#include "aktsp_implement_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"

AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_bss[AKTSP_NO_SMALL_DATA_SIZE]);
AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_data[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);
const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap1_rodata[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);

void
AktspNonTrustedOsap1Func(void)
{
	return;
}

AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_sbss);
AKTSP_DEFINE_ALIGNED_VAR(uint32, aktg_nt_osap1_sdata = AKTSP_RET_ORDER_SET);
AKTSP_DEFINE_ALIGNED_VAR_SEC(uint32, aktg_nt_osap1_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");
