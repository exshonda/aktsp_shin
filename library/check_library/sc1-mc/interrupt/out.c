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

static uint32 hookboot[2] = {0};

TASK(MainTask)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_0, 7);

	ercd = ActivateTask(RunTask0);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_0, 30);

	/* 優先度が異なる割込みを、低い順に発生させる */
#ifdef AKTSP_INTNO_D
	AktspRaiseInterrupt(AKTSP_INTNO_D);
#else
	FuncIntnoD();
#endif /* AKTSP_INTNO_D */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 31);

	AktspMcCheckPoint(OS_CORE_ID_0, 38);

	AktspBarrierSync(1, 2);
	ShutdownAllCores(E_OK);
}

TASK(MainTask1)
{
	StatusType ercd;

	AktspMcCheckPoint(OS_CORE_ID_1, 7);

	ercd = ActivateTask(RunTask1);
	CheckErcd(ercd, E_OK);

	AktspMcCheckPoint(OS_CORE_ID_1, 30);

	/* 優先度が異なる割込みを、低い順に発生させる */
#ifdef AKTSP_INTNO_CORE2_D
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_D);
#else
	FuncIntnoD();
#endif /* AKTSP_INTNO_CORE2_D */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 31);

	AktspMcCheckPoint(OS_CORE_ID_1, 38);

	AktspBarrierSync(1, 2);
	TerminateTask();
}

TASK(DummyTask)
{
	AktspMcCheckPoint(OS_CORE_ID_0, 0);
}

TASK(RunTask0)
{
#ifdef ALARMCALLBACK
	StatusType ercd;
#endif /* ALARMCALLBACK */

	AktspMcCheckPoint(OS_CORE_ID_0, 8);

	/* 実行中のタスクから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 9);

	AktspMcCheckPoint(OS_CORE_ID_0, 10);

	/* カテゴリ2 ISRを起こす */
#ifdef AKTSP_INTNO_C
	AktspRaiseInterrupt(AKTSP_INTNO_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_C */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 11);

	AktspMcCheckPoint(OS_CORE_ID_0, 12);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspMcCheckPoint(OS_CORE_ID_0, 19);

	/* アラームコールバックの呼び出し */
#ifdef ALARMCALLBACK
	ercd = SetRelAlarm(AlarmVerify0, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify0);
	CheckErcd(ercd, E_OK);
#else
	AlarmCallBackFunc();
#endif /* ALARMCALLBACK */

	AktspMcCheckPoint(OS_CORE_ID_0, 23);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot[OS_CORE_ID_0] = 1;
	TerminateTask();
}

TASK(RunTask1)
{
#ifdef ALARMCALLBACK
	StatusType ercd;
#endif /* ALARMCALLBACK */

	AktspMcCheckPoint(OS_CORE_ID_1, 8);

	/* 実行中のタスクから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_CORE2_A
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_CORE2_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 9);

	AktspMcCheckPoint(OS_CORE_ID_1, 10);

	/* カテゴリ2 ISRを起こす */
#ifdef AKTSP_INTNO_CORE2_C
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_CORE2_C */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 11);

	AktspMcCheckPoint(OS_CORE_ID_1, 12);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspMcCheckPoint(OS_CORE_ID_1, 19);

	/* アラームコールバックの呼び出し */
#ifdef ALARMCALLBACK
	ercd = SetRelAlarm(AlarmVerify1, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify1);
	CheckErcd(ercd, E_OK);
#else
	AlarmCallBackFunc();
#endif /* ALARMCALLBACK */

	AktspMcCheckPoint(OS_CORE_ID_1, 23);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot[OS_CORE_ID_1] = 1;
	TerminateTask();
}

void
StartupHook(void)
{
	AktspMcCheckPoint(GetCoreID(), 1);

	/* スタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_A);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
		break;
	}
#else
	FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
	AktspMcWaitCheckPoint(GetCoreID(), 2);

	AktspMcCheckPoint(GetCoreID(), 3);

	return;
}

void
StartupHook_OSAP_SELF_CORE(void){
	AktspMcCheckPoint(OS_CORE_ID_0, 4);

	/* OSAP固有のスタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 5);

	AktspMcCheckPoint(OS_CORE_ID_0, 6);

	return;
}

void
StartupHook_OSAP_OTHER_OTHER_CORE(void){
	AktspMcCheckPoint(OS_CORE_ID_1, 4);

	/* OSAP固有のスタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_CORE2_A
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_CORE2_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 5);

	AktspMcCheckPoint(OS_CORE_ID_1, 6);

	return;
}

void
ErrorHook(StatusType ercd)
{
	AktspMcCheckPoint(GetCoreID(), 13);

	/* エラーフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_A);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
		break;
	}
#else
	FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
	AktspMcWaitCheckPoint(GetCoreID(), 14);

	AktspMcCheckPoint(GetCoreID(), 15);

	return;
}

void
ErrorHook_OSAP_SELF_CORE(StatusType Error){
	AktspMcCheckPoint(OS_CORE_ID_0, 16);

	/* OSAP固有のエラーフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 17);

	AktspMcCheckPoint(OS_CORE_ID_0, 18);

	return;
}

void
ErrorHook_OSAP_OTHER_OTHER_CORE(StatusType Error){
	AktspMcCheckPoint(OS_CORE_ID_1, 16);

	/* OSAP固有のエラーフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_CORE2_A
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_CORE2_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 17);

	AktspMcCheckPoint(OS_CORE_ID_1, 18);

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
	AktspMcCheckPoint(GetCoreID(), 20);

	/* アラームコールバックから割込みを発生(SC1の場合) */

	/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_A);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
		break;
	}
