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
# $Id: Variable.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
  # クラス名: Variable
  # 概    要: variableの情報を処理するクラス
  #===================================================================
  class Variable
    include AKTFModule
    include AKTFModule::ObjectCommon

    #=================================================================
    # 概  要: 設定値のチェック
    #=================================================================
    def check_attribute_value()
      check_attribute_type(TSR_PRM_VAR_TYPE, @sType, String, false, @aPath)
      check_attribute_type(TSR_PRM_VAR_VALUE, @snValue, [String, Integer], true, @aPath)
      check_attribute_type(TSR_PRM_VAR_GLOBAL, @bGlobal, Bool, false, @aPath)
      if (!@hMember.nil?())
        @hMember.each_value{|val|
          check_attribute_type("member", val, [String, Integer], false, @aPath)
        }
      end
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check(bIsPre)
      check_class(Bool, bIsPre)  # pre_conditionか

      aErrors = []

      # pre_conditionの場合
      if (bIsPre == true)
        ### T3_VAR004: valueの値の先頭に「~」が付与されている
        if (@snValue.is_a?(String) && @snValue.index(TSR_NOT_SIGN) != nil)
          aErrors.push(YamlError.new("T3_VAR004: " + ERR_VAR_NOT_SIGN, @aPath))
        end
      end

      # 構造体の場合
      if (STR_INITIAL_INFO.has_key?(@sType))
        # メンバ名一覧作成
        aMemberNames = []
        STR_INITIAL_INFO[@sType].each{|aMember|
          aMemberNames.push(aMember[0])
        }
        # 宣言されているメンバが使用できるものか
        ### T3_VAR001: 変数が構造体の場合にその構造体のメンバ以外を使用している
        if (!@hMember.nil?())
          @hMember.each_key{|sMember|
            if (!aMemberNames.include?(sMember))
              sErr = sprintf("T3_VAR001: " + ERR_VAR_UNDEFINED_MEMBER, sMember, @sType)
              aErrors.push(YamlError.new(sErr, @aPath))
            end
          }
        end
        ### T3_VAR003: 変数が構造体の場合にvalue属性を定義している
        if (!@snValue.nil?())
          aErrors.push(YamlError.new("T3_VAR003: " + ERR_VAR_INVALID_DEFINE_VALUE, @aPath))
        end
      ### T3_VAR002: 変数がデータ型の場合にメンバを定義している
      elsif (!@hMember.nil?())
        aErrors.push(YamlError.new("T3_VAR002: " + ERR_VAR_INVALID_DEFINE_MEMBER, @aPath))
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 変数内のマクロを置換する
    #=================================================================
    def convert_macro()
      hMacro = @cConf.get_macro()
      # 値
      @snValue = calc_all_expr(@snValue, hMacro)
      # メンバ
      if (!@hMember.nil?())
        @hMember.each{|sAtr, val|
          @hMember[sAtr] = calc_all_expr(@hMember[sAtr], hMacro)
        }
      end
    end

    #=================================================================
    # 概  要: 初期値を補完する
    #=================================================================
    def complement_init_object_info()
      super()

      # global
      if (!is_specified?(TSR_PRM_VAR_GLOBAL))
        @bGlobal = false
      end

    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevVar)
      check_class(Variable, cPrevVar)  # 直前の状態の変数

      # タイプ
      if (@sType.nil?())
        @sType = safe_dup(cPrevVar.sType)
      end
      # 値
      if (!is_specified?(TSR_PRM_VAR_VALUE))
        @snValue = safe_dup(cPrevVar.snValue)
      end
      # グローバル変数
      if (@bGlobal.nil?())
        @bGlobal = safe_dup(cPrevVar.bGlobal)
      end
      # 構造体
      if (!cPrevVar.hMember.nil?() && !@hMember.nil?)
        cPrevVar.hMember.each{|sAtr, val|
          if (!is_specified?(sAtr))
            @hMember[sAtr] = safe_dup(val)
          end
        }
      end
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      # 変数名
      @sVarName = alias_replace(@sVarName, hAlias)
      # 値
      if (@snValue.is_a?(String))
        @snValue = alias_replace(@snValue, hAlias)
      end
      # メンバ
      if (!@hMember.nil?())
        @hMember.each{|sAtr, val|
          # stk_isridがある場合，構造体用に用意したエイリアス情報を使用する
          if ((sAtr == STR_ICISR_ID) && (hAlias.has_key?("#{val}_#{STR_ICISR_ID}")))
            @hMember[sAtr] = hAlias["#{val}_#{STR_ICISR_ID}"]
          else
            @hMember[sAtr] = alias_replace(val, hAlias)
          end
        }
      end
    end

    #=================================================================
    # 概  要: オブジェクトを複製して返す
    #=================================================================
    def dup()
      cVar = super()

      # 変数名複製
      cVar.sVarName = safe_dup(@sVarName)
      # タイプ複製
      cVar.sType = safe_dup(@sType)
      # 値複製
      cVar.snValue = safe_dup(@snValue)
      # グローバル変数複製
      cVar.bGlobal = safe_dup(@bGlobal)
      # 構造体複製
      if (!@hMember.nil?())
        hNewMember = {}
        @hMember.each{|atr, val|
          hNewMember[atr] = safe_dup(val)
        }
        cVar.hMember = hNewMember
      end

      return cVar  # [Object]複製したオブジェクト
    end

    #=================================================================
    # 概  要: オブジェクトの内容をyamlオブジェクトにして出力
    #=================================================================
    def to_yaml()
      hYaml = {}

      # インスタンス変数
      if (!@sVarName.nil?())
        hYaml["@sVarName"] = @sVarName
      end
      # type
      hYaml[TSR_PRM_VAR_TYPE] = @sType
      # value
      if (!@snValue.nil?() || is_specified?(TSR_PRM_VAR_VALUE))
        hYaml[TSR_PRM_VAR_VALUE] = @snValue
      end
      # global
      hYaml[TSR_PRM_VAR_GLOBAL] = @bGlobal
      # 構造体のメンバ
      if (!@hMember.nil?())
        @hMember.each{|atr, val|
          hYaml[atr] = val
        }
      end

      return hYaml  # [Hash]YAMLオブジェクト
    end
  end
end
