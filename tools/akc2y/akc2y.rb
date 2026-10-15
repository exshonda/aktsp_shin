#!ruby -Ke
#
# akc2y
#      Automotive Kernel CSV to YAML converter
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
# $Id: akc2y.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# 引数に与えられたCSVを，YAMLへ変換する．
# 使用方法は，システムサービステストの開発および実施要綱
# (aktsp/syssrv_test/developer.txt)を参照する．
# また，大量のYAMLファイルをSVNへコミットすることを避けるため，
# 1つのYAMLファイル(CMY)として結合する機能，および分割する機能も有する
#=====================================================================
require "csv.rb"
require "pp.rb"
require "optparse.rb"

# パラメータ解釈識別子定義
TESRY_INFO_ID       = "TESRY_param"
PREPOST_ARRAY       = "[a]"
PREPOST_ARRAY_HASH  = "[ah]"
PREPOST_ARRAY2      = "[a2]"
PREPOST_ARRAY2_HASH = "[a2h]"
PREPOST_HASH        = "[h]"
HOOK_DO             = "[p]do"
COMMA_SEPARATED     = "[cs]"
COLON_SPACE         = "[cols]"
ISTAT               = "[is]"
VAR_TYPE            = "[vt]"
SCDLTBL_REPEAT      = "[scrp]"
SCDLTBL_EXPPOINT    = "[scep]"
ISR_STATE           = "[isrst]"
TF_LOCAL            = "[tfl]local"
TF_TYPE             = "[tft]"
CALL_TRUST_ID       = "caller_null"
ENADIS_INT_SOURCE   = "[edis]"
RCV_TYPE            = "[rcv]"

# パラメータ定義(階層毎)
VARI_1ST_H      = ["cc", "sc", "si" , ]
VARI_1ST_H_S    = ["need_enadis_interrupt_source",  "need_stack_share", "application_mode", "maintask_wait", "add_osap_error_hook","single_only", "extended_return_status"]
PREPOST_1ST_H   = [/^TASK[0-9]+$/, /^C[1-2]ISR[0-9]+$/, /^RESOURCE[0-9]+$/, /^EVENT[0-9]+$/, /^CORE[0-9]+$/, /^INT_STATE[0-9]+$/,
                   /^ERROR_HOOK[0-9]+$/, /^POSTTASK_HOOK[0-9]+$/, /^PRETASK_HOOK[0-9]+$/, /^STARTUP_HOOK[0-9]+$/, /^SHUTDOWN_HOOK[0-9]+$/, /^PROTECTION_HOOK[0-9]+$/,
                   /^ALARM_CBACK[0-9]+$/, /^ALARM[0-9]+$/, /^SCHEDULE_TABLE[0-9]+$/, /^COUNTER[0-9]+$/, /^TRUSTED_FUNCTION[0-9]+$/, /^ERROR_HOOK_OSAP[0-9]+$/,
                   /^PROTECTION_HOOK_OSAP[0-9]+$/, /^STARTUP_HOOK_OSAP[0-9]+$/, /^SHUTDOWN_HOOK_OSAP[0-9]+$/, /^MEMORY_MODULE[0-9]+$/, /^APPLICATION_MODE[0-9]+$/,
                   /^SPINLOCK[0-9]+$/, /^SPINLOCK[\d\/-]+/, /^IOC[0-9]+$/, /^SENDER[0-9]+$/, /^RECEIVER/, /^IOC[0-9]_DATA[0-9]+$/, /^ICISR[0-9]+$/,
                   /^NON_TRUSTED_OSAP[0-3]+$/, /^NT_OSAP_SELF_CORE(?:\_(\d+)|)$/, /^NT_OSAP_OTHER_OTHER_CORE(?:\_(\d+)|)$/, /^RESTART_TASK[0-9]+$/]
PREPOST_2ND_H   = ["var","expoint"]
PREPOST_3RD_H   = [/^vname[0-9]+$/]
PREPOST_4TH_H   = ["acttsk", "setevt"]
PREPOST_4TH_H_S = ["value","maxallowedvalue","ticksperbase","mincycle","stk_mode","stk_action","stk_task","stk_event","stk_resource","stk_intno","stk_isrid","global",
                   "data1", "data2", "data3"]
