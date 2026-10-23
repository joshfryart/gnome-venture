#!/usr/bin/env python3
"""Headless stand-in for `Aseprite.exe -b --script file.lua`, for gvlib art scripts.

Implements only the slice of the Aseprite Lua API that gvlib/gvlib.lua uses (see aseshim_api.lua):
Image, Sprite (saveAs .aseprite, saveCopyAs .png), ColorMode, app.pixelColor, app.fs.
Paths that start with the Windows project root used by the existing scripts
(C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/) are remapped to aseprite-source/.

usage: python3 aseshim.py script.lua [more.lua ...]
"""
import os, struct, sys, zlib
from lupa import LuaRuntime

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)   # aseprite-source/
WIN_ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"


def fix(p):
    p = str(p).replace("\\", "/")
    return os.path.join(ROOT, p[len(WIN_ROOT):]) if p.startswith(WIN_ROOT) else p


class Img:
    def __init__(self, w, h):
        self.w, self.h = int(w), int(h)
        self.px = [0] * (self.w * self.h)          # packed ABGR ints, as Aseprite's rgba()

    def rgba_bytes(self):
        out = bytearray()
        for v in self.px:
            out += bytes((v & 255, (v >> 8) & 255, (v >> 16) & 255, (v >> 24) & 255))
        return bytes(out)


def png_bytes(im):
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    raw, row = im.rgba_bytes(), im.w * 4
    rows = b"".join(b"\x00" + raw[y * row:(y + 1) * row] for y in range(im.h))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", im.w, im.h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


def ase_bytes(im):
    """Minimal valid .aseprite (spec: github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md): 1 frame, 1 layer, 1 compressed cel."""
    def chunk(t, d): return struct.pack("<IH", len(d) + 6, t) + d
    name = b"Layer"
    layer = struct.pack("<HHHHHHB", 3, 0, 0, 0, 0, 0, 255) + b"\x00\x00\x00" + struct.pack("<H", len(name)) + name
    cel = struct.pack("<HhhBHh", 0, 0, 0, 255, 2, 0) + b"\x00" * 5 + struct.pack("<HH", im.w, im.h) + zlib.compress(im.rgba_bytes(), 9)
    body = chunk(0x2004, layer) + chunk(0x2005, cel)
    frame = struct.pack("<IHHH", len(body) + 16, 0xF1FA, 2, 100) + b"\x00\x00" + struct.pack("<I", 2)
    hdr = (struct.pack("<IHHHHHI", 0, 0xA5E0, 1, im.w, im.h, 32, 1) + struct.pack("<H", 100) + struct.pack("<II", 0, 0)
           + b"\x00" + b"\x00\x00\x00" + struct.pack("<H", 0) + b"\x01\x01" + struct.pack("<hhHH", 0, 0, 16, 16) + b"\x00" * 84)
    assert len(hdr) == 128 and len(frame) == 16
    return struct.pack("<I", 128 + len(frame) + len(body)) + hdr[4:] + frame + body


def main(argv):
    lua = LuaRuntime(unpack_returned_tuples=True)
    imgs = []

    def new_image(w, h):
        imgs.append(Img(w, h)); return len(imgs)
    def put(h, x, y, c):
        im = imgs[int(h) - 1]; x, y = int(x), int(y)
        if 0 <= x < im.w and 0 <= y < im.h: im.px[y * im.w + x] = int(c)
    def save(kind):
        def f(h, p):
            p = fix(p); os.makedirs(os.path.dirname(p) or ".", exist_ok=True)
            open(p, "wb").write((ase_bytes if kind == "ase" else png_bytes)(imgs[int(h) - 1]))
        return f
    P = lua.table_from({
        "new_image": new_image,
        "width": lambda h: imgs[int(h) - 1].w, "height": lambda h: imgs[int(h) - 1].h,
        "clear": lambda h, c: imgs[int(h) - 1].px.__setitem__(slice(None), [int(c)] * len(imgs[int(h) - 1].px)),
        "put": put, "get": lambda h, x, y: imgs[int(h) - 1].px[int(y) * imgs[int(h) - 1].w + int(x)],
        "save_ase": save("ase"), "save_png": save("png"),
        "mkdirs": lambda p: os.makedirs(fix(p), exist_ok=True), "fix": fix,
    })
    lua.execute(open(os.path.join(HERE, "aseshim_api.lua"), encoding="utf-8").read())
    lua.globals().ASESHIM_INSTALL(P)
    for s in argv:
        lua.execute(open(fix(s), encoding="utf-8").read().replace("\r\n", "\n"))


if __name__ == "__main__":
    main(sys.argv[1:])
