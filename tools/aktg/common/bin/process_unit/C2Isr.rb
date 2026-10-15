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
# 本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
# 
#  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
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
# $Id: C2Isr.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/process_unit/ProcessUnit.rb"
require "aktf/bin/process_unit/C2Isr.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: C2Isr
  # 概    要: カテゴリ2ISRの情報を処理するクラス
  #===================================================================
  class C2Isr < ProcessUnit
    #=================================================================
    # 概  要: カテゴリ2ISRの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_C2ISR, aPath, bIsPre)

    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      cElement.set_cfg_isr({XML_SNAME        => get_common_id(),
                            XML_P_I_CAT      => XML_ISR_TYPE_2,
                            XML_P_I_NUM      => @hState[TSR_PRM_INTNO],
                            XML_P_I_PRI      => @hState[TSR_PRM_INIINTPRI],
                            XML_P_I_SRC      => @hState[TSR_PRM_INTATR],
                            XML_P_I_RES      => @hState[TSR_PRM_RELRES],
                            XML_P_I_STKSZ    => @hState[TSR_PRM_ISTKSZ],
                            XML_P_I_ACC_APP  => @hState[TSR_PRM_ACCOSAP],
                            :osap            => @hState[TSR_PRM_OSAP],
                            :coreid          => @hState[TSR_PRM_COREID]})
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する
    #=================================================================
    def gc_obj_ref(cElement, hProcUnitInfo)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報

      # 状態参照を行うかチェック
      if (super() == false)
        return
      end

      # C1ISR/C2ISRの場合は共通関数IDとする
      if (GRP_PROCESS_UNIT_ISR.include?(@sObjectType))
        sObjectID = get_common_id()
      else
        sObjectID = @sObjectID
      end

      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO], TYP_AKTSP_ISR_INFO)

      # 割込み番号
      nIntno = @hState[TSR_PRM_INTNO]

      # 割込み属性
      sIntatr = @hState[TSR_PRM_INTATR]

      # 初期割込み優先度
      nIniIntpri = @hState[TSR_PRM_INIINTPRI]

      # 割込み要求禁止フラグ
      nIstat = @hState[TSR_PRM_ISTAT]

      # 処理単位動作状態
      if (@hState[TSR_PRM_STATE] == TSR_STT_ACTIVETE_WAITICISR)
        # ICISR起動待ちはOS上は実行状態
        sRtnstat = TSR_STT_ACTIVATE
      else
        sRtnstat = @hState[TSR_PRM_STATE]
      end

      # 獲得中リソース数
      nResnum = 0
      if (!@hState[TSR_PRM_GETRES].nil?())
        @hState[TSR_PRM_GETRES].each{|sResourceID|
          nResnum += 1
        }
      end
      if (!@hState[TSR_PRM_GETRESTFN].nil?())
        nResnum += @hState[TSR_PRM_GETRESTFN].size
      end
      nGetResCount = nResnum

      # 現在割込み優先度
      if (nGetResCount > 0)
        nCurIntpri = @hState[TSR_PRM_CURINTPRI]
      else
        nCurIntpri = "AKTSP_INVALID_SVALUE8"
      end

      # OSAP
      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      # スタック領域のサイズ
      sIstksz = @hState[TSR_PRM_ISTKSZ]

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_ISR}(&#{GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO]}, #{nIntno}, #{sIntatr}, #{nIniIntpri}, #{nCurIntpri}, #{nIstat}, #{sRtnstat}, #{nGetResCount}U, #{sOsap}, #{sIstksz})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO]})")


      # 関連づけされたリソース
      if (!@hState[TSR_PRM_RELRES].nil?())
        @hState[TSR_PRM_RELRES].each{|sResourceID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_REL_RES}(#{sObjectID}, #{sResourceID})")
        }
      end

      # 獲得済みリソース
      nIndex = 1
      if (!@hState[TSR_PRM_GETRES].nil?())
        @hState[TSR_PRM_GETRES].each{|sResourceID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_RES}(#{sObjectID}, (#{TYP_UINT32})#{nIndex}, #{sResourceID})")
          nIndex += 1
        }
      end
      # 信頼関数による獲得済みリソース
      if (!@hState[TSR_PRM_GETRESTFN].nil?())
        @hState[TSR_PRM_GETRESTFN].each{|sResourceID|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_RES}(#{sObjectID}, (#{TYP_UINT32})#{nIndex}, #{sResourceID})")
          nIndex += 1
        }
      end

      # アクセス可能な非信頼OSAP
      if (!@hState[TSR_PRM_ACCOSAP].nil?())
        @hState[TSR_PRM_ACCOSAP].each{|sAccosap|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_ACC_OSAP}(#{sObjectID}, #{sAccosap})")
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
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_SPN}(#{sObjectID}, i + #{nIndex}, #{sPrefixId}_SpinlockId[i])")
            cElement.unset_indent()
            cElement.set_code(hProcUnitInfo, "}", false)
            nIndex += nExNum
          else
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_SPN}(#{sObjectID}, #{nIndex}, #{sSpinlockID})")
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
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_SPN}(#{sObjectID}, i + #{nIndex}, #{sPrefixId}_SpinlockId[i])")
            cElement.unset_indent()
            cElement.set_code(hProcUnitInfo, "}", false)
            nIndex += nExNum
          else
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR_GET_SPN}(#{sObjectID}, #{nIndex}, #{sSpinlockID})")
            nIndex += 1
          end
        }
      end
    end
  end
end
