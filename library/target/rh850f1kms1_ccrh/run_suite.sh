#!/bin/bash
#
#  syssrv_test/sc1 のうち，割込みとハードウェアカウンタを使わないテストを
#  まとめて生成・ビルド・実機実行する
#
#  usage: run_suite.sh [<workdir>] [<block size>]
#    <workdir>    作業ディレクトリ (既定: <aktsp>/obj/f1kms1)
#    <block size> 1 つのロードモジュールに入れるテスト数 (既定: 100)
#
#  環境変数: CSPLUS_MCP_SERVER, ATK2_DIR, AKTSP_CDEFS (gen_build.sh/run_test.py 参照)
#  BUILD_PARALLEL ブロックの並列ビルド数 (既定: 4)
#
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
AKTSP=$(cd "$HERE/../../.." && pwd)
W=${1:-$AKTSP/obj/f1kms1}
BLOCK=${2:-100}
mkdir -p "$W"; W=$(cd "$W" && pwd)

# 1. .cmy を展開
"$HERE/expand_tesry.sh" "$W/tesry" $(find "$AKTSP/syssrv_test/sc1" -name '*.cmy' | sort) > "$W/expand.log"

# 2. 割込み (C1ISR/C2ISR/ISRT)，HW カウンタ (AK_HARDWARE)，プロテクションフックを
#    使うものを除く (F1KM-S1 向けのターゲット依存関数が未整備のため)
find "$W/tesry" -name '*.yaml' | sort | while read -r f; do
  grep -q -E 'type: (C1ISR|C2ISR|AK_HARDWARE|PROTECTION_HOOK|ISRT)\b' "$f" || echo "$f"
done > "$W/selected.list"
echo "selected $(wc -l < "$W/selected.list") / $(find "$W/tesry" -name '*.yaml' | wc -l) yaml"

# 3. ブロックに分けてビルド
rm -rf "$W"/block.* "$W"/b[0-9][0-9]
split -l "$BLOCK" -d -a 2 "$W/selected.list" "$W/block."
ls "$W"/block.* | xargs -P "${BUILD_PARALLEL:-4}" -I{} bash -c \
  'b={}; n=${b##*.}; MAKE_JOBS=4 "$0" "$1/b$n" $(cat "$b") > "$1/build_$n.log" 2>&1 || echo "build failed: b$n (see $1/build_$n.log)"' \
  "$HERE/gen_build.sh" "$W"

# 4. 実機で実行
"$HERE/run_test.py" --timeout 120 $(ls -d "$W"/b[0-9][0-9]) | tee "$W/run.log"
