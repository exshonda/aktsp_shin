#!/bin/bash
#
#  AKTSP テストプログラムの生成とビルド (RH850/F1KM-S1, atk2_sc1_shin, Linux 版 CC-RH)
#
#  usage: gen_build.sh <outdir> <yaml>...
#
#  <yaml> は展開済みの TESRY データ (expand_tesry.sh で .cmy から作る)．
#  <outdir> に out.c/out.h/out.arxml (AKTG 生成物)，Makefile，atk2-sc1.elf，
#  expected_count (最終チェックポイント番号) を作る．
#
#  環境変数:
#    ATK2_DIR  ATK2 のソースツリー (既定: aktsp と並べて置いた ../atk2_sc1_shin)
#    MAKE_JOBS make の並列数 (既定: 8)
#    FUNC_INTERRUPT/FUNC_HARDWARE_COUNTER/FUNC_PROTECTION_HOOK  AKTG の同名オプション (既定: true)
#    AKTG_EXTRA  AKTG への追加オプション (-f を含むと強制マージ: make に -DENABLE_RETURN_MAIN を足す)
#    AKTSP_CDEFS コンパイラへの追加定義 (既定: スタックサイズを自動で決める．下記参照)
#    RAM_END     RAM の終端 (既定: 0xFEE00000．RH850/F1KM-S1 のローカル RAM 128KB)
#    CCRH が PATH 上にあること (Linux 版 CC-RH)
#
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
AKTSP=$(cd "$HERE/../../.." && pwd)
ATK2_DIR=$(cd "${ATK2_DIR:-$AKTSP/../atk2_sc1_shin}" && pwd)
# CC-RH (-Ospeed -Oinline_size) は全テストのフック本体を ErrorHook 等へ
# インライン展開するため，フックのフレームが 500 バイトを超える．SC1 の
# ErrorHook/PreTaskHook/PostTaskHook は呼出し元タスクのスタックで動くので，
# 既定の 1280 バイトでは E_OS_STACKFAULT になる．syssrv_test/sc1 の *_error は
# 2048 バイト，IncrementCounter_nml_* (アラーム満了→タスク起動がサービス
# コール内で重なる) は 4096 バイト，HW カウンタ割込みを伴うものは 8192 バイトが要る．
# ISR/フックが使う OS スタック (AKTSP_HOOK_STACK_SIZE 分を含む) も，既定の
# 512 バイトでは予備領域を越えてあふれ，直下の cp_state 等を書き潰した
AKTSP_CDEFS_USER=${AKTSP_CDEFS:-}
RAM_END=${RAM_END:-0xFEE00000}
# AKTG に渡すターゲット依存関数の有無 (true/false)
FUNC_INTERRUPT=${FUNC_INTERRUPT:-true}
FUNC_HARDWARE_COUNTER=${FUNC_HARDWARE_COUNTER:-true}
FUNC_PROTECTION_HOOK=${FUNC_PROTECTION_HOOK:-true}
# AKTG への追加オプション (テスト群ごとの OS 設定．例: --return_status STANDARD)
AKTG_EXTRA=${AKTG_EXTRA:-}
BASE_MAKEFILE=$ATK2_DIR/obj/obj_rh850f1kms1_ccrh/Makefile

[ $# -ge 2 ] || { echo "usage: $0 <outdir> <yaml>..."; exit 1; }
out=$1; shift
yamls=()
for y in "$@"; do yamls+=("$(cd "$(dirname "$y")" && pwd)/$(basename "$y")"); done

mkdir -p "$out"; cd "$out"
rm -f out.c out.h out.arxml atk2-sc1.elf expected_count aktg_exclusion_list.txt

# AKTG (SC1, シングルコア)
if ! ruby "$AKTSP/tools/aktg/bin/aktg.rb" -p \
     --scalability_class SC1 --core_num 1 --use_multi_core false \
     --func_interrupt "$FUNC_INTERRUPT" --func_hardware_counter "$FUNC_HARDWARE_COUNTER" \
     --func_protection_hook "$FUNC_PROTECTION_HOOK" $AKTG_EXTRA \
     --out_file_name out "${yamls[@]}" > aktg.log 2>&1; then
  echo "AKTG failed (see $out/aktg.log)"; exit 1
fi
if [ -s aktg_exclusion_list.txt ]; then
  echo "excluded by AKTG:"; cat aktg_exclusion_list.txt
fi

# スタックサイズ: 指定がなければ，共有スタックの本数 (AKTG_STACK_NUM) から決める．
# タスクスタックの合計を 64KB に収め，1 本あたり最大 8192 バイト (2 の冪)．
# modistarc は 16 本使うので 4096 バイトになる (8192 だと RAM 128KB を超える)
if [ -n "$AKTSP_CDEFS_USER" ]; then
  AKTSP_CDEFS=$AKTSP_CDEFS_USER
else
  nstk=$(sed -n 's/^#define AKTG_STACK_NUM \([0-9]*\).*/\1/p' out.h)
  tsz=8192
  while [ "${nstk:-1}" -gt 0 ] && [ $((tsz * ${nstk:-1})) -gt 65536 ] && [ $tsz -gt 1024 ]; do tsz=$((tsz / 2)); done
  AKTSP_CDEFS="-DAKTSP_TASK_STACK_SIZE=${tsz}U -DAKTSP_HOOK_STACK_SIZE=4096U"
fi
# 強制マージ (AKTG -f): シャットダウン後に main へ戻して次のテストを StartOS する
case " $AKTG_EXTRA " in *" -f "*) AKTSP_CDEFS="$AKTSP_CDEFS -DENABLE_RETURN_MAIN" ;; esac
echo "$AKTSP_CDEFS" > aktsp_cdefs

