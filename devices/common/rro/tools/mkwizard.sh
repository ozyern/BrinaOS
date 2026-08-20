#!/bin/bash
# Regenerates the BrinaOSSetupWizard artwork. Run from the toolkit root.
set -e
ROOT=$(cd "$(dirname "$0")/../../../.." && pwd)
cd "$ROOT"

T=devices/common/rro/tools
D=devices/common/rro/BrinaOSSetupWizard/res
PHOTO="${1:-/mnt/c/Users/gameb/Downloads/post-credits scene (1).jpg}"
CREST="${2:-/mnt/c/Users/gameb/OneDrive/Desktop/boot animation.png}"
WORDMARK=devices/common/rro/BrinaOSBrandName/res/drawable/brand_logo_16_1.xml
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

mkdir -p "$D/raw" "$D/drawable" "$D/drawable-xxhdpi"

# The last page draws its lettering in black on a light card, so the wordmark
# matches rather than carrying the white one off the OTA card. 1280 wide is two
# device pixels per canvas unit at the size the page renders it.
java "$T/Logo.java" "$WORDMARK" 1280 272 272 "#000000" "$W/word.png"
python3 "$T/mklottie.py" "$W/word.png" "$D/raw/complete_page_logo.json"
cp -f "$D/raw/complete_page_logo.json" "$D/raw/complete_page_logo_id.json"

# ...and the still the page falls back to when it does not animate. This one has
# to go in drawable-xxhdpi, not drawable: that is the configuration the wizard
# defines it in, and a default-config entry would lose the match on any device
# with a density however high the overlay's priority is. 136 ink height is the
# same 640-wide wordmark the Lottie draws, so the two paths agree.
java "$T/Logo.java" "$WORDMARK" 1080 570 136 "#000000" "$D/drawable-xxhdpi/img_complete.png"

# The welcome page's background. ic_bg_guide_page is a vector in stock; a PNG
# overrides it fine, the ImageView-less RelativeLayout just stretches it.
java "$T/Guide.java" "$PHOTO" "$CREST" "$D/drawable/ic_bg_guide_page.png" 1080 2412

ls -la "$D/raw" "$D/drawable" "$D/drawable-xxhdpi"
