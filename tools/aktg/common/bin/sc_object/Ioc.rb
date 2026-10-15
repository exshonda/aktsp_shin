#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2012-2013 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2012-2013 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2012-2013 by Spansion LLC, USA
# Copyright (C) 2012-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2012-2013 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2012-2013 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2012-2013 by Sunny Giken Inc., JAPAN
# Copyright (C) 2012-2013 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2012-2013 by Witz Corporation, JAPAN
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
require "common/bin/sc_object/SCObject.rb"
require "aktf/bin/sc_object/Ioc.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: IOC
  # 概    要: IOCの情報を処理するクラス
  #===================================================================
  class Ioc < SCObject
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: IOCの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_IOC, aPath, bIsPre)

    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement, aSenderObject, cReceiverObject, aIocDataObject)
      check_class(IMCodeElement, cElement)      # エレメント
      check_class(Array, aSenderObject)         # センダオブジェクトの配列
      check_class(IocReceiver, cReceiverObject) # レシーバオブジェクト
      check_class(Array, aIocDataObject)        # IOC通信データオブジェクトの配列

      cElement.set_cfg_ioc({XML_SNAME         => @sObjectID,
                            XML_C_IOC_SND     => aSenderObject,
                            XML_C_IOC_RCV     => cReceiverObject,
                            XML_C_IOC_DATA    => aIocDataObject,
                            XML_P_IOC_BUF_LEN => @hState[TSR_PRM_MAXQUE],
                            :osap             => IMC_IOC_OSAP})
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref(cElement, hProcUnitInfo, aSenderObject, cReceiverObject, aIocDataObject)
      check_class(IMCodeElement, cElement)      # エレメント
      check_class(Hash, hProcUnitInfo)          # 処理単位情報
      check_class(Array, aSenderObject)         # センダオブジェクトの配列
      check_class(IocReceiver, cReceiverObject) # レシーバオブジェクト
      check_class(Array, aIocDataObject)        # IOC通信データオブジェクトの配列

      sMaxque = @hState[TSR_PRM_MAXQUE]                  # キューサイズ
      sQuecnt = 0                                        # キューカウント
      sLostflg = TSR_STT_FALSE                           # キューフルエラーフラグ
      sRcvosapid = cReceiverObject.hState[TSR_PRM_OSAP]  # レシーバが所属するOSAPのId

      # キューあり通信の場合
      if (sMaxque.to_i() > 0)
        # 格納されたデータなし
        if (@hState[TSR_PRM_DATALIST].nil?())
          sQuecnt = 0
        # 格納されたデータあり
        else
          sQuecnt = @hState[TSR_PRM_DATALIST].count()
        end
        # キューフルエラーフラグが指定されている場合
        if (!@hState[TSR_PRM_LOSTFLG].nil?())
          sLostflg = @hState[TSR_PRM_LOSTFLG]
        end
      end

      #=================================================================
      # 状態確認API(IOC)
      #=================================================================
      # 状態確認API用構造体変数宣言(IOC)
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_IOC_INFO], TYP_AKTSP_IOC_INFO)
      
      # 構造体作成(IOC)
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_IOC}(&#{GRP_VAR_TYPE[TYP_AKTSP_IOC_INFO]}, #{sMaxque}, #{sQuecnt}, #{sLostflg}, #{sRcvosapid})")
      # データを入れた構造体を状態確認APIへ渡す(IOC)
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_IOC}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_IOC_INFO]})")
      
      #=================================================================
      # 状態確認API(センダ)
      #=================================================================
      if (!aSenderObject.nil?())
        aSenderObject.each{|cSenderObject|
          sSenderid = cSenderObject.hState[TSR_PRM_SENDERID]
          if (sSenderid.nil?())
            sSenderid = 0
          end
          sSndosapid = cSenderObject.hState[TSR_PRM_OSAP]
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_IOC_SENDER}(#{sObjectID}, #{sSenderid}, #{sSndosapid})")
        }
      end
      
      #=================================================================
      # 状態確認API(IOC通信データ)
      #=================================================================
      sIocmbStructTypedef = "AKTSP_IOCMB_#{sObjectID}"     # typdefした構造体型
      sIocmbStructVar     = "#{sObjectID}_out"             # 変数名

      # キューあり通信(データが存在する場合)
      if ((sMaxque.to_i() > 0) and (!@hState[TSR_PRM_DATALIST].nil?()))
        # 状態確認API用構造体変数宣言(IOC通信データ)
        cElement.set_local_var(hProcUnitInfo[:id], sIocmbStructVar, sIocmbStructTypedef)
        nQueIndex = 1
        @hState[TSR_PRM_DATALIST].each{|aDataList|
          # IOCからデータを取得する
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_GET_DATA_FROM_IOC}(#{sObjectID}, &#{sIocmbStructVar}, #{nQueIndex})")
          nIocDataIndex = 1
          aDataList.each{|hDatalist|
            hDatalist.each{|sIocDataId, snVal|
              sVar = "#{sIocmbStructVar}.data#{nIocDataIndex}"
              sType = aIocDataObject[nIocDataIndex-1].hState[TSR_PRM_DATATYPE]
              gc_data_assert(cElement, hProcUnitInfo, sVar, sType, snVal)
            }
            nIocDataIndex += 1
          }
          nQueIndex += 1
        }
      # キューなし通信(データが存在する場合)
      elsif ((sMaxque.to_i() == 0) and (!@hState[TSR_PRM_DATA].nil?()))
        # 状態確認API用構造体変数宣言(IOC通信データ)
        cElement.set_local_var(hProcUnitInfo[:id], sIocmbStructVar, sIocmbStructTypedef)
        # IOCからデータを取得する
        cElement.set_verify_api(hProcUnitInfo, "#{FNC_GET_DATA_FROM_IOC}(#{sObjectID}, &#{sIocmbStructVar}, 0)")
        # CheckAssertで比較する
        nIocDataIndex = 1
        @hState[TSR_PRM_DATA].each {|hData|
          hData.each{|sIocDataId, snVal|
            sVar = "#{sIocmbStructVar}.data#{nIocDataIndex}"
            sType = aIocDataObject[nIocDataIndex-1].hState[TSR_PRM_DATATYPE]
            gc_data_assert(cElement, hProcUnitInfo, sVar, sType, snVal)
          }
          nIocDataIndex += 1
        }
      end
    end

    #=================================================================
    # 概  要: 変数の値をチェックするコードを追加する
    #=================================================================
    def gc_data_assert(cElement, hProcUnitInfo, sVar, sType, snVal)
      check_class(IMCodeElement, cElement)  # エレメント
      check_class(Hash, hProcUnitInfo)      # 処理単位情報
      check_class(String, sVar)             # 変数名
      check_class(String, sType)            # データ型
      check_class([String, Integer], snVal) # 値
      
      # 構造体ではない場合
      if (!STR_INITIAL_INFO.has_key?(sType))
        snVal = "(#{sType})#{snVal}"
        cElement.set_assert(hProcUnitInfo, sVar, snVal)
      # 構造体
      else
        aStructMember = snVal.split(/,/) # ,でメンバ変数を分解する
        nStructMemberIndex = 1           # メンバ変数のインデックス
        aStructMember.each{|sVal|
          cElement.set_assert(hProcUnitInfo, "#{sVar}.data#{nStructMemberIndex}", sVal.strip())
          nStructMemberIndex += 1
        }
      end
    end
    
  end

end
