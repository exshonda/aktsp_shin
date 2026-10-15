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
# $Id: error_checker.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
  TOOL_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../../")
  $LOAD_PATH.unshift(TOOL_ROOT)
end

require "aktf/test/err_check/test_data.rb"
require "common/kwalify.rb"
require "optparse.rb"

module ErrorCheckModule
  class ErrorCheck
    #=================================================================
    # 概  要: コンストラクタ
    #=================================================================
    def initialize(aArgs)
      check_class(Array, aArgs)  # 全オプション

      # エラーチェッカの位置
      @sTECPath      = File.dirname(__FILE__)
      @aMakeFileList = []  # エラーファイルおよびシェルファイルの生成時その情報を持つ変数

      # プロファイル設定
#     @bSC      = false
      @bMC      = false
      @sProfile = nil
      @sSClass  = nil
      @sLevel   = nil
      @sCore    = nil

      # スケーラビリティクラス
      @bSC1 = false
      @bSC2 = false
      @bSC3 = false
      @bSC4 = false

      # メモリ保護機能の機能レベル
      @bML1 = false
      @bML2 = false
      @bML3 = false

      # T0: environmentエラーチェックのオプション
      @bEnvironment = false
      @bT0_001      = false
      @bT0_002      = false
      @bT0_003      = false
      @bT0_004      = false
      @bT0_005      = false
      @bT0_006      = false
      @bT0_007      = false
      @bT0_008      = false
      @bT0_009      = false
      @bT0_010      = false
      @bT0_011      = false
      @bT0_012      = false
      @bT0_013      = false
      @bT0_014      = false
      @bT0_015      = false
      @bT0_SC3_001  = false

      # T1: basicエラーチェックのオプション
      @bBasic = false

      # T2: attributeエラーチェックのオプション
      @bAttribute = false
      @bT2_001    = false
      @bT2_002    = false
      @bT2_003    = false

      # T3: objectエラーチェックのオプション
      @bObject = false

      # T4: conditionエラーチェックのオプション
      @bCondition = false

      # T5: scenarioエラーチェックのオプション
      @bScenario = false

      # T6: propertyエラーチェックのオプション
      @bProperty = false
      @bT6_001   = false
      @bT6_004   = false
      @bT6_005   = false
      @bT6_006   = false
      @bT6_SC1_MC_001 = false

      # T7: multipleエラーチェックのオプション
      @bMultiple = false

      # 生成，実行，シェル，ディレクトリのオプション
      @bCreate  = false
      @bShell   = false
      @bRemove  = false

      # configureの情報取得
      @hConfigure = Kwalify::Yaml.load_file(ANY_CONFIGURE)
      @hConf      = @hConfigure.dup()             # configureのマクロ，不正IDマクロ以外の部分
      @hMacro     = @hConf.delete(CFG_MACRO)      # configureのマクロ部分
      @hInvalid   = @hConf.delete(CFG_INVALID_ID) # configureの不正IDマクロ部分
      @hMcMacro   = @hConf.delete(CFG_MC_MACRO)   # configureのMC用マクロ部分

      # 生成ファイル名と実行ファイル名を保持する変数と実行パス
      @sFileName = ""

      # ASPモードの場合，FMPファイルを除外するための変数
