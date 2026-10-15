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
# $Id: common.sh 2106 2015-09-14 07:43:54Z aisincom-nishioka $
#

##### AKTSP用変数定義 #####

# グローバル変数(マルチスレッド時も初期化が必要なもの)
g_isisr_cnvert_flg=0

# ファイル名/フォルダ名
MNF_SYSSRV_TESRY="MANIFEST_AUTO_CODE"
MNF_MODISTARC="MANIFEST_MODISTARC"
MNF_STACK_MONITORING_MRG="MANIFEST_STACK_MONITORING_MRG"
MNF_STACK_MONITORING_NOT_MRG="MANIFEST_STACK_MONITORING_NOT_MRG"
MNF_CPU_EXCEPTION_MRG="MANIFEST_CPU_EXCEPTION_MRG"
MNF_CPU_EXCEPTION_NOT_MRG="MANIFEST_CPU_EXCEPTION_NOT_MRG"
MNF_MEMORY_PROTECTION_NOT_MRG="MANIFEST_MEMORY_PROTECTION_NOT_MRG"
MNF_FORCED_TASK_TERMINATION_MRG="MANIFEST_FORCED_TASK_TERMINATION_MRG"
MNF_FORCED_TASK_TERMINATION_NOT_MRG="MANIFEST_FORCED_TASK_TERMINATION_NOT_MRG"
MNF_OSAP_TERMINATION_RESTART_NOT_MRG="MANIFEST_OSAP_TERMINATION_RESTART_NOT_MRG"
MNF_PROTECTION_EX_NOT_MRG="MANIFEST_PROTECTION_EX_NOT_MRG"

MNF_ILLEGAL_TERMINATE[1]="MANIFEST_ILLEGAL_TERMINATE_TASK_NOT_MRG"
MNF_ILLEGAL_TERMINATE[2]="MANIFEST_ILLEGAL_TERMINATE_C2ISR_NOT_MRG"
MNF_ILLEGAL_TERMINATE[3]="MANIFEST_ILLEGAL_TERMINATE_HOOK_NOT_MRG"
MNF_BOOT_ONLY_MASTER_CORE="MANIFEST_BOOT_ONLY_MASTER_CORE"
MNF_IOC_TEST="MANIFEST_IOC"
MNF_ICISR_SYSSRV_TESRY="MANIFEST_ICISR_AUTO_CODE"
MNF_ICISR_ATYPICAL_SYSSRV_TESRY="MANIFEST_ICISR_ATYPICAL_SYSSRV"
MNF_ICISR_STACK_MONITORING_MRG="MANIFEST_ICISR_STACK_MONITORING_MRG"
MNF_ICISR_STACK_MONITORING_NOT_MRG="MANIFEST_ICISR_STACK_MONITORING_NOT_MRG"
KERNEL_LIB="kernel_lib"
OBJECT_DIR="obj"
SYSSRV_TEST_ROOT="syssrv_test"
MODISTARC_ROOT="modistarc"
PROTECTION_TEST_ROOT="protection_test"
STACK_MONITORING_ROOT="stack_monitoring"
CPU_EXCEPTION_ROOT="cpu_exception"
MEMORY_PROTECTION_ROOT="mem_protect"
FORCED_TASK_TERMINATION_ROOT="forced_task_termination"
PROTECTION_EX_ROOT="protection_ex"
OSAP_TERMINATION_RESTART_ROOT="osap_termination_restart"
ERROR_TEST_ROOT="error_test"
ILLEGAL_TERMINATE_ROOT="illegal_terminate"
ATYPICAL_SYSSRV_TEST_ROOT="atypical_syssrv_test"
BOOT_ONLY_MASTER_CORE_ROOT="boot_only_master_core"
IOC_TEST_ROOT="ioc_test"
ICISR_TEST_ROOT="icisr_test"
ICISR_CONVERT_TEST_ROOT="icisr_convert_test"
TESRY_ROOT="tesry"
MERGE_TESRY_DIR="merge_tesry"
NOTMERGE_TESRY_DIR="notmerge_tesry"
AUTO_CODE_DIR_NAME="auto_code"
CHECK_LIBRARY_ROOT="check_library"
INTERRUPT_DIR_NAME="interrupt"
PROTECTIONHOOK_DIR_NAME="protection_hook"
FORCE_MERGE_DIVNUM="force_merge_divnum.dat"

# メニュー画面
DOUBLE_LINE=======================================================================
SINGLE_LINE=----------------------------------------------------------------------

MAIN_MENU="AKTSP main menu"
BACK_TO_MAIN_MENU="Return to main menu"
EXIT_TOOL="Quit"
INPUT_NO="Please input menu no:"
INPUT_DIV_NUM="Please input divide number:"
INPUT_YAML="Please input specified TESRY (absolute path or relative path from aktsp / file or folder):"
INPUT_SPEC_DIR="Please input folder number: auto_code_"
INPUT_THREAD_NUM="Please input thread number:"

GENE_ALL_MNF="Generate a MANIFEST file for All TESRYs"
GENE_DIV_MNF="Generate a MANIFEST file divided by specified number"
GENE_MNF="Generate a MANIFEST file"
MANI_ALL=syssrv_all
MANI_DIV=syssrv_div

MNF_MAKE_DIR="Make MANIFEST folders"
EXEC_AKTG="Execute AKTG"
MNF_MAKE_DEPEND="\"make depend\" for each MANIFEST folders"
MNF_MAKE_BUILD="\"make\" for each MANIFEST folders"
MNF_MAKE_CLEAN="\"make clean\" for each MANIFEST folders"
MNF_MAKE_REALCLEAN="\"make realclean\" for each MANIFEST folders"

# オートコードテスト
EXEC_4_7="Build all program files (No.4-7)"
EXEC_2_4="Build a program file (No.2-4)"
OPERATE_SPEC_DIR="Operate a specified MANIFEST folder"
SPCDIR_MAKE_DEPEND="\"make depend\""
SPCDIR_MAKE_BUILD="\"make\""
SPCDIR_MAKE_CLEAN="\"make clean\""
SPCDIR_MAKE_REALCLEAN="\"make realclean\""
MULTI_THREAD_EXEC_4_7="Build all program files (No.4-7) in multi thread"

