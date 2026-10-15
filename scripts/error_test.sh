#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2012-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2012-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2012-2013 by Spansion LLC, USA
# Copyright (C) 2012-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2012-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2012-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2012-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2012-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2012-2014 by Witz Corporation, JAPAN
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
# $Id: error_test.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

# エラー処理テストメニュー
error_test_main()
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

	# エラー処理テスト共通変数定義
	g_tree_level="../../../../"

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $ERROR_TEST_MENU
$DOUBLE_LINE
 1: $ILLEGAL_TERMINATE_TASK
 2: $ILLEGAL_TERMINATE_C2ISR
 3: $ILLEGAL_TERMINATE_HOOK
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
			# コア間割込み変換モードでは，タスクの不正終了テストは対象外
			if [ $g_isisr_cnvert_flg -eq 1 ]
			then
				echo "$ILLEGAL_TERMINATE_TASK is $NOT_SUPPORT"
				return
			fi
			g_obj=task
			g_part=1
			illegal_terminate
			;;
			2)
			g_obj=c2isr
			g_part=2
			illegal_terminate
			;;
			3)
			# コア間割込み変換モードでは，フックの不正終了テストは対象外
			if [ $g_isisr_cnvert_flg -eq 1 ]
			then
				echo "$ILLEGAL_TERMINATE_HOOK is $NOT_SUPPORT"
				return
			fi
			g_obj=hook
			g_part=3
			illegal_terminate
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

# 不正終了テストメニュー
illegal_terminate()
{
	# 不正終了テスト共通変数定義
	if [ $g_isisr_cnvert_flg -eq 1 ] && [ $g_part -eq 2 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$ERROR_TEST_ROOT/$ILLEGAL_TERMINATE_ROOT\_$g_obj
		g_tree_level="../../../../../"
	else
		g_aktg_opt=`echo "$AKTG_OPT --stack_monitoring true --stackfault_detection false --stack_share true"`
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

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 ${ARR_ILLEGAL_TERMINATE[$g_part]}
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
			 echo "${ARR_ILLEGAL_TERMINATE[$g_part]} ($MERGE_TEST) is $NOT_SUPPORT"
			 ;;
			2)
			 # 不正終了テスト(マージ不可能なテスト)共通変数定義
			 g_test_type="${ARR_ILLEGAL_TERMINATE[$g_part]} ($NOT_MERGE_TEST)"
			 g_manifest_name=${MNF_ILLEGAL_TERMINATE[$g_part]}
			 g_pre_dir_name=$ILLEGAL_TERMINATE_ROOT
			 g_temp_dir_name=temp_dir_illter_single\_$g_obj
			 g_temp_manifest=temp_illter_single\_$g_obj
			 g_tesry_dir=$ILLEGAL_TERMINATE_DIR\_$g_obj/$NOTMERGE_TESRY_DIR
			 g_cmy_dir=error_test/$LOWER_CASE_SC/illegal_terminate\_$g_obj/notmerge_tesry
			 g_temp_cmy=g_temp_cmy_illter_single\_$g_obj

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

# 処理開始
error_test_main
