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
# $Id: CBuilder.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "bin/product/CCode.rb"

module AKTG
  #===================================================================
  # クラス名: CBuilder
  # 概    要: 中間コードからCコードを生成して返す
  #===================================================================
  class CBuilder < CodeBuilder
    include CommonModule

    #=================================================================
    # 概  要: 中間コードからc/h/cfg/xmlファイルを生成する
    #=================================================================
    def build(cImCode)
      check_class(IntermediateCode, cImCode) # 中間コードのインスタンス

      @aGlobalVar      = cImCode.aGlobalVar.dup()
      @aCode           = cImCode.aCode.dup()
      @hProcUnitInfo   = cImCode.hProcUnitInfo.dup()
      @aStack          = cImCode.aStack.dup()
      @aUStack         = cImCode.aUStack.dup()
      @aHeader         = cImCode.aHeader.dup()
      @hConfig         = cImCode.hConfig.dup()
      @hOsapHook       = cImCode.hOsapHook.dup()
      @aForceMergeEnum = cImCode.aForceMergeEnum.dup()
      @hStructInfo     = cImCode.hStructInfo.dup()
      @cConf           = Config.new() # コンフィグを取得
      @sFileName       = @cConf.get_out_file()
      @hRestartTask    = cImCode.hRestartTask.dup()

      @hEnumData     = Hash.new()  # enum宣言用ハッシュ
      @hIfElseCnt    = Hash.new()  # if/else文処理用ハッシュ

      sCCode      = make_c()
      sHeaderCode = make_header()
      sCfgCode    = make_cfg()
      sXmlCode    = make_xml(cImCode)

      @@cCode = CCode.new(sCCode, sHeaderCode, sCfgCode, sXmlCode)
    end

    #=================================================================
    # 概  要: cfgファイル用文字列を生成して返す
    #=================================================================
    def make_cfg()
      # 出力コード文字列初期化
      sCfgCode = <<-EOS
