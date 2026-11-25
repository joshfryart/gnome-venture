#!/usr/bin/env python3
"""v2.8.53: pixel redraw of three weak Garden Yard sprites (frog pond mud bank, worm farm castings, silkworm spool).
There is no Aseprite binary here, so the PNGs in aseprite-source/v3/states2/ were edited in place with PIL (same palette, hard edges, no blur);
the matching .aseprite files are NOT updated. Safe to run twice (it only touches the old pixels). Then run tools/build_gyard_assets.py.
Run from the repo root."""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'aseprite-source/v3/states2')

K = (81, 48, 43, 255); M = (115, 66, 48, 255); D = (134, 76, 51, 255); A = (185, 122, 74, 255); S = (149, 102, 82, 255)
P = (245, 128, 159, 255); OUT = (43, 28, 38, 255)
CREAM = (255, 244, 214, 255); TAN = (230, 208, 160, 255); SAND = (232, 185, 130, 255)
HAZE, HAZE2 = (111, 140, 122, 255), (91, 120, 104, 255)   # the old flat grey-green shadow under the pond


def files(key, names):
    for n in names:
        yield os.path.join(SRC, key, '%s-%s.png' % (key, n))


def worm_farm():
    """The slab under the bin was one flat tan colour with three specks: now crumbly dark castings, with two worms."""
    for f in files('worm_farm', ['l1', 'l2', 'l3', 'ready-l1', 'ready-l2', 'ready-l3']):
        im = Image.open(f).convert('RGBA'); W = 56; px = im.load()
        for fr in range(im.width // W):
            ox = fr * W
            for y in range(37, 52):
                for lx in range(W):
                    if px[ox + lx, y] != A: continue
                    gx = (lx + 3 * (((y - 37) // 4) % 2)) % 6; gy = (y - 37) % 4
                    if gy == 1 and gx in (0, 1): px[ox + lx, y] = D
                    elif gy == 2 and gx == 1: px[ox + lx, y] = K
                    elif gy == 3 and gx == 4 and lx % 2: px[ox + lx, y] = S
            for pts in (((8, 46), (9, 45), (10, 45), (11, 46), (12, 46)), ((45, 40), (46, 39), (47, 39), (48, 40), (49, 40))):
                for (lx, y) in pts:
                    if px[ox + lx, y] in (A, D, K, S):
                        px[ox + lx, y] = P
                        if px[ox + lx, y + 1] in (A, D, S): px[ox + lx, y + 1] = K
        im.save(f, 'PNG', optimize=True)


def frog_pond():
    """The grey-green flat under the pond is now a muddy bank: dark mud, clumps, wet glints, two pebbles."""
    for f in files('frog_pond', ['l1', 'l2', 'l3', 'ready-l1', 'ready-l2', 'ready-l3']):
        im = Image.open(f).convert('RGBA'); W = 72; px = im.load()
        for fr in range(im.width // W):
            ox = fr * W
            for y in range(40, 52):
                for lx in range(W):
                    c = px[ox + lx, y]
                    if c not in (HAZE, HAZE2): continue
                    h = (lx * 7 + y * 13 + (lx * y) % 5) % 11
                    if c == HAZE2: px[ox + lx, y] = K if h % 3 else M
                    else: px[ox + lx, y] = D if h in (0, 1) else (S if h == 5 and y % 2 == 0 else M)
        im.save(f, 'PNG', optimize=True)


# 9 wide (x15..23) x 9 tall (y36..44): grey flanges, five rows of cream thread with diagonal winding; the right side of the thread rows keeps the shelf frame pixels
SPOOL_ROWS = {36: '.#######.', 37: '#LLLLLLL#', 43: '#xxxxxxx#', 44: '.#######.'}
GREY, LIGHT = (130, 120, 140, 255), (170, 169, 184, 255)


def silk_spool():
    col = {'#': OUT, 'L': LIGHT, 'x': GREY}
    for f in files('silk_shelf', ['l3', 'ready-l3']):
        im = Image.open(f).convert('RGBA'); W = 64; px = im.load()
        for fr in range(im.width // W):
            ox = fr * W
            if px[ox + 16, 38] != CREAM: continue   # already redrawn (or a frame without the old spool)
            for y, s in SPOOL_ROWS.items():
                for i, ch in enumerate(s):
                    if ch != '.': px[ox + 15 + i, y] = col[ch]
            for y in range(38, 43):
                px[ox + 15, y] = (0, 0, 0, 0); px[ox + 16, y] = OUT; px[ox + 22, y] = OUT   # the flanges stick out 1 px on the left
                for x in range(17, 22):
                    px[ox + x, y] = SAND if x == 21 else (TAN if (x + y) % 3 == 0 else CREAM)
        im.save(f, 'PNG', optimize=True)


if __name__ == '__main__':
    worm_farm(); frog_pond(); silk_spool()
