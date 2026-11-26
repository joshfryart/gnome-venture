#!/usr/bin/env python3
"""bramble-wolf "Bramble Wolf" (quad.canid rig, 95 x 58, 8 parts): "Woven from thorny vines, it hunts by the smell of fresh soil."
(large, forest, L22; drops Bramble Pelt, Thorn Fang; Howl)
A lean, long-legged wolf sewn from bramble canes: wine-red felt twisted into rope bands (pale-edged wrap seams) over a deep chest,
tucked waist and high hackled shoulders, a crest of hooked cream thorns down the spine, a ruff of green bramble leaves at the
neck and two red berries (body). Legs as twisted canes, hind legs with a proper wolf hock, cream thorn claws (legs, far pair one
step darker). A raised, hooked whip of a tail with thorns and a leaf tuft at the end (tail, sprung). A long wolf head with tall
pointed ears lined in leaf green, a pale muzzle, a black nose and a snarl of cream thorn fangs (head); one amber eye under a heavy
brow (eyes). The tallest, spikiest silhouette of the batch."""
import importlib.util, os, sys
_s = importlib.util.spec_from_file_location('qb', os.path.join(os.path.dirname(os.path.abspath(__file__)), '_quad_bramble-wolf.py'))
Q = importlib.util.module_from_spec(_s); _s.loader.exec_module(Q)
from rigkit import *  # noqa

R = Rig('bramble-wolf')
CANE = ('#c0705a', '#8e3e3e', '#6a2a34', '#45192a')
FARC = darker(CANE)
WRAP = '#b8605a'
LEAF = ('#a8d070', '#6aa048', '#3f7436', '#244a22')
THORN = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')
MUZ = ('#f2e4c0', '#d8b89a', '#b08070', '#6a2a34')
BERRY = ('#f08a4a', '#dd3a2a', '#a8241f', '#6e2038')
g = R.ground


def thorns(p, pts, hs, lean=-1.0, ramp=THORN):
    """hooked thorns: a broad base on the skin, the tip raked back"""
    for (x, y), h in zip(pts, hs):
        p.add(p.m(poly([(x - 3, y + 1.5), (x - 1.6, y - h * .45), (x + lean * h * .45, y - h), (x + .6, y - h * .45), (x + 3, y + 1.5)])), ramp, local=True, crescent=1)


def leaf(p, x, y, L, deg, ramp=LEAF):
    m = p.add(p.m(rell(x, y, L, L * .45, deg)), ramp, local=True, crescent=1)
    import math
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    p.line([(x - c * L * .6, y - s * L * .6), (x + c * L * .5, y + s * L * .5)], ramp[2])
    return m


def cane_leg(pid, pts, w0, w1, paw, ramp, against=()):
    p, m = Q.limb(R, pid, pts, w0, w1, ramp, paw=paw)
    for k in range(2):                                            # twisted-cane wrap: diagonal seams down the leg
        Q.strand(p, m, [(pts[0][0] - 4, pts[0][1] + 5 + k * 9), (pts[0][0] + 4, pts[0][1] + 8 + k * 9)], ramp[2], 1)
    Q.claws(p, (int(paw[0] + paw[1] - 1), int(paw[0] + paw[1] - 3)), g, THORN[1])
    if against:
        Q.seam(p, R, m, against, ramp[3])
    return p, m


# far legs (behind the body)
cane_leg('legBF', [(36, 30), (38.5, 40), (34, 46.5), (35, 50)], 7, 3.6, (36.3, 3.2, 2), FARC)
cane_leg('legFF', [(61.2, 30), (62.3, 44), (63, 50)], 5.5, 3.8, (64.3, 3.1, 2), FARC)

# tail: a raised whip of braided cane, hooking forward at the end, thorns on the outer curve, a tuft of leaves on the tip
p = R.part('tail')
path = [(28.5, 27.5), (22, 24), (16.5, 18.5), (14, 12.5), (16, 8)]
tm = p.add(p.m(capsule(path, 7, 5), Q.fluff(path[1:4], 3.4, 2.6)), CANE)
Q.strand(p, tm, [(27, 25.5), (20.5, 22), (16, 16.5), (15, 11)], CANE[2], 1)          # the cane twisting along the brush
for a, b in (((23, 21.5), (21.5, 27)), ((17, 15.5), (12.5, 19.5))):
    Q.strand(p, tm, [a, b], CANE[3], 1)
thorns(p, [(20, 19), (15.5, 13.5), (25.5, 22.5)], [5, 4.5, 4], lean=-1.4)
for x, y, d in ((16, 6.5, -70), (19.5, 8, -15), (12.8, 8, -120)):
    leaf(p, x, y, 3.4, d)

