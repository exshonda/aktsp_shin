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
# $Id: TargetIdTcs.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# 仕様IDから，対象のテストIDを取得する
#=====================================================================
require "csv"
require "pp"
require "./menu/Common.rb"

aSpecId = []

# 読み込むTCSファイルを指定
@aFileList = []
aFileList2 = []
aFileList3 = []
AKTM_SC1_TCS = File.expand_path(".") + "/../../../aktsp/syssrv_test/" + SCALABILITY_CLASS + "/*/*/*.csv"
@aFileList = Dir.glob(AKTM_SC1_TCS)
@aFileList = @aFileList.uniq().sort()

AKTM_PROTECTION_TEST_TCS = File.expand_path(".") + "/../../../aktsp/protection_test/" + SCALABILITY_CLASS + "/*/*.csv"
aFileList2 = Dir.glob(AKTM_PROTECTION_TEST_TCS)
aFileList2 = aFileList2.uniq().sort()
@aFileList.concat(aFileList2)

AKTM_ERROR_TEST_TCS = File.expand_path(".") + "/../../../aktsp/error_test/" + SCALABILITY_CLASS + "/*/*.csv"
aFileList3 = Dir.glob(AKTM_ERROR_TEST_TCS)
aFileList3 = aFileList3.uniq().sort()
@aFileList.concat(aFileList3)

@aFileName = []

# 1件の仕様ID指定か仕様IDが書かれたテキスト読み込みか選択
sNumber = tcs_target_spec_select()

AKTM_TCS_SPEC_ID = File.expand_path(".") + "/result/"

def targetid_tcs(sSpecId)
  # TCSから仕様ID情報を取得
  sTcs = nil
  bInput = false
  hSpecToTcs = Hash.new{|hash, key|
    hash[key] = []
  }

  sSearchId = "," + sSpecId + ","

  @aFileList.each{|sTcsName|
    nLine = 0
    nTcsTotal = 0

    sTcs = File.basename(sTcsName,".csv")

    CSV.open(sTcsName, "r") do |data|
      if (data.include?("No."))
        data.pop
        hSpecToTcs[sTcs].push(data)
      else
        nLine += 1
        data.each{|tcsdata|
          if (tcsdata.include?(sSearchId))
            bInput = true
            nTcsTotal += 1
          end
        }
        if (bInput == true)
          data.pop
          hSpecToTcs[sTcs].push(data)
          bInput = false
        end
      end
    end
    if (hSpecToTcs[sTcs].size == 1)
      hSpecToTcs.delete(sTcs)
    elsif (nLine == nTcsTotal)
      hSpecToTcs[sTcs].clear
      sMessage = sSpecId + " is included in all test case."
      hSpecToTcs[sTcs].push(sMessage)
    end
  }

  if (hSpecToTcs.size() != 0)
    # テストID一覧ファイル作成
    sFileName = sSpecId + ".csv"
    @aFileName.push(sFileName)
    sFile  = AKTM_TCS_SPEC_ID + sFileName
    CSV.open(sFile, "w") {|writer|
      writer << []
      hSpecToTcs.sort.each {|key, data|
        writer << [key]
        data.each {|tcs|
          if (tcs.is_a?(Array))
            writer << tcs.flatten
          else
             writer << [tcs]
          end
        }
        writer << []
      }
    }
  end
end

case sNumber
when "1"
  # 仕様IDを選択
  sSpecId = spec_id_select(3)
  targetid_tcs(sSpecId)
when "2"
  sTargetId = File.read(AKTM_TARGET_SPECID_FILE)
  sTargetId.freeze
  aSpecId = sTargetId.split("\n")
  aSpecId.each{|sSpecId|
    targetid_tcs(sSpecId)
  }
end

# 結果を表示
print("\n===========================================\n")
print("Get TCS records that correspond to a SpecID\n")
print("===========================================\n")
if (@aFileName == nil)
  print("No TCS Data.\n")
else
  @aFileName.each{|sName|
    printf("Check %s\n",sName)
  }
end
print("-------------------------------------------\n")

