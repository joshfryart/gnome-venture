#!/usr/bin/env python3
"""spadefoot-toad "Spadefoot Toad" (frog rig, 55 x 37, 5 parts, front view): "A fat toad with a spade on each hind foot, digging out of the
wall wearing a coat of clay." (medium; Trek chapter II, the Claybound; Toad Slime)
A round, fat felt toad, almost a ball: smooth tan skin under a cracked coat of pale clay (angular crusts with dark crack seams on the
back, the cheeks and the brows, clay crumbs falling off), a small content smile, a plain cream belly and little hands tucked in (body,
squashes from the ground); short folded hind legs whose feet each end in a big glossy black keratin spade, turned out so the spades stick
out at both sides at ground level, the creature's tell (footL / footR); and two tall eye domes holding tall gold eyes with the
spadefoot's vertical cat-slit pupils (eyeL / eyeR, they squash down onto their pivots)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('spadefoot-toad')
SKIN = ('#e3b47a', '#c98f55', '#9a6438', '#6a3f22')        # smooth tan toad felt
CLAY = ('#fbf0d8', '#ead5ae', '#cdb184', '#93643c')        # dried pale clay coat
CRACK = '#5a361e'
BELLY = ('#fff3c8', '#f7e7bd', '#e2c99a', '#b08f60')
SPADE = ('#4a4a52', '#141414', '#000000', '#000000')       # glossy black keratin spade
GLOSS = '#ffffff'
EYE = ('#ffe08a', '#f2b42a', '#c47f12', '#7a4a1f')
CX = 28


def crust(p, pts, cracks, inside):
    """an angular plate of dried clay with dark crack seams"""
    m = p.m(inter(poly(pts), inside))
    p.add(m, CLAY, local=True, crescent=0)
    for c in cracks:
        p.line(c, CRACK)
    return m


for pid in ('footL', 'footR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    s = -1 if pid == 'footL' else 1
    # the folded hind leg (mostly behind the body; its knee and foot show at the side)
    leg = union(ell(x - s * 1.5, 24.5, 5.4, 5.6), ell(x + s * .5, 30.6, 4, 2.3))
    p.add(p.m(leg), SKIN)
    p.add(p.m(inter(poly([(x - s * 5, 20.5), (x + s * 0, 19.5), (x + s * 2.5, 22.5), (x - s * 2, 24)]), leg)), CLAY, local=True, crescent=0)
    p.line([(x - s * 1.5, 20.5), (x - s * .5, 22.5)], CRACK)
    p.line([(x - s * 3.5, 26), (x + s * 2.5, 29.5)], SKIN[3])                               # knee fold
    # the big black spade: a curved blade sticking out at the side, flat on the ground
    blade = poly([(x + s * 1, 27.5), (x + s * 3.5, 25.2), (x + s * 6.5, 24.8), (x + s * 8.4, 26.8), (x + s * 8.4, 31), (x + s * 7.4, 32.9), (x + s * 1, 32.9)])
    p.add(p.m(blade), SPADE, local=True, crescent=1)
    p.line([(x + s * 3, 26.5), (x + s * 6.5, 26)], SPADE[0])                                # sheen along the top of the blade
    p.pxs([(x + s * 4, 27), (x + s * 5, 27), (x + s * 7, 28)], GLOSS)                     # the gloss glint
    p.line([(x + s * 3, 31.5), (x + s * 6.5, 31.5)], '#2e2e34')                            # a seam where the blade meets the ground
    p.pxs([(x - s * 1, 32), (x - s * 3, 32)], SKIN[3])                                      # toes

p = R.part('body')
bod = union(ell(CX, 20.5, 15.4, 12.2), rect(CX - 9, 29, CX + 9, 32.9))
p.add(p.m(bod), SKIN)
belly = inter(ell(CX, 29.5, 10, 6.2), bod)
p.add(p.m(belly), BELLY, local=True, crescent=1)
p.add(p.m(inter(belly, ell(CX + 6, 31.2, 2.6, 1.3))), CLAY, local=True, crescent=0)     # a little clay smear
# the clay coat: angular crusts over the back, the cheeks and the brow, cracked
crust(p, [(21, 9.5), (27, 8.4), (31.5, 9.6), (29.5, 13.6), (23.5, 13.8)], [[(26, 8.6), (25.5, 11), (27, 13.6)], [(25.5, 11), (22, 12)]], bod)
crust(p, [(31.5, 10.4), (36.5, 11), (35, 14.5), (30.6, 14)], [[(33, 10.6), (34, 13)]], bod)
crust(p, [(12.8, 19.5), (17.5, 18.2), (19.5, 21.5), (16, 24.4), (13, 23.5)], [[(15, 18.8), (16.5, 21.5), (14, 23)]], bod)
crust(p, [(43.2, 19.5), (38.5, 18.2), (36.5, 21.5), (40, 24.4), (43, 23.5)], [[(41, 18.8), (39.5, 21.5), (42, 23)]], bod)
crust(p, [(15.5, 26.5), (19, 26), (19.5, 29.5), (16, 30)], [[(17, 26.2), (18, 29)]], bod)
# the face: a small content smile, nostrils, blush
p.line([(24, 23), (25, 24), (27, 24.6), (29, 24.6), (31, 24), (32, 23)], INK)
p.pxs([(23, 22), (33, 22)], INK)                                                            # corners turn up
p.pxs([(26, 19), (30, 19)], SKIN[3])                                                        # nostrils
p.pxs([(21, 23), (22, 23), (34, 23), (35, 23)], BLUSH)
for hx in (21.5, 34.5):                                                                     # little hands tucked in
    p.add(p.m(ell(hx, 31.2, 2.8, 1.6)), SKIN, local=True, crescent=0)
    p.pxs([(hx - 1.5, 31), (hx + .5, 31)], SKIN[3])
for q in ((20, 15), (37, 16), (13, 26), (42, 27), (23, 31), (33, 28)):                     # clay crumbs
    p.px(q[0], q[1], CLAY[2])
    p.px(q[0], q[1] - 1, CLAY[0])

for pid in ('eyeL', 'eyeR'):
    p = R.part(pid)
    x, y = R.pv(pid)
    dome = ell(x, y - 5.5, 5.4, 6.6)
    p.add(p.m(dome), SKIN)
    # a cracked crust of clay on the brow
    s = -1 if pid == 'eyeL' else 1
    p.add(p.m(inter(dome, poly([(x - 4.5, y - 10), (x - 1, y - 12.6), (x + 3.5, y - 11.4), (x + 4.5, y - 9), (x, y - 10.2)]))), CLAY, local=True, crescent=0)
    p.line([(x + .5, y - 12), (x + .5, y - 10.5)], CRACK)
    # tall gold eye with a vertical cat-slit pupil
    p.add(p.m(ell(x, y - 5, 3.6, 4.6)), (INK,) * 4, flat=True)
    gold = p.add(p.m(ell(x, y - 5, 2.7, 3.7)), (EYE[1],) * 4, flat=True)
    p.add(p.m(inter(ell(x, y - 5, 2.7, 3.7), minus(ell(x, y - 6, 2.7, 3.7)))), (EYE[2],) * 4, flat=True)   # shade low in the eye
    p.add(p.m(inter(ell(x, y - 5, 2.7, 3.7), ell(x - .6, y - 6.6, 1.8, 1.6))), (EYE[0],) * 4, flat=True)  # warm light high in the eye
    p.add(p.m(ell(x, y - 5, .9, 3.9)), (INK,) * 4, flat=True)                                 # the vertical cat-slit pupil
    p.px(x - 2, y - 8, '#ffffff')                                                          # glint
    p.px(x - 2, y - 7, '#ffffff')

R.save()
