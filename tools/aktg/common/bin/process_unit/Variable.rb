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
require "common/bin/CommonModule.rb"
require "aktf/bin/class/AKTFCommon.rb"
require "common/bin/IMCodeElement.rb"
require "aktf/bin/process_unit/Variable.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Variable
  # 概    要: variableの情報を処理するクラス
  #===================================================================
  class Variable
    include CommonModule
    include AKTFModule
    include AKTFModule::ObjectCommon

    attr_accessor :sVarName, :sType, :snValue, :hMember, :bGlobal, :aPath

    #=================================================================
    # 概  要: variableの初期化
    #=================================================================
    def initialize(sVarName, hVarInfo, aPath)
      check_class(Object, sVarName)      # 変数名(T2_003でチェックを行う)
      check_class(Hash, hVarInfo, true)  # 変数の内容
      check_class(Array, aPath)          # ルートからのパス

      @sVarName = sVarName    # 変数名
      @sType    = nil         # 型
      @snValue  = nil         # 値
      @hMember  = nil         # 構造体のメンバ
      @bGlobal  = nil         # グローバル変数
      @aPath    = aPath + [@sVarName]

      @cConf = Config.new()

      store_var_info(hVarInfo)
    end

    #=================================================================
    # 概  要: テストシナリオ通りvariableにデータを代入
    #=================================================================
    def store_var_info(hVarInfo)
      check_class(Hash, hVarInfo, true)  # 変数の内容

      set_specified_attribute(hVarInfo)
      if (hVarInfo.is_a?(Hash))
        # 構造体のメンバがあれば空ハッシュで初期化
        hVarInfo.each_key{|sKey|
          if ((sKey != TSR_PRM_VAR_TYPE) && (sKey != TSR_PRM_VAR_VALUE) && (sKey != TSR_PRM_VAR_GLOBAL))
            @hMember = {}
          end
        }

        hVarInfo.each{|atr, val|
          case atr
          when TSR_PRM_VAR_TYPE
            @sType = val
          when TSR_PRM_VAR_VALUE
            @snValue = val
          when TSR_PRM_VAR_GLOBAL
            @bGlobal = val
          else
            @hMember[atr] = val
          end
        }
      end
    end

    #=================================================================
    # 概  要: グローバル/ローカル変数宣言用コード生成
    #=================================================================
    def gc_global_local_var(cElement, sObjectID)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(String, sObjectID)       # オブジェクトID

      if (@bGlobal == false)
        # ローカル変数
        if (@hMember.nil?())
          # 変数の値が指定されている場合，キャスト
          if (!@snValue.nil?())
            @snValue = "(#{@sType})#{@snValue}"
          end
          cElement.set_local_var(sObjectID, @sVarName, @sType, @snValue)
        else
          # 構造体の場合(全メンバ変数初期化)
          sInitStr = make_initial_str()
          cElement.set_local_var(sObjectID, @sVarName, @sType, sInitStr)
        end
      else
        # グローバル変数
        if (@hMember.nil?())
          # 構造体でない場合
          cElement.set_global_var(@sVarName, @sType, @snValue)
        else
          # 構造体の場合(全メンバ変数初期化)
          sInitStr = make_initial_str()
          cElement.set_global_var(@sVarName, @sType, sInitStr)
        end
      end
    end

    #=================================================================
    # 概  要: 構造体初期化用文字列を返す
    #=================================================================
    def make_initial_str()
      # 定義されていない構造体の型の場合エラー
      if (!STR_INITIAL_INFO.has_key?(@sType))
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      sInitStr = "{"
      STR_INITIAL_INFO[@sType].each{|aStructInfo|

        # 初期値が指定されている場合
        if (@hMember.has_key?(aStructInfo[0]))
          sInitStr.concat(" #{@hMember[aStructInfo[0]]},")
        # 初期値が指定されていない場合
        else
          sInitStr.concat(" #{aStructInfo[2]},")
        end
      }
      sInitStr.chop!()
      sInitStr.concat(" }")

      return sInitStr # [String]構造体初期化用文字列
    end

    #=================================================================
    # 概  要: ローカル変数比較用コード生成
    #=================================================================
    def gc_assert_value(cElement, hProcUnitInfo)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報

      # 配列の場合はアサートしない
      if (@sVarName =~ /\w+\[\w+\]/)
      # 変数の値が設定されている場合
      elsif (@hMember.nil?() && !@snValue.nil?())
        @snValue = "(#{@sType})#{@snValue}"
        cElement.set_assert(hProcUnitInfo, @sVarName, @snValue)
      # 構造体が設定されている場合
      elsif (!@hMember.nil?())
        @hMember.each{|name, val|
          cElement.set_assert(hProcUnitInfo, "#{@sVarName}.#{name}", val)
        }
      end
    end

  end
end
