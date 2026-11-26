import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

# Chestful of Twinkles (cell 5-6 of the Cenote of Echoes): inner-TBTB, keyhole.
# A sunken treasure chest that IS the piece: E + W keyhole tabs = gold chest handles, N keyhole blank cut into the domed lid,
# S keyhole blank between the stone feet. Planks in cenote teal with pale ripple dashes, lid ajar with a cream-gold glow.
TEAL = K.ramp('#1a5e78')
LID = K.ramp('#1f7a94')
GOLD = ('#e8b42a', '#a87a14', '#fbe08a')
GLOW = ('#fff1cf', '#e8c060', '#ffffff')
STONE = K.ramp('#9da2a2')
RIPPLE = '#8ee8dc'


def fn(c):
    k = 1.15 if c.small else 1.0
    lidarch = ell(32, 26, 22.5, 15)
    lid = lambda x, y: lidarch(x, y) and y < 26
    lidbox = rect(9.5, 21, 54.5, 26)
    box = rect(11, 30, 53, 52)
    gap = rect(12, 26, 52, 31)
    tabE = knob('T', 'keyhole', 53, 40, 1, 0, r=4.6 * k)
    tabW = knob('T', 'keyhole', 11, 40, -1, 0, r=4.6 * k)
    blankN = knob('B', 'keyhole', 32, 11, 0, -1, r=3.4 * k)
    blankS = knob('B', 'keyhole', 32, 55, 0, 1, r=4.0 * k)
    feetL = rect(12, 51, 22, 56)
    feetR = rect(42, 51, 52, 56)
    minus = (blankN, blankS)
    c.add(c.m(gap, minus=minus), GLOW)
    c.add(c.m(box, minus=minus), TEAL, stitch=None)
    c.add(c.m(lid, lidbox, minus=minus), LID)
    c.add(c.m(feetL, feetR, minus=minus), STONE)
    c.add(c.m(tabE, tabW, minus=(box,)), GOLD)
    # gold bands: lid rim, vertical straps
    c.add(c.m(rect(9.5, 24, 54.5, 26), minus=minus), GOLD)
    c.add(c.m(rect(11, 30, 53, 32), minus=minus), GOLD)
    c.add(c.m(rect(15, 18, 19, 52), minus=minus) & c.m(lid, lidbox, box), GOLD)
    c.add(c.m(rect(45, 18, 49, 52), minus=minus) & c.m(lid, lidbox, box), GOLD)
    # keyhole lock plate
    plate = c.add(c.m(rect(28, 31, 36, 41)), GOLD)
    kx, ky = c.P(32, 34)
    if c.small:
        c.px(kx - 1, ky, K.UMBER); c.px(kx, ky, K.UMBER); c.px(kx - 1, ky + 1, K.UMBER); c.px(kx, ky + 1, K.UMBER)
    else:
        for dx in (-1, 0):
            for dy in (0, 1, 2, 3):
                c.px(kx + dx, ky + dy, K.UMBER)
        c.px(kx - 2, ky + 1, K.UMBER); c.px(kx + 1, ky + 1, K.UMBER)
    # ripple dashes on the planks (cell's water dashes)
    if not c.small:
        for (x0, y) in ((21, 44), (37, 47), (22, 23), (38, 22)):
            for i in range(4):
                p = c.P(x0 + i, y)
                c.px(p[0], p[1], RIPPLE)
        # plank seam
        c.line([(19, 46), (28, 46)], K.ramp('#1a5e78')[1])
        c.line([(36, 44), (45, 44)], K.ramp('#1a5e78')[1])
    else:
        for (x0, y) in ((21, 46), (38, 23)):
            for i in range(0, 6, 2):
                p = c.P(x0 + i, y)
                c.px(p[0], p[1], RIPPLE); c.px(p[0] + 1, p[1], RIPPLE)
    # twinkles spilling from the gap
    for (x, y) in ((24, 28), (40, 28.5), (32, 28)):
        p = c.P(x, y)
        c.px(p[0], p[1], '#ffffff')
        if not c.small:
            c.px(p[0] - 1, p[1], GOLD[2]); c.px(p[0] + 1, p[1], GOLD[2])
    # face on the front, either side of the lock
    c.eye(23.5, 37, disc=True)
    c.eye(40.5, 37, disc=True)
    c.smile(32, 44, col=K.CREAM if not c.small else GLOW[0])
    c.blush(21, 41.5)
    c.blush(42, 41.5)


K.render_pal(fn, 'pl-wcen-3', 'Chestful of Twinkles', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcen-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcen-3.png')
