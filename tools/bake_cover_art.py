#!/usr/bin/env python3
"""Bake the untilled-ground coverings (Hearth Pop v3), blended like the paths (see tools/bake_path_art.py).
Each untilled square is drawn with one covering over the yard's turf: lawn (loose details only), clover, wildflower, weeds, dry grass, leaf litter, moss or bare dirt.
Same-covering neighbours join (47 shapes each, ragged lit/shaded edges, hard pixels); other neighbours leave the turf showing. Textures wrap, so they continue across squares.
Writes game/assets/img/cover/<kind>-<mask>.png, cover/lawn-<1..6>.png and ph/tile-turf-big.png (a 256x256 wrapped turf for the whole yard).
Run: python3 -I tools/bake_cover_art.py   (needs Pillow)"""
import math, os, sys
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bake_path_art as B
REPO = B.REPO; OUT = os.path.join(REPO, "game", "assets", "img", "cover"); PH = os.path.join(REPO, "game", "assets", "img", "ph")
T = 64; hsh = B.hsh
def hx(c): return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5)) + (255,)
GR = ['#3f7a3e', '#5a9a48', '#76b455', '#97cc66']
def vnp(x, y, cell, seed, size):
    per = size // cell; gx, gy = x / cell, y / cell; x0, y0 = math.floor(gx), math.floor(gy); fx, fy = gx - x0, gy - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy); g = lambda a, b: hsh(a % per, b % per, seed)
    t = g(x0, y0) * (1 - fx) + g(x0 + 1, y0) * fx; b = g(x0, y0 + 1) * (1 - fx) + g(x0 + 1, y0 + 1) * fx
    return t * (1 - fy) + b * fy

def canvas(size): im = Image.new("RGBA", (size, size)); return im, im.load()
def fill(size, ramp, seed, cell=8, split=(.34, .55, .72)):
    im, px = canvas(size)
    for y in range(size):
        for x in range(size):
            v = vnp(x, y, cell, seed, size) * .8 + hsh(x, y, seed + 1) * .2
            i = 0 if v < split[0] else 1 if v < split[1] else 2 if v < split[2] else 3
            if i == 0 and hsh(x, y, seed + 2) > .5: i = 1
            px[x, y] = hx(ramp[i])
    return im, px
def put(px, size, x, y, c): px[x % size, y % size] = hx(c)
def scatter(n, seed, size): return [(int(hsh(i, 1, seed) * size), int(hsh(i, 2, seed) * size)) for i in range(n)]
def tuft(px, size, x, y, tall=False, ramp=GR, tip='#e2dc90'):
    for dy, c in ((0, ramp[0]), (-1, ramp[0]), (-2, ramp[1]), (-3, ramp[3])): put(px, size, x, y + dy, c)
    put(px, size, x - 1, y, ramp[0]); put(px, size, x - 2, y - 1, ramp[1]); put(px, size, x - 2, y - 2, ramp[3]); put(px, size, x + 1, y, ramp[0]); put(px, size, x + 2, y - 1, ramp[1]); put(px, size, x + 2, y - 2, ramp[2]); put(px, size, x + 2, y - 3, ramp[3])
    if tall: put(px, size, x, y - 4, ramp[3]); put(px, size, x, y - 5, tip); put(px, size, x - 1, y - 4, ramp[2])
def clover(px, size, x, y, c1='#4c9a50', c2='#6ac06a'):
    for dx, dy in ((0, 0), (2, 1), (-2, 1)): put(px, size, x + dx, y + dy, c1); put(px, size, x + dx + 1, y + dy, c2); put(px, size, x + dx, y + dy - 1, c2)
def flower(px, size, x, y, a, b):
    put(px, size, x, y + 3, GR[0]); put(px, size, x, y + 2, GR[1]); put(px, size, x, y + 1, GR[1])
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)): put(px, size, x + dx, y + dy, a)
    put(px, size, x, y, b)
def pebble(px, size, x, y):
    for dx, dy, c in ((0, 0, '#8a899a'), (1, 0, '#aaa9b8'), (2, 0, '#8a899a'), (0, 1, '#5d5c70'), (1, 1, '#8a899a'), (2, 1, '#5d5c70'), (1, -1, '#cfcfdc')): put(px, size, x + dx, y + dy, c)
FL = [('#f0d067', '#fbeaa0'), ('#f7f0e6', '#f0d067'), ('#e8809a', '#fbeaa0'), ('#b9a0e0', '#f7f0e6')]

def turf(size=256):
    im, px = canvas(size)
    for y in range(size):   # two scales of wrapped noise so the big yard has broad light and dark drifts as well as small patches
        for x in range(size):
            v = vnp(x, y, 32, 5, size) * .38 + vnp(x, y, 8, 3, size) * .42 + hsh(x, y, 4) * .2
            i = 0 if v < .38 else 1 if v < .52 else 2 if v < .66 else 3
            if i == 0 and hsh(x, y, 6) > .5: i = 1
            px[x, y] = hx(GR[i])
    for i, (x, y) in enumerate(scatter(95, 21, size)): tuft(px, size, x, y, i % 4 == 0)
    for x, y in scatter(40, 22, size): clover(px, size, x, y)
    for i, (x, y) in enumerate(scatter(26, 23, size)): flower(px, size, x, y, *FL[i % 4])
    for x, y in scatter(8, 24, size): pebble(px, size, x, y)
    return im

def tex_clover():
    im, px = fill(T, ['#4c9a50', '#5aa85a', '#76b455', '#8ac66a'], 31)
    for x, y in scatter(30, 32, T): clover(px, T, x, y, '#3f8a46', '#7ad47a')
    for x, y in scatter(5, 33, T): put(px, T, x, y, '#f7f0e6'); put(px, T, x + 1, y, '#f7f0e6'); put(px, T, x, y - 1, '#f0d067')
    return im
