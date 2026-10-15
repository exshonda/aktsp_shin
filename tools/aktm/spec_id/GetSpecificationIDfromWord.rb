#!ruby
# -*- coding: euc-jp -*-
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
# $Id: GetSpecificationIDfromWord.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# Wordファイルから仕様タグを抜き出してID一覧をファイルへ出力する
# ※filenameを環境に応じて変更して使用すること
#=====================================================================
require "win32ole"
require "kconv"
# $KCODE = "euc" -> ruby1.9で廃止

# 読み込むWordファイル
sReadFile = "C:\\次世代車載システム向けRTOS外部仕様書.doc"

# 書き出すファイル
sWriteFileId   = File.dirname(__FILE__) + "/data/ngka_spec_id.txt"
sWriteFileDesc = File.dirname(__FILE__) + "/data/ngka_spec_desc.txt"
sWriteFileCnt = File.dirname(__FILE__) + "/data/ngka_spec_cnt.txt"

# OLE定義
cOLE = WIN32OLE.new("Word.Application")

# Wordファイルを読み込んで文字列にする
begin
  cWord = cOLE.Documents.open(sReadFile.tosjis, false, true)
  sText = cWord.Content.Text
  #word.saveAs("R:\\temp.txt", 4) # テキスト保存
  cWord.close()
rescue
  $stderr.print($!.message, "\n")
end

cOLE.quit()

# "【】"検索のためにEUC-JPへ変換する
sText  = sText.toeuc
sLeft  = "【".toeuc
sRight = "】".toeuc
sPeriod = "．".toeuc
sComma = "，".toeuc

### 仕様ID＋文章一覧作成 ###

# 改行ごとに配列化
aData1 = sText.split("\r")

# さらにピリオドごとに配列化
aData2 = []
aData1.each{|sLine|
  aData2.concat(sLine.split(/#{sPeriod}/e))
}

# カンマをピリオドに置換
aData2.each{|sLine|
  if (sLine.index(/#{sLeft}[A-Z]+[a-z]*[0-9]+.*#{sRight}#{sComma}/e) != nil)
    aData2.push(sLine.sub(/(#{sComma})+/e, "．"))
    aData2.delete(sLine)
  end
}

# さらにピリオドごとに配列化
aData3 = []
aData2.each{|sLine|
  aData3.concat(sLine.split(/#{sPeriod}/e))
}

# 【】を含む行のみを抽出し，仕様IDを先頭に置き換える
aData4 = []
aData3.each{|sLine|
  if (sLine.index(/#{sLeft}[A-Z]+[a-z]*[0-9]+.*#{sRight}/e) != nil)
    aData4.push(sLine.slice(/#{sLeft}[A-Z]+[a-z]*[0-9]+.*#{sRight}/e) + sLine.gsub(/#{sLeft}[A-Z]+[a-z]*[0-9]+.*#{sRight}/e, ""))
  end
}

# ソートして1つの文字列にする
aData4.sort!
sOutString = aData4.join("\n")

# ファイルへ出力する
File.open(sWriteFileDesc, "w") {|io|
  io.puts(sOutString)
}


### 仕様ID一覧作成 ###

# Word内の文字列から【】で囲まれた英字+数字を抜き出して配列にする
#aData1 = sText.scan(/#{sLeft}[A-Z]+[0-9]+#{sRight}/e)
aData1 = sText.scan(/#{sLeft}[A-Z]+[a-z]*[0-9]+[_Conf]*#{sRight}/e)

# 【】を削除する
aData2 = []
aDup = []
aData1.each{|sLine|
  sTemp = sLine.gsub(/#{sLeft}/e, "").gsub(/#{sRight}/e, "")
  # 重複しているものは2度いれない
  if (aData2.include?(sTemp))
    aDup.push(sTemp)
  else
    aData2.push(sTemp)
  end
}

# ソートして1つの文字列にする
aData2.sort!
sOutString = aData2.join("\n")

# ファイルへ出力する
File.open(sWriteFileId, "w") {|io|
  io.puts(sOutString)
}

### 仕様IDカウント一覧作成 ###

# COSXXXカウント
retCnt1 = aData2.count{ |var| var =~/^COS[0-9]/}
sCOS = "【COSxxx】 : " + "#{retCnt1}" + "\n"

# OSXXXカウント
retCnt2 = aData2.count{ |var| var =~/^OS[0-9]/}
sOS = "【OSxxx】  : " + "#{retCnt2}" + "\n"

# OSaXXXカウント
retCnt5 = aData2.count{ |var| var =~/^OSa[0-9]/}
sOSa = "【OSaxxx】 : " + "#{retCnt5}" + "\n"

# NOSXXXカウント
retCnt3 = aData2.count{ |var| var =~/^NOS[0-9]/}
sNOS = "【NOSxxx】 : " + "#{retCnt3}" + "\n"

# IOSXXXカウント
retCnt4 = aData2.count{ |var| var =~/^IOS[0-9]/}
sIOS = "【IOSxxx】 : " + "#{retCnt4}" + "\n"

# 仕様ID合計カウント
retCnt6 = aData2.count{ |var| var =~/^[A-Z]/}
sTotal = "   合計    : " + "#{retCnt6}" + "\n"

slineOut = "--------------------------------\n"

sCntOut = slineOut + sCOS + sOS + sOSa + sNOS + sIOS  + slineOut + sTotal + slineOut

# カウントした各仕様IDをファイルへ出力する
File.open(sWriteFileCnt, "w") {|io|
  io.puts(sCntOut)
}

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
