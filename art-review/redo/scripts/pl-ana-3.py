#!/usr/bin/env python3
"""pl-ana-3 "Creek Sipper": inner-TBTB, round. A plum tree-hollow frog sitting face on, ankles in the creek.
Round blank N = the dip between the two bulging eye bumps, round tabs W + E = the bent frog knees, round blank S = the gap between
the webbed feet, standing in a teal creek band. Plum doorway body with the door's gold lantern dots as spots, brown sill belly (cell 6-5),
creek teal + a burped bubble from the picture's stream."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PLUM = K.ramp('#6a4250')
DPLUM = K.ramp('#3c2a3c')
SILL = K.ramp('#8c5a48')
GOLD = K.ramp('#d8a860')
CREEK = K.ramp('#3a9aa0')
BUB = '#bfe8e4'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(10, 21, 54, 56)
    eyeL, eyeR = K.ell(20, 19, 9.5, 8.5), K.ell(44, 19, 9.5, 8.5)
    blankN = K.knob('B', 'round', 32, 20, 0, -1, r=3.6 * s)
    blankS = K.knob('B', 'round', 32, 56, 0, 1, r=4.0 * s)
    tabW = K.knob('T', 'round', 10, 42, -1, 0, r=4.6 * s, nw=3.4)
    tabE = K.knob('T', 'round', 54, 42, 1, 0, r=4.6 * s, nw=3.4)
    body = c.m(core, eyeL, eyeR, minus=(blankN, blankS))
    c.add(body, PLUM, stitch=None if c.small else PLUM[1])
    # knees: darker plum tabs with a contour where they meet the body
    kneeL = c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(K.rect(9, 0, 12, 64)))
    kneeR = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(52, 0, 55, 64)))
    c.add(kneeL, PLUM)
    c.add(kneeR, PLUM)
    c.edge(kneeL, PLUM[1])
    c.edge(kneeR, PLUM[1])
    # brown belly
    belly = c.m(K.ell(32, 42, 12, 6.5)) & body
    c.add(belly, K.ramp('#c0907a'))
    # creek band the feet stand in
    c.add(body & c.m(K.rect(0, 50, 64, 64)), CREEK)
    if not c.small:
        y = c.P(0, 50)[1]
        for x in range(c.n):
            if (x // 3) % 2 == 0:
                c.px(x, y + 1, CREEK[2])
    for tx in ((14, 19, 24) if not c.small else (15, 23)):
        c.add(c.m(K.ell(tx, 53, 2.4 * s, 2.2 * s)) & body, PLUM)
    for tx in ((40, 45, 50) if not c.small else (41, 49)):
        c.add(c.m(K.ell(tx, 53, 2.4 * s, 2.2 * s)) & body, PLUM)
    # gold lantern spots (the doorway lights)
    spots = [(15, 31), (49, 31), (15, 48), (49, 48)] if not c.small else [(15, 31), (49, 31)]
    for (x, y) in spots:
        c.add(c.m(K.ell(x, y, 2.6 * s, 2.4 * s)) & body, GOLD)
    # eyes on the bumps
    c.eye(20, 19, disc=True)
    c.eye(44, 19, disc=True)
    # wide frog mouth (a long umber line across, curling up at the ends)
    m0, m1 = c.P(15, 35), c.P(49, 35)
    for x in range(m0[0] + 1, m1[0]):
        c.px(x, m0[1], K.UMBER)
        if not c.small:
            c.px(x, m0[1] + 1, PLUM[1])
    c.px(m0[0], m0[1] - 1, K.UMBER)
    c.px(m1[0], m1[1] - 1, K.UMBER)
    c.blush(20, 32)
    c.blush(43, 32)
    # burped bubble at the mouth corner
    bx, by = c.P(52, 31)
    if not c.small:
        for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            c.px(bx + dx, by + dy, BUB)
        c.px(bx, by, '#ffffff')
    else:
        c.px(bx, by, BUB)
        c.px(bx + 1, by, BUB)


K.render_pal(fn, 'pl-ana-3', 'Creek Sipper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ana-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ana-3.png')
