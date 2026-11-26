#!/usr/bin/env python3
"""pl-wfla-5 "Question-Mark Neck": inner-BBBB keyhole. A flamingo whose square pink body is the piece (keyhole blanks on all
four sides); its neck rises from the upper right and curls into a question mark over the north blank, head and dark-tipped beak
hanging into the curl. Plum acacia-silhouette wing and lavender hill band from cell 2-3, pink shallows at the feet."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#f07a9c')
NECK = K.ramp('#f590ac')
PLUM = K.ramp('#6e4a6c')
HILL = K.ramp('#b496b8')
WATER = K.ramp('#e8a8c8')
BEAK = K.ramp('#f2e4c8')
TIP = K.ramp('#4a2a3a')
LEG = K.ramp('#d0587e')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(7, 25, 57, 56)
    r = 3.0 * k
    bN = K.knob('B', 'keyhole', 30, 25, 0, -1, r=r, nw=2.0)
    bS = K.knob('B', 'keyhole', 32, 56, 0, 1, r=r, nw=2.0)
    bW = K.knob('B', 'keyhole', 7, 38, -1, 0, r=r, nw=2.0)
    bE = K.knob('B', 'keyhole', 57, 38, 1, 0, r=r, nw=2.0)
    blanks = (bN, bS, bW, bE)
    legs = c.m(K.thick_path([(19, 54), (19, 62)], 3.0 * k), K.thick_path([(45, 54), (45, 62)], 3.0 * k), minus=blanks)
    c.add(legs, LEG)
    body = c.m(core, minus=blanks)
    c.add(body, PINK, stitch=None if c.small else '#ffc4d4')
    tail = c.m(K.poly([(7, 25), (2.5, 19.5), (4.5, 18), (10, 21), (13, 25)]))
    c.add(tail, LEG)
    # lavender hill band and pink shallows across the lower body (the cell's horizon)
    c.add(body & c.m(K.rect(0, 46, 64, 51)), HILL)
    c.add(body & c.m(K.rect(0, 51, 64, 56)), WATER)
    # wing: plum acacia-crown shape on the body
    wing = c.m(K.ell(36, 36, 12, 4.5), K.ell(45, 39.5, 8, 3.5), minus=blanks)
    c.add(wing & body, PLUM)
    # question-mark neck
    nw = 5.0 if not c.small else 5.6
    neck = c.m(K.thick_path([(47, 28), (48, 19), (46.5, 11), (42, 6), (36, 5), (31, 7.5)], nw))
    c.add(neck, NECK)
    head = c.m(K.ell(28.5, 10.5, 5.0, 4.2))
    c.add(head, NECK)
    beak = c.m(K.thick_path([(26, 13), (25.5, 17.5)], 3.4 * k))
    c.add(beak, BEAK)
    c.add(c.m(K.thick_path([(25.5, 17.2), (26.5, 20.5)], 3.2 * k)), TIP)
    c.edge(head, NECK[1])
    c.eye(29.5, 9.5)
    if not c.small:
        c.blush(32, 12)
        # ripples in the shallows
        for x0 in (12, 41):
            y = c.P(0, 53)[1]
            for x in range(c.P(x0, 0)[0], c.P(x0 + 6, 0)[0]):
                c.px(x, y, '#fbd8e6')


K.render_pal(fn, 'pl-wfla-5', 'Question-Mark Neck', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfla-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfla-5.png')
