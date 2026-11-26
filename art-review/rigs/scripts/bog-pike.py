#!/usr/bin/env python3
"""bog-pike "Bog Pike" (snake rig, 103 x 56, 8 parts): "A long-toothed fish that lunges from the reeds at anything dangling a boot."
A felt pike rearing out of the bog: forked orange tail fin flat on the ground (s1), a long olive body sewn from five
segments (s2..s6, dark back, cream pale-spotted flanks, cream belly; dorsal + anal fins far back on s2, pelvic fin on s4,
pectoral fin on s6), and a long duck-bill head (head) with an underbite full of cream teeth and a gill seam. Eye: gold, heavy lid (eyes).
The chained segments are lit against the whole fish (ref=), so the joints read as sewn seams, not as sausages."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('bog-pike')
P = {k: R.pv(k) for k in R.ids}
FIN = ('#f5cf6a', '#f08a4a', '#dd3a2a', '#a8241f')
BACK = PINE
SIDE = MOSS
BELLY = PAPER
SPOT = '#f2e4c0'

# the body path: s2 .. s6, then the neck. widths (full) at each end
chain = [('s2', P['s2'], P['s3'], 9, 12), ('s3', P['s3'], P['s4'], 12, 14), ('s4', P['s4'], P['s5'], 14, 15),
         ('s5', P['s5'], P['s6'], 15, 16), ('s6', P['s6'], P['head'], 16, 15)]
body_all = union(*[capsule([a, b], w0, w1) for _, a, b, w0, w1 in chain], capsule([P['head'], (74, 20)], 14, 13))
REF = R.part('s2').m(body_all, ell(70, 24, 8, 8))

# s1: the forked tail fin and the tail stem
p = R.part('s1')
fin = poly([(26, 42.5), (17, 38.5), (5, 33), (8, 40), (12.5, 44.8), (7, 49.5), (5, 51), (17, 49.5), (26, 48.5)])
p.add(p.m(fin), FIN, local=True)
for a, b in (((17, 41.5), (8, 36)), ((16, 44.5), (10, 42.5)), ((17, 48.5), (8, 49))):
    p.line([a, b], FIN[3])
stem = capsule([(19, 45.5), P['s2']], 7, 8)
p.add(p.m(stem), SIDE, ref=REF)
p.add(p.m(inter(stem, below((19, 45.5), P['s2'], 1.2))), BELLY, ref=REF)

# s2..s6: segments with back / flank / belly bands, seams, spots and fins
for k, (pid, a, b, w0, w1) in enumerate(chain):
    p = R.part(pid)
    cap = capsule([a, b], w0, w1)
    if pid == 's2':   # dorsal fin on the back, anal fin underneath, both far back like a real pike
        p.add(p.m(poly([(23, 42), (26, 34), (31, 31.5), (35, 33), (37, 39)])), FIN, local=True)
        p.add(p.m(poly([(27, 48.5), (29.5, 53.5), (35, 52.5), (36, 47)])), FIN, local=True)
        p.line([(27, 35.5), (28, 38.5)], FIN[3]); p.line([(31, 33), (31.5, 37.5)], FIN[3])
    if pid == 's4':   # pelvic fin
        p.add(p.m(poly([(50, 46), (53, 52.5), (57.5, 50), (56, 44)])), FIN, local=True)
        p.line([(53, 49), (54.5, 51)], FIN[3])
    if pid == 's6':   # pectoral fin, just behind the gills
        p.add(p.m(poly([(64.5, 34.5), (63.5, 41), (68, 39.5), (70, 33)])), FIN, local=True)
        p.line([(66, 37), (65.5, 39.5)], FIN[3])
    p.add(p.m(cap), SIDE, ref=REF)
    r = (w0 + w1) / 4
    p.add(p.m(inter(cap, below(a, b, r * .35))), BELLY, ref=REF)
    p.add(p.m(inter(cap, minus(lambda x, y: True, below(a, b, -r * .45)))), BACK, ref=REF)
    # pale chain spots along the flank, in two staggered rows
    import math
    dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
    for t, off in ((.25, -.05), (.7, -.05), (.48, .2)):
        cx, cy = a[0] + dx * t + nx * off * r * 2, a[1] + dy * t + ny * off * r * 2
        if 2 < t * L and pid != 's2' or off < 0:
            p.add(p.m(inter(rell(cx, cy, 1.6, 1.0, math.degrees(math.atan2(dy, dx))), cap)), (SPOT, SPOT, SPOT, SPOT), flat=True)
    # the sewn seam where this segment sits on the one behind it
    if pid != 's2':
        seam = p.m(inter(cap, lambda x, y, a=a: math.hypot(x - a[0], y - a[1]) > w0 / 2 - 1.2 and (x - a[0]) * dx + (y - a[1]) * dy < 0))
        p.fill(seam, SIDE[3])
    if pid == 's3':
        pass

# head: long flat snout, underbite, cream teeth, gill seam
p = R.part('head')
neck = ell(70.5, 24.5, 8.2, 8.2)
upper = poly([(64, 19), (71, 13.5), (80, 10.5), (90, 12), (99.5, 15.5), (100, 18.2), (88, 19.8), (74, 23)])
lower = poly([(70, 22), (88, 21), (100.5, 20.5), (100, 23.5), (90, 26), (79, 30), (69, 32)])
p.add(p.m(neck, upper, lower), SIDE, stitch=None)
p.add(p.m(inter(union(neck, lower), below((64, 26), (100, 22), 0))), BELLY)
p.add(p.m(inter(upper, minus(lambda x, y: True, below((66, 17), (100, 16.5), -1.5)))), BACK)
p.line([(99, 19.5), (88, 20.5), (78, 23), (75, 24.5)], INK)                      # the long mouth
for x in (80, 83, 86, 89, 92, 95, 98):
    p.px(x, 21 if x < 88 else 21, CREAM)                                     # teeth on the lower jaw
for x in (82, 88, 94):
    p.px(x, 19 if x > 85 else 20, CREAM)                                     # and a few hanging down
p.line([(73, 14.5), (75, 19), (75, 25), (72.5, 30)], SIDE[3])               # gill seam
p.px(98, 15.5, SIDE[3]); p.px(97, 16, SIDE[3])                               # nostril
p.add(p.m(ell(76.5, 26.5, 1.2, 1)), (BLUSH,) * 4, flat=True)                # a felt cheek

# eyes: a gold eye with a heavy olive lid (cross)
p = R.part('eyes')
ex, ey = 80, 13
p.add(p.m(ell(ex + .5, ey + .5, 3.6, 3.6)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex + .5, ey + .5, 2.6, 2.6)), ('#f5cf6a',) * 4, flat=True)
p.add(p.m(rect(ex, ey - 1, ex + 2, ey + 2)), (INK,) * 4, flat=True)
p.px(ex - 1, ey - 1, CREAM)
p.add(p.m(inter(ell(ex + .5, ey + .5, 3.6, 3.6), lambda x, y: y < ey - .3)), (BACK[0], BACK[1], BACK[1], BACK[1]), flat=True)
p.line([(ex - 3, ey - 1), (ex + 3, ey)], INK)

R.save()
