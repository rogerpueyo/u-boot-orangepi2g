#ifndef __CONFIG_H
#define __CONFIG_H

#include <configs/rda_config_defaults.h>

/*
 * SoC Configuration
 */
#define CONFIG_MACH_RDA8810
/* #define CONFIG_RDA_FPGA */

/*
 * Flash & Environment
 */
/* #define CONFIG_NAND_RDA_DMA */
#define CONFIG_NAND_RDA_V1		/* V1 for rda8810, rda8850 */
#define CONFIG_SYS_NAND_MAX_CHIPS	1

// Enable RDA signed bootloader:
#define CONFIG_SIGNATURE_CHECK_IMAGE

#ifdef _TGT_AP_HW_TEST_ENABLE
/* force to run a fast hardware test when pdl2 is running */
#define CONFIG_PDL_FORCE_HW_TEST
/* force to run a full/slow hardware test when pdl2 is running */
#define CONFIG_PDL_FORCE_HW_TEST_FULL

/* test list */
#ifdef _TGT_AP_VPU_TEST_ENABLE
#define CONFIG_VPU_TEST
#define CONFIG_VPU_STA_TEST
#endif

#ifdef _TGT_AP_VPU_MD5_TEST_ENABLE
#ifndef CONFIG_VPU_TEST
#define CONFIG_VPU_TEST
#endif
#define CONFIG_VPU_MD5_TEST
#endif

#ifdef _TGT_AP_CPU_TEST_ENABLE
#define CONFIG_CPU_TEST
#endif

#endif /*_TGT_AP_HW_TEST_ENABLE*/

#define CONFIG_SYS_CACHELINE_SIZE		32

#endif /* __CONFIG_H */
