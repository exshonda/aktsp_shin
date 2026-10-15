/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
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
 *  $Id: aktsp_target_common_lib.h 347 2014-09-17 00:28:35Z fsi-dankei $
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
#define AKTSP_TASK_STACK_SIZE   1280U

/*
 *  信頼フックが使用するスタックサイズ
 */
#define AKTSP_HOOK_STACK_SIZE   512U /* 512byte */

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
 *  各スタック領域の宣言
 */
#ifdef AKTG_USE_SHARE_STACK

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む) */
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else
extern uint8 aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#if AKTG_STACK_NUM != 0
/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
extern DEFINE_VAR_STACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#else
extern uint8 aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */
#endif /* AKTG_STACK_NUM != 0 */

/* OS/割込み用スタックの先頭番地 */
#define AKTSP_OS_STACK_ADDRESS		(aktg_os_stack + AKTSP_BUFFER_STACK_SIZE)

/* スタックオーバーフロー対象アドレス */
#define AKTSP_TASK_STACK_ADDRESS	aktg_stack[1]

#endif /* AKTG_USE_SHARE_STACK */

#endif /* TOPPERS_AKTSP_TARGET_COMMON_LIB_H */
