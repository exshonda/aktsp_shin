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

$:.unshift(File.dirname(__FILE__)) 
require 'fileutils'
require 'yaml'
require 'optparse'
require 'thwait'

require 'aktb_log.rb'
require 'mnf_generator.rb'
require 'cfg_manager.rb'
require 'aktg_manager.rb'
require 'make_manager.rb'
require 'mp_tesry_expander.rb'
require 'aktb_builder.rb'

Encoding.default_external = "ISO-8859-1"

#=======================================================================
#
# AKTBメインクラス
#
#=======================================================================
class AKTB

  #=====================================================================
  # 各実行バイナリのパス
  #=====================================================================
  CMD_RUBY = "/usr/bin/ruby"

  #=====================================================================
  # 初期化関数
  #=====================================================================
  def initialize(aktg_cfg)

    # 設定ファイル
    @config   = YAML.load_file(aktg_cfg["cfg_file"])
    
    # 各機能の実行有無
    @create_dir_mode      = aktg_cfg["create_dir_mode"]
    @exec_mode            = aktg_cfg["exec_mode"]
    @build_mode           = aktg_cfg["build_mode"]
    @build_libkernel_mode = aktg_cfg["build_libkernel_mode"]

    # 使用するボードによって実行するクラスを読み替える
    require @config["executer_module"]
    
    # AKTSPで使用するディレクトリ
    @aktsp_dir = `pwd`.chomp + "/../"
    @root_dir  = @aktsp_dir + @config["obj_root_path"]
    @tesry_dir = @aktsp_dir + @config["obj_tesry_path"]
    @cmy_dir   = @aktsp_dir + @config["cmy_path"]

    # 設定ファイルの読み込み
    if @config["log_file_path"]
      AktbLog.instance.set_logfile(@aktsp_dir + @config["log_file_path"])
    else
      AktbLog.instance.set_logfile("aktb_logger.log")
    end
    if @config["log_level"] != nil
      AktbLog.instance.change_level(@config["log_level"])
    end
    AktbLog.instance.info("<<< AKTSP START >>>")
    AktbLog.instance.info("[Config File] " + aktg_cfg["cfg_file"])

    # メモリ保護用TESRY拡張機構実施の有無(利用時はターゲット依存設定ファイルを読込む事)
    @use_mp_tesry_expander = @config["use_mp_tesry_expander"]
    if @use_mp_tesry_expander
      @mp_tesry_expander_conf = @aktsp_dir + @config["mp_tesry_expander_conf"]
    end

    # AUTO_CODE利用の有無
    @use_auto_code = @config["use_auto_code"]

    # 分割数
    @divide_num  = @config["divide_num"]

    # スレッド実行数
    @max_threads = @config["max_threads"]

    # 強制マージ有効/無効
    @use_force_merge = @config["use_force_merge"]

    # カーネルライブラリビルド用設定
    @use_libkernel_yml = @config["use_libkernel_yml"]
    @target_libkernel_yml = @config["target_libkernel_yml"]

    # CMY用ディレクトリリスト
    @cmy_tesry_dirs = []
    
  end

  #=====================================================================
  # メイン処理
  #=====================================================================
  def main

  
    if @create_dir_mode

      # tesryコピー用ディレクトリ作成
      FileUtils.mkdir_p(@tesry_dir)

      # CMYファイル分解処理
      divide_cmy

      # メモリ保護時専用TESRY拡張処理
      if @use_mp_tesry_expander
        expander = MPTesryExpander.new(@mp_tesry_expander_conf, @tesry_dir)
        expander.expand
      end

      # 分割済みマニフェストファイル作成
      # mnf_generator.rbに処理を委譲
      mnf_generator = MnfGenerator.new(@config, @cmy_tesry_dirs)
      @new_manifests = mnf_generator.execute

      # ビルドディレクトリ作成
      generate_build_dir

      # 状態管理ファイルの削除
      Dir.glob("#{@root_dir}/*.dat"){|file|
        FileUtils.remove(file)
      }

    elsif @build_libkernel_mode
      # tesryコピー用(libkernel作成用)ディレクトリ作成
      FileUtils.mkdir_p(@tesry_dir)

      # オプションの確認(use_libkernel_yml)
      if !@use_libkernel_yml
        # オプションがなければエラーログを出力して強制終了
        
      end

      # TESRY代替のビルド用YAMLファイルを指定し、ビルド環境にコピー
      target_yml   = @aktsp_dir + "/" + @target_libkernel_yml
      FileUtils.copy(target_yml, @tesry_dir)

      # コピー先のディレクトリをMnfGeneratorに渡し、マニフェストを生成
      mnf_generator = MnfGenerator.new(@config, @tesry_dir)
      @new_manifests = mnf_generator.execute
      
      # ビルドディレクトリ作成
      generate_build_dir
      
    end

    # ビルド・実行処理
    build_and_execute

    # 終了ログ
    AktbLog.instance.info("<<< AKTSP FINISH >>>")
  end

  #=====================================================================
  # テストケースがまとめられたCMYファイルを個別のYAMLファイルに分解
  #=====================================================================
  def divide_cmy
    AktbLog.instance.info("[divide_cmy] START")

    # 格納用ディレクトリを作成の上で、YAMLファイルを格納
    Dir::glob(@cmy_dir).each {|f|
      cmy_tesry_dir = @tesry_dir + "/" + File.basename(f, ".cmy")
      @cmy_tesry_dirs << cmy_tesry_dir
      FileUtils.mkdir_p(cmy_tesry_dir)
      Dir.chdir(cmy_tesry_dir) {
        pid = spawn("#{CMD_RUBY} #{@aktsp_dir}/tools/akc2y/akc2y.rb -d #{f}")
        thr = Process.wait(pid)
      }
    }
    AktbLog.instance.info("[divide_cmy] FINISH")
  end

  #=====================================================================
  # ビルド・実行用ディレクトリを作成
  #=====================================================================
  def generate_build_dir()
    AktbLog.instance.info("[generate_build_dir] START")
    @new_manifests.each{|new_manifest|
      new_manifest_dir = new_manifest.gsub("MNF_", "")
      FileUtils.mkdir_p(new_manifest_dir)
      FileUtils.move(new_manifest, new_manifest_dir + "/" + File.basename(new_manifest))
    }
    AktbLog.instance.info("[generate_force_merge_dir] FINISH")
  end

  #=====================================================================
  # ビルド・実行スレッドを起動
  #=====================================================================
  def build_and_execute

    AktbLog.instance.info("[build_and_execute] START")

    if @exec_mode
      executer = Executer.new(@config)
    end

    if @build_mode
      queue = Queue.new
      @max_threads.times {
        queue.push(:lock)
      }
      builder_hash = {}
      building_list = []
      counter = 0
      Dir.entries(@root_dir).each{|file|

        if (File::ftype("#{@root_dir}/#{file}") == "directory") \
            and ("#{@root_dir}/#{file}" !~ /\.+$/)  \
            and check_status("#{@root_dir}/#{file}")

          building_list << AKTBBuilder.new(file, queue, @config)
          counter = counter + 1
          if counter % 500 == 0
            ThreadsWait.all_waits(*building_list)
            building_list = []
          end
        end
      }
      ThreadsWait.all_waits(*building_list)

    end

    if @exec_mode
      executer.join
    end

    # 終了後処理:ディレクトリ数をカウント
    disp_count

    AktbLog.instance.info("[build_and_execute] FINISH")
  end

  #=====================================================================
  # ステータス確認(ビルド可能かどうか)
  #=====================================================================
  def check_status(target_dir)
    !File.exist?("#{target_dir}_post_make_build.dat") and \
    !File.exist?("#{target_dir}_ng.dat") and \
    !File.exist?("#{target_dir}_fail.dat") and \
    !File.exist?("#{target_dir}_finish.dat") and \
    !File.exist?("#{target_dir}_fail_build.dat") 
  end

  #=====================================================================
  # 成功・失敗数を出力
  #=====================================================================
  def disp_count
    all_count = 0
    Dir.entries(@root_dir).each{|file|
      if (File::ftype("#{@root_dir}/#{file}") == "directory") and "#{@root_dir}/#{file}" !~ /\.+$/
        all_count = all_count + 1
      end
    }
    all_dat_count        = Dir::glob("#{@root_dir}/*.dat").count
    finished_count       = Dir::glob("#{@root_dir}/*finish.dat").count
    ng_count             = Dir::glob("#{@root_dir}/*ng.dat").count
    failed_count         = Dir::glob("#{@root_dir}/*fail.dat").count
    build_failed_count   = Dir::glob("#{@root_dir}/*fail_build.dat").count

    AktbLog.instance.info("Test Case : #{all_dat_count}")
    AktbLog.instance.info("OK : #{finished_count}")
    AktbLog.instance.info("NG : #{ng_count}")
    AktbLog.instance.info("EXEC FAILED : #{failed_count}")
    AktbLog.instance.info("BUILD FAILED : #{build_failed_count}")
  end
