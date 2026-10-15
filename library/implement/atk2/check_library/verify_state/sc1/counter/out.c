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
 *  ・AktspVerifyCounter()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyCounter()】
 * ・ctype(カウンタのタイプ)
 *  AK_SOFTWARE : Counter1, Counter2, Counter3
 *  AK_HARDWARE : DUMMY_HARDWARE_COUNTER
 *
 * ・mincyc (周期の最小値)
 *  1 : Counter1
 *  2 : Counter2, DUMMY_HARDWARE_COUNTER
 *  3 : Counter3
 *
 * ・maxval (カウンタの最大値)
 *  8  : Counter1
 *  10 : Counter2, DUMMY_HARDWARE_COUNTER
 *  15 : Counter3
 *
 * ・curval (カウンタの現在値)
 *  2 : Counter1, DUMMY_HARDWARE_COUNTER
 *  1 : Counter2
 *  0 : Counter3
 *
 * ・ticksperbase (カウンタ固有の単位に達するまでに必要なティック数)
 *  1 : Counter1, Counter2, DUMMY_HARDWARE_COUNTER
 *  2 : Counter3
 *
 * ・cstat (カウンタの状態)
 *  AK_CS_NULL  : Counter1, Counter2, Counter3
 *  AK_CS_DOING : Counter1(AlarmActTaskが満了点になった際にTaskActTaskから確認する)
 *
 * ・secondspertick (ハードウェアカウンタにおける1ティック当たりの実時間(秒))
 *  1.0 : DUMMY_HARDWARE_COUNTER
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyCounter()】
 *  <ソフトウェアカウンタの場合>
 *   TESRYデータ | 確認するカウンタ カウンタID
 *  -------------------------------------------
 *   ctype       | Counter1
 *   mincyc      | Counter1
 *   maxval      | Counter1
 *   curval      | Counter1
 *   cstat       | Counter1
 *  <ハードウェアカウンタの場合>
 *   TESRYデータ    | 確認するカウンタ カウンタID
 *  ----------------------------------------------
 *   ctype          | DUMMY_HARDWARE_COUNTER
 *   curval         | DUMMY_HARDWARE_COUNTER
 *   secondspertick | DUMMY_HARDWARE_COUNTER
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyCounter()】
 *  <ソフトウェアカウンタの場合>
 *   TESRYデータ    | 確認するカウンタ カウンタID
 *  ---------------------------------------------
 *   ticksperbase   | Counter1
 *   secondspertick | Counter1
 *  <ハードウェアカウンタの場合>
 *   TESRYデータ    | 確認するカウンタ カウンタID
 *  ---------------------------------------------
 *   mincyc         | DUMMY_HARDWARE_COUNTER
 *   maxval         | DUMMY_HARDWARE_COUNTER
 *   cstat          | DUMMY_HARDWARE_COUNTER
 *   ticksperbase   | DUMMY_HARDWARE_COUNTER
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskVerify)
{
	StatusType ercd;

	AktspCheckPoint(2);

	/* ハードウェアカウンタ初期化 */
	ercd = AktspStopHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);
	ercd = AktspInitHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);

	ercd = SetRelAlarm(AlarmActTask, 4, 0);
	CheckErcd(ercd, E_OK);

	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter2);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter3);
	CheckErcd(ercd, E_OK);

	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);
	ercd = AktspIncrementHardwareCounter(DUMMY_HARDWARE_COUNTER);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(3);

	/* タスクからの確認 */
	CheckAktspVerifyCounter();

	AktspCheckPoint(4);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(6);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(8);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(10);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(12);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(14);
	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(TaskActTask)
{
	AktspCounterInfo	vcnt;
	StatusType			ercd;

	AktspCheckPoint(17);

	/*
	 *  Counter1チェック
	 *
	 *  Counter1:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 1
	 *    maxval       : 8
	 *    curval       : 4
	 *    ticksperbase : 1
	 *    cstat        : AK_CS_DOING
	 */
	vcnt.cm_ctype = AK_SOFTWARE;
	vcnt.cm_mincyc = 1;
	vcnt.cm_maxval = 8;
	vcnt.cm_curval = 4;
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_cstat = AK_CS_DOING;

	ercd = AktspVerifyCounter(Counter1, &vcnt);
	CheckErcd(E_OK, ercd);

	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(5);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyCounter();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(7);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyCounter();
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(13);

	/* アラームコールバックからの確認 */
	CheckAktspVerifyCounter();
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(16);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyCounter();
		hookboot = 0;
	}
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(15);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyCounter();
	}
}

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(9);

	/* エラーフックからの確認 */
	CheckAktspVerifyCounter();
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

	AktspCheckPoint(11);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyCounter();

	return(PRO_IGNORE);
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(Counter1);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(18);
	ShutdownOS(E_OK);
}

TASK(DummyTask)
{
	AktspCheckFinish(0);
}

/*
 *  状態確認APIチェック関数
 */
