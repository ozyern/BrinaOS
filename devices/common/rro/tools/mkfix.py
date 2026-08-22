#!/usr/bin/env python3
"""
Patches PuiThemeStatusIcon.apk so its data-type glyphs stop landing on top of
its own signal bars.

Why they collide: SystemUI puts mobile_signal (the bars) and mobile_type (the
G/E/3G/4G/5G glyph) in the same FrameLayout, both wrap_content and both
layout_gravity="end|center_vertical". Stock gets away with stacking them because
the stock art keeps the glyph in the top-left of its canvas and the bars in the
bottom-right, so the two interleave. The module's bars fill their canvas - that
is what makes them dual-row - and its glyphs still carry the stock 1.5-9dp right
inset, so every one of them ends up inside the bars.

The fix is to push each glyph left of the bars with an insetRight of
barsWidth + GAP, and to pad the narrow ones on the left so they all keep the
same intrinsic width - otherwise the cluster, and everything to its left in the
status bar, would jump sideways every time the network type changed. Nothing
else about the art is touched.

Why this patches the module rather than overlaying it: the module keeps its
glyphs in res/drawable-xxhdpi and its bars in res/drawable. A separate RRO can
outrank the module on priority and still lose, because configuration match is
decided before priority - a density-qualified entry beats a default-config one
on any device that reports a density. Overriding drawable/stat_signal_connected_*
from an overlay therefore had no effect at all on an xxhdpi panel. Editing the
module leaves one copy of each glyph and no ordering question.

    python3 devices/common/rro/tools/mkfix.py     # run from the toolkit root

It always decompiles PuiThemeStatusIcon.apk.orig - the pristine, unpatched
module APK kept beside the output - and writes PuiThemeStatusIcon.apk, so
running it twice can never compound apktool round-trips (an earlier priority
bump did exactly that and knocked the whole overlay out on a clean install).
To move to a newer build of the module, drop it in as BOTH .apk and .orig,
then run this once.
"""
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile

APK = 'devices/common/rro/prebuilt/DualRowStatusBar/PuiThemeStatusIcon.apk'
# Pristine, unpatched copy of the module APK. mkfix always decompiles this, never
# the output APK, so repeated runs cannot compound apktool round-trips. Restored
# once from the source module; if it is missing we fall back to APK itself.
ORIG = APK + '.orig'
APKTOOL = 'bin/apktool/apktool.jar'
APKSIGNER = 'otatools/bin/apksigner'
KEY = 'otatools/key/testkey.pk8'
CERT = 'otatools/key/testkey.x509.pem'
# Leave the overlay's own priority (800) alone. It is what shipped and what
# works: at 800 every signal/wifi/5G/notification icon themes correctly on the
# device. Bumping it to 9000 made the whole overlay stop applying on a clean
# install (only the untouched battery overlays survived), so priority is not the
# lever here - configuration match is, and the type glyphs already sit in
# drawable-xxhdpi. mkfix therefore does not touch the manifest at all.
BARS = 'res/drawable/stat_signal_signal_lte_single_4.xml'
GLYPHS = ('stat_signal_connected_', 'stat_sys_data_fully_connected_')
GAP = 4.0        # dp between the glyph and the first bar (was 2; a touch more air)


def run(*args):
    r = subprocess.run(args, capture_output=True, text=True)
    if r.returncode:
        sys.exit('%s failed:\n%s%s' % (args[0], r.stdout[-2000:], r.stderr[-2000:]))
    return r.stdout


def dp(text, attr, default=0.0):
    m = re.search(r'android:%s="([0-9.]+)dip"' % attr, text)
    return float(m.group(1)) if m else default


def num(x):
    return ('%.4f' % x).rstrip('0').rstrip('.')


def glyph_files(root):
    out = []
    for path in sorted(glob.glob(os.path.join(root, 'res', 'drawable*', '*.xml'))):
        if os.path.basename(path)[:-4].startswith(GLYPHS):
            out.append(path)
    return out


def set_inset(text, left, right):
    """Rewrite the root <inset>'s left and right, leaving top and bottom alone."""
    head = text.index('<inset')
    tail = text.index('>', head)
    tag = text[head:tail]
    for attr, value in (('insetLeft', left), ('insetRight', right)):
        pat = r'android:%s="[0-9.]+dip"' % attr
        new = 'android:%s="%sdip"' % (attr, num(value))
        tag = re.sub(pat, new, tag) if re.search(pat, tag) else \
            tag.replace('<inset', '<inset ' + new, 1)
    return text[:head] + tag + text[tail:]


def main():
    work = tempfile.mkdtemp()
    src = os.path.join(work, 'src')
    base = ORIG if os.path.exists(ORIG) else APK
    try:
        run('java', '-jar', APKTOOL, 'd', '-f', '-o', src, base)
        print('patching from %s' % base)

        bars_xml = open(os.path.join(src, BARS), encoding='utf-8').read()
        bars = dp(bars_xml, 'insetLeft') + dp(bars_xml, 'insetRight') + dp(bars_xml, 'width')
        print('signal bars are %s dp wide' % num(bars))

        files = glyph_files(src)
        if not files:
            sys.exit('no data-type glyphs in %s - has the module changed?' % APK)

        ink = {}
        for path in files:
            text = open(path, encoding='utf-8').read()
            # the vector's own width is the ink; the inset box is wider
            m = re.search(r'<vector[^>]*android:width="([0-9.]+)dip"', text)
            if not m:
                sys.exit('%s is not the expected inset>vector' % os.path.basename(path))
            ink[path] = float(m.group(1))

        widest = max(ink.values())
        right = bars + GAP
        print('widest glyph is %s dp, insetRight becomes %s dp for all of them'
              % (num(widest), num(right)))

        done = 0
        for path in files:
            text = open(path, encoding='utf-8').read()
            if abs(dp(text, 'insetRight') - right) < 0.001:
                done += 1
                continue
            left = widest - ink[path]
            open(path, 'w', encoding='utf-8').write(set_inset(text, left, right))
            print('  %-44s ink %7s dp, insetLeft %7s dp'
                  % (os.path.basename(path)[:-4], num(ink[path]), num(left)))

        if done:
            print('  (%d of %d already had the right inset)' % (done, len(files)))

        unsigned = os.path.join(work, 'unsigned.apk')
        run('java', '-jar', APKTOOL, 'b', src, '-o', unsigned)
        run(APKSIGNER, 'sign', '--key', KEY, '--cert', CERT,
            '--v4-signing-enabled', 'false', '--out', APK, unsigned)
        print('%s rewritten, %d bytes' % (APK, os.path.getsize(APK)))
    finally:
        shutil.rmtree(work, ignore_errors=True)


main()
