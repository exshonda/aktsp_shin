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
 *  $Id: aktsp_common_lib.c 2054 2015-09-01 05:01:58Z aisincom-nishioka $
 */

/*
 *  共通テストライブラリ
 */

#include "aktsp_common_lib.h"
#include "aktsp_target_lib.h"

/*
 *  チェックポイント
 */
#ifndef TotalNumberOfCores
static volatile uint32 check_count;
#else
static volatile uint32 check_count_mc[TotalNumberOfCores];
#endif /* TotalNumberOfCores */

/*
 *  チェックポイント通過の状態(AK_TRUE:正常，AK_FALSE:異常)
 */
volatile uint8	cp_state;

/*
 *  バリア同期用変数
 */
#ifdef TotalNumberOfCores
static volatile uint32 local_phase[TotalNumberOfCores];
static volatile uint32 global_phase;
static volatile boolean reentrant_check[TotalNumberOfCores];
#endif /* TotalNumberOfCores */

/*
 *  テストライブラリ初期化(共通部)
 */
void
AktspInitializeTestLib(void)
{
#ifndef TotalNumberOfCores
	check_count = 0U;
#else
	uint16 i;

	for (i = 0; i < TotalNumberOfCores; i++) {
		check_count_mc[i] = 0U;
		local_phase[i] = 0U;
		reentrant_check[i] = AK_FALSE;
	}
	global_phase = 0U;
#endif /* TotalNumberOfCores */

	cp_state = AK_TRUE;

	AktspInitializeImplementTestLib();
}

#ifdef TotalNumberOfCores
/*
 *  各コアで実行するテストライブラリ初期化(共通部)
 */
void
AktspInitializeTestLibEachCore(void)
{
	AktspInitializeImplementTestLibEachCore();
}
#endif /* TotalNumberOfCores */


#ifndef TotalNumberOfCores

/*
 *  チェックポイント(シングルコア用)
 */
void
AktspCheckPoint(uint32 count)
{
	uint8	errorflag = AK_FALSE;
	boolean	locked;

	/*
	 *  全割込み禁止状態でない場合，
	 *  SuspendAllInterruptsによる割込み禁止状態にする
	 */
	locked = AktspDisInt();

	/*  シーケンスチェック */
	check_count++;
	if (check_count == count) {
		AktspOutputLog_1("Check point %d passed.", count);
	}
	else {
		AktspOutputLog_1("## Unexpected check point %d.", count);
		errorflag = AK_TRUE;
	}

	/* 割込み禁止状態を解除 */
	AktspEnaInt(locked);

	if (errorflag == AK_TRUE) {
		cp_state = AK_FALSE;
		AktspShutdownOS();
	}
}

/*
 *  チェックポイントがcountになるのを待つ(シングルコア用)
 */
void
AktspWaitCheckPoint(uint32 count)
{
	uint32 timeout = 0U;

	while (check_count < count) {
		/*
		 * タイムアウト処理
		 */
		timeout++;
		if (timeout > AKTSP_LOOP_COUNT) {
			AktspOutputLog_1("## AktspWaitCheckPoint(%d) caused a timeout.", count);
			cp_state = AK_FALSE;
			AktspShutdownOS();
			break;
		}
		AktspBusyWait();
	}
}

/*
 *  完了チェックポイント(シングルコア用)
 */
void
AktspCheckFinish(uint32 count)
{
	AktspCheckPoint(count);
	if (cp_state == AK_TRUE) {
		AktspOutputLog_0("All check points passed.");
	}
	AktspShutdownOS();
}

#else
/*
 *  チェックポイント(マルチコア用)
 */
