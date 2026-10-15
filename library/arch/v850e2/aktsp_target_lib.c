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
 *  $Id: aktsp_target_lib.c 347 2014-09-17 00:28:35Z fsi-dankei $
 */

#include "aktsp_target_lib.h"

/*
 *  各スタック領域の定義
 */
#ifdef AKTG_USE_SHARE_STACK

/* スタックオーバーフローさせる先頭番地を一時的に格納する変数 */
uint8 *aktg_temp_stk;

/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む) */
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else
uint8 aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#if AKTG_STACK_NUM != 0
/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#else
uint8 aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */
#endif /* AKTG_STACK_NUM != 0 */

#endif /* AKTG_USE_SHARE_STACK */


/*
 *  テストライブラリ初期化(ターゲット依存部)
 */
uint32 bss_init_check;
uint32 data_init_check = 0x4E434553U;
extern void InitSerial(void);
void print_banner(void);
void
AktspInitializeTargetTestLib(void)
{
	static boolean boot_chk = FALSE;

	print_banner();

	/* bssセクションの初期化チェック */
	if ((boot_chk == FALSE) && (bss_init_check != 0U)) {
		AktspOutputLog_0("bss init error !!");
		AktspOutputLog_0("Kernel Exit...");
		while(1);
	}

	/* dataセクションの初期化チェック */
	if ((boot_chk == FALSE) && (data_init_check != 0x4E434553U)) {
		AktspOutputLog_0("data init error !!");
		AktspOutputLog_0("Kernel Exit...");
		while(1);
	}

	/* 1回起動したことをチェック */
	boot_chk = TRUE;
}

/*
 *  割込みの発生
 */
void
AktspRaiseInterrupt(InterruptNumberType intno)
{
	uint32 eic_address;

	eic_address = EIC_ADDRESS(intno);
	sil_wrh_mem((void *)eic_address,
				(sil_reh_mem((void *)eic_address)  | 0x1000));
}

/*
 *  割込み要求のクリア
 */
void
AktspClearIntRequest(InterruptNumberType intno)
{
	uint32 eic_address;

	eic_address = EIC_ADDRESS(intno);
	sil_wrh_mem((void *)eic_address ,
				(sil_reh_mem((void *)eic_address)  & ~0x1000));
}

/*
 *  割込み要求のキャンセル
 */
void
AktspCancelIntRequest(InterruptNumberType intno)
{
	uint32 eic_address;

	eic_address = EIC_ADDRESS(intno);
	sil_wrh_mem((void *)eic_address ,
				(sil_reh_mem((void *)eic_address)  & ~0x1000));
}

#define SEG_CONT 0xffff64B0
#define SEG_FLAG 0xffff64B2

/*
 *  プロテクションフック起動
 */
void
AktspRaiseProtectionHook(void)
{
	/* CPU例外によってプロテクションフックを起動 */
	AktspRaiseCPUException();
}

/*
 *  プロテクションフック初期処理
 */
void
AktspProtectionHookInit(void)
{
	/* リザーブ領域アクセス通知クリア */
	sil_reh_mem((void *)SEG_FLAG);
	sil_wrh_mem((void *)SEG_FLAG,0x0000);
}

/*
 * プロテクションフックにおけるデバッグ用関数(ターゲット依存)
 */
void
AktspProtectionHookTargetDebug(StatusType FatalError)
{
#ifdef CFG_USE_PROTECTIONHOOK
	AktspOutputLog_1("v850_cpu_exp_no:%d", v850_cpu_exp_no);
	AktspOutputLog_1("v850_cpu_exp_pc:0x%x", v850_cpu_exp_pc);
	AktspOutputLog_1("v850_cpu_exp_sp:0x%x", v850_cpu_exp_sp);
#endif /* CFG_USE_PROTECTIONHOOK */
}

/*
 *  スタックオーバーフロー発生
 *  (タスク系システムサービス発行時)
 */
