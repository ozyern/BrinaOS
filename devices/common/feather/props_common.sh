# Feather Engine — shared props (SM8250 + SM8350)
# Each function writes to system build.prop or vendor default.prop.
# Caller must define set_prop() before sourcing this file.

# ── SurfaceFlinger & Rendering ──────────────────────────────────────────────
apply_sf_props() {
    local sys="$1" vnd="$2"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.max_frame_buffer_acquired_buffers=3"
    set_prop "$vnd/default.prop"  "debug.hwui.renderer=skiaglthreaded"
    set_prop "$vnd/default.prop"  "debug.renderengine.backend=skiaglthreaded"
    set_prop "$vnd/default.prop"  "debug.sf.enable_gl_backpressure=1"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.enable_frame_rate_override=false"
    set_prop "$vnd/default.prop"  "debug.egl.hw=1"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.use_context_priority=true"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.running_without_sync_framework=false"
    set_prop "$vnd/default.prop"  "debug.sf.early_app_phase_offset_ns=500000"
    set_prop "$vnd/default.prop"  "debug.sf.early_sf_phase_offset_ns=500000"
    set_prop "$vnd/default.prop"  "debug.sf.hw=1"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.protect_contents=false"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.enable_frame_rate_flexibility=true"
}

# ── SurfaceFlinger idle timers (panel-dependent) ────────────────────────────
# $3=idle_ms  $4=touch_ms  $5=power_ms  $6=idle_fps
apply_sf_timers() {
    local vnd="$2"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.set_idle_timer_ms=$3"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.set_touch_timer_ms=$4"
    set_prop "$vnd/default.prop"  "ro.surface_flinger.set_display_power_timer_ms=$5"
    set_prop "$vnd/default.prop"  "vendor.display.idle_fps=$6"
}

# ── Dalvik / ART heap & JIT ─────────────────────────────────────────────────
apply_dalvik_props() {
    local sys="$1"
    set_prop "$sys/build.prop"  "dalvik.vm.usejit=true"
    set_prop "$sys/build.prop"  "dalvik.vm.heaptargetutilization=0.75"
    set_prop "$sys/build.prop"  "dalvik.vm.heapstartsize=16m"
    # heapgrowthlimit = heapsize: ART skips GC-before-allocation
    set_prop "$sys/build.prop"  "dalvik.vm.heapgrowthlimit=512m"
    set_prop "$sys/build.prop"  "dalvik.vm.heapsize=512m"
    set_prop "$sys/build.prop"  "dalvik.vm.heapminfree=8m"
    set_prop "$sys/build.prop"  "dalvik.vm.heapmaxfree=32m"
    # AOT compilation — all 8 cores for faster install + better code quality
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-filter=speed"
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-threads=8"
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5,6,7"
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-swap=false"
    # JIT threshold: hot methods promote to AOT faster
    set_prop "$sys/build.prop"  "dalvik.vm.jitthreshold=500"
    set_prop "$sys/build.prop"  "dalvik.vm.jitinitialsize=64m"
    set_prop "$sys/build.prop"  "dalvik.vm.jitmaxsize=512m"
    # Boot-time dex2oat on all cores — first boot finishes faster
    set_prop "$sys/build.prop"  "dalvik.vm.boot-dex2oat-threads=8"
    set_prop "$sys/build.prop"  "dalvik.vm.boot-dex2oat-cpu-set=0,1,2,3,4,5,6,7"
    set_prop "$sys/build.prop"  "dalvik.vm.image-dex2oat-filter=speed-profile"
    set_prop "$sys/build.prop"  "dalvik.vm.image-dex2oat-threads=4"
    # dex2oat JVM heap — without this dex2oat GCs during compilation
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-Xms=64m"
    set_prop "$sys/build.prop"  "dalvik.vm.dex2oat-Xmx=512m"
}

