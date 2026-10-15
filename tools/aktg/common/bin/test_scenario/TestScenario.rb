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
# $Id: TestScenario.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/test_scenario/PreCondition.rb"
require "common/bin/test_scenario/Do_PostCondition.rb"
require "aktf/bin/test_scenario/TestScenario.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: TestScenario
  # 概    要: PreCondition，Do，PostConditionのデータを生成
  #===================================================================
  class TestScenario
    include CommonModule

    attr_reader :sTestID, :hProperty, :cPreCondition, :aDo_PostCondition, :bSingleTest, :bCannotMerge

    #=================================================================
    # 概  要: コンストラクタ
    #=================================================================
    def initialize(sTestID, hScenario, bSingleTest)
      check_class(String, sTestID)         # テストID
      check_class(Object, hScenario, true) # pre，do，postシナリオ(T1_004でチェック)
      check_class(Bool, bSingleTest)       # テストケースが1件かどうか

      @cConf        = Config.new()  # コンフィグの取得
      @hProperty    = {}            # プロパティ情報
      @sTestID      = sTestID       # テストID
      @bSingleTest  = bSingleTest   # テストケースが1件かどうか
      @bCannotMerge = false         # マージしないテストケースフラグ
      @aNeedSi      = []            # 各コンディションの処理単位とdoに指定されたtarget_specと一致しないneed_si

      # スタートアップ/シャットダウンフック中に処理単位が起動するコアの管理
      @aActivateCoreOnStartupShutdown = Array.new(@cConf.get_core_num(), false)

      # 構造チェック
      basic_check(sTestID, hScenario)

      hMacro = @cConf.get_macro()

      # property格納
      if (hScenario[TSR_LBL_PROPERTY].nil?())
        @hProperty = {}
      else
        @hProperty = hScenario[TSR_LBL_PROPERTY]
      end

      # pre_condition生成
      @cPreCondition = PreCondition.new(sTestID, hScenario[TSR_LBL_PRE], @hProperty)

      # do，post_condition生成(doとpostは一緒に処理)
      @aDo_PostCondition = []

      # 構造を整形
      hScenario = fix_structure(hScenario)

      # シーケンス番号取得
      aSeqNumList = []
      hScenario.each_key{|sCondition|
        if (sCondition =~ TSR_REX_DO)
          aSeqNumList.push($1.to_i())
        end
      }
      aSeqNumList = aSeqNumList.sort()

      # 時系列順にdoとpostを作成
      aSeqNumList.each{|nSeqNum|
        sSeqDo   = "#{TSR_UNS_DO}#{nSeqNum}"
        sSeqPost = "#{TSR_UNS_POST}#{nSeqNum}"

        hScenarioDo   = hScenario["#{TSR_UNS_DO}#{nSeqNum}"]
        hScenarioPost = hScenario["#{TSR_UNS_POST}#{nSeqNum}"]

        cObj = Do_PostCondition.new(sTestID, hScenarioDo, hScenarioPost, nSeqNum, @cPreCondition, @hProperty)
        @aDo_PostCondition.push(cObj)
      }
    end

    #=================================================================
    # 概  要: テストシナリオの構造を整える
    #=================================================================
    def fix_structure(hScenario)
      check_class(Hash, hScenario)  # テストシナリオ

      hResult = {}
      hScenario.each{|sCondition, shCondition|
        case sCondition
        when TSR_LBL_PRE, TSR_LBL_PROPERTY
          hResult[sCondition] = shCondition
        when TSR_REX_PRE_DO
          sSeq    = "#{TSR_UNS_DO}#{$1.to_i()}"
          hResult[sSeq] = shCondition
        when TSR_REX_PRE_POST
          sSeq    = "#{TSR_UNS_POST}#{$1.to_i()}"
          hResult[sSeq] = shCondition
        else
          abort(ERR_MSG % [__FILE__, __LINE__])
        end
      }

      return hResult  # [Hash]整形されたテストシナリオ
    end

    #=================================================================
    # 概  要: 各コンディションを初期化
    #=================================================================
    def init_conditions()
      aConditions = get_all_condition()
      aConditions.each{|cCondition|
        cCondition.init_instance_variables()
      }

      # スタートアップ/シャットダウンフック中に処理単位が起動するコアの管理情報を更新する
      if (@cConf.is_multi?())
        aConditions.each{|cCondition|
          cCondition.aActivateCoreOnStartupShutdown.each_with_index{|bIsActive, nIndex|
            if (bIsActive == true)
              @aActivateCoreOnStartupShutdown[nIndex] = true
            end
          }
        }
      end
    end

    #=================================================================
    # 概  要: シーケンス番号を返す
    #=================================================================
    def get_seqnum(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか  # 何番目のdo_postか

      return @aDo_PostCondition[nIndex].nSeqNum  # [Integer]シーケンス番号
    end

    #=================================================================
    # 概  要: 最後のpost_conditionか確認
    #=================================================================
    def check_lastpost_condition(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (@aDo_PostCondition[AKTG_IDX_LAST] == @aDo_PostCondition[nIndex])
        return true  # [Bool]最後のpost_conditionか
      end

      return false  # [Bool]最後のpost_conditionか
    end

    #=================================================================
    # 概  要: メインタスクID，コアID，起動回数を取得
    #=================================================================
    def get_main_task_proc()
      return @cPreCondition.get_proc_unit_info()  # [Hash]メインタスクの情報
    end

    #=================================================================
    # 概  要: タスクの数を返す(信頼OSAP含む)
    #=================================================================
    def get_stack_num()

      aCnt = Array.new(@cConf.get_core_num(), 0)
      @cPreCondition.hTask.each{|cObjID, cObjInfo|
        if (cObjInfo.is_trusted?())
          aCnt[cObjInfo.hState[TSR_PRM_COREID]] += 1
        end
      }

      # スタックモニタリングのテストでは，スタックを1つ多く確保し，
      # スタックオーバーフローしても問題が発生しないようにする
      if (@cConf.enable_stackfault_detection() == false)
        aCnt.each_with_index{|nCnt, index|
          aCnt[index] += 1
        }
      end

      return aCnt  # [Array]タスクの数(信頼OSAP含む)
    end

    #=================================================================
    # 概  要: 非信頼OSAPのタスクの数を返す
    #=================================================================
    def get_ustack_num()

       aCnt = Array.new(@cConf.get_core_num(), 0)
      @cPreCondition.hTask.each{|cObjID, cObjInfo|
        if (!cObjInfo.is_trusted?())
          aCnt[cObjInfo.hState[TSR_PRM_COREID]] += 1
        end
      }

      # スタックモニタリングのテストでは，スタックを1つ多く確保し，
      # スタックオーバーフローしても問題が発生しないようにする
      # (信頼関数でのシステムスタックオーバーフロー)
      if (@cConf.enable_stackfault_detection() == false)
        aCnt.each_with_index{|nCnt, index|
          aCnt[index] += 1
        }
      end

      return aCnt  # [Array]非信頼OSAPのタスクの数
    end

    #=================================================================
    # 概  要: 全ての処理単位名とそれぞれの最終的な起動回数を取得
    #=================================================================
    def get_proc_units(cElement)
      check_class(IMCodeElement, cElement)  # コードを追加するエレメント

      @aDo_PostCondition[AKTG_IDX_LAST].get_proc_units(cElement)
    end

    #=================================================================
    # 概  要: doが情報を持っていればtrue，そうではなければfalseを返す
    #=================================================================
    def check_do_info(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (@aDo_PostCondition[nIndex].hDo.empty?())
        return false  # [Bool]doに設定がされているか
      else
        return true  # [Bool]doに設定がされているか
      end
    end

    #=================================================================
    # 概  要: グローバル/ローカル変数を宣言するためのコードを設定する
    #=================================================================
    def gc_global_local_var(cElement)
      check_class(IMCodeElement, cElement)  # コードを追加するエレメント

      @cPreCondition.gc_global_local_var(cElement)
    end

    #=================================================================
    # 概  要: ヘッダーファイルに出力するコードを設定する
    #=================================================================
    def gc_header(cElement)
      check_class(IMCodeElement, cElement)  # コードを追加するエレメント

      @cPreCondition.gc_header(cElement)
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコードを設定する
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement)  # コードを追加するエレメント

      @cPreCondition.gc_config(cElement)
    end

    #=================================================================
    # 概  要: 実行状態，実行可能状態のタスクを設定するコードを返す
    #=================================================================
    def gc_pre_task_running_ready()
      return @cPreCondition.gc_pre_task_running_ready()  # [IMCodeElement]実行状態，実行可能状態のタスクを設定するコード
    end

    #=================================================================
    # 概  要: コンディション内のオブジェクトのrefコードを返す
    #=================================================================
    def gc_obj_ref(nIndex = nil)
      check_class(Integer, nIndex, true)  # 何番目のdo_postか

      if (nIndex.nil?())
        return @cPreCondition.gc_obj_ref()  # [IMCodeElement]コンディション内のオブジェクトのrefコード
      else
        return @aDo_PostCondition[nIndex].gc_obj_ref()  # [IMCodeElement]コンディション内のオブジェクトのrefコード
      end
    end

    #=================================================================
    # 概  要: Doの処理のコードを返す
    #=================================================================
    def gc_do(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (nIndex == 0)
        cPrevCondition = @cPreCondition
      else
        cPrevCondition = @aDo_PostCondition[nIndex - 1]
      end

      return @aDo_PostCondition[nIndex].gc_do(cPrevCondition)  # [IMCodeElement]Doの処理のコード
    end

    #=================================================================
    # 概  要: ゼロチェックポイントを出力するコードを返す
    #=================================================================
    def gc_checkpoint_zero()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_checkpoint_zero()  # [IMCodeElement]ゼロチェックポイントを出力するコード
    end

    #=================================================================
    # 概  要: @aDo_PostConditionのIndex一覧を返す
    #=================================================================
    def get_do_post_index()
      aIndex = []

      @aDo_PostCondition.each_index{|nIndex|
        aIndex.push(nIndex)
      }

      return aIndex  # [Array]Index一覧
    end

    #=================================================================
    # 概  要: 各処理単位の有無を返す
    #=================================================================
    def exist_proc_unit(sObjectType)
      check_class(String, sObjectType)  # 対象とする処理単位タイプ

      case sObjectType
      when TSR_OBJ_C1ISR
        return @cPreCondition.bIsC1Isr  # [Bool]カテゴリ1ISRが存在するか
      when TSR_OBJ_C2ISR
        return @cPreCondition.bIsC2Isr  # [Bool]カテゴリ2ISRが存在するか
      when TSR_OBJ_STARTUP_HOOK
        return @cPreCondition.bIsStartupHook  # [Bool]スタートアップフックが存在するか
      when TSR_OBJ_SHUTDOWN_HOOK
        return @cPreCondition.bIsShutdownHook  # [Bool]シャットダウンフックが存在するか
      when TSR_OBJ_PRETASK_HOOK
        return @cPreCondition.bIsPreTaskHook  # [Bool]プレタスクフックフックが存在するか
      when TSR_OBJ_POSTTASK_HOOK
        return @cPreCondition.bIsPostTaskHook  # [Bool]ポストタスクフックフックが存在するか
      when TSR_OBJ_ERROR_HOOK
        return @cPreCondition.bIsErrorHook  # [Bool]エラーフックが存在するか
      when TSR_OBJ_PROTECTION_HOOK
        return @cPreCondition.bIsProtectionHook  # [Bool]プロテクションフックが存在するか
      when TSR_OBJ_STARTUP_HOOK_OSAP
        return @cPreCondition.bIsStartupHookOsap  # [Bool]OSAP固有のスタートアップフックが存在するか
      when TSR_OBJ_SHUTDOWN_HOOK_OSAP
        return @cPreCondition.bIsShutdownHookOsap  # [Bool]OSAP固有のシャットダウンフックが存在するか
      when TSR_OBJ_ERROR_HOOK_OSAP
        return @cPreCondition.bIsErrorHookOsap  # [Bool]OSAP固有のエラーフックが存在するか
      when TSR_OBJ_ICISR
        return @cPreCondition.bIsIcIsr  # [Bool]IC2ISRが存在するか
      when TSR_OBJ_RESTART_TASK
        return @cPreCondition.bIsRestartTask  # [Bool]リスタートタスクが存在するか
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end
    end

    #=================================================================
    # 概  要: スピンロック取得待ち状態の処理単位の有無確認
    #=================================================================
    def exist_wait_spinlock(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      return @aDo_PostCondition[nIndex].exist_wait_spinlock()  # [Bool]スピンロック取得待ち状態の処理単位の有無
    end

    #=================================================================
    # 概  要: ICISR起動待ち状態の処理単位の有無確認
    #=================================================================
    def exist_wait_icisr(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      return @aDo_PostCondition[nIndex].exist_wait_icisr()  # [Bool]ICISR起動待ち状態の処理単位の有無
    end

    #=================================================================
    # 概  要: 実行状態となる各処理単位の有無を返す
    #         (現状，スタートアップフック/シャットダウンフックのみ必要)
    #=================================================================
    def exist_active_proc_unit(sObjectType)
      check_class(String, sObjectType)  # 対象とする処理単位タイプ

      case sObjectType
      when TSR_OBJ_STARTUP_HOOK
        return @cPreCondition.bIsActiveStartupHook  # [Bool]実行状態となるスタートアップフックが存在するか
      when TSR_OBJ_SHUTDOWN_HOOK
        return @cPreCondition.bIsActiveShutdownHook  # [Bool]実行状態となるシャットダウンフックが存在するか
      when TSR_OBJ_STARTUP_HOOK_OSAP
        return @cPreCondition.bIsActiveStartupHookOsap  # [Bool]実行状態となるOSAP固有のスタートアップフックが存在するか
      when TSR_OBJ_SHUTDOWN_HOOK_OSAP
        return @cPreCondition.bIsActiveShutdownHookOsap  # [Bool]実行状態となるOSAP固有のシャットダウンフックが存在するか
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end
    end

    #=================================================================
    # 概  要: ハードウェアカウンタの有無を返す
    #=================================================================
    def exist_hwcnt()
      return @cPreCondition.bIsHwcnt  # [Bool]ハードウェアカウンタが存在するか
    end

    #=================================================================
    # 概  要: PreConditionの起動状態シャットダウンフックの有無を返す
    #=================================================================
    def exist_pre_active_shutdown_hook()
      return @cPreCondition.exist_pre_active_shutdown_hook()  # [Bool]PreConditionの起動状態シャットダウンフックの有無
    end

    #=================================================================
    # 概  要: 指定したオブジェクトの全情報を返す
    #=================================================================
    def get_all_object_info(sObjectType)
      check_class(String, sObjectType)  # 対象とするオブジェクトタイプ

      return @aDo_PostCondition[AKTG_IDX_LAST].get_all_object_info(sObjectType)  # [Hash]オブジェクト情報
    end

    #=================================================================
    # 概  要: 指定したオブジェクトタイプの処理単位でACTIVATEであるオブ
    #         ジェクトのIDを返す
    #=================================================================
    def get_activate_proc_unit_id(sObjectType)
      check_class(String, sObjectType)  # 対象とするオブジェクトタイプ

      aProcUnitID = @cPreCondition.get_activate_proc_unit_id(sObjectType)

      @aDo_PostCondition.each{|cPostCondition|
        aProcUnitID.concat(cPostCondition.get_activate_proc_unit_id(sObjectType))
      }

      return aProcUnitID.uniq()  # [Array]ACTIVATEであるオブジェクトのID
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックの全情報をオブジェクト
    #         IDでソートした配列で返す
    #=================================================================
    def get_startup_shutdown_object_info_sort_by_id(sObjectType)
      check_class(String, sObjectType)  # 対象とするオブジェクトタイプ[スタートアップorシャットダウンフック]

      return @cPreCondition.get_startup_shutdown_object_info_sort_by_id(sObjectType)  # [Hash]オブジェクト情報
    end

    #=================================================================
    # 概  要: 次のコンディションで起動するACTIVATEなISRが存在する場合，
    #         起動を待つコードを返す
    #=================================================================
    def gc_wait_isr_activate(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (nIndex == 0)
        cPrevCondition = @cPreCondition
      else
        cPrevCondition = @aDo_PostCondition[nIndex - 1]
      end

      # [IMCodeElement]次のコンディションで起動するACTIVATEなISRが存在する場合，起動を待つコード
      return @aDo_PostCondition[nIndex].gc_wait_isr_activate(cPrevCondition)
    end

    #=================================================================
    # 概  要: 実行状態のタスクが存在しないマスタコアに，実行状態のタス
    #         クが発生した場合の切替処理のコードを返す
    #=================================================================
    def gc_switch_running_task(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (nIndex == 0)
        cPrevCondition = @cPreCondition
      else
        cPrevCondition = @aDo_PostCondition[nIndex - 1]
      end

      # [IMCodeElement]実行状態のタスクが存在しないマスタコアに，実行状態のタスクが発生した場合の切替処理のコード
      return @aDo_PostCondition[nIndex].gc_switch_running_task(cPrevCondition)
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからテストID開始メッセ
    #         ージ出力するコードを返す
    #=================================================================
    def gc_pre_test_start_message()
      return @cPreCondition.gc_pre_test_start_message()  # [IMCodeElement]スタートアップ/シャットダウンフックからテストID開始メッセージ出力するコード
    end

    #=================================================================
    # 概  要: 共有関数からテストケース毎の関数を呼び出すコードを返す
    #=================================================================
    def gc_pre_call_each_func()
      return @cPreCondition.gc_pre_call_each_func()  # [IMCodeElement]共有関数からテストケース毎の関数を呼び出すコード
    end

    #=================================================================
    # 概  要: 引数のスタートアップ/シャットダウンフック用コードを
    #         pre_conditionクラスに格納する
    #=================================================================
    def set_hook_bootcnt_code(sCode)
      check_class(String, sCode)  # 実行するコード

      @cPreCondition.set_hook_bootcnt_code(sCode)
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからブートカウントをリ
    #         セットするコードを設定する
    #=================================================================
    def gc_hook_bootcnt_clear(sCode)
      check_class(String, sCode)  # 実行するコード

      return @aDo_PostCondition[AKTG_IDX_LAST].gc_hook_bootcnt_clear(sCode)  # [IMCodeElement]ブートカウントをリセットするコード
    end

    #=================================================================
    # 概  要: 最後のシャットダウンフックでカーネル終了処理を行うコード
    #         を返す
    #=================================================================
    def gc_finish_cp_on_shutdown_hook()
      return @cPreCondition.gc_finish_cp_on_shutdown_hook()  # [IMCodeElement]最後のシャットダウンフックでカーネル終了処理を行うコード
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからテストID完了メッセ
    #         ージ出力するコードを返す
    #=================================================================
    def gc_lastpost_test_end_message()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_test_end_message(@bCannotMerge)  # [IMCodeElement]スタートアップ/シャットダウンフックからテストID完了メッセージ出力するコード
    end

    #=================================================================
    # 概  要: 動作中のスケジュールテーブルを設定するコードを返す
    #=================================================================
    def gc_pre_set_start_schedule_table()
      return @cPreCondition.gc_pre_set_start_schedule_table()  # [IMCodeElement]動作中のスケジュールテーブルを設定するコードコード
    end

    #=================================================================
    # 概  要: カウンタの設定をするコードを返す
    #=================================================================
    def gc_pre_increment_counter()
      return @cPreCondition.gc_pre_increment_counter()  # [IMCodeElement]カウンタの設定をするコード
    end

    #=================================================================
    # 概  要: 動作中のアラーム設定をするコードを返す
    #=================================================================
    def gc_pre_set_alarm()
      return @cPreCondition.gc_pre_set_alarm()  # [IMCodeElement]動作中のアラーム設定をするコード
    end

    #=================================================================
    # 概  要: イベント待ちタスクの設定をするコードを返す
    #=================================================================
    def gc_pre_task_waiting()
      return @cPreCondition.gc_pre_task_waiting()  # [IMCodeElement]イベント待ちタスクの設定をするコード
    end

    #=================================================================
    # 概  要: 切替え待ち状態のスケジュールテーブルを設定するコードを返
    #         す
    #=================================================================
    def gc_pre_set_next_schedule_table()
      return @cPreCondition.gc_pre_set_next_schedule_table()  # [IMCodeElement]切替え待ち状態のスケジュールテーブルを設定するコード
    end

    #=================================================================
    # 概  要: 起動状態のC1/C2ISRの設定をするコードを返す
    #=================================================================
    def gc_pre_isr_activate(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      return @cPreCondition.gc_pre_isr_activate(sObjectType)  # [IMCodeElement]起動状態のC1/C2ISRの設定をするコード
    end

    #=================================================================
    # 概  要: 起動状態のエラー/プロテクションフックの設定をするコードを
    #         返す
    #=================================================================
    def gc_pre_hook_activate(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      return @cPreCondition.gc_pre_hook_activate(sObjectType, @bCannotMerge)  # [IMCodeElement]起動状態のエラー/プロテクションフックの設定をするコード
    end

    #=================================================================
    # 概  要: 割込み禁止を伴うスピンロック取得の設定をするコードを返す
    #=================================================================
    def gc_pre_get_spinlock_sus_int(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      return @cPreCondition.gc_pre_get_spinlock_sus_int(sObjectType)  # [IMCodeElement]スピンロック取得の設定をするコード
    end

    #=================================================================
    # 概  要: すべてのスピンロック取得の設定をするコードを返す
    #=================================================================
    def gc_pre_get_all_spinlock(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      return @cPreCondition.gc_pre_get_all_spinlock(sObjectType)  # [IMCodeElement]スピンロック取得の設定をするコード
    end

    #=================================================================
    # 概  要: 割込み禁止状態の設定をするコードを返す
    #=================================================================
    def gc_pre_interrupt(bByTask)
      check_class(Bool, bByTask)  # タスクによる割込み禁止か

      return @cPreCondition.gc_pre_interrupt(bByTask)  # [IMCodeElement]割込み禁止状態の設定をするコード
    end

    #=================================================================
    # 概  要: 割込み禁止状態の解除をするコードを返す
    #=================================================================
    def gc_lastpost_interrupt()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_interrupt()  # [IMCodeElement]割込み禁止状態の解除をするコード
    end

    #=================================================================
    # 概  要: スピンロックを獲得している処理単位の解放処理をするコードを返す
    #=================================================================
    def gc_lastpost_release_spinlock()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_release_spinlock()  # [IMCodeElement]スピンロックを獲得している処理単位の解放処理をするコード
    end

    #=================================================================
    # 概  要: リソースを獲得している処理単位の解放処理をするコードを返す
    #=================================================================
    def gc_lastpost_release_resource()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_release_resource()  # [IMCodeElement]リソースを獲得している処理単位の解放処理をするコード
    end

    #=================================================================
    # 概  要: 全タスクの最後にTerminateTaskを実行するコードを返す
    #=================================================================
    def gc_lastpost_terminate_each_task()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_terminate_each_task()  # [IMCodeElement]全タスクの最後にTerminateTaskを実行するコード
    end

    #=================================================================
    # 概  要: 起動要求が2以上となっているタスクを終了させるコードを返す
    #=================================================================
    def gc_lastpost_terminate_queueing_task()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_terminate_queueing_task()  # [IMCodeElement]起動要求が2以上となっているタスクを終了させるコード
    end

    #=================================================================
    # 概  要: イベント待ち状態となっているタスクを終了させるコードを返す
    #=================================================================
    def gc_lastpost_terminate_waiting_task()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_terminate_waiting_task()  # [IMCodeElement]イベント待ち状態となっているタスクを終了させるコード
    end

    #=================================================================
    # 概  要: スケジュールテーブルを停止させるコードを返す
    #=================================================================
    def gc_lastpost_stop_schedule_table()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_stop_schedule_table()  # [IMCodeElement]スケジュールテーブルを停止させるコード
    end

    #=================================================================
    # 概  要: 動作状態のアラームを停止させるコードを返す
    #=================================================================
    def gc_lastpost_stop_alarm()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_stop_alarm()  # [IMCodeElement]動作状態のアラームを停止させるコード
    end

    #=================================================================
    # 概  要: 1件のみのテストケースにおけるシャットダウンフック終了処理
    #         のコードを返す
    #=================================================================
    def gc_lastpost_shutdown_hook_in_single_test()
      if (@bCannotMerge == false)
        return nil
      else
        return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_shutdown_hook_in_single_test()  # [IMCodeElement]1件のみのテストケースにおけるシャットダウンフック終了処理するコード
      end
    end

    #=================================================================
    # 概  要: 各フックのbootcntをクリアするコードを返す
    #=================================================================
    def gc_lastpost_clear_hook_bootcnt()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_clear_hook_bootcnt()  # [IMCodeElement]各フックのbootcntをクリアするコード
    end

    #=================================================================
    # 概  要: 次のコンディションのフックの状態に合わせてbootcntを操作す
    #         るコードを返す
    #=================================================================
    def gc_set_hook_bootcnt(nIndex)
      check_class(Integer, nIndex)  # 何番目のdo_postか

      if (nIndex == 0)
        cPrevCondition = @cPreCondition
      else
        cPrevCondition = @aDo_PostCondition[nIndex - 1]
      end

      return @aDo_PostCondition[nIndex].gc_set_hook_bootcnt(cPrevCondition)  # [IMCodeElement]次のコンディションのフックの状態に合わせてbootcntを操作するコード
    end

    #=================================================================
    # 概  要: OSAP固有のスタートアップフックのID一覧を返す
    #=================================================================
    def get_startup_hook_osap_id()
      return @cPreCondition.aStartupHookOsapId  # [Array]OSAP固有のスタートアップフックのID一覧
    end

    #=================================================================
    # 概  要: OSAP固有のシャットダウンフックのID一覧を返す
    #=================================================================
    def get_shutdown_hook_osap_id()
      return @cPreCondition.aShutdownHookOsapId  # [Array]OSAP固有のシャットダウンフックのID一覧
    end

    #=================================================================
    # 概  要: 許可状態の割込みの禁止設定をするコード返す
    #=================================================================
    def gc_pre_set_disable_int()
      return @cPreCondition.gc_pre_set_disable_int()  # [IMCodeElement]許可状態の割込みの禁止設定をするコード
    end

    #=================================================================
    # 概  要: 禁止状態の割込みの許可設定をするコード返す
    #=================================================================
    def gc_lastpost_set_enable_int()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_set_enable_int()  # [IMCodeElement]禁止状態の割込みの許可設定をするコード
    end

    #=================================================================
    # 概  要: 登場する割込み番号を返す
    #=================================================================
    def get_exist_intno()
      return @cPreCondition.get_exist_intno()  # [Array]登場する割込み番号
    end

    #=================================================================
    # 概  要: pre_conditionで記述されたIOCを設定するコードを返す
    #=================================================================
    def gc_pre_set_ioc()
      return @cPreCondition.gc_pre_set_ioc()
    end

    #=================================================================
    # 概  要: BarrierSyncを行うコードを返す
    #=================================================================
    def gc_barrier_sync(sSyncComment, nIndex = nil)
      check_class(String, sSyncComment)   # マルチコアにおける同期用コメント
      check_class(Integer, nIndex, true)  # do/postのシーケンス番号

      if (nIndex.nil?())
        return @cPreCondition.gc_barrier_sync(sSyncComment)  # [IMCodeElement]BarrierSyncを行うコード
      else
        return @aDo_PostCondition[nIndex].gc_barrier_sync(sSyncComment)  # [IMCodeElement]BarrierSyncを行うコード
      end
    end

    #=================================================================
    # 概  要: DoStartSyncを行うコードを返す
    #=================================================================
    def gc_do_start_sync(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      if (nIndex == 0)
        cPrev = @cPreCondition
      else
        cPrev = @aDo_PostCondition[nIndex - 1]
      end

      return @aDo_PostCondition[nIndex].gc_do_start_sync(cPrev)  # [IMCodeElement]DoStartSyncを行うコード
    end

    #=================================================================
    # 概  要: DoFinishSyncを行うコードを返す
    #=================================================================
    def gc_do_finish_sync(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      if (nIndex == 0)
        cPrev = @cPreCondition
      else
        cPrev = @aDo_PostCondition[nIndex - 1]
      end

      return @aDo_PostCondition[nIndex].gc_do_finish_sync(cPrev)  # [IMCodeElement]DoFinishSyncを行うコード
    end

    #=================================================================
    # 概  要: 各コアのRUNNINGとREADYであるタスクが休止状態となるまで
    #         StateSyncする同期を行うコードを返す
    #=================================================================
    def gc_lastpost_state_sync()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_lastpost_state_sync()  # [IMCodeElement]各コアのRUNNINGとREADYであるタスクが休止状態となるまでStateSyncするコード
    end

    #=================================================================
    # 概  要: 各コアのスタートアップ/シャットダウンフックが次のテストへ
    #         進まないための同期を行うコードを返す
    #=================================================================
    def gc_last_startup_shutdown_hook_sync()
      return @aDo_PostCondition[AKTG_IDX_LAST].gc_last_startup_shutdown_hook_sync(@bCannotMerge)  # [IMCodeElement]各コアのスタートアップ/シャットダウンフックが次のテストへ進まないための同期を行うコード
    end

    #=================================================================
    # 概  要: スピンロック取得待ちのために遅延処理するコードを返す
    #=================================================================
    def gc_delay_wait_spin(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      return @aDo_PostCondition[nIndex].gc_delay_wait_spin()  # [IMCodeElement]スピンロック取得待ちのために遅延処理するコード
    end

    #=================================================================
    # 概  要: ICISR起動待ちのために遅延処理するコードを返す
    #=================================================================
    def gc_delay_wait_icisr(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      return @aDo_PostCondition[nIndex].gc_delay_wait_icisr()  # [IMCodeElement]ICISR起動待ちのために遅延処理するコード
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフック中に処理単位が起動する
    #         コアかどうかを返す
    #=================================================================
    def check_active_on_startup_shutdown(nCoreid)
      check_class(Integer, nCoreid)  # チェックするコアID

      return @aActivateCoreOnStartupShutdown[nCoreid]  # [Bool]処理単位が起動するコアかどうか
    end

    #=================================================================
    # 概  要: OS起動直後に終了/再起動状態かどうかを返す
    #=================================================================
    def check_terminate_restart_osap()
      return @cPreCondition.check_terminate_restart_osap() # [Array]OS起動直後に終了/再起動状態となるOSAPのID一覧
    end
  end
end
