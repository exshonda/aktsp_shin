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
# $Id: Counter.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/sc_object/SCObject.rb"
require "aktf/bin/sc_object/Counter.rb"

#=====================================================================
# CommonModule
#=====================================================================
module CommonModule
  #===================================================================
  # クラス名: Counter
  # 概    要: カウンタの情報を処理するクラス
  #===================================================================
  class Counter < SCObject
    include CommonModule

    attr_accessor :hState, :sObjectID, :sObjectType

    #=================================================================
    # 概  要: カウンタの初期化
    #=================================================================
    def initialize(sObjectID, hObjectInfo, aPath, bIsPre)
      check_class(String, sObjectID)  # オブジェクトID
      check_class(Hash, hObjectInfo)  # オブジェクト情報
      check_class(Array, aPath)       # ルートからのパス
      check_class(Bool, bIsPre)       # pre_condition内か

      initialize_class(sObjectID, hObjectInfo, TSR_OBJ_COUNTER, aPath, bIsPre)

    end

    #=================================================================
    # 概  要: コンフィグファイルに出力するコード作成
    #=================================================================
    def gc_config(cElement)
      check_class(IMCodeElement, cElement) # エレメント

      cElement.set_cfg_cnt({XML_SNAME        => @sObjectID,
                            XML_P_C_MAX_VAL  => @hState[TSR_PRM_MAXVAL],
                            XML_P_C_MIN_CYC  => @hState[TSR_PRM_MINCYC],
                            XML_P_C_TIC_BASE => @hState[TSR_PRM_TICKSPERBASE],
                            XML_P_C_TYPE     => @hState[TSR_PRM_CTYPE],
                            XML_P_C_SEC_TICK => nil,  # ここではソフトウェアカウンタのみ生成するので不要
                            XML_P_C_ISR      => nil,  # ここではソフトウェアカウンタのみ生成するので不要
                            XML_P_C_ACC_APP  => @hState[TSR_PRM_ACCOSAP],
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

      hHwcntParam = @cConf.get_hardware_counter_param()

      # 状態確認API用構造体変数宣言
      cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_CNT_INFO], TYP_AKTSP_CNT_INFO)

      # 周期の最小値
      nMincyc = @hState[TSR_PRM_MINCYC]

      # カウンタの最大値
      nMaxval = @hState[TSR_PRM_MAXVAL]

      # カウンタの現在値
      nCurval = @hState[TSR_PRM_CURVAL]

      # カウンタのタイプ
      sCtype = @hState[TSR_PRM_CTYPE]

      # カウンタ固有の単位に達するまでに必要なティック数
      nTicksPerBase = @hState[TSR_PRM_TICKSPERBASE]

      # ハードウェアカウンタにおける1ティック当たりの実時間(秒)
      if (is_hardware_counter?())
        fSecondsPerTick = hHwcntParam[CFG_HWCNT_SECONDSPERTICK]
      else
        fSecondsPerTick = "AKTSP_INVALID_FVALUE"
      end

      # カウンタの状態
      if (!@hState[TSR_PRM_CSTAT].nil?())
        sCstat = @hState[TSR_PRM_CSTAT]
      else
        sCstat = "AKTSP_INVALID_VALUE8"
      end

      # OSAP
      if (@hState[TSR_PRM_OSAP].nil?())
        sOsap = "AKTSP_INVALID_VALUE8"
      else
        sOsap = @hState[TSR_PRM_OSAP]
      end

      # 構造体作成
      cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_CNT}(&#{GRP_VAR_TYPE[TYP_AKTSP_CNT_INFO]}, #{nMincyc}, #{nMaxval}, #{nCurval}, #{sCtype}, #{nTicksPerBase}, #{fSecondsPerTick}, #{sCstat}, #{sOsap})")
      # データを入れた構造体を状態確認APIへ渡す
      cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_CNT}(#{sObjectID}, &#{GRP_VAR_TYPE[TYP_AKTSP_CNT_INFO]})")

      # アクセス可能な非信頼OSAP
      if (!@hState[TSR_PRM_ACCOSAP].nil?())
        @hState[TSR_PRM_ACCOSAP].each{|sAccosap|
          cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_CNT_ACC_OSAP}(#{sObjectID}, #{sAccosap})")
        }
      end

      # ハードウェアカウンタに割付けるC2ISRの情報
      if (is_hardware_counter?())
        # 状態確認API用構造体変数宣言
        cElement.set_local_var(hProcUnitInfo[:id], GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO], TYP_AKTSP_ISR_INFO)

        # 割込み番号
        nIntno = hHwcntParam[CFG_HWCNT_INTNO]

        # 割込み属性
        sIntatr = hHwcntParam[CFG_HWCNT_INTATR]

        # 初期割込み優先度
        nIniIntpri = hHwcntParam[CFG_HWCNT_INIINTPRI]

        # 現在割込み優先度
        nCurIntpri = "AKTSP_INVALID_SVALUE8"

        # 割込み要求禁止フラグ
        nIstat = TSR_STT_ENABLE

        # 処理単位動作状態
        sRtnstat = TSR_STT_STP

        # 獲得中リソース数
        nGetResCount = 0

        # OSAP
        if (@hState[TSR_PRM_OSAP].nil?())
          sOsap = "AKTSP_INVALID_VALUE8"
        elsif ((@cConf.is_sc1?() || @cConf.is_sc2?()) && @cConf.is_multi?())
          sOsap = @hState[TSR_PRM_OSAP]
        else
          sOsap = hHwcntParam[CFG_HWCNT_OSAP]
        end

        # スタック領域のサイズ
        sIstksz = "AKTSP_INVALID_VALUE32"

        # 構造体作成
        cElement.set_code(hProcUnitInfo, "#{FNC_MAKE_STR_ISR}(&#{GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO]}, #{nIntno}, #{sIntatr}, #{nIniIntpri}, #{nCurIntpri}, #{nIstat}, #{sRtnstat}, #{nGetResCount}U, #{sOsap}, #{sIstksz})")
        # データを入れた構造体を状態確認APIへ渡す
        cElement.set_verify_api(hProcUnitInfo, "#{FNC_VERIFY_C2ISR}(#{AKTG_DUMMY_C2ISR}, &#{GRP_VAR_TYPE[TYP_AKTSP_ISR_INFO]})")
      end
    end

    #=================================================================
    # 概  要: ハードウェアカウンタかを返す
    #=================================================================
    def is_hardware_counter?()
      return  (@hState[TSR_PRM_CTYPE] == TSR_STT_HARDWARE)  # [Bool]ハードウェアカウンタか
    end
  end
end
