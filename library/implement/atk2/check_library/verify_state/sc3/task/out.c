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
 *  ・AktspVerifyTask()
 *  ・AktspVerifyTaskRelResource()
 *  ・AktspVerifyTaskRelEvent()
 *  ・AktspVerifyTaskGetResource()
 *  ・AktspVerifyTaskGetInternalResource()
 *  ・AktspVerifyTaskApplicationMode()
 *  ・AktspVerifyTaskAccessOsap()
 *
 * 《E_OKが返ることの確認》
 * 【AktspVerifyTask()】
 * ・tstat (タスク状態)
 * ※タスク，カテゴリ2 ISR，カテゴリ1 ISR，エラーフックから確認する場合
 *  SUSPENDED : TaskSus
 *  RUNNING   : TaskPri15a(このタスクが他のタスクの状態を確認する),
 *            : TaskPri13a(このタスクが実行状態になった際の，自タスクの
 *            : 状態を確認する)
 *  READY     : porderの項目に書かれているタスク
 *  WAITING   : TaskEventA, TaskEventBC
 *
 * ・tstat (タスク状態)
 * ※プレタスクフック/ポストタスクフックから確認する場合
 *  SUSPENDED : TaskSus, TaskPri15a
 *  RUNNING   : TaskPri15b(このタスクが他のタスクの状態を確認する)
 *  READY     : porderの項目に書かれているTaskPri15bを除くタスク
 *  WAITING   : TaskEventA, TaskEventBC
 *
 * ・curpri (タスクの現在優先度)
 *  優先度 : チェックするタスクのタスクID
 *  15   : TaskPri15a,    TaskPri15b, TaskPri15c
 *  14   : TaskResource3, TaskPri14a
 *  13   : TaskEventA,    TaskPri13a, TaskPri13b
 *  12   : TaskPri12a,    TaskPri12b, TaskPri12c
 *  11   : TaskPri11a
 *  10   : TaskPri10a,    TaskPri10b
 *  9    : TaskEventBC,   TaskPri9a, TaskPri9b
 *  8    : TaskPri8a
 *  7    : TaskPri7a,     TaskPri7b
 *  6    : TaskResource2, TaskPri6a,  TaskPri6b
 *  5    : TaskPri5a,     TaskPri5b
 *  4    : TaskEventDE,   TaskPri4a,  TaskPri4b
 *  3    : TaskPri3a
 *  2    : TaskResource1, TaskPri2a,  TaskPri2b
 *  1    : TaskPri1a,     TaskPri1b
 *  0    : TaskPri0a,     TaskPri0b,  TaskPri0c
 *
 * ・inipri (タスクの初期優先度)
 *  優先度 : チェックするタスクのタスクID
 *  15     : TaskPri15a,    TaskPri15b, TaskPri15c
 *  14     : TaskPri14a
 *  13     : TaskEventA,    TaskPri13a, TaskPri13b
 *  12     : TaskPri12a,    TaskPri12b, TaskPri12c
 *  11     : TaskPri11a
 *  10     : TaskPri10a,    TaskPri10b
 *  9      : TaskEventBC,   TaskPri9a, TaskPri9b
 *  8      : TaskPri8a
 *  7      : TaskResource3, TaskPri7a,  TaskPri7b
 *  6      : TaskPri6a,     TaskPri6b
 *  5      : TaskPri5a,     TaskPri5b
 *  4      : TaskEventDE,   TaskPri4a,  TaskPri4b
 *  3      : TaskResource2, TaskPri3a
 *  2      : TaskPri2a,     TaskPri2b,  TaskSus
 *  1      : TaskResource1, TaskPri1a,  TaskPri1b
 *  0      : TaskPri0a,     TaskPri0b,  TaskPri0c
 *
 * ・ttype (タスクの種別)
 *  AK_BASIC    : 下記以外のタスク全て
 *  AK_EXTENDED : TaskEventA, TaskEventBC, TaskEventDE, TaskSus
 *
 * ・maxact (起動要求の最大数)
 *  3 : TaskPri8a
 *  1 : 上記以外のタスク全て
 *
 * ・spolicy (スケジューリングポリシ)
 *  AK_SCHFULL : 下記以外全てのタスク
 *  AK_SCHNON  : TaskPri13a, TaskPri9b
 *
 * ・waievt (待っているイベント)
 *  EventA : TaskEventA
 *  EventB : TaskEventBC
 *
 * ・curevt (イベントの現在値)
 *  EventC            : TaskEventBC
 *  (EventD | EventE) : TaskEventDE
 *  EventF            : TaskSus
 *  0                 : TaskEventA
 *
 * ・actcnt (起動要求数)
 *  1 : 下記以外のタスク
 *  3 : TaskPri8a
 *
 * ・porder (同一優先度タスク内での優先順位)
 *  ※各優先度のレディーキューに複数タスクが以下の順に存在することを確
 *    認
 *  ※左から順にporderをカウントする
 *  ※TaskPri15bは，プレタスクフック，ポストタスクフックから確認する場
 *    合確認しない
 *  優先度 : チェックするタスクのタスクID
 *  15     : TaskPri15b,    TaskPri15c
 *  14     : TaskResource3, TaskPri14a
 *  13     : TaskPri13a,    TaskPri13b
 *  12     : TaskPri12a,    TaskPri12b, TaskPri12c
 *  11     : TaskPri11a
 *  10     : TaskPri10a,    TaskPri10b
 *  9      : TaskPri9a,     TaskPri9b
 *  8      : TaskPri8a
 *  7      : TaskPri7a,     TaskPri7b
 *  6      : TaskResource2, TaskPri6a,  TaskPri6b
 *  5      : TaskPri5a,     TaskPri5b
 *  4      : TaskEventDE,   TaskPri4a,  TaskPri4b
 *  3      : TaskPri3a
 *  2      : TaskResource1, TaskPri2a,  TaskPri2b
 *  1      : TaskPri1a,     TaskPri1b
 *  0      : (MainTask),    TaskPri0a,  TaskPri0b, TaskPri0c
 *           (MAIN_TASKは除かれるので、TaskPri0aが porder : 1 となる)
 *
 * ・getrescount (内部リソースを除く，獲得リソース数)
 *  0 : getresにリソースが指定されていない，RUNNINGもしくは，READYのタスク
 *  1 : TaskResource1
 *  2 : TaskResource2
 *  3 : TaskResource3
 *
 * ・stksz (スタック領域のサイズ)
 *  1024                  : TaskSus
 *  AKTSP_TASK_STACK_SIZE : TaskSus以外のタスク
 *
 * ・stk (スタック領域の先頭番地)
 *  NULL : 全てのタスク(スタック共有offの場合は，指定できない)
 *
 * ・sstksz (システムスタック領域のサイズ)
 *  512                   : TaskSus
 *  AKTSP_TASK_STACK_SIZE : TaskSus以外のタスク
 *
 * ・sstk (システムスタック領域の先頭番地)
 *  NULL : 全てのタスク(スタック共有offの場合は，指定できない)
 *
 * 【AktspVerifyTaskApplicationMode()】
 * ・appmode (アプリケーションモード)
 *  MainApp           : TaskPri8a
 *  APPLICATION_MODE1 : TaskPri8a
 *  APPLICATION_MODE2 : TaskPri8a
 *  APPLICATION_MODE3 : TaskSus
 *
 * ・osap (所属するOSアプリケーション)
 *  TRUSTED_OSAP1     : TaskPri15a, TaskPri15c, TaskResource3, TaskPri13a,
 *                      TaskPri12a, TaskPri11a, TaskPri10a, TaskPri9a, TaskPri8a,
 *                      TaskPri7a, TaskResource2, TaskPri5a, TaskEventDE,
 *                      TaskPri3a, TaskResource1, TaskPri1a, TaskPri0a,
 *                      TaskEventBC
 *  NON_TRUSTED_OSAP1 : TaskPri15b, TaskPri14a, TaskPri13b, TaskPri12b, TaskPri12c,
 *                      TaskPri10b, TaskPri9b, TaskPri7b, TaskPri6a,
 *                      TaskPri6b, TaskPri5b, TaskPri4a, TaskPri4b,
 *                      TaskPri2a, TaskPri2b, TaskPri1b, TaskPri0b, TaskPri0c,
 *                      TaskSus, TaskEventA
 *
 * 【AktspVerifyTaskAccessOsap()】
 * ・accosap (アクセスを許可する非信頼OSアプリケーション)
 *  NON_TRUSTED_OSAP1 : TaskPri15a
 *
 * 【AktspVerifyTaskRelResource()】
 * ・relres (関連付けられたリソース)
 *  ResourceA(標準リソース) : TaskResource3, TaskPri9b
 *  ResourceB(標準リソース) : TaskResource3, TaskPri12a
 *  ResourceC(標準リソース) : TaskResource3, TaskPri14a
 *  ResourceD(標準リソース) : TaskResource2, TaskPri4b
 *  ResourceE(標準リソース) : TaskResource2, TaskPri6b
 *  ResourceF(標準リソース) : TaskResource1, TaskSus
 *  ResourceInternal(内部リソース) : TaskPri7a, TaskPri5b
 *
 * 【AktspVerifyTaskRelEvent()】
 * ・relevt (関連付けられたイベント)
 *  EventA : TaskEventA
 *  EventB : TaskEventBC
 *  EventC : TaskEventBC
 *  EventD : TaskEventDE
 *  EventE : TaskEventDE
 *  EventF : TaskSus
 *
 * 【AktspVerifyTaskGetResource()】
 * ・getres (獲得したリソース)
 *  ※ 左から順に獲得
 *  ResourceF                       : TaskResource1
 *  ResourceD, ResourceE            : TaskResource2
 *  ResourceA, ResourceB, ResourceC : TaskResource3
 *
 * <補足>
 *  TaskEventDEを一度待ち状態にし，再度実行可能状態になった際の優先度5の
 *  porderを確認する
 *  確認する順序 : TaskPri4a, TaskPri4b, TaskEventDE
 *
 * 《異常な値を代入し，E_NOT_OKが返ることの確認》
 * 【AktspVerifyTask()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   tstat       | TaskSus
 *   waievt      | TaskEventA
 *   curpri      | TaskPri8a, TaskPri13a
 *   inipri      | TaskSus
 *   ttype       | TaskSus, TaskPri8a
 *   maxact      | TaskSus
 *   curevt      | TaskSus
 *   actcnt      | TaskPri8a
 *   porder      | TaskPri8a
 *   getrescount | TaskPri8a
 *   stksz       | TaskSus
 *   stk         | TaskSus
 *   osap        | TaskSus
 *
 * 【AktspVerifyTaskGetResource()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   getres      | TaskResource1
 *
 * 【AktspVerifyTaskApplicationMode()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   appmode     | TaskPri8a
 *
 * 【AktspVerifyTaskAccessOsap()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   apposap     | TaskPri15a
 *
 * 《確認できないパラメータに対して不正な値を代入し，E_OKが返ることの確認》
 * 【AktspVerifyTask()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  --------------------------------------------------------------------
 *   spolicy     | TaskPri15a (初期優先度が15かつ，spolicyがAK_SCHFULL)
 *               | TaskPri13a (spolicyがAK_SCHNON)
 *
 * 【AktspVerifyTaskRelResource()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   relres      | TaskResource1
 *
 * 【AktspVerifyTaskRelEvent()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   relevt      | TaskEventA
 *
 * 【AktspVerifyTaskGetInternalResource()】
 *   TESRYデータ | 確認するタスクのタスクID
 *  ----------------------------------------
 *   getres      | TaskPri7a
 */

