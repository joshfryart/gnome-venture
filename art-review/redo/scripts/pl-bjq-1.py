import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
R = '/home/user/gnome-venture/'
PINK = K.ramp('#f4a6d2')
DEEP = K.ramp('#d26aa8')
BODY = ('#f4a6d2', '#a05a9c', '#fcd0e8')   # shade leans reef-violet
UNDER = ('#fbc8e2', '#c87ab0', '#fde4f1')
SUCK = '#fbd6ea'


def spiral(cx, cy, r0, r1, a0, a1, n=24):
    pts = []
    for i in range(n + 1):
        t = i / n
        a = a0 + (a1 - a0) * t
        r = r0 + (r1 - r0) * t
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def tube(pts, w0, w1):
    """Tapered tentacle: discs along the path, width w0 -> w1."""
    n = len(pts)
    discs = [K.ell(x, y, (w0 + (w1 - w0) * i / (n - 1)) / 2, (w0 + (w1 - w0) * i / (n - 1)) / 2) for i, (x, y) in enumerate(pts)]
    return lambda x, y: any(d(x, y) for d in discs)


def fn(c):
    """Corner-TB, peg: a box-jelly tentacle segment. Flat W + S, peg tab N rising into a tapered curling tentacle tip, peg blank E."""
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 26, 50, 58)
    tabN = K.knob('T', 'peg', 22, 26, 0, -1, r=5.0 * k)
    blankE = K.knob('B', 'peg', 50, 43, 1, 0, r=4.4 * k)
    path = [(22, 20), (22.5, 15), (25, 10), (29, 6.5)] + spiral(36, 12, 7.2, 1.5, math.pi * 1.2, math.pi * 3.1, 30)
    curl = tube(path, 10.5, 3.6 if not c.small else 5.0)
    body = c.m(core, tabN, minus=(blankE,))
    tip = c.m(curl, minus=(core,))
    c.add(body | tip, BODY)
    # pale underside stripe with suckers down the left edge of the tentacle
    under = c.m(K.rect(12, 27, 20.5, 58)) & body
    c.add(under, UNDER)
    c.edge(under, DEEP[1])
    for sy in ((31.5, 41, 50.5) if not c.small else (32, 42, 52)):
        ring = c.m(K.ell(16.2, sy, 3.0, 3.0))
        c.add(ring, DEEP)
        c.add(c.m(K.ell(16.2, sy, 1.7, 1.7)), (SUCK, SUCK, SUCK))
    # banded tentacle lumps: darker pink wavy rings across the body
    for yb in (33, 52):
        band = c.m(lambda x, y, yb=yb: abs(y - yb - 1.3 * math.sin(x / 3.5)) < 1.5, K.rect(0, 0, 21, 64), minus=(K.rect(0, 0, 21, 64),)) & body
        c.add(band, DEEP)
    # suckers along the curl's inner side
    for i in (5, 9, 13) if not c.small else (6, 12):
        x, y = path[i]
        c.add(c.m(K.ell(x, y, 1.8, 1.8)), (SUCK, DEEP[0], '#ffffff'))
    c.eye(27, 40)
    c.eye(37, 40)
    c.blush(24, 44.5)
    c.blush(39.5, 44.5)
    c.smile(32, 44)


K.render_pal(fn, 'pl-bjq-1', 'Tentacle Wisp', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-bjq-1-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-bjq-1.png')
