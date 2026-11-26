#!/usr/bin/env python3
"""clam-lurker "Clam Lurker" (snail rig, 61 x 45, 4 parts): "A clam as big as a garden gate, and it has just yawned open." (coast; Blue Mussels, Seed Pearl, Pearl)
A giant felt clam seen from the side, mid-yawn. body = the lower valve resting on the sand (ribbed blue felt bowl) with the pink frilly
mantle and a seed pearl inside; shell = the upper valve, hinged at the left on the rig's shell pivot, opened about 15 degrees, with
radial ribs, a pale growth band and a row of cream felt teeth along its lip (the charge pose claps it shut on the hinge);
head = the pink fleshy foot lolling out of the gap, carrying the eye bulb; eyes = one heavy-lidded peeping eye."""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('clam-lurker')
SHELL = WATER
MANTLE = PETAL
HINGE = (12, 28.5)
A, B = (9, 29.5), (56.5, 12.5)      # the upper valve's lip (chord), hinge end to front end: a wide yawn
ALL = lambda x, y: True

# body: hinge ligament, the dark gap between the valves, mantle lips, the pearl, the lower valve
p = R.part('body')
gap = inter(poly([(11, 30), (57.5, 11.5), (58.5, 31)]), ell(33, 27, 26, 15))
p.add(p.m(gap), ('#7d2c5e', '#7d2c5e', '#5a1f44', '#5a1f44'), flat=True)
p.add(p.m(inter(gap, ell(40, 27, 13, 7))), ('#a8346a',) * 4, flat=True)            # the throat glows a little lighter
p.add(p.m(ell(15, 26.5, 4.6, 4.2)), WOOD, local=True)                               # the hinge ligament (shell pivot sits on it)
p.add(p.m(ell(27, 26.2, 2.8, 2.6)), ('#ffffff', '#fff3c8', '#f2e4c0', '#c9a96e'), local=True)   # seed pearl
bowl = inter(ell(32, 29, 24.5, 11), lambda x, y: y >= 28.5)
p.add(p.m(bowl), SHELL, stitch=SHELL[3])
p.add(p.m(inter(ell(34, 29.2, 21, 2.6), lambda x, y: y < 29.6)), MANTLE, local=True)   # lower mantle lip
for k in range(7):                                                                  # radial ribs on the lower valve
    ang = math.radians(10 + k * 26)
    p.line([(32 + math.cos(ang) * 7, 31 + math.sin(ang) * 2.5), (32 + math.cos(ang) * 23, 30 + math.sin(ang) * 10)], SHELL[2])
for x in (26, 32, 38, 44, 50):                                                      # little bottom teeth on the lower lip
    p.add(p.m(ell(x + .5, 27.6, 1.2, 1.6)), ('#ffffff', CREAM, '#f2e4c0', '#c9a96e'), local=True, crescent=1)

# shell: the upper valve
p = R.part('shell')
dome = inter(rell(33, 21, 25, 14, -19), minus(ALL, below(A, B, 1.8)))
p.add(p.m(dome), SHELL, stitch=SHELL[3])
band = inter(rell(30, 22.5, 15.5, 8, -19), minus(ALL, rell(30, 22.5, 12.5, 5.2, -19)), minus(ALL, below(A, B, -1)))
p.add(p.m(band), (SHELL[0], SHELL[0], SHELL[1], SHELL[1]), flat=True)               # a pale growth band
dm = p.m(dome)
for k in range(8):                                                                  # radial ribs from the hinge
    ang = math.radians(-12 - k * 21)
    pts = [(HINGE[0] + math.cos(ang) * 6, HINGE[1] + math.sin(ang) * 6), (HINGE[0] + math.cos(ang) * 60, HINGE[1] + math.sin(ang) * 60)]
    rib = p.m(inter(capsule(pts, 1), dome))
    p.fill(rib - {q for q in dm if any((q[0] + dx, q[1] + dy) not in dm for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}, SHELL[2])
p.add(p.m(ell(HINGE[0] + 3, HINGE[1] - 2, 3, 2.4)), (SHELL[2], SHELL[2], SHELL[3], SHELL[3]), local=True)   # the hinge knob
# cream felt teeth hanging from the lip
dx, dy = B[0] - A[0], B[1] - A[1]; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
for t in (.4, .52, .64, .76, .88):
    cx, cy = A[0] + dx * t + nx * 2.6, A[1] + dy * t + ny * 2.6
    p.add(p.m(ell(cx, cy, 1.4, 1.9)), ('#ffffff', CREAM, '#f2e4c0', '#c9a96e'), local=True, crescent=1)

# head: the fleshy foot lolling out of the gap, with the eye bulb
p = R.part('head')
foot = union(ell(49, 26.2, 8.5, 3.2), capsule([R.pv('head'), (52, 26.5)], 6, 5), ell(49.3, 19.6, 3.8, 3.8), capsule([(47, 24.5), (49.3, 20)], 4, 4))
p.add(p.m(foot), MANTLE)
p.px(44, 26, MANTLE[3]); p.px(51, 26, MANTLE[3]); p.px(47, 27, MANTLE[2])         # spots on the foot
p.line([(52, 26.5), (54, 26)], MANTLE[3])

p = R.part('eyes')
ex, ey = 49.1, 18.9
p.add(p.m(ell(ex, ey + .2, 2.9, 2.9)), (INK,) * 4, flat=True)
p.add(p.m(ell(ex, ey + .2, 2.0, 2.0)), (CREAM,) * 4, flat=True)
p.add(p.m(rect(49, 18, 51, 21)), (INK,) * 4, flat=True)                              # pupil, looking forward
p.add(p.m(inter(ell(ex, ey + .2, 2.9, 2.9), lambda x, y: y < 17.4)), (MANTLE[2], MANTLE[2], MANTLE[2], MANTLE[2]), flat=True)   # lid
p.line([(46, 17), (52, 17)], INK)

R.save()
