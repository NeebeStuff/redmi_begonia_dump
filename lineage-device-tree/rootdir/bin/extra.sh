#!/system/bin/sh
sleep 10
apply() {
    local val="$1"
    local file="$2"
    [ -f "$file" ] || return
    chmod 644 "$file"
    echo "$val" > "$file"
    chmod 444 "$file"
}

# PPM Policies 
for i in 2 3 4 5 7 8 9; do
  apply "$i 0" /proc/ppm/policy_status
done

for i in 0 1; do
  apply "$i 1" /proc/ppm/policy_status
done

# Cpu rate
apply 8000000 /proc/perfmgr/boost_ctrl/eas_ctrl/debug_schedplus_down_throttle
apply 1000000 /proc/perfmgr/boost_ctrl/eas_ctrl/debug_schedplus_up_throttle

# Schedule
for device in mmcblk0 sda sdb sdc; do
    apply "deadline" /sys/block/$device/queue/scheduler
    apply 0 /sys/block/$device/queue/add_random
    apply 0 /sys/block/$device/queue/iostats
    apply 0 /sys/block/$device/queue/rotational
    apply 2 /sys/block/$device/queue/nomerges
    apply 2 /sys/block/$device/queue/rq_affinity
    apply 128 /sys/block/$device/queue/nr_requests
    apply 128 /sys/block/$device/queue/read_ahead_kb
done

# Power level
apply 0 /sys/devices/system/cpu/eas/enable
apply 3 /proc/cpufreq/cpufreq_power_mode
apply 1 /proc/cpufreq/cpufreq_sched_disable
apply 1 /proc/cpufreq/cpufreq_imax_enable
apply 0 /proc/cpufreq/cpufreq_imax_thermal_protect
apply 1 /proc/cpufreq/cpufreq_cci_mode
apply 1 /sys/kernel/fpsgo/fbt/boost_ta
apply 1 /proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_ext_launch_mon

# GED
apply 1 /sys/module/ged/parameters/gx_game_mode
apply 1 /sys/module/ged/parameters/cpu_boost_policy
apply 1 /sys/module/ged/parameters/boost_extra
apply 16666667 /sys/module/ged/parameters/target_t_cpu_remained
apply 1 /sys/module/ged/parameters/ged_boost_enable
apply 1 /sys/module/ged/parameters/gx_boost_on
apply 1 /sys/module/ged/parameters/ged_smart_boost

apply 1 /sys/kernel/fpsgo/fbt/split_window
apply 1 /sys/kernel/fpsgo/fbt/fpsgo_force_on
apply 1 /sys/kernel/fpsgo/fbt/fpsgo_notify_sf_fps

# UI & Animasi
settings put global animator_duration_scale 0.56
settings put global transition_animation_scale 0.56
settings put global window_animation_scale 0.56

# Scroll & Input 
settings put system view_scroll_friction 2
settings put system pointer_speed 5
settings put system touch_slop 2
settings put secure long_press_timeout 150
settings put secure tap_timeout 50
settings put secure key_repeat_delay 100

### Fast Charging ###
BOOST_NODE="/sys/kernel/fast_charge/force_fast_charge"
[ -e "$BOOST_NODE" ] && echo 1 > "$BOOST_NODE"

### Ios emoji ###
mount --bind /system/fonts/NotoColorEmojiCustom.ttf /system/fonts/NotoColorEmoji.ttf

### Fix buffer gcam ###
stop camerahalserver
mount --bind /system/lib64/libmtkcam_3rdparty.customer.so /vendor/lib64/libmtkcam_3rdparty.customer.so
mount --bind /system/lib64/libmtkcam_featurepolicy.so /vendor/lib64/libmtkcam_featurepolicy.so
start camerahalserver

# SurfaceFlinger aktif
until [ "$(getprop sys.boot_completed)" = "1" ] && dumpsys SurfaceFlinger | grep -q "refresh-rate"; do
    sleep 5
done

# Ambil refresh rate aktif
REFRESH_RATE=$(dumpsys SurfaceFlinger | grep -m1 "refresh-rate" | awk '{printf "%.0f", $3}')
[ -z "$REFRESH_RATE" ] && REFRESH_RATE=60

# Hitung durasi frame (dalam nanodetik)
FRAME_DURATION_NS=$(awk "BEGIN {printf \"%.0f\", (1 / $REFRESH_RATE) * 1000000000}")
EARLY_OFFSET=$((FRAME_DURATION_NS * 35 / 100))
LATE_OFFSET=$((FRAME_DURATION_NS * 70 / 100))
HALF_OFFSET=$((FRAME_DURATION_NS / 2))
THRESHOLD_OFFSET=$((FRAME_DURATION_NS * 85 / 100))
REGION_DURATION=$((FRAME_DURATION_NS * 3 / 10))
HWC_DURATION=$((FRAME_DURATION_NS * 95 / 100))

