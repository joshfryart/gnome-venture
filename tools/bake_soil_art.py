#!/usr/bin/env python3
"""Bake the bed-soil states that had no picture (Hearth Pop v3) from the tilled-soil tile -> game/assets/img/ph/tile-soil-{planted,thirsty,ready}.png (64x64).
  planted : damp, darker soil with a faint shine (a watered bed with something growing in it)
  thirsty : pale, dusty soil with fine cracks (growth is paused until it is watered)
  ready   : warm golden soil with a few sparkles (a crop to harvest)
The yard draws them behind the crop picture (see .yard .tile.planted in style.css).
Run: python3 -I tools/bake_soil_art.py   (needs Pillow)"""
import os
from PIL import Image
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PH = os.path.join(REPO, "game", "assets", "img", "ph"); T = 64
def hsh(a, b, s):
    n = (a * 374761393 + b * 668265263 + s * 2147483647) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535
def mix(c, t, k): return tuple(int(c[i] * (1 - k) + t[i] * k) for i in range(3))
def base(): return Image.open(os.path.join(PH, "tile-tilled.png")).convert("RGBA")
def planted():
    im = base(); p = im.load()
    for y in range(T):
        for x in range(T):
            r, g, b, a = p[x, y]; c = mix((int(r * .62), int(g * .6), int(b * .66)), (0x2a, 0x2a, 0x44), .08)
            p[x, y] = (*c, a)
    for i in range(34):   # damp glints on the ridges
        x, y = int(hsh(i, 1, 5) * 62) + 1, int(hsh(i, 2, 5) * 62) + 1
        if sum(p[x, y][:3]) > 150: p[x, y] = (0x6a, 0x6a, 0x84, 255)
    return im
def thirsty():
    im = base(); p = im.load()
    for y in range(T):
        for x in range(T):
            r, g, b, a = p[x, y]; c = mix((min(255, int(r * 1.12) + 22), min(255, int(g * 1.1) + 24), min(255, int(b * 1.08) + 22)), (0xd0, 0xb4, 0x88), .42)
            p[x, y] = (*c, a)
    for i in range(7):   # cracks: short jagged runs
        x, y = int(hsh(i, 3, 6) * 56) + 4, int(hsh(i, 4, 6) * 56) + 4; dx = 1 if hsh(i, 5, 6) > .5 else -1
        for k in range(5 + int(hsh(i, 6, 6) * 7)):
            if 0 <= x < T and 0 <= y < T: p[x, y] = (0x6e, 0x4a, 0x2e, 255)
            x += dx if hsh(i, k, 7) > .35 else 0; y += 1 if hsh(i, k, 8) > .45 else 0
    for i in range(30):   # dust
        x, y = int(hsh(i, 7, 9) * 64), int(hsh(i, 8, 9) * 64); p[x, y] = (0xe6, 0xd2, 0xa8, 255)
    return im
def ready():
    im = base(); p = im.load()
    for y in range(T):
        for x in range(T):
            r, g, b, a = p[x, y]; c = mix((min(255, int(r * 1.05)), min(255, int(g * 1.02)), int(b * .85)), (0xe0, 0xb0, 0x50), .30)
            p[x, y] = (*c, a)
    for i in range(7):   # sparkles: a plus of pale gold
        x, y = int(hsh(i, 1, 11) * 54) + 5, int(hsh(i, 2, 11) * 54) + 5
        for dx, dy, c in ((0, 0, (0xfb, 0xea, 0xa0)), (1, 0, (0xf0, 0xd0, 0x67)), (-1, 0, (0xf0, 0xd0, 0x67)), (0, 1, (0xf0, 0xd0, 0x67)), (0, -1, (0xf0, 0xd0, 0x67))): p[x + dx, y + dy] = (*c, 255)
    for i in range(22):
        x, y = int(hsh(i, 3, 12) * 64), int(hsh(i, 4, 12) * 64); p[x, y] = (0xf0, 0xd0, 0x67, 255)
    return im
def main():
    for n, fn in (("planted", planted), ("thirsty", thirsty), ("ready", ready)): fn().save(os.path.join(PH, f"tile-soil-{n}.png"), optimize=True)
    print("tile-soil-planted/thirsty/ready.png in", PH)
if __name__ == "__main__": main()
