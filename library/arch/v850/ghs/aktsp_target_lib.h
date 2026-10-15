/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2016 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2011-2013 by Spansion LLC, USA
 *  Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
 *  Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2011-2014 by Witz Corporation, JAPAN
 *
 *  本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
 *  関するコンソーシアム型共同研究において開発したものである．
 *  本ソフトウェアの著作権は，上記の著作権者に帰属する．
 *
 *  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *  $Id: aktsp_target_lib.h 49 2014-06-17 02:51:42Z ksigihar $
 */

#ifndef TOPPERS_AKTSP_TARGET_LIB_H
#define TOPPERS_AKTSP_TARGET_LIB_H

/********************************************************************

  ターゲット依存テストライブラリ(v850e2/ghs)

 ********************************************************************/

#include "aktsp_target_common_lib.h"

asm void set_sp(uint8* stk)
{
%reg stk
	  mov stk, sp
}

#define AKTSP_SHIFT_SP	set_sp(stk)
#define SYNC_MEMORY Asm("syncm")

/*
 *  SC3-MCのスタックモニタリングテストで使用する
 */
/*
 *  スタックポインタ方式で，スタックオーバーフローが検出される
 *  状態にする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_SET_STACK_OVERFLOW_S(stk, sz) set_sp(stk)

/*
 *  CheckTask(ISR)MemoryAccessがE_OS_ILLEGAL_ADDRESSを返すための
 *  メモリ領域指定
 */
#ifndef AKTG_CORE_NUM
#define AKTSP_ILLEGAL_MEMORY_ADDRESS   (aktg_ustack[0] - 4U)
#else /* AKTG_CORE_NUM */
#define AKTSP_ILLEGAL_MEMORY_ADDRESS   (aktg_ustack_core0[0] - 4U)
#endif /* AKTG_CORE_NUM */
#define AKTSP_ILLEGAL_MEMORY_SIZE      8U

/*
 *  スタックポインタ方式により，スタックオーバーフローを発生させて
 *  即returnする処理(引数にスタックの先頭番地，サイズを与える)
 */
extern uint8 *aktg_temp_stk;
#ifdef CFG_USE_SCALABILITYCLASS1
#define AKTSP_RETURN_IN_STACK_OVERFLOW_S(stk, sz)				\
	aktg_temp_stk = stk;										\
	/* レジスタは破壊されても問題ない */						\
	Asm("mov  _aktg_temp_stk, r11");							\
	Asm("ld.w 0[r11], r11");									\
	Asm("mov r11, sp");											\
	/* テスト対象はタスクのみなのでexit_taskへジャンプする */	\
	Asm("br  _exit_task");
#endif /* CFG_USE_SCALABILITYCLASS1 */
#ifdef CFG_USE_SCALABILITYCLASS3
#define AKTSP_RETURN_IN_STACK_OVERFLOW_S(stk, sz)				\
	aktg_temp_stk = stk;										\
	/* レジスタは破壊されても問題ない */						\
	Asm("mov  _aktg_temp_stk, r11");							\
	Asm("ld.w 0[r11], r11");									\
	Asm("mov r11, sp");											\
	/* テスト対象はタスクのみなので__kernel_exit_taskへジャンプする */	\
	Asm("br  __kernel_exit_task");
#endif /* CFG_USE_SCALABILITYCLASS3 */


/*
 *  マジックナンバー方式により，スタックオーバーフローを発生させて
 *  即returnする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_RETURN_IN_STACK_OVERFLOW_M(stk, sz)	\
	stk[0] = (uint8)~(stk[0]);						\
	return;

#ifndef AKTG_CORE_NUM

/*
 *  C1ISR出入り口処理(シングルコア用)
 *  ※レジスタ退避等の処理を行い，EntityFuncNameを呼出し，
 *    レジスタを復帰する
 *  ※関数名はカーネルのC1ISRで提供されるマクロのによる
 *    変換後の名前と一致するように定義する
 */