void
AktspMcCheckPoint(CoreIdType id, uint32 count)
{
	uint8		errorflag = AK_FALSE;
	boolean		locked;
	CoreIdType	coreid;

	/*
	 *  全割込み禁止状態でない場合，
	 *  SuspendAllInterruptsによる割込み禁止状態にする
	 */
	locked = AktspDisInt();

	/* コアID取得 */
	coreid = GetCoreID();

	/*
	 * 引数で指定したコアIDと異なる場合
	 */
	if (coreid != id) {
		AktspOutputLog_2("## Core %d : Wrong CoreID is specified [%d]", coreid, id);
		AktspOutputLog_2("## in \"AktspMcCheckPoint(%d, %d)\".", id, count);
		errorflag = AK_TRUE;
	}
	else {
		/*
		 *  シーケンスチェック
		 */
		check_count_mc[coreid]++;
		if (check_count_mc[coreid] == count) {
			AktspOutputLog_2("Core %d : Check point %d passed.", coreid, count);
		}
		else {
			AktspOutputLog_2("## Core %d : Unexpected Check Point : %d", coreid, count);
			AktspOutputLog_2("## in \"AktspMcCheckPoint(%d, %d)\".", id, count);
			errorflag = AK_TRUE;
		}
	}

	/* 割込み禁止状態を解除 */
	AktspEnaInt(locked);

	if (errorflag == AK_TRUE) {
		cp_state = AK_FALSE;
		AktspShutdownOS();
	}
}

/*
 *  チェックポイントがcountになるのを待つ(マルチコア用)
 */
void
AktspMcWaitCheckPoint(CoreIdType id, uint32 count)
{
	uint32 timeout = 0U;

	while (check_count_mc[id] < count) {
		/*
		 * タイムアウト処理
		 */
		timeout++;
		if (timeout > AKTSP_LOOP_COUNT) {
			AktspOutputLog_2("## AktspMcWaitCheckPoint(%d, %d) caused a timeout.", id, count);
			cp_state = AK_FALSE;
			AktspShutdownOS();
			break;
		}
		AktspBusyWait();
	}
}

/*
 *  完了チェックポイント(マルチコア用)
 */
void
AktspMcCheckFinish(CoreIdType id, uint32 count)
{
	AktspMcCheckPoint(id, count);
	if (cp_state == AK_TRUE) {
		AktspOutputLog_1("Core %d : All check points passed.", id);
	}
	AktspShutdownOS();
}

#endif /* TotalNumberOfCores */

/*
 *  無限ループ関数
 */
void AktspInfiniteLoop(void)
{
	while (1) {
	}
}

/*
 *  チェックポイント通過状態の取得
 */
uint8
AktspGetCpState(void)
{
	return cp_state;
}

/*
 *  チェックポイント通過状態の更新
 */
void
AktspSetCpState(uint8 state)
{
	cp_state = state;
}


#ifdef TotalNumberOfCores
/*
 *  バリア同期(マルチコア用)
 */
