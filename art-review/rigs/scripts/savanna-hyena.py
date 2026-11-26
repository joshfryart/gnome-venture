#!/usr/bin/env python3
"""savanna-hyena "Savanna Hyena" (quad.canid rig, 69 x 46, 8 parts): "Laughs at you first. The rest of the pack laughs later." (grassland, lv 29; Spotted Hide, Fox Fang)
A spotted hyena in sandy felt with the hyena's sloping back: tall shoulders and a deep chest at the front, low small hindquarters,
an umber bristle mane sewn along the neck and back, dark round spots all over (body, legs). Long straight front legs, short bent hind legs.
A short tail with a bushy umber tip (tail, sprung up-left). A broad head with big round ears (pink inside), a dark blunt muzzle and an
open laughing grin with cream teeth; a small gold eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
from _quad_savanna_hyena import leg, eye_round

R = Rig('savanna-hyena')
SAND = ('#f2e4c0', '#d9b77a', '#b48a4e', '#7a5530')
FAR = darker(SAND)
SPOT = '#5a3a22'
MANE = ('#7a5530', '#5a3a22', '#4a2c1a', '#2a1a10')
MUZ = ('#7a5530', '#5a3a22', '#4a2c1a', '#2a1a10')
BELLY = ('#fff3c8', '#f2e4c0', '#d9b77a', '#b48a4e')


def spots(p, pts, clip, r=1.4):
    for x, y in pts:
        p.fill(p.m(inter(ell(x, y, r, r * .9), clip)), SPOT)


# far legs (under the body): front long and straight, hind short with a bent hock
leg(R, 'legBF', 26.5, FAR, 6.5, 4.5, knee=(28.5, 34.5), paw=(3.2, 2.2))
leg(R, 'legFF', 46.5, FAR, 6, 4.5, paw=(3.2, 2.2))

# tail: short, leaves the rump up-left, bushy dark tip
p = R.part('tail')
p.add(p.m(capsule([(19.5, 21), (14, 18.5), (10.5, 15.5)], 4, 3)), SAND)
p.add(p.m(union(ell(9.5, 14.5, 3.4, 3), ell(11.5, 13.2, 2.4, 2.2))), MANE)

# body: deep chest high at the front, back sloping down to a small low rump; cream belly, mane, spots
p = R.part('body')
torso = union(ell(23.5, 24, 7.5, 6.5), ell(40, 21, 10, 10), poly([(18, 20), (33, 12), (45, 13), (45, 30), (21, 29.5)]))
mpath = [(20, 18.5), (31, 13.5), (40, 10.5), (46, 11)]
tufts = union(*[ell(x, y - 1.3, 2.2, 2) for x, y in ((24, 16.2), (28, 14.6), (32, 13), (36, 11.6), (40, 10.4), (44, 10.4))])
p.add(p.m(torso, tufts), SAND, stitch=True)
p.add(p.m(inter(torso, lambda x, y: y > 28 - (x - 20) * .02, lambda x, y: x > 24)), BELLY)
mane = union(inter(capsule(mpath, 3.4, 4.2), torso), tufts)
p.add(p.m(mane), MANE, local=True)
spots(p, [(22, 22), (26.5, 24.5), (30, 20), (33.5, 24), (36, 18.5), (40, 22.5), (43.5, 19), (27.5, 19.8), (31, 27), (38, 27)], minus(torso, capsule(mpath, 4.6, 5.4)))

# near legs (over the body): thigh pads sewn onto the body
p, m = leg(R, 'legBN', 22, SAND, 7, 4.8, knee=(24.5, 34.5), paw=(3.4, 2.4))
spots(p, [(20.5, 29), (24, 33)], lambda x, y: (int(x), int(y)) in m, 1.2)
p.edge(m, SAND[3], sides=((0, -1),))
p, m = leg(R, 'legFN', 42, SAND, 6.5, 5, paw=(3.4, 2.4))
spots(p, [(41, 32), (42.5, 36)], lambda x, y: (int(x), int(y)) in m, 1.1)

# head: neck, broad skull, big round ears, dark blunt muzzle, open laughing grin
p = R.part('head')
ears = union(ell(48, 6.5, 4.2, 4.6), ell(55.5, 5.4, 4.2, 4.6))
p.add(p.m(ears), MANE, local=True)
p.add(p.m(union(ell(48.2, 7, 2.6, 3), ell(55.6, 5.9, 2.6, 3))), (SAND[1], SAND[1], SAND[2], SAND[2]), flat=True)
p.add(p.m(union(ell(48.4, 7.6, 1.2, 1.6), ell(55.8, 6.5, 1.2, 1.6))), (PETAL[2],) * 4, flat=True)
skull = union(ell(52.5, 13, 7.5, 6.5), capsule([R.pv('head'), (50, 14)], 9, 9))
snout = poly([(55, 9.5), (63, 12), (66, 14.5), (66, 18), (60, 21), (53, 20)])
p.add(p.m(skull, snout), SAND)
p.add(p.m(inter(snout, lambda x, y: x > 58.5)), MUZ)
p.add(p.m(ell(65, 13.8, 1.7, 1.3)), (INK,) * 4, flat=True)                        # nose button
p.line([(65.5, 17), (60.5, 17.5), (56, 15.5)], INK)                                # laughing mouth, corner turned up
for x in (58, 60, 62, 64):
    p.px(x, 18, CREAM)                                                             # teeth
p.line([(57, 18.5), (62, 19.5)], PETAL[2])                                         # tongue
spots(p, [(48, 13), (51, 17.5)], skull, 1.1)
p.add(p.m(rell(54.3, 13, 3.4, 2.6, 20)), (MUZ[0],) * 4, flat=True)             # dark eye patch
p.add(p.m(ell(51.5, 9, 4, 1.2)), (MANE[1],) * 4, flat=True)                       # mane runs up the crown

p = R.part('eyes')
p.add(p.m(ell(53.6, 12.6, 1.9, 1.8)), (INK,) * 4, flat=True)                     # a dark button eye
p.px(53, 11, CREAM); p.px(55, 13, '#e8a317')

R.save()