#{VERSION_C}
#include "#{@sFileName}.h"

      EOS

      if (@cConf.enable_osap?())
        if (@cConf.is_sc3?() || @cConf.is_sc4?())
          sCfgCode.concat("INCLUDE(\"target_mem.cfg\");#{AKTG_NL}#{AKTG_NL}")
        end

        # どのOSAPにも属さないオブジェクトから出力
        @hConfig[IMC_NO_OSAP].each{|sCode|
          sCfgCode.concat("#{sCode}#{AKTG_NL}")
        }


        # テスト管理用OSAPは最初に出力するため取り出しておく
        hMainOsapInfo = @hConfig.delete(AKTG_MAIN_OSAP)
        hSubOsapInfo = []
        if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_multi?())
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (nCoreid != @cConf.get_master_core())
              hSubOsapInfo[nCoreid] = @hConfig.delete("#{AKTG_SUB_OSAP}_#{nCoreid}")
            end
          }
        end

        # IOC用静的API
        if (@hConfig.has_key?(IMC_IOC_OSAP))
          @hConfig[IMC_IOC_OSAP].each{|sCode|
            sCfgCode.concat("#{sCode}#{AKTG_NL}")
          }
          # プリミティブなデータ型は一律を追加する
          sCfgCode.concat("#{SAPI_DEF_IOC_PRIM}(#{TYP_AKTSP_IOC_DATA_INT_PRIM});#{AKTG_NL}")
          sCfgCode.concat("#{SAPI_DEF_IOC_PRIM}(#{TYP_AKTSP_IOC_DATA_STRUCT_PRIM});#{AKTG_NL}#{AKTG_NL}")
        end


        # OSAP固有フック実行順序のためOSAPIDでソートする
        aSortOsapInfo = @hConfig.sort()

        # 先頭にテスト管理用OSAPを追加
        if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_multi?())
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (nCoreid != @cConf.get_master_core())
              aSortOsapInfo.unshift(["#{AKTG_SUB_OSAP}_#{nCoreid}", hSubOsapInfo[nCoreid]])
            end
          }
        end
        aSortOsapInfo.unshift([AKTG_MAIN_OSAP, hMainOsapInfo])


        # ソートした順に出力
        aSortOsapInfo.each{|aOsapInfo|
          sOsapID = aOsapInfo[0]
          aOsapData = aOsapInfo[1]
          if (GRP_DUMMY_OSAP.include?(sOsapID))
            next
          end
          # OSAP宣言開始
          sCfgCode.concat("DOMAIN(#{sOsapID}){#{AKTG_NL}")

          # リスタートタスクの設定
          if (!@hRestartTask.nil?() && @hRestartTask.has_key?(sOsapID))
            sRestartTask = @hRestartTask[sOsapID]
          elsif (sOsapID == TSR_STT_NT_OSAP_RESTARTING)
            sRestartTask = AKTG_DUMMY_RETASK
          else
            sRestartTask = "NO_RESTART_TASK"
          end

          # 信頼/非信頼と各フックの有無定義
          if (@cConf.enable_all_hook())
            sCfgCode.concat("#{AKTG_TB}#{SAPI_DEF_OSAP}(#{@hOsapHook[sOsapID][:trusted].to_s.upcase()}, #{sRestartTask}, TRUE, TRUE, TRUE")
          else
            sCfgCode.concat("#{AKTG_TB}#{SAPI_DEF_OSAP}(#{@hOsapHook[sOsapID][:trusted].to_s.upcase()}, #{sRestartTask}, ")
            sCfgCode.concat("#{@hOsapHook[sOsapID][TSR_OBJ_STARTUP_HOOK_OSAP].to_s.upcase()}, ")
            sCfgCode.concat("#{@hOsapHook[sOsapID][TSR_OBJ_ERROR_HOOK_OSAP].to_s.upcase()}, ")
            sCfgCode.concat("#{@hOsapHook[sOsapID][TSR_OBJ_SHUTDOWN_HOOK_OSAP].to_s.upcase()}")
          end

          # コアID設定
          if (@cConf.is_multi?())
            sCfgCode.concat(", #{AUTOSAR_CORE_ID_PREFIX}#{@hOsapHook[sOsapID][:coreid]});#{AKTG_NL}")
          else
            sCfgCode.concat(");#{AKTG_NL}")
          end

          # 静的APIの記述
          aOsapData.each{|sCode|
            sCfgCode.concat("#{AKTG_TB}#{sCode}#{AKTG_NL}")
          }

          # クラス宣言終わり
          sCfgCode.concat("}#{AKTG_NL}")
        }

        # リソース，イベント，スピンロック，メモリセクション，メモリ領域属性を最後に出力
        @hConfig[IMC_RESOURCE_OSAP].each{|sCode|
          sCfgCode.concat("#{sCode}#{AKTG_NL}")
        }
        @hConfig[IMC_EVENT_OSAP].each{|sCode|
          sCfgCode.concat("#{sCode}#{AKTG_NL}")
        }
        if (!@hConfig[IMC_SPINLOCK_OSAP].nil?())
          @hConfig[IMC_SPINLOCK_OSAP].each{|sCode|
            sCfgCode.concat("#{sCode}#{AKTG_NL}")
          }
        end
        if (!@hConfig[IMC_MEM_NO_OSAP].nil?())
          @hConfig[IMC_MEM_NO_OSAP].each{|sCode|
            sCfgCode.concat("#{sCode}#{AKTG_NL}")
          }
        end
      else
        # SC1，SC2
        @hConfig[IMC_NO_OSAP].each{|sCode|
          # 静的APIの記述
          sCfgCode.concat("#{sCode}#{AKTG_NL}")
        }
      end

      return sCfgCode  # [String]cfgファイル用文字列
    end

    #=================================================================
    # 概  要: XMLファイル用文字列を生成して返す
    #=================================================================
    def make_xml(cImCode)
      # SC1/SC2ではIMC_NO_OSAPしか存在しないため，そのまま追加
      if (!@cConf.enable_osap?())
        cImCode.hOsapContainers.each{|sOsapID, aContainers|
          aContainers.each{|cContainer|
            cImCode.cXmlContainers.add_element(cContainer)
          }
        }
      else
        # テスト管理用コンテナは最初に，リソース・イベント・スピンロックは最後に出力するため取り出しておく
        aTestContainer = cImCode.hOsapContainers.delete(IMC_NO_OSAP)
        aMainContainer = cImCode.hOsapContainers.delete(AKTG_MAIN_OSAP)
        aResourceContainer = cImCode.hOsapContainers.delete(IMC_RESOURCE_OSAP)
        aEventContainer = cImCode.hOsapContainers.delete(IMC_EVENT_OSAP)
        aSpinlockContainer = cImCode.hOsapContainers.delete(IMC_SPINLOCK_OSAP)

        # IOCは別途親コンテナ(OsIoc)を作成する必要があるので取り出す
        aIocContainer = cImCode.hOsapContainers.delete(IMC_IOC_OSAP)

        # 静的APIと出力順序を揃えるためOSAPIDでソートする
        aSortContainer = cImCode.hOsapContainers.sort()

        # テスト管理用コンテナを先頭に，リソースとイベントを末尾に追加
        aSortContainer.insert(0, [AKTG_MAIN_OSAP, aMainContainer])
        aSortContainer.insert(0, [IMC_NO_OSAP, aTestContainer])
        aSortContainer.push([IMC_RESOURCE_OSAP, aResourceContainer])
        aSortContainer.push([IMC_EVENT_OSAP, aEventContainer])
        if (!aSpinlockContainer.nil?())
          aSortContainer.push([IMC_SPINLOCK_OSAP, aSpinlockContainer])
        end

        # ソートした順にコンテナ追加
        aSortContainer.each{|aContainers|
          aContainers[1].each{|cContainer|
            cImCode.cXmlContainers.add_element(cContainer)
          }
        }

        # IOC用コンテナ追加
        if (!aIocContainer.nil?())
          cIocContainer = make_container(XML_C_IOC, XML_C_IOC, true, false, true)
          aIocContainer.each{|cIocCom|
            cIocContainer.elements[XML_SUB].add_element(cIocCom)
          }
          cImCode.cXmlContainers.add_element(cIocContainer)
        end

        # SC3/SC4/MCでは所属OSAPの情報を出力
        hOsapObject = cImCode.hOsapObject.dup()

        # テスト管理用OSAPは最初に出力するため取り出しておく
        hMainOsapHook = @hOsapHook.delete(AKTG_MAIN_OSAP)
        hSubOsapHook = []
        if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_multi?())
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (nCoreid != @cConf.get_master_core())
              hSubOsapHook[nCoreid] = @hOsapHook.delete("#{AKTG_SUB_OSAP}_#{nCoreid}")
            end
          }
        end

        # OSAP固有フック実行順序のためOSAPIDでソートする
        aSortOsapHook = @hOsapHook.sort()

        # 先頭にテスト管理用OSAPを追加
        if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && @cConf.is_multi?())
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (nCoreid != @cConf.get_master_core())
              aSortOsapHook.unshift(["#{AKTG_SUB_OSAP}_#{nCoreid}", hSubOsapHook[nCoreid]])
            end
          }
        end
        aSortOsapHook.insert(0, [AKTG_MAIN_OSAP, hMainOsapHook])


        # ソートした順に出力
        aSortOsapHook.each{|aOsapInfo|
          sOsapID = aOsapInfo[0]
          hHooks = aOsapInfo[1]
          if (GRP_DUMMY_OSAP.include?(sOsapID))
            next
          end

          # 1つもオブジェクトが所属していない場合は参照不要
          bIsRefer = false
          if (hOsapObject.has_key?(sOsapID))
            bIsRefer = true
          end

          # OSAP固有フック用サブコンテナ
          cOsapContainer = make_container(sOsapID, XML_C_OS_APP, true, bIsRefer, true)
          if (@cConf.is_multi?())
            cOsapContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_O_CORE, "#{AUTOSAR_CORE_ID_PREFIX}#{hHooks[:coreid]}", XML_C_OS_APP))
          end
          cOsapContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_O_TRUSTED, hHooks[:trusted].to_s(), XML_C_OS_APP))
          cParam = make_container(XML_C_O_HOOK, XML_C_O_HOOK, true, false, false, XML_C_OS_APP)
          if (@cConf.enable_all_hook())
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_ERR, "true", "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_SHU, "true", "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_STA, "true", "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
          else
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_ERR, hHooks[TSR_OBJ_ERROR_HOOK_OSAP].to_s(), "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_SHU, hHooks[TSR_OBJ_SHUTDOWN_HOOK_OSAP].to_s(), "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
            cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_H_STA, hHooks[TSR_OBJ_STARTUP_HOOK_OSAP].to_s(), "#{XML_C_OS_APP}/#{XML_C_O_HOOK}"))
          end
          cOsapContainer.elements[XML_SUB].add_element(cParam)

          # 所属オブジェクトパラメータ
          if (hOsapObject.has_key?(sOsapID))
            hOsapObject[sOsapID].each{|aObjInfo|
              case aObjInfo[0]
              when TSR_OBJ_TASK
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_TSK, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_C2ISR  # C1ISRも兼用
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_ISR, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_ALARM
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_ALM, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_COUNTER
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_CNT, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_SCHEDULE_TABLE
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_SCHTBL, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_MEMORY_SECTION
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_MEMSEC, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_MEMORY_MODULE
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_MEMMOD, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_MEMORY_AREA
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_MEMAREA, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_ICISR
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_ICISR, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_TRUSTED_FUNCTION
                cParam = make_container(aObjInfo[1], XML_C_O_TFN, true, false, false, XML_C_OS_APP)
                cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_T_NAME, aObjInfo[2], "#{XML_C_OS_APP}/#{XML_C_O_TFN}"))
                cParam.elements[XML_PARAM].add_element(make_parameter(XML_P_O_T_STKSZ, aObjInfo[3].to_s(), "#{XML_C_OS_APP}/#{XML_C_O_TFN}"))
                cOsapContainer.elements[XML_SUB].add_element(cParam)
              when TSR_OBJ_RESTART_TASK
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_RE_TSK, aObjInfo[1], XML_C_OS_APP, true))
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_TSK, aObjInfo[1], XML_C_OS_APP, true))
              when TSR_OBJ_TIME_WINDOW
                cOsapContainer.elements[XML_REFER].add_element(make_parameter(XML_P_O_SCYCTWD, aObjInfo[1], XML_C_OS_APP, true))
              else
                abort(ERR_MSG % [__FILE__, __LINE__])
              end
            }
          end

          cImCode.cXmlContainers.add_element(cOsapContainer)
        }
      end

      # XML文字列生成
      sXmlCode = String.new()
      cImCode.cXmlInfo.write(sXmlCode, 2, false)

      # XML宣言の属性のコーテーションをダブルに出来ない(?)ため，ここで置換する
      sXmlCode.gsub!("'", "\"")

      # ダブルコーテーションが&quot;に変換されるのを抑止できない(?)ため，ここで置換する
      sXmlCode.gsub!("&quot;", "\"")

      # 値を定義する部分だけインデントを入れないように出来ない(?)ため，ここで置換する
      sXmlCode.gsub!(/>\n[\s]+([\.\w\/\[\]\+-]*?)\n[\s]+</, ">\\1<")

      # XMLDeclのコンストラクタではEUC-JPを指定出来ない(?)ため，ここで文字コードを置換する
      sXmlCode.sub!("UTF-8", "EUC-JP")

      return sXmlCode  # [String]XMLファイル用文字列
    end

    #=================================================================
    # 概  要: hファイル用文字列を生成して返す
    #=================================================================
    def make_header()
      # 出力コード文字列初期化
      sHeaderCode = <<-EOS
