#!/system/bin/sh

# clear launcher data
pm clear com.android.launcher3

# uninstall orphaned google apps
packages=(
  com.google.android.accessibility.soundamplifier
  com.google.android.apps.carrier.carrierwifi
  com.google.android.apps.carrier.log
  com.google.android.apps.cbrsnetworkmonitor
  com.google.android.apps.gcs
  com.google.android.apps.internal.betterbug
  com.google.android.apps.nexuslauncher
  com.google.android.apps.nexuslauncher.custom.overlay
  com.google.android.apps.safetyhub
  com.google.android.apps.security.securityhub
  com.google.android.apps.wallpaper
  com.google.android.apps.wallpaper.pixel
  com.google.android.apps.wearables.maestro.companion
  com.google.android.apps.work.clouddpc
  com.google.android.carrier
  com.google.android.carrierlocation
  com.google.android.carriersetup
  com.google.android.documentsui.theme.pixel
  com.google.android.ims
  com.google.android.odad
  com.google.android.overlay.googlewebview
  com.google.android.packageinstaller
  com.google.android.pixel.setupwizard.evolutionx
  com.google.android.storagemanager
  com.google.android.syncadapters.contacts
  com.google.android.tetheringentitlement
  com.google.android.wfcactivation
  com.google.ar.core
  com.google.audio.hearing.visualization.accessibility.scribe
  com.google.pixel.dynamicwallpapers
  com.google.pixel.livewallpaper
)
for package in ${packages[*]}; do
  pm uninstall `pm list packages -3 -U | grep -F $package\  | cut -d': ' -f2`
done

# uninstall system apps updates except google apps updates
filter='
  -e ^com.google.
  -e ^com.android.chrome$
  -e ^com.android.vending$
  -e ^com.miui.videoplayer$
'
packages=`pm list packages -s -f | grep -F /data/app/ | cut -d'/' -f6 | cut -d'=' -f2`
packages=`echo "${packages[*]}" | grep -v $filter`
for package in ${packages[*]}; do
  pm uninstall-system-updates $package
done

# schedule apps cache cleanup & reboot
setprop sys.user_present ""
setprop persist.storage.apps.trim_caches 1
rm /data/user_de/0/com.android.systemui/shared_prefs/status_bar.xml
sync
reboot
