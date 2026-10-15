/*
 *  AKTSP
 *      Automotive Kernel Test Suite Package
 *
 *  Copyright (C) 2011-2013 by Center for Embedded Computing Systems
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2011-2013 by FUJI SOFT INCORPORATED, JAPAN
 *  Copyright (C) 2011-2013 by Spansion LLC, USA
 *  Copyright (C) 2011-2013 by NEC Communication Systems, Ltd., JAPAN
 *  Copyright (C) 2011-2013 by Panasonic Advanced Technology Development Co., Ltd., JAPAN
 *  Copyright (C) 2011-2013 by Renesas Electronics Corporation, JAPAN
 *  Copyright (C) 2011-2013 by Sunny Giken Inc., JAPAN
 *  Copyright (C) 2011-2013 by TOSHIBA CORPORATION, JAPAN
 *  Copyright (C) 2011-2013 by Witz Corporation, JAPAN
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
 *  $Id: aktsp_target_lib_mem.c 2046 2015-08-24 01:14:35Z aisincom-nishioka $
 */

#include "Os.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"
#include "aktsp_target_lib.h"

#define BACKPOINT (1U)

#define IF_NOT_ENABLE_BREAK do {	\
	check_num++;					\
	if (!enable) {	 				\
		break;						\
	}								\
} while (0)

#define STACK_NO_ACCESS     (0U)
#define STACK_TRUSTED_TASK  (1U)
#define STACK_TRUSTED_C2ISR (2U)

/*
 *  マルチコアではOSAP名を置換するため，ラベルを変更する
 */
#ifdef TotalNumberOfCores
#define __start_text_NON_TRUSTED_OSAP1            __start_text_NT_OSAP_SELF_CORE
#define __limit_text_NON_TRUSTED_OSAP1            __limit_text_NT_OSAP_SELF_CORE
#define __end_text_NON_TRUSTED_OSAP1              __end_text_NT_OSAP_SELF_CORE
#define __start_rodata_NON_TRUSTED_OSAP1          __start_rodata_NT_OSAP_SELF_CORE
#define __limit_rodata_NON_TRUSTED_OSAP1          __limit_rodata_NT_OSAP_SELF_CORE
#define __end_rodata_NON_TRUSTED_OSAP1            __end_rodata_NT_OSAP_SELF_CORE
#define __start_text_NON_TRUSTED_OSAP2            __start_text_NT_OSAP_SELF_CORE_2
#define __limit_text_NON_TRUSTED_OSAP2            __limit_text_NT_OSAP_SELF_CORE_2
#define __end_text_NON_TRUSTED_OSAP2              __end_text_NT_OSAP_SELF_CORE_2
#define __start_rodata_NON_TRUSTED_OSAP2          __start_rodata_NT_OSAP_SELF_CORE_2
#define __limit_rodata_NON_TRUSTED_OSAP2          __limit_rodata_NT_OSAP_SELF_CORE_2
#define __end_rodata_NON_TRUSTED_OSAP2            __end_rodata_NT_OSAP_SELF_CORE_2
#define __start_sdata_NON_TRUSTED_OSAP1_28        __start_sdata_NT_OSAP_SELF_CORE__std
#define __limit_sdata_NON_TRUSTED_OSAP1_28        __limit_sdata_NT_OSAP_SELF_CORE__std
#define __end_sdata_NON_TRUSTED_OSAP1_28          __end_sdata_NT_OSAP_SELF_CORE__std
#define __start_sbss_NON_TRUSTED_OSAP1_20         __start_sbss_NT_OSAP_SELF_CORE__std
#define __limit_sbss_NON_TRUSTED_OSAP1_20         __limit_sbss_NT_OSAP_SELF_CORE__std
#define __end_sbss_NON_TRUSTED_OSAP1_20           __end_sbss_NT_OSAP_SELF_CORE__std
#define __start_sdata_NON_TRUSTED_OSAP2_28        __start_sdata_NT_OSAP_SELF_CORE_2__std
#define __limit_sdata_NON_TRUSTED_OSAP2_28        __limit_sdata_NT_OSAP_SELF_CORE_2__std
#define __end_sdata_NON_TRUSTED_OSAP2_28          __end_sdata_NT_OSAP_SELF_CORE_2__std
#define __start_sbss_NON_TRUSTED_OSAP2_20         __start_sbss_NT_OSAP_SELF_CORE_2__std
#define __limit_sbss_NON_TRUSTED_OSAP2_20         __limit_sbss_NT_OSAP_SELF_CORE_2__std
#define __end_sbss_NON_TRUSTED_OSAP2_20           __end_sbss_NT_OSAP_SELF_CORE_2__std
#define __start_sdata_NON_TRUSTED_OSAP1_28_srpw   __start_sdata_NT_OSAP_SELF_CORE__1_ffffffff
#define __limit_sdata_NON_TRUSTED_OSAP1_28_srpw   __limit_sdata_NT_OSAP_SELF_CORE__1_ffffffff
#define __end_sdata_NON_TRUSTED_OSAP1_28_srpw     __end_sdata_NT_OSAP_SELF_CORE__1_ffffffff
#define __start_sbss_NON_TRUSTED_OSAP1_20_srpw    __start_sbss_NT_OSAP_SELF_CORE__1_ffffffff
#define __limit_sbss_NON_TRUSTED_OSAP1_20_srpw    __limit_sbss_NT_OSAP_SELF_CORE__1_ffffffff
#define __end_sbss_NON_TRUSTED_OSAP1_20_srpw      __end_sbss_NT_OSAP_SELF_CORE__1_ffffffff
#define __start_sdata_NON_TRUSTED_OSAP2_28_srpw   __start_sdata_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __limit_sdata_NON_TRUSTED_OSAP2_28_srpw   __limit_sdata_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __end_sdata_NON_TRUSTED_OSAP2_28_srpw     __end_sdata_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __start_sbss_NON_TRUSTED_OSAP2_20_srpw    __start_sbss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __limit_sbss_NON_TRUSTED_OSAP2_20_srpw    __limit_sbss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __end_sbss_NON_TRUSTED_OSAP2_20_srpw      __end_sbss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __start_data_NON_TRUSTED_OSAP1            __start_data_NT_OSAP_SELF_CORE
#define __limit_data_NON_TRUSTED_OSAP1            __limit_data_NT_OSAP_SELF_CORE
#define __end_data_NON_TRUSTED_OSAP1              __end_data_NT_OSAP_SELF_CORE
#define __start_bss_NON_TRUSTED_OSAP1             __start_bss_NT_OSAP_SELF_CORE
#define __limit_bss_NON_TRUSTED_OSAP1             __limit_bss_NT_OSAP_SELF_CORE
#define __end_bss_NON_TRUSTED_OSAP1               __end_bss_NT_OSAP_SELF_CORE
#define __start_prsv_NON_TRUSTED_OSAP1            __start_prsv_NT_OSAP_SELF_CORE
#define __limit_prsv_NON_TRUSTED_OSAP1            __limit_prsv_NT_OSAP_SELF_CORE
#define __end_prsv_NON_TRUSTED_OSAP1              __end_prsv_NT_OSAP_SELF_CORE
#define __start_data_NON_TRUSTED_OSAP2            __start_data_NT_OSAP_SELF_CORE_2
#define __limit_data_NON_TRUSTED_OSAP2            __limit_data_NT_OSAP_SELF_CORE_2
#define __end_data_NON_TRUSTED_OSAP2              __end_data_NT_OSAP_SELF_CORE_2
#define __start_bss_NON_TRUSTED_OSAP2             __start_bss_NT_OSAP_SELF_CORE_2
#define __limit_bss_NON_TRUSTED_OSAP2             __limit_bss_NT_OSAP_SELF_CORE_2
#define __end_bss_NON_TRUSTED_OSAP2               __end_bss_NT_OSAP_SELF_CORE_2
#define __start_prsv_NON_TRUSTED_OSAP2            __start_prsv_NT_OSAP_SELF_CORE_2
#define __limit_prsv_NON_TRUSTED_OSAP2            __limit_prsv_NT_OSAP_SELF_CORE_2
#define __end_prsv_NON_TRUSTED_OSAP2              __end_prsv_NT_OSAP_SELF_CORE_2
#define __start_data_NON_TRUSTED_OSAP1_srpw       __start_data_NT_OSAP_SELF_CORE__1_ffffffff
#define __limit_data_NON_TRUSTED_OSAP1_srpw       __limit_data_NT_OSAP_SELF_CORE__1_ffffffff
#define __end_data_NON_TRUSTED_OSAP1_srpw         __end_data_NT_OSAP_SELF_CORE__1_ffffffff
#define __start_bss_NON_TRUSTED_OSAP1_srpw        __start_bss_NT_OSAP_SELF_CORE__1_ffffffff
#define __limit_bss_NON_TRUSTED_OSAP1_srpw        __limit_bss_NT_OSAP_SELF_CORE__1_ffffffff
#define __end_bss_NON_TRUSTED_OSAP1_srpw          __end_bss_NT_OSAP_SELF_CORE__1_ffffffff
#define __start_prsv_NON_TRUSTED_OSAP1_srpw       __start_prsv_NT_OSAP_SELF_CORE__1_ffffffff
#define __limit_prsv_NON_TRUSTED_OSAP1_srpw       __limit_prsv_NT_OSAP_SELF_CORE__1_ffffffff
#define __end_prsv_NON_TRUSTED_OSAP1_srpw         __end_prsv_NT_OSAP_SELF_CORE__1_ffffffff
#define __start_data_NON_TRUSTED_OSAP2_srpw       __start_data_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __limit_data_NON_TRUSTED_OSAP2_srpw       __limit_data_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __end_data_NON_TRUSTED_OSAP2_srpw         __end_data_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __start_bss_NON_TRUSTED_OSAP2_srpw        __start_bss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __limit_bss_NON_TRUSTED_OSAP2_srpw        __limit_bss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __end_bss_NON_TRUSTED_OSAP2_srpw          __end_bss_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __start_prsv_NON_TRUSTED_OSAP2_srpw       __start_prsv_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __limit_prsv_NON_TRUSTED_OSAP2_srpw       __limit_prsv_NT_OSAP_SELF_CORE_2__2_ffffffff
#define __end_prsv_NON_TRUSTED_OSAP2_srpw         __end_prsv_NT_OSAP_SELF_CORE_2__2_ffffffff
#else
#define __start_sdata_NON_TRUSTED_OSAP1_28        __start_sdata_NON_TRUSTED_OSAP1__std
#define __limit_sdata_NON_TRUSTED_OSAP1_28        __limit_sdata_NON_TRUSTED_OSAP1__std
#define __end_sdata_NON_TRUSTED_OSAP1_28          __end_sdata_NON_TRUSTED_OSAP1__std
#define __start_sbss_NON_TRUSTED_OSAP1_20         __start_sbss_NON_TRUSTED_OSAP1__std
#define __limit_sbss_NON_TRUSTED_OSAP1_20         __limit_sbss_NON_TRUSTED_OSAP1__std
#define __end_sbss_NON_TRUSTED_OSAP1_20           __end_sbss_NON_TRUSTED_OSAP1__std
#define __start_sdata_NON_TRUSTED_OSAP2_28        __start_sdata_NON_TRUSTED_OSAP2__std
#define __limit_sdata_NON_TRUSTED_OSAP2_28        __limit_sdata_NON_TRUSTED_OSAP2__std
#define __end_sdata_NON_TRUSTED_OSAP2_28          __end_sdata_NON_TRUSTED_OSAP2__std
#define __start_sbss_NON_TRUSTED_OSAP2_20         __start_sbss_NON_TRUSTED_OSAP2__std
#define __limit_sbss_NON_TRUSTED_OSAP2_20         __limit_sbss_NON_TRUSTED_OSAP2__std
#define __end_sbss_NON_TRUSTED_OSAP2_20           __end_sbss_NON_TRUSTED_OSAP2__std
#define __start_sdata_NON_TRUSTED_OSAP1_28_srpw   __start_sdata_NON_TRUSTED_OSAP1__1_ffffffff
#define __limit_sdata_NON_TRUSTED_OSAP1_28_srpw   __limit_sdata_NON_TRUSTED_OSAP1__1_ffffffff
#define __end_sdata_NON_TRUSTED_OSAP1_28_srpw     __end_sdata_NON_TRUSTED_OSAP1__1_ffffffff
#define __start_sbss_NON_TRUSTED_OSAP1_20_srpw    __start_sbss_NON_TRUSTED_OSAP1__1_ffffffff
#define __limit_sbss_NON_TRUSTED_OSAP1_20_srpw    __limit_sbss_NON_TRUSTED_OSAP1__1_ffffffff
#define __end_sbss_NON_TRUSTED_OSAP1_20_srpw      __end_sbss_NON_TRUSTED_OSAP1__1_ffffffff
#define __start_sdata_NON_TRUSTED_OSAP2_28_srpw   __start_sdata_NON_TRUSTED_OSAP2__2_ffffffff
#define __limit_sdata_NON_TRUSTED_OSAP2_28_srpw   __limit_sdata_NON_TRUSTED_OSAP2__2_ffffffff
#define __end_sdata_NON_TRUSTED_OSAP2_28_srpw     __end_sdata_NON_TRUSTED_OSAP2__2_ffffffff
#define __start_sbss_NON_TRUSTED_OSAP2_20_srpw    __start_sbss_NON_TRUSTED_OSAP2__2_ffffffff
#define __limit_sbss_NON_TRUSTED_OSAP2_20_srpw    __limit_sbss_NON_TRUSTED_OSAP2__2_ffffffff
#define __end_sbss_NON_TRUSTED_OSAP2_20_srpw      __end_sbss_NON_TRUSTED_OSAP2__2_ffffffff
#define __start_data_NON_TRUSTED_OSAP1_srpw       __start_data_NON_TRUSTED_OSAP1__1_ffffffff
#define __limit_data_NON_TRUSTED_OSAP1_srpw       __limit_data_NON_TRUSTED_OSAP1__1_ffffffff
#define __end_data_NON_TRUSTED_OSAP1_srpw         __end_data_NON_TRUSTED_OSAP1__1_ffffffff
#define __start_bss_NON_TRUSTED_OSAP1_srpw        __start_bss_NON_TRUSTED_OSAP1__1_ffffffff
#define __limit_bss_NON_TRUSTED_OSAP1_srpw        __limit_bss_NON_TRUSTED_OSAP1__1_ffffffff
#define __end_bss_NON_TRUSTED_OSAP1_srpw          __end_bss_NON_TRUSTED_OSAP1__1_ffffffff
#define __start_prsv_NON_TRUSTED_OSAP1_srpw       __start_prsv_NON_TRUSTED_OSAP1__1_ffffffff
#define __limit_prsv_NON_TRUSTED_OSAP1_srpw       __limit_prsv_NON_TRUSTED_OSAP1__1_ffffffff
#define __end_prsv_NON_TRUSTED_OSAP1_srpw         __end_prsv_NON_TRUSTED_OSAP1__1_ffffffff
#define __start_data_NON_TRUSTED_OSAP2_srpw       __start_data_NON_TRUSTED_OSAP2__2_ffffffff
#define __limit_data_NON_TRUSTED_OSAP2_srpw       __limit_data_NON_TRUSTED_OSAP2__2_ffffffff
#define __end_data_NON_TRUSTED_OSAP2_srpw         __end_data_NON_TRUSTED_OSAP2__2_ffffffff
#define __start_bss_NON_TRUSTED_OSAP2_srpw        __start_bss_NON_TRUSTED_OSAP2__2_ffffffff
#define __limit_bss_NON_TRUSTED_OSAP2_srpw        __limit_bss_NON_TRUSTED_OSAP2__2_ffffffff
#define __end_bss_NON_TRUSTED_OSAP2_srpw          __end_bss_NON_TRUSTED_OSAP2__2_ffffffff
#define __start_prsv_NON_TRUSTED_OSAP2_srpw       __start_prsv_NON_TRUSTED_OSAP2__2_ffffffff
#define __limit_prsv_NON_TRUSTED_OSAP2_srpw       __limit_prsv_NON_TRUSTED_OSAP2__2_ffffffff
#define __end_prsv_NON_TRUSTED_OSAP2_srpw         __end_prsv_NON_TRUSTED_OSAP2__2_ffffffff
#endif /* TotalNumberOfCores */
/* シングル・マルチ共通 */
#define __start_sdata_kernel_28                   __start_sdata_kernel__std
#define __limit_sdata_kernel_28                   __limit_sdata_kernel__std
#define __end_sdata_kernel_28                     __end_sdata_kernel__std
#define __start_sbss_kernel_20                    __start_sbss_kernel__std
#define __limit_sbss_kernel_20                    __limit_sbss_kernel__std
#define __end_sbss_kernel_20                      __end_sbss_kernel__std
#define __start_sdata_kernel_28_srpw              __start_sdata_kernel__0_ffffffff
#define __limit_sdata_kernel_28_srpw              __limit_sdata_kernel__0_ffffffff
#define __end_sdata_kernel_28_srpw                __end_sdata_kernel__0_ffffffff
#define __start_sbss_kernel_20_srpw               __start_sbss_kernel__0_ffffffff
#define __limit_sbss_kernel_20_srpw               __limit_sbss_kernel__0_ffffffff
#define __end_sbss_kernel_20_srpw                 __end_sbss_kernel__0_ffffffff
#define __start_sdata_shared_28                   __start_sdata_shared__std
#define __limit_sdata_shared_28                   __limit_sdata_shared__std
#define __end_sdata_shared_28                     __end_sdata_shared__std
#define __start_sbss_shared_20                    __start_sbss_shared__std
#define __limit_sbss_shared_20                    __limit_sbss_shared__std
#define __end_sbss_shared_20                      __end_sbss_shared__std
#define __start_data_kernel_srpw                  __start_data_kernel__0_ffffffff
#define __limit_data_kernel_srpw                  __limit_data_kernel__0_ffffffff
#define __end_data_kernel_srpw                    __end_data_kernel__0_ffffffff
#define __start_bss_kernel_srpw                   __start_bss_kernel__0_ffffffff
#define __limit_bss_kernel_srpw                   __limit_bss_kernel__0_ffffffff
#define __end_bss_kernel_srpw                     __end_bss_kernel__0_ffffffff
#define __start_prsv_kernel_srpw                  __start_prsv_kernel__0_ffffffff
#define __limit_prsv_kernel_srpw                  __limit_prsv_kernel__0_ffffffff
#define __end_prsv_kernel_srpw                    __end_prsv_kernel__0_ffffffff

