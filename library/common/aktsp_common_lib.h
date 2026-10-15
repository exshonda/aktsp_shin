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
 *  $Id: aktsp_common_lib.h 2036 2015-08-19 03:44:45Z aisincom-nishioka $
 */

#ifndef TOPPERS_AKTSP_COMMON_LIB_H
#define TOPPERS_AKTSP_COMMON_LIB_H

/********************************************************************

  共通テストライブラリ

 ********************************************************************/

#include "Os.h"
#include "aktsp_implement_lib.h"

/*
 *  真偽値
 */
#define AK_TRUE		1U   /* 真 */
#define AK_FALSE	0U   /* 偽 */

/*
 *  タスク
 */
#define AK_BASIC				0U  /* 基本タスク */
#define AK_EXTENDED				1U  /* 拡張タスク */
#define AK_SCHFULL				0U  /* フルプリエンプティブスケジューリング */
#define AK_SCHNON				1U  /* ノンプリエンプティブスケジューリング */
#define AK_AUTO_START			4U  /* 自動起動時用の状態(自動実行あり) */
#define AK_NO_AUTO_START		5U  /* 自動起動時用の状態(自動実行なし) */
#define AK_END_SUSPENDED		6U  /* シャットダウン後の状態(休止状態) */
#define AK_END_RUNNING			7U  /* シャットダウン後の状態(実行状態) */
#define AK_END_READY			8U  /* シャットダウン後の状態(実行可能状態) */
#define AK_END_WAITING			9U  /* シャットダウン後の状態(待ち状態) */
#define AK_END_OSAP_SUSPENDED	10U /* OSAP終了/再起動中の状態(休止状態) */
#define AK_END_OSAP_RUNNING		11U /* OSAP終了/再起動中の状態(実行状態) */
#define AK_END_OSAP_READY		12U /* OSAP終了/再起動中の状態(実行可能状態) */
#define AK_END_OSAP_WAITING		13U /* OSAP終了/再起動中の状態(待ち状態) */

/*
 *  リソース
 */
#define AK_UNLOCK		0U  /* 未獲得 */
#define AK_LOCK			1U  /* 獲得中 */
#define AK_INTERCORE	0U  /* コア間リソース */
#define AK_STANDARD		1U  /* 標準リソース */
#define AK_INTERNAL		2U  /* 内部リソース */
#define AK_LINKED		3U  /* リンクリソース */

/*
 *  ISR
 */
#define AK_ENABLE	0U  /* 許可状態 */
#define AK_DISABLE	1U  /* 禁止状態 */
#define AK_ACTIVATE	0U  /* 実行状態 */
#define AK_STOP		1U  /* 停止状態 */

/*
 *  割込み禁止状態
 */
#define AK_DIS_ALL_INT	0U  /* DisableAllInterruptsによる割込み禁止状態 */
#define AK_SUS_ALL_INT	1U  /* SuspendAllInterruptsによる割込み禁止状態 */
#define AK_SUS_OS_INT	2U  /* SuspendOSInterruptsによる割込み禁止状態 */

/*
 *  フック
 */
#define AK_STARTUP	0U  /* スタートアップフック */
#define AK_SHUTDOWN	1U  /* シャットダウンフック */
#define AK_PRETASK	2U  /* プレタスクフック */
#define AK_POSTTASK	3U  /* ポストタスクフック */
#define AK_ERROR	4U  /* エラーフック */
#define AK_PROTECT	5U  /* プロテクションフック */

/*
 *  カウンタ
 */
#define AK_HARDWARE	0U  /* ハードウェアカウンタ */
#define AK_SOFTWARE	1U  /* ソフトウェアカウンタ */
#define AK_CS_NULL	0U  /* 非操作中 */
#define AK_CS_DOING	1U  /* 操作中 */
#define AK_CS_ERROR	2U  /* 操作中かつエラーフックが起動中 */

/*
 *  アラーム
 */
#define AK_UNSET		0U  /* 未セット */
#define AK_SET			1U  /* セット済み */
#define AK_ALM_ATSK		0U  /* タスク起動 */
#define AK_ALM_SEVT		1U  /* イベントセット */
#define AK_ALM_CBACK	2U  /* コールバック */
#define AK_ALM_INCNT	3U  /* カウンタインクリメント */
#define AK_ABSOLUTE		0U  /* 絶対値起動 */
#define AK_RELATIVE		1U  /* 相対値起動 */

/*
 *  スケジュールテーブル
 */
#define AK_NONE		0U  /* 同期なしスケジュールテーブル */
#define AK_IMPLICIT	1U  /* 暗黙同期スケジュールテーブル */
#define AK_EXPLICIT	2U  /* 明示同期スケジュールテーブル */
#define AK_SYNCHRON	3U  /* 同期待ち起動 */

/*
 *  スケジュールテーブルの満了アクション
 */
