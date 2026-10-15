
	AKTSP - Automotive Kernel Test Suite Package -
	＜rcovによるカバレッジ取得手順書＞

本ドキュメントは，AKTGおよびAKTFのソースコードカバレッジを取得する方法
をまとめたものである．

----------------------------------------------------------------------
AKTSP
    Automotive Kernel Test Suite Package

Copyright (C) 2011-2014 by Center for Embedded Computing Systems
            Graduate School of Information Science, Nagoya Univ., JAPAN
Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
Copyright (C) 2011-2013 by Spansion LLC, USA
Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
Copyright (C) 2011-2014 by Witz Corporation, JAPAN

本ドキュメントは，次世代車載システム向けRTOSの仕様検討及び
開発に関するコンソーシアム型共同研究において作成したものである．
本ドキュメントの著作権は，上記の著作権者に帰属する．

上記著作権者は，以下の (1)?(3)の条件を満たす場合に限り，本ドキュメ
ント（本ドキュメントを改変したものを含む．以下同じ）を使用・複製・改
変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
(1) 本ドキュメントを利用する場合には，上記の著作権表示，この利用条件
    および下記の無保証規定が，そのままの形でドキュメント中に含まれて
    いること．
(2) 本ドキュメントを改変する場合には，ドキュメントを改変した旨の記述
    を，改変後のドキュメント中に含めること．ただし，改変後のドキュメ
    ントが，TOPPERSプロジェクト指定の開発成果物である場合には，この限
    りではない．
(3) 本ドキュメントの利用により直接的または間接的に生じるいかなる損害
    からも，上記著作権者およびTOPPERSプロジェクトを免責すること．また，
    本ドキュメントのユーザまたはエンドユーザからのいかなる理由に基づ
    く請求からも，上記著作権者およびTOPPERSプロジェクトを免責すること．

本ドキュメントは，AUTOSAR（AUTomotive Open System ARchitecture）仕様
に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するものではな
い．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利用する
者に対して，AUTOSARパートナーになることを求めている．

本ドキュメントは，無保証で提供されているものである．上記著作権者およ
びTOPPERSプロジェクトは，本ドキュメントに関して，特定の使用目的に対す
る適合性も含めて，いかなる保証も行わない．また，本ドキュメントの利用
により直接的または間接的に生じたいかなる損害に関しても，その責任を負
わない．

$Id: readme.txt 347 2014-09-17 00:28:35Z fsi-dankei $
----------------------------------------------------------------------

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
はじめに
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AKTG，AKTFのカバレッジ取得には，sample_tesryを使用する(aktsp/trunk/
sample_tesry)．なお，動作環境はCygwinを想定している．

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
環境構築手順
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
----------------------------------------------------------------------
[1]rubygemsインストール
----------------------------------------------------------------------
rubygemsとは，Rubyの標準パッケージ管理システムであり，後述のカバレッジ
取得用ライブラリであるrcovをインストールするのに必要である．

(1)rubygems-1.6.2.tgzを任意のディレクトリへ展開する．
   "rubygems-1.6.2"というディレクトリが作成される．

(2)setup.rbを実行する
   $ ruby setup.rb

※rubygems公開サイト
  http://rubyforge.org/projects/rubygems/

----------------------------------------------------------------------
[2]rcovインストール
----------------------------------------------------------------------
rcovとは，Rubyプログラム実行時のソースコードカバレッジをhtml形式で生成
するライブラリである．

(1)rubygemsによりrcovをインストールする．(インターネット接続が必要)
   $ gem install rcov

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
カバレッジ取得手順
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AKTGおよびAKTFのカバレッジ取得に必要なコマンドは，aktg_rcov.shにまとめ
ているため，aktg_rcov.shを実行することで，カレントディレクトリに"
coverage"ディレクトリが作成され，その中のindex.htmlにてカバレッジを確認
できる．

# aktg_rcov.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
参考情報
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
aktg_coverage.rbにて使用している単体テストライブラリに関しては，以下を
参考にする．

1. 単体テストプログラムを作成
単体テストライブラリTest::Unitを利用
http://www.ruby-lang.org/ja/man/html/Test_Unit.html

ex. Calc.rb (テスト対象クラス)
----------------------------------------------------------------------
class Calc
  def sum(val1, val2)
    return val1 + val2
  end

  def foo(val, flg)
    if (flg == true)
      return val * 2
    else
      return val / 2
    end
  end
end
----------------------------------------------------------------------

ex. test.rb (単体テストプログラム)
----------------------------------------------------------------------
require "test/unit"
require "Calc.rb"

class CalcTest < Test::Unit::TestCase
  def setup()
    @obj = Calc.new()
  end

  def test_sum()
    assert_equal(3, @obj.sum(1, 2))
  end

  def test_foo()
    assert_equal(2, @obj.foo(1, true))
  end
end
----------------------------------------------------------------------

test.rbを実行すると単体テストの結果が得られる．

2. rcovで実行
$ rcov test.rb

オプション例
-x PATTERN      PATTERNにマッチするファイルをカバレッジ結果生成対象から除外
-i PATTERN      PATTERNにマッチするファイルをカバレッジ結果生成対象に加える
--charset CODE  生成するHTMLの文字コードを指定



以上．
