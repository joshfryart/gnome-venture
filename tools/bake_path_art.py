#!/usr/bin/env python3
"""Bake blended yard-path tiles (Hearth Pop v3), the way the Trail ground blends (tools/bake_trail_art.py / gen2.terrain_layer).
For each path material it writes game/assets/img/paths/<material>-<mask>.png (64x64, transparent where the ground shows through):
  - the boundary between path and not-path is pushed around by wrapped (period-64) noise, hard pixels only, so neighbouring tiles always meet;
  - open sides are inset a little so a lone square reads as a worn patch; edges get a lit rim (up-left) and a shade rim (down-right);
  - <mask> is the 8-neighbour path mask in canonical form (a diagonal counts only when both its side neighbours are paths): 47 shapes.
Bit order: N=1 E=2 S=4 W=8 NE=16 SE=32 SW=64 NW=128.
Stepping stones are loose stones, not a surface: one transparent tile each (no mask).
Run: python3 -I tools/bake_path_art.py [--preview out.png]   (needs Pillow)"""
import math, os, sys
from PIL import Image
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PH = os.path.join(REPO, "game", "assets", "img", "ph")
OUT = os.path.join(REPO, "game", "assets", "img", "paths")
T = 64
MATS = {"stone": "tile-stone-path", "gravel": "tile-gravel-path", "brick": "tile-brick-path", "bark": "tile-bark-path"}
N, E, S, W, NE, SE, SW, NW = 1, 2, 4, 8, 16, 32, 64, 128

def hsh(a, b, s):
    n = (a * 374761393 + b * 668265263 + s * 2147483647) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535
def vnoise(x, y, cell, seed):   # period-64 value noise: tile edges always agree
    per = T // cell; gx, gy = x / cell, y / cell; x0, y0 = math.floor(gx), math.floor(gy); fx, fy = gx - x0, gy - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    h = lambda a, b: hsh(a % per, b % per, seed)
    top = h(x0, y0) * (1 - fx) + h(x0 + 1, y0) * fx; bot = h(x0, y0 + 1) * (1 - fx) + h(x0 + 1, y0 + 1) * fx
    return top * (1 - fy) + bot * fy

def canon(m):
    for d, (a, b) in ((NE, (N, E)), (SE, (S, E)), (SW, (S, W)), (NW, (N, W))):
        if m & d and not (m & a and m & b): m &= ~d
    return m
def all_masks(): return sorted({canon(m) for m in range(256)})

