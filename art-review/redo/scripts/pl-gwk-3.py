#!/usr/bin/env python3
"""pl-gwk-3 "Moonpale Mantle": a hooded wolf-pelt mantle, inner-TBTB peg.
Blanks N (the dip between the hood's two wolf ears) and S (the split hem of the cloak); peg tabs W and E (the mantle's
little sleeve-paws). Blue-grey wolf fur of cell 6-1, the king's yellow eye glowing in the dark hood and as the clasp,
moon-cream hem trim."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#aab6e0')
FURD = K.ramp('#5c64a0')
HOOD = ('#242850', '#1a1830', '#303560')
MOON = ('#fffef4', '#e8e0b0', '#ffffff')
EYE = '#ffd23c'
EYEL = '#fff176'
SRC = '/home/user/gnome-venture/art-review/redo/_src/'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(15, 13), (49, 13), (56, 58), (8, 58)])
    earL = K.poly([(13, 20), (15, 3.5), (27, 15)])
    earR = K.poly([(51, 20), (49, 3.5), (37, 15)])
    bN = K.knob('B', 'peg', 32, 13, 0, -1, r=4.0 * k)
    bS = K.knob('B', 'peg', 32, 58, 0, 1, r=4.0 * k)
    tW = K.knob('T', 'peg', 12.5, 37, -1, 0, r=4.2 * k)
    tE = K.knob('T', 'peg', 51.5, 37, 1, 0, r=4.2 * k)
    body = c.m(core, earL, earR, tW, tE, minus=(bN, bS))
    c.add(body, FUR, stitch=None if c.small else FUR[2])
    # darker fur on the hood + ear insides
    hood = c.m(K.ell(32, 30, 17, 14)) & body
    c.add(hood, FURD)
    c.add(c.m(K.poly([(16, 15), (17, 7), (24, 15)]), K.poly([(48, 15), (47, 7), (40, 15)])), HOOD)
    # hood opening, dark, with the glowing wolf eyes
    op = c.m(K.ell(32, 32, 10, 8.5))
    c.add(op, HOOD)
    c.edge(hood, FURD[1])
    for ex in (27.5, 36.5):
        x, y = c.P(ex, 31)
        if not c.small:
            for dx in range(-2, 2):
                for dy in range(-1, 2):
                    c.px(x + dx, y + dy, EYE)
            c.px(x - 2, y - 1, EYEL)
            c.px(x - 1, y - 1, EYEL)
            c.px(x, y - 1, K.UMBER)
            c.px(x, y, K.UMBER)
            c.px(x, y + 1, K.UMBER)
        else:
            for dx in range(-1, 1):
                for dy in range(-1, 1):
                    c.px(x + dx, y + dy, EYE)
            c.px(x, y - 1, EYEL)
            c.px(x - 1, y, K.UMBER)
    # moon-cream hem trim
    fringe = lambda x, y: y >= 54 - (2.2 if (int(x) // 3) % 2 else 0)
    c.add(body & c.m(fringe), MOON)
    # drape folds
    if not c.small:
        for fx, tx in ((20, 16), (44, 48)):
            c.line([(fx, 41), (tx, 52)], FUR[1])
    # front edges of the cloak from clasp to the hem split
    if not c.small:
        c.line([(30.5, 45), (29, 51)], FUR[1])
        c.line([(33.5, 45), (35, 51)], FUR[1])
    # wolf-eye clasp
    c.add(c.m(K.ell(32, 45, 3.6 * k, 3.0 * k)), ('#ffd23c', '#c89a20', '#fff176'))
    x, y = c.P(32, 45)
    c.px(x, y, K.UMBER)
    # moon glow sparkles on the fur
    if not c.small:
        for p in ((19, 44), (45, 47), (21, 50)):
            c.px(*c.P(*p), '#fffbb0')


K.render_pal(fn, 'pl-gwk-3', 'Moonpale Mantle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=SRC + 'pl-gwk-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-3.png')