# Set SurfaceFlinger props
setprop debug.sf.use_phase_offsets_as_durations 1
setprop debug.sf.enable_cached_set_render_scheduling true
setprop debug.sf.hwc.min.duration $HWC_DURATION
setprop debug.sf.region_sampling_duration_ns $REGION_DURATION
setprop debug.sf.cached_set_render_duration_ns $HALF_OFFSET
setprop debug.sf.region_sampling_period_ns $REGION_DURATION
setprop debug.sf.phase_offset_threshold_for_next_vsync_ns $THRESHOLD_OFFSET
setprop debug.sf.region_sampling_timer_timeout_ns $REGION_DURATION

# Early phase offset
for PROP in \
    debug.sf.early.app.duration \
    debug.sf.earlyGl.app.duration \
    debug.sf.early.sf.duration \
    debug.sf.earlyGl.sf.duration \
    debug.sf.early_app_phase_offset_ns \
    debug.sf.early_gl_app_phase_offset_ns \
    debug.sf.early_gl_phase_offset_ns \
    debug.sf.early_phase_offset_ns \
    debug.sf.high_fps_early_app_phase_offset_ns \
    debug.sf.high_fps_early_gl_app_phase_offset_ns \
    debug.sf.high_fps_early_phase_offset_ns \
    debug.sf.high_fps_early_gl_phase_offset_ns
do
    setprop $PROP $EARLY_OFFSET
done

# Late phase offset
setprop debug.sf.high_fps_late_app_phase_offset_ns $LATE_OFFSET
setprop debug.sf.high_fps_late_sf_phase_offset_ns $LATE_OFFSET
setprop debug.sf.late.app.duration $LATE_OFFSET
setprop debug.sf.late.sf.duration $LATE_OFFSET

# Gunakan SkiaGL sebagai renderer
setprop debug.hwui.renderer skiagl
setprop debug.renderengine.backend skiagl

# Nonaktifkan Vulkan agar fokus ke skiagl
setprop debug.hwui.use_vulkan false

# Tweak sinkronisasi dan VSYNC
setprop debug.hwui.disable_vsync true
setprop debug.sf.disable_backpressure true
setprop debug.sf.enable_gl_backpressure false
setprop debug.sf.latch_unsignaled 1
setprop debug.sf.predict_hwc_composition_strategy 0

# Smooth GPU + Rendering cache
setprop ro.hwui.texture_cache_size 144
setprop ro.hwui.layer_cache_size 64
setprop ro.hwui.path_cache_size 48
setprop ro.hwui.r_buffer_cache_size 24
setprop ro.hwui.gradient_cache_size 8
setprop ro.hwui.drop_shadow_cache_size 12
setprop ro.hwui.text_small_cache_width 1024
setprop ro.hwui.text_small_cache_height 1024
setprop ro.hwui.text_large_cache_width 2048
setprop ro.hwui.text_large_cache_height 2048

# Direct render & boost
setprop debug.hwui.direct_render true
setprop debug.hwui.skip_empty_frames true

# Hentikan service perf_init jika sedang jalan
[ "$(getprop init.svc.perf_init)" = "running" ] && stop perf_init
# Tambahkan ke boot script Magisk (service.d)
[ "$(getprop init.svc.qadaemon)" = "running" ] && stop qadaemon
[ "$(getprop init.svc.mqsasd)" = "running" ] && stop mqsasd
[ "$(getprop init.svc.miuibooster)" = "running" ] && stop miuibooster

# Cegah re-run jika dipanggil ulang
chmod -x /system/xbin/system_perf_init 
chmod -x /system/xbin/qadaemon
chmod -x /system/xbin/miuibooster

# Audio Policy 
setprop persist.vendor.audio.fluence.speaker true
setprop persist.audio.fluence.speaker true

# Top boost
TOP_APP=$(dumpsys window windows | grep mCurrentFocus | cut -d ' ' -f 8 | cut -d '/' -f 1)
if echo "$TOP_APP" | grep -qiE "pubg|mlbb|genshin|freefire"; then
    # Aktifkan Boost Mode
    echo 1 > /sys/module/ged/parameters/gx_game_mode
    echo 1 > /sys/kernel/fpsgo/fbt/boost_ta
    setprop persist.gaming.mode 1
else
    setprop persist.gaming.mode 0
fi

# Thermal
cp /bin/sh /vendor/bin/hw/android.hardware.thermal@2.0-service.mtk
chmod 755 /vendor/bin/hw/android.hardware.thermal@2.0-service.mtk

# Audio Gaming Mode (force speaker & disable effect)
setprop ro.audio.silent 0
setprop persist.audio.lowlatency.support 1
setprop persist.vendor.audio.fluence.voicecall false
setprop persist.vendor.audio.fluence.speaker false
setprop persist.vendor.audio.fluence.voicerec false
setprop persist.vendor.audio.fluence.tmic.enabled false
setprop vendor.audio.offload.buffer.size.kb 64
setprop vendor.audio.tunnel.encode 0

## Opt Net
# Net Core Buffers
apply 4096 /proc/sys/net/core/netdev_max_backlog
apply 262144 /proc/sys/net/core/rmem_default
apply 524288 /proc/sys/net/core/rmem_max
apply 262144 /proc/sys/net/core/wmem_default
apply 524288 /proc/sys/net/core/wmem_max
apply 4096 /proc/sys/net/core/somaxconn
apply 204800 /proc/sys/net/core/optmem_max

