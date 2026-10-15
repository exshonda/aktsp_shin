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
 *  ・AktspVerifyScheduleTable()
 *  ・AktspVerifyScheduleTableExAction()
 *  ・AktspVerifyScheduleTableApplicationMode()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyScheduleTable()】
 * ・counter (対象カウンタ名)
 *  Counter1               : ScheduleTable1, ScheduleTable2
 *  Counter2               : ScheduleTable4
 *  DUMMY_HARDWARE_COUNTER : ScheduleTable3
 *
 * ・repeat (繰り返し指定)
 *  AK_TRUE  : ScheduleTable1, ScheduleTable3
 *  AK_FALSE : ScheduleTable2, ScheduleTable4
 *
 * ・ststat (スケジュールテーブルの状態)
 *  SCHEDULETABLE_STOPPED                 : ScheduleTable2
 *  SCHEDULETABLE_NEXT                    : ScheduleTable2
 *  SCHEDULETABLE_RUNNING                 : ScheduleTable1, ScheduleTable3
 *  SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS : ScheduleTable2, ScheduleTable4
 *
 * ・duration (スケジュールテーブル周期)
 *  10 : ScheduleTable1
 *  20 : ScheduleTable2
 *  11 : ScheduleTable3, ScheduleTable4
 *
 * ・expoint (満了アクションの定義)
 *  <ScheduleTable1の場合>
 *  オフセット : 2
 *    満了アクション : Task1_1を起動
 *  オフセット : 4
 *    満了アクション : Task1_2を起動
 *    満了アクション : Task1_3を起動
 *  オフセット : 6
 *    満了アクション : Task1_4を起動
 *    満了アクション : Task1_5を起動
 *    満了アクション : Task1_6を起動
 *
 *  <ScheduleTable2の場合>
 *  オフセット : 3
 *    満了アクション : Task2_1にEvent2_1をセット
 *  オフセット : 8
 *    満了アクション : Task2_2にEvent2_2をセット
 *    満了アクション : Task2_3にEvent2_3をセット
 *  オフセット : 13
 *    満了アクション : Task2_4にEvent2_4をセット
 *    満了アクション : Task2_5にEvent2_5をセット
 *    満了アクション : Task2_6にEvent2_6をセット
 *
 *  <ScheduleTable3の場合>
 *  オフセット : 5
 *    満了アクション : Task3_1を起動
 *    満了アクション : Task3_1にEvent3_1をセット
 *  オフセット : 10
 *    満了アクション : Task3_2を起動
 *    満了アクション : Task3_3を起動
 *    満了アクション : Task3_2にEvent3_2をセット
 *    満了アクション : Task3_3にEvent3_3をセット
 *  オフセット : 15
 *    満了アクション : Task3_4を起動
 *    満了アクション : Task3_5を起動
 *    満了アクション : Task3_6を起動
 *    満了アクション : Task3_4にEvent3_4をセット
 *    満了アクション : Task3_5にEvent3_5をセット
 *    満了アクション : Task3_6にEvent3_6をセット
 *
 *  <ScheduleTable4の場合>
 *  オフセット : 2
 *    満了アクション : Task4_1を起動
 *
 * ・syncstrategy (同期方法)
 *  AK_NONE     : ScheduleTable1, ScheduleTable3
 *  AK_IMPLICIT : ScheduleTable2, ScheduleTable4
 *
 * ・curval (スケジュールテーブルの現在時刻)
 *  <ScheduleTable1の場合>
 *  1, 7
 *
 *  <ScheduleTable2の場合>
 *  0
 *
 *  <ScheduleTable3の場合>
 *  1
 *
 *  <ScheduleTable4の場合>
 *  0
 *
 * ・stfrom (NextScheduleTable発行後の切換え前スケジュールテーブルID)
 *  ScheduleTable1 : ScheduleTable2
 *
 * ・autostarttype (NextScheduleTable発行後の切換え前スケジュールテーブルID)
 *  AK_ABSOLUTE : ScheduleTable4
 *  AK_RELATIVE : ScheduleTable1
 *
 * ・starttick (自動起動ティック値)
 *  2 : ScheduleTable1
 *  3 : ScheduleTable4
 *
 * 【AktspVerifyScheduleTableApplicationMode()】
 * ・appmode (アプリケーションモード)
 *  MainApp           : ScheduleTable1, ScheduleTable4
 *  APPLICATION_MODE1 : ScheduleTable1
 *  APPLICATION_MODE2 : ScheduleTable4
 *  APPLICATION_MODE3 : ScheduleTable4
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyScheduleTable()】
 *   TESRYデータ   | 確認するスケジュールテーブルのスケジュールテーブルID
 *  ----------------------------------------------------------------------
 *   counter       | ScheduleTable3
 *   repeat        | ScheduleTable3
 *   ststat        | ScheduleTable3
 *   duration      | ScheduleTable3
 *   syncstrategy  | ScheduleTable3
 *   curval        | ScheduleTable1
 *   stfrom        | ScheduleTable2
 *   autostarttype | ScheduleTable1
 *   starttick     | ScheduleTable1
 *
 * 【AktspVerifyScheduleTableExAction()】
 *   TESRYデータ  | 確認するスケジュールテーブルのスケジュールテーブルID
 *  ---------------------------------------------------------------------
 *   offset       | ScheduleTable3
 *
 * 【AktspVerifyScheduleTableApplicationMode()】
 *   TESRYデータ   | 確認するスケジュールテーブルのスケジュールテーブルID
 *  ----------------------------------------------------------------------
 *   appmode       | ScheduleTable1
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyScheduleTableExAction()】
 *   TESRYデータ | 確認するスケジュールテーブルのスケジュールテーブルID
 *  --------------------------------------------------------------------
 *   acttsk      | ScheduleTable3
 *   setevt      | ScheduleTable3
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskVerify)
{
	StatusType		ercd;
	static uint16	bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(2);

		ercd = StartScheduleTableAbs(ScheduleTable1, 1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(3);

		/* ハードウェアカウンタ初期化 */
		ercd = AktspStopHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspInitHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);

		ercd = StartScheduleTableAbs(ScheduleTable3, 5);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(4);

		/* タスクからの確認 */
		CheckAktspVerifyScheduleTable();

		AktspCheckPoint(5);

		/* カテゴリ2 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_F);

		AktspCheckPoint(7);

		/* カテゴリ1 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_B);

		AktspCheckPoint(9);

		/* エラーフックの呼び出し */
		AktspRaiseErrorHook();

		AktspCheckPoint(11);

		/* プロテクションフックの呼び出し */
		AktspRaiseProtectionHook();

		AktspCheckPoint(13);

		/* アラームコールバックの呼び出し */
		ercd = SetRelAlarm(AlarmVerify, 1, 0);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(CounterVerify);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(15);
		/* ポストタスクフックとプレタスクフックの呼び出し */
		hookboot = 1;
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(19);

		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);

		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);

		ercd = NextScheduleTable(ScheduleTable1, ScheduleTable2);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(20);

		/* タスクからの確認 */
		CheckAktspVerifyScheduleTable();

		AktspCheckPoint(21);

		/* カテゴリ2 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_F);

		AktspCheckPoint(23);

		/* カテゴリ1 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_B);

		AktspCheckPoint(25);

		/* エラーフックの呼び出し */
		AktspRaiseErrorHook();

		AktspCheckPoint(27);

		/* プロテクションフックの呼び出し */
		AktspRaiseProtectionHook();

		AktspCheckPoint(29);

		/* アラームコールバックの呼び出し */
		ercd = SetRelAlarm(AlarmVerify, 1, 0);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(CounterVerify);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(31);
		/* ポストタスクフックとプレタスクフックの呼び出し */
		hookboot = 1;
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(35);

		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(Counter1);
		CheckErcd(ercd, E_OK);

		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);
		ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(36);

		/* タスクからの確認 */
		CheckAktspVerifyScheduleTable();

		AktspCheckPoint(37);

		/* カテゴリ2 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_F);

		AktspCheckPoint(39);

		/* カテゴリ1 ISR起動 */
		AktspRaiseInterrupt(AKTSP_INTNO_B);

		AktspCheckPoint(41);

		/* エラーフックの呼び出し */
		AktspRaiseErrorHook();

		AktspCheckPoint(43);

		/* プロテクションフックの呼び出し */
		AktspRaiseProtectionHook();

		AktspCheckPoint(45);

		/* アラームコールバックの呼び出し */
		ercd = SetRelAlarm(AlarmVerify, 1, 0);
		CheckErcd(ercd, E_OK);
		ercd = IncrementCounter(CounterVerify);
		CheckErcd(ercd, E_OK);

		AktspCheckPoint(47);
		/* ポストタスクフックとプレタスクフックの呼び出し */
		hookboot = 1;
	}

	bootcnt++;

	TerminateTask();
}

