#
#  プロセッサ種別
#
MCU=R7F701025xAFP

# 実行形式ファイル拡張子
MODULE_EXTENSION="abs"

# CS+の使用タイプ
CS_TYPE="CC"

# ターゲット依存共通シェル読み込み
source ./library/arch/v850/aktsp_csplus_with_build.sh

#
# アーキテクチャフォルダ(aktsp/library/arch配下の使用するフォルダ)の定義
# (必要な場合のみ)
# (複数指定可能，複数指定する場合はスペースで区切る)
#  例) "arm_gcc/mpcore arm_gcc/common"
#
ARCH_PATH="v850 v850/ccrh"

