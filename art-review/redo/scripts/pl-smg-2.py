#!/usr/bin/env python3
"""pl-smg-2 "Salt Lick": edge-TBB, tri. A lavender rock-salt lick block that licks itself.
Flat S (sits on the mine floor), tri tab N = a white salt crystal point, tri blanks W and E = licked-out hollows.
Colours from cell 2-7 (the mole's lavender-grey fur, pink paw) and the white salt crystals of the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SALT = K.ramp('#9384a7')
SALTDK = K.ramp('#7e6e96')
CRYS = ('#f4f0f8', '#c4bcd8', '#ffffff')
TONGUE = K.ramp('#e8909c')
VEIN = '#a89ab8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 22, 55, 58)
    tabN = K.knob('T', 'tri', 32, 22, 0, -1, r=6.2 * k, nw=3.2)
    blankW = K.knob('B', 'tri', 9, 38, -1, 0, r=4.8 * k)
    blankE = K.knob('B', 'tri', 55, 42, 1, 0, r=4.8 * k)
    body = c.m(core, minus=(blankW, blankE))
    c.add(body, SALT, stitch=None if c.small else SALT[2])
    # darker lower band (rock strata, like the mole's shaded fur)
    c.add(body & c.m(K.rect(0, 50, 64, 64)), SALTDK)
    # lighter top face of the block (a cut salt brick)
    c.add(body & c.m(K.rect(0, 22, 64, 26.5)), K.ramp('#b4a8c8'))
    # crack facets in the rock salt
    if not c.small:
        c.line([(46, 30), (50, 33), (49, 38)], SALT[1])
        c.line([(13, 50), (17, 46)], SALT[2])
    # crystal point on top
    crys = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 20, 64, 23)))
    c.add(crys, CRYS)
    # facet line down the crystal
    x0 = c.P(32, 0)[0]
    for y in range(c.P(0, 10.5)[1], c.P(0, 22)[1]):
        c.px(x0, y, CRYS[1])
    # salt crystal specks on the block
    for (sx, sy) in ((21, 29), (44, 29), (50, 35), (14, 47), (41, 54), (22, 54)):
        x, y = c.P(sx, sy)
        c.px(x, y, CRYS[0])
        if not c.small:
            c.px(x + 1, y, CRYS[2]); c.px(x, y + 1, CRYS[1])
    # face
    c.eye(24, 34)
    c.eye(40, 34)
    c.blush(19.5, 40)
    c.blush(43.5, 40)
    # open mouth with a long pink tongue licking out and down the side
    mx, my = c.P(32, 41)
    mw = 3 if not c.small else 2
    for dx in range(-mw, mw + 1):
        c.px(mx + dx, my, K.UMBER)
    tongue = c.m(K.ell(33.5, 46.5, 5.2 * k, 5.4), K.rect(29.5, 41.5, 37.5, 46))
    c.add(tongue, TONGUE)
    c.edge(tongue, TONGUE[1])
    tx = c.P(33.5, 0)[0]
    for y in range(c.P(0, 43)[1], c.P(0, 49)[1]):
        c.px(tx, y, TONGUE[1])


K.render_pal(fn, 'pl-smg-2', 'Salt Lick', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-2.png')
