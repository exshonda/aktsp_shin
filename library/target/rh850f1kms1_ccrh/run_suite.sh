#!/bin/bash
#
#  SC1 のテスト群をまとめて生成・ビルド・実機実行する
#
#  usage: run_suite.sh <suite>... [-- <workdir> [<block size>]]
#    <suite>      syssrv | modistarc | stack_monitoring | cpu_exception_merge |
#                 cpu_exception_notmerge | illegal_terminate_task |
#                 illegal_terminate_c2isr | all
#    <workdir>    作業ディレクトリ (既定: <aktsp>/obj/suite)．<workdir>/<suite>/ に作る
#    <block size> 1 つのロードモジュールに入れるテスト数 (既定: 100)
#
#  AKTG のオプションは aktb.sh (scripts/*.sh) が各テスト群に与えるものに合わせる．
#  マージ不可能 (notmerge) なテストは強制マージ (AKTG -f，ENABLE_RETURN_MAIN) で
#  1 つのロードモジュールにまとめ，run_test.py がテストごとに判定する．強制マージでは
#  OS 構成 (フックの有無等) がロードモジュールで共通になるので，aktb.sh と同じく
#  .cmy ごとにブロックを分ける (例: ProtectionHook あり/なしを混ぜない)．
#
#  環境変数: CSPLUS_MCP_SERVER, ATK2_DIR, AKTSP_CDEFS (gen_build.sh/run_test.py 参照)
#  BUILD_PARALLEL ブロックの並列ビルド数 (既定: 4)
#  EXCLUDE        この拡張正規表現に一致する "type: ..." を含む YAML を除く
#
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
AKTSP=$(cd "$HERE/../../.." && pwd)

suites=()
while [ $# -gt 0 ] && [ "$1" != "--" ]; do suites+=("$1"); shift; done
[ "${1:-}" = "--" ] && shift
W=${1:-$AKTSP/obj/suite}
BLOCK=${2:-100}
[ ${#suites[@]} -gt 0 ] || { sed -n '4,10p' "$0"; exit 1; }
if [ "${suites[0]}" = all ]; then
  suites=(syssrv modistarc stack_monitoring cpu_exception_merge cpu_exception_notmerge
          illegal_terminate_task illegal_terminate_c2isr)
fi

# OS 機能の設定: aktb.sh の SC1 の場合と同じ
OFF="--stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status STANDARD"
SM="--stack_monitoring true --stackfault_detection false --stack_share true"

preset()
{
  case $1 in
    syssrv)                  SRC=syssrv_test/sc1; EXTRA= ;;
    modistarc)               SRC=modistarc/sc1; EXTRA=$OFF ;;
    stack_monitoring)        SRC=protection_test/sc1/stack_monitoring/notmerge_tesry
                             EXTRA="-f $SM --use_get_serviceid false --use_parameter_access false --return_status STANDARD" ;;
    cpu_exception_merge)     SRC=protection_test/sc1/cpu_exception/merge_tesry; EXTRA=$OFF ;;
    cpu_exception_notmerge)  SRC=protection_test/sc1/cpu_exception/notmerge_tesry; EXTRA="-f $OFF" ;;
    illegal_terminate_task)  SRC=error_test/sc1/illegal_terminate_task
                             EXTRA="-f $SM --use_get_serviceid true --use_parameter_access false --return_status STANDARD" ;;
    illegal_terminate_c2isr) SRC=error_test/sc1/illegal_terminate_c2isr
                             EXTRA="-f $SM --use_get_serviceid true --use_parameter_access false --return_status STANDARD" ;;
    *) echo "unknown suite: $1"; exit 1 ;;
  esac
}

for s in "${suites[@]}"; do
  preset "$s"
  D=$W/$s
  mkdir -p "$D"; D=$(cd "$D" && pwd)
  echo "=== $s ($SRC) AKTG_EXTRA='$EXTRA'"

  # 1. .cmy を展開
  rm -rf "$D/tesry"
  "$HERE/expand_tesry.sh" "$D/tesry" $(find "$AKTSP/$SRC" -name '*.cmy' | sort) > "$D/expand.log"

  # 2. 対象を選ぶ
  if [ -n "${EXCLUDE:-}" ]; then
    find "$D/tesry" -name '*.yaml' | sort | while read -r f; do
      grep -q -E "type: ($EXCLUDE)\b" "$f" || echo "$f"
    done > "$D/selected.list"
  else
    find "$D/tesry" -name '*.yaml' | sort > "$D/selected.list"
  fi
  echo "selected $(wc -l < "$D/selected.list") / $(find "$D/tesry" -name '*.yaml' | wc -l) yaml"

  # 3. ブロックに分けてビルド
  rm -rf "$D"/block.* "$D"/b[0-9][0-9][0-9]
  case " $EXTRA " in
    *" -f "*)  # 強制マージ: .cmy (展開先ディレクトリ) ごとに分ける
      i=0
      for g in $(sed 's|/[^/]*$||' "$D/selected.list" | sort -u); do
        grep "^$g/" "$D/selected.list" | split -l "$BLOCK" -d -a 3 - "$D/tmpblock."
        for t in "$D"/tmpblock.*; do mv "$t" "$D/block.$(printf %03d $i)"; i=$((i + 1)); done
      done ;;
    *) split -l "$BLOCK" -d -a 3 "$D/selected.list" "$D/block." ;;
  esac
  ls "$D"/block.* | AKTG_EXTRA="$EXTRA" xargs -P "${BUILD_PARALLEL:-4}" -I{} bash -c \
    'b={}; n=${b##*.}; MAKE_JOBS=4 "$0" "$1/b$n" $(cat "$b") > "$1/build_$n.log" 2>&1 || echo "build failed: b$n (see $1/build_$n.log)"' \
    "$HERE/gen_build.sh" "$D"

  # 4. 実機で実行
  "$HERE/run_test.py" --timeout 120 $(ls -d "$D"/b[0-9][0-9][0-9]) | tee "$D/run.log" || true
done