void
AktspBarrierSync(uint32 phase, uint16 core_num)
{
	boolean		errorflag = AK_FALSE;
	boolean		locked;
	volatile	uint32 i;
	volatile	uint32 flag;
	CoreIdType	coreid;
	uint32		timeout = 0U;

	/*
	 *  全割込み禁止状態でない場合，
	 *  SuspendAllInterruptsによる割込み禁止状態にする
	 */
	locked = AktspDisInt();

	/* コアID取得 */
	coreid = GetCoreID();

	/*
	 * リエントラントされた場合はエラー終了する
	 */
	if (reentrant_check[coreid]) {
		AktspOutputLog_1("## Core %d : AktspBarrierSync has re-entranted", coreid);
		AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
		errorflag = AK_TRUE;
		goto error_exit;
	}
	reentrant_check[coreid] = AK_TRUE;

	local_phase[coreid] = phase;

	/* 割込み禁止状態を解除 */
	AktspEnaInt(locked);

	/*
	 *  バリア同期処理
	 */
	if (coreid == OS_CORE_ID_MASTER) {
		while (1) {
			flag = 0;
			for (i = 0; i < TotalNumberOfCores; i++) {
				if (local_phase[i] == phase) {
					flag++;
				}
			}

			/*
			 * バリア同期完了チェック
			 * (チェックから終了処理まではディスパッチしないよう割込みロック状態とする)
			 */
			locked = AktspDisInt();
			if (flag == core_num) {
				reentrant_check[coreid] = AK_FALSE;
				global_phase = phase;
				/*
				 * 全コアのバリア同期処理が完了することを待つ
				 * (既に次のphaseの場合は待つ必要はない)
				 */
				for (i = 0; i < TotalNumberOfCores; i++) {
					timeout = 0;
					while ((reentrant_check[i] == AK_TRUE) && (local_phase[i] == phase)) {
						timeout++;
						if (timeout > AKTSP_LOOP_COUNT) {
							AktspOutputLog_3("## Core %d : AktspBarrierSync(phase:%d) caused a timeout to wait for Core %d", coreid, phase, i + 1);
							AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
							errorflag = AK_TRUE;
							goto error_exit;
						}
						AktspBusyWait();
					}
				}
				AktspOutputLog_2("Core %d : Barrier sync phase %d synchronized.", coreid, phase);
				AktspEnaInt(locked);
				return;
			}
			AktspEnaInt(locked);

			/*
			 * タイムアウト処理
			 */
			timeout++;
			if (timeout > AKTSP_LOOP_COUNT) {
				AktspOutputLog_2("## Core %d : AktspBarrierSync(phase:%d) caused a timeout", coreid, phase);
				AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
				errorflag = AK_TRUE;
				goto error_exit;
			}
			AktspBusyWait();
		}
	}
	else {
		while (1) {
			/*
			 * バリア同期完了チェック
			 * チェックから終了処理まではディスパッチしないよう割込みロック状態とする
			 */
			locked = AktspDisInt();
			if (global_phase == phase) {
				reentrant_check[coreid] = AK_FALSE;
				/*
				 * 全コアのバリア同期処理が完了することを待つ
				 * (既に次のphaseの場合は待つ必要はない)
				 */
				for (i = 0; i < TotalNumberOfCores; i++) {
					timeout = 0;
					while ((reentrant_check[i] == AK_TRUE) && (local_phase[i] == phase)) {
						timeout++;
						if (timeout > AKTSP_LOOP_COUNT) {
							AktspOutputLog_3("## Core %d : AktspBarrierSync(phase:%d) caused a timeout to wait for Core %d", coreid, phase, i + 1);
							AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
							errorflag = AK_TRUE;
							goto error_exit;
						}
						AktspBusyWait();
					}
				}
				AktspOutputLog_2("Core %d : Barrier sync phase %d synchronized.", coreid, phase);
				AktspEnaInt(locked);
				return;
			}
			AktspEnaInt(locked);

			/*
			 * タイムアウト処理
			 */
			timeout++;
			if (timeout > AKTSP_LOOP_COUNT) {
				AktspOutputLog_2("## Core %d : AktspBarrierSync(phase:%d) caused a timeout", coreid, phase);
				AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
				errorflag = AK_TRUE;
				goto error_exit;
			}
			AktspBusyWait();
		}
	}

  error_exit:
	if (errorflag) {
		cp_state = AK_FALSE;
		AktspShutdownOS();
	}

	/*
	 *  正常な処理では通らないパスのため異常終了
	 */
	AktspOutputLog_2("## Core %d : AktspBarrierSync(phase:%d) occurred an unexpected error.", coreid, phase);
	AktspOutputLog_2("## in \"AktspBarrierSync(%d, %d)\".", phase, core_num);
	cp_state = AK_FALSE;
	AktspShutdownOS();
}

/*
 *  対象タスクの状態が指定した状態へ変化するのを待つ(マルチコア用)
 */ 
