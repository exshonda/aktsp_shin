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


ERRNAME = {0: "E_OK", 1: "E_OS_ACCESS", 2: "E_OS_CALLEVEL", 3: "E_OS_ID", 4: "E_OS_LIMIT",
           5: "E_OS_NOFUNC", 6: "E_OS_RESOURCE", 7: "E_OS_STATE", 8: "E_OS_VALUE",
           9: "E_OS_SERVICEID", 10: "E_OS_ILLEGAL_ADDRESS", 11: "E_OS_MISSINGEND",
           12: "E_OS_DISABLEDINT", 13: "E_OS_STACKFAULT", 14: "E_OS_PROTECTION_MEMORY",
           15: "E_OS_PROTECTION_TIME_TASK", 16: "E_OS_PROTECTION_TIME_ISR",
           17: "E_OS_PROTECTION_ARRIVAL_TASK", 18: "E_OS_PROTECTION_ARRIVAL_ISR",
           19: "E_OS_PROTECTION_LOCKED_RESOURCE", 20: "E_OS_PROTECTION_LOCKED_OSINT",
           21: "E_OS_PROTECTION_LOCKED_ALLINT", 22: "E_OS_PROTECTION_EXCEPTION",
           23: "E_OS_PROTECTION_FATAL", 24: "E_OS_MODE", 25: "E_OS_SHUTDOWN_FATAL",
           26: "E_OS_PARAM_POINTER", 27: "E_OS_SYS_ASSERT_FATAL", 28: "E_OS_STACKINSUFFICIENT"}


def sym_of(syms: dict[str, int], addr: int) -> str:
    best = max(((a, n) for n, a in syms.items() if a <= addr and a < 0xfe000000),
               default=(0, "?"))
    return f"{best[1]}+0x{addr - best[0]:x}"


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


def load_and_setup(mcp: Mcp, server: str, outdir: Path, syms: dict[str, int],
                   extra_breaks: tuple[str, ...] = ()) -> None:
    """書込み・リセットし，判定用のブレークポイントを置く．"""
    elf = outdir / "atk2-sc1.elf"
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
    # OS がシャットダウンする原因 (StatusType と呼出し元) を記録する．
    # 正常終了でも ShutdownOS(E_OK) で通るので，記録したら実行を続ける
    a_sd = syms.get("_kernel_internal_shutdownos")
    if a_sd is not None:
        mcp.call("add_breakpoint", address=a_sd, breakpoint_type="hardware")
    for loc in extra_breaks:
        mcp.call("add_breakpoint_at", location=loc, breakpoint_type="hardware")
    a_count, a_state = syms["_check_count.1"], syms["_cp_state"]
    mcp.call("write_memory", address=a_count, data=list(JUNK_COUNT.to_bytes(4, "little")))
    mcp.call("write_memory", address=a_state, data=[JUNK_STATE])
    if (le(mcp.call("read_memory", address=a_count, length=4), 4) != JUNK_COUNT
            or le(mcp.call("read_memory", address=a_state, length=1), 1) != JUNK_STATE):
        raise McpError("pre-fill of check_count/cp_state did not stick")


def describe_stop(mcp: Mcp, syms: dict[str, int], pc: int) -> str:
    """_CheckErcd/_CheckAssert で止まっていれば，その式・ファイル・行を返す．"""
    a_cerc, a_cass = syms.get("__CheckErcd"), syms.get("__CheckAssert")
    if pc not in (a_cerc, a_cass):
        return ""
    r6, r7, r8 = (int(mcp.call("read_register", name=r)) for r in ("r6", "r7", "r8"))
    if pc == a_cass:
        return f" CheckAssert({read_cstr(mcp, r6)}) at {read_cstr(mcp, r7)}:{r8}"
    return f" CheckErcd: unexpected ercd={r6} at {read_cstr(mcp, r7)}:{r8}"


