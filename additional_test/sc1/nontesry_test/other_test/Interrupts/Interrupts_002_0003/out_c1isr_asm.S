#define TOPPERS_MACRO_ONLY

#define UINT_C(val)	(val)
#define CAST(type, val)	(val)	/* 型キャストを行うマクロ */

#include "kernel/kernel_impl.h"
#include "vic.h"
#include "nios2.h"
#include "target_hw_counter.h"

.global C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B
.set noat

C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_B:
	addi	ea,	ea,	-4	/* 戻り番地をデクリメント */

	/* レジスタの保存 */
	addi	sp,	sp,	-76
	stw		at,		0(sp)
	stw		r2,		4(sp)
	stw		r3,		8(sp)
	stw		r4,		12(sp)
	stw		r5,		16(sp)
	stw		r6,		20(sp)
	stw		r7,		24(sp)
	stw		r8,		28(sp)
	stw		r9,		32(sp)
	stw		r10,	36(sp)
	stw		r11,	40(sp)
	stw		r12,	44(sp)
	stw		r13,	48(sp)
	stw		r14,	52(sp)
	stw		r15,	56(sp)
	stw		ra,		60(sp)
	stw		ea,		64(sp)
	rdctl	et,		estatus
	stw		et,		68(sp)

	/* 割込み発生前のcallevel_statをスタックに保存 */
	ldh		r2,		%gprel(callevel_stat)(gp)
	stw		r2,		72(sp)

	/* callevel_statにC1ISRをセット */
	ori		et,		et,	TSYS_ISR1
	sth		et,		%gprel(callevel_stat)(gp)

	call	FUNC_C1ISR1

	ldw		r2,		72(sp)
	sth		r2,		%gprel(callevel_stat)(gp)

	/* レジスタの復帰 */
	ldw		at,		0(sp)
	ldw		r2,		4(sp)
	ldw		r3,		8(sp)
	ldw		r4,		12(sp)
	ldw		r5,		16(sp)
	ldw		r6,		20(sp)
	ldw		r7,		24(sp)
	ldw		r8,		28(sp)
	ldw		r9,		32(sp)
	ldw		r10,	36(sp)
	ldw		r11,	40(sp)
	ldw		r12,	44(sp)
	ldw		r13,	48(sp)
	ldw		r14,	52(sp)
	ldw		r15,	56(sp)
	ldw		ra,		60(sp)
	ldw		ea,		64(sp)
	ldw		et,		68(sp)
	wrctl	estatus,	et
	addi	sp,	sp,	76

	eret

.global C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A
.set noat

C1ISRMainAKTG_C1ISR_COMMON_AKTSP_INTNO_A:
	addi	ea,	ea,	-4	/* 戻り番地をデクリメント */

	/* レジスタの保存 */
	addi	sp,	sp,	-76
	stw		at,		0(sp)
	stw		r2,		4(sp)
	stw		r3,		8(sp)
	stw		r4,		12(sp)
	stw		r5,		16(sp)
	stw		r6,		20(sp)
	stw		r7,		24(sp)
	stw		r8,		28(sp)
	stw		r9,		32(sp)
	stw		r10,	36(sp)
	stw		r11,	40(sp)
	stw		r12,	44(sp)
	stw		r13,	48(sp)
	stw		r14,	52(sp)
	stw		r15,	56(sp)
	stw		ra,		60(sp)
	stw		ea,		64(sp)
	rdctl	et,		estatus
	stw		et,		68(sp)

	/* 割込み発生前のcallevel_statをスタックに保存 */
	ldh		r2,		%gprel(callevel_stat)(gp)
	stw		r2,		72(sp)

	/* callevel_statにC1ISRをセット */
	ori		et,		et,	TSYS_ISR1
	sth		et,		%gprel(callevel_stat)(gp)

	call	FUNC_C1ISR2

	ldw		r2,		72(sp)
	sth		r2,		%gprel(callevel_stat)(gp)

	/* レジスタの復帰 */
	ldw		at,		0(sp)
	ldw		r2,		4(sp)
	ldw		r3,		8(sp)
	ldw		r4,		12(sp)
	ldw		r5,		16(sp)
	ldw		r6,		20(sp)
	ldw		r7,		24(sp)
	ldw		r8,		28(sp)
	ldw		r9,		32(sp)
	ldw		r10,	36(sp)
	ldw		r11,	40(sp)
	ldw		r12,	44(sp)
	ldw		r13,	48(sp)
	ldw		r14,	52(sp)
	ldw		r15,	56(sp)
	ldw		ra,		60(sp)
	ldw		ea,		64(sp)
	ldw		et,		68(sp)
	wrctl	estatus,	et
	addi	sp,	sp,	76

	eret
