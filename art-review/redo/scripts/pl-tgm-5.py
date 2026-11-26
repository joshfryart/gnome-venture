#!/usr/bin/env python3
"""pl-tgm-5 Moonhoop: inner-BBBB, double. A night-sky square piece (teal/navy of cell 11-1) whose body is a big full moon
ringed by a gold hoop, with a sleepy moon face; four double blanks bite the moon at N/E/S/W like a hoop's notches,
and a little tiger moth (brown-cream striped forewings, red hindwings) flutters through the hoop at the upper right."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

SKY = ramp('#143a48')
SKY2 = ramp('#2c4b51')
MOON = ramp('#fff1cf')
HOOP = ramp('#e8b048')
BROWN = ramp('#6a3e34')
RED = ramp('#c03030')
CREAMS = '#f4e2b8'
BLUE = '#66b2fa'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(6, 6, 58, 58)
    bl = [knob('B', 'double', 32, 6, 0, -1, r=4.2 * k), knob('B', 'double', 58, 32, 1, 0, r=4.2 * k),
          knob('B', 'double', 32, 58, 0, 1, r=4.2 * k), knob('B', 'double', 6, 32, -1, 0, r=4.2 * k)]
    body = c.m(core, minus=bl)
    c.add(body, SKY)
    # lighter teal diagonal band (cell's lower-right wedge)
    c.add(body & c.m(poly([(38, 58), (58, 38), (58, 58)])), SKY2)
    hoop = ell(32, 32.5, 15.5, 15.5)
    moon = ell(32, 32.5, 12.8, 12.8)
    c.add(body & c.m(hoop), HOOP)
    mm = c.add(body & c.m(moon), MOON, stitch='#e6d4a8')
    c.edge(mm, HOOP[1])
    # craters
    for (x, y, r) in ((25, 39, 2.0), (37, 25, 1.4), (39, 39.5, 1.3)):
        for p in c.m(ell(x, y, r, r)):
            if p in mm:
                c.px(p[0], p[1], '#e9d7ae')
    # stars in the sky corners
    for (sx, sy) in ((10, 10), (54, 54), (10, 54)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#fff3cc')
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], '#9fc8c0')
    # face
    c.eye(27.5, 32.5)
    c.eye(36.5, 32.5)
    c.smile(32, 37)
    c.blush(24, 36)
    c.blush(39.5, 36)
    # tiger moth flying through the hoop (upper right)
    mx, my = 46, 15
    hw = [ell(mx + 4.5, my + 4.5, 4, 3.2), ell(mx - 4.5, my + 4.5, 4, 3.2)]
    fw = [poly([(mx + 1, my + 1), (mx + 5, my - 6), (mx + 10, my - 6), (mx + 11, my - 3), (mx + 6, my + 2.5)]),
          poly([(mx - 1, my + 1), (mx - 5, my - 6), (mx - 10, my - 6), (mx - 11, my - 3), (mx - 6, my + 2.5)])]
    c.add(c.m(*hw), RED)
    fwm = c.add(c.m(*fw), BROWN)
    c.edge(fwm, K.UMBER2)
    c.add(c.m(ell(mx, my + 1, 1.9, 5.2)), ramp('#e8c090'))
    for s_ in (1, -1):
        c.line([(mx + s_ * 4, my - 2.5), (mx + s_ * 9.5, my - 4.5)], CREAMS)
        if not c.small:
            c.line([(mx + s_ * 4.5, my + 0.5), (mx + s_ * 9.5, my - 1.5)], CREAMS)
        x, y = c.P(mx + s_ * 5, my + 5)
        c.px(x, y, BLUE)
    # antennae
    ax, ay = c.P(mx, my - 4)
    for s in (1, -1):
        c.px(ax + s, ay - 1, K.UMBER2)
        c.px(ax + 2 * s, ay - 2, K.UMBER2)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-tgm-5', 'Moonhoop', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tgm-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tgm-5.png')
    print(rep)