#define AKTSP_C1ISR_ENTRY(C1ISRName, EntityFuncName)		\
	void C1ISRMain ## C1ISRName(void) {									\
		/* 戻り番地をデクリメント */									\
		Asm("addi    -80, sp,  sp");									\
		/* レジスタの保存 */											\
		Asm("st.w    ep,  12[sp]");										\
		Asm("mov     sp,  ep");											\
		Asm("sst.w   r1,  72[ep]");										\
		Asm("sst.w   r6,  68[ep]");										\
		Asm("sst.w   r7,  64[ep]");										\
		Asm("sst.w   r8,  60[ep]");										\
		Asm("sst.w   r9,  56[ep]");										\
		Asm("sst.w   r10, 52[ep]");										\
		Asm("sst.w   r11, 48[ep]");										\
		Asm("sst.w   r12, 44[ep]");										\
		Asm("sst.w   r13, 40[ep]");										\
		Asm("sst.w   r14, 36[ep]");										\
		Asm("sst.w   r15, 32[ep]");										\
		Asm("sst.w   r16, 28[ep]");										\
		Asm("sst.w   r17, 24[ep]");										\
		Asm("sst.w   r18, 20[ep]");										\
		Asm("sst.w   r19, 16[ep]");										\
		Asm("sst.w   r31, 8[ep]");										\
		/* 多重割込みのため，現在のEIPCとEIPSWを保存 */					\
		Asm("stsr    eipc,  r6");										\
		Asm("sst.w   r6,    4[ep]");									\
		Asm("stsr    eipsw, r6");										\
		Asm("sst.w   r6,    0[ep]");									\
		Asm("ei");														\
		/* 割込み発生前のcallevel_statをスタックに保存 */				\
		Asm("mov     _callevel_stat, r6");								\
		Asm("ld.h    0[r6], r7");										\
		Asm("sst.w   r7, 76[ep]");										\
		/* callevel_statにC1ISRをORでセット */							\
		Asm("mov     0x8000, r8");										\
		Asm("or      r8, r7");											\
		Asm("st.h    r7, 0[r6]");										\
		/* C1ISRで実行するC言語関数の呼び出し */						\
		Asm("jarl _"# EntityFuncName ", r31");							\
		Asm("di");														\
		/* レジスタの復帰 */											\
		Asm("mov     sp, ep");											\
		/* 保存したcallevel_statを復帰 */								\
		Asm("mov     _callevel_stat, r6");						\
		Asm("sld.w    76[ep], r7");										\
		Asm("st.h    r7, 0[r6]");										\
		Asm("sld.w    4[ep], r10");										\
		Asm("ldsr    r10, eipc");										\
		Asm("sld.w   0[ep], r10");										\
		Asm("ldsr    r10, eipsw");										\
		Asm("sld.w   72[ep], r1");										\
		Asm("sld.w   68[ep], r6");										\
		Asm("sld.w   64[ep], r7");										\
		Asm("sld.w   60[ep], r8");										\
		Asm("sld.w   56[ep], r9");										\
		Asm("sld.w   52[ep], r10");										\
		Asm("sld.w   48[ep], r11");										\
		Asm("sld.w   44[ep], r12");										\
		Asm("sld.w   40[ep], r13");										\
		Asm("sld.w   36[ep], r14");										\
		Asm("sld.w   32[ep], r15");										\
		Asm("sld.w   28[ep], r16");										\
		Asm("sld.w   24[ep], r17");										\
		Asm("sld.w   20[ep], r18");										\
		Asm("sld.w   16[ep], r19");										\
		Asm("sld.w    8[ep], r31");										\
		Asm("addi    80, ep, sp");										\
		Asm("sld.w   12[ep], r30");										\
		Asm("eiret");													\
}

#else /* AKTG_CORE_NUM */

/*
 *  C1ISR出入り口処理(マルチコア用)
 *  ※シングルコア用の処理に加え，コア毎のcallevel_statを操作する
 */
