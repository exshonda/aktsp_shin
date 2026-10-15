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
# $Id: MultipleChecker.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/Config.rb"
require "common/bin/test_scenario/TestScenario.rb"
require "aktf/bin/class/AKTFCommon.rb"

#=====================================================================
# AKTFModule
#=====================================================================
module AKTFModule
  #===================================================================
  # クラス名: MultipleChecker
  # 概    要: シナリオ間のエラーチェック
  #===================================================================
  class MultipleChecker
    include CommonModule
    include AKTFModule

    #=================================================================
    # 概  要: コンストラクタ
    #=================================================================
    def initialize()
      @cConf = Config.new()
      # テストID重複チェック
      @hMultipleTestID = Hash.new{|hash, key|
        hash[key] = []
      }
      # 各種統一パラメータ
      @hUnifiedAtrs = {
        :hC1isr       => {},
        :hC2isr       => {},
        :hC1isrOsap   => {},
        :hC2isrOsap   => {},
        :hRestartTask => {}
      }
    end

    #=================================================================
    # 概  要: エラーチェック用のデータを格納する
    #=================================================================
    def store(cTS, sFileName)
      check_class(TestScenario, cTS)  # テストシナリオ
      check_class(String, sFileName)  # ファイル名

      # テストID重複チェック用
      @hMultipleTestID[cTS.sTestID].push(sFileName)
      # 割込み番号毎にチェックするデータ(優先度，属性)をまとめる
      @hUnifiedAtrs[:hC1isr][sFileName]     = cTS.get_c1isr_attributes_by_intno()
      @hUnifiedAtrs[:hC2isr][sFileName]     = cTS.get_c2isr_attributes_by_intno()
      if (@cConf.enable_osap?())
        # 割込み番号毎に所属するOSAPをまとめる
        @hUnifiedAtrs[:hC1isrOsap][sFileName]   = cTS.get_c1isr_osap_attributes_by_intno()
        @hUnifiedAtrs[:hC2isrOsap][sFileName]   = cTS.get_c2isr_osap_attributes_by_intno()
      end
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        # OSAP毎にチェックするデータをまとめる
        @hUnifiedAtrs[:hRestartTask][sFileName] = cTS.get_restarttask_attributes_by_osap()
      end
    end

    #=================================================================
    # 概  要: シナリオ間エラーチェックを実行する
    #=================================================================
    def multiple_check()
      aErrors = []

      # 同じテストIDを複数のYAMLが使用している場合
      @hMultipleTestID.each{|sTestID, aFileNames|
        ### T7_001: テストIDが重複している
        if (aFileNames.size() > 1)
          sErr = sprintf("T7_001: " + ERR_TESTID_MULTIPLE, sTestID)
          aFileNames.each{|sFileName|
            sErr.concat("\n * #{sFileName}")
          }
          aErrors.push(AKTFError.new(sErr))
        end
      }

      # 割り込み番号の衝突をチェック
      hCheck = Hash.new{|hash, key|
        hash[key] = Hash.new{|hash2, key2|
          hash2[key2] = []
        }
      }

      hCheckC1isr     = hCheck.dup
      hCheckC2isr     = hCheck.dup
      hCheckC1isrOsap = hCheck.dup
      hCheckC2isrOsap = hCheck.dup
      hCheckReTask    = hCheck.dup
      aCheckIsr     = []
      aCheckIsrOsap = []

      [:hC1isr, :hC2isr, :hC1isrOsap, :hC2isrOsap, :hRestartTask].each{|lKey|
        @hUnifiedAtrs[lKey].each{|sTestID, hData|
          hData.each_key{|hGroupKeyAtrs|
            if (lKey == :hRestartTask)
              # OSAPごとにテストIDをまとめる
              hCheck[hGroupKeyAtrs[TSR_PRM_OSAP]][lKey].push(sTestID)
            else
              # 割込み番号ごとにテストIDをまとめる
              hCheck[hGroupKeyAtrs[TSR_PRM_INTNO]][lKey].push(sTestID)
            end
          }
          hData.each{|hGroupKeyAtrs,aAtrs|
            aAtrs.each{|hAtrs|
              if (lKey == :hC1isr)
                hCheckC1isr[hGroupKeyAtrs][hAtrs].push(sTestID)
              elsif (lKey == :hC2isr)
                hCheckC2isr[hGroupKeyAtrs][hAtrs].push(sTestID)
              elsif (lKey == :hC1isrOsap)
                hCheckC1isrOsap[hGroupKeyAtrs][hAtrs].push(sTestID)
              elsif (lKey == :hC2isrOsap)
                hCheckC2isrOsap[hGroupKeyAtrs][hAtrs].push(sTestID)
              elsif (lKey == :hRestartTask)
                hCheckReTask[hGroupKeyAtrs][hAtrs].push(sTestID)
              end
            }
          }
        }
      }
      # チェック用にC1ISRとC2ISRのデータをまとめる
      aCheckIsr.push(hCheckC1isr)
      aCheckIsr.push(hCheckC2isr)
      aCheckIsrOsap.push(hCheckC1isrOsap)
      aCheckIsrOsap.push(hCheckC2isrOsap)

      # チェック
      # (ハッシュキーが:hC1isr，:hC2isrとなっているが中身は配列)
      hCheck.each{|snIntNo, hGroup|
        ### T7_002: 同一割込み番号に対して，C1ISRとC2ISRが定義されている
        if (hGroup[:hC1isr].size() > 0 && hGroup[:hC2isr].size() > 0)
          sErr = sprintf("T7_002: " + ERR_CONFLICT_INTNO, snIntNo) + "\n"
          sErr.concat(" #{TSR_OBJ_C1ISR}\n")
          hGroup[:hC1isr].sort().each{|sFileName|
            sErr.concat(" * #{sFileName}\n")
          }
          sErr.concat(" #{TSR_OBJ_C2ISR}\n")
          hGroup[:hC2isr].sort().each{|sFileName|
            sErr.concat(" * #{sFileName}\n")
          }
          aErrors.push(AKTFError.new(sErr))
        end
      }

      # 全テストケースで統一された属性が必要なオブジェクトのチェック
      ### T7_003: 同一割込み番号に対するISRにおいて，intatr，iniintpriが異なる
      aCheckIsr.each{|hCheckIsr|
        hCheckIsr.each{|hGroupKeyAtrs, hAtrGroups|
          if (hAtrGroups.size() > 1)
            nNum = 1
            # グループ
            aTmp = []
            hGroupKeyAtrs.each{|atr, val|
              aTmp.push("#{atr} = #{val}")
            }
            sErr = sprintf("T7_003: " + ERR_UNIFIED_ATR_ISR)
            sErr.concat("\ntarget: " + aTmp.join(", ") + "\n")
            # 組み合わせごとにテストID一覧出力
            hAtrGroups.each{|hAtrs, aTestID|
              # パラメータの組み合わせ
              sErr.concat("-" * 30 + "\n")
              sErr.concat("case#{nNum}: ")
              nNum += 1
              aTmp = []
              hAtrs.each{|atr, val|
                if (!val.nil?())
                  aTmp.push("#{atr} = #{val}")
                end
              }
              sErr.concat(aTmp.join(", ") + "\n")
             # テストID
             aTestID.each{|sTestID|
               sErr.concat(" * #{sTestID}\n")
             }
           }
           aErrors.push(AKTFError.new(sErr))
          end
        }
      }

      ### T7_OSAP_001: 同一割込み番号に対するISRにおいて，異なるOSAPに所属している
      if (@cConf.enable_osap?())
        aCheckIsrOsap.each{|hCheckIsr|
          hCheckIsr.each{|hGroupKeyAtrs, hAtrGroups|
            if (hAtrGroups.size() > 1)
              nNum = 1
              # グループ
              aTmp = []
              hGroupKeyAtrs.each{|atr, val|
                aTmp.push("#{atr} = #{val}")
              }
              sErr = sprintf("T7_OSAP_001: " + ERR_UNIFIED_OSAP_ISR)
              sErr.concat("\ntarget: " + aTmp.join(", ") + "\n")
              # 組み合わせごとにテストID一覧出力
              hAtrGroups.each{|hAtrs, aTestID|
                # パラメータの組み合わせ
                sErr.concat("-" * 30 + "\n")
                sErr.concat("case#{nNum}: ")
                nNum += 1
                aTmp = []
                hAtrs.each{|atr, val|
                  if (!val.nil?())
                    aTmp.push("#{atr} = #{val}")
                  end
                }
                sErr.concat(aTmp.join(", ") + "\n")
               # テストID
               aTestID.each{|sTestID|
                 sErr.concat(" * #{sTestID}\n")
               }
             }
             aErrors.push(AKTFError.new(sErr))
            end
          }
        }
      end

      ### T7_SC3_001: 同一OSAPに所属しているリスタートタスクにおいて，以下のパラメータが異なる
      ###             → inipri，ttype，actcnt，spolicy，stksz，sstksz
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        hCheckReTask.each{|hGroupKeyAtrs, hAtrGroups|
          if (hAtrGroups.size() > 1)
            nNum = 1
            # グループ
            aTmp = []
            hGroupKeyAtrs.each{|atr, val|
              aTmp.push("#{atr} = #{val}")
            }
            sErr = sprintf("T7_SC3_001: " + ERR_UNIFIED_ATR_RETASK)
            sErr.concat("\ntarget: " + aTmp.join(", ") + "\n")
            # 組み合わせごとにテストID一覧出力
            hAtrGroups.each{|hAtrs, aTestID|
              # パラメータの組み合わせ
              sErr.concat("-" * 30 + "\n")
              sErr.concat("case#{nNum}: ")
              nNum += 1
              aTmp = []
              hAtrs.each{|atr, val|
                if (!val.nil?())
                  aTmp.push("#{atr} = #{val}")
                end
              }
              sErr.concat(aTmp.join(", ") + "\n")
             # テストID
             aTestID.each{|sTestID|
               sErr.concat(" * #{sTestID}\n")
             }
           }
           aErrors.push(AKTFError.new(sErr))
          end
        }
      end
      check_error(aErrors)
    end
  end
end
