#!/usr/bin/env python3
"""gen_build.sh で作ったテストを CS+ MCP 経由で実機実行し，合否を判定する．

usage: run_test.py [--server URL] [--timeout SEC] <outdir>...

シリアルログは使わず，RAM 上の check_count / cp_state で判定する．
  PASS: infinite_loop で停止 かつ check_count == expected_count かつ cp_state == 1
実行前に check_count / cp_state へありえない値を書いておく (リセットでは RAM が
消えないため，書かないと前回の実行結果を読んでしまう)．

ロードモジュールの転送には rh850-csplus-upload (lades_csplus_mcp) を使う．
見つからない場合は環境変数 RH850_UPLOAD でパスを指定する．
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

DEFAULT_SERVER = os.environ.get("CSPLUS_MCP_SERVER", "http://172.24.11.129:8765")
JUNK_COUNT = 0xDEADBEEF
JUNK_STATE = 0xAA
AK_TRUE = 1


class McpError(Exception):
    pass


class Mcp:
    """streamable HTTP の MCP サーバへの最小クライアント．"""

    def __init__(self, server: str) -> None:
        self.url = server.rstrip("/") + "/mcp"
        self.session: str | None = None
        self.next_id = 1
        self._post({"jsonrpc": "2.0", "id": self._id(), "method": "initialize",
                    "params": {"protocolVersion": "2025-03-26", "capabilities": {},
                               "clientInfo": {"name": "aktsp-run-test", "version": "1"}}})
        self._post({"jsonrpc": "2.0", "method": "notifications/initialized"})

    def _id(self) -> int:
        self.next_id += 1
        return self.next_id

    def _post(self, body: dict) -> dict | None:
        headers = {"Content-Type": "application/json",
                   "Accept": "application/json, text/event-stream"}
        if self.session:
            headers["Mcp-Session-Id"] = self.session
        req = urllib.request.Request(self.url, json.dumps(body).encode(), headers)
        with urllib.request.urlopen(req, timeout=300) as res:
            sid = res.headers.get("Mcp-Session-Id")
            if sid:
                self.session = sid
            text = res.read().decode("utf-8", "replace")
        if "id" not in body:
            return None
        # JSON 単体か SSE (data: 行) のどちらでも受ける
        for chunk in [text] + [l[5:].strip() for l in text.splitlines() if l.startswith("data:")]:
            try:
                msg = json.loads(chunk)
            except ValueError:
                continue
            if isinstance(msg, dict) and msg.get("id") == body["id"]:
                return msg
        raise McpError(f"no response for {body.get('method')}: {text[:200]}")

    def call(self, tool: str, **args):
        msg = self._post({"jsonrpc": "2.0", "id": self._id(), "method": "tools/call",
                          "params": {"name": tool, "arguments": args}})
        if "error" in msg:
            raise McpError(f"{tool}: {msg['error']}")
        res = msg["result"]
        text = "".join(c.get("text", "") for c in res.get("content", []))
        try:
            payload = json.loads(text)
        except ValueError:
            raise McpError(f"{tool}: unexpected result {text[:200]}")
        if res.get("isError") or not payload.get("ok", False):
            raise McpError(f"{tool}: {payload}")
        return payload.get("result")


def read_syms(path: Path) -> dict[str, int]:
    syms = {}
    for line in path.read_text(errors="replace").splitlines():
        f = line.split()
        if len(f) == 3:
            syms[f[2]] = int(f[0], 16)
    return syms


def checkpoint_owner(out_c: Path, count: int) -> str:
    """AktspCheckPoint(count) を含むテスト ID (分かる範囲で) を返す．"""
    test_re = re.compile(r"\b([A-Za-z0-9]+_[A-Za-z0-9_]*?_\d{4}(?:_\d+)?)(?![0-9])")
    current = "?"
    for line in out_c.read_text(errors="replace").splitlines():
        m = test_re.search(line)
        if m:
            current = m.group(1)
        if re.search(rf"\bAktsp(?:Check(?:Point|Finish)|WaitCheckPoint)\({count}\)", line):
            return current
    return "?"


def read_cstr(mcp: "Mcp", addr: int, limit: int = 160) -> str:
    data = bytes(int(b) for b in mcp.call("read_memory", address=addr, length=limit))
    return data.split(b"\0", 1)[0].decode("ascii", "replace")


def le(data, n: int) -> int:
    return sum(int(b) << (8 * i) for i, b in enumerate(data[:n]))


def upload(server: str, elf: Path) -> None:
    exe = os.environ.get("RH850_UPLOAD") or shutil.which("rh850-csplus-upload")
    if not exe:
        guess = Path(__file__).resolve().parents[4] / "lades_csplus_mcp/.venv/bin/rh850-csplus-upload"
        exe = str(guess) if guess.exists() else None
    if not exe:
        raise McpError("rh850-csplus-upload not found (set RH850_UPLOAD)")
    r = subprocess.run([exe, "--server", server, "--file", str(elf)],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise McpError(f"upload failed: {r.stderr.strip()}")


def run_one(mcp: Mcp, server: str, outdir: Path, timeout: float) -> tuple[bool, str]:
    elf = outdir / "atk2-sc1.elf"
    syms = read_syms(outdir / "atk2-sc1.syms")
    expected = int((outdir / "expected_count").read_text().strip())
    a_count, a_state = syms["_check_count.1"], syms["_cp_state"]
    a_loop = syms["_infinite_loop"]
    a_cerc, a_cass = syms.get("__CheckErcd"), syms.get("__CheckAssert")

    upload(server, elf)
    st = mcp.call("get_status")
    if st.get("state") == "TARGET_RUNNING":
        mcp.call("halt")
    elif st.get("state") not in ("TARGET_STOPPED",):
        mcp.call("connect_target")
    dl = mcp.call("download_loadmodule")
    if dl.get("file_name") != elf.name:
        raise McpError(f"downloaded {dl}")
    mcp.call("clear_breakpoints")
    mcp.call("reset")
    mcp.call("add_breakpoint_at", location="infinite_loop", breakpoint_type="hardware")
    mcp.call("add_breakpoint_at", location="AktspInfiniteLoop", breakpoint_type="hardware")
    # 失敗箇所を特定するため，CheckErcd/CheckAssert の失敗処理でも止める
    # (失敗時は停止したままにする．引数 r6-r8 から式・ファイル・行が分かる)
    for loc in ("_CheckErcd", "_CheckAssert"):
        mcp.call("add_breakpoint_at", location=loc, breakpoint_type="hardware")
    mcp.call("write_memory", address=a_count, data=list(JUNK_COUNT.to_bytes(4, "little")))
    mcp.call("write_memory", address=a_state, data=[JUNK_STATE])
    if (le(mcp.call("read_memory", address=a_count, length=4), 4) != JUNK_COUNT
            or le(mcp.call("read_memory", address=a_state, length=1), 1) != JUNK_STATE):
        raise McpError("pre-fill of check_count/cp_state did not stick")

    t0 = time.monotonic()
    mcp.call("run")
    hung = False
    while mcp.call("get_status").get("state") == "TARGET_RUNNING":
        if time.monotonic() - t0 > timeout:
            mcp.call("halt")
            hung = True
            break
        time.sleep(0.5)
    elapsed = time.monotonic() - t0

    pc = int(mcp.call("get_pc"))
    where = ""
    if pc in (a_cerc, a_cass):
        r6, r7, r8 = (int(mcp.call("read_register", name=r)) for r in ("r6", "r7", "r8"))
        if pc == a_cass:
            where = f" CheckAssert({read_cstr(mcp, r6)}) at {read_cstr(mcp, r7)}:{r8}"
        else:
            where = f" CheckErcd: unexpected ercd={r6} at {read_cstr(mcp, r7)}:{r8}"
    count = le(mcp.call("read_memory", address=a_count, length=4), 4)
    state = le(mcp.call("read_memory", address=a_state, length=1), 1)
    ok = (not hung and pc == a_loop and count == expected and state == AK_TRUE)
    detail = (f"pc=0x{pc:x}{' (infinite_loop)' if pc == a_loop else ''} "
              f"check_count={count}/{expected} cp_state={state} {elapsed:.1f}s")
    if hung:
        detail += f" TIMEOUT(>{timeout:.0f}s)"
    detail += where
    if not ok:
        if count == JUNK_COUNT:
            detail += " [check_count untouched: test lib never initialised]"
        else:
            detail += f" [next checkpoint {count + 1} is in {checkpoint_owner(outdir / 'out.c', count + 1)}]"
        try:
            stack = mcp.call("get_call_stack")
            detail += "\n    " + "\n    ".join(s.get("address_info", "").strip() for s in stack[:6])
        except McpError:
            pass
    return ok, detail


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--server", default=DEFAULT_SERVER)
    ap.add_argument("--timeout", type=float, default=60.0)
    ap.add_argument("outdirs", nargs="+", type=Path)
    args = ap.parse_args()

    mcp = Mcp(args.server)
    npass = 0
    for d in args.outdirs:
        try:
            ok, detail = run_one(mcp, args.server, d, args.timeout)
        except (McpError, OSError, KeyError, ValueError) as e:
            ok, detail = False, f"ERROR {type(e).__name__}: {e}"
        npass += ok
        print(f"{'PASS' if ok else 'FAIL'} {d}: {detail}", flush=True)
    print(f"{npass}/{len(args.outdirs)} passed")
    return 0 if npass == len(args.outdirs) else 1


if __name__ == "__main__":
    sys.exit(main())
