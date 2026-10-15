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
 *  ・AktspVerifyC2Isr()
 *  ・AktspVerifyC2IsrRelResource()
 *  ・AktspVerifyC2IsrGetResource()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyC2Isr()】
 * ・intno (割込み番号)
 *  AKTSP_INTNO_E : AKTG_C2ISR_COMMON_AKTSP_INTNO_E
 *  AKTSP_INTNO_F : AKTG_C2ISR_COMMON_AKTSP_INTNO_F
 *  AKTSP_INTNO_I : AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・iniintpri (割込み優先度)
 *  4 : AKTG_C2ISR_COMMON_AKTSP_INTNO_E
 *  3 : AKTG_C2ISR_COMMON_AKTSP_INTNO_F
 *  2 : AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・curintpri (割込み優先度)
 *  4 : AKTG_C2ISR_COMMON_AKTSP_INTNO_E
 *  3 : AKTG_C2ISR_COMMON_AKTSP_INTNO_F
 *  4 : AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・rtnstat (処理単位動作状態)
 *  AK_ACTIVATE : AKTG_C2ISR_COMMON_AKTSP_INTNO_E, AKTG_C2ISR_COMMON_AKTSP_INTNO_F(カテゴリ2 ISRから確認する場合のみ)
 *  AK_STOP     : AKTG_C2ISR_COMMON_AKTSP_INTNO_E, AKTG_C2ISR_COMMON_AKTSP_INTNO_F, AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・intatr (割込み属性)
 *  AK_ENABLE : AKTG_C2ISR_COMMON_AKTSP_INTNO_E, AKTG_C2ISR_COMMON_AKTSP_INTNO_F, AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・istat (割込み要求禁止フラグ)
 *  AK_ENABLE : AKTG_C2ISR_COMMON_AKTSP_INTNO_E, AKTG_C2ISR_COMMON_AKTSP_INTNO_F, AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・istksz (スタック領域のサイズ)
 *  256 : AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * ・getrescount(獲得済みリソース数)
 *  0 : AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *  1 : AKTG_C2ISR_COMMON_AKTSP_INTNO_F
 *  2 : AKTG_C2ISR_COMMON_AKTSP_INTNO_E
 *
 * 【AktspVerifyC2IsrRelResource()】
 * ・relres (関連付けられたリソース)
 *  ※TaskDummy1は確認しない
 *  ResourceA : AKTG_C2ISR_COMMON_AKTSP_INTNO_E，AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *  ResourceB : AKTG_C2ISR_COMMON_AKTSP_INTNO_E，TaskDummy1
 *  ResourceC : AKTG_C2ISR_COMMON_AKTSP_INTNO_F，TaskVerify
 *
 * 【AktspVerifyC2IsrGetResource()】
 * ・getres (獲得したリソース)
 *  ※ 左から順に獲得
 *  ResourceC            : AKTG_C2ISR_COMMON_AKTSP_INTNO_F(カテゴリ2 ISRから確認する場合のみ)
 *  ResourceB, ResourceA : AKTG_C2ISR_COMMON_AKTSP_INTNO_E(カテゴリ2 ISRから確認する場合のみ)
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyC2Isr()】
 *   TESRYデータ | 確認するカテゴリ2 ISRのISR ID
 *  -----------------------------------------------
 *   intno       | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   iniintpri   | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   curintpri   | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   intatr      | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   getrescount | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * 【AktspVerifyC2IsrGetResource()】
 *   TESRYデータ | 確認するカテゴリ2 ISRのISR ID
 *  -----------------------------------------------
 *   getres      | AKTG_C2ISR_COMMON_AKTSP_INTNO_E
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyC2Isr()】
 *   TESRYデータ | 確認するカテゴリ2 ISRのISR ID
 *  -----------------------------------------------
 *   istat       | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   rtnstat     | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *   istksz      | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 *
 * 【AktspVerifyC2IsrRelResource()】
 *   TESRYデータ | 確認するカテゴリ2 ISRのISR ID
 *  -----------------------------------------------
 *   relres      | AKTG_C2ISR_COMMON_AKTSP_INTNO_I
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskVerify)
{
	StatusType ercd;

	AktspCheckPoint(10);

	/* タスクからの確認 */
	CheckAktspVerifyIsr();

	AktspCheckPoint(11);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(13);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(15);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(17);

	/* アラームコールバックの呼び出し */
	ercd = SetRelAlarm(AlarmVerify, 1, 0);
	CheckErcd(ercd, E_OK);
	ercd = IncrementCounter(CounterVerify);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(19);
	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(DummyTask)
{
	AktspCheckPoint(0);
}

TASK(TaskDummy1)
{
	AktspCheckPoint(0);
	TerminateTask();
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_E)
{
	StatusType ercd;

	AktspClearIntRequest(AKTSP_INTNO_E);

	AktspCheckPoint(4);

	ercd = GetResource(ResourceB);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(ResourceA);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(5);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyIsr();

	AktspCheckPoint(6);

	ercd = ReleaseResource(ResourceA);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(ResourceB);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(7);

	return;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	StatusType ercd;

	AktspClearIntRequest(AKTSP_INTNO_F);

	AktspCheckPoint(2);

	ercd = GetResource(ResourceC);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(3);

	/* カテゴリ2 ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_E)起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_E);

	AktspCheckPoint(8);

	ercd = ReleaseResource(ResourceC);
	CheckErcd(ercd, E_OK);

	return;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_I)
{
	StatusType		ercd;
	AktspISRInfo	visr;

	AktspCheckPoint(22);

	AktspClearIntRequest(AKTSP_INTNO_I);

	ercd = GetResource(ResourceA);
	CheckErcd(ercd, E_OK);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyC2Isr())
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    rtnstat   : AK_ACTIVATE
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	visr.im_intno = AKTSP_INTNO_I;
	visr.im_iniintpri = 4;   /* 正しくは2 */
	visr.im_curintpri = 2;   /* 正しくは4 */
	visr.im_rtnstat = AK_ACTIVATE;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_ENABLE;
	visr.im_istksz = 256;
	visr.im_getrescount = 0; /* 正しくは1 */

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, &visr);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_Iの状態確認
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_Iチェック
	 *
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    curintpri : 4
	 *    rtnstat   : AK_ACTIVATE
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	visr.im_intno = AKTSP_INTNO_I;
	visr.im_iniintpri = 2;
	visr.im_curintpri = 4;
	visr.im_rtnstat = AK_ACTIVATE;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_ENABLE;
	visr.im_istksz = 256;
	visr.im_getrescount = 1;

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, &visr);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyC2IsrRelResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, ResourceA);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, 1, ResourceA);
	CheckErcd(E_OK, ercd);

	AktspCheckPoint(23);

	ercd = ReleaseResource(ResourceA);
	CheckErcd(ercd, E_OK);

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY()
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(12);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyIsr();
}

