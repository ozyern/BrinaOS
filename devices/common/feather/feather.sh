#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Feather Engine — SM8250 / SM8350 smoothness & performance tuning
# Injects SurfaceFlinger, Dalvik, GPU, scheduler, and perf HAL properties
# into the ported ROM. Also installs device-specific init.rc files.
# ─────────────────────────────────────────────────────────────────────────────

FEATHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Prop helpers ─────────────────────────────────────────────────────────────
# set_prop:  append only if key is absent (safe for defaults)
# force_prop: replace if key exists, append if absent (needed for overrides)

set_prop() {
    local file="$1" prop="$2"
    grep -q "^${prop%%=*}=" "$file" 2>/dev/null || echo "$prop" >> "$file"
}

force_prop() {
    local file="$1" prop="$2"
    local key="${prop%%=*}"
    if grep -q "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${prop}|" "$file"
    else
        echo "$prop" >> "$file"
    fi
}

# ── Source prop modules ──────────────────────────────────────────────────────
source "${FEATHER_DIR}/props_common.sh"
source "${FEATHER_DIR}/props_sm8250.sh"
source "${FEATHER_DIR}/props_sm8350.sh"

# ── Thermal config patcher ──────────────────────────────────────────────────
# Relaxes thermal throttling to keep sustained clocks during daily use.
# Operates on thermal-engine.conf in vendor/etc/; skips if absent.
patch_thermal_config() {
    local conf="$1/etc/thermal-engine.conf"
    [[ -f "$conf" ]] || return 0

    # Raise thresholds: 44°C → 47°C, 46°C → 50°C, etc.
    local -A thermal_map=(
        [44000]=47000  [46000]=50000  [48000]=52000  [50000]=55000
        [52000]=57000  [54000]=60000  [56000]=62000  [58000]=65000
        [60000]=67000  [62000]=70000  [64000]=72000  [66000]=75000
        [68000]=77000  [70000]=80000  [72000]=82000  [74000]=85000
    )

    for orig in "${!thermal_map[@]}"; do
        sed -i "s/set_point ${orig}/set_point ${thermal_map[$orig]}/g" "$conf"
        sed -i "s/set_point_clr ${orig}/set_point_clr ${thermal_map[$orig]}/g" "$conf"
    done

    blue "Feather: thermal thresholds relaxed" 2>/dev/null || true
}

# ── 12GB RAM variant overrides ──────────────────────────────────────────────
apply_12gb_overrides() {
    local sys="$1" vnd="$2"
    set_prop "$sys/build.prop"    "dalvik.vm.heapgrowthlimit=768m"
    set_prop "$sys/build.prop"    "dalvik.vm.heapsize=768m"
    set_prop "$sys/build.prop"    "dalvik.vm.heapmaxfree=48m"
    set_prop "$sys/build.prop"    "ro.sys.fw.bg_apps_limit=60"
    set_prop "$vnd/default.prop"  "ro.vendor.qti.sys.fw.bg_apps_limit=60"
}

# ── Install init.rc ─────────────────────────────────────────────────────────
install_rc() {
    local rc_src="$1" rc_name="$2" vnd="$3"
    local target="${vnd}/etc/init/${rc_name}"
    if [[ -f "$rc_src" ]]; then
        cp -f "$rc_src" "$target"
        chmod 644 "$target"
    fi
}

