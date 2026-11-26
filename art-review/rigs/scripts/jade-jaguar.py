#!/usr/bin/env python3
"""jade-jaguar "Jade Jaguar Spirit" (quad.feline rig, 121 x 65, 8 parts, boss): "A spirit of the deep jungle with eyes like polished jade." (rainforest, lv 32; Spotted Pelt, Jade Eye; Spirit Pounce)
A boss jaguar sewn from jade-green felt: stocky and heavy, a deep chest under a high shoulder hump, short thick legs on wide paws,
the jaguar's rosettes (dark pine rings round a deeper-jade middle with a centre dot) all over, a pale mint belly. A long tail that
rises behind and curls over at the tip (tail, sprung up-left), ringed in pine with a gold-thread band. A massive square head with
round ears, a broad pale muzzle and heavy jaw, a gold-thread spirit mark on the brow, and a big glowing jade eye with a slit pupil
(eyes). Green and spotted where the tiger is orange and striped; heavier and bigger-headed than the cloud-leopard."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
from _quad_savanna_hyena import leg, eye_round

R = Rig('jade-jaguar')
JADE = ('#9fdcb4', '#5fb08a', '#3f8a68', '#245a44')
FAR = darker(JADE)
RIM = '#173a2c'
MID = '#3f8a68'
BELLY = ('#e8fbf2', '#c8ecdc', '#9fdcb4', '#5fb08a')
GLD = '#f5cf6a'


def rosette(p, cx, cy, r, clip, dot=True):
    """a jaguar rosette: a broken dark ring (4 felt petals) round a deeper-jade middle with a centre dot"""
    import math
    k = int(cx * 7 + cy * 3) % 4
    ry = r * .82
    gap = lambda x, y: any(abs(math.atan2(y - cy, x - cx) - a) < .38 for a in (math.radians(100 + k * 25), math.radians(-30 - k * 20)))
    p.fill(p.m(inter(ell(cx, cy, r - .6, ry - .6), clip)), MID)
    p.fill(p.m(inter(minus(ell(cx, cy, r, ry), ell(cx, cy, r - 1.5, ry - 1.4), gap), clip)), RIM)
    if dot and r > 3.5:
        p.fill(p.m(inter(rect(int(cx), int(cy), int(cx) + 2, int(cy) + 1), clip)), RIM)


def jleg(pid, x, ramp, back):
    p, m = leg(R, pid, x, ramp, 13 if back else 12, 9.5, knee=(x + 2.5, 52) if back else None, paw=(6.4, 3.6))
    px_, py_ = R.pv(pid)
    rosette(p, x - 1, py_ + 6, 2.6, lambda X, Y: (int(X), int(Y)) in m, False)
    rosette(p, x + 2, py_ + 11, 2.2, lambda X, Y: (int(X), int(Y)) in m, False)
    return p, m


jleg('legBF', 44, FAR, True)
jleg('legFF', 83.5, FAR, False)

# tail: rises behind and curls over at the tip, pine rings, one gold-thread band
p = R.part('tail')
path = [(31, 30), (21, 32), (11, 28), (6.5, 19), (9, 9.5), (15, 6.5), (18, 10)]
tail = capsule(path, 9, 6)
p.add(p.m(tail), JADE)
for a, b in (((20, 27), (20, 37)), ((10, 23), (4, 30)), ((2, 17), (11, 17)), ((5, 8), (12, 12))):
    p.add(p.m(inter(capsule([a, b], 2.4), tail)), (RIM,) * 4, flat=True)
p.add(p.m(inter(capsule([(14, 22), (6, 25)], 1.4), tail)), (GLD,) * 4, flat=True)

# body: heavy, arched over a shoulder hump, mint belly, rosettes, a sewn seam
p = R.part('body')
torso = union(ell(43, 33.5, 15, 11), ell(72, 31, 16.5, 13.5), rect(43, 22, 72, 45))
p.add(p.m(torso), JADE, stitch=True)
p.add(p.m(inter(torso, lambda x, y: y > 40.5)), BELLY)
for cx, cy, r in ((34, 27, 3.4), (44, 24.5, 4), (55, 23, 4.2), (66, 22, 4), (77, 23, 3.6), (39, 35, 3.8), (50, 32, 4.2),
                  (61, 31.5, 4.2), (72, 31, 3.8), (31.5, 34.5, 2.6), (56, 39.5, 2.8), (46, 40.5, 2.4), (83, 30, 2.6)):
    rosette(p, cx, cy, r, torso)
p.line([(70, 26), (73, 24.5), (75.5, 26), (74, 28.5), (72, 28)], GLD)                   # a gold-thread spirit swirl on the shoulder

# near legs
jleg('legBN', 37, JADE, True)
jleg('legFN', 76.5, JADE, False)

# head: massive and square, round ears, broad pale muzzle and heavy jaw, gold spirit mark on the brow
p = R.part('head')
ears = union(ell(81.5, 9.5, 4.8, 4.6), ell(94, 7.5, 4.8, 4.6))
p.add(p.m(ears), JADE, local=True)
p.add(p.m(union(ell(81.8, 10.2, 2.4, 2.3), ell(94.3, 8.2, 2.4, 2.3))), (RIM,) * 4, flat=True)
skull = union(ell(90, 20.5, 13.5, 12), capsule([R.pv('head'), (86, 25)], 17, 17), ell(97, 27.5, 9, 6))
p.add(p.m(skull), JADE)
p.add(p.m(ell(102, 25.5, 5.6, 4.4)), BELLY)                                       # muzzle
p.add(p.m(ell(98.5, 30.5, 5, 2.6)), BELLY)                                          # chin / heavy jaw
p.add(p.m(ell(105.8, 22.3, 2, 1.6)), (PETAL[2], PETAL[2], PETAL[3], PETAL[3]), flat=True)
p.line([(106, 24), (104.5, 27.5), (100, 28.5)], RIM)                              # mouth
p.px(101, 30, CREAM); p.px(104, 29.5, CREAM)                                      # fang tips
for x, y in ((80, 17), (82, 21), (79, 22), (84, 26), (86, 14), (88, 28)):
    p.fill(p.m(ell(x + .5, y + .5, 1, .9)), RIM)                                  # small head spots
p.fill(p.m(poly([(90, 8.5), (92, 11), (90, 13.5), (88, 11)])), GLD)               # gold-thread spirit mark
p.px(90, 11, RIM)
p.line([(87, 15.5), (89, 14.5)], GLD); p.line([(91, 14.5), (93, 15.5)], GLD)
p.px(99, 24, RIM); p.px(101, 23, RIM); p.px(100, 26, RIM)                       # whisker dots

p = R.part('eyes')
p.add(p.m(ell(93.7, 17.8, 4, 3.4)), (INK,) * 4, flat=True)
p.add(p.m(ell(93.7, 17.8, 3.1, 2.5)), ('#b8ffe0',) * 4, flat=True)
p.add(p.m(inter(ell(93.7, 17.8, 3.1, 2.5), lambda x, y: y > 18.6)), ('#5fe0a8',) * 4, flat=True)
p.line([(94, 15.5), (94, 19.5)], INK)                                             # slit pupil
p.px(92, 16, '#ffffff')

R.save()
