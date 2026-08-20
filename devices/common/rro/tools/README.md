# rro/tools

Authoring tools for the BrinaOS overlays. Nothing here runs during a port —
`brina.sh` only ever compiles the finished `res/` trees. These exist so the
artwork, the wordmark and the status-bar geometry can be regenerated without
hunting for the recipe.

| tool | what it feeds |
| --- | --- |
| `Crop.java` | `BrinaOSOtaCard` — the Settings About card artwork |
| `Kv.java` | `BrinaOSUpdateApp` — the Software update key visual |
| `Brand.java` | `BrinaOSBrandName` — the BrinaOS logotype, as a vector |
| `Logo.java` | `BrinaOSUpdateApp` — the same logotype, as a PNG |
| `padvec.py` | `BrinaOSUpdateApp` — the same logotype refitted to another vector's box |
| `mkai.py` | `BrinaOSAiName` — the BrinaAI strings, in every locale |
| `mklottie.py` | `BrinaOSSetupWizard` — the wordmark animation on the last setup page |
| `Guide.java` | `BrinaOSSetupWizard` — the welcome page background |
| `mkwizard.sh` | runs both of those |
| `mkfix.py` | patches the `DualRowStatusBar` prebuilt's data-type icons |
| `Mock.java` | previews the Settings About card |
| `MockUpdate.java` | previews the Software update card |
| `Compose.java` | previews the status bar signal cluster |

The boot animation is not an overlay and lives one directory up, in
`devices/common/tools/` — see the README there.

The Java ones are single-file programs, run straight from source:

```sh
java Crop.java …
```

No `javac`, no build step, no host packages. That is deliberate: the machine this
toolkit runs on has OpenJDK and nothing else useful for images or fonts — no PIL,
no fontTools, no ImageMagick, no cwebp.

---

## Crop.java — the About device card artwork

```sh
java Crop.java <src>                                        # just print the size
java Crop.java <src> <out> <W> <H> <bias> [quality] [scrim]
```

Centre-crops `src` to the `W×H` aspect, bicubic-scales it and writes a JPEG.

* **`bias`** is the vertical focus of the crop: `0` keeps the top edge, `1` the
  bottom, `0.5` the middle. The shipped portrait crop uses `0.42` and the
  landscape one `0.35`.
* **`scrim`** is a black gradient given as `y:alpha` stops, or `none`.

### Why the aspect matters

Settings stretches the card art to fill the view — it does not centre-crop — so a
picture at the wrong aspect comes out squashed. `dimen/about_device_ota_item_height`
is `280dp` and the stock assets are `984×840`, i.e. 3px per dp. The five names the
overlay provides:

| resource | size |
| --- | --- |
| `device_ota_card_bg`, `device_ota_card_bg_16`, `device_ota_card_bg_16_1` | 984×840 |
| `device_ota_card_bg_16_land`, `device_ota_card_bg_16_1_land` | 1550×840 |

### Why the scrim exists

The device name, the OS logotype, the version and the update button are drawn
straight onto the artwork with **no shadow and no scrim of their own** — stock
gets away with it because the stock card is a dark illustration. Put a bright
photo there and the labels disappear. The stops in tree are:

```
0:0.52,0.60:0.40,0.72:0.26,0.86:0.40,1:0.34
```

52% black at the top of the card, easing to 26% across the middle where nothing
is drawn, back up to 40% behind the update button. Interpolation is smoothstep so
there is no banding edge. Pass `none` to turn it off, or dial the numbers down —
`Mock.java` shows the result before anything gets flashed.

### Regenerating the shipped set

```sh
S="0:0.52,0.60:0.40,0.72:0.26,0.86:0.40,1:0.34"
D=devices/common/rro/BrinaOSOtaCard/res/drawable
java Crop.java photo.jpg $D/device_ota_card_bg.jpg           984 840 0.42 0.92 "$S"
cp $D/device_ota_card_bg.jpg $D/device_ota_card_bg_16.jpg
cp $D/device_ota_card_bg.jpg $D/device_ota_card_bg_16_1.jpg
java Crop.java photo.jpg $D/device_ota_card_bg_16_land.jpg  1550 840 0.35 0.92 "$S"
cp $D/device_ota_card_bg_16_land.jpg $D/device_ota_card_bg_16_1_land.jpg
```

---

## Brand.java — the BrinaOS logotype

```sh
java Brand.java <coloros_paths.txt> <text> <#AARRGGBB> [out.xml] [preview.png]
```

### Why this is a drawable and not a string

There is no "ColorOS" string anywhere in Settings' resources — the only hits are
package names like `com.coloros.gallery3d`. The OS name on the About device page
is a **vector logotype**, and four drawables carry it:

