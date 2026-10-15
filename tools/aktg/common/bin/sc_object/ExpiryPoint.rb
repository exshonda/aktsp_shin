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
# $Id: ExpiryPoint.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/CommonModule.rb"
require "aktf/bin/class/AKTFCommon.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/sc_object/ExpiryPoint.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: ScheduleTable
  # 概    要: スケジュールテーブルの情報を処理するクラス
  #===================================================================
  class ExpiryPoint
    include CommonModule

    attr_accessor :nOffset, :aActtsk, :aSetevt

    #=================================================================
    # 概  要: スケジュールテーブルの初期化
    #=================================================================
    def initialize(nOffset, hExptInfo, aPath)
      check_class(Integer, nOffset) # オフセット
      check_class(Hash, hExptInfo)  # 満了点の情報
      check_class(Array, aPath)     # ルートからのパス

      @nOffset = nOffset                   # オフセット
      @aActtsk = hExptInfo[TSR_PRM_ACTTSK] # タスクの起動
      @aSetevt = hExptInfo[TSR_PRM_SETEVT] # イベントのセット
      @aPath   = aPath + [@nOffset]

      @cConf = Config.new()

      set_specified_attribute(hExptInfo)
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref(sSchtblID, cElement, hProcUnitInfo, nIndex)
      check_class(String, sSchtblID)       # スケジュールテーブルID
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報
      check_class(Integer, nIndex)         # インデックス

      # オフセット値
      nOffset = @nOffset

      # タスクの起動の確認
      if (!@aActtsk.nil?())
        @aActtsk.each{|sTask|
          # 構造体作成
          cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_SCHTBL_EXACT}(&#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_EXACT_INFO]}, #{nOffset}, #{TSR_STT_ST_ATSK}, #{sTask}, AKTSP_INVALID_VALUE8)")
          # データを入れた構造体を状態確認APIへ渡す
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SCHTBL_EXACT}(#{sSchtblID}, #{nIndex + 1}, &#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_EXACT_INFO]})")
        }
      end

      # イベントのセットの確認
      if (!@aSetevt.nil?())
        @aSetevt.each{|hAction|
          hAction.each{|sTask, sEvent|
            # 構造体作成
            cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_SCHTBL_EXACT}(&#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_EXACT_INFO]}, #{nOffset}, #{TSR_STT_ST_SEVT}, #{sTask}, #{sEvent})")
            # データを入れた構造体を状態確認APIへ渡す
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SCHTBL_EXACT}(#{sSchtblID}, #{nIndex + 1}, &#{GRP_VAR_TYPE[TYP_AKTSP_SCHTBL_EXACT_INFO]})")
          }
        }
      end
    end
  end
end
