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
 *  ・AktspVerifyStartupHookOsap()
 *  ・AktspVerifyShutdownHookOsap()
 *  ・AktspVerifyErrorHookOsap()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyStartupHookOsap()】
 * ・StartupHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のスタートアップフックの関数ポインタ)
 *   対象OSAP : TRUSTED_OSAP1
 *
 * 【AktspVerifyShutdownHookOsap()】
 * ・ShutdownHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のシャットダウンフックの関数ポインタ)
 *   対象OSAP : NON_TRUSTED_OSAP1
 *
 * 【AktspVerifyErrorHookOsap()】
 * ・ErrorHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のエラーフックの関数ポインタ)
 *   対象OSAP : NON_TRUSTED_OSAP1
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyStartupHookOsap()】
 * ・StartupHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のスタートアップフックの関数ポインタ)
 *   対象OSAP : TRUSTED_OSAP1
 *
 * 【AktspVerifyShutdownHookOsap()】
 * ・ShutdownHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のシャットダウンフックの関数ポインタ)
 *   対象OSAP : NON_TRUSTED_OSAP1
 *
 * 【AktspVerifyErrorHookOsap()】
 * ・ErrorHookFunction (確認対象のOSアプリケーションに所属するOSアプリケーション固有のエラーフックの関数ポインタ)
 *   対象OSAP : NON_TRUSTED_OSAP1
 *
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TrustedTask)
{
	StatusType ercd;

	AktspCheckPoint(3);

	/* 信頼OSAPに所属するタスクからの確認 */
	//CheckAktspVerifyHook();

	AktspCheckPoint(4);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(12);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(14);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(16);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(19);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(21);

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
	//CheckAktspVerifyHook();

	AktspCheckPoint(6);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(8);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(11);

	TerminateTask();
}

TASK(DummyTask1)
{
	TerminateTask();
}

TASK(DummyTask2)
{
	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(7);

	/* 信頼関数からの確認 */
	//CheckAktspVerifyHook();

	return E_OK;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(13);

	/* 信頼OSAPに所属するカテゴリ2 ISRからの確認 */
	//CheckAktspVerifyHook();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY(void)
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(15);

	/* カテゴリ1 ISRからの確認 */
	//CheckAktspVerifyHook();
}

#if 0
void
StartupHook_TRUSTED_OSAP1(void)
{
	AktspCheckPoint(1);

	/* 信頼OSAP固有のスタートアップフックからの確認 */
	//CheckAktspVerifyHook();
}
#endif

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	/* 非信頼OSAPからの起動 */
	if (bootcnt == 0) {
		AktspCheckPoint(9);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(17);
	}

	/* エラーフックからの確認 */
	//CheckAktspVerifyHook();

	bootcnt++;
}

#if 0
void
ErrorHook_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(18);

	/* 信頼OSAP固有のエラーフックからの確認 */
	//CheckAktspVerifyHook();
}

void
ErrorHook_NON_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(10);

	/* 非信頼OSAP固有のエラーフックからの確認 */
	//CheckAktspVerifyHook();
}

void
ErrorHook_NON_TRUSTED_OSAP1(StatusType ercd)
{
	return;
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

	AktspCheckPoint(20);

	/* プロテクションフックからの確認 */
	//CheckAktspVerifyHook();

	return(PRO_IGNORE);
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(22);

		/* ポストタスクフックからの確認 */
		//CheckAktspVerifyHook();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(23);

		/* プレタスクフックからの確認 */
		//CheckAktspVerifyHook();
		hookboot = 0;
	}
}

#if 0
void
ShutdownHook_NON_TRUSTED_OSAP1(StatusType Error)
{
	AktspCheckPoint(25);

	/* 信頼OSAP固有のシャットダウンフックからの確認 */
	//CheckAktspVerifyHook();

	AktspCheckPoint(26);
	AktspOutputLog_0("All check points passed.");
}
#endif

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(2);

	ercd = ActivateTask(TrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(24);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

#if 0
/*
 *  状態確認APIチェック関数
 */
void
CheckAktspVerifyHook(void)
{
	StatusType ercd;


	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyStartupHookOsap())
	 */
	ercd = AktspVerifyStartupHookOsap(TRUSTED_OSAP1, &PostTaskHook); /* 正しくは，第2引数がStartupHook_TRUSTED_OSAP1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyShutdownHookOsap())
	 */
	ercd = AktspVerifyShutdownHookOsap(NON_TRUSTED_OSAP1, &ErrorHook_TRUSTED_OSAP5); /* 正しくは，第2引数がStartupHook_TRUSTED_OSAP1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyErrorHookOsap())
	 */
	ercd = AktspVerifyErrorHookOsap(NON_TRUSTED_OSAP1, &ErrorHook_TRUSTED_OSAP5); /* 正しくは，第2引数がStartupHook_TRUSTED_OSAP1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  各フックの状態確認
	 */

	/*
	 *  AktspVerifyStartupHookOsapチェック
	 */
	ercd = AktspVerifyStartupHookOsap(TRUSTED_OSAP1, &StartupHook_TRUSTED_OSAP1);
	CheckErcd(E_OK, ercd);

	/*
	 *  AktspVerifyStartupHookOsapチェック
	 */
	ercd = AktspVerifyShutdownHookOsap(NON_TRUSTED_OSAP1, &ShutdownHook_NON_TRUSTED_OSAP1);
	CheckErcd(E_OK, ercd);

	/*
	 *  AktspVerifyStartupHookOsapチェック
	 */
	ercd = AktspVerifyErrorHookOsap(NON_TRUSTED_OSAP1, &ErrorHook_NON_TRUSTED_OSAP1);
	CheckErcd(E_OK, ercd);

	return;
}
#endif

/*
 *  User main
 */
sint32
main(void){
	AktspInitializeTestLib();
	StartOS(MainApp);
	while (1) {}
}
