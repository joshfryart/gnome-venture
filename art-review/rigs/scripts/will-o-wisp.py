#!/usr/bin/env python3
"""will-o-wisp "Will-o'-Wisp" (wisp rig, 45 x 70, 4 parts): "A floating light that leads gnomes astray." (wetland, night; Plant/Fungus)
Felt, not glass: a sea-mint flame (body) cut from flat felt with three licking tongues, a pale inner flame and a dashed stitch;
a cream-and-gold felt ball (core) in the middle carries the sly face; two button eyes looking sideways (eyes); the bog tussock it
rises from (base: moss mound, grass blades, a cattail and a tiny pink toadstool), drawn over the flame's foot as the rig orders it."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('will-o-wisp')
FLAME = ('#e8fbf2', '#7fc8b8', '#3f8fb0', '#25637d')
INNER = ('#ffffff', '#c8ecdc', '#a9dccb', '#7fc8b8')
BALL = ('#fffbe8', '#fff3c8', '#f5cf6a', '#e8a317')

p = R.part('body')
outer = union(ell(22.5, 41, 15.5, 17),
              capsule([(22.5, 34), (25, 20), (23, 11), (19, 4.5)], 15, 2.5),
              capsule([(13, 38), (8.5, 27), (8, 17)], 10, 2.5),
              capsule([(32, 37), (36.5, 25), (35.5, 14)], 10, 2.5))
p.add(p.m(outer), FLAME, stitch='#25637d')
inner = union(ell(22.5, 45, 10.5, 12), capsule([(22.5, 38), (24, 26), (21.5, 16)], 10, 2.5),
              capsule([(15, 42), (12.5, 33), (12, 27)], 5, 1.8), capsule([(30, 41), (32.5, 32), (32, 25)], 5, 1.8))
p.add(p.m(inner), INNER, flat=True)
p.edge(p.m(inner), FLAME[1])

p = R.part('core')
ball = ell(22.5, 44, 9.5, 9)
p.add(p.m(ball), BALL, stitch='#e8a317')
p.line([(20.5, 48.5), (21.5, 49.5), (23.5, 49.5), (24.5, 48.5)], INK)          # a sly little smile
p.px(16, 47, BLUSH); p.px(17, 47, BLUSH); p.px(28, 47, BLUSH); p.px(29, 47, BLUSH)

p = R.part('eyes')
for ex in (18.5, 26.5):
    p.add(p.m(ell(ex, 42.7, 2.4, 2.6)), (INK,) * 4, flat=True)
    p.px(int(ex) - 1, 41, CREAM)                                                  # glint, upper left
    p.px(int(ex), 41, '#4a2c1a')

p = R.part('base')
mound = ell(22.5, 62, 15, 6.4)
blades = union(capsule([(11, 61), (8, 53)], 2.6, 1.2), capsule([(15, 60), (14, 51.5)], 2.6, 1.2), capsule([(30, 60), (31.5, 52)], 2.6, 1.2),
               capsule([(35, 61), (38.5, 54)], 2.6, 1.2), capsule([(26, 59), (25.5, 54)], 2.4, 1.2))
p.add(p.m(blades), MOSS, local=True)
p.add(p.m(capsule([(39, 62), (40, 44)], 1.6, 1.6)), PINE, flat=True)              # cattail stalk
p.add(p.m(capsule([(40, 50), (40, 43.5)], 3.2, 3.2)), WOOD, local=True)            # cattail head
p.add(p.m(mound), PINE, stitch='#1f3d1c')
p.add(p.m(ell(9.5, 58.5, 3.2, 2.2)), PETAL, local=True)                            # toadstool cap
p.add(p.m(rect(9, 59.5, 11, 62)), PAPER, flat=True)                                # and stalk
p.px(8, 58, CREAM); p.px(11, 58, CREAM)
p.px(16, 63, MOSS[1]); p.px(24, 64, MOSS[1]); p.px(31, 63, MOSS[1])                # moss flecks

R.save()