#define AK_ST_ATSK	0U  /* タスクの起動 */
#define AK_ST_SEVT	1U  /* イベントのセット */

/*
 *  スピンロックによる割込み禁止状態
 */
#define AK_SUS_ALL_SPN	0U  /* スピンロック取得後，SuspendAllInterrupts実行状態となる */
#define AK_SUS_OS_SPN	1U  /* スピンロック取得後，SuspendOSInterrupts実行状態となる */
#define AK_DO_NOT_CARE	2U  /* スピンロック取得後，割込み禁止状態にならない */

/*
 *  全割込み禁止状態取得API
 */
#define AK_OFF	0U  /* 割込み禁止状態でない */
#define AK_ON	1U  /* 割込み禁止状態 */

/*
 *  メモリ保護テスト用対象スタック種別
 */
#define AK_NT_OSAP1_TASK1	0U  /* 非信頼OSAP1タスク1 */
#define AK_NT_OSAP1_TASK2	1U  /* 非信頼OSAP1タスク2 */
#define AK_NT_OSAP2_TASK1	2U  /* 非信頼OSAP2タスク1 */

/*
 *  構造体メンバー変数の無効値
 */
#define AKTSP_INVALID_VALUE8  0xFFU
#define AKTSP_INVALID_VALUE32 0xFFFFFFFFU
#define AKTSP_INVALID_SVALUE8 0x7F
#define AKTSP_INVALID_FVALUE  0.0
#define AKTSP_INVALID_ALMCB   ((void *) 0)

/* OSの終了(APIがシングルコアとマルチコアで異なるためマクロ化する) */
#ifdef TotalNumberOfCores
#define AKTSP_SHUTDOWN_OS(ercd) ShutdownAllCores(ercd)
#else
#define AKTSP_SHUTDOWN_OS(ercd) ShutdownOS(ercd)
#endif /* TotalNumberOfCores */

/* プレ/ポストタスクフックが起動しないことを確認するため変数 */
#ifdef TotalNumberOfCores
#define AKTSP_POSTTASKHOOK_NO_BOOT PostTaskHook_Core0_CheckNoBoot
#define AKTSP_PRETASKHOOK_NO_BOOT PreTaskHook_Core0_CheckNoBoot
#else
#define AKTSP_POSTTASKHOOK_NO_BOOT PostTaskHook_CheckNoBoot
#define AKTSP_PRETASKHOOK_NO_BOOT PreTaskHook_CheckNoBoot
#endif /* TotalNumberOfCores */

typedef struct aktsp_task_info {
	TaskStateType			tm_tstat;          /* タスク状態 */
	sint32					tm_curpri;         /* 現在優先度 */
	sint32					tm_inipri;         /* 初期優先度 */
	uint8					tm_ttype;          /* タスクの種別 */
	uint32					tm_maxact;         /* 多重起動要求の最大数 */
	uint8					tm_spolicy;        /* スケジューリングポリシ */
	EventMaskType			tm_waievt;         /* 待っているイベント */
	EventMaskType			tm_curevt;         /* イベントの現在値 */
	uint32					tm_actcnt;         /* 起動要求キューイング数 */
	uint32					tm_porder;         /* 同一優先度タスク内での優先順位 */
	uint32					tm_getrescount;    /* 取得済みリソース数(内部リソースを除く) */
	ApplicationType			tm_osap;           /* 所属するOSアプリケーション */
	MemorySizeType			tm_stksz;          /* スタック領域のサイズ */
	MemoryStartAddressType	tm_stk;            /* スタック領域の先頭番地 */
	MemorySizeType			tm_sstksz;         /* システムスタック領域のサイズ */
	MemoryStartAddressType	tm_sstk;           /* システムスタック領域の先頭番地 */
} AktspTaskInfo;
typedef AktspTaskInfo* AktspTaskRefInfo;

typedef struct aktsp_resource_info {
	uint8			rm_resprop;    /* リソースの種別 */
	ResourceType	rm_linkres;    /* リンクリソースのリンク先リソース */
	uint8			rm_lockflg;    /* リソースの状態 */
} AktspResourceInfo;
typedef AktspResourceInfo* AktspResourceRefInfo;

typedef struct aktsp_isr_info {
	uint32			im_intno;          /* 割込み番号 */
	uint32			im_intatr;         /* 割込み属性 */
	sint32			im_iniintpri;      /* 初期割込み優先度 */
	sint32			im_curintpri;      /* 現在割込み優先度 */
	uint8			im_istat;          /* 割込み要求禁止フラグ */
	uint8			im_rtnstat;        /* 処理単位動作状態 */
	uint32			im_getrescount;    /* 取得済みリソース数(内部リソースを除く) */
	ApplicationType	im_osap;           /* 所属するOSアプリケーション */
	MemorySizeType	im_istksz;         /* スタック領域のサイズ */
} AktspISRInfo;
typedef AktspISRInfo* AktspISRRefInfo;