# システムサービステスト
SYSSRV_TEST_MENU="System Service Tests"

RUN_EXEC_MODULE="Run executable module (Target Dependent)"

# MODISTARC
MODISTARC_MENU="MODISTARC"
INPUT_DIR="Please input specified folder:"

# マージ不可能なテスト
EXEC_3_6="Build all program files (No.3-6)"
MULTI_THREAD_EXEC_3_6="Build all program files (No.3-6) in multi thread"
PARALLEL_BUILD_AND_RUN="Build all (m) and Run (e) in parallel"

# 保護違反時処理テスト
PROTECTION_TEST_MENU="Protection Tests"
STACK_MONITORING="Stack Monitering Tests"
CPU_EXCEPTION="CPU Exception Tests"
FORCED_TASK_TERMINATION="Forced Task Termination Tests"
PROTECTION_EX="Protection Ex Tests"
OSAP_TERMINATION_RESTART="Osap Termination and Restart Tests"
ARR_MEMORY_PROTECTION[1]="Memory Protection Tests (Part 1)"
ARR_MEMORY_PROTECTION[2]="Memory Protection Tests (Part 2)"
ARR_MEMORY_PROTECTION[3]="Memory Protection Tests (Part 3)"
ARR_MEMORY_PROTECTION[4]="Memory Protection Tests (Part 4)"
ARR_MEMORY_PROTECTION[5]="Memory Protection Tests (Part 5)"
ARR_MEMORY_PROTECTION[6]="Memory Protection Tests (Part 6)"
CONVERT_MEM_ACC_PTN="Convert memory access pattern"
MERGE_TEST="Test that can be merged"
NOT_MERGE_TEST="Test that can NOT be merged"

# エラー処理テスト
ERROR_TEST_MENU="Error Tests"
ILLEGAL_TERMINATE="Illegal Terminate Tests"
ILLEGAL_TERMINATE_TASK="Illegal Terminate Task Tests"
ILLEGAL_TERMINATE_C2ISR="Illegal Terminate C2ISR Tests"
ILLEGAL_TERMINATE_HOOK="Illegal Terminate Hook Tests"
ARR_ILLEGAL_TERMINATE[1]="Illegal Terminate Task Tests"
ARR_ILLEGAL_TERMINATE[2]="Illegal Terminate C2ISR Tests"
ARR_ILLEGAL_TERMINATE[3]="Illegal Terminate Hook Tests"

# 特殊なシステムサービステスト
ATYPICAL_SYSSRV_TEST_MENU="Atypical System Service Tests"
BOOT_ONLY_MASTER_CORE="Boot Only MasterCore Tests"

# IOCテスト
IOC_TEST_MENU="Ioc Tests"

# コア間割込みテスト
ICISR_TEST_MENU="IcIsr Tests"
ICISR_CONVERT_TEST_MENU="IcIsr Convert Tests"
ICISR_CONVERT_SELECT_PRI="IcIsr Convert Tests Select Priority"
ARR_ISR_PRIORITY[1]="INT_PRI_TOP"
ARR_ISR_PRIORITY[2]="INT_PRI_HIGH"
ARR_ISR_PRIORITY[3]="INT_PRI_MID"
ARR_ISR_PRIORITY[4]="INT_PRI_LOW"
ARR_ISR_PRIORITY[5]="INT_PRI_BOTTOM"

# 強制マージ
FORCED_MERGE_MENU="Forced Merge Tests"
FORCED_MERGE_TEST="Forced Merge Test"

# TESRYデータ生成
EXPAND_TESRY="Expand cmy file to all TESRYs"
EXPAND_TESRY_EACH="Expand cmy file to TESRYs"

# チェックライブラリ
CHECK_LIBRARY_MENU="Check the Functions for Target Dependent"
CHECK_ALL_FUNC_2_4="Check all function (No.2-4)"
CHECK_ALL_FUNC="Check all function"
CHECK_PHK="Check protection hook"
CHECK_INT="Check interrupt"

CHECK_ALL_FUNC_ALL_BUILD="Build the all function (No.2-4)"
CHECK_ALL_FUNC_MKDIR="Make folders for each function"
CHECK_ALL_FUNC_DEPEND="\"make depend\" for each function folders"
CHECK_ALL_FUNC_BUILD="\"make\" for each function folders"
CHECK_ALL_FUNC_CLEAN="\"make clean\" for each function folders"
CHECK_ALL_FUNC_REALCLEAN="\"make realclean\" for each function folders"
CHECK_INT_ALL_BUILD="Build the interrupt (No.2-4)"
CHECK_INT_MKDIR="Make $INTERRUPT_DIR_NAME folder"
CHECK_INT_DEPEND="\"make depend\" for $INTERRUPT_DIR_NAME folder"
CHECK_INT_BUILD="\"make\" for $INTERRUPT_DIR_NAME folder"
CHECK_INT_CLEAN="\"make clean\" for $INTERRUPT_DIR_NAME folder"
CHECK_INT_REALCLEAN="\"make realclean\" for $INTERRUPT_DIR_NAME folder"
CHECK_PHK_ALL_BUILD="Build the protection hook (No.2-4)"
CHECK_PHK_MKDIR="Make $PROTECTIONHOOK_DIR_NAME folder"
CHECK_PHK_DEPEND="\"make depend\" for $PROTECTIONHOOK_DIR_NAME folder"
CHECK_PHK_BUILD="\"make\" for $PROTECTIONHOOK_DIR_NAME folder"
CHECK_PHK_CLEAN="\"make clean\" for $PROTECTIONHOOK_DIR_NAME folder"
CHECK_PHK_REALCLEAN="\"make realclean\" for $PROTECTIONHOOK_DIR_NAME folder"

# カーネルライブラリ
KERNEL_LIBRARY_MENU="Kernel Library"

