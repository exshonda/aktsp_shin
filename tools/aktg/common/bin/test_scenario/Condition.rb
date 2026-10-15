#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2011-2014 by Spansion LLC, USA
# Copyright (C) 2011-2014 by NEC Communication Systems, Ltd., JAPAN
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
# $Id: Condition.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/CommonModule.rb"
require "common/bin/Config.rb"
require "common/bin/process_unit/Task.rb"
require "common/bin/process_unit/C1Isr.rb"
require "common/bin/process_unit/C2Isr.rb"
require "common/bin/process_unit/AlarmCallBack.rb"
require "common/bin/process_unit/StartupHook.rb"
require "common/bin/process_unit/ShutdownHook.rb"
require "common/bin/process_unit/PreTaskHook.rb"
require "common/bin/process_unit/PostTaskHook.rb"
require "common/bin/process_unit/ErrorHook.rb"
require "common/bin/process_unit/ProtectionHook.rb"
require "common/bin/process_unit/TrustedFunction.rb"
require "common/bin/process_unit/StartupHookOsap.rb"
require "common/bin/process_unit/ShutdownHookOsap.rb"
require "common/bin/process_unit/ErrorHookOsap.rb"
require "common/bin/process_unit/IcIsr.rb"
require "common/bin/sc_object/Resource.rb"
require "common/bin/sc_object/Event.rb"
require "common/bin/sc_object/Counter.rb"
require "common/bin/sc_object/Alarm.rb"
require "common/bin/sc_object/ScheduleTable.rb"
require "common/bin/sc_object/Spinlock.rb"
require "common/bin/sc_object/Ioc.rb"
require "common/bin/sc_object/IocSender.rb"
require "common/bin/sc_object/IocReceiver.rb"
require "common/bin/sc_object/IocData.rb"
require "common/bin/sys_state/IntState.rb"
require "common/bin/sys_state/AppMode.rb"
require "common/bin/sys_state/MemoryModule.rb"
require "common/bin/sys_state/MemoryArea.rb"
require "common/bin/sys_state/MemorySection.rb"
require "common/bin/sys_state/Osap.rb"
require "common/bin/process_unit/RestartTask.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/test_scenario/Condition.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Condition
  # 概    要: pre_condition, post_conditionの情報を処理するクラス
  #===================================================================
  class Condition
    include CommonModule

    attr_reader :hAllObject, :sTestMain, :hTask, :cActivate, :aActivate, :cRunning, :aRunning, :aActivateProcUnit
    attr_reader :bIsC1Isr, :bIsC2Isr, :lMainTaskState, :lKernelState, :aNeedSi, :bIsHwcnt, :aErrorHookTsetId, :bIsIcIsr
    attr_reader :bIsStartupHook, :bIsShutdownHook, :bIsPreTaskHook, :bIsPostTaskHook, :bIsErrorHook, :bIsProtectionHook
    attr_reader :bIsStartupHookOsap, :bIsShutdownHookOsap, :bIsErrorHookOsap, :aStartupHookOsapId, :aShutdownHookOsapId
    attr_reader :bIsActiveStartupHook, :bIsActiveShutdownHook, :bIsActiveStartupHookOsap, :bIsActiveShutdownHookOsap
    attr_reader :aActivateCoreOnStartupShutdown, :bIsRestartTask, :aTerminateOsap

    # コア間割込み変換用
    @@hC2isrToIcisr = Hash.new{|hash, key|
      hash[key] = {
        :sObjectID => "",
        :sIntno => ""
      }
    }

    #=================================================================
    # 概  要: コンストラクタ
    #=================================================================
    def initialize(sTestID, hProperty)
      check_class(String, sTestID)     # テストID
      check_class(Hash, hProperty)     # プロパティ

      @hAllObject    = {}                 # 生成された全オブジェクトの情報を保持するためのハッシュ
      @cConf         = Config.new()       # コンフィグの取得
      @sTestID       = sTestID            # テストID
      @sTestMain     = sTestID + "_main"  # メイン関数名の生成
      @hProperty     = hProperty          # プロパティ
      @aNeedSi       = []                 # 各コンディションの処理単位とdoに指定されたtarget_specと一致しないneed_si(フィルタリングに使用)
      @sErrorHookCfg = ""                 # configure.yamlで指定したエラーフックのコンフィギュレーションの組合せ
      @lKernelState  = nil                # 置換処理用
      @aTerminateOsap = []                # 終了/再起動中のOSAPID

      if (!@cConf.enable_osap?())
        if (@cConf.enable_error_hook() == true)
          @sErrorHookCfg = TSR_STT_ONLY_SYSTEM
        end
      else
        if (@cConf.enable_error_hook() == true && @cConf.enable_error_hook_osap() == true)
          @sErrorHookCfg = TSR_STT_BOTH
        elsif (@cConf.enable_error_hook() == true && @cConf.enable_error_hook_osap() == false)
          @sErrorHookCfg = TSR_STT_ONLY_SYSTEM
        elsif (@cConf.enable_error_hook() == false && @cConf.enable_error_hook_osap() == true)
          @sErrorHookCfg = TSR_STT_ONLY_OSAP
        end
      end

      @hMainTaskInfo = {               # メインタスク情報
        :id      => @sTestMain,
        :coreid  => @cConf.get_master_core(),
        :bootcnt => AKTG_MAIN_BOOTCNT
      }

      @bIsC1Isr            = false
      @bIsC2Isr            = false
      @bIsStartupHook      = false
      @bIsShutdownHook     = false
      @bIsPreTaskHook      = false
      @bIsPostTaskHook     = false
      @bIsErrorHook        = false
      @bIsProtectionHook   = false
      @bIsHwcnt            = false
      @bIsStartupHookOsap  = false
      @bIsShutdownHookOsap = false
      @bIsErrorHookOsap    = false
      @aStartupHookOsapId  = []
      @aShutdownHookOsapId = []
      @bIsIcIsr            = false
      @bIsRestartTask      = false

      @bIsActiveStartupHook      = false
      @bIsActiveShutdownHook     = false
      @bIsActiveStartupHookOsap  = false
      @bIsActiveShutdownHookOsap = false

      # Multi用
      @nMasterCoreid  = @cConf.get_master_core()  # マスタコアID
      nCoreNum        = @cConf.get_core_num()     # コア数
      @aCoreid        = (0..(nCoreNum-1)).to_a()  # コアループのための配列
      @aSpinProcID    = []                        # スピンロックを取得している処理単位ID

      # スタートアップ/シャットダウンフック中に処理単位が起動するコアの管理
      @aActivateCoreOnStartupShutdown = Array.new(nCoreNum, false)

      # エラーチェック用
      @aErrorHookTsetId =[]

    end

    #=================================================================
    # 概  要: 各オブジェクトを生成する
    #=================================================================
    def store_condition_info(hCondition, hObjectType, sTestID)
      check_class(Hash, hCondition)  # コンディション情報
      check_class(Hash, hObjectType) # オブジェクトタイプ
      check_class(String, sTestID)   # テストID

      # オブジェクト生成
      aErrors = []
      aPath = get_condition_path()
      hMacro = @cConf.get_macro()
      hMcMacro = @cConf.get_mc_macro()
      bIsPre  = (self.class() == PreCondition)
      bErrorHookOsap = false
      aExistStartupHook    = Array.new(@cConf.get_core_num(), false)  # システム定義のスタートアップフックが存在するコアIDを格納
      aExistShutdownHook   = Array.new(@cConf.get_core_num(), false)  # システム定義のシャットダウンフックが存在するコアIDを格納
      aExistPreTaskHook    = Array.new(@cConf.get_core_num(), false)  # システム定義のプレタスクフックが存在するコアIDを格納
      aExistPostTaskHook   = Array.new(@cConf.get_core_num(), false)  # システム定義のポストタスクフックが存在するコアIDを格納
      aExistErrorHook      = Array.new(@cConf.get_core_num(), false)  # システム定義のエラーフックが存在するコアIDを格納
      aExistProtectionHook = Array.new(@cConf.get_core_num(), false)  # システム定義のプロテクションフックが存在するコアIDを格納

      hCondition.each{|sObjectID, hObjectInfo|
        ### T5_001: post_conditionにpre_conditionで定義されていないオブジェクトIDが存在する
        if (!hObjectType.has_key?(sObjectID))
          sErr = sprintf("T5_001: " + ERR_OBJECT_NOT_DEFINED_IN_PRE, sObjectID)
          aErrors.push(YamlError.new(sErr, aPath))
        else
          bCreate = true
          if (bIsPre == true)
            aNeedSi = hObjectInfo[TSR_PRM_NEED_SI]
            if (!aNeedSi.nil?() && aNeedSi.is_a?(Array))
              aNeedSi.each{|sSpec|
                if (!@cConf.get_target_spec.include?(sSpec[/\D*/]) && GRP_NEED_SI_AVAILABLE.include?(sSpec[/\D*/]))
                  @aDeleteObj.push(sObjectID)
                  @aNeedSi.push(sSpec)
                  bCreate = false
                end
              }
            end
            # AK_SC1_SINGLEをSC1，SC1-MCに合わせて置換する
            if (!hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].nil?() && hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].is_a?(Array) &&
                hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].include?(TSR_STT_SINGLE))
              if (@cConf.is_sc1?())
                hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].delete(TSR_STT_SINGLE)
                if (@cConf.is_multi?())
                  hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].concat([TSR_STT_ONLY_SYSTEM,TSR_STT_BOTH])
                else
                  hObjectInfo[TSR_PRM_ERROR_HOOK_CFG].concat([TSR_STT_ONLY_SYSTEM])
                end
              end
            end
            aErrorHookCfg = hObjectInfo[TSR_PRM_ERROR_HOOK_CFG]
            if (bCreate == true && !aErrorHookCfg.nil?() && aErrorHookCfg.is_a?(Array))
              aInvalidPrm = (GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC | aErrorHookCfg) - GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC
              if (!aErrorHookCfg.include?(@sErrorHookCfg) && aInvalidPrm.empty?())
                @aDeleteObj.push(sObjectID)
                bCreate = false
                @aErrorHookTsetId.push(sTestID)
              end
            end
          else
            if (!@aDeleteObj.nil?())
              @aDeleteObj.each{|sDelObjectID|
                if (sObjectID == sDelObjectID)
                  bCreate = false
                end
              }
            end
          end
          if (bCreate == false)
            next
          end
          begin
            sObjectType = hObjectType[sObjectID]
            case sObjectType
            when TSR_OBJ_TASK
              cNewObject = Task.new(sObjectID, hObjectInfo, aPath, bIsPre, @hProperty)
            when TSR_OBJ_C1ISR
              cNewObject = C1Isr.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsC1Isr = true
            when TSR_OBJ_C2ISR
              if (@cConf.enable_icisr_convert?() && (hObjectInfo[TSR_PRM_INIINTPRI] == @cConf.get_icisr_convert_pri() || @@hC2isrToIcisr.has_key?(sObjectID)))
                # 変換用のオブジェクトIDを保持
                @@hC2isrToIcisr[sObjectID][:sObjectID] = AKTG_LBL_ICISR_CONVERT + sObjectID
                if (@@hC2isrToIcisr[sObjectID][:sIntno].empty?())
                  # pre_condition時のみ代入
                  if (hObjectInfo[TSR_PRM_INTNO].is_a?(String))
                    @@hC2isrToIcisr[sObjectID][:sIntno] = hMacro[hObjectInfo[TSR_PRM_INTNO]]
                  else
                    @@hC2isrToIcisr[sObjectID][:sIntno] = hObjectInfo[TSR_PRM_INTNO]
                  end
                end
                # 不要なパラメータは削除
                hObjectInfo.delete(TSR_PRM_INIINTPRI)
                hObjectInfo.delete(TSR_PRM_CURINTPRI)
                # type，ObjectIDを変換
                hObjectInfo[TSR_PRM_TYPE] = TSR_OBJ_ICISR
                sObjectID = @@hC2isrToIcisr[sObjectID][:sObjectID]
                # ICISRの生成
                cNewObject = IcIsr.new(sObjectID, hObjectInfo, aPath, bIsPre)
                @bIsIcIsr = true
              else
                cNewObject = C2Isr.new(sObjectID, hObjectInfo, aPath, bIsPre)
                @bIsC2Isr = true
              end
            when TSR_OBJ_STARTUP_HOOK
              cNewObject = StartupHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsStartupHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistStartupHook[@cConf.get_master_core()] = true
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistStartupHook[nCoreid] = true
                end
              end
              # ACTIVATEとなるスタートアップフックの存在確認
              if (cNewObject.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
                @bIsActiveStartupHook = true
              end
            when TSR_OBJ_SHUTDOWN_HOOK
              cNewObject = ShutdownHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsShutdownHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistShutdownHook[@cConf.get_master_core()] = true
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistShutdownHook[nCoreid] = true
                end
              end
              # ACTIVATEとなるシャットダウンフックの存在確認
              if (cNewObject.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
                @bIsActiveShutdownHook = true
              end
            when TSR_OBJ_PRETASK_HOOK
              cNewObject = PreTaskHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsPreTaskHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistPreTaskHook[@cConf.get_master_core()] = true
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistPreTaskHook[nCoreid] = true
                end
              end
            when TSR_OBJ_POSTTASK_HOOK
              cNewObject = PostTaskHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsPostTaskHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistPostTaskHook[@cConf.get_master_core()] = true
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistPostTaskHook[nCoreid] = true
                end
              end
            when TSR_OBJ_ERROR_HOOK
              cNewObject = ErrorHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsErrorHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistErrorHook[@cConf.get_master_core()] = true
                # SC1のテストケースをMCの環境で実行する場合，OSAP固有のエラーフックを補完する
                if (@cConf.is_sc1?() && @cConf.is_multi?() && @sErrorHookCfg != TSR_STT_ONLY_SYSTEM)
                  bErrorHookOsap = true
                end
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistErrorHook[nCoreid] = true
                end
              end
            when TSR_OBJ_PROTECTION_HOOK
              cNewObject = ProtectionHook.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsProtectionHook = true
              if (cNewObject.hState[TSR_PRM_COREID].nil?())
                aExistProtectionHook[@cConf.get_master_core()] = true
              else
                nCoreid = hMacro[cNewObject.hState[TSR_PRM_COREID]]
                if (nCoreid.is_a?(Integer))
                  aExistProtectionHook[nCoreid] = true
                end
              end
            when TSR_OBJ_ALARM_CALL_BACK
              cNewObject = AlarmCallBack.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_ALARM
              cNewObject = Alarm.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_SCHEDULE_TABLE
              cNewObject = ScheduleTable.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_RESOURCE
              cNewObject = Resource.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_EVENT
              cNewObject = Event.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_COUNTER
              cNewObject = Counter.new(sObjectID, hObjectInfo, aPath, bIsPre)
              if (cNewObject.is_hardware_counter?() == true)
                @bIsHwcnt = true
              end
            when TSR_OBJ_INT_STATE
              cNewObject = IntState.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_TRUSTED_FUNCTION
              cNewObject = TrustedFunction.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_STARTUP_HOOK_OSAP
              cNewObject = StartupHookOsap.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsStartupHookOsap = true
              # 置換後のOSAPIDはここでしか取得できない
              if (hMcMacro.has_key?(cNewObject.hState[TSR_PRM_OSAP]))
                @aStartupHookOsapId.push(hMcMacro[cNewObject.hState[TSR_PRM_OSAP]])
              else
                @aStartupHookOsapId.push(cNewObject.hState[TSR_PRM_OSAP])
              end
              # ACTIVATEとなるOSAP固有スタートアップフックの存在確認
              if (cNewObject.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
                @bIsActiveStartupHookOsap = true
              end
            when TSR_OBJ_SHUTDOWN_HOOK_OSAP
              cNewObject = ShutdownHookOsap.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsShutdownHookOsap = true
              # 置換後のOSAPIDはここでしか取得できない
              if (hMcMacro.has_key?(cNewObject.hState[TSR_PRM_OSAP]))
                @aShutdownHookOsapId.push(hMcMacro[cNewObject.hState[TSR_PRM_OSAP]])
              else
                @aShutdownHookOsapId.push(cNewObject.hState[TSR_PRM_OSAP])
              end
              # ACTIVATEとなるOSAP固有シャットダウンフックの存在確認
              if (cNewObject.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
                @bIsActiveShutdownHookOsap = true
              end
            when TSR_OBJ_ERROR_HOOK_OSAP
              cNewObject = ErrorHookOsap.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsErrorHookOsap = true
            when TSR_OBJ_APPLICATION_MODE
              cNewObject = AppMode.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_MEMORY_MODULE
              cNewObject = MemoryModule.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_MEMORY_AREA
              cNewObject = MemoryArea.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_MEMORY_SECTION
              cNewObject = MemorySection.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_SPINLOCK
              cNewObject = Spinlock.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_IOC
              cNewObject = Ioc.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_IOC_SENDER
              cNewObject = IocSender.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_IOC_RECEIVER
              cNewObject = IocReceiver.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_IOC_DATA
              cNewObject = IocData.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_ICISR
              cNewObject = IcIsr.new(sObjectID, hObjectInfo, aPath, bIsPre)
              @bIsIcIsr = true
            when TSR_OBJ_OSAP
              # SC3のテストをSC3-MCに流用する場合，OSAPIDが変換されるため，変換後のIDで生成処理をする
              if (@cConf.is_multi?() && hMcMacro.has_key?(sObjectID))
                sObjectID = hMcMacro[sObjectID]
              end
              cNewObject = Osap.new(sObjectID, hObjectInfo, aPath, bIsPre)
            when TSR_OBJ_RESTART_TASK
              cNewObject = RestartTask.new(sObjectID, hObjectInfo, aPath, bIsPre, @hProperty)
              @bIsRestartTask = true
            else
              abort(ERR_MSG % [__FILE__, __LINE__])
            end

            # 生成されたオブジェクトを@hAllObjectに保持
            @hAllObject[sObjectID] = cNewObject
          # オブジェクト生成時に発生したエラーをまとめる
          rescue AKTFMultiError
            aErrors.concat($!.aErrors)
          end
        end
      }

      # コア間割込み変換モードの場合，変更対象のISRIDがあるパラメータを使用しているオブジェクトをチェックする
      if (@cConf.enable_icisr_convert?())
        @hAllObject.each{|sObjectID, cObject|
          # INT_STATE
          if (cObject.sObjectType == TSR_OBJ_INT_STATE && !cObject.hState[TSR_PRM_ISTAT].nil?())
            cObject.hState[TSR_PRM_ISTAT].each{|hIntState|
              hIntState.each{|sInt, sObj|
                if (@@hC2isrToIcisr.has_key?(sObj))
                  hIntState[sInt] = @@hC2isrToIcisr[sObj][:sObjectID]
                end
              }
            }
          # 信頼関数
          elsif (cObject.sObjectType == TSR_OBJ_TRUSTED_FUNCTION && !cObject.hState[TSR_PRM_CALLER].nil?())
            if (@@hC2isrToIcisr.has_key?(cObject.hState[TSR_PRM_CALLER]))
              cObject.hState[TSR_PRM_CALLER] = @@hC2isrToIcisr[cObject.hState[TSR_PRM_CALLER]][:sObjectID]
            end
          end
        }
      end

      # マルチコアでは，全コアで起動するフックが存在しないコアには，
      # AK_STOPのフックを補完する
      if ((bIsPre == true) && @cConf.is_multi?() && !@cConf.enable_boot_only_master_core?())
        if (@bIsStartupHook == true && aExistStartupHook.include?(false))
          aExistStartupHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_STARTUP_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_STARTUP_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = StartupHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        if (@bIsShutdownHook == true && aExistShutdownHook.include?(false))
          aExistShutdownHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_SHUTDOWN_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_SHUTDOWN_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = ShutdownHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        if (@bIsPreTaskHook == true && aExistPreTaskHook.include?(false))
          aExistPreTaskHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_PRETASK_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_PRETASK_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = PreTaskHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        if (@bIsPostTaskHook == true && aExistPostTaskHook.include?(false))
          aExistPostTaskHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_POSTTASK_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_POSTTASK_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = PostTaskHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        if (@bIsErrorHook == true && aExistErrorHook.include?(false))
          aExistErrorHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_ERROR_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_ERROR_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = ErrorHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        if (@bIsProtectionHook == true && aExistProtectionHook.include?(false))
          aExistProtectionHook.each_with_index{|bExist, nCoreid|
            if (bExist == false)
              sObjectID = "AKTG_#{TSR_OBJ_PROTECTION_HOOK}_#{nCoreid}"
              hObjectInfo = {"type" => TSR_OBJ_PROTECTION_HOOK, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => nCoreid}
              cNewObject = ProtectionHook.new(sObjectID, hObjectInfo, aPath, true)
              @hAllObject[sObjectID] = cNewObject
            end
          }
        end
        # エラーフックがあるSC1/SC3のテストをMCの環境で実行する場合，OSAP固有のエラーフックを補完する
        if (bErrorHookOsap == true && @bIsErrorHookOsap != true)
          sObjectID = "AKTG_#{TSR_OBJ_ERROR_HOOK_OSAP}_0"
          hObjectInfo = {"type" => TSR_OBJ_ERROR_HOOK_OSAP, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => 0, TSR_PRM_OSAP => @cConf.get_default_osap_id(), TSR_PRM_ERROR_HOOK_CFG => [TSR_STT_ONLY_OSAP, TSR_STT_BOTH]}
          cNewObject = ErrorHookOsap.new(sObjectID, hObjectInfo, aPath, true)
          @hAllObject[sObjectID] = cNewObject
          @bIsErrorHookOsap = true
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: インスタンス変数初期化
    #=================================================================
    def init_instance_variables()
      @hTask = get_objects_by_type([TSR_OBJ_TASK, TSR_OBJ_RESTART_TASK])   # 全タスクのリスト作成
      @hActiveTfn = get_active_tfn()                                       # 実行中の信頼関数と処理単位のリスト作成

      # 信頼関数が獲得したリソース，待ち対象イベント，獲得したスピンロックの情報を呼出し元の情報へ格納
      hObjects = get_objects_by_type(TSR_OBJ_TRUSTED_FUNCTION)
      if (!hObjects.empty?())
        hObjects.each_value{|cObjectInfo|
          if (!cObjectInfo.hState[TSR_PRM_WAIEVT].nil?())
            @hAllObject[cObjectInfo.hState[TSR_PRM_CALLER]].hState[TSR_PRM_WAIEVTTFN] = cObjectInfo.hState[TSR_PRM_WAIEVT]
          end
          if (!cObjectInfo.hState[TSR_PRM_GETRES].nil?())
            @hAllObject[cObjectInfo.hState[TSR_PRM_CALLER]].hState[TSR_PRM_GETRESTFN] = cObjectInfo.hState[TSR_PRM_GETRES]
          end
          if (@cConf.is_multi?() && !cObjectInfo.hState[TSR_PRM_GETSPN].nil?())
            @hAllObject[cObjectInfo.hState[TSR_PRM_CALLER]].hState[TSR_PRM_GETSPNTFN] = cObjectInfo.hState[TSR_PRM_GETSPN]
          end
        }
      end

      # シングルコア
      if (@cConf.is_single?())
        # 内部リソースIDリスト，内部リソース獲得時の優先度リストを作成
        @aInternalResID = []
        @hInternalResPri = {}
        @hAllObject.reject{|sObjectID, cObjectInfo|
          if ((cObjectInfo.sObjectType == TSR_OBJ_RESOURCE) && 
              (cObjectInfo.hState[TSR_PRM_RESPROP] == TSR_STT_INTERNAL))
            @aInternalResID.push(sObjectID)
            # 内部リソースが関連付けされているタスクで最も高い初期優先度を格納する
            @hTask.each{|sTaskID, cTaskInfo|
              if (!cTaskInfo.hState[TSR_PRM_RELRES].nil?() &&
                  cTaskInfo.hState[TSR_PRM_RELRES].include?(sObjectID))
                nIniPri = cTaskInfo.hState[TSR_PRM_INIPRI]
                if (!@hInternalResPri.has_key?(sObjectID) ||
                    (@hInternalResPri[sObjectID] < nIniPri))
                  @hInternalResPri[sObjectID] = nIniPri
                end
              end
            }
          end 
        }

        @cActivate  = get_activate()
        @cRunning   = get_running()

      # マルチコア
      else
        # コア毎のタスク配列
        @aTaskEachCore = []
        @aCoreid.each{|nCoreid|
          @aTaskEachCore[nCoreid] = {}
          @hTask.each{|key, val|
            if (val.hState[TSR_PRM_COREID] == nCoreid)
              @aTaskEachCore[nCoreid][key] = val
            end
          }
        }

        # コア毎に内部リソースIDリスト，内部リソース獲得時の優先度リストを作成
        @aInternalResIDEachCore = []
        @aInternalResPriEachCore = []
        @aCoreid.each{|nCoreid|
          @aInternalResIDEachCore[nCoreid] = []
          @aInternalResPriEachCore[nCoreid] = {}
          @hAllObject.reject{|sObjectID, cObjectInfo|
            if ((cObjectInfo.sObjectType == TSR_OBJ_RESOURCE) && 
                (cObjectInfo.hState[TSR_PRM_RESPROP] == TSR_STT_INTERNAL))
              @aInternalResIDEachCore[nCoreid].push(sObjectID)
              # 内部リソースが関連付けされているタスクで最も高い初期優先度を格納する
              @aTaskEachCore[nCoreid].each{|sTaskID, cTaskInfo|
                if (!cTaskInfo.hState[TSR_PRM_RELRES].nil?() &&
                    cTaskInfo.hState[TSR_PRM_RELRES].include?(sObjectID))
                  nIniPri = cTaskInfo.hState[TSR_PRM_INIPRI]
                  if (!@aInternalResPriEachCore[nCoreid].has_key?(sObjectID) ||
                      (@aInternalResPriEachCore[nCoreid][sObjectID] < nIniPri))
                    @aInternalResPriEachCore[nCoreid][sObjectID] = nIniPri
                  end
                end
              }
            end 
          }
        }

        # 各コアの割込み禁止状態，実行状態である非タスク，タスク
        @aIntState = get_int_state_multi()
        @aActivate = get_activate_multi()
        @aRunning  = get_running_multi()

        # c系はマスタコアIDのものを指し示すように設定
        @aIntState = @aIntState[@nMasterCoreid]
        @cRunning  = @aRunning[@nMasterCoreid]
        @cActivate = @aActivate[@nMasterCoreid]

        # マルチコアにおいて各コアで実行中の処理単位情報を取得しておく
        @aActivateProcUnit = []
        @aCoreid.each{|nCoreid|
          if (!@aActivate[nCoreid].nil?())
            if (@hActiveTfn.has_key?(@aActivate[nCoreid].sObjectID))
              @aActivateProcUnit[nCoreid] = @hActiveTfn[@aActivate[nCoreid].sObjectID]
            else
              @aActivateProcUnit[nCoreid] = @aActivate[nCoreid]
            end
          elsif (!@aRunning[nCoreid].nil?())
            if (@hActiveTfn.has_key?(@aRunning[nCoreid].sObjectID))
              @aActivateProcUnit[nCoreid] = @hActiveTfn[@aRunning[nCoreid].sObjectID]
            else
              @aActivateProcUnit[nCoreid] = @aRunning[nCoreid]
            end
          else
            # 実行状態が存在しないコアにはnilを入れておく
            @aActivateProcUnit[nCoreid] = nil
          end
        }

        # スタートアップ/シャットダウンフック中に処理単位が起動するコアの管理情報を更新する
        @aCoreid.each{|nCoreid|
          if (!@aActivateProcUnit[nCoreid].nil?() &&
              GRP_PROCESS_UNIT_BOOTABLE_ON_STARTUP_SHUTDOWN_HOOK_EACH_CORE.include?(@aActivateProcUnit[nCoreid].sObjectType))
            @aActivateCoreOnStartupShutdown[nCoreid] = true
          end
        }
      end
    end

    #=================================================================
    # 概  要: 指定したタイプに一致するオブジェクトを取得
    #=================================================================
    def get_objects_by_type(saType)
      check_class([String, Array], saType)  # オブジェクトタイプ

      # 文字列の場合配列にする
      if (saType.is_a?(String))
        saType = saType.each_line().to_a()
      end
      # 全オブジェクト情報から該当するタイプのオブジェクトを抜き出す
      hResult = @hAllObject.reject{|sObjectID, cObjectInfo|
        !(saType.include?(cObjectInfo.sObjectType))
      }

      return hResult # [Hash]オブジェクトのハッシュ
    end

    #=================================================================
    # 概  要: オブジェクトIDで該当のオブジェクトの情報を探して返す
    #=================================================================
    def get_object_info(sObjectID)
      check_class(String, sObjectID)  # オブジェクトID

      return @hAllObject[sObjectID]  # [Object]オブジェクトクラス
    end

    #=================================================================
    # 概  要: 実行中の非タスクのある場合はfalseを，
    #         実行中の非タスクのない場合はtrueを返す
    #=================================================================
    def check_activate_context()
      if (@cActivate.nil?())
        return true # [Bool]非タスクがある場合
      else
        return false # [Bool]非タスクがない場合
      end
    end

    #=================================================================
    # 概  要: 実行中のタスクを返す
    #         (ACTIVATEなタスク例外が関連付いている場合はタスク例外を返す)
    #=================================================================
    def get_running()
      @hTask.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_TASK || cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK) && cObjectInfo.is_activate?())
          return cObjectInfo  # [Task]実行中のタスク
        end
      }

      return nil
    end

    #=================================================================
    # 概  要: 実行中の処理単位を返す
    #=================================================================
    def get_activate()
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (GRP_NON_CONTEXT.include?(cObjectInfo.sObjectType) && cObjectInfo.is_activate?())
          return cObjectInfo  # [Object] 実行中の処理単位
        end
      }

      return nil
    end

    #=================================================================
    # 概  要: 実行中のタスクを返す
    #=================================================================
    def get_running_multi()
      aRunning = []

      @aTaskEachCore.each_with_index{|hTask, nCoreid|
        hTask.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.is_activate?())
            aRunning[nCoreid] = cObjectInfo
          end
        }
      }

      return aRunning  # [Array]実行中のタスク
    end

    #=================================================================
    # 概  要: 実行中の非タスクを返す
    #=================================================================
    def get_activate_multi()
      aActivate = []

      @hAllObject.each{|sObjectID, cObjectInfo|
        if (GRP_NON_CONTEXT.include?(cObjectInfo.sObjectType) && cObjectInfo.is_activate?())
          aActivate[cObjectInfo.hState[TSR_PRM_COREID]] = cObjectInfo
        end
      }

      return aActivate  # [Array]実行中の非タスク
    end

    #=================================================================
    # 概  要: 割込み禁止状態を返す
    #=================================================================
    def get_int_state_multi()
      aIntState = []
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.sObjectType == TSR_OBJ_INT_STATE)
           aIntState[cObjectInfo.hState[TSR_PRM_COREID]] = cObjectInfo
        end
      }
      return aIntState  # [Array]割込み禁止状態
    end

    #=================================================================
    # 概  要: 実行中の信頼関数と処理単位の関連ハッシュを返す
    #=================================================================
    def get_active_tfn()
      hActiveTfn = {}

      # 信頼関数のcallerに指定されている処理単位IDと信頼関数クラスを関連付ける
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        @hAllObject.each{|sObjectID, cObjectInfo|
          if ((cObjectInfo.sObjectType == TSR_OBJ_TRUSTED_FUNCTION) &&
              !cObjectInfo.hState[TSR_PRM_CALLER].nil?())
            hActiveTfn[cObjectInfo.hState[TSR_PRM_CALLER]] = cObjectInfo
          end
        }
      end

      return hActiveTfn
    end

    #=================================================================
    # 概  要: 実行中の処理単位を返す
    #=================================================================
    def get_prev_actvate_running(nCoreid = nil)
      cActiveProcUnit = nil

      if (@cConf.is_single?())
        if (!@cActivate.nil?())
          cActiveProcUnit = @cActivate # [Object] 起動中の処理単位
        else
          cActiveProcUnit = @cRunning # [Object] 実行中の処理単位
        end
      else
        if (!@aActivate[nCoreid].nil?())
          cActiveProcUnit = @aActivate[nCoreid] # [Object] 起動中の処理単位
        else
          cActiveProcUnit = @aRunning[nCoreid] # [Object] 実行中の処理単位
        end
      end

      # 信頼関数呼出し時は変換する
      if (!cActiveProcUnit.nil?() && @hActiveTfn.has_key?(cActiveProcUnit.sObjectID))
        cActiveProcUnit = @hActiveTfn[cActiveProcUnit.sObjectID]
      end

      return cActiveProcUnit
    end

    #=================================================================
    # 概  要: コード生成時に必要なオブジェクト情報をまとめて返す
    #=================================================================
    def get_proc_unit_info(cFristObject = nil, cSecondObject = nil)
      check_class(ProcessUnit, cFristObject, true)
      check_class(ProcessUnit, cSecondObject, true)

      hProcUnitInfo = {}

      if (!cFristObject.nil?())
        cObjectTemp = cFristObject
      elsif (!cSecondObject.nil?())
        cObjectTemp = cSecondObject
      else
        return @hMainTaskInfo # [Hash] コード生成時に必要な処理単位情報
      end

      hProcUnitInfo.store(:id, cObjectTemp.sObjectID)
      hProcUnitInfo.store(:coreid, cObjectTemp.hState[TSR_PRM_COREID])
      hProcUnitInfo.store(:bootcnt, cObjectTemp.hState[TSR_PRM_BOOTCNT])

      return hProcUnitInfo # [Hash] コード生成時に必要な処理単位情報
    end

    #=================================================================
    # 概  要: 全オブジェクトのref処理をIMCodeElementクラスにまとめて返
    #         す
    #=================================================================
    def gc_obj_ref()
      cElement = IMCodeElement.new()

      # マルチコアでも変数，割込み状態以外は，マスタコアから参照を行う
      hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)

      # マルチコア かつ スタートアップ/シャットダウンフック実行中で，
      # マスタコアに実行状態の処理単位が存在しない場合は，他コアで
      # 実行中の処理単位から参照を行う
      if (@cConf.is_multi?() && (@lKernelState != :KERNELBOOT) && @cActivate.nil?())
        # 実行中の処理単位が存在するどこか1つのコアを使用する
        @aCoreid.each{|nCoreid|
          if (!@aActivateProcUnit[nCoreid].nil?() && (nCoreid != @nMasterCoreid))
            hProcUnitInfo = get_proc_unit_info(@aActivateProcUnit[nCoreid])
            break
          end
        }
      end

      # 信頼関数が起動している処理単位への対応
      cActivateTfn = nil
      if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
        cActivateTfn = @hActiveTfn[hProcUnitInfo[:id]]
        hProcUnitInfo = get_proc_unit_info(cActivateTfn)
      end

      # コメント出力
      if (@nSeqNum.nil?())
        cElement.set_comment(hProcUnitInfo, "#{TSR_LBL_PRE}")
      else
        cElement.set_comment(hProcUnitInfo, "#{TSR_UNS_POST}#{@nSeqNum}")
      end

      # 実行中の処理単位に値が指定された変数があれば，一致していることを確認するコードを入れる
      if (@cConf.is_single?())
        if (!cActivateTfn.nil?() && !cActivateTfn.hState[TSR_PRM_VAR].nil?())
          cActivateTfn.gc_assert_value(cElement, hProcUnitInfo)
        elsif (!@cActivate.nil?() && !@cActivate.hState[TSR_PRM_VAR].nil?())
          @cActivate.gc_assert_value(cElement, hProcUnitInfo)
        elsif (@cActivate.nil?() && !@cRunning.nil?() && !@cRunning.hState[TSR_PRM_VAR].nil?())
          @cRunning.gc_assert_value(cElement, hProcUnitInfo)
        end
      else
        # 各コアで実行状態の処理単位から確認を行う
        @aCoreid.each{|nCoreid|
          if (!@aActivateProcUnit[nCoreid].nil?() && !@aActivateProcUnit[nCoreid].hState[TSR_PRM_VAR].nil?())
            hEachCoreProcUnitInfo = get_proc_unit_info(@aActivateProcUnit[nCoreid])
            @aActivateProcUnit[nCoreid].gc_assert_value(cElement, hEachCoreProcUnitInfo)
          end
        }
      end

      # 終了/再起動中のOSAPIDを取得
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        @hAllObject.each{|sObjectID, cObjectInfo|
         if (cObjectInfo.sObjectType == TSR_OBJ_OSAP)
           if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RESTARTING || cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_TERMINATED)
             @aTerminateOsap.push(cObjectInfo.sObjectID)
             @aTerminateOsap = @aTerminateOsap.uniq()
           elsif (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACCESSIBLE && @aTerminateOsap.include?(cObjectInfo.sObjectID))
             @aTerminateOsap.delete(cObjectInfo.sObjectID)
           end
         end
        }
      end

      # 全オブジェクトのref_codeをまとめる
      @hAllObject.each{|sObjectID, cObjectInfo|
        # タスクの場合，内部リソースIDリストが必要
        # スタートアップフック，シャットダウンフックが起動している場合に備え，lKernelStateも渡す
        if (cObjectInfo.sObjectType == TSR_OBJ_TASK || cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
          if (@cConf.is_single?())
            cObjectInfo.gc_obj_ref(cElement, hProcUnitInfo, @aInternalResID, @lKernelState, @aTerminateOsap)
          else
            cObjectInfo.gc_obj_ref(cElement, hProcUnitInfo, @aInternalResIDEachCore[cObjectInfo.hState[TSR_PRM_COREID]], @lKernelState, @aTerminateOsap)
          end
        # IOCの場合，センダ・レシーバ・IOC通信データの情報が必要
        elsif (cObjectInfo.sObjectType == TSR_OBJ_IOC)
          # センダ
          aSenderId = cObjectInfo.hState[TSR_PRM_SENDER]
          aSenderObject = Array.new()
          aSenderId.each{|sSenderId|
            aSenderObject.push(get_object_info(sSenderId))
          }
          # レシーバ
          sReceiverId = cObjectInfo.hState[TSR_PRM_RECEIVER]
          cReceiverObject = get_object_info(sReceiverId)
          # IOC通信データ
          aIocDataId = cObjectInfo.hState[TSR_PRM_IOCDATA]
          aIocDataObject = Array.new()
          aIocDataId.each{|sIocDataId|
            aIocDataObject.push(get_object_info(sIocDataId))
          }
          cObjectInfo.gc_obj_ref(cElement, hProcUnitInfo, aSenderObject, cReceiverObject, aIocDataObject)
        # マルチコアにおいて，割込み禁止状態もしくはC1/C2ISRの場合，各コアの実行状態の処理単位から参照する
        elsif (@cConf.is_multi?() && ((cObjectInfo.sObjectType == TSR_OBJ_INT_STATE) || GRP_PROCESS_UNIT_ISR.include?(cObjectInfo.sObjectType)))
          # 対象のコアIDを取得
          nTargetCoreid = cObjectInfo.hState[TSR_PRM_COREID]
          # 割込み禁止状態を指定したコアには実行状態の処理単位が必須であるので，
          # この処理単位から確認処理を行う
          hEachCoreProcUnitInfo = get_proc_unit_info(@aActivateProcUnit[nTargetCoreid])
          cObjectInfo.gc_obj_ref(cElement, hEachCoreProcUnitInfo)
        # 状態を参照できないオブジェクトの場合，何もしない
        elsif (!GRP_NO_VERIFY_OBJECT.include?(cObjectInfo.sObjectType))
          cObjectInfo.gc_obj_ref(cElement, hProcUnitInfo)
        end
      }

      cElement.set_checkpoint(hProcUnitInfo)

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: 指定したタイプの全オブジェクトの情報を返す
    #=================================================================
    def get_all_object_info(sObjectType)
      check_class(String, sObjectType) # 対象とするオブジェクトタイプ

      hObjectInfo = {}
      # 該当するオブジェクトの情報を格納する
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.sObjectType == sObjectType)
          hObjectInfo[sObjectID] = cObjectInfo
        end
      }

      return hObjectInfo # [Hash]オブジェクト情報ハッシュ
    end

    #=================================================================
    # 概  要: ACTIVATEである指定した処理単位のIDを返す
    #=================================================================
    def get_activate_proc_unit_id(sObjectType)
      check_class(String, sObjectType) # 対象とするオブジェクトタイプ

      aProcUnitID = Array.new()

      # ACTIVATEである処理単位の情報を格納する
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == sObjectType) &&
            (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
          aProcUnitID.push(sObjectID)
        end
      }

      return aProcUnitID # [Array]ACTIVATEである処理単位ID配列
    end

    #=================================================================
    # 概  要: BarrierSyncを行うコードを返す
    #=================================================================
    def gc_barrier_sync(sSyncComment)
      check_class(String, sSyncComment)  # マルチコアにおける同期用コメント

      cElement      = IMCodeElement.new()
      aProcUnitInfo = []

      @aCoreid.each{|nCoreid|
        if (@lKernelState == :KERNELBOOT)
          # カーネル起動中はマスタコアにはメインタスクが存在する
          if ((nCoreid == @nMasterCoreid) && @aActivateProcUnit[nCoreid].nil?())
            aProcUnitInfo.push(get_proc_unit_info())
          elsif (!@aActivateProcUnit[nCoreid].nil?())
            aProcUnitInfo.push(get_proc_unit_info(@aActivateProcUnit[nCoreid]))
          end
        else
          # カーネル起動前，終了後で，実行状態の処理単位がいればバリア同期を行う
          # (カーネル終了後にタスクがRUNNINGとなっている場合に備えて除外する)
          if (!@aActivateProcUnit[nCoreid].nil?() && (@aActivateProcUnit[nCoreid].sObjectType != TSR_OBJ_TASK))
            aProcUnitInfo.push(get_proc_unit_info(@aActivateProcUnit[nCoreid]))
          end
        end
      }

      if (aProcUnitInfo.size() > 1)
        cElement.set_barrier_sync(aProcUnitInfo, sSyncComment)
      end

      return cElement  # [IMCodeElement]BarrierSyncを行うコード
    end
  end
end
