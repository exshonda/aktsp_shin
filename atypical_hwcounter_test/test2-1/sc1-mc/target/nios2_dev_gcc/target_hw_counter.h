/*
 *  TOPPERS ATK2
 *      Toyohashi Open Platform for Embedded Real-Time Systems
 *      Automotive Kernel Version 2
 *
 *  Copyright (C) 2008-2017 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2017 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2011-2013 by Spansion LLC, USA
 *  Copyright (C) 2011-2017 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2011-2016 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2011-2014 by Renesas Electronics Corporation, JAPAN
 *  Copyright (C) 2011-2016 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2011-2017 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2011-2017 by Witz Corporation
 *  Copyright (C) 2014-2016 by AISIN COMCRUISE Co., Ltd., JAPAN
 *  Copyright (C) 2014-2016 by eSOL Co.,Ltd., JAPAN
 *  Copyright (C) 2014-2017 by SCSK Corporation, JAPAN
 *  Copyright (C) 2015-2017 by SUZUKI MOTOR CORPORATION
 *
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
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
 *  本ソフトウェアは，AUTOSAR（AUTomotive Open System ARchitecture）仕
 *  様に基づいている．上記の許諾は，AUTOSARの知的財産権を許諾するもので
 *  はない．AUTOSARは，AUTOSAR仕様に基づいたソフトウェアを商用目的で利
 *  用する者に対して，AUTOSARパートナーになることを求めている．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *  $Id: target_hw_counter.h 2366 2017-03-03 04:55:51Z witz-itoyo $
 */

/*
 *		テストプログラムのターゲット依存定義（NIOS2_DEV用）
 */

#ifndef TOPPERS_TARGET_HW_COUNTER_H
#define TOPPERS_TARGET_HW_COUNTER_H

/*
 *  カウンタ最大値
 */
#define MAX_TIMER_CNT		((uint32) 0xFFFFFFFF)

/*
 *  カウンタ周期最大値
 */
#define MAX_CNT_CYCLE		((uint32) 0x7FFFFFFF)

/*
 *  タイマハードウェア依存のベース定義
 */
#ifdef TOPPERS_NIOS2_DEV_DE2_115

/*
 *  タイマクロック周波数（Hz）60MHz
 */
#define TIMER_CLOCK_HZ		((uint32) 60000000)


/*
 *  NIOS2_DEV_DE2_115 用の定義割込みBASE ADDRESS
 */
#define INTNO_BASE_CORE0	UINT_C(0x10000)
#define INTNO_BASE_CORE1	UINT_C(0x20000)

/*
 *  NIOS2_DEV_DE2_115 用の定義割込み番号
 */
#define TIMER_0_IRQ			UINT_C(16)
#define TIMER_1_IRQ			UINT_C(17)
#define TIMER_2_IRQ			UINT_C(18)
#define TIMER_3_IRQ			UINT_C(19)
#define TIMER_4_IRQ			UINT_C(20)
#define TIMER_5_IRQ			UINT_C(21)
#define TIMER_6_IRQ			UINT_C(22)
#define TIMER_7_IRQ			UINT_C(23)
#define TIMER_8_IRQ			UINT_C(24)
#define TIMER_9_IRQ			UINT_C(25)
#define TIMER_10_IRQ		UINT_C(26)
#define TIMER_11_IRQ		UINT_C(27)
#define TIMER_12_IRQ		UINT_C(28)
#define TIMER_13_IRQ		UINT_C(29)
#define TIMER_14_IRQ		UINT_C(30)
#define TIMER_15_IRQ		UINT_C(31)

#define TIMER_CORE0_0_IRQ		(UINT_C(16) + INTNO_BASE_CORE0)
#define TIMER_CORE0_1_IRQ		(UINT_C(17) + INTNO_BASE_CORE0)
#define TIMER_CORE0_2_IRQ		(UINT_C(18) + INTNO_BASE_CORE0)
#define TIMER_CORE0_3_IRQ		(UINT_C(19) + INTNO_BASE_CORE0)
#define TIMER_CORE0_4_IRQ		(UINT_C(20) + INTNO_BASE_CORE0)
#define TIMER_CORE0_5_IRQ		(UINT_C(21) + INTNO_BASE_CORE0)
#define TIMER_CORE0_6_IRQ		(UINT_C(22) + INTNO_BASE_CORE0)
#define TIMER_CORE0_7_IRQ		(UINT_C(23) + INTNO_BASE_CORE0)
#define TIMER_CORE0_8_IRQ		(UINT_C(24) + INTNO_BASE_CORE0)
#define TIMER_CORE0_9_IRQ		(UINT_C(25) + INTNO_BASE_CORE0)
#define TIMER_CORE0_10_IRQ		(UINT_C(26) + INTNO_BASE_CORE0)
#define TIMER_CORE0_11_IRQ		(UINT_C(27) + INTNO_BASE_CORE0)
#define TIMER_CORE0_12_IRQ		(UINT_C(28) + INTNO_BASE_CORE0)
#define TIMER_CORE0_13_IRQ		(UINT_C(29) + INTNO_BASE_CORE0)
#define TIMER_CORE0_14_IRQ		(UINT_C(30) + INTNO_BASE_CORE0)
#define TIMER_CORE0_15_IRQ		(UINT_C(31) + INTNO_BASE_CORE0)