#     @aFMPAttr = []

      # オプション設定
      parse_option(aArgs)
    end

    #=================================================================
    # 概  要: オプションによる前処理
    #=================================================================
    def parse_option(aArgs)
      check_class(Array, aArgs)  # 全オプション

      cOpt = OptionParser.new()
      cOpt.program_name = "AKTF Error Checker"

      # 実施するテストの設定
      cOpt.on("-A", "--all", "All item") {
        @bEnvironment = true  # T0: environment
          @bT0_001    = true
          @bT0_002    = true
          @bT0_003    = true
          @bT0_004    = true
          @bT0_005    = true
          @bT0_006    = true
          @bT0_007    = true
          @bT0_008    = true
          @bT0_009    = true
          @bT0_010    = true
          @bT0_011    = true
          @bT0_012    = true
          @bT0_013    = true
          @bT0_014    = true
          @bT0_015    = true
          @bT0_SC3_001= true
        @bBasic       = true  # T1: basic
        @bAttribute   = true  # T2: attribute
          @bT2_001    = true
          @bT2_002    = true
          @bT2_003    = true
        @bObject      = true  # T3: object
        @bCondition   = true  # T4: condition
        @bScenario    = true  # T5: scenario
        @bProperty    = true  # T6: property
          @bT6_001    = true
          @bT6_004    = true
          @bT6_005    = true
          @bT6_006    = true
          @bT6_SC1_MC_001 = true
        @bMultiple    = true  # T7: multiple
      }

      cOpt.on("")

      # マルチコア
      cOpt.on("-m", "--multi", "MultiCore test") {
        @bMC = true
        @sCore = "--use_multi_core true --core_num 2"
      }

      cOpt.on("")

      # スケーラビリティクラス
      cOpt.on("-x number", "--sc number", "scalability class number [1-4]") {|sVal|
        if (sVal == "1")
          @bSC1 = true
          @sSClass = "--scalability_class SC1"
        end
        if (sVal == "2")
          @bSC2 = true
        end
        if (sVal == "3")
          @bSC3 = true
          @sSClass = "--scalability_class SC3"
        end
        if (sVal == "4")
          @bSC4 = true
          @sSClass = "--scalability_class SC4"
        end
      }

      # メモリ保護機能の機能レベル
      cOpt.on("-p number", "--memory number", "memory protection level number [1-3]") {|sVal|
        if (sVal == "1")
          @bML1 = true
          @sLevel = "--memory_protection_level Level1"
        end
        if (sVal == "2")
          @bML2 = true
          @sLevel = "--memory_protection_level Level2"
        end
        if (sVal == "3")
          @bML3 = true
          @sLevel = "--memory_protection_level Level3"
        end
      }

      cOpt.on("")

      cOpt.on("-t number", "--test number", "Test item number [0-7]") {|tVal|
        if (tVal == "0")
          @bEnvironment = true
        end
        if (tVal == "1")
          @bBasic = true
        end
        if (tVal == "2")
          @bAttribute = true
        end
        if (tVal == "3")
          @bObject = true
        end
        if (tVal == "4")
          @bCondition = true
        end
        if (tVal == "5")
          @bScenario = true
        end
        if (tVal == "6")
          @bProperty = true
        end
        if (tVal == "7")
          @bMultiple = true
        end
      }
      cOpt.on("-l number", "--label number", "Item label number [1-13,31,101]") {|lVal|
        if (lVal == "1")
          @bT0_001 = true
          @bT2_001 = true
          @bT6_001 = true
        end
        if (lVal == "2")
          @bT0_002 = true
          @bT2_002 = true
        end
        if (lVal == "3")
          @bT0_003 = true
          @bT2_003 = true
        end
        if (lVal == "4")
          @bT0_004 = true
          @bT6_004 = true
        end
        if (lVal == "5")
          @bT0_005 = true
          @bT6_005 = true
        end
        if (lVal == "6")
          @bT0_006 = true
          @bT6_006 = true
        end
        if (lVal == "7")
          @bT0_007 = true
        end
        if (lVal == "8")
          @bT0_008 = true
        end
        if (lVal == "9")
          @bT0_009 = true
        end
        if (lVal == "10")
          @bT0_010 = true
        end
        if (lVal == "11")
          @bT0_011 = true
        end
        if (lVal == "12")
          @bT0_012 = true
        end
        if (lVal == "13")
          @bT0_013 = true
        end
        if (lVal == "14")
          @bT0_014 = true
        end
        if (lVal == "15")
          @bT0_015 = true
        end
        if (lVal == "31")
          @bT0_SC3_001 = true
        end
        if (lVal == "101")
          @bT6_SC1_MC_001 = true
        end
      }

      cOpt.on("")

      # 生成，実行，削除設定
      cOpt.on("-c", "--create", "Create error-file") {     # エラーファイル生成
        @bCreate = true
      }
      cOpt.on("-s", "--shell", "Make shell") {             # シェルファイル生成
        @bShell = true
      }
      cOpt.on("-r", "--remove", "All remove") {  # 生成したファイルおよびディレクトリの削除
        @bRemove = true
      }

      cOpt.on("")

      # Help
      cOpt.on("-h", "--help", "Help") {
        puts cOpt.help()
        exit(1)
      }
      # オプション処理
      begin
        aConfPath = cOpt.parse(aArgs)
      rescue OptionParser::ParseError
        puts cOpt.help()
        exit(1)
      end

      # @bEnvironmentだけ定義された場合はT0の全ラベルをtrueにする
      if ((@bEnvironment == true) && (@bT0_001 == false) && (@bT0_002 == false) && (@bT0_003 == false) &&
          (@bT0_004 == false) && (@bT0_005 == false) && (@bT0_006 == false) && (@bT0_007 == false) &&
          (@bT0_008 == false) && (@bT0_009 == false) && (@bT0_010 == false) && (@bT0_011 == false) &&
          (@bT0_012 == false) && (@bT0_013 == false) && (@bT0_014 == false) && (@bT0_015 == false) &&
          (@bT0_SC3_001 == false))
        @bT0_001 = true
        @bT0_002 = true
        @bT0_003 = true
        @bT0_004 = true
        @bT0_005 = true
        @bT0_006 = true
        @bT0_007 = true
        @bT0_008 = true
        @bT0_009 = true
        @bT0_010 = true
        @bT0_011 = true
        @bT0_012 = true
        @bT0_013 = true
        @bT0_014 = true
        @bT0_015 = true
        @bT0_SC3_001 = true
      end

      # @bAttributeだけ定義された場合はT2の全ラベルをtrueにする
      if ((@bAttribute == true) && (@bT2_001 == false) && (@bT2_002 == false) && (@bT2_003 == false))
        @bT2_001 = true
        @bT2_002 = true
        @bT2_003 = true
      end

      # @bPropertyだけ定義された場合はT2の全ラベルをtrueにする
      if ((@bProperty == true) && (@bT6_001 == false) && (@bT6_004 == false) && (@bT6_005 == false) &&
          (@bT6_006 == false) && (@bT6_SC1_MC_001 == false))
        @bT6_001 = true
        @bT6_004 = true
        @bT6_005 = true
        @bT6_006 = true
        @bT6_SC1_MC_001 = true
      end

      # スケーラビリティクラスが何も指定されなかった場合はSC1をtrueにする
      if ((@bSC1 == false) && (@bSC2 == false) && (@bSC3 == false) && (@bSC4 == false))
        @bSC1 = true
        @sSClass = "--scalability_class SC1"
        @bT0_SC3_001 = false
      end

      # メモリ保護機能の機能レベルが何も指定されなかった場合はLevel2にする
      if ((@bSC1 == false) && (@bSC2 == false) && (@bSC3 == false) && (@bSC4 == false))
        @bML2 = true
      end

      # スケーラビリティクラスがSC3，SC4以外の場合は，T0_SC3_001をfalseにする
      if ((@bSC3 == false) && (@bSC4 == false))
        @bT0_SC3_001 = false
      end

      if ((@bMC == false) || (@bSC3 == true || @bSC4 == true))
        @bT6_SC1_MC_001 = false
      end

      # スケーラビリティクラスがSC1，SC2かつ，マルチコアを指定した場合はデフォルトOSAPを指定する
      if ((@bSC1 == true || @bSC2 == true) && @bMC == true)
        @sProfile = "--default_osap_id DEFAULT_OSAP"
        @bT6_SC1_MC_001 = true
      end

      # T0，T1，T2，T3，T4，T5，T6，T7オプションのチェック
      if (((@bT0_001 == false) && (@bT0_002 == false) && (@bT0_003 == false) && (@bT0_004 == false) &&
           (@bT0_005 == false) && (@bT0_006 == false) && (@bT0_007 == false) && (@bT0_008 == false) &&
           (@bT0_009 == false) && (@bT0_010 == false) && (@bT0_011 == false) && (@bT0_012 == false) &&
           (@bT0_013 == false) && (@bT0_014 == false) && (@bT0_015 == false) && (@bT0_SC3_001 == false) &&
           (@bT2_001 == false) && (@bT2_002 == false) && (@bT2_003 == false) && (@bT6_001 == false) &&
           (@bT6_004 == false) && (@bT6_005 == false) && (@bT6_006 == false) && (@bT6_SC1_MC_001 == false) &&
           (@bBasic == false) && (@bObject == false) && (@bCondition == false) && (@bScenario == false) &&
           (@bProperty == false) && (@bMultiple == false)) && (@bRemove == false))
        puts cOpt.help()
        exit(1)
      end

      # ファイル生成オプションのチェック
      if ((@bCreate == false) && (@bShell == false) && (@bRemove == false))
        puts cOpt.help()
        exit(1)
      end
   end

    #=================================================================
    # 概  要: エラーファイル生成，シェルファイル生成
    #=================================================================
    def proceed_AKTF_check()
      # Delete
      if (@bRemove == true)
        remove()
        return
      end

      # configureファイルの属性が一致しているかチェック
      check_configure()

      # T0: environment
      if (@bEnvironment == true)
        # Write
        if (@bCreate == true)
          if (@bT0_001 == true)
            create_file(FDR_T0_001)
          end
          if (@bT0_002 == true)
            create_file(FDR_T0_002)
          end
          if (@bT0_003 == true)
            create_file(FDR_T0_003)
          end
          if (@bT0_004 == true)
            create_file(FDR_T0_004)
          end
          if (@bT0_005 == true)
            create_file(FDR_T0_005)
          end
          if (@bT0_006 == true)
            create_file(FDR_T0_006)
          end
          if (@bT0_007 == true)
            create_file(FDR_T0_007)
          end
          if (@bT0_008 == true)
            create_file(FDR_T0_008)
          end
          if (@bT0_009 == true)
            create_file(FDR_T0_009)
          end
          if (@bT0_010 == true)
            create_file(FDR_T0_010)
          end
          if (@bT0_011 == true)
            create_file(FDR_T0_011)
          end
          if (@bT0_012 == true)
            create_file(FDR_T0_012)
          end
          if (@bT0_013 == true)
            create_file(FDR_T0_013)
          end
          if (@bT0_014 == true)
            create_file(FDR_T0_014)
          end
          if (@bT0_015 == true)
            create_file(FDR_T0_015)
          end
          if (@bT0_SC3_001 == true)
            create_file(FDR_T0_SC3_001)
          end
        end

        # Shell
        if (@bShell == true)
          if (@bT0_001 == true)
            create_shell(FDR_T0_001)
          end
          if (@bT0_002 == true)
            create_shell(FDR_T0_002)
          end
          if (@bT0_003 == true)
            create_shell(FDR_T0_003)
          end
          if (@bT0_004 == true)
            create_shell(FDR_T0_004)
          end
          if (@bT0_005 == true)
            create_shell(FDR_T0_005)
          end
          if (@bT0_006 == true)
            create_shell(FDR_T0_006)
          end
          if (@bT0_007 == true)
            create_shell(FDR_T0_007)
          end
          if (@bT0_008 == true)
            create_shell(FDR_T0_008)
          end
          if (@bT0_009 == true)
            create_shell(FDR_T0_009)
          end
          if (@bT0_010 == true)
            create_shell(FDR_T0_010)
          end
          if (@bT0_011 == true)
            create_shell(FDR_T0_011)
          end
          if (@bT0_012 == true)
            create_shell(FDR_T0_012)
          end
          if (@bT0_013 == true)
            create_shell(FDR_T0_013)
          end
          if (@bT0_014 == true)
            create_shell(FDR_T0_014)
          end
          if (@bT0_015 == true)
            create_shell(FDR_T0_015)
          end
          if (@bT0_SC3_001 == true)
            create_shell(FDR_T0_SC3_001)
          end
        end
      end

      # T1: basic check
      if (@bBasic == true)
        # Shell
        if (@bShell == true)
          create_shell(FDR_T1)
        end
      end

      # T2: attribute
      if (@bAttribute == true)
        # Write
        if (@bCreate == true)
          if (@bT2_001 == true)
            create_file(FDR_T2_001)
          end
          if (@bT2_002 == true)
            create_file(FDR_T2_002)
          end
        end

        # Shell
        if (@bShell == true)
          if (@bT2_001 == true)
            create_shell(FDR_T2_001)
          end
          if (@bT2_002 == true)
            create_shell(FDR_T2_002)
          end
          if (@bT2_003 == true)
            create_shell(FDR_T2_003)
          end
        end
      end

      # T3: object
      if (@bObject == true)
        # Shell
        if (@bShell == true)
          create_shell(FDR_T3)
        end
      end

      # T4: condition
      if (@bCondition == true)
        # Shell
        if (@bShell == true)
          create_shell(FDR_T4)
        end
      end

      # T5: scenario
      if (@bScenario == true)
        # Shell
        if (@bShell == true)
          create_shell(FDR_T5)
        end
      end

      # T6: property
      if (@bProperty == true)
        # Write
        if (@bCreate == true)
          if (@bT6_001 == true)
            create_file(FDR_T6_001)
          end
          if (@bT6_004 == true)
            create_file(FDR_T6_004)
          end
          if (@bT6_005 == true)
            create_file(FDR_T6_005)
          end
          if (@bT6_006 == true)
            create_file(FDR_T6_006)
          end
          if (@bT6_SC1_MC_001 == true)
            create_file(FDR_T6_SC1_MC_001)
          end
        end

        # Shell
        if (@bShell == true)
          if ((@bT6_001 == true) || (@bT6_004 == true) || (@bT6_005 == true) ||
              (@bT6_006 == true) || (@bT6_SC1_MC_001 == true))
            create_shell(FDR_T6)
          end
        end
      end

      # T7: multiple
      if (@bMultiple == true)
        # Shell
        if (@bShell == true)
          create_shell(FDR_T7)
        end
      end

      # 生成したファイルのリストをファイルに書込む
      if ((@bCreate == true) || (@bShell == true))
        make_file_list()
      end
    end

    #=================================================================
    # 概  要: 生成したファイルのリストをファイルとして保持する
    #=================================================================
    def make_file_list()
      aBeforeFile = []

      sBeforeDir = File.expand_path("")  # 現在の位置を保持する
      Dir.chdir(@sTECPath)

      # 既存のファイルのリストから情報を取得
      if (File.file?(MAKE_FILE_LIST) == true)
        sFileInfo = File.open(MAKE_FILE_LIST, "r").read()

        sFileInfo.each_line{|sLineInfo|
          aBeforeFile.push(sLineInfo.gsub("\n", ""))
        }
      end

      # ファイルリストを作成および更新する
      File.open(MAKE_FILE_LIST, "w"){|cIO|
        @aMakeFileList.concat(aBeforeFile)
        @aMakeFileList = @aMakeFileList.uniq.sort()

        @aMakeFileList.each{|sMakeFileList|
          cIO.puts(sMakeFileList)
        }
      }

      Dir.chdir(sBeforeDir)  # 元の位置に戻る
    end

    #=================================================================
    # 概  要: configureとマクロの属性が一致しているかをチェック
    #=================================================================
    def check_configure()
      sNotList   = ""
      aConfList  = []
      bTitleFlag = true

      # configureファイルの属性リスト
      @hConf.each_key{|key|
        aConfList.push(key)
      }
      @hMacro.each_key{|key|
        aConfList.push(key)
      }
      @hInvalid.each_key{|key|
        aConfList.push(key)
      }
      @hMcMacro.each_key{|key|
        aConfList.push(key)
      }

      if (@bEnvironment == true)
        # configureファイルの属性がツールのマクロに指定されているかをチェック
        aConfList.each{|key|
          if (CHK_CONFIGURE_TYPE.include?(key) == false)
            if (bTitleFlag == true)
              sNotList += "[File] #{File.expand_path(@sTECPath)}/test_data.rb\n"
              bTitleFlag = false
            end

            sNotList += "  [#{key}] Need to add attributes\n"
          end
        }

        bTitleFlag = true

        # 指定したツールのマクロがconfigureファイルにあるかをチェック
        CHK_CONFIGURE_TYPE.each_key{|key|
          if (aConfList.include?(key) == false)
            if (bTitleFlag == true)
              sNotList += "[File] #{File.expand_path(@sTECPath)}/test_data.rb\n"
              bTitleFlag = false
            end

            sNotList += "  [#{key}] Need to remove attributes\n"
          end
        }
      end

      # ツール内のconfigureのチェック
      aConfFile = []

      FDR_CONFIGURE_FILE.each{|sConForder|
        if (((@bScenario == true) && (sConForder == FDR_T5)) ||
            ((@bProperty == true) && (sConForder == FDR_T6)) ||
            ((@bMultiple == true) && (sConForder == FDR_T7)))
          sBeforeDir = File.expand_path("")  # 現在の位置を保持する

          Dir.chdir(@sTECPath)
          aFileList = catch_file_list(sConForder)
          Dir.chdir(sBeforeDir)  # 元の位置に戻る

          aFileList.each{|sFileList|
            if (sFileList.include?(CONFIGURE_FILE) == true)
              aConfFile.push(sFileList)
            end
          }

          aConfFile.each{|sConfList|
            hConfInfo = Kwalify::Yaml.load_file(sConfList)
            hConfList = hConfInfo.delete(CFG_MACRO)
            hConfList = hConfList.merge(hConfInfo)
            hConfId   = hConfInfo.delete(CFG_INVALID_ID)
            hConfList = hConfList.merge(hConfId)
            hConfMc   = hConfInfo.delete(CFG_MC_MACRO)
            hConfList = hConfList.merge(hConfMc)

            bTitleFlag = true

            aConfList.each{|key|
              if (hConfList.include?(key) == false)
                if (bTitleFlag == true)
                  sNotList += "[File] #{sConfList}\n"
                  bTitleFlag = false
                end

                sNotList += "  [#{key}] Need to add attributes\n"
              end
            }
          }

          aConfFile.each{|sConfList|
            hConfInfo = Kwalify::Yaml.load_file(sConfList)
            hConfList = hConfInfo.delete(CFG_MACRO)
            hConfList = hConfList.merge(hConfInfo)
            hConfId   = hConfInfo.delete(CFG_INVALID_ID)
            hConfList = hConfList.merge(hConfId)
            hConfMc   = hConfInfo.delete(CFG_MC_MACRO)
            hConfList = hConfList.merge(hConfMc)

            bTitleFlag = true

            hConfList.each_key{|key|
              if (aConfList.include?(key) == false)
                if (bTitleFlag == true)
                  sNotList += "[File] #{sConfList}\n"
                  bTitleFlag = false
                end

                sNotList += "  [#{key}] Need to remove attributes\n"
              end
            }
          }
      end
      }

      # ツールのマクロとconfigureファイルの内容が異なる場合，ファイルに出力する
      if (sNotList != "")
        if (File.file?(DO_NOT_ATTRIBUTE) == true)
          sNotInfo = File.open(DO_NOT_ATTRIBUTE, "r").read()

          if (sNotInfo.include?(sNotList) == true)
            sNotList = sNotInfo
          else
            sNotList = sNotInfo + sNotList
          end
        end

        File.open(DO_NOT_ATTRIBUTE, "w"){|cIO|
          sNotList.each_line{|sNotLine|
            cIO.puts(sNotLine)
          }
        }
      end
    end
