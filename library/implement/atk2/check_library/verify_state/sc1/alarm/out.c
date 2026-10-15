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
 *  $Id: out.c 347 2014-09-17 00:28:35Z fsi-dankei $
 */

/*
 *  本テストプログラムでは，以下の状態確認APIのテストする
 *  ・AktspVerifyAlarm()
 *  ・AktspVerifyAlarmApplicationMode()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyAlarm()】
 * ・almact (アラーム満了時に実行させるアクション)
 *  AK_ALM_ATSK  : AlarmActTask, AlarmUnset
 *  AK_ALM_SEVT  : AlarmSetEvent
 *  AK_ALM_CBACK : AlarmAlmCallBack
 *  AK_ALM_INCNT : AlarmIncCounter
 *
 * ・counter (対象カウンタ名)
 *  Counter : AlarmActTask, AlarmUnset, AlarmSetEvent, AlarmAlmCallBack, AlarmIncCounter
 *
 * ・almval (満了するティックの絶対値)
 *  4 : AlarmActTask
 *  5 : AlarmSetEvent
 *  6 : AlarmAlmCallBack
 *  7 : AlarmIncCounter
 *
 * ・cycle (アラーム満了周期)
 *  0 : AlarmActTask, AlarmSetEvent
 *  3 : AlarmAlmCallBack
 *  4 : AlarmIncCounter
 *
 * ・astat (アラームの状態)
 *  AK_UNSET : AlarmUnset
 *  AK_SET   : AlarmActTask, AlarmSetEvent, AlarmAlmCallBack, AlarmIncCounter
 *
 * ・task (ActivateTask/SetEventを実行するタスク)
 *  ActivateTaskの対象タスク : TaskActTask(AlarmActTask), TaskUnset(AlarmUnset)
 *  SetEventの対象タスク     : TaskSetEvent
 *
 * ・event (SetEventで指定する対象イベント)
 *  対象イベント : Event1
 *
 * ・incounter (IncrementCounterの対象カウンタ)
 *  対象カウンタ : CounterInc
 *
 * ・callback (実行するアラームコールバック)
 *  対象アラームコールバック : AlarmCallBack
 *
 * ・autostarttype (自動起動の属性)
 *  AK_ABSOLUTE : AlarmActTask
 *  AK_RELATIVE : AlarmSetEvent
 *
 * 【AktspVerifyAlarmApplicationMode()】
 * ・appmode (アプリケーションモード)
 *  MainApp           : AlarmActTask, AlarmSetEvent
 *  APPLICATION_MODE1 : AlarmActTask
 *  APPLICATION_MODE2 : AlarmSetEvent
 *  APPLICATION_MODE3 : AlarmSetEvent
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyAlarm()】
 *   TESRYデータ   | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   counter       | AlarmAlmCallBack
 *   almval        | AlarmAlmCallBack
 *   cycle         | AlarmAlmCallBack
 *   astat         | AlarmAlmCallBack
 *   callback      | AlarmAlmCallBack
 *   autostarttype | AlarmActTask
 *
 * 【AktspVerifyAlarmApplicationMode()】
 *   TESRYデータ   | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   appmode       | AlarmActTask
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyAlarm()】
 *   TESRYデータ | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   almact      | AlarmActTask
 *   task        | AlarmActTask
 *   event       | AlarmSetEvent
 *   incounter   | AlarmIncCounter
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskVerify)
{
	StatusType ercd;

	AktspCheckPoint(2);

	ercd = SetRelAlarm(AlarmActTask, 4, 0);
	CheckErcd(ercd, E_OK);
	ercd = SetRelAlarm(AlarmSetEvent, 5, 0);
	CheckErcd(ercd, E_OK);
	ercd = SetRelAlarm(AlarmAlmCallBack, 6, 3);
	CheckErcd(ercd, E_OK);
	ercd = SetRelAlarm(AlarmIncCounter, 7, 4);
	CheckErcd(ercd, E_OK);

	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterInc);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(3);

	/* タスクからの確認 */
	CheckAktspVerifyAlarm();

	AktspCheckPoint(4);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(6);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(8);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(10);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(12);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(14);
	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(TaskActTask)
{
	StatusType		ercd;
	AktspAlarmInfo	valm;

	AktspCheckPoint(18);

	/*
	 *  AlarmActTaskチェック
	 *
	 *  AlarmActTask:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    almval   : 4
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskActTask
	 *    autostarttype: AK_ABSOLUTE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_UNSET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_ABSOLUTE;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);

	TerminateTask();
}

TASK(TaskUnset)
{
	TerminateTask();
}

TASK(TaskSetEvent)
{
	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(5);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyAlarm();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(7);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyAlarm();
}

ALARMCALLBACK(AlarmCallBack)
{
	/* 起動しないため，チェックポイント0を指定 */
	AktspCheckPoint(0);
	return;
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(13);

	/* アラームコールバックからの確認 */
	CheckAktspVerifyAlarm();
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(16);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyAlarm();
		hookboot = 0;
	}
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(15);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyAlarm();
	}
}

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(9);

	/* エラーフックからの確認 */
	CheckAktspVerifyAlarm();
}

