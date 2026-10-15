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
 *  ・AktspVerifyResource()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyResource()】
 * ・resprop (リソースの種別)
 *  AK_STANDARD : StandardResLock, StandardResUnl, StandardResforLnk
 *  AK_INTERNAL : InternalResLock, InternalResUnl
 *  AK_LINKED   : LinkedResLock,   LinkedResUnl
 *
 * ・linkres (リンクリソースのリンク先リソース)
 *  StandardResforLnk : LinkedResLock
 *  StandardResUnl    : LinkedResUnl
 *
 * ・lockflg (リソースの状態)
 *  AK_LOCK   : StandardResLock, InternalResLock, LinkedResLock, StandardResforLnk
 *  AK_UNLOCK : StandardResUnl,  InternalResUnl,  LinkedResUnl
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyResource()】
 *   TESRYデータ | 確認するリソースのリソースID
 *  ------------------------------------------------------
 *   resprop     | InternalResLock (respropがAK_INTERNAL)
 *   lockflg     | StandardResLock
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyResource()】
 *   TESRYデータ | 確認するリソースのリソースID
 *  ---------------------------------------------------------------------------------
 *   resprop     | StandardResLock (respropがAK_STANDARDかAK_LINKEDの区別がつかない)
 *   lockflg     | InternalResLock (respropがAK_INTERNAL)
 *   linkres     | LinkedResLock
 *
 * <参考情報>
 * ※以下の項目については，状態確認APIを用いて確認しない
 * ・リソースを取得するタスク
 *  StandardResLock : TaskStandardRes
 *  InternalResLock : TaskInternalRes
 *  LinkedResLock   : TaskLinkedRes
 *
 * ・リソースに関連づいているタスク
 *  StandardResLock   : TaskStandardRes, TaskDummy1
 *  InternalResLock   : TaskInternalRes, TaskDummy2
 *  StandardResforLnk : TaskLinkedRes,   TaskDummy3
 *  StandardResUnl    : TaskDummy4,      TaskDummy5
 *  InternalResUnl    : TaskDummy6,      TaskDummy7
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskStandardRes)
{
	StatusType ercd;

	AktspCheckPoint(2);

	ercd = GetResource(StandardResLock);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskLinkedRes);
	CheckErcd(ercd, E_OK);

	/* 後処理 */
	ercd = ReleaseResource(StandardResLock);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(21);

	TerminateTask();
}

