#!/usr/bin/env python3
"""fern-cassowary "Fern Cassowary" (bird.long rig, large, 61 x 83, 8 parts): "A feathered helmet on two legs, with kicks like falling rocks."
(forest, rainforest, island; lv 36; Long Feather, Black Feather, Spotted Hide)
A tall felt cassowary whose plumage is a mound of drooping fern fronds: a domed body of dark fern-green felt with a ragged frond fringe
hanging over the thighs (body), a draped cloak of lighter fronds with midribs and pinnae plus a few black wing quills (wing, +r lifts
it), trailing fronds behind (tail), thick grey scaly legs on three toes with the long pale dagger claw on the inner toe (legB darker
behind, legF in front), a bare blue neck with a magenta nape and two red wattles swinging at the throat (neck), a small blue head under
a tall amber horn casque with a dark down-curved beak (head), and a cold gold eye (eyes)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('fern-cassowary')
FERN = ('#6f9a5a', '#4a6e40', '#33502e', '#22361f')          # dark fern felt (kept light enough for the dark theme)
FROND = ('#a8c878', '#7ab55c', '#4f8a3e', '#2f5a2a')
LEG = ('#b6b8a4', '#8b8f7e', '#5f6456', '#3c4036')
BLUE = ('#9fe0f4', '#4aa8d8', '#2f6fa8', '#1f3d6a')
MAG = ('#e88ac0', '#c84a98', '#8a2a6a', '#5a1a44')
CASQ = ('#f5d08a', '#d8a050', '#a8702a', '#6e4418')
G = R.ground


def leg(pid, ramp):
    p = R.part(pid)
    x, y = R.pv(pid)
    xi = int(x)
    p.add(p.m(capsule([(x, y), (xi - 1, y + 9), (xi + 1, G - 2)], 6, 3.6)), ramp)                # thick drumstick into the shank
    for yy in range(int(y) + 9, G - 2, 2):
        p.line([(xi - 1, yy), (xi + 1, yy)], ramp[2])                                           # scutes
    p.add(p.m(capsule([(xi - 3, G - .5), (xi + 6, G - .5)], 2.4), capsule([(xi, G - 1.5), (xi + 5, G - 2)], 2)), ramp, flat=True)
    p.add(p.m(capsule([(xi + 4, G - 1.5), (xi + 10, G + .2)], 2, 1)), (CREAM, '#f2e4c0', '#c9a96e', '#9a6b3f'), flat=True)  # the dagger claw
    p.px(xi - 4, G, INK)


leg('legB', darker(LEG))
leg('legF', LEG)

# tail: a sheaf of fronds trailing down and back
p = R.part('tail')
for tip, w in (((5, 50), 4.5), ((8, 55), 4), ((12, 57), 3.5)):
    m = p.add(p.m(capsule([R.pv('tail'), tip], 7, w * .6)), FERN, local=True, crescent=1)
    p.line([R.pv('tail'), tip], FERN[3])

# body: domed mound of fern felt with a frond fringe over the thighs
p = R.part('body')
dome = union(rell(29, 42, 17, 13, -8), ell(38, 37, 7, 6))
fringe = union(*[poly([(x - 3, 50), (x + 3, 50), (x + 1.5, 59 + (x % 3)), (x - .5, 59 + (x % 3))]) for x in range(16, 44, 4)])
p.add(p.m(dome, fringe), FERN, stitch=None)
for x in range(16, 44, 4):
    p.line([(x, 51), (x + .5, 57 + (x % 3))], FERN[3])
for (x, y) in ((22, 36), (30, 33), (36, 40), (27, 44), (19, 46), (35, 47)):                    # pinna ticks in the felt
    p.line([(x, y), (x - 2, y + 2)], FERN[0])

# wing: a cloak of lighter fronds draped from the shoulder, with three black wing quills
p = R.part('wing')
for tip in ((11, 46), (16, 49), (22, 50), (28, 48)):
    f = capsule([R.pv('wing'), ((R.pv('wing')[0] + tip[0]) / 2 + 1, (R.pv('wing')[1] + tip[1]) / 2 - 2), tip], 5, 2)
    p.add(p.m(f), FROND, local=True, crescent=1)
for tip in ((11, 46), (16, 49), (22, 50), (28, 48)):
    mx, my = (R.pv('wing')[0] + tip[0]) / 2 + 1, (R.pv('wing')[1] + tip[1]) / 2 - 2
    p.line([R.pv('wing'), (mx, my), tip], FROND[3])                                             # midribs
for tip in ((11, 46), (16, 49), (22, 50), (28, 48)):                                           # pinnae ticks along each frond
    for t in (.55, .75):
        x0, y0 = R.pv('wing')[0] + (tip[0] - R.pv('wing')[0]) * t, R.pv('wing')[1] + (tip[1] - R.pv('wing')[1]) * t
        p.px(x0 - 1, y0, FROND[0]); p.px(x0 + 1, y0 + 1, FROND[2])
for tip in ((30, 46), (32, 47.5), (34, 45.5)):
    p.add(p.m(capsule([(28, 38), tip], 1.4, 1)), (FERN[3], '#1a2218', '#1a2218', '#1a2218'), flat=True)   # quills

# neck: bare blue neck, magenta nape, red wattles
p = R.part('neck')
n = capsule([R.pv('neck'), (41.5, 28), (44, 18)], 7, 6)
p.add(p.m(n), BLUE)
p.add(p.m(inter(n, lambda x, y: x < 41.5 and y < 30)), MAG)                                    # magenta nape
for tip in ((34, 41), (37, 42.5), (40.5, 42.5), (44, 41)):                                     # a frond collar where the neck leaves the plumage
    p.add(p.m(capsule([(39.5, 34), tip], 4.5, 2)), FERN, local=True, crescent=1)
    p.line([(39.5, 35), tip], FERN[3])
for c, h in (((46.5, 26), 5), ((44.5, 28), 6)):
    p.add(p.m(capsule([(c[0] - .5, c[1] - 3), c, (c[0] + .5, c[1] + h - 3)], 3, 2.6)), EMBER, local=True, crescent=1)
p.line([(39, 33), (42, 32)], BLUE[2])                                                          # skin folds
p.line([(39.5, 25), (42, 24)], BLUE[2])

# head: small blue head, tall amber casque, dark down-curved beak
p = R.part('head')
skull = union(ell(47, 15.5, 5.2, 4.6), capsule([R.pv('head'), (46, 16)], 6, 6))
p.add(p.m(skull), BLUE)
casque = union(rell(46, 8, 3.9, 6.4, -14), poly([(42.5, 13), (43, 9), (50, 9), (51, 13)]))
p.add(p.m(casque), CASQ, local=True)
p.line([(44.5, 4), (45.5, 8), (47, 12)], CASQ[2])                                                 # a sewn ridge up the helmet
beak = poly([(50.5, 12.5), (55, 13), (58.5, 15.5), (59, 18.5), (56, 17), (51, 17.5)])
p.add(p.m(beak), ('#6a6470', '#45404a', '#2e2a33', '#1e1a22'), local=True)
p.line([(52, 15.5), (56, 16)], '#1e1a22')

# eyes: a cold gold eye
p = R.part('eyes')
ex, ey = 48, 14
p.add(p.m(ell(ex + 1, ey + 1, 2.5, 2.3)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + 1, ey + 1, 1.7, 1.5)), ('#f5cf6a',) * 4, flat=True)
p.add(p.m(rect(ex + 1, ey, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex, ey, CREAM)
p.line([(ex - 1, ey - 2), (ex + 3, ey - 1)], BLUE[3])                                          # stern brow

R.save()