def run_one(mcp: Mcp, server: str, outdir: Path, timeout: float) -> tuple[bool, str]:
    syms = read_syms(outdir / "atk2-sc1.syms")
    if "ENUM_AKTG_FORCE_MERGE_bootcnt" in (outdir / "out.c").read_text(errors="replace"):
        return run_forced(mcp, server, outdir, timeout, syms)
    expected = int((outdir / "expected_count").read_text().strip())
    a_count, a_state = syms["_check_count.1"], syms["_cp_state"]
    a_loop = syms["_infinite_loop"]
    a_sd = syms.get("_kernel_internal_shutdownos")
    load_and_setup(mcp, server, outdir, syms)

    t0 = time.monotonic()
    hung = False
    shutdown = []
    while True:
        mcp.call("run")
        while mcp.call("get_status").get("state") == "TARGET_RUNNING":
            if time.monotonic() - t0 > timeout:
                mcp.call("halt")
                hung = True
                break
            time.sleep(0.2)
        pc = int(mcp.call("get_pc"))
        if hung or pc != a_sd or len(shutdown) >= 4:
            break
        err = int(mcp.call("read_register", name="r6"))
        lp = int(mcp.call("read_register", name="lp"))
        shutdown.append(f"E={err}({ERRNAME.get(err, '?')}) from {sym_of(syms, lp)}")
    elapsed = time.monotonic() - t0
    where = describe_stop(mcp, syms, pc)
    count = le(mcp.call("read_memory", address=a_count, length=4), 4)
    state = le(mcp.call("read_memory", address=a_state, length=1), 1)
    ok = (not hung and pc == a_loop and count == expected and state == AK_TRUE)
    detail = (f"pc=0x{pc:x}{' (infinite_loop)' if pc == a_loop else ''} "
              f"check_count={count}/{expected} cp_state={state} {elapsed:.1f}s")
    if hung:
        detail += f" TIMEOUT(>{timeout:.0f}s)"
    detail += where
    if shutdown and not ok:
        detail += " [ShutdownOS: " + "; ".join(shutdown) + "]"
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


def forced_merge_plan(out_c: Path) -> list[tuple[str, int]]:
    """強制マージの out.c から，実行順のテスト ID と各テストの最終チェックポイントを得る．

    AktspInitializeTestLib はブートごとに check_count を 0 に戻すので，期待値は
    テストごとに決まる．チェックポイントは，その直前に現れたテスト ID (関数名や
    ENUM_AKTG_FORCE_MERGE_bootcnt の比較) のテストに属するものとして数える．

    期待値は，そのテストのコード中で AktspOutputLog_0("All check points passed.")
    を直接出力している箇所があれば，その直前のチェックポイント番号 (finish: true の
    テスト．合格を出力した後に OS がシャットダウンするのが正しく，以降のコードは
    実行されない)．なければ最大のチェックポイント番号 (AktspCheckFinish(N))．
    """
    text = out_c.read_text(errors="replace")
    order = re.findall(r'AktspOutputLog_0\("\\n=== (\S+) ==="\)', text)
    if not order:
        raise ValueError("forced merge: test order not found in out.c")
    id_re = re.compile("|".join(re.escape(t) for t in sorted(order, key=len, reverse=True)))
    cp_re = re.compile(r"\bAktsp(?:CheckPoint|CheckFinish)\((\d+)\)")
    best: dict[str, int] = {}
    finish: dict[str, int] = {}
    last: dict[str, int] = {}
    current = None
    for line in text.splitlines():
        m = id_re.search(line)
        if m and not (m.end() < len(line) and (line[m.end()].isdigit())):
            current = m.group(0)
        if current is None:
            continue
        c = cp_re.search(line)
        if c and int(c.group(1)) > 0:
            best[current] = max(best.get(current, 0), int(c.group(1)))
            last[current] = int(c.group(1))
        if 'AktspOutputLog_0("All check points passed.")' in line and current in last:
            finish[current] = max(finish.get(current, 0), last[current])
    return [(t, finish.get(t, best.get(t, 0))) for t in order]


