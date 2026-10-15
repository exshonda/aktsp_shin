#!/usr/bin/ruby
#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2011-2015 by Center for Embedded Computing Systems
#               Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2014-2015 by AISIN COMCRUISE Co., Ltd., JAPAN
# Copyright (C) 2014-2015 by eSOL Co.,Ltd., JAPAN
# Copyright (C) 2011-2015 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2014-2015 by Fujitsu TEN Limited
# Copyright (C) 2014-2015 by JTEKT CORPORATION
# Copyright (C) 2011-2015 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2011-2015 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2014-2015 by SCSK Corporation, JAPAN
# Copyright (C) 2011-2013 by Spansion LLC, USA
# Copyright (C) 2011-2015 by Sunny Giken Inc., JAPAN
# Copyright (C) 2011-2015 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2011-2015 by Witz Corporation
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

require 'yaml'
require 'fileutils'
require 'thread'
require 'logger'

#=======================================================================
#
# ビルド処理クラス
#
#=======================================================================
class AKTBBuilder < Thread

  #=====================================================================
  # 初期化関数
  #=====================================================================
  def initialize(build_name, queue, cfg_obj)

    # ビルド名
    @build_name = build_name

    # ツール実行マネージャ
    @cfg_mgr  = CfgManager.new(cfg_obj)
    @aktg_mgr = AktgManager.new(cfg_obj)
    @make_mgr = MakeManager.new(cfg_obj)

    # 設定ファイル
    @config = cfg_obj

    # AKTSPで使用するディレクトリ
    @aktsp_dir       = `pwd`.chomp + "/../"
    @root_dir        = @aktsp_dir + @config["obj_root_path"]
    @build_dir       = @root_dir  + "/" + @build_name
    @aktg_bin        = @aktsp_dir + @config["tool_aktg_bin"]
    @auto_dir_ladder = @config["auto_dir_ladder"]

    # 初期化処理
    @start_file             = "#{@build_dir}_start.dat"
    @post_configure_file    = "#{@build_dir}_post_configure.dat"
    @post_aktg_file         = "#{@build_dir}_post_aktg.dat"
    @post_make_depend_file  = "#{@build_dir}_post_make_depend.dat"
    @post_make_build_file   = "#{@build_dir}_post_make_build.dat"
    @fail_build_file        = "#{@build_dir}_fail_build.dat"

    # ビルドエラー管理
    @error_flg = false

    block = Proc.new{
      lock = queue.pop
      begin
        main_proc
      rescue => e
        AktbLog.instance.fatal("[AKTBBuilder] Exception : #{e}")
      ensure
        queue.push(lock)
      end
    }
    super(&block)
  end

  #=====================================================================
  # メイン処理
  #=====================================================================
  def main_proc

    # 0. 状態管理ファイルの作成
    FileUtils.touch(@start_file)

    # 1.configureを実行
    execute_configure
    if @error_flg
      return
    end

    # 2.AKTGを実行
    execute_aktg
    if @error_flg
      return
    end

    # 3.make dependを実行
    execute_make_depend
    if @error_flg
      return
    end

    # 4.makeを実行
    execute_make
  end

  #=====================================================================
  # configureを実行
  #=====================================================================
  def execute_configure
    AktbLog.instance.info("[configure:#{@build_name}] START")

    if @cfg_mgr.execute("#{@build_dir}")
      FileUtils.mv(@start_file, @post_configure_file)
      AktbLog.instance.info("[configure:#{@build_name}] FINISH")
    else
      @error_flg = true
      FileUtils.mv(@start_file, @fail_build_file)
      AktbLog.instance.warn("[configure:#{@build_name}] FAILED")
    end
  end

  #=====================================================================
  # AKTGを実行
  #=====================================================================
  def execute_aktg
    AktbLog.instance.info("[AKTG:#{@build_name}] START")

    if @aktg_mgr.execute("#{@build_dir}")
      FileUtils.mv(@post_configure_file, @post_aktg_file)
      AktbLog.instance.info("[AKTG:#{@build_name}] FINISH")
    else
      @error_flg = true
      FileUtils.mv(@post_configure_file, @fail_build_file)
      AktbLog.instance.warn("[AKTG:#{@build_name}] FAILED")
    end
  end

  #=====================================================================
  # make dependを実行
  #=====================================================================
  def execute_make_depend
    AktbLog.instance.info("[make depend:#{@build_name}] START")

    if @make_mgr.execute_depend("#{@build_dir}")
      FileUtils.mv(@post_aktg_file, @post_make_depend_file)
      AktbLog.instance.info("[make depend:#{@build_name}] FINISH")
    else
      @error_flg = true
      FileUtils.mv(@post_aktg_file, @fail_build_file)
      AktbLog.instance.warn("[make depend:#{@build_name}] FAILED")
    end
  end

  #=====================================================================
  # makeを実行
  #=====================================================================
  def execute_make
    AktbLog.instance.info("[make:#{@build_name}] START")

    if @make_mgr.execute_build("#{@build_dir}")
      FileUtils.mv(@post_make_depend_file, @post_make_build_file)
      AktbLog.instance.info("[make:#{@build_name}] FINISH")
    else
      @error_flg = true
      FileUtils.mv(@post_make_depend_file, @fail_build_file)
      AktbLog.instance.warn("[make:#{@build_name}] FAILED")
    end
  end
end
