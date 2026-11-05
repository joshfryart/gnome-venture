#!/usr/bin/env python3
"""Bake the untilled-ground tiles (Hearth Pop v3) -> game/assets/img/ph/tile-turf.png and tile-wild-1..6.png (64x64).
All seven share ONE wrapped turf (same noise, same greens), so any two squares side by side, and the yard's plain turf behind them,
meet without a seam; only the small details differ (flowers, tall tufts, pebbles, clover, bare soil), and they are kept 7 px off the edges
so nothing is cut at a square's border. tile-turf.png is the plain ground drawn behind the whole yard (no details).
Run: python3 -I tools/bake_wild_art.py   (needs Pillow)"""
import math, os, random
from PIL import Image
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "game", "assets", "img", "ph")
W = 64; M = 7
GR = ['#3f7a3e', '#5a9a48', '#76b455', '#97cc66']; SOIL = ['#472e27', '#6b4228', '#8a5a34', '#a8743f']
def hx(c): return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5)) + (255,)
def hsh(a, b, s):
    n = (a * 374761393 + b * 668265263 + s * 2147483647) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535
def vn(x, y, cell=8, s=91):
    per = W // cell; gx, gy = x / cell, y / cell; x0, y0 = math.floor(gx), math.floor(gy); fx, fy = gx - x0, gy - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy); g = lambda a, b: hsh(a % per, b % per, s)
    t = g(x0, y0) * (1 - fx) + g(x0 + 1, y0) * fx; b = g(x0, y0 + 1) * (1 - fx) + g(x0 + 1, y0 + 1) * fx
    return t * (1 - fy) + b * fy
def turf():
    im = Image.new('RGBA', (W, W)); px = im.load()
    for y in range(W):
        for x in range(W):
            v = vn(x, y) * .8 + hsh(x, y, 2) * .2
            i = 0 if v < .34 else 1 if v < .55 else 2 if v < .72 else 3
            if i == 0 and hsh(x, y, 6) > .5: i = 1
            px[x, y] = hx(GR[i])
    return im
def variant(seed, soil, tufts, clover, flowers, pebbles, tall):
    im = turf(); px = im.load(); rnd = random.Random(seed)
    def P(x, y, c):
        if 0 <= x < W and 0 <= y < W: px[x, y] = hx(c)
    pos = lambda: (rnd.randrange(M + 2, W - M - 2), rnd.randrange(M + 6, W - M - 2))
    for _ in range(soil):
        cx, cy = pos(); r = rnd.uniform(3.0, 4.8)
        for y in range(-7, 8):
            for x in range(-7, 8):
                d = math.hypot(x * 1.0, y * 1.3) + (hsh(cx + x, cy + y, 3) - .5) * 3
                if d < r: t = d / r; P(cx + x, cy + y, SOIL[0] if t > .8 else SOIL[1] if t > .45 else SOIL[2])
                elif d < r + 1.5 and hsh(cx + x, cy + y, 4) > .6: P(cx + x, cy + y, GR[0])
        P(cx, cy - 1, GR[0]); P(cx, cy - 2, GR[2]); P(cx - 1, cy - 3, GR[3]); P(cx + 1, cy - 3, GR[2])
    for _ in range(tufts):
        x, y = pos(); tl = rnd.random() < tall
        for dy, c in ((0, GR[0]), (-1, GR[0]), (-2, GR[1]), (-3, GR[3])): P(x, y + dy, c)
        P(x - 1, y, GR[0]); P(x - 2, y - 1, GR[1]); P(x - 2, y - 2, GR[3]); P(x + 1, y, GR[0]); P(x + 2, y - 1, GR[1]); P(x + 2, y - 2, GR[2]); P(x + 2, y - 3, GR[3])
        if tl: P(x, y - 4, GR[3]); P(x, y - 5, '#e2dc90'); P(x - 1, y - 4, GR[2])
    for _ in range(clover):
        x, y = pos()
        for dx, dy in ((0, 0), (2, 1), (-2, 1)): P(x + dx, y + dy, '#4c9a50'); P(x + dx + 1, y + dy, '#6ac06a'); P(x + dx, y + dy - 1, '#6ac06a')
    for _ in range(pebbles):
        x, y = pos()
        for dx, dy, c in ((0, 0, '#8a899a'), (1, 0, '#aaa9b8'), (2, 0, '#8a899a'), (0, 1, '#5d5c70'), (1, 1, '#8a899a'), (2, 1, '#5d5c70'), (1, -1, '#cfcfdc')): P(x + dx, y + dy, c)
    fl = [('#f0d067', '#fbeaa0'), ('#f7f0e6', '#f0d067'), ('#e8809a', '#fbeaa0'), ('#b9a0e0', '#f7f0e6')]
    for k in range(flowers):
        x, y = pos(); a, b = fl[(k + seed) % 4]
        P(x, y + 3, GR[0]); P(x, y + 2, GR[1]); P(x, y + 1, GR[1])
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)): P(x + dx, y + dy, a)
        P(x, y, b)
    return im
VARIANTS = [  # seed, soil patches, tufts, clover, flowers, pebbles, tall share
    (1, 2, 8, 6, 6, 1, .4), (2, 2, 18, 3, 1, 1, .9), (3, 3, 7, 1, 0, 4, .2), (4, 1, 9, 8, 2, 2, .4), (5, 4, 10, 3, 2, 2, .5), (6, 2, 10, 4, 4, 2, .5)]
def main():
    turf().save(os.path.join(OUT, "tile-turf.png"))
    for i, v in enumerate(VARIANTS, 1): variant(*v).save(os.path.join(OUT, f"tile-wild-{i}.png"))
    print("tile-turf.png + tile-wild-1..%d.png in %s" % (len(VARIANTS), OUT))
if __name__ == "__main__": main()