L_ALL="Build the kernel library (No.2-4)"
L_MKDIR="Make kernel library folder"
L_DEPEND="\"make depend\" for $KERNEL_LIB folder"
L_BUILD="\"make\" for $KERNEL_LIB folder"
L_CLEAN="\"make clean\" for $KERNEL_LIB folder"
L_REALCLEAN="\"make realclean\" for $KERNEL_LIB folder"

# 処理実行時のメッセージ
GENERATE=Generate
PRE_MAKE_DIRECTORY=make
POST_MAKE_DIRECTORY=folder
AKTG_IN="Execute AKTG in"
MAKE_DEPEND="make depend in"
MAKE_BUILD="make in"
MAKE_CLEAN="make clean in"
MAKE_REALCLEAN="make realclean in"
RUN_EXEC="Run executable module in"
TEST_OK=": Test OK"
TEST_NG=": Test Error!! -> Check"
TEST_RESULT="Test result"
EACH_TEST_RESULT="Each test result"
NUM_OF_TEST="Test folder number"
NUM_OF_OK="Test OK"
NUM_OF_ALL_PASS="\"All check points passed\" number"
NOT_SUPPORT="Not supported"

WAITING="waiting..."
EXECUTE="execute: "
WAIT_LAST_BUILD="waiting for last build..."
WAIT_LAST_EXEC="waiting for last execution..."
CHECK_LOG_SIZE1="checking log size1:"
CHECK_LOG_SIZE2="checking log size2:"
NOT_FOUND="not found:"
FOUND="found    :"
CHECK_EXEC_LOG="checking execution logs..."

DUMMY_LOG="Because there was no TESRY to be converted, added the results of the dummy.\nAll check points passed.\n\n\n\n\n\n"

# エラーメッセージ
ERR_NOT_MATCH="version is not match (please update aktb.sh and configure.sh)"
ERR_FILE_OR_DIVNUM_INVALID="temp manifest or divide number is invalid"
ERR_SC_INVALID="SCALABILITY_CLASS is invalid"
ERR_USE_KER_LIB_INVALID="USE_KERNEL_LIB is invalid"
ERR_INVALID_NO="is invalid input"
ERR_NO_FILE="file is not exist"
ERR_NO_DIR="folder is not exist"
ERR_EMP_FILE="file is empty"
ERR_AKTG_FAIL="something happened on AKTG in"
ERR_DEPEND_FAIL="make depend failed in"
ERR_CREAT_MAKEFILE_FAIL="Create Makefile failed"
ERR_PATH_FAIL="specified TESRY's path is wrong"
ERR_FATAL="AKTB: Fatal Error!!"

# その他定数
RULE_DEPEND=depend
RULE_BUILD=build
RULE_CLEAN=clean
RULE_REALCLEAM=realclean
APPLI_NAME_FOR_SCR=out
NIOS2_DEV=nios2_dev_gcc

RESULT_AKTG=result_aktg.log
RESULT_MAKE_DEPEND=result_make_depend.log
RESULT_MAKE=result_make.log
RESULT_EXECUTE=result_execute.log
RESULT_EXECUTE_MC=result_execute_core
RESULT_ERROR_TEST=result_error_test.log
EXEC_SUCCESS_MSG="All check points passed."
FINISH_MAKE_FLG="finish_make"

# realpathコマンドの有無を取得
which realpath &> /dev/null
if [ $? == 0 ]
then
	IS_REALPATH=true
else
	IS_REALPATH=false
fi

##### 関数 #####

# 実行時のヘッダー出力(二重線)
# 引数 $1 : ヘッダーに表示する処理の内容
header_double()
{
	echo ""
	echo $DOUBLE_LINE
	echo $1
	echo $DOUBLE_LINE
}

# 実行時のヘッダー出力(単線)
# 引数 $1 : ヘッダーに表示する処理の内容
header_single()
{
	echo ""
	echo $SINGLE_LINE
	echo $1
	echo $SINGLE_LINE
}

# ファイル存在チェック
# 返り値 0 : チェック対象ファイルが存在する
#        1 : チェック対象ファイルが存在しない
check_file()
{
	chk_flg=0

	for file_path in ${g_check_file_name[@]}
	do
		if [ ! -f $file_path ]
		then
			# 未実行と判断されないために改行を入れる
			echo -e "${file_path##*/} $ERR_NO_FILE\n\n\n\n\n\n"
			chk_flg=1
		fi
	done
	return $chk_flg
}

# フォルダ存在チェック
# 返り値 0 : チェック対象フォルダが存在する
#        1 : チェック対象フォルダが存在しない
check_dir()
{
	chk_flg=0
	for dir_path in ${g_check_dir_name[@]}
	do
		dir_path=`echo $dir_path | sed -e "s/\/$//"`
		if [ ! -d $dir_path ]
		then
			echo "${dir_path##*/} $ERR_NO_DIR"
			chk_flg=1
		fi
	done
	return $chk_flg
}

# ファイルが空ファイルかをチェック
# 返り値 0 : チェック対象ファイルが空でない
#        1 : チェック対象ファイルが空である
check_empty_file()
{
	chk_flg=0
	all_step=0

	all_step=`cat $g_check_file_name | wc -l`
	if [ $all_step == 0 ]
	then
		echo "${g_check_file_name##*/} $ERR_EMP_FILE"
		chk_flg=1
	fi
	return $chk_flg
}

# ファイル最終行の改行有無チェック
# 最終行が改行のみでなければ，改行を挿入
check_last_break()
{
	all_step=0

	last1=`cat $g_check_file_name | tail -1`
	all_step=`wc -l $g_check_file_name | awk -F ' ' '{print $1}'`
	last2=`sed -n "$all_step"p $g_check_file_name`
	if [ ! "$last1" == "$last2" ]
	then
		echo "" >> $g_check_file_name
	fi

	last1=`cat $g_check_file_name | tail -1`
	if [ ! "$last1" == "" ]
	then
		echo "" >> $g_check_file_name
	fi
}

