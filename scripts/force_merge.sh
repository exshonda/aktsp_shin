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
# $Id: force_merge.sh 2106 2015-09-14 07:43:54Z aisincom-nishioka $
#
##### 強制マージテスト共通処理 #####

# 強制マージテスト用のテスト種別選択メニュー
force_merge_main()
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
 $FORCED_MERGE_MENU
$DOUBLE_LINE
  1: ${ARR_MEMORY_PROTECTION[1]}
  2: ${ARR_MEMORY_PROTECTION[2]}
  3: ${ARR_MEMORY_PROTECTION[3]}
  4: ${ARR_MEMORY_PROTECTION[4]}
  5: ${ARR_MEMORY_PROTECTION[5]}
  6: ${ARR_MEMORY_PROTECTION[6]}
  7: $STACK_MONITORING
  8: $CPU_EXCEPTION
  9: $ILLEGAL_TERMINATE_TASK
 10: $ILLEGAL_TERMINATE_C2ISR
 11: $ILLEGAL_TERMINATE_HOOK
 12: $OSAP_TERMINATION_RESTART
 13: $FORCED_TASK_TERMINATION
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
			 memory_protection_fm
			 ;;
			2)
			 g_part=2
			 memory_protection_fm
			 ;;
			3)
			 g_part=3
			 memory_protection_fm
			 ;;
			4)
			 g_part=4
			 memory_protection_fm
			 ;;
			5)
			 g_part=5
			 memory_protection_fm
			 ;;
			6)
			 g_part=6
			 memory_protection_fm
			 ;;
			7)
			 stack_monitoring_fm
			 ;;
			8)
			 cpu_exception_fm
			 ;;
			9)
			 g_obj=task
			 g_part=1
			 illegal_terminate_fm
			 ;;
			10)
			 g_obj=c2isr
			 g_part=2
			 illegal_terminate_fm
			 ;;
			11)
			 g_obj=hook
			 g_part=3
			 illegal_terminate_fm
			 ;;
			12)
			 osap_termination_restart_fm
			 ;;
			13)
			 forced_task_termination_fm
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

# メモリ保護テスト共通変数定義
memory_protection_fm()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "${ARR_MEMORY_PROTECTION[$g_part]} is $NOT_SUPPORT"
		return
	fi

	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT -f --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$PROTECTION_TEST_ROOT/$MEMORY_PROTECTION_ROOT\_$g_part
		g_tree_level="../../../../../"
	else
		g_aktg_opt=`echo "$AKTG_OPT -f"`
		g_root_dir=$PROTECTION_TEST_ROOT/$MEMORY_PROTECTION_ROOT\_$g_part
	fi
	# メモリ保護テストでは全OS機能OFF(SC3ではSTANDARDは不可)
	g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"

	g_test_lib_file_for_mempro="$TEST_LIB_FILE_FOR_MEMPRO"
	g_include_dir_for_mempro=$INCLUDE_DIR_FOR_MEMPRO

	g_test_type="${ARR_MEMORY_PROTECTION[$g_part]} ($FORCED_MERGE_TEST)"
	g_manifest_name=$MNF_MEMORY_PROTECTION_NOT_MRG\_$g_part
	g_pre_dir_name=$MEMORY_PROTECTION_ROOT
	g_temp_dir_name=temp_dir_mempro_single\_$g_part
	g_temp_manifest=temp_mempro_single\_$g_part
	g_tesry_dir=$MEMORY_PROTECTION_DIR\_$g_part/$NOTMERGE_TESRY_DIR
	g_cmy_dir=protection_test/$LOWER_CASE_SC/memory_protection\_$g_part/notmerge_tesry
	g_temp_cmy=temp_cmy_mempro_single\_$g_part
	g_cvt_tesry_flg=1

	force_merge_menu
}

