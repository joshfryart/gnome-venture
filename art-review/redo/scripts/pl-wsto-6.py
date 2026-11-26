import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER

# Whimsy-stonehead, keyhole: a moai-style carved head that IS the piece. Flat S (chin on the ground), keyhole tab W = stone ear,
# keyhole blank E bites the cheek, keyhole tab N = the little red cap. Lavender-grey stone with checker moss and a gold seed (cell 8-5).
STONE = ramp('#aaa6bc')
STONED = ('#7e7a98', '#5e5a78', '#9c98b4')
BROW = ramp('#c8c2d0')
MOSS = '#6cc04a'
MOSSD = '#3f8a3a'
CAP = ('#d03a2a', '#982018', '#f07050')
GOLD = ('#e8b020', '#b07a10', '#f8d870')


def fn(c):
    s = 1.15 if c.small else 1.0
    head = poly([(15, 22), (49, 22), (51, 58), (13, 58)])
    dome = ell(32, 24, 17, 11)
    tabW = knob('T', 'keyhole', 14, 42, -1, 0, r=4.0 * s)
    blankE = knob('B', 'keyhole', 50.5, 46, 1, 0, r=3.4 * s)
    tabN = knob('T', 'keyhole', 32, 11.5, 0, -1, r=4.2 * s)
    body = c.m(head, dome, tabW, minus=(blankE,))
    c.add(body, STONE, stitch=None)
    # cap: red dome on the crown + the keyhole tab as its bobble
    capm = c.m(ell(32, 17, 12.5, 6.5), tabN, minus=(rect(0, 18.5, 64, 64),))
    c.add(capm, CAP)
    c.add(c.m(rect(19, 17, 45, 20)) & c.m(dome), ('#b02a20', '#7a1a14', '#e05040'))
    # gold seed bobble on the cap (the round head of the N keyhole tab)
    c.add(c.m(tabN) & c.m(rect(0, 0, 64, 7.5 if not c.small else 7.0)), GOLD)
    # ear: dark inner whorl on the W tab
    c.add(c.m(ell(9.5, 42, 2.2 * s, 2.6 * s)), STONED)
    # heavy brow band
    brow = c.m(rect(14, 27, 50, 32)) & body
    c.add(brow, BROW)
    # long nose
    nose = c.m(poly([(30, 31), (34, 31), (36.5, 46), (27.5, 46)]))
    c.add(nose, STONE)
    c.edge(nose, STONED[0])
    # lips
    c.add(c.m(rect(24, 49.5, 40, 53.5)), BROW)
    c.line([(25, 51.5), (39, 51.5)], STONED[1])
    # moss dither on the crown and the sides
    for (x, y) in body:
        X, Y = x / c.k, y / c.k
        if (x + y) % 2 == 0 and (((X - 22) ** 2 / 40 + (Y - 21) ** 2 / 10 < 1) or (X < 20 and 44 < Y < 56) or ((X - 43) ** 2 / 12 + (Y - 24) ** 2 / 6 < 1)):
            c.px(x, y, MOSS)
    if not c.small:
        for (x, y) in body:
            X, Y = x / c.k, y / c.k
            if (x * 3 + y) % 5 == 0 and 40 < Y < 48 and X > 40 and X < 46:
                c.px(x, y, MOSSD)
    # deep-set eyes under the brow: left open, right mid-blink
    c.eye(25, 35.5)
    ex, ey = c.P(39, 35.5)
    w = 2 if not c.small else 1
    for dx in range(-w, w + 1):
        c.px(ex + dx, ey, UMBER)
    c.px(ex - w - 1, ey - 1, UMBER)
    c.px(ex + w + 1, ey - 1, UMBER)
    c.px(ex, ey + 1, UMBER)
    # gold seed dropped at the chin
    c.add(c.m(ell(44, 54.5, 3.0 * s, 2.4 * s)), GOLD)


K.render_pal(fn, 'pl-wsto-6', 'Blinkseed Stonehead', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsto-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsto-6.png')
