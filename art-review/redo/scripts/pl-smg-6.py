#!/usr/bin/env python3
"""pl-smg-6 Saltblock Minecart (rare, whimsy-minecart, tri).
Concept: a copper mine cart face-on whose tub is the piece core; salt blocks heaped on top (whimsy crest, no knob),
a tri TAB coupling sticks out E, a tri BLANK is cut into the W end, wheels on a rail stub make the flat S.
Colours from cell 8-6: copper tub #c8744a, steel-blue rim #768191, white salt, slate wheels #5b748d, mine purple."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

COPPER = K.ramp('#c8744a')
RIM = K.ramp('#8a96a6')
SALT = ('#f4eef2', '#c9bfd0', '#ffffff')
WHEEL = K.ramp('#5b748d')
RAIL = K.ramp('#6a5a74')


def fn(c):
    k = 1.15 if c.small else 1.0
    # tub: slightly tapered box
    tub = K.poly([(9, 27), (55, 27), (52, 48), (12, 48)])
    tabE = K.knob('T', 'tri', 54, 37, 1, 0, r=4.8 * k)
    blankW = K.knob('B', 'tri', 10, 37, -1, 0, r=4.8 * k)
    wheels = (K.ell(20, 51, 6.8, 6.8), K.ell(44, 51, 6.8, 6.8))
    rail = K.rect(5, 57, 59, 60.5)
    blocks = [K.rect(11, 17.5, 23.5, 28), K.rect(23.5, 15.5, 39.5, 28), K.rect(39.5, 17.5, 52, 28),
              K.poly([(19, 9), (30, 6.5), (32.5, 15.5), (21.5, 17.5)])]

    c.add(c.m(rail), RAIL)
    c.add(c.m(*wheels), WHEEL)
    for bl in blocks:
        bm = c.add(c.m(bl), SALT)
        c.edge(bm, '#c9bfd0')
    tubm = c.add(c.m(tub, tabE, minus=(blankW,)), COPPER, stitch=None)
    rimm = c.add(c.m(K.rect(7, 26, 57, 31), minus=(blankW,)), RIM)
    # hubs and spokes
    for wx in (20, 44):
        x, y = c.P(wx, 52.5)
        c.px(x, y, '#2a1a10')
        c.px(x + 1, y, '#2a1a10')
        if not c.small:
            c.px(x, y + 1, '#2a1a10')
            c.px(x + 1, y + 1, '#2a1a10')
            c.px(x - 3, y + 1, WHEEL[2])
    # plank lines on the tub
    for px_ in ((17, 33, 46), (47, 33, 46)):
        if not c.small:
            c.line([(px_[0], px_[1]), (px_[0], px_[2])], COPPER[1])
    if not c.small:
        c.line([(14, 45.5), (50, 45.5)], COPPER[1])
    # face
    c.eye(25, 36, look=(0, 0))
    c.eye(39, 36, look=(0, 0))
    c.smile(32, 40.5)
    c.blush(21, 40)
    c.blush(43, 40)


K.render_pal(fn, 'pl-smg-6', 'Saltblock Minecart', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-6.png')