#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "out.h"

static int hookboot = 0;

TASK(TaskSus)
{
	AktspCheckPoint(6);
	TerminateTask();
}

TASK(TaskResource1)
{
	StatusType ercd;

	AktspCheckPoint(8);

	ercd = GetResource(ResourceF);
	CheckErcd(ercd, E_OK);

	ercd = ActivateTask(TaskResource2);
	CheckErcd(ercd, E_OK);

	/* 後処理 */
	ercd = ReleaseResource(ResourceF);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskResource2)
{
	StatusType ercd;

	AktspCheckPoint(9);

	ercd = GetResource(ResourceD);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(ResourceE);
	CheckErcd(ercd, E_OK);

	ercd = ActivateTask(TaskResource3);
	CheckErcd(ercd, E_OK);

	/* 後処理 */
	ercd = ReleaseResource(ResourceE);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(ResourceD);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskResource3)
{
	StatusType ercd;

	AktspCheckPoint(10);

	ercd = ActivateTask(TaskEventDE);
	CheckErcd(ercd, E_OK);
	ercd = SetEvent(TaskEventDE, (EventD | EventE));
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(11);

	ercd = GetResource(ResourceA);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(ResourceB);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(ResourceC);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(12);

	ercd = ActivateTask(TaskPri15a);
	CheckErcd(ercd, E_OK);

	/* 後処理 */
	ercd = ReleaseResource(ResourceC);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(ResourceB);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(ResourceA);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskEventA)
{
	StatusType ercd;

	AktspCheckPoint(2);

	ercd = WaitEvent(EventA);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskEventBC)
{
	StatusType ercd;

	AktspCheckPoint(4);

	ercd = WaitEvent(EventB);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskEventDE)
{
	StatusType ercd;

	/*
	 *  TaskEventDEを一度待ち状態にし，再度実行可能状態になった際の
	 *  優先度5のporderを確認するための状態作成
	 */
	ercd = WaitEvent((EventD | EventE));
	CheckErcd(ercd, E_OK);
	ercd = ClearEvent((EventD | EventE));
	CheckErcd(ercd, E_OK);
	ercd = WaitEvent(EventD);
	CheckErcd(ercd, E_OK);
	ercd = ClearEvent(EventD);
	CheckErcd(ercd, E_OK);

	TerminateTask();
}

