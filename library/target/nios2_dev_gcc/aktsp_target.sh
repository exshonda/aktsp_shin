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
# $Id: aktsp_target.sh 1961 2015-07-10 05:06:18Z t_ishikawa $
#

#
# アプリケーション名
#
APPLI_NAME="out"

#
# アーキテクチャフォルダ(aktsp/library/arch配下の使用するフォルダ)の定義
# (必要な場合のみ)
# (複数指定可能，複数指定する場合はスペースで区切る)
#  例) "arm_gcc/mpcore arm_gcc/common"
#
ARCH_PATH=

#
# ターゲット依存APIの有無
# [true: 有り，false: 無し]
#
FUNC_INTERRUPT="true"			# 割込み発生関数
FUNC_HARDWARE_COUNTER="true"	# ハードウェアカウンタ操作関数
FUNC_PROTECTION_HOOK="true"		# プロテクションフック起動関数

#
# AKTGへの追加オプション
# (-c，--scalability_class，--core_num，--use_multi_core，
#  --func_interrupt，--func_hardware_counter，--func_protection_hook，
#  --out_file_nameは使用不可．詳細はaktsp/user.txtを参照)
#
AKTG_OPT=

#
# ジェネレータへの追加オプション(必要な場合のみ)
# (-T, -A, -U, -a, -L, -oはAKTSPで使用するため使用不可)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
if [ $SCALABILITY_CLASS == "SC1" ]
then
	CONFIG_OPT=
elif [ $SCALABILITY_CLASS == "SC3" ]
then
	CONFIG_OPT="-O -DOTHER_PRC_SVC_TABLE=aktsp_add_syssrv.h"
fi

#
# ジェネレータへの追加オプション(-o 共通コンパイルオプションのみ)
# 配列で定義する
#
CONFIG_OPT_O="-DINTPRI_ICI0=3 -DINTPRI_ICI1=3"

#
# メモリ保護テスト実行時に追加するアプリケーションプログラムファイル
# (.oファイル名で指定，SC3のみで使用)
#
TEST_LIB_FILE_FOR_MEMPRO="aktsp_target_lib_mem.o nt_osap1.o nt_osap1_share.o nt_osap2.o nt_osap2_share.o common.o t_osap1.o t_osap1_share.o"

#
# メモリ保護テスト実行時に追加するアプリケーションのディレクトリパス
# (AKTSPディレクトリからの相対パス／SC3のみで使用)
#
INCLUDE_DIR_FOR_MEMPRO=`echo '/library/target/'$TARGET_NAME'/memory_protection'`

#
# make depend / make / make clean / make realclean の追加オプション(必要な場合のみ)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
MAKE_OPT="SERIAL_UART=false"

#
# makeのみに付与するオプション(必要な場合のみ)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
ONLY_MAKE_OPT=

#
# make実行後に，実行モジュール実行に不要なファイル(*.oファイルなど)を削除するか
# [true: 削除する，false: 削除しない]
#
REMOVE_INTERMEDIATE_FILE=true

#
# 強制マージテストが実行可能か
# [true: 可能，false: 不可能]
#
ENABLE_FORCED_MARGE=true

#
# 実行モジュール名
#
if [ "$USE_MULTI_CORE" == "false" ]
then
	MODULE_NAME="atk2-$LOWER_CASE_SC.srec"
elif [ "$USE_MULTI_CORE" == "true" ]
then
	MODULE_NAME="atk2-$LOWER_CASE_SC-mc.srec"
fi

#
# 実行モジュールの実行をシェルスクリプトで実装済みか
# [true : 実装済み，false : 実装していない]
# (trueの場合，aktb.shの"e: Run executable module (Target Dependent)"を
#  選択すると，以下の関数simulation()が実行される)
#
EXC_MODULE="true"

