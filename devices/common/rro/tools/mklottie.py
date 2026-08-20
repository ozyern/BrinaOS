#!/usr/bin/env python3
"""
Builds the BrinaOS wordmark animation for the setup wizard's last page.

com.coloros.bootreg draws the "ColorOS" lettering there as a Lottie animation
(raw/complete_page_logo), stroking each letter on in turn. There is no way to
retype that from an overlay, so this writes a replacement composition: the
BrinaOS wordmark as an embedded PNG, wiped on left to right behind a slanted
mask, with the same canvas, frame rate and length as the stock file so the page
timing and layout are unchanged.

    python3 mklottie.py <wordmark.png> <out.json>

The wordmark PNG must be the ink cropped to its own bounds - the geometry below
is measured off the stock composition and assumes no padding.
"""
import base64
import json
import sys

# Measured off res/VI.json: the stock "ColorOS" ink is 643.3 x 149.3 centred at
# (486.4, 597.4) in a 1080x1329 canvas. Ours is centred properly instead.
CANVAS_W, CANVAS_H = 1080, 1329
FR, LAST = 60, 50
INK_W = 640.0
CENTRE = (540.0, 597.0)

src, out = sys.argv[1], sys.argv[2]
png = open(src, 'rb').read()

# PNG header: width and height are big-endian ints at byte 16.
pw = int.from_bytes(png[16:20], 'big')
ph = int.from_bytes(png[20:24], 'big')
scale = INK_W / pw * 100.0


def rect(x0, x1, slant):
    """A parallelogram in image space, leaning right so the wipe reads diagonally."""
    v = [[x0, 0], [x1 + slant, 0], [x1, ph], [x0 - slant, ph]]
    return {'i': [[0, 0]] * 4, 'o': [[0, 0]] * 4, 'v': v, 'c': True}


slant = ph * 0.55
anim = {
    'v': '5.12.1', 'fr': FR, 'ip': 0, 'op': LAST, 'w': CANVAS_W, 'h': CANVAS_H,
    'nm': 'BrinaOS', 'ddd': 0,
    'assets': [{
        'id': 'wordmark', 'w': pw, 'h': ph, 'u': '', 'e': 1,
        'p': 'data:image/png;base64,' + base64.b64encode(png).decode('ascii'),
    }],
    'layers': [{
        'ddd': 0, 'ind': 1, 'ty': 2, 'nm': 'BrinaOS', 'refId': 'wordmark', 'sr': 1,
        'ks': {
            'o': {'a': 1, 'k': [
                {'i': {'x': [0.6], 'y': [1]}, 'o': {'x': [0.4], 'y': [0]}, 't': 0, 's': [0]},
                {'t': 8, 's': [100]},
            ], 'ix': 11},
            'r': {'a': 0, 'k': 0, 'ix': 10},
            'p': {'a': 0, 'k': [CENTRE[0], CENTRE[1], 0], 'ix': 2, 'l': 2},
            'a': {'a': 0, 'k': [pw / 2.0, ph / 2.0, 0], 'ix': 1, 'l': 2},
            # settles the last couple of percent as the wipe finishes
            's': {'a': 1, 'k': [
                {'i': {'x': [0.2, 0.2, 0.2], 'y': [1, 1, 1]},
                 'o': {'x': [0.4, 0.4, 0.4], 'y': [0, 0, 0]},
                 't': 0, 's': [scale * 0.965, scale * 0.965, 100]},
                {'t': 42, 's': [scale, scale, 100]},
            ], 'ix': 6, 'l': 2},
        },
        'ao': 0, 'hasMask': True,
        'masksProperties': [{
            'inv': False, 'mode': 'a', 'nm': 'wipe', 'x': {'a': 0, 'k': 0, 'ix': 4},
            'o': {'a': 0, 'k': 100, 'ix': 3},
            'pt': {'a': 1, 'k': [
                {'i': {'x': 0.55, 'y': 1}, 'o': {'x': 0.35, 'y': 0}, 't': 3,
                 's': [rect(-slant - 4, -slant - 4, slant)]},
                {'t': 40, 's': [rect(-slant - 4, pw + slant + 4, slant)]},
            ], 'ix': 1},
        }],
        'ip': 0, 'op': LAST, 'st': 0, 'bm': 0,
    }],
    'markers': [],
}

with open(out, 'w', encoding='utf-8') as fh:
    json.dump(anim, fh, separators=(',', ':'))
print('wrote %s  %dx%d ink at %.1f%% -> %.0f wide, %d bytes'
      % (out, pw, ph, scale, INK_W, len(json.dumps(anim))))