TASK(TaskPri15a)
{
	StatusType ercd;

	/*
	 *  実行可能状態となるタスクを起動
	 */
	ercd = ActivateTask(TaskPri15b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri15c);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri14a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri13a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri13b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri12a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri12b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri12c);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri11a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri10a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri10b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri9a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri9b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri8a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri7a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri7b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri6a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri6b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri5a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri5b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri4a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri4b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri3a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri2a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri2b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri1a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri1b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri0a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri0b);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri0c);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(13);

	/* 多重起動要求数をキューイング */
	ercd = ActivateTask(TaskPri8a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri8a);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(14);

	/* 信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyTask();

	AktspCheckPoint(15);

	/* カテゴリ2 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_F);

	AktspCheckPoint(17);

	/* カテゴリ1 ISR起動 */
	AktspRaiseInterrupt(AKTSP_INTNO_B);

	AktspCheckPoint(19);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(22);

	/* プロテクションフックの呼び出し */
	AktspRaiseProtectionHook();

	AktspCheckPoint(24);

	/* ポストタスクフックとプレタスクフックの呼び出し */
	hookboot = 1;

	TerminateTask();
}

TASK(TaskPri15b)
{
	StatusType		ercd;
	AktspTfParam	local;

	AktspCheckPoint(27);

	/* 非信頼OSAPに所属するタスクからの確認 */
	CheckAktspVerifyTask();

	AktspCheckPoint(28);

	/* 信頼関数の呼び出し */
	ercd = CallTrustedFunction(VerifyTrustedFunction, &local);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(30);

	/* エラーフックの呼び出し */
	AktspRaiseErrorHook();

	AktspCheckPoint(33);

	TerminateTask();
}

TASK(TaskPri15c)
{
	TerminateTask();
}

