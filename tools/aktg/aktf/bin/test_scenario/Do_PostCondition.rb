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
# $Id: Do_PostCondition.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Do_PostCondition
  # 概    要: do，post_conditionの情報を処理するクラス
  #===================================================================
  class Do_PostCondition < Condition
    #=================================================================
    # 概  要: post_conditionの構造チェック
    #=================================================================
    def basic_post_check(hScenarioPost)
      check_class(Hash, hScenarioPost, true)  # post_condition

      # オブジェクトの構造チェック
      if (hScenarioPost.is_a?(Hash))
        aErrors = []
        aPath = get_condition_path()
        hScenarioPost.each{|sObjectID, hObjectInfo|
          begin
            ### T1_018: post_conditionで状態変化のないオブジェクトが記述されている
            if (hObjectInfo.nil?())
              sErr = sprintf("T1_018: " + ERR_OBJECT_NOCHANGE, sObjectID)
              aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
            else
              common_basic_check(sObjectID, hObjectInfo, aPath)
              ### T1_019: post_condition内のオブジェクトにtype属性が定義されている
              if (hObjectInfo.has_key?(TSR_PRM_TYPE))
                sErr = sprintf("T1_019: " + ERR_ONLY_PRE_ATR, TSR_PRM_TYPE)
                aErrors.push(YamlError.new(sErr, aPath + [sObjectID]))
              end
            end
          rescue AKTFMultiError
            aErrors.concat($!.aErrors)
          end
        }

        check_error(aErrors)
      end
    end

    #=================================================================
    # 概  要: 属性チェック(何の属性を指定したかをチェック)
    #=================================================================
    def basic_attribute_check(hScenarioDo)
      check_class(Hash, hScenarioDo)  # do

      aPath       = get_do_path()
      aAtrDefList = GRP_DEF_DO.keys()

      check_defined_attribute(hScenarioDo.keys(), aAtrDefList, aPath)
    end

    #=================================================================
    # 概  要: 属性チェック
    #=================================================================
    def attribute_check()
      aErrors = []

      aPath = get_do_path()
      # オブジェクトの属性チェック
      begin
        super()
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end

      ### T3_DO001: idが指定されていない
      if (@hDo[TSR_PRM_ID].nil?())
        sErr = sprintf("T3_DO001: " + ERR_REQUIRED_KEY, TSR_PRM_ID)
        aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_ID]))
      end
      ### T3_DO002: syssrvが指定されていない
      if (@hDo[TSR_PRM_SYSSRV].nil?())
        sErr = sprintf("T3_DO002: " + ERR_REQUIRED_KEY, TSR_PRM_SYSSRV)
        aErrors.push(YamlError.new(sErr, aPath + [TSR_PRM_SYSSRV]))
      end
      ### T3_DO003: rettypeとretvalのどちらかしか指定されていない
      if ((@hDo[TSR_PRM_RETTYPE].nil?() && !@hDo[TSR_PRM_RETVAL].nil?()) || (!@hDo[TSR_PRM_RETTYPE].nil?() && @hDo[TSR_PRM_RETVAL].nil?()))
          aErrors.push(YamlError.new("T3_DO003: " + ERR_RTYPE_AND_RVAL, aPath))
      end

      ### T2: doの属性指定チェック
      check_do_attribute(@hDo, @aSpecifiedDoAttributes, aPath)

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: コンディションチェック
    #=================================================================
    def condition_check(bCannotMerge)
      check_class(Bool, bCannotMerge) # マージしないテストケースかどうか

      aErrors = []

      begin
        super(bCannotMerge)
      rescue AKTFMultiError
        aErrors.concat($!.aErrors)
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: 最後のポストコンディションチェック
    #=================================================================
    def last_condition_check()
      aErrors = []
      aPath = get_condition_path()

      if (@hProperty[TSR_PRM_MAINTASK_WAIT] == true)
        aActivate = []
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
        hObjects.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.is_activate?())
            aActivate.push(cObjectInfo.sObjectType)
          end
        }

        ### T4_087: propertyのmaintask_waitがtrueの場合に，最後のpost_conditionで実行状態のタスクかC2ISRが登場しない
        if (!(aActivate.include?(TSR_OBJ_TASK) || aActivate.include?(TSR_OBJ_C2ISR) || aActivate.include?(TSR_OBJ_ICISR)))
          aErrors.push(YamlError.new("T4_087: " + ERR_NOT_EXIST_TASK_C2ISR, aPath))
        end
      end

      if (!@hProperty[TSR_PRM_PRO_APPMODE].nil?())
        bHookAct = false
        hObjects = get_objects_by_type([TSR_OBJ_SHUTDOWN_HOOK,TSR_OBJ_SHUTDOWN_HOOK_OSAP])
        hObjects.each{|sObjectID, cObjectInfo|
          if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE)
            bHookAct = true
          end
        }
        ### T4_089: propertyのapplication_modeを指定した場合に，シャットダウンフックが存在しない，または，最後のdoのfinishがtrueではない
        if (bHookAct == false && @hDo[TSR_PRM_FINISH] == false)
          aErrors.push(YamlError.new("T4_089: " + ERR_APPMODE_FINISH, aPath))
        end
      end

      check_error(aErrors)
    end

    #=================================================================
    # 概  要: コンディション内の全てのマクロを置換する
    #=================================================================
    def convert_macro()
      super()

      hMacro = @cConf.get_macro()
      @hDo.each{|sAtr, val|
        @hDo[sAtr] = calc_all_expr(@hDo[sAtr], hMacro)
      }
      if (@cConf.is_multi?())
        hMacro = @cConf.get_mc_macro()
        @hDo.each{|sAtr, val|
          @hDo[sAtr] = calc_all_expr(@hDo[sAtr], hMacro)
        }
      end
    end

    #=================================================================
    # 概  要: 補完を実行する
    #=================================================================
    def complement(cPrevCondition)
      check_class(Condition, cPrevCondition)  # 直前のコンディション

      #doの補完
      # gcov
      if (!@aSpecifiedDoAttributes.include?(TSR_PRM_GCOV))
        @hDo[TSR_PRM_GCOV] = true
      end

      # finish
      if (!@aSpecifiedDoAttributes.include?(TSR_PRM_FINISH))
        @hDo[TSR_PRM_FINISH] = false
      end

      # repeat
      if (!@aSpecifiedDoAttributes.include?(TSR_PRM_REPEAT))
        @hDo[TSR_PRM_REPEAT] = 1
      end

      # need_si
      # syssrvを発行する処理単位が直前のコンディションでneed_siがnilでない場合，
      # doのneed_siに補完する(delete_unneeded_do()でdo/post_conditionを削除するため)
      if (!@aDeleteObj.include?(@hDo[TSR_PRM_ID]) && !cPrevCondition.hAllObject[@hDo[TSR_PRM_ID]].nil?())
        aPrevNeedSi = cPrevCondition.hAllObject[@hDo[TSR_PRM_ID]].hState[TSR_PRM_NEED_SI]
      end
      if (!@aSpecifiedDoAttributes.include?(TSR_PRM_NEED_SI))
        @hDo[TSR_PRM_NEED_SI] = nil
      end
      if (!aPrevNeedSi.nil?() && aPrevNeedSi.is_a?(Array))
        if (@hDo[TSR_PRM_NEED_SI].nil?)
          @hDo[TSR_PRM_NEED_SI] = []
        end
        @hDo[TSR_PRM_NEED_SI] |= aPrevNeedSi
      end


      # post_conditionの補完
      cPrevCondition.hAllObject.each{|sObjectID, cObjectInfo|
        bNeedFlg = true
        if (!@hAllObject[sObjectID].nil?())
          # post_conditionのneed_siとtarget_specが一致した場合，処理単位は記述されていないとみなす
          if (@hAllObject[sObjectID].is_specified?(TSR_PRM_NEED_SI))
            aNeedSi = @hAllObject[sObjectID].hState[TSR_PRM_NEED_SI]
          else
            aNeedSi = cObjectInfo.hState[TSR_PRM_NEED_SI]
          end
          if (!aNeedSi.nil?() && aNeedSi.is_a?(Array))
            aNeedSi.each{|sSpec|
              if (!@cConf.get_target_spec.include?(sSpec[/\D*/]))
                @aNeedSi.push(sSpec)
                bNeedFlg = false
              end
            }
          end
          # エラーフックのコンフィギュレーションとtarget_error_hook_cfgが一致しなかった場合，
          # 処理単位は記述されていないとみなす
          # また，target_error_hook_cfgがAK_SC1_SINGLEの場合，SC1，SC1-MCに合わせて置換する
          if (!@hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG].nil?() && @hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG].include?(TSR_STT_SINGLE))
            if (@cConf.is_sc1?())
              @hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG].delete(TSR_STT_SINGLE)
              if (@cConf.is_multi?())
                @hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG].concat([TSR_STT_ONLY_SYSTEM,TSR_STT_BOTH])
              else
                @hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG].concat([TSR_STT_ONLY_SYSTEM])
              end
            end
          end
          aErrorHookCfg = @hAllObject[sObjectID].hState[TSR_PRM_ERROR_HOOK_CFG]
          if (!aErrorHookCfg.nil?() && aErrorHookCfg.is_a?(Array) && !aErrorHookCfg.include?(@sErrorHookCfg))
            aInvalidPrm = (GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC | aErrorHookCfg) - GRP_ERROR_HOOK_CFG_SC3_OR_SC1MC
            if (aInvalidPrm.empty?())
              bNeedFlg = false
            end
          end
        end
        # postに記述されている場合省略された属性を補完
        # ただし，need_siに指定された仕様種別がtarget_specに含まれない場合は，
        # post_conditionに何も記述されていなかったとみなす
        # (need_siは指定されたものを補完する)
        if (!@hAllObject[sObjectID].nil?() && bNeedFlg == true)
          @hAllObject[sObjectID].complement(cObjectInfo)
        # post_conditionに記述されていない場合pre_conditionからコピー
        else
          cNewObjectInfo = cObjectInfo.dup()
          cNewObjectInfo.aSpecifiedAttributes = []
          cNewObjectInfo.set_path(get_condition_path() + [cNewObjectInfo.sObjectID])
          @hAllObject[sObjectID] = cNewObjectInfo
          # need_siは，TESRYデータに記述したものをhStateに残しておく
          if (bNeedFlg == false)
            @hAllObject[sObjectID].hState[TSR_PRM_NEED_SI] = aNeedSi
            cNewObjectInfo.aSpecifiedAttributes = [TSR_PRM_NEED_SI]
          end
        end
      }

      # @lKernelStateの設定
      case cPrevCondition.lKernelState
      when :STARTUPHOOK, :STARTUPHOOK_OSAP
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
        hObjects.each{|sObjectID, cObjectInfo|
          # ACTIVATEなシステム定義のスタートアップフックが存在する場合，確定
          if ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK) && cObjectInfo.is_activate?())
            @lKernelState = :STARTUPHOOK
            break
          # ACTIVATEなOSAP固有のスタートアップフックが存在する場合，確定
          elsif ((cObjectInfo.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP) && cObjectInfo.is_activate?())
            @lKernelState = :STARTUPHOOK_OSAP
            break
          # ACTIVATEなシステム定義のシャットダウンフックが存在する場合，確定
          elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) && cObjectInfo.is_activate?())
            @lKernelState = :SHUTDOWNHOOK
            break
          # ACTIVATEなOSAP固有のシャットダウンフックが存在する場合，確定
          elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) && cObjectInfo.is_activate?())
            @lKernelState = :SHUTDOWNHOOK_OSAP
            break
          # スタートアップフック中に起動することができる処理単位が
          # ACTIVATEである場合，前回のスタートアップフックのままで確定
          elsif (GRP_PROCESS_UNIT_BOOTABLE_ON_STARTUP_HOOK.include?(cObjectInfo.sObjectType) && cObjectInfo.is_activate?())
            @lKernelState = cPrevCondition.lKernelState
            break
          # それ以外は，カーネル起動となる(hObjectsの順序次第なのでbreakしない)
          else
            @lKernelState = :KERNELBOOT
          end
        }
      when :KERNELBOOT
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
        hObjects.each{|sObjectID, cObjectInfo|
          # ACTIVATEなシステム定義のシャットダウンフックが存在する場合，確定
          if ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) && cObjectInfo.is_activate?())
            @lKernelState = :SHUTDOWNHOOK
            break
          # ACTIVATEなOSAP固有のシャットダウンフックが存在する場合，確定
          elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) && cObjectInfo.is_activate?())
            @lKernelState = :SHUTDOWNHOOK_OSAP
            break
          # それ以外は，カーネル起動となる(hObjectsの順序次第なのでbreakしない)
          else
            @lKernelState = :KERNELBOOT
          end
        }
      when :SHUTDOWNHOOK, :SHUTDOWNHOOK_OSAP
        hObjects = get_objects_by_type(GRP_PROCESS_UNIT_ALL)
        hObjects.each{|sObjectID, cObjectInfo|
          # ACTIVATEなシステム定義のシャットダウンフックが存在する場合，確定
          if ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
            @lKernelState = :SHUTDOWNHOOK
          # ACTIVATEなOSAP固有のシャットダウンフックが存在する場合，確定
          elsif ((cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP) && (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_ACTIVATE))
            @lKernelState = :SHUTDOWNHOOK_OSAP
          # それ以外は，前回のままとなる(hObjectsの順序次第なのでbreakしない)
          else
            @lKernelState = cPrevCondition.lKernelState
          end
        }
      end
    end

    #=================================================================
    # 概  要: エイリアスを実行する
    #=================================================================
    def alias(hAlias)
      check_class(Hash, hAlias)   # エイリアス変換テーブル

      # post_conditionのエイリアス
      super(hAlias)

      # doのエイリアス
      @hDo.each_key{|sAtr|
        if (sAtr == TSR_PRM_NEED_SI)
          next
        end
        @hDo[sAtr] = alias_replace(@hDo[sAtr], hAlias)
      }
      # コア間割込み変換モード用のエイリアス
      if (@cConf.enable_icisr_convert?())
        @@hC2isrToIcisr.each{|sObjID, hData|
          hData[:sObjectID] = alias_replace(hData[:sObjectID], hAlias)
        }
      end

      # コア間割込み変換モードで割込み発生関数をコア間割込み発生関数に変更が必要な場合
      if (@cConf.enable_icisr_convert?() && @hDo[TSR_PRM_SYSSRV] =~ /#{FNC_INT_RAISE}/)
        @@hC2isrToIcisr.each{|sIsrID, hData|
          if (!@@hC2isrToIcisr[sIsrID][:sIntno].empty?() && @hDo[TSR_PRM_SYSSRV] =~ /#{@@hC2isrToIcisr[sIsrID][:sIntno]}/)
            if (@cConf.is_sc1?() || GRP_PROCESS_UNIT_HOOK.include?(@hAllObject[@hDo[TSR_PRM_ID]].sObjectType) || @hAllObject[@hDo[TSR_PRM_ID]].is_trusted?())
              @hDo[TSR_PRM_SYSSRV] = "#{SS_RAISE_ICISR}(#{@@hC2isrToIcisr[sIsrID][:sObjectID]})"
            else
              @hDo[TSR_PRM_SYSSRV] = "#{TR_RAISE_ICISR}(#{@@hC2isrToIcisr[sIsrID][:sObjectID]})"
            end
            @hDo[TSR_PRM_RETTYPE] = TYP_STATUS
            @hDo[TSR_PRM_RETVAL] = "E_OK"
            break
          end
        }
      end

      # syssrvにISR IDが指定されている場合，ISR IDを共用関数のものにする
      hIsrInfo = get_objects_by_type(GRP_PROCESS_UNIT_ISR)
      hIsrInfo.each{|sIsrID, cIsrInfo|
        sStr = @hDo[TSR_PRM_SYSSRV].dup()
        aMatches = sStr.scan(/\w+/)
        aMatches.each{|sMatch|
          # コア間割込み変換モードの場合，syssrvに変換対象のISR IDがないかチェックする
          if ((@cConf.enable_icisr_convert?()) && (@@hC2isrToIcisr.has_key?(sMatch)) && sIsrID == @@hC2isrToIcisr[sMatch][:sObjectID])
            @hDo[TSR_PRM_SYSSRV].gsub!(/(^|\W)#{sMatch}(?=$|\W)/, "\\1#{cIsrInfo.get_common_id()}")
          elsif (sMatch == sIsrID)
            @hDo[TSR_PRM_SYSSRV].gsub!(/(^|\W)#{sMatch}(?=$|\W)/, "\\1#{cIsrInfo.get_common_id()}")
          end
        }
      }

      # 戻り値がISRTypeの場合，ISR IDを共用関数のものにする
      if (@hDo[TSR_PRM_RETTYPE] == TYP_ISR)
        # コア間割込み変換モードかつ，戻り値が変換対象のISRの場合，変換後のISRにする
        if (@cConf.enable_icisr_convert?() && @@hC2isrToIcisr.has_key?(@hDo[TSR_PRM_RETVAL]))
          @hDo[TSR_PRM_RETVAL] = @@hC2isrToIcisr[@hDo[TSR_PRM_RETVAL]][:sObjectID]
        end
        cIsrInfo = get_object_info(@hDo[TSR_PRM_RETVAL])
        # 戻り値の値がISRのオブジェクトIDである場合のみ
        if (!cIsrInfo.nil?() && GRP_PROCESS_UNIT_ISR.include?(cIsrInfo.sObjectType))
          @hDo[TSR_PRM_RETVAL] = cIsrInfo.get_common_id()
        end
      end
      
      ### IOCの場合，IOC IDとセンダIDが付ける
      if (@hDo[TSR_PRM_SYSSRV] =~ /^(Ioc(Send|Receive|SendGroup|ReceiveGroup|EmptyQueue|Write|Read|WriteGroup|ReadGroup)_IOC\d)/)
        hIocInfo = get_objects_by_type(TSR_OBJ_IOC)
        hIocInfo.each{|sIocID, cIocInfo|
          @hDo[TSR_PRM_SYSSRV].gsub!(/(_IOC\d)/, "_#{sIocID}")
        }
      end

    end

    #=================================================================
    # 概  要: doのパス情報を返す
    #=================================================================
    def get_do_path()
      return [@sTestID, "#{TSR_UNS_DO}#{@nSeqNum}"]  # [Array]doのパス情報
    end

    #=================================================================
    # 概  要: post_conditionのパス情報を返す
    #=================================================================
    def get_condition_path()
      return [@sTestID, "#{TSR_UNS_POST}#{@nSeqNum}"]  # [Array]post_conditionのパス情報
    end

  end
end
