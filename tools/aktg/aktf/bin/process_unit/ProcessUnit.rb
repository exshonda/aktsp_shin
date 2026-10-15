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
# $Id: ProcessUnit.rb 347 2014-09-17 00:28:35Z fsi-dankei $

#  TTG
#      TOPPERS Test Generator
#
#  Copyright (C) 2009-2011 by Center for Embedded Computing Systems
#              Graduate School of Information Science, Nagoya Univ., JAPAN
#  Copyright (C) 2010-2011 by Graduate School of Information Science,
#                             Aichi Prefectural Univ., JAPAN
#
#  上記著作権者は，以下の(1)~(4)の条件を満たす場合に限り，本ソフトウェ
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
require "aktf/bin/class/AKTFCommon.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: ProcessUnit
  # 概    要: 処理単位オブジェクトの情報を処理するクラス
  #===================================================================
  class ProcessUnit
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

      # var
      if (hObjectInfo[TSR_PRM_VAR].is_a?(Hash))
        hObjectInfo[TSR_PRM_VAR].each{|sVarName, hVar|
          if (hVar.is_a?(Hash))
            ### T1_024: pre_conditionで変数のtypeが指定されていない
            if (bIsPre == true && hVar[TSR_PRM_VAR_TYPE].nil?())
              sErr = sprintf("T1_024: " + ERR_REQUIRED_KEY, TSR_PRM_VAR_TYPE)
              aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_VAR, sVarName]))
            ### T1_025: post_conditionで変数のtypeが指定されている
            elsif (bIsPre == false && hVar.has_key?(TSR_PRM_VAR_TYPE))
              sErr = sprintf("T1_025: " + ERR_ONLY_PRE_ATR, TSR_PRM_VAR_TYPE)
              aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_VAR, sVarName]))
            end
          else
            # Variableクラスのインスタンス変数に代入する前にT2_001チェックを実施
            sErr = sprintf("T2_001: " + ERR_INVALID_TYPE, sVarName, "Hash", hVar.class())
            aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_VAR]))
          end
        }
      elsif (hObjectInfo[TSR_PRM_VAR].nil?())
        # 何もしない
      else
        # Variableクラスのインスタンス変数に代入する前にT2_001チェックを実施
        sErr = sprintf("T2_001: " + ERR_INVALID_TYPE, TSR_PRM_VAR, "Hash", hObjectInfo[TSR_PRM_VAR].class())
        aErrors.push(YamlError.new(sErr, aPath))
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
            # 0以上の整数
            when TSR_PRM_BOOTCNT, TSR_PRM_COREID
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              check_attribute_unsigned(sAtr, val, @aPath)

            # 0以上の整数(AK_INVALIDの場合，チェックしない)
            when TSR_PRM_CURPRI, TSR_PRM_INIPRI
              if (val != TSR_STT_INVALID)
                check_attribute_type(sAtr, val, Integer, false, @aPath)
                check_attribute_unsigned(sAtr, val, @aPath)
              end

            # 0より大きい整数
            when TSR_PRM_MAXACT, TSR_PRM_ACTCNT, TSR_PRM_PORDER, TSR_PRM_TICKSPERBASE
              check_attribute_type(sAtr, val, Integer, false, @aPath)
              check_attribute_gt(sAtr, val, 0, @aPath)

            # 文字列
            when TSR_PRM_WAIEVT, TSR_PRM_ARG, TSR_PRM_SPNID
              check_attribute_type(sAtr, val, String, false, @aPath)

            # 文字列かnil
            when TSR_PRM_WAIEVT, TSR_PRM_ARG, TSR_PRM_CALLER
              check_attribute_type(sAtr, val, String, true, @aPath)

            # 整数か文字列
            when TSR_PRM_INIINTPRI, TSR_PRM_CURINTPRI
              check_attribute_type(sAtr, val, [String, Integer], false, @aPath)

            # 0か文字列
            when TSR_PRM_CUREVT
              check_attribute_type(sAtr, val, [String, Integer], false, @aPath)
              if (!val.is_a?(String))
                check_attribute_only0(sAtr, val, @aPath)
              end

            # 0以上の整数か文字列
            when TSR_PRM_INTNO, TSR_PRM_STKSZ, TSR_PRM_STK, TSR_PRM_SSTKSZ, 
                 TSR_PRM_SSTK, TSR_PRM_ISTKSZ
              check_attribute_type(sAtr, val, [String, Integer], false, @aPath)
              if (!val.is_a?(String))
                check_attribute_unsigned(sAtr, val, @aPath)
              end

            # var
            when TSR_PRM_VAR
              check_attribute_type(sAtr, val, Hash, false, @aPath)
              # 変数名のチェック
              val.each{|sVarName, cVar|
                if (sVarName.is_a?(String))
                  sTempVarName = sVarName.gsub(/\[\w*\]/, "")
                else
                  sTempVarName = sVarName
                end
                check_attribute_variable(sAtr, sTempVarName, @aPath)
                cVar.check_attribute_value()
              }

            # 規定した文字列
            when TSR_PRM_TSTAT, TSR_PRM_TTYPE, TSR_PRM_SPOLICY, TSR_PRM_RTNSTAT, 
                 TSR_PRM_INTATR, TSR_PRM_ISTAT, TSR_PRM_HOOKSTAT, TSR_PRM_CBSTAT
              # 指定可能な値
              if (@cConf.is_single?())
                aList = GRP_PROC_UNIT_AVAILABLE_SINGLE
              else
                aList = GRP_PROC_UNIT_AVAILABLE_MULTI
              end
              check_attribute_type(sAtr, val, String, false, @aPath)
              check_attribute_enum(sAtr, val, aList[sAtr], @aPath)

            # 配列
            when TSR_PRM_RELRES, TSR_PRM_RELEVT, TSR_PRM_APPMODE
              check_attribute_type(sAtr, val, Array, false, @aPath)

            # 配列かNil
            when TSR_PRM_GETRES, TSR_PRM_NEED_SI, TSR_PRM_ERROR_HOOK_CFG, TSR_PRM_GETSPN
              check_attribute_type(sAtr, val, Array, true, @aPath)
              if ((sAtr == TSR_PRM_NEED_SI) && (val.is_a?(Array)))
                if (val.any? {|sStr| sStr !~ /^(COS|OS|NOS|IOS|DOS)(\d)+$/})
                  sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, GRP_NEED_SI_AVAILABLE.join(" | "), val.join(", "))
                  aErrors.push(YamlError.new(sErr, @aPath))
                end
              end
              if ((sAtr == TSR_PRM_ERROR_HOOK_CFG) && (val.is_a?(Array)))
                if (@cConf.is_single?() && (@cConf.is_sc1?() || @cConf.is_sc2?()))
                  if (val.join() != TSR_STT_ONLY_SYSTEM)
                    sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, TSR_STT_ONLY_SYSTEM, val.join(", "))
                    aErrors.push(YamlError.new(sErr, @aPath))
                  end
                else
                  val.each{|sCfg|
                    if (!GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC.include?(sCfg))
                      sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC.join(" | "), sCfg)
                      aErrors.push(YamlError.new(sErr, @aPath))
                    end
                  }
                end
              end

            when TSR_PRM_OSAP, TSR_PRM_ACCOSAP
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
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre = false)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []
      # 変数のチェック
      if (!@hState[TSR_PRM_VAR].nil?())
        @hState[TSR_PRM_VAR].each{|sVarName, cVar|
          begin
            cVar.object_check(bIsPre)
          rescue AKTFMultiError
            aErrors.concat($!.aErrors)
          end
        }
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクト内のマクロを置換する
    #=================================================================
    def convert_macro()
      super()

      # 変数
      if (@hState[TSR_PRM_VAR].is_a?(Hash))
        @hState[TSR_PRM_VAR].each_value{|cVar|
          cVar.convert_macro()
        }
      end
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      # bootcnt
      if (!is_specified?(TSR_PRM_BOOTCNT))
        @hState[TSR_PRM_BOOTCNT] = 0
      end
      # need_si
      if (!is_specified?(TSR_PRM_NEED_SI))
        @hState[TSR_PRM_NEED_SI] = nil
      end
      # 変数
      if (!@hState[TSR_PRM_VAR].nil?())
        @hState[TSR_PRM_VAR].each_value{|cVar|
          cVar.complement_init_object_info()
        }
      end
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevObj)
      check_class(ProcessUnit, cPrevObj)  # 直前の状態のオブジェクト

      # 指定されていない場合補完
      cPrevObj.hState.each{|sAtr, val|
        sRealAtr = get_real_attribute_name(sAtr)
        if (!is_specified?(sRealAtr))
          # 変数の補完
          if (sRealAtr == TSR_PRM_VAR && val.is_a?(Hash))
            complement_variable(val)
          else
            @hState[sAtr] = safe_dup(val)
          end
        # 変数の省略された属性の補完
        elsif (sRealAtr == TSR_PRM_VAR && val.is_a?(Hash))
          complement_variable(val)
        end
      }
    end

    #=================================================================
    # 概  要: 変数の補完を実行する
    #=================================================================
    def complement_variable(hPrevVar)
      check_class(Hash, hPrevVar)  # 直前の状態の変数

      if (@hState[TSR_PRM_VAR].nil?())
        @hState[TSR_PRM_VAR] = {}
      end
      hPrevVar.each{|sVarName, cVar|
        # 変数の情報が省略されている場合は複製
        if (@hState[TSR_PRM_VAR][sVarName].nil?())
          @hState[TSR_PRM_VAR][sVarName] = cVar.dup()
          @hState[TSR_PRM_VAR][sVarName].aSpecifiedAttributes = []
        # 変数の情報がある場合は補完
        else
          @hState[TSR_PRM_VAR][sVarName].complement(cVar)
        end
      }
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      super(hAlias)

      # 変数
      if (!@hState[TSR_PRM_VAR].nil?())
        hTmp = @hState[TSR_PRM_VAR].dup()
        @hState[TSR_PRM_VAR] = {}
        hTmp.each{|sVarName, cVar|
          sTempVarName = sVarName.gsub(/\[\w*\]/, "")
          sAlias = hAlias[sTempVarName]
          cVar.alias(hAlias)
          @hState[TSR_PRM_VAR][sAlias] = cVar
        }
      end

      # 関連づけされたリソース
      if (!@hState[TSR_PRM_RELRES].nil?())
        @hState[TSR_PRM_RELRES].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_RELRES][nIndex] = alias_replace(sRes, hAlias)
        }
      end

      # 取得済みリソース
      if (!@hState[TSR_PRM_GETRES].nil?())
        @hState[TSR_PRM_GETRES].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_GETRES][nIndex] = alias_replace(sRes, hAlias)
        }
      end

      # 関連づけされたイベント
      if (!@hState[TSR_PRM_RELEVT].nil?())
        @hState[TSR_PRM_RELEVT].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_RELEVT][nIndex] = alias_replace(sRes, hAlias)
        }
      end

      # アプリケーションモード
      if (!@hState[TSR_PRM_APPMODE].nil?())
        @hState[TSR_PRM_APPMODE].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_APPMODE][nIndex] = alias_replace(sRes, hAlias)
        }
      end

      # 取得済みスピンロック
      if (!@hState[TSR_PRM_GETSPN].nil?())
        @hState[TSR_PRM_GETSPN].each_with_index{|sRes, nIndex|
          @hState[TSR_PRM_GETSPN][nIndex] = alias_replace(sRes, hAlias)
        }
      end
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
      # varの構造体のICRID用エイリアス変換情報
      if (@sObjectType == TSR_OBJ_ICISR)
        hResult["#{@sObjectID}_#{STR_ICISR_ID}"] = get_common_id()
      end

      # 変数名
      if (!@hState[TSR_PRM_VAR].nil?())
        @hState[TSR_PRM_VAR].each_key{|sVarName|
           if (bSingleTest == false)
            hResult[sVarName] = alias_str(sVarName, sTestID)
           else
             hResult[sVarName] = sVarName
           end
        }
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
          # 変数
          when TSR_PRM_VAR
            hYaml[TSR_PRM_VAR] = {}
            val.each{|sVarName, cVar|
              hYaml[TSR_PRM_VAR][sVarName] = cVar.to_yaml()
            }
          # 状態
          when TSR_PRM_STATE
            hYaml[sRealAtr] = @hState[TSR_PRM_STATE]
          # その他
          else
            hYaml[sRealAtr] = safe_dup(val)
          end
        end
      }

      return hYaml  # [Hash]YAMLオブジェクト
    end

    #=================================================================
    # 概  要: オブジェクト内に存在する変数名一覧を返す
    #=================================================================
    def get_variable_names()
      aResult = []
      if (!@hState[TSR_PRM_VAR].nil?())
        aResult = @hState[TSR_PRM_VAR].keys()
      end

      return aResult  # [Array]オブジェクト内に存在する変数名一覧
    end

    #=================================================================
    # 概  要: 内部保持用属性名からTESRYの属性名を取得する
    #=================================================================
    def get_real_attribute_name(sAtr)
      check_class(String, sAtr)  # 内部保持用属性名

      if (sAtr == TSR_PRM_STATE)
        sAtr = GRP_PRM_KEY_STAT[@sObjectType]
      end

      return sAtr  # [String]TESRYの属性名
    end

    #=================================================================
    # 概  要: YAML階層のパスを設定する
    #=================================================================
    def set_path(aPath)
      check_class(Array, aPath)  # ルートからのパス

      super(aPath)
      if (@hState[TSR_PRM_VAR].is_a?(Hash))
        @hState[TSR_PRM_VAR].each{|sVarName, cVar|
          cVar.aPath = aPath + [sVarName]
        }
      end
    end

    #=================================================================
    # 概  要: activateな処理単位かを返す
    #=================================================================
    def is_activate?()

        bResult = GRP_ACTIVATE.include?(@hState[TSR_PRM_STATE])

      return bResult  # [Bool]activateな処理単位か
    end

    #=================================================================
    # 概  要: relresが指定されているかを返す
    #=================================================================
    def has_relres?()
      return !(@hState[TSR_PRM_RELRES].nil?())  # [Bool]relresが指定されているか
    end

    #=================================================================
    # 概  要: getresが指定されているかを返す
    #=================================================================
    def has_getres?()
      return !(@hState[TSR_PRM_GETRES].nil?())  # [Bool]getresが指定されているか
    end

    #=================================================================
    # 概  要: getspnが指定されているかを返す
    #=================================================================
    def has_getspn?()
      return !(@hState[TSR_PRM_GETSPN].nil?())  # [Bool]getspnが指定されているか
    end

    #=================================================================
    # 概  要: スピンロック待ちの処理単位か
    #=================================================================
    def is_spinlock_waiting?()
      case @sObjectType
      when TSR_OBJ_TASK
        bResult = (@hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITSPIN)
      when TSR_OBJ_C2ISR, TSR_OBJ_ICISR
        bResult = (@hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITSPIN)
      else
        bResult = false
      end

      return bResult  # [Bool]スピンロック待ちの処理単位か
    end
  end
end
