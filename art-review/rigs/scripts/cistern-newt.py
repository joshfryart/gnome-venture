#!/usr/bin/env python3
"""cistern-newt "Cistern Newt" (snake rig, 71 x 34, 8 parts, side view): "A long dark newt with a clay-slick back, raised in the old cistern.
Its sour breath smells of vinegar and old pennies." (medium; Trek chapter II, the Claybound; Newt Tail, Wet Clay)
A long felt newt rearing up on its front legs: a tall flat paddle tail with a wavy crest lying on the ground (s1), a long dark slate
body sewn from segments (s2..s6) with a wet clay-brown slick along the back, a fire-orange belly dotted with black, little splayed
hind legs on s3 and propping front legs on s5 (far legs one shade darker, behind), and a broad flat head (head) with a round snout,
a wide closed smile and a puff of sour green breath; eye: a small gold eye with a dark bar pupil (eyes).
The segments are lit against the whole newt (ref=), so the joints read as sewn seams, not as sausages."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('cistern-newt')
P = {k: R.pv(k) for k in R.ids}
BACK = ('#8e7e72', '#625450', '#463a3a', '#2e2426')        # dark slate felt
CLAY = ('#ecd2a2', '#c4a272', '#9a7a52', '#6b5034')        # the clay slick on the back
BELLY = ('#ffc45a', '#f08a2a', '#c4521f', '#8a3418')       # fire-orange belly
TIP = (3, 27.2)
NOSE = (66.5, 9.5)

chain = [('s2', P['s2'], P['s3'], 6.5, 8), ('s3', P['s3'], P['s4'], 8, 9), ('s4', P['s4'], P['s5'], 9, 9),
         ('s5', P['s5'], P['s6'], 9, 8.2), ('s6', P['s6'], P['head'], 8.2, 7.6)]
whole = union(capsule([TIP, P['s2']], 2, 6.5), *[capsule([a, b], w0, w1) for _, a, b, w0, w1 in chain], ell(58, 10.5, 9, 4.6))
REF = R.part('s2').m(whole)
under = lambda a, b, w: below(a, b, w * .12)          # the belly side of a segment
over = lambda a, b, w: minus(lambda x, y: True, below(a, b, -w * .24))   # the back side

# s1: the flat paddle tail with its wavy crest, lying on the ground
p = R.part('s1')
crest = poly([(2.5, 26.5), (5, 24), (8, 23.3), (10, 22.2), (12.5, 22.5), (14.5, 21.8), (15.5, 25), (4, 27.5)])
p.add(p.m(crest), (CLAY[2], BACK[1], BACK[2], BACK[3]), local=True)
for x in (6, 9, 12):
    p.px(x, 24 if x != 12 else 23, BACK[3])
tail = capsule([TIP, P['s2']], 2.4, 6.5)
p.add(p.m(tail), BACK, ref=REF)
p.add(p.m(inter(tail, below(TIP, P['s2'], 1))), BELLY, ref=REF)
p.line([(4, 26), (12, 25)], CLAY[1])                                                    # the clay streak runs to the tail tip

# s2..s6: body segments: dark back, clay slick on top, orange belly with black dots, seams, legs
for pid, a, b, w0, w1 in chain:
    p = R.part(pid)
    cap = capsule([a, b], w0, w1)
    if pid in ('s3', 's5'):     # legs: far leg (darker, behind) then near leg
        hx, hy = (a[0] + 3, a[1] + 2) if pid == 's3' else (a[0] + 1, a[1] + 2.5)
        fx = hx + (3.5 if pid == 's3' else 3)
        far = union(capsule([(hx + 3, hy), (fx + 3.5, 29)], 2.6, 2.2), capsule([(fx + 2, 30), (fx + 6, 30)], 1.6))
        p.add(p.m(far), darker(BACK), local=True, crescent=0)
        near = union(capsule([(hx, hy), (fx, 29)], 3, 2.4), capsule([(fx - 2, 30), (fx + 3, 30)], 1.8), capsule([(fx, 29.5), (fx + 2.5, 28.5)], 1.4))
        nm = p.add(p.m(near), BACK, local=True, crescent=1)
        p.edge(nm - p.m(cap), BACK[3], sides=((-1, 0),))
        p.pxs([(int(fx - 2), 30), (int(fx + 3), 30)], BELLY[1])                       # orange toe tips
    p.add(p.m(cap), BACK, ref=REF)
    r = (w0 + w1) / 4
    p.add(p.m(inter(cap, under(a, b, r * 2))), BELLY, ref=REF)
    p.add(p.m(inter(cap, over(a, b, r * 2))), CLAY, ref=REF)
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
    for t in (.3, .75):                                                                 # black belly dots
        cx, cy = a[0] + dx * t + nx * r * .9, a[1] + dy * t + ny * r * .9
        p.px(cx, cy, INK)
    for t in (.5,):                                                                     # a wet glint on the clay slick
        cx, cy = a[0] + dx * t - nx * r * 1.3, a[1] + dy * t - ny * r * 1.3
        p.px(cx, cy, CLAY[0]); p.px(cx + 1, cy, CLAY[0])
    if pid != 's2':                                                                     # the sewn seam onto the segment behind
        seam = p.m(inter(cap, lambda x, y, a=a: math.hypot(x - a[0], y - a[1]) > w0 / 2 - 1.2 and (x - a[0]) * dx + (y - a[1]) * dy < 0))
        p.fill(seam - p.m(under(a, b, r * 2)), BACK[2])

# head: broad flat newt head, round snout, wide closed smile, sour breath
p = R.part('head')
skull = union(ell(57.5, 10.6, 8.4, 4.9), ell(63.5, 10.6, 4, 3.7), capsule([P['head'], (56, 11)], 7.6, 8.6))
p.add(p.m(skull), BACK, stitch=None)
p.add(p.m(inter(skull, lambda x, y: y > 12 - (x - 50) * .05)), BELLY)
p.add(p.m(inter(skull, rell(52, 8.2, 4.5, 1.4, -12))), CLAY, local=True, crescent=0)   # the clay slick ends on the nape
p.line([(66, 11.5), (61, 12.6), (55, 12.6), (52, 12)], INK)                            # wide closed smile
p.px(51, 11, INK)
p.px(65, 9, BACK[3])                                                                    # nostril
p.pxs([(57, 14), (59, 14)], INK)                                                        # chin dots
p.px(58, 11.5, BLUSH); p.px(59, 11.5, BLUSH)
# sour breath: two little green puffs just in front of the snout (on the head part so they move with it)
p.add(p.m(ell(68, 13.5, 1.5, 1.3)), ('#e4f0a8', '#c8d870', '#9aa860', '#6b7a3a'), local=True, crescent=0)
p.add(p.m(capsule([(66, 12.5), (68, 13.5)], 1.2)), ('#e4f0a8', '#c8d870', '#9aa860', '#6b7a3a'), flat=True)

# eyes: small gold eye with a dark bar pupil, a heavy brow
p = R.part('eyes')
ex, ey = P['eyes']
p.add(p.m(ell(ex, ey + .4, 3.0, 2.8)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey + .4, 2.1, 1.9)), ('#f5cf6a',) * 4, flat=True)
p.add(p.m(rect(ex - 1, ey, ex + 2, ey + 1)), (INK,) * 4, flat=True)
p.px(ex - 1, ey - 1, '#ffffff')

R.save()
