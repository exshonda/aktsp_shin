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

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot[2] = {0};

TASK(MainTask)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_0, 7);

	ercd = ActivateTask(RunTask0);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_0, 28);

	AktspBarrierSync(1, 2);
	ShutdownAllCores(E_OK);
}

TASK(MainTask1)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_1, 7);

	ercd = ActivateTask(RunTask1);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_1, 28);

	AktspBarrierSync(1, 2);
	TerminateTask();
}

TASK(DummyTask)
{
	AktspMcCheckPoint(OS_CORE_ID_0, 0);
}

TASK(RunTask0)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_0, 8);

	/* 実行中のタスクからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 9);

	AktspMcCheckPoint(OS_CORE_ID_0, 10);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspMcCheckPoint(OS_CORE_ID_0, 17);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify0, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify0);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_0, 21);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot[OS_CORE_ID_0] = 1;
	TerminateTask();
}

TASK(RunTask1)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_1, 8);

	/* 実行中のタスクからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 9);

	AktspMcCheckPoint(OS_CORE_ID_1, 10);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspMcCheckPoint(OS_CORE_ID_1, 17);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify1, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify1);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_1, 21);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot[OS_CORE_ID_1] = 1;
	TerminateTask();
}

void
StartupHook(void)
{
	AktspMcCheckPoint(GetCoreID(), 1);

	/* スタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 2);

	AktspMcCheckPoint(GetCoreID(), 3);

	return;
}

void
StartupHook_OSAP_SELF_CORE(void){
	AktspMcCheckPoint(GetCoreID(), 4);

	/* OSAP固有のスタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 5);

	AktspMcCheckPoint(GetCoreID(), 6);

	return;
}

void
StartupHook_OSAP_OTHER_OTHER_CORE(void){
	AktspMcCheckPoint(GetCoreID(), 4);

	/* OSAP固有のスタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 5);

	AktspMcCheckPoint(GetCoreID(), 6);

	return;
}

void
ErrorHook(StatusType ercd)
{
	AktspMcCheckPoint(GetCoreID(), 11);

	/* エラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 12);

	AktspMcCheckPoint(GetCoreID(), 13);

	return;
}

void
ErrorHook_OSAP_SELF_CORE(StatusType Error){
	AktspMcCheckPoint(GetCoreID(), 14);

	/* OSAP固有のエラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 15);

	AktspMcCheckPoint(GetCoreID(), 16);

	return;
}

void
ErrorHook_OSAP_OTHER_OTHER_CORE(StatusType Error){
	AktspMcCheckPoint(GetCoreID(), 14);

	/* OSAP固有のエラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 15);

	AktspMcCheckPoint(GetCoreID(), 16);

	return;
}

#ifdef ALARMCALLBACK
ALARMCALLBACK(AlarmCallBackVerify0)
{
	AlarmCallBackFunc();

	return;
}

ALARMCALLBACK(AlarmCallBackVerify1)
{
	AlarmCallBackFunc();

	return;
}
#endif /* ALARMCALLBACK */

void
AlarmCallBackFunc(void)
{
	AktspMcCheckPoint(GetCoreID(), 18);

	/* アラームコールバックからプロテクションフックを起動(SC1の場合) */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 19);

	AktspMcCheckPoint(GetCoreID(), 20);

	return;
}

void
PostTaskHook(void)
{
	if (hookboot[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 22);

		/* ポストタスクフックからプロテクションフックを起動 */
		AktspRaiseProtectionHook();
		AktspMcWaitCheckPoint(GetCoreID(), 23);

		AktspMcCheckPoint(GetCoreID(), 24);
	}
	return;
}

void
PreTaskHook(void)
{
	if (hookboot[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 25);

		/* プレタスクフックからプロテクションフックを起動 */
		AktspRaiseProtectionHook();
		AktspMcWaitCheckPoint(GetCoreID(), 26);

		AktspMcCheckPoint(GetCoreID(), 27);

		hookboot[GetCoreID()] = 0;
	}
	return;
}

void
ShutdownHook(StatusType Error)
{
	AktspMcCheckPoint(GetCoreID(), 32);

	/* シャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 33);

	AktspMcCheckPoint(GetCoreID(), 34);
	if (GetCoreID() == OS_CORE_ID_0) {
		AktspOutputLog_0("All check points passed.");
	}
}

void
ShutdownHook_OSAP_SELF_CORE(StatusType Error){
	AktspMcCheckPoint(GetCoreID(), 29);

	/* OSAP固有のシャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 30);

	AktspMcCheckPoint(GetCoreID(), 31);
	return;
}

void
ShutdownHook_OSAP_OTHER_OTHER_CORE(StatusType Error){
	AktspMcCheckPoint(GetCoreID(), 29);

	/* OSAP固有のシャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspMcWaitCheckPoint(GetCoreID(), 30);

	AktspMcCheckPoint(GetCoreID(), 31);
	return;
}

ProtectionReturnType
ProtectionHook(StatusType FatalError)
{
	static uint16 bootcnt[2] = {0};

	AktspProtectionHookInit();
	if (FatalError == E_OS_STACKFAULT) {
		AktspOutputLog_0("## Stack overflow is detected !!");
		AktspSetCpState(AK_FALSE);
		return(PRO_SHUTDOWN);
	}

	if (bootcnt[GetCoreID()] == 0) {
		AktspOutputLog_0("[StartupHook] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 2);
	}
	else if (bootcnt[GetCoreID()] == 1) {
		AktspOutputLog_0("[StartupHook(OSAP)] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 5);
	}
	else if (bootcnt[GetCoreID()] == 2) {
		AktspOutputLog_0("[Task] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 9);
	}
	else if (bootcnt[GetCoreID()] == 3) {
		AktspOutputLog_0("[ErrorHook] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 12);
	}
	else if (bootcnt[GetCoreID()] == 4) {
		AktspOutputLog_0("[ErrorHook(OSAP)] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 15);
	}
	else if (bootcnt[GetCoreID()] == 5) {
		AktspOutputLog_0("[AlarmCallBack] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 19);
	}
	else if (bootcnt[GetCoreID()] == 6) {
		AktspOutputLog_0("[PosttaskHook] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 23);
	}
	else if (bootcnt[GetCoreID()] == 7) {
		AktspOutputLog_0("[PretaskHook] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 26);
	}
	else if (bootcnt[GetCoreID()] == 8) {
		AktspOutputLog_0("[ShutdownHook(OSAP)] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 30);
	}
	else if (bootcnt[GetCoreID()] == 9) {
		AktspOutputLog_0("[ShutdownHook] AktspRaiseProtectionHook() : OK");
		AktspMcCheckPoint(GetCoreID(), 33);
	}
	else {
		AktspMcCheckPoint(GetCoreID(), 0);
	}

	bootcnt[GetCoreID()]++;

	return(PRO_IGNORE);
}

/*
 *  User main
 */
sint32
main(void){
	StatusType ercd;
	CoreIdType	i;

	if (GetCoreID() == OS_CORE_ID_MASTER) {
		AktspInitializeTestLib();
		AktspInitializeTestLibEachCore();
		for (i = 0; i < TNUM_HWCORE; i++) {
			if (i != OS_CORE_ID_MASTER) {
				StartCore(i, &ercd);
				CheckErcd(ercd, E_OK);
			}
		}
		StartOS(MainApp);
	}
	else {
		AktspInitializeTestLibEachCore();
		StartOS(DONOTCARE);
	}
	AktspInfiniteLoop();

	return 0;
}
