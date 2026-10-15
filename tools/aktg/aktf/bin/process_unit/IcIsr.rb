#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2013-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2013-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2013-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2013-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2013-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2013-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2013-2014 by Witz Corporation, JAPAN
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
# $Id: IcIsr.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "aktf/bin/process_unit/ProcessUnit.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: IcIsr
  # 概    要: ICISRの情報を処理するクラス
  #===================================================================
  class IcIsr < ProcessUnit

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
        # osapのチェック
        if (is_specified?(TSR_PRM_OSAP))
          sAtr = TSR_PRM_OSAP
          val = @hState[TSR_PRM_OSAP]
          check_attribute_type(sAtr, val, String, false, @aPath)
          if (@cConf.is_sc1?() || @cConf.is_sc2?())
            check_attribute_enum(sAtr, val, GRP_OSAP_SC1MC, @aPath)
          else
            if (@cConf.get_memory_protection_level() == CFG_MEMORY_PROTECTION_LEVEL3)
              check_attribute_enum(sAtr, val, GRP_OSAP_ALL_AVAILABLE_SC3, @aPath)
            else
              check_attribute_enum(sAtr, val, GRP_OSAP_TRUSTED_AVAILABLE_SC3, @aPath)
            end
          end
        end
        # accosapのチェック
        if (is_specified?(TSR_PRM_ACCOSAP))
          sAtr = TSR_PRM_ACCOSAP
          val = @hState[TSR_PRM_ACCOSAP]
          check_attribute_type(sAtr, val, Array, false, @aPath)
          val.each {|sTrusted|
            check_attribute_enum(sAtr, sTrusted, GRP_OSAP_NON_TRUSTED_AVAILABLE_SC3, @aPath)
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
        ### T3_MC_ICISR001: relresで指定されたリソースが重複している
        if (!@hState[TSR_PRM_RELRES].nil?())
          if (@hState[TSR_PRM_RELRES].size != @hState[TSR_PRM_RELRES].uniq.size)
            sErr = sprintf("T3_C2ISR001: " + ERR_RESID_DUPLICATE, TSR_PRM_RELRES)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        end
      end

      ### T3_MC_ICISR002: getresで指定されたリソースが重複している
      if (!@hState[TSR_PRM_GETRES].nil?())
        if (@hState[TSR_PRM_GETRES].size != @hState[TSR_PRM_GETRES].uniq.size)
          sErr = sprintf("T3_C2ISR002: " + ERR_RESID_DUPLICATE, TSR_PRM_GETRES)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      ### T3_MC_ICISR003:rtnstatがAK_ACTIVATE_WAITSPINの場合に，spnidが指定されていない
      if (@hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITSPIN && @hState[TSR_PRM_SPNID].nil?())
        sErr = sprintf("T3_C2ISR002: " + ERR_NOT_SET_SPINID, @hState[TSR_PRM_RTNSTAT], TSR_STT_ACTIVETE_WAITSPIN)
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      ### T3_MC_ICISR004: getspnで指定されたスピンロックが重複している
      if (!@hState[TSR_PRM_GETSPN].nil?())
        if (@hState[TSR_PRM_GETSPN].size != @hState[TSR_PRM_GETSPN].uniq.size)
          sErr = sprintf("T3_C2ISR002: " + ERR_SPNID_DUPLICATE, TSR_PRM_GETSPN)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      super()

      # intatr
      if (!is_specified?(TSR_PRM_INTATR))
        @hState[TSR_PRM_INTATR] = TSR_STT_ENABLE
      end

      # istat
      if (!is_specified?(TSR_PRM_ISTAT))
        @hState[TSR_PRM_ISTAT] = TSR_STT_ENABLE
      end

      # istksz
      if (!is_specified?(TSR_PRM_ISTKSZ))
        @hState[TSR_PRM_ISTKSZ] = "AKTSP_ICISR_STACK_SIZE"
      end

      # osap
      if (!is_specified?(TSR_PRM_OSAP))
        @hState[TSR_PRM_OSAP] = @cConf.get_default_osap_id()
      elsif (@hState[TSR_PRM_OSAP] == "ANY_OSAP_1")
        hMacro  = @cConf.get_macro()
        @hState[TSR_PRM_OSAP] = hMacro["ANY_OSAP_1"]
      end

      # coreid
      @hState[TSR_PRM_COREID] = @cConf.get_core_id_from_osap(@hState[TSR_PRM_OSAP])

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

  end
end
