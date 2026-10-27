"""Mockup 4: art for the shared item square (.itm). Loads mockup2/gather_b.py (same palette, outline and felt9/ribbon9
pipeline, saved 2x with NEAREST) and adds only the new parts:
  felt-{c,u,r,l}.png     9-slice felt per rarity (18x18 native, CSS slice 12). c = the idle felt, u sage, r sky, l gold felt with gold stitch.
                         All four keep dark ink >= 7:1 (felt is art: it stays light in dark mode, like the Gather cards).
  win-{c,u,r,l,off}.png  9-slice framed window for the 64 px item icon (14x14 native, 6 px corners, CSS slice 12): wood frame,
                         nail heads, inner shadow upper left, a pale rarity wash inside.
  gem-{c,u,r,l}.png      rarity mark (shape + letter, so not colour alone): C pebble, U shield, R diamond, L star
  spark-{r,l}.png        4-frame twinkle strip (16x16 frames, 64x16 native) for rare and legendary; CSS steps(4), frame 3 static
  badge-basket.png       in the basket (sell or buy)   badge-use.png  in use / equipped (a belt buckle)
  rib-{idle,sel,off}.png the gather ribbon redrawn with short 3 px ends (10x12 native, CSS slice 8 6), so a name gets the whole card width
  petal.png              the Petals mark for price chips (the word stays for screen readers)
Felt off, ribbons and the sel/lock/done badges are mockup2's files; badge-star is mockup3's. Nothing is copied.
Usage: python3 claude/art-variants/mockup4/item_art.py   (writes to mockup4/art/)"""
import os, importlib.util
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'art')
os.makedirs(OUT, exist_ok=True)
spec = importlib.util.spec_from_file_location('gather_b', os.path.join(HERE, '..', 'mockup2', 'gather_b.py'))
gb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gb)
C, rect, ell, poly, line, hx, OL = gb.C, gb.rect, gb.ell, gb.poly, gb.line, gb.hx, gb.OL

# base, shade, rim, stitch
gb.FELT.update({
    'c': ('#c9a46a', '#a98450', '#e3c48c', '#8a6a3e'),
    'u': ('#b4c07e', '#929e5e', '#d0daa0', '#5e6e34'),
    'r': ('#a9c8d0', '#86a8b2', '#cfe6ea', '#3e6a7a'),
    'l': ('#e2be62', '#c09a3e', '#fbe08a', '#8a5a10'),
})
WASH = {'c': '#f6ead0', 'u': '#eef2d6', 'r': '#e6f2f2', 'l': '#fdf0c8', 'off': '#e6e2d8'}
FRAME = {'c': ('#a06a3a', '#74462a', '#c08a52'), 'off': ('#9e978a', '#7e786c', '#bdb6a6')}


def win9(k):
    n = 14
    base, shade, rim = FRAME['off' if k == 'off' else 'c']
    px = np.zeros((n, n, 4), np.uint8)
    put = lambda m, col: px.__setitem__(m, hx(col) + (255,))
    yy, xx = np.mgrid[0:n, 0:n]
    out = (xx == 0) | (yy == 0) | (xx == n - 1) | (yy == n - 1)
    corner = ((xx == 0) | (xx == n - 1)) & ((yy == 0) | (yy == n - 1))
    put(out & ~corner & ((xx == 0) | (yy == 0)), OL[1]); put(out & ~corner & ((xx == n - 1) | (yy == n - 1)), OL[2])
    fr = ~out & ((xx <= 3) | (yy <= 3) | (xx >= n - 4) | (yy >= n - 4))
    put(fr, base)
    put(fr & ((xx == 1) | (yy == 1)) & (xx < n - 2) & (yy < n - 2), rim)
    put(fr & ((xx == n - 2) | (yy == n - 2)), shade)
    put(fr & ((xx == 3) & (yy >= 3) & (yy <= n - 4) | (yy == 3) & (xx >= 3) & (xx <= n - 4)), shade)   # bevel into the window
    for x, y in ((2, 2), (n - 3, 2), (2, n - 3), (n - 3, n - 3)):
        put((xx == x) & (yy == y), '#e3c48c' if k != 'off' else '#d6d0c2')
    inner = (xx >= 4) & (yy >= 4) & (xx <= n - 5) & (yy <= n - 5)
    put(inner, WASH[k])
    put(inner & ((xx == 4) | (yy == 4)), '#d9c69c' if k != 'off' else '#c9c3b6')   # inner shadow upper left
    return px


FONT = {'C': ['.##', '#..', '#..', '#..', '.##'], 'U': ['#.#', '#.#', '#.#', '#.#', '###'],
        'R': ['##.', '#.#', '##.', '#.#', '#.#'], 'L': ['#..', '#..', '#..', '#..', '###']}


def letter(c, ch, x0, y0, col):
    for j, row in enumerate(FONT[ch]):
        for i, v in enumerate(row):
            if v == '#': c.f(rect(x0 + i, y0 + j, x0 + i, y0 + j), col)


