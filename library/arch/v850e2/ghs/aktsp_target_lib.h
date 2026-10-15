/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2014 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2014 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2011-2013 by Spansion LLC, USA
 *  Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2011-2014 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
 *  Copyright (C) 2011-2014 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2011-2014 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2011-2014 by Witz Corporation, JAPAN
 *
 *  本ソフトウェアは，次世代車載システム向けRTOSの仕様検討及び開発に
 *  関するコンソーシアム型共同研究において開発したものである．
 *  本ソフトウェアの著作権は，上記の著作権者に帰属する．
 *
 *  上記著作権者は，以下の(1)?(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *  $Id: aktsp_target_lib.h 347 2014-09-17 00:28:35Z fsi-dankei $
 */

#ifndef TOPPERS_AKTSP_TARGET_LIB_H
#define TOPPERS_AKTSP_TARGET_LIB_H

/********************************************************************

  ターゲット依存テストライブラリ(v850e2/ghs)

 ********************************************************************/

#include "aktsp_target_common_lib.h"

asm void set_sp(uint8* stk)
{
%reg stk
	  mov stk, sp
}

#define AKTSP_SHIFT_SP	set_sp(stk)

/*
 *  スタックポインタ方式により，スタックオーバーフローを発生させて
 *  即returnする処理(引数にスタックの先頭番地，サイズを与える)
 */
extern uint8 *aktg_temp_stk;
#define AKTSP_RETURN_IN_STACK_OVERFLOW_S(stk, sz)				\
	aktg_temp_stk = stk;										\
	/* レジスタは破壊されても問題ない */						\
	Asm("mov  _aktg_temp_stk, r11");							\
	Asm("ld.w 0[r11], r11");									\
	Asm("mov r11, sp");											\
	/* テスト対象はタスクのみなのでexit_taskへジャンプする */	\
	Asm("br  _exit_task");

/*
 *  マジックナンバー方式により，スタックオーバーフローを発生させて
 *  即returnする処理(引数にスタックの先頭番地，サイズを与える)
 */
#define AKTSP_RETURN_IN_STACK_OVERFLOW_M(stk, sz)	\
	stk[0] = (uint8)~(stk[0]);						\
	return;

/*
 *  C1ISR出入り口処理(シングルコア用)
 *  ※レジスタ退避等の処理を行い，EntityFuncNameを呼出し，
 *    レジスタを復帰する
 *  ※関数名はカーネルのC1ISRで提供されるマクロのによる
 *    変換後の名前と一致するように定義する
 */
#define AKTSP_C1ISR_ENTRY(C1ISRName, EntityFuncName)		\
	void C1ISRMain ## C1ISRName(void) {									\
		/* 戻り番地をデクリメント */									\
		Asm("addi    -80, sp,  sp");									\
		/* レジスタの保存 */											\
		Asm("st.w    ep,  12[sp]");										\
		Asm("mov     sp,  ep");											\
		Asm("sst.w   r1,  72[ep]");										\
		Asm("sst.w   r6,  68[ep]");										\
		Asm("sst.w   r7,  64[ep]");										\
		Asm("sst.w   r8,  60[ep]");										\
		Asm("sst.w   r9,  56[ep]");										\
		Asm("sst.w   r10, 52[ep]");										\
		Asm("sst.w   r11, 48[ep]");										\
		Asm("sst.w   r12, 44[ep]");										\
		Asm("sst.w   r13, 40[ep]");										\
		Asm("sst.w   r14, 36[ep]");										\
		Asm("sst.w   r15, 32[ep]");										\
		Asm("sst.w   r16, 28[ep]");										\
		Asm("sst.w   r17, 24[ep]");										\
		Asm("sst.w   r18, 20[ep]");										\
		Asm("sst.w   r19, 16[ep]");										\
		Asm("sst.w   r31, 8[ep]");										\
		/* 多重割込みのため，現在のEIPCとEIPSWを保存 */					\
		Asm("stsr    eipc,  r6");										\
		Asm("sst.w   r6,    4[ep]");									\
		Asm("stsr    eipsw, r6");										\
		Asm("sst.w   r6,    0[ep]");									\
		Asm("ei");														\
		/* 割込み発生前のcallevel_statをスタックに保存 */				\
		Asm("mov     _callevel_stat, r6");								\
		Asm("ld.h    0[r6], r7");										\
		Asm("sst.w   r7, 76[ep]");										\
		/* callevel_statにC1ISRをORでセット */							\
		Asm("mov     0x8000, r8");										\
		Asm("or      r8, r7");											\
		Asm("st.h    r7, 0[r6]");										\
		/* C1ISRで実行するC言語関数の呼び出し */						\
		Asm("jarl _"# EntityFuncName ", r31");							\
		Asm("di");														\
		/* レジスタの復帰 */											\
		Asm("mov     sp, ep");											\
		/* 保存したcallevel_statを復帰 */								\
		Asm("mov     _callevel_stat, r6");						\
		Asm("sld.w    76[ep], r7");										\
		Asm("st.h    r7, 0[r6]");										\
		Asm("sld.w    4[ep], r10");										\
		Asm("ldsr    r10, eipc");										\
		Asm("sld.w   0[ep], r10");										\
		Asm("ldsr    r10, eipsw");										\
		Asm("sld.w   72[ep], r1");										\
		Asm("sld.w   68[ep], r6");										\
		Asm("sld.w   64[ep], r7");										\
		Asm("sld.w   60[ep], r8");										\
		Asm("sld.w   56[ep], r9");										\
		Asm("sld.w   52[ep], r10");										\
		Asm("sld.w   48[ep], r11");										\
		Asm("sld.w   44[ep], r12");										\
		Asm("sld.w   40[ep], r13");										\
		Asm("sld.w   36[ep], r14");										\
		Asm("sld.w   32[ep], r15");										\
		Asm("sld.w   28[ep], r16");										\
		Asm("sld.w   24[ep], r17");										\
		Asm("sld.w   20[ep], r18");										\
		Asm("sld.w   16[ep], r19");										\
		Asm("sld.w    8[ep], r31");										\
		Asm("addi    80, ep, sp");										\
		Asm("sld.w   12[ep], r30");										\
		Asm("eiret");													\
}

#if TSYS_ISR1 != 0x8000
#error Change TSYS_ISR1 valule in AKTSP_C1ISR_ENTRY() macro!
#endif /* TSYS_ISR1 != 0x8000 */


#endif /* TOPPERS_AKTSP_TARGET_LIB_H */