extern uint8 __start_text_kernel;
extern uint8 __limit_text_kernel;
extern uint8 __end_text_kernel;
extern uint8 __start_rodata_kernel;
extern uint8 __limit_rodata_kernel;
extern uint8 __end_rodata_kernel;
extern uint8 __start_text_NON_TRUSTED_OSAP1;
extern uint8 __limit_text_NON_TRUSTED_OSAP1;
extern uint8 __end_text_NON_TRUSTED_OSAP1;
extern uint8 __start_rodata_NON_TRUSTED_OSAP1;
extern uint8 __limit_rodata_NON_TRUSTED_OSAP1;
extern uint8 __end_rodata_NON_TRUSTED_OSAP1;
extern uint8 __start_text_NON_TRUSTED_OSAP2;
extern uint8 __limit_text_NON_TRUSTED_OSAP2;
extern uint8 __end_text_NON_TRUSTED_OSAP2;
extern uint8 __start_rodata_NON_TRUSTED_OSAP2;
extern uint8 __limit_rodata_NON_TRUSTED_OSAP2;
extern uint8 __end_rodata_NON_TRUSTED_OSAP2;
extern uint8 __start_text_shared_srpw;
extern uint8 __limit_text_shared_srpw;
extern uint8 __end_text_shared_srpw;
extern uint8 __start_rodata_shared_srpw;
extern uint8 __limit_rodata_shared_srpw;
extern uint8 __end_rodata_shared_srpw;
extern uint8 __start_text_shared;
extern uint8 __limit_text_shared;
extern uint8 __end_text_shared;
extern uint8 __start_rodata_shared;
extern uint8 __limit_rodata_shared;
extern uint8 __end_rodata_shared;
extern uint8 __start_sdata_kernel_28;
extern uint8 __limit_sdata_kernel_28;
extern uint8 __end_sdata_kernel_28;
extern uint8 __start_sbss_kernel_20;
extern uint8 __limit_sbss_kernel_20;
extern uint8 __end_sbss_kernel_20;
extern uint8 __start_sdata_NON_TRUSTED_OSAP1_28;
extern uint8 __limit_sdata_NON_TRUSTED_OSAP1_28;
extern uint8 __end_sdata_NON_TRUSTED_OSAP1_28;
extern uint8 __start_sbss_NON_TRUSTED_OSAP1_20;
extern uint8 __limit_sbss_NON_TRUSTED_OSAP1_20;
extern uint8 __end_sbss_NON_TRUSTED_OSAP1_20;
extern uint8 __start_sdata_NON_TRUSTED_OSAP2_28;
extern uint8 __limit_sdata_NON_TRUSTED_OSAP2_28;
extern uint8 __end_sdata_NON_TRUSTED_OSAP2_28;
extern uint8 __start_sbss_NON_TRUSTED_OSAP2_20;
extern uint8 __limit_sbss_NON_TRUSTED_OSAP2_20;
extern uint8 __end_sbss_NON_TRUSTED_OSAP2_20;
extern uint8 __start_sdata_kernel_28_srpw;
extern uint8 __limit_sdata_kernel_28_srpw;
extern uint8 __end_sdata_kernel_28_srpw;
extern uint8 __start_sbss_kernel_20_srpw;
extern uint8 __limit_sbss_kernel_20_srpw;
extern uint8 __end_sbss_kernel_20_srpw;
extern uint8 __start_sdata_NON_TRUSTED_OSAP1_28_srpw;
extern uint8 __limit_sdata_NON_TRUSTED_OSAP1_28_srpw;
extern uint8 __end_sdata_NON_TRUSTED_OSAP1_28_srpw;
extern uint8 __start_sbss_NON_TRUSTED_OSAP1_20_srpw;
extern uint8 __limit_sbss_NON_TRUSTED_OSAP1_20_srpw;
extern uint8 __end_sbss_NON_TRUSTED_OSAP1_20_srpw;
extern uint8 __start_sdata_NON_TRUSTED_OSAP2_28_srpw;
extern uint8 __limit_sdata_NON_TRUSTED_OSAP2_28_srpw;
extern uint8 __end_sdata_NON_TRUSTED_OSAP2_28_srpw;
extern uint8 __start_sbss_NON_TRUSTED_OSAP2_20_srpw;
extern uint8 __limit_sbss_NON_TRUSTED_OSAP2_20_srpw;
extern uint8 __end_sbss_NON_TRUSTED_OSAP2_20_srpw;
extern uint8 __start_sdata_shared_28;
extern uint8 __limit_sdata_shared_28;
extern uint8 __end_sdata_shared_28;
extern uint8 __start_sbss_shared_20;
extern uint8 __limit_sbss_shared_20;
extern uint8 __end_sbss_shared_20;
extern uint8 __start_data_kernel;
extern uint8 __limit_data_kernel;
extern uint8 __end_data_kernel;
extern uint8 __start_bss_kernel;
extern uint8 __limit_bss_kernel;
extern uint8 __end_bss_kernel;
extern uint8 __start_prsv_kernel;
extern uint8 __limit_prsv_kernel;
extern uint8 __end_prsv_kernel;
extern uint8 __start_data_NON_TRUSTED_OSAP1;
extern uint8 __limit_data_NON_TRUSTED_OSAP1;
extern uint8 __end_data_NON_TRUSTED_OSAP1;
extern uint8 __start_bss_NON_TRUSTED_OSAP1;
extern uint8 __limit_bss_NON_TRUSTED_OSAP1;
extern uint8 __end_bss_NON_TRUSTED_OSAP1;
extern uint8 __start_prsv_NON_TRUSTED_OSAP1;
extern uint8 __limit_prsv_NON_TRUSTED_OSAP1;
extern uint8 __end_prsv_NON_TRUSTED_OSAP1;
extern uint8 __start_data_NON_TRUSTED_OSAP2;
extern uint8 __limit_data_NON_TRUSTED_OSAP2;
extern uint8 __end_data_NON_TRUSTED_OSAP2;
extern uint8 __start_bss_NON_TRUSTED_OSAP2;
extern uint8 __limit_bss_NON_TRUSTED_OSAP2;
extern uint8 __end_bss_NON_TRUSTED_OSAP2;
extern uint8 __start_prsv_NON_TRUSTED_OSAP2;
extern uint8 __limit_prsv_NON_TRUSTED_OSAP2;
extern uint8 __end_prsv_NON_TRUSTED_OSAP2;
extern uint8 __start_data_kernel_srpw;
extern uint8 __limit_data_kernel_srpw;
extern uint8 __end_data_kernel_srpw;
extern uint8 __start_bss_kernel_srpw;
extern uint8 __limit_bss_kernel_srpw;
extern uint8 __end_bss_kernel_srpw;
extern uint8 __start_prsv_kernel_srpw;
extern uint8 __limit_prsv_kernel_srpw;
extern uint8 __end_prsv_kernel_srpw;
extern uint8 __start_data_NON_TRUSTED_OSAP1_srpw;
extern uint8 __limit_data_NON_TRUSTED_OSAP1_srpw;
extern uint8 __end_data_NON_TRUSTED_OSAP1_srpw;
extern uint8 __start_bss_NON_TRUSTED_OSAP1_srpw;
extern uint8 __limit_bss_NON_TRUSTED_OSAP1_srpw;
extern uint8 __end_bss_NON_TRUSTED_OSAP1_srpw;
extern uint8 __start_prsv_NON_TRUSTED_OSAP1_srpw;
extern uint8 __limit_prsv_NON_TRUSTED_OSAP1_srpw;
extern uint8 __end_prsv_NON_TRUSTED_OSAP1_srpw;
extern uint8 __start_data_NON_TRUSTED_OSAP2_srpw;
extern uint8 __limit_data_NON_TRUSTED_OSAP2_srpw;
extern uint8 __end_data_NON_TRUSTED_OSAP2_srpw;
extern uint8 __start_bss_NON_TRUSTED_OSAP2_srpw;
extern uint8 __limit_bss_NON_TRUSTED_OSAP2_srpw;
extern uint8 __end_bss_NON_TRUSTED_OSAP2_srpw;
extern uint8 __start_prsv_NON_TRUSTED_OSAP2_srpw;
extern uint8 __limit_prsv_NON_TRUSTED_OSAP2_srpw;
extern uint8 __end_prsv_NON_TRUSTED_OSAP2_srpw;
extern uint8 __start_data_shared;
extern uint8 __limit_data_shared;
extern uint8 __end_data_shared;
extern uint8 __start_bss_shared;
extern uint8 __limit_bss_shared;
extern uint8 __end_bss_shared;
extern uint8 __start_prsv_shared;
extern uint8 __limit_prsv_shared;
extern uint8 __end_prsv_shared;

