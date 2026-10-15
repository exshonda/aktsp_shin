/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
 *  Copyright (C) 2011-2013 by FUJITSU VLSI LIMITED, JAPAN
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
 *  $Id: aktsp_target_include.h 399 2014-03-06 12:56:14Z t_ishikawa $
 */
#ifndef TOPPERS_AKTSP_TARGET_INCLUDE_H
#define TOPPERS_AKTSP_TARGET_INCLUDE_H

/*
 *  out.cでインクルードするヘッダファイル(ターゲット依存部分)
 */

#ifdef CFG_USE_SCALABILITYCLASS3

/* スモールデータでないデータサイズ(9byte以上) */
#define AKTSP_NO_SMALL_DATA_SIZE	10U

/* 
 * メモリ保護テストで実行アクセスを空振りさせる数値
 * (0x007f: jmp [lp]命令) (0x001f: syncp)
 */
#define AKTSP_RET_ORDER_0		(uint8)0x7f
#define AKTSP_RET_ORDER_1		(uint8)0x00
#define AKTSP_RET_ORDER_2		(uint8)0x1f
#define AKTSP_RET_ORDER_3		(uint8)0x00
#define AKTSP_RET_ORDER_SET		(uint32)0x001f007f
#define AKTSP_RET_ORDER_ARRAY	{AKTSP_RET_ORDER_0, AKTSP_RET_ORDER_1, AKTSP_RET_ORDER_2, AKTSP_RET_ORDER_3, 0U, 0U, 0U, 0U, 0U, 0U}

/*
 * アライン指定宣言マクロ
 */
#define AKTSP_DEFINE_ALIGNED_VAR(type, var) type __attribute__((aligned(32))) var
#define AKTSP_DEFINE_ALIGNED_VAR_SEC(type, var, sec) type __attribute__((section(sec), aligned(32))) var

/* 非信頼OSAPからも呼び出すためにtrap命令を使用する関数 */
#define AktspInitializeTestLib					_trap_AktspInitializeTestLib
#define AktspCheckPoint							_trap_AktspCheckPoint
#define AktspWaitCheckPoint						_trap_AktspWaitCheckPoint
#define AktspCheckFinish						_trap_AktspCheckFinish
#define AktspGetCpState							_trap_AktspGetCpState
#define AktspSetCpState							_trap_AktspSetCpState
#define AktspVerifyTask							_trap_AktspVerifyTask
#define AktspVerifyTaskRelResource				_trap_AktspVerifyTaskRelResource
#define AktspVerifyTaskRelEvent					_trap_AktspVerifyTaskRelEvent
#define AktspVerifyTaskGetResource				_trap_AktspVerifyTaskGetResource
#define AktspVerifyTaskGetInternalResource		_trap_AktspVerifyTaskGetInternalResource
#define AktspVerifyTaskAccessOsap				_trap_AktspVerifyTaskAccessOsap
#define AktspVerifyTaskApplicationMode			_trap_AktspVerifyTaskApplicationMode
#define AktspVerifyResource						_trap_AktspVerifyResource
#define AktspVerifyResourceAccessOsap			_trap_AktspVerifyResourceAccessOsap
#define AktspVerifyC1Isr						_trap_AktspVerifyC1Isr
#define AktspVerifyC2Isr						_trap_AktspVerifyC2Isr
#define AktspVerifyC2IsrRelResource				_trap_AktspVerifyC2IsrRelResource
#define AktspVerifyC2IsrGetResource				_trap_AktspVerifyC2IsrGetResource
#define AktspVerifyC2IsrAccessOsap				_trap_AktspVerifyC2IsrAccessOsap
#define AktspVerifyIntState						_trap_AktspVerifyIntState
#define AktspVerifyDisIntOrder					_trap_AktspVerifyDisIntOrder
#define AktspVerifyCounter						_trap_AktspVerifyCounter
#define AktspVerifyCounterAccessOsap			_trap_AktspVerifyCounterAccessOsap
#define AktspVerifyAlarm						_trap_AktspVerifyAlarm
#define AktspVerifyAlarmAccessOsap				_trap_AktspVerifyAlarmAccessOsap
#define AktspVerifyAlarmApplicationMode			_trap_AktspVerifyAlarmApplicationMode
#define AktspVerifyScheduleTable				_trap_AktspVerifyScheduleTable
#define AktspVerifyScheduleTableExaction		_trap_AktspVerifyScheduleTableExaction
#define AktspVerifyScheduleTableAccessOsap		_trap_AktspVerifyScheduleTableAccessOsap
#define AktspVerifyScheduleTableApplicationMode	_trap_AktspVerifyScheduleTableApplicationMode
#define AktspVerifyTrustedFunction				_trap_AktspVerifyTrustedFunction
#define AktspStopHardwareCounter				_trap_AktspStopHardwareCounter
#define AktspStartHardwareCounter				_trap_AktspStartHardwareCounter
#define AktspInitHardwareCounter				_trap_AktspInitHardwareCounter
#define AktspIncrementHardwareCounter			_trap_AktspIncrementHardwareCounter
#define AktspRaiseInterrupt						_trap_AktspRaiseInterrupt
#define AktspClearIntRequest					_trap_AktspClearIntRequest
#define AktspCancelIntRequest					_trap_AktspCancelIntRequest
#define AktspInitializeStack					_trap_AktspInitializeStack
#define AktspCheckStackUsage					_trap_AktspCheckStackUsage
#define AktspInitHist							_trap_AktspInitHist
#define AktspBeginMeasure						_trap_AktspBeginMeasure
#define AktspEndMeasure							_trap_AktspEndMeasure
#define AktspPrintHist							_trap_AktspPrintHist
#define AktspMcCheckPoint						_trap_AktspMcCheckPoint
#define AktspMcWaitCheckPoint					_trap_AktspMcWaitCheckPoint
#define AktspMcCheckFinish						_trap_AktspMcCheckFinish
#define AktspBarrierSync						_trap_AktspBarrierSync
#define AktspStateSync							_trap_AktspStateSync
#define AktspVerifySpinlock						_trap_AktspVerifySpinlock
#define AktspVerifyTaskGetSpinlock				_trap_AktspVerifyTaskGetSpinlock
#define AktspVerifyC2IsrGetSpinlock				_trap_AktspVerifyC2IsrGetSpinlock
#define AktspVerifySpinlockAccessOsap			_trap_AktspVerifySpinlockAccessOsap
#define AktspVerifyIoc							_trap_AktspVerifyIoc
#define AktspVerifyIocSender					_trap_AktspVerifyIocSender
#define AktspGetDataFromIoc						_trap_AktspGetDataFromIoc
#define AktspVerifyIcIsr						_trap_AktspVerifyIcIsr
#define AktspVerifyIcIsrRelResource				_trap_AktspVerifyIcIsrRelResource
#define AktspVerifyIcIsrGetResource				_trap_AktspVerifyIcIsrGetResource
#define AktspVerifyIcIsrAccessOsap				_trap_AktspVerifyIcIsrAccessOsap
#define AktspVerifyIcIsrGetSpinlock				_trap_AktspVerifyIcIsrGetSpinlock
#define AktspVerifyOsapState					_trap_AktspVerifyOsapState

#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
#define AktspInfiniteLoop   AktspTargetInfiniteLoop
#endif /*TotalNumberOfCores*/

#endif /* TOPPERS_AKTSP_TARGET_INCLUDE_H */
