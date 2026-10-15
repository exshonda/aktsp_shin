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
# $Id: Task.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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
require "common/bin/process_unit/ProcessUnit.rb"
require "aktf/bin/process_unit/Task.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Task
  # 概    要: タスクの情報を処理するクラス
  #===================================================================
  class Task < ProcessUnit
    attr_accessor :nStackNum ,:bUnderPostTaskHook

    #=================================================================
    # 概  要: タスクの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre, hProperty)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か
      check_class(Hash, hProperty)    # プロパティ

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_TASK, aPath, bIsPre)

      @nStackNum = nil
      @bUnderPostTaskHook = false
      @hProperty = hProperty
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント
      cElement.set_cfg_tsk({XML_SNAME        => @sObjectID,
                            XML_P_T_ACT      => @hState[TSR_PRM_MAXACT],
                            XML_P_T_PRI      => @hState[TSR_PRM_INIPRI],
                            XML_P_T_SCHE     => @hState[TSR_PRM_SPOLICY],
                            XML_P_T_EVT      => @hState[TSR_PRM_RELEVT],
                            XML_P_T_RES      => @hState[TSR_PRM_RELRES],
                            XML_P_T_STKSZ    => @hState[TSR_PRM_STKSZ],
                            XML_P_T_STKADD   => @hState[TSR_PRM_STK],
                            XML_P_T_SSTKSZ   => @hState[TSR_PRM_SSTKSZ],
                            XML_P_T_SSTKADD  => @hState[TSR_PRM_SSTK],
                            XML_P_T_APP_MODE => @hState[TSR_PRM_APPMODE],
                            XML_P_T_ACC_APP  => @hState[TSR_PRM_ACCOSAP],
                            :osap            => @hState[TSR_PRM_OSAP],
                            :coreid          => @hState[TSR_PRM_COREID],
                            :restart         => false})
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref(cElement, hProcUnitInfo, aInternalResID, lKernelState, aTerminateOsap)
      check_class(IMCodeElement, cElement)  # エレメント
      check_class(Hash, hProcUnitInfo)      # 処理単位情報
      check_class(Array, aInternalResID)    # 内部リソースIDリスト
      check_class(Symbol, lKernelState)     # カーネル状態(スタートアップフック，シャットダウンフックの起動状態)
      check_class(Array, aTerminateOsap)    # 終了/再起動中のOSAP一覧

      # 状態参照を行うかチェック
      if (super() == false)
        return
      end

      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO], TYP_AKTSP_TSK_INFO)

      # ObjectIDの設定(タスク，リスタートタスク)
      if (sObjectType == TSR_OBJ_RESTART_TASK)
        sTaskId = get_common_id()
      else
        sTaskId = sObjectID
      end

      # タスク状態(カーネルの状態によって変更)
      case lKernelState
      when :KERNELBOOT
        if (@hState[TSR_PRM_STATE] == TSR_STT_RUNNING_WAITICISR)
          # ICISR起動待ちはOS上は実行状態
          sTstat = TSR_STT_RUNNING
        else
          # 通常の起動状態ならそのまま
          sTstat = @hState[TSR_PRM_STATE]
        end
      when :STARTUPHOOK, :STARTUPHOOK_OSAP
        # スタートアップフック起動中(カーネル起動前)
        case @hState[TSR_PRM_STATE]
        when TSR_STT_READY
          sTstat = TSR_STT_AUTO_START
        when TSR_STT_SUSPENDED
          sTstat = TSR_STT_NO_AUTO_START
        end
      when :SHUTDOWNHOOK, :SHUTDOWNHOOK_OSAP
        # シャットダウンフック起動中(カーネル終了後)
        case @hState[TSR_PRM_STATE]
        when TSR_STT_RUNNING, TSR_STT_RUNNING_WAITICISR
          sTstat = TSR_STT_END_RUNNING
        when TSR_STT_READY
          sTstat = TSR_STT_END_READY
        when TSR_STT_SUSPENDED
          sTstat = TSR_STT_END_SUSPENDED
        when TSR_STT_WAITING
          sTstat = TSR_STT_END_WAITING
        end
      end
      # 所属しているOSAPの状態によってタスクの状態を変更する
      if ((@cConf.is_sc3?() || @cConf.is_sc4?()) && !aTerminateOsap.nil?())
        if (aTerminateOsap.include?(@hState[TSR_PRM_OSAP]))
          case @hState[TSR_PRM_STATE]
          when TSR_STT_RUNNING, TSR_STT_RUNNING_WAITICISR
            sTstat = TSR_STT_END_OSAP_RUNNING
          when TSR_STT_READY
            sTstat = TSR_STT_END_OSAP_READY
          when TSR_STT_SUSPENDED
            sTstat = TSR_STT_END_OSAP_SUSPENDED
          when TSR_STT_WAITING
            sTstat = TSR_STT_END_OSAP_WAITING
          end
        end
      end

      # 初期優先度
      nInipri = @hState[TSR_PRM_INIPRI]

      # タスクタイプ
      sTtype = @hState[TSR_PRM_TTYPE]

      # 起動要求の最大数
      nMaxact = @hState[TSR_PRM_MAXACT]

      # スケジューリングポリシ
      sSpolicy = @hState[TSR_PRM_SPOLICY]

      # 起動要求数
      if ([TSR_STT_RUNNING, TSR_STT_READY, TSR_STT_RUNNING_WAITICISR].include?(@hState[TSR_PRM_STATE]))
        nActcnt = @hState[TSR_PRM_ACTCNT]
      else
        nActcnt = "AKTSP_INVALID_VALUE32"
      end

      # 現在優先度(タスクが休止状態の場合は参照しない)
      if (!@hState[TSR_PRM_CURPRI].nil?() && (@hState[TSR_PRM_STATE] != TSR_STT_SUSPENDED))
        nCurpri = @hState[TSR_PRM_CURPRI]
      else
        nCurpri = "AKTSP_INVALID_SVALUE8"
      end

      # イベントの現在値
      if ((!@hState[TSR_PRM_CUREVT].nil?()) && (@hState[TSR_PRM_CUREVT].is_a?(String)))
        sCurevt = @hState[TSR_PRM_CUREVT]
      elsif (@hState[TSR_PRM_CUREVT].is_a?(Integer))
        sCurevt = @hState[TSR_PRM_CUREVT].to_s() + "U"
      else
        sCurevt = "AKTSP_INVALID_VALUE32"
      end

      # 待ち対象イベント
      if (!@hState[TSR_PRM_WAIEVT].nil?())
        sWaievt = @hState[TSR_PRM_WAIEVT]
      elsif (!@hState[TSR_PRM_WAIEVTTFN].nil?())
        sWaievt = @hState[TSR_PRM_WAIEVTTFN]
      else
        sWaievt = "AKTSP_INVALID_VALUE32"
      end

      # レディキュー内順位(タスクが休止状態の場合は参照しない)
      if (!@hState[TSR_PRM_PORDER].nil?() && (@hState[TSR_PRM_STATE] == TSR_STT_READY))
        nPorder = @hState[TSR_PRM_PORDER]
      else
        nPorder = "AKTSP_INVALID_VALUE32"
      end

      # 内部リソースを除く，獲得中リソース数(タスクが休止状態，待ち状態の場合は参照しない)
      nResnum = 0
      if (!((@hState[TSR_PRM_STATE] == TSR_STT_SUSPENDED) || (@hState[TSR_PRM_STATE] == TSR_STT_WAITING)))
        if (!@hState[TSR_PRM_GETRES].nil?())
          @hState[TSR_PRM_GETRES].each{|sResourceID|
            # 内部リソース以外の場合
            if (!aInternalResID.include?(sResourceID))
              nResnum += 1
            end
          }
        end
        if (!@hState[TSR_PRM_GETRESTFN].nil?())
          nResnum += @hState[TSR_PRM_GETRESTFN].size
        end
        nGetResCount = nResnum
      else
        nGetResCount = "AKTSP_INVALID_VALUE32"
      end

      # OSAP
      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      # スタック領域のサイズ
      sStksz = @hState[TSR_PRM_STKSZ]

      # スタック領域の先頭番地
      sStk = @hState[TSR_PRM_STK]

      # システムスタック領域のサイズ
      sSstksz = @hState[TSR_PRM_SSTKSZ]

      # システムスタック領域の先頭番地
      sSstk = @hState[TSR_PRM_SSTK]

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_TSK}(&#{GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO]}, #{sTstat}, #{nCurpri}, #{nInipri}, #{sTtype}, #{nMaxact}, #{sSpolicy}, #{sWaievt}, #{sCurevt}, #{nActcnt}, #{nPorder}, #{nGetResCount}, #{sOsap}, #{sStksz}, #{sStk}, #{sSstksz}, #{sSstk})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK}(#{sTaskId}, &#{GRP_VAR_TYPE[TYP_AKTSP_TSK_INFO]})")


      # 関連づけされたリソース
      if (!@hState[TSR_PRM_RELRES].nil?())
        @hState[TSR_PRM_RELRES].each{|sResourceID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_REL_RES}(#{sTaskId}, #{sResourceID})")
        }
      end

      # 獲得済みリソース
      nIndex = 1
      if (!@hState[TSR_PRM_GETRES].nil?())
        @hState[TSR_PRM_GETRES].each{|sResourceID|
          # 内部リソースの場合
          if (aInternalResID.include?(sResourceID))
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_INT_RES}(#{sTaskId}, #{sResourceID})")
          # 内部リソース以外の場合
          else
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_RES}(#{sTaskId}, #{nIndex}, #{sResourceID})")
            nIndex += 1
          end
        }
      end
      # 信頼関数による獲得済みリソース
      if (!@hState[TSR_PRM_GETRESTFN].nil?())
        @hState[TSR_PRM_GETRESTFN].each{|sResourceID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_RES}(#{sTaskId}, #{nIndex}, #{sResourceID})")
          nIndex += 1
        }
      end


      # 関連づけされたイベント
      if (!@hState[TSR_PRM_RELEVT].nil?())
        @hState[TSR_PRM_RELEVT].each{|sEventID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_REL_EVT}(#{sTaskId}, #{sEventID})")
        }
      end

      # アクセス可能な非信頼OSAP
      if (!@hState[TSR_PRM_ACCOSAP].nil?())
        @hState[TSR_PRM_ACCOSAP].each{|sAccosap|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_ACC_OSAP}(#{sTaskId}, #{sAccosap})")
        }
      end

      # アプリケーションモード
      if (!@hState[TSR_PRM_APPMODE].nil?())
        @hState[TSR_PRM_APPMODE].each{|sAppMode|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_APP_MODE}(#{sTaskId}, #{sAppMode})")
        }
      end

      # 獲得済みスピンロック
      nIndex = 1
      if (!@hState[TSR_PRM_GETSPN].nil?())
        @hState[TSR_PRM_GETSPN].each{|sSpinlockID|
          # スピンロック個数拡張
          if (sSpinlockID =~ /\w+\/\d+-\d+\//)
            # 拡張する情報取得
            sPrefixId = sSpinlockID[/(\w+)\/\d+-\d+\//, 1]
            nStartId = sSpinlockID[/\w+\/(\d+)-\d+\//, 1].to_i()
            nEndId = sSpinlockID[/\w+\/\d+-(\d+)\//, 1].to_i()
            nExNum = nEndId - nStartId + 1

            # 拡張する数分のスピンロックを確認
            cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
            cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{nExNum}; i++) {", false)
            cElement.set_indent()
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_SPN}(#{sTaskId}, i + #{nIndex}, #{sPrefixId}_SpinlockId[i])")
            cElement.unset_indent()
            cElement.set_code(hProcUnitInfo, "}", false)
            nIndex += nExNum
          else
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_SPN}(#{sTaskId}, #{nIndex}, #{sSpinlockID})")
            nIndex += 1
          end
        }
      end
      # 信頼関数による獲得済みスピンロック
      if (!@hState[TSR_PRM_GETSPNTFN].nil?())
        @hState[TSR_PRM_GETSPNTFN].each{|sSpinlockID|
          # スピンロック個数拡張
          if (sSpinlockID =~ /\w+\/\d+-\d+\//)
            # 拡張する情報取得
            sPrefixId = sSpinlockID[/(\w+)\/\d+-\d+\//, 1]
            nStartId = sSpinlockID[/\w+\/(\d+)-\d+\//, 1].to_i()
            nEndId = sSpinlockID[/\w+\/\d+-(\d+)\//, 1].to_i()
            nExNum = nEndId - nStartId + 1

            # 拡張する数分のスピンロックを確認
            cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
            cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{nExNum}; i++) {", false)
            cElement.set_indent()
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_SPN}(#{sTaskId}, i + #{nIndex}, #{sPrefixId}_SpinlockId[i])")
            cElement.unset_indent()
            cElement.set_code(hProcUnitInfo, "}", false)
            nIndex += nExNum
          else
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_TSK_GET_SPN}(#{sTaskId}, #{nIndex}, #{sSpinlockID})")
            nIndex += 1
          end
        }
      end
    end
  end
end
