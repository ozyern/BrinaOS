#!/usr/bin/env python3
"""Append a kernel cmdline argument to a vendor_boot image, in place.

The vendor_boot v3/v4 header keeps cmdline in a fixed 2048-byte NUL-padded
field at offset 28, so appending an argument rewrites only that field. Nothing
before or after it moves, which means the vendor ramdisk and the dtb are
untouched - no unpack/repack round trip and no chance of dropping the
first-stage modules.

  usage: patch_bootarg.py <vendor_boot.img> <arg> [<arg> ...]

Exits 0 and changes nothing if every argument is already present.
"""
import sys
import struct

CMDLINE_OFF = 28
CMDLINE_LEN = 2048


def main(argv):
    if len(argv) < 3:
        print(__doc__.strip())
        return 2

    path, args = argv[1], argv[2:]

    with open(path, "rb") as fh:
        data = bytearray(fh.read())

    if data[:8] != b"VNDRBOOT":
        print("FATAL: %s is not a vendor_boot image (magic=%r)" % (path, bytes(data[:8])))
        return 1

    hdr_ver = struct.unpack("<I", data[8:12])[0]
    if hdr_ver not in (3, 4):
        print("FATAL: unsupported vendor_boot header version %d" % hdr_ver)
        return 1

    field = data[CMDLINE_OFF:CMDLINE_OFF + CMDLINE_LEN]
    cmdline = field.split(b"\x00")[0].decode("utf-8")

    missing = [a for a in args if a not in cmdline.split()]
    if not missing:
        print("cmdline already has %s - unchanged" % " ".join(args))
        return 0

    new = (cmdline + " " + " ".join(missing)).strip()
    encoded = new.encode("utf-8")
    if len(encoded) + 1 > CMDLINE_LEN:
        print("FATAL: cmdline would be %d bytes, field holds %d" % (len(encoded) + 1, CMDLINE_LEN))
        return 1

    data[CMDLINE_OFF:CMDLINE_OFF + CMDLINE_LEN] = encoded.ljust(CMDLINE_LEN, b"\x00")

    with open(path, "wb") as fh:
        fh.write(data)

    print("added: %s" % " ".join(missing))
    print("cmdline is now: %s" % new)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
