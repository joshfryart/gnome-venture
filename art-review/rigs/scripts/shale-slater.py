#!/usr/bin/env python3
"""shale-slater "Shale Slater" (bug.beetle rig, 53 x 33, 8 parts): "A pale woodlouse the colour of slate that rolls into a ball at the
first sign of trouble. Today it rolls at you." (small, lv 20, trek ch3 caves; Slate Shard)
A felt woodlouse in profile, built like a little rolled-up armadillo: a high, round slate-blue dome sewn from eight overlapping plates
(body: each plate a dark seam with a pale ridge behind it, a pale scalloped skirt along the bottom, two little tail prongs at the
rear and a chip of pale slate stuck on its back); a small slate head tucked under the front plate with a pink cheek (head); one small
button eye (eyes); long elbowed, beaded woodlouse feelers (antL up, antR forward); six short pale legs peeping from under the skirt,
two per part (leg1..leg3). Silhouette: the round hump of the batch (the silverfish is long and flat, the weaver all legs, the
glowworm a lit tube)."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_shale-slater')

R = Rig('shale-slater')
SLATE = ('#c3cad4', '#97a1ae', '#6c7684', '#454d5a')
PALE = ('#eef0f3', '#d2d7de', '#a3abb7', '#6c7684')
LEGC = ('#e2d8d8', '#bcaeb2', '#8e8086', '#5e5258')

# legs: two short pale legs per part, the far one a shade darker and set back
for pid, feet in (('leg1', ((13, 27), (16.5, 27.2))), ('leg2', ((23.5, 27.2), (27, 27.2))), ('leg3', ((32, 27.2), (36.5, 27)))):
    p = R.part(pid)
    x, y = R.pv(pid)
    for k, f in enumerate(feet):
        ramp = darker(LEGC) if k == 0 else LEGC
        knee = ((x + f[0]) / 2 + (1 if k else -1) * .6, y + 3.5)
        H.thin_leg(p, [(x + (k - .5) * 2, y - 1.5), knee, f], ramp, 2.8, 2)

# body: the plated dome
p = R.part('body')
dome = minus(ell(23, 19.5, 18.5, 14), lambda x, y: y > 23.5)
skirt = inter(ell(23, 19.5, 18.5, 14), lambda x, y: y > 19.5)
tail = union(capsule([(7, 21.5), (3.5, 23)], 2.2, 1.6), capsule([(8.5, 22.5), (5, 25)], 2, 1.4))
p.add(p.m(tail), darker(SLATE), local=True, crescent=0)
p.add(p.m(dome), SLATE, stitch=None)
seams = [8.5, 12.5, 16.5, 20.5, 24.5, 28.5, 32.5, 36.5]
dm = p.m(dome)
for sx in seams:   # a plate seam bowing back toward the tail, a pale ridge just behind it
    for (x, y) in dm:
        X, Y = x + .5, y + .5
        c = sx + .035 * (Y - 16) ** 2 - (Y - 16) * .12
        if abs(X - c) < .5 and Y < 20.5:
            p.px(x, y, SLATE[3])
        elif 0.5 <= c - X < 1.5 and Y < 20 and (x - 1, y) in dm:
            p.px(x, y, SLATE[0] if Y < 12 else SLATE[1])
H.blob(p, p.m(inter(skirt, dome)), PALE)          # the pale scalloped skirt of side plates
for sx in seams:
    p.px(int(sx + .6), 21, PALE[3]); p.px(int(sx + .6), 22, PALE[3]); p.px(int(sx + 1.6), 22, PALE[2])
p.fill(p.m(inter(dome, lambda x, y: y < 20.5 and y > 18.5)), SLATE[2])   # shadow line where the dome meets the skirt
SHARD = ('#8e9ab0', '#5e6a80', '#434d60', '#2e3544')
shard = poly([(19.5, 8.5), (21, 3.2), (23.5, 2.2), (25.5, 4.5), (27, 8.5)])     # a shard of slate stuck in its back (the Slate Shard)
p.add(p.m(shard), SHARD, local=True, crescent=1)
p.fill(p.m(poly([(21.5, 3.5), (23.3, 2.8), (22.8, 7), (21, 7.5)])), SHARD[0])
p.line([(23.5, 3), (23.5, 8)], SHARD[3])
for q in ((12, 13), (29, 11), (34, 15), (15, 9), (26, 16)):    # pale speckles
    p.px(q[0], q[1], SLATE[0])

# head: small, tucked under the front plate
p = R.part('head')
hd = union(ell(42.5, 20, 5, 4), capsule([R.pv('head'), (41, 20)], 5, 5))
p.add(p.m(hd), darker(SLATE))
p.line([(39, 17), (38.5, 20), (39, 23)], INK)                 # the front plate's edge
p.add(p.m(ell(45.5, 21.3, 1.3, .9)), (BLUSH,) * 4, flat=True)
p.line([(46, 22.6), (47.5, 22.3)], INK)

p = R.part('eyes')
H.button_eye(p, 41.8, 18, 1.9, look=1)

for pid, pts in (('antL', [(41, 16.5), (39.5, 12), (42.5, 7.5)]), ('antR', [(43.5, 16.5), (47, 12.5), (50.5, 14.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2, 1.4)), SLATE, local=True, crescent=0)
    p.px(int(pts[1][0]), int(pts[1][1]), PALE[1])        # the elbow bead
    p.px(int((pts[0][0] + pts[1][0]) / 2), int((pts[0][1] + pts[1][1]) / 2), SLATE[3])
    p.add(p.m(ell(pts[-1][0], pts[-1][1], 1.3, 1.3)), PALE, local=True, crescent=0)

R.save()
