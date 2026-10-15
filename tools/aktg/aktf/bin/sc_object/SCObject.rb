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
#  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
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
#  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#  の責任を負わない．
#
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
    include AKTFModule
    include AKTFModule::ObjectCommon

    #=================================================================
    # 概  要: 属性チェック(何の属性を指定したかをチェック)
    #=================================================================
    def pre_attribute_check(hObjectInfo, aPath, bIsPre)
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      aErrors = []
      begin
        super(hObjectInfo, aPath, bIsPre)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end

      hMacro = @cConf.get_macro()
      # 満了点情報
      if (!hObjectInfo[TSR_PRM_EXPOINT].nil?())
        begin
          # ハッシュから配列に変更するため，先に型チェック(T2_001)を実施
          check_attribute_type(TSR_PRM_EXPOINT, hObjectInfo[TSR_PRM_EXPOINT], Hash, false, @aPath)
          hTempObjectInfo = safe_dup(hObjectInfo)
          hTempObjectInfo[TSR_PRM_EXPOINT].each{|key, val|
            # マクロの置換を実施
            nOffset = parse_value(key, hMacro)
            # ソートするため，オフセットの型を先に型チェック(T2_001)を実施
            check_attribute_type("offset", nOffset, Integer, false, @aPath + [TSR_PRM_EXPOINT])
            check_attribute_type("#{key}", val, Hash, false, @aPath + [TSR_PRM_EXPOINT])
            val.each{|sAtr, val2|
              case sAtr

              # acttskの型チェック
              when TSR_PRM_ACTTSK
                check_attribute_type(sAtr, val2, Array, false, @aPath + [TSR_PRM_EXPOINT, key])

              # setevtの型チェック
              when TSR_PRM_SETEVT
                check_attribute_type(sAtr, val2, Array, false, @aPath + [TSR_PRM_EXPOINT, key])
                val2.each{|hAction|
                  check_attribute_type("action", hAction, Hash, false, @aPath + [TSR_PRM_EXPOINT, key, sAtr])
                }

              # 満了点の定義に定義可能な属性以外が指定されている
              else
                sErr = sprintf("T1_021: " + ERR_UNDEFINED_KEY, sAtr)
                aErrors.push(YamlError.new(sErr, aPath))
              end
            }
            if (key != nOffset)
              hObjectInfo[TSR_PRM_EXPOINT][nOffset] = val
              hObjectInfo[TSR_PRM_EXPOINT].delete(key)
            end
          }
        rescue YamlError
          aErrors.push($!)
        end
      end

      # IOC data,datalist
      ### T1_022: pre_conditionで指定必須な属性が指定されていない
      if (@cConf.is_multi?())
        # maxqueの型チェックは，T2_001で実施
        if (hObjectInfo[TSR_PRM_TYPE] == TSR_OBJ_IOC && hObjectInfo[TSR_PRM_MAXQUE].is_a?(Integer))
          if (hObjectInfo[TSR_PRM_MAXQUE] == 0 && !hObjectInfo.has_key?(TSR_PRM_DATA))
            sErr = sprintf("T1_022: " + ERR_REQUIRED_KEY, TSR_PRM_DATA)
            aErrors.push(YamlError.new(sErr, aPath))
          elsif (hObjectInfo[TSR_PRM_MAXQUE] >= 1 && !hObjectInfo.has_key?(TSR_PRM_DATALIST))
            sErr = sprintf("T1_022: " + ERR_REQUIRED_KEY, TSR_PRM_DATALIST)
            aErrors.push(YamlError.new(sErr, aPath))
          end
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []

      @hState.each{|sAtr, val|
        begin
          sAtr = get_real_attribute_name(sAtr)
          if (is_specified?(sAtr))
            case sAtr

            # 0より大きい整数
            when TSR_PRM_MAXVAL, TSR_PRM_TICKSPERBASE, TSR_PRM_DURATION
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              check_attribute_gt(sAtr, val, 0, @aPath)

            # 0より大きい整数か文字列
            when TSR_PRM_MASK
              check_attribute_type(sAtr, val, [String, Integer], false, @aPath)
              if (!val.is_a?(String))
                check_attribute_gt(sAtr, val, 0, @aPath)
              end

            # 0以上の整数か文字列
            when TSR_PRM_INITVAL
              check_attribute_type(sAtr, val, [String, Integer], false, @aPath)
              if (!val.is_a?(String))
                check_attribute_unsigned(sAtr, val, @aPath)
              end

            # 0以上の整数
            when TSR_PRM_MAXQUE, TSR_PRM_SENDERID
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              check_attribute_unsigned(sAtr, val, @aPath)

            # 文字列
            when TSR_PRM_LINKRES, TSR_PRM_COUNTER, TSR_PRM_TASK, TSR_PRM_EVENT, TSR_PRM_INCOUNTER,
                 TSR_PRM_CALLBAK, TSR_PRM_STFROM, TSR_PRM_SUCCESSOR, TSR_PRM_RECEIVER, TSR_PRM_DATATYPE
              check_attribute_type(sAtr, val, String, false, @aPath)

            # 規定した文字列
            when TSR_PRM_RESPROP, TSR_PRM_LOCKFLG, TSR_PRM_CTYPE, TSR_PRM_CSTAT, TSR_PRM_ALMACT, 
                 TSR_PRM_ASTAT, TSR_PRM_SYNCSTRATEGY, TSR_PRM_REPEAT, TSR_PRM_STSTAT, TSR_PRM_SUSINT,
                 TSR_PRM_KIND, TSR_PRM_LOSTFLG
              # 指定可能な値
              if (@cConf.is_single?())
                aList = GRP_SC_OBJECT_AVAILABLE_SINGLE
              else
                aList = GRP_SC_OBJECT_AVAILABLE_MULTI
              end
              check_attribute_type(sAtr, val, String, false, @aPath)
              check_attribute_enum(sAtr, val, aList[sAtr], @aPath)

            # 配列
            when TSR_PRM_APPMODE, TSR_PRM_SENDER, TSR_PRM_IOCDATA, TSR_PRM_DATA
              check_attribute_type(sAtr, val, Array, false, @aPath)

            # 配列かNil
            when TSR_PRM_DATALIST
              check_attribute_type(sAtr, val, Array, true, @aPath)

            # 満了点
            when TSR_PRM_EXPOINT
              if (val == nil)
                check_attribute_type(sAtr, val, Hash, false, @aPath)
              else
                val.each{|cExpoint|
                  check_attribute_expoint(sAtr, cExpoint, @aPath)
                }
              end

            # mincyc(>  0，<= maxval)
            when TSR_PRM_MINCYC
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              if (@hState[TSR_PRM_MAXVAL].is_a?(Integer))
                check_attribute_range(sAtr, val, 1, @hState[TSR_PRM_MAXVAL], @aPath)
              end

            # almval, cycle
            when TSR_PRM_ALMVAL, TSR_PRM_CYCLE
              # almval，cycleのT2_002は，T4でチェック
              check_attribute_type(sAtr, val, Integer, false, @aPath)

            when TSR_PRM_CURVAL, TSR_PRM_OSAP, TSR_PRM_ACCOSAP, TSR_PRM_STARTTICK, TSR_PRM_AUTOSTARTTYPE
              # 設定可能な値がオブジェクトによって異なるため，各クラスでチェックする

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
    # 概  要: オブジェクト内のマクロを置換する
    #=================================================================
    def convert_macro()
      super()

      # 満了点
      if (!@hState[TSR_PRM_EXPOINT].nil?())
        @hState[TSR_PRM_EXPOINT].each{|cExpoint|
          cExpoint.convert_macro()
        }
      end
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObj)
      check_class(SCObject, cPrevObj)  # 直前の状態のオブジェクト
      # 指定されていない場合補完
      cPrevObj.hState.each{|sAtr, val|
        sRealAtr = get_real_attribute_name(sAtr)
        if (!is_specified?(sRealAtr))
          # 満了点の補完
          if (sRealAtr == TSR_PRM_EXPOINT && val.is_a?(Array))
            complement_expiry_point(val)
          else
            @hState[sAtr] = safe_dup(val)
          end
        end
      }
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement_expiry_point(aPrevExpoint)
      check_class(Array, aPrevExpoint)  # 直前の状態のオブジェクト

      if (@hState[TSR_PRM_EXPOINT].nil?())
        @hState[TSR_PRM_EXPOINT] = safe_dup(aPrevExpoint)
        aPrevExpoint.each_with_index{|cPrevExpoint, nIndex|
          @hState[TSR_PRM_EXPOINT][nIndex] = cPrevExpoint.dup()
          @hState[TSR_PRM_EXPOINT][nIndex].aSpecifiedAttributes = []
        }
      end
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      super(hAlias)
      # 満了点情報
      if (!@hState[TSR_PRM_EXPOINT].nil?())
        hTmp = @hState[TSR_PRM_EXPOINT].dup()
        @hState[TSR_PRM_EXPOINT] = []
        hTmp.each_with_index{|cExpoint, nIndex|
          cExpoint.alias(hAlias)
          @hState[TSR_PRM_EXPOINT][nIndex] = cExpoint
        }
      end

      # アプリケーションモード
      if (!@hState[TSR_PRM_APPMODE].nil?())
        @hState[TSR_PRM_APPMODE].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_APPMODE][nIndex] = alias_replace(sRes, hAlias)
        }
      end
    end

    #=================================================================
    # 概  要: オブジェクトのエイリアス変換テーブルを返す
    #=================================================================
    def get_alias(sTestID, bSingleTest, nNum = nil)
      check_class(String, sTestID)      # テストID
      check_class(Bool, bSingleTest)    # テストケースが1件かどうか
      check_class(Integer, nNum, true)  # 識別番号

      hHwcntParam = @cConf.get_hardware_counter_param()
      hResult = {}

      if (@hState[TSR_PRM_CTYPE] == TSR_STT_HARDWARE)
        hResult[@sObjectID] = hHwcntParam[CFG_HWCNT_COUNTER_ID]
      else
        if (bSingleTest == false)
          hResult[@sObjectID] = alias_str(@sObjectID, sTestID)
        else
          hResult[@sObjectID] = @sObjectID
        end
      end

      return hResult  # [Hash]エイリアス変換テーブル
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

    #=================================================================
    # 概  要: オブジェクトの内容をYAMLオブジェクトに変換して返す
    #=================================================================
    def to_yaml(bIsPre = false)
      check_class(Bool, bIsPre)  # pre_conditionか

      hYaml = {}
      # preの場合type属性を付与
      if (bIsPre == true)
        hYaml[TSR_PRM_TYPE] = @sObjectType
      end
      # 保持している情報を取りだす
      @hState.each{|sAtr, val|
        sRealAtr = get_real_attribute_name(sAtr)
        if (!val.nil?() || is_specified?(sRealAtr))
          case sAtr
          # 満了点の情報
          when TSR_PRM_EXPOINT
            hYaml[TSR_PRM_EXPOINT] = {}
            val.each{|cExpoint|

              hYaml[TSR_PRM_EXPOINT][cExpoint.nOffset] = cExpoint.to_yaml()
            }
          # その他
          else
            hYaml[sRealAtr] = safe_dup(val)
          end
        end
      }

      return hYaml  # [Hash]YAMLオブジェクト
    end

    #=================================================================
    # 概  要: 内部保持用属性名からTESRYの属性名を取得する
    #=================================================================
    def get_real_attribute_name(sAtr)
      check_class(String, sAtr)  # 内部保持用属性名

      return sAtr  # [String]TESRYの属性名
    end
  end
end
