#!/usr/bin/env python3
"""pl-wgor-2 "Peekaboo Pipsqueak": edge-TTB keyhole. A baby gorilla's head IS the piece: keyhole tab N = the round crown bun
(like the glade gorilla's head), keyhole tab E = its ear, keyhole blank W, flat S = mother's lavender shoulder it peeks over,
little fingers clutching the rim. Gorilla purples + mauve face from the picture, green leaf wedge from cell 3-6."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#5a4c68')
FURD = K.ramp('#3a2e49')
FACE = ('#8a7078', '#6a5260', '#a8888c')
SHOULDER = K.ramp('#8a7c98')
LEAF = K.ramp('#58a048')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 16, 52, 58)
    tabN = K.knob('T', 'keyhole', 31, 16, 0, -1, r=6.4 * k, nw=3.4)
    tabE = K.knob('T', 'keyhole', 52, 32, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'keyhole', 11, 34, -1, 0, r=4.4 * k)
    body = c.m(core, tabN, tabE, minus=(blankW,))
    c.add(body, FUR)
    cut = (blankW,)
    # ear: mauve inner
    c.add(c.m(K.ell(56.5 + (0.5 if c.small else 0), 32, 2.4 * k, 2.6 * k)), FACE)
    # mother's shoulder band across the bottom (flat S side)
    sh = c.m(K.rect(11, 49, 52, 58), minus=cut)
    c.add(sh, SHOULDER)
    # green leaf wedge from the cell, sweeping up the lower-left corner
    c.add(c.m(K.poly([(11, 58), (11, 42), (14, 44), (20, 52), (23, 58)])), LEAF)
    # face: mauve heart-ish muzzle
    face = c.m(K.ell(25, 31, 7.5, 6.5), K.ell(37, 31, 7.5, 6.5), K.ell(31, 40, 12, 8.5), minus=(K.rect(0, 48.5, 64, 64), blankW))
    c.add(face, FACE)
    # heavy brow ridge
    brow = c.m(K.ell(25, 27, 6.5, 2.6 if not c.small else 3.2), K.ell(37, 27, 6.5, 2.6 if not c.small else 3.2), minus=cut)
    c.add(brow, FURD)
    # fingers clutching the shoulder rim
    for fx in (21, 25.5, 36.5, 41):
        c.add(c.m(K.ell(fx, 49.5, 2.3 * k, 2.4 * k), minus=cut), FURD)
    # nostrils + small worried mouth
    nx1, ny1 = c.P(28.5, 39)
    nx2, _ = c.P(33.5, 39)
    c.px(nx1, ny1, K.UMBER2)
    c.px(nx2, ny1, K.UMBER2)
    for dx, dy in ((1, 0), (0, 1), (1, 1)) if not c.small else ((0, 1),):
        c.px(nx1 - dx + 1, ny1 + dy, K.UMBER2)
        c.px(nx2 + dx - 1, ny1 + dy, K.UMBER2)
    mx, my = c.P(31, 44)
    for dx in (-1, 0, 1) if not c.small else (0, 1):
        c.px(mx + dx, my, K.UMBER2)
    # big shy eyes, glancing sideways
    c.eye(24.5, 32, disc=True, look=(1, 0))
    c.eye(37.5, 32, disc=True, look=(1, 0))
    c.blush(19.5, 37)
    c.blush(42, 37)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wgor-2', 'Peekaboo Pipsqueak', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-2.png'))
