#!/usr/bin/env python3
"""pl-wdol-3 Notch-Ladder Trunk. Inner-TBTB, keyhole: a square slab of riverside tree trunk.
N keyhole tab = leafy canopy tuft, S keyhole tab = splayed root foot, E + W keyhole blanks = the climbing notches cut into the bark.
Hanging green vines from the canopy, small ladder notches up the bark. Bark browns + leaf greens from cell 3-1 (trunk by the pink-dolphin pool)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

BARK = K.ramp('#9a6448')
BARKD = K.ramp('#7a4c3a')
TAN = '#d8a47a'
LEAF = K.ramp('#4aa05a')
LEAFL = K.ramp('#7ac85c')
VINE = K.ramp('#3f8a4a')
ROOT = K.ramp('#8c5e48')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 14, 51, 52)
    tabN = knob('T', 'keyhole', 32, 14, 0, -1, r=5.2 * k)
    tabS = knob('T', 'keyhole', 32, 52, 0, 1, r=4.4 * k)
    blankE = knob('B', 'keyhole', 51, 38, 1, 0, r=3.3 * k, nw=2.0)
    blankW = knob('B', 'keyhole', 13, 38, -1, 0, r=3.3 * k, nw=2.0)
    body = c.m(core, tabS, minus=(blankE, blankW))
    c.add(body, BARK)
    # root foot: the S tab and the trunk base in darker root brown, with root splay lines
    roots = c.m(tabS, minus=(core,)) | (body & c.m(rect(0, 49, 64, 53)))
    c.add(roots, ROOT)
    c.line([(24, 52), (19, 51.5)], ROOT[1]); c.line([(40, 52), (45, 51.5)], ROOT[1])
    # bark grain: vertical darker streaks + tan flecks
    for gx in (18, 24, 40, 46):
        c.line([(gx, 22 if gx in (24, 40) else 26), (gx, 48)], BARKD[0])
    if not c.small:
        for (x, y) in body:
            if (x * 7 + y * 3) % 23 == 0 and 16 < y < 48:
                c.px(x, y, TAN)
    # ladder notches: little umber steps up the middle-left of the bark
    for ny in ((24, 31, 46) if not c.small else (25, 46)):
        c.line([(15.5, ny), (20, ny)], K.UMBER2)
        c.line([(44, ny - 2), (48.5, ny - 2)], K.UMBER2)
    # canopy: the N tab plus a leafy brim across the top of the trunk, scalloped lower edge
    brim = c.m(lambda x, y: 12 <= x < 52 and 12 <= y < 19 + (2 if (x // 5) % 2 else 0), ell(19, 13, 6.5, 4.5), ell(45, 13, 6.5, 4.5))
    can = c.m(tabN, minus=(core,)) | brim
    c.add(can, LEAF)
    c.add(c.m(ell(30, 6.5, 3, 2.2), ell(22, 13, 3.2, 2), ell(41, 13, 3.2, 2)) & can, LEAFL)
    # hanging vines down the trunk with leaf beads
    vw = 2.8 if c.small else 2.2
    for vx, vy in ((16, 33), (49, 29)):
        c.add(c.m(thick_path([(vx, 18), (vx + 1, (18 + vy) / 2), (vx, vy)], vw)) & body, VINE)
        c.add(c.m(ell(vx + 0.5, vy, 2.0 * k, 2.4 * k)) & body, LEAFL)
    # face on the calm middle of the trunk
    c.eye(26, 28)
    c.eye(38, 28)
    c.smile(32, 33)
    c.blush(22, 32)
    c.blush(41, 32)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wdol-3', 'Notch-Ladder Trunk', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-3.png')
    print(rep)
