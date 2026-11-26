#!/usr/bin/env python3
"""pl-wlig-2 Tipsy Crescent: edge-TBT keyhole. A crescent moon that IS the piece: flat W side (the moon's back),
keyhole tabs on the N and S horn tips (N one is a drooping night-purple nightcap with a cream pom), and the E keyhole
blank is the crescent's hollow. Moon cream #ffeaa8 and night purples from cell 0-0 (top-left sky)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = ('#ffeaa8', '#d8b064', '#fff8dc')
CAP = K.ramp('#5a3586')
POM = ('#fff8dc', '#e0c88a', '#ffffff')
ROOT = '/home/user/gnome-venture/'


def rrect(x0, y0, x1, y1, rnw, rne, rse, rsw):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        for cx, cy, r, sx, sy in ((x0 + rnw, y0 + rnw, rnw, -1, -1), (x1 - rne, y0 + rne, rne, 1, -1),
                                  (x1 - rse, y1 - rse, rse, 1, 1), (x0 + rsw, y1 - rsw, rsw, -1, 1)):
            if (x - cx) * sx > 0 and (y - cy) * sy > 0 and (x - cx) ** 2 + (y - cy) ** 2 > r * r:
                return False
        return True
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(11, 12, 53, 53, 17, 15, 15, 17)
    tabN = K.knob('T', 'keyhole', 24, 12, 0, -1, r=4.6 * k)
    tabS = K.knob('T', 'keyhole', 24, 53, 0, 1, r=4.6 * k)
    blankE = K.knob('B', 'keyhole', 53, 33, 1, 0, r=9.5 * k, nw=3.4)
    body = c.m(core, tabS, minus=(blankE,))
    c.add(body, MOON, stitch='#e2c070')
    # nightcap on the N tab: purple neck flopping, cream pom-pom
    capm = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 10, 64, 13)))
    c.add(capm, CAP)
    pom = c.m(K.ell(24, 12 - (6.1 + 0.5) * k - 0.1, 3.4 * k, 3.4 * k)) & capm
    c.add(pom, POM)
    # cap brim band across the top of the moon
    c.add(c.m(K.rect(14, 12, 36, 15.5)) & body, CAP)
    # craters (picture's lilac) on the back
    for (x, y, r) in ((17, 45, 2.6), (30, 20, 1.9), (40, 47, 1.8)):
        c.add(c.m(K.ell(x, y, r, r)) & body, ('#e6cc88', '#c8a860', '#e6cc88'))
    # sleepy face on the back, looking into the hollow
    if not c.small:
        ex, ey = c.P(18, 30)
        for dx in range(-2, 3):
            c.px(ex + dx, ey + (1 if abs(dx) < 2 else 0), K.UMBER)
        ex2, ey2 = c.P(27, 30)
        for dx in range(-2, 3):
            c.px(ex2 + dx, ey2 + (1 if abs(dx) < 2 else 0), K.UMBER)
    else:
        ex, ey = c.P(18, 30)
        for dx in range(-1, 2):
            c.px(ex + dx, ey + (1 if dx == 0 else 0), K.UMBER)
        ex2, ey2 = c.P(27, 30)
        for dx in range(-1, 2):
            c.px(ex2 + dx, ey2 + (1 if dx == 0 else 0), K.UMBER)
    c.blush(16, 34)
    c.blush(28, 34)
    c.smile(22.5, 37, K.UMBER2)
    # little Zz star on the lower horn
    


K.render_pal(fn, 'pl-wlig-2', 'Tipsy Crescent', ROOT + 'art-review/redo/out',
             cellfile=ROOT + 'art-review/redo/_src/pl-wlig-2-cell.png',
             oldfile=ROOT + 'game/assets/img/puzzles/pals/pl-wlig-2.png')
