#!/usr/bin/env python3
"""silverfin "Silverfin the Page-Eater" (snake rig, 135 x 78, 9 parts, boss, ch2 Drowned Library):
"A silverfish grown as long as a gnome, silver and shy. The blight made her hungry for words, and she has eaten half the Library."
A felt silverfish-fish: a long carrot body that tapers to the tail, sewn from overlapping silver plates (s2..s6, each plate
edge a pale seam, chevron scale stitches, pale belly, three stubby felt legs on the ground under s2..s4), three long tail bristles
fanning back with blue fin webbing between them (s1), a blue dorsal frill fanning up behind the head (hood, under the head),
a round blunt head with two long antennae sweeping forward and up, a gold monocle, and a torn page with ink lines hanging from
her mouth (head); one shy dark eye with a heavy silver lid, sitting inside the monocle (eyes)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('silverfin')
P = {k: R.pv(k) for k in R.ids}
SILVER = ('#eef0f6', '#c6c8d8', '#9295b0', '#5f6380')
BACK = ('#b3b6cc', '#8a8eaa', '#6d7090', '#4f5470')
BELLY = ('#ffffff', '#f4f3f8', '#d6d7e2', '#9a9cb4')
FIN = ('#a9d6ea', '#3f8fb0', '#2f6f90', '#1f4a6a')
ALL = lambda x, y: True

chain = [('s2', P['s2'], P['s3'], 11, 15), ('s3', P['s3'], P['s4'], 15, 19), ('s4', P['s4'], P['s5'], 19, 22),
         ('s5', P['s5'], P['s6'], 22, 24), ('s6', P['s6'], P['head'], 24, 22)]
HEADC = (105, 25)
body_all = union(*[capsule([a, b], w0, w1) for _, a, b, w0, w1 in chain], ell(HEADC[0], HEADC[1], 15, 13))
REF = R.part('s2').m(body_all)

# s1: the tail stem and three long bristles with blue webbing between them
p = R.part('s1')
web = poly([(27, 63), (8, 50), (5, 62), (9, 72), (27, 67)])
p.add(p.m(web), FIN, local=True)
for a, b in (((18, 58), (10, 53)), ((17, 64), (8, 63)), ((18, 68), (10, 70))):
    p.line([a, b], FIN[2])
stem = capsule([(22, 65), P['s2']], 7, 11)
p.add(p.m(stem), SILVER, ref=REF)
for end in ((3, 46), (2, 63), (5, 74)):
    p.add(p.m(capsule([(22, 65), end], 3.4, 1.6)), SILVER, local=True)

# s2..s6: overlapping silver plates
for pid, a, b, w0, w1 in chain:
    p = R.part(pid)
    cap = capsule([a, b], w0, w1)
    if pid in ('s2', 's3', 's4'):        # a stubby felt leg standing on the ground
        lx = (a[0] + b[0]) / 2 + 1
        p.add(p.m(capsule([(lx, (a[1] + b[1]) / 2 + 2), (lx + 2, 71.5)], 3.6, 3.2)), SILVER, local=True)
    p.add(p.m(cap), SILVER, ref=REF)
    r = (w0 + w1) / 4
    p.add(p.m(inter(cap, below(a, b, r * .4))), BELLY, ref=REF)
    p.add(p.m(inter(cap, minus(ALL, below(a, b, -r * .35)))), BACK, ref=REF, stitch=SILVER[0])
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
    for t in (.3, .7):                    # chevron scale stitches along the flank
        for off in (-.45, .05):
            cx, cy = a[0] + dx * t + nx * off * r * 2, a[1] + dy * t + ny * off * r * 2
            p.line([(cx - 1, cy - 1), (cx, cy), (cx + 1, cy - 1)], SILVER[0] if off < 0 else BACK[1])
    if pid != 's2':                       # the plate's front edge sits over the one behind: pale seam + shade line
        seam = p.m(inter(cap, lambda x, y, a=a: w0 / 2 - 1.5 < math.hypot(x - a[0], y - a[1]) <= w0 / 2 - .5 and (x - a[0]) * dx + (y - a[1]) * dy < 0))
        p.fill(seam, SILVER[0])
        p.fill({(x + 1, y) for x, y in seam} - seam, SILVER[2])

# hood: a blue dorsal frill fanning up behind the head (drawn under it)
p = R.part('hood')
frill = poly([(P['hood'][0] + 3, 33), (82, 24), (78, 12), (83, 15), (84, 5), (89, 11), (92, 3), (95, 12), (100, 14), (97, 33)])
p.add(p.m(frill), FIN, stitch=FIN[3])
for top in ((80, 14), (85, 8), (92, 6)):
    p.line([(92, 28), top], FIN[2])

# head: round blunt head, antennae, monocle, a torn page in the mouth
p = R.part('head')
for pts in (((107, 14), (113, 8), (120, 5), (126, 5), (131, 8)), ((105, 14), (108, 8), (112, 5), (117, 3), (122, 3))):
    p.add(p.m(capsule(list(pts), 2.6, 1.4)), SILVER, local=True)
head = union(ell(HEADC[0], HEADC[1], 15, 13), ell(113, 28, 7.5, 7.5), capsule([P['s6'], P['head']], 20, 20))
p.add(p.m(head), SILVER, ref=REF)
p.add(p.m(inter(head, below((92, 33), (119, 31), 0))), BELLY, ref=REF)
p.add(p.m(inter(head, minus(ALL, below((90, 22), (112, 13), 0)))), BACK, ref=REF)
p.line([(120, 31), (112, 32), (107, 30)], INK)                       # the mouth
page = poly([(111, 32), (119, 32), (122, 43), (118, 42), (116, 45), (113, 42)])
p.add(p.m(page), PAPER, local=True)
for y, x0, x1 in ((35, 113, 118), (37, 113, 119), (39, 114, 119)):
    p.line([(x0, y), (x1, y)], '#74462a')
p.line([(95, 17), (96, 24), (95, 31)], SILVER[2])                           # cheek plate seam
p.add(p.m(ell(103, 28, 1.6, 1)), (BLUSH,) * 4, flat=True)
ring = p.m(inter(ell(107.5, 21.5, 5, 5), minus(ALL, ell(107.5, 21.5, 3.9, 3.9))))
p.fill(ring, GOLD[1]); p.fill({q for q in ring if q[0] < 107 and q[1] < 21}, GOLD[0])
p.line([(105, 26), (103, 31), (101, 34)], GOLD[2])                          # monocle chain

# eyes: one shy dark eye with a silver lid, inside the monocle
p = R.part('eyes')
ex, ey = 107, 21
p.add(p.m(ell(ex + .5, ey + .5, 3, 3)), ('#fff3c8',) * 4, flat=True)
p.add(p.m(rect(ex, ey - 1, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex, ey - 1, CREAM)
p.add(p.m(inter(ell(ex + .5, ey + .5, 3, 3), lambda x, y: y < ey - .5)), (SILVER[1],) * 4, flat=True)
p.line([(ex - 2, ey - 1), (ex + 2, ey - 1)], SILVER[3])

R.save()
