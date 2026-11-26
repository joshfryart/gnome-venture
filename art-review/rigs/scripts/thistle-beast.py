#!/usr/bin/env python3
"""thistle-beast "Thistle Beast" (quad.bear rig, 65 x 44, 8 parts; medium; grassland, mountain; L12; Thistle Spines, Thistle Heart)
"A walking thistle patch with a bad attitude."
A squat, round-backed beast that IS a thistle: a domed body of sage-green felt bracts (overlapping scale seams) with a skirt of
jagged spiny leaves round its belly and three big purple thistle-flower brushes sprouting from its back, each on a spiky green cup
(body); stubby stalk legs ending in leaf-cuff feet with cream spine claws (far legs a step darker); a spiny thistle leaf held up
behind as a tail (tail); a low blunt head with jagged leaf ears laid back, a small purple tuft, a scowling brow and a downturned
mouth with one cream spine poking out (head); one small round eye under the scowl (eyes)."""
import importlib.util, os, sys
_d = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_d, '..'))
from rigkit import *  # noqa
_s = importlib.util.spec_from_file_location('kb', os.path.join(_d, '_quad_wild-boar.py'))
K = importlib.util.module_from_spec(_s); _s.loader.exec_module(K)

R = Rig('thistle-beast')
LEAF = ('#e0efb8', '#9cc87a', '#62964f', '#2f5a2a')
FAR = darker(LEAF)
DARK = ('#5a8a4e', '#3f6e3a', '#2f5a2a', '#1f3d1c')
BRUSH = ('#f6c6ee', '#cf6ec8', '#9a3a9a', '#5a2a6a')
SPINE = PAPER
P = R.pv


def jag(pts, h, w=2.2, dirs=(0, -1)):
    """jagged leaf points: triangles at base pts, sticking out h px along dirs (dx, dy)"""
    return union(*[poly([(x - w * abs(dirs[1]), y - w * abs(dirs[0])), (x + dirs[0] * h, y + dirs[1] * h),
                         (x + w * abs(dirs[1]), y + w * abs(dirs[0]))]) for x, y in pts])


def brush(p, cx, cy, s=1.0):
    """a thistle flower: a round green bulb criss-crossed with bracts and spiky tips, a purple brush of strands fanning up out of it"""
    tips = [(-4.2, 5.2), (-2.6, 7.2), (-.8, 8.2), (1.2, 8.2), (3, 7.2), (4.6, 5.2)]
    fan = union(ell(cx + .2, cy - 1.8 * s, 3.6 * s, 2.4 * s),
                *[capsule([(cx + dx * .4 * s, cy - 1), (cx + dx * s, cy - h * s)], 2.2, .9) for dx, h in tips])
    p.add(p.m(fan), BRUSH)
    for i, (dx, h) in enumerate(tips):
        if i % 2:
            p.line([(cx + dx * .5 * s, cy - 2), (cx + dx * .9 * s, cy - (h - 1.5) * s)], BRUSH[2])
        p.px(cx + dx * s, cy - h * s + .2, BRUSH[0])
    bulb = ell(cx + .2, cy + 2.2 * s, 3.9 * s, 3.1 * s)
    spikes = jag([(cx - 3.4 * s, cy + 1.5 * s), (cx + 3.8 * s, cy + 1.5 * s)], 2.4, 1.1, (0, -1))
    spikes2 = union(jag([(cx - 3.3 * s, cy + 2.6 * s)], 2.6, 1, (-1, 0)), jag([(cx + 3.7 * s, cy + 2.6 * s)], 2.6, 1, (1, 0)))
    bm = p.add(p.m(bulb, spikes, spikes2), LEAF, local=True)
    for (x, y) in p.m(bulb):                                           # criss-cross bract seams
        if (x + y) % 3 == 0 or (x - y) % 3 == 0:
            if (x + y) % 3 == 0 and (x - y) % 3 == 0:
                p.px(x, y, LEAF[0])
            elif ((x - 1, y) in bm and (x + 1, y) in bm and (x, y + 1) in bm):
                p.px(x, y, LEAF[2])


def foot(p, fx, ramp):
    g = R.ground
    p.add(p.m(jag([(fx - 1.5, g - 2.5), (fx + 1.5, g - 2.5), (fx + 4, g - 2.5)], 2.5, 1.6, (0, -1))), ramp, local=True)   # leaf cuff
    for dx in (0, 2, 4):
        p.px(fx + dx, g, SPINE[1])                                                                 # spine claws


# far legs: stubby stalks with leaf-cuff feet
for pid, fx in (('legBF', 21), ('legFF', 44)):
    p, m = K.leg(R, pid, fx, FAR, 6, 5, top=3, foot=None, cloven=False)
    foot(p, fx - 1.5, DARK)