typedef struct aktsp_intstate_info {
	uint8	ism_disallint;  /* DisableAllInterruptsによる割込み禁止状態 */
	uint8	ism_susallint;  /* SuspendAllInterruptsによる割込み禁止状態 */
	uint8	ism_susosint;   /* SuspendOSInterruptsによる割込み禁止状態 */
	uint8	ism_susallcnt;  /* SuspendAllInterruptsのネスト回数 */
	uint8	ism_susoscnt;   /* SuspendOSInterruptsのネスト回数 */
} AktspIntStateInfo;
typedef AktspIntStateInfo* AktspIntStateRefInfo;

typedef struct aktsp_counter_info {
	TickType		cm_mincyc;         /* 周期の最小値 */
	TickType		cm_maxval;         /* カウンタの最大値 */
	TickType		cm_curval;         /* カウンタの現在値 */
	uint8			cm_ctype;          /* カウンタのタイプ */
	TickType		cm_ticksperbase;   /* 1回で進むティック数 */
	float32			cm_secondspertick; /* 1ティック当たりの実時間(秒) */
	uint8			cm_cstat;          /* カウンタの状態 */
	ApplicationType	cm_osap;           /* 所属するOSアプリケーション */
} AktspCounterInfo;
typedef AktspCounterInfo* AktspCounterRefInfo;

typedef struct aktsp_alarm_info {
	uint8			am_almact;             /* アラーム満了時に実行させるアクション */
	CounterType		am_counter;            /* 接続するカウンタ */
	TickType		am_almval;             /* 満了するティックの絶対値 */
	TickType		am_cycle;              /* アラーム満了周期 */
	uint8			am_astat;              /* アラームの状態 */
	TaskType		am_task;               /* ActivateTask/SetEventを実行するタスク */
	EventMaskType	am_event;              /* SetEventで指定する対象イベント */
	CounterType		am_incounter;          /* IncrementCounterを実行するカウンタ */
	void (*am_callback)(void);             /* 実行するアラームコールバック */
	ApplicationType	am_osap;               /* 所属するOSアプリケーション */
	uint8			am_autostarttype;      /* 自動起動の属性 */
} AktspAlarmInfo;
typedef AktspAlarmInfo* AktspAlarmRefInfo;

typedef struct aktsp_scheduletable_info {
	CounterType				sm_counter;        /* 対象カウンタ名 */
	uint8					sm_repeat;         /* 繰り返し指定 */
	ScheduleTableStatusType	sm_ststat;         /* スケジュールテーブルの状態 */
	TickType				sm_duration;       /* スケジュールテーブル周期 */
	uint8					sm_syncstrategy;   /* 同期方法 */
	TickType				sm_curval;         /* スケジュールテーブルの現在時刻 */
	ScheduleTableType		sm_stfrom;         /* 切換え前スケジュールテーブルID */
	ApplicationType			sm_osap;           /* 所属するOSアプリケーション */
	TickType				sm_starttick;      /* 自動起動ティック値 */
	uint8					sm_autostarttype;  /* 自動起動の属性 */
} AktspScheduleTableInfo;
typedef AktspScheduleTableInfo* AktspScheduleTableRefInfo;

typedef struct aktsp_scheduletable_exaction_info {
	TickType		sem_offset;         /* オフセット値 */
	uint8			sem_expprop;        /* 満了アクション種別 */
	TaskType		sem_task;           /* 起動/イベントセットする対象タスク */
	EventMaskType	sem_event;          /* セットするイベント */
} AktspScheduleTableExactionInfo;
typedef AktspScheduleTableExactionInfo* AktspScheduleTableExactionRefInfo;

typedef struct aktsp_spinlock_info {
	uint8			sl_susint;       /* 割込み禁止状態 */
	SpinlockIdType	sl_successor;    /* 次に取得可能なスピンロック */
	uint8			sl_lockflg;      /* スピンロックの状態 */
} AktspSpinlockInfo;
typedef AktspSpinlockInfo* AktspSpinlockRefInfo;

typedef struct aktsp_trustedfunction_exaction_info {
	ApplicationType	tfm_osap;       /* 所属するOSアプリケーション */
	uint32			tfm_stksz;      /* 信頼関数で使用するスタックサイズ */
} AktspTrustedFunctionInfo;
typedef AktspTrustedFunctionInfo* AktspTrustedFunctionRefInfo;