# aktsp_target.shで設定するmakeオプション(MAKE_OPT)で"-f"が指定されてい
# るかのチェック
# 指定されていれば、MAKEFILE変数として定義
check_makefile()
{
	makeopt=($MAKE_OPT)

    num=0
	while [ "${makeopt[$num]}" != "" ]
	do
		if [ "${makeopt[num]}" == "-f" ]
		then
			MAKE_FILE_NAME=${makeopt[num+1]}
			num=`expr $num + 2`
			return
		else
			num=`expr $num + 1`
		fi
	done
	MAKE_FILE_NAME="Makefile"
}

# マニフェストファイル内の#でコメントアウトしたテストケースを除外
# 除外した後のテストケース一覧は，配列として変数g_test_case_listに格納
exclusion_comment_out()
{
	g_test_case_list=`grep -v "^#.*" $g_check_file_name | xargs`
}

# 絶対パス取得(realpathが使用できないOSの対応)
get_realpath()
{
	if [ $IS_REALPATH == "true" ]
	then
		rpath=`realpath $1`
		echo $rpath
	else
		echo "$PWD/$1"
	fi
}

# スクラッチプログラムのファイル名をAPPLI_NAMEに変更
rename_scratch_program()
{
	if [ "$APPLI_NAME_FOR_SCR" != "$APPLI_NAME" ]
	then
		flg=`find ./ -name "$APPLI_NAME.*"`
		if [ ! "$flg" ]
		then
			mv $APPLI_NAME_FOR_SCR.c $APPLI_NAME.c
			mv $APPLI_NAME_FOR_SCR.h $APPLI_NAME.h
			mv $APPLI_NAME_FOR_SCR.arxml $APPLI_NAME.arxml
			sed -i -e "s/#include\ \"$APPLI_NAME_FOR_SCR.h\"/#include\ \"$APPLI_NAME.h\"/" ./$APPLI_NAME.*
		fi
	fi
}