TASK(Task1_1)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_1\" is done");
	TerminateTask();
}

TASK(Task1_2)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_2\" is done");
	TerminateTask();
}

TASK(Task1_3)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_3\" is done");
	TerminateTask();
}

TASK(Task1_4)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_4\" is done");
	TerminateTask();
}

TASK(Task1_5)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_5\" is done");
	TerminateTask();
}

TASK(Task1_6)
{
	AktspOutputLog_0("Expiry point of ScheduleTable1 \"TaskActivation Task1_6\" is done");
	TerminateTask();
}

TASK(Task2_1)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_1);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_1\" is done");
	TerminateTask();
}

TASK(Task2_2)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_2);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_2\" is done");
	TerminateTask();
}

TASK(Task2_3)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_3);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_3\" is done");
	TerminateTask();
}

TASK(Task2_4)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_4);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_4\" is done");
	TerminateTask();
}

TASK(Task2_5)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_5);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_5\" is done");
	TerminateTask();
}

TASK(Task2_6)
{
	StatusType ercd;

	ercd = WaitEvent(Event2_6);
	CheckErcd(ercd, E_OK);

	AktspOutputLog_0("Expiry point of ScheduleTable2 \"EventSetting Task2_6\" is done");
	TerminateTask();
}

TASK(Task3_1)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_1\" is done");
	TerminateTask();
}

