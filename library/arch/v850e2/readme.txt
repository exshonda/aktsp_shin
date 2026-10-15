======================================================================
V850依存部メモ

以下のターゲット依存部は共通事項が多いことから，arch/v850e2へ統合できる
ものをまとめる
・fl850fl4_gcc
・fl850fl4_ghs
・fl850pj4_gcc
・fl850pj4_ghs
・hsbv850e2fg4_cx
======================================================================

----------------------------------------------------------------------
テストライブラリ
----------------------------------------------------------------------
・target以下にある各依存部には，aktsp_target.shを配置し，gccかghsかで，
  インクルードパスを切り替える．

・aktsp_target.sh内の処理は全ターゲット共通のため，
  aktsp_v850e2_common.shへ統合する

・aktsp_target_lib.h内の共通事項は，aktsp_target_common_lib.hへまとめ，
  両者からincludeする．

・force_merge_divnum.datも全ターゲット共通であるが，aktb.shの都合上，
  各ターゲット依存部に配置する．

----------------------------------------------------------------------
テスト分割数
----------------------------------------------------------------------
全ターゲットにて，以下で確認．

1: System Service Tests
→ 50分割
※以下は100分割
　hsbv850e2fg4_cx

2: Protection Tests
  CPU Exception Tests
    Test that can be merged → 分割必要なし

4: MODISTARC
→ 分割必要なし
※以下のテストは多くのタスクが登場し，メモリを多く使用するため，ターゲ
  ットによってはビルドができない．この場合，この数のタスクが使用される
  ことがないため，テストは不要であるので，マニフェストファイルから削除
  する．
  ActivateTask_modistarc_0002
  ActivateTask_modistarc_0003

f: Forced Merge Tests
  Stack Monitering Tests → 分割必要なし
  CPU Exception Tests → 分割必要なし
  Illegal Terminate Task Tests → force_merge_divnum.datで対応
  Illegal Terminate C2ISR Tests → 分割必要なし
  Illegal Terminate Hook Tests → 分割必要なし



以上．