# tail: a broad spiny thistle leaf raised behind, a midrib and side veins
p = R.part('tail')
blade = union(capsule([P('tail'), (10.5, 17.5), (6, 11.5)], 6.5, 2.5))
p.add(p.m(blade, jag([(12, 21.5), (8.5, 17.5), (6, 14.5)], 3, 1.5, (-.8, .5)), jag([(13, 17.5), (10, 14), (8.5, 11)], 3, 1.5, (.5, -.8))), LEAF)
p.line([(14, 21), (10, 17), (7, 13)], LEAF[3]); p.line([(10, 17), (8, 18)], LEAF[2]); p.line([(11, 18), (12, 15)], LEAF[2])

# body: a round bract dome with spiny leaves sticking out all round, three thistle flowers on the back
p = R.part('body')
torso = union(ell(30, 23.5, 15, 8.5), ell(23, 25, 9.5, 6.5), ell(39, 24.5, 8, 6.5))
for bx, by, s_ in ((19.5, 11.5, .8), (39.5, 12, .8), (29.5, 9.5, .92)):
    brush(p, bx, by, s_)
leaves = union(jag([(16, 30), (21, 32), (27, 33), (33, 33), (39, 31.5)], 3.6, 2.4, (-.3, 1)),    # skirt of spiny leaves under the belly
               jag([(15.5, 18), (14.5, 22.5), (15, 27)], 3.5, 2, (-1, -.2)),                    # rump leaves
               jag([(24.5, 16), (34.5, 15.5), (44, 18)], 3, 1.8, (-.4, -1)))                     # back spines between the flowers
tm = p.m(torso, leaves)
p.add(p.m(leaves), DARK, local=True)
p.add(p.m(torso), LEAF, stitch=None)
for row, y0 in enumerate((17, 22, 27)):                                                           # big overlapping bract scales
    for x0 in range(17 + (row % 2) * 4, 46, 8):
        arc = [(x0 - 3, y0 - 1.5), (x0, y0 + 1.5), (x0 + 3, y0 - 1.5)]
        if all(((int(x), int(y)) in tm) for x, y in arc):
            p.line(arc, LEAF[2]); p.px(x0, y0 - 1, LEAF[0]); p.px(x0, y0 - 2, SPINE[1])

# near legs
for pid, fx in (('legBN', 16.5), ('legFN', 40)):
    p, m = K.leg(R, pid, fx, LEAF, 6.5, 5.5, top=3, thigh=(4.5, 4) if pid == 'legBN' else None, foot=None, cloven=False)
    p.edge({q for q in m if q[1] < P(pid)[1] + 2}, LEAF[3], sides=((-1, 0), (1, 0)))
    foot(p, fx - 1.5, LEAF)

# head: low blunt head, big jagged leaf ears laid back, a heavy scowling brow, sulky mouth with a spine tooth
p = R.part('head')
skull = ell(50, 21, 7.5, 6.5)
snout = capsule([(52, 22.5), (59.5, 23.5)], 9, 7)
neck = capsule([P('head'), (47, 22)], 9, 9)
ears = union(poly([(45.5, 16.5), (41, 7.5), (44.5, 10.5), (45, 5.5), (48, 10), (50.5, 6), (51.5, 15)]))
p.add(p.m(ears), DARK, local=True)
p.line([(48.5, 15), (46.5, 9.5)], DARK[3])
p.add(p.m(skull, snout, neck), LEAF)
p.add(p.m(inter(union(snout, skull), lambda x, y: y > 25.2)), (LEAF[0], LEAF[0], LEAF[1], LEAF[2]), local=True)   # pale chin
p.add(p.m(jag([(44, 27), (47.5, 28)], 2.5, 1.5, (0, 1))), LEAF, local=True)                         # spiky chin leaves
p.add(p.m(ell(61.6, 21.8, 1.7, 1.7)), (UMBER2, INK, INK, INK), local=True)                           # nose
p.line([(61, 26), (58, 25.5), (55, 26.5)], INK)                                                      # sulky mouth
p.px(57, 26, SPINE[0]); p.px(57, 27, SPINE[1])                                                       # a spine for a tooth
p.add(p.m(poly([(45.5, 16.5), (53.5, 17.8), (53.5, 19.3), (46, 18.3)])), DARK, flat=True)          # the scowling brow
p.add(p.m(ell(54, 24.2, 1.3, .9)), (BRUSH[0],) * 4, flat=True)                                      # thistle-pink cheek

p = R.part('eyes')
K.eye_dot(p, 49.6, 20.4, r=1.3)

R.save()
