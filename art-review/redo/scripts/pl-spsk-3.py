#!/usr/bin/env python3
"""pl-spsk-3 "Lamp Dangle": inner-TBTB round. A hanging souk lantern: round tab N = brass hanging cap (+ chain stub),
round tab S = brass finial, round blanks W and E cut into the indigo fretwork sides. Glowing amber arch window with the
cell's cream arch trim (magenta + teal dots) and the night-indigo sky colour from cell 4-1 of the spice souk picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, UMBER2

BRASS = ramp('#c08a3a')
INDIGO = ramp('#4a3a8a')
GLOW = ('#f8c860', '#e09a30', '#fff8d6')
CORE = ('#fff2c0', '#f8d070', '#fffbe8')
TRIM = ('#f4deb8', '#d8b888', '#fff4d8')
MAGD, TEALD = '#c8327a', '#2a9a9a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 15, 51, 50)
    tabN = knob('T', 'round', 32, 15, 0, -1, r=5.0 * k)
    tabS = knob('T', 'round', 32, 50, 0, 1, r=4.6 * k)
    blW = knob('B', 'round', 13, 33, -1, 0, r=4.2 * k)
    blE = knob('B', 'round', 51, 33, 1, 0, r=4.2 * k)
    chain = rect(30.6, 0, 33.4, 6)
    domeL = poly([(12, 14), (21, 14), (12, 19.5)])
    domeR = poly([(52, 14), (43, 14), (52, 19.5)])
    footL = poly([(12, 51), (16, 51), (12, 48)])
    footR = poly([(52, 51), (48, 51), (52, 48)])
    ring = ell(32, 8.6, 2.0 * k, 1.8 * k)
    body = c.m(core, tabN, tabS, chain, minus=(blW, blE, domeL, domeR, footL, footR, ring))
    c.add(body, INDIGO)
    # brass cap (dome band + tab) and base (band + finial)
    c.add(body & c.m(rect(0, 0, 64, 20.5)), BRASS)
    c.add(body & c.m(rect(0, 44.5, 64, 64)), BRASS)
    # ridge lines on brass bands
    c.line([(14, 18.5), (50, 18.5)], BRASS[1]) if not c.small else None
    c.line([(14, 46.5), (50, 46.5)], BRASS[1]) if not c.small else None
    # chain links
    pass
    # arch window: cream trim around glowing glass
    arch_o = lambda x, y: (abs(x - 32) < 9.5 and 29 <= y < 44.5) or ((x - 32) ** 2 + (y - 29) ** 2 < 9.5 ** 2 and y < 29)
    arch_i = lambda x, y: (abs(x - 32) < 7.0 and 29 <= y < 44.5) or ((x - 32) ** 2 + (y - 29) ** 2 < 7.0 ** 2 and y < 29)
    c.add(c.m(arch_o) & body, TRIM)
    win = c.m(arch_i) & body
    c.add(win, GLOW)
    c.add(c.m(ell(32, 34, 4.5, 5.0)) & win, CORE)
    # trim dots (magenta / teal), like the arch trim in the cell
    for (x, y, col) in ((24.0, 36, MAGD), (40.0, 36, TEALD), (26.0, 24, TEALD), (38.0, 24, MAGD)):
        c.px(*c.P(x, y), col)
    # fretwork stars on indigo upper corners
    if not c.small:
        for (x, y) in ((17, 24), (47, 24), (17, 41), (47, 41)):
            cx, cy = c.P(x, y)
            for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(cx + d[0], cy + d[1], '#f0b850' if d == (0, 0) else INDIGO[2])
    else:
        for (x, y) in ((17, 24), (47, 24)):
            c.px(*c.P(x, y), '#f0b850')
    # face in the glow
    c.eye(29, 33)
    c.eye(35.5, 33)
    c.blush(26.5, 37) if not c.small else None
    c.blush(37.5, 37) if not c.small else None
    c.smile(32, 38, UMBER2)


K.render_pal(fn, 'pl-spsk-3', 'Lamp Dangle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-spsk-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-spsk-3.png')
