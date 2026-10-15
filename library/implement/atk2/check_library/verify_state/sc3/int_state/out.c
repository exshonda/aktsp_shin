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
 *   ・信頼OSAP固有のスタートアップフック
 *   ・非信頼OSAP固有のスタートアップフック
 *   ・信頼OSAPに所属するタスク
 *   ・非信頼OSAPに所属するタスク
 *   ・エラーフック
 *   ・非信頼OSAP固有のエラーフック
 *   ・C2ISR
 *   ・C1ISR
 *   ・エラーフック
 *   ・信頼OSAP固有のエラーフック
 *   ・プロテクションフック
 *   ・ポストタスクフック
 *   ・プレタスクフック
 *   ・信頼OSAP固有のシャットダウンフック
 *   ・非信頼OSAP固有のシャットダウンフック
 *   ・シャットダウンフック
 * ※タスクが状態 1)，2)，3)，6)を作成し，以下の処理単位から確認する
 *   ・エラーフック
 *   ・信頼OSAP固有のエラーフック
 *   ・非信頼OSAP固有のエラーフック
 *   ・プロテクションフック
 * ※タスクが状態 4)，5)を作成し，以下の処理単位から確認する
 *   ・C1ISR
 *   ・エラーフック
 *   ・信頼OSAP固有のエラーフック
 *   ・非信頼OSAP固有のエラーフック
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

