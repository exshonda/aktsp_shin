#include "aktsp_implement_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"

AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_common_bss[AKTSP_NO_SMALL_DATA_SIZE]);
AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_kernel_common_data[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);

AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_common_sbss);
AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_kernel_common_sdata = AKTSP_RET_ORDER_SET);

AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_kernel_common_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");
