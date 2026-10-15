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
# $Id: test_data.rb 347 2014-09-17 00:28:35Z fsi-dankei $

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

# AKTGおよびAKTFのマクロが要るためCommonをインクルードする必要がある
require "common/bin/CommonModule.rb"

module ErrorCheckModule
  include CommonModule

  #=====================================================================
  # TTC Error-checkerの共通マクロ
  #=====================================================================
  AKTSP_PATH = File.expand_path(File.dirname(__FILE__) + "/../../../../../")
  TESRY_PATH = File.expand_path(File.dirname(__FILE__) + "/../../../../../../")
  AKTG_PATH  = AKTSP_PATH + "/tools/aktg/bin/aktg.rb"

  # ファイル生成時の情報を持つファイル名
  MAKE_FILE_LIST   = "make_file_list.txt"
  DO_NOT_ATTRIBUTE = "do_not_attribute.txt"

  # configure名
  CONFIGURE_FILE = "configure"

  # フォルダ名
  FDR_T0 = "T0"
  FDR_T1 = "T1"
  FDR_T2 = "T2"
  FDR_T3 = "T3"
  FDR_T4 = "T4"
  FDR_T5 = "T5"
  FDR_T6 = "T6"
  FDR_T7 = "T7"

  FDR_T0_001 = "T0/T0_001"
  FDR_T0_002 = "T0/T0_002"
  FDR_T0_003 = "T0/T0_003"
  FDR_T0_004 = "T0/T0_004"
  FDR_T0_005 = "T0/T0_005"
  FDR_T0_006 = "T0/T0_006"
  FDR_T0_007 = "T0/T0_007"
  FDR_T0_008 = "T0/T0_008"
  FDR_T0_009 = "T0/T0_009"
  FDR_T0_010 = "T0/T0_010"
  FDR_T0_011 = "T0/T0_011"
  FDR_T0_012 = "T0/T0_012"
  FDR_T0_013 = "T0/T0_013"
  FDR_T0_014 = "T0/T0_014"
  FDR_T0_015 = "T0/T0_015"

  FDR_T0_SC3_001 = "T0/T0_SC3_001"

  FDR_T2_001 = "T2/T2_001"
  FDR_T2_002 = "T2/T2_002"
  FDR_T2_003 = "T2/T2_003"

  FDR_T6_001 = "T6/T6_001"
  FDR_T6_004 = "T6/T6_004"
  FDR_T6_005 = "T6/T6_005"
  FDR_T6_006 = "T6/T6_006"
  FDR_T6_SC1_MC_001 = "T6/T6_SC1_MC_001"

  # 削除可能なフォルダ
  DEL_FOLDER_LIST = [
    FDR_T0,
    FDR_T2,
    FDR_T6
  ]

  # configureファイルが保存されているフォルダ
  FDR_CONFIGURE_FILE = [
    FDR_T5,
    FDR_T7
  ]

  #=====================================================================
  # T0: environmentのマクロ
  #=====================================================================
  # パス
  ANY_T0_TESRY_SC1  = TESRY_PATH + "/sample_tesry/merge/sc1/Task/Task_0001.yaml"
  ANY_T0_TESRY_SC3  = TESRY_PATH + "/sample_tesry/merge/sc3/Task/Task_0001.yaml"
  ANY_CONFIGURE     = AKTSP_PATH + "/tools/aktg/bin/configure.yaml"

  # ANY VALUE
  ANY_ZERO       = 0
  ANY_PLUS       = 123
  ANY_MINUS      = -123
  ANY_REAL       = 1.23
  ANY_REAL_0     = 0.0
  ANY_STRING     = "string"
  ANY_VALUE_HASH = [{"key" => "val"}]
  ANY_MAX_TASK_PRI = 16
  ANY_TRUSTED_OSAP = TSR_STT_TRUSTED_OSAP1
  ANY_MULTI_CORE_NUM = 2

  # マクロの置換
  CVT_CONFIGURE_VALUE = {
    # configure
    String     => "string",
    Integer    => 0,
    Float      => 1.0,
    Hash       => {"key" => "val"},
    Array      => ["array"],
    TrueClass  => true,
    FalseClass => false,

    # macro
    ANY_ZERO   => ANY_ZERO,
    ANY_PLUS   => ANY_PLUS,
    ANY_MINUS  => ANY_MINUS,
    ANY_REAL   => ANY_REAL,
    ANY_REAL_0 => ANY_REAL_0,
    ANY_STRING => ANY_STRING,
    ANY_MAX_TASK_PRI => ANY_MAX_TASK_PRI,
    ANY_TRUSTED_OSAP => ANY_TRUSTED_OSAP,

    # intno
    "AKTSP_INTNO_A" => "AKTSP_INTNO_A",
    "AKTSP_INTNO_B" => "AKTSP_INTNO_B",
    "AKTSP_INTNO_C" => "AKTSP_INTNO_C",
    "AKTSP_INTNO_D" => "AKTSP_INTNO_D",
    "AKTSP_INTNO_E" => "AKTSP_INTNO_E",
    "AKTSP_INTNO_F" => "AKTSP_INTNO_F",
    "AKTSP_INTNO_G" => "AKTSP_INTNO_G",
    "AKTSP_INTNO_H" => "AKTSP_INTNO_H",
    "AKTSP_INTNO_I" => "AKTSP_INTNO_I",
    "AKTSP_INTNO_J" => "AKTSP_INTNO_J",

    # intatr
    "AK_DISABLE" => "AK_DISABLE",

    # 2以上の整数
    ANY_MULTI_CORE_NUM => ANY_MULTI_CORE_NUM,

    # return_status
    "STANDARD" => "STANDARD",

    # level
    "Level2" => "Level2",
    "Level3" => "Level3",

    # version
    "0.0.0"  => "0.0.0"
  }

  # ファイル変換名
  CVT_CONFIGURE_NAME = {
    # configure
    String     => "string",
    Integer    => "number",
    Float      => "float",
    Hash       => "hash",
    Array      => "array",
    TrueClass  => "true",
    FalseClass => "false",

    # macro
    ANY_ZERO   => "zero",
    ANY_PLUS   => "plus",
    ANY_MINUS  => "minus",
    ANY_REAL   => "realnum",
    ANY_REAL_0 => "zero_realnum",
    ANY_STRING => "string",
    ANY_MAX_TASK_PRI => "max_task_pri",
    ANY_TRUSTED_OSAP => "trusted_osap",

    # intno
    "AKTSP_INTNO_A" => "AKTSP_INTNO_A",
    "AKTSP_INTNO_B" => "AKTSP_INTNO_B",
    "AKTSP_INTNO_C" => "AKTSP_INTNO_C",
    "AKTSP_INTNO_D" => "AKTSP_INTNO_D",
    "AKTSP_INTNO_E" => "AKTSP_INTNO_E",
    "AKTSP_INTNO_F" => "AKTSP_INTNO_F",
    "AKTSP_INTNO_G" => "AKTSP_INTNO_G",
    "AKTSP_INTNO_H" => "AKTSP_INTNO_H",
    "AKTSP_INTNO_I" => "AKTSP_INTNO_I",
    "AKTSP_INTNO_J" => "AKTSP_INTNO_J",

    # intatr
    "AK_DISABLE" => "AK_DISABLE",

    # 2以上の整数
    ANY_MULTI_CORE_NUM => ANY_MULTI_CORE_NUM,

    # return_status
    "STANDARD" => "standard",

    # level
    "Level2" => "Level2",
    "Level3" => "Level3",

    # version
    "0.0.0"  => "0.0.0"
  }

  # configureに規定されていない項目検査
  ERROR_CONFIGURE_ENTRY = {
    "core_num_error" => 1
  }

=begin
  # configureに指定されていない属性検査
  ERROR_ATTRIBUTE = {
    "error_attribute" => "T0_001"
  }
