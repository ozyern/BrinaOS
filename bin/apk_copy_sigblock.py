#!/usr/bin/env python3
"""Copy the APK Signing Block of a stock APK into a rebuilt one.

apk_swap_dex.py rewrites the zip entry by entry, which drops the stock
APK Signing Block (v2/v3 signatures live outside the zip entries). A COS17
system APK like SystemUI is v3-only signed, so the result had no signature at
all and PackageManager refused to install it: com.android.systemui missing at
boot -> no status bar, lockscreen or gesture navigation.

PackageManager does not check the digests of preinstalled system APKs at boot,
only reads their certificates, so the stock block (now with stale digests, the
same state every APKEditor-patched app in the port is in) keeps the platform
signature. Run this AFTER zipalign: zipalign rewrites the zip and would drop
the block again.

usage: apk_copy_sigblock.py STOCK.apk APK  (APK is modified in place)
"""
import struct, sys

MAGIC = b"APK Sig Block 42"


def eocd(data):
    i = data.rfind(b"PK\x05\x06", max(0, len(data) - 65557))
    if i < 0:
        sys.exit("no end of central directory record")
    cd_size, cd_off = struct.unpack_from("<II", data, i + 12)
    if cd_off == 0xFFFFFFFF:
        sys.exit("zip64 is not supported")
    return i, cd_size, cd_off


def sigblock(data):
    _, _, cd_off = eocd(data)
    if data[cd_off - 16:cd_off] != MAGIC:
        return None
    size = struct.unpack_from("<Q", data, cd_off - 24)[0]
    start = cd_off - size - 8
    if struct.unpack_from("<Q", data, start)[0] != size:
        sys.exit("malformed APK Signing Block")
    return data[start:cd_off]


stock_path, apk_path = sys.argv[1:3]
stock = open(stock_path, "rb").read()
apk = open(apk_path, "rb").read()
block = sigblock(stock)
if block is None:
    sys.exit(f"{stock_path} has no APK Signing Block (v1-only?), nothing to copy")
if sigblock(apk) is not None:
    sys.exit(f"{apk_path} already has an APK Signing Block")
e, cd_size, cd_off = eocd(apk)
if cd_off + cd_size != e:
    sys.exit("central directory is not directly before EOCD")
out = bytearray(apk[:cd_off] + block + apk[cd_off:])
struct.pack_into("<I", out, e + len(block) + 16, cd_off + len(block))
open(apk_path, "wb").write(out)
print(f"copied {len(block)} byte APK Signing Block from {stock_path}")
