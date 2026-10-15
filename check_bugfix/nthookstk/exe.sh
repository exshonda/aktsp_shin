#!/bin/sh
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
# $Id: exe.sh 347 2014-09-17 00:28:35Z fsi-dankei $
#

LOWER_CASE_SC="sc3"
AKTSP_DIR="../.."
source $AKTSP_DIR/configure.sh
source $AKTSP_DIR/scripts/common.sh
source $AKTSP_DIR/library/target/nios2_dev_gcc/aktsp_target.sh

LOG_FILE="test_execute.log"

SP="@@@"

COND1="coreid_number coreid_macro"
COND2="hook_not_exist_core0${SP}hook_not_exist_core1 hook_exist_core0${SP}hook_not_exist_core1 hook_not_exist_core0${SP}hook_exist_core1 hook_exist_core0${SP}hook_exist_core1"
COND3="${SP} hook_stack_size_core0    hook_stack_size_core1    hook_stack_size_core0${SP}hook_stack_size_core1"
COND4="${SP} hook_stack_address_core0 hook_stack_address_core1 hook_stack_address_core0${SP}hook_stack_address_core1"

rm -f $LOG_FILE
rm -f Makefile*
$AKTSP_DIR/../configure -h -T nios2_dev_gcc -U "aktsp_common_lib.o aktsp_implement_lib.o aktsp_target_lib.o" -a "\$(SRCDIR)/aktsp/library/common \$(SRCDIR)/aktsp/library/implement/atk2 \$(SRCDIR)/aktsp/library/target/nios2_dev_gcc" -A out -O -DOTHER_PRC_SVC_TABLE=aktsp_add_syssrv.h

g_cmd_depend="depend"
cnt=0
for cond1 in ${COND1[@]};
do
	for cond2 in ${COND2[@]};
	do
		for cond3 in ${COND3[@]};
		do
			for cond4 in ${COND4[@]};
			do
				# サイズ指定がある場合のみ，アドレスも指定可能
				tmp=`echo $cond4 | sed -e s/hook_stack_address/hook_stack_size/g`
				chk=`echo $cond3 | grep $tmp | wc -l`
				if [ $chk -eq 1 ] || [ "$cond4" == "$SP" ]
				then
					cnt=`expr $cnt + 1`
					all_cond=`echo $cond1 $cond2 $cond3 $cond4 | sed -e s/"@@@"/" "/g`

					# スタック指定コンテナ用コアIDもマクロと整数を切り替え
					for coreid in 0 1
					do
						chk=`echo $all_cond | grep -e hook_stack_size_core$coreid -e hook_stack_address_core$coreid | wc -l`
						if [ $chk -eq 1 ]
						then
							if [ $cond1 == "coreid_number" ]
							then
								all_cond=`echo "$all_cond hook_stack_coreid_number_core$coreid"`
							else
								all_cond=`echo "$all_cond hook_stack_coreid_macro_core$coreid"`
							fi
						fi
					done

					#echo "$cnt: $all_cond"

					# .yaml拡張子を付与
					arg_yamls=""
					for file in ${all_cond[@]};
					do
						arg_yamls=`echo "$arg_yamls $file.yaml"`
					done

					# arxml作成
					ruby $AKTSP_DIR/../utils/abrex/abrex.rb out.yaml $arg_yamls

					echo $DOUBLE_LINE >> $LOG_FILE
					echo "$cnt: $arg_yamls" >> $LOG_FILE
					echo $SINGLE_LINE >> $LOG_FILE
					echo "$cnt: $arg_yamls"

					make realclean
					make depend SERIAL_UART=true
					make SERIAL_UART=true
					simulation

					cat result_execute_core*.log >> $LOG_FILE
					grep -i -e NTHKSTK -e nhstack Os_Lcfg.c >> $LOG_FILE
				fi
			done
		done
	done
done
