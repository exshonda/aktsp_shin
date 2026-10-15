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
 *  $Id: aktsp_add_syssrv.h 2036 2015-08-19 03:44:45Z aisincom-nishioka $
 */

/*
 *  prc_config.hでインクルードするヘッダファイル
 *  (非信頼OSAPからテストライブラリを使用可能とする);
 */

#ifndef TOPPERS_AKTSP_ADD_SYSSRV_H
#define TOPPERS_AKTSP_ADD_SYSSRV_H

#ifndef TOPPERS_MACRO_ONLY
#include "aktsp_implement_lib.h"
#endif /* TOPPERS_MACRO_ONLY */

#ifndef TotalNumberOfCores

#if 0 /*modified by ishi*/
#define PRC_SVC_NUM		52
#else
#define PRC_SVC_NUM		51
#endif
#define CORE_NUM_SWITCH_SVC			\
	(void *)&AktspCheckPoint,		\
	(void *)&AktspWaitCheckPoint,	\
	(void *)&AktspCheckFinish,		\
	(void *)&AktspVerifyIoc, 		\
	(void *)&AktspVerifyIocSender, 	\
	(void *)&AktspGetDataFromIoc,	\
	(void *)&AktspVerifyOsapState
#else

#if 0 /*modified by ishi*/
#define PRC_SVC_NUM		63
#else
#define PRC_SVC_NUM		62
#endif
#define CORE_NUM_SWITCH_SVC					\
	(void *)&AktspMcCheckPoint,				\
	(void *)&AktspMcWaitCheckPoint,			\
	(void *)&AktspMcCheckFinish,			\
	(void *)&AktspBarrierSync,				\
	(void *)&AktspStateSync,				\
	(void *)&AktspVerifySpinlock,			\
	(void *)&AktspVerifyTaskGetSpinlock,	\
	(void *)&AktspVerifyC2IsrGetSpinlock,	\
	(void *)&AktspVerifySpinlockAccessOsap, \
	(void *)&AktspVerifyIoc, 				\
	(void *)&AktspVerifyIocSender, 			\
	(void *)&AktspGetDataFromIoc,			\
	(void *)&AktspVerifyIcIsr,				\
	(void *)&AktspVerifyIcIsrRelResource,	\
	(void *)&AktspVerifyIcIsrGetResource,	\
	(void *)&AktspVerifyIcIsrAccessOsap,	\
	(void *)&AktspVerifyIcIsrGetSpinlock,	\
	(void *)&AktspVerifyOsapState

#endif /* TotalNumberOfCores */

/*
 * modified by ishi
 * call_nontrusted_trap_ret を削除
 */
#define PRC_SVC_TABLE									\
	(void *)&_kernel_KernelLibrarySyslog,				\
	(void *)&AktspInitializeTestLib,					\
	(void *)&AktspGetCpState,							\
	(void *)&AktspSetCpState,							\
	(void *)&AktspVerifyTask,							\
	(void *)&AktspVerifyTaskRelResource,				\
	(void *)&AktspVerifyTaskRelEvent,					\
	(void *)&AktspVerifyTaskGetResource,				\
	(void *)&AktspVerifyTaskGetInternalResource,		\
	(void *)&AktspVerifyTaskAccessOsap,					\
	(void *)&AktspVerifyTaskApplicationMode,			\
	(void *)&AktspVerifyResource,						\
	(void *)&AktspVerifyResourceAccessOsap,				\
	(void *)&AktspVerifyC1Isr,							\
	(void *)&AktspVerifyC2Isr,							\
	(void *)&AktspVerifyC2IsrRelResource,				\
	(void *)&AktspVerifyC2IsrGetResource,				\
	(void *)&AktspVerifyC2IsrAccessOsap,				\
	(void *)&AktspVerifyIntState,						\
	(void *)&AktspVerifyDisIntOrder,					\
	(void *)&AktspVerifyCounter,						\
	(void *)&AktspVerifyCounterAccessOsap,				\
	(void *)&AktspVerifyAlarm,							\
	(void *)&AktspVerifyAlarmAccessOsap,				\
	(void *)&AktspVerifyAlarmApplicationMode,			\
	(void *)&AktspVerifyScheduleTable,					\
	(void *)&AktspVerifyScheduleTableExaction,			\
	(void *)&AktspVerifyScheduleTableAccessOsap,		\
	(void *)&AktspVerifyScheduleTableApplicationMode,	\
	(void *)&AktspVerifyTrustedFunction,				\
	(void *)&AktspTrustShutdownOS,						\
	(void *)&AktspStopHardwareCounter,					\
	(void *)&AktspStartHardwareCounter,					\
	(void *)&AktspInitHardwareCounter,					\
	(void *)&AktspIncrementHardwareCounter,				\
	(void *)&AktspRaiseInterrupt,						\
	(void *)&AktspClearIntRequest,						\
	(void *)&AktspCancelIntRequest,						\
	(void *)&AktspInitializeStack,						\
	(void *)&AktspCheckStackUsage,						\
	(void *)&AktspInitHist,								\
	(void *)&AktspBeginMeasure,							\
	(void *)&AktspEndMeasure,							\
	(void *)&AktspPrintHist,							\
	CORE_NUM_SWITCH_SVC

#endif /* TOPPERS_AKTSP_ADD_SYSSRV_H */
