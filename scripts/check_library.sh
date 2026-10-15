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
# $Id: check_library.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

# チェックライブラリ確認メインメニュー
check_library_main()
{
	if [ $USE_KERNEL_LIB == "true" ]
	then
		g_check_file_name=$KERNEL_LIB/libkernel.a
		check_file
		if [ $? -eq 1 ]
		then
			return
		fi
	fi

	# チェックライブラリ確認共通変数定義
	g_root_dir=$CHECK_LIBRARY_ROOT
	g_test_lib_file_for_mempro=
	g_include_dir_for_mempro=

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $CHECK_LIBRARY_MENU
$DOUBLE_LINE
 1: $CHECK_ALL_FUNC_2_4
 2: $CHECK_INT
 3: $CHECK_PHK
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
			 check_all_function
			 ;;
			2)
			 check_interrupt
			 ;;
			3)
			 check_protection_hook
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

# 全機能チェックのメニュー
check_all_function()
{
	# 全機能チェック共通変数定義
	g_loop_dir_name="$INTERRUPT_DIR_NAME $PROTECTIONHOOK_DIR_NAME"

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $CHECK_ALL_FUNC
$DOUBLE_LINE
 1: $CHECK_ALL_FUNC_ALL_BUILD
 2: $CHECK_ALL_FUNC_MKDIR
 3: $CHECK_ALL_FUNC_DEPEND
 4: $CHECK_ALL_FUNC_BUILD
 5: $CHECK_ALL_FUNC_CLEAN
 6: $CHECK_ALL_FUNC_REALCLEAN
 e: $RUN_EXEC_MODULE
 r: $BACK_TO_MAIN_MENU
 q: Quit
$SINGLE_LINE
EOS
echo -n " $INPUT_NO "
		# キー読み込み
		read key
		echo ""
		# 読み込んだキーによって分岐
		case ${key} in
			1)
			 header_double "$CHECK_ALL_FUNC_ALL_BUILD"
			 continuous_execute_for_check_library
			 ;;
			2)
			 header_double "$CHECK_ALL_FUNC_MKDIR"
			 make_directory_for_check_library
			 ;;
			3)
			 header_double "$CHECK_ALL_FUNC_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_for_check_library
			 ;;
			4)
			 header_double "$CHECK_ALL_FUNC_BUILD"
			 g_rule=$RULE_BUILD
			 make_for_check_library
			 ;;
			5)
			 header_double "$CHECK_ALL_FUNC_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_for_check_library
			 ;;
			6)
			 header_double "$CHECK_ALL_FUNC_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_for_check_library
			 ;;
			e)
			 header_double "RUN_EXEC_MODULE"
			 g_kind="$CHECK_ALL_FUNC"
			 execute_module
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

# 割込み発生関数のチェック
check_interrupt()
{
	# 割込み発生関数チェック共通変数定義
	g_loop_dir_name="$INTERRUPT_DIR_NAME"

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $CHECK_INT
$DOUBLE_LINE
 1: $CHECK_INT_ALL_BUILD
 2: $CHECK_INT_MKDIR
 3: $CHECK_INT_DEPEND
 4: $CHECK_INT_BUILD
 5: $CHECK_INT_CLEAN
 6: $CHECK_INT_REALCLEAN
 e: $RUN_EXEC_MODULE
 r: $BACK_TO_MAIN_MENU
 q: Quit
$SINGLE_LINE
EOS
echo -n " $INPUT_NO "
		# キー読み込み
		read key
		echo ""
		# 読み込んだキーによって分岐
		case ${key} in
			1)
			 header_double "$CHECK_INT_ALL_BUILD"
			 continuous_execute_for_check_library
			 ;;
			2)
			 header_double "$CHECK_INT_MKDIR"
			 make_directory_for_check_library
			 ;;
			3)
			 header_double "$CHECK_INT_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_for_check_library
			 ;;
			4)
			 header_double "$CHECK_INT_BUILD"
			 g_rule=$RULE_BUILD
			 make_for_check_library
			 ;;
			5)
			 header_double "$CHECK_INT_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_for_check_library
			 ;;
			6)
			 header_double "$CHECK_INT_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_for_check_library
			 ;;
			e)
			 header_double "RUN_EXEC_MODULE"
			 g_kind=$CHECK_INT
			 execute_module
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

