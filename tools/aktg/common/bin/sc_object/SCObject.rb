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
# $Id: SCObject.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/sc_object/ExpiryPoint.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/sc_object/SCObject.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: SCObject
  # 概    要: 同期・通信オブジェクトの情報を処理するクラス
  #===================================================================
  class SCObject
    include CommonModule

    attr_accessor :hState, :sObjectType, :sObjectID

    #=================================================================
    # 概  要: 同期・通信オブジェクトの初期化
    #=================================================================
    def initialize_class(sObjectID, hObjectInfo, sObjectType, aPath, bIsPre)
      check_class(String, sObjectID)    # オブジェクトID
      check_class(Hash, hObjectInfo)    # オブジェクト情報
      check_class(String, sObjectType)  # オブジェクトタイプ
      check_class(Array, aPath)         # ルートからのパス
      check_class(Bool, bIsPre)         # pre_condition内か

      @cConf   = Config.new()
      @hState = {}

      @sObjectID   = sObjectID
      @sObjectType = sObjectType  # オブジェクトのタイプ
      @aPath       = aPath + [@sObjectID]

      # 同期通信オブジェクトクラス共通部分
      @hState[TSR_PRM_COUNTER]       = nil  # 対象カウンタ名[アラーム/スケジュールテーブル]
      @hState[TSR_PRM_CURVAL]        = nil  # カウンタの現在値，スケジュールテーブルの現在時刻[カウンタ/スケジュールテーブル]
      @hState[TSR_PRM_OSAP]          = nil  # 所属するOSAP[カウンタ/アラーム/スケジュールテーブル]
      @hState[TSR_PRM_ACCOSAP]       = nil  # アクセスを許可する非信頼OSAP[リソース/カウンタ/アラーム/スケジュールテーブル/スピンロック]
      @hState[TSR_PRM_AUTOSTARTTYPE] = nil  # 自動起動の属性[アラーム/スケジュールテーブル]
      @hState[TSR_PRM_APPMODE]       = nil  # アプリケーションモード[アラーム/スケジュールテーブル]
      @hState[TSR_PRM_COREID]        = nil  # コアID[カウンタ/アラーム/スケジュールテーブル]【TESRYデータには指定しないが，内部的に保持しておく】
      @hState[TSR_PRM_LOCKFLG]       = nil  # リソース/スピンロックの状態

      # RESOURCE
      @hState[TSR_PRM_RESPROP]  = nil  # リソースの種別
      @hState[TSR_PRM_LINKRES]  = nil  # リンクリソースのリンク先リソース

      # EVENT
      @hState[TSR_PRM_MASK] = nil  # イベントマスク値

      # COUNTER
      @hState[TSR_PRM_MINCYC]         = nil  # 周期の最小値
      @hState[TSR_PRM_MAXVAL]         = nil  # カウンタの最大値
      @hState[TSR_PRM_CTYPE]          = nil  # カウンタのタイプ 
      @hState[TSR_PRM_TICKSPERBASE]   = nil  # カウンタ固有の単位に達するまでに必要なティック数
      @hState[TSR_PRM_CSTAT]          = nil  # カウンタの状態

      # ALARM
      @hState[TSR_PRM_ALMACT]        = nil  # アラーム満了時に実行させるアクション
      @hState[TSR_PRM_ALMVAL]        = nil  # 満了するティックの絶対値
      @hState[TSR_PRM_CYCLE]         = nil  # アラーム満了周期
      @hState[TSR_PRM_ASTAT]         = nil  # アラームの状態
      @hState[TSR_PRM_TASK]          = nil  # ActivateTask/SetEventの対象タスク
      @hState[TSR_PRM_EVENT]         = nil  # SetEventで指定する対象イベント
      @hState[TSR_PRM_INCOUNTER]     = nil  # IncrementCounterの対象カウンタ
      @hState[TSR_PRM_CALLBAK]       = nil  # 実行するアラームコールバック

      # SCHEDULE_TABLE
      @hState[TSR_PRM_SYNCSTRATEGY]  = nil  # 同期方法
      @hState[TSR_PRM_REPEAT]        = nil  # 繰り返し指定
      @hState[TSR_PRM_STSTAT]        = nil  # スケジュールテーブルの状態
      @hState[TSR_PRM_DURATION]      = nil  # スケジュールテーブル周期
      @hState[TSR_PRM_EXPOINT]       = nil  # 満了点の定義
      @hState[TSR_PRM_STARTTICK]     = nil  # 自動起動の属性

      # SPINLOCK
      @hState[TSR_PRM_SUSINT]    = nil  # 割込み禁止状態
      @hState[TSR_PRM_SUCCESSOR] = nil  # 次に取得可能なスピンロック

      pre_attribute_check(hObjectInfo, aPath + [@sObjectID], bIsPre)
      store_object_info(hObjectInfo)
    end
    private :initialize_class

    #=================================================================
    # 概  要: テストシナリオの通り同期・通信オブジェクトデータを
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

        when TSR_PRM_EXPOINT
          if (val != nil)
            aExpoint = val.keys.sort
            @hState[atr] = []
            aExpoint.each{|nOffset|
              @hState[atr].push(ExpiryPoint.new(nOffset, val[nOffset], @aPath + [TSR_PRM_EXPOINT]))
            }
          end

        else
          @hState[atr] = val
        end
      }
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
