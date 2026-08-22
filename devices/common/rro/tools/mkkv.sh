#!/bin/bash
# Regenerates the BrinaOS version key-visual for the Software update card -
# res/drawable/kv_16.png and kv_16_1.png in the BrinaOSUpdateApp overlay.
#
# These are the giant "16" / "16.1" that r5/f.L0 sets on iv_version_logo. Stock
# draws them in the ColorOS pink/lavender gradient, so the "Version up to date"
# screen reads ColorOS no matter what the small wordmark below says - the card
# background (kv_bg_*) and that wordmark (logo_coloros_*) were already overridden,
# this is the piece that was missing. KvNum.java lifts the numerals straight out
# of the stock kv_16.png so the typeface matches, and refills them in BrinaOS
# gold. Run from the toolkit root:
#
#     bash devices/common/rro/tools/mkkv.sh
set -e
ROOT=$(cd "$(dirname "$0")/../../../.." && pwd)
cd "$ROOT"

# Prefer the portrom copy: the baserom OTA can be an older build without the
# key-visual drawables.
OTA=build/portrom/images/system_ext/app/OTA/OTA.apk
[[ -f "$OTA" ]] || OTA=$(find build -type f -path "*system_ext/app/OTA/OTA.apk" 2>/dev/null | head -n1)
if [[ -z "$OTA" || ! -f "$OTA" ]]; then echo "mkkv: stock OTA.apk not found in build/, run after unpack"; exit 1; fi

W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
java -jar bin/apktool/apktool.jar d -f -o "$W/ota" "$OTA" >/dev/null 2>&1
STOCK="$W/ota/res/drawable/kv_16.png"
if [[ ! -f "$STOCK" ]]; then echo "mkkv: kv_16.png not in stock OTA - has the app changed?"; exit 1; fi

DRW=devices/common/rro/BrinaOSUpdateApp/res/drawable
mkdir -p "$DRW"
# Canvas sizes are the stock intrinsic sizes (kv_16 345x300 PNG, kv_16_1 440x395
# webp); the ImageView is centerInside so these set how big the numerals draw.
java devices/common/rro/tools/KvNum.java "$STOCK" 16   345 300 "$DRW/kv_16.png"
# kv_16_1 is the numeral L0 picks on the online update card (both "checking" and
# "up to date"). We deliberately serve the clean gold "16" there too rather than a
# reconstructed "16.1": the ".1" glyph never reads as cleanly and the plain "16"
# is the look the device owner signed off on. So kv_16_1 is just a copy of kv_16.
cp -f "$DRW/kv_16.png" "$DRW/kv_16_1.png"
echo "mkkv: wrote $DRW/kv_16.png and kv_16_1.png (both the gold 16)"
