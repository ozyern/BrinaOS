#!/usr/bin/env python3
"""Make libupdateprof.qti.so stop blocking on a missing AIDL qspmhal.

ColorOS 17's libupdateprof.qti.so asks for the AIDL
vendor.qti.qspmhal.IQspmhal/default with AServiceManager_waitForService before
it ever tries its HIDL fallback. Legacy vendors (Android 11 lahaina) only ship
the HIDL vendor.qti.qspmhal@1.0, so the call never returns. It runs on
system_server's display thread at boot-complete (GameGpuControlPanel), the
Watchdog kills system_server after ~67s and the framework soft-reboots every
couple of minutes.

The import is renamed to AServiceManager_checkService (same arguments,
returns at once) and its symbol version moved from LIBBINDER_NDK31 to
LIBBINDER_NDK, which is where libbinder_ndk exports checkService. The library
then falls through to the HIDL HAL.

usage: patch_qspm_waitforservice.py <libupdateprof.qti.so>
exit 0 = patched or already patched, 1 = unexpected layout (file untouched)
"""
import struct
import sys

OLD = b"AServiceManager_waitForService"
NEW = b"AServiceManager_checkService"
NEW_VERSION = b"LIBBINDER_NDK"

DT_STRTAB, DT_SYMTAB, DT_STRSZ, DT_VERSYM, DT_VERNEED, DT_VERNEEDNUM = 5, 6, 10, 0x6ffffff0, 0x6ffffffe, 0x6fffffff


def fail(msg):
    print("patch_qspm_waitforservice: " + msg, file=sys.stderr)
    sys.exit(1)


def main(path):
    d = bytearray(open(path, "rb").read())
    if d[:4] != b"\x7fELF" or d[4] != 2 or d[5] != 1:
        fail("not a little-endian ELF64 file")

    e_phoff, = struct.unpack_from("<Q", d, 0x20)
    e_phentsize, e_phnum = struct.unpack_from("<HH", d, 0x36)
    loads, dynamic = [], None
    for i in range(e_phnum):
        p_type, _, p_offset, p_vaddr, _, p_filesz, _, _ = struct.unpack_from("<IIQQQQQQ", d, e_phoff + i * e_phentsize)
        if p_type == 1:
            loads.append((p_vaddr, p_offset, p_filesz))
        elif p_type == 2:
            dynamic = (p_offset, p_filesz)
    if dynamic is None:
        fail("no PT_DYNAMIC")

    def off(vaddr):
        for v, o, sz in loads:
            if v <= vaddr < v + sz:
                return vaddr - v + o
        fail("address 0x%x not in a PT_LOAD" % vaddr)

    dyn = {}
    for i in range(dynamic[1] // 16):
        tag, val = struct.unpack_from("<qQ", d, dynamic[0] + i * 16)
        if tag == 0:
            break
        dyn.setdefault(tag, val)
    for tag in (DT_STRTAB, DT_SYMTAB, DT_STRSZ, DT_VERSYM, DT_VERNEED, DT_VERNEEDNUM):
        if tag not in dyn:
            fail("missing dynamic tag 0x%x" % tag)
    strtab, strsz = off(dyn[DT_STRTAB]), dyn[DT_STRSZ]
    symtab, versym = off(dyn[DT_SYMTAB]), off(dyn[DT_VERSYM])

    def cstr(o):
        return bytes(d[strtab + o:d.index(b"\0", strtab + o)])

    # version index of LIBBINDER_NDK from the libbinder_ndk.so verneed entry
    ver_index = None
    vn = off(dyn[DT_VERNEED])
    for _ in range(dyn[DT_VERNEEDNUM]):
        _, vn_cnt, vn_file, vn_aux, vn_next = struct.unpack_from("<HHIII", d, vn)
        if cstr(vn_file) == b"libbinder_ndk.so":
            va = vn + vn_aux
            for _ in range(vn_cnt):
                _, _, vna_other, vna_name, vna_next = struct.unpack_from("<IHHII", d, va)
                if cstr(vna_name) == NEW_VERSION:
                    ver_index = vna_other
                va += vna_next
        vn += vn_next
    if ver_index is None:
        fail("libbinder_ndk.so verneed has no LIBBINDER_NDK entry")

    # dynsym count: it ends where the string table starts in every lld/bfd
    # layout we have seen; stop at the first entry that runs past dynstr too
    nsym = (strtab - symtab) // 24 if strtab > symtab else 0
    if nsym <= 0:
        fail("cannot size .dynsym")
    names = [struct.unpack_from("<I", d, symtab + i * 24)[0] for i in range(nsym)]
    names = [n if n < strsz else None for n in names]

    hits = [i for i, n in enumerate(names) if n is not None and cstr(n) == OLD]
    done = [i for i, n in enumerate(names) if n is not None and cstr(n) == NEW]
    if not hits:
        if done:
            print("patch_qspm_waitforservice: already patched")
            return
        fail("no %s import" % OLD.decode())
    if len(hits) != 1:
        fail("%d %s symbols" % (len(hits), OLD.decode()))
    i = hits[0]
    so = names[i]
    st_info, st_other, st_shndx = struct.unpack_from("<BBH", d, symtab + i * 24 + 4)
    if st_shndx != 0:
        fail("%s is defined here, not imported" % OLD.decode())
    if any(j != i and n is not None and so < n < so + len(OLD) + 1 for j, n in enumerate(names)):
        fail("another symbol shares the string; refusing to rename it")

    d[strtab + so:strtab + so + len(OLD) + 1] = NEW + b"\0" * (len(OLD) + 1 - len(NEW))
    struct.pack_into("<H", d, versym + i * 2, ver_index)
    open(path, "wb").write(d)
    print("patch_qspm_waitforservice: %s -> %s@%s" % (OLD.decode(), NEW.decode(), NEW_VERSION.decode()))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        fail("usage: patch_qspm_waitforservice.py <libupdateprof.qti.so>")
    main(sys.argv[1])