# body: deep chest, tucked waist, high hackled shoulders; rope bands, spine thorns, leaf ruff, berries
p = R.part('body')
torso = union(ell(32.5, 28, 8, 7.5), ell(45, 26.5, 13, 6.2), ell(58.5, 25.5, 9.8, 11),
              poly([(30, 21), (44, 20.5), (54, 15.5), (61, 14.5), (66, 22), (64, 36.5), (55, 37), (45, 32), (34, 34.5)]))
thorns(p, [(30.5, 22), (37, 21), (43.5, 21), (49.5, 19.5), (54.5, 16.5), (59, 15)], [5, 5.5, 5.5, 6, 7.5, 8])
bm = p.add(p.m(torso), CANE)
Q.strand(p, bm, [(27, 26), (36, 24.5), (46, 25), (54, 21.5), (62, 19)], CANE[2], 1.2)   # canes running along the flank
Q.strand(p, bm, [(30, 32), (40, 30), (50, 31), (58, 29), (64, 30)], CANE[2], 1.2)
for a, b in (((35, 21.5), (31.5, 33.5)), ((47.5, 21), (43.5, 32)), ((58, 15.5), (55, 35.5))):
    Q.strand(p, bm, [a, (a[0] - 1, (a[1] + b[1]) / 2), b], CANE[3], 1.1, hi=WRAP, side=(-1, 0))   # binding wraps
p.add(p.m(inter(torso, lambda x, y: y > 31.5 and 40 < x < 60)), (CANE[2], CANE[2], CANE[3], CANE[3]), local=True)   # dark tucked belly
for x, y, d in ((62.5, 17.5, -70), (66, 21.5, -30), (66.5, 26.5, 10), (65, 31, 40), (62, 34.5, 70), (59.5, 20, -100), (63, 24.5, -10)):
    leaf(p, x, y, 3.6, d)                                                    # the leafy ruff at the neck and chest
for cx, cy in ((47.5, 25.5), (38, 28.5)):
    p.add(p.m(ell(cx, cy, 1.8, 1.8)), BERRY, local=True, crescent=1); p.px(cx - 1, cy - 1, BERRY[0])

# near legs (over the body)
cane_leg('legBN', [(30.6, 30), (33.5, 40), (28.5, 46.5), (29.5, 50)], 8, 4, (30.8, 3.4, 2.1), CANE, against=('legBF', 'body'))
cane_leg('legFN', [(56.1, 30), (57, 44), (57.8, 50)], 6.2, 4.2, (59.2, 3.3, 2.1), CANE, against=('legFF', 'body'))

# head: long wolf head, tall pointed ears lined in leaf, pale muzzle, snarl of thorn fangs
p = R.part('head')
skull = ell(70, 16.5, 7, 6.3)
snout = poly([(72, 11.5), (79, 13.5), (85.5, 15.5), (87, 17.5), (85.5, 20.5), (77, 21.5), (70, 22)])
jaw = poly([(71, 21), (83, 20.5), (82, 23.5), (75, 25), (69, 24.5)])
neck = capsule([R.pv('head'), (67, 18)], 11, 11)
ears = union(poly([(63, 12.5), (64, 3.5), (69.5, 10)]), poly([(67.5, 10.5), (71.5, 3.5), (74, 12)]))
p.add(p.m(ears), CANE, local=True)
p.add(p.m(union(poly([(64.5, 10.5), (65, 5.5), (68, 10)]), poly([(69.5, 10.5), (71.5, 5.5), (72.5, 11)]))), LEAF, flat=True)
hm = p.add(p.m(skull, snout, neck, jaw), CANE)
p.add(p.m(inter(union(snout, jaw), below((70, 19.5), (88, 18), 0))), MUZ)          # pale muzzle and jaw
p.add(p.m(inter(snout, lambda x, y: x > 78, minus(lambda x, y: True, below((70, 19.5), (88, 18), 0)))), (CANE[0], CANE[1], CANE[2], CANE[3]), local=True)
Q.strand(p, hm, [(64, 15), (61, 23)], CANE[3], 1, hi=WRAP, side=(-1, 0))
p.add(p.m(ell(85.8, 16.4, 1.7, 1.4)), (INK,) * 4, flat=True); p.px(85, 15, '#6a5648')   # nose
p.line([(86, 20), (80, 21), (74.5, 22)], INK)                                       # the snarl
for x in (79, 82):
    p.px(x, 21, THORN[0]); p.px(x, 22, THORN[1])                                   # upper thorn fangs
p.px(76, 21, THORN[0]); p.px(84, 20, THORN[0])
p.line([(67, 12.5), (74, 14)], CANE[3])                                            # heavy brow

p = R.part('eyes')
Q.bead(p, 71.2, 17.2, r=1.3, iris='#f5cf6a')

R.save()
