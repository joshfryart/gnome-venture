#!/usr/bin/env python3
"""pl-frt-2 "Puddle Croak": a mossy frost toad squatting in a cold puddle, as an edge-TTB hook piece.
Flat S = the icy puddle it sits in; hook tabs W and E = its two splayed front feet (curled toes); hook blank N = the dip
between its two bulging eye domes. Moss green of the barrow mound with snow patches on its back, puddle in the barrow's stone blue-grey (cell 7-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOSS = K.ramp('#8ac478')
MOSSD = K.ramp('#5fa860')
BELLY = K.ramp('#b4e090')
SNOW = ('#f0f9fa', '#c6d2e0', '#ffffff')
ICE = K.ramp('#a4b4cc')
ICED = K.ramp('#6c7ca0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 22, 54, 58)
    domes = (K.ell(19, 22, 9, 8), K.ell(45, 22, 9, 8))
    tabW = K.knob('T', 'hook', 10, 40, -1, 0, r=5.0 * k, flip=True)
    tabE = K.knob('T', 'hook', 54, 40, 1, 0, r=5.0 * k)
    blankN = K.knob('B', 'hook', 32, 22, 0, -1, r=4.2 * k)
    body = c.m(core, *domes, minus=(blankN,))
    c.add(body, MOSS, stitch=None if c.small else MOSSD[1])
    # feet = tabs, darker moss
    c.add(c.m(tabW, minus=(core,)), MOSSD)
    c.add(c.m(tabE, minus=(core,)), MOSSD)
    # snow patches on the back (like the snowy barrow)
    c.add(body & c.m(K.ell(16, 32, 4.5, 2.6), K.ell(46, 31, 5, 2.4), K.ell(31, 32.5, 3, 1.8)), SNOW)
    # pale belly
    c.add(body & c.m(K.ell(32, 47, 15, 6.5)), BELLY)
    # icy puddle along the flat bottom side
    pud = body & c.m(K.rect(0, 50.5, 64, 64))
    c.add(pud, ICE)
    rip = c.m(K.rect(14, 53, 24, 54.6), K.rect(34, 54.5, 46, 56.2), K.rect(26, 52, 30, 53.4)) & pud
    for p in rip:
        c.px(p[0], p[1], '#e0f0f4')
    c.edge(pud, ICED[1])
    # warts
    for (wx, wy) in ((24, 28), (38, 27), (13, 44), (51, 45), (40, 33)):
        c.add(body & c.m(K.ell(wx, wy, 1.6 * k, 1.4 * k)), MOSSD)
    # eyes on the domes, wide toad mouth
    c.eye(19, 21, disc=True)
    c.eye(45, 21, disc=True)
    c.line([(16, 38), (22, 40), (42, 40), (48, 38)], K.UMBER)
    c.blush(17, 41) if not c.small else None
    c.blush(46, 41) if not c.small else None


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-frt-2', 'Puddle Croak', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-frt-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-frt-2.png')
    print(rep)
