#!/usr/bin/env python3
"""pl-wpry-5 "Stone Doughnuts": inner-BBBB, keyhole. A little cairn of three stacked stone doughnuts IS the square piece: the stones stack
into the body (notched seams on the sides), each has its dark doughnut hole; keyhole blanks bite into all four sides (N into the top stone,
E/W into the middle stone, S between the bottom stone's 'feet'). A wish flag on a thin pole tops the cairn. Stupa cream, mauve-grey stone,
the stupa's red band as a ribbon, slate-blue holes (cell 6-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CREAM = K.ramp('#f4e8d4')
STONE = K.ramp('#cdb0a8')
STONE2 = K.ramp('#e6d2c0')
RED = ('#c43e4e', '#8e2a52', '#e0707a')
SLATE = '#5e6694'
POLE = K.WOOD
FLAGY = ('#f0c030', '#b08a20', '#f8e080')
FLAGB = ('#3f7fc8', '#2c5a8e', '#8ab4e4')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 7, 57, 16, 58
    s1, s2 = 28, 41.5            # seams between the stones
    def pill(ya, yb, xa=x0, xb=x1):
        cx, cy, rx, ry = (xa + xb) / 2, (ya + yb) / 2, (xb - xa) / 2, (yb - ya) / 2
        return lambda x, y: abs((x - cx) / rx) ** 3 + ((y - cy) / ry) ** 2 < 1
    pT, pM, pB = pill(y0, s1 + 0.6, x0 + 1.5, x1 - 1.5), pill(s1 - 0.6, s2 + 0.6), pill(s2 - 0.6, y1, x0 - 0.5, x1 + 0.5)
    bN = K.knob('B', 'keyhole', 32, y0, 0, -1, r=2.8 * k, nw=2.0)
    bS = K.knob('B', 'keyhole', 32, y1, 0, 1, r=2.4 * k, nw=1.8)
    bE = K.knob('B', 'keyhole', x1, 34.8, 1, 0, r=2.7 * k, nw=2.0)
    bW = K.knob('B', 'keyhole', x0, 34.8, -1, 0, r=2.7 * k, nw=2.0)
    minus = (bN, bS, bE, bW)
    # wish pole and flag (top right, clear of the N blank)
    pole = c.m(K.rect(45, 3, 47.6 if not c.small else 48.2, y0 + 1))
    c.add(pole, POLE)
    flag = c.m(K.poly([(47, 3.5), (58, 6.5), (47, 11.5)]))
    c.add(flag, RED)
    c.add(flag & c.m(K.rect(0, 0, 64, 7.5)), FLAGY)
    body = c.m(pT, pM, pB, minus=minus)
    top = c.m(pT, minus=minus)
    mid = c.m(pM, minus=minus) - top
    bot = body - top - mid
    c.add(bot, CREAM)
    c.add(mid, STONE)
    c.add(top, STONE2)
    for m in (top, mid, bot):
        c.edge(m, '#8e6e68')
    # red ribbon tied round the bottom stone (the stupa's red band)
    rib = bot & c.m(K.rect(0, 43.5, 64, 46 if not c.small else 46.5))
    c.add(rib, RED)
    # pillow profile: each stone darkens toward its lower seam (a fat rounded ring seen from the side)
    for m, (b, d, l) in ((top, STONE2), (mid, STONE), (bot, CREAM)):
        ys = [y for (_, y) in m]
        lo = max(ys)
        band = {(x, y) for (x, y) in m if y >= lo - (2 if not c.small else 1)}
        c.add(band, (d, d, d))
    # the top stone seen a little from above: a lighter top face ring around the N blank, which becomes the doughnut's hole
    ring = c.m(K.ell(32, y0 + 3.2, 13, 3.6 if not c.small else 4.0), minus=minus) & top
    c.add(ring, ('#fff4e4', '#e6d2c0', '#fff9ee'))
    c.edge(ring, '#b8968c')
    lip = c.m(K.knob('B', 'keyhole', 32, y0, 0, -1, r=2.8 * k + 1.3, nw=3.2)) & top
    c.add(lip, ('#8a90b8', '#5e6694', '#8a90b8'))
    # top surface sheen on each stone
    if not c.small:
        for m, yy in ((top, y0 + 2), (mid, s1 + 1), (bot, s2 + 1)):
            for (x, y) in m:
                if y == c.P(0, yy)[1] and (x + y) % 3 == 0:
                    c.px(x, y, '#fff9ea')
    # face on the middle stone, between the E/W blanks
    c.eye(25, 34, look=(0, 0))
    c.eye(39, 34, look=(0, 0))
    c.smile(32, 37.5)
    c.blush(21.5, 37.5)
    c.blush(41.5, 37.5)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wpry-5', 'Stone Doughnuts', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpry-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpry-5.png')
    print(rep)