#{VERSION_C}
#ifndef TOPPERS_AKTG_HEADER
#define TOPPERS_AKTG_HEADER

      EOS

      # マルチコア識別用マクロ定義
      if (@cConf.is_multi?())
        sHeaderCode.concat("#define AKTG_CORE_NUM #{@cConf.get_core_num()}#{AKTG_NL}")
      end

      # スタック共有する場合のマクロ定義(ターゲット依存ライブラリで使用)
      if (@cConf.enable_stack_share_mode() == true)
        sHeaderCode.concat("#define AKTG_USE_SHARE_STACK#{AKTG_NL}")
        if (@cConf.is_single?())
          sHeaderCode.concat("#define AKTG_STACK_NUM #{@aStack[0]}#{AKTG_NL}")
          if (@cConf.is_sc3?() || @cConf.is_sc4?())
            sHeaderCode.concat("#define AKTG_USTACK_NUM #{@aUStack[0]}#{AKTG_NL}")
          end
        else
          # マルチコアの場合，コア毎に信頼/非信頼タスクのスタック数のマクロを定義する
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (@aStack[nCoreid] != 0)
              sHeaderCode.concat("#define T_TASK_NUM_CORE#{nCoreid} #{@aStack[nCoreid]}#{AKTG_NL}")
            end
          }
          if (@cConf.is_sc3?() || @cConf.is_sc4?())
            # 非信頼タスク
            (0..@cConf.get_core_num()-1).each{|nCoreid|
              if (@aUStack[nCoreid] != 0)
                sHeaderCode.concat("#define N_TASK_NUM_CORE#{nCoreid} #{@aUStack[nCoreid]}#{AKTG_NL}")
              end
            }
          end
        end
        sHeaderCode.concat("#{AKTG_NL}")
      end

      sHeaderCode.concat("#include \"aktsp_target_lib.h\"#{AKTG_NL}#{AKTG_NL}");

      # テスト用信頼関数インデックス
      if (@cConf.is_multi?() && (@cConf.is_sc3?() || @cConf.is_sc4?()))
        sHeaderCode.concat("extern uint8 AKTSP_TFN_ACTIVATE_TASK_INDEX[#{@cConf.get_core_num()}];#{AKTG_NL}")
        sHeaderCode.concat("extern uint8 AKTSP_TFN_SET_EVENT_INDEX[#{@cConf.get_core_num()}];#{AKTG_NL}")
        sHeaderCode.concat("extern uint8 AKTSP_TFN_SHUTDOWN_OS_INDEX[#{@cConf.get_core_num()}];#{AKTG_NL}")
        sHeaderCode.concat("extern uint8 AKTSP_TFN_RAISE_INTER_CORE_INTERRUPT_INDEX[#{@cConf.get_core_num()}];#{AKTG_NL}#{AKTG_NL}")
      end

      # 強制マージの場合，実行中のテストIDを識別するためのENUMを用意する
      if (@cConf.enable_forced_merge() == true)
        sHeaderCode.concat("enum #{AKTG_FORCE_MERGE_ENUM}{")
        @aForceMergeEnum.each{|sEnumID|
          sHeaderCode.concat("#{AKTG_NL}#{AKTG_TB}#{sEnumID},")
        }
        sHeaderCode.chop!()
        sHeaderCode.concat("#{AKTG_NL}};#{AKTG_NL}")
      end

      # enumの定義
      if (!@hEnumData.empty?())
        @hEnumData.each{|sEnumID, aTestID|
          sHeaderCode.concat("enum #{sEnumID}{")
          # 先頭に無効値を入れる
          sHeaderCode.concat("#{AKTG_NL}#{AKTG_TB}#{sEnumID.sub("ENUM_", "")}_#{AKTG_ENUM_INVALID},")
          aTestID.each{|sTestID|
            sHeaderCode.concat("#{AKTG_NL}#{AKTG_TB}#{sTestID},")
          }
          sHeaderCode.chop!()
          sHeaderCode.concat("#{AKTG_NL}};#{AKTG_NL}")
        }
        sHeaderCode.concat("#{AKTG_NL}")
      end

      @aHeader.sort.each{|sObjID, aArgs, sType|
        case sType
        when TSR_OBJ_TASK, TSR_OBJ_C2ISR, TSR_OBJ_ALARM_CALL_BACK, TSR_OBJ_TRUSTED_FUNCTION, TSR_OBJ_ICISR
          # マクロ定義の処理単位は直接呼び出しされることが無いため，宣言不要
        when TSR_OBJ_C1ISR
          sHeaderCode.concat("#{TYP_VOID} #{sObjID}_ENTITY(#{TYP_VOID});#{AKTG_NL}")
        when TSR_OBJ_STARTUP_HOOK_OSAP
          sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{TYP_VOID});#{AKTG_NL}")
        when TSR_OBJ_SHUTDOWN_HOOK_OSAP, TSR_OBJ_ERROR_HOOK_OSAP, TSR_OBJ_SHUTDOWN_HOOK_OSAP
          sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{TYP_STATUS} #{VAR_ERROR});#{AKTG_NL}")
        when IMC_FUNC_TYPE, IMC_ERROR_TYPE
          if (aArgs.empty?())
            sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{TYP_VOID});#{AKTG_NL}")
          else
            sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{aArgs.join(', ')});#{AKTG_NL}")
          end
        when IMC_PROTECTION_TYPE
          sHeaderCode.concat("#{TYP_PROTECT_RETURN} #{sObjID}(#{aArgs.join(', ')});#{AKTG_NL}")
        when IMC_FUNC_ISR
          sHeaderCode.concat("#{TYP_VOID} #{AKTG_LBL_ISR_FUNC}#{sObjID}(#{TYP_VOID});#{AKTG_NL}")
        # マルチコアにおけるシステム定義の各フックは，コア毎の共有関数となるためプロトタイプ宣言する
        when TSR_OBJ_STARTUP_HOOK, TSR_OBJ_PRETASK_HOOK, TSR_OBJ_POSTTASK_HOOK
          if (@cConf.is_multi?())
            sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{TYP_VOID});#{AKTG_NL}")
          end
        when TSR_OBJ_SHUTDOWN_HOOK, TSR_OBJ_ERROR_HOOK
          if (@cConf.is_multi?())
            sHeaderCode.concat("#{TYP_VOID} #{sObjID}(#{TYP_STATUS} #{VAR_ERROR});#{AKTG_NL}")
          end
        when TSR_OBJ_PROTECTION_HOOK
          if (@cConf.is_multi?())
            sHeaderCode.concat("#{TYP_PROTECT_RETURN} #{sObjID}(#{TYP_STATUS} #{VAR_FATAL_ERROR});#{AKTG_NL}")
          end
        else
          # main関数と処理単位以外はヘッダに出力しない
        end
      }

      sHeaderCode.concat("#{AKTG_NL}#endif /* TOPPERS_AKTG_HEADER */ #{AKTG_NL}");

      return sHeaderCode  # [String]hファイル用文字列
    end

    #=================================================================
    # 概  要: cファイル用文字列を生成して返す
    #=================================================================
    def make_c()
      # 出力コード文字列初期化
      sCCode = <<-EOS