# configure実行
execution_configure()
{
	# カーネルライブラリ使用有無
	if [ $USE_KERNEL_LIB == true ]
	then
		CONFIG_KERNEL_LIB_OPT="-L ${g_tree_level}${KERNEL_LIB}"
	elif [ $USE_KERNEL_LIB == false ]
	then
		CONFIG_KERNEL_LIB_OPT=
	else
		echo "$ERR_USE_KER_LIB_INVALID ($USE_KERNEL_LIB)"
		exit 1
	fi

	# includeディレクトリパス作成
	TEST_LIB_FILE="aktsp_common_lib.o aktsp_implement_lib.o aktsp_target_lib.o"
	INCLUDE_DIR="${g_tree_level}library/common ${g_tree_level}library/implement/${IMPLEMENT_NAME} ${g_tree_level}library/target/${TARGET_NAME}"
	ARCH_DIR="${g_tree_level}library/arch"
	for dir in ${ARCH_PATH[@]}
	do
		INCLUDE_DIR=`echo "$INCLUDE_DIR $ARCH_DIR/$dir"`
	done

	num=${#CONFIG_OPT_O[*]}
	O_OPTION=

	if [ $num != 0 ]
	then
		O_OPTION="-o"
		for opt_o in ${CONFIG_OPT_O[@]}
		do
			O_OPTION=`echo "$O_OPTION $opt_o"`
		done
	fi
	perl ${g_tree_level}${OS_PATH}/configure -h -T $TARGET_NAME -A $APPLI_NAME -C "$APPLI_NAME aktsp_implementation_data_types" $CONFIG_KERNEL_LIB_OPT -U "$TEST_LIB_FILE $g_test_lib_file_for_mempro" $CONFIG_OPT -a "$INCLUDE_DIR $g_tree_level$g_include_dir_for_mempro" "$O_OPTION" &> /dev/null
}

# メモリ保護テストのシェルスクリプトを用いたTESRYデータのメモリアクセス
# パターン拡張
convert_memory_access_pattern()
{
	cd $OBJECT_DIR/$TESRY_ROOT/$g_tesry_dir
	loop_dir=`ls | sed -e "s/\///g"`
	for dir in ${loop_dir[@]}
	do
		if [ -d $dir ]
		then
			header_single "$CONVERT_MEM_ACC_PTN in $OBJECT_DIR/$TESRY_ROOT/$g_tesry_dir/$dir"
			cd $dir
			ruby $AKTSP_DIR/scripts/convert_memory_protection_tesry.rb $AKTSP_DIR/library/target/$TARGET_NAME/memory_protection/memcvt.yaml
			cd ../
		fi
	done
	cd $AKTSP_DIR
}

# cmyファイルを1件毎のTESRYデータに分割
expand_tesry()
{
	mkdir -p $OBJECT_DIR/$TESRY_ROOT
	cd $OBJECT_DIR/$TESRY_ROOT

	for dir in ${g_cmy_dir[@]}
	do
		if [ -d $AKTSP_DIR/$dir ]
		then
			echo $dir
			find $AKTSP_DIR/$dir/ -name "*.cmy" > $g_temp_cmy
		fi

		if [ "$USE_MULTI_CORE" == "true" ]
		then
			mc=`echo $dir | sed -e "s/$LOWER_CASE_SC/$LOWER_CASE_SC"-mc"/g"`
			echo $mc
			if [ -d $AKTSP_DIR/$mc ]
			then
				find $AKTSP_DIR/$mc/ -name "*.cmy" >> $g_temp_cmy
			fi
		fi

		root=`echo $dir | sed -e "s/\/$LOWER_CASE_SC//g"`
		rm -rf $root
		mkdir -p $root
		cd $root
		header_single "$EXPAND_TESRY_EACH in $OBJECT_DIR/$TESRY_ROOT/$root"

		while read cmy_path
		do
			cmy_name=${cmy_path##*/}
			g_dir_name=`echo $cmy_name | sed -e "s/\.cmy//g"`
			mkdir -p $g_dir_name
			cd $g_dir_name
			echo $cmy_name
			ruby $AKTSP_DIR/tools/akc2y/akc2y.rb -d $cmy_path &> /dev/null
			cd ../
		done < $AKTSP_DIR/$OBJECT_DIR/$TESRY_ROOT/$g_temp_cmy
		cd $AKTSP_DIR/$OBJECT_DIR/$TESRY_ROOT
	done
	rm -f $g_temp_cmy
	cd $AKTSP_DIR

	# メモリ保護テストの場合，シェルスクリプトを用いてTESRYデータを拡張
	if [ $g_cvt_tesry_flg -eq 1 ]
	then
		convert_memory_access_pattern
	fi
}

# TESRYを用いたテストのマニフェスト作成
make_manifest_for_tesry()
{
	# cmyファイル展開前に，分割数を読み込む
	if [ "$g_mani_type" == "$MANI_DIV" ]
	then
		# configure.shでDIV_NUMの指定がある場合のチェック
		# 数字以外の文字列，異常値のチェック
		err_div_num=`echo -n $DIV_NUM | sed 's/[0-9]//g' `
		if [ ! $err_div_num ] && [ $DIV_NUM ] && [ $DIV_NUM -gt 0 ]
		then
			div_num=$DIV_NUM
		# configure.shでDIV_NUMの指定がない，もしくはDIV_NUMがエラーの
		# 場合のチェック
		else
			div_num=0
			while [ $div_num -lt 1 ]
			do
				echo -n "$INPUT_DIV_NUM "
				read div_num
				err_div_num=`echo -n $div_num | sed 's/[0-9]//g' `
				# 数字以外の文字列，異常値のチェック
				if [ "$div_num" == "" ] || [ $err_div_num ] || [ $div_num -lt 1 ]
				then
					echo "$div_num $ERR_INVALID_NO"
					return
				fi
			done
		fi
	fi

	# TESRYデータをcmyから展開
	expand_tesry

	#マニフェストファイル作成
	header_single "$GENE_MNF"

	mkdir -p $OBJECT_DIR/$g_root_dir
	cd $OBJECT_DIR/$g_root_dir
	rm -f $g_temp_manifest
	rm -f $g_manifest_name

	g_check_dir_name=$AKTSP_DIR/$OBJECT_DIR/$TESRY_ROOT/$g_tesry_dir
	check_dir
	if [ $? -eq 0 ]
	then
		find $AKTSP_DIR/$OBJECT_DIR/$TESRY_ROOT/$g_tesry_dir/ -name "*.yaml" | sort >> $g_temp_manifest

		sed -i -e "/\/\.svn/d" $g_temp_manifest # omit svnファイル
		case $g_mani_type in
			$MANI_ALL)
			 cat $g_temp_manifest | tee $g_manifest_name
			 ;;
			$MANI_DIV)
			 if [ "$AVERAGE_MANIFEST" == "true" ]
			 then
			 	ruby $AKTSP_DIR/scripts/average_manifest.rb $g_temp_manifest $div_num > .tmp
			 	if [ $? -ne 0 ]
			 	then
			 		echo "$ERR_FILE_OR_DIVNUM_INVALID"
			 		cd $AKTSP_DIR
			 		return
			 	fi
			 	mv -f .tmp $g_temp_manifest
			 fi

			 all_step=`cat $g_temp_manifest | wc -l`
			 each_step=`expr $all_step / $div_num`
			 remainder=`expr $all_step % $div_num`

			 loop=`expr $remainder - 1`
			 for pre_loop in `seq 0 1 $loop` # pre_loopを0から1ずつ増やしながら，loopの値になるまでループする
			 do
			 	cat $g_temp_manifest | tail -n `expr $all_step - \( $each_step + 1 \) \* $pre_loop` > .tmp
			 	cat .tmp | head -n `expr $each_step + 1` | tee -a $g_manifest_name
			 	echo ""  | tee -a $g_manifest_name
			 done
			 if [ $remainder -eq 0 ]
			 then
			 	pre_loop=0
			 else
			 	pre_loop=`expr $pre_loop + 1`
			 fi
			 loop=`expr $div_num - $remainder - 1`
			 for post_loop in `seq 0 1 $loop`
			 do
			 	cat $g_temp_manifest | tail -n `expr $all_step - \( $each_step + 1 \) \* $pre_loop - $each_step \* $post_loop` > .tmp
			 	cat .tmp | head -n $each_step | tee -a $g_manifest_name
			 	echo ""  | tee -a $g_manifest_name
			 done
			 rm -f .tmp

			 # YAMLの数が変化していないか念のためチェック
			 check_yaml_num=`grep -v "^$" $g_manifest_name | wc -l`
			 if [ $all_step -ne $check_yaml_num ]
			 then
			 	echo $ERR_FATAL
			 	exit 1
			 fi
			 ;;
		esac
	fi
	rm -f $g_temp_manifest
	cd $AKTSP_DIR
}

# AKTGの実行
# 返り値 status : 0の場合，AKTG成功 / 0以外の場合，AKTG失敗
execute_aktg()
{
	args="$g_aktg_opt $g_test_case_list"
	# 3>&1 1>&2  2>&3 : 標準出力と標準エラー出力を交換
	# プログレスバーとエラー情報の両方を画面出力し，ログファイルにも
	# 出力するため
	( ruby $g_aktg_bin $args 3>&1 1>&2 2>&3; echo $? >status_file ) | tee $RESULT_AKTG
	sed -i -e "s/^.*\r//g" ./$RESULT_AKTG
	status=`cat status_file`
	rm -rf status_file
	if [ $status -ne 0 ]
	then
		touch $FINISH_MAKE_FLG
	fi
	return $status
}

