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
# $Id: count_tesry_data.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

# チェック対象パス
this_sh_name=`basename $0`
this_sh_dir=`echo $0 | sed -e s/$this_sh_name//`
CHECK_PATH="${this_sh_dir}../obj/tesry"

# パス存在チェック
if [ -d $CHECK_PATH ]
then
	:
else
	echo "folder not found [$CHECK_PATH]"
	exit 2
fi

TARGET_DIR=`ls -1 $CHECK_PATH | grep -v -e protection_test -e error_test | xargs`

if [ -d $CHECK_PATH/error_test ]
then
	temp=`ls -1 $CHECK_PATH/error_test | awk -F ' ' '{print "error_test/"$1}' | xargs`
	TARGET_DIR="$TARGET_DIR $temp"
fi

if [ -d $CHECK_PATH/protection_test ]
then
	temp=`ls -1 $CHECK_PATH/protection_test | awk -F ' ' '{print "protection_test/"$1}' | xargs`
	TARGET_DIR="$TARGET_DIR $temp"
fi

mem_cnt=0
err_cnt=0
total=0
for dir in ${TARGET_DIR[@]};
do
	cnt=`find $CHECK_PATH/$dir -name "*.yaml" -print | wc -l`
	echo "$dir: $cnt"

	total=`expr $total + $cnt`

	# エラー処理の合計値を算出する
	chk=`echo $dir | grep error_test_ | wc -l`
	if [ $chk -eq 1 ]
	then
		err_cnt=`expr $err_cnt + $cnt`
	fi

	# メモリ保護の合計値を算出する
	chk=`echo $dir | grep memory_protection_ | wc -l`
	if [ $chk -eq 1 ]
	then
		mem_cnt=`expr $mem_cnt + $cnt`
	fi
done

echo "----"
echo "total: $total"

if [ $err_cnt -ne 0 ]
then
	echo "----"
	echo "error_test_*: $err_cnt"
fi

if [ $mem_cnt -ne 0 ]
then
	echo "----"
	echo "memory_protection_*: $mem_cnt"
fi