#define TIMER_CORE1_0_IRQ		(UINT_C(16) + INTNO_BASE_CORE1)
#define TIMER_CORE1_1_IRQ		(UINT_C(17) + INTNO_BASE_CORE1)
#define TIMER_CORE1_2_IRQ		(UINT_C(18) + INTNO_BASE_CORE1)
#define TIMER_CORE1_3_IRQ		(UINT_C(19) + INTNO_BASE_CORE1)
#define TIMER_CORE1_4_IRQ		(UINT_C(20) + INTNO_BASE_CORE1)
#define TIMER_CORE1_5_IRQ		(UINT_C(21) + INTNO_BASE_CORE1)
#define TIMER_CORE1_6_IRQ		(UINT_C(22) + INTNO_BASE_CORE1)
#define TIMER_CORE1_7_IRQ		(UINT_C(23) + INTNO_BASE_CORE1)
#define TIMER_CORE1_8_IRQ		(UINT_C(24) + INTNO_BASE_CORE1)
#define TIMER_CORE1_9_IRQ		(UINT_C(25) + INTNO_BASE_CORE1)
#define TIMER_CORE1_10_IRQ		(UINT_C(26) + INTNO_BASE_CORE1)
#define TIMER_CORE1_11_IRQ		(UINT_C(27) + INTNO_BASE_CORE1)
#define TIMER_CORE1_12_IRQ		(UINT_C(28) + INTNO_BASE_CORE1)
#define TIMER_CORE1_13_IRQ		(UINT_C(29) + INTNO_BASE_CORE1)
#define TIMER_CORE1_14_IRQ		(UINT_C(30) + INTNO_BASE_CORE1)
#define TIMER_CORE1_15_IRQ		(UINT_C(31) + INTNO_BASE_CORE1)

/*
 *  NIOS2_DEV_DE2_115 用の定義タイマレジスタベース
 */
#define TIMER_BASE(INTNO)     (UINT_C(0x0c000200) +											  \
							   (UINT_C(0x00100000) * (((INTNO) >> UINT_C(16)) - UINT_C(1))) + \
							   (UINT_C(0x20) * (((INTNO) &UINT_C(0xffff)) - UINT_C(16))))

/* それ以外のターゲット定義 */
#endif /* TOPPERS_NIOS2_DEV_DE2_115 */

/*
 *  タイマcontrolレジスタのビット定義
 */
#define TIMER_CONTROL_ITO		(UINT_C(0x00000001))
#define TIMER_CONTROL_CONT		(UINT_C(0x00000002))
#define TIMER_CONTROL_START		(UINT_C(0x00000004))
#define TIMER_CONTROL_STOP		(UINT_C(0x00000008))

/*
 *  TIMER関連レジスタ定義
 */
#define TIMER_STATUS(INTNO)		(TIMER_BASE(INTNO) + UINT_C(0x00000000))
#define TIMER_CONTROL(INTNO)	(TIMER_BASE(INTNO) + UINT_C(0x00000004))
#define TIMER_PERIODL(INTNO)	(TIMER_BASE(INTNO) + UINT_C(0x00000008))
#define TIMER_PERIODH(INTNO)	(TIMER_BASE(INTNO) + UINT_C(0x0000000C))
#define TIMER_SNAPL(INTNO)		(TIMER_BASE(INTNO) + UINT_C(0x00000010))
#define TIMER_SNAPH(INTNO)		(TIMER_BASE(INTNO) + UINT_C(0x00000014))

/*
 *  10msと一致するティック値(サンプルプログラム用)
 */
#define TICK_FOR_10MS	(TIMER_CLOCK_HZ / 100)

#endif /* TOPPERS_TARGET_HW_COUNTER_H */