TASK(TaskPri14a)
{
	TerminateTask();
}

TASK(TaskPri13a)
{
	StatusType		ercd;
	AktspTaskInfo	vtsk;

	AktspCheckPoint(34);

	/*
	 *  ノンスケジューリングポリシのタスクが実行状態の場合の確認
	 *
	 *  TaskPri13a:
	 *    type    : TASK
	 *    tstat   : RUNNING
	 *    curpri  : 14
	 *    inipri  : 14
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = RUNNING;
	vtsk.tm_curpri = 13;
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON;
	vtsk.tm_actcnt = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri13a, &vtsk);
	CheckErcd(E_OK, ercd);

	TerminateTask();
}

TASK(TaskPri13b)
{
	TerminateTask();
}

TASK(TaskPri12a)
{
	TerminateTask();
}

TASK(TaskPri12b)
{
	TerminateTask();
}

TASK(TaskPri12c)
{
	TerminateTask();
}

TASK(TaskPri11a)
{
	TerminateTask();
}

TASK(TaskPri10a)
{
	TerminateTask();
}

TASK(TaskPri10b)
{
	TerminateTask();
}

TASK(TaskPri9a)
{
	TerminateTask();
}

TASK(TaskPri9b)
{
	TerminateTask();
}

TASK(TaskPri8a)
{
	TerminateTask();
}

TASK(TaskPri7a)
{
	StatusType		ercd;
	AktspTaskInfo	vtsk;

	AktspCheckPoint(35);

	/*
	 *  TaskPri7a:
	 *    type    : TASK
	 *    tstat   : RUNNING
	 *    curpri  : 8
	 *    inipri  : 8
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceInternal
	 *    getres  :
	 *      - ResourceInternal
	 *    osap    : TRUSTED_OSAP1
	 */

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyTaskGetInternalResource())
	 */
	ercd = AktspVerifyTaskGetInternalResource(TaskPri6a, ResourceInternal); /* 正しくは第1引数がTaskPri7a */
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskGetInternalResource(TaskPri7a, ResourceF);        /* 正しくは第2引数がResourceInternal */
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri7aの状態確認
	 */
	vtsk.tm_tstat = RUNNING;
	vtsk.tm_curpri = 7;
	vtsk.tm_inipri = 7;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri7a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri7a, ResourceInternal);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskGetInternalResource(TaskPri7a, ResourceInternal);
	CheckErcd(E_OK, ercd);

	TerminateTask();
}

TASK(TaskPri7b)
{
	TerminateTask();
}

TASK(TaskPri6a)
{
	TerminateTask();
}

TASK(TaskPri6b)
{
	TerminateTask();
}

TASK(TaskPri5a)
{
	TerminateTask();
}

TASK(TaskPri5b)
{
	TerminateTask();
}

TASK(TaskPri4a)
{
	TerminateTask();
}

TASK(TaskPri4b)
{
	TerminateTask();
}

TASK(TaskPri3a)
{
	TerminateTask();
}

TASK(TaskPri2a)
{
	TerminateTask();
}

TASK(TaskPri2b)
{
	TerminateTask();
}

TASK(TaskPri1a)
{
	TerminateTask();
}

TASK(TaskPri1b)
{
	TerminateTask();
}

TASK(TaskPri0a)
{
	TerminateTask();
}

TASK(TaskPri0b)
{
	TerminateTask();
}

TASK(TaskPri0c)
{
	TerminateTask();
}

TRUSTEDFUNCTION(TRUSTED_VerifyTrustedFunction, FunctionIndex, FunctionParams)
{
	AktspCheckPoint(29);

	/* 信頼関数からの確認 */
	CheckAktspVerifyTask();

	return E_OK;
}

ISR(AKTG_C2ISR_COMMON_AKTSP_INTNO_F)
{
	AktspClearIntRequest(AKTSP_INTNO_F);
	AktspCheckPoint(16);

	/* カテゴリ2 ISRからの確認 */
	CheckAktspVerifyTask();

	return;
}

AKTSP_C1ISR_ENTRY(AKTG_C1ISR_COMMON_AKTSP_INTNO_B, AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY);
void
AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY(void)
{
	AktspClearIntRequest(AKTSP_INTNO_B);
	AktspCheckPoint(18);

	/* カテゴリ1 ISRからの確認 */
	CheckAktspVerifyTask();
}

void
ErrorHook(StatusType ercd)
{
	static uint16	bootcnt = 0;

	if (bootcnt == 0) {
		AktspCheckPoint(20);
	}
	/* 非信頼OSAPからの起動 */
	else if (bootcnt == 1) {
		AktspCheckPoint(31);
	}

	/* エラーフックからの確認 */
	CheckAktspVerifyTask();

	bootcnt++;
}

#if 0
void
ErrorHook_TRUSTED_OSAP1(StatusType ercd)
{
	AktspCheckPoint(21);

	/* 信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyTask();
}

void
ErrorHook_NON_TRUSTED_OSAP1(StatusType ercd)
{
	AktspCheckPoint(32);

	/* 非信頼OSAP固有のエラーフックからの確認 */
	CheckAktspVerifyTask();
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

	AktspCheckPoint(23);

	/* プロテクションフックからの確認 */
	CheckAktspVerifyTask();

	return(PRO_IGNORE);
}

