#!/usr/bin/env python3
"""mire-toad "Mire Toad" (frog rig, 69 x 45, 5 parts, front view): "Ancient, warty, and much bigger than it has any right to be." (large; wetland; rain, fog; Mire Hide, Toad Jewel)
An old felt toad squatting low and wide in the bog: a flat, broad teal-olive body whose top edge is lumpy with big warts (so the one-piece
outline reads lumpy, not like a smooth bullfrog egg), two fat ochre poison glands behind the eyes, a long grim down-turned mouth seam,
a dirty-cream mottled belly and thick turned-in arms with stubby fingers (body, squashes from the ground); heavy splayed hind legs with
long webbed toes sticking out at both sides (footL / footR); and two low eye domes with copper eyes, horizontal pupils and a heavy
half-closed lid, the grumpy old-toad look (eyeL / eyeR, they squash down onto their pivots)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('mire-toad')
import math
SKIN = ('#93b39a', '#5f8873', '#45665a', '#2c463e')       # teal-olive bog felt
BACK = ('#8e9e66', '#66764a', '#4b5838', '#323c28')        # the olive, mossier back
WART = ('#a38a5c', '#7a6240', '#58462e', '#3c2f20')        # mud-brown warts
GLAND = ('#e8c25a', '#c99a2e', '#9a7020', '#6a4a18')       # ochre poison glands
BELLY = ('#e9dfba', '#cfc394', '#a99b6a', '#7a6c46')       # dirty cream
EYE = ('#f0a860', '#c8702a', '#8f4a1c', '#5a2a12')         # copper
CX = 35

# hind legs: a fat haunch on each side, the foot splayed out on the mud with three long webbed toes
for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    s = -1 if pid == 'footL' else 1
    toes = union(capsule([(x, 38), (x - s * 10, 39.5)], 3, 2.4), capsule([(x, 38), (x - s * 8.5, 36)], 3, 2.2),
                 capsule([(x + s * 2, 38.5), (x - s * 2, 40)], 3, 2.4))
    web = poly([(x, 37), (x - s * 9.5, 36.5), (x - s * 10, 39.5), (x - s * 2, 40)])
    p.add(p.m(toes, web), darker(SKIN), local=True)
    haunch = ell(x + s * 1.5, 31, 8.5, 7.2)
    p.add(p.m(haunch), SKIN)
    p.line([(x - s * 5, 27), (x + s * 1, 34)], SKIN[2])                                   # knee fold
    p.pxs([(x + s * 3, 27), (x - s * 2, 31), (x + s * 5, 31), (x + s * 3, 33)], WART[1]); p.px(x + s * 4, 27, WART[0])                  # leg warts
    p.pxs([(x - s * 6, 39), (x - s * 8, 37)], SKIN[3])                                   # toe seams

# body: low wide dome whose top edge is broken up by big warts
p = R.part('body')
dome = union(ell(CX, 29, 24.5, 11.5), ell(CX - 21.5, 26, 3.6, 3.4), ell(CX + 21.5, 26, 3.6, 3.4), rect(CX - 8, 38, CX + 9, 40.2))
lumps = []
for deg, r in ((200, 2.0), (186, 2.6), (172, 2.2), (158, 2.8), (146, 2.0), (124, 2.4), (106, 2.6), (90, 3.0), (74, 2.5), (56, 2.3),
               (34, 2.0), (22, 2.8), (8, 2.2), (-6, 2.6), (-20, 2.0)):
    t = math.radians(deg)
    lumps.append((CX + 24.5 * math.cos(t) * .98, 29 - 11.5 * math.sin(t) * .98, r * 1.15))
bod = union(dome, *[ell(x, y, r, r * .9) for x, y, r in lumps])
p.add(p.m(bod), SKIN, stitch=None)
p.add(p.m(inter(bod, lambda x, y: y < 25 + abs(x - CX) * .1)), BACK)
belly = inter(union(ell(CX, 37.5, 16, 6.5), ell(CX - 6, 34.8, 5, 2.4), ell(CX + 5, 34.6, 6, 2.6)), bod)
p.add(p.m(belly), BELLY)
for q in ((27, 35), (30, 37), (36, 34), (39, 36), (33, 38), (42, 38), (24, 37), (45, 35), (28, 39), (37, 39)):   # belly mottles
    p.px(q[0], q[1], BELLY[2]); p.px(q[0] + 1, q[1], BELLY[2]); p.px(q[0], q[1] + 1, BELLY[3] if q[0] % 3 == 0 else BELLY[2])
for gx in (-1, 1):                                                                        # fat ochre poison glands behind the eyes
    gm = p.m(rell(CX + gx * 17.5, 24.4, 6.5, 3.0, gx * 24))
    p.add(gm, GLAND, local=True, crescent=1)
    p.edge(gm, GLAND[3])
    for k in (-3, 0, 3):                                                                  # gland pores
        p.px(CX + gx * (18 + k), 24.6 + gx * k * .45, GLAND[3])
# warts: mud-brown bumps all over the back and flanks (the outline lumps too)
for x, y, r in lumps:
    p.add(p.m(inter(ell(x, y + .3, r * .62, r * .55), bod)), WART, local=True, crescent=0)
for q in ((35, 22), (30, 24), (40, 24), (35, 26.5), (24, 28), (46, 28), (19, 31), (51, 31), (14, 28), (56, 28)):
    p.add(p.m(ell(q[0] + .5, q[1] + .5, 1.6, 1.4)), WART, local=True, crescent=0)
# the grim mouth: a long seam arching up in the middle, corners dragged down
mouth = [(13, 31.5), (17, 29.6), (25, 28.2), (35, 27.6), (45, 28.2), (53, 29.6), (57, 31.5)]
p.line(mouth, INK)
p.pxs([(12, 32), (12, 33), (11, 34), (58, 32), (58, 33), (59, 34)], INK)
p.line([(18, 31), (25, 29.6), (45, 29.6), (52, 31)], SKIN[3])                         # heavy lower lip / jowl shadow
p.pxs([(32, 26), (38, 26)], SKIN[3])                                                      # nostrils
for hx, s in ((25, -1), (45, 1)):                                                         # thick arms, stubby fingers turned in
    arm = union(capsule([(hx + s * 2, 32.5), (hx, 38.5)], 5.5, 5), ell(hx - s * .5, 39, 4, 1.6))
    am = p.add(p.m(arm), SKIN, local=True, crescent=1)
    p.edge(am, SKIN[3])
    p.pxs([(hx - 2, 39), (hx, 40), (hx + 2, 39)], SKIN[3])
    p.line([(hx + s * 4, 32), (hx + s * 2.5, 35)], SKIN[2])
    p.px(hx + s * 1, 34, WART[1])

# eye domes: low, copper eyes under a heavy, slanted, half-closed lid (inner corner lower: a scowl)
for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    inner = 1 if pid == 'eyeL' else -1                                                    # direction toward the face centre
    dome = union(ell(x, y - 4.8, 7, 6), ell(x - inner * 4, y - 9.6, 2.2, 2), ell(x + inner * 2, y - 10.4, 2, 1.8))
    p.add(p.m(dome), BACK)
    eye = ell(x, y - 4.4, 4.6, 4.0)
    p.add(p.m(eye), (INK,) * 4, flat=True)
    iris = ell(x, y - 4.4, 3.5, 2.9)
    p.add(p.m(iris), EYE, flat=True)
    p.add(p.m(inter(iris, lambda X, Y: Y > y - 2.6)), (EYE[2],) * 4, flat=True)
    p.add(p.m(rect(x - 2.5, y - 4.2, x + 2.5, y - 3.2)), (INK,) * 4, flat=True)              # flat horizontal pupil
    # the lid: covers the top half, its lower edge slants down toward the nose
    lid = inter(ell(x, y - 4.4, 5.2, 4.6), lambda X, Y: Y < (y - 5.2) + inner * (X - x) * .32)
    lm = p.m(lid)
    p.add(lm, (BACK[0], BACK[1], BACK[1], BACK[2]), local=True, crescent=0)
    lo = {(X, Y) for (X, Y) in lm if (X, Y + 1) not in lm}
    for q in lo:
        p.px(q[0], q[1], INK)
    p.px(int(x + 1.5), int(y - 3), EYE[0]); p.px(int(x - 2), int(y - 3), EYE[0])
    p.pxs([(int(x) - 3, int(y - 9)), (int(x) + 1, int(y - 10)), (int(x) + 3, int(y - 7))], WART[1])   # warts on the brow
    p.px(int(x - inner * 4), int(y - 10), WART[1])

R.save()
