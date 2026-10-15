/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2015-2016 by Center for Embedded Computing Systems
 *             Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2015-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
 *  Copyright (C) 2015-2016 by eSOL Co.,Ltd., JAPAN
 *  Copyright (C) 2015-2016 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2015-2016 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2015-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2015-2016 by SCSK Corporation, JAPAN
 *  Copyright (C) 2015-2016 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2015-2016 by SUZUKI MOTOR CORPORATION
 *  Copyright (C) 2015-2016 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2015-2016 by Witz Corporation
 *  Copyright (C) 2015-2016 by Fujitsu TEN Limited
 *  Copyright (C) 2015-2016 by JTEKT CORPORATION
 * 
 *  本ソフトウェアは，車載制御システム向け高品質プラットフォームに
 *  関するコンソーシアム型共同研究において開発したものである．
 *  本ソフトウェアの著作権は，上記の著作権者に帰属する． 
 *
 *  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
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
 *  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
 *  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
 *  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
 *  用する者に対して，AUTOSARパートナーになることを求めている．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *  $Id: aktsp_target_lib.h 1699 2016-02-04 08:27:41Z aisincom-nishioka $
 */

#ifndef TOPPERS_AKTSP_TARGET_TEST_H
#define TOPPERS_AKTSP_TARGET_TEST_H

/********************************************************************

  ターゲット依存テストライブラリ(nios2_dev_gcc)

 ********************************************************************/

#include "aktsp_implement_lib.h"
#include "target_hw_counter.h"
#include "vic.h"
#include "out.h"

/*
 * テストプログラムではアラーム循環チェック，
 * スピンロックのデッドロックのチェックをしない(処理速度向上のため)
 */
#define OMIT_CHECK_CYCLIC_CHAIN
#define OMIT_CHECK_DEADLOCK_SPINLOCK

/*
 *  タスクのスタックサイズ
 */
#define AKTSP_TASK_STACK_SIZE  4096U  /* 4Kbyte */

/*
 *  信頼フックが使用するスタックサイズ
 */
#define AKTSP_HOOK_STACK_SIZE   4096U  /* 4Kbyte */

/*
 *  1つのC2ISRが使用するスタックサイズ
 */
#define AKTSP_C2ISR_STACK_SIZE  1024U  /* 1Kbyte */

/*
 *  1つのICISRが使用するスタックサイズ
 */
#define AKTSP_ICISR_STACK_SIZE  AKTSP_C2ISR_STACK_SIZE  /* 1Kbyte */

/*
 *  (信頼)フック，C2ISR用に用意する合計スタックサイズ
 */
#define AKTSP_OS_STACK_SIZE   (MINIMUM_OSTKSZ + AKTSP_HOOK_STACK_SIZE + (AKTSP_C2ISR_STACK_SIZE * 15))  /* C2ISRは最大15個 */

/*
 *  非信頼フックが使用するスタックサイズ
 */
#define AKTSP_NTHOOK_STACK_SIZE   4096U  /* 4Kbyte */

/*
 *  C2ISRがスタックオーバーフローした後で
 *  スタックオーバーフローを検知するまでに使用する予備のスタックサイズ
 */
#define AKTSP_BUFFER_STACK_SIZE  512U  /* 512byte */

/*
 *  システムサービス用信頼関数で使用するスタックサイズ
 *  (信頼関数呼出し時の残量チェックに使用される)
 */
#define AKTSP_STACK_SIZE_FOR_TFN  32U  /* 32byte */

/*
 *  不正な番地
 */
#define AKTSP_INVALID_ADDRESS  0x12345678U

/*
 *  不正なサイズ
 */
#define AKTSP_INVALID_SIZE  0x12345678U

/*
 *  割込み番号(正常値)
 */
#ifndef AKTG_CORE_NUM

#define AKTSP_INTNO_HWCNT  (TIMER_1_IRQ)   /* 割込み番号(ハードウェアカウンタ用) */
#define AKTSP_INTNO_A      (TIMER_2_IRQ)   /* 割込み番号A */
#define AKTSP_INTNO_B      (TIMER_3_IRQ)   /* 割込み番号B */
#define AKTSP_INTNO_C      (TIMER_4_IRQ)   /* 割込み番号C */
#define AKTSP_INTNO_D      (TIMER_5_IRQ)   /* 割込み番号D */
#define AKTSP_INTNO_E      (TIMER_6_IRQ)   /* 割込み番号E */
#define AKTSP_INTNO_F      (TIMER_7_IRQ)   /* 割込み番号F */
#define AKTSP_INTNO_G      (TIMER_8_IRQ)   /* 割込み番号G */
#define AKTSP_INTNO_H      (TIMER_9_IRQ)   /* 割込み番号H */
#define AKTSP_INTNO_I      (TIMER_10_IRQ)  /* 割込み番号I */
#define AKTSP_INTNO_J      (TIMER_11_IRQ)  /* 割込み番号J */
#define AKTSP_INTNO_K      (TIMER_12_IRQ)  /* 割込み番号K */
#define AKTSP_INTNO_L      (TIMER_13_IRQ)  /* 割込み番号L */
#define AKTSP_INTNO_M      (TIMER_14_IRQ)  /* 割込み番号M */
#define AKTSP_INTNO_N      (TIMER_15_IRQ)  /* 割込み番号N */

#else

