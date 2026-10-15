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
 *  $Id: out.c 2036 2015-08-19 03:44:45Z aisincom-nishioka $
 */

/*
 *  本テストプログラムでは，以下の状態確認APIのテストする
 *  ・AktspVerifyAlarm()
 *  ・AktspVerifyAlarmApplicationMode()
 *  ・AktspVerifyAlarmAccessOsap()
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
 * ・osap (所属するOSアプリケーション)
 *  TRUSTED_OSAP1     : AlarmActTask, AlarmIncCounter
 *  NON_TRUSTED_OSAP1 : AlarmSetEvent, AlarmUnset
 *
 * 【AktspVerifyAlarmAccessOsap()】
 * ・accosap (アクセスを許可する非信頼OSアプリケーション)
 *  NON_TRUSTED_OSAP5 : AlarmActTask
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyAlarm()】
 *   TESRYデータ   | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   counter       | AlarmSetEvent
 *   almval        | AlarmSetEvent
 *   cycle         | AlarmSetEvent
 *   astat         | AlarmSetEvent
 *   autostarttype | AlarmActTask
 *   osap          | AlarmSetEvent
 *
 * 【AktspVerifyAlarmApplicationMode()】
 *   TESRYデータ   | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   appmode       | AlarmActTask
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyAlarmAccessOsap()】
 *   TESRYデータ | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   accosap     | AlarmActTask
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

TASK(TrustedTask)
{
	StatusType ercd;

	AktspCheckPoint(2);

	ercd = SetRelAlarm(AlarmActTask, 4, 0);
	CheckErcd(ercd, E_OK);
	ercd = SetRelAlarm(AlarmSetEvent, 5, 0);
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

	/* 信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyAlarm();

	AktspCheckPoint(4);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(11);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(13);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(15);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(18);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(20);

	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(NonTrustedTask)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(5);

	/* 非信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyAlarm();

	AktspCheckPoint(6);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(8);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(7);

	/* 信頼関数からの確認 */
	CheckAktspVerifyAlarm();

	return E_OK;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(12);

	/* 信頼OSAPに所属するカテゴリ2 ISRからの確認 */
	CheckAktspVerifyAlarm();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY(void)
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(14);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyAlarm();
}

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	/* 非信頼OSAPからの起動 */
	if (bootcnt == 0) {
		AktspCheckPoint(9);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(16);
	}

	/* エラーフックからの確認 */
	CheckAktspVerifyAlarm();

	bootcnt++;
}