# スタックモニタリングテスト共通変数定義
stack_monitoring_fm()
{
	# コア間割込み変換モードでは，スタックモニタリングテストは対象外
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		echo "$STACK_MONITORING is $NOT_SUPPORT"
		return
	fi

	# スタックモニタリングテストではスタックモニタリング以外のOS機能OFF
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f --use_get_serviceid false --use_parameter_access false --return_status STANDARD"`
	else
		# SC3ではSTANDARDは不可
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"`
	fi

	g_root_dir=$PROTECTION_TEST_ROOT/$STACK_MONITORING_ROOT
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	g_test_type="$STACK_MONITORING ($FORCED_MERGE_TEST)"
	g_manifest_name=$MNF_STACK_MONITORING_NOT_MRG
	g_pre_dir_name=$STACK_MONITORING_ROOT
	g_temp_dir_name=temp_dir_smoni_single
	g_temp_manifest=temp_smoni_single
	g_tesry_dir="$STACK_MONITORING_DIR/$NOTMERGE_TESRY_DIR"
	g_cmy_dir="protection_test/$LOWER_CASE_SC/stack_monitoring/notmerge_tesry"
	g_temp_cmy=temp_cmy_smoni_single

	force_merge_menu
}

# CPU例外テスト共通変数定義
cpu_exception_fm()
{
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT -f --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$PROTECTION_TEST_ROOT/$CPU_EXCEPTION_ROOT
		g_tree_level="../../../../../"
	else
		g_aktg_opt=`echo "$AKTG_OPT -f"`
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

	g_test_type="$CPU_EXCEPTION ($FORCED_MERGE_TEST)"
	g_manifest_name=$MNF_CPU_EXCEPTION_NOT_MRG
	g_pre_dir_name=$CPU_EXCEPTION_ROOT
	g_temp_dir_name=temp_dir_cpuexc_single
	g_temp_manifest=temp_cpuexc_single
	g_tesry_dir="$CPU_EXCEPTION_DIR/$NOTMERGE_TESRY_DIR"
	g_cmy_dir="protection_test/$LOWER_CASE_SC/cpu_exception/notmerge_tesry"
	g_temp_cmy=temp_cmy_cpuexc_single

	force_merge_menu
}

# タスク強制終了テスト共通変数定義
forced_task_termination_fm()
{
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		echo "$FORCED_TASK_TERMINATION is $NOT_SUPPORT"
		return
	else
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"`
		g_root_dir=$PROTECTION_TEST_ROOT/$FORCED_TASK_TERMINATION_ROOT
	fi

	# CPU例外テストでは全OS機能OFF
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "$FORCED_TASK_TERMINATION is $NOT_SUPPORT"
		return
	fi

	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	g_test_type="$FORCED_TASK_TERMINATION ($FORCED_MERGE_TEST)"
	g_manifest_name=$MNF_FORCED_TASK_TERMINATION_NOT_MRG
	g_pre_dir_name=$FORCED_TASK_TERMINATION_ROOT
	g_temp_dir_name=temp_dir_ftask_single
	g_temp_manifest=temp_ftask_single
	g_tesry_dir="$FORCED_TASK_TERMINATION_DIR/$NOTMERGE_TESRY_DIR"
	g_cmy_dir="protection_test/$LOWER_CASE_SC/forced_task_termination/notmerge_tesry"
	g_temp_cmy=temp_cmy_ftask_single

	force_merge_menu
}

