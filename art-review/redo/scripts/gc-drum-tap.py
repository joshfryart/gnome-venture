#!/usr/bin/env python3
"""gc-drum-tap "Drum Tap": edge-TBB double. A thatch-straw djembe drum pal: flat S (drum foot), double tab N
(two red mallet heads tapping the cream drumhead), double blanks W and E pinching the djembe waist.
Gold thatch with brown slat dashes from cell 4-3 (pavilion roof), red drum from the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

THATCH = K.ramp('#d9a84b')
SLAT = '#a7782a'
RED = K.ramp('#c72c2a')
DEEP = K.ramp('#871d1f')
SKIN = K.ramp('#f0dcae')
GREEN = '#306a5b'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(12, 22, 52, 59)(x, y) or K.ell(32, 22, 20.5, 4.2)(x, y)
    tabN = K.knob('T', 'double', 32, 18.5, 0, -1, r=5.8 * k)
    blW = K.knob('B', 'double', 12, 45, -1, 0, r=4.4 * k)
    blE = K.knob('B', 'double', 52, 45, 1, 0, r=4.4 * k)
    body = c.m(core, minus=(blW, blE))
    c.add(body, THATCH, stitch=None if c.small else SLAT)
    # thatch rows (cell motif): solid brown row lines with light straw dashes between
    rows = (34, 42, 49) if not c.small else (35, 48)
    for ry in rows:
        for x in range(0, c.n):
            X = (x + 0.5) / c.k
            y = c.P(0, ry + 2.6 * max(0.0, 1 - ((X - 32) / 20) ** 2))[1]
            if (x, y) in body:
                c.px(x, y, SLAT)
        if not c.small:
            for x in range(0, c.n):
                X = (x + 0.5) / c.k
                y = c.P(0, ry + 2.6 * max(0.0, 1 - ((X - 32) / 20) ** 2))[1]
                if x % 5 == 2 and (x, y + 3) in body and (x, y - 3) in body:
                    c.px(x, y + 3, THATCH[2])
    # drumhead: cream skin band with red rim
    skin = K.ell(32, 22, 20.5, 4.2)
    curve = lambda y0: (lambda x, y: y < y0 + 4.2 * max(0.0, 1 - ((x - 32) / 20.5) ** 2) ** 0.5)
    c.add(body & c.m(curve(27.5)), RED)
    c.add(body & c.m(skin), SKIN)
    # lacing on the red rim
    if not c.small:
        for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
            X = (x + 0.5) / c.k
            y = c.P(0, 25.3 + 4.2 * max(0.0, 1 - ((X - 32) / 20.5) ** 2) ** 0.5)[1]
            if x % 4 == 0:
                c.px(x, y, SKIN[0])
    # foot band
    c.add(body & c.m(K.rect(0, 54, 64, 59)), DEEP)
    if not c.small:
        y = c.P(0, 56)[1]
        for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
            if x % 3 == 0:
                c.px(x, y, '#e9bb2a')
    # two drum mallets: wood sticks rising from the drumhead, red round heads (the double tab lobes)
    tab = c.m(tabN, minus=(core,))
    c.add(tab, K.ramp('#b07a3a'))
    hy = 11.5 if not c.small else 11
    heads = c.m(K.rect(0, 0, 64, hy)) & tab
    c.add(heads, RED)
    gap = c.m(K.rect(31.4, 0, 32.6, 19))
    for (x, y) in gap & tab:
        c.px(x, y, K.UMBER2)
    # face on the thatch body
    c.eye(25, 38)
    c.eye(39, 38)
    c.smile(32, 45, wide=True)
    c.blush(21, 42)
    c.blush(42, 42)


K.render_pal(fn, 'gc-drum-tap', 'Drum Tap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/gc-drum-tap-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/gc-drum-tap.png')