def gem(k):
    c = C()
    if k == 'c':
        s = ell(1, 1, 11, 11); c.outline(s); c.shaded(s, '#8b8f96', '#5b6470', '#c9c5bc'); letter(c, 'C', 5, 4, '#fff3c8'); return c.px[0:13, 0:13]
    if k == 'u':
        s = poly([(1, 1), (11, 1), (11, 7), (6, 12), (1, 7)]); c.outline(s); c.shaded(s, '#4f8a3c', '#2f5a2a', '#7ab55c'); letter(c, 'U', 5, 3, '#fff3c8'); return c.px[0:14, 0:13]
    if k == 'r':
        s = poly([(6, 0), (12, 6), (6, 12), (0, 6)]); c.outline(s); c.shaded(s, '#3a86a8', '#25637d', '#a9d6ea'); letter(c, 'R', 5, 4, '#fff3c8'); return c.px[0:14, 0:14]
    s = poly([(7, 0), (9, 5), (14, 5), (10, 8), (12, 14), (7, 10), (2, 14), (4, 8), (0, 5), (5, 5)])
    c.outline(s); c.shaded(s, '#f4c84a', '#c89a2a', '#fff2b0'); letter(c, 'L', 6, 5, '#7a4a1f'); return c.px[0:16, 0:16]


def spark(k):
    main, glint = (('#a9d6ea', '#ffffff') if k == 'r' else ('#f5cf6a', '#fffbe6'))
    px = np.zeros((16, 64, 4), np.uint8)
    def star(f, x, y, r):
        x += f * 16
        for d in range(-r, r + 1):
            px[y, x + d] = hx(main if abs(d) else glint) + (255,)
            px[y + d, x] = hx(main if abs(d) else glint) + (255,)
        if r >= 2:
            for dx, dy in ((1, 1), (-1, 1), (1, -1), (-1, -1)): px[y + dy, x + dx] = hx(main) + (200,)
    # frame by frame: two twinkles that grow and fade out of phase
    for f, (a, b) in enumerate(((1, 3), (2, 2), (3, 1), (2, 0))):
        if a: star(f, 4, 5, a)
        if b: star(f, 11, 11, b)
        if f == 2: px[2, f * 16 + 12] = hx(glint) + (255,)
    return px


def badge3(kind):
    c = C()
    if kind == 'basket':
        handle = ell(3, 1, 11, 9) & ~ell(5, 3, 9, 9)
        body = poly([(1, 6), (13, 6), (11, 13), (3, 13)])
        c.outline(handle | body); c.f(handle, '#74462a'); c.shaded(body, '#c08a52', '#8a5a30', '#e3c48c')
        for y in (8, 10): c.f(rect(3, y, 11, y), '#8a5a30')
        return c.px[0:15, 0:15]
    ring = rect(1, 2, 13, 12) & ~rect(4, 5, 10, 9)       # in use: a belt buckle
    c.outline(ring); c.shaded(ring, '#f4c84a', '#c89a2a', '#fff2b0')
    c.f(rect(4, 7, 11, 7), '#74462a'); c.f(rect(12, 6, 12, 8), '#74462a')
    return c.px[0:15, 0:15]


def rib9(state):
    w, h, e = 10, 12, 3
    base, shade, rim = gb.SIGN[state]
    px = np.zeros((h, w, 4), np.uint8)
    put = lambda m, col: px.__setitem__(m, hx(col) + (255,))
    yy, xx = np.mgrid[0:h, 0:w]
    depth = np.minimum(np.minimum(yy, h - 1 - yy), 2)        # a shallower notch: 0 at the top/bottom rows, 2 deep in the middle
    body = (xx >= depth) & (xx <= w - 1 - depth)
    edge = body & ~((xx >= depth + 1) & (xx <= w - 2 - depth) & (yy >= 1) & (yy <= h - 2))
    put(body, base)
    put(body & (yy >= h - 3), shade)
    put(body & (yy == 1), rim)
    put(edge & ((yy < h // 2) | (xx < w // 2)), OL[1]); put(edge & (yy >= h // 2) & (xx >= w // 2), OL[2])
    put(edge & (yy == 0), OL[0])
    put(((yy == 2) | (yy == h - 4)) & (xx >= e) & (xx <= w - 1 - e) & (xx % 2 == 1), rim)
    return px


def petal():
    c = C()
    p = poly([(3, 0), (6, 3), (5, 7), (1, 7), (0, 3)])
    c.outline(p); c.shaded(p, '#e88aa8', '#b8577a', '#f8c8d8')
    c.f(rect(3, 2, 3, 5), '#b8577a')
    return c.px[0:10, 0:9]


if __name__ == '__main__':
    for st in ('idle', 'sel', 'off'):
        gb.img(rib9(st)).save(os.path.join(OUT, f'rib-{st}.png'), optimize=True)
    gb.img(petal()).save(os.path.join(OUT, 'petal.png'), optimize=True)
    for k in 'curl':
        gb.img(gb.felt9(k)).save(os.path.join(OUT, f'felt-{k}.png'), optimize=True)
        gb.img(gem(k)).save(os.path.join(OUT, f'gem-{k}.png'), optimize=True)
    for k in ('c', 'u', 'r', 'l', 'off'):
        gb.img(win9(k)).save(os.path.join(OUT, f'win-{k}.png'), optimize=True)
    for k in 'rl':
        gb.img(spark(k)).save(os.path.join(OUT, f'spark-{k}.png'), optimize=True)
    for k in ('basket', 'use'):
        gb.img(badge3(k)).save(os.path.join(OUT, f'badge-{k}.png'), optimize=True)
    print('felt x4, win x5, gem x4, spark x2, badge x2 ->', OUT)
