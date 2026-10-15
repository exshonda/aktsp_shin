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
# $Id: ScheduleTable.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "aktf/bin/sc_object/SCObject.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: ScheduleTable
  # 概    要: スケジュールテーブルの情報を処理するクラス
  #===================================================================
  class ScheduleTable < SCObject

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
        # curvalのチェック
        if (is_specified?(TSR_PRM_CURVAL))
          # curval(>= 0，<= duration)
          sAtr = TSR_PRM_CURVAL
          val = @hState[TSR_PRM_CURVAL]
          check_attribute_type(sAtr, val, Integer, false, @aPath)
          if (@hState[TSR_PRM_DURATION].is_a?(Integer))
            check_attribute_range(sAtr, val, 0, @hState[TSR_PRM_DURATION], @aPath)
          end
        end
        # starttickのチェック
        if (is_specified?(TSR_PRM_STARTTICK))
          # starttickのT2_002は，T4_083,T4_084でチェック
          sAtr = TSR_PRM_STARTTICK
          val = @hState[TSR_PRM_STARTTICK]
          check_attribute_type(sAtr, val, Integer, false, @aPath)
        end
        # autostarttypeのチェック
        if (is_specified?(TSR_PRM_AUTOSTARTTYPE))
          sAtr = TSR_PRM_AUTOSTARTTYPE
          val = @hState[TSR_PRM_AUTOSTARTTYPE]
          check_attribute_type(sAtr, val, String, false, @aPath)
          check_attribute_enum(sAtr, val, GRP_SCHEDULE_TABLE_AUTOSTARTTYPE, @aPath)
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
      if ((@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUNNING) || (@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUN_AND_SYNC))
        ### T3_SCHTBL003: syncstrategyがAK_NONEであるのに，SCHEDULETABLE_WAITING，SCHEDULETABLE_RUNNING_AND_SYNCHRONOUSが指定されている
        if ((@hState[TSR_PRM_SYNCSTRATEGY] == TSR_STT_NONE) && (@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUN_AND_SYNC))
          sErr = sprintf("T3_SCHTBL003: " + ERR_CANNOT_SET_STSTAT, @hState[TSR_PRM_SYNCSTRATEGY], @hState[TSR_PRM_STSTAT])
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_SCHTBL004: syncstrategyがAK_IMPLICITであるのに，SCHEDULETABLE_RUNNING，SCHEDULETABLE_WAITINGが指定されている
        if ((@hState[TSR_PRM_SYNCSTRATEGY] == TSR_STT_IMPLICIT) && (@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUNNING))
          sErr = sprintf("T3_SCHTBL004: " + ERR_CANNOT_SET_STSTAT, @hState[TSR_PRM_SYNCSTRATEGY], @hState[TSR_PRM_STSTAT])
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      elsif ((@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_STOPPED) || (@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT))
        ### T3_SCHTBL002: ststatがSCHEDULETABLE_STOPPED，SCHEDULETABLE_NEXTであるのに，curvalが指定されている
        if (!@hState[TSR_PRM_CURVAL].nil?())
          sErr = sprintf("T3_SCHTBL002: " + ERR_CANNOT_SET_CURVAL, @hState[TSR_PRM_STSTAT])
          aErrors.push(YamlError.new(sErr, @aPath))
        end
        ### T3_SCHTBL005: ststatがSCHEDULETABLE_NEXTであるが，stfromが指定されていない
        if ((@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT) && (@hState[TSR_PRM_STFROM].nil?()))
          sErr = sprintf("T3_SCHTBL005: " + ERR_NOT_SET_STFROM)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      ### T3_SCHTBL006: ststatがSCHEDULETABLE_NEXTでないが，stfromが指定されている
      if ((@hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_NEXT) && (!@hState[TSR_PRM_STFROM].nil?()))
        sErr = sprintf("T3_SCHTBL006: " + ERR_CANNOT_SET_STFROM, @hState[TSR_PRM_STSTAT])
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      ### T3_SCHTBL008: syncstrategyがAK_IMPLICITである場合に，autostarttypeにAK_RELATIVEを指定している
      if ((@hState[TSR_PRM_SYNCSTRATEGY] == TSR_STT_IMPLICIT) && (@hState[TSR_PRM_AUTOSTARTTYPE] == TSR_STT_RELATIVE))
        sErr = sprintf("T3_SCHTBL008: " + ERR_CANNOT_SET_AUTOSTARTTYPE, @hState[TSR_PRM_SYNCSTRATEGY], @hState[TSR_PRM_AUTOSTARTTYPE])
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      ### T3_SCHTBL009: syncstrategyがAK_EXPLICITでない場合に，autostarttypeにAK_SYNCHRONを指定している
      if ((@hState[TSR_PRM_SYNCSTRATEGY] != TSR_STT_EXPLICIT) && (@hState[TSR_PRM_AUTOSTARTTYPE] == TSR_STT_SYNCHRON))
        sErr = sprintf("T3_SCHTBL009: " + ERR_CANNOT_SET_AUTOSTARTTYPE, @hState[TSR_PRM_SYNCSTRATEGY], @hState[TSR_PRM_AUTOSTARTTYPE])
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      if (bIsPre == true)
        ### T3_SCHTBL010: autostarttypeとappmodeのどちらかしか指定されていない
        if (((@hState[TSR_PRM_APPMODE].nil?()) && (!@hState[TSR_PRM_AUTOSTARTTYPE].nil?())) ||
            ((!@hState[TSR_PRM_APPMODE].nil?()) && (@hState[TSR_PRM_AUTOSTARTTYPE].nil?())))
          sErr = sprintf("T3_SCHTBL010: " + ERR_APPMDOE_AUTOSTARTTYPE)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      # starttick
      if (!is_specified?(TSR_PRM_STARTTICK))
        @hState[TSR_PRM_STARTTICK] = 0
      end

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

      # 補完例外(curval)
      if (!is_specified?(TSR_PRM_CURVAL) && (cPrevObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUNNING ||
          cPrevObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_WAITING || cPrevObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_RUN_AND_SYNC) &&
          (@hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_STOPPED || @hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT))
        @hState[TSR_PRM_CURVAL] = nil
      end
      # 補完例外(stfrom)
      if (!is_specified?(TSR_PRM_STFROM) && cPrevObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT && @hState[TSR_PRM_STSTAT] != TSR_STT_SCHTBL_NEXT)
        @hState[TSR_PRM_STFROM] = nil
      end
    end

  end
end
