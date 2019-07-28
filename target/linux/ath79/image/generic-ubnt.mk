DEVICE_VARS += UBNT_BOARD UBNT_CHIP UBNT_TYPE UBNT_VERSION UBNT_REVISION

# On M (XW) devices the U-Boot as of version 1.1.4-s1039 doesn't like
# VERSION_DIST being on the place of major(?) version number, so we need to
# use some number.
UBNT_REVISION := $(VERSION_DIST)-$(REVISION)

# mkubntimage is using the kernel image direct
# routerboard creates partitions out of the ubnt header
define Build/mkubntimage
	-$(STAGING_DIR_HOST)/bin/mkfwimage \
		-B $(UBNT_BOARD) -v $(UBNT_TYPE).$(UBNT_CHIP).v6.0.0-$(VERSION_DIST)-$(REVISION) \
		-k $(IMAGE_KERNEL) \
		-r $@ \
		-o $@
endef

# all UBNT XM/WA devices expect the kernel image to have 1024k while flash, when
# booting the image, the size doesn't matter.
define Build/mkubntimage-split
	-[ -f $@ ] && ( \
	dd if=$@ of=$@.old1 bs=1024k count=1; \
	dd if=$@ of=$@.old2 bs=1024k skip=1; \
	$(STAGING_DIR_HOST)/bin/mkfwimage \
		-B $(UBNT_BOARD) -v $(UBNT_TYPE).$(UBNT_CHIP).v$(UBNT_VERSION)-$(UBNT_REVISION) \
		-k $@.old1 \
		-r $@.old2 \
		-o $@; \
	rm $@.old1 $@.old2 )
endef

# UBNT_BOARD e.g. one of (XS2, XS5, RS, XM)
# UBNT_TYPE e.g. one of (BZ, XM, XW)
# UBNT_CHIP e.g. one of (ar7240, ar933x, ar934x)
# UBNT_VERSION e.g. one of (6.0.0, 8.5.0)
define Device/ubnt
  DEVICE_VENDOR := Ubiquiti
  DEVICE_PACKAGES := kmod-usb-core kmod-usb2
  IMAGE_SIZE := 7552k
  UBNT_BOARD := XM
  UBNT_VERSION := 6.0.0
  IMAGES += factory.bin
  IMAGE/factory.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | \
	append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE) | mkubntimage-split
endef

define Device/ubnt-xm
  $(Device/ubnt)
  DEVICE_PACKAGES += kmod-usb-ohci rssileds
  UBNT_TYPE := XM
  UBNT_CHIP := ar7240
  ATH_SOC := ar7241
  KERNEL := kernel-bin | append-dtb | relocate-kernel | lzma | uImage lzma
endef

define Device/ubnt-bz
  $(Device/ubnt)
  UBNT_TYPE := BZ
  UBNT_CHIP := ar7240
  ATH_SOC := ar7241
endef

define Device/ubnt-wa
  $(Device/ubnt)
  UBNT_TYPE := WA
  UBNT_CHIP := ar934x
  UBNT_BOARD := WA
  UBNT_VERSION := 8.5.0
  ATH_SOC := ar9342
endef

define Device/ubnt-xw
  $(Device/ubnt)
  UBNT_TYPE := XW
  UBNT_CHIP := ar934x
  UBNT_BOARD := XM
  UBNT_VERSION := 6.0.4
  UBNT_REVISION := 42.$(UBNT_REVISION)
  ATH_SOC := ar9342
endef

define Device/ubnt_airrouter
  $(Device/ubnt-xm)
  DEVICE_MODEL := AirRouter
  SUPPORTED_DEVICES += airrouter
endef
TARGET_DEVICES += ubnt_airrouter

define Device/ubnt_bullet-m
  $(Device/ubnt-xm)
  DEVICE_MODEL := Bullet-M
  SUPPORTED_DEVICES += bullet-m
endef
TARGET_DEVICES += ubnt_bullet-m

define Device/ubnt_bullet-m-xw
  $(Device/ubnt-xw)
  DEVICE_MODEL := Bullet-M
  DEVICE_VARIANT := XW
  SUPPORTED_DEVICES += bullet-m-xw
endef
TARGET_DEVICES += ubnt_bullet-m-xw

define Device/ubnt_rocket-m
  $(Device/ubnt-xm)
  DEVICE_MODEL := Rocket-M
  SUPPORTED_DEVICES += rocket-m
endef
TARGET_DEVICES += ubnt_rocket-m

define Device/ubnt_nanostation-m
  $(Device/ubnt-xm)
  DEVICE_MODEL := Nanostation M
  SUPPORTED_DEVICES += nano-m
endef
TARGET_DEVICES += ubnt_nanostation-m

define Device/ubnt_nanostation-m-xw
  $(Device/ubnt-xw)
  DEVICE_MODEL := Nanostation M
  DEVICE_VARIANT := XW
  SUPPORTED_DEVICES += nano-m-xw
endef
TARGET_DEVICES += ubnt_nanostation-m-xw