#define AKTSP_INTNO_HWCNT  (0x10000 + TIMER_1_IRQ)   /* コア0割込み番号(ハードウェアカウンタ用) */
#define AKTSP_INTNO_A      (0x10000 + TIMER_2_IRQ)   /* コア0割込み番号A */
#define AKTSP_INTNO_B      (0x10000 + TIMER_3_IRQ)   /* コア0割込み番号B */
#define AKTSP_INTNO_C      (0x10000 + TIMER_4_IRQ)   /* コア0割込み番号C */
#define AKTSP_INTNO_D      (0x10000 + TIMER_5_IRQ)   /* コア0割込み番号D */
#define AKTSP_INTNO_E      (0x10000 + TIMER_6_IRQ)   /* コア0割込み番号E */
#define AKTSP_INTNO_F      (0x10000 + TIMER_7_IRQ)   /* コア0割込み番号F */
#define AKTSP_INTNO_G      (0x10000 + TIMER_8_IRQ)   /* コア0割込み番号G */
#define AKTSP_INTNO_H      (0x10000 + TIMER_9_IRQ)   /* コア0割込み番号H */
#define AKTSP_INTNO_I      (0x10000 + TIMER_10_IRQ)  /* コア0割込み番号I */
#define AKTSP_INTNO_J      (0x10000 + TIMER_11_IRQ)  /* コア0割込み番号J */
#define AKTSP_INTNO_K      (0x10000 + TIMER_12_IRQ)  /* コア0割込み番号K */
#define AKTSP_INTNO_L      (0x10000 + TIMER_13_IRQ)  /* コア0割込み番号L */
#define AKTSP_INTNO_M      (0x10000 + TIMER_14_IRQ)  /* コア0割込み番号M */
#define AKTSP_INTNO_N      (0x10000 + TIMER_15_IRQ)  /* コア0割込み番号N */

#define AKTSP_INTNO_CORE2_HWCNT  (0x20000 + TIMER_1_IRQ)   /* コア1割込み番号(ハードウェアカウンタ用) */
#define AKTSP_INTNO_CORE2_A      (0x20000 + TIMER_2_IRQ)   /* コア1割込み番号A */
#define AKTSP_INTNO_CORE2_B      (0x20000 + TIMER_3_IRQ)   /* コア1割込み番号B */
#define AKTSP_INTNO_CORE2_C      (0x20000 + TIMER_4_IRQ)   /* コア1割込み番号C */
#define AKTSP_INTNO_CORE2_D      (0x20000 + TIMER_5_IRQ)   /* コア1割込み番号D */
#define AKTSP_INTNO_CORE2_E      (0x20000 + TIMER_6_IRQ)   /* コア1割込み番号E */
#define AKTSP_INTNO_CORE2_F      (0x20000 + TIMER_7_IRQ)   /* コア1割込み番号F */
#define AKTSP_INTNO_CORE2_G      (0x20000 + TIMER_8_IRQ)   /* コア1割込み番号G */
#define AKTSP_INTNO_CORE2_H      (0x20000 + TIMER_9_IRQ)   /* コア1割込み番号H */
#define AKTSP_INTNO_CORE2_I      (0x20000 + TIMER_10_IRQ)  /* コア1割込み番号I */
#define AKTSP_INTNO_CORE2_J      (0x20000 + TIMER_11_IRQ)  /* コア1割込み番号J */
#define AKTSP_INTNO_CORE2_K      (0x20000 + TIMER_12_IRQ)  /* コア1割込み番号K */
#define AKTSP_INTNO_CORE2_L      (0x20000 + TIMER_13_IRQ)  /* コア1割込み番号L */
#define AKTSP_INTNO_CORE2_M      (0x20000 + TIMER_14_IRQ)  /* コア1割込み番号M */
#define AKTSP_INTNO_CORE2_N      (0x20000 + TIMER_15_IRQ)  /* コア1割込み番号N */

#endif /* AKTG_CORE_NUM */

/*
 *  割込み番号(異常値)
 */
#define AKTSP_INVALID_INTNO  50U /* ターゲットでサポートしていない割込み番号 */
#define AKTSP_NOT_SET_INTNO   1U /* 割込み要求ラインに対して割込み属性が設定されていない割込み番号 */

/*
 *  割込み優先度
 *  ※本マクロはcheck_libraryなどのスクラッチプログラムで使用される
 *  ※AKTGによるテストプログラムではconfigure.yamlで指定した割込み優先度が使用される
 */
#define AKTSP_INT_PRI_ISR1 7U
#define AKTSP_INT_PRI_HIGH 4U
#define AKTSP_INT_PRI_MID  3U
#define AKTSP_INT_PRI_LOW  2U

/*
 *  タイムアウト用変数
 *  [for (i = 0; i < AKTSP_BUSY_LOOP; i++) × AKTSP_LOOP_COUNT]
 */
#define AKTSP_BUSY_LOOP   1000U
#define AKTSP_LOOP_COUNT  50000U

/*
 *  ObjectTypeの不正なID
 */
#ifndef AKTG_CORE_NUM
#define AKTSP_INVALID_OBJ_TYPE_NUM 7
#else
#define AKTSP_INVALID_OBJ_TYPE_NUM 8
#endif

/*
 *  各スタック領域の宣言
 */
#ifdef AKTG_USE_SHARE_STACK

#ifdef CFG_USE_SCALABILITYCLASS1

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む) */
#ifndef AKTG_CORE_NUM
extern DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else
extern DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#endif /* AKTG_CORE_NUM */