void
PostTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(25);

		/* ポストタスクフックからの確認 */
		CheckAktspVerifyTask();
	}
}

void
PreTaskHook(void)
{
	if (hookboot == 1) {
		AktspCheckPoint(26);

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

	ercd = ActivateTask(TaskEventA);
	CheckErcd(ercd, E_OK);
	AktspCheckPoint(3);
	ercd = ActivateTask(TaskEventBC);
	CheckErcd(ercd, E_OK);
	AktspCheckPoint(5);

	ercd = SetEvent(TaskEventBC, EventC);
	CheckErcd(ercd, E_OK);
	ercd = GetResource(DummyResource);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskSus);
	CheckErcd(ercd, E_OK);
	ercd = SetEvent(TaskSus, EventF);
	CheckErcd(ercd, E_OK);
	ercd = ReleaseResource(DummyResource);
	CheckErcd(ercd, E_OK);
	AktspCheckPoint(7);

	ercd = ActivateTask(TaskResource1);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(36);

	/*
	 *  TaskEventDEを一度待ち状態にし，再度実行可能状態になった際の
	 *  優先度5のporderを確認する
	 */
	ercd = GetResource(DummyResource);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri4a);
	CheckErcd(ercd, E_OK);
	ercd = ActivateTask(TaskPri4b);
	CheckErcd(ercd, E_OK);
	ercd = SetEvent(TaskEventDE, EventD);
	CheckErcd(ercd, E_OK);

	AktspCheckPoint(37);

	CheckPorderAfterRotate();

	ercd = ReleaseResource(DummyResource);
	CheckErcd(ercd, E_OK);

	AktspCheckFinish(39);
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
CheckAktspVerifyTask(void)
{
	StatusType		ercd;
	AktspTaskInfo	vtsk;
	static uint16	bootcnt = 0;

	/*
	 *  bootcntと呼び出し元処理単位の関係
	 *  0  : 信頼OSAPに所属するタスク
	 *  1  : カテゴリ2 ISR
	 *  2  : カテゴリ1 ISR
	 *  3  : エラーフック
	 *  4  : 信頼OSAP固有のエラーフック
	 *  5  : プロテクションフック
	 *  6  : ポストタスクフック
	 *  7  : プレタスクフック
	 *  8  : 非信頼OSAPに所属するタスク
	 *  9  : 信頼関数
	 *  10 : エラーフック
	 *  11 : 非信頼OSAP固有のエラーフック
	 */

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTask())
	 */

	/*
	 *  TaskSus:
	 *    type    : TASK
	 *    tstat   : SUSPENDED
	 *    inipri  : 2
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    curevt  : EventF
	 *    relres  :
	 *      - ResourceF
	 *    relevt  :
	 *      - EventF
	 *    stksz   : 1024
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;                                 /* 正しくはSUSPENDED */
	vtsk.tm_inipri = 3;                                    /* 正しくは2 */
	vtsk.tm_ttype = AK_BASIC;                              /* 正しくはAK_EXTENDED */
	vtsk.tm_maxact = 2;                                    /* 正しくは1 */
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = EventE;                               /* 正しくはEventF */
	vtsk.tm_stksz = 256;                                   /* 正しくは1024 */
	vtsk.tm_stk = AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY;  /* 正しくはNULL */
	vtsk.tm_sstksz = 1024;                                 /* 正しくは512 */
	vtsk.tm_sstk = AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY; /* 正しくはNULL */
	vtsk.tm_osap = TRUSTED_OSAP1;                          /* 正しくはNON_TRUSTED_OSAP1 */

	ercd = AktspVerifyTask(TaskSus, &vtsk);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  TaskEventA:
	 *    type    : TASK
	 *    tstat   : WAITING
	 *    inipri  : 13
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    waievt  : EventA
	 *    relevt  :
	 *      - EventA
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = WAITING;
	vtsk.tm_inipri = 13;
	vtsk.tm_curpri = 13;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_waievt = EventB; /* 正しくはEventA */
	vtsk.tm_curevt = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskEventA, &vtsk);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  TaskPri8a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 8
	 *    inipri  : 8
	 *    ttype   : AK_BASIC
	 *    maxact  : 3
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 3
	 *    porder  : 1
	 *    appmode :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 *      - APPLICATION_MODE2
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 9;           /* 正しくは8 */
	vtsk.tm_inipri = 8;
	vtsk.tm_ttype = AK_EXTENDED;  /* 正しくはAK_BASIC */
	vtsk.tm_maxact = 3;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 4;           /* 正しくは3 */
	vtsk.tm_porder = 3;           /* 正しくは1 */
	vtsk.tm_getrescount = 1;      /* 正しくは0 */
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri8a, &vtsk);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  TaskPri13a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 13
	 *    inipri  : 13
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 12; /* 正しくは13 */
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri13a, &vtsk);
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTaskGetResource())
	 */

	/*
	 *  TaskResource1:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 2
	 *    inipri  : 1
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceF
	 *    getres  :
	 *      - ResourceF
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	ercd = AktspVerifyTaskGetResource(TaskResource1, 2, ResourceF); /* 正しくは第2引き数が1 */
	CheckErcd(E_NOT_OK, ercd);
	ercd = AktspVerifyTaskGetResource(TaskResource1, 1, ResourceE); /* 正しくは第3引き数がResourceF */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTaskApplicationMode())
	 */

	/*
	 *  TaskPri8a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 8
	 *    inipri  : 8
	 *    ttype   : AK_BASIC
	 *    maxact  : 3
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 3
	 *    porder  : 1
	 *    appmode :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 *      - APPLICATION_MODE2
	 */
	ercd = AktspVerifyTaskApplicationMode(TaskPri8a, APPLICATION_MODE3); /* 正しくは第2引き数がMainApp，APPLICATION_MODE1，もしくはAPPLICATION_MODE2 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  異常な値を代入し，E_NOT_OKが返ることの確認(AktspVerifyTaskAccessOsap())
	 */

	/*
	 *  TaskPri15a:
	 *    type    : TASK
	 *    tstat   : RUNNING
	 *    curpri  : 15
	 *    inipri  : 15
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    osap    : TRUSTED_OSAP1
	 *    accosap :
	 *      - NON_TRUSTED_OSAP1
	 */
	ercd = AktspVerifyTaskAccessOsap(TaskPri15a, TRUSTED_OSAP1); /* 正しくは第2引き数がNON_TRUSTED_OSAP1 */
	CheckErcd(E_NOT_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyTask())
	 */

	/*
	 *  TaskPri15a:
	 *    type    : TASK
	 *    tstat   : RUNNING
	 *    curpri  : 15
	 *    inipri  : 15
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    osap    : TRUSTED_OSAP1
	 *    accosap :
	 *      - NON_TRUSTED_OSAP1
	 */
	if (bootcnt <= 6) {
		vtsk.tm_tstat = RUNNING;
		vtsk.tm_curpri = 15;
		vtsk.tm_actcnt = 1;
		vtsk.tm_getrescount = 0;
	}
	else {
		vtsk.tm_tstat = SUSPENDED;
	}
	vtsk.tm_inipri = 15;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON; /* 正しくはAK_SCHFULL */
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri15a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri13a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 13
	 *    inipri  : 13
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 13;
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL; /* 正しくはAK_SCHNON */
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri13a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyTaskRelResource())
	 */

	/*
	 *  TaskResource1:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 2
	 *    inipri  : 1
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceF
	 *    getres  :
	 *      - ResourceF
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */

	ercd = AktspVerifyTaskRelResource(TaskResource1, ResourceA); /* 正しくは第1引き数がResourceF */
	CheckErcd(E_OK, ercd);

	/*
	 *  確認できないパラメータに対して不正な値を代入し，
	 *  E_OKが返ることの確認(AktspVerifyTaskRelEvent())
	 */

	/*
	 *  TaskEventA:
	 *    type    : TASK
	 *    tstat   : WAITING
	 *    inipri  : 13
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    waievt  : EventA
	 *    relevt  :
	 *      - EventA
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	ercd = AktspVerifyTaskRelEvent(TaskEventA, EventB); /* 正しくは第2引き数がEventA */
	CheckErcd(E_OK, ercd);

	/*
	 *  各タスクの状態確認
	 */

	/*
	 *  TaskSusチェック
	 *
	 *  TaskSus:
	 *    type    : TASK
	 *    tstat   : SUSPENDED
	 *    inipri  : 2
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    curevt  : EventF
	 *    stksz   : 1024
	 *    sstksz  : 512
	 *    relres  :
	 *      - ResourceF
	 *    relevt  :
	 *      - EventF
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = SUSPENDED;
	vtsk.tm_inipri = 2;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = EventF;
	vtsk.tm_stksz = 1024;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 512;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskSus, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskSus, ResourceF);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelEvent(TaskSus, EventF);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskApplicationMode(TaskSus, APPLICATION_MODE3);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri15aチェック
	 *
	 *  TaskPri15a:
	 *    type    : TASK
	 *    tstat   : RUNNING
	 *    curpri  : 15
	 *    inipri  : 15
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	if (bootcnt <= 6) {
		vtsk.tm_tstat = RUNNING;
		vtsk.tm_curpri = 15;
		vtsk.tm_actcnt = 1;
		vtsk.tm_getrescount = 0;
	}
	else {
		vtsk.tm_tstat = SUSPENDED;
	}
	vtsk.tm_inipri = 15;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri15a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskAccessOsap(TaskPri15a, NON_TRUSTED_OSAP1);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri15bチェック
	 *
	 *  TaskPri15b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 15
	 *    inipri  : 15
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	if (bootcnt <= 6) {
		vtsk.tm_tstat = READY;
		vtsk.tm_porder = 1;
	}
	else {
		vtsk.tm_tstat = RUNNING;
	}
	vtsk.tm_curpri = 15;
	vtsk.tm_inipri = 15;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri15b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri15cチェック
	 *
	 *  TaskPri15c:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 15
	 *    inipri  : 15
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 15;
	vtsk.tm_inipri = 15;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON;
	vtsk.tm_actcnt = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;
	if (bootcnt <= 5) {
		vtsk.tm_porder = 2;
	}
	else {
		vtsk.tm_porder = 1;
	}

	ercd = AktspVerifyTask(TaskPri15c, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskResource3チェック
	 *
	 *  TaskResource3:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 14
	 *    inipri  : 7
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceA
	 *      - ResourceB
	 *      - ResourceC
	 *    getres  :
	 *      - ResourceA
	 *      - ResourceB
	 *      - ResourceC
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 14;
	vtsk.tm_inipri = 7;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 3;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskResource3, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskResource3, ResourceA);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskRelResource(TaskResource3, ResourceB);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskRelResource(TaskResource3, ResourceC);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskGetResource(TaskResource3, 1, ResourceA);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskGetResource(TaskResource3, 2, ResourceB);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskGetResource(TaskResource3, 3, ResourceC);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri14aチェック
	 *
	 *  TaskPri14a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 14
	 *    inipri  : 14
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceC
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 14;
	vtsk.tm_inipri = 14;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri14a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri14a, ResourceC);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri13aチェック
	 *
	 *  TaskPri13a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 13
	 *    inipri  : 13
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 13;
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri13a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri13bチェック
	 *
	 *  TaskPri13b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 13
	 *    inipri  : 13
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 13;
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri13b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri12aチェック
	 *
	 *  TaskPri12a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 12
	 *    inipri  : 12
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceB
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 12;
	vtsk.tm_inipri = 12;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri12a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri12a, ResourceB);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri12bチェック
	 *
	 *  TaskPri12b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 12
	 *    inipri  : 12
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 12;
	vtsk.tm_inipri = 12;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri12b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri12cチェック
	 *
	 *  TaskPri12c:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 12
	 *    inipri  : 12
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 3
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 12;
	vtsk.tm_inipri = 12;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri12c, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri11aチェック
	 *
	 *  TaskPri11a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 11
	 *    inipri  : 11
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 11;
	vtsk.tm_inipri = 11;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri11a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri10aチェック
	 *
	 *  TaskPri10a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 10
	 *    inipri  : 10
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 10;
	vtsk.tm_inipri = 10;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri10a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri10bチェック
	 *
	 *  TaskPri10b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 10
	 *    inipri  : 10
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 10;
	vtsk.tm_inipri = 10;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri10b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri9aチェック
	 *
	 *  TaskPri9a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 9
	 *    inipri  : 9
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 9;
	vtsk.tm_inipri = 9;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri9a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri9bチェック
	 *
	 *  TaskPri9b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 9
	 *    inipri  : 9
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHNON
	 *    actcnt  : 1
	 *    porder  : 2
	 *    relres  :
	 *      - ResourceA
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 9;
	vtsk.tm_inipri = 9;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHNON;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri9b, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri9b, ResourceA);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri8aチェック
	 *
	 *  TaskPri8a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 8
	 *    inipri  : 8
	 *    ttype   : AK_BASIC
	 *    maxact  : 3
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 3
	 *    porder  : 1
	 *    appmode :
	 *      - MainApp
	 *      - APPLICATION_MODE1
	 *      - APPLICATION_MODE2
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 8;
	vtsk.tm_inipri = 8;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 3;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 3;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri8a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskApplicationMode(TaskPri8a, MainApp);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskApplicationMode(TaskPri8a, APPLICATION_MODE1);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskApplicationMode(TaskPri8a, APPLICATION_MODE2);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri7aチェック
	 *
	 *  TaskPri7a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 7
	 *    inipri  : 7
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    relres  :
	 *      - ResourceInternal
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 7;
	vtsk.tm_inipri = 7;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri7a, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri7a, ResourceInternal);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri7bチェック
	 *
	 *  TaskPri7b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 7
	 *    inipri  : 7
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 7;
	vtsk.tm_inipri = 7;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri7b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskResource2チェック
	 *
	 *  TaskResource2:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 6
	 *    inipri  : 3
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceD
	 *      - ResourceE
	 *    getres  :
	 *      - ResourceD
	 *      - ResourceE
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 6;
	vtsk.tm_inipri = 3;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 2;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskResource2, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskResource2, ResourceD);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskRelResource(TaskResource2, ResourceE);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskGetResource(TaskResource2, 1, ResourceD);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskGetResource(TaskResource2, 2, ResourceE);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri6aチェック
	 *
	 *  TaskPri6a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 6
	 *    inipri  : 6
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 6;
	vtsk.tm_inipri = 6;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri6a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri6bチェック
	 *
	 *  TaskPri6b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 6
	 *    inipri  : 6
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceE
	 *    porder  : 3
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 6;
	vtsk.tm_inipri = 6;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri6b, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri6b, ResourceE);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri5aチェック
	 *
	 *  TaskPri5a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 5
	 *    inipri  : 5
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 5;
	vtsk.tm_inipri = 5;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri5a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri5bチェック
	 *
	 *  TaskPri5b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 5
	 *    inipri  : 5
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    relres  :
	 *      - ResourceInternal
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 5;
	vtsk.tm_inipri = 5;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri5b, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri7a, ResourceInternal);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskEventDEチェック
	 *
	 *  TaskEventDE:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 4
	 *    inipri  : 4
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    curevt  : (EventD | EventE)
	 *    actcnt  : 1
	 *    porder  : 1
	 *    relevt  :
	 *      - EventD
	 *      - EventE
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = (EventD | EventE);
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskEventDE, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelEvent(TaskEventDE, EventD);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskRelEvent(TaskEventDE, EventE);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri4aチェック
	 *
	 *  TaskPri4a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 4
	 *    inipri  : 4
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri4a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri4bチェック
	 *
	 *  TaskPri4b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 4
	 *    inipri  : 4
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceD
	 *    porder  : 3
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri4b, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskPri4b, ResourceD);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri3aチェック
	 *
	 *  TaskPri3a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 3
	 *    inipri  : 3
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 3;
	vtsk.tm_inipri = 3;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri3a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskResource1チェック
	 *
	 *  TaskResource1:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 2
	 *    inipri  : 1
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    relres  :
	 *      - ResourceF
	 *    getres  :
	 *      - ResourceF
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 2;
	vtsk.tm_inipri = 1;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 1;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskResource1, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelResource(TaskResource1, ResourceF);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskGetResource(TaskResource1, 1, ResourceF);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri2aチェック
	 *
	 *  TaskPri2a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 2
	 *    inipri  : 2
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 2;
	vtsk.tm_inipri = 2;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri2a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri2bチェック
	 *
	 *  TaskPri2b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 2
	 *    inipri  : 2
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 3
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 2;
	vtsk.tm_inipri = 2;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri2b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri1aチェック
	 *
	 *  TaskPri1a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 1
	 *    inipri  : 1
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 1;
	vtsk.tm_inipri = 1;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri1a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri1bチェック
	 *
	 *  TaskPri1b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 1
	 *    inipri  : 1
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 1;
	vtsk.tm_inipri = 1;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri1b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri0aチェック
	 *
	 *  TaskPri0a:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 0
	 *    inipri  : 0
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 1
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 0;
	vtsk.tm_inipri = 0;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri0a, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri0bチェック
	 *
	 *  TaskPri0b:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 0
	 *    inipri  : 0
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 2
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 0;
	vtsk.tm_inipri = 0;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri0b, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskPri0cチェック
	 *
	 *  TaskPri0c:
	 *    type    : TASK
	 *    tstat   : READY
	 *    curpri  : 0
	 *    inipri  : 0
	 *    ttype   : AK_BASIC
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    actcnt  : 1
	 *    porder  : 3
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 0;
	vtsk.tm_inipri = 0;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri0c, &vtsk);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskEventAチェック
	 *
	 *  TaskEventA:
	 *    type    : TASK
	 *    tstat   : WAITING
	 *    inipri  : 13
	 *    curpri  : 13
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    waievt  : EventA
	 *    relevt  :
	 *      - EventA
	 *    osap    : NON_TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = WAITING;
	vtsk.tm_curpri = 13;
	vtsk.tm_inipri = 13;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_waievt = EventA;
	vtsk.tm_curevt = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskEventA, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelEvent(TaskEventA, EventA);
	CheckErcd(E_OK, ercd);

	/*
	 *  TaskEventBCチェック
	 *
	 *  TaskEventBC:
	 *    type    : TASK
	 *    tstat   : WAITING
	 *    curpri  : 13
	 *    inipri  : 9
	 *    ttype   : AK_EXTENDED
	 *    maxact  : 1
	 *    spolicy : AK_SCHFULL
	 *    waievt  : EventB
	 *    curevt  : EventC
	 *    relevt  :
	 *      - EventB
	 *      - EventC
	 *    osap    : TRUSTED_OSAP1
	 */
	vtsk.tm_tstat = WAITING;
	vtsk.tm_curpri = 9;
	vtsk.tm_inipri = 9;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_waievt = EventB;
	vtsk.tm_curevt = EventC;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskEventBC, &vtsk);
	CheckErcd(E_OK, ercd);

	ercd = AktspVerifyTaskRelEvent(TaskEventBC, EventB);
	CheckErcd(E_OK, ercd);
	ercd = AktspVerifyTaskRelEvent(TaskEventBC, EventC);
	CheckErcd(E_OK, ercd);

	bootcnt++;

	return;
}

