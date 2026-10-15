#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2015-2016 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2015-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
# Copyright (C) 2015-2016 by eSOL Co.,Ltd., JAPAN
# Copyright (C) 2015-2016 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2015-2016 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2015-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2015-2016 by SCSK Corporation, JAPAN
# Copyright (C) 2015-2016 by Sunny Giken Inc., JAPAN
# Copyright (C) 2015-2016 by SUZUKI MOTOR CORPORATION
# Copyright (C) 2015-2016 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2015-2016 by Witz Corporation
# Copyright (C) 2015-2016 by Fujitsu TEN Limited
# Copyright (C) 2015-2016 by JTEKT CORPORATION
# 
# 本ソフトウェアは，車載制御システム向け高品質プラットフォームに
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2011-2013 by Spansion LLC, USA
# Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2011-2014 by Witz Corporation, JAPAN
#
# 本ソフトウェアは，TTGを元に，次世代車載システム向けRTOSの仕様検討及び
# 開発に関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの二次著作権は，上記の著作権者に帰属する．
# TTGの著作権表示は以下の通りである．
#
# $Id: CommonModule.rb 347 2014-09-17 00:28:35Z fsi-dankei $

#  TTG
#      TOPPERS Test Generator
#
#  Copyright (C) 2009-2011 by Center for Embedded Computing Systems
#              Graduate School of Information Science, Nagoya Univ., JAPAN
#  Copyright (C) 2010-2011 by Graduate School of Information Science,
#                             Aichi Prefectural Univ., JAPAN
#
#  上記著作権者は，以下の(1)~(4)の条件を満たす場合に限り，本ソフトウェ
#  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
#  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
#  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
#      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
#      スコード中に含まれていること．
#  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
#      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
#      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
#      の無保証規定を掲載すること．
#  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
#      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
#      と．
#    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
#        作権表示，この利用条件および下記の無保証規定を掲載すること．
#    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
#        報告すること．
#  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
#      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
#      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
#      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
#      免責すること．
#
#  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
#  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
#  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
#  用する者に対して，AUTOSARパートナーになることを求めている．
#
#  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#  の責任を負わない．
#
require "curses" unless defined?(Curses)  # Ruby 2.1+: see ruby3_compat.rb
require "rexml/document.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  include REXML

  #===================================================================
  # 変数のマクロ定義(Variable)
  #===================================================================
  # 変数名の定義
  VAR_ERCD             = "ercd"
  VAR_IOC_ERCD         = "iocercd"
  VAR_TSK              = "tsktype"
  VAR_ISR              = "isrtype"
  VAR_APPLICATION      = "apptype"
  VAR_ACCESS           = "accesstype"
  VAR_APPMODE          = "appmodetype"
  VAR_OBJACCESS        = "objaccesstype"
  VAR_STATE            = "state"
  VAR_BOOTCNT          = "bootcnt"
  VAR_ERROR            = "Error"
  VAR_FATAL_ERROR      = "FatalError"
  VAR_VTSK             = "vtsk"
  VAR_VRES             = "vres"
  VAR_VALM             = "valm"
  VAR_VSCHTBL          = "vschtbl"
  VAR_VSCHTBL_EXACT    = "vschtblexact"
  VAR_VCNT             = "vcnt"
  VAR_VISR             = "visr"
  VAR_VINT             = "vint"
  VAR_VSPN             = "vspn"
  VAR_VTFN             = "vtfn"
  VAR_VIOC             = "vioc"
  VAR_VICISR           = "vicisr"
  VAR_COREID           = "coreidtype"
  VAR_GCOV_LOCK_FLG    = "coverage_progress"
  VAR_CORENUM          = "corenum"
  VAR_FAULTY_CONTEX    = "faultycontex"

  # 変数の型の定義
  TYP_STATUS                       = "StatusType"
  TYP_STD_RETURN                   = "Std_ReturnType"
  TYP_APPMODE                      = "AppModeType"
  TYP_TSK                          = "TaskType"
  TYP_TSK_STATE                    = "TaskStateType"
  TYP_ISR                          = "ISRType"
  TYP_RES                          = "ResourceType"
  TYP_EVT_MASK                     = "EventMaskType"
  TYP_TICK                         = "TickType"
  TYP_CNT                          = "CounterType"
  TYP_SPN                          = "SpinlockIdType"
  TYP_CORE                         = "CoreIdType"
  TYP_ALMBASE                      = "AlarmBaseType"
  TYP_APPLICATION                  = "ApplicationType"
  TYP_ACCESS                       = "AccessType"
  TYP_OBJACCESS                    = "ObjectAccessType"
  TYP_PROTECT_RETURN               = "ProtectionReturnType"
  TYP_INTERRUPT_NUMBER             = "InterruptNumberType"
  TYP_IOC                          = "IocType"
  TYP_FAULTY_CONTEXT               = "FaultyContextType"
  TYP_UINT8                        = "uint8"
  TYP_UINT16                       = "uint16"
  TYP_UINT32                       = "uint32"
  TYP_UINT8_P                      = "uint8 *"
  TYP_UINT16_P                     = "uint16 *"
  TYP_UINT32_P                     = "uint32 *"
  TYP_SINT8                        = "sint8"
  TYP_SINT16                       = "sint16"
  TYP_SINT32                       = "sint32"
  TYP_FLOAT32                      = "float32"
  TYP_VOLATILE_UINT32              = "volatile uint32"
  TYP_VOID                         = "void"
  TYP_VOID_P                       = "void *"
  TYP_BOOL                         = "boolean"
  TYP_AKTSP_TSK_INFO               = "AktspTaskInfo"
  TYP_AKTSP_RES_INFO               = "AktspResourceInfo"
  TYP_AKTSP_CNT_INFO               = "AktspCounterInfo"
  TYP_AKTSP_ALM_INFO               = "AktspAlarmInfo"
  TYP_AKTSP_SCHTBL_INFO            = "AktspScheduleTableInfo"
  TYP_AKTSP_SCHTBL_EXACT_INFO      = "AktspScheduleTableExactionInfo"
  TYP_AKTSP_ISR_INFO               = "AktspISRInfo"
  TYP_AKTSP_INT_INFO               = "AktspIntStateInfo"
  TYP_AKTSP_SPN_INFO               = "AktspSpinlockInfo"
  TYP_AKTSP_TFN_INFO               = "AktspTrustedFunctionInfo"
  TYP_AKTSP_STACK_INFO             = "AktspStackOverflowInfo"
  TYP_AKTSP_IOC_INFO               = "AktspIocInfo"
  TYP_AKTSP_IOC_DATA_INT_PRIM      = "AktspIocDataIntegerTypePrim"
  TYP_AKTSP_IOC_DATA_INT_NOPRIM    = "AktspIocDataIntegerTypeNoPrim"
  TYP_AKTSP_IOC_DATA_STRUCT_PRIM   = "AktspIocDataStructTypePrim"
  TYP_AKTSP_IOC_DATA_STRUCT_NOPRIM = "AktspIocDataStructTypeNoPrim"
  TYP_AKTSP_ICISR_INFO             = "AktspIcISRInfo"

  # 変数の型と名前の対応
  GRP_VAR_TYPE = {
    TYP_STATUS                  => VAR_ERCD,
    TYP_STD_RETURN              => VAR_IOC_ERCD,
    TYP_TSK                     => VAR_TSK,
    TYP_ISR                     => VAR_ISR,
    TYP_APPLICATION             => VAR_APPLICATION,
    TYP_ACCESS                  => VAR_ACCESS,
    TYP_APPMODE                 => VAR_APPMODE,
    TYP_OBJACCESS               => VAR_OBJACCESS,
    TYP_PROTECT_RETURN          => VAR_FATAL_ERROR,
    TYP_AKTSP_TSK_INFO          => VAR_VTSK,
    TYP_AKTSP_RES_INFO          => VAR_VRES,
    TYP_AKTSP_CNT_INFO          => VAR_VCNT,
    TYP_AKTSP_ALM_INFO          => VAR_VALM,
    TYP_AKTSP_SCHTBL_INFO       => VAR_VSCHTBL,
    TYP_AKTSP_SCHTBL_EXACT_INFO => VAR_VSCHTBL_EXACT,
    TYP_AKTSP_ISR_INFO          => VAR_VISR,
    TYP_AKTSP_SPN_INFO          => VAR_VSPN,
    TYP_AKTSP_INT_INFO          => VAR_VINT,
    TYP_AKTSP_TFN_INFO          => VAR_VTFN,
    TYP_AKTSP_IOC_INFO          => VAR_VIOC,
    TYP_CORE                    => VAR_COREID,
    TYP_UINT32                  => VAR_CORENUM,
    TYP_AKTSP_ICISR_INFO        => VAR_VICISR,
    TYP_FAULTY_CONTEXT          => VAR_FAULTY_CONTEX
  }

  # グローバル変数定義する型
  GRP_GLOBAL_TYPE = []

  #===================================================================
  # 関数のマクロ定義(Function)
  #===================================================================
  # 関数名の定義
  FNC_MAIN                = "main"
  FNC_CHECK_MAIN          = "AktgCheckMainTask"
  FNC_OUTPUT_LOG_0        = "AktspOutputLog_0"
  FNC_OUTPUT_LOG_1        = "AktspOutputLog_1"
  FNC_OUTPUT_LOG_2        = "AktspOutputLog_2"
  FNC_OUTPUT_LOG_3        = "AktspOutputLog_3"
  FNC_OUTPUT_LOG_4        = "AktspOutputLog_4"
  FNC_CHECK_ERCD          = "CheckErcd"
  FNC_CHECK_ASSERT        = "CheckAssert"
  FNC_CHECK_POINT         = "AktspCheckPoint"
  FNC_WAIT_CHECK_POINT    = "AktspWaitCheckPoint"
  FNC_CHECK_FINISH        = "AktspCheckFinish"
  FNC_MC_CHECK_POINT      = "AktspMcCheckPoint"
  FNC_MC_WAIT_CHECK_POINT = "AktspMcWaitCheckPoint"
  FNC_MC_CHECK_FINISH     = "AktspMcCheckFinish"
  FNC_BARRIER_SYNC        = "AktspBarrierSync"
  FNC_GET_CP_STATE        = "AktspGetCpState"
  FNC_SET_CP_STATE        = "AktspSetCpState"
  FNC_WAIT_FINISH_SYNC    = "AktspWaitFinishSync"
  FNC_STATE_SYNC          = "AktspStateSync"
  FNC_HWCOUNTER_STOP      = "AktspStopHardwareCounter"
  FNC_HWCOUNTER_START     = "AktspStartHardwareCounter"
  FNC_HWCOUNTER_INIT      = "AktspInitHardwareCounter"
  FNC_HWCOUNTER_INCREMENT = "AktspIncrementHardwareCounter"

  # 割込み関連の関数
  FNC_INT_RAISE      = "AktspRaiseInterrupt"
  FNC_CLEAR_INT_REQ  = "AktspClearIntRequest"
  FNC_CANCEL_INT_REQ = "AktspCancelIntRequest"

  # フック起動関連
  FNC_RAISE_ERROR_HOOK      = "AktspRaiseErrorHook()"
  FNC_RAISE_PROTECTION_HOOK = "AktspRaiseProtectionHook()"
  FNC_PROTECTION_HOOK_INIT  = "AktspProtectionHookInit()"

  # 状態確認API
  FNC_VERIFY_TSK                = "AktspVerifyTask"
  FNC_VERIFY_TSK_REL_RES        = "AktspVerifyTaskRelResource"
  FNC_VERIFY_TSK_REL_EVT        = "AktspVerifyTaskRelEvent"
  FNC_VERIFY_TSK_GET_RES        = "AktspVerifyTaskGetResource"
  FNC_VERIFY_TSK_INT_RES        = "AktspVerifyTaskGetInternalResource"
  FNC_VERIFY_TSK_ACC_OSAP       = "AktspVerifyTaskAccessOsap"
  FNC_VERIFY_TSK_APP_MODE       = "AktspVerifyTaskApplicationMode"
  FNC_VERIFY_RES                = "AktspVerifyResource"
  FNC_VERIFY_RES_ACC_OSAP       = "AktspVerifyResourceAccessOsap"
  FNC_VERIFY_EVT                = "AktspVerifyEvent"
  FNC_VERIFY_C1ISR              = "AktspVerifyC1Isr"
  FNC_VERIFY_C2ISR              = "AktspVerifyC2Isr"
  FNC_VERIFY_C2ISR_REL_RES      = "AktspVerifyC2IsrRelResource"
  FNC_VERIFY_C2ISR_GET_RES      = "AktspVerifyC2IsrGetResource"
  FNC_VERIFY_C2ISR_ACC_OSAP     = "AktspVerifyC2IsrAccessOsap"
  FNC_VERIFY_INT_STATE          = "AktspVerifyIntState"
  FNC_VERIFY_DIS_INT_ORDER      = "AktspVerifyDisIntOrder"
  FNC_VERIFY_CNT                = "AktspVerifyCounter"
  FNC_VERIFY_CNT_ACC_OSAP       = "AktspVerifyCounterAccessOsap"
  FNC_VERIFY_ALM                = "AktspVerifyAlarm"
  FNC_VERIFY_ALM_ACC_OSAP       = "AktspVerifyAlarmAccessOsap"
  FNC_VERIFY_ALM_APP_MODE       = "AktspVerifyAlarmApplicationMode"
  FNC_VERIFY_SCHTBL             = "AktspVerifyScheduleTable"
  FNC_VERIFY_SCHTBL_EXACT       = "AktspVerifyScheduleTableExaction"
  FNC_VERIFY_SCHTBL_ACC_OSAP    = "AktspVerifyScheduleTableAccessOsap"
  FNC_VERIFY_SCHTBL_APP_MODE    = "AktspVerifyScheduleTableApplicationMode"
  FNC_VERIFY_SPN                = "AktspVerifySpinlock"
  FNC_VERIFY_TSK_GET_SPN        = "AktspVerifyTaskGetSpinlock"
  FNC_VERIFY_C2ISR_GET_SPN      = "AktspVerifyC2IsrGetSpinlock"
  FNC_VERIFY_SPN_ACC_OSAP       = "AktspVerifySpinlockAccessOsap"
  FNC_VERIFY_TFN                = "AktspVerifyTrustedFunction"
  FNC_VERIFY_STARTUP_HOOK_OSAP  = "AktspVerifyStartupHookOsap"
  FNC_VERIFY_SHUTDOWN_HOOK_OSAP = "AktspVerifyShutdownHookOsap"
  FNC_VERIFY_ERROR_HOOK_OSAP    = "AktspVerifyErrorHookOsap"
  FNC_VERIFY_IOC                = "AktspVerifyIoc"
  FNC_VERIFY_IOC_SENDER         = "AktspVerifyIocSender"
  FNC_VERIFY_ICISR              = "AktspVerifyIcIsr"
  FNC_VERIFY_ICISR_REL_RES      = "AktspVerifyIcIsrRelResource"
  FNC_VERIFY_ICISR_GET_RES      = "AktspVerifyIcIsrGetResource"
  FNC_VERIFY_ICISR_ACC_OSAP     = "AktspVerifyIcIsrAccessOsap"
  FNC_VERIFY_ICISR_GET_SPN      = "AktspVerifyIcIsrGetSpinlock"
  FNC_VERIFY_OSAP               = "AktspVerifyOsapState"

  # 構造体情報API
  FNC_MAKE_STR_TSK          = "AktspMakeTaskInfo"
  FNC_MAKE_STR_RES          = "AktspMakeResourceInfo"
  FNC_MAKE_STR_ISR          = "AktspMakeISRInfo"
  FNC_MAKE_STR_INT          = "AktspMakeIntStateInfo"
  FNC_MAKE_STR_CNT          = "AktspMakeCounterInfo"
  FNC_MAKE_STR_ALM          = "AktspMakeAlarmInfo"
  FNC_MAKE_STR_SCHTBL       = "AktspMakeScheduleTableInfo"
  FNC_MAKE_STR_SCHTBL_EXACT = "AktspMakeScheduleTableExactionInfo"
  FNC_MAKE_STR_SPN          = "AktspMakeSpinlockInfo"
  FNC_MAKE_STR_TFN          = "AktspMakeTrustedFunctionInfo"
  FNC_MAKE_STR_IOC          = "AktspMakeIocInfo"
  FNC_MAKE_STR_ICISR        = "AktspMakeIcISRInfo"

  # GCOV関連
  FNC_GCOV_PAUSE        = "gcov_pause"
  FNC_GCOV_RESUME       = "gcov_resume"
  FNC_GCOV_DUMP         = "gcov_dump"
  FNC_GCOV_C_PAUSE      = "#{FNC_GCOV_PAUSE}()"
  FNC_GCOV_C_RESUME     = "#{FNC_GCOV_RESUME}()"
  FNC_GCOV_C_DUMP       = "#{FNC_GCOV_DUMP}()"

  # その他テストライブラリ関連
  FNC_INITIALIZE_TEST_LIB           = "AktspInitializeTestLib()"
  FNC_INITIALIZE_TEST_LIB_EACH_CORE = "AktspInitializeTestLibEachCore()"
  FNC_INITIALIZE_STACK              = "AktspInitializeStack"
  FNC_INFINITE_LOOP                 = "AktspInfiniteLoop()"
  FNC_CHECK_STACK_USAGE             = "AktspCheckStackUsage"
  FNC_TFN_ACTIVATE_TASK             = "AktspTfnActivateTask"
  FNC_TFN_SET_EVENT                 = "AktspTfnSetEvent"
  FNC_TFN_SHUTDOWN_OS               = "AktspTfnShutdownOS"
  FNC_TFN_RAISE_INTERCORE_INTERRUPT = "AktspTfnRaiseInterCoreInterrupt"
  FNC_GET_DATA_FROM_IOC             = "AktspGetDataFromIoc"
  FNC_CALL_FROM_LAST_MAIN_FUNC      = "AktspCallFromLastMainFunc()"


  #===================================================================
  # システムサービスのマクロ定義(カーネルのシステムサービス)
  #===================================================================
  # システムサービスのマクロ定義
  SS_GET_APP_MODE    = "GetActiveApplicationMode"
  SS_GET_CORE_ID     = "GetCoreID"
  SS_ACT_TSK         = "ActivateTask"
  SS_TER_TSK         = "TerminateTask"
  SS_CHAIN_TSK       = "ChainTask"
  SS_SCHEDULE        = "Schedule"
  SS_GET_TSK_ID      = "GetTaskID"
  SS_GET_TSK_STAT    = "GetTaskState"
  SS_GET_ISR_ID      = "GetISRID"
  SS_DIS_ALL_INT     = "DisableAllInterrupts"
  SS_ENA_ALL_INT     = "EnableAllInterrupts"
  SS_SUS_ALL_INT     = "SuspendAllInterrupts"
  SS_RSM_ALL_INT     = "ResumeAllInterrupts"
  SS_SUS_OS_INT      = "SuspendOSInterrupts"
  SS_RSM_OS_INT      = "ResumeOSInterrupts"
  SS_ENA_INT_SRC     = "EnableInterruptSource"
  SS_DIS_INT_SRC     = "DisableInterruptSource"
  SS_SET_EVT         = "SetEvent"
  SS_CLR_EVT         = "ClearEvent"
  SS_GET_EVT         = "GetEvent"
  SS_WAIT_EVT        = "WaitEvent"
  SS_GET_RES         = "GetResource"
  SS_GET_NST_RES     = "GetNestedResource"
  SS_REL_RES         = "ReleaseResource"
  SS_INC_CNT         = "IncrementCounter"
  SS_GET_CNT_VAL     = "GetCounterValue"
  SS_ELAPSED_VAL     = "GetElapsedValue"
  SS_GET_ALM_BASE    = "GetAlarmBase"
  SS_GET_ALM         = "GetAlarm"
  SS_SET_REL_ALM     = "SetRelAlarm"
  SS_SET_ABS_ALM     = "SetAbsAlarm"
  SS_CAN_ALM         = "CancelAlarm"
  SS_STA_SCHTBL_REL  = "StartScheduleTableRel"
  SS_STA_SCHTBL_ABS  = "StartScheduleTableAbs"
  SS_STP_SCHTBL      = "StopScheduleTable"
  SS_NXT_SCHTBL      = "NextScheduleTable"
  SS_STA_SCHTBL_SNC  = "StartScheduleTableSynchron"
  SS_SNC_SCHTBL      = "SyncScheduleTable"
  SS_SET_SCHTBL_ASNC = "SetScheduleTableAsync"
  SS_GET_SCHTBL_STAT = "GetScheduleTableStatus"
  SS_GET_APP_ID      = "GetApplicationID"
  SS_CHK_ISR_MEM_ACC = "CheckISRMemoryAccess"
  SS_CHK_TSK_MEM_ACC = "CheckTaskMemoryAccess"
  SS_CHK_OBJ_ACC     = "CheckObjectAccess"
  SS_CHK_OBJ_OWNSHIP = "CheckObjectOwnership"
  SS_TER_APP         = "TerminateApplication"
  SS_ALL_ACC         = "AllowAccess"
  SS_APP_STAT        = "GetApplicationState"
  SS_GET_SPN         = "GetSpinlock"
  SS_REL_SPN         = "ReleaseSpinlock"
  SS_TRY_SPN         = "TryToGetSpinlock"
  SS_START_OS        = "StartOS"
  SS_START_CORE      = "StartCore"
  SS_SHUTDOWN_OS     = "ShutdownOS"
  SS_SHUTDOWN_ALL    = "ShutdownAllCores"
  SS_CALL_TFN        = "CallTrustedFunction"
  SS_RAISE_ICISR     = "RaiseInterCoreInterrupt"
  SS_CHK_TSK_ACC     = "CheckTaskAccess"
  SS_CHK_ISR_ACC     = "CheckISRAccess"
  SS_CHK_ALM_ACC     = "CheckAlarmAccess"
  SS_CHK_RES_ACC     = "CheckResourceAccess"
  SS_CHK_CNT_ACC     = "CheckCounterAccess"
  SS_CHK_SCHTBL_ACC  = "CheckScheduleTableAccess"
  SS_CHK_SPN_ACC     = "CheckSpinlockAccess"
  SS_CHK_TSK_OWNSHIP = "CheckTaskOwnership"
  SS_CHK_ISR_OWNSHIP = "CheckISROwnership"
  SS_CHK_ALM_OWNSHIP = "CheckAlarmOwnership"
  SS_CHK_CNT_OWNSHIP = "CheckCounterOwnership"
  SS_CHK_SCHTBL_OWNSHIP = "CheckScheduleTableOwnership"
  SS_GETFAULTY_CONTEXT  = "GetFaultyContext"
  SS_START_NON_AUTOSAR_CORE = "StartNonAutosarCore"
  TR_ACT_TSK         = "AktspTrustActivateTask"
  TR_SET_EVT         = "AktspTrustSetEvent"
  TR_RAISE_ICISR     = "AktspTrustRaiseInterCoreInterrupt"

  # 静的APIのマクロ定義
  SAPI_DEF_OS       = "DEF_OS"
  SAPI_DEF_OSAP     = "DEF_OSAP"
  SAPI_LNK_SEC      = "LNK_SEC"
  SAPI_DEF_HOOK     = "DEF_HOOK"
  SAPI_DEF_OSTK     = "DEF_OS_STK"
  SAPI_DEF_HSTK     = "DEF_HOOK_STK"
  SAPI_DEF_NTHSTK   = "DEF_NTHOOK_STK"
  SAPI_CRE_APP      = "CRE_APP"
  SAPI_CRE_TSK      = "CRE_TSK"
  SAPI_CRE_RES      = "CRE_RES"
  SAPI_CRE_EVT      = "CRE_EVT"
  SAPI_CRE_CNT      = "CRE_CNT"
  SAPI_CRE_ALM      = "CRE_ALM"
  SAPI_CRE_SCHTBL   = "CRE_SCHTBL"
  SAPI_DEF_EXPIREPT = "DEF_EXPIREPT"
  SAPI_CRE_ISR      = "CRE_ISR"
  SAPI_CRE_SPN      = "CRE_SPN"
  SAPI_CRE_TFN      = "CRE_TFN"
  SAPI_ATT_MOD      = "ATT_MOD"
  SAPI_ATT_MEM      = "ATT_MEM"
  SAPI_ATT_SEC      = "ATT_SEC"
  SAPI_CRE_IOC      = "CRE_IOC"
  SAPI_DEF_IOC_DATA = "DEF_IOC_DATA"
  SAPI_DEF_IOC_SND  = "DEF_IOC_SND"
  SAPI_DEF_IOC_RCV  = "DEF_IOC_RCV"
  SAPI_DEF_IOC_PRIM = "DEF_IOC_PRIM"
  SAPI_DEF_ICI      = "DEF_ICI"

  #===================================================================
  # XMLのマクロ定義
  #===================================================================
  XML_AUTOSAR_FIXED_ATT = {"xmlns"              => "http://autosar.org/schema/r4.0",
                           "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
                           "xsi:schemaLocation" => "http://autosar.org/schema/r4.0 AUTOSAR_4-0-3_STRICT.xsd"}

  XML_ISR_TYPE_1 = "CATEGORY_1"
  XML_ISR_TYPE_2 = "CATEGORY_2"

  XML_IMPL_DATA_TYPE_PACKAGE = "/ImplementationDataTypes/"

  XML_ROOT_PATH = "/AUTOSAR/EcucDefs/Os"
  XML_REF_PATH  = "/Os/Os/"
  XML_SNAME     = "SHORT-NAME"
  XML_PARAM     = "PARAMETER-VALUES"
  XML_REFER     = "REFERENCE-VALUES"
  XML_SUB       = "SUB-CONTAINERS"

  XML_C_APP_MODE = "OsAppMode"

  XML_C_INCLUDE      = "OsInclude"
  XML_P_INCLUDE_FILE = "OsIncludeFileName"

  XML_C_OS             = "OsOS"
  XML_P_CORE_NUM       = "OsNumberOfCores"
  XML_P_SCAL_CLASS     = "OsScalabilityClass"
  XML_P_VIO_HAND_LVL   = "OsViolationHandlingLevel"
  XML_P_TIM_PRO_LVL    = "OsTimingProtectionLevel"
  XML_P_MEM_PRO_LVL    = "OsMemoryProtectionLevel"
  XML_P_STK_MON        = "OsStackMonitoring"
  XML_P_STATUS         = "OsStatus"
  XML_P_USE_GET_SRV_ID = "OsUseGetServiceId"
  XML_P_USE_PARAM_ACC  = "OsUseParameterAccess"
  XML_P_MASTER_CORE_ID = "OsMasterCoreId"

  XML_C_HOOKS    = "OsHooks"
  XML_P_ERR_HOOK = "OsErrorHook"
  XML_P_POS_HOOK = "OsPostTaskHook"
  XML_P_PRE_HOOK = "OsPreTaskHook"
  XML_P_PRO_HOOK = "OsProtectionHook"
  XML_P_SHU_HOOK = "OsShutdownHook"
  XML_P_STA_HOOK = "OsStartupHook"
  XML_P_GROUP_HOOK = [XML_P_ERR_HOOK,
                      XML_P_POS_HOOK,
                      XML_P_PRE_HOOK,
                      XML_P_PRO_HOOK,
                      XML_P_SHU_HOOK,
                      XML_P_STA_HOOK]

  XML_C_OSSTK      = "OsOsStack"
  XML_P_OSSTK_SZ   = "OsOsStackSize"
  XML_P_OSSTK_ADD  = "OsOsStackStartAddress"
  XML_P_OSSTK_CORE = "OsOsStackCoreAssignment"

  XML_C_HOOKSTK      = "OsHookStack"
  XML_P_HOOKSTK_SZ   = "OsHookStackSize"
  XML_P_HOOKSTK_ADD  = "OsHookStackStartAddress"
  XML_P_HOOKSTK_CORE = "OsHookStackCoreAssignment"

  XML_C_NTHOOKSTK      = "OsNonTrustedHookStack"
  XML_P_NTHOOKSTK_SZ   = "OsNonTrustedHookStackSize"
  XML_P_NTHOOKSTK_ADD  = "OsNonTrustedHookStackStartAddress"
  XML_P_NTHOOKSTK_CORE = "OsNonTrustedHookStackCoreAssignment"

  XML_C_SCYC         = "OsSystemCycle"
  XML_P_SCYC_TIM     = "OsSystemCycleTime"
  XML_P_SCYC_TWD     = "OsSystemCycleTimeWindow"
  XML_P_SCYC_TWD_STA = "OsSystemCycleTimeWindowStart"
  XML_P_SCYC_TWD_LEN = "OsSystemCycleTimeWindowLength"

  XML_C_LNK_SEC   = "OsLinkSection"
  XML_P_L_NAME    = "OsLinkSectionName"
  XML_P_L_MEM_REG = "OsLinkSectionMemoryRegionRef"

  XML_C_TSK       = "OsTask"
  XML_P_T_ACT     = "OsTaskActivation"
  XML_P_T_PRI     = "OsTaskPriority"
  XML_P_T_SCHE    = "OsTaskSchedule"
  XML_P_T_ACC_APP = "OsTaskAccessingApplication"
  XML_P_T_EVT     = "OsTaskEventRef"
  XML_P_T_RES     = "OsTaskResourceRef"
  XML_P_T_STKSZ   = "OsTaskStackSize"
  XML_P_T_STKADD  = "OsTaskStackStartAddress"
  XML_P_T_SSTKSZ  = "OsTaskSystemStackSize"
  XML_P_T_SSTKADD = "OsTaskSystemStackStartAddress"
  XML_P_T_REG      = "OsTaskMemoryRegion"
  XML_P_T_STK_REG  = "OsTaskStackMemoryRegion"

  XML_C_T_AUTO_STA = "OsTaskAutostart"
  XML_P_T_APP_MODE = "OsTaskAppModeRef"

  XML_C_ISR       = "OsIsr"
  XML_P_I_CAT     = "OsIsrCategory"
  XML_P_I_NUM     = "OsIsrInterruptNumber"
  XML_P_I_PRI     = "OsIsrInterruptPriority"
  XML_P_I_SRC     = "OsIsrInterruptSource"
  XML_P_I_ACC_APP = "OsIsrAccessingApplication"
  XML_P_I_RES     = "OsIsrResourceRef"
  XML_P_I_STKSZ   = "OsIsrStackSize"
  XML_P_I_STKADD  = "OsIsrStackStartAddress"
  XML_P_I_SSTKSZ  = "OsIsrSystemStackSize"
  XML_P_I_SSTKADD = "OsIsrSystemStackStartAddress"

  XML_C_EVT    = "OsEvent"
  XML_P_E_MASK = "OsEventMask"

  XML_C_RES       = "OsResource"
  XML_P_R_ACC_APP = "OsResourceAccessingApplication"
  XML_P_R_PROP    = "OsResourceProperty"
  XML_P_R_LINK    = "OsResourceLinkedResourceRef"
  XML_P_R_REG     = "OsResourceMemoryRegion"

  XML_C_CNT        = "OsCounter"
  XML_P_C_MAX_VAL  = "OsCounterMaxAllowedValue"
  XML_P_C_MIN_CYC  = "OsCounterMinCycle"
  XML_P_C_TIC_BASE = "OsCounterTicksPerBase"
  XML_P_C_TYPE     = "OsCounterType"
  XML_P_C_SEC_TICK = "OsSecondsPerTick"
  XML_P_C_ISR      = "OsCounterIsrRef"
  XML_P_C_ACC_APP  = "OsCounterAccessingApplication"
  XML_P_C_REG      = "OsCounterMemoryRegion"

  XML_C_ALM       = "OsAlarm"
  XML_P_A_ACC_APP = "OsAlarmAccessingApplication"
  XML_P_A_CNT     = "OsAlarmCounterRef"

  XML_C_A_ACT = "OsAlarmAction"

  XML_C_A_ACT_TSK = "OsAlarmActivateTask"
  XML_P_A_ACT_TSK = "OsAlarmActivateTaskRef"

  XML_C_A_CBACK = "OsAlarmCallback"
  XML_P_A_CBACK = "OsAlarmCallbackName"

  XML_C_A_INCR_CNT = "OsAlarmIncrementCounter"
  XML_P_A_INCR_CNT = "OsAlarmIncrementCounterRef"

  XML_C_A_SET_EVT = "OsAlarmSetEvent"
  XML_P_A_SET_EVT = "OsAlarmSetEventRef"
  XML_P_A_EVT_TSK = "OsAlarmSetEventTaskRef"

  XML_C_A_AUTO_STA = "OsAlarmAutostart"
  XML_P_A_ALM_TIM  = "OsAlarmAlarmTime"
  XML_P_A_APP_MODE = "OsAlarmAppModeRef"
  XML_P_A_CYC_TIM  = "OsAlarmCycleTime"
  XML_P_A_STA_TYP  = "OsAlarmAutostartType"

  XML_C_SCHTBL     = "OsScheduleTable"
  XML_P_S_DUR      = "OsScheduleTableDuration"
  XML_P_S_REP      = "OsScheduleTableRepeating"
  XML_P_S_ACC_APP  = "OsSchTblAccessingApplication"
  XML_P_S_CNT      = "OsScheduleTableCounterRef"

  XML_C_S_AUTO_STA = "OsScheduleTableAutostart"
  XML_P_S_STA_VAL  = "OsScheduleTableStartValue"
  XML_P_S_STA_TYP  = "OsScheduleTableAutostartType"
  XML_P_S_APP_MODE = "OsScheduleTableAppModeRef"

  XML_C_S_EXP_PT = "OsScheduleTableExpiryPoint"
  XML_P_S_OFFSET = "OsScheduleTblExpPointOffset"

  XML_C_S_SET_EVT = "OsScheduleTableEventSetting"
  XML_P_S_SET_EVT = "OsScheduleTableSetEventRef"
  XML_P_S_EVT_TSK = "OsScheduleTableSetEventTaskRef"

  XML_C_S_ACT_TSK = "OsScheduleTableTaskActivation"
  XML_P_S_ACT_TSK = "OsScheduleTableActivateTaskRef"

  XML_C_S_SYNC     = "OsScheduleTableSync"
  XML_P_S_STRATEGY = "OsScheduleTblSyncStrategy"

  XML_C_SPN        = "OsSpinlock"
  XML_P_SP_ACC_APP = "OsSpinlockAccessingApplication"
  XML_P_SP_SCCR    = "OsSpinlockSuccessor"
  XML_P_SP_SUS_INT = "OsSpinlockLockMethod"

  XML_C_OS_APP    = "OsApplication"
  XML_P_O_CORE    = "OsApplicationCoreAssignment"
  XML_P_O_TRUSTED = "OsTrusted"
  XML_P_O_ALM     = "OsAppAlarmRef"
  XML_P_O_CNT     = "OsAppCounterRef"
  XML_P_O_ISR     = "OsAppIsrRef"
  XML_P_O_SCHTBL  = "OsAppScheduleTableRef"
  XML_P_O_TSK     = "OsAppTaskRef"
  XML_P_O_RE_TSK  = "OsRestartTask"
  XML_P_O_MEMSEC  = "OsAppMemorySectionRef"
  XML_P_O_MEMMOD  = "OsAppMemoryModuleRef"
  XML_P_O_MEMAREA = "OsAppMemoryAreaRef"
  XML_P_O_ICISR   = "OsAppInterCoreInterruptRef"
  XML_P_O_SCYCTWD = "OsSystemCycleTimeWindowRef"

  XML_C_O_HOOK  = "OsApplicationHooks"
  XML_P_O_H_ERR = "OsAppErrorHook"
  XML_P_O_H_SHU = "OsAppShutdownHook"
  XML_P_O_H_STA = "OsAppStartupHook"

  XML_C_O_TFN     = "OsApplicationTrustedFunction"
  XML_P_O_T_NAME  = "OsTrustedFunctionName"
  XML_P_O_T_STKSZ = "OsTrustedFunctionStackSize"

  XML_C_MEM_MOD  = "OsMemoryModule"
  XML_P_M_NAME   = "OsMemoryModuleName"
  XML_P_M_EXPORT = "OsMemoryModuleExport"

  XML_C_MEM_AREA = "OsMemoryArea"
  XML_P_A_WRITE  = "OsMemoryAreaWritable"
  XML_P_A_READ   = "OsMemoryAreaReadable"
  XML_P_A_EXEC   = "OsMemoryAreaExecutable"
  XML_P_A_CACHE  = "OsMemoryAreaCacheable"
  XML_P_A_IODEV  = "OsMemoryAreaDevice"
  XML_P_A_ADD    = "OsMemoryAreaStartAddress"
  XML_P_A_SIZE   = "OsMemoryAreaSize"

  XML_C_MEM_SEC   = "OsMemorySection"
  XML_P_S_NAME    = "OsMemorySectionName"
  XML_P_S_REG     = "OsMemorySectionRegionRef"
  XML_P_S_WRITE   = "OsMemorySectionWritable"
  XML_P_S_READ    = "OsMemorySectionReadable"
  XML_P_S_EXEC    = "OsMemorySectionExecutable"
  XML_P_S_SDATA   = "OsMemorySectionShort"
  XML_P_S_MEMINI  = "OsMemorySectionInitialize"
  XML_P_S_CACHE   = "OsMemorySectionCacheable"
  XML_P_S_IODEV   = "OsMemorySectionDevice"
  XML_P_S_EXPORT  = "OsMemorySectionExport"

  XML_C_IOC               = "OsIoc"

  XML_C_IOC_COM           = "OsIocCommunication"
  XML_P_IOC_BUF_LEN       = "OsIocBufferLength"

  XML_C_IOC_SND           = "OsIocSenderProperties"
  XML_P_IOC_SND_IMPL_KIND = "OsIocFunctionImplementationKind"
  XML_P_IOC_SND_ID        = "OsIocSenderId"
  XML_P_IOC_SND_OSAP      = "OsIocSendingOsApplicationRef"

  XML_C_IOC_RCV           = "OsIocReceiverProperties"
  XML_P_IOC_RCV_IMPL_KIND = "OsIocFunctionImplementationKind"
  XML_P_IOC_RCV_OSAP      = "OsIocReceivingOsApplicationRef"

  XML_C_IOC_DATA          = "OsIocDataProperties"
  XML_P_IOC_INI_VAL       = "OsIocInitValue"
  XML_P_IOC_DATA_TYPE     = "OsIocDataTypeRef"
  XML_P_IOC_INC_FILE      = "OsIocIncludeFile"
  XML_P_IOC_DATA_INDEX    = "OsIocDataPropertyIndex"

  XML_C_ICISR             = "OsInterCoreInterrupt"
  XML_P_IC_SRC            = "OsInterCoreInterruptInterruptSource"
  XML_P_IC_ACC_APP        = "OsInterCoreInterruptAccessingApplication"
  XML_P_IC_RES            = "OsInterCoreInterruptResourceRef"
  XML_P_IC_STKSZ          = "OsInterCoreInterruptStackSize"
  XML_P_IC_STKADD         = "OsInterCoreInterruptStackStartAddress"
  XML_P_IC_SSTKSZ         = "OsInterCoreInterruptSystemStackSize"
  XML_P_IC_SSTKADD        = "OsInterCoreInterruptSystemStackStartAddress"

  #===================================================================
  # Configureのマクロ定義(configre)
  #===================================================================
  CFG_VERSION                   = "version"                         # configre.yamlのバージョン
  CFG_MACRO                     = "macro"                           # マクロ設定がされているキー
  CFG_MC_MACRO                  = "mc_macro"                        # MC用マクロ設定がされているキー
  CFG_INVALID_ID                = "invalid_id"                      # 不正ID展開用マクロキー
  CFG_SCALABILITY_CLASS         = "scalability_class"               # スケーラビリティクラス
  CFG_VIOLATION_HANDLING_LEVEL  = "violation_handling_level"        # 保護違反時処理機能の機能レベル
  CFG_TIMING_PROTECTION_LEVEL   = "timing_protection_level"         # タイミング保護機能の機能レベル
  CFG_MEMORY_PROTECTION_LEVEL   = "memory_protection_level"         # メモリ保護機能の機能レベル
  CFG_STACK_MONITORING          = "stack_monitoring"                # スタックモニタリングの使用有無
  CFG_STACKFAULT_DETECTION      = "stackfault_detection"            # スタックオーバーフロー検出
  CFG_RETURN_STATUS             = "return_status"                   # エラーコード種別
  CFG_USE_GET_SERVICEID         = "use_get_serviceid"               # OSErrorGetServiceId()の使用有無
  CFG_USE_PARAMETER_ACCESS      = "use_parameter_access"            # エラーが発生したシステムサービスの引数取得の使用有無
  CFG_USE_C1ISR                 = "use_c1isr"                       # C1ISRの使用有無
  CFG_ERROR_HOOK                = "error_hook"                      # エラーフックの呼出し有無
  CFG_POST_TASK_HOOK            = "post_task_hook"                  # ポストタスクフックの呼出し有無
  CFG_PRE_TASK_HOOK             = "pre_task_hook"                   # プレタスクフックの呼出し有無
  CFG_PROTECTION_HOOK           = "protection_hook"                 # プロテクションフックの呼出し有無
  CFG_SHUTDOWN_HOOK             = "shutdown_hook"                   # シャットダウンフックの呼出し有無
  CFG_STARTUP_HOOK              = "startup_hook"                    # スタートアップフックの呼出し有無
  CFG_STARTUP_HOOK_OSAP         = "startup_hook_osap"               # OSAP固有のスタートアップフックの呼出しの有無
  CFG_SHUTDOWN_HOOK_OSAP        = "shutdown_hook_osap"              # OSAP固有のシャットダウンフックの呼出し有無
  CFG_ERROR_HOOK_OSAP           = "error_hook_osap"                 # OSAP固有のエラーフックの呼出し有無
  CFG_ALL_INTERRUPT_LOCK_BUDGET = "all_interrupt_lock_budget"       # 全割込み禁止バジェット(単位:秒)
  CFG_OS_INTERRUPT_LOCK_BUDGET  = "os_interrupt_lock_budget"        # OS管理割込み禁止バジェット(単位:秒)
  CFG_CONFORMANCE_CLASS         = "conformance_class"               # コンフォーマンスクラス
  CFG_TARGET_SPEC               = "target_spec"                     # テスト対象とする仕様
  CFG_FUNC_PROTECTION_HOOK      = "func_protection_hook"            # プロテクションフック起動関数の有無
  CFG_CORE_NUM                  = "core_num"                        # コア数
  CFG_USE_MULTI_CORE            = "use_multi_core"                  # マルチコアかどうか
  CFG_MASTER_CORE               = "master_core"                     # マスタコアID
  CFG_IRC_ARCH                  = "irc_arch"                        # IRCアーキテクチャ
  CFG_SUPPORT_ENADIS_INT_SOURCE = "support_enadis_interrupt_source" # EnableInterruptSource/DisableInterruptSourceのサポート
  CFG_FUNC_INTERRUPT            = "func_interrupt"                  # 割込み発生関数利用可否
  CFG_HARDWARE_COUNTER          = "func_hardware_counter"           # ハードウェアカウンタ利用可否
  CFG_HARDWARE_COUNTER_PARAM    = "hardware_counter_param"          # ハードウェアカウンタの設定情報
  CFG_HWCNT_COUNTER_ID          = "counter_id"                      # ハードウェアカウンタのカウンタID
  CFG_HWCNT_INTNO               = "intno"                           # ハードウェアカウンタに割付けるC2ISRの割込み番号
  CFG_HWCNT_INIINTPRI           = "iniintpri"                       # ハードウェアカウンタに割付けるC2ISRの割込み優先度
  CFG_HWCNT_INTATR              = "intatr"                          # ハードウェアカウンタに割付けるC2ISRの割込み属性
  CFG_HWCNT_MINCYC              = "mincyc"                          # 周期の最小値
  CFG_HWCNT_MAXVAL              = "maxval"                          # カウンタの最大値
  CFG_HWCNT_SECONDSPERTICK      = "secondspertick"                  # ハードウェアカウンタにおける1ティック当たりの実時間(秒)
  CFG_HWCNT_OSAP                = "osap"                            # ハードウェアカウンタが所属するOSAP
  CFG_HWCNT_ISRID               = "isrid"                           # ハードウェアカウンタに割付けるC2ISR
  CFG_STACK_SHARE               = "stack_share"                     # スタック共有モード
  CFG_OUT_FILE                  = "out_file_name"                   # 出力ファイル名
  CFG_APP_MODE                  = "app_mode_name"                   # StartOSに指定するアプリケーションモード
  CFG_DEFAULT_OSAP_ID           = "default_osap_id"                 # デフォルトOSAP
  CFG_WAIT_SPIN_LOOP            = "wait_spin_loop"                  # スピンロック取得待ちを確認するためのループ回数
  CFG_YAML_LIBRARY              = "yaml_lib"                        # YAMLライブラリ
  CFG_ENABLE_GCOV               = "enable_gcov"                     # GCOVを取得するか
  CFG_ENABLE_CPPTEST            = "enable_cpptest"                  # C++testを使用するか
  CFG_CPPTEST_USE_BUFFER        = "cpptest_use_buffer"              # C++testを使用時に，バッファーを使用するか
  CFG_CPPTEST_ONLY_DO           = "cpptest_only_do"                 # C++testを使用時に，doの処理のみ計測にするか
  CFG_ENABLE_LOG                = "enable_log"                      # ログを取得するか
  CFG_ENA_EXC_LOCK              = "enable_exc_in_cpulock"           # CPUロック中のCPU例外発生のサポート
  CFG_MAX_TASK_PRI              = "max_task_pri"                    # タスクの最大優先度
  CFG_MIN_TASK_PRI              = "min_task_pri"                    # タスクの最小優先度
  CFG_DEFINE_DECLARE            = "define_declare"                  # declareの有無
  CFG_CHECK_STACK_USAGE         = "check_stack_usage"               # スタック使用量表示の有無
  CFG_ONLY_MASTER_CORE          = "boot_only_master_core"           # マスタコアのみ起動するか
  CFG_NT_TASK_STACK_REGION      = "nt_task_stack_region"            # 非信頼タスクスタックを配置するメモリリージョン名
  CFG_INTER_CORE_INTERRUPT      = "inter_core_interrupt"            # コア間割込みの有無
  CFG_ICISR_CONVERT             = "icisr_convert"                   # コア間割込み変換モード
  CFG_ICISR_PRI                 = "icisr_pri"                       # コア間割込みへ変換するC2ISRの優先度

  CFG_FILE                      = "configure_file"                  # 読み込む設定ファイル
  CFG_TEST_FLOW                 = "test_flow_mode"                  # テストフロー出力モード
  CFG_DEBUG_MODE                = "debug_mode"                      # デバッグモード
  CFG_NO_PROGRESS_BAR           = "no progress bar"                 # プログレスバー非表示モード
  CFG_ENABLE_SAPI               = "enable_sapi"                     # 静的API出力が有効か(未サポート)
  CFG_ENABLE_ALL_HOOK           = "enable_all_hook"                 # 全てのフックを有効にする
  CFG_ENABLE_FORCED_MERGE       = "enable forced merge"             # 強制マージする
  
  CFG_USE_TIME_PARTITIONING           = "use_time_partitioning"            # 時間パーティショニング機能の有無
  CFG_SYSTEM_CYCLE_TIME               = "system_cycle_time"                # システム周期時間
  CFG_SYSTEM_CYCLE_TIME_WINDOW_START  = "system_cycle_time_window_start"   # タイムウィンドウ開始時刻
  CFG_SYSTEM_CYCLE_TIME_WINDOW_LENGTH = "system_cycle_time_window_length"  # タイムウィンドウ終了時刻

  # configureに指定必須な項目
  GRP_CFG_NECESSARY_KEYS = [
    CFG_VERSION,
    CFG_MACRO,
    CFG_MC_MACRO,
    CFG_SCALABILITY_CLASS,
    CFG_VIOLATION_HANDLING_LEVEL,
    CFG_TIMING_PROTECTION_LEVEL,
    CFG_MEMORY_PROTECTION_LEVEL,
    CFG_STACK_MONITORING,
    CFG_STACKFAULT_DETECTION,
    CFG_RETURN_STATUS,
    CFG_USE_GET_SERVICEID,
    CFG_USE_PARAMETER_ACCESS,
    CFG_USE_C1ISR,
    CFG_ERROR_HOOK,
    CFG_POST_TASK_HOOK,
    CFG_PRE_TASK_HOOK,
    CFG_PROTECTION_HOOK,
    CFG_SHUTDOWN_HOOK,
    CFG_STARTUP_HOOK,
    CFG_STARTUP_HOOK_OSAP,
    CFG_SHUTDOWN_HOOK_OSAP,
    CFG_ERROR_HOOK_OSAP,
    CFG_ALL_INTERRUPT_LOCK_BUDGET,
    CFG_OS_INTERRUPT_LOCK_BUDGET,
    CFG_CONFORMANCE_CLASS,
    CFG_TARGET_SPEC,
    CFG_FUNC_PROTECTION_HOOK,
    CFG_CORE_NUM,
    CFG_USE_MULTI_CORE,
    CFG_MASTER_CORE,
    CFG_IRC_ARCH,
    CFG_SUPPORT_ENADIS_INT_SOURCE,
    CFG_FUNC_INTERRUPT,
    CFG_HARDWARE_COUNTER,
    CFG_HARDWARE_COUNTER_PARAM,
    CFG_STACK_SHARE,
    CFG_OUT_FILE,
    CFG_APP_MODE,
    CFG_DEFAULT_OSAP_ID,
    CFG_WAIT_SPIN_LOOP,
    CFG_YAML_LIBRARY,
    CFG_ENABLE_GCOV,
    CFG_ENABLE_CPPTEST,
    CFG_CPPTEST_USE_BUFFER,
    CFG_CPPTEST_ONLY_DO,
    CFG_ENABLE_LOG,
    CFG_MAX_TASK_PRI,
    CFG_MIN_TASK_PRI,
    CFG_DEFINE_DECLARE,
    CFG_CHECK_STACK_USAGE,
    CFG_NT_TASK_STACK_REGION,
    CFG_INTER_CORE_INTERRUPT,
    CFG_ICISR_CONVERT,
    CFG_ICISR_PRI
  ]

  # ハードウェアカウンタの設定情報に必要な項目
  GRP_CFG_HWCNT_NECESSARY_KEYS = [
    CFG_HWCNT_COUNTER_ID,
    CFG_HWCNT_INTNO,
    CFG_HWCNT_INIINTPRI,
    CFG_HWCNT_INTATR,
    CFG_HWCNT_MINCYC,
    CFG_HWCNT_MAXVAL,
    CFG_HWCNT_SECONDSPERTICK,
    CFG_HWCNT_OSAP,
    CFG_HWCNT_ISRID
  ]

  # スケーラビリティクラス
  CFG_SCALABILITY_CLASS_SC1 = "SC1"
  CFG_SCALABILITY_CLASS_SC2 = "SC2"
  CFG_SCALABILITY_CLASS_SC3 = "SC3"
  CFG_SCALABILITY_CLASS_SC4 = "SC4"
  
  # 保護違反時処理機能の機能レベル
  CFG_VIOLATION_HANDLING_LEVEL1 = "Level1"
  CFG_VIOLATION_HANDLING_LEVEL2 = "Level2"
  CFG_VIOLATION_HANDLING_LEVEL3 = "Level3"
  
  # タイミング保護機能の機能レベル
  CFG_TIMING_PROTECTION_LEVEL1 = "Level1"
  CFG_TIMING_PROTECTION_LEVEL2 = "Level2"
  CFG_TIMING_PROTECTION_LEVEL3 = "Level3"
  
  # メモリ保護機能の機能レベル
  CFG_MEMORY_PROTECTION_LEVEL1 = "Level1"
  CFG_MEMORY_PROTECTION_LEVEL2 = "Level2"
  CFG_MEMORY_PROTECTION_LEVEL3 = "Level3"
  
  # エラーコード種別
  CFG_RETURN_STATUS_STANDARD = "STANDARD"
  CFG_RETURN_STATUS_EXTENDED = "EXTENDED"
  
  # コンフォーマンスクラス
  CFG_CONFORMANCE_CLASS_BCC1 = "BCC1"
  CFG_CONFORMANCE_CLASS_BCC2 = "BCC2"
  CFG_CONFORMANCE_CLASS_ECC1 = "ECC1"
  CFG_CONFORMANCE_CLASS_ECC2 = "ECC2"
  
  # テスト対象とする仕様
  CFG_TARGET_SPEC_COS = "COS"
  CFG_TARGET_SPEC_OS  = "OS"
  CFG_TARGET_SPEC_NOS = "NOS"
  CFG_TARGET_SPEC_IOS = "IOS"
  CFG_TARGET_SPEC_DOS = "DOS"

  CFG_LIB_YAML    = "yaml"
  CFG_LIB_KWALIFY = "kwalify"

  # coreidのマクロ
  CFG_MCR_CORE_SELF    = "CORE_SELF"
  CFG_MCR_CORE_OTHER   = "CORE_OTHER"
  CFG_MCR_CORE_OTHER_1 = "CORE_OTHER_1"
  CFG_MCR_CORE_THIRD   = "CORE_THIRD"

  # 定義が必要なマクロ
  GRP_CFG_NECESSARY_MACRO = [
    "TSK_PRI_MAX","TSK_PRI_TOP", "TSK_PRI_HIGH", "TSK_PRI_MID", "TSK_PRI_LOW", "TSK_PRI_BOTTOM",
    
    "MASTER_CORE", CFG_MCR_CORE_SELF, CFG_MCR_CORE_OTHER,
    CFG_MCR_CORE_OTHER_1, CFG_MCR_CORE_THIRD,
    
    "CORE_NUM",
    
    "INT_PRI_TOP", "INT_PRI_HIGH", "INT_PRI_MID", "INT_PRI_LOW", "INT_PRI_BOTTOM", "INT_PRI_ICISR",
    
    "INTNO_SELF_C1ISR_HIGH", "INTNO_SELF_C1ISR_MID", "INTNO_SELF_C1ISR_LOW",
    "INTNO_SELF_C2ISR_TOP", "INTNO_SELF_C2ISR_HIGH",
    "INTNO_SELF_C2ISR_MID_A", "INTNO_SELF_C2ISR_MID_B", "INTNO_SELF_C2ISR_MID_C", "INTNO_SELF_C2ISR_MID_D",
    "INTNO_SELF_C2ISR_MID_E", "INTNO_SELF_C2ISR_MID_F", "INTNO_SELF_C2ISR_MID_G",
    "INTNO_SELF_C2ISR_LOW", "INTNO_SELF_C2ISR_BOTTOM",
    "INTNO_OTHER_ISR1_A",
    "INTNO_OTHER_ISR2_A", "INTNO_OTHER_ISR2_B", "INTNO_OTHER_ISR2_C", "INTNO_OTHER_ISR2_D", "INTNO_OTHER_ISR2_E",
    "INTNO_OTHER_ISR2_F", "INTNO_OTHER_ISR2_G", "INTNO_OTHER_ISR2_H", "INTNO_OTHER_ISR2_I", "INTNO_OTHER_ISR2_J",
    "INTNO_OTHER_ISR2_K", "INTNO_OTHER_1_ISR1_A",
    "INTNO_OTHER_1_ISR2_A", "INTNO_OTHER_1_ISR2_B", "INTNO_OTHER_1_ISR2_C", "INTNO_OTHER_1_ISR2_D", "INTNO_OTHER_1_ISR2_E",
    "INTNO_OTHER_2_ISR1_A",
    "INTNO_OTHER_2_ISR2_A", "INTNO_OTHER_2_ISR2_B", "INTNO_OTHER_2_ISR2_C", "INTNO_OTHER_2_ISR2_D", "INTNO_OTHER_2_ISR2_E",
    
    "INVALID_TSK_ID", "INVALID_ISR_ID", "INVALID_RES_ID",  "INVALID_SPN_ID",
    "INVALID_CNT_ID", "INVALID_ALM_ID", "INVALID_SCHTBL_ID", "ANY_BASIC_MAXACT",
    "INVALID_OSAP_ID", "INVALID_FUNC_INDEX", "INVALID_OBJECT_TYPE_ID", "PRO_INVALID", "ANY_ACTCNT_NOT_MAX_1",
    
    "ANY_ALMVAL_A", "ANY_ALMVAL_B", "ANY_ALMVAL_C",
    "ANY_ALMCYCLE_A", "ANY_ALMCYCLE_B", "ANY_ALMCYCLE_C",
    "ANY_MINCYC_A", "ANY_MINCYC_B", "ANY_MINCYC_C", 
    "ANY_MAXVAL_A", "ANY_MAXVAL_B", "ANY_MAXVAL_C",
    "ANY_CURVAL_A", "ANY_CURVAL_B", "ANY_CURVAL_C",
    "ANY_CURVAL_NOT_0_A", "ANY_CURVAL_NOT_0_B", "ANY_CURVAL_NOT_0_C",
    "ANY_CURVAL_NOT_MAX_A", "ANY_CURVAL_NOT_MAX_B", "ANY_CURVAL_NOT_MAX_C",
    "ANY_CURVAL_NOT_0_MAX_A", "ANY_CURVAL_NOT_0_MAX_B", "ANY_CURVAL_NOT_0_MAX_C",
    "ANY_CURVAL_WRAPAROUND_A", "ANY_CURVAL_WRAPAROUND_B", "ANY_CURVAL_WRAPAROUND_C",
    "ANY_CURVAL_NOT_WRAPAROUND_A", "ANY_CURVAL_NOT_WRAPAROUND_B", "ANY_CURVAL_NOT_WRAPAROUND_C",
    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_A", "INVALID_INCREMENT_GREATER_THAN_MAXVAL_B", "INVALID_INCREMENT_GREATER_THAN_MAXVAL_C",
    "INVALID_INCREMENT_LOWER_THAN_0",  "INVALID_START_GREATER_THAN_MAXVAL_A", "INVALID_START_GREATER_THAN_MAXVAL_B",
    "INVALID_START_GREATER_THAN_MAXVAL_C", "INVALID_START_LOWER_THAN_0", "INVALID_CYCLE_GREATER_THAN_MAXVAL_A",
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_B", "INVALID_CYCLE_GREATER_THAN_MAXVAL_C", "INVALID_CYCLE_LOWER_THAN_MINCYCL_A",
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_B", "INVALID_CYCLE_LOWER_THAN_MINCYCL_C",
    
    "EVENTMASK_A", "EVENTMASK_B", "EVENTMASK_C",
    
    "ANY_SPOLICY", "ANY_TTYPE", 
    
    "ANY_TICKSPERBASE", "ANY_EVENTMASK",
    
    "ANY_SCDLTBL_DURATION_A", "ANY_SCDLTBL_DURATION_B", "ANY_SCDLTBL_DURATION_C",
    "ANY_SCDLTBL_INIT_OFFSET_A", "ANY_SCDLTBL_INIT_OFFSET_B",
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A",
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A",
    "ANY_SCDLTBL_OFFSET_NOT_0_A",
    "ANY_PARAM_OFFSET_STARTSCDLTBLREL", "ANY_CURVAL_STARTSCDLTBLREL", "ANY_CURVAL_STARTSCDLTBLREL_WRAPAROUND",
    "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND","ANY_SCDLTBLREL_REPEAT",
    
    "ANY_TFN_STKSZ", "ANY_OSAP_1", "INVALID_ILLEGAL_ADD",
    
    "TRUSTED_OSAP1", "TRUSTED_OSAP2", "TRUSTED_OSAP3", "NON_TRUSTED_OSAP1", "NON_TRUSTED_OSAP2", "NON_TRUSTED_OSAP3",
    
    "DATA_UINT8_A", "DATA_UINT8_B", "DATA_UINT8_C", "DATA_UINT8_D", "DATA_UINT8_E", "DATA_UINT8_F",
    "DATA_UINT16_A", "DATA_UINT16_B", "DATA_UINT16_C", "DATA_UINT16_D", "DATA_UINT16_E", "DATA_UINT16_F",
    "DATA_UINT32_A", "DATA_UINT32_B", "DATA_UINT32_C", "DATA_UINT32_D", "DATA_UINT32_E", "DATA_UINT32_F",
    "DATA_INT_A", "DATA_INT_B", "DATA_INT_C", "DATA_INT_D", "DATA_INT_E", "DATA_INT_F"
  ]

  #===================================================================
  # カーネルで定義される構造体のマクロ定義(Struct)
  #===================================================================
  # AlarmBaseType
  STR_MAXALLOWEDVALUE = "maxallowedvalue"
  STR_TICKSPERBASE    = "ticksperbase"
  STR_MINCYCLE        = "mincycle"

  # IcIsrId
  STR_ICISR_ID = "stk_isrid"

  # 構造体のメンバ変数名，型，デフォルト初期値
  STR_INITIAL_INFO = {TYP_ALMBASE => [[STR_MAXALLOWEDVALUE, TYP_TICK, 0],
                                      [STR_TICKSPERBASE,    TYP_TICK, 0],
                                      [STR_MINCYCLE,        TYP_TICK, 0]],
                      TYP_AKTSP_STACK_INFO => [["stk_mode",     TYP_UINT8,            0],
                                               ["stk_action",   TYP_UINT8,            0],
                                               ["stk_task",     TYP_TSK,              0],
                                               ["stk_event",    TYP_EVT_MASK,         0],
                                               ["stk_resource", TYP_RES,              0],
                                               ["stk_intno",    TYP_INTERRUPT_NUMBER, 0],
                                               [STR_ICISR_ID,    TYP_ISR,              0]],
                      TYP_AKTSP_IOC_DATA_STRUCT_PRIM => [["data1", TYP_UINT8,  0],
                                                        ["data2", TYP_UINT16, 0],
                                                        ["data3", TYP_UINT32, 0]],
                      TYP_AKTSP_IOC_DATA_STRUCT_NOPRIM => [["data1", TYP_UINT8,  0],
                                                          ["data2", TYP_UINT16, 0],
                                                          ["data3", TYP_UINT32, 0]]}

  #===================================================================
  # プリミティブなデータ型
  #===================================================================
  GROUP_TYP_NOPRIM = [TYP_AKTSP_IOC_DATA_INT_NOPRIM, TYP_AKTSP_IOC_DATA_STRUCT_NOPRIM]
  
  #===================================================================
  # TESRYのマクロ定義(TESRY)
  #===================================================================
  # オブジェクト名のマクロ定義
  TSR_OBJ_TASK               = "TASK"
  TSR_OBJ_C1ISR              = "C1ISR"
  TSR_OBJ_C2ISR              = "C2ISR"
  TSR_OBJ_STARTUP_HOOK       = "STARTUP_HOOK"
  TSR_OBJ_SHUTDOWN_HOOK      = "SHUTDOWN_HOOK"
  TSR_OBJ_PRETASK_HOOK       = "PRETASK_HOOK"
  TSR_OBJ_POSTTASK_HOOK      = "POSTTASK_HOOK"
  TSR_OBJ_ERROR_HOOK         = "ERROR_HOOK"
  TSR_OBJ_PROTECTION_HOOK    = "PROTECTION_HOOK"
  TSR_OBJ_ALARM_CALL_BACK    = "ALARM_CBACK"
  TSR_OBJ_ALARM              = "ALARM"
  TSR_OBJ_RESOURCE           = "RESOURCE"
  TSR_OBJ_EVENT              = "EVENT"
  TSR_OBJ_COUNTER            = "COUNTER"
  TSR_OBJ_SCHEDULE_TABLE     = "SCHEDULE_TABLE"
  TSR_OBJ_INT_STATE          = "INT_STATE"
  TSR_OBJ_STARTUP_HOOK_OSAP  = "STARTUP_HOOK_OSAP"
  TSR_OBJ_SHUTDOWN_HOOK_OSAP = "SHUTDOWN_HOOK_OSAP"
  TSR_OBJ_ERROR_HOOK_OSAP    = "ERROR_HOOK_OSAP"
  TSR_OBJ_TRUSTED_FUNCTION   = "TRUSTED_FUNCTION"
  TSR_OBJ_APPLICATION_MODE   = "APPLICATION_MODE"
  TSR_OBJ_MEMORY_MODULE      = "MEMORY_MODULE"
  TSR_OBJ_MEMORY_AREA        = "MEMORY_AREA"
  TSR_OBJ_MEMORY_SECTION     = "MEMORY_SECTION"
  TSR_OBJ_SPINLOCK           = "SPINLOCK"
  TSR_OBJ_IOC                = "IOC"
  TSR_OBJ_IOC_SENDER         = "IOC_SENDER"
  TSR_OBJ_IOC_RECEIVER       = "IOC_RECEIVER"
  TSR_OBJ_IOC_DATA           = "IOC_DATA"
  TSR_OBJ_ICISR              = "ICISR"
  TSR_OBJ_OSAP               = "OSAP"
  TSR_OBJ_RESTART_TASK       = "RESTART_TASK"
  TSR_OBJ_TIME_WINDOW        = "TIME_WINDOW"

  # テストシナリオバージョン情報
  TSR_LBL_VERSION = "version"

  # 変数の否定を表す記号
  TSR_NOT_SIGN = "~"

  # condition名のマクロ定義
  TSR_LBL_PRE       = "pre_condition"
  TSR_LBL_DO        = "do"
  TSR_LBL_POST      = "post_condition"
  TSR_LBL_PROPERTY  = "property"

  # do_，post_condition_のマクロ定義
  TSR_UNS_DO   = TSR_LBL_DO + "_"
  TSR_UNS_POST = TSR_LBL_POST + "_"

  # do_x，post_condition_xの正規表現のマクロ定義
  TSR_REX_DO       = /^#{TSR_UNS_DO}(\d*)?\z/
  TSR_REX_POST     = /^#{TSR_UNS_POST}(\d*)?\z/
  TSR_REX_PRE_DO   = /^#{TSR_LBL_DO}(?:\_(\d+)|)$/    # シーケンス番号なしにもマッチ（do）
  TSR_REX_PRE_POST = /^#{TSR_LBL_POST}(?:\_(\d+)|)$/  # シーケンス番号なしにもマッチ（post）

  # 各種命名規則
  TSR_REX_TEST_ID        = /^[a-zA-Z]\w*$/                               # 正しいテストID
  TSR_REX_OBJECT_ID      = /^[a-zA-Z]\w*(\/\d-\d*\/)?$/                  # 正しいオブジェクトID
  TSR_REX_VARIABLE       = /^[a-zA-Z\_][a-zA-Z0-9\_\+\-\*\/%\[\]\(\)]*$/ # 正しい変数名(配列の添字の演算に対応するため英数字以外の記号を含む)

  # 割込み優先度と判断するマクロのプレフィックス
  TSR_MACRO_INI_PRI = /^INT_PRI_.*/

  # 統合するパラメータ(TESRYでは指定不可)
  TSR_PRM_STATE     = "hdlstat"  # tstat, rtnstat, hookstat, cbstat

  # 共通部分
  TSR_PRM_COREID         = "coreid"

  # 共通部分(処理単位オブジェクト)
  TSR_PRM_TYPE           = "type"
  TSR_PRM_BOOTCNT        = "bootcnt"
  TSR_PRM_CLASS          = "class"
  TSR_PRM_VAR            = "var"
  TSR_PRM_VAR_TYPE       = "type"
  TSR_PRM_VAR_VALUE      = "value"
  TSR_PRM_VAR_GLOBAL     = "global"
  TSR_PRM_RELRES         = "relres"
  TSR_PRM_GETRES         = "getres"
  TSR_PRM_GETRESTFN      = "getrestfn"
  TSR_PRM_STKSZ          = "stksz"
  TSR_PRM_OSAP           = "osap"
  TSR_PRM_ACCOSAP        = "accosap"
  TSR_PRM_NEED_SI        = "need_si"
  TSR_PRM_ERROR_HOOK_CFG = "target_error_hook_cfg"
  TSR_PRM_SPNID          = "spnid"
  TSR_PRM_GETSPN         = "getspn"
  TSR_PRM_GETSPNTFN      = "getspntfn"

  # 共通部分(タスク，アラーム，スケジュールテーブル)
  TSR_PRM_APPMODE     = "appmode"

  # TASK
  TSR_PRM_TSTAT     = "tstat"
  TSR_PRM_CURPRI    = "curpri"
  TSR_PRM_INIPRI    = "inipri"
  TSR_PRM_TTYPE     = "ttype"
  TSR_PRM_MAXACT    = "maxact"
  TSR_PRM_SPOLICY   = "spolicy"
  TSR_PRM_CUREVT    = "curevt"
  TSR_PRM_WAIEVT    = "waievt"
  TSR_PRM_WAIEVTTFN = "waievttfn"
  TSR_PRM_ACTCNT    = "actcnt"
  TSR_PRM_PORDER    = "porder"
  TSR_PRM_RELEVT    = "relevt"
  TSR_PRM_STK       = "stk"
  TSR_PRM_SSTKSZ    = "sstksz"
  TSR_PRM_SSTK      = "sstk"

  # ALARM_CBACK
  TSR_PRM_CBSTAT = "cbstat"

  # ISR
  TSR_PRM_RTNSTAT   = "rtnstat"
  TSR_PRM_INTNO     = "intno"
  TSR_PRM_INTATR    = "intatr"
  TSR_PRM_INIINTPRI = "iniintpri"
  TSR_PRM_CURINTPRI = "curintpri"
  TSR_PRM_ISTAT     = "istat"
  TSR_PRM_ISTKSZ    = "istksz"

  # ICISR
  TSR_PRM_ICISRNO  = "icisrno"

  # HOOK
  TSR_PRM_HOOKSTAT = "hookstat"

  # TRUSTED_FUNCTION
  TSR_PRM_CALLER = "caller"
  TSR_PRM_ARG    = "arg"

  # 共通部分(同期通信オブジェクト)
  TSR_PRM_COUNTER       = "counter"
  TSR_PRM_CURVAL        = "curval"
  TSR_PRM_AUTOSTARTTYPE = "autostarttype"

  # 共通部分(スケジュールテーブルとdo)
  TSR_PRM_REPEAT  = "repeat"

  # RESOURCE
  TSR_PRM_RESPROP = "resprop"
  TSR_PRM_LINKRES = "linkres"
  TSR_PRM_LOCKFLG = "lockflg"

  # EVENT
  TSR_PRM_MASK = "mask"

  # COUNTER
  TSR_PRM_MINCYC       = "mincyc"
  TSR_PRM_MAXVAL       = "maxval"
  TSR_PRM_CTYPE        = "ctype"
  TSR_PRM_TICKSPERBASE = "ticksperbase"
  TSR_PRM_CSTAT        = "cstat"

  # ALARM
  TSR_PRM_ALMACT    = "almact"
  TSR_PRM_ALMVAL    = "almval"
  TSR_PRM_CYCLE     = "cycle"
  TSR_PRM_ASTAT     = "astat"
  TSR_PRM_TASK      = "task"
  TSR_PRM_EVENT     = "event"
  TSR_PRM_INCOUNTER = "incounter"
  TSR_PRM_CALLBAK   = "callback"

  # SCHEDULE_TABLE
  TSR_PRM_SYNCSTRATEGY = "syncstrategy"
  TSR_PRM_STSTAT       = "ststat"
  TSR_PRM_DURATION     = "duration"
  TSR_PRM_EXPOINT      = "expoint"
  TSR_PRM_ACTTSK       = "acttsk"
  TSR_PRM_SETEVT       = "setevt"
  TSR_PRM_STFROM       = "stfrom"
  TSR_PRM_STARTTICK    = "starttick"

  # INTSTATE
  TSR_PRM_INT_STATE = "istat"

  # SPINLOCK
  TSR_PRM_SUSINT    = "susint"
  TSR_PRM_SUCCESSOR = "successor"

  # 共通部分(メモリセクション情報，メモリ領域属性)
  TSR_PRM_EXPORT = "export"
  TSR_PRM_MEMATR = "mematr"

  # MEMORY_MODULE
  TSR_PRM_FILE = "file"

  # MEMORY_AREA
  TSR_PRM_BASE = "base"
  TSR_PRM_SIZE = "size"

  # MEMORY_SECTION
  TSR_PRM_SECTION = "section"
  TSR_PRM_REGION  = "region"

  # IOC
  TSR_PRM_SENDER    = "sender"
  TSR_PRM_RECEIVER  = "receiver"
  TSR_PRM_IOCDATA   = "iocdata"
  TSR_PRM_MAXQUE    = "maxque"
  TSR_PRM_DATA      = "data"
  TSR_PRM_DATALIST  = "datalist"
  TSR_PRM_LOSTFLG   = "lostflg"
  TSR_PRM_SENDERID  = "senderid"
  TSR_PRM_KIND      = "kind"
  TSR_PRM_DATATYPE  = "datatype"
  TSR_PRM_INITVAL   = "initval"

  # OSAP
  TSR_PRM_OSAPSTAT = "osapstat"

  # do配下のマクロ定義
  TSR_PRM_ID      = "id"
  TSR_PRM_SYSSRV  = "syssrv"
  TSR_PRM_RETTYPE = "rettype"
  TSR_PRM_RETVAL  = "retval"
  TSR_PRM_GCOV    = "gcov"
  TSR_PRM_FINISH  = "finish"

  # property配下のマクロ定義
  TSR_PRM_PRO_SC                   = "sc"
  TSR_PRM_NEED_ENADIS_INT_SOURCE   = "need_enadis_interrupt_source"
  TSR_PRM_VIOLATION_HANDLING_LEVEL = "violation_handling_level"
  TSR_PRM_TIMING_PROTECTION_LEVEL  = "timing_protection_level"
  TSR_PRM_MEMORY_PROTECTION_LEVEL  = "memory_protection_level"
  TSR_PRM_NEED_STACK_SHARE         = "need_stack_share"
  TSR_PRM_MAINTASK_WAIT            = "maintask_wait"
  TSR_PRM_USE_MAINTASK             = "use_maintask"
  TSR_PRM_PRO_APPMODE              = "application_mode"
  TSR_PRM_ADD_OSAP_ERR_HOOK        = "add_osap_error_hook"
  TSR_PRM_SINGLE_ONLY              = "single_only"
  TSR_PRM_EXTENDED_RETURN_STATUS   = "extended_return_status"

  # 各オブジェクト状態のマクロ定義
  TSR_STT_TRUSTED_OSAP1     = "TRUSTED_OSAP1"
  TSR_STT_TRUSTED_OSAP2     = "TRUSTED_OSAP2"
  TSR_STT_TRUSTED_OSAP3     = "TRUSTED_OSAP3"
  TSR_STT_TRUSTED_OSAP4     = "TRUSTED_OSAP4"
  TSR_STT_TRUSTED_OSAP5     = "TRUSTED_OSAP5"
  TSR_STT_NON_TRUSTED_OSAP1 = "NON_TRUSTED_OSAP1"
  TSR_STT_NON_TRUSTED_OSAP2 = "NON_TRUSTED_OSAP2"
  TSR_STT_NON_TRUSTED_OSAP3 = "NON_TRUSTED_OSAP3"
  TSR_STT_NON_TRUSTED_OSAP4 = "NON_TRUSTED_OSAP4"
  TSR_STT_NON_TRUSTED_OSAP5 = "NON_TRUSTED_OSAP5"
  TSR_STT_NON_TRUSTED_OSAP_FOR_NOT_ACCESS_ISR = "NON_TRUSTED_OSAP_FOR_NOT_ACCESS_ISR"
  TSR_STT_BEFORE_NT_TRUSTED_OSAP     = "BEFORE_NT_TRUSTED_OSAP"
  TSR_STT_TR_OSAP_SELF_CORE          = "TR_OSAP_SELF_CORE"
  TSR_STT_TR_OSAP_SELF_CORE_2        = "TR_OSAP_SELF_CORE_2"
  TSR_STT_TR_OSAP_SELF_CORE_3        = "TR_OSAP_SELF_CORE_3"
  TSR_STT_NT_OSAP_SELF_CORE          = "NT_OSAP_SELF_CORE"
  TSR_STT_NT_OSAP_SELF_CORE_2        = "NT_OSAP_SELF_CORE_2"
  TSR_STT_NT_OSAP_SELF_CORE_3        = "NT_OSAP_SELF_CORE_3"
  TSR_STT_TR_OSAP_OTHER_OTHER_CORE   = "TR_OSAP_OTHER_OTHER_CORE"
  TSR_STT_TR_OSAP_OTHER_OTHER_CORE_2 = "TR_OSAP_OTHER_OTHER_CORE_2"
  TSR_STT_NT_OSAP_OTHER_OTHER_CORE   = "NT_OSAP_OTHER_OTHER_CORE"
  TSR_STT_NT_OSAP_OTHER_OTHER_CORE_2 = "NT_OSAP_OTHER_OTHER_CORE_2"
  TSR_STT_OSAP_SELF_CORE             = "OSAP_SELF_CORE"
  TSR_STT_OSAP_OTHER_SAME_CORE       = "OSAP_OTHER_SAME_CORE"
  TSR_STT_OSAP_OTHER_OTHER_CORE      = "OSAP_OTHER_OTHER_CORE"
  TSR_STT_NT_OSAP_RESTARTING         = "NT_OSAP_RESTARTING"
  TSR_STT_NT_OSAP_TERMINATED         = "NT_OSAP_TERMINATED"

  TSR_STT_RUNNING           = "RUNNING"
  TSR_STT_READY             = "READY"
  TSR_STT_SUSPENDED         = "SUSPENDED"
  TSR_STT_WAITING           = "WAITING"
  TSR_STT_RUNNING_WAITSPIN  = "AK_RUNNING_WAITSPIN"
  TSR_STT_RUNNING_WAITICISR = "AK_RUNNING_WAITICISR"
  TSR_STT_BASIC             = "AK_BASIC"
  TSR_STT_EXTENDED          = "AK_EXTENDED"
  TSR_STT_SCHFULL           = "AK_SCHFULL"
  TSR_STT_SCHNON            = "AK_SCHNON"

  TSR_STT_ACTIVATE           = "AK_ACTIVATE"
  TSR_STT_STP                = "AK_STOP"
  TSR_STT_ACTIVETE_WAITSPIN  = "AK_ACTIVATE_WAITSPIN"
  TSR_STT_ACTIVETE_WAITICISR = "AK_ACTIVATE_WAITICISR"

  TSR_STT_ONLY_SYSTEM = "AK_ONLY_SYSTEM"
  TSR_STT_ONLY_OSAP   = "AK_ONLY_OSAP"
  TSR_STT_BOTH        = "AK_BOTH"
  TSR_STT_SINGLE      = "AK_SC1_SINGLE"

  TSR_STT_STANDARD  = "AK_STANDARD"
  TSR_STT_INTERNAL  = "AK_INTERNAL"
  TSR_STT_LINKED    = "AK_LINKED"
  TSR_STT_LOCK      = "AK_LOCK"
  TSR_STT_UNLOCK    = "AK_UNLOCK"

  TSR_STT_ENABLE  = "AK_ENABLE"
  TSR_STT_DISABLE = "AK_DISABLE"

  TSR_STT_STARTUP    = "AK_STARTUP"
  TSR_STT_SHUTDOWN   = "AK_SHUTDOWN"
  TSR_STT_PRETASK    = "AK_PRETASK"
  TSR_STT_POSTTASK   = "AK_POSTTASK"
  TSR_STT_ERROR      = "AK_ERROR"
  TSR_STT_PROTECTION = "AK_PROTECT"

  TSR_STT_HARDWARE = "AK_HARDWARE"
  TSR_STT_SOFTWARE = "AK_SOFTWARE"
  TSR_STT_CS_NULL  = "AK_CS_NULL"
  TSR_STT_CS_DOING = "AK_CS_DOING"
  TSR_STT_CS_ERROR = "AK_CS_ERROR"

  TSR_STT_ALM_ATSK  = "AK_ALM_ATSK"
  TSR_STT_ALM_SEVT  = "AK_ALM_SEVT"
  TSR_STT_ALM_CBACK = "AK_ALM_CBACK"
  TSR_STT_ALM_INCNT = "AK_ALM_INCNT"

  TSR_STT_UNSET = "AK_UNSET"
  TSR_STT_SET   = "AK_SET"

  TSR_STT_NONE     = "AK_NONE"
  TSR_STT_IMPLICIT = "AK_IMPLICIT"
  TSR_STT_EXPLICIT = "AK_EXPLICIT"

  TSR_STT_TRUE  = "AK_TRUE"
  TSR_STT_FALSE = "AK_FALSE"

  TSR_STT_SCHTBL_STOPPED      = "SCHEDULETABLE_STOPPED"
  TSR_STT_SCHTBL_NEXT         = "SCHEDULETABLE_NEXT"
  TSR_STT_SCHTBL_RUNNING      = "SCHEDULETABLE_RUNNING"
  TSR_STT_SCHTBL_WAITING      = "SCHEDULETABLE_WAITING"
  TSR_STT_SCHTBL_RUN_AND_SYNC = "SCHEDULETABLE_RUNNING_AND_SYNCHRONOUS"

  TSR_STT_ST_ATSK = "AK_ST_ATSK"
  TSR_STT_ST_SEVT = "AK_ST_SEVT"

  TSR_STT_DIS_ALL_INT = "AK_DIS_ALL_INT"
  TSR_STT_SUS_ALL_INT = "AK_SUS_ALL_INT"
  TSR_STT_SUS_OS_INT  = "AK_SUS_OS_INT"

  TSR_STT_ABSOLUTE = "AK_ABSOLUTE"
  TSR_STT_RELATIVE = "AK_RELATIVE"
  TSR_STT_SYNCHRON = "AK_SYNCHRON"
  TSR_STT_NULL     = "NULL"

  TSR_STT_AUTO = "AK_AUTO"

  TSR_STT_NOWRITE = "AK_NOWRITE"
  TSR_STT_NOREAD  = "AK_NOREAD"
  TSR_STT_EXEC    = "AK_EXEC"
  TSR_STT_UNCACHE = "AK_UNCACHE"
  TSR_STT_IODEV   = "AK_IODEV"
  TSR_STT_SDATA   = "AK_SDATA"
  TSR_STT_MEMINI  = "AK_MEMINI"
  TSR_STT_MEMPRSV = "AK_MEMPRSV"

  TSR_STT_INVALID = "AK_INVALID"

  TSR_STT_SUS_ALL_SPN     = "AK_SUS_ALL_SPN"
  TSR_STT_SUS_OS_SPN      = "AK_SUS_OS_SPN"
  TSR_STT_DO_NOT_CARE     = "AK_DO_NOT_CARE"

  TSR_STT_ACCESSIBLE = "APPLICATION_ACCESSIBLE"
  TSR_STT_RESTARTING = "APPLICATION_RESTARTING"
  TSR_STT_TERMINATED = "APPLICATION_TERMINATED"

  TSR_PRM_IRC_GLOBAL      = "global"
  TSR_PRM_IRC_LOCAL       = "local"
  TSR_PRM_IRC_COMBINATION = "combination"

  # スタートアップフック，シャットダウンフック起動時に置き換えるタスク状態
  TSR_STT_AUTO_START    = "AK_AUTO_START"
  TSR_STT_NO_AUTO_START = "AK_NO_AUTO_START"
  TSR_STT_END_RUNNING   = "AK_END_RUNNING"
  TSR_STT_END_READY     = "AK_END_READY"
  TSR_STT_END_SUSPENDED = "AK_END_SUSPENDED"
  TSR_STT_END_WAITING   = "AK_END_WAITING"

  # OSAP終了/再起動中時に置き換えるタスク状態
  TSR_STT_END_OSAP_RUNNING   = "AK_END_OSAP_RUNNING"
  TSR_STT_END_OSAP_READY     = "AK_END_OSAP_READY"
  TSR_STT_END_OSAP_SUSPENDED = "AK_END_OSAP_SUSPENDED"
  TSR_STT_END_OSAP_WAITING   = "AK_END_OSAP_WAITING"

  TSR_STT_FUNCTION    = "AK_FUNCTION"
  TSR_STT_MACRO       = "AK_MACRO"

  #===================================================================
  # コンフィギュレーション用変換ハッシュ
  #===================================================================
  # TESRY→ATK2(静的API)
  CONVERT_TESRY_TO_ATK2 = {
    TSR_STT_SCHNON          => "NON",
    TSR_STT_SCHFULL         => "FULL",
    TSR_STT_STANDARD        => "STANDARD",
    TSR_STT_INTERNAL        => "INTERNAL",
    TSR_STT_LINKED          => "LINKED",
    TSR_STT_ALM_ATSK        => "ACTIVATETASK",
    TSR_STT_ALM_SEVT        => "SETEVENT",
    TSR_STT_ALM_CBACK       => "CALLBACK",
    TSR_STT_ALM_INCNT       => "INCREMENTCOUNTER",
    TSR_STT_TRUE            => "TRUE",
    TSR_STT_FALSE           => "FALSE",
    TSR_STT_EXPLICIT        => "EXPLICIT",
    TSR_STT_IMPLICIT        => "IMPLICIT",
    TSR_STT_NONE            => "NONE",
    TSR_STT_HARDWARE        => "HARDWARE",
    TSR_STT_SOFTWARE        => "SOFTWARE",
    TSR_STT_ENABLE          => "ENABLE",
    TSR_STT_DISABLE         => "TA_NULL",
    TSR_STT_AUTO            => "AUTO",
    TSR_STT_ABSOLUTE        => "ABSOLUTE",
    TSR_STT_RELATIVE        => "RELATIVE",
    TSR_STT_SYNCHRON        => "SYNCHRON",
    TSR_STT_NULL            => "NULL",
    TSR_STT_NOWRITE         => "TA_NOWRITE",
    TSR_STT_NOREAD          => "TA_NOREAD",
    TSR_STT_EXEC            => "TA_EXEC",
    TSR_STT_MEMINI          => "TA_MEMINI",
    TSR_STT_MEMPRSV         => "TA_MEMPRSV",
    TSR_STT_UNCACHE         => "TA_UNCACHE",
    TSR_STT_IODEV           => "TA_IODEV",
    TSR_STT_SDATA           => "TA_SDATA",
    TSR_STT_SUS_ALL_SPN     => "LOCK_ALL_INTERRUPTS",
    TSR_STT_SUS_OS_SPN      => "LOCK_CAT2_INTERRUPTS",
    TSR_STT_DO_NOT_CARE     => "LOCK_NOTHING",
    TSR_STT_FUNCTION        => "FUNCTION",
    TSR_STT_MACRO           => "MACRO"
  }

  # TESRY→AUTOSAR(XML)
  CONVERT_TESRY_TO_ARXML = {
    TSR_STT_SCHNON          => "NON",
    TSR_STT_SCHFULL         => "FULL",
    TSR_STT_STANDARD        => "STANDARD",
    TSR_STT_INTERNAL        => "INTERNAL",
    TSR_STT_LINKED          => "LINKED",
    TSR_STT_TRUE            => "true",
    TSR_STT_FALSE           => "false",
    TSR_STT_EXPLICIT        => "EXPLICIT",
    TSR_STT_IMPLICIT        => "IMPLICIT",
    TSR_STT_NONE            => "NONE",
    TSR_STT_HARDWARE        => "HARDWARE",
    TSR_STT_SOFTWARE        => "SOFTWARE",
    TSR_STT_ENABLE          => "ENABLE",
    TSR_STT_DISABLE         => "DISABLE",
    TSR_STT_ABSOLUTE        => "ABSOLUTE",
    TSR_STT_RELATIVE        => "RELATIVE",
    TSR_STT_SYNCHRON        => "SYNCHRON",
    TSR_STT_SUS_ALL_SPN     => "LOCK_ALL_INTERRUPTS",
    TSR_STT_SUS_OS_SPN      => "LOCK_CAT2_INTERRUPTS",
    TSR_STT_DO_NOT_CARE     => "LOCK_NOTHING",
    TSR_STT_FUNCTION        => "FUNCTION",
    TSR_STT_MACRO           => "MACRO"
  }

  #===================================================================
  # グループのマクロ定義(マクロGroup)
  #===================================================================
  # 状態確認が必要ないオブジェクト
  GRP_NO_VERIFY_OBJECT = [
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK,
    TSR_OBJ_ALARM_CALL_BACK,
    TSR_OBJ_EVENT,
    TSR_OBJ_APPLICATION_MODE,
    TSR_OBJ_MEMORY_MODULE,
    TSR_OBJ_MEMORY_AREA,
    TSR_OBJ_MEMORY_SECTION,
    TSR_OBJ_IOC_SENDER,
    TSR_OBJ_IOC_RECEIVER,
    TSR_OBJ_IOC_DATA
  ]

  # シングルコアで指定できる値リスト
  GRP_PROC_UNIT_AVAILABLE_SINGLE = {
    TSR_PRM_TSTAT     => [TSR_STT_RUNNING, TSR_STT_READY, TSR_STT_SUSPENDED, TSR_STT_WAITING],
    TSR_PRM_TTYPE     => [TSR_STT_BASIC, TSR_STT_EXTENDED],
    TSR_PRM_SPOLICY   => [TSR_STT_SCHFULL, TSR_STT_SCHNON],
    TSR_PRM_RTNSTAT   => [TSR_STT_ACTIVATE, TSR_STT_STP],
    TSR_PRM_INTATR    => [TSR_STT_ENABLE, TSR_STT_DISABLE],
    TSR_PRM_ISTAT     => [TSR_STT_ENABLE, TSR_STT_DISABLE],
    TSR_PRM_HOOKSTAT  => [TSR_STT_ACTIVATE, TSR_STT_STP,TSR_STT_ACTIVETE_WAITSPIN],
    TSR_PRM_CBSTAT    => [TSR_STT_ACTIVATE, TSR_STT_STP]
  }
  GRP_SC_OBJECT_AVAILABLE_SINGLE = {
    TSR_PRM_RESPROP      => [TSR_STT_STANDARD, TSR_STT_INTERNAL, TSR_STT_LINKED],
    TSR_PRM_LOCKFLG      => [TSR_STT_LOCK, TSR_STT_UNLOCK],
    TSR_PRM_CTYPE        => [TSR_STT_HARDWARE, TSR_STT_SOFTWARE],
    TSR_PRM_CSTAT        => [TSR_STT_CS_NULL, TSR_STT_CS_DOING, TSR_STT_CS_ERROR],
    TSR_PRM_ALMACT       => [TSR_STT_ALM_ATSK, TSR_STT_ALM_SEVT, TSR_STT_ALM_CBACK, TSR_STT_ALM_INCNT],
    TSR_PRM_ASTAT        => [TSR_STT_UNSET, TSR_STT_SET],
    TSR_PRM_SYNCSTRATEGY => [TSR_STT_NONE, TSR_STT_IMPLICIT],
    TSR_PRM_REPEAT       => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_LOSTFLG      => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_STSTAT       => [TSR_STT_SCHTBL_STOPPED, TSR_STT_SCHTBL_NEXT, TSR_STT_SCHTBL_RUNNING, TSR_STT_SCHTBL_RUN_AND_SYNC],
    TSR_PRM_EXPORT       => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_KIND         => [TSR_STT_FUNCTION, TSR_STT_MACRO, TSR_STT_DO_NOT_CARE]
  }
  GRP_ALARM_AUTOSTARTTYPE          = [TSR_STT_ABSOLUTE, TSR_STT_RELATIVE]
  GRP_SCHEDULE_TABLE_AUTOSTARTTYPE = [TSR_STT_ABSOLUTE, TSR_STT_RELATIVE, TSR_STT_SYNCHRON]
  GRP_INT_STATE_AVAILABLE_SINGLE = {
    TSR_PRM_INT_STATE => [TSR_STT_DIS_ALL_INT, TSR_STT_SUS_ALL_INT, TSR_STT_SUS_OS_INT]
  }
  GRP_OSAPSTAT_AVAILABLE = [TSR_STT_ACCESSIBLE, TSR_STT_RESTARTING, TSR_STT_TERMINATED]
  GRP_DO_AVAILABLE = {
    TSR_PRM_RETTYPE   => [TYP_STATUS, TYP_ISR, TYP_APPLICATION, TYP_ACCESS, TYP_APPMODE, TYP_OBJACCESS, TYP_CORE, TYP_UINT32, TYP_STD_RETURN, TYP_FAULTY_CONTEXT]
  }
  GRP_NEED_SI_AVAILABLE = [
    CFG_TARGET_SPEC_COS,
    CFG_TARGET_SPEC_OS,
    CFG_TARGET_SPEC_NOS,
    CFG_TARGET_SPEC_IOS,
    CFG_TARGET_SPEC_DOS
  ]
  GRP_OSAP_ALL_AVAILABLE_SC3 = [
    TSR_STT_TRUSTED_OSAP1,
    TSR_STT_TRUSTED_OSAP2,
    TSR_STT_TRUSTED_OSAP3,
    TSR_STT_TRUSTED_OSAP4,
    TSR_STT_TRUSTED_OSAP5,
    TSR_STT_NON_TRUSTED_OSAP1,
    TSR_STT_NON_TRUSTED_OSAP2,
    TSR_STT_NON_TRUSTED_OSAP3,
    TSR_STT_NON_TRUSTED_OSAP4,
    TSR_STT_NON_TRUSTED_OSAP5,
    TSR_STT_NON_TRUSTED_OSAP_FOR_NOT_ACCESS_ISR,
    TSR_STT_BEFORE_NT_TRUSTED_OSAP,
    TSR_STT_TR_OSAP_SELF_CORE,
    TSR_STT_TR_OSAP_SELF_CORE_2,
    TSR_STT_TR_OSAP_SELF_CORE_3,
    TSR_STT_NT_OSAP_SELF_CORE,
    TSR_STT_NT_OSAP_SELF_CORE_2,
    TSR_STT_NT_OSAP_SELF_CORE_3,
    TSR_STT_TR_OSAP_OTHER_OTHER_CORE,
    TSR_STT_TR_OSAP_OTHER_OTHER_CORE_2,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE_2,
    TSR_STT_NT_OSAP_RESTARTING,
    TSR_STT_NT_OSAP_TERMINATED
  ]
  GRP_OSAP_TRUSTED_AVAILABLE_SC3 = [
    TSR_STT_TRUSTED_OSAP1,
    TSR_STT_TRUSTED_OSAP2,
    TSR_STT_TRUSTED_OSAP3,
    TSR_STT_TRUSTED_OSAP4,
    TSR_STT_TRUSTED_OSAP5,
    TSR_STT_BEFORE_NT_TRUSTED_OSAP,
    TSR_STT_TR_OSAP_SELF_CORE,
    TSR_STT_TR_OSAP_SELF_CORE_2,
    TSR_STT_TR_OSAP_SELF_CORE_3,
    TSR_STT_TR_OSAP_OTHER_OTHER_CORE,
    TSR_STT_TR_OSAP_OTHER_OTHER_CORE_2
  ]
  GRP_OSAP_SC1MC = [
    TSR_STT_OSAP_SELF_CORE,
    TSR_STT_OSAP_OTHER_SAME_CORE,
    TSR_STT_OSAP_OTHER_OTHER_CORE
  ]
  GRP_OSAP_NON_TRUSTED_ISR_AVAILABLE_SC3 = [
    TSR_STT_NON_TRUSTED_OSAP1,
    TSR_STT_NON_TRUSTED_OSAP2,
    TSR_STT_NON_TRUSTED_OSAP3,
    TSR_STT_NON_TRUSTED_OSAP4,
    TSR_STT_NON_TRUSTED_OSAP5,
    TSR_STT_NON_TRUSTED_OSAP_FOR_NOT_ACCESS_ISR,
    TSR_STT_NT_OSAP_SELF_CORE,
    TSR_STT_NT_OSAP_SELF_CORE_2,
    TSR_STT_NT_OSAP_SELF_CORE_3,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE_2,
    TSR_STT_NT_OSAP_RESTARTING,
    TSR_STT_NT_OSAP_TERMINATED
  ]
  GRP_OSAP_NON_TRUSTED_AVAILABLE_SC3 = [
    TSR_STT_NON_TRUSTED_OSAP1,
    TSR_STT_NON_TRUSTED_OSAP2,
    TSR_STT_NON_TRUSTED_OSAP3,
    TSR_STT_NON_TRUSTED_OSAP4,
    TSR_STT_NON_TRUSTED_OSAP5,
    TSR_STT_NT_OSAP_SELF_CORE,
    TSR_STT_NT_OSAP_SELF_CORE_2,
    TSR_STT_NT_OSAP_SELF_CORE_3,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE,
    TSR_STT_NT_OSAP_OTHER_OTHER_CORE_2,
    TSR_STT_NT_OSAP_RESTARTING,
    TSR_STT_NT_OSAP_TERMINATED
  ]
  GRP_HWCNT_OSAP_ALL_AVAILABLE = [
    TSR_STT_TRUSTED_OSAP1,
    TSR_STT_TRUSTED_OSAP2,
    TSR_STT_TRUSTED_OSAP3,
    TSR_STT_TRUSTED_OSAP4,
    TSR_STT_TRUSTED_OSAP5,
    TSR_STT_NON_TRUSTED_OSAP1,
    TSR_STT_NON_TRUSTED_OSAP2,
    TSR_STT_NON_TRUSTED_OSAP3,
    TSR_STT_NON_TRUSTED_OSAP4,
    TSR_STT_NON_TRUSTED_OSAP5,
    TSR_STT_NON_TRUSTED_OSAP_FOR_NOT_ACCESS_ISR,
    TSR_STT_BEFORE_NT_TRUSTED_OSAP,
    TSR_STT_TR_OSAP_SELF_CORE,
    TSR_STT_TR_OSAP_SELF_CORE_2,
    TSR_STT_TR_OSAP_SELF_CORE_3,
    TSR_STT_NT_OSAP_SELF_CORE,
    TSR_STT_NT_OSAP_SELF_CORE_2,
    TSR_STT_NT_OSAP_SELF_CORE_3,
    TSR_STT_NT_OSAP_RESTARTING,
    TSR_STT_NT_OSAP_TERMINATED
  ]
  GRP_HWCNT_OSAP_TRUSTED_AVAILABLE = [
    TSR_STT_TRUSTED_OSAP1,
    TSR_STT_TRUSTED_OSAP2,
    TSR_STT_TRUSTED_OSAP3,
    TSR_STT_TRUSTED_OSAP4,
    TSR_STT_TRUSTED_OSAP5,
    TSR_STT_BEFORE_NT_TRUSTED_OSAP,
    TSR_STT_TR_OSAP_SELF_CORE,
    TSR_STT_TR_OSAP_SELF_CORE_2,
    TSR_STT_TR_OSAP_SELF_CORE_3
  ]
  GRP_MEMORY_AREA_AVAILABLE_SINGLE = [
    TSR_STT_NOWRITE,
    TSR_STT_NOREAD,
    TSR_STT_EXEC,
    TSR_STT_UNCACHE,
    TSR_STT_IODEV
  ]
  GRP_MEMORY_SECTION_AVAILABLE_SINGLE = [
    TSR_STT_NOWRITE,
    TSR_STT_NOREAD,
    TSR_STT_EXEC,
    TSR_STT_UNCACHE,
    TSR_STT_IODEV,
    TSR_STT_SDATA,
    TSR_STT_MEMINI,
    TSR_STT_MEMPRSV
  ]

  # マルチコアで指定できる値リスト
  GRP_PROC_UNIT_AVAILABLE_MULTI = {
    TSR_PRM_TSTAT     => [TSR_STT_RUNNING, TSR_STT_READY, TSR_STT_SUSPENDED, TSR_STT_WAITING, TSR_STT_RUNNING_WAITSPIN, TSR_STT_RUNNING_WAITICISR],
    TSR_PRM_TTYPE     => [TSR_STT_BASIC, TSR_STT_EXTENDED],
    TSR_PRM_SPOLICY   => [TSR_STT_SCHFULL, TSR_STT_SCHNON],
    TSR_PRM_RTNSTAT   => [TSR_STT_ACTIVATE, TSR_STT_STP, TSR_STT_ACTIVETE_WAITSPIN, TSR_STT_ACTIVETE_WAITICISR],
    TSR_PRM_INTATR    => [TSR_STT_ENABLE, TSR_STT_DISABLE],
    TSR_PRM_ISTAT     => [TSR_STT_ENABLE, TSR_STT_DISABLE],
    TSR_PRM_HOOKSTAT  => [TSR_STT_ACTIVATE, TSR_STT_STP,TSR_STT_ACTIVETE_WAITSPIN],
    TSR_PRM_CBSTAT    => [TSR_STT_ACTIVATE, TSR_STT_STP]
  }
  GRP_SC_OBJECT_AVAILABLE_MULTI = {
    TSR_PRM_RESPROP       => [TSR_STT_STANDARD, TSR_STT_INTERNAL, TSR_STT_LINKED],
    TSR_PRM_LOCKFLG       => [TSR_STT_LOCK, TSR_STT_UNLOCK],
    TSR_PRM_CTYPE         => [TSR_STT_HARDWARE, TSR_STT_SOFTWARE],
    TSR_PRM_CSTAT         => [TSR_STT_CS_NULL, TSR_STT_CS_DOING, TSR_STT_CS_ERROR],
    TSR_PRM_ALMACT        => [TSR_STT_ALM_ATSK, TSR_STT_ALM_SEVT, TSR_STT_ALM_CBACK, TSR_STT_ALM_INCNT],
    TSR_PRM_ASTAT         => [TSR_STT_UNSET, TSR_STT_SET],
    TSR_PRM_SYNCSTRATEGY  => [TSR_STT_NONE, TSR_STT_IMPLICIT],
    TSR_PRM_REPEAT        => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_LOSTFLG       => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_STSTAT        => [TSR_STT_SCHTBL_STOPPED, TSR_STT_SCHTBL_NEXT, TSR_STT_SCHTBL_RUNNING, TSR_STT_SCHTBL_RUN_AND_SYNC],
    TSR_PRM_EXPORT        => [TSR_STT_TRUE, TSR_STT_FALSE],
    TSR_PRM_SUSINT        => [TSR_STT_SUS_ALL_SPN, TSR_STT_SUS_OS_SPN, TSR_STT_DO_NOT_CARE],
    TSR_PRM_KIND          => [TSR_STT_FUNCTION, TSR_STT_MACRO, TSR_STT_DO_NOT_CARE]
  }
  GRP_INT_STATE_AVAILABLE_MULTI = {
    TSR_PRM_INT_STATE => [TSR_STT_DIS_ALL_INT, TSR_STT_SUS_ALL_INT, TSR_STT_SUS_OS_INT]
  }

  # オブジェクト状態のマクロ定義
  GRP_ACTIVATE = [TSR_STT_ACTIVATE, TSR_STT_RUNNING, TSR_STT_ACTIVETE_WAITSPIN, TSR_STT_RUNNING_WAITSPIN]

  # 共有する処理単位
  GRP_SHARED_PROCESS_UNIT = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK,
    TSR_OBJ_STARTUP_HOOK_OSAP,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_ICISR,
    TSR_OBJ_RESTART_TASK
  ]

  # 共有しない処理単位
  GRP_NOT_SHARED_PROCESS_UNIT = [
    TSR_OBJ_TASK,
    TSR_OBJ_ALARM_CALL_BACK,
    TSR_OBJ_TRUSTED_FUNCTION
  ]

  # スピンロックを獲得する処理単位
  GRP_PROCESS_UNIT_SPINLOCK = [
    TSR_OBJ_TASK,
    TSR_OBJ_C2ISR,
    TSR_OBJ_TRUSTED_FUNCTION,
    TSR_OBJ_ICISR,
    TSR_OBJ_PROTECTION_HOOK
  ]

  # リソースを獲得する処理単位
  GRP_PROCESS_UNIT_RESOURCE = [
    TSR_OBJ_TASK,
    TSR_OBJ_C2ISR,
    TSR_OBJ_TRUSTED_FUNCTION,
    TSR_OBJ_ICISR
  ]

  # ISR
  GRP_PROCESS_UNIT_ISR = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_ICISR
  ]

  # グローバル変数を用意する処理単位
  GRP_GLOBAL_VAR_PROCESS_UNIT = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_ICISR,
    TSR_OBJ_RESTART_TASK
  ]

  # プレタスク/ポストタスクフック
  GRP_PROCESS_UNIT_PRETASK_POSTTASK = [
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK
  ]

  # 全フック
  GRP_PROCESS_UNIT_HOOK = [
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK
  ]

  # 全処理単位
  GRP_PROCESS_UNIT_ALL = [
    TSR_OBJ_TASK,
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_ALARM_CALL_BACK,
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK,
    TSR_OBJ_TRUSTED_FUNCTION,
    TSR_OBJ_STARTUP_HOOK_OSAP,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_ICISR,
    TSR_OBJ_RESTART_TASK
  ]

  # 非タスクコンテキストのマクロ定義
  GRP_NON_CONTEXT = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_ALARM_CALL_BACK,
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_PROTECTION_HOOK,
    TSR_OBJ_STARTUP_HOOK_OSAP,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_ICISR
  ]

  # スタートアップフックが登場するテストケースで，実行状態となると
  # マージできない処理単位
  GRP_PROCESS_UNIT_NOT_MERGE_WITH_STARTUP_HOOK = [
    TSR_OBJ_TASK,
    TSR_OBJ_C2ISR,
    TSR_OBJ_ALARM_CALL_BACK,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_PRETASK_HOOK,
    TSR_OBJ_POSTTASK_HOOK,
    TSR_OBJ_TRUSTED_FUNCTION,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ICISR
  ]

  # スタートアップフック中に起動することができる処理単位
  # (再びスタートアップフックに戻ることができる処理単位)
  GRP_PROCESS_UNIT_BOOTABLE_ON_STARTUP_HOOK = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_PROTECTION_HOOK
  ]

  # スタートアップ/シャットダウンフック中に起動する処理単位
  GRP_PROCESS_UNIT_BOOTABLE_ON_STARTUP_SHUTDOWN_HOOK_EACH_CORE = [
    TSR_OBJ_C1ISR,
    TSR_OBJ_STARTUP_HOOK,
    TSR_OBJ_STARTUP_HOOK_OSAP,
    TSR_OBJ_SHUTDOWN_HOOK,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ERROR_HOOK,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_PROTECTION_HOOK
  ]

  # スピンロックを取得可能な処理単位
  GRP_PROCESS_UNIT_LOCK_SPINLOCK = [
    TSR_OBJ_TASK,
    TSR_OBJ_C2ISR,
    TSR_OBJ_ICISR,
    TSR_OBJ_PROTECTION_HOOK
  ]

  # TestScenarioクラス内で保持する際に共通のキーで持つパラメータ名の関連付け
  GRP_PRM_KEY_STAT = {
    TSR_OBJ_TASK               => TSR_PRM_TSTAT,
    TSR_OBJ_C1ISR              => TSR_PRM_RTNSTAT,
    TSR_OBJ_C2ISR              => TSR_PRM_RTNSTAT,
    TSR_OBJ_ALARM_CALL_BACK    => TSR_PRM_CBSTAT,
    TSR_OBJ_STARTUP_HOOK       => TSR_PRM_HOOKSTAT,
    TSR_OBJ_SHUTDOWN_HOOK      => TSR_PRM_HOOKSTAT,
    TSR_OBJ_PRETASK_HOOK       => TSR_PRM_HOOKSTAT,
    TSR_OBJ_POSTTASK_HOOK      => TSR_PRM_HOOKSTAT,
    TSR_OBJ_ERROR_HOOK         => TSR_PRM_HOOKSTAT,
    TSR_OBJ_PROTECTION_HOOK    => TSR_PRM_HOOKSTAT,
    TSR_OBJ_STARTUP_HOOK_OSAP  => TSR_PRM_HOOKSTAT,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP => TSR_PRM_HOOKSTAT,
    TSR_OBJ_ERROR_HOOK_OSAP    => TSR_PRM_HOOKSTAT,
    TSR_OBJ_ICISR              => TSR_PRM_RTNSTAT,
    TSR_OBJ_OSAP               => TSR_PRM_OSAPSTAT,
    TSR_OBJ_RESTART_TASK       => TSR_PRM_TSTAT
  }

  # syssrvで使用可能な複数マクロ
  GRP_DUPLICATE_MACRO = [
    "INVALID_TSK_ID",
    "INVALID_ISR_ID",
    "INVALID_RES_ID",
    "INVALID_CNT_ID",
    "INVALID_ALM_ID",
    "INVALID_SCHTBL_ID",
    "INVALID_OSAP_ID",
    "INVALID_FUNC_INDEX",
    "INVALID_OBJECT_TYPE_ID",
    "INVALID_SPN_ID"
  ]

  # NOSで使用可能なシステムサービス(SC3)
  GRP_TARGET_SPEC_NOS_SYSSRV = [
    SS_CHK_TSK_ACC,
    SS_CHK_ISR_ACC,
    SS_CHK_ALM_ACC,
    SS_CHK_RES_ACC,
    SS_CHK_CNT_ACC,
    SS_CHK_SCHTBL_ACC,
    SS_CHK_TSK_OWNSHIP,
    SS_CHK_ISR_OWNSHIP,
    SS_CHK_ALM_OWNSHIP,
    SS_CHK_CNT_OWNSHIP,
    SS_CHK_SCHTBL_OWNSHIP
  ]

  # スタックオーバーフロー発生関数(実装依存)
  GRP_STACK_OVERFLOW_FNC = [
    "AktspRaiseTaskStackOverflowByDispatch",
    "AktspRaiseTaskStackOverflowByInterrupt",
    "AktspRaiseIsrStackOverflowByInterrupt",
    "AktspRaiseIsrStackOverflowByReturn",
    "AktspRaiseTfnStackOverflowByReturn",
    "AktspRaiseTaskStackOverflowByIcIsr",
    "AktspRaiseIsrStackOverflowByIcIsr",
    "AKTSP_RETURN_IN_STACK_OVERFLOW_S"
  ]

  # 返り値の型がStatusTypeでないシステムサービス
  GRP_NO_RETURN_STATUSTYPE_SYSSRV = [
    SS_GET_APP_MODE,
    SS_START_OS,
    SS_SHUTDOWN_OS,
    SS_ENA_ALL_INT,
    SS_DIS_ALL_INT,
    SS_RSM_ALL_INT,
    SS_SUS_ALL_INT,
    SS_RSM_OS_INT,
    SS_SUS_OS_INT,
    SS_GET_ISR_ID,
    SS_GET_APP_ID,
    SS_CHK_ISR_MEM_ACC,
    SS_CHK_TSK_MEM_ACC,
    SS_CHK_TSK_ACC,
    SS_CHK_ISR_ACC,
    SS_CHK_ALM_ACC,
    SS_CHK_RES_ACC,
    SS_CHK_CNT_ACC,
    SS_CHK_SCHTBL_ACC,
    SS_CHK_SPN_ACC,
    SS_CHK_OBJ_ACC,
    SS_CHK_TSK_OWNSHIP,
    SS_CHK_ISR_OWNSHIP,
    SS_CHK_ALM_OWNSHIP,
    SS_CHK_CNT_OWNSHIP,
    SS_CHK_SCHTBL_OWNSHIP,
    SS_CHK_OBJ_OWNSHIP,
    SS_START_CORE,
    SS_GETFAULTY_CONTEXT,
    SS_START_NON_AUTOSAR_CORE
  ]

  # 所属するOSAPを設定可能なオブジェクト
  GRP_OSAP_OBJECT = [
    TSR_OBJ_TASK,
    TSR_OBJ_C1ISR,
    TSR_OBJ_C2ISR,
    TSR_OBJ_STARTUP_HOOK_OSAP,
    TSR_OBJ_SHUTDOWN_HOOK_OSAP,
    TSR_OBJ_ERROR_HOOK_OSAP,
    TSR_OBJ_TRUSTED_FUNCTION,
    TSR_OBJ_RESTART_TASK,
    TSR_OBJ_COUNTER,
    TSR_OBJ_ALARM,
    TSR_OBJ_SCHEDULE_TABLE,
    TSR_OBJ_IOC_SENDER,
    TSR_OBJ_IOC_RECEIVER,
    TSR_OBJ_ICISR,
    TSR_OBJ_MEMORY_MODULE,
    TSR_OBJ_MEMORY_AREA,
    TSR_OBJ_MEMORY_SECTION
  ]

  #===================================================================
  # AUTOSAR固有のマクロ定義
  #===================================================================
  # 特定の処理単位に用いる関数名
  AUTOSAR_STARTUP_HOOK    = "StartupHook"
  AUTOSAR_SHUTDOWN_HOOK   = "ShutdownHook"
  AUTOSAR_PRETASK_HOOK    = "PreTaskHook"
  AUTOSAR_POSTTASK_HOOK   = "PostTaskHook"
  AUTOSAR_ERROR_HOOK      = "ErrorHook"
  AUTOSAR_PROTECTION_HOOK = "ProtectionHook"

  # コアIDのマクロプレフィックス
  AUTOSAR_CORE_ID_PREFIX = "OS_CORE_ID_"

  #===================================================================
  # AKTGのマクロ定義
  #===================================================================
  AKTG_IDX_LAST       = -1                          # 配列の最後の要素をアクセスするときの定数
  AKTG_FINISH_MESSAGE = "All check points passed."  # 終了ルーチンが存在する場合に出力するメッセージ
  AKTG_INVALID_PRI    = 0xFFFF                      # 必ず無効となる優先度

  # 特殊な文字列に用いるラベル
  AKTG_LBL_C1ISR_COMMON  = "AKTG_C1ISR_COMMON"
  AKTG_LBL_C2ISR_COMMON  = "AKTG_C2ISR_COMMON"
  AKTG_LBL_ICISR_COMMON  = "AKTG_ICISR"
  AKTG_LBL_RETASK_COMMON = "AKTG_RESTART_TASK_COMMON"
  AKTG_LBL_ISR_FUNC      = "AKTG_FUNC_"
  AKTG_LBL_CHK_ENAINT    = "AKTG_CHK_ENAINT"
  AKTG_LBL_DUMMY_OSAP    = "AKTG_DUMMY_OSAP"
  AKTG_GRP_LBL_RESERVED  = ["AKTG_", "ErrorHook"]  # テストIDの先頭文字の予約語
  AKTG_LBL_ICISR_CONVERT = "CONVERT_"

  # メインタスク関連のマクロ定義
  AKTG_MAIN_OSAP    = "TRUSTED_MAIN_OSAP"
  AKTG_SUB_OSAP     = "TRUSTED_SUB_OSAP"
  AKTG_MAIN_TASK    = "MainTask"
  AKTG_DUMMY_TASK   = "DummyTask"
  AKTG_DUMMY_RES    = "DummyResource"
  AKTG_DUMMY_EVT    = "DummyEvent"
  AKTG_DUMMY_RETASK = "AKTG_DUMMY_RESTART_TASK"
  AKTG_MAIN_BOOTCNT = 0

  # OSAP名による信頼/非信頼の判定用文字列
  AKTG_JUDGE_NON_TRUSTED = "NON_TRUSTED_OSAP"
  AKTG_JUDGE_TRUSTED     = "TRUSTED_OSAP"
  AKTG_JUDGE_MC_NON_TRUSTED = "NT_OSAP"
  AKTG_JUDGE_MC_TRUSTED     = "TR_OSAP"

  # AKTG優先度のマクロ定義
  AKTG_TSK_SELF = "TSK_SELF"
  AKTG_WAIT_PRI = 0

  # ハードウェアカウンタ用C2ISRのマクロ定義
  AKTG_DUMMY_C2ISR = "AKTG_C2ISR_FOR_HWCNT"

  # その他
  AKTG_TB = "\t" # Tab
  AKTG_NL = "\n" # New Line
  AKTG_ENUM_INVALID = "INVALID"
  AKTG_CHECK_NO_BOOT = "CheckNoBoot"
  AKTG_FORCE_MERGE_ENUM = "ENUM_AKTG_FORCE_MERGE"
  AKTG_FORCE_MERGE_BOOTCNT = "ENUM_AKTG_FORCE_MERGE_bootcnt"

  # [進捗表示用]最大テストID文字数(これ以上は切り捨てる)
  AKTG_MAX_TEST_ID_SIZE = 40

  # 各進捗完了後に表示するメッセージ
  AKTG_PROGRESS_MSG = " %d test cases passed."
  AKTF_PROGRESS_MSG = " %d files passed."

  # C++test関連
  CPPTEST_INIT    = "CppTest_InitializeRuntime()"
  CPPTEST_FINAL   = "cpptestCoverageDumpBuffer()"
  CPPTEST_DISABLE = "cpptestCoverageDisable()"
  CPPTEST_ENABLE  = "cpptestCoverageEnable()"

  # 同期用コメント
  AKTG_SYNC_ACTIVE_SYNC                      = "ActiveSync"
  AKTG_SYNC_STATE_SYNC                       = "StateSync"
  AKTG_SYNC_WAIT_ACTIVATE_TASK_SYNC          = "WaitActivateTaskSync"
  AKTG_SYNC_LOCK_SYNC                        = "LockSync"
  AKTG_SYNC_CONDITION_SYNC                   = "ConditionSync"
  AKTG_SYNC_DO_START_SYNC                    = "DoStartSync"
  AKTG_SYNC_DO_FINISH_SYNC                   = "DoFinishSync"
  AKTG_SYNC_LAST_CHECKED_SYNC                = "LastCheckedSync"
  AKTG_SYNC_LAST_STARTUP_SHUTDOWN_HOOK_SYNC  = "LastStartupShutdownHookSync"
  AKTG_SYNC_AFTER_BOOT_CNT_CLEAR_SYNC        = "AfterBootCntClearSync"
  AKTG_SYNC_WAIT_TERMINATE_ACTIVE_TASK_SYNC  = "WaitTerminateActiveTaskSync"
  AKTG_SYNC_WAIT_TERMINATE_WAITING_TASK_SYNC = "WaitTerminateWaitingTaskSync"

  # 遅延処理コメント
  AKTG_WAIT_SPIN_LOOP   = "loop for well-confirming to wait for spinlock"
  AKTG_WAIT_BOOT_ICISR  = "loop for boot icisr by RaiseInterCoreInterrupt"
  AKTG_WAIT_OS_SHUTDOWN = "loop for until OS shutdown"

  #===================================================================
  # 中間コードのマクロ定義(Inter Mediate Code)
  #===================================================================
  # 中間コードのエレメントタイプ
  IMC_COMMON         = "Common"
  IMC_AKTG_MAIN      = "AKTG_Main"
  IMC_BLOCK          = "block"
  IMC_CONDITION_SYNC = "condition_sync"
  IMC_ACTIVE_SYNC    = "active_sync"
  IMC_STATE_SYNC     = "state_sync"

  # SC1，SC2の場合のOSAP名
  IMC_NO_OSAP = "no_osap"

  # リソースに対するOSAP名(ドメインで囲まない)
  IMC_RESOURCE_OSAP = "resource_osap"

  # イベントに対するOSAP名(ドメインで囲まない)
  IMC_EVENT_OSAP = "event_osap"

  # スピンロックに対するOSAP名(ドメインで囲まない)
  IMC_SPINLOCK_OSAP = "spinlock_osap"

  # IOCに対するOSAP名(ドメインで囲まない)
  IMC_IOC_OSAP = "ioc_osap"

  # メモリセクション，メモリ領域属性のOSAP名(ドメインで囲まない場合)
  IMC_MEM_NO_OSAP = "no_mem_osap"

  # 関数の処理単位種別
  IMC_FUNC_TYPE       = "func"
  IMC_MAIN_TYPE       = "main"
  IMC_FUNC_ISR        = "isr"
  IMC_ERROR_TYPE      = "error"
  IMC_PROTECTION_TYPE = "protection"

  # カウント対象外とするラベル名
  GRP_IGNORE_LABEL = [IMC_COMMON, AKTG_LBL_CHK_ENAINT]

  #===================================================================
  # AKTFのマクロ定義
  #===================================================================
  # ディレクトリ・ファイルパス設定
  DEFAULT_CONFIG_FILE     = "#{TOOL_ROOT}/bin/configure.yaml"                    # デフォルトのconfig
  EXTENDED_RETERN_STATUS  = "#{TOOL_ROOT}/aktf/bin/extended_return_status.yaml"  # 拡張エラーに該当する戻り値一覧

  AKTF_DEBUG_FILE_BEFORE = "aktg_before.yaml"
  AKTF_DEBUG_FILE_AFTER  = "aktg_after.yaml"
  AKTF_DEBUG_FILE_GLOBAL = "aktg_global.yaml"
  AKTF_EXCLUSION_FILE    = "aktg_exclusion_list.txt"
  AKTF_ERROR_HOOK_EXCLUSION_FILE = "aktg_errorhook_exclusion_list.txt"

  AKTF_REX_NUM = /^\d+$/             # 10進数
  AKTF_REX_HEX = /^0x[0-9a-fA-F]+$/  # 16進数
  AKTF_REX_FLOAT = /[-+]?(?:\d+(\.\d*)?|(\.\d+))([eE][-+]?\d+)?/ # 浮動小数点数(整数も含む)

  # スケーラビリティクラス
  GRP_SCALABILITY_CLASS = [
    CFG_SCALABILITY_CLASS_SC1,
    CFG_SCALABILITY_CLASS_SC2,
    CFG_SCALABILITY_CLASS_SC3,
    CFG_SCALABILITY_CLASS_SC4
  ]

  # コンフォーマンスクラス
  GRP_CONFORMANCE_CLASS = [
    CFG_CONFORMANCE_CLASS_BCC1,
    CFG_CONFORMANCE_CLASS_BCC2,
    CFG_CONFORMANCE_CLASS_ECC1,
    CFG_CONFORMANCE_CLASS_ECC2
  ]

  # テスト対象とする仕様
  GRP_TARGET_SPEC = [
    CFG_TARGET_SPEC_COS,
    CFG_TARGET_SPEC_OS,
    CFG_TARGET_SPEC_NOS,
    CFG_TARGET_SPEC_IOS,
    CFG_TARGET_SPEC_DOS
  ]

  # エラーフックのコンフィギュレーション
  GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC = [
    TSR_STT_ONLY_SYSTEM,
    TSR_STT_ONLY_OSAP,
    TSR_STT_BOTH
  ]

  # タスクの優先度(TSK_PRI_TOP以外)
  GRP_TSK_PRI = [
    "TSK_PRI_HIGH",
    "TSK_PRI_MID",
    "TSK_PRI_LOW",
    "TSK_PRI_BOTTOM"
  ]

  # 割込み優先度(INT_PRI_ISR1_HIGH以外)
  GRP_INT_PRI = [
    "INT_PRI_ISR1_MID",
    "INT_PRI_ISR1_LOW",
    "INT_PRI_TOP",
    "INT_PRI_HIGH",
    "INT_PRI_MID",
    "INT_PRI_LOW",
    "INT_PRI_BOTTOM"
  ]

  # 定義できるオブジェクトと属性（Single）
  # 属性ごとの配列 [定義必須フラグ, pre_conditionのみ指定可能フラグ]
  # SC1で定義できるオブジェクト
  GRP_DEF_OBJECT_SINGLE = {
    TSR_OBJ_TASK => {
      TSR_PRM_TSTAT          => [true,  false],
      TSR_PRM_CURPRI         => [false, false],
      TSR_PRM_INIPRI         => [false, true],
      TSR_PRM_TTYPE          => [false, true],
      TSR_PRM_MAXACT         => [false, true],
      TSR_PRM_SPOLICY        => [false, true],
      TSR_PRM_CUREVT         => [false, false],
      TSR_PRM_ACTCNT         => [false, false],
      TSR_PRM_PORDER         => [false, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_STKSZ          => [false, true],
      TSR_PRM_STK            => [false, true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_RELRES         => [false, true],
      TSR_PRM_GETRES         => [false, false],
      TSR_PRM_RELEVT         => [false, true],
      TSR_PRM_WAIEVT         => [false, false],
      TSR_PRM_APPMODE        => [false, true],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_C1ISR => {
      TSR_PRM_INTNO          => [true,  true],
      TSR_PRM_INIINTPRI      => [true,  true],
      TSR_PRM_RTNSTAT        => [true,  false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_C2ISR => {
      TSR_PRM_INTNO          => [true,  true],
      TSR_PRM_INIINTPRI      => [true,  true],
      TSR_PRM_CURINTPRI      => [false, false],
      TSR_PRM_RTNSTAT        => [true,  false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_INTATR         => [false, true],
      TSR_PRM_ISTAT          => [false, false],
      TSR_PRM_ISTKSZ         => [false, true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_RELRES         => [false, true],
      TSR_PRM_GETRES         => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_STARTUP_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_SHUTDOWN_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_HOOKSTAT       => [true, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_ALARM_CALL_BACK => {
      TSR_PRM_CBSTAT         => [true, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_RESOURCE => {
      TSR_PRM_RESPROP => [true, true],
      TSR_PRM_LOCKFLG => [false, false],
      TSR_PRM_LINKRES => [false, true]
    },
    TSR_OBJ_EVENT => {
      TSR_PRM_MASK => [false, true]
    },
    TSR_OBJ_COUNTER => {
      TSR_PRM_MINCYC        => [false, true],
      TSR_PRM_MAXVAL        => [false, true],
      TSR_PRM_CURVAL        => [true, false],
      TSR_PRM_CTYPE         => [true, true],
      TSR_PRM_TICKSPERBASE  => [false, true],
      TSR_PRM_CSTAT         => [false, false]
    },
    TSR_OBJ_ALARM => {
      TSR_PRM_ALMACT        => [true, true],
      TSR_PRM_COUNTER       => [true, true],
      TSR_PRM_ASTAT         => [true, false],
      TSR_PRM_AUTOSTARTTYPE => [false, true],
      TSR_PRM_ALMVAL        => [false, false],
      TSR_PRM_CYCLE         => [false, false],
      TSR_PRM_TASK          => [false, true],
      TSR_PRM_EVENT         => [false, true],
      TSR_PRM_INCOUNTER     => [false, true],
      TSR_PRM_CALLBAK       => [false, true],
      TSR_PRM_APPMODE       => [false, true]
    },
    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_COUNTER       => [true, true],
      TSR_PRM_SYNCSTRATEGY  => [true, true],
      TSR_PRM_REPEAT        => [true, true],
      TSR_PRM_STSTAT        => [true, false],
      TSR_PRM_DURATION      => [true, true],
      TSR_PRM_EXPOINT       => [true, true],
      TSR_PRM_STARTTICK     => [false, true],
      TSR_PRM_AUTOSTARTTYPE => [false, true],
      TSR_PRM_CURVAL        => [false, false],
      TSR_PRM_STFROM        => [false, false],
      TSR_PRM_APPMODE       => [false, true]
    },
    TSR_OBJ_INT_STATE => {
      TSR_PRM_INT_STATE => [true, false]
    },
    TSR_OBJ_APPLICATION_MODE => {
    },
    # SC1シングルでは不要であるが，エラーチェックのために追加する
    TSR_OBJ_ICISR => {
      TSR_PRM_RTNSTAT        => [true,  false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_ISTKSZ         => [false, true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_RELRES         => [false, true],
      TSR_PRM_GETRES         => [false, false],
      TSR_PRM_VAR            => [false, false],
      TSR_PRM_SPNID          => [false,  false],
      TSR_PRM_GETSPN         => [false,  false],
      TSR_PRM_OSAP           => [false,  true],
      TSR_PRM_INTNO          => [false,  true],
      TSR_PRM_ISTAT          => [false, false]
    }
  }

  # SC1→SC3で追加されるオブジェクトとオブジェクトの属性
  # 属性ごとの配列 [定義必須フラグ, pre_conditionのみ指定可能フラグ]
  GRP_DEF_OBJECT_ADD_SC3 = {
    TSR_OBJ_TASK => {
      TSR_PRM_OSAP    => [true,  true],
      TSR_PRM_SSTKSZ  => [false, true],
      TSR_PRM_SSTK    => [false, true],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP    => [true,  true]
    },
    TSR_OBJ_C2ISR => {
      TSR_PRM_OSAP    => [true,  true],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_CALLER         => [false, false],
      TSR_PRM_STKSZ          => [false, true],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_ARG            => [false, true],
      TSR_PRM_GETRES         => [false, false],
      TSR_PRM_WAIEVT         => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_RESOURCE => {
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP    => [false, true],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP    => [true,  true],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP    => [true,  true],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_MEMORY_MODULE => {
      TSR_PRM_FILE   => [true,  true],
      TSR_PRM_EXPORT => [true,  true],
      TSR_PRM_OSAP   => [false, true]
    },
    TSR_OBJ_MEMORY_AREA => {
      TSR_PRM_MEMATR => [false, true],
      TSR_PRM_BASE   => [true,  true],
      TSR_PRM_SIZE   => [true,  true],
      TSR_PRM_OSAP   => [false, true]
    },
    TSR_OBJ_MEMORY_SECTION => {
      TSR_PRM_SECTION => [true,  true],
      TSR_PRM_MEMATR  => [true,  true],
      TSR_PRM_REGION  => [true,  true],
      TSR_PRM_EXPORT  => [true,  true],
      TSR_PRM_OSAP    => [false, true]
    },
    TSR_OBJ_IOC => {
      TSR_PRM_SENDER   => [true, true],
      TSR_PRM_RECEIVER => [true, true],
      TSR_PRM_IOCDATA  => [true, true],
      TSR_PRM_MAXQUE   => [true, true],
      TSR_PRM_DATA     => [false, false],
      TSR_PRM_DATALIST => [false, false],
      TSR_PRM_LOSTFLG  => [false, false]
    },
    TSR_OBJ_IOC_SENDER => {
      TSR_PRM_SENDERID => [false, true],
      TSR_PRM_KIND     => [true, true],
      TSR_PRM_OSAP     => [true, true]
    },
    TSR_OBJ_IOC_RECEIVER => {
      TSR_PRM_KIND     => [true, true],
      TSR_PRM_OSAP     => [true, true]
    },
    TSR_OBJ_IOC_DATA => {
      TSR_PRM_DATATYPE  => [true, true],
      TSR_PRM_INITVAL   => [false, true]
    },
    TSR_OBJ_OSAP => {
      TSR_PRM_OSAPSTAT     => [true,  false]
    },
    TSR_OBJ_RESTART_TASK => {
      TSR_PRM_TSTAT          => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_CURPRI         => [false, false],
      TSR_PRM_INIPRI         => [false, true],
      TSR_PRM_TTYPE          => [false, true],
      TSR_PRM_MAXACT         => [false, true],
      TSR_PRM_SPOLICY        => [false, true],
      TSR_PRM_CUREVT         => [false, false],
      TSR_PRM_ACTCNT         => [false, false],
      TSR_PRM_PORDER         => [false, false],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_STKSZ          => [false, true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_RELRES         => [false, true],
      TSR_PRM_GETRES         => [false, false],
      TSR_PRM_RELEVT         => [false, true],
      TSR_PRM_WAIEVT         => [false, false],
      TSR_PRM_APPMODE        => [false, true],
      TSR_PRM_VAR            => [false, false],
      TSR_PRM_SSTKSZ         => [false, true],
      TSR_PRM_ACCOSAP        => [false, true]
    },
    # SC3シングルでは不要であるが，エラーチェックのために追加する
    TSR_OBJ_ICISR => {
      TSR_PRM_INTATR    => [false, true],
      TSR_PRM_ACCOSAP   => [false, true],
      TSR_PRM_ISTAT     => [false, false]
    }
  }

  # SC1→SC1-MCで追加されるオブジェクトの属性
  # 属性ごとの配列 [定義必須フラグ, pre_conditionのみ指定可能フラグ]
  GRP_DEF_OBJECT_ADD_SC1_MC = {
    TSR_OBJ_TASK => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_GETSPN  => [false,  false],
      TSR_PRM_OSAP    => [false,  true]
    },
    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP    => [false,  true]
    },
    TSR_OBJ_C2ISR => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_GETSPN  => [false,  false],
      TSR_PRM_OSAP    => [false,  true]
    },
    TSR_OBJ_STARTUP_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_SHUTDOWN_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_COREID  => [false, false],
      TSR_PRM_GETSPN  => [false,  false]
    },
    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false]
    },
    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [true,  false],
      TSR_PRM_OSAP           => [true,  true],
      TSR_PRM_BOOTCNT        => [false, false],
      TSR_PRM_NEED_SI        => [false, false],
      TSR_PRM_ERROR_HOOK_CFG => [false, false],
      TSR_PRM_VAR            => [false, false],
      TSR_PRM_COREID         => [false, false]
    },
    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP    => [false, true]
    },
    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP    => [false, true]
    },
    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP    => [false, true]
    },
    TSR_OBJ_INT_STATE => {
      TSR_PRM_COREID  => [false, true]
    },
    TSR_OBJ_SPINLOCK => {
      TSR_PRM_SUSINT    => [false, true],
      TSR_PRM_LOCKFLG   => [false, false],
      TSR_PRM_SUCCESSOR => [false, true],
      TSR_PRM_ACCOSAP   => [true, true]
    },
    TSR_OBJ_IOC => {
      TSR_PRM_SENDER   => [true, true],
      TSR_PRM_RECEIVER => [true, true],
      TSR_PRM_IOCDATA  => [true, true],
      TSR_PRM_MAXQUE   => [true, true],
      TSR_PRM_DATA     => [false, false],
      TSR_PRM_DATALIST => [false, false],
      TSR_PRM_LOSTFLG  => [false, false]
    },
    TSR_OBJ_IOC_SENDER => {
      TSR_PRM_SENDERID => [false, true],
      TSR_PRM_KIND     => [true, true],
      TSR_PRM_OSAP     => [true, true]
    },
    TSR_OBJ_IOC_RECEIVER => {
      TSR_PRM_KIND     => [true, true],
      TSR_PRM_OSAP     => [true, true]
    },
    TSR_OBJ_IOC_DATA => {
      TSR_PRM_DATATYPE  => [true, true],
      TSR_PRM_INITVAL   => [false, true]
    }
  }

  # SC3→SC3-MCで追加されるオブジェクトの属性
  # 属性ごとの配列 [定義必須フラグ, pre_conditionのみ指定可能フラグ]
  GRP_DEF_OBJECT_ADD_SC3_MC = {
    TSR_OBJ_TASK => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_GETSPN  => [false,  false]
    },
    TSR_OBJ_C2ISR => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_GETSPN  => [false,  false]
    },
    TSR_OBJ_STARTUP_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_SHUTDOWN_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_COREID  => [false, false]
    },
    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_COREID  => [false, false],
      TSR_PRM_GETSPN  => [false,  false]
    },
    TSR_OBJ_INT_STATE => {
      TSR_PRM_COREID  => [false, true]
    },
    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_GETSPN  => [false,  false]
    },
    TSR_OBJ_SPINLOCK => {
      TSR_PRM_SUSINT    => [false, true],
      TSR_PRM_LOCKFLG   => [false, false],
      TSR_PRM_SUCCESSOR => [false, true],
      TSR_PRM_ACCOSAP   => [true, true]
    },
    TSR_OBJ_ICISR => {
      TSR_PRM_ISTAT   => [false, false],
      TSR_PRM_ACCOSAP => [false, true]
    },
    TSR_OBJ_RESTART_TASK => {
      TSR_PRM_SPNID   => [false,  false],
      TSR_PRM_GETSPN  => [false,  false]
    }
  }


  # 定義できるdoの属性
  GRP_DEF_DO = {
    TSR_PRM_ID      => [String],
    TSR_PRM_SYSSRV  => [String],
    TSR_PRM_REPEAT  => [Integer],
    TSR_PRM_GCOV    => [TrueClass, FalseClass],
    TSR_PRM_FINISH  => [TrueClass, FalseClass],
    TSR_PRM_NEED_SI => [Array, NilClass],
    TSR_PRM_RETTYPE => [String],
    TSR_PRM_RETVAL  => [String,Integer]
  }

  # タスクが休止状態の場合でも指定できるパラメータ
  GRP_ACTIVATE_PRM_ON_SUSPENDED = [
    TSR_PRM_TSTAT,
    TSR_PRM_OSAP,
    TSR_PRM_INIPRI,
    TSR_PRM_TTYPE,
    TSR_PRM_MAXACT,
    TSR_PRM_SPOLICY,
    TSR_PRM_CUREVT,
    TSR_PRM_BOOTCNT,
    TSR_PRM_STKSZ,
    TSR_PRM_STK,
    TSR_PRM_SSTKSZ,
    TSR_PRM_SSTK,
    TSR_PRM_NEED_SI,
    TSR_PRM_ERROR_HOOK_CFG,
    TSR_PRM_RELRES,
    TSR_PRM_GETRES,
    TSR_PRM_RELEVT,
    TSR_PRM_ACCOSAP,
    TSR_PRM_APPMODE,
    TSR_PRM_VAR,
    TSR_PRM_GETSPN
  ]

  # SUSPENDED時にも補完するパラメータ
  GRP_COMPLEMENT_PRM_ON_SUSPENDED = [
    TSR_PRM_STATE,
    TSR_PRM_INIPRI,
    TSR_PRM_TTYPE,
    TSR_PRM_MAXACT,
    TSR_PRM_SPOLICY,
    TSR_PRM_CUREVT,
    TSR_PRM_COREID,
    TSR_PRM_VAR,
    TSR_PRM_RELRES,
    TSR_PRM_GETRES,
    TSR_PRM_RELEVT,
    TSR_PRM_BOOTCNT,
    TSR_PRM_STKSZ,
    TSR_PRM_STK,
    TSR_PRM_SSTKSZ,
    TSR_PRM_SSTK,
    TSR_PRM_OSAP,
    TSR_PRM_ACCOSAP
  ]

  # ALARMの満了処理に必要なオブジェクト(task，event，incounter，callback)
  GRP_PRM_FOR_ALMACT = [TSR_PRM_TASK, TSR_PRM_EVENT, TSR_PRM_INCOUNTER, TSR_PRM_CALLBAK]

  # ALARMのalmactによる指定必須項目
  GRP_REQUIRED_PRM_WITH_ALMACT = {
    TSR_STT_ALM_ATSK =>  [TSR_PRM_TASK],
    TSR_STT_ALM_SEVT =>  [TSR_PRM_TASK, TSR_PRM_EVENT],
    TSR_STT_ALM_INCNT => [TSR_PRM_INCOUNTER],
    TSR_STT_ALM_CBACK => [TSR_PRM_CALLBAK]
  }

  # 返り値が返るシステムサービス
  GRP_SYSSRV_RTN_VAL = [
    SS_GET_APP_MODE,
    SS_GET_CORE_ID,
    SS_ACT_TSK,
    SS_SCHEDULE,
    SS_GET_TSK_ID,
    SS_GET_TSK_STAT,
    SS_GET_ISR_ID,
    SS_ENA_INT_SRC,
    SS_DIS_INT_SRC,
    SS_SET_EVT,
    SS_CLR_EVT,
    SS_GET_EVT,
    SS_WAIT_EVT,
    SS_GET_RES,
    SS_GET_NST_RES,
    SS_REL_RES,
    SS_INC_CNT,
    SS_GET_CNT_VAL,
    SS_ELAPSED_VAL,
    SS_GET_ALM_BASE,
    SS_GET_ALM,
    SS_SET_REL_ALM,
    SS_SET_ABS_ALM,
    SS_CAN_ALM,
    SS_STA_SCHTBL_REL,
    SS_STA_SCHTBL_ABS,
    SS_STP_SCHTBL,
    SS_NXT_SCHTBL,
    SS_STA_SCHTBL_SNC,
    SS_SNC_SCHTBL,
    SS_SET_SCHTBL_ASNC,
    SS_GET_SCHTBL_STAT,
    SS_GET_APP_ID,
    SS_GET_SPN,
    SS_REL_SPN,
    SS_TRY_SPN,
    SS_CALL_TFN,
    SS_CHK_ISR_MEM_ACC,
    SS_CHK_TSK_MEM_ACC,
    SS_CHK_OBJ_ACC,
    SS_CHK_OBJ_OWNSHIP,
    SS_TER_APP,
    SS_ALL_ACC,
    SS_APP_STAT
  ]

  # 実際は作成しないダミーのOSAPID
  GRP_DUMMY_OSAP = [
    IMC_NO_OSAP,
    IMC_RESOURCE_OSAP,
    IMC_EVENT_OSAP,
    IMC_SPINLOCK_OSAP,
    IMC_MEM_NO_OSAP,
    IMC_IOC_OSAP
  ]

  #===================================================================
  # エラーのマクロ定義(Error)
  #===================================================================
  ERR_MSG       = "%s:%s: Fatal Error(AKTGToolError)" #abort用エラーメッセージ(__FILE__, __LINE__)
  ERR_LINE      = "======================================================================\n"
  ERR_HEADER    = "\n#{ERR_LINE}Some errors occurred.\n#{ERR_LINE}"
  ERR_F_HEADER  = "\n#{ERR_LINE}available test scenario does not exist.\n#{ERR_LINE}"
  ERR_RESULT    = "%d test cases error."
  ERR_EXCLUDE_HEADER = "\n#{ERR_LINE}Some files are excluded by property mismatch.\n#{ERR_LINE}"
  ERR_EXCLUDE_RESULT = "%d test cases are excluded.(%d%% passed, %d / %d test cases)"
  ERR_HOOK_EXCLUDE_HEADER = "\n#{ERR_LINE}Some files are excluded ErrorHook or ErrorHookOsap by target_error_hook_cfg.\n#{ERR_LINE}"

  # 環境に起因する問題
  ERR_CONSOLE_WIDTH = "Please make this window more bigger."

  # configure，option
  ERR_CFG_INVALID_VALUE    = "\"%s\" of configure is invalid value.[%s]"                  # 値が不正
  ERR_CFG_UNDEFINED_KEY    = "\"%s\" of configure is undefined key."                      # キーが未定義
  ERR_CFG_REQUIRED_KEY     = "\"%s\" of configure is required key."                       # 指定が必要
  ERR_CFG_REQUIRED_MACRO   = "\"%s\" of macro is required."                               # 定義が必要
  ERR_CFG_BE_INTEGER_GT    = "\"%s\" of configure must be greater than %s.[%s]"           # 指定値より大きい必要
  ERR_CFG_BE_INTEGER_GE    = "\"%s\" of configure must be greater than or equal %s.[%s]"  # 指定値以上の必要
  ERR_CFG_BE_INTEGER_LT    = "\"%s\" of configure must be less than %s.[%s]"              # 指定値より小さい必要
  ERR_CFG_BE_INTEGER_RANGE = "\"%s\" of configure must be between from %d to %d.[%s]"     # 指定値の範囲内の必要
  ERR_RETURN_STATUS        = "if #{CFG_SCALABILITY_CLASS} is #{CFG_SCALABILITY_CLASS_SC3} or #{CFG_SCALABILITY_CLASS_SC4}, #{CFG_RETURN_STATUS} must be #{CFG_RETURN_STATUS_EXTENDED}."
  ERR_MCR_NOT_INTNO_UNIQUE = "\"%s\" is same intno for hardware counter."
  ERR_HWCNT_CANNOT_WORK    = "#{CFG_HWCNT_INTATR} is can't is #{TSR_STT_DISABLE}."
  ERR_NOT_MULTI_CORE       = "if #{CFG_USE_MULTI_CORE} is false, #{CFG_CORE_NUM} must be 1."
  ERR_NOT_VERSION          = "version of configure [%s] and AKTG [%s] is different."
  ERR_ADD_OSAP_ERR_HOOK    = "if #{TSR_PRM_ADD_OSAP_ERR_HOOK} is true, #{TSR_OBJ_ERROR_HOOK} must be defined."

  # マクロの依存関係
  ERR_MCR_INVALID_VALUE    = "\"%s\" of macro is invalid value.[%s]"
  ERR_MCR_INVALID_TYPE     = "\"%s\" of macro must be %s.[%s]"
  ERR_MCR_BE_INTEGER_GT    = "\"%s\" of macro must be greater than %s.[%s]"           # 指定値より大きい必要
  ERR_MCR_BE_INTEGER_GE    = "\"%s\" of macro must be greater than or equal %s.[%s]"  # 指定値以上の必要
  ERR_MCR_BE_INTEGER_LT    = "\"%s\" of macro must be less than %s.[%s]"              # 指定値より小さい必要
  ERR_MCR_BE_INTEGER_LE    = "\"%s\" of macro must be less than or equal %s.[%s]"     # 指定値以下の必要
  ERR_MCR_BE_INTEGER_RANGE = "\"%s\" of macro must be between from %d to %d.[%s]"     # 指定値の範囲内の必要
  ERR_MCR_NOT_BIT_UNIQUE   = "\"%s\" of macro is not bit unique."
  ERR_MCR_INCLUDE_ZERO     = "\"%s\" of macro must be between from %d to %d, or 0.[%s]"     # 指定値の範囲内かつ0の必要

  # AKTF汎用
  ERR_EXPRESSION_INVALID  = "expression is invalid.[%s]"       # 計算式の文法が不正
  ERR_YAML_SYNTAX_INVALID = "yaml syntax is invalid. [%s]"     # YAMLの文法が不正
  ERR_OPTION_INVALID      = "invalid option specified."        # オプション指定が不正
  ERR_CANNOT_OPEN_FILE    = "can't open file. [%s]"            # ファイルが開けない

  # 構造チェック
  ERR_INVALID_TYPE_TESTCASE      = "test case must be %s.[%s]"                 # テストケースのタイプが不正
  ERR_SCENARIO_NOT_EXIST         = "test scenario does not exist."             # ファイル内にテストシナリオが存在しない
  ERR_INVALID_TYPE_SCENARIO      = "test scenario must be %s.[%s]"             # テストシナリオのタイプが不正
  ERR_NO_AVAILABLE_SCENARIO      = "available test scenario does not exist."   # 有効なテストシナリオが存在しない
  ERR_INVALID_TESTID             = "test id is invalid.[%s]"                   # テストIDが不正
  ERR_INVALID_TESTID_PREFIX      = "test id use the reserved word."            # テストIDに予約語が使われている
  ERR_INVALID_OBJECTID           = "object id is invalid.[%s]"                 # オブジェクトIDが不正
  ERR_USE_RESERVED_WORD_OBJECTID = "reserved words are used in object id.[%s]" # オブジェクトIDが不正
  ERR_TESTID_MULTIPLE            = "\"%s\" of test id is multiple defined."    # 同一テストIDが存在
  ERR_CONDITION_MULTIPLE         = "\"%s_%d\" is multiple defined."            # コンディションが複数定義（同一シーケンス番号）
  ERR_CONDITION_UNDEFINED        = "undefined condition found.[%s]"            # 未定義のコンディションが記述されている
  ERR_CONDITION_NOT_EXIST        = "\"%s\" is not exist."                      # 必要なコンディションが存在しない
  ERR_CONDITION_NOT_MATCH        = "sequence number do not match."             # doとpostのシーケンス番号がマッチしない
  ERR_KEY_CANNOT_EXIST           = "\"%s\" can't be exist."                    # 不要なキーが記述されている

  ERR_INVALID_TYPE      = "\"%s\" must be %s.[%s]"
  ERR_INVALID_TYPE_NIL  = "\"%s\" must be %s or Nil.[%s]"
  ERR_INVALID_VAR_NAME  = "variable name is invalid.[%s]"
  ERR_BE_INTEGER_LT     = "\"%s\" must be less than %s.[%s]"
  ERR_BE_INTEGER_LE     = "\"%s\" must be less than or equal %s.[%s]"
  ERR_BE_INTEGER_GT     = "\"%s\" must be greater than %s.[%s]"
  ERR_BE_INTEGER_GE     = "\"%s\" must be greater than or equal %s.[%s]"
  ERR_BE_INTEGER_RANGE  = "\"%s\" must be between from %d to %d.[%s]"     # 指定値の範囲内の必要
  ERR_BE_ONLY0          = "\"%s\" must be 0.[%s]"
  ERR_BE_INCLUDE        = "\"%s\" must be included in (%s).[%s]"

  ERR_REQUIRED_KEY         = "\"%s\" is required key."
  ERR_UNDEFINED_KEY        = "\"%s\" is undefined key."
  ERR_ONLY_PRE_ATR         = "\"%s\" can be defined only in pre_condition."

  ERR_OBJECT_UNDEFINED    = "object type \"%s\" is undefined."
  ERR_OBJECT_NOCHANGE     = "no changed object described.[%s]"
  ERR_OBJECT_NOT_ACTIVATE = "\"%s\" is not activate object in pre_condition."

  ERR_VAR_NOT_SIGN              = "#{TSR_NOT_SIGN} can't set in pre_condition"
  ERR_VAR_UNDEFINED_MEMBER      = "\"%s\" is undefined member in struct type \"%s\"."
  ERR_VAR_INVALID_DEFINE_VALUE  = "\"#{TSR_PRM_VAR_VALUE}\" attribute can be defined only when type is data."
  ERR_VAR_INVALID_DEFINE_MEMBER = "member attributes can be defined only when type is struct."

  ERR_LIST_INVALID_TYPE          = "\"%s\"'s item must be %s.[%s]"
  ERR_LIST_MUST_BE_SINGLE        = "\"%s\"'s item's Hash size must be 1.[%d]"

  # 処理単位
  # TASK/C2ISR
  ERR_RESID_DUPLICATE              = "resourceID is duplicate in \"%s\"."
  ERR_NOT_SET_SPINID               = "if %s is %s, \"#{TSR_PRM_SPNID}\" is required key."
  ERR_SPNID_DUPLICATE              = "spinlockID is duplicate in \"%s\"."
  # TASK
  ERR_SET_RELEVT_BASICTASK         = "basic task can't be have \"#{TSR_PRM_RELEVT}\"."
  ERR_WAIEVT_NOT_SUSPENDED         = "non-waiting task can't have \"#{TSR_PRM_WAIEVT}\"."
  ERR_ATR_SUSPENDED_TASK           = "\"%s\" can't be defined in \"#{TSR_STT_SUSPENDED}\" task."
  ERR_PORDER_NOT_READY             = "non-ready task can't have \"#{TSR_PRM_PORDER}\"."
  ERR_SET_GETRES_NOT_PORDER1       = "if #{TSR_PRM_PORDER} isn't 1, task can't have \"#{TSR_PRM_GETRES}\"."
  ERR_TASK_INIPRI_GT_CURPRI        = "#{TSR_PRM_INIPRI} [%d] geater than #{TSR_PRM_CURPRI} [%d]."
  ERR_NOT_SET_WAIEVT_AND_RELEVT    = "\"#{TSR_PRM_WAIEVT}\" isn't defined in \"#{TSR_PRM_RELEVT}\"."
  ERR_SET_CUREVT_BASICTASK         = "basic task can't be set \"#{TSR_PRM_CUREVT}\"."
  ERR_EVENT_DUPLICATE              = "event is duplicate in \"#{TSR_PRM_RELEVT}\"."
  ERR_SET_GETRES_READY_AND_SCHNON  = "if #{TSR_STT_READY} and non preemptive task can't be set \"#{TSR_PRM_GETRES}\"."
  ERR_SET_GETRES_WAITING           = "waiting task can't be set \"#{TSR_PRM_GETRES}\"."
  ERR_SET_GETRES_SUSPENDED         = "suspended task can't be set \"#{TSR_PRM_GETRES}\"."
  ERR_STK_NOT_STACK_SHARE          = "if shared stack is off, stk or sstk can't be defined."
  ERR_SSTKSZ_SSTK_TRUSTED_OSAP     = "if task belong to trusted osap, sstksz and sstk can't be defined."
  ERR_CURPRI_NOT_MINPRI            = "if #{TSR_PRM_MAINTASK_WAIT} is true, #{TSR_PRM_CURPRI} must be same as #{CFG_MIN_TASK_PRI}."
  ERR_SET_MAXACT_EXTENDEDTASK      = "extended task can't be set more than 2 #{TSR_PRM_MAXACT}."
  ERR_SET_GETSPN_RUNNING           = "if set up #{TSR_PRM_GETSPN}, %s must be %s."
  # C2ISR
  ERR_C2ISR_INIPRI_GT_CURPRI       = "#{TSR_PRM_INIINTPRI} [%d] greater than #{TSR_PRM_CURINTPRI} [%d]."
  # ALARM_CBACK
  ERR_CBSTAT_ACTIVE_IN_PRE         = "\"#{TSR_STT_ACTIVATE}\" of #{TSR_PRM_CBSTAT} is not enable in pre_condition."

  # 同期通信オブジェクト
  # RESOURCE
  ERR_NOT_SET_LINKRES       = "if #{TSR_PRM_RESPROP} is #{TSR_STT_LINKED}, \"#{TSR_PRM_LINKRES}\" is required key."
  ERR_SET_LINKRES           = "if #{TSR_PRM_RESPROP} isn't #{TSR_STT_LINKED}, \"#{TSR_PRM_LINKRES}\" can't define."
  ERR_CANNOT_SET_RES        = "if #{TSR_PRM_RESPROP} is #{TSR_STT_LINKED}, \"#{TSR_PRM_ACCOSAP}\" can't define."
  # COUNTER
  ERR_CANNOT_SET_COUNTER    = "if #{TSR_PRM_CTYPE} is #{TSR_STT_HARDWARE}, \"%s\" can't define."
  ERR_NOT_SET_COUNTER       = "if #{TSR_PRM_CTYPE} is #{TSR_STT_SOFTWARE}, \"%s\" is required key."
  ERR_CSTAT_ACTIVE_IN_PRE   =  "\"#{TSR_STT_CS_DOING}\" of #{TSR_PRM_CSTAT} is not enable in pre_condition."
  # ALARM
  ERR_CANNOT_SET_ALARM       = "if #{TSR_PRM_ASTAT} is #{TSR_STT_UNSET}, \"%s\" can't define."
  ERR_NOT_SET_ALARM          = "if #{TSR_PRM_ASTAT} is #{TSR_STT_SET}, \"%s\" is required key."
  ERR_NOT_SET_ALMACT         = "if %s is %s, \"%s\" is required key."
  ERR_UNNECESSARY_SET_ALMACT = "if %s is %s, \"%s\" is unnecessary key."
  ERR_NOT_SAME_COUNTER       = "#{TSR_PRM_COUNTER} and #{TSR_PRM_INCOUNTER} can't be set the same counter."
  ERR_APPMODE_NOT_SET_ALARM  = "if #{TSR_PRM_APPMODE} is specified, #{TSR_PRM_ASTAT} can't be defined #{TSR_STT_UNSET}."
  ERR_APPMDOE_AUTOSTARTTYPE  = "Do not specify only one of the #{TSR_PRM_APPMODE} or #{TSR_PRM_AUTOSTARTTYPE}."
  # SCHEDULE_TABLE
  ERR_NOT_SET_CURVAL        = "if #{TSR_PRM_STSTAT} is %s, \"#{TSR_PRM_CURVAL}\" is required key in pre_condition."
  ERR_CANNOT_SET_CURVAL     = "if #{TSR_PRM_STSTAT} is %s, \"#{TSR_PRM_CURVAL}\" can't define."
  ERR_CANNOT_SET_STSTAT     = "if #{TSR_PRM_SYNCSTRATEGY} is %s, \"%s\" can't define."
  ERR_NOT_SET_STFROM        = "if #{TSR_PRM_STSTAT} is #{TSR_STT_SCHTBL_NEXT}, \"#{TSR_PRM_STFROM}\" is required key."
  ERR_CANNOT_SET_STFROM     = "if #{TSR_PRM_STSTAT} is %s, \"#{TSR_PRM_STFROM}\" can't define."
  ERR_NOT_SET_ACTION        = "\"#{TSR_PRM_ACTTSK}\" or \"#{TSR_PRM_SETEVT}\" must be set in #{TSR_PRM_EXPOINT}."
  ERR_CURVAl_GT_OFFSET      = "#{TSR_PRM_CURVAL} [%d] greater than or equal to initial offset [%d] in pre_condition."
  ERR_CANNOT_SET_AUTOSTARTTYPE = "if #{TSR_PRM_SYNCSTRATEGY} is %s, #{TSR_PRM_AUTOSTARTTYPE} can't define \"%s\"."
  # TRUSTED_FUNCTION
  ERR_NOT_SET_TFN           = "if #{TSR_PRM_CALLER} is not nil, \"%s\" is required key."
  ERR_SET_TFN               = "if #{TSR_PRM_CALLER} is nil, \"%s\" can't define."
  ERR_RES_DUPLICATE         = "resource is duplicate in \"#{TSR_PRM_GETRES}\"."
  # MEMORY_SECTION
  ERR_NOT_SET_MEMINI_MEMPRSV = "Do not set both \"#{TSR_STT_MEMINI}\" and \"#{TSR_STT_MEMPRSV}\" at once."
  # SPINLOCK
  ERR_SET_ACCOSAP           = "#{TSR_OBJ_SPINLOCK} must be set more than 2 #{TSR_PRM_ACCOSAP}."
  ERR_NOT_SAME_ACC_CORE     = "all #{TSR_PRM_OSAP} of #{TSR_PRM_ACCOSAP} must not belongs to the same core."
  # IOC
  ERR_SENDER_IOCDATA_NUM    = "if #{TSR_PRM_SENDER} set more than 2, #{TSR_PRM_IOCDATA} can't be set more than 2."
  ERR_MAXQUE_0_NOT_SET      = "if #{TSR_PRM_MAXQUE} set 0, \"%s\" can't define."
  ERR_MAXQUE_1_NOT_SET      = "if #{TSR_PRM_MAXQUE} set more than 1, \"%s\" can't define."
  ERR_DATALIST_NUM_MAXQUE   = "#{TSR_PRM_DATALIST} can't be set more than #{TSR_PRM_MAXQUE}."
  ERR_LOSTFLG_DATA_NUM      = "if #{TSR_PRM_LOSTFLG} is true, #{TSR_PRM_DATALIST} and #{TSR_PRM_MAXQUE} must be same."

  # INT_STATE
  ERR_MIXED_INT_STATE       = "\"#{TSR_STT_DIS_ALL_INT}\" can't define with \"#{TSR_STT_SUS_ALL_INT}\/#{TSR_STT_SUS_OS_INT}\"."
  ERR_DUPLICATE_DIS_ALL_INT = "\"#{TSR_STT_DIS_ALL_INT}\" is duplicate."
  ERR_DIS_ALL_INT_SPINLOCK  = "if #{TSR_PRM_INT_STATE} is #{TSR_STT_DIS_ALL_INT}, #{TSR_OBJ_SPINLOCK} can't define."
  # APPLICATION_MODE
  ERR_SAME_APP_MODE         = "\"%s\" is same app_mode_name of configure."

  # DO
  ERR_RTYPE_AND_RVAL        = "\"#{TSR_PRM_RETTYPE}\" and \"#{TSR_PRM_RETVAL}\" must be used together."
  ERR_NEED_RTYPE_AND_RVAL   = "\"%s\" can return value."

  # コンディションチェック
  ERR_NO_RUNNING_PROCESS_UNIT         = "there is no active process unit."
  ERR_TASK_NOT_RUNNING                = "if #{TSR_PRM_MAINTASK_WAIT} is true, #{TSR_OBJ_TASK} must be running in pre_condition."
  ERR_NO_TASK                         = "there is no task."
  ERR_MULTI_OBJECT                    = "there are multi %s."
  ERR_NO_RUNTASK_WITH_PROC_UNIT       = "%s needs running task."
  ERR_NO_ACTIVATE_STARTUP_HOOK        = "#{TSR_PRM_HOOKSTAT} must be set #{TSR_STT_ACTIVATE} at the core of any in pre_condition."
  ERR_TFN_AND_PRE_HOOK_ACTIVATE       = "if trusted function is activate, pretask hook can't activate."
  ERR_TASK_TFN_SET_WAIEVT             = "#{TSR_OBJ_TASK} and #{TSR_OBJ_TRUSTED_FUNCTION} have #{TSR_PRM_WAIEVT}."
  ERR_C2ISR_SET_WAIEVT                = "#{TSR_OBJ_C2ISR} can't set #{TSR_PRM_WAIEVT}."
  ERR_PLURAL_RUNNING_TASK             = "there are multiple running task.(core: %d)"
  ERR_PLURAL_ACTIVATE_NON_CONTEXT     = "there are multiple activate non-task.(core: %d)"
  ERR_NO_RUNTASK_WITH                 = "%s needs running task.(core: %d)"
  ERR_NOT_PROCESS_UNIT                = "%s is not process unit."
  ERR_TASK_NOT_SET_GETRES             = "if #{TSR_PRM_CURPRI} isn't same as #{TSR_PRM_INIPRI}, task/trusted function must have \"#{TSR_PRM_GETRES}\"."
  ERR_NO_WAIEVT_WAITING               = "waiting task must have \"#{TSR_PRM_WAIEVT}\"."
  ERR_C2ISR_NOT_SET_GETRES            = "if #{TSR_PRM_CURINTPRI} isn't same as #{TSR_PRM_INIINTPRI}, c2isr/trusted function must have \"#{TSR_PRM_GETRES}\"."
  ERR_NO_TARGET_OBJECT                = "\"%s\" is not defined."
  ERR_NOT_EVENT                       = "\"%s\" is not #{TSR_OBJ_EVENT}."
  ERR_EVENT_MASK_DUPLICATE            = "\"%s\" of #{TSR_OBJ_EVENT}'s #{TSR_PRM_MASK} is duplicate."
  ERR_NOT_STD_OR_INT_RESOURCE         = "\"%s\" is not standard nor internal resource."
  ERR_NOT_STD_RESOURCE                = "\"%s\" is not standard resource."
  ERR_NOT_SET_RELRES                  = "%s is not related #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR}."
  ERR_NOT_C2ISR                       = "\"%s\" is not #{TSR_OBJ_C2ISR}."
  ERR_NOT_COUNTER                     = "\"%s\" is not #{TSR_OBJ_COUNTER}."
  ERR_NOT_TASK                        = "\"%s\" is not #{TSR_OBJ_TASK}."
  ERR_NOT_SPINLOCK                    = "\"%s\" is not #{TSR_OBJ_SPINLOCK}."
  ERR_NOT_IOC_SENDER                  = "\"%s\" is not #{TSR_OBJ_IOC_SENDER}."
  ERR_NOT_EXIST_IOC_SENDER_ID         = "\"%s\" #{TSR_PRM_SENDERID} does not exist in 1:1 coummunication"
  ERR_NO_IOC_SENDER_ID                = "\"%s\" is not defined #{TSR_PRM_SENDERID}"
  ERR_NOT_IOC_RECEIVER                = "\"%s\" is not #{TSR_OBJ_IOC_RECEIVER}."
  ERR_NOT_IOC_DATA                    = "\"%s\" is not #{TSR_OBJ_IOC_DATA}."
  ERR_NOT_EXTENDED_TASK               = "%s's #{TSR_PRM_TTYPE} is not #{TSR_STT_EXTENDED}."
  ERR_NOT_ALARM_CALL_BACK             = "\"%s\" is not #{TSR_OBJ_ALARM_CALL_BACK}."
  ERR_NOT_SCHEDULE_TABLE              = "\"%s\" is not #{TSR_OBJ_SCHEDULE_TABLE}."
  ERR_NOT_TASK_OR_C2ISR               = "\"%s\" is not #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR}."
  ERR_CALLER_STOP                     = "\"%s\" is suspended or stop."
  ERR_NOT_SAME_DURATION_AND_MAXVAL    = "#{TSR_PRM_DURATION}[%d] and (#{TSR_PRM_MAXVAL} + 1)[%d] are not the same."
  ERR_INIT_OFFSET_INVALID             = "initial offset is invalid.(%d)"
  ERR_DELAY_INVALID                   = "delay [%d - %d] is invalid."
  ERR_FINAL_DELAY_INVALID             = "final delay is invalid.(%d)"
  ERR_ALMVAL_SAME_AS_CURVAL           = "#{TSR_PRM_ALMVAL} is same as #{TSR_PRM_CURVAL}."
  ERR_HIGHER_TASK_READY               = "ready task' #{TSR_PRM_CURPRI} is higher then running task's."
  ERR_PRETASKHOOK_CANT_ACT            = "#{TSR_OBJ_PRETASK_HOOK}'s #{TSR_PRM_HOOKSTAT} is activate is not possible."
  ERR_NEED_GETRES                     = "task must set getres."
  ERR_HEAD_NOT_INTERNAL_RES           = "\"%s\" must be head in getres."
  ERR_TFN_CANNOT_SET_INTRES           = "trusted function can't set internal resource."
  ERR_SCHNON_TSK_HAS_INTERNAL_RES     = "non preemptive task has internal task.(%s)"
  ERR_DUPLICATE_GETRES                = "multi process units are set same resource in #{TSR_PRM_GETRES}."
  ERR_DUPLICATE_GETSPN                = "multi process units are set same resource in #{TSR_PRM_GETSPN}."
  ERR_HIGHER_READY_TASK_GETRES        = "ready task has higher #{TSR_PRM_CURPRI} than running task is set #{TSR_PRM_GETRES}"
  ERR_HIGHER_READY_TASK_CANT_READY    = "#{TSR_OBJ_TASK} can't be set #{TSR_STT_READY}."
  ERR_LOCKFLG_NOT_UNLOCK              = "process unit get %s, but #{TSR_PRM_LOCKFLG} is #{TSR_STT_UNLOCK}"
  ERR_LOCKFLG_NOT_LOCK                = "process unit don't get %s, but #{TSR_PRM_LOCKFLG} is #{TSR_STT_LOCK}"
  ERR_CANT_GETRES                     = "#{TSR_OBJ_TASK} can't have #{TSR_PRM_GETRES}"
  ERR_ALMVAL_INVALID                  = "#{TSR_PRM_ALMVAL} is invalid.(%d)"
  ERR_CYCLE_INVALID                   = "#{TSR_PRM_CYCLE} is invalid.(%d)"
  ERR_NOT_RUN_OR_RUN_AND_SYNC         = "%s is not #{TSR_STT_SCHTBL_RUNNING} or #{TSR_STT_SCHTBL_RUN_AND_SYNC}"
  ERR_INTERNAL_RES_DUPLICATE          = "there are some internal resource (%s)."
  ERR_NOT_RESOURCE                    = "\"%s\" is not resource."
  ERR_PORDER_NOT_UNIQUE               = "porder is not unique.(%s)"
  ERR_PORDER_NOT_SEQUENCE             = "tskpri \"%d\"'s porder is not sequence.(core: %d)"
  ERR_PLURAL_INT_STATE                = "there are multiple \"#{TSR_OBJ_INT_STATE}\".(core: %d)"
  ERR_CANNNOT_REF_INT_STATE           = "there is no active process unit in disable interrupts.(core: %d)"
  ERR_TARGET_NOT_DEFINED              = "\"%s\" is not defined."
  ERR_TARGET_NOT_PROCESS_UNIT         = "\"%s\" is not process_unit."
  ERR_TARGET_NOT_SPINLOCK             = "\"%s\" is not \"#{TSR_OBJ_SPINLOCK}\" object."
  ERR_INTNO_DUPLICATE                 = "\"#{TSR_PRM_INTNO}\" \"%s\" is duplicate.[%s]"