=begin
    #=================================================================
    # 概  要: FMP関連のTESRYコードを取得する
    #=================================================================
    def search_FMP_file(aFileList)
      check_class(Array, aFileList)  # ファイルリスト

      aFMPFile = []

      aFileList.each{|sFileList|
        sFileInfo = File.open(sFileList, "r").read()

        catch(:FMPfile) {
          sFileInfo.each_line(){|sFileLine|
            @aFMPAttr.each{|sFMPAttr|
              if (sFileLine.include?(sFMPAttr) == true)
                aFMPFile.push(sFileList)
                throw(:FMPfile)
              end
            }
          }
        }
      }

      return aFMPFile  # [Array] FMP関連のTESRYコードの一覧
    end
=end
    #=================================================================
    # 概  要: エラーファイルを生成する
    #         ※ YAMLライブラリからYAMLファイルを作成するとarrayの
    #            インデントがずれる現象が起こるため，直接にYAMLファイル
    #            を作成するメソッド
    #=================================================================
    def prepare_file(ahErrorInfo)
      check_class([Hash, Array], ahErrorInfo)  # エラーデータ情報を持っているハッシュ

      cIO = File.open(@sFileName, "w")
      cIO.puts("# #{@sFileName.split("/")[-1]}")

      if (ahErrorInfo.is_a?(Hash) == true)
        ahErrorInfo.each{|sSection, xSectionInfo|

          if (xSectionInfo.is_a?(Hash) == true)
            cIO.puts("#{sSection}:")
            process_file_creation(cIO, xSectionInfo)
          elsif (xSectionInfo.is_a?(Array) == true)
            cIO.puts("#{sSection}:")
            process_file_creation(cIO, xSectionInfo)
          else
            cIO.puts("#{sSection}: #{xSectionInfo}")
          end
        }
      elsif (ahErrorInfo.is_a?(Array) == true)
        ahErrorInfo.each{|xError|
          if (xError.is_a?(Hash) == true)
            bFlag = false

            xError.each{|sSection, xSectionInfo|
              if (bFlag == false)
                sArraySym = "- "
                bFlag = true
              else
                sArraySym = "  "
              end

              if (xSectionInfo.is_a?(Hash) == true)
                sIndent = "  "
                cIO.puts("#{sArraySym}#{sSection}:")
                process_file_creation(cIO, xSectionInfo, sIndent)
              elsif (xSectionInfo.is_a?(Array) == true)
                cIO.puts("#{sArraySym}#{sSection}:")
                process_file_creation(cIO, xSectionInfo)
              else
                cIO.puts("#{sArraySym}#{sSection}: #{xSectionInfo}")
              end
            }
          else
            cIO.puts("- #{xError}")
          end
        }
      end

      puts("  #{@sFileName}")
    end

    #=================================================================
    # 概  要: エラーファイルの情報をファイルに記入する．
    #         ※ YAMLライブラリからYAMLファイルを作成するとarrayの
    #            インデントがずれる現象が起こるため，直接にYAMLファイル
    #            を作成するメソッド
    #=================================================================
    def process_file_creation(cIO, ahYaml, sIndent = "", bArrayFlag = false)
      check_class(IO, cIO)           # ファイル入出力IO
      check_class(String, sIndent)   # YAMLインデント
      check_class(Bool, bArrayFlag)  # Arrayを区別するためのフラグ
      check_class([Hash, Array, String], ahYaml)  # エラーデータ情報を持っているハッシュ

      sIndent += "  "

      if (ahYaml.is_a?(Hash) == true)
        ahYaml.each{|sYamlId, ahYamlInfo|
          if (ahYamlInfo.is_a?(Hash) == true)
            if (bArrayFlag == true)
              cIO.puts("#{" " * (sIndent.size() - 2)}- #{sYamlId}:")
              bArrayFlag = false
            else
              cIO.puts("#{sIndent}#{sYamlId}:")
            end

            process_file_creation(cIO, ahYamlInfo, sIndent)
          elsif (ahYamlInfo.is_a?(Array) == true)
            if (bArrayFlag == true)
              cIO.puts("#{" " * (sIndent.size() - 2)}- #{sYamlId}:")
              bArrayFlag = false
            else
              cIO.puts("#{sIndent}#{sYamlId}:")
            end

            process_file_creation(cIO, ahYamlInfo, sIndent, true)
          else
            if (bArrayFlag == true)
              cIO.puts("#{" " * (sIndent.size() - 2)}- #{sYamlId}: #{ahYamlInfo}")
              bArrayFlag = false
            else
              cIO.puts("#{sIndent}#{sYamlId}: #{ahYamlInfo}")
            end
          end
        }
      elsif (ahYaml.is_a?(Array) == true)
        ahYaml.each{|ahYamlInfo|
          process_file_creation(cIO, ahYamlInfo, sIndent, true)
        }
      elsif (ahYaml.is_a?(String) == true)
        if (bArrayFlag == true)
          cIO.puts("#{" " * (sIndent.size() - 2)}- #{ahYaml}")
        end
      end
    end

    #=================================================================
    # 概  要: 項目ごとにエラーファイルを生成する
    #=================================================================
    def create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      puts("[#{sDirectory}] Error-file Creating..")
      sBeforeDir = File.expand_path("")  # 現在の位置を保持する
      Dir.chdir(@sTECPath)

      case sDirectory
      when FDR_T0_001
        prepare_directory(FDR_T0_001)
        T0_001_create_file(FDR_T0_001)

      when FDR_T0_002
        prepare_directory(FDR_T0_002)
        T0_002_create_file(FDR_T0_002)

      when FDR_T0_003
        prepare_directory(FDR_T0_003)
        T0_003_create_file(FDR_T0_003)

      when FDR_T0_004
        prepare_directory(FDR_T0_004)
        T0_004_create_file(FDR_T0_004)

      when FDR_T0_005
        prepare_directory(FDR_T0_005)
        T0_005_create_file(FDR_T0_005)

      when FDR_T0_006
        prepare_directory(FDR_T0_006)
        T0_006_create_file(FDR_T0_006)

      when FDR_T0_007
        prepare_directory(FDR_T0_007)
        T0_007_create_file(FDR_T0_007)

      when FDR_T0_008
        prepare_directory(FDR_T0_008)
        T0_008_create_file(FDR_T0_008)

      when FDR_T0_009
        prepare_directory(FDR_T0_009)
        T0_009_create_file(FDR_T0_009)

      when FDR_T0_010
        prepare_directory(FDR_T0_010)
        T0_010_create_file(FDR_T0_010)

      when FDR_T0_011
        prepare_directory(FDR_T0_011)
        T0_011_create_file(FDR_T0_011)

      when FDR_T0_012
        prepare_directory(FDR_T0_012)
        T0_012_create_file(FDR_T0_012)

      when FDR_T0_013
        prepare_directory(FDR_T0_013)
        T0_013_create_file(FDR_T0_013)

      when FDR_T0_014
        prepare_directory(FDR_T0_014)
        T0_014_create_file(FDR_T0_014)

      when FDR_T0_015
        prepare_directory(FDR_T0_015)
        T0_015_create_file(FDR_T0_015)

      when FDR_T0_SC3_001
        prepare_directory(FDR_T0_SC3_001)
        T0_SC3_001_create_file(FDR_T0_SC3_001)

      when FDR_T2_001
        T2_001_create_file(FDR_T2_001)

      when FDR_T2_002
        T2_002_create_file(FDR_T2_002)

      when FDR_T6_001
        T6_create_file(FDR_T6_001, "sc")

      when FDR_T6_004
        T6_004_create_file(FDR_T6_004)

      when FDR_T6_005
        T6_005_create_file(FDR_T6_005)

      when FDR_T6_006
        T6_006_create_file(FDR_T6_006)

      when FDR_T6_SC1_MC_001
       T6_SC1_MC_001_create_file(FDR_T6_SC1_MC_001)
      end

      Dir.chdir(sBeforeDir)  # 元の位置に戻る
    end

    #=================================================================
    # 概  要: シェルファイル生成の前に生成に必要な情報を整える
    #=================================================================
    def create_shell(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      return if (File.directory?(File.expand_path("#{@sTECPath}/#{sDirectory}")) == false)

      puts("[#{sDirectory}] Shell Creating..")

      aFileList  = []
      sBeforeDir = File.expand_path("")  # 現在の位置を保持する

      Dir.chdir(@sTECPath)
      aFileList = catch_file_list(sDirectory)
      Dir.chdir(sBeforeDir)  # 元の位置に戻る

      case sDirectory
      when FDR_T0_001, FDR_T0_002, FDR_T0_003, FDR_T0_004, FDR_T0_005,
           FDR_T0_006, FDR_T0_007, FDR_T0_008, FDR_T0_009, FDR_T0_010,
           FDR_T0_011, FDR_T0_012, FDR_T0_013, FDR_T0_014, FDR_T0_015,
           FDR_T0_SC3_001
        T0_create_shell(sDirectory, aFileList)

      when FDR_T1
        T1_create_shell(sDirectory, aFileList)

      when FDR_T2_001, FDR_T2_002, FDR_T2_003
        T2_create_shell(sDirectory, aFileList)

      when FDR_T3
        T3_create_shell(sDirectory, aFileList)

      when FDR_T4
        T4_create_shell(sDirectory, aFileList)

      when FDR_T5
        T5_create_shell(sDirectory, aFileList)

      when FDR_T6
        T6_create_shell(sDirectory, aFileList)

      when FDR_T7
        T7_create_shell(sDirectory, aFileList)

      end

      puts("  #{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: ファイルリストを作成する
    #=================================================================
    def catch_file_list(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      sBeforeDir = File.expand_path("")  # 現在の位置を保持する
      Dir.chdir(sDirectory)

      aDirList  = []
      aFileList = []

      # ファイルとディレクトリを取得する
      Dir.entries(File.expand_path("")).each{|sInfo|
        next if (sInfo == ".")
        next if (sInfo == "..")
        next if (sInfo == ".svn")

        if (File.ftype(sInfo) == "directory")
          aDirList.push(sInfo)
        elsif ((File.ftype(sInfo) == "file") && (sInfo.include?(".yaml") == true))
          aFileList.push("#{File.expand_path("")}/#{sInfo}")
        end
      }

      # 下位のディレクトリがある場合はその下位のディレクトリも取得する
      aDirList.each{|sDirList|
        aFileList.concat(catch_file_list(sDirList))
      }

      # ファイルをまとめる
      aFileList = aFileList.uniq.sort()
      Dir.chdir(sBeforeDir)  # 元の位置に戻る

      return aFileList  # [Array] ファイルのリスト
    end

    #=================================================================
    # 概  要: ディレクトリを生成する
    #=================================================================
    def prepare_directory(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      sDirTemp = ""

      sDirectory.split("/").each{|sDir|
        sDirTemp += "#{sDir}/"

        if (File.directory?(sDirTemp) == false)
          Dir.mkdir(sDirTemp)
        end
      }
    end

    #=================================================================
    # 概  要: 生成したディレクトリを削除する
    #=================================================================
    def remove_directory(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      if (File.directory?(File.expand_path(sDirectory)) == false)
        return
      end

      aDirList  = []

      # ディレクトリを取得する
      Dir.entries(File.expand_path(sDirectory)).each{|sInfo|
        next if (sInfo == ".")
        next if (sInfo == "..")
        next if (sInfo == ".svn")

        if (File.ftype("#{sDirectory}/#{sInfo}") == "directory")
          aDirList.push(sInfo)
        end
      }

      # 下位のディレクトリがある場合はその下位のディレクトリも取得する
      aDirList.each{|sDirList|
        Dir.chdir(sDirectory)
        remove_directory(sDirList)
        Dir.chdir("../")
      }

      # すべてのディレクトリを削除する
      begin
        Dir.rmdir(sDirectory)
      rescue Errno::ENOTEMPTY, Errno::EBUSY
        # ファイルが残っている場合はエラーしない
      end
    end

    #=================================================================
    # 概  要: エラーファイル，シェルファイル，ディレクトリを削除する
    #=================================================================
    def remove()
      puts("AKTF Error-checker Removing..")

      sBeforeDir = File.expand_path("")  # 現在の位置を保持する
      Dir.chdir(@sTECPath)

      # 生成したファイルリストから情報を取得する
      if (File.file?(MAKE_FILE_LIST) == true)
        sFileInfo = File.open(MAKE_FILE_LIST, "r").read()

        # ファイル削除
        sFileInfo.each_line{|sLineInfo|
          sLineInfo = sLineInfo.gsub("\n", "")
          puts("  #{sLineInfo}")

          begin
            File.delete(sLineInfo)
          rescue Errno::ENOENT
            # ファイルがない場合エラーにしない
          end
        }
      end

      # ディレクトリ削除
      DEL_FOLDER_LIST.each{|sDirectory|
        remove_directory(sDirectory)
      }

      # make_file_listファイル削除
      begin
        File.delete(MAKE_FILE_LIST)
      rescue Errno::ENOENT
        # ファイル削除時，ファイルがない場合エラーにしない
      end

      # do_not_attributeファイル削除
      begin
        File.delete(DO_NOT_ATTRIBUTE)
      rescue Errno::ENOENT
        # ファイル削除時，ファイルがない場合エラーにしない
      end

      Dir.chdir(sBeforeDir)  # 元の位置に戻る
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T0_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array, aFileList)    # ファイルリスト

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory.split("/")[-1]}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
          cIO.puts("echo [File] #{sFileList}")
          if (@bSC3 == true)
            if (sFileList.include?("scalability_class"))
              cIO.puts("#{AKTG_PATH} #{@sCore} #{@sLevel} #{ANY_T0_TESRY_SC3} -c #{sFileList}")
            else
              cIO.puts("#{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{ANY_T0_TESRY_SC3} -c #{sFileList}")
            end
          else
            if (sFileList.include?("scalability_class"))
              cIO.puts("#{AKTG_PATH} #{@sCore} #{@sLevel} #{ANY_T0_TESRY_SC1} -c #{sFileList}")
            else
              cIO.puts("#{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{ANY_T0_TESRY_SC1} -c #{sFileList}")
            end
          end
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: T0のエラーファイルの内容を生成する
    #=================================================================
    def T0_convert_data(sDirectory, sKey, xType)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(String, sKey)        # 置換用マクロのキー
      check_class([Class, Integer, Float, String, Hash], xType)  # 置換用マクロの値

      hConfigureInfo = {}

      if (xType.is_a?(Hash) == true)
        xType.each{|typeKey, typeVal|
          hConfigureInfo.store(typeKey, typeVal)
        }

        CVT_DEPEND_NAME.each{|dependKey, dependVal|
          if (xType == dependVal)
            @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{sKey}-depend_#{dependKey}.yaml"
            @aMakeFileList.push(@sFileName)
          end
        }
      else
        hConfigureInfo = {sKey => CVT_CONFIGURE_VALUE[xType]}
        @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{sKey}-#{CVT_CONFIGURE_NAME[xType]}.yaml"
        @aMakeFileList.push(@sFileName)
      end

      return hConfigureInfo  # [Hash]正しいデータをエラーデータに置換したハッシュ
    end

=begin
    #=================================================================
    # 概  要: T0_001のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_001_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      ERROR_ATTRIBUTE.each{|key, val|
        hConfInfo = {key => val}
        @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{key}.yaml"
        @aMakeFileList.push(@sFileName)
        hErrorInfo = @hConfigure.merge(hConfInfo)
        prepare_file(hErrorInfo)
      }
    end
=end

    #=================================================================
    # 概  要: T0_001のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_001_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      hDeleteInfo = {}

      GRP_CFG_NECESSARY_KEYS.each{|val|
        @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{val}-delete.yaml"
        @aMakeFileList.push(@sFileName)

        hDeleteInfo = Marshal.load(Marshal.dump(@hConfigure))
        hDeleteInfo.delete(val)
        prepare_file(hDeleteInfo)

        if (val == CFG_HARDWARE_COUNTER_PARAM)
          GRP_CFG_HWCNT_NECESSARY_KEYS.each{|sParam|
            @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{sParam}-delete.yaml"
            @aMakeFileList.push(@sFileName)

            hDeleteInfo = Marshal.load(Marshal.dump(@hConfigure))
            hDeleteInfo[CFG_HARDWARE_COUNTER_PARAM].delete(sParam)
            prepare_file(hDeleteInfo)
          }
        end
      }
    end

    #=================================================================
    # 概  要: T0_002のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_002_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      @hConf.each_key{|key|
        next if (CHK_CONFIGURE_TYPE[key].nil? == true)

        CHK_CONFIGURE_TYPE[key].each{|type|
          hConfInfo  = T0_convert_data(sDirectory, key, type)
          hErrorInfo = @hConfigure.merge(hConfInfo)
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_003のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_003_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      @hConf.each{|key, val|
        next if (CHK_CONFIGURE_VALUE[key].nil? == true)

        CHK_CONFIGURE_VALUE[key].each{|type|
          hConfInfo  = T0_convert_data(sDirectory, key, type)
          hErrorInfo = @hConfigure.merge(hConfInfo)
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_004のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_004_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      aArrayInfo = []
      @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{CONFIGURE_FILE}.yaml"
      @aMakeFileList.push(@sFileName)

      aArrayInfo.push(@hConfigure)
      prepare_file(aArrayInfo)
    end

    #=================================================================
    # 概  要: T0_005のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_005_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{CONFIGURE_FILE}.yaml"
      @aMakeFileList.push(@sFileName)

      hConfInfo = @hConf.merge(ERROR_CONFIGURE_ENTRY)
      hErrorInfo = @hConfigure.merge(hConfInfo)
      prepare_file(hErrorInfo)
      
    end

    #=================================================================
    # 概  要: T0_006のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_006_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      hDeleteMacro = {}
      hDeleteId = {}
      hDeleteMcMacro = {}
      GRP_CFG_NECESSARY_MACRO.each{|val|
        @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{val}-delete.yaml"
        @aMakeFileList.push(@sFileName)

        hDeleteMacro = Marshal.load(Marshal.dump(@hMacro))
        hDeleteId = Marshal.load(Marshal.dump(@hInvalid))
        hDeleteMcMacro = Marshal.load(Marshal.dump(@hMcMacro))
        if (hDeleteMacro.has_key?(val))
          hDeleteMacro.delete(val)
          hDeleteMacro = {"macro" => hDeleteMacro}
          hDeleteMacro = @hConfigure.merge(hDeleteMacro)
          prepare_file(hDeleteMacro)
        elsif (hDeleteId.has_key?(val))
          hDeleteId.delete(val)
          hDeleteId = {"invalid_id" => hDeleteId}
          hDeleteId = @hConfigure.merge(hDeleteId)
          prepare_file(hDeleteId)
        elsif (hDeleteMcMacro.has_key?(val))
          hDeleteMcMacro.delete(val)
          hDeleteMcMacro = {"mc_macro" => hDeleteMcMacro}
          hDeleteMcMacro = @hConfigure.merge(hDeleteMcMacro)
          prepare_file(hDeleteMcMacro)
        end
      }
    end

    #=================================================================
    # 概  要: T0_007のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_007_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      hMacroInfo = {}
      @hMacro.each{|key, val|
        next if (CHK_CONFIGURE_TYPE[key].nil? == true)

        CHK_CONFIGURE_TYPE[key].each{|type|
          hMacroInfo = T0_convert_data(sDirectory, key, type)
          hMacroInfo = {"macro" => @hMacro.merge(hMacroInfo)}
          hErrorInfo = @hConfigure.merge(hMacroInfo)
          prepare_file(hErrorInfo)
        }
      }

      hMacroInfo.clear
      @hInvalid.each{|key, val|
        next if (CHK_CONFIGURE_TYPE[key].nil? == true)

        CHK_CONFIGURE_TYPE[key].each{|type|
          hMacroInfo = T0_convert_data(sDirectory, key, type)
          hMacroInfo = {"invalid_id" => @hInvalid.merge(hMacroInfo)}
          hErrorInfo = @hConfigure.merge(hMacroInfo)
          prepare_file(hErrorInfo)
        }
      }

      hMacroInfo.clear
      @hMcMacro.each{|key, val|
        next if (CHK_CONFIGURE_TYPE[key].nil? == true)

        CHK_CONFIGURE_TYPE[key].each{|type|
          hMacroInfo = T0_convert_data(sDirectory, key, type)
          hMacroInfo = {"mc_macro" => @hMcMacro.merge(hMacroInfo)}
          hErrorInfo = @hConfigure.merge(hMacroInfo)
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_008のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_008_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      hMacroInfo = {}
      @hMacro.each{|key, val|
        next if (CHK_CONFIGURE_VALUE[key].nil? == true)

        CHK_CONFIGURE_VALUE[key].each{|type|
          hMacroInfo = T0_convert_data(sDirectory, key, type)
          hMacroInfo = {"macro" => @hMacro.merge(hMacroInfo)}
          hErrorInfo = @hConfigure.merge(hMacroInfo)
          prepare_file(hErrorInfo)
        }
      }

      # 不正IDマクロは，配列のためT0_008はチェックしない

      hMacroInfo.clear
      @hMcMacro.each{|key, val|
        next if (CHK_CONFIGURE_VALUE[key].nil? == true)

        CHK_CONFIGURE_VALUE[key].each{|type|
          hMacroInfo = T0_convert_data(sDirectory, key, type)
          hMacroInfo = {"mc_macro" => @hMcMacro.merge(hMacroInfo)}
          hErrorInfo = @hConfigure.merge(hMacroInfo)
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_009のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_009_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      aArrayInfo = []
      # Macro
      @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{CONFIGURE_FILE}.yaml"
      @aMakeFileList.push(@sFileName)

      aArrayInfo.push(@hMacro)
      hArrayInfo = {"macro" => aArrayInfo}
      hArrayInfo = @hConfigure.merge(hArrayInfo)
      prepare_file(hArrayInfo)

      # invalid_id
      aArrayInfo.clear
      @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{CONFIGURE_FILE}_2.yaml"
      @aMakeFileList.push(@sFileName)

      aArrayInfo.push(@hInvalid)
      hArrayInfo = {"invalid_id" => aArrayInfo}
      hArrayInfo = @hConfigure.merge(hArrayInfo)
      prepare_file(hArrayInfo)

      # McMacro
      aArrayInfo.clear
      @sFileName = "#{File.expand_path(sDirectory)}/#{sDirectory.split("/")[-1]}-#{CONFIGURE_FILE}_3.yaml"
      @aMakeFileList.push(@sFileName)

      aArrayInfo.push(@hMcMacro)
      hArrayInfo = {"mc_macro" => aArrayInfo}
      hArrayInfo = @hConfigure.merge(hArrayInfo)
      prepare_file(hArrayInfo)

    end

    #=================================================================
    # 概  要: T0_010のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_010_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      GRP_CFG_HWCNT_NECESSARY_KEYS.each{|sParam|
        CHK_HARDWARE_COUNTER_PARAM_TYPE[sParam].each{|stype|
          hConfInfo  = T0_convert_data(sDirectory, sParam, stype)
          hHwcntInfo = @hConfigure[CFG_HARDWARE_COUNTER_PARAM].merge(hConfInfo)
          hErrorInfo[CFG_HARDWARE_COUNTER_PARAM] = hHwcntInfo
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_011のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_011_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      GRP_CFG_HWCNT_NECESSARY_KEYS.each{|sParam|
        next if (CHK_HARDWARE_COUNTER_PARAM_VALUE[sParam].nil? == true)

        CHK_HARDWARE_COUNTER_PARAM_VALUE[sParam].each{|stype|
          hConfInfo  = T0_convert_data(sDirectory, sParam, stype)
          hHwcntInfo = @hConfigure[CFG_HARDWARE_COUNTER_PARAM].merge(hConfInfo)
          hErrorInfo[CFG_HARDWARE_COUNTER_PARAM] = hHwcntInfo
          prepare_file(hErrorInfo)
        }
      }
    end

    #=================================================================
    # 概  要: T0_012のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_012_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      CHK_HARDWARE_COUNTER_INTNO["intno"].each{|stype|
        hConfInfo  = T0_convert_data(sDirectory, "intno", stype)
        hHwcntInfo = @hConfigure[CFG_HARDWARE_COUNTER_PARAM].merge(hConfInfo)
        hErrorInfo[CFG_HARDWARE_COUNTER_PARAM] = hHwcntInfo
        prepare_file(hErrorInfo)
      }
    end

    #=================================================================
    # 概  要: T0_013のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_013_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      hConfInfo  = T0_convert_data(sDirectory, "support_enadis_interrupt_source", FalseClass)
      hErrorInfo = @hConfigure.merge(hConfInfo)

      hConfInfo  = T0_convert_data(sDirectory, "intatr", "AK_DISABLE")
      hHwcntInfo = @hConfigure[CFG_HARDWARE_COUNTER_PARAM].merge(hConfInfo)

      hErrorInfo[CFG_HARDWARE_COUNTER_PARAM] = hHwcntInfo
      prepare_file(hErrorInfo)
    end

    #=================================================================
    # 概  要: T0_014のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_014_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      hConfInfo  = T0_convert_data(sDirectory, "use_multi_core", FalseClass)
      hErrorInfo = @hConfigure.merge(hConfInfo)

      hConfInfo  = T0_convert_data(sDirectory, "core_num", ANY_MULTI_CORE_NUM)
      hErrorInfo = hErrorInfo.merge(hConfInfo)

      prepare_file(hErrorInfo)
    end

    #=================================================================
    # 概  要: T0_015のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T0_015_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      hConfInfo  = T0_convert_data(sDirectory, "version", "0.0.0")
      hErrorInfo = @hConfigure.merge(hConfInfo)

      prepare_file(hErrorInfo)
    end

    #=====================================================================
    # 概  要: T0_SC3_001のエラーファイルを生成するために必要な情報を整える
    #=====================================================================
    def T0_SC3_001_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = @hConfigure.dup

      hConfInfo  = T0_convert_data(sDirectory, "return_status", "STANDARD")
      hErrorInfo = @hConfigure.merge(hConfInfo)
      prepare_file(hErrorInfo)
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T1_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array, aFileList)    # ファイルリスト

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
          cIO.puts("echo [File] #{sFileList}")
          cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: T2のエラーファイルの内容を生成するために必要な情報を
    #         整える
    #=================================================================
    def T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
      check_class(String, sDirectory)   # 対象ディレクトリ
      check_class(String, sObjectType)  # オブジェクトタイプ
      check_class(String, sAttribute)   # 属性
      check_class(Array,  aAttrInfo)    # エラー情報

      case sObjectType
      when TSR_OBJ_TASK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_TASK_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_TASK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_TASK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_TASK, sDirectory)

      when TSR_OBJ_C1ISR
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C1ISR_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C1ISR_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C1ISR)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_C1ISR, sDirectory)

      when TSR_OBJ_C2ISR
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C2ISR_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C2ISR_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_C2ISR)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_C2ISR, sDirectory)

      when TSR_OBJ_STARTUP_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_STARTUP_HOOK_SC3)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_STARTUP_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_STARTUP_HOOK, sDirectory)

      when TSR_OBJ_SHUTDOWN_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SHUTDOWN_HOOK_SC3)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SHUTDOWN_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_SHUTDOWN_HOOK, sDirectory)

      when TSR_OBJ_PRETASK_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PRETASK_HOOK_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PRETASK_HOOK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PRETASK_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_PRETASK_HOOK, sDirectory)

      when TSR_OBJ_POSTTASK_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_POSTTASK_HOOK_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_POSTTASK_HOOK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_POSTTASK_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_POSTTASK_HOOK, sDirectory)

      when TSR_OBJ_ERROR_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ERROR_HOOK_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ERROR_HOOK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ERROR_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_ERROR_HOOK, sDirectory)

      when TSR_OBJ_PROTECTION_HOOK
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PROTECTION_HOOK_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PROTECTION_HOOK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_PROTECTION_HOOK)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_PROTECTION_HOOK, sDirectory)

      when TSR_OBJ_ALARM_CALL_BACK
        hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ALARM_CALL_BACK)
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_ALARM_CALL_BACK, sDirectory)

      when TSR_OBJ_ALARM
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ALARM_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ALARM_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ALARM)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_ALARM, sDirectory)

      when TSR_OBJ_RESOURCE
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_RESOURCE_SC3)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_RESOURCE)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_RESOURCE, sDirectory)

      when TSR_OBJ_EVENT
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_EVENT_SC3)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_EVENT)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_EVENT, sDirectory)

      when TSR_OBJ_COUNTER
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_COUNTER_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_COUNTER_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_COUNTER)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_COUNTER, sDirectory)

      when TSR_OBJ_INT_STATE
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_INT_STATE_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_INT_STATE_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_INT_STATE)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_INT_STATE, sDirectory)

      when TSR_OBJ_SCHEDULE_TABLE
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SCHEDULE_TABLE_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SCHEDULE_TABLE_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SCHEDULE_TABLE)
        end
        if ((sAttribute == "offset") || (sAttribute == TSR_PRM_ACTTSK) || (sAttribute == TSR_PRM_SETEVT))
          T2_convert_expoint_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_SCHEDULE_TABLE, sDirectory)
        else
          T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_SCHEDULE_TABLE, sDirectory)
        end

      when TSR_OBJ_STARTUP_HOOK_OSAP
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_STARTUP_HOOK_OSAP_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_STARTUP_HOOK_OSAP_SC1_MC)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_STARTUP_HOOK_OSAP, sDirectory)

      when TSR_OBJ_SHUTDOWN_HOOK_OSAP
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SHUTDOWN_HOOK_OSAP_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SHUTDOWN_HOOK_OSAP_SC1_MC)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_SHUTDOWN_HOOK_OSAP, sDirectory)

      when TSR_OBJ_ERROR_HOOK_OSAP
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ERROR_HOOK_OSAP_SC3)
        elsif (@bSC1 == true && @bMC == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_ERROR_HOOK_OSAP_SC1_MC)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_ERROR_HOOK_OSAP, sDirectory)

      when TSR_OBJ_TRUSTED_FUNCTION
        if (@bSC3 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_TRUSTED_FUNCTION_SC3)
          T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_TRUSTED_FUNCTION, sDirectory)
        else
          # SC1は対象外
          return
        end

      when TSR_OBJ_SPINLOCK
        if (@bSC1 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SPINLOCK_SC1_MC)
        else
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_SPINLOCK_SC3_MC)
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_SPINLOCK, sDirectory)

      when TSR_OBJ_IOC
        if (@bSC1 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_IOC_SC1_MC)
        else
          ### ToDo: SC3-MCは未対応
          return
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_IOC, sDirectory)

      when TSR_OBJ_IOC_SENDER
        if (@bSC1 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_IOC_SC1_MC)
        else
          ### ToDo: SC3-MCは未対応
          return
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_IOC_SENDER, sDirectory)

      when TSR_OBJ_IOC_RECEIVER
        if (@bSC1 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_IOC_SC1_MC)
        else
          ### ToDo: SC3-MCは未対応
          return
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_IOC_RECEIVER, sDirectory)

      when TSR_OBJ_IOC_DATA
        if (@bSC1 == true)
          hTesryTask = Kwalify::Yaml.load_file(ANY_T2_TESRY_IOC_SC1_MC)
        else
          ### ToDo: SC3-MCは未対応
          return
        end
        T2_convert_object_data(hTesryTask, sAttribute, aAttrInfo, TSR_OBJ_IOC_DATA, sDirectory)

      when TSR_LBL_DO
        if (@bSC3 == true)
          hTesryDo = Kwalify::Yaml.load_file(ANY_T2_TESRY_DO_SC3)
        else
          hTesryDo = Kwalify::Yaml.load_file(ANY_T2_TESRY_DO)
        end
        T2_convert_do_data(hTesryDo, sAttribute, aAttrInfo, sObjectType, sDirectory)

      end
    end

    #=================================================================
    # 概  要: T2のエラーファイルの内容を生成する
    #=================================================================
    def T2_convert_object_data(hTesryObject, sAttribute, aAttrInfo, sObjectType, sDirectory)
      check_class(Hash,   hTesryObject)  # TESRYコードの情報
      check_class(String, sAttribute)    # 属性
      check_class(Array,  aAttrInfo)     # エラー情報
      check_class(String, sObjectType)   # オブジェクトタイプ
      check_class(String, sDirectory)    # 対象ディレクトリ

      bTestFlag = true

      hTesryObject.each{|sSection, hSectionInfo|
        hSectionInfo.each{|sCondition, hConditionInfo|
          next if (sCondition.include?(TSR_LBL_DO))
          next if (sCondition == TSR_LBL_PROPERTY)
          next if (hConditionInfo.nil?())

          hConditionInfo.each{|sObject, hObecjtInfo|
            if (hObecjtInfo[TSR_PRM_TYPE] == sObjectType)

              aAttrInfo.each{|sConvert|
                hObjectTemp = Hash.new
                hObjectTemp = Marshal.load(Marshal.dump(hTesryObject))

                if (bTestFlag == true)
                  hObjectTemp[sSection][sCondition][sObject][sAttribute] = CVT_ATTRIBUTE_VALUE[sConvert]
                  if ((sAttribute == TSR_PRM_VAR) && (sConvert == Hash))
                    hObjectTemp[sSection][sCondition][sObject][sAttribute]["key"] = CVT_ATTRIBUTE_VALUE[Array]
                    @sFileName = "#{File.expand_path(sDirectory)}/#{sObjectType.downcase()}/#{sDirectory.split("/")[-1]}_#{sObjectType.downcase()}-#{sAttribute}-#{CVT_ATTRIBUTE_NAME[sConvert]}-#{CVT_ATTRIBUTE_NAME[Array]}.yaml"
                  else
                    @sFileName = "#{File.expand_path(sDirectory)}/#{sObjectType.downcase()}/#{sDirectory.split("/")[-1]}_#{sObjectType.downcase()}-#{sAttribute}-#{CVT_ATTRIBUTE_NAME[sConvert]}.yaml"
                  end
                  @aMakeFileList.push(@sFileName)
                  prepare_file(hObjectTemp)
                end
              }
              bTestFlag = false
            end
          }
        }
      }
    end

    #=================================================================
    # 概  要: doに該当するT2のエラーファイルの内容を生成する
    #=================================================================
    def T2_convert_do_data(hTesryDo, sAttribute, aAttrInfo, sObjectType, sDirectory)
      check_class(Hash,   hTesryDo)     # doの情報
      check_class(String, sAttribute)   # 属性
      check_class(Array,  aAttrInfo)    # エラー情報
      check_class(String, sObjectType)  # オブジェクトタイプ
      check_class(String, sDirectory)   # 対象ディレクトリ

      hTesryDo.each{|sSection, hSectionInfo|
        hSectionInfo[TSR_LBL_DO].each{|doKey, doVal|
          aAttrInfo.each{|sConvert|
            hDoTemp = Marshal.load(Marshal.dump(hTesryDo))
            hDoTemp[sSection][TSR_LBL_DO][sAttribute] = CVT_ATTRIBUTE_VALUE[sConvert]

            @sFileName = "#{File.expand_path(sDirectory)}/#{sObjectType.downcase()}/#{sDirectory.split("/")[-1]}_#{TSR_LBL_DO}-#{sAttribute}-#{CVT_ATTRIBUTE_NAME[sConvert]}.yaml"
            @aMakeFileList.push(@sFileName)
            prepare_file(hDoTemp)
          }
        }
      }
    end

    #=================================================================
    # 概  要: expointに該当するT2のエラーファイルの内容を生成する
    #=================================================================
    def T2_convert_expoint_data(hTesryObject, sAttribute, aAttrInfo, sObjectType, sDirectory)
      check_class(Hash,   hTesryObject)  # TESRYコードの情報
      check_class(String, sAttribute)    # 属性
      check_class(Array,  aAttrInfo)     # エラー情報
      check_class(String, sObjectType)   # オブジェクトタイプ
      check_class(String, sDirectory)    # 対象ディレクトリ

     bTestFlag = true

      hTesryObject.each{|sSection, hSectionInfo|
        hSectionInfo.each{|sCondition, hConditionInfo|
          next if (sCondition.include?(TSR_LBL_DO))
          next if (sCondition == TSR_LBL_PROPERTY)
          next if (hConditionInfo.nil?() == true)

          hConditionInfo.each{|sObject, hObecjtInfo|
            if (hObecjtInfo[TSR_PRM_TYPE] == sObjectType)

              aAttrInfo.each{|sConvert|
                hObjectTemp = Hash.new
                hObjectTemp = Marshal.load(Marshal.dump(hTesryObject))

                hObjectTemp[sSection][sCondition][sObject][TSR_PRM_EXPOINT].each {|key, val|
                  if (bTestFlag == true)
                    if (sAttribute == "offset")
                      hObjectTemp[sSection][sCondition][sObject][TSR_PRM_EXPOINT][key] = CVT_ATTRIBUTE_VALUE[sConvert]
                      @sFileName = "#{File.expand_path(sDirectory)}/#{sObjectType.downcase()}/#{sDirectory.split("/")[-1]}_#{sObjectType.downcase()}-#{sAttribute}-#{CVT_ATTRIBUTE_NAME[sConvert]}.yaml"
                      @aMakeFileList.push(@sFileName)
                      prepare_file(hObjectTemp)
                    elsif (val[sAttribute] != nil)
                      val[sAttribute] = CVT_ATTRIBUTE_VALUE[sConvert]
                      @sFileName = "#{File.expand_path(sDirectory)}/#{sObjectType.downcase()}/#{sDirectory.split("/")[-1]}_#{sObjectType.downcase()}-#{sAttribute}-#{CVT_ATTRIBUTE_NAME[sConvert]}.yaml"
                      @aMakeFileList.push(@sFileName)
                      prepare_file(hObjectTemp)
                    end
                  end
                }
              }
             bTestFlag = false
            end
          }
        }
      }
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T2_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array, aFileList)    # ファイルリスト

