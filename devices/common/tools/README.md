# common/tools

Authoring tools for the parts of BrinaOS that are not overlays. Nothing here
runs during a port — `brina.sh` only copies the finished
`devices/common/bootanimation.zip` and `rbootanimation.zip` into place.

| tool | what it feeds |
| --- | --- |
| `Boot.java` | the boot and shutdown animation frames |
| `mkboot.sh` | runs it and packs both zips |

The overlay tooling lives in `devices/common/rro/tools/`.

---

## mkboot.sh

```sh
bash devices/common/tools/mkboot.sh [crest.png]
```

Rebuilds both zips from the crest artwork and the BrinaOS wordmark, and prints
their sizes. `brina.sh` copies them over every `bootanimation.zip` /
`rbootanimation.zip` under `my_product/media/bootanimation/`, including the
`ATT_MX` and `Telcel` carrier subdirectories — those carry their own copies, and
a phone with one of those SIMs would otherwise boot OPPO's.

## The geometry

ColorOS's bootanimation draws a **band**, not a screen. The stock `desc.txt` is:

```
g 1440 777 0 688 60
```

— a 1440×777 strip placed 688px down a 1440-wide framebuffer, `part0` once then
`part1` forever. BrinaOS keeps that geometry exactly (at 30fps rather than 60,
see below), so the animation lands where OPPO's did whatever resolution the
panel happens to be running at.

The shutdown animation uses **the same band**, not the stock `g 1440 206 0 977`.
Stock only ever draws a small wordmark on power-off, and 206px has no room for
the crest; sharing the band is what lets the same lockup fade away in the same
place it faded in.

Everything in the zip must be **stored, not deflated** — `zip -0`. The frames are
mmapped.

## The frames

`Boot.java` renders them:

```sh
java Boot.java boot     <crest.png> <wordmark.png> <outDir> <w> <h> <n0> <n1>
java Boot.java shutdown <wordmark.png> <outDir> <w> <h> <n0> <n1>
```

The crest is gold on black with no alpha channel, so it is unmatted on load:
alpha becomes `max(r,g,b)` and the colour is divided back out by it. Composited
over black that is pixel-for-pixel the original, but it also gives a real alpha
channel to scale, blur and mask with — which is what the halo and the sheen
need.

Boot's `part0` fades and scales the crest in under a blooming halo, sweeps a
diagonal highlight across it, and wipes the wordmark on left to right. `part1`
loops a slow breathing glow with one sheen pass, written on `t = f / count`
rather than `f / (count - 1)` so the last frame runs into the first without a
hitch.

Shutdown is the same `Lockup` — same art, same position, same 0.18 resting glow
the boot loop sits at — driven by the opposite curves: one last sheen, a bloom,
then everything fades and settles back a fraction. The wordmark leaves first so
the crest is the last thing on screen. Its `part1` is two black frames, so a slow
power-off just holds on black instead of looping something back into view.

## Why 30fps and 256 colours

Frame count and frame size are the whole budget. At 60fps and truecolour the zip
came to 28MB against the stock 13MB — big enough to matter on `my_product`.

The animation is one gold ramp over black, so a palette costs nothing visually:
`Boot.java` median-cuts a sample of the frames down to 256 colours and writes
indexed PNGs. That plus 30fps lands boot at **8.7MB** and shutdown at **2.1MB**,
with 48 + 60 frames and 40 + 2 respectively — 10.8MB against the 13.5MB the two
stock zips came to.
