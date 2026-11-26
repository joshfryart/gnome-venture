#!/usr/bin/env python3
"""ow-sun-glint "Sun Glint": inner-TTTT, tri. A setting sun that IS an inner piece: a rounded-square gold body whose four tri tabs are
its rays (N, E, W gold rays; the S ray is the sea reflection streak). The lower body dips into the sea band with white glints, a
purple island hump on the horizon (cell 2-2: pale sunset sky, plum island, sea blue). Face winks (blurb)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SUN = K.ramp('#f8c860')
CORE = K.ramp('#fff1b0')
RAY = K.ramp('#f6a84a')
SEA = K.ramp('#6fb7d0')
ISLE = K.ramp('#7a5a67')
WHITE = '#ffffff'


def rrect(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 < r * r
    return f


def tri_tab(mx, my, nx, ny, k):
    """Tri-knob tab with a visible neck: a short neck, then a wide triangular head (the sun's ray)."""
    ax, ay = -ny, nx
    nw, nl, hw, hh = 3.4 * k, 2.4, 6.4 * k, 7.0 * k

    def f(x, y):
        px, py = x - mx, y - my
        u, v = px * ax + py * ay, px * nx + py * ny
        if -2 < v < nl + 0.5 and abs(u) < nw:
            return True
        return nl <= v < nl + hh and abs(u) < hw * (1 - (v - nl) / hh) + 0.4
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 15, 15, 49, 49
    core = rrect(x0, y0, x1, y1, 9)
    tN = tri_tab(32, y0, 0, -1, k)
    tE = tri_tab(x1, 32, 1, 0, k)
    tW = tri_tab(x0, 32, -1, 0, k)
    tS = tri_tab(32, y1, 0, 1, k)
    body = c.m(core)
    c.add(body, SUN)
    c.add(c.m(tN, tE, tW, minus=(core,)), RAY)
    sea_y = 39.5
    # warm inner disc: the sun's bright heart
    c.add(c.m(K.ell(32, 29, 12.5, 11.5)) & body, CORE)
    # plum island hump on the horizon (left), sea band across the bottom with the S ray as the reflection streak
    isle = c.m(K.poly([(14, sea_y), (14, 35), (17, 33), (19, 30.5), (21, 33), (24, 32), (26, 35), (30, 37.5), (33, sea_y)])) & body
    c.add(isle, ISLE)
    wave = lambda x, y: y >= sea_y + (0.8 if (x // 4) % 2 else 0)
    sea = c.m(wave) & body
    c.add(sea | c.m(tS, minus=(core,)), SEA)
    # glints on the water: short white dashes
    for (gx, gy, w) in ((20, 43.5, 4), (35, 42.5, 6), (27, 46.5, 4), (41, 46, 3)):
        a = c.P(gx, gy)
        b = c.P(gx + w, gy)
        for x in range(a[0], max(b[0], a[0] + 1)):
            c.px(x, a[1], WHITE)
    # reflection streak down the S ray
    a = c.P(32, sea_y + 1)
    for y in range(a[1], c.P(0, 56)[1]):
        c.px(a[0], y, CORE[0] if y % 2 == 0 else WHITE)
    # twinkle glint top-left (the "glint")
    gx, gy = c.P(21.5, 21.5)
    for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(gx + d[0], gy + d[1], WHITE)
    if not c.small:
        for d in ((2, 0), (-2, 0), (0, 2), (0, -2)):
            c.px(gx + d[0], gy + d[1], WHITE)
    # face: open left eye, winking right eye, smile, blush
    c.eye(27, 29)
    wx, wy = c.P(37, 29)
    if not c.small:
        for dx, dy in ((-2, 0), (-1, -1), (0, -1), (1, -1), (2, 0)):
            c.px(wx + dx, wy + dy, K.UMBER)
    else:
        for dx, dy in ((-1, 0), (0, -1), (1, 0)):
            c.px(wx + dx, wy + dy, K.UMBER)
    c.smile(32, 34, wide=True)
    c.blush(24.5, 32.5)
    c.blush(40, 33)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'ow-sun-glint', 'Sun Glint', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/ow-sun-glint-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/ow-sun-glint.png'))