#define AKTSP_C1ISR_ENTRY(C1ISRName, EntityFuncName)	  \
	void C1ISRMain ## C1ISRName(void) {					  \
		/* 戻り番地をデクリメント */					  \
		Asm("addi    -80, sp,  sp");					  \
		/* レジスタの保存 */							  \
		Asm("st.w    ep,  12[sp]");						  \
		Asm("mov     sp,  ep");							  \
		Asm("sst.w   r1,  76[ep]");						  \
		Asm("sst.w   r5,  72[ep]");						  \
		Asm("sst.w   r6,  68[ep]");						  \
		Asm("sst.w   r7,  64[ep]");						  \
		Asm("sst.w   r8,  60[ep]");						  \
		Asm("sst.w   r9,  56[ep]");						  \
		Asm("sst.w   r10, 52[ep]");						  \
		Asm("sst.w   r11, 48[ep]");						  \
		Asm("sst.w   r12, 44[ep]");						  \
		Asm("sst.w   r13, 40[ep]");						  \
		Asm("sst.w   r14, 36[ep]");						  \
		Asm("sst.w   r15, 32[ep]");						  \
		Asm("sst.w   r16, 28[ep]");						  \
		Asm("sst.w   r17, 24[ep]");						  \
		Asm("sst.w   r18, 20[ep]");						  \
		Asm("sst.w   r19, 16[ep]");						  \
		Asm("sst.w   r31, 8[ep]");						  \
		/* 多重割込みのため，現在のEIPCとEIPSWを保存 */	  \
		Asm("stsr    eipc,  r6");						  \
		Asm("sst.w   r6,    4[ep]");					  \
		Asm("stsr    eipsw, r6");						  \
		Asm("sst.w   r6,    0[ep]");					  \
		Asm("ei");										  \
		/* コアID取得 */								  \
		Asm("stsr    0,  r16, 2");						  \
		Asm("sar     16, r16");							  \
		Asm("add     -1, r16");							  \
		/* CCB取得 */									  \
		Asm("mov     _p_ccb_table, r17");				  \
		Asm("shl     2, r16");							  \
		Asm("add     r16, r17");						  \
		Asm("ld.w    0[r17], r16");						  \
		/* 割込み発生前のcallevel_statをスタックに保存 */ \
		Asm("ld.h    4[r16], r7");						  \
		Asm("add     -4, sp");							  \
		Asm("st.w    r7, 0[sp]");						  \
		/* callevel_statにC1ISRをORでセット */			  \
		Asm("mov     0x8000, r8");						  \
		Asm("or      r8, r7");							  \
		Asm("st.h    r7, 4[r16]");						  \
		/* C1ISRで実行するC言語関数の呼び出し */		  \
		Asm("jarl _"# EntityFuncName ", r31");			  \
		Asm("di");										  \
		/* コアID取得 */								  \
		Asm("stsr    0,  r16, 2");						  \
		Asm("sar     16, r16");							  \
		Asm("add     -1, r16");							  \
		/* CCB取得 */									  \
		Asm("mov     _p_ccb_table, r17");				  \
		Asm("shl     2, r16");							  \
		Asm("add     r16, r17");						  \
		Asm("ld.w    0[r17], r16");						  \
		/* 保存したcallevel_statを復帰 */				  \
		Asm("ld.w    0[sp],  r6");						  \
		Asm("add     4, sp");							  \
		Asm("st.h    r6, 4[r16]");						  \
		/* レジスタの復帰 */							  \
		Asm("mov     sp, ep");							  \
		Asm("sld.w   4[ep], r10");						  \
		Asm("ldsr    r10, eipc");						  \
		Asm("sld.w   0[ep], r10");						  \
		Asm("ldsr    r10, eipsw");						  \
		Asm("sld.w   76[ep], r1");						  \
		Asm("sld.w   72[ep], r5");						  \
		Asm("sld.w   68[ep], r6");						  \
		Asm("sld.w   64[ep], r7");						  \
		Asm("sld.w   60[ep], r8");						  \
		Asm("sld.w   56[ep], r9");						  \
		Asm("sld.w   52[ep], r10");						  \
		Asm("sld.w   48[ep], r11");						  \
		Asm("sld.w   44[ep], r12");						  \
		Asm("sld.w   40[ep], r13");						  \
		Asm("sld.w   36[ep], r14");						  \
		Asm("sld.w   32[ep], r15");						  \
		Asm("sld.w   28[ep], r16");						  \
		Asm("sld.w   24[ep], r17");						  \
		Asm("sld.w   20[ep], r18");						  \
		Asm("sld.w   16[ep], r19");						  \
		Asm("sld.w    8[ep], r31");						  \
		Asm("addi    80, ep, sp");						  \
		Asm("sld.w   12[ep], r30");						  \
		Asm("eiret");									  \
	}

