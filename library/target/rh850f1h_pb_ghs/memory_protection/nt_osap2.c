#include "aktsp_implement_lib.h"
#include "aktsp_implement_include.h"
#include "aktsp_target_include.h"

AKTSP_DEFINE_ALIGNED_VAR(volatile uint8, aktg_nt_osap2_bss[AKTSP_NO_SMALL_DATA_SIZE]);
AKTSP_DEFINE_ALIGNED_VAR(volatile uint8, aktg_nt_osap2_data[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);
const AKTSP_DEFINE_ALIGNED_VAR(uint8, aktg_nt_osap2_rodata[AKTSP_NO_SMALL_DATA_SIZE] = AKTSP_RET_ORDER_ARRAY);

void
AktspNonTrustedOsap2Func(void)
{
	return;
}

#pragma ghs startsda
AKTSP_DEFINE_ALIGNED_VAR(volatile uint32, aktg_nt_osap2_sbss);
AKTSP_DEFINE_ALIGNED_VAR(volatile uint32, aktg_nt_osap2_sdata = AKTSP_RET_ORDER_SET);
AKTSP_DEFINE_ALIGNED_VAR(const uint32, aktg_nt_osap2_rosdata = AKTSP_RET_ORDER_SET);
#pragma ghs endsda
AKTSP_DEFINE_ALIGNED_VAR_SEC(volatile uint32, aktg_nt_osap2_prsv[AKTSP_NO_SMALL_DATA_SIZE], ".prsv");
