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

#=======================================================================
#
# AKTG実行管理クラス
#
#=======================================================================
class AktgManager

  #=====================================================================
  # 各実行バイナリのパス
  #=====================================================================
  RUBY_BIN = "/usr/bin/ruby"

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj)

    # 2回目以降はこの処理を実行しない
    if @aktb_config != nil
      return
    end

    @aktb_config = cfg_obj
    @aktsp_dir   = `pwd`.chomp + "/../"
    @aktg_bin    = "#{@aktsp_dir}#{@aktb_config["tool_aktg_bin"]}"
    
    generate_option
  end

  #=====================================================================
  # AKTG用オプション生成処理
  #=====================================================================
  def generate_option
    # AKTGのオプションを生成
    @aktg_option = ""

    scalability_class      = @aktb_config["scalability_class"]
    core_num               = @aktb_config["core_num"]
    use_multi_core         = @aktb_config["use_multi_core"]
    use_time_partitioning  = @aktb_config["use_time_partitioning"]
    
    # ymlでconfigure_pathを設定している場合，オプションに追加
    if !(@aktb_config["configure_path"].nil?())
      @configure_path = @aktsp_dir + @aktb_config["configure_path"]
      # configure.yamlディレクトリパスの追加
      @aktg_option << " -c #{@configure_path}"
    end

    if (use_time_partitioning.nil?())
      use_time_partitioning  = false
    end

    # スケーラビリティクラス
    @aktg_option << " --scalability_class #{scalability_class}"
    
    # コア数
    @aktg_option << " --core_num #{core_num}"

    # マルチコア使用の有無
    @aktg_option << " --use_multi_core #{use_multi_core}"
    
    # TP機能の有無
    @aktg_option << " --use_time_partitioning #{use_time_partitioning}"


    # AKTG固有パラメータの追加
    aktb_config_keys = @aktb_config.keys
    aktb_config_keys.each do |aktb_key|

      # 設定ファイル内で"aktg_"で始まる設定項目
      if aktb_key =~ /^aktg_(\w+)/
        @aktg_option << " --#{$1}"
        @aktg_option << " #{@aktb_config[aktb_key]}"
      elsif aktb_key =~ /^use_force_merge/
        if @aktb_config[aktb_key]
          @aktg_option << " -f"
        end
      elsif aktb_key =~ /^use_cpptest/
        if @aktb_config[aktb_key]
          @aktg_option << " -h"
        end
      end
    end
  end

  #=====================================================================
  # AKTG実行
  #=====================================================================
  def execute(exec_dir)
    status = false
    
    # ディレクトリ内でワイルドカード検索を実施→ひっかかった1件分のみ実行
    # AKTGは本来単一ディレクトリ上で2回以上実行することを前提としていない
    Dir.glob("#{exec_dir}/MNF_*").each{ |manifest| 
      yaml_files = File.open(manifest).readlines
      yaml_files.each{|y|
        y.chomp!
      }
      yaml_files = yaml_files.join(" ")
    
      # Kernel#spawn経由でAKTGを実行すると失敗するため、systemに移行
      AktbLog.instance.debug("#{RUBY_BIN} #{@aktg_bin} #{@aktg_option} #{yaml_files} > #{exec_dir}/result_aktg.log 2>&1")
      status = system("#{RUBY_BIN} #{@aktg_bin} #{@aktg_option} #{yaml_files} > #{exec_dir}/result_aktg.log 2>&1", :chdir=>exec_dir)
      break
    }
    status
  end
end
