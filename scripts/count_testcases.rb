#!ruby
#
# AKTB
#      Automotive Kernel Test Builder
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
# $Id: count_testcases.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

# テスト実行後，全体の件数および実際に実行した件数をカウントする

require "pp"
require "find"

LOG_FILE_NAME = "result_aktg.log"

# 引数チェック
if (ARGV.size() == 0)
  abort("argument error!")
end

# 対象ディレクトリ内に含まれるログファイルへのパスを取得
sTargetDir = File.expand_path(ARGV[0])
Dir.chdir(sTargetDir)
aTargetFiles = []
Find.find(sTargetDir) do |sRes|
  if ((!File.directory?(sRes)) && (File.basename(sRes) == LOG_FILE_NAME))
    aTargetFiles.push(sRes)
  end
end

nTotalPassNum = 0
nTotalExistNum = 0
hEachCount = {}
aTargetFiles.each{|sFileName|
  # ファイル有無のチェック
  if (!File.exist?(sFileName))
    puts("file not found: [#{sFileName}]")
    exit 1
  end

  sFileData = File.read(sFileName)
  aData = sFileData.split("\n")

  # パスからテスト種別を取得
  aPath = sFileName.split("/")
  sTestName = aPath[-3]

  if (!hEachCount.has_key?(sTestName))
    hEachCount[sTestName] = {:PASS => 0, :EXIST=> 0}
  end

  if (aData.size() == 3)
    nNum = aData[2][/\s[0-9]+\stest\scases\spassed\./][/[0-9]+/].to_i()
    hEachCount[sTestName][:PASS] += nNum
    hEachCount[sTestName][:EXIST] += nNum
    nTotalPassNum += nNum
    nTotalExistNum += nNum
  else
    nNum = aData[-1][/passed,\s[0-9]+\s/][/[0-9]+/].to_i()
    hEachCount[sTestName][:PASS] += nNum
    nTotalPassNum += nNum
    nNum = aData[-1][/\s[0-9]+\stest\scases/][/[0-9]+/].to_i()
    hEachCount[sTestName][:EXIST] += nNum
    nTotalExistNum += nNum
  end
}

# 整形用演算
nMaxLen = 0
hEachCount.each{|sName, hCount|
  if (nMaxLen < sName.size())
    nMaxLen = sName.size()
  end
}
hFairCount = {}
hEachCount.each{|sName, hCount|
  if (nMaxLen > sName.size())
    sName += " " * (nMaxLen - sName.size())
  end
  hFairCount[sName] = hCount
}

# 結果表示
puts("-" * 40);
hFairCount.each{|sName, hCount|
  sPadding = " "
  if (hCount[:PASS] == hCount[:EXIST])
    sPadding = ""
  end
  fRatio = hCount[:PASS].to_f() / hCount[:EXIST].to_f()
  fRatio = (fRatio * 100).round(1)
  puts("[#{sName}] #{sPadding}#{fRatio}% executed. [ #{hCount[:PASS]} / #{hCount[:EXIST]} ]")
}
puts("-" * 40);
fRatio = nTotalPassNum.to_f() / nTotalExistNum.to_f()
fRatio = (fRatio * 100).round(1)
puts("[Total] #{fRatio}% executed. [ #{nTotalPassNum} / #{nTotalExistNum} ]")