PREPOST_2ND_H_S = ["type", "coreid", "bootcnt", 
                   "tstat", "waievt", "curpri", "inipri", "ttype", "maxact", "spolicy", "actcnt", "porder", "curevt", "mask", 
                   "osap", "tfstat", "arg", "caller", "stksz", "spnid",
                   "intno", "iniintpri", "rtnstat", "intatr", "curintpri", 
                   "hooktype", "hookstat", "var", "osapstat",
                   "cbstat", "almact", "counter", "almval", "cycle", "astat", "callback", "event", "task", "incounter", "ctype",
                   "mincyc", "maxval", "curval", "cstat", 
                   "duration", "syncstrategy", "ststat", "stfrom", 
                   "resprop", "lockflg", "linkres",
                   "file","export", "susint", "successor",
                   "receiver", "maxque", "lostflg", "kind", "senderid", "datatype", "include", "initval"]
PREPOST_2ND_H_A = ["relres", "getres", "relevt", "istat", "accosap", "need_si", "appmode", "target_error_hook_cfg", "getspn",
                   "sender", "iocdata", "data", "datalist"]
DO_FIRST_H      = ["id", "syssrv", "repeat", "rettype", "retval","gcov","finish", ]

# 結合/分割用デリミタ定義
DELIMITER = "#" * 70

#=====================================================================
# 正規表現での配列include 
#=====================================================================
def check_include(aGroup, sTarget)
  aGroup.each{|sVal|
    if (sVal =~ sTarget)
      return true
    end
  }
  return false
end

#=====================================================================
# pre/postの整形処理
#=====================================================================
def format_pre_post(aData)
  sStr = "\n  " + aData.shift() + ":\n"
  bOsap = false
  aData.each{|sVal|
    if (sVal.include?(PREPOST_HASH))
      sStr += sVal.gsub(PREPOST_HASH, "") + "\n"
    elsif (sVal.include?(PREPOST_ARRAY))
      sStr += "        - " + sVal.gsub(PREPOST_ARRAY, "") + "\n"
    elsif (sVal.include?(PREPOST_ARRAY_HASH))
      sStr += "        - " + sVal.gsub(PREPOST_ARRAY_HASH, "") + ": "
    elsif (sVal.include?(PREPOST_ARRAY2))
      sStr += "            - " + sVal.gsub(PREPOST_ARRAY2, "") + "\n"
    elsif (sVal.include?(PREPOST_ARRAY2_HASH))
      sStr += "          - " + sVal.gsub(PREPOST_ARRAY2_HASH, "") + ": "
    elsif (sVal.include?(RCV_TYPE))
      sStr += sVal.gsub(RCV_TYPE, "") + "\n"
    elsif (check_include(PREPOST_1ST_H, sVal))
      if (bOsap == true)
        # OSAPIDと所属するosapが同じため，区別する必要がある
        sStr += sVal + "\n"
        bOsap = false
      else
        sStr += "    " + sVal + ":\n"
      end
    elsif (PREPOST_2ND_H.include?(sVal))
      sStr += "      " + sVal + ":\n"
    elsif (PREPOST_4TH_H_S.include?(sVal))
      sStr += "          " + sVal + ": "
    elsif (check_include(PREPOST_3RD_H, sVal))
      sStr += "        " + sVal + ":\n"
    elsif (PREPOST_4TH_H.include?(sVal))
      sStr += "          " + sVal + ":\n"
    elsif (sVal.include?(TF_TYPE))
      sStr += "          " + sVal.gsub(TF_TYPE, "") + ": "
    elsif (sVal.include?(VAR_TYPE))
      sStr += "          " + sVal.gsub(VAR_TYPE, "") + ": "
    elsif (sVal.include?(SCDLTBL_REPEAT))
      sStr += "      " + sVal.gsub(SCDLTBL_REPEAT, "") + ": "
    elsif (sVal.include?(ISR_STATE))
      sStr += "      " + sVal.gsub(ISR_STATE, "") + ": "
    elsif (sVal.include?(SCDLTBL_EXPPOINT))
      sStr += "        " + sVal.gsub(SCDLTBL_EXPPOINT, "") + ":\n"
    elsif (PREPOST_2ND_H_S.include?(sVal))
      sStr += "      " + sVal + ": "
      if (sVal == "osap")
        bOsap = true
      end
    elsif (PREPOST_2ND_H_A.include?(sVal))
      sStr += "      " + sVal + ":\n"
    elsif (sVal == TF_LOCAL)
      sStr += "        local:\n"
    elsif (sVal == HOOK_DO)
      sStr += "      do:\n"
    elsif (DO_FIRST_H.include?(sVal))
      sStr += "        " + sVal + ": "
    elsif (CALL_TRUST_ID == (sVal))
      sStr += "\n"
    else
      sStr += sVal + "\n"
      if (bOsap == true)
        bOsap = false
      end
    end
  }
  return sStr
