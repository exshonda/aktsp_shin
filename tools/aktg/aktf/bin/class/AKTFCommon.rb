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
# $Id: AKTFCommon.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "kconv.rb"
require "yaml.rb"
require "common/bin/CommonModule.rb"
require "aktf/bin/class/AKTFError.rb"
require "aktf/bin/class/ObjectCommon.rb"
require "common/kwalify.rb"
require "common/bin/Config.rb"

#=====================================================================
# AKTFModule
#=====================================================================
module AKTFModule
  include CommonModule

  #===================================================================
  # 概  要: YAMLファイルをロードする
  #===================================================================
  def load_yaml_file(sFileName)
    check_class(String, sFileName)  # ファイル名

    cConf = Config.new()
    begin
      if (cConf.is_yaml_library?())
        yaml = YAML.load(File.read(sFileName).toutf8)
      else
        yaml = Kwalify::Yaml.load_file(sFileName)
      end
    rescue SystemCallError
      raise(AKTFError.new(sprintf(ERR_CANNOT_OPEN_FILE, sFileName) + "#{AKTG_NL}(#{$!.message()})"))
    rescue ArgumentError
      raise(AKTFError.new(sprintf(ERR_YAML_SYNTAX_INVALID, sFileName) + "#{AKTG_NL}(#{$!.message()})"))
    rescue Kwalify::SyntaxError
      raise(AKTFError.new(sprintf(ERR_YAML_SYNTAX_INVALID, sFileName) + "#{AKTG_NL}(#{$!.message()})"))
    end

    return yaml  # [Object]YAMLオブジェクト
  end
  protected :load_yaml_file

  #===================================================================
  # 概  要: 値を演算する
  #===================================================================
  def parse_value(val, hMacro = {})
    check_class(Object, val, true) # 値
    check_class(Hash, hMacro)      # マクロ

    # 文字列の場合は様々なケースに対応
    if (val.is_a?(String))
      result = val.dup()

      # 否定記号"~"を取り除いておく
      bNotFlg = false
      if (result.index(TSR_NOT_SIGN) == 0)
        result.gsub!(TSR_NOT_SIGN, "")
        bNotFlg = true
      end

      # ユーザ定義マクロを置換
      if (!hMacro.empty?())
        aMatches = val.scan(/\w+/)
        aMatches.each{|sMacro|
          if (hMacro.has_key?(sMacro))
            result = result.gsub(/(^|\W)#{sMacro}(?=$|\W)/, "\\1#{hMacro[sMacro]}")
          end
        }
      end

      # 数値（16進数も）と一部の記号と空白のみで構成された文字列
      if (result =~ /^(\d+|0x[a-fA-F\d]+|[\s\+\-\*\%\/\|\&\(\)])+$/)
        begin
          result = eval(result)
        rescue SyntaxError
          sErr = sprintf(ERR_EXPRESSION_INVALID, result)
          raise(AKTFError.new(sErr))
        end
      end

      # 取り除いた否定記号を付与
      if (bNotFlg == true)
        result = TSR_NOT_SIGN + result.to_s()
      end

    # 文字列以外の場合はそのまま
    else
      result = safe_dup(val)
    end

    return result  # [Object]演算結果
  end

  #===================================================================
  # 概  要: マクロ置換・計算式の演算を行う
  #===================================================================
  def calc_all_expr(data, hMacro)
    check_class(Object, data, true) # 値
    check_class(Hash, hMacro)       # マクロ

    if (data.is_a?(Hash))
      hTmp = data
      data = {}
      hTmp.each{|atr, val|
        atr       = parse_value(atr, hMacro)
        val       = calc_all_expr(val, hMacro)
        data[atr] = val
      }
    elsif (data.is_a?(Array))
      data = data.dup()
      data.each_with_index{|val, index|
        data[index] = calc_all_expr(val, hMacro)
      }
    elsif (data.is_a?(String))
      data = parse_value(data, hMacro)
    end

    return data  # [Object]マクロ置換・計算式の演算の結果
  end

  #===================================================================
  # 概  要: 文字列を検索し，テストIDを付与できるもの全てをエイリアス
  #       : 文字列以外の場合はそのまま返す
  #===================================================================
  def alias_replace(sStr, hAlias)
    check_class(Object, sStr)  # 対象文字列
    check_class(Hash, hAlias)  # エイリアス変換テーブル

    if (sStr.is_a?(String))
      sResult = sStr.dup()
      aMatches = sResult.scan(/[\w\/-]+/)
      aMatches.each{|sMatch|
        # 置き換え対象IDに含まれる場合はエイリアス
        if (hAlias.has_key?(sMatch))
          sAlias  = hAlias[sMatch]
          sResult = sResult.gsub(/(^|\W)#{sMatch}(?=$|\W)/, "\\1#{sAlias}")
        end
      }
      return sResult  # [Object]テストIDが付与された文字列
    else
      return safe_dup(sStr)  # 元のオブジェクト
    end
  end

  #===================================================================
  # 概  要: 文字列にテストIDを付与して返す
  #===================================================================
  def alias_str(sStr, sTestID)
    check_class(String, sStr)     # 対象文字列
    check_class(String, sTestID)  # テストID

    return "#{sTestID}_#{sStr}"  # [String]テストIDが付与された文字列
  end

  #===================================================================
  # 概  要: エラーがあるかチェックし，ある場合は例外を投げる
  #===================================================================
  def check_error(aErrors)
    check_class(Array, aErrors)  # エラー格納配列

    # エラーがあった場合
    if (!aErrors.empty?())
      raise(AKTFMultiError.new(aErrors))
    end
  end

  #===================================================================
  # 概  要: 属性が定義されているものかチェック
  #===================================================================
  def check_defined_attribute(aAtrs, aAtrList, aPath)
    check_class(Array, aAtrs)     # 記述された属性
    check_class(Array, aAtrList)  # 定義できる属性
    check_class(Array, aPath)     # ルートからのパス

    aErrors = []
    ### T1_021: オブジェクトで定義可能な属性以外が指定されている
    aAtrs.each{|sAtr|
      if (!aAtrList.include?(sAtr))
        sErr = sprintf("T1_021: " + ERR_UNDEFINED_KEY, sAtr)
        aErrors.push(YamlError.new(sErr, aPath))
      end
    }

    check_error(aErrors)
  end

  #===================================================================
  # 概  要: 属性のクラスタイプチェック
  #===================================================================
  def check_attribute_type(sAtr, val, acClass, bAllowNil, aPath)
    check_class(String, sAtr)             # 属性名
    check_class(Object, val, true)        # チェックする値
    check_class([Class, Array], acClass)  # 正しいクラス
    check_class(Bool, bAllowNil)          # nilを許可するか
    check_class(Array, aPath)             # ルートからのパス

    bMatch = false
    # 指定されたクラスかチェック
    if (!acClass.is_a?(Array))
      acClass = [acClass]
    end
    # nil許可
    if (bAllowNil == true)
      acClass.push(NilClass)
    end
    acClass.each{|cClass|
      if (val.is_a?(cClass))
        bMatch = true
        break
      end
    }

    ### T2_001: パラメータの型が想定されている型と異なる
    if (bMatch == false)
      sErr = sprintf("T2_001: " + ERR_INVALID_TYPE, sAtr, acClass.join(" or "), val.class())
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が0以上の整数かチェック
  #===================================================================
  def check_attribute_unsigned(sAtr, val, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (val < 0)
      sErr = sprintf("T2_002: " + ERR_BE_INTEGER_GE, sAtr, 0, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が指定した数値より大きい整数かチェック
  #===================================================================
  def check_attribute_gt(sAtr, val, nComp, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Integer, nComp)     # 比較する数値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (val <= nComp)
      sErr = sprintf("T2_002: " + ERR_BE_INTEGER_GT, sAtr, nComp, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が指定した数値以下の整数かチェック
  #===================================================================
  def check_attribute_le(sAtr, val, nComp, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Integer, nComp)     # 比較する数値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (val > nComp)
      sErr = sprintf("T2_002: " + ERR_BE_INTEGER_LE, sAtr, nComp, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が指定した数値より小さい整数かチェック
  #===================================================================
  def check_attribute_lt(sAtr, val, nComp, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Integer, nComp)     # 比較する数値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (val >= nComp)
      sErr = sprintf("T2_002: " + ERR_BE_INTEGER_LT, sAtr, nComp, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が範囲内の整数かチェック
  #===================================================================
  def check_attribute_range(sAtr, val, nMin, nMax, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Integer, nMin)      # 最小値
    check_class(Integer, nMax)      # 最大値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (!(val >= nMin && val <= nMax))
      sErr = sprintf("T2_002: " + ERR_BE_INTEGER_RANGE, sAtr, nMin, nMax, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が0かチェック
  #===================================================================
  def check_attribute_only0(sAtr, val, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Integer, val, true) # チェックする値
    check_class(Array, aPath)       # ルートからのパス

    # 比較
    if (val != 0)
      sErr = sprintf("T2_002: " + ERR_BE_ONLY0, sAtr, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が予期された値かチェック
  #===================================================================
  def check_attribute_enum(sAtr, val, aEnum, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Object, val, true)  # チェックする値(T2_002でチェックを行う)
    check_class(Array, aEnum)       # 予期された値
    check_class(Array, aPath)       # ルートからのパス

    if (!aEnum.include?(val))
      sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, aEnum.join(" | "), val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 属性の値が予期された値，またはその組み合わせかチェック
  #===================================================================
  def check_attribute_multi(sAtr, val, aEnum, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(String, val, true)  # チェックする値
    check_class(Array, aEnum)       # 予期された値
    check_class(Array, aPath)       # ルートからのパス

    val = val.gsub(/\s+/, "")
    val = val.gsub(/^\((.*)\)$/, "\\1")
    aMacro = val.split("|")
    aMacro.each{|sMacro|
      begin
        check_attribute_enum(sAtr, sMacro, aEnum, aPath)
      rescue YamlError
        sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, aEnum.join(" | "), val)
        raise(YamlError.new(sErr, aPath + [sAtr]))
      end
    }
  end

  #===================================================================
  # 概  要: 属性の値が変数名かチェック
  #===================================================================
  def check_attribute_variable(sAtr, val, aPath)
    check_class(String, sAtr)       # 属性名
    check_class(Object, val, true)  # チェックする値(T2_003でチェックを行う)
    check_class(Array, aPath)       # ルートからのパス

    ### T2_003: 変数名が命名規則に反している
    if (!(val =~ TSR_REX_VARIABLE) || !(val.is_a?(String)))
      sErr = sprintf("T2_003: " + ERR_INVALID_VAR_NAME, val)
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end

  #===================================================================
  # 概  要: 満了点情報のチェック
  #===================================================================
  def check_attribute_expoint(sAtr, cExpoint, aPath)
    check_class(String, sAtr)          # 属性名
    check_class(ExpiryPoint, cExpoint) # 属性名
    check_class(Array, aPath)          # ルートからのパス

    # offsetの範囲チェック
    if (@hState[TSR_PRM_DURATION].is_a?(Integer))
      check_attribute_range("offset", cExpoint.nOffset, 0, @hState[TSR_PRM_DURATION], @aPath + [sAtr])
    end

  end

  #===================================================================
  # 概  要: doの属性チェック
  #===================================================================
  def check_do_attribute(hDo, aSpecified, aPath)
    check_class(Hash, hDo)          # チェックする値
    check_class(Array, aSpecified)  # 指定された属性
    check_class(Array, aPath)       # ルートからのパス

    aErrors = []
    ### T2: doの属性指定チェック
    GRP_DEF_DO.each{|sAtr, aClass|
      if (aSpecified.include?(sAtr))
        cClass = hDo[sAtr].class()
        if (hDo[sAtr].is_a?(Integer))  # 1.9: Fixnum/Bignum, 2.4+: Integer
          cClass = Integer
        end
        ### T2_001: パラメータの型が想定されている型と異なる
        if (!aClass.include?(cClass))
          sErr = sprintf("T2_001: " + ERR_INVALID_TYPE, sAtr, aClass.join(" or "), cClass)
          aErrors.push(YamlError.new(sErr, aPath + [sAtr]))
        end
        # repeatの値チェック
        if (sAtr == TSR_PRM_REPEAT && hDo[sAtr].is_a?(Integer))
          check_attribute_gt(sAtr, hDo[sAtr], 0, aPath)
        end
        # rettypeが規定された文字列かチェック
        if (sAtr == TSR_PRM_RETTYPE && hDo[sAtr].is_a?(String))
          check_attribute_enum(sAtr, hDo[sAtr], GRP_DO_AVAILABLE[sAtr], aPath)
        end
        # need_siが規定された文字列かチェック
        if (sAtr == TSR_PRM_NEED_SI && hDo[sAtr].is_a?(Array))
          if (hDo[sAtr].any? {|sStr| sStr !~ /^(COS|OS|NOS|IOS|DOS)(\d)+$/})
            sErr = sprintf("T2_002: " + ERR_BE_INCLUDE, sAtr, GRP_NEED_SI_AVAILABLE.join(" | "), hDo[sAtr].join(", "))
            aErrors.push(YamlError.new(sErr, aPath))
          end
        end
        # retvalの値チェック
        if (sAtr == TSR_PRM_RETVAL && hDo[sAtr].is_a?(Integer))
          check_attribute_unsigned(sAtr, hDo[sAtr], aPath)
        end
      end
    }

    check_error(aErrors)
  end

  #=================================================================
  # 概  要: SC3で定義可能なオブジェクトの属性一覧を作成
  #=================================================================
  def get_define_object_sc3()
    hAtrList = GRP_DEF_OBJECT_SINGLE

    # SC3では，アラームコールバックは使用できないため削除
    hAtrList.delete(TSR_OBJ_ALARM_CALL_BACK)

    # SC1からSC3で指定可能となる属性の差分を追加
    GRP_DEF_OBJECT_ADD_SC3.each{|sObject, hAtr|
      if (hAtrList.include?(sObject))
        hAtrList[sObject].update(hAtr)
      else
        hAtrList[sObject] = hAtr
      end
    }

    return hAtrList # [Hash]SC3で定義可能なオブジェクトの属性一覧
  end

  #=================================================================
  # 概  要: SC1-MCで定義可能なオブジェクトの属性一覧を作成
  #=================================================================
  def get_define_object_sc1_mc()
    hAtrList = GRP_DEF_OBJECT_SINGLE

    # SC1からSC1-MCで指定可能となる属性の差分を追加
    GRP_DEF_OBJECT_ADD_SC1_MC.each{|sObject, hAtr|
      if (hAtrList.include?(sObject))
        hAtrList[sObject].update(hAtr)
      else
        hAtrList[sObject] = hAtr
      end
    }

    return hAtrList # [Hash]SC1-MCで定義可能なオブジェクトの属性一覧
  end

  #=================================================================
  # 概  要: SC3-MCで定義可能なオブジェクトの属性一覧を作成
  #=================================================================
  def get_define_object_sc3_mc()
    hAtrList = get_define_object_sc3()

    # SC3からSC3-MCで指定可能となる属性の差分を追加
    GRP_DEF_OBJECT_ADD_SC3_MC.each{|sObject, hAtr|
      if (hAtrList.include?(sObject))
        hAtrList[sObject].update(hAtr)
      else
        hAtrList[sObject] = hAtr
      end
    }

    return hAtrList # [Hash]SC3-MCで定義可能なオブジェクトの属性一覧
  end

  #===================================================================
  # 概  要: propertyのクラスタイプチェック
  #===================================================================
  def check_property_type(sAtr, val, acClass, bAllowNil, aPath)
    check_class(String, sAtr)                     # 項目名
    check_class(Object, val, true)                # チェックする値
    check_class([Class, Array, String], acClass)  # 正しいクラス
    check_class(Bool, bAllowNil)                  # nilを許可するか
    check_class(Array, aPath)                     # ルートからのパス

    bMatch = false
    # 指定されたクラスかチェック
    if (!acClass.is_a?(Array))
      acClass = [acClass]
    end
    # nil許可
    if (bAllowNil == true)
      acClass.push(NilClass)
    end
    acClass.each{|cClass|
      if (val.is_a?(cClass))
        bMatch = true
        break
      end
    }

    ### T6_004: 設定値の型が規定する型と異なる
    if (bMatch == false)
      sErr = sprintf("T6_004: " + ERR_PROPERTY_INVALID_TYPE, sAtr, acClass.join(" or "), val.class())
      raise(YamlError.new(sErr, aPath + [sAtr]))
    end
  end
end
