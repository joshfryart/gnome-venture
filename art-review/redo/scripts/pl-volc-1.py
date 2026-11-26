#!/usr/bin/env python3
"""pl-volc-1 Cinnamon Puff Bounce: a round grey-mauve smoke puff that is a corner-BB piece.
Flat sides W and S (the puff sits on a cinnamon-brown crater rim), keyhole blanks N (between two puff lobes) and E.
Colours from cell 4-1 (mauve smoke #bdb1bf, lavender sky #b0b4d8, blue-grey #909bb8) plus the picture's cinnamon slope and lava orange."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SMOKE = K.ramp('#bdb1bf')
SMOKE2 = K.ramp('#a69ca0')
LAVSKY = K.ramp('#b0b4d8')
CINN = K.ramp('#8a5634')
LAVA = K.ramp('#e8702a')


def fn(c):
    S = 1.15 if c.small else 1.0
    core = K.rect(8, 24, 53, 57)
    bumps = [K.ell(14.5, 24, 7, 7), K.ell(25, 18.5, 8.5, 8), K.ell(47, 23.5, 7, 6.5), K.ell(40, 22, 5, 4)]
    blankN = K.knob('B', 'keyhole', 36, 15.5, 0, -1, r=4.0 * S)
    blankE = K.knob('B', 'keyhole', 53, 40, 1, 0, r=4.3 * S)
    clip = K.rect(8, 0, 64, 57)
    body = c.m(core, *bumps, minus=(blankN, blankE, lambda x, y: not clip(x, y)))
    c.add(body, SMOKE, stitch=None if c.small else '#d8ccd8')
    # billow lobes: lavender caps on the upper bumps, a darker mauve puff low on the left
    for (bx, by, r) in ((14.5, 22.5, 4.5), (24, 16.5, 5.5), (46, 22, 4)):
        cap = c.m(K.ell(bx - 1, by - 1, r, r * 0.8)) & body
        c.add(cap, LAVSKY)
    for (bx, by, rx, ry) in ((14.5, 45, 6.5, 4.5),):
        lo = c.m(K.ell(bx, by, rx, ry)) & body
        c.add(lo, SMOKE2)
        c.edge(lo, '#8a7f8a')
    # puff seams between the top bumps
    for pts in (((19.5, 24), (21, 27)), ((43, 27), (44.5, 29))):
        c.line(list(pts), '#8a7f8a')
    # cinnamon crater rim along the flat bottom, with a lava glint
    rim = c.m(K.rect(8, 50, 64, 57), K.ell(40, 51, 13, 3)) & body
    c.add(rim, CINN)
    glow = c.m(K.rect(13, 52.5, 20, 54.6), K.rect(30, 52.5, 38, 54.6), K.rect(45, 52.5, 50, 54.6)) & rim
    c.add(glow, LAVA)
    # cinnamon-bun swirl on the puff (the scent)
    if c.small:
        sw = [(40, 33), (44, 33), (44, 37), (39, 37), (39, 31), (46, 31)]
        c.line(sw, CINN[0])
    else:
        sw = [(41, 33), (43, 33), (43, 35), (39.5, 35), (39.5, 31), (45, 31), (45, 37), (38, 37)]
        c.line(sw, CINN[0])
    # face on the calm centre
    c.eye(21, 36)
    c.eye(31, 36)
    c.smile(26, 40.5, wide=True)
    c.blush(16.5, 40)
    c.blush(35, 40)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-volc-1', 'Cinnamon Puff Bounce', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-volc-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-volc-1.png'))
