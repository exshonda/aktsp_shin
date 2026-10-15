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
# $Id: InvalidSpecId.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# 不正な仕様IDの存在チェック
#=====================================================================
require "yaml"
require "find"
require "./menu/Common.rb"

# 全仕様IDを取得
aAllSpecId = []
aAllSpecId = get_all_spec_id

# 除外IDを取得
aExSpecId = []
aExSpecId = get_exclusion_id()

# 対象IDを求める
aTargetSpecId = []
aTargetSpecId = get_target_spec_id(aAllSpecId,aExSpecId)

# 読み込むTESRYファイルを指定
aFileList  = []
aFileList2 = []
aFileList3 = []
AKTM_SC1_TESRY = File.expand_path(".") + "/../../../aktsp/syssrv_test/"+ SCALABILITY_CLASS + "/*/*/*/*.yaml"
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

# TESRYデータから仕様ID情報を取得
aTesrySpecId = []
hTestInfo  = {}  # テストID毎のタグ
hSpecToTest = Hash.new{|hash, key|
  hash[key] = []
}
nCnt = 0
nTotal = aFileList.size()

aFileList.each{|sYamlName|
  nCnt += 1

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
    print_progress(sTestId, nCnt, nTotal)

    # 既にテストIDが存在した場合エラー
    if (hTestInfo.has_key?(sTestId))
      abort("exist same Test ID !! [#{sTestId}]")
    else
      hTestInfo[sTestId] = []
    end

    # PROPERTYセクションが無い場合エラー
    if (!hScenario.has_key?(PROPERTY))
      abort("not exist \"#{"version"}\" !! [#{sTestId}]")
    end

    # SPEC_IDセクションが無い場合エラー
    if (!hScenario[PROPERTY].has_key?(SPEC_ID))
      abort("not exist Specification ID !! [#{sTestId}]")
    end

    # 仕様IDを取得
    if (hScenario[PROPERTY][SPEC_ID].is_a?(String))
      hTestInfo[sTestId].push(hScenario[PROPERTY][SPEC_ID])
      aTesrySpecId.push(hScenario[PROPERTY][SPEC_ID])
      hSpecToTest[hScenario[PROPERTY][SPEC_ID]].push(sTestId)
    elsif (hScenario[PROPERTY][SPEC_ID].is_a?(Array))
      hTestInfo[sTestId].concat(hScenario[PROPERTY][SPEC_ID])
      aTesrySpecId.concat(hScenario[PROPERTY][SPEC_ID])
      hScenario[PROPERTY][SPEC_ID].each{|sSpecId|
        hSpecToTest[sSpecId].push(sTestId)
      }
    else
      # 文字列でも配列でも無い場合エラー
      abort("Specification ID must be defined as Array or String !! [#{sTestId}]")
    end
  }
}

# プログレスバー用表示のリセット
finish_progress(nTotal)

# hTestInfoが空の場合，対象テストなし
if (hTestInfo.empty?())
  abort("Test is not exist !!")
end

# 重複した仕様タグ一覧をまとめる
aTesrySpecId.uniq!().sort!()

# 除外IDがTESRYデータに含まれていないか
aErrerId = []
aExSpecId.each {|sSpec|
  if (aTesrySpecId.any?{|sId| sId == sSpec})
    aErrerId.push(sSpec)
  end
}

# 全仕様IDに存在しない仕様IDがTESRYデータに含まれていないか
aTesrySpecId.each {|sTesry|
  if (!aAllSpecId.any?{|sAllId| sAllId == sTesry})
    aErrerId.push(sTesry)
  end
}
if (!aErrerId.empty?)
  sTest = nil
  aTestID = []
  aErrerId.each{|sSpec|
    hSpecToTest[sSpec].each {|sId|
      sId = sId.gsub(/_\d+$/,"")
      if (sTest != sId)
        aTestID.push(sId)
        aTestID = aTestID.uniq
        sTest = sId
      end
    }
  }

  # テストID一覧ファイル作成
  AKTM_INVALID_SPEC_ID  = File.expand_path(".") + "/result/tesry_invalid_id.txt"
  File.open(AKTM_INVALID_SPEC_ID, "w") {|io|
    aErrerId.each{|sSpec|
      io.print("<",sSpec,">\n")
      aTestID.each {|sId|
        io.puts(sId)
      }
      io.print("\n")
    }
  }
end

# 結果を表示
print("\n===========================================\n")
print("Check invalid SpecIDs\n")
print("===========================================\n")
if (aErrerId.empty?)
  print("No invalid SpecID in TESRYs\n")
else
  print("Check tesry_invalid_id.txt\n")
end
print("-------------------------------------------\n")