#     aFMPFile = search_FMP_file(aFileList)

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory.split("/")[-1]}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
#         next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))
          cIO.puts("echo [File] #{sFileList}")
          cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: T2_001のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T2_001_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      CHK_ATTRIBUTE_TYPE.each{|sObjectType, hAttribute|
        if ((@bSC3 == true) && (sObjectType == TSR_OBJ_ALARM_CALL_BACK))
          # SC3の場合，アラームコールバックはない
          next
        end
        prepare_directory("#{FDR_T2_001}/#{sObjectType.downcase()}")
        puts("[#{FDR_T2_001}/#{sObjectType.downcase()}] Error-file Creating..")

        hAttribute.each{|sAttribute, aAttrInfo|
          T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
        }
      }
      if (@bSC3 == true)
        CHK_ATTRIBUTE_TYPE_SC3.each{|sObjectType, hAttribute|
          if (!File.exists?("#{FDR_T2_001}/#{sObjectType.downcase()}"))
           puts("[#{FDR_T2_001}/#{sObjectType.downcase()}] Error-file Creating..")
           prepare_directory("#{FDR_T2_001}/#{sObjectType.downcase()}")
          end

          hAttribute.each{|sAttribute, aAttrInfo|
            T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
          }
        }
      end
      if (@bMC == true)
        CHK_ATTRIBUTE_TYPE_MC.each{|sObjectType, hAttribute|
          if (sObjectType == TSR_OBJ_TRUSTED_FUNCTION && @bSC1 == true)
            next
          end
          if (!File.exists?("#{FDR_T2_001}/#{sObjectType.downcase()}"))
           puts("[#{FDR_T2_001}/#{sObjectType.downcase()}] Error-file Creating..")
           prepare_directory("#{FDR_T2_001}/#{sObjectType.downcase()}")
          end
          
          hAttribute.each{|sAttribute, aAttrInfo|
            T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
          }
        }
      end
    end

    #=================================================================
    # 概  要: T2_002のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T2_002_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ

      CHK_ATTRIBUTE_VALUE.each{|sObjectType, hAttribute|
        if ((@bSC3 == true) && (sObjectType == TSR_OBJ_ALARM_CALL_BACK))
          # SC3の場合，アラームコールバックはない
          next
        end
        prepare_directory("#{FDR_T2_002}/#{sObjectType.downcase()}")
        puts("[#{FDR_T2_002}/#{sObjectType.downcase()}] Error-file Creating..")

        hAttribute.each{|sAttribute, aAttrInfo|
          T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
        }
      }
      if (@bSC3 == true)
        CHK_ATTRIBUTE_VALUE_SC3.each{|sObjectType, hAttribute|
          prepare_directory("#{FDR_T2_002}/#{sObjectType.downcase()}")
          if (((sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP) || (sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) || (sObjectType == TSR_OBJ_ERROR_HOOK_OSAP)) &&
              (@bML1 != true))
            hAttribute.each{|sAttribute, aAttrInfo|
              if (aAttrInfo.include?(ANY_OSAP_LEVEL1))
                aAttrInfo.delete(ANY_OSAP_LEVEL1)
              end
              T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
            }
          elsif ((sObjectType == TSR_OBJ_C2ISR) && (@bML1 != true) && (@bML2 != true))
            hAttribute.each{|sAttribute, aAttrInfo|
              if (aAttrInfo.include?(ANY_OSAP_LEVEL1))
                aAttrInfo.delete(ANY_OSAP_LEVEL1)
              end
              T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
            }
          else
            hAttribute.each{|sAttribute, aAttrInfo|
              T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
            }
          end
        }
      end
      if (@bMC == true)
        CHK_ATTRIBUTE_VALUE_MC.each{|sObjectType, hAttribute|
          if (sObjectType == TSR_OBJ_TRUSTED_FUNCTION && @bSC1 == true)
            next
          end
          prepare_directory("#{FDR_T2_002}/#{sObjectType.downcase()}")
          hAttribute.each{|sAttribute, aAttrInfo|
            T2_prepare_convert_data(sDirectory, sObjectType, sAttribute, aAttrInfo)
          }
        }
      end
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T3_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array, aFileList)    # ファイルリスト

