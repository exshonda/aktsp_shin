#
#  プロセッサ種別をMakefile.targetから取得
#
MCU=`grep "^MCU" $OS_PATH/target/$TARGET_NAME/Makefile.target | awk -F '#' '{print $1}' | sed -e "s/^MCU\s=\s\(.*\)\s*.*$/\1/"`

# ターゲット依存共通シェル読み込み
source ./library/arch/v850e2/aktsp_v850e2_common.sh

#
# V850E2S(f3577)は割込み優先度が7段のためC1ISRを除外する
#
if [ "$MCU" == "f3577" ]
then
	AKTG_OPT="$AKTG_OPT --use_c1isr false"
fi

#
# アーキテクチャフォルダ(aktsp/library/arch配下の使用するフォルダ)の定義
# (必要な場合のみ)
# (複数指定可能，複数指定する場合はスペースで区切る)
#  例) "arm_gcc/mpcore arm_gcc/common"
#
ARCH_PATH="v850e2 v850e2/gcc"

