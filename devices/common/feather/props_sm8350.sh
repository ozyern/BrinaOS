# Feather Engine — SM8350 (Snapdragon 888 / Adreno 660) specific props

apply_sm8350_props() {
    local sys="$1" vnd="$2"

    # ── Adreno 660 / Lahaina GPU ────────────────────────────────────────────
    set_prop "$vnd/default.prop"  "ro.hardware.vulkan=adreno"
    set_prop "$vnd/default.prop"  "ro.hardware.egl=adreno"
    set_prop "$vnd/default.prop"  "persist.graphics.vulkan.disable=false"
    set_prop "$vnd/default.prop"  "ro.gfx.driver.1=com.qualcomm.qti.gpudrivers.lahaina.api30"
    set_prop "$vnd/default.prop"  "ro.hwui.skia_use_vulkan_for_hwui=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.display.dcvs_mode=2"

    # ── LPDDR5 prefetch ─────────────────────────────────────────────────────
    set_prop "$vnd/default.prop"  "ro.vendor.qti.sys.fw.bg_apps_limit_ddr5=true"
}