#ifdef TOPPERS_OS_CFG_H
#include "offset.h"
#if CCB_callevel_stat != 4
#error Change CCB_callevel_stat value in AKTSP_C1ISR_ENTRY() macro!
#endif /* CCB_callevel_stat != 4 */
#endif /* TOPPERS_OS_CFG_H */

#endif /* AKTG_CORE_NUM */


#if TSYS_ISR1 != 0x8000
#error Change TSYS_ISR1 valule in AKTSP_C1ISR_ENTRY() macro!
#endif /* TSYS_ISR1 != 0x8000 */

/*
 *  SC3/SC4におけるテストライブラリのtrap対応
 *  (非信頼OSAPからテストライブラリを使用可能とする)
 */
#ifdef CFG_USE_SCALABILITYCLASS3

#ifndef TotalNumberOfCores
#define TFN_AKTSP_INITIALIZE_TEST_LIB						63
#define TFN_AKTSP_GET_CP_STATE								64
#define TFN_AKTSP_SET_CP_STATE								65
#define TFN_AKTSP_VERYFY_TASK								66
#define TFN_AKTSP_VERYFY_TASK_REL_RESOURCE					67
#define TFN_AKTSP_VERYFY_TASK_REL_EVENT						68
#define TFN_AKTSP_VERYFY_TASK_GET_RESOURCE					69
#define TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE			70
#define TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP					71
#define TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE				72
#define TFN_AKTSP_VERYFY_RESOURCE							73
#define TFN_AKTSP_VERYFY_RESOURCE_OSAP						74
#define TFN_AKTSP_VERYFY_C1ISR								75
#define TFN_AKTSP_VERYFY_C2ISR								76
#define TFN_AKTSP_VERYFY_REL_RESOURCE						77
#define TFN_AKTSP_VERYFY_GET_RESOURCE						78
#define TFN_AKTSP_VERYFY_ACCESS_OSAP						79
#define TFN_AKTSP_VERYFY_INT_STATE							80
#define TFN_AKTSP_VERYFY_DIS_INT_ORDER						81
#define TFN_AKTSP_VERYFY_COUNTER							82
#define TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP				83
#define TFN_AKTSP_VERYFY_ALARM								84
#define TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP					85
#define TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE				86
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE						87
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION			88
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP			89
#define TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE	90
#define TFN_AKTSP_VERYFY_TRUSTED_FUNCTION					91
#define TFN_AKTSP_TRUSTED_SHUTDOWN_OS						92
#define TFN_AKTSP_STOP_HARDWARE_COUNTER						93
#define TFN_AKTSP_START_HARDWARE_COUNTER					94
#define TFN_AKTSP_INIT_HARDWARE_COUNTER						95
#define TFN_AKTSP_INCREMENT_HARDWARE_COUNTER				96
#define TFN_AKTSP_RAISE_INTERRUPT							97
#define TFN_AKTSP_CLEAR_INT_REQUEST							98
#define TFN_AKTSP_CANCEL_INT_REQUEST						99
#define TFN_AKTSP_INITIALIZE_STACK							100
#define TFN_AKTSP_CHECK_STACK_USAGE							101
#define TFN_AKTSP_INIT_HIST									102
#define TFN_AKTSP_BEGIN_MEASURE								103
#define TFN_AKTSP_END_MEASURE								104
#define TFN_AKTSP_PRINT_HIST								105
#define TFN_AKTSP_CHECK_POINT								106
#define TFN_AKTSP_WAIT_CHECK_POINT							107
#define TFN_AKTSP_CHECK_FINISH								108
#define TFN_AKTSP_VERYFY_IOC								109
#define TFN_AKTSP_VERYFY_IOC_SENDER							110
#define TFN_AKTSP_GET_DATA_FROM_IOC							111
#define TFN_AKTSP_VERYFY_OSAP_STATE							112
#else /* TotalNumberOfCores */
#define TFN_AKTSP_INITIALIZE_TEST_LIB						74
#define TFN_AKTSP_GET_CP_STATE								75
#define TFN_AKTSP_SET_CP_STATE								76
#define TFN_AKTSP_VERYFY_TASK								77
#define TFN_AKTSP_VERYFY_TASK_REL_RESOURCE					78
#define TFN_AKTSP_VERYFY_TASK_REL_EVENT						79
#define TFN_AKTSP_VERYFY_TASK_GET_RESOURCE					80
#define TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE			81
#define TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP					82
#define TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE				83
#define TFN_AKTSP_VERYFY_RESOURCE							84
#define TFN_AKTSP_VERYFY_RESOURCE_OSAP						85
#define TFN_AKTSP_VERYFY_C1ISR								86
#define TFN_AKTSP_VERYFY_C2ISR								87
#define TFN_AKTSP_VERYFY_REL_RESOURCE						88
#define TFN_AKTSP_VERYFY_GET_RESOURCE						89
#define TFN_AKTSP_VERYFY_ACCESS_OSAP						90
#define TFN_AKTSP_VERYFY_INT_STATE							91
#define TFN_AKTSP_VERYFY_DIS_INT_ORDER						92
#define TFN_AKTSP_VERYFY_COUNTER							93
#define TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP				94
#define TFN_AKTSP_VERYFY_ALARM								95
#define TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP					96
#define TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE				97
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE						98
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION			99
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP			100
#define TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE	101
#define TFN_AKTSP_VERYFY_TRUSTED_FUNCTION					102
#define TFN_AKTSP_TRUSTED_SHUTDOWN_OS						103
#define TFN_AKTSP_STOP_HARDWARE_COUNTER						104
#define TFN_AKTSP_START_HARDWARE_COUNTER					105
#define TFN_AKTSP_INIT_HARDWARE_COUNTER						106
#define TFN_AKTSP_INCREMENT_HARDWARE_COUNTER				107
#define TFN_AKTSP_RAISE_INTERRUPT							108
#define TFN_AKTSP_CLEAR_INT_REQUEST							109
#define TFN_AKTSP_CANCEL_INT_REQUEST						110
#define TFN_AKTSP_INITIALIZE_STACK							111
#define TFN_AKTSP_CHECK_STACK_USAGE							112
#define TFN_AKTSP_INIT_HIST									113
#define TFN_AKTSP_BEGIN_MEASURE								114
#define TFN_AKTSP_END_MEASURE								115
#define TFN_AKTSP_PRINT_HIST								116
#define TFN_AKTSP_MC_CHECK_POINT							117
#define TFN_AKTSP_MC_WAIT_CHECK_POINT						118
#define TFN_AKTSP_MC_CHECK_FINISH							119
#define TFN_AKTSP_BARRIER_SYNC								120
#define TFN_AKTSP_STATE_SYNC								121
#define TFN_AKTSP_VERIFY_SPINLOCK							122
#define TFN_AKTSP_VERIFY_TASK_GET_SPINLOCK					123
#define TFN_AKTSP_VERIFY_C2ISR_GET_SPINLOCK					124
#define TFN_AKTSP_VERIFY_SPINLOCK_ACCESS_OSAP				125
#define TFN_AKTSP_VERYFY_IOC								126
#define TFN_AKTSP_VERYFY_IOC_SENDER							127
#define TFN_AKTSP_GET_DATA_FROM_IOC							128
#define TFN_AKTSP_VERYFY_ICISR								129
#define TFN_AKTSP_VERYFY_IC_REL_RESOURCE					130
#define TFN_AKTSP_VERYFY_IC_GET_RESOURCE					131
#define TFN_AKTSP_VERYFY_IC_ACCESS_OSAP						132
#define TFN_AKTSP_VERIFY_IC_GET_SPINLOCK					133
#define TFN_AKTSP_VERYFY_OSAP_STATE							134
#endif /* TotalNumberOfCores */