TASK(Task3_2)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_2\" is done");
	TerminateTask();
}

TASK(Task3_3)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_3\" is done");
	TerminateTask();
}

TASK(Task3_4)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_4\" is done");
	TerminateTask();
}

TASK(Task3_5)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_5\" is done");
	TerminateTask();
}

TASK(Task3_6)
{
	AktspOutputLog_0("Expiry point of ScheduleTable3 \"TaskActivation Task3_6\" is done");
	TerminateTask();
}

TASK(Task4_1)
{
	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	static uint16 bootcnt = 0;

	AktspClearIntRequest(AKTSP_INTNO_F);

	if (bootcnt == 0) {
		AktspCheckPoint(6);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(22);
	}
	else {
		AktspCheckPoint(38);
	}

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyScheduleTable();

	bootcnt++;

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	static uint16 bootcnt = 0;

	AktspClearIntRequest(AKTSP_INTNO_B);

	if (bootcnt == 0) {
		AktspCheckPoint(8);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(24);
	}
	else {
		AktspCheckPoint(40);
	}

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyScheduleTable();

	bootcnt++;

	return;
}

void
ErrorHook(StatusType ercd)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(10);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(26);
	}
	else {
		AktspCheckPoint(42);
	}

	/* エラーフックからの確認 */
	CheckAktspVerifyScheduleTable();

	bootcnt++;

	return;
}

