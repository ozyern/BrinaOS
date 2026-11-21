#!/usr/bin/env python3
"""Rebuild an APK from the stock one, taking only classes*.dex from a patched build.

APKEditor/apktool resource rebuilds corrupt Android 17 framework references
(e.g. @android:color/system_on_secondary_fixed_dark becomes an invalid ?attr),
which crash-loops SystemUI.  Smali patches only touch dex, so keep stock
resources.arsc/res and swap the dex files.  Run zipalign -p 4 afterwards.

usage: apk_swap_dex.py STOCK.apk PATCHED.apk OUT.apk
"""
import re, sys, zipfile

stock, patched, out = sys.argv[1:4]
with zipfile.ZipFile(stock) as zs, zipfile.ZipFile(patched) as zp, zipfile.ZipFile(out, "w") as zo:
    pnames = set(zp.namelist())
    snames = set()
    for info in zs.infolist():
        snames.add(info.filename)
        swap = re.fullmatch(r"classes\d*\.dex", info.filename) and info.filename in pnames
        ni = zipfile.ZipInfo(info.filename, info.date_time)
        ni.compress_type = info.compress_type
        ni.external_attr = info.external_attr
        zo.writestr(ni, (zp if swap else zs).read(info.filename))
    for name in sorted(pnames - snames):
        if re.fullmatch(r"classes\d*\.dex", name):
            ni = zipfile.ZipInfo(name, (2009, 1, 1, 0, 0, 0))
            zo.writestr(ni, zp.read(name))