#else
	FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
	AktspMcWaitCheckPoint(GetCoreID(), 21);

	AktspMcCheckPoint(GetCoreID(), 22);

	return;
}

void
PostTaskHook(void)
{
	if (hookboot[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 24);

		/* ポストタスクフックから割込みを発生 */

		/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
		switch (GetCoreID()) {
		case OS_CORE_ID_0:
			AktspRaiseInterrupt(AKTSP_INTNO_A);
			break;
		case OS_CORE_ID_1:
			AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
			break;
		}
#else
		FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
		AktspMcWaitCheckPoint(GetCoreID(), 25);

		AktspMcCheckPoint(GetCoreID(), 26);
	}
	return;
}

void
PreTaskHook(void)
{
	if (hookboot[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 27);

		/* プレタスクフックから割込みを発生 */

		/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
		switch (GetCoreID()) {
		case OS_CORE_ID_0:
			AktspRaiseInterrupt(AKTSP_INTNO_A);
			break;
		case OS_CORE_ID_1:
			AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
			break;
		}
#else
		FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
		AktspMcWaitCheckPoint(GetCoreID(), 28);

		AktspMcCheckPoint(GetCoreID(), 29);

		hookboot[GetCoreID()] = 0;
	}
	return;
}

void
ShutdownHook(StatusType Error)
{
	AktspBarrierSync(3, 2);
	AktspMcCheckPoint(GetCoreID(), 42);

	/* シャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_A);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
		break;
	}
#else
	FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
	AktspMcWaitCheckPoint(GetCoreID(), 43);

	AktspMcCheckPoint(GetCoreID(), 44);
	if (GetCoreID() == OS_CORE_ID_0) {
		AktspOutputLog_0("All check points passed.");
	}
}

void ShutdownHook_OSAP_SELF_CORE(StatusType Error){
	AktspBarrierSync(2, 2);
	AktspMcCheckPoint(OS_CORE_ID_0, 39);

	/* OSAP固有のシャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_0, 40);

	AktspMcCheckPoint(OS_CORE_ID_0, 41);
}

void ShutdownHook_OSAP_OTHER_OTHER_CORE(StatusType Error){
	AktspBarrierSync(2, 2);
	AktspMcCheckPoint(OS_CORE_ID_1, 39);

	/* OSAP固有のシャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_CORE2_A
	AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_CORE2_A */
	AktspMcWaitCheckPoint(OS_CORE_ID_1, 40);

	AktspMcCheckPoint(OS_CORE_ID_1, 41);
}

#ifdef AKTSP_INTNO_A
AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_A, AKTG_C1ISR_COMMON_AKTSP_INTNO_A_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_A_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_A);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_A) : OK");
	FuncIntnoA();

	return;
}
#endif /* AKTSP_INTNO_A */

#ifdef AKTSP_INTNO_CORE2_A
AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_CORE2_A, AKTG_C1ISR_COMMON_AKTSP_INTNO_CORE2_A_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_CORE2_A_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_CORE2_A);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A) : OK");
	FuncIntnoA();

	return;
}
#endif /* AKTSP_INTNO_CORE2_A */

void
FuncIntnoA(void)
{
	static uint16 bootcnt[2] = {0};

	if (bootcnt[GetCoreID()] == 0) {
		AktspMcCheckPoint(GetCoreID(), 2);
	}
	else if (bootcnt[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 5);
	}
	else if (bootcnt[GetCoreID()] == 2) {
		AktspMcCheckPoint(GetCoreID(), 9);
	}
	else if (bootcnt[GetCoreID()] == 3) {
		AktspMcCheckPoint(GetCoreID(), 14);
	}
	else if (bootcnt[GetCoreID()] == 4) {
		AktspMcCheckPoint(GetCoreID(), 17);
	}
	else if (bootcnt[GetCoreID()] == 5) {
		AktspMcCheckPoint(GetCoreID(), 21);
	}
	else if (bootcnt[GetCoreID()] == 6) {
		AktspMcCheckPoint(GetCoreID(), 25);
	}
	else if (bootcnt[GetCoreID()] == 7) {
		AktspMcCheckPoint(GetCoreID(), 28);
	}
	else if (bootcnt[GetCoreID()] == 8) {
		AktspMcCheckPoint(GetCoreID(), 34);
	}
	else if (bootcnt[GetCoreID()] == 9) {
		AktspMcCheckPoint(GetCoreID(), 40);
	}
	else if (bootcnt[GetCoreID()] == 10) {
		AktspMcCheckPoint(GetCoreID(), 43);
	}
	else {
		AktspMcCheckPoint(GetCoreID(), 0);
	}

	bootcnt[GetCoreID()]++;
	return;
}

