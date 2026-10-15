#!/bin/sh
#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2011-2013 by Spansion LLC, USA
# Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2011-2014 by Witz Corporation, JAPAN
#
# 本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
# 
#  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
#  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
#  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
#  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
#      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
#      スコード中に含まれていること．
#  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
#      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
#      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
#      の無保証規定を掲載すること．
#  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
#      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
#      と．
#    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
#        作権表示，この利用条件および下記の無保証規定を掲載すること．
#    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
#        報告すること．
#  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
#      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
#      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
#      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
#      免責すること．
#
#  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
#  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
#  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
#  用する者に対して，AUTOSARパートナーになることを求めている．
#
#  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#  の責任を負わない．
# 
# $Id: aktb.sh 2054 2015-09-01 05:01:58Z aisincom-nishioka $

# AKTB開発時の注意
# ・変数の命名規則
#   ・マクロは全て大文字
#   ・グローバル変数には先頭に"g_"を付与
# ・configure.shの更新時
#   ・configure.shのCONF_VERSIONとaktb.shのAKTB_VERSIONを共に上げる
# ・aktsp_target.shの更新時
#   ・scriptsフォルダにある雛形の更新も行う

AKTB_VERSION="1.0.0"

# カレント実行チェック
chk=`dirname $0`
if [ $chk != "." ]
then
	echo "Need to execute at a directory of existing \"aktb.sh\""
	exit 1
fi

# aktspフォルダの絶対パス
AKTSP_DIR=`pwd`

# AKTB実行に必要なフォルダ(シングル/マルチコア共通)
NECESSARY_DIR="\
syssrv_test \
modistarc \
protection_test \
error_test \
library \
scripts \
tools"

# AKTB実行に必要なフォルダ(マルチコア)
NECESSARY_DIR_MC="\
atypical_syssrv_test \
ioc_test \
icisr_test"

# AKTB実行に必要なフォルダの有無をチェック
# マルチコア用チェックは，ターゲット依存の定義のインクルード後行う
# (USE_MULTI_COREの変数でマルチコアかを判断するため)
for dir in ${NECESSARY_DIR[@]}
do
	if [ ! -d $dir ]
	then
		echo "$dir is necessary directory"
		exit 1
	fi
done

# 設定ファイルの読込み
source ./configure.sh
source ./scripts/common.sh

# 第1引数でSCALABILITY_CLASSを上書き
if [ "$1" ]
then
	SCALABILITY_CLASS="$1"
fi

# 第2引数でTARGET_NAMEを上書き
if [ "$2" ]
then
	TARGET_NAME="$2"
fi


# バージョンチェック
if [ "$AKTB_VERSION" != "$CONF_VERSION" ]
then
	echo "$ERR_NOT_MATCH"
	exit 1
fi

