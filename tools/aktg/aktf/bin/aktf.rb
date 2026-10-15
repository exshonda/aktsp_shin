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
# $Id: aktf.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
if ($0 == __FILE__)
  TOOL_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../")
  $LOAD_PATH.unshift(TOOL_ROOT)
end
require "optparse.rb"
require "common/bin/CommonModule.rb"
require "common/bin/Config.rb"
require "common/bin/test_scenario/TestScenario.rb"
require "aktf/bin/class/AKTFCommon.rb"
require "aktf/bin/class/MultipleChecker.rb"

#=====================================================================
# AKTFModule
#=====================================================================
module AKTFModule
  #===================================================================
  # クラス名: AKTF
  # 概    要: AKTFメインクラス
  #===================================================================
  class AKTF
    include CommonModule
    include AKTFModule
    attr_reader :hErrors, :hExclude

    #=================================================================
    # 概  要: コンストラクタ
    #=================================================================
    def initialize()
      @cConf   = Config.new()  # configure
      @hErrors = Hash.new{|hash, key|  # エラー情報
        hash[key] = []
      }
      @hExclude = Hash.new{|hash, key|  # プロパティ除外
        hash[key] = {
          :sMessage   => "",
          :aFileNames => []
        }
      }
      @aFileNames     = []
      @nTestCaseCount = 0
      @aErrorHookExclude = []
    end

    #=================================================================
    # 概  要: 前処理を実行しTestScenarioインスタンスの配列を返す
    #=================================================================
    def pre_process(aArgs)
      check_class(Array, aArgs)      # 実行時引数

      @aFileNames = parse_option(aArgs)  # オプションパース
      @aFileNames = @aFileNames.uniq().sort()

      # configureロード
      sConfFile = @cConf.get_configure_file()
      if (sConfFile.nil?())
        sConfFile = DEFAULT_CONFIG_FILE
      end
      @cConf.load_config(sConfFile)
      @cConf.environment_check()
      @cConf.hwcnt_param_check()

      # ファイルが開けるかチェック
      pre_file_check()

      # プリプロセッシング実行
      aTestScenario = exec_pre_process()

      # エラー表示
      print_error()

      # 有効なシナリオがない
      # (フィルタリングにより，実行可能なテストシナリオが0件になった場合の処理)
      bNoScenarioFlg = false
      if (aTestScenario.empty?())
        bNoScenarioFlg = true
        raise(AKTFError.new(ERR_NO_AVAILABLE_SCENARIO))
      end

      return aTestScenario  # [Array]TestScenarioインスタンスの配列
    rescue AKTFError
      if (bNoScenarioFlg == true)
        # フィルタリングにより，実行可能なテストシナリオが0件になった場合は，エラーメッセージのヘッダを変える
        $stderr.puts(ERR_F_HEADER)
      else
        $stderr.puts(ERR_HEADER)
        $stderr.puts($!.message())
      end
      print_exclude()
      exit(1)
    rescue AKTFMultiError
      $stderr.puts(ERR_HEADER)
      $!.aErrors.each_with_index{|ex, index|
        $stderr.puts("  #{index + 1}. #{ex.message}")
      }
      print_exclude()
      exit(1)
    end

    #=================================================================
    # 概  要: 入力テストシナリオをチェックし，TestScenarioインスタンス
    #       : の配列を返す
    #=================================================================
    def exec_pre_process()
      nCnt = 0
      nTotal = @aFileNames.size()

      aTestScenario = []
      cMultipleChecker = MultipleChecker.new()
      @aFileNames.each{|sFileName|

        nCnt += 1

        begin
          # ファイル内容読み込み
          hYaml = load_yaml_file(sFileName)
          ### T1_001: 入力YAMLがHashではない
          if (!hYaml.is_a?(Hash))
            sErr = sprintf("T1_001: " + ERR_INVALID_TYPE_TESTCASE, Hash, hYaml.class())
            raise(YamlError.new(sErr))
          end

          ### T1_029: versionが存在する
          if (hYaml.include?(TSR_LBL_VERSION))
            sErr = sprintf("T1_029: " + ERR_KEY_CANNOT_EXIST, TSR_LBL_VERSION)
            raise(YamlError.new(sErr))
          end

          # SC1-MCでSC1のテストを流用する場合，OSAP固有のエラーフックの補完とエラーチェックを追加する
          if (@cConf.is_multi?() && @cConf.is_sc1?())
            hYaml = add_osap_error_hook(hYaml)
          end

          # 不正IDマクロが含まれる場合，展開してテストケースを複製する
          hYaml = expand_invalid_id_test_cases(hYaml)

          # YAML内のテストシナリオ分析
          nTestCaseNum = hYaml.size() # 1ファイルに記述されたテストケースの数
          bSingleTest = false

          if (nTotal == 1 && nTestCaseNum == 1)
            bSingleTest = true
          end
          hYaml.each{|sTestID, hScenario|
            @nTestCaseCount += 1

            # プログレスバー
            if (@cConf.enable_no_progress_bar_mode())
              $stderr.puts("[AKTF][#{"%5.1f" % (100 * nCnt.to_f / nTotal.to_f)}\% (#{"%4d" % nCnt}/#{"%4d" % nTotal})] #{sTestID}")
            else
              print_progress("AKTF", sTestID, nCnt, nTotal)
            end

            # TestScenarioインスタンス生成
            hBefore = {sTestID => safe_dup(hScenario)}

            begin
              cTS = make_test_scenario(sTestID, hScenario, bSingleTest)
              cMultipleChecker.store(cTS, sFileName)

              # デバッグ出力
              if (@cConf.enable_debug_mode())
                dump(hBefore, AKTF_DEBUG_FILE_BEFORE)
                dump(cTS.to_yaml(), AKTF_DEBUG_FILE_AFTER)
              end

              aTestScenario.push(cTS)
            rescue AKTFMultiExcludeError
              $!.aErrors.each{|cErr|
                @hExclude[cErr.lErrCode][:sMessage] = cErr.message()
                @hExclude[cErr.lErrCode][:aFileNames].push(sFileName + " (" + sTestID + ")")
              }
              next
            end
          }

        rescue AKTFMultiError
          @hErrors[sFileName].concat($!.aErrors)
        rescue AKTFError
          @hErrors[sFileName].push($!)
        end
      }

      # プログレスバー用表示のリセット
      if (!@cConf.enable_no_progress_bar_mode())
        finish_progress("AKTF", nTotal)
      end

      # シナリオ間チェック
      cMultipleChecker.multiple_check()

      # テストIDでソート
      aTestScenario = aTestScenario.sort{|cTS1, cTS2|
        cTS1.sTestID.downcase() <=> cTS2.sTestID.downcase()
      }

      return aTestScenario  # [Array]TestScenarioインスタンスの配列
    end
    private :exec_pre_process

    #=================================================================
    # 概  要: 1件分のTestScenarioインスタンスを生成し返す
    #=================================================================
    def make_test_scenario(sTestID, hScenario, bSingleTest)
      check_class(String, sTestID)         # テストID
      check_class(Object, hScenario, true) # テストシナリオ(T1_004でチェック)
      check_class(Bool, bSingleTest)       # テストケースが1件かどうか

      # TestScenarioインスタンス作成＋basic_check
      cTS = TestScenario.new(sTestID, hScenario, bSingleTest)
      cTS.set_nil_attribute()
      @aErrorHookExclude.concat(cTS.check_error_hook_exclude())

      # 補完
      cTS.complement()

      # need_siが指定されたdo/post_conditionを削除
      cTS.delete_unneeded_do()

      # マクロチェック
      if (@cConf.is_multi?())
        cTS.core_id_macro_check()
      end

      # マクロ置換
      cTS.convert_macro()

      # 属性チェック
      cTS.attribute_check()
      # オブジェクトチェック
      cTS.object_check()
      # マージ可能かをチェック
      cTS.marge_check()
      # コンディションチェック
      cTS.condition_check()
      # シナリオチェック
      cTS.scenario_check()

      # フィルタリング
      cTS.filtering()

      # エイリアス
      cTS.alias()
      cTS.init_conditions()

      return cTS  # [TestScenario]1件分のTestScenarioインスタンス
    end
    private :make_test_scenario

    #=================================================================
    # 概  要: 不正IDマクロを展開してテストケースを複製する
    #=================================================================
    def expand_invalid_id_test_cases(hYaml)
      hExpandedYaml = {}
      cConf = Config.new()
      hInvalidData = cConf.get_invalid_id()
      aInvalidId = hInvalidData.keys()

      hYaml.each{|sTestID, hScenario|
        if (hScenario.is_a?(Hash))
          # 変換する不正IDマクロ
          sConverMacro = nil

          hScenario.each{|sKey, hData|
            # doのみ，かつ"syssrv"を持っている場合のみとする
            if ((sKey =~ TSR_REX_PRE_DO) && hData.is_a?(Hash) && (hData.has_key?(TSR_PRM_SYSSRV)) && hData[TSR_PRM_SYSSRV].is_a?(String))
              aInvalidId.each{|sId|
                if (hData[TSR_PRM_SYSSRV].include?(sId))
                  sConverMacro = sId
                  break
                end
              }
            end
          }

          # 不正IDマクロが使用されていた場合，複製する
          if (!sConverMacro.nil?())
            nCnt = 1
            hInvalidData[sConverMacro].each{|sInvalidValue|
              sNewTestID = "#{sTestID}_#{nCnt}"
              hExpandedYaml[sNewTestID] = safe_dup(hScenario)

              hExpandedYaml[sNewTestID].each{|sKey, hData|
                if ((sKey =~ TSR_REX_PRE_DO) && (hData.has_key?(TSR_PRM_SYSSRV)))
                  hExpandedYaml[sNewTestID][sKey][TSR_PRM_SYSSRV].gsub!(sConverMacro, sInvalidValue)
                end
              }

              nCnt += 1
            }
          else
            hExpandedYaml[sTestID] = safe_dup(hScenario)
          end
        else
          ### T1_004: テストシナリオがHashではない
          sErr = sprintf("T1_004: " + ERR_INVALID_TYPE_SCENARIO, Hash, hScenario.class())
          raise(YamlError.new(sErr))
        end
      }

      return hExpandedYaml
    end

    #=================================================================
    # 概  要: OSAPのエラーフックを補完し，エラーチェックを追加する
    #=================================================================
    def add_osap_error_hook(hYaml)
      hAddYaml = {}
      sErrOsapID = nil
      sErrHookID = nil
      sPostHookID = nil
      
      hYaml.each{|sTestID, hScenario|
        bAddFlg = false
        bErrHookFlg = false
        bPostHookFlg = false
        if (hScenario.is_a?(Hash))
          hScenario.each{|sKey, hData|
            # propertyにadd_osap_error_hook:trueがあるかチェック
            if ((sKey == TSR_LBL_PROPERTY) && hData.is_a?(Hash) && (hData.has_key?(TSR_PRM_ADD_OSAP_ERR_HOOK)) && hData[TSR_PRM_ADD_OSAP_ERR_HOOK] == true)
              bAddFlg = true
            # pre_conditionにシステム定義のエラーフックがあるかチェック
            elsif (sKey == TSR_LBL_PRE)
              hData.each{|sObjID, hState|
                if (hState[TSR_PRM_TYPE] == TSR_OBJ_ERROR_HOOK)
                  bErrHookFlg = true
                  sErrHookID = sObjID
                elsif (hState[TSR_PRM_TYPE] == TSR_OBJ_POSTTASK_HOOK)
                  bPostHookFlg = true
                  sPostHookID = sObjID
                end
              }
            end
          }
          ### T6_SC1_MC_001: add_osap_error_hookがtrueだが，システム定義のエラーフックがない
          if (bAddFlg == true && bErrHookFlg == false)
            sErr = sprintf("T6_SC1_MC_001: " + ERR_ADD_OSAP_ERR_HOOK)
            raise(YamlError.new(sErr))
          elsif (bAddFlg == true && bErrHookFlg == true)
            nCnt = 0
            hAddDoData = {}
            sErrOsapID = "#{TSR_OBJ_ERROR_HOOK_OSAP}_1"
            hScenario.each{|sKey, hData|
              if (sKey == TSR_LBL_PRE)
                # pre_conditionにOSAP固有のエラーフックを補完
                sDefaultOsap = @cConf.get_default_osap_id()
                hErrOsapInfo = {"type" => TSR_OBJ_ERROR_HOOK_OSAP, TSR_PRM_HOOKSTAT => TSR_STT_STP, TSR_PRM_COREID => @cConf.get_core_id_from_osap(sDefaultOsap), TSR_PRM_OSAP => sDefaultOsap, TSR_PRM_ERROR_HOOK_CFG => [TSR_STT_ONLY_OSAP, TSR_STT_BOTH]}
                hScenario[sKey][sErrOsapID] = hErrOsapInfo
              elsif (sKey =~ TSR_REX_PRE_DO)
                # システム定義のエラーフックが行っているエラーチェックをコピーする
                nCnt += 1
                if (hData[TSR_PRM_ID] == sErrHookID)
                  hAddDoData[sKey] = safe_dup(hData)
                  # コピー先のdoのIDをOSAP固有のエラーフックに変更しておく
                  hAddDoData[sKey][TSR_PRM_ID] = sErrOsapID
                end
              end
            }
            if (bPostHookFlg == true)
              # POSTTASK_HOOKがある場合，最後のdo/post_conditionでPOSTTASK_HOOKをACTIVATEにしている
              # この処理は，最後に持っていくためdoのカウントを減らし，do/post_conditionを上書きする
              nCnt -= 1
            end
            # システム定義のエラーフックをreturnするdoを追加
            hScenario["#{TSR_LBL_DO}_#{nCnt}"] = {TSR_PRM_ID => sErrHookID, TSR_PRM_SYSSRV => "return", TSR_PRM_GCOV => false}
            # システム定義のエラーフックをSTOP，OSAP固有のエラーフックをACTIVATEにするpost_conditionを追加
            hScenario["#{TSR_LBL_POST}_#{nCnt}"] = {sErrHookID => {TSR_PRM_HOOKSTAT => TSR_STT_STP}, sErrOsapID => {TSR_PRM_HOOKSTAT => TSR_STT_ACTIVATE, TSR_PRM_ERROR_HOOK_CFG => [TSR_STT_BOTH]}}
            nCnt += 1
            # コピーしたエラーチェックを追加する
            hAddDoData.each{|sDo, hData|
              sDo = sDo.gsub(/\d/, "#{nCnt}")
              hScenario[sDo] = safe_dup(hData)
              hScenario["#{TSR_LBL_POST}_#{nCnt}"] = nil
              nCnt += 1
            }
            if (bPostHookFlg == true)
              # 最後のpost_conditionにOSAP固有のエラーフックをSTOP，ポストタスクフックをACTIVATEにする処理を上書きする
              nCnt -= 1
              hScenario["#{TSR_LBL_POST}_#{nCnt}"] = {sErrOsapID => {TSR_PRM_HOOKSTAT => TSR_STT_STP}, sPostHookID => {TSR_PRM_HOOKSTAT => TSR_STT_ACTIVATE}}
            end
            hAddYaml[sTestID] = safe_dup(hScenario)
          else
            # 何もしない
            hAddYaml[sTestID] = safe_dup(hScenario)
          end
        else
          ### T1_004: テストシナリオがHashではない
          sErr = sprintf("T1_004: " + ERR_INVALID_TYPE_SCENARIO, Hash, hScenario.class())
          raise(YamlError.new(sErr))
        end
      }
      return hAddYaml
    end

    #=================================================================
    # 概  要: 出力するファイルのチェックをする
    #=================================================================
    def pre_file_check()
      # 出力ファイルが開けない
      if ($0 != __FILE__)
        # チェックするファイル
        aFileNames = [AKTF_EXCLUSION_FILE, AKTF_ERROR_HOOK_EXCLUSION_FILE]
        aExt = [".c", ".h", ".cfg", ".html"]
        aExt.each{|sExt|
          aFileNames.push(@cConf.get_out_file() + sExt)
        }
        # 実際に開いてみて確認
        aFileNames.each{|sFileName|
          if (File.exist?(sFileName))
            begin
              File.open(sFileName, "w"){|cIO|
              }
            rescue SystemCallError
              sErr = sprintf(ERR_CANNOT_OPEN_FILE, sFileName)
              raise(AKTFError.new(sErr))
            end
          end
        }
      end

      # デバッグ出力用ファイル削除
      if (@cConf.enable_debug_mode())
        aFiles = [AKTF_DEBUG_FILE_BEFORE, AKTF_DEBUG_FILE_AFTER, AKTF_DEBUG_FILE_GLOBAL]
        aFiles.each{|sFileName|
          if (File.exist?(sFileName))
            begin
              File.delete(sFileName)
            rescue SystemCallError
              sErr = sprintf(ERR_CANNOT_OPEN_FILE, sFileName)
              raise(AKTFError.new(sErr))
            end
          end
        }
      end
    end

    #=================================================================
    # 概  要: オプションをパースしオプション以外の引数を返す
    #=================================================================
    def parse_option(aArgs)
      check_class(Array, aArgs)  # コマンドライン引数

      cOpt = OptionParser.new(banner="Usage: aktg.rb [options]... [yaml files]...", width=42)
      # バージョン情報設定
      cOpt.version = $Version

      # メインオプション
      cOpt.on("-c CONFFILE", "set configure file"){|val|
        @cConf.set(CFG_FILE, val)
      }
      cOpt.on("-d", "debug mode on"){|val|
        @cConf.set(CFG_DEBUG_MODE, val)
      }
      cOpt.on("-p", "no progress bar mode on"){|val|
        @cConf.set(CFG_NO_PROGRESS_BAR, val)
      }
      cOpt.on("-t", "test program flow mode on"){|val|
        @cConf.set(CFG_TEST_FLOW, val)
      }
      cOpt.on("-s", "enable sapi output (non-support)"){|val|
        @cConf.set(CFG_ENABLE_SAPI, val)
      }
      cOpt.on("-h", "enable all hooks"){|val|
        @cConf.set(CFG_ENABLE_ALL_HOOK, val)
      }
      cOpt.on("-f", "enable forced merge"){|val|
        @cConf.set(CFG_ENABLE_FORCED_MERGE, val)
      }

      # 共通設定
      cOpt.on("--#{CFG_SCALABILITY_CLASS} CLASS", "set scalability class"){|val|
        @cConf.set(CFG_SCALABILITY_CLASS, val)
      }
      cOpt.on("--#{CFG_CONFORMANCE_CLASS} CLASS", "set conformance class"){|val|
        @cConf.set(CFG_CONFORMANCE_CLASS, val)
      }
      cOpt.on("--#{CFG_TARGET_SPEC} CLASS", "set target test spec"){|val|
        @cConf.set(CFG_TARGET_SPEC, val)
      }

      # ターゲットのハードウェアアーキテクチャに関する設定
      cOpt.on("--#{CFG_CORE_NUM} NUM", "set processor number"){|val|
        @cConf.set(CFG_CORE_NUM, val)
      }
      cOpt.on("--#{CFG_USE_MULTI_CORE} BOOL", "multi core is enable"){|val|
        @cConf.set(CFG_USE_MULTI_CORE, val)
      }
      cOpt.on("--#{CFG_MASTER_CORE} NUM", "set main task's processor ID"){|val|
        @cConf.set(CFG_MASTER_CORE, val)
      }
      cOpt.on("--#{CFG_MAX_TASK_PRI} CLASS", "set max priority of task"){|val|
        @cConf.set(CFG_MAX_TASK_PRI, val)
      }
      cOpt.on("--#{CFG_MIN_TASK_PRI} CLASS", "set min priority of task"){|val|
        @cConf.set(CFG_MIN_TASK_PRI, val)
      }
      cOpt.on("--#{CFG_IRC_ARCH} TYPE",
              "set irc architecture [#{TSR_PRM_IRC_LOCAL} | #{TSR_PRM_IRC_GLOBAL} | #{TSR_PRM_IRC_COMBINATION}]"){|val|
        @cConf.set(CFG_IRC_ARCH, val)
      }
      cOpt.on("--#{CFG_SUPPORT_ENADIS_INT_SOURCE} BOOL", "support system service of EnableInterruptSource and DisableInterruptSource"){|val|
        @cConf.set(CFG_SUPPORT_ENADIS_INT_SOURCE, val)
      }
      cOpt.on("--#{CFG_ENA_EXC_LOCK} BOOL", "cpu exception in cpu lock is available"){|val|
        @cConf.set(CFG_ENA_EXC_LOCK, val)
      }

      # ターゲット依存部毎に用意するテストライブラリ
      cOpt.on("--#{CFG_FUNC_INTERRUPT} BOOL", "interrupt function is available"){|val|
        @cConf.set(CFG_FUNC_INTERRUPT, val)
      }
      cOpt.on("--#{CFG_HARDWARE_COUNTER} BOOL", "hardware counter is available"){|val|
        @cConf.set(CFG_HARDWARE_COUNTER, val)
      }
      cOpt.on("--#{CFG_FUNC_PROTECTION_HOOK} BOOL", "protection hook start function is available"){|val|
        @cConf.set(CFG_FUNC_PROTECTION_HOOK, val)
      }
      cOpt.on("--#{CFG_VIOLATION_HANDLING_LEVEL} LEVEL", "set violation handling level"){|val|
        @cConf.set(CFG_VIOLATION_HANDLING_LEVEL, val)
      }
      cOpt.on("--#{CFG_TIMING_PROTECTION_LEVEL} LEVEL", "set timing protection level"){|val|
        @cConf.set(CFG_TIMING_PROTECTION_LEVEL, val)
      }
      cOpt.on("--#{CFG_MEMORY_PROTECTION_LEVEL} LEVEL", "set memory protection level"){|val|
        @cConf.set(CFG_MEMORY_PROTECTION_LEVEL, val)
      }
      cOpt.on("--#{CFG_STACK_MONITORING} BOOL", "stack monitoring is available"){|val|
        @cConf.set(CFG_STACK_MONITORING, val)
      }
      cOpt.on("--#{CFG_STACKFAULT_DETECTION} BOOL", "stack overflow detection is available"){|val|
        @cConf.set(CFG_STACKFAULT_DETECTION, val)
      }
      cOpt.on("--#{CFG_RETURN_STATUS} TYPE", "set type of error"){|val|
        @cConf.set(CFG_RETURN_STATUS, val)
      }
      cOpt.on("--#{CFG_USE_GET_SERVICEID} BOOL", "error serviceid get function is available"){|val|
        @cConf.set(CFG_USE_GET_SERVICEID, val)
      }
      cOpt.on("--#{CFG_USE_PARAMETER_ACCESS} BOOL", "error function's argument is available"){|val|
        @cConf.set(CFG_USE_PARAMETER_ACCESS, val)
      }
      cOpt.on("--#{CFG_USE_C1ISR} BOOL", "category 1 ISR is available"){|val|
        @cConf.set(CFG_USE_C1ISR, val)
      }
      cOpt.on("--#{CFG_ERROR_HOOK} BOOL", "error hook function is available"){|val|
        @cConf.set(CFG_ERROR_HOOK, val)
      }
      cOpt.on("--#{CFG_POST_TASK_HOOK} BOOL", "posttask hook function is available"){|val|
        @cConf.set(CFG_POST_TASK_HOOK, val)
      }
      cOpt.on("--#{CFG_PRE_TASK_HOOK} BOOL", "pretask hook function is available"){|val|
        @cConf.set(CFG_PRE_TASK_HOOK, val)
      }
      cOpt.on("--#{CFG_PROTECTION_HOOK} BOOL", "protection hook function is available"){|val|
        @cConf.set(CFG_PROTECTION_HOOK, val)
      }
      cOpt.on("--#{CFG_SHUTDOWN_HOOK} BOOL", "shutdown hook function is available"){|val|
        @cConf.set(CFG_SHUTDOWN_HOOK, val)
      }
      cOpt.on("--#{CFG_STARTUP_HOOK} BOOL", "startup hook function is available"){|val|
        @cConf.set(CFG_STARTUP_HOOK, val)
      }
      cOpt.on("--#{CFG_STARTUP_HOOK_OSAP} BOOL", "osap startup hook function is available"){|val|
        @cConf.set(CFG_STARTUP_HOOK_OSAP, val)
      }
      cOpt.on("--#{CFG_SHUTDOWN_HOOK_OSAP} BOOL", "osap shutdown hook function is available"){|val|
        @cConf.set(CFG_SHUTDOWN_HOOK_OSAP, val)
      }
      cOpt.on("--#{CFG_ERROR_HOOK_OSAP} BOOL", "osap error hook function is available"){|val|
        @cConf.set(CFG_ERROR_HOOK_OSAP, val)
      }
      cOpt.on("--#{CFG_INTER_CORE_INTERRUPT} BOOL", "inter core interrupt is available"){|val|
        @cConf.set(CFG_INTER_CORE_INTERRUPT, val)
      }
      cOpt.on("--#{CFG_ALL_INTERRUPT_LOCK_BUDGET} NUM", "set all interrupt lock budget"){|val|
        @cConf.set(CFG_ALL_INTERRUPT_LOCK_BUDGET, val)
      }
      cOpt.on("--#{CFG_OS_INTERRUPT_LOCK_BUDGET} NUM", "set os interrupt lock budget"){|val|
        @cConf.set(CFG_OS_INTERRUPT_LOCK_BUDGET, val)
      }

      # 必要に応じて変更可能なパラメータ
      cOpt.on("--#{CFG_STACK_SHARE} BOOL", "shared mode stack is available"){|val|
        @cConf.set(CFG_STACK_SHARE, val)
      }
      cOpt.on("--#{CFG_OUT_FILE} FILE", "set output program file name's prefix"){|val|
        @cConf.set(CFG_OUT_FILE, val)
      }
      cOpt.on("--#{CFG_APP_MODE} APP MODE", "set application mode for StartOS"){|val|
        @cConf.set(CFG_APP_MODE, val)
      }
      cOpt.on("--#{CFG_DEFAULT_OSAP_ID} OSAP", "set default OSAP ID"){|val|
        @cConf.set(CFG_DEFAULT_OSAP_ID, val)
      }
      cOpt.on("--#{CFG_WAIT_SPIN_LOOP} NUM", "set wait spinlock loop"){|val|
        @cConf.set(CFG_WAIT_SPIN_LOOP, val)
      }
      cOpt.on("--#{CFG_YAML_LIBRARY} TYPE", "set yaml library [#{CFG_LIB_YAML} | #{CFG_LIB_KWALIFY}]"){|val|
        @cConf.set(CFG_YAML_LIBRARY, val)
      }
      cOpt.on("--#{CFG_ENABLE_GCOV} BOOL", "enable gcov output"){|val|
        @cConf.set(CFG_ENABLE_GCOV, val)
      }
      cOpt.on("--#{CFG_ENABLE_CPPTEST} BOOL", "enable cpptest output"){|val|
        @cConf.set(CFG_ENABLE_CPPTEST, val)
      }
      cOpt.on("--#{CFG_CPPTEST_USE_BUFFER} BOOL", "cpptest use buffer"){|val|
        @cConf.set(CFG_CPPTEST_USE_BUFFER, val)
      }
      cOpt.on("--#{CFG_CPPTEST_ONLY_DO} BOOL", "cpptest only do"){|val|
        @cConf.set(CFG_CPPTEST_ONLY_DO, val)
      }
      cOpt.on("--#{CFG_ENABLE_LOG} BOOL", "enable log output"){|val|
        @cConf.set(CFG_ENABLE_LOG, val)
      }
      cOpt.on("--#{CFG_DEFINE_DECLARE} BOOL", "declare is available"){|val|
        @cConf.set(CFG_DEFINE_DECLARE, val)
      }
      cOpt.on("--#{CFG_CHECK_STACK_USAGE} BOOL", "print stack usage at end of tests"){|val|
        @cConf.set(CFG_CHECK_STACK_USAGE, val)
      }
      cOpt.on("--#{CFG_ONLY_MASTER_CORE} BOOL", "boot master core only"){|val|
        @cConf.set(CFG_ONLY_MASTER_CORE, val)
      }
      cOpt.on("--#{CFG_NT_TASK_STACK_REGION} REGION NAME", "memory region name for non-trusted task stack"){|val|
        @cConf.set(CFG_NT_TASK_STACK_REGION, val)
      }
      cOpt.on("--#{CFG_ICISR_CONVERT} BOOL", "mode to be converted to inter core interrupt"){|val|
        @cConf.set(CFG_ICISR_CONVERT, val)
      }
      cOpt.on("--#{CFG_ICISR_PRI} INTPRI", "set priority to be converted to inter core interrupt"){|val|
        @cConf.set(CFG_ICISR_PRI, val)
      }
      cOpt.on("--#{CFG_USE_TIME_PARTITIONING} BOOL", "flag that indicates whether OS has time partitioning or not"){|val|
        @cConf.set(CFG_USE_TIME_PARTITIONING, val)
      }

      # 標準オプション
      cOpt.on("-v", "--version", "show version information"){
        puts(cOpt.ver())
        exit(1)
      }
      cOpt.on("--help", "show help (this)"){
        puts(cOpt.help())
        exit(1)
      }

      # 解析実行
      begin
        aPath = cOpt.parse(aArgs)
      rescue OptionParser::ParseError
        $stderr.puts(ERR_HEADER)
        $stderr.puts(ERR_OPTION_INVALID)
        $stderr.puts(ERR_LINE)
      end

      # ファイル指定がされていない場合
      if (aPath.nil?() || aPath.empty?())
        puts(cOpt.help())
        exit(1)
      end

      return aPath  # [Array]オプション以外の引数
    end
    private :parse_option

    #=================================================================
    # 概  要: エラーを出力する
    #=================================================================
    def print_error()
      if (!@hErrors.empty?())
        nNum = 0
        $stderr.puts(ERR_HEADER)
        @aFileNames.each{|sFileName|
          if (@hErrors.has_key?(sFileName) && !@hErrors[sFileName].empty?())
            nNum = nNum + 1
            $stderr.puts("* #{sFileName}")
            @hErrors[sFileName].each_with_index{|ex, index|
              if (ex.is_a?(YamlError))
                $stderr.puts("  #{index + 1}. [#{ex.path}]")
                $stderr.puts("  => #{ex.message}")
              else
                $stderr.puts("  #{index + 1}. #{ex.message}")
              end
            }
          end
        }
        $stderr.puts(ERR_LINE)
        $stderr.puts(sprintf(ERR_RESULT, nNum))

        exit(1)
      end
    end
    private :print_error

    #=================================================================
    # 概  要: 除外内容を出力する
    #=================================================================
    def print_exclude()
      if (!@hExclude.empty?())
        # 文字列の最大長・含まれるテストケース数取得
        nMaxLength = 0
        aTestCases = []
        @hExclude.each_value{|hItem|
          nSize = hItem[:sMessage].size()
          if (nSize > nMaxLength)
            nMaxLength = nSize
          end
          aTestCases.concat(hItem[:aFileNames])
        }

        # 統計情報
        nExclude = aTestCases.uniq.size()
        nPercent = (@nTestCaseCount.to_f() - nExclude) / @nTestCaseCount * 100
        nPercent = nPercent.truncate()
        sTotal   = sprintf(ERR_EXCLUDE_RESULT, nExclude, nPercent, @nTestCaseCount - nExclude, @nTestCaseCount)

        # 出力
        $stderr.puts(ERR_EXCLUDE_HEADER)
        @hExclude.each_value{|hItem|
          $stderr.print(sprintf("* %-#{nMaxLength}s", hItem[:sMessage]))
          $stderr.puts("  #{hItem[:aFileNames].size()} test cases")
        }
        $stderr.puts(ERR_LINE)
        $stderr.puts(sTotal)
        # ファイルに出力
        File.open(AKTF_EXCLUSION_FILE, "w"){|cIO|
          cIO.puts(ERR_EXCLUDE_HEADER)
          @hExclude.each_value{|hItem|
            cIO.puts("\n#{hItem[:sMessage]} (#{hItem[:aFileNames].size()} test cases)")
            hItem[:aFileNames].each{|sFileName|
              cIO.puts("* #{sFileName}")
            }
            cIO.puts(ERR_LINE)
          }
          cIO.puts(sTotal)
        }
      end
    end

    #=================================================================
    # 概  要: 除外されたエラーフックを含むテストIDを通知する
    #=================================================================
    def print_error_hook_exclude()
      if (!@aErrorHookExclude.empty?())
        # 出力
        $stderr.puts(ERR_HOOK_EXCLUDE_HEADER)
        $stderr.puts("#{@aErrorHookExclude.uniq.size()} test cases")
        # ファイルに出力
        File.open(AKTF_ERROR_HOOK_EXCLUSION_FILE, "w"){|cIO|
          cIO.puts(ERR_HOOK_EXCLUDE_HEADER)
          cIO.puts("TestId : ")
          @aErrorHookExclude.uniq.each{|sTestId|
            cIO.puts(sTestId)
          }
          cIO.puts(ERR_LINE)
          cIO.puts("#{@aErrorHookExclude.uniq.size()} test cases")
        }
      end
    end

    #=================================================================
    # 概  要: デバッグ用YAMLファイルを生成する
    #=================================================================
    def dump(hYaml, sFileName)
      check_class(Hash, hYaml)        # 出力YAML
      check_class(String, sFileName)  # 出力先ファイル名

      cIO = File.open(sFileName, "a")
      cIO.print("---")
      dump_yaml(cIO, hYaml)
      cIO.puts()
      cIO.close()
    end

    #=================================================================
    # 概  要: YAMLオブジェクトをソートし出力する
    #=================================================================
    def dump_yaml(cIO, data, nNest = 1)
      check_class(IO, cIO)             # 出力先IO
      check_class(Object, data, true)  # 出力データ
      check_class(Integer, nNest)      # ネスト数

      sSpace = "  " * nNest
      if (data.is_a?(Hash))
        cIO.puts()
        aKeys = data.keys()
        bAllInt = aKeys.all?(){|key|
          parse_value(key, @cConf.get_macro()).is_a?(Integer)
        }
        hKeys = {}
        if (bAllInt == true)
          aKeys.each{|key|
            nVal = parse_value(key, @cConf.get_macro())
            hKeys[nVal] = key
          }
        else
          aKeys.each{|key|
            hKeys[key.to_s()] = key
          }
        end
        hKeys.sort().each{|atr, val|
          sOriginal = hKeys[atr]
          cIO.print("#{sSpace}#{sOriginal}:")
          dump_yaml(cIO, data[sOriginal], nNest + 1)
        }
      elsif (data.is_a?(Array))
        cIO.puts()
        data.each{|val|
          cIO.print("#{sSpace}-")
          dump_yaml(cIO, val, nNest + 1)
        }
      elsif (data.nil?())
        cIO.puts()
      else
        cIO.puts(" #{data}")
      end
    end
  end
end


#=====================================================================
# main
#=====================================================================
if ($0 == __FILE__)
  module AKTFModule
    include CommonModule

    cAKTF = AKTF.new()
    aTestScenario = cAKTF.pre_process(ARGV)
    cAKTF.print_exclude()
  end
end
