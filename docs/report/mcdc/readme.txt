
	AKTSP - Automotive Kernel Test Suite Package -
	＜MC/DC解析レポート概要＞

本ドキュメントは，MC/DC解析レポートについてまとめたものである．

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
(1) はじめに
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MC/DC解析レポートは，Parasoft社製のテストツールであるC++testを使用して，
AKTSPのテストプログラムによるMC/DC解析結果をhtmlファイル形式に出力した
ものである．

なお，本ドキュメントは，AKTSP(Automotive Kernel Test Suite Package)およ
びAKTG(Automotive Kernel Test Generator)のユーザーズマニュアルの記載内
容を理解していることを前提とする．

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(2) ファイル/フォルダ構成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MC/DC解析レポートのフォルダ構成を以下にまとめる．

	mcdc/
		readme.txt				本書
		sc1/					SC1
			line/				行カバレッジ解析レポート
			    report.html		行カバレッジ解析レポートのメインページ
			mcdc/				MC/DC解析レポート
			    report.html		MC/DC解析レポートのメインページ	

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(3) MC/DC解析レポートの詳細
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MC/DC解析レポートは，AKTSPのシステムサービステストに対するカバレッジ情
報に，システムサービステストでパスできていないコードに対する追加テスト
ケース分のカバレッジ情報をマージした解析結果である．

―――――――――――――――――――――――――――――――――――
(3.1) SC1
―――――――――――――――――――――――――――――――――――

・解析結果
   カバレッジ種類 |  パス件数/総件数   |  カバレッジ  | 備考
  ------------------------------------------------------------
   MC/DC          |    286 /  286      |    100%      | 
   行カバレッジ   |   1192 / 1196(※1) |     99%(※2) | (※3)

※1 行カバレッジ解析レポートで，kernelディレクトリに対する件数
※2 行カバレッジ解析レポートで，kernelディレクトリに対するカバレッジ
※3 パスできないコードの詳細
  - atk2-sc1/kernel/osctl.c
    ・call_protectionhk_main
      switch文内のbreak文の一部は，internal_shutdownosの処理後に戻らな
      いため，実行されない．
    ・internal_shutdownos
      target_exit()の処理後に戻らないため，while文は実行されない．
  - atk2-sc1/kernel/osctl_manage.c
    ・StartOS
      ASSERTマクロは，NDEBUGを定義することにより空に置換される.
      start_dispatch()処理後に戻らない場合，ASSERTマクロはNDEBUGを定義
      することにより空であるが，末尾の'；'が1行と認識されてしまう．

―――――――――――――――――――――――――――――――――――
(3.2) SC1-MC
―――――――――――――――――――――――――――――――――――

T.B.D

―――――――――――――――――――――――――――――――――――
(3.3) SC3
―――――――――――――――――――――――――――――――――――

T.B.D

―――――――――――――――――――――――――――――――――――
(3.4) SC3-MC
―――――――――――――――――――――――――――――――――――

T.B.D


以上．