/*
 *  メモリ保護テストの実行アクセス用関数
 */
extern void AktspKernelFunc(void);
extern void AktspNonTrustedOsap1Func(void);
extern void AktspNonTrustedOsap2Func(void);
extern void AktspCommonFunc(void);

/*
 *  メモリ保護テストのアクセス用変数
 */
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_common_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_common_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_common_rodata[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_common_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_common_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_common_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_rodata[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_nt_osap1_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_common_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_common_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_common_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_common_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_nt_osap1_common_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_rodata[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap2_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap2_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_nt_osap2_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_common_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_common_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap2_common_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap2_common_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_nt_osap2_common_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_rodata[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_sdata);

extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_common_bss[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_common_data[AKTSP_NO_SMALL_DATA_SIZE]);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_common_sbss);
extern AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_common_sdata);
extern AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_kernel_common_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");


/*
 *  CheckMemoryAccess系システムサービステスト実行関数
 */
static void
AktspCheckMemoryAccess(MemoryStartAddressType start_addr, MemorySizeType mem_sz, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid, AccessType tsk2acc, AccessType tsk3acc, uint8 trusted_stack)
{
	AccessType stack_trusted_task  = 0U;
	AccessType stack_trusted_c2isr = 0U;

	if (trusted_stack == STACK_TRUSTED_TASK) {
		stack_trusted_task  = AP_StackSpace;
	}
	else if (trusted_stack == STACK_TRUSTED_C2ISR) {
		stack_trusted_c2isr = AP_StackSpace;
	}

	/* TASK1(信頼OSAP) */
	CheckAssert(CheckTaskMemoryAccess(tsk1id, start_addr, mem_sz) == (AP_Readable | AP_Writable | AP_Executable | stack_trusted_task));

	/* TASK2(非信頼OSAP1) */
	CheckAssert(CheckTaskMemoryAccess(tsk2id, start_addr, mem_sz) == tsk2acc);

	/* TASK3(非信頼OSAP2) */
	CheckAssert(CheckTaskMemoryAccess(tsk3id, start_addr, mem_sz) == tsk3acc);

	/* C2ISR1(信頼OSAP) */
	CheckAssert(CheckISRMemoryAccess(isrid, start_addr, mem_sz) == (AP_Readable | AP_Writable | AP_Executable | stack_trusted_c2isr));
}

/*
 *  すべてのOSAP，処理単位からアクセスできる領域へのアクセス
 *  ・共有領域へのアクセスなど
 *  ・すべてからアクセスできるので引数のenableは不要
 *  ・1回の呼出しで対象のすべての領域へのアクセスを実行する
 */
void
AktspAccessAllAccessibleArea(boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data, write_data;
	uint8*			start_addr;
	MemorySizeType	mem_sz;

	/********************************************************/
	/* 共有コード領域										*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_text_shared;
	mem_sz = (&__limit_text_shared - &__start_text_shared);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Executable), (AP_Readable | AP_Executable), STACK_NO_ACCESS);
	}

	/* (0)リードアクセス(先頭) */
	read_data = __start_text_shared;

	/* (1)リードアクセス(終端) */
	read_data = *(&__limit_text_shared - BACKPOINT);

	/* (2)実行アクセス */
	AktspCommonFunc();

	/********************************************************/
	/* 共有リードオンリーデータ領域							*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_rodata_shared;
	mem_sz = (&__limit_rodata_shared - &__start_rodata_shared);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (3)リードアクセス(先頭) */
	read_data = __start_rodata_shared;

	/* (4)リードアクセス(終端) */
	read_data = *(&__limit_rodata_shared - BACKPOINT);

	/*********************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の共有リード領域 */
	/*********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sdata_kernel_28_srpw;
	mem_sz = (&__limit_sdata_kernel_28_srpw - &__start_sdata_kernel_28_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (5)リードアクセス(先頭) */
	read_data = __start_sdata_kernel_28_srpw;

	/* (6)リードアクセス(終端) */
	read_data = *(&__limit_sdata_kernel_28_srpw - BACKPOINT);

	/********************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の共有リード領域 */
	/********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sbss_kernel_20_srpw;
	mem_sz = (&__limit_sbss_kernel_20_srpw - &__start_sbss_kernel_20_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (7)リードアクセス(先頭) */
	read_data = __start_sbss_kernel_20_srpw;

	/* (8)リードアクセス(終端) */
	read_data = *(&__limit_sbss_kernel_20_srpw - BACKPOINT);

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP1の専有ライト領域 */
	/**********************************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sdata_NON_TRUSTED_OSAP1_28_srpw;
	mem_sz = (&__limit_sdata_NON_TRUSTED_OSAP1_28_srpw - &__start_sdata_NON_TRUSTED_OSAP1_28_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_Readable, STACK_NO_ACCESS);
	}

	/* (9)リードアクセス(先頭) */
	read_data = __start_sdata_NON_TRUSTED_OSAP1_28_srpw;

	/* (10)リードアクセス(終端) */
	read_data = *(&__limit_sdata_NON_TRUSTED_OSAP1_28_srpw - BACKPOINT);

	/*********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP1の専有ライト領域 */
	/*********************************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sbss_NON_TRUSTED_OSAP1_20_srpw;
	mem_sz = (&__limit_sbss_NON_TRUSTED_OSAP1_20_srpw - &__start_sbss_NON_TRUSTED_OSAP1_20_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_Readable, STACK_NO_ACCESS);
	}

	/* (11)リードアクセス(先頭) */
	read_data = __start_sbss_NON_TRUSTED_OSAP1_20_srpw;

	/* (12)リードアクセス(終端) */
	read_data = *(&__limit_sbss_NON_TRUSTED_OSAP1_20_srpw - BACKPOINT);

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP2の専有ライト領域 */
	/**********************************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sdata_NON_TRUSTED_OSAP2_28_srpw;
	mem_sz = (&__limit_sdata_NON_TRUSTED_OSAP2_28_srpw - &__start_sdata_NON_TRUSTED_OSAP2_28_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (13)リードアクセス(先頭) */
	read_data = __start_sdata_NON_TRUSTED_OSAP2_28_srpw;

	/* (14)リードアクセス(終端) */
	read_data = *(&__limit_sdata_NON_TRUSTED_OSAP2_28_srpw - BACKPOINT);

	/*********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP2の専有ライト領域 */
	/*********************************************************************************/
	/* システムサービステスト */
	start_addr = &__start_sbss_NON_TRUSTED_OSAP2_20_srpw;
	mem_sz = (&__limit_sbss_NON_TRUSTED_OSAP2_20_srpw - &__start_sbss_NON_TRUSTED_OSAP2_20_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (15)リードアクセス(先頭) */
	read_data = __start_sbss_NON_TRUSTED_OSAP2_20_srpw;

	/* (16)リードアクセス(終端) */
	read_data = *(&__limit_sbss_NON_TRUSTED_OSAP2_20_srpw - BACKPOINT);

	/********************************************************/
	/* 共有リードライトデータ(スモールデータ，sdata)		*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_sdata_shared_28;
	mem_sz = (&__limit_sdata_shared_28 - &__start_sdata_shared_28);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (17)リードアクセス(先頭) */
	read_data = __start_sdata_shared_28;

	/* (18)リードアクセス(終端) */
	read_data = *(&__limit_sdata_shared_28 - BACKPOINT);

	/* (19)ライトアクセス(先頭) */
	write_data = __start_sdata_shared_28;
	__start_sdata_shared_28 = write_data;

	/* (20)ライトアクセス(終端) */
	write_data = *(&__limit_sdata_shared_28 - BACKPOINT);
	*(&__limit_sdata_shared_28 - BACKPOINT) = write_data;

	/********************************************************/
	/* 共有リードライトデータ(スモールデータ，sbss)			*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_sbss_shared_20;
	mem_sz = (&__limit_sbss_shared_20 - &__start_sbss_shared_20);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (21)リードアクセス(先頭) */
	read_data = __start_sbss_shared_20;

	/* (22)リードアクセス(終端) */
	read_data = *(&__limit_sbss_shared_20 - BACKPOINT);

	/* (23)ライトアクセス(先頭) */
	write_data = __start_sbss_shared_20;
	__start_sbss_shared_20 = write_data;

	/* (24)ライトアクセス(終端) */
	write_data = *(&__limit_sbss_shared_20 - BACKPOINT);
	*(&__limit_sbss_shared_20 - BACKPOINT) = write_data;

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，data) */
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_data_kernel_srpw;
	mem_sz = (&__limit_data_kernel_srpw - &__start_data_kernel_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (25)リードアクセス(先頭) */
	read_data = __start_data_kernel_srpw;

	/* (26)リードアクセス(終端) */
	read_data = *(&__limit_data_kernel_srpw - BACKPOINT);

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，bss)	*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_bss_kernel_srpw;
	mem_sz = (&__limit_bss_kernel_srpw - &__start_bss_kernel_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (27)リードアクセス(先頭) */
	read_data = __start_bss_kernel_srpw;

	/* (28)リードアクセス(終端) */
	read_data = *(&__limit_bss_kernel_srpw - BACKPOINT);

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，prsv) */
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_prsv_kernel_srpw;
	mem_sz = (&__limit_prsv_kernel_srpw - &__start_prsv_kernel_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_Readable, STACK_NO_ACCESS);
	}

	/* (29)リードアクセス(先頭) */
	read_data = __start_prsv_kernel_srpw;

	/* (30)リードアクセス(終端) */
	read_data = *(&__limit_prsv_kernel_srpw - BACKPOINT);

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，data) */
	/*********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_data_NON_TRUSTED_OSAP1_srpw;
	mem_sz = (&__limit_data_NON_TRUSTED_OSAP1_srpw - &__start_data_NON_TRUSTED_OSAP1_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_Readable, STACK_NO_ACCESS);
	}

	/* (31)リードアクセス(先頭) */
	read_data = __start_data_NON_TRUSTED_OSAP1_srpw;

	/* (32)リードアクセス(終端) */
	read_data = *(&__limit_data_NON_TRUSTED_OSAP1_srpw - BACKPOINT);

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，bss) */
	/********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_bss_NON_TRUSTED_OSAP1_srpw;
	mem_sz = (&__limit_bss_NON_TRUSTED_OSAP1_srpw - &__start_bss_NON_TRUSTED_OSAP1_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_Readable, STACK_NO_ACCESS);
	}

	/* (33)リードアクセス(先頭) */
	read_data = __start_bss_NON_TRUSTED_OSAP1_srpw;

	/* (34)リードアクセス(終端) */
	read_data = *(&__limit_bss_NON_TRUSTED_OSAP1_srpw - BACKPOINT);

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，prsv) */
	/*********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_prsv_NON_TRUSTED_OSAP1_srpw;
	mem_sz = (&__limit_prsv_NON_TRUSTED_OSAP1_srpw - &__start_prsv_NON_TRUSTED_OSAP1_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_Readable, STACK_NO_ACCESS);
	}

	/* (35)リードアクセス(先頭) */
	read_data = __start_prsv_NON_TRUSTED_OSAP1_srpw;

	/* (36)リードアクセス(終端) */
	read_data = *(&__limit_prsv_NON_TRUSTED_OSAP1_srpw - BACKPOINT);

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，data) */
	/*********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_data_NON_TRUSTED_OSAP2_srpw;
	mem_sz = (&__limit_data_NON_TRUSTED_OSAP2_srpw - &__start_data_NON_TRUSTED_OSAP2_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (37)リードアクセス(先頭) */
	read_data = __start_data_NON_TRUSTED_OSAP2_srpw;

	/* (38)リードアクセス(終端) */
	read_data = *(&__limit_data_NON_TRUSTED_OSAP2_srpw - BACKPOINT);

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，bss) */
	/********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_bss_NON_TRUSTED_OSAP2_srpw;
	mem_sz = (&__limit_bss_NON_TRUSTED_OSAP2_srpw - &__start_bss_NON_TRUSTED_OSAP2_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (39)リードアクセス(先頭) */
	read_data = __start_bss_NON_TRUSTED_OSAP2_srpw;

	/* (40)リードアクセス(終端) */
	read_data = *(&__limit_bss_NON_TRUSTED_OSAP2_srpw - BACKPOINT);

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，prsv) */
	/*********************************************************************/
	/* システムサービステスト */
	start_addr = &__start_prsv_NON_TRUSTED_OSAP2_srpw;
	mem_sz = (&__limit_prsv_NON_TRUSTED_OSAP2_srpw - &__start_prsv_NON_TRUSTED_OSAP2_srpw);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (41)リードアクセス(先頭) */
	read_data = __start_prsv_NON_TRUSTED_OSAP2_srpw;

	/* (42)リードアクセス(終端) */
	read_data = *(&__limit_prsv_NON_TRUSTED_OSAP2_srpw - BACKPOINT);

	/********************************************************/
	/* 共有リードライトデータ領域(data)						*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_data_shared;
	mem_sz = (&__limit_data_shared - &__start_data_shared);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (43)リードアクセス(先頭) */
	read_data = __start_data_shared;

	/* (44)リードアクセス(終端) */
	read_data = *(&__limit_data_shared - BACKPOINT);

	/* (45)ライトアクセス(先頭) */
	write_data = __start_data_shared;
	__start_data_shared = write_data;

	/* (46)ライトアクセス(終端) */
	write_data = *(&__limit_data_shared - BACKPOINT);
	*(&__limit_data_shared - BACKPOINT) = write_data;

	/********************************************************/
	/* 共有リードライトデータ領域(bss)						*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_bss_shared;
	mem_sz = (&__limit_bss_shared - &__start_bss_shared);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (47)リードアクセス(先頭) */
	read_data = __start_bss_shared;

	/* (48)リードアクセス(終端) */
	read_data = *(&__limit_bss_shared - BACKPOINT);

	/* (49)ライトアクセス(先頭) */
	write_data = __start_bss_shared;
	__start_bss_shared = write_data;

	/* (50)ライトアクセス(終端) */
	write_data = *(&__limit_bss_shared - BACKPOINT);
	*(&__limit_bss_shared - BACKPOINT) = write_data;

	/********************************************************/
	/* 共有リードライトデータ領域(prsv)						*/
	/********************************************************/
	/* システムサービステスト */
	start_addr = &__start_prsv_shared;
	mem_sz = (&__limit_prsv_shared - &__start_prsv_shared);
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), (AP_Readable | AP_Writable), STACK_NO_ACCESS);
	}

	/* (51)リードアクセス(先頭) */
	read_data = __start_prsv_shared;

	/* (52)リードアクセス(終端) */
	read_data = *(&__limit_prsv_shared - BACKPOINT);

	/* (53)ライトアクセス(先頭) */
	write_data = __start_prsv_shared;
	__start_prsv_shared = write_data;

	/* (54)ライトアクセス(終端) */
	write_data = *(&__limit_prsv_shared - BACKPOINT);
	*(&__limit_prsv_shared - BACKPOINT) = write_data;
}

