#!/usr/bin/env python3
"""drumming-cricket "Drumming Cricket" (bug.plain rig, 75 x 54, 10 parts): "A fat cricket in a crust of clay that drums its wings on
the walls. Nobody told it the beat has stopped meaning anything." (trek Claybound chambers, level 21; Cricket Leg)
A fat dark-brown felt field cricket caked in terracotta clay: a round, heavy abdomen (body) with cracked clay crust patches and two
spiky cerci at the tail, a saddle-shaped neck shield, and its two pairs of veined tan wings held UP over its back mid-drum
(wingB, wingF, behind the body), which gives it the tall, raised silhouette in the batch. A big round head (head) with a clay smear,
palps and a big button eye (eyes); very long whip antennae, one swept back over the wings, one reaching forward (antL / antR).
The hind leg (leg1) is the folded jumping leg: a big drumstick thigh with clay chevrons and a spiny shin; two short front legs."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_insect_tallow-grub')

R = Rig('drumming-cricket')
BODY = ('#957258', '#6e5038', '#4c3424', '#2f1e14')
LEGC = ('#a8805e', '#7e5a3e', '#56392a', '#33201a')
CLAY = ('#f0b888', '#d0845a', '#a05a38', '#6e3420')
WING = ('#f6e2b4', '#dcbe84', '#ae8a54', '#765832')
ALL = lambda x, y: True

# leg1: the folded jumping leg, thigh back-down to a knee behind the tail, spiny shin forward to the ground
p = H.leg(R, 'leg1', [(5, 43.5), (12.5, 48.6)], LEGC, (9, 4.6, 2.4), foot=1, spur=((8, 45), (10, 47)))
for t in (.35, .55, .75):
    x, y = 26.7 + (5 - 26.7) * t, 33.9 + (43.5 - 33.9) * t
    p.line([(x + 1.5, y - 2.5), (x - 1, y), (x + 1.5, y + 2)], CLAY[2])
H.leg(R, 'leg2', [(36, 43), (34.5, 48.6)], LEGC, (3.6, 3, 2.4), foot=-1)
H.leg(R, 'leg3', [(48.5, 42.5), (50.5, 48.6)], LEGC, (3.6, 3, 2.4), foot=1)

# wings: raised over the back mid-drum, veined felt
for pid, tip, ramp, rot in (('wingB', (25, 2.5), darker(WING), -34), ('wingF', (14, 10), WING, -24)):
    p = R.part(pid)
    x0, y0 = R.pv(pid)
    cx, cy = (x0 + tip[0]) / 2, (y0 + tip[1]) / 2
    L = math.hypot(tip[0] - x0, tip[1] - y0) / 2 + 1.5
    wm = p.add(p.m(rell(cx, cy, L, 5.2 if pid == 'wingF' else 4.4, math.degrees(math.atan2(tip[1] - y0, tip[0] - x0)))), ramp, local=True)
    p.line([(x0 - 1, y0 - 1), (tip[0] + 2, tip[1] + 1)], ramp[2])
    if pid == 'wingF':
        for a, b in (((29, 19.5), (23, 21)), ((25, 16.5), (19, 18)), ((27, 15), (23, 10)), ((22, 13), (18, 8.5))):
            p.line([a, b], ramp[2])
        H.stitch_line(p, [(33, 25), (24, 22.5), (16, 16.5), (13, 11)], ramp[3])

# body: fat abdomen, neck saddle, cerci, clay crust
p = R.part('body')
for pts in ([(10, 31), (2.5, 27.5)], [(10, 33.5), (3, 33.5)]):
    p.add(p.m(capsule(pts, 2, 1.2)), LEGC, local=True, crescent=0)
abdo = union(ell(23.5, 30.2, 14.5, 9.8), ell(34.5, 27, 4.5, 4.6), ell(40.5, 31.5, 7.5, 7.8), ell(44.5, 37, 4.5, 3))
p.add(p.m(abdo), BODY)
H.stitch_line(p, [(10, 34), (14, 38.5), (24, 40), (33, 39)], BODY[3])
p.fill(p.m(inter(abdo, capsule([(36, 22), (35.5, 41)], 1.3))), BODY[3])       # the neck saddle seam
crust = inter(abdo, union(lambda x, y: y < 26.5 + 2.2 * math.sin(x * .9) + (x - 24) * .08, rell(31, 36, 4.5, 2.4, 8)))
H.blob(p, p.m(crust), CLAY)
for pts in ([(14, 23.5), (16, 25.5), (15, 27)], [(21, 21), (22.5, 24), (25, 25)], [(28, 22.5), (29, 26)], [(38, 24), (40, 26.5), (43, 27)], [(30, 35.5), (32, 37)]):
    p.line(pts, CLAY[3])                                                       # cracks in the clay crust
for x in (14, 19, 25):
    p.line([(x, 37), (x + 1, 40)], BODY[2])

# head: big round head with a clay smear, palps, blush
p = R.part('head')
p.add(p.m(capsule([(54.5, 36), (56, 40)], 2, 1.5), capsule([(52.5, 37), (53, 41)], 1.8, 1.4)), LEGC, local=True, crescent=0)
HEADC = ('#8a6450', '#5e4232', '#422c20', '#2a1a10')
hm = p.add(p.m(ell(49.5, 30.6, 7, 7.4), capsule([R.pv('head'), (47, 31)], 6, 6)), HEADC)
H.seam_over(p, hm, R.part('body').m(abdo), BODY[3])
H.blob(p, p.m(inter(lambda x, y: y < 25.8 + 1.2 * math.sin(x * 1.3), ell(49.5, 30.6, 7, 7.4))), CLAY)
p.line([(45, 25), (47, 27)], CLAY[3])
p.px(54, 33, BLUSH); p.px(53, 33, BLUSH)

p = R.part('eyes')
H.button_eye(p, 50.8, 29.4, 2.2)

# antennae: long whips
for pid, pts in (('antL', [(47.1, 23.1), (45, 15), (40, 7), (34.5, 2.5)]), ('antR', [(51.9, 23.1), (56, 16), (63, 9.5), (71.5, 5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.8, 1.1)), LEGC, crescent=0)

R.save()
