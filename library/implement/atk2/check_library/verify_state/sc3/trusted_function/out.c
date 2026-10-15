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
 *  ・AktspVerifyTrustedFunction()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyTrustedFunction()】
 * ・osap (所属するOSアプリケーション)
 *  TRUSTED_OSAP1     : TrustedFunction1
 *  NON_TRUSTED_OSAP1 : TrustedFunction2, TrustedFunction3
 *
 * ・stksz (信頼関数で使用するスタックサイズ)
 *  256  : TrustedFunction1
 *  512  : TrustedFunction2
 *  1024 : TrustedFunction3
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyTrustedFunction()】
 *   TESRYデータ | 確認するアラーム アラームID
 *  ---------------------------------------------
 *   stksz       | TrustedFunction1
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyTrustedFunction()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  --------------------------------------------------------------------
 *   osap        | TrustedFunction1
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TrustedTask)
{
	StatusType ercd;

	AktspCheckPoint(2);

	/* 信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyTrustedFunction();

	AktspCheckPoint(3);

	ercd = ActivateTask(NonTrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(11);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(13);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(15);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(18);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(20);

	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(NonTrustedTask)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(4);

	/* 非信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyTrustedFunction();

	AktspCheckPoint(5);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(TrustedFunction1, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(7);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(10);

	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_TrustedFunction1, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(6);

	/* 信頼関数からの確認 */
	CheckAktspVerifyTrustedFunction();

	return E_OK;
}

TRUSTEDFUNCTION(TRUSTED_TrustedFunction2, FunctionIndex, FunctionParams)
{
	return E_OK;
}

TRUSTEDFUNCTION(TRUSTED_TrustedFunction3, FunctionIndex, FunctionParams)
{
	return E_OK;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(12);

	/* 信頼OSAPに所属するカテゴリ2 ISRからの確認 */
	CheckAktspVerifyTrustedFunction();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY(void)
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(14);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyTrustedFunction();
}

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	/* 非信頼OSAPからの起動 */
	if (bootcnt == 0) {
		AktspCheckPoint(8);
	}
	else if (bootcnt == 1) {
		AktspCheckPoint(16);
	}

	/* エラーフックからの確認 */
	CheckAktspVerifyTrustedFunction();

	bootcnt++;
}

#if 0
void
ErrorHook_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(17);

	/* 信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyTrustedFunction();
}

void
ErrorHook_NON_TRUSTED_OSAP5(StatusType ercd)
{
	AktspCheckPoint(9);

	/* 非信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyTrustedFunction();
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

	AktspCheckPoint(19);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyTrustedFunction();

	return(PRO_IGNORE);
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(21);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyTrustedFunction();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(22);

		/* プレタスクフックからの確認 */
		CheckAktspVerifyTrustedFunction();
		hookboot = 0;
	}
}

TASK(MainTask)
{
	StatusType ercd;

	hookboot = 0;

	AktspCheckPoint(1);

	ercd = ActivateTask(TrustedTask);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(23);
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
CheckAktspVerifyTrustedFunction(void)
{
	StatusType					ercd;
	AktspTrustedFunctionInfo	vtfn;

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTrustedFunction())
	 */

	/*
	 *  TrustedFunction1:
	 *    type  : TRUSTED_FUNCTION
	 *    stksz : 256
	 *    osap  : TRUSTED_OSAP1
	 */
	vtfn.tfm_stksz = 512;          /* 正しくは256 */
	vtfn.tfm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTrustedFunction(TrustedFunction1, &vtfn);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyTrustedFunction())
	 */

	/*
	 *  TrustedFunction1:
	 *    type  : TRUSTED_FUNCTION
	 *    stksz : 256
	 *    osap  : TRUSTED_OSAP1
	 */
	vtfn.tfm_stksz = 256;
	vtfn.tfm_osap = NON_TRUSTED_OSAP5;  /* 正しくはTRUSTED_OSAP1 */

	ercd = AktspVerifyTrustedFunction(TrustedFunction1, &vtfn);
	CheckErcd(E_OK, ercd);

	/*
	 *  各信頼関数の状態確認
	 */

	/*
	 *  TrustedFunction1チェック
	 *
	 *  TrustedFunction1:
	 *    type  : TRUSTED_FUNCTION
	 *    stksz : 256
	 *    osap  : TRUSTED_OSAP1
	 */
	vtfn.tfm_stksz = 256;
	vtfn.tfm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTrustedFunction(TrustedFunction1, &vtfn);
	CheckErcd(E_OK, ercd);

	/*
	 *  TrustedFunction2チェック
	 *
	 *  TrustedFunction2:
	 *    type  : TRUSTED_FUNCTION
	 *    stksz : 512
	 *    osap  : TRUSTED_OSAP1
	 */
	vtfn.tfm_stksz = 512;
	vtfn.tfm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTrustedFunction(TrustedFunction2, &vtfn);
	CheckErcd(E_OK, ercd);

	/*
	 *  TrustedFunction3チェック
	 *
	 *  TrustedFunction3:
	 *    type  : TRUSTED_FUNCTION
	 *    stksz : 1024
	 *    osap  : TRUSTED_OSAP1
	 */
	vtfn.tfm_stksz = 1024;
	vtfn.tfm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTrustedFunction(TrustedFunction3, &vtfn);
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
