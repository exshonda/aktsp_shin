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

require 'fileutils'

#=======================================================================
#
# make実行管理クラス
#
#=======================================================================
class MakeManager

  #=====================================================================
  # 各実行バイナリのパス
  #=====================================================================
  MAKE_BIN = "/usr/bin/make"

  #=====================================================================
  # getter/setter
  #=====================================================================
  attr_writer :makebuild_option
  attr_writer :make_option

  #=====================================================================
  # 初期化処理
  #=====================================================================
  def initialize(cfg_obj)

    # 2回目以降はこの処理を実行しない
    if @aktb_config != nil
      return
    end

    @aktb_config = cfg_obj

    @makefile_name = ""
    @make_option   = ""
    @makebuild_option =""

    generate_option
  end

  #=====================================================================
  # Make用オプション生成処理
  #=====================================================================
  def generate_option

    # 本メソッドは"XXX=AAA"形式のオプションを設定ファイル経由で読み込む
    # ケースのみを想定する
    # -f などのオプションはAktgManagerのForce Mergeオプションを参考として、
    # 本メソッドを拡張するか、本クラスのインスタンスに対して、makebuild_option
    # make_optionのsetterメソッドで直接上書きするかにより対応すること

    # Makeオプションの追加
    aktb_config_keys = @aktb_config.keys
    aktb_config_keys.each do |aktb_key|

      # 設定ファイル内で"make_"で始まる設定項目
      if aktb_key =~ /^make_(\w+)/
        @make_option << " #{$1}=#{@aktb_config[aktb_key]}"
      end
      # 設定ファイル内で"makebuild_"で始まる設定項目
      if aktb_key =~ /^makebuild_(\w+)/
        @makebuild_option << " #{$1}=#{@aktb_config[aktb_key]}"
      end
      
    end
  end

  #=====================================================================
  # make depend
  #=====================================================================
  def execute_depend(exec_dir)
    md_log = "#{exec_dir}/result_make_depend.log"
    FileUtils.touch(md_log)

    AktbLog.instance.debug("#{MAKE_BIN} depend #{@make_option} > #{md_log} 2>&1")
    system("#{MAKE_BIN} depend #{@make_option} > #{md_log} 2>&1", :chdir=>exec_dir)
  end

  #=====================================================================
  # make
  #=====================================================================
  def execute_build(exec_dir)
    mb_log = "#{exec_dir}/result_make.log"
    FileUtils.touch(mb_log)

    AktbLog.instance.debug("#{MAKE_BIN} #{@make_option} #{@makebuild_option} > #{mb_log} 2>&1")
    system("#{MAKE_BIN} #{@make_option} #{@makebuild_option} > #{mb_log} 2>&1", :chdir=>exec_dir)
  end

  #=====================================================================
  # make clean
  #=====================================================================
  def execute_clean(exec_dir)
    AktbLog.instance.debug("#{MAKE_BIN} clean 2>&1 > /dev/null")
    system("#{MAKE_BIN} clean 2>&1 > /dev/null", :chdir=>exec_dir)
  end

  #=====================================================================
  # make realclean
  #=====================================================================
  def execute_realclean(exec_dir)
    AktbLog.instance.debug("#{MAKE_BIN} realclean 2>&1 > /dev/null")
    system("#{MAKE_BIN} realclean 2>&1 > /dev/null", :chdir=>exec_dir)
  end
end
