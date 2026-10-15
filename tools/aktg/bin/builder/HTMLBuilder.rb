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
# $Id: HTMLBuilder.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "bin/builder/CodeBuilder.rb"
require "bin/product/HTMLCode.rb"

#マルチコア色分けカラーリスト
DEEP_COLOR_LIST = ["#FFFFFF", "lightcoral", "steelblue", "aquamarine", "#FFFFD7"]
PALE_COLOR_LIST = ["#FFFFFF", "#FFE3E3", "#E3EEFF", "#E3FFE3", "#FFFFD7"]
# 出力関数と同期をとる場合は以下をアンコメント
# STDOUT.sync = true
module AKTG

  #==================================================================
  # クラス名: HTMLBuilder
  # 概    要: 中間コードを利用してHTMLファイルを生成するクラス
  #==================================================================
  class HTMLBuilder < CodeBuilder
    include CommonModule

    #================================================================
    # 概  要: コンストラクタ
    #================================================================
    def initialize()
      @sHTMLCode  = ""   # HTML出力する文字列を一時的に保持する
      @@cHTMLCode = nil  # HTMLコードを保持する
      @nRowSpan   = 0    # コンディション内の行数を保持する
      @aProcUnits = []   # 登場する処理単位を保持する
      @sTestID    = ""   # テストシナリオID
      @cConf      = Config.new() # コンフィグを取得
    end


    #================================================================
    # 概  要: 中間コードからHTMLファイルを生成して出力する
    #================================================================
    def build(cIntermediateCode)
      check_class(IntermediateCode, cIntermediateCode) # 中間コードのインスタンス
      cnt = 0

      # ヘッダーの追加
      add_header()

      @bSingleTest = false
      if (cIntermediateCode.aCode.size == 2)
        @bSingleTest = true
      end

      cIntermediateCode.aCode.each{ |hScenarioes|
        hScenarioes.each{ |sScenarioID, aScenario|
          if (sScenarioID == IMC_COMMON)
            next
          end

          @sTestID    = sScenarioID
          @aProcUnits = []
          @aScenario  = aScenario # 高速化のため

          sScenarioIDLow = sScenarioID.downcase
          sIsrFuncLow = AKTG_LBL_ISR_FUNC.downcase

          # 登場する処理単位を抜き出す
          cIntermediateCode.hProcUnitInfo.each_key{ |sProcUnit|
            if ((sProcUnit == AKTG_MAIN_TASK) || (sProcUnit == AKTG_DUMMY_TASK) || (sProcUnit == FNC_CHECK_MAIN) || (sProcUnit == FNC_MAIN))
              next
            end
            sProcUnitLow   = sProcUnit.downcase
            if (/\A#{sScenarioIDLow}/ =~ sProcUnitLow)
              @aProcUnits.push(sProcUnit.sub(@sTestID+"_", ""))
            elsif (/\A#{sIsrFuncLow}[a-z\_]+#{sScenarioIDLow}/ =~ sProcUnitLow)
              aProcUnit = sProcUnit.split("_")
              @aProcUnits.push(aProcUnit[AKTG_IDX_LAST])
            elsif (@bSingleTest == true)
              @aProcUnits.push(sProcUnit)
            end
          }
          @aScenario.each{|hCondition|
            hCondition.each_value{|aCodeInfo|
              aCodeInfo.each{|hBlockInfo|
                hBlockInfo.each_value{|aInfo|
                  aInfo.each{|aId|
                    if (aId[0] =~ /\A\w+(Hook)$/)
                      @aProcUnits.push(aId[0])
                    end
                  }
                }
              }
            }
          }
          @aProcUnits.sort!.uniq!

          # テストシナリオごとに表を追加
          @sHTMLCode.concat(%Q[<font size = "6">#{@sTestID}</font><br>#{AKTG_NL}])
          @sHTMLCode.concat("<table border=1>#{AKTG_NL}")
          make_body()
          @sHTMLCode.concat("</table>#{AKTG_NL}")
          @sHTMLCode.concat("<br>#{AKTG_NL}")
        }
      }

      # フッターを追加
      add_footer()

      # HTMLコードを生成
      @@cHTMLCode = HTMLCode.new(@sHTMLCode)
    end


    #================================================================
    # 概  要: ヘッダ部のコードを追加する
    #================================================================
    def add_header()
      sHeader = <<-EOS
<html>
<head>
</head>
<body>
      EOS
      @sHTMLCode.concat(sHeader)

      # カラーの凡例を追加
      if (@cConf.is_multi?())
        1.upto(@cConf.get_core_num()){ |coreid|
          @sHTMLCode.concat(%Q[　<font style="font-size:24px; background-color:#{PALE_COLOR_LIST[coreid]}">コア#{coreid}</font>#{AKTG_NL}])
        }
        @sHTMLCode.concat("<br><br>#{AKTG_NL}")
      end
    end


    #================================================================
    # 概  要: フッタ部のコードを追加する
    #================================================================
    def add_footer()
      sFooter = <<-EOS
</body>
</html>
      EOS

      @sHTMLCode.concat(sFooter)
    end


    #================================================================
    # 概  要: 中間コードからHTMLコードの本体部分を生成する
    #================================================================
    def make_body()

      @aScenario.each{ |hCondition|
        hCondition.each{ |sCondition, aBlocks|
          if (aBlocks.empty?())
            # 空のConditionSyncを飛ばす
            next
          end

          # コンディションごとに処理単位行を付与
          add_processing_units(sCondition)

          aBlocks.each{ |hBlocks|
            hBlocks.each{ |sBlock, aCodeInfo|
              @aCodeInfo = aCodeInfo # 高速化のため
              # ブロックごとに出力
              add_lines()
            }
          @sHTMLCode.concat("#{AKTG_NL}")
          }

          # 最左行の結合行数を設定
          replace_rowspan(sCondition)
        }
      }
    end


    #================================================================
    # 概  要: 処理単位行を追加する
    #================================================================
    def add_processing_units(sConditionID)
      check_class(String, sConditionID) # コンディションID

      @sHTMLCode.concat(%Q[<tr><th rowspan = "SPAN:#{sConditionID}">#{sConditionID}</th>])

      @aProcUnits.each{ |sProcUnit|
        @sHTMLCode.concat("#{AKTG_NL}")
        @sHTMLCode.concat(%Q[<th bgcolor = "gainsboro">#{sProcUnit}</th>])
      }

      @sHTMLCode.concat("</tr>#{AKTG_NL}")
    end


    #================================================================
    # 概  要: rowspan属性の置き換え
    #================================================================
    def replace_rowspan(sConditionID)
      @sHTMLCode = @sHTMLCode.sub("SPAN:#{sConditionID}", "#{@nRowSpan+1}")
      @nRowSpan = 0
    end


    #================================================================
    # 概  要: 与えられたコード情報を追加する
    #================================================================
    def add_lines()
      @aCodeInfo.each{|sObjID, sCode, nBootCnt, nCoreid, lAtr|
        nColumn = @aProcUnits.index(sObjID.sub(@sTestID+"_", "")) # 列数
        if (nColumn.nil?())
          aObjID = sObjID.split("_")
          nColumn = @aProcUnits.index(aObjID[AKTG_IDX_LAST]) # 列数
        end

        if (@cConf.is_multi?())
          sColor  = PALE_COLOR_LIST[nCoreid]                       # カラーの設定
        else
          sColor  = PALE_COLOR_LIST[1]
        end

        sCode   = sCode.sub(@sTestID+"_", "")                     # 出力コード

        if (is_hidden?(lAtr) || sCode.index(AKTG_LBL_ISR_FUNC))
          next
        end

        # 行数カウンターのインクリメント
        @nRowSpan += 1

        @sHTMLCode.concat("#{AKTG_TB}")
        @sHTMLCode.concat("<tr>")

        nColumnSize = @aProcUnits.size()
        nColumnSize.times{ |index|
          if (index == nColumn)
            @sHTMLCode.concat(%Q[<td bgcolor = "#{sColor}"> #{sCode} </td>])
          else
            @sHTMLCode.concat("<td>　</td>")
          end
        }

        @sHTMLCode.concat("</tr>#{AKTG_NL}")
      }
    end


    #=================================================================
    # 概  要: 属性を見て，隠すコードかどうかを判断する
    #=================================================================
    def is_hidden?(lAtr)
      check_class(Symbol, lAtr) # 属性

      return false  # [Bool]出力しないかどうか
    end

    #=================================================================
    # 概  要: 生成されたコードをファイル化する
    #=================================================================
    def output_code_file(cHTMLCode, sFileName)
      check_class(HTMLCode, cHTMLCode) # HTMLCodeのインスタンス
      check_class(String, sFileName)   # 出力時のファイル名

      cHTMLCode.output_code_file(sFileName)
    end

    #=================================================================
    # 概  要: 生成したコードクラスを返す
    #=================================================================
    def get_result()
      return @@cHTMLCode  # [HTMLCode]生成したコードクラス
    end

  end
end