ALARMCALLBACK(AlarmCallBackVerify)
{
	AktspCheckPoint(18);

	/* アラームコールバックからの確認 */
	CheckAktspVerifyIsr();
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(21);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyIsr();
		hookboot = 0;
	}
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(20);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyIsr();
	}
}

void
ErrorHook(StatusType ercd)
{
	AktspCheckPoint(14);

	/* エラーフックからの確認 */
	CheckAktspVerifyIsr();
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

	AktspCheckPoint(16);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyIsr();

	return(PRO_IGNORE);
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	/* カテゴリ2 ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(9);

	ercd = ActivateTask(TaskVerify);
	CheckErcd(ercd, E_OK);

	/* カテゴリ2 ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_I)起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_I);

	AktspCheckFinish(24);
	ShutdownOS(E_OK);
}

/*
 *  状態確認APIチェック関数
 */
void
CheckAktspVerifyIsr()
{
	StatusType		ercd;
	AktspISRInfo	visr;
	static uint16	bootcnt = 0;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0 : カテゴリ2 ISR
	 *  1 : タスク
	 *  2 : カテゴリ1 ISR
	 *  3 : エラーフック
	 *  4 : アラームコールバック
	 *  5 : ポストタスクフック
	 *  6 : プレタスクフック
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyC2Isr())
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    rtnstat   : AK_STOP
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	visr.im_intno = AKTSP_INTNO_E; /* 正しくはAKTSP_INTNO_I */
	visr.im_iniintpri = 4;         /* 正しくは2 */
	visr.im_curintpri = AKTSP_INVALID_VALUE;
	visr.im_rtnstat = AK_STOP;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_DISABLE;    /* 正しくはAK_ENABLE */
	visr.im_istksz = 256;
	visr.im_getrescount = 1;       /* 正しくは0 */

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, &visr);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyC2IsrGetResource())
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_E:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_E
	 *    iniintpri : 4
	 *    rtnstat   : AK_ACTIVATE
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *      - ResourceB
	 *    getres  :
	 *      - ResourceB
	 *      - ResourceA
	 */
	if (bootcnt == 0) {
		ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, 2, ResourceB); /* 正しくは第2引数が1 */
		CheckErcd(E_NOT_OK, ercd);
		ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, 2, ResourceB); /* 正しくは第3引数がResourceA */
		CheckErcd(E_NOT_OK, ercd);
	}

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyC2Isr())
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    rtnstat   : AK_STOP
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	visr.im_intno = AKTSP_INTNO_I;
	visr.im_iniintpri = 2;
	visr.im_rtnstat = AK_ACTIVATE; /* 正しくはAK_STOP */
	visr.im_istat = AK_DISABLE;    /* 正しくはAK_ENABLE */
	visr.im_intatr = AK_ENABLE;
	visr.im_istksz = 512;          /* 正しくは256 */
	visr.im_getrescount = 0;

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, &visr);
	CheckErcd(E_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyC2IsrRelResource())
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    rtnstat   : AK_STOP
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	ercd = AktspVerifyC2IsrRelResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, ResourceB); /* 正しくは第2引数がResourceA */
	CheckErcd(E_OK, ercd);

	/*
	 *  各カテゴリ2 ISRの状態確認
	 */

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_Eチェック
	 *
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_E:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_E
	 *    iniintpri : 4
	 *    curintpri : 4
	 *    rtnstat   : AK_ACTIVATE
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *      - ResourceB
	 *    getres    :
	 *      - ResourceB
	 *      - ResourceA
	 */
	visr.im_intno = AKTSP_INTNO_E;
	visr.im_iniintpri = 4;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_ENABLE;
	if (bootcnt == 0) {
		visr.im_rtnstat = AK_ACTIVATE;
		visr.im_getrescount = 2;
		visr.im_curintpri = 4;
	}
	else {
		visr.im_rtnstat = AK_STOP;
		visr.im_getrescount = 0;
	}

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, &visr);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyC2IsrRelResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, ResourceA);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyC2IsrRelResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, ResourceB);
	CheckErcd(E_OK, ercd);

	if (bootcnt == 0) {
		ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, 1, ResourceB);
		CheckErcd(E_OK, ercd);
		ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_E, 2, ResourceA);
		CheckErcd(E_OK, ercd);
	}

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_Fチェック
	 *
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_F:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_F
	 *    iniintpri : 3
	 *    rtnstat   : AK_STOP
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceC
	 *    getres    :
	 *      - ResourceC
	 */
	visr.im_intno = AKTSP_INTNO_F;
	visr.im_iniintpri = 3;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_ENABLE;
	visr.im_rtnstat = AK_STOP;
	if (bootcnt == 0) {
		visr.im_getrescount = 1;
		visr.im_curintpri = 3;
	}
	else {
		visr.im_getrescount = 0;
	}

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_F, &visr);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyC2IsrRelResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_F, ResourceC);
	CheckErcd(E_OK, ercd);

	if (bootcnt == 0) {
		ercd = AktspVerifyC2IsrGetResource(AKTG_C2ISR_COMMON_AKTSP_INTNO_F, 1, ResourceC);
		CheckErcd(E_OK, ercd);
	}

	/*
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_Iチェック
	 *
	 *  AKTG_C2ISR_COMMON_AKTSP_INTNO_I:
	 *    type      : C2ISR
	 *    intno     : AKTSP_INTNO_I
	 *    iniintpri : 2
	 *    rtnstat   : AK_STOP
	 *    istat     : AK_ENABLE
	 *    intatr    : AK_ENABLE
	 *    relres    :
	 *      - ResourceA
	 *    istksz    : 256
	 */
	visr.im_intno = AKTSP_INTNO_I;
	visr.im_iniintpri = 2;
	visr.im_rtnstat = AK_STOP;
	visr.im_istat = AK_ENABLE;
	visr.im_intatr = AK_ENABLE;
	visr.im_istksz = 256;
	visr.im_getrescount = 0;

	ercd = AktspVerifyC2Isr(AKTG_C2ISR_COMMON_AKTSP_INTNO_I, &visr);
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