ProtectionReturnType
ProtectionHook(StatusType FatalError)
{
	static uint16 bootcnt = 0;

	AktspProtectionHookInit();
	if (FatalError == E_OS_STACKFAULT) {
		AktspOutputLog_0("## Stack overflow is detected !!");
		AktspSetCpState(AK_FALSE);
		return(PRO_SHUTDOWN);
	}

	if (bootcnt == 0) {
		AktspCheckPoint(12);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(28);
	}
	else {
		AktspCheckPoint(44);
	}

	/* プロテクションフックからの確認 */
	CheckAktspVerifyScheduleTable();

	bootcnt++;

	return(PRO_IGNORE);
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(14);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(30);
	}
	else {
		AktspCheckPoint(46);
	}

	/* アラームコールバックからの確認 */
	CheckAktspVerifyScheduleTable();

	bootcnt++;

	return;
}

void
PostTaskHook(void)
{
	static uint16 bootcnt = 0;

	if (hookboot == 1) {
		if (bootcnt == 0) {
			AktspCheckPoint(16);
		}
		else if (bootcnt == 1) {
			AktspCheckPoint(32);
		}
		else {
			AktspCheckPoint(48);
		}

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyScheduleTable();

		bootcnt++;
	}

	return;
}

void
PreTaskHook(void)
{
	static uint16 bootcnt = 0;

	if (hookboot == 1) {
		if (bootcnt == 0) {
			AktspCheckPoint(17);
		}
		else if (bootcnt == 1) {
			AktspCheckPoint(33);
		}
		else {
			AktspCheckPoint(49);
		}

		/* プレタスクフックからの確認 */
		CheckAktspVerifyScheduleTable();
		hookboot = 0;

		bootcnt++;
	}

	return;
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	ercd = StopScheduleTable(ScheduleTable1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter2);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter2);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter2);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(1);

	ercd = ActivateTask(Task2_1);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(Task2_2);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(Task2_3);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(Task2_4);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(Task2_5);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(Task2_6);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(18);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(34);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(50);

	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);
	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);
	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);
	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(51);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	TerminateTask();
}

/*
 *  状態確認APIチェック関数
 */
