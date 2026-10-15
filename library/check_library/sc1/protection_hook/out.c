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
 *  本テストプログラムでは，以下のプロテクションフック起動関数をテスト
 *  する
 *  ・AktspRaiseProtectionHook()
 *  ・AktspProtectionHookInit()
 *
 * 【確認する内容】
 *  以下の処理単位から，プロテクションフックを発生させる
 *  ・スタートアップフック
 *  ・タスク
 *  ・エラーフック
 *  ・アラームコールバック
 *  ・ポストタスクフック
 *  ・プレタスクフック
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

	AktspCheckPoint(4);

	ercd = ActivateTask(RunTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(22);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

TASK(RunTask)
{
	StatusType ercd;

	AktspCheckPoint(5);

	/* 実行中のタスクからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(6);

	AktspCheckPoint(7);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(11);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(15);

	/* ポストタスクフック，プレタスクフックの呼び出し */
	hookboot = 1;
	TerminateTask();
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

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(8);

	/* エラーフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(9);

	AktspCheckPoint(10);

	return;
}

#ifdef ALARMCALLBACK
ALARMCALLBACK(AlarmCallBackVerify)
{
	AlarmCallBackFunc();

	return;
}
#endif /* ALARMCALLBACK */

void
AlarmCallBackFunc(void)
{
	AktspCheckPoint(12);

	/* アラームコールバックからプロテクションフックを起動(SC1の場合) */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(13);

	AktspCheckPoint(14);

	return;
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(16);

		/* ポストタスクフックからプロテクションフックを起動 */
		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(17);

		AktspCheckPoint(18);
	}
	return;
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(19);

		/* プレタスクフックからプロテクションフックを起動 */
		AktspRaiseProtectionHook();
		AktspWaitCheckPoint(20);

		AktspCheckPoint(21);

		hookboot = 0;
	}
	return;
}

void
ShutdownHook(StatusType Error)
{
	AktspCheckPoint(23);

	/* シャットダウンフックからプロテクションフックを起動 */
	AktspRaiseProtectionHook();
	AktspWaitCheckPoint(24);

	AktspCheckPoint(25);
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
		AktspOutputLog_0("[Task] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(6);
	}
	else if (bootcnt == 2) {
		AktspOutputLog_0("[ErrorHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(9);
	}
	else if (bootcnt == 3) {
		AktspOutputLog_0("[AlarmCallBack] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(13);
	}
	else if (bootcnt == 4) {
		AktspOutputLog_0("[PosttaskHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(17);
	}
	else if (bootcnt == 5) {
		AktspOutputLog_0("[PretaskHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(20);
	}
	else if (bootcnt == 6) {
		AktspOutputLog_0("[ShutdownHook] AktspRaiseProtectionHook() : OK");
		AktspCheckPoint(24);
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
