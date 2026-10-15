#!ruby -Ke
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
# $Id: GetSpecificationIDfromPdf.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# PDFファイルから仕様タグを抜き出してID一覧をファイルへ出力する
# ※filenameを環境に応じて変更して使用すること
#=====================================================================

# 書き出すファイル
sWriteFileId   = File.dirname(__FILE__) + "/autosar_spec_id.txt"
sWriteFileDesc = File.dirname(__FILE__) + "/autosar_spec_desc.txt"


### PDFファイルをテキストファイルへ変換する(ToDo)
# 読み込むPDFファイル
sPdfFile  = "AUTOSAR_SWS_OS_R4.0.3.pdf"

# pdfから読みだしたテキストデータ
sTextFile = "AUTOSAR_SWS_OS_R4.0.3.txt"

# テキストファイルを読み込む
sText = File.read(sTextFile)
sText.freeze

# 改行ごとに配列化
aData1 = sText.split("\n")


### 仕様ID＋文章一覧作成 ###

# さらに読点ごとに配列化
aData2 = []
aData1.each{|sLine|
  aTemp = sLine.split(".")
  aTemp.each{|sStr|
    aData2.push(sStr + ".")
  }
}

# OSxxx: を含む行のみを抽出
aData3 = []
aData2.each{|sLine|
  if (sLine.index(/OS[0-9][0-9][0-9]|OS[0-9][0-9][0-9]_Conf\s:|MCOS[0-9][0-9][0-9][0-9]_Conf\s:/) != nil)
    aData3.push(sLine)
  end
}

# ソートして1つの文字列にする
aData3.sort!
sOutString = aData3.join("\n")

# ファイルへ出力する
File.open(sWriteFileDesc, "w") {|io|
  io.puts(sOutString)
}


### 仕様ID一覧作成 ###

# PDF内の文字列からOSxxx:を抜き出して配列にする
aData1 = sText.scan(/\[OS[0-9][0-9][0-9]\]/)
aData2 = sText.scan(/OS[0-9][0-9][0-9]_Conf\s:/)
aData3 = sText.scan(/MCOS[0-9][0-9][0-9][0-9]_Conf\s:/)

nData1 = aData1.size()
nData2 = aData2.size()
nData3 = aData3.size()

aTotal = aData1 + aData2 + aData3

aData = []
aDup = []

# :,[,]を削除
aTotal.each{|sLine|
  sTemp = sLine.gsub(/:|\s|\[|\]/, "")
  # 重複しているものは2度いれない
  if (aData.include?(sTemp))
    aDup.push(sTemp)
  else
    aData.push(sTemp)
  end
}

aData.sort!

# 1つの文字列にする
sOutString = aData.join("\n")

# ファイルへ出力する
File.open(sWriteFileId, "w") {|io|
  io.puts(sOutString)
}

# 仕様IDの件数を表示する
print("================================\n")
printf("OS***        : %3d\n", nData1)
printf("OS***_Conf   : %3d\n", nData2)
printf("MCOS***_Conf : %3d\n", nData3)
print("================================\n")
printf("Total      : %3d\n", (nData1 + nData2 + nData3))

# 重複したIDが存在する場合は表示する
if (aDup.size != 0)
  aDup.sort!
  print("--------------------------------\n")
  print("the following IDs are duplicated\n")
  print("--------------------------------\n")
  aDup.each{|sLine|
    print(sLine + "\n")
  }
end