void
AktspStateSync(TaskType target_tskid, TaskStateType target_state)
{
	TaskStateType	cur_state;
	uint32			timeout = 0;
	CoreIdType		coreid = GetCoreID();

	do {
		cur_state = AktspGetTaskState(target_tskid);
		timeout++;
		if (timeout > AKTSP_LOOP_COUNT) {
			AktspOutputLog_1("## Core %d : AktspStateSync() caused a timeout.", coreid);
			AktspOutputLog_2("## (TaskID: %d, State: %d)", target_tskid, target_state);
			cp_state = AK_FALSE;
			AktspShutdownOS();
		}
		AktspBusyWait();
	} while (cur_state != target_state);
}

#endif /* TotalNumberOfCores */

/*
 *  シャットダウン処理(SC毎の分岐用)
 */
void
AktspShutdownOS(void)
{
#ifdef CFG_USE_SCALABILITYCLASS3
	AktspTrustShutdownOS(E_OK);
	/* 信頼関数が使用できない処理単位に備えてShutdownOSも呼ぶ */
#endif /* CFG_USE_SCALABILITYCLASS3 */

	AKTSP_SHUTDOWN_OS(E_OK);
}

/*
 *  ビジーウェイト関数
 */
void
AktspBusyWait(void)
{
	volatile uint32 i;

	for (i = 0U; i < AKTSP_BUSY_LOOP; i++) {
	}
}

/*
 * 割込み禁止状態
 */
boolean
AktspDisInt(void)
{
	boolean locked = AK_FALSE;

	/*
	 * DisableAllInterrputによる割込み禁止でなければ，
	 * ネスト可能なSuspendAllInterruptsで割込み禁止とする
	 */
	if (AktspGetDisableAllInterruptsState() == AK_OFF) {
		DisableAllInterrupts();
		locked = AK_TRUE;
	}
	return(locked);
}

/*
 * 割込み禁止状態解除
 */
void
AktspEnaInt(boolean locked)
{
	if (locked) {
		EnableAllInterrupts();
	}
}

/*
 *  タスク情報作成
 */
void
AktspMakeTaskInfo(AktspTaskRefInfo vtsk, TaskStateType tstat, sint32 curpri, sint32 inipri, uint8 ttype,
				  uint32 maxact, uint8 spolicy, EventMaskType waievt, EventMaskType curevt,
				  uint32 actcnt, uint32 porder, uint32 getrescount, ApplicationType osap,
				  MemorySizeType tstksz, MemoryStartAddressType tstk, MemorySizeType sstksz,
				  MemoryStartAddressType sstk)
{
	vtsk->tm_tstat = tstat;
	vtsk->tm_curpri = curpri;
	vtsk->tm_inipri = inipri;
	vtsk->tm_ttype = ttype;
	vtsk->tm_maxact = maxact;
	vtsk->tm_spolicy = spolicy;
	vtsk->tm_waievt = waievt;
	vtsk->tm_curevt = curevt;
	vtsk->tm_actcnt = actcnt;
	vtsk->tm_porder = porder;
	vtsk->tm_getrescount = getrescount;
	vtsk->tm_osap = osap;
	vtsk->tm_stksz = tstksz;
	vtsk->tm_stk = tstk;
	vtsk->tm_sstksz = sstksz;
	vtsk->tm_sstk = sstk;
}

/*
 *  リソース情報作成
 */
void
AktspMakeResourceInfo(AktspResourceRefInfo vres, uint8 resprop, ResourceType linkres, uint8 lockflg)
{
	vres->rm_resprop = resprop;
	vres->rm_linkres = linkres;
	vres->rm_lockflg = lockflg;
}

/*
 *  ISR情報作成
 */
void
AktspMakeISRInfo(AktspISRRefInfo visr, uint32 intno, uint32 intatr, sint32 iniintpri, sint32 curintpri, uint8 istat,
				 uint8 rtnstat, uint32 getrescount, ApplicationType osap, MemorySizeType istksz)
{
	visr->im_intno = intno;
	visr->im_intatr = intatr;
	visr->im_iniintpri = iniintpri;
	visr->im_curintpri = curintpri;
	visr->im_istat = istat;
	visr->im_rtnstat = rtnstat;
	visr->im_getrescount = getrescount;
	visr->im_osap = osap;
	visr->im_istksz = istksz;
}