#     aFMPFile = search_FMP_file(aFileList)

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
#         next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))
          cIO.puts("echo [File] #{sFileList}")
          cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T4_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array,  aFileList)   # ファイルリスト

      T3_create_shell(sDirectory, aFileList)
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T5_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array,  aFileList)   # ファイルリスト

      aConfList = []
      aTemp     = []

#     aFMPFile = search_FMP_file(aFileList)

      # ASPモードの場合，FMPファイルを除外する
      aFileList.each{|sFileList|
#       next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))

        aTemp.push(sFileList)
      }

      aFileList = aTemp

      # 多数ファイルを実行するための実行命令名の変更
      aFileList.each{|sFileList|
        if (sFileList.include?(CONFIGURE_FILE) == true)
          aConfList.push(sFileList.gsub("-#{CONFIGURE_FILE}", ""))
          aFileList.delete(sFileList)
        end
      }

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
          if (aConfList.include?(sFileList) == true)
#           next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))
            cIO.puts("echo [File] #{sFileList}")
            cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList} -c #{sFileList.gsub(".yaml", "-#{CONFIGURE_FILE}.yaml")}")
          else
#           next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))
            cIO.puts("echo [File] #{sFileList}")
            cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
          end
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory}.sh")
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T6_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array, aFileList)    # ファイルリスト

