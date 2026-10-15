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
# $Id: IMCodeElement.rb 1961 2015-07-10 05:06:18Z t_ishikawa $

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

module CommonModule

  #==================================================================
  # クラス名: IMCodeElement
  # 概    要: IntermediateCodeが解釈できる形式で中間コードの要素を格納
  #           するクラス
  #==================================================================
  class IMCodeElement
    include CommonModule

    # リネームできないオブジェクトを2つ以上登録しないための確認用配列
    @@aSetAppMode = []
    @@aSetMemMod  = []
    @@aSetMemArea = []
    @@aSetMemSec  = []

    #================================================================
    # 概  要: コンストラクタ．
    #         指定したタイプのエレメントを生成する
    #================================================================
    def initialize(lMode = :block)
      check_class(Symbol, lMode) # 生成したコードをBlock化するか共通部に挿入するか（デフォルト :block）

      @aElement = []           # 要素を保持
      @cConf    = Config.new() # コンフィグを取得

      # モードの設定
      if (lMode == :block || :common)
        @lMode = lMode
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

    end
    attr_reader :aElement, :lMode


    #================================================================
    # 概  要: システムサービス呼び出しと戻り値のチェックを行うコードの
    #         要素を保持する
    #================================================================
    def set_syscall(hProcUnitInfo, sSyscall, snbReturn = "E_OK", sVarType = TYP_STATUS)
      check_class(Hash, hProcUnitInfo)                       # コードを追加する処理単位情報
      check_class(String, sSyscall)                          # 追加するシステムサービス
      check_class([String, Integer, *Bool], snbReturn, true) # 想定される戻り値（デフォルト E_OK）
      check_class(String, sVarType)                          # 想定される戻り値の型（デフォルト TYP_ER）

      # 変数名を取得
      sVarName = GRP_VAR_TYPE[sVarType]

      # 戻り値のチェックを行う場合
      if (!snbReturn.nil?())
        @aElement.push({:atr => :api, :proc_unit => hProcUnitInfo, :syscall => sSyscall, :var => sVarName})
        set_local_var(hProcUnitInfo[:id], sVarName, sVarType)

        # 戻り値の型がTYP_STATUSの場合はcheck_ercd
        if (sVarType == TYP_STATUS)
          set_ercd(hProcUnitInfo, snbReturn, sVarName)
        # 戻り値の型がTYP_STATUS以外の場合はassert
        else
          set_assert(hProcUnitInfo, sVarName, snbReturn)
        end

      # 戻り値のチェックを行わない場合
      else
        # 呼び出し側で個別にチェックしているところがあるため
        set_local_var(hProcUnitInfo[:id], sVarName, sVarType)
        @aElement.push({:atr => :api, :proc_unit => hProcUnitInfo, :syscall => sSyscall, :var => sVarName})
      end
    end


    #================================================================
    # 概  要: TerminateTask()とChainTask()が正常系の場合、呼び出した
    #         TASKに戻らないことを確認するコードを保持
    #================================================================
    def set_assert_ter_chain(hProcUnitInfo)
      check_class(Hash, hProcUnitInfo)  # コードを追加する処理単位情報

      @aElement.push({:atr => :expression, :proc_unit => hProcUnitInfo, :code => "ASSERT(0);"})
    end


    #================================================================
    # 概  要: 状態参照API呼び出しと戻り値のチェックを行うコードの要素
    #         を保持する
    #================================================================
    def set_verify_api(hProcUnitInfo, sSyscall)
      check_class(Hash, hProcUnitInfo)  # コードを追加する処理単位情報
      check_class(String, sSyscall)     # 追加するシステムサービス

      # 変数名を取得
      sVarName = GRP_VAR_TYPE[TYP_STATUS]

      @aElement.push({:atr => :api, :proc_unit => hProcUnitInfo, :syscall => sSyscall, :var => sVarName})
      set_local_var(hProcUnitInfo[:id], sVarName, TYP_STATUS)
      set_assert(hProcUnitInfo, sVarName, "E_OK")
    end


    #================================================================
    # 概  要: assertチェックを行うコードの要素を保持する
    #================================================================
    def set_assert(hProcUnitInfo, sVar, snbValue)
      check_class(Hash, hProcUnitInfo)                # コードを追加する処理単位情報
      check_class(String, sVar)                       # assertによって確認する変数
      check_class([String, Integer, *Bool], snbValue) # assertによって確認する値

      @aElement.push({:atr => :assert, :proc_unit => hProcUnitInfo, :var => sVar, :value => snbValue})
    end


    #================================================================
    # 概  要: ercdチェックを行うコードの要素を保持する
    #================================================================
    def set_ercd(hProcUnitInfo, snbReturn, sVarName)
      check_class(Hash, hProcUnitInfo)  # コードを追加する処理単位情報
      check_class(String, snbReturn)    # ercdチェックによって確認する戻り値
      check_class(String, sVarName)     # ercdチェックによって確認する変数

      @aElement.push({:atr => :ercd, :proc_unit => hProcUnitInfo, :ret => snbReturn, :var => sVarName})
    end


    #================================================================
    # 概  要: 引数で与えた文字列をそのまま出力する要素を保持する．
    #         関数呼び出し，時間関連，割込み発生，CPU例外発生，syslog
    #         などのコードを追加したい場合での利用を想定
    #================================================================
    def set_code(hProcUnitInfo, sEvalCode, bExpression = true)
      check_class(Hash, hProcUnitInfo) # コードを追加する処理単位情報
      check_class(String, sEvalCode)   # 出力したいコード
      check_class(Bool, bExpression)   # コードが式であるかどうか（デフォルト：true）

      if (bExpression == true)
        # 式の場合は出力文字列にセミコロンを付与する
        sEvalCodeSemicolon = sEvalCode + ";"
        @aElement.push({:atr => :expression, :proc_unit => hProcUnitInfo, :code => sEvalCodeSemicolon})
      else
        # 文の場合はそのまま格納する
        @aElement.push({:atr => :statement, :proc_unit => hProcUnitInfo, :code => sEvalCode})
      end
    end


    #================================================================
    # 概  要: チェックポイントを挿入するコードの要素を保持する
    #================================================================
    def set_checkpoint(hProcUnitInfo, sSyncComment = nil)
      check_class(Hash, hProcUnitInfo)         # チェックポイントを追加する処理単位情報
      check_class(String, sSyncComment, true)  # マルチコアにおける同期用コメント

      if (@cConf.is_single?())
        @aElement.push({:atr => :check, :proc_unit => hProcUnitInfo})
      else
        if (!sSyncComment.nil?())
          set_comment(hProcUnitInfo, sSyncComment)
        end
        @aElement.push({:atr => :check_mc, :proc_unit => hProcUnitInfo})
      end
    end


    #================================================================
    # 概  要: ゼロチェックポイントを挿入するコードの要素を保持する
    #================================================================
    def set_checkpoint_zero(hProcUnitInfo)
      check_class(Hash, hProcUnitInfo) # チェックポイントを追加する処理単位情報

      if (@cConf.is_single?())
        @aElement.push({:atr => :check_zero, :proc_unit => hProcUnitInfo})
      else
        @aElement.push({:atr => :check_zero_mc, :proc_unit => hProcUnitInfo})
      end
    end


    #================================================================
    # 概  要: チェックポイントを待つコードの要素を保持する
    #================================================================
    def wait_checkpoint(hProcUnitInfo, nCoreid = nil, sSyncComment = nil)
      check_class(Hash, hProcUnitInfo)         # チェックポイントを待つ処理単位情報
      check_class(Integer, nCoreid, true)      # 待つ対象のチェックポイントのコアID
      check_class(String, sSyncComment, true)  # マルチコアにおける同期用コメント

      if (@cConf.is_single?())
        @aElement.push({:atr => :wait, :proc_unit => hProcUnitInfo})
      else
        # システム定義のシャットダウンフックの場合は，マスタコアのみを待てばよい
        if (nCoreid == nil)
          nCoreid = @cConf.get_master_core();
        end
        if (!sSyncComment.nil?())
          set_comment(hProcUnitInfo, sSyncComment)
        end
        @aElement.push({:atr => :wait_mc, :proc_unit => hProcUnitInfo, :coreid => nCoreid})
      end

    end


    #================================================================
    # 概  要: 最終チェックポイントを挿入するコードの要素を保持する
    #================================================================
    def set_checkfinish(hProcUnitInfo)
      check_class(Hash, hProcUnitInfo) # チェックポイントを追加する処理単位情報

      if (@cConf.enable_check_stack_usage() == true)
        set_print_stack_usage(hProcUnitInfo)
      end

      if (@cConf.is_single?())
        @aElement.push({:atr => :check_finish, :proc_unit => hProcUnitInfo})
      else
        @aElement.push({:atr => :check_finish_mc, :proc_unit => hProcUnitInfo})
      end
    end


    #================================================================
    # 概  要: StateSyncを行うコードの要素を保持する
    #================================================================
    def set_state_sync(hProcUnitInfo, sTargetTask, sTargetState, sSyncComment)
      check_class(Hash, hProcUnitInfo)   # waitCPを追加する処理単位情報
      check_class(String, sTargetTask)   # 待ち対象タスクID
      check_class(String, sTargetState)  # 待ち対象状態
      check_class(String, sSyncComment)  # マルチコアにおける同期用コメント

      if (!@cConf.is_multi?())
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      set_comment(hProcUnitInfo, sSyncComment)
      set_code(hProcUnitInfo, "#{FNC_STATE_SYNC}(#{sTargetTask}, #{sTargetState})")
    end


    #================================================================
    # 概  要: WaitFinishSyncを行うコードの要素を保持する
    #================================================================
    def set_wait_finish_sync(hProcUnitInfo)
      check_class(Hash, hProcUnitInfo)  # WaitFinishSyncを追加する処理単位情報

      if (!@cConf.is_multi?())
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      set_code(hProcUnitInfo, "#{FNC_WAIT_FINISH_SYNC}(\"#{hProcUnitInfo[:id]}\")")
    end


    #================================================================
    # 概  要: BarrierSyncを行うコードの要素を保持する
    #================================================================
    def set_barrier_sync(aProcUnitInfo, sSyncComment)
      check_class(Array, aProcUnitInfo)  # バリア同期を追加する処理単位情報の配列
      check_class(String, sSyncComment)  # マルチコアにおける同期用コメント

      if (!@cConf.is_multi?())
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      aProcUnitInfo.each{|hProcUnitInfo|
        set_comment(hProcUnitInfo, sSyncComment)
        @aElement.push({:atr => :barrier, :proc_unit => hProcUnitInfo, :num => aProcUnitInfo.size})
      }
    end


    #================================================================
    # 概  要: 遅延処理を行うコードの要素を保持する
    #================================================================
    def set_delay_loop(hProcUnitInfo, sComment)
      check_class(Hash, hProcUnitInfo)  # 遅延処理を行う処理単位情報
      check_class(String, sComment)     # 出力するコメント

      set_comment(hProcUnitInfo, sComment)
      set_local_var(hProcUnitInfo[:id], "loop", TYP_VOLATILE_UINT32)
      set_code(hProcUnitInfo, "for (loop = 0; loop < #{@cConf.get_wait_spin_loop()}; loop++)")
    end


    #================================================================
    # 概  要: 処理単位名と最終的な起動回数をを保持する
    #================================================================
    def set_proc_unit(sProcUnitID, nFinalBootCnt = 0)
      check_class(String, sProcUnitID)    # 追加する処理単位ID
      check_class(Integer, nFinalBootCnt) # 最終的な起動回数

      @aElement.push({:atr => :proc_unit, :proc_unit_id => sProcUnitID, :fbootcnt => nFinalBootCnt})
    end


    #================================================================
    # 概  要: ローカル変数宣言コードの要素を保持する
    #================================================================
    def set_local_var(sProcUnitID, sVarName, sVarType, snVarValue = nil)
      check_class(String, sProcUnitID)                 # コメントを追加する処理単位ID
      check_class(String, sVarName)                    # 変数名
      check_class(String, sVarType)                    # 変数の型
      check_class([String, Integer], snVarValue, true) # 変数の初期値

      @aElement.push({:atr => :localvar, :proc_unit_id => sProcUnitID, :name => sVarName, :type => sVarType, :value => snVarValue})
    end


    #================================================================
    # 概  要: グローバル変数宣言コードの要素を保持する
    #================================================================
    def set_global_var(sVarName, sVarType, snVarValue = nil)
      check_class(String, sVarName)                           # 変数名
      check_class(String, sVarType)                           # 変数の型
      check_class([String, Integer, *Bool], snVarValue, true) # 変数の初期値

      @aElement.push({:atr => :globalvar, :name => sVarName, :type => sVarType, :value => snVarValue})
    end

    #================================================================
    # 概  要: 構造体変数宣言コードの要素を保持する
    #================================================================
    def set_struct_def(sStructName, aMember, sTypedef)
      check_class(String, sStructName)    # 変数の型
      check_class(Array, aMember)          # 変数の型(typedef)
      check_class(String, sTypedef)       # メンバの型

      @aElement.push({:atr => :struct_def, :name => sStructName, :member => aMember, :typedef => sTypedef})
    end

    #================================================================
    # 概  要: プロトタイプ宣言コードの要素を保持する
    #================================================================
    def set_header(sProcUnitID, sObjectType, aFuncArgs = nil)
      check_class(String, sProcUnitID)    # プロトタイプ宣言に追加する処理単位
      check_class(String, sObjectType)    # 処理単位のオブジェクトタイプ（関数の場合はIMC_FUNC_TYPE）
      check_class(Array, aFuncArgs, true) # 引数の配列（関数の場合のみ）

      @aElement.push({:atr => :header, :proc_unit_id => sProcUnitID, :type => sObjectType, :args => aFuncArgs})
    end


    #================================================================
    # 概  要: 静的APIの文字列に改行を入れる
    #================================================================
    def set_sapi_return(sOsap = IMC_NO_OSAP)
      check_class(String, sOsap, true)  # 追加する対象OSAP

      @aElement.push({:atr => :config, :code => "", :osap => sOsap})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsOS)の要素を保持する
    #================================================================
    def set_cfg_os(hHookInfo)
      check_class(Hash, hHookInfo)  # コンフィギュレーション情報

      hOsInfo = {XML_P_SCAL_CLASS     => @cConf.get_scalability_class(),
                 XML_P_TIM_PRO_LVL    => @cConf.get_timing_protection_level(),
                 XML_P_MEM_PRO_LVL    => @cConf.get_memory_protection_level(),
                 XML_P_VIO_HAND_LVL   => @cConf.get_violation_handling_level(),
                 XML_P_STK_MON        => @cConf.enable_stack_monitoring(),
                 XML_P_STATUS         => @cConf.get_return_status(),
                 XML_P_USE_GET_SRV_ID => @cConf.enable_use_get_serviceid(),
                 XML_P_USE_PARAM_ACC  => @cConf.enable_use_parameter_access(),
                 XML_P_CORE_NUM       => @cConf.get_core_num(),
                 XML_P_MASTER_CORE_ID => @cConf.get_master_core()}

      ### 静的API用処理
      sNumCore = ""
      if (@cConf.is_multi?())
        sNumCore = ", #{@cConf.get_core_num()}"
      end
      sStaticAPI = "#{SAPI_DEF_OS}(#{hOsInfo[XML_P_SCAL_CLASS]}, #{hOsInfo[XML_P_TIM_PRO_LVL]}, #{hOsInfo[XML_P_MEM_PRO_LVL]}, #{hOsInfo[XML_P_VIO_HAND_LVL]}, #{hOsInfo[XML_P_STK_MON].to_s.upcase()}, #{hOsInfo[XML_P_USE_GET_SRV_ID].to_s.upcase()}, #{hOsInfo[XML_P_USE_PARAM_ACC].to_s.upcase()}, #{hOsInfo[XML_P_STATUS]}#{sNumCore});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
      sStaticAPI = "#{SAPI_DEF_HOOK}(#{hHookInfo[XML_P_STA_HOOK].to_s.upcase()}, #{hHookInfo[XML_P_SHU_HOOK].to_s.upcase()}, #{hHookInfo[XML_P_PRE_HOOK].to_s.upcase()}, #{hHookInfo[XML_P_POS_HOOK].to_s.upcase()}, #{hHookInfo[XML_P_ERR_HOOK].to_s.upcase()}, #{hHookInfo[XML_P_PRO_HOOK].to_s.upcase()});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
      if (@cConf.is_single?())
        sStaticAPI = "#{SAPI_DEF_HSTK}(AKTSP_HOOK_STACK_SIZE, NULL);"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
      else
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          sStaticAPI = "#{SAPI_DEF_HSTK}(AKTSP_HOOK_STACK_SIZE, NULL, #{AUTOSAR_CORE_ID_PREFIX}#{nCoreid});"
          @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
        }
      end

      sOsStack = "NULL"
      sNtStack = "NULL"
      if (@cConf.enable_stack_share_mode() == true)
        # スタックオーバーフローしても問題が発生しないようにバッファ分ずらして定義する
        sOsStack = "aktg_os_stack+AKTSP_BUFFER_STACK_SIZE"
        sNtStack = "aktg_nt_hstack"
      end

      # 割込み用スタックサイズ指定(スタック共有の有無でアドレス指定のみ変える)
      if (@cConf.is_single?())
        sStaticAPI = "#{SAPI_DEF_OSTK}(AKTSP_OS_STACK_SIZE, #{sOsStack});"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
      else
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          if (@cConf.enable_stack_share_mode() == true)
            sOsStack = "AKTG_OS_STACK_ADDRESS_CORE_#{nCoreid}"
          end
          sStaticAPI = "#{SAPI_DEF_OSTK}(AKTSP_OS_STACK_SIZE, #{sOsStack}, #{AUTOSAR_CORE_ID_PREFIX}#{nCoreid});"
          @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
        }
      end

      # 非信頼フックのスタックサイズ指定(スタック共有の有無でアドレス指定のみ変える)
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        if (@cConf.is_single?())
          sStaticAPI = "#{SAPI_DEF_NTHSTK}(AKTSP_NTHOOK_STACK_SIZE, #{sNtStack});"
          @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
        else
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (@cConf.enable_stack_share_mode() == true)
              sNtStack = "aktg_nt_hstack[#{nCoreid}]"
            end
            sStaticAPI = "#{SAPI_DEF_NTHSTK}(AKTSP_NTHOOK_STACK_SIZE, #{sNtStack}, #{nCoreid});"
            @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
          }
        end
      end
      # SC3/SC4では，スタック共有の場合のみ，リンクセクションを行う
      if ((@cConf.enable_stack_share_mode() == true) && (@cConf.is_sc3?() || @cConf.is_sc4?()))
        sStaticAPI = "#{SAPI_LNK_SEC}(\".stack_section\", \"#{@cConf.get_nt_stack_region()}\");"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})
      end


      ### XML用処理
      cContainer = make_container(XML_C_OS, XML_C_OS, true, false, true)

      if (@cConf.is_multi?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_CORE_NUM, hOsInfo[XML_P_CORE_NUM], XML_C_OS))
        if (@cConf.is_target_spec_nos?())
          cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_MASTER_CORE_ID, hOsInfo[XML_P_MASTER_CORE_ID], XML_C_OS))
        end
      end
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_STK_MON, hOsInfo[XML_P_STK_MON].to_s(), XML_C_OS))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_STATUS, hOsInfo[XML_P_STATUS], XML_C_OS))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_USE_GET_SRV_ID, hOsInfo[XML_P_USE_GET_SRV_ID].to_s(), XML_C_OS))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_USE_PARAM_ACC, hOsInfo[XML_P_USE_PARAM_ACC].to_s(), XML_C_OS))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_SCAL_CLASS, hOsInfo[XML_P_SCAL_CLASS], XML_C_OS))
      if (@cConf.is_sc2?() && @cConf.is_target_spec_nos?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_TIM_PRO_LVL, hOsInfo[XML_P_TIM_PRO_LVL], XML_C_OS))
      end
      if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_target_spec_nos?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_MEM_PRO_LVL, hOsInfo[XML_P_MEM_PRO_LVL], XML_C_OS))
      end
      if (!@cConf.is_sc1?() && @cConf.is_target_spec_nos?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_VIO_HAND_LVL, hOsInfo[XML_P_VIO_HAND_LVL], XML_C_OS))
      end

      # サブコンテナ追加
      cParam = make_container(XML_C_HOOKS, XML_C_HOOKS, true, false, false, XML_C_OS)
      XML_P_GROUP_HOOK.each{|sHook|
        cParam.elements[XML_PARAM].add_element(make_parameter(sHook, hHookInfo[sHook].to_s(), "#{XML_C_OS}/#{XML_C_HOOKS}"))
      }
      cContainer.elements[XML_SUB].add_element(cParam)

      if (@cConf.is_single?())
        cParam = make_container(XML_C_HOOKSTK, XML_C_HOOKSTK, true, false, false, XML_C_OS)
        cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_HOOKSTK_SZ, "AKTSP_HOOK_STACK_SIZE", "#{XML_C_OS}/#{XML_C_HOOKSTK}"))
        cContainer.elements[XML_SUB].add_element(cParam)
      else
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          cParam = make_container("#{XML_C_HOOKSTK}_#{nCoreid.to_s()}", XML_C_HOOKSTK, true, false, false, XML_C_OS)
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_HOOKSTK_SZ, "AKTSP_HOOK_STACK_SIZE", "#{XML_C_OS}/#{XML_C_HOOKSTK}"))
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_HOOKSTK_CORE, "#{AUTOSAR_CORE_ID_PREFIX}#{nCoreid}", "#{XML_C_OS}/#{XML_C_HOOKSTK}"))
          cContainer.elements[XML_SUB].add_element(cParam)
        }
      end
      
      # 時間パーティショニング用コンテナ作成
      if(@cConf.is_time_partitioning?())
        cParam1 = make_container(XML_C_SCYC, XML_C_SCYC, true, false, true, XML_C_OS)
        cParam1.elements[XML_PARAM].add_element(make_parameter(XML_P_SCYC_TIM, @cConf.get_system_cycle_time(), "#{XML_C_OS}/#{XML_C_SCYC}"))
        cParam2 = make_container("TWD1", XML_P_SCYC_TWD, true, false, false, "#{XML_C_OS}/#{XML_C_SCYC}")
        cParam2.elements[XML_PARAM].add_element(make_parameter(XML_P_SCYC_TWD_STA, @cConf.get_system_cycle_time_window_start(), "#{XML_C_OS}/#{XML_C_SCYC}/#{XML_P_SCYC_TWD}"))
        cParam2.elements[XML_PARAM].add_element(make_parameter(XML_P_SCYC_TWD_LEN, @cConf.get_system_cycle_time_window_length(), "#{XML_C_OS}/#{XML_C_SCYC}/#{XML_P_SCYC_TWD}"))
        cParam1.elements[XML_SUB].add_element(cParam2)
        cContainer.elements[XML_SUB].add_element(cParam1)
        
        hMacro = @cConf.get_macro()
        @aElement.push({:atr => :add_osap, :osap => "DUMMY_OSAP", :coreid => hMacro[@cConf.get_core_id_from_osap("DUMMY_OSAP")]})        
        @aElement.push({:atr => :xml_osap, :osap => "DUMMY_OSAP", :id => "TWD1", :type => TSR_OBJ_TIME_WINDOW})
      end

      # 割込み用スタックサイズ指定(スタック共有の有無でアドレス指定のみ変える)
      if (@cConf.is_single?())
        cParam = make_container(XML_C_OSSTK, XML_C_OSSTK, true, false, false, XML_C_OS)
        cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_OSSTK_SZ, "AKTSP_OS_STACK_SIZE", "#{XML_C_OS}/#{XML_C_OSSTK}"))
        cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_OSSTK_ADD, sOsStack, "#{XML_C_OS}/#{XML_C_OSSTK}"))
        cContainer.elements[XML_SUB].add_element(cParam)
      else
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          if (@cConf.enable_stack_share_mode() == true)
            sOsStack = "aktg_os_stack[#{nCoreid}]+AKTSP_BUFFER_STACK_SIZE"
          end
          cParam = make_container("#{XML_C_OSSTK}_#{nCoreid.to_s()}", XML_C_OSSTK, true, false, false, XML_C_OS)
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_OSSTK_SZ, "AKTSP_OS_STACK_SIZE", "#{XML_C_OS}/#{XML_C_OSSTK}"))
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_OSSTK_ADD, sOsStack, "#{XML_C_OS}/#{XML_C_OSSTK}"))
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_OSSTK_CORE, "#{AUTOSAR_CORE_ID_PREFIX}#{nCoreid}", "#{XML_C_OS}/#{XML_C_OSSTK}"))
          cContainer.elements[XML_SUB].add_element(cParam)
        }
      end
      # 非信頼フックのスタックサイズ指定(スタック共有の有無でアドレス指定のみ変える)