/*
 *  割込み禁止状態情報作成
 */
void
AktspMakeIntStateInfo(AktspIntStateRefInfo vint, uint8 disallint, uint8 susallint, uint8 susosint,
					  uint8 susallcnt, uint8 susoscnt)
{
	vint->ism_disallint = disallint;
	vint->ism_susallint = susallint;
	vint->ism_susosint = susosint;
	vint->ism_susallcnt = susallcnt;
	vint->ism_susoscnt = susoscnt;
}

/*
 *  カウンタ情報作成
 */
void
AktspMakeCounterInfo(AktspCounterRefInfo vcnt, TickType mincyc, TickType maxval, TickType curval, uint8 ctype,
					 TickType ticksperbase, float32 secondspertick, uint8 cstat, ApplicationType osap)
{
	vcnt->cm_mincyc = mincyc;
	vcnt->cm_maxval = maxval;
	vcnt->cm_curval = curval;
	vcnt->cm_ctype = ctype;
	vcnt->cm_ticksperbase = ticksperbase;
	vcnt->cm_secondspertick = secondspertick;
	vcnt->cm_cstat = cstat;
	vcnt->cm_osap = osap;
}

/*
 *  アラーム情報作成
 */
void
AktspMakeAlarmInfo(AktspAlarmRefInfo valm, uint8 almact, CounterType counter, TickType almval, TickType cycle,
				   uint8 astat, TaskType task, EventMaskType event, CounterType incounter,
				   void (*callback)(void), ApplicationType osap, uint8 autostarttype)
{
	valm->am_almact = almact;
	valm->am_counter = counter;
	valm->am_almval = almval;
	valm->am_cycle = cycle;
	valm->am_astat = astat;
	valm->am_task = task;
	valm->am_event = event;
	valm->am_incounter = incounter;
	valm->am_callback = callback;
	valm->am_osap = osap;
	valm->am_autostarttype = autostarttype;
}

/*
 *  スケジュールテーブル情報作成
 */
void
AktspMakeScheduleTableInfo(AktspScheduleTableRefInfo vschtbl, CounterType counter, uint8 repeat, ScheduleTableStatusType ststat,
						   TickType duration, uint8 syncstrategy, TickType curval, ScheduleTableType stfrom,
						   ApplicationType osap, TickType starttick, uint8 autostarttype)
{
	vschtbl->sm_counter = counter;
	vschtbl->sm_repeat = repeat;
	vschtbl->sm_ststat = ststat;
	vschtbl->sm_duration = duration;
	vschtbl->sm_syncstrategy = syncstrategy;
	vschtbl->sm_curval = curval;
	vschtbl->sm_stfrom = stfrom;
	vschtbl->sm_osap = osap;
	vschtbl->sm_starttick = starttick;
	vschtbl->sm_autostarttype = autostarttype;
}

/*
 *  スケジュールテーブル満了アクション情報作成
 */
void
AktspMakeScheduleTableExactionInfo(AktspScheduleTableExactionRefInfo vschtblexact, TickType offset,
								   uint8 expprop, TaskType task, EventMaskType event)
{
	vschtblexact->sem_offset = offset;
	vschtblexact->sem_expprop = expprop;
	vschtblexact->sem_task = task;
	vschtblexact->sem_event = event;
}

/*
 *  スピンロック情報作成
 */
void
AktspMakeSpinlockInfo(AktspSpinlockRefInfo vspn, uint8 susint, SpinlockIdType successor, uint8 lockflg)
{
	vspn->sl_susint = susint;
	vspn->sl_successor = successor;
	vspn->sl_lockflg = lockflg;
}

/*
 *  信頼関数
 */
void
AktspMakeTrustedFunctionInfo(AktspTrustedFunctionRefInfo vtfn, ApplicationType osap, uint32 stksz)
{
	vtfn->tfm_osap = osap;
	vtfn->tfm_stksz = stksz;
}