TASK(TaskInternalRes)
{
	StatusType ercd;

	AktspCheckPoint(5);

	/* タスクからの確認 */
	CheckAktspVerifyResource();

	AktspCheckPoint(6);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(8);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(10);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(12);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(14);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(16);
	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(TaskLinkedRes)
{
	StatusType ercd;

	AktspCheckPoint(3);

	ercd = GetResource(StandardResforLnk);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(LinkedResLock);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(4);

	ercd = ActivateTask(TaskInternalRes);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(19);

	/* 後処理 */
	ercd = ReleaseResource(LinkedResLock);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(StandardResforLnk);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(20);

	TerminateTask();

}

TASK(TaskDummy1)
{
	TerminateTask();
}

TASK(TaskDummy2)
{
	TerminateTask();
}


TASK(TaskDummy3)
{
	TerminateTask();
}


TASK(TaskDummy4)
{
	TerminateTask();
}

TASK(TaskDummy5)
{
	TerminateTask();
}

TASK(TaskDummy6)
{
	TerminateTask();
}

TASK(TaskDummy7)
{
	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(7);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyResource();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(9);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyResource();
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(15);

	/* アラームコールバックからの確認 */
	CheckAktspVerifyResource();
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(18);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyResource();
		hookboot = 0;
	}
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(17);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyResource();
	}
}

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(11);

	/* エラーフックからの確認 */
	CheckAktspVerifyResource();
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

	AktspCheckPoint(13);

	/* エラーフックからの確認 */
	CheckAktspVerifyResource();

	return(PRO_IGNORE);
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = ActivateTask(TaskStandardRes);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(22);
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
CheckAktspVerifyResource()
{
	StatusType			ercd;
	AktspResourceInfo	vres;
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
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyResource())
	 */

	/*
	 *  InternalResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_INTERNAL
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_STANDARD; /* 正しくはAK_INTERNAL */
	vres.rm_lockflg = AK_LOCK;

	ercd = AktspVerifyResource(InternalResLock, &vres);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  StandardResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_STANDARD
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_STANDARD;
	vres.rm_lockflg = AK_UNLOCK; /* 正しくはAK_LOCK */

	ercd = AktspVerifyResource(StandardResLock, &vres);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyResource())
	 */

	/*
	 *  StandardResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_STANDARD
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_LINKED; /* 正しくはAK_STANDARD */
	vres.rm_lockflg = AK_LOCK;

	ercd = AktspVerifyResource(StandardResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  InternalResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_INTERNAL
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_INTERNAL;
	vres.rm_lockflg = AK_UNLOCK; /* 正しくはAK_LOCK */

	ercd = AktspVerifyResource(InternalResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  LinkedResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_LINKED
	 *    lockflg : AK_LOCK
	 *    linkres : StandardResforLnk
	 */

	vres.rm_resprop = AK_LINKED;
	vres.rm_lockflg = AK_LOCK;
	vres.rm_linkres = StandardResLock; /* 正しくはStandardResforLnk */

	ercd = AktspVerifyResource(LinkedResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  各リソースの状態確認
	 */

	/*
	 *  StandardResLockチェック
	 *
	 *  StandardResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_STANDARD
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_STANDARD;
	vres.rm_lockflg = AK_LOCK;

	ercd = AktspVerifyResource(StandardResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  StandardResUnlチェック
	 *
	 *  StandardResUnl:
	 *    type    : RESOURCE
	 *    resprop : AK_STANDARD
	 *    lockflg : AK_UNLOCK
	 */
	vres.rm_resprop = AK_STANDARD;
	vres.rm_lockflg = AK_UNLOCK;

	ercd = AktspVerifyResource(StandardResUnl, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  StandardResforLnkチェック
	 *
	 *  StandardResforLnk:
	 *    type    : RESOURCE
	 *    resprop : AK_STANDARD
	 *    lockflg : AK_LOCK
	 */

	vres.rm_resprop = AK_STANDARD;
	vres.rm_lockflg = AK_LOCK;

	ercd = AktspVerifyResource(StandardResforLnk, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  InternalResLockチェック
	 *
	 *  InternalResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_INTERNAL
	 *    lockflg : AK_LOCK
	 */
	vres.rm_resprop = AK_INTERNAL;
	vres.rm_lockflg = AK_LOCK;

	ercd = AktspVerifyResource(InternalResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  InternalResUnlチェック
	 *
	 *  InternalResUnl:
	 *    type    : RESOURCE
	 *    resprop : AK_INTERNAL
	 *    lockflg : AK_UNLOCK
	 */
	vres.rm_resprop = AK_INTERNAL;
	vres.rm_lockflg = AK_UNLOCK;

	ercd = AktspVerifyResource(InternalResUnl, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  LinkedResLockチェック
	 *
	 *  LinkedResLock:
	 *    type    : RESOURCE
	 *    resprop : AK_LINKED
	 *    lockflg : AK_LOCK
	 *    linkres : StandardResforLnk
	 */

	vres.rm_resprop = AK_LINKED;
	vres.rm_lockflg = AK_LOCK;
	vres.rm_linkres = StandardResforLnk;

	ercd = AktspVerifyResource(LinkedResLock, &vres);
	CheckErcd(E_OK, ercd);

	/*
	 *  LinkedResUnlチェック
	 *
	 *  LinkedResUnl:
	 *    type    : RESOURCE
	 *    resprop : AK_LINKED
	 *    lockflg : AK_UNLOCK
	 *    linkres : StandardResUnl
	 */

	vres.rm_resprop = AK_LINKED;
	vres.rm_lockflg = AK_UNLOCK;
	vres.rm_linkres = StandardResUnl;

	ercd = AktspVerifyResource(LinkedResUnl, &vres);
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
