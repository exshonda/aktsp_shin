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
# $Id: ScheduleTable.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/sc_object/SCObject.rb"
require "aktf/bin/sc_object/ScheduleTable.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: ScheduleTable
  # 概    要: スケジュールテーブルの情報を処理するクラス
  #===================================================================
  class ScheduleTable < SCObject
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: スケジュールテーブルの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_SCHEDULE_TABLE, aPath, bIsPre)

    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      if (@hState[TSR_PRM_AUTOSTARTTYPE].nil?())
        sAutotype = TSR_STT_NULL
      else
        sAutotype = @hState[TSR_PRM_AUTOSTARTTYPE]
      end

      cElement.set_cfg_schtbl({XML_SNAME        => @sObjectID,
                               XML_P_S_DUR      => @hState[TSR_PRM_DURATION],
                               XML_P_S_REP      => @hState[TSR_PRM_REPEAT],
                               XML_P_S_CNT      => @hState[TSR_PRM_COUNTER],
                               XML_P_S_STA_VAL  => @hState[TSR_PRM_STARTTICK],
                               XML_P_S_STA_TYP  => sAutotype,
                               XML_P_S_APP_MODE => @hState[TSR_PRM_APPMODE],
                               XML_P_S_STRATEGY => @hState[TSR_PRM_SYNCSTRATEGY],
                               :expire_points   => @hState[TSR_PRM_EXPOINT],  # 満了点をクラスの配列のまま渡す
                               XML_P_S_ACC_APP  => @hState[TSR_PRM_ACCOSAP],
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
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_INFO], TYP_AKTSP_SCHTBL_INFO)
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_EXACT_INFO], TYP_AKTSP_SCHTBL_EXACT_INFO)

      # 対象カウンタ名
      sCounter = @hState[TSR_PRM_COUNTER]

      # 繰り返し指定
      sRepeat = @hState[TSR_PRM_REPEAT]

      # スケジュールテーブルの状態
      sStstat = @hState[TSR_PRM_STSTAT]

      # スケジュールテーブルの周期
      nDuration = @hState[TSR_PRM_DURATION]

      # 同期方法
      sSyncstrategy = @hState[TSR_PRM_SYNCSTRATEGY]

      # 満了するティックの絶対値
      if (!@hState[TSR_PRM_CURVAL].nil?())
        nCurval = @hState[TSR_PRM_CURVAL]
      else
        nCurval = "AKTSP_INVALID_VALUE32"
      end

      # NextScheduleTable発行後の切換え前スケジュールテーブルID
      if (!@hState[TSR_PRM_STFROM].nil?())
        sStfrom = @hState[TSR_PRM_STFROM]
      else
        sStfrom = "AKTSP_INVALID_VALUE32"
      end

      # OSAP
      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      # 自動起動のティック値
      nStarttick = @hState[TSR_PRM_STARTTICK]

      # 自動起動の属性
      if (!@hState[TSR_PRM_AUTOSTARTTYPE].nil?())
        sStarttype = @hState[TSR_PRM_AUTOSTARTTYPE]
      else
        sStarttype = "AKTSP_INVALID_VALUE8"
      end

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_SCHTBL}(&#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_INFO]}, #{sCounter}, #{sRepeat}, #{sStstat}, #{nDuration}, #{sSyncstrategy}, #{nCurval}, #{sStfrom}, #{sOsap}, #{nStarttick}U, #{sStarttype})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SCHTBL}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_INFO]})")

      # 満了点の状態確認
      @hState[TSR_PRM_EXPOINT].each_with_index{|cExpoint, nIndex|
        cExpoint.gc_obj_ref(@sObjectID, cElement, hProcUnitInfo, nIndex)
      }

      # アクセス可能な非信頼OSAP
      if (!@hState[TSR_PRM_ACCOSAP].nil?())
        @hState[TSR_PRM_ACCOSAP].each{|sAccosap|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SCHTBL_ACC_OSAP}(#{sObjectID}, #{sAccosap})")
        }
      end

      # アプリケーションモード
      if (!@hState[TSR_PRM_APPMODE].nil?())
        @hState[TSR_PRM_APPMODE].each{|sAppMode|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SCHTBL_APP_MODE}(#{sObjectID}, #{sAppMode})")
        }
      end

    end
  end
end
