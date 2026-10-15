#!/usr/bin/ruby
#
# AKTB
#      Automotive Kernel Test Builder
#
# Copyright (C) 2011-2016 by Center for Embedded Computing Systems
#               Graduate School of Information Science, Nagoya Univ., JAPAN
# Copyright (C) 2014-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
# Copyright (C) 2014-2016 by eSOL Co.,Ltd., JAPAN
# Copyright (C) 2011-2016 by FUJI SOFT INCORPORATED, JAPAN
# Copyright (C) 2014-2016 by Fujitsu TEN Limited
# Copyright (C) 2014-2016 by JTEKT CORPORATION
# Copyright (C) 2011-2016 by NEC Communication Systems, Ltd., JAPAN
# Copyright (C) 2011-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
# Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
# Copyright (C) 2014-2016 by SCSK Corporation, JAPAN
# Copyright (C) 2011-2013 by Spansion LLC, USA
# Copyright (C) 2011-2016 by Sunny Giken Inc., JAPAN
# Copyright (C) 2011-2016 by TOSHIBA CORPORATION, JAPAN
# Copyright (C) 2011-2016 by Witz Corporation
# Copyright (C) 2015-2016 by SUZUKI MOTOR CORPORATION
#
# 本ソフトウェアは，車載制御システム向け高品質プラットフォームに
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
require 'aktb_log.rb'
#require 'downloader_nios2_mc_blaster.rb'
#require 'downloader_nios2_mc_uart.rb'

require 'timeout'
require 'yaml'
require 'fileutils'
require 'thread'

