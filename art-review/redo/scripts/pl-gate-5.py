#!/usr/bin/env python3
"""pl-gate-5 "Dawnglow Pearl": inner-BBBB, double. A rising-sun pearl: a rounded square sun with peach-to-cream rings (cell 8-2),
a little torii gate across its lower half (plum kasagi beam, vermilion tie and posts); the S blank is the gate's opening,
the N, E and W blanks are cut into the glowing sun. Mauve hill at the foot, sleepy-happy face on the sun."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

RAY = K.ramp('#fde6a8')   # pale ray streaks
R1 = K.ramp('#f6906a')   # outer sun ring
R2 = K.ramp('#fab480')
R3 = K.ramp('#fac48a')
R4 = K.ramp('#fbd495')   # sun core
BEAM = ('#36283a', '#241c2a', '#5a4e5c')
RED = ('#d8482e', '#98282a', '#ea744c')
HILL = K.ramp('#bc7e98')


def rrect(x0, y0, x1, y1, r):
    return lambda x, y: (rect(x0 + r, y0, x1 - r, y1)(x, y) or rect(x0, y0 + r, x1, y1 - r)(x, y)
                         or any(ell(cx, cy, r, r)(x, y) for cx in (x0 + r, x1 - r) for cy in (y0 + r, y1 - r)))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: rrect(8, 8, 56, 56, 13)(x, y) or rect(8, 30, 56, 56)(x, y) and rrect(8, 8, 56, 56, 4)(x, y)
    bN = knob('B', 'double', 32, 8, 0, -1, r=4.6 * k)
    bE = knob('B', 'double', 56, 27, 1, 0, r=4.4 * k)
    bW = knob('B', 'double', 8, 27, -1, 0, r=4.4 * k)
    bS = knob('B', 'double', 32, 56, 0, 1, r=4.6 * k)
    blanks = (bN, bE, bW, bS)
    body = c.m(core, minus=blanks)
    # concentric sun rings around a centre low behind the gate
    cx, cy = 32, 38
    c.add(body, K.ramp('#e8643a'))
    # sunburst rays fanning up from the sun into the top lobes
    import math
    rays = []
    for a in (-165, -138, -112, -68, -42, -15):
        t = math.radians(a)
        rays.append(K.thick_path([(cx + 14 * math.cos(t), cy + 14 * math.sin(t)), (cx + 40 * math.cos(t), cy + 40 * math.sin(t))], 3.6 if c.small else 3.0))
    c.add(body & c.m(*rays), RAY)
    c.add(body & c.m(ell(cx, cy, 22, 22)), R2)
    c.add(body & c.m(ell(cx, cy, 17, 17)), R3)
    sun = body & c.m(ell(cx, cy, 12, 12))
    c.add(sun, R4)
    # hill at the foot
    hill = body & c.m(ell(32, 70, 40, 20))
    c.add(hill, HILL)
    # torii: kasagi beam with upswept ends, tie beam, two posts
    beam = c.m(poly([(6, 37), (58, 37), (55, 42.5), (9, 42.5)]), poly([(5, 34), (12, 37.5), (8, 38.5)]),
               poly([(59, 34), (52, 37.5), (56, 38.5)])) & body
    c.add(beam, BEAM)
    tie = body & c.m(rect(13, 44, 51, 47.5))
    c.add(tie, RED)
    posts = body & c.m(rect(17, 42, 22.5, 52.5), rect(41.5, 42, 47, 52.5))
    c.add(posts, RED)
    c.edge(tie, RED[1])
    # face on the sun
    c.eye(25.5, 24)
    c.eye(38.5, 24)
    c.smile(32, 29, wide=True)
    c.blush(21, 29)
    c.blush(42, 29)
    if not c.small:
        # little sparkle top-left of the beam, as in the picture
        x, y = c.P(17, 20)
        for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
            c.px(x + d[0], y + d[1], '#ffffff')


K.render_pal(fn, 'pl-gate-5', 'Dawnglow Pearl', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gate-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gate-5.png')
