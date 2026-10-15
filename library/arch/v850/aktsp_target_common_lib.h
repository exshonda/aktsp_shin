/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
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
 *  $Id: aktsp_target_common_lib.h 780 2014-12-24 12:21:36Z ksigihar $
 */

#ifndef TOPPERS_AKTSP_TARGET_COMMON_LIB_H
#define TOPPERS_AKTSP_TARGET_COMMON_LIB_H

/********************************************************************

  ターゲット依存テストライブラリ共通部(fl850)

 ********************************************************************/

#include "aktsp_implement_lib.h"
#include "out.h"

/*
 * テストプログラムではアラーム循環チェックをしない(処理速度向上のため)
 */
#define OMIT_CHECK_CYCLIC_CHAIN

/*
 *  タスクのスタックサイズ
 */
#ifndef AKTSP_TASK_STACK_SIZE	/* overridable from the build (e.g. -DAKTSP_TASK_STACK_SIZE=2048U) */
#ifdef __v850e2v3__
#define AKTSP_TASK_STACK_SIZE   1280U
#elif defined(__v850e3v5__)
#define AKTSP_TASK_STACK_SIZE   1280U
#else  /* __v850e3v5__ */
#error please define ether __v850e2v3__ or __v850e3v5__
#endif /* __v850e2v3__ */
#endif /* AKTSP_TASK_STACK_SIZE */

/*
 *  信頼フックが使用するスタックサイズ
 */
#ifndef AKTSP_HOOK_STACK_SIZE	/* overridable from the build */
#define AKTSP_HOOK_STACK_SIZE   512U /* 512byte */
#endif /* AKTSP_HOOK_STACK_SIZE */

/*
 *  1つのC2ISRが使用するスタックサイズ
 */
#define AKTSP_C2ISR_STACK_SIZE  128U /* 128byte */

/*
 *  1つのICISRが使用するスタックサイズ
 */
#define AKTSP_ICISR_STACK_SIZE  AKTSP_C2ISR_STACK_SIZE  /* 1Kbyte */

/*
 *  (信頼)フック，C2ISR用に用意する合計スタックサイズ
 */
#define AKTSP_OS_STACK_SIZE   (MINIMUM_OSTKSZ + AKTSP_HOOK_STACK_SIZE + (AKTSP_C2ISR_STACK_SIZE * 15))  /* C2ISRは最大15個 */

/*
 *  システムサービス用信頼関数で使用するスタックサイズ
 *  (信頼関数呼出し時の残量チェックに使用される)
 */
#define AKTSP_STACK_SIZE_FOR_TFN  32U  /* 32byte */

/*
 *  C2ISRがスタックオーバーフローした後で
 *  スタックオーバーフローを検知するまでに使用する予備のスタックサイズ
 */
#define AKTSP_BUFFER_STACK_SIZE  128U  /* 128byte */

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

/* シングルコア */

#ifdef __v850e2v3__
#define AKTSP_INTNO_HWCNT  71  /* 割込み番号(ハードウェアカウンタ用) */
#define AKTSP_INTNO_A      72  /* 割込み番号A */
#define AKTSP_INTNO_B      73  /* 割込み番号B */
#define AKTSP_INTNO_C      74  /* 割込み番号C */
#define AKTSP_INTNO_D      75  /* 割込み番号D */
#define AKTSP_INTNO_E      76  /* 割込み番号E */
#define AKTSP_INTNO_F      77  /* 割込み番号F */
#define AKTSP_INTNO_G      78  /* 割込み番号G */
#define AKTSP_INTNO_H      79  /* 割込み番号H */
#define AKTSP_INTNO_I      80  /* 割込み番号I */
#define AKTSP_INTNO_J      81  /* 割込み番号J */
#define AKTSP_INTNO_K      82  /* 割込み番号K */
#define AKTSP_INTNO_L      83  /* 割込み番号L */
#define AKTSP_INTNO_M      84  /* 割込み番号M */
#define AKTSP_INTNO_N      85  /* 割込み番号N */
#elif defined(__v850e3v5__)
#define AKTSP_INTNO_A      52  /* 割込み番号A */
#define AKTSP_INTNO_B      53  /* 割込み番号B */
#define AKTSP_INTNO_C      54  /* 割込み番号C */
#define AKTSP_INTNO_D      55  /* 割込み番号D */
#define AKTSP_INTNO_E      56  /* 割込み番号E */
#define AKTSP_INTNO_F      57  /* 割込み番号F */
#define AKTSP_INTNO_G      58  /* 割込み番号G */
#define AKTSP_INTNO_H      59  /* 割込み番号H */
#define AKTSP_INTNO_I      60  /* 割込み番号I */
#define AKTSP_INTNO_J      61  /* 割込み番号J */
#define AKTSP_INTNO_K      62  /* 割込み番号K */
#define AKTSP_INTNO_L      63  /* 割込み番号L */
#define AKTSP_INTNO_M      64  /* 割込み番号M */
#define AKTSP_INTNO_N      65  /* 割込み番号N */
#define AKTSP_INTNO_HWCNT  66  /* 割込み番号(ハードウェアカウンタ用) */
#else  /* __v850e3v5__ */
#error please define ether __v850e2v3__ or __v850e3v5__
#endif /* __v850e2v3__ */

