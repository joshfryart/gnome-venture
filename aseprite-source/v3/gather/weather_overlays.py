#!/usr/bin/env python3
"""Weather overlays for the gather scene: transparent 480x270 PNGs, hard pixels only (no semi-transparency).
Writes weather-{rain,storm,frost,wind,fog,cloud}.png into the folder given as argv[1] (default ./out)."""
import sys, os, math, random
from PIL import Image

W, H = 480, 270
out = sys.argv[1] if len(sys.argv) > 1 else 'out'
os.makedirs(out, exist_ok=True)

def hsh(x, y, s):
    n = (x * 374761393 + y * 668265263 + s * 144665) & 0x7fffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
    return (n % 10007) / 10007.0

def vn(x, y, sc, s):
    gx, gy = x / sc, y / sc
    x0, y0 = math.floor(gx), math.floor(gy)
    fx, fy = gx - x0, gy - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b, c, e = hsh(x0, y0, s), hsh(x0 + 1, y0, s), hsh(x0, y0 + 1, s), hsh(x0 + 1, y0 + 1, s)
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + e) * fx * fy

def put(px, x, y, col):
    if 0 <= x < W and 0 <= y < H: px[x, y] = col

def rain(n, seed, light=(207, 230, 245, 255), dark=(134, 170, 204, 255), slant=1):
    im = Image.new('RGBA', (W, H)); px = im.load(); r = random.Random(seed)
    for i in range(n):
        x, y = r.randrange(W), r.randrange(H); L = r.choice((4, 5, 6)); col = light if r.random() < .6 else dark
        for k in range(L): put(px, x + k * slant // 2 + (k // 2) * slant, y + k, col)
        if r.random() < .4: put(px, x - 1, y + L + 1, light); put(px, x + 1, y + L + 1, light)   # splash
    return im

def save(im, name): im.save(os.path.join(out, 'weather-' + name + '.png'))

save(rain(420, 1), 'rain')

st = rain(760, 2, light=(190, 214, 236, 255), dark=(106, 138, 176, 255), slant=2)
px = st.load()
for y in range(0, 44):   # storm-cloud band over the top
    for x in range(W):
        if vn(x, y * 1.4, 18, 4) > .5 + y / 120: px[x, y] = (70, 78, 104, 255) if vn(x, y, 7, 5) > .4 else (92, 100, 128, 255)
save(st, 'storm')

fr = Image.new('RGBA', (W, H)); px = fr.load()
for y in range(H):   # frost creeping in from the edges
    for x in range(W):
        d = min(x, W - 1 - x, y, H - 1 - y)
        if d < 26 and vn(x, y, 5, 7) + (26 - d) / 40 > .95: px[x, y] = (232, 244, 255, 255) if vn(x, y, 3, 9) > .4 else (190, 220, 248, 255)
r = random.Random(3)
for i in range(70):   # sparkles
    x, y = r.randrange(W), r.randrange(H)
    put(px, x, y, (255, 255, 255, 255))
    if i % 3 == 0:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)): put(px, x + dx, y + dy, (200, 228, 252, 255))
save(fr, 'frost')

wd = Image.new('RGBA', (W, H)); px = wd.load(); r = random.Random(4)
for i in range(60):
    x, y = r.randrange(40, W), r.randrange(20, H - 20); col = r.choice(((245, 184, 46, 255), (201, 79, 58, 255), (124, 195, 90, 255), (232, 136, 58, 255)))
    put(px, x, y, col); put(px, x + 1, y, col); put(px, x + 1, y - 1, col); put(px, x - 1, y + 1, (43, 28, 38, 255))
    for k in range(3, 10): put(px, x + k, y + (k // 4), (255, 244, 214, 255) if k % 2 else (230, 236, 244, 255))   # whoosh
save(wd, 'wind')

fg = Image.new('RGBA', (W, H)); px = fg.load()
for y in range(H):
    for x in range(W):
        t = vn(x * .5, y, 16, 11) * .55 + vn(x, y, 40, 12) * .45 + (y / H) * .22
        if t > .86: px[x, y] = (226, 233, 241, 255)
        elif t > .5 and (x + y) % 2 == 0: px[x, y] = (214, 224, 236, 255)
        elif t > .68 and (x % 2 == 0 and y % 2 == 1): px[x, y] = (236, 241, 247, 255)
save(fg, 'fog')

cl = Image.new('RGBA', (W, H)); px = cl.load()
for y in range(0, 40):
    for x in range(W):
        t = vn(x, y * 1.6, 22, 21) * .7 + vn(x, y, 9, 22) * .3
        if t > .55 + y / 90: px[x, y] = (226, 230, 240, 255) if vn(x, y, 5, 23) > .35 else (190, 198, 216, 255)
save(cl, 'cloud')

sn = Image.new('RGBA', (W, H)); px = sn.load(); r = random.Random(5)
for i in range(180):
    x, y = r.randrange(W), r.randrange(H)
    put(px, x, y, (255, 255, 255, 255))
    if i % 3 == 0: put(px, x + 1, y, (226, 238, 252, 255)); put(px, x, y + 1, (226, 238, 252, 255))
for y in range(H - 70, H):   # thin snow cover creeping up from the bottom
    for x in range(W):
        if vn(x, y, 6, 31) * .6 + (y - (H - 70)) / 70 * .5 > .78: px[x, y] = (240, 246, 255, 255) if vn(x, y, 3, 32) > .35 else (212, 226, 244, 255)
save(sn, 'snow')
