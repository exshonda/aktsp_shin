# ターゲット依存共通シェル読み込み
source ./library/arch/v850e2/aktsp_v850e2_common.sh

#
# アーキテクチャフォルダ(aktsp/library/arch配下の使用するフォルダ)の定義
# (必要な場合のみ)
# (複数指定可能，複数指定する場合はスペースで区切る)
#  例) "arm_gcc/mpcore arm_gcc/common"
#
ARCH_PATH="v850e2 v850e2/ghs"