def run_forced(mcp: Mcp, server: str, outdir: Path, timeout: float,
               syms: dict[str, int]) -> tuple[bool, str]:
    """強制マージ: 1 つのロードモジュールで複数のテストを順に実行する (ENABLE_RETURN_MAIN)．

    次のテストの AktspInitializeTestLib に入ったところで，直前のテストを判定する．
    最後のテストは AktspInfiniteLoop で判定する．
    """
    plan = forced_merge_plan(outdir / "out.c")
    a_count, a_state = syms["_check_count.1"], syms["_cp_state"]
    a_init, a_inf = syms["_AktspInitializeTestLib"], syms["_AktspInfiniteLoop"]
    a_loop, a_sd = syms["_infinite_loop"], syms.get("_kernel_internal_shutdownos")
    load_and_setup(mcp, server, outdir, syms, extra_breaks=("AktspInitializeTestLib",))

    results: list[tuple[str, bool, str]] = []
    boot = -1          # 実行中のテストの番号
    notes: list[str] = []   # 失敗の証拠 (CheckErcd/CheckAssert/タイムアウト)
    diags: list[str] = []   # 参考情報 (シャットダウン要因．finish テストでは正常)
    t0 = time.monotonic()
    t_test = t0

    def judge(idx: int, end: str) -> None:
        name, exp = plan[idx]
        count = le(mcp.call("read_memory", address=a_count, length=4), 4)
        state = le(mcp.call("read_memory", address=a_state, length=1), 1)
        ok = exp > 0 and count == exp and state == AK_TRUE and not notes
        d = f"check_count={count}/{exp} cp_state={state}"
        if not ok:
            d += " " + " ".join(notes + diags) + f" [{end}]"
        results.append((name, ok, d))

    while True:
        mcp.call("run")
        hung = False
        while mcp.call("get_status").get("state") == "TARGET_RUNNING":
            if time.monotonic() - t_test > timeout:
                mcp.call("halt")
                hung = True
                break
            time.sleep(0.1)
        pc = int(mcp.call("get_pc"))
        if hung:
            notes.append(f"TIMEOUT(>{timeout:.0f}s) pc={sym_of(syms, pc)}")
            if boot >= 0:
                judge(boot, "hung")
            break
        if pc == a_init:
            # main はブートごとに AktspInitializeTestLib を呼ぶ．最後のテストの後にも
            # 1 回呼んでから AktspInfiniteLoop に入る
            if 0 <= boot < len(plan):
                judge(boot, "next boot")
            boot += 1
            notes, diags = [], []
            t_test = time.monotonic()
            continue
        if pc == a_sd:
            err = int(mcp.call("read_register", name="r6"))
            if err != 0 and len(diags) < 4:
                lp = int(mcp.call("read_register", name="lp"))
                diags.append(f"ShutdownOS(E={err}({ERRNAME.get(err, '?')}) from {sym_of(syms, lp)})")
            continue
        w = describe_stop(mcp, syms, pc)
        if w:
            notes.append(w.strip())
            continue
        # AktspInfiniteLoop (全テスト終了) か infinite_loop (main に戻れなかった)
        if 0 <= boot < len(plan):
            judge(boot, "end" if pc == a_inf else f"stopped at {sym_of(syms, pc)}")
        break

    missing = [t for t, _ in plan[len(results):]]
    npass = sum(ok for _, ok, _ in results)
    ok_all = npass == len(plan) and not missing and pc == a_inf
    lines = [f"forced merge {npass}/{len(plan)} passed {time.monotonic() - t0:.1f}s"]
    lines += [f"    FAIL {n}: {d}" for n, ok, d in results if not ok]
    if missing:
        lines.append(f"    NOT RUN ({len(missing)}): {', '.join(missing[:5])}{' ...' if len(missing) > 5 else ''}")
    return ok_all, "\n".join(lines)


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
