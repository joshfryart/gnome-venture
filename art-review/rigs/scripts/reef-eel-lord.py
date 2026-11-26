#!/usr/bin/env python3
"""reef-eel-lord "Reef Eel Lord" (snake rig, 95 x 57, 8 parts, large lv 34, coast and island): "Lives in the coral keep and bites anyone
who swims past without paying." (Eel Skin, Sea Glass, Pearl)
A moray in olive-gold felt, leaning out of its keep to collect the toll: a pointed tail on the sand (s1), a thick moray body (s2..s6)
with olive flanks under a dark back, a cream-yellow belly with a dashed belly seam, dark honeycomb spots, and a low continuous dorsal
fin running the whole length of the back like a frill; head = the blunt moray head gaping open on rows of needle teeth, a dark
throat, a nostril tube, and a crown of branching pink-coral sitting on the brow with a pearl set in its band (its toll);
eyes = a small mean gold eye under a heavy brow.
Silhouette: a long low S of a body ending in a tall gaping head and a spiky coral crown; the leviathan is a bigger blue serpent with fin sails."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa
S = importlib.import_module('_snake_grass-snake')
ALL = S.ALL

R = Rig('reef-eel-lord')
SIDE = ('#b8c060', '#8a9a38', '#627428', '#3a4a1c')
BACK = ('#7a8a30', '#566826', '#3e4e1c', '#283412')
BELLY = ('#fffbe0', '#f2e6a0', '#d4c270', '#9a8a40')
FIN = ('#f0d870', '#c8a838', '#8a7428', '#5a4e1e')
SPOT = '#f0e07a'
CORAL = ('#ffc0b0', '#f07a6a', '#c84a4a', '#8a2a36')
TIP = (3.5, 48.5)
W = (3, 10, 12.5, 13.5, 13.5, 13, 12)
ROT = 'rot'


def marks(p, pid, shape, a, b, r):
    dx, dy, L = S.unit(a, b)
    nx, ny = -dy, dx
    if pid != 's1':                                   # the dorsal fin: a low frill along the top of the back
        fin = inter(capsule([a, b], 2 * r + 6.5), minus(ALL, below(a, b, -r + .6)), S.along(a, b, -1.5, L + 1.5))
        p.add(p.m(fin, minus=[shape]), FIN, local=True, crescent=1)
        for t in range(2, int(L), 3):                 # fin rays
            x, y = a[0] + dx * t - nx * (r + 1.6), a[1] + dy * t - ny * (r + 1.6)
            if (int(x), int(y)) in p.layers[-1][0]:
                p.px(x, y, FIN[2])
    for k, (t, off) in enumerate(((.2, -.25), (.55, .05), (.8, -.4), (.4, -.6), (.7, .25))):   # honeycomb spots
        if pid == 's1' and k > 1:
            break
        x, y = a[0] + dx * L * t + nx * off * r, a[1] + dy * L * t + ny * off * r
        p.add(p.m(inter(shape, ell(x, y, 1.0, .8))), (SPOT,) * 4, flat=True)


P, REF, out = S.snake(R, TIP, W, SIDE, BACK, BELLY, pattern=marks, back_band=.35, belly_band=.4, seam=SIDE[2], belly_stitch=BELLY[3])

# head: blunt moray head gaping open, needle teeth, coral crown with a pearl
p = R.part('head')
hp = P['head']
neck = capsule([hp, (71, 16.5)], 11, 11.5)
upper = poly([(65, 13), (69, 8.5), (76, 8), (83, 10.5), (85.5, 14), (84.5, 16), (75, 17), (67, 19)])
lower = poly([(67, 21.5), (75, 20.5), (82.5, 21), (82, 23.2), (74, 24.6), (67, 25)])
p.add(p.m(neck, upper, lower), SIDE)
p.add(p.m(inter(union(upper, neck), lambda x, y: y < 11.6 + (x - 66) * .05)), BACK)
p.add(p.m(lower), BELLY, local=True)
gap = poly([(71, 18.6), (85, 15.6), (83.4, 21.2), (72, 21)])
p.add(p.m(gap), ('#7d2c5e', '#6e2038', '#5a1f44', '#5a1f44'), flat=True)
for x in (75, 78, 81, 84):                                                   # needle teeth, top and bottom
    p.px(x, 18 - (x - 75) * .2 + .5, CREAM); p.px(x - 1.5, 20.5, CREAM)
p.add(p.m(capsule([(84, 11.5), (86.5, 10)], 1.6, 1.2)), SIDE, local=True, flat=True)   # nostril tube
p.add(p.m(inter(neck, ell(67, 21, 1, .8))), (SPOT,) * 4, flat=True)
p.px(64, 17, SPOT); p.px(70, 13, SPOT)
crown = union(rect(67, 7, 78, 9.5),                                         # coral crown: a band and branching prongs
              *[capsule([(x, 8), (x + l, 8 - h), (x + l + br, 8 - h - 2)], 2.2, 1.4) for x, h, l, br in ((68, 3, -1, -1), (71, 4, 0, 1), (74.5, 4.3, .5, -1), (77, 3.2, 1, 1))])
p.add(p.m(crown), CORAL, local=True, crescent=1)
p.pxs([(66.5, 4.5), (79.5, 4.5)], CORAL[0])
p.add(p.m(ell(72.5, 8.2, 1.3, 1.2)), ('#ffffff', '#fff3c8', '#e4dcf6', '#c3b2ea'), local=True, crescent=0)   # the toll pearl

# eyes: small mean gold eye under a heavy brow
p = R.part('eyes')
S.eyeball(p, 76.4, 13.6, 1.8, '#f5cf6a', lid=BACK[2], lidcut=12.6, pupil='round')
p.line([(73.5, 11.2), (79, 12.6)], INK)

R.save()
