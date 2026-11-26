import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2

BLUE, GREEN, WHITE, RED, YEL = ramp('#3a78d0'), ramp('#4ab04a'), ('#eef0f4', '#b8c0d0', '#ffffff'), ramp('#d6322b'), ramp('#f4c040')
CORD = ramp('#7a4a1f')
XS = [10, 18, 26, 38, 46, 54]


def fn(c):
    """Windtalking Bunting, inner-TTTT double: five prayer flags sewn into one square piece, cord across the top (cell 8-3)."""
    S = 1.15 if c.small else 1.0
    y0, y1 = 13, 51
    tN = knob('T', 'double', 32, y0, 0, -1, r=4.8 * S)
    tS = knob('T', 'double', 32, y1, 0, 1, r=4.8 * S)
    tW = knob('T', 'double', 10, 33, -1, 0, r=4.8 * S)
    tE = knob('T', 'double', 54, 33, 1, 0, r=4.8 * S)
    # small notches between flags along the bottom edge so they read as separate hanging cloths
    nd = 3.2 if c.small else 2.6
    notches = [poly([(x - 2.2, y1 + 1), (x + 2.2, y1 + 1), (x, y1 - 5)]) for x in XS[1:5]]
    notches += [rect(x - 0.5, 40, x + 0.5, y1) for x in XS[1:5]]
    rams = [BLUE, GREEN, WHITE, RED, YEL]
    for i, rm in enumerate(rams):
        preds = [rect(XS[i], y0, XS[i + 1], y1)]
        if i == 2:
            preds += [tS]
        c.add(c.m(*preds, minus=notches), rm, stitch=None)
    # cord ties: N hanging loop and E/W cord ends are brown cord knots
    c.add(c.m(tN, tW, tE, minus=(rect(XS[0], y0 + 3, XS[5], y1),)), CORD)
    # seams between flags
    for i in range(1, 5):
        m = c.m(rect(XS[i] - 0.5, y0 + 3, XS[i] + 0.5, y1))
        for p in m:
            c.px(p[0], p[1], rams[i - 1][1])
    # cord across the top, with knots
    cord = c.m(rect(9, y0 + 0.5, 55, y0 + (3.2 if c.small else 2.8)))
    for p in cord:
        c.px(p[0], p[1], CORD[0])
    for x in XS[1:5]:
        kx, ky = c.P(x, y0 + 1.5)
        c.px(kx, ky, UMBER2)
        c.px(kx - 1, ky, UMBER2)
        if not c.small:
            c.px(kx, ky + 1, UMBER2)
            c.px(kx - 1, ky + 1, UMBER2)
    # wind-horse print blocks on the side flags (64 px only), darker shade
    if not c.small:
        for i in (0, 1, 3, 4):
            cx = (XS[i] + XS[i + 1]) / 2
            for yy in (24, 29, 34, 39):
                a, b = c.P(cx - 2, yy)
                for dx in range(0, 4 if yy % 10 == 4 else 3):
                    c.px(a + dx, b, rams[i][1])
    else:
        for i in (0, 1, 3, 4):
            cx = (XS[i] + XS[i + 1]) / 2
            for yy in (26, 36):
                a, b = c.P(cx - 1.5, yy)
                c.px(a, b, rams[i][1]); c.px(a + 1, b, rams[i][1])
    # face on the white centre flag
    c.eye(28.8, 29)
    c.eye(35.4, 29)
    c.smile(32.2, 35)
    c.blush(27.6, 34)
    c.blush(36.4, 34)


K.render_pal(fn, 'pl-wpry-4', 'Windtalking Bunting', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpry-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpry-4.png')