#     aFMPFile = search_FMP_file(aFileList)

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory.split("/")[-1]}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
#         next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))
          cIO.puts("echo [File] #{sFileList}")
          cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory.split("/")[-1]}.sh")
    end

    #=================================================================
    # 概  要: T6_001のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T6_create_file(sDirectory, sProperty)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = {}
      hPropertyTemp = {}

      prepare_directory("#{FDR_T6}")

      if (@bSC3 == true)
        hErrorInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY_SC3)
      else
        hErrorInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY)
      end

      hErrorInfo.each{|sTestId, hScenario|
        hPropertyTemp = Marshal.load(Marshal.dump(hErrorInfo))
        hPropertyTemp[sTestId][TSR_LBL_PROPERTY].delete(sProperty)
      }
      @sFileName = "#{File.expand_path(FDR_T6)}/#{sDirectory.split("/")[-1]}-#{sProperty}-delete.yaml"
      @aMakeFileList.push(@sFileName)
      prepare_file(hPropertyTemp)
    end

    #=================================================================
    # 概  要: T6_004のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T6_004_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hPropertyInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY)

      prepare_directory("#{FDR_T6}")

      hPropertyInfo.each{|sTestId, hScenario|
        CHK_PROPERTY_TYPE.each{|sKey, aErrType|
          aErrType.each{|type|
            hPropertyTemp = Marshal.load(Marshal.dump(hPropertyInfo))
            hPropertyTemp[sTestId][TSR_LBL_PROPERTY][sKey] = CVT_PROPERTY_VALUE[type]

            @sFileName = "#{File.expand_path(FDR_T6)}/#{sDirectory.split("/")[-1]}-#{sKey}-#{CVT_PROPERTY_NAME[type]}.yaml"
            @aMakeFileList.push(@sFileName)
            prepare_file(hPropertyTemp)
          }
        }
      }
    end

    #=================================================================
    # 概  要: T6_005のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T6_005_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hPropertyInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY)

      prepare_directory("#{FDR_T6}")

      hPropertyInfo.each{|sTestId, hScenario|
        CHK_PROPERTY_VALUE.each{|sKey, aErrVal|
          aErrVal.each{|sValue|
            hPropertyTemp = Marshal.load(Marshal.dump(hPropertyInfo))
            hPropertyTemp[sTestId][TSR_LBL_PROPERTY][sKey] = CVT_PROPERTY_VALUE[sValue]

            @sFileName = "#{File.expand_path(FDR_T6)}/#{sDirectory.split("/")[-1]}-#{sKey}-#{CVT_PROPERTY_NAME[sValue]}.yaml"
            @aMakeFileList.push(@sFileName)
            prepare_file(hPropertyTemp)
          }
        }
      }
    end

    #=================================================================
    # 概  要: T6_006のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T6_006_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY)
      hPropertyTemp = {}

      prepare_directory("#{FDR_T6}")

      hErrorInfo.each{|sTestId, hScenario|
        hPropertyTemp = Marshal.load(Marshal.dump(hErrorInfo))
        hPropertyTemp[sTestId][TSR_LBL_PROPERTY].store("aa",["dummy"])
      }
      @sFileName = "#{File.expand_path(FDR_T6)}/#{sDirectory.split("/")[-1]}-key-no-exist.yaml"
      @aMakeFileList.push(@sFileName)
      prepare_file(hPropertyTemp)
    end

    #=================================================================
    # 概  要: T6_SC1_MC_001のエラーファイルを生成するために必要な情報を整える
    #=================================================================
    def T6_SC1_MC_001_create_file(sDirectory)
      check_class(String, sDirectory)  # 対象ディレクトリ
      hErrorInfo = Kwalify::Yaml.load_file(ANY_T6_TESRY)
      hPropertyTemp = {}

      prepare_directory("#{FDR_T6}")

      hErrorInfo.each{|sTestId, hScenario|
        hPropertyTemp = Marshal.load(Marshal.dump(hErrorInfo))
        hPropertyTemp[sTestId][TSR_LBL_PROPERTY].store("#{TSR_PRM_ADD_OSAP_ERR_HOOK}","true")
      }
      @sFileName = "#{File.expand_path(FDR_T6)}/#{sDirectory.split("/")[-1]}-add_osap_error_hook-true.yaml"
      @aMakeFileList.push(@sFileName)
      prepare_file(hPropertyTemp)
    end

    #=================================================================
    # 概  要: シェルファイルを生成する
    #=================================================================
    def T7_create_shell(sDirectory, aFileList)
      check_class(String, sDirectory)  # 対象ディレクトリ
      check_class(Array,  aFileList)   # ファイルリスト

      aConfList    = []
      aTemp        = []