# 不正終了テスト共通変数定義
illegal_terminate_fm()
{
	# コア間割込み変換モードでは，C2ISRの不正終了以外は対象外
	if [ $g_isisr_cnvert_flg -eq 1 ] && [ $g_part -ne 2 ]
	then
		echo "${ARR_ILLEGAL_TERMINATE[$g_part]} is $NOT_SUPPORT"
		return
	fi

	if [ $g_isisr_cnvert_flg -eq 1 ] && [ $g_part -eq 2 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$ERROR_TEST_ROOT/$ILLEGAL_TERMINATE_ROOT\_$g_obj
		g_tree_level="../../../../../"
	else
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f"`
		g_root_dir=$ERROR_TEST_ROOT/$ILLEGAL_TERMINATE_ROOT\_$g_obj
	fi

	# 不正終了テストではスタックモニタリング，サービスID取得以外のOS機能OFF
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		g_aktg_opt=`echo "$g_aktg_opt --use_get_serviceid true --use_parameter_access false --return_status STANDARD"`
	else
		# SC3ではSTANDARDは不可
		g_aktg_opt=`echo "$g_aktg_opt --use_get_serviceid true --use_parameter_access false --return_status EXTENDED"`
	fi

	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	g_test_type="${ARR_ILLEGAL_TERMINATE[$g_part]} ($FORCED_MERGE_TEST)"
	g_manifest_name=${MNF_ILLEGAL_TERMINATE[$g_part]}
	g_pre_dir_name=$ILLEGAL_TERMINATE_ROOT
	g_temp_dir_name=temp_dir_illter_single\_$g_obj
	g_temp_manifest=temp_illter_single\_$g_obj
	g_tesry_dir=$ILLEGAL_TERMINATE_DIR\_$g_obj/$NOTMERGE_TESRY_DIR
	g_cmy_dir=error_test/$LOWER_CASE_SC/illegal_terminate\_$g_obj/notmerge_tesry
	g_temp_cmy=g_temp_cmy_illter_single\_$g_obj

	force_merge_menu
}

# OSAP終了/再起動テスト共通変数定義
osap_termination_restart_fm()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		echo "$FORCED_TASK_TERMINATION is $NOT_SUPPORT"
		return
	fi

	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT -f --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$PROTECTION_TEST_ROOT/$OSAP_TERMINATION_RESTART_ROOT
		g_tree_level="../../../../../"
	else
		g_aktg_opt=`echo "$AKTG_OPT -f"`
		g_root_dir=$PROTECTION_TEST_ROOT/$OSAP_TERMINATION_RESTART_ROOT
	fi

	# OSAP終了/再起動テストでは全OS機能OFF
	# SC3ではSTANDARDは不可
	g_aktg_opt="$g_aktg_opt --stack_monitoring false --use_get_serviceid false --use_parameter_access false --return_status EXTENDED"

	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	g_test_type="$OSAP_TERMINATION_RESTART ($FORCED_MERGE_TEST)"
	g_manifest_name=$MNF_OSAP_TERMINATION_RESTART_NOT_MRG
	g_pre_dir_name=$OSAP_TERMINATION_RESTART_ROOT
	g_temp_dir_name=temp_dir_osaptr_single
	g_temp_manifest=temp_osaptr_single
	g_tesry_dir="$OSAP_TERMINATION_RESTART_DIR/$NOTMERGE_TESRY_DIR"
	g_cmy_dir="protection_test/$LOWER_CASE_SC/osap_termination_restart/notmerge_tesry"
	g_temp_cmy=temp_cmy_osaptr_single

	force_merge_menu
}

# 強制マージテスト実行用のメニュー
force_merge_menu()
{
	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $g_test_type
$DOUBLE_LINE
 1: $GENE_ALL_MNF
 2: $EXEC_3_6
 3: $MNF_MAKE_DIR
 4: $EXEC_AKTG
 5: $MNF_MAKE_DEPEND
 6: $MNF_MAKE_BUILD
 7: $MNF_MAKE_CLEAN
 8: $MNF_MAKE_REALCLEAN
 s: $OPERATE_SPEC_DIR
 e: $RUN_EXEC_MODULE
 m: $MULTI_THREAD_EXEC_3_6
 p: $PARALLEL_BUILD_AND_RUN
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
			 header_double "$GENE_ALL_MNF"
			 make_manifest_for_force_merge
			 ;;
			2)
			 header_double "$EXEC_3_6"
			 continuous_execute_for_force_merge
			 ;;
			3)
			 header_double "$MNF_MAKE_DIR"
			 make_directory_for_force_merge
			 ;;
			4)
			 header_double "$EXEC_AKTG"
			 execute_aktg_for_force_merge
			 ;;
			5)
			 header_double "$MNF_MAKE_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_for_force_merge
			 ;;
			6)
			 header_double "$MNF_MAKE_BUILD"
			 g_rule=$RULE_BUILD
			 make_for_force_merge
			 ;;
			7)
			 header_double "$MNF_MAKE_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_for_force_merge
			 ;;
			8)
			 header_double "$MNF_MAKE_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_for_force_merge
			 ;;
			s)
			 operate_spec_dir_for_force_merge
			 ;;
			e)
			 header_double "$RUN_EXEC_MODULE"
			 execute_module_for_force_merge
			 ;;
			m)
			 header_double "$MULTI_THREAD_EXEC_3_6"
			 multi_thread_execute_for_force_merge 0
			 ;;
			p)
			 header_double "$PARALLEL_BUILD_AND_RUN"
			 multi_thread_execute_for_force_merge 1
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


