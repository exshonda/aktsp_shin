#!ruby -Ke
#
# AKTG
#      Automotive Kernel Test Generator
#
# Copyright (C) 2015-2016 by Center for Embedded Computing Systems
#             Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2015-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
# Copyright (C) 2015-2016 by eSOL Co.,Ltd., JAPAN
# Copyright (C) 2015-2016 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2015-2016 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2015-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2015-2016 by SCSK Corporation, JAPAN
# Copyright (C) 2015-2016 by Sunny Giken Inc., JAPAN
# Copyright (C) 2015-2016 by SUZUKI MOTOR CORPORATION
# Copyright (C) 2015-2016 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2015-2016 by Witz Corporation
# Copyright (C) 2015-2016 by Fujitsu TEN Limited
# Copyright (C) 2015-2016 by JTEKT CORPORATION
# 
# 本ソフトウェアは，車載制御システム向け高品質プラットフォームに
# 関するコンソーシアム型共同研究において開発したものである．
# 本ソフトウェアの著作権は，上記の著作権者に帰属する．
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
# $Id: SingleBuilder.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#
require "common/bin/CommonModule.rb"
require "bin/builder/ProfileBuilder.rb"

module AKTG

  #==================================================================
  # クラス名: SingleBuilder
  # 概    要: テストシナリオを用いて中間コードを生成するクラス
  #==================================================================
  class SingleBuilder < ProfileBuilder
    include CommonModule

    #================================================================
    # 概  要: コンストラクタ
    #================================================================
    def initialize()
      super()
    end

    #================================================================
    # 概  要: pre_conditionを生成するための中間コードを生成する
    #================================================================
    def build_pre_condition()
      # pre_conditionのハッシュを追加する
      @cIMCode.set_condition_level(TSR_LBL_PRE)

      # 共有関数からテストケース毎の関数を呼び出す
      @cIMCode.add_element(@cTS.gc_pre_call_each_func())

      # スタートアップ/シャットダウンフックからテストID開始メッセージ出力
      @cIMCode.add_element(@cTS.gc_pre_test_start_message())

      # 動作中のスケジュールテーブル設定
      @cIMCode.add_element(@cTS.gc_pre_set_start_schedule_table())

      # カウンタの設定
      @cIMCode.add_element(@cTS.gc_pre_increment_counter())

      # 切替え待ち状態のスケジュールテーブル設定
      @cIMCode.add_element(@cTS.gc_pre_set_next_schedule_table())

      # 動作中のアラーム設定
      @cIMCode.add_element(@cTS.gc_pre_set_alarm())

      # イベント待ちタスクの設定
      @cIMCode.add_element(@cTS.gc_pre_task_waiting())

      # 実行状態，実行可能状態のタスクの設定
      # (プレ/ポストタスクフック，信頼関数もここで設定する)
      @cIMCode.add_element(@cTS.gc_pre_task_running_ready())

      # タスク(信頼関数)による割込み禁止状態の設定
      @cIMCode.add_element(@cTS.gc_pre_interrupt(true))

      # pre_conditionで記述されたIOCの設定(構造体定義を含む)
      if (@cConf.enable_osap?())
        @cIMCode.add_element(@cTS.gc_pre_set_ioc())
      end

      # 起動状態のC2ISRの設定
      # (信頼関数もここで設定する)
      @cIMCode.add_element(@cTS.gc_pre_isr_activate(TSR_OBJ_C2ISR))

      # 起動状態のC1ISRの設定
      @cIMCode.add_element(@cTS.gc_pre_isr_activate(TSR_OBJ_C1ISR))

      # 起動状態のエラーフックの設定
      @cIMCode.add_element(@cTS.gc_pre_hook_activate(TSR_OBJ_ERROR_HOOK))

      # 起動状態のOSAP固有のエラーフックの設定
      if (@cConf.enable_osap?())
        @cIMCode.add_element(@cTS.gc_pre_hook_activate(TSR_OBJ_ERROR_HOOK_OSAP))
      end

      # 起動状態のプロテクションフックの設定
      @cIMCode.add_element(@cTS.gc_pre_hook_activate(TSR_OBJ_PROTECTION_HOOK))

      # 起動状態のOSAP固有のエラーフックの設定
      if (@cConf.enable_osap?())
        @cIMCode.add_element(@cTS.gc_pre_hook_activate(TSR_OBJ_SHUTDOWN_HOOK_OSAP))
      end

      # 起動状態のシャットダウンフックの設定
      @cIMCode.add_element(@cTS.gc_pre_hook_activate(TSR_OBJ_SHUTDOWN_HOOK))

      # タスク以外による割込み禁止状態の設定
      @cIMCode.add_element(@cTS.gc_pre_interrupt(false))

      # 許可状態の割込みの禁止設定(DisableInterruptSourceをサポートしている場合のみ:NOS)
      if (@cConf.is_target_spec_nos?())
        @cIMCode.add_element(@cTS.gc_pre_set_disable_int())
      end

      #
      # 前状態作成時点で，実行中の処理単位から
      # 全オブジェクトのrefコードを挿入
      #
      @cIMCode.add_element(@cTS.gc_obj_ref())
    end

    #================================================================
    # 概  要: do_conditionを生成するための中間コードを生成する
    #================================================================
    def build_do(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      # doのハッシュを追加する
      @cIMCode.set_condition_level(TSR_LBL_DO + "_#{@cTS.get_seqnum(nIndex)}")

      # 次のコンディションのフックの状態に合わせてbootcntを操作する
      @cIMCode.add_element(@cTS.gc_set_hook_bootcnt(nIndex))

      # doの処理
      if (@cTS.check_do_info(nIndex) == true)
        @cIMCode.add_element(@cTS.gc_do(nIndex))
      end

      # 次のコンディションで起動するACTIVATEなISRが存在する場合，起動を待つ
      @cIMCode.add_element(@cTS.gc_wait_isr_activate(nIndex))
    end

    #================================================================
    # 概  要: post_conditionの終了処理を生成するための中間コードを生成
    #         する
    #================================================================
    def build_lastpost_condition(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      # post_conditionのハッシュを追加する
      @cIMCode.set_condition_level(TSR_LBL_POST + "_#{@cTS.get_seqnum(nIndex)}")

      # 全オブジェクトのrefコードを返す
      @cIMCode.add_element(@cTS.gc_obj_ref(nIndex))

      # 各フックのbootcntをクリアする
      @cIMCode.add_element(@cTS.gc_lastpost_clear_hook_bootcnt())

      # 割込み禁止状態の解除
      @cIMCode.add_element(@cTS.gc_lastpost_interrupt())

      # 禁止状態の割込みの許可設定(EnableInterruptSourceをサポートしている場合のみ:NOS)
      if (@cConf.is_target_spec_nos?())
        @cIMCode.add_element(@cTS.gc_lastpost_set_enable_int())
      end

      # リソースを獲得している処理単位の解放処理
      @cIMCode.add_element(@cTS.gc_lastpost_release_resource())

      # 全タスクの最後にTerminateTaskを実行
      @cIMCode.add_element(@cTS.gc_lastpost_terminate_each_task())

      # 起動要求が2以上となっているタスクを終了させる
      # (NOSの場合，gc_lastpost_terminate_each_task内で行う)
      if (!@cConf.is_target_spec_nos?())
        @cIMCode.add_element(@cTS.gc_lastpost_terminate_queueing_task())
      end

      #
      # この時点でメインタスクが実行状態となっている
      #

      # イベント待ち状態となっているタスクを終了させる
      @cIMCode.add_element(@cTS.gc_lastpost_terminate_waiting_task())

      # スケジュールテーブルの停止
      @cIMCode.add_element(@cTS.gc_lastpost_stop_schedule_table())

      # 動作状態のアラームの停止
      @cIMCode.add_element(@cTS.gc_lastpost_stop_alarm())

      # スタートアップ/シャットダウンフックからテストID完了メッセージ出力
      @cIMCode.add_element(@cTS.gc_lastpost_test_end_message())

      # 1件のみのテストケースにおけるシャットダウンフック終了処理
      @cIMCode.add_element(@cTS.gc_lastpost_shutdown_hook_in_single_test())
    end


    #================================================================
    # 概  要: post_conditionを生成するための中間コードを生成する
    #================================================================
    def build_post_condition(nIndex)
      check_class(Integer, nIndex)  # do/postのシーケンス番号

      # post_conditionのハッシュを追加する
      @cIMCode.set_condition_level(TSR_LBL_POST + "_#{@cTS.get_seqnum(nIndex)}")

      # 全オブジェクトのrefコードを返す
      @cIMCode.add_element(@cTS.gc_obj_ref(nIndex))
    end
  end
end
