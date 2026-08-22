#!/usr/bin/env python3
"""
Generates locale-aware string overrides for the BrinaOSUpdateApp overlay,
replacing every "ColorOS" reference in the OTA app's user-visible strings.

Like mkai.py for the AI name, this has to repeat each override in every locale
the target defines for that string, or the target's own locale-specific value
wins over a default-only overlay.

    python3 devices/common/rro/tools/mkota.py    # run from the toolkit root

Reads the locales straight from the current OTA APK in the build tree.
"""
import glob
import os
import re
import sys

APK_DIR = None  # set by find_ota_source()
RRO_RES = 'devices/common/rro/BrinaOSUpdateApp/res'

# Strings to override and their replacements.
# key = resource name, value = (pattern, replacement) applied to the text.
OVERRIDES = {
    'card_title_coloros':     ('ColorOS', 'BrinaOS'),
    'card_title_coloros_new': ('ColorOS', 'BrinaOS'),
    'questionnaire_os':      ('ColorOS', 'BrinaOS'),
}


def find_ota_source():
    """Find the decompiled OTA strings, or the APK itself."""
    # If already decompiled at /tmp/ota_check, use that
    d = '/tmp/ota_check/res'
    if os.path.isdir(d):
        return d
    return None


def locales_with_string(res_root, name):
    """Return the list of values-* dirs (including plain 'values') that define `name`."""
    out = []
    for d in sorted(glob.glob(os.path.join(res_root, 'values*'))):
        sf = os.path.join(d, 'strings.xml')
        if not os.path.isfile(sf):
            continue
        text = open(sf, encoding='utf-8').read()
        if re.search(r'<string\s+name="%s"' % re.escape(name), text):
            out.append(os.path.basename(d))
    return out


def get_string_value(res_root, values_dir, name):
    """Extract the text content of a <string name="..."> element."""
    sf = os.path.join(res_root, values_dir, 'strings.xml')
    text = open(sf, encoding='utf-8').read()
    m = re.search(r'<string\s+name="%s">(.*?)</string>' % re.escape(name), text, re.DOTALL)
    return m.group(1) if m else None


def xml_header():
    return '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'


def xml_footer():
    return '</resources>\n'


def main():
    src = find_ota_source()
    if not src:
        sys.exit('OTA source not found. Decompile OTA.apk to /tmp/ota_check first.')

    total = 0
    for name, (pattern, replacement) in OVERRIDES.items():
        locales = locales_with_string(src, name)
        if not locales:
            print('  %s: not found in any locale, skipping' % name)
            continue

        for locale_dir in locales:
            orig = get_string_value(src, locale_dir, name)
            if orig is None:
                continue
            new_val = orig.replace(pattern, replacement)
            if new_val == orig:
                continue

            out_dir = os.path.join(RRO_RES, locale_dir)
            os.makedirs(out_dir, exist_ok=True)
            out_file = os.path.join(out_dir, 'strings.xml')

            # Read existing file or start fresh
            if os.path.isfile(out_file):
                content = open(out_file, encoding='utf-8').read()
                # Check if this string already exists
                if 'name="%s"' % name in content:
                    # Update it
                    content = re.sub(
                        r'<string\s+name="%s">.*?</string>' % re.escape(name),
                        '<string name="%s">%s</string>' % (name, new_val),
                        content, flags=re.DOTALL)
                else:
                    # Add before closing tag
                    content = content.replace('</resources>',
                        '    <string name="%s">%s</string>\n</resources>' % (name, new_val))
            else:
                content = xml_header()
                content += '    <string name="%s">%s</string>\n' % (name, new_val)
                content += xml_footer()

            open(out_file, 'w', encoding='utf-8').write(content)
            total += 1

        print('  %s: %d locale(s)' % (name, len(locales)))

    print('wrote %d string overrides to %s' % (total, RRO_RES))


main()
