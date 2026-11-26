#!/usr/bin/env python3
"""pl-silk-4 "Starry Tilework": inner-TTTT, keyhole. A glazed teal gate tile (the caravanserai dome teal) whose square body IS the piece,
four keyhole tabs (N/E/S/W) glazed like the tile's own rim. A big gold eight-point star (the gate's star tilework) fills the face;
four little gold stars in the corners, a brick-tan grout rim from the cell's brick wall, an orange-sky blush."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

TEAL = K.ramp('#2f7fa8')
DEEP = K.ramp('#2d696b')
GOLD = ('#f0c040', '#b8862a', '#ffe98a')
BRICK = K.ramp('#d6a474')
SKY = '#f09a6a'


def star(cx, cy, ro, ri, n=8, rot=0.0):
    pts = []
    for i in range(2 * n):
        a = rot + math.pi * i / n - math.pi / 2
        r = ro if i % 2 == 0 else ri
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return K.poly(pts)


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 15, 15, 49, 49
    rr = 3.5
    core = lambda x, y: x0 <= x < x1 and y0 <= y < y1 and not (
        min(x - x0, x1 - x) < rr and min(y - y0, y1 - y) < rr and
        (min(x - x0, x1 - x) - rr) ** 2 + (min(y - y0, y1 - y) - rr) ** 2 > rr * rr)
    tabs = [K.knob('T', 'keyhole', 32, y0, 0, -1, r=(7.0 if not c.small else 7.4), nw=2.4),
            K.knob('T', 'keyhole', x1, 32, 1, 0, r=(7.0 if not c.small else 7.4), nw=2.4),
            K.knob('T', 'keyhole', 32, y1, 0, 1, r=(7.0 if not c.small else 7.4), nw=2.4),
            K.knob('T', 'keyhole', x0, 32, -1, 0, r=(7.0 if not c.small else 7.4), nw=2.4)]
    body = c.m(core)
    c.add(c.m(core, *tabs), DEEP)
    # glazed tile field inside a brick grout rim
    g = 2.6 if c.small else 2.2
    inner = c.m(K.rect(x0 + g, y0 + g, x1 - g, y1 - g))
    c.add(body - inner, BRICK)
    c.add(inner, TEAL)
    c.edge(inner, DEEP[1])
    # tabs: glossy teal knobs with a gold boss
    for t in tabs:
        c.add(c.m(t, minus=(core,)), TEAL)
    for (bx, by) in ((32, 5.5), (58.5, 32), (32, 58.5), (5.5, 32)):
        cx, cy = c.P(bx, by)
        c.px(cx, cy, GOLD[0])
        if not c.small:
            c.px(cx - 1, cy, GOLD[0]); c.px(cx, cy - 1, GOLD[2]); c.px(cx - 1, cy - 1, GOLD[2])
    # big eight-point star
    h = 10.2
    sq = K.rect(32 - h, 32 - h, 32 + h, 32 + h)
    dia = lambda x, y: abs(x - 32) + abs(y - 32) < h * 1.414
    big = c.m(sq, dia)
    c.add(big, GOLD)
    c.edge(big, GOLD[1])
    # small corner stars
    for (sx, sy) in ((21.5, 21.5), (42.5, 21.5), (21.5, 42.5), (42.5, 42.5)):
        if c.small:
            cx, cy = c.P(sx, sy)
            for d in ((0, 0), (1, 0), (0, 1), (1, 1), (-1, 0), (2, 0)):
                pass
            for d in ((0, -1), (-1, 0), (0, 0), (1, 0), (0, 1)):
                c.px(cx + d[0], cy + d[1], GOLD[2])
        else:
            c.add(c.m(star(sx, sy, 3.2, 1.4, n=4)), GOLD)
    # face on the star
    c.eye(28, 31)
    c.eye(36, 31)
    c.smile(32, 36)
    c.px(*c.P(25, 35.5), SKY)
    c.px(*c.P(39, 35.5), SKY)
    if not c.small:
        cx, cy = c.P(25, 35.5); c.px(cx + 1, cy, SKY)
        cx, cy = c.P(39, 35.5); c.px(cx - 1, cy, SKY)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-silk-4', 'Starry Tilework', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-4.png'))