# Makefileを使用する際の必要なファイルを指定
need_file_name()
{
	case $g_rule in
		$RULE_DEPEND)
		 g_check_file_name="$APPLI_NAME.c \
							$APPLI_NAME.h \
							$APPLI_NAME.arxml \
							$MAKE_FILE_NAME"
		 ;;
		$RULE_BUILD)
		 g_check_file_name="$APPLI_NAME.c \
							$APPLI_NAME.h \
							$APPLI_NAME.arxml \
							$MAKE_FILE_NAME"
		 ;;
		$RULE_CLEAN)
		 g_check_file_name="$MAKE_FILE_NAME"
		 ;;
		$RULE_REALCLEAM)
		 g_check_file_name="$MAKE_FILE_NAME"
		 ;;
	esac
}

# 個別フォルダでのAKTG，make depend，make実行
continuous_execute_in_operate_directory()
{
	check_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_empty_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_last_break

	# AKTG実行
	if [ $g_merge_flg -eq 1 ]
	then
		exclusion_comment_out
	else
		g_test_case_list=`grep $g_dir_name ../$g_manifest_name`
	fi
	header_single "$AKTG_IN $g_dir_name"
	execute_aktg

	# make depend実行
	if [ $? -eq 0 ]
	then
		g_check_file_name=$MAKE_FILE_NAME
		check_file
		if [ $? -eq 1 ]
		then
			return
		fi
		header_single "$MAKE_DEPEND $g_dir_name"
		g_rule=$RULE_DEPEND
		make_for_common

		# make実行
		if [ $? -eq 0 ]
		then
			header_single "$MAKE_BUILD $g_dir_name"
			g_rule=$RULE_BUILD
			make_for_common
		else
			echo "$ERR_DEPEND_FAIL "$g_dir_name
		fi
	else
		echo "$ERR_AKTG_FAIL "$g_dir_name
	fi
}

# 個別フォルダでのAKTG実行
execute_aktg_in_operate_directory()
{
	check_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_empty_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_last_break

	# AKTG実行
	if [ $g_merge_flg -eq 1 ]
	then
		exclusion_comment_out
	else
		g_test_case_list=`grep $g_dir_name ../$g_manifest_name`
	fi
	header_single "$AKTG_IN $g_dir_name"
	execute_aktg
}

# 個別フォルダでのMakefileを用いて行う処理(make depend, make, 
# make clean, make realclean)の実行
make_in_operate_directory()
{
	case $g_rule in
		$RULE_DEPEND)
		 header_single "$MAKE_DEPEND $g_dir_name"
		 ;;
		$RULE_BUILD)
		 header_single "$MAKE_BUILD $g_dir_name"
		 ;;
		$RULE_CLEAN)
		 header_single "$MAKE_CLEAN $g_dir_name"
		 ;;
		$RULE_REALCLEAM)
		 header_single "$MAKE_REALCLEAN $g_dir_name"
		 ;;
	esac
	need_file_name
	check_file
	if [ $? -eq 1 ]
	then
		return
	fi
	make_for_common
}
# Makefileを用いて行う処理(make depend, make, make clean, 
# make realclean)の実行(マニフェストファイルがない場合)
make_for_no_manifest()
{
	g_check_dir_name=$g_dir_name
	check_dir
	if [ $? -eq 0 ]
	then
		cd $g_dir_name
		need_file_name
		check_file
		if [ $? -eq 1 ]
		then
			cd $AKTSP_DIR
			return
		fi
		make_for_common
		cd $AKTSP_DIR
	fi
}

# Makefileを用いて行う処理(make depend, make, make clean, 
# make realclean)の実行
# 返り値 status : 0の場合，make depend成功 / 0以外の場合，make depend失敗
#        ※make depend以外の場合，意味を持たない
make_for_common()
{
	case $g_rule in
		$RULE_DEPEND)
		 ( make $g_cmd_depend $MAKE_OPT 2>&1; echo $? >status_file ) | tee $RESULT_MAKE_DEPEND
		 status=`cat status_file`
		 rm -rf status_file
		 if [ $status -ne 0 ]
		 then
		 	touch $FINISH_MAKE_FLG
		 fi
		 ;;
		$RULE_BUILD)
		 make $g_cmd_all $MAKE_OPT $ONLY_MAKE_OPT 2>&1 | tee $RESULT_MAKE
		 # 不要ファイル削除オプション
		 if [ "$REMOVE_INTERMEDIATE_FILE" == "true" ]
		 then
		 	rm -f *.o *.a rm *.ld *.dump *.map *.syms Os_* cfg* kernel* Makefile.depend offset.h
		 fi
		 touch $FINISH_MAKE_FLG
		 ;;
		$RULE_CLEAN)
		 make clean $MAKE_OPT
		 rm -rf $FINISH_MAKE_FLG
		 ;;
		$RULE_REALCLEAM)
		 make realclean $MAKE_OPT
		 rm -rf $FINISH_MAKE_FLG
		 ;;
	esac
	return $status
}

