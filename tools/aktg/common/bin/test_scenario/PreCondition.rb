#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2011-2014 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2011-2014 by Spansion LLC, USA
# Copyright (C) 2011-2014 by NEC Communication Systems, Ltd., JAPAN
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
# $Id: PreCondition.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/test_scenario/Condition.rb"
require "aktf/bin/test_scenario/PreCondition.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: PreCondition
  # 概    要: pre_conditionの情報を処理するクラス
  #===================================================================
  class PreCondition < Condition
    include CommonModule

    attr_reader :hObjectType, :aDeleteObj

    #=================================================================
    # 概  要: pre_conditionの初期化
    #=================================================================
    def initialize(sTestID, hScenarioPre, hProperty)
      check_class(String, sTestID)           # テストID
      check_class(Hash, hScenarioPre, true)  # pre_condition
      check_class(Hash, hProperty)           # プロパティ

      @aDeleteObj = []  # need_siの指定により，生成しないオブジェクト
      super(sTestID, hProperty)
      @hObjectType = {}  # オブジェクトIDとタイプの対応付け
      @@hC2isrToIcisr.delete_if{|sObjID, hData| sObjID != ""}

      # 構造チェック
      basic_check(hScenarioPre)

      # オブジェクトIDとオブジェクトタイプの対応表作成
      hScenarioPre.each{|sObjectID, hObjectInfo|
        @hObjectType[sObjectID] = hObjectInfo[TSR_PRM_TYPE]
      }
      # オブジェクト情報格納
      store_condition_info(hScenarioPre, @hObjectType, sTestID)

      # スタック番号の格納
      if (@cConf.enable_stack_share_mode())
        hObjects = get_objects_by_type(TSR_OBJ_TASK)
        # ID順にソートしてインデックスを付ける
        if (@cConf.is_single?())
          nStackNum = 0
          nSStackNum = 0
          hObjects.sort.each{|aObjectInfo|
            sObjectID = aObjectInfo[0]
            cObjectInfo = aObjectInfo[1]
            if (cObjectInfo.is_trusted?())
              nStackNum += 1
              cObjectInfo.nStackNum = nStackNum
            else
              nSStackNum += 1
              cObjectInfo.nStackNum = nSStackNum
            end
          }
        else
          # マルチコアの場合，コア毎かつ信頼/非信頼で分ける
          aStackNum  = Array.new(@cConf.get_core_num(), 0)
          aSStackNum = Array.new(@cConf.get_core_num(), 0)
          hMacro  = @cConf.get_macro()
          hObjects.sort.each{|aObjectInfo|
            sObjectID = aObjectInfo[0]
            cObjectInfo = aObjectInfo[1]
            # OSAPからコアIDを取得
            if (cObjectInfo.hState[TSR_PRM_OSAP].nil?())
              # 空の場合は，デフォルトOSAPからコアIDを取得
              sOsap = @cConf.get_core_id_from_osap(@cConf.get_default_osap_id())
            elsif (cObjectInfo.hState[TSR_PRM_OSAP] == "ANY_OSAP_1")
              # マクロの場合は，マクロの値を取得したあとにコアIDを取得
              sOsap = @cConf.get_core_id_from_osap(hMacro["ANY_OSAP_1"])
            else
              sOsap = @cConf.get_core_id_from_osap(cObjectInfo.hState[TSR_PRM_OSAP])
            end
            nCoreid = hMacro[sOsap]
            # インデックス設定
            if (cObjectInfo.is_trusted?())
              aStackNum[nCoreid] += 1
              cObjectInfo.nStackNum = aStackNum[nCoreid]
            else
              aSStackNum[nCoreid] += 1
              cObjectInfo.nStackNum = aSStackNum[nCoreid]
            end
          }
        end
      end

      # ICISRの共通化のための番号格納
      if (@cConf.is_multi?())
        hIcisrNum = {}
        hObjects = get_objects_by_type(TSR_OBJ_ICISR)
        # ID順にソートしてインデックスを付ける
        hObjects.sort.each{|aObjectInfo|
          sObjectID = aObjectInfo[0]
          cObjectInfo = aObjectInfo[1]
          if (!hIcisrNum.has_key?(cObjectInfo.hState[TSR_PRM_OSAP]))
            hIcisrNum[cObjectInfo.hState[TSR_PRM_OSAP]] = 1
          else
            hIcisrNum[cObjectInfo.hState[TSR_PRM_OSAP]] += 1
          end
          cObjectInfo.hState[TSR_PRM_ICISRNO] = hIcisrNum[cObjectInfo.hState[TSR_PRM_OSAP]]
        }
      end

      # スタートアップ/シャットダウンフック用コード
      @aStartupShutdownHookCode = []

    end

    #=================================================================
    # 概  要: グローバル/ローカル変数を宣言するためのコードを
    #         cElementに格納する
    #=================================================================
    def gc_global_local_var(cElement)
      check_class(IMCodeElement, cElement)  # エレメント

      # 変数が存在する場合，定義する
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (!cObjectInfo.hState[TSR_PRM_VAR].nil?())
          cObjectInfo.hState[TSR_PRM_VAR].each{|sValName, cVariable|
            cVariable.gc_global_local_var(cElement, sObjectID)
          }
        end
      }
    end

    #=================================================================
    # 概  要: ヘッダーファイルに出力するコード作成
    #=================================================================
    def gc_header(cElement)
      check_class(IMCodeElement, cElement)  # エレメント

      @hAllObject.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.sObjectType == TSR_OBJ_PROTECTION_HOOK)
          cElement.set_header(sObjectID, IMC_PROTECTION_TYPE, ["#{TYP_STATUS} #{VAR_FATAL_ERROR}"])
        elsif ((cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK) || (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) ||
               (cObjectInfo.sObjectType == TSR_OBJ_ERROR_HOOK_OSAP) || (cObjectInfo.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP))
          cElement.set_header(sObjectID, IMC_ERROR_TYPE, ["#{TYP_STATUS} #{VAR_ERROR}"])
        elsif (GRP_PROCESS_UNIT_ISR.include?(cObjectInfo.sObjectType))
          cElement.set_header(sObjectID, IMC_FUNC_ISR)
        elsif (GRP_SHARED_PROCESS_UNIT.include?(cObjectInfo.sObjectType))
          cElement.set_header(sObjectID, IMC_FUNC_TYPE)
        elsif (GRP_NOT_SHARED_PROCESS_UNIT.include?(cObjectInfo.sObjectType))
          cElement.set_header(sObjectID, cObjectInfo.sObjectType)
        # リソース，イベント，アラームは，Declare宣言のためにヘッダ情報に入れておく
        elsif ((@cConf.enable_define_declare() == true) &&
               ((cObjectInfo.sObjectType == TSR_OBJ_RESOURCE) ||
                (cObjectInfo.sObjectType == TSR_OBJ_EVENT) ||
                (cObjectInfo.sObjectType == TSR_OBJ_ALARM)))
          cElement.set_header(sObjectID, cObjectInfo.sObjectType)
        end
      }
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement)  # エレメント

      @hAllObject.each{|sObjectID, cObjectInfo|
        # IOCの場合，IOCコンテナにセンダ・レシーバ・IOC通信データが含まれるので全ての情報が必要
        if (cObjectInfo.sObjectType == TSR_OBJ_IOC)
          # センダ
          aSenderId = cObjectInfo.hState[TSR_PRM_SENDER]
          aSenderObject = Array.new()
          aSenderId.each{|sSenderId|
            aSenderObject.push(get_object_info(sSenderId))
          }
          # レシーバ
          sReceiverId = cObjectInfo.hState[TSR_PRM_RECEIVER]
          cReceiverObject = get_object_info(sReceiverId)
          # IOC通信データ
          aIocDataId = cObjectInfo.hState[TSR_PRM_IOCDATA]
          aIocDataObject = Array.new()
          aIocDataId.each{|sIocDataId|
            aIocDataObject.push(get_object_info(sIocDataId))
          }
          cObjectInfo.gc_config(cElement, aSenderObject, cReceiverObject, aIocDataObject)
        # 割込み禁止状態，IOCのセンダ・レシーバ・データは必要なし
        # C1ISR，C2ISR，フック，ハードウェアカウンタ，リスタートタスクは共有関数のため別途定義する
        elsif ((cObjectInfo.sObjectType != TSR_OBJ_INT_STATE) &&
               (cObjectInfo.sObjectType != TSR_OBJ_IOC_SENDER) &&
               (cObjectInfo.sObjectType != TSR_OBJ_IOC_RECEIVER) &&
               (cObjectInfo.sObjectType != TSR_OBJ_IOC_DATA) &&
               (cObjectInfo.sObjectType != TSR_OBJ_RESTART_TASK) &&
               !GRP_PROCESS_UNIT_ISR.include?(cObjectInfo.sObjectType) &&
               !GRP_PROCESS_UNIT_HOOK.include?(cObjectInfo.sObjectType) &&
               !(cObjectInfo.sObjectType == TSR_OBJ_COUNTER && cObjectInfo.is_hardware_counter?()))
          cObjectInfo.gc_config(cElement)
        end
      }
    end

    #=================================================================
    # 概  要: 実行状態，実行可能状態のタスクを設定するコードを返す
    #=================================================================
    def gc_pre_task_running_ready()

      cElement = IMCodeElement.new()  # elementクラスを用意する

      # シングルコア
      if (@cConf.is_single?())
        task_running_ready(cElement, @hTask, @cRunning, @cActivate, @aInternalResID, @hInternalResPri, true)
      # マルチコア
      else
        # メインタスクから最初の起動処理を行うので，マスタコアを最後に行う
        @aCoreid.each{|nCoreid|
          if (nCoreid != @nMasterCoreid)
            task_running_ready(cElement, @aTaskEachCore[nCoreid], @aRunning[nCoreid], @aActivate[nCoreid], @aInternalResIDEachCore[nCoreid], @aInternalResPriEachCore[nCoreid], false)
          end
        }
        task_running_ready(cElement, @aTaskEachCore[@nMasterCoreid], @aRunning[@nMasterCoreid], @aActivate[@nMasterCoreid], @aInternalResIDEachCore[@nMasterCoreid], @aInternalResPriEachCore[@nMasterCoreid], true)
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における実行状態，実行可能状態のタスクを設定する
    #         コードを返す
    #=================================================================
    def task_running_ready(cElement, hTask, cRunning, cActivate, aInternalResID, hInternalResPri, bMasterCore)
      check_class(IMCodeElement, cElement, true)  # IMCodeElementクラスのインスタンス
      check_class(Hash, hTask)                    # 1コア内のタスク情報
      check_class(ProcessUnit, cRunning, true)    # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)   # 実行状態非タスク情報
      check_class(Array, aInternalResID)          # 内部リソースIDリスト
      check_class(Hash, hInternalResPri)          # 内部リソース獲得時の優先度リスト
      check_class(Bool, bMasterCore)                # マスタコアかどうか

      # RUNNINGが存在しないコアは何もしない
      if (cRunning.nil?())
        return nil
      end

      # 実行状態のタスクの優先度未満のタスクと，以上のタスク情報を分割して，
      # それぞれ優先度順/porder順に保持したハッシュを作成する
      # (リソース獲得時に備え，初期優先度で比較する)
      # (実行状態のタスクのグループタスクは対象外として，後で起動する)
      sInterResID = get_running_task_internal_res_id(cRunning)
      hPorderTaskUnder = {}
      hPorderTaskOver = {}
      hTask.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_READY)
          if ((cObjectInfo.hState[TSR_PRM_CURPRI] < cRunning.hState[TSR_PRM_INIPRI]) &&
              (sInterResID.nil?() || !cObjectInfo.hState[TSR_PRM_RELRES].include?(sInterResID)))
            # キーが無ければ配列で初期化する
            if (!hPorderTaskUnder.has_key?(cObjectInfo.hState[TSR_PRM_CURPRI]))
              hPorderTaskUnder[cObjectInfo.hState[TSR_PRM_CURPRI]] = []
            end
            hPorderTaskUnder[cObjectInfo.hState[TSR_PRM_CURPRI]][cObjectInfo.hState[TSR_PRM_PORDER]] = cObjectInfo
          else
            # キーが無ければ配列で初期化する
            if (!hPorderTaskOver.has_key?(cObjectInfo.hState[TSR_PRM_CURPRI]))
              hPorderTaskOver[cObjectInfo.hState[TSR_PRM_CURPRI]] = []
            end
            hPorderTaskOver[cObjectInfo.hState[TSR_PRM_CURPRI]][cObjectInfo.hState[TSR_PRM_PORDER]] = cObjectInfo
          end
        end
      }

      # 実行状態タスクの優先度未満で，リソースを持っているタスクは，
      # 初期優先度の先頭に入れる
      # (リソース獲得前は初期優先度となっているため)
      hPorderTaskUnderDup = safe_dup(hPorderTaskUnder)
      hPorderTaskUnderDup.each{|nPri, aTaskOrder|
        aTaskOrder.each_with_index{|cTask, nIndex|
          if (!cTask.nil?() && !cTask.hState[TSR_PRM_GETRES].nil?())
            nCurPri = cTask.hState[TSR_PRM_CURPRI]
            nIniPri = cTask.hState[TSR_PRM_INIPRI]
            # 内部リソースの場合，内部リソース獲得による優先度にする
            if (aInternalResID.include?(cTask.hState[TSR_PRM_GETRES][0]))
              nIniPri = hInternalResPri[cTask.hState[TSR_PRM_GETRES][0]]
            end
            # 同一優先度タスクがいなければ初期化
            if (!hPorderTaskUnder.has_key?(nIniPri))
              hPorderTaskUnder[nIniPri] = []
            end
            hPorderTaskUnder[nIniPri].unshift(cTask)
            hPorderTaskUnder[nCurPri].delete_at(nIndex)
            # 対象優先度からタスクがなくなればキーを削除
            if (hPorderTaskUnder[nCurPri].empty?())
              hPorderTaskUnder.delete(nCurPri)
            end
          end
        }
      }

      # 優先度順に並べた配列に，porder順の配列を格納する
      aReadyTaskUnder = []
      hPorderTaskUnder.each{|nPri, aPorderTaskUnder|
        aPorderTaskUnder.delete(nil)
        aReadyTaskUnder[nPri] = aPorderTaskUnder
      }
      aReadyTaskOver = []
      hPorderTaskOver.each{|nPri, aPorderTaskOver|
        aPorderTaskOver.delete(nil)
        aReadyTaskOver[nPri] = aPorderTaskOver
      }

      # READYのタスクが存在しない優先度を取り除く
      aReadyTaskUnder.delete(nil)
      aReadyTaskOver.delete(nil)

      # 実行状態のタスクの優先度以上のタスクは順に起こすだけのため，
      # ネストした配列を平滑化する
      aReadyTaskOver.flatten!()

      # 実行状態のタスクの優先度未満のタスクを起動していく
      nReadyNum = aReadyTaskUnder.size()
      hMainTaskInfo = get_proc_unit_info()
      if (nReadyNum != 0)
        aReadyTaskUnder.each_with_index{|aTask, nIndex|
          # 各優先度における先頭のタスクから設定を行う
          cTask = aTask[0]

          hTaskInfo = get_proc_unit_info(cTask)

          # 最初のタスクはメインタスクが起動する
          if (nIndex == 0)
            cElement.set_syscall(hMainTaskInfo, "#{SS_ACT_TSK}(#{cTask.sObjectID})")

            # 他コアの場合，マスタコアのメインタスクから起動を待つ
            if (bMasterCore == false)
              cElement.set_checkpoint(hTaskInfo)
              cElement.wait_checkpoint(hMainTaskInfo, cTask.hState[TSR_PRM_COREID])
            end
          end

          # 信頼/非信頼でシステムサービスを切り替え
          if (cTask.is_trusted?())
            sActTsk = SS_ACT_TSK
            sSetEvt = SS_SET_EVT
          else
            sActTsk = TR_ACT_TSK
            sSetEvt = TR_SET_EVT
          end

          # 起動確認のためチェックポイント
          cElement.set_checkpoint(hTaskInfo)

          # リソース獲得処理
          # (リソースは各優先度の先頭のタスクしか獲得できない)
          if (!cTask.hState[TSR_PRM_GETRES].nil?())
            cTask.hState[TSR_PRM_GETRES].each{|sRes|
              cRes = get_object_info(sRes)
              # 内部リソースは獲得できない
              if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
                cElement.set_syscall(hTaskInfo, "#{SS_GET_RES}(#{sRes})")
              end
            }
          end

          # スピンロック獲得処理
          if (!cTask.hState[TSR_PRM_GETSPN].nil?())
            # READYのタスクが割込み禁止を伴うスピンロックを
            # 獲得することはあり得ないので，ここで全て獲得する
            cTask.hState[TSR_PRM_GETSPN].each{|sSpn|
              cSpinLock = get_object_info(sSpn)
              # スピンロック個数拡張
              if (sSpn =~ /\w+\/\d+-\d+\//)
                # 拡張する数分のスピンロックを取得
                cElement.set_local_var(hTaskInfo[:id], "i", TYP_SINT32)
                cElement.set_code(hTaskInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
                cElement.set_indent()
                cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                cElement.unset_indent()
                cElement.set_code(hTaskInfo, "}", false)
              else
                cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn})")
              end
            }
          end

          # 先頭以外のタスクの起動処理
          aTask.each{|cObj|
            if (cObj.sObjectID != cTask.sObjectID)
              cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cObj.sObjectID})")
            end
          }

          # イベントセット処理
          aTask.each{|cObj|
            if (!cObj.hState[TSR_PRM_CUREVT].nil?() && cObj.hState[TSR_PRM_CUREVT] != 0)
              cElement.set_syscall(hTaskInfo, "#{sSetEvt}(#{cObj.sObjectID}, #{cObj.hState[TSR_PRM_CUREVT]})")
            end
          }

          # キューイング処理
          aTask.each{|cObj|
            if (!cObj.hState[TSR_PRM_ACTCNT].nil?() && cObj.hState[TSR_PRM_ACTCNT] > 1)
              (cObj.hState[TSR_PRM_ACTCNT] - 1).times{
                cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cObj.sObjectID})")
              }
            end
          }

          # 信頼関数が起動しているREADYへの対応
          if (@hActiveTfn.has_key?(hTaskInfo[:id]))
            cActivateTfn = @hActiveTfn[hTaskInfo[:id]]
            cElement.set_syscall(hTaskInfo, "#{SS_CALL_TFN}(#{cActivateTfn.sObjectID}, &#{cActivateTfn.hState[TSR_PRM_ARG]})")
            # 以降の処理は信頼関数から行う
            hTaskInfo = get_proc_unit_info(cActivateTfn)

            # 起動した信頼関数のリソース獲得
            if (!cActivateTfn.hState[TSR_PRM_GETRES].nil?())
              cActivateTfn.hState[TSR_PRM_GETRES].each{|sRes|
                cRes = get_object_info(sRes)
                # 内部リソースは獲得できない
                if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
                  cElement.set_syscall(hTaskInfo, "#{SS_GET_RES}(#{sRes})")
                end
              }
            end

            # 起動した信頼関数のスピンロック獲得
            if (!cActivateTfn.hState[TSR_PRM_GETSPN].nil?())
              cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
                # READYのタスクが割込み禁止を伴うスピンロックを
                # 獲得することはあり得ないので，ここで全て獲得する
                cSpinLock = get_object_info(sSpn)
                # スピンロック個数拡張
                if (sSpn =~ /\w+\/\d+-\d+\//)
                  # 拡張する数分のスピンロックを取得
                  cElement.set_local_var(hTaskInfo[:id], "i", TYP_SINT32)
                  cElement.set_code(hTaskInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
                  cElement.set_indent()
                  cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                  cElement.unset_indent()
                  cElement.set_code(hTaskInfo, "}", false)
                else
                  cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn})")
                end
              }
            end
          end

          # 最後のタスクは実行状態のタスクを起動する
          if (nIndex == (nReadyNum - 1))
            # プレタスクフックのbootcntをセットしてから起動する
            set_pretask_hook_bootcnt(cElement, hTaskInfo, cRunning.hState[TSR_PRM_COREID])
            cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cRunning.sObjectID})")
            # ノンプリエンプティブのタスクの場合はScheduleでディスパッチする
            if (cTask.hState[TSR_PRM_SPOLICY] == TSR_STT_SCHNON)
              cElement.set_syscall(hTaskInfo, "#{SS_SCHEDULE}()")
            end
          # 最後でない場合は次のタスクを起動する
          else
            cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{aReadyTaskUnder[nIndex + 1][0].sObjectID})")
            # ノンプリエンプティブのタスクの場合はScheduleでディスパッチする
            if (cTask.hState[TSR_PRM_SPOLICY] == TSR_STT_SCHNON)
              cElement.set_syscall(hTaskInfo, "#{SS_SCHEDULE}()")
            end
          end
        }
      # READYのタスクが存在しない場合
      else
        # プレタスクフックのbootcntをセット後，実行状態のタスクをメインタスクから起こす
        cPreTaskHook = set_pretask_hook_bootcnt(cElement, hMainTaskInfo, cRunning.hState[TSR_PRM_COREID])
        cElement.set_syscall(hMainTaskInfo, "#{SS_ACT_TSK}(#{cRunning.sObjectID})")

        # 他コアの場合，マスタコアのメインタスクから起動を待つ
        if (bMasterCore == false)
          # プレタスクフックが起動している場合，プレタスクフックの起動を待つ
          if (!cPreTaskHook.nil?())
            cElement.set_checkpoint(get_proc_unit_info(cPreTaskHook), AKTG_SYNC_ACTIVE_SYNC)
          else
            cElement.set_checkpoint(get_proc_unit_info(cRunning), AKTG_SYNC_ACTIVE_SYNC)
          end
          # コアIDはプレタスクフックでも同じとなる
          cElement.wait_checkpoint(hMainTaskInfo, cRunning.hState[TSR_PRM_COREID], AKTG_SYNC_ACTIVE_SYNC)
        end
      end


      # 実行状態のタスクがリソース獲得中の場合
      if (!cRunning.hState[TSR_PRM_GETRES].nil?())
        hTaskInfo = get_proc_unit_info(cRunning)
        cRunning.hState[TSR_PRM_GETRES].each{|sRes|
          cRes = get_object_info(sRes)
          # 内部リソースは獲得できない
          if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
            cElement.set_syscall(hTaskInfo, "#{SS_GET_RES}(#{sRes})")
          end
        }
      end

      # 実行状態のタスクがスピンロック獲得中の場合
      if (!cRunning.hState[TSR_PRM_GETSPN].nil?())
        hTaskInfo = get_proc_unit_info(cRunning)

        # 割込み禁止を伴うスピンロックの存在チェック
        bCpinChk = false
        cRunning.hState[TSR_PRM_GETSPN].each{|sSpn|
          cSpinLock = get_object_info(sSpn)
          if (cSpinLock.hState[TSR_PRM_SUSINT] != TSR_STT_DO_NOT_CARE)
            bCpinChk = true
            break
          end
        }

        # 割込み禁止を伴わないスピンロックのみの場合，ここで処理する
        if (bCpinChk == false)
          cRunning.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            # スピンロック個数拡張
            if (sSpn =~ /\w+\/\d+-\d+\//)
              # 拡張する数分のスピンロックを取得
              cElement.set_local_var(hTaskInfo[:id], "i", TYP_SINT32)
              cElement.set_code(hTaskInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
              cElement.set_indent()
              cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
              cElement.unset_indent()
              cElement.set_code(hTaskInfo, "}", false)
            else
              cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn})")
            end
          }
        end
      end

      # 実行状態のタスクがイベントセット中の場合
      if (!cRunning.hState[TSR_PRM_CUREVT].nil?() && cRunning.hState[TSR_PRM_CUREVT] != 0)
        hTaskInfo = get_proc_unit_info(cRunning)
        if (cRunning.is_trusted?())
          sSetEvt = SS_SET_EVT
        else
          sSetEvt = TR_SET_EVT
        end
        cElement.set_syscall(hTaskInfo, "#{sSetEvt}(#{cRunning.sObjectID}, #{cRunning.hState[TSR_PRM_CUREVT]})")
      end

      # 実行状態のタスクがキューイング有りの場合
      if (!cRunning.hState[TSR_PRM_ACTCNT].nil?() && cRunning.hState[TSR_PRM_ACTCNT] > 1)
        hTaskInfo = get_proc_unit_info(cRunning)
        if (cRunning.is_trusted?())
          sActTsk = SS_ACT_TSK
        else
          sActTsk = TR_ACT_TSK
        end
        (cRunning.hState[TSR_PRM_ACTCNT] - 1).times{
          cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cRunning.sObjectID})")
        }
      end


      # メインタスクに対する処理はマスタコアでのみ行う
      if (bMasterCore == true)
        # メインタスクを最低優先度としてディスパッチする
        cElement.set_syscall(hMainTaskInfo, "#{SS_REL_RES}(#{AKTG_DUMMY_RES})")

        # maintask_waitがtrueのときは，ここでディスパッチしないので，WaitEventで待ち状態とする
        if (@hProperty[TSR_PRM_MAINTASK_WAIT] == true)
          cElement.set_syscall(hMainTaskInfo, "#{SS_WAIT_EVT}(#{AKTG_DUMMY_EVT})")
        end

        # 次にメインタスクが実行状態となったときに再度ダミーリソースを獲得する
        cElement.set_syscall(hMainTaskInfo, "#{SS_GET_RES}(#{AKTG_DUMMY_RES})")
      end


      # 実行状態のタスクからの処理
      hTaskInfo = get_proc_unit_info(cRunning)
      if (cRunning.is_trusted?())
        sActTsk = SS_ACT_TSK
        sSetEvt = SS_SET_EVT
      else
        sActTsk = TR_ACT_TSK
        sSetEvt = TR_SET_EVT
      end

      # 信頼関数が起動しているRUNNINGへの対応
      if (@hActiveTfn.has_key?(hTaskInfo[:id]))
        cActivateTfn = @hActiveTfn[hTaskInfo[:id]]
        cElement.set_syscall(hTaskInfo, "#{SS_CALL_TFN}(#{cActivateTfn.sObjectID}, &#{cActivateTfn.hState[TSR_PRM_ARG]})")
        # 以降の処理は信頼関数から行う
        hTaskInfo = get_proc_unit_info(cActivateTfn)
        sActTsk = SS_ACT_TSK
        sSetEvt = SS_SET_EVT

        # 起動している信頼関数のリソース獲得
        if (!cActivateTfn.hState[TSR_PRM_GETRES].nil?())
          cActivateTfn.hState[TSR_PRM_GETRES].each{|sRes|
            cRes = get_object_info(sRes)
            # 内部リソースは獲得できない
            if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
              cElement.set_syscall(hTaskInfo, "#{SS_GET_RES}(#{sRes})")
            end
          }
        end

        # 起動している信頼関数のスピンロック獲得
        if (!cActivateTfn.hState[TSR_PRM_GETSPN].nil?())
          # 割込み禁止を伴うスピンロックの存在チェック
          bCpinChk = false
          cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            if (cSpinLock.hState[TSR_PRM_SUSINT] != TSR_STT_DO_NOT_CARE)
              bCpinChk = true
              break
            end
          }

          # 割込み禁止を伴わないスピンロックのみの場合，ここで処理する
          if (bCpinChk == false)
            cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
              cSpinLock = get_object_info(sSpn)
              # スピンロック個数拡張
              if (sSpn =~ /\w+\/\d+-\d+\//)
                # 拡張する数分のスピンロックを取得
                cElement.set_local_var(hTaskInfo[:id], "i", TYP_SINT32)
                cElement.set_code(hTaskInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
                cElement.set_indent()
                cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                cElement.unset_indent()
                cElement.set_code(hTaskInfo, "}", false)
              else
                cElement.set_syscall(hTaskInfo, "#{SS_GET_SPN}(#{sSpn})")
              end
            }
          end
        end
      end


      # 実行状態のタスクから，実行状態のタスクの優先度以上のタスクを起動していく
      nReadyNum = aReadyTaskOver.size()
      if (nReadyNum != 0)
        aReadyTaskOver.each{|cTask|
          # 対象タスクを起動
          cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cTask.sObjectID})")

          # イベントセット処理
          if (!cTask.hState[TSR_PRM_CUREVT].nil?() && cTask.hState[TSR_PRM_CUREVT] != 0)
            cElement.set_syscall(hTaskInfo, "#{sSetEvt}(#{cTask.sObjectID}, #{cTask.hState[TSR_PRM_CUREVT]})")
          end

          # キューイング処理
          if (!cTask.hState[TSR_PRM_ACTCNT].nil?() && cTask.hState[TSR_PRM_ACTCNT] > 1)
            (cTask.hState[TSR_PRM_ACTCNT] - 1).times{
              cElement.set_syscall(hTaskInfo, "#{sActTsk}(#{cTask.sObjectID})")
            }
          end
        }
      end

      # ポストタスクフックが起動中の場合，ここでbootcntをセットする
      if (!cActivate.nil?() && (cActivate.sObjectType == TSR_OBJ_POSTTASK_HOOK))
        hProcUnitInfo = get_proc_unit_info(cRunning)

        # 信頼関数が起動しているRUNNINGへの対応
        if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
          hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
        end

        sCommonID = cActivate.get_common_id()
        cElement.set_code(hProcUnitInfo, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{@sTestID}")
        cElement.set_syscall(hProcUnitInfo, "#{SS_TER_TSK}()")
      end

    end
    private :task_running_ready

    #=================================================================
    # 概  要: 動作中のスケジュールテーブルを設定するコードを返す
    #=================================================================
    def gc_pre_set_start_schedule_table()
      cElement  = IMCodeElement.new()  # elementクラスを用意する

      bChk = false
      hSetBeforeIcounter = {}
      hSetAfterIcounter = {}
      hCounter = {}

      hObjects = get_objects_by_type(TSR_OBJ_SCHEDULE_TABLE)
      hObjects.each{|sObjectID, cObjectInfo|
        # 動作状態，同期動作状態でない場合
        if ((cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT) || (cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_STOPPED))
          next
        end
        # 動作状態，同期動作状態の場合
        # カウンタのcurvalがスケジュールテーブルのcurval以下の場合
        if (@hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]].hState[TSR_PRM_CURVAL] <= cObjectInfo.hState[TSR_PRM_CURVAL])
          hSetBeforeIcounter[sObjectID] = cObjectInfo
        else
          hSetAfterIcounter[sObjectID] = cObjectInfo
        end
      }

      # カウンタのcurvalがスケジュールテーブルのcurval以下の場合
      if (!hSetBeforeIcounter.empty?())
        # 同時に満了する場合に備えて，オブジェクトIDでソートしてセットする
        hSetBeforeIcounter.sort.each{|aScheTblInfo|
          sObjectID    = aScheTblInfo[0]
          cObjectInfo  = aScheTblInfo[1]
          cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]

          # シングルコアでは一律メインタスクから実行する
          hProcUnitInfo = nil
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info()
          # マルチコアでは，IncrementCounterがコアを跨げないため，各コアから行う
          else
            # マスタコアではプレタスクフック起動に備えて，メインタスクで行う
            if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
              hProcUnitInfo = get_proc_unit_info()
            # スレーブコアでは必ずタスクが起動している
            else
              hProcUnitInfo = get_proc_unit_info(@aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
            end
          end

          nCntMax = cCounterInfo.hState[TSR_PRM_MAXVAL]
          nTick = nCntMax + cCounterInfo.hState[TSR_PRM_CURVAL] - cObjectInfo.hState[TSR_PRM_CURVAL] + 1
          # nTickがカウンタの最大値よりも大きい場合は，カウンタの最大値+1との差をnTickに指定
          if (nTick > nCntMax)
            nTick = nTick - nCntMax - 1
          end
          cElement.set_syscall(hProcUnitInfo, "#{SS_STA_SCHTBL_ABS}(#{sObjectID}, #{nTick})")
          # IncrementCounterするための情報を保持
          if (!hCounter.has_key?(cCounterInfo.sObjectID))
            # ソフトウェア/ハードウェアカウンタでシステムサービス切り替え
            if (cCounterInfo.hState[TSR_PRM_CTYPE] == TSR_STT_HARDWARE)
              sSystemService = FNC_HWCOUNTER_INCREMENT
            else
              sSystemService = SS_INC_CNT
            end
            hCounter[cCounterInfo.sObjectID] = [(cCounterInfo.hState[TSR_PRM_MAXVAL] + 1), sSystemService, hProcUnitInfo]
          end
          bChk = true
        }
      end

      # カウンタのcurvalを0に戻す
      if (bChk == true)
          hCounter.each{|sObjectID, aCounterInfo|
            # スケジュールテーブルを起動するタスクから対象カウンタへIncrementCounterを発行
            cElement.set_local_var(aCounterInfo[2][:id], "i", TYP_SINT32)
            cElement.set_code(aCounterInfo[2], "for (i = 0; i < #{aCounterInfo[0]}; i++) {", false)
            cElement.set_indent()
            cElement.set_syscall(aCounterInfo[2], "#{aCounterInfo[1]}(#{sObjectID})")
            cElement.unset_indent()
            cElement.set_code(aCounterInfo[2], "}", false)
          }
      end

      # スケジュールテーブルのcurvalがカウンタのcurvalより小さいの場合
      if (!hSetAfterIcounter.empty?())
        # 同時に満了する場合に備えて，オブジェクトIDでソートしてセットする
        hSetAfterIcounter.sort.each{|aScheTblInfo|
          sObjectID    = aScheTblInfo[0]
          cObjectInfo  = aScheTblInfo[1]
          cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]

          # シングルコアでは一律メインタスクから実行する
          hProcUnitInfo = nil
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info()
          # マルチコアでは，IncrementCounterと合わせて，カウンタのコアから行う
          else
            # マスタコアではプレタスクフック起動に備えて，メインタスクで行う
            if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
              hProcUnitInfo = get_proc_unit_info()
            # スレーブコアでは必ずタスクが起動している
            else
              hProcUnitInfo = get_proc_unit_info(@aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
            end
          end

          nTick = cCounterInfo.hState[TSR_PRM_CURVAL] - cObjectInfo.hState[TSR_PRM_CURVAL]
          cElement.set_syscall(hProcUnitInfo, "#{SS_STA_SCHTBL_ABS}(#{sObjectID}, #{nTick})")
          bChk = true
        }
      end

      # 設定するスケジュールテーブルが存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: カウンタの設定をするコードを返す
    #=================================================================
    def gc_pre_increment_counter()
      cElement  = IMCodeElement.new()  # elementクラスを用意する

      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_COUNTER) && cObjectInfo.hState[TSR_PRM_CURVAL] != 0)
          hProcUnitInfo = nil
          # シングルコアでは一律メインタスクから実行する
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info()
          # マルチコアでは，IncrementCounterがコアを跨げないため，各コアから行う
          else
            # マスタコアではプレタスクフック起動に備えて，メインタスクで行う
            if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
              hProcUnitInfo = get_proc_unit_info()
            # スレーブコアでは必ずタスクが起動している
            else
              hProcUnitInfo = get_proc_unit_info(@aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
            end
          end

          # ソフトウェア/ハードウェアカウンタでシステムサービス切り替え
          if (cObjectInfo.hState[TSR_PRM_CTYPE] == TSR_STT_HARDWARE)
            sSystemService = FNC_HWCOUNTER_INCREMENT
          else
            sSystemService = SS_INC_CNT
          end

          # 対象カウンタへIncrementCounterを発行
          cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
          cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{cObjectInfo.hState[TSR_PRM_CURVAL]}; i++) {", false)
          cElement.set_indent()
          cElement.set_syscall(hProcUnitInfo, "#{sSystemService}(#{sObjectID})")
          cElement.unset_indent()
          cElement.set_code(hProcUnitInfo, "}", false)
        end
      }

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 動作中のアラーム設定をするコードを返す
    #=================================================================
    def gc_pre_set_alarm()
      cElement  = IMCodeElement.new()  # elementクラスを用意する

      hAlarmInfo = get_all_object_info(TSR_OBJ_ALARM)
      # 同時に満了する場合に備えて，オブジェクトIDでソートしてセットする
      hAlarmInfo.sort.each{|aAlarmInfo|
        sObjectID    = aAlarmInfo[0]
        cObjectInfo  = aAlarmInfo[1]
        cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]

        if (cObjectInfo.hState[TSR_PRM_ASTAT] == TSR_STT_SET)
          hProcUnitInfo = nil
          # シングルコアでは一律メインタスクから実行する
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info()
          # マルチコアでは，SetAbsAlarmはコアを跨ぐことができるが，
          # IncrementCounter後に実行する必要があるので，各コアから行う
          else
            # マスタコアではプレタスクフック起動に備えて，メインタスクで行う
            if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
              hProcUnitInfo = get_proc_unit_info()
            # スレーブコアでは必ずタスクが起動している
            else
              hProcUnitInfo = get_proc_unit_info(@aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
            end
          end

          # 対象アラームへSetAbsAlarmを発行
          cElement.set_syscall(hProcUnitInfo, "#{SS_SET_ABS_ALM}(#{sObjectID}, #{cObjectInfo.hState[TSR_PRM_ALMVAL]}, #{cObjectInfo.hState[TSR_PRM_CYCLE]})")
        end
      }

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: イベント待ちタスクの設定をするコードを返す
    #         (キューイング，イベント設定もここで行う)
    #=================================================================
    def gc_pre_task_waiting()
      cElement  = IMCodeElement.new()  # elementクラスを用意する

      bChk = false
      @hTask.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.hState[TSR_PRM_STATE] == TSR_STT_WAITING)
          hMainTaskInfo = get_proc_unit_info()
          hTaskInfo = get_proc_unit_info(cObjectInfo)

          # 起動確認のためのチェックポイント
          cElement.set_checkpoint(hTaskInfo)

          # 信頼関数が起動しているWAITINGへの対応
          if (@hActiveTfn.has_key?(hTaskInfo[:id]))
            cActivateTfn = @hActiveTfn[hTaskInfo[:id]]
            cElement.set_syscall(hTaskInfo, "#{SS_CALL_TFN}(#{cActivateTfn.sObjectID}, &#{cActivateTfn.hState[TSR_PRM_ARG]})")
            hTaskInfo = get_proc_unit_info(cActivateTfn)
            # 信頼関数からWaitEventを発行
            cElement.set_syscall(hTaskInfo, "#{SS_WAIT_EVT}(#{cActivateTfn.hState[TSR_PRM_WAIEVT]})")
          else
            # 対象タスクからWaitEventを発行
            cElement.set_syscall(hTaskInfo, "#{SS_WAIT_EVT}(#{cObjectInfo.hState[TSR_PRM_WAIEVT]})")
          end

          # メインタスクから対象タスクを起動
          cElement.set_syscall(hMainTaskInfo, "#{SS_ACT_TSK}(#{sObjectID})")

          if (@cConf.is_single?() || (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid))
            # メインタスクの優先度を下げて，対象タスクへディスパッチ
            cElement.set_syscall(hMainTaskInfo, "#{SS_REL_RES}(#{AKTG_DUMMY_RES})")
            # 対象タスクが待ちに入るので，メインタスクの優先度を戻す
            cElement.set_syscall(hMainTaskInfo, "#{SS_GET_RES}(#{AKTG_DUMMY_RES})")
          else
            if (cObjectInfo.sObjectType == TSR_OBJ_RESTART_TASK)
              sObjectID = cObjectInfo.get_common_id()
            end
            cElement.set_state_sync(hMainTaskInfo, sObjectID, TSR_STT_WAITING, AKTG_SYNC_STATE_SYNC)
          end

          # 対象タスクがイベントセット中の場合
          if (!cObjectInfo.hState[TSR_PRM_CUREVT].nil?() && cObjectInfo.hState[TSR_PRM_CUREVT] != 0)
            cElement.set_syscall(hMainTaskInfo, "#{SS_SET_EVT}(#{sObjectID}, #{cObjectInfo.hState[TSR_PRM_CUREVT]})")
          end

          # 対象タスクがキューイング有りの場合
          if (!cObjectInfo.hState[TSR_PRM_ACTCNT].nil?() && cObjectInfo.hState[TSR_PRM_ACTCNT] > 1)
            (cObjectInfo.hState[TSR_PRM_ACTCNT] - 1).times{
              cElement.set_syscall(hMainTaskInfo, "#{SS_ACT_TSK}(#{sObjectID})")
            }
          end

          # メインタスクへ戻ったことの確認のためのチェックポイント
          cElement.set_checkpoint(hMainTaskInfo)

          bChk = true
        end
      }
      # イベント待ちタスクが存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 切替え待ち状態のスケジュールテーブルを設定するコードを返
    #         す
    #=================================================================
    def gc_pre_set_next_schedule_table()
      cElement  = IMCodeElement.new()  # elementクラスを用意する

      hNextSchtbl = {}

      hObjects = get_objects_by_type(TSR_OBJ_SCHEDULE_TABLE)
      hObjects.each{|sObjectID, cObjectInfo|
        # 切り替え待ち状態の場合
        if (cObjectInfo.hState[TSR_PRM_STSTAT] == TSR_STT_SCHTBL_NEXT)
          hNextSchtbl[sObjectID] = cObjectInfo
        end
      }

      if (hNextSchtbl.size > 0)
        # 同時に満了する場合に備えて，オブジェクトIDでソートしてセットする
        hNextSchtbl.sort.each{|aScheTblInfo|
          sObjectID    = aScheTblInfo[0]
          cObjectInfo  = aScheTblInfo[1]
          cCounterInfo = @hAllObject[cObjectInfo.hState[TSR_PRM_COUNTER]]

          # シングルコアでは一律メインタスクから実行する
          hProcUnitInfo = nil
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info()
          # マルチコアでは，IncrementCounterと合わせて，カウンタのコアから行う
          else
            # マスタコアではプレタスクフック起動に備えて，メインタスクで行う
            if (cObjectInfo.hState[TSR_PRM_COREID] == @nMasterCoreid)
              hProcUnitInfo = get_proc_unit_info()
            # スレーブコアでは必ずタスクが起動している
            else
              hProcUnitInfo = get_proc_unit_info(@aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
            end
          end

          cElement.set_syscall(hProcUnitInfo, "#{SS_NXT_SCHTBL}(#{cObjectInfo.hState[TSR_PRM_STFROM]}, #{sObjectID})")
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 共有関数からテストケース毎の関数を呼び出すコードを返す
    #=================================================================
    def gc_pre_call_each_func()
      cElement = IMCodeElement.new()

      # ACTIVATEになるかに関わらず，共有するISR関数から該当テスト用関数を呼び出す
      bChk = false
      GRP_SHARED_PROCESS_UNIT.each{|sProcUnitType|
        hObjInfo = get_all_object_info(sProcUnitType)
        hObjInfo.each{|sObjectID, cObjectInfo|
          hProcUnitInfo = {:id => cObjectInfo.get_common_id(), :coreid => cObjectInfo.hState[TSR_PRM_COREID], :bootcnt => AKTG_MAIN_BOOTCNT}

          case sProcUnitType

          # エラーフックの場合，エラーコードを渡す
          when TSR_OBJ_ERROR_HOOK, TSR_OBJ_ERROR_HOOK_OSAP
            cElement.set_code(hProcUnitInfo, "#{sObjectID}(#{VAR_ERROR})")

          # プロテクションフックの場合，エラーコードを渡し返り値を受け取る
          when TSR_OBJ_PROTECTION_HOOK
            cElement.set_code(hProcUnitInfo, "#{VAR_ERROR} = #{sObjectID}(#{VAR_FATAL_ERROR})")

          # シャットダウンフックの場合，エラーコードを渡し返り値を受け取る
          # (強制マージの場合はbootcntを入れる)
          when TSR_OBJ_SHUTDOWN_HOOK, TSR_OBJ_SHUTDOWN_HOOK_OSAP
            if (@cConf.enable_forced_merge() == true)
              cElement.set_code(hProcUnitInfo, "if (#{AKTG_FORCE_MERGE_BOOTCNT} == #{AKTG_FORCE_MERGE_ENUM}_#{@sTestID}) {", false)
              cElement.set_indent()
            end
            cElement.set_code(hProcUnitInfo, "#{sObjectID}(#{VAR_ERROR})")
            if (@cConf.enable_forced_merge() == true)
              cElement.unset_indent()
              cElement.set_code(hProcUnitInfo, "}", false)
            end

          # スタートアップフックの場合かつ強制マージの場合はbootcntを入れる
          when TSR_OBJ_STARTUP_HOOK, TSR_OBJ_STARTUP_HOOK_OSAP
            if (@cConf.enable_forced_merge() == true)
              cElement.set_code(hProcUnitInfo, "if (#{AKTG_FORCE_MERGE_BOOTCNT} == #{AKTG_FORCE_MERGE_ENUM}_#{@sTestID}) {", false)
              cElement.set_indent()
            end
            cElement.set_code(hProcUnitInfo, "#{sObjectID}()")
            if (@cConf.enable_forced_merge() == true)
              cElement.unset_indent()
              cElement.set_code(hProcUnitInfo, "}", false)
            end

          # ISRの場合，IDと区別するためにプレフィックスを付ける
          when TSR_OBJ_C1ISR, TSR_OBJ_C2ISR, TSR_OBJ_ICISR
            cElement.set_code(hProcUnitInfo, "#{AKTG_LBL_ISR_FUNC}#{sObjectID}()")

          # リスタートタスクの場合
          when TSR_OBJ_RESTART_TASK
            cElement.set_code(hProcUnitInfo, "#{sObjectID}()")

          else
            cElement.set_code(hProcUnitInfo, "#{sObjectID}()")
          end

          bChk = true
        }
      }
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 起動状態のC1/C2ISRの設定をするコードを返す
    #=================================================================
    def gc_pre_isr_activate(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      cElement = IMCodeElement.new()

      if (@cConf.is_single?())
        isr_activate(cElement, sObjectType, @cRunning, @cActivate)
      else
        @aCoreid.each{|nCoreid|
          isr_activate(cElement, sObjectType, @aRunning[nCoreid], @aActivate[nCoreid])
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における起動状態のC1/C2/ICISRの設定をするコードを返す
    #=================================================================
    def isr_activate(cElement, sObjectType, cRunning, cActivate)
      check_class(IMCodeElement, cElement, true)  # IMCodeElementクラスのインスタンス
      check_class(String, sObjectType)            # 対象とするオブジェクトタイプ
      check_class(ProcessUnit, cRunning, true)    # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)   # 実行状態非タスク情報

      # ACTIVATEな処理単位が対象タイプと異なる場合はnilを返す
      if (cActivate.nil?() || (cActivate.sObjectType != sObjectType))
        return
      end

      hRunningInfo = get_proc_unit_info(cRunning)

      # 信頼関数が起動しているRUNNINGへの対応
      if (@hActiveTfn.has_key?(hRunningInfo[:id]))
        hRunningInfo = get_proc_unit_info(@hActiveTfn[hRunningInfo[:id]])
      end

      # 割込み発生関数を実行して起動する
      if (sObjectType == TSR_OBJ_ICISR)
        # 実行状態のタスクが非信頼の場合は，信頼関数経由でICISRを起動する
        if (cRunning.is_trusted?())
          sRaiseIcisr = SS_RAISE_ICISR
        else
          sRaiseIcisr = TR_RAISE_ICISR
        end
        cElement.set_syscall(hRunningInfo, "#{sRaiseIcisr}(#{cActivate.get_common_id()})")
      else
        cElement.set_code(hRunningInfo, "#{FNC_INT_RAISE}(#{cActivate.hState[TSR_PRM_INTNO]})")
      end

      # 割込み発生が遅延した場合に備え，非タスク側でチェックポイントを発行し，
      # 発行元でチェックポイントを待つ
      hActivateInfo = get_proc_unit_info(cActivate)
      cElement.set_checkpoint(hActivateInfo)
      # シングルコアでは関数側でコアIDを使用しない
      cElement.wait_checkpoint(hRunningInfo, hActivateInfo[:coreid])

      # リソース獲得中の場合，獲得処理を行う
      if (!cActivate.hState[TSR_PRM_GETRES].nil?())
        cActivate.hState[TSR_PRM_GETRES].each{|sRes|
          cElement.set_syscall(hActivateInfo, "#{SS_GET_RES}(#{sRes})")
        }
      end

      # 信頼関数が起動しているC2ISRへの対応
      if (@hActiveTfn.has_key?(cActivate.sObjectID))
        cActivateTfn = @hActiveTfn[cActivate.sObjectID]
        cElement.set_syscall(hActivateInfo, "#{SS_CALL_TFN}(#{cActivateTfn.sObjectID}, &#{cActivateTfn.hState[TSR_PRM_ARG]})")

        # 起動している信頼関数のリソース獲得
        if (!cActivateTfn.hState[TSR_PRM_GETRES].nil?())
          hProcUnitInfo = get_proc_unit_info(cActivateTfn)
          cActivateTfn.hState[TSR_PRM_GETRES].each{|sRes|
            cRes = get_object_info(sRes)
            # 内部リソースは獲得できない
            if (cRes.hState[TSR_PRM_RESPROP] != TSR_STT_INTERNAL)
              cElement.set_syscall(hProcUnitInfo, "#{SS_GET_RES}(#{sRes})")
            end
          }
        end
      end
    end
    private :isr_activate

    #=================================================================
    # 概  要: 起動状態のエラー/プロテクションフックの設定をするコードを
    #         返す
    #=================================================================
    def gc_pre_hook_activate(sObjectType, bCannotMerge)
      check_class(String, sObjectType)  # 対象とするオブジェクトタイプ
      check_class(Bool, bCannotMerge)   # 1件のみのテストケースかどうか

      cElement = IMCodeElement.new()

      # シングルコア
      if (@cConf.is_single?())
        hook_activate(cElement, sObjectType, bCannotMerge, @cRunning, @cActivate)
      # マルチコア
      else
        @aCoreid.each{|nCoreid|
          hook_activate(cElement, sObjectType, bCannotMerge, @aRunning[nCoreid], @aActivate[nCoreid])
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 1コア内における起動状態のエラー/プロテクションフックの設
    #         定をするコードを返す
    #=================================================================
    def hook_activate(cElement, sObjectType, bCannotMerge, cRunning, cActivate)
      check_class(IMCodeElement, cElement, true)  # IMCodeElementクラスのインスタンス
      check_class(String, sObjectType)            # 対象とするオブジェクトタイプ
      check_class(Bool, bCannotMerge)             # 1件のみのテストケースかどうか
      check_class(ProcessUnit, cRunning, true)    # 実行状態タスク情報
      check_class(ProcessUnit, cActivate, true)   # 実行状態非タスク情報

      # ACTIVATEな処理単位が対象タイプと異なる場合はnilを返す
      if (cActivate.nil?() || (cActivate.sObjectType != sObjectType))
        return nil
      end

      hProcUnitInfo = get_proc_unit_info(cRunning)

      # 信頼関数が起動しているRUNNINGへの対応
      if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
        hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
      end

      # エラーフックの場合，エラーフック起動関数を実行して起動する
      if ((sObjectType == TSR_OBJ_ERROR_HOOK) || (sObjectType == TSR_OBJ_ERROR_HOOK_OSAP))
        cElement.set_code(hProcUnitInfo, FNC_RAISE_ERROR_HOOK)
      # プロテクションフックの場合，プロテクションフック起動関数を実行して起動する
      elsif (sObjectType == TSR_OBJ_PROTECTION_HOOK)
        cElement.set_code(hProcUnitInfo, FNC_RAISE_PROTECTION_HOOK)
      # 1件のみのテストケースの場合，シャットダウンフックを起動する
      elsif ((bCannotMerge == true) && ((sObjectType == TSR_OBJ_SHUTDOWN_HOOK) || (sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)))
        if (@cConf.is_single?())
          cElement.set_code(hProcUnitInfo, "#{SS_SHUTDOWN_OS}(E_OK)")
        elsif (@cConf.is_multi?())
          cElement.set_code(hProcUnitInfo, "#{SS_SHUTDOWN_ALL}(E_OK)")
        end
      else
        return nil  # 処理必要なし
      end

      # フック起動が遅延した場合に備え，非タスク側でチェックポイントを発行し，
      # 発行元でチェックポイントを待つ
      hActivateInfo = get_proc_unit_info(cActivate)
      cElement.set_checkpoint(hActivateInfo)
      # シングルコアでは関数側でコアIDを使用しない
      cElement.wait_checkpoint(hProcUnitInfo, hActivateInfo[:coreid])

    end
    private :hook_activate

    #=================================================================
    # 概  要: 割込み禁止を伴うスピンロック取得の設定をするコードを返す
    #=================================================================
    def gc_pre_get_spinlock_sus_int(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) == true) && 
            (cObjectInfo.hState[TSR_PRM_GETSPN] != nil) &&
            (cObjectInfo.sObjectType == sObjectType))
          # 割込み禁止を伴うスピンロックの存在チェック
          bCpinChk = false
          cObjectInfo.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            if (cSpinLock.hState[TSR_PRM_SUSINT] != TSR_STT_DO_NOT_CARE)
              bCpinChk = true
              break
            end
          }

          # 割込み禁止を伴うスピンロックが含まれる場合，ここで処理する
          if (bCpinChk == true)
            hProcUnitInfo = get_proc_unit_info(cObjectInfo)
            cObjectInfo.hState[TSR_PRM_GETSPN].each{|sSpn|
              cSpinLock = get_object_info(sSpn)
              # スピンロック個数拡張
              if (sSpn =~ /\w+\/\d+-\d+\//)
                # 拡張する数分のスピンロックを取得
                cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
                cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
                cElement.set_indent()
                cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                cElement.unset_indent()
                cElement.set_code(hProcUnitInfo, "}", false)
              else
                cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn})")
              end
            }
            bChk = true
          end
        elsif ((@hActiveTfn.has_key?(sObjectID)) && (cObjectInfo.sObjectType == sObjectType) &&
               (@hActiveTfn[sObjectID].hState[TSR_PRM_GETSPN] != nil))
          cActivateTfn = @hActiveTfn[sObjectID]

          # 割込み禁止を伴うスピンロックの存在チェック
          bCpinChk = false
          cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            if (cSpinLock.hState[TSR_PRM_SUSINT] != TSR_STT_DO_NOT_CARE)
              bCpinChk = true
              break
            end
          }

          # 割込み禁止を伴うスピンロックが含まれる場合，ここで処理する
          if (bCpinChk == true)
            hProcUnitInfo = get_proc_unit_info(cActivateTfn)
            cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
              cSpinLock = get_object_info(sSpn)
              # スピンロック個数拡張
              if (sSpn =~ /\w+\/\d+-\d+\//)
                # 拡張する数分のスピンロックを取得
                cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
                cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
                cElement.set_indent()
                cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
                cElement.unset_indent()
                cElement.set_code(hProcUnitInfo, "}", false)
              else
                cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn})")
              end
            }
            bChk = true
          end
        end
      }
      # スピンロックを獲得している処理単位が存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: すべてのスピンロック取得の設定をするコードを返す
    #=================================================================
    def gc_pre_get_all_spinlock(sObjectType)
      check_class(String, sObjectType)   # 対象とするオブジェクトタイプ

      cElement = IMCodeElement.new()

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((GRP_PROCESS_UNIT_SPINLOCK.include?(cObjectInfo.sObjectType) == true) && 
            (cObjectInfo.hState[TSR_PRM_GETSPN] != nil) && (cObjectInfo.sObjectType == sObjectType))
          hProcUnitInfo = get_proc_unit_info(cObjectInfo)
          cObjectInfo.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            # スピンロック個数拡張
            if (sSpn =~ /\w+\/\d+-\d+\//)
              # 拡張する数分のスピンロックを取得
              cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
              cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
              cElement.set_indent()
              cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
              cElement.unset_indent()
              cElement.set_code(hProcUnitInfo, "}", false)
            else
              cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn})")
            end
          }
          bChk = true
        elsif ((@hActiveTfn.has_key?(sObjectID)) && (cObjectInfo.sObjectType == sObjectType) &&
               (@hActiveTfn[sObjectID].hState[TSR_PRM_GETSPN] != nil))
          cActivateTfn = @hActiveTfn[sObjectID]

          hProcUnitInfo = get_proc_unit_info(cActivateTfn)
          cActivateTfn.hState[TSR_PRM_GETSPN].each{|sSpn|
            cSpinLock = get_object_info(sSpn)
            # スピンロック個数拡張
            if (sSpn =~ /\w+\/\d+-\d+\//)
              # 拡張する数分のスピンロックを取得
              cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
              cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{cSpinLock.nExNum}; i++) {", false)
              cElement.set_indent()
              cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn[/(\w+)\/\d+-\d+\//, 1]}_SpinlockId[i])")
              cElement.unset_indent()
              cElement.set_code(hProcUnitInfo, "}", false)
            else
              cElement.set_syscall(hProcUnitInfo, "#{SS_GET_SPN}(#{sSpn})")
            end
          }
          bChk = true
        end
      }
      # スピンロックを獲得している処理単位が存在しなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement]エレメント
    end

    #=================================================================
    # 概  要: 割込み禁止状態の設定をするコードを返す
    #=================================================================
    def gc_pre_interrupt(bByTask)
      check_class(Bool, bByTask)  # タスクによる割込み禁止か

      cElement = IMCodeElement.new()  # elementクラスを用意する

      bChk = false
      @hAllObject.each{|sObjectID, cObjectInfo|
        if ((cObjectInfo.sObjectType == TSR_OBJ_INT_STATE) && cObjectInfo.is_state_changed?())
          if (cObjectInfo.is_dis_all_int?())
            cProcUnit = get_object_info(cObjectInfo.hState[TSR_PRM_INT_STATE][0][TSR_STT_DIS_ALL_INT])
            if (((bByTask == true) && (cProcUnit.sObjectType == TSR_OBJ_TASK)) ||
                ((bByTask == false) && (cProcUnit.sObjectType != TSR_OBJ_TASK)))
              hProcUnitInfo = get_proc_unit_info(cProcUnit)
              cElement.set_code(hProcUnitInfo, "#{SS_DIS_ALL_INT}()")
            end
          elsif (cObjectInfo.is_sus_all_int?() || cObjectInfo.is_sus_os_int?())
            cObjectInfo.hState[TSR_PRM_INT_STATE].each{|hIntState|
              if (hIntState.has_key?(TSR_STT_SUS_ALL_INT))
                cProcUnit = get_object_info(hIntState[TSR_STT_SUS_ALL_INT])
                if (((bByTask == true) && (cProcUnit.sObjectType == TSR_OBJ_TASK)) ||
                    ((bByTask == false) && (cProcUnit.sObjectType != TSR_OBJ_TASK)))
                  # スピンロックによる割込み禁止は，スピンロック獲得で禁止するので，ここでは何もしない
                  if (cProcUnit.sObjectType != TSR_OBJ_SPINLOCK)
                    hProcUnitInfo = get_proc_unit_info(cProcUnit)
                    cElement.set_code(hProcUnitInfo, "#{SS_SUS_ALL_INT}()")
                  end
                end
              else
                cProcUnit = get_object_info(hIntState[TSR_STT_SUS_OS_INT])
                if (((bByTask == true) && (cProcUnit.sObjectType == TSR_OBJ_TASK)) ||
                    ((bByTask == false) && (cProcUnit.sObjectType != TSR_OBJ_TASK)))
                  # スピンロックによる割込み禁止は，スピンロック獲得で禁止するので，ここでは何もしない
                  if (cProcUnit.sObjectType != TSR_OBJ_SPINLOCK)
                    hProcUnitInfo = get_proc_unit_info(cProcUnit)
                    cElement.set_code(hProcUnitInfo, "#{SS_SUS_OS_INT}()")
                  end
                end
              end
            }
          end

          bChk = true
        end
      }
      # 割込み禁止状態でなければnilを返す
      if (bChk == false)
        return nil
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフックからテストID開始メッセ
    #         ージ出力するコードを返す
    #=================================================================
    def gc_pre_test_start_message()
      cElement  = IMCodeElement.new()

      cActivate = nil
      if (@cConf.is_single?())
        cActivate = @cActivate
      else
        # マルチコアの場合，いずれかのコアで実行中の処理単位から出力する
        @aCoreid.each{|nCoreid|
          if (!@aActivate[nCoreid].nil?())
            cActivate = @aActivate[nCoreid]
            break
          end
        }
      end

      if (!cActivate.nil?() &&
          ((cActivate.sObjectType == TSR_OBJ_STARTUP_HOOK) || (cActivate.sObjectType == TSR_OBJ_STARTUP_HOOK_OSAP) ||
           (cActivate.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) || (cActivate.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)))
        hProcUnitInfo = get_proc_unit_info(cActivate)
        cElement.set_code(hProcUnitInfo, "#{FNC_OUTPUT_LOG_0}(\"#{@sTestID}: Start\")")

        # スタートアップ/シャットダウンフック用コードがあれば出力
        @aStartupShutdownHookCode.each{|sCode|
          cElement.set_code(hProcUnitInfo, sCode)
        }
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 引数のスタートアップ/シャットダウンフック用コードを
    #         pre_conditionクラスに格納する
    #=================================================================
    def set_hook_bootcnt_code(sCode)
      check_class(String, sCode)  # 実行するコード

      @aStartupShutdownHookCode.push(sCode)
    end

    #=================================================================
    # 概  要: 最後のシャットダウンフックでカーネル終了処理を行うコード
    #         を返す
    #=================================================================
    def gc_finish_cp_on_shutdown_hook()
      cElement  = IMCodeElement.new()

      cActivate = nil
      if (@cConf.is_single?())
        cActivate = @cActivate
      else
        # マルチコアの場合，マスタコアの処理単位から出力する
        if (!@aActivate[@nMasterCoreid].nil?())
          cActivate = @aActivate[@nMasterCoreid]
        else
          # マスタコアに実行中の処理単位が存在しなければ，いずれかのコアで実行中の処理単位から出力する
          @aCoreid.each{|nCoreid|
            if (!@aActivate[nCoreid].nil?())
              cActivate = @aActivate[nCoreid]
              break
            end
          }
        end
      end

      # 実行中の処理単位がシャットダウンフックでないことは有り得ない
      if (cActivate.nil?() || ![TSR_OBJ_SHUTDOWN_HOOK, TSR_OBJ_SHUTDOWN_HOOK_OSAP].include?(cActivate.sObjectType))
        abort(ERR_MSG % [__FILE__, __LINE__])
      end

      hProcUnitInfo = get_proc_unit_info(cActivate)
      cElement.set_checkpoint(hProcUnitInfo)

      if (@cConf.enable_check_stack_usage() == true)
        cElement.set_print_stack_usage(hProcUnitInfo)
      end

      # 正常の場合のみ終了メッセージを出力する
      cElement.set_local_var(hProcUnitInfo[:id], VAR_STATE, TYP_UINT8)
      cElement.set_code(hProcUnitInfo, "#{VAR_STATE} = #{FNC_GET_CP_STATE}()")
      cElement.set_code(hProcUnitInfo, "if (#{VAR_STATE} == #{TSR_STT_TRUE}) {", false)
      # C++test終了
      if (@cConf.is_enable_cpptest?() && @cConf.is_cpptest_use_buffer?())
        cElement.set_code(hProcUnitInfo, "#{AKTG_TB}#{CPPTEST_FINAL}")
      end
      cElement.set_code(hProcUnitInfo, "#{AKTG_TB}#{FNC_OUTPUT_LOG_0}(\"#{AKTG_FINISH_MESSAGE}\")")
      cElement.set_code(hProcUnitInfo, "}", false)

      # GCOV取得の終了
      if (@cConf.is_enable_gcov?())
        cElement.set_code(hProcUnitInfo, FNC_GCOV_C_RESUME)
        cElement.set_code(hProcUnitInfo, FNC_GCOV_C_DUMP)
      end

      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: スタートアップ/シャットダウンフッククラスの配列をID順で
    #         生成して返す
    #=================================================================
    def get_startup_shutdown_object_info_sort_by_id(sObjectType)
      check_class(String, sObjectType)  # 対象とするオブジェクトタイプ[スタートアップorシャットダウンフック]

      aStartupShutdownInfo = []
      @hAllObject.sort.each{|aObjectInfo|
        if (aObjectInfo[1].sObjectType == sObjectType)
          aStartupShutdownInfo.push(aObjectInfo[1])
        end
      }

      return aStartupShutdownInfo  # [Array]スタートアップ/シャットダウンフッククラスの配列
    end

    #=================================================================
    # 概  要: 実行中のタスクが内部リソースに関連付けられている場合，内
    #         部リソースのIDを返す(関連付けられていない場合nilを返す)
    #=================================================================
    def get_running_task_internal_res_id(cRunning)
      check_class(ProcessUnit, cRunning, true)    # 実行状態タスク情報

      if (cRunning.nil?() || cRunning.hState[TSR_PRM_RELRES].nil?())
        return nil
      end

      cRunning.hState[TSR_PRM_RELRES].each{|sResID|
        cRes = get_object_info(sResID)
        if (cRes.hState[TSR_PRM_RESPROP] == TSR_STT_INTERNAL)
          return sResID
        end
      }

      return nil  # [nil]内部リソースが関連付けされていない
    end

    #=================================================================
    # 概  要: ACTIVATEなプレタスクフックが存在する場合，bootcntをセット
    #         する
    #=================================================================
    def set_pretask_hook_bootcnt(cElement, hProcUnitInfo, nTargetCoreid)
      check_class(IMCodeElement, cElement)  # エレメント
      check_class(Hash, hProcUnitInfo)      # 処理を実行する処理単位情報
      check_class(Integer, nTargetCoreid)   # プレタスクフックを起動するコアID

      cActivate = nil
      if (@cConf.is_single?())
        cActivate = @cActivate
      else
        cActivate = @aActivate[nTargetCoreid]
      end

      if (!cActivate.nil?() && (cActivate.sObjectType == TSR_OBJ_PRETASK_HOOK))
        sCommonID = cActivate.get_common_id()
        cElement.set_code(hProcUnitInfo, "#{sCommonID}_#{VAR_BOOTCNT} = #{sCommonID}_#{@sTestID}")
        return cActivate  # プレタスクフック情報
      end

      return nil  # プレタスクフックが存在しない場合
    end

    #=================================================================
    # 概  要: PreConditionの起動状態シャットダウンフックの有無を返す
    #=================================================================
    def exist_pre_active_shutdown_hook()
      if (@cConf.is_single?())
        if (!@cActivate.nil?() && 
            ((@cActivate.sObjectType == TSR_OBJ_SHUTDOWN_HOOK) || (@cActivate.sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)))
          return true  # 起動状態シャットダウンフック有
        else
          return false  # 起動状態シャットダウンフック無
        end
      else
        # マルチコアの場合，1つでもシャットダウンフックが存在する場合trueを返す
        @aCoreid.each{|nCoreid|
          if (!@aActivate[nCoreid].nil?() && 
              ((@aActivate[nCoreid].sObjectType == TSR_OBJ_SHUTDOWN_HOOK) || (@aActivate[nCoreid].sObjectType == TSR_OBJ_SHUTDOWN_HOOK_OSAP)))
            return true  # 起動状態シャットダウンフック有
          end
        }
        return false  # 起動状態シャットダウンフック無
      end
    end

    #=================================================================
    # 概  要: 許可状態の割込みの禁止設定をするコード返す
    #=================================================================
    def gc_pre_set_disable_int()
      cElement  = IMCodeElement.new()

      bChk = false
      hObjInfo = get_all_object_info(TSR_OBJ_C2ISR)
      if (@cConf.is_multi?())
        hIcisrObjInfo = get_all_object_info(TSR_OBJ_ICISR)
        hObjInfo = hObjInfo.merge(hIcisrObjInfo)
      end
      hObjInfo.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.hState[TSR_PRM_ISTAT] == TSR_STT_DISABLE)
          if (@cConf.is_single?())
            hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
          else
            hProcUnitInfo = get_proc_unit_info(@aActivate[cObjectInfo.hState[TSR_PRM_COREID]], @aRunning[cObjectInfo.hState[TSR_PRM_COREID]])
          end
          # 信頼関数が起動している場合は，信頼関数から発行する
          if (@hActiveTfn.has_key?(hProcUnitInfo[:id]))
            hProcUnitInfo = get_proc_unit_info(@hActiveTfn[hProcUnitInfo[:id]])
          end
          cElement.set_syscall(hProcUnitInfo, "#{SS_DIS_INT_SRC}(#{cObjectInfo.get_common_id()})")
          bChk = true
        end
      }

      # C2ISR,ICISRがなければnilを返す
      if (bChk == false)
        return nil
      end
      return cElement # [IMCodeElement] エレメント
    end

    #=================================================================
    # 概  要: 登場する割込み番号を返す
    #=================================================================
    def get_exist_intno()
      aIntNo = []

      hIsrInfo = get_objects_by_type([TSR_OBJ_C1ISR, TSR_OBJ_C2ISR])
      hIsrInfo.each{|sObjectID, cObjectInfo|
        aIntNo.push(cObjectInfo.hState[TSR_PRM_INTNO])
      }

      return aIntNo  # [Array]登場する割込み番号
    end

    #=================================================================
    # 概  要: IOCデータ格納状態を設定するコードを返す
    #=================================================================
    def gc_pre_set_ioc()
      cElement = IMCodeElement.new()

      # IOCデータ管理ブロック用構造体データ型宣言
      @hAllObject.each{|sObjectID, cObjectInfo|
        if (cObjectInfo.sObjectType == TSR_OBJ_IOC)
          sIocmbStructTypedef = "AKTSP_IOCMB_#{sObjectID}"     # typdefした構造体型
          sIocmbStructName    = sIocmbStructTypedef.downcase() # IOCデータ管理ブロックの構造体
          aIocmbStructMember  = []                             # typedefしたデータ型
          nMemberIndex = 1                                     # 構造体メンバのインデックス

          cObjectInfo.hState[TSR_PRM_IOCDATA].each{|sIodDataId|
            sVarName = "data#{nMemberIndex}"
            hIocmbStructMember = {sVarName => @hAllObject[sIodDataId].hState[TSR_PRM_DATATYPE]}
            aIocmbStructMember.push(hIocmbStructMember)
            nMemberIndex += 1
          }
          if (aIocmbStructMember.count() > 0)
            # 構造体データ型宣言
            cElement.set_struct_def(sIocmbStructName, aIocmbStructMember, sIocmbStructTypedef)
          end
        end
      }

      @hAllObject.each{|sObjectID, cObjectInfo|
        bIsPreSetIocSend = false  # IocSendの呼び出しが必要なのか
        bIsPreSetIocWrite = false # IocWriteの呼び出しが必要なのか

        # 送信APIの呼び出しが必要なのか判定する
        if (cObjectInfo.sObjectType == TSR_OBJ_IOC)
          # キューあり通信の場合
          if (!cObjectInfo.hState[TSR_PRM_DATALIST].nil?())
            bIsPreSetIocSend = true
          # キューなし通信の場合
          elsif(!cObjectInfo.hState[TSR_PRM_DATA].nil?())
            # 格納されているデータと初期値を比較する
            cObjectInfo.hState[TSR_PRM_DATA].each{|hData|
              hData.each{|sIocDataId, snValue|
                cIocDataInfo = get_object_info(sIocDataId)
                if (snValue != cIocDataInfo.hState[TSR_PRM_INITVAL])
                  bIsPreSetIocWrite = true
                end
              }
            }
          end
        end

        if ((bIsPreSetIocSend == true) or (bIsPreSetIocWrite == true))
          hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)
          sGroup    = ""         # グループ通信
          sSendID   = ""         # N:1通信の場合，センダのID
          snbReturn = "IOC_E_OK" # 戻り値

          # グループ通信の場合'Group'を付ける
          if (cObjectInfo.hState[TSR_PRM_IOCDATA].count() > 1)
            sGroup = "Group"
          # N:1通信の場合センダIDを付ける
          elsif (cObjectInfo.hState[TSR_PRM_SENDER].count() > 1)
            aSenderId = cObjectInfo.hState[TSR_PRM_SENDER]
            aSenderId.each{|sSenderId|
              # タスクと同じOSAPに所属するセンダを検索
              sTaskOsap = @hAllObject[hProcUnitInfo[:id]].hState[TSR_PRM_OSAP]
              sSenderOsap =  @hAllObject[sSenderId].hState[TSR_PRM_OSAP]
              if (sTaskOsap == sSenderOsap)
                sSendID =  "_#{@hAllObject[sSenderId].hState[TSR_PRM_SENDERID]}"
                break # 同じOSAPに所属するセンダが複数存在する場合，1番目のセンダにする
              end
            }
          end

          # キューあり通信
          if(bIsPreSetIocSend == true)
            nIndex = 1  # データのインデックス
            cObjectInfo.hState[TSR_PRM_DATALIST].each{|aDataList|
              ioc_send_write(cElement, "IocSend", sGroup, sObjectID, sSendID, nIndex, aDataList, snbReturn)
              nIndex += 1
            }
          # キューなし通信
          elsif (bIsPreSetIocWrite == true)
            ioc_send_write(cElement, "IocWrite", sGroup, sObjectID, sSendID, 0, cObjectInfo.hState[TSR_PRM_DATA], snbReturn)
          end
        end
      }
      return cElement
    end

    #=================================================================
    # 概  要: IOCデータを送信するコードを返す
    #=================================================================
    def ioc_send_write(cElement, sSysType, sGroup, sObjectID, sSendID, nIndex, aDataList, snbReturn)
      check_class(IMCodeElement, cElement)   # [IMCodeElement] エレメント
      check_class(String, sSysType)          # API名の要素(キューあり通信/キューなし通信)
      check_class(String, sGroup)            # API名の要素(単一データ通信/グループ通信)
      check_class(String, sObjectID)         # API名の要素(IOCのID)
      check_class(String, sSendID)           # API名の要素センダのID
      check_class(Integer, nIndex)           # APIの引数に指定した変数の要素(変数名の末尾につける番号)
      check_class(Array, aDataList)          # IOCに格納されたデータ
      check_class(String, snbReturn)         # 戻り値

      sParam = "" # 送信APIの引数
      hProcUnitInfo = get_proc_unit_info(@cActivate, @cRunning)

      aDataList.each{|aData|
        aData.each{|sIocData, sVal|
          # 送信API引数の変数生成
          sVarType = @hAllObject[sIocData].hState[TSR_PRM_DATATYPE]
          sVarName = "#{sIocData.downcase}_in#{nIndex}"

          # 構造体は{}で囲む
          if (STR_INITIAL_INFO.has_key?(sVarType))
            sVal = "{#{sVal}}"
          else
            sVal = "(#{sVarType})#{sVal}"
          end
          # ローカル変数宣言
          cElement.set_local_var(hProcUnitInfo[:id], sVarName, sVarType, sVal)

          # ノンプリミティブなデータ型
          if (GROUP_TYP_NOPRIM.include?(sVarType))
            sParam += "&#{sVarName}, "
          # プリミティブなデータ型
          else
            sParam += "#{sVarName}, "
          end
        }
      }
      sParam.chop!().chop!()
      # 送信API生成
      sSyscall = "#{sSysType}#{sGroup}_#{sObjectID}#{sSendID}(#{sParam})"
      # puts sSyscall
      # 送信API呼び出しコード生成
      cElement.set_syscall(hProcUnitInfo, sSyscall, snbReturn, TYP_STD_RETURN)
    end
    private :ioc_send_write

    #=================================================================
    # 概  要: OS起動直後に終了/再起動状態となるOSAPのID一覧を返す
    #=================================================================
    def check_terminate_restart_osap()
      aOsapId = []

      @hAllObject.each{|sObjectID, cObjectInfo|
        if (GRP_PROCESS_UNIT_ALL.include?(cObjectInfo.sObjectType) &&
           (cObjectInfo.hState[TSR_PRM_OSAP] == TSR_STT_NT_OSAP_RESTARTING || cObjectInfo.hState[TSR_PRM_OSAP] == TSR_STT_NT_OSAP_TERMINATED))
          aOsapId.push(cObjectInfo.hState[TSR_PRM_OSAP])
          aOsapId = aOsapId.uniq()
        end
      }

      return aOsapId  # [Array]OS起動直後に終了/再起動状態となるOSAPID
    end
  end
end