void
AktspRaiseTaskStackOverflowByDispatch(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info)
{
	StatusType ercd = E_OK;

	/* 検出方式によってスタックオーバーフロー発生処理を変える */
	if (info->stk_mode == AK_SMM_MAGIC_NUMBER) {
		/* マジックナンバー領域を変更する */
		stk[0] = (uint8)~(stk[0]);
	}
	else {
		/*
		 * スタックポインタを先頭へずらす
		 * ※先頭からは他のタスクのスタックか，予備の領域となっているため問題ない
		 */
		AKTSP_SHIFT_SP;
	}

	/* actionによってスタックオーバーフロー検出アクションを変える */
	switch (info->stk_action) {
	case AK_SOA_ACTIVATE_TASK:
		ercd = ActivateTask(info->stk_task);
		break;
	case AK_SOA_TERMINATE_TASK:
		ercd = TerminateTask();
		break;
	case AK_SOA_CHAIN_TASK:
		ercd = ChainTask(info->stk_task);
		break;
	case AK_SOA_SCHEDULE:
		ercd = Schedule();
		break;
	case AK_SOA_SET_EVENT:
		ercd = SetEvent(info->stk_task, info->stk_event);
		break;
	case AK_SOA_WAIT_EVENT:
		ercd = WaitEvent(info->stk_event);
		break;
	case AK_SOA_RELEASE_RESOURCE:
		ercd = ReleaseResource(info->stk_resource);
		break;
	default:
		CheckAssert(FALSE);
		break;
	}

	/* エラー発生等によりディスパッチしなかった場合に備えてassert */
	CheckAssert(ercd == E_OK);
}

/*
 *  スタックオーバーフロー発生
 *  (割込み発生時)
 */
void
AktspRaiseTaskStackOverflowByInterrupt(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info)
{
	/* 検出方式によってスタックオーバーフロー発生処理を変える */
	if (info->stk_mode == AK_SMM_MAGIC_NUMBER) {
		/* マジックナンバー領域を変更する */
		stk[0] = (uint8)~(stk[0]);
	}
	else {
		/*
		 * スタックポインタを先頭へずらす
		 * ※先頭からは他のタスクのスタックか，予備の領域となっているため問題ない
		 */
		AKTSP_SHIFT_SP;
	}

	/* 割込み発生時にスタックオーバーフロー検出 */
	AktspRaiseInterrupt(info->stk_intno);

	/* 割込みが即座に発生しない場合に備えビジーウェイト */
	AktspBusyWait();
}

/*
 *  スタックオーバーフロー発生
 *  (多重割込み発生時)
 */
void
AktspRaiseIsrStackOverflowByInterrupt(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info)
{
	/* 検出方式によってスタックオーバーフロー発生処理を変える */
	if (info->stk_mode == AK_SMM_MAGIC_NUMBER) {
		/* マジックナンバー領域を変更する */
		stk[0] = (uint8)~(stk[0]);
	}
	else {
		/*
		 * スタックポインタを先頭へずらす
		 * ※先頭からは予備の領域となっているため問題ない
		 */
		AKTSP_SHIFT_SP;
	}

	/* 割込み発生時にスタックオーバーフロー検出 */
	AktspRaiseInterrupt(info->stk_intno);

	/* 割込みが即座に発生しない場合に備えビジーウェイト */
	AktspBusyWait();
}

/*
 *  スタックオーバーフロー発生
 *  (割込みリターン時)
 */
void
AktspRaiseIsrStackOverflowByReturn(uint8* stk, MemorySizeType size)
{
	/* マジックナンバー領域を変更する */
	stk[0] = (uint8)~(stk[0]);
}

/*
 *  スタックオーバーフロー発生
 *  (信頼関数リターン時)
 */
void
AktspRaiseTfnStackOverflowByReturn(uint8 *stk, MemorySizeType size)
{
	/* マジックナンバー領域を変更する */
	stk[0] = (uint8)~(stk[0]);
}

/*
 *  CPU例外発生
 */
void
AktspRaiseCPUException(void)
{
	/* リザーブ領域アクセス通知クリア */
	sil_reh_mem((void *)SEG_FLAG);
	sil_wrh_mem((void *)SEG_FLAG, 0x0000);
#ifdef _V850E2M_
	/* リザーブ領域アクセス通知イネーブル */
	sil_wrh_mem((void *)SEG_CONT, 0x0020);
	/* リザーブ領域アクセス通知 */
	sil_wrh_mem((void *)SEG_FLAG, 0x0020);
#else /* _V850E2S_ */
	/* リザーブ領域アクセス通知イネーブル */
	sil_wrh_mem((void *)SEG_CONT, 0x0010);
	/* リザーブ領域アクセス通知 */
	sil_wrh_mem((void *)SEG_FLAG, 0x0010);
#endif /* _V850E2M_ */
}