| resource | where it shows |
| --- | --- |
| `brand_logo` | the About card on the pre-16.1 layout |
| `brand_logo_16_1` | the About card on 16.1 |
| `about_device_easter_egg_logo` | centred on the card during the long-press easter egg |
| `coloros_15` | the 15 wordmark, kept in sync for good measure |

They sit in `ImageView`s that are `34dp` tall and `@dimen/brand_logo_width` =
`165dp` wide, with no `scaleType`, so the default `fitCenter` applies: a
replacement is scaled to `34dp` tall and centred. It does **not** have to be
`165dp` wide — it just must not be wider, or it will be scaled down to fit.

### Why the letterforms come from ColorOS itself

Those drawables *are* the font: the outlines are exactly what the type designer
drew. A lookalike system font is visibly wrong next to them — the ColorOS face is
a geometric sans with a circular `o`, a `4.98`-unit stem and a slightly lighter
`4.70`-unit ring, and nothing in `system/fonts` matches it.

So `Brand.java` lifts **r**, **O** and **S** out of the stock wordmark unchanged,
and constructs **B**, **i**, **n** and **a** — the four letters "ColorOS" does not
contain — from the same primitives, using measurements taken off the stock paths:

```
baseline 32.21   cap top 1.03   x-height 9.65   round overshoot to 9.20 / 33.07
stem 4.98        ring 4.695     o 23.69 wide    counter 14.30 wide
```

`a` is the stock `o` with a straight stem down its right side (the geometric
single-storey `a`); `n` is the stock `o` arch standing on two stems; `B` is the
`l` stem carrying two bowls; `i` is that stem cut to the x-height with a round
dot. Side bearings follow the stock ones — round-to-round `1.71`, stem-to-round
`3.40`.

### Getting the stock paths

They are extracted from the port's own Settings, not committed here:

```sh
A=otatools/bin/aapt2
S=build/portrom/images/system_ext/priv-app/Settings/Settings.apk
$A dump xmltree --file res/drawable/brand_logo_16_1.xml "$S" \
  | grep -oE 'pathData\(0x01010405\)="[^"]*"' | sed 's/pathData(0x01010405)=//' \
  | tail -n +2 > coloros_paths.txt      # tail drops the clip-path
```

That leaves seven lines, one per glyph of "ColorOS"; `Brand.java` sorts them left
to right and picks the ones it needs.

### Regenerating the shipped set

```sh
D=devices/common/rro/BrinaOSBrandName/res/drawable
for n in brand_logo brand_logo_16_1 about_device_easter_egg_logo coloros_15; do
    java Brand.java coloros_paths.txt BrinaOS "#FFFFFFFF" $D/$n.xml
done
```

Pass a fifth argument to also get a 10× PNG of the wordmark on a dark ground.

---

## Mock.java — see the card before flashing it

```sh
java Mock.java <card.jpg> <logo.xml> <0xRRGGBB> <out.png>
```

Composites the About device card the way Settings lays it out — the geometry is
read off `res/layout/about_device_ota_item.xml` and the dimens it references, so
text sizes and vertical rhythm match the real thing. Use it to judge a new photo,
a new scrim or a new text colour without building a ROM.

```sh
java Mock.java devices/common/rro/BrinaOSOtaCard/res/drawable/device_ota_card_bg.jpg \
               devices/common/rro/BrinaOSBrandName/res/drawable/brand_logo_16_1.xml \
               0xFFFFFF card-preview.png
```

It reads `OPSans-En-Regular.ttf` out of the port tree for the labels, so run it
with a port unpacked.

---

## The text colour

`BrinaOSOtaCard/res/values/colors.xml` overrides one colour,
`about_phone_name_version_color`. Settings tints **both** the device name and the
version number with it; stock is `#FFDDEB`, a pale pink chosen to sit on the
stock artwork. Everything else on the card — "Version up to date", the update
button — already uses `about_phone_text_color`, which is white. Setting this one
to white makes the whole card agree with the logotype.

Worth knowing if this ever needs revisiting: the layout declares
`about_phone_text_color` on every one of those `TextView`s and the code retints
two of them at runtime, so the layout alone does not tell you which colour is in
play. This one was found by sampling the pixels of a screenshot.


---

## Logo.java — the wordmark as a bitmap

```sh
java Logo.java <wordmark.xml> <canvasW> <canvasH> <inkH> <#RRGGBB> <out.png>
```

The Software update app (`com.oplus.ota`) keeps its OS logotype as a **PNG**, not
a vector, so the wordmark `Brand.java` produces has to be rasterised for that
overlay. Canvas size and ink height are explicit because the stock intrinsic size
has to be preserved: the `ImageView` is `wrap_content` with `centerInside`, so
changing the intrinsic size changes the layout around it.