=begin
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        if (@cConf.is_single?())
          cParam = make_container(XML_C_NTHOOKSTK, XML_C_NTHOOKSTK, true, false, false, XML_C_OS)
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_NTHOOKSTK_SZ, "AKTSP_NTHOOK_STACK_SIZE", "#{XML_C_OS}/#{XML_C_NTHOOKSTK}"))
          cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_NTHOOKSTK_ADD, sNtStack, "#{XML_C_OS}/#{XML_C_NTHOOKSTK}"))
          cContainer.elements[XML_SUB].add_element(cParam)
        else
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (@cConf.enable_stack_share_mode() == true)
              sNtStack = "aktg_nt_hstack[#{nCoreid}]"
            end
            cParam = make_container("#{XML_C_NTHOOKSTK}_#{nCoreid.to_s()}", XML_C_NTHOOKSTK, true, false, false, XML_C_OS)
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_NTHOOKSTK_SZ, "AKTSP_NTHOOK_STACK_SIZE", "#{XML_C_OS}/#{XML_C_NTHOOKSTK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_NTHOOKSTK_ADD, sNtStack, "#{XML_C_OS}/#{XML_C_NTHOOKSTK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_NTHOOKSTK_CORE, nCoreid, "#{XML_C_OS}/#{XML_C_NTHOOKSTK}"))
            cContainer.elements[XML_SUB].add_element(cParam)
          }
        end
      end