end

#=====================================================================
# 起動処理(オプション解析含)
#=====================================================================
# 起動オプションの読取り
aktg_cfg = {}
params = ARGV.getopts("c:", "conf:", "[no-]createdir", "[no-]build", "[no-]exec", "build_libkernel")

# 起動オプション:設定ファイル(デフォルト:aktb.yml)
if params["conf"]
  aktg_cfg["cfg_file"] = params["conf"]
elsif params["c"]
  aktg_cfg["cfg_file"] = params["c"]
else
  aktg_cfg["cfg_file"] = 'aktb.yml'
end

# 起動オプション:ディレクトリ作成処理の有効/無効(デフォルト:有効)
aktg_cfg["create_dir_mode"] = params["createdir"]
if aktg_cfg["create_dir_mode"].nil?
  aktg_cfg["create_dir_mode"] = true
end

# 起動オプション:ビルド処理の有効/無効(デフォルト:有効)
aktg_cfg["build_mode"] = params["build"]
if aktg_cfg["build_mode"].nil?
  aktg_cfg["build_mode"] = true
end

# 起動オプション:実行処理の有効/無効(デフォルト:有効)
aktg_cfg["exec_mode"] = params["exec"]
if aktg_cfg["exec_mode"].nil?
  aktg_cfg["exec_mode"] = true
end

# 起動オプション:カーネルライブラリビルド実行の有効/無効(デフォルト:無効)
aktg_cfg["build_libkernel_mode"] = params["build_libkernel"]
if aktg_cfg["build_libkernel_mode"].nil?
  aktg_cfg["build_libkernel_mode"] = false
end
# カーネルライブラリビルド有効の場合、この処理とビルド処理のみが有効になる
if aktg_cfg["build_libkernel_mode"]
  aktg_cfg["create_dir_mode"] = false
  aktg_cfg["build_mode"] = true
  aktg_cfg["exec_mode"] = false
end

# ctrl+cによる強制終了設定
Signal.trap(:SIGINT){
  system("kill -9 #$$")
}


# AKTBクラスの起動処理
aktb = AKTB.new(aktg_cfg)
aktb.main

