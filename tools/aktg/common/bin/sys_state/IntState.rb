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
# 本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
# 
#  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
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
# $Id: IntState.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/CommonModule.rb"
require "common/bin/Config.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/sys_state/IntState.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: IntState
  # 概    要: 割込み禁止状態の情報を処理するクラス
  #===================================================================
  class IntState
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: 割込み禁止状態の初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      @cConf  = Config.new()
      @hState = {}

      @sObjectID   = sObjectID
      @sObjectType = TSR_OBJ_INT_STATE
      @aPath       = aPath + [@sObjectID]

      @hState[TSR_PRM_INT_STATE] = nil  # 割込み禁止状態
      @hState[TSR_PRM_COREID]    = nil  # コアID

      pre_attribute_check(hObjectInfo, aPath + [@sObjectID], bIsPre)
      store_object_info(hObjectInfo)
    end

    #=================================================================
    # 概  要: テストシナリオの割込み禁止状態データを@hStateに代入
    #=================================================================
    def store_object_info(hObjectInfo)
      check_class(Hash, hObjectInfo)  # オブジェクト情報

      # 格納
      set_specified_attribute(hObjectInfo)
      hObjectInfo.each{|atr, val|
        if (atr != TSR_PRM_TYPE)
          @hState[atr] = val
        end
      }
    end

    #=================================================================
    # 概  要: 割込み禁止状態を参照するコードをcElementに格納する
    #=================================================================
    def gc_obj_ref(cElement, hProcUnitInfo)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報

      # マスタコアのみ起動時のテスト，かつ他コアに所属する場合，状態参照処理を行わない
      if (@cConf.enable_boot_only_master_core?() == true && @hState[TSR_PRM_COREID] != @cConf.get_master_core())
        return
      end

      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_INT_INFO], TYP_AKTSP_INT_INFO)

      # DisableAllInterruptsによる割込み禁止状態
      if (is_dis_all_int?())
        sDisAllInt = TSR_STT_DISABLE
      else
        sDisAllInt = TSR_STT_ENABLE
      end

      # SuspendAllInterruptsによる割込み禁止状態
      nSusAllCnt = 0
      if (is_sus_all_int?())
        sSusAllInt = TSR_STT_DISABLE
        # ネスト回数カウント
        @hState[TSR_PRM_INT_STATE].each{|hIntState|
          if (hIntState.has_key?(TSR_STT_SUS_ALL_INT))
            # スピンロック個数拡張
            if (hIntState[TSR_STT_SUS_ALL_INT] =~ /\w+\/\d+-\d+\//)
              # 拡張する個数を取得して加算
              nStartId = hIntState[TSR_STT_SUS_ALL_INT][/\w+\/(\d+)-\d+\//, 1].to_i()
              nEndId = hIntState[TSR_STT_SUS_ALL_INT][/\w+\/\d+-(\d+)\//, 1].to_i()
              nExNum = nEndId - nStartId + 1
              nSusAllCnt += nExNum
            else
              nSusAllCnt += 1
            end
          end
        }
      else
        sSusAllInt = TSR_STT_ENABLE
      end

      # SuspendOSInterruptsによる割込み禁止状態
      nSusOsCnt = 0
      if (is_sus_os_int?())
        sSusOSInt = TSR_STT_DISABLE
        # ネスト回数カウント
        @hState[TSR_PRM_INT_STATE].each{|hIntState|
          if (hIntState.has_key?(TSR_STT_SUS_OS_INT))
            # スピンロック個数拡張
            if (hIntState[TSR_STT_SUS_OS_INT] =~ /\w+\/\d+-\d+\//)
              # 拡張する個数を取得して加算
              nStartId = hIntState[TSR_STT_SUS_OS_INT][/\w+\/(\d+)-\d+\//, 1].to_i()
              nEndId = hIntState[TSR_STT_SUS_OS_INT][/\w+\/\d+-(\d+)\//, 1].to_i()
              nExNum = nEndId - nStartId + 1
              nSusOsCnt += nExNum
            else
              nSusOsCnt += 1
            end
          end
        }
      else
        sSusOSInt = TSR_STT_ENABLE
      end

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_INT}(&#{GRP_VAR_TYPE[TYP_AKTSP_INT_INFO]}, #{sDisAllInt}, #{sSusAllInt}, #{sSusOSInt}, #{nSusAllCnt}, #{nSusOsCnt})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_INT_STATE}(&#{GRP_VAR_TYPE[TYP_AKTSP_INT_INFO]})")

      # 割込み禁止操作の順番
      @hState[TSR_PRM_INT_STATE].each_with_index{|hIntState, nIndex|
        cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_DIS_INT_ORDER}(#{(nIndex + 1)}, #{hIntState.keys[0]})")
      }

    end

    #=================================================================
    # 概  要: DisableAllInterruptsによる割込み禁止状態かを返す
    #=================================================================
    def is_dis_all_int?()
      @hState[TSR_PRM_INT_STATE].each{|hIntState|
        if (hIntState.has_key?(TSR_STT_DIS_ALL_INT))
          return true    # [Bool]DisableAllInterruptsによる割込み禁止状態がある
        end
      }
      return false  # [Bool]DisableAllInterruptsによる割込み禁止状態がない
    end

    #=================================================================
    # 概  要: SuspendAllInterruptsによる割込み禁止状態かを返す
    #=================================================================
    def is_sus_all_int?()
      @hState[TSR_PRM_INT_STATE].each{|hIntState|
        if (hIntState.has_key?(TSR_STT_SUS_ALL_INT))
          return true    # [Bool]SuspendAllInterruptsによる割込み禁止状態がある
        end
      }
      return false  # [Bool]SuspendAllInterruptsによる割込み禁止状態がない
    end

    #=================================================================
    # 概  要: SuspendOSInterruptsによる割込み禁止状態かを返す
    #=================================================================
    def is_sus_os_int?()
      @hState[TSR_PRM_INT_STATE].each{|hIntState|
        if (hIntState.has_key?(TSR_STT_SUS_OS_INT))
          return true    # [Bool]SuspendOSInterruptsによる割込み禁止状態がある
        end
      }
      return false  # [Bool]SuspendOSInterruptsによる割込み禁止状態がない
    end

    #=================================================================
    # 概  要: 状態変化が指定されているかを返す
    #=================================================================
    def is_state_changed?()
      return (is_dis_all_int?() || is_sus_all_int?() || is_sus_os_int?())  # [Bool]状態変化が指定されているか
    end
  end
end
