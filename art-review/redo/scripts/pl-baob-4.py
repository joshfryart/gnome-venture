# Canopy Rustle (pl-baob-4): a bushy baobab leaf-canopy pad, inner-TTTT with peg knobs.
# Concept: a square leaf clump (the green canopy of cell 2-1); N peg = a leafy top tuft, W/E pegs = leaf sprigs
# rustling out sideways, S peg = the stubby baobab trunk under it. Greens from the cell, bark tan from the trunk, pink sky blush.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path, ramp

LEAF_L = ramp('#a8d860')
LEAF = ramp('#78bc54')
LEAF_M = ramp('#48a048')
LEAF_D = ramp('#2a6a48')
BARK = ramp('#b48a5e')
PINK = '#c0607c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 17, 54, 44)
    tN = knob('T', 'peg', 32, 17, 0, -1, r=5.4 * k, nw=3.2 * k)
    tS = knob('T', 'peg', 32, 44, 0, 1, r=5.6 * k, nw=4.0 * k)
    tW = knob('T', 'peg', 10, 30, -1, 0, r=5.0 * k, nw=3.0 * k)
    tE = knob('T', 'peg', 54, 30, 1, 0, r=5.0 * k, nw=3.0 * k)
    # puffy leaf bumps on the canopy top (either side of the N tab), leaf drips along the underside
    puffs = [ell(17, 18, 5, 3.2), ell(47, 18, 5, 3.2)]
    drips = [ell(x, 44, 2.6, 2.2) for x in (14, 20, 44, 50)]
    body = c.m(core, *puffs, *drips)
    c.add(body, LEAF_M)
    c.add(c.m(lambda x, y: y < 24 + 2.0 * ((x // 5) % 2) and 8 <= x < 56) & body, LEAF_L)
    c.add(c.m(lambda x, y: y >= 38 - 2.0 * ((x // 5 + 1) % 2) and 8 <= x < 56) & body, LEAF_D)
    c.add(c.m(tN, minus=(core,)), LEAF_L)
    c.add(c.m(tW, minus=(core,)), LEAF)
    c.add(c.m(tE, minus=(core,)), LEAF)
    c.add(c.m(tS, minus=(core, *drips)), BARK)
    # leaf texture: small light flecks in each band (clumped leaves, as in the cell)
    sm = c.small
    for (x, y) in list(body):
        X, Y = x / c.k, y / c.k
        if sm:
            continue
        if (x * 3 + y * 5) % 11 == 0 and 25 < Y < 37 and not (19 < X < 45 and 26 < Y < 37):
            c.px(x, y, LEAF_M[2])
        if (x * 7 + y * 3) % 13 == 0 and Y > 39:
            c.px(x, y, LEAF_D[2])
    # leaf-row lines dividing the bands
    if not sm:
        for x0 in range(12, 51, 5):
            c.line([(x0, 25.5), (x0 + 2.5, 27), (x0 + 5, 25.5)], LEAF_D[0])
        c.line([(30, 47), (30, 57)], BARK[1])
        c.line([(34.5, 46), (34.5, 55)], BARK[1])
        c.line([(32, 3), (32, 10)], LEAF[0])
        c.line([(2, 30), (7, 30)], LEAF[1])
        c.line([(57, 30), (62, 30)], LEAF[1])
    c.eye(25, 31)
    c.eye(39, 31)
    c.smile(32, 35.5)
    c.blush(20, 34.5)
    c.blush(43, 34.5)
    if not sm:
        c.px(*c.P(20, 34.5), PINK)


K.render_pal(fn, 'pl-baob-4', 'Canopy Rustle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-baob-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-baob-4.png')