# ERR_NO_CPU_STATE_IN_SPINLOCK        = "\"#{TSR_OBJ_CPU_STATE}\" is not defined during spinlock.(core: %d)"
# ERR_NOT_CPU_LOCK_IN_SPINLOCK        = "\"#{TSR_PRM_LOCCPU}\" is false during spinlock.(core: %d)"
  ERR_CANNOT_OSAP                     = "%s can't access %s."
  ERR_MULTI_OSAP_HOOK                 = "there are multi OS application specific %s."
  ERR_ERROR_HOOK_AND_ERROR_HOOK_OSAP  = "there are #{TSR_OBJ_ERROR_HOOK} and #{TSR_OBJ_ERROR_HOOK_OSAP}."
  ERR_NOT_EXIST_OSAP                  = "%s is not exist."
  ERR_STARTUP_HOOK_OSAP_STOP          = "#{TSR_OBJ_STARTUP_HOOK_OSAP} is not #{TSR_STT_ACTIVATE}."
  ERR_STARTUP_HOOK_OSAP_AND_OTHER_ACT = "there are activate OS application specific startup hook and other processing unit."
  ERR_STARTTICK_INVALID               = "#{TSR_PRM_STARTTICK} is invalid.(%d)"
  ERR_NOT_APPMODE                     = "\"%s\" is not #{TSR_OBJ_APPLICATION_MODE}."
  ERR_NOT_EXIST_TASK_C2ISR            = "if #{TSR_PRM_MAINTASK_WAIT} is true, #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR} must activate in last post_condition"
  ERR_APPMODE_NOT_STARTUPHOOK         = "if #{TSR_PRM_PRO_APPMODE} of #{TSR_LBL_PROPERTY} is set, #{TSR_OBJ_STARTUP_HOOK} or #{TSR_OBJ_STARTUP_HOOK_OSAP} must define."
  ERR_APPMODE_FINISH                  = "if #{TSR_PRM_PRO_APPMODE} of #{TSR_LBL_PROPERTY} is set, must #{TSR_OBJ_SHUTDOWN_HOOK} or #{TSR_OBJ_SHUTDOWN_HOOK_OSAP} define, or #{TSR_PRM_FINISH} of #{TSR_LBL_DO} is true."
  ERR_STARTUPHOOK_TSTAT               = "if #{TSR_OBJ_STARTUP_HOOK} or #{TSR_OBJ_STARTUP_HOOK_OSAP} is active, must #{TSR_PRM_TSTAT} is #{TSR_STT_READY} or #{TSR_STT_SUSPENDED}."
  ERR_STARTUP_SHUTDOWN_HOOK_ACTIVATE  = "if #{TSR_OBJ_STARTUP_HOOK} or #{TSR_OBJ_SHUTDOWN_HOOK} is active, must %s is %s in pre_condition."
  ERR_COUNTER_TASK_C2ISR_NOT_ACTIVATE = "if #{TSR_PRM_CURVAL} is not 0, must active #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR} that belongs to the same core, or not must active #{TSR_OBJ_PRETASK_HOOK} that belongs to the non-master core."
  ERR_NOT_SAME_COREID                 = "#{TSR_PRM_COREID} of \"%s\" and \"%s\" are different."
  ERR_SHARE_RES_NOT_SAME_COREID       = "share %s #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR} are different #{TSR_PRM_COREID}"
  ERR_TASK_C2ISR_NOT_ACTIVATE         = "if %s is %s, must active #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR} that belongs to the same core."
  ERR_RUNNING_WAITSPIN                = "%s can't set %s in pre_condition and last post_condition."
  ERR_LOSTFLG_TRUE_PRE                = "#{TSR_PRM_LOSTFLG} can't set true in pre_condition."
  ERR_SENDERID_DUPLICATE              = "\"#{TSR_PRM_SENDERID}\" \"%s\" is duplicate.[%s]"
  ERR_TASK_C2ISR_NOT_ACTIVATE_OSAP    = "if %s is set, must active #{TSR_OBJ_TASK} or #{TSR_OBJ_C2ISR} that belongs to the same #{TSR_PRM_SENDER} osap."
  ERR_OBJECT_NOT_BELONG_OSAP          = "object that belong to \"%s\" is not defined."

  # シナリオチェック
  ERR_OBJECT_NOT_DEFINED_IN_PRE  = "object \"%s\" is not defined in pre_condition."
  ERR_VAR_NOT_DEFINED_IN_PRE     = "variable \"%s\" is not defined in pre_condition."
  ERR_CANT_RAISE_INT             = "#{TSR_PRM_INTATR} \/ #{TSR_PRM_ISTAT} are #{TSR_STT_DISABLE}."
  ERR_OBJECT_NOT_ACTIVATE_PREV   = "\"%s\" is not activate object in prev condition."