/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTG_CORE_NUM
#if AKTG_STACK_NUM != 0
extern DEFINE_VAR_STACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#endif /* AKTG_STACK_NUM != 0 */
#else
#if T_TASK_NUM_CORE0 != 0
extern DEFINE_VAR_STACK(uint8, aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE0 != 0 */
#if T_TASK_NUM_CORE1 != 0
extern DEFINE_VAR_STACK(uint8, aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE1 != 0 */
#endif /* AKTG_CORE_NUM */

#endif /* CFG_USE_SCALABILITYCLASS1 */


#ifdef CFG_USE_SCALABILITYCLASS3

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む)，非信頼フック用スタック */
#ifndef AKTG_CORE_NUM
extern DEFINE_VAR_SSTACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_nt_hstack[AKTSP_HOOK_STACK_SIZE], ".stack_section");
#else
extern DEFINE_VAR_SSTACK(uint8, aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_nt_hstack[AKTG_CORE_NUM][AKTSP_HOOK_STACK_SIZE], ".stack_section");
#endif /* AKTG_CORE_NUM */

/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTG_CORE_NUM

#if AKTG_STACK_NUM != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#endif /* AKTG_STACK_NUM != 0 */

#if AKTG_USTACK_NUM != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_sstack[AKTG_USTACK_NUM][AKTSP_TASK_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_ustack[AKTG_USTACK_NUM][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* AKTG_USTACK_NUM != 0 */

#else

#if T_TASK_NUM_CORE0 != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE0 != 0 */

#if T_TASK_NUM_CORE1 != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE1 != 0 */

#if N_TASK_NUM_CORE0 != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_sstack_core0[N_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_ustack_core0[N_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* N_TASK_NUM_CORE0 != 0 */