typedef struct aktsp_stack_overflow_info {
	uint8				stk_mode;         /* スタックモニタリング方式種別 */
	uint8				stk_action;       /* スタックオーバーフロー検出アクション */
	TaskType			stk_task;         /* システムサービス発行対象タスク */
	EventMaskType		stk_event;        /* システムサービス発行対象イベント */
	ResourceType		stk_resource;     /* システムサービス発行対象リソース */
	InterruptNumberType	stk_intno;        /* 発生させるISRの割込み番号 */
	ISRType				stk_isrid;        /* 発生させるICISRのISRID */
} AktspStackOverflowInfo;
typedef AktspStackOverflowInfo* AktspStackOverflowRefInfo;

typedef struct aktsp_tf_param {
	TaskType		TaskID;	/* 信頼関数に渡すタスクID */
	EventMaskType	Mask;	/* 信頼関数に渡すイベントマスク */
	ISRType			ISRID;	/* 信頼関数に渡すISR ID */
	StatusType		Error;	/* 信頼関数の戻り値 */
} AktspTfParam;

typedef struct aktsp_ioc_info {
	uint32			ioc_maxque;     /* キューサイズ */
	uint32			ioc_quecnt;     /* 格納数 */
	boolean			ioc_lostflg;    /* キューフルエラーフラグ */
	ApplicationType	ioc_rcvosapid;  /* レシーバが所属するOSAPID*/
} AktspIocInfo;
typedef AktspIocInfo* AktspIocRefInfo;

typedef struct aktsp_icisr_info {
	uint32			icm_intatr;         /* 割込み属性 */
	uint8			icm_istat;          /* 割込み要求禁止フラグ */
	uint8			icm_rtnstat;        /* 処理単位動作状態 */
	uint32			icm_getrescount;    /* 取得済みリソース数(内部リソースを除く) */
	ApplicationType	icm_osap;           /* 所属するOSアプリケーション */
	MemorySizeType	icm_istksz;         /* スタック領域のサイズ */
} AktspIcISRInfo;
typedef AktspIcISRInfo* AktspIcISRRefInfo;

/*
 * スタックオーバーフローを検知するスタックモニタリング方式
 */
enum AK_ENUM_STACK_MONITERING_MODE {
	AK_SMM_MAGIC_NUMBER,
	AK_SMM_STACK_POINTER,
	AK_SMM_CHECK_REMAIN
};

/*
 * スタックオーバーフローを検知するシステムサービス
 */
enum AK_ENUM_STACK_OVERFLOW_ACTION {
	AK_SOA_ACTIVATE_TASK,
	AK_SOA_TERMINATE_TASK,
	AK_SOA_CHAIN_TASK,
	AK_SOA_SCHEDULE,
	AK_SOA_SET_EVENT,
	AK_SOA_WAIT_EVENT,
	AK_SOA_RELEASE_RESOURCE
};


/*
 *  テストライブラリ初期化(共通部)
 */
extern void AktspInitializeTestLib(void);

/*
 *  各コアで実行するテストライブラリ初期化(共通部)
 */
extern void AktspInitializeTestLibEachCore(void);

/*
 *  チェックポイント(シングルコア用)
 */
extern void AktspCheckPoint(uint32 count);

/*
 *  チェックポイントがcountになるのを待つ(シングルコア用)
 */
extern void AktspWaitCheckPoint(uint32 count);

/*
 *  完了チェックポイント(シングルコア用)
 */
extern void AktspCheckFinish(uint32 count);

/*
 *  チェックポイント(マルチコア用)
 */
extern void AktspMcCheckPoint(CoreIdType id, uint32 count);

/*
 *  チェックポイントがcountになるのを待つ(マルチコア用)
 */
extern void AktspMcWaitCheckPoint(CoreIdType id, uint32 count);

/*
 *  完了チェックポイント(マルチコア用)
 */
extern void AktspMcCheckFinish(CoreIdType id, uint32 count);

/*
 *  チェックポイント通過の状態(AK_TRUE:正常，AK_FALSE:異常)
 */
extern volatile uint8 cp_state;

/*
 *  チェックポイント通過状態の取得
 */
extern uint8 AktspGetCpState(void);

/*
 *  チェックポイント通過状態の更新
 */
extern void AktspSetCpState(uint8 state);

/*
 *  バリア同期(マルチコア用)
 */
extern void AktspBarrierSync(uint32 phase, uint16 core_num);

/*
 *  対象タスクの状態が指定した状態へ変化するのを待つ(マルチコア用)
 */ 
extern void AktspStateSync(TaskType target_tskid, TaskStateType target_state);

/*
 *  シャットダウン処理(SC毎の分岐用)
 */
extern void AktspShutdownOS(void);

/*
 *  ビジーウェイト関数
 */
extern void AktspBusyWait(void);

/*
 *  無限ループ関数
 */
extern void AktspInfiniteLoop(void);

/*
 *  タスク情報作成
 */
