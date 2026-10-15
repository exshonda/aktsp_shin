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
| `run_suite.sh [<workdir>] [<block>]` | syssrv_test/sc1 の全テストを一括で実行 (`EXCLUDE` で除外可) |

```sh
T=library/target/rh850f1kms1_ccrh
$T/expand_tesry.sh /tmp/tesry syssrv_test/sc1/task/ActivateTask/normal_tesry/ActivateTask_normal.cmy
$T/gen_build.sh /tmp/t1 /tmp/tesry/ActivateTask_normal/ActivateTask_normal_006[1-5].yaml
$T/run_test.py /tmp/t1
```

### gen_build.sh の要点

- Makefile は `atk2_sc1_shin/obj/obj_rh850f1kms1_ccrh/Makefile` から毎回 sed で生成する．
  置換が外れたら止める (サンプルを黙ってビルドしないため．変更行数を検査)
- Python 版 cfg は EUC-JP の arxml を読めないので，UTF-8 化したコピーを置く
- `aktsp_target.asm` が参照する `_exit_task` は，最終リンクでだけ `_kernel_exit_task` の別名にする
- **スタックを広げる** (`AKTSP_CDEFS` の既定 `-DAKTSP_TASK_STACK_SIZE=8192U -DAKTSP_HOOK_STACK_SIZE=4096U`)．
  CC-RH が全テストのフック本体を ErrorHook/PreTaskHook/PostTaskHook/ProtectionHook に
  インライン展開する．SC1 ではフックが呼出し元タスクのスタックで動くため，1280 バイトでは
  `E_OS_STACKFAULT` になる (`*_error` は 2048，IncrementCounter は 4096，HW カウンタ割込みを
  伴うものは 8192 が要った)．ISR/フックの OS スタックも既定の 512 バイト分ではあふれ，
  予備領域の直下にある `cp_state` を書き潰した
- AKTG の `--func_interrupt/--func_hardware_counter/--func_protection_hook` は既定で true
  (`FUNC_INTERRUPT` 等の環境変数で変更可)
- `expected_count` は `out.c` 中の最大のチェックポイント番号．通常は MainTask 末尾の
  `AktspCheckFinish(N)`．ShutdownHook を試すテストを含むブロックでは ShutdownHook 内の
  `AktspCheckPoint(N)` が最後になる

## 合否判定 (run_test.py)

このホストにはシリアル (RLIN32) がつながっていないので，ログではなく RAM で判定する．

1. `infinite_loop`，`AktspInfiniteLoop`，`_CheckErcd`，`_CheckAssert` にハードウェアブレーク
2. **`check_count.1` と `cp_state` にありえない値 (0xDEADBEEF / 0xAA) を書いてから**実行する．
   リセットでは RAM が消えないので，これをしないと前回の結果を読んでしまう
3. PASS: `infinite_loop` で停止 かつ `check_count.1 == expected_count` かつ `cp_state == 1`

FAIL のときは，次のチェックポイントを含むテスト名，`_CheckErcd`/`_CheckAssert` で止まった
場合はその式・ファイル・行，コールスタックを表示する．

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

2026-10-15: `run_suite.sh` で syssrv_test/sc1 の全 7178 YAML (AKTG の展開後 7247 テスト，
100 件ずつ 72 ブロック) がすべて PASS．

途中で見つかった不具合:

- atk2_sc1_shin: CC-RH 版の FE/EI 例外復帰で ep を戻していなかった (ProtectionHook が
  PRO_IGNORE を返すと誤った番地へ復帰)．atk2_sc1_shin 6079ee4 で修正．**この修正より前の
  atk2_sc1_shin ではプロテクションフックのテストが通らない**
- AKTG (Ruby 3 対応): 整数パラメータの型チェック (aktsp_shin f11222a)

## 割込み・HW カウンタ・プロテクションフック

- 割込み番号は `library/arch/v850/aktsp_target_common_lib.h` の e3v5 用 (52〜66) を使う．
  EIC の要求フラグをソフトウェアで立てて起こす．F1KM-S1 では atk2 が使う RLIN32 等と重ならない
- HW カウンタは実装依存ライブラリが `AKTSP_INTNO_HWCNT` の割込みで模擬する (TAUB は使わない．
  `OMIT_HW_COUNTER` で atk2 側の HW カウンタは外している)
- プロテクションフックは G3KH では `FETRAP 15` で起こす (`_aktsp_raise_fetrap`)．
  G3K/G3M 用の SEG レジスタは使わない

## 制限

- 確認したのは syssrv_test/sc1 のみ．modistarc，protection_test，error_test 等は未実施