define Device/ubnt_lap-120
  $(Device/ubnt-wa)
  DEVICE_MODEL := LiteAP ac
  DEVICE_VARIANT := LAP-120
  DEVICE_PACKAGES += kmod-ath10k-ct ath10k-firmware-qca988x-ct
  IMAGE_SIZE := 15744k
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | mkubntimage-split
endef
TARGET_DEVICES += ubnt_lap-120

define Device/ubnt_nanobeam-ac
  $(Device/ubnt-wa)
  DEVICE_MODEL := NanoBeam AC
  DEVICE_PACKAGES += kmod-ath10k-ct ath10k-firmware-qca988x-ct
  IMAGE_SIZE := 15744k
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | mkubntimage-split
endef
TARGET_DEVICES += ubnt_nanobeam-ac

define Device/ubnt_nanostation-ac
  $(Device/ubnt-wa)
  DEVICE_MODEL := Nanostation AC
  DEVICE_PACKAGES += kmod-ath10k-ct ath10k-firmware-qca988x-ct
  IMAGE_SIZE := 15744k
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | mkubntimage-split
endef
TARGET_DEVICES += ubnt_nanostation-ac

define Device/ubnt_nanostation-ac-loco
  $(Device/ubnt-wa)
  DEVICE_MODEL := Nanostation AC loco
  DEVICE_PACKAGES += kmod-ath10k-ct ath10k-firmware-qca988x-ct
  IMAGE_SIZE := 15744k
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | mkubntimage-split
endef
TARGET_DEVICES += ubnt_nanostation-ac-loco

define Device/ubnt_unifi
  $(Device/ubnt-bz)
  DEVICE_MODEL := UniFi
  SUPPORTED_DEVICES += unifi
endef
TARGET_DEVICES += ubnt_unifi

define Device/ubnt_unifiac
  DEVICE_VENDOR := Ubiquiti
  ATH_SOC := qca9563
  IMAGE_SIZE := 7744k
  DEVICE_PACKAGES := kmod-ath10k-ct ath10k-firmware-qca988x-ct
endef

define Device/ubnt_unifiac-lite
  $(Device/ubnt_unifiac)
  DEVICE_MODEL := UniFi AC-Lite
  SUPPORTED_DEVICES += ubnt-unifiac-lite
endef
TARGET_DEVICES += ubnt_unifiac-lite

define Device/ubnt_unifiac-mesh
  $(Device/ubnt_unifiac)
  DEVICE_MODEL := UniFi AC-Mesh
  SUPPORTED_DEVICES += ubnt-unifiac-mesh
endef
TARGET_DEVICES += ubnt_unifiac-mesh

define Device/ubnt_unifiac-mesh-pro
  $(Device/ubnt_unifiac)
  DEVICE_MODEL := UniFi AC-Mesh Pro
  SUPPORTED_DEVICES += ubnt-unifiac-mesh-pro
endef
TARGET_DEVICES += ubnt_unifiac-mesh-pro

define Device/ubnt_unifiac-pro
  $(Device/ubnt_unifiac)
  DEVICE_MODEL := UniFi AC-Pro
  DEVICE_PACKAGES += kmod-usb-core kmod-usb2
  SUPPORTED_DEVICES += ubnt-unifiac-pro
endef
TARGET_DEVICES += ubnt_unifiac-pro

define Device/ubnt_routerstation_common
  DEVICE_PACKAGES := -kmod-ath9k -wpad-mini -uboot-envtools kmod-usb-ohci kmod-usb2 fconfig
  DEVICE_VENDOR := Ubiquiti
  ATH_SOC := ar7161
  IMAGE_SIZE := 16128k
  IMAGES += factory.bin
  IMAGE/factory.bin := append-rootfs | pad-rootfs | mkubntimage | check-size $$$$(IMAGE_SIZE)
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | combined-image | check-size $$$$(IMAGE_SIZE)
#  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE) | sysupgrade-tar rootfs=$$$$@ | append-metadata
  KERNEL := kernel-bin | append-dtb | lzma | pad-to $$(BLOCKSIZE)
  KERNEL_INITRAMFS := kernel-bin | append-dtb
endef

define Device/ubnt_routerstation
  $(Device/ubnt_routerstation_common)
  DEVICE_MODEL := RouterStation
  UBNT_BOARD := RS
  UBNT_TYPE := RSx
  UBNT_CHIP := ar7100
  DEVICE_PACKAGES += -swconfig
endef
TARGET_DEVICES += ubnt_routerstation

define Device/ubnt_routerstation-pro
  $(Device/ubnt_routerstation_common)
  DEVICE_MODEL := RouterStation Pro
  UBNT_BOARD := RSPRO
  UBNT_TYPE := RSPRO
  UBNT_CHIP := ar7100pro
endef
TARGET_DEVICES += ubnt_routerstation-pro

define Device/ubnt_acb-isp
  $(Device/ubnt)
  ATH_SOC := qca9533
  IMAGE_SIZE := 15744k
  DEVICE_MODEL := airCube ISP
  UBNT_BOARD := ACB-ISP
  UBNT_TYPE := ACB
  UBNT_CHIP := qca9533
  IMAGES := sysupgrade.bin
endef
TARGET_DEVICES += ubnt_acb-isp
