# pl-mirr-5 "Peach Dawn Coin": a round peach dawn sun-coin over violet peaks; inner-BBBB double blanks on all four sides
# (top slot like a coin slot, bottom blank sits in the valley between the two violet mountains). Colours from cell 8-3.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob

HALO = K.ramp('#ffc080')
GLOW = K.ramp('#ffe098')
SUN = ('#fff4c8', '#f6d89a', '#fffbe8')
RAY = K.ramp('#f49a5c')
MTN = K.ramp('#6a58a0')
MTNL = K.ramp('#8878b8')
SALT = ('#f0e8f4', '#b8b0d8', '#f8f4fa')


def rsq(x0, y0, x1, y1, r):
    return lambda x, y: (x0 + r <= x < x1 - r and y0 <= y < y1) or (x0 <= x < x1 and y0 + r <= y < y1 - r) or any(
        (x - cx) ** 2 + (y - cy) ** 2 < r * r for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r), (x0 + r, y1 - r), (x1 - r, y1 - r)))


def fn(c):
    k = 1.12 if c.small else 1.0
    core = lambda x, y: (rsq(6, 6, 58, 58, 17)(x, y) and y < 34) or (rsq(6, 6, 58, 58, 5)(x, y) and y >= 34)
    bl = [knob('B', 'double', 32, 6, 0, -1, r=3.8 * k), knob('B', 'double', 58, 30, 1, 0, r=3.8 * k),
          knob('B', 'double', 32, 58, 0, 1, r=3.8 * k), knob('B', 'double', 6, 30, -1, 0, r=3.8 * k)]
    body = c.m(core, minus=bl)
    c.add(body, HALO)
    import math
    rays = []
    for i in range(8):
        a = math.radians(i * 45 + 22.5)
        dx, dy = math.cos(a), math.sin(a)
        px_, py_ = -dy, dx
        rays.append(poly([(32 + 17 * dx + 3.2 * px_, 27 + 17 * dy + 3.2 * py_), (32 + 26 * dx, 27 + 26 * dy),
                          (32 + 17 * dx - 3.2 * px_, 27 + 17 * dy - 3.2 * py_)]))
    c.add(body & c.m(*rays), RAY)
    c.add(body & c.m(ell(32, 27, 17.5, 17.5)), GLOW)
    disc = body & c.m(ell(32, 27, 14, 14))
    c.add(disc, SUN, stitch=None if c.small else '#f6d89a')
    rng = body & c.m(poly([(4, 60), (4, 44), (14, 37), (22, 42), (32, 35), (42, 42), (50, 37), (60, 44), (60, 60)]))
    c.add(rng, MTN)
    c.add(body & c.m(poly([(14, 37), (9, 41), (13, 40.5), (16, 42), (18, 39.5)]),
                     poly([(32, 35), (27, 39), (30, 38.5), (33, 40.5), (35, 37.5)]),
                     poly([(50, 37), (45, 41), (48, 40.5), (51, 42), (54, 40)])), MTNL)
    c.add(body & c.m(rect(0, 50, 64, 64)), SALT)
    c.eye(27, 24)
    c.eye(37, 24)
    c.smile(32, 29)
    c.blush(23.5, 28)
    c.blush(40, 28)


print(K.render_pal(fn, 'pl-mirr-5', 'Peach Dawn Coin', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-5-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-5.png'))
