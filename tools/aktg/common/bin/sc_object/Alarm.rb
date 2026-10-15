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
# $Id: Alarm.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/sc_object/SCObject.rb"
require "aktf/bin/sc_object/Alarm.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Alarm
  # 概    要: アラームの情報を処理するクラス
  #===================================================================
  class Alarm < SCObject
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: アラームの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_ALARM, aPath, bIsPre)

    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      if (@hState[TSR_PRM_APPMODE].nil?())
        nAlmtick = 0
        nAlmcyc = 0
      else
        nAlmtick = @hState[TSR_PRM_ALMVAL]
        nAlmcyc = @hState[TSR_PRM_CYCLE]
      end

      if (@hState[TSR_PRM_AUTOSTARTTYPE].nil?())
        sAutotype = TSR_STT_NULL
      else
        sAutotype = @hState[TSR_PRM_AUTOSTARTTYPE]
      end

      cElement.set_cfg_alm({XML_SNAME        => @sObjectID,
                            XML_P_A_CNT      => @hState[TSR_PRM_COUNTER],
                            XML_P_A_ACT_TSK  => @hState[TSR_PRM_TASK],
                            XML_P_A_CBACK    => @hState[TSR_PRM_CALLBAK],
                            XML_P_A_INCR_CNT => @hState[TSR_PRM_INCOUNTER],
                            XML_P_A_SET_EVT  => @hState[TSR_PRM_EVENT],
                            XML_P_A_EVT_TSK  => @hState[TSR_PRM_TASK],
                            XML_P_A_ALM_TIM  => nAlmtick,
                            XML_P_A_APP_MODE => @hState[TSR_PRM_APPMODE],
                            XML_P_A_CYC_TIM  => nAlmcyc,
                            XML_P_A_STA_TYP  => sAutotype,
                            :action_mode     => @hState[TSR_PRM_ALMACT],
                            XML_P_A_ACC_APP  => @hState[TSR_PRM_ACCOSAP],
                            :osap            => @hState[TSR_PRM_OSAP],
                            :coreid          => @hState[TSR_PRM_COREID]})
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref(cElement, hProcUnitInfo)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報

      # 状態参照を行うかチェック
      if (super() == false)
        return
      end

      # 状態確認API用構造体変数宣言
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_ALM_INFO], TYP_AKTSP_ALM_INFO)

      # アラーム満了時に実行させるアクション
      sAlmact = @hState[TSR_PRM_ALMACT]

      # 対象カウンタ名
      sCounter = @hState[TSR_PRM_COUNTER]

      # アラームの状態
      sAstat = @hState[TSR_PRM_ASTAT]

      # 満了するティックの絶対値
      if (!@hState[TSR_PRM_ALMVAL].nil?())
        nAlmval = @hState[TSR_PRM_ALMVAL]
      else
        nAlmval = "AKTSP_INVALID_VALUE32"
      end

      # アラーム満了周期
      if (!@hState[TSR_PRM_CYCLE].nil?())
        nCycle = @hState[TSR_PRM_CYCLE]
      else
        nCycle = "AKTSP_INVALID_VALUE32"
      end

      # ActivateTask/SetEventの対象タスク
      if (!@hState[TSR_PRM_TASK].nil?())
        sTask = @hState[TSR_PRM_TASK]
      else
        sTask = "AKTSP_INVALID_VALUE32"
      end

      # SetEventで指定する対象イベント
      if (!@hState[TSR_PRM_EVENT].nil?())
        sEvent = @hState[TSR_PRM_EVENT]
      else
        sEvent = "AKTSP_INVALID_VALUE32"
      end

      # IncrementCounterの対象カウンタ
      if (!@hState[TSR_PRM_INCOUNTER].nil?())
        sInCounter = @hState[TSR_PRM_INCOUNTER]
      else
        sInCounter = "AKTSP_INVALID_VALUE32"
      end

      # 実行するアラームコールバック
      if (!@hState[TSR_PRM_CALLBAK].nil?())
        sCallBack = "ALARMCALLBACKNAME(#{@hState[TSR_PRM_CALLBAK]})"
      else
        sCallBack = "AKTSP_INVALID_ALMCB"
      end

      # OSAP
      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      # 自動起動の属性
      if (!@hState[TSR_PRM_AUTOSTARTTYPE].nil?())
        sStarttype = @hState[TSR_PRM_AUTOSTARTTYPE]
      else
        sStarttype = "AKTSP_INVALID_VALUE8"
      end

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_ALM}(&#{GRP_VAR_TYPE[TYP_AKTSP_ALM_INFO]}, #{sAlmact}, #{sCounter}, #{nAlmval}, #{nCycle}, #{sAstat}, #{sTask}, #{sEvent}, #{sInCounter}, #{sCallBack}, #{sOsap}, #{sStarttype})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_ALM}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_ALM_INFO]})")

      # アクセス可能な非信頼OSAP
      if (!@hState[TSR_PRM_ACCOSAP].nil?())
        @hState[TSR_PRM_ACCOSAP].each{|sAccosap|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_ALM_ACC_OSAP}(#{sObjectID}, #{sAccosap})")
        }
      end

      # アプリケーションモード
      if (!@hState[TSR_PRM_APPMODE].nil?())
        @hState[TSR_PRM_APPMODE].each{|sAppmode|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_ALM_APP_MODE}(#{sObjectID}, #{sAppmode})")
        }
      end

    end
  end
end