#if N_TASK_NUM_CORE1 != 0
extern DEFINE_VAR_SSTACK(uint8, aktg_sstack_core1[N_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_ustack_core1[N_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* N_TASK_NUM_CORE1 != 0 */

#endif /* AKTG_CORE_NUM */

#endif /* CFG_USE_SCALABILITYCLASS3 */


/* OS/割込み用スタック，タスクスタック，非信頼フック用スタックの先頭番地 */
#ifndef AKTG_CORE_NUM

#define AKTSP_OS_STACK_ADDRESS       (aktg_os_stack + AKTSP_BUFFER_STACK_SIZE)
#define AKTSP_NT_HOOK_STACK_ADDRESS  aktg_nt_hstack

/* CheckISR(Task)MemoryAccessのチェック対象メモリ領域の先頭番地 */
#define AKTSP_CHECK_NT_TASK_ADDRESS aktg_ustack[0]

/* スタックオーバーフロー対象アドレス(SC1/SC3信頼) */
#define AKTSP_TASK_STACK_ADDRESS    aktg_stack[1]

#ifdef CFG_USE_SCALABILITYCLASS3
/* スタックオーバーフロー対象アドレス(SC3非信頼のシステムスタック) */
#define AKTSP_TASK_SYSTEM_STACK_ADDRESS aktg_sstack[1]
#define AKTSP_NT_TASK_STACK_ADDRESS     aktg_ustack[1]
#endif /* CFG_USE_SCALABILITYCLASS3 */

/* 非信頼から書き込めない変数 */
#define AKTSP_NOWRITE_VAL_BY_NT aktg_stack[0][0]

/* メモリ保護テスト */
#define AKTSP_MEM_TR_TASK_STACK(task_no, pos)  (aktg_stack[(task_no)][(pos)])
#define AKTSP_MEM_TASK_SYS_STACK(task_no, pos) (aktg_sstack[(task_no)][(pos)])
#define AKTSP_MEM_NT_TASK_STACK(task_no, pos)  (aktg_ustack[(task_no)][(pos)])

#else

#define AKTG_OS_STACK_ADDRESS_CORE_0             (aktg_os_stack[0] + AKTSP_BUFFER_STACK_SIZE)
#define AKTG_OS_STACK_ADDRESS_CORE_1             (aktg_os_stack[1] + AKTSP_BUFFER_STACK_SIZE)
#define AKTG_TASK_STACK_ADDRESS_CORE_0(task_no)  (aktg_stack_core0[(task_no)])
#define AKTG_TASK_STACK_ADDRESS_CORE_1(task_no)  (aktg_stack_core1[(task_no)])
#define AKTG_TASK_USTACK_ADDRESS_CORE_0(task_no) (aktg_ustack_core0[(task_no)])
#define AKTG_TASK_USTACK_ADDRESS_CORE_1(task_no) (aktg_ustack_core1[(task_no)])
#define AKTG_TASK_SSTACK_ADDRESS_CORE_0(task_no) (aktg_sstack_core0[(task_no)])
#define AKTG_TASK_SSTACK_ADDRESS_CORE_1(task_no) (aktg_sstack_core1[(task_no)])
#define AKTSP_NT_HOOK_STACK_ADDRESS              aktg_nt_hstack[0]

/* CheckISR(Task)MemoryAccessのチェック対象メモリ領域の先頭番地 */
#define AKTSP_OS_STACK_ADDRESS             AKTG_OS_STACK_ADDRESS_CORE_0
#define AKTSP_CHECK_NT_TASK_ADDRESS        aktg_ustack_core0[0]
#define AKTSP_CHECK_NT_TASK_ADDRESS_CORE_1 aktg_ustack_core1[0]

/* スタックオーバーフロー対象アドレス(SC1/SC3信頼) */
#define AKTSP_TASK_STACK_ADDRESS           aktg_stack_core0[1]
#define AKTSP_TASK_STACK_ADDRESS_CORE_1    aktg_stack_core1[1]

#ifdef CFG_USE_SCALABILITYCLASS3
/* スタックオーバーフロー対象アドレス(SC3非信頼のシステムスタック) */
#define AKTSP_TASK_SYSTEM_STACK_ADDRESS        aktg_sstack_core0[1]
#define AKTSP_TASK_SYSTEM_STACK_ADDRESS_CORE_1 aktg_sstack_core1[1]
#define AKTSP_NT_TASK_STACK_ADDRESS            aktg_ustack_core0[1]
#define AKTSP_NT_TASK_STACK_ADDRESS_CORE_1     aktg_ustack_core1[1]
#endif /* CFG_USE_SCALABILITYCLASS3 */

/* 非信頼から書き込めない変数 */
#define AKTSP_NOWRITE_VAL_BY_NT aktg_stack_core0[0][0]

/* メモリ保護テスト */
#define AKTSP_MEM_TR_TASK_STACK(task_no, pos)    (aktg_stack_core0[(task_no)][(pos)])
#define AKTSP_MEM_TASK_SYS_STACK(task_no, pos)   (aktg_sstack_core0[(task_no)][(pos)])
#define AKTSP_MEM_NT_TASK_STACK(task_no, pos)    (aktg_ustack_core0[(task_no)][(pos)])

#endif /* AKTG_CORE_NUM */

#endif /* AKTG_USE_SHARE_STACK */


/*
 *  CheckTask(ISR)MemoryAccessがE_OS_ILLEGAL_ADDRESSを返すための
 *  メモリ領域指定
 */
#ifndef AKTG_CORE_NUM
#define AKTSP_ILLEGAL_MEMORY_ADDRESS   (aktg_ustack[0] - 4U)
#else
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
	Asm("ldw   r4,  %gprel(aktg_temp_stk)(gp)");				\
	Asm("mov   sp,  r4");										\
	/* テスト対象はタスクのみなのでexit_taskへジャンプする */	\
	Asm("movia r4,  kernel_exit_task");								\
	Asm("jmp   r4");
#endif /* CFG_USE_SCALABILITYCLASS1 */
#ifdef CFG_USE_SCALABILITYCLASS3
#define AKTSP_RETURN_IN_STACK_OVERFLOW_S(stk, sz)				\
	aktg_temp_stk = stk;										\
	Asm("ldw   r4,  %gprel(aktg_temp_stk)(gp)");				\
	Asm("mov   sp,  r4");										\
	/* テスト対象はタスクのみなのでexit_taskへジャンプする */	\
	Asm("movia r4,  kernel_exit_task");						\
	Asm("jmp   r4");
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  マジックナンバー方式により，スタックオーバーフローを発生させて
 *  即returnする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_RETURN_IN_STACK_OVERFLOW_M(stk, sz)	\
	stk[0] = (uint8)~(stk[0]);						\
	return;


/*
 *  スタックポインタ方式で，スタックオーバーフローが検出される
 *  状態にする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_SET_STACK_OVERFLOW_S(stk, sz)				\
	aktg_temp_stk = stk;										\
	Asm("ldw   r4,  %gprel(aktg_temp_stk)(gp)");				\
	Asm("mov   sp,  r4");

/*
 *  マジックナンバー方式で，スタックオーバーフローが検出される
 *  状態にする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_SET_STACK_OVERFLOW_M(stk, sz)				\
	stk[0] = (uint8)~(stk[0]);


#ifndef AKTG_CORE_NUM
/*
 *  C1ISR出入り口処理(シングルコア用)
 *  ※レジスタ退避等の処理を行い，EntityFuncNameを呼出し，
 *    レジスタを復帰する
 *  ※関数名はカーネルのC1ISRで提供されるマクロのによる
 *    変換後の名前と一致するように定義する
 */
#define AKTSP_C1ISR_ENTRY(C1ISRName, EntityFuncName)					\
	extern void C1ISRMain ## C1ISRName(void) __attribute__ (( naked ));	\
	void C1ISRMain ## C1ISRName(void) {									\
		Asm(".set noat");												\
		/* 戻り番地をデクリメント */									\
		Asm("addi  ea,  ea, -4");										\
		/* レジスタの保存 */											\
		Asm("addi  sp,  sp, -76");										\
		Asm("stw   at,   0(sp)");										\
		Asm("stw   r2,   4(sp)");										\
		Asm("stw   r3,   8(sp)");										\
		Asm("stw   r4,  12(sp)");										\
		Asm("stw   r5,  16(sp)");										\
		Asm("stw   r6,  20(sp)");										\
		Asm("stw   r7,  24(sp)");										\
		Asm("stw   r8,  28(sp)");										\
		Asm("stw   r9,  32(sp)");										\
		Asm("stw   r10, 36(sp)");										\
		Asm("stw   r11, 40(sp)");										\
		Asm("stw   r12, 44(sp)");										\
		Asm("stw   r13, 48(sp)");										\
		Asm("stw   r14, 52(sp)");										\
		Asm("stw   r15, 56(sp)");										\
		Asm("stw   ra,  60(sp)");										\
		Asm("stw   ea,  64(sp)");										\
		Asm("rdctl et,  estatus");										\
		Asm("stw   et,  68(sp)");										\
		/* callevel_statをスタックに保存 */								\
		Asm("ldh   r2,  %gprel(kernel_callevel_stat)(gp)");					\
		Asm("stw   r2,  72(sp)");										\
		/* callevel_statへC1ISRをORでセット */							\
		Asm("ori   r3,  r2, %0" :: "i" (TSYS_ISR1));					\
		Asm("sth   r3,  %gprel(kernel_callevel_stat)(gp)");					\
		/* C1ISRで実行するC言語関数の呼び出し */						\
		Asm("call " # EntityFuncName "");								\
		/* 保存したcallevel_statを復帰 */								\
		Asm("ldw   r2,  72(sp)");										\
		Asm("sth   r2,  %gprel(kernel_callevel_stat)(gp)");					\
		/* レジスタの復帰 */											\
		Asm("ldw   at,   0(sp)");										\
		Asm("ldw   r2,   4(sp)");										\
		Asm("ldw   r3,   8(sp)");										\
		Asm("ldw   r4,  12(sp)");										\
		Asm("ldw   r5,  16(sp)");										\
		Asm("ldw   r6,  20(sp)");										\
		Asm("ldw   r7,  24(sp)");										\
		Asm("ldw   r8,  28(sp)");										\
		Asm("ldw   r9,  32(sp)");										\
		Asm("ldw   r10, 36(sp)");										\
		Asm("ldw   r11, 40(sp)");										\
		Asm("ldw   r12, 44(sp)");										\
		Asm("ldw   r13, 48(sp)");										\
		Asm("ldw   r14, 52(sp)");										\
		Asm("ldw   r15, 56(sp)");										\
		Asm("ldw   ra,  60(sp)");										\
		Asm("ldw   ea,  64(sp)");										\
		Asm("ldw   et,  68(sp)");										\
		Asm("wrctl estatus, et");										\
		Asm("addi  sp,  sp, 76");										\
		Asm("eret");													\
	}

#else

/*
 *  C1ISR出入り口処理(マルチコア用)
 *  ※シングルコア用の処理に加え，コア毎のcallevel_statを操作する
 */
#ifdef TOPPERS_OS_CFG_H
#include "offset.h"
#endif /* TOPPERS_OS_CFG_H */

#define AKTSP_C1ISR_ENTRY(C1ISRName, EntityFuncName)					\
	extern void C1ISRMain ## C1ISRName(void) __attribute__ (( naked ));	\
	void C1ISRMain ## C1ISRName(void) {									\
		Asm(".set noat");												\
		/* 戻り番地をデクリメント */									\
		Asm("addi  ea,  ea, -4");										\
		/* レジスタの保存 */											\
		Asm("addi  sp,  sp, -76");										\
		Asm("stw   at,   0(sp)");										\
		Asm("stw   r2,   4(sp)");										\
		Asm("stw   r3,   8(sp)");										\
		Asm("stw   r4,  12(sp)");										\
		Asm("stw   r5,  16(sp)");										\
		Asm("stw   r6,  20(sp)");										\
		Asm("stw   r7,  24(sp)");										\
		Asm("stw   r8,  28(sp)");										\
		Asm("stw   r9,  32(sp)");										\
		Asm("stw   r10, 36(sp)");										\
		Asm("stw   r11, 40(sp)");										\
		Asm("stw   r12, 44(sp)");										\
		Asm("stw   r13, 48(sp)");										\
		Asm("stw   r14, 52(sp)");										\
		Asm("stw   r15, 56(sp)");										\
		Asm("stw   ra,  60(sp)");										\
		Asm("stw   ea,  64(sp)");										\
		Asm("rdctl et,  estatus");										\
		Asm("stw   et,  68(sp)");										\
		/* callevel_statをスタックに保存 */								\
		Asm("rdctl r3,  cpuid");										\
		Asm("ldh   r2,  %0(r3)" :: "i" (CCB_callevel_stat));			\
		Asm("stw   r2,  72(sp)");										\
		/* callevel_statへC1ISRをORでセット */							\
		Asm("ori   r4,  r2, %0" :: "i" (TSYS_ISR1));					\
		Asm("sth   r4,  %0(r3)" :: "i" (CCB_callevel_stat));			\
		/* C1ISRで実行するC言語関数の呼び出し */						\
		Asm("call " # EntityFuncName "");								\
		/* 保存したcallevel_statを復帰 */								\
		Asm("ldw   r2,  72(sp)");										\
		Asm("rdctl r3,  cpuid");										\
		Asm("sth   r2,  %0(r3)" :: "i" (CCB_callevel_stat));			\
		/* レジスタの復帰 */											\
		Asm("ldw   at,   0(sp)");										\
		Asm("ldw   r2,   4(sp)");										\
		Asm("ldw   r3,   8(sp)");										\
		Asm("ldw   r4,  12(sp)");										\
		Asm("ldw   r5,  16(sp)");										\
		Asm("ldw   r6,  20(sp)");										\
		Asm("ldw   r7,  24(sp)");										\
		Asm("ldw   r8,  28(sp)");										\
		Asm("ldw   r9,  32(sp)");										\
		Asm("ldw   r10, 36(sp)");										\
		Asm("ldw   r11, 40(sp)");										\
		Asm("ldw   r12, 44(sp)");										\
		Asm("ldw   r13, 48(sp)");										\
		Asm("ldw   r14, 52(sp)");										\
		Asm("ldw   r15, 56(sp)");										\
		Asm("ldw   ra,  60(sp)");										\
		Asm("ldw   ea,  64(sp)");										\
		Asm("ldw   et,  68(sp)");										\
		Asm("wrctl estatus, et");										\
		Asm("addi  sp,  sp, 76");										\
		Asm("eret");													\
	}

#endif /* AKTG_CORE_NUM */


/*
 *  SC3/SC4におけるテストライブラリのtrap対応
 *  (非信頼OSAPからテストライブラリを使用可能とする)
 */
#ifdef CFG_USE_SCALABILITYCLASS3

#ifndef TotalNumberOfCores
#define TFN_AKTSP_INITIALIZE_TEST_LIB						64
#define TFN_AKTSP_GET_CP_STATE								65
#define TFN_AKTSP_SET_CP_STATE								66
#define TFN_AKTSP_VERYFY_TASK								67
#define TFN_AKTSP_VERYFY_TASK_REL_RESOURCE					68
#define TFN_AKTSP_VERYFY_TASK_REL_EVENT						69
#define TFN_AKTSP_VERYFY_TASK_GET_RESOURCE					70
#define TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE			71
#define TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP					72
#define TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE				73
#define TFN_AKTSP_VERYFY_RESOURCE							74
#define TFN_AKTSP_VERYFY_RESOURCE_OSAP						75
#define TFN_AKTSP_VERYFY_C1ISR								76
#define TFN_AKTSP_VERYFY_C2ISR								77
#define TFN_AKTSP_VERYFY_REL_RESOURCE						78
#define TFN_AKTSP_VERYFY_GET_RESOURCE						79
#define TFN_AKTSP_VERYFY_ACCESS_OSAP						80
#define TFN_AKTSP_VERYFY_INT_STATE							81
#define TFN_AKTSP_VERYFY_DIS_INT_ORDER						82
#define TFN_AKTSP_VERYFY_COUNTER							83
#define TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP				84
#define TFN_AKTSP_VERYFY_ALARM								85
#define TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP					86
#define TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE				87
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE						88
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION			89
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP			90
#define TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE	91
#define TFN_AKTSP_VERYFY_TRUSTED_FUNCTION					92
#if 0
#define TFN_AKTSP_VERYFY_STARTUP_HOOK_OSAP					92
#define TFN_AKTSP_VERYFY_SHUTDOWN_HOOK_OSAP					93
#define TFN_AKTSP_VERYFY_ERROR_HOOK_OSAP					94
#endif
#define TFN_AKTSP_TRUSTED_SHUTDOWN_OS						93
#define TFN_AKTSP_STOP_HARDWARE_COUNTER						94
#define TFN_AKTSP_START_HARDWARE_COUNTER					95
#define TFN_AKTSP_INIT_HARDWARE_COUNTER						96
#define TFN_AKTSP_INCREMENT_HARDWARE_COUNTER				97
#define TFN_AKTSP_RAISE_INTERRUPT							98
#define TFN_AKTSP_CLEAR_INT_REQUEST							99
#define TFN_AKTSP_CANCEL_INT_REQUEST						100
#define TFN_AKTSP_INITIALIZE_STACK							101
#define TFN_AKTSP_CHECK_STACK_USAGE							102
#define TFN_AKTSP_INIT_HIST									103
#define TFN_AKTSP_BEGIN_MEASURE								104
#define TFN_AKTSP_END_MEASURE								105
#define TFN_AKTSP_PRINT_HIST								106
#define TFN_AKTSP_CHECK_POINT								107
#define TFN_AKTSP_WAIT_CHECK_POINT							108
#define TFN_AKTSP_CHECK_FINISH								109
#define TFN_AKTSP_VERYFY_IOC								110
#define TFN_AKTSP_VERYFY_IOC_SENDER							111
#define TFN_AKTSP_GET_DATA_FROM_IOC							112
#define TFN_AKTSP_VERYFY_OSAP_STATE							113
#else
#define TFN_AKTSP_INITIALIZE_TEST_LIB						75
#define TFN_AKTSP_GET_CP_STATE								76
#define TFN_AKTSP_SET_CP_STATE								77
#define TFN_AKTSP_VERYFY_TASK								78
#define TFN_AKTSP_VERYFY_TASK_REL_RESOURCE					79
#define TFN_AKTSP_VERYFY_TASK_REL_EVENT						80
#define TFN_AKTSP_VERYFY_TASK_GET_RESOURCE					81
#define TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE			82
#define TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP					83
#define TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE				84
#define TFN_AKTSP_VERYFY_RESOURCE							85
#define TFN_AKTSP_VERYFY_RESOURCE_OSAP						86
#define TFN_AKTSP_VERYFY_C1ISR								87
#define TFN_AKTSP_VERYFY_C2ISR								88
#define TFN_AKTSP_VERYFY_REL_RESOURCE						89
#define TFN_AKTSP_VERYFY_GET_RESOURCE						90
#define TFN_AKTSP_VERYFY_ACCESS_OSAP						91
#define TFN_AKTSP_VERYFY_INT_STATE							92
#define TFN_AKTSP_VERYFY_DIS_INT_ORDER						93
#define TFN_AKTSP_VERYFY_COUNTER							94
#define TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP				95
#define TFN_AKTSP_VERYFY_ALARM								96
#define TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP					97
#define TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE				98
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE						99
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION			100
#define TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP			101
#define TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE	102
#define TFN_AKTSP_VERYFY_TRUSTED_FUNCTION					103
#if 0
#define TFN_AKTSP_VERYFY_STARTUP_HOOK_OSAP					103
#define TFN_AKTSP_VERYFY_SHUTDOWN_HOOK_OSAP					104
#define TFN_AKTSP_VERYFY_ERROR_HOOK_OSAP					105
#endif
#define TFN_AKTSP_TRUSTED_SHUTDOWN_OS						104
#define TFN_AKTSP_STOP_HARDWARE_COUNTER						105
#define TFN_AKTSP_START_HARDWARE_COUNTER					106
#define TFN_AKTSP_INIT_HARDWARE_COUNTER						107
#define TFN_AKTSP_INCREMENT_HARDWARE_COUNTER				108
#define TFN_AKTSP_RAISE_INTERRUPT							109
#define TFN_AKTSP_CLEAR_INT_REQUEST							110
#define TFN_AKTSP_CANCEL_INT_REQUEST						111
#define TFN_AKTSP_INITIALIZE_STACK							112
#define TFN_AKTSP_CHECK_STACK_USAGE							113
#define TFN_AKTSP_INIT_HIST									114
#define TFN_AKTSP_BEGIN_MEASURE								115
#define TFN_AKTSP_END_MEASURE								116
#define TFN_AKTSP_PRINT_HIST								117
#define TFN_AKTSP_MC_CHECK_POINT							118
#define TFN_AKTSP_MC_WAIT_CHECK_POINT						119
#define TFN_AKTSP_MC_CHECK_FINISH							120
#define TFN_AKTSP_BARRIER_SYNC								121
#define TFN_AKTSP_STATE_SYNC								122
#define TFN_AKTSP_VERIFY_SPINLOCK							123
#define TFN_AKTSP_VERIFY_TASK_GET_SPINLOCK					124
#define TFN_AKTSP_VERIFY_C2ISR_GET_SPINLOCK					125
#define TFN_AKTSP_VERIFY_SPINLOCK_ACCESS_OSAP				126
#define TFN_AKTSP_VERYFY_IOC								127
#define TFN_AKTSP_VERYFY_IOC_SENDER							128
#define TFN_AKTSP_GET_DATA_FROM_IOC							129
#define TFN_AKTSP_VERYFY_ICISR								130
#define TFN_AKTSP_VERYFY_IC_REL_RESOURCE					131
#define TFN_AKTSP_VERYFY_IC_GET_RESOURCE					132
#define TFN_AKTSP_VERYFY_IC_ACCESS_OSAP						133
#define TFN_AKTSP_VERIFY_IC_GET_SPINLOCK					134
#define TFN_AKTSP_VERYFY_OSAP_STATE							135
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
#else
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
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SPINLOCK, SpinlockIdType, SpnID, AktspSpinlockRefInfo, SpnInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetSpinlock(TaskType TaskID, uint32 Index, SpinlockIdType SpnID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_TASK_GET_SPINLOCK, TaskType, TaskID, uint32, Index, SpinlockIdType, SpnID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_C2ISR_GET_SPINLOCK, ISRType, IsrID, uint32, Index, SpinlockIdType, SpnID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifySpinlockAccessOsap(SpinlockIdType SpnID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SPINLOCK_ACCESS_OSAP, SpinlockIdType, SpnID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsr(ISRType ISRID, AktspIcISRRefInfo IcISRInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ICISR, ISRType, ISRID, AktspIcISRRefInfo, IcISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrRelResource(ISRType ISRID, ResourceType ResID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IC_REL_RESOURCE, ISRType, ISRID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrGetResource(ISRType ISRID, uint32 Index, ResourceType ResID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_IC_GET_RESOURCE, ISRType, ISRID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrAccessOsap(ISRType ISRID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IC_ACCESS_OSAP, ISRType, ISRID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIcIsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERIFY_IC_GET_SPINLOCK, ISRType, IsrID, uint32, Index, SpinlockIdType, SpnID);
}
#endif /* TotalNumberOfCores */

LOCAL_INLINE uint8
_trap_AktspGetCpState(void)
{
	CAL_SVC_0M(uint8, TFN_AKTSP_GET_CP_STATE);
}

LOCAL_INLINE void
_trap_AktspSetCpState(uint8 state)
{
	CAL_SVC_1N(void, TFN_AKTSP_SET_CP_STATE, uint8, state);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTask(TaskType TaskID, AktspTaskRefInfo TaskInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK, TaskType, TaskID, AktspTaskRefInfo, TaskInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskRelResource(TaskType TaskID, ResourceType ResID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_REL_RESOURCE, TaskType, TaskID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskRelEvent(TaskType TaskID, EventMaskType Mask)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_REL_EVENT, TaskType, TaskID, EventMaskType, Mask);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetResource(TaskType TaskID, uint32 Index, ResourceType ResID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_TASK_GET_RESOURCE, TaskType, TaskID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskGetInternalResource(TaskType TaskID, ResourceType ResID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_GET_INTERNAL_RESOURCE, TaskType, TaskID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskAccessOsap(TaskType TaskID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TASK_ACCESS_OSAP, TaskType, TaskID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTaskApplicationMode(TaskType TaskID, AppModeType Mode)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_TASK_APPLICATION_MODE, TaskType, TaskID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyResource(ResourceType ResID, AktspResourceRefInfo ResInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_RESOURCE, ResourceType, ResID, AktspResourceRefInfo, ResInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyResourceAccessOsap(ResourceType ResID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_RESOURCE_OSAP, ResourceType, ResID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC1Isr(ISRType ISRID, AktspISRRefInfo ISRInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_C1ISR, ISRType, ISRID, AktspISRRefInfo, ISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2Isr(ISRType ISRID, AktspISRRefInfo ISRInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_C2ISR, ISRType, ISRID, AktspISRRefInfo, ISRInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrRelResource(ISRType ISRID, ResourceType ResID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_REL_RESOURCE, ISRType, ISRID, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrGetResource(ISRType ISRID, uint32 Index, ResourceType ResID)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_GET_RESOURCE, ISRType, ISRID, uint32, Index, ResourceType, ResID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyC2IsrAccessOsap(ISRType ISRID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ACCESS_OSAP, ISRType, ISRID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIntState(AktspIntStateRefInfo IntStateInfo)
{
	CAL_SVC_1M(StatusType, TFN_AKTSP_VERYFY_INT_STATE, AktspIntStateRefInfo, IntStateInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyDisIntOrder(uint32 Index, uint8 State)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_DIS_INT_ORDER, uint32, Index, uint8, State);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyCounter(CounterType CounterID, AktspCounterRefInfo CounterInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_COUNTER, CounterType, CounterID, AktspCounterRefInfo, CounterInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyCounterAccessOsap(CounterType CounterID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_COUNTER_ACCESS_OSAP, CounterType, CounterID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarm(AlarmType AlarmID, AktspAlarmRefInfo AlarmData)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ALARM, AlarmType, AlarmID, AktspAlarmRefInfo, AlarmData);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarmAccessOsap(AlarmType AlarmID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ALARM_ACCESS_OSAP, AlarmType, AlarmID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyAlarmApplicationMode(AlarmType AlarmID, AppModeType Mode)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_ALARM_APPLICATION_MODE, AlarmType, AlarmID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTable(ScheduleTableType ScheduleTableID, AktspScheduleTableRefInfo ScheduleTableInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE, ScheduleTableType, ScheduleTableID, AktspScheduleTableRefInfo, ScheduleTableInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableExaction(ScheduleTableType ScheduleTableID, uint32 Index, AktspScheduleTableExactionRefInfo ScheduleTableExactionInfo)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE_EXACTION, ScheduleTableType, ScheduleTableID, uint32, Index, AktspScheduleTableExactionRefInfo, ScheduleTableExactionInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableAccessOsap(ScheduleTableType ScheduleTableID, ApplicationType OsapID)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_SCHEDULE_TABLE_ACCESS_OSAP, ScheduleTableType, ScheduleTableID, ApplicationType, OsapID);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyScheduleTableApplicationMode(ScheduleTableType ScheduleTableID, AppModeType Mode)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERIFY_SCHEDULE_TABLE_APPLICATION_MODE, ScheduleTableType, ScheduleTableID, AppModeType, Mode);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyTrustedFunction(TrustedFunctionIndexType FunctionIndex, AktspTrustedFunctionRefInfo TrustedFunctionInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_TRUSTED_FUNCTION, TrustedFunctionIndexType, FunctionIndex, AktspTrustedFunctionRefInfo, TrustedFunctionInfo);
}

#if 0
LOCAL_INLINE StatusType
_trap_AktspVerifyStartupHookOsap(ApplicationType OsapID, StartupHookOsap StartupHookFunction)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_STARTUP_HOOK_OSAP, ApplicationType, OsapID, StartupHookOsap, StartupHookFunction);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyShutdownHookOsap(ApplicationType OsapID, ShutdownHookOsap ShutdownHookFunction)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_SHUTDOWN_HOOK_OSAP, ApplicationType, OsapID, ShutdownHookOsap, ShutdownHookFunction);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyErrorHookOsap(ApplicationType OsapID, ErrorHookOsap ErrorHookFunction)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_ERROR_HOOK_OSAP, ApplicationType, OsapID, ErrorHookOsap, ErrorHookFunction);
}
#endif

LOCAL_INLINE void
_trap_AktspTrustShutdownOSt(StatusType Error)
{
	CAL_SVC_1N(void, TFN_AKTSP_TRUSTED_SHUTDOWN_OS, StatusType, Error);
}

LOCAL_INLINE StatusType
_trap_AktspStopHardwareCounter(CounterType CounterID)
{
	CAL_SVC_1M(StatusType, TFN_AKTSP_STOP_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspStartHardwareCounter(CounterType CounterID)
{
	CAL_SVC_1M(StatusType, TFN_AKTSP_START_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspInitHardwareCounter(CounterType CounterID)
{
	CAL_SVC_1M(StatusType, TFN_AKTSP_INIT_HARDWARE_COUNTER, CounterType, CounterID);
}

LOCAL_INLINE StatusType
_trap_AktspIncrementHardwareCounter(CounterType CounterID)
{
	CAL_SVC_1M(StatusType, TFN_AKTSP_INCREMENT_HARDWARE_COUNTER, CounterType, CounterID);
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
	CAL_SVC_2M(uint32, TFN_AKTSP_CHECK_STACK_USAGE, uint8*, stk, MemorySizeType, size);
}

LOCAL_INLINE boolean
_trap_AktspInitHist(uint32 histid, uint32 maxval, uint32* histarea)
{
	CAL_SVC_3M(boolean, TFN_AKTSP_INIT_HIST, uint32, histid, uint32, maxval, uint32*, histarea);
}

LOCAL_INLINE boolean
_trap_AktspBeginMeasure(uint32 histid)
{
	CAL_SVC_1M(boolean, TFN_AKTSP_BEGIN_MEASURE, uint32, histid);
}

LOCAL_INLINE boolean
_trap_AktspEndMeasure(uint32 histid)
{
	CAL_SVC_1M(boolean, TFN_AKTSP_END_MEASURE, uint32, histid);
}

LOCAL_INLINE boolean
_trap_AktspPrintHist(uint32 histid)
{
	CAL_SVC_1M(boolean, TFN_AKTSP_PRINT_HIST, uint32, histid);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIoc(IocType IocId, const AktspIocRefInfo IocInfo)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_IOC, IocType, IocId, AktspIocRefInfo, IocInfo);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyIocSender(IocType IocId, SenderIdType SenderId, ApplicationType SenderOsapId)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_VERYFY_IOC_SENDER, IocType, IocId, SenderIdType, SenderId, ApplicationType, SenderOsapId);
}

LOCAL_INLINE StatusType
_trap_AktspGetDataFromIoc(IocType IocId, void* data, uint32 index)
{
	CAL_SVC_3M(StatusType, TFN_AKTSP_GET_DATA_FROM_IOC, IocType, IocId, void *, data, uint32, index);
}

LOCAL_INLINE StatusType
_trap_AktspVerifyOsapState(ApplicationType OsapID, ApplicationStateType State)
{
	CAL_SVC_2M(StatusType, TFN_AKTSP_VERYFY_OSAP_STATE, ApplicationType, OsapID, ApplicationStateType, State);
}

#endif /* CFG_USE_SCALABILITYCLASS3 */

#endif /* TOPPERS_AKTSP_TARGET_TEST_H */
