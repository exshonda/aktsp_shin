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
 *  $Id: aktsp_implement_lib.h 2036 2015-08-19 03:44:45Z aisincom-nishioka $
 */

#ifndef TOPPERS_AKTSP_IMPLEMENT_LIB_H
#define TOPPERS_AKTSP_IMPLEMENT_LIB_H

/********************************************************************

  実装依存テストライブラリ

 ********************************************************************/

#include "kernel/kernel_impl.h"

#ifdef TOPPERS_OS_CFG_H

#ifdef CFG_USE_SCALABILITYCLASS1

#ifndef TotalNumberOfCores
typedef uint8   ApplicationType;
typedef uint32  IocType;
typedef uint8   SenderIdType;
#endif /* TotalNumberOfCores */

typedef uint32  TrustedFunctionIndexType;
typedef void*   MemoryStartAddressType;
typedef uint8   ApplicationStateType;

#endif /* CFG_USE_SCALABILITYCLASS1 */

#ifndef TotalNumberOfCores
typedef uint8   CoreIdType;
typedef uint16  SpinlockIdType;
#endif /* TotalNumberOfCores */

#if 0
typedef void (*StartupHookOsap)(void);
typedef void (*ShutdownHookOsap)(StatusType Error);
typedef void (*ErrorHookOsap)(StatusType Error);
#endif

#include "aktsp_common_lib.h"

/*
 *  ユーザ定義のエラーコード
 */
#define E_AKTSP_USER_DEFINED_ERCD (ERRCODE_NUM + 1)

/*
 *  実装依存マクロの定義
 *  (ATK2ではkernel_int.hをインクルードするため，下記のマクロは定義不要)
 *  #define TASKNAME(TASKName) TASKMain ## TASKName
 *  #define ALARMCALLBACKNAME(AlarmCallBackName) AlarmMain ## AlarmCallBackName
 */

/*
 *  ダミーハードウェアカウンタの定義
 *  (ターゲットでハードウェアカウンタを用意できない場合に使用する)
 */
extern void init_hwcounter_DUMMY_HARDWARE_COUNTER(TickType maxval2, TimeType nspertick);
extern void start_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void stop_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void set_hwcounter_DUMMY_HARDWARE_COUNTER(TickType exprtick);
extern TickType get_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void cancel_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void trigger_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void int_clear_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void int_cancel_hwcounter_DUMMY_HARDWARE_COUNTER(void);
extern void increment_hwcounter_DUMMY_HARDWARE_COUNTER(void);

#endif /* TOPPERS_OS_CFG_H */

/*
 *  実行時間分布計測の初期化(trap命令)
 */
extern boolean AktspInitHist(uint32 histid, uint32 maxval, uint32 *histarea);

/*
 *  実行時間計測の開始(trap命令)
 */
extern boolean AktspBeginMeasure(uint32 histid);

/*
 *  実行時間計測の終了(trap命令)
 */
extern boolean AktspEndMeasure(uint32 histid);

/*
 *  実行時間分布計測の表示(trap命令)
 */
extern boolean AktspPrintHist(uint32 histid);


#endif /* TOPPERS_AKTSP_IMPLEMENT_LIB_H */
