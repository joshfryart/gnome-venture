"""pl-sugr-2 Tapper Tip: edge-BTB, peg. A red-hatted maple-tapper gnome whose square body IS the piece: flat S (boots on the snow),
peg tab N = the tip of his red stocking cap (snow-capped), peg blanks W + E bite into his log-wood coat at the belt. Coat in the
sugar-shack log orange with dark log seams (cell 3-5), snowy beard with lavender snow shade, plum boots like the fence posts."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

HAT = ramp('#c8362a')
COAT = ramp('#d98c3c')
SKIN = ramp('#f0b48a')
BEARD = ('#f2f0f6', '#a8acd4', '#ffffff')
BOOT = ramp('#4a3448')
SNOW = ('#f2f0f6', '#b8bce0', '#ffffff')
METAL = ramp('#9aa0b8')
SYRUP = '#c8761a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 21, 52, 58)
    tabN = knob('T', 'peg', 32, 21, 0, -1, r=5.0 * k)
    blW = knob('B', 'peg', 12, 44, -1, 0, r=3.8 * k)
    blE = knob('B', 'peg', 52, 44, 1, 0, r=3.8 * k)
    # cap slopes: shave the two top corners so the red top reads as a cone stub, straight sides stay below
    slopeW = poly([(0, 0), (22, 0), (22, 21), (12, 29), (0, 29)])
    slopeE = poly([(64, 0), (42, 0), (42, 21), (52, 29), (64, 29)])
    body = c.m(core, tabN, minus=(blW, blE, slopeW, slopeE))
    c.add(body, COAT, stitch=None)
    # log seams on the coat (the cabin wall)
    beard = c.m(poly([(20, 38), (44, 38), (41, 48), (35, 53), (32, 54.5), (29, 53), (23, 48)]))
    for sy in (43, 50):
        y = c.P(0, sy)[1]
        for x in range(c.n):
            if (x, y) in body and (x, y) not in beard:
                c.px(x, y, COAT[1])
    # red stocking cap: top band + the peg tab, tip leaning a touch
    hat = c.m(rect(0, 0, 64, 31), tabN) & body
    c.add(hat, HAT, stitch=None)
    # snow on the cap tip
    c.add(c.m(ell(32, 9.5, 5, 3.2)) & body, SNOW)
    # fur brim
    c.add(c.m(rect(12, 29, 52, 32.5)) & body, SNOW)
    # face
    c.add(c.m(rect(17, 32.5, 47, 40)) & body, SKIN)
    # beard: scalloped snowy beard down the front
    c.add(beard & body, BEARD)
    # nose
    c.add(c.m(ell(32, 39, 3.4, 2.8)), ramp('#e8806a'))
    # boots on the flat side
    c.add(c.m(rect(14, 54, 29, 58), rect(35, 54, 50, 58)) & body, BOOT)
    # tapper's spile in his fist on the E side with a syrup drop
    c.add(c.m(rect(42, 50.5, 52, 54.5)) & body, METAL)
    c.add(c.m(rect(40, 49.5, 44, 55.5)) & body, ramp('#e8b090'))
    c.px(*c.P(50.5, 55.5), SYRUP)
    if not c.small:
        c.px(*c.P(50.5, 56.5), SYRUP)
    c.eye(26, 35.5)
    c.eye(38, 35.5)
    c.blush(21, 37.5)
    c.blush(42, 37.5)


K.render_pal(fn, 'pl-sugr-2', 'Tapper Tip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-2.png')
