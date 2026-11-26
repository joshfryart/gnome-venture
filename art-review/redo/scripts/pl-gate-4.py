#!/usr/bin/env python3
"""pl-gate-4 "Redgate Staircase": a red torii gate that IS an inner-TTTT keyhole piece.
Square core = the gate: dark kasagi roof beam on top, red beam with the face, red pillars with dark feet on W/E,
grey cobbled path inside with a smaller red gate behind (the receding gates). Keyhole tabs: N = the gate's name
plaque, W + E = the nuki crossbar ends poking out past the pillars, S = a grey stone step of the path (cell 5-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

RED = ramp('#c8422e')
RED2 = ramp('#98282a')
ROOF = ('#36283a', '#241c2a', '#5a4a5e')
STONE = ramp('#7a6e76')
STONE_L = ramp('#9a8e90')
STONE_D = ramp('#5a4e5c')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')


def fn(c):
    k = 1.0
    x0, y0, x1, y1 = 12, 15, 52, 52
    core = rect(x0, y0, x1, y1)
    tabN = knob('T', 'keyhole', 32, y0, 0, -1, r=5.0 * k)
    tabW = knob('T', 'keyhole', x0, 28.5, -1, 0, r=5.0 * k)
    tabE = knob('T', 'keyhole', x1, 28.5, 1, 0, r=5.0 * k)
    tabS = knob('T', 'keyhole', 32, y1, 0, 1, r=5.0 * k)
    # grey path fills the whole piece first
    body = c.m(core)
    c.add(body, STONE)
    c.add(c.m(tabS, minus=(core,)), STONE)
    # light path receding up the middle
    c.add(c.m(poly([(30, 38), (34, 38), (40, 56), (24, 56)])), STONE_L)
    # receding gates behind: middle and far
    c.add(c.m(rect(23.5, 33, 26.5, 50), rect(37.5, 33, 40.5, 50)), RED2)
    c.add(c.m(poly([(21, 31), (43, 31), (42, 34), (22, 34)])), ROOF)
    c.add(c.m(rect(28.5, 38, 30.2, 46), rect(33.8, 38, 35.5, 46)), RED2)
    c.add(c.m(rect(27.5, 36.5, 36.5, 38.5)), ROOF)
    # pillars with dark feet
    c.add(c.m(rect(x0, 22, 19.5, y1), rect(44.5, 22, x1, y1)), RED)
    c.add(c.m(rect(x0, 47.5, 19.5, y1), rect(44.5, 47.5, x1, y1)), ROOF)
    # nuki crossbar + its tab ends (W/E keyhole tabs)
    c.add(c.m(rect(x0, 27, x1, 30), tabW, tabE), RED)
    # top red beam (face) and dark kasagi roof with upturned ends
    c.add(c.m(rect(x0, 18, x1, 25)), RED)
    c.add(c.m(poly([(x0, y0 - 2.5), (20, y0 + 0.5), (44, y0 + 0.5), (x1, y0 - 2.5), (x1, 19), (x0, 19)])), ROOF)
    # plaque tab
    c.add(c.m(tabN, minus=(core,)), ROOF)
    px, py = c.P(32, 9.5 if not c.small else 9.0)
    for dy in range(0, 3 if not c.small else 2):
        c.px(px, py + dy, GOLD[0])
        if not c.small:
            c.px(px - 1, py + dy, GOLD[0])
    # cobbles
    for (cx, cy) in [(21.5, 37), (42, 40), (21.5, 44), (42, 46), (27.5, 50)]:
        x, y = c.P(cx, cy)
        c.px(x, y, STONE_D[0])
        if not c.small:
            c.px(x + 1, y, STONE_D[0])
    # face on the red beam
    c.eye(25, 21.5, disc=not c.small)
    c.eye(39, 21.5, disc=not c.small)
    if not c.small:
        c.smile(32, 22)
    else:
        x, y = c.P(32, 23)
        c.px(x, y, K.UMBER)
        c.px(x - 1, y, K.UMBER)
    c.blush(19.5, 23)
    c.blush(44, 23)

if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-gate-4', 'Redgate Staircase', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gate-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gate-4.png')
    print(rep)
