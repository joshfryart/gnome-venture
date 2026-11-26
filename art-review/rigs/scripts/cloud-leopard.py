#!/usr/bin/env python3
"""cloud-leopard "Cloud Leopard" (quad.feline rig, 89 x 51, 8 parts): "Walks the high ledges as if gnomes were a rumour." (mountain; Frost Fur, Spotted Pelt)
A clouded leopard in pale cream felt: a long low body (body) printed with the big dark-rimmed "cloud" blotches and a cream belly,
short thick legs with round paws (near legs cream, far legs a step darker), a very long thick tail curling up behind and ringed in
umber (tail, sprung), a round cat head with small round ears, cream muzzle, pink nose, cheek stripes and a calm green-gold eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('cloud-leopard')
COAT = ('#f2e4c0', '#e0c690', '#c9a96e', '#9a6b3f')   # tawny felt between surface-2 and line
FAR = darker(COAT)
RIM = '#4a2c1a'
MID = '#9a6b3f'


def cloud(p, cx, cy, rx, ry, clip):
    """a cloud blotch: dark felt rim, brown inside, clipped to the part"""
    out = p.m(inter(union(ell(cx, cy, rx, ry), ell(cx + rx * .6, cy - ry * .45, rx * .55, ry * .6)), clip))
    ins = p.m(inter(union(ell(cx, cy, rx - 1.2, ry - 1.1), ell(cx + rx * .6, cy - ry * .45, rx * .55 - 1, ry * .6 - 1)), clip))
    p.fill(out, RIM)
    p.fill(ins, MID)


def leg(pid, x, ramp, back):
    p = R.part(pid)
    px_, py_ = R.pv(pid)
    shape = capsule([(px_, py_ - 3), (x, 41.5)], 8 if back else 7, 6)
    paw = ell(x + 1.2, 43.4, 4.2, 2.7)
    p.add(p.m(shape, paw), ramp)
    p.line([(x + 1, 44.5), (x + 1, 45.5)], ramp[3]); p.line([(x + 3, 44.5), (x + 3, 45.5)], ramp[3])   # toe seams
    if ramp is COAT:
        p.px(x - 1, 36, RIM); p.px(x + 1, 38.5, RIM)        # leg spots
    return p


leg('legBF', 31.5, FAR, True)
leg('legFF', 60, FAR, False)

# tail: long, thick, curls up and back; umber rings
p = R.part('tail')
path = [(24, 24.5), (15, 27), (8, 23), (5.5, 15), (8.5, 7.5)]
tail = capsule(path, 7.5, 6)
p.add(p.m(tail), COAT)
for (a, b) in (((17, 23), (16, 31)), ((11, 21.5), (8.5, 29)), ((3, 18.5), (10, 17)), ((3, 13), (10, 12.5)), ((5, 8), (11, 10))):
    p.add(p.m(inter(capsule([a, b], 2.2), tail)), (RIM,) * 4, flat=True)
p.add(p.m(inter(ell(9, 6.5, 3.5, 3), tail)), (RIM,) * 4, flat=True)              # dark tail tip

# body: long and low, cream belly, cloud blotches, a stitched seam along the back
p = R.part('body')
torso = union(ell(30, 26.5, 12.5, 9.5), ell(52, 24.5, 12, 10.5), rect(30, 17.5, 52, 35))
p.add(p.m(torso), COAT, stitch=True)
belly = inter(torso, lambda x, y: y > 31.5)
p.add(p.m(belly), ('#fff3c8', '#fff3c8', '#f2e4c0', '#c9a96e'))
clip = torso
for cx, cy, rx, ry in ((24, 21.5, 4.2, 3), (34, 19.5, 4.6, 3), (45, 19, 4.4, 3), (55, 18.5, 3.8, 2.8),
                       (29.5, 28.5, 4, 2.6), (40, 26.5, 4.4, 2.8), (51, 28, 3.6, 2.5), (20.5, 29, 2.6, 2.2)):
    cloud(p, cx, cy, rx, ry, clip)

leg('legBN', 25.5, COAT, True)
leg('legFN', 55, COAT, False)

# head: round cat head with a neck, small round ears, cream muzzle, pink nose, cheek stripes
p = R.part('head')
hd = union(ell(66.5, 14.5, 10, 9), capsule([R.pv('head'), (63, 17)], 11, 11))
ears = union(ell(59.5, 7.2, 3.6, 3.4), ell(68.5, 5.4, 3.6, 3.4))
p.add(p.m(ears), COAT, local=True)
p.add(p.m(union(ell(59.5, 7.6, 1.7, 1.6), ell(68.5, 5.8, 1.7, 1.6))), (PETAL[2],) * 4, flat=True)
p.add(p.m(hd), COAT, stitch=None)
p.add(p.m(ell(74.5, 18.2, 4.4, 3.6)), ('#fff3c8', '#fff3c8', '#f2e4c0', '#c9a96e'))
p.add(p.m(ell(78, 16.2, 1.6, 1.2)), (PETAL[2], PETAL[2], PETAL[3], PETAL[3]), flat=True)
p.line([(78, 17.5), (77, 19.5), (75, 20.5)], RIM)                                   # mouth
p.line([(64, 16.5), (60, 18)], RIM); p.line([(65, 19), (61, 21.5)], RIM)          # cheek stripes
p.px(64, 10, RIM); p.px(66, 9.5, RIM); p.px(62, 12, RIM); p.px(65, 11.5, RIM)    # forehead spots
p.px(73, 20, CREAM); p.px(74, 21, PAPER[2])                                        # whisker dots

p = R.part('eyes')
p.add(p.m(ell(69, 15, 2.2, 1.9)), (INK,) * 4, flat=True)
p.add(p.m(rect(68, 14, 70, 16)), ('#a8c05a',) * 4, flat=True)
p.px(69, 14, INK); p.px(69, 15, INK)
p.px(68, 14, CREAM)

R.save()
