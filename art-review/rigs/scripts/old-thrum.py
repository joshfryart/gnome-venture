#!/usr/bin/env python3
"""old-thrum "Old Thrum" (bug.wasp rig, 121 x 88, 11 parts; boss, Lv 24, Chapter II-b's Drum Chamber; attack: swoop)
"A hulking clay-crusted cicada nymph the size of a cart, who has been drumming the Chamber walls since before the clay wept.
He is not angry. He is only very, very loud." (drum, harden: his clay shell thickens, crack, molt: sheds the old clay.)
A felt cicada nymph seen from the side: a fat amber barrel abdomen in sewn rings with a pale ribbed drumskin (the tymbal) on its
front flank (abdo); a tall hunched thorax dome (body); both thick under a cracked crust of grey-ochre clay. Two short stubby wing
pads (wingB, wingF) lie back over the hump like folded leaves. A broad blunt head with the striped clypeus bulge of a nymph and
a sucking beak tucked under (head); one big tired cream eye with a heavy lid (eyes); two short bristly antennae (antL, antR).
Legs: two plain walking legs behind (leg1, leg2) and the huge toothed digging foreleg in front (leg3)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('old-thrum')
AMB = ('#f0c890', '#d0975a', '#a06838', '#6e4224')
FARA = ('#d0975a', '#a06838', '#80502c', '#6e4224')
CLAY = ('#efe4cc', '#cdbb9a', '#a38e6c', '#6e5a44')
DRUM = ('#fff3c8', '#f2e4c0', '#d8c49a', '#9a6b3f')
G = R.ground + 1.0


def crust(p, mask, cracks):
    """a cracked clay crust laid over part of the felt"""
    p.add(mask, CLAY, stitch=None, local=True)
    for c in cracks:
        p.line(c, CLAY[3])


def leg(pid, pts, w0, w1, ramp, teeth=0):
    p = R.part(pid)
    p.add(p.m(inter(capsule([R.pv(pid)] + pts, w0, w1), lambda x, y: y < G)), ramp)
    for k in range(teeth):            # the digging foreleg: cream teeth along the underside of the femur
        a, b = pts[0], pts[1]
        t = .25 + k * .22
        p.add(p.m(ell(a[0] + (b[0] - a[0]) * t + 1.5, a[1] + (b[1] - a[1]) * t + 3, 1.3, 1.6)), DRUM, local=True, crescent=0)
    return p


def bent(pid, knee, foot, w, ramp):
    p = R.part(pid)
    a = R.pv(pid)
    p.add(p.m(inter(union(capsule([a, knee], w, w - 1), capsule([knee, foot], w - 1.5, w - 3), ell(knee[0], knee[1], w / 2, w / 2)), lambda x, y: y < G)), ramp)
    p.line([(knee[0] - 1, knee[1] - 1), (knee[0] + 1, knee[1] + 1)], ramp[3])
    p.add(p.m(inter(ell(foot[0] - 1, G - 1.5, 3, 1.8), lambda x, y: y < G)), ramp, local=True)
    return p


bent('leg1', (44, 66), (42, G - 2), 6.5, FARA)
bent('leg2', (58, 71), (57, G - 2), 6.5, FARA)
# the great digging foreleg: a swollen toothed femur, a short tibia and a hooked claw on the ground
p = R.part('leg3')
a = R.pv('leg3')
fem = union(rell(83, 67, 9.5, 5.5, 30), ell(a[0] + 1, a[1] + 1, 4.5, 4.5))
tib = capsule([(89, 71), (95, G - 4)], 6, 4.5)
p.add(p.m(inter(union(fem, tib), lambda x, y: y < G)), AMB)
for k in range(3):                                   # the rake: three cream teeth on the front of the tibia
    p.add(p.m(capsule([(92 + k * 1.2, 72 + k * 3), (96.5 + k * 1, 71 + k * 3)], 2.2, 1.2)), DRUM, local=True, crescent=0)
p.line([(78, 64), (86, 69)], AMB[3])
p.add(p.m(inter(union(capsule([(94, G - 4), (101, G - 1.5)], 3.6, 1.6), capsule([(93, G - 4), (95, G - .5)], 3, 1.4)), lambda x, y: y < G)), DRUM, local=True)

# wing pads: flat stubby leaves folded back over the hump, crusted with clay at the tips
for pid, tip, w in (('wingB', (31, 37), 10), ('wingF', (38, 31), 12)):
    p = R.part(pid)
    a = R.pv(pid)
    pad = union(capsule([a, tip], w, w * .45), ell(a[0], a[1], w / 2, w / 2))
    p.add(p.m(pad), AMB if pid == 'wingF' else FARA)
    p.line([(a[0] - 3, a[1] - 1), ((a[0] + tip[0]) / 2, (a[1] + tip[1]) / 2 - .5), (tip[0] + 3, tip[1])], AMB[3])
    crust(p, p.m(inter(pad, ell(tip[0] + 4, tip[1], 7, 6))), [[(tip[0] + 3, tip[1] - 2), (tip[0] + 5, tip[1] + 1)]])

# abdomen: fat barrel in sewn rings, clay caked on top, the ribbed drumskin (tymbal) on the front flank
p = R.part('abdo')
barrel = union(rell(33, 54, 29, 16, -6), ell(56, 54, 8, 11))
p.add(p.m(barrel), AMB)
for x in (11, 17, 23, 29, 35):                      # ring seams
    p.line([(x + 2, 41 + abs(x - 32) * .15), (x - 1, 55), (x + 1, 68 - abs(x - 32) * .12)], AMB[3])
crust(p, p.m(inter(barrel, union(rell(28, 41, 21, 6, -6), ell(14, 45, 6, 4), ell(38, 39, 6, 4)))),
      [[(14, 42), (18, 45), (21, 43)], [(30, 40), (32, 44)], [(40, 38), (43, 41)]])
drum = ell(43, 55, 6, 8)
p.add(p.m(drum), DRUM, local=True)
for y in (50, 53, 56, 59):
    p.line([(39, y), (47, y + 1)], DRUM[2])
p.line([(6, 58), (9, 55)], AMB[3])

# thorax: a tall hunched dome under a thick cracked clay crust
p = R.part('body')
dome = union(ell(66, 48, 17, 18), ell(64, 58, 13, 7))
p.add(p.m(dome), AMB, stitch=AMB[3])
cr = union(ell(66, 36, 17, 9), ell(55, 39, 5, 4), ell(77, 39, 5, 4))
crust(p, p.m(inter(dome, cr)), [[(56, 36), (60, 39), (59, 43)], [(69, 32), (71, 37), (76, 38)], [(64, 39), (65, 43)]])
p.line([(52, 55), (79, 55)], AMB[3])

# head: broad blunt head, striped clypeus bulge in front, beak tucked under
p = R.part('head')
skull = union(ell(86, 46, 14, 14), capsule([R.pv('head'), (82, 50)], 12, 12))
clyp = ell(98, 51, 7, 9.5)
p.add(p.m(skull), AMB)
p.add(p.m(clyp), AMB, local=True)
for k in range(5):
    p.line([(93, 44 + k * 3.4), (104, 45 + k * 3.4)], AMB[3])  # nymph face ridges
crust(p, p.m(inter(skull, union(ell(82, 34, 12, 5), ell(91, 34, 4, 3)))), [[(80, 33), (82, 36)], [(87, 33), (88, 35)]])
p.add(p.m(capsule([(94, 59), (88, 65)], 4, 2.4)), FARA, local=True)   # the sucking beak
p.add(p.m(ell(82, 53, 2, 1.3)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
ex, ey = R.pv('eyes')
p.add(p.m(ell(ex, ey, 3.4, 3.2)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey + .3, 2.5, 2.3)), (CREAM,) * 4, flat=True)
p.add(p.m(ell(ex + 1, ey + .8, 1.2, 1.3)), (INK,) * 4, flat=True)
p.add(p.m(inter(ell(ex, ey, 3.4, 3.2), lambda x, y: y < ey - .6)), (AMB[2],) * 4, flat=True)   # tired heavy lid
p.line([(ex - 4, ey - 1), (ex + 3, ey - 1.5)], INK)

for pid, tip in (('antL', (96, 28)), ('antR', (103, 33))):
    p = R.part(pid)
    a = R.pv(pid)
    p.add(p.m(capsule([a, tip], 2.6, 1.4)), FARA, local=True, crescent=0)
    p.px((a[0] + tip[0]) / 2 + 1, (a[1] + tip[1]) / 2, AMB[3])

R.save()