LOCAL_INLINE void
_trap_AktspInitializeTestLib(void)
{
	CAL_SVC_0N(void, TFN_AKTSP_INITIALIZE_TEST_LIB);
}

#ifndef TotalNumberOfCores
LOCAL_INLINE void
_trap_AktspCheckPoint(uint32 count)
{
	CAL_SVC_1N(void, TFN_AKTSP_CHECK_POINT, uint32, count);
}

LOCAL_INLINE void
_trap_AktspWaitCheckPoint(uint32 count)
{
	CAL_SVC_1N(void, TFN_AKTSP_WAIT_CHECK_POINT, uint32, count);
}

LOCAL_INLINE void
_trap_AktspCheckFinish(uint32 count)
{
	CAL_SVC_1N(void, TFN_AKTSP_CHECK_FINISH, uint32, count);
}

#else /* TotalNumberOfCores */

LOCAL_INLINE void
_trap_AktspMcCheckPoint(CoreIdType id, uint32 count)
{
	CAL_SVC_2N(void, TFN_AKTSP_MC_CHECK_POINT, CoreIdType, id, uint32, count);
}

LOCAL_INLINE void
_trap_AktspMcWaitCheckPoint(CoreIdType id, uint32 count)
{
	CAL_SVC_2N(void, TFN_AKTSP_MC_WAIT_CHECK_POINT, CoreIdType, id,uint32, count);
}

