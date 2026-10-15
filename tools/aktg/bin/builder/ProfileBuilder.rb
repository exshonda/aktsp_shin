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
# $Id: ProfileBuilder.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/IMCodeElement.rb"
require "common/bin/test_scenario/TestScenario.rb"
require "bin/product/IntermediateCode.rb"

module AKTG

  #==================================================================
  # クラス名: ProfileBuilder
  # 概    要: Single / Multi Builderのスーパークラス
  #==================================================================
  class ProfileBuilder
    include CommonModule

    #================================================================
    # 概  要: コンストラクタ
    #================================================================
    def initialize()
      # 中間コードの初期化処理で全テストシナリオ共通の情報を追加する
      @cIMCode = IntermediateCode.new()

      @cConf = Config.new() # コンフィグを取得
    end

    #================================================================
    # 概  要: テストシナリオからスタートアップフックのコードを生成する
    #================================================================
    def build_startup_hook(cTestScenario)
      check_class(TestScenario, cTestScenario) # テストシナリオクラス

      hMainTask  = @cIMCode.hMainTask

      # 強制マージの場合はチェックポイントを初期化
      @cIMCode.reset_checkpoint()

      @cTS = cTestScenario.dup()
      @hTestMain = @cTS.get_main_task_proc() # メインタスクID取得

      # このテストシナリオに登場する処理単位の追加
      cElement = IMCodeElement.new(:common)
      cElement.set_proc_unit(@hTestMain[:id], @hTestMain[:bootcnt])
      @cTS.get_proc_units(cElement)

      # グローバル/ローカル変数宣言の追加(処理単位にTSR_PRM_VARが定義されているもの)
      @cTS.gc_global_local_var(cElement)

      # プロトタイプ宣言の追加
      cElement.set_header(@hTestMain[:id], IMC_FUNC_TYPE)
      @cTS.gc_header(cElement)

      # 静的API，XML情報の追加
      @cTS.gc_config(cElement)

      # 強制マージの場合，ENUMで実行中のテストIDを識別して処理を分ける
      if (@cConf.enable_forced_merge() == true)
        cElement.set_code(hMainTask, "#{AKTG_NL}#{AKTG_TB}if (#{AKTG_FORCE_MERGE_BOOTCNT} == #{AKTG_FORCE_MERGE_ENUM}_#{@cTS.sTestID}) {", false)
        cElement.set_indent()
      else
        cElement.set_code(hMainTask, "", false)
      end

      # テスト毎のメインタスクの呼出し(本質的には不要)
      # (リソースを獲得しないのでメインタスクのチェックはしない)
      cElement.set_code(hMainTask, "#{@hTestMain[:id]}()")

      # 強制マージの場合のインデントを終了しておく
      if (@cConf.enable_forced_merge() == true)
        cElement.unset_indent()
      end

      # ここまでの情報を中間コードへ格納する
      @cIMCode.add_element(cElement)

      # テストIDレベルを追加する
      @cIMCode.set_testid_level(@cTS.sTestID)

      # 必要なタスクスタックの個数をアップデート
      @cIMCode.update_stack_size(@cTS.get_stack_num())
      @cIMCode.update_ustack_size(@cTS.get_ustack_num())

      # 共有する処理単位がある場合，グローバル変数を定義，および対象テストIDをセット
      @cIMCode.add_element(build_global_var_for_shared_unit(true))

      # 信頼関数がある場合，返り値を返すコードを追加
      # (信頼関数が返り値を返すのはNOS仕様)
      if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_target_spec_nos?())
        @cIMCode.add_element(build_trusted_func_return_value())
      end

      # pre_conditionの設定
      build_pre_condition()

      # do，post_conditionの設定
      @cTS.get_do_post_index().each{|nIndex|
        # doの処理
        build_do(nIndex)

        # post_conditionの処理
        if (@cTS.check_lastpost_condition(nIndex) == true)
          build_lastpost_condition(nIndex)
        else
          build_post_condition(nIndex)
        end
      }

      # 実行状態のスタートアップ，シャットダウンフックの有無取得
      bIsStartupHook = false
      bIsShutdownHook = false
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
        bIsStartupHook = true
      end
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
        bIsShutdownHook = true
      end

      # 共有する処理単位がある場合，グローバル変数をクリア
      @cIMCode.add_element(build_global_var_clear(bIsStartupHook, bIsShutdownHook, true))
    end

    #================================================================
    # 概  要: テストシナリオからシャットダウンフックのコードを生成する
    #================================================================
    def build_shutdown_hook(cTestScenario, bLastFlg)
      check_class(TestScenario, cTestScenario) # テストシナリオクラス
      check_class(Bool, bLastFlg)              # 最後かどうか

      hMainTask  = @cIMCode.hMainTask

      # 強制マージの場合はチェックポイントを初期化
      @cIMCode.reset_checkpoint()

      @cTS = cTestScenario.dup()
      @hTestMain = @cTS.get_main_task_proc() # メインタスクID取得

      # このテストシナリオに登場する処理単位の追加
      cElement = IMCodeElement.new(:common)
      cElement.set_proc_unit(@hTestMain[:id], @hTestMain[:bootcnt])
      @cTS.get_proc_units(cElement)

      # グローバル/ローカル変数宣言の追加(処理単位にTSR_PRM_VARが定義されているもの)
      @cTS.gc_global_local_var(cElement)

      # プロトタイプ宣言の追加
      cElement.set_header(@hTestMain[:id], IMC_FUNC_TYPE)
      @cTS.gc_header(cElement)

      # 静的API，XML情報の追加
      @cTS.gc_config(cElement)

      # テスト毎のメインタスクの呼出し(本質的には不要)
      # (リソースを獲得しないのでメインタスクのチェックはしない)
      cElement.set_code(hMainTask, "#{@hTestMain[:id]}()")

      # ここまでの情報を中間コードへ格納する
      @cIMCode.add_element(cElement)

      # テストIDレベルを追加する
      @cIMCode.set_testid_level(@cTS.sTestID)

      # 必要なタスクスタックの個数をアップデート
      @cIMCode.update_stack_size(@cTS.get_stack_num())
      @cIMCode.update_ustack_size(@cTS.get_ustack_num())

      # 共有する処理単位がある場合，グローバル変数を定義，および対象テストIDをセット
      @cIMCode.add_element(build_global_var_for_shared_unit(true))

      # 信頼関数がある場合，返り値を返すコードを追加
      # (信頼関数が返り値を返すのはNOS仕様)
      if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_target_spec_nos?())
        @cIMCode.add_element(build_trusted_func_return_value())
      end

      # pre_conditionの設定
      build_pre_condition()

      # do，post_conditionの設定
      @cTS.get_do_post_index().each{|nIndex|
        # doの処理
        build_do(nIndex)

        # post_conditionの処理
        if (@cTS.check_lastpost_condition(nIndex) == true)
          build_lastpost_condition(nIndex)
        else
          build_post_condition(nIndex)
        end
      }

      # 実行状態のスタートアップ，シャットダウンフックの有無取得
      bIsStartupHook = false
      bIsShutdownHook = false
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
        bIsStartupHook = true
      end
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
        bIsShutdownHook = true
      end

      # 共有する処理単位がある場合，グローバル変数をクリア
      @cIMCode.add_element(build_global_var_clear(bIsStartupHook, bIsShutdownHook))

      # 最後のシャットダウンフックでカーネル終了処理を行う
      if ((bLastFlg == true) || (@cConf.enable_forced_merge() == true))
        @cIMCode.add_element(@cTS.gc_finish_cp_on_shutdown_hook())
      end
    end

    #================================================================
    # 概  要: 各フック，ハードウェアカウンタの有無からコンフィギュレー
    #         ションを設定する
    #================================================================
    def set_hook_and_hwcnt_info(hIsHookInfo, bIsHwcntInfo, aHwcntAccosap, sAppMode, aAppModeInfo, sRestartOsap)
      check_class(Hash, hIsHookInfo)          # 各フックの有無情報
      check_class(Bool, bIsHwcntInfo)         # ハードウェアカウンタの有無情報
      check_class(Array, aHwcntAccosap, true) # ハードウェアカウンタにアクセス可能なOSAP
      check_class(String, sAppMode)           # StartOSに指定するアプリケーションモード
      check_class(Array, aAppModeInfo)        # テストIDとアプリケーションモード
      check_class(String, sRestartOsap, true) # 起動後にすぐ再起動するOSAP

      @cIMCode.add_common_info(hIsHookInfo, bIsHwcntInfo, aHwcntAccosap, sAppMode, aAppModeInfo, sRestartOsap)
    end

    #================================================================
    # 概  要: テストシナリオから中間コードを生成する
    #================================================================
    def build(cTestScenario)
      check_class(TestScenario, cTestScenario)  # テストシナリオクラス

      # 強制マージの場合はチェックポイントを初期化
      @cIMCode.reset_checkpoint()

      @cTS = cTestScenario.dup()
      @hTestMain = @cTS.get_main_task_proc() # メインタスクID取得

      # テストシナリオ開始処理
      start_test_scenario()

      # pre_conditionの設定
      build_pre_condition()

      # do，post_conditionの設定
      @cTS.get_do_post_index().each{|nIndex|
        # doの処理
        build_do(nIndex)

        # post_conditionの処理
        if (@cTS.check_lastpost_condition(nIndex) == true)
          build_lastpost_condition(nIndex)
        else
          build_post_condition(nIndex)
        end
      }

      # 実行状態のスタートアップ，シャットダウンフックの有無取得
      bIsStartupHook = false
      bIsShutdownHook = false
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true))
        bIsStartupHook = true
      end
      if ((cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK) == true) ||
          (cTestScenario.exist_active_proc_unit(TSR_OBJ_SHUTDOWN_HOOK_OSAP) == true))
        bIsShutdownHook = true
      end

      # 共有する処理単位がある場合，グローバル変数をクリア
      @cIMCode.add_element(build_global_var_clear(bIsStartupHook, bIsShutdownHook, true))
    end

    #================================================================
    # 概  要: テストシナリオ開始処理
    #================================================================
    def start_test_scenario()
      hMainTask  = @cIMCode.hMainTask
      hCheckMain = @cIMCode.hCheckMain

      # このテストシナリオに登場する処理単位の追加
      # 最終的な起動回数の設定も同時に行う
      cElement = IMCodeElement.new(:common)
      cElement.set_proc_unit(@hTestMain[:id], @hTestMain[:bootcnt])
      @cTS.get_proc_units(cElement)

      # グローバル/ローカル変数宣言の追加(処理単位にTSR_PRM_VARが定義されているもの)
      @cTS.gc_global_local_var(cElement)

      # プロトタイプ宣言の追加
      cElement.set_header(@hTestMain[:id], IMC_FUNC_TYPE)
      @cTS.gc_header(cElement)

      # 静的API，XML情報の追加
      @cTS.gc_config(cElement)

      # 強制マージの場合，ENUMで実行中のテストIDを識別して処理を分ける
      if (@cConf.enable_forced_merge() == true)
        cElement.set_code(hMainTask, "#{AKTG_NL}#{AKTG_TB}if (#{AKTG_FORCE_MERGE_BOOTCNT} == #{AKTG_FORCE_MERGE_ENUM}_#{@cTS.sTestID}) {", false)
        cElement.set_indent()
      else
        cElement.set_code(hMainTask, "", false)
      end

      # テストID開始のsyslog出力
      # (マージできないテストケースではスタートアップ/シャットダウンフックで出力する)
      if ((@cTS.bCannotMerge == false) || (@cTS.exist_pre_active_shutdown_hook() == false))
        cElement.set_code(hMainTask, "#{FNC_OUTPUT_LOG_0}(\"#{@cTS.sTestID}: Start\")")
      end

      # ハードウェアカウンタがある場合，停止して初期化
      if (@cTS.exist_hwcnt() == true)
        hHwcntParam = @cConf.get_hardware_counter_param()
        cElement.set_syscall(hMainTask, "#{FNC_HWCOUNTER_STOP}(#{hHwcntParam[CFG_HWCNT_COUNTER_ID]})")
        cElement.set_syscall(hMainTask, "#{FNC_HWCOUNTER_INIT}(#{hHwcntParam[CFG_HWCNT_COUNTER_ID]})")
      end

      # ここまでのコードを中間コードへ追加
      @cIMCode.add_element(cElement)

      # 共有する処理単位がある場合，グローバル変数を定義，および対象テストIDをセット
      @cIMCode.add_element(build_global_var_for_shared_unit(false))

      # 信頼関数がある場合，返り値を返すコードを追加
      # (信頼関数が返り値を返すのはNOS仕様)
      if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_target_spec_nos?())
        @cIMCode.add_element(build_trusted_func_return_value())
      end

      cElement = IMCodeElement.new(:common)
      cElement.set_code(hMainTask, "#{@hTestMain[:id]}()")

      # メインタスクの状態チェック処理
      cElement.set_code(hMainTask, "#{hCheckMain[:id]}()")

      # ハードウェアカウンタがある場合，初期化して再開
      if (@cTS.exist_hwcnt() == true)
        hHwcntParam = @cConf.get_hardware_counter_param()
        cElement.set_syscall(hMainTask, "#{FNC_HWCOUNTER_INIT}(#{hHwcntParam[CFG_HWCNT_COUNTER_ID]})")
        cElement.set_syscall(hMainTask, "#{FNC_HWCOUNTER_START}(#{hHwcntParam[CFG_HWCNT_COUNTER_ID]})")
      end

      # テストID完了のsyslog出力
      # 1件のみのテストケースではスタートアップ/シャットダウンフックで出力するが，
      # OSが終了することが理由ではないマージ不可テストケースのために，ここでも出力しておく
      cElement.set_code(hMainTask, "#{FNC_OUTPUT_LOG_0}(\"#{@cTS.sTestID}: OK\")")

      # 強制マージの場合のインデントを終了しておく
      if (@cConf.enable_forced_merge() == true)
        cElement.unset_indent()
      end

      # ここまでのコードを中間コードへ追加
      @cIMCode.add_element(cElement)

      # テストIDレベルを追加する
      @cIMCode.set_testid_level(@cTS.sTestID)

      # 必要なタスクスタックの個数をアップデート
      @cIMCode.update_stack_size(@cTS.get_stack_num())
      @cIMCode.update_ustack_size(@cTS.get_ustack_num())
    end

    #================================================================
    # 概  要: checkfinishのコードを生成する
    #================================================================
    def build_finish_cp(bIsShutdownHook)
      check_class(Bool, bIsShutdownHook) # シャットダウンフック有無フラグ

      cElement = IMCodeElement.new(:common)

      sShutdownOSCode = SS_SHUTDOWN_OS
      if (@cConf.is_multi?())
        sShutdownOSCode = SS_SHUTDOWN_ALL
      end

      # シャットダウンフックが無ければ，check_finish
      if (bIsShutdownHook == false)
        # GCOV取得の終了
        if (@cConf.is_enable_gcov?())
          cElement.set_code(@cIMCode.hMainTask, FNC_GCOV_C_RESUME)
          cElement.set_code(@cIMCode.hMainTask, FNC_GCOV_C_DUMP)
        end

        # 強制マージの場合，シーケンス番号不明のためシャットダウンのみにする
        if (@cConf.enable_forced_merge() == false)
          cElement.set_checkfinish(@cIMCode.hMainTask)
        else
          cElement.set_code(@cIMCode.hMainTask, "#{sShutdownOSCode}(E_OK)")
        end
      # シャットダウンフックがあれば，check_point
      else
        # 強制マージの場合，シーケンス番号不明のためシャットダウンのみにする
        if (@cConf.enable_forced_merge() == false)
          cElement.set_checkpoint(@cIMCode.hMainTask)
        end
        cElement.set_code(@cIMCode.hMainTask, "#{sShutdownOSCode}(E_OK)")
      end

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: 関数を共有する処理単位の初期処理を行うコードを生成する
    #================================================================
    def build_shared_proc_unit(hSharedProcUnitInfo, sObjectType)
      check_class(Hash, hSharedProcUnitInfo) # 関数を共有する処理単位の情報
      check_class(String, sObjectType)       # 対象とする処理単位タイプ

      cElement = IMCodeElement.new()

      # 対象とする処理単位に必要な情報を定義
      hSharedProcUnitInfo.sort.each{|aObjectInfo|
        # 処理単位情報追加
        cElement.set_proc_unit(aObjectInfo[0])

        # プロトタイプ宣言の追加
        cElement.set_header(aObjectInfo[0], sObjectType)

        # 割込み(C1ISR/C2ISR)は一律先頭で割込み要求フラグクリア関数(開始時処理)を実行する
        if (GRP_PROCESS_UNIT_ISR.include?(sObjectType) && sObjectType != TSR_OBJ_ICISR)
          # 明示的な割込み要求クリア処理
          # (個々のデバイスに対する割込み要求のクリア処理/ターゲット依存)
          cElement.set_pre_code(aObjectInfo[0], "#{FNC_CLEAR_INT_REQ}(#{aObjectInfo[1].hState[TSR_PRM_INTNO]})")
        end

        # プレタスク/ポストタスクフックはelse文を使えないので，起動しないことを確認するためのコードを入れる
        if (GRP_PROCESS_UNIT_PRETASK_POSTTASK.include?(sObjectType))
          sVarName = "#{aObjectInfo[1].get_common_id()}_#{AKTG_CHECK_NO_BOOT}"
          cElement.set_global_var(sVarName, TYP_BOOL, "FALSE")
          cElement.set_pre_code(aObjectInfo[0], "if (#{sVarName} == TRUE) {", false)
          cElement.set_pre_code(aObjectInfo[0], "#{AKTG_TB}#{FNC_CHECK_ASSERT}(FALSE)")
          cElement.set_pre_code(aObjectInfo[0], "}", false)
        end

        # OSAP固有のシャットダウンフックの先頭に，異常が発生している場合の処理を入れる
        if (sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)
          cElement.set_local_var(aObjectInfo[0], VAR_STATE, TYP_UINT8)
          cElement.set_pre_code(aObjectInfo[0], "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
          cElement.set_pre_code(aObjectInfo[0], "if (#{VAR_STATE} == #{TSR_STT_FALSE}) {", false)
          cElement.set_pre_code(aObjectInfo[0], "#{AKTG_TB}return")
          cElement.set_pre_code(aObjectInfo[0], "}", false)
        end

        # マルチコアでは，プロテクションフックに戻り値を返す処理を入れる
        if (@cConf.is_multi?() && (sObjectType == TSR_OBJ_PROTECTION_HOOK))
          cElement.set_local_var(aObjectInfo[0], VAR_ERROR, TYP_PROTECT_RETURN, "PRO_IGNORE")
          cElement.set_post_code(aObjectInfo[0], "", false)
          cElement.set_post_code(aObjectInfo[0], "return(#{VAR_ERROR})")
        end
      }

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: 関数を共有する処理単位の静的APIを生成するコードを生成する
    #         (DEF_OS等を出力してから生成するために独立させている)
    #================================================================
    def config_shared_proc_unit(hSharedProcUnitInfo)
      check_class(Hash, hSharedProcUnitInfo) # 関数を共有する処理単位の情報

      cElement = IMCodeElement.new()

      # 対象とする処理単位に必要な情報を定義
      hSharedProcUnitInfo.sort.each{|aObjectInfo|
        # 静的API，XML情報の追加
        aObjectInfo[1].gc_config(cElement)
      }

      # SC3/SC4/全MCの場合，OSAP固有のフック情報を設定
      if (@cConf.enable_osap?())
        hSharedProcUnitInfo.each{|sObjectID, cObjectInfo|
          if ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP) ||
              (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) ||
              (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK_OSAP))
            cElement.set_osap_hook(cObjectInfo.hState[TSR_PRM_OSAP], cObjectInfo.sObjectType, cObjectInfo.hState[TSR_PRM_COREID])
          end
        }
      end

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: メインタスクの先頭でcp_stateをチェックするコードを生成する
    #================================================================
    def build_check_cp_state()
      cElement = IMCodeElement.new(:common)

      cElement.set_local_var(@cIMCode.hMainTask[:id], VAR_STATE, TYP_UINT8)
      cElement.set_code(@cIMCode.hMainTask, "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
      cElement.set_code(@cIMCode.hMainTask, "if (#{VAR_STATE} == #{TSR_STT_FALSE}) {", false)
      cElement.set_indent(1)
      if (@cConf.is_single?())
        cElement.set_code(@cIMCode.hMainTask, "#{SS_SHUTDOWN_OS}(E_OK)")
      elsif (@cConf.is_multi?())
        cElement.set_code(@cIMCode.hMainTask, "#{SS_SHUTDOWN_ALL}(E_OK)")
      end
      cElement.unset_indent()
      cElement.set_code(@cIMCode.hMainTask, "}", false)

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: メインタスクの先頭でOSAPを終了するコードを生成する
    #================================================================
    def build_terminate_osap(aOsapId)
      check_class(Array, aOsapId) # 終了するOSAPIDの一覧

      cElement = IMCodeElement.new(:common)

      aOsapId.each{|sOsapId|
        if (sOsapId == TSR_STT_NT_OSAP_RESTARTING)
          sRestart = "RESTART"
        else
          sRestart = "NO_RESTART"
        end
        cElement.set_syscall(@cIMCode.hMainTask, "#{SS_TER_APP}(#{sOsapId}, #{sRestart})")
      }

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: メインタスクの先頭でダミーリソースを獲得するコードを生成
    #         する
    #================================================================
    def build_get_dummy_resource()
      cElement = IMCodeElement.new(:common)

      cElement.set_syscall(@cIMCode.hMainTask, "#{SS_GET_RES}(#{AKTG_DUMMY_RES})")

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: メインタスクの最後にダミーリソースを解放するコードを生成
    #         する
    #================================================================
    def build_release_dummy_resource()
      cElement = IMCodeElement.new(:common)

      cElement.set_code(@cIMCode.hMainTask, "", false)
      cElement.set_syscall(@cIMCode.hMainTask, "#{SS_REL_RES}(#{AKTG_DUMMY_RES})")

      @cIMCode.add_element(cElement)
    end

    #================================================================
    # 概  要: 共有する処理単位がある場合，グローバル変数を定義，および
    #         対象テストIDをセット
    #================================================================
    def build_global_var_for_shared_unit(bForStartupShutdown)
      check_class(Bool, bForStartupShutdown)  # スタートアップ/シャットダウンフックかどうか

      cElement = IMCodeElement.new(:common)

      # グローバル変数を用意する共有関数が存在する場合のみ
      bChk = false
      GRP_GLOBAL_VAR_PROCESS_UNIT.each{|sProcUnitType|
        if (@cTS.exist_proc_unit(sProcUnitType) == true)
          hObjInfo = @cTS.get_all_object_info(sProcUnitType)
          hObjInfo.each{|sObjectID, cObjectInfo|
            sCommonID = cObjectInfo.get_common_id()
            cElement.set_global_var("#{sCommonID}_#{VAR_BOOTCNT}", "enum ENUM_#{sCommonID}", "#{sCommonID}_#{AKTG_ENUM_INVALID}")

            # プレ/ポストタスクフックは起動する箇所に設定する
            if (!GRP_PROCESS_UNIT_PRETASK_POSTTASK.include?(sProcUnitType))
              if (bForStartupShutdown == true)
                # スタートアップ/シャットダウンフックは，コア毎に独立して実行され，
                # 特定のコアしか実行されないことがあるため，バリア同期ができないことがある
                # つまり，該当テストケースの中で，スタートアップ/シャットダウンフック中で処理単位が
                # 起動するコアのbootcntのみを更新しないと，他のテストケースとの実行タイミングで
                # 他のテストケース用のbootcntが不正に更新されることがある
                # したがって，テストケース内で起動しないコアのbootcntは更新しない
                if  (@cConf.is_single?() || (@cTS.check_active_on_startup_shutdown(cObjectInfo.hState[TSR_PRM_COREID]) == true))
                  @cTS.set_hook_bootcnt_code("#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{@cTS.sTestID}")
                end
              else
                cElement.set_code(@cIMCode.hMainTask, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{@cTS.sTestID}")
              end
            end

            # プロテクションフックは返り値を返す
            if (sProcUnitType == TSR_OBJ_PROTECTION_HOOK)
              cElement.set_post_code(sObjectID, "return(PRO_IGNORE)")
            end
            bChk = true
          }
        end
      }

      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement]エレメント
    end

    #================================================================
    # 概  要: 共有する処理単位がある場合，グローバル変数をクリア
    #================================================================
    def build_global_var_clear(bIsStartupHook, bIsShutdownHook, bIsMainTask = false)
      check_class(Bool, bIsStartupHook)   # スタートアップフックがあるかどうか
      check_class(Bool, bIsShutdownHook)  # シャットダウンフックがあるかどうか
      check_class(Bool, bIsMainTask)      # テスト毎のメインタスクがあるかどうか

      cElement = IMCodeElement.new(:common)

      # グローバル変数を用意する共有関数が存在する場合のみ
      bChk = false
      GRP_GLOBAL_VAR_PROCESS_UNIT.each{|sProcUnitType|
        if (@cTS.exist_proc_unit(sProcUnitType) == true)
          hObjInfo = @cTS.get_all_object_info(sProcUnitType)
          hObjInfo.each{|sObjectID, cObjectInfo|
            sCommonID = cObjectInfo.get_common_id()

            # プレ/ポストタスクフックは起動する箇所に設定する
            if (!GRP_PROCESS_UNIT_PRETASK_POSTTASK.include?(sProcUnitType))
              if ((bIsStartupHook == true) || (bIsShutdownHook == true))
                # bootcnt設定と同様，処理単位が起動するコアに対してのみクリアを行う
                if  (@cConf.is_single?() || (@cTS.check_active_on_startup_shutdown(cObjectInfo.hState[TSR_PRM_COREID]) == true))
                  @cIMCode.add_element(@cTS.gc_hook_bootcnt_clear("#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{AKTG_ENUM_INVALID}"))
                end
              else
                # 強制マージの場合のテスト毎のif文用にインデントする
                if (@cConf.enable_forced_merge() == true)
                  cElement.set_indent()
                end
                cElement.set_code(@cIMCode.hMainTask, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{AKTG_ENUM_INVALID}")
                if (@cConf.enable_forced_merge() == true)
                  cElement.unset_indent()
                end
              end
              bChk = true
            end
          }
        end
      }

      # 強制マージの場合のテスト毎のif文の括弧を閉じる
      if ((@cConf.enable_forced_merge() == true) && (bIsMainTask == true))
        # シャットダウンフックがいなければ，ここでAktspCheckFinishする
        if (bIsShutdownHook == false)
          cElement.set_indent()
          cElement.set_checkfinish(@cIMCode.hMainTask)
          cElement.unset_indent()
        end
        cElement.set_code(@cIMCode.hMainTask, "}", false)
        bChk = true
      end

      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement]エレメント
    end

    #================================================================
    # 概  要: 信頼関数がある場合，返り値を返すコードを追加
    #================================================================
    def build_trusted_func_return_value()
      cElement = IMCodeElement.new(:common)

      bChk = false
      hObjInfo = @cTS.get_all_object_info(TSR_OBJ_TRUSTED_FUNCTION)
      hObjInfo.each{|sObjectID, cObjectInfo|
        # 返り値を返すのは，NOSサポート時のみ
        if (@cConf.is_target_spec_nos?())
          cElement.set_post_code(sObjectID, "return E_OK")
          bChk = true
        end
      }

      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement]エレメント
    end

    #================================================================
    # 概  要: リスタートタスクの情報を設定する
    #================================================================
    def set_restart_task_info(hSharedProcUnitInfo)
      check_class(Hash, hSharedProcUnitInfo) # リスタートタスクの情報

      hReTaskInfo = {}
      hSharedProcUnitInfo.each{|aObjectInfo|
        # OSAP毎にリスタートタスクを設定する
        hReTaskInfo[aObjectInfo[1].hState[TSR_PRM_OSAP]] = aObjectInfo[0]
      }
      @cIMCode.add_restart_task_osap(hReTaskInfo)
    end

    #================================================================
    # 概  要: 生成した中間コードを返す
    #================================================================
    def get_result()
      return @cIMCode  # [IntermediateCode]中間コード
    end

  end
end