/*
 *  非信頼OSAP1からのみアクセスできない領域へのアクセス
 *  ・非信頼OSAP2の専有領域へのアクセスなど
 *  ・enableがtrueの場合，switch文のすべてのcaseを実行することで，
 *    1回の呼出しで対象のすべての領域へのアクセスを実行する
 *  ・ライトアクセスの対象はテスト用データ領域のため書き換えても問題ない
 */
void
AktspAccessNtOsap1InaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data;
	uint8			check_num = 0U;
	uint8*			start_addr;
	MemorySizeType	mem_sz;

	/* アクセス可能の場合は，actionは0以外指定不可 */
	if (enable && (action != 0)) {
		CheckAssert(FALSE);
	}

	switch (action) {
	/********************************************************/
	/* 非信頼OSAP2の専有コード領域							*/
	/********************************************************/
	case 0:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_text_NON_TRUSTED_OSAP2;
		mem_sz = (&__limit_text_NON_TRUSTED_OSAP2 - &__start_text_NON_TRUSTED_OSAP2);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Executable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_text_NON_TRUSTED_OSAP2;
		IF_NOT_ENABLE_BREAK;
	case 1:		/* リードアクセス(終端) */
		read_data = *(&__limit_text_NON_TRUSTED_OSAP2 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 2:		/* 実行アクセス */
		AktspNonTrustedOsap2Func();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードオンリー領域					*/
	/********************************************************/
	case 3:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_rodata_NON_TRUSTED_OSAP2;
		mem_sz = (&__limit_rodata_NON_TRUSTED_OSAP2 - &__start_rodata_NON_TRUSTED_OSAP2);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_Readable, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_rodata_NON_TRUSTED_OSAP2;
		IF_NOT_ENABLE_BREAK;
	case 4:		/* リードアクセス(終端) */
		read_data = *(&__limit_rodata_NON_TRUSTED_OSAP2 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;

	/******************************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(スモールデータ，sdata) */
	/******************************************************************/
	case 5:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sdata_NON_TRUSTED_OSAP2_28;
		mem_sz = (&__limit_sdata_NON_TRUSTED_OSAP2_28 - &__start_sdata_NON_TRUSTED_OSAP2_28);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sdata_NON_TRUSTED_OSAP2_28;
		IF_NOT_ENABLE_BREAK;
	case 6:		/* リードアクセス(終端) */
		read_data = *(&__limit_sdata_NON_TRUSTED_OSAP2_28 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 7:		/* ライトアクセス(先頭) */
		__start_sdata_NON_TRUSTED_OSAP2_28 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 8:		/* ライトアクセス(終端) */
		*(&__limit_sdata_NON_TRUSTED_OSAP2_28 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*****************************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(スモールデータ，sbss) */
	/*****************************************************************/
	case 9:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sbss_NON_TRUSTED_OSAP2_20;
		mem_sz = (&__limit_sbss_NON_TRUSTED_OSAP2_20 - &__start_sbss_NON_TRUSTED_OSAP2_20);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sbss_NON_TRUSTED_OSAP2_20;
		IF_NOT_ENABLE_BREAK;
	case 10:	/* リードアクセス(終端) */
		read_data = *(&__limit_sbss_NON_TRUSTED_OSAP2_20 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 11:	/* ライトアクセス(先頭) */
		__start_sbss_NON_TRUSTED_OSAP2_20 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 12:	/* ライトアクセス(終端) */
		*(&__limit_sbss_NON_TRUSTED_OSAP2_20 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP2の専有ライト領域 */
	/**********************************************************************************/
	case 13:	/* ライトアクセス(先頭) */
		__start_sdata_NON_TRUSTED_OSAP2_28_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 14:	/* ライトアクセス(終端) */
		*(&__limit_sdata_NON_TRUSTED_OSAP2_28_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP2の専有ライト領域 */
	/**********************************************************************************/
	case 15:	/* ライトアクセス(先頭) */
		__start_sbss_NON_TRUSTED_OSAP2_20_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 16:	/* ライトアクセス(終端) */
		*(&__limit_sbss_NON_TRUSTED_OSAP2_20_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(data)		*/
	/********************************************************/
	case 17:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_data_NON_TRUSTED_OSAP2;
		mem_sz = (&__limit_data_NON_TRUSTED_OSAP2 - &__start_data_NON_TRUSTED_OSAP2);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_data_NON_TRUSTED_OSAP2;
		IF_NOT_ENABLE_BREAK;
	case 18:	/* リードアクセス(終端) */
		read_data = *(&__limit_data_NON_TRUSTED_OSAP2 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 19:	/* ライトアクセス(先頭) */
		__start_data_NON_TRUSTED_OSAP2 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 20:	/* ライトアクセス(終端) */
		*(&__limit_data_NON_TRUSTED_OSAP2 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(bss)			*/
	/********************************************************/
	case 21:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_bss_NON_TRUSTED_OSAP2;
		mem_sz = (&__limit_bss_NON_TRUSTED_OSAP2 - &__start_bss_NON_TRUSTED_OSAP2);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_bss_NON_TRUSTED_OSAP2;
		IF_NOT_ENABLE_BREAK;
	case 22:	/* リードアクセス(終端) */
		read_data = *(&__limit_bss_NON_TRUSTED_OSAP2 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 23:	/* ライトアクセス(先頭) */
		__start_bss_NON_TRUSTED_OSAP2 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 24:	/* ライトアクセス(終端) */
		*(&__limit_bss_NON_TRUSTED_OSAP2 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(prsv)		*/
	/********************************************************/
	case 25:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_prsv_NON_TRUSTED_OSAP2;
		mem_sz = (&__limit_prsv_NON_TRUSTED_OSAP2 - &__start_prsv_NON_TRUSTED_OSAP2);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, (AP_Readable | AP_Writable), STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_prsv_NON_TRUSTED_OSAP2;
		IF_NOT_ENABLE_BREAK;
	case 26:	/* リードアクセス(終端) */
		read_data = *(&__limit_prsv_NON_TRUSTED_OSAP2 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 27:	/* ライトアクセス(先頭) */
		__start_prsv_NON_TRUSTED_OSAP2 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 28:	/* ライトアクセス(終端) */
		*(&__limit_prsv_NON_TRUSTED_OSAP2 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，data) */
	/*********************************************************************/
	case 29:	/* ライトアクセス(先頭) */
		__start_data_NON_TRUSTED_OSAP2_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 30:	/* ライトアクセス(終端) */
		*(&__limit_data_NON_TRUSTED_OSAP2_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，bss) */
	/********************************************************************/
	case 31:	/* ライトアクセス(先頭) */
		__start_bss_NON_TRUSTED_OSAP2_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 32:	/* ライトアクセス(終端) */
		*(&__limit_bss_NON_TRUSTED_OSAP2_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，prsv)*/
	/********************************************************/
	case 33:	/* ライトアクセス(先頭) */
		__start_prsv_NON_TRUSTED_OSAP2_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 34:	/* ライトアクセス(終端) */
		*(&__limit_prsv_NON_TRUSTED_OSAP2_srpw - BACKPOINT) = (uint8)1;
		break;

	default:
		CheckAssert(FALSE);
	}

	/* アクセス可能の場合は，全領域へのアクセスを確認 */
	if (enable && (check_num != 34)) {
		CheckAssert(FALSE);
	}
}

/*
 *  非信頼OSAP2からのみアクセスできない領域へのアクセス
 *  ・非信頼OSAP1の専有領域へのアクセスなど
 *  ・enableがtrueの場合，switch文のすべてのcaseを実行することで，
 *    1回の呼出しで対象のすべての領域へのアクセスを実行する
 *  ・ライトアクセスの対象はテスト用データ領域のため書き換えても問題ない
 */
void AktspAccessNtOsap2InaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data;
	uint8			check_num = 0U;
	uint8*			start_addr;
	MemorySizeType	mem_sz;

	/* アクセス可能の場合は，actionは0以外指定不可 */
	if (enable && (action != 0)) {
		CheckAssert(FALSE);
	}

	switch (action) {
	/********************************************************/
	/* 非信頼OSAP1の専有コード領域							*/
	/********************************************************/
	case 0:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_text_NON_TRUSTED_OSAP1;
		mem_sz = (&__limit_text_NON_TRUSTED_OSAP1 - &__start_text_NON_TRUSTED_OSAP1);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Executable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_text_NON_TRUSTED_OSAP1;
		IF_NOT_ENABLE_BREAK;
	case 1:		/* リードアクセス(終端) */
		read_data = *(&__limit_text_NON_TRUSTED_OSAP1 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 2:		/* 実行アクセス */
		AktspNonTrustedOsap1Func();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードオンリー領域					*/
	/********************************************************/
	case 3:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_rodata_NON_TRUSTED_OSAP1;
		mem_sz = (&__limit_rodata_NON_TRUSTED_OSAP1 - &__start_rodata_NON_TRUSTED_OSAP1);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_Readable, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_rodata_NON_TRUSTED_OSAP1;
		IF_NOT_ENABLE_BREAK;
	case 4:		/* リードアクセス(終端) */
		read_data = *(&__limit_rodata_NON_TRUSTED_OSAP1 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;

	/******************************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(スモールデータ，sdata) */
	/******************************************************************/
	case 5:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sdata_NON_TRUSTED_OSAP1_28;
		mem_sz = (&__limit_sdata_NON_TRUSTED_OSAP1_28 - &__start_sdata_NON_TRUSTED_OSAP1_28);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sdata_NON_TRUSTED_OSAP1_28;
		IF_NOT_ENABLE_BREAK;
	case 6:		/* リードアクセス(終端) */
		read_data = *(&__limit_sdata_NON_TRUSTED_OSAP1_28 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 7:		/* ライトアクセス(先頭) */
		__start_sdata_NON_TRUSTED_OSAP1_28 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 8:		/* ライトアクセス(終端) */
		*(&__limit_sdata_NON_TRUSTED_OSAP1_28 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*****************************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(スモールデータ，sbss) */
	/*****************************************************************/
	case 9:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sbss_NON_TRUSTED_OSAP1_20;
		mem_sz = (&__limit_sbss_NON_TRUSTED_OSAP1_20 - &__start_sbss_NON_TRUSTED_OSAP1_20);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sbss_NON_TRUSTED_OSAP1_20;
		IF_NOT_ENABLE_BREAK;
	case 10:	/* リードアクセス(終端) */
		read_data = *(&__limit_sbss_NON_TRUSTED_OSAP1_20 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 11:	/* ライトアクセス(先頭) */
		__start_sbss_NON_TRUSTED_OSAP1_20 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 12:	/* ライトアクセス(終端) */
		*(&__limit_sbss_NON_TRUSTED_OSAP1_20 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP1の専有ライト領域 */
	/**********************************************************************************/
	case 13:	/* ライトアクセス(先頭) */
		__start_sdata_NON_TRUSTED_OSAP1_28_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 14:	/* ライトアクセス(終端) */
		*(&__limit_sdata_NON_TRUSTED_OSAP1_28_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP1の専有ライト領域 */
	/*********************************************************************************/
	case 15:	/* ライトアクセス(先頭) */
		__start_sbss_NON_TRUSTED_OSAP1_20_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 16:	/* ライトアクセス(終端) */
		*(&__limit_sbss_NON_TRUSTED_OSAP1_20_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(data)		*/
	/********************************************************/
	case 17:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_data_NON_TRUSTED_OSAP1;
		mem_sz = (&__limit_data_NON_TRUSTED_OSAP1 - &__start_data_NON_TRUSTED_OSAP1);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_data_NON_TRUSTED_OSAP1;
		IF_NOT_ENABLE_BREAK;
	case 18:	/* リードアクセス(終端) */
		read_data = *(&__limit_data_NON_TRUSTED_OSAP1 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 19:	/* ライトアクセス(先頭) */
		__start_data_NON_TRUSTED_OSAP1 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 20:	/* ライトアクセス(終端) */
		*(&__limit_data_NON_TRUSTED_OSAP1 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(bss)			*/
	/********************************************************/
	case 21:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_bss_NON_TRUSTED_OSAP1;
		mem_sz = (&__limit_bss_NON_TRUSTED_OSAP1 - &__start_bss_NON_TRUSTED_OSAP1);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_bss_NON_TRUSTED_OSAP1;
		IF_NOT_ENABLE_BREAK;
	case 22:	/* リードアクセス(終端) */
		read_data = *(&__limit_bss_NON_TRUSTED_OSAP1 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 23:	/* ライトアクセス(先頭) */
		__start_bss_NON_TRUSTED_OSAP1 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 24:	/* ライトアクセス(終端) */
		*(&__limit_bss_NON_TRUSTED_OSAP1 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(prsv)		*/
	/********************************************************/
	case 25:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_prsv_NON_TRUSTED_OSAP1;
		mem_sz = (&__limit_prsv_NON_TRUSTED_OSAP1 - &__start_prsv_NON_TRUSTED_OSAP1);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, (AP_Readable | AP_Writable), AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_prsv_NON_TRUSTED_OSAP1;
		IF_NOT_ENABLE_BREAK;
	case 26:	/* リードアクセス(終端) */
		read_data = *(&__limit_prsv_NON_TRUSTED_OSAP1 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 27:	/* ライトアクセス(先頭) */
		__start_prsv_NON_TRUSTED_OSAP1 = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 28:	/* ライトアクセス(終端) */
		*(&__limit_prsv_NON_TRUSTED_OSAP1 - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，data) */
	/*********************************************************************/
	case 29:	/* ライトアクセス(先頭) */
		__start_data_NON_TRUSTED_OSAP1_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 30:	/* ライトアクセス(終端) */
		*(&__limit_data_NON_TRUSTED_OSAP1_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，bss) */
	/********************************************************************/
	case 31:	/* ライトアクセス(先頭) */
		__start_bss_NON_TRUSTED_OSAP1_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 32:	/* ライトアクセス(終端) */
		*(&__limit_bss_NON_TRUSTED_OSAP1_srpw - BACKPOINT) = (uint8)1;
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，prsv) */
	/*********************************************************************/
	case 33:	/* ライトアクセス(先頭) */
		__start_prsv_NON_TRUSTED_OSAP1_srpw = (uint8)1;
		IF_NOT_ENABLE_BREAK;
	case 34:	/* ライトアクセス(終端) */
		*(&__limit_prsv_NON_TRUSTED_OSAP1_srpw - BACKPOINT) = (uint8)1;
		break;

	default:
		CheckAssert(FALSE);
	}

	/* アクセス可能の場合は，全領域へのアクセスを確認 */
	if (enable && (check_num != 34)) {
		CheckAssert(FALSE);
	}
}

/*
 *  全ての非信頼OSAPからアクセスできない領域へのアクセス
 *  ・OS専有領域，ROMへの書込み，リードライトへの実行アクセスなど
 *  ・enableがtrueの場合，switch文のすべてのcaseを実行することで，
 *    1回の呼出しで対象のすべての領域へのアクセスを実行する
 *  ・実行アクセスは，対象領域にret命令データを書き込み，実行する
 *  ・初期化時にret命令データを書き込める領域には，書き込み済みである
 *  ・実行アクセス，ライトアクセスでは，対象領域を書き換えると問題が発生するので，
 *    enableがtrueの場合，事前にデータを保持してテスト後，元に戻す
 */
void AktspAccessAllNtOsapInaccessibleArea(boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data;
	uint8			stack_data[64], i;
	uint8			write_data = 0U;
	uint8			check_num = 0U;
	uint8*			start_addr;
	uint8*			os_stack_addr = AKTSP_OS_STACK_ADDRESS;
	MemorySizeType	mem_sz;
	void			(*pfunc)();

	/* アクセス可能の場合は，actionは0以外指定不可 */
	if (enable && (action != 0)) {
		CheckAssert(FALSE);
	}

	switch (action) {
	/********************************************************/
	/* OSの専用コード領域									*/
	/********************************************************/
	case 0:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_text_kernel;
		mem_sz = (&__limit_text_kernel - &__start_text_kernel);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_text_kernel;
		IF_NOT_ENABLE_BREAK;
	case 1:		/* リードアクセス(終端) */
		read_data = *(&__limit_text_kernel - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 2:		/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_text_kernel;
		}
		__start_text_kernel = write_data;
		IF_NOT_ENABLE_BREAK;
	case 3:		/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_text_kernel - BACKPOINT);
		}
		*(&__limit_text_kernel - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 4:		/* 実行アクセス */
		AktspKernelFunc();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードオンリーデータ領域						*/
	/********************************************************/
	case 5:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_rodata_kernel;
		mem_sz = (&__limit_rodata_kernel - &__start_rodata_kernel);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_rodata_kernel;
		IF_NOT_ENABLE_BREAK;
	case 6:		/* リードアクセス(終端) */
		read_data = *(&__limit_rodata_kernel - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 7:		/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_rodata_kernel;
		}
		__start_rodata_kernel = write_data;
		IF_NOT_ENABLE_BREAK;
	case 8:		/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_rodata_kernel - BACKPOINT);
		}
		*(&__limit_rodata_kernel - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 9:		/* 実行アクセス */
		pfunc = (void *) (&aktg_kernel_rodata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有コード領域							*/
	/********************************************************/
	case 10:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_text_NON_TRUSTED_OSAP1;
		}
		__start_text_NON_TRUSTED_OSAP1 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 11:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_text_NON_TRUSTED_OSAP1 - BACKPOINT);
		}
		*(&__limit_text_NON_TRUSTED_OSAP1 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードオンリー領域					*/
	/********************************************************/
	case 12:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_rodata_NON_TRUSTED_OSAP1;
		}
		__start_rodata_NON_TRUSTED_OSAP1 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 13:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_rodata_NON_TRUSTED_OSAP1 - BACKPOINT);
		}
		*(&__limit_rodata_NON_TRUSTED_OSAP1 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 14:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap1_rodata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有コード領域							*/
	/********************************************************/
	case 15:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_text_NON_TRUSTED_OSAP2;
		}
		__start_text_NON_TRUSTED_OSAP2 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 16:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_text_NON_TRUSTED_OSAP2 - BACKPOINT);
		}
		*(&__limit_text_NON_TRUSTED_OSAP2 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードオンリー領域					*/
	/********************************************************/
	case 17:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_rodata_NON_TRUSTED_OSAP2;
		}
		__start_rodata_NON_TRUSTED_OSAP2 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 18:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_rodata_NON_TRUSTED_OSAP2 - BACKPOINT);
		}
		*(&__limit_rodata_NON_TRUSTED_OSAP2 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 19:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap2_rodata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有コード領域										*/
	/********************************************************/
	case 20:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_text_shared;
		}
		__start_text_shared = write_data;
		IF_NOT_ENABLE_BREAK;
	case 21:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_text_shared - BACKPOINT);
		}
		*(&__limit_text_shared - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードオンリーデータ領域							*/
	/********************************************************/
	case 22:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_rodata_shared;
		}
		__start_rodata_shared = write_data;
		IF_NOT_ENABLE_BREAK;
	case 23:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_rodata_shared - BACKPOINT);
		}
		*(&__limit_rodata_shared - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 24:	/* 実行アクセス */
		pfunc = (void *) (&aktg_common_rodata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(スモールデータ，sdata)		*/
	/********************************************************/
	case 25:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sdata_kernel_28;
		mem_sz = (&__limit_sdata_kernel_28 - &__start_sdata_kernel_28);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sdata_kernel_28;
		IF_NOT_ENABLE_BREAK;
	case 26:	/* リードアクセス(終端) */
		read_data = *(&__limit_sdata_kernel_28 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 27:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_sdata_kernel_28;
		}
		__start_sdata_kernel_28 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 28:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_sdata_kernel_28 - BACKPOINT);
		}
		*(&__limit_sdata_kernel_28 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 29:	/* 実行アクセス */
		pfunc = (void *) (&aktg_kernel_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(スモールデータ，sbss)		*/
	/********************************************************/
	case 30:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_sbss_kernel_20;
		mem_sz = (&__limit_sbss_kernel_20 - &__start_sbss_kernel_20);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_sbss_kernel_20;
		IF_NOT_ENABLE_BREAK;
	case 31:	/* リードアクセス(終端) */
		read_data = *(&__limit_sbss_kernel_20 - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 32:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_sbss_kernel_20;
		}
		__start_sbss_kernel_20 = write_data;
		IF_NOT_ENABLE_BREAK;
	case 33:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_sbss_kernel_20 - BACKPOINT);
		}
		*(&__limit_sbss_kernel_20 - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 34:	/* 実行アクセス */
		if (enable) {
			aktg_kernel_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_kernel_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/******************************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(スモールデータ，sdata) */
	/******************************************************************/
	case 35:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap1_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*****************************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(スモールデータ，sbss) */
	/*****************************************************************/
	case 36:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap1_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/******************************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(スモールデータ，sdata) */
	/******************************************************************/
	case 37:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap2_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*****************************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(スモールデータ，sbss) */
	/*****************************************************************/
	case 38:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap2_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の共有リード領域 */
	/*********************************************************************/
	case 39:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_sdata_kernel_28_srpw;
		}
		__start_sdata_kernel_28_srpw = write_data;
		IF_NOT_ENABLE_BREAK;
	case 40:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_sdata_kernel_28_srpw - BACKPOINT);
		}
		*(&__limit_sdata_kernel_28_srpw - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 41:	/* 実行アクセス */
		pfunc = (void *) (&aktg_kernel_common_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の共有リード領域 */
	/********************************************************************/
	case 42:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_sbss_kernel_20_srpw;
		}
		__start_sbss_kernel_20_srpw = write_data;
		IF_NOT_ENABLE_BREAK;
	case 43:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_sbss_kernel_20_srpw - BACKPOINT);
		}
		*(&__limit_sbss_kernel_20_srpw - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 44:	/* 実行アクセス */
		if (enable) {
			aktg_kernel_common_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_kernel_common_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP1の専有ライト領域 */
	/**********************************************************************************/
	case 45:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap1_common_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP1の専有ライト領域 */
	/*********************************************************************************/
	case 46:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_common_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap1_common_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/**********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sdata)の非信頼OSAP2の専有ライト領域 */
	/**********************************************************************************/
	case 47:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap2_common_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************************/
	/* 共有リード専有ライトデータ(スモールデータ，sbss)の非信頼OSAP2の専有ライト領域 */
	/*********************************************************************************/
	case 48:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_common_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap2_common_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードライトデータ(スモールデータ，sdata)		*/
	/********************************************************/
	case 49:	/* 実行アクセス */
		pfunc = (void *) (&aktg_common_sdata);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードライトデータ(スモールデータ，sbss)		*/
	/********************************************************/
	case 50:	/* 実行アクセス */
		if (enable) {
			aktg_common_sbss = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_common_sbss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(data)						*/
	/********************************************************/
	case 51:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_data_kernel;
		mem_sz = (&__limit_data_kernel - &__start_data_kernel);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_data_kernel;
		IF_NOT_ENABLE_BREAK;
	case 52:	/* リードアクセス(終端) */
		read_data = *(&__limit_data_kernel - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 53:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_data_kernel;
		}
		__start_data_kernel = write_data;
		IF_NOT_ENABLE_BREAK;
	case 54:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_data_kernel - BACKPOINT);
		}
		*(&__limit_data_kernel - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 55:	/* 実行アクセス */
		pfunc = (void *) (&aktg_kernel_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(bss)						*/
	/********************************************************/
	case 56:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &__start_bss_kernel;
		mem_sz = (&__limit_bss_kernel - &__start_bss_kernel);
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = __start_bss_kernel;
		IF_NOT_ENABLE_BREAK;
	case 57:	/* リードアクセス(終端) */
		read_data = *(&__limit_bss_kernel - BACKPOINT);
		IF_NOT_ENABLE_BREAK;
	case 58:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_bss_kernel;
		}
		__start_bss_kernel = write_data;
		IF_NOT_ENABLE_BREAK;
	case 59:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_bss_kernel - BACKPOINT);
		}
		*(&__limit_bss_kernel - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 60:	/* 実行アクセス */
		if (enable) {
			aktg_kernel_bss[0] = AKTSP_RET_ORDER_0;
			aktg_kernel_bss[1] = AKTSP_RET_ORDER_1;
			aktg_kernel_bss[2] = AKTSP_RET_ORDER_2;
			aktg_kernel_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_kernel_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(prsv)(割込みスタック)		*/
	/********************************************************/
	case 61:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = os_stack_addr;
		mem_sz = AKTSP_OS_STACK_SIZE;
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_TRUSTED_C2ISR);
		}
		/* メモリアクセステスト */
		read_data = os_stack_addr[0];
		IF_NOT_ENABLE_BREAK;
	case 62:	/* リードアクセス(終端) */
		read_data = os_stack_addr[AKTSP_OS_STACK_SIZE - 1];
		IF_NOT_ENABLE_BREAK;
	case 63:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = os_stack_addr[0];
		}
		os_stack_addr[0] = write_data;
		IF_NOT_ENABLE_BREAK;
	case 64:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = os_stack_addr[AKTSP_OS_STACK_SIZE - 1];
		}
		os_stack_addr[AKTSP_OS_STACK_SIZE - 1] = write_data;
		IF_NOT_ENABLE_BREAK;
	case 65:	/* 実行アクセス */
		if (enable) {
			for (i = 0; i < 64; i++) {
				stack_data[i] = os_stack_addr[i];
				os_stack_addr[i] = 0U;
			}
			os_stack_addr[0] = AKTSP_RET_ORDER_0;
			os_stack_addr[1] = AKTSP_RET_ORDER_1;
			os_stack_addr[2] = AKTSP_RET_ORDER_2;
			os_stack_addr[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&os_stack_addr[0]);
		(*pfunc)();
		if (enable) {
			for (i = 0; i < 64; i++) {
				os_stack_addr[i] = stack_data[i];
			}
		}
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* OSの専有リードライト領域(prsv)(信頼タスクスタック)	*/
	/********************************************************/
	case 66:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &AKTSP_MEM_TR_TASK_STACK(0, 0);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_TRUSTED_TASK);
		}
		/* メモリアクセステスト */
		read_data = AKTSP_MEM_TR_TASK_STACK(0, 0);
		IF_NOT_ENABLE_BREAK;
	case 67:	/* リードアクセス(終端) */
		read_data = AKTSP_MEM_TR_TASK_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		IF_NOT_ENABLE_BREAK;
	case 68:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = AKTSP_MEM_TR_TASK_STACK(0, 0);
		}
		AKTSP_MEM_TR_TASK_STACK(0, 0) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 69:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = AKTSP_MEM_TR_TASK_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		}
		AKTSP_MEM_TR_TASK_STACK(0, AKTSP_TASK_STACK_SIZE - 1) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 70:	/* 実行アクセス */
		if (enable) {
			for (i = 0; i < 64; i++) {
				stack_data[i] = AKTSP_MEM_TR_TASK_STACK(0, i);
				AKTSP_MEM_TR_TASK_STACK(0, i) = 0U;
			}
			AKTSP_MEM_TR_TASK_STACK(0, 0) = AKTSP_RET_ORDER_0;
			AKTSP_MEM_TR_TASK_STACK(0, 1) = AKTSP_RET_ORDER_1;
			AKTSP_MEM_TR_TASK_STACK(0, 2) = AKTSP_RET_ORDER_2;
			AKTSP_MEM_TR_TASK_STACK(0, 3) = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&AKTSP_MEM_TR_TASK_STACK(0, 0));
		(*pfunc)();
		if (enable) {
			for (i = 0; i < 64; i++) {
				AKTSP_MEM_TR_TASK_STACK(0, i) = stack_data[i];
			}
		}
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* OSの専有リードライト領域(prsv)(非信頼OSAP1タスクシステムスタック) */
	/*********************************************************************/
	case 71:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &AKTSP_MEM_TASK_SYS_STACK(0, 0);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = AKTSP_MEM_TASK_SYS_STACK(0, 0);
		IF_NOT_ENABLE_BREAK;
	case 72:	/* リードアクセス(終端) */
		read_data = AKTSP_MEM_TASK_SYS_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		IF_NOT_ENABLE_BREAK;
	case 73:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = AKTSP_MEM_TASK_SYS_STACK(0, 0);
		}
		AKTSP_MEM_TASK_SYS_STACK(0, 0) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 74:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = AKTSP_MEM_TASK_SYS_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		}
		AKTSP_MEM_TASK_SYS_STACK(0, AKTSP_TASK_STACK_SIZE - 1) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 75:	/* 実行アクセス */
		if (enable) {
			for (i = 0; i < 64; i++) {
				stack_data[i] = AKTSP_MEM_TASK_SYS_STACK(0, i);
				AKTSP_MEM_TASK_SYS_STACK(0, i) = 0U;
			}
			AKTSP_MEM_TASK_SYS_STACK(0, 0) = AKTSP_RET_ORDER_0;
			AKTSP_MEM_TASK_SYS_STACK(0, 1) = AKTSP_RET_ORDER_1;
			AKTSP_MEM_TASK_SYS_STACK(0, 2) = AKTSP_RET_ORDER_2;
			AKTSP_MEM_TASK_SYS_STACK(0, 3) = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&AKTSP_MEM_TASK_SYS_STACK(0, 0));
		(*pfunc)();
		if (enable) {
			for (i = 0; i < 64; i++) {
				AKTSP_MEM_TASK_SYS_STACK(0, i) = stack_data[i];
			}
		}
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* OSの専有リードライト領域(prsv)(非信頼OSAP2タスクシステムスタック) */
	/*********************************************************************/
	case 76:	/* リードアクセス(先頭) */
		/* システムサービステスト */
		start_addr = &AKTSP_MEM_TASK_SYS_STACK(1, 0);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, AP_NoAccess, AP_NoAccess, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = AKTSP_MEM_TASK_SYS_STACK(1, 0);
		IF_NOT_ENABLE_BREAK;
	case 77:	/* リードアクセス(終端) */
		read_data = AKTSP_MEM_TASK_SYS_STACK(1, AKTSP_TASK_STACK_SIZE - 1);
		IF_NOT_ENABLE_BREAK;
	case 78:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = AKTSP_MEM_TASK_SYS_STACK(1, 0);
		}
		AKTSP_MEM_TASK_SYS_STACK(1, 0) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 79:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = AKTSP_MEM_TASK_SYS_STACK(1, AKTSP_TASK_STACK_SIZE - 1);
		}
		AKTSP_MEM_TASK_SYS_STACK(1, AKTSP_TASK_STACK_SIZE - 1) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 80:	/* 実行アクセス */
		if (enable) {
			for (i = 0; i < 64; i++) {
				stack_data[i] = AKTSP_MEM_TASK_SYS_STACK(1, i);
				AKTSP_MEM_TASK_SYS_STACK(1, i) = 0U;
			}
			AKTSP_MEM_TASK_SYS_STACK(1, 0) = AKTSP_RET_ORDER_0;
			AKTSP_MEM_TASK_SYS_STACK(1, 1) = AKTSP_RET_ORDER_1;
			AKTSP_MEM_TASK_SYS_STACK(1, 2) = AKTSP_RET_ORDER_2;
			AKTSP_MEM_TASK_SYS_STACK(1, 3) = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&AKTSP_MEM_TASK_SYS_STACK(1, 0));
		(*pfunc)();
		if (enable) {
			for (i = 0; i < 64; i++) {
				AKTSP_MEM_TASK_SYS_STACK(1, i) = stack_data[i];
			}
		}
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(data)		*/
	/********************************************************/
	case 81:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap1_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(bss)			*/
	/********************************************************/
	case 82:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_bss[0] = AKTSP_RET_ORDER_0;
			aktg_nt_osap1_bss[1] = AKTSP_RET_ORDER_1;
			aktg_nt_osap1_bss[2] = AKTSP_RET_ORDER_2;
			aktg_nt_osap1_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_nt_osap1_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP1の専有リードライトデータ領域(prsv)		*/
	/********************************************************/
	case 83:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap1_prsv[0]);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(data)		*/
	/********************************************************/
	case 84:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap2_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(bss)			*/
	/********************************************************/
	case 85:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_bss[0] = AKTSP_RET_ORDER_0;
			aktg_nt_osap2_bss[1] = AKTSP_RET_ORDER_1;
			aktg_nt_osap2_bss[2] = AKTSP_RET_ORDER_2;
			aktg_nt_osap2_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_nt_osap2_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 非信頼OSAP2の専有リードライトデータ領域(prsv)		*/
	/********************************************************/
	case 86:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap2_prsv[0]);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，data)	*/
	/********************************************************/
	case 87:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_data_kernel_srpw;
		}
		__start_data_kernel_srpw = write_data;
		IF_NOT_ENABLE_BREAK;
	case 88:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_data_kernel_srpw - BACKPOINT);
		}
		*(&__limit_data_kernel_srpw - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 89:	/* 実行アクセス */
		pfunc = (void *) (&aktg_kernel_common_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，bss)	*/
	/********************************************************/
	case 90:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_bss_kernel_srpw;
		}
		__start_bss_kernel_srpw = write_data;
		IF_NOT_ENABLE_BREAK;
	case 91:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_bss_kernel_srpw - BACKPOINT);
		}
		*(&__limit_bss_kernel_srpw - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 92:	/* 実行アクセス */
		if (enable) {
			aktg_kernel_common_bss[0] = AKTSP_RET_ORDER_0;
			aktg_kernel_common_bss[1] = AKTSP_RET_ORDER_1;
			aktg_kernel_common_bss[2] = AKTSP_RET_ORDER_2;
			aktg_kernel_common_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_kernel_common_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リード専有ライトデータ領域(共有リード領域，prsv)	*/
	/********************************************************/
	case 93:	/* ライトアクセス(先頭) */
		if (enable) {
			write_data = __start_prsv_kernel_srpw;
		}
		__start_prsv_kernel_srpw = write_data;
		IF_NOT_ENABLE_BREAK;
	case 94:	/* ライトアクセス(終端) */
		if (enable) {
			write_data = *(&__limit_prsv_kernel_srpw - BACKPOINT);
		}
		*(&__limit_prsv_kernel_srpw - BACKPOINT) = write_data;
		IF_NOT_ENABLE_BREAK;
	case 95:	/* 実行アクセス */
		if (enable) {
			aktg_kernel_common_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_kernel_common_prsv[0]);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，data) */
	/*********************************************************************/
	case 96:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap1_common_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，bss) */
	/********************************************************************/
	case 97:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_common_bss[0] = AKTSP_RET_ORDER_0;
			aktg_nt_osap1_common_bss[1] = AKTSP_RET_ORDER_1;
			aktg_nt_osap1_common_bss[2] = AKTSP_RET_ORDER_2;
			aktg_nt_osap1_common_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_nt_osap1_common_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP1の専有ライト領域，prsv) */
	/*********************************************************************/
	case 98:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap1_common_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap1_common_prsv[0]);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，data) */
	/*********************************************************************/
	case 99:	/* 実行アクセス */
		pfunc = (void *) (&aktg_nt_osap2_common_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，bss) */
	/********************************************************************/
	case 100:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_common_bss[0] = AKTSP_RET_ORDER_0;
			aktg_nt_osap2_common_bss[1] = AKTSP_RET_ORDER_1;
			aktg_nt_osap2_common_bss[2] = AKTSP_RET_ORDER_2;
			aktg_nt_osap2_common_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_nt_osap2_common_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/*********************************************************************/
	/* 共有リード専有ライトデータ領域(非信頼OSAP2の専有ライト領域，prsv) */
	/*********************************************************************/
	case 101:	/* 実行アクセス */
		if (enable) {
			aktg_nt_osap2_common_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_nt_osap2_common_prsv[0]);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードライトデータ領域(data)						*/
	/********************************************************/
	case 102:	/* 実行アクセス */
		pfunc = (void *) (&aktg_common_data);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードライトデータ領域(bss)						*/
	/********************************************************/
	case 103:	/* 実行アクセス */
		if (enable) {
			aktg_common_bss[0] = AKTSP_RET_ORDER_0;
			aktg_common_bss[1] = AKTSP_RET_ORDER_1;
			aktg_common_bss[2] = AKTSP_RET_ORDER_2;
			aktg_common_bss[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void *) (&aktg_common_bss);
		(*pfunc)();
		IF_NOT_ENABLE_BREAK;

	/********************************************************/
	/* 共有リードライトデータ領域(prsv)						*/
	/********************************************************/
	case 104:	/* 実行アクセス */
		if (enable) {
			aktg_common_prsv[0] = AKTSP_RET_ORDER_SET;
		}
		pfunc = (void *) (&aktg_common_prsv[0]);
		(*pfunc)();
		break;

	default:
		CheckAssert(FALSE);
	}

	/* アクセス可能の場合は，全領域へのアクセスを確認 */
	if (enable && (check_num != 104)) {
		CheckAssert(FALSE);
	}
}

