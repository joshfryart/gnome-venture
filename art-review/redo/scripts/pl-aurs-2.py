#!/usr/bin/env python3
"""pl-aurs-2 "Pine Shiver": edge-TBT, peg. A snowy pine that IS an edge piece.
Peg tab N = the snow-capped treetop, peg tab S = the trunk stump, peg blank E bitten into the boughs, W = the flat edge side.
Colours: the picture's pine (#204842 / #184339), its snow (#f4f8fe) shaded in the night-sky blues of cell 0-5 (#919fd2, #6472a8)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINE = ('#2c6454', '#184339', '#4a8a72')
SNOW = ('#f4f8fe', '#919fd2', '#ffffff')
DRIFT = ('#a9b8e2', '#6472a8', '#d0daf2')
BARK = ('#8a5a30', '#5a3a1f', '#b07a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(19, 15), (45, 15), (51, 49), (13, 49)])
    tabN = K.knob('T', 'peg', 32, 15, 0, -1, r=5.2 * k, nw=2.8)
    tabS = K.knob('T', 'peg', 32, 49, 0, 1, r=4.6 * k, nw=2.8)
    nx, ny = 34.0, -6.0
    L = (nx * nx + ny * ny) ** 0.5
    blankE = K.knob('B', 'peg', 48.0, 32, nx / L, ny / L, r=5.0 * k, nw=2.8)
    body = c.m(core, minus=(blankE,))
    c.add(body, PINE, stitch=None)
    # treetop peg: green with a snow cap
    top = c.m(tabN, minus=(core,))
    c.add(top, PINE)
    c.add(top & c.m(K.rect(0, 0, 64, 8.5)), SNOW)
    # trunk
    c.add(c.m(tabS, minus=(core,)), BARK)
    # scalloped snow on three tiers of boughs
    for y0, x0, x1 in ((15, 19, 45), (23.5, 17, 47), (39.5, 14, 50)):
        bumps = [K.rect(x0, y0 - 1, x1 + 1, y0 + 2)]
        x = x0 + 2
        while x < x1:
            bumps.append(K.ell(x, y0 + 1.6, 2.6, 2.0))
            x += 5.5
        c.add(body & c.m(*bumps), SNOW)
    # snow drift along the flat bottom
    c.add(body & c.m(K.rect(0, 46, 64, 64), K.ell(24, 46, 7, 2.2), K.ell(40, 46.4, 7, 2)), DRIFT)
    # face on the middle tier
    ey = 31.5
    c.eye(26, ey, disc=True)
    c.eye(36, ey, disc=True)
    c.smile(31.5, 34.5, wide=not c.small)
    c.blush(22.5, 34.5)
    c.blush(39.5, 34.5)
    # shiver: tiny snowflakes falling off the boughs
    for fx, fy in ((22, 20), (40, 20.5), (18, 44)):
        x, y = c.P(fx, fy)
        c.px(x, y, SNOW[0])
        if not c.small:
            c.px(x + 1, y + 1, SNOW[2])


K.render_pal(fn, 'pl-aurs-2', 'Pine Shiver', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-2.png')
