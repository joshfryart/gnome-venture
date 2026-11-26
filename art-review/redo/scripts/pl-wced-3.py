# Concept: a red-capped toadstool that IS an inner piece (TBTB, keyhole): left and right keyhole tabs are the cap brim,
# the top blank is a dent in the cap, the bottom blank parts the stem into two tiptoeing feet. Ribbon red + owl cream
# from the cedar picture, meadow green grass tufts and the cell's yellow flower.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#e34f3c')
SPOT = K.ramp('#f6ecd0')
STEM = K.ramp('#f0d8a8')
GILL = K.ramp('#c9a878')
GRASS = K.ramp('#68a04e')
CEDAR = K.ramp('#3c8a58')
YEL = '#f2c14e'


def rrect(x0, y0, x1, y1, r):
    core = (K.rect(x0 + r, y0, x1 - r, y1), K.rect(x0, y0 + r, x1, y1 - r),
            K.ell(x0 + r, y0 + r, r, r), K.ell(x1 - r, y0 + r, r, r),
            K.ell(x0 + r, y1 - r, r, r), K.ell(x1 - r, y1 - r, r, r))
    return lambda x, y: any(p(x, y) for p in core)


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.6 * s
    cap = lambda x, y: rrect(6, 14, 58, 33, 4)(x, y) or K.ell(32, 18, 25, 12)(x, y) and y < 30
    tabL = K.knob('T', 'keyhole', 6, 23, -1, 0, r=r)
    tabR = K.knob('T', 'keyhole', 58, 23, 1, 0, r=r)
    blT = K.knob('B', 'keyhole', 32, 6, 0, -1, r=r * 0.85)
    stem = rrect(17, 28, 47, 57, 3)
    blB = K.knob('B', 'keyhole', 32, 57, 0, 1, r=r)
    grass = (K.ell(17, 58.5, 7, 3.2), K.ell(47, 58.5, 7, 3.2))

    c.add(c.m(*grass), GRASS)
    c.add(c.m(stem, minus=(blB,)), STEM, stitch=GILL[0])
    capm = c.add(c.m(cap, tabL, tabR, minus=(blT,)), RED)
    gill = c.add(c.m(K.rect(13, 30, 51, 33.5), minus=(blT,)), GILL)
    c.edge(capm | gill, K.UMBER2)
    # cap spots (two in the keyhole tabs, three on the dome)
    for (x, y, rr) in ((14, 17, 3.2), (50, 17, 3.0), (32, 26, 2.8), (-0.5, 23, 2.0), (64.5, 23, 2.0), (21, 26, 2.2), (43, 26, 2.2)):
        c.add(c.m(K.ell(x, y, rr, rr * 0.9)), SPOT)
    # cedar grass blades + yellow meadow flower at the right foot
    c.add(c.m(K.thick_path([(11, 60), (9, 53)], 2.8), K.thick_path([(53, 60), (56, 53)], 2.8)), CEDAR)
    fx, fy = c.P(56, 52)
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)) if not c.small else ((0, 0),):
        c.px(fx + dx, fy + dy, YEL)
    # face on the stem
    c.eye(25, 40)
    c.eye(39, 40)
    c.smile(32, 44.5)
    c.blush(22, 44)
    c.blush(42, 44)


K.render_pal(fn, 'pl-wced-3', 'Toadstool Tiptoe', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-3.png')