def seamless(im):
    """Make a 64x64 picture wrap: take the picture near its middle and a copy shifted by half a tile near the edges, picked pixel by pixel with noise (hard pixels, no fades)."""
    rolled = Image.new("RGBA", (T, T)); rolled.paste(im, (T // 2, T // 2)); rolled.paste(im, (-T // 2, T // 2)); rolled.paste(im, (T // 2, -T // 2)); rolled.paste(im, (-T // 2, -T // 2))
    a, b, out = im.load(), rolled.load(), Image.new("RGBA", (T, T)); o = out.load()
    for y in range(T):
        for x in range(T):
            w = min(1 - abs(x - 32) / 32, 1 - abs(y - 32) / 32) * 1.6 - .1   # 1 in the middle (picture is whole there), 0 at the wrap edges (the shifted copy is whole there)
            o[x, y] = a[x, y] if w > hsh(x, y, 77) else b[x, y]
    return out

def bark():
    """Shredded bark, drawn wrapped so it tiles: dark base, a few hundred short strands in four browns, lit tops, a leaf fleck."""
    im = Image.new("RGBA", (T, T), (0x4a, 0x2c, 0x1c, 255)); P = im.load()
    for y in range(T):
        for x in range(T):
            if hsh(x, y, 5) > .72: P[x, y] = (0x3a, 0x22, 0x16, 255)
    cols = [(0x6b, 0x40, 0x25, 255), (0x8a, 0x56, 0x30, 255), (0xa8, 0x70, 0x3c, 255), (0xc8, 0x92, 0x52, 255)]
    for i in range(150):
        x, y = hsh(i, 1, 31) * T, hsh(i, 2, 31) * T; ang = (hsh(i, 3, 31) - .5) * 1.3 + (0 if i % 4 else 1.5); ln = 5 + int(hsh(i, 4, 31) * 8); ci = int(hsh(i, 5, 31) * 3)
        for k in range(ln):
            px, py = int(x + math.cos(ang) * k) % T, int(y + math.sin(ang) * k) % T
            c = cols[min(3, ci + (1 if k == 0 else 0))] if k < ln - 2 else cols[max(0, ci - 1)]
            P[px, py] = c
            if k % 3 == 1: P[(px + 1) % T, py] = cols[ci]
    for i in range(7):
        x, y = int(hsh(i, 9, 41) * T), int(hsh(i, 8, 41) * T)
        for dx, dy, c in ((0, 0, (0x3f, 0x7a, 0x3e, 255)), (1, 0, (0x5a, 0x9a, 0x48, 255)), (0, -1, (0x76, 0xb4, 0x55, 255))): P[(x + dx) % T, (y + dy) % T] = c
    return im

def texture(mat):
    if mat == "bark": return bark()
    im = Image.open(os.path.join(PH, MATS[mat] + ".png")).convert("RGBA")
    return seamless(im) if mat == "stone" else im

INSET = 3
def is_path(m, x, y):
    """Is local pixel (x,y) (may sit just outside 0..63) path, given canonical mask m?"""
    dx = (vnoise(x % T, y % T, 8, 11) - .5) * 12 + (vnoise(x % T, y % T, 4, 13) - .5) * 4
    dy = (vnoise(x % T, y % T, 8, 12) - .5) * 12 + (vnoise(x % T, y % T, 4, 14) - .5) * 4
    wx, wy = x + dx, y + dy
    cx = -1 if wx < 0 else (1 if wx >= T else 0); cy = -1 if wy < 0 else (1 if wy >= T else 0)
    has = {(0, -1): N, (1, 0): E, (0, 1): S, (-1, 0): W, (1, -1): NE, (1, 1): SE, (-1, 1): SW, (-1, -1): NW}
    if not (cx == 0 and cy == 0) and not (m & has[(cx, cy)]): return False
    # an open side pulls the surface in a few pixels; an open diagonal (inner corner) takes a round bite
    j = (vnoise(x % T, y % T, 4, 15) - .5) * 3
    ins = INSET + j
    if not m & N and wy < ins: return False
    if not m & S and wy > T - 1 - ins: return False
    if not m & W and wx < ins: return False
    if not m & E and wx > T - 1 - ins: return False
    for d, a, b, px, py in ((NE, N, E, T, 0), (SE, S, E, T, T), (SW, S, W, 0, T), (NW, N, W, 0, 0)):
        if m & a and m & b and not m & d and math.hypot(wx - px, wy - py) < ins * 2.2 + j: return False
    return True

def shade(c, f): return (min(255, int(c[0] * f)), min(255, int(c[1] * f)), min(255, int(c[2] * f)), c[3])

def bake_tile(tex, m):
    tp = tex.load(); out = Image.new("RGBA", (T, T), (0, 0, 0, 0)); P = out.load()
    pm = {(x, y): is_path(m, x, y) for x in range(-1, T + 1) for y in range(-1, T + 1)}
    for y in range(T):
        for x in range(T):
            if not pm[(x, y)]: continue
            c = tp[x, y]
            if not pm[(x, y + 1)] or not pm[(x + 1, y)]: c = shade(c, .74)
            elif not pm[(x, y - 1)] or not pm[(x - 1, y)]: c = shade(c, 1.16)
            P[x, y] = c
    return out

def stepping():
    im = Image.open(os.path.join(PH, "tile-stepping-stones.png")).convert("RGBA"); P = im.load()
    for y in range(T):
        for x in range(T):
            r, g, b, a = P[x, y]
            if g > r + 8 and g >= b + 8 and g > 70: P[x, y] = (0, 0, 0, 0)   # grass-green background goes; stones and their outlines stay
    return im

def main():
    os.makedirs(OUT, exist_ok=True)
    masks = all_masks(); n = 0
    for mat in MATS:
        tex = texture(mat)
        for m in masks:
            bake_tile(tex, m).save(os.path.join(OUT, f"{mat}-{m}.png")); n += 1
    stepping().save(os.path.join(OUT, "stones.png")); n += 1
    print(n, "files in", OUT, "(", len(masks), "masks x", len(MATS), "materials + stones )")
if __name__ == "__main__": main()