ProtectionReturnType
ProtectionHook(StatusType FatalError)
{
	AktspProtectionHookInit();
	if (FatalError == E_OS_STACKFAULT) {
		AktspOutputLog_0("## Stack overflow is detected !!");
		AktspSetCpState(AK_FALSE);
		return(PRO_SHUTDOWN);
	}

	AktspCheckPoint(11);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyAlarm();

	return(PRO_IGNORE);
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = CancelAlarm(AlarmActTask);
	CheckErcd(ercd, E_OK);
	ercd = CancelAlarm(AlarmSetEvent);
	CheckErcd(ercd, E_OK);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(17);

	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(19);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

/*
 *  状態確認APIチェック関数
 */
void
CheckAktspVerifyAlarm()
{
	StatusType		ercd;
	AktspAlarmInfo	valm;

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyAlarm())
	 */

	/*
	 *  AlarmAlmCallBack:
	 *    type     : ALARM
	 *    almact   : AK_ALM_CBACK
	 *    counter  : Counter
	 *    almval   : 6
	 *    cycle    : 3
	 *    astat    : AK_SET
	 *    callback : AlarmCallBack
	 */
	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = CounterInc; /* 正しくはCounter */
	valm.am_almval = 6;
	valm.am_cycle = 3;
	valm.am_astat = AK_SET;
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBack);
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_NOT_OK, ercd);

	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = Counter;
	valm.am_almval = 7; /* 正しくは6 */
	valm.am_cycle = 3;
	valm.am_astat = AK_SET;
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBack);
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_NOT_OK, ercd);

	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = Counter;
	valm.am_almval = 6;
	valm.am_cycle = 0; /* 正しくは3 */
	valm.am_astat = AK_SET;
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBack);
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_NOT_OK, ercd);

	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = Counter;
	valm.am_almval = 6;
	valm.am_cycle = 3;
	valm.am_astat = AK_UNSET; /* 正しくはAK_SET */
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBack);
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_NOT_OK, ercd);

	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = Counter;
	valm.am_almval = 6;
	valm.am_cycle = 3;
	valm.am_astat = AK_SET;
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBackVerify); /* 正しくはALARMCALLBACKNAME(AlarmCallBack) */
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  AlarmActTask:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    almval   : 4
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskActTask
	 *    autostarttype: AK_ABSOLUTE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_RELATIVE; /* 正しくはAK_ABSOLUTE */

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyAlarmApplicationMode())
	 */

	/*
	 *  AlarmActTask:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    almval   : 4
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskActTask
	 *    autostarttype: AK_ABSOLUTE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 */
	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, APPLICATION_MODE2); /* 正しくは第2引数がMainApp，もしくはAPPLICATION_MODE1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyAlarm())
	 */

	/*
	 *  AlarmActTask:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    almval   : 4
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskActTask
	 *    autostarttype: AK_ABSOLUTE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 */
	valm.am_almact = AK_ALM_SEVT; /* 正しくはAK_ALM_ATSK */
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_ABSOLUTE;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_OK, ercd);

	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent; /* 正しくはAK_ALM_ATSK */
	valm.am_autostarttype = AK_ABSOLUTE;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmSetEvent:
	 *    type     : ALARM
	 *    almact   : AK_ALM_SEVT
	 *    counter  : Counter
	 *    almval   : 5
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskSetEvent
	 *    event    : Event1
	 *    autostarttype: AK_RELATIVE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE2
	 *      - APPLICATION_MODE3
	 */
	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = Counter;
	valm.am_almval = 5;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;
	valm.am_event = 0xff; /* 正しくはEvent1 */
	valm.am_autostarttype = AK_RELATIVE;

	ercd = AktspVerifyAlarm(AlarmSetEvent, &valm);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmIncCounter:
	 *    type      : ALARM
	 *    almact    : AK_ALM_INCNT
	 *    counter   : Counter
	 *    almval    : 7
	 *    cycle     : 4
	 *    astat     : AK_SET
	 *    incounter : CounterInc
	 */
	valm.am_almact = AK_ALM_INCNT;
	valm.am_counter = Counter;
	valm.am_almval = 7;
	valm.am_cycle = 4;
	valm.am_astat = AK_SET;
	valm.am_incounter = Counter; /* 正しくはCounterInc */
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmIncCounter, &valm);
	CheckErcd(E_OK, ercd);

	/*
	 *  各アラームの状態確認
	 */

	/*
	 *  AlarmActTaskチェック
	 *
	 *  AlarmActTask:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    almval   : 4
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskActTask
	 *    autostarttype: AK_ABSOLUTE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_ABSOLUTE;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmUnsetチェック
	 *
	 *  AlarmUnset:
	 *    type     : ALARM
	 *    almact   : AK_ALM_ATSK
	 *    counter  : Counter
	 *    astat    : AK_UNSET
	 *    task     : TaskActTask
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_astat = AK_UNSET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmUnset, &valm);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmSetEvent:
	 *    type     : ALARM
	 *    almact   : AK_ALM_SEVT
	 *    counter  : Counter
	 *    almval   : 5
	 *    cycle    : 0
	 *    astat    : AK_SET
	 *    task     : TaskSetEvent
	 *    event    : Event1
	 *    autostarttype: AK_RELATIVE
	 *    appmode  :
	 *      - MainApp
	 *      - APPLICATION_MODE2
	 *      - APPLICATION_MODE3
	 */
	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = Counter;
	valm.am_almval = 5;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;
	valm.am_event = Event1;
	valm.am_autostarttype = AK_RELATIVE;

	ercd = AktspVerifyAlarm(AlarmSetEvent, &valm);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, APPLICATION_MODE2);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, APPLICATION_MODE3);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmAlmCallBack:
	 *    type     : ALARM
	 *    almact   : AK_ALM_CBACK
	 *    counter  : Counter
	 *    almval   : 6
	 *    cycle    : 3
	 *    astat    : AK_SET
	 *    callback : AlarmCallBack
	 */
	valm.am_almact = AK_ALM_CBACK;
	valm.am_counter = Counter;
	valm.am_almval = 6;
	valm.am_cycle = 3;
	valm.am_astat = AK_SET;
	valm.am_callback = ALARMCALLBACKNAME(AlarmCallBack);
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmAlmCallBack, &valm);
	CheckErcd(E_OK, ercd);

	/*
	 *  AlarmIncCounter:
	 *    type      : ALARM
	 *    almact    : AK_ALM_INCNT
	 *    counter   : Counter
	 *    almval    : 7
	 *    cycle     : 4
	 *    astat     : AK_SET
	 *    incounter : CounterInc
	 */
	valm.am_almact = AK_ALM_INCNT;
	valm.am_counter = Counter;
	valm.am_almval = 7;
	valm.am_cycle = 4;
	valm.am_astat = AK_SET;
	valm.am_incounter = CounterInc;
	valm.am_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyAlarm(AlarmIncCounter, &valm);
	CheckErcd(E_OK, ercd);

	return;
}

/*
 *  User main
 */
sint32
main(void){
	AktspInitializeTestLib();
	StartOS(MainApp);
	while (1) {}
}