#if 0
void
ErrorHook_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(17);

	/* 信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyAlarm();
}

void
ErrorHook_NON_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(10);

	/* 非信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyAlarm();
}
#endif

ProtectionReturnType
ProtectionHook(StatusType FatalError)
{
	AktspProtectionHookInit();

	if (FatalError == E_OS_STACKFAULT) {
		AktspOutputLog_0("## Stack overflow is detected !!");
		AktspSetCpState(AK_FALSE);
		return(PRO_SHUTDOWN);
	}

	AktspCheckPoint(19);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyAlarm();

	return(PRO_IGNORE);
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(21);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyAlarm();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(22);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyAlarm();
		hookboot = 0;
	}
}

TASK(TaskActTask)
{
	StatusType		ercd;
	AktspAlarmInfo	valm;

	AktspCheckPoint(24);

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
	 *    osap     : TRUSTED_OSAP1
	 *    accosap  :
	 *      - NON_TRUSTED_OSAP5
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_UNSET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_ABSOLUTE;
	valm.am_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
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

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = CancelAlarm(AlarmActTask);
	CheckErcd(ercd, E_OK);
	ercd = CancelAlarm(AlarmSetEvent);
	CheckErcd(ercd, E_OK);

	ercd = ActivateTask(TrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(23);

	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(25);
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
CheckAktspVerifyAlarm(void)
{
	StatusType		ercd;
	AktspAlarmInfo	valm;

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyAlarm())
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
	 *    osap     : TRUSTED_OSAP1
	 *    accosap  :
	 *      - NON_TRUSTED_OSAP5
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_RELATIVE; /* 正しくはAK_ABSOLUTE */
	valm.am_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_NOT_OK, ercd);

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
	 *    osap     : NON_TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = CounterInc;  /* 正しくはCounter */
	valm.am_almval = 5;
	valm.am_cycle = 0;
	valm.am_astat = AK_UNSET;      /* 正しくはAK_SET */
	valm.am_task = TaskSetEvent;
	valm.am_event = Event1;
	valm.am_autostarttype = AKTSP_INVALID_VALUE;
	valm.am_osap = TRUSTED_OSAP1;  /* 正しくはNON_TRUSTED_OSAP1 */

	ercd = AktspVerifyAlarm(AlarmSetEvent, &valm);
	CheckErcd(E_NOT_OK, ercd);

	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = Counter;
	valm.am_almval = 4;            /* 正しくは5 */
	valm.am_cycle = 1;             /* 正しくは0 */
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;
	valm.am_event = Event1;
	valm.am_autostarttype = AKTSP_INVALID_VALUE;
	valm.am_osap = TRUSTED_OSAP1;  /* 正しくはNON_TRUSTED_OSAP1 */

	ercd = AktspVerifyAlarm(AlarmSetEvent, &valm);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyAlarmAccessOsap())
	 */
	ercd = AktspVerifyAlarmAccessOsap(AlarmActTask, NON_TRUSTED_OSAP1); /* 正しくは第2引数がNON_TRUSTED_OSAP5 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyAlarmApplicationMode())
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
	 *    osap     : TRUSTED_OSAP1
	 *    accosap  :
	 *      - NON_TRUSTED_OSAP5
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
	 *    osap     : TRUSTED_OSAP1
	 *    accosap  :
	 *      - NON_TRUSTED_OSAP5
	 */
	valm.am_almact = AK_ALM_SEVT; /* 正しくはAK_ALM_ATSK */
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;  /* 正しくはAK_ALM_ATSK */
	valm.am_autostarttype = AK_ABSOLUTE;
	valm.am_osap = TRUSTED_OSAP1;

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
	 *    appmode  : MainApp
	 *    osap     : NON_TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = Counter;
	valm.am_almval = 5;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;
	valm.am_event = 0xff; /* 正しくはEvent1 */
	valm.am_autostarttype = AK_RELATIVE;
	valm.am_osap = NON_TRUSTED_OSAP1;

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
	 *    osap      : TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_INCNT;
	valm.am_counter = Counter;
	valm.am_almval = 7;
	valm.am_cycle = 4;
	valm.am_astat = AK_SET;
	valm.am_incounter = Counter; /* 正しくはCounterInc */
	valm.am_autostarttype = AKTSP_INVALID_VALUE;
	valm.am_osap = TRUSTED_OSAP1;

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
	 *    osap     : TRUSTED_OSAP1
	 *    accosap  :
	 *      - NON_TRUSTED_OSAP5
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_almval = 4;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskActTask;
	valm.am_autostarttype = AK_ABSOLUTE;
	valm.am_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyAlarm(AlarmActTask, &valm);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmActTask, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmAccessOsap(AlarmActTask, NON_TRUSTED_OSAP5);
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
	 *    osap     : NON_TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_ATSK;
	valm.am_counter = Counter;
	valm.am_astat = AK_UNSET;
	valm.am_task = TaskActTask;
	valm.am_osap = NON_TRUSTED_OSAP1;
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
	 *    appmode  : MainApp
	 *    osap     : NON_TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_SEVT;
	valm.am_counter = Counter;
	valm.am_almval = 5;
	valm.am_cycle = 0;
	valm.am_astat = AK_SET;
	valm.am_task = TaskSetEvent;
	valm.am_event = Event1;
	valm.am_autostarttype = AK_RELATIVE;
	valm.am_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyAlarm(AlarmSetEvent, &valm);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, APPLICATION_MODE2);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyAlarmApplicationMode(AlarmSetEvent, APPLICATION_MODE3);
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
	 *    osap      : TRUSTED_OSAP1
	 */
	valm.am_almact = AK_ALM_INCNT;
	valm.am_counter = Counter;
	valm.am_almval = 7;
	valm.am_cycle = 4;
	valm.am_astat = AK_SET;
	valm.am_incounter = CounterInc;
	valm.am_autostarttype = AKTSP_INVALID_VALUE;
	valm.am_osap = TRUSTED_OSAP1;

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
