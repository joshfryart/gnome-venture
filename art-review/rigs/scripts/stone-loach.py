#!/usr/bin/env python3
"""stone-loach "Stone Loach" (snake rig, 83 x 41, 8 parts, medium, trek ch3b, still cave water):
"A blind grey fish that slides out of the still water to see who is knocking."
A felt loach rearing up out of the water to listen: a round paddle tail fin (s1), a long soft pebble-grey body sewn from five
segments (s2..s6) with a darker back, a cream belly and brown pebble mottling, a low frilly dorsal ridge on s3/s4 and a small
pelvic fin on s4, and a blunt flat-bottomed head (head) with a small downturned mouth and three pairs of drooping felt barbels
(the whiskers it feels its way with). Blind: one milky, pupil-less button eye under a heavy sewn lid (eyes)."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('stone-loach')
P = {k: R.pv(k) for k in R.ids}
GREY = ('#e4e2dc', '#b8b6b0', '#8c8a85', '#5e5c58')
BACK = ('#aaa8a2', '#84827d', '#686661', '#4a4844')
BELLY = ('#f1ece0', '#dedbd3', '#b8b6b0', '#8c8a85')
FIN = ('#c9c7c0', '#9a9892', '#6e6c67', '#4a4844')
MOTTLE = '#5e554a'
ALL = lambda x, y: True

chain = [('s2', P['s2'], P['s3'], 8, 9), ('s3', P['s3'], P['s4'], 9, 10), ('s4', P['s4'], P['s5'], 10, 11),
         ('s5', P['s5'], P['s6'], 11, 11), ('s6', P['s6'], P['head'], 11, 11)]
body_all = union(*[capsule([a, b], w0, w1) for _, a, b, w0, w1 in chain], ell(61, 12, 8, 6))
REF = R.part('s2').m(body_all)

# s1: the round paddle tail fin and the tail stem
p = R.part('s1')
fin = union(poly([(16, 30), (16, 34.5), (7, 36), (3, 33), (3, 26), (6, 21.5)]), ell(5.5, 29, 3.5, 6))
p.add(p.m(fin), FIN, local=True)
for a, b in (((15, 31), (6, 23)), ((15, 32), (3, 28)), ((15, 33), (4, 33))):
    p.line([a, b], FIN[2])
stem = capsule([(14, 32), P['s2']], 6, 8)
p.add(p.m(stem), GREY, ref=REF)
p.add(p.m(inter(stem, below((14, 32), P['s2'], 1))), BELLY, ref=REF)

# s2..s6: back / flank / belly, pebble mottling, sewn seams, fins
for pid, a, b, w0, w1 in chain:
    p = R.part(pid)
    cap = capsule([a, b], w0, w1)
    if pid in ('s3', 's4'):      # the low frilly dorsal ridge
        x0 = a[0] + 1
        p.add(p.m(poly([(x0 - 1, a[1] - 3), (x0 + 1, a[1] - 8), (x0 + 5, a[1] - 9), (x0 + 8, b[1] - 7), (b[0] + 1, b[1] - 3)])), FIN, local=True)
        p.line([(x0 + 2, a[1] - 7), (x0 + 2, a[1] - 4)], FIN[0]); p.line([(x0 + 5, a[1] - 7), (x0 + 5, a[1] - 4)], FIN[0])
    if pid == 's4':              # pelvic fin
        p.add(p.m(poly([(40, 34), (42, 37.5), (46, 36.5), (45, 33)])), FIN, local=True)
    p.add(p.m(cap), GREY, ref=REF)
    r = (w0 + w1) / 4
    p.add(p.m(inter(cap, below(a, b, r * .5))), BELLY, ref=REF)
    p.add(p.m(inter(cap, minus(ALL, below(a, b, -r * .4)))), BACK, ref=REF)
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
    for t, off, big in ((.3, -.25, 1), (.75, .0, 0), (.55, -.6, 0)):
        cx, cy = a[0] + dx * t + nx * off * r * 2, a[1] + dy * t + ny * off * r * 2
        p.fill(p.m(inter(ell(cx, cy, 1.2 + big * .4, 1.0), cap)), MOTTLE)
    if pid != 's2':
        seam = p.m(inter(cap, lambda x, y, a=a: w0 / 2 - 1.3 < math.hypot(x - a[0], y - a[1]) <= w0 / 2 - .3 and (x - a[0]) * dx + (y - a[1]) * dy < 0))
        p.fill(seam, GREY[3])

# head: blunt flat-bottomed head, downturned mouth, three pairs of drooping barbels
p = R.part('head')
for base, tip in (((68, 15), (71, 20)), ((70, 14), (75, 18)), ((71, 12), (77, 14))):
    p.add(p.m(capsule([base, ((base[0] + tip[0]) / 2 + 1, (base[1] + tip[1]) / 2 - .5), tip], 1.8, 1.4)), ('#ead3cc', '#d4aea6', '#a8837c', '#7d5f5a'), local=True)
head = union(ell(61.5, 11, 8, 6.5), poly([(60, 6), (69, 7), (72.5, 11), (71, 15), (56, 17)]), capsule([P['s6'], P['head']], 11, 11))
p.add(p.m(head), GREY, ref=REF)
p.add(p.m(inter(head, lambda x, y: y > 13.2 + (x - 55) * .05)), BELLY, ref=REF)
p.add(p.m(inter(head, lambda x, y: y < 8 - (x - 60) * .15)), BACK, ref=REF)
p.line([(71, 13), (68, 14), (66, 13.5)], INK)                               # small downturned mouth
p.fill(p.m(ell(57, 8, 1, .8)), MOTTLE); p.px(67, 9, MOTTLE)
p.line([(58, 6), (57, 11), (58, 15)], GREY[3])                              # gill seam
p.add(p.m(ell(65, 12, 1.1, .7)), (BLUSH,) * 4, flat=True)

# eyes: blind: a milky pupil-less button under a heavy stitched lid
p = R.part('eyes')
ex, ey = 63.9, 6.6
p.add(p.m(ell(ex, ey, 2.6, 2.6)), (GREY[3],) * 4, flat=True)
p.add(p.m(ell(ex, ey + .3, 1.8, 1.8)), ('#dfe6ea',) * 4, flat=True)
p.px(64, 7, '#ffffff')
p.add(p.m(inter(ell(ex, ey, 2.6, 2.6), lambda x, y: y < ey - 1)), (BACK[1],) * 4, flat=True)
p.line([(61.5, 5), (66.5, 5)], GREY[3])

R.save()
