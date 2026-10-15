#!/bin/sh
#
# AKTM
#      Automotive Kernel Test Manager
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
# $Id: grep_specid_tcs.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# 仕様ID毎にTCS内からgrepしてまとめる
# --------------------------------------------------------------------
# $Id: grep_specid_tcs.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#=====================================================================

# 結果出力フォルダ初期化
RESULT_DIR=result2
if [ -d $RESULT_DIR ]
then
	rm -f $RESULT_DIR/*
else
	mkdir $RESULT_DIR
fi

# 仕様IDリスト
SPEC_ID_LIST=`cat ./spec_id/data/target_id_tcs.txt`

# 対象ディレクトリ
CHECK_PATH="../../syssrv_test/sc1"

# システムサービス名でソートしたTCSファイルへのパス
CHECK_FILES=`find $CHECK_PATH -name "*.csv" -print | awk -F '/' '{print $7":::"$1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7}' | sort | awk -F ':::' '{print $2}'`

exec_grep()
{
	echo $SPEC_ID

	chkflg=0
	for csv in ${CHECK_FILES[@]};
	do
		# システムサービス名
		ss_name=`basename $csv|sed -e s/"\.csv"//`

		# 出力ファイル名
		csv_name="./$RESULT_DIR/$SPEC_ID.csv"

		# テストケース数
		tc_cnt=`cat $csv | wc -l`
		tc_cnt=`expr $tc_cnt - 1`

		# 対象テストケース数取得
		hit_cnt=`grep $SPEC_ID_GREP $csv | wc -l`

		# 対象テストケースなし
		if [ $hit_cnt == 0 ]
		then
			continue
		# 全件が対象
		elif [ $tc_cnt == $hit_cnt ]
		then
			echo "" >> $csv_name
			echo "$ss_name" >> $csv_name
			echo "$SPEC_ID is included in all test case." >> $csv_name
			chkflg=1
		# 特定のテストケースが対象
		else
			echo "" >> $csv_name
			echo "$ss_name" >> $csv_name
			head -n 1 $csv | sed -e s/",TESRY_param"// >> $csv_name
			grep $SPEC_ID_GREP $csv | sed -e s/",\".*\""// >> $csv_name
			chkflg=1
		fi
	done
	if [ $chkflg == 1 ]
	then
		echo "" >> $csv_name
	fi
}

for specid in ${SPEC_ID_LIST[@]};
do
	# チェック仕様タグ
	SPEC_ID=`echo $specid`
	SPEC_ID_GREP=`echo ","$specid","`

	# 実行
	exec_grep
done

