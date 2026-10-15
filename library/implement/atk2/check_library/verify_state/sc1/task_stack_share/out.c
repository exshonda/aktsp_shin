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
 *  ・AktspVerifyTask()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyTask()】
 * ・stksz (スタック領域のサイズ)
 *  AKTSP_TASK_STACK_SIZE : Task1
 *
 * ・stk (スタック領域の先頭番地)
 *  aktg_stack[0] : Task1
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyTask()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   stksz       | Task1
 *   stk         | Task1
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int	hookboot = 0;

TASK(TaskVerify)
{
	StatusType ercd;

	AktspCheckPoint(2);

	/* タスクからの確認 */
	CheckAktspVerifyTask();

	AktspCheckPoint(3);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(5);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(7);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(9);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(11);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(13);
	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(Task1)
{
	AktspCheckPoint(0);
	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(4);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyTask();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(6);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyTask();
}

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(8);

	/* エラーフックからの確認 */
	CheckAktspVerifyTask();
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

	AktspCheckPoint(10);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyTask();

	return(PRO_IGNORE);
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(12);

	/* アラームコールバックからの確認 */
	CheckAktspVerifyTask();
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(14);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyTask();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(15);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyTask();
		hookboot = 0;
	}
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(16);
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
CheckAktspVerifyTask()
{
	StatusType		ercd;
	AktspTaskInfo	vtsk;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0 : タスク
	 *  1 : カテゴリ2 ISR
	 *  2 : カテゴリ1 ISR
	 *  3 : エラーフック
	 *  4 : プロテクションフック
	 *  5 : アラームコールバック
	 *  6 : ポストタスクフック
	 *  7 : プレタスクフック
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTask())
	 */

	/*
	 *  Task1:
	 *    type    : TASK
	 *    tstat   : SUSPENDED
	 *    inipri  : 2
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    stksz   : AKTSP_TASK_STACK_SIZE
	 *    stk     : aktg_stack[0]
	 */
	vtsk.tm_tstat = SUSPENDED;
	vtsk.tm_inipri = 2;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = 0;
	vtsk.tm_stksz = 256;                                  /* 正しくはAKTSP_TASK_STACK_SIZE */
	vtsk.tm_stk = AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY; /* 正しくはaktg_stack[0] */

	ercd = AktspVerifyTask(Task1, &vtsk);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  各タスクの状態確認
	 */

	/*
	 *  Task1チェック
	 *
	 *  Task1:
	 *    type    : TASK
	 *    tstat   : SUSPENDED
	 *    inipri  : 2
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    stksz   : AKTSP_TASK_STACK_SIZE
	 *    stk     : aktg_stack[0]
	 */
	vtsk.tm_tstat = SUSPENDED;
	vtsk.tm_inipri = 2;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = aktg_stack[0];

	ercd = AktspVerifyTask(Task1, &vtsk);
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
