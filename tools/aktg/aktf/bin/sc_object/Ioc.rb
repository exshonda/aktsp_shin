#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2012-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2012-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2012-2013 by Spansion LLC, USA
# Copyright (C) 2012-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2012-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2012-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2012-2014 by Sunny Giken Inc., JAPAN
# Copyright (C) 2012-2014 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2012-2014 by Witz Corporation, JAPAN
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
# $Id: Ioc.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "aktf/bin/sc_object/SCObject.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: IOC
  # 概    要: IOCの情報を処理するクラス
  #===================================================================
  class Ioc < SCObject

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
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []
      if (bIsPre == true)
        ### senderが2個以上，かつ，iocdataが2個以上指定されている
        if (@hState[TSR_PRM_SENDER].length >= 2 && @hState[TSR_PRM_IOCDATA].length >= 2)
          sErr = sprintf("T3_OSAP_IOC001: " + ERR_SENDER_IOCDATA_NUM)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      if (@hState[TSR_PRM_MAXQUE] == 0)
        ### T3_OSAP_IOC002: maxqueが0であるが，lostflgが指定されている
        if (!@hState[TSR_PRM_LOSTFLG].nil?())
          sErr = sprintf("T3_OSAP_IOC002: " + ERR_MAXQUE_0_NOT_SET, TSR_PRM_LOSTFLG)
          aErrors.push(YamlError.new(sErr, @aPath))
        ### T3_OSAP_IOC003: maxqueが0であるが，datalistが指定されている
        elsif (!@hState[TSR_PRM_DATALIST].nil?())
          sErr = sprintf("T3_OSAP_IOC003: " + ERR_MAXQUE_0_NOT_SET, TSR_PRM_DATALIST)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      elsif (@hState[TSR_PRM_MAXQUE] >= 1)
        ### T3_OSAP_IOC004: maxqueが1以上であるが，dataが指定されている
        if (!@hState[TSR_PRM_DATA].nil?())
          sErr = sprintf("T3_OSAP_IOC004: " + ERR_MAXQUE_1_NOT_SET, TSR_PRM_DATA)
          aErrors.push(YamlError.new(sErr, @aPath))
        end
      end

      ### T3_OSAP_IOC005: datalistの数がmaxqueより大きい
      if (!@hState[TSR_PRM_DATALIST].nil?() && @hState[TSR_PRM_DATALIST].length > @hState[TSR_PRM_MAXQUE])
        sErr = sprintf("T3_OSAP_IOC005: " + ERR_DATALIST_NUM_MAXQUE)
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      ### T3_OSAP_IOC006: lostflgにtrueが指定されているが，datalistの数とmaxqueが同じではない
      if (@hState[TSR_PRM_LOSTFLG] == true && @hState[TSR_PRM_DATALIST].length != @hState[TSR_PRM_MAXQUE])
        sErr = sprintf("T3_OSAP_IOC006: " + ERR_LOSTFLG_DATA_NUM)
        aErrors.push(YamlError.new(sErr, @aPath))
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObjectInfo)
      check_class(SCObject, cPrevObjectInfo)  # 直前のオブジェクト情報

      # iocdata
      if (!is_specified?(TSR_PRM_IOCDATA))
        @hState[TSR_PRM_IOCDATA] = cPrevObjectInfo.hState[TSR_PRM_IOCDATA]
      end

      # sender
      if (!is_specified?(TSR_PRM_SENDER))
        @hState[TSR_PRM_SENDER] = cPrevObjectInfo.hState[TSR_PRM_SENDER]
      end

      # receiver
      if (!is_specified?(TSR_PRM_RECEIVER))
        @hState[TSR_PRM_RECEIVER] = cPrevObjectInfo.hState[TSR_PRM_RECEIVER]
      end

      # maxque
      if (!is_specified?(TSR_PRM_MAXQUE))
        @hState[TSR_PRM_MAXQUE] = cPrevObjectInfo.hState[TSR_PRM_MAXQUE]
      end

      # lostflg
      if (!is_specified?(TSR_PRM_LOSTFLG))
        @hState[TSR_PRM_LOSTFLG] = cPrevObjectInfo.hState[TSR_PRM_LOSTFLG]
      end

    end
    
    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      # ID
      @sObjectID = alias_replace(@sObjectID, hAlias)

      # センダ
      @aSender = []
      aSender = @hState[TSR_PRM_SENDER]
      if (!aSender.nil?())
        aSender.each{|sSender|
          sSender = alias_replace(sSender, hAlias)
          @aSender.push(sSender)
        }
        @hState[TSR_PRM_SENDER] = @aSender
      end

      # レシーバ
      @hState[TSR_PRM_RECEIVER] = alias_replace(@hState[TSR_PRM_RECEIVER], hAlias)

      # IOC通信データ
      @aIocData = []
      aIocData = @hState[TSR_PRM_IOCDATA]
      if (!aIocData.nil?())
        aIocData.each{|sIocDataId|
          sIocDataId = alias_replace(sIocDataId, hAlias)
          @aIocData.push(sIocDataId)
        }
        @hState[TSR_PRM_IOCDATA] = @aIocData
      end

      # 格納されたデータ
      # キューあり
      if (!@hState[TSR_PRM_DATALIST].nil?())
        aAliasDataList = []
        @hState[TSR_PRM_DATALIST].each{|aDataList|
          aAliasData = []
          aDataList.each{|hDatalist|
            hDatalist.each{|sId, snVal|
              sIocDataId = alias_replace(sId, hAlias)
              hDatalist = {sIocDataId => snVal}
              aAliasData.push(hDatalist)
            }
          }
          aAliasDataList.push(aAliasData)
        }
        @hState[TSR_PRM_DATALIST] = aAliasDataList
      # キューなし
      elsif (!@hState[TSR_PRM_DATA].nil?())
        aAliasData = []
        @hState[TSR_PRM_DATA].each{|hData|
          hData.each{|sId, snVal|
            sIocDataId = alias_replace(sId, hAlias)
            hData = {sIocDataId => snVal}
            aAliasData.push(hData)
          }
        }
        @hState[TSR_PRM_DATA] = aAliasData
      end
    end
  end
end