# プロテクションフック起動関数のチェック
check_protection_hook()
{
	# プロテクションフック起動関数チェック共通変数定義
	g_loop_dir_name="$PROTECTIONHOOK_DIR_NAME"

	while true
	do
		cat<<EOS

$DOUBLE_LINE
 $CHECK_PHK
$DOUBLE_LINE
 1: $CHECK_PHK_ALL_BUILD
 2: $CHECK_PHK_MKDIR
 3: $CHECK_PHK_DEPEND
 4: $CHECK_PHK_BUILD
 5: $CHECK_PHK_CLEAN
 6: $CHECK_PHK_REALCLEAN
 e: $RUN_EXEC_MODULE
 r: $BACK_TO_MAIN_MENU
 q: Quit
$SINGLE_LINE
EOS
echo -n " $INPUT_NO "
		# キー読み込み
		read key
		echo ""
		# 読み込んだキーによって分岐
		case ${key} in
			1)
			 header_double "$CHECK_PHK_ALL_BUILD"
			 continuous_execute_for_check_library
			 ;;
			2)
			 header_double "$CHECK_PHK_MKDIR"
			 make_directory_for_check_library
			 ;;
			3)
			 header_double "$CHECK_PHK_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_for_check_library
			 ;;
			4)
			 header_double "$CHECK_PHK_BUILD"
			 g_rule=$RULE_BUILD
			 make_for_check_library
			 ;;
			5)
			 header_double "$CHECK_PHK_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_for_check_library
			 ;;
			6)
			 header_double "$CHECK_PHK_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_for_check_library
			 ;;
			e)
			 header_double "RUN_EXEC_MODULE"
			 g_kind=$CHECK_PHK
			 execute_module
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

# フォルダ作成
make_directory_for_check_library()
{
	rm -rf $OBJECT_DIR/$g_root_dir/temp_dir_chk
	mkdir -p $OBJECT_DIR/$g_root_dir/temp_dir_chk
	cd $OBJECT_DIR/$g_root_dir/temp_dir_chk

	g_tree_level="../../../"
	execution_configure

	cd ../
	for g_dir_name in ${g_loop_dir_name[@]}
	do
		rm -rf $g_dir_name
		echo "$PRE_MAKE_DIRECTORY $g_dir_name $POST_MAKE_DIRECTORY"
		mkdir -p $g_dir_name
		cp -p temp_dir_chk/$MAKE_FILE_NAME ./$g_dir_name
		if [ "$USE_MULTI_CORE" == "false" ]
		then
			cp -p $AKTSP_DIR/library/$PROFILE_NAME/check_library/$LOWER_CASE_SC/$g_dir_name/out.* ./$g_dir_name
		else
			cp -p $AKTSP_DIR/library/$PROFILE_NAME/check_library/${LOWER_CASE_SC}-mc/$g_dir_name/out.* ./$g_dir_name
		fi
		cd $g_dir_name
		touch $RESULT_AKTG
		rename_scratch_program
		cd ../
	done
	rm -rf temp_dir_chk
	cd $AKTSP_DIR
}

# Makefileを用いる処理の実行
make_for_check_library()
{
	g_check_dir_name=$OBJECT_DIR/$g_root_dir/
	check_dir
	if [ $? -eq 0 ]
	then
		for g_dir_name in ${g_loop_dir_name[@]}
		do
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
			cd $OBJECT_DIR/$g_root_dir/
			make_for_no_manifest
		done
	fi
	cd $AKTSP_DIR
}

# フォルダ毎に実行
continuous_execute_for_check_library()
{
	rm -rf $OBJECT_DIR/$g_root_dir/temp_dir_chk
	mkdir -p $OBJECT_DIR/$g_root_dir/temp_dir_chk
	cd $OBJECT_DIR/$g_root_dir/temp_dir_chk

	g_tree_level="../../../"
	execution_configure

	cd ../
	for g_dir_name in ${g_loop_dir_name[@]}
	do
		rm -rf $g_dir_name
		# フォルダ作成
		echo "$PRE_MAKE_DIRECTORY $g_dir_name $POST_MAKE_DIRECTORY"
		mkdir -p $g_dir_name
		cp -p temp_dir_chk/$MAKE_FILE_NAME ./$g_dir_name
		if [ "$USE_MULTI_CORE" == "false" ]
		then
			cp -p $AKTSP_DIR/library/$PROFILE_NAME/check_library/$LOWER_CASE_SC/$g_dir_name/out.* ./$g_dir_name
		else
			cp -p $AKTSP_DIR/library/$PROFILE_NAME/check_library/${LOWER_CASE_SC}-mc/$g_dir_name/out.* ./$g_dir_name
		fi

		# make depend実行
		g_rule=$RULE_DEPEND
		cd $g_dir_name
		touch $RESULT_AKTG
		rename_scratch_program
		need_file_name
		check_file
		if [ $? -ne 1 ]
		then
			make_for_common

			# make実行
			if [ $? -eq 0 ]
			then
				g_rule=$RULE_BUILD
				make_for_common
				echo ""
			else
				echo "$ERR_DEPEND_FAIL "$g_dir_name
				echo ""
			fi
		fi
		cd ../
	done
	rm -rf temp_dir_chk
	cd $AKTSP_DIR
}

# 処理開始
check_library_main
