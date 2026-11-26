"""pl-trng-3 Cellar Apple Gleam: inner-TBTB keyhole. A red apple whose body is the piece core: stem = keyhole tab N (bark brown + moss leaf),
moss mound = keyhole tab S, keyhole blanks W and E bitten into the apple. Gleam highlight upper left. Colours: stump bark + moss from cell 6-7."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#c8302a')
BARK = K.ramp('#6a3a22')
MOSS = K.ramp('#3a8a4a')
LEAF = K.ramp('#7ab040')
GLOW = '#fbe6a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    # apple core: a fat rounded square (superellipse) with two shoulder lobes beside the stem dip
    sq = lambda x, y: abs((x - 32) / 22.5) ** 3 + abs((y - 35) / 18.5) ** 3 < 1
    core = lambda x, y: sq(x, y) or K.ell(22, 21, 10.5, 6)(x, y) or K.ell(42, 21, 10.5, 6)(x, y)
    tabN = K.knob('T', 'keyhole', 32, 17.5, 0, -1, r=4.6 * k)
    tabS = K.knob('T', 'keyhole', 32, 51.5, 0, 1, r=5.0 * k, nw=4.2)
    blW = K.knob('B', 'keyhole', 9.5, 37, -1, 0, r=3.6 * k, nw=2.0)
    blE = K.knob('B', 'keyhole', 54.5, 37, 1, 0, r=3.6 * k, nw=2.0)
    apple = c.m(core, minus=(blW, blE))
    c.add(apple, RED, stitch=None if c.small else '#e86a50')
    # stem tab (bark)
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 14, 64, 18))), BARK)
    # leaf off the stem, to the upper right
    c.add(c.m(K.poly([(36, 9), (44, 4), (52, 6), (47, 12), (38, 12)])), LEAF)
    if not c.small:
        c.line([(38, 10), (49, 6.5)], LEAF[1])
    # bottom tab: the apple's own blossom end (red), with a moss skirt hugging the apple's base on both sides (it sits in the moss)
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 51, 64, 55))), RED)
    c.add(apple & c.m(lambda x, y: y > 46 + (2 if (int(x) // 3) % 2 else 0), minus=(K.rect(24, 0, 40, 64),)), MOSS)
    if not c.small:
        c.px(*c.P(31, 58), RED[1])
        c.px(*c.P(32, 58), RED[1])
    # gleam: big soft highlight upper left
    c.add(c.m(K.ell(20, 24, 4.2, 3.2)) & apple, (GLOW, GLOW, GLOW))
    c.px(*c.P(26, 21), GLOW)
    # face
    c.eye(26, 31)
    c.eye(38, 31)
    c.smile(32, 38)
    c.blush(21, 36)
    c.blush(42, 36)


K.render_pal(fn, 'pl-trng-3', 'Cellar Apple Gleam', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-trng-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-trng-3.png')