/*
 * IOC情報作成
 */
void
AktspMakeIocInfo(AktspIocRefInfo vioc, uint32 maxque, uint32 quecnt, boolean lostflg, ApplicationType rcvosapid)
{
	vioc->ioc_maxque = maxque;
	vioc->ioc_quecnt = quecnt;
	vioc->ioc_lostflg = lostflg;
	vioc->ioc_rcvosapid = rcvosapid;
}

/*
 *  ICISR情報作成
 */
void
AktspMakeIcISRInfo(AktspIcISRRefInfo vicisr, uint32 intatr, uint8 istat, uint8 rtnstat, uint32 getrescount, ApplicationType osap, MemorySizeType istksz)
{
	vicisr->icm_intatr = intatr;
	vicisr->icm_istat = istat;
	vicisr->icm_rtnstat = rtnstat;
	vicisr->icm_getrescount = getrescount;
	vicisr->icm_osap = osap;
	vicisr->icm_istksz = istksz;
}

/*
 *  終了/再起動中のOSAPに所属するタスクの確認
 */
StatusType
AktspCheckTaskTerminated(TaskType TaskID, uint8 taskflg)
{
	StatusType ercd;
	TaskStateType state;
	EventMaskType mask;

	ercd = ActivateTask(TaskID);
	CheckErcd(ercd, E_OS_ACCESS);

	/* 呼出し元がタスク以外の場合は実施しない */
	if (taskflg == AK_TRUE) {
		ercd = ChainTask(TaskID);
		CheckErcd(ercd, E_OS_ACCESS);
	}

	ercd = GetTaskState(TaskID, &state);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = SetEvent(TaskID, mask);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = GetEvent(TaskID, &mask);
	CheckErcd(ercd, E_OS_ACCESS);

	return ercd;
}

/*
 *  終了/再起動中のOSAPに所属するアラームの確認
 */
StatusType
AktspCheckAlarmTerminated(AlarmType AlarmID)
{
	StatusType ercd;
	TickType   tick = 1;
	TickType   cycle = 3;
	AlarmBaseType info;

	ercd = GetAlarm(AlarmID, &tick);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = GetAlarmBase(AlarmID, &info);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = SetRelAlarm(AlarmID, tick, cycle);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = SetAbsAlarm(AlarmID, tick, cycle);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = CancelAlarm(AlarmID);
	CheckErcd(ercd, E_OS_ACCESS);

	return ercd;
}

/*
 *  終了/再起動中のOSAPに所属するスケジュールテーブルの確認
 */
StatusType
AktspCheckScheduleTableTerminated(ScheduleTableType ScheduleTableID_From, ScheduleTableType ScheduleTableID_To, uint8 implicit)
{
	StatusType ercd;
	TickType   tick = 1;
	TickType   start = 1;

	/* スケジュールテーブルが暗黙同期スケジュールテーブルの場合は確認しない */
	if (implicit == AK_FALSE) {
		ercd = StartScheduleTableRel(ScheduleTableID_From, tick);
		CheckErcd(ercd, E_OS_ACCESS);
	}

	ercd = StartScheduleTableAbs(ScheduleTableID_From, start);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = StopScheduleTable(ScheduleTableID_From);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = NextScheduleTable(ScheduleTableID_From, ScheduleTableID_To);
	CheckErcd(ercd, E_OS_ACCESS);

	return ercd;
}

/*
 *  終了/再起動中のOSAPに所属するカウンタの確認
 */
StatusType
AktspCheckCounterTerminated(CounterType CounterID)
{
	StatusType ercd;
	TickType   value = 1;
	TickType   evalue;

	ercd = IncrementCounter(CounterID);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = GetCounterValue(CounterID, &value);
	CheckErcd(ercd, E_OS_ACCESS);

	ercd = GetElapsedValue(CounterID, &value, &evalue);
	CheckErcd(ercd, E_OS_ACCESS);

	return ercd;
}
