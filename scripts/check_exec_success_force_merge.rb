#!ruby -Ke
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
# $Id: check_exec_success_force_merge.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

# 強制マージテスト用の実行モジュール実行結果確認用スクリプト
# 処理が重いため，Rubyで処理する．
# 全テストが成功していた場合は0を返し，そうでない場合やエラー終了した場
# 合は1を返す．
# 各テストが成功しているかの判定には，実行ログの表示が，
# "=== テストID ===" → "テストID: Start" → 複数の
# "Check point n passed" → "テストID: OK"の順で表示され，かつ，"##"が
# 表示されていないかを用いる．
# マルチコアに備えて，"Barrier sync phase n synchronized"も確認する．
require "kconv"
require "pp"

# 引数チェック
aFileName = []
bMulti = false
if ((ARGV.size() == 2) || (ARGV.size() == 3))
  # 引数のファイル有無のチェック
  if (!File.exist?(ARGV[0]))
    abort("Error: #{__LINE__}")
  end
  sManifestName = ARGV[0]

  if (!File.exist?(ARGV[1]))
    abort("Error: #{__LINE__}")
  end
  aFileName.push(ARGV[1])

  if (ARGV.size() == 3)
    if (!File.exist?(ARGV[2]))
      abort("Error: #{__LINE__}")
    end
    aFileName.push(ARGV[2])
    bMulti = true
  end
else
  abort("Error: #{__LINE__}")
end


aData = []
aFileName.each{|sFileName|
  sFileData = File.read(sFileName).toeuc()
  # 改行コードを変換
  if (sFileData.include?("\r\n"))
    sFileData.gsub!("\r\n","\n")
  end
  if (sFileData.include?("\r"))
    sFileData.gsub!("\r","\n")
  end
  if (aData.nil?())
    aData = sFileData.split("\n")
  else
    aData = aData.concat(sFileData.split("\n"))
  end
}

sTestID = ""
bStartFlg = false
bCPFlg = false
bOKFlg = false
bAllFlg = false
bUnexpectedFlg = false
bNextFlg = false
bShutdownFlg = false

nSuccessNum = 0
aFailTest = []
aSuccessTest1 = []
aSuccessTest2 =[]

aData.each{|sLine|
  if (sLine =~ /===\s[a-zA-Z0-9_]*\s===/)
    sTestID = sLine[4..-5]
  elsif (!sTestID.empty?() && sLine.include?("Test Number"))
    # 何もしない
  elsif (!sTestID.empty?() && (sLine =~ /^#{sTestID}: Start$/))
    bStartFlg = true
  elsif (!sTestID.empty?() && (bStartFlg == true) && ((sLine =~ /^Check point [0-9]* passed\.$/) || 
                                                      (sLine =~ /^Core [0-9] : Check point [0-9]* passed\.$/)))
    bCPFlg = true
  elsif (!sTestID.empty?() && (bStartFlg == true) && (sLine =~ /^Core [0-9] : Barrier sync phase [0-9]* synchronized\.$/))
    # バリア同期の有無はテストに依存するため，チェックしない
  elsif (!sTestID.empty?() && (bStartFlg == true) && (bCPFlg == true) && (sLine =~ /^#{sTestID}: OK$/))
    bOKFlg = true
  elsif (!sTestID.empty?() && (bStartFlg == true) && (bCPFlg == true) && (bOKFlg == true) && (sLine =~ /All check points passed\.$/))
    bAllFlg = true
  elsif (sLine.include?("##"))
    bUnexpectedFlg = true
  elsif (!sTestID.empty?() && (bAllFlg == false) && (bUnexpectedFlg == false) && (sLine == "Kernel Shutdown...") && (bMulti == true))
    # マルチコアの場合，一方のコアには「All check points passed.」は出ない
    # 正常に終了したかは，「Kernel Shutdown...」とエラーメッセージの有無で確認する
    bShutdownFlg = true
  end

  if (!sTestID.empty?() && sLine.empty?())
    if (!sTestID.empty?() && (bStartFlg == true) && (bCPFlg == true) && (bOKFlg == true) && (bAllFlg == true) && (bUnexpectedFlg == false))
      if (!aFailTest.include?(sTestID))
        # 既に他コアでエラーの場合は，aSuccessTestに追加しない
        aSuccessTest1.push(sTestID)
      end
    elsif (!sTestID.empty?() && (bUnexpectedFlg == false) && (bShutdownFlg == true) && (bMulti == true))
      if (!aFailTest.include?(sTestID))
        # 既に他コアでエラーの場合は，aSuccessTestに追加しない
        aSuccessTest2.push(sTestID)
      end
    else
      aFailTest.push(sTestID)
    end
    bNextFlg = true
  end
  if (bNextFlg == true)
    # 変数初期化
    sTestID = ""
    bStartFlg = false
    bCPFlg = false
    bOKFlg = false
    bAllFlg = false
    bUnexpectedFlg = false
    bNextFlg = false
  end
}

aSuccessTest = []
if (bMulti == true)
  # マルチコアの場合，他コアで失敗している場合がある
  # 2つの結果ファイルから重複していないケースは，失敗と判断する
  aSuccessTest1.each{|sTestID|
    if (aSuccessTest2.include?(sTestID))
      aSuccessTest.push(sTestID)
      aSuccessTest2.delete(sTestID)
    else
      aFailTest.push(sTestID)
    end
  }
  if (!aSuccessTest2.nil?())
    aFailTest.concat(aSuccessTest2.uniq())
  end
else
  # シングルの場合は，結果ファイルは1つのみ
  aSuccessTest = aSuccessTest1
end

sManifestData = File.read(sManifestName)
aData = sManifestData.split("\n")
nTestNum = aData.size
# 除外されたテストケースが存在する場合は，母数を減らす
if (File.exist?("aktg_exclusion_list.txt"))
  sExclusionListData = File.read("aktg_exclusion_list.txt")
  sExclusionListData = sExclusionListData[/[0-9]* test cases are excluded./]
  nTestNum = nTestNum - (sExclusionListData[/[0-9]*/].to_i)
end
nSuccessNum = aSuccessTest.uniq.size

puts "=" * 70
puts sManifestName.gsub("MNF_", "")
puts "=" * 70
puts "Test number: #{nTestNum}"
puts "Success number: #{nSuccessNum}"
if (!aFailTest.empty?())
  puts "-" * 70
  puts "NG Test Case:"
  puts aFailTest
end
puts ""
if (nTestNum == nSuccessNum)
  exit 0
else
  exit 1
end
