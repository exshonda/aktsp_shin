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
# $Id: Common.rb 347 2014-09-17 00:28:35Z fsi-dankei $
#

#=====================================================================
# CommonModule
#=====================================================================
require "pp"
require "curses"
require "find"

#=================================================================
# ユーザ設定可能項目
#=================================================================
# スケーラビリティクラス
SCALABILITY_CLASS = "sc1"

#=================================================================
# マクロ定義
#=================================================================
PROPERTY = "property"
SPEC_ID  = "si"

AKTM_MAIN_MENU = [
   "Specifications Coverage",
   "Check invalid SpecIDs",
   "Check untested SpecIDs",
   "Get TCS records that correspond to a SpecID",
   "Get TestIDs that correspond to a SpecID",
   "Check AKC2Y"
]
STDOUT.sync = true
#=================================================================
# 概  要: 対象仕様IDを入力
#=================================================================
def spec_id_select(nMenuNum)
  sSpecId = nil
  aAllSpecId = []

  print("\n===========================================\n")
  printf("%s\n", AKTM_MAIN_MENU[nMenuNum])
  print("===========================================\n")
  print("Please input SpecID: ")

  sSpecId = STDIN.gets.chomp

  case sSpecId
  when "q"
    exit
  else
    aAllSpecId = get_all_spec_id()
    aAllSpecId.each {|sSpec|
     if (sSpec == sSpecId)
       return sSpecId
     end
    }
    printf("\n%s is invalid SpecID\n",sSpecId)
    spec_id_select(nMenuNum)
  end
end


AKTM_ALL_SPEC_FILE  = File.expand_path(".") + "/spec_id/data/ngka_spec_id.txt"
AKTM_EXCLUSION_FILE = File.expand_path(".") + "/spec_id/data/atk2_exclusion_id.txt"
AKTM_TARGET_SPECID_FILE  = File.expand_path(".") + "/spec_id/data/target_id_tcs.txt"
#=================================================================
# 概　要: 全仕様ID取得
#=================================================================
def get_all_spec_id()
  sFileData = File.read(AKTM_ALL_SPEC_FILE)
  sFileData.freeze
  aNgkaSpecId = sFileData.split("\n")
  aAllSpecId = aNgkaSpecId.dup
  return aAllSpecId
end

#=================================================================
# 概　要: 除外ID取得
#=================================================================
def get_exclusion_id()
  aExSpecId = []

  # 除外するIDを読込み，配列に格納する
  sExFileData = File.read(AKTM_EXCLUSION_FILE)
  sExFileData.freeze
  aExSpecId = sExFileData.split("\n")
  aExSpecId = aExSpecId.uniq
  return aExSpecId
end

#=================================================================
# 概　要: 対象ID取得
#=================================================================
def get_target_spec_id(aAllSpecIdCopy,aExSpecId)
  aExSpecId.each {|sTestId|
    aAllSpecIdCopy.delete(sTestId)
  }
  aAllSpecIdCopy.sort!()
  return aAllSpecIdCopy
end

#=================================================================
# 概　要: 1件の仕様ID指定か仕様IDが書かれたテキスト読み込みか選択
#=================================================================
def tcs_target_spec_select()
  sNumber = nil

  print("\n===========================================\n")
  printf("%s\n", AKTM_MAIN_MENU[3])
  print("===========================================\n")
  print("1: Specify a SpecID\n")
  print("2: Read target_id_tcs.txt\n")
  print("-------------------------------------------\n")
  print("Please input number: ")

  sNumber = STDIN.gets.chomp
  
  print("\n")
  
  case sNumber
  when "1","2"
  else
    sNumber = tcs_target_spec_select()
  end
  return sNumber
end

#=================================================================
# 概　要: 処理の進捗を表示
#=================================================================
def print_progress(sTestID, nCnt, nTotal)
  # 呼び出す処理が局所的のためcheck_classはしない
  Curses.init_screen

  # コンソールの幅取得
  nCols = Curses.cols

  # 進捗率計算
  fProgress = nCnt.to_f / nTotal.to_f

  # プログレスバーサイズ計算(幅-フェーズ-進捗率-最大テストID-括弧等)
  nProgressSize = nCols - 40 - 17

  # 整数にしたプログレスバー上の進捗サイズ
  nIntProg = (fProgress * nProgressSize).to_i

  # テストID文字数チェック
  if (40 < sTestID.size())
    sTestID = sTestID.slice(0, 40)
  end

  # 文字列作成
  sProgress = "#" * nIntProg
  sProgress += "-" * (nProgressSize - nIntProg)
  sProgress += ":#{"%5.1f" % (fProgress * 100)}\%"
  sProgress += " [#{sTestID}"
  sProgress += "\s"  * (40 - sTestID.size())
  sProgress += "]"
  $stderr.print("\r#{sProgress}\r")

  Curses.close_screen
end

#=================================================================
# 概　要: 進捗表示の終了
#=================================================================
def finish_progress(nTotal)
  # 呼び出す処理が局所的のためcheck_classはしない
  Curses.init_screen

  # コンソールの幅取得
  nCols = Curses.cols

  # プログレスバーサイズ計算(幅-フェーズ-進捗率-最大テストID-括弧等)
  nProgressSize = nCols - 40 - 17

  # メッセージ作成
  sMsg = " %d files passed." % nTotal

  # 文字列作成
  sProgress = "#" * nProgressSize
  sProgress += ":100.0\%"
  sProgress += " [#{sMsg}"
  sProgress += "\s"  * (40 - sMsg.size())
  sProgress += "]"
  $stderr.print(sProgress)

  Curses.close_screen

  $stderr.print("\n")
end
