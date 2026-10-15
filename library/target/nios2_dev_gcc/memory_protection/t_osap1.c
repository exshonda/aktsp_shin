#include "aktsp_implement_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"

AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_bss[AKTSP_NO_SMALL_DATA_SIZE]);
AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_data[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);
const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_rodata[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);

void
AktspKernelFunc(void)
{
	return;
}

AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_sbss);
AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_sdata = AKTSP_RET_ORDER_SET);
