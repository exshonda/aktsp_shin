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

  RUBY_BIN                 = "/usr/local/ruby/bin/ruby"
  PYTHON_BIN               = "/usr/bin/python"
  NIOS2_SRV_GO_W2_CMD      = "nios2-gdb-server --cable=USB-Blaster --instance=0 --no-verify --go --wait 5"
  ATK2_NIOS2_COM_PATH      = "/target/nios2_dev_gcc/com_port.rb"

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj)

    # 設定ファイル
    @config = cfg_obj

    # AKTSPで使用するディレクトリ
    @aktsp_dir = `pwd`.chomp + "/../"
    @root_dir  = @aktsp_dir + @config["obj_root_path"]
    @kernel_dir = @aktsp_dir + "/" + @config["kernel_path"]

    # 最大実行時間
    @g_max_exec_time = @config["max_exec_time"]

    # 生成されるターゲットモジュール名
    @g_target_bin = @config["target_bin"]

    # Target(NIOS2)で使用するコマンド
    @g_target_exec_cmd = @config["target_exec_cmd"]
    # COMポート経由でデータをDLするコマンド
    #@g_target_log_cmd  = "#{RUBY_BIN} #{@aktsp_dir}library/arch/v850/common/com_port.rb"
    @g_target_log_cmd_core0  = "#{PYTHON_BIN} #{@aktsp_dir}../com_port_core0.py"
    @g_target_log_cmd_core1  = "#{PYTHON_BIN} #{@aktsp_dir}../com_port_core1.py"

    @g_target_mcu = "R7F701503" # TODO depend on target
    @g_target_main_clk = "16000" # TODO depend on target
    @g_target_cs_type = "CC" # TODO depend on target

    #
    # CS+の実行ファイルパス
    #
    @cs_path="/cygdrive/c/Program\\ Files/Renesas\\ Electronics/CS+/#{@g_target_cs_type}:/cygdrive/c/Program\\ Files\\ \\(x86\\)/Renesas\\ Electronics/CS+/#{@g_target_cs_type}"

    #
    # 使用するCS+プロジェクトファイル
    #
    if @g_target_cs_type == "CACX"
        @cs_prj="run_cx"
    else
        @cs_prj="run_ccrh"
    end

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
    # all_count = count_dir(@root_dir, "^auto_code_[0-9]+$")
    all_count = 0
    Dir.entries(@root_dir).each{|file|
      if (File::ftype("#{@root_dir}/#{file}") == "directory") and "#{@root_dir}/#{file}" !~ /\.+$/
        all_count = all_count + 1
      end
    }

    AktbLog.instance.info("[target->all:#{all_count}]")
    exec_count = 0

    while(all_count > exec_count)

      Dir.entries(@root_dir).each{|file|
        # if file =~ /^(auto_code_\d+)_post_make_build\.dat/
        if file =~ /^(\w+)_post_make_build\.dat/
          execute($1)
          sleep 4
          #download_log($1)

          finished_count =  Dir::glob("#{@root_dir}/*finish.dat").count
          ng_count       =  Dir::glob("#{@root_dir}/*ng.dat").count
          failed_count   =  Dir::glob("#{@root_dir}/*fail.dat").count
          exec_count = finished_count + ng_count + failed_count
          AktbLog.instance.info("[target->all:#{all_count},exec:#{exec_count}]")
        end
      }
      sleep 1
    end
    AktbLog.instance.info("[target] FINISH")
  end

  #=====================================================================
  # Target転送処理
  #=====================================================================
  def execute(num)
    AktbLog.instance.info("[target:download:#{num}] START")
    auto_dir = @root_dir + "/" + num
  
    post_make_build_file = "#{auto_dir}_post_make_build.dat"
    finish_file          = "#{auto_dir}_finish.dat"
    ng_file              = "#{auto_dir}_ng.dat"
    fail_file            = "#{auto_dir}_fail.dat"

    exec_log_core0 = "#{auto_dir}/result_execute_core0.log"
    exec_log_core1 = "#{auto_dir}/result_execute_core1.log"
    thLogs = []
    pid1 = Process::spawn(@g_target_log_cmd_core0+" "+exec_log_core0)
    thLogs << Process::detach(pid1)
    pid2 = Process::spawn(@g_target_log_cmd_core1+" "+exec_log_core1)
    thLogs << Process::detach(pid2)
    sleep 1

    AktbLog.instance.info("[target:exec:#{num}] START")
    # exec_cmd = @g_target_exec_cmd + " " + auto_dir + "\/" + @g_target_bin
    exec_log2 = "#{auto_dir}/result_execute1.log"
    mod = "C:/cygwin#{auto_dir}/#{@g_target_bin}"
    File.open(@aktsp_dir + "library/arch/v850/common/run.py", "r") { |fin|
        buf = fin.read.gsub(/OBJECT_FILE_PATH/, mod)
        # CCの場合シンボル先頭に"_"を付与する
        if @cs_type == "CC"
            buf.gsub!(/AktspInfiniteLoop/, "_AktspInfiniteLoop")
            buf.gsub!(/infinite_loop/, "_infinite_loop")
        end
        File.open("#{auto_dir}/cube_suite.py", "w") { |fout|
            fout.write(buf)
        }
    }
    cspy = IO.popen("cygpath -w #{auto_dir}/cube_suite.py", "r") {|io|
        io.read
    }
    File.open(@aktsp_dir + "library/arch/v850/common/#{@cs_prj}.mtpj", "r")  { |fin|
        buf = fin.read.gsub(/AKTSP_MCU_NAME/, @g_target_mcu)
        buf.gsub!(/AKTSP_MAIN_CLK/, @g_target_main_clk)
        File.open("#{auto_dir}/cs_prj.mtpj", "w")  { |fout|
            fout.write(buf)
        }
    }
    csprj = IO.popen("cygpath -w #{auto_dir}/cs_prj.mtpj", "r") {|io|
        io.read
    }
	exec_cmd = "export PATH=\$PATH:#{@cs_path}; CubeSuite+.exe /ps \"#{cspy.chomp}\" \"#{csprj.chomp}\""
    system(exec_cmd)
