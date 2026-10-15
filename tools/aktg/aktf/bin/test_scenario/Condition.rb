#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
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
require "aktf/bin/class/AKTFCommon.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Condition
  # 概    要: pre_condition, post_conditionの情報を処理するクラス
  #===================================================================
  class Condition
    include AKTFModule

    #=================================================================
    # 概  要: オブジェクトの共通基礎チェック
    #=================================================================
    def common_basic_check(sObjectID, hObjectInfo, aPath)
      check_class(String, sObjectID, true)   # オブジェクトID
      check_class(Object, hObjectInfo, true) # コンディション(T1_015でチェックを行う)
      check_class(Array, aPath)              # ルートからのパス

      aErrors = []
      ### T1_014: オブジェクトIDの文字列が不正
      if (sObjectID !~ TSR_REX_OBJECT_ID)
        sErr = sprintf("T1_014: " + ERR_INVALID_OBJECTID, sObjectID)
        aErrors.push(YamlError.new(sErr, aPath))
      ### T1_028: オブジェクトIDに予約語(※)が使用されている
      elsif (!hObjectInfo.has_key?(TSR_PRM_OSAPSTAT) && (GRP_OSAP_ALL_AVAILABLE_SC3 + GRP_OSAP_SC1MC).include?(sObjectID))
        sErr = sprintf("T1_028: " + ERR_USE_RESERVED_WORD_OBJECTID, sObjectID)
        aErrors.push(YamlError.new(sErr, aPath))
      end
      ### T1_015: オブジェクトがHashではない
      if (!hObjectInfo.is_a?(Hash))
        sErr = sprintf("T1_015: " + ERR_INVALID_TYPE, sObjectID, Hash, hObjectInfo.class())
        aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []
      @hAllObject.each{|sObjectID, cObjectInfo|
        begin
          cObjectInfo.attribute_check()
        rescue AKTFMultiError
          aErrors.concat($!.aErrors)
        end
      }
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre = false)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []
      @hAllObject.each{|sObjectID, cObjectInfo|
        begin
          cObjectInfo.object_check(bIsPre)
        rescue AKTFMultiError
          aErrors.concat($!.aErrors)
        end
      }
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: コンディションチェック
    #=================================================================
    def condition_check(bCannotMerge)
      check_class(Bool, bCannotMerge) # マージしないテストケースかどうか

      aErrors = []
      aPath = get_condition_path()

      # 処理単位のチェック準備
      hActivate = {}
      aCoreid = get_all_coreid()
      aCoreid.each{|nCoreid|
        hActivate[nCoreid] = {
          :nTaskRun          => 0, # 実行中のタスクの数
          :nAlarmcb          => 0, # 実行中のアラームコールバックの数
          :nC1isr            => 0, # 実行中のC1ISRの数
          :nC2isr            => 0, # 実行中のC2ISRの数
          :nStartupHook      => 0, # 実行中のシステム定義のスタートアップフックの数
          :nShutdownHook     => 0, # 実行中のシステム定義のシャットダウンフックの数
          :nPretaskHook      => 0, # 実行中のシステム定義のプレタスクフックの数
          :nPosttaskHook     => 0, # 実行中のシステム定義のポストタスクフックの数
          :nErrorHook        => 0, # 実行中のシステム定義のエラーフックの数
          :nProtectionHook   => 0, # 実行中のシステム定義のプロテクションフックの数
          :nStartupHookOsap  => 0, # 実行中のOSAP固有のスタートアップフックの数
          :nShutdownHookOsap => 0, # 実行中のOSAP固有のシャットダウンフックの数
          :nErrorHookOsap    => 0, # 実行中のOSAP固有のエラーフックの数
          :nTrustedFunction  => 0, # 実行中の信頼関数の数
          :nRestartTask      => 0  # 実行中のリスタートタスクの数
        }
      }
      hReadyQueue = Hash.new{|hash, key|
        hash[key] = {:cRunning => nil, :aReady => []}
      }

      hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
      hObjects.each{|sObjectID, cObjectInfo|
        # コアID取得
        nCoreid = get_process_coreid(cObjectInfo)
        # 起動中の処理単位
        if (cObjectInfo.is_activate?())
          # 起動中の処理単位の判別
          if (cObjectInfo.sObjectType == TSR_OBJ_TASK)
            hActivate[nCoreid][:nTaskRun] += 1
            hReadyQueue[nCoreid][:cRunning] = cObjectInfo
          elsif (cObjectInfo.sObjectType == TSR_OBJ_C1ISR)
            hActivate[nCoreid][:nC1isr] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_C2ISR)
            hActivate[nCoreid][:nC2isr] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_ALARM_CALL_BACK)
            hActivate[nCoreid][:nAlarmcb] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK)
            hActivate[nCoreid][:nStartupHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK)
            hActivate[nCoreid][:nShutdownHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_PRETASK_HOOK)
            hActivate[nCoreid][:nPretaskHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_POSTTASK_HOOK)
            hActivate[nCoreid][:nPosttaskHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK)
            hActivate[nCoreid][:nErrorHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_PROTECTION_HOOK)
            hActivate[nCoreid][:nProtectionHook] += 1
          elsif (cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
            hActivate[nCoreid][:nRestartTask] += 1
          elsif (@cConf.enable_osap?())
            if (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP)
              hActivate[nCoreid][:nStartupHookOsap] += 1
            elsif (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)
              hActivate[nCoreid][:nShutdownHookOsap] += 1
            elsif (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK_OSAP)
              hActivate[nCoreid][:nErrorHookOsap] += 1
            end
          end
        end
        # 実行可能状態のタスクのピックアップ
        if (cObjectInfo.sObjectType == TSR_OBJ_TASK && cObjectInfo.is_ready?())
          hReadyQueue[nCoreid][:aReady].push(cObjectInfo)
        end
      }

      # 処理単位
      aGetres = []
      aGetspn = []
      aPorder = []
      aProcUnit = []
      hReadyAndGetresTask = Hash.new{|hash, key|
        hash[key] = {}
      }
      hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
      hTrustedFunctioin = get_objects_by_type(TSR_OBJ_TRUSTED_FUNCTION)
      hObjects.each{|sObjectID, cObjectInfo|
        # INT_STATEチェック準備
        aProcUnit.push(sObjectID)
        if ((cObjectInfo.sObjectType != TSR_OBJ_TASK) && (cObjectInfo.sObjectType != TSR_OBJ_RESTART_TASK) && (cObjectInfo.sObjectType != TSR_OBJ_C2ISR) &&
            (cObjectInfo.sObjectType != TSR_OBJ_TRUSTED_FUNCTION) && (cObjectInfo.sObjectType != TSR_OBJ_ICISR) &&
            (cObjectInfo.sObjectType != TSR_OBJ_PROTECTION_HOOK))
          next
        end
        # タスク
        if (cObjectInfo.sObjectType == TSR_OBJ_TASK)
          if (!cObjectInfo.hState[TSR_PRM_CURPRI].nil?() && cObjectInfo.hState[TSR_PRM_INIPRI] != cObjectInfo.hState[TSR_PRM_CURPRI])
            # getresの有無をチェック
            bGetresFlg = false
            if (!cObjectInfo.hState[TSR_PRM_GETRES].nil?())
              bGetresFlg = true
            elsif (!hTrustedFunctioin.empty?())
              # 信頼関数経由でリソースを獲得している場合もチェックする
              hTrustedFunctioin.each{|sTfnID, cTfnInfo|
                if ((cTfnInfo.hState[TSR_PRM_CALLER] == sObjectID) && (!cTfnInfo.hState[TSR_PRM_GETRES].nil?))
                  bGetresFlg = true
                end
              }
            end
            ### T4_078: タスクのinipriとcurpriが異なる場合に，タスクかタスクが呼出した信頼関数のgetresにリソースが指定されていない
            if (bGetresFlg == false)
              aErrors.push(YamlError.new("T4_078: " + ERR_TASK_NOT_SET_GETRES,  aPath + [sObjectID, TSR_PRM_GETRES]))
            end
          end
          # タスクが待ち状態の場合のチェック
          if (cObjectInfo.is_waiting?())
            bWaievtFlg = false
            if (!cObjectInfo.hState[TSR_PRM_WAIEVT].nil?())
              bWaievtFlg = true
            elsif (!hTrustedFunctioin.empty?())
              # 信頼関数経由でイベント待ち状態の場合もチェックする
              hTrustedFunctioin.each{|sTfnID, cTfnInfo|
                if ((cTfnInfo.hState[TSR_PRM_CALLER] == sObjectID) && (!cTfnInfo.hState[TSR_PRM_WAIEVT].nil?))
                  bWaievtFlg = true
                end
              }
            end
            ### T4_080: タスクがWAITINGの場合に，タスクかタスクが呼出した信頼関数のwaievtにイベントが指定されていない
            if (bWaievtFlg == false)
              aErrors.push(YamlError.new("T4_080: " + ERR_NO_WAIEVT_WAITING,  aPath + [sObjectID, TSR_PRM_GETRES]))
            end
          end
          # タスクが実行可能状態の場合のチェック
          if (cObjectInfo.is_ready?())
            # porderチェック準備
            nCoreid = get_process_coreid(cObjectInfo)
            nPri = cObjectInfo.hState[TSR_PRM_CURPRI]
            if (!cObjectInfo.hState[TSR_PRM_PORDER].nil?())
              nPorder = cObjectInfo.hState[TSR_PRM_PORDER]
              if (aPorder[nCoreid].nil?())
                aPorder[nCoreid] = []
              end
              if (aPorder[nCoreid][nPri].nil?())
                aPorder[nCoreid][nPri] = []
              end
              if (aPorder[nCoreid][nPri][nPorder].nil?())
                aPorder[nCoreid][nPri][nPorder] = []
              end
              aPorder[nCoreid][nPri][nPorder].push(sObjectID)
            end
          end
          ### T4_090: スタートアップフックが実行状態の場合に，タスクのtstatがREASY，SUSPENDED以外を指定している
          if ((@lKernelState == :STARTUPHOOK || @lKernelState == :STARTUPHOOK_OSAP) &&
              (cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_READY && cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_SUSPENDED))
            aErrors.push(YamlError.new("T4_090: " + ERR_STARTUPHOOK_TSTAT,  aPath))
          end
        end
        # C2ISR
        if (cObjectInfo.sObjectType == TSR_OBJ_C2ISR)
          # getresの有無をチェック
          if (cObjectInfo.hState[TSR_PRM_INIINTPRI] != cObjectInfo.hState[TSR_PRM_CURINTPRI])
            bGetresFlg = false
            if (!cObjectInfo.hState[TSR_PRM_GETRES].nil?)
              bGetresFlg = true
            elsif (!hTrustedFunctioin.empty?())
              # 信頼関数経由でリソースを獲得している場合もチェックする
              hTrustedFunctioin.each{|sTfnID, cTfnInfo|
                if ((cTfnInfo.hState[TSR_PRM_CALLER] == sObjectID) && (!cTfnInfo.hState[TSR_PRM_GETRES].nil?))
                  bGetresFlg = true
                end
              }
            end
            ### T4_079: C2ISRのiniintpriとcurintpriが異なる場合に，C2ISRかC2ISRが呼出した信頼関数のgetresにリソースが指定されていない
            if (bGetresFlg == false)
              aErrors.push(YamlError.new("T4_079: " + ERR_C2ISR_NOT_SET_GETRES,  aPath + [sObjectID, TSR_PRM_GETRES]))
            end
          end
        end
        # getresに関連するチェック
        if (cObjectInfo.has_getres?())
          cObjectInfo.hState[TSR_PRM_GETRES].each{|sGetres|
            cResourceInfo = @hAllObject[sGetres]
            ### T4_017: タスクとC2ISR，信頼関数のgetresで指定されたリソースが存在しない
            if (cResourceInfo.nil?())
              sErr = sprintf("T4_017: " + ERR_NO_TARGET_OBJECT, sGetres)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETRES]))
            ### T4_018: タスクとC2ISR，信頼関数のgetresで指定されたリソースが，リソースでない
            elsif (cResourceInfo.sObjectType != TSR_OBJ_RESOURCE)
              sErr = sprintf("T4_018: " + ERR_NOT_RESOURCE, sGetres)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETRES]))
            # タスク
            elsif (cObjectInfo.sObjectType == TSR_OBJ_TASK)
              if (cObjectInfo.is_activate?())
                ### T4_020: 実行状態のタスクのrelresに内部リソースが指定されている場合に，getresの先頭リソースが内部リソースでない
                if (cResourceInfo.is_internal_resource?() && cObjectInfo.hState[TSR_PRM_GETRES][0] != sGetres)
                  sErr = sprintf("T4_020: " + ERR_HEAD_NOT_INTERNAL_RES, sGetres)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETRES]))
                end
              elsif (cObjectInfo.is_ready?())
                ### T4_021: 実行可能状態のタスクのrelresに内部リソースが指定されていて，getresが指定されている場合に，getresの先頭リソースが内部リソースでない
                if (cResourceInfo.is_internal_resource?() && cObjectInfo.hState[TSR_PRM_GETRES][0] != sGetres)
                  sErr = sprintf("T4_021: " + ERR_HEAD_NOT_INTERNAL_RES, sGetres)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETRES]))
                end
              end
            end
            aGetres.push(sGetres)
          }
          # 実行可能状態のタスクがリソース獲得している場合のチェック準備
          if (cObjectInfo.sObjectType == TSR_OBJ_TASK && cObjectInfo.is_ready?())
            hReadyAndGetresTask[cObjectInfo.hState[TSR_PRM_COREID]][cObjectInfo.sObjectID] = cObjectInfo.hState[TSR_PRM_CURPRI]
          end
        end
        if (@cConf.is_multi?())
          # getspnチェック
          if (cObjectInfo.has_getspn?())
            cObjectInfo.hState[TSR_PRM_GETSPN].each{|sGetspn|
              cSpinlockInfo = @hAllObject[sGetspn]
              ### T4_MC_011: タスクとC2ISRとICISR，getspnで指定されたスピンロックが存在しない
              if (cSpinlockInfo.nil?())
                sErr = sprintf("T4_MC_011: " + ERR_NO_TARGET_OBJECT, sGetspn)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETSPN]))
              ### T4_MC_012: タスクとC2ISRとICISR，getspnで指定されたスピンロックが，スピンロックでない
              elsif (cSpinlockInfo.sObjectType != TSR_OBJ_SPINLOCK)
                sErr = sprintf("T4_MC_012: " + ERR_NOT_SPINLOCK, sGetspn)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETSPN]))
              end
              aGetspn.push(sGetspn)
            }
          end
        end
      }

      # porderチェック
      aPorder.each_with_index{|aPriByCoreid, nCoreid|
        if (!aPriByCoreid.nil?())
          aPriByCoreid.each_with_index{|aPri, nPri|
            if (!aPri.nil?())
              bCheckFlag = false
              aPri.each_with_index{|aTasks, nPorder|
                ### T4_008: 同一優先度内でporderが連番でない
                if (aTasks.nil?())
                  if (bCheckFlag == true && nPorder != 0)
                    sErr = sprintf("T4_008: " + ERR_PORDER_NOT_SEQUENCE, nPri, nCoreid)
                    aErrors.push(YamlError.new(sErr, aPath))
                  end
                ### T4_009: 同一優先度内でporderがユニークでない
                else
                  bCheckFlag = true
                  if (aTasks.size() > 1)
                    sErr = sprintf("T4_009: " + ERR_PORDER_NOT_UNIQUE, aTasks.join(", "))
                    aErrors.push(YamlError.new(sErr, aPath))
                  end
                end
              }
            end
          }
        end
      }

      # リソースチェック
      ### T4_023: タスクとC2ISR，信頼関数のgetresに指定されたリソースが重複している
      if (aGetres.size != aGetres.uniq.size)
        aErrors.push(YamlError.new("T4_023: " + ERR_DUPLICATE_GETRES, aPath))
      end
      hObjects = get_objects_by_type(TSR_OBJ_RESOURCE)
      hObjects.each{|sObjectID, cObjectInfo|
        ### T4_024: タスクとC2ISR，信頼関数のgetresで指定されたリソースのlockflgが獲得中でない
        if (cObjectInfo.hState[TSR_PRM_LOCKFLG] == TSR_STT_UNLOCK && aGetres.include?(sObjectID))
          sErr = sprintf("T4_024: " + ERR_LOCKFLG_NOT_UNLOCK, sObjectID)
          aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_LOCKFLG]))
        ### T4_025: タスクとC2ISR，信頼関数のgetresにリソースは指定されていないが，lockflgが獲得中である
        elsif (cObjectInfo.hState[TSR_PRM_LOCKFLG] == TSR_STT_LOCK && !aGetres.include?(sObjectID))
          sErr = sprintf("T4_025: " + ERR_LOCKFLG_NOT_LOCK, sObjectID)
          aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_LOCKFLG]))
        end
      }

      # INT_STATEのチェック準備
      aIntState = []
      hObjects = get_objects_by_type(TSR_OBJ_INT_STATE)
      hObjects.each_value{|cObjectInfo|
        nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
        aIntState[nCoreid] = cObjectInfo
      }

      # 起動中の処理単位チェック
      hActivate.each_key{|nCoreid|
        ### T4_005: 同一コンディション内で実行状態のタスクが複数存在する
        if (hActivate[nCoreid][:nTaskRun] > 1)
          sErr = sprintf("T4_005: " + ERR_PLURAL_RUNNING_TASK, nCoreid)
          aErrors.push(YamlError.new(sErr, aPath))
        elsif (hActivate[nCoreid][:nTaskRun] == 1)
          ### T4_054: 実行可能のタスクがノンプリエンプティブスケジューリングである場合に，実行状態のタスクより優先度の高い実行可能状態のタスクがリソース獲得中である
          if (hReadyAndGetresTask.has_key?(nCoreid) && !hReadyQueue[nCoreid][:cRunning].is_schfull?())
            hReadyAndGetresTask[nCoreid].each{|sTaskID, nPri|
              if (nPri > hReadyQueue[nCoreid][:cRunning].hState[TSR_PRM_CURPRI])
                aErrors.push(YamlError.new("T4_054: " + ERR_HIGHER_READY_TASK_GETRES, aPath))
                break
              end
            }
          end
          ### T4_057: ノンプリエンプティブスケジューリングのタスクのシステム定義のプレタスクフックが実行状態で，そのタスクの優先度以上の実行可能状態のタスクが存在している
          if (hActivate[nCoreid][:nPretaskHook] == 1 && !hReadyQueue[nCoreid][:cRunning].is_schfull?() && !hReadyQueue[nCoreid][:aReady] != [])
            hReadyQueue[nCoreid][:aReady].each{|cTask|
              if (cTask.hState[TSR_PRM_CURPRI] >= hReadyQueue[nCoreid][:cRunning].hState[TSR_PRM_CURPRI])
                aErrors.push(YamlError.new("T4_057: " + ERR_HIGHER_READY_TASK_CANT_READY, aPath + [cTask.sObjectID]))
                break
              end
            }
          end
        end
        ### T4_006: 同一コンディション内でタスク以外の実行状態の処理単位が複数存在する
        if ((hActivate[nCoreid][:nC1isr] + hActivate[nCoreid][:nC2isr] + hActivate[nCoreid][:nAlarmcb] +
             hActivate[nCoreid][:nStartupHook] + hActivate[nCoreid][:nShutdownHook] + hActivate[nCoreid][:nPretaskHook] +
             hActivate[nCoreid][:nPosttaskHook] + hActivate[nCoreid][:nErrorHook] + hActivate[nCoreid][:nProtectionHook] +
             hActivate[nCoreid][:nStartupHookOsap] + hActivate[nCoreid][:nShutdownHookOsap] + hActivate[nCoreid][:nErrorHookOsap])  > 1)
          sErr = sprintf("T4_006: " + ERR_PLURAL_ACTIVATE_NON_CONTEXT, nCoreid)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        if (hActivate[nCoreid][:nTaskRun] == 0)
          ### T4_034: 実行状態のシステム定義のプレタスクフックが存在するコンディションに，実行状態のタスクが存在しない
          if (hActivate[nCoreid][:nPretaskHook] == 1)
            sErr = sprintf("T4_034: " + ERR_NO_RUNTASK_WITH, TSR_OBJ_PRETASK_HOOK, nCoreid)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_035: 実行状態のシステム定義のポストタスクフックが存在するコンディションに，実行状態のタスクが存在しない
          if (hActivate[nCoreid][:nPosttaskHook] == 1)
            sErr = sprintf("T4_035: " + ERR_NO_RUNTASK_WITH, TSR_OBJ_POSTTASK_HOOK, nCoreid)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        end

        # INT_STATEが関連するチェック
        if (!aIntState[nCoreid].nil?())
          ### T4_007: 実行状態の処理単位が存在しない状態で割込みが禁止されている状態(INT_STATEのistatに，AK_DIS_ALL_INT，AK_SUS_ALL_INT，AK_SUS_OS_INT)を指定している
          aValues = hActivate[nCoreid].values()
          if (aValues.max() == 0 && aIntState[nCoreid].is_state_changed?())
            sErr = sprintf("T4_007: " + ERR_CANNNOT_REF_INT_STATE, nCoreid)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          aIntState[nCoreid].hState[TSR_PRM_INT_STATE].each{|hIntState|
            sObjectID = hIntState.values()[0]
            ### T4_048: 割込み禁止状態のistatのシステムサービスを発行したオブジェクトが存在しない
            if (!@hAllObject.has_key?(sObjectID))
              sErr = sprintf("T4_048: " + ERR_NO_TARGET_OBJECT, sObjectID)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_INT_STATE]))
            ### T4_049: 割込み禁止状態のistatのシステムサービスを発行したオブジェクトが，処理単位でない
            elsif (!aProcUnit.include?(sObjectID) && @hAllObject[sObjectID].sObjectType != TSR_OBJ_SPINLOCK)
              sErr = sprintf("T4_049: " + ERR_NOT_PROCESS_UNIT, sObjectID)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_INT_STATE]))
            end
            if (@cConf.is_multi?())
              ### T4_MC_016: 割込み禁止状態がAK_DIS_ALL_INTの場合，istatのシステムサービスを発行したオブジェクトがスピンロックである
              if (hIntState.keys()[0] == TSR_STT_DIS_ALL_INT && @hAllObject[sObjectID].sObjectType == TSR_OBJ_SPINLOCK)
                sErr = sprintf("T4_MC_016: " + ERR_DIS_ALL_INT_SPINLOCK)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_INT_STATE]))
              end
            end
          }
        end
      }

      # 内部リソースチェック
      hShareInternalRes = {}
      aCoreid.each{|nCoreid|
        hShareInternalRes[nCoreid] = get_shared_internal_resource(nCoreid)
      }
      hShareInternalRes.each{|nCoreid, hResource|
        if (hResource != {})
          hResource.each{|sResourceID, aTask|
            aTask.each{|sRunTask|
              if (@hAllObject[sRunTask].is_activate?())
                aTask.each{|sTaskID|
                  cTask = @hAllObject[sTaskID]
                  if (cTask.is_activate?())
                    ### T4_058: 実行状態のタスクのrelresに内部リソースが指定されている場合に，getresが指定されていない
                    if (!cTask.has_getres?())
                      aErrors.push(YamlError.new("T4_058: " + ERR_NEED_GETRES, aPath + [sTaskID]))
                    end
                  elsif (cTask.is_ready?())
                    ### T4_055: 実行状態のタスクと同じ内部リソースを共有しているタスクが，実行可能状態であり，かつシステム定義のプレタスクフックが実行状態である
                    if (hActivate[nCoreid][:nPretaskHook] == 1)
                      aErrors.push(YamlError.new("T4_055: " + ERR_PRETASKHOOK_CANT_ACT, aPath))
                    ### T4_056: 実行状態のタスクと同じ内部リソースを共有しているタスクが，実行可能状態であり，かつリソース獲得中である
                    elsif (cTask.has_getres?())
                      aErrors.push(YamlError.new("T4_056: " + ERR_CANT_GETRES, aPath + [sTaskID]))
                    end
                  end
                }
              end
            }
          }
        end
      }

      # アラームのチェック
      hObjects = get_objects_by_type(TSR_OBJ_ALARM)
      hObjects.each{|sObjectID, cObjectInfo|
        nMaxval = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]].hState[TSR_PRM_MAXVAL]
        nMincyc = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]].hState[TSR_PRM_MINCYC]
        nAlmval = cObjectInfo.hState[TSR_PRM_ALMVAL]
        nCycle = cObjectInfo.hState[TSR_PRM_CYCLE]
        ### T4_050: アラームのalmvalが，0以上，かつ，対象カウンタのmaxval以下でない
        if (!nAlmval.nil?() && !(nAlmval >= 0 && nAlmval <= nMaxval))
          sErr = sprintf("T4_050: " + ERR_ALMVAL_INVALID, nAlmval)
          aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_ALMVAL]))
        end
        ### T4_051: アラームのcycleが，0，もしくは，対象カウンタのmincyc以上，maxval以下でない
        if (!nCycle.nil?() && !(nCycle == 0 || (nCycle >= nMincyc && nCycle <= nMaxval)))
          sErr = sprintf("T4_051: " + ERR_CYCLE_INVALID, nCycle)
          aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CYCLE]))
        end
      }

      # スケジュールテーブルのチェック
      hObjects = get_objects_by_type(TSR_OBJ_SCHEDULE_TABLE)
      hObjects.each{|sObjectID, cObjectInfo|
        cSchtblInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_STFROM]]
        if (!cObjectInfo.hState[TSR_PRM_STFROM].nil?())
          ### T4_073: スケジュールテーブルのstfromに指定されたオブジェクトが存在しない
          if (cSchtblInfo.nil?())
            sErr = sprintf("T4_073: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_STFROM])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_STFROM]))
          ### T4_074: スケジュールテーブルのstfromに指定されたオブジェクトがスケジュールテーブルでない
          elsif (cSchtblInfo.sObjectType != TSR_OBJ_SCHEDULE_TABLE)
            sErr = sprintf("T4_074: " + ERR_NOT_SCHEDULE_TABLE, cObjectInfo.hState[TSR_PRM_STFROM])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_STFROM]))
          ### T4_075: スケジュールテーブルのstfromに指定されたスケジュールテーブルの状態が，動作状態か同期動作状態でない
          elsif (cSchtblInfo.hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_RUNNING && cSchtblInfo.hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_RUN_AND_SYNC)
            sErr = sprintf("T4_075: " + ERR_NOT_RUN_OR_RUN_AND_SYNC, cObjectInfo.hState[TSR_PRM_STFROM])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_STFROM]))
          end
        end
      }

      # 信頼関数のチェック
      hObjects = get_objects_by_type(TSR_OBJ_TRUSTED_FUNCTION)
      hObjects.each{|sObjectID, cObjectInfo|
        if (!cObjectInfo.hState[TSR_PRM_CALLER].nil?)
          cProcUnitInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_CALLER]]
          ### T4_SC3_001: 信頼関数のcallerに指定された処理単位が存在しない
          if (cProcUnitInfo.nil?)
            sErr = sprintf("T4_SC3_001: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_CALLER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLER]))
          ### T4_SC3_002: 信頼関数のcallerに指定された処理単位が，タスクかC2ISRでない
          elsif ((cProcUnitInfo.sObjectType != TSR_OBJ_TASK) && (cProcUnitInfo.sObjectType != TSR_OBJ_C2ISR) && (cProcUnitInfo.sObjectType != TSR_OBJ_ICISR))
            sErr = sprintf("T4_SC3_002: " + ERR_NOT_TASK_OR_C2ISR, cObjectInfo.hState[TSR_PRM_CALLER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLER]))
          elsif (cProcUnitInfo.sObjectType == TSR_OBJ_TASK)
            if (cProcUnitInfo.is_activate?())
              hActivate.each_key{|nCoreid|
                ### T4_SC3_005: 信頼関数のcallerにタスクを指定している場合，プレタスクフックが実行状態である
                if (cObjectInfo.hState[TSR_PRM_COREID] == nCoreid) && (hActivate[nCoreid][:nPretaskHook] > 0)
                  aErrors.push(YamlError.new("T4_SC3_005: " + ERR_TFN_AND_PRE_HOOK_ACTIVATE, aPath))
                end
              }
            elsif (cProcUnitInfo.is_waiting?())
              ### T4_SC3_004: タスクとタスクが呼出した信頼関数に，waievtが指定されている
              if ((!cProcUnitInfo.hState[TSR_PRM_WAIEVT].nil?()) && (!cObjectInfo.hState[TSR_PRM_WAIEVT].nil?()))
                aErrors.push(YamlError.new("T4_SC3_004: " + ERR_TASK_TFN_SET_WAIEVT, aPath))
              end
              ### T4_SC3_007: 信頼関数のwaievtが指定されている場合に，callerに指定されたタスクが拡張タスクでない
              if (cProcUnitInfo.is_basic?())
                sErr = sprintf("T4_SC3_007: " + ERR_NOT_EXTENDED_TASK, cProcUnitInfo.sObjectID)
                aErrors.push(YamlError.new(sErr, aPath + [cProcUnitInfo.sObjectID]))
              end

            end
          elsif (cProcUnitInfo.sObjectType == TSR_OBJ_C2ISR || cProcUnitInfo.sObjectType == TSR_OBJ_ICISR)
            ### T4_SC3_006: 信頼関数のwaievtが指定されている場合に，callerに指定された処理単位がC2ISRである
            if (!cObjectInfo.hState[TSR_PRM_WAIEVT].nil?())
              aErrors.push(YamlError.new("T4_SC3_006: " + ERR_C2ISR_SET_WAIEVT, aPath))
            end
          end
        end
      }

      # マルチコア限定
      if (@cConf.is_multi?())
        # スピンロックチェック
        ### T4_MC_013: タスクとC2ISRとICISR，getspnに指定されたスピンロックが重複している
        if (aGetspn.size != aGetspn.uniq.size)
          aErrors.push(YamlError.new("T4_MC_013: " + ERR_DUPLICATE_GETSPN, aPath))
        end
        hObjects = get_objects_by_type(TSR_OBJ_SPINLOCK)
        hObjects.each{|sObjectID, cObjectInfo|
          ### T4_MC_014: タスクとC2ISRとICISR，getspnで指定されたスピンロックのlockflgが獲得中でない
          if (!cObjectInfo.is_lock?() && aGetspn.include?(sObjectID))
            sErr = sprintf("T4_MC_014: " + ERR_LOCKFLG_NOT_UNLOCK, sObjectID)
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_LOCKFLG]))
          ### T4_MC_015: タスクとC2ISRとICISR，getspnにスピンロックは指定されていないが，lockflgが獲得中である
          elsif (cObjectInfo.is_lock?() && !aGetspn.include?(sObjectID))
            sErr = sprintf("T4_MC_015: " + ERR_LOCKFLG_NOT_LOCK, sObjectID)
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_LOCKFLG]))
          end
        }

        # スピンロック獲得が可能な処理単位
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_LOCK_SPINLOCK)
        hObjects.each{|sObjectID, cObjectInfo|
          # スピンロック待ち
          if (cObjectInfo.is_spinlock_waiting?())
            sSpnid = cObjectInfo.hState[TSR_PRM_SPNID]
            if (@hAllObject.has_key?(sSpnid))
              cSpinlock = @hAllObject[sSpnid]
              ### T4_MC_008: spnidに指定されたオブジェクトがスピンロックでない
              if (cSpinlock.sObjectType != TSR_OBJ_SPINLOCK)
                sErr = sprintf("T4_MC_008: " + ERR_TARGET_NOT_SPINLOCK, sSpnid)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SPNID]))
              end
            ### T4_MC_007: spnidに指定されたオブジェクトが存在しない
            else
              sErr = sprintf("T4_MC_007: " + ERR_TARGET_NOT_DEFINED, sSpnid)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SPNID]))
            end
          end
        }

        # IOCチェック
        hObjects = get_objects_by_type(TSR_OBJ_IOC)
        hObjects.each{|sObjectID, cObjectInfo|
          if (!cObjectInfo.hState[TSR_PRM_DATA].nil?)
            cObjectInfo.hState[TSR_PRM_DATA].each{|hData|
              hData.each_key{|sData|
                cDataInfo = @hAllObject[sData]
                ### T4_MC_023: IOCのdataに指定されたIOC通信データが存在しない
                if (cDataInfo.nil?())
                  sErr = sprintf("T4_MC_023: " + ERR_NO_TARGET_OBJECT, sData)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATA]))
                ### T4_MC_024: IOCのdataに指定されたオブジェクトが，IOC通信データではない
                elsif (cDataInfo.sObjectType != TSR_OBJ_IOC_DATA)
                  sErr = sprintf("T4_MC_024: " + ERR_NOT_IOC_DATA, sData)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATA]))
                end
              }
            }
          end
          if (!cObjectInfo.hState[TSR_PRM_DATALIST].nil?)
            cObjectInfo.hState[TSR_PRM_DATALIST].each{|aDataList|
              aDataList.each{|hDatalist|
                hDatalist.each_key{|sDatalist|
                  cDatalistInfo = @hAllObject[sDatalist]
                  ### T4_MC_025: IOCのdatalistに指定されたIOC通信データが存在しない
                  if (cDatalistInfo.nil?())
                    sErr = sprintf("T4_MC_025: " + ERR_NO_TARGET_OBJECT, sDatalist)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATALIST]))
                  ### T4_MC_026: IOCのdatalistに指定されたオブジェクトが，IOC通信データではない
                  elsif (cDatalistInfo.sObjectType != TSR_OBJ_IOC_DATA)
                    sErr = sprintf("T4_MC_026: " + ERR_NOT_IOC_DATA, sDatalist)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATALIST]))
                  end
                }
              }
            }
          end
        }
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 処理単位のコアIDを返す
    #=================================================================
    def get_process_coreid(cObjectInfo)
      check_class(Object, cObjectInfo, true)  # ProcessUnit(T5_004でチェックを行う)

      nCoreid = nil
      if (!cObjectInfo.nil?())
        if (@cConf.is_single?())
          nCoreid = 0
        else
          nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
        end
      end

      return nCoreid  # [Integer,NilClass]コアID
    end

    #=================================================================
    # 概  要: コンディション内の全てのマクロを置換する
    #=================================================================
    def convert_macro()
      @hAllObject.each_value{|cObjectInfo|
        cObjectInfo.convert_macro()
      }
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      hTmp        = @hAllObject.dup()
      @hAllObject = {}
      hTmp.each{|sObjectID, cObjectInfo|
        if (hAlias.has_key?(sObjectID))
          cObjectInfo.alias(hAlias)
          @hAllObject[hAlias[sObjectID]] = cObjectInfo
        else
          abort(ERR_MSG % [__FILE__, __LINE__])
        end
      }
    end

    #=================================================================
    # 概  要: 全補完終了後に実行する処理
    #=================================================================
    def complement_after()
      @hAllObject.each_value{|cObjectInfo|
        cObjectInfo.complement_after()
      }
    end

    #=================================================================
    # 概  要: コンディションの内容をYAMLオブジェクトに変換して返す
    #=================================================================
    def to_yaml(bIsPre = false)
      check_class(Bool, bIsPre)  # pre_conditionか

      hYaml = {}
      @hAllObject.each{|sObjectID, cObjectInfo|
        hYaml[sObjectID] = cObjectInfo.to_yaml(bIsPre)
      }

      return hYaml  # [Hash]YAMLオブジェクト
    end

    #=================================================================
    # 概  要: コンディション内に存在する変数名一覧を返す
    #=================================================================
    def get_variable_names()
      aVarNames = []
      @hAllObject.each_value{|cObjectInfo|
        aVarNames.concat(cObjectInfo.get_variable_names())
      }
      aVarNames = aVarNames.uniq()

      return aVarNames  # [Array]コンディション内に存在する変数名一覧
    end

    #=================================================================
    # 概  要: コンディション内に存在するコアID一覧を返す
    #=================================================================
    def get_all_coreid()
      aCoreID = []
      @hAllObject.each_value{|cObjectInfo|
        if (!cObjectInfo.hState[TSR_PRM_COREID].nil?())
          aCoreID.push(cObjectInfo.hState[TSR_PRM_COREID])
        end
      }

      return aCoreID.compact().uniq()  # [Array]コンディション内に存在するコアID一覧
    end

    #=================================================================
    # 概  要: コアIDごとに起動中の処理単位を返す
    #=================================================================
    def get_activate_process_unit_by_coreid()
      aDoProcess = get_activate_by_coreid()
      hObjects   = get_objects_by_type([TSR_OBJ_TASK, TSR_OBJ_RESTART_TASK])
      hObjects.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.is_activate?())
          nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
          if (aDoProcess[nCoreid].nil?())
            aDoProcess[nCoreid] = cObjectInfo
          end
        end
      }

      # 信頼関数のcallerに指定されている処理単位は置き換える
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        @hAllObject.each{|sObjectID, cObjectInfo|
          if ((cObjectInfo.sObjectType == TSR_OBJ_TRUSTED_FUNCTION) &&
              !cObjectInfo.hState[TSR_PRM_CALLER].nil?())
            nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
            if (!aDoProcess[nCoreid].nil?() && (aDoProcess[nCoreid].sObjectID == cObjectInfo.hState[TSR_PRM_CALLER]))
              aDoProcess[nCoreid] = cObjectInfo
            end
          end
        }
      end

      return aDoProcess  # [Array]コアIDごとに起動中の処理単位
    end

    #=================================================================
    # 概  要: コアIDごとにactivateな非タスクを返す
    #=================================================================
    def get_activate_by_coreid()
      aActivate = []
      if (@cConf.is_single?())
        aActivate[0] = get_activate()
      else
        aActivate = get_activate_multi()
      end

      return aActivate  # [Array]コアIDごとにactivateな非タスクを返す
    end

    #=================================================================
    # 概  要: コア内で同じ内部リソースを共有しているタスクを返す
    #=================================================================
    def get_shared_internal_resource(nCoreid)
      check_class(Integer, nCoreid)  # コアID

      hShareInternalRes = {}

      hResources = get_objects_by_type(TSR_OBJ_RESOURCE)
      hTasks = get_objects_by_type(TSR_OBJ_TASK)

      if (hResources != {} && hTasks != {})
        hResources.each{|sObjectID, cObjectInfo|
          hShareInternalRes[sObjectID] = []
        }
        hTasks.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.has_relres?() && cObjectInfo.hState[TSR_PRM_COREID] == nCoreid)
            cObjectInfo.hState[TSR_PRM_RELRES].each{|sResourceID|
              hShareInternalRes[sResourceID].push(sObjectID)
            }
          end
        }
        hResources.each{|sObjectID, cObjectInfo|
          if (!cObjectInfo.is_internal_resource?())
            hShareInternalRes.delete(sObjectID)
          end
        }
      end

      return hShareInternalRes  # [Hash]内部リソース(キー)を共有しているタスク(値)
    end

    #=================================================================
    # 概  要: C1ISRで割込み番号ごとにチェックする属性を返す
    #=================================================================
    def get_c1isr_attributes_by_intno()
      return get_object_attributes_by_attributes(TSR_OBJ_C1ISR, [TSR_PRM_INIINTPRI], [TSR_PRM_INTNO])  # [Hash]割込み番号の組み合わせごとの該当属性
    end

    #=================================================================
    # 概  要: C2ISRで割込み番号ごとにチェックする属性を返す
    #=================================================================
    def get_c2isr_attributes_by_intno()
      return get_object_attributes_by_attributes(TSR_OBJ_C2ISR, [TSR_PRM_INTATR, TSR_PRM_INIINTPRI], [TSR_PRM_INTNO])  # [Hash]割込み番号の組み合わせごとの該当属性
    end

    #=================================================================
    # 概  要: C1ISRで割込み番号ごとにチェックする所属するOSAPを返す
    #=================================================================
    def get_c1isr_osap_attributes_by_intno()
      return get_object_attributes_by_attributes(TSR_OBJ_C1ISR, [TSR_PRM_OSAP], [TSR_PRM_INTNO])  # [Hash]割込み番号の組み合わせごとの所属するOSAP
    end

    #=================================================================
    # 概  要: C2ISRで割込み番号ごとにチェックする所属するOSAPを返す
    #=================================================================
    def get_c2isr_osap_attributes_by_intno()
      return get_object_attributes_by_attributes(TSR_OBJ_C2ISR, [TSR_PRM_OSAP], [TSR_PRM_INTNO])  # [Hash]割込み番号の組み合わせごとの所属するOSAP
    end

    #=================================================================
    # 概  要: リスタートタスクで所属するOSAPごとにチェックする属性を返す
    #=================================================================
    def get_restarttask_attributes_by_osap()
      return get_object_attributes_by_attributes(TSR_OBJ_RESTART_TASK, [TSR_PRM_INIPRI, TSR_PRM_TTYPE, TSR_PRM_SPOLICY, TSR_PRM_ACTCNT, TSR_PRM_STKSZ,  TSR_PRM_SSTKSZ], [TSR_PRM_OSAP])  # [Hash]所属するOSAPの組み合わせごとの該当属性
    end

    #=================================================================
    # 概  要: 登場するC2ISR，ICISRの割込み属性，割込み要求禁止フラグを返す
    #=================================================================
    def get_isr_intatr_and_istat()
      hIsrAtr = Hash.new{|hash, key|
        hash[key] = []
      }

      hObjects = get_objects_by_type(TSR_OBJ_C2ISR)
      if (@cConf.is_multi?())
        hIcisrObjects = get_objects_by_type(TSR_OBJ_ICISR)
        hObjects = hObjects.merge(hIcisrObjects)
      end
      hObjects.each{|sObjectID, cObjectInfo|
        hIsrAtr[sObjectID].push(cObjectInfo.hState[TSR_PRM_INTATR])
        hIsrAtr[sObjectID].push(cObjectInfo.hState[TSR_PRM_ISTAT])
      }

      return hIsrAtr # [Hash]全C2ISR，ICISRの割込み属性，割込み要求禁止フラグ
    end

    #=================================================================
    # 概  要: 登場するISRの初期割込み優先度，割込み番号を返す
    #=================================================================
    def get_isr_intpri_and_intno()
      aIsr = []
      
      hC2IsrObjects = get_objects_by_type(TSR_OBJ_C2ISR)
      hC2IsrObjects.each{|sObjectID, cObjectInfo|
        aIsr.push(cObjectInfo.hState[TSR_PRM_INIINTPRI])
        aIsr.push(cObjectInfo.hState[TSR_PRM_INTNO])
      }

      hC1IsrObjects = get_objects_by_type(TSR_OBJ_C1ISR)
      hC1IsrObjects.each{|sObjectID, cObjectInfo|
        aIsr.push(cObjectInfo.hState[TSR_PRM_INIINTPRI])
        aIsr.push(cObjectInfo.hState[TSR_PRM_INTNO])
      }

      return aIsr # [Array]全ISRの割込み優先度，割込み番号
    end

    #=================================================================
    # 概  要: 登場するC2ISRの現在割込み優先度を返す
    #=================================================================
    def get_c2isr_curpri()
      aIsrpri = []
      
      hC2IsrObjects = get_objects_by_type(TSR_OBJ_C2ISR)
      hC2IsrObjects.each{|sObjectID, cObjectInfo|
        aIsrpri.push(cObjectInfo.hState[TSR_PRM_CURINTPRI])
      }

      return aIsrpri # [Array]全C2ISRの現在割込み優先度
    end

    #=================================================================
    # 概  要: 指定したオブジェクトの属性の値ごとに指定した属性の組み合
    #       : わせをグループ分けして返す
    #=================================================================
    def get_object_attributes_by_attributes(sObjectType, aTargetAtrs, aAtrsByGroup)
      check_class(String, sObjectType)  # オブジェクトタイプ
      check_class(Array, aTargetAtrs)   # 組み合わせとする属性名
      check_class(Array, aAtrsByGroup)  # グループ分けに使う属性名

      hResult = Hash.new{|hash, key|
        hash[key] = []
      }
      hObjects = get_objects_by_type(sObjectType)
      hObjects.each{|sObjectID, cObjectInfo|
        # key
        hKey = {}
        aAtrsByGroup.each{|sAtr|
          sRealAtr       = cObjectInfo.get_real_attribute_name(sAtr)
          hKey[sRealAtr] = cObjectInfo.hState[sAtr]
        }
        # value
        hVal  = {}
        aTargetAtrs.each{|sAtr|
          sRealAtr       = cObjectInfo.get_real_attribute_name(sAtr)
          hVal[sRealAtr] = cObjectInfo.hState[sAtr]
        }
        hResult[hKey].push(hVal)
      }

      # ユニーク化
      hResult.each{|hAtrs, aVals|
        hResult[hAtrs] = aVals.uniq()
      }

      return hResult  # [Hash]属性の組み合わせ(ハッシュ)の配列を値にもつハッシュ
    end
    private :get_object_attributes_by_attributes

    #=================================================================
    # 概  要: 全オブジェクトにおいて指定されていない属性をセット
    #=================================================================
    def set_nil_attribute()
      @hAllObject.each_value{|cObjectInfo|
        cObjectInfo.set_nil_attribute()
      }
    end

=begin
    #=================================================================
    # 概  要: いずれかのコアで割り込み優先度マスクが設定されてい
    #       : るかを返す
    #=================================================================
    def exist_disable_interrupt?()
      bResult = false

      hObjects = get_objects_by_type(TSR_OBJ_CPU_STATE)
      hObjects.each_value{|cObjectInfo|
        unless (cObjectInfo.is_enable_interrupt?())
          bResult = true
          break
        end
      }

      return bResult  # [Bool]いずれかのコアで割り込み優先度マスクが設定されているか
    end
=end
  end
end
