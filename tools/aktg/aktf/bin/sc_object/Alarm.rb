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
# $Id: Alarm.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "aktf/bin/sc_object/SCObject.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Alarm
  # 概    要: アラームの情報を処理するクラス
  #===================================================================
  class Alarm < SCObject

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

      begin
        # autostarttypeのチェック
        if (is_specified?(TSR_PRM_AUTOSTARTTYPE))
          sAtr = TSR_PRM_AUTOSTARTTYPE
          val = @hState[TSR_PRM_AUTOSTARTTYPE]
          check_attribute_type(sAtr, val, String, false, @aPath)
          check_attribute_enum(sAtr, val, GRP_ALARM_AUTOSTARTTYPE, @aPath)
        end
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
      if (@hState[TSR_PRM_ASTAT] == TSR_STT_SET)
        ### T3_ALM001: astatがAK_SETであるのに，almvalが指定されていない
        if (@hState[TSR_PRM_ALMVAL].nil?())
          sErr = sprintf("T3_ALM001: " + ERR_NOT_SET_ALARM, TSR_PRM_ALMVAL)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_ALM002: astatがAK_SETであるのに，cycleが指定されていない
        if (@hState[TSR_PRM_CYCLE].nil?())
          sErr = sprintf("T3_ALM002: " + ERR_NOT_SET_ALARM, TSR_PRM_CYCLE)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      else
        ### T3_ALM006: astatがAK_UNSETであるのに，almvalが指定されてる
        if (!@hState[TSR_PRM_ALMVAL].nil?())
          sErr = sprintf("T3_ALM006: " + ERR_CANNOT_SET_ALARM, TSR_PRM_ALMVAL)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_ALM007: astatがAK_UNSETであるのに，cycleが指定されている
        if (!@hState[TSR_PRM_CYCLE].nil?())
          sErr = sprintf("T3_ALM007: " + ERR_CANNOT_SET_ALARM, TSR_PRM_CYCLE)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_ALM008: appmodeが指定されているのに，astatがAK_UNSETである
        if ((bIsPre == true) && (!@hState[TSR_PRM_APPMODE].nil?()))
          sErr = sprintf("T3_ALM008: " + ERR_APPMODE_NOT_SET_ALARM)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      # 満了処理に必要な項目と不要な項目のリスト作成
      aRequiredList = GRP_REQUIRED_PRM_WITH_ALMACT[@hState[TSR_PRM_ALMACT]]
      aUnnecessaryList = GRP_PRM_FOR_ALMACT - aRequiredList

      aRequiredList.each{|sPrm|
        ### T3_ALM003: almactの設定値による満了処理に必要な項目が指定されていない
        if (@hState[sPrm].nil?())
          sErr = sprintf("T3_ALM003: " + ERR_NOT_SET_ALMACT, TSR_PRM_ALMACT, @hState[TSR_PRM_ALMACT], sPrm)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      }
      aUnnecessaryList.each{|sPrm|
        ### T3_ALM004: almactの設定値による満了処理に不要な項目が指定されている
        if (!@hState[sPrm].nil?())
          sErr = sprintf("T3_ALM004: " + ERR_UNNECESSARY_SET_ALMACT, TSR_PRM_ALMACT, @hState[TSR_PRM_ALMACT], sPrm)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      }

      if (@hState[TSR_PRM_ALMACT] == TSR_STT_ALM_INCNT)
        ### T3_ALM005: almactがAK_ALM_INCNTの場合，counterとincounterが同一である
        if (@hState[TSR_PRM_COUNTER] == @hState[TSR_PRM_INCOUNTER])
          aErrors.push(YamlError.new("T3_ALM005: " + ERR_NOT_SAME_COUNTER, @aPath))
        end
      end

      if (bIsPre == true)
        ### T3_ALM009: autostarttypeとappmodeのどちらかしか指定されていない
        if (((@hState[TSR_PRM_APPMODE].nil?()) && (!@hState[TSR_PRM_AUTOSTARTTYPE].nil?())) ||
            ((!@hState[TSR_PRM_APPMODE].nil?()) && (@hState[TSR_PRM_AUTOSTARTTYPE].nil?())))
          sErr = sprintf("T3_ALM009: " + ERR_APPMDOE_AUTOSTARTTYPE)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      if (@cConf.is_multi?())
        hMacro  = @cConf.get_macro()
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

    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObjectInfo)
      check_class(SCObject, cPrevObjectInfo)  # 直前のオブジェクト情報

      super(cPrevObjectInfo)

      # 補完例外(almval，cycle)
      if (!is_specified?(TSR_PRM_ALMVAL) && cPrevObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET &&
          @hState[TSR_PRM_ASTAT] == TSR_STT_UNSET)
        @hState[TSR_PRM_ALMVAL] = nil
      end
      if (!is_specified?(TSR_PRM_CYCLE) && cPrevObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET &&
          @hState[TSR_PRM_ASTAT] == TSR_STT_UNSET)
        @hState[TSR_PRM_CYCLE] = nil
      end
    end

  end
end
