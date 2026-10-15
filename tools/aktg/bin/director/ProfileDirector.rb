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
# $Id: ProfileDirector.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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

module AKTG

  #==================================================================
  # クラス名: ProfileDirector
  # 概    要: ProfileBuilderを利用して中間コードを生成するクラス
  #==================================================================
  class ProfileDirector
    include CommonModule

    #================================================================
    # 概  要: コンストラクタ
    #================================================================
    def initialize(cProfileBuilder)
      check_class(ProfileBuilder, cProfileBuilder) # ProfileBuilderクラスのインスタンス

      @cProfileBuilder = cProfileBuilder.dup()

      @cConf = Config.new() # Configを取得
    end


    #================================================================
    # 概  要: 指定されたProfileBuilderを用いてbuildを行う
    #================================================================
    def build(aOrgTestScenarios)
      check_class(Array, aOrgTestScenarios) # テストシナリオの配列

      # 共有関数の情報を設定
      GRP_SHARED_PROCESS_UNIT.each{|sProcUnitType|
        hProcUnitInfo = get_all_proc_unit_info(aOrgTestScenarios, sProcUnitType)
        if (!hProcUnitInfo.empty?())
          @cProfileBuilder.build_shared_proc_unit(hProcUnitInfo, sProcUnitType)
          if (sProcUnitType == TSR_OBJ_RESTART_TASK)
            # コンフィギュレーション設定のためリスタートタスクの情報を渡す
            @cProfileBuilder.set_restart_task_info(hProcUnitInfo)
          end
        end
      }

      # 各フックの有無情報を取得
      hIsHookInfo = {TSR_OBJ_STARTUP_HOOK => false,
                     TSR_OBJ_SHUTDOWN_HOOK => false,
                     TSR_OBJ_PRETASK_HOOK => false,
                     TSR_OBJ_POSTTASK_HOOK => false,
                     TSR_OBJ_ERROR_HOOK => false,
                     TSR_OBJ_PROTECTION_HOOK => false}
      bIsHwcntInfo = false
      sRestartOsap = nil
      aOrgTestScenarios.each{|cTestScenario|
        GRP_PROCESS_UNIT_HOOK.each{|sHookType|
          if (cTestScenario.exist_proc_unit(sHookType) == true)
            hIsHookInfo[sHookType] = true
          end
        }
        if (cTestScenario.exist_hwcnt() == true)
          bIsHwcntInfo = true
        end
        if (@cConf.is_sc3?() || @cConf.is_sc4?())
          aOsapId = []
          aOsapId = cTestScenario.check_terminate_restart_osap()
          if (!aOsapId.nil?() && aOsapId.include?(TSR_STT_NT_OSAP_RESTARTING))
            sRestartOsap = TSR_STT_NT_OSAP_RESTARTING
          end
        end
      }

      # SC3/SC4/全MCの場合，ハードウェアカウンタにアクセス可能OSAP情報を取得
      if ((@cConf.enable_osap?()) && (bIsHwcntInfo == true))
        aHwcntAccosap = get_all_hwcounter_accosap(aOrgTestScenarios)
      end

      # アプリケーションモードが指定されている場合(1件のみ)
      sAppMode = @cConf.get_app_mode()
      if (!aOrgTestScenarios[0].hProperty[TSR_PRM_PRO_APPMODE].nil?())
        sAppMode = aOrgTestScenarios[0].hProperty[TSR_PRM_PRO_APPMODE]
      end

      # 強制マージする場合は，テストIDとアプリケーションモードと登場する割込み番号を保存
      aAppModeInfo = []
      if (@cConf.enable_forced_merge() == true)
        aOrgTestScenarios.each{|cTestScenario|
          if (cTestScenario.hProperty[TSR_PRM_PRO_APPMODE].nil?())
            aAppModeInfo.push([cTestScenario.sTestID, @cConf.get_app_mode(), cTestScenario.get_exist_intno()])
          else
            aAppModeInfo.push([cTestScenario.sTestID, cTestScenario.hProperty[TSR_PRM_PRO_APPMODE], cTestScenario.get_exist_intno()])
          end
        }
      end

      # コンフィギュレーション設定のためフック，ハードウェアカウンタの情報を渡す
      @cProfileBuilder.set_hook_and_hwcnt_info(hIsHookInfo, bIsHwcntInfo, aHwcntAccosap, sAppMode, aAppModeInfo, sRestartOsap)

      # 共有関数の静的APIを設定
      GRP_SHARED_PROCESS_UNIT.each{|sProcUnitType|
        hProcUnitInfo = get_all_proc_unit_info(aOrgTestScenarios, sProcUnitType)
        if (!hProcUnitInfo.empty?())
          @cProfileBuilder.config_shared_proc_unit(hProcUnitInfo)
        end
      }

      # スタートアップ/シャットダウンフックを含むテストシナリオと
      # 含まないテストシナリオの配列を作成する
      bIsStartupHook  = false
      bIsShutdownHook = false
      aStartupHook  = []
      aShutdownHook = []
      aTestScenarios = []
      # 強制マージの場合，全シナリオに通常の条件分岐を適用する
      if (@cConf.enable_forced_merge() == true)
        aOrgTestScenarios.each{|cTestScenario|
          if (cTestScenario.bCannotMerge == true)
            if ((cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
                (cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
              bIsShutdownHook = true
            end
            if ((cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
                (cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
              aStartupHook.push(cTestScenario)
              bIsStartupHook = true
            else
              aTestScenarios.push(cTestScenario)
            end
          # テストシナリオがマージ可能な場合と，マージ不可能かつシャットダウンフックが登場する場合は
          # 通常のプログラム生成処理とする
          else
            if ((cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
                (cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
              aStartupHook.push(cTestScenario)
              bIsStartupHook = true
            elsif ((cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
                   (cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
              aShutdownHook.push(cTestScenario)
              bIsShutdownHook = true
            else
              aTestScenarios.push(cTestScenario)
            end
          end
        }
      # テストシナリオがマージ不可能な場合
      elsif (aOrgTestScenarios[0].bCannotMerge == true)
        if ((aOrgTestScenarios[0].exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
            (aOrgTestScenarios[0].exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
          bIsShutdownHook = true
        end
        if ((aOrgTestScenarios[0].exist_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
            (aOrgTestScenarios[0].exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
          aStartupHook.push(aOrgTestScenarios[0])
          bIsStartupHook = true
        else
          aTestScenarios.push(aOrgTestScenarios[0])
        end
      # テストシナリオがマージ可能な場合と，マージ不可能かつシャットダウンフックが登場する場合は
      # 通常のプログラム生成処理とする
      else
        aOrgTestScenarios.each{|cTestScenario|
          if ((cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
              (cTestScenario.exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
            aStartupHook.push(cTestScenario)
            bIsStartupHook = true
          elsif ((cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
                 (cTestScenario.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
            aShutdownHook.push(cTestScenario)
            bIsShutdownHook = true
          else
            aTestScenarios.push(cTestScenario)
          end
        }
      end


      # SC3/SC4/全MCの場合，OSAP固有のフックの順序を並び替える
      if ((@cConf.enable_osap?()) && (aOrgTestScenarios.size() > 1) &&
          (@cConf.enable_forced_merge() == false))
        # スタートアップフック：システム定義→OSAP固有(アルファベット順)
        aTemp = aStartupHook.dup()
        aStartupHook = []
        aAddedTestID = []
        aTemp.each{|cTS|
          if (cTS.exist_proc_unit(TSR_OBJ_STARTUP_HOOK) == true)
            aStartupHook.push(cTS)
            aAddedTestID.push(cTS.sTestID)
          end
        }
        aOsapHookId = []
        aTemp.each{|cTS|
          if (cTS.exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true)
            cTS.get_startup_hook_osap_id().each{|sOsap|
              if (!aOsapHookId.include?(sOsap))
                aOsapHookId.push(sOsap)
              end
            }
          end
        }
        aOsapHookId.sort.each{|sOsap|
          aTemp.each{|cTS|
            if (cTS.exist_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true)
              if (cTS.get_startup_hook_osap_id().include?(sOsap) &&
                  !aAddedTestID.include?(cTS.sTestID))
                aStartupHook.push(cTS)
                # マルチコアで複数のコアにOSAP固有フックが存在する場合への対処
                aAddedTestID.push(cTS.sTestID)
              end
            end
          }
        }

        # シャットダウンフック：OSAP固有(アルファベット順)→システム定義
        aTemp = aShutdownHook.dup()
        aShutdownHook = []
        aAddedTestID = []
        aOsapHookId = []
        aTemp.each{|cTS|
          if (cTS.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true)
            cTS.get_shutdown_hook_osap_id().each{|sOsap|
              if (!aOsapHookId.include?(sOsap))
                aOsapHookId.push(sOsap)
              end
            }
          end
        }
        aOsapHookId.sort.each{|sOsap|
          aTemp.each{|cTS|
            if (cTS.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true)
              if (cTS.get_shutdown_hook_osap_id().include?(sOsap) &&
                  !aAddedTestID.include?(cTS.sTestID))
                aShutdownHook.push(cTS)
                # マルチコアで複数のコアにOSAP固有フックが存在する場合への対処
                aAddedTestID.push(cTS.sTestID)
              end
            end
          }
        }

        aTemp.each{|cTS|
          if ((cTS.exist_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) &&
              !aAddedTestID.include?(cTS.sTestID))
            aShutdownHook.push(cTS)
          end
        }
      end


      # プログレスバー用変数初期化
      nCnt = 0
      nTotal = aOrgTestScenarios.size()
      # スタートアップフックを含むテストシナリオのコードを作成する
      if (bIsStartupHook == true)
        aStartupHook.each{|cTestScenario|
          nCnt += 1
          if (@cConf.enable_no_progress_bar_mode())
            $stderr.puts "[AKTG][#{"%5.1f" % (100 * nCnt.to_f / nTotal.to_f)}\% (#{"%4d" % nCnt}/#{"%4d" % nTotal})] #{cTestScenario.sTestID}"
          else
            print_progress("AKTG", cTestScenario.sTestID, nCnt, nTotal)
          end

          @cProfileBuilder.build_startup_hook(cTestScenario)
        }

        # スタートアップフックがあるときはメインタスクの先頭でcp_stateをチェックする
        @cProfileBuilder.build_check_cp_state()
      end

      # 起動後に終了するOSAPが設定されていた場合，メインタスクからTerminateApplicationする
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        aOsapId = []
        aOrgTestScenarios.each{|cTestScenario|
          aOsapId = aOsapId + cTestScenario.check_terminate_restart_osap()
        }
        if (!aOsapId.nil?())
          aOsapId = aOsapId.uniq()
          @cProfileBuilder.build_terminate_osap(aOsapId)
        end
      end

      # メインタスクがダミーリソースを獲得
      @cProfileBuilder.build_get_dummy_resource()

      # 中間コードにテストシナリオごとに必要な情報を追加する
      aTestScenarios.each{|cTestScenario|
        nCnt += 1
        if (@cConf.enable_no_progress_bar_mode())
          $stderr.puts "[AKTG][#{"%5.1f" % (100 * nCnt.to_f / nTotal.to_f)}\% (#{"%4d" % nCnt}/#{"%4d" % nTotal})] #{cTestScenario.sTestID}"
        else
          print_progress("AKTG", cTestScenario.sTestID, nCnt, nTotal)
        end

        @cProfileBuilder.build(cTestScenario)
      }

      # メインタスクがダミーリソースを解放
      @cProfileBuilder.build_release_dummy_resource()


      # 最後のチェックポイントを入れる
      # (シャットダウンフックがある場合はcheck_pointしてShutdownOS，無い場合はcheck_finish)
      @cProfileBuilder.build_finish_cp(bIsShutdownHook)


      # シャットダウンフックを含むテストシナリオのコードを作成する
      if (bIsShutdownHook == true)
        bLastFlg = false
        aShutdownHook.each_with_index{|cTestScenario, nIndex|
          # 最後のみtrueとする
          if (nIndex == (aShutdownHook.size() - 1))
            bLastFlg = true
          end

          nCnt += 1
          if (@cConf.enable_no_progress_bar_mode())
            $stderr.puts "[AKTG][#{"%5.1f" % (100 * nCnt.to_f / nTotal.to_f)}\% (#{"%4d" % nCnt}/#{"%4d" % nTotal})] #{cTestScenario.sTestID}"
          else
            print_progress("AKTG", cTestScenario.sTestID, nCnt, nTotal)
          end

          @cProfileBuilder.build_shutdown_hook(cTestScenario, bLastFlg)
        }
      end


      # プログレスバー用表示のリセット
      if (!@cConf.enable_no_progress_bar_mode())
        finish_progress("AKTG", nTotal)
      end
    end

    #================================================================
    # 概  要: 全テストシナリオにおける指定した処理単位の情報を返す
    #================================================================
    def get_all_proc_unit_info(aTestScenarios, sObjectType)
      check_class(Array, aTestScenarios) # 全テストシナリオデータ
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      hAllObjectInfo = Hash.new()

      # カテゴリ2ISR，ICISR，リスタートタスクはリソース，アクセスOSAPを関連付ける
      if ((sObjectType == TSR_OBJ_C2ISR) || (sObjectType == TSR_OBJ_ICISR) || (sObjectType == TSR_OBJ_RESTART_TASK))
        aTestScenarios.each{|cTestScenario|
          if (cTestScenario.exist_proc_unit(sObjectType) == true)
            hIsrInfo = safe_dup(cTestScenario.get_all_object_info(sObjectType))

            # オブジェクトIDを共有関数に置き換える
            hTempIsrInfo = safe_dup(hIsrInfo)
            hTempIsrInfo.each{|sObjectID, cObjectInfo|
              hIsrInfo.delete(sObjectID)
              hIsrInfo[cObjectInfo.get_common_id()] = cObjectInfo
            }

            # 関連付けされたリソースがあれば追加していく
            hAllObjectInfo.each{|sObjectID, cObjectInfo|
              # 関連付けされたリソースが出てくるまで飛ばす
              if (cObjectInfo.hState[TSR_PRM_RELRES].nil?())
                next
              end

              # 次に追加する対象のISR，リスタートタスクに蓄積したリソースを追加する
              if (hIsrInfo.has_key?(sObjectID))
                if (hIsrInfo[sObjectID].hState[TSR_PRM_RELRES].nil?())
                  hIsrInfo[sObjectID].hState[TSR_PRM_RELRES] = cObjectInfo.hState[TSR_PRM_RELRES]
                else
                  hIsrInfo[sObjectID].hState[TSR_PRM_RELRES].concat(cObjectInfo.hState[TSR_PRM_RELRES])
                end
              end
            }

            # アクセス可能なOSAP定義があれば追加していく
            if (@cConf.is_sc3?() || @cConf.is_sc4?())
              hAllObjectInfo.each{|sObjectID, cObjectInfo|
                # アクセス可能なOSAP定義が出てくるまで飛ばす
                if (cObjectInfo.hState[TSR_PRM_ACCOSAP].nil?())
                  next
                end

                # 次に追加する対象のISR，リスタートタスクに蓄積したOSAP定義を追加する
                if (hIsrInfo.has_key?(sObjectID))
                  if (hIsrInfo[sObjectID].hState[TSR_PRM_ACCOSAP].nil?())
                    hIsrInfo[sObjectID].hState[TSR_PRM_ACCOSAP] = cObjectInfo.hState[TSR_PRM_ACCOSAP]
                  else
                    hIsrInfo[sObjectID].hState[TSR_PRM_ACCOSAP].concat(cObjectInfo.hState[TSR_PRM_ACCOSAP])
                    hIsrInfo[sObjectID].hState[TSR_PRM_ACCOSAP].uniq!()
                  end
                end
              }
            end

            hAllObjectInfo.update(hIsrInfo)
          end
        }
      # その他の処理単位は共通の処理
      elsif (GRP_SHARED_PROCESS_UNIT.include?(sObjectType))
        aTestScenarios.each{|cTestScenario|
          if (cTestScenario.exist_proc_unit(sObjectType) == true)
            hProcUnit = safe_dup(cTestScenario.get_all_object_info(sObjectType))

            # オブジェクトIDを共有関数に置き換える
            hTempProcUnit = safe_dup(hProcUnit)
            hTempProcUnit.each{|sObjectID, cObjectInfo|
              hProcUnit.delete(sObjectID)
              hProcUnit[cObjectInfo.get_common_id()] = cObjectInfo
            }
            hAllObjectInfo.update(hProcUnit)
          end
        }
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      return hAllObjectInfo  # [Hash]オブジェクト情報ハッシュ
    end

    #================================================================
    # 概  要: 全テストシナリオにおけるハードウェアカウンタにアクセス可
    #         能なOSAP一覧を返す
    #================================================================
    def get_all_hwcounter_accosap(aTestScenarios)
      check_class(Array, aTestScenarios) # 全テストシナリオデータ

      aHwcntAccosap = []
      aTestScenarios.each{|cTestScenario|
        if (cTestScenario.exist_hwcnt() == true)
          hCounterInfo = cTestScenario.get_all_object_info(TSR_OBJ_COUNTER)
          hCounterInfo.each_value{|cObjectInfo|
            if (cObjectInfo.is_hardware_counter?() && !cObjectInfo.hState[TSR_PRM_ACCOSAP].nil?())
              cObjectInfo.hState[TSR_PRM_ACCOSAP].each{|sOsap|
                if (!aHwcntAccosap.include?(sOsap))
                  aHwcntAccosap.push(sOsap)
                end
              }
              # ハードウェアカウンタは1テストに1つなので，1つ処理したら終了
              break
            end
          }
        end
      }

      return aHwcntAccosap  # [Array]OSAP一覧
    end
  end
end