/*
 *  対象スタックを使用する処理単位からアクセスできるスタック領域へのアクセス
 *  ・対象スタックへの読出し，書込みアクセス
 *  ・引数のstackで対象とするスタックを指定する
 *  ・アクセスできる場合に使用する関数であるので引数のenableは不要
 *  ・1回の呼出しで対象のすべての領域へのアクセスを実行する
 */
void
AktspAccessStackArea(uint8 stack, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data, write_data;
	uint8*			start_addr = NULL;
	uint8*			end_addr = NULL;
#if 0   /* modified by ishi */
	uint8*			ht_hook_stack_addr = AKTSP_NT_HOOK_STACK_ADDRESS;
#else
    /* 非信頼フックのスタックはostack */
	uint8*			ht_hook_stack_addr = AKTSP_OS_STACK_ADDRESS;
#endif
	MemorySizeType	mem_sz;
	AccessType		tsk2acc = AP_NoAccess;
	AccessType		tsk3acc = AP_NoAccess;

	/* 対象スタック領域のポインタを取得 */
	switch (stack) {
	case AK_NT_OSAP1_TASK1:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(0, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		tsk2acc = (AP_Readable | AP_Writable | AP_StackSpace);
		break;
	case AK_NT_OSAP1_TASK2:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(2, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(2, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		break;
	case AK_NT_OSAP2_TASK1:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(1, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(1, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		tsk3acc = (AP_Readable | AP_Writable | AP_StackSpace);
		break;
#if 0
	case AK_NT_OSAP1_HOOK:
		start_addr = &ht_hook_stack_addr[0];
		end_addr = &ht_hook_stack_addr[AKTSP_NTHOOK_STACK_SIZE - 1];
		mem_sz = AKTSP_NTHOOK_STACK_SIZE;
#endif
		break;
	default:
		CheckAssert(FALSE);
	}

	/* システムサービステスト */
	if (service) {
		AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, tsk2acc, tsk3acc, STACK_NO_ACCESS);
	}

	/* リードアクセス(先頭) */
	read_data = *start_addr;

	/* リードアクセス(終端) */
	read_data = *end_addr;

	/* ライトアクセス(先頭) */
	write_data = *start_addr;
	*start_addr = write_data;

	/* ライトアクセス(終端) */
	write_data = *end_addr;
	*end_addr = write_data;
}


/*
 *  対象スタックを使用する処理単位からアクセスできないスタック領域へのアクセス
 *  ・対象スタックへの実行アクセス，スタックを使用する処理単位以外の全処理単位からのアクセスなど
 *  ・引数のstackで対象とするスタックを指定する
 *  ・実行アクセス，ライトアクセスでは，対象領域を書き換えると問題が発生するので，
 *    enableがtrueの場合，事前にデータを保持してテスト後，元に戻す
 *  ・実行アクセスは，対象領域にret命令データを書き込み，実行する
 */
void
AktspInaccessibleStackArea(uint8 stack, boolean enable, uint16 action, boolean service, TaskType tsk1id, TaskType tsk2id, TaskType tsk3id, ISRType isrid)
{
	volatile uint8	read_data;
	uint8			stack_data[64], i;
	uint8			write_data = 0U;
	uint8			check_num = 0U;
	uint8*			start_addr = NULL;
	uint8*			end_addr = NULL;
	uint8*			ht_hook_stack_addr = AKTSP_NT_HOOK_STACK_ADDRESS;
	MemorySizeType	mem_sz;
	AccessType		tsk2acc = AP_NoAccess;
	AccessType		tsk3acc = AP_NoAccess;
	void			(*pfunc)();

	/* アクセス可能の場合は，actionは0以外指定不可 */
	if (enable && (action != 0)) {
		CheckAssert(FALSE);
	}

	/* 対象スタック領域のポインタを取得 */
	switch (stack) {
	case AK_NT_OSAP1_TASK1:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(0, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(0, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		tsk2acc = (AP_Readable | AP_Writable | AP_StackSpace);
		break;
	case AK_NT_OSAP1_TASK2:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(2, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(2, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		break;
	case AK_NT_OSAP2_TASK1:
		start_addr = &AKTSP_MEM_NT_TASK_STACK(1, 0);
		end_addr = &AKTSP_MEM_NT_TASK_STACK(1, AKTSP_TASK_STACK_SIZE - 1);
		mem_sz = AKTSP_TASK_STACK_SIZE;
		tsk3acc = (AP_Readable | AP_Writable | AP_StackSpace);
		break;
#if 0
	case AK_NT_OSAP1_HOOK:
		start_addr = &ht_hook_stack_addr[0];
		end_addr = &ht_hook_stack_addr[AKTSP_NTHOOK_STACK_SIZE - 1];
		mem_sz = AKTSP_NTHOOK_STACK_SIZE;
		break;
#endif
	default:
		CheckAssert(FALSE);
	}

	switch (action) {
	case 0:		/* 実行アクセス */
		if (enable) {
			for (i = 0; i < 64; i++) {
				stack_data[i] = start_addr[i];
				start_addr[i] = 0U;
			}
			start_addr[0] = AKTSP_RET_ORDER_0;
			start_addr[1] = AKTSP_RET_ORDER_1;
			start_addr[2] = AKTSP_RET_ORDER_2;
			start_addr[3] = AKTSP_RET_ORDER_3;
		}
		pfunc = (void*)(start_addr);
		(*pfunc)();
		if (enable) {
			for (i = 0; i < 64; i++) {
				start_addr[i] = stack_data[i];
			}
		}
		IF_NOT_ENABLE_BREAK;

	case 1:		/* リードアクセス(先頭) */
		/* システムサービステスト */
		if (service) {
			AktspCheckMemoryAccess(start_addr, mem_sz, tsk1id, tsk2id, tsk3id, isrid, tsk2acc, tsk3acc, STACK_NO_ACCESS);
		}
		/* メモリアクセステスト */
		read_data = *start_addr;
		IF_NOT_ENABLE_BREAK;

	case 2:		/* リードアクセス(終端) */
		read_data = *end_addr;
		IF_NOT_ENABLE_BREAK;

	case 3:		/* ライトアクセス(先頭) */
		if (enable) {
			write_data = *start_addr;
		}
		*start_addr = write_data;
		IF_NOT_ENABLE_BREAK;

	case 4:		/* ライトアクセス(終端) */
		if (enable) {
			write_data = *end_addr;
		}
		*end_addr = write_data;
		break;

	default:
		CheckAssert(FALSE);
	}

	/* アクセス可能の場合は，全領域へのアクセスを確認 */
	if (enable && (check_num != 4)) {
		CheckAssert(FALSE);
	}
}

