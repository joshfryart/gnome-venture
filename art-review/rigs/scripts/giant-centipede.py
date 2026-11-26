#!/usr/bin/env python3
"""giant-centipede "Giant Centipede" (worm rig, 79 x 32, 14 parts): "A hundred legs and not one of them friendly." (rainforest/forest, L11; Centipede Plate, Venom Fang)
A long, low felt centipede in jungle red: six flat stitched body plates (s1..s6), each a red pillow with a dark maroon back band,
sloping down to a tail that ends in two long trailing tail legs. Under every plate a pair of gold legs (l1..l6), one near leg raked
back and one darker far leg reaching forward, so the whole side bristles with legs. The head (head) is an orange-red flat shield with
two long jointed gold antennae swept forward and up, and a pair of big curved venom fangs (gold, ink tips) hooking in under the chin.
Eye: one small mean button eye with a heavy red lid (eyes). Plates are lit against the whole body (ref=) and sewn with seams."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_giant-centipede')

R = Rig('giant-centipede')
G = R.ground + .5                                   # foot level (centre of the ground row)
RED = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
BAND = ('#a8241f', '#6e2038', '#4e1a2c', '#3a1420')
LEGN = ('#f5cf6a', '#e8a317', '#b87a14', '#7a4a1f')
LEGF = darker(LEGN)
HEAD = ('#f5a05a', '#e8642a', '#b8401f', '#6e2038')
SEGS = ['s1', 's2', 's3', 's4', 's5', 's6']
PV = {k: R.pv(k) for k in R.ids}
TAIL = (9.5, 20.6)

shape = {}
for i, pid in enumerate(SEGS):
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < len(SEGS) else TAIL
    ht = 4.4 - i * .3; hb = 3.8 - i * .2
    shape[pid] = H.seg_mask(R, a, b, back=1.2 if i < 5 else 1.5, front=1.8 if i else 3.5, h_top=ht, h_bot=hb)
REF = R.part('s1').m(*shape.values())

# s1..s6: red plates with a maroon band at the back edge, a running stitch along the back, seams where each sits on the one ahead
for i, pid in enumerate(SEGS):
    p = R.part(pid)
    mk = p.add(p.m(shape[pid]), RED, ref=REF)
    a = PV[pid]; b = PV[SEGS[i + 1]] if i + 1 < len(SEGS) else TAIL
    bx = b[0] + 2.2
    H.blob(p, {q for q in mk if q[0] + .5 < bx}, BAND)
    p.fill({q for q in mk if q[0] + .5 >= bx and q[0] + .5 < bx + 1}, BAND[0])        # a thin bright welt before the band
    if i:
        H.seam_over(p, mk, R.part('s1').m(shape[SEGS[i - 1]]), RED[3])
    top = min(y for x, y in mk)
    H.stitch_line(p, [(a[0] - 1, a[1] - 1.5), (bx + 1, b[1] - 1.5)], RED[0], gap=1)
    if pid == 's6':                                  # the two long trailing tail legs, swept back
        H.leg(p, [(11.5, 20.2), (6, 17.5), (2, 17.8)], [2.2, 1.8, 1.4], LEGF)
        H.leg(p, [(11.5, 21.3), (6.5, 22.8), (2.2, 25.2)], [2.4, 2, 1.5], LEGN)

# l1..l6: a far leg reaching forward (dark) and a near leg raked back (gold), each with a knee
for i in range(6):
    pid = 'l%d' % (i + 1)
    p = R.part(pid)
    x, y = PV[pid]
    H.leg(p, [(x + .6, y - .8), (x + 2.2, y + 3.4), (x + 1.4, G - .3)], [1.8, 1.5, 1.2], LEGF)
    H.leg(p, [(x - .4, y - .8), (x - 1.2, y + 3.8), (x - 3.6, G - .3)], [2, 1.7, 1.3], LEGN)

# head: a flat orange-red shield, antennae up and forward, venom fangs hooked under the chin
p = R.part('head')
hp = PV['head']
shield = union(H.seg_mask(R, (65.5, 15.2), hp, back=2.5, front=0, h_top=5.2, h_bot=4.4), ell(62, 12.5, 3.6, 3.2))
p.add(p.m(capsule([(65, 12.5), (69, 10), (72.5, 8.8), (76.5, 9.6)], 1.5, 1.1)), darker(LEGN), local=True, crescent=0)   # far antenna, forward
p.add(p.m(capsule([(64.5, 19), (68.5, 19.8), (70.6, 17.6)], 2.2, 1.3)), darker(LEGN), local=True, crescent=0)        # far fang
p.add(p.m(shield), HEAD, stitch=None)
p.add(p.m(capsule([(63.5, 10), (64.6, 6.4), (67.5, 3.4), (72, 2.6)], 1.6, 1.1)), LEGN, local=True, crescent=0)          # near antenna, up
for q in ((64, 7), (66, 4), (69, 3), (70, 10), (73, 9)):
    p.px(q[0], q[1], LEGN[3])
p.add(p.m(capsule([(62, 19.8), (65.5, 22), (68.6, 21.6), (70, 19.6)], 2.6, 1.3)), LEGN, local=True, crescent=1)    # near fang, a hook
p.pxs([(69, 20), (70, 19), (69, 19)], INK)
p.pxs([(70, 17), (70, 18)], INK)
p.line([(66.5, 16.5), (63, 18)], HEAD[3])                                                                              # mouth seam
p.px(64, 15, BLUSH); p.px(65, 15, BLUSH)
H.stitch_line(p, [(57, 12.3), (60, 11)], HEAD[0], gap=1)

# eyes: a small mean button eye with a heavy lid
p = R.part('eyes')
H.button_eye(p, 61.8, 11.9, r=2.0, lid=HEAD[3], look=1)

R.save()
