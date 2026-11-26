#!/usr/bin/env python3
"""mm-gatepost-hoot "Gatepost Hoot" (rare, whimsy-owl, keyhole).
An owl that is a puzzle piece: square-ish owl body with a flat straight head-top between two small rounded ear tufts (N),
a keyhole TAB at E (the folded wing tip), a keyhole BLANK at W, and a keyhole TAB at S that is the gatepost stub it perches on.
Colours from cell 7-4 of Mistmoor: sign-board wood browns, teapot cream face/belly, moss-green post cap, lavender heather."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

OWL = ramp('#7a5a3e')       # owl in the picture (121,94,67) nudged warm
WING = ramp('#593e2b')      # dark sign board
CREAMR = ramp('#e6e2d6')    # teapot cream
POST = ramp('#a77a50')      # light frame wood
MOSS = ramp('#6e7f49')      # meadow moss
HEATH = ramp('#9a6ab8')     # lavender heather
BEAK = ramp('#e8a317')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 13, 51, 50)
    rc = lambda x, y: not ((x < 16 and y > 47 and (x - 16) ** 2 + (y - 47) ** 2 > 9) or (x > 48 and y > 47 and (x - 48) ** 2 + (y - 47) ** 2 > 9))
    corefull = lambda x, y: core(x, y) and rc(x, y)
    tuftL = poly([(13, 16), (12.5, 7.5), (15, 6.5), (23, 13.5)])
    tuftR = poly([(51, 16), (51.5, 7.5), (49, 6.5), (41, 13.5)])
    tuftLr = ell(14.5, 8.5, 2.6, 2.6)
    tuftRr = ell(49.5, 8.5, 2.6, 2.6)
    tabE = knob('T', 'keyhole', 51, 31, 1, 0, r=4.6 * k)
    blankW = knob('B', 'keyhole', 13, 32, -1, 0, r=4.4 * k)
    tabS = knob('T', 'keyhole', 32, 50, 0, 1, r=4.6 * k)
    body = c.m(corefull, tuftL, tuftR, tuftLr, tuftRr, minus=(blankW,))
    c.add(body, OWL, stitch=None)
    # gatepost stub: the S tab, light wood, with moss cap line at the top
    post = c.m(tabS, minus=(core,))
    c.add(post, POST)
    # wings: dark board brown down both sides; E wing carries the E tab
    wingE = c.m(lambda x, y: x > 40 and y > 22 and corefull(x, y) and (x - 40) > (y - 22) * 0.25, tabE)
    c.add(wingE, WING)
    wingW = c.m(lambda x, y: x < 21 and y > 24 and corefull(x, y) and (21 - x) > (y - 24) * 0.25, minus=(blankW,))
    c.add(wingW, WING)
    if not c.small:
        for (x, y) in wingE | wingW:
            if (y % 4 == 0) and (x + y) % 3 == 0:
                c.px(x, y, WING[2])
    # cream belly with brown chevrons
    belly = c.m(ell(32, 39, 10.5, 10), minus=(lambda x, y: y > 48,))
    belly &= body
    c.add(belly, CREAMR)
    chev = [(27, 36), (32, 37.5), (37, 36)] if not c.small else [(26, 37), (32, 39), (38, 37)]
    for dy in ((0, 5) if not c.small else (0,)):
        pts = []
        for i in range(-2, 3):
            pts.append((32 + i * 2.6, 35.5 + dy + abs(i) * -0.9))
        if not c.small:
            for i in (-1, 1):
                for j in (-1, 1):
                    cx, cy = c.P(32 + i * 4 + j * 1.2, 36 + dy + (0 if j == i else 0))
            for xx in (27, 32, 37):
                X, Y = c.P(xx, 36 + dy)
                c.px(X - 1, Y, OWL[0]); c.px(X, Y + 1, OWL[0]); c.px(X + 1, Y, OWL[0])
        else:
            for xx in (28, 35):
                X, Y = c.P(xx, 39)
                c.px(X - 1, Y, OWL[1]); c.px(X, Y + 1, OWL[1]); c.px(X + 1, Y, OWL[1])
    # talons gripping the post top: a moss-capped plank along the base
    plank = c.m(rect(15, 47, 49, 50.5)) & body
    c.add(plank, MOSS)
    for tx in (27, 37):
        X, Y = c.P(tx, 47)
        for d in (-1, 0, 1):
            c.px(X + d, Y, BEAK[1])
    # face: two big cream discs (facial disc) with felt eyes, beak between
    fr = 7.2 if not c.small else 7.6
    c.add(c.m(ell(24.5, 24, fr, fr * 0.95)) & body, CREAMR)
    c.add(c.m(ell(39.5, 24, fr, fr * 0.95)) & body, CREAMR)
    c.edge(c.m(ell(24.5, 24, fr, fr * 0.95)) & body, OWL[1])
    c.edge(c.m(ell(39.5, 24, fr, fr * 0.95)) & body, OWL[1])
    if not c.small:
        for (ex, ey) in ((24.5, 24), (39.5, 24)):
            cx, cy = c.P(ex, ey)
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    if dx * dx + dy * dy <= 10:
                        c.px(cx + dx, cy + dy, BEAK[0])
    else:
        for (ex, ey) in ((24.5, 24), (39.5, 24)):
            cx, cy = c.P(ex, ey)
            for dx in range(-1, 3):
                for dy in range(-1, 3):
                    if not (dx in (-1, 2) and dy in (-1, 2)):
                        c.px(cx + dx, cy + dy, BEAK[0])
    c.eye(24.5, 24.5)
    c.eye(39.5, 24.5)
    c.add(c.m(poly([(29.5, 29), (34.5, 29), (32, 34.5)])), BEAK)
    # heather sprig on the gatepost stub
    hx, hy = c.P(29, 55)
    c.px(hx, hy, HEATH[0]); c.px(hx + 1, hy - 1, HEATH[2])
    if not c.small:
        c.px(hx + 1, hy + 1, HEATH[1]); c.px(hx + 6, hy + 2, HEATH[0]); c.px(hx + 7, hy + 1, HEATH[2])


K.render_pal(fn, 'mm-gatepost-hoot', 'Gatepost Hoot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-gatepost-hoot-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-gatepost-hoot.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
