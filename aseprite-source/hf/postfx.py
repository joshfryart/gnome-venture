#!/usr/bin/env python3
"""Turn a generated image into hard-pixel 64x64 art in the project's style.

  python3 postfx.py in.png out.png [--palette palette.json] [--size 64]
  python3 postfx.py --make-palette DIR palette.json     (from finished art, top colours)

Steps: key out the magenta background -> box downscale -> binarise alpha -> snap to palette
-> remove orphan pixels -> 1 px #000000 border on 4-adjacent transparent pixels.
"""
import argparse, json, sys
from collections import Counter
from pathlib import Path
from PIL import Image

KEY = (255, 0, 255)
BLACK = (0, 0, 0)
NB4 = ((1, 0), (-1, 0), (0, 1), (0, -1))

def make_palette(folder, n=128):
    c = Counter()
    for f in Path(folder).glob("*.png"):
        im = Image.open(f).convert("RGBA")
        data = im.get_flattened_data() if hasattr(im, "get_flattened_data") else im.getdata()
        c.update(p[:3] for p in data if p[3] == 255 and p[:3] != BLACK)
    return [list(k) for k, _ in c.most_common(n)]

def dist(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b))

def snap(rgb, pal):
    return min(pal, key=lambda q: dist(rgb, q))

def run(im, pal, size=64):
    im = im.convert("RGB")
    big = im.size[0]
    # background mask at full res, before any blending
    keyed = Image.new("L", im.size, 255)
    kp, ip = keyed.load(), im.load()
    for y in range(big):
        for x in range(big):
            r, g, b = ip[x, y]
            if r > 170 and b > 170 and g < 110 and abs(r - b) < 90:
                kp[x, y] = 0
    rgb = im.resize((size, size), Image.BOX)
    a = keyed.resize((size, size), Image.BOX)
    px = {}
    for y in range(size):
        for x in range(size):
            if a.getpixel((x, y)) >= 128:
                px[(x, y)] = tuple(snap(rgb.getpixel((x, y)), pal))
    # orphan pixels: no 4-neighbour of the same colour -> take the commonest neighbour colour
    for _ in range(2):
        for (x, y), col in list(px.items()):
            ns = [px[(x + dx, y + dy)] for dx, dy in NB4 if (x + dx, y + dy) in px]
            if ns and col not in ns:
                px[(x, y)] = Counter(ns).most_common(1)[0][0]
            elif not ns:
                del px[(x, y)]
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    o = out.load()
    for (x, y), col in px.items():
        o[x, y] = col + (255,)
    for y in range(size):
        for x in range(size):
            if (x, y) in px: continue
            if any((x + dx, y + dy) in px for dx, dy in NB4):
                o[x, y] = BLACK + (255,)
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src"); ap.add_argument("dst")
    ap.add_argument("--palette", default=str(Path(__file__).with_name("palette.json")))
    ap.add_argument("--size", type=int, default=64)
    ap.add_argument("--make-palette", action="store_true")
    a = ap.parse_args()
    if a.make_palette:
        Path(a.dst).write_text(json.dumps(make_palette(a.src)))
        print("palette written", a.dst); return
    pal = [tuple(c) for c in json.loads(Path(a.palette).read_text())]
    run(Image.open(a.src), pal, a.size).save(a.dst)

if __name__ == "__main__":
    main()
