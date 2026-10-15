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
# $Id: Task.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "aktf/bin/process_unit/ProcessUnit.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Task
  # 概    要: タスクの情報を処理するクラス
  #===================================================================
  class Task < ProcessUnit

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []
      begin
        super()
      rescue AKTFMultiError
        aErrors = $!.aErrors
      end

      # RestartTaskクラスからProcessUnitクラスのattribute_check()を
      # 使用するため，ここでRestartTaskを除外する
      if (@sObjectType == TSR_OBJ_RESTART_TASK)
        return
      end

      begin
        # osapのチェック
        if (is_specified?(TSR_PRM_OSAP))
          sAtr = TSR_PRM_OSAP
          val = @hState[TSR_PRM_OSAP]
          check_attribute_type(sAtr, val, String, false, @aPath)
          if (@cConf.is_sc1?() || @cConf.is_sc2?())
            check_attribute_enum(sAtr, val, GRP_OSAP_SC1MC, @aPath)
          else
            check_attribute_enum(sAtr, val, GRP_OSAP_ALL_AVAILABLE_SC3, @aPath)
          end
        end
        # accosapのチェック
        if (is_specified?(TSR_PRM_ACCOSAP))
          sAtr = TSR_PRM_ACCOSAP
          val = @hState[TSR_PRM_ACCOSAP]
          check_attribute_type(sAtr, val, Array, false, @aPath)
          val.each {|sTrusted|
            check_attribute_enum(sAtr, sTrusted, GRP_OSAP_NON_TRUSTED_ISR_AVAILABLE_SC3, @aPath)
          }
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []
      begin
        super(bIsPre)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end

      # pre_conditionのみのチェック
      if (bIsPre == true)
        ### T3_TSK001: ttypeをAK_BASICと明示的に指定しているのに，relevtが指定されている
        if (is_basic?() && !@hState[TSR_PRM_RELEVT].nil?())
          aErrors.push(YamlError.new("T3_TSK001: " + ERR_SET_RELEVT_BASICTASK, @aPath))
        end

        ### T3_TSK009: relresで指定されたリソースが重複している
        if (!@hState[TSR_PRM_RELRES].nil?())
          if (@hState[TSR_PRM_RELRES].size != @hState[TSR_PRM_RELRES].uniq.size)
            sErr = sprintf("T3_TSK009: " + ERR_RESID_DUPLICATE, TSR_PRM_RELRES)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        end
        ### T3_TSK010: relevtで指定されたイベントが重複している
        if (!@hState[TSR_PRM_RELEVT].nil?())
          if (@hState[TSR_PRM_RELEVT].size != @hState[TSR_PRM_RELEVT].uniq.size)
            aErrors.push(YamlError.new("T3_TSK010: " + ERR_EVENT_DUPLICATE, @aPath))
          end
        end
        ### T3_TSK017: スタック共有がOFFの場合に，stkが指定されている
        if ((@cConf.enable_stack_share_mode() == false) && (@hState[TSR_PRM_STK] != "NULL"))
          aErrors.push(YamlError.new("T3_TSK017: " + ERR_STK_NOT_STACK_SHARE, @aPath))
        end
        ### T3_TSK019: ttypeがAK_EXTENDEDの場合に，maxactが2以上で指定されている
        if (is_extended?() && @hState[TSR_PRM_MAXACT] >= 2)
          aErrors.push(YamlError.new("T3_TSK019: " + ERR_SET_MAXACT_EXTENDEDTASK, @aPath))
        end

        if (@cConf.is_sc3?() || @cConf.is_sc4?())
          ### T3_SC3_TSK001: タスクが信頼OSAPに所属している場合に，sstksz，sstkが指定されている
          if ((GRP_OSAP_TRUSTED_AVAILABLE_SC3.include?(@hState[TSR_PRM_OSAP])) &&
             ((@hState[TSR_PRM_SSTKSZ] != 0) || (@hState[TSR_PRM_SSTK] != "NULL")))
            aErrors.push(YamlError.new("T3_SC3_TSK001: " + ERR_SSTKSZ_SSTK_TRUSTED_OSAP, @aPath))
          end
          ### T3_SC3_TSK002: スタック共有がOFFの場合に，sstkが指定されている
          if ((@cConf.enable_stack_share_mode() == false) && (@hState[TSR_PRM_SSTK] != "NULL"))
            aErrors.push(YamlError.new("T3_SC3_TSK002: " + ERR_STK_NOT_STACK_SHARE, @aPath))
          end 
        end
      end

      # 待ち状態の場合
      if (is_waiting?())
        ### T3_TSK012: tstatがWAITINGであるが，getresにリソースが指定されている
        if (!@hState[TSR_PRM_GETRES].nil?())
          aErrors.push(YamlError.new("T3_TSK012: " + ERR_SET_GETRES_WAITING, @aPath))
        end
      else
        ### T3_TSK003: tstatがWAITINGではないが，waievtが指定されている
        if (!@hState[TSR_PRM_WAIEVT].nil?())
          aErrors.push(YamlError.new("T3_TSK003: " + ERR_WAIEVT_NOT_SUSPENDED, @aPath))
        end
      end

      # 休止状態の場合
      if (is_dormant?())
        @aSpecifiedAttributes.each{|sAtr|
          ### T3_TSK004: tstatがSUSPENDEDの場合に，指定できないパラメータが指定されている
          if (sAtr != TSR_PRM_TYPE && !GRP_ACTIVATE_PRM_ON_SUSPENDED.include?(sAtr))
            sErr = sprintf("T3_TSK004: " + ERR_ATR_SUSPENDED_TASK, sAtr)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        }
        ### T3_TSK013: tstatがSUSPENDEDであるが，getresにリソースが指定されている
        if (!@hState[TSR_PRM_GETRES].nil?())
          aErrors.push(YamlError.new("T3_TSK013: " + ERR_SET_GETRES_SUSPENDED, @aPath))
        end
      else
        ### T3_TSK015: inipriがcurpriより大きい
        if ((@hState[TSR_PRM_INIPRI] != TSR_STT_INVALID) && (@hState[TSR_PRM_CURPRI] != TSR_STT_INVALID))
          if (@hState[TSR_PRM_INIPRI] > @hState[TSR_PRM_CURPRI])
            sErr = sprintf("T3_TSK015: " + ERR_TASK_INIPRI_GT_CURPRI, @hState[TSR_PRM_INIPRI], @hState[TSR_PRM_CURPRI])
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        end
      end

      # 実行可能状態の場合
      if (is_ready?())
        ### T3_TSK006: porderが1ではないが，getresにリソースが指定されている
        if (@hState[TSR_PRM_PORDER] > 1 && !@hState[TSR_PRM_GETRES].nil?())
          aErrors.push(YamlError.new("T3_TSK006: " + ERR_SET_GETRES_NOT_PORDER1, @aPath))
        end
        ### T3_TSK011: tstatがREADYで，かつspolicyがAK_SCHNONである場合に，getresにリソースが指定されている
        if (!is_schfull?() && !@hState[TSR_PRM_GETRES].nil?())
          aErrors.push(YamlError.new("T3_TSK011: " + ERR_SET_GETRES_READY_AND_SCHNON, @aPath))
        end
      else
        ### T3_TSK005: tstatがREADYではないが，porderが指定されている
        if (is_specified?(TSR_PRM_PORDER) && !@hState[TSR_PRM_PORDER].nil?())
          aErrors.push(YamlError.new("T3_TSK005: " + ERR_PORDER_NOT_READY, @aPath))
        end
      end

      # タスクの種別
      ### T3_TSK014: ttypeがAK_BASICの場合に，curevtが指定されている
      if (is_basic?() && !@hState[TSR_PRM_CUREVT].nil?())
        aErrors.push(YamlError.new("T3_TSK014: " + ERR_SET_CUREVT_BASICTASK, @aPath))
      end

      ### T3_TSK016: getresで指定されたリソースが重複している
      if (!@hState[TSR_PRM_GETRES].nil?())
        if (@hState[TSR_PRM_GETRES].size != @hState[TSR_PRM_GETRES].uniq.size)
          sErr = sprintf("T3_TSK016: " + ERR_RESID_DUPLICATE, TSR_PRM_GETRES)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      ### T3_TSK018: propertyのmaintask_waitがtrueの場合に，curpriがタスクの最小優先度でない
      if (@hProperty[TSR_PRM_MAINTASK_WAIT] == true && !@hState[TSR_PRM_CURPRI].nil?() && @hState[TSR_PRM_CURPRI] != @cConf.get_min_task_pri())
        aErrors.push(YamlError.new("T3_TSK018: " + ERR_CURPRI_NOT_MINPRI, @aPath))
      end

      if (@cConf.is_multi?())
        ### T3_MC_TSK001:tstatがAK_RUNNING_WAITSPINの場合に，spnidが指定されていない
        if (is_waitspin?() && @hState[TSR_PRM_SPNID].nil?())
          sErr = sprintf("T3_MC_TSK001: " + ERR_NOT_SET_SPINID, @hState[TSR_PRM_STATE], TSR_STT_RUNNING_WAITSPIN)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_MC_TSK002: getspnで指定されたスピンロックが重複している
        if (!@hState[TSR_PRM_GETSPN].nil?())
          if (@hState[TSR_PRM_GETSPN].size != @hState[TSR_PRM_GETSPN].uniq.size)
            sErr = sprintf("T3_MC_TSK002: " + ERR_SPNID_DUPLICATE, TSR_PRM_GETSPN)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      super()
      hMacro  = @cConf.get_macro()

      # curpri
      if (!is_specified?(TSR_PRM_CURPRI))
        @hState[TSR_PRM_CURPRI]  = hMacro["TSK_PRI_MID"]
      end
      # inipri
      if (!is_specified?(TSR_PRM_INIPRI))
        if (is_specified?(TSR_PRM_CURPRI))
          @hState[TSR_PRM_INIPRI] = @hState[TSR_PRM_CURPRI]
        else
          @hState[TSR_PRM_INIPRI] = hMacro["TSK_PRI_MID"]
        end
      end
      # ttype
      if (!is_specified?(TSR_PRM_TTYPE))
        if (is_specified?(TSR_PRM_RELEVT))
          @hState[TSR_PRM_TTYPE] = TSR_STT_EXTENDED
        else
          @hState[TSR_PRM_TTYPE] = hMacro["ANY_TTYPE"]
        end
      end

      # actcnt
      if (!is_specified?(TSR_PRM_ACTCNT))
        # SUSPENDEDは0，SUSPENDED以外は1とする
        if (is_dormant?())
          @hState[TSR_PRM_ACTCNT] = 0
        else
          @hState[TSR_PRM_ACTCNT] = 1
        end
      end
      # maxact
      if (!is_specified?(TSR_PRM_MAXACT))
        @hState[TSR_PRM_MAXACT] = 1
      end
      # spolicy
      if (!is_specified?(TSR_PRM_SPOLICY))
        @hState[TSR_PRM_SPOLICY] = hMacro["ANY_SPOLICY"]
      end
      # porder
      if (!is_specified?(TSR_PRM_PORDER))
        @hState[TSR_PRM_PORDER] = 0
      end
      # relevt
      # (拡張タスクかつ関連イベントが無い場合，ダミーイベントを関連付ける)
      if (!is_specified?(TSR_PRM_RELEVT) && is_extended?())
        @hState[TSR_PRM_RELEVT] = [AKTG_DUMMY_EVT]
      end
      # curevt
      # (拡張タスクの場合のみ，補完する)
      if (!is_specified?(TSR_PRM_CUREVT) && is_extended?())
        @hState[TSR_PRM_CUREVT] = 0
      end
      # stksz
      if (!is_specified?(TSR_PRM_STKSZ))
        @hState[TSR_PRM_STKSZ] = "AKTSP_TASK_STACK_SIZE"
      end
      # sstksz
      if (!is_specified?(TSR_PRM_SSTKSZ))
        if (is_trusted?())
          @hState[TSR_PRM_SSTKSZ] = 0
        else
          @hState[TSR_PRM_SSTKSZ] = "AKTSP_TASK_STACK_SIZE"
        end
      end

      if (@cConf.is_multi?())
        # マルチコア
        # osap
        if (!is_specified?(TSR_PRM_OSAP))
          @hState[TSR_PRM_OSAP] = @cConf.get_default_osap_id()
        elsif (@hState[TSR_PRM_OSAP] == "ANY_OSAP_1")
          @hState[TSR_PRM_OSAP] = hMacro["ANY_OSAP_1"]
        end
        # coreid
        @hState[TSR_PRM_COREID] = @cConf.get_core_id_from_osap(@hState[TSR_PRM_OSAP])
      else
        # マルチコアのマスタコアの処理と，シングルコアの処理が同じ場合の分岐のため
        # シングルコアでもマスタコアIDで補完しておく
        # coreid
        @hState[TSR_PRM_COREID] = @cConf.get_master_core()
      end

      # stk
      # 補完処理でosapを使用するため，osap補完後にstkを補完する
      if (!is_specified?(TSR_PRM_STK))
        if (@cConf.enable_stack_share_mode() == false)
          @hState[TSR_PRM_STK] = "NULL"
        elsif (is_trusted?())
          if (@cConf.is_single?())
            if (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_STK] = "aktg_stack[#{(@nStackNum - 1)}]"
            else
              # スタックモニタリングのテストでは，スタックを1つ多く確保し，
              # 先頭の領域をバッファとして，スタックオーバーフローしても
              # 問題が発生しないようにする
              @hState[TSR_PRM_STK] = "aktg_stack[#{@nStackNum}]"
            end
          else
            # マルチコアの場合，コア毎にスタックを確保する
            if (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_STK] = "AKTG_TASK_STACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{(@nStackNum - 1)})"
            else
              # スタックモニタリングテストの場合，スタックを1つ多く確保する
              @hState[TSR_PRM_STK] = "AKTG_TASK_STACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{@nStackNum})"
            end
          end
        else
          if (@cConf.is_single?())
            if (@sObjectType == TSR_OBJ_RESTART_TASK)
              @hState[TSR_PRM_STK] = "NULL"
            elsif (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_STK]  = "aktg_ustack[#{(@nStackNum - 1)}]"
            else
              # ユーザスタックにはバッファの必要はないがaktg_sstackとの対称性のために確保する
              @hState[TSR_PRM_STK]  = "aktg_ustack[#{@nStackNum}]"
            end
          else
            # マルチコアの場合，コア毎にスタックを確保する
            if (@sObjectType == TSR_OBJ_RESTART_TASK)
              @hState[TSR_PRM_STK] = "NULL"
            elsif (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_STK]  = "AKTG_TASK_USTACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{(@nStackNum - 1)})"
            else
              # ユーザスタックにはバッファの必要はないがaktg_sstackとの対称性のために確保する
              @hState[TSR_PRM_STK] = "AKTG_TASK_USTACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{@nStackNum})"
            end
          end
        end
      end
      # sstk
      # 補完処理でosapを使用するため，osap補完後にsstkを補完する
      if (!is_specified?(TSR_PRM_SSTK))
        if (@cConf.enable_stack_share_mode() == false)
          @hState[TSR_PRM_SSTK] = "NULL"
        elsif (is_trusted?())
            @hState[TSR_PRM_SSTK] = "NULL"
        else
          if (@cConf.is_single?())
            if (@sObjectType == TSR_OBJ_RESTART_TASK)
              @hState[TSR_PRM_SSTK] = "NULL"
            elsif (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_SSTK] = "aktg_sstack[#{(@nStackNum - 1)}]"
            else
              # スタックモニタリングのテストでは，スタックを1つ多く確保し，
              # 先頭の領域をバッファとして，スタックオーバーフローしても
              # 問題が発生しないようにする
              @hState[TSR_PRM_SSTK] = "aktg_sstack[#{@nStackNum}]"
            end
          else
            # マルチコアの場合，コア毎にシステムスタックを確保する
            if (@sObjectType == TSR_OBJ_RESTART_TASK)
              @hState[TSR_PRM_SSTK] = "NULL"
            elsif (@cConf.enable_stackfault_detection() == true)
              @hState[TSR_PRM_SSTK] = "AKTG_TASK_SSTACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{(@nStackNum - 1)})"
            else
              # スタックモニタリングテストの場合，スタックを1つ多く確保する
              @hState[TSR_PRM_SSTK] = "AKTG_TASK_SSTACK_ADDRESS_CORE_#{hMacro[@hState[TSR_PRM_COREID]]}(#{@nStackNum})"
            end
          end
        end
      end

    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObjectInfo)
      check_class(ProcessUnit, cPrevObjectInfo)  # 直前のオブジェクト情報

      super(cPrevObjectInfo)

      # 補完例外(waievt)
      if (!is_specified?(TSR_PRM_WAIEVT) && (cPrevObjectInfo.is_waiting?()) && 
          (@hState[TSR_PRM_STATE] != TSR_STT_WAITING))
        @hState[TSR_PRM_WAIEVT] = nil
      end
      # 補完例外(porder)
      if (!is_specified?(TSR_PRM_PORDER) && (cPrevObjectInfo.hState[TSR_PRM_STATE] != @hState[TSR_PRM_STATE] ||
          cPrevObjectInfo.hState[TSR_PRM_CURPRI] != @hState[TSR_PRM_CURPRI]))
        @hState[TSR_PRM_PORDER] = 0
      end
    end

    #=================================================================
    # 概  要: 全補完終了後に実行する処理
    #=================================================================
    def complement_after()
      # SUSPENDEDの場合，一部のパラメータを無効とする
      if (is_dormant?())
        @hState.each_key{|sAtr|
          if (!is_specified?(sAtr) && !GRP_COMPLEMENT_PRM_ON_SUSPENDED.include?(sAtr))
            @hState[sAtr] = nil
          end
        }
      end
    end

    #=================================================================
    # 概  要: タスク内のマクロを置換する
    #=================================================================
    def convert_macro()
      # 現在優先度に割込み優先度が指定されていた場合，
      # タスクの最大優先度に割込み優先度を加算して，
      # 他のタスクとの相対的な優先度関係を実現する
      if (@hState[TSR_PRM_CURPRI] =~ TSR_MACRO_INI_PRI)
        hMacro = @cConf.get_macro()
        nTempIni = hMacro[@hState[TSR_PRM_CURPRI]]
        if (nTempIni != TSR_STT_INVALID)
          @hState[TSR_PRM_CURPRI] = nTempIni + @cConf.get_max_task_pri()
        else
         @hState[TSR_PRM_CURPRI] = nTempIni
        end
      end

      super()
    end

    #=================================================================
    # 概  要: relevtが指定されているかを返す
    #=================================================================
    def has_relevt?()
      return !(@hState[TSR_PRM_RELEVT].nil?())  # [Bool]relevtが指定されているか
    end

    #=================================================================
    # 概  要: relresが指定されているかを返す
    #=================================================================
    def has_relres?()
      super  # [Bool]relresが指定されているか
    end

    #=================================================================
    # 概  要: getresが指定されているかを返す
    #=================================================================
    def has_getres?()
      super  # [Bool]getresが指定されているか
    end

    #=================================================================
    # 概  要: getspnが指定されているかを返す
    #=================================================================
    def has_getspn?()
      super  # [Bool]getspnが指定されているか
    end

    #=================================================================
    # 概  要: 実行可能状態かを返す
    #=================================================================
    def is_ready?()
      return (@hState[TSR_PRM_STATE] == TSR_STT_READY)  # [Bool]実行可能状態か
    end

    #=================================================================
    # 概  要: オブジェクト待ち状態かを返す
    #=================================================================
    def is_waiting?()
      return (@hState[TSR_PRM_STATE] == TSR_STT_WAITING)  # [Bool]待ち状態か
    end

    #=================================================================
    # 概  要: 休止状態かを返す
    #=================================================================
    def is_dormant?()
      return (@hState[TSR_PRM_STATE] == TSR_STT_SUSPENDED)  # [Bool]休止状態か
    end

    #=================================================================
    # 概  要: スピンロック取得待ち状態かを返す
    #=================================================================
    def is_waitspin?()
      return (@hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITSPIN)  # [Bool]スピンロック取得待ち状態か
    end

    #=================================================================
    # 概  要: フルプリエンプティブスケジューリングかを返す
    #=================================================================
    def is_schfull?()
      return (@hState[TSR_PRM_SPOLICY] == TSR_STT_SCHFULL)  # [Bool]フルプリエンプティブスケジューリングか
    end

    #=================================================================
    # 概  要: 拡張タスクかを返す
    #=================================================================
    def is_extended?()
      if (@hState[TSR_PRM_TTYPE] == "ANY_TTYPE")
        hMacro  = @cConf.get_macro()
        sTtype = hMacro["ANY_TTYPE"]
      else
        sTtype = @hState[TSR_PRM_TTYPE]
      end
      return (sTtype == TSR_STT_EXTENDED)  # [Bool]拡張タスクか
    end

    #=================================================================
    # 概  要: 基本タスクかを返す
    #=================================================================
    def is_basic?()
      if (@hState[TSR_PRM_TTYPE] == "ANY_TTYPE")
        hMacro  = @cConf.get_macro()
        sTtype = hMacro["ANY_TTYPE"]
      else
        sTtype = @hState[TSR_PRM_TTYPE]
      end
      return (sTtype == TSR_STT_BASIC)  # [Bool]基本タスクか
    end
  end
end
