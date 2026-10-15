
    AKTSP - Automotive Kernel Test Suite Package -
    ＜atypical_hwcounter_test 実行マニュアル＞

本ドキュメントは，atypical_hwcounter_testを実行するために必要な事項を説明するものである．
AKTSPではハードウェアカウンタの動作をソフトウェアカウンタと割込みを用いて擬似的に
再現しているため，テスト出来ない項目が存在する．
具体的には，ハードウェアカウンタのカウント値を意図的に書き換える必要がある場合のテストである．atypical_hwcounter_testはそのような場合に対するテストである．

対応するATK2外部仕様書，ATK2のバージョンはAKTSPに準ずる．

----------------------------------------------------------------------
 AKTSP
    Automotive Kernel Test Suite Package

 Copyright (C) 2017 by Center for Embedded Computing Systems
           Graduate School of Information Science, Nagoya Univ., JAPAN
 Copyright (C) 2017 by FUJI SOFT INCORPORATED, JAPAN
 Copyright (C) 2017 by NEC Communication Systems, Ltd., JAPAN
 Copyright (C) 2017 by SCSK Corporation, JAPAN
 Copyright (C) 2017 by SUZUKI MOTOR CORPORATION
 Copyright (C) 2017 by TOSHIBA CORPORATION, JAPAN
 Copyright (C) 2017 by Witz Corporation
 Copyright (C) 2017 by Fujitsu TEN Limited

 本ソフトウェアは，車載制御システム向け高品質プラットフォームに
 関するコンソーシアム型共同研究において開発したものである．
 本ソフトウェアの著作権は，上記の著作権者に帰属する．

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

$Id: readme.txt 2393 2017-03-14 04:35:43Z witz-itoyo $
----------------------------------------------------------------------

1.ディレクトリ構成
	atypical_hwcounter_test/
		test1/					テストディレクトリ
			sc1/
				target/			テスト実行時に必要なターゲット依存部のコード
				test_code/		テストコード
		test2-1/
		test2-2/

2. 環境構築
	・各テストディレクトリ毎に環境構築する必要がある
	・テスト対象となるATK2ディレクトリの直下にtest_codeフォルダをコピーする
	・テスト対象となるATK2のターゲット依存部をテスト実行時に必要なターゲット依存部のコードで更新する
	・ATK2ディレクトリ直下のlibraryフォルダに以下のファイルをコピーする
		aktsp/library/common/aktsp_common_lib.c
		aktsp/library/common/aktsp_common_lib.h
		aktsp/library/implement/atk2/aktsp_implement_lib.c
		aktsp/library/implement/atk2/aktsp_implement_lib.h
		aktsp/library/target/nios2_dev_gcc/aktsp_target_lib.c
		aktsp/library/target/nios2_dev_gcc/aktsp_target_lib.h
	
	(環境構築例) +は差分を示す
		atk2-sc1/
			arch/
			・
			library/
				+aktsp_common_lib.c
				+aktsp_common_lib.h
				+aktsp_implement_lib.c
				+aktsp_implement_lib.h
				+aktsp_target_lib.c
				+aktsp_target_lib.h
				histogram.c
				log_output.c
				・
			target/
				<ターゲット名>/
					・
					+target_hw_counter.arxml
					+target_hw_counter.c
					+target_hw_counter.h
					+target_hw_counter.yaml
					・
			+test_code/
				+Makefile
				+Rte_Type.h
				+out.arxml
				+out.c
				+out.h
				+out.yaml
			・
	
3.実行方法
	・ビルド用のディレクトリを作成する(例：obj)
	・以下のコマンドを実行する
		../configure -T <ターゲット名> -A out -t ../test_code
	・Rte_Type.hをtest_codeよりコピーする
	・makeし，実行する
	・合否結果に関する出力はAKTSPと同じである

4.テスト仕様

