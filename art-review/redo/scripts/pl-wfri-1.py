#!/usr/bin/env python3
"""pl-wfri-1 "Moon Spotlight": corner-BB, keyhole.
Concept: the full moon from the top-right corner of the fairy-ring clearing IS the corner piece. Flat top and right sides
(the moon clipped by the picture's frame), the free bottom-left corner swells into the moon's round disc, keyhole blanks
cut into the left and bottom sides. Moon cream with craters (picture), the cell's night-sky navy as a spotlight hood/visor
band over the top flat edge, and the cell's yellow + green sparkles twinkling on the moon."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = K.ramp('#fff0c0')
CRATER = K.ramp('#c8c4b4')
SHADE = K.ramp('#e0cc94')
NAVY = K.ramp('#24405e')
BEAM = K.ramp('#fff6a8')
SPARK_Y, SPARK_G = '#fff6a8', '#b8f8a8'


def rounded_core(x0, y0, x1, y1, rbl, r):
    """Square core, flat square corner top-right, big round bottom-left (the moon disc), small round top-left / bottom-right."""
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        for cx, cy, rr, sx, sy in ((x0 + rbl, y1 - rbl, rbl, -1, 1), (x0 + r, y0 + r, r, -1, -1), (x1 - r, y1 - r, r, 1, 1)):
            if (x - cx) * sx > 0 and (y - cy) * sy > 0 and (x - cx) ** 2 + (y - cy) ** 2 > rr * rr:
                return False
        return True
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    disc = K.ell(31, 35, 26, 26)
    sky = K.rect(31, 4.5, 59.5, 35)          # the square top-right corner: flat top + flat right meet here
    bW = K.knob('B', 'keyhole', 5, 36, -1, 0, r=4.6 * k, nw=2.2)
    bS = K.knob('B', 'keyhole', 31, 61, 0, 1, r=4.6 * k, nw=2.2)
    body = c.m(disc, sky, minus=(bW, bS))
    skym = body - c.m(disc)
    moon = body & c.m(disc)
    c.add(skym, NAVY)
    c.add(moon, MOON, stitch=None)
    c.edge(moon, MOON[1])
    # crescent shade on the lower right of the disc (moon phase), lavender craters
    sh = moon & c.m(K.ell(31, 35, 26, 26), minus=(K.ell(27.5, 31.5, 24.5, 24.5),))
    c.add(sh, SHADE)
    for (cx, cy, rx, ry) in ((43, 48, 4.2, 3.6), (14, 47, 2.8, 2.6), (22, 17, 3, 2.4)):
        m = c.m(K.ell(cx, cy, rx, ry)) & moon
        c.add(m, CRATER)
    # the cell's sparkles in the sky corner
    for (x, y, col) in ((54, 10, SPARK_Y), (45, 8.5, SPARK_G), (55.5, 24, SPARK_Y)):
        px, py = c.P(x, y)
        c.px(px, py, col)
        if not c.small:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(px + dx, py + dy, col)
    # face: dreamy moon
    c.eye(23, 33)
    c.eye(37, 33)
    c.smile(30, 40, wide=True)
    c.blush(18, 39)
    c.blush(42, 39)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wfri-1', 'Moon Spotlight', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wfri-1-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wfri-1.png'))