| stock resource | canvas | ink | colour |
| --- | --- | --- | --- |
| `logo_coloros_dark_16_1` | 438×138 | 378×78 | `#FFE5AE` |
| `logo_coloros_dark`, `logo_coloros` | 378×78 | 378×78 | `#FFFFFF` |

```sh
D=devices/common/rro/BrinaOSUpdateApp/res/drawable
java Brand.java coloros_paths.txt BrinaOS "#FFFFE5AE" wm.xml
java Logo.java wm.xml 438 138 78 "#FFE5AE" $D/logo_coloros_dark_16_1.png
```

The `16` above the wordmark is `kv_16_1`, left alone — it is a WebP and there is
no WebP encoder on this machine. The background is `Kv.java`'s job.

---

## padvec.py — the wordmark refitted to another vector's box

```sh
python3 devices/common/rro/tools/padvec.py <src.xml> <wDp> <hDp> <#AARRGGBB> <out.xml>
```

`logo_oxygenos` and `logo_oxygenos_dark` are vectors rather than PNGs, and their
box is 137×26dp against the wordmark's own 159.61×34. Scaling ours to fill that
box would squash the letterforms, so `padvec.py` widens the *viewport* to the
target's aspect and centres the wordmark inside it: the ink keeps its shape, and
the drawable keeps the intrinsic size the layout is built around.

Both variants get the light wordmark. Stock uses black ink for the light-mode
local-update case, which reads fine on stock's flat card and disappears on a
photo — the same reason OPPO ships `logo_coloros` and `logo_coloros_dark` as the
same white file.

---

## Kv.java — the Software update key visual

```sh
java Kv.java <src> <out> <canvasW> <canvasH> <windowW> <bias> [quality] [scrim]
```

This one is easy to get wrong, and was. The KV `ImageView` in
`res/layout/logo_area.xml` is a **fixed 600dp × 503dp** with `scaleType`
`centerCrop`, sitting in a `COUICardView` the parent squeezes down to the card
width — 312dp on a phone. The `ImageView` keeps its 600dp; the card just *clips*
it. So only the middle 312/600 = **52%** of the artwork is ever on screen. Stock
is 1800×1509, which is exactly 600×503dp at 3×, which is why stock looks 1:1 with
its middle half showing.

A replacement sized to the visible window is therefore wrong twice over:
`centerCrop` scales it up to 600dp wide first, and the card then shows the middle
half of *that* — a ~1.9× zoom. The first attempt shipped 928×1509 for exactly that
reason and came out looking like a close crop of the photo.

So the canvas is the full **1800×1509**, the photo is framed inside the middle
**936** pixels, and the margins are filled with a blurred, darkened cover of the
same photo — invisible on a phone, a soft continuation on any layout that gives
the card more width.

`bias` is the horizontal focus (0 = left edge, 1 = right edge); the photo is
taller than the window, so its full height is always kept and there is no
vertical choice to make.

```sh
D=devices/common/rro/BrinaOSUpdateApp/res/drawable
S="0:0.25,0.20:0.46,0.52:0.46,0.68:0.22,0.84:0.46,1:0.50"
java Kv.java photo.jpg $D/kv_bg_16_1.jpg 1800 1509 936 0.5 0.86 "$S"
```

The scrim stops are the card's text bands: the version number, the wordmark and
the device name sit between 21% and 52% of the height, the status line between
85% and 94%.

`getBgDrawable()` picks the background by brand, OS version and whether this is
a local-package install, so every one of its outcomes gets the same file:

| resource | when the app picks it |
| --- | --- |
| `kv_bg_16_1` | ColorOS 16.1 |
| `kv_bg_16` | ColorOS 16.0 |
| `kv_bg_16_oxygen` | brand reports `oneplus-exp` |
| `kv_bg_16_realme` | brand reports `realme`, version 16 |
| `bg15_realme` | brand reports `realme`, older version |
| `bg_local`, `bg_local_black` | installing a package from storage |

The realme wordmarks are deliberately **not** overridden: their canvases
(441×78, 384×300) imply lockups this port never ships, and guessing at their
geometry would move the layout for no gain.

---

## mkai.py — the BrinaAI strings

```sh
python3 devices/common/rro/tools/mkai.py      # run from the toolkit root
```

Renames OPPO AI to BrinaAI in `com.oplus.pantanal.ums` — the Settings row
(`setting_name_*`), the page title (`ai_setting_header_title*`) and the tagline
under it (`ai_setting_header_subtitle*`).

The catch, and the reason this is generated rather than written by hand: **an RRO
does not win by being an overlay, it wins by being the best configuration
match.** UMS ships all nine strings in 74 locales, so on an en-GB phone the
target's own `en-rGB` value beats an overlay carrying only a default one, and the
row keeps saying OPPO AI. The overlay therefore repeats itself in every locale
the target defines, which is what the script generates — reading the locale list
straight out of `UMS.apk` so it stays right when the target changes.

