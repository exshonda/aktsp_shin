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
# $Id: single_tesry_common.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#
##### マージ不可能なTESRYデータ用のテスト共通処理 #####

# マージ不可能なTESRYデータ用のメニュー
single_tesry_menu()
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
			 g_mani_type=$MANI_ALL
			 make_manifest_for_tesry
			 ;;
			2)
			 header_double "$EXEC_3_6"
			 continuous_execute_for_single_tesry
			 ;;
			3)
			 header_double "$MNF_MAKE_DIR"
			 make_directory_for_single_tesry
			 ;;
			4)
			 header_double "$EXEC_AKTG"
			 execute_aktg_for_single_tesry
			 ;;
			5)
			 header_double "$MNF_MAKE_DEPEND"
			 g_rule=$RULE_DEPEND
			 make_for_single_tesry
			 ;;
			6)
			 header_double "$MNF_MAKE_BUILD"
			 g_rule=$RULE_BUILD
			 make_for_single_tesry
			 ;;
			7)
			 header_double "$MNF_MAKE_CLEAN"
			 g_rule=$RULE_CLEAN
			 make_for_single_tesry
			 ;;
			8)
			 header_double "$MNF_MAKE_REALCLEAN"
			 g_rule=$RULE_REALCLEAM
			 make_for_single_tesry
			 ;;
			s)
			 operate_spec_dir_for_single_tesry
			 ;;
			e)
			 header_double "$RUN_EXEC_MODULE"
			 execute_module_for_single_tesry
			 ;;
			m)
			 header_double "$MULTI_THREAD_EXEC_3_6"
			 multi_thread_execute_for_single_tesry 0
			 ;;
			p)
			 header_double "$PARALLEL_BUILD_AND_RUN"
			 multi_thread_execute_for_single_tesry 1
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
operate_spec_dir_for_single_tesry()
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
			 g_check_file_name=../$g_manifest_name
			 g_merge_flg=0
			 continuous_execute_in_operate_directory
			 ;;
			2)
			 header_double "$EXEC_AKTG"
			 g_check_file_name=../$g_manifest_name
			 g_merge_flg=0
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
			 g_kind="$OPERATE_SPEC_DIR"
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

# テスト用フォルダ作成
make_directory_for_single_tesry()
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
	exclusion_comment_out

	rm -rf $OBJECT_DIR/$g_root_dir/$g_pre_dir_name\_*/
	mkdir -p $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
	cd $OBJECT_DIR/$g_root_dir/$g_temp_dir_name

	execution_configure

	g_check_file_name=$MAKE_FILE_NAME
	check_file
	if [ $? -eq 1 ]
	then
		echo "$ERR_CREAT_MAKEFILE_FAIL"
		cd $AKTSP_DIR
		return
	fi

	cd $AKTSP_DIR/$OBJECT_DIR/$g_root_dir

	g_test_case_list_all=$g_test_case_list

	g_dir_num=0 # マルチスレッド実行で使用する変数
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			get_dir_name

			# フォルダ作成
			echo "$PRE_MAKE_DIRECTORY $g_dir_name $POST_MAKE_DIRECTORY"
			mkdir -p $g_dir_name &> /dev/null
			cp -p $g_temp_dir_name/$MAKE_FILE_NAME ./$g_dir_name
			g_dir_num=`expr $g_dir_num + 1`
		fi
	done

	rm -rf $g_temp_dir_name
	cd $AKTSP_DIR
}

# TESRYデータ1件毎にAKTG実行
execute_aktg_for_single_tesry()
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
	exclusion_comment_out

	g_check_dir_name=$OBJECT_DIR/$g_root_dir
	check_dir
	if [ $? -eq 1 ]
	then
		return
	fi
	cd $OBJECT_DIR/$g_root_dir
	g_test_case_list_all=$g_test_case_list
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			get_dir_name

			g_check_dir_name=$g_dir_name
			check_dir
			if [ $? -eq 1 ]
			then
				continue
			fi

			# AKTG実行
			cd $g_dir_name
			header_single "$AKTG_IN $g_dir_name"
			execute_aktg
			cd ../
		fi
	done
	cd $AKTSP_DIR
}

