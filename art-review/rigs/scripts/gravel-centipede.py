#!/usr/bin/env python3
"""gravel-centipede "Gravel Centipede" (worm rig, 103 x 39, 16 parts): "A long grey centipede in a rattling coat of gravel. It has the
whole tunnel to itself and has opinions about that." (trek tunnels, large, L23; Centipede Plate)
A big slate-grey felt centipede wearing its gravel: seven stitched grey plates (s1..s7) sloping down to the tail, each with a row of
fat felt pebbles sewn along its back (grey, sand and blue-grey stones), so the top line is lumpy like a gravel bank, not a tube.
Under each plate a pair of dark slate legs (l1..l7), near leg raked back, far leg forward. The tail ends in two stiff trailing legs.
The head (head) is a blunt grey shield capped with two pebbles, short thick jointed antennae poking forward, and stubby dark fangs.
Eye: one grumpy button eye under a heavy stone brow (eyes): it has opinions. Plates lit against the whole body (ref=)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_giant-centipede')

R = Rig('gravel-centipede')
G = R.ground + .5
SLATE = ('#9aa0a8', '#6e7682', '#4e5664', '#353b46')
BELLY = ('#6e7682', '#5b6470', '#4a505c', '#353b46')
LEGN = ('#aab0b8', '#7e8692', '#5b6470', '#3a404a')
LEGF = ('#6e7682', '#5b6470', '#4a505c', '#353b46')
STONES = [('#fbf8f0', '#d8d3c8', '#a8a398', '#6a665e'), ('#f2e4c0', '#c9a96e', '#9a7a4a', '#6a5030'),
          ('#d6e2ea', '#9fb4c2', '#6a8296', '#3f5468'), ('#e8e4dc', '#aaa69e', '#7a766e', '#4a4640')]
SEGS = ['s1', 's2', 's3', 's4', 's5', 's6', 's7']
PV = {k: R.pv(k) for k in R.ids}
TAIL = (13, 27.2)

shape, pebs = {}, {}
for i, pid in enumerate(SEGS):
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < 7 else TAIL
    shape[pid] = H.seg_mask(R, a, b, back=1.4, front=2 if i else 3.5, h_top=5.4 - i * .3, h_bot=4.4 - i * .2)
    # three pebbles riding the back of the plate
    n = 3 if i < 6 else 5
    pebs[pid] = []
    for k in range(n):
        t = (k + .5) / n
        x = a[0] + (b[0] - a[0]) * t; y = a[1] + (b[1] - a[1]) * t - (5.4 - i * .3) - .6 + (k % 2) * .9
        r = (2.9 - i * .15) * (1.12 if (k + i) % 2 else .88) * (1 - .12 * k * (i == 6))
        pebs[pid].append((x, y, r * 1.2, r, STONES[(k + 2 * i) % 4]))
REF = R.part('s1').m(*shape.values())

for i, pid in enumerate(SEGS):
    p = R.part(pid)
    mk = p.add(p.m(shape[pid]), SLATE, ref=REF)
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < 7 else TAIL
    H.blob(p, {q for q in mk if below(a, b, (4.4 - i * .2) * .35)(q[0] + .5, q[1] + .5)}, BELLY)   # pale underside
    if i:
        H.seam_over(p, mk, R.part('s1').m(shape[SEGS[i - 1]]), SLATE[3])
    if pid == 's7':
        H.leg(p, [(15, 26.5), (8.5, 24.5), (3, 25)], [2.4, 2, 1.6], LEGF)
        H.leg(p, [(15, 28), (9, 30), (3.6, 32.4)], [2.6, 2.2, 1.7], LEGN)
    for (x, y, rx, ry, st) in pebs[pid]:
        p.add(p.m(ell(x, y, rx, ry)), st, local=True, crescent=1)

for i in range(7):
    pid = 'l%d' % (i + 1)
    p = R.part(pid)
    x, y = PV[pid]
    H.leg(p, [(x + .7, y - 1), (x + 2.8, y + 4.2), (x + 2, G - .4)], [2, 1.6, 1.3], LEGF)
    H.leg(p, [(x - .4, y - 1), (x - 1.4, y + 4.6), (x - 4.2, G - .4)], [2.2, 1.8, 1.4], LEGN)

# head: blunt grey shield, pebble cap, short thick antennae, stubby dark fangs
p = R.part('head')
hp = PV['head']
shield = H.seg_mask(R, (85, 19.5), hp, back=3, front=0, h_top=6.4, h_bot=5)
p.add(p.m(capsule([(85, 14), (90, 10), (95, 8.5), (99, 9.5)], 2.4, 1.6)), LEGF, local=True, crescent=0)        # far antenna
p.add(p.m(capsule([(84.5, 24), (89.5, 25.5), (92, 23)], 3, 1.8)), LEGF, local=True, crescent=1)                 # far fang
p.add(p.m(shield), SLATE, stitch=SLATE[3])
H.blob(p, p.m(inter(shield, below((68, 21.5), (87, 21.5), 0))), BELLY)
p.add(p.m(capsule([(82, 13), (84, 7.5), (88.5, 4), (94, 3.6)], 2.6, 1.6)), LEGN, local=True, crescent=0)        # near antenna
p.pxs([(84, 9), (87, 5), (91, 4), (89, 11), (93, 9)], LEGN[3])
p.add(p.m(ell(73.5, 13, 3.4, 2.7)), STONES[1], local=True, crescent=1)                                          # pebble cap
p.add(p.m(ell(69.5, 14.6, 2.2, 1.7)), STONES[2], local=True, crescent=1)
p.add(p.m(capsule([(82, 24.5), (86.5, 27.4), (90, 26.4)], 3.4, 2)), LEGN, local=True, crescent=1)               # near fang
p.pxs([(89, 26), (90, 25), (91, 24)], INK)
p.line([(87, 21.5), (82.5, 23)], SLATE[3])                                                                       # mouth seam
p.px(84, 20, BLUSH); p.px(85, 20, BLUSH)

# eyes: grumpy button eye under a heavy stone brow
p = R.part('eyes')
p.add(p.m(ell(79.4, 15.4, 3.2, 3)), (INK,) * 4, flat=True)
p.add(p.m(ell(79.4, 15.4, 2.3, 2.1)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(80, 15, 82, 17)), (INK,) * 4, flat=True)                                 # pupil, glaring forward
p.px(78, 14, '#ffffff')
p.add(p.m(poly([(75.6, 11.6), (83.4, 12.6), (83.2, 13.6), (76.2, 12.8)])), (SLATE[1],) * 4, flat=True)   # the heavy brow

R.save()
