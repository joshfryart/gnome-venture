#!/usr/bin/env python3
"""leopard-slug "Leopard Slug" (worm rig, 55 x 30, 6 parts): "A spotted slug the length of a gnome, slithering for your lettuce."
(small, lv 2, forest / wetland / rainforest, rain and fog; Slug Slime, Spotted Hide)
A long felt slug crawling right, no shell: a pale fawn body sewn from four pieces lit as one (s1 front with the saddle-shaped mantle,
s2, s3 with the raised keel ridge, s4 the pointed tail), a cream sole skirt with a running stitch, dark leopard spots in rows along the
back and a marbled cluster on the mantle; the head (head) peeks out under the mantle with a blush, two short lower feelers and two
tall upper tentacles, and it is already nibbling a stolen frilly lettuce leaf; the eyes (eyes) are dark felt knobs with little button
eyes at the tips of the tall tentacles. Silhouette: a long low spotted slug with two tall stalks, no shell at all (unlike the snails)."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_mollusc_garden-snail')

R = Rig('leopard-slug')
P = {k: R.pv(k) for k in R.ids}
FAWN = ('#f6e4c2', '#dcbc8c', '#b08c5e', '#7a5a3c')
SPOT = '#3a2a24'
SOLE = '#f2e4c0'
LEAF = ('#e4f4b8', '#a8d46a', '#6fa83e', '#3f6e2a')
GROUND = R.ground + 1
lo = lambda x, y: y < GROUND

SHAPES = {
    's1': union(ell(39.2, 19.6, 9, 6.4), ell(35, 21.5, 5, 3.8)),
    's2': ell(30.4, 20, 8.6, 5.6),
    's3': union(ell(21.2, 20.8, 7.8, 4.9), capsule([(13.5, 19.6), (25.5, 16.4)], 2.4, 2.4)),
    's4': capsule([(17, 21), (10, 22.6), (3.4, 24.6)], 7.6, 1.8),
}
REF = R.part('s1').m(*[inter(s, lo) for s in SHAPES.values()], ell(46, 21, 6, 4))
SPOTS = {'s4': [(7.5, 23.2), (11.5, 21.4), (15, 22.4)],
         's3': [(16.6, 19.4), (19.6, 22), (22.6, 18.4), (25.6, 21.2)],
         's2': [(25.8, 17.4), (28.4, 20.6), (31.4, 16.6), (34, 19.8), (31.2, 23.4)],
         's1': [(33.6, 16), (37, 14.6), (40.4, 15.4), (35.6, 18.6), (39.4, 18.4), (42.6, 18.8)]}

for pid, shape in SHAPES.items():
    p = R.part(pid)
    m = p.m(inter(shape, lo))
    p.add(m, FAWN, ref=REF)
    p.fill({q for q in m if q[1] >= GROUND - 1.5}, SOLE)                                    # the pale sole skirt
    for x, y in SPOTS[pid]:
        sm = p.m(inter(ell(x, y, 1.8 if pid != 's4' else 1.3, 1.3), shape))
        if pid == 's1':
            sm = p.m(inter(union(ell(x, y, 1.6, 1.1), ell(x + 1.2, y + .8, 1, 1)), shape))
        p.fill(sm, SPOT)
    if pid != 's1':                                                                         # the seam where it sits on the piece ahead
        right = max(x for x, y in m)
        p.fill({q for q in m if q[0] >= right and q[1] < GROUND - 4}, FAWN[2])
H.stitch_line(R.part('s2'), [(24, 23.4), (37, 23.4)], FAWN[3])
H.stitch_line(R.part('s3'), [(15, 23.4), (28, 23.4)], FAWN[3])
p = R.part('s1')                                                                            # the mantle seam
p.line([(31.5, 19.2), (34, 20.4), (38, 21.2), (43, 21), (46.6, 19.8)], FAWN[3])

# head: peeking out under the mantle, lower feelers, tall tentacles, a stolen lettuce leaf
p = R.part('head')
for base, tip in (((43.8, 16.6), (40.4, 6.4)), ((47, 17), (47.2, 6))):
    p.add(p.m(capsule([base, tip], 2.8, 2)), FAWN, local=True, crescent=1)
p.add(p.m(capsule([(50.5, 20), (52.6, 19)], 1.4)), FAWN, local=True, crescent=0)
p.add(p.m(ell(46.2, 20.8, 5.6, 4.2), capsule([P['head'], (44, 20.5)], 5, 6)), FAWN)
p.add(p.m(ell(47.4, 21.6, 1.2, .9)), (BLUSH,) * 4, flat=True)
p.fill(p.m(inter(ell(46.2, 20.8, 5.6, 4.2), lambda x, y: y >= GROUND - 1.5)), SOLE)
leaf = union(ell(50.8, 22.8, 2.6, 2.2), ell(51.6, 20.6, 1.8, 1.6))
p.add(p.m(leaf), LEAF, local=True, crescent=1)
p.line([(49.5, 24), (52, 20.5)], LEAF[3]); p.px(52, 24, LEAF[0]); p.px(50, 21, LEAF[0])

# eyes: dark knobs with button eyes at the tops of the tall tentacles
p = R.part('eyes')
for x, y in ((40.2, 5.2), (47.2, 4.8)):
    p.add(p.m(ell(x, y, 2.4, 2.2)), ('#8a7460', '#6e5c4a', '#4a3a2e', '#3a2a24'), local=True, crescent=1)
    p.add(p.m(rect(int(x), int(y) - 1, int(x) + 2, int(y) + 1)), (INK,) * 4, flat=True)
    p.px(int(x), int(y) - 1, CREAM)

R.save()