void
CheckAktspVerifyScheduleTable()
{
	StatusType						ercd;
	AktspScheduleTableInfo			vschtbl;
	AktspScheduleTableExactionInfo	vschtblexact;
	static uint16					bootcnt = 0;

	/*
	 *  ScheduleTable1:
	 *    type: SCHEDULE_TABLE
	 *    counter: Counter1
	 *    autostarttype: AK_RELATIVE
	 *    starttick: 2
	 *    appmode:
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 *    repeat: AK_TRUE
	 *    duration: 10
	 *    syncstrategy: AK_NONE
	 *    ststat: SCHEDULETABLE_RUNNING
	 *    curval: 1
	 *    expoint:
	 *      2:
	 *        acttsk:
	 *          - Task1_1
	 *      4:
	 *        acttsk:
	 *          - Task1_2
	 *          - Task1_3
	 *      6:
	 *        acttsk:
	 *          - Task1_4
	 *          - Task1_5
	 *          - Task1_6
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyScheduleTable())
	 */
	if (bootcnt < 8) {
		vschtbl.sm_counter = Counter1;
		vschtbl.sm_repeat = AK_TRUE;
		vschtbl.sm_ststat = SCHEDULETABLE_RUNNING;
		vschtbl.sm_duration = 10;
		vschtbl.sm_syncstrategy = AK_NONE;
		vschtbl.sm_curval = 2;                     /* 正しくは1 */
		vschtbl.sm_autostarttype = AK_ABSOLUTE;    /* 正しくはAK_RELATIVE */
		vschtbl.sm_starttick = 3;                  /* 正しくは2 */

		ercd = AktspVerifyScheduleTable(ScheduleTable1, &vschtbl);
		CheckErcd(E_NOT_OK, ercd);
	}

	/*
	 *  ScheduleTable2チェック
	 *
	 *  ScheduleTable2:
	 *    type: SCHEDULE_TABLE
	 *    counter: Counter1
	 *    repeat: AK_FALSE
	 *    duration: 20
	 *    syncstrategy: AK_NONE
	 *    ststat: SCHEDULETABLE_NEXT
	 *    expoint:
	 *      3:
	 *        setevt:
	 *          - Task2_1: Event2_1
	 *      8:
	 *        setevt:
	 *          - Task2_2: Event2_2
	 *          - Task2_3: Event2_3
	 *      13:
	 *        setevt:
	 *          - Task2_4: Event2_4
	 *          - Task2_5: Event2_5
	 *          - Task2_6: Event2_6
	 */
	if (bootcnt >= 8 && bootcnt < 16) {
		vschtbl.sm_counter = Counter1;
		vschtbl.sm_repeat = AK_FALSE;
		vschtbl.sm_ststat = SCHEDULETABLE_NEXT;
		vschtbl.sm_stfrom = ScheduleTable3; /* 正しくはScheduleTable1 */
		vschtbl.sm_duration = 20;
		vschtbl.sm_syncstrategy = AK_NONE;
		vschtbl.sm_starttick = 0;
		vschtbl.sm_autostarttype = AKTSP_INVALID_VALUE;

		ercd = AktspVerifyScheduleTable(ScheduleTable2, &vschtbl);
		CheckErcd(E_NOT_OK, ercd);
	}

	/*
	 *  ScheduleTable3:
	 *    type: SCHEDULE_TABLE
	 *    counter: DUMMY_HARDWARE_COUNTER
	 *    repeat: AK_TRUE
	 *    duration: 11
	 *    syncstrategy: AK_NONE
	 *    ststat: SCHEDULETABLE_RUNNING
	 *    curval: 1
	 *    expoint:
	 *      3:
	 *        acttsk:
	 *          - Task3_1
	 *        setevt:
	 *          - Task3_1: Event3_1
	 *      7:
	 *        acttsk:
	 *          - Task3_2
	 *          - Task3_3
	 *        setevt:
	 *          - Task3_2: Event3_2
	 *          - Task3_3: Event3_3
	 *      9:
	 *        acttsk:
	 *          - Task3_4
	 *          - Task3_5
	 *          - Task3_6
	 *        setevt:
	 *          - Task3_4: Event3_4
	 *          - Task3_5: Event3_5
	 *          - Task3_6: Event3_6
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyScheduleTable())
	 */
	vschtbl.sm_counter = Counter1;                  /* 正しくはDUMMY_HARDWARE_COUNTER */
	vschtbl.sm_repeat = AK_FALSE;                   /* 正しくはAK_TRUE */
	vschtbl.sm_ststat = SCHEDULETABLE_STOPPED;      /* 正しくはSCHEDULETABLE_RUNNING_AND_SYNCHRONOUS */
	vschtbl.sm_duration = 10;                       /* 正しくは11 */
	vschtbl.sm_syncstrategy = AK_NONE;              /* 正しくはAK_IMPLICIT */
	vschtbl.sm_starttick = 0;
	vschtbl.sm_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyScheduleTable(ScheduleTable3, &vschtbl);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyScheduleTableExAction())
	 */
	vschtblexact.sem_offset = 2; /* 正しくは3 */
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_1;
	vschtblexact.sem_event = Event3_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 1, &vschtblexact);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyScheduleTableApplicationMode())
	 */
	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable1, APPLICATION_MODE3); /* 正しくは第2引数がMainApp，もしくはAPPLICATION_MODE1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyScheduleTableExAction())
	 */
	vschtblexact.sem_offset = 3;
	vschtblexact.sem_expprop = AK_ST_ATSK; /* 正しくはAK_ST_SEVT */
	vschtblexact.sem_task = Task2_1;       /* 正しくはTask3_1 */
	vschtblexact.sem_event = Event2_1;     /* 正しくはEvent3_1 */

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	/*
	 *  各スケジュールテーブルの状態確認
	 */

	/*
	 *  ScheduleTable1チェック
	 *
	 *  ScheduleTable1:
	 *    type: SCHEDULE_TABLE
	 *    counter: Counter1
	 *    autostarttype: AK_RELATIVE
	 *    starttick: 2
	 *    appmode:
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 *    repeat: AK_TRUE
	 *    duration: 10
	 *    syncstrategy: AK_NONE
	 *    ststat: SCHEDULETABLE_RUNNING
	 *    curval: 1
	 *    expoint:
	 *      2:
	 *        acttsk:
	 *          - Task1_1
	 *      4:
	 *        acttsk:
	 *          - Task1_2
	 *          - Task1_3
	 *      6:
	 *        acttsk:
	 *          - Task1_4
	 *          - Task1_5
	 *          - Task1_6
	 */
	vschtbl.sm_counter = Counter1;
	vschtbl.sm_repeat = AK_TRUE;
	if (bootcnt < 8) {
		vschtbl.sm_ststat = SCHEDULETABLE_RUNNING;
		vschtbl.sm_curval = 1;
	}
	else if (bootcnt < 16) {
		vschtbl.sm_ststat = SCHEDULETABLE_RUNNING;
		vschtbl.sm_curval = 7;
	}
	else {
		vschtbl.sm_ststat = SCHEDULETABLE_STOPPED;
	}
	vschtbl.sm_duration = 10;
	vschtbl.sm_syncstrategy = AK_NONE;
	vschtbl.sm_autostarttype = AK_RELATIVE;
	vschtbl.sm_starttick = 2;

	ercd = AktspVerifyScheduleTable(ScheduleTable1, &vschtbl);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 2;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 4;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_2;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 4;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_3;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 6;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_4;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 6;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_5;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 6;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task1_6;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable1, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable1, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable1, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);

	/*
	 *  ScheduleTable2チェック
	 *
	 *  ScheduleTable2:
	 *    type: SCHEDULE_TABLE
	 *    counter: Counter1
	 *    repeat: AK_FALSE
	 *    duration: 20
	 *    syncstrategy: AK_NONE
	 *    ststat: SCHEDULETABLE_STOPPED
	 *    expoint:
	 *      3:
	 *        setevt:
	 *          - Task2_1: Event2_1
	 *      8:
	 *        setevt:
	 *          - Task2_2: Event2_2
	 *          - Task2_3: Event2_3
	 *      13:
	 *        setevt:
	 *          - Task2_4: Event2_4
	 *          - Task2_5: Event2_5
	 *          - Task2_6: Event2_6
	 */
	vschtbl.sm_counter = Counter1;
	vschtbl.sm_repeat = AK_FALSE;
	if (bootcnt < 8) {
		vschtbl.sm_ststat = SCHEDULETABLE_STOPPED;
	}
	else if (bootcnt < 16) {
		vschtbl.sm_ststat = SCHEDULETABLE_NEXT;
		vschtbl.sm_stfrom = ScheduleTable1;
	}
	else {
		vschtbl.sm_ststat = SCHEDULETABLE_RUNNING;
		vschtbl.sm_curval = 1;
	}
	vschtbl.sm_duration = 20;
	vschtbl.sm_syncstrategy = AK_NONE;
	vschtbl.sm_starttick = 0;
	vschtbl.sm_autostarttype = AKTSP_INVALID_VALUE;

	ercd = AktspVerifyScheduleTable(ScheduleTable2, &vschtbl);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 3;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_1;
	vschtblexact.sem_event = Event2_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 8;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_2;
	vschtblexact.sem_event = Event2_2;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 8;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_3;
	vschtblexact.sem_event = Event2_3;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 13;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_4;
	vschtblexact.sem_event = Event2_4;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 13;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_5;
	vschtblexact.sem_event = Event2_5;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 13;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task2_6;
	vschtblexact.sem_event = Event2_6;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable2, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	/*
	 *  ScheduleTable3チェック
	 *
	 *  ScheduleTable3:
	 *    type: SCHEDULE_TABLE
	 *    counter: DUMMY_HARDWARE_COUNTER
	 *    repeat: AK_TRUE
	 *    duration: 11
	 *    syncstrategy: AK_IMPLICIT
	 *    ststat: SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS
	 *    curval: 1
	 *    expoint:
	 *      3:
	 *        acttsk:
	 *          - Task3_1
	 *        setevt:
	 *          - Task3_1: Event3_1
	 *      7:
	 *        acttsk:
	 *          - Task3_2
	 *          - Task3_3
	 *        setevt:
	 *          - Task3_2: Event3_2
	 *          - Task3_3: Event3_3
	 *      9:
	 *        acttsk:
	 *          - Task3_4
	 *          - Task3_5
	 *          - Task3_6
	 *        setevt:
	 *          - Task3_4: Event3_4
	 *          - Task3_5: Event3_5
	 *          - Task3_6: Event3_6
	 */
	vschtbl.sm_counter = DUMMY_HARDWARE_COUNTER;
	vschtbl.sm_repeat = AK_TRUE;
	vschtbl.sm_ststat = SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS;
	vschtbl.sm_duration = 11;
	vschtbl.sm_syncstrategy = AK_IMPLICIT;
	vschtbl.sm_starttick = 0;
	vschtbl.sm_autostarttype = AKTSP_INVALID_VALUE;
	if (bootcnt < 8) {
		vschtbl.sm_curval = 1;
	}
	else if (bootcnt < 16) {
		vschtbl.sm_curval = 5;
	}
	else {
		vschtbl.sm_curval = 8;
	}

	ercd = AktspVerifyScheduleTable(ScheduleTable3, &vschtbl);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 3;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 3;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_1;
	vschtblexact.sem_event = Event3_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 7;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_2;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 7;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_2;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 7;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_2;
	vschtblexact.sem_event = Event3_2;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 7;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_3;
	vschtblexact.sem_event = Event3_3;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 2, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_4;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_5;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task3_6;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_4;
	vschtblexact.sem_event = Event3_4;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_5;
	vschtblexact.sem_event = Event3_5;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 9;
	vschtblexact.sem_expprop = AK_ST_SEVT;
	vschtblexact.sem_task = Task3_6;
	vschtblexact.sem_event = Event3_6;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable3, 3, &vschtblexact);
	CheckErcd(E_OK, ercd);

	/*
	 *  ScheduleTable4チェック
	 *
	 *  ScheduleTable4:
	 *    type: SCHEDULE_TABLE
	 *    counter: Counter2
	 *    autostarttype: AK_ABSOLUTE
	 *    starttick: 3
	 *    appmode:
	 *      - MainApp
	 *      - APPLICATION_MODE2
	 *      - APPLICATION_MODE3
	 *    repeat: AK_FALSE
	 *    duration: 11
	 *    syncstrategy: AK_IMPLICIT
	 *    ststat: SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS
	 *    curval: 0
	 *    expoint:
	 *      2:
	 *        acttsk:
	 *          - Task4_1
	 */
	vschtbl.sm_counter = Counter2;
	vschtbl.sm_repeat = AK_FALSE;
	vschtbl.sm_ststat = SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS;
	vschtbl.sm_duration = 11;
	vschtbl.sm_syncstrategy = AK_IMPLICIT;
	vschtbl.sm_autostarttype = AK_ABSOLUTE;
	vschtbl.sm_starttick = 3;
	vschtbl.sm_curval = 0;

	ercd = AktspVerifyScheduleTable(ScheduleTable4, &vschtbl);
	CheckErcd(E_OK, ercd);

	vschtblexact.sem_offset = 2;
	vschtblexact.sem_expprop = AK_ST_ATSK;
	vschtblexact.sem_task = Task4_1;

	ercd = AktspVerifyScheduleTableExaction(ScheduleTable4, 1, &vschtblexact);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable4, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable4, APPLICATION_MODE2);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyScheduleTableApplicationMode(ScheduleTable4, APPLICATION_MODE3);
	CheckErcd(E_OK, ercd);

	bootcnt++;

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
