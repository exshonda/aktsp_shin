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
# $Id: aktg_coverage.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
TOOL_ROOT = File.expand_path(File.dirname(__FILE__) + "/../")
$LOAD_PATH.unshift(TOOL_ROOT)
require "test/unit.rb"
require "bin/aktg.rb"
require "pp.rb"

DIR_API_TEST       = File.expand_path(TOOL_ROOT + "/../../syssrv_test/")
DIR_AKTF_TEST      = File.expand_path(TOOL_ROOT + "/aktf/test/err_check")
DIR_JUST_IN        = File.expand_path(TOOL_ROOT + "/coverage/for_covers_all")
DIR_SAMPLE_TEST    = File.expand_path(TOOL_ROOT + "/../../../sample_tesry/merge")
DIR_FILTERING_TEST = File.expand_path(TOOL_ROOT + "/aktf/test/filtering")
DIR_PROTECTION_TEST= File.expand_path(TOOL_ROOT + "/../../protection_test/")

def exit(nErr = 0)
  if (nErr == 1)
    raise(StandardError)
  else
    super()
  end
end

#=====================================================================
# クラス名: CoverageTest
# 概　  要: カバレッジを取得するためのテストケース
#=====================================================================
class CoverageTest < Test::Unit::TestCase
  include CommonModule
  include AKTFModule
  include AKTG

  #===================================================================
  # 概　要: 各テストケース実行前の初期化処理
  #===================================================================
  def setup()
    cConf = Config.new()
    cConf.reset()
    @aArgs = []
  end

  #===================================================================
  # 概　要: SC1テストケースの実行
  #===================================================================
  def test_aktg_sc1()
    print_test("SC1 valid")
    setup()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（T1,T3~T5）
  #===================================================================
  def test_aktg_sc1_error()
    print_test("SC1 T1,T3-T5 error")
    common_error()
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（特殊ケース）
  #===================================================================
  def test_aktg_sc1_error_exception()
    print_test("SC1 exception error")
    setup()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1", "--#{CFG_STACK_SHARE}", "false")
    @aArgs.push("--#{CFG_VIOLATION_HANDLING_LEVEL}", "Level1")
    @aArgs.push("--#{CFG_TIMING_PROTECTION_LEVEL}", "Level2")
    @aArgs.push("--#{CFG_MEMORY_PROTECTION_LEVEL}", "Level1")
    aPattern = [
      "#{DIR_AKTF_TEST}/T3/T3_TSK017-stack_share_false_defined_stk.yaml",
      "#{DIR_FILTERING_TEST}/F_P005_violation_handling_level/violation_handling_level_2.yaml",
      "#{DIR_FILTERING_TEST}/F_P006_timing_protection_level/timing_protection_level_3.yaml",
      "#{DIR_FILTERING_TEST}/F_P007_memory_protection_level/memory_protection_level_2.yaml",
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    begin
      exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（T7）
  #===================================================================
  def test_aktg_sc1_error_T7()
    print_test("SC1 T7 error")
    setup()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1")
    aPattern = [
      "#{DIR_AKTF_TEST}/T7/*.yaml"
    ]
    begin
      exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: filteringテストケースの実行（F_P001~F_P007）
  #===================================================================
  def test_aktg_sc1_filtering()
    print_test("SC1 filtering F_P001-F_P007")
    setup()
    # F_P001
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1")
    @aArgs.push("--#{CFG_TARGET_SPEC}", "COS | NOS")
    @aArgs.push("--#{CFG_FUNC_INTERRUPT}", "false")
    @aArgs.push("--#{CFG_HARDWARE_COUNTER}", "false")
    @aArgs.push("--#{CFG_FUNC_PROTECTION_HOOK}", "false")
    @aArgs.push("--#{CFG_RETURN_STATUS}", "STANDARD")
    @aArgs.push("--#{CFG_STARTUP_HOOK}", "false")
    @aArgs.push("--#{CFG_SHUTDOWN_HOOK}", "false")
    @aArgs.push("--#{CFG_PRE_TASK_HOOK}", "false")
    @aArgs.push("--#{CFG_POST_TASK_HOOK}", "false")
    @aArgs.push("--#{CFG_ERROR_HOOK}", "false")
    @aArgs.push("--#{CFG_PROTECTION_HOOK}", "false")
    @aArgs.push("--#{CFG_SUPPORT_ENADIS_INT_SOURCE}", "false")
    aPattern = [
      "#{DIR_FILTERING_TEST}/F_P001_sc/*.yaml",
      "#{DIR_FILTERING_TEST}/F_P002_cc/*.yaml",
      "#{DIR_FILTERING_TEST}/F_P004_enadis_interrupt_source/*.yaml",
      "#{DIR_FILTERING_TEST}/F_P005_violation_handling_level/violation_handling_level_3.yaml",
      "#{DIR_FILTERING_TEST}/F_P006_timing_protection_level/timing_protection_level_2.yaml",
      "#{DIR_FILTERING_TEST}/F_P007_memory_protection_level/memory_protection_level_3.yaml",
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（gcov,declare）
  #===================================================================
  def test_aktg_sc1_gcov()
    print_test("SC1 (gcov)")
    setup()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1", "--#{CFG_ENABLE_GCOV}", "true", "--#{CFG_DEFINE_DECLARE}", "true")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/Task/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（html + progress bar）
  #===================================================================
  def test_aktg_sc1_html()
    print_test("SC1 (html + progress bar off)")
    setup()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1", "-p", "-t")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: AKTFファイル処理（事前削除）
  #===================================================================
  def test_aktg_sc1_pre_file_check()
    print_test("AKTF pre file check")

    # ファイル作成
    unless (File.exist?(AKTF_EXCLUSION_FILE))
      `touch #{AKTF_EXCLUSION_FILE}`
    end
    unless (File.exist?(AKTF_DEBUG_FILE_BEFORE))
      `touch #{AKTF_DEBUG_FILE_BEFORE}`
    end

    # ファイル削除
    @aArgs.push("-d", "--#{CFG_SCALABILITY_CLASS}", "SC1")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: AKTGオプション（ヘルプ，バージョン,全てのフックを有効）
  #===================================================================
  def test_aktg_sc1_option()
    print_test("AKTG basic option")

    ["-v", "--help"].each{|sOpt|
      setup()
      @aArgs.push(sOpt, "--#{CFG_SCALABILITY_CLASS}", "SC1")
      aPattern = [
        "#{DIR_SAMPLE_TEST}/sc1/Task/Task_0001.yaml"
      ]
      begin
        exec_test(aPattern)
      rescue
      end
    }
  end

  #===================================================================
  # 概　要: AKTGオプション（全てのフックを有効）
  #===================================================================
  def test_aktg_sc1_option_hook()
    print_test("AKTG sc1 all hook option")

    setup()
    @aArgs.push("-h", "--#{CFG_SCALABILITY_CLASS}", "SC1")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC1テストケースの実行（xml）
  #===================================================================
  def test_aktg_sc1_xml()
    print_test("SC1 (xml)")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1", "-x")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC1 YAMLファイル読み込みに使用するライブラリ（yaml）
  #===================================================================
  def test_aktg_sc1_yaml()
    print_test("SC1 (yaml)")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1", "--#{CFG_YAML_LIBRARY}", "yaml")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc1/Task/Task_0001.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: SC3テストケースの実行
  #===================================================================
  def test_aktg_sc3()
    print_test("SC3 valid")
    setup()
    # 引数
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc3/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: configureオプション指定
  #===================================================================
  def test_aktg_sc3_configure_option()
    print_test("AKTG all configure option")
    cConf = Config.new()
    cConf.load_config(DEFAULT_CONFIG_FILE)
    # 引数
    aKeys = [
      CFG_SCALABILITY_CLASS,
      CFG_VIOLATION_HANDLING_LEVEL,
      CFG_TIMING_PROTECTION_LEVEL,
      CFG_MEMORY_PROTECTION_LEVEL,
      CFG_STACK_MONITORING,
      CFG_STACKFAULT_DETECTION,
      CFG_RETURN_STATUS,
      CFG_USE_GET_SERVICEID,
      CFG_USE_PARAMETER_ACCESS,
      CFG_USE_C1ISR,
      CFG_ERROR_HOOK,
      CFG_POST_TASK_HOOK,
      CFG_PRE_TASK_HOOK,
      CFG_PROTECTION_HOOK,
      CFG_SHUTDOWN_HOOK,
      CFG_STARTUP_HOOK,
      CFG_STARTUP_HOOK_OSAP,
      CFG_SHUTDOWN_HOOK_OSAP,
      CFG_ERROR_HOOK_OSAP,
      CFG_ALL_INTERRUPT_LOCK_BUDGET,
      CFG_OS_INTERRUPT_LOCK_BUDGET,
      CFG_CONFORMANCE_CLASS,
      CFG_TARGET_SPEC,
      CFG_FUNC_PROTECTION_HOOK,
      CFG_CORE_NUM,
      CFG_USE_MULTI_CORE,
      CFG_MASTER_CORE,
      CFG_IRC_ARCH,
      CFG_SUPPORT_ENADIS_INT_SOURCE,
      CFG_FUNC_INTERRUPT,
      CFG_HARDWARE_COUNTER,
      CFG_STACK_SHARE,
      CFG_OUT_FILE,
      CFG_APP_MODE,
      CFG_WAIT_SPIN_LOOP,
      CFG_YAML_LIBRARY,
      CFG_ENABLE_GCOV,
      CFG_ENABLE_CPPTEST,
      CFG_ENABLE_LOG,
      CFG_ENA_EXC_LOCK,
      CFG_MAX_TASK_PRI,
      CFG_MIN_TASK_PRI,
      CFG_DEFINE_DECLARE,
      CFG_CHECK_STACK_USAGE
    ]
    aKeys.each{|sKey|
      @aArgs = []
      @aArgs.push("--#{sKey}")
      if (sKey == CFG_TARGET_SPEC)
        aSpec = []
        sOption = cConf.get(sKey)
        sOption.each{|sSpec|
          sSpec = sSpec + " | "
          aSpec.push(sSpec)
        }
        sSpec = (aSpec.pop).delete(" | ")
        aSpec.push(sSpec)
        @aArgs.push(aSpec.to_s())
      else
        @aArgs.push(cConf.get(sKey).to_s())
      end
      aPattern = [
        "#{DIR_SAMPLE_TEST}/sc3/Task/Task_0001.yaml"
      ]
      exec_test(aPattern)
    }
  end

  #===================================================================
  # 概　要: SC3テストケースの実行（T2_001~002,T3_SC3,T4_SC3,T6,T7_SC3_001）
  #===================================================================
  def test_aktg_sc3_error()
    print_test("SC3 T1-T5 error")
    
    # SC3
    aPatternSc3 = [
      "#{DIR_AKTF_TEST}/T2/*/*/*.yaml",
      "#{DIR_AKTF_TEST}/T3/SC3/*.yaml",
      "#{DIR_AKTF_TEST}/T4/SC3/*.yaml",
      "#{DIR_AKTF_TEST}/T6/*.yaml",
    ]
    aPatternSc3.each{|sPattern|
      Dir.glob(sPattern){|sFileName|
        setup()
        begin
          exec_test(sFileName)
        rescue
        end
      }
    }
    
    setup()
    aPattern = [
      "#{DIR_AKTF_TEST}/T7/SC3/*.yaml"
    ]
    begin
      exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: SC3テストケースの実行（特殊ケース）
  #===================================================================
  def test_aktg_sc3_error_exception()
    print_test("SC3 exception error")
    setup()
    # 引数
    @aArgs.push("--#{CFG_STACK_SHARE}", "false")
    aPattern = [
      "#{DIR_AKTF_TEST}/T3/SC3/T3_SC3_TSK002-stack_share_false_defined_sstak.yaml"
    ]
    begin
      exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: T0エラーチェック
  #===================================================================
  def test_aktg_sc3_error_T0()
    print_test("AKTG T0 error")
    # 引数
    Dir.glob("#{DIR_AKTF_TEST}/T0/*/*.yaml"){|sFileName|
      setup()
      @aArgs.concat(["-c", sFileName])
      begin
        exec_test("#{DIR_SAMPLE_TEST}/sc3/Task/Task_0001.yaml")
      rescue
      end
    }
  end

  #===================================================================
  # 概　要: T2エラーチェック(機能レベル変更)
  #===================================================================
  def test_aktg_sc3_error_T2()
    print_test("AKTG T2 error Memory Rotection LEVEL3")
    setup()
    # 引数
    @aArgs.push("--#{CFG_MEMORY_PROTECTION_LEVEL}", "Level3")
    aPattern = [
      "#{DIR_AKTF_TEST}/T2/T2_002/c2isr/T2_002_c2isr-osap-string.yaml"
    ]
    begin
     exec_test(aPattern)
    rescue
    end
    
    setup()
    @aArgs.push("--#{CFG_MEMORY_PROTECTION_LEVEL}", "Level1")
    aPattern = [
      "#{DIR_AKTF_TEST}/T2/T2_002/error_hook_osap/T2_002_error_hook_osap-osap-string.yaml",
      "#{DIR_AKTF_TEST}/T2/T2_002/shutdown_hook_osap/T2_002_shutdown_hook_osap-osap-string.yaml",
      "#{DIR_AKTF_TEST}/T2/T2_002/startup_hook_osap/T2_002_startup_hook_osap-osap-string.yaml",
    ]
    begin
     exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: filteringテストケースの実行（F_011~F_014，F_P008）
  #===================================================================
  def test_aktg_sc3_filtering()
    print_test("SC3 filtering F_P008 F_011-014")
    setup()
    # 引数
    @aArgs.push("--#{CFG_STARTUP_HOOK_OSAP}", "false")
    @aArgs.push("--#{CFG_SHUTDOWN_HOOK_OSAP}", "false")
    @aArgs.push("--#{CFG_ERROR_HOOK_OSAP}", "false")
    @aArgs.push("--#{CFG_STACK_SHARE}", "false")
    aPattern = [
      "#{DIR_FILTERING_TEST}/F_P008_need_stack_share/*.yaml",
      "#{DIR_FILTERING_TEST}/F_011_can_not_marge/shutdown_hook_activate_task_run.yaml",
      "#{DIR_SAMPLE_TEST}/sc3/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: AKTGオプション（CPPTEST）
  #===================================================================
  def test_aktg_sc3_cpptest()
    print_test("AKTG sc3 CPPTEST")

    setup()
    @aArgs.push("--#{CFG_ENABLE_CPPTEST}", "true")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc3/Task/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: AKTGオプション（全てのフックを有効）
  #===================================================================
  def test_aktg_sc3_option_hook()
    print_test("AKTG sc3 all hook option")

    setup()
    @aArgs.push("-h", "-x")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc3/Error_Hook_Osap/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: AKTGオプション（OptionParserError）
  #===================================================================
  def test_aktg_sc3_option_parser_error()
    print_test("AKTG option parser error")
    setup()

    @aArgs.push("--undefined")
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc3/Task/Task_0001.yaml"
    ]
    begin
      exec_test(aPattern)
    rescue
    end
  end

  #===================================================================
  # 概　要: SC3テストケースの実行（xml）
  #===================================================================
  def test_aktg_sc3_xml()
    print_test("SC3 (xml)")
    cConf = Config.new()
    # 引数
    aPattern = [
      "#{DIR_SAMPLE_TEST}/sc3/*/*.yaml"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: スタックモニタリング
  #===================================================================
  def test_aktg_sc3_stack_monitoring()
    print_test("SC3 stack monitoring")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC3", "--#{CFG_STACKFAULT_DETECTION}", "false")
    aPattern = [
      "#{DIR_PROTECTION_TEST}/sc3/stack_monitoring/merge_tesry/stack_monitoring_Merge_1.cmy"
    ]
    exec_test(aPattern)
  end
 
  #===================================================================
  # 概　要: CPU例外
  #===================================================================
  def test_aktg_sc3_cpu_exception()
    print_test("SC3 CPU exception")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC3")
    aPattern = [
      "#{DIR_PROTECTION_TEST}/sc3/cpu_exception/merge_tesry/cpu_exception_Merge.cmy"
    ]
    exec_test(aPattern)
  end
 
  #===================================================================
  # 概　要: メモリ保護
  #===================================================================
  def test_aktg_sc3_memory_protection()
    print_test("SC3 memory protection")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC3", "-f")
    aPattern = [
      "#{DIR_PROTECTION_TEST}/sc3/memory_protection_1/notmerge_tesry/memory_protection_NM_1_01_OK.cmy"
    ]
    exec_test(aPattern)
  end
 
  #===================================================================
  # 概　要: タスク強制終了
  #===================================================================
  def test_aktg_sc3_forced_task_termination()
    print_test("SC3 forced task termination")
    cConf = Config.new()
    # 引数
    @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC3")
    aPattern = [
      "#{DIR_PROTECTION_TEST}/sc3/forced_task_termination/merge_tesry/forced_task_termination_merge_2.cmy"
    ]
    exec_test(aPattern)
  end

  #===================================================================
  # 概　要: エラーテストケースの実行共通部
  #===================================================================
  def common_error()
    # 引数
    aPattern = [
      "#{DIR_AKTF_TEST}/T1/*.yaml",
      "#{DIR_AKTF_TEST}/T2/*/*.yaml",
      "#{DIR_AKTF_TEST}/T3/*.yaml",
      "#{DIR_AKTF_TEST}/T4/*.yaml",
      "#{DIR_AKTF_TEST}/T5/*.yaml"
    ]
    aPattern.each{|sPattern|
      Dir.glob(sPattern){|sFileName|
        setup()
        @aArgs.push("--#{CFG_SCALABILITY_CLASS}", "SC1")
        begin
          exec_test(sFileName)
        rescue
        end
      }
    }
  end
  private :common_error

  #===================================================================
  # 概　要: 指定された条件でAKTG実行
  #===================================================================
  def exec_test(aPattern)
    aPattern.each{|sPattern|
      Dir.glob(sPattern){|sFileName|
        @aArgs.push(sFileName)
      }
    }
    # AKTG実行
    cAKTG = AKTGMain.new()
    cAKTG.main(@aArgs)
  end
  private :exec_test

  #===================================================================
  # 概　要: 実行内容表示
  #===================================================================
  def print_test(sMsg)
    $stderr.puts
    $stderr.puts("-" * 32)
    $stderr.puts(sMsg)
    $stderr.puts("-" * 32)
  end
end
