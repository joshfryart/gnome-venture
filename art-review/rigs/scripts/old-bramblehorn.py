#!/usr/bin/env python3
"""old-bramblehorn "Old Bramblehorn" (quad.ungulate rig, 111 x 92, 8 parts; boss; forest; L30; Antler Shard, Elder Pelt; Horn Gore,
Bramble Mantle, Ancient Root, Antler Wall)  "A great stag crowned with living branches."
An ancient thicket stag in deep chestnut felt with a pale tawny belly: a heavy, high-shouldered body draped in a mossy mantle that
hangs in scallops over the shoulders, with a bramble cane looped across it (red thorns, blackberries) and fern sprouts growing from
the moss (body); long deer legs with knees and backward hocks, dark cloven hooves, far legs a step darker (legs); a short pale flag
of a tail (tail); a long noble deer head on a thick neck with a shaggy moss-grey elder beard, a leaf-shaped ear, and the signature:
a huge crown of bramble-cane antlers, near and far, each beam forking into tines, studded with red thorns, leaves and blackberries
(head); an amber eye under a heavy old brow (eyes). The biggest, tallest, most branching silhouette of the batch."""
import importlib.util, os, sys
_d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_d, '..'))
from rigkit import *  # noqa
_s = importlib.util.spec_from_file_location('kb', os.path.join(_d, '_quad_wild-boar.py'))
K = importlib.util.module_from_spec(_s); _s.loader.exec_module(K)

R = Rig('old-bramblehorn')
COAT = ('#d8a070', '#a8643a', '#7a4428', '#4e2a1c')
FAR = darker(COAT)
BELLY = ('#f6e2b8', '#dcb880', '#b88c58', '#7a5a3a')
MOSSY = ('#c8d09f', '#7ab55c', '#4f8a3e', '#2f5a2a')
BEARD = ('#e4ead0', '#b4c09a', '#7f9070', '#4f5f48')
CANE = WOOD
FARCANE = darker(WOOD)
HOOF = ('#6a5648', '#4a3a32', '#2e221c', '#2a1a10')
THORN = EMBER[2]
BERRY = ('#8a72c8', '#4e3a8a', '#2e2050', '#1a1030')
G = R.ground + 1
P = R.pv


def leg(pid, path, w0, w1, ramp, thigh=None):
    """a long deer leg along path (pivot first, the hoof last), a dark cloven hoof on the ground row"""
    p = R.part(pid)
    fx = path[-1][0]
    shape = capsule(path + [(fx, G - 5)], w0, w1)
    if thigh:
        shape = union(shape, thigh)
    hoof = union(rect(fx - 3, G - 4, fx + 4, G), ell(fx + .5, G - 4, 3.5, 1.5))
    m = p.m(inter(union(shape, hoof), lambda x, y: y < G))
    p.add(m, ramp)
    p.add(p.m(inter(hoof, lambda x, y: y < G and y > G - 5)), HOOF, local=True)
    p.px(fx + 3, G - 1, INK); p.px(fx + 3, G - 2, INK)                                            # the cloven split
    p.edge({q for q in m if q[1] < P(pid)[1] + 3}, ramp[3], sides=((-1, 0), (1, 0)))
    return p, m


def berries(p, x, y):
    for dx, dy in ((0, 0), (1.5, 1), (-.5, 1.6)):
        p.add(p.m(ell(x + dx, y + dy, 1.2, 1.2)), BERRY, local=True)
    p.px(x - .5, y - .5, BERRY[0])


def antler(p, beam, tines, ramp, w0=5.4):
    """a bramble-cane antler: a tapering beam with forked tines, red hooked thorns along it, bone-pale tips"""
    m = p.m(capsule(beam, w0, 2.4), *[capsule(t, 3.2, 1.6) for t in tines])
    p.add(m, ramp, local=True)
    for a, b in zip(beam, beam[1:]):
        for t in (.35, .8):
            x, y = a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t
            p.px(x + w0 / 2 - .5, y, THORN); p.px(x + w0 / 2 + .5, y - 1, THORN)                 # thorn hooks on the front edge
    for t in tines + [beam]:
        p.px(t[-1][0], t[-1][1] + .3, PAPER[0])                                                   # pale tips
    return m


# far legs
leg('legBF', [P('legBF'), (41.5, 70), (35.5, 78), (37.5, 85)], 7, 3.8, FAR)
leg('legFF', [P('legFF'), (76, 75), (75.5, 85)], 7, 3.8, FAR)

# tail: a short pale flag up and back
p = R.part('tail')
p.add(p.m(rell(23.5, 47, 4.6, 3, -30)), COAT, local=True)
p.add(p.m(inter(rell(23.5, 47, 4.6, 3, -30), below((19, 46), (28, 51), -.5))), BELLY, local=True)

