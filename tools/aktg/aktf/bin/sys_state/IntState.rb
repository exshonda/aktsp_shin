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
require "aktf/bin/class/AKTFCommon.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: IntState
  # 概    要: 割込み禁止状態状態の情報を処理するクラス
  #===================================================================
  class IntState
    include AKTFModule
    include AKTFModule::ObjectCommon

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []
      @hState.each{|sAtr, val|
        begin
          if (is_specified?(sAtr))
            case sAtr
            # 配列かNil
            when TSR_PRM_INT_STATE
              check_attribute_type(sAtr, val, Array, true, @aPath)
              if (!val.nil?())
                if (@cConf.is_single?())
                  aList = GRP_INT_STATE_AVAILABLE_SINGLE
                else
                  aList = GRP_INT_STATE_AVAILABLE_MULTI
                end
                val.each{|hStat|
                  check_attribute_type(sAtr, hStat, Hash, false, @aPath)
                  hStat.each_key{|sStat|
                    check_attribute_type(sAtr, sStat, String, false, @aPath)
                    check_attribute_enum(sAtr, sStat, aList[sAtr], @aPath)
                  }
                }
              end

            # 0以上の整数
            when TSR_PRM_COREID
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              check_attribute_unsigned(sAtr, val, @aPath)

            else
              abort(ERR_MSG % [__FILE__, __LINE__])
            end
          end
        rescue AKTFError
          aErrors.push($!)
        end
      }

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre = false)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []

      # チェック準備
      nDisallintCnt = 0
      bSusint = false
      @hState[TSR_PRM_INT_STATE].each{|hIntState|
        if (hIntState.has_key?(TSR_STT_DIS_ALL_INT))
          nDisallintCnt += 1
        elsif (hIntState.has_key?(TSR_STT_SUS_ALL_INT) || hIntState.has_key?(TSR_STT_SUS_OS_INT))
          bSusint = true
        end
      }

      ### T3_INT001: istatに，AK_DIS_ALL_INTとAK_SUS_ALL_INT/AK_SUS_OS_INTが混在している
      if (nDisallintCnt == 1 && bSusint == true)
        aErrors.push(YamlError.new("T3_INT001: " + ERR_MIXED_INT_STATE, @aPath))
      end
      ### T3_INT002: istatに，AK_DIS_ALL_INTが複数指定されている
      if (nDisallintCnt > 1)
        aErrors.push(YamlError.new("T3_INT002: " + ERR_DUPLICATE_DIS_ALL_INT, @aPath))
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      # istat
      if (@hState[TSR_PRM_INT_STATE].nil?())
        @hState[TSR_PRM_INT_STATE]  = []
      end

      # coreid
      if (@cConf.is_multi?())
        # マルチコア
        if (!is_specified?(TSR_PRM_COREID))
          @hState[TSR_PRM_COREID] = CFG_MCR_CORE_SELF
        end
      else
        # マルチコアのマスタコアの処理と，シングルコアの処理が同じ場合の分岐のため
        # シングルコアでもマスタコアIDで補完しておく
        @hState[TSR_PRM_COREID] = @cConf.get_master_core()
      end
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObj)
      check_class(IntState, cPrevObj)  # 直前の状態のオブジェクト

      # istat
      if (@hState[TSR_PRM_INT_STATE].nil?())
        @hState[TSR_PRM_INT_STATE]  = []
      end

      super(cPrevObj)
    end

    #=================================================================
    # 概  要: オブジェクトのエイリアス変換テーブルを返す
    #=================================================================
    def get_alias(sTestID, bSingleTest, nNum = nil)
      check_class(String, sTestID)      # テストID
      check_class(Integer, nNum, true)  # 識別番号

      hResult = {}
      if (bSingleTest == false)
        hResult[@sObjectID] = alias_str(@sObjectID, sTestID)
      else
        hResult[@sObjectID] = @sObjectID
      end

      return hResult  # [Hash]エイリアス変換テーブル
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      super(hAlias)

      # システムサービスを発行した処理単位
      if (!@hState[TSR_PRM_INT_STATE].nil?())
        @hState[TSR_PRM_INT_STATE].each_with_index{|hIntState, nIndex|
          hIntState.each{|sStat, sProcUnit|
            @hState[TSR_PRM_INT_STATE][nIndex][sStat] = alias_replace(sProcUnit, hAlias)
          }
        }
      end
    end

    #=================================================================
    # 概  要: オブジェクトを複製して返す
    #=================================================================
    def dup()
      cObjectInfo = super()

      # オブジェクトID複製
      cObjectInfo.sObjectID = safe_dup(@sObjectID)
      # オブジェクトタイプ複製
      cObjectInfo.sObjectType = safe_dup(@sObjectType)
      # パラメータ複製
      cObjectInfo.hState = safe_dup(@hState)

      return cObjectInfo  # [Object]複製したオブジェクト
    end
  end
end