# TCP Tweaks
apply 0 /proc/sys/net/ipv4/tcp_slow_start_after_idle
apply 1 /proc/sys/net/ipv4/tcp_low_latency
apply 1 /proc/sys/net/ipv4/tcp_timestamps
apply 1 /proc/sys/net/ipv4/tcp_sack
apply 1 /proc/sys/net/ipv4/tcp_fack
apply 1 /proc/sys/net/ipv4/tcp_window_scaling
apply 1 /proc/sys/net/ipv4/tcp_moderate_rcvbuf
apply 0 /proc/sys/net/ipv4/tcp_no_metrics_save
apply 1 /proc/sys/net/ipv4/tcp_ecn
apply 1 /proc/sys/net/ipv4/tcp_adv_win_scale

# Ganti TCP congestion control ke algo terbaik yg tersedia
PREFERRED="bbr2 bbr westwood cubic reno"
AVAIL=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control)
for algo in $PREFERRED; do
    echo "$AVAIL" | grep -qw "$algo" && apply "$algo" /proc/sys/net/ipv4/tcp_congestion_control && break
done

# Timeout & Port Range
apply 3 /proc/sys/net/ipv4/tcp_syn_retries
apply 2 /proc/sys/net/ipv4/tcp_synack_retries
apply 3 /proc/sys/net/ipv4/tcp_retries2
apply 15 /proc/sys/net/ipv4/tcp_fin_timeout
apply "1024 65535" /proc/sys/net/ipv4/ip_local_port_range

# TCP/UDP Buffer
apply "4096 87380 524288" /proc/sys/net/ipv4/tcp_rmem
apply "4096 65536 524288" /proc/sys/net/ipv4/tcp_wmem
apply 8192 /proc/sys/net/ipv4/udp_rmem_min
apply 8192 /proc/sys/net/ipv4/udp_wmem_min
apply "8192 65536 524288" /proc/sys/net/ipv4/udp_mem

# Reuse & Fast Open
apply 1 /proc/sys/net/ipv4/tcp_tw_reuse
apply 262144 /proc/sys/net/ipv4/tcp_max_tw_buckets
apply 8192 /proc/sys/net/ipv4/tcp_max_syn_backlog
apply 1 /proc/sys/net/ipv4/tcp_fastopen

# ARP Cache
apply 1024 /proc/sys/net/ipv4/neigh/default/gc_thresh1
apply 2048 /proc/sys/net/ipv4/neigh/default/gc_thresh2
apply 4096 /proc/sys/net/ipv4/neigh/default/gc_thresh3

# Security
apply 1 /proc/sys/net/ipv4/tcp_syncookies
apply 0 /proc/sys/net/ipv4/conf/all/rp_filter
apply 0 /proc/sys/net/ipv4/icmp_echo_ignore_all

# Unix Socket
apply 4096 /proc/sys/net/unix/max_dgram_qlen

# MTU (untuk semua interface yang cocok)
for iface in $(ls /sys/class/net/ | grep -E 'wlan|rmnet|ccmni|radio'); do
    [ -e "/sys/class/net/$iface/mtu" ] && apply 1400 "/sys/class/net/$iface/mtu"
done

# DNS TTL
apply 10 /proc/sys/net/ipv4/ipfrag_time

# FIN Cleanup
apply 2 /proc/sys/net/ipv4/tcp_orphan_retries
apply 4096 /proc/sys/net/ipv4/tcp_max_orphans

# Flush Routing
apply 1 /proc/sys/net/ipv4/route/flush

# Notif
MESSAGES=(
  "🔧 MIUI Union Initialized"
  "🚀 System Ready – Welcome to MIUI Union"
  "🛰️ MIUI Union Protocol: Online"
  "💻 Boot Sequence Complete: MIUI Union Activated"
  "⚙️ System Hooked – MIUI Union is Live"
  "🔌 Power Route Engaged – MIUI Union Synced"
  "🧠 MIUI Union: Performance Layer Online"
)

RANDOM_MSG="${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"

# Bangun isi toast lengkap dengan device info
FULL_TOAST=$(echo -e "$RANDOM_MSG\n\n---- DEVICE INFO ----\nDEVICE       : $(getprop ro.build.product)\nMODEL        : $(getprop ro.product.model)\nMANUFACTURER : $(getprop ro.product.system.manufacturer)\nBOARD        : $(getprop ro.product.board)\nCPU          : $(getprop ro.hardware)\nANDROID VER  : $(getprop ro.build.version.release)\nKERNEL       : $(uname -r)\nRAM (KB)     : $(free | grep Mem | awk '{print $2}')\n----------------------")

# Tampilkan toast via bellavita.toast
am start -a android.intent.action.MAIN \
-n bellavita.toast/.MainActivity \
-e toasttext "$FULL_TOAST"

# Permission 
chmod 0731 /data/system/theme    
chmod 0640 /sys/fs/selinux/enforce
chmod 0440 /sys/fs/selinux/policy
setenforce 1
apply 1 /sys/fs/selinux/enforce