#
# INCLUDE対象のパス定義
#
AKTSP_DIR_NAME=${AKTSP_DIR##*/}


#
# スケーラビリティクラス毎の設定
#
if [ $SCALABILITY_CLASS == "SC1" ]
then
	LOWER_CASE_SC="sc1"
elif [ $SCALABILITY_CLASS == "SC3" ]
then
	LOWER_CASE_SC="sc3"
else
	echo "$ERR_SC_INVALID ($SCALABILITY_CLASS)"
	exit 1
fi


# 第4引数でCORE_NUMを上書き
if [ "$4" ]
then
	CORE_NUM="$4"
fi

# 第5引数でUSE_MULTI_COREを上書き
if [ "$5" ]
then
	USE_MULTI_CORE="$5"
fi

#
# ターゲット依存の定義のインクルード
#
source ./library/target/$TARGET_NAME/aktsp_target.sh

# 第3引数をAKTG_OPTに追加
if [ "$3" ]
then
	AKTG_OPT="$AKTG_OPT $3"
fi

# 第6引数でコア間割込みの優先度を上書き
# ターゲット依存で設定したジェネレータへの追加オプション(-oのみ)
if [ "$6" ]
then
	CONFIG_OPT_O="$6"
fi

# AKTB実行に必要なフォルダの有無をチェック(マルチコア用)
if [ "$USE_MULTI_CORE" == "true" ]
then
	for dir in ${NECESSARY_DIR_MC[@]}
	do
		if [ ! -d $dir ]
		then
			echo "$dir is necessary directory"
			exit 1
		fi
	done
fi
# AKTB実行に必要なフォルダの有無をチェック(SC3用)
if [ $SCALABILITY_CLASS == "SC3" ] && [ "$USE_MULTI_CORE" == "false" ]
then
	if [ ! -d "ioc_test" ]
	then
		echo "ioc_test is necessary directory"
		exit 1
	fi
fi

#
# テスト対象フォルダの設定
#
SYSSRV_TEST_DIR="syssrv_test"
MODISTARC_DIR="modistarc"
STACK_MONITORING_DIR="protection_test/stack_monitoring"
CPU_EXCEPTION_DIR="protection_test/cpu_exception"
MEMORY_PROTECTION_DIR="protection_test/memory_protection"
FORCED_TASK_TERMINATION_DIR="protection_test/forced_task_termination"
OSAP_TERMINATION_RESTART_DIR="protection_test/osap_termination_restart"
ILLEGAL_TERMINATE_DIR="error_test/illegal_terminate"
BOOT_ONLY_MASTER_CORE_DIR="atypical_syssrv_test/boot_only_master_core"
IOC_TEST_DIR="ioc_test"
ICISR_SYSSRV_TEST_DIR="icisr_test/syssrv_test"
ICISR_ATYPICAL_SYSSRV_TEST_DIR="icisr_test/atypical_syssrv_test"
ICISR_STACK_MONITORING_TEST_DIR="icisr_test/stack_monitoring"
PROTECTION_EX_DIR="protection_test/protection_ex"

# AKTGへのパス
g_aktg_bin=`get_realpath ./$AKTG_BIN`

# AKTGオプション指定
AKTG_OPT=`echo "$AKTG_OPT --scalability_class $SCALABILITY_CLASS --core_num $CORE_NUM --use_multi_core $USE_MULTI_CORE \
          --func_interrupt $FUNC_INTERRUPT --out_file_name $APPLI_NAME \
          --func_hardware_counter $FUNC_HARDWARE_COUNTER --func_protection_hook $FUNC_PROTECTION_HOOK"`

# カーネルライブラリを使用する場合，全フックON
if [ $USE_KERNEL_LIB == true ]
then
	AKTG_OPT=`echo "$AKTG_OPT -h"`
fi

# ターゲット依存のconfigure.yamlが存在すれば，AKTG_OPTに指定
if [ -f ./library/target/$TARGET_NAME/configure.yaml ]
then
	configure_path=`get_realpath ./library/target/$TARGET_NAME/configure.yaml`
	AKTG_OPT="-c $configure_path $AKTG_OPT"
fi

#
# ビルド時のコマンド設定
#
g_cmd_depend="depend"
g_cmd_all="all"


# AKTSPメインメニュー
aktsp_main_menu()
{
	g_go_main_flg=0

	# 強制マージフラグ[ターゲット依存部用]
	g_force_merge_flg=0

	check_makefile

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $MAIN_MENU
$DOUBLE_LINE
 1: $SYSSRV_TEST_MENU
 2: $PROTECTION_TEST_MENU
 3: $ERROR_TEST_MENU
 4: $MODISTARC_MENU
 5: $ATYPICAL_SYSSRV_TEST_MENU
 6: $IOC_TEST_MENU
 7: $ICISR_TEST_MENU
 t: $EXPAND_TESRY
 c: $CHECK_LIBRARY_MENU
 f: $FORCED_MERGE_MENU
 k: $KERNEL_LIBRARY_MENU
 q: $EXIT_TOOL
$SINGLE_LINE
EOS
echo -n " $INPUT_NO "
		# キー読み込み
		read key
		echo ""
		# 読み込んだキーによって分岐
		case ${key} in
			1)
			 source ./scripts/syssrv_test.sh
			 ;;
			2)
			 source ./scripts/protection_test.sh
			 ;;
			3)
			 source ./scripts/error_test.sh
			 ;;
			4)
			 source ./scripts/modistarc.sh
			 ;;
			5)
			 source ./scripts/atypical_syssrv_test.sh
			 ;;
			6)
			 source ./scripts/ioc_test.sh
			 ;;
			7)
			 source ./scripts/icisr_test.sh
			 ;;
			t)
			 g_temp_cmy=temp_cmy_all
			 g_cmy_dir="syssrv_test/$LOWER_CASE_SC \
			          modistarc/$LOWER_CASE_SC \
			          protection_test/$LOWER_CASE_SC/stack_monitoring/notmerge_tesry \
			          protection_test/$LOWER_CASE_SC/stack_monitoring/merge_tesry \
			          protection_test/$LOWER_CASE_SC/cpu_exception/notmerge_tesry \
			          protection_test/$LOWER_CASE_SC/cpu_exception/merge_tesry \
			          error_test/$LOWER_CASE_SC/illegal_terminate_task/notmerge_tesry \
			          error_test/$LOWER_CASE_SC/illegal_terminate_c2isr/notmerge_tesry \
			          error_test/$LOWER_CASE_SC/illegal_terminate_hook/notmerge_tesry"
			          if [ "$USE_MULTI_CORE" == "true" ] || [ "$SCALABILITY_CLASS" == "SC3" ]
			          then
			          	g_sc3_cmy_dir=" ioc_test/$LOWER_CASE_SC"
			          	if [ "$USE_MULTI_CORE" == "true" ]
			          	then
			          		g_m_cmy_dir=" atypical_syssrv_test/$LOWER_CASE_SC/boot_only_master_core/error_tesry"
			          		g_sc3_cmy_dir=$g_sc3_cmy_dir$g_m_cmy_dir
			          	fi
			          	g_cmy_dir=$g_cmy_dir$g_sc3_cmy_dir
			          fi
			 g_cvt_tesry_flg=0
			 expand_tesry
			 if [ "$SCALABILITY_CLASS" == "SC3" ]
			 then
			 	g_cmy_dir="protection_test/$LOWER_CASE_SC/forced_task_termination/merge_tesry"
			 	expand_tesry
			 	part=1
			 	while [ $part -le 6 ]
			 	do
			 		g_cmy_dir=protection_test/$LOWER_CASE_SC/memory_protection\_$part/notmerge_tesry
			 		g_cvt_tesry_flg=1
			 		g_tesry_dir=$MEMORY_PROTECTION_DIR\_$part/$NOTMERGE_TESRY_DIR
			 		expand_tesry
			 		part=`expr $part + 1 `
			 	done
			 fi
			 ;;
			c)
			 source ./scripts/check_library.sh
			 ;;
			k)
			 source ./scripts/kernel_lib.sh
			 ;;
			f)
			 if [ "$ENABLE_FORCED_MARGE" != "true" ]
			 then
			 	echo "$FORCED_MERGE_MENU is $NOT_SUPPORT"
			 else
			 	g_force_merge_flg=1
			 	source ./scripts/force_merge.sh
			 	force_merge_main
			 fi
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
	done
	exit 0
}

# 処理開始
source ./scripts/auto_code_common.sh
source ./scripts/single_tesry_common.sh
aktsp_main_menu