void
CheckAktspVerifyCounter()
{
	StatusType			ercd;
	AktspCounterInfo	vcnt;

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyCounter())
	 */

	/*
	 *  Counter1:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 1
	 *    maxval       : 8
	 *    curval       : 2
	 *    ticksperbase : 1
	 *    cstat        : AK_CS_NULL
	 */
	vcnt.cm_ctype = AK_HARDWARE;  /* 正しくはAK_SOFTWARE */
	vcnt.cm_mincyc = 3;           /* 正しくは1 */
	vcnt.cm_maxval = 10;          /* 正しくは8 */
	vcnt.cm_curval = 5;           /* 正しくは2 */
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_cstat = AK_CS_DOING;  /* 正しくはAK_CS_NULL */

	ercd = AktspVerifyCounter(Counter1, &vcnt);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  DUMMY_HARDWARE_COUNTER:
	 *    type           : COUNTER
	 *    ctype          : AK_HARDWARE
	 *    mincyc         : 2
	 *    maxval         : 10
	 *    curval         : 2
	 *    ticksperbase   : 1
	 *    secondspertick : 1.0
	 */
	vcnt.cm_ctype = AK_SOFTWARE;  /* 正しくはAK_HARDWARE */
	vcnt.cm_mincyc = 2;
	vcnt.cm_maxval = 10;
	vcnt.cm_curval = 5;           /* 正しくは2 */
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_secondspertick = 2.0; /* 正しくは1.0 */

	ercd = AktspVerifyCounter(DUMMY_HARDWARE_COUNTER, &vcnt);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyCounter())
	 */

	/*
	 *  Counter1:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 1
	 *    maxval       : 8
	 *    curval       : 2
	 *    ticksperbase : 1
	 *    cstat        : AK_CS_NULL
	 */
	vcnt.cm_ctype = AK_SOFTWARE;
	vcnt.cm_mincyc = 1;
	vcnt.cm_maxval = 8;
	vcnt.cm_curval = 2;
	vcnt.cm_ticksperbase = 2;     /* 正しくは1 */
	vcnt.cm_secondspertick = 2.0; /* 正しくは1.0 */
	vcnt.cm_cstat = AK_CS_NULL;

	ercd = AktspVerifyCounter(Counter1, &vcnt);
	CheckErcd(E_OK, ercd);

	/*
	 *  DUMMY_HARDWARE_COUNTER:
	 *    type           : COUNTER
	 *    ctype          : AK_HARDWARE
	 *    mincyc         : 1
	 *    maxval         : 8
	 *    curval         : 2
	 *    ticksperbase   : 1
	 *    secondspertick : 1.0
	 */
	vcnt.cm_ctype = AK_SOFTWARE;  /* 正しくはAK_HARDWARE */
	vcnt.cm_mincyc = 1;
	vcnt.cm_maxval = 8;
	vcnt.cm_curval = 5;           /* 正しくは2 */
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_secondspertick = 1.0;

	ercd = AktspVerifyCounter(DUMMY_HARDWARE_COUNTER, &vcnt);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  各カウンタの状態確認
	 */

	/*
	 *  Counter1チェック
	 *
	 *  Counter1:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 1
	 *    maxval       : 8
	 *    curval       : 2
	 *    ticksperbase : 1
	 *    cstat        : AK_CS_NULL
	 */
	vcnt.cm_ctype = AK_SOFTWARE;
	vcnt.cm_mincyc = 1;
	vcnt.cm_maxval = 8;
	vcnt.cm_curval = 2;
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_cstat = AK_CS_NULL;

	ercd = AktspVerifyCounter(Counter1, &vcnt);
	CheckErcd(E_OK, ercd);

	/*
	 *  Counter2チェック
	 *
	 *  Counter2:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 2
	 *    maxval       : 10
	 *    curval       : 1
	 *    ticksperbase : 1
	 *    cstat        : AK_CS_NULL
	 */
	vcnt.cm_ctype = AK_SOFTWARE;
	vcnt.cm_mincyc = 2;
	vcnt.cm_maxval = 10;
	vcnt.cm_curval = 1;
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_cstat = AK_CS_NULL;

	ercd = AktspVerifyCounter(Counter2, &vcnt);
	CheckErcd(E_OK, ercd);

	/*
	 *  Counter3チェック
	 *
	 *  Counter3:
	 *    type         : COUNTER
	 *    ctype        : AK_SOFTWARE
	 *    mincyc       : 3
	 *    maxval       : 15
	 *    curval       : 0
	 *    ticksperbase : 2
	 *    cstat        : AK_CS_NULL
	 */
	vcnt.cm_ctype = AK_SOFTWARE;
	vcnt.cm_mincyc = 3;
	vcnt.cm_maxval = 15;
	vcnt.cm_curval = 0;
	vcnt.cm_ticksperbase = 2;
	vcnt.cm_cstat = AK_CS_NULL;

	ercd = AktspVerifyCounter(Counter3, &vcnt);
	CheckErcd(E_OK, ercd);

	/*
	 *  DUMMY_HARDWARE_COUNTER:
	 *    type           : COUNTER
	 *    ctype          : AK_HARDWARE
	 *    mincyc         : 2
	 *    maxval         : 10
	 *    curval         : 2
	 *    ticksperbase   : 1
	 *    secondspertick : 1.0
	 */
	vcnt.cm_ctype = AK_HARDWARE;
	vcnt.cm_mincyc = 2;
	vcnt.cm_maxval = 10;
	vcnt.cm_curval = 2;
	vcnt.cm_ticksperbase = 1;
	vcnt.cm_secondspertick = 1.0;

	ercd = AktspVerifyCounter(DUMMY_HARDWARE_COUNTER, &vcnt);
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
