# RH850/F1KM-S1 (atk2_sc1_shin, CC-RH) で AKTSP を動かす

[atk2_sc1_shin](https://github.com/exshonda/atk2_sc1_shin) の `rh850f1kms1_ccrh` ターゲットに対して，
Linux 上で AKTSP のテストプログラムを生成・ビルドし，CS+ MCP 経由で実機で実行する手順．
`aktb.sh` のメニューは使わない．

## 前提

- aktsp と ATK2 を並べて置く (`ATK2_DIR` で変更可)
  ```
  aktsp_shin/
  atk2_sc1_shin/
  ```
- Linux 版 CC-RH (`ccrh`, `rlink`) が `PATH` 上にあること
- Ruby 2.x/3.x (AKTG は互換層 `tools/aktg/common/bin/ruby3_compat.rb` で動く)
- Python 3.10+ (`run_test.py`)，CS+ MCP サーバ (`CSPLUS_MCP_SERVER`，既定 `http://172.24.11.129:8765`)
  とアップローダ `rh850-csplus-upload` (`lades_csplus_mcp`．見つからなければ `RH850_UPLOAD` で指定)

## スクリプト

| スクリプト | 役割 |
|---|---|
| `expand_tesry.sh <outdir> <cmy>...` | `.cmy` を個別の YAML に展開 |
| `gen_build.sh <outdir> <yaml>...` | AKTG → Makefile 生成 → make．`atk2-sc1.elf` と `expected_count` を作る |
| `run_test.py <outdir>...` | アップロード → 書込み → 実行 → RAM で合否判定 |
| `run_suite.sh <suite>... [-- <workdir> [<block>]]` | テスト群を一括で実行 (`all` で全群．`EXCLUDE` で除外可) |

```sh
T=library/target/rh850f1kms1_ccrh
$T/expand_tesry.sh /tmp/tesry syssrv_test/sc1/task/ActivateTask/normal_tesry/ActivateTask_normal.cmy
$T/gen_build.sh /tmp/t1 /tmp/tesry/ActivateTask_normal/ActivateTask_normal_006[1-5].yaml
$T/run_test.py /tmp/t1

$T/run_suite.sh all          # SC1 の全テスト群 (下の「結果」の表)
```

### gen_build.sh の要点

- Makefile は `atk2_sc1_shin/obj/obj_rh850f1kms1_ccrh/Makefile` から毎回 sed で生成する．
  置換が外れたら止める (サンプルを黙ってビルドしないため．変更行数を検査)
- Python 版 cfg は EUC-JP の arxml を読めないので，UTF-8 化したコピーを置く
- **スタックを広げる**．CC-RH が全テストのフック本体を ErrorHook/PreTaskHook/PostTaskHook/
  ProtectionHook にインライン展開する．SC1 ではフックが呼出し元タスクのスタックで動くため，
  1280 バイトでは `E_OS_STACKFAULT` になる (`*_error` は 2048，IncrementCounter は 4096，
  HW カウンタ割込みを伴うものは 8192 が要った)．ISR/フックの OS スタックも既定の 512 バイト分
  ではあふれ，予備領域の直下にある `cp_state` を書き潰した．
  既定ではタスクスタックを共有スタックの本数 (`AKTG_STACK_NUM`) から決める (合計 64KB，
  1 本最大 8192)．OS スタックのフック分は 4096．`AKTSP_CDEFS` を与えるとそれを使う
- **RAM あふれを検査する**．F1KM-S1 のローカル RAM は 0xFEDE0000〜0xFEDFFFFF の 128KB
  (実機で確認)．rlink は RAM 容量を知らず，あふれても黙ってリンクする (modistarc は共有スタック
  16 本 × 8192 で 163KB になり，StartOS 後に固まった)．`RAM_END` で変更可
- `AKTG_EXTRA` で AKTG に追加オプションを渡す (テスト群ごとの OS 構成)．`-f` を含むと
  強制マージで，`-DENABLE_RETURN_MAIN` を付ける
- AKTG の `--func_interrupt/--func_hardware_counter/--func_protection_hook` は既定で true
  (`FUNC_INTERRUPT` 等の環境変数で変更可)
- `expected_count` は `out.c` 中の最大のチェックポイント番号．通常は MainTask 末尾の
  `AktspCheckFinish(N)`．ShutdownHook を試すテストを含むブロックでは ShutdownHook 内の
  `AktspCheckPoint(N)` が最後になる (強制マージでは使わない．下記)

## 合否判定 (run_test.py)

このホストにはシリアル (RLIN32) がつながっていないので，ログではなく RAM で判定する．

1. `infinite_loop`，`AktspInfiniteLoop`，`_CheckErcd`，`_CheckAssert` にハードウェアブレーク
2. **`check_count.1` と `cp_state` にありえない値 (0xDEADBEEF / 0xAA) を書いてから**実行する．
   リセットでは RAM が消えないので，これをしないと前回の結果を読んでしまう
3. PASS: `infinite_loop` で停止 かつ `check_count.1 == expected_count` かつ `cp_state == 1`

FAIL のときは，次のチェックポイントを含むテスト名，`_CheckErcd`/`_CheckAssert` で止まった
場合はその式・ファイル・行，コールスタックを表示する．

### 強制マージ (マージ不可能なテスト)

シャットダウンで終わるテスト (protection_test，error_test の notmerge) は 1 つずつ別の
ロードモジュールにすると数千回の書込みになる．AKTSP の強制マージ (AKTG `-f`) を使い，
シャットダウン後に main へ戻って (`ENABLE_RETURN_MAIN`) 次のテストを `StartOS` する．

- `AktspInitializeTestLib` はブートごとに `check_count`/`cp_state` を初期化するので，
  そこで止まって直前のテストを判定する．最後のテストは `AktspInfiniteLoop` で判定する
- テストごとの期待値は `out.c` から求める．そのテストの `"All check points passed."` の
  出力の直前のチェックポイント番号で，優先順位は
  1. 無条件の出力 (`finish: true`．合格を出した後に OS がシャットダウンするのが正しい．
     後ろのコードは実行されず，`AktspCheckPoint(0)` はそこへ来たら失敗という印)
  2. `if (state == AK_TRUE)` 付きの出力 (ShutdownHook で終わるテスト)
  3. どちらもなければ最大のチェックポイント番号 (MainTask の `AktspCheckFinish(N)`)
- シャットダウン要因 (`E_OS_STACKFAULT` 等) は参考情報として表示するだけで，失敗扱いしない
  (finish テストではシャットダウンが正常)
- 強制マージでは OS 構成 (フックの有無等) がロードモジュールで共通になるので，`.cmy` ごとに
  ブロックを分ける (`run_suite.sh` が行う)．ProtectionHook あり/なしを混ぜると，なしのテストで
  ProtectionHook が呼ばれて `CheckAssert(FALSE)` になる

`AktspShutdownOS` へのブレークは使わないこと．CC-RH がインライン展開して
`jr _ShutdownOS` にするので止まらない．

## 失敗の調べ方

- `check_count` が途中で止まり `cp_state == 0` で，`_CheckErcd`/`_CheckAssert` でも止まらない
  → OS が自分でシャットダウンしている．`kernel_internal_shutdownos` にブレークを置き，
  r6 (StatusType) と lp (呼出し元) を見る．13 (`E_OS_STACKFAULT`) で lp が
  `stack_monitoring_error` 付近ならスタック不足
- `check_count == 0` ですぐ終わる → 最初のテストより前 (StartOS 直後) で落ちている．同上
- `run_test.py` は `kernel_internal_shutdownos` でも一度止まり，FAIL 時に
  `[ShutdownOS: E=..(..) from <呼出し元>]` を表示する．上の手作業はこれで代替できる
- `cp_state` が 0/1 以外 (例: 254) → メモリが書き潰されている．`cp_state` は OS スタック
  (`aktg_os_stack`) の直下にあるので，まず OS スタック (`AKTSP_HOOK_STACK_SIZE`) を疑う
- 1 ブロックで原因を絞るには，`AKTSP_CDEFS` を変えて同じブロックを作り直し，比べる
  (例: タスクスタックだけ / OS スタックだけを増やす)

## 結果

`run_suite.sh all` で SC1 の全テスト群が実機で PASS (2026-10-15〜16)．

| テスト群 | YAML | テスト | 方式 |
|---|---:|---:|---|
| syssrv_test/sc1 | 7178 | 7247 | マージ (100 件 × 72 ブロック) |
| modistarc/sc1 | 67 | 67 | マージ |
| protection_test/sc1/cpu_exception (merge) | 9 | 9 | マージ |
| protection_test/sc1/cpu_exception (notmerge) | 53 | 53 | 強制マージ |
| protection_test/sc1/stack_monitoring | 240 | 240 | 強制マージ |
| error_test/sc1/illegal_terminate_task | 3240 | 3240 | 強制マージ |
| error_test/sc1/illegal_terminate_c2isr | 84 | 84 | 強制マージ |

AKTG のオプション (OS 構成) は aktb.sh が各テスト群に与えるものに合わせている (`run_suite.sh`
の `preset`)．

途中で見つかった不具合:

- atk2_sc1_shin: CC-RH 版の FE/EI 例外復帰で ep を戻していなかった (ProtectionHook が
  PRO_IGNORE を返すと誤った番地へ復帰)．atk2_sc1_shin 6079ee4 で修正．**この修正より前の
  atk2_sc1_shin ではプロテクションフックのテストが通らない**
- atk2_sc1_shin: `ENABLE_RETURN_MAIN` を定義すると存在しない変数を参照してコンパイルできなかった
  (7e77c8c で修正．強制マージに必要)
- AKTG (Ruby 3 対応): 整数パラメータの型チェック (aktsp_shin f11222a)

## 割込み・HW カウンタ・プロテクションフック

- 割込み番号は `library/arch/v850/aktsp_target_common_lib.h` の e3v5 用 (52〜66) を使う．
  EIC の要求フラグをソフトウェアで立てて起こす．F1KM-S1 では atk2 が使う RLIN32 等と重ならない
- HW カウンタは実装依存ライブラリが `AKTSP_INTNO_HWCNT` の割込みで模擬する (TAUB は使わない．
  `OMIT_HW_COUNTER` で atk2 側の HW カウンタは外している)
- プロテクションフックは G3KH では `FETRAP 15` で起こす (`_aktsp_raise_fetrap`)．
  G3K/G3M 用の SEG レジスタは使わない

## 制限

- SC1 (シングルコア) のみ．sc1-mc/sc3 のテスト，additional_test，check_library は未実施
