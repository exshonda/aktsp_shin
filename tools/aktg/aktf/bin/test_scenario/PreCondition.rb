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
# $Id: PreCondition.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: PreCondition
  # 概    要: pre_conditionの情報を処理するクラス
  #===================================================================
  class PreCondition < Condition
    #=================================================================
    # 概  要: pre_conditionの構造チェック
    #=================================================================
    def basic_check(hScenarioPre)
      check_class(Hash, hScenarioPre)  # pre_condition

      aErrors = []
      aPath = get_condition_path()
      # オブジェクトの構造チェック
      hScenarioPre.each{|sObjectID, hObjectInfo|
        begin
          common_basic_check(sObjectID, hObjectInfo, aPath)

          # オブジェクトの構造に問題がなければタイプ属性のチェック
          ### T1_017: pre_condition内のオブジェクトにtype属性が定義されていない
          if (!hObjectInfo.has_key?(TSR_PRM_TYPE))
            sErr = sprintf("T1_017: " + ERR_REQUIRED_KEY, TSR_PRM_TYPE)
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
          else
            # 定義できるオブジェクトタイプ
            if (@cConf.is_single?())
              if (@cConf.is_sc1?())
                aObjectType = GRP_DEF_OBJECT_SINGLE.keys()
              elsif (@cConf.is_sc3?())
                aObjectType = get_define_object_sc3().keys()
              elsif (@cConf.is_sc4?())
                aObjectType = get_define_object_sc3().keys()
              end
            else
              if (@cConf.is_sc1?())
                aObjectType = get_define_object_sc1_mc().keys()
              elsif (@cConf.is_sc3?())
                aObjectType = get_define_object_sc3_mc().keys()
              end
            end
            ### T1_016: 指定されたオブジェクトタイプが定義されていない
            if (!aObjectType.include?(hObjectInfo[TSR_PRM_TYPE]))
              sErr = sprintf("T1_016: " + ERR_OBJECT_UNDEFINED, hObjectInfo[TSR_PRM_TYPE])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
            end
          end
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

      begin
        # INT_STATEの準備
        aIntStateCount = []
        hObjects = get_objects_by_type(TSR_OBJ_INT_STATE)
        hObjects.each_value{|cObjectInfo|
          nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
          if (aIntStateCount[nCoreid].nil?())
            aIntStateCount[nCoreid] = 1
          else
            aIntStateCount[nCoreid] += 1
          end
        }
        # INT_STATEのチェック
        aIntStateCount.each_with_index{|nCount, nCoreid|
          ### T4_003: INT_STATEが1つのコアに2つ以上存在している
          if (!nCount.nil?() && nCount > 1)
            sErr = sprintf("T4_003: " + ERR_PLURAL_INT_STATE, nCoreid)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        }
        # 処理単位のチェックの準備
        hProcUnit = {
          :bTask             => false,
          :nStartupHook      => [],    # システム定義のスタートアップフックが存在するコアIDの配列
          :nShutdownHook     => [],    # システム定義のシャットダウンフックが存在するコアIDの配列
          :nPretaskHook      => [],    # システム定義のプレタスクフックが存在するコアIDの配列
          :nPosttaskHook     => [],    # システム定義のポストタスクフックが存在するコアIDの配列
          :nErrorHook        => [],    # システム定義のエラーフックが存在するコアIDの配列
          :nProtectionHook   => [],    # システム定義のプロテクションフックが存在するコアIDの配列
          :aStartupHookOsap  => [],    # OSAP固有のスタートアップフックを持つOSAPの配列
          :aShutdownHookOsap => [],    # OSAP固有のシャットダウンフックを持つOSAPの配列
          :aErrorHookOsap    => []     # OSAP固有のエラーフックを持つOSAPの配列
        }
        hActivate = {}
        aCoreid = get_all_coreid()
        aCoreid.each{|nCoreid|
          hActivate[nCoreid] = {}
        }
        # 登場する全OSAPをまとめておく
        if (@cConf.enable_osap?())
          aOsap = []
          @hAllObject.each_value{|cObjectInfo|
            if (cObjectInfo.sObjectType == TSR_OBJ_APPLICATION_MODE)
              next
            end
            aOsap.push(cObjectInfo.hState[TSR_PRM_OSAP])
          }
          aOsap.uniq!()
        end
        hReadyQueue = {}
        aCoreid.each{|nCoreid|
          hReadyQueue[nCoreid] = {:cRunning => nil, :aReady => []}
        }
        hRelres = {}
        bActivate = false

        # 処理単位のチェック
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
        hObjects.each{|sObjectID, cObjectInfo|
          # タスク
          if (cObjectInfo.sObjectType == TSR_OBJ_TASK)
            # タスクとイベントのチェック
            if (cObjectInfo.has_relevt?() && cObjectInfo.is_specified?(TSR_PRM_RELEVT))
              aMask = []
              cObjectInfo.hState[TSR_PRM_RELEVT].each{|sEvent|
                cEventInfo = @hAllObject[sEvent]
                ### T4_011: タスクのrelevtに指定されたイベントが存在しない
                if (cEventInfo.nil?())
                  sErr = sprintf("T4_011: " + ERR_NO_TARGET_OBJECT, sEvent)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELEVT]))
                else
                  ### T4_012: タスクのrelevtに指定されたイベントが，イベントでない
                  if (cEventInfo.sObjectType != TSR_OBJ_EVENT)
                    sErr = sprintf("T4_012: " + ERR_NOT_EVENT, sEvent)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELEVT]))
                  elsif (cEventInfo.hState[TSR_PRM_MASK] != TSR_STT_AUTO)
                    aMask.push(cEventInfo.hState[TSR_PRM_MASK])
                  end
                end
              }
              ### T4_013: タスクのrelevtに指定されたイベントが複数あり，ユーザ指定のイベントマスク値が指定されている場合，マスク値がビットユーニークでない
              if (!aMask.nil?() && aMask.size != aMask.uniq.size)
                sErr = sprintf("T4_013: " + ERR_EVENT_MASK_DUPLICATE, aMask.uniq)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELEVT]))
              end
            end
            # タスクとリソースのチェック
            if (cObjectInfo.has_relres?())
              aInternalRes = []
              cObjectInfo.hState[TSR_PRM_RELRES].each{|sRes|
                cResourceInfo = @hAllObject[sRes]
                ### T4_014: relresに指定されたリソースが存在しない
                if (cResourceInfo.nil?())
                  sErr = sprintf("T4_014: " + ERR_NO_TARGET_OBJECT, sRes)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                ### T4_015: タスクのrelresに指定されたリソースが，標準リソースか内部リソースでない
                elsif (cResourceInfo.sObjectType != TSR_OBJ_RESOURCE || !(cResourceInfo.is_standard_resource?() || cResourceInfo.is_internal_resource?()))
                  sErr = sprintf("T4_015: " + ERR_NOT_STD_OR_INT_RESOURCE, sRes)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                ### T4_022: タスクがノンプリエンプティブスケジューリングであるが，内部リソースが関連付けられている
                elsif (cObjectInfo.hState[TSR_PRM_SPOLICY] == TSR_STT_SCHNON && cResourceInfo.is_internal_resource?())
                  sErr = sprintf("T4_022: " + ERR_SCHNON_TSK_HAS_INTERNAL_RES, sRes)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                else
                  # 関連付けられていないリソースのチェック準備
                  if (!hRelres.has_key?(cResourceInfo.sObjectID))
                    hRelres[cResourceInfo.sObjectID] = []
                  end
                  hRelres[cResourceInfo.sObjectID].push(cObjectInfo)
                  if (cResourceInfo.is_internal_resource?())
                    if (@cConf.is_sc3?() || @cConf.is_sc4?())
                      sTaskOsap = cObjectInfo.hState[TSR_PRM_OSAP]
                      ### T4_OSAP_001: タスクが所属するOSAPがタスクのrelresに指定された内部リソースへのアクセス権を持たない
                      if (non_access_right_check(sTaskOsap, cResourceInfo.hState[TSR_PRM_OSAP], cResourceInfo.hState[TSR_PRM_ACCOSAP]))
                        sErr = sprintf("T4_OSAP_001: " + ERR_CANNOT_OSAP, sObjectID, sRes)
                        aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
                      end
                    end
                    # 内部リソースの重複チェック準備
                    aInternalRes.push(cResourceInfo.sObjectID)
                  end
                end
              }
              ### T4_016: タスクのrelresに指定されたリソースに，複数の内部リソースを指定している
              if (aInternalRes.size > 1)
                sErr = sprintf("T4_016: " + ERR_INTERNAL_RES_DUPLICATE, aInternalRes.join(", "))
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
              end
            end

            # 存在フラグtrue
            hProcUnit[:bTask] = true
            # 優先度矛盾チェックのためのデータ収集
            nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
            if (cObjectInfo.is_activate?())
              hReadyQueue[nCoreid][:cRunning] = cObjectInfo
            elsif (cObjectInfo.is_ready?())
              hReadyQueue[nCoreid][:aReady].push(cObjectInfo)
            end
            # appmode
            if (!cObjectInfo.hState[TSR_PRM_APPMODE].nil?())
              cObjectInfo.hState[TSR_PRM_APPMODE].each {|sAppMode|
                cAppModeInfo = @hAllObject[sAppMode]
                ### T4_081: appmodeに指定したアプリケーションモードが同一テストシナリオ内に存在しない(configure.yamlのapp_mode_nameで指定したアプリケーションモードは除く)
                if (cAppModeInfo.nil?())
                  if (@cConf.get_app_mode() != sAppMode)
                    sErr = sprintf("T4_081: " + ERR_NO_TARGET_OBJECT, sAppMode)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
                  end
                ### T4_082: appmodeに指定したアプリケーションモードがアプリケーションモードではない
                elsif (cAppModeInfo.sObjectType != TSR_OBJ_APPLICATION_MODE)
                  sErr = sprintf("T4_082: " + ERR_NOT_APPMODE, sAppMode)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
                end
              }
            end
            ### T4_094: pre_conditionで，シャットダウンフックが起動中の場合に，タスクのtstatがSUSPENDED以外を指定している
            if ((@lKernelState == :SHUTDOWNHOOK || @lKernelState == :SHUTDOWNHOOK_OSAP) &&
                (cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_SUSPENDED))
              sErr = sprintf("T4_094: " + ERR_STARTUP_SHUTDOWN_HOOK_ACTIVATE, TSR_PRM_TSTAT, TSR_STT_SUSPENDED)
              aErrors.push(YamlError.new(sErr, aPath))
            end
            if (@cConf.is_multi?())
              ### T4_MC_034: pre_conditionで，タスクのtstatがAK_RUNNING_WAITICISRである
              if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITICISR)
                sErr = sprintf("T4_MC_034: " + ERR_RUNNING_WAITSPIN, TSR_PRM_TSTAT, TSR_STT_RUNNING_WAITICISR)
                aErrors.push(YamlError.new(sErr, aPath))
              end
            end
          end
          # C2ISR
          if (cObjectInfo.sObjectType == TSR_OBJ_C2ISR)
            if (cObjectInfo.has_relres?())
              # C2ISRとリソースのチェック
              cObjectInfo.hState[TSR_PRM_RELRES].each{|sRes|
                cResourceInfo = @hAllObject[sRes]
                ### T4_014: relresに指定されたリソースが存在しない
                if (cResourceInfo.nil?())
                  sErr = sprintf("T4_014: " + ERR_NO_TARGET_OBJECT, sRes)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                ### T4_019: C2ISRのrelresに指定されたリソースが，標準リソースでない
                elsif (cResourceInfo.sObjectType != TSR_OBJ_RESOURCE || !cResourceInfo.is_standard_resource?())
                  sErr = sprintf("T4_019: " + ERR_NOT_STD_RESOURCE, sRes)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                else
                  # 関連付けられていないリソースのチェック準備
                  if (!hRelres.has_key?(cResourceInfo.sObjectID))
                    hRelres[cResourceInfo.sObjectID] = []
                  end
                  hRelres[cResourceInfo.sObjectID].push(cObjectInfo)
                end
              }
            end
            if (@cConf.is_multi?())
              ### T4_MC_029: pre_conditionで，C2ISR/ICISRのgetspnにスピンロックが指定されている場合に，rtnstatがAK_ACTIVATEでない
              if (!cObjectInfo.hState[TSR_PRM_GETSPN].nil?() && cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_ACTIVATE)
                sErr = sprintf("T4_MC_029: " + ERR_SET_GETSPN_RUNNING, TSR_PRM_RTNSTAT, TSR_STT_ACTIVATE)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETSPN]))
              end
              ### T4_MC_034: pre_conditionで，C2ISRのrtnstatがAK_ACTIVATE_WAITICISRである
              if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITICISR)
                sErr = sprintf("T4_MC_034: " + ERR_RUNNING_WAITSPIN, TSR_PRM_RTNSTAT, TSR_STT_ACTIVETE_WAITICISR)
                aErrors.push(YamlError.new(sErr, aPath))
              end
            end
          end
          if (@cConf.is_multi?())
            # ICISR
            if (cObjectInfo.sObjectType == TSR_OBJ_ICISR)
              if (cObjectInfo.has_relres?())
                # ICISRとリソースのチェック
                cObjectInfo.hState[TSR_PRM_RELRES].each{|sRes|
                  cResourceInfo = @hAllObject[sRes]
                  ### T4_014: relresに指定されたリソースが存在しない
                  if (cResourceInfo.nil?())
                    sErr = sprintf("T4_014: " + ERR_NO_TARGET_OBJECT, sRes)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                  ### T4_019: C2ISRのrelresに指定されたリソースが，標準リソースでない
                  elsif (cResourceInfo.sObjectType != TSR_OBJ_RESOURCE || !cResourceInfo.is_standard_resource?())
                    sErr = sprintf("T4_019: " + ERR_NOT_STD_RESOURCE, sRes)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
                  else
                    # 関連付けられていないリソースのチェック準備
                    if (!hRelres.has_key?(cResourceInfo.sObjectID))
                      hRelres[cResourceInfo.sObjectID] = []
                    end
                    hRelres[cResourceInfo.sObjectID].push(cObjectInfo)
                  end
                }
              end
              ### T4_MC_029: pre_conditionで，C2ISR/ICISRのgetspnにスピンロックが指定されている場合に，rtnstatがAK_ACTIVATEでない
              if (!cObjectInfo.hState[TSR_PRM_GETSPN].nil?() && cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_ACTIVATE)
                sErr = sprintf("T4_MC_029: " + ERR_SET_GETSPN_RUNNING, TSR_PRM_RTNSTAT, TSR_STT_ACTIVATE)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_GETSPN]))
              end
              ### T4_MC_034: pre_conditionで，ICISRのrtnstatがAK_ACTIVATE_WAITICISRである
              if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITICISR)
                sErr = sprintf("T4_MC_034: " + ERR_RUNNING_WAITSPIN, TSR_PRM_RTNSTAT, TSR_STT_ACTIVETE_WAITICISR)
                aErrors.push(YamlError.new(sErr, aPath))
              end
            end
          end
          # 信頼関数
          if (cObjectInfo.sObjectType == TSR_OBJ_TRUSTED_FUNCTION)
            if (!cObjectInfo.hState[TSR_PRM_CALLER].nil?)
              cProcUnitInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_CALLER]]
              ### T4_SC3_003: pre_conditionで，信頼関数のcallerに指定されたタスクかC2ISRが停止状態である
              if ((!cProcUnitInfo.nil?()) &&
                  (((cProcUnitInfo.sObjectType == TSR_OBJ_TASK) && (cProcUnitInfo.is_dormant?())) ||
                   ((cProcUnitInfo.sObjectType == TSR_OBJ_C2ISR) && (cProcUnitInfo.hState[TSR_PRM_STATE] == TSR_STT_STP)) ||
                   ((cProcUnitInfo.sObjectType == TSR_OBJ_ICISR) && (cProcUnitInfo.hState[TSR_PRM_STATE] == TSR_STT_STP))))
                sErr = sprintf("T4_SC3_003: " + ERR_CALLER_STOP, cObjectInfo.hState[TSR_PRM_CALLER])
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLER]))
              end
              ### T4_SC3_008: pre_conditionで信頼関数のcallerが指定されているが，argが指定されていない
              if (!cObjectInfo.is_specified?(TSR_PRM_ARG))
                sErr = sprintf("T4_SC3_008: " + ERR_NOT_SET_TFN, TSR_PRM_ARG)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLER]))
              end
            else
              ### T4_SC3_009: pre_conditionで信頼関数のcallerが指定されていないが，argが指定されている
              if (cObjectInfo.is_specified?(TSR_PRM_ARG))
                sErr = sprintf("T4_SC3_009: " + ERR_SET_TFN, TSR_PRM_ARG)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_ARG]))
              end
            end
          end

          # 実行中の処理単位の存在
          if (cObjectInfo.is_activate?())
            hActivate[cObjectInfo.hState[TSR_PRM_COREID]][cObjectInfo.sObjectType] = cObjectInfo
            bActivate = true
          end
          # フックの存在
          if (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK)
            hProcUnit[:nStartupHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK)
            hProcUnit[:nShutdownHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (cObjectInfo.sObjectType == TSR_OBJ_PRETASK_HOOK)
            hProcUnit[:nPretaskHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (cObjectInfo.sObjectType == TSR_OBJ_POSTTASK_HOOK)
            hProcUnit[:nPosttaskHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK)
            hProcUnit[:nErrorHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (cObjectInfo.sObjectType == TSR_OBJ_PROTECTION_HOOK)
            hProcUnit[:nProtectionHook].push(cObjectInfo.hState[TSR_PRM_COREID])
          elsif (@cConf.enable_osap?())
            if (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP)
              hProcUnit[:aStartupHookOsap].push(cObjectInfo.hState[TSR_PRM_OSAP])
            elsif (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)
              hProcUnit[:aShutdownHookOsap].push(cObjectInfo.hState[TSR_PRM_OSAP])
            elsif (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK_OSAP)
              hProcUnit[:aErrorHookOsap].push(cObjectInfo.hState[TSR_PRM_OSAP])
            end
          end
        }
        ### T4_001: pre_conditionで実行状態の処理単位が存在しない
        if (bActivate == false)
          aErrors.push(YamlError.new("T4_001: " + ERR_NO_RUNNING_PROCESS_UNIT, aPath))
        end

        # 優先度矛盾のチェック
        hReadyQueue.each{|nCoreid, hTasks|
          if (!hTasks[:cRunning].nil?() && hTasks[:cRunning].is_schfull?())
            nRunTaskPri = hTasks[:cRunning].hState[TSR_PRM_CURPRI]
            hTasks[:aReady].each{|cObjectInfo|
              ### T4_052: pre_conditionで，実行状態のタスクがフルプリエンプティブスケジューリングである場合に，同一コア内で実行状態のタスクより優先度の高いタスクが実行可能状態である
              if (cObjectInfo.hState[TSR_PRM_CURPRI] > nRunTaskPri)
                aErrors.push(YamlError.new("T4_052: " + ERR_HIGHER_TASK_READY, aPath))
                break
              elsif (hProcUnit[:nPretaskHook] == 1 && cObjectInfo.hState[TSR_PRM_CURPRI] == nRunTaskPri)
                ### T4_053: pre_conditionの同一コア内で，実行状態のタスクと同じ優先度の実行可能状態のタスクが存在し，システム定義のプレタスクフックが起動状態である
                if (hActivate[nCoreid].has_key?(TSR_OBJ_PRETASK_HOOK))
                  aErrors.push(YamlError.new("T4_053: " + ERR_PRETASKHOOK_CANT_ACT, aPath))
                  break
                end
              end
            }
          end
        }

        ### T4_002: pre_conditionでタスクが存在しない
        if (hProcUnit[:bTask] == false && !(hProcUnit[:nStartupHook].size > 0 || hProcUnit[:nShutdownHook].size > 0))
          aErrors.push(YamlError.new("T4_002: " + ERR_NO_TASK, aPath))
        end

        ### T4_026: システム定義のスタートアップフックが1コアに複数存在する
        if (hProcUnit[:nStartupHook].size != hProcUnit[:nStartupHook].uniq.size)
          sErr = sprintf("T4_026: " + ERR_MULTI_OBJECT, TSR_OBJ_STARTUP_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        ### T4_027: システム定義のシャットダウンフックが1コアに複数存在する
        if (hProcUnit[:nShutdownHook].size != hProcUnit[:nShutdownHook].uniq.size)
          sErr = sprintf("T4_027: " + ERR_MULTI_OBJECT, TSR_OBJ_SHUTDOWN_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        ### T4_028: システム定義のプレタスクフックが1コアに複数存在する
        if (hProcUnit[:nPretaskHook].size != hProcUnit[:nPretaskHook].uniq.size)
          sErr = sprintf("T4_028: " + ERR_MULTI_OBJECT, TSR_OBJ_PRETASK_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        ### T4_029: システム定義のポストタスクフックが1コアに複数存在する
        if (hProcUnit[:nPosttaskHook].size != hProcUnit[:nPosttaskHook].uniq.size)
          sErr = sprintf("T4_029: " + ERR_MULTI_OBJECT, TSR_OBJ_POSTTASK_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        ### T4_030: システム定義のエラーフックが1コアに複数存在する
        if (hProcUnit[:nErrorHook].size != hProcUnit[:nErrorHook].uniq.size)
          sErr = sprintf("T4_030: " + ERR_MULTI_OBJECT, TSR_OBJ_ERROR_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end
        ### T4_031: システム定義のプロテクションフックが1コアに複数存在する
        if (hProcUnit[:nProtectionHook].size != hProcUnit[:nProtectionHook].uniq.size)
          sErr = sprintf("T4_031: " + ERR_MULTI_OBJECT, TSR_OBJ_PROTECTION_HOOK)
          aErrors.push(YamlError.new(sErr, aPath))
        end

        bStartupHookActivate = false
        aCoreid.each{|nCoreid|
          ### T4_086: propertyのmaintask_waitがtrueの場合に，pre_conditionでタスク以外の処理単位が実行状態であるコアがある
          if (@hProperty[TSR_PRM_MAINTASK_WAIT] == true && (hActivate[nCoreid].size > 1 || (hActivate[nCoreid].size == 1 && !hActivate[nCoreid].has_key?(TSR_OBJ_TASK))))
            aErrors.push(YamlError.new("T4_086: " + ERR_TASK_NOT_RUNNING, aPath))
          end
          ### T4_036: 実行状態のエラーフックが存在するコンディションに，実行状態のタスクが存在しない
          if (hActivate[nCoreid].has_key?(TSR_OBJ_ERROR_HOOK) && !hActivate[nCoreid].has_key?(TSR_OBJ_TASK))
            sErr = sprintf("T4_036: " + ERR_NO_RUNTASK_WITH_PROC_UNIT, TSR_OBJ_ERROR_HOOK)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_037: 実行状態のプロテクションフックが存在するコンディションに，実行状態のタスクが存在しない
          if (hActivate[nCoreid].has_key?(TSR_OBJ_PROTECTION_HOOK) && !hActivate[nCoreid].has_key?(TSR_OBJ_TASK))
            sErr = sprintf("T4_037: " + ERR_NO_RUNTASK_WITH_PROC_UNIT, TSR_OBJ_PROTECTION_HOOK)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_095: pre_conditionで，実行状態のISRが存在するコアに，実行状態のタスクが存在しない
          if (hActivate[nCoreid].has_key?(TSR_OBJ_C2ISR) && !hActivate[nCoreid].has_key?(TSR_OBJ_TASK))
            sErr = sprintf("T4_095: " + ERR_NO_RUNTASK_WITH_PROC_UNIT, TSR_OBJ_C2ISR)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          if (hActivate[nCoreid].has_key?(TSR_OBJ_STARTUP_HOOK))
            bStartupHookActivate = true
          end
        }
        ### T4_096: システム定義のスタートアップフックが存在する場合に，pre_conditionで実行状態のシステム定義のスタートアップフックがどのコアにもいない
        if ((bStartupHookActivate == false) && !hProcUnit[:nStartupHook].empty?())
          aErrors.push(YamlError.new("T4_096: " + ERR_NO_ACTIVATE_STARTUP_HOOK, aPath))
        end
        if (@cConf.enable_osap?())
          ### T4_OSAP_006: 同一のOSAPに所属するOSAP固有のスタートアップフックが複数存在する
          if (hProcUnit[:aStartupHookOsap].size != hProcUnit[:aStartupHookOsap].uniq.size)
            sErr = sprintf("T4_OSAP_006: " + ERR_MULTI_OSAP_HOOK, TSR_OBJ_STARTUP_HOOK_OSAP)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_OSAP_007: 同一のOSAPに所属するOSAP固有のシャットダウンフックが複数存在する
          if (hProcUnit[:aShutdownHookOsap].size != hProcUnit[:aShutdownHookOsap].uniq.size)
            sErr = sprintf("T4_OSAP_007: " + ERR_MULTI_OSAP_HOOK, TSR_OBJ_SHUTDOWN_HOOK)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_OSAP_008: 同一のOSAPに所属するOSAP固有のエラーフックが複数存在する
          if (hProcUnit[:aErrorHookOsap].size != hProcUnit[:aErrorHookOsap].uniq.size)
            sErr = sprintf("T4_OSAP_008: " + ERR_MULTI_OSAP_HOOK, TSR_OBJ_ERROR_HOOK)
            aErrors.push(YamlError.new(sErr, aPath))
          end

          bStartupHookActivateOsap = true
          hObjects = get_objects_by_type(TSR_OBJ_STARTUP_HOOK_OSAP)
          aCoreid.each{|nCoreid|
            ### T4_OSAP_010: pre_conditionで，実行状態のOSAP固有のエラーフックが存在するコンディションに，同一のOSAPに所属する実行状態のタスクが存在しない
            if (hActivate[nCoreid].has_key?(TSR_OBJ_ERROR_HOOK_OSAP) &&
                (!hActivate[nCoreid].has_key?(TSR_OBJ_TASK) ||
                 (hActivate[nCoreid].has_key?(TSR_OBJ_TASK) && hActivate[nCoreid][TSR_OBJ_ERROR_HOOK_OSAP].hState[TSR_PRM_OSAP] != hActivate[nCoreid][TSR_OBJ_TASK].hState[TSR_PRM_OSAP])))
              sErr = sprintf("T4_OSAP_010: " + ERR_NO_RUNTASK_WITH_PROC_UNIT, TSR_OBJ_ERROR_HOOK_OSAP)
              aErrors.push(YamlError.new(sErr, aPath))
            end
            # T4_OSAP_012のチェック
            if (hProcUnit[:nStartupHook].empty?() && !hProcUnit[:aStartupHookOsap].empty?())
              hObjects.each{|sObjectID, cObjectInfo|
                if (cObjectInfo.hState[TSR_PRM_COREID] == nCoreid && !hActivate[nCoreid].has_key?(TSR_OBJ_STARTUP_HOOK_OSAP))
                  bStartupHookActivateOsap = false
                end
              }
            end
          }
          ### T4_OSAP_012: システム定義のスタートアップフックが存在しない場合に，OSAP固有のスタートアップフックが存在するコアで，pre_conditionでOSAP固有のスタートアップフックが実行状態でない
          if (bStartupHookActivateOsap == false)
            sErr = sprintf("T4_OSAP_012: " + ERR_STARTUP_HOOK_OSAP_STOP)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        end

        # リソース
        aStdResource = []
        hObjects = get_objects_by_type(TSR_OBJ_RESOURCE)
        hObjects.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.is_standard_resource?())
            aStdResource.push(sObjectID)
          end
        }
        hObjects.each{|sObjectID, cObjectInfo|
          # リンクリソースの場合
          if (cObjectInfo.is_linked_resource?())
            ### T4_061: リンクリソースのlinkresに指定されたオブジェクトが標準リソースでない
            if (!aStdResource.include?(cObjectInfo.hState[TSR_PRM_LINKRES]))
              sErr = sprintf("T4_061: " + ERR_NOT_STD_RESOURCE, cObjectInfo.hState[TSR_PRM_LINKRES])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RELRES]))
            end
          else
            ### T4_060: リソースが，タスクもしくはC2ISRのrelresに指定されていない(リンクリソースの場合を除く)
            if (!hRelres.has_key?(sObjectID))
              sErr = sprintf("T4_060: " + ERR_NOT_SET_RELRES, sObjectID)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
            end
            if (@cConf.is_multi?())
              ### T4_MC_004: 同じリソースを共有するタスク/C2ISR/ICISRが，異なるコアに存在する
              if (hRelres[sObjectID].size > 1)
                nCoreid = hRelres[sObjectID][0].hState[TSR_PRM_COREID]
                (1..(hRelres[sObjectID].size - 1)).each{|nCnt|
                  if (nCoreid != hRelres[sObjectID][nCnt].hState[TSR_PRM_COREID])
                    sErr = sprintf("T4_MC_004: " + ERR_SHARE_RES_NOT_SAME_COREID, sObjectID)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COREID]))
                  end
                }
              end
            end
          end
        }

        # アラーム
        hObjects = get_objects_by_type(TSR_OBJ_ALARM)
        hObjects.each{|sObjectID, cObjectInfo|
          cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]
          ### T4_039: アラームのcounterに指定されたオブジェクトが存在しない
          if (cCounterInfo.nil?())
            sErr = sprintf("T4_039: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_COUNTER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COUNTER]))
          ### T4_040: アラームのcounterに指定されたオブジェクトが，カウンタでない
          elsif(cCounterInfo.sObjectType != TSR_OBJ_COUNTER)
            sErr = sprintf("T4_040: " + ERR_NOT_COUNTER, cObjectInfo.hState[TSR_PRM_COUNTER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COUNTER]))
          else
            ### T4_059: pre_conditionで，アラームのalmvalが対象カウンタのcurvalと一致している
            if (cObjectInfo.hState[TSR_PRM_ALMVAL] == cCounterInfo.hState[TSR_PRM_CURVAL])
              sErr = sprintf("T4_059: " + ERR_ALMVAL_SAME_AS_CURVAL)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_ALMVAL]))
            end
            if (@cConf.is_multi?())
              ### T4_MC_002: アラームとアラームのcounterに指定されたオブジェクトが異なるコアに割付けられている
              nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
              if (nCoreid != cCounterInfo.hState[TSR_PRM_COREID])
                sErr = sprintf("T4_MC_002: " + ERR_NOT_SAME_COREID, cObjectInfo.sObjectID, cObjectInfo.hState[TSR_PRM_COUNTER])
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COREID]))
              end
            end
          end
          if (@cConf.is_multi?())
            ### T4_MC_005: pre_conditionで，astatがAK_SETのアラームが他コアに存在する場合，実行状態のタスク/C2ISR/ICISRが存在しない
            if (cObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET)
              nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
              if (nCoreid != @cConf.get_master_core())
                if (!hActivate[nCoreid].has_key?(TSR_OBJ_TASK))
                  sErr = sprintf("T4_MC_005: " + ERR_TASK_C2ISR_NOT_ACTIVATE, cObjectInfo.hState[TSR_PRM_ASTAT], TSR_STT_SET)
                  aErrors.push(YamlError.new(sErr, aPath))
                end
              end
            end
          end
          # 満了処理のチェック
          # タスクの起動の場合
          if (cObjectInfo.hState[TSR_PRM_ALMACT] == TSR_STT_ALM_ATSK)
            cTaskInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_TASK]]
            ### T4_041: アラームのtaskに指定されたオブジェクトが存在しない
            if (cTaskInfo.nil?())
              sErr = sprintf("T4_041: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_TASK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_TASK]))
            ### T4_042: アラームのtaskに指定されたオブジェクトが，タスクでない
            elsif (cTaskInfo.sObjectType != TSR_OBJ_TASK)
              sErr = sprintf("T4_042: " + ERR_NOT_TASK, cObjectInfo.hState[TSR_PRM_TASK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_TASK]))
            elsif (@cConf.is_sc3?() || @cConf.is_sc4?())
              sAlarmOsap = cObjectInfo.hState[TSR_PRM_OSAP]
              ### T4_OSAP_002: アラームが所属するOSAPがアラームのtaskに指定されたタスクへのアクセス権を持たない
              if (non_access_right_check(sAlarmOsap, cTaskInfo.hState[TSR_PRM_OSAP], cTaskInfo.hState[TSR_PRM_ACCOSAP]))
                sErr = sprintf("T4_OSAP_002: " + ERR_CANNOT_OSAP, sObjectID, cTaskInfo.sObjectID)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
              end
            end
          # イベントのセットの場合
          elsif (cObjectInfo.hState[TSR_PRM_ALMACT] == TSR_STT_ALM_SEVT)
            cTaskInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_TASK]]
            cEventInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_EVENT]]
            ### T4_041: アラームのtaskに指定されたオブジェクトが存在しない
            if (cTaskInfo.nil?())
              sErr = sprintf("T4_041: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_TASK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_TASK]))
            ### T4_042: アラームのtaskに指定されたオブジェクトが，タスクでない
            elsif (cTaskInfo.sObjectType != TSR_OBJ_TASK)
              sErr = sprintf("T4_042: " + ERR_NOT_TASK, cObjectInfo.hState[TSR_PRM_TASK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_TASK]))
            ### T4_045: アラーム満了時に実行させるアクションがイベントのセットの場合に，アラームのtaskに指定されたオブジェクトが，拡張タスクでない
            elsif (cTaskInfo.is_basic?())
              sErr = sprintf("T4_045: " + ERR_NOT_EXTENDED_TASK, cObjectInfo.hState[TSR_PRM_TASK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_TASK]))
            elsif (@cConf.is_sc3?() || @cConf.is_sc4?())
              sAlarmOsap = cObjectInfo.hState[TSR_PRM_OSAP]
              ### T4_OSAP_002: アラームが所属するOSAPがアラームのtaskに指定されたタスクへのアクセス権を持たない
              if (non_access_right_check(sAlarmOsap, cTaskInfo.hState[TSR_PRM_OSAP], cTaskInfo.hState[TSR_PRM_ACCOSAP]))
                sErr = sprintf("T4_OSAP_002: " + ERR_CANNOT_OSAP, sObjectID, cTaskInfo.sObjectID)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
              end
            end
            ### T4_043: アラームのeventに指定されたオブジェクトが存在しない
            if (cEventInfo.nil?())
              sErr = sprintf("T4_043: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_EVENT])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EVENT]))
            ### T4_044: アラームのeventに指定されたオブジェクトが，イベントでない
            elsif (cEventInfo.sObjectType != TSR_OBJ_EVENT)
              sErr = sprintf("T4_044: " + ERR_NOT_TASK, cObjectInfo.hState[TSR_PRM_EVENT])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EVENT]))
            end
          # カウンタのインクリメントの場合
          elsif (cObjectInfo.hState[TSR_PRM_ALMACT] == TSR_STT_ALM_INCNT)
            cInCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_INCOUNTER]]
            ### T4_046: アラームのincounterに指定されたオブジェクトが存在しない
            if (cInCounterInfo.nil?())
              sErr = sprintf("T4_046: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_INCOUNTER])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_INCOUNTER]))
            ### T4_047: アラームのincounterに指定されたオブジェクトが，カウンタでない
            elsif (cInCounterInfo.sObjectType != TSR_OBJ_COUNTER)
              sErr = sprintf("T4_047: " + ERR_NOT_COUNTER, cObjectInfo.hState[TSR_PRM_INCOUNTER])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_INCOUNTER]))
            elsif (@cConf.is_sc3?() || @cConf.is_sc4?())
              sAlarmOsap = cObjectInfo.hState[TSR_PRM_OSAP]
              ### T4_OSAP_003: アラームが所属するOSAPがアラームのincounterに指定されたカウンタへのアクセス権を持たない
              if (non_access_right_check(sAlarmOsap, cInCounterInfo.hState[TSR_PRM_OSAP], cInCounterInfo.hState[TSR_PRM_ACCOSAP]))
                sErr = sprintf("T4_OSAP_003: " + ERR_CANNOT_OSAP, sObjectID, cInCounterInfo.sObjectID)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
              end
            end
          # アラームコールバックの起動の場合
          elsif (cObjectInfo.hState[TSR_PRM_ALMACT] == TSR_STT_ALM_CBACK)
            cCallbackInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_CALLBAK]]
            ### T4_SC1_001: アラームのcallbackに指定されたオブジェクトが存在しない
            if (cCallbackInfo.nil?())
              sErr = sprintf("T4_SC1_001: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_CALLBAK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLBAK]))
            ### T4_SC1_002: アラームのcallbackに指定されたオブジェクトが，アラームコールバックでない
            elsif (cCallbackInfo.sObjectType != TSR_OBJ_ALARM_CALL_BACK)
              sErr = sprintf("T4_SC1_002: " + ERR_NOT_ALARM_CALL_BACK, cObjectInfo.hState[TSR_PRM_CALLBAK])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLBAK]))
            ### T4_SC1_003: pre_conditionでアラームコールバックのcbatatにAK_ACTIVATEが指定されている
            elsif (cCallbackInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
              sErr = sprintf("T4_SC1_003: " + ERR_CBSTAT_ACTIVE_IN_PRE)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CALLBAK]))
            end
          end
          # appmode
          if (!cObjectInfo.hState[TSR_PRM_APPMODE].nil?())
            cObjectInfo.hState[TSR_PRM_APPMODE].each{|sAppMode|
              cAppModeInfo = @hAllObject[sAppMode]
              ### T4_081: appmodeに指定したアプリケーションモードが同一テストシナリオ内に存在しない(configure.yamlのapp_mode_nameで指定したアプリケーションモードは除く)
              if (cAppModeInfo.nil?())
                if (@cConf.get_app_mode() != sAppMode)
                  sErr = sprintf("T4_081: " + ERR_NO_TARGET_OBJECT, sAppMode)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
                end
              ### T4_082: appmodeに指定したアプリケーションモードがアプリケーションモードではない
              elsif (cAppModeInfo.sObjectType != TSR_OBJ_APPLICATION_MODE)
                sErr = sprintf("T4_082: " + ERR_NOT_APPMODE, sAppMode)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
              end
            }
            nCntMax = cCounterInfo.hState[TSR_PRM_MAXVAL]
            ### T4_085: アラームの自動起動属性が相対アラームとして自動起動する，かつ，アプリケーションモードが指定された場合，almvalが，0より大きい，かつ，対象カウンタのmaxval以下でない
            if ((cObjectInfo.hState[TSR_PRM_AUTOSTARTTYPE] == TSR_STT_RELATIVE) &&
               ((cObjectInfo.hState[TSR_PRM_ALMVAL] <= 0) || (cObjectInfo.hState[TSR_PRM_ALMVAL] > nCntMax)))
              sErr = sprintf("T4_085: " + ERR_STARTTICK_INVALID, cObjectInfo.hState[TSR_PRM_ALMVAL])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_ALMVAL]))
            end
          end
          ### T4_093: pre_conditionで，スタートアップフックまたはシャットダウンフックが起動中の場合に，アラームのastatがAK_UNSET以外を指定している
          if ((@lKernelState != :KERNELBOOT) && (cObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET))
            sErr = sprintf("T4_093: " + ERR_STARTUP_SHUTDOWN_HOOK_ACTIVATE, TSR_PRM_ASTAT, TSR_STT_UNSET)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        }

        # スケジュールテーブル
        hObjects = get_objects_by_type(TSR_OBJ_SCHEDULE_TABLE)
        hObjects.each{|sObjectID, cObjectInfo|
          cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]
          ### T4_076: スケジュールテーブルのcounterに指定されたオブジェクトが存在しない
          if (cCounterInfo.nil?())
            sErr = sprintf("T4_076: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_COUNTER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COUNTER]))
          ### T4_077: スケジュールテーブルのcounterに指定されたオブジェクトが，カウンタでない
          elsif (cCounterInfo.sObjectType != TSR_OBJ_COUNTER)
            sErr = sprintf("T4_077: " + ERR_NOT_COUNTER, cObjectInfo.hState[TSR_PRM_COUNTER])
            aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COUNTER]))
          else
            if (@cConf.is_multi?())
              ### T4_MC_003: スケジュールテーブルとスケジュールテーブルのcounterに指定されたオブジェクトが異なるコアに割付けられている
              nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
              if (nCoreid != cCounterInfo.hState[TSR_PRM_COREID])
                sErr = sprintf("T4_MC_003: " + ERR_NOT_SAME_COREID, cObjectInfo.sObjectID, cObjectInfo.hState[TSR_PRM_COUNTER])
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_COREID]))
              end
              ### T4_MC_006: pre_conditionで，ststatがSCHEDULETABLE_RUNNINGのスケジュールテーブルが他コアに存在する場合，実行状態のタスク/C2ISR/ICISRが存在しない
              if (cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUNNING)
                nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
                if (nCoreid != @cConf.get_master_core())
                  if (!hActivate[nCoreid].has_key?(TSR_OBJ_TASK))
                    sErr = sprintf("T4_MC_006: " + ERR_TASK_C2ISR_NOT_ACTIVATE, cObjectInfo.hState[TSR_PRM_STSTAT], TSR_STT_SCHTBL_RUNNING)
                    aErrors.push(YamlError.new(sErr, aPath))
                  end
                end
              end
            end
            nMaxval = cCounterInfo.hState[TSR_PRM_MAXVAL]
            nMincyc = cCounterInfo.hState[TSR_PRM_MINCYC]
            ### T4_062: スケジュールテーブルの同期方法が暗黙同期スケジュールテーブルであるのに，スケジュールテーブル周期が対象カウンタのmaxval+1と等しくない
            if (cObjectInfo.hState[TSR_PRM_SYNCSTRATEGY] == TSR_STT_IMPLICIT &&
               cObjectInfo.hState[TSR_PRM_DURATION] != (nMaxval + 1))
              sErr = sprintf("T4_062: " + ERR_NOT_SAME_DURATION_AND_MAXVAL, cObjectInfo.hState[TSR_PRM_DURATION], (nMaxval + 1))
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DURATION]))
            end
            # 満了点のチェック
            cObjectInfo.hState[TSR_PRM_EXPOINT].each_with_index{|cExpoint, nIndex|
              # オフセット
              nOffset = cExpoint.nOffset
              if (nIndex == 0)
                ### T4_063: スケジュールテーブルの初期オフセットが0，もしくは，対象カウンタのmincyc以上，maxval以下でない
                if (!(nOffset == 0 || (nOffset >= nMincyc && nOffset <= nMaxval)))
                  sErr = sprintf("T4_063: " + ERR_INIT_OFFSET_INVALID, nOffset)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT]))
                end
              else
                nPrevOffset = cObjectInfo.hState[TSR_PRM_EXPOINT][nIndex - 1].nOffset
                nDelay = nOffset - nPrevOffset
                ### T4_064: スケジュールテーブルの遅延が対象カウンタのmincyc以上，maxval以下でない
                if (!(nDelay >= nMincyc && nDelay <= nMaxval))
                  sErr = sprintf("T4_064: " + ERR_DELAY_INVALID, nPrevOffset, nOffset)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT]))
                end
              end
              # タスクの起動の場合
              if (!cExpoint.aActtsk.nil?())
                cExpoint.aActtsk.each{|sTask|
                  cTaskInfo = @hAllObject[sTask]
                  ### T4_066: スケジュールテーブルのacttsk配下に指定されたオブジェクトが存在しない
                  if (cTaskInfo.nil?())
                    sErr = sprintf("T4_066: " + ERR_NO_TARGET_OBJECT, sTask)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                  ### T4_067: スケジュールテーブルのacttsk配下に指定されたオブジェクトが，タスクでない
                  elsif (cTaskInfo.sObjectType != TSR_OBJ_TASK)
                    sErr = sprintf("T4_067: " + ERR_NOT_TASK, sTask)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                  elsif (@cConf.is_sc3?() || @cConf.is_sc4?())
                    sSchtblOsap = cObjectInfo.hState[TSR_PRM_OSAP]
                    ### T4_OSAP_004: スケジュールテーブルが所属するOSAPがスケジュールテーブルのacttsk配下に指定されたタスクへのアクセス権を持たない
                    if (non_access_right_check(sSchtblOsap, cTaskInfo.hState[TSR_PRM_OSAP], cTaskInfo.hState[TSR_PRM_ACCOSAP]))
                      sErr = sprintf("T4_OSAP_004: " + ERR_CANNOT_OSAP, sObjectID, cTaskInfo.sObjectID)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
                    end
                  end
                }
              end
              # イベントのセットの場合
              if (!cExpoint.aSetevt.nil?())
                cExpoint.aSetevt.each{|hAction|
                  hAction.each{|sTask, sEvent|
                    cTaskInfo = @hAllObject[sTask]
                    cEventInfo = @hAllObject[sEvent]
                    ### T4_068: スケジュールテーブルのsetevt配下のハッシュのキーに指定されたオブジェクトが存在しない
                    if (cTaskInfo.nil?())
                      sErr = sprintf("T4_068: " + ERR_NO_TARGET_OBJECT, sTask)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                    ### T4_069: スケジュールテーブルのsetevt配下のハッシュのキーに指定されたオブジェクトが，タスクでない
                    elsif (cTaskInfo.sObjectType != TSR_OBJ_TASK)
                      sErr = sprintf("T4_069: " + ERR_NOT_TASK, sTask)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                    ### T4_070: スケジュールテーブルのsetevt配下のハッシュのキーに指定されたタスクが，拡張タスクでない
                    elsif (cTaskInfo.is_basic?())
                      sErr = sprintf("T4_070: " + ERR_NOT_EXTENDED_TASK, sTask)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                    elsif (@cConf.is_sc3?() || @cConf.is_sc4?())
                      sSchtblOsap = cObjectInfo.hState[TSR_PRM_OSAP]
                      ### T4_OSAP_005: スケジュールテーブルが所属するOSAPがスケジュールテーブルのsetevt配下のハッシュのキーに指定されたタスクへのアクセス権を持たない
                      if (non_access_right_check(sSchtblOsap, cTaskInfo.hState[TSR_PRM_OSAP], cTaskInfo.hState[TSR_PRM_ACCOSAP]))
                        sErr = sprintf("T4_OSAP_005: " + ERR_CANNOT_OSAP, sObjectID, cTaskInfo.sObjectID)
                        aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_OSAP]))
                      end
                    end
                    ### T4_071: スケジュールテーブルのsetevt配下のハッシュの値に指定されたオブジェクトが存在しない
                    if (cEventInfo.nil?())
                      sErr = sprintf("T4_071: " + ERR_NO_TARGET_OBJECT, sEvent)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                    ### T4_072: スケジュールテーブルのsetevt配下のハッシュの値に指定されたオブジェクトが，イベントでない
                    elsif (cEventInfo.sObjectType != TSR_OBJ_EVENT)
                      sErr = sprintf("T4_072: " + ERR_NOT_EVENT, sEvent)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT, nOffset]))
                    end
                  }
                }
              end
            }
            nFinalDelay = cObjectInfo.hState[TSR_PRM_DURATION] - cObjectInfo.hState[TSR_PRM_EXPOINT][AKTG_IDX_LAST].nOffset
            ### T4_065: スケジュールテーブルの最終遅延が対象カウンタのmincyc以上，maxval以下でない(単発動作の場合は0も指定可能)
            if (!(nFinalDelay >= nMincyc && nFinalDelay <= nMaxval) && !(cObjectInfo.hState[TSR_PRM_REPEAT] == TSR_STT_FALSE && nFinalDelay == 0))
              sErr = sprintf("T4_065: " + ERR_FINAL_DELAY_INVALID, nFinalDelay)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_EXPOINT]))
            end
            nStarttick = cObjectInfo.hState[TSR_PRM_STARTTICK]
            ### T4_083: スケジュールテーブルの自動起動属性がティックの絶対値で自動起動する場合，自動起動ティック値が0以上，対象カウンタのmaxval以下でない
            if ((cObjectInfo.hState[TSR_PRM_AUTOSTARTTYPE] == TSR_STT_ABSOLUTE) && ((nStarttick < 0) || (nStarttick > nMaxval)))
              sErr = sprintf("T4_083: " + ERR_STARTTICK_INVALID, nStarttick)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_STARTTICK]))
            end
            ### T4_084: スケジュールテーブルの自動起動属性がティックの相対値で自動起動する場合，自動起動ティック値が0より大きく，対象カウンタのmaxval以下でない
            if ((cObjectInfo.hState[TSR_PRM_AUTOSTARTTYPE] == TSR_STT_RELATIVE) && ((nStarttick <= 0) || (nStarttick > nMaxval)))
              sErr = sprintf("T4_084: " + ERR_STARTTICK_INVALID, nStarttick)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_STARTTICK]))
            end
            if (cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUNNING || cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUN_AND_SYNC)
              ### T4_098: pre_conditionで，スケジュールテーブルのststatがSCHEDULETABLE_RUNNING，SCHEDULETABLE_RUNNING_AND_SYNCHRONOUSであるのに，curvalが指定されていない
              if (cObjectInfo.hState[TSR_PRM_CURVAL].nil?())
                sErr = sprintf("T4_098: " + ERR_NOT_SET_CURVAL, cObjectInfo.hState[TSR_PRM_STSTAT])
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CURVAL]))
              else
                nIniOffset = cObjectInfo.hState[TSR_PRM_EXPOINT][0].get_expoint_offset()
                ### T4_099: pre_conditionで，スケジュールテーブルのcurvalが初期オフセット未満でない
                if (nIniOffset <= cObjectInfo.hState[TSR_PRM_CURVAL])
                  sErr = sprintf("T4_099: " + ERR_CURVAl_GT_OFFSET, cObjectInfo.hState[TSR_PRM_CURVAL], nIniOffset)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_CURVAL]))
                end
              end
            end
          end
          # appmode
          if (!cObjectInfo.hState[TSR_PRM_APPMODE].nil?())
            cObjectInfo.hState[TSR_PRM_APPMODE].each{|sAppMode|
              cAppModeInfo = @hAllObject[sAppMode]
              ### T4_081: appmodeに指定したアプリケーションモードが同一テストシナリオ内に存在しない(configure.yamlのapp_mode_nameで指定したアプリケーションモードは除く)
              if (cAppModeInfo.nil?())
                if (@cConf.get_app_mode() != sAppMode)
                  sErr = sprintf("T4_081: " + ERR_NO_TARGET_OBJECT, sAppMode)
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
                end
              ### T4_082: appmodeに指定したアプリケーションモードがアプリケーションモードではない
              elsif (cAppModeInfo.sObjectType != TSR_OBJ_APPLICATION_MODE)
                sErr = sprintf("T4_082: " + ERR_NOT_APPMODE, sAppMode)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, sAppMode]))
              end
            }
          end
          ### T4_092: pre_conditionで，スタートアップフックまたはシャットダウンフックが起動中の場合に，スケジュールテーブルのststatがSCHEDULETABLE_STOPPED以外を指定している
          if ((@lKernelState != :KERNELBOOT) && (cObjectInfo.hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_STOPPED))
            sErr = sprintf("T4_092: " + ERR_STARTUP_SHUTDOWN_HOOK_ACTIVATE, TSR_PRM_STSTAT, TSR_STT_SCHTBL_STOPPED)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        }

        # カウンタ
        nHwcntNum = 0
        hObjects = get_objects_by_type(TSR_OBJ_COUNTER)
        hObjects.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.is_hardware_counter?())
            nHwcntNum += 1
          end
          ### T4_091: pre_conditionで，スタートアップフックまたはシャットダウンフックが起動中の場合に，カウンタのcurvalが0以外を指定している
          if ((@lKernelState != :KERNELBOOT) && (cObjectInfo.hState[TSR_PRM_CURVAL] != 0))
            sErr = sprintf("T4_091: " + ERR_STARTUP_SHUTDOWN_HOOK_ACTIVATE, TSR_PRM_CURVAL, 0)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          ### T4_097: pre_conditionで，カウンタのcstatにAK_CS_DOINGが指定されている
          if (cObjectInfo.hState[TSR_PRM_CSTAT] == TSR_STT_CS_DOING)
            sErr = sprintf("T4_097: " + ERR_CSTAT_ACTIVE_IN_PRE)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          if (@cConf.is_multi?())
            ### T4_MC_001: pre_conditionで，curvarが0でないカウンタが所属するコアに実行状態のタスク/C2ISR/ICISRが存在しない
            if (cObjectInfo.hState[TSR_PRM_CURVAL] != 0)
              nCoreid = cObjectInfo.hState[TSR_PRM_COREID]
              if (nCoreid != @cConf.get_master_core())
                if (!hActivate[nCoreid].has_key?(TSR_OBJ_TASK) || (hActivate[nCoreid].has_key?(TSR_OBJ_TASK) && hActivate[nCoreid].has_key?(TSR_OBJ_PRETASK_HOOK)))
                  sErr = sprintf("T4_MC_001: " + ERR_COUNTER_TASK_C2ISR_NOT_ACTIVATE)
                  aErrors.push(YamlError.new(sErr, aPath))
                end
              end
            end
          end
        }
        ### T4_038: ハードウェアカウンタが複数存在する
        if (nHwcntNum > 1)
          sErr = sprintf("T4_038: " + ERR_MULTI_OBJECT, "Hardware Counter")
          aErrors.push(YamlError.new(sErr, aPath))
        end

        # ISR
        hIntno = Hash.new{|hash, snIntno|
          hash[snIntno] = []
        }
        hObjects = get_objects_by_type([TSR_OBJ_C1ISR, TSR_OBJ_C2ISR])
        hObjects.each{|sObjectID, cObjectInfo|
          # 割込み番号ごとにまとめる
          snIntno = cObjectInfo.hState[TSR_PRM_INTNO]
          hIntno[snIntno].push(sObjectID)
        }
        # 割込み番号に着目したチェック
        hIntno.each{|snIntno, aItem|
          ### T4_010: intnoが同じであるISRが複数存在する
          if (aItem.size() > 1)
            sErr = sprintf("T4_010: " + ERR_INTNO_DUPLICATE, snIntno, aItem.join(", "))
            aErrors.push(YamlError.new(sErr, aPath))
          end
        }

        # OSAP
        aOsap = []
        hObjects = get_objects_by_type(TSR_OBJ_OSAP)
        hObjects.each_key{|sObjectID|
          # OSAPIDをまとめる
          aOsap.push(sObjectID)
        }
        ### T4_SC3_010: OSAPに所属しているオブジェクトが存在しない
        if (!aOsap.empty?())
          bOsapCheck = false
          hObjects = get_objects_by_type(GRP_OSAP_OBJECT)
          hObjects.each{|sObjectID, cObjectInfo|
            if (aOsap.include?(cObjectInfo.hState[TSR_PRM_OSAP]))
              bOsapCheck = true
            end
          }
          if (bOsapCheck == false)
           sErr = sprintf("T4_SC3_010: " + ERR_OBJECT_NOT_BELONG_OSAP, aOsap.join(", "))
            aErrors.push(YamlError.new(sErr, aPath))
          end
        end

        if (@cConf.is_multi?())
          # スピンロック
          hObjects = get_objects_by_type(TSR_OBJ_SPINLOCK)
          hObjects.each{|sObjectID, cObjectInfo|
            if (!cObjectInfo.hState[TSR_PRM_SUCCESSOR].nil?())
              ### T4_MC_009: スピンロックのsuccessorに指定されたオブジェクトが存在しない
              if (@cConf.is_dilation_spinlock?(cObjectInfo.hState[TSR_PRM_SUCCESSOR]) == false)
                cSpinlockInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_SUCCESSOR]]
                if (cSpinlockInfo.nil?())
                  sErr = sprintf("T4_MC_009: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_SUCCESSOR])
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SUCCESSOR]))
                ### T4_MC_010: スピンロックのsuccessorに指定されたオブジェクトがスピンロックでない
                elsif (cSpinlockInfo.sObjectType != TSR_OBJ_SPINLOCK)
                  sErr = sprintf("T4_MC_010: " + ERR_NOT_SPINLOCK, cObjectInfo.hState[TSR_PRM_SUCCESSOR])
                  aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SUCCESSOR]))
                end
              end
            end
          }

          # IOC
          hSendid = Hash.new{|hash, snSendid|
            hash[snSendid] =[]
          }
          hObjects = get_objects_by_type(TSR_OBJ_IOC)
          hObjects.each{|sObjectID, cObjectInfo|
            cObjectInfo.hState[TSR_PRM_SENDER].each{|sSender|
              cSenderInfo = @hAllObject[sSender]
              ### T4_MC_017: IOCのsenderに指定されたIOCセンダが存在しない
              if (cSenderInfo.nil?())
                sErr = sprintf("T4_MC_017: " + ERR_NO_TARGET_OBJECT, sSender)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SENDER]))
              ### T4_MC_018: IOCのsenderに指定されたオブジェクトが，IOCセンダではない
              elsif (cSenderInfo.sObjectType != TSR_OBJ_IOC_SENDER)
                sErr = sprintf("T4_MC_018: " + ERR_NOT_IOC_SENDER, sSender)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SENDER]))
              else
                if (cObjectInfo.hState[TSR_PRM_SENDER].length > 1)
                  ### T4_MC_033: IOCのsenderに指定されたIOCセンダが複数存在する場合(N:1通信)，IOCセンダのseneridが存在しない
                  if (cSenderInfo.hState[TSR_PRM_SENDERID].nil?())
                    sErr = sprintf("T4_MC_033: " + ERR_NO_IOC_SENDER_ID, sSender)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SENDER]))
                  else
                    # senderidのチェック用に情報を保持しておく
                    snSendid = cSenderInfo.hState[TSR_PRM_SENDERID]
                    hSendid[snSendid].push(cSenderInfo.sObjectID)
                  end
                else
                  ### T4_MC_032: IOCのsenderに指定されたIOCセンダが1個存在する場合(1:1通信)，IOCセンダのseneridが存在する
                  if (!cSenderInfo.hState[TSR_PRM_SENDERID].nil?())
                    sErr = sprintf("T4_MC_032: " + ERR_NOT_EXIST_IOC_SENDER_ID, sSender)
                    aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_SENDER]))
                  end
                end
              end
            }
            cReceiverInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_RECEIVER]]
            ### T4_MC_019: IOCのreceiverに指定されたIOCレシーバが存在しない
            if (cReceiverInfo.nil?())
              sErr = sprintf("T4_MC_019: " + ERR_NO_TARGET_OBJECT, cObjectInfo.hState[TSR_PRM_RECEIVER])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RECEIVER]))
            ### T4_MC_020: IOCのreceiverに指定されたオブジェクトが，IOCレシーバではない
            elsif (cReceiverInfo.sObjectType != TSR_OBJ_IOC_RECEIVER)
              sErr = sprintf("T4_MC_020: " + ERR_NOT_IOC_RECEIVER, cObjectInfo.hState[TSR_PRM_RECEIVER])
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_RECEIVER]))
            end
            cObjectInfo.hState[TSR_PRM_IOCDATA].each{|sIocdata|
              cIocdataInfo = @hAllObject[sIocdata]
              ### T4_MC_021: IOCのiocdataに指定したIOC通信データが存在しない
              if (cIocdataInfo.nil?())
                sErr = sprintf("T4_MC_021: " + ERR_NO_TARGET_OBJECT, sIocdata)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_IOCDATA]))
              ### T4_MC_022: IOCのiocdataに指定されたオブジェクトが，IOC通信データではない
              elsif (cIocdataInfo.sObjectType != TSR_OBJ_IOC_DATA)
                sErr = sprintf("T4_MC_022: " + ERR_NOT_IOC_DATA, sIocdata)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_IOCDATA]))
              end
            }
            ### T4_MC_027: pre_conditionで，IOCのlostflgがtrueと設定されている
            if (!cObjectInfo.hState[TSR_PRM_LOSTFLG].nil?() && cObjectInfo.hState[TSR_PRM_LOSTFLG] == true)
              sErr = sprintf("T4_MC_027: " + ERR_LOSTFLG_TRUE_PRE)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_LOSTFLG]))
            end
            # senderidに着目したチェック
            hSendid.each{|snSendid, aItem|
              ### T4_MC_028: IOCのsenderに指定されたIOCセンダが複数存在する場合，IOCセンダのsenderidが同じオブジェクトが存在する
              if (aItem.size() > 1)
                sErr = sprintf("T4_MC_028: " + ERR_SENDERID_DUPLICATE, snSendid, aItem.join(", "))
                aErrors.push(YamlError.new(sErr, aPath))
              end
            }
            if (!cObjectInfo.hState[TSR_PRM_DATA].nil?)
              ### T4_MC_031: IOCのdataに格納されたデータがIOC通信データのinitvalと異なる場合，IOCセンダが所属するOSAPと同一のOSAPに所属する実行状態のタスク/C2ISR/ICISRが存在しない
              cObjectInfo.hState[TSR_PRM_DATA].each{|hData|
                hData.each_key{|sData|
                  cDataInfo = @hAllObject[sData]
                  if (cDataInfo.hState[TSR_PRM_INITVAL] != hData[sData])
                    bNotErr = false
                    cObjectInfo.hState[TSR_PRM_SENDER].each{|sSender|
                      cSenderInfo = @hAllObject[sSender]
                      aCoreid.each{|nCoreid|
                        if (hActivate[nCoreid].has_key?(TSR_OBJ_TASK) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_TASK].hState[TSR_PRM_OSAP])) ||
                           (hActivate[nCoreid].has_key?(TSR_OBJ_C2ISR) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_C2ISR].hState[TSR_PRM_OSAP])) ||
                           (hActivate[nCoreid].has_key?(TSR_OBJ_ICISR) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_ICISR].hState[TSR_PRM_OSAP]))
                          bNotErr = true
                          break
                        end
                      }
                    }
                    if (bNotErr != true)
                      sErr = sprintf("T4_MC_031: " + ERR_TASK_C2ISR_NOT_ACTIVATE_OSAP, TSR_PRM_DATA)
                      aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATA]))
                    end
                  end
                }
              }
            end
            if (!cObjectInfo.hState[TSR_PRM_DATALIST].nil?)
              ### T4_MC_030: IOCのdatalisにデータが格納されている場合，IOCセンダが所属するOSAPと同一のOSAPに所属する実行状態のタスク/C2ISR/ICISRが存在しない
              bNotErr = false
              cObjectInfo.hState[TSR_PRM_SENDER].each{|sSender|
                cSenderInfo = @hAllObject[sSender]
                aCoreid.each{|nCoreid|
                  if (hActivate[nCoreid].has_key?(TSR_OBJ_TASK) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_TASK].hState[TSR_PRM_OSAP])) ||
                     (hActivate[nCoreid].has_key?(TSR_OBJ_C2ISR) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_C2ISR].hState[TSR_PRM_OSAP])) ||
                     (hActivate[nCoreid].has_key?(TSR_OBJ_ICISR) && (cSenderInfo.hState[TSR_PRM_OSAP] == hActivate[nCoreid][TSR_OBJ_ICISR].hState[TSR_PRM_OSAP]))
                    bNotErr = true
                    break
                  end
                }
              }
              if (bNotErr != true)
                sErr = sprintf("T4_MC_030: " + ERR_TASK_C2ISR_NOT_ACTIVATE_OSAP, TSR_PRM_DATALIST)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID, TSR_PRM_DATALIST]))
              end
            end
          }
        end

        ### T4_088: propertyのapplication_modeを指定した場合に，スタートアップフックが存在しない
        if (!@hProperty[TSR_PRM_PRO_APPMODE].nil?() && hProcUnit[:nStartupHook].empty?() && hProcUnit[:aStartupHookOsap].empty?())
           sErr = sprintf("T4_088: " + ERR_APPMODE_NOT_STARTUPHOOK)
           aErrors.push(YamlError.new(sErr, aPath))
        end

        check_error(aErrors)
      rescue AKTFMultiError
        # condition.rbのcondition_checkは実施しない
      else
        super(bCannotMerge)
      end
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      @hAllObject.each_value{|cObjectInfo|
        cObjectInfo.complement_init_object_info()
        # アラームコールバックのcoreidにはアラームのcoreidを補完する
        if (cObjectInfo.sObjectType == TSR_OBJ_ALARM && cObjectInfo.hState[TSR_PRM_ALMACT] == TSR_STT_ALM_CBACK && !@hAllObject[cObjectInfo.hState[TSR_PRM_CALLBAK]].nil?())
          @hAllObject[cObjectInfo.hState[TSR_PRM_CALLBAK]].hState[TSR_PRM_COREID] = cObjectInfo.hState[TSR_PRM_COREID]
        end
      }

      # @lKernelStateの設定(スタートアップフック，シャットダウンフックの起動状態を表すインスタンス変数)
      # 自動起動のケースで使用する置換処理用の変数
      hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
      hObjects.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
          @lKernelState = :STARTUPHOOK
        elsif ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
          @lKernelState = :STARTUPHOOK_OSAP
        elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
          @lKernelState = :SHUTDOWNHOOK
        elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
          @lKernelState = :SHUTDOWNHOOK_OSAP
        elsif (@lKernelState == nil)
          @lKernelState = :KERNELBOOT
        end
      }
    end

    #=================================================================
    # 概  要: 全オブジェクト・変数のエイリアス変換テーブルを返す
    #=================================================================
    def get_alias(bSingleTest)
      check_class(Bool, bSingleTest) # テストケースが1件かどうか

      hResult       = {}
      aSortedObject = @hAllObject.sort()
      aSortedObject.each{|aObjectInfo|
        cObjectInfo = aObjectInfo[1]
        hAlias = cObjectInfo.get_alias(@sTestID, bSingleTest)
        hResult = hResult.merge(hAlias)
      }
      return hResult  # [Hash]エイリアス変換テーブル
    end

    #=================================================================
    # 概  要: オブジェクトがアクセス権を持たないかのチェック
    #=================================================================
    def non_access_right_check(sAccObject, sRefOsap, aAccOsap)
      check_class(String, sAccObject)     # アクセスするオブジェクトが所属するOSAP
      check_class(String, sRefOsap, true) # アクセスされるオブジェクトのOSAP
      check_class(Array, aAccOsap, true)  # アクセスされるオブジェクトにアクセス可能なOSAP

      if (aAccOsap.nil?())
        aAccOsap = []
      end

      if (!@cConf.is_multi?())
        if (sRefOsap.nil?())
          return (sAccObject.include?(AKTG_JUDGE_NON_TRUSTED) && !aAccOsap.include?(sAccObject))  # [Bool]アクセス権を持たないか
        else
          return (sAccObject.include?(AKTG_JUDGE_NON_TRUSTED) && sRefOsap != sAccObject && !aAccOsap.include?(sAccObject))  # [Bool]アクセス権を持たないか
        end
      else
        if (sRefOsap.nil?())
          return (sAccObject.include?(AKTG_JUDGE_MC_NON_TRUSTED) && !aAccOsap.include?(sAccObject))  # [Bool]アクセス権を持たないか
        else
          return (sAccObject.include?(AKTG_JUDGE_MC_NON_TRUSTED) && sRefOsap != sAccObject && !aAccOsap.include?(sAccObject))  # [Bool]アクセス権を持たないか
        end
      end
    end

    #=================================================================
    # 概  要: pre_conditionのパス情報を返す
    #=================================================================
    def get_condition_path()
      return [@sTestID, TSR_LBL_PRE]  # [Array]pre_conditionのパス情報
    end

    #=================================================================
    # 概  要: 除外されたエラーフックを含むテストID一覧を返す
    #=================================================================
    def error_hook_exclude_id()
      return @aErrorHookTsetId
    end

  end
end