end

#=====================================================================
# doの整形処理
#=====================================================================
def format_do(aData)
  sStr = "\n  " + aData.shift() + ":\n"
  aData.each{|sVal|
    if (DO_FIRST_H.include?(sVal))
      sStr += "    " + sVal + ": "
    elsif (PREPOST_2ND_H_A.include?(sVal))
      sStr += "    " + sVal + ":\n"
    elsif (sVal.include?(PREPOST_ARRAY))
      sStr += "      - " + sVal.gsub(PREPOST_ARRAY, "") + "\n"
    else
      sStr += sVal + "\n"
    end
  }
  return sStr
end

#=====================================================================
# CSV→YAML変換関数
#=====================================================================
def make_yaml(aData)
  # テストID取り出し
  sTestId = aData.shift()

  # YAMLファイル名
  sYamlName = sTestId + ".yaml"

  # 出力文字列初期化(1行目のテストID)
  sTesryData = sTestId + ":\n"

  # vari/pre/do/postへ分割
  aVari = []
  aPre  = []
  aDo   = []
  aPost = []
  nDoCnt   = 0
  nPostCnt = 0
  lPhase = :vari
  aData.each{|sVal|
    sVal = sVal.gsub(COMMA_SEPARATED, ",")
    sVal = sVal.gsub(COLON_SPACE, ": ")
    sVal = sVal.gsub(ISTAT, ": ")
    case lPhase
    when :vari
      if (sVal == "pre_condition")
        lPhase = :pre
        aPre.push(sVal)
      else
        aVari.push(sVal)
      end
    when :pre
      if ((sVal == "do") || ( sVal =~ /^do_[0-9]+$/))
        lPhase = :do
        aDo[nDoCnt] = []
        aDo[nDoCnt].push(sVal)
      else
        aPre.push(sVal)
      end
    when :do
      if ((sVal == "post_condition") || (sVal =~ /^post_condition_[0-9]+$/))
        lPhase = :post
        aPost[nPostCnt] = []
        aPost[nPostCnt].push(sVal)
        nDoCnt += 1
      else
        aDo[nDoCnt].push(sVal)
      end
    when :post
      if ((sVal == "do") || ( sVal =~ /^do_[0-9]+$/))
        lPhase = :do
        aDo[nDoCnt] = []
        aDo[nDoCnt].push(sVal)
        nPostCnt += 1
      else
        aPost[nPostCnt].push(sVal)
      end
    end
  }

  # vari生成
  aVari.shift()
  sTesryData += "  property:\n"
  aVari.each{|sVal|
    if (VARI_1ST_H.include?(sVal))
      sTesryData += "    " + sVal + ": \n"
    elsif (VARI_1ST_H_S.include?(sVal))
      sTesryData += "    " + sVal + ": "
    elsif (sVal.include?(ENADIS_INT_SOURCE))
      sTesryData += sVal.gsub(ENADIS_INT_SOURCE, "") + "\n"
    else
      sTesryData += "      - " + sVal + "\n"
    end
  }

  # pre生成
  sTesryData += format_pre_post(aPre)

  # do/post生成
  for i in 0..(aDo.size() - 1)
    sTesryData += format_do(aDo[i])
    sTesryData += format_pre_post(aPost[i])
  end

  # ファイルへ出力
  File.open(sYamlName, "w") {|io|
    io.puts(sTesryData)
  }

  # 生成したYAMLファイル名を返す
  return sYamlName
end

#=====================================================================
# YAML結合関数
#=====================================================================
def combine_yaml_files(aYamlFiles, sCmbinedYamlFile)
  File.open(sCmbinedYamlFile, "w") {|io|
    aYamlFiles.each{|sFileName|
      # ファイル名取得
      sBaseName = File.basename(sFileName)

      # ファイルの内容取得
      sFileData = File.read(sFileName)

      # デリミタ＋ファイル名出力
      io.puts(DELIMITER)
      io.puts("# " + sBaseName)
      io.puts(DELIMITER)

      # ファイルの内容出力
      io.puts(sFileData)
    }

    # 解凍を容易にするため最後にデリミタ出力
    io.puts(DELIMITER)
  }
