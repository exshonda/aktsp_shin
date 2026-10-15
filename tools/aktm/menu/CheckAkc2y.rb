#!ruby
#
# AKTM
#      Automotive Kernel Test Manager
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
# $Id: CheckAkc2y.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# 不正な仕様IDの存在チェック
#=====================================================================
require "yaml"
require "csv"
require "./menu/Common.rb"

# 読み込むTESRYファイルを指定
aFileList  = []
aFileList2 = []
aFileList3 = []
AKTM_SC1_TESRY = File.expand_path(".") + "/../../../aktsp/syssrv_test/" + SCALABILITY_CLASS + "/*/*/*/*.yaml"
aFileList = Dir.glob(AKTM_SC1_TESRY)
aFileList = aFileList.uniq().sort()

AKTM_PROTECTION_TEST = File.expand_path(".") + "/../../../aktsp/protection_test/" + SCALABILITY_CLASS + "/*/*/*.yaml"
aFileList2 = Dir.glob(AKTM_PROTECTION_TEST)
aFileList2 = aFileList2.uniq().sort()
aFileList.concat(aFileList2)

AKTM_ERROR_TEST = File.expand_path(".") + "/../../../aktsp/error_test/" + SCALABILITY_CLASS + "/*/*/*.yaml"
aFileList3 = Dir.glob(AKTM_ERROR_TEST)
aFileList3 = aFileList3.uniq().sort()
aFileList.concat(aFileList3)

# TESRYデータ読み込み
aTesryId = []  # テストID毎のタグ
nTesryCnt     = 0
nTotal   = aFileList.size()

aFileList.each{|sYamlName|
  nTesryCnt += 1

  hYaml = YAML.load_file(sYamlName)
  # ハッシュでない(YAMLでない)場合エラー
  if (!hYaml.is_a?(Hash))
    abort("not YAML file !! [#{sYamlName}]")
  end

  hYaml.each{|sTestId, hScenario|
    if (sTestId == "version")
      next
    end

    # プログレスバー
    print_progress(sTestId, nTesryCnt, nTotal)

    # 既にテストIDが存在した場合エラー
    if (aTesryId.include?(sTestId))
      abort("exist same Test ID !! [#{sTestId}]")
    else
      aTesryId.push(sTestId)
    end
  }
}
# プログレスバー用表示のリセット
finish_progress(nTotal)

# hTestInfoが空の場合，対象テストなし
if (aTesryId.empty?())
  abort("Test is not exist !!")
end

# 読み込むTCSを指定
aFileList.clear
AKTM_SC1_TCS = File.expand_path(".") + "/../../../aktsp/syssrv_test/"+ SCALABILITY_CLASS + "/*/*/*.csv"
aFileList = Dir.glob(AKTM_SC1_TCS)
aFileList = aFileList.uniq().sort()

aFileList2.clear
AKTM_PROTECTION_TEST_TCS = File.expand_path(".") + "/../../../aktsp/protection_test/" + SCALABILITY_CLASS + "/*/*.csv"
aFileList2 = Dir.glob(AKTM_PROTECTION_TEST_TCS)
aFileList2 = aFileList2.uniq().sort()
aFileList.concat(aFileList2)

aFileList3.clear
AKTM_ERROR_TEST_TCS = File.expand_path(".") + "/../../../aktsp/error_test/" + SCALABILITY_CLASS + "/*/*.csv"
aFileList3 = Dir.glob(AKTM_ERROR_TEST_TCS)
aFileList3 = aFileList3.uniq().sort()
aFileList.concat(aFileList3)

# TCS読み込み
sTcs = nil
nTotal = 0
aTotal = []
nTcsCnt = 0
hSpecToTcs = Hash.new{|hash, key|
  hash[key] = []
}
nCnt = 0
nTotal = aFileList.size()

aFileList.each{|sTcsName|
  nCnt += 1

  sTcs = File.basename(sTcsName,".csv")

  # プログレスバー
  print_progress(sTcs, nCnt, nTotal)

  CSV.open(sTcsName, "r") do |data|
    hSpecToTcs[sTcs].push(data)
  end
  hSpecToTcs[sTcs].delete_at(0)
  aTotal.push(hSpecToTcs[sTcs].size)
}
# プログレスバー用表示のリセット
finish_progress(nTotal)

# 件数
aTotal.each {|sValue|
  nTcsCnt += sValue
}

# 比較する
nNum = 0
nNum = nTesryCnt <=> nTcsCnt

# 結果を表示
print("\n===========================================\n")
print("Check AKC2Y\n")
print("===========================================\n")
if (nNum == 0)
  print("No Difference between TESRYs and TCSs\n")
elsif (nNum > 0)
  print("Difference detected\n")
  printf("TESRY has %d more cases than TCS\n", nTesryCnt - nTcsCnt)
elsif (nNum < 0)
  print("There is Difference\n")
  printf("TCS has %d more cases than TESRY\n", nTcsCnt - nTesryCnt)
else
  print("Error!!!\n")
end
print("-------------------------------------------\n")