#{VERSION_C}
#include "aktsp_common_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "#{@sFileName}.h"
      EOS

      ### IOCヘッダコードを追加する
      if (@cConf.enable_osap?())
        sCCode.concat("#include \"Ioc.h\"#{AKTG_NL}#{AKTG_NL}")
      end

      # GCOVを取得する場合
      if (@cConf.is_enable_gcov?())
        sGcov = <<-EOS

extern void #{FNC_GCOV_PAUSE}(void);
extern void #{FNC_GCOV_RESUME}(void);
extern void #{FNC_GCOV_DUMP}(void);
        EOS

        sCCode.concat(sGcov)
      end

      # C++test用関数，変数の定義
      if (@cConf.is_enable_cpptest?())
        sCCode.concat("extern #{TYP_VOID} #{CPPTEST_INIT};#{AKTG_NL}");
        sCCode.concat("extern #{TYP_VOID} #{CPPTEST_FINAL};#{AKTG_NL}");
        sCCode.concat("extern #{TYP_VOID} #{CPPTEST_DISABLE};#{AKTG_NL}");
        sCCode.concat("extern #{TYP_VOID} #{CPPTEST_ENABLE};#{AKTG_NL}#{AKTG_NL}");
      end

      # テスト用信頼関数インデックス
      if (@cConf.is_multi?() && (@cConf.is_sc3?() || @cConf.is_sc4?()))
        sTfnActTsk = "uint8 AKTSP_TFN_ACTIVATE_TASK_INDEX[#{@cConf.get_core_num()}] = {"
        sTfnSetEvt = "uint8 AKTSP_TFN_SET_EVENT_INDEX[#{@cConf.get_core_num()}] = {"
        sTfnShutOs = "uint8 AKTSP_TFN_SHUTDOWN_OS_INDEX[#{@cConf.get_core_num()}] = {"
        sTfnRaiseIcisr = "uint8 AKTSP_TFN_RAISE_INTER_CORE_INTERRUPT_INDEX[#{@cConf.get_core_num()}] = {"
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          if (nCoreid == @cConf.get_master_core())
            sTfnActTsk += "#{FNC_TFN_ACTIVATE_TASK},"
            sTfnSetEvt += "#{FNC_TFN_SET_EVENT},"
            sTfnShutOs += "#{FNC_TFN_SHUTDOWN_OS},"
            sTfnRaiseIcisr += "#{FNC_TFN_RAISE_INTERCORE_INTERRUPT},"
          else
            sTfnActTsk += "#{FNC_TFN_ACTIVATE_TASK}_#{nCoreid},"
            sTfnSetEvt += "#{FNC_TFN_SET_EVENT}_#{nCoreid},"
            sTfnShutOs += "#{FNC_TFN_SHUTDOWN_OS}_#{nCoreid},"
            sTfnRaiseIcisr += "#{FNC_TFN_RAISE_INTERCORE_INTERRUPT}_#{nCoreid},"
          end
        }
        sTfnActTsk.chop!()
        sTfnSetEvt.chop!()
        sTfnShutOs.chop!()
        sTfnRaiseIcisr.chop!()
        sCCode += "#{sTfnActTsk}};#{AKTG_NL}#{sTfnSetEvt}};#{AKTG_NL}#{sTfnShutOs}};#{AKTG_NL}#{sTfnRaiseIcisr}};#{AKTG_NL}"
      end

      # Declare宣言
      if (@cConf.enable_define_declare())
        @aHeader.sort.each{|sObjID, aArgs, sType|
          case sType
          when TSR_OBJ_TASK
            sCCode.concat("DeclareTask(#{sObjID});#{AKTG_NL}")
          when TSR_OBJ_RESOURCE
            sCCode.concat("DeclareResource(#{sObjID});#{AKTG_NL}")
          when TSR_OBJ_EVENT
            sCCode.concat("DeclareEvent(#{sObjID});#{AKTG_NL}")
          when TSR_OBJ_ALARM
            sCCode.concat("DeclareAlarm(#{sObjID});#{AKTG_NL}")
          else
            # 処理単位以外の関数は宣言しない
          end
        }
      end

      sCCode.concat(make_struct())
      sCCode.concat(make_global_var())
      sCCode.concat(make_function())

      return sCCode  # [String]cファイル用文字列
    end

    #=================================================================
    # 概  要: 関数のコード文字列を生成して返す
    #=================================================================
    def make_function()
      # ローカル変数の記述
      @hFuncCode = make_local_var() # 処理速度向上のためインスタンス変数として引数渡ししない

      # プレコードを追加
      @hProcUnitInfo.each{|sObjID, hObjData|
        bPreChk = false
        hObjData[:precode].each{|sCode|
          @hFuncCode[sObjID].push("#{AKTG_TB}#{sCode}#{AKTG_NL}")
          bPreChk = true
        }
        # プレコードがある場合，最後に改行を入れる
        if (bPreChk == true)
          @hFuncCode[sObjID].push("#{AKTG_NL}")
        end
      }

      # bootcntが0でない処理単位は複数回起動用静的変数のインクリメント処理
      @hProcUnitInfo.each{|sObjID, hObjData|
        if ((hObjData[:fbootcnt] > AKTG_MAIN_BOOTCNT))
          @hFuncCode[sObjID].push("#{AKTG_TB}#{VAR_BOOTCNT}++;#{AKTG_NL}#{AKTG_NL}")
        end
      }

      # テストシナリオ対象外の件数を減算
      nCnt = 0
      nTotal = @aCode.size()
      @aCode.each{|hScenarioes|
        hScenarioes.each{|sScenarioID, aScenario|
          GRP_IGNORE_LABEL.each{|sIgnoreLabel|
            if (sScenarioID.include?(sIgnoreLabel))
              nTotal -= 1
              break
            end
          }
        }
      }

      @aCode.each{|hScenarioes|
        hScenarioes.each{|sScenarioID, aScenario|
          bChk = false
          GRP_IGNORE_LABEL.each{|sIgnoreLabel|
            if (sScenarioID.include?(sIgnoreLabel))
              bChk = true
              break
            end
          }
          if (bChk == false)
            nCnt += 1
            if (@cConf.enable_no_progress_bar_mode())
              $stderr.puts "[CODE][#{"%5.1f" % (100 * nCnt.to_f / nTotal.to_f)}\% (#{"%4d" % nCnt}/#{"%4d" % nTotal})] #{sScenarioID}"
            else
              print_progress("CODE", sScenarioID, nCnt, nTotal)
            end
          end

          # テストケース毎の処理
          aScenario.each{|hScenarioData|
            hScenarioData.each{|sConditionID, aConditionData|
              if (sConditionID == IMC_AKTG_MAIN)
                make_block_code(aConditionData)
              else
                aConditionData.each{|hBlock|
                  hBlock.each{|sBlockID, aBlockData|
                    make_block_code(aBlockData, sScenarioID)
                  }
                }
              end
            }
          }
        }
      }

      # 共有関数の最後にelse文を入れる
      @hIfElseCnt.each{|sObjID, nCnt|
        @hFuncCode[sObjID].push("#{AKTG_TB}else {#{AKTG_NL}")
        if ((sObjID == AUTOSAR_ERROR_HOOK) || (sObjID =~ /^#{AUTOSAR_ERROR_HOOK}_.+/))
          @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}AktspErrorHookDebug(Error);#{AKTG_NL}")
        end
        if ((sObjID == AUTOSAR_PROTECTION_HOOK) || (sObjID =~ /^#{AUTOSAR_PROTECTION_HOOK}_.+/))
          @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}AktspProtectionHookDebug(FatalError);#{AKTG_NL}")
        end
        @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}#{FNC_CHECK_ASSERT}(FALSE);#{AKTG_NL}")
        @hFuncCode[sObjID].push("#{AKTG_TB}}#{AKTG_NL}")
      }

      # プログレスバー用表示のリセット
      if (!@cConf.enable_no_progress_bar_mode())
        finish_progress("CODE", nTotal)
      end

      # ポストコードを追加
      @hProcUnitInfo.each{|sObjID, hObjData|
        hObjData[:postcode].each{|sCode|
          @hFuncCode[sObjID].push("#{AKTG_TB}#{sCode}#{AKTG_NL}")
        }
      }

      # 出力コードを保持する文字列
      sFuncCode = ""

      # ヘッダをハッシュ化する
      hHeader = {}
      @aHeader.each{|aFuncInfo|
        hHeader[aFuncInfo[0]] = aFuncInfo[1]
      }

      # オブジェクト種別情報を作成
      hObjType = {}
      @aHeader.each{|aFuncInfo|
        hObjType[aFuncInfo[0]] = aFuncInfo[2]
      }

      # 処理単位ごとに分けたハッシュを，出力する形のコードに作る
      @hFuncCodeLow = @hFuncCode.sort_by{|key, val| key}
      @hFuncCodeLow.each{|sObjectID, aCode|
        # 関数宣言開始
        case hObjType[sObjectID]
        when TSR_OBJ_TASK, TSR_OBJ_RESTART_TASK
          sFuncCode.concat("TASK(#{sObjectID}){#{AKTG_NL}")
        when TSR_OBJ_C1ISR
          sFuncCode.concat("AKTSP_C1ISR_ENTRY(#{sObjectID}, #{sObjectID}_ENTITY)#{AKTG_NL}#{TYP_VOID} #{sObjectID}_ENTITY(#{TYP_VOID}){#{AKTG_NL}")
        when TSR_OBJ_C2ISR
          sFuncCode.concat("ISR(#{sObjectID}){#{AKTG_NL}")
        when TSR_OBJ_ALARM_CALL_BACK
          sFuncCode.concat("ALARMCALLBACK(#{sObjectID}){#{AKTG_NL}")
        when TSR_OBJ_STARTUP_HOOK, TSR_OBJ_PRETASK_HOOK, TSR_OBJ_POSTTASK_HOOK, TSR_OBJ_STARTUP_HOOK_OSAP
          sFuncCode.concat("#{TYP_VOID} #{sObjectID}(#{TYP_VOID}){#{AKTG_NL}")
        when TSR_OBJ_SHUTDOWN_HOOK, TSR_OBJ_ERROR_HOOK, TSR_OBJ_SHUTDOWN_HOOK_OSAP, TSR_OBJ_ERROR_HOOK_OSAP, TSR_OBJ_SHUTDOWN_HOOK_OSAP
          sFuncCode.concat("#{TYP_VOID} #{sObjectID}(#{TYP_STATUS} #{VAR_ERROR}){#{AKTG_NL}")
        when TSR_OBJ_PROTECTION_HOOK, IMC_PROTECTION_TYPE
          sFuncCode.concat("#{TYP_PROTECT_RETURN} #{sObjectID}(#{TYP_STATUS} #{VAR_FATAL_ERROR}){#{AKTG_NL}")
        when TSR_OBJ_TRUSTED_FUNCTION
          sFuncCode.concat("TRUSTEDFUNCTION(TRUSTED_#{sObjectID}, FunctionIndex, FunctionParams){#{AKTG_NL}")
        when TSR_OBJ_ICISR
          sFuncCode.concat("ICISR(#{sObjectID}){#{AKTG_NL}")
        when IMC_FUNC_TYPE, IMC_ERROR_TYPE
          if (hHeader[sObjectID].empty?())
            sFuncCode.concat("#{TYP_VOID} #{sObjectID}(#{TYP_VOID}){#{AKTG_NL}")
          else
            sFuncCode.concat("#{TYP_VOID} #{sObjectID}(#{hHeader[sObjectID].join(', ')}){#{AKTG_NL}")
          end
        when IMC_MAIN_TYPE
          sFuncCode.concat("#{TYP_SINT32} #{sObjectID}(#{TYP_VOID}){#{AKTG_NL}")
        when IMC_FUNC_ISR
          sFuncCode.concat("#{TYP_VOID} #{AKTG_LBL_ISR_FUNC}#{sObjectID}(#{TYP_VOID}){#{AKTG_NL}")
        else
          # 該当無しエラー
          abort(ERR_MSG % [__FILE__, __LINE__])
        end

        # 内部コードの記述
        aCode.each{ |sCode|
          sFuncCode.concat("#{sCode}")
        }

        # 関数宣言終わり
        sFuncCode.concat("}#{AKTG_NL}#{AKTG_NL}")
      }

      return sFuncCode  # [String]関数のコード
    end

    #=================================================================
    # 概  要: グローバル変数のコードを生成して返す
    #=================================================================
    def make_global_var()

      # 出力コードの臨時文字列
      sGlobalCode = ""

      @aGlobalVar.each{|sVarName, sVarType, snVarValue|
        # :valueの値が存在するかどうか判別
        if (snVarValue.nil?())
          sGlobalCode.concat("#{sVarType} #{sVarName};#{AKTG_NL}")
        else
          sGlobalCode.concat("#{sVarType} #{sVarName} = #{snVarValue};#{AKTG_NL}")
        end
      }

      # 改行
      sGlobalCode.concat("#{AKTG_NL}")

      return sGlobalCode  # [String]グローバル変数のコード
    end

    #=================================================================
    # 概  要: 構造体データ型宣言と変数のコードを生成して返す
    #=================================================================
    def make_struct()

      # 出力コードの臨時文字列
      sStructCode = ""
      
      @hStructInfo.each{|sStructName, hStructInfo|
        sTypedef = hStructInfo["typedef"]
        hMemberinfo = hStructInfo["member"]
        
        sStructCode += "#{AKTG_NL}typedef struct #{sStructName} {#{AKTG_NL}"
        hStructInfo["member"].each{|hStruct|
          hStruct.each{|sVal, sDatatype|
            sStructCode += "#{AKTG_TB}#{sDatatype} #{sVal};#{AKTG_NL}"
          }
        }
        sStructCode += "}#{sTypedef};#{AKTG_NL}#{AKTG_NL}"
      }

      return sStructCode  # [String]グローバル変数のコード
    end

    #=================================================================
    # 概  要: ローカル変数のコードを生成して返す
    #=================================================================
    def make_local_var()

      # 出力前のコードを保持するハッシュ
      hLocalCode = {}

      @hProcUnitInfo.each{|sObjID, hObjData|
        # キーに対する値がない場合，新しいキーを作る
        # (ここで全処理単位に対する@hFuncCodeのキーが作成される)
        if (hLocalCode[sObjID].nil?())
          hLocalCode[sObjID] = []
        end

        hObjData[:localvar].each{|sVarName, hVarData|
          # :valueの値が存在するかどうか判別
          if (hVarData[:value].nil?())
            hLocalCode[sObjID].push("#{AKTG_TB}#{hVarData[:type]} #{sVarName};#{AKTG_NL}")
          else
            hLocalCode[sObjID].push("#{AKTG_TB}#{hVarData[:type]} #{sVarName} = #{hVarData[:value]};#{AKTG_NL}")
          end
        }

        # 複数回起動用静的変数の宣言
        if (hObjData[:fbootcnt] > AKTG_MAIN_BOOTCNT)
          hLocalCode[sObjID].push("#{AKTG_TB}static #{TYP_SINT32} #{VAR_BOOTCNT} = -1;#{AKTG_NL}")
        end

        # 改行
        hLocalCode[sObjID].push("#{AKTG_NL}")
      }

      return hLocalCode  # [String]ローカル変数のコード
    end

    #=================================================================
    # 概  要: ブロックの実行コードを生成する
    #=================================================================
    def make_block_code(aBlockData, sTestID = nil)
      check_class(Array,  aBlockData)    # ブロックのコードのデータ
      check_class(String, sTestID, true) # テストID

      # ブロックごとに改行を出すためのオブジェクトリスト
      aObjList = []

      #nCoreid, sAttrはCコード生成時は使用しない
      aBlockData.each{|sObjID, sCode, nBootCnt, nCoreid, sAttr|
        # 改行を入れるオブジェクリスト挿入
        aObjList.push(sObjID)

        # 共有関数用処理
        # (マルチコアでは全コアで起動されるフックは除外して，コア毎の関数を共有関数とする)
        if ((sObjID =~ /^#{AKTG_LBL_C1ISR_COMMON}_.+/) || (sObjID =~ /^#{AKTG_LBL_C2ISR_COMMON}_.+/) || (sObjID =~ /^#{AUTOSAR_ERROR_HOOK}_.+/) || (sObjID =~ /^#{AKTG_LBL_RETASK_COMMON}_.+/) ||
            (@cConf.is_single?() &&
             ((sObjID == AUTOSAR_PRETASK_HOOK) || (sObjID == AUTOSAR_POSTTASK_HOOK) || (sObjID == AUTOSAR_ERROR_HOOK) || (sObjID == AUTOSAR_PROTECTION_HOOK))) ||
            (@cConf.is_multi?() &&
             ((sObjID =~ /^#{AUTOSAR_PRETASK_HOOK}_Core[0-9]/) || (sObjID =~ /^#{AUTOSAR_POSTTASK_HOOK}_Core[0-9]/) || (sObjID =~ /^#{AUTOSAR_ERROR_HOOK}_Core[0-9]/) || (sObjID =~ /^#{AUTOSAR_PROTECTION_HOOK}_Core[0-9]/) ||
              (sObjID =~ /^#{AKTG_LBL_ICISR_COMMON}_.+/))))

          # if/else文初期処理
          sElseStr = ""
          if ((sObjID != AUTOSAR_PRETASK_HOOK) && (sObjID != AUTOSAR_POSTTASK_HOOK) &&
              (sObjID !~ /^#{AUTOSAR_PRETASK_HOOK}_Core[0-9]/) && (sObjID !~ /^#{AUTOSAR_POSTTASK_HOOK}_Core[0-9]/))
            if (!@hIfElseCnt.has_key?(sObjID))
              @hIfElseCnt[sObjID] = 0
            else
              @hIfElseCnt[sObjID] += 1
              sElseStr = "else "
            end
          end

          # 必要な文字列作成
          sEnumObjID    = sObjID
          sEnumID       = "ENUM_#{sEnumObjID}"
          sEnumElement  = "#{sEnumObjID}_#{sTestID}"
          sIfTestID     = "#{AKTG_TB}#{sElseStr}if (#{sEnumObjID}_#{VAR_BOOTCNT} == #{sEnumObjID}_#{sTestID}) {#{AKTG_NL}"
          sEndIfTestID  = "#{AKTG_TB}} \/* #{sEnumObjID}_#{VAR_BOOTCNT} == #{sEnumObjID}_#{sTestID} *\/"

          sIfBootcnt    = "#{AKTG_TB}#{AKTG_TB}\/* #{sTestID} *\/#{AKTG_NL}#{AKTG_TB}#{AKTG_TB}if (#{VAR_BOOTCNT} == #{nBootCnt}) {#{AKTG_NL}"
          sInitBootcnt  = "#{AKTG_TB}#{AKTG_TB}#{AKTG_TB}#{VAR_BOOTCNT} = -1; \/* #{sTestID} *\/#{AKTG_NL}#{AKTG_NL}"
          sEndIfBootcnt = "#{AKTG_NL}#{AKTG_TB}#{AKTG_TB}} \/* #{VAR_BOOTCNT} == #{nBootCnt} (#{sTestID}) *\/#{AKTG_NL}"

          # enumデータの初期処理
          if (!@hEnumData.has_key?(sEnumID))
            @hEnumData[sEnumID] = [sEnumElement]
          # データがなければ追加
          elsif (!@hEnumData[sEnumID].include?(sEnumElement))
            @hEnumData[sEnumID].push(sEnumElement)
          end

          # テストID毎の起動
          if (!@hFuncCode[sObjID].include?(sIfTestID))
            @hFuncCode[sObjID].push(sIfTestID)
          end

          # 複数回起動
          if (@hProcUnitInfo["#{sObjID}"][:fbootcnt] == AKTG_MAIN_BOOTCNT)
            @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}#{sCode}#{AKTG_NL}")
          else
            if (!@hFuncCode[sObjID].include?(sIfBootcnt))
              @hFuncCode[sObjID].push(sIfBootcnt)
              @hFuncCode[sObjID].delete(sInitBootcnt)
              @hFuncCode[sObjID].push(sInitBootcnt)
            end

            @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}#{AKTG_TB}#{sCode}#{AKTG_NL}")

            if (@hFuncCode[sObjID].include?(sEndIfBootcnt))
              @hFuncCode[sObjID].delete(sEndIfBootcnt)
            end

            @hFuncCode[sObjID].push(sEndIfBootcnt)
          end

          if (@hFuncCode[sObjID].include?(sEndIfTestID))
            @hFuncCode[sObjID].delete(sEndIfTestID)
          end

          @hFuncCode[sObjID].push(sEndIfTestID)
        # 通常のソースコード
        else
          # 必要な文字列作成
          sIfBootcnt    = "#{AKTG_TB}if (#{VAR_BOOTCNT} == #{nBootCnt}) {#{AKTG_NL}"
          sEndIfBootcnt = "#{AKTG_TB}} \/* #{VAR_BOOTCNT} == #{nBootCnt} *\/#{AKTG_NL}"

          # 複数回起動の確認
          if (@hProcUnitInfo[sObjID][:fbootcnt] == AKTG_MAIN_BOOTCNT)
            @hFuncCode[sObjID].push("#{AKTG_TB}#{sCode}#{AKTG_NL}")
          else
            if (!@hFuncCode[sObjID].include?(sIfBootcnt))
              @hFuncCode[sObjID].push(sIfBootcnt)
            end

            @hFuncCode[sObjID].push("#{AKTG_TB}#{AKTG_TB}#{sCode}#{AKTG_NL}")

            if (@hFuncCode[sObjID].include?(sEndIfBootcnt))
              @hFuncCode[sObjID].delete(sEndIfBootcnt)
            end

            @hFuncCode[sObjID].push(sEndIfBootcnt)
          end
        end
      }

      # ブロック内のオブジェクト毎に改行を入れる
      aObjList.uniq.each{|sObjID|
        @hFuncCode[sObjID].push("#{AKTG_NL}")
      }
    end

    #=================================================================
    # 概  要: 生成したコードをファイル化する
    #=================================================================
    def output_code_file(cCCode, sFileName)
      check_class(CCode, cCCode)    # CCodeのインスタンス
      check_class(String, sFileName) # 出力時のファイル名

      cCCode.output_code_file(sFileName)
    end

    #=================================================================
    # 概  要: 生成したコードクラスを返す
    #=================================================================
    def get_result()
      return @@cCode  # [CCode]生成したコードクラス
    end
  end
end
