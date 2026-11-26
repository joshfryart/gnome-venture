#!/usr/bin/env python3
"""echo-bat "Echo Bat" (bird rig, medium, 59 x 50, 7 parts): "A small brown bat that calls out and listens for the answer. Its answer comes
back a little too late, as if from further down." (Trek chapter III caves; lv 22; Bat Down)
A small felt brown bat perched upright on its hind feet, one wing half raised: a round brown fur body with a pale tan belly patch and
stitched fur tufts (body), a big leathery membrane wing raised up and back from the shoulder, tan finger bones fanning from the wrist
with a hooked thumb claw and a scalloped trailing edge (wing, +r lifts it), a little tail membrane peeking out behind (tail), short
dark hind legs with hooked toes (legB darker behind, legF in front), a pug head with two huge listening ears (pink felt inside), a
leaf nose and an open calling mouth with two tiny fangs (head), and round shiny button eyes (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('echo-bat')
FUR = ('#d0a878', '#9a6b3f', '#74462a', '#4a2c1a')
TAN = ('#f2dcb0', '#e0c090', '#c49a68', '#9a6b3f')
SKIN = ('#a88070', '#7a564c', '#573a34', '#3a2420')
BONE = '#d8b890'
EAR = ('#fde0ea', '#f6b8cf', '#e46a9b', '#a8346a')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    xi = int(x)
    p.add(p.m(capsule([(x, y), (xi + .5, G - 2)], 2.2, 1.6)), ramp, flat=True)
    p.add(p.m(capsule([(xi - 1, G - .5), (xi + 3, G - .5)], 2)), ramp, flat=True)
    for cx in (xi - 2, xi + 1, xi + 3):                                                       # hooked toes
        p.px(cx, G, INK)


leg('legB', darker(SKIN))
leg('legF', SKIN)

# tail: the little tail membrane peeking out behind the rump
p = R.part('tail')
p.add(p.m(poly([(25.5, 29), (19, 33), (16.5, 38.5), (20, 37), (23, 39.5), (27, 36)])), SKIN, local=True, crescent=1)
p.line([(24, 31), (18, 37.5)], BONE)

# wing: big membrane raised up and back, finger bones from the wrist
p = R.part('wing')
SH, WR = R.pv('wing'), (18, 9)
tips = [(3.5, 5), (2.5, 17), (6, 28), (15, 35)]
mem = poly([SH, WR, tips[0], (8, 11.5), tips[1], (9.5, 22), tips[2], (13.5, 28.5), tips[3], (20, 31.5), (27, 33.5), (29.5, 27)])
p.add(p.m(mem), SKIN, stitch=None)
p.add(p.m(capsule([SH, WR], 3, 2.2)), FUR, local=True, crescent=1)                         # furry forearm
for t in tips:
    p.line([WR, t], BONE)                                                                     # finger bones
p.line([(22, 27), (14, 34)], SKIN[3])
p.add(p.m(capsule([(18, 8.5), (16.5, 5.5)], 2, 1.2)), FUR, flat=True)                      # thumb
p.px(17, 5, INK); p.px(18, 5, INK)                                                          # its hooked claw
for (x, y) in ((10, 14), (11, 22), (17, 27), (21, 18)):                                      # felt crease seams
    p.px(x, y, SKIN[3]); p.px(x + 1, y + 1, SKIN[3])

# body: round fur body, tan belly patch, tufts
p = R.part('body')
bod = union(ell(29.5, 30, 8, 9.5), ell(31, 23.5, 6, 4.5))
p.add(p.m(bod), FUR, stitch=FUR[3])
p.add(p.m(inter(bod, ell(33.5, 31.5, 4.2, 6.5))), TAN)
for (x, y) in ((24, 28), (26, 34), (30, 37), (35, 27)):
    p.line([(x, y), (x + 1, y + 1)], FUR[2] if x < 33 else TAN[2])

# head: pug face, huge ears, leaf nose, open calling mouth
p = R.part('head')
skull = union(ell(36, 16.5, 6.5, 6), capsule([R.pv('head'), (34, 19)], 7, 7))
earB = poly([(30.5, 15), (29, 9), (29.5, 3), (33.5, 8), (34.5, 13)])
earF = poly([(35.5, 13), (37.5, 6), (40.5, 2), (41.5, 8), (40.5, 14)])
p.add(p.m(earB), darker(FUR), local=True)
p.add(p.m(inter(earB, poly([(31, 13), (30.5, 6.5), (33, 9.5), (33.5, 13)]))), darker(EAR), flat=True)
p.add(p.m(skull), FUR)
p.add(p.m(earF), FUR, local=True)
p.add(p.m(inter(earF, poly([(37, 12.5), (38.5, 7), (40.3, 4.5), (40.5, 9), (39.5, 13)]))), EAR, flat=True)
p.add(p.m(ell(40.8, 19, 2.8, 2.6)), TAN, local=True, crescent=1)                           # pug muzzle
p.add(p.m(ell(42.6, 16.8, 1.3, 1.9)), EAR, flat=True)                                       # leaf nose
p.add(p.m(poly([(39, 20.5), (43, 20), (42, 23.2), (39.5, 22.8)])), ('#6e2038',) * 4, flat=True)   # open calling mouth
p.px(41, 20, CREAM); p.px(39, 21, CREAM)                                                    # tiny fangs
p.line([(31, 19), (33, 21)], FUR[2])

# eyes: round button eyes with a glint
p = R.part('eyes')
ex, ey = 37, 16
p.add(p.m(ell(ex + .5, ey + .5, 2.6, 2.6)), (CREAM,) * 4, flat=True)
p.add(p.m(ell(ex + 1, ey + .5, 1.8, 2)), (INK,) * 4, flat=True)
p.px(ex, ey - 1, CREAM)

R.save()