# body: heavy chest, high shoulders, tucked flank; pale belly; mossy mantle with scallops, fern sprouts, a bramble cane with berries
p = R.part('body')
torso = union(ell(37, 51, 14, 13), ell(65, 49.5, 15, 16.5), poly([(26, 43), (52, 36.5), (70, 33.5), (80, 58), (74, 65), (60, 64), (44, 63.5), (29, 64), (24, 55)]))
p.add(p.m(torso), COAT)
p.add(p.m(inter(torso, lambda x, y: y > 60 - (x - 30) * .04, lambda x, y: 37 < x < 74)), BELLY, local=True)
mant = inter(torso, union(lambda x, y: y < 43 + (x - 30) * .04,
                          *[ell(x, 43.5 + (x - 30) * .04, 2.4, 4) for x in range(25, 82, 5)]))
fern = union(*[capsule([(x, 39 - (x - 30) * .06), (x + 2, 33 - h)], 2.2, 1.2) for x, h in ((36, 0), (45, 2), (57, 1))])
p.add(p.m(fern), MOSSY, local=True)
mm = p.add(p.m(mant), MOSSY, local=True)
for x, h in ((36, 0), (45, 2), (57, 1)):
    p.px(x + 1.5, 34 - h, MOSSY[0]); p.px(x + .5, 36 - h, MOSSY[2])
for (x, y) in mm:
    if (x * 3 + y * 5) % 11 == 0:
        p.px(x, y, MOSSY[0])
    elif (x * 7 + y * 2) % 13 == 0:
        p.px(x, y, MOSSY[2])
cane = [(30, 47), (40, 44), (50, 46.5), (60, 44), (70, 47)]
p.line(cane, CANE[2]); p.line([(x, y - 1) for x, y in cane], CANE[1])
for x, y in cane[1:]:
    p.px(x - 2, y - 2, THORN)
berries(p, 45, 48); berries(p, 64, 47.5)
p.line([(56, 52), (58, 57)], COAT[2]); p.line([(42, 52), (43, 56)], COAT[2])                        # felt seams on ribs

# near legs: big haunch, backward hock; straight foreleg with a knee
th = rell(32.5, 64, 7.5, 9, -15)
leg('legBN', [P('legBN'), (35, 70), (28.5, 78), (30.5, 85)], 7.5, 4, COAT, thigh=th)
leg('legFN', [P('legFN'), (69.5, 75), (68.5, 85)], 8, 4.2, COAT)

# head: thick neck, elder beard, long deer head, leaf ear, the bramble crown
p = R.part('head')
antler(p, [(91.5, 28), (94.5, 21), (98, 13), (100.5, 4.5)], [[(95.5, 17.5), (103.5, 13.5)], [(98.5, 10), (106.5, 6)], [(93, 23.5), (100, 22)], [(97, 12), (93.5, 5)]], FARCANE, 4.6)
ear = rell(78.5, 29.5, 6.5, 2.6, 25)
p.add(p.m(ear), COAT, local=True)
p.add(p.m(rell(78.8, 29.6, 4.2, 1.1, 25)), BELLY, flat=True)
neck = capsule([(73, 50), (79, 41), (85, 35)], 20, 13)
skull = ell(87, 33.5, 7.5, 6.5)
snout = capsule([(89, 35), (103, 40)], 11, 8)
beard = union(ell(85, 42, 6.5, 3.5), *[poly([(x - 2.4, y - 4), (x + .5, y + 4.5), (x + 2.6, y - 4)]) for x, y in ((79.5, 47.5), (83, 47), (86.5, 46.5), (90, 45))])
p.add(p.m(neck, skull, snout), COAT)
p.add(p.m(beard), BEARD)
for x, y in ((81, 46.5), (84.5, 46), (88, 45)):
    p.line([(x, y - 4), (x + .5, y)], BEARD[2])
p.add(p.m(inter(snout, ell(101, 40.5, 5, 3.2))), BELLY, local=True)                                 # pale muzzle
p.add(p.m(ell(104.2, 38.2, 2, 1.8)), (UMBER2, INK, INK, INK), local=True)                           # nose
p.line([(104, 42), (98, 42.5)], INK)                                                                # mouth
p.line([(83, 31), (88, 31.5), (91, 33)], COAT[3])                                                  # heavy old brow
p.line([(92.5, 37), (96, 38)], COAT[2])
nm = antler(p, [(85, 29), (83, 21), (80, 13), (77.5, 4.5)], [[(82.5, 19), (90.5, 14)], [(80, 11), (86.5, 4.5)], [(78.5, 8), (70.5, 3.5)], [(84.5, 26.5), (91.5, 24)], [(81.5, 16.5), (74, 14)]], CANE)
for x, y in ((87.5, 15), (71.5, 4), (98.5, 25), (104.5, 12.5)):
    p.add(p.m(rell(x, y, 3.4, 1.8, -30), rell(x - 1.5, y + 1.8, 2.6, 1.4, 25)), MOSSY, local=True); p.px(x, y, MOSSY[3])                   # living leaves
berries(p, 89, 8); berries(p, 76.5, 17.5); berries(p, 102.5, 17)

p = R.part('eyes')
K.eye_dot(p, 87.6, 36.6, r=1.5, iris=GOLD[1])

R.save()
