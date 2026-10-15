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
# $Id: MemoryArea.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/CommonModule.rb"
require "common/bin/Config.rb"
require "aktf/bin/sys_state/MemoryArea.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: MemoryArea
  # 概    要: メモリ領域属性の情報を処理するクラス
  #===================================================================
  class MemoryArea
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: メモリ領域属性の初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      @cConf  = Config.new()
      @hState = {}

      @sObjectID   = sObjectID
      @sObjectType = TSR_OBJ_MEMORY_AREA
      @aPath       = aPath + [@sObjectID]

      @hState[TSR_PRM_MEMATR]  = nil  # 追加する属性情報
      @hState[TSR_PRM_BASE]    = nil  # 属性情報を設定する領域の先頭番地
      @hState[TSR_PRM_SIZE]    = nil  # 属性情報を設定する領域のサイズ
      @hState[TSR_PRM_OSAP]    = nil  # 所属するOSAP
      @hState[TSR_PRM_COREID]  = nil  # コアID

      pre_attribute_check(hObjectInfo, aPath + [@sObjectID], bIsPre)
      store_object_info(hObjectInfo)
    end

    #=================================================================
    # 概  要: テストシナリオの通り処理単位オブジェクトデータを
    #         @hStateに代入
    #=================================================================
    def store_object_info(hObjectInfo)
      check_class(Hash, hObjectInfo)  # オブジェクト情報

      # 格納
      set_specified_attribute(hObjectInfo)
      hObjectInfo.each{|atr, val|
        if (atr != TSR_PRM_TYPE)
          @hState[atr] = val
        end
      }
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      sMematr = CONVERT_TESRY_TO_ATK2[TSR_STT_MEMPRSV]
      sWrite = TSR_STT_TRUE
      sRead  = TSR_STT_TRUE
      sExec  = TSR_STT_FALSE
      sCache = TSR_STT_TRUE
      sDev   = TSR_STT_FALSE
      if (!@hState[TSR_PRM_MEMATR].nil?())
        @hState[TSR_PRM_MEMATR].each {|sAttribute|
          case sAttribute
          when TSR_STT_NOWRITE
            sWrite = TSR_STT_FALSE
            sMematr = sMematr + " | " + CONVERT_TESRY_TO_ATK2[TSR_STT_NOWRITE]
          when TSR_STT_NOREAD
            sRead  = TSR_STT_FALSE
            sMematr = sMematr + " | " + CONVERT_TESRY_TO_ATK2[TSR_STT_NOREAD]
          when TSR_STT_EXEC
            sExec  = TSR_STT_TRUE
            sMematr = sMematr + " | " + CONVERT_TESRY_TO_ATK2[TSR_STT_EXEC]
          when TSR_STT_UNCACHE
            sCache = TSR_STT_FALSE
            sMematr = sMematr + " | " + CONVERT_TESRY_TO_ATK2[TSR_STT_UNCACHE]
          when TSR_STT_IODEV
            sDev   = TSR_STT_TRUE
            sMematr = sMematr + " | " + CONVERT_TESRY_TO_ATK2[TSR_STT_IODEV]
          end
        }
      end

      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = IMC_MEM_NO_OSAP
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      cElement.set_cfg_memarea({XML_SNAME     => @sObjectID,
                                :mematr       => sMematr,
                                XML_P_A_WRITE => sWrite,
                                XML_P_A_READ  => sRead,
                                XML_P_A_EXEC  => sExec,
                                XML_P_A_CACHE => sCache,
                                XML_P_A_IODEV => sDev,
                                XML_P_A_ADD   => @hState[TSR_PRM_BASE],
                                XML_P_A_SIZE  => @hState[TSR_PRM_SIZE],
                                :osap         => sOsap,
                                :coreid       => @hState[TSR_PRM_COREID]})
    end
  end
end
