#!/usr/bin/env python3
"""giant-anteater "Giant Anteater" (quad.bear rig, 111 x 51, 8 parts; level 22, rainforest; drops Digging Claw, Rubber Sap, Ant Chitin):
"Wears its tail like a cloak and its tongue like a whip."
A big shaggy felt anteater: a deep oatmeal-grey body, highest at the shoulders, with a long hair fringe hanging along the belly
and the famous black shoulder band edged in cream running from the throat up over the shoulder (body). A huge fan of a tail
raised behind like a cloak, combed into long dark strands with a ragged fringe (tail). Pale front legs with a black wrist band,
walking on the knuckles with big cream claws curled up (legFN/legFF); dark hind legs with flat feet (legBN/legBF).
A long tube snout with a little round ear and a pink whip of a tongue flicking from the tip (head); a small bead eye (eyes)."""
import os, sys, importlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
K = importlib.import_module('_quad_barn-rat')

R = Rig('giant-anteater')
OAT = ('#ddd2bf', '#b3a691', '#877a6a', '#5e5249')
DARK = ('#958676', '#6e6058', '#524640', '#3a302e')
BAND = ('#4a3f3e', '#30282a', '#30282a', '#30282a')
PALE = ('#f6efe0', '#ddd4c2', '#b3a691', '#877a6a')
TAIL = ('#b3a691', '#877a6a', '#665a50', '#4a3f3a')
g = R.ground + 1.0

def front(pid, x, ramp, band, claw, upper):
    p, m = K.limb(R, pid, [(R.pv(pid)[0], 30), (x, g - 3)], 7, 5.5, ramp, foot=(x + 1, 4.4, 2.4))
    p.add({q for q in m if q[1] < 36}, upper)                                       # oatmeal shoulder, pale forearm
    p.fill({q for q in m if 38 <= q[1] <= 40}, band[1])                             # black wrist band
    p.add(p.m(capsule([(x + 2, g - 3.5), (x + 5.5, g - 5), (x + 5, g - 7.5)], 2.4, 1.4)), claw, local=True, crescent=1)
    return p

def hind(pid, x, ramp):
    px_, py_ = R.pv(pid)
    p, m = K.limb(R, pid, [(px_, 29), (px_ + 2.5, 37), (x, g - 3)], 7, 5, ramp, foot=(x + 1.5, 4.6, 2.4))
    p.add(p.m(ell(px_ + .5, 31, 5.2, 6)), ramp)
    p.line([(px_ - 2, 33), (px_ + 1, 37)], ramp[2])                                  # knee seam                                     # the round haunch
    K.toes(p, (int(x + 3), int(x + 5)), int(g - 1), PALE[1])
    return p

# far legs, one step darker
hind('legBF', 43.5, darker(DARK))
front('legFF', 72, darker(PALE), BAND, darker(PALE), darker(OAT))

# tail: a huge fan raised behind like a cloak, combed into long strands, ragged fringe
p = R.part('tail')
fan = union(rell(23, 13.5, 14, 7, 46.5), capsule([(34, 24.5), (26, 17)], 7, 9),
            K.tufts([(11.5, 8.5), (12.5, 13.5), (15.5, 17.5), (19.5, 21), (24, 23.5)], 2.0, 2.4),
            K.tufts([(14, 4), (19, 3.2), (24, 5.5), (28.5, 9.5), (31.5, 14)], 1.9, 1.6))
fm = p.add(p.m(fan), TAIL, stitch=TAIL[3])
for a, b in (((31, 21), (14, 4.5)), ((28, 22.5), (13, 9)), ((32, 17), (22, 5)), ((25, 22), (14.5, 14))):
    p.line([a, b], TAIL[3])
p.line([(29, 13), (21, 6.5)], TAIL[0])

# body: deep, highest at the shoulders, a belly fringe, the black shoulder band edged in cream
p = R.part('body')
torso = union(ell(50, 25.5, 19.5, 11.5), ell(62, 23, 12.5, 12.5),
              K.tufts([(35, 34), (40, 35.8), (45, 36.6), (50, 37), (55, 36.8), (60, 36), (65, 34.5)], 2.6, 2.4))
p.add(p.m(torso), OAT, stitch=OAT[3])
p.add(p.m(inter(torso, lambda x, y: y > 33.5)), darker(OAT), local=True)
edge = capsule([(67, 37), (61, 23), (55, 16), (46, 12)], 9, 4)
band = capsule([(67, 37), (61, 23), (55, 16), (46, 12)], 5.4, 1.6)
p.add(p.m(inter(edge, torso)), PALE, flat=True)
p.add(p.m(inter(band, torso)), BAND, flat=True)
for x, y in ((36, 20), (42, 17), (47, 21), (40, 26), (46, 28), (53, 25), (58, 28), (35, 27)):
    p.line([(x, y), (x - 1, y + 2)], OAT[2])                                       # shaggy guard hairs

# near legs
hind('legBN', 38, DARK)
front('legFN', 67, PALE, BAND, (CREAM, CREAM, PAPER[2], PAPER[3]), OAT)

# head: small skull on the shoulder, little round ear, a long tube snout, pink whip tongue
p = R.part('head')
skull = union(ell(74.5, 25, 7, 6.2), capsule([R.pv('head'), (72, 27)], 8, 8))
snout = capsule([(76, 25.5), (90, 28.5), (104.5, 31)], 8, 3.6)
p.add(p.m(skull, snout), OAT)
p.add(p.m(inter(union(skull, snout), below((74, 29.5), (105, 32.6), 0))), (OAT[0], OAT[0], OAT[1], OAT[2]), local=True)   # paler chin
em = p.add(p.m(ell(70.5, 19.8, 2.2, 2.1)), OAT, local=True)                       # little round ear
p.edge(em, OAT[3]); p.px(70, 20, OAT[3])
tongue = capsule([(105, 32), (107, 34), (106, 37), (103.5, 38.5)], 1.8, 1.3)
p.add(p.m(tongue), PETAL, flat=True)
p.add(p.m(ell(105.3, 30.6, 1.3, 1.2)), (INK,) * 4, flat=True)                      # nose tip
for x in (82, 88, 94):
    p.px(x, 26 + (x - 82) * .2, OAT[2])                                             # snout wrinkles

p = R.part('eyes')
K.bead(p, 76.6, 22.7, r=1.2)

R.save()
