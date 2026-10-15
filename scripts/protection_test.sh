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
# $Id: protection_test.sh 2106 2015-09-14 07:43:54Z aisincom-nishioka $
#

# 保護違反時処理テストメニュー
protection_test_main()
{
	if [ "$USE_KERNEL_LIB" == "true" ]
	then
		g_check_file_name=$KERNEL_LIB/libkernel.a
		check_file
		if [ $? -eq 1 ]
		then
			return
		fi
	fi

	g_tree_level="../../../../"

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $PROTECTION_TEST_MENU
$DOUBLE_LINE
 1: ${ARR_MEMORY_PROTECTION[1]}
 2: ${ARR_MEMORY_PROTECTION[2]}
 3: ${ARR_MEMORY_PROTECTION[3]}
 4: ${ARR_MEMORY_PROTECTION[4]}
 5: ${ARR_MEMORY_PROTECTION[5]}
 6: ${ARR_MEMORY_PROTECTION[6]}
 7: $STACK_MONITORING
 8: $CPU_EXCEPTION
 9: $FORCED_TASK_TERMINATION
10: $OSAP_TERMINATION_RESTART
11: $PROTECTION_EX
 r: $BACK_TO_MAIN_MENU
 q: $EXIT_TOOL
$SINGLE_LINE
EOS
echo -n " $INPUT_NO "
		# キー読み込み
		read key
		# 読み込んだキーによって分岐
		case ${key} in
			1)
			 g_part=1
			 memory_protection
			 ;;
			2)
			 g_part=2
			 memory_protection
			 ;;
			3)
			 g_part=3
			 memory_protection
			 ;;
			4)
			 g_part=4
			 memory_protection
			 ;;
			5)
			 g_part=5
			 memory_protection
			 ;;
			6)
			 g_part=6
			 memory_protection
			 ;;
			7)
			 stack_monitoring
			 ;;
			8)
			 cpu_exception
			 ;;
			9)
			 forced_task_termination
			 ;;
			10)
			 osap_termination_restart
			 ;;
			11)
			 protection_ex
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
		
	done
}

# メモリ保護テストメニュー
memory_protection()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "${ARR_MEMORY_PROTECTION[$g_part]} is $NOT_SUPPORT"
		return
	fi
	# メモリ保護テスト共通変数定義
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT$PROTECTION_TEST_ROOT/$MEMORY_PROTECTION_ROOT\_$g_part
		g_tree_level="../../../../../"
	else
		g_aktg_opt=$AKTG_OPT
		g_root_dir=$PROTECTION_TEST_ROOT/$MEMORY_PROTECTION_ROOT\_$g_part
	fi
	# メモリ保護テストでは全OS機能OFF(SC3ではSTANDARDは不可)
	g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"

	g_test_lib_file_for_mempro="$TEST_LIB_FILE_FOR_MEMPRO"
	g_include_dir_for_mempro=$INCLUDE_DIR_FOR_MEMPRO

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 ${ARR_MEMORY_PROTECTION[$g_part]}
$DOUBLE_LINE
 1: $MERGE_TEST
 2: $NOT_MERGE_TEST
 r: $BACK_TO_MAIN_MENU
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
			 echo "${ARR_MEMORY_PROTECTION[$g_part]} ($MERGE_TEST) is $NOT_SUPPORT"
			 ;;
			2)
			 # メモリ保護テスト(マージ不可能なテスト)共通変数定義
			 g_test_type="${ARR_MEMORY_PROTECTION[$g_part]} ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_MEMORY_PROTECTION_NOT_MRG\_$g_part
			 g_pre_dir_name=$MEMORY_PROTECTION_ROOT
			 g_temp_dir_name=temp_dir_mempro_single\_$g_part
			 g_temp_manifest=temp_mempro_single\_$g_part
			 g_tesry_dir=$MEMORY_PROTECTION_DIR\_$g_part/$NOTMERGE_TESRY_DIR
			 g_cmy_dir=protection_test/$LOWER_CASE_SC/memory_protection\_$g_part/notmerge_tesry
			 g_temp_cmy=g_temp_cmy_mempro_single\_$g_part
			 g_cvt_tesry_flg=1

			 single_tesry_menu
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
	done
}

