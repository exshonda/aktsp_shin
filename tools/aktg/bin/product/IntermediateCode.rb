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
# $Id: IntermediateCode.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/IMCodeElement.rb"

module AKTG

  #==================================================================
  # クラス名: IntermediateCode
  # 概    要: 中間コードを保持するクラス
  #==================================================================
  class IntermediateCode
    include CommonModule

    #================================================================
    # 概  要: コンストラクタ
    #================================================================
    def initialize()
      @aCode = []            # コード情報
      @hProcUnitInfo = {}    # 処理単位ごとに持つ情報（ローカル変数、最終起動回数）
      @aGlobalVar = []       # グローバル変数宣言
      @aHeader = []          # ヘッダーファイルに出力する情報
      @hConfig = {}          # コンフィグファイルに出力する情報
      @hOsapHook = {}        # OSAP固有のフック有無情報
      @hOsapObject = {}      # OSAPコンテナ用情報
      @hOsapContainers = {}  # OSAP毎のコンテナ情報
      @hStructInfo     = {}  # 構造体の情報
      @hRestartTask = {}     # リスタートタスク

      @cConf           = Config.new()                             # Configを取得
      @nBlockSeqCnt    = 0                                        # ブロックのシーケンス番号
      @nBarrierSeqCnt  = 0                                        # BarrierSyncのシーケンス番号
      @aCheckSeqCnt    = Array.new(@cConf.get_core_num() + 1, 0)  # チェックポイントのシーケンス番号（コアごとに保持）
      @aStack          = Array.new(@cConf.get_core_num(), 0)      # スタック共有時に必要なスタック数(信頼OSAP含む)
      @aUStack         = Array.new(@cConf.get_core_num(), 0)      # スタック共有時に必要な非信頼OSAPのスタック数

      @nIndent             = 0     # 出力コードに入れるタブの個数

      @aForceMergeEnum     = []    # 強制マージ用ENUM情報

      # XML情報(REXMLライブラリを使用)
      # ※定型的なコンテナをここで作成する
      @cXmlInfo = Document.new()
      @cXmlInfo.add(XMLDecl.new("1.0", "UTF-8"))
      REXML::Comment.new(VERSION, @cXmlInfo)
      cXmlAutosar = @cXmlInfo.add_element("AUTOSAR", XML_AUTOSAR_FIXED_ATT)
      cXmlArPackages = cXmlAutosar.add_element("AR-PACKAGES")
      cXmlArPackage = cXmlArPackages.add_element("AR-PACKAGE")
      cXmlArPackage.add_element(XML_SNAME).add_text("Os")
      cXmlElements = cXmlArPackage.add_element("ELEMENTS")
      cXmlEcucModuleConfVal = cXmlElements.add_element("ECUC-MODULE-CONFIGURATION-VALUES")
      cXmlEcucModuleConfVal.add_element(XML_SNAME).add_text("Os")
      cXmlEcucModuleConfVal.add_element("DEFINITION-REF", {"DEST" => "ECUC-MODULE-DEF"}).add_text(XML_ROOT_PATH)
      cXmlEcucModuleConfVal.add_element("ECUC-DEF-EDITION").add_text("4.0.3")
      cXmlEcucModuleConfVal.add_element("IMPLEMENTATION-CONFIG-VARIANT").add_text("VARIANT-PRE-COMPILE")
      @cXmlContainers = cXmlEcucModuleConfVal.add_element("CONTAINERS")
      cContainer = make_container(XML_C_INCLUDE, XML_C_INCLUDE, true, false, false)
      cContainer.elements[XML_PARAM].add_element(make_parameter(XML_P_INCLUDE_FILE, "#{@cConf.get_out_file()}.h", XML_C_INCLUDE))
      @cXmlContainers.add_element(cContainer)
    end
    attr_reader :aCode, :hProcUnitInfo, :aGlobalVar, :aHeader, :hConfig, :aStack, :aUStack, :hMainTask, :hCheckMain, :cXmlInfo
    attr_reader :cXmlContainers, :hOsapHook, :hOsapObject, :hOsapContainers, :aForceMergeEnum, :hStructInfo, :hRestartTask


    #================================================================
    # 概  要: 全テストシナリオ共通の情報を追加する
    #================================================================
    def add_common_info(hIsHookInfo, bIsHwcntInfo, aHwcntAccosap, sAppMode, aAppModeInfo, sRestartOsap)
      check_class(Hash, hIsHookInfo)          # 各フックの有無情報
      check_class(Bool, bIsHwcntInfo)         # ハードウェアカウンタの有無情報
      check_class(Array, aHwcntAccosap, true) # ハードウェアカウンタにアクセス可能なOSAP
      check_class(String, sAppMode)           # StartOSに指定するアプリケーションモード
      check_class(Array, aAppModeInfo)        # テストIDとアプリケーションモード
      check_class(String, sRestartOsap, true) # 起動後にすぐ再起動するOSAP

      # 基本的なデータ構造の生成
      set_testid_level(IMC_COMMON)
      set_condition_level(IMC_AKTG_MAIN)

      # メインタスクなど必要なの処理単位/関数情報を生成
      @hMainTask  = {:id => AKTG_MAIN_TASK,  :coreid => @cConf.get_master_core(), :bootcnt => AKTG_MAIN_BOOTCNT}
      @hDummyTask = {:id => AKTG_DUMMY_TASK, :coreid => @cConf.get_master_core(), :bootcnt => AKTG_MAIN_BOOTCNT}
      @hCheckMain = {:id => FNC_CHECK_MAIN,  :coreid => @cConf.get_master_core(), :bootcnt => AKTG_MAIN_BOOTCNT}
      @hMain      = {:id => FNC_MAIN,        :coreid => @cConf.get_master_core(), :bootcnt => AKTG_MAIN_BOOTCNT}

      # コード情報を共通部分に格納するエレメントを用意
      cElement = IMCodeElement.new(:common)

      # メインタスク，ダミータスク，メインタスク状態参照関数，main関数を追加
      cElement.set_proc_unit(@hMainTask[:id], @hMainTask[:bootcnt])
      cElement.set_proc_unit(@hDummyTask[:id], @hDummyTask[:bootcnt])
      cElement.set_proc_unit(@hCheckMain[:id], @hCheckMain[:bootcnt])
      cElement.set_proc_unit(@hMain[:id], @hMain[:bootcnt])

      # プロトタイプ宣言の追加
      cElement.set_header(@hMainTask[:id], TSR_OBJ_TASK)
      cElement.set_header(@hDummyTask[:id], TSR_OBJ_TASK)
      cElement.set_header(@hCheckMain[:id], IMC_FUNC_TYPE)
      cElement.set_header(@hMain[:id], IMC_MAIN_TYPE)
      if (@cConf.enable_define_declare())
        # Declare宣言のためにヘッダ情報に入れておく
        cElement.set_header(AKTG_DUMMY_RES, TSR_OBJ_RESOURCE)
        cElement.set_header(AKTG_DUMMY_EVT, TSR_OBJ_EVENT)
      end

      # 起動後すぐ再起動するOSAPのダミーリスタートタスクを追加
      if (!sRestartOsap.nil?())
        @hDummyReTask = {:id => AKTG_DUMMY_RETASK, :coreid => @cConf.get_core_id_from_osap(sRestartOsap), :bootcnt => AKTG_MAIN_BOOTCNT}
        cElement.set_proc_unit(@hDummyReTask[:id], @hDummyReTask[:bootcnt])
        cElement.set_header(@hDummyReTask[:id], TSR_OBJ_TASK)
      end

      # プロテクションフックの先頭に，スタックオーバーフロー用の処理を入れる
      if (hIsHookInfo[TSR_OBJ_PROTECTION_HOOK] == true)
        # 返り値用変数
        cElement.set_local_var(AUTOSAR_PROTECTION_HOOK, VAR_ERROR, TYP_PROTECT_RETURN, "PRO_IGNORE")
        # プロテクションフック初期処理
        cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, FNC_PROTECTION_HOOK_INIT)
        if (@cConf.enable_stackfault_detection())
          cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, "if (FatalError == E_OS_STACKFAULT) {", false)
          cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, "#{AKTG_TB}#{FNC_OUTPUT_LOG_0}(\"## Stack overflow is detected !!\")")
          cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, "#{AKTG_TB}#{FNC_SET_CP_STATE}(AK_FALSE)")
          cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, "#{AKTG_TB}return(PRO_SHUTDOWN)")
          cElement.set_pre_code(AUTOSAR_PROTECTION_HOOK, "}", false)
        end
        # プロテクションフック戻り値
        cElement.set_post_code(AUTOSAR_PROTECTION_HOOK, "return(#{VAR_ERROR})")
      end

      # マルチコアの場合のシステム定義の各フック
      if (@cConf.is_multi?())
        if (hIsHookInfo[TSR_OBJ_STARTUP_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_STARTUP_HOOK, TSR_OBJ_STARTUP_HOOK)
        end
        if (hIsHookInfo[TSR_OBJ_SHUTDOWN_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_SHUTDOWN_HOOK, TSR_OBJ_SHUTDOWN_HOOK, VAR_ERROR)
        end
        if (hIsHookInfo[TSR_OBJ_PRETASK_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_PRETASK_HOOK, TSR_OBJ_PRETASK_HOOK)
        end
        if (hIsHookInfo[TSR_OBJ_POSTTASK_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_POSTTASK_HOOK, TSR_OBJ_POSTTASK_HOOK)
        end
        if (hIsHookInfo[TSR_OBJ_ERROR_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_ERROR_HOOK, TSR_OBJ_ERROR_HOOK, VAR_ERROR)
        end
        if (hIsHookInfo[TSR_OBJ_PROTECTION_HOOK] == true)
          add_hook_code_for_all_core(cElement, AUTOSAR_PROTECTION_HOOK, TSR_OBJ_PROTECTION_HOOK, VAR_FATAL_ERROR, true)
        end
      end

      # シャットダウンフックの先頭に，異常が発生している場合の処理を入れる
      if (hIsHookInfo[TSR_OBJ_SHUTDOWN_HOOK] == true)
        cElement.set_local_var(AUTOSAR_SHUTDOWN_HOOK, VAR_STATE, TYP_UINT8)
        cElement.set_pre_code(AUTOSAR_SHUTDOWN_HOOK, "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
        cElement.set_pre_code(AUTOSAR_SHUTDOWN_HOOK, "if (#{VAR_STATE} == #{TSR_STT_FALSE}) {", false)
        cElement.set_pre_code(AUTOSAR_SHUTDOWN_HOOK, "#{AKTG_TB}return")
        cElement.set_pre_code(AUTOSAR_SHUTDOWN_HOOK, "}", false)
      end

      # コンフィギュレーション情報の追加
      cElement.set_cfg_app_mode(@cConf.get_app_mode())
      if (@cConf.enable_all_hook())
        cElement.set_cfg_os({XML_P_ERR_HOOK => true,
                             XML_P_POS_HOOK => true,
                             XML_P_PRE_HOOK => true,
                             XML_P_PRO_HOOK => true,
                             XML_P_SHU_HOOK => true,
                             XML_P_STA_HOOK => true})
      else
        cElement.set_cfg_os({XML_P_ERR_HOOK => hIsHookInfo[TSR_OBJ_ERROR_HOOK],
                             XML_P_POS_HOOK => hIsHookInfo[TSR_OBJ_POSTTASK_HOOK],
                             XML_P_PRE_HOOK => hIsHookInfo[TSR_OBJ_PRETASK_HOOK],
                             XML_P_PRO_HOOK => hIsHookInfo[TSR_OBJ_PROTECTION_HOOK],
                             XML_P_SHU_HOOK => hIsHookInfo[TSR_OBJ_SHUTDOWN_HOOK],
                             XML_P_STA_HOOK => hIsHookInfo[TSR_OBJ_STARTUP_HOOK]})
      end

      cElement.set_cfg_tsk({XML_SNAME        => AKTG_MAIN_TASK,
                            XML_P_T_ACT      => 1,
                            XML_P_T_PRI      => AKTG_WAIT_PRI,
                            XML_P_T_SCHE     => TSR_STT_SCHFULL,
                            XML_P_T_EVT      => [AKTG_DUMMY_EVT],
                            XML_P_T_RES      => [AKTG_DUMMY_RES],
                            XML_P_T_STKSZ    => "AKTSP_TASK_STACK_SIZE",
                            XML_P_T_STKADD   => "NULL",
                            XML_P_T_SSTKSZ   => 0,
                            XML_P_T_SSTKADD  => "NULL",
                            XML_P_T_APP_MODE => [@cConf.get_app_mode()],
                            XML_P_T_ACC_APP  => nil,
                            :osap            => AKTG_MAIN_OSAP,
                            :coreid          => @cConf.get_master_core(),
                            :restart         => false})
      cElement.set_cfg_tsk({XML_SNAME        => AKTG_DUMMY_TASK,
                            XML_P_T_ACT      => 1,
                            XML_P_T_PRI      => @cConf.get_max_task_pri(),
                            XML_P_T_SCHE     => TSR_STT_SCHFULL,
                            XML_P_T_EVT      => nil,
                            XML_P_T_RES      => [AKTG_DUMMY_RES],
                            XML_P_T_STKSZ    => "AKTSP_TASK_STACK_SIZE",
                            XML_P_T_STKADD   => "NULL",
                            XML_P_T_SSTKSZ   => 0,
                            XML_P_T_SSTKADD  => "NULL",
                            XML_P_T_APP_MODE => nil,
                            XML_P_T_ACC_APP  => nil,
                            :osap            => AKTG_MAIN_OSAP,
                            :coreid          => @cConf.get_master_core(),
                            :restart         => false})
      if (@cConf.is_time_partitioning?())
      cElement.set_cfg_res({XML_SNAME       => AKTG_DUMMY_RES,
                            XML_P_R_PROP    => TSR_STT_STANDARD,
                            XML_P_R_LINK    => nil,
                            XML_P_R_ACC_APP => [AKTG_MAIN_OSAP],
                            :osap           => IMC_RESOURCE_OSAP})
      else
      cElement.set_cfg_res({XML_SNAME       => AKTG_DUMMY_RES,
                            XML_P_R_PROP    => TSR_STT_STANDARD,
                            XML_P_R_LINK    => nil,
                            XML_P_R_ACC_APP => nil,
                            :osap           => IMC_RESOURCE_OSAP})
      end
      cElement.set_cfg_evt({XML_SNAME    => AKTG_DUMMY_EVT,
                            XML_P_E_MASK => TSR_STT_AUTO,
                            :osap        => IMC_EVENT_OSAP})

      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        if (!sRestartOsap.nil?())
          if (@cConf.is_multi?())
            hMacro = @cConf.get_macro()
            sCoreid = hMacro[@cConf.get_core_id_from_osap(sRestartOsap)]
          else
            sCoreid = @cConf.get_core_id_from_osap(sRestartOsap)
          end
          cElement.set_cfg_tsk({XML_SNAME        => AKTG_DUMMY_RETASK,
                                XML_P_T_ACT      => 1,
                                XML_P_T_PRI      => @cConf.get_max_task_pri(),
                                XML_P_T_SCHE     => TSR_STT_SCHFULL,
                                XML_P_T_EVT      => nil,
                                XML_P_T_RES      => nil,
                                XML_P_T_STKSZ    => "AKTSP_TASK_STACK_SIZE",
                                XML_P_T_STKADD   => "NULL",
                                XML_P_T_SSTKSZ   => 0,
                                XML_P_T_SSTKADD  => "NULL",
                                XML_P_T_APP_MODE => nil,
                                XML_P_T_ACC_APP  => nil,
                                :osap            => sRestartOsap,
                                :coreid          => sCoreid,
                                :restart         => true})
        end
        if (@cConf.is_single?())
          cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_ACTIVATE_TASK,
                                :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                :osap        => AKTG_MAIN_OSAP})
          cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_SET_EVENT,
                                :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                :osap        => AKTG_MAIN_OSAP})
          cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_SHUTDOWN_OS,
                                :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                :osap        => AKTG_MAIN_OSAP})
        elsif (@cConf.is_multi?())
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            if (nCoreid == @cConf.get_master_core())
              cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_ACTIVATE_TASK,
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => AKTG_MAIN_OSAP})
              cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_SET_EVENT,
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => AKTG_MAIN_OSAP})
              cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_SHUTDOWN_OS,
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => AKTG_MAIN_OSAP})
              cElement.set_cfg_tfn({XML_SNAME    => FNC_TFN_RAISE_INTERCORE_INTERRUPT,
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => AKTG_MAIN_OSAP})
            else
              # 全コアで同じ関数を共用するため，:funcnameで指定する
              # 信頼関数のために追加するOSAPであるため，:coreidでコアIDを指定する
              cElement.set_cfg_tfn({XML_SNAME    => "#{FNC_TFN_ACTIVATE_TASK}_#{nCoreid}",
                                    :funcname    => "TRUSTED_#{FNC_TFN_ACTIVATE_TASK}",
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => "#{AKTG_SUB_OSAP}_#{nCoreid}",
                                    :coreid      => nCoreid})
              cElement.set_cfg_tfn({XML_SNAME    => "#{FNC_TFN_SET_EVENT}_#{nCoreid}",
                                    :funcname    => "TRUSTED_#{FNC_TFN_SET_EVENT}",
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => "#{AKTG_SUB_OSAP}_#{nCoreid}",
                                    :coreid      => nCoreid})
              cElement.set_cfg_tfn({XML_SNAME    => "#{FNC_TFN_SHUTDOWN_OS}_#{nCoreid}",
                                    :funcname    => "TRUSTED_#{FNC_TFN_SHUTDOWN_OS}",
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => "#{AKTG_SUB_OSAP}_#{nCoreid}",
                                    :coreid      => nCoreid})
              cElement.set_cfg_tfn({XML_SNAME    => "#{FNC_TFN_RAISE_INTERCORE_INTERRUPT}_#{nCoreid}",
                                    :funcname    => "TRUSTED_#{FNC_TFN_RAISE_INTERCORE_INTERRUPT}",
                                    :stksz       => "AKTSP_STACK_SIZE_FOR_TFN",
                                    :osap        => "#{AKTG_SUB_OSAP}_#{nCoreid}",
                                    :coreid      => nCoreid})
            end
          }
        end
      end

      # 静的API側に区切りの改行を入れる
      cElement.set_sapi_return()

      if (bIsHwcntInfo == true)
        hMacro = @cConf.get_macro()
        hHwcntParam = @cConf.get_hardware_counter_param()
        if ((@cConf.is_sc1?() || @cConf.is_sc2?()) && @cConf.is_multi?())
          sOsap = @cConf.get_default_osap_id()
        else
          sOsap = hHwcntParam[CFG_HWCNT_OSAP]
        end

        cElement.set_cfg_isr({XML_SNAME        => AKTG_DUMMY_C2ISR,
                              XML_P_I_CAT      => XML_ISR_TYPE_2,
                              XML_P_I_NUM      => hHwcntParam[CFG_HWCNT_INTNO],
                              XML_P_I_PRI      => hHwcntParam[CFG_HWCNT_INIINTPRI],
                              XML_P_I_SRC      => hHwcntParam[CFG_HWCNT_INTATR],
                              XML_P_I_RES      => nil,
                              XML_P_I_STKSZ    => "AKTSP_C2ISR_STACK_SIZE",
                              :osap            => sOsap,
                              :coreid          => hMacro["CORE_SELF"]})
        cElement.set_cfg_cnt({XML_SNAME        => hHwcntParam[CFG_HWCNT_COUNTER_ID],
                              XML_P_C_MAX_VAL  => hHwcntParam[CFG_HWCNT_MAXVAL],
                              XML_P_C_MIN_CYC  => hHwcntParam[CFG_HWCNT_MINCYC],
                              XML_P_C_TIC_BASE => hMacro["ANY_TICKSPERBASE"],
                              XML_P_C_TYPE     => TSR_STT_HARDWARE,
                              XML_P_C_SEC_TICK => hHwcntParam[CFG_HWCNT_SECONDSPERTICK],
                              XML_P_C_ISR      => hHwcntParam[CFG_HWCNT_ISRID],
                              XML_P_C_ACC_APP  => aHwcntAccosap,
                              :osap            => sOsap,
                              :coreid          => hMacro["CORE_SELF"]})
      end

      # ローカル変数の追加
      cElement.set_local_var(@hCheckMain[:id], GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO], TYP_AKTSP_TSK_INFO)

      # メインタスクチェック関数用構造体作成
      if (!@cConf.enable_osap?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = AKTG_MAIN_OSAP
      end
      cElement.set_code(@hCheckMain, "#{FNC_MAKE_STR_TSK}(&#{GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO]}, #{TSR_STT_RUNNING}, #{@cConf.get_max_task_pri()}, #{AKTG_WAIT_PRI}, #{TSR_STT_EXTENDED}, 1, #{TSR_STT_SCHFULL}, AKTSP_INVALID_VALUE32, 0, 1, AKTSP_INVALID_VALUE32, 1, #{sOsap}, AKTSP_TASK_STACK_SIZE, NULL, 0, NULL)")
      cElement.set_verify_api(@hCheckMain, "#{FNC_VERIFY_TSK}(#{AKTG_MAIN_TASK}, &#{GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO]})")

      # フック内のアサート処理におけるShutdownOSが空振りした場合に備えcp_stateを都度チェックしておく
      cElement.set_local_var(@hCheckMain[:id], VAR_STATE, TYP_UINT8)
      cElement.set_code(@hCheckMain, "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
      cElement.set_code(@hCheckMain, "if (#{VAR_STATE} == #{TSR_STT_FALSE}) {", false)
      cElement.set_indent(1)
      if (@cConf.is_single?())
        cElement.set_code(@hCheckMain, "#{SS_SHUTDOWN_OS}(E_OK)")
      elsif (@cConf.is_multi?())
        cElement.set_code(@hCheckMain, "#{SS_SHUTDOWN_ALL}(E_OK)")
      end
      cElement.unset_indent()
      cElement.set_code(@hCheckMain, "}", false)

      # main関数の内容作成
      if (@cConf.enable_forced_merge() == false)
        # シングルコア
        if (@cConf.is_single?() || @cConf.enable_boot_only_master_core?())
          # テストライブラリ用変数初期化
          cElement.set_initialize_test_library(@hMain)
          # 1コアで動作させるマルチコアの場合は各コアの初期化も行う
          if (@cConf.is_multi?() && @cConf.enable_boot_only_master_core?())
            cElement.set_code(@hMain, FNC_INITIALIZE_TEST_LIB_EACH_CORE)
          end
          cElement.set_code(@hMain, "#{SS_START_OS}(#{sAppMode})")
        # マルチコア
        else
          if (@cConf.get_core_num() > 1)
            cElement.set_local_var(@hMain[:id], GRP_VAR_TYPE[TYP_STATUS], TYP_STATUS)
          end
          cElement.set_code(@hMain, "switch (#{SS_GET_CORE_ID}()) {", false)
          (0..@cConf.get_core_num()-1).each{|nCoreid|
            cElement.set_code(@hMain, "case #{AUTOSAR_CORE_ID_PREFIX}#{nCoreid}:", false)
            cElement.set_indent(1)
            # マスタコアでは，マスタコア以外の全コアにStartCoreを発行する
            if (nCoreid == @cConf.get_master_core())
              # テストライブラリ用変数初期化(マスタコアのみ)
              cElement.set_initialize_test_library(@hMain)
              cElement.set_code(@hMain, FNC_INITIALIZE_TEST_LIB_EACH_CORE)
              (0..@cConf.get_core_num()-1).each{|nID|
                if (nID != @cConf.get_master_core())
                  cElement.set_code(@hMain, "#{SS_START_CORE}(#{AUTOSAR_CORE_ID_PREFIX}#{nID}, &ercd)")
                  cElement.set_code(@hMain, "#{FNC_CHECK_ERCD}(#{GRP_VAR_TYPE[TYP_STATUS]}, E_OK)")
                end
              }
              cElement.set_code(@hMain, "#{SS_START_OS}(#{sAppMode})")
            # スレーブコアでは，DONOTCAREでStartOSを発行するのみ
            else
              cElement.set_code(@hMain, FNC_INITIALIZE_TEST_LIB_EACH_CORE)
              cElement.set_code(@hMain, "#{SS_START_OS}(DONOTCARE)")
            end
            cElement.set_code(@hMain, "break")
            cElement.unset_indent()
          }
          cElement.set_code(@hMain, "}", false)
        end
      else
        # 強制マージの場合は，main関数で呼出し回数を管理し，
        # 実行中のテストIDを識別するためのENUMを用意する
        cElement.set_global_var("#{AKTG_FORCE_MERGE_BOOTCNT}", "enum #{AKTG_FORCE_MERGE_ENUM}", "#{AKTG_FORCE_MERGE_ENUM}_#{AKTG_ENUM_INVALID}")
        @aForceMergeEnum.push("#{AKTG_FORCE_MERGE_ENUM}_#{AKTG_ENUM_INVALID}")

        # マルチコアではコア毎にbootcntを用意する
        if (@cConf.is_single?())
          cElement.set_code(@hMain, "static #{TYP_SINT32} #{VAR_BOOTCNT} = -1")
          cElement.set_code(@hMain, "#{VAR_BOOTCNT}++")

          # テストライブラリ用変数初期化(マルチコアではマスタコアのみで行う)
          cElement.set_initialize_test_library(@hMain)
        else
          sInitVal = "-1," * @cConf.get_core_num()
          cElement.set_code(@hMain, "static #{TYP_SINT32} #{VAR_BOOTCNT}[#{@cConf.get_core_num()}] = {#{sInitVal.chop()}}")
          cElement.set_code(@hMain, "#{VAR_BOOTCNT}[#{SS_GET_CORE_ID}()]++")

          # マスタコアのテストライブラリ初期化
          cElement.set_code(@hMain, "if (#{SS_GET_CORE_ID}() == #{AUTOSAR_CORE_ID_PREFIX}#{@cConf.get_master_core()}) {", false)
          cElement.set_initialize_test_library(@hMain, true)
          cElement.set_code(@hMain, "}", false)

          # 各コアのテストライブラリ初期化
          cElement.set_code(@hMain, "#{FNC_INITIALIZE_TEST_LIB_EACH_CORE}")
        end

        # 全テストに登場する割込み番号をユニークにする
        aAllIntNo = []
        aAppModeInfo.each{|aTestInfo|
          aTestInfo[2].each{|snIntNo|
            if (!aAllIntNo.include?(snIntNo))
              aAllIntNo.push(snIntNo)
            end
          }
        }

        # 前のテストで割込みが保留となっている場合に備え，割込み要求をキャンセルする
        aAllIntNo.each{|snIntNo|
          cElement.set_code(@hMain, "#{FNC_CANCEL_INT_REQ}(#{snIntNo})")
        }

        nIndex = -1
        nTestNum = aAppModeInfo.size()
        aAppModeInfo.each{|aTestInfo|
          nIndex += 1
          if (@cConf.is_single?())
            cElement.set_code(@hMain, "if (#{VAR_BOOTCNT} == #{nIndex}) {", false)
          else
            cElement.set_code(@hMain, "if (#{VAR_BOOTCNT}[#{SS_GET_CORE_ID}()] == #{nIndex}) {", false)
          end

          cElement.set_code(@hMain, "#{AKTG_TB}#{FNC_OUTPUT_LOG_0}(\"\\n=== #{aTestInfo[0]} ===\")")
          cElement.set_code(@hMain, "#{AKTG_TB}#{FNC_OUTPUT_LOG_0}(\"[Test Number: #{nIndex + 1} / #{nTestNum}]\")")
          cElement.set_code(@hMain, "#{AKTG_TB}#{AKTG_FORCE_MERGE_BOOTCNT} = #{AKTG_FORCE_MERGE_ENUM}_#{aTestInfo[0]}")

          if (@cConf.is_single?())
            cElement.set_code(@hMain, "#{AKTG_TB}#{SS_START_OS}(#{aTestInfo[1]})")
          else
            if (@cConf.get_core_num() > 1)
              cElement.set_local_var(@hMain[:id], GRP_VAR_TYPE[TYP_STATUS], TYP_STATUS)
            end
            cElement.set_code(@hMain, "#{AKTG_TB}switch (#{SS_GET_CORE_ID}()) {", false)
            (0..@cConf.get_core_num()-1).each{|nCoreid|
              cElement.set_code(@hMain, "#{AKTG_TB}case #{AUTOSAR_CORE_ID_PREFIX}#{nCoreid}:", false)
              cElement.set_indent(1)
              # マスタコアでは，マスタコア以外の全コアにStartCoreを発行する
              if (nCoreid == @cConf.get_master_core())
                (0..@cConf.get_core_num()-1).each{|nID|
                  if (nID != @cConf.get_master_core())
                    cElement.set_code(@hMain, "#{AKTG_TB}#{SS_START_CORE}(#{AUTOSAR_CORE_ID_PREFIX}#{nID}, &ercd)")
                    cElement.set_code(@hMain, "#{AKTG_TB}#{FNC_CHECK_ERCD}(#{GRP_VAR_TYPE[TYP_STATUS]}, E_OK)")
                  end
                }
                cElement.set_code(@hMain, "#{AKTG_TB}#{SS_START_OS}(#{aTestInfo[1]})")
              # スレーブコアでは，DONOTCAREでStartOSを発行するのみ
              else
                cElement.set_code(@hMain, "#{AKTG_TB}#{SS_START_OS}(DONOTCARE)")
              end
              cElement.set_code(@hMain, "#{AKTG_TB}break")
              cElement.unset_indent()
            }
            cElement.set_code(@hMain, "#{AKTG_TB}}", false)
          end

          cElement.set_code(@hMain, "}", false)
          @aForceMergeEnum.push("#{AKTG_FORCE_MERGE_ENUM}_#{aTestInfo[0]}")
        }

        # マルチコアでは，最後のmain関数から呼び出す処理を行う
        if (@cConf.is_multi?())
          cElement.set_code(@hMain, FNC_CALL_FROM_LAST_MAIN_FUNC)
        end

        cElement.set_code(@hMain, "#{FNC_OUTPUT_LOG_0}(\"\\nKernel Exit...\")")
      end

      cElement.set_code(@hMain, FNC_INFINITE_LOOP)
      cElement.set_code(@hMain, "return 0")

      # ダミータスクは起動することがないため不正なチェックポイントを設定する
      cElement.set_checkpoint_zero(@hDummyTask)

      # ダミーリスタートタスクのコード設定
      if (!sRestartOsap.nil?())
        # リスタートタスク起動後，すぐTerminateTaskする
        cElement.set_syscall(@hDummyReTask, "#{SS_TER_TSK}()")
      end

      # エレメントを追加する
      add_element(cElement)
    end


    #================================================================
    # 概  要: IMCodeElementを中間コードに変換して保持する
    #================================================================
    def add_element(cElement)
      check_class(IMCodeElement, cElement, true) # IMCodeElementクラスのインスタンス

      if (cElement.nil?())
        return
      end

      aCode      = []    # 生成したコード情報を一時的に保持
      aCodeBlock = []    # ブロック単位でコード情報を保持
      bPassed    = false # バリア同期のシーケンス番号管理フラグ

      # ローカル変数の追加等が失敗しないように処理単位情報は最初に追加する
      cElement.aElement.each{|hElement|
        if (hElement[:atr] == :proc_unit)
          add_proc_unit(hElement)
        end
      }

      cElement.aElement.each{|hElement|
        # 属性によって異なる方法で中間コードを生成して格納する
        # コード情報は格納時の操作が複雑なので生成のみ行う
        case hElement[:atr]
        when :api
          sCode = "#{hElement[:var]} = #{hElement[:syscall]};"
        when :ercd
          sCode = "#{FNC_CHECK_ERCD}(#{hElement[:var]}, #{hElement[:ret]});"
        when :assert
          # 先頭が"~"だった場合，不等号でチェックする
          if (hElement[:value].is_a?(Integer) || (hElement[:value].index(TSR_NOT_SIGN) == nil))
            sCode = "#{FNC_CHECK_ASSERT}(#{hElement[:var]} == #{hElement[:value]});"
          else
            sTemp = hElement[:value].gsub(TSR_NOT_SIGN, "")
            sCode = "#{FNC_CHECK_ASSERT}(#{hElement[:var]} != #{sTemp});"
          end
        when :check
          nMasterCoreid = @cConf.get_master_core()
          @aCheckSeqCnt[nMasterCoreid] += 1
          sCode = "#{FNC_CHECK_POINT}(#{@aCheckSeqCnt[nMasterCoreid]});"
        when :check_mc
          @aCheckSeqCnt[hElement[:proc_unit][:coreid]] += 1
          sCode = "#{FNC_MC_CHECK_POINT}(#{AUTOSAR_CORE_ID_PREFIX}#{hElement[:proc_unit][:coreid]}, #{@aCheckSeqCnt[hElement[:proc_unit][:coreid]]});"
        when :wait
          nMasterCoreid = @cConf.get_master_core()
          sCode = "#{FNC_WAIT_CHECK_POINT}(#{@aCheckSeqCnt[nMasterCoreid]});"
        when :wait_mc
          sCode = "#{FNC_MC_WAIT_CHECK_POINT}(#{AUTOSAR_CORE_ID_PREFIX}#{hElement[:coreid]}, #{@aCheckSeqCnt[hElement[:coreid]]});"
        when :check_zero
          sCode = "#{FNC_CHECK_POINT}(0);"
        when :check_zero_mc
          sCode = "#{FNC_MC_CHECK_POINT}(#{AUTOSAR_CORE_ID_PREFIX}#{hElement[:proc_unit][:coreid]}, 0);"
        when :check_finish
          nMasterCoreid = @cConf.get_master_core()
          @aCheckSeqCnt[nMasterCoreid] += 1
          sCode = "#{FNC_CHECK_FINISH}(#{@aCheckSeqCnt[nMasterCoreid]});"
          # C++test終了
          if (@cConf.is_enable_cpptest?())
            sCode = "#{CPPTEST_FINAL};#{AKTG_NL}#{AKTG_TB}#{FNC_CHECK_FINISH}(#{@aCheckSeqCnt[nMasterCoreid]});"
          end
       when :check_finish_mc
          @aCheckSeqCnt[hElement[:proc_unit][:coreid]] += 1
          sCode = "#{FNC_MC_CHECK_FINISH}(#{AUTOSAR_CORE_ID_PREFIX}#{hElement[:proc_unit][:coreid]}, #{@aCheckSeqCnt[hElement[:proc_unit][:coreid]]});"
        when :barrier
          # 一つのエレメントで一回だけインクリメント
          if (bPassed != true)
            @nBarrierSeqCnt += 1
            bPassed = true
          end
          sCode = "#{FNC_BARRIER_SYNC}(#{@nBarrierSeqCnt}, #{hElement[:num]});"
        when :comment
          sCode = "/* #{hElement[:code]} */"
        when :expression, :statement
          sCode = "#{hElement[:code]}"
        when :localvar
          add_local_var(hElement)
          next
        when :globalvar
          add_global_var(hElement)
          next
        when :header
          add_header(hElement)
          next
        when :config
          add_config(hElement)
          next
        when :xml
          add_xml(hElement)
          next
        when :xml_osap
          add_xml_osap(hElement)
          next
        when :osap_hook
          set_osap_hook(hElement)
          next
        when :proc_unit
          # 処理単位情報は最初に処理済み
          next
        when :add_osap
          add_config(hElement, false)
          next
        when :delimiter_cmd
          # ブロックを分ける
          aCodeBlock.push(aCode)
          aCode = []
          next
        when :indent_cmd
          @nIndent = hElement[:num]
          next
        when :unindent_cmd
          @nIndent = 0
          next
        when :precode
          add_pre_code(hElement)
          next
        when :postcode
          add_post_code(hElement)
          next
        when :struct_def
          add_struct_def(hElement)
          next
        else
          abort(ERR_MSG % [__FILE__, __LINE__])
        end

        # インデント命令がオンになっている場合，インデントを行う
        sCode = AKTG_TB * @nIndent + sCode

        # コード情報を生成して一時的に保持する
        aCode.push([hElement[:proc_unit][:id], sCode, hElement[:proc_unit][:bootcnt], hElement[:proc_unit][:coreid], hElement[:atr]])
      }

      # ブロックを生成する
      aCodeBlock.push(aCode)

      # 空のブロックを取り除く
      aCodeBlock.delete_if{|aBlock|
        aBlock.empty?()
      }
      # 一つも残らなければリターン
      if (aCodeBlock.empty?())
        return
      end

      if (cElement.lMode == :block)
        sTestID = get_current_level()
        sCondition = get_current_level(sTestID)

        aCodeBlock.each{|aBlock|
          @nBlockSeqCnt += 1
          @aCode[AKTG_IDX_LAST][sTestID][AKTG_IDX_LAST][sCondition].push({IMC_BLOCK + "_#{@nBlockSeqCnt}" => aBlock})
        }
      else
        # commonモードの場合は共通部分にコード情報を格納する
        @aCode[0][IMC_COMMON][0][IMC_AKTG_MAIN].concat(aCodeBlock[0])
      end
    end


    #================================================================
    # 概  要: aCodeにテストIDレベルを追加する
    #================================================================
    def set_testid_level(sTestID)
      check_class(String, sTestID) # テストID

      # テストIDレベルを追加する
      @aCode.push({sTestID => []})
    end


    #================================================================
    # 概  要: aCodeにコンディションレベルを追加する
    #================================================================
    def set_condition_level(sCondition)
      check_class(String, sCondition) # Condition or do

      # 現在のテストIDレベルのキーを取得する
      sTestID = get_current_level()
      #コンディションレベルを追加する
      @aCode[AKTG_IDX_LAST][sTestID].push({sCondition => []})

    end


    #================================================================
    # 概  要: aCodeの指定したレベルのキー名を取得する
    #================================================================
    def get_current_level(sTestID = nil)
      check_class(String, sTestID, true)    # 現在のテストIDレベル

      if (sTestID.nil?())
        # 現在のテストIDレベルのキー名を返す
        return @aCode[AKTG_IDX_LAST].keys[0] # [String]レベルのキー名
      else
        # 現在のコンディションレベルのキー名を返す
        return @aCode[AKTG_IDX_LAST][sTestID][AKTG_IDX_LAST].keys[0] # [String]レベルのキー名
      end
    end
    private :get_current_level


    #================================================================
    # 概  要: 処理単位情報の追加を行う
    #================================================================
    def add_proc_unit(hElement)
      check_class(Hash, hElement) # 処理単位情報の要素

      @hProcUnitInfo[hElement[:proc_unit_id]] = {:localvar => {}, :fbootcnt => hElement[:fbootcnt], :precode => [], :postcode => []}
    end
    private :add_proc_unit


    #================================================================
    # 概  要: ローカル変数情報を中間表現のデータ構造に変換して保持する
    #================================================================
    def add_local_var(hElement)
      check_class(Hash, hElement) # ローカル変数情報の要素

      # 処理単位が登録されていなければエラー
      if (!@hProcUnitInfo.has_key?(hElement[:proc_unit_id]))
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      @hProcUnitInfo[hElement[:proc_unit_id]][:localvar].update({hElement[:name] => {:type => hElement[:type], :value => hElement[:value]}})
    end
    private :add_local_var


    #================================================================
    # 概  要: グローバル変数情報を中間表現のデータ構造に変換して保持す
    #         る
    #================================================================
    def add_global_var(hElement)
      check_class(Hash, hElement) # グローバル変数情報の要素

      @aGlobalVar.push([hElement[:name], hElement[:type], hElement[:value]])
      @aGlobalVar.uniq!()
    end
    private :add_global_var


    #================================================================
    # 概  要: 処理単位のプロトタイプ宣言を中間表現のデータ構造に変換し
    #         て保持する
    #================================================================
    def add_header(hElement)
      check_class(Hash, hElement) # プロトタイプ宣言情報の要素

      sFuncID = hElement[:proc_unit_id]

      case hElement[:type]
      # タスク，カテゴリ2ISR
      when TSR_OBJ_TASK, TSR_OBJ_C2ISR
        aArgs = ["#{sFuncID}"]
      # TEST_MAIN，CHECK_MAIN，同期関数，(個別)プロテクションフック
      when IMC_FUNC_TYPE, IMC_PROTECTION_TYPE, IMC_ERROR_TYPE
        aArgs = hElement[:args] || []
      end

      @aHeader.push([sFuncID, aArgs, hElement[:type]])
    end
    private :add_header


    #================================================================
    # 概  要: 静的APIの情報を中間表現のデータ構造に変換して保持する
    #================================================================
    def add_config(hElement, bIsCode = true)
      check_class(Hash, hElement) # 静的API情報の要素

      if (@cConf.enable_osap?())
        sOsap = hElement[:osap]
      else
        sOsap = IMC_NO_OSAP
      end

      if (!@hConfig.has_key?(sOsap))
        @hConfig[sOsap] = []
      end

      if (hElement.has_key?(:coreid))
        sCoreid = hElement[:coreid]
      else
        sCoreid = ""
      end

      # SC3/SC4/全MCではOSAP固有フックがない場合に備え，OSAP固有フック情報を初期化する
      if ((@cConf.enable_osap?()) && !@hOsapHook.has_key?(sOsap))
        if (sOsap.include?(AKTG_JUDGE_NON_TRUSTED) || sOsap.include?(AKTG_JUDGE_MC_NON_TRUSTED))
          bTrusted = false
        else
          bTrusted = true
        end
        @hOsapHook[sOsap] = {TSR_OBJ_STARTUP_HOOK_OSAP  => false,
                             TSR_OBJ_SHUTDOWN_HOOK_OSAP => false,
                             TSR_OBJ_ERROR_HOOK_OSAP    => false,
                             :trusted                   => bTrusted,
                             :coreid                    => sCoreid}
      end

      if (bIsCode == true)
        @hConfig[sOsap].push(hElement[:code])
      end
    end
    private :add_config


    #================================================================
    # 概  要: XML情報を中間表現データのREXMLインスタンスへ保持する
    #================================================================
    def add_xml(hElement)
      check_class(Hash, hElement) # XML情報の要素

      if (!@cConf.enable_osap?())
        sOsap = IMC_NO_OSAP
      else
        sOsap = hElement[:osap]
      end

      if (!@hOsapContainers.has_key?(sOsap))
        @hOsapContainers[sOsap] = []
      end
      @hOsapContainers[sOsap].push(hElement[:container])
    end
    private :add_xml


    #================================================================
    # 概  要: OSAPコンテナ用情報を中間表現データのインスタンスへ保持す
    #         る
    #================================================================
    def add_xml_osap(hElement)
      check_class(Hash, hElement) # OSAPコンテナ用情報の要素

      if (!@cConf.enable_osap?())
        sOsap = IMC_NO_OSAP
      else
        sOsap = hElement[:osap]
      end

      if (!@hOsapObject.has_key?(sOsap))
        @hOsapObject[sOsap] = []
      end

      if (hElement[:type] == TSR_OBJ_TRUSTED_FUNCTION)
        # :funcname，:sizeは信頼関数でのみ使用
        @hOsapObject[sOsap].push([hElement[:type], hElement[:id], hElement[:funcname], hElement[:size]])
      else
        @hOsapObject[sOsap].push([hElement[:type], hElement[:id]])
      end
    end
    private :add_xml_osap


    #================================================================
    # 概  要: OSAP固有のフック有無情報を中間表現データのインスタンスへ
    #         保持する
    #================================================================
    def set_osap_hook(hElement)
      check_class(Hash, hElement) # OSAP固有のフック有無情報の要素

      # 静的API用情報
      if (!@hOsapHook.has_key?(hElement[:osap]))
        if (GRP_OSAP_NON_TRUSTED_ISR_AVAILABLE_SC3.include?(hElement[:osap]))
          bTrusted = false
        else
          bTrusted = true
        end
        @hOsapHook[hElement[:osap]] = {TSR_OBJ_STARTUP_HOOK_OSAP  => false,
                                       TSR_OBJ_SHUTDOWN_HOOK_OSAP => false,
                                       TSR_OBJ_ERROR_HOOK_OSAP    => false,
                                       :trusted                   => bTrusted,
                                       :coreid                    => hElement[:coreid]}

        # OSAP固有のフック以外，同一OSAPに存在しなかった場合への対処
        if (!@hConfig.has_key?(hElement[:osap]))
          @hConfig[hElement[:osap]] = []
        end
        @hConfig[hElement[:osap]].push("")
      end
      @hOsapHook[hElement[:osap]][hElement[:type]] = true
    end
    private :set_osap_hook


    #================================================================
    # 概  要: 共有するスタックの必要最大数を更新する(信頼OSAP含む)
    #================================================================
    def update_stack_size(aStack)
      check_class(Array, aStack) # 必要なスタック数

      @aStack.each_with_index{|nStack, index|
        if (nStack < aStack[index])
          @aStack[index] = aStack[index]
        end
      }
    end


    #================================================================
    # 概  要: 共有する非信頼OSAPのスタックの必要最大数を更新する
    #================================================================
    def update_ustack_size(aUStack)
      check_class(Array, aUStack) # 必要なスタック数

      @aUStack.each_with_index{|nUStack, index|
        if (nUStack < aUStack[index])
          @aUStack[index] = aUStack[index]
        end
      }
    end


    #================================================================
    # 概  要: プレコード情報を中間表現のデータ構造に変換して保持する
    #================================================================
    def add_pre_code(hElement)
      check_class(Hash, hElement) # プレコード情報の要素

      # 処理単位が登録されていなければエラー
      if (!@hProcUnitInfo.has_key?(hElement[:proc_unit]))
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      @hProcUnitInfo[hElement[:proc_unit]][:precode].push(hElement[:code])
    end
    private :add_pre_code


    #================================================================
    # 概  要: ポストコード情報を中間表現のデータ構造に変換して保持する
    #================================================================
    def add_post_code(hElement)
      check_class(Hash, hElement) # ポストコード情報の要素

      # 処理単位が登録されていなければエラー
      if (!@hProcUnitInfo.has_key?(hElement[:proc_unit]))
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      @hProcUnitInfo[hElement[:proc_unit]][:postcode].push(hElement[:code])
    end
    private :add_post_code


    #================================================================
    # 概  要: 構造体情報を中間表現のデータ構造に変換して保持する
    #================================================================
    def add_struct_def(hElement)
      check_class(Hash, hElement) # 構造体情報の要素
      
      @hStructInfo[hElement[:name]] = {"typedef" => hElement[:typedef],
                                       "member"  => hElement[:member]}
    end
    private :add_struct_def


    #================================================================
    # 概  要: チェックポイントのシーケンス番号を初期化する
    #================================================================
    def reset_checkpoint()
      # 強制マージの場合は全コアのチェックポイントを初期化
      if (@cConf.enable_forced_merge() == true)
        @aCheckSeqCnt = Array.new(@cConf.get_core_num() + 1, 0)
        # マルチコアではバリア同期のシーケンス番号も初期化
        @nBarrierSeqCnt = 0
      end
    end


    #================================================================
    # 概  要: 全コアで呼び出されるフック用コードを作成する
    #================================================================
    def add_hook_code_for_all_core(cElement, sHookName, sHookType, sArg = "", bProtection = false)
      check_class(IMCodeElement, cElement) # IMCodeElementクラスのインスタンス
      check_class(String, sHookName)       # 対象フックの名前
      check_class(String, sHookType)       # 対象フックの種別
      check_class(String, sArg)            # 対象フックの引数
      check_class(Bool, bProtection)       # 対象フックがプロテクションフックかどうか

      hHookInfo = {:id => sHookName, :coreid => @cConf.get_master_core(), :bootcnt => AKTG_MAIN_BOOTCNT}
      cElement.set_proc_unit(sHookName, AKTG_MAIN_BOOTCNT)
      cElement.set_header(sHookName, sHookType)

      sRet = ""
      if (bProtection == true)
        sRet = "#{VAR_ERROR} = "
      end

      cElement.set_code(hHookInfo, "switch (#{SS_GET_CORE_ID}()) {", false)
      (0..@cConf.get_core_num()-1).each{|nCoreid|
        cElement.set_code(hHookInfo, "case #{AUTOSAR_CORE_ID_PREFIX}#{nCoreid}:", false)
        if (@cConf.enable_boot_only_master_core?() && nCoreid != @cConf.get_master_core())
          # boot_only_master_coreがtrueの場合，マスターコア以外は処理はなし
        else
          cElement.set_code(hHookInfo, "#{AKTG_TB}#{sRet}#{sHookName}_Core#{nCoreid}(#{sArg})")
        end
        cElement.set_code(hHookInfo, "#{AKTG_TB}break")
      }
      cElement.set_code(hHookInfo, "}", false)
    end
    private :add_hook_code_for_all_core


    #================================================================
    # 概  要: リスタートタスクの所属OSAPを保持する
    #================================================================
    def add_restart_task_osap(hReTaskInfo)
      check_class(Hash, hReTaskInfo) # リスタートタスクのOSAP情報
      @hRestartTask = hReTaskInfo.dup()
    end


    #================================================================
    # 概  要: IntermediateCodeをppより見やすい形で整形して出力する
    #================================================================
    def p_code(lOption = nil)
      check_class(Symbol, lOption, true) # 指定オプション

      # コード情報の出力
      puts "--- added CodeInfo ---"
      @aCode.each{ |hScenarios|
        hScenarios.each{ |sTestID, aTestIDLevel|
          puts "#{sTestID} => "
          aTestIDLevel.each{ |hScenario|
            hScenario.each{ |sCondition, aConditionLevel|
              puts "  #{sCondition} => "
              if (sCondition == IMC_AKTG_MAIN)
                aConditionLevel.each{ |aCodeInfo|
                  print "      "
                  p aCodeInfo
                }
              else
                aConditionLevel.each{ |hBlocks|
                  hBlocks.each{ |sBlock, aBlockLevel|
                    puts "    #{sBlock} => "
                    aBlockLevel.each{ |aCodeInfo|
                      print "      "
                      p aCodeInfo
                    }
                  }
                }
              end
            }
          }
        }
      }

      if (lOption == :all)
        require "pp.rb"
        puts ""
        print "@hProcUnitInfo = ".ljust(17); pp @hProcUnitInfo
        print "@aGlobalVar = ".ljust(17);    pp @aGlobalVar
        print "@aHeader = ".ljust(17);       pp @aHeader
        print "@hConfig = ".ljust(17);       pp @hConfig
        print "@nStack = ".ljust(17);        pp @nStack
      end
    end

  end
end