#else  /* AKTG_CORE_NUM */

/* マルチコア */

#ifdef __v850e3v5__
#define AKTSP_INTNO_A		(0xffff0000 + 52)  /* コア0割込み番号A */
#define AKTSP_INTNO_B		(0xffff0000 + 53)  /* コア0割込み番号B */
#define AKTSP_INTNO_C		(0xffff0000 + 54)  /* コア0割込み番号C */
#define AKTSP_INTNO_D		(0xffff0000 + 55)  /* コア0割込み番号D */
#define AKTSP_INTNO_E		(0xffff0000 + 56)  /* コア0割込み番号E */
#define AKTSP_INTNO_F		(0xffff0000 + 57)  /* コア0割込み番号F */
#define AKTSP_INTNO_G		(0xffff0000 + 58)  /* コア0割込み番号G */
#define AKTSP_INTNO_H		(0xffff0000 + 59)  /* コア0割込み番号H */
#define AKTSP_INTNO_I		(0xffff0000 + 60)  /* コア0割込み番号I */
#define AKTSP_INTNO_J		(0xffff0000 + 61)  /* コア0割込み番号J */
#define AKTSP_INTNO_K		(0xffff0000 + 62)  /* コア0割込み番号K */
#define AKTSP_INTNO_L		(0xffff0000 + 63)  /* コア0割込み番号L */
#define AKTSP_INTNO_M		(0xffff0000 + 64)  /* コア0割込み番号M */
#define AKTSP_INTNO_N		(0xffff0000 + 65)  /* コア0割込み番号N */
#define AKTSP_INTNO_HWCNT	(0xffff0000 + 66)  /* コア0割込み番号(ハードウェアカウンタ用) */

#define AKTSP_INTNO_CORE2_A		(0xffff0000 + 67)  /* コア1割込み番号A */
#define AKTSP_INTNO_CORE2_B		(0xffff0000 + 68)  /* コア1割込み番号B */
#define AKTSP_INTNO_CORE2_C		(0xffff0000 + 69)  /* コア1割込み番号C */
#define AKTSP_INTNO_CORE2_D		(0xffff0000 + 70)  /* コア1割込み番号D */
#define AKTSP_INTNO_CORE2_E		(0xffff0000 + 71)  /* コア1割込み番号E */
#define AKTSP_INTNO_CORE2_F		(0xffff0000 + 72)  /* コア1割込み番号F */
#define AKTSP_INTNO_CORE2_G		(0xffff0000 + 73)  /* コア1割込み番号G */
#define AKTSP_INTNO_CORE2_H		(0xffff0000 + 74)  /* コア1割込み番号H */
#define AKTSP_INTNO_CORE2_I		(0xffff0000 + 75)  /* コア1割込み番号I */
#define AKTSP_INTNO_CORE2_J		(0xffff0000 + 76)  /* コア1割込み番号J */
#define AKTSP_INTNO_CORE2_K		(0xffff0000 + 77)  /* コア1割込み番号K */
#define AKTSP_INTNO_CORE2_L		(0xffff0000 + 78)  /* コア1割込み番号L */
#define AKTSP_INTNO_CORE2_M		(0xffff0000 + 79)  /* コア1割込み番号M */
#define AKTSP_INTNO_CORE2_N		(0xffff0000 + 80)  /* コア1割込み番号N */
#define AKTSP_INTNO_CORE2_HWCNT	(0xffff0000 + 81)  /* コア1割込み番号(ハードウェアカウンタ用) */
#else
#error only support __v850e3v5__
#endif /* __v850e3v5__ */

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
#define AKTSP_INVALID_OBJ_TYPE_NUM	8