=begin
    pid2 = -1
    begin
        pid2 = spawn(exec_cmd, :out=>exec_log2, :pgroup =>true)
      thr = Process.detach(pid2)
      Timeout.timeout(300) {
        thr.join
      }
    rescue Timeout::Error
      while (true)
        begin
          Process::kill(:TERM, pid2)
        rescue
        end
        if !exists_process(pid2)
          break
        end
      end
    end
=end
    AktbLog.instance.info("[target:exec:#{num}] FINISH")

    thLogs.each { |t|
        t.join(60)
    }

    flag = false
    exec_time_count = 0
=begin
    while(!flag)
      sleep 1
      exec_time_count = exec_time_count + 1
      if !File.readlines(exec_log_core0).grep(/Kernel Exit/).empty? \
          && !File.readlines(exec_log_core1).grep(/Kernel Exit/).empty?
        flag = true
        if !File.readlines(exec_log_core0).grep(/All check points passed/).empty? \
          || !File.readlines(exec_log_core1).grep(/All check points passed/).empty?
          FileUtils.move(post_make_build_file, finish_file)
        else
          FileUtils.move(post_make_build_file, ng_file)
        end
      elsif exec_time_count > @g_max_exec_time
        flag = true
        FileUtils.move(post_make_build_file, fail_file)
      end
    end
=end
    if !File.readlines(exec_log_core0).grep(/Kernel Exit/).empty? \
        && !File.readlines(exec_log_core1).grep(/Kernel Exit/).empty?
      if !File.readlines(exec_log_core0).grep(/All check points passed/).empty? \
        || !File.readlines(exec_log_core1).grep(/All check points passed/).empty?
        FileUtils.move(post_make_build_file, finish_file)
      else
        FileUtils.move(post_make_build_file, ng_file)
      end
    else
        flag = true
        FileUtils.move(post_make_build_file, fail_file)
    end
    # 実行プロセス(com_port.py)をkill
    begin
        Process::kill("KILL", pid1)
    rescue
        # 子プロセス(com_port.py)側で終了している場合にはkillで
        # 例外となるためここでrescueする
    end
    begin
        Process::kill("KILL", pid2)
    rescue
        # 子プロセス(com_port.py)側で終了している場合にはkillで
        # 例外となるためここでrescueする
    end

    #t_pid = spawn("tset -I")
    #Process::detach(t_pid)

    AktbLog.instance.info("[target:download:#{num}] FINISH")

  end

  #=====================================================================
  # ログ取得処理
  #=====================================================================
  def download_log(num)

    AktbLog.instance.info("[target:download:#{num}] START")
    auto_dir = @root_dir + "/" + num
  
    post_make_build_file = "#{auto_dir}_post_make_build.dat"
    finish_file          = "#{auto_dir}_finish.dat"
    ng_file              = "#{auto_dir}_ng.dat"
    fail_file            = "#{auto_dir}_fail.dat"

    exec_log = "#{auto_dir}/result_execute2.log"
    pid = Process::spawn(@g_target_log_cmd, :err=>:out, :out=>exec_log)
    Process::detach(pid)

    flag = false
    exec_time_count = 0
    while(!flag)
      sleep 1
      exec_time_count = exec_time_count + 1
      if !File.readlines(exec_log).grep(/Kernel Exit/).empty?
        flag = true
        if !File.readlines(exec_log).grep(/All check points passed/).empty?
          FileUtils.move(post_make_build_file, finish_file)
        else
          FileUtils.move(post_make_build_file, ng_file)
        end
      elsif exec_time_count > @g_max_exec_time
        flag = true
        FileUtils.move(post_make_build_file, fail_file)
      end
    end
    Process::kill("TERM", pid)
    t_pid = spawn("tset -I")
    Process::detach(t_pid)

    AktbLog.instance.info("[target:download:#{num}] FINISH")
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