#ifdef AKTSP_INTNO_B
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_B)
{
	AktspClearIntRequest(AKTSP_INTNO_B);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_B) : OK");
	FuncIntnoB();

	return;
}
#endif /* AKTSP_INTNO_B */

#ifdef AKTSP_INTNO_CORE2_B
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_CORE2_B)
{
	AktspClearIntRequest(AKTSP_INTNO_CORE2_B);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_CORE2_B) : OK");
	FuncIntnoB();

	return;
}
#endif /* AKTSP_INTNO_CORE2_B */

void
FuncIntnoB(void)
{
	AktspMcCheckPoint(GetCoreID(), 33);
#if defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_A);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_A);
		break;
	}
#else
	FuncIntnoA();
#endif /* defined(AKTSP_INTNO_A) && defined(AKTSP_INTNO_CORE2_A) */
	AktspMcWaitCheckPoint(GetCoreID(), 34);
	AktspMcCheckPoint(GetCoreID(), 35);

	return;
}

#ifdef AKTSP_INTNO_C
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_C)
{
	AktspClearIntRequest(AKTSP_INTNO_C);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_C) : OK");
	FuncIntnoC();

	return;
}
#endif /* AKTSP_INTNO_C */

#ifdef AKTSP_INTNO_CORE2_C
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_CORE2_C)
{
	AktspClearIntRequest(AKTSP_INTNO_CORE2_C);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_CORE2_C) : OK");
	FuncIntnoC();

	return;
}
#endif /* AKTSP_INTNO_CORE2_C */

void
FuncIntnoC(void)
{
	static uint16 bootcnt[2] = {0};

	if (bootcnt[GetCoreID()] == 0) {
		AktspMcCheckPoint(GetCoreID(), 11);
	}
	else if (bootcnt[GetCoreID()] == 1) {
		AktspMcCheckPoint(GetCoreID(), 32);
#if defined(AKTSP_INTNO_B) && defined(AKTSP_INTNO_CORE2_B)
		switch (GetCoreID()) {
		case OS_CORE_ID_0:
			AktspRaiseInterrupt(AKTSP_INTNO_B);
			break;
		case OS_CORE_ID_1:
			AktspRaiseInterrupt(AKTSP_INTNO_CORE2_B);
			break;
		}
#else
		FuncIntnoB();
#endif /* defined(AKTSP_INTNO_B) && defined(AKTSP_INTNO_CORE2_B) */
		AktspMcWaitCheckPoint(GetCoreID(), 33);
		AktspMcCheckPoint(GetCoreID(), 36);
	}
	else {
		AktspMcCheckPoint(GetCoreID(), 0);
	}

	bootcnt[GetCoreID()]++;
	return;
}

#ifdef AKTSP_INTNO_D
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_D)
{
	AktspClearIntRequest(AKTSP_INTNO_D);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_D) : OK");
	FuncIntnoD();

	return;
}
#endif /* AKTSP_INTNO_D */

#ifdef AKTSP_INTNO_CORE2_D
ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_CORE2_D)
{
	AktspClearIntRequest(AKTSP_INTNO_CORE2_D);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_CORE2_D) : OK");
	FuncIntnoD();

	return;
}
#endif /* AKTSP_INTNO_CORE2_D */

void
FuncIntnoD(void)
{
	AktspMcCheckPoint(GetCoreID(), 31);
#if defined(AKTSP_INTNO_C) && defined(AKTSP_INTNO_CORE2_C)
	switch (GetCoreID()) {
	case OS_CORE_ID_0:
		AktspRaiseInterrupt(AKTSP_INTNO_C);
		break;
	case OS_CORE_ID_1:
		AktspRaiseInterrupt(AKTSP_INTNO_CORE2_C);
		break;
	}
#else
	FuncIntnoC();
#endif /* defined(AKTSP_INTNO_C) && defined(AKTSP_INTNO_CORE2_C) */
	AktspMcWaitCheckPoint(GetCoreID(), 32);
	AktspMcCheckPoint(GetCoreID(), 37);

	return;
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
				/* E_OS_STATEを発生させて，エラーフックが上がらないことを確認 */
				StartCore(i, &ercd);
				CheckErcd(ercd, E_OS_STATE);
				StartNonAutosarCore(i, &ercd);
				CheckErcd(ercd, E_OS_STATE);
			}
		}
		/* E_OS_IDを発生させて，エラーフックが上がらないことを確認 */
		StartCore(TNUM_HWCORE, &ercd);
		CheckErcd(ercd, E_OS_ID);
		StartNonAutosarCore(TNUM_HWCORE, &ercd);
		CheckErcd(ercd, E_OS_ID);
		
		/* E_OS_DISABLEDINTを発生させてエラーフックが上がらない事を確認 */
		DisableAllInterrupts();
		SuspendAllInterrupts();
		ResumeAllInterrupts();
		EnableAllInterrupts();
		
		StartOS(MainApp);
	}
	else {
		AktspInitializeTestLibEachCore();
		StartOS(DONOTCARE);
	}
	AktspInfiniteLoop();

	return 0;
}
