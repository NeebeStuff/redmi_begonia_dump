#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Product characteristics
PRODUCT_CHARACTERISTICS := default

# Rootdir
PRODUCT_PACKAGES += \
    install-recovery.sh \
    tp_selftest.sh \
    tp_data_collect.sh \
    mishow.sh \

PRODUCT_PACKAGES += \
    fstab.emmc \
    init.mt6785.rc \
    init.sensor_1_0.rc \
    factory_init.rc \
    init.project.rc \
    init.connectivity.rc \
    factory_init.project.rc \
    multi_init.rc \
    init.mt6785.usb.rc \
    meta_init.modem.rc \
    meta_init.rc \
    init.modem.rc \
    factory_init.connectivity.rc \
    init.aee.rc \
    meta_init.connectivity.rc \
    init.ago.rc \
    meta_init.project.rc \
    miui.factoryreset.rc \
    init.recovery.mt6785.rc \
    init.recovery.hardware.rc \

# Shipping API level
PRODUCT_SHIPPING_API_LEVEL := 28

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/xiaomi/begonia/begonia-vendor.mk)
