#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2013-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2013-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2013-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2013-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2013-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2013-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2013-2014 by Witz Corporation, JAPAN
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
# $Id: icisr_test.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

# コア間割込みテストメニュー
icisr_test_main()
{
	if [ "$USE_MULTI_CORE" == "false" ]
	then
		echo "$ICISR_TEST_MENU is $NOT_SUPPORT"
		return
	fi

	if [ "$USE_KERNEL_LIB" == "true" ]
	then
		g_check_file_name=$KERNEL_LIB/libkernel.a
		check_file
		if [ $? -eq 1 ]
		then
			return
		fi
	fi

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $ICISR_TEST_MENU
$DOUBLE_LINE
 1: $ICISR_CONVERT_TEST_MENU
 2: $SYSSRV_TEST_MENU
 3: $ATYPICAL_SYSSRV_TEST_MENU
 4: $STACK_MONITORING
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
			 icisr_convert_test_select_pri
			 ;;
			2)
			 icisr_syssrv_test
			 ;;
			3)
			 icisr_atypical_syssrv_test
			 ;;
			4)
			 icisr_stack_monitoring_test
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

# コア間割込み変換テスト優先度選択
icisr_convert_test_select_pri()
{
	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $ICISR_CONVERT_SELECT_PRI
$DOUBLE_LINE
 1: ${ARR_ISR_PRIORITY[1]}
 2: ${ARR_ISR_PRIORITY[2]}
 3: ${ARR_ISR_PRIORITY[3]}
 4: ${ARR_ISR_PRIORITY[4]}
 5: ${ARR_ISR_PRIORITY[5]}
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
			 g_isr_pri=1
			 icisr_convert_test
			 ;;
			2)
			 g_isr_pri=2
			 icisr_convert_test
			 ;;
			3)
			 g_isr_pri=3
			 icisr_convert_test
			 ;;
			4)
			 g_isr_pri=4
			 icisr_convert_test
			 ;;
			5)
			 g_isr_pri=5
			 icisr_convert_test
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

# コア間割込み変換テストメニュー
icisr_convert_test()
{
	# 変換フラグをONにする
	g_isisr_cnvert_flg=1

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $ICISR_CONVERT_TEST_MENU
$DOUBLE_LINE
 1: $SYSSRV_TEST_MENU
 2: $PROTECTION_TEST_MENU
 3: $ERROR_TEST_MENU
 4: $MODISTARC_MENU
 5: $ATYPICAL_SYSSRV_TEST_MENU
 6: $IOC_TEST_MENU
 f: $FORCED_MERGE_MENU
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

# コア間割込みシステムサービステスト
icisr_syssrv_test()
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

	g_aktg_opt=$AKTG_OPT
	g_root_dir=$ICISR_TEST_ROOT/$SYSSRV_TEST_ROOT
	g_manifest_name=$MNF_ICISR_SYSSRV_TESRY
	g_pre_dir_name=$AUTO_CODE_DIR_NAME
	g_temp_dir_name=temp_dir_icisr_ss_aut
	g_temp_manifest=temp_icisr_ss
	g_tree_level="../../../../"
	g_test_type="$SYSSRV_TEST_MENU"
	g_tesry_dir="$ICISR_SYSSRV_TEST_DIR"
	g_cmy_dir="icisr_test/$LOWER_CASE_SC/syssrv_test"
	g_temp_cmy=temp_cmy_icisr_ss
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	auto_code_menu
}

# コア間割込み特殊なシステムサービステスト
icisr_atypical_syssrv_test()
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

	g_aktg_opt=`echo "$AKTG_OPT --boot_only_master_core true"`
	g_root_dir=$ICISR_TEST_ROOT/$ATYPICAL_SYSSRV_TEST_ROOT
	g_manifest_name=$MNF_ICISR_ATYPICAL_SYSSRV_TESRY
	g_pre_dir_name=$AUTO_CODE_DIR_NAME
	g_temp_dir_name=temp_dir_icisr_ass_aut
	g_temp_manifest=temp_icisr_ass
	g_tree_level="../../../../"
	g_test_type="$ATYPICAL_SYSSRV_TEST_MENU"
	g_tesry_dir="$ICISR_ATYPICAL_SYSSRV_TEST_DIR"
	g_cmy_dir="icisr_test/$LOWER_CASE_SC/atypical_syssrv_test"
	g_temp_cmy=temp_cmy_icisr_ass
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	auto_code_menu
}

# コア間割込みスタックモニタリングテスト
icisr_stack_monitoring_test()
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

	# スタックモニタリングテスト共通変数定義
	g_root_dir=$ICISR_TEST_ROOT/$STACK_MONITORING_ROOT
	g_tree_level="../../../../"
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
 f: $FORCED_MERGE_TEST
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
			 	g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true"`
			 	g_test_type="$STACK_MONITORING ($MERGE_TEST)"
			 	g_manifest_name=$MNF_ICISR_STACK_MONITORING_MRG
			 	g_pre_dir_name=$AUTO_CODE_DIR_NAME
			 	g_temp_dir_name=temp_dir_icisr_smoni_aut
			 	g_temp_manifest=temp_icisr_smoni_aut
			 	g_tesry_dir="$ICISR_STACK_MONITORING_TEST_DIR/$MERGE_TESRY_DIR"
			 	g_cmy_dir="icisr_test/$LOWER_CASE_SC/stack_monitoring/merge_tesry"
			 	g_temp_cmy=temp_cmy_icisr_smoni_aut

			 	auto_code_menu
			 fi
			 ;;
			2)
			 # スタックモニタリングテスト(マージ不可能なテスト)共通変数定義
			 g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true"`
			 g_test_type="$STACK_MONITORING ($NOT_MERGE_TEST)"
			 g_manifest_name=$MNF_ICISR_STACK_MONITORING_NOT_MRG
			 g_pre_dir_name=$STACK_MONITORING_ROOT
			 g_temp_dir_name=temp_dir_isisr_smoni_single
			 g_temp_manifest=temp_icisr_smoni_single
			 g_tesry_dir="$ICISR_STACK_MONITORING_TEST_DIR/$NOTMERGE_TESRY_DIR"
			 g_cmy_dir="icisr_test/$LOWER_CASE_SC/stack_monitoring/notmerge_tesry"
			 g_temp_cmy=temp_cmy_icisr_smoni_single

			 single_tesry_menu
			 ;;
			f)
			 if [ "$ENABLE_FORCED_MARGE" != "true" ]
			 then
			 	echo "$FORCED_MERGE_MENU is $NOT_SUPPORT"
			 else
			 	# スタックモニタリングテスト(強制マージ)共通変数定義
			 	g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true -f"`
			 	g_test_type="$STACK_MONITORING ($FORCED_MERGE_TEST)"
				g_manifest_name=$MNF_ICISR_STACK_MONITORING_NOT_MRG
				g_pre_dir_name=$STACK_MONITORING_ROOT
				g_temp_dir_name=temp_dir_isisr_smoni_single
				g_temp_manifest=temp_icisr_smoni_single
				g_tesry_dir="$ICISR_STACK_MONITORING_TEST_DIR/$NOTMERGE_TESRY_DIR"
				g_cmy_dir="icisr_test/$LOWER_CASE_SC/stack_monitoring/notmerge_tesry"
				g_temp_cmy=temp_cmy_icisr_smoni_single

			 	g_force_merge_flg=1
			 	source ./scripts/force_merge.sh
			 	# コア間割込みの強制マージはスタックモニタリングのみ
			 	force_merge_menu
			 fi
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

# 処理開始
icisr_test_main
