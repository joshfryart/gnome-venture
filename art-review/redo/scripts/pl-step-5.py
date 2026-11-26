#!/usr/bin/env python3
"""pl-step-5 Goldseal Gleam. Inner-BBBB, double: a round-cornered gold temple seal (medallion) whose four sides each carry a
double blank, so the coin is notched like a jigsaw piece. Its sunken centre disc is sandstone brick from cell 6-2, carved with
the stepped seed temple (moss-green ledges) and the gold seed gem on top; the temple's middle tier wears the felt face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

GOLDR = K.ramp('#e8b42c')
GEM = ('#f4cc3c', '#b8801c', '#fff0a0')
SAND = K.ramp('#b08c6c')
SANDL = K.ramp('#d4ae88')
MOSS = K.ramp('#52a07c')
SKY = K.ramp('#9cc8e8')


def rrect(x0, y0, x1, y1, r):
    return lambda x, y: (x0 <= x < x1 and y0 + r <= y < y1 - r) or (x0 + r <= x < x1 - r and y0 <= y < y1) or any(
        (x - cx) ** 2 + (y - cy) ** 2 < r * r for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r), (x0 + r, y1 - r), (x1 - r, y1 - r)))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(6, 6, 58, 58, 9)
    bl = [knob('B', 'double', 32, 6, 0, -1, r=3.9 * k), knob('B', 'double', 32, 58, 0, 1, r=3.9 * k),
          knob('B', 'double', 6, 32, -1, 0, r=3.9 * k), knob('B', 'double', 58, 32, 1, 0, r=3.9 * k)]
    body = c.m(core, minus=bl)
    c.add(body, GOLDR, stitch=None if c.small else '#b07a10')
    disc = ell(32, 32, 14.5, 14.5)
    dm = c.m(disc)
    c.add(dm, SKY)
    # stepped temple inside the seal
    tiers = [(18, 46.5, 46, 41), (21, 42.5, 43, 37), (24, 39, 40, 33), (27, 35, 37, 29.5)]
    tiers = [(17, 40, 47, 47.5), (20, 33, 44, 40), (24.5, 27, 39.5, 33)]
    for i, (x0, y0, x1, y1) in enumerate(tiers):
        c.add(c.m(rect(x0, y0, x1, y1)) & dm, SANDL if i == 1 else SAND)
        c.add(c.m(rect(x0 - 0.8, y0, x1 + 0.8, y0 + (1.8 if c.small else 1.1))) & dm, MOSS)
    c.add(c.m(rect(0, 47, 64, 64)) & dm, MOSS)
    # brick joints on lower tier (64 only)
    if not c.small:
        for (x0, y0, x1, y1) in tiers[:1]:
            yy = c.P(0, 43)[1]
            for x in list(range(c.P(x0, 0)[0] + 1, c.P(25, 0)[0])) + list(range(c.P(39.5, 0)[0], c.P(x1, 0)[0] - 1)):
                c.px(x, yy, SAND[1])
            for bx in (23, 41):
                xx, y1p = c.P(bx, 41)
                c.px(xx, y1p, SAND[1]); c.px(xx, y1p + 1, SAND[1])
            for bx in (20, 44):
                xx, y2p = c.P(bx, 44)
                c.px(xx, y2p, SAND[1]); c.px(xx, y2p + 1, SAND[1])
    # temple door in the top tier
    c.add(c.m(rect(30, 29.5, 34, 33), ell(32, 29.8, 2, 1.6)) & dm, ('#5e4a48', '#4a3a38', '#6e5a58'))
    # the gold seed gem on top
    c.add(c.m(poly([(32, 18.5), (35.6, 23), (32, 27.6), (28.4, 23)])), GEM)
    c.edge(dm, '#b07a10')
    # face on the seal's gold above? no: on the temple tiers either side of the stair
    c.eye(26.5, 36.8)
    c.eye(37.8, 36.8)
    c.smile(32.2, 42.6, wide=not c.small)
    c.blush(22.5, 38.5)
    c.blush(41.5, 38.5)
    # rivets at the four corners of the seal
    for rx, ry in ((12.5, 12.5), (51.5, 12.5), (12.5, 51.5), (51.5, 51.5)):
        x, y = c.P(rx, ry)
        c.px(x, y, GOLDR[2] if not c.small else '#fff0a0')
        if not c.small:
            c.px(x + 1, y + 1, GOLDR[1]); c.px(x + 1, y, GOLDR[0]); c.px(x, y + 1, GOLDR[0])
    # gleam sparkle on the rim (upper left)
    x, y = c.P(17, 20)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)) if not c.small else ((0, 0),):
        c.px(x + dx, y + dy, '#fff8d8')


rep = K.render_pal(fn, 'pl-step-5', 'Goldseal Gleam', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-step-5-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-5.png')
print(rep)