# 個別のマニフェストフォルダに対する操作
operate_spec_dir_for_force_merge()
{
	g_check_dir_name=$OBJECT_DIR/$g_root_dir
	check_dir
	if [ $? -eq 1 ]
	then
		return
	fi
	cd $OBJECT_DIR/$g_root_dir

	echo -n "$INPUT_DIR "
	read g_dir_name
	if [ -d $g_dir_name ]
	then
		cd $g_dir_name
	else
		echo "$g_dir_name $ERR_NO_DIR"
		cd $AKTSP_DIR
		return
	fi

	echo $SINGLE_LINE

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $OPERATE_SPEC_DIR ($g_test_type) [$g_dir_name]
$DOUBLE_LINE
 1: $EXEC_2_4
 2: $EXEC_AKTG
 3: $SPCDIR_MAKE_DEPEND
 4: $SPCDIR_MAKE_BUILD
 5: $SPCDIR_MAKE_CLEAN
 6: $SPCDIR_MAKE_REALCLEAN
 e: $RUN_EXEC_MODULE
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
			 header_double "$EXEC_2_4"
			 g_check_file_name=MNF\_$g_dir_name
			 g_merge_flg=1
			 continuous_execute_in_operate_directory
			 ;;
			2)
			 header_double "$EXEC_AKTG"
			 g_check_file_name=MNF\_$g_dir_name
			 g_merge_flg=1
			 execute_aktg_in_operate_directory
			 ;;
			3)
			 header_double "$SPCDIR_MAKE_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_in_operate_directory
			 ;;
			4)
			 header_double "$SPCDIR_MAKE_BUILD"
			 g_rule=$RULE_BUILD
			 make_in_operate_directory
			 ;;
			5)
			 header_double "$SPCDIR_MAKE_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_in_operate_directory
			 ;;
			6)
			 header_double "$SPCDIR_MAKE_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_in_operate_directory
			 ;;
			e)
			 header_double "$RUN_EXEC_MODULE"
			 g_kind="$OPERATE_SPEC_DIR_FORCE_MERGE"
			 execute_module
			 ;;
			r)
			 cd $AKTSP_DIR
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