#     aFMPFile = search_FMP_file(aFileList)

      # ASPモードの場合，FMPファイルを除外する
      aFileList.each{|sFileList|
#       next if ((@bSC == true) && (aFMPFile.include?(sFileList) == true))

        aTemp.push(sFileList)
      }

      aFileList = aTemp

      # 多数ファイルを実行するための実行命令名の変更
      aFileList.each{|sFileList|
        if (sFileList.include?(CONFIGURE_FILE) == true)
          aConfList.push(sFileList.gsub("-#{CONFIGURE_FILE}", ""))
        end
      }

      # シェルファイルを実行したディレクトリに生成する
      File.open("#{sDirectory}.sh", "w"){|cIO|
        aFileList.each{|sFileList|
          if (aConfList.include?(sFileList) == true)
            cIO.puts("echo [File] #{sFileList}")
            cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList} -c #{sFileList.gsub(".yaml", "-#{CONFIGURE_FILE}.yaml")}")
          else
            cIO.puts("echo [File] #{sFileList}")
            cIO.puts("ruby #{AKTG_PATH} #{@sCore} #{@sSClass} #{@sProfile} #{@sLevel} #{sFileList}")
          end
        }
      }

      @aMakeFileList.push("#{File.expand_path("")}/#{sDirectory}.sh")
    end

  end
end

#=====================================================================
# 概  要: Main
#=====================================================================
if ($0 == __FILE__)
  require "pp.rb"

  include ErrorCheckModule

  cErrorCheck = ErrorCheck.new(ARGV)
  cErrorCheck.proceed_AKTF_check()
end