# TESRYデータ1件毎にフォルダ作成，AKTG，make depend，make実行
continuous_execute_for_single_tesry()
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
	exclusion_comment_out

	rm -rf $OBJECT_DIR/$g_root_dir/$g_pre_dir_name\_*/
	mkdir -p $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
	cd $OBJECT_DIR/$g_root_dir/$g_temp_dir_name

	execution_configure

	g_check_file_name=$MAKE_FILE_NAME
	check_file
	if [ $? -eq 1 ]
	then
		echo "$ERR_CREAT_MAKEFILE_FAIL"
		cd $AKTSP_DIR
		return
	fi

	cd ../

	g_test_case_list_all=$g_test_case_list
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			get_dir_name

			# フォルダ作成
			echo "$PRE_MAKE_DIRECTORY $g_dir_name $POST_MAKE_DIRECTORY"
			mkdir -p $g_dir_name  &> /dev/null
			cp -p $g_temp_dir_name/$MAKE_FILE_NAME ./$g_dir_name

			cd $g_dir_name
			# AKTG実行
			header_single "$AKTG_IN $g_dir_name"
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

			echo ""
			cd ../
		fi
	done

	cd $AKTSP_DIR
	rm -rf $OBJECT_DIR/$g_root_dir/$g_temp_dir_name
}

# 1件のみのTESRYデータでのMakefileを用いて行う処理(make depend, make, 
# make clean, make realclean)の実行
make_for_single_tesry()
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
	exclusion_comment_out

	cd $OBJECT_DIR/$g_root_dir

	g_test_case_list_all=$g_test_case_list
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			get_dir_name

			g_check_dir_name=$g_dir_name
			check_dir
			if [ $? -eq 1 ]
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
		fi
	done
	cd $AKTSP_DIR
}

# マルチスレッドでの実行
multi_thread_execute_for_single_tesry()
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
	exclusion_comment_out

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

	make_directory_for_single_tesry # g_test_case_listをg_test_case_list_allに代入

	# 引数が1の場合，ビルドと平行して実行も行う
	if [ $1 -eq 1 ]
	then
		cur_dir=`pwd`
		cygstart --shownoactivate sh "$cur_dir/scripts/common.sh PARALLEL_RUN_SINGLE $g_root_dir $g_manifest_name $g_test_case_list $g_dir_name $AKTSP_DIR $TARGET_NAME $SCALABILITY_CLASS $CORE_NUM $USE_MULTI_CORE"
	fi

	cnt=1
	for g_test_case_list in ${g_test_case_list_all[@]} # g_test_case_listは1件のテストケース
	do
		if [ -f $g_test_case_list ]
		then
			get_dir_name

			g_check_dir_name=$OBJECT_DIR/$g_root_dir/$g_dir_name
			check_dir
			if [ $? -eq 1 ]
			then
				continue
			fi

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
			cygstart $cyg_opt --shownoactivate sh "$cur_dir/scripts/single_tesry_common.sh MULTI_THREAD $g_root_dir $g_dir_name $g_test_case_list \"$g_aktg_opt\" $g_cmd_depend $g_cmd_all"
			cnt=`expr $cnt + 1`
			sleep 1
		fi
	done

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
		for g_test_case_list in ${g_test_case_list_all[@]}
		do
			if [ -f $g_test_case_list ]
			then
				g_test_num=`expr $g_test_num + 1`
				get_dir_name
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
				check_exec_success
				cd $AKTSP_DIR
			fi
		done

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
	g_dir_name=$3
	g_test_case_list=$4
	g_aktg_opt=$5
	g_cmd_depend=$6
	g_cmd_all=$7
	g_aktg_bin=`get_realpath ./$AKTG_BIN`
	curdir=`get_realpath ./`
	chk_err=0

	# 対象ディレクトリへ移動
	cd $OBJECT_DIR/$g_root_dir/$g_dir_name

	# ATKG実行
	header_single "$AKTG_IN $g_dir_name"
	execute_aktg
	if [ $? -ne 0 ]
	then
		exit
	fi

	# 以下のランタイムエラー対策(at91skyeye_gcc用コンパイラのみで発生)
	# This application has requested the Runtime to terminate it in an unusual way.
	# Please contact the application's support team for more information.
	if [ $TARGET_NAME == "at91skyeye_gcc" ]
	then
		apl_file=`echo $APPLI_NAME".c"`
		arm-none-eabi-gcc -c $apl_file &> /dev/null
		if [ $? -eq 3 ]
		then
			chk_err=1
			tmp_dir_name=`basename $g_dir_name`
			mkdir $curdir/$tmp_dir_name
		fi
	fi

	# make depend実行
	header_single "$MAKE_DEPEND $g_dir_name"
	g_rule=$RULE_DEPEND
	make_for_common
	if [ $? -ne 0 ]
	then
		exit
	fi
	sleep 2

	# make実行
	header_single "$MAKE_BUILD $g_dir_name"
	g_rule=$RULE_BUILD
	make_for_common

	# ランタイムエラー対策
	if [ $chk_err -eq 1 ]
	then
		rm -rf $curdir/$tmp_dir_name
	fi

	sleep 3
	exit
fi
