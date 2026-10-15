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
# $Id: Counter.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "aktf/bin/sc_object/SCObject.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Counter
  # 概    要: カウンタの情報を処理するクラス
  #===================================================================
  class Counter < SCObject
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
        # curval(>= 0，<= maxval)
        sAtr = TSR_PRM_CURVAL
        val = @hState[TSR_PRM_CURVAL]
        check_attribute_type(sAtr, val, Integer, false, @aPath)
        ### T3_CNT002: ctypeがAK_HARDWAREであるのに，maxvalが指定されている
        # 本来，オブジェクトチェックで実施する内容だが，ハードウェアカウンタかつmaxvalを指定した場合に
        # curvalの範囲チェックより先に検出するために，ここで実施する
        if (is_hardware_counter?() && is_specified?(TSR_PRM_MAXVAL))
          sErr = sprintf("T3_CNT002: " + ERR_CANNOT_SET_COUNTER, TSR_PRM_MAXVAL)
          aErrors.push(YamlError.new(sErr, @aPath))
        elsif (@hState[TSR_PRM_MAXVAL].is_a?(Integer))
          check_attribute_range(sAtr, val, 0, @hState[TSR_PRM_MAXVAL], @aPath)
        end
        # osapのチェック
        if ((!is_hardware_counter?()) && (is_specified?(TSR_PRM_OSAP)))
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
      if (bIsPre == true)
        if (is_hardware_counter?())
          ### T3_CNT001: ctypeがAK_HARDWAREであるのに，mincycが指定されている
          if (is_specified?(TSR_PRM_MINCYC))
            sErr = sprintf("T3_CNT001: " + ERR_CANNOT_SET_COUNTER, TSR_PRM_MINCYC)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
          ### T3_CNT004: ctypeがAK_HARDWAREであるのに，ticksperbaseが指定されている
          if (is_specified?(TSR_PRM_TICKSPERBASE))
            sErr = sprintf("T3_CNT004: " + ERR_CANNOT_SET_COUNTER, TSR_PRM_TICKSPERBASE)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
          ### T3_OSAP_CNT001: ctypeがAK_HARDWAREであるのに，osapが指定されている
          if ((@cConf.enable_osap?()) && (is_specified?(TSR_PRM_OSAP)))
            sErr = sprintf("T3_OSAP_CNT001: " + ERR_CANNOT_SET_COUNTER, TSR_PRM_OSAP)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        else
          ### T3_CNT005: ctypeがAK_SOFTWAREであるのに，mincycが指定されていない
          if (!is_specified?(TSR_PRM_MINCYC))
            sErr = sprintf("T3_CNT005: " + ERR_NOT_SET_COUNTER, TSR_PRM_MINCYC)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
          ### T3_CNT006: ctypeがAK_SOFTWAREであるのに，maxvalが指定されていない
          if (!is_specified?(TSR_PRM_MAXVAL))
            sErr = sprintf("T3_CNT006: " + ERR_NOT_SET_COUNTER, TSR_PRM_MAXVAL)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
          ### T3_SC3_CNT001: ctypeがAK_SOFTWAREであるのに，osapが指定されていない
          if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && (!is_specified?(TSR_PRM_OSAP)))
            sErr = sprintf("T3_SC3_CNT001: " + ERR_NOT_SET_COUNTER, TSR_PRM_OSAP)
            aErrors.push(YamlError.new(sErr, @aPath))
          end
        end
      end

      if (is_hardware_counter?() && is_specified?(TSR_PRM_CSTAT))
        ### T3_CNT003: ctypeがAK_HARDWAREであるのに，cstatが指定されている
        sErr = sprintf("T3_CNT003: " + ERR_CANNOT_SET_COUNTER, TSR_PRM_CSTAT)
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      hHwcntParam = @cConf.get_hardware_counter_param()
      hMacro  = @cConf.get_macro()

      # ハードウェアカウンタのmincyc，maxval，osap
      if (is_hardware_counter?())
        @hState[TSR_PRM_MINCYC] = hHwcntParam[CFG_HWCNT_MINCYC]
        @hState[TSR_PRM_MAXVAL] = hHwcntParam[CFG_HWCNT_MAXVAL]
        if (@cConf.is_sc3?() || @cConf.is_sc4?())
          @hState[TSR_PRM_OSAP] = hHwcntParam[CFG_HWCNT_OSAP]
        elsif ((@cConf.is_sc1?() || @cConf.is_sc2?()) && @cConf.is_multi?())
          @hState[TSR_PRM_OSAP] = @cConf.get_default_osap_id()
        end
      end
      # ticksperbase
      if (!is_specified?(TSR_PRM_TICKSPERBASE))
        @hState[TSR_PRM_TICKSPERBASE] = hMacro["ANY_TICKSPERBASE"]
      end

      # cstat
      if (!is_specified?(TSR_PRM_CSTAT) && !is_hardware_counter?())
        @hState[TSR_PRM_CSTAT] = TSR_STT_CS_NULL
      end

      if (@cConf.is_multi?() && !is_hardware_counter?())
        # マルチコアかつソフトウェアカウンタ限定
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

  end
end
