"""pl-pgg-3 Stalactite Tap. Inner-TBTB, peg: a grotto stalactite that IS the piece. N peg tab = the rock root in the cave ceiling,
E + W peg blanks cut into the rock mass, S peg tab = the stalactite's hanging stem tapering to a point with a sky-blue drip.
Two small side stalactites on the bottom edge. Rock from the grotto arch (#aa9694 / #8c7c88), sky blue + distant gull from cell 7-1."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, UMBER2

ROCK = K.ramp('#aa9694')
ROCKD = K.ramp('#8c7c88')
SKY = K.ramp('#78b8e8')
SKYL = K.ramp('#b8e4f4')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(11, 12), (53, 12), (53, 34), (48, 43), (16, 43), (11, 34)])
    tabN = knob('T', 'peg', 32, 12, 0, -1, r=5.0 * k, nw=3.2)
    blW = knob('B', 'peg', 11, 26, -1, 0, r=4.0 * k)
    blE = knob('B', 'peg', 53, 26, 1, 0, r=4.0 * k)
    stem = poly([(25, 42), (39, 42), (36.5, 50), (32, 59), (27.5, 50)])
    spL = poly([(16, 42), (22, 42), (19.6, 48), (18.4, 48)])
    spR = poly([(42, 42), (48, 42), (45.6, 48), (44.4, 48)])
    body = c.m(core, minus=(blW, blE))
    c.add(body, ROCK, stitch='#c9b8b4')
    c.add(c.m(tabN, minus=(core,)), ROCKD)
    c.add(c.m(stem, spL, spR, minus=(core,)), ROCKD)
    # rock ridges: darker strata bands across the ceiling chunk
    for y0 in (15.5, 37):
        x0, y = c.P(14, y0)
        x1, _ = c.P(50, y0)
        for x in range(x0, x1):
            if (x // (2 if c.small else 3)) % 3 != 2:
                c.px(x, y, ROCKD[1])
    drop = c.m(ell(32, 58.5, 3.0 * k, 3.6 * k))
    c.add(drop, SKY)
    # wet sky-blue streaks running down the rock
    for sx, y0, y1 in ((19, 34, 46), (45, 35, 46), (32, 40, 52)):
        x, ya = c.P(sx, y0)
        _, yb = c.P(sx, y1)
        for y in range(ya, yb):
            c.px(x, y, SKYL[0])
    # distant gull from cell 7-1, carved high on the right
    gx, gy = c.P(40, 18.5)
    if c.small:
        for dx, dy in ((0, 1), (1, 0), (2, 1), (3, 0), (4, 1)):
            c.px(gx + dx - 2, gy + dy, UMBER2)
    else:
        for dx, dy in ((0, 1), (1, 0), (2, 0), (3, 1), (4, 0), (5, 0), (6, 1)):
            c.px(gx + dx - 3, gy + dy, UMBER2)
    c.eye(25, 27)
    c.eye(39, 27)
    c.smile(32, 33, wide=True)
    c.blush(21, 31)
    c.blush(42, 31)


K.render_pal(fn, 'pl-pgg-3', 'Stalactite Tap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-pgg-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-pgg-3.png')
