
	AKTSP - Automotive Kernel Test Suite Package -
	＜AKTSP バグ(#1870)修正確認プログラム＞

本ドキュメントは，バグ(#1870)修正確認プログラムを説明するものである．

----------------------------------------------------------------------
AKTSP
    Automotive Kernel Test Suite Package

Copyright (C) 2013-2014 by Center for Embedded Computing Systems
            Graduate School of Information Science, Nagoya Univ., JAPAN
Copyright (C) 2013-2014 by FUJI SOFT INCORPORATED, JAPAN
Copyright (C) 2013-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
Copyright (C) 2013-2014 by Renesas Electronics Corporation, JAPAN
Copyright (C) 2013-2014 by Sunny Giken Inc., JAPAN
Copyright (C) 2013-2014 by TOSHIBA CORPORATION, JAPAN
Copyright (C) 2013-2014 by Witz Corporation, JAPAN

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
対象バグ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
https://www.nces.is.nagoya-u.ac.jp/trac/atk2-conso/ticket/1870

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
確認プログラム概要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ABREXには，複数のYAMLを入力してマージする機能があるので，意図したXMLを
作成するために，パーツ毎に用意したYAMLを組み合わせて，ABREXに入力し，様
々なパターンのXMLを作成してテストする．

■コアIDの指定方法
　a)整数   : coreid_number.yaml
　b)マクロ : coreid_macro.yaml
　フックスタックのサイズ指定が有りの場合，以下も対象
　　a) 整数   : hook_stack_coreid_number_core0.yaml hook_stack_coreid_number_core1.yaml
　　b) マクロ : hook_stack_coreid_macro_core0.yaml hook_stack_coreid_macro_core1.yaml

■OSAPフックのコンフィギュレーション有無
　A)両コアにOSAP固有のフックあり    : hook_exist_core0.yaml hook_exist_core1.yaml
　B)コア0にのみOSAP固有のフックあり : hook_exist_core0.yaml hook_not_exist_core1.yaml
　C)コア1にのみOSAP固有のフックあり : hook_not_exist_core0.yaml hook_exist_core1.yaml
　D)両コアにOSAP固有のフックなし    : hook_not_exist_core0.yaml hook_not_exist_core1.yaml

■フックスタックのサイズ指定有無(コンテナの有無)
　▼両コアにフックスタックサイズ指定あり
　　1)両コアにフックスタックの先頭番地指定あり    : hook_stack_size_core0.yaml hook_stack_size_core1.yaml hook_stack_address_core0.yaml hook_stack_address_core1.yaml
　　2)コア0にのみフックスタックの先頭番地指定あり : hook_stack_size_core0.yaml hook_stack_size_core1.yaml hook_stack_address_core0.yaml
　　3)コア1にのみフックスタックの先頭番地指定あり : hook_stack_size_core0.yaml hook_stack_size_core1.yaml hook_stack_address_core1.yaml
　　4)両コアにフックスタックの先頭番地指定なし    : hook_stack_size_core0.yaml hook_stack_size_core1.yaml
　▼コア0にのみフックスタックサイズ指定あり
　　5)コア0にフックスタックの先頭番地指定あり     : hook_stack_size_core0.yaml hook_stack_address_core0.yaml
　　6)コア0にフックスタックの先頭番地指定なし     : hook_stack_size_core0.yaml
　▼コア1にのみフックスタックサイズ指定あり
　　7)コア1にフックスタックの先頭番地指定あり     : hook_stack_size_core1.yaml hook_stack_address_core1.yaml
　　8)コア1にフックスタックの先頭番地指定なし     : hook_stack_size_core1.yaml
　▼両コアにフックスタックサイズ指定なし
　　9)フックスタック指定コンテナ/静的APIなし      : 

上記のパラメータ，2×4×9＝72パターンの組み合わせで，それぞれコンフィギ
ュレーション，ビルド，実行を確認し，スタック領域が確保されていること，
OSAP固有のフック(スタートアップフックのみ)が実行されることを確認する．
テスト実行は，aktspをOSのルートフォルダに配置した状態で，exe.shを実行す
るのみでよい．実行結果は，test_execute.logに出力される．



以上．
