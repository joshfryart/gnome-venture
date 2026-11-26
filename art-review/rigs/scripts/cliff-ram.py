#!/usr/bin/env python3
"""cliff-ram "Cliff Ram" (quad.ungulate rig, 85 x 56, 8 parts; large; mountain; drops Goat Hair, Slate Shard, Frost Crystal; attack: charge)
"Lowers its curled horns and treats the ledge as private property."
A compact, deep-chested mountain ram in taupe-grey felt with a cream belly, a cream rump patch and a stitched seam all round;
a short dark mane line down the back. Slim sure-footed legs with knees, cream socks and dark split hooves (legs).
A small cream-and-fawn tail stub (tail). A short Roman-nosed head with a cream muzzle and, the signature, one huge ridged
horn that curls back, down and round under the ear to point its tip forward at the cheek (head). Gold eye, ink pupil (eyes)."""
import math
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
import importlib
K = importlib.import_module('_quad_wild-boar')

R = Rig('cliff-ram')
FUR = ('#c8b8a4', '#9e8c78', '#78685a', '#524640')
FAR = darker(FUR)
BELLY = PAPER
HOOF = ('#6a5648', '#4a3a32', '#2e221c', '#2a1a10')
HORN = ('#fff0c0', '#f0cf84', '#c99a4e', '#8a5e2a')
G = R.ground + 1


def legsock(p, fx, ramp):
    """cream sock above the hoof"""
    p.add(p.m(inter(rect(fx - 3, G - 7, fx + 4, G - 3), lambda x, y, p=p: True)), ramp, local=True)


# far legs
for pid, fx in (('legBF', 30), ('legFF', 58.5)):
    p, m = K.leg(R, pid, fx, FAR, 5.5, 3.2, top=3, knee=(R.pv(pid)[0] - (1 if pid == 'legBF' else -.5), 42), foot=HOOF, foot_w=3.6)

# tail: a short stub off the rump
p = R.part('tail')
p.add(p.m(ell(18.5, 22, 3.2, 2.4)), FUR, local=True)
p.add(p.m(ell(18, 23.3, 2.2, 1.3)), BELLY, local=True)

# body: rump, deep chest, level back; cream belly and rump patch, dark mane line
p = R.part('body')
torso = union(ell(28.5, 23.5, 10.5, 10.5), ell(48, 22.5, 14, 12.5), ell(56.5, 28, 6.5, 6.5), poly([(21, 18), (32, 13), (50, 10), (60, 15), (62, 30), (28, 33)]))
p.add(p.m(torso), FUR, stitch=FUR[3])
p.add(p.m(inter(torso, lambda x, y: y > 30 - (x - 40) * .08)), BELLY, local=True)
p.add(p.m(inter(torso, ell(21.5, 22.5, 5.5, 6.5))), BELLY, local=True)                   # rump patch
p.line([(31, 14), (42, 12), (54, 12)], FUR[3])                                           # mane line down the back
p.line([(36, 20), (37, 23)], FUR[3]); p.line([(46, 18), (47, 21)], FUR[3])

# near legs: haunch and shoulder pads, slim shank with a knee, cream sock, hoof
for pid, fx, th in (('legBN', 25, (6.5, 7)), ('legFN', 53.5, (5, 6))):
    px_, py_ = R.pv(pid)
    p, m = K.leg(R, pid, fx, FUR, 6, 3.6, top=3, knee=(px_ + (-.5 if pid == 'legBN' else .8), 42), thigh=th, foot=HOOF, foot_w=3.8)
    sock = p.m(inter(capsule([(fx, G - 8), (fx, G - 3.5)], 4.2), lambda x, y: y < G - 3))
    p.add(sock, BELLY, local=True)
    p.edge(p.m(inter(ell(px_, py_ - .6, th[0], th[1]), lambda x, y: y < py_ + 2)), FUR[3], sides=((0, -1), (-1, 0) if pid == 'legBN' else (1, 0)))

# head: neck, short Roman-nosed face, cream muzzle, little ear, big curled horn
p = R.part('head')
face = union(capsule([R.pv('head'), (63, 14)], 12, 10), ell(66, 13, 7, 6.3), capsule([(66, 13), (78.5, 17)], 9, 6.5))
p.add(p.m(face), FUR)
p.edge({q for q in p.m(face) if q[0] < 56}, INK, sides=((-1, 0), (0, -1)))
p.add(p.m(inter(face, ell(78, 17.5, 5.5, 4.5))), BELLY, local=True)                      # muzzle
p.px(80, 15, INK); p.px(81, 15, INK)                                                     # nostril
p.line([(81, 19.5), (77, 20)], INK)                                                      # mouth
# the curled horn: a tapered spiral from the crown, back, down and round to point forward
c = (59.5, 13)
pts = []
for i in range(19):
    t = i / 18
    a = math.radians(-50 - 290 * t)
    r = 7.4 - 3.6 * t
    pts.append((c[0] + r * math.cos(a), c[1] + r * math.sin(a)))
hm = p.m(capsule(pts, 6.4, 2.8))
p.add(hm, HORN, local=True)
for i in range(1, 17, 2):                                                                 # growth ridges across the horn
    a = math.radians(-50 - 290 * i / 18); r = 7.4 - 3.6 * i / 18
    for d in (-1.8, -.6, .6, 1.8):
        p.px(c[0] + (r + d) * math.cos(a), c[1] + (r + d) * math.sin(a), HORN[2])
p.edge(hm, UMBER2)

p = R.part('eyes')
K.eye_dot(p, 67, 13, r=1.3, iris=GOLD[0])

R.save()
