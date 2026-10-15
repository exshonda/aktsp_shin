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
# $Id: ioc_test.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

# IOCテストメニュー
ioc_test_main()
{
	if [ "$SCALABILITY_CLASS" == "SC1" ]
	then
		if [ "$USE_MULTI_CORE" == "false" ]
		then
			echo "$IOC_TEST_MENU is $NOT_SUPPORT"
			return
		fi
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

	# IOCテスト共通変数定義
	if [ $g_isisr_cnvert_flg -eq 1 ]
	then
		g_aktg_opt=`echo "$AKTG_OPT --icisr_convert true --icisr_pri ${ARR_ISR_PRIORITY[$g_isr_pri]}"`
		g_root_dir=$ICISR_CONVERT_TEST_ROOT/$IOC_TEST_ROOT
		g_tree_level="../../../../"
	else
		g_aktg_opt=$AKTG_OPT
		g_root_dir=$IOC_TEST_ROOT
		g_tree_level="../../../"
	fi
	# IOCではスタックモニタリングのみOFF
	g_aktg_opt="$g_aktg_opt --stack_monitoring false"

	g_manifest_name=$MNF_IOC_TEST
	g_pre_dir_name=$AUTO_CODE_DIR_NAME
	g_temp_dir_name=temp_dir_ioc_aut
	g_temp_manifest=temp_ioc
	g_test_type="$IOC_TEST_MENU"
	g_tesry_dir="$IOC_TEST_DIR"
	g_cmy_dir="ioc_test/$LOWER_CASE_SC"
	g_temp_cmy=temp_cmy_ioc
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=
	g_cvt_tesry_flg=0

	auto_code_menu
}

# 処理開始
ioc_test_main