extern void
AktspMakeTaskInfo(AktspTaskRefInfo vtsk, TaskStateType tstat, sint32 curpri, sint32 inipri, uint8 ttype,
				  uint32 maxact, uint8 spolicy, EventMaskType waievt, EventMaskType curevt,
				  uint32 actcnt, uint32 porder, uint32 getrescount, ApplicationType osap,
				  MemorySizeType tstksz, MemoryStartAddressType tstk, MemorySizeType sstksz,
				  MemoryStartAddressType sstk);

/*
 *  リソース情報作成
 */
extern void
AktspMakeResourceInfo(AktspResourceRefInfo vres, uint8 resprop, ResourceType linkres, uint8 lockflg);

/*
 *  ISR情報作成
 */
extern void
AktspMakeISRInfo(AktspISRRefInfo visr, uint32 intno, uint32 intatr, sint32 iniintpri, sint32 curintpri, uint8 istat,
				 uint8 rtnstat, uint32 getrescount, ApplicationType osap, MemorySizeType istksz);

/*
 *  割込み禁止状態情報作成
 */
extern void
AktspMakeIntStateInfo(AktspIntStateRefInfo vint, uint8 disallint, uint8 susallint, uint8 susosint,
					  uint8 susallcnt, uint8 susoscnt);

/*
 *  カウンタ情報作成
 */
extern void
AktspMakeCounterInfo(AktspCounterRefInfo vcnt, TickType mincyc, TickType maxval, TickType curval, uint8 ctype,
					 TickType ticksperbase, float32 secondspertick, uint8 cstat, ApplicationType osap);

/*
 *  アラーム情報作成
 */
extern void
AktspMakeAlarmInfo(AktspAlarmRefInfo valm, uint8 almact, CounterType counter, TickType almval, TickType cycle,
				   uint8 astat, TaskType task, EventMaskType event, CounterType incounter,
				   void (*callback)(void), ApplicationType osap, uint8 autostarttype);

/*
 *  スケジュールテーブル情報作成
 */
extern void
AktspMakeScheduleTableInfo(AktspScheduleTableRefInfo vschtbl, CounterType counter, uint8 repeat, ScheduleTableStatusType ststat,
						   TickType duration, uint8 syncstrategy, TickType curval, ScheduleTableType stfrom,
						   ApplicationType osap, TickType starttick, uint8 autostarttype);

/*
 *  スケジュールテーブル満了アクション情報作成
 */
extern void
AktspMakeScheduleTableExactionInfo(AktspScheduleTableExactionRefInfo vschtblexact, TickType offset,
								   uint8 expprop, TaskType task, EventMaskType event);

/*
 *  スピンロック情報作成
 */
extern void
AktspMakeSpinlockInfo(AktspSpinlockRefInfo vspn, uint8 susint, SpinlockIdType successor, uint8 lockflg);

/*
 *  信頼関数
 */
extern void
AktspMakeTrustedFunctionInfo(AktspTrustedFunctionRefInfo vtfn, ApplicationType osap, uint32 stksz);

/*
 * IOC情報作成
 */
extern void
AktspMakeIocInfo(AktspIocRefInfo vioc, uint32 maxque, uint32 quecnt, boolean lostflg, ApplicationType rcvosapid);

/*
 *  ICISR情報作成
 */
extern void
AktspMakeIcISRInfo(AktspIcISRRefInfo vicisr, uint32 intatr, uint8 istat, uint8 rtnstat, uint32 getrescount, ApplicationType osap, MemorySizeType istksz);

/*
 *  終了/再起動中のOSAPに所属するタスクの確認
 */
extern StatusType AktspCheckTaskTerminated(TaskType TaskID, uint8 taskflg);

/*
 *  終了/再起動中のOSAPに所属するアラームの確認
 */
extern StatusType AktspCheckAlarmTerminated(AlarmType AlarmID);

/*
 *  終了/再起動中のOSAPに所属するスケジュールテーブルの確認
 */
extern StatusType AktspCheckScheduleTableTerminated(ScheduleTableType ScheduleTableID, ScheduleTableType ScheduleTableID_To, uint8 implicit);

/*
 *  終了/再起動中のOSAPに所属するカウンタの確認
 */
extern StatusType AktspCheckCounterTerminated(CounterType CounterID);

/********************************************************************

  実装依存で用意するテストライブラリの宣言

 ********************************************************************/

/*
 *  条件チェック
 */
extern void _CheckAssert(const sint8 *expr, const char *file, sint32 line);
#define CheckAssert(exp) do { \
	if (!(exp)) { \
		_CheckAssert((sint8*)(# exp), __FILE__, __LINE__); \
	} \
} while (0)

/*
 *  エラーコードチェック
 */
extern void _CheckErcd(StatusType ercd, const char *file, sint32 line);
#define CheckErcd(ercd, expected_ercd) do { \
	if ((ercd) != (expected_ercd)) { \
		 _CheckErcd((ercd), __FILE__, __LINE__); \
	} \
} while (0)

