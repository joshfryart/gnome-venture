#!/usr/bin/env python3
"""pale-olm "Pale Olm" (worm5 rig, 71 x 29, 12 parts): "A long white salamander with no eyes to speak of. It has lived in the dark
so long that it hears your heartbeat first." (Deep Rock cave folk, trek ch3, level 21, medium; drops Pale Scale)
A felt cave salamander, long and low: a slender pink-white body sewn from four segments (s1 shoulder, s2..s4 trunk), a flat paddle
tail with a fin frill on top (s5) and a frill underneath (l5, tucked under), a long flat spoon-shaped head with a blunt snout and
three feathery coral gill plumes behind it (head). Tiny stick legs with splayed toes: near front leg l1, far front leg l2 (darker),
far hind leg l3 (darker), near hind leg l4. The eye is only a sewn-shut dimple under the skin (eyes). A thin grey blight vein
is stitched along the flank (the Deep Rock folk each carry one)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('pale-olm')
P = {k: R.pv(k) for k in R.ids}
SKIN = ('#fff6f0', '#f4dcd4', '#d9aeb0', '#a87e8c')
FAR = ('#e8c8c4', '#d9aeb0', '#b48a94', '#8a6474')
GILL = ('#fbc4d4', '#ec7a9c', '#c8486e', '#8a2a48')
GILL_SOFT = ('#fde0ea', '#f2bccb', '#d98ea6', '#a8607a')
VEIN = '#9a92a8'

# spine from the tail tip to the shoulder, and the body thickness along it
SP = [(3.5, 19.6), (11, 19.2), (P['s5'][0], 18.0), (P['s4'][0], 16.4), (P['s3'][0], 15.3), (P['s2'][0], 15.0), (51.5, 15.0)]
W = [1.5, 5.0, 7.6, 8.8, 9.0, 9.2, 9.4]
def spine(a, b):
    return [(SP[i], W[i]) for i in range(len(SP)) if a - .1 <= SP[i][0] <= b + .1]
def seg(a, b):
    pts = spine(a, b)
    return union(*[capsule([p0, p1], w0, w1) for (p0, w0), (p1, w1) in zip(pts, pts[1:])])
BODY = seg(0, 52)
REF = R.part('s1').m(BODY, ell(57, 14.5, 10, 4.5))

def trunk(pid, x0, x1, belly=True):
    p = R.part(pid)
    m = p.m(seg(x0, x1))
    p.add(m, SKIN, ref=REF)
    if belly:   # a pale belly band
        p.add(p.m(inter(seg(x0, x1), lambda x, y: y > 15.2 + (40 - x) * .09 + 2.6)), (SKIN[0], SKIN[0], SKIN[2], SKIN[3]), ref=REF)
    return p

def vein(p, pts):
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        for i in range(int(abs(bx - ax)) + 1):
            x = ax + (bx - ax) * i / max(1, abs(bx - ax))
            p.px(x, ay + (by - ay) * i / max(1, abs(bx - ax)), VEIN)

def seam(p, cx, cy, h):   # the sewn joint at the front (head-side) end of a segment
    for dy in range(-int(h), int(h) + 1):
        p.px(cx + (abs(dy) > h * .6), cy + dy, SKIN[2])

# s1: shoulder, carries the head and the near front leg
p = trunk('s1', 44.5, 52)
p.add(p.m(ell(50.5, 15.3, 4.8, 4.6)), SKIN, ref=REF)
# s2..s4: the long trunk, s5: the paddle tail with its top frill
p = trunk('s2', P['s3'][0] - .5, P['s2'][0] + 1.2); seam(p, 46, 15, 3); vein(p, [(37, 15.5), (41, 14.5), (46, 15)])
p = trunk('s3', P['s4'][0] - .5, P['s3'][0] + 1.2); seam(p, 37.5, 15.2, 3); vein(p, [(28, 16.5), (33, 15.5), (37.5, 15.5)])
p = trunk('s4', P['s5'][0] - .5, P['s4'][0] + 1.2); seam(p, 29, 16.2, 3); vein(p, [(20, 18), (24, 17), (29, 16.5)])
p = R.part('s5')
frill = poly([(4, 18.6), (9, 16.6), (15, 14.8), (19.5, 14.4), (20.5, 16), (12, 18.6)])
p.add(p.m(frill), FAR, local=True)
for x in (8, 11, 14, 17):
    p.line([(x, 18), (x + 1, 16.4 - (x - 8) * .2)], GILL_SOFT[2])
p.add(p.m(seg(0, P['s5'][0] + 1.4)), SKIN, ref=REF)
seam(p, 20, 17.9, 2.5); vein(p, [(10, 19.5), (15, 19), (20, 18.5)])

# l5: the frill under the tail (tucked behind s5)
p = R.part('l5')
p.add(p.m(poly([(5, 20), (12, 21.4), (16.5, 19.5), (17.5, 22), (13, 23.2), (8, 22.2)])), GILL_SOFT, local=True)
for x in (9, 12, 15):
    p.line([(x, 21), (x, 22)], GILL_SOFT[2])

# legs: tiny felt sticks, a 3-toed foot on the ground row
G = R.ground
def leg(pid, top, foot, ramp, toes=3):
    p = R.part(pid)
    knee = (foot[0] + (foot[0] - top[0]) * .2 + 1, top[1] + 3)
    p.add(p.m(capsule([top, knee, foot], 3.6, 2.4)), ramp, local=True)
    fx, fy = foot
    for k in range(toes):
        p.px(fx - 1 + k * 2 - (toes == 2), G, ramp[1])
    p.px(fx, G, ramp[1])
leg('l1', P['l1'], (51.5, G - .6), SKIN)
leg('l2', P['l2'], (44.5, G - .6), FAR)
leg('l3', P['l3'], (30.5, G - .6), FAR, 2)
leg('l4', P['l4'], (25.5, G - .6), SKIN, 2)

# head: long flat spoon head, blunt snout, mouth seam, coral gill plumes
p = R.part('head')
for bx, by, tx, ty, w in ((51.5, 13.5, 44.5, 7.5, 2.8), (52.5, 12.5, 48.5, 3.5, 3.2), (54.5, 12.5, 54.5, 4.2, 2.8)):
    L = math.hypot(tx - bx, ty - by); ux, uy = (tx - bx) / L, (ty - by) / L
    m = p.m(capsule([(bx, by), (tx, ty)], w, w - .6))
    p.add(m, GILL, local=True)
    for t in (.5, .75):   # frond notches: little pale ticks on the plume's back edge, a darker groove between them
        cx, cy = bx + (tx - bx) * t, by + (ty - by) * t
        p.px(cx - uy * (w / 2 + .6), cy + ux * (w / 2 + .6), GILL[0])
    p.line([(bx + ux * 3, by + uy * 3), (tx - ux * 1.5, ty - uy * 1.5)], GILL[2])
headm = union(ell(56.5, 14.6, 7.2, 4.6), poly([(55, 10.6), (64, 11.6), (68.4, 13.4), (68.6, 16.2), (64, 18.1), (55, 19)]))
p.add(p.m(headm), SKIN, ref=REF, stitch=SKIN[2])
p.add(p.m(inter(headm, lambda x, y: y > 16.6 - (x - 56) * .05)), (SKIN[0], SKIN[0], SKIN[2], SKIN[3]), ref=REF)
p.line([(68, 16), (62, 16.6), (57, 16.4)], SKIN[3])            # the long thin mouth
p.px(67, 14, SKIN[3])                                          # nostril
p.line([(50.5, 11.5), (49.5, 14.5), (50.5, 17.5)], SKIN[2])   # gill-collar seam
p.add(p.m(ell(60.5, 16.8, 1.2, .8)), (BLUSH,) * 4, flat=True)

# eyes: no real eyes, only a dimple sewn shut under the skin
p = R.part('eyes')
ex, ey = int(P['eyes'][0]), int(P['eyes'][1])
p.add(p.m(ell(ex + .5, ey + .5, 1.9, 1.3)), (SKIN[2],) * 4, flat=True)
p.line([(ex - 1, ey), (ex + 2, ey + 1)], SKIN[3]); p.line([(ex - 1, ey + 1), (ex + 2, ey)], SKIN[3])

R.save()