TASK(TrustedTask)
{
	StatusType ercd;

	AktspCheckPoint(56);

	/* 信頼OSAPに所属するタスクからの確認 */
	AktspOutputLog_0("--- Verify from Task of Trusted OSAP ---");
	MakeAndVerifyState();

	CheckState();

	AktspCheckPoint(74);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	CheckState();

	AktspCheckPoint(149);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	CheckState();

	AktspCheckPoint(168);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	CheckState();

	AktspCheckPoint(187);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	CheckState();

	AktspCheckPoint(224);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	CheckState();

	AktspCheckPoint(243);

	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(NonTrustedTask)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(75);

	/* 非信頼OSAPに所属するタスクからの確認 */
	AktspOutputLog_0("--- Verify from Task of Non Trusted OSAP ---");
	MakeAndVerifyState();

	CheckState();

	AktspCheckPoint(93);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(112);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	TerminateTask();
}
void
MakeAndVerifyState(void)
{
	static uint16	bootcnt = 0;
	uint16			cp = 0;

	if (bootcnt == 0) { /* スタートアップフック */
		cp = 1;
	}
	else if (bootcnt == 1) { /* 非信頼OSAP固有のスタートアップフック */
		cp = 19;
	}
	else if (bootcnt == 2) { /* 信頼OSAP固有のスタートアップフック */
		cp = 37;
	}
	else if (bootcnt == 3) { /* 信頼OSAP固有のタスク */
		cp = 56;
	}
	else if (bootcnt == 4) { /* 非信頼OSAP固有のタスク */
		cp = 75;
	}
	else if (bootcnt == 5) { /* 信頼関数 */
		cp = 94;
	}
	else if (bootcnt == 6) { /* エラーフック */
		cp = 113;
	}
	else if (bootcnt == 7) { /* 非信頼OSAP固有のエラーフック */
		cp = 131;
	}
	else if (bootcnt == 8) { /* カテゴリ2 ISR */
		cp = 150;
	}
	else if (bootcnt == 9) { /* カテゴリ1 ISR */
		cp = 169;
	}
	else if (bootcnt == 10) { /* エラーフック */
		cp = 188;
	}
	else if (bootcnt == 11) { /* 信頼OSAP固有のエラーフック */
		cp = 206;
	}
	else if (bootcnt == 12) { /* プロテクションフック */
		cp = 225;
	}
	else if (bootcnt == 13) { /* ポストタスクフック */
		cp = 244;
	}
	else if (bootcnt == 14) { /* プレタスクフック */
		cp = 262;
	}
	else if (bootcnt == 15) { /* 非信頼OSAP固有のシャットダウンフック */
		cp = 356;
	}
	else if (bootcnt == 16) { /* 信頼OSAP固有のシャットダウンフック */
		cp = 374;
	}
	else if (bootcnt == 17) { /* シャットダウンフック */
		cp = 392;
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

TASK(TrustedTaskMakeState)
{
	AktspCheckPoint(281);

	/* 状態 1)の作成 */
	DisableAllInterrupts();

	AktspCheckPoint(282);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(285);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(287);

	EnableAllInterrupts();

	AktspCheckPoint(288);

	/* 状態 2)の作成 */
	SuspendAllInterrupts();

	AktspCheckPoint(289);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(292);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(294);

	/* 状態 3)の作成 */
	SuspendAllInterrupts();
	SuspendAllInterrupts();

	AktspCheckPoint(295);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(298);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(300);

	ResumeAllInterrupts();
	ResumeAllInterrupts();
	ResumeAllInterrupts();

	AktspCheckPoint(301);

	/* 状態 4)の作成 */
	SuspendOSInterrupts();

	AktspCheckPoint(302);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(304);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(307);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(309);

	ResumeOSInterrupts();

	CheckState();

	/* 状態 5)の作成 */
	SuspendOSInterrupts();
	SuspendOSInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(310);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(312);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(315);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(317);

	ResumeOSInterrupts();
	ResumeOSInterrupts();
	ResumeOSInterrupts();

	CheckState();

	AktspCheckPoint(318);

	/* 状態 6)の作成 */
	SuspendAllInterrupts();
	SuspendOSInterrupts();
	SuspendAllInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(319);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(322);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	ResumeOSInterrupts();
	ResumeAllInterrupts();
	ResumeOSInterrupts();
	ResumeAllInterrupts();

	CheckState();

	AktspCheckPoint(324);

	TerminateTask();
}

TASK(NonTrustedTaskMakeState)
{
	AktspCheckPoint(326);

	/* 状態 1)の作成 */
	DisableAllInterrupts();

	AktspCheckPoint(327);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(330);

	EnableAllInterrupts();

	AktspCheckPoint(331);

	/* 状態 2)の作成 */
	SuspendAllInterrupts();

	AktspCheckPoint(332);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(335);

	/* 状態 3)の作成 */
	SuspendAllInterrupts();
	SuspendAllInterrupts();

	AktspCheckPoint(336);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(339);

	ResumeAllInterrupts();
	ResumeAllInterrupts();
	ResumeAllInterrupts();

	AktspCheckPoint(340);

	/* 状態 4)の作成 */
	SuspendOSInterrupts();

	AktspCheckPoint(341);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(344);

	ResumeOSInterrupts();

	CheckState();

	/* 状態 5)の作成 */
	SuspendOSInterrupts();
	SuspendOSInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(345);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(348);

	ResumeOSInterrupts();
	ResumeOSInterrupts();
	ResumeOSInterrupts();

	CheckState();

	AktspCheckPoint(349);

	/* 状態 6)の作成 */
	SuspendAllInterrupts();
	SuspendOSInterrupts();
	SuspendAllInterrupts();
	SuspendOSInterrupts();

	AktspCheckPoint(350);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(353);

	ResumeOSInterrupts();
	ResumeAllInterrupts();
	ResumeOSInterrupts();
	ResumeAllInterrupts();

	CheckState();

	AktspCheckPoint(354);

	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(94);

	/* 信頼関数からの確認 */
	MakeAndVerifyState();

	return E_OK;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(150);

	/* カテゴリ2 ISRからの確認 */
	AktspOutputLog_0("--- Verify from C2ISR ---");
	MakeAndVerifyState();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY(void)
{
	static uint16 bootcnt = 0;

	AktspClearIntRequest(AKTSP_INTNO_B);

	if (bootcnt == 0) {
		AktspCheckPoint(169);

		/* カテゴリ1 ISRからの確認 */
		AktspOutputLog_0("--- Verify from C1ISR ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(303);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(311);
		CheckAktspVerifyIntState5();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return;
}

void
StartupHook(void)
{
	AktspCheckPoint(1);
	AktspOutputLog_0("--- Verify from StartupHook ---");
	MakeAndVerifyState();
}

#if 0
void
StartupHook_NON_TRUSTED_OSAP5(void)
{
	AktspCheckPoint(19);
	AktspOutputLog_0("--- Verify from StartupHook of NON_TRUSTED_OSAP5 ---");
	MakeAndVerifyState();
}

void
StartupHook_TRUSTED_OSAP5(void)
{
	AktspCheckPoint(37);
	AktspOutputLog_0("--- Verify from StartupHook of TRUSTED_OSAP5 ---");
	MakeAndVerifyState();
}
#endif

void
ErrorHook(StatusType ercd)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(113);

		AktspOutputLog_0("--- Verify from ErrorHook ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(188);

		AktspOutputLog_0("--- Verify from ErrorHook ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 2) { /* DisableAllInterruptsによる割込み禁止 */
		AktspCheckPoint(283);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 3) { /* SuspendAllInterruptsによる割込み禁止 */
		AktspCheckPoint(290);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 4) { /* SuspendAllInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(296);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 5) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(305);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 6) { /* SuspendOSInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(313);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 7) { /* SuspendAllInterrupts，SuspendOSInterruptsのネストによる割込み禁止 */
		AktspCheckPoint(320);
		CheckAktspVerifyIntState6();
	}
	else if (bootcnt == 8) { /* DisableAllInterruptsによる割込み禁止 */
		AktspCheckPoint(328);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 9) { /* SuspendAllInterruptsによる割込み禁止 */
		AktspCheckPoint(333);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 10) { /* SuspendAllInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(337);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 11) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(342);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 12) { /* SuspendOSInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(346);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 13) { /* SuspendAllInterrupts，SuspendOSInterruptsのネストによる割込み禁止 */
		AktspCheckPoint(351);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return;
}

#if 0
void
ErrorHook_TRUSTED_OSAP5(StatusType ercd)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(206);

		AktspOutputLog_0("--- Verify from ErrorHook of TRUSTED_OSAP5 ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(284);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 2) {
		AktspCheckPoint(291);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 3) {
		AktspCheckPoint(297);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 4) {
		AktspCheckPoint(306);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 5) {
		AktspCheckPoint(314);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 6) {
		AktspCheckPoint(321);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return;
}

void
ErrorHook_NON_TRUSTED_OSAP5(StatusType ercd)
{
	static uint16 bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(131);

		AktspOutputLog_0("--- Verify from ErrorHook of NON_TRUSTED_OSAP5 ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) { /* DisableAllInterruptsによる割込み禁止 */
		AktspCheckPoint(329);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 2) { /* SuspendAllInterruptsによる割込み禁止 */
		AktspCheckPoint(334);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 3) { /* SuspendAllInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(338);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 4) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(343);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 5) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(347);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 6) { /* SuspendAllInterrupts，SuspendOSInterruptsのネストによる割込み禁止 */
		AktspCheckPoint(352);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return;
}
#endif

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
		AktspCheckPoint(225);

		AktspOutputLog_0("--- Verify from ProtectionHook ---");
		MakeAndVerifyState();
	}
	else if (bootcnt == 1) { /* DisableAllInterruptsによる割込み禁止 */
		AktspCheckPoint(286);
		CheckAktspVerifyIntState1();
	}
	else if (bootcnt == 2) { /* SuspendAllInterruptsによる割込み禁止 */
		AktspCheckPoint(293);
		CheckAktspVerifyIntState2();
	}
	else if (bootcnt == 3) { /* SuspendAllInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(299);
		CheckAktspVerifyIntState3();
	}
	else if (bootcnt == 4) { /* SuspendOSInterruptsによる割込み禁止 */
		AktspCheckPoint(308);
		CheckAktspVerifyIntState4();
	}
	else if (bootcnt == 5) { /* SuspendOSInterrupts(ネスト)による割込み禁止 */
		AktspCheckPoint(316);
		CheckAktspVerifyIntState5();
	}
	else if (bootcnt == 6) { /* SuspendAllInterrupts，SuspendOSInterruptsのネストによる割込み禁止 */
		AktspCheckPoint(323);
		CheckAktspVerifyIntState6();
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return(PRO_IGNORE);
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(244);

		/* ポストタスクフックからの確認 */
		AktspOutputLog_0("--- Verify from PostTaskHook ---");
		MakeAndVerifyState();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(262);

		/* プレタスクフックからの確認 */
		AktspOutputLog_0("--- Verify from PreTaskHook ---");
		MakeAndVerifyState();

		hookboot = 0;
	}
}

#if 0
void
ShutdownHook_NON_TRUSTED_OSAP5(StatusType Error)
{
	AktspCheckPoint(356);
	AktspOutputLog_0("--- Verify from ShutdownHook of NON_TRUSTED_OSAP5 ---");
	MakeAndVerifyState();
}

void
ShutdownHook_TRUSTED_OSAP5(StatusType Error)
{
	AktspCheckPoint(374);
	AktspOutputLog_0("--- Verify from ShutdownHook of TRUSTED_OSAP5 ---");
	MakeAndVerifyState();
}
#endif

void
ShutdownHook(StatusType Error)
{
	AktspCheckPoint(392);
	AktspOutputLog_0("--- Verify from ShutdownHook ---");
	MakeAndVerifyState();
	AktspCheckPoint(410);
	AktspOutputLog_0("All check points passed.");
}

TASK(MainTask)
{
	StatusType ercd;

	AktspCheckPoint(55);

	ercd = ActivateTask(TrustedTask);
	CheckErcd(ercd, E_OK);

	CheckState();

	AktspCheckPoint(280);

	ercd = ActivateTask(TrustedTaskMakeState);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(325);

	ercd = ActivateTask(NonTrustedTaskMakeState);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(355);
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