# ATK2 の Python 版 cfg は EUC-JP の arxml を読めないので UTF-8 化する
# (vpath の先頭が . なので，ここに置いたものが優先される)
for f in out.arxml "$AKTSP/library/common/aktsp_implementation_data_types.arxml"; do
  iconv -f EUC-JP -t UTF-8 "$f" | sed '1s/encoding="EUC-JP"/encoding="UTF-8"/' > "$(basename "$f").tmp"
done
mv out.arxml.tmp out.arxml
mv aktsp_implementation_data_types.arxml.tmp aktsp_implementation_data_types.arxml

# サンプル用の Makefile からテスト用の Makefile を作る
sed \
 -e "s|^SRCDIR = \.\./\.\.\$|SRCDIR = $ATK2_DIR\nAKTSP = $AKTSP|" \
 -e 's|^CFGNAME = sample1$|CFGNAME = out aktsp_implementation_data_types|' \
 -e 's|^OMIT_HW_COUNTER =$|OMIT_HW_COUNTER = true|' \
 -e 's|^APPLNAME = sample1$|APPLNAME = out|' \
 -e 's|^APPLDIR  = \$(SRCDIR)/sample$|APPLDIR  = .\nAKTSP_LIBDIRS = $(AKTSP)/library/common $(AKTSP)/library/implement/atk2 $(AKTSP)/library/arch/v850 $(AKTSP)/library/arch/v850/ccrh|' \
 -e 's|^APPL_DIR = \$(APPLDIR) \$(SRCDIR)/library$|APPL_DIR = $(APPLDIR) $(SRCDIR)/library $(AKTSP_LIBDIRS)|' \
 -e 's|^APPL_ASMOBJS =$|APPL_ASMOBJS = aktsp_target.obj|' \
 -e 's|^APPL_COBJS = \$(APPLNAME)\.obj$|APPL_COBJS = $(APPLNAME).obj aktsp_common_lib.obj aktsp_implement_lib.obj aktsp_target_lib.obj|' \
 -e 's|^INCLUDES := \$(INCLUDES) \$(foreach dir,\$(APPLDIR),-I\$(dir))$|INCLUDES := $(INCLUDES) $(foreach dir,$(APPLDIR) $(AKTSP_LIBDIRS),-I$(dir))|' \
 "$BASE_MAKEFILE" > Makefile
cat >> Makefile <<'MK'

# AKTSP 向けの追加定義 (gen_build.sh が make の引数で渡す)
CDEFS := $(CDEFS) $(AKTSP_CDEFS)
MK
# 置換が 1 つでも外れると黙ってサンプルをビルドしてしまうので，全件当たったことを確かめる
nsub=$(diff "$BASE_MAKEFILE" Makefile | grep -c '^>' || true)
if [ "$nsub" -ne 14 ]; then
  echo "Makefile generation: expected 14 changed lines, got $nsub ($BASE_MAKEFILE changed?)"; exit 1
fi

# AKTSP_CDEFS の変更は依存関係に現れないので，常に全体を作り直す
make clean > /dev/null 2>&1 || true
if ! make -j"${MAKE_JOBS:-8}" AKTSP_CDEFS="$AKTSP_CDEFS" > make.log 2>&1; then
  echo "make failed (see $out/make.log)"
  grep -E "[EF]0[0-9]{6}" make.log | head || true
  exit 1
fi
[ -f atk2-sc1.elf ] || { echo "atk2-sc1.elf not built"; exit 1; }

# RAM あふれの検査 (rlink は RAM 容量を知らないので，あふれても黙ってリンクする)
ram_end=$(awk '/^SECTION +START/{f=1;next} f&&/^\*\*\*/{exit} f&&NF==4&&$1~/^fe/{print $2}' atk2-sc1.map | sort | tail -1)
if [ -z "$ram_end" ] || [ $((16#$ram_end)) -ge $((RAM_END)) ]; then
  echo "RAM overflow: end=0x$ram_end >= $RAM_END ($AKTSP_CDEFS)"; exit 1
fi

# 最終チェックポイント = out.c 中の最大のチェックポイント番号．通常は MainTask 末尾の
# AktspCheckFinish(N) だが，ShutdownHook を試すテストを含むと ShutdownHook 内の
# AktspCheckPoint(N) が最後になる (チェックポイントは実行順に通し番号)
max=$(grep -o -E 'Aktsp(CheckPoint|CheckFinish)\([0-9]+\)' out.c | grep -o -E '[0-9]+' | sort -n | tail -1 || true)
[ -n "$max" ] || { echo "no checkpoint in out.c"; exit 1; }
echo "$max" > expected_count

echo "built: $out/atk2-sc1.elf"
echo "expected_count: $(cat expected_count)"
grep -E " _(check_count\.1|cp_state|infinite_loop|AktspInfiniteLoop)\$" atk2-sc1.syms
