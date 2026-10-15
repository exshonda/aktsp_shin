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
# $Id: Do_PostCondition.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/test_scenario/Condition.rb"
require "aktf/bin/test_scenario/Do_PostCondition.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Do_PostCondition
  # 概    要: do，post_conditionの情報を処理するクラス
  #===================================================================
  class Do_PostCondition < Condition
    include CommonModule

    attr_accessor :nSeqNum, :hDo
    attr_reader :nTimeTick, :aDeleteObj

    #=================================================================
    # 概  要: do，post_conditionの初期化
    #=================================================================
    def initialize(sTestID, hScenarioDo, hScenarioPost, nSeqNum, cPreCondition, hProperty)
      check_class(String, sTestID)              # テストID
      check_class(Hash, hScenarioDo, true)      # do
      check_class(Hash, hScenarioPost, true)    # post_condition
      check_class(Integer, nSeqNum)             # シーケンス番号
      check_class(PreCondition, cPreCondition)  # PreCondition
      check_class(Hash, hProperty)              # プロパティ

      @nSeqNum                = nSeqNum
      @cCallerObject          = nil        # システムサービス発行オブジェクト
      @hDo                    = {}
      @aSpecifiedDoAttributes = []
      @aDeleteObj             = cPreCondition.aDeleteObj

      super(sTestID, hProperty)

      # 構造チェック
      aErrors = []
      begin
        basic_post_check(hScenarioPost)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end
      check_error(aErrors)

      # 補完
      if (hScenarioDo.nil?())
        hScenarioDo = {}
      end
      if (hScenarioPost.nil?())
        hScenarioPost = {}
      end

      begin
        basic_attribute_check(hScenarioDo)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end
      check_error(aErrors)

      # エラーがなければdo，post_conditionの情報格納
      store_do_info(hScenarioDo, cPreCondition)
      store_condition_info(hScenarioPost, cPreCondition.hObjectType, sTestID)
    end

    #=================================================================
    # 概  要: doの情報を格納
    #=================================================================
    def store_do_info(hScenarioDo, cPreCondition)
      check_class(Hash, hScenarioDo)            # do
      check_class(PreCondition, cPreCondition)  # PreCondition

      # 格納
      @aSpecifiedDoAttributes = hScenarioDo.keys()
      hScenarioDo.each{|atr, val|
        case atr
        when TSR_PRM_ID
          if ((@cConf.enable_icisr_convert?()) && @@hC2isrToIcisr.has_key?(val))
            val = @@hC2isrToIcisr[val][:sObjectID]
          end
          @hDo[atr] = val
          @cCallerObject = cPreCondition.hAllObject[val]
        else
          @hDo[atr] = val
        end
      }
    end

    #=================================================================
    # 概  要: 処理単位情報をまとめてエレメントとして返す
    #=================================================================
    def get_proc_units(cElement)
      @hAllObject.each{|sObjectID, cObjectInfo|
        # 処理単位のみ
        if (GRP_PROCESS_UNIT_ALL.include?(cObjectInfo.sObjectType))
          # 起動要求のあるタスクはbootcntを加算しておく
          if (!cObjectInfo.hState[TSR_PRM_ACTCNT].nil?() && cObjectInfo.hState[TSR_PRM_ACTCNT] > 1)
            cElement.set_proc_unit(sObjectID, (cObjectInfo.hState[TSR_PRM_BOOTCNT] + cObjectInfo.hState[TSR_PRM_ACTCNT] - 1))
          else
            cElement.set_proc_unit(sObjectID, cObjectInfo.hState[TSR_PRM_BOOTCNT])
          end
        end
      }
    end

    #=================================================================
    # 概  要: Doの処理をIMCodeElementクラスにまとめて返す
    #=================================================================
    def gc_do(cPrevCondition)
      check_class(Condition, cPrevCondition)  # 前のコンディション

      cElement = IMCodeElement.new()

      # 直前のコンディションにおけるbootcntで実行するため，
      # 処理単位情報は直前のコンディションから取得する
      cObjectInfo = cPrevCondition.get_object_info(@hDo[TSR_PRM_ID])
      hProcUnitInfo = get_proc_unit_info(cObjectInfo)

      # コメント出力
      cElement.set_comment(hProcUnitInfo, "#{TSR_UNS_DO}#{@nSeqNum}")

      # finishフラグがtrueの場合，ここでカーネルが終了するため，メッセージを出力する
      if (@hDo[TSR_PRM_FINISH] == true)
        # テスト終了のログを出力
        cElement.set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_0}(\"#{@sTestID}: OK\")")
        if (@cConf.enable_check_stack_usage() == true)
          cElement.set_print_stack_usage(hProcUnitInfo)
        end
        # C++test終了
        if (@cConf.is_enable_cpptest?() && @cConf.is_cpptest_use_buffer?())
          cElement.set_code(hProcUnitInfo, "#{CPPTEST_FINAL}")
        end
        cElement.set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_0}(\"#{AKTG_FINISH_MESSAGE}\")")

        # プレタスク/ポストタスクフックの場合は，bootcntをリセットする
        if (GRP_PROCESS_UNIT_PRETASK_POSTTASK.include?(cObjectInfo.sObjectType))
          cElement.set_code(hProcUnitInfo, "#{cObjectInfo.get_common_id()}_#{VAR_BOOTCNT} = #{cObjectInfo.get_common_id()}_#{AKTG_ENUM_INVALID}")
        end
      end

      # GCOV取得の開始(gcovがtrueの場合のみ)
      if (@cConf.is_enable_gcov?() && (@hDo[TSR_PRM_GCOV] == true))
        cElement.set_code(hProcUnitInfo, FNC_GCOV_C_RESUME)
      end

      # C++test用カバレッジ取得の開始(doの処理のみ)
      if (@cConf.is_enable_cpptest?() && @cConf.is_cpptest_only_do?() && (@hDo[TSR_PRM_GCOV] == true))
        cElement.set_code(hProcUnitInfo, CPPTEST_ENABLE)
      end

      # syssrv部
      @hDo[TSR_PRM_REPEAT].times{|nCnt|
        if (@hDo.has_key?(TSR_PRM_RETTYPE) && @hDo.has_key?(TSR_PRM_RETVAL))
          cElement.set_syscall(hProcUnitInfo, @hDo[TSR_PRM_SYSSRV], @hDo[TSR_PRM_RETVAL], @hDo[TSR_PRM_RETTYPE])
        else
          cElement.set_code(hProcUnitInfo, @hDo[TSR_PRM_SYSSRV])
        end
        
        # ASSERTマクロの挿入
        if (@sTestID =~ /ChainTask_normal/ && @hDo[TSR_PRM_SYSSRV] =~ /ChainTask\(/)
          # 正常系ChaintaskテストでChainTaskを呼び出した場合
          cElement.set_assert_ter_chain(hProcUnitInfo)
        elsif (@sTestID =~ /TerminateTask_normal/ && @hDo[TSR_PRM_SYSSRV] =~ /TerminateTask\(\)/)
          # 正常系TerminatetaskテストでTerminateTaskを呼び出した場合
          cElement.set_assert_ter_chain(hProcUnitInfo)
        end
      }

      # finishフラグがtrueの場合，ここでカーネルが終了する
      if (@hDo[TSR_PRM_FINISH] == true)
        # doの処理からカーネルが終了するまで遅延がある場合に備えて遅延処理を入れる
        cElement.set_delay_loop(hProcUnitInfo, AKTG_WAIT_OS_SHUTDOWN)
        # 不具合でカーネルが終了しなかった場合に備え不正なチェックポイントを入れておく
        cElement.set_checkpoint_zero(hProcUnitInfo)
      end

      # GCOV取得の中断(gcovがtrueの場合のみ)
      if (@cConf.is_enable_gcov?() && (@hDo[TSR_PRM_GCOV] == true))
        # doの後で実行中の処理単位から行う
        cElement.set_code(get_proc_unit_info(@cActivate, @cRunning), FNC_GCOV_C_PAUSE)
      end

      # C++test用カバレッジ取得の中断(doの処理のみ)
      if (@cConf.is_enable_cpptest?() && @cConf.is_cpptest_only_do?() && (@hDo[TSR_PRM_GCOV] == true))
        # doの後で実行中の処理単位から行う
        cElement.set_code(get_proc_unit_info(@cActivate, @cRunning), CPPTEST_DISABLE)
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: 次のコンディションで起動するACTIVATEなISRが存在する場合，
    #         起動を待つコードを返す
    #=================================================================
    def gc_wait_isr_activate(cPrevCondition)
      check_class(Condition, cPrevCondition) # 前のコンディション

      cElement = IMCodeElement.new()

      # シングルコア
      if (@cConf.is_single?())
        wait_isr_activate(cElement, cPrevCondition.cRunning, cPrevCondition.cActivate, @cRunning, @cActivate)
      # マルチコア
      else
        @aCoreid.each{|nCoreid|
          wait_isr_activate(cElement, cPrevCondition.aRunning[nCoreid], cPrevCondition.aActivate[nCoreid], @aRunning[nCoreid], @aActivate[nCoreid])
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における次のコンディションで起動するACTIVATEなISR
    #         が存在する場合，起動を待つコードを返す
    #=================================================================
    def wait_isr_activate(cElement, cPrevRunning, cPrevActivate, cRunning, cActivate)
      check_class(IMCodeElement, cElement, true)      # IMCodeElementクラスのインスタンス
      check_class(ProcessUnit, cPrevRunning, true)    # 前のコンディションの実行状態タスク情報
      check_class(ProcessUnit, cPrevActivate, true)   # 前のコンディションの実行状態非タスク情報
      check_class(ProcessUnit, cRunning, true)        # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)       # 実行状態非タスク情報

      # ISRが存在する場合のみ
      if (!cActivate.nil?() && GRP_PROCESS_UNIT_ISR.include?(cActivate.sObjectType))
        hActivateInfo = get_proc_unit_info(cActivate)
        hRunningInfo = get_proc_unit_info(cRunning)
        # 信頼関数対応
        if (@hActiveTfn.has_key?(hRunningInfo[:id]))
          cActivateTfn = @hActiveTfn[hRunningInfo[:id]]
          hRunningInfo = get_proc_unit_info(cActivateTfn)
        end

        # 前のコンディションに非タスクがいない場合，タスクから起動を待つ
        if (cPrevActivate.nil?())
          cElement.set_checkpoint(hActivateInfo)
          cElement.wait_checkpoint(hRunningInfo, hActivateInfo[:coreid])
        # 異なる処理単位からISRがACTIVATEになった場合は，前の非タスクから起動を待つ
        elsif (cPrevActivate.sObjectID != cActivate.sObjectID)
          cElement.set_checkpoint(hActivateInfo)
          hPrevActivateInfo = get_proc_unit_info(cPrevActivate)
          # 信頼関数対応
          if (@hActiveTfn.has_key?(hPrevActivateInfo[:id]))
            cActivateTfn = @hActiveTfn[hPrevActivateInfo[:id]]
            hPrevActivateInfo = get_proc_unit_info(cActivateTfn)
          end
          cElement.wait_checkpoint(hPrevActivateInfo, hActivateInfo[:coreid])
        # 同じISRが実行中の場合，何もしない
        else
          return
        end
      end
    end

    #=================================================================
    # 概  要: 実行状態のタスクが存在しないマスタコアに，実行状態のタス
    #         クが発生した場合の切替処理のコードを返す
    #=================================================================
    def gc_switch_running_task(cPrevCondition)
      check_class(Condition, cPrevCondition) # 前のコンディション

      cElement = IMCodeElement.new()

      # 前のコンディションで，マスタコアに実行状態の処理単位が存在しない かつ
      # 今回のコンディションで，マスタコアに実行状態のタスクが存在する場合のみ
      # (タスク以外はgc_wait_isr_activateで待つことが可能)
      if (cPrevCondition.aActivateProcUnit[@nMasterCoreid].nil?() && !@cRunning.nil?())
        hMainTaskInfo = get_proc_unit_info()

        # メインタスクを最低優先度とする
        cElement.set_syscall(hMainTaskInfo, "#{SS_REL_RES}(#{AKTG_DUMMY_RES})")

        # 今回起動するタスクにチェックポイントを入れ，メインタスクから待つ
        hTaskInfo = get_proc_unit_info(@cRunning)
        cElement.set_checkpoint(hTaskInfo)
        cElement.wait_checkpoint(hMainTaskInfo, @cRunning.hState[TSR_PRM_COREID])

        # 次にメインタスクが実行状態となったときに再度ダミーリソースを獲得する
        cElement.set_syscall(hMainTaskInfo, "#{SS_GET_RES}(#{AKTG_DUMMY_RES})")
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 割込み禁止状態の解除をするコードを返す
    #=================================================================
    def gc_lastpost_interrupt()
      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_INT_STATE) && cObjectInfo.is_state_changed?())
          if (cObjectInfo.is_dis_all_int?())
            cProcUnit = get_object_info(cObjectInfo.hState[TSR_PRM_INT_STATE][0][TSR_STT_DIS_ALL_INT])
            # DisAllは発行した処理単位が既に終了している可能性がある
            if (GRP_ACTIVATE.include?(cProcUnit.hState[TSR_PRM_STATE]))
              hProcUnitInfo = get_proc_unit_info(cProcUnit)
            else
              if (@cConf.is_single?)
                hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
              else
                nCoreid = cProcUnit.hState[TSR_PRM_COREID]
                hProcUnitInfo = get_proc_unit_info(@aActivateProcUnit[nCoreid])
              end
            end
            cElement.set_code(hProcUnitInfo, "#{SS_ENA_ALL_INT}()")
          elsif (cObjectInfo.is_sus_all_int?() || cObjectInfo.is_sus_os_int?())
            # 逆順に解除していく
            cObjectInfo.hState[TSR_PRM_INT_STATE].reverse.each{|hIntState|
              if (hIntState.has_key?(TSR_STT_SUS_ALL_INT))
                cProcUnit = get_object_info(hIntState[TSR_STT_SUS_ALL_INT])
                # スピンロックによる割込み禁止は，スピンロック解放で許可するので，ここでは何もしない
                if (cProcUnit.sObjectType != TSR_OBJ_SPINLOCK)
                  hProcUnitInfo = get_proc_unit_info(cProcUnit)
                  cElement.set_code(hProcUnitInfo, "#{SS_RSM_ALL_INT}()")
                end
              else
                cProcUnit = get_object_info(hIntState[TSR_STT_SUS_OS_INT])
                # スピンロックによる割込み禁止は，スピンロック解放で許可するので，ここでは何もしない
                if (cProcUnit.sObjectType != TSR_OBJ_SPINLOCK)
                  hProcUnitInfo = get_proc_unit_info(cProcUnit)
                  cElement.set_code(hProcUnitInfo, "#{SS_RSM_OS_INT}()")
                end
              end
            }
          end

          bChk = true
        end
      }
      # 割込み禁止状態でなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: スピンロックを獲得している処理単位の解放処理をするコード
    #         を返す
    #=================================================================
    def gc_lastpost_release_spinlock()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) == true) && 
            (cObjectInfo.hState[TSR_PRM_GETSPN] != nil))
            # スピンロック解放処理(逆順に解放していく)
            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            cObjectInfo.hState[TSR_PRM_GETSPN].reverse.each{|sSpn|
              # スピンロック個数拡張
              if (sSpn =~ /\w+\/\d+-\d+\//)
                # 拡張する数分のスピンロックを解放
                cSpinLock = get_object_info(sSpn)
                cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
                cElement.set_code(hProcUnitInfo, "for (i = #{cSpinLock.nExNum - 1}; i >= 0; i--) {", false)
                cElement.set_indent()
                cElement.set_syscall(hProcUnitInfo, "#{SS_REL_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                cElement.unset_indent()
                cElement.set_code(hProcUnitInfo, "}", false)
              else
                cElement.set_syscall(hProcUnitInfo, "#{SS_REL_SPN}(#{sSpn})")
              end
            }
            bChk = true
        end
      }
      # スピンロックを獲得している処理単位が存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: リソースを獲得している処理単位の解放処理をするコードを返す
    #=================================================================
    def gc_lastpost_release_resource()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((GRP_PROCESS_UNIT_RESOURCE.include?(cObjectInfo.sObjectType) == true) && 
            (cObjectInfo.hState[TSR_PRM_GETRES] != nil))
            # リソース解放処理(逆順に解放していく)
            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            cObjectInfo.hState[TSR_PRM_GETRES].reverse.each{|sRes|
              # 内部リソースは解放できない
              cRes = get_object_info(sRes)
              if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
                cElement.set_syscall(hProcUnitInfo, "#{SS_REL_RES}(#{sRes})")
                bChk = true
              end
            }
        end
      }
      # リソースを獲得している処理単位が存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: 全タスクの最後にTerminateTaskを実行するコードを返す
    #=================================================================
    def gc_lastpost_terminate_each_task()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()

      # maintask_waitがtrueのときは，ここでメインタスクの待ち状態を解除する
      if (@hProperty[TSR_PRM_MAINTASK_WAIT] == true)
        hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
        cElement.set_syscall(hProcUnitInfo, "#{SS_SET_EVT}(#{AKTG_MAIN_TASK}, #{AKTG_DUMMY_EVT})")
        # 次にmaintask_waitがtrueとなるテストのためにイベントはクリアしておく
        hMainTaskInfo = get_proc_unit_info()
        cElement.set_syscall(hMainTaskInfo, "#{SS_CLR_EVT}(#{AKTG_DUMMY_EVT})")
      end

      # シングルコア
      if (@cConf.is_single?())
        terminate_each_task(cElement, @hTask, @cRunning, @cActivate, @aInternalResID, @hInternalResPri)
      # マルチコア
      else
        @aCoreid.each{|nCoreid|
          terminate_each_task(cElement, @aTaskEachCore[nCoreid], @aRunning[nCoreid], @aActivate[nCoreid], @aInternalResIDEachCore[nCoreid], @aInternalResPriEachCore[nCoreid])
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における全タスクの最後にTerminateTaskを実行する
    #         コードを返す
    #=================================================================
    def terminate_each_task(cElement, hTask, cRunning, cActivate, aInternalResID, hInternalResPri)
      check_class(IMCodeElement, cElement, true)  # IMCodeElementクラスのインスタンス
      check_class(Hash, hTask)                    # 1コア内のタスク情報
      check_class(ProcessUnit, cRunning, true)    # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)   # 実行状態非タスク情報
      check_class(Array, aInternalResID)          # 内部リソースIDリスト
      check_class(Hash, hInternalResPri)          # 内部リソース獲得時の優先度リスト

      # 実行，実行可能を合わせたタスクの初期優先度でソートした配列を作成する
      # (この時点でC2ISRの終了，標準(リンク)リソースの解放が終わっているため)
      hOrderedTask = {}
      aResourceTask = []
      hTask.each{|sObjectID, cObjectInfo|
        sTaskState = cObjectInfo.hState[TSR_PRM_STATE]
        nTaskIniPri = cObjectInfo.hState[TSR_PRM_INIPRI]

        if ((sTaskState == TSR_STT_RUNNING) || (sTaskState == TSR_STT_READY))
          # 実行状態のタスクの場合
          if (sTaskState == TSR_STT_RUNNING)
            # ノンプリだった場合は，全体の先頭に入れるため，ここでは除外
            if (cRunning.hState[TSR_PRM_SPOLICY] == TSR_STT_SCHNON)
              next
            end
          # 実行可能状態のタスクの場合
          else
            # 実行状態を各優先度の先頭とするためにREADYのporderを1から始まるようシフトする
            cObjectInfo.hState[TSR_PRM_PORDER] += 1
          end

          # リソースを保持しているタスクは後で先頭に入れるため，一時保存
          # (同一初期優先度のタスクが複数存在しても，リソースを獲得しているのは1タスクしかあり得ない)
          if (!cObjectInfo.hState[TSR_PRM_GETRES].nil?())
            aResourceTask.push(cObjectInfo)
          else
            # キーが無ければ配列で初期化する
            if (!hOrderedTask.has_key?(nTaskIniPri))
              hOrderedTask[nTaskIniPri] = []
            end

            hOrderedTask[nTaskIniPri][cObjectInfo.hState[TSR_PRM_PORDER]] = cObjectInfo
          end
        end
      }

      # リソースを保持していたタスクを各優先度の先頭に入れる
      aResourceTask.each{|cTask|
        # タスクが内部リソースを獲得している場合は，内部リソース獲得による優先度にする
        # (内部リソースは解放できていないため)
        nTaskIniPri = cTask.hState[TSR_PRM_INIPRI]
        if (aInternalResID.include?(cTask.hState[TSR_PRM_GETRES][0]))
          nTaskIniPri = hInternalResPri[cTask.hState[TSR_PRM_GETRES][0]]

          # 内部リソースを保持しているタスクが多重起動要求(n)がある場合，
          # リソース獲得時の優先度の先頭にactcnt:1，
          # 初期優先度の末尾にactcnt:n-1のインスタンスを追加
          if (cTask.hState[TSR_PRM_ACTCNT] > 1)
            cTemp = cTask.dup()
            cTask.hState[TSR_PRM_ACTCNT] = 1
            cTemp.hState[TSR_PRM_ACTCNT] -= 1
            cTemp.hState[TSR_PRM_BOOTCNT] += 1
            # キーが無ければ配列で初期化する
            if (!hOrderedTask.has_key?(cTemp.hState[TSR_PRM_INIPRI]))
              hOrderedTask[cTemp.hState[TSR_PRM_INIPRI]] = []
            end
            hOrderedTask[cTemp.hState[TSR_PRM_INIPRI]].push(cTemp)
          end
        end

        # キーが無ければ配列で初期化する
        if (!hOrderedTask.has_key?(nTaskIniPri))
          hOrderedTask[nTaskIniPri] = []
        end
        hOrderedTask[nTaskIniPri].unshift(cTask)
      }

      # 優先度順に並べた配列に，porder順の配列を格納する
      aOrderedTask = []
      hOrderedTask.each{|nPri, aTask|
        aTask.delete(nil)
        aOrderedTask[nPri] = aTask
      }

      # READYのタスクが存在しない優先度を取り除く
      aOrderedTask.delete(nil)

      # 優先度の高いほうから終了していくため反転
      aOrderedTask.reverse!()

      # ネストした配列を平滑化する
      aOrderedTask.flatten!()

      # 実行状態のタスクがノンプリだった場合は，配列の先頭に入れる
      nActRunPri = AKTG_INVALID_PRI
      if (!cRunning.nil?() && (cRunning.hState[TSR_PRM_SPOLICY] == TSR_STT_SCHNON))
        aOrderedTask.unshift(cRunning)
        # 多重起動要求がある場合は優先度を保持
        if (cRunning.hState[TSR_PRM_ACTCNT] > 1)
          nActRunPri = cRunning.hState[TSR_PRM_INIPRI]
        end
      end

      # 多重起動要求ありのタスクを終了させる
      # (チェックポイントを入れられるのは起動順がporderで確定できるNOS仕様のみ)
      if (@cConf.is_target_spec_nos?())
        # 配列をコピー
        aTempTask = aOrderedTask.dup()
        aOrderedTask = []

        # 実行状態のタスクがノンプリかつ多重起動要求(n)がある場合，
        # 先頭にactcnt:1，対象優先度の先頭にactcnt:n-1のインスタンスを追加
        if (nActRunPri != AKTG_INVALID_PRI)
          # 先頭のタスクを削除
          aTempTask.shift()

          # actcntを-1して対象優先度の先頭へ登録
          cTemp = cRunning.dup()
          cTemp.hState[TSR_PRM_ACTCNT] -= 1
          cTemp.hState[TSR_PRM_BOOTCNT] += 1
          bAddChk = false
          # 同一優先度の末尾へ登録
          aTempTask.each_with_index{|cTask, nIndex|
            if (cTask.hState[TSR_PRM_INIPRI] < cTemp.hState[TSR_PRM_INIPRI])
              aTempTask.insert(nIndex, cTemp)
              bAddChk = true
              break
            end
          }
          # 全体の末尾となる場合
          if (bAddChk == false)
            aTempTask.push(cTemp)
          end

          # actcntを1にして先頭に再登録
          cTemp = cRunning.dup()
          cTemp.hState[TSR_PRM_ACTCNT] = 1
          aTempTask.unshift(cTemp)
        end

        nTaskNum = aTempTask.size()
        nCurPri = AKTG_INVALID_PRI
        # 多重起動要求ありのタスクを検索
        (0..(nTaskNum - 1)).each{|nCnt|
          # 既に追加済みのタスクは除外
          if (nCurPri == aTempTask[nCnt].hState[TSR_PRM_INIPRI])
            next
          end

          # 起動要求が2以上の場合
          if (aTempTask[nCnt].hState[TSR_PRM_ACTCNT] > 1)
            # タスクをまとめる対象の優先度を更新
            nCurPri = aTempTask[nCnt].hState[TSR_PRM_INIPRI]

            aSamePriTask = []
            aSamePriTask.push(aTempTask[nCnt])

            # まだ後続のタスクが存在する場合，優先度が同じタスクをまとめる
            if (nTaskNum != (nCnt + 1))
              (nCnt..(nTaskNum - 2)).each{|nCnt2|
                if (aTempTask[nCnt2].hState[TSR_PRM_INIPRI] == aTempTask[nCnt2 + 1].hState[TSR_PRM_INIPRI])
                  aSamePriTask.push(aTempTask[nCnt2 + 1])
                else
                  break
                end
              }
            end

            # 1回目の終了(全タスクが対象)
            aSamePriTask.each{|cTask|
              aOrderedTask.push(cTask.dup())
              cTask.hState[TSR_PRM_ACTCNT] -= 1
            }

            # 2回目の終了(多重起動要求のあるタスクのみ)
            nEnd = 0
            nSamePriNum = aSamePriTask.size()
            while (nEnd != nSamePriNum)
              # まとめたすべてのタスクの起動要求がなくなるまで繰り返す
              nEnd = 0
              aSamePriTask.each{|cTask|
                if (cTask.hState[TSR_PRM_ACTCNT] >= 1)
                  # bootcntを加算して，起動後すぐに終了させる処理を要求数分追加する
                  cTask.hState[TSR_PRM_BOOTCNT] += 1
                  aOrderedTask.push(cTask.dup())
                  cTask.hState[TSR_PRM_ACTCNT] -= 1
                else
                  nEnd += 1
                end
              }
            end

          else
            # 起動要求が1の場合はそのまま追加
            aOrderedTask.push(aTempTask[nCnt].dup())
          end
        }
      end

      # 順番にチェックポイントを実行して，TerminateTaskを実行する
      aOrderedTask.each{|cObjectInfo|
        if ((cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RUNNING) && 
            !cActivate.nil?() && (cActivate.sObjectType == TSR_OBJ_POSTTASK_HOOK))
          # ポストタスクフックが起動している場合のRUNNINGのタスクはTerminateTaskの必要はない
        elsif (cObjectInfo.bUnderPostTaskHook == true)
          # ポストタスクフックが起動した後に実行状態となっているタスクはTerminateTaskの必要はない
        else
          hProcUnitInfo = get_proc_unit_info(cObjectInfo)
          # (チェックポイントを入れられるのは起動順がporderで確定できるNOS仕様のみ)
          if (@cConf.is_target_spec_nos?())
            cElement.set_checkpoint(hProcUnitInfo)
          end
          cElement.set_syscall(hProcUnitInfo, "#{SS_TER_TSK}()")
        end
      }
    end
    private :terminate_each_task

    #=================================================================
    # 概  要: 起動要求が2以上となっているタスクを終了させるコードを返す
    #=================================================================
    def gc_lastpost_terminate_queueing_task()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()

      bChk = false
      # bootcntを加算して，起動後すぐに終了させる処理を要求数分追加する
      @hTask.each{|sObjectID, cObjectInfo|
        if (!cObjectInfo.hState[TSR_PRM_ACTCNT].nil?() && (cObjectInfo.hState[TSR_PRM_ACTCNT] > 1))
          (cObjectInfo.hState[TSR_PRM_ACTCNT] - 1).times{
            cObjectInfo.hState[TSR_PRM_BOOTCNT] += 1
            hProcUnitInfo = {:id => sObjectID, :coreid => cObjectInfo.hState[TSR_PRM_COREID], :bootcnt => cObjectInfo.hState[TSR_PRM_BOOTCNT]}
            cElement.set_syscall(hProcUnitInfo, "#{SS_TER_TSK}()")
          }
          bChk = true
        end
      }
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: イベント待ち状態となっているタスクを終了させるコードを返す
    #=================================================================
    def gc_lastpost_terminate_waiting_task()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()

      bChk = false
      @hTask.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_WAITING)
          hProcUnitInfo = get_proc_unit_info(cObjectInfo)
          hMainTaskInfo = get_proc_unit_info()

          # 信頼関数が起動しているWAITINGへの対応
          if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
            sEvt = @hActiveTfn[hProcUnitInfo[:id]].hState[TSR_PRM_WAIEVT]
          else
            sEvt = cObjectInfo.hState[TSR_PRM_WAIEVT]
          end

          # メインタスクから対象タスクを待ち解除するためのSetEventを発行
          cElement.set_syscall(hMainTaskInfo, "#{SS_SET_EVT}(#{sObjectID}, #{sEvt})")

          # メインタスクの優先度を下げて，対象タスクへディスパッチ
          # (対象タスクが他コアの場合は不要)
          if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
            cElement.set_syscall(hMainTaskInfo, "#{SS_REL_RES}(#{AKTG_DUMMY_RES})")
          end

          # 待ち解除後，対象タスクはTerminateTaskして，メインタスクに戻ってくる
          cElement.set_checkpoint(hProcUnitInfo)
          cElement.set_syscall(hProcUnitInfo, "#{SS_TER_TSK}()")

          # メインタスクの優先度を戻す
          # (対象タスクが他コアの場合は不要)
          if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
            cElement.set_syscall(hMainTaskInfo, "#{SS_GET_RES}(#{AKTG_DUMMY_RES})")
          end

          # 対象タスクが休止状態となるまで待つ
          # (対象タスクが自コアの場合は不要)
          if (cObjectInfo.hState[TSR_PRM_COREID] != @nMasterCoreid)
            if (cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
              sObjectID = cObjectInfo.get_common_id()
            end
            cElement.set_state_sync(hMainTaskInfo, sObjectID, TSR_STT_SUSPENDED, AKTG_SYNC_WAIT_TERMINATE_WAITING_TASK_SYNC)
          end

          bChk = true
        end
      }
      # イベント待ちタスクが存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 動作状態のスケジュールテーブルを停止させるコードを返す
    #=================================================================
    def gc_lastpost_stop_schedule_table()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()
      hMainTaskInfo = get_proc_unit_info()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_SCHEDULE_TABLE) &&
            (cObjectInfo.hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_STOPPED && cObjectInfo.hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_NEXT))
          cElement.set_syscall(hMainTaskInfo, "#{SS_STP_SCHTBL}(#{sObjectID})")

          bChk = true
        end
      }
      # 動作状態のアラームがなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 動作状態のアラームを停止させるコードを返す
    #=================================================================
    def gc_lastpost_stop_alarm()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()
      hMainTaskInfo = get_proc_unit_info()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_ALARM) &&
            (cObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET))
          cElement.set_syscall(hMainTaskInfo, "#{SS_CAN_ALM}(#{sObjectID})")

          bChk = true
        end
      }
      # 動作状態のアラームがなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからテストID完了メッセ
    #         ージ出力するコードを返す
    #=================================================================
    def gc_lastpost_test_end_message(bCannotMerge)
      check_class(Bool, bCannotMerge)  # マージ可能なテストシナリオかどうか

      cElement  = IMCodeElement.new()

      cActiveProcUnit = nil
      if (@cConf.is_single?())
        if (!@cActivate.nil?())
          cActiveProcUnit = @cActivate
        elsif (!@cRunning.nil?())
          cActiveProcUnit = @cRunning
        end
      else
        # マルチコアの場合，いずれかのコアで実行中の処理単位から出力する
        @aCoreid.each{|nCoreid|
          if (!@aActivate[nCoreid].nil?())
            cActiveProcUnit = @aActivate[nCoreid]
            break
          end
        }
      end

      # スタートアップ/シャットダウンフック状態もしくはマージ不可の場合に実行
      # (マージ不可では，スタートアップ/シャットダウンフック以外が最後のコンディションで
      #  実行状態となっている可能性がある)
      if (!cActiveProcUnit.nil?() && ((@lKernelState != :KERNELBOOT) || (bCannotMerge == true)))
        hProcUnitInfo = get_proc_unit_info(cActiveProcUnit)
        cElement.set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_0}(\"#{@sTestID}: OK\")")
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1件のみのテストケースにおけるシャットダウンフック終了処理
    #         のコードを返す
    #=================================================================
    def gc_lastpost_shutdown_hook_in_single_test()
      cElement = IMCodeElement.new()

      cActivate = nil
      if (@cConf.is_single?())
        cActivate = @cActivate
      else
        # マルチコアの場合，マスタコアの処理単位から出力する
        if (!@aActivate[@nMasterCoreid].nil?())
          cActivate = @aActivate[@nMasterCoreid]
        else
          # マスタコアに実行中の処理単位が存在しなければ，いずれかのコアで実行中の処理単位から出力する
          @aCoreid.each{|nCoreid|
            if (!@aActivate[nCoreid].nil?())
              cActivate = @aActivate[nCoreid]
              break
            end
          }
        end
      end

      # シャットダウンフック状態のみ実行
      # (スタートアップフックの場合，mainタスクが起動するので不要)
      if (!cActivate.nil?() && (@lKernelState == :SHUTDOWNHOOK || @lKernelState == :SHUTDOWNHOOK_OSAP))
        hProcUnitInfo = get_proc_unit_info(cActivate)

        if (@cConf.enable_check_stack_usage() == true)
          cElement.set_print_stack_usage(hProcUnitInfo)
        end

        # 正常の場合のみ終了メッセージを出力する
        cElement.set_local_var(hProcUnitInfo[:id], VAR_STATE, TYP_UINT8)
        cElement.set_code(hProcUnitInfo, "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
        cElement.set_code(hProcUnitInfo, "if (#{VAR_STATE} == #{TSR_STT_TRUE}) {", false)
        cElement.set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_0}(\"#{AKTG_FINISH_MESSAGE}\")")
        # C++test終了
        if (@cConf.is_enable_cpptest?() && @cConf.is_cpptest_use_buffer?())
          cElement.set_code(hProcUnitInfo, "#{AKTG_TB}#{CPPTEST_FINAL}")
        end
        cElement.set_code(hProcUnitInfo, "}", false)

        # GCOV取得の終了
        if (@cConf.is_enable_gcov?())
          cElement.set_code(hProcUnitInfo, FNC_GCOV_C_RESUME)
          cElement.set_code(hProcUnitInfo, FNC_GCOV_C_DUMP)
        end
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 各フックのbootcntをクリアするコードを返す
    #=================================================================
    def gc_lastpost_clear_hook_bootcnt()
      cElement = IMCodeElement.new()

      aActivateList = []
      if (@cConf.is_single?())
        aActivateList.push(@cActivate)
      else
        aActivateList = @aActivate
      end

      bChk = false
      aActivateList.each{|aActivate|
        if (!aActivate.nil?())
          if ((aActivate.sObjectType == TSR_OBJ_PRETASK_HOOK) ||
              (aActivate.sObjectType == TSR_OBJ_POSTTASK_HOOK))
            hProcUnitInfo = get_proc_unit_info(aActivate)
            sCommonID = aActivate.get_common_id()
            cElement.set_code(hProcUnitInfo, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{AKTG_ENUM_INVALID}")

            bChk = true
          end
        end
      }
      # 対象フックがなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 次のコンディションのフックの状態に合わせてbootcntを操作す
    #         るコードを返す
    #=================================================================
    def gc_set_hook_bootcnt(cPrevCondition)
      check_class(Condition, cPrevCondition) # 前のコンディション

      cElement = IMCodeElement.new()

      # シングルコア
      if (@cConf.is_single?())
        cPrevActiveObject = cPrevCondition.get_prev_actvate_running()
        set_hook_bootcnt(cElement, cPrevCondition.cRunning, cPrevActiveObject, @cRunning, @cActivate)
      # マルチコア
      else
        @aCoreid.each{|nCoreid|
          bMasterCore = false
          if (nCoreid == @nMasterCoreid)
            bMasterCore = true
          end
          cPrevActiveObject = cPrevCondition.get_prev_actvate_running(nCoreid)
          set_hook_bootcnt(cElement, cPrevCondition.aRunning[nCoreid], cPrevActiveObject, @aRunning[nCoreid], @aActivate[nCoreid], nCoreid)
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における次のコンディションのフックの状態に合わせて
    #         bootcntを操作するコードを返す
    #=================================================================
    def set_hook_bootcnt(cElement, cPrevRunning, cPrevActiveObject, cRunning, cActivate, nCoreid = nil)
      check_class(IMCodeElement, cElement, true)         # IMCodeElementクラスのインスタンス
      check_class(ProcessUnit, cPrevRunning, true)       # 前のコンディションの実行状態タスク情報
      check_class(ProcessUnit, cPrevActiveObject, true)  # 前のコンディションの実行状態非タスク情報(信頼関数対応済み)
      check_class(ProcessUnit, cRunning, true)           # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)          # 実行状態非タスク情報
      check_class(Integer, nCoreid, true)                # コアID

      # 今回プレ/ポストタスクフックが起動していて，前の状態でプレ/ポストタスクフックが起動していない場合，
      # bootcntをセットする
      if (!cActivate.nil?())
        if (((cActivate.sObjectType == TSR_OBJ_PRETASK_HOOK) && (cPrevActiveObject.nil?() || (cPrevActiveObject.sObjectType != TSR_OBJ_PRETASK_HOOK))) ||
            ((cActivate.sObjectType == TSR_OBJ_POSTTASK_HOOK) && (cPrevActiveObject.nil?() || (cPrevActiveObject.sObjectType != TSR_OBJ_POSTTASK_HOOK))))
          hProcUnitInfo = get_proc_unit_info(cPrevActiveObject)
          sCommonID = cActivate.get_common_id()
          cElement.set_code(hProcUnitInfo, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{@sTestID}")

          # 複数回起動した場合に備えて，ポストタスクフック起動フラグを初期化する
          cRunning.bUnderPostTaskHook = false
        end
      end

      # 前の状態でプレ/ポストタスクフックが起動していて，今回プレ/ポストタスクフックが起動していない場合，
      # bootcntをクリアする
      if (!cPrevActiveObject.nil?())
        if (((cPrevActiveObject.sObjectType == TSR_OBJ_PRETASK_HOOK) && (cActivate.nil?() || (cActivate.sObjectType != TSR_OBJ_PRETASK_HOOK))) ||
            ((cPrevActiveObject.sObjectType == TSR_OBJ_POSTTASK_HOOK) && (cActivate.nil?() || (cActivate.sObjectType != TSR_OBJ_POSTTASK_HOOK))))
          hProcUnitInfo = get_proc_unit_info(cPrevActiveObject)
          sCommonID = cPrevActiveObject.get_common_id()
          cElement.set_code(hProcUnitInfo, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{AKTG_ENUM_INVALID}")
        end
      end

      # 前の状態でポストタスクフックが起動していて，今回ポストタスクフックが起動していない場合，かつ
      # 前の状態で実行中のタスクと，今回実行中のタスクが同じ場合，別の処理単位(フックorISR)が起動しているため，
      # そのタスクが起動することはない
      # →後片付け処理で不正なチェックポイントが入らないようにフラグを立てる
      if (!cPrevActiveObject.nil?())
        if ((cPrevActiveObject.sObjectType == TSR_OBJ_POSTTASK_HOOK) && !cActivate.nil?() && (cActivate.sObjectType != TSR_OBJ_POSTTASK_HOOK) &&
            !cRunning.nil?() && !cPrevRunning.nil?() && (cPrevRunning.sObjectID == cRunning.sObjectID))
          cRunning.bUnderPostTaskHook = true
        end
      end
    end

    #=================================================================
    # 概  要: 禁止状態の割込みの許可設定をするコード返す
    #=================================================================
    def gc_lastpost_set_enable_int()
      cElement = IMCodeElement.new()

      bChk = false
      hObjInfo = get_all_object_info(TSR_OBJ_C2ISR)
      if (@cConf.is_multi?())
        hIcisrObjInfo = get_all_object_info(TSR_OBJ_ICISR)
        hObjInfo = hObjInfo.merge(hIcisrObjInfo)
      end
      hObjInfo.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.hState[TSR_PRM_ISTAT] == TSR_STT_DISABLE)
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
          else
            hProcUnitInfo = get_proc_unit_info(@aActivate[cObjectInfo.hState[TSR_PRM_COREID]], @aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
          end
          cElement.set_syscall(hProcUnitInfo, "#{SS_ENA_INT_SRC}(#{cObjectInfo.get_common_id()})")
          bChk = true
        end
      }

      # C2ISR,ICISRがなければnilを返す
      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: DoStartSyncを行うコードを返す
    #=================================================================
    def gc_do_start_sync(cPrevCondition)
      check_class(Condition, cPrevCondition)  # 前のコンディション

      cElement = IMCodeElement.new()

      # doでシステムサービスを発行するコア以外において，前のコンディションでは実行状態で，
      # post_conditonで実行状態ではなくなるタスクがいる場合，
      # doのシステムサービス発行まで実行状態のままとする
      cPrevCondition.aRunning.each{|cObjectInfo|
        if (!cObjectInfo.nil?() && !@hDo.empty?())
          # doでシステムサービスを発行するオブジェクトの前状態における情報取得
          cPreDoObjectInfo = cPrevCondition.get_object_info(@hDo[TSR_PRM_ID])

          # doでシステムサービスを発行するタスクの場合は何もしない
          if (cObjectInfo.hState[TSR_PRM_COREID] == cPreDoObjectInfo.hState[TSR_PRM_COREID])
            next
          end

          # 現在のオブジェクト情報取得
          cNowObjectInfo = get_object_info(cObjectInfo.sObjectID)

          # システムサービス発行後にチェックポイントを設定し，実行状態のタスクからはそのチェックポイントを待機する
          if (!cNowObjectInfo.is_activate?())
            # doでシステムサービスを発行するオブジェクトの後状態における情報取得
            cPostDoObjectInfo = get_object_info(@hDo[TSR_PRM_ID])

            # 後状態でシステムサービスを発行した処理単位が実行状態でなくなる場合は，
            # マスタコアの実行状態の処理単位にチェックポイントを入れる
            hActivateInfo = nil
            if (!cPostDoObjectInfo.is_activate?())
              hActivateInfo = get_proc_unit_info(@cActivate, @cRunning)
              # 信頼関数が起動している処理単位への対応
              if (@hActiveTfn.has_key?(hActivateInfo[:id]))
                hActivateInfo = get_proc_unit_info(@hActiveTfn[hActivateInfo[:id]])
              end
            else
              hActivateInfo = get_proc_unit_info(cPostDoObjectInfo)
            end
            cElement.set_checkpoint(hActivateInfo, AKTG_SYNC_DO_START_SYNC)

            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            # 信頼関数が起動している処理単位への対応
            if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
              hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
            end
            cElement.wait_checkpoint(hProcUnitInfo, hActivateInfo[:coreid], AKTG_SYNC_DO_START_SYNC)
          end
        end
      }

      # doでシステムサービスを発行するコア以外において，前のコンディションでは実行状態で，
      # post_conditonで実行状態ではなくなる非タスクがいる場合，
      # doのシステムサービス発行まで実行状態のままとする
      cPrevCondition.aActivate.each{|cObjectInfo|
        if (!cObjectInfo.nil?() && !@hDo.empty?())
          # doでシステムサービスを発行するオブジェクトの前状態における情報取得
          cPreDoObjectInfo = cPrevCondition.get_object_info(@hDo[TSR_PRM_ID])

          # doでシステムサービスを発行する非タスクの場合は何もしない
          if (cObjectInfo.hState[TSR_PRM_COREID] == cPreDoObjectInfo.hState[TSR_PRM_COREID])
            next
          end

          # 現在のオブジェクト情報取得
          cNowObjectInfo = get_object_info(cObjectInfo.sObjectID)

          # システムサービス発行後にチェックポイントを設定し，実行状態の非タスクからはそのチェックポイントを待機する
          if (!cNowObjectInfo.is_activate?())
            # doでシステムサービスを発行するオブジェクトの後状態における情報取得
            cPostDoObjectInfo = get_object_info(@hDo[TSR_PRM_ID])

            hActivateInfo = get_proc_unit_info(cPostDoObjectInfo)
            # 信頼関数が起動している処理単位への対応
            if (@hActiveTfn.has_key?(hActivateInfo[:id]))
              hActivateInfo = get_proc_unit_info(@hActiveTfn[hActivateInfo[:id]])
            end
            cElement.set_checkpoint(hActivateInfo, AKTG_SYNC_DO_START_SYNC)

            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            # 信頼関数が起動している処理単位への対応
            if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
              hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
            end
            cElement.wait_checkpoint(hProcUnitInfo, cPostDoObjectInfo.hState[TSR_PRM_COREID], AKTG_SYNC_DO_START_SYNC)
          end
        end
      }

      return cElement  # [IMCodeElement]DoStartSyncを行うコード
    end

    #=================================================================
    # 概  要: DoFinishSyncを行うコードを返す
    #=================================================================
    def gc_do_finish_sync(cPrevCondition)
      check_class(Condition, cPrevCondition)  # 前のコンディション

      cElement = IMCodeElement.new()

      # 他コアにおいて，前のコンディションでは実行状態だったが，
      # doの処理によって実行状態ではなくなったタスクがいる場合，
      # そのタスクが現在の状態になるまで待機する(先にrefするのを防ぐ)
      cPrevCondition.aRunning.each_with_index{|cObjectInfo, nCoreid|
        if (!cObjectInfo.nil?() && (nCoreid != @nMasterCoreid))
          # 現在のオブジェクト情報取得
          cNowObjectInfo = get_object_info(cObjectInfo.sObjectID)

          # 現在，実行状態でない場合のみ(ICISR起動待ちは対象外)
          if (!cNowObjectInfo.is_activate?() && ![TSR_STT_RUNNING_WAITICISR, TSR_STT_ACTIVETE_WAITICISR].include?(cNowObjectInfo.hState[TSR_PRM_STATE]))
            # 対象タスクが現在の状態になるまでStateSyncする
            hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
            # 信頼関数が起動している処理単位への対応
            if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
              hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
            end
            if (cNowObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
              sObjectID = cNowObjectInfo.get_common_id()
            else
              sObjectID = cNowObjectInfo.sObjectID
            end
            cElement.set_state_sync(hProcUnitInfo, sObjectID, cNowObjectInfo.hState[TSR_PRM_STATE], AKTG_SYNC_DO_FINISH_SYNC)
          end
        end
      }

      return cElement  # [IMCodeElement]DoFinishSyncを行うコード
    end

    #=================================================================
    # 概  要: 各コアのRUNNINGとREADYであるタスクが休止状態となるまで
    #         StateSyncする同期を行うコードを返す
    #=================================================================
    def gc_lastpost_state_sync()
      # OS起動前，終了後である場合は不要
      if (@lKernelState != :KERNELBOOT)
        return nil
      end

      cElement = IMCodeElement.new()
      hMainTaskInfo = get_proc_unit_info()

      @hTask.each{|sObjectID, cObjectInfo|
        if ([TSR_STT_RUNNING, TSR_STT_READY].include?(cObjectInfo.hState[TSR_PRM_STATE]))
          if (cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
            sObjectID = cObjectInfo.get_common_id()
          end
          cElement.set_state_sync(hMainTaskInfo, sObjectID, TSR_STT_SUSPENDED, AKTG_SYNC_WAIT_TERMINATE_ACTIVE_TASK_SYNC)
        end
      }

      return cElement  # [IMCodeElement]LastStateSyncコード
    end

    #=================================================================
    # 概  要: LastStartupShutdownHookSyncを行うコードを返す
    #=================================================================
    def gc_last_startup_shutdown_hook_sync(bCannotMerge)
      check_class(Bool, bCannotMerge)  # マージ可能なテストシナリオかどうか

      # カーネル起動中，マージ不可の場合は不要
      if ((@lKernelState == :KERNELBOOT) || (bCannotMerge == true))
        return nil
      end

      cElement      = IMCodeElement.new()
      aProcUnitInfo = []

      # マルチコアでは全コアにスタートアップ，シャットダウンフックが存在して，
      # 状態に関わらず空の関数が実行されるので，そこにバリア同期を入れておく
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK) ||
            (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK))
          aProcUnitInfo.push(get_proc_unit_info(cObjectInfo))
        end
      }

      if (aProcUnitInfo.size > 1)
        cElement.set_barrier_sync(aProcUnitInfo, AKTG_SYNC_LAST_STARTUP_SHUTDOWN_HOOK_SYNC)
      end

      return cElement  # [IMCodeElement]BarrierSyncを行うコード
    end

    #=================================================================
    # 概  要: スピンロック取得待ち状態の処理単位の有無確認を返す
    #=================================================================
    def exist_wait_spinlock()
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) == true) &&
            ((cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITSPIN) ||
             (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITSPIN)))
          return true  # [Bool]スピンロック取得待ち状態の処理単位がある
        end
      }

      return false  # [Bool]スピンロック取得待ち状態の処理単位がない
    end

    #=================================================================
    # 概  要: スピンロック取得待ちのために遅延処理するコードを返す
    #=================================================================
    def gc_delay_wait_spin()
      cElement = IMCodeElement.new()

      # スピンロック取得待ちの処理単位情報取得
      # (複数存在する場合はどれかで遅延させればよい)
      cWaitProcUnit = nil
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) &&
            ((cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITSPIN) ||
             (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITSPIN)))
          cWaitProcUnit = cObjectInfo
          break
        end
      }

      # スピンロック取得待ち対象のスピンロックIDを取得
      sSpinlockID = cWaitProcUnit.hState[TSR_PRM_SPNID]

      # 対象のスピンロックを取得している処理単位情報を取得
      cSpinlockProcUnit = nil
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) &&
            (cObjectInfo.hState[TSR_PRM_GETSPN] != nil) &&
            (cObjectInfo.hState[TSR_PRM_GETSPN].include?(sSpinlockID)))
          cSpinlockProcUnit = cObjectInfo
          break
        end
      }

      # スピンロック取得中の処理単位が実行状態ではない場合に備えて
      # 同じコアで実行中の処理単位から遅延処理を行う
      hDelayProcUnit = get_proc_unit_info(@aActivateProcUnit[cSpinlockProcUnit.hState[TSR_PRM_COREID]])

      # 遅延処理を実行
      cElement.set_delay_loop(hDelayProcUnit, AKTG_WAIT_SPIN_LOOP)

      return cElement  # [IMCodeElement]スピンロック取得待ちのために遅延処理するコード
    end

    #=================================================================
    # 概  要: ICISR起動待ち状態の処理単位の有無確認を返す
    #=================================================================
    def exist_wait_icisr()
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ([TSR_OBJ_TASK, TSR_OBJ_C2ISR].include?(cObjectInfo.sObjectType) &&
            [TSR_STT_RUNNING_WAITICISR, TSR_STT_ACTIVETE_WAITICISR].include?(cObjectInfo.hState[TSR_PRM_STATE]))
          return true  # [Bool]ICISR起動待ち状態の処理単位がある
        end
      }

      return false  # [Bool]ICISR起動待ち状態の処理単位がない
    end

    #=================================================================
    # 概  要: ICISR起動待ちのために遅延処理するコードを返す
    #=================================================================
    def gc_delay_wait_icisr()
      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ([TSR_OBJ_TASK, TSR_OBJ_C2ISR].include?(cObjectInfo.sObjectType) &&
            [TSR_STT_RUNNING_WAITICISR, TSR_STT_ACTIVETE_WAITICISR].include?(cObjectInfo.hState[TSR_PRM_STATE]))
          hProcUnitInfo = get_proc_unit_info(cObjectInfo)
          if (@hActiveTfn.has_key?(sObjectID))
            hProcUnitInfo = get_proc_unit_info(@hActiveTfn[sObjectID])
          end
          cElement.set_delay_loop(hProcUnitInfo, AKTG_WAIT_BOOT_ICISR)
          bChk = true
        end
      }

      if (bChk == false)
        return nil
      end
      return cElement  # [IMCodeElement]ICISR起動待ちのために遅延処理するコードを返す
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからブートカウントをリ
    #         セットするコードを設定する
    #=================================================================
    def gc_hook_bootcnt_clear(sCode)
      check_class(String, sCode)            # 実行するコード

      # finishフラグがtrueの場合，ここでカーネルが終了するため，リセットは不要
      if (@hDo[TSR_PRM_FINISH] == true)
        return nil
      end

      cElement = IMCodeElement.new()
      bChk = false

      # AfterBootCntClearSyncを行う処理単位
      aProcUnitInfo = []

      # システム定義のシャットダウンフック
      hObjInfo = get_all_object_info(TSR_OBJ_SHUTDOWN_HOOK)
      hObjInfo.each{|sObjectID, cObjectInfo|
        hProcUnitInfo = get_proc_unit_info(cObjectInfo)
        aProcUnitInfo.push(hProcUnitInfo)
        if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
          cElement.set_code(hProcUnitInfo, sCode)
          bChk = true
        end
      }

      # OSAP固有のシャットダウンフック
      # (システム定義のシャットダウンフックで実施済みの場合は不要)
      if ((@cConf.enable_osap?()) && (bChk == false))
        hObjInfo = get_all_object_info(TSR_OBJ_SHUTDOWN_HOOK_OSAP)
        hObjInfo.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            cElement.set_code(hProcUnitInfo, sCode)
            bChk = true
          end
        }
      end

      # OSAP固有のスタートアップフック
      # (シャットダウンフックで実施する場合は不要)
      if ((@cConf.enable_osap?()) && (bChk == false))
        hObjInfo = get_all_object_info(TSR_OBJ_STARTUP_HOOK_OSAP)
        hObjInfo.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            cElement.set_code(hProcUnitInfo, sCode)
            bChk = true
          end
        }
      end

      # システム定義のスタートアップフック
      # (シャットダウンフックかOSAP固有のスタートアップフックで実施済みの場合は不要)
      if (bChk == false)
        hObjInfo = get_all_object_info(TSR_OBJ_STARTUP_HOOK)
        hObjInfo.each{|sObjectID, cObjectInfo|
          hProcUnitInfo = get_proc_unit_info(cObjectInfo)
          aProcUnitInfo.push(hProcUnitInfo)
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            cElement.set_code(hProcUnitInfo, sCode)
            bChk = true
          end
        }
      end

      # マルチコアではAfterBootCntClearSyncを行う
      if (@cConf.is_multi?() && (aProcUnitInfo.size() > 1))
        cElement.set_barrier_sync(aProcUnitInfo, AKTG_SYNC_AFTER_BOOT_CNT_CLEAR_SYNC)
        bChk = true
      end

      # スタートアップ/シャットダウンフックがなければnilを返す
      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement] エレメント
    end

  end
end
