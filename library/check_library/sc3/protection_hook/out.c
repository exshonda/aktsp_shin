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
 *  本テストプログラムでは，以下のプロテクションフック起動関数をテスト
 *  する
 *  ・AktspRaiseProtectionHook()
 *  ・AktspProtectionHookInit()
 *
 * 【確認する内容】
 *  以下の処理単位から，プロテクションフックを発生させる
 *  ・スタートアップフック
 *  ・信頼OSAP固有のスタートアップフック
 *  ・非信頼OSAP固有のスタートアップフック
 *  ・信頼OSAPに所属するタスク
 *  ・非信頼OSAPに所属するタスク
 *  ・エラーフック
 *  ・非信頼OSAP固有のエラーフック
 *  ・信頼OSAP固有のエラーフック
 *  ・ポストタスクフック
 *  ・プレタスクフック
 *  ・信頼OSAP固有のシャットダウンフック
 *  ・非信頼OSAP固有のシャットダウンフック
 *  ・シャットダウンフック
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

	AktspCheckPoint(42);
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

	/* 実行中のタスクからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(12);

	AktspCheckPoint(13);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(28);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(35);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot = 1;
	TerminateTask();
}

TASK(NonTrustedTask)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(14);

	/* 実行中のタスクからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(15);

	AktspCheckPoint(16);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(20);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(27);

	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(17);

	/* 信頼関数からプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(18);

	AktspCheckPoint(19);

	return E_OK;
}

void
StartupHook(void)
{
	AktspCheckPoint(1);

	/* スタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(2);

	AktspCheckPoint(3);

	return;
}

#if 0
void
StartupHook_NON_TRUSTED_OSAP1(void)
{
	AktspCheckPoint(4);

	/* 非信頼関数OSAP固有のスタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(5);

	AktspCheckPoint(6);

	return;
}

void
StartupHook_TRUSTED_OSAP1(void)
{
	AktspCheckPoint(7);

	/* 信頼関数OSAP固有のスタートアップフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(8);

	AktspCheckPoint(9);

	return;
}
#endif

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	/* エラーフックからプロテクションフックを起動 */
	/* 非信頼OSAPからの起動 */
	if (bootcnt == 0) {
		AktspCheckPoint(21);

		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(22);

		AktspCheckPoint(23);
	}
	/* 信頼OSAPからの起動 */
	else if (bootcnt == 1) {
		AktspCheckPoint(29);

		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(30);

		AktspCheckPoint(31);
	}

	bootcnt++;
	return;
}

#if 0
void
ErrorHook_TRUSTED_OSAP1(StatusType ercd)
{
	AktspCheckPoint(32);

	/* 信頼関数OSAP固有のエラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(33);

	AktspCheckPoint(34);

	return;
}

void
ErrorHook_NON_TRUSTED_OSAP1(StatusType ercd)
{
	AktspCheckPoint(24);

	/* 非信頼関数OSAP固有のエラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(25);

	AktspCheckPoint(26);

	return;
}
#endif

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(36);

		/* ポストタスクフックからプロテクションフックを起動 */

		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(37);

		AktspCheckPoint(38);
	}
	return;
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(39);

		/* プレタスクフックからプロテクションフックを起動 */
		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(40);

		AktspCheckPoint(41);

		hookboot = 0;
	}
	return;
}

#if 0
void
ShutdownHook_NON_TRUSTED_OSAP1(StatusType Error)
{
	AktspCheckPoint(43);

	/* 非信頼OSAP固有のシャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(44);

	AktspCheckPoint(45);
}

void
ShutdownHook_TRUSTED_OSAP1(StatusType Error)
{
	AktspCheckPoint(46);

	/* 信頼OSAP固有のシャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(47);

	AktspCheckPoint(48);
}
#endif

void
ShutdownHook(StatusType Error)
{
	AktspCheckPoint(49);

	/* シャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(50);

	AktspCheckPoint(51);
	AktspOutputLog_0("All check points passed.");
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
		AktspOutputLog_0("[StartupHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(2);
	}
	else if (bootcnt == 1) {
		AktspOutputLog_0("[StartupHook specified NON Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(5);
	}
	else if (bootcnt == 2) {
		AktspOutputLog_0("[StartupHook specified Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(8);
	}
	else if (bootcnt == 3) {
		AktspOutputLog_0("[Task in Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(12);
	}
	else if (bootcnt == 4) {
		AktspOutputLog_0("[Task in NON Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(15);
	}
	else if (bootcnt == 5) {
		AktspOutputLog_0("[TruestedFunction] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(18);
	}
	else if (bootcnt == 6) {
		AktspOutputLog_0("[ErrorHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(22);
	}
	else if (bootcnt == 7) {
		AktspOutputLog_0("[ErrorHook specified NON Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(25);
	}
	else if (bootcnt == 8) {
		AktspOutputLog_0("[ErrorHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(30);
	}
	else if (bootcnt == 9) {
		AktspOutputLog_0("[ErrorHook specified Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(33);
	}
	else if (bootcnt == 10) {
		AktspOutputLog_0("[PosttaskHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(37);
	}
	else if (bootcnt == 11) {
		AktspOutputLog_0("[PretaskHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(40);
	}
	else if (bootcnt == 12) {
		AktspOutputLog_0("[ShutdownHook specified NON Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(44);
	}
	else if (bootcnt == 13) {
		AktspOutputLog_0("[ShutdownHook specified Trusted OSAP] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(47);
	}
	else if (bootcnt == 14) {
		AktspOutputLog_0("[ShutdownHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(50);
	}
	else {
		AktspCheckPoint(0);
	}

	bootcnt++;

	return(PRO_IGNORE);
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
