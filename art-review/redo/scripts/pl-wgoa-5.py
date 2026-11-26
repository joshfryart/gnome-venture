# Hoopsy Barrels (pl-wgoa-5): inner-BBBB keyhole. A squat wine barrel IS the piece: bulging staves form the square body,
# two dark iron hoops run across it, keyhole blanks cut into all four sides (the top blank is the bung-hole notch in the lid).
# A purple grape bunch and a vine leaf sit on the lid shoulders. Soil olive-brown staves, vine greens, grape purple, path tan (cell 10-7).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

STAVE = ramp('#a8763e')
STAVE2 = ramp('#8a6034')
HOOP = ramp('#6e6a60')
LID = ramp('#e8d68c')
VINE = ramp('#58a048')
GRAPE = ramp('#7a3e98')


def fn(c):
    k = 1.15 if c.small else 1.0
    # barrel: square-ish with slightly bulging sides (straight-ish between knobs)
    def barrel(x, y):
        if not (12 <= y < 58):
            return False
        t = (y - 35) / 23.0
        bulge = 4.0 * (1 - t * t)
        return 10 - bulge <= x < 54 + bulge
    blanks = (knob('B', 'keyhole', 32, 12, 0, -1, r=3.3 * k, nw=1.8),
              knob('B', 'keyhole', 32, 58, 0, 1, r=3.3 * k, nw=1.8),
              knob('B', 'keyhole', 7, 35, -1, 0, r=3.3 * k, nw=1.8),
              knob('B', 'keyhole', 57, 35, 1, 0, r=3.3 * k, nw=1.8))
    body = c.m(barrel, minus=blanks)
    c.add(body, STAVE, stitch=None)
    # alternate staves
    sw = 7.0
    staves = c.m(lambda x, y: barrel(x, y) and int((x - 4) // sw) % 2 == 1, minus=blanks)
    c.add(staves, STAVE2)
    # lid rim (top band, tan)
    lid = c.m(lambda x, y: barrel(x, y) and y < 16, minus=blanks)
    c.add(lid, LID)
    # iron hoops
    hw = 3.4 if c.small else 3.0
    for hy in (22, 48):
        c.add(c.m(lambda x, y, hy=hy: barrel(x, y) and abs(y - hy) < hw / 2 + 0.6, minus=blanks), HOOP)
    # stave seams (64 px)
    if not c.small:
        for sx in range(11, 54, 7):
            x, _ = c.P(sx, 0)
            for y in range(c.P(0, 17)[1], c.n):
                if (x, y) in body and not (abs(y - c.P(0, 22)[1]) < 3 or abs(y - c.P(0, 48)[1]) < 3):
                    c.px(x, y, STAVE2[1])
    # grape bunch on the left shoulder, vine leaf on the right shoulder
    g = []
    for (gx, gy) in ((13, 9), (18, 9), (15.5, 13.5) , (10.5, 13.5), (20.5, 13.5)):
        g.append(ell(gx, gy, 3.0 * k, 3.0 * k))
    grapes = c.m(*g, minus=blanks)
    c.add(grapes, GRAPE)
    c.add(c.m(thick_path([(15.5, 6.5), (17, 3.5)], 2.0 * k + 0.6)), VINE)
    leaf = c.m(poly([(42, 14), (44, 6), (49, 3), (54, 5), (56, 10), (52, 14), (46, 15)]), minus=blanks)
    c.add(leaf, VINE)
    if not c.small:
        c.line([(44, 13), (52, 6)], VINE[1])
        for (gx, gy) in ((12, 8), (17, 8), (14.5, 12.5)):
            c.px(*c.P(gx, gy), GRAPE[2])
    # face on the calm middle between the hoops
    c.eye(24, 33)
    c.eye(40, 33)
    c.smile(32, 39)
    c.blush(19.5, 37)
    c.blush(43.5, 37)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wgoa-5', 'Hoopsy Barrels', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgoa-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgoa-5.png')
    print(rep)
