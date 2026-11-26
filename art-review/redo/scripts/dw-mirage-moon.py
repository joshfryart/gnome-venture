#!/usr/bin/env python3
"""dw-mirage-moon "Mirage Moon" (rare, whimsy-moon, keyhole).
Concept: a fat cream crescent moon opening to the right IS the piece: keyhole tab out of its round back (W), keyhole tab
standing on its top horn shoulder (N), keyhole blank cut up into its belly (S). Sleepy felt face on the thick back,
purple night-cloud wisp from the cell (0-0) tucked into the crescent's mouth, tiny star at the upper tip."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = K.ramp('#fef0bf')
MOON = (MOON[0], '#d8c48a', '#fffbe8')
CLOUD = K.ramp('#6a4a92')
SKY = '#3d2a62'
GLOW = '#f6d878'


def fn(c):
    s = 1.15 if c.small else 1.0
    outer = K.ell(33, 33, 22, 22)
    inner = K.ell(48, 25, 16, 17)
    tabW = K.knob('T', 'keyhole', 11.2, 34, -1, 0, r=4.6 * s)
    tabN = K.knob('T', 'keyhole', 24, 13.5, -0.45, -0.89, r=4.4 * s)
    blankS = K.knob('B', 'keyhole', 30, 55, 0, 1, r=4.2 * s)
    moon = c.m(outer, tabW, tabN, minus=(inner, blankS))
    c.add(moon, MOON, stitch='#e6d394')
    # purple cloud wisp from the cell, resting in the crescent's mouth
    cloud = c.m(K.ell(47, 47, 9, 4.2), K.ell(53, 44.5, 6, 4), K.ell(41, 48.5, 6, 3.2))
    c.add(cloud, CLOUD)
    c.edge(cloud, CLOUD[1])
    # star near the upper tip
    sx, sy = c.P(55, 9)
    star = c.m(K.ell(55, 9, 2.6, 2.6) if c.small else K.poly([(55, 4.5), (56.3, 7.7), (59.5, 9), (56.3, 10.3), (55, 13.5), (53.7, 10.3), (50.5, 9), (53.7, 7.7)]))
    c.add(star, (GLOW, '#d8a840', '#fff6c8'))
    # craters (soft glow ramp dots)
    for (x, y, r) in ((20, 22, 2.2), (17, 44, 1.8), (35, 50, 1.5)):
        cx, cy = c.P(x, y)
        rr = 1 if c.small else int(r)
        for dx in range(-rr, rr + 1):
            for dy in range(-rr, rr + 1):
                if dx * dx + dy * dy <= rr * rr:
                    c.px(cx + dx, cy + dy, '#ecd99a')
    # sleepy face on the thick back, looking toward the mouth
    if c.small:
        for (ex, ey) in ((24, 33), (33, 32)):
            x, y = c.P(ex, ey)
            c.px(x, y, K.UMBER); c.px(x + 1, y + 1, K.UMBER); c.px(x + 2, y, K.UMBER)
    else:
        for (ex, ey) in ((22, 32), (32, 31)):
            x, y = c.P(ex, ey)
            for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0)):
                c.px(x + dx, y + dy, K.UMBER)
            c.px(x - 2, y - 1, K.UMBER2); c.px(x + 2, y - 1, K.UMBER2)
    c.blush(19, 37)
    c.blush(33.5, 36)
    c.smile(27.5, 38)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'dw-mirage-moon', 'Mirage Moon', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/dw-mirage-moon-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/dw-mirage-moon.png')
    print(rep)