/*
 *  テストライブラリ初期化(実装依存部)
 */
extern void AktspInitializeImplementTestLib(void);

/*
 *  各コアで実行するテストライブラリ初期化(実装依存部)
 */
extern void AktspInitializeImplementTestLibEachCore(void);

/*
 * エラーフックにおけるデバッグ用関数
 */
extern void AktspErrorHookDebug(StatusType Error);

/*
 * プロテクションフックにおけるデバッグ用関数
 */
extern void AktspProtectionHookDebug(StatusType FatalError);

/*
 * 割込み禁止状態
 */
extern boolean AktspDisInt(void);

/*
 * 割込み禁止状態解除
 */
extern void AktspEnaInt(boolean locked);

/*
 *  ログ出力(書式指定子0)
 */
extern void AktspOutputLog_0(const char8* Format);

/*
 *  ログ出力(書式指定子1)
 */
extern void AktspOutputLog_1(const char8* Format, sintptr Arg1);

/*
 *  ログ出力(書式指定子2)
 */
extern void AktspOutputLog_2(const char8* Format, sintptr Arg1, sintptr Arg2);

/*
 *  ログ出力(書式指定子3)
 */
extern void AktspOutputLog_3(const char8* Format, sintptr Arg1, sintptr Arg2, sintptr Arg3);

/*
 *  ログ出力(書式指定子4)
 */
extern void AktspOutputLog_4(const char8* Format, sintptr Arg1, sintptr Arg2, sintptr Arg3, sintptr Arg4);

/*
 *  タスク
 */
extern StatusType AktspVerifyTask(TaskType TaskID, const AktspTaskRefInfo TaskInfo);

/*
 *  タスクとリソースの関連づけ
 */
extern StatusType AktspVerifyTaskRelResource(TaskType TaskID, ResourceType ResID);

/*
 *  タスクとイベントの関連づけ
 */
extern StatusType AktspVerifyTaskRelEvent(TaskType TaskID, EventMaskType Mask);

/*
 *  タスクが獲得中のリソース(内部リソース以外)
 */
extern StatusType AktspVerifyTaskGetResource(TaskType TaskID, uint32 Index, ResourceType ResID);

/*
 *  タスクが獲得中の内部リソース
 */
extern StatusType AktspVerifyTaskGetInternalResource(TaskType TaskID, ResourceType ResID);

/*
 *  タスクにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyTaskAccessOsap(TaskType TaskID, ApplicationType OsapID);

/*
 *  タスクのアプリケーションモード
 */
extern StatusType AktspVerifyTaskApplicationMode(TaskType TaskID, AppModeType Mode);

/*
 *  リソース
 */
extern StatusType AktspVerifyResource(ResourceType ResID, const AktspResourceRefInfo ResInfo);

/*
 *  リソースにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyResourceAccessOsap(ResourceType ResID, ApplicationType OsapID);

/*
 *  C1ISR
 */
extern StatusType AktspVerifyC1Isr(ISRType IsrID, const AktspISRRefInfo ISRInfo);

/*
 *  C2ISR
 */
extern StatusType AktspVerifyC2Isr(ISRType IsrID, const AktspISRRefInfo ISRInfo);

/*
 *  C2ISRとリソースの関連づけ
 */
extern StatusType AktspVerifyC2IsrRelResource(ISRType IsrID, ResourceType ResID);

/*
 *  C2ISRが獲得中のリソース
 */
extern StatusType AktspVerifyC2IsrGetResource(ISRType IsrID, uint32 Index, ResourceType ResID);

/*
 *  C2ISRにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyC2IsrAccessOsap(ISRType IsrID, ApplicationType OsapID);

/*
 *  割込み禁止状態
 */
extern StatusType AktspVerifyIntState(const AktspIntStateRefInfo IntStateInfo);

/*
 *  割込み禁止操作の順番
 */
extern StatusType AktspVerifyDisIntOrder(uint32 Index, uint8 State);

/*
 *  カウンタ
 */
extern StatusType AktspVerifyCounter(CounterType CounterID, const AktspCounterRefInfo CounterInfo);

/*
 *  カウンタにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyCounterAccessOsap(CounterType CounterID, ApplicationType OsapID);

/*
 *  アラーム
 */
extern StatusType AktspVerifyAlarm(AlarmType AlarmID, const AktspAlarmRefInfo AlarmData);

/*
 *  アラームにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyAlarmAccessOsap(AlarmType AlarmID, ApplicationType OsapID);

/*
 *  アラームのアプリケーションモード
 */
extern StatusType AktspVerifyAlarmApplicationMode(AlarmType AlarmID, AppModeType Mode);

/*
 *  スケジュールテーブル
 */
extern StatusType AktspVerifyScheduleTable(ScheduleTableType ScheduleTableID, const AktspScheduleTableRefInfo ScheduleTableInfo);