# ── Qualcomm Perf HAL (IOP, MPCTLV3, PHR, frame boost) ─────────────────────
apply_perf_hal_props() {
    local vnd="$2"
    set_prop "$vnd/default.prop"  "vendor.perf.iop.enable=true"
    set_prop "$vnd/default.prop"  "vendor.perf.iop_v3.enable=true"
    set_prop "$vnd/default.prop"  "ro.vendor.perf.scroll_opt=1"
    set_prop "$vnd/default.prop"  "vendor.perf.gestureflingboost.enable=true"
    set_prop "$vnd/default.prop"  "vendor.perf.enable_hint_manager=true"
    set_prop "$vnd/default.prop"  "vendor.perf.enable_perf_hal_mpctlv3=true"
    set_prop "$vnd/default.prop"  "vendor.perf.ux_frameboost.enable=true"
    set_prop "$vnd/default.prop"  "vendor.perf.framepacing.enable=1"
    set_prop "$vnd/default.prop"  "vendor.perf.topAppRenderThreadBoost.enable=true"
    set_prop "$vnd/default.prop"  "ro.vendor.perf.vsync_boost.enable=1"
    set_prop "$vnd/default.prop"  "vendor.perf.app_launch_hint_enable=1"
    # PHR: pre-boosts CPU before next frame budget opens
    set_prop "$vnd/default.prop"  "vendor.perf.phr.target_fps=120"
    set_prop "$vnd/default.prop"  "ro.vendor.perf.phr.enable=1"
    set_prop "$vnd/default.prop"  "vendor.perf.phr.render_ahead=2"
    set_prop "$vnd/default.prop"  "vendor.perf.sched_boost_on_top_app=1"
    # DDR/LLCC/CCI bandwidth boosting
    set_prop "$vnd/default.prop"  "persist.vendor.qti.bus.dcvs=true"
    set_prop "$vnd/default.prop"  "vendor.perf.ddr.bw_boost=true"
    set_prop "$vnd/default.prop"  "vendor.perf.cci_boost=true"
    set_prop "$vnd/default.prop"  "vendor.perf.llcc.wt_aggr=1"
    set_prop "$vnd/default.prop"  "ro.vendor.perf.pfar.enable=1"
}

# ── HWUI cache sizes & hint manager ─────────────────────────────────────────
apply_hwui_props() {
    local vnd="$2"
    set_prop "$vnd/default.prop"  "debug.hwui.texture_cache_size=72"
    set_prop "$vnd/default.prop"  "debug.hwui.layer_cache_size=48"
    set_prop "$vnd/default.prop"  "debug.hwui.r_buffer_cache_size=8"
    set_prop "$vnd/default.prop"  "debug.hwui.path_cache_size=32"
    set_prop "$vnd/default.prop"  "debug.hwui.drop_shadow_cache_size=6"
    set_prop "$vnd/default.prop"  "debug.hwui.shape_cache_size=4"
    # HWUI pushes perf hints into QTI HAL during heavy draw passes
    set_prop "$vnd/default.prop"  "debug.hwui.use_hint_manager=true"
    set_prop "$vnd/default.prop"  "debug.hwui.target_cpu_time_percent=33"
    set_prop "$vnd/default.prop"  "debug.hwui.skia_atrace_enabled=false"
}

# ── LMKD PSI tuning ────────────────────────────────────────────────────────
apply_lmkd_props() {
    local sys="$1"
    set_prop "$sys/build.prop"  "ro.lmk.use_psi=true"
    set_prop "$sys/build.prop"  "ro.lmk.psi_partial_stall_ms=70"
    set_prop "$sys/build.prop"  "ro.lmk.psi_complete_stall_ms=700"
    set_prop "$sys/build.prop"  "ro.lmk.thrashing_limit=100"
    set_prop "$sys/build.prop"  "ro.lmk.swap_free_low_percentage=10"
    set_prop "$sys/build.prop"  "ro.lmk.kill_timeout_ms=100"
    set_prop "$sys/build.prop"  "ro.lmk.critical_upgrade=true"
    set_prop "$sys/build.prop"  "ro.lmk.upgrade_pressure=40"
    set_prop "$sys/build.prop"  "ro.lmk.downgrade_pressure=60"
}

# ── Background process limits & memory management ──────────────────────────
apply_memory_props() {
    local sys="$1" vnd="$2"
    set_prop "$sys/build.prop"    "ro.sys.fw.bg_apps_limit=48"
    set_prop "$vnd/default.prop"  "ro.vendor.qti.sys.fw.bg_apps_limit=48"
    set_prop "$vnd/default.prop"  "ro.vendor.qti.sys.fw.bservice_enable=true"
    set_prop "$sys/build.prop"    "persist.sys.purgeable_assets=1"
    set_prop "$sys/build.prop"    "ro.min.fling_velocity=160"
    set_prop "$sys/build.prop"    "ro.max.fling_velocity=8000"
    set_prop "$sys/build.prop"    "ro.config.max_starting_bg=4"
    set_prop "$vnd/default.prop"  "vendor.perf.bg_app_suspend.enable=true"
    # LLCC retention + Zygote preload
    set_prop "$vnd/default.prop"  "persist.vendor.qti.llcc.enable=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.llcc.retentionmode=1"
    set_prop "$sys/build.prop"    "ro.zygote.preload.enable=true"
    # Memory trim / bandwidth governors
    set_prop "$sys/build.prop"    "ro.sys.fw.use_trim_settings=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.sys.fw.trim_enable_memory=3221225472"
    set_prop "$vnd/default.prop"  "vendor.power.bw_hwmon.enable=1"
    set_prop "$vnd/default.prop"  "ro.vendor.qti.mem.autosuspend_enable=1"
    set_prop "$sys/build.prop"    "persist.sys.suspend.mode=deep"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.perfd.reclaim_memory=1"
    set_prop "$vnd/default.prop"  "ro.vendor.radio.power_down_enable=1"
}