# ERR_CANNOT_BE_RUNNING_WAITSPIN = "\"#{TSR_PRM_TSKSTAT}\" cannot be \"#{TSR_STT_R_WAITSPN}\" in pre_condition or last post_condition."
# ERR_COREID_MACRO_COMBINATION   = "\"#{TSR_PRM_COREID}\" macro's combination is invalid.(using: %s)"

  # シナリオ間チェック
  ERR_UNIFIED_ATR_ISR       = "ISR attributes must be unified."
  ERR_CONFLICT_INTNO        = "\"#{TSR_PRM_INTNO}\" \"%s\" of \"#{TSR_OBJ_C1ISR}\" and \"#{TSR_OBJ_C2ISR}\" is conflict."
  ERR_UNIFIED_OSAP_ISR      = "ISR #{TSR_PRM_OSAP} must be unified."
# ERR_OVER_SPINLOCK_SUM     = "spinlock sum is more than configure setting.\n(you can use emulate mode.)"
# ERR_OVER_INTNO_SUM        = "\"#{TSR_PRM_INTNO}\" sum is more than configure setting."
  ERR_UNIFIED_ATR_RETASK    = "RestartTask attributes must be unified."

  # プロパティ設定
  ERR_PROPERTY_INVALID_VALUE = "\"%s\" of property is invalid value.[%s]"  # 値が不正
  ERR_PROPERTY_INVALID_TYPE  = "\"%s\" of property must be %s.[%s]"
  ERR_PROPERTY_UNDEFINED_KEY = "\"%s\" of property is undefined key."      # キーが未定義

  # プロパティチェック
  ERR_PROPERTY_UNMATCH                      = "\"%s\" is not match."
  ERR_PROPERTY_NO_FUNC                      = "\"%s\" is not available."
  ERR_PROPERTY_OVER_CORE_NUM                = "core number (configure: %d)[%d]"
  ERR_PROPERTY_NOT_MATCH_TIMER_ARCH         = "timer architecture (configure: %s)[%s]"
  ERR_PROPERTY_NOT_MATCH_IRC_ARCH           = "irc architecture (configure: %s)[%s]"
  ERR_PROPERTY_NOT_SUPPORT_ENADIS_INT_SRC   = "#{SS_ENA_INT_SRC} \/ #{SS_DIS_INT_SRC} is not supported."
  ERR_PROPERTY_NOT_MARGE_TEST_CASE          = "Include TESRY that can not merge."
  ERR_PROPERTY_NOT_VIOLATION_HANDLING_LEVEL = "not fulfil violation handling level."
  ERR_PROPERTY_NOT_TIMING_PROTECTION_LEVEL  = "not fulfil timing protection level."
  ERR_PROPERTY_NOT_MEMORY_PROTECTION_LEVEL  = "not fulfil memory protection level."
  ERR_PROPERTY_NOT_SUPPORT_STACK_SHARE      = "shared stack is not supported."
  ERR_PROPERTY_NOT_SUPPORT_MULTI_CORE       = "multi core is not supported."
  ERR_PROPERTY_INVALID_INTPRI_INTNUM        = "\"#{TSR_PRM_INTNO}\" or \"#{TSR_PRM_INIINTPRI}\" or \"#{TSR_PRM_CURPRI}\" is #{TSR_STT_INVALID}."
  ERR_PROPERTY_NO_SPINLOCK                  = "if core num is 1, #{TSR_OBJ_SPINLOCK} is not available."
  ERR_PROPERTY_NO_CONVERT_C2ISR             = "there is no C2ISR to convert."
  ERR_PROPERTY_NOT_MATCH_CONVERT_PRI        = "there is no C2SIR same priority to convert."
  ERR_PROPERTY_CONVERT_ICISR_FAULT_CASE     = "after C2ISR convert to ICISR, test case become impossible."
  ERR_PROPERTY_NOT_MATCH_TARGET_SPEC        = "taeget spec of TESRY is %s. taeget spec of configure is not match."

  #===================================================================
  # 関数
  #===================================================================

  # trueとfalseを一つのクラスで使えるようにするための真偽値マクロ
  Bool = [TrueClass, FalseClass]
  # dup，cloneできないクラス
  CANNOT_CLONE_CLASS = [Fixnum, NilClass, TrueClass, FalseClass, Symbol, Float]

  #=================================================================
  # 概  要: オブジェクトを複製可能な場合は複製
  #=================================================================
  def safe_dup(cObj)
    check_class(Object, cObj, true)  # 複製したいオブジェクト

    # 配列の場合全要素にも適用
    if (cObj.is_a?(Array))
      cObj = cObj.dup()
      cObj.each_with_index{|val, index|
        cObj[index] = safe_dup(val)
      }
      return cObj
    # ハッシュの場合，全値に適用
    elsif(cObj.is_a?(Hash))
      cObj = cObj.dup()
      cObj.each{|atr, val|
        cObj[atr] = safe_dup(val)
      }
      return cObj
    else
      # 複製できる場合はdup
      begin
        if (!CANNOT_CLONE_CLASS.include?(cObj.class))
          return cObj.dup()  # [Object]複製可能な場合は複製後の値，複製不可能な場合はそのまま
        else
          return cObj  # [Object]複製可能な場合は複製後の値，複製不可能な場合はそのまま
        end
      # 既知の複製できないクラスに漏れがあった場合の対策
      rescue TypeError
        return cObj
      end
    end
  end

  #===================================================================
  # 概  要: 変数の型をチェックするメソッド
  #===================================================================
  def check_class(obj, instance, nullable = false)
    # 指定したクラス属性の正当性チェックしてクラスではない場合はエラー終了
    if (obj.is_a?(Array))
      obj.each{|val|
        if (val.class != Class)
          raise(ArgumentError.new("#{obj * ", "} : \"#{val}\" is not Class"))
        end
      }
    elsif (obj.class != Class)
      raise(ArgumentError.new("#{obj} : \"#{obj}\" is not Class"))
    end

    # nullableがtrueまたはfalseではない場合はエラー終了
    if (!nullable.is_a?(FalseClass) && !nullable.is_a?(TrueClass))
      raise(ArgumentError.new("nullable is either true or false"))
    end

    # nullableがfalseなのに変数がnilの場合はエラー終了
    if (instance.nil?() && (nullable == false))
      raise(ArgumentError.new("nullable condition is false"))
    elsif (instance.nil?() && (nullable == true))
      return # [Object]class正当性チェック完了の値
    end

    # 指定したクラス属性と変数のクラス型の正当性チェック
    if (obj.is_a?(Array))
      obj.each{|val|
        if (instance.is_a?(val))
          return # [Object]class正当性チェック完了の値
        end
      }

      raise(ArgumentError.new("class mismatch: #{instance.class} for #{obj * ", "}"))
    elsif (!instance.is_a?(obj))
      raise(ArgumentError.new("class mismatch: #{instance.class} for #{obj}"))
    end

    return # [Object]class正当性チェック完了の値
  end

  #===================================================================
  # 概  要: 処理の進捗を表示
  #===================================================================
  def print_progress(sPhase, sTestID, nCnt, nTotal)
    # 呼び出す処理が局所的のためcheck_classはしない
    Curses.init_screen

    # コンソールの幅取得
    nCols = Curses.cols

    # 進捗率計算
    fProgress = nCnt.to_f / nTotal.to_f

    # プログレスバーサイズ計算(幅-フェーズ-進捗率-最大テストID-括弧等)
    nProgressSize = nCols - AKTG_MAX_TEST_ID_SIZE - 17

    # 整数にしたプログレスバー上の進捗サイズ
    nIntProg = (fProgress * nProgressSize).to_i

    # テストID文字数チェック
    if (AKTG_MAX_TEST_ID_SIZE < sTestID.size())
      sTestID = sTestID.slice(0, AKTG_MAX_TEST_ID_SIZE)
    end

    # 文字列作成
    sProgress = "[#{sPhase}]"
    sProgress += "#" * nIntProg
    sProgress += "-" * (nProgressSize - nIntProg)
    sProgress += ":#{"%5.1f" % (fProgress * 100)}\%"
    sProgress += " [#{sTestID}"
    sProgress += "\s"  * (AKTG_MAX_TEST_ID_SIZE - sTestID.size())
    sProgress += "]"
    $stderr.print("\r#{sProgress}\r")

    Curses.close_screen
  end

  #===================================================================
  # 概  要: 進捗表示の終了
  #===================================================================
  def finish_progress(sPhase, nTotal)
    # 呼び出す処理が局所的のためcheck_classはしない
    Curses.init_screen

    # コンソールの幅取得
    nCols = Curses.cols

    # プログレスバーサイズ計算(幅-フェーズ-進捗率-最大テストID-括弧等)
    nProgressSize = nCols - AKTG_MAX_TEST_ID_SIZE - 17

    # メッセージ作成
    if (sPhase == "AKTF")
      sMsg = AKTF_PROGRESS_MSG % nTotal
    else
      sMsg = AKTG_PROGRESS_MSG % nTotal
    end

    # 文字列作成
    sProgress = "[#{sPhase}]"
    sProgress += "#" * nProgressSize
    sProgress += ":100.0\%"
    sProgress += " [#{sMsg}"
    sProgress += "\s"  * (AKTG_MAX_TEST_ID_SIZE - sMsg.size())
    sProgress += "]"
    $stderr.print(sProgress)

    Curses.close_screen

    $stderr.print(AKTG_NL)
  end

  #===================================================================
  # 概  要: コンソールの横幅チェック
  #===================================================================
  def check_console_width()
    Curses.init_screen

    # コンソールの幅取得
    nCols = Curses.cols

    # プログレスバーサイズ計算(幅-フェーズ-進捗率-最大テストID-括弧等)
    nSize = nCols - AKTG_MAX_TEST_ID_SIZE - 17

    Curses.close_screen

    if (nSize > 0)
      return true  # [Bool]実行可能
    else
      return false  # [Bool]実行不可能
    end
  end

  #================================================================
  # 概  要: XML用コンテナを作成して返す
  #================================================================
  def make_container(sShortName, sContainerName, bIsParam, bIsRefer, bIsSub, sSubPath = "")
    check_class(String, sShortName)      # コンテナに入れるショートネーム
    check_class(String, sContainerName)  # コンテナ名
    check_class(Bool, bIsParam)          # パラメータを含むかどうか
    check_class(Bool, bIsRefer)          # 参照パラメータを含むかどうか
    check_class(Bool, bIsSub)            # サブコンテナを含むかどうか
    check_class(String, sSubPath)        # コンテナまでのパス(サブコンテナでのみ使用)

    sSlash = ""
    if (sSubPath != "")
      sSlash = "/"
    end

    # 一律"ECUC-CONTAINER-VALUE"を入れた状態で初期化
    cContainer = Element.new().add_element("ECUC-CONTAINER-VALUE")

    # ショートネーム追加
    cContainer.add_element(XML_SNAME).add_text(sShortName)

    # コンテナまでのパス追加
    cContainer.add_element("DEFINITION-REF", {"DEST" => "ECUC-PARAM-CONF-CONTAINER-DEF"}).add_text("#{XML_ROOT_PATH}/#{sSubPath}#{sSlash}#{sContainerName}")

    # パラメータがある場合，パラメータ用コンテナを追加しておく
    if (bIsParam == true)
      cContainer.add_element(XML_PARAM)
    end

    # 参照パラメータがある場合，参照パラメータ用コンテナを追加しておく
    if (bIsRefer == true)
      cContainer.add_element(XML_REFER)
    end

    # サブコンテナがある場合，サブコンテナを追加しておく
    if (bIsSub == true)
      cContainer.add_element(XML_SUB)
    end

    return cContainer  # [Element]XML用コンテナ
  end


  #================================================================
  # 概  要: XML用パラメータコンテナを作成して返す
  #================================================================
  def make_parameter(sParameterName, snValue, sSubPath, bRef = false)
    check_class(String, sParameterName)             # パラメータ名
    check_class([String, Integer, Float], snValue)  # 値
    check_class(String, sSubPath)                   # パラメータコンテナまでのパス
    check_class(Bool, bRef, true)                   # 参照パラメータかどうか

    # エレメント生成
    cContainer_ = Element.new()

    # パラメータ毎にコンテナを変更
    case sParameterName
    # 列挙型
    when XML_P_SCAL_CLASS, XML_P_STATUS, XML_P_T_SCHE, XML_P_R_PROP, XML_P_I_CAT, XML_P_I_SRC,
         XML_P_C_TYPE, XML_P_S_STRATEGY, XML_P_A_STA_TYP, XML_P_S_STA_TYP, XML_P_TIM_PRO_LVL,
         XML_P_MEM_PRO_LVL, XML_P_VIO_HAND_LVL, XML_P_S_MEMINI, XML_P_SP_SUS_INT,
         XML_P_IOC_SND_IMPL_KIND, XML_P_IOC_RCV_IMPL_KIND, XML_P_IC_SRC
      sEcuc = "ECUC-TEXTUAL-PARAM-VALUE"
      sDest = "ECUC-ENUMERATION-PARAM-DEF"
    # 整数型
    when XML_P_T_ACT, XML_P_T_PRI, XML_P_T_STKSZ, XML_P_T_STKADD, XML_P_T_SSTKSZ, XML_P_T_SSTKADD,
         XML_P_E_MASK, XML_P_I_NUM, XML_P_I_PRI, XML_P_I_STKSZ, XML_P_C_MAX_VAL, XML_P_C_MIN_CYC,
         XML_P_C_TIC_BASE, XML_P_S_DUR, XML_P_S_OFFSET, XML_P_OSSTK_SZ, XML_P_OSSTK_ADD,
         XML_P_HOOKSTK_SZ, XML_P_HOOKSTK_ADD, XML_P_NTHOOKSTK_SZ, XML_P_NTHOOKSTK_ADD,
         XML_P_O_T_STKSZ, XML_P_A_ALM_TIM, XML_P_A_CYC_TIM, XML_P_S_STA_VAL, XML_P_A_ADD, XML_P_A_SIZE,
         XML_P_O_CORE, XML_P_CORE_NUM, XML_P_HOOKSTK_CORE, XML_P_OSSTK_CORE, XML_P_NTHOOKSTK_CORE,
         XML_P_IOC_BUF_LEN, XML_P_IOC_SND_ID, XML_P_IOC_DATA_INDEX, XML_P_IC_STKSZ, XML_P_MASTER_CORE_ID
      sEcuc = "ECUC-NUMERICAL-PARAM-VALUE"
      sDest = "ECUC-INTEGER-PARAM-DEF"
    # 浮動小数点型
    when XML_P_C_SEC_TICK, XML_P_SCYC_TIM, XML_P_SCYC_TWD_STA, XML_P_SCYC_TWD_LEN 
      sEcuc = "ECUC-NUMERICAL-PARAM-VALUE"
      sDest = "ECUC-FLOAT-PARAM-DEF"
    # ブール型
    when XML_P_STK_MON, XML_P_USE_GET_SRV_ID, XML_P_USE_PARAM_ACC,
         XML_P_ERR_HOOK, XML_P_POS_HOOK, XML_P_PRE_HOOK, XML_P_PRO_HOOK, XML_P_SHU_HOOK, XML_P_STA_HOOK,
         XML_P_S_REP, XML_P_O_TRUSTED, XML_P_O_H_ERR, XML_P_O_H_SHU, XML_P_O_H_STA, XML_P_M_EXPORT,
         XML_P_S_WRITE, XML_P_S_READ, XML_P_S_EXEC, XML_P_S_SDATA, XML_P_S_CACHE, XML_P_S_IODEV,
         XML_P_S_EXPORT, XML_P_A_WRITE, XML_P_A_READ, XML_P_A_EXEC, XML_P_A_CACHE, XML_P_A_IODEV
      sEcuc = "ECUC-NUMERICAL-PARAM-VALUE"
      sDest = "ECUC-BOOLEAN-PARAM-DEF"
    # 文字列型
    when XML_P_L_NAME, XML_P_S_NAME, XML_P_M_NAME, XML_P_INCLUDE_FILE,
         XML_P_IOC_INI_VAL, XML_P_IOC_DATA_TYPE
      sEcuc = "ECUC-TEXTUAL-PARAM-VALUE"
      sDest = "ECUC-STRING-PARAM-DEF"
    # 関数名
    when XML_P_A_CBACK, XML_P_O_T_NAME
      sEcuc = "ECUC-TEXTUAL-PARAM-VALUE"
      sDest = "ECUC-FUNCTION-NAME-DEF"
    # 参照
    when XML_P_T_APP_MODE, XML_P_T_RES, XML_P_T_EVT, XML_P_R_LINK, XML_P_I_RES, XML_P_C_ISR,
         XML_P_A_CNT, XML_P_A_INCR_CNT, XML_P_A_EVT_TSK, XML_P_A_SET_EVT, XML_P_A_ACT_TSK,
         XML_P_S_CNT, XML_P_S_ACT_TSK, XML_P_S_SET_EVT, XML_P_S_EVT_TSK, XML_P_O_ALM,
         XML_P_O_CNT, XML_P_O_ISR, XML_P_O_SCHTBL, XML_P_O_TSK, XML_P_O_RE_TSK, XML_P_T_ACC_APP,
         XML_P_I_ACC_APP, XML_P_R_ACC_APP, XML_P_C_ACC_APP, XML_P_A_ACC_APP, XML_P_S_ACC_APP,
         XML_P_L_MEM_REG, XML_P_A_APP_MODE, XML_P_S_APP_MODE, XML_P_S_REG, XML_P_O_MEMSEC,
         XML_P_O_MEMMOD, XML_P_O_MEMAREA, XML_P_SP_ACC_APP, XML_P_SP_SCCR,
         XML_P_IOC_SND_OSAP, XML_P_IOC_RCV_OSAP, XML_P_IC_ACC_APP, XML_P_IC_RES, XML_P_O_ICISR,
         XML_P_O_SCYCTWD
      sEcuc = "ECUC-REFERENCE-VALUE"
      sDest = "ECUC-REFERENCE-DEF"
    else
      abort(ERR_MSG % [__FILE__, __LINE__])
    end

    # コンテナ生成
    cContainer = cContainer_.add_element(sEcuc)
    cContainer.add_element("DEFINITION-REF", {"DEST" => sDest}).add_text("#{XML_ROOT_PATH}/#{sSubPath}/#{sParameterName}")

    # 値を定義
    if (bRef == false)
      cContainer.add_element("VALUE").add_text(snValue.to_s())
    else
      cContainer.add_element("VALUE-REF", {"DEST" => "ECUC-CONTAINER-VALUE"}).add_text(XML_REF_PATH + snValue)
    end

    return cContainer  # [Element]XML用パラメータコンテナ
  end
end
