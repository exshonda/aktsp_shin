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

## 生成とビルド

```sh
T=library/target/rh850f1kms1_ccrh
# .cmy を展開して個別の YAML にする
$T/expand_tesry.sh /tmp/tesry syssrv_test/sc1/task/ActivateTask/normal_tesry/ActivateTask_normal.cmy
# YAML を選んで AKTG → make
$T/gen_build.sh /tmp/t1 /tmp/tesry/ActivateTask_normal/ActivateTask_normal_006[1-5].yaml
```

`<outdir>/atk2-sc1.elf` と，最終チェックポイント番号を書いた `<outdir>/expected_count` ができる．
最後に `check_count.1`，`cp_state`，`infinite_loop`，`AktspInfiniteLoop` の番地を表示する
(ビルドごとに変わる)．

Makefile は `atk2_sc1_shin/obj/obj_rh850f1kms1_ccrh/Makefile` から毎回 sed で生成する．
置換が外れたらビルドを止める (サンプルを黙ってビルドしないため)．

## 実行と合否判定

このホストにはシリアル (RLIN32) がつながっていないので，ログではなく RAM で判定する．

1. `rh850-csplus-upload --server <CS+ MCP> --file atk2-sc1.elf`
2. MCP: `download_loadmodule` → `clear_breakpoints` → `reset`
3. MCP: `infinite_loop` と `AktspInfiniteLoop` にハードウェアブレークを置く
4. **`check_count.1` と `cp_state` に，ありえない値を書いておく** (例: 0xDEADBEEF / 0xAA)．
   リセットでは RAM は消えないので，これをしないと前回の実行結果がそのまま読めてしまう
5. MCP: `run` → 停止を待つ (待ちすぎたら `halt` してコールスタックを見る．ハングは FAIL)
6. PASS の条件:
   - PC が `infinite_loop` (ShutdownOS 後) で停止
   - `check_count.1` == `expected_count`
   - `cp_state` == 1 (AK_TRUE)

`AktspShutdownOS` へのブレークは使わないこと．CC-RH が呼出し元へインライン展開して
`jr _ShutdownOS` にしてしまうので止まらない．

## 制限

- `--func_interrupt/--func_hardware_counter/--func_protection_hook false` で生成している．
  割込み・カウンタ・アラーム・スケジュールテーブルを使うテストは，F1KM-S1 用の
  `AKTSP_INTNO_*` などのターゲット定義がまだ無いので動かない
- `library/arch/v850/aktsp_target_lib.c` の G3KH 用 `SEG_CONT/SEG_FLAG` 番地は未確認
- 確認済み: `syssrv_test/sc1/task` の割込みを使わないテスト 40 件 (2026-10-15)
