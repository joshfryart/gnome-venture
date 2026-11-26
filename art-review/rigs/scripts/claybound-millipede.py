#!/usr/bin/env python3
"""claybound-millipede "Claybound Millipede" (worm rig, 81 x 42, 16 parts): "A long, slow millipede in a clay shell that rattles as it
goes. It is a patrol of one." (trek, the Weeping Clay / the Hush, large, L20; Millipede Plate)
A tall, round-backed felt millipede caked in terracotta clay: seven high domed rings (s1..s7) arching up in the middle and rounding
off at a blunt tail, each ring with a dark groove at its back edge, a pale clay rim, and wet clay weeping down its flanks in glossy
dark drips (Claybound). Under each ring a comb of short straight legs (l1..l7, two near pale, two far dark): millipede legs, many and
tidy, not splayed like a centipede. The head (head) is a round clay dome with a pale muzzle and two short elbowed club antennae.
Eye: one sleepy, half-lidded button eye (eyes): a slow patrol of one. Rings lit against the whole body (ref=)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_giant-centipede')

R = Rig('claybound-millipede')
G = R.ground + .5
CLAY = ('#f0b884', '#cf7f4c', '#a05a32', '#6a3420')
RIM = ('#f8d8b0', '#f0c090', '#cf7f4c', '#a05a32')
WET = ('#9a6040', '#6a3e24', '#4a2a18', '#3f2416')
LEGN = ('#f2d0a0', '#d8a070', '#a87048', '#6a3420')
LEGF = ('#b88058', '#8a5634', '#6a3e24', '#4a2a18')
SEGS = ['s1', 's2', 's3', 's4', 's5', 's6', 's7']
PV = {k: R.pv(k) for k in R.ids}
TAIL = (11.5, 28.4)
HT = [7, 8.6, 9.4, 9.4, 8.6, 7.2, 5.6]
HB = [5.6, 5.8, 5.9, 5.9, 5.6, 5, 4.4]

shape = {}
for i, pid in enumerate(SEGS):
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < 7 else TAIL
    shape[pid] = H.seg_mask(R, a, b, back=1.5 if i < 6 else 3, front=1.8 if i else 4, h_top=HT[i], h_bot=HB[i], n=2.0)
REF = R.part('s1').m(*shape.values())

for i, pid in enumerate(SEGS):
    p = R.part(pid)
    mk = p.add(p.m(shape[pid]), CLAY, ref=REF)
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < 7 else TAIL
    if i:
        H.seam_over(p, mk, R.part('s1').m(shape[SEGS[i - 1]]), CLAY[3])
    H.blob(p, {q for q in mk if q[1] + .5 > a[1] + HB[i] * .3}, ('#d88c58', '#b86c40', '#8a4a28', '#6a3420'))   # darker clay belly band
    # wet clay weeping down the flank: a glossy drip from the top, with a cream glint
    top = min(y for x, y in mk if abs(x + .5 - (a[0] + b[0]) / 2) < 1)
    cx = (a[0] + b[0]) / 2 + .3
    if i < 6:
        cx += (-1.2, 1, -.6, 1.2, -1, .4)[i]
        ln = 4.5 + (i * 5 % 3) * 1.5
        drip = p.m(capsule([(cx, top + .5), (cx - .2, top + ln)], 2.2, 2.0)) & mk
        H.blob(p, drip, WET)
        p.px(cx - 1, top + 1.5, '#f2d8b0')
    H.stitch_line(p, [(cx - 2.5, top + 2.2), (cx + 2.5, top + 2.4)], RIM[0], gap=1)               # a felt stitch across the ring

# legs: a tidy comb of short straight legs (far ones dark, near ones pale)
for i in range(7):
    pid = 'l%d' % (i + 1)
    p = R.part(pid)
    x, y = PV[pid]
    H.leg(p, [(x + 2, y - .5), (x + 2.8, G - .4)], [1.5, 1.3], LEGF, knee=False)
    H.leg(p, [(x - .8, y - .5), (x - 1.2, y + 4), (x - .6, G - .4)], [1.8, 1.6, 1.4], LEGN)

# head: round clay dome, pale muzzle, two short elbowed club antennae
p = R.part('head')
hp = PV['head']
dome = union(ell(67, 21.4, 7.6, 6.8), capsule([hp, (63, 22)], 9, 9))
for (bx_, col) in ((3.6, LEGF), (0, LEGN)):
    p.add(p.m(capsule([(66.5 + bx_, 15.5), (67.2 + bx_ * 1.4, 9.5), (70.5 + bx_ * 2, 5.6 + bx_ * .6)], 1.5, 1.3)), col, local=True, crescent=0)
    p.add(p.m(ell(71.5 + bx_ * 2, 4.6 + bx_ * .6, 1.6, 1.5)), col, local=True, crescent=1)
p.add(p.m(dome), CLAY, stitch=CLAY[3])
p.add(p.m(inter(ell(71.5, 24.2, 4.4, 3.4), dome)), RIM, local=True, crescent=1)                   # pale muzzle
p.line([(74.5, 25), (71.5, 26.2)], CLAY[3])                                                       # little mouth
p.px(70, 23, BLUSH); p.px(69, 23, BLUSH)
H.blob(p, p.m(capsule([(63.5, 15.2), (63.2, 19.6)], 2.2, 1.8)) & p.m(dome), WET)                  # a clay drip on the crown
p.px(63, 16, '#f2d8b0')

p = R.part('eyes')
H.button_eye(p, 68.4, 17.7, r=1.8, lid=CLAY[2], look=1)
p.line([(66, 16.4), (70.6, 16.4)], INK)

R.save()
