
	AKTSP - Automotive Kernel Test Suite Package -
	＜チェックライブラリ概要＞

このドキュメントは，実装依存APIのチェックライブラリについてまとめたもの
である．

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

○テストプログラムの内容
各テストプログラムで実施するテスト内容については，各フォルダの
out.cのヘッダ部分を参照すること．

○各テストプログラムが格納されているフォルダのTESRYデータについて
各テストプログラムが格納されているフォルダのcfgフォルダにあるTESRYデー
タは，コンフィギュレーションファイル生成を目的としたものであるため，テ
ストプログラム全体を表現しているものではない．

○AKTG実行時の注意事項
・TESRYデータが格納されているフォルダでAKTGを実行した場合，既存のテスト
  プログラムが上書きされてしまうため別のフォルダで実行すること
・task_stack_shareフォルダ以外のテストプログラムは，スタック共有しない
  前提で作成されているので，stack_shareオプションをfalseにして実行する
  こと


以上
