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
 *  本テストプログラムでは，以下の割込み発生関数をテストする
 *  ・AktspRaiseInterrupt()
 *  ・AktspClearIntRequest()
 *
 * 【テスト対象のISR】
 *   割込み番号    | 割込み優先度(※) | カテゴリ1/2 ISR
 *  ----------------------------------------------------
 *   AKTSP_INTNO_A | INT_PRI_ISR1     | カテゴリ1 ISR
 *   AKTSP_INTNO_B | INT_PRI_HIGH     | カテゴリ2 ISR
 *   AKTSP_INTNO_C | INT_PRI_MID      | カテゴリ2 ISR
 *   AKTSP_INTNO_D | INT_PRI_LOW      | カテゴリ2 ISR
 *  (※)：out.hにてマクロ定義
 *
 * 【確認する内容】
 *  1) 割込み番号AKTSP_INTNO_AとAKTSP_INTNO_Cの割込みを以下の処理単位か
 *     ら発生させる
 *     ・スタートアップフック                 (AKTSP_INTNO_Aのみ)
 *     ・信頼OSAP固有のスタートアップフック   (AKTSP_INTNO_Aのみ)
 *     ・非信頼OSAP固有のスタートアップフック (AKTSP_INTNO_Aのみ)
 *     ・信頼OSAPに所属するタスク
 *     ・非信頼OSAPに所属するタスク
 *     ・信頼関数
 *     ・エラーフック                         (AKTSP_INTNO_Aのみ)
 *     ・非信頼OSAP固有のエラーフック         (AKTSP_INTNO_Aのみ)
 *     ・信頼OSAP固有のエラーフック           (AKTSP_INTNO_Aのみ)
 *     ・ポストタスクフック                   (AKTSP_INTNO_Aのみ)
 *     ・プレタスクフック                     (AKTSP_INTNO_Aのみ)
 *     ・信頼OSAP固有のシャットダウンフック   (AKTSP_INTNO_Aのみ)
 *     ・非信頼OSAP固有のシャットダウンフック (AKTSP_INTNO_Aのみ)
 *     ・シャットダウンフック                 (AKTSP_INTNO_Aのみ)
 *
 *  2) 優先度が異なるISRを優先度が低い順に発生させる(タスクにて実施)
 *   発生順 | 割込み番号    | 割込み優先度
 *  -----------------------------------------------------
 *   1      | AKTSP_INTNO_D | INT_PRI_LOW
 *   2      | AKTSP_INTNO_C | INT_PRI_MID
 *   3      | AKTSP_INTNO_B | INT_PRI_HIGH
 *   4      | AKTSP_INTNO_A | INT_PRI_ISR1
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(MainTask)
{
	StatusType ercd;

	AktspCheckPoint(10);

	ercd = ActivateTask(TrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(48);

	/* 優先度が異なる割込みを、低い順に発生させる */
#ifdef AKTSP_INTNO_D
	AktspRaiseInterrupt(AKTSP_INTNO_D);
#else
	FuncIntnoD();
#endif /* AKTSP_INTNO_D */
	AktspWaitCheckPoint(49);

	AktspCheckPoint(56);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

TASK(TrustedTask)
{
	StatusType ercd;

	AktspCheckPoint(11);

	/* 信頼OSAPに所属するタスクから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(12);

	AktspCheckPoint(13);

	/* カテゴリ2 ISRを起こす */
#ifdef AKTSP_INTNO_C
	AktspRaiseInterrupt(AKTSP_INTNO_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_C */
	AktspWaitCheckPoint(14);

	AktspCheckPoint(15);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(34);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(41);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot = 1;
	TerminateTask();
}

TASK(NonTrustedTask)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(16);

	/* 非信頼OSAPに所属するタスクから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(17);

	AktspCheckPoint(18);

	/* カテゴリ2 ISRを起こす */
#ifdef AKTSP_INTNO_C
	AktspRaiseInterrupt(AKTSP_INTNO_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_C */
	AktspWaitCheckPoint(19);

	AktspCheckPoint(20);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(26);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(33);

	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(21);

	/* 信頼関数から割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(22);

	AktspCheckPoint(23);

	/* カテゴリ2 ISRを起こす */
#ifdef AKTSP_INTNO_C
	AktspRaiseInterrupt(AKTSP_INTNO_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_C */
	AktspWaitCheckPoint(24);

	AktspCheckPoint(25);

	return E_OK;
}

void
StartupHook(void)
{
	AktspCheckPoint(1);

	/* スタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(2);

	AktspCheckPoint(3);

	return;
}

#if 0
void
StartupHook_NON_TRUSTED_OSAP5(void)
{
	AktspCheckPoint(4);

	/* 非信頼OSAP固有のスタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(5);

	AktspCheckPoint(6);

	return;
}

void
StartupHook_TRUSTED_OSAP5(void)
{
	AktspCheckPoint(7);

	/* 信頼OSAP固有のスタートアップフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(8);

	AktspCheckPoint(9);

	return;
}
#endif

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	/* エラーフックから割込みを発生 */
	/* 非信頼OSAPからの起動 */
	if (bootcnt == 0) {
		AktspCheckPoint(27);

		/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
		AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
		FuncIntnoA();
#endif /* AKTSP_INTNO_A */
		AktspWaitCheckPoint(28);

		AktspCheckPoint(29);
	}
	/* 信頼OSAPからの起動 */
	else if (bootcnt == 1) {
		AktspCheckPoint(35);

		/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
		AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
		FuncIntnoA();
#endif /* AKTSP_INTNO_A */
		AktspWaitCheckPoint(36);

		AktspCheckPoint(37);
	}

	bootcnt++;
	return;
}

#if 0
void
ErrorHook_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(38);

	/* 信頼OSAP固有のエラーフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(39);

	AktspCheckPoint(40);
}

void
ErrorHook_NON_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(30);

	/* 非信頼OSAP固有のエラーフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(31);

	AktspCheckPoint(32);
}
#endif

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(42);

		/* ポストタスクフックから割込みを発生 */

		/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
		AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
		FuncIntnoA();
#endif /* AKTSP_INTNO_A */
		AktspWaitCheckPoint(43);

		AktspCheckPoint(44);
	}
	return;
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(45);

		/* プレタスクフックから割込みを発生 */

		/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
		AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
		FuncIntnoA();
#endif /* AKTSP_INTNO_A */
		AktspWaitCheckPoint(46);

		AktspCheckPoint(47);

		hookboot = 0;
	}
	return;
}

#if 0
void
ShutdownHook_NON_TRUSTED_OSAP5(StatusType Error)
{
	AktspCheckPoint(57);

	/* 非信頼OSAP固有のシャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(58);

	AktspCheckPoint(59);
}

void
ShutdownHook_TRUSTED_OSAP5(StatusType Error)
{
	AktspCheckPoint(60);

	/* 信頼OSAP固有のシャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(61);

	AktspCheckPoint(62);
}
#endif

void
ShutdownHook(StatusType Error)
{
	AktspCheckPoint(63);

	/* シャットダウンフックから割込みを発生 */

	/* カテゴリ1 ISRを起こす */
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(64);

	AktspCheckPoint(65);
	AktspOutputLog_0("All check points passed.");
}

#ifdef AKTSP_INTNO_A
AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_A, AKTG_C1ISR_COMMON_AKTSP_INTNO_A_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_A_ENTITY(void)
{
	AktspClearIntRequest(AKTSP_INTNO_A);

	AktspOutputLog_0("AktspRaiseInterrupt(AKTSP_INTNO_A) : OK");
	FuncIntnoA();

	return;
}
#endif /* AKTSP_INTNO_A */

void
FuncIntnoA(void)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(2);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(5);
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(8);
	}
	else if (bootcnt == 3) {
		AktspCheckPoint(12);
	}
	else if (bootcnt == 4) {
		AktspCheckPoint(17);
	}
	else if (bootcnt == 5) {
		AktspCheckPoint(22);
	}
	else if (bootcnt == 6) {
		AktspCheckPoint(28);
	}
	else if (bootcnt == 7) {
		AktspCheckPoint(31);
	}
	else if (bootcnt == 8) {
		AktspCheckPoint(36);
	}
	else if (bootcnt == 9) {
		AktspCheckPoint(39);
	}
	else if (bootcnt == 10) {
		AktspCheckPoint(43);
	}
	else if (bootcnt == 11) {
		AktspCheckPoint(46);
	}
	else if (bootcnt == 12) {
		AktspCheckPoint(52);
	}
	else if (bootcnt == 13) {
		AktspCheckPoint(58);
	}
	else if (bootcnt == 14) {
		AktspCheckPoint(61);
	}
	else if (bootcnt == 15) {
		AktspCheckPoint(64);
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;
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

void
FuncIntnoB(void)
{
	AktspCheckPoint(51);
#ifdef AKTSP_INTNO_A
	AktspRaiseInterrupt(AKTSP_INTNO_A);
#else
	FuncIntnoA();
#endif /* AKTSP_INTNO_A */
	AktspWaitCheckPoint(52);
	AktspCheckPoint(53);

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

void
FuncIntnoC(void)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(14);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(19);
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(24);
	}
	else if (bootcnt == 3) {
		AktspCheckPoint(50);
#ifdef AKTSP_INTNO_B
		AktspRaiseInterrupt(AKTSP_INTNO_B);
#else
		FuncIntnoB();
#endif /* AKTSP_INTNO_B */
		AktspWaitCheckPoint(51);
		AktspCheckPoint(54);
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;
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

void
FuncIntnoD(void)
{
	AktspCheckPoint(49);
#ifdef AKTSP_INTNO_C
	AktspRaiseInterrupt(AKTSP_INTNO_C);
#else
	FuncIntnoC();
#endif /* AKTSP_INTNO_C */
	AktspWaitCheckPoint(50);
	AktspCheckPoint(55);

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
	AktspInitializeTestLib();
	/* E_OS_DISABLEDINTを発生させてエラーフックが上がらない事を確認 */
	DisableAllInterrupts();
	SuspendAllInterrupts();
	ResumeAllInterrupts();
	EnableAllInterrupts();
	StartOS(MainApp);
	while (1) {}
}
