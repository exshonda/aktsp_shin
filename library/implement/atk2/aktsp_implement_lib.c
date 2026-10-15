/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2015-2016 by Center for Embedded Computing Systems
 *             Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2015-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
 *  Copyright (C) 2015-2016 by eSOL Co.,Ltd., JAPAN
 *  Copyright (C) 2015-2016 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2015-2016 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2015-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2015-2016 by SCSK Corporation, JAPAN
 *  Copyright (C) 2015-2016 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2015-2016 by SUZUKI MOTOR CORPORATION
 *  Copyright (C) 2015-2016 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2015-2016 by Witz Corporation
 *  Copyright (C) 2015-2016 by Fujitsu TEN Limited
 *  Copyright (C) 2015-2016 by JTEKT CORPORATION
 * 
 *  本ソフトウェアは，車載制御システム向け高品質プラットフォームに
 *  関するコンソーシアム型共同研究において開発したものである．
 *  本ソフトウェアの著作権は，上記の著作権者に帰属する． 
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
 *  $Id: aktsp_implement_lib.c 1699 2016-02-04 08:27:41Z aisincom-nishioka $
 */

/*
 *  実装依存テストライブラリ
 */

#include "aktsp_common_lib.h"
#include "aktsp_target_lib.h"

#include "t_syslog.h"
#include "t_stdlib.h"
#include "sysmod/serial.h"
#include "kernel/task.h"
#include "kernel/resource.h"
#include "kernel/counter.h"
#include "kernel/alarm.h"
#include "kernel/interrupt.h"
#include "kernel/scheduletable.h"
#ifdef CFG_USE_SCALABILITYCLASS3
#include "kernel/osap.h"
#ifndef TotalNumberOfCores
#include "kernel/ioc_impl.h"
#include "Ioc.h"
#endif /* TotalNumberOfCores */
#endif /* CFG_USE_SCALABILITYCLASS3 */
#ifdef TotalNumberOfCores
#include "kernel/spinlock.h"
#include "kernel/ioc_impl.h"
#include "Ioc.h"
#endif /* TotalNumberOfCores */

#include "Os_Lcfg.h"

/*
 *  ALMCBからアラームIDを取り出すためのマクロ
 */
#ifndef TotalNumberOfCores
#define AK_ALMID(p_acb) ((AlarmType)((p_acb) - almcb_table))
#else
#define AK_ALMID(p_acb) ((AlarmType)(((p_acb)->p_alminib) - alminib_table))
#endif /* TotalNumberOfCores */
/*
 *  SCHTBLCBからスケジュールテーブルIDを取り出すためのマクロ
 */
#ifndef TotalNumberOfCores
#define AK_SCHTBID(p_schtblcb) ((ScheduleTableType)((p_schtblcb) - schtblcb_table))
#else
#define AK_SCHTBID(p_schtblcb) ((ScheduleTableType)(((p_schtblcb)->p_schtblinib) - schtblinib_table))
#endif /* TotalNumberOfCores */

/*
 *  指定した順番に獲得したリソースID[内部関数]
 */
static StatusType AktspGetOrderedResourceId(RESCB* p_lastres, uint32 Index, ResourceType ResID);

/*
 *  指定した順番に獲得したスピンロックID[内部関数]
 */
#ifdef TotalNumberOfCores
static StatusType AktspGetOrderedSpinlockId(SPNCB* p_lastspn, uint32 Index, SpinlockIdType SpnID);
#endif /* TotalNumberOfCores */


/*
 *  テストライブラリ初期化(実装依存部)
 */
void
AktspInitializeImplementTestLib(void)
{
#ifndef TotalNumberOfCores
	/* シングルコアの場合，ここで実行 */
	InitSerial();
#endif /* TotalNumberOfCores */
	AktspInitializeTargetTestLib();
}

#ifdef TotalNumberOfCores
/*
 *  各コアで実行するテストライブラリ初期化(実装依存部)
 */
void
AktspInitializeImplementTestLibEachCore(void)
{
	InitSerial();
	AktspInitializeTargetTestLibEachCore();
}
#endif /* TotalNumberOfCores */

/*
 *  ログ出力(書式指定子0)
 */
void
AktspOutputLog_0(const char8* Format)
{
	syslog_0(LOG_NOTICE, Format);
}

/*
 *  ログ出力(書式指定子1)
 */
void
AktspOutputLog_1(const char8* Format, sintptr Arg1)
{
	syslog_1(LOG_NOTICE, Format, Arg1);
}

/*
 *  ログ出力(書式指定子2)
 */
void
AktspOutputLog_2(const char8* Format, sintptr Arg1, sintptr Arg2)
{
	syslog_2(LOG_NOTICE, Format, Arg1, Arg2);
}

/*
 *  ログ出力(書式指定子3)
 */
void
AktspOutputLog_3(const char8* Format, sintptr Arg1, sintptr Arg2, sintptr Arg3)
{
	syslog_3(LOG_NOTICE, Format, Arg1, Arg2, Arg3);
}

/*
 *  ログ出力(書式指定子4)
 */
void
AktspOutputLog_4(const char8* Format, sintptr Arg1, sintptr Arg2, sintptr Arg3, sintptr Arg4)
{
	syslog_4(LOG_NOTICE, Format, Arg1, Arg2, Arg3, Arg4);
}

/*
 *  条件チェックのエラー処理
 */
void
_CheckAssert(const sint8 *expr, const char *file, sint32 line)
{
	AktspOutputLog_3("## Assertion `%s' failed at %s:%u.",
					 (const sintptr) expr, (const sintptr) file, line);
	cp_state = AK_FALSE;
	AktspShutdownOS();
}

/*
 *  エラーコードチェックのエラー処理
 */
void
_CheckErcd(StatusType ercd, const char *file, sint32 line)
{
	const char *strerr = NULL;

	strerr = atk2_strerror(ercd);
	AktspOutputLog_3("## Unexpected error %s detected at %s:%u.",
					 (const sintptr) strerr, (const sintptr) file, line);
	cp_state = AK_FALSE;
	AktspShutdownOS();
}

/*
 * エラーフックにおけるデバッグ用関数
 */