LOCAL_INLINE void
_trap_AktspMcCheckFinish(CoreIdType id, uint32 count)
{
	CAL_SVC_2N(void, TFN_AKTSP_MC_CHECK_FINISH, CoreIdType, id, uint32, count);
}

LOCAL_INLINE void
_trap_AktspBarrierSync(uint32 phase, uint16 core_num)
{
	CAL_SVC_2N(void, TFN_AKTSP_BARRIER_SYNC, uint32, phase, uint16, core_num);
}

LOCAL_INLINE void
_trap_AktspStateSync(TaskType target_tskid, TaskStateType target_state)
{
	CAL_SVC_2N(void, TFN_AKTSP_STATE_SYNC, TaskType, target_tskid, TaskStateType, target_state);
}

LOCAL_INLINE StatusType
_trap_AktspVerifySpinlock(SpinlockIdType SpnID, const AktspSpinlockRefInfo SpnInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SPINLOCK, SpinlockIdType, SpnID, AktspSpinlockRefInfo, SpnInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetSpinlock(TaskType TaskID, uint32 Index, SpinlockIdType SpnID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_TASK_GET_SPINLOCK, TaskType, TaskID, uint32, Index, SpinlockIdType, SpnID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_C2ISR_GET_SPINLOCK, ISRType, IsrID, uint32, Index, SpinlockIdType, SpnID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifySpinlockAccessOsap(SpinlockIdType SpnID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SPINLOCK_ACCESS_OSAP, SpinlockIdType, SpnID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsr(ISRType ISRID, AktspIcISRRefInfo IcISRInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ICISR, ISRType, ISRID, AktspIcISRRefInfo, IcISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrRelResource(ISRType ISRID, ResourceType ResID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IC_REL_RESOURCE, ISRType, ISRID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrGetResource(ISRType ISRID, uint32 Index, ResourceType ResID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_IC_GET_RESOURCE, ISRType, ISRID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrAccessOsap(ISRType ISRID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IC_ACCESS_OSAP, ISRType, ISRID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_IC_GET_SPINLOCK, ISRType, IsrID, uint32, Index, SpinlockIdType, SpnID);
}

#endif /* TotalNumberOfCores */

LOCAL_INLINE uint8
_trap_AktspGetCpState(void)
{
	return CAL_SVC_0M(uint8, TFN_AKTSP_GET_CP_STATE);
}

LOCAL_INLINE void
_trap_AktspSetCpState(uint8 state)
{
	CAL_SVC_1N(void, TFN_AKTSP_SET_CP_STATE, uint8, state);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTask(TaskType TaskID, AktspTaskRefInfo TaskInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK, TaskType, TaskID, AktspTaskRefInfo, TaskInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskRelResource(TaskType TaskID, ResourceType ResID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_REL_RESOURCE, TaskType, TaskID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskRelEvent(TaskType TaskID, EventMaskType Mask)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_REL_EVENT, TaskType, TaskID, EventMaskType, Mask);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetResource(TaskType TaskID, uint32 Index, ResourceType ResID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_TASK_GET_RESOURCE, TaskType, TaskID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetInternalResource(TaskType TaskID, ResourceType ResID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE, TaskType, TaskID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskAccessOsap(TaskType TaskID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP, TaskType, TaskID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskApplicationMode(TaskType TaskID, AppModeType Mode)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE, TaskType, TaskID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyResource(ResourceType ResID, AktspResourceRefInfo ResInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_RESOURCE, ResourceType, ResID, AktspResourceRefInfo, ResInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyResourceAccessOsap(ResourceType ResID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_RESOURCE_OSAP, ResourceType, ResID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC1Isr(ISRType ISRID, AktspISRRefInfo ISRInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_C1ISR, ISRType, ISRID, AktspISRRefInfo, ISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2Isr(ISRType ISRID, AktspISRRefInfo ISRInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_C2ISR, ISRType, ISRID, AktspISRRefInfo, ISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrRelResource(ISRType ISRID, ResourceType ResID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_REL_RESOURCE, ISRType, ISRID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrGetResource(ISRType ISRID, uint32 Index, ResourceType ResID)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_GET_RESOURCE, ISRType, ISRID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrAccessOsap(ISRType ISRID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ACCESS_OSAP, ISRType, ISRID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIntState(AktspIntStateRefInfo IntStateInfo)
{
	return CAL_SVC_1M(StatusType, TFN_AKTSP_VERYFY_INT_STATE, AktspIntStateRefInfo, IntStateInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyDisIntOrder(uint32 Index, uint8 State)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_DIS_INT_ORDER, uint32, Index, uint8, State);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyCounter(CounterType CounterID, AktspCounterRefInfo CounterInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_COUNTER, CounterType, CounterID, AktspCounterRefInfo, CounterInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyCounterAccessOsap(CounterType CounterID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP, CounterType, CounterID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarm(AlarmType AlarmID, AktspAlarmRefInfo AlarmData)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ALARM, AlarmType, AlarmID, AktspAlarmRefInfo, AlarmData);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarmAccessOsap(AlarmType AlarmID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP, AlarmType, AlarmID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarmApplicationMode(AlarmType AlarmID, AppModeType Mode)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE, AlarmType, AlarmID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTable(ScheduleTableType ScheduleTableID, AktspScheduleTableRefInfo ScheduleTableInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE, ScheduleTableType, ScheduleTableID, AktspScheduleTableRefInfo, ScheduleTableInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableExaction(ScheduleTableType ScheduleTableID, uint32 Index, AktspScheduleTableExactionRefInfo ScheduleTableExactionInfo)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION, ScheduleTableType, ScheduleTableID, uint32, Index, AktspScheduleTableExactionRefInfo, ScheduleTableExactionInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableAccessOsap(ScheduleTableType ScheduleTableID, ApplicationType OsapID)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP, ScheduleTableType, ScheduleTableID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableApplicationMode(ScheduleTableType ScheduleTableID, AppModeType Mode)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE, ScheduleTableType, ScheduleTableID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTrustedFunction(TrustedFunctionIndexType FunctionIndex, AktspTrustedFunctionRefInfo TrustedFunctionInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TRUSTED_FUNCTION, TrustedFunctionIndexType, FunctionIndex, AktspTrustedFunctionRefInfo, TrustedFunctionInfo);
}

LOCAL_INLINE void
_trap_AktspTrustShutdownOSt(StatusType Error)
{
	CAL_SVC_1N(void, TFN_AKTSP_TRUSTED_SHUTDOWN_OS, StatusType, Error);
}

LOCAL_INLINE StatusType
_trap_AktspStopHardwareCounter(CounterType CounterID)
{
	return CAL_SVC_1M(StatusType, TFN_AKTSP_STOP_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspStartHardwareCounter(CounterType CounterID)
{
	return CAL_SVC_1M(StatusType, TFN_AKTSP_START_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspInitHardwareCounter(CounterType CounterID)
{
	return CAL_SVC_1M(StatusType, TFN_AKTSP_INIT_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspIncrementHardwareCounter(CounterType CounterID)
{
	return CAL_SVC_1M(StatusType, TFN_AKTSP_INCREMENT_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE void
_trap_AktspRaiseInterrupt(InterruptNumberType raiseintno)
{
	CAL_SVC_1N(void, TFN_AKTSP_RAISE_INTERRUPT, InterruptNumberType, raiseintno);
}

LOCAL_INLINE void
_trap_AktspClearIntRequest(InterruptNumberType clearintno)
{
	CAL_SVC_1N(void, TFN_AKTSP_CLEAR_INT_REQUEST, InterruptNumberType, clearintno);
}

LOCAL_INLINE void
_trap_AktspCancelIntRequest(InterruptNumberType cancelintno)
{
	CAL_SVC_1N(void, TFN_AKTSP_CANCEL_INT_REQUEST, InterruptNumberType, cancelintno);
}

LOCAL_INLINE void
_trap_AktspInitializeStack(uint8* stk, MemorySizeType size, boolean boot)
{
	CAL_SVC_3N(void, TFN_AKTSP_INITIALIZE_STACK, uint8*, stk, MemorySizeType, size, boolean, boot);
}

LOCAL_INLINE uint32
_trap_AktspCheckStackUsage(uint8* stk, MemorySizeType size)
{
	return CAL_SVC_2M(uint32, TFN_AKTSP_CHECK_STACK_USAGE, uint8*, stk, MemorySizeType, size);
}

LOCAL_INLINE boolean
_trap_AktspInitHist(uint32 histid, uint32 maxval, uint32* histarea)
{
	return CAL_SVC_3M(boolean, TFN_AKTSP_INIT_HIST, uint32, histid, uint32, maxval, uint32*, histarea);
}

LOCAL_INLINE boolean
_trap_AktspBeginMeasure(uint32 histid)
{
	return CAL_SVC_1M(boolean, TFN_AKTSP_BEGIN_MEASURE, uint32, histid);
}

LOCAL_INLINE boolean
_trap_AktspEndMeasure(uint32 histid)
{
	return CAL_SVC_1M(boolean, TFN_AKTSP_END_MEASURE, uint32, histid);
}

LOCAL_INLINE boolean
_trap_AktspPrintHist(uint32 histid)
{
	return CAL_SVC_1M(boolean, TFN_AKTSP_PRINT_HIST, uint32, histid);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIoc(IocType IocId, const AktspIocRefInfo IocInfo)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IOC, IocType, IocId, AktspIocRefInfo, IocInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIocSender(IocType IocId, SenderIdType SenderId, ApplicationType SenderOsapId)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_IOC_SENDER, IocType, IocId, SenderIdType, SenderId, ApplicationType, SenderOsapId);
}

LOCAL_INLINE StatusType
_trap_AktspGetDataFromIoc(IocType IocId, void* data, uint32 index)
{
	return CAL_SVC_3M(StatusType, TFN_AKTSP_GET_DATA_FROM_IOC, IocType, IocId, void *, data, uint32, index);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyOsapState(ApplicationType OsapID, ApplicationStateType State)
{
	return CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_OSAP_STATE, ApplicationType, OsapID, ApplicationStateType, State);
}

#endif /* CFG_USE_SCALABILITYCLASS3 */

#endif /* TOPPERS_AKTSP_TARGET_LIB_H */