/*
 *  スケジュールテーブルの満了アクション
 */
extern StatusType AktspVerifyScheduleTableExaction(ScheduleTableType ScheduleTableID, uint32 Index, const AktspScheduleTableExactionRefInfo ScheduleTableExactionInfo);

/*
 *  スケジュールテーブルにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyScheduleTableAccessOsap(ScheduleTableType ScheduleTableID, ApplicationType OsapID);

/*
 *  スケジュールテーブルのアプリケーションモード
 */
extern StatusType AktspVerifyScheduleTableApplicationMode(ScheduleTableType ScheduleTableID, AppModeType Mode);

/*
 *  スピンロック
 */
extern StatusType AktspVerifySpinlock(SpinlockIdType SpnID, const AktspSpinlockRefInfo SpnInfo);

/*
 *  タスクが獲得中のスピンロック
 */
extern StatusType AktspVerifyTaskGetSpinlock(TaskType TaskID, uint32 Index, SpinlockIdType SpnID);

/*
 *  C2ISRが獲得中のスピンロック
 */
extern StatusType AktspVerifyC2IsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID);

/*
 *  スピンロックにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifySpinlockAccessOsap(SpinlockIdType SpnID, ApplicationType OsapID);

/*
 *  信頼関数
 */
extern StatusType AktspVerifyTrustedFunction(TrustedFunctionIndexType FunctionIndex, AktspTrustedFunctionRefInfo TrustedFunctionInfo);

/*
 *  AktspTfnActivateTaskへのラッパー関数
 */
extern StatusType AktspTrustActivateTask(TaskType TaskID);

/*
 *  AktspTfnSetEventへのラッパー関数
 */
extern StatusType AktspTrustSetEvent(TaskType TaskID, EventMaskType Mask);

/*
 *  AktspTfnRaiseInterCoreInterruptへのラッパー関数
 */
extern StatusType AktspTrustRaiseInterCoreInterrupt(ISRType ISRID);

/*
 *  AktspTfnShutdownOSへのラッパー関数
 */
extern void AktspTrustShutdownOS(StatusType Error);

#if 0
/*
 *  OSアプリケーション固有のスタートアップフック
 */
extern StatusType AktspVerifyStartupHookOsap(ApplicationType OsapID, StartupHookOsap StartupHookFunction);

/*
 *  OSアプリケーション固有のシャットダウンフック
 */
extern StatusType AktspVerifyShutdownHookOsap(ApplicationType OsapID, ShutdownHookOsap ShutdownHookFunction);

/*
 *  OSアプリケーション固有のエラーフック
 */
extern StatusType AktspVerifyErrorHookOsap(ApplicationType OsapID, ErrorHookOsap ErrorHookFunction);

#endif

/*
 *  全割込み禁止状態取得API
 */
extern boolean AktspGetDisableAllInterruptsState(void);

/*
 *  タスクの状態取得API(マルチコアのみ)
 */
extern TaskStateType AktspGetTaskState(TaskType TaskID);

/*
 *  エラーフック起動
 */
extern void AktspRaiseErrorHook(void);

/*
 *  CounterIDで指定したハードウェアカウンタのティック更新停止
 */
extern StatusType AktspStopHardwareCounter(CounterType CounterID);

/*
 *  CounterIDで指定したハードウェアカウンタのティック更新開始
 */
extern StatusType AktspStartHardwareCounter(CounterType CounterID);

/*
 *  CounterIDで指定したハードウェアカウンタのティックを0へ初期化
 */
extern StatusType AktspInitHardwareCounter(CounterType CounterID);

/*
 *  CounterIDで指定したハードウェアカウンタの1ティック更新
 */
extern StatusType AktspIncrementHardwareCounter(CounterType CounterID);

/*
 *  IOC確認
 */
extern StatusType AktspVerifyIoc(IocType IocId, const AktspIocRefInfo IocInfo);

/*
 *  IOCセンダ確認
 */
extern StatusType AktspVerifyIocSender(IocType IocId, SenderIdType SenderId, ApplicationType SenderOsapId);

/*
 *  IOCデータ確認
 */
extern StatusType AktspGetDataFromIoc(IocType IocId, void* data, uint32 index);

/*
 *  強制マージ時に，最後のmain関数から呼び出す処理(マルチコアのみで使用)
 */
extern void AktspCallFromLastMainFunc(void);

/*
 *  ICISR
 */
extern StatusType AktspVerifyIcIsr(ISRType IsrID, const AktspIcISRRefInfo IcISRInfo);

/*
 *  ICISRとリソースの関連づけ
 */
extern StatusType AktspVerifyIcIsrRelResource(ISRType IsrID, ResourceType ResID);

/*
 *  ICISRが獲得中のリソース
 */
extern StatusType AktspVerifyIcIsrGetResource(ISRType IsrID, uint32 Index, ResourceType ResID);