# ═════════════════════════════════════════════════════════════════════════════
# Entry point — called from brina.sh
# Args: $1 = base_device_family, $2 = base_product_device, $3 = base_product_model
# ═════════════════════════════════════════════════════════════════════════════
apply_feather_engine() {
    local family="$1"
    local device="$2"
    local model="$3"

    local SYSTEM_PATH="build/portrom/images/system/system"
    local VENDOR_PATH="build/portrom/images/vendor"

    # Gate: only SM8250 and SM8350 families
    case "$family" in
        OPSM8250|OPSM8350) ;;
        *) return 0 ;;
    esac

    # Gate: required files
    if [[ ! -f "$SYSTEM_PATH/build.prop" || ! -f "$VENDOR_PATH/default.prop" ]]; then
        yellow "Feather Engine skipped: required prop files not found" 2>/dev/null || true
        return 0
    fi

    blue "Implementing Feather Engine ($family)..." 2>/dev/null || true

    # ── Device variant detection ─────────────────────────────────────────────
    local is_op9pro=false is_op8pro=false is_op8t=false is_op9r_8250=false
    local is_12gb=false

    case "$device" in
        OnePlus9Pro|LE2120|LE2121|LE2123|LE2125)  is_op9pro=true ;;
        OnePlus8Pro|IN2020|IN2021|IN2022|IN2023)   is_op8pro=true ;;
        OnePlus8T|KB2000|KB2001|KB2003|KB2005)     is_op8t=true ;;
        OnePlus9R|LE2100|LE2101)                   is_op9r_8250=true ;;
    esac

    # 12GB detection: OP8 Pro IN2023, OP9 Pro LE2123/LE2125, OP9 LE2111/LE2115
    case "$model" in
        IN2023|LE2123|LE2125|LE2111|LE2115) is_12gb=true ;;
    esac

    # ── Shared props (both SoCs) ─────────────────────────────────────────────
    apply_sf_props         "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_dalvik_props     "$SYSTEM_PATH"
    apply_perf_hal_props   "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_hwui_props       "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_lmkd_props       "$SYSTEM_PATH"
    apply_memory_props     "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_power_props      "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_dexopt_props     "$SYSTEM_PATH"
    apply_misc_props       "$SYSTEM_PATH" "$VENDOR_PATH"
    apply_bootloader_spoof "$SYSTEM_PATH" "$VENDOR_PATH"

    # ── SoC-specific props + init.rc ─────────────────────────────────────────
    if [[ "$family" == "OPSM8250" ]]; then
        apply_sm8250_props "$SYSTEM_PATH" "$VENDOR_PATH"

        # SF idle timers per panel type
        if [[ "$is_op8pro" == true ]]; then
            # 120Hz curved QHD+ AMOLED
            apply_sf_timers "" "$VENDOR_PATH" 500 200 1000 60
        elif [[ "$is_op9r_8250" == true ]]; then
            # 90Hz flat FHD+ — no content-detection based RR switching
            apply_sf_timers "" "$VENDOR_PATH" 300 100 500 60
            set_prop "$VENDOR_PATH/default.prop" \
                "ro.surface_flinger.use_content_detection_for_refresh_rate=false"
        else
            # OP8/OP8T: 120Hz flat FHD+
            apply_sf_timers "" "$VENDOR_PATH" 400 150 750 60
        fi

        install_rc "${FEATHER_DIR}/rc_sm8250.rc" "op8_sched.rc" "$VENDOR_PATH"

    elif [[ "$family" == "OPSM8350" ]]; then
        apply_sm8350_props "$SYSTEM_PATH" "$VENDOR_PATH"

        if [[ "$is_op9pro" == true ]]; then
            # OP9 Pro: LTPO 120Hz QHD+ — longer idle window, higher touch timer
            apply_sf_timers "" "$VENDOR_PATH" 500 200 1000 60
            set_prop "$VENDOR_PATH/default.prop" \
                "ro.surface_flinger.use_content_detection_for_refresh_rate=true"
            # OP9 Pro exclusive props
            set_prop "$VENDOR_PATH/default.prop" "ro.surface_flinger.has_LTPO=true"
            set_prop "$VENDOR_PATH/default.prop" "ro.surface_flinger.force_hwc_for_virtual_displays=true"
            # Install OP9 Pro rc (overrides base SM8350 rc)
            install_rc "${FEATHER_DIR}/rc_sm8350.rc" "op9_sched.rc" "$VENDOR_PATH"
            install_rc "${FEATHER_DIR}/rc_op9pro.rc" "op9pro_perf.rc" "$VENDOR_PATH"
        else
            # OP9 / other SM8350: FHD+ 120Hz
            apply_sf_timers "" "$VENDOR_PATH" 400 150 750 60
            install_rc "${FEATHER_DIR}/rc_sm8350.rc" "op9_sched.rc" "$VENDOR_PATH"
        fi
    fi

    # ── 12GB RAM overrides ───────────────────────────────────────────────────
    if [[ "$is_12gb" == true ]]; then
        blue "Feather: 12GB RAM profile applied (${model})" 2>/dev/null || true
        apply_12gb_overrides "$SYSTEM_PATH" "$VENDOR_PATH"
    fi

    # ── Thermal config patching ──────────────────────────────────────────────
    patch_thermal_config "$VENDOR_PATH"

    green "Feather Engine applied successfully" 2>/dev/null || true
}
