#!/usr/bin/env python3
"""pl-wsta-2 "Hazy Island Nap": a dozing far island that is an edge piece (edge-TBB, keyhole).
Flat S = the sea line it floats on (dark indigo water band). Keyhole tab N = the island's summit knoll with a little palm.
Keyhole blanks W and E = bays bitten into the island's flanks. Colours from cell 10-4: pink haze hill, mauve ridge,
grey-mauve shore, indigo sea, purple sky; a pale pink star above. Closed sleepy eyes + a 'z'."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2

HILL = ramp('#cf839f')
RIDGE = ramp('#9a6d9f')
SHORE = ramp('#83707d')
SEA = ramp('#554572')
PALM = ramp('#4f8a5a')
TRUNK = ramp('#8a5a3a')
FOAM = '#ffd0e0'
STAR = '#9ec8ff'


def fn(c):
    k = 1.15 if c.small else 1.0
    # dome-shouldered core: a square-ish piece with rounded top corners
    core = lambda x, y: (8 <= x < 56 and 24 <= y < 58) and not (
        (x < 17 and y < 33 and (x - 17) ** 2 + (y - 33) ** 2 > 81) or
        (x >= 47 and y < 33 and (x - 47) ** 2 + (y - 33) ** 2 > 81))
    tabN = knob('T', 'keyhole', 32, 24, 0, -1, r=5.4 * k, nw=3.2)
    blankW = knob('B', 'keyhole', 8, 40, -1, 0, r=4.4 * k)
    blankE = knob('B', 'keyhole', 56, 40, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, minus=(blankW, blankE))
    # layers: pink hazy hill (dome + summit knoll), a mauve haze streak across it, grey shore, indigo sea band
    hill = body
    c.add(hill, HILL, stitch=None)
    haze = c.m(lambda x, y: 27 + (1.5 if (x // 7) % 2 else 0) <= y < 30.5 + (1.5 if (x // 7) % 2 else 0)) & body
    c.add(haze, RIDGE)
    shore = c.m(lambda x, y: y >= 47 - (2 if x > 36 else 0)) & body
    c.add(shore, SHORE)
    sea = c.m(rect(0, 52, 64, 64)) & body
    c.add(sea, SEA)
    
    # little palm on the summit knoll
    tw = 2.2 if not c.small else 2.9
    c.add(c.m(thick_path([(32, 20), (33, 14), (35, 10)], tw)), TRUNK)
    fw = 2.6 if not c.small else 3.2
    c.add(c.m(thick_path([(35, 10), (29, 9), (26, 12)], fw), thick_path([(35, 10), (41, 8), (44, 11)], fw),
              thick_path([(35, 10), (36, 5)], fw)), PALM)
    # wave crests on the sea band
    y = c.P(0, 55.5)[1]
    for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
        if (x // 3) % 2 == 0 and (x, y) in sea:
            c.px(x, y + (x % 3 == 1), FOAM if not c.small else SEA[2])
    # sleepy face on the pink hill: closed arc eyes, soft smile, blush
    for ex in (24, 40):
        cx, cy = c.P(ex, 36)
        if not c.small:
            for dx in (-2, -1, 0, 1, 2):
                c.px(cx + dx, cy + (0 if abs(dx) < 2 else -1), UMBER)
        else:
            for dx in (-1, 0, 1):
                c.px(cx + dx, cy + (0 if dx == 0 else -1) + 1, UMBER)
    c.smile(32, 40, UMBER2)
    c.blush(20, 39.5)
    c.blush(43, 39.5)
    # a 'z' drifting up on the ridge, and the pink star
    zx, zy = c.P(44, 31)
    if not c.small:
        for p in [(0, 0), (1, 0), (2, 0), (1, 1), (0, 2), (1, 2), (2, 2)]:
            c.px(zx + p[0], zy + p[1], '#f2e4c0')
    sx, sy = c.P(14, 33)
    c.px(sx, sy, FOAM)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wsta-2', 'Hazy Island Nap', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsta-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsta-2.png'))
