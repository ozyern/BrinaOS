#!/bin/bash
# Rebuilds devices/common/bootanimation.zip and rbootanimation.zip.
# Run from the toolkit root:  bash devices/common/tools/mkboot.sh [crest.png]
set -e
ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
cd "$ROOT"

CREST="${1:-/mnt/c/Users/gameb/OneDrive/Desktop/boot animation.png}"
WORDMARK=devices/common/rro/BrinaOSBrandName/res/drawable/brand_logo_16_1.xml
GOLD="#EFD39B"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
mkdir -p "$W/boot" "$W/shutdown"

# The wordmark canvas is sized to the ink exactly - Boot.java scales the whole
# PNG, so any padding here would shrink the letters inside the lockup.
java devices/common/rro/tools/Logo.java "$WORDMARK" 980 208 208 "$GOLD" "$W/word.png"

# Geometry copied from the stock boot desc.txt so the animation lands where
# OPPO's did. The shutdown one uses the same band rather than its own 1440x206
# strip: it is the same lockup fading away, and 206px has no room for the crest.
java devices/common/tools/Boot.java boot     "$CREST" "$W/word.png" "$W/boot"     1440 777 48 60
java devices/common/tools/Boot.java shutdown "$CREST" "$W/word.png" "$W/shutdown" 1440 777 40 2

cat > "$W/boot/desc.txt" <<'EOF'
# global width height offsetx offsety fps
#
g 1440 777 0 688 30

p 1 0 part0
p 0 0 part1
EOF

cat > "$W/shutdown/desc.txt" <<'EOF'
# global width height offsetx offsety fps
#
g 1440 777 0 688 30

p 1 0 part0
p 0 0 part1
EOF

# bootanimation mmaps the frames, so everything must be stored, not deflated.
rm -f "$ROOT/devices/common/bootanimation.zip" "$ROOT/devices/common/rbootanimation.zip"
( cd "$W/boot"     && zip -0 -q -r -X "$ROOT/devices/common/bootanimation.zip"  desc.txt part0 part1 )
( cd "$W/shutdown" && zip -0 -q -r -X "$ROOT/devices/common/rbootanimation.zip" desc.txt part0 part1 )

ls -la "$ROOT/devices/common/bootanimation.zip" "$ROOT/devices/common/rbootanimation.zip"
