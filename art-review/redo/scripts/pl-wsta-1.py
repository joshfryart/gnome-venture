#!/usr/bin/env python3
"""pl-wsta-1 "Dot-to-Dot Sky": a corner piece cut from the starry night sky (flat top + left, keyhole tab S, keyhole blank E).
Night bands from the picture (#161850 / #1e2062 / #2a2c78 + the mauve horizon), gold star dots joined by lavender lines, a crescent moon."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

NIGHT0 = K.ramp('#1e2062')
NIGHT1 = K.ramp('#2a2c78')
NIGHT2 = K.ramp('#3a3a8a')
DUSK = K.ramp('#8a5aa0')
MOON = ('#fff1cf', '#e8c070', '#ffffff')
STAR = '#f5cf6a'
STARHI = '#fff1cf'
LINE = '#8a8ad8'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 5, 5, 51, 50
    core = K.rect(x0, y0, x1, y1)
    tabS = K.knob('T', 'keyhole', 27, y1, 0, 1, r=5.6 * k, nw=3.0)
    blkE = K.knob('B', 'keyhole', x1, 31, 1, 0, r=5.4 * k, nw=3.0)
    # rounded outer corners (keep the flat top/left reading as a corner)
    cutc = [K.rect(x0, y0, x0 + 2, y0 + 2), K.rect(x1 - 2, y0, x1, y0 + 2),
            K.rect(x0, y1 - 2, x0 + 2, y1), K.rect(x1 - 2, y1 - 2, x1, y1)]
    body = c.m(core, tabS, minus=[blkE] + cutc)
    c.add(body, NIGHT0, stitch=None if c.small else '#3a3a8a')
    # sky bands, wavy like the picture's clouds
    c.add(body & c.m(K.poly([(0, 30), (14, 27), (26, 30), (40, 26), (64, 29), (64, 64), (0, 64)])), NIGHT1)
    c.add(body & c.m(K.poly([(0, 43), (16, 40), (30, 43), (46, 39), (64, 42), (64, 64), (0, 64)])), DUSK)
    # the hanging keyhole tab: a bit of night with a gold star in its bulb (the last dot of the chart)
    c.add(c.m(tabS, minus=(core,)), NIGHT1)
    c.line([(23, 47), (27, 57)], LINE)
    tx, ty = c.P(27, 57.5 + (0.6 if c.small else 0))
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)) + (() if c.small else ((2, 0), (-2, 0), (0, 2), (0, -2), (1, 1), (-1, -1), (1, -1), (-1, 1))):
        c.px(tx + dx, ty + dy, STAR)
    c.px(tx, ty, STARHI)
    # crescent moon, top right
    moon = c.m(K.ell(41, 14, 5.2, 5.2), minus=(K.ell(43.6, 12, 4.6, 4.6),))
    c.add(moon, MOON)
    # constellation: gold dots joined by lines (dot-to-dot), a dipper over the brow
    stars = [(11, 12), (18, 18), (26, 13), (33, 20), (31, 26), (20, 25)]
    c.line(stars[:4], LINE)
    c.line([stars[3], stars[4], stars[5], stars[1]], LINE)
    for i, (sx, sy) in enumerate(stars):
        x, y = c.P(sx, sy)
        big = i in (0, 3)
        if c.small:
            c.px(x, y, STAR)
            if big:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    c.px(x + dx, y + dy, STAR)
                c.px(x, y, STARHI)
            else:
                c.px(x + 1, y, STAR)
        else:
            for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
                c.px(x + dx, y + dy, STAR)
            c.px(x, y, STARHI)
            if big:
                for dx, dy in ((-1, 0), (2, 0), (0, -1), (1, -1), (0, 2), (1, 2), (-1, 1), (2, 1)):
                    c.px(x + dx, y + dy, STAR)
    # tiny far stars sprinkled
    for sx, sy in ((45, 24), (47, 44), (13, 46), (37, 30), (8, 30)):
        x, y = c.P(sx, sy)
        c.px(x, y, STARHI)
    # face on the calm middle band
    c.eye(15, 34, disc=True)
    c.eye(30, 34, disc=True)
    c.smile(22.5, 38, col=STARHI)
    c.blush(10, 38)
    c.blush(35, 38)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wsta-1', 'Dot-to-Dot Sky', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsta-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsta-1.png')
    print(rep)
