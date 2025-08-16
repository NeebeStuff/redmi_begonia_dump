#!/bin/bash

cat recovery.img.* 2>/dev/null >> recovery.img
rm -f recovery.img.* 2>/dev/null
cat vendor/etc/camera/apu_miai_fragment.bin.* 2>/dev/null >> vendor/etc/camera/apu_miai_fragment.bin
rm -f vendor/etc/camera/apu_miai_fragment.bin.* 2>/dev/null
cat boot.img.* 2>/dev/null >> boot.img
rm -f boot.img.* 2>/dev/null
cat system/system/app/MIUIMusic/oat/arm64/base.odex.* 2>/dev/null >> system/system/app/MIUIMusic/oat/arm64/base.odex
rm -f system/system/app/MIUIMusic/oat/arm64/base.odex.* 2>/dev/null
cat system/system/priv-app/SecurityCenter/SecurityCenter.apk.* 2>/dev/null >> system/system/priv-app/SecurityCenter/SecurityCenter.apk
rm -f system/system/priv-app/SecurityCenter/SecurityCenter.apk.* 2>/dev/null
cat system/system/priv-app/MiuiCamera/MiuiCamera.apk.* 2>/dev/null >> system/system/priv-app/MiuiCamera/MiuiCamera.apk
rm -f system/system/priv-app/MiuiCamera/MiuiCamera.apk.* 2>/dev/null
cat system/system/product/app/WebViewGoogle/WebViewGoogle.apk.* 2>/dev/null >> system/system/product/app/WebViewGoogle/WebViewGoogle.apk
rm -f system/system/product/app/WebViewGoogle/WebViewGoogle.apk.* 2>/dev/null
cat system/system/product/app/LatinImeGoogle/LatinImeGoogle.apk.* 2>/dev/null >> system/system/product/app/LatinImeGoogle/LatinImeGoogle.apk
rm -f system/system/product/app/LatinImeGoogle/LatinImeGoogle.apk.* 2>/dev/null
cat system/system/product/priv-app/GmsCore/GmsCore.apk.* 2>/dev/null >> system/system/product/priv-app/GmsCore/GmsCore.apk
rm -f system/system/product/priv-app/GmsCore/GmsCore.apk.* 2>/dev/null
cat system/system/system_ext/priv-app/Settings/Settings.apk.* 2>/dev/null >> system/system/system_ext/priv-app/Settings/Settings.apk
rm -f system/system/system_ext/priv-app/Settings/Settings.apk.* 2>/dev/null