def tex_flowers():
    im, px = fill(T, GR, 41)
    for x, y in scatter(5, 42, T): tuft(px, T, x, y)
    for i, (x, y) in enumerate(scatter(15, 43, T)): flower(px, T, x, y, *FL[i % 4])
    return im
def tex_weeds():
    ramp = ['#2f6a3c', '#3f7a3e', '#4c9a50', '#76b455']
    im, px = fill(T, ramp, 51)
    for i, (x, y) in enumerate(scatter(20, 52, T)): tuft(px, T, x, y, i % 2 == 0, ramp, '#d8d488')
    for x, y in scatter(4, 53, T):
        put(px, T, x, y, '#fbeaa0'); put(px, T, x - 1, y, '#f7f0e6'); put(px, T, x + 1, y, '#f7f0e6'); put(px, T, x, y - 1, '#f7f0e6'); put(px, T, x, y + 1, GR[1])
    return im
def tex_dry():
    im, px = fill(T, ['#8a9a40', '#a8b050', '#c4c068', '#dcd488'], 61)
    for i, (x, y) in enumerate(scatter(26, 62, T)):
        for k in range(4): put(px, T, x + (k % 2) * (1 if i % 2 else -1), y - k, '#e8e0a0' if k > 1 else '#b89a4a')
    for x, y in scatter(7, 63, T): put(px, T, x, y, '#8a6a30'); put(px, T, x + 1, y, '#a8843c')
    return im
def tex_leaves():
    im, px = fill(T, ['#4a3a22', '#5d4a2a', '#6e5632', '#7a6038'], 71)
    cols = ['#c4762a', '#d89a3a', '#9a4a22', '#b8892e', '#7a8a30', '#e0b04a']
    for i, (x, y) in enumerate(scatter(34, 72, T)):
        c = cols[i % len(cols)]; d = i % 3
        for dx, dy in (((0, 0), (1, 0), (2, 0), (1, 1)) if d == 0 else ((0, 0), (0, 1), (1, 1), (1, 2)) if d == 1 else ((0, 0), (1, 0), (1, 1), (2, 1))): put(px, T, x + dx, y + dy, c)
        put(px, T, x + 1, y, '#f0c870' if i % 2 else c)
    return im
def tex_moss():
    im, px = fill(T, ['#2f6a3c', '#3f7a3e', '#4c8a50', '#68a460'], 81, cell=4)
    for x, y in scatter(60, 82, T): put(px, T, x, y, '#9ccc88')
    for x, y in scatter(3, 83, T):
        for dx, dy, c in ((0, 0, '#e8e0d0'), (-1, -1, '#c8362a'), (0, -1, '#e04a3a'), (1, -1, '#c8362a')): put(px, T, x + dx, y + dy, c)
    return im
def tex_dirt():
    im, px = fill(T, ['#472e27', '#5a3a2a', '#6b4228', '#8a5a34'], 91)
    for x, y in scatter(22, 92, T): put(px, T, x, y, '#a8743f'); put(px, T, x + 1, y, '#8a5a34')
    for x, y in scatter(5, 93, T): pebble(px, T, x, y)
    for x, y in scatter(7, 94, T):
        put(px, T, x, y, '#3f7a3e'); put(px, T, x, y - 1, '#5a9a48'); put(px, T, x - 1, y - 2, '#97cc66'); put(px, T, x + 1, y - 2, '#76b455')
    return im
KINDS = {"dirt": (tex_dirt, .66, 1.2), "clover": (tex_clover, .8, 1.1), "flowers": (tex_flowers, .86, 1.1), "weeds": (tex_weeds, .8, 1.12),
         "dry": (tex_dry, .8, 1.1), "leaves": (tex_leaves, .72, 1.14), "moss": (tex_moss, .8, 1.1)}

def lawns():
    """Plain lawn: no covering, just a few loose details over the turf (transparent png), six looks."""
    out = []
    for k in range(6):
        im = Image.new("RGBA", (T, T)); px = im.load(); M = 8
        pos = lambda i, s: (int(M + 2 + hsh(i, 1, s + k * 9) * (T - 2 * M - 4)), int(M + 8 + hsh(i, 2, s + k * 9) * (T - 2 * M - 10)))
        for i in range(4 + k % 3): tuft(px, T, *pos(i, 101), tall=(i % 2 == 0))
        for i in range(1 + k % 3): clover(px, T, *pos(i, 102))
        for i in range(k % 3 + (1 if k > 2 else 0)): flower(px, T, *pos(i, 103), *FL[(i + k) % 4])
        if k % 2: pebble(px, T, *pos(0, 104))
        out.append(im)
    return out

def main():
    B.WARP = (16, 18, 8, 6); B.INSET = 5   # big organic patches, not squares
    os.makedirs(OUT, exist_ok=True); n = 0
    masks = B.all_masks()
    for name, (fn, dk, lt) in KINDS.items():
        tex = fn()
        for m in masks: B.bake_tile(tex, m, dk, lt).save(os.path.join(OUT, f"{name}-{m}.png"), optimize=True); n += 1
    for i, im in enumerate(lawns(), 1): im.save(os.path.join(OUT, f"lawn-{i}.png"), optimize=True); n += 1
    turf().save(os.path.join(PH, "tile-turf-big.png"), optimize=True)
    print(n, "cover files in", OUT, "+ ph/tile-turf-big.png (256x256)")
if __name__ == "__main__": main()
