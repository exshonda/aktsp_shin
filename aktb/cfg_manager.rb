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
# configure実行管理クラス
#
#=======================================================================
class CfgManager

  #=====================================================================
  # 各実行バイナリのパス
  #=====================================================================
  PERL_BIN = "/usr/bin/perl"

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj)

    if @aktb_config != nil
      return
    end

    @aktb_config = cfg_obj

    @auto_dir_ladder        = @aktb_config["auto_dir_ladder"]
    @kernel_path            = @aktb_config["kernel_path"]
    @configure_bin          = "#{@auto_dir_ladder}#{@kernel_path}/configure"

    @use_hwcounter          = @aktb_config["use_hwcounter"]
    @use_application_name   = @aktb_config["use_application_name"]
    @use_configuration_name = @aktb_config["use_configuration_name"]
    @use_kernel_library     = @aktb_config["use_kernel_library"]
    @use_other_library      = @aktb_config["use_other_library"]
    @use_compile_option     = @aktb_config["use_compile_option"]
    @use_symbol_definition_option     = @aktb_config["use_symbol_definition_option"]

    @target_name            = @aktb_config["target_name"]
    if @use_application_name
      @application_name     = @aktb_config["application_name"]
    end
    if @use_configuration_name
      @configuration_name   = @aktb_config["configuration_name"].join(" ")
    end
    if @use_other_library
      @other_library        = @aktb_config["other_library"].join(" ")
    end
    if @use_compile_option
      @compile_option       = @aktb_config["compile_option"].join(" ")
    end

    if @use_symbol_definition_option 
      @symbol_definition_option    = @aktb_config["symbol_definition_option"].join(" ")
    end

    @include_target         = @aktb_config["include_target"]
    @cfg_include = ""
    @include_target.each{|include|
      @cfg_include << @auto_dir_ladder
      @cfg_include << include
      @cfg_include << " "
    }

    if @use_kernel_library
      @kernel_library       = @auto_dir_ladder + @aktb_config["kernel_library"]
    end
    
    generate_option

  end

  #=====================================================================
  # configure用オプション生成処理
  #=====================================================================
  def generate_option

    if @configure_option != nil
      return
    end

    @configure_option = ""

    # ハードウェアカウンタ有効化
    if @aktb_config["use_hwcounter"]
      @configure_option << "-h"
      @configure_option << " "
    end
    
    # ターゲット名
    @configure_option << "-T #{@target_name}"
    @configure_option << " "
    
    # アプリケーションプログラム名
    if @use_application_name
      @configure_option << "-A #{@application_name}"
      @configure_option << " "
    end
    
    # コンフィギュレーションファイル名
    if @use_configuration_name
      @configure_option << "-C \'#{@configuration_name}\'"
      @configure_option << " "
    end

    # カーネルライブラリのパス
    if @use_kernel_library
      @configure_option << "-L  \'#{@kernel_library}\'"
      @configure_option << " "
    end

    # 他のアプリケーションプログラムファイル
    if @use_other_library
      @configure_option << "-U \'#{@other_library}\'"
      @configure_option << " "
    end

    # 共通コンパイルオプション（COPTSに追加）
    if @use_compile_option
      @configure_option << "-o \'#{@compile_option}\'"
      @configure_option << " "
    end

    # 共通シンボル定義オプション（CDEFSに追加）
    if @use_symbol_definition_option
      @configure_option << "-O \'#{@symbol_definition_option}\'"
      @configure_option << " "
    end

    # アプリケーションのディレクトリ名
    @configure_option << "-a \'#{@cfg_include}\'"
    @configure_option << " "
  end

  #=====================================================================
  # configure実行
  #=====================================================================
  def execute(exec_dir)
    AktbLog.instance.debug("#{PERL_BIN} #{@configure_bin} #{@configure_option} > #{exec_dir}/result_configure.log 2>&1")
    system("#{PERL_BIN} #{@configure_bin} #{@configure_option} > #{exec_dir}/result_configure.log 2>&1", \
           :chdir=>exec_dir)
  end

end