/*
 *  TaskEventDEを一度WAITINGにした後に，実行可能状態となった際の，porderを
 *  確認
 */
void
CheckPorderAfterRotate(void)
{
	StatusType		ercd;
	AktspTaskInfo	vtsk;

	AktspCheckPoint(38);

	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 1;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri4a, &vtsk);
	CheckErcd(E_OK, ercd);

	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_BASIC;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 2;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = NON_TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskPri4b, &vtsk);
	CheckErcd(E_OK, ercd);

	vtsk.tm_tstat = READY;
	vtsk.tm_curpri = 4;
	vtsk.tm_inipri = 4;
	vtsk.tm_ttype = AK_EXTENDED;
	vtsk.tm_maxact = 1;
	vtsk.tm_spolicy = AK_SCHFULL;
	vtsk.tm_curevt = EventD;
	vtsk.tm_actcnt = 1;
	vtsk.tm_porder = 3;
	vtsk.tm_getrescount = 0;
	vtsk.tm_stksz = AKTSP_TASK_STACK_SIZE;
	vtsk.tm_stk = NULL;
	vtsk.tm_sstksz = 0;
	vtsk.tm_sstk = NULL;
	vtsk.tm_osap = TRUSTED_OSAP1;

	ercd = AktspVerifyTask(TaskEventDE, &vtsk);
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