end



#=====================================================================
# メイン処理
#=====================================================================

# オプション解析
cOpt = OptionParser.new(banner="Usage: akc2y.rb [option] [csv files|yaml files|cmy file]...", width=15)

lMode = nil
sCombinedYamlFile = String.new()
# CSV→YAML変換処理
cOpt.on("-a", "convert csv to yaml and combine yaml files to cmy file"){|val|
  lMode = :AKC2Y
}
# 結合YAML分割処理
cOpt.on("-d CMYFILE", "divide cmy file"){|val|
  lMode = :DEVIDE
  sCombinedYamlFile = val
}
# YAML結合(CMYファイル作成)処理
cOpt.on("-c CMYFILE", "combine yaml files to cmy file"){|val|
  lMode = :COMBINE
  sCombinedYamlFile = val
}

# 対象のCSVもしくはYAMLファイルを取得
aTargetFilePath = cOpt.parse(ARGV)

# オプション指定が不正，もしくは対象ファイルが指定されていない場合はエラー
if (lMode != nil)
  if ( ((lMode == :AKC2Y) || (lMode == :COMBINE)) &&
       (aTargetFilePath.nil?() || aTargetFilePath.empty?()) )
    puts(cOpt.help())
    exit(1)
  end
end


### オプション毎の処理を実行
case lMode
  ### CSV→YAML変換処理
  when :AKC2Y
    # 引数に与えられたCSV情報からYAMLを作成
    aTargetFilePath.each{|sCsvName|
      # ファイル存在チェック
      if (!File.exist?(sCsvName))
        print("\"#{sCsvName}\" is not exist !!")
        next
      end

      nIndex = 0
      bHeader = false
      aYamlFiles = []

      # 各レコードをYAMLとして変換＆生成する
      CSV.foreach(sCsvName) do |aLine|
        if (bHeader == false)
          nIndex = aLine.index(TESRY_INFO_ID)
          if (nIndex.nil?())
            print("Not found \"#{TESRY_INFO_ID}\" !!")
            exit(2)
          end
          bHeader = true
        else
          sFileName = make_yaml(aLine[nIndex].split(","))
          aYamlFiles.push(sFileName)
        end
      end

      # YAML結合(CMYファイル作成)処理(akc2y実行フォルダに作成)
      sCmyFile = sCsvName.gsub(".csv", ".cmy")
      combine_yaml_files(aYamlFiles, File.basename(sCmyFile))
      # 作成した個別のYAMLを削除
      system("rm -f *.yaml")
    }

  ### 結合YAML分割処理
  when :DEVIDE
    # ファイル存在チェック
    if (!File.exist?(sCombinedYamlFile))
      print("\"#{sCombinedYamlFile}\" is not exist !!")
      exit(1)
    end
    aArchiveData = File.read(sCombinedYamlFile).split("\n")

    bNameFlg = false
    bDataFlg = false
    sOutName = String.new()
    aOutData = Array.new()
    aArchiveData.each{|sLine|
      # デリミタが来た場合の処理
      if (sLine == DELIMITER)
        # 1行目
        if ((bNameFlg == false) && (bDataFlg == false))
          bNameFlg = true
          next
        # ファイル名→データへの切り替わり
        elsif (bDataFlg == false)
          bNameFlg = false
          bDataFlg = true
          next
        # データ→ファイル名への切り替わり
        elsif (bDataFlg == true)
          bNameFlg = true
          bDataFlg = false
          # ファイルを生成
          sOutData = aOutData.join("\n")
          File.open(sOutName, "w") {|io|
            io.puts(sOutData)
          }
          aOutData.clear()
          #puts(sOutName)
          next
        else
          puts("a archive file is invalid.")
          exit(1)
        end
      end

      if (bNameFlg == true)
        # ファイル名取得
        sOutName = sLine.gsub(/^# /, "")
      else
        # データ取得
        aOutData.push(sLine)
      end
    }

  ### YAML結合(CMYファイル作成)処理
  when :COMBINE
    # 引数に与えられた結合ファイル名で，YAMLを結合する
    combine_yaml_files(aTargetFilePath, sCombinedYamlFile)

  else
    puts(cOpt.help())
    exit(1)
end