=end

  # タスク優先度の不具合
  TASTPRI_TOP_HIGH = {
    "TSK_PRI_TOP"    => 11,
    "TSK_PRI_HIGH"   => 12,
    "TSK_PRI_MID"    => 10,
    "TSK_PRI_LOW"    => 9,
    "TSK_PRI_BOTTOM" => 8
  }

  TASTPRI_HIGH_MID = {
    "TSK_PRI_TOP"    => 12,
    "TSK_PRI_HIGH"   => 10,
    "TSK_PRI_MID"    => 11,
    "TSK_PRI_LOW"    => 9,
    "TSK_PRI_BOTTOM" => 8
  }

  TASTPRI_MID_LOW = {
    "TSK_PRI_TOP"    => 12,
    "TSK_PRI_HIGH"   => 11,
    "TSK_PRI_MID"    => 9,
    "TSK_PRI_LOW"    => 10,
    "TSK_PRI_BOTTOM" => 8
  }

  TASTPRI_LOW_BOTTOM = {
    "TSK_PRI_TOP"    => 12,
    "TSK_PRI_HIGH"   => 11,
    "TSK_PRI_MID"    => 10,
    "TSK_PRI_LOW"    => 8,
    "TSK_PRI_BOTTOM" => 9
  }

  TASTPRI_BOTTOM = {
    "TSK_PRI_TOP"    => 12,
    "TSK_PRI_HIGH"   => 11,
    "TSK_PRI_MID"    => 10,
    "TSK_PRI_LOW"    => 8,
    "TSK_PRI_BOTTOM" => 8
  }

  # 割込み優先度の不具合
  INTPRI_ISR1_HIGH_MID = {
    "INT_PRI_ISR1_HIGH" => 7,
    "INT_PRI_ISR1_MID"  => 8,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 2,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_ISR1_MID_LOW = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 6,
    "INT_PRI_ISR1_LOW"  => 7,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 2,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_ISR1_LOW_TOP = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 5,
    "INT_PRI_TOP"       => 6,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 2,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_TOP_HIGH = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 4,
    "INT_PRI_HIGH"      => 5,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 2,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_HIGH_MID = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 3,
    "INT_PRI_MID"       => 4,
    "INT_PRI_LOW"       => 2,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_MID_LOW = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 2,
    "INT_PRI_LOW"       => 3,
    "INT_PRI_BOTTOM"    => 1
  }

  INTPRI_LOW_BOTTOM = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 1,
    "INT_PRI_BOTTOM"    => 2
  }

  INTPRI_BOTTOM = {
    "INT_PRI_ISR1_HIGH" => 8,
    "INT_PRI_ISR1_MID"  => 7,
    "INT_PRI_ISR1_LOW"  => 6,
    "INT_PRI_TOP"       => 5,
    "INT_PRI_HIGH"      => 4,
    "INT_PRI_MID"       => 3,
    "INT_PRI_LOW"       => 1,
    "INT_PRI_BOTTOM"    => 1
  }

  # 満了するティックの絶対値の不具合
  ALMVAL_A_HIGH = {
    "ANY_ALMVAL_A" => 11
  }
  ALMVAL_B_HIGH = {
    "ANY_ALMVAL_B" => 51
  }
  ALMVAL_C_HIGH = {
    "ANY_ALMVAL_C" => 101
  }

  # アラーム満了周期の不具合
  ALMCYCLE_A_LOW = {
    "ANY_ALMCYCLE_A" => 0
  }
  ALMCYCLE_B_LOW = {
    "ANY_ALMCYCLE_B" => 2
  }
  ALMCYCLE_C_LOW = {
    "ANY_ALMCYCLE_C" => 4
  }
  ALMCYCLE_A_HIGH = {
    "ANY_ALMCYCLE_A" => 11
  }
  ALMCYCLE_B_HIGH = {
    "ANY_ALMCYCLE_B" => 51
  }
  ALMCYCLE_C_HIGH = {
    "ANY_ALMCYCLE_C" => 101
  }

  # 周期の最小値
  MINCYC_A_HIGH = {
    "ANY_MINCYC_A" => 11
  }
  MINCYC_B_HIGH = {
    "ANY_MINCYC_B" => 51
  }
  MINCYC_C_HIGH = {
    "ANY_MINCYC_C" => 101
  }

  # カウンタの現在値の不具合
  CURVAL_A_HIGH = {
    "ANY_CURVAL_A" => 11
  }
  CURVAL_B_HIGH = {
    "ANY_CURVAL_B" => 51
  }
  CURVAL_C_HIGH = {
    "ANY_CURVAL_C" => 101
  }

  # カウンタの現在値(0以外の値)の不具合
  CURVAL_NOT_0_A_HIGH = {
    "ANY_CURVAL_NOT_0_A" => 11
  }
  CURVAL_NOT_0_B_HIGH = {
    "ANY_CURVAL_NOT_0_B" => 51
  }
  CURVAL_NOT_0_C_HIGH = {
    "ANY_CURVAL_NOT_0_C" => 101
  }

  # カウンタの現在値(MAX以外の値)の不具合
  CURVAL_NOT_MAX_A_HIGH = {
    "ANY_CURVAL_NOT_MAX_A" => 11
  }
  CURVAL_NOT_MAX_B_HIGH = {
    "ANY_CURVAL_NOT_MAX_B" => 51
  }
  CURVAL_NOT_MAX_C_HIGH = {
    "ANY_CURVAL_NOT_MAX_C" => 101
  }

  # カウンタの現在値(0,MAX以外の値)の不具合
  CURVAL_NOT_0_MAX_A_HIGH = {
    "ANY_CURVAL_NOT_0_MAX_A" => 11
  }
  CURVAL_NOT_0_MAX_B_HIGH = {
    "ANY_CURVAL_NOT_0_MAX_B" => 51
  }
  CURVAL_NOT_0_MAX_C_HIGH = {
    "ANY_CURVAL_NOT_0_MAX_C" => 101
  }

  # ラップアラウンドするアラーム系の検査で使用するカウンタの値の不具合
  WRAPAROUND_MAX_CURVAL_A = {
     "ANY_CURVAL_WRAPAROUND_A" => 2
  }
  WRAPAROUND_MAX_CURVAL_B = {
     "ANY_CURVAL_WRAPAROUND_B" => 4
  }
  WRAPAROUND_MAX_CURVAL_C = {
     "ANY_CURVAL_WRAPAROUND_C" => 6
  }

  # ラップアラウンドしないアラーム系の検査で使用するカウンタの値の不具合
  WRAPAROUND_NOT_MAX_CURVAL_A = {
     "ANY_CURVAL_NOT_WRAPAROUND_A" => 0
  }
  WRAPAROUND_NOT_MAX_CURVAL_B = {
     "ANY_CURVAL_NOT_WRAPAROUND_B" => 3
  }
  WRAPAROUND_NOT_MAX_CURVAL_C = {
     "ANY_CURVAL_NOT_WRAPAROUND_C" => 5
  }

  # アラーム満了までのティックの相対値の不正な値の不具合
  INCREMENT_GREATER_THAN_MAXVAL_A = {
     "INVALID_INCREMENT_GREATER_THAN_MAXVAL_A" => 9
  }
  INCREMENT_GREATER_THAN_MAXVAL_B = {
     "INVALID_INCREMENT_GREATER_THAN_MAXVAL_B" => 49
  }
  INCREMENT_GREATER_THAN_MAXVAL_C = {
     "INVALID_INCREMENT_GREATER_THAN_MAXVAL_C" => 99
  }

  # アラーム満了までのティックの絶対値の不正な値
  START_GREATER_THAN_MAXVAL_A = {
     "INVALID_START_GREATER_THAN_MAXVAL_A" => 9
  }
  START_GREATER_THAN_MAXVAL_B = {
     "INVALID_START_GREATER_THAN_MAXVAL_B" => 49
  }
  START_GREATER_THAN_MAXVAL_C = {
     "INVALID_START_GREATER_THAN_MAXVAL_C" => 99
  }

  # アラーム満了周期の不正な値の不具合
  CYCLE_GREATER_THAN_MAXVAL_A = {
     "INVALID_CYCLE_GREATER_THAN_MAXVAL_A" => 9
  }
  CYCLE_GREATER_THAN_MAXVAL_B = {
     "INVALID_CYCLE_GREATER_THAN_MAXVAL_B" => 49
  }
  CYCLE_GREATER_THAN_MAXVAL_C = {
     "INVALID_CYCLE_GREATER_THAN_MAXVAL_C" => 99
  }

  # アラーム満了周期の不正な値の不具合
  CYCLE_LOWER_THAN_MINCYCL_A = {
     "INVALID_CYCLE_LOWER_THAN_MINCYCL_A" => 3
  }
  CYCLE_LOWER_THAN_MINCYCL_B = {
     "INVALID_CYCLE_LOWER_THAN_MINCYCL_B" => 5
  }
  CYCLE_LOWER_THAN_MINCYCL_C = {
     "INVALID_CYCLE_LOWER_THAN_MINCYCL_C" => 7
  }

  # 基本タスクの任意の起動要求数(2以上,MAX未満)の不具合
  ACTCNT_LOWER_THAN_BASIC_MAXACT = {
     "ANY_ACTCNT_NOT_MAX_1" => 1
  }

  # ハードウェアカウンタ 周期の最小値の不具合
  HARDWARE_COUNTER_MIMCYC_GREATER_THAN_MAXVAL = {
     "mincyc" => 200
  }

  # スケジュールテーブル周期(スケジュールテーブルのシステムサービステスト用)
  SCDLTBL_DURATION_A_LESS_MINCYC = {
    "ANY_SCDLTBL_DURATION_A" => 2
  }
  SCDLTBL_DURATION_B_LESS_MINCYC = {
    "ANY_SCDLTBL_DURATION_B" => 4
  }
  SCDLTBL_DURATION_C_LESS_MINCYC = {
    "ANY_SCDLTBL_DURATION_C" => 6
  }
  SCDLTBL_DURATION_A_MORE_MAXVAL = {
    "ANY_SCDLTBL_DURATION_A" => 11
  }
  SCDLTBL_DURATION_B_MORE_MAXVAL = {
    "ANY_SCDLTBL_DURATION_B" => 51
  }
  SCDLTBL_DURATION_C_MORE_MAXVAL = {
    "ANY_SCDLTBL_DURATION_C" => 101
  }

  # スケジュールテーブル初期オフセット(最終オフセットを兼ねる)(任意の値)
  SCDLTBL_INIT_OFFSET_A_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_A" => 1
  }
  SCDLTBL_INIT_OFFSET_B_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_B" => 3
  }
  SCDLTBL_INIT_OFFSET_C_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_C" => 5
  }
  SCDLTBL_INIT_OFFSET_A_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_A" => 4
  }
  SCDLTBL_INIT_OFFSET_B_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_B" => 6
  }
  SCDLTBL_INIT_OFFSET_C_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_C" => 9
  }

  # スケジュールテーブル初期オフセット(最終オフセットを兼ねる)(0以外の値)
  SCDLTBL_INIT_OFFSET_NOT_0_A_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A" => 1
  }
  SCDLTBL_INIT_OFFSET_NOT_0_B_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_B" => 3
  }
  SCDLTBL_INIT_OFFSET_NOT_0_C_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_C" => 5
  }
  SCDLTBL_INIT_OFFSET_NOT_0_A_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A" => 4
  }
  SCDLTBL_INIT_OFFSET_NOT_0_B_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_B" => 6
  }
  SCDLTBL_INIT_OFFSET_NOT_0_C_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_C" => 9
  }

  # スケジュールテーブル初期オフセット(最終オフセットを兼ねる)(中間値用)
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A" => 1
  }
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_B" => 3
  }
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_LESS_MINCYC = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_C" => 5
  }
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A" => 3
  }
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_B" => 5
  }
  SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_MORE_DIFFERENTIAL_VALUE = {
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_C" => 8
  }

  # スケジュールテーブル初期オフセット(0以外の値)
  SCDLTBL_OFFSET_A_LESS_MINCYC = {
    "ANY_SCDLTBL_OFFSET_NOT_0_A" => 1
  }
  SCDLTBL_OFFSET_B_LESS_MINCYC = {
    "ANY_SCDLTBL_OFFSET_NOT_0_B" => 3
  }
  SCDLTBL_OFFSET_C_LESS_MINCYC = {
    "ANY_SCDLTBL_OFFSET_NOT_0_C" => 5
  }
  SCDLTBL_OFFSET_A_MORE_MAXVAL = {
    "ANY_SCDLTBL_OFFSET_NOT_0_A" => 11
  }
  SCDLTBL_OFFSET_B_MORE_MAXVAL = {
    "ANY_SCDLTBL_OFFSET_NOT_0_B" => 51
  }
  SCDLTBL_OFFSET_C_MORE_MAXVAL = {
    "ANY_SCDLTBL_OFFSET_NOT_0_C" => 101
  }

  # StartScheduleTableRel()の引数に指定するスケジュールテーブル開始オフセット
  STARTSCDLTBLREL_OFFSET_LESS_1 = {
    "ANY_PARAM_OFFSET_STARTSCDLTBLREL" => 1
  }
  STARTSCDLTBLREL_OFFSET_MORE_MAXVAL = {
    "ANY_PARAM_OFFSET_STARTSCDLTBLREL" => 10
  }

  # StartScheduleTableRel()で使用するスケジュールテーブル開始前時刻
  STARTSCDLTBLREL_CURVAL_MORE_NOT_WRAPAROUND = {
   "ANY_CURVAL_STARTSCDLTBLREL" => 8
  }

  # StartScheduleTableRel()で使用するスケジュールテーブル開始時刻(カウンタラップアラウンドあり)
  STARTSCDLTBLREL_WRAPAROUND_MORE_MAX = {
    "ANY_CURVAL_STARTSCDLTBLREL_WRAPAROUND" => 3
  }

  # StartScheduleTableRel()の引数に指定するスケジュールテーブル開始オフセット(カウンタラップアラウンドなし)
  STARTSCDLTBLREL_NOT_WRAPAROUND_LESS_CURVAL_STARTSCDLTBLREL = {
    "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND" => 6
  }
  STARTSCDLTBLREL_NOT_WRAPAROUND_MORE_MAXVAL = {
    "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND" => 11
  }

  # 依存性のマクロのファイル名
  CVT_DEPEND_NAME = {
    "tastpri_top_high"                 => TASTPRI_TOP_HIGH,
    "tastpri_high_mid"                 => TASTPRI_HIGH_MID,
    "tastpri_mid_low"                  => TASTPRI_MID_LOW,
    "tastpri_low_bottom"               => TASTPRI_LOW_BOTTOM,
    "tastpri_bottom"                   => TASTPRI_BOTTOM,
    "intpri_isr1_high_mid"             => INTPRI_ISR1_HIGH_MID,
    "intpri_isr1_mid_low"              => INTPRI_ISR1_MID_LOW,
    "intpri_isr1_low_top"              => INTPRI_ISR1_LOW_TOP,
    "intpri_top_high"                  => INTPRI_TOP_HIGH,
    "intpri_high_mid"                  => INTPRI_HIGH_MID,
    "intpri_mid_low"                   => INTPRI_MID_LOW,
    "intpri_low_bottom"                => INTPRI_LOW_BOTTOM,
    "intpri_bottom"                    => INTPRI_BOTTOM,
    "almval_A_high"                    => ALMVAL_A_HIGH,
    "almval_B_high"                    => ALMVAL_B_HIGH,
    "almval_C_high"                    => ALMVAL_C_HIGH,
    "almcycle_A_high"                  => ALMCYCLE_A_HIGH,
    "almcycle_B_high"                  => ALMCYCLE_B_HIGH,
    "almcycle_C_high"                  => ALMCYCLE_C_HIGH,
    "almcycle_A_low"                   => ALMCYCLE_A_LOW,
    "almcycle_B_low"                   => ALMCYCLE_B_LOW,
    "almcycle_C_low"                   => ALMCYCLE_C_LOW,
    "mincyc_A_high"                    => MINCYC_A_HIGH,
    "mincyc_B_high"                    => MINCYC_B_HIGH,
    "mincyc_C_high"                    => MINCYC_C_HIGH,
    "curval_A_high"                    => CURVAL_A_HIGH,
    "curval_B_high"                    => CURVAL_B_HIGH,
    "curval_C_high"                    => CURVAL_C_HIGH,
    "curval_not_0_A_high"              => CURVAL_NOT_0_A_HIGH,
    "curval_not_0_B_high"              => CURVAL_NOT_0_B_HIGH,
    "curval_not_0_C_high"              => CURVAL_NOT_0_C_HIGH,
    "curval_not_max_A_high"            => CURVAL_NOT_MAX_A_HIGH,
    "curval_not_max_B_high"            => CURVAL_NOT_MAX_B_HIGH,
    "curval_not_max_C_high"            => CURVAL_NOT_MAX_C_HIGH,
    "curval_not_0_max_A_high"          => CURVAL_NOT_0_MAX_A_HIGH,
    "curval_not_0_max_B_high"          => CURVAL_NOT_0_MAX_B_HIGH,
    "curval_not_0_max_C_high"          => CURVAL_NOT_0_MAX_C_HIGH,
    "wraparound_max_curval_A"          => WRAPAROUND_MAX_CURVAL_A,
    "wraparound_max_curval_B"          => WRAPAROUND_MAX_CURVAL_B,
    "wraparound_max_curval_C"          => WRAPAROUND_MAX_CURVAL_C,
    "wraparound_not_max_curval_A"      => WRAPAROUND_NOT_MAX_CURVAL_A,
    "wraparound_not_max_curval_B"      => WRAPAROUND_NOT_MAX_CURVAL_B,
    "wraparound_not_max_curval_C"      => WRAPAROUND_NOT_MAX_CURVAL_C,
    "Increment_greater_than_maxval_A"  => INCREMENT_GREATER_THAN_MAXVAL_A,
    "Increment_greater_than_maxval_B"  => INCREMENT_GREATER_THAN_MAXVAL_B,
    "Increment_greater_than_maxval_C"  => INCREMENT_GREATER_THAN_MAXVAL_C,
    "start_greater_than_maxval_A"      => START_GREATER_THAN_MAXVAL_A,
    "start_greater_than_maxval_B"      => START_GREATER_THAN_MAXVAL_B,
    "start_greater_than_maxval_C"      => START_GREATER_THAN_MAXVAL_C,
    "cycle_greater_than_maxval_A"      => CYCLE_GREATER_THAN_MAXVAL_A,
    "cycle_greater_than_maxval_B"      => CYCLE_GREATER_THAN_MAXVAL_B,
    "cycle_greater_than_maxval_C"      => CYCLE_GREATER_THAN_MAXVAL_C,
    "cycle_lower_than_mincycl_A"       => CYCLE_LOWER_THAN_MINCYCL_A,
    "cycle_lower_than_mincycl_B"       => CYCLE_LOWER_THAN_MINCYCL_B,
    "cycle_lower_than_mincycl_C"       => CYCLE_LOWER_THAN_MINCYCL_C,
    "actcnt_lower_than_basic_maxact"   => ACTCNT_LOWER_THAN_BASIC_MAXACT,
    "hwcnt_mincyc_greater_than_maxval" => HARDWARE_COUNTER_MIMCYC_GREATER_THAN_MAXVAL,
    "scdltbl_duration_a_less_mincyc"                             => SCDLTBL_DURATION_A_LESS_MINCYC,
    "scdltbl_duration_b_less_mincyc"                             => SCDLTBL_DURATION_B_LESS_MINCYC,
    "scdltbl_duration_c_less_mincyc"                             => SCDLTBL_DURATION_C_LESS_MINCYC,
    "scdltbl_duration_a_more_maxval"                             => SCDLTBL_DURATION_A_MORE_MAXVAL,
    "scdltbl_duration_b_more_maxval"                             => SCDLTBL_DURATION_B_MORE_MAXVAL,
    "scdltbl_duration_c_more_maxval"                             => SCDLTBL_DURATION_C_MORE_MAXVAL,
    "scdltbl_init_offset_a_less_mincyc"                          => SCDLTBL_INIT_OFFSET_A_LESS_MINCYC,
    "scdltbl_init_offset_b_less_mincyc"                          => SCDLTBL_INIT_OFFSET_B_LESS_MINCYC,
    "scdltbl_init_offset_c_less_mincyc"                          => SCDLTBL_INIT_OFFSET_C_LESS_MINCYC,
    "scdltbl_init_offset_a_more_differential_value"              => SCDLTBL_INIT_OFFSET_A_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_b_more_differential_value"              => SCDLTBL_INIT_OFFSET_B_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_c_more_differential_value"              => SCDLTBL_INIT_OFFSET_C_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_a_less_mincyc"                    => SCDLTBL_INIT_OFFSET_NOT_0_A_LESS_MINCYC,
    "scdltbl_init_offset_not_0_b_less_mincyc"                    => SCDLTBL_INIT_OFFSET_NOT_0_B_LESS_MINCYC,
    "scdltbl_init_offset_not_0_c_less_mincyc"                    => SCDLTBL_INIT_OFFSET_NOT_0_C_LESS_MINCYC,
    "scdltbl_init_offset_not_0_a_more_differential_value"        => SCDLTBL_INIT_OFFSET_NOT_0_A_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_b_more_differential_value"        => SCDLTBL_INIT_OFFSET_NOT_0_B_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_c_more_differential_value"        => SCDLTBL_INIT_OFFSET_NOT_0_C_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_max_a_less_mincyc"                => SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_LESS_MINCYC,
    "scdltbl_init_offset_not_0_max_b_less_mincyc"                => SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_LESS_MINCYC,
    "scdltbl_init_offset_not_0_max_c_less_mincyc"                => SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_LESS_MINCYC,
    "scdltbl_init_offset_not_0_max_a_more_differential_value"    => SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_max_b_more_differential_value"    => SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_init_offset_not_0_max_c_more_differential_value"    => SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_MORE_DIFFERENTIAL_VALUE,
    "scdltbl_offset_a_less_mincyc"                               => SCDLTBL_OFFSET_A_LESS_MINCYC,
    "scdltbl_offset_b_less_mincyc"                               => SCDLTBL_OFFSET_B_LESS_MINCYC,
    "scdltbl_offset_c_less_mincyc"                               => SCDLTBL_OFFSET_C_LESS_MINCYC,
    "scdltbl_offset_a_more_maxval"                               => SCDLTBL_OFFSET_A_MORE_MAXVAL,
    "scdltbl_offset_b_more_maxval"                               => SCDLTBL_OFFSET_B_MORE_MAXVAL,
    "scdltbl_offset_c_more_maxval"                               => SCDLTBL_OFFSET_C_MORE_MAXVAL,
    "startscdltblrel_offset_less_1"                              => STARTSCDLTBLREL_OFFSET_LESS_1,
    "startscdltblrel_offset_more_maxval"                         => STARTSCDLTBLREL_OFFSET_MORE_MAXVAL,
    "startscdltblrel_curval_more_not_wraparound"                 => STARTSCDLTBLREL_CURVAL_MORE_NOT_WRAPAROUND,
    "startscdltblrel_wraparound_more_max"                        => STARTSCDLTBLREL_WRAPAROUND_MORE_MAX,
    "startscdltblrel_not_wraparound_less_curval_startscdltblrel" => STARTSCDLTBLREL_NOT_WRAPAROUND_LESS_CURVAL_STARTSCDLTBLREL,
    "startscdltblrel_not_wraparound_more_maxval"                 => STARTSCDLTBLREL_NOT_WRAPAROUND_MORE_MAXVAL
  }

  # type検査
  # 文字列と整数 : 真偽値, 実数
  # 整数         : 真偽値，文字列
  # 文字列       : 真偽値，整数
  # 真偽値       : 文字列，整数
  # ハッシュ     : 真偽値，整数，文字列
  CHK_CONFIGURE_TYPE = {
    # configure
    "version"                         => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "scalability_class"               => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "conformance_class"               => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "target_spec"                     => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "core_num"                        => [String,          Float, Hash, Array, TrueClass, FalseClass],
    "use_multi_core"                  => [String, Integer, Float, Hash, Array,                      ],
    "master_core"                     => [                 Float, Hash, Array, TrueClass, FalseClass],
    "irc_arch"                        => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "max_task_pri"                    => [String,          Float, Hash, Array, TrueClass, FalseClass],
    "min_task_pri"                    => [String,          Float, Hash, Array, TrueClass, FalseClass],
    "enable_exc_in_cpulock"           => [String, Integer, Float, Hash, Array,                      ],
    "func_interrupt"                  => [String, Integer, Float, Hash, Array,                      ],
    "func_hardware_counter"           => [String, Integer, Float, Hash, Array,                      ],
    "func_protection_hook"            => [String, Integer, Float, Hash, Array,                      ],
    "violation_handling_level"        => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "timing_protection_level"         => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "memory_protection_level"         => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "stack_monitoring"                => [String, Integer, Float, Hash, Array,                      ],
    "return_status"                   => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "use_get_serviceid"               => [String, Integer, Float, Hash, Array,                      ],
    "use_parameter_access"            => [String, Integer, Float, Hash, Array,                      ],
    "error_hook"                      => [String, Integer, Float, Hash, Array,                      ],
    "post_task_hook"                  => [String, Integer, Float, Hash, Array,                      ],
    "pre_task_hook"                   => [String, Integer, Float, Hash, Array,                      ],
    "protection_hook"                 => [String, Integer, Float, Hash, Array,                      ],
    "shutdown_hook"                   => [String, Integer, Float, Hash, Array,                      ],
    "startup_hook"                    => [String, Integer, Float, Hash, Array,                      ],
    "startup_hook_osap"               => [String, Integer, Float, Hash, Array,                      ],
    "shutdown_hook_osap"              => [String, Integer, Float, Hash, Array,                      ],
    "error_hook_osap"                 => [String, Integer, Float, Hash, Array,                      ],
    "all_interrupt_lock_budget"       => [String, Integer,        Hash, Array, TrueClass, FalseClass],
    "os_interrupt_lock_budget"        => [String, Integer,        Hash, Array, TrueClass, FalseClass],
    "stack_share"                     => [String, Integer, Float, Hash, Array,                      ],
    "out_file_name"                   => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "app_mode_name"                   => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "default_osap_id"                 => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "wait_spin_loop"                  => [String,          Float, Hash, Array, TrueClass, FalseClass],
    "yaml_lib"                        => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "enable_gcov"                     => [String, Integer, Float, Hash, Array,                      ],
    "enable_log"                      => [String, Integer, Float, Hash, Array,                      ],
    "define_declare"                  => [String, Integer, Float, Hash, Array,                      ],
    "check_stack_usage"               => [String, Integer, Float, Hash, Array,                      ],
    "support_enadis_interrupt_source" => [String, Integer, Float, Hash, Array,                      ],
    "hardware_counter_param"          => [String, Integer, Float,       Array, TrueClass, FalseClass],
    "stackfault_detection"            => [String, Integer, Float, Hash, Array,                      ],
    "enable_cpptest"                  => [String, Integer, Float, Hash, Array,                      ],
    "nt_task_stack_region"            => [        Integer, Float, Hash, Array, TrueClass, FalseClass],
    "inter_core_interrupt"            => [String, Integer, Float, Hash, Array,                      ],
    "use_c1isr"                       => [String, Integer, Float, Hash, Array,                      ],
    "icisr_convert"                   => [String, Integer, Float, Hash, Array,                      ],
    "icisr_pri"                       => [        Integer, Float, Hash, Array, TrueClass, FalseClass],

    # macro
    "MASTER_CORE"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "CORE_SELF"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "CORE_OTHER"   => [Float, String, Hash, Array, TrueClass, FalseClass],
    "CORE_OTHER_1" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "CORE_THIRD"   => [Float, String, Hash, Array, TrueClass, FalseClass],
    "CORE_NUM"     => [Float, String, Hash, Array, TrueClass, FalseClass],

    "PRO_INVALID"            => [Float, Array, Hash, TrueClass, FalseClass],

    "INTNO_SELF_C1ISR_HIGH"   => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C1ISR_MID"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C1ISR_LOW"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_TOP"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_HIGH"   => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_A"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_B"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_C"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_D"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_E"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_F"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_MID_G"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_LOW"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_SELF_C2ISR_BOTTOM" => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR1_A"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_A"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_B"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_C"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_D"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_E"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_F"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_G"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_H"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_I"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_J"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_ISR2_K"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR1_A"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR2_A"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR2_B"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR2_C"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR2_D"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_1_ISR2_E"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR1_A"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR2_A"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR2_B"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR2_C"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR2_D"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INTNO_OTHER_2_ISR2_E"    => [Float, Hash, Array, TrueClass, FalseClass],

    "TSK_PRI_TOP"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "TSK_PRI_HIGH"   => [Float, String, Hash, Array, TrueClass, FalseClass],
    "TSK_PRI_MID"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "TSK_PRI_LOW"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "TSK_PRI_BOTTOM" => [Float, String, Hash, Array, TrueClass, FalseClass],

    "INT_PRI_ISR1_HIGH" => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_ISR1_MID"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_ISR1_LOW"  => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_TOP"       => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_HIGH"      => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_MID"       => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_LOW"       => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_BOTTOM"    => [Float, Hash, Array, TrueClass, FalseClass],
    "INT_PRI_ICISR"     => [Float, Hash, Array, TrueClass, FalseClass],

    "ANY_BASIC_MAXACT"            => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ACTCNT_NOT_MAX_1"        => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMVAL_A"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMVAL_B"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMVAL_C"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMCYCLE_A"              => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMCYCLE_B"              => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_ALMCYCLE_C"              => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MINCYC_A"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MINCYC_B"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MINCYC_C"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MAXVAL_A"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MAXVAL_B"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_MAXVAL_C"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_A"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_B"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_C"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_A"          => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_B"          => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_C"          => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_MAX_A"        => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_MAX_B"        => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_MAX_C"        => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_MAX_A"      => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_MAX_B"      => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_0_MAX_C"      => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_WRAPAROUND_A"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_WRAPAROUND_B"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_WRAPAROUND_C"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_WRAPAROUND_A" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_WRAPAROUND_B" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_NOT_WRAPAROUND_C" => [Float, String, Hash, Array, TrueClass, FalseClass],

    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_A" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_B" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_C" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_INCREMENT_LOWER_THAN_0"          => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_START_GREATER_THAN_MAXVAL_A"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_START_GREATER_THAN_MAXVAL_B"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_START_GREATER_THAN_MAXVAL_C"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_START_LOWER_THAN_0"              => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_A"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_B"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_C"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_A"      => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_B"      => [Float, String, Hash, Array, TrueClass, FalseClass],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_C"      => [Float, String, Hash, Array, TrueClass, FalseClass],

    "EVENTMASK_A" => [Float, Hash, Array, TrueClass, FalseClass],
    "EVENTMASK_B" => [Float, Hash, Array, TrueClass, FalseClass],
    "EVENTMASK_C" => [Float, Hash, Array, TrueClass, FalseClass],

    "ANY_SPOLICY"      => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "ANY_TTYPE"        => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "ANY_TICKSPERBASE" => [Float, Hash, Array, String, TrueClass, FalseClass],
    "ANY_EVENTMASK"    => [Float, Hash, Array, TrueClass, FalseClass],

    "ANY_SCDLTBL_DURATION_A"                    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_DURATION_B"                    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_DURATION_C"                    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_A"                 => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_B"                 => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_C"                 => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A"           => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_B"           => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_C"           => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A"       => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_B"       => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_C"       => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_OFFSET_NOT_0_A"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_OFFSET_NOT_0_B"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBL_OFFSET_NOT_0_C"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_PARAM_OFFSET_STARTSCDLTBLREL"          => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_STARTSCDLTBLREL"                => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_STARTSCDLTBLREL_WRAPAROUND"     => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "ANY_SCDLTBLREL_REPEAT"                     => [Float, Integer, Hash, Array, TrueClass, FalseClass],

    "ANY_TFN_STKSZ" => [Float, Hash, Array, TrueClass, FalseClass],
    "ANY_OSAP_1"    => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "INVALID_ILLEGAL_ADD" => [Float, Hash, Array, TrueClass, FalseClass],

    # invalid_id
    "INVALID_TSK_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_ISR_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_RES_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_CNT_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_ALM_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_SCHTBL_ID"      => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_OSAP_ID"        => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_FUNC_INDEX"     => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_OBJECT_TYPE_ID" => [String, Integer, Float, Hash, TrueClass, FalseClass],
    "INVALID_SPN_ID"         => [String, Integer, Float, Hash, TrueClass, FalseClass],

    # mc_macro
    "TRUSTED_OSAP1"     => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "TRUSTED_OSAP2"     => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "TRUSTED_OSAP3"     => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "NON_TRUSTED_OSAP1" => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "NON_TRUSTED_OSAP2" => [Float, Hash, Array, Integer, TrueClass, FalseClass],
    "NON_TRUSTED_OSAP3" => [Float, Hash, Array, Integer, TrueClass, FalseClass],
   
    # IOC
    "DATA_UINT8_A"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT8_B"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT8_C"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT8_D"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT8_E"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT8_F"  => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_A" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_B" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_C" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_D" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_E" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT16_F" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_A" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_B" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_C" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_D" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_E" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_UINT32_F" => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_A"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_B"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_C"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_D"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_E"    => [Float, String, Hash, Array, TrueClass, FalseClass],
    "DATA_INT_F"    => [Float, String, Hash, Array, TrueClass, FalseClass]
  }

  CHK_HARDWARE_COUNTER_PARAM_TYPE = {
    "counter_id"     => [Float, Integer, Hash, Array, TrueClass, FalseClass],
    "intno"          => [Float, Hash, Array, TrueClass, FalseClass],
    "iniintpri"      => [Float, Hash, Array, TrueClass, FalseClass],
    "intatr"         => [Float, Integer, Hash, Array, TrueClass, FalseClass],
    "mincyc"         => [Float, String, Hash, Array, TrueClass, FalseClass],
    "maxval"         => [Float, String, Hash, Array, TrueClass, FalseClass],
    "secondspertick" => [Integer, String, Hash, Array, TrueClass, FalseClass],
    "osap"           => [Float, Integer, Hash, Array, TrueClass, FalseClass],
    "isrid"          => [Float, Integer, Hash, Array, TrueClass, FalseClass]
  }

  # value検査
  # 0以上の整数     : マイナス，実数
  # 0より大きい整数 : マイナス，実数，0
  # 文字列          : 
  # 特定な文字列    : 任意の文字列
  # 真偽値          : 
  # 0より小さい整数 : プラス，実数，0
  CHK_CONFIGURE_VALUE = {
    # configure
    "version"                         => [],
    "scalability_class"               => [ANY_STRING],
    "conformance_class"               => [ANY_STRING],
    "target_spec"                     => [ANY_STRING],
    "core_num"                        => [ANY_MINUS,ANY_ZERO],
    "use_multi_core"                  => [],
    "master_core"                     => [ANY_MINUS,ANY_ZERO],
    "irc_arch"                        => [ANY_STRING],
    "max_task_pri"                    => [ANY_MINUS],
    "min_task_pri"                    => [ANY_MINUS],
    "enable_exc_in_cpulock"           => [],
    "func_interrupt"                  => [],
    "func_hardware_counter"           => [],
    "func_protection_hook"            => [],
    "violation_handling_level"        => [ANY_STRING],
    "timing_protection_level"         => [ANY_STRING],
    "memory_protection_level"         => [ANY_STRING],
    "stack_monitoring"                => [],
    "return_status"                   => [ANY_STRING],
    "use_get_serviceid"               => [],
    "use_parameter_access"            => [],
    "error_hook"                      => [],
    "post_task_hook"                  => [],
    "pre_task_hook"                   => [],
    "protection_hook"                 => [],
    "shutdown_hook"                   => [],
    "startup_hook"                    => [],
    "startup_hook_osap"               => [],
    "shutdown_hook_osap"              => [],
    "error_hook_osap"                 => [],
    "all_interrupt_lock_budget"       => [ANY_REAL_0],
    "os_interrupt_lock_budget"        => [ANY_REAL_0],
    "stack_share"                     => [],
    "out_file_name"                   => [],
    "app_mode_name"                   => [],
    "default_osap_id"                 => [],
    "wait_spin_loop"                  => [ANY_MINUS],
    "yaml_lib"                        => [ANY_STRING],
    "enable_gcov"                     => [],
    "enable_log"                      => [],
    "define_declare"                  => [],
    "check_stack_usage"               => [],
    "support_enadis_interrupt_source" => [],
    "hardware_counter_param"          => [],
    "stackfault_detection"            => [],
    "enable_cpptest"                  => [],
    "nt_task_stack_region"            => [],
    "inter_core_interrupt"            => [],
    "use_c1isr"                       => [],
    "icisr_convert"                   => [],
    "icisr_pri"                       => [],

    # macro
    "MASTER_CORE"   => [ANY_MINUS],
    "CORE_SELF"     => [ANY_MINUS],
    "CORE_OTHER"    => [ANY_MINUS],
    "CORE_OTHER_1"  => [ANY_MINUS],
    "CORE_THIRD"    => [ANY_MINUS],
    "CORE_NUM"      => [ANY_MINUS],

    "PRO_INVALID"            => [],

    "INTNO_SELF_C1ISR_HIGH"   => [ANY_MINUS],
    "INTNO_SELF_C1ISR_MID"    => [ANY_MINUS],
    "INTNO_SELF_C1ISR_LOW"    => [ANY_MINUS],
    "INTNO_SELF_C2ISR_TOP"    => [ANY_MINUS],
    "INTNO_SELF_C2ISR_HIGH"   => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_A"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_B"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_C"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_D"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_E"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_F"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_MID_G"  => [ANY_MINUS],
    "INTNO_SELF_C2ISR_LOW"    => [ANY_MINUS],
    "INTNO_SELF_C2ISR_BOTTOM" => [ANY_MINUS],
    "INTNO_OTHER_ISR1_A"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_A"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_B"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_C"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_D"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_E"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_F"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_G"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_H"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_I"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_J"      => [ANY_MINUS],
    "INTNO_OTHER_ISR2_K"      => [ANY_MINUS],
    "INTNO_OTHER_1_ISR1_A"    => [ANY_MINUS],
    "INTNO_OTHER_1_ISR2_A"    => [ANY_MINUS],
    "INTNO_OTHER_1_ISR2_B"    => [ANY_MINUS],
    "INTNO_OTHER_1_ISR2_C"    => [ANY_MINUS],
    "INTNO_OTHER_1_ISR2_D"    => [ANY_MINUS],
    "INTNO_OTHER_1_ISR2_E"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR1_A"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR2_A"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR2_B"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR2_C"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR2_D"    => [ANY_MINUS],
    "INTNO_OTHER_2_ISR2_E"    => [ANY_MINUS],

    "TSK_PRI_TOP"    => [ANY_ZERO, ANY_MAX_TASK_PRI, TASTPRI_TOP_HIGH],
    "TSK_PRI_HIGH"   => [ANY_ZERO, ANY_MAX_TASK_PRI, TASTPRI_HIGH_MID],
    "TSK_PRI_MID"    => [ANY_ZERO, ANY_MAX_TASK_PRI, TASTPRI_MID_LOW],
    "TSK_PRI_LOW"    => [ANY_ZERO, ANY_MAX_TASK_PRI, TASTPRI_LOW_BOTTOM],
    "TSK_PRI_BOTTOM" => [ANY_ZERO, ANY_MAX_TASK_PRI, TASTPRI_BOTTOM],

    "INT_PRI_ISR1_HIGH" => [INTPRI_ISR1_HIGH_MID],
    "INT_PRI_ISR1_MID"  => [INTPRI_ISR1_MID_LOW],
    "INT_PRI_ISR1_LOW"  => [INTPRI_ISR1_LOW_TOP],
    "INT_PRI_TOP"       => [INTPRI_TOP_HIGH],
    "INT_PRI_HIGH"      => [INTPRI_HIGH_MID],
    "INT_PRI_MID"       => [INTPRI_MID_LOW],
    "INT_PRI_LOW"       => [INTPRI_LOW_BOTTOM],
    "INT_PRI_BOTTOM"    => [INTPRI_BOTTOM],
    "INT_PRI_ICISR"     => [],

    "ANY_BASIC_MAXACT" => [ANY_MINUS, ANY_ZERO],

    "ANY_ACTCNT_NOT_MAX_1" => [ANY_MINUS, ANY_ZERO, ACTCNT_LOWER_THAN_BASIC_MAXACT],

    "ANY_ALMVAL_A"           => [ANY_MINUS, ALMVAL_A_HIGH],
    "ANY_ALMVAL_B"           => [ANY_MINUS, ALMVAL_B_HIGH],
    "ANY_ALMVAL_C"           => [ANY_MINUS, ALMVAL_B_HIGH],
    "ANY_ALMCYCLE_A"         => [ANY_MINUS, ANY_ZERO, ALMCYCLE_A_LOW, ALMCYCLE_A_HIGH],
    "ANY_ALMCYCLE_B"         => [ANY_MINUS, ANY_ZERO, ALMCYCLE_B_LOW, ALMCYCLE_B_HIGH],
    "ANY_ALMCYCLE_C"         => [ANY_MINUS, ANY_ZERO, ALMCYCLE_C_LOW, ALMCYCLE_C_HIGH],
    "ANY_MINCYC_A"           => [ANY_MINUS, MINCYC_A_HIGH],
    "ANY_MINCYC_B"           => [ANY_MINUS, MINCYC_B_HIGH],
    "ANY_MINCYC_C"           => [ANY_MINUS, MINCYC_C_HIGH],
    "ANY_MAXVAL_A"           => [ANY_MINUS, ANY_ZERO],
    "ANY_MAXVAL_B"           => [ANY_MINUS, ANY_ZERO],
    "ANY_MAXVAL_C"           => [ANY_MINUS, ANY_ZERO],
    "ANY_CURVAL_A"           => [ANY_MINUS, CURVAL_A_HIGH],
    "ANY_CURVAL_B"           => [ANY_MINUS, CURVAL_B_HIGH],
    "ANY_CURVAL_C"           => [ANY_MINUS, CURVAL_C_HIGH],
    "ANY_CURVAL_NOT_0_A"     => [ANY_MINUS, CURVAL_NOT_0_A_HIGH],
    "ANY_CURVAL_NOT_0_B"     => [ANY_MINUS, CURVAL_NOT_0_B_HIGH],
    "ANY_CURVAL_NOT_0_C"     => [ANY_MINUS, CURVAL_NOT_0_C_HIGH],
    "ANY_CURVAL_NOT_MAX_A"   => [ANY_MINUS, CURVAL_NOT_MAX_A_HIGH],
    "ANY_CURVAL_NOT_MAX_B"   => [ANY_MINUS, CURVAL_NOT_MAX_B_HIGH],
    "ANY_CURVAL_NOT_MAX_C"   => [ANY_MINUS, CURVAL_NOT_MAX_C_HIGH],
    "ANY_CURVAL_NOT_0_MAX_A" => [ANY_MINUS, CURVAL_NOT_0_MAX_A_HIGH],
    "ANY_CURVAL_NOT_0_MAX_B" => [ANY_MINUS, CURVAL_NOT_0_MAX_B_HIGH],
    "ANY_CURVAL_NOT_0_MAX_C" => [ANY_MINUS, CURVAL_NOT_0_MAX_C_HIGH],
    "ANY_CURVAL_WRAPAROUND_A" => [ANY_MINUS, WRAPAROUND_MAX_CURVAL_A],
    "ANY_CURVAL_WRAPAROUND_B" => [ANY_MINUS, WRAPAROUND_MAX_CURVAL_B],
    "ANY_CURVAL_WRAPAROUND_C" => [ANY_MINUS, WRAPAROUND_MAX_CURVAL_C],
    "ANY_CURVAL_NOT_WRAPAROUND_A" => [ANY_MINUS, WRAPAROUND_NOT_MAX_CURVAL_A],
    "ANY_CURVAL_NOT_WRAPAROUND_B" => [ANY_MINUS, WRAPAROUND_NOT_MAX_CURVAL_B],
    "ANY_CURVAL_NOT_WRAPAROUND_C" => [ANY_MINUS, WRAPAROUND_NOT_MAX_CURVAL_C],

    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_A" => [INCREMENT_GREATER_THAN_MAXVAL_A],
    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_B" => [INCREMENT_GREATER_THAN_MAXVAL_B],
    "INVALID_INCREMENT_GREATER_THAN_MAXVAL_C" => [INCREMENT_GREATER_THAN_MAXVAL_C],
    "INVALID_INCREMENT_LOWER_THAN_0"          => [ANY_ZERO],
    "INVALID_START_GREATER_THAN_MAXVAL_A"     => [START_GREATER_THAN_MAXVAL_A],
    "INVALID_START_GREATER_THAN_MAXVAL_B"     => [START_GREATER_THAN_MAXVAL_B],
    "INVALID_START_GREATER_THAN_MAXVAL_C"     => [START_GREATER_THAN_MAXVAL_C],
    "INVALID_START_LOWER_THAN_0"              => [ANY_ZERO],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_A"     => [CYCLE_GREATER_THAN_MAXVAL_A],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_B"     => [CYCLE_GREATER_THAN_MAXVAL_B],
    "INVALID_CYCLE_GREATER_THAN_MAXVAL_C"     => [CYCLE_GREATER_THAN_MAXVAL_C],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_A"      => [ANY_ZERO, CYCLE_LOWER_THAN_MINCYCL_A],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_B"      => [ANY_ZERO, CYCLE_LOWER_THAN_MINCYCL_A],
    "INVALID_CYCLE_LOWER_THAN_MINCYCL_C"      => [ANY_ZERO, CYCLE_LOWER_THAN_MINCYCL_A],

    "EVENTMASK_A" => [ANY_STRING, ANY_MINUS, ANY_ZERO],
    "EVENTMASK_B" => [ANY_STRING, ANY_MINUS, ANY_ZERO],
    "EVENTMASK_C" => [ANY_STRING, ANY_MINUS, ANY_ZERO],

    "ANY_SPOLICY"      => [ANY_STRING],
    "ANY_TTYPE"        => [ANY_STRING],
    "ANY_TICKSPERBASE" => [ANY_MINUS, ANY_ZERO],
    "ANY_EVENTMASK"    => [ANY_STRING, ANY_MINUS, ANY_ZERO],

    "ANY_SCDLTBL_DURATION_A"                    => [SCDLTBL_DURATION_A_LESS_MINCYC, SCDLTBL_DURATION_A_MORE_MAXVAL],
    "ANY_SCDLTBL_DURATION_B"                    => [SCDLTBL_DURATION_B_LESS_MINCYC, SCDLTBL_DURATION_B_MORE_MAXVAL],
    "ANY_SCDLTBL_DURATION_C"                    => [SCDLTBL_DURATION_C_LESS_MINCYC, SCDLTBL_DURATION_C_MORE_MAXVAL],
    "ANY_SCDLTBL_INIT_OFFSET_A"                 => [SCDLTBL_INIT_OFFSET_A_LESS_MINCYC, SCDLTBL_INIT_OFFSET_A_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_B"                 => [SCDLTBL_INIT_OFFSET_B_LESS_MINCYC, SCDLTBL_INIT_OFFSET_B_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_C"                 => [SCDLTBL_INIT_OFFSET_C_LESS_MINCYC, SCDLTBL_INIT_OFFSET_C_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_A"           => [SCDLTBL_INIT_OFFSET_NOT_0_A_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_A_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_B"           => [SCDLTBL_INIT_OFFSET_NOT_0_B_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_B_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_C"           => [SCDLTBL_INIT_OFFSET_NOT_0_C_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_C_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_A"       => [SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_MAX_A_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_B"       => [SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_MAX_B_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_INIT_OFFSET_NOT_0_MAX_C"       => [SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_LESS_MINCYC, SCDLTBL_INIT_OFFSET_NOT_0_MAX_C_MORE_DIFFERENTIAL_VALUE],
    "ANY_SCDLTBL_OFFSET_NOT_0_A"                => [SCDLTBL_OFFSET_A_LESS_MINCYC, SCDLTBL_OFFSET_A_MORE_MAXVAL],
    "ANY_SCDLTBL_OFFSET_NOT_0_B"                => [SCDLTBL_OFFSET_B_LESS_MINCYC, SCDLTBL_OFFSET_B_MORE_MAXVAL],
    "ANY_SCDLTBL_OFFSET_NOT_0_C"                => [SCDLTBL_OFFSET_C_LESS_MINCYC, SCDLTBL_OFFSET_C_MORE_MAXVAL],
    "ANY_PARAM_OFFSET_STARTSCDLTBLREL"          => [STARTSCDLTBLREL_OFFSET_LESS_1, STARTSCDLTBLREL_OFFSET_MORE_MAXVAL],
    "ANY_CURVAL_STARTSCDLTBLREL"                => [ANY_ZERO, STARTSCDLTBLREL_CURVAL_MORE_NOT_WRAPAROUND],
    "ANY_CURVAL_STARTSCDLTBLREL_WRAPAROUND"     => [ANY_MINUS, STARTSCDLTBLREL_WRAPAROUND_MORE_MAX],
    "ANY_CURVAL_STARTSCDLTBLREL_NOT_WRAPAROUND" => [STARTSCDLTBLREL_NOT_WRAPAROUND_LESS_CURVAL_STARTSCDLTBLREL, STARTSCDLTBLREL_NOT_WRAPAROUND_MORE_MAXVAL],
    "ANY_SCDLTBLREL_REPEAT"                     => [ANY_STRING],

    "ANY_TFN_STKSZ" => [ANY_MINUS],
    "ANY_OSAP_1"    => [ANY_STRING],
    "INVALID_ILLEGAL_ADD" => [ANY_ZERO, ANY_MINUS],

    "DATA_UINT8_A"  => [],
    "DATA_UINT8_B"  => [],
    "DATA_UINT8_C"  => [],
    "DATA_UINT8_D"  => [],
    "DATA_UINT8_E"  => [],
    "DATA_UINT8_F"  => [],
    "DATA_UINT16_A" => [],
    "DATA_UINT16_B" => [],
    "DATA_UINT16_C" => [],
    "DATA_UINT16_D" => [],
    "DATA_UINT16_E" => [],
    "DATA_UINT16_F" => [],
    "DATA_UINT32_A" => [],
    "DATA_UINT32_B" => [],
    "DATA_UINT32_C" => [],
    "DATA_UINT32_D" => [],
    "DATA_UINT32_E" => [],
    "DATA_UINT32_F" => [],
    "DATA_INT_A"    => [],
    "DATA_INT_B"    => [],
    "DATA_INT_C"    => [],
    "DATA_INT_D"    => [],
    "DATA_INT_E"    => [],
    "DATA_INT_F"    => [],

    # invalid_id
    "INVALID_TSK_ID"         => [],
    "INVALID_ISR_ID"         => [],
    "INVALID_RES_ID"         => [],
    "INVALID_CNT_ID"         => [],
    "INVALID_ALM_ID"         => [],
    "INVALID_SCHTBL_ID"      => [],
    "INVALID_OSAP_ID"        => [],
    "INVALID_FUNC_INDEX"     => [],
    "INVALID_OBJECT_TYPE_ID" => [],
    "INVALID_SPN_ID"         => [],

    # mc_macro
    "TRUSTED_OSAP1"     => [ANY_STRING],
    "TRUSTED_OSAP2"     => [ANY_STRING],
    "TRUSTED_OSAP3"     => [ANY_STRING],
    "NON_TRUSTED_OSAP1" => [ANY_STRING],
    "NON_TRUSTED_OSAP2" => [ANY_STRING],
    "NON_TRUSTED_OSAP3" => [ANY_STRING]
  }

  CHK_HARDWARE_COUNTER_PARAM_VALUE = {
    "counter_id"     => [],
    "intno"          => [ANY_MINUS],
    "iniintpri"      => [],
    "intatr"         => [ANY_STRING],
    "mincyc"         => [ANY_ZERO, HARDWARE_COUNTER_MIMCYC_GREATER_THAN_MAXVAL],
    "maxval"         => [ANY_ZERO],
    "secondspertick" => [ANY_REAL_0],
    "osap"           => [ANY_STRING]
  }

  CHK_HARDWARE_COUNTER_PARAM_VALUE_SC3 = {
    "isrosap" => [ANY_TRUSTED_OSAP],
    "osap"    => [ANY_TRUSTED_OSAP]
  }

  CHK_HARDWARE_COUNTER_INTNO = {
    "intno" => ["AKTSP_INTNO_A", "AKTSP_INTNO_B", "AKTSP_INTNO_C",
                "AKTSP_INTNO_D", "AKTSP_INTNO_E", "AKTSP_INTNO_F",
                "AKTSP_INTNO_G", "AKTSP_INTNO_H", "AKTSP_INTNO_I", "AKTSP_INTNO_J"]
  }

  CHC_VIOLATION_HANDLING_LEVEL = {
    "violation_handling_level" => ["Level2", "Level3"]
  }

  #=====================================================================
  # T2: attributeのマクロ
  #=====================================================================
  # doに必要なファイルのパス
  ANY_T2_TESRY_DO     = TESRY_PATH + "/sample_tesry/merge/sc1/Task/Task_0001.yaml"
  ANY_T2_TESRY_DO_SC3 = TESRY_PATH + "/sample_tesry/merge/sc3/Task/Task_0001.yaml"

  # SC1ファイルのパス
  ANY_T2_TESRY_TASK            = TESRY_PATH + "/sample_tesry/merge/sc1/Task/Task_0005.yaml"
  ANY_T2_TESRY_C1ISR           = TESRY_PATH + "/sample_tesry/merge/sc1/C1ISR/C1ISR_0001.yaml"
  ANY_T2_TESRY_C2ISR           = TESRY_PATH + "/sample_tesry/merge/sc1/C2ISR/C2ISR_0001.yaml"
  ANY_T2_TESRY_STARTUP_HOOK    = TESRY_PATH + "/sample_tesry/merge/sc1/Startup_Hook/Startup_Hook_normal_0001.yaml"
  ANY_T2_TESRY_SHUTDOWN_HOOK   = TESRY_PATH + "/sample_tesry/merge/sc1/Shutdown_Hook/Shutdown_Hook_normal_0001.yaml"
  ANY_T2_TESRY_PRETASK_HOOK    = TESRY_PATH + "/sample_tesry/merge/sc1/Pretask_Hook/Pretask_Hook_normal_0001.yaml"
  ANY_T2_TESRY_POSTTASK_HOOK   = TESRY_PATH + "/sample_tesry/merge/sc1/Posttask_Hook/Posttask_Hook_normal_0001.yaml"
  ANY_T2_TESRY_ERROR_HOOK      = TESRY_PATH + "/sample_tesry/merge/sc1/Error_Hook/Error_Hook_normal_0001.yaml"
  ANY_T2_TESRY_PROTECTION_HOOK = TESRY_PATH + "/sample_tesry/merge/sc1/Protection_Hook/Protection_Hook_normal_0001.yaml"
  ANY_T2_TESRY_ALARM_CALL_BACK = TESRY_PATH + "/sample_tesry/merge/sc1/Alarm/Alarm_normal_0003.yaml"
  ANY_T2_TESRY_ALARM           = TESRY_PATH + "/sample_tesry/merge/sc1/Alarm/Alarm_normal_0001.yaml"
  ANY_T2_TESRY_RESOURCE        = TESRY_PATH + "/sample_tesry/merge/sc1/Resource/Resource_normal_0001.yaml"
  ANY_T2_TESRY_EVENT           = TESRY_PATH + "/sample_tesry/merge/sc1/Event/Event_0001.yaml"
  ANY_T2_TESRY_COUNTER         = TESRY_PATH + "/sample_tesry/merge/sc1/Alarm/Alarm_normal_0002.yaml"
  ANY_T2_TESRY_INT_STATE       = TESRY_PATH + "/sample_tesry/merge/sc1/IntState/IntState_0001.yaml"
  ANY_T2_TESRY_SCHEDULE_TABLE  = TESRY_PATH + "/sample_tesry/merge/sc1/Schedule_Table/Schedule_Table_0009.yaml"

  # SC3ファイルパス
  ANY_T2_TESRY_TASK_SC3               = TESRY_PATH + "/sample_tesry/merge/sc3/Task/Task_0005.yaml"
  ANY_T2_TESRY_C1ISR_SC3              = TESRY_PATH + "/sample_tesry/merge/sc3/C1ISR/C1ISR_0001.yaml"
  ANY_T2_TESRY_C2ISR_SC3              = TESRY_PATH + "/sample_tesry/merge/sc3/C2ISR/C2ISR_0001.yaml"
  ANY_T2_TESRY_STARTUP_HOOK_SC3       = TESRY_PATH + "/sample_tesry/merge/sc3/Startup_Hook/Startup_Hook_normal_0001.yaml"
  ANY_T2_TESRY_SHUTDOWN_HOOK_SC3      = TESRY_PATH + "/sample_tesry/merge/sc3/Shutdown_Hook/Shutdown_Hook_normal_0001.yaml"
  ANY_T2_TESRY_PRETASK_HOOK_SC3       = TESRY_PATH + "/sample_tesry/merge/sc3/Pretask_Hook/Pretask_Hook_normal_0001.yaml"
  ANY_T2_TESRY_POSTTASK_HOOK_SC3      = TESRY_PATH + "/sample_tesry/merge/sc3/Posttask_Hook/Posttask_Hook_normal_0001.yaml"
  ANY_T2_TESRY_ERROR_HOOK_SC3         = TESRY_PATH + "/sample_tesry/merge/sc3/Error_Hook/Error_Hook_normal_0001.yaml"
  ANY_T2_TESRY_PROTECTION_HOOK_SC3    = TESRY_PATH + "/sample_tesry/merge/sc3/Protection_Hook/Protection_Hook_normal_0001.yaml"
  ANY_T2_TESRY_ALARM_SC3              = TESRY_PATH + "/sample_tesry/merge/sc3/Alarm/Alarm_normal_0001.yaml"
  ANY_T2_TESRY_RESOURCE_SC3           = TESRY_PATH + "/sample_tesry/merge/sc3/Resource/Resource_normal_0001.yaml"
  ANY_T2_TESRY_EVENT_SC3              = TESRY_PATH + "/sample_tesry/merge/sc3/Event/Event_0001.yaml"
  ANY_T2_TESRY_COUNTER_SC3            = TESRY_PATH + "/sample_tesry/merge/sc3/Alarm/Alarm_normal_0002.yaml"
  ANY_T2_TESRY_INT_STATE_SC3          = TESRY_PATH + "/sample_tesry/merge/sc3/IntState/IntState_0001.yaml"
  ANY_T2_TESRY_SCHEDULE_TABLE_SC3     = TESRY_PATH + "/sample_tesry/merge/sc3/Schedule_Table/Schedule_Table_0001.yaml"
  ANY_T2_TESRY_STARTUP_HOOK_OSAP_SC3  = TESRY_PATH + "/sample_tesry/merge/sc3/Startup_Hook_Osap/Startup_Hook_Osap_0001.yaml"
  ANY_T2_TESRY_SHUTDOWN_HOOK_OSAP_SC3 = TESRY_PATH + "/sample_tesry/merge/sc3/Shutdown_Hook_Osap/Shutdown_Hook_Osap_0001.yaml"
  ANY_T2_TESRY_ERROR_HOOK_OSAP_SC3    = TESRY_PATH + "/sample_tesry/merge/sc3/Error_Hook_Osap/Error_Hook_Osap_0001.yaml"
  ANY_T2_TESRY_TRUSTED_FUNCTION_SC3   = TESRY_PATH + "/sample_tesry/merge/sc3/Trusted_Function/Trusted_Function_0001.yaml"

  # SC1-MCファイルパス
  ANY_T2_TESRY_TASK_SC1_MC               = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Task/Task_0005.yaml"
  ANY_T2_TESRY_C1ISR_SC1_MC              = TESRY_PATH + "/sample_tesry/merge/sc1-mc/C1ISR/C1ISR_0001.yaml"
  ANY_T2_TESRY_C2ISR_SC1_MC              = TESRY_PATH + "/sample_tesry/merge/sc1-mc/C2ISR/C2ISR_0003.yaml"
  ANY_T2_TESRY_PRETASK_HOOK_SC1_MC       = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Pretask_Hook/Pretask_Hook_0001.yaml"
  ANY_T2_TESRY_POSTTASK_HOOK_SC1_MC      = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Posttask_Hook/Posttask_Hook_0001.yaml"
  ANY_T2_TESRY_ERROR_HOOK_SC1_MC         = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Error_Hook/Error_Hook_0001.yaml"
  ANY_T2_TESRY_PROTECTION_HOOK_SC1_MC    = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Protection_Hook/Protection_Hook_0001.yaml"
  ANY_T2_TESRY_ALARM_SC1_MC              = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Alarm/Alarm_0005.yaml"
  ANY_T2_TESRY_COUNTER_SC1_MC            = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Counter/Counter_0001.yaml"
  ANY_T2_TESRY_INT_STATE_SC1_MC          = TESRY_PATH + "/sample_tesry/merge/sc1-mc/IntState/IntState_0001.yaml"
  ANY_T2_TESRY_SCHEDULE_TABLE_SC1_MC     = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Schedule_Table/Schedule_Table_0005.yaml"
  ANY_T2_TESRY_STARTUP_HOOK_OSAP_SC1_MC  = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Startup_Hook_Osap/Startup_Hook_Osap_0002.yaml"
  ANY_T2_TESRY_SHUTDOWN_HOOK_OSAP_SC1_MC = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Shutdown_Hook_Osap/Shutdown_Hook_Osap_0003.yaml"
  ANY_T2_TESRY_ERROR_HOOK_OSAP_SC1_MC    = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Error_Hook_Osap/Error_Hook_Osap_0001.yaml"
  ANY_T2_TESRY_SPINLOCK_SC1_MC           = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Spinlock/Spinlock_0005.yaml"
  ANY_T2_TESRY_IOC_SC1_MC                = TESRY_PATH + "/sample_tesry/merge/sc1-mc/Ioc/Ioc_0001.yaml"

  # SC3-MCファイルパス
  # 現状，SC3のファイルで確認が可能なため，使用していない(スピンロック以外)
  ANY_T2_TESRY_TASK_SC3_MC               = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Task/Task_0005.yaml"
  ANY_T2_TESRY_C1ISR_SC3_MC              = TESRY_PATH + "/sample_tesry/merge/sc3-mc/C1ISR/C1ISR_0001.yaml"
  ANY_T2_TESRY_C2ISR_SC3_MC              = TESRY_PATH + "/sample_tesry/merge/sc3-mc/C2ISR/C2ISR_0003.yaml"
  ANY_T2_TESRY_PRETASK_HOOK_SC3_MC       = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Pretask_Hook/Pretask_Hook_0001.yaml"
  ANY_T2_TESRY_POSTTASK_HOOK_SC3_MC      = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Posttask_Hook/Posttask_Hook_0001.yaml"
  ANY_T2_TESRY_ERROR_HOOK_SC3_MC         = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Error_Hook/Error_Hook_0001.yaml"
  ANY_T2_TESRY_PROTECTION_HOOK_SC3_MC    = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Protection_Hook/Protection_Hook_0001.yaml"
  ANY_T2_TESRY_ALARM_SC3_MC              = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Alarm/Alarm_0005.yaml"
  ANY_T2_TESRY_COUNTER_SC3_MC            = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Counter/Counter_0001.yaml"
  ANY_T2_TESRY_INT_STATE_SC3_MC          = TESRY_PATH + "/sample_tesry/merge/sc3-mc/IntState/IntState_0001.yaml"
  ANY_T2_TESRY_SCHEDULE_TABLE_SC3_MC     = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Schedule_Table/Schedule_Table_0005.yaml"
  ANY_T2_TESRY_STARTUP_HOOK_OSAP_SC3_MC  = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Startup_Hook_Osap/Startup_Hook_Osap_0002.yaml"
  ANY_T2_TESRY_SHUTDOWN_HOOK_OSAP_SC3_MC = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Shutdown_Hook_Osap/Shutdown_Hook_Osap_0003.yaml"
  ANY_T2_TESRY_ERROR_HOOK_OSAP_SC3_MC    = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Error_Hook_Osap/Error_Hook_Osap_0001.yaml"
  ANY_T2_TESRY_SPINLOCK_SC3_MC           = TESRY_PATH + "/sample_tesry/merge/sc3-mc/Spinlock/Spinlock_0005.yaml"
  ANY_T2_TESRY_TRUSTED_FUNCTION_SC3_MC   = TESRY_PATH + "/sample_tesry/merge/sc3/Trusted_Function/Trusted_Function_0001.yaml"

  ANY_ERR_SI  = ["AAA000"]
  ANY_ERR_HOOK_CFG = ["ERROR"]
  ANY_OSAP_LEVEL1 = TSR_STT_NON_TRUSTED_OSAP1

  # マクロの置換
  CVT_ATTRIBUTE_VALUE = {
    Array      => ["array"],
    Hash       => {"key" => "val"},
    String     => "string",
    Float      => 1.0,
    Integer    => 0,
    TrueClass  => true,
    FalseClass => false,
    NilClass   => "",

    ANY_ZERO   => ANY_ZERO,
    ANY_PLUS   => ANY_PLUS,
    ANY_MINUS  => ANY_MINUS,
    ANY_STRING => ANY_STRING,
    ANY_REAL_0 => ANY_REAL_0,

    # osap
    ANY_OSAP_LEVEL1 => ANY_OSAP_LEVEL1,

    # need_si
    ANY_ERR_SI  => ANY_ERR_SI,

    # target_error_hook_cfg
    ANY_ERR_HOOK_CFG => ANY_ERR_HOOK_CFG,

    # Int_state
    ANY_VALUE_HASH => ANY_VALUE_HASH
  }

  # ファイル変換名
  CVT_ATTRIBUTE_NAME = {
    Array      => "array",
    Hash       => "hash",
    String     => "string",
    Integer    => "number",
    Float      => "float",
    TrueClass  => "true",
    FalseClass => "false",
    NilClass   => "null",

    ANY_ZERO   => "zero",
    ANY_PLUS   => "plus",
    ANY_MINUS  => "minus",
    ANY_STRING => "string",
    ANY_REAL_0 => "zero_realnum",

    ANY_OSAP_LEVEL1 => "osap_memory_protection_level1",

    ANY_ERR_SI => "error_need_si",
    ANY_ERR_HOOK_CFG => "error_hook_cnfigure",

    ANY_VALUE_HASH => "type_hash"
  }

  # type検査
  # 配列         : [      ハッシュ，文字列，整数，真偽値, null]
  # ハッシュ     : [配列，          文字列，整数，真偽値, null]
  # 文字列       : [配列，ハッシュ，        整数，真偽値, null]
  # 整数         : [配列，ハッシュ，文字列，      真偽値, null]
  # 真偽値       : [配列，ハッシュ，文字列，整数,         null]
  # 文字列と整数 : [配列，ハッシュ，              真偽値, null]
  CHK_ATTRIBUTE_TYPE = {
    TSR_OBJ_TASK => {
      TSR_PRM_TSTAT          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CURPRI         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INIPRI         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_TTYPE          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_MAXACT         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SPOLICY        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CUREVT         => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ACTCNT         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_PORDER         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_RELRES         => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_GETRES         => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_RELEVT         => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_WAIEVT         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STKSZ          => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STK            => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_APPMODE        => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_INTNO          => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INIINTPRI      => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_RTNSTAT        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array,       String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_INTNO          => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INIINTPRI      => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CURINTPRI      => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_RTNSTAT        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INTATR         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ISTAT          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_RELRES         => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_GETRES         => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ISTKSZ         => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_STARTUP_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SHUTDOWN_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ALARM_CALL_BACK => {
      TSR_PRM_CBSTAT         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_VAR            => [Array, Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_RESOURCE => {
      TSR_PRM_RESPROP  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_LOCKFLG  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_LINKRES  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_EVENT => {
      TSR_PRM_MASK     => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_MINCYC   => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_MAXVAL   => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CURVAL   => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CTYPE    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_TICKSPERBASE => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CSTAT    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_ALMACT        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_COUNTER       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ASTAT         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ALMVAL        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CYCLE         => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_TASK          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_EVENT         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INCOUNTER     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_AUTOSTARTTYPE => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_APPMODE       => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CALLBAK       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_INT_STATE => {
      TSR_PRM_ISTAT    => [Array, Hash, String, Integer, Float, TrueClass, FalseClass          ],
    },

    TSR_OBJ_SCHEDULE_TABLE  => {
      TSR_PRM_COUNTER       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SYNCSTRATEGY  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_REPEAT        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STSTAT        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_DURATION      => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_EXPOINT       => [Array,       String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CURVAL        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STFROM        => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      "offset"              => [Array,       String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ACTTSK        => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SETEVT        => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STARTTICK     => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_AUTOSTARTTYPE => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_APPMODE       => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_LBL_DO => {
      TSR_PRM_ID       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SYSSRV   => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_REPEAT   => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_GCOV     => [Array, Hash, String, Integer, Float,                        NilClass],
      TSR_PRM_FINISH   => [Array, Hash, String, Integer, Float,                        NilClass],
      TSR_PRM_RETTYPE  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI  => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_RETVAL   => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass]
    }
  }

  CHK_ATTRIBUTE_TYPE_SC3 = {
    TSR_OBJ_TASK => {
      TSR_PRM_SSTKSZ  => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SSTK    => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ACCOSAP => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ACCOSAP => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_BOOTCNT        => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_STKSZ          => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ARG            => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_CALLER         => [Array, Hash,         Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_GETRES         => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_WAIEVT         => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_RESOURCE => {
      TSR_PRM_ACCOSAP => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },
=begin
    TSR_OBJ_MEMORY_MODULE => {
      TSR_PRM_FILE   => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_EXPORT => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP   => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_MEMORY_AREA => {
      TSR_PRM_MEMATR => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_BASE   => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SIZE   => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP   => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_MEMORY_SECTION => {
      TSR_PRM_SECTION => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_MEMATR  => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_REGION  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_EXPORT  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    }
=end
  }

  CHK_ATTRIBUTE_TYPE_MC = {
    TSR_OBJ_TASK => {
      TSR_PRM_SPNID          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_GETSPN         => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_SPNID          => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_GETSPN         => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_NEED_SI        => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_ERROR_HOOK_CFG => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_COREID  => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_COREID  => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_COREID  => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_COREID  => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_INT_STATE => {
      TSR_PRM_COREID  => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP           => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_SPINLOCK => {
      TSR_PRM_SUSINT     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_LOCKFLG    => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_SUCCESSOR  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_ACCOSAP    => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_GETSPN     => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ]
    },

    TSR_OBJ_IOC => {
      TSR_PRM_SENDER   => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_RECEIVER => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_IOCDATA  => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_MAXQUE   => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_DATA     => [       Hash, String, Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_DATALIST => [       Hash, String, Integer, Float, TrueClass, FalseClass,         ],
      TSR_PRM_LOSTFLG  => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_IOC_SENDER => {
      TSR_PRM_SENDERID => [Array, Hash, String,          Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_KIND     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_IOC_RECEIVER => {
      TSR_PRM_KIND     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_OSAP     => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass]
    },

    TSR_OBJ_IOC_DATA => {
      TSR_PRM_DATATYPE => [Array, Hash,         Integer, Float, TrueClass, FalseClass, NilClass],
      TSR_PRM_INITVAL  => [Array, Hash,                  Float, TrueClass, FalseClass, NilClass]
    }
  }

  # value検査
  # 0以上の整数     : マイナス，実数
  # 0より大きい整数 : マイナス，実数，0
  # 文字列          : 
  # 特定な文字列    : 任意の文字列
  # 真偽値          : 
  # 0より小さい整数 : プラス，実数，0
  # varの場合はT3_VARxxxで検査している
  CHK_ATTRIBUTE_VALUE = {
    TSR_OBJ_TASK => {
      TSR_PRM_TSTAT          => [ANY_STRING],
      TSR_PRM_CURPRI         => [ANY_MINUS],
      TSR_PRM_INIPRI         => [ANY_MINUS],
      TSR_PRM_TTYPE          => [ANY_STRING],
      TSR_PRM_MAXACT         => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_SPOLICY        => [ANY_STRING],
      TSR_PRM_CUREVT         => [ANY_MINUS],
      TSR_PRM_ACTCNT         => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_PORDER         => [ANY_MINUS],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_RELRES         => [],
      TSR_PRM_GETRES         => [],
      TSR_PRM_RELEVT         => [],
      TSR_PRM_WAIEVT         => [],
      TSR_PRM_STKSZ          => [ANY_MINUS],
      TSR_PRM_STK            => [ANY_MINUS],
      TSR_PRM_APPMODE        => [],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_INTNO          => [ANY_MINUS],
      TSR_PRM_INIINTPRI      => [],
      TSR_PRM_RTNSTAT        => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_INTNO          => [ANY_MINUS],
      TSR_PRM_INIINTPRI      => [],
      TSR_PRM_CURINTPRI      => [],
      TSR_PRM_RTNSTAT        => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_INTATR         => [ANY_STRING],
      TSR_PRM_ISTAT          => [ANY_STRING],
      TSR_PRM_RELRES         => [],
      TSR_PRM_GETRES         => [],
      TSR_PRM_ISTKSZ         => [],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_STARTUP_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_SHUTDOWN_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_ALARM_CALL_BACK => {
      TSR_PRM_CBSTAT         => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_VAR            => []
    },

    TSR_OBJ_RESOURCE => {
      TSR_PRM_RESPROP  => [ANY_STRING],
      TSR_PRM_LOCKFLG  => [ANY_STRING],
      TSR_PRM_LINKRES  => []
    },

    TSR_OBJ_EVENT => {
      TSR_PRM_MASK     => [ANY_MINUS, ANY_ZERO]
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_MINCYC   => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_MAXVAL   => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_CURVAL   => [ANY_MINUS],
      TSR_PRM_CTYPE    => [ANY_STRING],
      TSR_PRM_TICKSPERBASE => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_CSTAT    => [ANY_STRING]
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_ALMACT        => [ANY_STRING],
      TSR_PRM_COUNTER       => [],
      TSR_PRM_ASTAT         => [ANY_STRING],
      TSR_PRM_ALMVAL        => [ANY_MINUS],
      TSR_PRM_CYCLE         => [ANY_MINUS],
      TSR_PRM_TASK          => [],
      TSR_PRM_EVENT         => [],
      TSR_PRM_INCOUNTER     => [],
      TSR_PRM_CALLBAK       => [],
      TSR_PRM_AUTOSTARTTYPE => [ANY_STRING],
      TSR_PRM_APPMODE       => [],
    },

    TSR_OBJ_INT_STATE => {
      TSR_PRM_ISTAT    => [ANY_VALUE_HASH]
    },

    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_COUNTER       => [],
      TSR_PRM_SYNCSTRATEGY  => [ANY_STRING],
      TSR_PRM_REPEAT        => [ANY_STRING],
      TSR_PRM_STSTAT        => [ANY_STRING],
      TSR_PRM_DURATION      => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_EXPOINT       => [],
      TSR_PRM_CURVAL        => [ANY_MINUS],
      TSR_PRM_STFROM        => [],
      "offset"              => [],
      TSR_PRM_ACTTSK        => [],
      TSR_PRM_SETEVT        => [],
      TSR_PRM_STARTTICK     => [],
      TSR_PRM_AUTOSTARTTYPE => [ANY_STRING],
      TSR_PRM_APPMODE       => []
    },

    TSR_LBL_DO => {
      TSR_PRM_ID       => [],
      TSR_PRM_SYSSRV   => [],
      TSR_PRM_REPEAT   => [ANY_MINUS, ANY_ZERO],
      TSR_PRM_GCOV     => [],
      TSR_PRM_FINISH   => [],
      TSR_PRM_RETTYPE  => [ANY_STRING],
      TSR_PRM_NEED_SI  => [ANY_ERR_SI],
      TSR_PRM_RETVAL   => [ANY_MINUS]
    }
  }

  CHK_ATTRIBUTE_VALUE_SC3 = {
    TSR_OBJ_TASK => {
      TSR_PRM_SSTKSZ  => [ANY_MINUS],
      TSR_PRM_SSTK    => [ANY_MINUS],
      TSR_PRM_OSAP    => [ANY_STRING],
      TSR_PRM_ACCOSAP => []
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP    => [ANY_STRING]
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_OSAP    => [ANY_STRING, ANY_OSAP_LEVEL1],
      TSR_PRM_ACCOSAP => []
    },
    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING, ANY_OSAP_LEVEL1]
    },

    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING, ANY_OSAP_LEVEL1]
    },

    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING, ANY_OSAP_LEVEL1]
    },

    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_OSAP           => [ANY_STRING],
      TSR_PRM_BOOTCNT        => [ANY_MINUS],
      TSR_PRM_STKSZ          => [ANY_MINUS],
      TSR_PRM_ARG            => [],
      TSR_PRM_CALLER         => [],
      TSR_PRM_GETRES         => [],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_WAIEVT         => []
    },

    TSR_OBJ_RESOURCE => {
      TSR_PRM_ACCOSAP => []
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP    => [ANY_STRING],
      TSR_PRM_ACCOSAP => []
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP    => [ANY_STRING],
      TSR_PRM_ACCOSAP => []
    },

    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP    => [ANY_STRING],
      TSR_PRM_ACCOSAP => []
    },
=begin
    TSR_OBJ_MEMORY_MODULE => {
      TSR_PRM_FILE   => [],
      TSR_PRM_EXPORT => [ANY_STRING],
      TSR_PRM_OSAP   => [ANY_STRING]
    },

    TSR_OBJ_MEMORY_AREA => {
      TSR_PRM_MEMATR => [ANY_STRING],
      TSR_PRM_BASE   => [ANY_MINUS],
      TSR_PRM_SIZE   => [ANY_MINUS],
      TSR_PRM_OSAP   => [ANY_STRING]
    },

    TSR_OBJ_MEMORY_SECTION => {
      TSR_PRM_SECTION => [],
      TSR_PRM_MEMATR  => [ANY_STRING],
      TSR_PRM_REGION  => [],
      TSR_PRM_EXPORT  => [ANY_STRING],
      TSR_PRM_OSAP    => [ANY_STRING]
    }
=end
  }

  CHK_ATTRIBUTE_VALUE_MC = {
    TSR_OBJ_TASK => {
      TSR_PRM_SPNID          => [],
      TSR_PRM_GETSPN         => [],
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_C1ISR => {
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_C2ISR => {
      TSR_PRM_SPNID          => [],
      TSR_PRM_GETSPN         => [],
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_STARTUP_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_SHUTDOWN_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_ERROR_HOOK_OSAP => {
      TSR_PRM_HOOKSTAT       => [ANY_STRING],
      TSR_PRM_NEED_SI        => [ANY_ERR_SI],
      TSR_PRM_ERROR_HOOK_CFG => [ANY_ERR_HOOK_CFG],
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_PRETASK_HOOK => {
      TSR_PRM_COREID  => [ANY_MINUS]
    },

    TSR_OBJ_POSTTASK_HOOK => {
      TSR_PRM_COREID  => [ANY_MINUS]
    },

    TSR_OBJ_ERROR_HOOK => {
      TSR_PRM_COREID  => [ANY_MINUS]
    },

    TSR_OBJ_PROTECTION_HOOK => {
      TSR_PRM_COREID  => [ANY_MINUS]
    },

    TSR_OBJ_INT_STATE => {
      TSR_PRM_COREID  => [ANY_MINUS]
    },

    TSR_OBJ_COUNTER => {
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_ALARM => {
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_SCHEDULE_TABLE => {
      TSR_PRM_OSAP           => [ANY_STRING]
    },

    TSR_OBJ_SPINLOCK => {
      TSR_PRM_SUSINT     => [ANY_STRING],
      TSR_PRM_LOCKFLG    => [ANY_STRING],
      TSR_PRM_SUCCESSOR  => [],
      TSR_PRM_ACCOSAP    => []
    },

    TSR_OBJ_TRUSTED_FUNCTION => {
      TSR_PRM_GETSPN     => []
    },

    TSR_OBJ_IOC => {
      TSR_PRM_SENDER   => [],
      TSR_PRM_RECEIVER => [],
      TSR_PRM_IOCDATA  => [],
      TSR_PRM_MAXQUE   => [ANY_MINUS],
      TSR_PRM_DATA     => [],
      TSR_PRM_DATALIST => [],
      TSR_PRM_LOSTFLG  => [ANY_STRING]
    },

    TSR_OBJ_IOC_SENDER => {
      TSR_PRM_SENDERID => [ANY_MINUS],
      TSR_PRM_KIND     => [ANY_STRING],
      TSR_PRM_OSAP     => [ANY_STRING]
    },

    TSR_OBJ_IOC_RECEIVER => {
      TSR_PRM_KIND     => [ANY_STRING],
      TSR_PRM_OSAP     => [ANY_STRING]
    },

    TSR_OBJ_IOC_DATA => {
      TSR_PRM_DATATYPE => [],
      TSR_PRM_INITVAL  => [ANY_MINUS]
    }
  }

  #=====================================================================
  # T6: propertyのマクロ
  #=====================================================================
  # パス
  ANY_T6_TESRY     = TESRY_PATH + "/sample_tesry/merge/sc1/Task/Task_0001.yaml"
  ANY_T6_TESRY_SC3 = TESRY_PATH + "/sample_tesry/merge/sc3/Task/Task_0001.yaml"

  # ANY VALUE
  ANY_SC = ["AC1"]
  ANY_CC = ["DCC2"]
  ANY_SI = ["OSI0432"]

  # マクロの置換
  CVT_PROPERTY_VALUE = {
    Array      => ["array"],
    Hash       => {"key" => "val"},
    String     => "string",
    Float      => 1.0,
    Integer    => 0,
    TrueClass  => true,
    FalseClass => false,
    ANY_ZERO   => ANY_ZERO,

    ANY_SC   => ANY_SC,
    ANY_CC   => ANY_CC,
    ANY_SI   => ANY_SI
  }

  # ファイル変換名
  CVT_PROPERTY_NAME = {
    Array      => "array",
    Hash       => "hash",
    String     => "string",
    Integer    => "number",
    Float      => "float",
    TrueClass  => "true",
    FalseClass => "false",
    ANY_ZERO   => "zero",

    ANY_SC   => "error_value",
    ANY_CC   => "error_value",
    ANY_SI   => "error_value"
  }

  # type検査
  # 配列         : [      ハッシュ，文字列，整数，真偽値]
  # ハッシュ     : [配列，          文字列，整数，真偽値]
  # 文字列       : [配列，ハッシュ，        整数，真偽値]
  # 整数         : [配列，ハッシュ，文字列，      真偽値]
  # 真偽値       : [配列，ハッシュ，文字列，整数,       ]
  # 文字列と整数 : [配列，ハッシュ，              真偽値]
  CHK_PROPERTY_TYPE = {
    "sc"                           => [       Hash, String, Integer, Float, TrueClass, FalseClass],
    "cc"                           => [       Hash, String, Integer, Float, TrueClass, FalseClass],
    "si"                           => [       Hash, String, Integer, Float, TrueClass, FalseClass],
    "need_enadis_interrupt_source" => [Array, Hash, String, Integer, Float,                      ],
    "violation_handling_level"     => [Array, Hash, String,          Float, TrueClass, FalseClass],
    "timing_protection_level"      => [Array, Hash, String,          Float, TrueClass, FalseClass],
    "memory_protection_level"      => [Array, Hash, String,          Float, TrueClass, FalseClass],
    "need_stack_share"             => [Array, Hash, String, Integer, Float,                      ],
    "maintask_wait"                => [Array, Hash, String, Integer, Float,                      ],
    "application_mode"             => [Array, Hash,         Integer, Float, TrueClass, FalseClass]
  }

  # value検査
  # 特定な文字列    : 任意の文字列
  # 真偽値          : 
  CHK_PROPERTY_VALUE = {
    "sc"                           => [ANY_SC],
    "cc"                           => [ANY_CC],
    "si"                           => [ANY_SI],
    "need_enadis_interrupt_source" => [],
    "violation_handling_level"     => [ANY_ZERO],
    "timing_protection_level"      => [ANY_ZERO],
    "memory_protection_level"      => [ANY_ZERO],
    "need_stack_share"             => [],
    "maintask_wait"                => [],
    "application_mode"             => []
  }

end
