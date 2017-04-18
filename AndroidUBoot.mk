

include u-boot/rda-signing.mk

$(warning BOARD_FLASH_BLOCK_SIZE $(BOARD_FLASH_BLOCK_SIZE))
$(warning ANDROID_BUILD_TOP $(ANDROID_BUILD_TOP))
LOCAL_TOOLCHAIN := arm-eabi-
UBOOT_OUT := $(TARGET_OUT_INTERMEDIATES)/u-boot
UBOOT_IMG := $(UBOOT_OUT)/u-boot.img
UBOOT_CONFIG := $(UBOOT_OUT)/include/config.h

PDL_OUT := $(TARGET_OUT_INTERMEDIATES)/pdl
PDL_DEST  := $(PRODUCT_OUT)/pdl1.bin $(PRODUCT_OUT)/pdl2.bin
PDL_BUILD := $(PDL_OUT)/pdl1$(RDASIGN).bin $(PDL_OUT)/pdl2$(RDASIGN).bin
PDL_UBOOT_BIN := $(PDL_OUT)/u-boot.bin
PDL_CONFIG := $(PDL_OUT)/include/config.h

BOOTLOADER_BUILD := $(UBOOT_OUT)/u-boot$(RDASIGN).rda

#build for bootloader, and it come from u-boot.rda
#and at same time , we build PDL too if pdl1.bin and pdl2.bin
#is outdate. pdl1 and pdl2 use the same u-boot project but with
#with a special build argument pdl=1

$(warning RDA_TARGET_DEVICE_DIR $(RDA_TARGET_DEVICE_DIR))

.PHONY: $(INSTALLED_UBOOT_TARGET) $(BOOTLOADER_BUILD) $(UBOOT_IMG)
.PHONY: pdl_build $(PDL_UBOOT_BIN)

ifeq "$(CLEAN)" "1"
$(INSTALLED_UBOOT_TARGET) :
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(UBOOT_OUT) distclean
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(PDL_OUT) distclean
else
$(INSTALLED_UBOOT_TARGET) : $(BOOTLOADER_BUILD) pdl_build
	@echo "Install booloader target"
	@cp $(BOOTLOADER_BUILD) $(INSTALLED_UBOOT_TARGET)
	@echo "Install bootloader target done"
endif

$(UBOOT_OUT):
	@echo "Start U-Boot build"

$(UBOOT_CONFIG): | $(VENDOR_SESSION_KEY)
$(UBOOT_CONFIG): u-boot/include/configs/$(addsuffix .h,$(UBOOT_DEFCONFIG))
	@mkdir -p $(UBOOT_OUT)
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(UBOOT_OUT) distclean
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(UBOOT_OUT) \
		BUILD_DISPLAY_ID="$(BUILD_DISPLAY_ID)" \
        UBOOT_VARIANT=$(TARGET_BUILD_VARIANT) $(UBOOT_DEFCONFIG)_config

$(UBOOT_IMG) : $(UBOOT_CONFIG)
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) \
	BUILD_DISPLAY_ID="$(BUILD_DISPLAY_ID)" \
	 O=../$(UBOOT_OUT) UBOOT_VARIANT=$(TARGET_BUILD_VARIANT) \
	REBOOT_WHEN_CRASH=$(REBOOT_WHEN_CRASH)

$(BOOTLOADER_BUILD) : $(UBOOT_IMG)

#build for PDL
$(PDL_UBOOT_BIN) : | $(UBOOT_IMG)
$(PDL_UBOOT_BIN) : $(PDL_CONFIG)
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(PDL_OUT) \
		BUILD_DISPLAY_ID="$(BUILD_DISPLAY_ID)" \
        UBOOT_VARIANT=$(TARGET_BUILD_VARIANT) pdl=1 PDL

$(PDL_CONFIG) : u-boot/include/configs/$(addsuffix .h,$(UBOOT_DEFCONFIG))
	@mkdir -p $(PDL_OUT)
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(PDL_OUT) distclean
	$(MAKE) -C u-boot CROSS_COMPILE=$(LOCAL_TOOLCHAIN) O=../$(PDL_OUT) \
		BUILD_DISPLAY_ID="$(BUILD_DISPLAY_ID)" \
        UBOOT_VARIANT=$(TARGET_BUILD_VARIANT) pdl=1 $(UBOOT_DEFCONFIG)_config

$(PDL_BUILD): $(PDL_UBOOT_BIN)
	@echo "Build $(notdir $@)"

$(PRODUCT_OUT)/pdl%.bin: $(PDL_OUT)/pdl%$(RDASIGN).bin
	@echo "Install $(notdir $@)"
	@cp -fp $< $@

pdl_build: $(PDL_DEST)
	@echo "Installed PDL target"
