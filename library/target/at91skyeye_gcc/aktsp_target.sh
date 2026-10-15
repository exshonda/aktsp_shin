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
# $Id: aktsp_target.sh 347 2014-09-17 00:28:35Z fsi-dankei $
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
# コンフィギュレータへの追加オプション(必要な場合のみ)
# (-T, -A, -U, -a, -LはAKTSPで使用するため使用不可)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
CONFIG_OPT=

#
# メモリ保護テスト実行時に追加するアプリケーションプログラムファイル
# (.oファイル名で指定，SC3のみで使用)
#
TEST_LIB_FILE_FOR_MEMPRO=

#
# メモリ保護テスト実行時に追加するアプリケーションのディレクトリ名
# (SC3のみで使用)
#
INCLUDE_DIR_FOR_MEMPRO=

#
# make depend / make / make clean / make realclean の追加オプション(必要な場合のみ)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
MAKE_OPT=

#
# makeのみに付与するオプション(必要な場合のみ)
# (コーテーションを含むオプションは指定不可(例:"-d \"dir1 dir2\""))
#
ONLY_MAKE_OPT=

#
# make実行後に，実行モジュール実行に不要なファイル(*.oファイルなど)を削除するか
# [true: 削除する，false: 削除しない]
#
REMOVE_INTERMEDIATE_FILE=false

#
# 強制マージテストが実行可能か
# [true: 可能，false: 不可能]
#
ENABLE_FORCED_MARGE=true

#
# 実行モジュール名
#
MODULE_NAME="atk2-sc1.exe"

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
	# skyeyeの定義
	SKYEYE_EXE="skyeye.exe"
	SKYEYE_CONF="$OS_PATH/target/at91skyeye_gcc/skyeye.conf"

	# エラーメッセージ
	ERR_SKYEYE_PATH="Need to pass a path to skyeye"
	WAIT_COMPLETE_BUILD="waiting for complete to build..."

	# SkyEyeチェック
	which $SKYEYE_EXE &> /dev/null
	if [ $? -eq 1 ]
	then
		echo "$ERR_SKYEYE_PATH"
		return
	fi

	create_log_file

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

	skyeye_conf="$AKTSP_DIR/$SKYEYE_CONF"

	#script -c "$SKYEYE_EXE -c $skyeye_conf -e $MODULE_NAME" -a $RESULT_EXECUTE
	#sed -i "s/\r\r\n/\r\n/g" $RESULT_EXECUTE

	expect -c "
		set timeout -1
		spawn $SKYEYE_EXE -c $skyeye_conf -e $MODULE_NAME
		expect \"Kernel Exit...\"; send \"\003\n\"
	" | tee $RESULT_EXECUTE

	sleep 1
}

#
# 全分割フォルダ実行完了時のフック(ターゲット依存)
#
all_dir_finish_hook()
{
	return
}

# ログファイル生成
create_log_file()
{
	echo $SINGLE_LINE > $RESULT_EXECUTE
	echo $dir_name >> $RESULT_EXECUTE
	echo $SINGLE_LINE >> $RESULT_EXECUTE
}
