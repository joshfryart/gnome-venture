"""pl-labi-1 Cypress Candle: corner-TT, keyhole. A dark cypress that is a green candle. Flat W + S (S = the sand maze path it stands in),
keyhole tab N = the candle flame on the tree's tip (gold, like the island's central candle), keyhole tab E = a bright hedge tuft from the maze.
Hedge greens + sand from cell 11-5."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CYP = K.ramp('#2e7a44')
CYPD = ('#1a4a38', '#123428', '#2e7a44')
HEDGE = K.ramp('#58b048')
LEAF = '#bef06a'
SAND = K.ramp('#f4dc9c')
FLAME = ('#f0a020', '#c06a10', '#f8d060')


def fn(c):
    k = 1.15 if c.small else 1.0
    # tall cypress column (also a green candle), rounded crown, standing on a wide sand base (flat S, flat W through the base)
    colp = (K.rect(13, 28, 51, 58), K.rect(23, 15, 41, 30), K.ell(23, 28, 10, 13), K.ell(41, 28, 10, 13))
    col = c.m(*colp)
    base = col & c.m(K.rect(0, 51, 64, 64))
    tabN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'keyhole', 51, 38, 1, 0, r=4.6 * k)
    flame = c.m(tabN, minus=(K.rect(0, 15.5, 64, 64),))
    tuft = c.m(tabE, minus=(K.rect(0, 0, 50.5, 64),))
    c.add(col, CYP)
    # scale tufts: upward-pointing flame-like tips in light and dark green
    step = 8 if not c.small else 10
    for ty in range(16, 48, step):
        for tx in range(15, 50, 5 if not c.small else 7):
            ox = 3 if ((ty - 18) // step) % 2 else 0
            tri = K.poly([(tx + ox - 1.9, ty + 8), (tx + ox - 0.6, ty + 2), (tx + ox, ty), (tx + ox + 0.6, ty + 2), (tx + ox + 1.9, ty + 8)])
            m = c.m(tri) & col
            c.add(m, CYPD if tx + ox > 32 else K.ramp('#3e8e4c'))
    c.add(base, SAND)
    if not c.small:
        for (x, y) in ((16, 54), (22, 56), (42, 53), (47, 56), (36, 56)):
            c.px(*c.P(x, y), '#d8b078')
    c.add(flame, FLAME)
    c.add(c.m(K.ell(32, 5.0, 2.0 * k, 2.6 * k)) & flame, ('#f8d060', '#f0a020', '#fff4d6'))
    c.add(tuft, HEDGE)
    if not c.small:
        for (x, y) in ((57, 36), (59, 38)):
            c.px(*c.P(x, y), LEAF)
    c.eye(25.5, 37, disc=True)
    c.eye(38.5, 37, disc=True)
    c.smile(32, 43, '#f2e4c0')


K.render_pal(fn, 'pl-labi-1', 'Cypress Candle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-1.png')