# ── Power / radio / wifi / sensors / audio ──────────────────────────────────
apply_power_props() {
    local sys="$1" vnd="$2"
    # Radio
    set_prop "$vnd/default.prop"  "persist.radio.add_power_save=1"
    set_prop "$vnd/default.prop"  "persist.vendor.radio.process_sups_ind=1"
    set_prop "$vnd/default.prop"  "ro.vendor.use_data_netmgrd=true"
    set_prop "$vnd/default.prop"  "ro.config.hw_fast_dormancy=1"
    set_prop "$vnd/default.prop"  "persist.radio.sw_mbn_update=0"
    # Wi-Fi
    set_prop "$vnd/default.prop"  "persist.vendor.wifi.enhanced.power.save=1"
    set_prop "$vnd/default.prop"  "ro.wifi.power_save_mode=1"
    set_prop "$vnd/default.prop"  "persist.vendor.wifi.scan.allow_low_latency_scan=0"
    # Sensors — RT thread off saves idle battery with no latency impact
    set_prop "$vnd/default.prop"  "persist.vendor.sensors.enable.rt_task=false"
    set_prop "$vnd/default.prop"  "persist.vendor.sensors.support_wakelock=false"
    # Audio — fast track + DSP offload
    set_prop "$vnd/default.prop"  "af.fast_track_multiplier=1"
    set_prop "$vnd/default.prop"  "audio.deep_buffer.media=false"
    set_prop "$vnd/default.prop"  "ro.config.low_power_audio=true"
    set_prop "$vnd/default.prop"  "persist.vendor.bt.a2dp_offload_cap=sbc-aptx-aptxhd-aac-ldac"
    set_prop "$vnd/default.prop"  "vendor.audio.feature.a2dp_offload.enable=true"
    set_prop "$vnd/default.prop"  "persist.vendor.audio.fluence.speaker=true"
}

# ── dexopt / IORap / job scheduler ──────────────────────────────────────────
apply_dexopt_props() {
    local sys="$1"
    set_prop "$sys/build.prop"  "persist.device_config.runtime_native_boot.iorap_readahead_enable=true"
    set_prop "$sys/build.prop"  "pm.dexopt.downgrade_after_inactive_days=7"
    set_prop "$sys/build.prop"  "pm.dexopt.install=speed"
    set_prop "$sys/build.prop"  "pm.dexopt.shared_apk=speed"
    set_prop "$sys/build.prop"  "pm.dexopt.bg-dexopt=speed-profile"
    set_prop "$sys/build.prop"  "pm.dexopt.boot-after-ota=verify"
    set_prop "$sys/build.prop"  "ro.iorapd.enable=true"
    set_prop "$sys/build.prop"  "persist.iorapd.enable=true"
    set_prop "$sys/build.prop"  "ro.iorapd.perfetto_enable=true"
    set_prop "$sys/build.prop"  "persist.sys.job_scheduler_optimization_enabled=true"
    set_prop "$sys/build.prop"  "ro.config.shutdown_timeout=3"
}

# ── Misc vendor props (QTI cgroup, input, display, strictmode) ──────────────
apply_misc_props() {
    local sys="$1" vnd="$2"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.cgroup_follow.enable=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.inputopts.enable=true"
    set_prop "$sys/build.prop"    "ro.config.hw_quickpoweron=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.display.idle_time=0"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.display.idle_time_inactive=0"
    set_prop "$sys/build.prop"    "persist.sys.strictmode.disable=true"
    set_prop "$vnd/default.prop"  "ro.vendor.qti.sys.fw.bg_apps_limit_io=true"
}

# ── Bootloader spoof (vendor-side — system-side is in lemonade.prop) ────────
apply_bootloader_spoof() {
    local vnd="$2"
    set_prop "$vnd/default.prop"  "ro.vendor.boot.warranty_bit=0"
    set_prop "$vnd/default.prop"  "ro.vendor.warranty_bit=0"
    set_prop "$vnd/default.prop"  "ro.warranty_bit=0"
}
