#!/usr/bin/env python3
"""pl-spsk-1 Awning Flutter (corner-TT, round): a souk stall awning that IS a corner piece.
Flat N side = the wooden awning rod, flat W side = the awning's straight left hem; round tab E = a corner flap of the canopy
fluttering out in the wind, round tab S = the middle scallop of the valance with a gold tassel. Red and cream stripes from the
souk's checker floor and sand wall, gold from the lamps, and the cell's four-point star glint (cell 2-0) on the canopy."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d05054')
CREAMR = K.ramp('#f8d8a8')
ROD = K.ramp('#b86e44')
GOLD = K.ramp('#e8ac58')
TAN = K.ramp('#ecc090')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(7, 9, 51, 50)
    tabE = K.knob('T', 'round', 51, 29, 1, 0, r=5.2 * k, nw=3.2)
    tabS = K.knob('T', 'round', 28, 50, 0, 1, r=5.4 * k, nw=3.4)
    scx = (10.5, 17.5, 38.5, 45.5) if not c.small else (11, 18, 38.5, 46)
    scal = [K.ell(x, 49.5, 3.6, 4.2) for x in scx]
    body = c.m(core, tabE, tabS, *scal)
    c.add(body, CREAMR)
    # vertical stripes over the canopy and the E flap (red on even bands)
    sw = 7.0
    stripes = c.m(lambda x, y: 15 <= y < 50 and int((x - 7) // sw) % 2 == 0) & body
    flap = c.m(tabE, minus=(core,))
    c.add(stripes - flap, RED)
    c.add(flap & c.m(lambda x, y: y < 30), RED)
    c.add(flap & c.m(lambda x, y: y >= 30), CREAMR)
    # wooden rod along the flat N side, with knob ends
    c.add(c.m(K.rect(7, 9, 51, 15)), ROD)
    # valance band (red) with cream scallops, and the S scallop tab
    val = c.m(K.rect(7, 43, 51, 50))
    sc = c.m(tabS, minus=(core,))
    c.add(sc, RED)
    for i, e in enumerate(scal):
        c.add(c.m(e, minus=(core,)), RED if i % 2 == 0 else CREAMR)
    # gold trim where the valance hangs from the canopy
    c.add(c.m(K.rect(7, 42, 51, 44.6 if c.small else 44)), GOLD)
    # gold tassel at the bottom of the S scallop and a gold rim on the flap
    c.add(c.m(K.ell(28, 60, 2.8 * k, 2.4 * k)), GOLD)
    # rod grain + rings
    if not c.small:
        c.line([(9, 12), (49, 12)], ROD[1])
    for rx in (14, 44):
        x, y = c.P(rx, 9)
        for dy in range(c.P(0, 15)[1] - y):
            c.px(x, y + dy, GOLD[0])
    # the cell's four-point star glint, gold on the canopy
    sx, sy = c.P(44, 21)
    arm = 1 if c.small else 2
    for d in range(-arm, arm + 1):
        c.px(sx + d, sy, '#fff0c0')
        c.px(sx, sy + d, '#fff0c0')
    # face: on the canopy middle
    c.eye(21.5, 29, disc=True)
    c.eye(36.5, 29, disc=True)
    c.smile(29, 35.5, wide=True)
    c.blush(16.5, 34)
    c.blush(41.5, 34)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-spsk-1', 'Awning Flutter', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-spsk-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-spsk-1.png')
    print(rep)