# TESRYデータのファイルパスから，テスト実行用フォルダのフォルダ名
# (g_dir_name)を作成
get_dir_name()
{
	tesry_name=${g_test_case_list##*/}
	g_dir_name=`echo $tesry_name | sed -e "s/\.yaml//"`
}

check_exec_success()
{
	num=0

	# マスタコアのみ起動するテストは，コア数を1として実行しているため，シングルコアと同じ結果ファイル
	if [ "$USE_MULTI_CORE" == "false" ] || [ "$g_manifest_name" == "$MNF_BOOT_ONLY_MASTER_CORE" ]
	then
		if [ -f $RESULT_EXECUTE ]
		then
			# AKTG実行時にフィルタリングにより，対象フォルダのテストが0件になった場合，ダミーの結果ファイルを作成する
			convert_flg=`ls -l | grep "(0% passed" $RESULT_AKTG | wc -l`
			if [ $convert_flg -ne 0 ]
			then
				echo -e $DUMMY_LOG >> $RESULT_EXECUTE
			fi
			num=`grep --text "$EXEC_SUCCESS_MSG" ./$RESULT_EXECUTE | wc -l `
			g_success_num=`expr $num + $g_success_num`
		else
			g_no_log_num=`expr $g_no_log_num + 1`
		fi
	else
		core0_file="${RESULT_EXECUTE_MC}0.log"
		# AKTG実行時にフィルタリングにより，対象フォルダのテストが0件になった場合，ダミーの結果ファイルを作成する
		if [ ! -f $core0_file ]
		then
			convert_flg=`ls -l | grep "(0% passed" $RESULT_AKTG | wc -l`
			if [ $convert_flg -ne 0 ]
			then
				rm -f $RESULT_EXECUTE
				echo -e $DUMMY_LOG >> $core0_file
			fi
		fi
		if [ -f $core0_file ]
		then
			num=`grep --text "$EXEC_SUCCESS_MSG" ./${RESULT_EXECUTE_MC}*.log | wc -l `
			g_success_num=`expr $num + $g_success_num`
		else
			g_no_log_num=`expr $g_no_log_num + 1`
		fi
	fi
}

check_exec_success_force_merge()
{
	# シングルコアとマルチコアでは，結果ファイル名が異なる
	if [ "$USE_MULTI_CORE" == "false" ]
	then
		if [ -f $RESULT_EXECUTE ]
		then
			( ruby $AKTSP_DIR/scripts/check_exec_success_force_merge.rb MNF_$g_dir_name $RESULT_EXECUTE;  echo $? > status_file ) >> ../$RESULT_ERROR_TEST
			status=`cat status_file`
			rm -rf status_file
			if [ $status -eq 0 ]
			then
				g_success_num=`expr $g_success_num + 1`
			fi
		else
			g_no_log_num=`expr $g_no_log_num + 1`
		fi
	else
		core0_file="${RESULT_EXECUTE_MC}0.log"
		core1_file="${RESULT_EXECUTE_MC}1.log"
		# AKTG実行時にフィルタリングにより，対象フォルダのテストが0件になった場合，ダミーの結果ファイルを作成する
		if [ ! -f $core0_file ]
		then
			convert_flg=`ls -l | grep "(0% passed" $RESULT_AKTG | wc -l`
			if [ $convert_flg -ne 0 ]
			then
				rm -f $RESULT_EXECUTE
				echo -e $DUMMY_LOG >> $core0_file
			fi
		fi
		if [ -f $core0_file ]
		then
			if [ -f $core1_file ]
			then
				# core1_fileがある場合は，core1_fileも実行結果確認用スクリプトへ渡す
				( ruby $AKTSP_DIR/scripts/check_exec_success_force_merge.rb MNF_$g_dir_name $core0_file $core1_file;  echo $? > status_file ) >> ../$RESULT_ERROR_TEST
			else
				( ruby $AKTSP_DIR/scripts/check_exec_success_force_merge.rb MNF_$g_dir_name $core0_file;  echo $? > status_file ) >> ../$RESULT_ERROR_TEST
			fi
			status=`cat status_file`
			rm -rf status_file
			if [ $status -eq 0 ]
			then
				g_success_num=`expr $g_success_num + 1`
			fi
		else
			g_no_log_num=`expr $g_no_log_num + 1`
		fi
	fi
}

# 実行モジュールの実行結果出力
output_log()
{
	if [ $g_no_log_num -ne $g_test_num ]
	then
		header_single "$TEST_RESULT"
		echo "$NUM_OF_TEST: "$g_test_num
		echo "$NUM_OF_OK: "$g_success_num
	fi
}

# 実行モジュールを実行するフォルダへの移動(オートコードテスト用)
execute_module_for_auto_code()
{
	g_test_num=0
	g_success_num=0
	g_no_log_num=0

	g_check_dir_name=$OBJECT_DIR/$g_root_dir
	check_dir
	if [ $? -eq 1 ]
	then
		return
	fi

	cd $OBJECT_DIR/$g_root_dir
	list_num=`ls -l | grep $g_pre_dir_name\_ | wc -l`
	if [ $list_num -eq 0 ]
	then
		echo $g_pre_dir_name'_* '$ERR_NO_DIR
	else
		cnt=0
		while [ $cnt -lt $list_num ]
		do
			g_test_num=`expr $g_test_num + 1`
			cnt=`expr $cnt + 1`
			g_dir_name=$g_pre_dir_name\_$cnt
			if [ ! -d $g_dir_name ]
			then
				continue
			fi
			header_single "$RUN_EXEC $g_dir_name"
			cd $g_dir_name
			rm -rf $RESULT_EXECUTE
			simulation
			check_exec_success
			cd ../
		done
	fi
	all_dir_finish_hook
	cd $AKTSP_DIR

	output_log
}

# 実行モジュールを実行するフォルダへの移動(1件のみで実行可能なTESRYデータ用)
execute_module_for_single_tesry()
{
	g_test_num=0
	g_success_num=0
	g_no_log_num=0

	g_check_file_name=$OBJECT_DIR/$g_root_dir/$g_manifest_name
	check_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_empty_file
	if [ $? -eq 1 ]
	then
		return
	fi
	check_last_break
	exclusion_comment_out

	cd $OBJECT_DIR/$g_root_dir

	g_test_case_list_all=$g_test_case_list
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			g_test_num=`expr $g_test_num + 1`
			get_dir_name

			g_check_dir_name=$g_dir_name
			check_dir
			if [ $? -eq 1 ]
			then
				continue
			fi

			header_single "$RUN_EXEC $g_dir_name"
			cd $g_dir_name
			rm -rf $RESULT_EXECUTE
			simulation
			check_exec_success
			cd ../
		fi
	done
	all_dir_finish_hook
	cd $AKTSP_DIR

	output_log
}

# 実行モジュールを実行するフォルダへの移動(強制マージテスト用)
execute_module_for_force_merge()
{
	g_test_num=0
	g_success_num=0
	g_no_log_num=0

	g_check_dir_name=$OBJECT_DIR/$g_root_dir
	check_dir
	if [ $? -eq 1 ]
	then
		return
	fi

	cd $OBJECT_DIR/$g_root_dir
	dir_list=`ls | grep $g_pre_dir_name\_`
	if [ ! "$dir_list" ]
	then
		echo $g_pre_dir_name'_* '$ERR_NO_DIR
	else
		rm -f $RESULT_ERROR_TEST
		for g_dir_name in ${dir_list[@]}
		do
			g_test_num=`expr $g_test_num + 1`
			if [ ! -d $g_dir_name ]
			then
				continue
			fi
			header_single "$RUN_EXEC $g_dir_name"
			cd $g_dir_name
			rm -rf $RESULT_EXECUTE
			simulation
			check_exec_success_force_merge
			cd ../
		done
		if [ $g_no_log_num -ne $g_test_num ]
		then
			header_single "$EACH_TEST_RESULT"
			cat $RESULT_ERROR_TEST
		fi
	fi
	all_dir_finish_hook
	cd $AKTSP_DIR

	output_log
}

# 実行モジュールを実行するフォルダへの移動
# (マニフェストファイルを用いないテスト用)
execute_module_for_no_manifest()
{
	g_test_num=0
	g_success_num=0
	g_no_log_num=0

	for g_dir_name in ${g_loop_dir_name[@]}
	do
		g_test_num=`expr $g_test_num + 1`
		g_check_dir_name=$OBJECT_DIR/$g_root_dir/$g_dir_name
		check_dir
		if [ $? -eq 1 ]
		then
			return
		fi

		cd $OBJECT_DIR/$g_root_dir/$g_dir_name
		header_single "$RUN_EXEC $g_dir_name"
		rm -rf $RESULT_EXECUTE
		simulation
		check_exec_success
		all_dir_finish_hook
		cd $AKTSP_DIR
	done

	output_log
}

execute_module()
{
	if [ $EXC_MODULE != "true" ]
	then
		echo "$NOT_SUPPORT"
	else
		case $g_kind in
			"$OPERATE_SPEC_DIR")
			 header_single "$RUN_EXEC $g_dir_name"
			 g_success_num=0
			 g_no_log_num=0
			 simulation
			 g_test_num=1
			 check_exec_success
			 output_log
			 ;;
			"$OPERATE_SPEC_DIR_FORCE_MERGE")
			 header_single "$RUN_EXEC $g_dir_name"
			 g_no_log_num=0
			 rm -f ../$RESULT_ERROR_TEST
			 simulation
			 g_test_num=1
			 check_exec_success_force_merge
			 if [ $g_no_log_num -ne $g_test_num ]
			 then
			 	header_single "$TEST_RESULT"
			 	cat ../$RESULT_ERROR_TEST
			 fi
			 ;;
			"$CHECK_ALL_FUNC")
			 g_loop_dir_name="$INTERRUPT_DIR_NAME $PROTECTIONHOOK_DIR_NAME"
			 execute_module_for_no_manifest
			 ;;
			"$CHECK_INT")
			 g_loop_dir_name=$INTERRUPT_DIR_NAME
			 execute_module_for_no_manifest
			 ;;
			"$CHECK_PHK")
			 g_loop_dir_name=$PROTECTIONHOOK_DIR_NAME
			 execute_module_for_no_manifest
			 ;;
		esac
	fi
}

