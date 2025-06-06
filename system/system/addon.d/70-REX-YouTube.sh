#!/sbin/sh
#
# ADDOND_VERSION=2
#
# /system/addon.d/70-REX-YouTube.sh
# rexyoutube
#

. /tmp/backuptool.functions

# determine parent output fd and ui_print method
FD=1
# update-binary|updater <RECOVERY_API_VERSION> <OUTFD> <ZIPFILE>
OUTFD=$(ps | grep -v 'grep' | grep -oE 'update(.*) 3 [0-9]+' | cut -d" " -f3)
[ -z $OUTFD ] && OUTFD=$(ps -Af | grep -v 'grep' | grep -oE 'update(.*) 3 [0-9]+' | cut -d" " -f3)
# update_engine_sideload --payload=file://<ZIPFILE> --offset=<OFFSET> --headers=<HEADERS> --status_fd=<OUTFD>
[ -z $OUTFD ] && OUTFD=$(ps | grep -v 'grep' | grep -oE 'status_fd=[0-9]+' | cut -d= -f2)
[ -z $OUTFD ] && OUTFD=$(ps -Af | grep -v 'grep' | grep -oE 'status_fd=[0-9]+' | cut -d= -f2)
if [ -z $OUTFD ]; then
  ui_print() { echo $1; }
else
  ui_print() { echo -e "ui_print $1\nui_print" >>"/proc/self/fd/$OUTFD"; }
fi

delete_list() {
cat <<'HEREDOC'
product/app/YouTube/YouTube.apk
product/app/YouTube/lib/arm64/libaffinityconfigurator.so
product/app/YouTube/lib/arm64/libGfxPluginCardboard_only_gles2.so
product/app/YouTube/lib/arm64/libdav1dJNI.so
product/app/YouTube/lib/arm64/libnativecrashdetectorutil.so
product/app/YouTube/lib/arm64/libdrishti_jni_native.so
product/app/YouTube/lib/arm64/libavif_android.so
product/app/YouTube/lib/arm64/libannexbtoavcc.so
product/app/YouTube/lib/arm64/libvpxV2JNI.so
product/app/YouTube/lib/arm64/libgvr_audio.so
product/app/YouTube/lib/arm64/libenvoy_jni.so
product/app/YouTube/lib/arm64/libgoogle3.so
product/app/YouTube/lib/arm64/libnative_crash_handler_jni.so
product/app/YouTube/lib/arm64/libgav1JNI.so
product/app/YouTube/lib/arm64/libframesequence.so
product/app/YouTube/lib/arm64/libopusV2JNI.so
product/app/YouTube/lib/arm64/libcronet.127.0.6510.5.so
product/app/YouTube/lib/arm64/libfilterframework_jni.so
product/app/YouTube/lib/arm64/libelements.so
product/app/YouTube/lib/arm64/libelements2.so
product/app/YouTube/lib/arm64/libvpx.so
product/app/YouTube/lib/arm64/libjingle_peerconnection_so.so
product/app/YouTube/lib/arm64/libcronet.131.0.6738.0.so
product/app/YouTube/lib/arm64/libcronet.122.0.6238.4.so
product/app/YouTube/lib/arm64/libcardboard_sdk_jni.so
product/app/YouTube/lib/arm64/libnative_deps.so
product/app/YouTube/lib/arm64/libjni_native.so
product/app/YouTube/lib/arm64/libimage_processing_util_jni.so
product/app/YouTube/lib/arm64/libfaceviewer_jni_native.so
product/app/YouTube/lib/arm64/libcronet.126.0.6423.0.so
HEREDOC
}
add_list() {
cat <<'HEREDOC'
product/app/YouTube/YouTube.apk
product/app/YouTube/lib/arm64/libdrishti_jni_native.so
product/app/YouTube/lib/arm64/libvpxV2JNI.so
product/app/YouTube/lib/arm64/libfaceviewer_jni_native.so
product/app/YouTube/lib/arm64/libcardboard_sdk_jni.so
product/app/YouTube/lib/arm64/libaffinityconfigurator.so
product/app/YouTube/lib/arm64/libelements.so
product/app/YouTube/lib/arm64/libjingle_peerconnection_so.so
product/app/YouTube/lib/arm64/libGfxPluginCardboard_only_gles2.so
product/app/YouTube/lib/arm64/libgvr_audio.so
product/app/YouTube/lib/arm64/libgoogle3.so
product/app/YouTube/lib/arm64/libenvoy_jni.so
product/app/YouTube/lib/arm64/libopusV2JNI.so
product/app/YouTube/lib/arm64/libannexbtoavcc.so
product/app/YouTube/lib/arm64/libimage_processing_util_jni.so
product/app/YouTube/lib/arm64/libframesequence.so
product/app/YouTube/lib/arm64/libvpx.so
product/app/YouTube/lib/arm64/libgav1JNI.so
product/app/YouTube/lib/arm64/libfilterframework_jni.so
product/app/YouTube/lib/arm64/libcronet.131.0.6738.0.so
product/app/YouTube/lib/arm64/libnativecrashdetectorutil.so
product/app/YouTube/lib/arm64/libdav1dJNI.so
product/app/YouTube/lib/arm64/libelements2.so
product/app/YouTube/lib/arm64/libavif_android.so
product/app/YouTube/lib/arm64/libnative_crash_handler_jni.so
product/app/YouTube/lib/arm64/libnative_deps.so
HEREDOC
}

case $1 in
  backup)
    ui_print '- Backing up rexyoutube'
    add_list | while read FILE; do
      backup_file "$S/$FILE"
    done
    ;;
  restore)
    ui_print '- Restoring rexyoutube'
    delete_list | while read FILE; do
      rm -f "$S/$FILE"
    done
    add_list | while read FILE; do
      [ -f "$C/$S/$FILE" ] && restore_file "$S/$FILE"
    done
    ;;
esac
