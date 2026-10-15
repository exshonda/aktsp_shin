;
;  AKTSP
;      Automotive Kernel Test Suite Package
;
;  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
;              Graduate School of Information Science, Nagoya Univ., JAPAN
;  Copyright (C) 2011-2014 by FUJISOFT INCORPORATED, JAPAN
;  Copyright (C) 2011-2013 by Spansion LLC, USA
;  Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
;  Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
;  Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
;  Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
;  Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
;  Copyright (C) 2011-2014 by Witz Corporation, JAPAN
;
;  本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
;  関するコンソーシアム型共同研究において開発したものである．
;  本ソフトウェアの著作権は，上記の著作権者に帰属する．
;
;  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
;  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
;  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
;  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
;      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
;      スコード中に含まれていること．
;  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
;      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
;      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
;      の無保証規定を掲載すること．
;  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
;      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
;      と．
;    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
;        作権表示，この利用条件および下記の無保証規定を掲載すること．
;    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
;        報告すること．
;  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
;      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
;      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
;      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
;      免責すること．
;
;  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
;  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
;  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
;  用する者に対して，AUTOSARパートナーになることを求めている．
;
;  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
;  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
;  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
;  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
;  の責任を負わない．
;
;  $Id: aktsp_target.asm 4883 2014-02-28 02:23:44Z shigihara $
;

; _aktsp_shift_sp(uint32 stk)
; stkの値をスタックポインタ(sp)に設定
	.extern __aktsp_shift_sp
__aktsp_shift_sp:
	mov     r6, sp
	jmp     [lp]

; _aktsp_return_in_stack_overflow_s(uint32 stk, uint32 sz)
; スタックポインタ方式により，スタックオーバーフローを発生させて
; 即returnする処理(引数にスタックの先頭番地，サイズを与える)
	.extern __aktsp_return_in_stack_overflow_s
__aktsp_return_in_stack_overflow_s:
	mov     r6, sp
	br      _exit_task

; C1ISR用定義
; (インラインアセンブラが使えないためシンボル名固定で対応)

$include (v850asm.inc)
$include (asm_config.inc)

PRE_C1ISR .macro
	;/* レジスタの保存 */
$ifdef TOPPERS_USE_HFLOAT
	addi    -84 , sp , sp
$else ;/* !TOPPERS_USE_HFLOAT */
	addi    -80 , sp , sp
$endif ;/* TOPPERS_USE_HFLOAT */
	st.w    r30, 12[sp]  ;/* r30(ep) */
	mov     sp, ep 
	sst.w   r1, 76[ep]
	sst.w   r5, 72[ep]
	sst.w   r6, 68[ep]
	sst.w   r7, 64[ep]
	sst.w   r8, 60[ep]
	sst.w   r9, 56[ep]
	sst.w   r10, 52[ep]
	sst.w   r11, 48[ep]
	sst.w   r12, 44[ep]
	sst.w   r13, 40[ep]
	sst.w   r14, 36[ep]
	sst.w   r15, 32[ep]
	sst.w   r16, 28[ep]
	sst.w   r17, 24[ep]
	sst.w   r18, 20[ep]
	sst.w   r19, 16[ep]
	sst.w   r31, 8[ep]
$ifdef TOPPERS_USE_HFLOAT
	stsr    fpsr, r19     ;/* load FPSR */
	sst.w   r19, 80[ep]
$endif ;/* TOPPERS_USE_HFLOAT */

	;/* 多重割込みのため，現在のEIPCとEIPSWを保存 */
	stsr    eipc, r6
	sst.w   r6, 4[ep]
	stsr    eipsw, r6
	sst.w   r6, 0[ep]

	ei

	;/*
	 ;*  _callevel_stat 保存
	 ;*/
	Lea     _callevel_stat, r6
	ld.h    0[r6], r7
	Push    r7

	;/*
	 ;*  _callevel_stat 設定
	 ;*/
	mov     TSYS_ISR1, r8
	or      r8, r7
	st.h    r7, 0[r6]
.endm

POST_C1ISR .macro
	di

	;/*
	 ;* _callevel_stat の復帰
	 ;*/
	Lea     _callevel_stat, r7
	Pop     r6
	st.h    r6, 0[r7]

	;/*
	 ;* レジスタを復帰
	 ;*/
	mov     sp, ep
	sld.w    4[ep], r10
	ldsr    r10, eipc
	sld.w    0[ep], r10
	ldsr    r10, eipsw

$ifdef TOPPERS_USE_HFLOAT
	sld.w   80[ep], r19
	ldsr    r19, fpsr     ;/* store FPSR */
$endif ;/* TOPPERS_USE_HFLOAT */
	sld.w   76[ep], r1
	sld.w   72[ep], r5
	sld.w   68[ep], r6
	sld.w   64[ep], r7
	sld.w   60[ep], r8
	sld.w   56[ep], r9
	sld.w   52[ep], r10
	sld.w   48[ep], r11
	sld.w   44[ep], r12
	sld.w   40[ep], r13
	sld.w   36[ep], r14
	sld.w   32[ep], r15
	sld.w   28[ep], r16
	sld.w   24[ep], r17
	sld.w   20[ep], r18
	sld.w   16[ep], r19
	sld.w    8[ep], r31
$ifdef TOPPERS_USE_HFLOAT
	addi    84, ep, sp
$else ;/* !TOPPERS_USE_HFLOAT */
	addi    80, ep, sp
$endif ;/* TOPPERS_USE_HFLOAT */
	sld.w   12[ep], r30 ;/* r30(ep) */

	eiret
.endm

$ifdef C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A
	.extern _C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A
_C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A:
	PRE_C1ISR
	;*  割込みハンドラ呼び出し
	jarl    _AKTG_C1ISR_COMMON_AKTSP_INTNO_A_ENTITY, r31
	POST_C1ISR
$endif ;/* C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A */

$ifdef C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B
	.extern _C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B
_C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B:
	PRE_C1ISR
	;*  割込みハンドラ呼び出し
	jarl    _AKTG_C1ISR_COMMON_AKTSP_INTNO_B_ENTITY, r31
	POST_C1ISR
$endif ;/* C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B */
