#!/usr/bin/env python3
"""paper-wasp "Paper Wasp" (bug.wasp rig, 75 x 56, 11 parts): "A striped guard with a short temper." (lv 6; grassland, forest, desert; sun, heat;
Wasp Stinger, Paper Comb)
A slim felt paper wasp hovering in profile, legs dangling the way real paper wasps fly: a long spindle gaster in gold and plum-black bands
on a thin waist, with a dark sting at the tip (abdo, behind the thorax); a plum-black thorax with gold shoulder flashes (body); a round head,
gold face and black crown with orange hooked jaws (head); a cream button eye under a cross slanted brow (eyes: the short temper);
long orange elbowed feelers (antL / antR); two narrow smoky paper wings with a dark leading edge and veins, standing up behind (wingB darker,
wingF); three long gold legs hanging under it, dark thighs, the hind one trailing (leg1..leg3)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('paper-wasp')
YEL = ('#fff3a0', '#f5c832', '#d89a18', '#9a6414')
BLK = ('#6a5068', '#43303f', '#33232c', '#2a1a10')        # plum felt black (lighter than the ink so the outline still reads)
ORA = ('#f5cf6a', '#f08a3a', '#c45a1f', '#7a3a1f')
WING = ('#fbf3dc', '#e8d6aa', '#c9ac72', '#9a7a4a')       # smoky paper


def rell2(a, b, w):
    cx, cy = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    return rell(cx, cy, math.hypot(b[0] - a[0], b[1] - a[1]) / 2, w / 2, math.degrees(math.atan2(b[1] - a[1], b[0] - a[0])))


for pid, knee, foot in (('leg1', (31.5, 43), (27, 50)), ('leg2', (39, 44), (35.5, 50.5)), ('leg3', (45.5, 44.5), (43, 50.5))):
    p = R.part(pid)
    x, y = R.pv(pid)
    p.add(p.m(capsule([(x, y - 1), knee], 2.8, 2.3), capsule([knee, foot], 2.2, 1.8)), darker(YEL) if pid == 'leg1' else YEL, crescent=0)
    p.add(p.m(capsule([(x, y - 1), (x + (knee[0] - x) * .35, y + (knee[1] - y) * .35)], 3, 2.6)), BLK, local=True, crescent=0)
    p.px(int(foot[0]) + (1 if pid != 'leg1' else -1), int(foot[1]), ORA[2])            # a little hooked foot

for pid, tip, w, ramp in (('wingB', (26, 3.5), 7.5, darker(WING)), ('wingF', (16.5, 11), 8.5, WING)):
    p = R.part(pid)
    a = R.pv(pid)
    wm = rell2((a[0] + 1, a[1] + 1), tip, w)
    p.add(p.m(wm), ramp, stitch=None)
    p.add(p.m(inter(wm, below(tip, a, 1.6))), (ramp[2], ramp[2], ramp[3], ramp[3]), flat=True)   # darker leading edge along the top
    mid = ((a[0] + tip[0]) / 2, (a[1] + tip[1]) / 2)
    p.line([a, (mid[0] + .5, mid[1] + 1.5), (tip[0] + 2.5, tip[1] + 1.5)], ramp[3])        # veins
    p.line([(mid[0] + .5, mid[1] + 1.5), (mid[0] - 2.5, mid[1] + 4)], ramp[3])

p = R.part('abdo')
gas = union(rell2((32, 34), (6.5, 38.5), 12.5), poly([(9, 35.5), (3.5, 40), (9.5, 40.5)]))
p.add(p.m(gas, capsule([R.pv('abdo'), (32, 34)], 4, 4)), YEL, stitch=None)
ux, uy = (6.5 - 33.5) / 27.4, (38.5 - 33.5) / 27.4
along = lambda x, y: (x - 33.5) * ux + (y - 33.5) * uy
for t0, t1 in ((4.5, 7.5), (10.5, 13.2), (16, 18.2), (21.5, 23.2)):                           # plum-black bands, waist first
    p.add(p.m(inter(gas, lambda x, y, t0=t0, t1=t1: t0 <= along(x, y) < t1)), BLK)
p.add(p.m(inter(gas, lambda x, y: along(x, y) >= 25.5)), BLK)
for q in ((25, 34.5), (18.5, 33.5)):                                                     # the two black dots of a paper wasp
    p.add(p.m(ell(q[0], q[1] + 2.5, 1.1, 1)), BLK, flat=True)
p.add(p.m(capsule([R.pv('abdo'), (32, 34)], 3, 3)), BLK, local=True, crescent=0)        # the thin waist
p.line([(4, 40), (2, 41)], INK)                                                          # the sting

p = R.part('body')
th = union(ell(41.5, 31.5, 7.8, 7.4), ell(35, 28.5, 3.2, 3), capsule([(35.5, 36.5), (47, 36.5)], 5))
p.add(p.m(th), BLK, stitch=None)
p.add(p.m(inter(rell(42.5, 26.5, 5.5, 1.8, 8), th)), YEL, local=True, crescent=0)        # gold collar and shoulder flashes
p.add(p.m(inter(rell(38.5, 34, 3, 1.6, 30), th)), YEL, local=True, crescent=0)
p.add(p.m(inter(ell(45.5, 34.5, 2, 1.5), th)), YEL, local=True, crescent=0)
p.line([(39, 25.5), (37.5, 30)], BLK[0])                                                 # a seam

p = R.part('head')
hd = union(ell(53.5, 31.5, 8.5, 8), capsule([R.pv('head'), (50, 31)], 7, 7), ell(48.2, 25.3, 2, 2))
p.add(p.m(hd), BLK)
face = inter(hd, below((45, 28), (62, 23), 0))
p.add(p.m(face), YEL)
jaw = poly([(57, 35.5), (63, 34.5), (65, 36.5), (64.5, 38.8), (62.5, 37.3), (58.5, 39.5)])
p.add(p.m(jaw), ORA, local=True, crescent=0)
p.line([(60, 36.5), (63, 36)], ORA[3])
p.add(p.m(ell(57.5, 34.6, 1.3, .9)), (BLUSH,) * 4, flat=True)                            # felt cheek
p.add(p.m(inter(ell(60.5, 29.5, 1.2, 1.2), hd)), YEL, local=True, crescent=0)             # gold spot on the brow

p = R.part('eyes')
ex, ey = 53, 29.2
p.add(p.m(ell(ex + .5, ey + .5, 3.5, 3.6)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .5, ey + .5, 2.5, 2.6)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(54, 28, 56, 31)), (INK,) * 4, flat=True)
p.px(52, 28, '#ffffff')
p.add(p.m(inter(ell(ex + .5, ey + .5, 3.5, 3.6), lambda x, y: y < 27 + (x - 50) * .4)), (BLK[0],) * 4, flat=True)   # cross lid, low at the front
p.line([(49, 25), (57, 28)], INK)                                                       # the scowl

for pid, pts in (('antL', [R.pv('antL'), (46, 17.5), (47.5, 12)]), ('antR', [R.pv('antR'), (56.5, 18.5), (62.5, 15)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts[:2], 2.4, 2)), BLK, crescent=0)
    p.add(p.m(capsule(pts[1:], 2, 2.2)), ORA, local=True, crescent=0)
    p.px(int(pts[-1][0]), int(pts[-1][1]), ORA[3])

R.save()
