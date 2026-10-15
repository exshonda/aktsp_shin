#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2012-2013 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2012-2013 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2012-2013 by Spansion LLC, USA
# Copyright (C) 2012-2013 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2012-2013 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2012-2013 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2012-2013 by Sunny Giken Inc., JAPAN
# Copyright (C) 2012-2013 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2012-2013 by Witz Corporation, JAPAN
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
# $Id: Spinlock.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/sc_object/SCObject.rb"
require "aktf/bin/sc_object/Spinlock.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Spinlock
  # 概    要: スピンロックの情報を処理するクラス
  #===================================================================
  class Spinlock < SCObject
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType, :nExNum

    #=================================================================
    # 概  要: スピンロックの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_SPINLOCK, aPath, bIsPre)

      # スピンロック個数拡張
      if (sObjectID =~ /\w+\/\d+-\d+\//)
        # ID拡張文字列をパース
        # (エイリアス化前のため，ID自体は取得しない)
        @nStartId = sObjectID[/\w+\/(\d+)-\d+\//, 1].to_i()
        @nEndId = sObjectID[/\w+\/\d+-(\d+)\//, 1].to_i()
        @nExNum = @nEndId - @nStartId + 1

        # successorの指定拡張を確認
        @bSuccChk = false
        @nStartSucc = 0
        if (@hState[TSR_PRM_SUCCESSOR] =~ /\w+\/\d+-\d+\//)
          @bSuccChk = true
          @nStartSucc = @hState[TSR_PRM_SUCCESSOR][/\w+\/(\d+)-\d+\//, 1].to_i()
          @nEndSucc = @hState[TSR_PRM_SUCCESSOR][/\w+\/\d+-(\d+)\//, 1].to_i()
          # 拡張数が一致しない場合はエラー終了
          if ((@nEndId - @nStartId) != (@nEndSucc - @nStartSucc))
            abort(ERR_MSG % [__FILE__, __LINE__])
          end
        end
      end
    end

    #=================================================================
    # 概  要: テストシナリオのスピンロックのデータを@hStateに代入
    #=================================================================
    def store_object_info(hObjectInfo)
      check_class(Hash, hObjectInfo)  # オブジェクト情報

      # 格納
      set_specified_attribute(hObjectInfo)
      hObjectInfo.each{|atr, val|
        if (atr != TSR_PRM_TYPE)
          @hState[atr] = val
        end
      }
    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      # スピンロック個数拡張
      if (@sObjectID =~ /\w+\/\d+-\d+\//)
        sPrefixId = sObjectID[/(\w+)\/\d+-\d+\//, 1]

        # 拡張する数分のスピンロックを追加
        nCnt = @nStartSucc
        (@nStartId..@nEndId).each{|nId|
          sSuccessor = @hState[TSR_PRM_SUCCESSOR]
          if (@bSuccChk == true)
            # 拡張したサクセサはエイリアス化できないため，スピンロックのprefixを使用する
            sSuccessor = "#{sPrefixId}#{nCnt}"
            nCnt += 1
          end
          cElement.set_cfg_spn({XML_SNAME        => "#{sPrefixId}#{nId}",
                                XML_P_SP_ACC_APP => @hState[TSR_PRM_ACCOSAP],
                                XML_P_SP_SCCR    => sSuccessor,
                                XML_P_SP_SUS_INT => @hState[TSR_PRM_SUSINT],
                                :osap            => IMC_SPINLOCK_OSAP})
        }

        # ID格納用グローバル変数配列を生成
        sValue = "{"
        (@nStartId..@nEndId).each{|nId|
          sValue += "#{sPrefixId}#{nId},"
        }
        sValue.chop!()
        sValue += "}"
        cElement.set_global_var("#{sPrefixId}_SpinlockId[#{@nExNum}]", "const #{TYP_SPN}", sValue)
      else
        cElement.set_cfg_spn({XML_SNAME        => @sObjectID,
                              XML_P_SP_ACC_APP => @hState[TSR_PRM_ACCOSAP],
                              XML_P_SP_SCCR    => @hState[TSR_PRM_SUCCESSOR],
                              XML_P_SP_SUS_INT => @hState[TSR_PRM_SUSINT],
                              :osap            => IMC_SPINLOCK_OSAP})
      end
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

      # 状態確認API用構造体変数宣言
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_SPN_INFO], TYP_AKTSP_SPN_INFO)

      # 割込み禁止状態
      sSusInt = @hState[TSR_PRM_SUSINT]

      # スピンロックの状態
      sLockFlg = @hState[TSR_PRM_LOCKFLG]

      # 次に取得可能なスピンロック
      if (!@hState[TSR_PRM_SUCCESSOR].nil?())
        sSuccessor = @hState[TSR_PRM_SUCCESSOR]
      else
        sSuccessor = "AKTSP_INVALID_VALUE32"
      end

      # スピンロック個数拡張
      if (@sObjectID =~ /\w+\/\d+-\d+\//)
        sPrefixId = sObjectID[/(\w+)\/\d+-\d+\//, 1]

        # 拡張する数分のスピンロックを確認
        cElement.set_local_var(hProcUnitInfo[:id], "i", TYP_SINT32)
        cElement.set_code(hProcUnitInfo, "for (i = 0; i < #{@nExNum - 1}; i++) {", false)
        cElement.set_indent()
        if (@bSuccChk == true)
          sSuccessor = "#{sPrefixId}_SpinlockId[i + 1]"
        end
        gc_obj_ref_local(cElement, hProcUnitInfo, "#{sPrefixId}_SpinlockId[i]", sSusInt, sLockFlg, sSuccessor, @hState[TSR_PRM_ACCOSAP])
        cElement.unset_indent()
        cElement.set_code(hProcUnitInfo, "}", false)
      else
        gc_obj_ref_local(cElement, hProcUnitInfo, @sObjectID, sSusInt, sLockFlg, sSuccessor, @hState[TSR_PRM_ACCOSAP])
      end
    end

    #=================================================================
    # 概  要: 状態参照処理をcElementに追加する(ローカル処理)
    #=================================================================
    def gc_obj_ref_local(cElement, hProcUnitInfo, sObjectID, sSusInt, sLockFlg, sSuccessor, aAccosap)
      check_class(IMCodeElement, cElement) # エレメント
      check_class(Hash, hProcUnitInfo)     # 処理単位情報
      check_class(String, sObjectID)       # スピンロックID
      check_class(String, sSusInt)         # 割込み禁止状態
      check_class(String, sLockFlg)        # スピンロックの状態
      check_class(String, sSuccessor)      # 次に取得可能なスピンロック
      check_class(Array, aAccosap, true)   # アクセス可能な非信頼OSAP

      # 状態確認API用構造体変数宣言
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_SPN_INFO], TYP_AKTSP_SPN_INFO)

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_SPN}(&#{GRP_VAR_TYPE[TYP_AKTSP_SPN_INFO]}, #{sSusInt}, #{sSuccessor}, #{sLockFlg})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SPN}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_SPN_INFO]})")

      # アクセス可能な非信頼OSAP
      if (!aAccosap.nil?())
        aAccosap.each{|sAccosap|
          # スピンロックのaccosapには，信頼OSAP/非信頼OSAPが設定されているため，非信頼OSAPの場合のみ状態参照を行う
          if (sAccosap.include?(AKTG_JUDGE_NON_TRUSTED) || sAccosap.include?(AKTG_JUDGE_MC_NON_TRUSTED))
            cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_SPN_ACC_OSAP}(#{sObjectID}, #{sAccosap})")
          end
        }
      end
    end
    private :gc_obj_ref_local
  end
end
