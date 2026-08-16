# Feather Engine — SM8250 (Snapdragon 865 / Adreno 650) specific props

apply_sm8250_props() {
    local sys="$1" vnd="$2"

    # ── Adreno 650 / Kona GPU ───────────────────────────────────────────────
    set_prop "$vnd/default.prop"  "ro.hardware.vulkan=adreno"
    set_prop "$vnd/default.prop"  "ro.hardware.egl=adreno"
    set_prop "$vnd/default.prop"  "persist.graphics.vulkan.disable=false"
    set_prop "$vnd/default.prop"  "ro.gfx.driver.1=com.qualcomm.qti.gpudrivers.kona.api30"
    set_prop "$vnd/default.prop"  "ro.hwui.skia_use_vulkan_for_hwui=true"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.display.dcvs_mode=2"

    # ── LPM prediction off — keeps prime in shallower C-state ───────────────
    set_prop "$vnd/default.prop"  "vendor.power.lpm_prediction=false"
    set_prop "$vnd/default.prop"  "persist.vendor.qti.lpm.prediction=false"
}