# [オートコード]並列実行用(別シェルから実行する)
if [ "$1" == "PARALLEL_RUN_AUTO_CODE" ]
then
	source ./configure.sh

	# 必要な変数定義
	g_root_dir=$2
	list_num=$3
	g_pre_dir_name=$4
	AKTSP_DIR=$5
	TARGET_NAME=$6
	SCALABILITY_CLASS=$7
	CORE_NUM=$8
	USE_MULTI_CORE=$9

	# aktg.rbを実行できないので，ここでSCを指定
	if [ $SCALABILITY_CLASS == "SC1" ]
	then
		LOWER_CASE_SC="sc1"
	elif [ $SCALABILITY_CLASS == "SC3" || $SCALABILITY_CLASS == "SC4" ]
	then
		LOWER_CASE_SC="sc3"
	fi

	source ./library/target/$TARGET_NAME/aktsp_target.sh

	# モジュール実行
	execute_module_for_auto_code

	exit
fi

# [1件毎]並列実行用(別シェルから実行する)
if [ "$1" == "PARALLEL_RUN_SINGLE" ]
then
	source ./configure.sh

	# 必要な変数定義
	g_root_dir=$2
	g_manifest_name=$3
	g_test_case_list=$4
	g_dir_name=$5
	AKTSP_DIR=$6
	TARGET_NAME=$7
	SCALABILITY_CLASS=$8
	CORE_NUM=$9
	USE_MULTI_CORE=${10}

	# aktg.rbを実行できないので，ここでSCを指定
	if [ $SCALABILITY_CLASS == "SC1" ]
	then
		LOWER_CASE_SC="sc1"
	elif [ $SCALABILITY_CLASS == "SC3" || $SCALABILITY_CLASS == "SC4"]
	then
		LOWER_CASE_SC="sc3"
	fi

	source ./library/target/$TARGET_NAME/aktsp_target.sh

	# モジュール実行
	execute_module_for_single_tesry

	exit
fi

# [強制マージ]並列実行用(別シェルから実行する)
if [ "$1" == "PARALLEL_RUN_FORCE_MERGE" ]
then
	source ./configure.sh

	# 必要な変数定義
	g_root_dir=$2
	g_pre_dir_name=$3
	AKTSP_DIR=$4
	TARGET_NAME=$5
	SCALABILITY_CLASS=$6
	CORE_NUM=$7
	USE_MULTI_CORE=$8
	dir_list=`ls | grep $OBJECT_DIR/$g_root_dir/$g_pre_dir_name\_`

	# aktg.rbを実行できないので，ここでSCを指定
	if [ $SCALABILITY_CLASS == "SC1" ]
	then
		LOWER_CASE_SC="sc1"
	elif [ $SCALABILITY_CLASS == "SC3" || $SCALABILITY_CLASS == "SC4"]
	then
		LOWER_CASE_SC="sc3"
	fi

	source ./library/target/$TARGET_NAME/aktsp_target.sh

	# モジュール実行
	execute_module_for_force_merge

	exit
fi