/*
 *  ICISRにアクセス可能な非信頼OSアプリケーション
 */
extern StatusType AktspVerifyIcIsrAccessOsap(ISRType IsrID, ApplicationType OsapID);

/*
 *  ICISRが獲得中のスピンロック
 */
extern StatusType AktspVerifyIcIsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID);

/*
 *  OSAPの状態
 */
extern StatusType AktspVerifyOsapState(ApplicationType OsapID, ApplicationStateType State);

/********************************************************************

  ターゲット依存で用意するテストライブラリの宣言

 ********************************************************************/

/*
 *  テストライブラリ初期化(ターゲット依存部)
 */
extern void AktspInitializeTargetTestLib(void);

/*
 *  各コアで実行するテストライブラリ初期化(ターゲット依存部)
 */
extern void AktspInitializeTargetTestLibEachCore(void);

/*
 *  割込みの発生
 */
extern void AktspRaiseInterrupt(InterruptNumberType raiseintno);

/*
 *  割込み要求のクリア
 */
extern void AktspClearIntRequest(InterruptNumberType clearintno);

/*
 *  割込み要求のキャンセル
 */
extern void AktspCancelIntRequest(InterruptNumberType cancelintno);

/*
 *  プロテクションフック起動
 */
extern void AktspRaiseProtectionHook(void);

/*
 *  プロテクションフック初期処理
 */
extern void AktspProtectionHookInit(void);

/*
 * プロテクションフックにおけるデバッグ用関数(ターゲット依存)
 */
extern void AktspProtectionHookTargetDebug(StatusType FatalError);

/*
 *  スタックオーバーフロー発生
 *  (タスク系システムサービス発行時)
 */
extern void AktspRaiseTaskStackOverflowByDispatch(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info);

/*
 *  スタックオーバーフロー発生
 *  (割込み発生時)
 */
extern void AktspRaiseTaskStackOverflowByInterrupt(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info);

/*
 *  スタックオーバーフロー発生
 *  (自コアに対するコア間割込み発生時)
 */
extern void AktspRaiseTaskStackOverflowByIcIsr(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info);

/*
 *  スタックオーバーフロー発生
 *  (多重割込み発生時)
 */
extern void AktspRaiseIsrStackOverflowByInterrupt(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info);

/*
 *  スタックオーバーフロー発生
 *  (自コアに対するコア間割込みが多重割込みで発生時)
 */
extern void AktspRaiseIsrStackOverflowByIcIsr(uint8* stk, MemorySizeType size, const AktspStackOverflowRefInfo info);

/*
 *  スタックオーバーフロー発生
 *  (割込みリターン時)
 */
extern void AktspRaiseIsrStackOverflowByReturn(uint8* stk, MemorySizeType size);

/*
 *  スタックオーバーフロー発生
 *  (信頼関数リターン時)
 */
extern void AktspRaiseTfnStackOverflowByReturn(uint8* stk, MemorySizeType size);

/*
 *  CPU例外発生
 */
extern void AktspRaiseCPUException(void);

/*
 *  スタック初期化
 */
extern void AktspInitializeStack(uint8* stk, MemorySizeType size, boolean boot);

/*
 *  スタック使用量チェック
 */
extern uint32 AktspCheckStackUsage(uint8* stk, MemorySizeType size);

/*
 *  メモリ保護テスト関数
 */

/*
 *  すべてのOSAP，処理単位からアクセスできる領域へのアクセス
 *  (共有領域へのアクセスなど)
 */
extern void AktspAccessAllAccessibleArea(boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

/*
 *  非信頼OSAP1からのみアクセスできない領域へのアクセス
 *  (非信頼OSAP2の専有領域へのアクセスなど)
 */
extern void AktspAccessNtOsap1InaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

/*
 *  非信頼OSAP2からのみアクセスできない領域へのアクセス
 *  (非信頼OSAP1の専有領域へのアクセスなど)
 */
extern void AktspAccessNtOsap2InaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

/*
 *  全ての非信頼OSAPからアクセスできない領域へのアクセス
 *  (OS専有領域，ROMへの書込み，リードライトへの実行アクセスなど)
 */
extern void AktspAccessAllNtOsapInaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

/*
 *  対象スタックを使用する処理単位からアクセスできるスタック領域へのアクセス
 *  (対象スタックへの読出し，書込みアクセス)
 */
extern void AktspAccessStackArea(uint8 stack, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

/*
 *  対象スタックを使用する処理単位からアクセスできないスタック領域へのアクセス
 *  (対象スタックへの実行アクセス，スタックを使用する処理単位以外の全処理単位からのアクセスなど)
 */
extern void AktspInaccessibleStackArea(uint8 stack, boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid);

#endif /* TOPPERS_AKTSP_COMMON_LIB_H */
