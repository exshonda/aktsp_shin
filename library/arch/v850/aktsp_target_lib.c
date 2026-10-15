/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
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
 *  $Id: aktsp_target_lib.c 477 2014-10-14 07:16:42Z ikegaya $
 */

#include "aktsp_target_lib.h"
#include "kernel/interrupt.h"

/*
 *  各スタック領域の定義
 */
#ifdef AKTG_USE_SHARE_STACK

/* スタックオーバーフローさせる先頭番地を一時的に格納する変数 */
uint8 *aktg_temp_stk;

#ifdef CFG_USE_SCALABILITYCLASS1
/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む) */
#ifndef AKTG_CORE_NUM

/* シングルコア */

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else
uint8 aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#else /* AKTG_CORE_NUM */

/* マルチルコア */

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else
uint8 aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#endif /* AKTG_CORE_NUM */


/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTG_CORE_NUM

/* シングルコア */

#if defined(AKTG_STACK_NUM) && (AKTG_STACK_NUM != 0)

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
uint8 aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#endif /* defined(AKTG_STACK_NUM) && (AKTG_STACK_NUM != 0) */

#else /* AKTG_CORE_NUM */

#if T_TASK_NUM_CORE0 != 0

/* マルチコア */

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
uint8 aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE];
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#endif /* T_TASK_NUM_CORE0 != 0 */

#if defined(T_TASK_NUM_CORE1) && T_TASK_NUM_CORE1 != 0

