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
# $Id: Config.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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

module CommonModule
  #===================================================================
  # クラス名: Config
  # 概    要: 設定を管理
  #===================================================================
  class Config
    include CommonModule
    include AKTFModule

    @@hConf  = {} # configure設定
    @@hError = {} # 拡張エラーに該当する戻り値一覧

    #=================================================================
    # 概  要: configureファイルを読み込む
    #=================================================================
    def load_config(sFileName)
      check_class(String, sFileName)  # configureファイル

      hConf = load_yaml_file(sFileName)
      # Hashならば中身をsetしていく
      if (hConf.is_a?(Hash))
        hConf.each{|sKey, val|
          # 既に設定されている項目は飛ばす
          if (@@hConf[sKey].nil?())
            set(sKey, val)
          end
        }
      ### T0_004: configureがHashでない
      else
        sErr = sprintf("T0_004: " + ERR_INVALID_TYPE, "configure", Hash, hConf.class())
        raise(AKTFError.new(sErr))
      end

      # マクロの値を計算する
      calc_macro()

      # エラー種別が標準エラーのみ検出ならば拡張エラーに該当する仕様一覧を読み込む
      if (is_return_status_standard?())
        hError = load_yaml_file(EXTENDED_RETERN_STATUS)
        if (hError.is_a?(Hash))
          @@hError = hError
        end
      else
        @@hError = {}
      end

    end

    #=================================================================
    # 概  要: 値を設定する
    #=================================================================
    def set(sKey, val)
      check_class(String, sKey)       # キー
      check_class(Object, val, true)  # 値

      # 16進数処理
      if (val =~ AKTF_REX_HEX)
        val = val.hex()
      end

      case sKey
      # スケーラビリティクラス
      when CFG_SCALABILITY_CLASS
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_SCALABILITY_CLASS_SC1 && val != CFG_SCALABILITY_CLASS_SC2 && val != CFG_SCALABILITY_CLASS_SC3 && val != CFG_SCALABILITY_CLASS_SC4)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # 保護違反時処理機能の機能レベル
      when CFG_VIOLATION_HANDLING_LEVEL
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_VIOLATION_HANDLING_LEVEL1 && val != CFG_VIOLATION_HANDLING_LEVEL2 && val != CFG_VIOLATION_HANDLING_LEVEL3)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # タイミング保護機能の機能レベル
      when CFG_TIMING_PROTECTION_LEVEL
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_TIMING_PROTECTION_LEVEL1 && val != CFG_TIMING_PROTECTION_LEVEL2 && val != CFG_TIMING_PROTECTION_LEVEL3)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # メモリ保護機能の機能レベル
      when CFG_MEMORY_PROTECTION_LEVEL
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_MEMORY_PROTECTION_LEVEL1 && val != CFG_MEMORY_PROTECTION_LEVEL2 && val != CFG_MEMORY_PROTECTION_LEVEL3)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # エラー種別
      when CFG_RETURN_STATUS
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_RETURN_STATUS_STANDARD && val != CFG_RETURN_STATUS_EXTENDED)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # コンフォーマンスクラス
      when CFG_CONFORMANCE_CLASS
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_CONFORMANCE_CLASS_BCC1 && val != CFG_CONFORMANCE_CLASS_BCC2 && val != CFG_CONFORMANCE_CLASS_ECC1 && val != CFG_CONFORMANCE_CLASS_ECC2)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # テスト対象とする仕様
      when CFG_TARGET_SPEC
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        sStr = val.gsub(/\s[\|]\s/, "|")
        aTspec = sStr.split("|")
        ### T0_003: configureの設定値が有効値でない
        aTspec.each {|sSpec|
          if (!GRP_TARGET_SPEC.include?(sSpec))
            sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
            raise(AKTFError.new(sErr))
          end
        }
        val = aTspec

      # 真偽値
      when CFG_DEBUG_MODE,CFG_NO_PROGRESS_BAR, CFG_STACK_MONITORING, CFG_STACKFAULT_DETECTION,
           CFG_USE_GET_SERVICEID,CFG_USE_PARAMETER_ACCESS, CFG_USE_C1ISR, CFG_DEFINE_DECLARE, CFG_ENABLE_SAPI,
           CFG_ERROR_HOOK, CFG_POST_TASK_HOOK, CFG_PRE_TASK_HOOK, CFG_PROTECTION_HOOK,
           CFG_SHUTDOWN_HOOK, CFG_STARTUP_HOOK, CFG_FUNC_INTERRUPT, CFG_HARDWARE_COUNTER,
           CFG_STACK_SHARE, CFG_ENABLE_GCOV, CFG_ENABLE_CPPTEST, CFG_CPPTEST_USE_BUFFER, CFG_CPPTEST_ONLY_DO, CFG_ENABLE_LOG, CFG_ENA_EXC_LOCK,
           CFG_FUNC_PROTECTION_HOOK, CFG_TEST_FLOW, CFG_SUPPORT_ENADIS_INT_SOURCE, CFG_ENABLE_ALL_HOOK,
           CFG_STARTUP_HOOK_OSAP, CFG_SHUTDOWN_HOOK_OSAP, CFG_ERROR_HOOK_OSAP, CFG_CHECK_STACK_USAGE,
           CFG_ENABLE_FORCED_MERGE, CFG_USE_MULTI_CORE, CFG_ONLY_MASTER_CORE,
           CFG_INTER_CORE_INTERRUPT, CFG_ICISR_CONVERT, CFG_USE_TIME_PARTITIONING
        val = to_bool(val)
        ### T0_002: configureの設定値が指定された型と異なる
        if (!Bool.include?(val.class()))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # 0より大きい実数
      when CFG_ALL_INTERRUPT_LOCK_BUDGET,CFG_OS_INTERRUPT_LOCK_BUDGET
        # オプション指定時は文字列になるため変換
        if (val =~ AKTF_REX_FLOAT)
          val = val.to_f()
        end
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(Float))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        ### T0_003: configureの設定値が有効値でない
        elsif (val <= 0.0)
          sErr = sprintf("T0_003: " + ERR_CFG_BE_INTEGER_GT, sKey, 0.0, val)
          raise(AKTFError.new(sErr))
        end

      # 0より大きい整数
      when CFG_CORE_NUM
        # オプション指定時は文字列になるため変換
        if (val =~ AKTF_REX_NUM)
          val = val.to_i()
        end
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(Integer))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        ### T0_003: configureの設定値が有効値でない
        elsif (val <= 0)
          sErr = sprintf("T0_003: " + ERR_CFG_BE_INTEGER_GT, sKey, 0, val)
          raise(AKTFError.new(sErr))
        end

      # 0以上の整数
      when CFG_WAIT_SPIN_LOOP, CFG_MAX_TASK_PRI, CFG_MIN_TASK_PRI
        # オプション指定時は文字列になるため変換
        if (val =~ AKTF_REX_NUM)
          val = val.to_i()
        end
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(Integer))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        ### T0_003: configureの設定値が有効値でない
        elsif (val < 0)
          sErr = sprintf("T0_003: " + ERR_CFG_BE_INTEGER_GE, sKey, 0, val)
          raise(AKTFError.new(sErr))
        end

      # 文字列
      when CFG_FILE, CFG_OUT_FILE, CFG_APP_MODE, CFG_DEFAULT_OSAP_ID, CFG_NT_TASK_STACK_REGION,
           CFG_ICISR_PRI, CFG_VERSION
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # 文字列か0以上の整数
      when CFG_MASTER_CORE
        # オプション指定時は文字列になるため変換
        if (val =~ AKTF_REX_NUM)
          val = val.to_i()
        end
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String) && !val.is_a?(Integer))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        ### T0_003: configureの設定値が有効値でない
        elsif (val.is_a?(Integer) && (val < 0))
          sErr = sprintf("T0_003: " + ERR_CFG_BE_INTEGER_GE, sKey, 0, val)
          raise(AKTFError.new(sErr))
        end

      # IRCアーキテクチャ
      when CFG_IRC_ARCH
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != TSR_PRM_IRC_GLOBAL && val != TSR_PRM_IRC_LOCAL && val != TSR_PRM_IRC_COMBINATION)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # YAMLライブラリ
      when CFG_YAML_LIBRARY
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(String))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end
        ### T0_003: configureの設定値が有効値でない
        if (val != CFG_LIB_YAML && val != CFG_LIB_KWALIFY)
          sErr = sprintf("T0_003: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # ハードウェアカウンタの設定情報
      when CFG_HARDWARE_COUNTER_PARAM
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(Hash))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # マクロ，不正IDマクロ
      when CFG_MACRO, CFG_MC_MACRO, CFG_INVALID_ID
        ### T0_009: マクロ定義部がHashでない
        if (!val.nil?() & !val.is_a?(Hash))
          sErr = sprintf("T0_009: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        end

      # 0以上の実数(時間パーティショニング)
      when CFG_SYSTEM_CYCLE_TIME, CFG_SYSTEM_CYCLE_TIME_WINDOW_START, CFG_SYSTEM_CYCLE_TIME_WINDOW_LENGTH
        # オプション指定時は文字列になるため変換
        if (val =~ AKTF_REX_FLOAT)
          val = val.to_f()
        end
        ### T0_002: configureの設定値が指定された型と異なる
        if (!val.is_a?(Float))
          sErr = sprintf("T0_002: " + ERR_CFG_INVALID_VALUE, sKey, val)
          raise(AKTFError.new(sErr))
        ### T0_003: configureの設定値が有効値でない
        elsif (val < 0.0)
          sErr = sprintf("T0_003: " + ERR_CFG_BE_INTEGER_GT, sKey, 0.0, val)
          raise(AKTFError.new(sErr))
        end

      # 定義されていないキー
      else
        ### T0_005: configureに規定されていない項目が記述されている
        sErr = sprintf("T0_005: " + ERR_CFG_UNDEFINED_KEY, sKey, "configure")
        raise(AKTFError.new(sErr))
      end

      # チェックが通れば代入
      @@hConf[sKey] = val
    end

    #=================================================================
    # 概  要: マクロの値を処理
    #=================================================================
    def calc_macro()
      if (@@hConf[CFG_MACRO].is_a?(Hash))
        hMacro = @@hConf.dup()
        hMacro.delete(CFG_MACRO)
        @@hConf[CFG_MACRO].each{|sMacro, val|
          @@hConf[CFG_MACRO][sMacro] = parse_value(val, hMacro)
        }
      end
    end

    #=================================================================
    # 概  要: 真偽値を表す文字列を変換する
    #=================================================================
    def to_bool(sStr)
      check_class(Object, sStr, true)  # 変換する文字列

      case sStr
      when "true"
        return true # [Bool]変換結果
      when "false"
        return false # [Bool]変換結果
      else
        return safe_dup(sStr) # [Bool]変換結果
      end
    end

    #=================================================================
    # 概  要: configureのチェックを行う
    #=================================================================
    def environment_check()
      @aErrors = []

      # 設定のチェック
      GRP_CFG_NECESSARY_KEYS.each{|sKey|
        ### T0_001: configureの設定で記述されていない項目がある
        if (!@@hConf.has_key?(sKey))
          sErr = sprintf("T0_001: " + ERR_CFG_REQUIRED_KEY, sKey)
          @aErrors.push(AKTFError.new(sErr))
        elsif (sKey == CFG_HARDWARE_COUNTER_PARAM)
          GRP_CFG_HWCNT_NECESSARY_KEYS.each{|sParam|
            if (!@@hConf[sKey].has_key?(sParam))
              sErr = sprintf("T0_001: " + ERR_CFG_REQUIRED_KEY, sParam)
              @aErrors.push(AKTFError.new(sErr))
            end
          }
        end
      }

      check_error(@aErrors)

      ### T0_015: configureのバージョンとAKTGのバージョンが異なる
      if (@@hConf[CFG_VERSION] != $Version)
        sErr = sprintf("T0_015: " + ERR_NOT_VERSION, @@hConf[CFG_VERSION], $Version)
        raise(AKTFError.new(sErr))
      end

      ### T0_014: use_multi_coreがfalseであるが，core_numが2以上である
      if (is_single?() && get_core_num() >= 2)
        raise(AKTFError.new("T0_014: " + ERR_NOT_MULTI_CORE))
      end

      ### T0_SC3_001: return_statusがEXTENDEDでない
      if ((@@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC3 || @@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC4) &&
          (@@hConf[CFG_RETURN_STATUS] != CFG_RETURN_STATUS_EXTENDED))
        sErr = sprintf("T0_SC3_001: " + ERR_RETURN_STATUS, CFG_SCALABILITY_CLASS, @@hConf[CFG_SCALABILITY_CLASS])
        raise(AKTFError.new(sErr))
      end

      # マクロのチェック
      hMacro = get_macro()
      hMcMacro = get_mc_macro()
      hHwcntParam = get_hardware_counter_param()
      hInvalid_id = get_invalid_id()

      ### T0_006: 必要なマクロが定義されていない
      GRP_CFG_NECESSARY_MACRO.each{|sMacro|
        if (hMacro.nil?() || hInvalid_id.nil?() || hMcMacro.nil?() ||
           (!hMacro.has_key?(sMacro) && !hInvalid_id.has_key?(sMacro) && !hMcMacro.has_key?(sMacro)))
          sErr = sprintf("T0_006: " + ERR_CFG_REQUIRED_MACRO, sMacro)
          @aErrors.push(AKTFError.new(sErr))
        end
      }

      if (hMacro.is_a?(Hash))
        ### T0_007: マクロの設定値が指定された型と異なる
        ### T0_008: マクロの設定値が有効値でない
        hMacro.each{|sMacro, val|
          case sMacro
          # [1以上，かつ，タスクの最大優先度以下の整数]
          when /^TSK_PRI_/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((val < 1) || (val > @@hConf[CFG_MAX_TASK_PRI]))
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, @@hConf[CFG_MAX_TASK_PRI], val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [整数か文字列]
          when /^INT_PRI_/, "PRO_INVALID"
            if (!val.is_a?(Integer) && !val.is_a?(String))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, "Integer or String", val.class())
              @aErrors.push(AKTFError.new(sErr))
            end

          # [文字列か0以上の整数]
          when /^INTNO_/, "ANY_TFN_STKSZ"
            if (!val.is_a?(String))
              if (!val.is_a?(Integer))
                sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, "Integer or String", val.class())
                @aErrors.push(AKTFError.new(sErr))
              elsif (val < 0)
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GE, sMacro, 0, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            ### T0_012: 各割込み番号のマクロとハードウェアカウンタ用の割込み番号が一致している
            elsif (val == hHwcntParam[CFG_HWCNT_INTNO])
                sErr = sprintf("T0_012: " + ERR_MCR_NOT_INTNO_UNIQUE, val)
                @aErrors.push(AKTFError.new(sErr))
            end

          # [0以上の整数]
          when /^CORE_/,  "MASTER_CORE"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val < 0)
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GE, sMacro, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [0より大きい整数]
          when "ANY_TICKSPERBASE"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val <= 0)
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [1より大きい整数]
          when /^ANY_MAXVAL_/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val <= 1)
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, 1, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [3以上の整数]
          when "ANY_BASIC_MAXACT"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val < 3)
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GE, sMacro, 3, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [2以上の整数，かつ，基本タスクの任意の起動要求の最大数未満]
          when "ANY_ACTCNT_NOT_MAX_1"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((val < 2) || ((hMacro["ANY_BASIC_MAXACT"] != nil && hMacro["ANY_BASIC_MAXACT"].is_a?(Integer)) && (val >= hMacro["ANY_BASIC_MAXACT"])))
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GE, sMacro, 3, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [0以上，かつ，カウンタの最大値以下の整数]
          when /^ANY_ALMVAL_/, /^ANY_CURVAL_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_ALMVAL_A", "ANY_CURVAL_A"
                if ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val < 0 || val > hMacro["ANY_MAXVAL_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, hMacro["ANY_MAXVAL_A"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_ALMVAL_B", "ANY_CURVAL_B"
                if ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val < 0 || val > hMacro["ANY_MAXVAL_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, hMacro["ANY_MAXVAL_B"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_ALMVAL_C", "ANY_CURVAL_C"
                if ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val < 0 || val > hMacro["ANY_MAXVAL_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, hMacro["ANY_MAXVAL_C"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0，もしくは，周期の最小値以上，カウンタの最大値以下の整数]
          when /^ANY_ALMCYCLE_/, /^ANY_SCDLTBL_OFFSET_/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_ALMCYCLE_A", "ANY_SCDLTBL_OFFSET_NOT_0_A"
                if (hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) &&
                   (val <= 0 || val < hMacro["ANY_MINCYC_A"] || val > hMacro["ANY_MAXVAL_A"])
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_A"], hMacro["ANY_MAXVAL_A"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_ALMCYCLE_B", "ANY_SCDLTBL_OFFSET_NOT_0_B"
                if (hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) &&
                   (val <= 0 || val < hMacro["ANY_MINCYC_B"] || val > hMacro["ANY_MAXVAL_B"])
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_B"], hMacro["ANY_MAXVAL_B"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_ALMCYCLE_C", "ANY_SCDLTBL_OFFSET_NOT_0_C"
                if (hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) &&
                   (val <= 0 || val < hMacro["ANY_MINCYC_C"] || val > hMacro["ANY_MAXVAL_C"])
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_C"], hMacro["ANY_MAXVAL_C"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0より大きく，カウンタの最大値以下の整数]
          when /^ANY_MINCYC_/, /^ANY_CURVAL_NOT_0_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_MINCYC_A", "ANY_CURVAL_NOT_0_A"
                if ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val <= 0 || val > hMacro["ANY_MAXVAL_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, hMacro["ANY_MAXVAL_A"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_MINCYC_B", "ANY_CURVAL_NOT_0_B"
                if ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val <= 0 || val > hMacro["ANY_MAXVAL_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, hMacro["ANY_MAXVAL_B"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_MINCYC_C", "ANY_CURVAL_NOT_0_C"
                if ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val <= 0 || val > hMacro["ANY_MAXVAL_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, hMacro["ANY_MAXVAL_C"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0以上，かつ，カウンタの最大値未満の整数]
          when /^ANY_CURVAL_NOT_MAX_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_CURVAL_NOT_MAX_A"
                if ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val < 0 || val >= hMacro["ANY_MAXVAL_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MAXVAL_A"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_MAX_B"
                if ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val < 0 || val >= hMacro["ANY_MAXVAL_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MAXVAL_B"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_MAX_C"
                if ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val < 0 || val >= hMacro["ANY_MAXVAL_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MAXVAL_C"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0より大きく，かつ，カウンタの最大値未満の整数]
          when /^ANY_CURVAL_NOT_0_MAX_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_CURVAL_NOT_0_MAX_A"
                if ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val <= 0 || val >= hMacro["ANY_MAXVAL_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, (hMacro["ANY_MAXVAL_A"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_0_MAX_B"
                if ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val <= 0 || val >= hMacro["ANY_MAXVAL_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, (hMacro["ANY_MAXVAL_B"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_0_MAX_C"
                if ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val <= 0 || val >= hMacro["ANY_MAXVAL_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, (hMacro["ANY_MAXVAL_C"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0以上，かつ，カウンタの現在値(0,MAX以外の値)未満の整数]
          when /^ANY_CURVAL_WRAPAROUND_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_CURVAL_WRAPAROUND_A"
                if ((hMacro["ANY_CURVAL_NOT_0_MAX_A"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_A"].is_a?(Integer)) &&
                    (val < 0 || val > hMacro["ANY_CURVAL_NOT_0_MAX_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_A"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_WRAPAROUND_B"
                if ((hMacro["ANY_CURVAL_NOT_0_MAX_B"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_B"].is_a?(Integer)) &&
                    (val < 0 || val > hMacro["ANY_CURVAL_NOT_0_MAX_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_B"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_WRAPAROUND_C"
                if ((hMacro["ANY_CURVAL_NOT_0_MAX_C"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_C"].is_a?(Integer)) &&
                    (val < 0 || val > hMacro["ANY_CURVAL_NOT_0_MAX_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_C"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [カウンタの現在値(0,MAX以外の値)より大きく，かつ，カウンタの最大値以下の整数]
          when /^ANY_CURVAL_NOT_WRAPAROUND_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_CURVAL_NOT_WRAPAROUND_A"
                if (((hMacro["ANY_CURVAL_NOT_0_MAX_A"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_A"].is_a?(Integer)) && (val <= hMacro["ANY_CURVAL_NOT_0_MAX_A"])) ||
                   ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val > hMacro["ANY_MAXVAL_A"])))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_A"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_WRAPAROUND_B"
                if (((hMacro["ANY_CURVAL_NOT_0_MAX_B"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_B"].is_a?(Integer)) && (val <= hMacro["ANY_CURVAL_NOT_0_MAX_B"])) ||
                   ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val > hMacro["ANY_MAXVAL_B"])))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_B"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_CURVAL_NOT_WRAPAROUND_C"
                if (((hMacro["ANY_CURVAL_NOT_0_MAX_C"] != nil && hMacro["ANY_CURVAL_NOT_0_MAX_C"].is_a?(Integer)) && (val <= hMacro["ANY_CURVAL_NOT_0_MAX_C"])) ||
                   ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val > hMacro["ANY_MAXVAL_C"])))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_CURVAL_NOT_0_MAX_C"]), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [カウンタの最大値より大きい整数]
          when /^INVALID_INCREMENT_GREATER_THAN_MAXVAL_[ABC]/, /^INVALID_START_GREATER_THAN_MAXVAL_[ABC]/, /^INVALID_CYCLE_GREATER_THAN_MAXVAL_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "INVALID_INCREMENT_GREATER_THAN_MAXVAL_A", "INVALID_START_GREATER_THAN_MAXVAL_A", "INVALID_CYCLE_GREATER_THAN_MAXVAL_A"
                if ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) && (val <= hMacro["ANY_MAXVAL_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, hMacro["ANY_MAXVAL_A"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "INVALID_INCREMENT_GREATER_THAN_MAXVAL_B", "INVALID_START_GREATER_THAN_MAXVAL_B", "INVALID_CYCLE_GREATER_THAN_MAXVAL_B"
                if ((hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) && (val <= hMacro["ANY_MAXVAL_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, hMacro["ANY_MAXVAL_B"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "INVALID_INCREMENT_GREATER_THAN_MAXVAL_C", "INVALID_START_GREATER_THAN_MAXVAL_C", "INVALID_CYCLE_GREATER_THAN_MAXVAL_C"
                if ((hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) && (val <= hMacro["ANY_MAXVAL_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, hMacro["ANY_MAXVAL_C"], val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0より小さい整数]
          when "INVALID_INCREMENT_LOWER_THAN_0", "INVALID_START_LOWER_THAN_0"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val >= 0)
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_LT, sMacro, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [0より大きく，かつ，周期の最小値より小さい整数]
          when /^INVALID_CYCLE_LOWER_THAN_MINCYCL_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "INVALID_CYCLE_LOWER_THAN_MINCYCL_A"
                if ((hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) &&
                    (val <= 0 || val >= hMacro["ANY_MINCYC_A"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MINCYC_A"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "INVALID_CYCLE_LOWER_THAN_MINCYCL_B"
                if ((hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) &&
                    (val <= 0 || val >= hMacro["ANY_MINCYC_B"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MINCYC_B"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              when "INVALID_CYCLE_LOWER_THAN_MINCYCL_C"
                if ((hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) &&
                    (val <= 0 || val >= hMacro["ANY_MINCYC_C"]))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, (hMacro["ANY_MINCYC_C"]-1), val)
                @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [AK_AUTO，もしくは，0より大きい整数]
          when /^EVENTMASK_/, "ANY_EVENTMASK"
            if (val.is_a?(String))
              if (val != TSR_STT_AUTO)
                sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sMacro, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            elsif (val.is_a?(Integer))
              if (val <= 0)
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, 0, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            else
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, "Integer or String", val.class())
              @aErrors.push(AKTFError.new(sErr))
            end

          # [AK_SCHFULL, AK_SCHNON]
          when "ANY_SPOLICY"
            if (!val.is_a?(String))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, String, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val != TSR_STT_SCHFULL && val != TSR_STT_SCHNON)
              sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sMacro, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [AK_BASIC, AK_EXTENDED]
          when "ANY_TTYPE"
            if (!val.is_a?(String))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, String, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (val != TSR_STT_BASIC && val != TSR_STT_EXTENDED)
              sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sMacro, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [カウンタ周期の最小値＋1以上，かつ，カウンタの最大値以下の整数]
          when /^ANY_SCDLTBL_DURATION_/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_SCDLTBL_DURATION_A"
                if ((hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) &&
                   ((val < (hMacro["ANY_MINCYC_A"] + 1)) || (val > hMacro["ANY_MAXVAL_A"])))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, (hMacro["ANY_MINCYC_A"]+1), hMacro["ANY_MAXVAL_A"], val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_DURATION_B"
                if ((hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_B"] != nil && hMacro["ANY_MAXVAL_B"].is_a?(Integer)) &&
                    ((val < (hMacro["ANY_MINCYC_B"] + 1)) || (val > hMacro["ANY_MAXVAL_B"])))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, (hMacro["ANY_MINCYC_B"]+1), hMacro["ANY_MAXVAL_B"], val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_DURATION_C"
                if ((hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) && (hMacro["ANY_MAXVAL_C"] != nil && hMacro["ANY_MAXVAL_C"].is_a?(Integer)) &&
                    ((val < (hMacro["ANY_MINCYC_C"] + 1)) || (val > hMacro["ANY_MAXVAL_C"])))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, (hMacro["ANY_MINCYC_C"]+1), hMacro["ANY_MAXVAL_C"], val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [0またはカウンタ周期の最小値以上，かつ，(スケジュールテーブルの周期-カウンタ周期)以下の整数]
          when /^ANY_SCDLTBL_INIT_OFFSET_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_SCDLTBL_INIT_OFFSET_A"
                if ((hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_A"] != nil && hMacro["ANY_SCDLTBL_DURATION_A"].is_a?(Integer)) &&
                    (((val != 0) && (val < hMacro["ANY_MINCYC_A"])) || (val > (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_INCLUDE_ZERO, sMacro, hMacro["ANY_MINCYC_A"], (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_B"
                if ((hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_B"] != nil && hMacro["ANY_SCDLTBL_DURATION_B"].is_a?(Integer)) &&
                    (((val != 0) && (val < hMacro["ANY_MINCYC_B"])) || (val > (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_INCLUDE_ZERO, sMacro, hMacro["ANY_MINCYC_A"], (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_C"
                if ((hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_C"] != nil && hMacro["ANY_SCDLTBL_DURATION_C"].is_a?(Integer)) &&
                    (((val != 0) && (val < hMacro["ANY_MINCYC_C"])) || (val > (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_INCLUDE_ZERO, sMacro, hMacro["ANY_MINCYC_A"], (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [カウンタの周期以上，かつ，(スケジュールテーブルの周期-カウンタ周期)以下の整数]
          when /^ANY_SCDLTBL_INIT_OFFSET_NOT_0_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A"
                if ((hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_A"] != nil && hMacro["ANY_SCDLTBL_DURATION_A"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_A"]) || (val > (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_A"], (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_B"
                if ((hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_B"] != nil && hMacro["ANY_SCDLTBL_DURATION_B"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_B"]) || (val > (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_B"], (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_C"
                if ((hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_C"] != nil && hMacro["ANY_SCDLTBL_DURATION_C"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_C"]) || (val > (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_C"], (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"]), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [カウンタの周期以上，かつ，(スケジュールテーブルの周期-カウンタ周期)未満の整数]
          when /^ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_[ABC]/
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            else
              case sMacro
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A"
                if ((hMacro["ANY_MINCYC_A"] != nil && hMacro["ANY_MINCYC_A"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_A"] != nil && hMacro["ANY_SCDLTBL_DURATION_A"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_A"]) || (val >= (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_A"], (hMacro["ANY_SCDLTBL_DURATION_A"] - hMacro["ANY_MINCYC_A"] - 1), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_B"
                if ((hMacro["ANY_MINCYC_B"] != nil && hMacro["ANY_MINCYC_B"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_B"] != nil && hMacro["ANY_SCDLTBL_DURATION_B"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_B"]) || (val >= (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_B"], (hMacro["ANY_SCDLTBL_DURATION_B"] - hMacro["ANY_MINCYC_B"] - 1), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              when "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_C"
                if ((hMacro["ANY_MINCYC_C"] != nil && hMacro["ANY_MINCYC_C"].is_a?(Integer)) &&
                    (hMacro["ANY_SCDLTBL_DURATION_C"] != nil && hMacro["ANY_SCDLTBL_DURATION_C"].is_a?(Integer)) &&
                    ((val < hMacro["ANY_MINCYC_C"]) || (val >= (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"]))))
                  sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_MINCYC_C"], (hMacro["ANY_SCDLTBL_DURATION_C"] - hMacro["ANY_MINCYC_C"] - 1), val)
                  @aErrors.push(AKTFError.new(sErr))
                end
              end
            end

          # [1より大きい，かつ，カウンタの最大値未満の整数]
          when "ANY_PARAM_OFFSET_STARTSCDLTBLREL"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) &&
                   ((val <= 1) || (val >= hMacro["ANY_MAXVAL_A"])))
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 1, hMacro["ANY_MAXVAL_A"], val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [0より大きい，かつ，スケジュールテーブル開始オフセット未満の整数]
          when "ANY_CURVAL_STARTSCDLTBLREL"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((hMacro["ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND"] != nil && hMacro["ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND"].is_a?(Integer)) &&
                   ((val <= 0) || (val >= hMacro["ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND"])))
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, hMacro["ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND"], val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [0以上，かつ，(カウンタ最大値-スケジュールテーブル開始前時刻+スケジュールテーブル開始時刻+1)が
          #  (カウンタ最大値-スケジュールテーブル初期オフセット値)以下の整数]
          when "ANY_CURVAL_STARTSCDLTBLREL_WRAPAROUND"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) &&
                   (hMacro["ANY_CURVAL_STARTSCDLTBLREL"] != nil && hMacro["ANY_CURVAL_STARTSCDLTBLREL"].is_a?(Integer)) &&
                   (hMacro["ANY_SCDLTBL_INIT_OFFSET_A"] != nil && hMacro["ANY_SCDLTBL_INIT_OFFSET_A"].is_a?(Integer)))
              nSchtblval = (hMacro["ANY_MAXVAL_A"] - hMacro["ANY_CURVAL_STARTSCDLTBLREL"] + val + 1)
              nCntval = (hMacro["ANY_MAXVAL_A"] - hMacro["ANY_SCDLTBL_INIT_OFFSET_A"])
              if ((val < 0) || (nSchtblval > nCntval))
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, 0, nCntval, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            end

          # [スケジュールテーブル開始前時刻より大きく，かつ，カウンタの最大値以下の整数]
          when "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND"
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, Integer, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((hMacro["ANY_CURVAL_STARTSCDLTBLREL"] != nil && hMacro["ANY_CURVAL_STARTSCDLTBLREL"].is_a?(Integer)) &&
                   (hMacro["ANY_MAXVAL_A"] != nil && hMacro["ANY_MAXVAL_A"].is_a?(Integer)) &&
                   ((val <= hMacro["ANY_CURVAL_STARTSCDLTBLREL"]) || (val > hMacro["ANY_MAXVAL_A"])))
              sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_RANGE, sMacro, hMacro["ANY_CURVAL_STARTSCDLTBLREL"], hMacro["ANY_MAXVAL_A"], val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [AK_TRUE，もしくは，AK_FALSE]
          when "ANY_SCDLTBLREL_REPEAT"
            if (!val.is_a?(String))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, String, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif ((val != TSR_STT_TRUE) && (val != TSR_STT_FALSE))
              sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sMacro, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [文字列]
          when "ANY_OSAP_1"
            if (!val.is_a?(String))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, String, val.class())
              @aErrors.push(AKTFError.new(sErr))
            elsif (!GRP_OSAP_ALL_AVAILABLE_SC3.include?(val))
              sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sMacro, val)
              @aErrors.push(AKTFError.new(sErr))
            end

          # [文字列，もしくは，0より大きい整数]
          when "INVALID_ILLEGAL_ADD"
            if (!val.is_a?(String))
              if (!val.is_a?(Integer))
                sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sMacro, "Integer or String", val.class())
                @aErrors.push(AKTFError.new(sErr))
              elsif (val <= 0)
                sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sMacro, 0, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            end

          end
        }
        check_error(@aErrors)

        # タスク優先度の大小関係チェック
        sKey1 = "TSK_PRI_TOP"
        GRP_TSK_PRI.each{|sKey2|
          check_lt(sKey1, sKey2)
          sKey1 = sKey2
        }
        # 割込み優先度の大小関係チェック(文字列の場合はチェック不要)
        if (hMacro["INT_PRI_ISR1_HIGH"].is_a?(Integer))
          sKey1 = "INT_PRI_ISR1_HIGH"
        end
        GRP_INT_PRI.each{|sKey2|
          if (sKey1 != nil) && (hMacro[sKey2].is_a?(Integer))
            check_lt(sKey1, sKey2)
            sKey1 = sKey2
          end
        }

      end

      if (hInvalid_id.is_a?(Hash))
        ### T0_007: マクロの設定値が指定された型と異なる
        hInvalid_id.each{|sInvalid, val|
          case sInvalid
          # [配列]
          when /^INVALID_[A-Z]+(_[A-Z]+|)_ID$/, "INVALID_FUNC_INDEX"
            if (!val.is_a?(Array))
              sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sInvalid, Array, val.class())
              @aErrors.push(AKTFError.new(sErr))
            end
          end
        }
      end

      if (hMcMacro.is_a?(Hash))
        ### T0_007: マクロの設定値が指定された型と異なる
        ### T0_008: マクロの設定値が有効値でない
        hMcMacro.each{|sOsap, val|
          case sOsap
          # [文字列]
          when /[A-Z]*TRUSTED_OSAP[0-9A-Z_]*/
            if (!val.is_a?(String))
               sErr = sprintf("T0_007: " + ERR_MCR_INVALID_TYPE, sOsap, Array, val.class())
               @aErrors.push(AKTFError.new(sErr))
            elsif (!GRP_OSAP_ALL_AVAILABLE_SC3.include?(val))
              sErr = sprintf("T0_008: " + ERR_MCR_INVALID_VALUE, sOsap, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          end
        }
      end

      check_error(@aErrors)
    end

    #=================================================================
    # 概  要: ハードウェアカウンタ設定情報のチェックを行う
    #=================================================================
    def hwcnt_param_check()
      @aErrors = []

      hMacro = get_macro()
      hHwcntParam = get_hardware_counter_param()

      nMaxval = hHwcntParam[CFG_HWCNT_MAXVAL]
      # ランタイムエラー防止のため，maxvalの型を先にチェック
      if (nMaxval.is_a?(Integer))
        hHwcntParam.each{|sParam, val|
          case sParam
          # 文字列
          when CFG_HWCNT_COUNTER_ID, CFG_HWCNT_ISRID
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(String))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          # 文字列か0以上の整数
          when CFG_HWCNT_INTNO
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(String) && !val.is_a?(Integer))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            elsif (val.is_a?(Integer) && (val < 0))
              sErr = sprintf("T0_011: " + ERR_CFG_BE_INTEGER_GE, sParam, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          # 整数か文字列
          when CFG_HWCNT_INIINTPRI
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(String) && !val.is_a?(Integer))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          # GRP_HWCNT_OSAP_ALL_AVAILABLEかGRP_HWCNT_OSAP_TRUSTED_AVAILABLE
          when CFG_HWCNT_OSAP
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(String))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            elsif (get_memory_protection_level() == CFG_MEMORY_PROTECTION_LEVEL3)
              if (!GRP_HWCNT_OSAP_ALL_AVAILABLE.include?(val))
                sErr = sprintf("T0_011: " + ERR_CFG_INVALID_VALUE, sParam, val)
                @aErrors.push(AKTFError.new(sErr))
              end
            elsif (!GRP_HWCNT_OSAP_TRUSTED_AVAILABLE.include?(val))
             sErr = sprintf("T0_011: " + ERR_CFG_INVALID_VALUE, sParam, val)
             @aErrors.push(AKTFError.new(sErr))
            end
          # AK_ENABLEかAK_DISABLE
          when CFG_HWCNT_INTATR
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(String))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            elsif (val != TSR_STT_ENABLE && val != TSR_STT_DISABLE)
              sErr = sprintf("T0_011: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            end
            ### T0_013: support_enadis_interrupt_sourceがfalseであるが，ハードウェアカウンタに割付けるC2ISRの割込み属性がAK_DISABLEである
            if (is_support_enadis_int_source?() == false && val == TSR_STT_DISABLE)
              @aErrors.push(YamlError.new("T0_013: " + ERR_HWCNT_CANNOT_WORK))
            end
          # 0より大きく，maxval以下の整数
          when CFG_HWCNT_MINCYC
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(Integer))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            elsif (val <= 0 || val > nMaxval)
              sErr = sprintf("T0_011: " + ERR_CFG_BE_INTEGER_RANGE, sParam, 1, nMaxval, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          # 0より大きい整数
          when CFG_HWCNT_MAXVAL
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            if (val <= 0)
              sErr = sprintf("T0_011: " + ERR_CFG_BE_INTEGER_GT, sParam, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          # 0より大きい実数
          when CFG_HWCNT_SECONDSPERTICK
            ### T0_010: ハードウェアカウンタ設定情報の設定値が指定された型と異なる
            if (!val.is_a?(Float))
              sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, sParam, val)
              @aErrors.push(AKTFError.new(sErr))
            ### T0_011: ハードウェアカウンタ設定情報の設定値が有効値でない
            elsif (val <= 0.0)
              sErr = sprintf("T0_011: " + ERR_CFG_BE_INTEGER_GT, sParam, 0, val)
              @aErrors.push(AKTFError.new(sErr))
            end
          else
            ### T0_005: configureに規定されていない項目が記述されている
            sErr = sprintf("T0_005: " + ERR_CFG_UNDEFINED_KEY, sParam, "configure")
            @aErrors.push(AKTFError.new(sErr))
          end
        }
      else
         sErr = sprintf("T0_010: " + ERR_CFG_INVALID_VALUE, CFG_HWCNT_MAXVAL, nMaxval)
         @aErrors.push(AKTFError.new(sErr))
      end

      check_error(@aErrors)
    end

    #=================================================================
    # 概  要: 大小関係チェックを行う
    #=================================================================
    def check_lt(sKey1, sKey2)
      check_class(String, sKey1, true)  # 元となる値のキー
      check_class(String, sKey2, true)  # 比較対象のキー

      hMacro = get_macro()
      if (hMacro[sKey1] <= hMacro[sKey2])
        sErr = sprintf("T0_008: " + ERR_MCR_BE_INTEGER_GT, sKey1, sKey2, hMacro[sKey2])
        @aErrors.push(AKTFError.new(sErr))
      end
    end

    #=================================================================
    # 概  要: 読み込むconfigureファイル名を取得
    #=================================================================
    def get_configure_file()
      return @@hConf[CFG_FILE] # [String]configureファイル名
    end

    #=================================================================
    # 概  要: 出力ファイル名を取得
    #=================================================================
    def get_out_file()
      return @@hConf[CFG_OUT_FILE] # [String]出力ファイル名
    end

    #=================================================================
    # 概  要: StartOSに指定するアプリケーションモードを取得
    #=================================================================
    def get_app_mode()
      return @@hConf[CFG_APP_MODE] # [String]StartOSに指定するアプリケーションモード
    end

    #=================================================================
    # 概  要: マスタコアIDを取得
    #=================================================================
    def get_master_core()
      if (is_single?())
        return 0  # [Integer]シングルの場合，一律0を返す
      else
        return @@hConf[CFG_MASTER_CORE]  # [Integer]マスタコアID
      end
    end

    #=================================================================
    # 概  要: コア数を取得
    #=================================================================
    def get_core_num()
      return @@hConf[CFG_CORE_NUM] # [Integer]コア数
    end

    #=================================================================
    # 概  要: デフォルトOSAPを取得
    #=================================================================
    def get_default_osap_id()
      return @@hConf[CFG_DEFAULT_OSAP_ID] # [String]デフォルトOSAP
    end

    #=================================================================
    # 概  要: スピンロック取得待ちを確認するためのループ回数を取得
    #=================================================================
    def get_wait_spin_loop()
      return @@hConf[CFG_WAIT_SPIN_LOOP] # [Integer]スピンロック取得待ちを確認するためのループ回数
    end

    #=================================================================
    # 概  要: IRCアーキテクチャを取得
    #=================================================================
    def get_irc_arch()
      return @@hConf[CFG_IRC_ARCH] # [String]IRCアーキテクチャ
    end

    #=================================================================
    # 概  要: ハードウェアカウンタ設定情報を取得
    #=================================================================
    def get_hardware_counter_param()
      hHwcntParam = {}
      hMacro = get_macro()
      hMcMacro = get_mc_macro()

      @@hConf[CFG_HARDWARE_COUNTER_PARAM].each{|sParam, val|
        hHwcntParam[sParam] = calc_all_expr(val, hMacro)
      }
      if (is_multi?() && !hMcMacro[hHwcntParam[TSR_PRM_OSAP]].nil?)
        hHwcntParam[TSR_PRM_OSAP] = hMcMacro[hHwcntParam[TSR_PRM_OSAP]]
      end

      return hHwcntParam # [Hash]マクロ変換済みのハードウェアカウンタ設定情報のハッシュ
    end

    #=================================================================
    # 概  要: ユーザ定義マクロを取得
    #=================================================================
    def get_macro()
      return @@hConf[CFG_MACRO] # [Hash]マクロのハッシュ
    end

    #=================================================================
    # 概  要: ユーザ定義MC用マクロを取得
    #=================================================================
    def get_mc_macro()
      return @@hConf[CFG_MC_MACRO] # [Hash]MC用マクロのハッシュ
    end

    #=================================================================
    # 概  要: 不正ID展開用マクロを取得
    #=================================================================
    def get_invalid_id()
      return @@hConf[CFG_INVALID_ID] # [Hash]マクロのハッシュ
    end

    #=================================================================
    # 概  要: 非信頼タスクスタックを配置するメモリリージョン名を取得
    #=================================================================
    def get_nt_stack_region()
      return @@hConf[CFG_NT_TASK_STACK_REGION] # [String]メモリリージョン名
    end

    #=================================================================
    # 概  要: 割込み発生関数が使用可能かを返す
    #=================================================================
    def enable_func_interrupt()
      return (@@hConf[CFG_FUNC_INTERRUPT] == true) # [Bool]割込み発生関数が使用可能か
    end

    #=================================================================
    # 概  要: CPUロック中のCPU例外発生をサポートしているかを返す
    #=================================================================
    def is_enable_exc_in_cpulock?()
      return (@@hConf[CFG_ENA_EXC_LOCK] == true) # [Bool]CPUロック中のCPU例外発生をサポートしているか
    end

    #=================================================================
    # 概  要: テストフローモードが有効かを返す
    #=================================================================
    def enable_testflow_mode()
      return (@@hConf[CFG_TEST_FLOW] == true) # [Bool]テストフローモードが有効か
    end

    #=================================================================
    # 概  要: デバッグモードが有効かを返す
    #=================================================================
    def enable_debug_mode()
      return (@@hConf[CFG_DEBUG_MODE] == true) # [Bool]デバッグモードが有効か
    end

    #=================================================================
    # 概  要: スタック共有モードが有効かを返す
    #=================================================================
    def enable_stack_share_mode()
      return (@@hConf[CFG_STACK_SHARE] == true) # [Bool]スタック共有モードが有効か
    end

    #=================================================================
    # 概  要: プログレスバー非表示モードが有効かを返す
    #=================================================================
    def enable_no_progress_bar_mode()
      return (@@hConf[CFG_NO_PROGRESS_BAR] == true) # [Bool]プログレスバー非表示モードが有効か
    end

    #=================================================================
    # 概  要: プロファイルがSingleかチェック
    #=================================================================
    def is_single?()
      return (@@hConf[CFG_USE_MULTI_CORE] == false) # [Bool]プロファイルがSingleか
    end

    #=================================================================
    # 概  要: プロファイルがMultiかチェック
    #=================================================================
    def is_multi?()
      return (@@hConf[CFG_USE_MULTI_CORE] == true) # [Bool]プロファイルがMultiか
    end

    #=================================================================
    # 概  要: IRCアーキテクチャがグローバルかチェック(現状不使用)
    #=================================================================
    def is_irc_global?()
      return (@@hConf[CFG_IRC_ARCH] == TSR_PRM_IRC_GLOBAL) #[Bool]IRCアーキテクチャがグローバルか
    end

    #=================================================================
    # 概  要: IRCアーキテクチャがローカルかチェック(現状不使用)
    #=================================================================
    def is_irc_local?()
      return (@@hConf[CFG_IRC_ARCH] == TSR_PRM_IRC_LOCAL) #[Bool]IRCアーキテクチャがローカルか
    end

    #=================================================================
    # 概  要: IRCアーキテクチャを両方サポートするかチェック(現状不使用)
    #=================================================================
    def is_irc_combination?()
      return (@@hConf[CFG_IRC_ARCH] == TSR_PRM_IRC_COMBINATION) #[Bool]IRCアーキテクチャを両方サポートするか
    end

    #=================================================================
    # 概  要: EnableInterruptSource/DisableInterruptSourceをサポートす
    #         るかチェック
    #=================================================================
    def is_support_enadis_int_source?()
      return (@@hConf[CFG_SUPPORT_ENADIS_INT_SOURCE] == true) #[Bool]IRCアーキテクチャを両方サポートするか
    end

    #=================================================================
    # 概  要: YAMLライブラリを使うかを返す
    #=================================================================
    def is_yaml_library?()
      return (@@hConf[CFG_YAML_LIBRARY] == CFG_LIB_YAML) #[Bool]YAMLライブラリを使うか
    end

    #=================================================================
    # 概  要: GCOVを取得するかを返す
    #=================================================================
    def is_enable_gcov?()
      return (@@hConf[CFG_ENABLE_GCOV] == true) #[Bool]GCOVを取得するか
    end

    #=================================================================
    # 概  要: C++testを使用するかを返す
    #=================================================================
    def is_enable_cpptest?()
      return (@@hConf[CFG_ENABLE_CPPTEST] == true) #[Bool]C++testを使用するか
    end

    #=================================================================
    # 概  要: C++testでバッファーを使用するかを返す
    #=================================================================
    def is_cpptest_use_buffer?()
      return (@@hConf[CFG_CPPTEST_USE_BUFFER] == true) #[Bool]C++testでバッファーを使用するか
    end

    #=================================================================
    # 概  要: C++testのカバレッジ計測方法
    #=================================================================
    def is_cpptest_only_do?()
      return (@@hConf[CFG_CPPTEST_ONLY_DO] == true) #[Bool]true:doのみ/false:全て
    end

    #=================================================================
    # 概  要: ログを取得するかを返す(現状不使用)
    #=================================================================
    def is_enable_log?()
      return (@@hConf[CFG_ENABLE_LOG] == true) #[Bool]ログを取得するか
    end

    #=================================================================
    # 概  要: 値を取得（将来的に廃止）
    #=================================================================
    def get(sKey)
      check_class(String, sKey)  # キー

      return @@hConf[sKey] # [String, Bool]取得値
    end

    #=================================================================
    # 概  要: 保持している情報をリセットする
    #       : （カバレッジテストプログラム用）
    #=================================================================
    def reset()
      @@hConf = {}
    end

    #=================================================================
    # 概  要: スケーラビリティクラスを取得
    #=================================================================
    def get_scalability_class()
      return @@hConf[CFG_SCALABILITY_CLASS] # [String]スケーラビリティクラス
    end

    #=================================================================
    # 概  要: スケーラビリティクラス1かどうかを返す
    #=================================================================
    def is_sc1?()
      return (@@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC1)  # [Bool]スケーラビリティクラス1かどうか
    end

    #=================================================================
    # 概  要: スケーラビリティクラス2かどうかを返す
    #=================================================================
    def is_sc2?()
      return (@@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC2)  # [Bool]スケーラビリティクラス1かどうか
    end

    #=================================================================
    # 概  要: スケーラビリティクラス3かどうかを返す
    #=================================================================
    def is_sc3?()
      return (@@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC3)  # [Bool]スケーラビリティクラス1かどうか
    end

    #=================================================================
    # 概  要: スケーラビリティクラス4かどうかを返す
    #=================================================================
    def is_sc4?()
      return (@@hConf[CFG_SCALABILITY_CLASS] == CFG_SCALABILITY_CLASS_SC4)  # [Bool]スケーラビリティクラス1かどうか
    end

    #=================================================================
    # 概  要: オブジェクトがOSAPに所属するかどうかを返す
    #=================================================================
    def enable_osap?()
      bOsap = false
      if (is_sc3?() || is_sc4?() || is_multi?())
        bOsap = true
      end

      return bOsap  # [Bool]オブジェクトがOSAPに所属するかどうかを返す
    end

    #=================================================================
    # 概  要: コンフォーマンスクラスを取得
    #=================================================================
    def get_conformance_class()
      return @@hConf[CFG_CONFORMANCE_CLASS] # [String]コンフォーマンスクラス
    end

    #=================================================================
    # 概  要: テスト対象仕様を取得
    #=================================================================
    def get_target_spec()
      return @@hConf[CFG_TARGET_SPEC] # [Array]テスト対象仕様
    end

    #=================================================================
    # 概  要: テスト対象とする仕様がNOSかを返す
    #=================================================================
    def is_target_spec_nos?()
      return @@hConf[CFG_TARGET_SPEC].include?(CFG_TARGET_SPEC_NOS) # [Bool]テスト対象の仕様がNOSか
    end

    #=================================================================
    # 概  要: ハードウェアカウンタが使用可能かを返す
    #=================================================================
    def enable_func_hardware_counter()
      return (@@hConf[CFG_HARDWARE_COUNTER] == true) # [Bool]ハードウェアカウンタが使用可能か
    end

    #=================================================================
    # 概  要: プロテクションフック起動関数が使用可能かを返す
    #=================================================================
    def enable_func_protection_hook()
      return (@@hConf[CFG_FUNC_PROTECTION_HOOK] == true) # [Bool]プロテクションフック起動関数が使用可能か
    end

    #=================================================================
    # 概  要: スタートアップフックの呼出しが有効かを返す
    #=================================================================
    def enable_startup_hook()
      return (@@hConf[CFG_STARTUP_HOOK] == true) # [Bool]スタートアップフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: シャットダウンフックの呼出しが有効かを返す
    #=================================================================
    def enable_shutdown_hook()
      return (@@hConf[CFG_SHUTDOWN_HOOK] == true) # [Bool]シャットダウンフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: プレタスクフックの呼出しが有効かを返す
    #=================================================================
    def enable_pre_task_hook()
      return (@@hConf[CFG_PRE_TASK_HOOK] == true) # [Bool]プレタスクフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: ポストタスクフックの呼出しが有効かを返す
    #=================================================================
    def enable_post_task_hook()
      return (@@hConf[CFG_POST_TASK_HOOK] == true) # [Bool]ポストタスクフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: エラーフックの呼出しが有効かを返す
    #=================================================================
    def enable_error_hook()
      return (@@hConf[CFG_ERROR_HOOK] == true) # [Bool]エラーフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: プロテクションフックの呼出しが有効かを返す
    #=================================================================
    def enable_protection_hook()
      return (@@hConf[CFG_PROTECTION_HOOK] == true) # [Bool]プロテクションフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: OSAP固有のスタートアップフックの呼出しが有効かを返す
    #=================================================================
    def enable_startup_hook_osap()
      return (@@hConf[CFG_STARTUP_HOOK_OSAP] == true) # [Bool]OSAP固有のスタートアップフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: OSAP固有のシャットダウンフックの呼出しが有効かを返す
    #=================================================================
    def enable_shutdown_hook_osap()
      return (@@hConf[CFG_SHUTDOWN_HOOK_OSAP] == true) # [Bool]OSAP固有のシャットダウンフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: OSAP固有のエラーフックの呼出しが有効かを返す
    #=================================================================
    def enable_error_hook_osap()
      return (@@hConf[CFG_ERROR_HOOK_OSAP] == true) # [Bool]OSAP固有のエラーフックの呼出しが有効か
    end

    #=================================================================
    # 概  要: エラー種別が標準エラーのみ検出かを返す
    #=================================================================
    def is_return_status_standard?()
      if (@@hConf[CFG_RETURN_STATUS] != nil)
        return @@hConf[CFG_RETURN_STATUS].include?(CFG_RETURN_STATUS_STANDARD) # [Bool]エラー種別が標準エラーのみ検出か
      end
      return false # [Bool]エラー種別が標準エラーのみ検出か
    end

    #=================================================================
    # 概  要: 拡張エラーに該当する戻り値一覧を返す
    #=================================================================
    def get_return_status_extended()
      return @@hError # [Hash]拡張エラーに該当する戻り値一覧
    end

    #=================================================================
    # 概  要: タスクの最大優先度を返す
    #=================================================================
    def get_max_task_pri()
      return @@hConf[CFG_MAX_TASK_PRI] # [Integer]タスクの最大優先度
    end

    #=================================================================
    # 概  要: タスクの最小優先度を返す
    #=================================================================
    def get_min_task_pri()
      return @@hConf[CFG_MIN_TASK_PRI] # [Integer]タスクの最小優先度
    end

    #=================================================================
    # 概  要: declareが有効かを返す
    #=================================================================
    def enable_define_declare()
      return @@hConf[CFG_DEFINE_DECLARE] # [Bool]declareが有効か
    end

    #=================================================================
    # 概  要: スタックオーバーフロー検出が有効かを返す
    #=================================================================
    def enable_stackfault_detection()
      return (@@hConf[CFG_STACKFAULT_DETECTION] == true) # [Bool]スタックオーバーフロー検出が有効か
    end

    #=================================================================
    # 概  要: 保護違反時処理機能の機能レベルを返す
    #=================================================================
    def get_violation_handling_level()
      return @@hConf[CFG_VIOLATION_HANDLING_LEVEL] # [Integer]保護違反時処理機能の機能レベル
    end

    #=================================================================
    # 概  要: タイミング保護機能の機能レベルを返す
    #=================================================================
    def get_timing_protection_level()
      return @@hConf[CFG_TIMING_PROTECTION_LEVEL] # [Integer]タイミング保護機能の機能レベル
    end

    #=================================================================
    # 概  要: メモリ保護機能の機能レベルを返す
    #=================================================================
    def get_memory_protection_level()
      return @@hConf[CFG_MEMORY_PROTECTION_LEVEL] # [Integer]メモリ保護機能の機能レベル
    end

    #=================================================================
    # 概  要: 静的API出力が有効かを返す
    #=================================================================
    def enable_sapi()
      return (@@hConf[CFG_ENABLE_SAPI] == true) #[Bool]静的API出力が有効か
    end

    #=================================================================
    # 概  要: 全てのフックを有効にするかを返す
    #=================================================================
    def enable_all_hook()
      return (@@hConf[CFG_ENABLE_ALL_HOOK] == true)
    end

    #=================================================================
    # 概  要: スタックモニタリングを有効にするかを返す
    #=================================================================
    def enable_stack_monitoring()
      return (@@hConf[CFG_STACK_MONITORING] == true) #[Bool]スタックモニタリングを有効にするか
    end

    #=================================================================
    # 概  要: エラー種別を返す
    #=================================================================
    def get_return_status()
      return @@hConf[CFG_RETURN_STATUS] # [String]エラー種別
    end

    #=================================================================
    # 概  要: OSErrorGetServiceId()の使用を有効にするかを返す
    #=================================================================
    def enable_use_get_serviceid()
      return (@@hConf[CFG_USE_GET_SERVICEID] == true) #[Bool]OSErrorGetServiceId()の使用を有効にするか
    end

    #=================================================================
    # 概  要: エラーが発生したシステムサービスの引数取得を有効にするか
    #         を返す
    #=================================================================
    def enable_use_parameter_access()
      return (@@hConf[CFG_USE_PARAMETER_ACCESS] == true) #[Bool]エラーが発生したシステムサービスの引数取得を有効にするか
    end

    #=================================================================
    # 概  要: C1ISRの使用有無を返す
    #=================================================================
    def enable_use_c1isr()
      return (@@hConf[CFG_USE_C1ISR] == true) #[Bool]C1ISRの使用有無
    end

    #=================================================================
    # 概  要: スタック使用量表示が有効かを返す
    #=================================================================
    def enable_check_stack_usage()
      if (@@hConf[CFG_CHECK_STACK_USAGE] == true && @@hConf[CFG_STACK_SHARE] == true)
        return (@@hConf[CFG_CHECK_STACK_USAGE] == true) # [Bool]スタック使用量表示が有効か
      end
      return false # [Bool]スタック使用量表示が有効か
    end

    #=================================================================
    # 概  要: 強制マージを有効にするかを返す
    #=================================================================
    def enable_forced_merge()
      return (@@hConf[CFG_ENABLE_FORCED_MERGE] == true) #[Bool]全てのフックを有効にするか
    end

    #=================================================================
    # 概  要: OSAPから所属するコアIDを返す
    #=================================================================
    def get_core_id_from_osap(sOsap)
      check_class(Object, sOsap, true)  # OSAP(T2_001でチェック)
      sCoreid = ""

      case sOsap
      # SC1-MCの場合
      when get_default_osap_id(), TSR_STT_OSAP_SELF_CORE, TSR_STT_OSAP_OTHER_SAME_CORE
        sCoreid = CFG_MCR_CORE_SELF
      when TSR_STT_OSAP_OTHER_OTHER_CORE
        sCoreid = CFG_MCR_CORE_OTHER

      # SC3-MCの場合
      when /[A-Z]*TRUSTED_OSAP[0-9A-Z_]*/, TSR_STT_TR_OSAP_SELF_CORE, TSR_STT_NT_OSAP_SELF_CORE,
           TSR_STT_TR_OSAP_SELF_CORE_2, TSR_STT_NT_OSAP_SELF_CORE_2, TSR_STT_TR_OSAP_SELF_CORE_3,
           TSR_STT_NT_OSAP_SELF_CORE_3,TSR_STT_NT_OSAP_RESTARTING, TSR_STT_NT_OSAP_TERMINATED
        sCoreid = CFG_MCR_CORE_SELF
      when TSR_STT_TR_OSAP_OTHER_OTHER_CORE, TSR_STT_NT_OSAP_OTHER_OTHER_CORE,
           TSR_STT_TR_OSAP_OTHER_OTHER_CORE_2, TSR_STT_NT_OSAP_OTHER_OTHER_CORE_2
        sCoreid = CFG_MCR_CORE_OTHER

      else
        # 何もしない(OSAPが不正の場合，T2でチェックを行う)
      end

      return sCoreid # [Integer]コアID
    end

    #=================================================================
    # 概  要: 拡張用のスピンロックかどうかを返す
    #=================================================================
    def is_dilation_spinlock?(sSpinlock)
      check_class(Object, sSpinlock, true)  # Spinlock(T2_001でチェック)
      if (sSpinlock =~ /^#{TSR_OBJ_SPINLOCK}(\/\d-\d*\/)$/)
        return true
      end
      return false
    end

    #=================================================================
    # 概  要: マスタコアのみ起動させるかどうかを返す
    #=================================================================
    def enable_boot_only_master_core?()
      return (@@hConf[CFG_ONLY_MASTER_CORE] == true) #[Bool]マスタコアのみ起動させるか
    end

    #=================================================================
    # 概  要: コア間割込みの有無を返す
    #=================================================================
    def enable_inter_core_interrupt?()
      return (@@hConf[CFG_INTER_CORE_INTERRUPT] == true) #[Bool]コア間割込みが有効か
    end

    #=================================================================
    # 概  要: コア間割込み変換モードかどうかを返す
    #=================================================================
    def enable_icisr_convert?()
      return (@@hConf[CFG_ICISR_CONVERT] == true) #[Bool]コア間割込み変換モードが有効か
    end

    #=================================================================
    # 概  要: ICISRに変換対象のC2ISRの優先度を取得
    #=================================================================
    def get_icisr_convert_pri()
      return @@hConf[CFG_ICISR_PRI] # [String]割込み優先度
    end

    #=================================================================
    # 概  要: 時間パーティショニング機能があるかどうか返す
    #=================================================================
    def is_time_partitioning?()
      return (@@hConf[CFG_USE_TIME_PARTITIONING] == true) # [Bool]時間パーティショニング機能があるか
    end
    
    #=================================================================
    # 概  要: システム周期時間を取得 
    #=================================================================
    def get_system_cycle_time()
      return @@hConf[CFG_SYSTEM_CYCLE_TIME] # [Float]システム周期時間
    end
    
    #=================================================================
    # 概  要: タイムウィンドウ開始時刻を取得 
    #=================================================================
    def get_system_cycle_time_window_start()
      return @@hConf[CFG_SYSTEM_CYCLE_TIME_WINDOW_START] # [Float]タイムウィンドウ開始時刻
    end
		
    #=================================================================
    # 概  要: タイムウィンドウ終了時刻を取得 
    #=================================================================
    def get_system_cycle_time_window_length()
      return @@hConf[CFG_SYSTEM_CYCLE_TIME_WINDOW_LENGTH] # [Float]タイムウィンドウ終了時刻
    end
    
  end
end
