#!/usr/bin/env python3
"""pl-hcr-1 "Lightning Pinch": corner-BB, hook.
Concept: an open crab claw that is a corner piece. Flat W and S sides (the claw's back and its wrist on a storm-cloud cuff); the pincer
fingers rise from the top corners and the hook blank N is the claw's throat between them; hook blank E bites the palm. Crab red
(#9c2a3c / #d8402e from cell 11-2) over the storm purple (#5a5684 / #44406e) with lavender rain and a yellow lightning bolt."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CRAB = K.ramp('#c0343a')
CRABDK = K.ramp('#9c2a3c')
STORM = K.ramp('#5a5684')
BOLT = ('#f8d040', '#d89a18', '#fff0a0')
ORANGE = '#e8603a'
RAIN = '#b4b0cc'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 24, 54, 58)
    finL = K.poly([(8, 34), (5.5, 20), (9, 10), (16, 4), (25, 1.5), (29, 3), (24, 6.5), (20, 12), (19, 20), (22, 28)])
    finR = K.poly([(54, 34), (56.5, 21), (53, 12), (46, 7), (38, 6), (35, 8), (40, 11), (43, 16), (43, 22), (40, 28)])
    blankN = K.knob('B', 'hook', 31, 25, 0, -1, r=4.4 * k)
    blankE = K.knob('B', 'hook', 54, 41, 1, 0, r=4.2 * k, flip=True)
    body = c.m(core, finL, finR, minus=(blankN, blankE))
    c.add(body, CRAB)
    # darker finger tips (the pincers)
    tips = c.m(lambda x, y: y < 13, minus=(blankN,)) & body
    c.add(tips, CRABDK)
    # cream teeth nubs on the inner edges of the fingers
    for (x0, y0) in ((20.5, 15), (19.5, 21), (43, 15), (43.5, 21)):
        c.add(c.m(K.ell(x0, y0, 1.9, 1.7)), K.CREAM and ('#f2e4c0', '#c9b898', '#ffffff'))
    # storm-cloud cuff along the wrist (flat S side)
    cuff = c.m(lambda x, y: y >= 49 + (1.6 if (int(x) // 6) % 2 else 0) and 8 <= x < 54, minus=(blankE,))
    c.add(cuff & body, STORM)
    # orange speckles on the shell
    if not c.small:
        for (x0, y0) in ((14, 40), (47, 32), (12, 30)):
            c.px(*c.P(x0, y0), ORANGE)
    # lightning bolt down the left finger into the palm
    bw = 3.4 if not c.small else 4.0
    c.add(c.m(K.thick_path([(17, 6), (11, 17), (16, 19), (11, 31)], bw)), BOLT)
    # rain streaks on the cloud cuff
    for (x0, y0) in ((16, 53), (30, 53), (44, 53)):
        c.line([(x0 + 1.5, y0), (x0, y0 + 3.5)], RAIN)
    # face on the palm
    c.eye(25, 38)
    c.eye(38, 38)
    c.smile(31.5, 43)
    c.blush(20, 43)
    c.blush(43, 43)


K.render_pal(fn, 'pl-hcr-1', 'Lightning Pinch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hcr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hcr-1.png')
