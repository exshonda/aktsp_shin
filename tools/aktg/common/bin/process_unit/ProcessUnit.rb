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
# $Id: ProcessUnit.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/process_unit/Variable.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/process_unit/ProcessUnit.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: ProcessUnit
  # 概    要: 処理単位オブジェクトの情報を処理するクラス
  #===================================================================
  class ProcessUnit
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: 処理単位オブジェクトの初期化
    #=================================================================
    def initialize_class(sObjectID, hObjectInfo, sObjectType, aPath, bIsPre)
      check_class(String, sObjectID)    # オブジェクトID
      check_class(Hash, hObjectInfo)    # オブジェクト情報
      check_class(String, sObjectType)  # オブジェクトタイプ
      check_class(Array, aPath)         # ルートからのパス
      check_class(Bool, bIsPre)         # pre_condition内か

      @cConf                  = Config.new()
      @hState                 = {}

      @sObjectID   = sObjectID
      @sObjectType = sObjectType
      @aPath       = aPath + [@sObjectID]

      @bConvertState = false  # state属性を内部保持用の値に置き換えたか(TESRYでTTS_RUNなど指定された場合にエラー検出できない)

      # 処理単位クラス共通部分
      @hState[TSR_PRM_STATE]       = nil  # ハンドラ状態[全処理単位]
      @hState[TSR_PRM_VAR]         = nil  # 変数情報[全処理単位]
      @hState[TSR_PRM_BOOTCNT]     = nil  # 処理単位の起動回数[タスク/C1ISR/C2ISR/アラームコールバック/ICISR/リスタートタスク]
      @hState[TSR_PRM_COREID]      = nil  # コアID[全処理単位]【TESRYデータには指定しない処理単位でも，内部的に保持しておく】
      @hState[TSR_PRM_RELRES]      = nil  # 関連づけされたリソース[タスク/C2ISR/ICISR/リスタートタスク]
      @hState[TSR_PRM_GETRES]      = nil  # 獲得済みリソース[タスク/C2ISR/信頼関数/ICISR/リスタートタスク]
      @hState[TSR_PRM_GETRESTFN]   = nil  # 信頼関数の獲得済みリソース[タスク/C2ISR/ICISR/リスタートタスク]※バックエンドで使用
      @hState[TSR_PRM_INTNO]       = nil  # 割込み番号[C1ISR/C2ISR]
      @hState[TSR_PRM_INIINTPRI]   = nil  # 初期割込み優先度[C1ISR/C2ISR]
      @hState[TSR_PRM_INTATR]      = nil  # 割込み属性[C1ISR/C2ISR/ICISR]
      @hState[TSR_PRM_ISTAT]       = nil  # 割込み要求禁止フラグ[C2ISR/ICISR]
      @hState[TSR_PRM_STKSZ]       = nil  # スタック領域のサイズ[タスク/信頼関数/リスタートタスク]
      @hState[TSR_PRM_ISTKSZ]      = nil  # スタック領域のサイズ[C2ISR/ICISR]
      @hState[TSR_PRM_OSAP]        = nil  # 所属するOSAP[タスク/C1ISR/C2ISR/OSAP固有のフック(スタートアップ/シャットダウン/エラーフック)/信頼関数/ICISR/リスタートタスク]
      @hState[TSR_PRM_ACCOSAP]     = nil  # アクセスを許可する非信頼OSAP[タスク/C2ISR/ICISR/リスタートタスク]
      @hState[TSR_PRM_SPNID]       = nil  # 取得待ちのスピンロック[タスク/C2ISR/信頼関数/ICISR/リスタートタスク]
      @hState[TSR_PRM_GETSPN]      = nil  # 取得済みのスピンロック[タスク/C2ISR/信頼関数/ICISR/リスタートタスク]
      @hState[TSR_PRM_GETSPNTFN]   = nil  # 信頼関数の獲得済みスピンロック[タスク/C2ISR/ICISR/リスタートタスク]※バックエンドで使用

      # TASK, RESTART_TASK
      @hState[TSR_PRM_CURPRI]    = nil  # 現在優先度
      @hState[TSR_PRM_INIPRI]    = nil  # 初期優先度
      @hState[TSR_PRM_TTYPE]     = nil  # タスクタイプ
      @hState[TSR_PRM_MAXACT]    = nil  # 起動要求の最大数
      @hState[TSR_PRM_SPOLICY]   = nil  # スケジューリングポリシ
      @hState[TSR_PRM_CUREVT]    = nil  # イベントの現在値
      @hState[TSR_PRM_WAIEVT]    = nil  # 待ち対象イベント
      @hState[TSR_PRM_WAIEVTTFN] = nil  # 信頼関数の待ち対象イベント
      @hState[TSR_PRM_ACTCNT]    = nil  # 起動要求数
      @hState[TSR_PRM_PORDER]    = nil  # レディキュー内順位
      @hState[TSR_PRM_RELEVT]    = nil  # 関連づけされたイベント
      @hState[TSR_PRM_STK]       = nil  # スタック領域の先頭番地
      @hState[TSR_PRM_SSTKSZ]    = nil  # システムスタック領域のサイズ
      @hState[TSR_PRM_SSTK]      = nil  # システムスタック領域の先頭番地
      @hState[TSR_PRM_APPMODE]   = nil  # アプリケーションモード

      # C2ISR
      @hState[TSR_PRM_CURINTPRI] = nil  # 現在割込み優先度

      # TRUSTEDFUNCTION
      @hState[TSR_PRM_CALLER] = nil  # 信頼関数を呼出した処理単位
      @hState[TSR_PRM_ARG]    = nil  # CallTrustedFunctionの第2引数名

      # ICISR
      @hState[TSR_PRM_ICISRNO] = nil # 登場するICISRの番号【TESRYデータには指定しない，内部的に保持しておく】

      pre_attribute_check(hObjectInfo, aPath + [@sObjectID], bIsPre)
      store_object_info(hObjectInfo)
    end
    private :initialize_class

    #=================================================================
    # 概  要: テストシナリオの通り処理単位オブジェクトデータを
    #         @hStateに代入
    #=================================================================
    def store_object_info(hObjectInfo)
      check_class(Hash, hObjectInfo)  # オブジェクト情報

      # 格納
      set_specified_attribute(hObjectInfo)
      hObjectInfo.each{|atr, val|
        case atr
        when TSR_PRM_TYPE
          # 何もしない

        when TSR_PRM_TSTAT, TSR_PRM_RTNSTAT, TSR_PRM_HOOKSTAT, TSR_PRM_CBSTAT
          @hState[TSR_PRM_STATE] = val

        when TSR_PRM_VAR
          @hState[atr] = {}
          if (val.is_a?(Hash))
            val.each{|sVarName, var|
              @hState[atr][sVarName] = Variable.new(sVarName, var, @aPath + [TSR_PRM_VAR])
            }
          else
            @hState[atr] = val
          end

        else
          @hState[atr] = val

        end
      }
    end

    #=================================================================
    # 概  要: 処理単位が持つ変数の値を比較するコードをcElementに格納す
    #         る
    #=================================================================
    def gc_assert_value(cElement, hProcUnitInfo)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報

      hState[TSR_PRM_VAR].each{|sValName, cVariable|
        cVariable.gc_assert_value(cElement, hProcUnitInfo)
      }
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      # コンフィギュレーションが必要ない処理単位は何もしない
      # (必要な処理単位は各処理単位クラスでオーバーライドする)
    end

    #=================================================================
    # 概  要: 各共有関数IDを返す
    #=================================================================
    def get_common_id()
      case @sObjectType
      when TSR_OBJ_C1ISR
        return "#{AKTG_LBL_C1ISR_COMMON}_#{@hState[TSR_PRM_INTNO]}"
      when TSR_OBJ_C2ISR
        return "#{AKTG_LBL_C2ISR_COMMON}_#{@hState[TSR_PRM_INTNO]}"
      when TSR_OBJ_ICISR
        if (@cConf.enable_icisr_convert?() && !@hState[TSR_PRM_INTNO].nil?())
          return "#{AKTG_LBL_ICISR_COMMON}_#{@hState[TSR_PRM_INTNO]}_#{@hState[TSR_PRM_ICISRNO]}"
        else
          return "#{AKTG_LBL_ICISR_COMMON}_#{@hState[TSR_PRM_OSAP]}_#{@hState[TSR_PRM_ICISRNO]}"
        end
      when TSR_OBJ_STARTUP_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_STARTUP_HOOK
        else
          return "#{AUTOSAR_STARTUP_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_SHUTDOWN_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_SHUTDOWN_HOOK
        else
          return "#{AUTOSAR_SHUTDOWN_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_PRETASK_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_PRETASK_HOOK
        else
          return "#{AUTOSAR_PRETASK_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_POSTTASK_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_POSTTASK_HOOK
        else
          return "#{AUTOSAR_POSTTASK_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_ERROR_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_ERROR_HOOK
        else
          return "#{AUTOSAR_ERROR_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_PROTECTION_HOOK
        if (@cConf.is_single?())
          return AUTOSAR_PROTECTION_HOOK
        else
          return "#{AUTOSAR_PROTECTION_HOOK}_Core#{@hState[TSR_PRM_COREID]}"
        end
      when TSR_OBJ_STARTUP_HOOK_OSAP
        return "#{AUTOSAR_STARTUP_HOOK}_#{@hState[TSR_PRM_OSAP]}"
      when TSR_OBJ_SHUTDOWN_HOOK_OSAP
        return "#{AUTOSAR_SHUTDOWN_HOOK}_#{@hState[TSR_PRM_OSAP]}"
      when TSR_OBJ_ERROR_HOOK_OSAP
        return "#{AUTOSAR_ERROR_HOOK}_#{@hState[TSR_PRM_OSAP]}"
      when TSR_OBJ_RESTART_TASK
        return "#{AKTG_LBL_RETASK_COMMON}_#{@hState[TSR_PRM_OSAP]}"
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end
    end

    #=================================================================
    # 概  要: 信頼OSAPかどうか
    #=================================================================
    def is_trusted?()
      if (@cConf.is_sc1?() || @cConf.is_sc2?())
        return true  # SC1，SC2は信頼OSAPと同じ処理とする
      elsif (!@hState[TSR_PRM_OSAP].nil?())
        if (@hState[TSR_PRM_OSAP].include?(AKTG_JUDGE_NON_TRUSTED) ||
            @hState[TSR_PRM_OSAP].include?(AKTG_JUDGE_MC_NON_TRUSTED))
          return false  # 非信頼OSAP
        elsif (@hState[TSR_PRM_OSAP].include?(AKTG_JUDGE_TRUSTED) ||
               @hState[TSR_PRM_OSAP].include?(AKTG_JUDGE_MC_TRUSTED))
          return true  # 信頼OSAP
        else
          hMacro = @cConf.get_macro()
          if (hMacro["ANY_OSAP_1"].include?(AKTG_JUDGE_NON_TRUSTED)||
              hMacro["ANY_OSAP_1"].include?(AKTG_JUDGE_MC_NON_TRUSTED))
            return false  # 非信頼OSAP
          else
            return true  # 信頼OSAP
          end
        end
      else
        # osapが空の場合，T2_001でエラーチェックする
      end
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref()
      # マスタコアのみ起動時のテスト，かつ他コアに所属する場合，状態参照処理を行わない
      if (@cConf.enable_boot_only_master_core?() == true && @hState[TSR_PRM_COREID] != @cConf.get_master_core())
        return false
      else
        return true
      end
    end
  end
end
