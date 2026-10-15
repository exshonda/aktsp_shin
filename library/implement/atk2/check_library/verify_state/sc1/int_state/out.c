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
 *  ・AktspVerifyIntState()
 *  ・AktspVerifyDisIntOrder()
 *
 * ※確認する各状態を，以下の番号で管理する
 *  状態 1) AK_DIS_ALL_INT(DisableAllInterruptsによる割込み禁止状態)
 *  状態 2) AK_SUS_ALL_INT(SuspendAllInterruptsによる割込み禁止状態/ネストなし)
 *  状態 3) AK_SUS_ALL_INT(SuspendAllInterruptsによる割込み禁止状態/ネスト3回)
 *  状態 4) AK_SUS_OS_INT(SuspendOSInterruptsによる割込み禁止状態/ネストなし)
 *  状態 5) AK_SUS_OS_INT(SuspendOSInterruptsによる割込み禁止状態/ネスト3回)
 *  状態 6) AK_SUS_ALL_INT/AK_SUS_OS_INT(SuspendAllInterruptsとSuspendOSInterruptsの2回ずつのネスト)
 *          ※AK_SUS_OS_INT → AK_SUS_ALL_INT → AK_SUS_OS_INT → AK_SUS_ALL_INTの順とする
 *  状態 7) 割込み許可状態
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyIntState()】
 * ・istat (割込み禁止状態)
 * ※状態 1)，2)，3)，4)，5)，6)，7)を，以下の処理単位が作成して確認する
 *   ・スタートアップフック
 *   ・タスク
 *   ・C2ISR
 *   ・C1ISR
 *   ・エラーフック
 *   ・プロテクションフック
 *   ・アラームコールバック
 *   ・ポストタスクフック
 *   ・プレタスクフック
 * ※タスクが状態 1)，2)，3)，6)を作成し，以下の処理単位から確認する
 *   ・エラーフック
 *   ・プロテクションフック
 * ※タスクが状態 4)，5)を作成し，以下の処理単位から確認する
 *   ・C1ISR
 *   ・エラーフック
 *   ・プロテクションフック
 *
 * 【AktspVerifyDisIntOrder()】
 * ・割込みのネスト順
 * ※状態 3)，5)，6)に対して確認する
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyIntState()】
 * ・istat (割込み禁止状態)
 * ※異なる値を代入する
 *
 * 《確認できないパラメータに対して不正な値を代入し，ことの確認》
 * 【AktspVerifyDisIntOrder()】
 *  6) AK_SUS_ALL_INT → AK_SUS_OS_INT → AK_SUS_ALL_INT → AK_SUS_OS_INTであることを確認
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskVerify)
{
	StatusType ercd;

	AktspCheckPoint(20);

	/* タスクからの確認 */
	AktspOutputLog_0("--- Verify from Task ---");
	MakeAndVerifyState();

	CheckState();

	AktspCheckPoint(38);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	CheckState();

	AktspCheckPoint(57);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	CheckState();

	AktspCheckPoint(76);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	CheckState();

	AktspCheckPoint(95);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	CheckState();

	AktspCheckPoint(114);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	CheckState();

	AktspCheckPoint(133);

	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

void
MakeAndVerifyState()
{
	static uint16	bootcnt = 0;
	uint16			cp = 0;

	if (bootcnt < 9) {
		cp = 1 + bootcnt * 19;
	}
	else if (bootcnt == 9) {
		cp = 211;
	}
	else {
		AktspCheckPoint(0);
	}

	/* 状態 1)の作成 */
	DisableAllInterrupts();

	AktspCheckPoint(1 + cp);

	/* 確認 */
	CheckAktspVerifyIntState1();

	AktspCheckPoint(2 + cp);

	EnableAllInterrupts();

	AktspCheckPoint(3 + cp);

	/* 状態 2)の作成 */
	SuspendAllInterrupts();

	AktspCheckPoint(4 + cp);

	/* 確認 */
	CheckAktspVerifyIntState2();

	AktspCheckPoint(5 + cp);

	/* 状態 3)の作成 */
	SuspendAllInterrupts();
	SuspendAllInterrupts();

	AktspCheckPoint(6 + cp);

	/* 確認 */
	CheckAktspVerifyIntState3();

	AktspCheckPoint(7 + cp);

	ResumeAllInterrupts();
	ResumeAllInterrupts();
	ResumeAllInterrupts();

	AktspCheckPoint(8 + cp);

	/* 状態 4)の作成 */
	SuspendOSInterrupts();

	AktspCheckPoint(9 + cp);

	/* 確認 */
	CheckAktspVerifyIntState4();

	AktspCheckPoint(10 + cp);

	/* 状態 5)の作成 */
	SuspendOSInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(11 + cp);

	/* 確認 */
	CheckAktspVerifyIntState5();

	AktspCheckPoint(12 + cp);

	ResumeOSInterrupts();
	ResumeOSInterrupts();
	ResumeOSInterrupts();

	AktspCheckPoint(13 + cp);

	/* 状態 6)の作成 */
	SuspendAllInterrupts();
	SuspendOSInterrupts();
	SuspendAllInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(14 + cp);

	/* 確認 */
	CheckAktspVerifyIntState6();

	AktspCheckPoint(15 + cp);

	ResumeOSInterrupts();
	ResumeAllInterrupts();
	ResumeOSInterrupts();
	ResumeAllInterrupts();

	/* 状態 7)の状態完成 */

	AktspCheckPoint(16 + cp);

	/* 確認 */
	CheckAktspVerifyIntState7();

	AktspCheckPoint(17 + cp);

	bootcnt++;
}

TASK(TaskMakeState)
{
	AktspCheckPoint(172);

	/* 状態 1)の作成 */
	DisableAllInterrupts();

	AktspCheckPoint(173);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(175);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(177);

	EnableAllInterrupts();

	AktspCheckPoint(178);

	/* 状態 2)の作成 */
	SuspendAllInterrupts();

	AktspCheckPoint(179);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(181);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(183);

	/* 状態 3)の作成 */
	SuspendAllInterrupts();
	SuspendAllInterrupts();

	AktspCheckPoint(184);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(186);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(188);

	ResumeAllInterrupts();
	ResumeAllInterrupts();
	ResumeAllInterrupts();

	AktspCheckPoint(189);

	/* 状態 4)の作成 */
	SuspendOSInterrupts();

	AktspCheckPoint(190);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(192);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(194);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(196);

	ResumeOSInterrupts();

	CheckState();

	/* 状態 5)の作成 */
	SuspendOSInterrupts();
	SuspendOSInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(197);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(199);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(201);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(203);

	ResumeOSInterrupts();
	ResumeOSInterrupts();
	ResumeOSInterrupts();

	CheckState();

	AktspCheckPoint(204);

	/* 状態 6)の作成 */
	SuspendAllInterrupts();
	SuspendOSInterrupts();
	SuspendAllInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(205);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(207);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	ResumeOSInterrupts();
	ResumeAllInterrupts();
	ResumeOSInterrupts();
	ResumeAllInterrupts();

	CheckState();

	AktspCheckPoint(209);

	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(39);

	/* カテゴリ2 ISRからの確認 */
	AktspOutputLog_0("--- Verify from C2ISR ---");
	MakeAndVerifyState();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	static uint16 bootcnt = 0;

	AktspClearIntRequest(AKTSP_INTNO_B);

	if (bootcnt == 0) {
		AktspCheckPoint(58);

		/* カテゴリ1 ISRからの確認 */
		AktspOutputLog_0("--- Verify from C1ISR ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(191);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(198);
		CheckAktspVerifyIntState5();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return;
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(115);

	/* アラームコールバックからの確認 */
	AktspOutputLog_0("--- Verify from AlarmCallBack ---");
	MakeAndVerifyState();
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(152);
		AktspCheckPoint(153);

		/* プレタスクフックからの確認 */
		AktspOutputLog_0("--- Verify from PreTaskHook ---");
		MakeAndVerifyState();

		hookboot = 0;
	}
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(134);

		/* ポストタスクフックからの確認 */
		AktspOutputLog_0("--- Verify from PostTaskHook ---");
		MakeAndVerifyState();
	}
}

void
ErrorHook(StatusType ercd)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(77);

		AktspOutputLog_0("--- Verify from ErrorHook ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(174);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(180);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 3) {
		AktspCheckPoint(185);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 4) {
		AktspCheckPoint(193);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 5) {
		AktspCheckPoint(200);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 6) {
		AktspCheckPoint(206);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

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
		AktspCheckPoint(96);

		AktspOutputLog_0("--- Verify from ProtectionHook ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) { /* DisableAllInterruptsによる割込み禁止 */
		AktspCheckPoint(176);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 2) { /* SuspendAllInterruptsによる割込み禁止 */
		AktspCheckPoint(182);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 3) { /* SuspendAllInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(187);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 4) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(195);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 5) { /* SuspendOSInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(202);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 6) { /* SuspendAllInterrupts，SuspendOSInterruptsのネストによる割込み禁止 */
		AktspCheckPoint(208);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return(PRO_IGNORE);
}

void
StartupHook(void)
{
	AktspCheckPoint(1);
	AktspOutputLog_0("--- Verify from StartupHook ---");
	MakeAndVerifyState();
}

void
ShutdownHook(StatusType Error)
{
	AktspCheckPoint(211);
	AktspOutputLog_0("--- Verify from ShutdownHook ---");
	MakeAndVerifyState();
	AktspCheckPoint(229);
	AktspOutputLog_0("All check points passed.");
}

TASK(MainTask)
{
	StatusType ercd;

	AktspCheckPoint(19);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	CheckState();

	AktspCheckPoint(171);

	ercd = ActivateTask(TaskMakeState);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(210);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

/*
 *  状態確認APIチェック関数：状態 1)
 */
void
CheckAktspVerifyIntState1(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_DIS_ALL_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_ENABLE;  /* 正しくはAK_DISABLE */
	vint.ism_susallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susosint = AK_DISABLE;  /* 正しくはAK_ENABLE */
	vint.ism_susallcnt = 1;          /* 正しくは0 */
	vint.ism_susoscnt = 1;           /* 正しくは0 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_DISABLE;
	vint.ism_susallint = AK_ENABLE;
	vint.ism_susosint = AK_ENABLE;
	vint.ism_susallcnt = 0;
	vint.ism_susoscnt = 0;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	return;
}

/*
 *  状態確認APIチェック関数：状態 2)
 */
void
CheckAktspVerifyIntState2(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_SUS_ALL_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_ENABLE;  /* 正しくはAK_DISABLE */
	vint.ism_susosint = AK_DISABLE;  /* 正しくはAK_ENABLE */
	vint.ism_susallcnt = 0;          /* 正しくは1 */
	vint.ism_susoscnt = 1;           /* 正しくは0 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_DISABLE;
	vint.ism_susosint = AK_ENABLE;
	vint.ism_susallcnt = 1;
	vint.ism_susoscnt = 0;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyDisIntOrder(1, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);

	return;
}

/*
 *  状態確認APIチェック関数：状態 3)
 */
void
CheckAktspVerifyIntState3(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_SUS_ALL_INT
	 *      - AK_SUS_ALL_INT
	 *      - AK_SUS_ALL_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_ENABLE;  /* 正しくはAK_DISABLE */
	vint.ism_susosint = AK_DISABLE;  /* 正しくはAK_ENABLE */
	vint.ism_susallcnt = 0;          /* 正しくは3 */
	vint.ism_susoscnt = 3;           /* 正しくは0 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_DISABLE;
	vint.ism_susosint = AK_ENABLE;
	vint.ism_susallcnt = 3;
	vint.ism_susoscnt = 0;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyDisIntOrder(1, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(2, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(3, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);

	return;
}

/*
 *  状態確認APIチェック関数：状態 4)
 */
void
CheckAktspVerifyIntState4(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;
	static uint16		bootcnt = 0;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0 : タスク
	 *  1 : カテゴリ2 ISR
	 *  2 : カテゴリ1 ISR
	 *  3 : エラーフック
	 *  4 : アラームコールバック
	 *  5 : ポストタスクフック
	 *  6 : プレタスクフック
	 */

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_SUS_OS_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susosint = AK_ENABLE;   /* 正しくはAK_DISABLE */
	vint.ism_susallcnt = 1;          /* 正しくは0 */
	vint.ism_susoscnt = 0;           /* 正しくは1 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_ENABLE;
	vint.ism_susosint = AK_DISABLE;
	vint.ism_susallcnt = 0;
	vint.ism_susoscnt = 1;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyDisIntOrder(1, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);

	bootcnt++;

	return;
}

/*
 *  状態確認APIチェック関数：状態 5)
 */
void
CheckAktspVerifyIntState5(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;
	static uint16		bootcnt = 0;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0 : タスク
	 *  1 : カテゴリ2 ISR
	 *  2 : カテゴリ1 ISR
	 *  3 : エラーフック
	 *  4 : アラームコールバック
	 *  5 : ポストタスクフック
	 *  6 : プレタスクフック
	 */

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_SUS_OS_INT
	 *      - AK_SUS_OS_INT
	 *      - AK_SUS_OS_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susosint = AK_ENABLE;   /* 正しくはAK_DISABLE */
	vint.ism_susallcnt = 3;          /* 正しくは0 */
	vint.ism_susoscnt = 0;           /* 正しくは3 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);
	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_ENABLE;
	vint.ism_susosint = AK_DISABLE;
	vint.ism_susallcnt = 0;
	vint.ism_susoscnt = 3;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyDisIntOrder(1, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(2, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(3, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);

	bootcnt++;

	return;
}

/*
 *  状態確認APIチェック関数：状態 6)
 */
void
CheckAktspVerifyIntState6(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 *      - AK_SUS_OS_INT
	 *      - AK_SUS_ALL_INT
	 *      - AK_SUS_OS_INT
	 *      - AK_SUS_ALL_INT
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */
	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_ENABLE;  /* 正しくはAK_DISABLE */
	vint.ism_susosint = AK_ENABLE;   /* 正しくはAK_DISABLE */
	vint.ism_susallcnt = 0;          /* 正しくは2 */
	vint.ism_susoscnt = 0;           /* 正しくは2 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyDisIntOrder())
	 */
	ercd = AktspVerifyDisIntOrder(1, AK_SUS_ALL_INT);  /* 正しくは第2引数がAK_SUS_OS_INT */
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(2, AK_SUS_OS_INT);   /* 正しくは第2引数がAK_SUS_ALL_INT */
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(3, AK_SUS_ALL_INT);  /* 正しくは第2引数がAK_SUS_OS_INT */
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(4, AK_SUS_OS_INT);   /* 正しくは第2引数がAK_SUS_ALL_INT */
	CheckErcd(E_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_DISABLE;
	vint.ism_susosint = AK_DISABLE;
	vint.ism_susallcnt = 2;
	vint.ism_susoscnt = 2;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyDisIntOrder(1, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(2, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(3, AK_SUS_OS_INT);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyDisIntOrder(4, AK_SUS_ALL_INT);
	CheckErcd(E_OK, ercd);

	return;
}

/*
 *  状態確認APIチェック関数：状態 7)
 */
void
CheckAktspVerifyIntState7(void)
{
	StatusType			ercd;
	AktspIntStateInfo	vint;
	static uint16		bootcnt = 0;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0 : タスク
	 *  1 : カテゴリ2 ISR
	 *  2 : カテゴリ1 ISR
	 *  3 : エラーフック
	 *  4 : アラームコールバック
	 *  5 : ポストタスクフック
	 *  6 : プレタスクフック
	 */

	/*
	 *  CORE1:
	 *    type  : INT_STATE
	 *    istat :
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyIntState())
	 */

	vint.ism_disallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susallint = AK_DISABLE; /* 正しくはAK_ENABLE */
	vint.ism_susosint = AK_DISABLE;  /* 正しくはAK_ENABLE */
	vint.ism_susallcnt = 1;          /* 正しくは0 */
	vint.ism_susoscnt = 1;           /* 正しくは0 */

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  割込み禁止状態の確認
	 */
	vint.ism_disallint = AK_ENABLE;
	vint.ism_susallint = AK_ENABLE;
	vint.ism_susosint = AK_ENABLE;
	vint.ism_susallcnt = 0;
	vint.ism_susoscnt = 0;

	ercd = AktspVerifyIntState(&vint);
	CheckErcd(E_OK, ercd);

	bootcnt++;

	return;
}

void
CheckState(void)
{
	uint8 state;

	state = AktspGetCpState();
	if (state == AK_FALSE) {
		ShutdownOS(E_OK);
	}
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