4-11.テスト観点
	・test1
		ある満了処理Aを実行する．その後時間経過させた時点で，満了処理Aが満了した際のティック値より過去の満了処理Bと未来の満了処理Cを登録する．ただし，満了処理Bの満了ティックは満了処理Cの満了ティックよりも大きいものとする（BとCの間でカウンタのラップアラウンドが起こることを意味する）．このとき，満了処理B，Cの順で処理が行われることを確認する．
	・test2-1
		2つの満了処理A,Bが同じ満了ティックで設定されているとする．そのうち，先に登録されているほうの満了処理Aでタスクを起動し，新たに満了処理Cを登録する．このとき，満了処理Cの満了ティックはカウンタの最大値を超えない（ラップアラウンドしない）ものとする．その後，満了処理Bの満了ティックも既に経過しているため，満了処理B，Cの順で処理が行われることを確認する．
	・test2-2
		test2-1で満了処理Cの満了ティックがカウンタの最大値を超える（ラップアラウンドする）場合も同様の順で処理が行われることを確認する．

4-2.テストコンフィギュレーション
	テストコンフィギュレーションは全テストで共通である．SC1でのコンフィギュレーションのみを記載する．
		タスク
			MainTask
				自動起動設定する
				優先度は任意
			Task2
				優先度は任意
			Task3
				優先度は任意
			Task4
				優先度は任意
		アラーム
			ActTskArm2
				満了アクションはTask2の起動
				ハードウェアカウンタに紐付ける
			ActTskArm3
				満了アクションはTask3の起動
				ハードウェアカウンタに紐付ける
			ActTskArm4
				満了アクションはTask4の起動
				ハードウェアカウンタに紐付ける
		ハードウェアカウンタ
			カウンタ最大値は0x1FFFFFFF

4.3 テストシーケンス
	・test1
		・ハードウェアカウンタの現在値0とする
		・MainTaskでSetRelAlarm(ActTskArm2, 0x1FFF, 0)を発行
		・MainTask1を終了する
		・ActTskArm2の割込みが発生
		・ハードウェアカウンタ満了時のハードウェアカウンタの現在値を0x2328とする
		・ActTaskArm2の満了処理実行
		・ハードウェアカウンタの現在値0x36DB6DB6とする
		・Task2でSetRelAlarm(ActTskArm3, 0x1F07C1F, 0);
		・Task2でSetRelAlarm(ActTskArm4, 0x924C248, 0);
		・Task2を終了する
		・ActTskArm3の割込みが発生
		・ハードウェアカウンタの現在値を0x38CBF9D5とする
		・ActTskArm3の満了処理実行
		・Task3を起動，終了する
		・ActTskArm4の割込みが発生
		・ハードウェアカウンタの現在値を0x3FFEとする
		・Task4を起動，終了する
	test2-1
		・ハードウェアカウンタの現在値0とする
		・MainTaskでSetRelAlarm(ActTskArm2, 0x500, 0)を発行
		・MainTaskでSetRelAlarm(ActTskArm3, 0x500, 0)を発行
		・MainTask1を終了する
		・ActTskArm2の割込みが発生
		・ハードウェアカウンタの現在値を0x200004FFとする
		・ActTaskArm2の満了処理実行
		・Task2でSetRelAlarm(ActTskArm4, 0x1000, 0);
		・Task2を終了する
		・ハードウェアカウンタ満了時のハードウェアカウンタの現在値を0x38CBF9D5とする
		・ActTskArm3の満了処理実行
		・Task3を起動，終了する
		・ActTskArm4の割込みが発生
		・Task4を起動，終了する
	test2-2
		・ハードウェアカウンタの現在値0とする
		・MainTaskでSetRelAlarm(ActTskArm2, 0x500, 0)を発行
		・MainTaskでSetRelAlarm(ActTskArm3, 0x500, 0)を発行
		・MainTask1を終了する
		・ActTskArm2の割込みが発生
		・ハードウェアカウンタの現在値を0x200004FFとする
		・ActTaskArm2の満了処理実行
		・Task2でSetRelAlarm(ActTskArm4, 0x10000000, 0);
		・Task2を終了する
		・ハードウェアカウンタ満了時のハードウェアカウンタの現在値を0x38CBF9D5とする
		・ActTskArm3の満了処理実行
		・Task3を起動，終了する
		・ActTskArm4の割込みが発生
		・ハードウェアカウンタ満了時のハードウェアカウンタの現在値を0x9000000とする
		・Task4を起動，終了する

以上