#!/usr/bin/env python3
"""old-holler "Old Holler" (golem rig, front view, boss, 87 x 109, 7 parts): the Chapter III-b boss of the Still Mere.
"A giant blind cave toad, wide as a cart. She swallows every sound she hears." Her eyes are blind and milky, and her throat is stained
grey with blight (it cracks and flakes off when she is low). She thumps with her wide, wet chin and booms back what she gulped.
A pale cave toad in mauve felt, squatting wide: a fat pear body with a cream belly, darker wart spots, and the blighted grey throat sac
bulging under her chin, cracked like old paint (body); a huge flat head nearly as wide as the frame, two eye mounds and two warty
parotoid lumps, a mouth seam from cheek to cheek and two nostril dots (head); blind milky eyes with no glint under heavy lids (eyes);
short stout forearms with four splayed fingers and round pads (armL / armR); big folded haunches with splayed webbed feet (legL / legR).
Silhouette: very wide and low, no spikes on top (Gneiss is tall and horned, the Moss Golem round with spore stalks)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('old-holler')
SKIN = ('#f6e6e6', '#d8b6bc', '#ab8594', '#76586c')
SKIN2 = ('#e6ccd0', '#c49ea8', '#9a7486', '#6a4c62')       # haunches, a step darker
WART = '#a07888'
BELLY = ('#fff3e4', '#f2e2cc', '#d4bea4', '#a89078')
BLIGHT = ('#dcd8d4', '#a8a4a2', '#807c7c', '#5a5658')
G = R.ground                                               # 104
cx = 43.5

for pid, s in (('legL', -1), ('legR', 1)):
    p = R.part(pid)
    x, y = R.pv(pid)
    hx = x + s * 6
    p.add(p.m(ell(hx, 94, 12.5, 9.5)), SKIN2)
    for k, (dx, dy) in enumerate(((-9, 0), (-3, 1.5), (4, 1))):              # splayed webbed toes, outward
        tx = hx + s * (dx + 6)
        p.add(p.m(capsule([(hx + s * 1, 99), (tx, G - .5 + dy * 0)], 4, 3), ell(tx, G - .8, 2.4, 1.7)), SKIN2, local=True, crescent=1)
    p.add(p.m(poly([(hx + s * -2, 100), (hx + s * 10, G - 1), (hx + s * 3, G - 1)])), SKIN2, flat=True)   # the web
    p.pxs([(hx - 4, 91), (hx + 3, 89), (hx + s * 6, 95), (hx - 1, 96)], WART)

p = R.part('body')
body = union(ell(cx, 74, 33.5, 17.5), ell(14, 60.5, 6.5, 5.5), ell(73, 60.5, 6.5, 5.5))
p.add(p.m(body), SKIN, stitch=SKIN[3])
p.add(p.m(inter(ell(cx, 79, 21, 11.5), body)), BELLY, local=True)
throat = union(ell(cx, 63.5, 16.5, 9), ell(cx, 56, 12, 4.5))
p.add(p.m(throat), BLIGHT, local=True)
for pts in (((cx - 9, 62), (cx - 6, 65), (cx - 7, 68)), ((cx + 5, 63), (cx + 8, 66), (cx + 12, 66))):
    p.line(list(pts), BLIGHT[3])                                           # the grey cracks
p.add(p.m(rell(cx - 12, 70, 2, 1.2, 30), rell(cx + 13, 72, 1.6, 1, -20)), BLIGHT, flat=True)   # flakes slipping down
for x, y in ((18, 70), (22, 77), (66, 70), (70, 77), (26, 66), (61, 66), (15, 80), (72, 82), (30, 88), (57, 88)):
    p.add(p.m(ell(x, y, 1.8, 1.4)), (WART,) * 4, flat=True)

for pid, s in (('armL', -1), ('armR', 1)):
    p = R.part(pid)
    x, y = R.pv(pid)
    hx, hy = x + s * 1, y + 22
    p.add(p.m(ell(x, y + 1.5, 6, 6), capsule([(x, y + 2), (hx, hy - 3)], 10, 7.5)), SKIN, crescent=1)
    for dx in (-5, -1.8, 1.8, 5):                                           # four splayed fingers with round pads
        fx = hx + dx * 1.15
        p.add(p.m(capsule([(hx, hy - 2), (fx, hy + 3)], 3, 2.6), ell(fx, hy + 3.6, 1.9, 1.7)), SKIN, local=True, crescent=1)
    p.pxs([(x - 2, y + 7), (x + 2, y + 12), (x - 1, y + 15)], WART)

p = R.part('head')
head = union(ell(cx, 46, 34.5, 10), ell(cx, 45, 29, 12), ell(cx, 51, 25, 8.5), ell(33.5, 37, 8.5, 7.5), ell(55.5, 37, 8.5, 7.5))
p.add(p.m(head), SKIN, stitch=SKIN[3])
for x in (18, 69):                                                          # warty parotoid lumps behind the eyes
    p.add(p.m(rell(x, 42, 6.5, 3.6, -12 if x < cx else 12)), SKIN2, local=True)
    p.pxs([(x - 2, 42), (x + 2, 41), (x, 43)], WART)
mouth = [(10.5, 45.5), (16, 48.5), (28, 50.5), (cx, 51), (59, 50.5), (71, 48.5), (76.5, 45.5)]
p.add(p.m(inter(head, lambda x, y: y > 51.5 - abs(x - cx) * .12)), BELLY, local=True)             # the pale wet chin
p.line(mouth, INK)
p.pxs([(41, 44), (46, 44)], SKIN[3])                                        # nostrils
for x, y in ((24, 46), (63, 46), (cx, 39.5), (28, 42), (59, 42)):
    p.add(p.m(ell(x, y, 1.5, 1.2)), (WART,) * 4, flat=True)
p.add(p.m(ell(21, 45, 2.6, 1.3), ell(66, 45, 2.6, 1.3)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
for ex in (33.5, 55.5):
    p.add(p.m(ell(ex, 38.5, 5.4, 4.8)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, 38.5, 4.4, 3.8)), ('#eef2f4',) * 4, flat=True)                    # milky
    p.add(p.m(ell(ex + .3, 39.4, 2.4, 2)), ('#c2ccd4',) * 4, flat=True)                 # a faint clouded pupil, no glint
    p.add(p.m(inter(ell(ex, 38.5, 5.4, 4.8), lambda x, y: y < 37.2)), (SKIN[2],) * 4, flat=True)   # heavy lid
    p.line([(ex - 5.5, 37), (ex + 5, 37)], INK)

R.save()