=end
      @aElement.push({:atr => :xml, :container => cContainer, :osap => IMC_NO_OSAP})

      # SC3/SC4では，スタック共有の場合のみ，リンクセクションを行う
      if ((@cConf.enable_stack_share_mode() == true) && (@cConf.is_sc3?() || @cConf.is_sc4?()))
        cContainer = make_container(XML_C_LNK_SEC, XML_C_LNK_SEC, true, true, false)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_L_NAME, ".stack_section", XML_C_LNK_SEC))
        cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_L_MEM_REG, @cConf.get_nt_stack_region(), XML_C_LNK_SEC, true))
        @aElement.push({:atr => :xml, :container => cContainer, :osap => IMC_NO_OSAP})
      end
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsAppMode)の要素を保持する
    #================================================================
    def set_cfg_app_mode(sAppMode)
      check_class(String, sAppMode)  # アプリケーションモード名

      # 既に登録済みの場合，何もしない
      if (@@aSetAppMode.include?(sAppMode))
        return
      else
        @@aSetAppMode.push(sAppMode)
      end

      ### 静的API用処理
      sStaticAPI = "#{SAPI_CRE_APP}(#{sAppMode});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_NO_OSAP})

      ### XML用処理
      cContainer = make_container(sAppMode, XML_C_APP_MODE, false, false, false)
      @aElement.push({:atr => :xml, :container => cContainer, :osap => IMC_NO_OSAP})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsTask)の要素を保持する
    #================================================================
    def set_cfg_tsk(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sSStack = ""
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        sSStack = ", #{hInfo[XML_P_T_SSTKSZ]}, #{hInfo[XML_P_T_SSTKADD]}"
      end
      sStaticAPI = "#{SAPI_CRE_TSK}(#{hInfo[XML_SNAME]}, #{hInfo[XML_P_T_PRI]}, #{hInfo[XML_P_T_ACT]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_T_SCHE]]}, #{hInfo[XML_P_T_STKSZ]}, #{hInfo[XML_P_T_STKADD]}#{sSStack}, {"
      if (!hInfo[XML_P_T_APP_MODE].nil?())
        hInfo[XML_P_T_APP_MODE].sort.each{|sAppMpde|
          sStaticAPI += "#{sAppMpde}, "
        }
        sStaticAPI.chop!().chop!()
      end
      sStaticAPI += "},"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
      make_sapi_list(hInfo[XML_P_T_EVT], hInfo[:osap])
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        make_sapi_list(hInfo[XML_P_T_RES], hInfo[:osap], true)
      else
        make_sapi_list(hInfo[XML_P_T_RES], hInfo[:osap], false)
        make_sapi_list(hInfo[XML_P_T_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_T_ACC_APP].nil?() && !hInfo[XML_P_T_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_T_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理

      # リソースorイベントorOSAP参照がある場合のみ参照が必要
      bIsRefer = false
      if (!hInfo[XML_P_T_RES].nil?() || !hInfo[XML_P_T_EVT].nil?() || !hInfo[XML_P_T_ACC_APP].nil?())
        bIsRefer = true
      end
      # 自動起動の場合のみサブコンテナが必要
      bIsSub = false
      if (!hInfo[XML_P_T_APP_MODE].nil?())
        bIsSub = true
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_TSK, true, bIsRefer, bIsSub)

      # タスクのパラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_ACT, hInfo[XML_P_T_ACT].to_s(), XML_C_TSK))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_PRI, hInfo[XML_P_T_PRI].to_s(), XML_C_TSK))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_SCHE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_T_SCHE]], XML_C_TSK))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_STKSZ, hInfo[XML_P_T_STKSZ].to_s(), XML_C_TSK))
      if (hInfo[XML_P_T_STKADD] != "NULL")
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_STKADD, hInfo[XML_P_T_STKADD].to_s(), XML_C_TSK))
      end
      if (hInfo[XML_P_T_SSTKSZ] != 0)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_SSTKSZ, hInfo[XML_P_T_SSTKSZ].to_s(), XML_C_TSK))
      end
      if (hInfo[XML_P_T_SSTKADD] != "NULL")
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_T_SSTKADD, hInfo[XML_P_T_SSTKADD].to_s(), XML_C_TSK))
      end

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_T_ACC_APP].nil?())
        hInfo[XML_P_T_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_T_ACC_APP, sOsap, XML_C_TSK, true))
        }
      end

      # リソースへの参照パラメータ追加
      if (!hInfo[XML_P_T_RES].nil?())
        hInfo[XML_P_T_RES].sort.each{|sRes|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_T_RES, sRes, XML_C_TSK, true))
        }
      end

      # イベントへの参照パラメータ追加
      if (!hInfo[XML_P_T_EVT].nil?())
        hInfo[XML_P_T_EVT].sort.each{|sEvt|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_T_EVT, sEvt, XML_C_TSK, true))
        }
      end

      # サブコンテナ追加
      if (!hInfo[XML_P_T_APP_MODE].nil?())
        cParam = make_container(XML_C_T_AUTO_STA, XML_C_T_AUTO_STA, false, true, false, XML_C_TSK)
        hInfo[XML_P_T_APP_MODE].sort.each{|sAppMpde|
          cParam.elements[XML_REFER].add_element(make_parameter(XML_P_T_APP_MODE, sAppMpde, "#{XML_C_TSK}/#{XML_C_T_AUTO_STA}", true))
        }
        cContainer.elements[XML_SUB].add_element(cParam)
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      if (hInfo[:restart] == true)
        @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_RESTART_TASK})
      else
        @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_TASK})
      end
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsIsr)の要素を保持する
    #================================================================
    def set_cfg_isr(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sStaticAPI = "#{SAPI_CRE_ISR}(#{hInfo[XML_SNAME]}, #{hInfo[XML_P_I_CAT]}, #{hInfo[XML_P_I_NUM]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_I_SRC]]}, #{hInfo[XML_P_I_PRI]}, #{hInfo[XML_P_I_STKSZ]},"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        make_sapi_list(hInfo[XML_P_I_RES], hInfo[:osap], true)
      else
        make_sapi_list(hInfo[XML_P_I_RES], hInfo[:osap], false)
        make_sapi_list(hInfo[XML_P_I_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_I_ACC_APP].nil?() && !hInfo[XML_P_I_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_I_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理

      # リソースorイベントorOSAP参照がある場合のみ参照が必要
      bIsRefer = false
      if (!hInfo[XML_P_I_RES].nil?() || !hInfo[XML_P_I_ACC_APP].nil?())
        bIsRefer = true
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_ISR, true, bIsRefer, false)

      # ISRのパラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_CAT, hInfo[XML_P_I_CAT], XML_C_ISR))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_NUM, hInfo[XML_P_I_NUM].to_s(), XML_C_ISR))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_PRI, hInfo[XML_P_I_PRI].to_s(), XML_C_ISR))
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_SRC, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_I_SRC]], XML_C_ISR))
      else
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_SRC, "ENABLE" , XML_C_ISR))
      end
      if (hInfo[XML_P_I_CAT] == XML_ISR_TYPE_2)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_I_STKSZ, hInfo[XML_P_I_STKSZ].to_s(), XML_C_ISR))
      end

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_I_ACC_APP].nil?())
        hInfo[XML_P_I_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_I_ACC_APP, sOsap, XML_C_ISR, true))
        }
      end

      # リソースへの参照パラメータ追加
      if (!hInfo[XML_P_I_RES].nil?())
        hInfo[XML_P_I_RES].sort.each{|sRes|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_I_RES, sRes, XML_C_ISR, true))
        }
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      # ISRは一括りなので一律C2ISRで区別する
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_C2ISR})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsEvent)の要素を保持する
    #================================================================
    def set_cfg_evt(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      if (hInfo[XML_P_E_MASK] == TSR_STT_AUTO)
        sStaticAPI = "#{SAPI_CRE_EVT}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_E_MASK]]});"
      else
        sStaticAPI = "#{SAPI_CRE_EVT}(#{hInfo[XML_SNAME]}, #{hInfo[XML_P_E_MASK]});"
      end
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})


      ### XML用処理

      # イベントマスクが指定されている場合のみパラメータが必要
      if (hInfo[XML_P_E_MASK] != TSR_STT_AUTO)
        bIsParam = true
      else
        bIsParam = false
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_EVT, bIsParam, false, false)

      # イベントマスク追加
      if (hInfo[XML_P_E_MASK] != TSR_STT_AUTO)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_E_MASK, hInfo[XML_P_E_MASK], XML_C_EVT))
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsResource)の要素を保持する
    #================================================================
    def set_cfg_res(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sLink = "NULL"
      if (!hInfo[XML_P_R_LINK].nil?())
        sLink = hInfo[XML_P_R_LINK]
      end
      sStaticAPI = "#{SAPI_CRE_RES}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_R_PROP]]}, #{sLink}"
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        sStaticAPI += ");"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})
      else
        sStaticAPI += ", "
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})
        make_sapi_list(hInfo[XML_P_R_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_R_ACC_APP].nil?() && !hInfo[XML_P_R_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_R_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理

      # リンクリソースの場合orOSAP参照がある場合は参照が必要
      if (!hInfo[XML_P_R_LINK].nil?() || !hInfo[XML_P_R_ACC_APP].nil?())
        bIsRefer = true
      else
        bIsRefer = false
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_RES, true, bIsRefer, false)

      # リソースのパラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_R_PROP, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_R_PROP]], XML_C_RES))

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_R_ACC_APP].nil?())
        hInfo[XML_P_R_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_R_ACC_APP, sOsap, XML_C_RES, true))
        }
      end

      # リソースへの参照パラメータ追加
      if (!hInfo[XML_P_R_LINK].nil?())
        cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_R_LINK, hInfo[XML_P_R_LINK], XML_C_RES, true))
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_RESOURCE})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsCounter)の要素を保持する
    #================================================================
    def set_cfg_cnt(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sIsr = "NULL"
      nTick = 0
      if (hInfo[XML_P_C_TYPE] == TSR_STT_HARDWARE)
        sIsr = hInfo[XML_P_C_ISR]
        nTick = (hInfo[XML_P_C_SEC_TICK] * 1000000000).truncate()
      end
      sStaticAPI = "#{SAPI_CRE_CNT}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_C_TYPE]]}, #{hInfo[XML_P_C_MIN_CYC]}, #{hInfo[XML_P_C_MAX_VAL]}, #{hInfo[XML_P_C_TIC_BASE]}, #{sIsr}, #{nTick}"
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        sStaticAPI += ");"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
      else
        sStaticAPI += ", "
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
        make_sapi_list(hInfo[XML_P_C_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_C_ACC_APP].nil?() && !hInfo[XML_P_C_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_C_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理

      # ハードウェアカウンタの場合orOSAP参照がある場合は参照が必要
      if ((hInfo[XML_P_C_TYPE] == TSR_STT_HARDWARE) || !hInfo[XML_P_C_ACC_APP].nil?())
        bIsRefer = true
      else
        bIsRefer = false
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_CNT, true, bIsRefer, false)

      # カウンタのパラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_C_MAX_VAL, hInfo[XML_P_C_MAX_VAL], XML_C_CNT))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_C_MIN_CYC, hInfo[XML_P_C_MIN_CYC], XML_C_CNT))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_C_TIC_BASE, hInfo[XML_P_C_TIC_BASE], XML_C_CNT))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_C_TYPE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_C_TYPE]], XML_C_CNT))

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_C_ACC_APP].nil?())
        hInfo[XML_P_C_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_C_ACC_APP, sOsap, XML_C_CNT, true))
        }
      end

      # ハードウェアカウンタのパラメータ追加
      if (hInfo[XML_P_C_TYPE] == TSR_STT_HARDWARE)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_C_SEC_TICK, hInfo[XML_P_C_SEC_TICK], XML_C_CNT))
        cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_C_ISR, hInfo[XML_P_C_ISR], XML_C_CNT, true))
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_COUNTER})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsAlarm)の要素を保持する
    #================================================================
    def set_cfg_alm(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sTask = "NULL"
      if (!hInfo[XML_P_A_ACT_TSK].nil?())
        sTask = hInfo[XML_P_A_ACT_TSK]
      end
      sEvent = "NULL"
      if (!hInfo[XML_P_A_SET_EVT].nil?())
        sEvent = hInfo[XML_P_A_SET_EVT]
      end
      sCallBack = "NULL"
      if (!hInfo[XML_P_A_CBACK].nil?())
        sCallBack = hInfo[XML_P_A_CBACK]
      end
      sInCounter = "NULL"
      if (!hInfo[XML_P_A_INCR_CNT].nil?())
        sInCounter = hInfo[XML_P_A_INCR_CNT]
      end
      sStaticAPI = "#{SAPI_CRE_ALM}(#{hInfo[XML_SNAME]}, #{hInfo[XML_P_A_CNT]}, #{hInfo[XML_P_A_ALM_TIM]}, #{hInfo[XML_P_A_CYC_TIM]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_A_STA_TYP]]}, #{CONVERT_TESRY_TO_ATK2[hInfo[:action_mode]]}, #{sTask}, #{sEvent}, #{sCallBack}, #{sInCounter}, {"
      if (!hInfo[XML_P_A_APP_MODE].nil?())
        hInfo[XML_P_A_APP_MODE].sort.each{|sAppMpde|
          sStaticAPI += "#{sAppMpde}, "
        }
        sStaticAPI.chop!().chop!()
      end
      sStaticAPI += "}"
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        sStaticAPI += ");"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
      else
        sStaticAPI += ", "
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
        make_sapi_list(hInfo[XML_P_A_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_A_ACC_APP].nil?() && !hInfo[XML_P_A_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_A_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理
      cContainer = make_container(hInfo[XML_SNAME], XML_C_ALM, false, true, true)

      # カウンタのパラメータ追加
      cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_A_CNT, hInfo[XML_P_A_CNT], XML_C_ALM, true))

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_A_ACC_APP].nil?())
        hInfo[XML_P_A_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_A_ACC_APP, sOsap, XML_C_ALM, true))
        }
      end

      # サブコンテナ追加
      cParam1 = make_container(XML_C_A_ACT, XML_C_A_ACT, false, false, true, XML_C_ALM)

      # サブサブコンテナ追加
      if (!hInfo[XML_P_A_INCR_CNT].nil?())
        cParam2 = make_container(XML_C_A_INCR_CNT, XML_C_A_INCR_CNT, false, true, false, "#{XML_C_ALM}/#{XML_C_A_ACT}")
        cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_A_INCR_CNT, hInfo[XML_P_A_INCR_CNT], "#{XML_C_ALM}/#{XML_C_A_ACT}/#{XML_C_A_INCR_CNT}", true))
      elsif (!hInfo[XML_P_A_CBACK].nil?())
        cParam2 = make_container(XML_C_A_CBACK, XML_C_A_CBACK, true, false, false, "#{XML_C_ALM}/#{XML_C_A_ACT}")
        cParam2.elements[XML_PARAM].add_element(make_parameter(XML_P_A_CBACK, hInfo[XML_P_A_CBACK], "#{XML_C_ALM}/#{XML_C_A_ACT}/#{XML_C_A_CBACK}"))
      elsif (!hInfo[XML_P_A_SET_EVT].nil?())
        cParam2 = make_container(XML_C_A_SET_EVT, XML_C_A_SET_EVT, false, true, false, "#{XML_C_ALM}/#{XML_C_A_ACT}")
        cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_A_EVT_TSK, hInfo[XML_P_A_EVT_TSK], "#{XML_C_ALM}/#{XML_C_A_ACT}/#{XML_C_A_SET_EVT}", true))
        cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_A_SET_EVT, hInfo[XML_P_A_SET_EVT], "#{XML_C_ALM}/#{XML_C_A_ACT}/#{XML_C_A_SET_EVT}", true))
      else
        cParam2 = make_container(XML_C_A_ACT_TSK, XML_C_A_ACT_TSK, false, true, false, "#{XML_C_ALM}/#{XML_C_A_ACT}")
        cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_A_ACT_TSK, hInfo[XML_P_A_ACT_TSK], "#{XML_C_ALM}/#{XML_C_A_ACT}/#{XML_C_A_ACT_TSK}", true))
      end

      cParam1.elements[XML_SUB].add_element(cParam2)
      cContainer.elements[XML_SUB].add_element(cParam1)

      if (!hInfo[XML_P_A_APP_MODE].nil?())
        cParam3 = make_container(XML_C_A_AUTO_STA, XML_C_A_AUTO_STA, true, true, false, XML_C_ALM)
        cParam3.elements[XML_PARAM].add_element(make_parameter(XML_P_A_ALM_TIM, hInfo[XML_P_A_ALM_TIM], "#{XML_C_ALM}/#{XML_C_A_AUTO_STA}"))
        hInfo[XML_P_A_APP_MODE].sort.each{|sAppMpde|
          cParam3.elements[XML_REFER].add_element(make_parameter(XML_P_A_APP_MODE, sAppMpde, "#{XML_C_ALM}/#{XML_C_A_AUTO_STA}", true))
        }
        cParam3.elements[XML_PARAM].add_element(make_parameter(XML_P_A_CYC_TIM, hInfo[XML_P_A_CYC_TIM], "#{XML_C_ALM}/#{XML_C_A_AUTO_STA}"))
        cParam3.elements[XML_PARAM].add_element(make_parameter(XML_P_A_STA_TYP, CONVERT_TESRY_TO_ATK2[hInfo[XML_P_A_STA_TYP]], "#{XML_C_ALM}/#{XML_C_A_AUTO_STA}"))
        cContainer.elements[XML_SUB].add_element(cParam3)
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_ALARM})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsScheduleTable)の要素を保持する
    #================================================================
    def set_cfg_schtbl(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sStaticAPI = "#{SAPI_CRE_SCHTBL}(#{hInfo[XML_SNAME]}, #{hInfo[XML_P_S_CNT]}, #{hInfo[XML_P_S_STA_VAL]}, #{hInfo[XML_P_S_DUR]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_S_REP]]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_S_STA_TYP]]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_S_STRATEGY]]}, {"
      if (!hInfo[XML_P_S_APP_MODE].nil?())
        hInfo[XML_P_S_APP_MODE].sort.each{|sAppMpde|
          sStaticAPI += "#{sAppMpde}, "
        }
        sStaticAPI.chop!().chop!()
      end
      sStaticAPI += "}"
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        sStaticAPI += ");"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
      else
        sStaticAPI += ", "
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
        make_sapi_list(hInfo[XML_P_S_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_S_ACC_APP].nil?() && !hInfo[XML_P_S_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_S_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end
      hInfo[:expire_points].each{|cExpoint|
        if (!cExpoint.aActtsk.nil?())
          cExpoint.aActtsk.each{|sTask|
            sStaticAPI = "#{SAPI_DEF_EXPIREPT}(#{hInfo[XML_SNAME]}, #{cExpoint.nOffset}, ACTIVATETASK, #{sTask}, NULL);"
            @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})
          }
        end
        if (!cExpoint.aSetevt.nil?())
          cExpoint.aSetevt.each{|hAction|
            hAction.each{|sTask, sEvent|
              sStaticAPI = "#{SAPI_DEF_EXPIREPT}(#{hInfo[XML_SNAME]}, #{cExpoint.nOffset}, SETEVENT, #{sTask}, #{sEvent});"
              @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})
            }
          }
        end
      }

      ### XML用処理
      cContainer = make_container(hInfo[XML_SNAME], XML_C_SCHTBL, true, true, true)

      # スケジュールテーブルのパラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_DUR, hInfo[XML_P_S_DUR], XML_C_SCHTBL))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_REP, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_REP]], XML_C_SCHTBL))
      cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_S_CNT, hInfo[XML_P_S_CNT], XML_C_SCHTBL, true))

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_S_ACC_APP].nil?())
        hInfo[XML_P_S_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_S_ACC_APP, sOsap, XML_C_SCHTBL, true))
        }
      end

      # サブコンテナ追加
      nCntExp = 0
      hInfo[:expire_points].each{|cExpoint|
        cParam1 = make_container("#{XML_C_S_EXP_PT}_#{nCntExp.to_s()}", XML_C_S_EXP_PT, true, false, true, XML_C_SCHTBL)
        cParam1.elements[XML_PARAM].add_element(make_parameter(XML_P_S_OFFSET, cExpoint.nOffset, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}"))
        nCntExp += 1

        # サブサブコンテナ追加
        if (!cExpoint.aActtsk.nil?())
          nCntAct = 0
          cExpoint.aActtsk.each{|sTask|
            cParam2 = make_container("#{XML_C_S_ACT_TSK}_#{nCntAct.to_s()}", XML_C_S_ACT_TSK, false, true, false, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}")
            cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_S_ACT_TSK, sTask, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}/#{XML_C_S_ACT_TSK}", true))
            cParam1.elements[XML_SUB].add_element(cParam2)
            nCntAct += 1
          }
        end
        if (!cExpoint.aSetevt.nil?())
          nCntSet = 0
          cExpoint.aSetevt.each{|hAction|
            hAction.each{|sTask, sEvent|
              cParam2 = make_container("#{XML_C_S_SET_EVT}_#{nCntSet.to_s()}", XML_C_S_SET_EVT, false, true, false, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}")
              cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_S_SET_EVT, sEvent, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}/#{XML_C_S_SET_EVT}", true))
              cParam2.elements[XML_REFER].add_element(make_parameter(XML_P_S_EVT_TSK, sTask, "#{XML_C_SCHTBL}/#{XML_C_S_EXP_PT}/#{XML_C_S_SET_EVT}", true))
              cParam1.elements[XML_SUB].add_element(cParam2)
              nCntSet += 1
            }
          }
        end

        cContainer.elements[XML_SUB].add_element(cParam1)
      }

      cParam = make_container(XML_C_S_SYNC, XML_C_S_SYNC, true, false, false, XML_C_SCHTBL)
      cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_S_STRATEGY, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_STRATEGY]], "#{XML_C_SCHTBL}/#{XML_C_S_SYNC}"))
      cContainer.elements[XML_SUB].add_element(cParam)

      if (!hInfo[XML_P_S_APP_MODE].nil?())
        cParam = make_container(XML_C_S_AUTO_STA, XML_C_S_AUTO_STA, true, true, false, XML_C_SCHTBL)
        cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_S_STA_VAL, hInfo[XML_P_S_STA_VAL], "#{XML_C_SCHTBL}/#{XML_C_S_AUTO_STA}"))
        cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_S_STA_TYP, CONVERT_TESRY_TO_ATK2[hInfo[XML_P_S_STA_TYP]], "#{XML_C_SCHTBL}/#{XML_C_S_AUTO_STA}"))
        hInfo[XML_P_S_APP_MODE].sort.each{|sAppMpde|
          cParam.elements[XML_REFER].add_element(make_parameter(XML_P_S_APP_MODE, sAppMpde, "#{XML_C_SCHTBL}/#{XML_C_S_AUTO_STA}", true))
        }
        cContainer.elements[XML_SUB].add_element(cParam)
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_SCHEDULE_TABLE})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsSpinlock)の要素を保持する
    #================================================================
    def set_cfg_spn(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sSuccessor = "NULL"
      if (!hInfo[XML_P_SP_SCCR].nil?())
        sSuccessor = hInfo[XML_P_SP_SCCR]
      end
      sStaticAPI = "#{SAPI_CRE_SPN}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_SP_SUS_INT]]}, #{sSuccessor}"
      sStaticAPI += ", "
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})
      make_sapi_list(hInfo[XML_P_SP_ACC_APP], hInfo[:osap], true)
      # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
      if (!hInfo[XML_P_SP_ACC_APP].nil?() && !hInfo[XML_P_SP_ACC_APP].empty?())
        hMacro = @cConf.get_macro()
        hInfo[XML_P_SP_ACC_APP].each{|sOasp|
          @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
        }
      end

      ### XML用処理

      # 割込み禁止オプションが指定されている場合のみパラメータが必要
      bIsParam = false
      if (!hInfo[XML_P_SP_SUS_INT].nil?())
        bIsParam = true
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_SPN, bIsParam, true, false)

      # スピンロックのパラメータ追加
      if (!hInfo[XML_P_SP_SUS_INT].nil?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_SP_SUS_INT, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_SP_SUS_INT]], XML_C_SPN, false))
      end

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_SP_ACC_APP].nil?())
        hInfo[XML_P_SP_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_SP_ACC_APP, sOsap, XML_C_SPN, true))
        }
      end

      # スピンロック(Successor)への参照パラメータ追加
      if (!hInfo[XML_P_SP_SCCR].nil?())
        cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_SP_SCCR, hInfo[XML_P_SP_SCCR], XML_C_SPN, true))
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_SPINLOCK})
    end


    #================================================================
    # 概  要: コンフィギュレーション(OsIoc)の要素を保持する
    #================================================================
    def set_cfg_ioc(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理(CRE_IOC)
      sStaticAPI = "#{SAPI_CRE_IOC}(#{hInfo[XML_SNAME]}, "

      # キューサイズ
      if (hInfo[XML_P_IOC_BUF_LEN] == 0)
        sStaticAPI += "NULL);"
      else
        sStaticAPI += "#{hInfo[XML_P_IOC_BUF_LEN]});"
      end

      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap]})


      ### 静的API用処理(DEF_IOC_SND)
      hInfo[XML_C_IOC_SND].each{|cIocSender|
        snSenderId = cIocSender.hState[TSR_PRM_SENDERID]
        if (snSenderId.nil?())
          snSenderId = "NULL"
        end
        sStaticAPI = "#{SAPI_DEF_IOC_SND}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[cIocSender.hState[TSR_PRM_KIND]]}, #{snSenderId});"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => cIocSender.hState[TSR_PRM_OSAP], :coreid => cIocSender.hState[TSR_PRM_COREID]})
      }


      ### 静的API用処理(DEF_IOC_RCV)
      cIocReceiver = hInfo[XML_C_IOC_RCV]
      sStaticAPI = "#{SAPI_DEF_IOC_RCV}(#{hInfo[XML_SNAME]}, #{CONVERT_TESRY_TO_ATK2[cIocReceiver.hState[TSR_PRM_KIND]]});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => cIocReceiver.hState[TSR_PRM_OSAP], :coreid => cIocReceiver.hState[TSR_PRM_COREID]})


      ### 静的API用処理(DEF_IOC_DATA)
      nCntData = 0
      hInfo[XML_C_IOC_DATA].each{|cIocData|
        sStaticAPI = "#{SAPI_DEF_IOC_DATA}(#{hInfo[XML_SNAME]}, {"

        # 引数の順序の有無
        if (hInfo[XML_C_IOC_DATA].length > 1)
          sStaticAPI += "#{nCntData}"
        else
          sStaticAPI += "NULL"
        end
        nCntData += 1

        # 初期値の有無
        if (!cIocData.hState[TSR_PRM_INITVAL].nil?())
          sStaticAPI += ", \"#{cIocData.hState[TSR_PRM_INITVAL]}\""
        else
          sStaticAPI += ", \"NULL\""
        end

        # データ型
        sStaticAPI += ", \"#{cIocData.hState[TSR_PRM_DATATYPE]}\""

        sStaticAPI += "});"

        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => IMC_IOC_OSAP})
      }


      ### XML用処理

      # キューサイズが指定されている場合のみパラメータが必要
      bIsParam = false
      if (hInfo[XML_P_IOC_BUF_LEN] != 0)
        bIsParam = true
      end

      # 1つのIOCに関する情報は，すべてOsIocCommunicationの中に含まれる
      cContainer = make_container(hInfo[XML_SNAME], XML_C_IOC_COM, bIsParam, false, true, XML_C_IOC)

      # キューサイズ追加
      if (hInfo[XML_P_IOC_BUF_LEN] != 0)
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_BUF_LEN, hInfo[XML_P_IOC_BUF_LEN], "#{XML_C_IOC}/#{XML_C_IOC_COM}"))
      end

      # センダ用サブコンテナ追加
      nCntSender = 0
      hInfo[XML_C_IOC_SND].each{|cIocSender|
        cSender = make_container("#{XML_C_IOC_SND}_#{nCntSender.to_s()}", XML_C_IOC_SND, true, true, false, "#{XML_C_IOC}/#{XML_C_IOC_COM}")
        cSender.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_SND_IMPL_KIND, CONVERT_TESRY_TO_ATK2[cIocSender.hState[TSR_PRM_KIND]], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_SND}", false))
        if (!cIocSender.hState[TSR_PRM_SENDERID].nil?())
          cSender.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_SND_ID, cIocSender.hState[TSR_PRM_SENDERID], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_SND}", false))
        end
        cSender.elements[XML_REFER].add_element(make_parameter(XML_P_IOC_SND_OSAP, cIocSender.hState[TSR_PRM_OSAP], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_SND}", true))
        cContainer.elements[XML_SUB].add_element(cSender)
        nCntSender += 1
      }

      # レシーバ用サブコンテナ追加
      cReceiver = make_container(XML_C_IOC_RCV, XML_C_IOC_RCV, true, true, false, "#{XML_C_IOC}/#{XML_C_IOC_COM}")
      cReceiver.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_RCV_IMPL_KIND, CONVERT_TESRY_TO_ATK2[cIocReceiver.hState[TSR_PRM_KIND]], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_RCV}", false))
      cReceiver.elements[XML_REFER].add_element(make_parameter(XML_P_IOC_RCV_OSAP, cIocReceiver.hState[TSR_PRM_OSAP], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_RCV}", true))
      cContainer.elements[XML_SUB].add_element(cReceiver)

      # データ用サブコンテナ追加
      nCntData = 0
      hInfo[XML_C_IOC_DATA].each{|cIocData|
        cSender = make_container("#{XML_C_IOC_DATA}_#{nCntData.to_s()}", XML_C_IOC_DATA, true, false, false, "#{XML_C_IOC}/#{XML_C_IOC_COM}")
        if (!cIocData.hState[TSR_PRM_INITVAL].nil?())
          cSender.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_INI_VAL, cIocData.hState[TSR_PRM_INITVAL], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_DATA}", false))
        end
        cSender.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_DATA_TYPE, XML_IMPL_DATA_TYPE_PACKAGE + cIocData.hState[TSR_PRM_DATATYPE], "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_DATA}", false))
        if (hInfo[XML_C_IOC_DATA].length > 1)
          cSender.elements[XML_PARAM].add_element(make_parameter(XML_P_IOC_DATA_INDEX, nCntData, "#{XML_C_IOC}/#{XML_C_IOC_COM}/#{XML_C_IOC_DATA}", false))
        end
        cContainer.elements[XML_SUB].add_element(cSender)
        nCntData += 1
      }

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
    end

    #======================================================================
    # 概  要: コンフィギュレーション(OsInterCoreInterrupt)の要素を保持する
    #======================================================================
    def set_cfg_icisr(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      sStaticAPI = "#{SAPI_DEF_ICI}(#{hInfo[XML_SNAME]}, "

      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        sStaticAPI += "#{hInfo[XML_P_IC_STKSZ]},"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
        make_sapi_list(hInfo[XML_P_IC_RES], hInfo[:osap], true)
      else
        sStaticAPI += "#{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_IC_SRC]]}, #{hInfo[XML_P_IC_STKSZ]},"
        @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})
        make_sapi_list(hInfo[XML_P_IC_RES], hInfo[:osap], false)
        make_sapi_list(hInfo[XML_P_IC_ACC_APP], hInfo[:osap], true)
        # アクセス可能なOSAPに所属するオブジェクトが存在しない可能性に備えて，OSAPを追加しておく
        if (!hInfo[XML_P_IC_ACC_APP].nil?() && !hInfo[XML_P_IC_ACC_APP].empty?())
          hMacro = @cConf.get_macro()
          hInfo[XML_P_IC_ACC_APP].each{|sOasp|
            @aElement.push({:atr => :add_osap, :osap => sOasp, :coreid => hMacro[@cConf.get_core_id_from_osap(sOasp)]})
          }
        end
      end

      ### XML用処理

      # リソースorイベントorOSAP参照がある場合のみ参照が必要
      bIsRefer = false
      if (!hInfo[XML_P_IC_RES].nil?() || !hInfo[XML_P_IC_ACC_APP].nil?())
        bIsRefer = true
      end
      cContainer = make_container(hInfo[XML_SNAME], XML_C_ICISR, true, bIsRefer, false)

      # ISRのパラメータ追加
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_IC_SRC, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_IC_SRC]], XML_C_ICISR))
      end
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_IC_STKSZ, hInfo[XML_P_IC_STKSZ].to_s(), XML_C_ICISR))

      # OSAPへの参照パラメータ追加
      if (!hInfo[XML_P_IC_ACC_APP].nil?())
        hInfo[XML_P_IC_ACC_APP].sort.each{|sOsap|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_IC_ACC_APP, sOsap, XML_C_ICISR, true))
        }
      end

      # リソースへの参照パラメータ追加
      if (!hInfo[XML_P_IC_RES].nil?())
        hInfo[XML_P_IC_RES].sort.each{|sRes|
          cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_IC_RES, sRes, XML_C_ICISR, true))
        }
      end

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_ICISR})
    end

    #================================================================
    # 概  要: コンフィギュレーション(信頼関数)の要素を保持する
    #================================================================
    def set_cfg_tfn(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      ### 静的API用処理
      # 信頼関数に登録する関数名の指定がある場合への対応
      sFuncName = "TRUSTED_#{hInfo[XML_SNAME]}"
      if (hInfo.has_key?(:funcname))
        sFuncName = hInfo[:funcname]
      end
      sStaticAPI = "#{SAPI_CRE_TFN}(#{hInfo[XML_SNAME]}, #{sFuncName}, #{hInfo[:stksz]});"
      hSapiData = {:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]}
      # 各コアにテスト用信頼関数を登録するためのOSAPへの対応
      if (hInfo.has_key?(:coreid))
        hSapiData[:coreid] = hInfo[:coreid]
      end
      @aElement.push(hSapiData)

      ### XML用処理
      @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_TRUSTED_FUNCTION, :funcname => sFuncName, :size => hInfo[:stksz]})
    end

    #================================================================
    # 概  要: メモリセクション情報(OsMemoryModule)の要素を保持する
    #================================================================
    def set_cfg_memmod(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      # 既に登録済みの場合，何もしない
      if (@@aSetMemMod.include?(hInfo[XML_P_M_NAME]))
        return
      else
        @@aSetMemMod.push(hInfo[XML_P_M_NAME])
      end

      ### 静的API用処理
      sStaticAPI = "#{SAPI_ATT_MOD}(\"#{hInfo[XML_P_M_NAME]}\", #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_M_EXPORT]]});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})

      ### XML用処理
      cContainer = make_container(hInfo[XML_SNAME], XML_C_MEM_MOD, true, false, false)

      # パラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_M_NAME, hInfo[XML_P_M_NAME], XML_C_MEM_MOD, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_M_EXPORT, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_M_EXPORT]], XML_C_MEM_MOD, false))

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      if (hInfo[:osap] != IMC_MEM_NO_OSAP)
        @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_MEMORY_MODULE})
      end
    end

    #================================================================
    # 概  要: メモリ領域属性(OSMemoryArea)の要素を保持する
    #================================================================
    def set_cfg_memarea(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      # 既に登録済みの場合，何もしない
      if (@@aSetMemArea.include?(hInfo[XML_P_A_ADD]))
        return
      else
        @@aSetMemArea.push(hInfo[XML_P_A_ADD])
      end

      ### 静的API用処理
      sStaticAPI = "#{SAPI_ATT_MEM}(#{hInfo[:mematr]}, #{hInfo[XML_P_A_ADD]}, #{hInfo[XML_P_A_SIZE]});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})

      ### XML用処理
      cContainer = make_container(hInfo[XML_SNAME], XML_C_MEM_AREA, true, false, false)

      # パラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_WRITE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_A_WRITE]], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_READ, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_A_READ]], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_EXEC, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_A_EXEC]], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_CACHE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_A_CACHE]], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_IODEV, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_A_IODEV]], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_ADD, hInfo[XML_P_A_ADD], XML_C_MEM_AREA, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_A_SIZE, hInfo[XML_P_A_SIZE], XML_C_MEM_AREA, false))

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      if (hInfo[:osap] != IMC_MEM_NO_OSAP)
        @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_MEMORY_AREA})
      end
    end

    #================================================================
    # 概  要: メモリセクション情報(OsMemorySection)の要素を保持する
    #================================================================
    def set_cfg_memsec(hInfo)
      check_class(Hash, hInfo)  # コンフィギュレーション情報

      # 既に登録済みの場合，何もしない
      if (@@aSetMemSec.include?(hInfo[XML_P_S_NAME]))
        return
      else
        @@aSetMemSec.push(hInfo[XML_P_S_NAME])
      end

      ### 静的API用処理
      sStaticAPI = "#{SAPI_ATT_SEC}(\"#{hInfo[XML_P_S_NAME]}\", #{hInfo[:mematr]}, \"#{hInfo[XML_P_S_REG]}\", #{CONVERT_TESRY_TO_ATK2[hInfo[XML_P_S_EXPORT]]});"
      @aElement.push({:atr => :config, :code => sStaticAPI, :osap => hInfo[:osap], :coreid => hInfo[:coreid]})

      ### XML用処理
      cContainer = make_container(hInfo[XML_SNAME], XML_C_MEM_SEC, true, true, false)

      # パラメータ追加
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_NAME, hInfo[XML_P_S_NAME], XML_C_MEM_SEC, false))
      cContainer.elements[XML_REFER].add_element(make_parameter(XML_P_S_REG, hInfo[XML_P_S_REG], XML_C_MEM_SEC, true))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_WRITE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_WRITE]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_READ, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_READ]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_EXEC, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_EXEC]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_SDATA, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_SDATA]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_MEMINI, hInfo[XML_P_S_MEMINI], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_CACHE, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_CACHE]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_IODEV, CONVERT_TESRY_TO_ARXML[hInfo[XML_P_S_IODEV]], XML_C_MEM_SEC, false))
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_S_EXPORT, hInfo[XML_P_S_EXPORT], XML_C_MEM_SEC, false))

      @aElement.push({:atr => :xml, :container => cContainer, :osap => hInfo[:osap]})
      if (hInfo[:osap] != IMC_MEM_NO_OSAP)
        @aElement.push({:atr => :xml_osap, :osap => hInfo[:osap], :id => hInfo[XML_SNAME], :type => TSR_OBJ_MEMORY_SECTION})
      end
    end

    #================================================================
    # 概  要: コメントコードの要素を保持する
    #================================================================
    def set_comment(hProcUnitInfo, sComment, lAtr = :comment)
      check_class(Hash, hProcUnitInfo) # コメントを追加する処理単位情報
      check_class(String, sComment)    # 追加するコメント
      check_class(Symbol, lAtr)        # 付与する属性（デフォルト :comment）

      @aElement.push({:atr => lAtr, :proc_unit => hProcUnitInfo, :code => sComment})
    end


    #================================================================
    # 概  要: ブロックの境界を挿入する命令を保持する
    #================================================================
    def set_block_delimiter()
      if (@lMode == :block)
        @aElement.push({:atr => :delimiter_cmd})
      end
    end


    #================================================================
    # 概  要: 以降の出力コードをインデントする命令を保持する
    #================================================================
    def set_indent(nTabs = 1)
      check_class(Integer, nTabs) # インデントの深さ（デフォルト 1）

      @aElement.push({:atr => :indent_cmd, :num => nTabs})
    end


    #================================================================
    # 概  要: インデント命令を解除する命令を保持する
    #================================================================
    def unset_indent()
      @aElement.push({:atr => :unindent_cmd})
    end


    #================================================================
    # 概  要: 関数定義の直後に出力するプレコードの要素を保持する
    #================================================================
    def set_pre_code(sProcUnitID, sPreCode, bExpression = true)
      check_class(String, sProcUnitID)  # コードを追加する処理単位ID
      check_class(String, sPreCode)     # 出力したいプレコード
      check_class(Bool, bExpression)    # コードが式であるかどうか（デフォルト：true）

      if (bExpression == true)
        # 式の場合は出力文字列にセミコロンを付与する
        sPreCodeSemicolon = sPreCode + ";"
        @aElement.push({:atr => :precode, :proc_unit => sProcUnitID, :code => sPreCodeSemicolon})
      else
        # 文の場合はそのまま格納する
        @aElement.push({:atr => :precode, :proc_unit => sProcUnitID, :code => sPreCode})
      end
    end


    #================================================================
    # 概  要: 関数定義の最後に出力するポストコードの要素を保持する
    #================================================================
    def set_post_code(sProcUnitID, sPostCode, bExpression = true)
      check_class(String, sProcUnitID)  # コードを追加する処理単位ID
      check_class(String, sPostCode)    # 出力したいポストコード
      check_class(Bool, bExpression)    # コードが式であるかどうか（デフォルト：true）

      if (bExpression == true)
        # 式の場合は出力文字列にセミコロンを付与する
        sPostCodeSemicolon = sPostCode + ";"
        @aElement.push({:atr => :postcode, :proc_unit => sProcUnitID, :code => sPostCodeSemicolon})
      else
        # 文の場合はそのまま格納する
        @aElement.push({:atr => :postcode, :proc_unit => sProcUnitID, :code => sPostCode})
      end
    end


    #================================================================
    # 概  要: OSAP固有のフック有無を保持する
    #================================================================
    def set_osap_hook(sOsapID, sHookType, sCoreid)
      check_class(String, sOsapID)              # 追加するOSAP
      check_class(String, sHookType)            # 追加するフック
      check_class([String, Integer], sCoreid)   # 追加するコアID

      @aElement.push({:atr => :osap_hook, :osap => sOsapID, :type => sHookType, :coreid => sCoreid})
    end


    #================================================================
    # 概  要: テストライブラリ初期化を行うコードの要素を保持する
    #================================================================
    def set_initialize_test_library(hProcUnitInfo, bIndent = false)
      check_class(Hash, hProcUnitInfo)  # テストライブラリ初期化を行う処理単位情報
      check_class(Bool, bIndent)        # インデントするかどうか

      sTab = ""
      if (bIndent == true)
        sTab = AKTG_TB
      end

      # テストライブラリ用変数初期化(必須)
      set_code(hProcUnitInfo, "#{sTab}#{FNC_INITIALIZE_TEST_LIB}")

      # スタック初期化
      if (@cConf.enable_check_stack_usage() == true)
        set_code(hProcUnitInfo, "#{sTab}#{FNC_OUTPUT_LOG_0}(\"Stack Initialize start.\")")

        if (@cConf.is_single?())
          set_code(hProcUnitInfo, "#{sTab}#{FNC_INITIALIZE_STACK}(aktg_os_stack+AKTSP_BUFFER_STACK_SIZE, AKTSP_OS_STACK_SIZE, TRUE)")
        else
          (0..@cConf.get_core_num()-1).each{|nID|
            set_code(hProcUnitInfo, "#{sTab}#{FNC_INITIALIZE_STACK}(AKTG_OS_STACK_ADDRESS_CORE_#{nID}, AKTSP_OS_STACK_SIZE, TRUE)")
          }
        end

        set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
        if (@cConf.is_single?())
          set_code(hProcUnitInfo, "#{sTab}#if AKTG_STACK_NUM != 0", false)
          set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < AKTG_STACK_NUM; i++) {", false)
          set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(aktg_stack[i], AKTSP_TASK_STACK_SIZE, FALSE)")
          set_code(hProcUnitInfo, "#{sTab}}", false)
          set_code(hProcUnitInfo, "#{sTab}#endif /* AKTG_STACK_NUM != 0 */", false)
        else
          set_code(hProcUnitInfo, "#{sTab}#if T_TASK_NUM_CORE0 != 0", false)
          set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < T_TASK_NUM_CORE0; i++) {", false)
          set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_STACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE, FALSE)")
          set_code(hProcUnitInfo, "#{sTab}}", false)
          set_code(hProcUnitInfo, "#{sTab}#endif /* T_TASK_NUM_CORE0 != 0 */", false)

          set_code(hProcUnitInfo, "#{sTab}#if T_TASK_NUM_CORE1 != 0", false)
          set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < T_TASK_NUM_CORE1; i++) {", false)
          set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_STACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE, FALSE)")
          set_code(hProcUnitInfo, "#{sTab}}", false)
          set_code(hProcUnitInfo, "#{sTab}#endif /* T_TASK_NUM_CORE1 != 0 */", false)
        end

        if (@cConf.is_sc3?() || @cConf.is_sc4?())
          if (@cConf.is_single?())
            set_code(hProcUnitInfo, "#{sTab}#if AKTG_USTACK_NUM != 0", false)
            set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < AKTG_USTACK_NUM; i++) {", false)
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(aktg_sstack[i], AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(aktg_ustack[i], AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}}", false)
            set_code(hProcUnitInfo, "#{sTab}#{FNC_INITIALIZE_STACK}(aktg_nt_hstack, AKTSP_NTHOOK_STACK_SIZE, TRUE)")
            set_code(hProcUnitInfo, "#{sTab}#endif /* AKTG_USTACK_NUM != 0 */", false)
          else
            set_code(hProcUnitInfo, "#{sTab}#if N_TASK_NUM_CORE0 != 0", false)
            set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < N_TASK_NUM_CORE0; i++) {", false)
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_SSTACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_USTACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}}", false)
            set_code(hProcUnitInfo, "#{sTab}#endif /* N_TASK_NUM_CORE0 != 0 */", false)

            set_code(hProcUnitInfo, "#{sTab}#if N_TASK_NUM_CORE1 != 0", false)
            set_code(hProcUnitInfo, "#{sTab}for (i = 0; i < N_TASK_NUM_CORE1; i++) {", false)
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_SSTACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}#{AKTG_TB}#{FNC_INITIALIZE_STACK}(AKTG_TASK_USTACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE, FALSE)")
            set_code(hProcUnitInfo, "#{sTab}}", false)
            set_code(hProcUnitInfo, "#{sTab}#endif /* N_TASK_NUM_CORE1 != 0 */", false)
            
            (0..@cConf.get_core_num()-1).each{|nCoreid|
              set_code(hProcUnitInfo, "#{sTab}#{FNC_INITIALIZE_STACK}(aktg_nt_hstack[#{nCoreid}], AKTSP_NTHOOK_STACK_SIZE, TRUE)")
            }
          end
        end

        set_code(hProcUnitInfo, "#{sTab}#{FNC_OUTPUT_LOG_0}(\"Stack Initialize end.\")")
      end

      # C++test初期化
      if (@cConf.is_enable_cpptest?())
        set_code(hProcUnitInfo, CPPTEST_INIT)
        # doの処理のみ計測する場合，_collectCoverage = 0に設定
        if (@cConf.is_cpptest_only_do?())
          set_code(hProcUnitInfo, CPPTEST_DISABLE)
        # 全ての処理を計測する場合，_collectCoverage = 1に設定
        else
          set_code(hProcUnitInfo, CPPTEST_ENABLE)
        end 
      end

      # GCOVを取得する場合，初期化する
      if (@cConf.is_enable_gcov?())
        set_code(hProcUnitInfo, FNC_GCOV_C_PAUSE)
      end
    end


    #================================================================
    # 概  要: スタック使用量表示を行うコードの要素を保持する
    #================================================================
    def set_print_stack_usage(hProcUnitInfo)
      check_class(Hash, hProcUnitInfo)  # スタック使用量表示を行う処理単位情報

      set_local_var(hProcUnitInfo[:id], "usage", TYP_UINT32)

      if (@cConf.is_single?())
        set_code(hProcUnitInfo, "usage = #{FNC_CHECK_STACK_USAGE}(aktg_os_stack+AKTSP_BUFFER_STACK_SIZE, AKTSP_OS_STACK_SIZE)")
        set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_3}(\"aktg_os_stack: %d / %d (%d%%)\", usage, AKTSP_OS_STACK_SIZE, (usage  * 100) / AKTSP_OS_STACK_SIZE)")
      else
        (0..@cConf.get_core_num()-1).each{|nID|
          set_code(hProcUnitInfo, "usage = #{FNC_CHECK_STACK_USAGE}(AKTG_OS_STACK_ADDRESS_CORE_#{nID}, AKTSP_OS_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_3}(\"aktg_os_stack[#{nID}]: %d / %d (%d%%)\", usage, AKTSP_OS_STACK_SIZE, (usage  * 100) / AKTSP_OS_STACK_SIZE)")
        }
      end

      set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
      if (@cConf.is_single?())
        set_code(hProcUnitInfo, "#if AKTG_STACK_NUM != 0", false)
        set_code(hProcUnitInfo, "for (i = 0; i < AKTG_STACK_NUM; i++) {", false)
        set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(aktg_stack[i], AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_stack[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "}", false)
        set_code(hProcUnitInfo, "#endif /* AKTG_STACK_NUM != 0 */", false)
      else
        set_code(hProcUnitInfo, "#if T_TASK_NUM_CORE0 != 0", false)
        set_code(hProcUnitInfo, "for (i = 0; i < T_TASK_NUM_CORE0; i++) {", false)
        set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_STACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_stack_core0[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "}", false)
        set_code(hProcUnitInfo, "#endif /* T_TASK_NUM_CORE0 != 0 */", false)

        set_code(hProcUnitInfo, "#if N_TASK_NUM_CORE1 != 0", false)
        set_code(hProcUnitInfo, "for (i = 0; i < N_TASK_NUM_CORE1; i++) {", false)
        set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_STACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_stack_core1[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
        set_code(hProcUnitInfo, "}", false)
        set_code(hProcUnitInfo, "#endif /* N_TASK_NUM_CORE1 != 0 */", false)
      end

      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        if (@cConf.is_single?())
          set_code(hProcUnitInfo, "#if AKTG_USTACK_NUM != 0", false)
          set_code(hProcUnitInfo, "for (i = 0; i < AKTG_USTACK_NUM; i++) {", false)
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(aktg_sstack[i], AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_sstack[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(aktg_ustack[i], AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_ustack[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "}", false)
          set_code(hProcUnitInfo, "#endif /* AKTG_USTACK_NUM != 0 */", false)

          set_code(hProcUnitInfo, "usage = #{FNC_CHECK_STACK_USAGE}(aktg_nt_hstack, AKTSP_NTHOOK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_3}(\"aktg_nt_hstack: %d / %d (%d%%)\", usage, AKTSP_NTHOOK_STACK_SIZE, (usage  * 100) / AKTSP_NTHOOK_STACK_SIZE)")
        else
          set_code(hProcUnitInfo, "#if N_TASK_NUM_CORE0 != 0", false)
          set_code(hProcUnitInfo, "for (i = 0; i < N_TASK_NUM_CORE0; i++) {", false)
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_SSTACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_sstack_core0[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_USTACK_ADDRESS_CORE_0(i), AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_ustack_core0[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "}", false)
          set_code(hProcUnitInfo, "#endif /* N_TASK_NUM_CORE0 != 0 */", false)

          set_code(hProcUnitInfo, "#if N_TASK_NUM_CORE1 != 0", false)
          set_code(hProcUnitInfo, "for (i = 0; i < N_TASK_NUM_CORE1; i++) {", false)
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_SSTACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_sstack_core1[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}usage = #{FNC_CHECK_STACK_USAGE}(AKTG_TASK_USTACK_ADDRESS_CORE_1(i), AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_4}(\"aktg_ustack_core1[%d]: %d / %d (%d%%)\", i, usage, AKTSP_TASK_STACK_SIZE, (usage  * 100) / AKTSP_TASK_STACK_SIZE)")
          set_code(hProcUnitInfo, "}", false)
          set_code(hProcUnitInfo, "#endif /* N_TASK_NUM_CORE1 != 0 */", false)

          (0..@cConf.get_core_num()-1).each{|nCoreid|
            set_code(hProcUnitInfo, "usage = #{FNC_CHECK_STACK_USAGE}(aktg_nt_hstack[#{nCoreid}], AKTSP_NTHOOK_STACK_SIZE)")
            set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_3}(\"aktg_nt_hstack[#{nCoreid}]: %d / %d (%d%%)\", usage, AKTSP_NTHOOK_STACK_SIZE, (usage  * 100) / AKTSP_NTHOOK_STACK_SIZE)")
          }
        end
      end
    end


    #================================================================
    # 概  要: リスト構造の静的APIを出力する
    #================================================================
    def make_sapi_list(aSapiInfo, sOsapID, bLastFlg = false)
      check_class(Array, aSapiInfo, true)  # 出力する静的APIのリスト
      check_class(String, sOsapID, true)   # 追加するOSAP
      check_class(Bool, bLastFlg)          # 最後の要素かどうか

      if (!aSapiInfo.nil?() && !aSapiInfo.empty?())
        aSapiInfo.sort.each_with_index{|sObjID, nIdx|
          sStaticAPI = "#{AKTG_TB}#{AKTG_TB}"
          if (nIdx == 0)
            sStaticAPI += "{"
          else
            sStaticAPI += " "
          end
          sStaticAPI += "#{sObjID},"
          if (nIdx == (aSapiInfo.size() - 1))
            sStaticAPI.chop!()
            sStaticAPI += "},"
            if (bLastFlg == true)
              sStaticAPI.chop!()
              sStaticAPI += ");"
            end
          end
          @aElement.push({:atr => :config, :code => sStaticAPI, :osap => sOsapID})
        }
      else
        if (bLastFlg == true)
          @aElement.push({:atr => :config, :code => "#{AKTG_TB}#{AKTG_TB}{});", :osap => sOsapID})
        else
          @aElement.push({:atr => :config, :code => "#{AKTG_TB}#{AKTG_TB}{},", :osap => sOsapID})
        end
      end
    end


    #================================================================
    # 概  要: IMCodeElementをppより見やすい形で整形して出力する
    #================================================================
    def p_code(lOption = :all)
      # [atr]         [proc]   [other parameters]
      # api           proc,    syscall,          var
      # ercd          proc,    ret,              var
      # assert        proc,                      var,     value
      # code          proc,    code
      # check(mp)     proc
      # zero          proc
      # finish(mp)    proc
      # waitcp        proc,    coreid
      # barrier       proc,    num
      # proc_unit     proc_id, fbootcnt
      # localvar      proc_id, name,    type,             value
      # globalvar              name,    type,             value
      # header        proc_id,          type,    var
      # config                 code,    class
      # comment       proc,    code
      # delimiter_cmd
      # precode       proc_id, code
      # postcode      proc_id, code
      puts "[atr]".center(15) + "|" + "[proc_unit]".center(14) + "|" + "[other_parameters]"
      puts "-" * 15 + "+" + "-" * 14 + "+" + "-" * 20
      @aElement.each{ |hElement|
        if (hElement[:atr] == :delimiter_cmd)
          puts ""; next
        end
        print "#{hElement[:atr]}".ljust(15) + "|"

        print "#{hElement[:proc_unit][:id].sub(/.*_(\w+\z)/, "\\1")}".ljust(8) + "|" if (hElement[:proc_unit])
        print "#{hElement[:proc_unit_id].sub(/.*_(\w+\z)/, "\\1")}".ljust(8)   + "|" if (hElement[:proc_unit_id])
        print "".ljust(8) + "|" unless (hElement[:proc_unit] || hElement[:proc_unit_id])
        print "#{hElement[:proc_unit][:bootcnt]}".ljust(2) + "|" if (hElement[:proc_unit])
        print "#{hElement[:proc_unit][:coreid]}".ljust(2)   + "|" if (hElement[:proc_unit])
        print "".ljust(2) + "|" + "".ljust(2) + "|" unless (hElement[:proc_unit])
        print "#{hElement[:syscall]}, "   if (hElement[:syscall])
        print "#{hElement[:ret]}, "       if (hElement[:ret])
        print "#{hElement[:code]}, "      if (hElement[:code])
        print "#{hElement[:coreid]}, "    if (hElement[:coreid])
        print "#{hElement[:num]}, "       if (hElement[:num])
        print "#{hElement[:fbootcnt]}, "  if (hElement[:fbootcnt])
        print "#{hElement[:name]}, "      if (hElement[:name])
        print "#{hElement[:type]}, "      if (hElement[:type])
        print "#{hElement[:var]}, "       if (hElement[:var])
        print "#{hElement[:value]}, "     if (hElement[:value])
        print "#{hElement[:code]}, "      if (hElement[:precode])
        print "#{hElement[:code]}, "      if (hElement[:postcode])
        puts ""
      }
    end

  end
end