#
# 実行モジュールの実行(ターゲット依存)
# (EXC_MODULEがtrueの場合に実行される)
#
simulation()
{
	# エラーメッセージ
	WAIT_COMPLETE_BUILD="waiting for complete to build..."

	# 実行モジュールチェック
	while true
	do
		if [ -f $MODULE_NAME ]
		then
			# 実行ファイルがある場合，処理を続行
			sleep 2
			break
		else
			sleep 1
			# 実行ファイルが無い場合，make終了ファイルをチェック
			if [ -f $FINISH_MAKE_FLG ]
			then
				sleep 1
				# make終了ファイルが存在するのに実行モジュールが存在しない場合はビルドエラー
				if [ -f $MODULE_NAME ]
				then
					# この時点で実行ファイルがある場合，処理を続行
					sleep 1
					break
				else
					g_check_file_name=$MODULE_NAME
					check_file | tee -a $RESULT_EXECUTE
					return
				fi
			else
				echo "$WAIT_COMPLETE_BUILD"
				sleep 5
			fi
		fi
	done

	# マスタコアのみ起動するテストの場合，コア数を1へ変更する
	if [ "$g_manifest_name" == "$MNF_BOOT_ONLY_MASTER_CORE" ] || [ "$g_manifest_name" == "$MNF_ICISR_ATYPICAL_SYSSRV_TESRY" ]
	then
		saved_core_num=$CORE_NUM
		CORE_NUM=1
	fi

	if [ $CORE_NUM -eq 1 ]
	then
		inst=""
		if [ "$USE_MULTI_CORE" == "true" ]
		then
			inst="--instance=0"
		fi

		# UARTとJTAG-UARTで実行処理を切り替え
		chk=`echo $MAKE_OPT | grep "SERIAL_UART=true" | wc -l`
		if [ $chk -eq 1 ]
		then
			# シリアル受信待機前に実行を開始しないよう，遅延してロードする
			cygstart --shownoactivate nios2-gdb-server.exe --cable=USB-Blaster $inst --no-verify -r --go --wait 2 $MODULE_NAME &
			sleep 1

			# teeだとログ受信が遅延したためscriptを使用する
			script -c "ruby $AKTSP_DIR/$OS_PATH/target/nios2_dev_gcc/com_port.rb" $RESULT_EXECUTE
			grep --text -v "Script started on" $RESULT_EXECUTE > ./tmp
			grep --text -v "Script done" ./tmp > $RESULT_EXECUTE
		else
			nios2-gdb-server.exe --cable=USB-Blaster $inst --no-verify -r --go $MODULE_NAME
			expect -c "
				set timeout -1
				spawn nios2-terminal --cable=USB-Blaster $inst -q
				expect \"Kernel Exit...\"; send \"\003\n\"
			" | tee $RESULT_EXECUTE
		fi

		sleep 1
	else
		# 各コア実行用スクリプト生成
		num=0
		# UARTとJTAG-UARTで実行処理を切り替え
		chk=`echo $MAKE_OPT | grep "SERIAL_UART=true" | wc -l`
		while [ $num -lt $CORE_NUM ]
		do
			sh_file="aktb_core${num}.sh"

			if [ $chk -eq 1 ]
			then
				echo 'script -c "ruby '$AKTSP_DIR'/'$OS_PATH'/target/nios2_dev_gcc/com_port.rb '$num' true" '$RESULT_EXECUTE_MC$num'.log' > $sh_file
				echo 'grep --text -v "Script started on" '$RESULT_EXECUTE_MC$num'.log > temp'$num >> $sh_file
				echo 'grep --text -v "Script done" temp'$num' > '$RESULT_EXECUTE_MC$num'.log' >> $sh_file
				echo 'rm -f temp'$num >> $sh_file
			else
				echo 'expect -c "' > $sh_file
				echo '	set timeout -1' >> $sh_file
				echo '	spawn nios2-terminal --cable=USB-Blaster --instance='$num >> $sh_file
				echo '	expect \"Kernel Exit...\"; send \"\003\n\"' >> $sh_file
				echo '" | tee '$RESULT_EXECUTE_MC$num'.log' >> $sh_file
			fi

			num=`expr $num + 1`
		done

		# 各コアへ実行モジュールロード
		num=0
		while [ $num -lt $CORE_NUM ]
		do
			mod=""
			reset=""
			if [ $num -eq 0 ]
			then
				mod="$MODULE_NAME"
			fi
			if [ $num -eq 0 ] || [ $chk -ne 1 ]
			then
				reset="-r"
			fi

			nios2-gdb-server --cable=USB-Blaster --instance=$num --no-verify $reset --stop $mod

			num=`expr $num + 1`
		done

		# 各コアへgoコマンド
		num=0
		max_id=`expr $CORE_NUM - 1`
		while [ $num -lt $CORE_NUM ]
		do
			# UARTとJTAG-UARTで実行処理を切り替え
			if [ $chk -eq 1 ]
			then
				reset=""
				if [ $num -eq $max_id ]
				then
					reset="-r"
				fi
				# シリアル受信待機前に実行を開始しないよう，遅延してロードする
				cygstart --shownoactivate nios2-gdb-server.exe --cable=USB-Blaster --wait 2 --instance=$num $reset --no-verify --go &
			else
				nios2-gdb-server --cable=USB-Blaster --instance=$num --no-verify --go
			fi

			num=`expr $num + 1`
		done

		# 各コアのターミナルを起動
		num=$CORE_NUM
		while [ $num -ge 0 ]
		do
			wait=""
			bg="&"
			if [ $num -eq 0 ]
			then
				wait="-w"
				bg=""
			fi

			sh_file="aktb_core${num}.sh"
			cygstart $wait --shownoactivate sh $sh_file $bg

			num=`expr $num - 1`
		done

		sleep 2

		# 確認のために，ログを表示する
		num=0
		while [ $num -lt $CORE_NUM ]
		do
			echo '=== '$RESULT_EXECUTE_MC$num'.log ==='
			cat $RESULT_EXECUTE_MC$num'.log'

			num=`expr $num + 1`
		done

		# 各スクリプト削除
		rm -f aktb_core*.sh
		rm -f ./tmp
	fi

	# プロセスが残っている場合強制終了
	chk_cnt=0
	while [ 1 ]
	do
		num=`ps ax | grep "nios2-terminal" | awk -F ' ' '{print $4}' | head -n 1`
		expr 1 + $num >/dev/null 2>&1
		if [ $? -ge 2 ]
		then
			break
		else
			sleep 1
			chk_cnt=`expr 1 + $chk_cnt`
			if [ $chk_cnt -eq 5 ]
			then
				echo "kill nios2-terminal !!"
				/usr/bin/kill -9 -f $num
				break
			fi
		fi
	done

	# マスタコアのみ起動するテストの場合，コア数を元へ戻す
	if [ "$g_manifest_name" == "$MNF_BOOT_ONLY_MASTER_CORE" ] || [ "$g_manifest_name" == "$MNF_ICISR_ATYPICAL_SYSSRV_TESRY" ]
	then
		CORE_NUM=$saved_core_num
	fi

	# C++testのカバレッジを取得する場合，不要な情報を削除したテキストファイルを作成する
	chk=`echo $MAKE_OPT | grep "USE_CPPTEST" | wc -l`
	if [ $chk -eq 1 ]
	then
		grep CLOG: $RESULT_EXECUTE | sed -e "1d" | sed -e 's/^CLOG: //' > temp.clog
	fi
}

#
# 全分割フォルダ実行完了時のフック(ターゲット依存)
#
all_dir_finish_hook()
{
	return
}