Drawables were never affected by this: the KV artwork and the logotypes have a
single default-configuration entry each.

## MockUpdate.java — see the update card before flashing it

```sh
java MockUpdate.java <card.jpg> <wordmark.png> <out.png> [windowW]
```

Same idea as `Mock.java`, geometry read off `res/layout/logo_area.xml`. Run it
from the toolkit root; it reads `OPSans-En-Regular.ttf` out of the port tree.
Pass `windowW` — 936 for a phone — to get what the card actually shows rather
than the whole 1800-wide artwork; see `Kv.java` above for why they differ.

## mkfix.py — the status bar data-type icons

```sh
python3 devices/common/rro/tools/mkfix.py      # run from the toolkit root
```

Patches `prebuilt/DualRowStatusBar/PuiThemeStatusIcon.apk` in place. It is
idempotent: glyphs that already carry the right inset are skipped, and if all of
them do the APK is not rewritten.

SystemUI puts `mobile_signal` (the bars) and `mobile_type` (the G/E/3G/4G/5G/LTE
glyph) in **one FrameLayout**, both `wrap_content`, both
`layout_gravity="end|center_vertical"` — see
`res/layout/oplus_status_bar_mobile_signal_group_big_fiveg.xml`. Stock gets away
with stacking them because stock art keeps the glyph in the top-left of its
canvas and the bars in the bottom-right, so the two interleave. The module's
dual-row bars fill their canvas edge to edge, and its glyphs still carry the
stock 1.5–9dp right inset, so every one of them sits on top of the bars.

The tool rewrites only the insets:

* `insetRight` = width of the bars (24dp, measured off the module's own
  `stat_signal_signal_lte_single_4`) + `GAP` (2dp), which puts every glyph clear
  of the bars with the same gap;
* `insetLeft` pads each one back out to the width of the widest glyph, so the
  cluster — and everything to its left in the status bar — does not jump
  sideways when the network type changes.

### Why it patches the module instead of overlaying it

The first attempt was a separate RRO, `BrinaOSDualRowSignal`, carrying the same
19 vectors at priority 9000 against the module's 800. It changed nothing on the
phone, and the reason is the same rule that broke the BrinaAI strings:
**configuration match is decided before priority.**

The module keeps its bars in `res/drawable` but its type glyphs in
`res/drawable-xxhdpi`. An overlay offering `drawable/stat_signal_connected_g_lte_big`
is a default-config entry; on any device that reports a density the module's
`-xxhdpi` entry is the better match and wins outright, whatever the priorities
say. Matching the qualifier would have worked, but then two packages would carry
the same 19 drawables and the ordering would have to stay right forever. Editing
the module leaves one copy of each glyph and no question to get wrong.

Re-run it after dropping a newer build of the module into `prebuilt/` — every
number is measured off the APK, not hardcoded.

## mkwizard.sh — the setup wizard

```sh
bash devices/common/rro/tools/mkwizard.sh [photo.jpg] [crest.png]
```

Regenerates everything in `BrinaOSSetupWizard`. The wizard is `com.coloros.bootreg`
and it runs once, on first boot and after a wipe, so testing any of this means
factory resetting.

**`mklottie.py` — the last page.** Before the Get started button, the wizard
strokes the word "ColorOS" on as a Lottie animation, `raw/complete_page_logo`
(and `_id`, the Indonesian cut). There is no string to override, so the overlay
ships a replacement composition instead: the BrinaOS wordmark as an embedded
base64 PNG, wiped on left to right behind a slanted mask. Canvas, frame rate and
length are copied from the stock file — 1080×1329 at 60fps, frames 0–50 — so the
page's layout and timing are unchanged.

The stock ink measures 643×149 centred at (486, 597) in that canvas, which is
where the 640dp width and the (540, 597) centre in the script come from. The
wordmark is black to match; the last page is a light card.

**`Guide.java` — the welcome page.** `drawable/ic_bg_guide_page` sits behind the
whole first page, and the wizard writes "Hello" over it in `@color/Black` with no
scrim and no text shadow, so the replacement has to stay light. It is a champagne
gradient with the photo washed across the top at low opacity and faded out well
above the text, and the crest set underneath as a watermark. The photo is lifted
towards the paper colour before it is blended — a straight low-opacity wash of it
reads as grey dirt over cream rather than as a print.

## Compose.java — see the signal cluster before flashing it

```sh
java Compose.java <bars.txt> <type.txt> <out.png>
```

Each `.txt` is six lines: `viewportW`, `viewportH`, `widthDp`, `heightDp`,
`insetRightDp`, `pathData`. It stacks them the way the FrameLayout does, drawing
the type glyph in red so a collision is impossible to miss.
