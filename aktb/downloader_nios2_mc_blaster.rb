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
require 'aktb_log.rb'

class Downloader < Thread

  #=====================================================================
  # 定数
  #=====================================================================
  NIOS2_TERM_CMD     = "nios2-terminal --cable=USB-Blaster --instance=XXX -q &"

  #=====================================================================
  # getter/setter
  #=====================================================================
  attr_reader :result

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj, target_dir, core_id)

    # 設定ファイル
    @config = cfg_obj

    # AKTSPで使用するディレクトリ
    @aktsp_dir = `pwd`.chomp + "/../"
    @root_dir  = @aktsp_dir + @config["obj_root_path"]

    # 最大実行時間
    @g_max_exec_time = @config["max_exec_time"]

    # 現在の実行状態(開始前→実行中→終了)を保持
    @exec_status = "PRE_EXEC"

    # 結果(OK, NG, 実行失敗, 未決定)を保持
    @result = "UNSET"

    block = Proc.new{
      download_log(target_dir, core_id)
    }
    super(&block)
  end

  #=====================================================================
  # ログ取得処理
  #=====================================================================
  def download_log(target_dir, core_id)

    AktbLog.instance.info("[target:download:#{target_dir}:#{core_id}] START")
    exec_dir = @root_dir + "/" + target_dir

    exec_log = "#{exec_dir}/result_execute_core#{core_id}.log"
    pid = Process::spawn(NIOS2_TERM_CMD.gsub("XXX", core_id.to_s), :err=>:out, :out=>[exec_log, "a+"], :pgroup =>true)

    @exec_status = "IN_EXEC"
    exec_time_count = 0
    while(@exec_status != "POST_EXEC")
      sleep 1
      exec_time_count = exec_time_count + 1
      if exec_log_check(exec_log, "Kernel Exit")
        @exec_status = "POST_EXEC"
        if exec_log_check(exec_log, "All check points passed")
          @result = "OK"
        else
          @result = "NOT_OK"
        end
      elsif exec_time_count > @g_max_exec_time
        @exec_status = "POST_EXEC"
        @result = "EXEC_FAILURE"
        break
      end
    end

    # 実行プロセス(nios2-terminal)をkill
    Process::detach(pid)
    Process::kill("TERM", -pid)

    # 制御をコンソールに戻す
    t_pid = spawn("tset -I")
    Process::detach(t_pid)

    AktbLog.instance.info("[target:download:#{target_dir}:#{core_id}] FINISH")
  end
  
  def exec_log_check(exec_log, check_string)
    found_flg = false
    File.open(exec_log){|file|
      file.each_line{|line|
        line.encode!('ISO-8859-1', :encoding=>:replace, :undef=>:replace)
        if line =~ /#{check_string}/
          found_flg = true
        end
      }
    }
    found_flg
  end
end