#=======================================================================
#
# モジュール実行用クラス(Nios II)
#
#=======================================================================
class Executer < Thread

  NIOS2_SRV_STOP_CMD = "nios2-gdb-server --cable=USB-Blaster --instance=XXX --no-verify -r --stop"
  NIOS2_SRV_GO_CMD   = "nios2-gdb-server --cable=USB-Blaster --instance=XXX --no-verify --go --wait 3"

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj)

    # 設定ファイル
    @config = cfg_obj

    # AKTSPで使用するディレクトリ
    @aktsp_dir = `pwd`.chomp + "/../"
    @root_dir  = @aktsp_dir + @config["obj_root_path"]
    
    # 使用する通信線によって実行するクラスを読み替える
    require @config["downloader_module"]
    
    # 最大実行時間
    @g_max_exec_time = @config["max_exec_time"]

    # 生成されるターゲットモジュール名
    @g_target_bin = @config["target_bin"]
    
    # コア数
    @core_num = @config["core_num"]
    
    block = Proc.new{
      main
    }
    super(&block)
  end


  #=====================================================================
  # 未実行のビルド・実行用ディレクトリを検索し、実行処理を開始
  #=====================================================================
  def main
    AktbLog.instance.info("[target] START")
    all_count = 0
    Dir.entries(@root_dir).each{|file|
      if (File::ftype("#{@root_dir}/#{file}") == "directory") and "#{@root_dir}/#{file}" !~ /\.+$/
        all_count = all_count + 1
      end
    }

    AktbLog.instance.info("[target->all:#{all_count}]")
    exec_count = 0
    build_failed_count = 0
    while(all_count > (exec_count + build_failed_count))

      finished_count =  Dir::glob("#{@root_dir}/*finish.dat").count
      ng_count       =  Dir::glob("#{@root_dir}/*ng.dat").count
      failed_count   =  Dir::glob("#{@root_dir}/*fail.dat").count
      build_failed_count = Dir::glob("#{@root_dir}/*fail_build.dat").count
      exec_count = finished_count + ng_count + failed_count
 
      Dir.entries(@root_dir).each{|file|
        if file =~ /^(\w+)_post_make_build\.dat/
          process($1)

          finished_count =  Dir::glob("#{@root_dir}/*finish.dat").count
          ng_count       =  Dir::glob("#{@root_dir}/*ng.dat").count
          failed_count   =  Dir::glob("#{@root_dir}/*fail.dat").count
          build_failed_count = Dir::glob("#{@root_dir}/*fail_build.dat").count
          exec_count = finished_count + ng_count + failed_count
          AktbLog.instance.info("[target->all:#{all_count},exec:#{exec_count}]")
        end
      }
      sleep 1
    end
    AktbLog.instance.info("[target] FINISH")
  end


  #=====================================================================
  # 実行プロセス
  #=====================================================================
  def process(target_dir)
  
    AktbLog.instance.info("[target:exec:#{target_dir}] START")
    exec_dir = @root_dir + "/" + target_dir

    post_make_build_file = "#{exec_dir}_post_make_build.dat"
    finish_file          = "#{exec_dir}_finish.dat"
    ng_file              = "#{exec_dir}_ng.dat"
    fail_file            = "#{exec_dir}_fail.dat"

    # ログファイルの初期化
    (0..(@core_num - 1)).each { |core_id|
      File.open("#{exec_dir}/result_execute_core#{core_id}.log", "w+").puts
    }

    # モジュールの存在チェック
    module_path = exec_dir + "/" + @g_target_bin
    if !File.exist?(module_path)
      AktbLog.instance.warn("[target:exec:#{target_dir}] Build Failure")
      FileUtils.move(post_make_build_file, fail_file)
      AktbLog.instance.info("[target:exec:#{target_dir}] FINISH")
      return
    end

    upload_pid_thr = []
    # モジュールのアップロード / STOPコマンド実行
    (0..(@core_num - 1)).each { |core_id|
      if core_id == 0
        upload_pid_thr  << execute(exec_dir, NIOS2_SRV_STOP_CMD + " " + exec_dir + "/" + @g_target_bin, core_id)
      else
        upload_pid_thr << execute(exec_dir, NIOS2_SRV_STOP_CMD, core_id)
      end
    }

    begin
    # アップロード完了を待機
      Timeout.timeout(300) {
          upload_pid_thr.each { |pid_thr|
              pid_thr[1].join
          }
      }
    rescue Timeout::Error
      upload_pid_thr.each { |pid_thr|
        begin
          Process::kill(:TERM, pid_thr[0])
        rescue
        end
        if !exists_process(pid_thr[0])
          break
        end
      }
    end

    puts "upload complete."
    execute_pid_thr = []
    # GOコマンド実行
    (0..(@core_num - 1)).each { |core_id|
      execute_pid_thr << execute(exec_dir, NIOS2_SRV_GO_CMD, core_id)
    }

    # nios2-terminalコマンドを完全同時に起動してはならない→1秒waitを挟む
    downloader = []
    (0..(@core_num - 1)).each { |core_id|
      downloader[core_id] = Downloader.new(@config, target_dir, core_id)
      sleep 1
    }

    begin
    # 実行完了を待機
      Timeout.timeout(300) {
          execute_pid_thr.each { |pid_thr|
              pid_thr[1].join
          }
      }
    rescue Timeout::Error
      upload_pid_thr.each { |pid_thr|
        begin
          Process::kill(:TERM, pid_thr[0])
        rescue
        end
        if !exists_process(pid_thr[0])
          break
        end
      }
    end
    puts "exec complete. waiting log download..."

    # スレッド実行を待機
    downloader.each { |dl|
      dl.join
    }

    # 結果判定 : いずれかの結果でOKが出れば成功/出なければ失敗とみなす
    success = false
    downloader.each { |dl|
      if dl.result == "OK"
        success = true
      end
    }

    if success
      AktbLog.instance.info("[target:exec:#{target_dir}] OK")
      FileUtils.move(post_make_build_file, finish_file)
    else
      AktbLog.instance.warn("[target:exec:#{target_dir}] NG")
      FileUtils.move(post_make_build_file, ng_file)
    end
    AktbLog.instance.info("[target:exec:#{target_dir}] FINISH")
  end

  #=====================================================================
  # Target転送処理
  # @return [exec_cmdを実行するプロセスID, そのプロセスを監視するスレッド]
  #=====================================================================
  def execute(exec_dir, exec_cmd, core_id)
  
    exec_log = "#{exec_dir}/result_load_core#{core_id}.log"
    pid = -1
    begin
      pid = spawn(exec_cmd.gsub("XXX", core_id.to_s), :out=>[exec_log, "a+"], :pgroup =>true)
      thr = Process.detach(pid)
=begin
    # ここで実行完了を待っていると，ログを出し終わったあとでcom_port.rbが起動し，
    # ログを取得できないため，待たない
      Timeout.timeout(300) {
        thr.join
      }
      
    rescue Timeout::Error
      while (true)
        begin
          Process::kill(:TERM, pid)
        rescue
        end
        if !exists_process(pid)
          break
        end
      end
=end
    end
    t_pid = spawn("tset -I")
    Process::detach(t_pid)
    File.open(exec_log, "a+") { |file|
      file.puts
      file.puts
    }

    return [pid, thr]
  end

  #=====================================================================
  # 正規表現の条件を満たすディレクトリの数をカウント
  #=====================================================================
  def count_dir(target_dir, file_regexp)
    count = 0
    Dir.entries(target_dir).each{|file|
      if file =~ /#{file_regexp}/
        count = count + 1
      end
    }
    return count
  end

  #=====================================================================
  # プロセスの起動確認
  #=====================================================================
  def exists_process(pid)
    begin
      pgid = Process.getpgid(pid)
      return true
    rescue 
      return false
    end
  end

end