# スタックモニタリングテストメニュー
stack_monitoring()
{
	# コア間割込み変換モードでは，スタックモニタリングテストは対象外
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		echo "$STACK_MONITORING is $NOT_SUPPORT"
		return
	fi

	# スタックモニタリングテスト共通変数定義
	# (スタックモニタリングテストではスタックモニタリング以外のOS機能OFF)
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true --use_get_serviceid false --use_parameter_access false --return_status STANDARD"`
	else
		# SC3ではSTANDARDは不可
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"`
	fi

	g_root_dir=$PROTECTION_TEST_ROOT/$STACK_MONITORING_ROOT
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $STACK_MONITORING
$DOUBLE_LINE
 1: $MERGE_TEST
 2: $NOT_MERGE_TEST
 r: $BACK_TO_MAIN_MENU
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
			 # SC1では，マージ可能なTESRYデータは無い
			 if [ "$SCALABILITY_CLASS" == "SC1" ]
			 then
			 	echo "$STACK_MONITORING ($MERGE_TEST) is $NOT_SUPPORT"
			 else
			 	# スタックモニタリングテスト(マージ可能なテスト)共通変数定義
			 	g_test_type="$STACK_MONITORING ($MERGE_TEST)"
			 	g_manifest_name=$MNF_STACK_MONITORING_MRG
			 	g_pre_dir_name=$AUTO_CODE_DIR_NAME
			 	g_temp_dir_name=temp_dir_smoni_aut
			 	g_temp_manifest=temp_smoni_aut
			 	g_tesry_dir="$STACK_MONITORING_DIR/$MERGE_TESRY_DIR"
			 	g_cmy_dir="protection_test/$LOWER_CASE_SC/stack_monitoring/merge_tesry"
			 	g_temp_cmy=temp_cmy_smoni_aut

			 	auto_code_menu
			 fi
			 ;;
			2)
			 # スタックモニタリングテスト(マージ不可能なテスト)共通変数定義
			 g_test_type="$STACK_MONITORING ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_STACK_MONITORING_NOT_MRG
			 g_pre_dir_name=$STACK_MONITORING_ROOT
			 g_temp_dir_name=temp_dir_smoni_single
			 g_temp_manifest=temp_smoni_single
			 g_tesry_dir="$STACK_MONITORING_DIR/$NOTMERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/stack_monitoring/notmerge_tesry"
			 g_temp_cmy=temp_cmy_smoni_single

			 single_tesry_menu
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
	done
}

# CPU例外テストメニュー
cpu_exception()
{
	# CPU例外テスト共通変数定義
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$PROTECTION_TEST_ROOT/$CPU_EXCEPTION_ROOT
		g_tree_level="../../../../../"
	else
		g_aktg_opt=$AKTG_OPT
		g_root_dir=$PROTECTION_TEST_ROOT/$CPU_EXCEPTION_ROOT
	fi
	# CPU例外テストでは全OS機能OFF
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status STANDARD"
	else
		# SC3ではSTANDARDは不可
		g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"
	fi

	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $CPU_EXCEPTION
$DOUBLE_LINE
 1: $MERGE_TEST
 2: $NOT_MERGE_TEST
 r: $BACK_TO_MAIN_MENU
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
			 # CPU例外テスト(マージ可能なテスト)共通変数定義
			 g_test_type="$CPU_EXCEPTION ($MERGE_TEST)"
			 g_manifest_name=$MNF_CPU_EXCEPTION_MRG
			 g_pre_dir_name=$AUTO_CODE_DIR_NAME
			 g_temp_dir_name=temp_dir_cpuexc_aut
			 g_temp_manifest=temp_cpuexc_aut
			 g_tesry_dir="$CPU_EXCEPTION_DIR/$MERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/cpu_exception/merge_tesry"
			 g_temp_cmy=temp_cmy_cpuexc_aut

			 auto_code_menu
			 ;;
			2)
			 # CPU例外テスト(マージ不可能なテスト)共通変数定義
			 g_test_type="$CPU_EXCEPTION ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_CPU_EXCEPTION_NOT_MRG
			 g_pre_dir_name=$CPU_EXCEPTION_ROOT
			 g_temp_dir_name=temp_dir_cpuexc_single
			 g_temp_manifest=temp_cpuexc_single
			 g_tesry_dir="$CPU_EXCEPTION_DIR/$NOTMERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/cpu_exception/notmerge_tesry"
			 g_temp_cmy=temp_cmy_cpuexc_single

			 single_tesry_menu
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
	done
}

# タスク強制終了テスト
forced_task_termination()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "$FORCED_TASK_TERMINATION is $NOT_SUPPORT"
		return
	fi
	# コア間割込み変換モードでは，タスク強制終了テストは対象外
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		echo "$STACK_MONITORING is $NOT_SUPPORT"
		return
	fi

	# タスク強制終了テスト
	# (タスク強制終了テストではスタックモニタリング以外のOS機能OFF(SC3ではSTANDARDは不可))
	g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"`
	g_root_dir=$PROTECTION_TEST_ROOT/$FORCED_TASK_TERMINATION_ROOT
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0
	
	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $FORCED_TASK_TERMINATION