/*
 *  各スタック領域の宣言
 */
#ifdef AKTG_USE_SHARE_STACK

#ifdef CFG_USE_SCALABILITYCLASS1

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む) */
#ifndef AKTG_CORE_NUM

/* シングルコア */

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
extern uint8 aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#else /* AKTG_CORE_NUM */

/* マルチコア */

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
extern uint8 aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */


#endif /* AKTG_CORE_NUM */

/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTG_CORE_NUM

/* シングルコア */

#if defined(AKTG_STACK_NUM) && (AKTG_STACK_NUM != 0) 
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#else /* !AKTSP_OMIT_DEFINE_VAR_STACK */
extern uint8 aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */
#endif /* defined(AKTG_STACK_NUM) && (AKTG_STACK_NUM != 0) */

#else /* AKTG_CORE_NUM */

/* マルチコア */

#if T_TASK_NUM_CORE0 != 0

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
extern uint8 aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */
#endif /* T_TASK_NUM_CORE0 != 0 */

#if defined(T_TASK_NUM_CORE1) && T_TASK_NUM_CORE1 != 0
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
extern uint8 aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#endif /* T_TASK_NUM_CORE1 != 0 */

#endif /* AKTG_CORE_NUM */


#ifndef AKTG_CORE_NUM

/* シングルコア */

/* OS/割込み用スタックの先頭番地 */
#define AKTSP_OS_STACK_ADDRESS		(aktg_os_stack + AKTSP_BUFFER_STACK_SIZE)

/* スタックオーバーフロー対象アドレス */
#define AKTSP_TASK_STACK_ADDRESS	aktg_stack[1]

#else /* AKTG_CORE_NUM */

/* OS/割込み用スタックの先頭番地 */
#define AKTG_OS_STACK_ADDRESS_CORE_0				(aktg_os_stack[0] + AKTSP_BUFFER_STACK_SIZE)
#define AKTG_OS_STACK_ADDRESS_CORE_1				(aktg_os_stack[1] + AKTSP_BUFFER_STACK_SIZE)
#define AKTG_TASK_STACK_ADDRESS_CORE_0(task_no)		(aktg_stack_core0[(task_no)])
#define AKTG_TASK_STACK_ADDRESS_CORE_1(task_no)		(aktg_stack_core1[(task_no)])

/* スタックオーバーフロー対象アドレス */
#define AKTSP_TASK_STACK_ADDRESS			aktg_stack_core0[1]
#define AKTSP_TASK_STACK_ADDRESS_CORE_1		aktg_stack_core1[1]

#endif /* AKTG_CORE_NUM */

#endif /* CFG_USE_SCALABILITYCLASS1 */

#ifdef CFG_USE_SCALABILITYCLASS3

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む)，非信頼フック用スタック */
#ifndef AKTG_CORE_NUM
extern DEFINE_VAR_SSTACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
extern DEFINE_VAR_USTACK(uint8, aktg_nt_hstack[AKTSP_HOOK_STACK_SIZE], ".stack_section");
#else /* AKTG_CORE_NUM */
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

#else /* AKTG_CORE_NUM */

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

#else /* AKTG_CORE_NUM */

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

#ifdef TotalNumberOfCores
extern void AktspTargetInfiniteLoop(void);
#endif /*TotalNumberOfCores*/

#endif /* TOPPERS_AKTSP_TARGET_COMMON_LIB_H */
