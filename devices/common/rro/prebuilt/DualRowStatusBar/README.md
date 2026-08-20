# DualRowStatusBar

The dual-row signal status bar with the big 5G glyph, lifted out of the Magisk
module **iOS Theme StatusIcon For ColorOS 16.0** (`id=iOSThemeStatusIconForColorOS`,
version 16.0.0.212, 酷安@Treatangus). Installed by `install_prebuilt_rro
DualRowStatusBar` on ColorOS Global ports.

| APK | package | priority | what it overrides |
| --- | --- | --- | --- |
| `PuiThemeStatusIcon.apk` | `com.android.systemui.PuiThemeStatusIcon` | 800 | the signal, wifi, 5G and notification status icons |
| `PuiThemeHorizontalBattery.apk` | `com.android.systemui.PuiThemeHorizontalBattery` | 5000 | the horizontal battery drawables and their dimens |
| `PuiThemeHorizontalBatteryColor.apk` | `com.android.systemui.PuiThemeHorizontalBatteryColor` | 200 | the VOOC / SVOOC / saver charging bar colours |
| `PuiThemeBluetoothBatteryIcon.apk` | `com.android.systemui.PuiThemeBluetoothBatteryIcon141New` | 8000 | the bluetooth battery digits |

All four are static RROs against `com.android.systemui` and carry no code, which
is why they do not need Magisk: the module only mounted them over
`/system/vendor/overlay`, and a static RRO is trusted by whichever system
partition it sits on. Dropping them into `product/overlay` at build time is the
same thing with one less moving part.

## PuiThemeStatusIcon.apk is patched

It is **not** the author's build byte for byte. Its dual-row bars fill their
canvas, and SystemUI stacks the bars and the data-type glyph in one end-aligned
`FrameLayout`, so out of the box every G/E/3G/4G/5G/LTE glyph is drawn on top of
the bars. `devices/common/rro/tools/mkfix.py` rewrites the `insetLeft` and
`insetRight` of the 19 type glyphs — and only those — to put them clear of the
bars at a constant intrinsic width, then rebuilds and re-signs the APK with the
toolkit's testkey. Resource ids, names and configurations are unchanged; the
tools README explains the geometry, and why this is a patch rather than another
overlay layered on top.

## What was deliberately left behind

* **`system.prop`** — seven blur and animation props. brina.sh already owns every
  one of those decisions: it sets `persist.sys.oplus.anim_level` itself per device
  family, and `ro.surface_flinger.supports_background_blur` /
  `media_panel_bg_blur` are commented out on purpose. Carrying the module's copies
  in would silently overrule both.
* **`service.sh`** — a boot loop that waits for `sys.boot_completed` and then
  `resetprop`s `ro.vendor.oplus.camera.isSupportExplorer 1`. brina.sh already sets
  that prop at build time for ColorOS ports.
* **`customize.sh`** — Magisk installer plumbing, plus an `am start` that opens the
  author's Coolapk profile.

## Updating

Drop a newer build of the module in here as `*.apk` and the next port picks it up;
`install_prebuilt_rro` copies every APK in the directory. Check the package names
have not changed, since two overlays with the same package name cannot both be
installed — and **re-run `python3 devices/common/rro/tools/mkfix.py`**, or the
data-type glyphs go back to sitting on the bars. It is safe to run at any time;
it prints what it did and does nothing to an APK that is already patched.
