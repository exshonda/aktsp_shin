#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
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
# $Id: aktsp_cx_target.sh 250 2014-08-05 04:53:25Z ksigihar $
#

#
# アプリケーション名
#
APPLI_NAME="out"

#
# ターゲット依存APIの有無
# [true: 有り，false: 無し]
#
FUNC_INTERRUPT="true"			# 割込み発生関数
FUNC_HARDWARE_COUNTER="true"	# ハードウェアカウンタ操作関数
FUNC_PROTECTION_HOOK="true"		# プロテクションフック起動関数

#
# AKTGへの追加オプション
# (-c，-x，--scalability_class，--core_num，--use_multi_core，
#  --func_interrupt，--func_hardware_counter，--func_protection_hook，
#  --out_file_nameは使用不可．詳細はaktsp/user.txtを参照)
#
AKTG_OPT=

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
MODULE_NAME="./DefaultBuild/atk2-sc1.$MODULE_EXTENSION"

#
# CS+の実行ファイルパス
#
CS_PATH="/cygdrive/c/Program\ Files/Renesas\ Electronics/CS+/$CS_TYPE":"/cygdrive/c/Program\ Files\ \(x86\)/Renesas\ Electronics/CS+/$CS_TYPE"

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
	# ビルド，実行用ファイルコピー
	if [ "$CS_TYPE" == "CACX" ]
	then
		cp -rp $AKTSP_DIR/library/arch/v850/cx/CubeSuiteFiles/* .
	elif [ "$CS_TYPE" == "CC" ]
	then
		cp -rp $AKTSP_DIR/library/arch/v850/ccrh/CubeSuiteFiles/* .
	fi

	# 実行フォルダの深さに合わせて各ファイル中のパスを修正
	atk2_win_path=`echo $g_tree_level/$OS_PATH | sed -e "s/\\//\\\\\\\\\\\\\\\/g"`
	atk2_cyg_path=`echo $g_tree_level/$OS_PATH | sed -e "s/\\//\\\\\\\\\//g"`
	aktsp_win_path=`echo $g_tree_level | sed -e "s/\\//\\\\\\\\\\\\\\\/g"`

	sed -i -e "s/ATK2_PATH_CYGWIN/$atk2_cyg_path/g" ./atk2-sc1.mtpj
	sed -i -e "s/ATK2_PATH_WINDOWS/$atk2_win_path/g" ./atk2-sc1.mtpj
	sed -i -e "s/AKTSP_PATH_WINDOWS/$aktsp_win_path/g" ./atk2-sc1.mtpj

	sed -i -e "s/ATK2_PATH_CYGWIN/$atk2_cyg_path/g" ./cfg/cfg.mtsp
	sed -i -e "s/ATK2_PATH_WINDOWS/$atk2_win_path/g" ./cfg/cfg.mtsp
	sed -i -e "s/AKTSP_PATH_WINDOWS/$aktsp_win_path/g" ./cfg/cfg.mtsp

	sed -i -e "s/ATK2_PATH_WINDOWS/$atk2_win_path/g" ./kernel/kernel.mtsp
	sed -i -e "s/AKTSP_PATH_WINDOWS/$aktsp_win_path/g" ./kernel/kernel.mtsp

	sed -i -e "s/ATK2_PATH_CYGWIN/$atk2_cyg_path/g" ./def.py

	# 強制マージの場合，マクロを追加定義
	if [ $g_force_merge_flg -ne 0 ]
	then
		sed -i -e s/TOPPERS_LABEL_ASM/TOPPERS_LABEL_ASM\\nENABLE_RETURN_MAIN/g ./kernel/kernel.mtsp
	fi

	# ターゲットボード名称指定
	BOARD_NAME=`echo $TARGET_NAME | awk -F '_' '{print $1}'`
	sed -i -e "s/AKTSP_BOARD_NAME/$BOARD_NAME/g" ./atk2-sc1.mtpj
	sed -i -e "s/AKTSP_BOARD_NAME/$BOARD_NAME/g" ./cfg/cfg.mtsp
	sed -i -e "s/AKTSP_BOARD_NAME/$BOARD_NAME/g" ./kernel/kernel.mtsp
	sed -i -e "s/AKTSP_BOARD_NAME/$BOARD_NAME/g" ./def.py

	# hsbrh850f1lのINTRAMの開始位置を変更
	if [ "$BOARD_NAME" == "hsbrh850f1l" ]
	then
		sed -i -e "s/.stack.bss\/FEDE0000<\/LinkOptionStart-0/.stack.bss\/FEDE8000<\/LinkOptionStart-0/g" ./atk2-sc1.mtpj
	fi

	# uPD70F3550はエミュレータから電源供給する
	if [ "$MCU" == "uPD70F3550" ]
	then
		sed -i -e "s/TargetSupplyPower>No<\/DebuggerProperty/TargetSupplyPower>Yes<\/DebuggerProperty/g" ./atk2-sc1.mtpj
	fi
	sed -i -e "s/AKTSP_MODEL_NO/$MCU/g" ./atk2-sc1.mtpj
	sed -i -e "s/AKTSP_MODEL_NO/$MCU/g" ./cfg/cfg.mtsp
	sed -i -e "s/AKTSP_MODEL_NO/$MCU/g" ./kernel/kernel.mtsp
	sed -i -e "s/AKTSP_MODEL_NO/$MCU/g" ./def.py

	cur=`cygpath -w $PWD`

	scr=`echo "${cur}\run.py"`

	prj=`echo "${cur}\atk2-sc1.mtpj"`

	echo "export PATH=\$PATH:$CS_PATH" > temp.sh
	echo "CubeSuite+.exe /ps \"$scr\" \"$prj\" | tee result_build.log | nkf -u" >> temp.sh
	cygstart --shownoactivate sh temp.sh &

	b_cnt=100
	while true
	do
		if [ -f $MODULE_NAME ]
		then
			ruby $AKTSP_DIR/library/arch/v850/common/com_port.rb $RESULT_EXECUTE
			break
		else
			sleep 1
			echo "waiting for complete to build... $b_cnt"
			if [ $b_cnt -lt 0 ]
			then
				g_check_file_name=$MODULE_NAME
				check_file | tee -a $RESULT_EXECUTE
				break
			fi
			b_cnt=`expr $b_cnt - 1`
		fi
	done

	sleep 1

	chk=`ps ax | grep CubeSuite | wc -l`
	if [ $chk -eq 1 ]
	then
		kill -9 `ps ax | grep CubeSuite | awk -F ' ' '{print $1}'`
	fi
}

#
# 全分割フォルダ実行完了時のフック(ターゲット依存)
#
all_dir_finish_hook()
{
	return
}