$DOUBLE_LINE
 1: $MERGE_TEST
 2: $NOT_MERGE_TEST
 r: $BACK_TO_MAIN_MENU
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
			 # タスク強制終了テスト(マージ可能なテスト)共通変数定義
			 g_test_type="$FORCED_TASK_TERMINATION ($MERGE_TEST)"
			 g_manifest_name=$MNF_FORCED_TASK_TERMINATION_MRG
			 g_pre_dir_name=$AUTO_CODE_DIR_NAME
			 g_temp_dir_name=temp_dir_ftask_aut
			 g_temp_manifest=temp_ftask_aut
			 g_tesry_dir="$FORCED_TASK_TERMINATION_DIR/$MERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/forced_task_termination/merge_tesry"
			 g_temp_cmy=temp_cmy_ftask_aut

			 auto_code_menu
			 ;;
			2)
			 # タスク強制終了テスト(マージ不可能なテスト)共通変数定義
			 g_test_type="$FORCED_TASK_TERMINATION ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_FORCED_TASK_TERMINATION_NOT_MRG
			 g_pre_dir_name=$FORCED_TASK_TERMINATION_ROOT
			 g_temp_dir_name=temp_dir_ftask_single
			 g_temp_manifest=temp_ftask_single
			 g_tesry_dir="$FORCED_TASK_TERMINATION_DIR/$NOTMERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/forced_task_termination/notmerge_tesry"
			 g_temp_cmy=temp_cmy_ftask_single

			 single_tesry_menu
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
	done
}

# OSAP終了/再起動テスト
osap_termination_restart()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "$FORCED_TASK_TERMINATION is $NOT_SUPPORT"
		return
	fi

	# OSAP終了/再起動テスト共通変数定義
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$PROTECTION_TEST_ROOT/$OSAP_TERMINATION_RESTART_ROOT
		g_tree_level="../../../../../"
	else
		g_aktg_opt=$AKTG_OPT
		g_root_dir=$PROTECTION_TEST_ROOT/$OSAP_TERMINATION_RESTART_ROOT
	fi

	# OSAP終了/再起動テストでは全OS機能OFF
	# SC3ではSTANDARDは不可
	g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"

	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $OSAP_TERMINATION_RESTART
$DOUBLE_LINE
 1: $MERGE_TEST
 2: $NOT_MERGE_TEST
 r: $BACK_TO_MAIN_MENU
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
			 echo "$OSAP_TERMINATION_RESTART ($MERGE_TEST) is $NOT_SUPPORT"
			 ;;
			2)
			 # OSAP終了/再起動テスト(マージ不可能なテスト)共通変数定義
			 g_test_type="$OSAP_TERMINATION_RESTART ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_OSAP_TERMINATION_RESTART_NOT_MRG
			 g_pre_dir_name=$OSAP_TERMINATION_RESTART_ROOT
			 g_temp_dir_name=temp_dir_osaptr_single
			 g_temp_manifest=temp_osaptr_single
			 g_tesry_dir="$OSAP_TERMINATION_RESTART_DIR/$NOTMERGE_TESRY_DIR"
			 g_cmy_dir="protection_test/$LOWER_CASE_SC/osap_termination_restart/notmerge_tesry"
			 g_temp_cmy=temp_cmy_osaptr_single

			 single_tesry_menu
			 ;;
			r)
			 g_go_main_flg=1
			 ;;
			q)
			 exit 0
			 ;;
			*)
			 echo " $key $ERR_INVALID_NO"
			 ;;
		esac
		if [ $g_go_main_flg -eq 1 ]
		then
			g_go_main_flg=0
			aktsp_main_menu
		fi
	done
}

# Protection Ex テスト
protection_ex()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "$PROTECTION_EX is $NOT_SUPPORT"
		return
	fi
	# コア間割込み変換モードでは，タスク強制終了テストは対象外
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		echo "$PROTECTION_EX is $NOT_SUPPORT"
		return
	fi

	# Protection Ex テスト
	g_aktg_opt=$AKTG_OPT
	g_root_dir=$PROTECTION_TEST_ROOT/$PROTECTION_EX_ROOT
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0
	
	# タスク強制終了テスト(マージ可能なテスト)共通変数定義
	g_test_type="$PROTECTION_EX"
	g_manifest_name=$MNF_PROTECTION_EX_NOT_MRG
	g_pre_dir_name=$AUTO_CODE_DIR_NAME
	g_temp_dir_name=temp_dir_cpu_ex
	g_temp_manifest=temp_cpu_ex
	g_tesry_dir="$PROTECTION_EX_DIR/$TESRY_ROOT"
	g_cmy_dir="protection_test/$LOWER_CASE_SC/protection_ex/tesry"
	g_temp_cmy=temp_cmy_ftask_aut

	single_tesry_menu
}

# 処理開始
protection_test_main
