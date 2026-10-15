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
# $Id: TestScenario.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/test_scenario/TestScenario.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: TestScenario
  # 概    要: PreCondition，Do，PostConditionのデータを保持
  #===================================================================
  class TestScenario
    include AKTFModule

    #=================================================================
    # 概  要: 構造チェック
    #=================================================================
    def basic_check(sTestID, hScenario)
      check_class(String, sTestID, true)   # テストID
      check_class(Object, hScenario, true) # テストシナリオ(T1_004でチェック)

      aErrors = []
      ### T1_003: テストIDの文字列が不正
      if (sTestID !~ TSR_REX_TEST_ID)
        sErr = sprintf("T1_003: " + ERR_INVALID_TESTID, sTestID)
        aErrors.push(YamlError.new(sErr))
      else
        AKTG_GRP_LBL_RESERVED.each{|sLabel|
          ### T1_026: テストIDが予約語(AKTG_，ErrorHook)から始まる
          if (sTestID =~ /^#{sLabel}/i)
            sErr = sprintf("T1_026: " + ERR_INVALID_TESTID_PREFIX, sTestID)
            aErrors.push(YamlError.new(sErr))
          end
        }
      end

      aPath = [sTestID]

      # do，post_conditionのチェック
      bExistPre = false
      bExistProperty = false
      aSeqDo = []
      aSeqPost = []
      hScenario.each{|sCondition, shCondition|
        case sCondition
        # pre_condition
        when TSR_LBL_PRE
          bExistPre = true
          ### T1_007: pre_conditionがHashではない
          if (!shCondition.is_a?(Hash))
            sErr = sprintf("T1_007: " + ERR_INVALID_TYPE, TSR_LBL_PRE, Hash, shCondition.class())
            aErrors.push(YamlError.new(sErr, aPath + [sCondition]))
          end

        # do
        when TSR_REX_PRE_DO
          nSeqNum = $1.to_i()
          ### T1_009: doのシーケンス番号が二重に定義されている
          if (aSeqDo.include?(nSeqNum))
            sErr = sprintf("T1_009: " + ERR_CONDITION_MULTIPLE, TSR_LBL_DO, nSeqNum)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          aSeqDo.push(nSeqNum)

          ### T1_010: doがHashかnilではない
          if (!shCondition.nil?() && !shCondition.is_a?(Hash))
            sErr = sprintf("T1_010: " + ERR_INVALID_TYPE_NIL, TSR_LBL_DO, Hash, shCondition.class())
            aErrors.push(YamlError.new(sErr, aPath + [sCondition]))
          end

        # post_condition
        when TSR_REX_PRE_POST
          nSeqNum = $1.to_i()
          ### T1_011: post_conditionのシーケンス番号が二重に定義されている
          if (aSeqPost.include?(nSeqNum))
            sErr = sprintf("T1_011: " + ERR_CONDITION_MULTIPLE, TSR_LBL_POST, nSeqNum)
            aErrors.push(YamlError.new(sErr, aPath))
          end
          aSeqPost.push(nSeqNum)

          ### T1_012: post_conditionがHashかnilではない
          if (!shCondition.nil?() && !shCondition.is_a?(Hash))
            sErr = sprintf("T1_012: " + ERR_INVALID_TYPE_NIL, TSR_LBL_POST, Hash, shCondition.class())
            aErrors.push(YamlError.new(sErr, aPath + [sCondition]))
          end

        # property
        when TSR_LBL_PROPERTY
          bExistProperty = true
          begin
              property_check(hScenario[TSR_LBL_PROPERTY], aPath)
          rescue AKTFMultiError
            aErrors.concat($!.aErrors)
          end

        ### T1_005: テストシナリオ内不正なキーが指定されている
        else
          sErr = sprintf("T1_005: " + ERR_CONDITION_UNDEFINED, sCondition)
          aErrors.push(YamlError.new(sErr, aPath))
        end
      }

      ### T1_006: pre_conditionが存在しない
      if (bExistPre == false)
        sErr = sprintf("T1_006: " + ERR_CONDITION_NOT_EXIST, TSR_LBL_PRE)
        aErrors.push(YamlError.new(sErr, aPath))
      end
      ### T1_027: propertyが存在しない
      if (bExistProperty == false)
        sErr = sprintf("T1_027: " + ERR_CONDITION_NOT_EXIST, TSR_LBL_PROPERTY)
        aErrors.push(YamlError.new(sErr, aPath))
      end
      ### T1_008: doが存在しない
      if (aSeqDo.empty?())
        sErr = sprintf("T1_008: " + ERR_CONDITION_NOT_EXIST, TSR_LBL_DO)
        aErrors.push(YamlError.new(sErr, aPath))
      else
        ### T1_013: doとpost_conditionのシーケンス番号が対応していない
        if (aSeqDo.uniq.sort() != aSeqPost.uniq.sort())
          aErrors.push(YamlError.new("T1_013: " + ERR_CONDITION_NOT_MATCH, aPath))
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: プロパティチェック
    #=================================================================
    def property_check(hProperty, aPath)
      check_class(Object, hProperty, true) # プロパティ(T1_020でチェックを行う)
      check_class(Array, aPath)            # ルートからのパス

      aErrors = []
      aNewPath = aPath + [TSR_LBL_PROPERTY]
      ### T1_020: propertyがHashではない
      if (!hProperty.is_a?(Hash))
        sErr = sprintf("T1_020: " + ERR_INVALID_TYPE, TSR_LBL_PROPERTY, Hash, hProperty.class())
        aErrors.push(YamlError.new(sErr, aNewPath))
      else
        ### T6_001: propertyにscが存在しない
        if (!hProperty.key?(TSR_PRM_PRO_SC))
          sErr = sprintf("T6_001: " + ERR_CONDITION_NOT_EXIST, TSR_PRM_PRO_SC)
          aErrors.push(YamlError.new(sErr, aPath))
        end

        hProperty.each{|sAtr, val|
          case sAtr
          # sc
          when TSR_PRM_PRO_SC
            check_property_type(sAtr, val, Array, true, aNewPath)
            ### T6_005: propertyの設定値が有効値でない
            if (val.is_a?(Array) && (!val.all? {|sStr| GRP_SCALABILITY_CLASS.include?(sStr)}))
              sErr = sprintf("T6_005: " + ERR_PROPERTY_INVALID_VALUE, sAtr, val.join(", "))
              aErrors.push(YamlError.new(sErr, aNewPath))
            end

          # 真偽値
          # need_enadis_interrupt_source
          when TSR_PRM_NEED_ENADIS_INT_SOURCE, TSR_PRM_NEED_STACK_SHARE, TSR_PRM_MAINTASK_WAIT,
               TSR_PRM_ADD_OSAP_ERR_HOOK,TSR_PRM_SINGLE_ONLY, TSR_PRM_EXTENDED_RETURN_STATUS
            check_property_type(sAtr, val, Bool, false, aNewPath)

          # 整数
          # violation_handling_level, timing_protection_level, memory_protection_level
          when TSR_PRM_VIOLATION_HANDLING_LEVEL, TSR_PRM_TIMING_PROTECTION_LEVEL,
               TSR_PRM_MEMORY_PROTECTION_LEVEL
            if (val =~ AKTF_REX_NUM)
              val = val.to_i()
            end
            check_property_type(sAtr, val, Integer, false, aNewPath)
            ### T6_005: propertyの設定値が有効値でない
            if (val != 1 && val != 2 && val != 3)
              sErr = sprintf("T6_005: " + ERR_PROPERTY_INVALID_VALUE, sAtr, val)
              aErrors.push(YamlError.new(sErr, aNewPath))
            end

          # 文字列
          when TSR_PRM_PRO_APPMODE
             check_property_type(sAtr, val, String, false, aNewPath)

          ### T6_006: propertyに未定義のkeyが存在する
          else
            sErr = sprintf("T6_006: " + ERR_PROPERTY_UNDEFINED_KEY, sAtr)
            aErrors.push(YamlError.new(sErr, aNewPath))
          end
        }
      end

      check_error(aErrors)
    end
    private :property_check

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        begin
          cCondition.attribute_check()
        rescue AKTFMultiError
          aErrors.concat($!.aErrors)
        end
      }
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: オブジェクトチェック
    #=================================================================
    def object_check()
      aErrors = []
      begin
        @cPreCondition.object_check(true)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end
      @aDo_PostCondition.each{|cCondition|
        begin
          cCondition.object_check()
        rescue AKTFMultiError
          aErrors.concat($!.aErrors)
        end
      }
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: コンディションチェック
    #=================================================================
    def condition_check()
      aErrors = []
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        begin
          cCondition.condition_check(@bCannotMerge)
        rescue AKTFMultiError
          aErrors.concat($!.aErrors)
          break
        end
      }
      begin
        aCondition[AKTG_IDX_LAST].last_condition_check()
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end
      check_error(aErrors)
    end

    #=================================================================
    # 概  要: シナリオチェック
    #=================================================================
    def scenario_check()
      aErrors = []

      # pre_conditionのチェック
      ### T5_006: 以下の条件が揃う場合に，C2ISR，ICISRのistat，intatrにAK_DISABLEが指定されている
      ###         * TESRYデータのpropertyにneed_enadis_interrupt_sourceが指定されていない，もしくはfalseが指定されている
      ###         * configure.yamlのsupport_enadis_interrupt_sourceにfalseが指定されている
      hIsrAtr = get_isr_intatr_and_istat(@cPreCondition)
      if (!hIsrAtr.nil?() && (@cConf.is_support_enadis_int_source?() != true))
        hIsrAtr.each{|sObjectID, aAtr|
          if ((aAtr.include?(TSR_STT_DISABLE)) &&
              (@hProperty[TSR_PRM_NEED_ENADIS_INT_SOURCE] != true))
            aPath = @cPreCondition.get_condition_path()
            aErrors.push(YamlError.new("T5_006: " + ERR_CANT_RAISE_INT, aPath))
          end
        }
      end

      aPreVarNames   = @cPreCondition.get_variable_names()
      cPrevCondition = @cPreCondition
      @aDo_PostCondition.each_with_index{|cCondition, nIndex|
        # doのチェック
        aPath = cCondition.get_do_path()
        # id
        bNoObjectFlg = false
        sCallerObject = cCondition.hDo[TSR_PRM_ID]
        if (cPrevCondition.hAllObject.has_key?(sCallerObject))
          cPrevCaller      = cPrevCondition.hAllObject[sCallerObject]
          nCoreid          = cPrevCondition.get_process_coreid(cPrevCaller)
          aActivateProcess = cPrevCondition.get_activate_process_unit_by_coreid()
          if (GRP_PROCESS_UNIT_ALL.include?(cPrevCaller.sObjectType))
            # システムサービスを発行できる処理単位かチェック
            if (cPrevCaller != aActivateProcess[nCoreid])
              ### T5_005: doでシステムサービスを発行するオブジェクトが直前の状態で実行状態でない
              sErr = sprintf("T5_005: " + ERR_OBJECT_NOT_ACTIVATE_PREV, sCallerObject)
              aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_ID]))
            end
          else
          ### T5_004: doでシステムサービスを発行するオブジェクトが処理単位でない
            sErr = sprintf("T5_004: " + ERR_TARGET_NOT_PROCESS_UNIT, sCallerObject)
            aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_ID]))
          end
        ### T5_003: doでシステムサービスを発行するオブジェクトが存在しない
        else
          sErr = sprintf("T5_003: " + ERR_OBJECT_NOT_DEFINED_IN_PRE, sCallerObject)
          aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_ID]))
          bNoObjectFlg = true
        end

        # post_conditionのチェック
        aPath = cCondition.get_condition_path()

        ### T5_006: 以下の条件が揃う場合に，C2ISR，ICISRのistat，intatrにAK_DISABLEが指定されている
        ###         * TESRYデータのpropertyにneed_enadis_interrupt_sourceが指定されていない，もしくはfalseが指定されている
        ###         * configure.yamlのsupport_enadis_interrupt_sourceにfalseが指定されている
        hIsrAtr = get_isr_intatr_and_istat(cCondition)
        if (!hIsrAtr.nil?() && (@cConf.is_support_enadis_int_source?() != true))
          hIsrAtr.each{|sObjectID, aAtr|
            if ((aAtr.include?(TSR_STT_DISABLE)) &&
                (@hProperty[TSR_PRM_NEED_ENADIS_INT_SOURCE] != true))
              aErrors.push(YamlError.new("T5_006: " + ERR_CANT_RAISE_INT, aPath))
            end
          }
        end

        # エラーコード指定
        bErrorFlg = false
        sSyssrv = cCondition.hDo[TSR_PRM_SYSSRV].scan(/^\w*/).join()
        sCallerObject = cCondition.hDo[TSR_PRM_ID]
        sReturnValue = cCondition.hDo[TSR_PRM_RETTYPE]
        if (GRP_SYSSRV_RTN_VAL.include?(sSyssrv) && sReturnValue.nil?())
            bErrorFlg = true
        # TerminateTaskとChainTaskは，正常終了の場合は戻り値がないため，他の戻り値があるシステムサービスとチェック方法が異なる
        elsif ((sSyssrv == SS_TER_TSK || sSyssrv == SS_CHAIN_TSK) && bNoObjectFlg == false)
          aCondition = get_all_condition()
          cPrevCondition = aCondition[nIndex]
          nPrevBootcnt = cPrevCondition.hAllObject[sCallerObject].hState[TSR_PRM_BOOTCNT]
          nBootcnt = cCondition.hAllObject[sCallerObject].hState[TSR_PRM_BOOTCNT]
          # TerminateTaskの場合，呼出し元は休止状態となるため，post_conditionで呼出し元が実行状態の場合はエラーとなる
          if (sSyssrv == SS_TER_TSK && cCondition.hAllObject[sCallerObject].is_activate?() && sReturnValue.nil?())
            bErrorFlg = true
            # ポストタスクフックがpost_conditionで実行状態の場合，エラーとならない
            hPosttaskHook = cCondition.get_objects_by_type(TSR_OBJ_POSTTASK_HOOK)
            hPosttaskHook.each{|sObjectId, cObjectInfo|
              if (cObjectInfo.is_activate?())
                bErrorFlg = false
              end
            }
            # 起動回数(bootcnt)が異なる場合，エラーとならない
            if (nPrevBootcnt != nBootcnt)
              bErrorFlg = false
            end
          # ChainTaskの場合，呼出し元がpost_conditionで実行状態，かつ，起動回数(bootcnt)がChainTaskの呼出し前と同じ場合はエラーとなる
          elsif (sSyssrv == SS_CHAIN_TSK && cCondition.hAllObject[sCallerObject].is_activate?() && nPrevBootcnt == nBootcnt && sReturnValue.nil?())
            bErrorFlg = true
          end
        end
        ### T3_DO004: 返り値を返せるシステムサービスであるのに，rettypeとretvalが指定されていない
        if (bErrorFlg == true)
          sErr = sprintf("T3_DO004: " + ERR_NEED_RTYPE_AND_RVAL, sSyssrv)
          aErrors.push(YamlError.new(sErr, aPath))
        end

        # 直前のコンディション
        cPrevCondition = cCondition
      }

      # Multi限定
      if (@cConf.is_multi?())
        # running-waitspin
        aCondition = [@cPreCondition, @aDo_PostCondition.last()]
        aCondition.each{|cCondition|
          hObjects = cCondition.get_objects_by_type([TSR_OBJ_TASK,TSR_OBJ_C2ISR,TSR_OBJ_ICISR])
          hObjects.each{|sObjectID, cObjectInfo|
            ### T5_MC_001: pre_conditionおよび最後のpost_conditionに存在するタスクのtstatがAK_RUNNING_WAITSPIN，またはC2ISR/ICISRのrtnstatがAK_ACTIVATE_WAITSPINである
            if (cObjectInfo.is_spinlock_waiting?())
              if (cObjectInfo.sObjectType == TSR_OBJ_TASK)
                sErr = sprintf("T5_MC_001: " + ERR_RUNNING_WAITSPIN, TSR_PRM_TSTAT, TSR_STT_RUNNING_WAITSPIN)
              else
                sErr = sprintf("T5_MC_001: " + ERR_RUNNING_WAITSPIN, TSR_PRM_RTNSTAT, TSR_STT_ACTIVETE_WAITSPIN)
              end
              aPath = cCondition.get_condition_path() + [sObjectID, TSR_PRM_TSTAT]
              aErrors.push(YamlError.new(sErr, aPath))
            end
          }
        }
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: コアIDのマクロチェック
    #=================================================================
    def core_id_macro_check()
      aMacro = get_all_coreid()
      ### T5_MC_002: coreidに指定するマクロがCORE_OTHERとCORE_OTHER_1・CORE_THIRDのいずれかと同時に指定されている
      if (aMacro.include?(CFG_MCR_CORE_OTHER) && (aMacro.include?(CFG_MCR_CORE_OTHER_1) || aMacro.include?(CFG_MCR_CORE_THIRD)))
        # 使用しているコアIDのマクロで，エラーとなったマクロを表示する
        aMacro.delete(CFG_MCR_CORE_SELF)
        aMacro = aMacro.reject(){|val|
          !(val =~ /^CORE_/)
        }
        aMacro = aMacro.uniq().sort()
        sErr = sprintf("T5_MC_002: " + ERR_COREID_MACRO_COMBINATION, aMacro.join(", "))
        raise(YamlError.new(sErr, [@sTestID]))
      end
    end

    #=================================================================
    # 概  要: 全てのマクロを置換する(不正IDマクロ以外)
    #=================================================================
    def convert_macro()
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        cCondition.convert_macro()
      }
    end

    #=================================================================
    # 概  要: 全てのpost_conditionの補完を実行する
    #=================================================================
    def complement()
      # デフォルト値補完
      @cPreCondition.complement_init_object_info()
      # 直前の状態から補完
      cPrevCondition = @cPreCondition
      @aDo_PostCondition.each{|cCondition|
        cCondition.complement(cPrevCondition)
        cPrevCondition = cCondition
      }
      # 後処理
      @cPreCondition.complement_after()
      cPrevCondition = @cPreCondition
      @aDo_PostCondition.each{|cCondition|
        cCondition.complement_after()
      }
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias()
      hAlias = @cPreCondition.get_alias(@bSingleTest)
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        cCondition.alias(hAlias)
      }
      if (!@hProperty[TSR_PRM_PRO_APPMODE].nil?())
        @hProperty[TSR_PRM_PRO_APPMODE] = alias_replace(@hProperty[TSR_PRM_PRO_APPMODE], hAlias)
      end
    end

    #=================================================================
    # 概  要: テストシナリオの内容をYAMLオブジェクトに変換して返す
    #=================================================================
    def to_yaml()
      hYaml = {}
      hYaml[@sTestID] = Hash.new{|hash, key|
        hash[key] = {}
      }
      # pre_condition
      hYaml[@sTestID][TSR_LBL_PRE] = @cPreCondition.to_yaml(true)
      # do，post_condition
      @aDo_PostCondition.each{|cCondition|
        sDoSeq    = "#{TSR_UNS_DO}#{cCondition.nSeqNum}"
        sPostSeq  = "#{TSR_UNS_POST}#{cCondition.nSeqNum}"
        hYaml[@sTestID][sDoSeq]   = cCondition.hDo
        hYaml[@sTestID][sPostSeq] = cCondition.to_yaml()
      }
      return safe_dup(hYaml)  # [Hash]YAMLオブジェクト
    end

    #=================================================================
    # 概  要: フィルタリング
    #=================================================================
    def filtering()

      aErrors = []

      ### F_P001: configureのスケーラビリティクラスと一致しない
      if (!@hProperty[TSR_PRM_PRO_SC].nil?() && !@hProperty[TSR_PRM_PRO_SC].include?(@cConf.get_scalability_class))
        sErr = sprintf("F_P001: " + ERR_PROPERTY_UNMATCH, CFG_SCALABILITY_CLASS)
        aErrors.push(AKTFExcludeError.new(sErr, :F_P001))
      end

      # ATK2-SC3-TPのフィルタリング
      if (@cConf.is_time_partitioning?())

        ### F_019: OsTaskResourceRef が内部リソースを指定し、他のOSAPに所属するタスクが同じリソースを指定
        # タスクの情報からフィルタリングチェック
        @cPreCondition.get_objects_by_type(TSR_OBJ_TASK).each{|sTaskID1, hTaskInfo1|
          sTaskOsap1 = hTaskInfo1.hState[TSR_PRM_OSAP]
          # タスクがリソースを指定しているかチェック
          if (hTaskInfo1.has_relres?())
            hTaskInfo1.hState[TSR_PRM_RELRES].each{|sRes1|
              cResInfo = @cPreCondition.hAllObject[sRes1]
              # タスクの指定するリソースが内部リソースであるかチェック
              if (cResInfo.hState[TSR_PRM_RESPROP] == TSR_STT_INTERNAL)
                @cPreCondition.get_objects_by_type(TSR_OBJ_TASK).each{|sTaskID2, hTaskInfo2|
                  # 異なるOSAPに所属している他のタスクが，同じリソースを指定している場合，除外
                  if (hTaskInfo2.has_relres?() \
                      && sTaskID1 != sTaskID2 \
                      && sTaskOsap1 != hTaskInfo2.hState[TSR_PRM_OSAP] \
                      && hTaskInfo2.hState[TSR_PRM_RELRES].include?(sRes1))
                    sErr = sprintf("F_019: internal resource OsResource must be assigned at most one OSAP but OsApplication refers")
                    aErrors.push(AKTFExcludeError.new(sErr, :F_019))
                  end
                }
              end
              
              ### F_020: 非信頼OSAPに所属するタスクが OsTaskResourceRef で指定したリソースが異なるOSAPに所属するタスクもしくはC2ISRが指定
              # タスクが非信頼OSAPに所属しているかチェック
              if (sTaskOsap1.include?(AKTG_JUDGE_NON_TRUSTED))
                @cPreCondition.get_objects_by_type([TSR_OBJ_TASK, TSR_OBJ_C2ISR]).each{|sID2, hInfo2|
                  # タスクのOSAPと異なるOSAPに所属するタスクもしくはC2ISRからリソースが参照されたら除外
                  if (hInfo2.has_relres?() \
                      && sTaskID1 != sID2 \
                      && sTaskOsap1 != hInfo2.hState[TSR_PRM_OSAP] \
                      && hInfo2.hState[TSR_PRM_RELRES].include?(sRes1))
                    sErr = sprintf("F_020: OsTaskResourceRef should not defined as Multiple untrusted OsApplications refer to the OsResource")
                    aErrors.push(AKTFExcludeError.new(sErr, :F_020))
                  end
                }
              end
            }
          end
        }

        ### F_021: OsResourceAccesingAplication のCFGエラー
        # リソースの情報からフィルタリングのチェック
        @cPreCondition.get_objects_by_type(TSR_OBJ_RESOURCE).each{|sResID, hResInfo|
          check_cnt = 0
          # リソースがACCOSAPを指定しているかチェック
          if (!hResInfo.hState[TSR_PRM_ACCOSAP].nil?)
            # ACCOSAPが2つ以上かチェック
            if(hResInfo.hState[TSR_PRM_ACCOSAP].length > 1)
              hResInfo.hState[TSR_PRM_ACCOSAP].each{|sResAccOsap|
                # リソースのACCOSAPが非信頼OSAPかチェック
                if (sResAccOsap.include?(AKTG_JUDGE_NON_TRUSTED))
                  sErr = sprintf("F_025: Multi")
                  aErrors.push(AKTFExcludeError.new(sErr, :F_025))
                end
              }
            end
            hResInfo.hState[TSR_PRM_ACCOSAP].each{|sResAccOsap|
              # リソースのACCOSAPが非信頼OSAPかチェック
              if (sResAccOsap.include?(AKTG_JUDGE_NON_TRUSTED))
                @cPreCondition.get_objects_by_type(TSR_OBJ_TASK).each{|sTaskID, hTaskInfo|
                  # 全タスクの中から、このリソースを指定しており、リソースのACCOSAPと同じOSAPのタスクがあるかチェック
                  if (hTaskInfo.has_relres?() \
                      && hTaskInfo.hState[TSR_PRM_RELRES].include?(sResID) \
                      && sResAccOsap == hTaskInfo.hState[TSR_PRM_OSAP])
                    check_cnt = 1
                  end
                }
              end
            }
            # リソースを指定するタスクが一つもない場合、除外
            if (check_cnt == 0)
              sErr = sprintf("F_021: OsTaskResourceRef and OsResourceAccessingApplication are not consistent for OsResource")
              aErrors.push(AKTFExcludeError.new(sErr, :F_021))
            end
            hResInfo.hState[TSR_PRM_ACCOSAP].each{|sResAccOsap|
              check_cnt = 0
              @cPreCondition.get_objects_by_type([TSR_OBJ_TASK, TSR_OBJ_C2ISR]).each{|sID, hInfo|
                # タスク・C2ISRがリソースを指定しているかチェック
                if (hInfo.has_relres?() \
                    && hInfo.hState[TSR_PRM_RELRES].include?(sResID))
                  # リソースのACCOSAPで指定したOSAPの集合にタスク・C2ISRが所属するOSAPがない場合，除外
                  if (!hResInfo.hState[TSR_PRM_ACCOSAP].include?(hInfo.hState[TSR_PRM_OSAP]))
                    sErr = sprintf("F_021: OsTaskResourceRef and OsResourceAccessingApplication are not consistent for OsResource")
                    aErrors.push(AKTFExcludeError.new(sErr, :F_021))
                  end
                  # ACCOSAP指定の各OSAP毎にリソースを指定するタスク・C2ISRがあるかチェック
                  if (sResAccOsap == hInfo.hState[TSR_PRM_OSAP])
                    check_cnt = 1
                  end
                end
              }
              # ACCOSAPでOSAPを指定しているが，そのOSAPに所属するタスク・C2ISRが何一つリソースを指定していない場合，除外
              if (check_cnt == 0)
                sErr = sprintf("F_021: OsTaskResourceRef and OsResourceAccessingApplication are not consistent for OsResource")
                aErrors.push(AKTFExcludeError.new(sErr, :F_021))
              end
            }
          # リソースがACCOSAPを指定していない場合
          else
            @cPreCondition.get_objects_by_type([TSR_OBJ_TASK, TSR_OBJ_C2ISR]).each{|sTaskID, hTaskInfo|
              # リソースを指定しているタスクがOSAPに所属している場合，除外
              if (hTaskInfo.has_relres?() \
                  && hTaskInfo.hState[TSR_PRM_RELRES].include?(sResID))
                sErr = sprintf("F_021: OsTaskResourceRef and OsResourceAccessingApplication are not consistent for OsResource")
                aErrors.push(AKTFExcludeError.new(sErr, :F_021))
              end
            }
          end
        }

        ### F_022: SuspendOsInterrupts による機能仕様のエラー(TP機能付きOSのみ)
        # pre_conditionにおいてINT_STATEで非信頼OSAP所属処理単位を指定している場合，除外
        @cPreCondition.get_objects_by_type(TSR_OBJ_INT_STATE).each{|sIntID, hIntInfo|
          hIntInfo.hState[TSR_PRM_ISTAT].each{|hIntIstat|
            hIntIstat.each{|sIstatID, sIstatInfo|
              # INT_STATEのistatにAK_SUS_OS_INTがあるかチェック
              if(sIstatID == TSR_STT_SUS_OS_INT)
                sOsap = @cPreCondition.hAllObject[sIstatInfo].hState[TSR_PRM_OSAP]
                # AK_SUS_OS_INTに指定される処理単位が非信頼OSAPに所属している場合，除外
                if (!sOsap.nil? && sOsap.include?(AKTG_JUDGE_NON_TRUSTED))
                  sErr = sprintf("F_022: SuspendOSInterrupts error")
                  aErrors.push(AKTFExcludeError.new(sErr, :F_022))
                end
              end
            }
          }
        }
        # doにおいて非信頼OSAP所属処理単位がSuspendOSInterruptsを実行している場合，除外
        @aDo_PostCondition.each{|cCondition|
          sOsap = @cPreCondition.hAllObject[cCondition.hDo[TSR_PRM_ID]].hState[TSR_PRM_OSAP]
          if (!sOsap.nil? \
              && sOsap.include?(AKTG_JUDGE_NON_TRUSTED) \
              && cCondition.hDo[TSR_PRM_SYSSRV].include?(SS_SUS_OS_INT))
            sErr = sprintf("F_022: SuspendOSInterrupts error")
            aErrors.push(AKTFExcludeError.new(sErr, :F_022))
          end
        }
        # post_conditionにおいて，INT_STATEを定義している場合は，ソースコードでSuspendOSInterruptsを使用しない為，除外の必要性はなし
      end

      ### F_017: configureのコンフォーマンスクラスでは実行不可
      sCc = @cConf.get_conformance_class()
      # conformance_classがECC2の場合，すべてのTESRYが対象となるためチェックしない
      if (sCc != CFG_CONFORMANCE_CLASS_ECC2)
        if (check_conformance_class(sCc) == true)
          sErr = sprintf("F_017: " + ERR_PROPERTY_UNMATCH, CFG_CONFORMANCE_CLASS)
          aErrors.push(AKTFExcludeError.new(sErr, :F_017))
        end
      end

      ### F_018: configureのtarget_specでは実行不可
      aTargetSpec = @cConf.get_target_spec
      if (!aTargetSpec.include?(CFG_TARGET_SPEC_NOS))
        # configureのテスト対象にNOSが含まれて居ない場合，TESRYの対象がNOSでないかチェックする
        if (check_target_spec_nos() == true)
          sErr = sprintf("F_018: " + ERR_PROPERTY_NOT_MATCH_TARGET_SPEC, CFG_TARGET_SPEC_NOS)
          aErrors.push(AKTFExcludeError.new(sErr, :F_018))
        end
      end
      if (!aTargetSpec.include?(CFG_TARGET_SPEC_IOS))
        # configureのテスト対象にNOSが含まれて居ない場合，TESRYの対象がIOSでないかチェックする
        if (check_target_spec_ios() == true)
          sErr = sprintf("F_018: " + ERR_PROPERTY_NOT_MATCH_TARGET_SPEC, CFG_TARGET_SPEC_IOS)
          aErrors.push(AKTFExcludeError.new(sErr, :F_018))
        end
      end

      ### F_001: 割込み発生関数が必要であるが使用不可
      if (!(@cConf.enable_func_interrupt()) && exist_interrupt_handler?())
        sErr = sprintf("F_001: " + ERR_PROPERTY_NO_FUNC, CFG_FUNC_INTERRUPT)
        aErrors.push(AKTFExcludeError.new(sErr, :F_001))
      end

      ### F_002: ハードウェアカウンタが必要であるが使用不可
      if (!(@cConf.enable_func_hardware_counter()) && exist_hardware_counter?())
        sErr = sprintf("F_002: " + ERR_PROPERTY_NO_FUNC, CFG_HARDWARE_COUNTER)
        aErrors.push(AKTFExcludeError.new(sErr, :F_002))
      end

      ### F_003: プロテクションフックが必要であるが使用不可
      if (!(@cConf.enable_func_protection_hook()) && exist_protection_hook?())
        sErr = sprintf("F_003: " + ERR_PROPERTY_NO_FUNC, CFG_FUNC_PROTECTION_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_003))
      end

      ### F_004: 標準エラーのみ実行可能であるが拡張エラーが含まれている
      if (@cConf.is_return_status_standard?() && (@hProperty[TSR_PRM_EXTENDED_RETURN_STATUS] == true || exist_extended_retern_status?()))
        sErr = sprintf("F_004: " + ERR_PROPERTY_UNMATCH, CFG_RETURN_STATUS)
        aErrors.push(AKTFExcludeError.new(sErr, :F_004))
      end

      ### F_005: スタートアップフックが必要であるが使用不可
      if ((!@cConf.enable_startup_hook()) && exist_startup_hook?())
        sErr = sprintf("F_005: " + ERR_PROPERTY_NO_FUNC, CFG_STARTUP_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_005))
      end

      ### F_006: シャットダウンフックが必要であるが使用不可
      if (!(@cConf.enable_shutdown_hook()) && exist_shutdown_hook?())
        sErr = sprintf("F_006: " + ERR_PROPERTY_NO_FUNC, CFG_SHUTDOWN_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_006))
      end

      ### F_007: プレタスクフックが必要であるが使用不可
      if (!(@cConf.enable_pre_task_hook()) && exist_pre_task_hook?())
        sErr = sprintf("F_007: " + ERR_PROPERTY_NO_FUNC, CFG_PRE_TASK_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_007))
      end

      ### F_008: ポストタスクフックが必要であるが使用不可
      if (!(@cConf.enable_post_task_hook()) && exist_post_task_hook?())
        sErr = sprintf("F_008: " + ERR_PROPERTY_NO_FUNC, CFG_POST_TASK_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_008))
      end

      ### F_009: エラーフックが必要であるが使用不可
      if (!(@cConf.enable_error_hook()) && exist_error_hook?())
        sErr = sprintf("F_009: " + ERR_PROPERTY_NO_FUNC, CFG_ERROR_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_009))
      end

      ### F_010: プロテクションフックが必要であるが使用不可
      if (!(@cConf.enable_protection_hook()) && exist_protection_hook?())
        sErr = sprintf("F_010: " + ERR_PROPERTY_NO_FUNC, CFG_PROTECTION_HOOK)
        aErrors.push(AKTFExcludeError.new(sErr, :F_010))
      end

      ### F_P004: システムサービスのEnableInterruptSource/DisableInterruptSourceが必要であるが，使用不可
      if (@hProperty[TSR_PRM_NEED_ENADIS_INT_SOURCE] == true && @cConf.is_support_enadis_int_source?() == false)
        aErrors.push(AKTFExcludeError.new("F_P004: " + ERR_PROPERTY_NOT_SUPPORT_ENADIS_INT_SRC, :F_P004))
      end

      ### F_011: 複数のテストケースの中に，マージ不可のテストケースが含まれている
      if ((@bCannotMerge == true) && (@bSingleTest == false) && (@cConf.enable_forced_merge() == false))
        aErrors.push(AKTFExcludeError.new("F_011: " + ERR_PROPERTY_NOT_MARGE_TEST_CASE, :F_011))
        @bCannotMerge = false
      end

      if (@cConf.get_target_spec.include?(CFG_TARGET_SPEC_NOS))
        ### F_P005: 対象の仕様にNOSが含まれ，テスト実行に必要な保護違反時処理機能の機能レベルを満たしていない
        case @cConf.get_violation_handling_level()
        when CFG_VIOLATION_HANDLING_LEVEL1
          if (@hProperty[TSR_PRM_VIOLATION_HANDLING_LEVEL] == 2 || @hProperty[TSR_PRM_VIOLATION_HANDLING_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P005: " + ERR_PROPERTY_NOT_VIOLATION_HANDLING_LEVEL, :F_P005))
          end
        when CFG_VIOLATION_HANDLING_LEVEL2
          if (@hProperty[TSR_PRM_VIOLATION_HANDLING_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P005: " + ERR_PROPERTY_NOT_VIOLATION_HANDLING_LEVEL, :F_P005))
          end
        end

        ### F_P006: 対象の仕様にNOSが含まれ，テスト実行に必要なタイミング保護機能の機能レベルを満たしていない
        case @cConf.get_timing_protection_level()
        when CFG_TIMING_PROTECTION_LEVEL1
          if (@hProperty[TSR_PRM_TIMING_PROTECTION_LEVEL] == 2 || @hProperty[TSR_PRM_TIMING_PROTECTION_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P006: " + ERR_PROPERTY_NOT_TIMING_PROTECTION_LEVEL, :F_P006))
          end
        when CFG_TIMING_PROTECTION_LEVEL2
          if (@hProperty[TSR_PRM_TIMING_PROTECTION_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P006: " + ERR_PROPERTY_NOT_TIMING_PROTECTION_LEVEL, :F_P006))
          end
        end

        ### F_P007: 対象の仕様にNOSが含まれ，テスト実行に必要なメモリ保護機能の機能レベルを満たしていない
        case @cConf.get_memory_protection_level()
        when CFG_MEMORY_PROTECTION_LEVEL1
          if (@hProperty[TSR_PRM_MEMORY_PROTECTION_LEVEL] == 2 || @hProperty[TSR_PRM_MEMORY_PROTECTION_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P007: " + ERR_PROPERTY_NOT_TIMING_PROTECTION_LEVEL, :F_P007))
          end
        when CFG_MEMORY_PROTECTION_LEVEL2
          if (@hProperty[TSR_PRM_MEMORY_PROTECTION_LEVEL] == 3)
            aErrors.push(AKTFExcludeError.new("F_P007: " + ERR_PROPERTY_NOT_TIMING_PROTECTION_LEVEL, :F_P007))
          end
        end
      end

      ### F_012: OSAP固有のスタートアップフックが必要であるが使用不可
      if ((!@cConf.enable_startup_hook_osap()) && exist_startup_hook_osap?())
        sErr = sprintf("F_012 " + ERR_PROPERTY_NO_FUNC, CFG_STARTUP_HOOK_OSAP)
        aErrors.push(AKTFExcludeError.new(sErr, :F_012))
      end

      ### F_013: OSAP固有のシャットダウンフックが必要であるが使用不可
      if (!(@cConf.enable_shutdown_hook_osap()) && exist_shutdown_hook_osap?())
        sErr = sprintf("F_013: " + ERR_PROPERTY_NO_FUNC, CFG_SHUTDOWN_HOOK_OSAP)
        aErrors.push(AKTFExcludeError.new(sErr, :F_013))
      end

      ### F_014: OSAP固有のエラーフックが必要であるが使用不可
      if (!(@cConf.enable_error_hook_osap()) && exist_error_hook_osap?())
        sErr = sprintf("F_014: " + ERR_PROPERTY_NO_FUNC, CFG_ERROR_HOOK_OSAP)
        aErrors.push(AKTFExcludeError.new(sErr, :F_014))
      end

      ### F_P008: スタック共有が必要であるが使用不可
      if (@hProperty[TSR_PRM_NEED_STACK_SHARE] == true && @cConf.enable_stack_share_mode() == false)
        aErrors.push(AKTFExcludeError.new("F_P008: " + ERR_PROPERTY_NOT_SUPPORT_STACK_SHARE, :F_P008))
      end

      ### F_P009: マルチコアであるため，実行不可
      if (@hProperty[TSR_PRM_SINGLE_ONLY] == true && @cConf.is_multi?() == true)
        aErrors.push(AKTFExcludeError.new("F_P009: " + ERR_PROPERTY_NOT_SUPPORT_MULTI_CORE, :F_P009))
      end

      ### F_015: 使用不可の割込み優先度，割込み番号がある
      # 初期割込み優先度，割込み番号を取得
      aIsrInfo = get_isr_intpri_and_intno()
        if (!aIsrInfo.nil?())
          aCondition = get_all_condition()
          aCondition.each{|cCondition|
            # 各コンディションの全C2ISRの現在割込み優先度を追加
            aIsrInfo.concat(get_c2isr_curpri(cCondition))
          }
          if (aIsrInfo.include?(TSR_STT_INVALID))
              sErr = sprintf("F_015: " + ERR_PROPERTY_INVALID_INTPRI_INTNUM)
              aErrors.push(AKTFExcludeError.new(sErr, :F_015))
          end
        end

      # multi
      if (@cConf.is_multi?())
        # コア数のチェック
        nMax = @cConf.get_core_num()
        nProc = get_max_coreid()
        ### F_M001: 設定したコア数より多いコアが使用されている
        if (nMax != 0 && nProc > nMax)
          sErr = sprintf("F_M001: " + ERR_PROPERTY_OVER_CORE_NUM, nMax, nProc)
          aErrors.push(AKTFExcludeError.new(sErr, :F_M001))
        end

        ### F_M002: スピンロックが必要であるがコア数不足で使用不可
        if (nMax == 1 && exist_spinlock?())
          sErr = sprintf("F_M002: " + ERR_PROPERTY_NO_SPINLOCK)
          aErrors.push(AKTFExcludeError.new(sErr, :F_M002))
        end

        ### F_M003: コア間割込みが必要であるが使用不可
        if (!(@cConf.enable_inter_core_interrupt?()) && exist_inter_core_interrupt?())
          sErr = sprintf("F_M003: " + ERR_PROPERTY_NO_FUNC, CFG_INTER_CORE_INTERRUPT)
          aErrors.push(AKTFExcludeError.new(sErr, :F_M003))
        end

        ### F_M004: コア間割込み変換モードであるが対象のC2ISRが含まれておらず使用不可
        if (@cConf.enable_icisr_convert?())
          if (!exist_c2isr?() && !exist_inter_core_interrupt?())
            # C2ISRがない，かつ，変換したICISRもない
            # →テストケースに1つもC2ISRがない
            sErr = sprintf("F_M004: " + ERR_PROPERTY_NO_CONVERT_C2ISR)
            aErrors.push(AKTFExcludeError.new(sErr, :F_M004_1))
          elsif (exist_c2isr?() && !exist_inter_core_interrupt?())
            # C2ISRはあるが，変換したICISRはない
            # →変換対象の優先度と同じ優先度のC2ISRがない
            sErr = sprintf("F_M004: " + ERR_PROPERTY_NOT_MATCH_CONVERT_PRI)
            aErrors.push(AKTFExcludeError.new(sErr, :F_M004_2))
          end
          ### F_M005: コア間割込み変換後，実施不可能なテストケースになる
          sObjectType = nil
          bErrFlg = false
          if (exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK) == true)
            # pre_conditionでシステム定義のスタートアップフックがAK_ACTIVATEの場合
            sObjectType = TSR_OBJ_STARTUP_HOOK
          end
          if (@cConf.is_sc3?() || @cConf.is_sc4?())
            if (exist_active_proc_unit(TSR_OBJ_STARTUP_HOOK_OSAP) == true)
              # pre_conditionでOSAP固有のスタートアップフックがAK_ACTIVATEの場合
              sObjectType = TSR_OBJ_STARTUP_HOOK_OSAP
            elsif (exist_error_hook_osap?())
              # pre_conditionで非信頼OSAP固有のエラーフックがAK_ACTIVATEの場合
              hErrorHookOsap = @cPreCondition.get_objects_by_type(TSR_OBJ_ERROR_HOOK_OSAP)
              hErrorHookOsap.each{|cObjID, cObjInfo|
                if ((!cObjInfo.is_trusted?()) && (cObjInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
                  sObjectType = TSR_OBJ_ERROR_HOOK_OSAP
                end
              }
            end
          end
          if ((!sObjectType.nil?()) && (exist_inter_core_interrupt?()))
            @aDo_PostCondition.each{|cCondition|
              hIcIsrInfo = cCondition.get_all_object_info(TSR_OBJ_ICISR)
              hIcIsrInfo.each{|sIcIsrID, cIcIsrInfo|
                if (cIcIsrInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
                  bErrFlg = true
                  break
                end
              }
            }
            if (bErrFlg == true)
              sErr = sprintf("F_M005: " + ERR_PROPERTY_CONVERT_ICISR_FAULT_CASE)
              aErrors.push(AKTFExcludeError.new(sErr, :F_M005))
            end
          end
          # AktspRaiseInterruptの発行元が非信頼OSAPに所属している，かつ，割込み禁止状態があるケースは除外する
          if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && exist_inter_core_interrupt?() && bErrFlg == false)
            bCheckFlg = false
            @aDo_PostCondition.each{|cCondition|
              if (cCondition.hDo[TSR_PRM_SYSSRV] =~ /#{FNC_INT_RAISE}/)
                # syssrvがAktspRaiseInterruput(ここでは変換前)かつ，引数のintnoが変換対象のC2ISRかをチェックする
                hIcIsrInfo = cCondition.get_all_object_info(TSR_OBJ_ICISR)
                hIcIsrInfo.each{|sIcIsrID, cIcIsrInfo|
                  if (cCondition.hDo[TSR_PRM_SYSSRV] =~ /#{cIcIsrInfo.hState[TSR_PRM_INTNO]}/)
                    bCheckFlg = true
                    break
                  end
                }
                if (bCheckFlg == true)
                  cObjInfo = cCondition.hAllObject[cCondition.hDo[TSR_PRM_ID]]
                  # 非信頼OSAP所属かをチェック
                  if ((!cObjInfo.hState[TSR_PRM_OSAP].nil?()) && !cObjInfo.is_trusted?())
                    hIntStateInfo = cCondition.get_all_object_info(TSR_OBJ_INT_STATE)
                    hIntStateInfo.each{|sIntID, cIntInfo|
                      # 割込み禁止状態かをチェック
                      if ((cObjInfo.hState[TSR_PRM_COREID] == cIntInfo.hState[TSR_PRM_COREID]) && (!cIntInfo.hState[TSR_PRM_INT_STATE].nil?()))
                        sErr = sprintf("F_M005: " + ERR_PROPERTY_CONVERT_ICISR_FAULT_CASE)
                        aErrors.push(AKTFExcludeError.new(sErr, :F_M005))
                        break
                      end
                    }
                  end
                end
              end
            }
          end
        end
      end

      ### F_016: C1ISRが必要であるが使用不可
      if ((@cConf.enable_use_c1isr() == false) && (exist_proc_unit(TSR_OBJ_C1ISR) == true))
        sErr = sprintf("F_016: " + ERR_PROPERTY_NO_FUNC, CFG_USE_C1ISR)
        aErrors.push(AKTFExcludeError.new(sErr, :F_016))
      end

      # エラーがあった場合
      if (!aErrors.empty?())
        raise(AKTFMultiExcludeError.new(aErrors))
      end
    end

    #=================================================================
    # 概  要: need_siが指定されたテスト実施に不要なdo/post_conditionを
    #         削除
    #=================================================================
    def delete_unneeded_do()
      hTmp = @aDo_PostCondition.dup()
      hTmp.each{|cCondition|
        aDoNeedSi = cCondition.hDo[TSR_PRM_NEED_SI]
        # doのneed_siによる不要なdo/post_conditionを削除
        # 直前のコンディションでdoのsiに指定されている処理単位のneed_siはdoのneed_siに補完済
        if (!aDoNeedSi.nil?() && aDoNeedSi.is_a?(Array))
          @aNeedSi |= aDoNeedSi
          aDoNeedSi.each{|sSpec|
            if (!@cConf.get_target_spec.include?(sSpec[/\D*/])  && GRP_NEED_SI_AVAILABLE.include?(sSpec[/\D*/]))
              @aDo_PostCondition.delete(cCondition)
              break
            end
          }
        end
        # pre_conditionでneed_siやtarget_error_hook_cfgが指定されていて，
        # doのidに指定された処理単位が生成されていない場合のdo/post_conditionを削除
        cCondition.aDeleteObj.each{|sObjectID|
          if (cCondition.hDo[TSR_PRM_ID] == sObjectID)
            @aDo_PostCondition.delete(cCondition)
            break
          end
        }
      }
      @aDo_PostCondition.each_with_index{|cCondition, nNewSeqNum|
        cCondition.nSeqNum = nNewSeqNum
      }
    end

    #=================================================================
    # 概  要: コンディション内に存在するコアIDの最大値を返す
    #=================================================================
    def get_max_coreid()
      nMaxCoreid = 0
      aCoreid = get_all_coreid()
      aCoreid = aCoreid.reject(){|val|
        !val.is_a?(Integer)
      }
      if (!aCoreid.empty?())
        nMaxCoreid = aCoreid.uniq().size()
      end

      return nMaxCoreid  # [Integer]コンディション内に存在するコアIDの最大値
    end

    #=================================================================
    # 概  要: テストシナリオ内に存在する全てのコアIDを返す
    #=================================================================
    def get_all_coreid()
      aCoreid = []
      # 全てのコンディションの処理単位のcoreidを収集する
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        aCoreid.concat(cCondition.get_all_coreid())
      }

      return aCoreid  # [Array]テストシナリオ内に存在する全てのコアID
    end

    #=================================================================
    # 概  要: テストシナリオ内に存在するスピンロック数を返す
    #=================================================================
    def get_spinlock_count()
      aSpinID = get_spinlock_names()

      return aSpinID.size()  # [Integer]テストシナリオ内に存在するスピンロック数
    end

    #=================================================================
    # 概  要: テストシナリオ内に存在するスピンロックIDを返す
    #=================================================================
    def get_spinlock_names()
      hSpinlock = @cPreCondition.get_objects_by_type(TSR_OBJ_SPINLOCK)

      return hSpinlock.keys()  # [Array]テストシナリオ内に存在するスピンロックID
    end

    #=================================================================
    # 概  要: C1ISRで割込み番号ごとにチェックする属性を返す
    #=================================================================
    def get_c1isr_attributes_by_intno()
      return @cPreCondition.get_c1isr_attributes_by_intno() # [Hash]割込み番号ごとの該当属性
    end

    #=================================================================
    # 概  要: C2ISRで割込み番号ごとにチェックする属性を返す
    #=================================================================
    def get_c2isr_attributes_by_intno()
      return @cPreCondition.get_c2isr_attributes_by_intno() # [Hash]割込み番号ごとの該当属性
    end

    #=================================================================
    # 概  要: C1ISRで割込み番号ごとにチェックする所属するOSAPを返す
    #=================================================================
    def get_c1isr_osap_attributes_by_intno()
      return @cPreCondition.get_c1isr_osap_attributes_by_intno() # [Hash]割込み番号ごとの所属するOSAP
    end

    #=================================================================
    # 概  要: C2ISRで割込み番号ごとにチェックする所属するOSAPを返す
    #=================================================================
    def get_c2isr_osap_attributes_by_intno()
      return @cPreCondition.get_c2isr_osap_attributes_by_intno() # [Hash]割込み番号ごとの所属するOSAP
    end

    #=================================================================
    # 概  要: リスタートタスクで所属するOSAPごとにチェックする属性を返す
    #=================================================================
    def get_restarttask_attributes_by_osap()
      return @cPreCondition.get_restarttask_attributes_by_osap() # [Hash]所属OSAPごとの該当属性
    end

    #=================================================================
    # 概  要: 登場するC2ISR，ICISRの割込み属性，割込み要求禁止フラグを返す
    #=================================================================
    def get_isr_intatr_and_istat(cCondition)
      check_class(Condition, cCondition)  # コンディション

      return cCondition.get_isr_intatr_and_istat() # [Hash]引数に与えられたコンディションの全C2ISRの割込み属性，割込み要求禁止フラグ
    end

    #=================================================================
    # 概  要: 登場する初期割込み優先度，割込み番号を返す
    #=================================================================
    def get_isr_intpri_and_intno()
      return @cPreCondition.get_isr_intpri_and_intno() # [Array]全ISRの初期割込み優先度，割込み番号
    end

    #=================================================================
    # 概  要: 登場する割込み優先度
    #=================================================================
    def get_c2isr_curpri(cCondition)
      check_class(Condition, cCondition)  # コンディション

      return cCondition.get_c2isr_curpri() # [Array]引数に与えられたコンディションの全C2ISRの現在割込み優先度
    end

    #=================================================================
    # 概  要: 割込みハンドラが存在するかを返す
    #=================================================================
    def exist_interrupt_handler?()
      hIntHdr = @cPreCondition.get_objects_by_type([TSR_OBJ_C1ISR, TSR_OBJ_C2ISR])

      return !(hIntHdr.empty?())  # [Bool]割込みハンドラが存在するか
    end
    private :exist_interrupt_handler?

    #=================================================================
    # 概  要: ハードウェアカウンタが存在するかを返す
    #=================================================================
    def exist_hardware_counter?()
      bResult = false
      @cPreCondition.hAllObject.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.sObjectType == TSR_OBJ_COUNTER && cObjectInfo.hState[TSR_PRM_CTYPE] == TSR_STT_HARDWARE)
          bResult = true
          break
        end
      }

      return bResult  # [Bool]ハードウェアカウンタが存在するか
    end
    private :exist_hardware_counter?

    #=================================================================
    # 概  要: スタートアップフックが存在するかを返す
    #=================================================================
    def exist_startup_hook?()
      hStartupHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_STARTUP_HOOK)

      return !(hStartupHookExc.empty?())  # [Bool]スタートアップフックが存在するか
    end
    private :exist_startup_hook?

    #=================================================================
    # 概  要: シャットダウンフックが存在するかを返す
    #=================================================================
    def exist_shutdown_hook?()
      hShutdownHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_SHUTDOWN_HOOK)

      return !(hShutdownHookExc.empty?())  # [Bool]シャットダウンフックが存在するか
    end
    private :exist_shutdown_hook?

    #=================================================================
    # 概  要: プレタスクフックが存在するかを返す
    #=================================================================
    def exist_pre_task_hook?()
      hPretaskHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_PRETASK_HOOK)

      return !(hPretaskHookExc.empty?())  # [Bool]プレタスクフックが存在するか
    end
    private :exist_pre_task_hook?

    #=================================================================
    # 概  要: ポストタスクフックが存在するかを返す
    #=================================================================
    def exist_post_task_hook?()
      hPosttaskHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_POSTTASK_HOOK)

      return !(hPosttaskHookExc.empty?())  # [Bool]ポストタスクフックが存在するか
    end
    private :exist_post_task_hook?

    #=================================================================
    # 概  要: エラーフックが存在するかを返す
    #=================================================================
    def exist_error_hook?()
      hErrorHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_ERROR_HOOK)

      return !(hErrorHookExc.empty?())  # [Bool]エラーフックが存在するか
    end
    private :exist_error_hook?

    #=================================================================
    # 概  要: プロテクションフックが存在するかを返す
    #=================================================================
    def exist_protection_hook?()
      hPeotectionHookExc = @cPreCondition.get_objects_by_type(TSR_OBJ_PROTECTION_HOOK)

      return !(hPeotectionHookExc.empty?())  # [Bool]プロテクションフックが存在するか
    end
    private :exist_protection_hook?

    #=================================================================
    # 概  要: OSAP固有のスタートアップフックが存在するかを返す
    #=================================================================
    def exist_startup_hook_osap?()
      hStartupHookOsapExc = @cPreCondition.get_objects_by_type(TSR_OBJ_STARTUP_HOOK_OSAP)

      return !(hStartupHookOsapExc.empty?())  # [Bool]OSAP固有のスタートアップフックが存在するか
    end
    private :exist_startup_hook_osap?

    #=================================================================
    # 概  要: OSAP固有のシャットダウンフックが存在するかを返す
    #=================================================================
    def exist_shutdown_hook_osap?()
      hShutdownHookOsapExc = @cPreCondition.get_objects_by_type(TSR_OBJ_SHUTDOWN_HOOK_OSAP)

      return !(hShutdownHookOsapExc.empty?())  # [Bool]シャットダウンフックが存在するか
    end
    private :exist_shutdown_hook_osap?

    #=================================================================
    # 概  要: OSAP固有のエラーフックが存在するかを返す
    #=================================================================
    def exist_error_hook_osap?()
      hErrorHookOsapExc = @cPreCondition.get_objects_by_type(TSR_OBJ_ERROR_HOOK_OSAP)

      return !(hErrorHookOsapExc.empty?())  # [Bool]OSAP固有のエラーフックが存在するか
    end
    private :exist_error_hook_osap?

    #=================================================================
    # 概  要: スピンロックが存在するかを返す
    #=================================================================
    def exist_spinlock?()
      hSpinlockExc = @cPreCondition.get_objects_by_type(TSR_OBJ_SPINLOCK)

      return !(hSpinlockExc.empty?())  # [Bool]スピンロックが存在するか
    end
    private :exist_spinlock?

    #=================================================================
    # 概  要: コア間割込みが存在するかを返す
    #=================================================================
    def exist_inter_core_interrupt?()
      hIcIsrExc = @cPreCondition.get_objects_by_type(TSR_OBJ_ICISR)

      return !(hIcIsrExc.empty?())  # [Bool]スピンロックが存在するか
    end
    private :exist_inter_core_interrupt?

    #=================================================================
    # 概  要: C2ISRが存在するかを返す
    #=================================================================
    def exist_c2isr?()
      hC2isr = @cPreCondition.get_objects_by_type(TSR_OBJ_C2ISR)

      return !(hC2isr.empty?())  # [Bool]C2ISRが存在するか
    end
    private :exist_c2isr?

    #=================================================================
    # 概  要: 全コンディションの配列を返す
    #=================================================================
    def get_all_condition()
      aCondition = [@cPreCondition]
      aCondition.concat(@aDo_PostCondition)

      return aCondition  # [Array]全コンディション
    end
    private :get_all_condition

    #=================================================================
    # 概  要: 全オブジェクトにおいて指定されていない属性をセット
    #=================================================================
    def set_nil_attribute()
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        cCondition.set_nil_attribute()
      }
    end

    #=================================================================
    # 概  要: 全オブジェクトにおいて指定されていない属性をセット
    #=================================================================
    def check_error_hook_exclude()
      return  @cPreCondition.error_hook_exclude_id()
    end

    #=================================================================
    # 概  要: マージ可能かをチェック
    #=================================================================
    def marge_check()
      aTaskFlg = Array.new(@cConf.get_core_num(), false)             # 実行状態のタスクの存在フラグ
      aStartupFlg = Array.new(@cConf.get_core_num(), false)          # システム定義のスタートアップフックの存在フラグ
      aShutdownFlg = Array.new(@cConf.get_core_num(), false)         # システム定義のシャットダウンフックの存在フラグ
      aActivateShutdownFlg = Array.new(@cConf.get_core_num(), false) # 実行状態のシステム定義のシャットダウンフック/OSAP固有のシャットダウンフックの存在フラグ
      aOsapShutdownCnt = Array.new(@cConf.get_core_num(), 0)         # OSAP固有のスタートアップフックの存在する数
      aOsapStartupCnt = Array.new(@cConf.get_core_num(), 0)          # OSAP固有のシャットダウンフックの存在する数

      @cPreCondition.hAllObject.each{|sObjectID, cObjectInfo|
        # システム定義のシャットダウンフックのチェック
        if (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK)
          aShutdownFlg[cObjectInfo.hState[TSR_PRM_COREID]] = true
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            aActivateShutdownFlg[cObjectInfo.hState[TSR_PRM_COREID]] = true
          end
        # タスクの状態をチェック
        elsif ((cObjectInfo.sObjectType == TSR_OBJ_TASK) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_RUNNING))
          aTaskFlg[cObjectInfo.hState[TSR_PRM_COREID]] = true
        # OSAP固有のシャットダウンフックのチェック
        elsif (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)
          if (!aOsapShutdownCnt[cObjectInfo.hState[TSR_PRM_COREID]].nil?())
            # 設定したコア数分のOSAP固有のシャットダウンフックをカウントする
            # 設定したコア数より多いコアが使用されている場合は，F_M001でフィルタリングする
            aOsapShutdownCnt[cObjectInfo.hState[TSR_PRM_COREID]] += 1
          end
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_STP)
            # pre_conditionで，OSAP固有のシャットダウンフックがAK_STOPである→マージ不可
            @bCannotMerge = true
            return
          elsif (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            aActivateShutdownFlg[cObjectInfo.hState[TSR_PRM_COREID]] = true
          end
        # システム定義のスタートアップフックのチェック
        elsif (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK)
          aStartupFlg[cObjectInfo.hState[TSR_PRM_COREID]] = true
        # OSAP固有のスタートアップフックのチェック
        elsif (cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP && !aOsapStartupCnt[cObjectInfo.hState[TSR_PRM_COREID]].nil?())
          # 設定したコア数分のOSAP固有のスタートアップフックをカウントする
          # 設定したコア数より多いコアが使用されている場合は，F_M001でフィルタリングする
          aOsapStartupCnt[cObjectInfo.hState[TSR_PRM_COREID]] += 1
        end
        # アプリケーションモードにconfigure.yamlで指定したapp_mode_nameが含まれている→マージ不可
        if (!cObjectInfo.hState[TSR_PRM_APPMODE].nil?() && cObjectInfo.hState[TSR_PRM_APPMODE].include?(@cConf.get_app_mode()))
          @bCannotMerge = true
          return
        end
      }

      bMergeableShutdownHook = false
      (0..@cConf.get_core_num()-1).each{|nCoreid|
        # pre_conditionで，シャットダウンフックがAK_ACTIVATEかつタスクがRUNNINGである
        if ((aActivateShutdownFlg[nCoreid] == true) && (aTaskFlg[nCoreid] == true))
          @bCannotMerge = true
          return
        end

        # pre_conditionで，シャットダウンフックがAK_STOPである(マルチコアの場合，全コアで確認する必要がある)
        if ((aShutdownFlg[nCoreid] == false) || (aActivateShutdownFlg[nCoreid] == true))
          bMergeableShutdownHook = true
        end

        # テストシナリオに登場する各コアのシャットダウン/スタートアップフックの数に関するチェック
        # ・システム定義のスタートアップフックとOSAP固有のスタートアップフックの合計値が2以上→マージ不可
        # ・システム定義のシャットダウンフックとOSAP固有のシャットダウンフックの合計値が2以上→マージ不可
        if ((aStartupFlg[nCoreid] == true && aOsapStartupCnt[nCoreid] >= 1) || (aStartupFlg[nCoreid] == false && aOsapStartupCnt[nCoreid] > 1) ||
            (aShutdownFlg[nCoreid] == true && aOsapShutdownCnt[nCoreid] >= 1)) ||((aShutdownFlg[nCoreid] == false && aOsapShutdownCnt[nCoreid] > 1))
          @bCannotMerge = true
          return
        end
      }

      # 全コアにおいて，pre_conditionで，シャットダウンフックがAK_STOPである
      if (bMergeableShutdownHook == false)
        @bCannotMerge = true
        return
      end

      @aDo_PostCondition.each{|cCondition|
        # doのfinishがtrueである→マージ不可
        if (cCondition.hDo[TSR_PRM_FINISH] == true)
          @bCannotMerge = true
          return
        end
        (0..@cConf.get_core_num()-1).each{|nCoreid|
          # スタートアップフックがある場合，実行状態となるとマージできない処理単位が含まれている→マージ不可
          if (aStartupFlg[nCoreid] == true || aOsapStartupCnt[nCoreid] >= 1)
            cCondition.hAllObject.each{|sObjectID, cObjectInfo|
              if (GRP_PROCESS_UNIT_NOT_MERGE_WITH_STARTUP_HOOK.include?(cObjectInfo.sObjectType) && cObjectInfo.is_activate?())
                @bCannotMerge = true
                return
              end
            }
          end
        }
      }

      # SC3,SC3-MC,SC4限定
      if (@cConf.is_sc3?() || @cConf.is_sc4?())
        aCondition = [@cPreCondition, @aDo_PostCondition.last()]
        aCondition.each{|cCondition|
          hObjects = cCondition.get_objects_by_type([TSR_OBJ_RESTART_TASK,TSR_OBJ_OSAP])
          hObjects.each{|sObjectID, cObjectInfo|
            # pre_conditionおよび最後のpost_conditionに存在するリスタートタスクのtstatにSUSPENDED以外が指定されている→マージ不可
            if (cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK && cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_SUSPENDED)
              @bCannotMerge = true
              return
            # pre_conditionおよび最後のpost_conditionに存在するOSAPのosapstatにAPPLICATION_ACCESSIBLEが指定されている→マージ不可
            elsif (cObjectInfo.sObjectType == TSR_OBJ_OSAP && cObjectInfo.hState[TSR_PRM_STATE] != TSR_STT_ACCESSIBLE)
              @bCannotMerge = true
              return
            end
          }
        }
      end
    end

    #=================================================================
    # 概  要: コンフォーマンスクラスのチェック
    #=================================================================
    def check_conformance_class(sCc)
      check_class(String, sCc)  # コンフォーマンスクラス
      bErrCc  = false           # エラーチェック用フラグ
      bCheckA = true            # Check A用フラグ
      bCheckB = true            # Check B用フラグ
      bCheckC = true            # Check C用フラグ

      # タスク優先度のチェック用変数
      hMacro  = @cConf.get_macro()
      hCheckPri = {hMacro["TSK_PRI_TOP"]    => false,
                   hMacro["TSK_PRI_HIGH"]   => false,
                   hMacro["TSK_PRI_MID"]    => false,
                   hMacro["TSK_PRI_LOW"]    => false,
                   hMacro["TSK_PRI_BOTTOM"] => false
                  }

      # Check A
      # pre_conditionで1タスク1優先度のみとなっている
      hTaskInfo = @cPreCondition.get_objects_by_type(TSR_OBJ_TASK)
      hTaskInfo.each{|sObjctID, hObjInfo|
        if (hCheckPri[hObjInfo.hState[TSR_PRM_INIPRI]] == false)
          hCheckPri[hObjInfo.hState[TSR_PRM_INIPRI]] = true
        else
          bCheckA = false
        end
      }

      # Check B
      # 全conditionで，多重起動要求が未指定か1以外のタスクが存在しない
      aCondition = get_all_condition()
      aCondition.each{|cCondition|
        hTaskInfo = cCondition.get_objects_by_type(TSR_OBJ_TASK)
        hTaskInfo.each{|sObjctID, hObjInfo|
          if (!hObjInfo.hState[TSR_PRM_ACTCNT].nil?() && hObjInfo.hState[TSR_PRM_ACTCNT] > 1)
            bCheckB = false
          end
        }
      }

      # Check C
      # イベントが登場しない(拡張タスクが存在しない)
      hEventInfo = @cPreCondition.get_objects_by_type(TSR_OBJ_EVENT)
      if (!hEventInfo.empty?())
        bCheckC = false
      end

      # TESRYの内容に該当するコンフォーマンスクラスを設定
      # A && B && C　BCC1
      if (bCheckA && bCheckB && bCheckC)
        bTesryCc = CFG_CONFORMANCE_CLASS_BCC1
      # (!A || !B) && C　BCC2
      elsif ((!bCheckA || !bCheckB) && bCheckC)
        bTesryCc = CFG_CONFORMANCE_CLASS_BCC2
      # A && B && !C　ECC1
      elsif (bCheckA && bCheckB && !bCheckC)
        bTesryCc = CFG_CONFORMANCE_CLASS_ECC1
      # (!A || !B) && !C  ECC2
      elsif ((!bCheckA || !bCheckB) && !bCheckC)
        bTesryCc = CFG_CONFORMANCE_CLASS_ECC2
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      # configureのコンフォーマンスクラスでテスト可能かをチェック
      case sCc
      when CFG_CONFORMANCE_CLASS_BCC1
        # BCC1のみが対象
        if (bTesryCc != CFG_CONFORMANCE_CLASS_BCC1)
          bErrCc = true
        end
      when CFG_CONFORMANCE_CLASS_BCC2
        # BCC1とBCC2が対象
        if (bTesryCc != CFG_CONFORMANCE_CLASS_BCC1 && bTesryCc != CFG_CONFORMANCE_CLASS_BCC2)
          bErrCc = true
        end
      when CFG_CONFORMANCE_CLASS_ECC1
        # BCC1とECC1が対象
        if (bTesryCc != CFG_CONFORMANCE_CLASS_BCC1 && bTesryCc != CFG_CONFORMANCE_CLASS_ECC1)
          bErrCc = true
        end
      when CFG_CONFORMANCE_CLASS_ECC2
        # 全て対象
      else
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      return bErrCc
    end
    private :check_conformance_class

    #=================================================================
    # 概  要: テスト対象の仕様(NOS)のチェック
    #=================================================================
    def check_target_spec_nos()
      sSc = @cConf.get_scalability_class()

      if (sSc == CFG_SCALABILITY_CLASS_SC1)
        # NOS0341：SC1においてもプロテクションフックをサポートする
        if (exist_protection_hook?())
          return true
        end
      elsif (sSc == CFG_SCALABILITY_CLASS_SC3)
        # メモリ保護テストは，ATK2で設定した方法で実行しているため，全てNOSと判断する
        hMemModuleInfo = @cPreCondition.get_objects_by_type(TSR_OBJ_MEMORY_MODULE)
        if (!hMemModuleInfo.empty?())
          return true
        end
        # 信頼関数の有無
        bTrustedFunctioin = false
        hTrustedFunctioin = @cPreCondition.get_objects_by_type(TSR_OBJ_TRUSTED_FUNCTION)
        if (!hTrustedFunctioin.empty?())
          bTrustedFunctioin = true
        end
        @aDo_PostCondition.each{|cCondition|
          sSyssrv = cCondition.hDo[TSR_PRM_SYSSRV].scan(/^\w*/).join()
          if (sSc == CFG_SCALABILITY_CLASS_SC3)
            # NOS0522~0611：Check***Access，Check***Ownership
            if (GRP_TARGET_SPEC_NOS_SYSSRV.include?(sSyssrv))
              return true
            # NOS0374,NOS0375,NOS0179：信頼関数をStatusType型とし，ユーザが定義した信頼関数の返り値をCallTrustedFunctionの返り値とする
            elsif (bTrustedFunctioin == true)
              if (sSyssrv == "return" && @cPreCondition.hAllObject[cCondition.hDo[TSR_PRM_ID]].sObjectType == TSR_OBJ_TRUSTED_FUNCTION)
                return true
              end
            end
          end
        }
      end

      if (@cConf.is_multi?())
        # NOS0060：ICISRの定義
        if (exist_inter_core_interrupt?())
          return true
        end
      end

      # NOS0674,NOS0691：ハードウェアカウンタの具体的な実装方法をATK2で規定
      if (exist_hardware_counter?())
        return true
      end

      # エラーチェック用のエラーフックの有無
      bErrHook = false
      hErrorHookInfo = @cPreCondition.get_objects_by_type(TSR_OBJ_ERROR_HOOK)
      if (!hErrorHookInfo.empty?())
        # pre_conditionでhookstatがAK_STOPの場合のみ
        hErrorHookInfo.each{|sObjectId, cObjectInfo|
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_STP)
            bErrHook = true
            break
          end
        }
      end

      @aDo_PostCondition.each{|cCondition|
        # 保護違反発生時，プロテクションフックが呼び出される
        # NOS0443等：不正終了
        if (bErrHook == true && cCondition.hDo[TSR_PRM_SYSSRV] =~ /OSServiceId_(Task|Hook|ISR)MissingEnd/)
          return true
        end
        sSyssrv = cCondition.hDo[TSR_PRM_SYSSRV].scan(/^\w*/).join()
        # NOS1070：実装定義のチェック可能な箇所でスタックオーバーフローのチェックを行う
        # 上記仕様から，スタックモニタリングテストは全てNOSと判断する
        if (GRP_STACK_OVERFLOW_FNC.include?(sSyssrv))
          return true
        # NOS0638,NOS0639：CPU例外時の動作の処理レベルを規定
        # 上記仕様から，CPU例外テストは全てNOSと判断する
        elsif (sSyssrv == "AktspRaiseCPUException")
          return true
        # NOS0409,NOS0411,NOS0412：返り値のデータ型がStatusTypeでないシステムサービスでもエラーフックを呼び出す場合がある
        elsif (bErrHook == true && GRP_NO_RETURN_STATUSTYPE_SYSSRV.include?(sSyssrv))
          return true
        # NOS1087：エラーを起こしたIOC用システムサービスの情報取得
        elsif (bErrHook == true && sSyssrv =~ /^(Ioc(Send|Receive|SendGroup|ReceiveGroup|EmptyQueue|Write|Read|WriteGroup|ReadGroup)_IOC\d)/)
          return true
        # NOS0125：保護違反が発生した時に，違反の区別を示すエラーコードをパラメータとして，システム定義のプロテクションフックが呼び出される
        elsif (sSyssrv == FNC_CHECK_ASSERT && @cPreCondition.hAllObject[cCondition.hDo[TSR_PRM_ID]].sObjectType == TSR_OBJ_PROTECTION_HOOK)
          return true
        end
      }
      return false
    end
    private :check_target_spec_nos

    #=================================================================
    # 概  要: テスト対象の仕様(IOS)のチェック
    #=================================================================
    def check_target_spec_ios()
      # IOS031：C1ISR
      hC1isrInfo = @cPreCondition.get_objects_by_type(TSR_OBJ_C1ISR)
      if (!hC1isrInfo.empty?())
        return true
      end

      # IOC007等：スタックモニタリング
      @aDo_PostCondition.each{|cCondition|
        sSyssrv = cCondition.hDo[TSR_PRM_SYSSRV].scan(/^\w*/).join()
        if (GRP_STACK_OVERFLOW_FNC.include?(sSyssrv))
          return true
        end
      }
      return false
    end
    private :check_target_spec_ios

    #=================================================================
    # 概  要: 拡張エラーが存在するかを返す
    #=================================================================
    def exist_extended_retern_status?()
      hError = @cConf.get_return_status_extended()

      @aDo_PostCondition.each{|cCondition|
        sSyssrv = cCondition.hDo[TSR_PRM_SYSSRV].scan(/^\w*/).join()
        if (hError.has_key?(sSyssrv))
          # 戻り値がStatusTypeかそうでないかで判定方法が異なる
          if (!GRP_NO_RETURN_STATUSTYPE_SYSSRV.include?(sSyssrv) && !hError[sSyssrv].nil?() && hError[sSyssrv].include?(cCondition.hDo[TSR_PRM_RETVAL]))
            return true
          end
        end
      }
      return false
    end
    private :exist_extended_retern_status?
  end
end
