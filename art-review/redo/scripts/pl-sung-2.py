#!/usr/bin/env python3
"""pl-sung-2 "Chestful Snore": a sunken treasure chest that is an edge piece (edge-TBT, keyhole).
Flat bottom (sitting in the sand), keyhole tab N (gold lid handle), keyhole tab E (gold side handle), keyhole blank W cut into the box.
Wood and sand from cell 9-6 of the sunken galleon (hull brown, sea-floor sand), gold bands, porthole-cyan bubbles; snoring face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

WOOD = K.ramp('#a9714a')
PLANK = K.ramp('#7a4a30')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
SAND = K.ramp('#e8c078')
INSIDE = '#4a2f32'
BUB = '#8ce6ee'


def fn(c):
    k = 1.15 if c.small else 1.0
    lidcap = lambda x, y: ell(32, 25, 23, 12)(x, y) and y < 30
    lid = lambda x, y: lidcap(x, y) or rect(9, 24, 55, 31)(x, y)
    box = rect(9, 31, 55, 58)
    tabN = knob('T', 'keyhole', 32, 13.5, 0, -1, r=4.8 * k)
    tabE = knob('T', 'keyhole', 55, 43, 1, 0, r=5.0 * k)
    blankW = knob('B', 'keyhole', 9, 44, -1, 0, r=4.6 * k)
    body = c.m(box, lid, tabN, tabE, minus=(blankW,))
    c.add(body & c.m(box), WOOD, stitch=None)
    c.add(body & c.m(lid), PLANK, stitch=None)
    # gold handles (the tabs)
    c.add(c.m(tabN, minus=(lid,)) | (c.m(tabN) & c.m(rect(0, 12, 64, 15.5))), GOLD)
    c.add(c.m(tabE, minus=(box,)) | (c.m(tabE) & c.m(rect(53, 0, 55, 64))), GOLD)
    # gold corner bands on lid and box
    for bx in (12, 47):
        c.add(body & c.m(rect(bx, 0, bx + 4, 64)), GOLD)
    # lid gap = sleepy open mouth with coins glinting inside
    gap = body & c.m(rect(19, 30, 45, 33.5))
    c.add(gap, (INSIDE, INSIDE, INSIDE))
    c.add(body & c.m(rect(9, 28.5, 55, 30)), GOLD)
    for gx in (23, 29, 35, 41):
        c.add(body & c.m(ell(gx, 32.3, 2.4, 1.5)), GOLD)
    # lock plate with keyhole
    plate = c.m(rect(28, 34, 36, 42))
    c.add(plate, GOLD)
    kx, ky = c.P(32, 37)
    c.px(kx, ky, INSIDE)
    c.px(kx, ky + 1, INSIDE)
    if not c.small:
        c.px(kx - 1, ky, INSIDE)
        c.px(kx, ky + 2, INSIDE)
    # sand drift across the base (flat side)
    sand = body & c.m(lambda x, y: y > 51 + 1.8 * ((x // 6) % 2) - (1 if 24 < x < 40 else 0))
    c.add(sand, SAND)
    # closed snoring eyes on the box front
    for ex in (23, 41):
        cx, cy = c.P(ex, 44)
        if c.small:
            for dx in (-1, 0, 1):
                c.px(cx + dx, cy + (1 if dx == 0 else 0), K.UMBER)
        else:
            for dx in (-2, -1, 0, 1, 2):
                c.px(cx + dx, cy + (1 if abs(dx) < 2 else 0), K.UMBER)
    c.blush(19.5, 47.5)
    c.blush(42, 47.5)
    # bubbles drifting past the lid
    pts = [(22, 22), (41, 21)] if c.small else [(21, 22), (42, 20), (39, 25)]
    for i, (bx, by) in enumerate(pts):
        x, y = c.P(bx, by)
        if c.small or i == 2:
            c.px(x, y, BUB)
        else:
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                c.px(x + dx, y + dy, BUB)
            c.px(x, y, '#ffffff')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-sung-2', 'Chestful Snore', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-2.png')
    print(rep)