#ifdef CFG_USE_ERRORHOOK
void
AktspErrorHookDebug(StatusType Error)
{
	TaskType tskid;
	StatusType ercd;

	ercd = GetTaskID(&tskid);
	if (ercd == E_OK) {
		AktspOutputLog_1("GetTaskID: %d", (sintptr)tskid);
	}
	else {
		AktspOutputLog_0("GetTaskID is unavailable.");
	}
	AktspOutputLog_1("GetISRID: %d", (sintptr)GetISRID());

#if defined(CFG_USE_GETSERVICEID) && defined(CFG_USE_PARAMETERACCESS)

	switch (OSErrorGetServiceId()) {
	case OSServiceId_GetActiveApplicationMode:
		AktspOutputLog_1("Error:%s=GetActiveApplicationMode()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_StartOS:
		AktspOutputLog_2("Error:%s=StartOS(%d)", (sintptr)atk2_strerror(Error), OSError_StartOS_Mode());
		break;
	case OSServiceId_ActivateTask:
		AktspOutputLog_2("Error:%s=ActivateTask(%d)", (sintptr)atk2_strerror(Error), OSError_ActivateTask_TaskID());
		break;
	case OSServiceId_TerminateTask:
		AktspOutputLog_1("Error:%s=TerminateTask()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_ChainTask:
		AktspOutputLog_2("Error:%s=ChainTask(%d)", (sintptr)atk2_strerror(Error), OSError_ChainTask_TaskID());
		break;
	case OSServiceId_Schedule:
		AktspOutputLog_1("Error:%s=Schedule()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_GetTaskID:
		AktspOutputLog_2("Error:%s=GetTaskID(0x%p)", (sintptr)atk2_strerror(Error), (sintptr)OSError_GetTaskID_TaskID());
		break;
	case OSServiceId_GetTaskState:
		AktspOutputLog_3("Error:%s=GetTaskState(%d, 0x%p)", (sintptr)atk2_strerror(Error),
			OSError_GetTaskState_TaskID(), (sintptr)OSError_GetTaskState_State());
		break;
	case OSServiceId_EnableAllInterrupts:
		AktspOutputLog_1("Error:%s=EnableAllInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_DisableAllInterrupts:
		AktspOutputLog_1("Error:%s=DisableAllInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_ResumeAllInterrupts:
		AktspOutputLog_1("Error:%s=ResumeAllInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_SuspendAllInterrupts:
		AktspOutputLog_1("Error:%s=SuspendAllInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_ResumeOSInterrupts:
		AktspOutputLog_1("Error:%s=ResumeOSInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_SuspendOSInterrupts:
		AktspOutputLog_1("Error:%s=SuspendOSInterrupts()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_GetISRID:
		AktspOutputLog_1("Error:%s=GetISRID()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_SetEvent:
		AktspOutputLog_3("Error:%s=SetEvent(%d, 0x%x)", (sintptr)atk2_strerror(Error),
			OSError_SetEvent_TaskID(), OSError_SetEvent_Mask());
		break;
	case OSServiceId_ClearEvent:
		AktspOutputLog_2("Error:%s=ClearEvent(0x%x)", (sintptr)atk2_strerror(Error), OSError_ClearEvent_Mask());
		break;
	case OSServiceId_GetEvent:
		AktspOutputLog_3("Error:%s=GetEvent(%d, 0x%p)", (sintptr)atk2_strerror(Error),
			OSError_GetEvent_TaskID(), (sintptr)OSError_GetEvent_Event());
		break;
	case OSServiceId_WaitEvent:
		AktspOutputLog_2("Error:%s=WaitEvent(0x%x)", (sintptr)atk2_strerror(Error), OSError_WaitEvent_Mask());
		break;
	case OSServiceId_GetResource:
		AktspOutputLog_2("Error:%s=GetResource(%d)", (sintptr)atk2_strerror(Error), OSError_GetResource_ResID());
		break;
	case OSServiceId_ReleaseResource:
		AktspOutputLog_2("Error:%s=ReleaseResource(%d)", (sintptr)atk2_strerror(Error), OSError_ReleaseResource_ResID());
		break;
	case OSServiceId_IncrementCounter:
		AktspOutputLog_2("Error:%s=IncrementCounter(%d)", (sintptr)atk2_strerror(Error), OSError_IncrementCounter_CounterID());
		break;
	case OSServiceId_GetAlarmBase:
		AktspOutputLog_2("Error:%s=GetAlarmBase(0x%p)", (sintptr)atk2_strerror(Error), (sintptr)OSError_GetAlarmBase_AlarmID());
		break;
	case OSServiceId_GetAlarm:
		AktspOutputLog_3("Error:%s=GetAlarm(%d, 0x%p)", (sintptr)atk2_strerror(Error),
			OSError_GetAlarm_AlarmID(), (sintptr)OSError_GetAlarm_Tick());
		break;
	case OSServiceId_SetRelAlarm:
		AktspOutputLog_4("Error:%s=SetRelAlarm(%d, %d, %d)", (sintptr)atk2_strerror(Error),
			OSError_SetRelAlarm_AlarmID(), OSError_SetRelAlarm_increment(), OSError_SetRelAlarm_cycle());
		break;
	case OSServiceId_SetAbsAlarm:
		AktspOutputLog_4("Error:%s=SetAbsAlarm(%d, %d, %d)", (sintptr)atk2_strerror(Error),
			OSError_SetAbsAlarm_AlarmID(), OSError_SetAbsAlarm_start(), OSError_SetAbsAlarm_cycle());
		break;
	case OSServiceId_CancelAlarm:
		AktspOutputLog_2("Error:%s=CancelAlarm(%d)", (sintptr)atk2_strerror(Error), OSError_CancelAlarm_AlarmID());
		break;
	case OSServiceId_StartScheduleTableRel:
		AktspOutputLog_3("Error:%s=StartScheduleTableRel(%d, %d)", (sintptr)atk2_strerror(Error),
			OSError_StartScheduleTableRel_ScheduleTableID(), OSError_StartScheduleTableRel_Offset());
		break;
	case OSServiceId_StartScheduleTableAbs:
		AktspOutputLog_3("Error:%s=StartScheduleTableAbs(%d, %d)", (sintptr)atk2_strerror(Error),
			OSError_StartScheduleTableAbs_ScheduleTableID(), OSError_StartScheduleTableAbs_Start());
		break;
	case OSServiceId_StopScheduleTable:
		AktspOutputLog_2("Error:%s=StopScheduleTable(%d)", (sintptr)atk2_strerror(Error), OSError_StopScheduleTable_ScheduleTableID());
		break;
	case OSServiceId_NextScheduleTable:
		AktspOutputLog_3("Error:%s=NextScheduleTable(%d, %d)", (sintptr)atk2_strerror(Error),
			OSError_NextScheduleTable_ScheduleTableID_From(), OSError_NextScheduleTable_ScheduleTableID_To());
		break;
	case OSServiceId_GetScheduleTableStatus:
		AktspOutputLog_3("Error:%s=GetScheduleTableStatus(%d, 0x%p)", (sintptr)atk2_strerror(Error),
			OSError_GetScheduleTableStatus_ScheduleTableID(), (sintptr)OSError_GetScheduleTableStatus_ScheduleStatus());
		break;
	case OSServiceId_TaskMissingEnd:
		AktspOutputLog_1("Error:%s=TaskMissingEnd()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_ISRMissingEnd:
		AktspOutputLog_1("Error:%s=ISRMissingEnd()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_HookMissingEnd:
		AktspOutputLog_1("Error:%s=HookMissingEnd()", (sintptr)atk2_strerror(Error));
		break;

#if defined(CFG_USE_SCALABILITYCLASS3) || defined(TotalNumberOfCores)
	case OSServiceId_GetApplicationID:
		AktspOutputLog_1("Error:%s=GetApplicationID()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_CheckTaskOwnership:
		AktspOutputLog_2("Error:%s=CheckTaskOwnership(%d)", (sintptr)atk2_strerror(Error), OSError_CheckTaskOwnership_TaskID());
		break;
	case OSServiceId_CheckISROwnership:
		AktspOutputLog_2("Error:%s=CheckISROwnership(%d)", (sintptr)atk2_strerror(Error), OSError_CheckISROwnership_ISRID());
		break;
	case OSServiceId_CheckAlarmOwnership:
		AktspOutputLog_2("Error:%s=CheckAlarmOwnership(%d)", (sintptr)atk2_strerror(Error), OSError_CheckAlarmOwnership_AlarmID());
		break;
	case OSServiceId_CheckCounterOwnership:
		AktspOutputLog_2("Error:%s=CheckCounterOwnership(%d)", (sintptr)atk2_strerror(Error), OSError_CheckCounterOwnership_CounterID());
		break;
	case OSServiceId_CheckScheduleTableOwnership:
		AktspOutputLog_2("Error:%s=CheckScheduleTableOwnership(%d)", (sintptr)atk2_strerror(Error), OSError_CheckScheduleTableOwnership_ScheduleTableID());
		break;
	case IOCServiceId_IOC_Send:
		AktspOutputLog_3("Error:%s=IOC_Send() [IocId:%d] [SenderId:%d]", (sintptr)atk2_strerror(Error), OSError_IocSend_IocId(),
			OSError_IocSend_SenderId());
		break;
	case IOCServiceId_IOC_Write:
		AktspOutputLog_3("Error:%s=IOC_Write() [IocId:%d] [SenderId:%d]", (sintptr)atk2_strerror(Error), OSError_IocWrite_IocId(),
			OSError_IocWrite_SenderId());
		break;
	case IOCServiceId_IOC_SendGroup:
		AktspOutputLog_2("Error:%s=IOC_SendGroup() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocSend_IocId());
		break;
	case IOCServiceId_IOC_WriteGroup:
		AktspOutputLog_2("Error:%s=IOC_WriteGroup() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocSend_IocId());
		break;
	case IOCServiceId_IOC_Receive:
		AktspOutputLog_2("Error:%s=IOC_Receive() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocReceive_IocId());
		break;
	case IOCServiceId_IOC_Read:
		AktspOutputLog_2("Error:%s=IOC_Read() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocRead_IocId());
		break;
	case IOCServiceId_IOC_ReceiveGroup:
		AktspOutputLog_2("Error:%s=IOC_ReceiveGroup() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocReceive_IocId());
		break;
	case IOCServiceId_IOC_ReadGroup:
		AktspOutputLog_2("Error:%s=IOC_ReadGroup() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocRead_IocId());
		break;
	case IOCServiceId_IOC_EmptyQueue:
		AktspOutputLog_2("Error:%s=IOC_EmptyQueue() [IocId:%d]", (sintptr)atk2_strerror(Error), OSError_IocEmptyQueue_IocId());
		break;
#endif /* CFG_USE_SCALABILITYCLASS3 || TotalNumberOfCores */

#ifdef CFG_USE_SCALABILITYCLASS3
	case OSServiceId_GetCurrentApplicationID:
		AktspOutputLog_1("Error:%s=GetCurrentApplicationID()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_EnableInterruptSource:
		AktspOutputLog_2("Error:%s=EnableInterruptSource(%d)", (sintptr)atk2_strerror(Error), OSError_EnableInterruptSource_EnableISR());
		break;
	case OSServiceId_DisableInterruptSource:
		AktspOutputLog_2("Error:%s=DisableInterruptSource(%d)", (sintptr)atk2_strerror(Error), OSError_DisableInterruptSource_DisableISR());
		break;
	case OSServiceId_CallTrustedFunction:
		AktspOutputLog_3("Error:%s=CallTrustedFunction(%d, 0x%p)", (sintptr)atk2_strerror(Error), OSError_CallTrustedFunction_FunctionIndex(),
			(sintptr)OSError_CallTrustedFunction_FunctionParams());
		break;
	case OSServiceId_CheckISRMemoryAccess:
		AktspOutputLog_4("Error:%s=CheckISRMemoryAccess(%d, 0x%p, %d)", (sintptr)atk2_strerror(Error), OSError_CheckISRMemoryAccess_ISRID(),
			(sintptr)OSError_CheckISRMemoryAccess_Address(), OSError_CheckISRMemoryAccess_Size());
		break;
	case OSServiceId_CheckTaskMemoryAccess:
		AktspOutputLog_4("Error:%s=CheckTaskMemoryAccess(%d, 0x%p, %d)", (sintptr)atk2_strerror(Error), OSError_CheckTaskMemoryAccess_TaskID(),
			(sintptr)OSError_CheckTaskMemoryAccess_Address(), OSError_CheckTaskMemoryAccess_Size());
		break;
	case OSServiceId_CheckTaskAccess:
		AktspOutputLog_3("Error:%s=CheckTaskAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckTaskAccess_ApplID(),
			OSError_CheckTaskAccess_TaskID());
		break;
	case OSServiceId_CheckISRAccess:
		AktspOutputLog_3("Error:%s=CheckISRAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckISRAccess_ApplID(),
			OSError_CheckISRAccess_ISRID());
		break;
	case OSServiceId_CheckAlarmAccess:
		AktspOutputLog_3("Error:%s=CheckAlarmAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckAlarmAccess_ApplID(),
			OSError_CheckAlarmAccess_AlarmID());
		break;
	case OSServiceId_CheckResourceAccess:
		AktspOutputLog_3("Error:%s=CheckResourceAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckResourceAccess_ApplID(),
			OSError_CheckResourceAccess_ResID());
		break;
	case OSServiceId_CheckCounterAccess:
		AktspOutputLog_3("Error:%s=CheckCounterAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckCounterAccess_ApplID(),
			OSError_CheckCounterAccess_CounterID());
		break;
	case OSServiceId_CheckScheduleTableAccess:
		AktspOutputLog_3("Error:%s=CheckScheduleTableAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckScheduleTableAccess_ApplID(),
			OSError_CheckScheduleTableAccess_ScheduleTableID());
		break;
#ifdef TotalNumberOfCores
	case OSServiceId_CheckSpinlockAccess:
		AktspOutputLog_3("Error:%s=CheckSpinlockAccess(%d, %d)", (sintptr)atk2_strerror(Error), OSError_CheckSpinlockAccess_ApplID(),
			OSError_CheckSpinlockAccess_SpinlockId());
		break;
#endif /* TotalNumberOfCores */
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifndef TotalNumberOfCores

#ifdef CFG_USE_SCALABILITYCLASS3
	case OSServiceId_ShutdownOS:
		AktspOutputLog_2("Error:%s=ShutdownOS(%d)", (sintptr)atk2_strerror(Error), OSError_ShutdownOS_Error());
		break;
#else
	case OSServiceId_ShutdownOS:
		AktspOutputLog_1("Error:%s=ShutdownOS()", (sintptr)atk2_strerror(Error));
		break;
#endif /* CFG_USE_SCALABILITYCLASS3 */

#else

	case OSServiceId_StartCore:
		AktspOutputLog_1("Error:%s=StartCore()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_StartNonAutosarCore:
		AktspOutputLog_3("Error:%s=StartNonAutosarCore(%d, 0x%p)", (sintptr)atk2_strerror(Error), OSError_StartNonAutosarCore_CoreID(), (sintptr)OSError_StartNonAutosarCore_Status());
		break;
	case OSServiceId_ShutdownAllCores:
		AktspOutputLog_1("Error:%s=ShutdownAllCores()", (sintptr)atk2_strerror(Error));
		break;
	case OSServiceId_GetSpinlock:
		AktspOutputLog_2("Error:%s=GetSpinlock(%d)", (sintptr)atk2_strerror(Error), OSError_GetSpinlock_SpinlockId());
		break;
	case OSServiceId_ReleaseSpinlock:
		AktspOutputLog_2("Error:%s=ReleaseSpinlock(%d)", (sintptr)atk2_strerror(Error), OSError_ReleaseSpinlock_SpinlockId());
		break;
	case OSServiceId_TryToGetSpinlock:
		AktspOutputLog_3("Error:%s=TryToGetSpinlock(%d, 0x%p)", (sintptr)atk2_strerror(Error), OSError_TryToGetSpinlock_SpinlockId(), (sintptr)OSError_TryToGetSpinlock_Success());
		break;
	case OSServiceId_RaiseInterCoreInterrupt:
		AktspOutputLog_2("Error:%s=RaiseInterCoreInterrupt(%d)", (sintptr)atk2_strerror(Error), OSError_RaiseInterCoreInterrupt_ISRID());
		break;

#endif /* TotalNumberOfCores */

	default:
		AktspOutputLog_1("Error:%s=UnKnownFunc()", (sintptr)atk2_strerror(Error));
		break;
	}

#endif /* CFG_USE_GETSERVICEID && CFG_USE_PARAMETERACCESS */
}
#endif /* CFG_USE_ERRORHOOK */

/*
 * プロテクションフックにおけるデバッグ用関数
 */
void
AktspProtectionHookDebug(StatusType FatalError)
{
	TaskType tskid;
	StatusType ercd;

	ercd = GetTaskID(&tskid);
	if (ercd == E_OK) {
		AktspOutputLog_1("GetTaskID: %d", (sintptr)tskid);
	}
	else {
		AktspOutputLog_0("GetTaskID is unavailable.");
	}
	AktspOutputLog_1("GetISRID: %d", (sintptr)GetISRID());
	AktspOutputLog_1("GetFaultyContext: %d", GetFaultyContext());
	AktspOutputLog_1("FatalError:%s", (sintptr)atk2_strerror(FatalError));

	/* CPU例外などターゲット依存のデバッグ処理を行う */
	AktspProtectionHookTargetDebug(FatalError);
}


/*
 *  タスク
 */
StatusType
AktspVerifyTask(TaskType TaskID, const AktspTaskRefInfo TaskInfo)
{
	TCB				*p_tcb;          /* タスク管理の為のメモリ領域 */
	uint32			tskstat;         /* タスクの状態 */
	uint32			tstat;           /* 変換後のタスクの状態 */
	uint32			porder = 0U;     /* 同一優先度タスク内での優先順位(warning対策のため初期化) */
	QUEUE			*p_next = NULL;  /* キューのデータ */
	sint32			pri;             /* 優先度 */
	uint32			acnt;            /* 起動要求キューイング数 */
	uint32			maxactcnt;       /* 起動要求最大数 */
	RESCB			*p_rescb;        /* 最後に獲得したリソース管理の為のメモリ領域へのポインタ */
	uint32			getrescnt = 0U;  /* 獲得中リソース総数(内部リソースを除く)(warning対策のため初期化) */
	boolean			locked;          /* 割込み禁止状態 */
	StatusType		ercd = E_OK;     /* エラーコード */

	uint8			i;                      /* レディキュー操作用変数 */
#ifdef TotalNumberOfCores
	CCB				*p_ccb;                 /* コア管理の為のメモリ領域 */
	TCB				*p_runtsk;              /* 呼び出したコアの実行状態のタスク */
	TCB				*p_schedtsk;              /* 呼び出したコアの実行状態のタスク */
	QUEUE			ready_queue[TNUM_TPRI]; /* 呼び出したコアのレディキュー */
	uint16			callevel_stat;          /* 呼び出したコアの実行中のコンテキスト */
#endif /* TotalNumberOfCores */

#ifdef CFG_USE_SCALABILITYCLASS3
	MemorySizeType	stksz;   /* スタック領域のサイズ */
#endif /* CFG_USE_SCALABILITYCLASS3 */

#if defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)
	ApplicationType	osapid;  /* OSアプリケーションID */
#endif /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */

#ifdef OS_ATK2_SC3_TP
	TCB *p_schedtsk;
	QUEUE ready_queue[TNUM_TPRI];
#endif /* OS_ATK2_SC3_TP */

	locked = AktspDisInt();

	p_tcb = get_tcb(TaskID);

#ifdef TotalNumberOfCores
	p_ccb = p_tcb->p_tinib->p_ccb;
	p_runtsk = p_ccb->p_runtsk;
	p_schedtsk = p_ccb->p_schedtsk;
	callevel_stat = p_ccb->callevel_stat;
	for (i = 0; i < TNUM_TPRI; i++) {
		ready_queue[i] = p_ccb->ready_queue[i];
	}
	acquire_tsk_lock(p_ccb);
#endif /* TotalNumberOfCores */

#ifdef OS_ATK2_SC3_TP
	p_schedtsk = idle_scdcb.p_schedtsk;
	memcpy(ready_queue, idle_scdcb.ready_queue, sizeof(idle_scdcb.ready_queue));
#endif /* OS_ATK2_SC3_TP */

	/* パラメータチェック */
	/*
	 *  自動起動時用の状態を変換する
	 */
	switch (TaskInfo->tm_tstat) {
		case AK_AUTO_START:
			tstat = READY;
			break;
		case AK_NO_AUTO_START:
			tstat = SUSPENDED;
			break;
		case AK_END_SUSPENDED:
		case AK_END_OSAP_SUSPENDED:
			tstat = SUSPENDED;
			break;
		case AK_END_RUNNING:
		case AK_END_OSAP_RUNNING:
			tstat = RUNNING;
			break;
		case AK_END_READY:
		case AK_END_OSAP_READY:
			tstat = READY;
			break;
		case AK_END_WAITING:
		case AK_END_OSAP_WAITING:
			tstat = WAITING;
			break;
		default:
			tstat = TaskInfo->tm_tstat;
			break;
	}

	tskstat = (p_tcb == p_runtsk) ? RUNNING : p_tcb->tstat;
	if (tskstat != tstat) {
		AktspOutputLog_2("## Task tstat Error!! OS : %d, TESRY : %d.", tskstat, tstat);
		ercd = E_NOT_OK;
	}

	if (tstat == READY) {
		/*
		 *  同一優先度タスク内での優先順位
		 *  "MainTask"はカウント対象外とする
		 *  (MainTaskを使用しない場合は無視する)
		 */
		if (TaskInfo->tm_porder != 0U) {
#if defined(CFG_USE_SCALABILITYCLASS3) || defined(CFG_USE_SCALABILITYCLASS4)
			/*
			 * リスタートタスクが最高優先度の場合，
			 * 現在実行状態のタスクがレディキューにいるため，
			 * レディキューの位置をひとつずらす
			 */
			if ((p_schedtsk != NULL) && (p_runtsk != NULL) && (p_runtsk != p_schedtsk) &&
					(p_runtsk->curpri == p_tcb->curpri)) {
				for (i = 0U; i < tnum_osap; i++) {
					if (osapinib_table[i].p_restart_tcb == p_schedtsk) {
						syslog(LOG_EMERG, "tm_porder=%d", TaskInfo->tm_porder);
						TaskInfo->tm_porder += 1;
					}
				}
			}
#endif /*defined(CFG_USE_SCALABILITYCLASS3) || defined(CFG_USE_SCALABILITYCLASS4)*/
			
			p_next = ready_queue[p_tcb->curpri].p_next;
			do {
#ifdef MainTask
				if (TSKID(((TCB *)p_next)) != MainTask) {
					porder++;
				}
#endif /* MainTask */
				if (TSKID(((TCB *)p_next)) == TaskID) {
					break;
				}
				p_next = p_next->p_next;
			} while (&ready_queue[p_tcb->curpri] != p_next);

			if ((callevel_stat & TCL_PREPOST) != 0U) {
				if ((TaskInfo->tm_porder != porder) && ((TaskInfo->tm_porder - 1U) != porder)) {
					AktspOutputLog_2("## Task porder Error!! OS : %d, TESRY : %d.",
									 porder, TaskInfo->tm_porder);
					ercd = E_NOT_OK;
				}
			}
			else {
				if (TaskInfo->tm_porder != porder) {
					AktspOutputLog_2("## Task porder Error!! OS : %d, TESRY : %d.",
									 porder, TaskInfo->tm_porder);
					ercd = E_NOT_OK;
				}
			}
		}
	}

	/* TaskIDが拡張タスク数(tnum_exttask)未満の場合は拡張タスク，それ以外は基本タスクとなる */
	if (TaskID < tnum_exttask) {
		if (TaskInfo->tm_ttype != AK_EXTENDED) {
			AktspOutputLog_2("## Task ttype Error!! OS : %d, TESRY : %d.",
							 AK_EXTENDED, TaskInfo->tm_ttype);
			ercd = E_NOT_OK;
		}

		if (TaskInfo->tm_curevt != p_tcb->curevt) {
			AktspOutputLog_2("## Task curevt Error!! OS : 0x%x, TESRY : 0x%x.",
							 p_tcb->curevt, TaskInfo->tm_curevt);
			ercd = E_NOT_OK;
		}

		if (tstat == WAITING) {
			if (TaskInfo->tm_waievt != p_tcb->waievt) {
				AktspOutputLog_2("## Task waievt Error!! OS : 0x%x, TESRY : 0x%x.",
								 p_tcb->waievt, TaskInfo->tm_waievt);
				ercd = E_NOT_OK;
			}
		}
	}
	else {
		if (TaskInfo->tm_ttype != AK_BASIC) {
			AktspOutputLog_2("## Task ttype Error!! OS : %d, TESRY : %d.",
							 AK_BASIC, TaskInfo->tm_ttype);
			ercd = E_NOT_OK;
		}
	}

	if ((tstat == RUNNING) || (tstat == READY)) {
		acnt = (uint32) (p_tcb->actcnt + 1U);
		if (TaskInfo->tm_actcnt != acnt) {
			AktspOutputLog_2("## Task actcnt Error!! OS : %d, TESRY : %d.",
							 acnt, TaskInfo->tm_actcnt);
			ercd = E_NOT_OK;
		}

		/* 最後に獲得したリソース管理ブロックへのポインタを利用し，リソース獲得数を確認する */
		p_rescb = p_tcb->p_lastrescb;
		while (p_rescb != NULL) {
			if (p_rescb->lockflg == AK_TRUE) {
				getrescnt++;
			}
			else {
				break;
			}
			p_rescb = p_rescb->p_prevrescb;
		}
		if (TaskInfo->tm_getrescount != getrescnt) {
			AktspOutputLog_2("## Task getrescnt Error!! OS : %d, TESRY : %d.",
							 getrescnt, TaskInfo->tm_getrescount);
			ercd = E_NOT_OK;
		}
	}

	maxactcnt = (uint32) (p_tcb->p_tinib->maxact + 1U);
	if (TaskInfo->tm_maxact != maxactcnt) {
		AktspOutputLog_2("## Task maxact Error!! OS : %d, TESRY : %d.",
						 maxactcnt, TaskInfo->tm_maxact);
		ercd = E_NOT_OK;
	}

	pri = TMAX_TPRI - (p_tcb->p_tinib->inipri);
	if (TaskInfo->tm_inipri != pri) {
		AktspOutputLog_2("## Task inipri Error!! OS : %d, TESRY : %d.",
						 pri, TaskInfo->tm_inipri);
		ercd = E_NOT_OK;
	}

	if (TaskInfo->tm_spolicy == AK_SCHFULL) {
		if ((tstat == RUNNING) || (tstat == READY) || (tstat == WAITING)) {
			pri = TMAX_TPRI - (p_tcb->curpri);
			if (TaskInfo->tm_curpri != pri) {
				AktspOutputLog_2("## Task curpri Error!! OS : %d, TESRY : %d.",
								 pri, TaskInfo->tm_curpri);
				ercd = E_NOT_OK;
			}
		}
	}
	else {
		if ((tstat == READY) || (tstat == WAITING)) {
			pri = TMAX_TPRI - (p_tcb->curpri);
			if (TaskInfo->tm_curpri != pri) {
				AktspOutputLog_2("## Task curpri Error!! OS : %d, TESRY : %d.",
								 pri, TaskInfo->tm_curpri);
				ercd = E_NOT_OK;
			}
		}
		if (p_tcb->tstat == RUNNING) {
			if (p_tcb->curpri != 0) {
				AktspOutputLog_1("## Task of running and non preemptive scheduling is not highest priority.[%d]",
								 p_tcb->curpri);
				ercd = E_NOT_OK;
			}
		}

		/*
		 *  スケジューリングポリシ
		 *  ATK2では，ノンプリエンティブ，フルプリエンティブの判別処理を行っていない．
		 *  ノンプリエンティブの場合は優先度が絶対0となるため，ここでは，その判定のみ行う
		 */
		if (p_tcb->p_tinib->exepri != 0) {
			AktspOutputLog_1("## Task is non preemptive scheduling, Priority at startup is not highest priority.[%d]",
							 p_tcb->p_tinib->exepri);
			ercd = E_NOT_OK;
		}
	}

#if defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)
#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_tcb->p_tinib->p_osapcb);
#else
	osapid = OSAPID(p_tcb->p_tinib->p_osapinib);
#endif /* CFG_USE_SCALABILITYCLASS3 */
	if (TaskInfo->tm_osap != osapid) {
		AktspOutputLog_2("## Task osap Error!! OS : %d, TESRY : %d.",
						 osapid, TaskInfo->tm_osap);
		ercd = E_NOT_OK;
	}
#endif /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */

#ifndef USE_TSKINICTXB
#ifdef CFG_USE_SCALABILITYCLASS1
	if (TaskInfo->tm_stksz != p_tcb->p_tinib->stksz) {
		AktspOutputLog_2("## Task stksz Error!! OS : %d, TESRY : %d.",
								 p_tcb->p_tinib->stksz, TaskInfo->tm_stksz);
		ercd = E_NOT_OK;
	}

	if (TaskInfo->tm_stk != NULL) {
		if (TaskInfo->tm_stk != p_tcb->p_tinib->stk) {
			AktspOutputLog_2("## Task stk Error!! OS : 0x%x, TESRY : 0x%x.",
						 (sintptr)p_tcb->p_tinib->stk, (const sintptr)TaskInfo->tm_stk);
			ercd = E_NOT_OK;
		}
	}
#endif /* CFG_USE_SCALABILITYCLASS1 */
#ifdef CFG_USE_SCALABILITYCLASS3
	/* 信頼OSAPに所属するタスクの場合 */
	if (p_tcb->p_tinib->p_osapcb->p_osapinib->osap_trusted == TA_TRUSTED) {
		/* スタックサイズとシステムスタックサイズの合計値をスタックサイズとする */
		stksz = p_tcb->p_tinib->ustksz + p_tcb->p_tinib->sstksz;
		if (TaskInfo->tm_stksz != stksz) {
			AktspOutputLog_2("## Task sstksz Error!! OS : %d, TESRY : %d.",
													 stksz, TaskInfo->tm_sstksz);
			ercd = E_NOT_OK;
		}

		/* NULLの場合は，コンフィギュレータが任意のアドレスを設定するため，確認を行わない */
		if (TaskInfo->tm_stk != NULL) {
			if (TaskInfo->tm_stk != p_tcb->p_tinib->sstk) {
				AktspOutputLog_2("## Task sstk Error!! OS : 0x%x, TESRY : 0x%x.",
									(sintptr)p_tcb->p_tinib->sstk, (const sintptr)TaskInfo->tm_stk);
				ercd = E_NOT_OK;
			}
		}
	}
	/* 非信頼OSAPに所属するタスクの場合 */
	else {
		if (TaskInfo->tm_stksz != p_tcb->p_tinib->ustksz) {
			AktspOutputLog_2("## Task stksz Error!! OS : %d, TESRY : %d.",
									 p_tcb->p_tinib->ustksz, TaskInfo->tm_stksz);
			ercd = E_NOT_OK;
		}

		if (TaskInfo->tm_stk != NULL) {
			if (TaskInfo->tm_stk != p_tcb->p_tinib->ustk) {
				AktspOutputLog_2("## Task stk Error!! OS : 0x%x, TESRY : 0x%x.",
							 (sintptr)p_tcb->p_tinib->ustk, (const sintptr)TaskInfo->tm_stk);
				ercd = E_NOT_OK;
			}
		}

		if (TaskInfo->tm_sstksz != p_tcb->p_tinib->sstksz) {
			AktspOutputLog_2("## Task sstksz Error!! OS : %d, TESRY : %d.",
									 p_tcb->p_tinib->sstksz, TaskInfo->tm_sstksz);
			ercd = E_NOT_OK;
		}

		/* NULLの場合は，コンフィギュレータが任意のアドレスを設定するため，確認を行わない */
		if (TaskInfo->tm_sstk != NULL) {
			if (TaskInfo->tm_sstk != p_tcb->p_tinib->sstk) {
				AktspOutputLog_2("## Task sstk Error!! OS : 0x%x, TESRY : 0x%x.",
								(sintptr)p_tcb->p_tinib->sstk, (const sintptr)TaskInfo->tm_sstk);
				ercd = E_NOT_OK;
			}
		}
	}
#endif /* CFG_USE_SCALABILITYCLASS3 */
#endif /* USE_TSKINICTXB */

#ifdef TotalNumberOfCores
	release_tsk_lock(p_ccb);
#endif /* TotalNumberOfCores */

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *	タスクとリソースの関連づけ
 */
StatusType
AktspVerifyTaskRelResource(TaskType TaskID, ResourceType ResID)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

/*
 *	タスクとイベントの関連づけ
 */
StatusType
AktspVerifyTaskRelEvent(TaskType TaskID, EventMaskType Mask)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

/*
 *  タスクが獲得中のリソース(内部リソース以外)
 */
StatusType
AktspVerifyTaskGetResource(TaskType TaskID, uint32 Index, ResourceType ResID)
{
	TCB			*p_tcb;         /* タスク管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */
#ifdef TotalNumberOfCores
	CCB			*p_ccb;         /* コア管理の為のメモリ領域 */
#endif /* TotalNumberOfCores */

	locked = AktspDisInt();

	p_tcb = get_tcb(TaskID);

#ifdef TotalNumberOfCores
	p_ccb = p_tcb->p_tinib->p_ccb;
	acquire_tsk_lock(p_ccb);
#endif /* TotalNumberOfCores */

	/* パラメータチェック */
	/* 指定した順番にリソースを獲得しているかを確認する */
	ercd = AktspGetOrderedResourceId(p_tcb->p_lastrescb, Index, ResID);

#ifdef TotalNumberOfCores
	release_tsk_lock(p_ccb);
#endif /* TotalNumberOfCores */

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *	タスクが獲得中の内部リソース
 */
StatusType
AktspVerifyTaskGetInternalResource(TaskType TaskID, ResourceType ResID)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  タスクにアクセス可能な非信頼OSアプリケーション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyTaskAccessOsap(TaskType TaskID, ApplicationType OsapID)
{
	TCB				*p_tcb;         /* タスク管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_tcb = get_tcb(TaskID);
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_tcb->p_tinib->acsbtmp)) == 0) {
			AktspOutputLog_2("## Task accosap Error!! Task btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_tcb->p_tinib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## Task accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  タスクのアプリケーションモード
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyTaskApplicationMode(TaskType TaskID, AppModeType Mode)
{
	TCB			*p_tcb;         /* タスク管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_tcb = get_tcb(TaskID);

	/* パラメータチェック */
	if ((p_tcb->p_tinib->autoact & ((uint32)1U << Mode)) == APPMODE_NONE) {
		AktspOutputLog_2("## Task appmode Error!! OS : 0x%x, TESRY : 0x%x.",
									 p_tcb->p_tinib->autoact, ((uint32)1U << Mode));
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}


/*
 *	リソース
 */
StatusType
AktspVerifyResource(ResourceType ResID, const AktspResourceRefInfo ResInfo)
{
	RESCB		*p_rescb;    /* リソース管理の為のメモリ領域 */
	boolean		locked;      /* 割込み禁止状態 */
	StatusType	ercd = E_OK; /* エラーコード */

	locked = AktspDisInt();

	p_rescb = get_rescb(ResID);

	/* パラメータチェック */
	/* ResIDが内部リソースを除くリソース数(tnum_stdresource)以上であれば内部リソースとなる */
	if (tnum_stdresource <= ResID) {
		if (ResInfo->rm_resprop != AK_INTERNAL) {
			AktspOutputLog_2("## Resource resprop Error!! OS : %d, TESRY : %d.",
							 AK_INTERNAL, ResInfo->rm_resprop);
			ercd = E_NOT_OK;
		}
	}
	else {
		if (ResInfo->rm_lockflg != p_rescb->lockflg) {
			AktspOutputLog_2("## Resource lockflg Error!! OS : %d, TESRY : %d.",
							 p_rescb->lockflg, ResInfo->rm_lockflg);
			ercd = E_NOT_OK;
		}
	}

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  リソースにアクセス可能な非信頼OSアプリケーション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyResourceAccessOsap(ResourceType ResID, ApplicationType OsapID)
{
	RESCB			*p_rescb;       /* リソース管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_rescb = get_rescb(ResID);
	p_osapinib = get_osapinib(OsapID);

	if (tnum_stdresource > ResID) {
		/* パラメータチェック */
		if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
			if (((p_osapinib->btptn) & (p_rescb->p_resinib->acsbtmp)) == 0) {
				AktspOutputLog_2("## Resource accosap Error!! Resource btptn : 0x%x, Osap acsbtmp : 0x%x.",
								 p_osapinib->btptn, p_rescb->p_resinib->acsbtmp);
				ercd = E_NOT_OK;
			}
		}
		else {
			AktspOutputLog_1("## Resource accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
			ercd = E_NOT_OK;
		}
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  C1ISR
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyC1Isr(ISRType IsrID, const AktspISRRefInfo ISRInfo)
{
	StatusType		ercd = E_OK;    /* エラーコード */
	sint32			intpri;         /* 初期の割込み優先度 */
	AttributeType	intatr;         /* 割込み属性 */
	ISRType			isrid;          /* ISRID */

#ifdef TotalNumberOfCores
	/* 
	 * ISRIDは，C2ISR-ICISR-C1ISRの順番で定義される
	 * intinib_tableには，ICISRの情報は含まれていないため，ISRIDからICISRを除く
	 */
	if (IsrID >= tnum_isr2) {
		/* C1ISRの場合 */
		isrid = IsrID - tnum_ici;
	}
	else {
		/* C2ISRの場合(C2ISRでもこの関数は使用するため) */
		isrid = IsrID;
	}
#else
	/* 変更なし */
	isrid = IsrID;
#endif /* TotalNumberOfCores */

	if (intinib_table[isrid].intno != ISRInfo->im_intno) {
		AktspOutputLog_2("## ISR intno Error!! OS : %d, TESRY : %d.",
						 intinib_table[isrid].intno, ISRInfo->im_intno);
		ercd = E_NOT_OK;
	}

	if (intinib_table[isrid].intatr == ENABLE) {
		intatr = AK_ENABLE;
	}
	else {
		intatr = AK_DISABLE;
	}
	if (intatr != ISRInfo->im_intatr) {
		AktspOutputLog_2("## ISR intatr Error!! OS : %d, TESRY : %d.",
						 intatr, ISRInfo->im_intatr);
		ercd = E_NOT_OK;
	}

	intpri = (-1) * (intinib_table[isrid].intpri);
	if (intpri != ISRInfo->im_iniintpri) {
		AktspOutputLog_2("## ISR intpri Error!! OS : %d, TESRY : %d.",
						 intpri, ISRInfo->im_iniintpri);
		ercd = E_NOT_OK;
	}
	return(ercd);
}

/*
 *  C2ISR
 */
StatusType
AktspVerifyC2Isr(ISRType IsrID, const AktspISRRefInfo ISRInfo)
{
	ISRCB			*p_isrcb;       /* C2ISRの管理の為のメモリ領域 */
	sint32			iniintpri;      /* 初期の割込み優先度 */
	sint32			curintpri;      /* 現在の割込み優先度 */
	RESCB			*p_rescb;       /* 最後に獲得したリソース管理の為のメモリ領域へのポインタ */
	uint32			getrescnt = 0U; /* 獲得中リソース総数(内部リソースを除く)(warning対策のため初期化) */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */
#if defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)
	ApplicationType	osapid;         /* OSアプリケーションID */
#endif /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */

	locked = AktspDisInt();

#ifndef TotalNumberOfCores
	p_isrcb = &(isrcb_table[IsrID]);
#else
	p_isrcb = p_isrcb_table[IsrID];
#endif /* TotalNumberOfCores */

	/* intinib_tableの内容はC1ISR用の関数を流用して確認する */
	ercd = AktspVerifyC1Isr(IsrID, ISRInfo);

	/* パラメータチェック */
#if defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)
	iniintpri = (-1) * (p_isrcb->p_isrinib->p_intinib->intpri);
#else /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */
	iniintpri = (-1) * (p_isrcb->p_intinib->intpri);
#endif /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */
	if (ISRInfo->im_iniintpri != iniintpri) {
		AktspOutputLog_2("## C2ISR iniintpri Error!! OS : %d, TESRY : %d.",
						 iniintpri, ISRInfo->im_iniintpri);
		ercd = E_NOT_OK;
	}

	/* 最後に獲得したリソース管理ブロックへのポインタを利用し，リソース獲得数を確認する */
	p_rescb = p_isrcb->p_lastrescb;
	while (p_rescb != NULL) {
		if (p_rescb->lockflg == AK_TRUE) {
			getrescnt++;
		}
		else {
			break;
		}
		p_rescb = p_rescb->p_prevrescb;
	}
	if (ISRInfo->im_getrescount != getrescnt) {
		AktspOutputLog_2("## C2ISR getrescnt Error!! OS : %d, TESRY : %d.",
						 getrescnt, ISRInfo->im_getrescount);
		ercd = E_NOT_OK;
	}

	/*
	 *  割込み優先度
	 *  リソースを取得している場合，割込み優先度が初期優先度から変更されるため，確認を行う
	 */
	if ((ISRInfo->im_getrescount > 0U) && (ISRInfo->im_rtnstat == AK_ACTIVATE)) {
		/*
		 *  割込み優先度マスクがOS割込み禁止の場合のみ参照可能なため，
		 *  OS割込み禁止状態にする
		 */
		x_nested_lock_os_int();
#ifdef OS_ATK2_SC4
		if (sus_os_cnt == 0) { 
			curintpri = (-1) * (x_get_ipm());
		}
		else {
			curintpri = (-1) * sus_os_prevpri;
		}
#else
		curintpri = (-1) * (x_get_ipm());
#endif
		if (ISRInfo->im_curintpri != curintpri) {
			AktspOutputLog_2("## C2ISR curintpri Error!! OS : %d, TESRY : %d.",
							 curintpri, ISRInfo->im_curintpri);
			ercd = E_NOT_OK;
		}
		x_nested_unlock_os_int();
	}

#if defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)
	if (ISRInfo->im_intno != p_isrcb->p_isrinib->p_intinib->intno) {
		AktspOutputLog_2("## C2ISR intno Error!! OS : %d, TESRY : %d.",
						 p_isrcb->p_isrinib->p_intinib->intno, ISRInfo->im_intno);
		ercd = E_NOT_OK;
	}

#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_isrcb->p_isrinib->p_osapcb);
#else
	osapid = OSAPID(p_isrcb->p_isrinib->p_osapinib);
#endif /* CFG_USE_SCALABILITYCLASS3 */
	if (ISRInfo->im_osap != osapid) {
		AktspOutputLog_2("## C2ISR osap Error!! OS : %d, TESRY : %d.",
						 osapid, ISRInfo->im_osap);
		ercd = E_NOT_OK;
	}
#endif /* TotalNumberOfCores || CFG_USE_SCALABILITYCLASS3 */

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *	C2ISRの関連づけされたリソース
 */
StatusType
AktspVerifyC2IsrRelResource(ISRType IsrID, ResourceType ResID)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

/*
 *	C2ISRが獲得中のリソース
 */
StatusType
AktspVerifyC2IsrGetResource(ISRType IsrID, uint32 Index, ResourceType ResID)
{
	ISRCB		*p_isrcb;       /* C2ISRの管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

#ifndef TotalNumberOfCores
	p_isrcb = &(isrcb_table[IsrID]);
#else
	p_isrcb = p_isrcb_table[IsrID];
#endif /* TotalNumberOfCores */

	/* パラメータチェック */
	ercd = AktspGetOrderedResourceId(p_isrcb->p_lastrescb, Index, ResID);

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  C2ISRにアクセス可能な非信頼OSアプリケーション
 */
StatusType
AktspVerifyC2IsrAccessOsap(ISRType IsrID, ApplicationType OsapID)
{
	ISRCB			*p_isrcb;       /* C2ISRの管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

#ifndef TotalNumberOfCores
	p_isrcb = &(isrcb_table[IsrID]);
#else
	p_isrcb = p_isrcb_table[IsrID];
#endif /* TotalNumberOfCores */
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_isrcb->p_isrinib->acsbtmp)) == 0) {
			AktspOutputLog_2("## C2ISR accosap Error!! C2ISR btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_isrcb->p_isrinib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## C2ISR accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *	割込み禁止状態
 */
StatusType
AktspVerifyIntState(const AktspIntStateRefInfo IntStateInfo)
{
	uint8		int_sts;        /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

#ifdef TotalNumberOfCores
	CCB			*p_ccb;         /* コア管理の為のメモリ領域 */
	uint16		callevel_stat;
	uint8		sus_all_cnt;
	uint8		sus_os_cnt;

	p_ccb = get_my_p_ccb();
	callevel_stat = p_ccb->callevel_stat;
	sus_all_cnt = p_ccb->sus_all_cnt;
	sus_os_cnt = p_ccb->sus_os_cnt;
#endif /* TotalNumberOfCores */

	/*
	 * 割込み禁止状態をチェックするため，本関数では割込み禁止にしない
	 */

	/* パラメータチェック */
	if ((callevel_stat & TSYS_DISALLINT) != 0U) {
		int_sts = AK_DISABLE;
	}
	else {
		int_sts = AK_ENABLE;
	}
	if (IntStateInfo->ism_disallint != int_sts) {
		AktspOutputLog_2("## IntState disallint Error!! OS : %d, TESRY : %d.",
						 int_sts, IntStateInfo->ism_disallint);
		ercd = E_NOT_OK;
	}

	if ((callevel_stat & TSYS_SUSALLINT) != 0U) {
		int_sts = AK_DISABLE;
	}
	else {
		int_sts = AK_ENABLE;
	}
	if (IntStateInfo->ism_susallint != int_sts) {
		AktspOutputLog_2("## IntState susallint Error!! OS : %d, TESRY : %d.",
						 int_sts, IntStateInfo->ism_susallint);
		ercd = E_NOT_OK;
	}

	if ((callevel_stat & TSYS_SUSOSINT) != 0U) {
		int_sts = AK_DISABLE;
	}
	else {
		int_sts = AK_ENABLE;
	}
	if (IntStateInfo->ism_susosint != int_sts) {
		AktspOutputLog_2("## IntState susosint Error!! OS : %d, TESRY : %d.",
						 int_sts, IntStateInfo->ism_susosint);
		ercd = E_NOT_OK;
	}

	if (IntStateInfo->ism_susallcnt != sus_all_cnt) {
		AktspOutputLog_2("## IntState susallcnt Error!! OS : %d, TESRY : %d.",
						 sus_all_cnt, IntStateInfo->ism_susallcnt);
		ercd = E_NOT_OK;
	}

	if (IntStateInfo->ism_susoscnt != sus_os_cnt) {
		AktspOutputLog_2("## IntState susoscnt Error!! OS : %d, TESRY : %d.",
						 sus_os_cnt, IntStateInfo->ism_susoscnt);
		ercd = E_NOT_OK;
	}

	return(ercd);
}

/*
 *	割込み禁止操作の順番
 */
StatusType
AktspVerifyDisIntOrder(uint32 Index, uint8 State)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

/*
 *	カウンタ
 */
StatusType
AktspVerifyCounter(CounterType CounterID, const AktspCounterRefInfo CounterInfo)
{
	CNTCB			*p_cntcb;       /* カウンタ管理の為のメモリ領域 */
	TickType		cntval;         /* カウンタの現在値 */
	TickType		hwcurval;       /* ハードウェアカウンタの現在値 */
	uint8			cstat;          /* カウンタの状態 */
	uint32			nanotick;       /* HWCNTの1ティックの重み(ns単位) */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */
#ifdef CFG_USE_SCALABILITYCLASS3
	ApplicationType	osapid;         /* OSアプリケーションID */
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
	CCB			*p_ccb;         /* コア管理の為のメモリ領域 */
	uint16		callevel_stat;
	CoreIdType	coreid;
#endif /* TotalNumberOfCores */

	locked = AktspDisInt();

	p_cntcb = get_cntcb(CounterID);

#ifdef TotalNumberOfCores
	p_ccb = get_my_p_ccb();
	callevel_stat = p_ccb->callevel_stat;
	coreid = p_ccb->coreid;
	acquire_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	/* パラメータチェック */
	/* ハードウェアカウンタの場合 */
	if (CounterID < tnum_hardcounter) {
		if (CounterInfo->cm_ctype != AK_HARDWARE) {
			AktspOutputLog_2("## Counter ctype Error!! OS : %d, TESRY : %d.",
							 AK_HARDWARE, CounterInfo->cm_ctype);
			ercd = E_NOT_OK;
		}

		nanotick = (const uint32)CounterInfo->cm_secondspertick;
		nanotick = nanotick * 1000000000U;
		if (nanotick != hwcntinib_table[CounterID].nspertick) {
			AktspOutputLog_2("## Counter secondspertick Error!! OS : %d, TESRY : %d.",
							 hwcntinib_table[CounterID].nspertick/1000000000, CounterInfo->cm_secondspertick);
		}

		hwcurval = hwcntinib_table[CounterID].get();
		/* ATK2では，カウンタ値を最大値の2周期分(最大値の2倍＋1)まで管理している */
		if (p_cntcb->p_cntinib->maxval < hwcurval) {
			hwcurval = hwcurval - (p_cntcb->p_cntinib->maxval + 1U);
		}
		if (CounterInfo->cm_curval != hwcurval) {
			AktspOutputLog_2("## Counter curval Error!! OS : %d, TESRY : %d.",
							 hwcurval, CounterInfo->cm_curval);
			ercd = E_NOT_OK;
		}
	}
	/* ソフトウェアカウンタの場合 */
	else {
		if (CounterInfo->cm_ctype != AK_SOFTWARE) {
			AktspOutputLog_2("## Counter ctype Error!! OS : %d, TESRY : %d.",
							 AK_SOFTWARE, CounterInfo->cm_ctype);
			ercd = E_NOT_OK;
		}

		/* ATK2では，カウンタ値を最大値の2周期分(最大値の2倍＋1)まで管理している */
		if (p_cntcb->p_cntinib->maxval < p_cntcb->curval) {
			cntval = p_cntcb->curval - (p_cntcb->p_cntinib->maxval + 1U);
		}
		else {
			cntval = p_cntcb->curval;
		}
		if (CounterInfo->cm_curval != cntval) {
			AktspOutputLog_2("## Counter curval Error!! OS : %d, TESRY : %d.",
							 cntval, CounterInfo->cm_curval);
			ercd = E_NOT_OK;
		}

		if (CounterInfo->cm_cstat == AK_CS_ERROR) {
			if ((callevel_stat & TCL_ERROR) != 0U) {
				/* IncrementCounterでエラーが発生した場合，エラーフックが起動するため，カウンタはAK_CS_DOINGになる */
				cstat = AK_CS_DOING;
			}
			else {
				/* IncrementCounterでエラーが発生し，エラーフックがない場合，カウンタはAK_CS_NULLにになる */
				cstat = AK_CS_NULL;
			}
		}
		else {
			cstat = CounterInfo->cm_cstat;
		}
		if (cstat != p_cntcb->cstat) {
			AktspOutputLog_2("## Counter cstat Error!! OS : %d, TESRY : %d.",
							 p_cntcb->cstat, cstat);
			ercd = E_NOT_OK;
		}
	}

	if (CounterInfo->cm_mincyc != p_cntcb->p_cntinib->mincyc) {
		AktspOutputLog_2("## Counter mincyc Error!! OS : %d, TESRY : %d.",
						 p_cntcb->p_cntinib->mincyc, CounterInfo->cm_mincyc);
		ercd = E_NOT_OK;
	}

	if (CounterInfo->cm_maxval != p_cntcb->p_cntinib->maxval) {
		AktspOutputLog_2("## Counter maxval Error!! OS : %d, TESRY : %d.",
						 p_cntcb->p_cntinib->maxval, CounterInfo->cm_maxval);
		ercd = E_NOT_OK;
	}

#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_cntcb->p_cntinib->p_osapcb);
	if (CounterInfo->cm_osap != osapid) {
		AktspOutputLog_2("## Counter osap Error!! OS : %d, TESRY : %d.",
						 osapid, CounterInfo->cm_osap);
		ercd = E_NOT_OK;
	}
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
	/* SC1-MCでは，割付けられたコアを確認できれば良い */
	coreid = p_cntcb->p_cntinib->coreid;
    if ((osapinib_table[CounterInfo->cm_osap].coreid) != coreid) {
		AktspOutputLog_2("## Counter CoreId Error!! OS : %d, TESRY : %d.",
						 coreid, osapinib_table[CounterInfo->cm_osap].coreid);
		ercd = E_NOT_OK;
	}
	release_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  カウンタにアクセス可能な非信頼OSアプリケーション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyCounterAccessOsap(CounterType CounterID, ApplicationType OsapID)
{
	CNTCB			*p_cntcb;       /* カウンタ管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_cntcb = get_cntcb(CounterID);
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_cntcb->p_cntinib->acsbtmp)) == 0) {
			AktspOutputLog_2("## Counter accosap Error!! Counter btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_cntcb->p_cntinib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## Counter accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *	アラーム
 */
StatusType
AktspVerifyAlarm(AlarmType AlarmID, const AktspAlarmRefInfo AlarmData)
{
	ALMCB			*p_acb;            /* アラーム管理の為のメモリ領域 */
	uint32			astat = AK_UNSET;  /* アラーム状態 */
	CNTCB			*p_cntcb;          /* カウンタ管理の為のメモリ領域 */
	QUEUE			*p_next = NULL;    /* アラームキュー */
	TickType		almtickval;        /* 満了するティックの絶対値 */
	CounterType		cnterid;           /* カウンタID */
	boolean			locked;            /* 割込み禁止状態 */
	StatusType		ercd = E_OK;       /* エラーコード */
	uint8			autostarttype;     /* 自動起動の属性 */
	AlarmType		alarmid;           /* アラームID */
#ifdef CFG_USE_SCALABILITYCLASS3
	ApplicationType	osapid;            /* OSアプリケーションID */
#endif /* CFG_USE_SCALABILITYCLASS3 */

	locked = AktspDisInt();

	p_acb = get_almcb(AlarmID);

#ifdef TotalNumberOfCores
	p_cntcb = p_acb->p_alminib->p_cntcb;
	acquire_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	/* パラメータチェック */
	cnterid = CNTID(p_acb->p_alminib->p_cntcb);
	if (AlarmData->am_counter != cnterid) {
		AktspOutputLog_2("## Alarm counter Error!! OS : %d, TESRY : %d.",
						 cnterid, AlarmData->am_counter);
		ercd = E_NOT_OK;
	}

	p_cntcb = p_acb->p_alminib->p_cntcb;

	p_next = p_cntcb->cntexpque.p_next;
	if (p_cntcb != (CNTCB *)p_next) {
		do {
			alarmid = AK_ALMID((ALMCB *)p_next);
			if (alarmid == AlarmID) {
				astat = AK_SET;
				break;
			}
			p_next = p_next->p_next;
		} while (p_cntcb->cntexpque.p_next != p_next);
	}
	if (AlarmData->am_astat != astat) {
		AktspOutputLog_2("## Alarm astat Error!! OS : %d, TESRY : %d.",
						 astat, AlarmData->am_astat);
		ercd = E_NOT_OK;
	}

	if (AlarmData->am_astat == AK_SET) {
		/* ATK2では，カウンタのティックを最大値の2周期分(最大値の2倍＋1)管理している */
		if (p_acb->cntexpinfo.expiretick > p_cntcb->p_cntinib->maxval) {
			almtickval = p_acb->cntexpinfo.expiretick - (p_cntcb->p_cntinib->maxval + 1U);
		}
		else {
			almtickval = p_acb->cntexpinfo.expiretick;
		}
		if (AlarmData->am_almval != almtickval) {
			AktspOutputLog_2("## Alarm almval Error!! OS : %d, TESRY : %d.",
							 almtickval, AlarmData->am_almval);
			ercd = E_NOT_OK;
		}

		if (AlarmData->am_cycle != p_acb->cycle) {
			AktspOutputLog_2("## Alarm cycle Error!! OS : %d, TESRY : %d.",
							 p_acb->cycle, AlarmData->am_cycle);
			ercd = E_NOT_OK;
		}
	}

	if (AlarmData->am_almact == AK_ALM_CBACK) {
		if (AlarmData->am_callback != p_acb->p_alminib->action) {
			AktspOutputLog_2("## Alarm callback Error!! OS : 0x%x, TESRY : 0x%x.",
							 (sintptr) p_acb->p_alminib->action, (const sintptr) AlarmData->am_callback);
			ercd = E_NOT_OK;
		}
	}

	/* ATK2では，アプリケーションモードに指定がない場合は自動起動を行わないため，確認を行わない */
	if (AlarmData->am_autostarttype != AKTSP_INVALID_VALUE8) {
#ifdef CFG_USE_SCALABILITYCLASS3
		if (p_acb->p_alminib->actatr == ABSOLUTE) {
#else  /* CFG_USE_SCALABILITYCLASS3 */
		if ((p_acb->p_alminib->actatr & ABSOLUTE) == ABSOLUTE) {
#endif /* CFG_USE_SCALABILITYCLASS3 */
			autostarttype = AK_ABSOLUTE;
		}
		else {
			autostarttype = AK_RELATIVE;
		}
		if (AlarmData->am_autostarttype != autostarttype) {
			AktspOutputLog_2("## Alarm autostarttype Error!! OS : %d, TESRY : %d.",
						 					autostarttype, AlarmData->am_autostarttype);
			ercd = E_NOT_OK;
		}
	}

#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_acb->p_alminib->p_osapcb);
	if (AlarmData->am_osap != osapid) {
		AktspOutputLog_2("## Alarm osap Error!! OS : %d, TESRY : %d.",
						 osapid, AlarmData->am_osap);
		ercd = E_NOT_OK;
	}
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
	release_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  アラームにアクセス可能な非信頼OSアプリケーション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyAlarmAccessOsap(AlarmType AlarmID, ApplicationType OsapID)
{
	ALMCB			*p_acb;         /* アラーム管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_acb = get_almcb(AlarmID);
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_acb->p_alminib->acsbtmp)) == 0) {
			AktspOutputLog_2("## Alarm accosap Error!! Alarm btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_acb->p_alminib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## Alarm accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  アラームのアプリケーションモード
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyAlarmApplicationMode(AlarmType AlarmID, AppModeType Mode)
{
	ALMCB		*p_acb;         /* アラーム管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_acb = get_almcb(AlarmID);

	/* パラメータチェック */
	if ((p_acb->p_alminib->autosta & ((uint32)1U << Mode)) == APPMODE_NONE) {
		AktspOutputLog_2("## Alarm appmode Error!! OS : 0x%x, TESRY : 0x%x.",
									 p_acb->p_alminib->autosta, ((uint32)1U << Mode));
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  スケジュールテーブル
 */
StatusType
AktspVerifyScheduleTable(ScheduleTableType ScheduleTableID, const AktspScheduleTableRefInfo ScheduleTableInfo)
{
	SCHTBLCB			*p_schtblcb;            /* スケジュールテーブル管理の為のメモリ領域 */
	uint8				recycle;                /* 繰り返し指定 */
	uint8				syncstrategy;           /* 同期方法 */
	CounterType			cnterid;                /* カウンタID */
	ScheduleTableType	previd;                 /* 切換え前スケジュールテーブルID */
	TickType			cntval;                 /* カウンタ上の満了するティック値とカウンタの現在時刻の差 */
	TickType			schtblval = 0U;         /* 現在値(warning対策のため初期化) */
	const SCHTBLEXPPTCB	*p_exppoint;            /* 個々の満了点テーブル型のメモリ領域 */
	boolean				locked;                 /* 割込み禁止状態 */
	TickType			cntcurval;              /* カウンタの現在値 */
	boolean				curvalflg = AK_TRUE;    /* 現在値確認処理用フラグ */
	StatusType			ercd = E_OK;            /* エラーコード */
	uint8				autostarttype;          /* 自動起動の属性 */
#ifdef CFG_USE_SCALABILITYCLASS3
	ApplicationType		osapid;                 /* OSアプリケーションID */
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
	CNTCB    *p_cntcb;          /* カウンタ管理の為のメモリ領域 */
#endif /* TotalNumberOfCores */

	locked = AktspDisInt();

	p_schtblcb = get_schtblcb(ScheduleTableID);

#ifdef TotalNumberOfCores
	p_cntcb = p_schtblcb->p_schtblinib->p_cntcb;
	acquire_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	/* パラメータチェック */
	cnterid = CNTID(p_schtblcb->p_schtblinib->p_cntcb);
	if (ScheduleTableInfo->sm_counter != cnterid) {
		AktspOutputLog_2("## ScheduleTable counter Error!! OS : %d, TESRY : %d.",
						 cnterid, ScheduleTableInfo->sm_counter);
		ercd = E_NOT_OK;
	}

	if (p_schtblcb->p_schtblinib->repeat == AK_TRUE) {
		recycle = AK_TRUE;
	}
	else {
		recycle = AK_FALSE;
	}
	if (ScheduleTableInfo->sm_repeat != recycle) {
		AktspOutputLog_2("## ScheduleTable repeat Error!! OS : %d, TESRY : %d.",
						 recycle, ScheduleTableInfo->sm_repeat);
		ercd = E_NOT_OK;
	}

	if (ScheduleTableInfo->sm_ststat != p_schtblcb->status) {
		AktspOutputLog_2("## ScheduleTable ststat Error!! OS : 0x%x, TESRY : 0x%x.",
						 p_schtblcb->status, ScheduleTableInfo->sm_ststat);
		ercd = E_NOT_OK;
	}

	if (ScheduleTableInfo->sm_duration != p_schtblcb->p_schtblinib->length) {
		AktspOutputLog_2("## ScheduleTable duration Error!! OS : %d, TESRY : %d.",
						 p_schtblcb->p_schtblinib->length, ScheduleTableInfo->sm_duration);
		ercd = E_NOT_OK;
	}

	/* 
	 *  ScheduleTableIDが暗黙同期スケジュールテーブル数を保持する変数(tnum_implscheduletable)より
	 *  小さければ暗黙同期スケジュールテーブル，それ以外の場合は，同期なしスケジュールテーブルとなる
	 */
	if (ScheduleTableID < tnum_implscheduletable) {
		syncstrategy = AK_IMPLICIT;
	}
	else {
		syncstrategy = AK_NONE;
	}
	if (ScheduleTableInfo->sm_syncstrategy != syncstrategy) {
		AktspOutputLog_2("## ScheduleTable syncstrategy Error!! OS : %d, TESRY : %d.",
						 syncstrategy, ScheduleTableInfo->sm_syncstrategy);
		ercd = E_NOT_OK;
	}

	if (ScheduleTableInfo->sm_ststat == SCHEDULETABLE_NEXT) {
		previd = AK_SCHTBID((p_schtblcb)->p_prevschtblcb);
		if (ScheduleTableInfo->sm_stfrom != previd) {
			AktspOutputLog_2("## ScheduleTable stfrom Error!! OS : %d, TESRY : %d.",
							 previd, ScheduleTableInfo->sm_stfrom);
			ercd = E_NOT_OK;
		}
	}

	/*
	 *  スケジュールテーブルの現在値
	 *  オフセット値 - (満了するカウンタ上のティック値 - カウンタの現在値)
	 */
	if ((ScheduleTableInfo->sm_ststat == SCHEDULETABLE_RUNNING) || (ScheduleTableInfo->sm_ststat == SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS)) {
		/*
		 *  カウンタの現在値を取得
		 */
		if (cnterid < tnum_hardcounter) {
			cntcurval = hwcntinib_table[cnterid].get();
		}
		else {
			cntcurval = p_schtblcb->p_schtblinib->p_cntcb->curval;
		}

		/*
		 *  満了するカウンタ上のティック値とカウンタの現在値の差分を取得
		 */
		if (p_schtblcb->cntexpinfo.expiretick < cntcurval) {
			cntval = (((p_schtblcb->p_schtblinib->p_cntcb->p_cntinib->maxval2 - cntcurval) + 1U) + p_schtblcb->cntexpinfo.expiretick);
		}
		else {
			cntval = p_schtblcb->cntexpinfo.expiretick - cntcurval;
		}

		if (p_schtblcb->p_schtblinib->tnum_exppt == p_schtblcb->expptindex) {
			/*
			 *  周期最後の満了処理後の場合
			 *  オフセット値にダミーとして周期の値を設定しているため，
			 *  周期からcntvalを引き，現在値を取得する
			 */
			schtblval = p_schtblcb->p_schtblinib->length - cntval;
		}
		else {
			p_exppoint = &(p_schtblcb->p_schtblinib->p_exppt[p_schtblcb->expptindex]);
			if (p_schtblcb->expptindex == EXPPTINDEX_INITIAL) {
				/*
				 *  動作開始待ち状態
				 *  状態はRUNNINGだが，スケジュールテーブルは動き出していないため，
				 *  アクションインデックスをEXPPTINDEX_INITIALに設定している
				 */
				if (ScheduleTableInfo->sm_curval != AKTSP_INVALID_VALUE32) {
					AktspOutputLog_2("## ScheduleTable curval Error!! OS : %d, TESRY : %d.",
									 AKTSP_INVALID_VALUE32, ScheduleTableInfo->sm_curval);
					ercd = E_NOT_OK;
				}
				curvalflg = AK_FALSE;
			}
			else if (p_exppoint->offset < cntval) {
				schtblval = p_schtblcb->p_schtblinib->length - cntval;
			}
			else {
				schtblval = p_exppoint->offset - cntval;
			}
		}

		if ((curvalflg == AK_TRUE) && (ScheduleTableInfo->sm_curval != schtblval)) {
			AktspOutputLog_2("## ScheduleTable curval Error!! OS : %d, TESRY : %d.",
							 schtblval, ScheduleTableInfo->sm_curval);
			ercd = E_NOT_OK;
		}
	}

	if (ScheduleTableInfo->sm_starttick != p_schtblcb->p_schtblinib->staval) {
		AktspOutputLog_2("## ScheduleTable starttick Error!! OS : %d, TESRY : %d.",
							 p_schtblcb->p_schtblinib->staval, ScheduleTableInfo->sm_starttick);
		ercd = E_NOT_OK;
	}

	if (ScheduleTableInfo->sm_autostarttype != AKTSP_INVALID_VALUE8) {
		if (p_schtblcb->p_schtblinib->actatr == ABSOLUTE) {
			autostarttype = AK_ABSOLUTE;
		}
		else {
			autostarttype = AK_RELATIVE;
		}
		if (ScheduleTableInfo->sm_autostarttype != autostarttype) {
			AktspOutputLog_2("## ScheduleTable autostarttype Error!! OS : %d, TESRY : %d.",
							 				autostarttype, ScheduleTableInfo->sm_autostarttype);
			ercd = E_NOT_OK;
		}
	}

#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_schtblcb->p_schtblinib->p_osapcb);
	if (ScheduleTableInfo->sm_osap != osapid) {
		AktspOutputLog_2("## ScheduleTable osap Error!! OS : %d, TESRY : %d.",
						 osapid, ScheduleTableInfo->sm_osap);
		ercd = E_NOT_OK;
	}
#endif /* CFG_USE_SCALABILITYCLASS3 */

#ifdef TotalNumberOfCores
	release_cnt_lock(get_p_ccb(p_cntcb->p_cntinib->coreid));
#endif /* TotalNumberOfCores */

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  スケジュールテーブルの満了アクション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyScheduleTableExaction(ScheduleTableType ScheduleTableID, uint32 Index, const AktspScheduleTableExactionRefInfo ScheduleTableExactionInfo)
{
	SCHTBLCB			*p_schtblcb;    /* スケジュールテーブル管理の為のメモリ領域 */
	const SCHTBLEXPPTCB *p_exppoint;    /* 個々の満了点テーブル型のメモリ領域 */
	boolean				locked;         /* 割込み禁止状態 */
	StatusType			ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_schtblcb = get_schtblcb(ScheduleTableID);
	p_exppoint = &(p_schtblcb->p_schtblinib->p_exppt[(Index - 1U)]);

	/* パラメータチェック */
	if (ScheduleTableExactionInfo->sem_offset != p_exppoint->offset) {
		AktspOutputLog_1("## ScheduleTableExaction offset Error!! TESRY : %d.",
						 ScheduleTableExactionInfo->sem_offset);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  スケジュールテーブルのアプリケーションモード
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyScheduleTableApplicationMode(ScheduleTableType ScheduleTableID, AppModeType Mode)
{
	SCHTBLCB			*p_schtblcb;    /* スケジュールテーブル管理の為のメモリ領域 */
	boolean				locked;         /* 割込み禁止状態 */
	StatusType			ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_schtblcb = get_schtblcb(ScheduleTableID);

	/* パラメータチェック */
	if ((p_schtblcb->p_schtblinib->autosta & ((uint32)1U << Mode)) == APPMODE_NONE) {
		AktspOutputLog_2("## ScheduleTable appmode Error!! OS : 0x%x, TESRY : 0x%x.",
									 p_schtblcb->p_schtblinib->autosta, ((uint32)1U << Mode));
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  スケジュールテーブルにアクセス可能な非信頼OSアプリケーション
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyScheduleTableAccessOsap(ScheduleTableType ScheduleTableID, ApplicationType OsapID)
{
	SCHTBLCB		*p_schtblcb;    /* スケジュールテーブル管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_schtblcb = get_schtblcb(ScheduleTableID);
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_schtblcb->p_schtblinib->acsbtmp)) == 0) {
			AktspOutputLog_2("## ScheduleTable accosap Error!! ScheduleTable btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_schtblcb->p_schtblinib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## ScheduleTable accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  信頼関数
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyTrustedFunction(TrustedFunctionIndexType FunctionIndex, const AktspTrustedFunctionRefInfo TrustedFunctionInfo)
{
	const TFINIB	*p_tfinib;      /* 信頼関数制御の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_tfinib = &tfinib_table[FunctionIndex];

	/* パラメータチェック */
	if (TrustedFunctionInfo->tfm_stksz != p_tfinib->tf_stksz) {
		AktspOutputLog_2("## TrustedFunction stksz Error!! OS : %d, TESRY : %d.",
						 p_tfinib->tf_stksz, TrustedFunctionInfo->tfm_stksz);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */


#ifdef TotalNumberOfCores
/*
 *  スピンロック
 */
StatusType
AktspVerifySpinlock(SpinlockIdType SpnID, const AktspSpinlockRefInfo SpnInfo)
{
	SPNCB			*p_spncb;         /* スピンロック管理の為のメモリ領域 */
	SPNCB			*p_get_spncb;     /* successorチェック用ポインタ */
	const SPNINIB	*p_spninib;       /* successorチェック用ポインタ */
	const SPNINIB	*p_get_spninib;   /* successorチェック用ポインタ */
	boolean			nest_chk = FALSE; /* successorチェック用フラグ */
	boolean			locked;           /* 割込み禁止状態 */
	StatusType		ercd = E_OK;      /* エラーコード */

	locked = AktspDisInt();

	p_spncb = get_spncb(SpnID);

	/* パラメータチェック */
	switch (SpnInfo->sl_susint) {
		case AK_SUS_ALL_SPN:
			if ((p_spncb->p_spninib->susint != &wrap_sus_all_int) || (p_spncb->p_spninib->resint != &wrap_res_all_int)) {
				AktspOutputLog_0("## Spinlock susint Error!! OS : AK_DO_NOT_CARE or AK_SUS_OS_SPN, TESRY : AK_SUS_ALL_SPN.");
				ercd = E_NOT_OK;
			}
			break;
		case AK_SUS_OS_SPN:
			if ((p_spncb->p_spninib->susint != &wrap_sus_os_int) || (p_spncb->p_spninib->resint != &wrap_res_os_int)) {
				AktspOutputLog_0("## Spinlock susint Error!! OS : AK_DO_NOT_CARE or AK_SUS_ALL_SPN, TESRY : AK_SUS_OS_SPN.");
				ercd = E_NOT_OK;
			}
			break;
		case AK_DO_NOT_CARE:
			if ((p_spncb->p_spninib->susint != NULL) || (p_spncb->p_spninib->resint != NULL)) {
				AktspOutputLog_0("## Spinlock susint Error!! OS : AK_SUS_ALL_SPN or AK_SUS_OS_SPN, TESRY : AK_DO_NOT_CARE.");
				ercd = E_NOT_OK;
			}
			break;
		default:
			AktspOutputLog_1("## SpnInfo->sl_susint is invalid!! : %d", SpnInfo->sl_susint);
			ercd = E_NOT_OK;
			break;
	}

	if (SpnInfo->sl_successor == AKTSP_INVALID_VALUE32) {
		if (p_spncb->p_spninib->p_nextspn != NULL) {
			AktspOutputLog_0("## Spinlock successor exist!!");
			ercd = E_NOT_OK;
		}
	}
	else {
		/* successorはTESRYに指定されたスピンロックIDがリストに存在すればOKとする */
		p_get_spncb = get_spncb(SpnInfo->sl_successor);
		p_get_spninib = p_get_spncb->p_spninib;
		p_spninib = p_spncb->p_spninib;
		while (p_spninib->p_nextspn != NULL) {
			p_spninib = p_spninib->p_nextspn;
			if (p_spninib == p_get_spninib) {
				nest_chk = TRUE;
				break;
			}
		}
		if (nest_chk == FALSE) {
			AktspOutputLog_1("## Spinlock nest_order don't include successor.[%d]", SpnInfo->sl_successor);
			ercd = E_NOT_OK;
		}
	}

	if (((SpnInfo->sl_lockflg == AK_UNLOCK) && (p_spncb->p_holdcb != NULL)) ||
		((SpnInfo->sl_lockflg == AK_LOCK) && (p_spncb->p_holdcb == NULL))) {
		AktspOutputLog_2("## Spinlock lockflg Error!! OS : %d, TESRY : %d.",
						 (sintptr)p_spncb->p_holdcb, SpnInfo->sl_lockflg);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  タスクが獲得中のスピンロック
 */
StatusType
AktspVerifyTaskGetSpinlock(TaskType TaskID, uint32 Index, SpinlockIdType SpnID)
{
	TCB			*p_tcb;         /* タスク管理の為のメモリ領域 */
	SPNCB		*p_spncb;       /* スピンロック管理の為のメモリ領域 */
	CCB			*p_ccb;         /* コア管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_tcb = get_tcb(TaskID);
	p_ccb = p_tcb->p_tinib->p_ccb;
	p_spncb = get_spncb(SpnID);

	acquire_tsk_lock(p_ccb);

	/* パラメータチェック */
	if (p_spncb->p_ccb != p_ccb) {
		AktspOutputLog_2("## Spinlock coreid Error!! TASK : %d, SPINLOCK : %d.",
						 p_ccb->coreid, p_spncb->p_ccb->coreid);
		ercd = E_NOT_OK;
	}

	ercd = AktspGetOrderedSpinlockId(p_tcb->p_lastspncb, Index, SpnID);

	release_tsk_lock(p_ccb);
	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  C2ISRが獲得中のスピンロック
 */
StatusType
AktspVerifyC2IsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	ISRCB		*p_isrcb;       /* C2ISRの管理の為のメモリ領域 */
	SPNCB		*p_spncb;       /* スピンロック管理の為のメモリ領域 */
	CoreIdType	coreid;         /* C2ISRの所属コアID */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_spncb = get_spncb(SpnID);
	p_isrcb = p_isrcb_table[IsrID];
	coreid = p_isrcb->p_isrinib->p_intinib->coreid;

	/* パラメータチェック */
	if (p_spncb->p_ccb->coreid != coreid) {
		AktspOutputLog_2("## Spinlock coreid Error!! C2ISR : %d, SPINLOCK : %d.",
						 coreid, p_spncb->p_ccb->coreid);
		ercd = E_NOT_OK;
	}

	ercd = AktspGetOrderedSpinlockId(p_isrcb->p_lastspncb, Index, SpnID);

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  指定した順番に獲得したスピンロックID[内部関数]
 */
StatusType
AktspGetOrderedSpinlockId(SPNCB* p_lastspn, uint32 Index, SpinlockIdType SpnID)
{
	SPNCB		*p_spncb;                   /* スピンロック管理の為のメモリ領域 */
	SPNCB		*cnt_lastspn = p_lastspn;   /* 獲得スピンロックカウント用最後に獲得したスピンロック管理の為のメモリ領域 */
	StatusType	ercd = E_OK;                /* エラーコード */
	uint32		maxcnt = 0U;                /* 獲得スピンロック総数 */
	uint32		setcnt = 0U;
	uint32		i;

	/* スピンロック獲得総数 */
	while (cnt_lastspn != NULL) {
		if (cnt_lastspn->p_holdcb != NULL) {
			maxcnt++;
		}
		else {
			break;
		}
		cnt_lastspn = cnt_lastspn->p_prevspncb;
	}

	if (maxcnt < Index) {
		ercd = E_NOT_OK;
	}
	else {
		/* 指定した順番に獲得したスピンロックID */
		p_spncb = get_spncb(SpnID);
		setcnt = (maxcnt - Index) + 1U;
		for (i = 1U; i <= setcnt; i++) {
			if (i == setcnt) {
				if (p_lastspn != p_spncb) {
					AktspOutputLog_2("## AktspGetOrderedSpinlockId Error!! OS : 0x%x, TESRY : 0x%x.",
									 (sintptr) p_lastspn, (sintptr) p_spncb);
					ercd = E_NOT_OK;
				}
				break;
			}
			p_lastspn = p_lastspn->p_prevspncb;
		}
	}

	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  スピンロックにアクセス可能な非信頼OSアプリケーション
 */
StatusType
AktspVerifySpinlockAccessOsap(SpinlockIdType SpnID, ApplicationType OsapID)
{
	SPNCB		*p_spncb;           /* スピンロック管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_spncb = get_spncb(SpnID);
	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_spncb->p_spninib->acsbtmp)) == 0) {
			AktspOutputLog_2("## Spinlock accosap Error!! Spinlock btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_spncb->p_spninib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## Spinlock accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  強制マージ時に，最後のmain関数から呼び出す処理(マルチコアのみで使用)
 */
void
AktspCallFromLastMainFunc(void)
{
	uint8		i;
	StatusType	ercd;

	/* マスタコア以外は何もせずにreturn */
	if (GetCoreID() != OS_CORE_ID_MASTER) {
		return;
	}

	/*
	 * ・最後に起動したマスタコアのmain関数から呼び出される
	 * ・スレーブコアは，起動待ちの無限ループに入っているため，
	 *   最後にStartCoreを発行することで，スレーブコアもmain関数が
	 *   呼び出され，"Kernel Exit..."を表示させることができる
	 */
	for (i = 0; i < TotalNumberOfCores; i++) {
		if (i != OS_CORE_ID_MASTER) {
			StartCore(i, &ercd);
			CheckErcd(ercd, E_OK);
		}
	}
}

#endif /* TotalNumberOfCores */


#if 0
/*
 *  OSアプリケーション固有のスタートアップフック
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyStartupHookOsap(ApplicationType OsapID, StartupHookOsap StartupHookFunction)
{
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	/* パラメータチェック */
	if (StartupHookFunction != osapinib_table[OsapID].StartupHook) {
		AktspOutputLog_2("## StartupHookOsap StartupHook Error!! OS : 0x%x, TESRY : 0x%x.",
						 (const sintptr) osapinib_table[OsapID].StartupHook, (sintptr) StartupHookFunction);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  OSアプリケーション固有のシャットダウンフック
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyShutdownHookOsap(ApplicationType OsapID, ShutdownHookOsap ShutdownHookFunction)
{
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	/* パラメータチェック */
	if (ShutdownHookFunction != osapinib_table[OsapID].ShutdownHook) {
		AktspOutputLog_2("## ShutdownHookOsap ShutdownHook Error!! OS : 0x%x, TESRY : 0x%x.",
						 (const sintptr) osapinib_table[OsapID].ShutdownHook, (sintptr) ShutdownHookFunction);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *  OSアプリケーション固有のエラーフック
 *  ([マルチコア]初期化ブロックのみの参照であるためロックは不要)
 */
StatusType
AktspVerifyErrorHookOsap(ApplicationType OsapID, ErrorHookOsap ErrorHookFunction)
{
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	/* パラメータチェック */
	if (ErrorHookFunction != osapinib_table[OsapID].ErrorHook) {
		AktspOutputLog_2("## ErrorHookOsap ErrorHook Error!! OS : 0x%x, TESRY : 0x%x.",
						 (const sintptr) osapinib_table[OsapID].ErrorHook, (sintptr) ErrorHookFunction);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif 

/*
 *  指定した順番に獲得したリソースID[内部関数]
 */
StatusType
AktspGetOrderedResourceId(RESCB* p_lastres, uint32 Index, ResourceType ResID)
{
	RESCB		*p_rescb;                   /* リソース管理の為のメモリ領域 */
	RESCB		*cnt_lastres = p_lastres;   /* 獲得リソースカウント用最後に獲得したリソース管理の為のメモリ領域 */
	StatusType	ercd = E_OK;                /* エラーコード */
	uint32		maxcnt = 0U;                /* 獲得リソース総数 */
	uint32		setcnt = 0U;
	uint32		i;

	/* リソース獲得総数 */
	while (cnt_lastres != NULL) {
		if (cnt_lastres->lockflg == AK_TRUE) {
			maxcnt++;
		}
		else {
			break;
		}
		cnt_lastres = cnt_lastres->p_prevrescb;
	}

	if (maxcnt < Index) {
		ercd = E_NOT_OK;
	}
	else {
		/* 指定した順番に獲得したリソースID */
#ifndef TotalNumberOfCores
		p_rescb = &(rescb_table[ResID]);
#else
		p_rescb = p_rescb_table[ResID];
#endif /* TotalNumberOfCores */
		setcnt = (maxcnt - Index) + 1U;
		for (i = 1U; i <= setcnt; i++) {
			if (i == setcnt) {
				if (p_lastres != p_rescb) {
					AktspOutputLog_2("## GetOrderedResourceId Error!! OS : 0x%x, TESRY : 0x%x.",
									 (sintptr) p_lastres, (sintptr) p_rescb);
					ercd = E_NOT_OK;
				}
				break;
			}
			p_lastres = p_lastres->p_prevrescb;
		}
	}

	return(ercd);
}

/*
 *  全割込み禁止状態取得API
 */
boolean
AktspGetDisableAllInterruptsState(void)
{
	boolean	state = AK_OFF;                        /* 全割り込み禁止状態フラグ */
#ifdef TotalNumberOfCores
	CCB		*p_ccb = get_my_p_ccb();               /* コア管理の為のメモリ領域 */
	uint16	callevel_stat = p_ccb->callevel_stat;  /* 呼び出したコアの実行中のコンテキスト */
#endif /* TotalNumberOfCores */

	if (((callevel_stat & TSYS_DISALLINT) != 0U) ||
		((callevel_stat & TSYS_SUSALLINT) != 0U)) {
		state = AK_ON;
	}

	return(state);
}

/*
 *  タスクの状態取得API(マルチコアのみ)
 */
#ifdef TotalNumberOfCores
TaskStateType
AktspGetTaskState(TaskType TaskID)
{
	TCB *p_tcb;
	CCB *p_ccb;

	p_tcb = get_tcb(TaskID);
	p_ccb = p_tcb->p_tinib->p_ccb;

	return (p_tcb == p_ccb->p_runtsk) ? RUNNING : p_tcb->tstat;
}
#endif /* TotalNumberOfCores */

/*
 *  エラーフック起動
 */
void
AktspRaiseErrorHook(void)
{
	/* 標準エラーでもエラーフックが起動するE_OS_LIMITとする */
	ActivateTask(MainTask);
}

/*
 *  CounterIDで指定したハードウェアカウンタのティック更新停止
 */
StatusType
AktspStopHardwareCounter(CounterType CounterID)
{
	StatusType ercd = E_OK;

	if (!is_hwcnt(CounterID)) {
		ercd = E_NOT_OK;
	}
	else {
		hwcntinib_table[CounterID].stop();
	}

	return ercd;
}

/*
 *  CounterIDで指定したハードウェアカウンタのティック更新開始
 */
StatusType
AktspStartHardwareCounter(CounterType CounterID)
{
	StatusType ercd = E_OK;

	if (!is_hwcnt(CounterID)) {
		ercd = E_NOT_OK;
	}
	else {
		hwcntinib_table[CounterID].start();
	}

	return ercd;
}

/*
 *  CounterIDで指定したハードウェアカウンタのティックを0へ初期化
 */
StatusType
AktspInitHardwareCounter(CounterType CounterID)
{
	StatusType	ercd = E_OK;
	CNTCB		*p_cntcb;

#ifndef TotalNumberOfCores
	p_cntcb = &(cntcb_table[CounterID]);
#else
	p_cntcb = p_cntcb_table[CounterID];
#endif /* TotalNumberOfCores */

	if (!is_hwcnt(CounterID)) {
		ercd = E_NOT_OK;
	}
	else {
		hwcntinib_table[CounterID].init(p_cntcb->p_cntinib->maxval2, hwcntinib_table[CounterID].nspertick);
	}

	return ercd;
}

/*
 *  CounterIDで指定したハードウェアカウンタの1ティック更新
 */
StatusType
AktspIncrementHardwareCounter(CounterType CounterID)
{
	StatusType ercd = E_OK;

	if (!is_hwcnt(CounterID)) {
		ercd = E_NOT_OK;
	}
	else {
		hwcntinib_table[CounterID].increment();
	}

	return ercd;
}

#if (defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)) && defined(TNUM_IOC_WRAPPER)
/*
 * IOC
 */
StatusType
AktspVerifyIoc(IocType IocId, const AktspIocRefInfo IocInfo)
{
	const IOCINIB	*p_iocinib;
	IOCCB			*p_ioccb;
	ApplicationType	osapid;      /* OSアプリケーションID */

	StatusType	ercd = E_OK;    /* エラーコード */
	
	p_iocinib = get_iocinib(IocId);
	p_ioccb = get_ioccb(IocId);

	/* maxque */
	if (p_iocinib->maxque != IocInfo->ioc_maxque) {
		AktspOutputLog_2("## IOC maxque Error!! OS: %d, TESRY: %d", p_iocinib->maxque, IocInfo->ioc_maxque);
		ercd = E_NOT_OK;
	}
	/* レシーバが所属するOSAPID */
#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_iocinib->p_rcvosapcb);
#else
	osapid = OSAPID(p_iocinib->p_rcvosapinib);
#endif /* CFG_USE_SCALABILITYCLASS3 */
	if (IocInfo->ioc_rcvosapid != osapid) {
		AktspOutputLog_2("## IOC rcvosap Error!! OS: %d, TESRY:%d", osapid, IocInfo->ioc_rcvosapid);
		ercd = E_NOT_OK;
	}

	/* キューあり通信 */
	if (p_iocinib->maxque > 0) {
		/* quecnt */
		if (p_ioccb->quecnt != IocInfo->ioc_quecnt) {
			AktspOutputLog_2("## IOC quecnt Error!! OS: %d, TESRY:%d", p_ioccb->quecnt, IocInfo->ioc_quecnt);
			ercd = E_NOT_OK;
		}
		/* lostflg */
		if (p_ioccb->lostflg != IocInfo->ioc_lostflg) {
			AktspOutputLog_2("## IOC lostflg Error!! OS: %d, TESRY:%d", p_ioccb->lostflg, IocInfo->ioc_lostflg);
			ercd = E_NOT_OK;
		}
	}

	return ercd;
}

/*
 * IOCとセンダの関連付け
 */
StatusType
AktspVerifyIocSender(IocType IocId, SenderIdType SenderId, ApplicationType SenderOsapId)
{
	StatusType		ercd = E_OK;
	boolean			beSenderId = FALSE; /* iocwrpinib_tableにSenderIdが存在するか */
	uint32			index = 0;          /* iocwrpinib_tableのindex */
	ApplicationType	osapid;         /* OSアプリケーションID */

	/* IOCのIDチェック */
	for (index = 0; index < TNUM_IOC_WRAPPER; index++) {
		if (IocId == IOCID(&iocwrpinib_table[index])) {
#ifdef CFG_USE_SCALABILITYCLASS3
			osapid = OSAPID(iocwrpinib_table[index].p_sndosapcb);
#else
			osapid = OSAPID(iocwrpinib_table[index].p_sndosapinib);
#endif /* CFG_USE_SCALABILITYCLASS3 */
			/* センダID && センダが所属するOSAPIDのチェック */
			if ((SenderId == iocwrpinib_table[index].senderid) && (SenderOsapId == osapid)) {
				beSenderId = TRUE;
				break;
			}
		}
	}

	/* センダIDが存在しない*/
	if (beSenderId != TRUE) {
		AktspOutputLog_1("## IOC SenderId Error!! %d", SenderId);
		ercd = E_NOT_OK;
	}

	return ercd;
}

/*
 * メモリコピー
 */
LOCAL_INLINE void
AktspMemCpy(void *p_dst, const void *p_src, uint32 sz)
{
	uint8		*p_tmp_dst = (uint8 *) p_dst;
	const uint8	*p_tmp_src = (uint8 *) p_src;

	while (sz > 0U)	{
		*p_tmp_dst = *p_tmp_src;
		p_tmp_dst++;
		p_tmp_src++;
		sz--;
	}
}

/*
 * IOC通信データ取得
 */
StatusType
AktspGetDataFromIoc(IocType IocId, void* data, uint32 index)
{
	const IOCINIB	*p_iocinib; 
	const IOCCB		*p_ioccb;

	StatusType	ercd = E_OK;
	uint32		head = 0;

	p_iocinib = get_iocinib(IocId);
	p_ioccb = get_ioccb(IocId);

	/* キューあり通信 */
	if (p_iocinib->maxque > 0) {
		if (index > p_iocinib->maxque) {
			AktspOutputLog_2("## AktspGetDataFromIoc Error!! index %d isn't small than maxque %d", index, p_iocinib->maxque);
			ercd = E_NOT_OK;
		}
		else if (index < 1) {
			AktspOutputLog_1("## AktspGetDataFromIoc Error!! index %d is small than 1", index);
			ercd = E_NOT_OK;
		}
		else {
			head = p_ioccb->head;
			head += index - 1;
			if (head >= p_iocinib->maxque) {
				head = (uint32)(head % p_iocinib->maxque);
			}
			AktspMemCpy(data, (void *) ((uint32) p_iocinib->p_iocmb + (p_iocinib->datasz) * head), p_iocinib->datasz);
		}
	}
	/* キューなし通信 */
	else {
		AktspMemCpy(data, (void *) (p_iocinib->p_iocmb), p_iocinib->datasz);
	}

	return(ercd);
}
#endif /*(defined(TotalNumberOfCores) || defined(CFG_USE_SCALABILITYCLASS3)) && defined(TNUM_IOC_WRAPPER)*/

#ifdef TotalNumberOfCores
/*
 *  ICISR
 */
StatusType
AktspVerifyIcIsr(ISRType IsrID, const AktspIcISRRefInfo IcISRInfo)
{
	ISRCB			*p_isrcb;       /* ISRの管理の為のメモリ領域 */
	RESCB			*p_rescb;       /* 最後に獲得したリソース管理の為のメモリ領域へのポインタ */
	uint32			getrescnt = 0U; /* 獲得中リソース総数(内部リソースを除く)(warning対策のため初期化) */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */
	ApplicationType	osapid;         /* OSアプリケーションID */
#ifdef CFG_USE_SCALABILITYCLASS3
	AttributeType	intatr;         /* 割込み属性 */
#endif /* CFG_USE_SCALABILITYCLASS3 */

	locked = AktspDisInt();

	p_isrcb = p_isrcb_table[IsrID];

	/* パラメータチェック */
#ifdef CFG_USE_SCALABILITYCLASS3
	if (iciinib_table[IsrID + tnum_ici - tnum_isr2].iciatr == ENABLE) {
		intatr = AK_ENABLE;
	}
	else {
		intatr = AK_DISABLE;
	}
	if (intatr != IcISRInfo->icm_intatr) {
		AktspOutputLog_2("## ICISR intatr Error!! OS : %d, TESRY : %d.",
						 intatr, IcISRInfo->icm_intatr);
		ercd = E_NOT_OK;
	}
#endif /* CFG_USE_SCALABILITYCLASS3 */

	/* 最後に獲得したリソース管理ブロックへのポインタを利用し，リソース獲得数を確認する */
	p_rescb = p_isrcb->p_lastrescb;
	while (p_rescb != NULL) {
		if (p_rescb->lockflg == AK_TRUE) {
			getrescnt++;
		}
		else {
			break;
		}
		p_rescb = p_rescb->p_prevrescb;
	}
	if (IcISRInfo->icm_getrescount != getrescnt) {
		AktspOutputLog_2("## ICISR getrescnt Error!! OS : %d, TESRY : %d.",
						 getrescnt, IcISRInfo->icm_getrescount);
		ercd = E_NOT_OK;
	}

#ifdef CFG_USE_SCALABILITYCLASS3
	osapid = OSAPID(p_isrcb->p_isrinib->p_osapcb);
#else
	osapid = OSAPID(p_isrcb->p_isrinib->p_osapinib);
#endif /* CFG_USE_SCALABILITYCLASS3 */
	if (IcISRInfo->icm_osap != osapid) {
		AktspOutputLog_2("## ICISR osap Error!! OS : %d, TESRY : %d.",
						 osapid, IcISRInfo->icm_osap);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}

/*
 *	ICISRの関連づけされたリソース
 */
StatusType
AktspVerifyIcIsrRelResource(ISRType IsrID, ResourceType ResID)
{
	/* ATK2では，参照できない情報のため，確認せず，E_OKを返す */
	return(E_OK);
}

/*
 *	ICISRが獲得中のリソース
 */
StatusType
AktspVerifyIcIsrGetResource(ISRType IsrID, uint32 Index, ResourceType ResID)
{
	ISRCB		*p_isrcb;       /* ISRの管理の為のメモリ領域 */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_isrcb = p_isrcb_table[IsrID];

	/* パラメータチェック */
	ercd = AktspGetOrderedResourceId(p_isrcb->p_lastrescb, Index, ResID);

	AktspEnaInt(locked);
	return(ercd);
}

#ifdef CFG_USE_SCALABILITYCLASS3
/*
 *  ICISRにアクセス可能な非信頼OSアプリケーション
 */
StatusType
AktspVerifyIcIsrAccessOsap(ISRType IsrID, ApplicationType OsapID)
{
	ISRCB			*p_isrcb;       /* ISRの管理の為のメモリ領域 */
	const OSAPINIB	*p_osapinib;    /* OSアプリケーション管理の為のメモリ領域 */
	boolean			locked;         /* 割込み禁止状態 */
	StatusType		ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_isrcb = p_isrcb_table[IsrID];

	p_osapinib = get_osapinib(OsapID);

	/* パラメータチェック */
	if (p_osapinib->osap_trusted == TA_NONTRUSTED) {
		if (((p_osapinib->btptn) & (p_isrcb->p_isrinib->acsbtmp)) == 0) {
			AktspOutputLog_2("## ICISR accosap Error!! ICISR btptn : 0x%x, Osap acsbtmp : 0x%x.",
							 p_osapinib->btptn, p_isrcb->p_isrinib->acsbtmp);
			ercd = E_NOT_OK;
		}
	}
	else {
		AktspOutputLog_1("## ICISR accosap Error!! accosap isn't TA_NONTRUSTED, OsapID : %d.", OsapID);
		ercd = E_NOT_OK;
	}

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */
/*
 *  ICISRが獲得中のスピンロック
 */
StatusType
AktspVerifyIcIsrGetSpinlock(ISRType IsrID, uint32 Index, SpinlockIdType SpnID)
{
	ISRCB		*p_isrcb;       /* ISRの管理の為のメモリ領域 */
	SPNCB		*p_spncb;       /* スピンロック管理の為のメモリ領域 */
	CoreIdType	coreid;         /* C2ISRの所属コアID */
	boolean		locked;         /* 割込み禁止状態 */
	StatusType	ercd = E_OK;    /* エラーコード */

	locked = AktspDisInt();

	p_spncb = get_spncb(SpnID);
	p_isrcb = p_isrcb_table[IsrID];
#ifdef CFG_USE_SCALABILITYCLASS3
	coreid = p_isrcb->p_isrinib->p_osapcb->p_osapinib->coreid;
#else
	coreid = p_isrcb->p_isrinib->p_osapinib->coreid;
#endif /* CFG_USE_SCALABILITYCLASS3 */

	/* パラメータチェック */
	if (p_spncb->p_ccb->coreid != coreid) {
		AktspOutputLog_2("## Spinlock coreid Error!! ICISR : %d, SPINLOCK : %d.",
						 coreid, p_spncb->p_ccb->coreid);
		ercd = E_NOT_OK;
	}

	ercd = AktspGetOrderedSpinlockId(p_isrcb->p_lastspncb, Index, SpnID);

	AktspEnaInt(locked);
	return(ercd);
}
#endif /* TotalNumberOfCores */

#ifdef CFG_USE_SCALABILITYCLASS3
StatusType
AktspVerifyOsapState(ApplicationType OsapID, ApplicationStateType State)
{
	OSAPCB		*p_osapcb;    /* OSAP管理ブロック */
	StatusType	ercd = E_OK;  /* エラーコード */

	p_osapcb = get_osapcb(OsapID);
	    
	/* パラメータチェック */
	if (p_osapcb->osap_stat != State) {
		AktspOutputLog_2("## OSAP state Error!! OS: %d, TESRY: %d.",
						 p_osapcb->osap_stat, State);
		ercd = E_NOT_OK;
	}

	return(ercd);
}
#endif /* CFG_USE_SCALABILITYCLASS3 */

/*
 *  ダミーハードウェアカウンタの定義
 */
static volatile TickType	dummy_hwcnt_curval;
static volatile TickType	dummy_hwcnt_maxval;
static volatile TickType	dummy_hwcnt_maxval2;
static volatile TickType	dummy_hwcnt_exprtick;
static volatile boolean		dummy_hwcnt_set_flg;

void
init_hwcounter_DUMMY_HARDWARE_COUNTER(TickType maxval2, TimeType nspertick)
{
	dummy_hwcnt_curval = 0U;
	dummy_hwcnt_maxval = (maxval2 - 1U) / 2U;
	dummy_hwcnt_maxval2 = maxval2;
	dummy_hwcnt_exprtick = 0U;
	dummy_hwcnt_set_flg = AK_FALSE;
}

void
start_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	/*
	 * ダミーカウンタは動作していないので，何もしない
	 */
}

void
stop_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	/*
	 * ダミーカウンタは動作していないので，何もしない
	 */
}

void
set_hwcounter_DUMMY_HARDWARE_COUNTER(TickType exprtick)
{
	DisableAllInterrupts();
	dummy_hwcnt_exprtick = exprtick;
	dummy_hwcnt_set_flg = AK_TRUE;
	EnableAllInterrupts();
}

TickType
get_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	return dummy_hwcnt_curval;
}

void
cancel_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	dummy_hwcnt_set_flg = AK_FALSE;
}

void
trigger_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	AktspRaiseInterrupt(AKTSP_INTNO_HWCNT);
}

void
int_clear_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	AktspClearIntRequest(AKTSP_INTNO_HWCNT);
}

void
int_cancel_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	AktspCancelIntRequest(AKTSP_INTNO_HWCNT);
}

void
increment_hwcounter_DUMMY_HARDWARE_COUNTER(void)
{
	TickType difftick;

	DisableAllInterrupts();

	/* 現在値をインクリメント */
	dummy_hwcnt_curval += 1U;

	/* 最大値を超えた場合，0へ戻す */
	if (dummy_hwcnt_curval > dummy_hwcnt_maxval2) {
		dummy_hwcnt_curval = 0U;
	}

	/* 満了時刻を超えていた場合，ISRを起動する */
	if (dummy_hwcnt_set_flg == AK_TRUE) {
		difftick = diff_tick(dummy_hwcnt_curval, dummy_hwcnt_exprtick, dummy_hwcnt_maxval2);
		if (difftick <= dummy_hwcnt_maxval) {
			AktspRaiseInterrupt(AKTSP_INTNO_HWCNT);
			dummy_hwcnt_set_flg = AK_FALSE;
		}
	}

	/* 満了する場合，この割込み禁止解除によってISRが起動する */
	EnableAllInterrupts();
}

#ifndef AKTSP_OMIT_INITIALIZE_STACK

/* 初期値と見なすマジックナンバー */
#define AKTSP_INITIAL_MAGIC_NUMBER  0x4AU

/*
 *  スタック初期化
 *  (ターゲット依存部で用意する場合，AKTSP_OMIT_INITIALIZE_STACKを定義する)
 */
void
AktspInitializeStack(uint8 stk[], MemorySizeType size, boolean boot)
{
	uint32 i;

	/* 
	 *  本関数は，main関数の先頭で実行するので，OS起動に要する最小値(MINIMUM_OSTKSZ)の
	 *  サイズだけ上書きしなければ安全である
	 */
	if (boot == TRUE) {
		size -= MINIMUM_OSTKSZ;
	}

	/* 先頭4byteはマジックナンバー */
	for (i = 4U; i < size; i++) {
		stk[i] = AKTSP_INITIAL_MAGIC_NUMBER;
	}
}

/*
 *  スタック使用量チェック
 *  (ターゲット依存部で用意する場合，AKTSP_OMIT_INITIALIZE_STACKを定義する)
 */
uint32
AktspCheckStackUsage(uint8 stk[], MemorySizeType size)
{
	uint32 i;

	/* 先頭4byteはマジックナンバー */
	for (i = 4U; i < size; i++) {
		if (stk[i] != AKTSP_INITIAL_MAGIC_NUMBER) {
			break;
		}
	}

	return (size - i);
}

#endif /* AKTSP_OMIT_INITIALIZE_STACK */

/*
 * スケーラビリティクラス毎の定義
 */
#ifdef CFG_USE_SCALABILITYCLASS3

/*
 *  SC3/SC4における前状態生成用信頼関数(ActivateTask)
 *  (非信頼OSAPから全タスクへActivateTaskを発行可能とする)
 */
TRUSTEDFUNCTION(TRUSTED_AktspTfnActivateTask, FunctionIndex, FunctionParams)
{
	StatusType		ercd;
	AktspTfParam	*local = FunctionParams;

	ercd = ActivateTask(local->TaskID);

	return ercd;
}

/*
 *  SC3/SC4における前状態生成用信頼関数(SetEvent)
 *  (非信頼OSAPから全タスクへSetEventを発行可能とする)
 */
TRUSTEDFUNCTION(TRUSTED_AktspTfnSetEvent, FunctionIndex, FunctionParams)
{
	StatusType		ercd;
	AktspTfParam	*local = FunctionParams;

	ercd = SetEvent(local->TaskID, local->Mask);

	return ercd;
}

#ifdef TotalNumberOfCores
/*
 *  SC3-MC/SC4-MCにおける前状態生成用信頼関数(RaiseInterCoreInterrupt)
 *  (非信頼OSAPから全ICISRへRaiseInterCoreInterruptを発行可能とする)
 */
TRUSTEDFUNCTION(TRUSTED_AktspTfnRaiseInterCoreInterrupt, FunctionIndex, FunctionParams)
{
	StatusType		ercd;
	AktspTfParam	*local = FunctionParams;

	ercd = RaiseInterCoreInterrupt(local->ISRID);

	return ercd;
}
#endif /* TotalNumberOfCores */

/*
 *  SC3/SC4における異常時シャットダウン用信頼関数(ShutdownOS)
 *  (非信頼OSAPからShutdownOSを発行可能とする)
 */
TRUSTEDFUNCTION(TRUSTED_AktspTfnShutdownOS, FunctionIndex, FunctionParams)
{
	AktspTfParam *local = FunctionParams;

	AKTSP_SHUTDOWN_OS(local->Error);

	return local->Error;
}

/*
 *  AktspTfnActivateTaskへのラッパー関数
 */
StatusType
AktspTrustActivateTask(TaskType TaskID)
{
	StatusType					ercd;
	AktspTfParam				local;
	TrustedFunctionIndexType	tfnid;

#ifdef TotalNumberOfCores
	tfnid = AKTSP_TFN_ACTIVATE_TASK_INDEX[GetCoreID()];
#else
	tfnid = AktspTfnActivateTask;
#endif /* TotalNumberOfCores */

	local.TaskID = TaskID;
	ercd = CallTrustedFunction(tfnid, &local);

	return ercd;
}

/*
 *  AktspTfnSetEventへのラッパー関数
 */
StatusType
AktspTrustSetEvent(TaskType TaskID, EventMaskType Mask)
{
	StatusType		ercd;
	AktspTfParam	local;
	TrustedFunctionIndexType	tfnid;

#ifdef TotalNumberOfCores
	tfnid = AKTSP_TFN_SET_EVENT_INDEX[GetCoreID()];
#else
	tfnid = AktspTfnSetEvent;
#endif /* TotalNumberOfCores */

	local.TaskID = TaskID;
	local.Mask = Mask;
	ercd = CallTrustedFunction(tfnid, &local);

	return ercd;
}

#ifdef TotalNumberOfCores
/*
 *  AktspTfnRaiseInterCoreInterruptへのラッパー関数
 */
StatusType
AktspTrustRaiseInterCoreInterrupt(ISRType ISRID)
{
	StatusType		ercd;
	AktspTfParam	local;

	local.ISRID = ISRID;
	ercd = CallTrustedFunction(AKTSP_TFN_RAISE_INTER_CORE_INTERRUPT_INDEX[GetCoreID()], &local);

	return ercd;
}
#endif /* TotalNumberOfCores */

/*
 *  AktspTfnShutdownOSへのラッパー関数
 */
void
AktspTrustShutdownOS(StatusType Error)
{
	AktspTfParam				local;
	TrustedFunctionIndexType	tfnid;

#ifdef TotalNumberOfCores
	CCB		*p_ccb = get_my_p_ccb();               /* コア管理の為のメモリ領域 */
	uint16	callevel_stat = p_ccb->callevel_stat;  /* 呼び出したコアの実行中のコンテキスト */
	tfnid = AKTSP_TFN_SHUTDOWN_OS_INDEX[GetCoreID()];
#else
	tfnid = AktspTfnShutdownOS;
#endif /* TotalNumberOfCores */

	/* スタートアップフックからの呼出しの場合(非信頼OSAPからはシャットダウン不可) */
	if ((callevel_stat & TCL_STARTUP) != 0U) {
		AKTSP_SHUTDOWN_OS(E_OK);
	}

	/* 割込み禁止を解除 */
	if ((callevel_stat & TSYS_DISALLINT) != 0U) {
		EnableAllInterrupts();
	}

	local.Error = Error;
	CallTrustedFunction(tfnid, &local);
}

#endif /* CFG_USE_SCALABILITYCLASS3 */