#ifndef AKTSP_OMIT_DEFINE_VAR_STACK
DEFINE_VAR_STACK(uint8, aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#else /* AKTSP_OMIT_DEFINE_VAR_STACK */
uint8 aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#endif /* AKTSP_OMIT_DEFINE_VAR_STACK */

#endif /* T_TASK_NUM_CORE1 != 0 */

#endif /* AKTG_CORE_NUM */
#endif /* CFG_USE_SCALABILITYCLASS1 */

#ifdef CFG_USE_SCALABILITYCLASS3
/* OS/割込み用スタック(スタックモニタリングテスト実施時の割込み用バッファ領域を含む)，非信頼フック用スタック */
#ifndef AKTG_CORE_NUM
DEFINE_VAR_SSTACK(uint8, aktg_os_stack[AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#else /* AKTG_CORE_NUM */
DEFINE_VAR_SSTACK(uint8, aktg_os_stack[AKTG_CORE_NUM][AKTSP_OS_STACK_SIZE + AKTSP_BUFFER_STACK_SIZE]);
#endif /* AKTG_CORE_NUM */

/* タスク用スタック(スタックモニタリングテスト実施時は1つ余分に確保される) */
#ifndef AKTG_CORE_NUM
#if AKTG_STACK_NUM != 0
DEFINE_VAR_SSTACK(uint8, aktg_stack[AKTG_STACK_NUM][AKTSP_TASK_STACK_SIZE]);
#endif /* AKTG_STACK_NUM != 0 */
#if AKTG_USTACK_NUM != 0
DEFINE_VAR_SSTACK(uint8, aktg_sstack[AKTG_USTACK_NUM][AKTSP_TASK_STACK_SIZE]);
DEFINE_VAR_USTACK(uint8, aktg_ustack[AKTG_USTACK_NUM][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* AKTG_USTACK_NUM != 0 */

#else /* AKTG_CORE_NUM */
#if T_TASK_NUM_CORE0 != 0
DEFINE_VAR_SSTACK(uint8, aktg_stack_core0[T_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE0 != 0 */
#if T_TASK_NUM_CORE1 != 0
DEFINE_VAR_SSTACK(uint8, aktg_stack_core1[T_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
#endif /* T_TASK_NUM_CORE1 != 0 */
#if N_TASK_NUM_CORE0 != 0
DEFINE_VAR_SSTACK(uint8, aktg_sstack_core0[N_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE]);
DEFINE_VAR_USTACK(uint8, aktg_ustack_core0[N_TASK_NUM_CORE0][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* N_TASK_NUM_CORE0 != 0 */
#if N_TASK_NUM_CORE1 != 0
DEFINE_VAR_SSTACK(uint8, aktg_sstack_core1[N_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE]);
DEFINE_VAR_USTACK(uint8, aktg_ustack_core1[N_TASK_NUM_CORE1][AKTSP_TASK_STACK_SIZE], ".stack_section");
#endif /* N_TASK_NUM_CORE1 != 0 */
#endif /* AKTG_CORE_NUM */

#endif /* CFG_USE_SCALABILITYCLASS3 */
#endif /* AKTG_USE_SHARE_STACK */

/* 自コア以外の割込み番号を無視するマクロ(マルチコア用) */
#ifdef AKTG_CORE_NUM
#define AKTSP_IGNORE_INTERRUPT(intno)			\
	if ((GetCoreID() + 1) != (intno >> 16U)) {	\
		return;									\
	}
#endif /* AKTG_CORE_NUM */

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
 *  各コアで実行するテストライブラリ初期化(ターゲット依存部)
 */
void
AktspInitializeTargetTestLibEachCore(void)
{
}

/*
 *  割込みの発生
 */
void
AktspRaiseInterrupt(InterruptNumberType intno)
{
	uint32 eic_address;

#ifdef AKTG_CORE_NUM
	/* マルチコアでは下位16bitがHW上の割込み番号 */
	intno &= 0x0000FFFF;
#endif /* AKTG_CORE_NUM */

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

#ifdef AKTG_CORE_NUM
	/* マルチコアでは下位16bitがHW上の割込み番号 */
	intno &= 0x0000FFFF;
#endif /* AKTG_CORE_NUM */

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

#ifdef AKTG_CORE_NUM
	/* マルチコアでは下位16bitがHW上の割込み番号 */
	intno &= 0x0000FFFF;
#endif /* AKTG_CORE_NUM */

	eic_address = EIC_ADDRESS(intno);
	sil_wrh_mem((void *)eic_address ,
				(sil_reh_mem((void *)eic_address)  & ~0x1000));
}

#ifdef __v850e2v3__
#define SEG_CONT 0xffff64B0
#define SEG_FLAG 0xffff64B2
#elif defined(__v850e3v5__)
#ifdef _RH850G3K_
#define SEG_CONT 0xffff8c00
#define SEG_FLAG 0xffff8c02
#elif defined(_RH850G3KH_)
/*
 *  RH850 G3KH (F1K/F1KM): the SEG register layout of G3K/G3M is not assumed.
 *  The CPU exception is raised with FETRAP (FE level -> ProtectionHook) instead.
 */
#define AKTSP_RAISE_CPU_EXCEPTION_BY_FETRAP
#elif defined(_RH850G3M_)
#define SEG_CONT 0xfffee980
#define SEG_FLAG 0xfffee982
#else
#error please define ether _RH850G3K_ or _RH850G3M_
#endif /* _RH850G3K_ */
#else  /* __v850e3v5__ */
#error please define ether __v850e2v3__ or __v850e3v5__
#endif /* __v850e2v3__ */

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
#ifndef AKTSP_RAISE_CPU_EXCEPTION_BY_FETRAP
	sil_reh_mem((void *)SEG_FLAG);
	sil_wrh_mem((void *)SEG_FLAG,0x0000);
#endif /* AKTSP_RAISE_CPU_EXCEPTION_BY_FETRAP */
}

/*
 * プロテクションフックにおけるデバッグ用関数(ターゲット依存)
 */
void
AktspProtectionHookTargetDebug(StatusType FatalError)
{
#ifdef CFG_USE_PROTECTIONHOOK
#ifdef TotalNumberOfCores
	CoreIdType coreid = GetCoreID();
	AktspOutputLog_2("v850_cpu_exp_no_table[%d]:%d", coreid, v850_cpu_exp_no_table[coreid]);
	AktspOutputLog_2("v850_cpu_exp_pc_table[%d]:0x%x", coreid, v850_cpu_exp_pc_table[coreid]);
	AktspOutputLog_2("v850_cpu_exp_sp_table[%d]:0x%x", coreid, v850_cpu_exp_sp_table[coreid]);
#else /* !TotalNumberOfCores */
	AktspOutputLog_1("v850_cpu_exp_no:%d", v850_cpu_exp_no);
	AktspOutputLog_1("v850_cpu_exp_pc:0x%x", v850_cpu_exp_pc);
	AktspOutputLog_1("v850_cpu_exp_sp:0x%x", v850_cpu_exp_sp);
#endif /* TotalNumberOfCores */
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
#ifdef CFG_USE_STACKMONITORING
	/* 検出方式によってスタックオーバーフロー発生処理を変える */
	if (info->stk_mode == AK_SMM_MAGIC_NUMBER) {
		/* マジックナンバー領域を変更する */
		stk[0] = (uint8)~(stk[0]);
	}
	else {
		/*
		 * スタックポインタを先頭へずらす
		 * SPを残量ギリギリにずらす
		 */
		stk += intinib_table[info->stk_isrid].remain_stksz;
		AKTSP_SHIFT_SP;
	}

	/* 割込み発生時にスタックオーバーフロー検出 */
	AktspRaiseInterrupt(info->stk_intno);

	/* 割込みが即座に発生しない場合に備えビジーウェイト */
	AktspBusyWait();
#endif /* CFG_USE_STACKMONITORING */
}

#ifdef TotalNumberOfCores
/*
 *  スタックオーバーフロー発生
 *  (自コアに対するコア間割込み発生時)
 */
void
AktspRaiseTaskStackOverflowByIcIsr(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info)
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

	/* コア間割込み発生時にスタックオーバーフロー検出 */
	RaiseInterCoreInterrupt(info->stk_isrid);

	/* コア間割込みが即座に発生しない場合に備えビジーウェイト */
	AktspBusyWait();
}

/*
 *  スタックオーバーフロー発生
 *  (自コアに対するコア間割込みが多重割込みで発生時)
 */
void
AktspRaiseIsrStackOverflowByIcIsr(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info)
{
#ifdef CFG_USE_STACKMONITORING
	MemorySizeType	over_stkaddr;
	CoreIdType		coreid = x_core_id();
	/* 検出方式によってスタックオーバーフロー発生処理を変える */
	if (info->stk_mode == AK_SMM_MAGIC_NUMBER) {
		/* マジックナンバー領域を変更する */
		stk[0] = (uint8)~(stk[0]);
	}
	else {
		/*
		 * スタック残量チェック方式
		 * SPを残量ギリギリにずらす
		 */
		stk += ici_remain_stksz[coreid];
		AKTSP_SHIFT_SP;
	}

	/* コア間割込み発生時にスタックオーバーフロー検出 */
	RaiseInterCoreInterrupt(info->stk_isrid);

	/* コア間割込みが即座に発生しない場合に備えビジーウェイト */
	AktspBusyWait();
#endif /* CFG_USE_STACKMONITORING */
}
#endif /* TotalNumberOfCores */


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
 *  SC3-MCのスタックモニタリングテストで使用する
 */
/*
 *  マジックナンバー方式で，スタックオーバーフローが検出される
 *  状態にする処理(引数にスタックの先頭番地，サイズを与える)
 */
void
AKTSP_SET_STACK_OVERFLOW_M(uint8 *stk, MemorySizeType sz)
{
	stk[0] = (uint8)~(stk[0]);
}

/*
 *  CPU例外発生
 */
void
AktspRaiseCPUException(void)
{
#ifdef CFG_USE_SCALABILITYCLASS3
	asm("FETRAP 0xf");
#elif defined(AKTSP_RAISE_CPU_EXCEPTION_BY_FETRAP)
	_aktsp_raise_fetrap();
#else
	/* リザーブ領域アクセス通知クリア */
	sil_reh_mem((void *)SEG_FLAG);
	sil_wrh_mem((void *)SEG_FLAG, 0x0000);

#ifdef __v850e2v3__
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
#elif defined(__v850e3v5__)
	/* プライマリ／セカンダリローカル RAM 領域エラー通知イネーブル */
	sil_wrh_mem((void *)SEG_CONT, 0x0010);
	/* プライマリ／セカンダリローカル RAM 領域エラー通知 */
	sil_wrh_mem((void *)SEG_FLAG, 0x0010);
#else  /* __v850e3v5__ */
#error please define ether __v850e2v3__ or __v850e3v5__
#endif /* __v850e2v3__ */
#endif /* CFG_USE_SCALABILITYCLASS3 */
}

#ifdef AKTSP_PERFORMANCE_TEST
#include "t_syslog.h"
#include "histogram.h"
#endif /* AKTSP_PERFORMANCE_TEST */
/*
 *  実行時間分布計測の初期化(trap命令)
 */
boolean
AktspInitHist(uint32 histid, uint32 maxval, uint32 *histarea)
{
#ifdef AKTSP_PERFORMANCE_TEST
	return init_hist((ObjectIDType)histid, maxval, histarea);
#else
	return FALSE;
#endif /* AKTSP_PERFORMANCE_TEST */
}

/*
 *  実行時間計測の開始(trap命令)
 */
boolean
AktspBeginMeasure(uint32 histid)
{
#ifdef AKTSP_PERFORMANCE_TEST
	return begin_measure((ObjectIDType)histid);
#else
	return FALSE;
#endif /* AKTSP_PERFORMANCE_TEST */
}

/*
 *  実行時間計測の終了(trap命令)
 */
boolean
AktspEndMeasure(uint32 histid)
{
#ifdef AKTSP_PERFORMANCE_TEST
	return end_measure((ObjectIDType)histid);
#else
	return FALSE;
#endif /* AKTSP_PERFORMANCE_TEST */
}

/*
 *  実行時間分布計測の表示(trap命令)
 */
boolean
AktspPrintHist(uint32 histid)
{
#ifdef AKTSP_PERFORMANCE_TEST
	return print_hist((ObjectIDType)histid);
#else
	return FALSE;
#endif /* AKTSP_PERFORMANCE_TEST */
}

#ifdef TotalNumberOfCores
void 
AktspTargetInfiniteLoop(void)
{
	barrier_sync(10U, FALSE);
    AktspInfiniteLoop();
}
#endif /*TotalNumberOfCores*/