# 強制マージテストのマニフェスト作成
make_manifest_for_force_merge()
{
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

		cmy_list=`find $AKTSP_DIR/$g_cmy_dir/ -name "*.cmy"`
		# マルチコアの場合
		if [ "$USE_MULTI_CORE" == "true" ]
		then
			mc=`echo $g_cmy_dir | sed -e "s/$LOWER_CASE_SC/$LOWER_CASE_SC"-mc"/g"`
			if [ -d $AKTSP_DIR/$mc ]
			then
				cmy_list=(${cmy_list[@]} `find $AKTSP_DIR/$mc/ -name "*.cmy"`)
			fi
		fi

		for line in ${cmy_list[@]}
		do
			match_str=`echo $line | sed -e "s/\.cmy//g"`
			match_str=${match_str##*/}

			# cmyファイル単位よりも細かい単位でテストする必要がある場合，
			# 指定された値(div_num)で分割する
			div_num=""
			if [ -f $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM ]
			then
				div_num=`grep "$match_str" $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM | grep "$SCALABILITY_CLASS" | awk -F ',' '{print $2}'`
			fi
			if [ "$div_num" != "" ]
			then
				grep "$match_str" ./$g_temp_manifest > .tmp1
				all_step=`cat .tmp1 | wc -l`
				each_step=`expr $all_step / $div_num`
				remainder=`expr $all_step % $div_num`
				pre_loop=-1

				loop=`expr $remainder - 1`
				for pre_loop in `seq 0 1 $loop` # pre_loopを0から1ずつ増やしながら，loopの値になるまでループする
				do
					cat .tmp1 | tail -n `expr $all_step - \( $each_step + 1 \) \* $pre_loop` > .tmp2
					cat .tmp2 | head -n `expr $each_step + 1` | tee -a $g_manifest_name
					echo ""  | tee -a $g_manifest_name
				done
				pre_loop=`expr $pre_loop + 1`
				loop=`expr $div_num - $remainder - 1`
				for post_loop in `seq 0 1 $loop`
				do
					cat .tmp1 | tail -n `expr $all_step - \( $each_step + 1 \) \* $pre_loop - $each_step \* $post_loop` > .tmp2
					cat .tmp2 | head -n $each_step | tee -a $g_manifest_name
					echo ""  | tee -a $g_manifest_name
				done
				rm -f .tmp*
			else
				grep "$match_str" ./$g_temp_manifest | tee -a $g_manifest_name
				echo ""  | tee -a $g_manifest_name
			fi
		done
	fi
	rm -f $g_temp_manifest
	cd $AKTSP_DIR
}

# 強制マージテストのテストフォルダ(cmy単位)毎にフォルダ作成，AKTG，
# make depend，make実行
continuous_execute_for_force_merge()
{
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

	rm -rf $OBJECT_DIR/$g_root_dir/$g_pre_dir_name\_*/

	mkdir -p $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
	cd $OBJECT_DIR/$g_root_dir/$g_temp_dir_name

	# ジェネレータオプションの共通コンパイルオプションに追加
	UNSET_CONFIG_OPT_O=$CONFIG_OPT_O
	CONFIG_OPT_O+=" -DENABLE_RETURN_MAIN"

	execution_configure

	# 強制マージ用の共通コンパイルオプションに戻す
	CONFIG_OPT_O=$UNSET_CONFIG_OPT_O

	g_check_file_name=$MAKE_FILE_NAME
	check_file
	if [ $? -eq 1 ]
	then
		echo "$ERR_CREAT_MAKEFILE_FAIL"
		cd $AKTSP_DIR
		return
	fi

	cd ../
	rm -f $g_temp_manifest
	cnt=1
	tmp_dir_name=""
	while read line
	do
		if [ $line ]
		then
			flg=0
			echo $line >> $g_temp_manifest
			pre_line=$line
		else
			if [ $flg -eq 0 ]
			then
				# フォルダとフォルダ内のマニフェストファイル作成
				g_dir_name=`echo $pre_line | sed -e "s/\.yaml//g"`
				g_dir_name=`echo ${g_dir_name##*/} | sed -e "s/\(\_[0-9][0-9][0-9][0-9]\)//g"`

				# cmyファイル単位よりも細かい単位でテストする必要がある場合
				chk=0
				if [ -f $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM ]
				then
					chk=`grep "$g_dir_name" $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM | grep "$SCALABILITY_CLASS" | wc -l`
				fi
				if [ $chk -ne 0 ]
				then
					if [ "$tmp_dir_name" == "$g_dir_name" ]
					then
						cnt=`expr $cnt + 1`
					else
						cnt=1
					fi
					tmp_dir_name=$g_dir_name
					tmpcnt=`printf "%02d" ${cnt}`
					g_dir_name=$g_dir_name\_$tmpcnt
				fi

				mkdir -p $g_dir_name &> /dev/null
				echo "$PRE_MAKE_DIRECTORY "$g_dir_name" $POST_MAKE_DIRECTORY"
				mv $g_temp_manifest $g_dir_name/MNF\_$g_dir_name
				cp -p $g_temp_dir_name/$MAKE_FILE_NAME ./$g_dir_name

				cd $g_dir_name
				# AKTG実行
				header_single "$AKTG_IN $g_dir_name"
				g_check_file_name=MNF\_$g_dir_name
				exclusion_comment_out
				execute_aktg

				# make depend実行
				if [ $? -eq 0 ]
				then
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

				flg=1
				echo ""
				cd ../
			fi
		fi
	done < $g_manifest_name

	cd $AKTSP_DIR
	rm -rf $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
}

# テスト用フォルダ作成(強制マージテスト用)
make_directory_for_force_merge()
{
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

	rm -rf $OBJECT_DIR/$g_root_dir/$g_pre_dir_name\_*/

	mkdir -p $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
	cd $OBJECT_DIR/$g_root_dir/$g_temp_dir_name

	# ジェネレータオプションの共通コンパイルオプションに追加
	UNSET_CONFIG_OPT_O=$CONFIG_OPT_O
	CONFIG_OPT_O+=" -DENABLE_RETURN_MAIN"

	execution_configure

	# 強制マージ用の共通コンパイルオプションに戻す
	CONFIG_OPT_O=$UNSET_CONFIG_OPT_O

	g_check_file_name=$MAKE_FILE_NAME
	check_file
	if [ $? -eq 1 ]
	then
		echo "$ERR_CREAT_MAKEFILE_FAIL"
		cd $AKTSP_DIR
		return
	fi

	cd ../
	rm -f $g_temp_manifest
	g_dir_num=0 # マルチスレッド実行で使用する変数
	cnt=1
	tmp_dir_name=""
	while read line
	do
		if [ $line ]
		then
			flg=0
			echo $line >> $g_temp_manifest
			pre_line=$line
		else
			if [ $flg -eq 0 ]
			then
				# フォルダとフォルダ内のマニフェストファイル作成
				g_dir_name=`echo $pre_line | sed -e "s/\.yaml//g"`
				g_dir_name=`echo ${g_dir_name##*/} | sed -e "s/\(\_[0-9][0-9][0-9][0-9]\)//g"`

				# cmyファイル単位よりも細かい単位でテストする必要がある場合
				chk=0
				if [ -f $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM ]
				then
					chk=`grep "$g_dir_name" $AKTSP_DIR/library/target/$TARGET_NAME/$FORCE_MERGE_DIVNUM | grep "$SCALABILITY_CLASS" | wc -l`
				fi
				if [ $chk -ne 0 ]
				then
					if [ "$tmp_dir_name" == "$g_dir_name" ]
					then
						cnt=`expr $cnt + 1`
					else
						cnt=1
					fi
					tmp_dir_name=$g_dir_name
					tmpcnt=`printf "%02d" ${cnt}`
					g_dir_name=$g_dir_name\_$tmpcnt
				fi

				mkdir -p $g_dir_name &> /dev/null
				echo "$PRE_MAKE_DIRECTORY "$g_dir_name" $POST_MAKE_DIRECTORY"
				mv $g_temp_manifest $g_dir_name/MNF\_$g_dir_name
				cp -p $g_temp_dir_name/$MAKE_FILE_NAME ./$g_dir_name
				g_dir_num=`expr $g_dir_num + 1 `
				flg=1
			fi
		fi
	done < $g_manifest_name

	cd $AKTSP_DIR
	rm -rf $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
}

# AKTG実行(強制マージテスト用)
execute_aktg_for_force_merge()
{
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
		for g_dir_name in ${dir_list[@]}
		do
			header_single "$AKTG_IN $g_dir_name"
			g_check_file_name=$g_dir_name/MNF\_$g_dir_name
			check_file
			if [ $? -eq 1 ]
			then
				continue
			fi
			check_empty_file
			if [ $? -eq 1 ]
			then
				continue
			fi
			exclusion_comment_out
			cd $g_dir_name
			execute_aktg
			cd ../
		done
	fi
	cd $AKTSP_DIR
}

# 強制マージテストのMakefileを用いて行う処理(make depend, make, 
# make clean, make realclean)の実行
make_for_force_merge()
{
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
		for g_dir_name in ${dir_list[@]}
		do
			if [ ! -d $g_dir_name ]
			then
				continue
			fi
			cd $g_dir_name
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
			if [ $? -ne 1 ]
			then
				make_for_common
			fi
			cd ../
		done
	fi
	cd $AKTSP_DIR
}

# マルチスレッドでの実行
multi_thread_execute_for_force_merge()
{
	thread_num=0
	while [ $thread_num -lt 1 ]
	do
		echo -n "$INPUT_THREAD_NUM "
		read thread_num
		err_thread_num=`echo -n $thread_num | sed 's/[0-9]//g' `
		# Enterのみ押下，数字以外の文字列の入力，1未満のチェック
		if [ "$thread_num" == "" ] || [ $err_thread_num ] || [ $thread_num -lt 1 ]
		then
			echo "$thread_num $ERR_INVALID_NO"
			return
		fi
	done

	make_directory_for_force_merge

	# 引数が1の場合，ビルドと平行して実行も行う
	if [ $1 -eq 1 ]
	then
		cur_dir=`pwd`
		cygstart --shownoactivate sh "$cur_dir/scripts/common.sh PARALLEL_RUN_FORCE_MERGE $g_root_dir $g_pre_dir_name $AKTSP_DIR $TARGET_NAME $SCALABILITY_CLASS $CORE_NUM $USE_MULTI_CORE"
	fi

	cd $OBJECT_DIR/$g_root_dir
	dir_list=`ls | grep $g_pre_dir_name\_`
	cd $AKTSP_DIR
	cnt=1

	if [ ! "$dir_list" ]
	then
		echo $g_pre_dir_name'_* '$ERR_NO_DIR
	else
		for g_dir_name in ${dir_list[@]}
		do
			# 同時実行スレッド数以下であれば新規起動
			now_thread=`ps ax | grep con | grep -e ruby -e make -e sleep | wc -l`
			while [ $now_thread -ge $thread_num ]
			do
				echo "$WAITING"
				sleep 10
				now_thread=`ps ax | grep con | grep -e ruby -e make -e sleep | wc -l`
			done

			cur_dir=`pwd`
			echo "$EXECUTE"$g_dir_name
			if [ $cnt -eq $g_dir_num ]
			then
				cyg_opt="-w"
				echo "$WAIT_LAST_BUILD"
			else
				cyg_opt=""
			fi
			cygstart $cyg_opt --shownoactivate sh "$cur_dir/scripts/force_merge.sh MULTI_THREAD $g_root_dir $g_manifest_name $g_dir_name \"$g_aktg_opt\" $g_cmd_depend $g_cmd_all $g_force_merge_flg"
			cnt=`expr $cnt + 1`
			sleep 3
		done
	fi

	# シングル/マルチコアでログファイル切り替え
	if [ "$USE_MULTI_CORE" == "false" ] || [ "$g_manifest_name" == "$MNF_BOOT_ONLY_MASTER_CORE" ]
	then
		log_name=$RESULT_EXECUTE
	else
		log_name="${RESULT_EXECUTE_MC}0.log"
	fi

	# 引数が1の場合，最後のフォルダ実行後に結果表示を行う
	if [ $1 -eq 1 ]
	then
		echo "$WAIT_LAST_EXEC"
		while true
		do
			# 実行ログがある場合，ファイルサイズの変化で実行終了を判断する
			if [ -f "$OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name" ]
			then
				chk_size1=`cat $OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name | wc -l`
				echo "$CHECK_LOG_SIZE1 $OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name: $chk_size1"

				sleep 3

				# ログサイズが5行以下のときは未実行と判断(ロード中など)
				if [ $chk_size1 -gt 5 ]
				then
					chk_size2=`cat $OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name | wc -l`
					echo "$CHECK_LOG_SIZE2 $OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name: $chk_size2"
					if [ $chk_size1 -eq $chk_size2 ]
					then
						break
					fi
				fi
			# それ以外はビルド＆実行待ち
			else
				echo "$NOT_FOUND $OBJECT_DIR/$g_root_dir/$g_dir_name/$log_name"
				if [ -f "$OBJECT_DIR/$g_root_dir/$g_dir_name/$MODULE_NAME" ]
				then
					echo "$FOUND $OBJECT_DIR/$g_root_dir/$g_dir_name/$MODULE_NAME"
				fi
				if [ -f "$OBJECT_DIR/$g_root_dir/$g_dir_name/$FINISH_MAKE_FLG" ]
				then
					echo "$FOUND $OBJECT_DIR/$g_root_dir/$g_dir_name/$FINISH_MAKE_FLG"
				fi
				sleep 5
			fi
		done

		# ログ確認
		echo "$CHECK_EXEC_LOG"
		g_test_num=0
		g_success_num=0
		g_no_log_num=0
		cd $OBJECT_DIR/$g_root_dir
		rm -f $RESULT_ERROR_TEST
		cd $AKTSP_DIR
		for g_dir_name in ${dir_list[@]}
		do
			g_test_num=`expr $g_test_num + 1`
			g_check_dir_name=$OBJECT_DIR/$g_root_dir/$g_dir_name
			check_dir
			if [ $? -eq 1 ]
			then
				continue
			fi

			header_single $g_check_dir_name
			cd $g_check_dir_name
			# マスタコアのみ起動するテストは，コア数を1として実行しているため，シングルコアと同じ結果ファイル
			if [ "$USE_MULTI_CORE" == "false" ] || [ "$g_manifest_name" == "$MNF_BOOT_ONLY_MASTER_CORE" ]
			then
				cat $RESULT_EXECUTE
			else
				cat ${RESULT_EXECUTE_MC}*.log
			fi
			check_exec_success_force_merge
			cd $AKTSP_DIR
		done
		if [ $g_no_log_num -ne $g_test_num ]
		then
			header_single "$EACH_TEST_RESULT"
			cat $AKTSP_DIR/$OBJECT_DIR/$g_root_dir/$RESULT_ERROR_TEST
		fi
		output_log
	fi
}

# マルチスレッド起動用(別シェルから実行する)
if [ "$1" == "MULTI_THREAD" ]
then
	source ./scripts/common.sh
	source ./configure.sh
	source ./library/target/$TARGET_NAME/aktsp_target.sh

	# 必要な変数定義
	g_root_dir=$2
	g_manifest_name=$3
	g_dir_name=$4
	g_aktg_opt=$5
	g_cmd_depend=$6
	g_cmd_all=$7
	g_force_merge_flg=$8
	g_aktg_bin=`get_realpath ./$AKTG_BIN`

	# 対象ディレクトリへ移動
	cd $OBJECT_DIR/$g_root_dir/$g_dir_name/

	# ATKG実行
	header_double "$EXEC_AKTG"
	g_check_file_name=MNF\_$g_dir_name
	g_merge_flg=1
	execute_aktg_in_operate_directory
	if [ $? -ne 0 ]
	then
		exit
	fi

	# make depend実行
	header_double "$SPCDIR_MAKE_DEPEND"
	g_rule=$RULE_DEPEND
	make_in_operate_directory
	if [ $? -ne 0 ]
	then
		exit
	fi
	sleep 2

	# make実行
	header_double "$SPCDIR_MAKE_BUILD"
	g_rule=$RULE_BUILD
	make_in_operate_directory

	sleep 3
	exit
fi

