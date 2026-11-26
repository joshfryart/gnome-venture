#!/usr/bin/env python3
"""quartz-snail "Quartz Snail" (snail rig, 61 x 42, 6 parts): "A slow snail with a shell of tiny crystals that chime when it turns.
It looks sleepy and snaps anyway." (medium, lv 21, the Deep Rock caves; Quartz Shell; cave folk with a thin grey vein of blight)
A cave snail in felt: its shell (shell) is a round dome sewn from many little lilac and white crystal facets (a patchwork of
cut felt with dark seams, still winding in a faint spiral), crowned by three clear quartz points sticking up and one out the back,
each with a white glint, so it is the spiky one of the batch; a long, cool slate-blue foot (body) with a pale sole and a thin grey
blight vein stitched along its flank; a broad blunt face (head) with a grumpy jaw line; eye stalks tipped with little crystal beads
(antL / antR); a drowsy, half-shut button eye (eyes) that still looks ready to snap."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_mollusc_garden-snail')

R = Rig('quartz-snail')
P = {k: R.pv(k) for k in R.ids}
SKIN = ('#e4f0fa', '#a9c4dc', '#7894b4', '#4a6488')
GEM = ('#f4f0ff', '#d4c6f4', '#a68ee0', '#5e4698')
CLEAR = ('#ffffff', '#e4dcf6', '#a68ee0', '#5e4698')
VEIN = '#7a7f88'
GROUND = R.ground + 1

# body: long slate foot, pale sole, the grey blight vein
p = R.part('body')
foot = inter(union(ell(36.5, 32.6, 18.2, 5.8), capsule([(3.5, 36.7), (12, 35.6), (23, 32.8)], 2.6, 8.5), ell(25, 31.5, 9, 4)), lambda x, y: y < GROUND)
p.add(p.m(foot), SKIN)
p.fill(p.m(inter(foot, lambda x, y: y >= GROUND - 1.6, lambda x, y: x > 7)), SKIN[0])
H.stitch_line(p, [(8, 35.5), (18, 34.2), (30, 33.6), (42, 34), (51, 32.5)], VEIN, gap=1)
p.px(29, 32, VEIN); p.px(41, 33, VEIN)

# shell: a felt dome patched together from crystal facets, with quartz points on top
p = R.part('shell')
C = (24, 18.4)
dome = ell(C[0], C[1], 13, 12.6)
points = [((14, 10), (16.5, 2.5), (20.5, 8.5)), ((20.5, 8), (25, 1.5), (29, 8)), ((28.5, 10), (34, 4), (35, 12.5)), ((12, 14), (8, 6.5), (16, 10.5))]
for a, tip, b in points:   # two-tone quartz points: lit left face, shaded right face, a white glint
    p.add(p.m(poly([a, tip, b])), CLEAR, local=True, crescent=1)
    mid = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    p.fill(p.m(inter(poly([a, tip, b]), lambda x, y, tip=tip, mid=mid: (x - tip[0]) * (mid[1] - tip[1]) - (y - tip[1]) * (mid[0] - tip[0]) < 0)), CLEAR[1])
    p.line([tip, (tip[0] + (mid[0] - tip[0]) * .7, tip[1] + (mid[1] - tip[1]) * .7)], '#ffffff')
p.add(p.m(dome), GEM, stitch=None)
dm = p.m(dome)
seeds = [(C[0] + 1.5 + math.cos(a) * r, C[1] + 1 + math.sin(a) * r * .95) for r, a in
         [(0, 0)] + [(4.2, k * 1.26 + .3) for k in range(5)] + [(9, k * .785 + .1) for k in range(8)]]
cols = [GEM[1], GEM[2], GEM[0], GEM[2], GEM[1], GEM[2], GEM[1], GEM[0], GEM[2], GEM[1], GEM[0], GEM[2], GEM[1], GEM[2]]
for (x, y) in dm:
    d = sorted((math.hypot(x + .5 - sx, y + .5 - sy), i) for i, (sx, sy) in enumerate(seeds))
    if d[1][0] - d[0][0] < .75:
        p.over[(x, y)] = GEM[3]
    elif (x, y) not in p.over:
        c = cols[d[0][1]]
        rim = any((x + dx, y + dy) not in dm for dx, dy in ((1, 0), (0, 1), (1, 1), (2, 2)))
        p.over[(x, y)] = GEM[3] if rim else c
p.fill(p.m(inter(capsule(H.spiral(C[0] + 2, C[1] + 1.5, 1.5, 11.5, 1.6, start=3.6), 1.2), ell(C[0], C[1], 11.8, 11.4))), GEM[3])   # the faint spiral under the facets
p.line([(13, 27.5), (20, 30.4), (28, 30.4), (35, 27)], GEM[3])                            # the aperture lip seam

# head: broad blunt face on a thick neck, a grumpy jaw
p = R.part('head')
head = union(capsule([P['head'], (47, 24.5)], 10, 10), ell(49.6, 22.8, 8, 5.8), ell(54, 25, 4.8, 4.2))
p.add(p.m(head), SKIN)
p.line([(52.5, 27.5), (55, 27), (57.5, 27.8)], SKIN[3])
p.add(p.m(ell(52.6, 25.4, 1.4, 1)), ('#d8b4cc',) * 4, flat=True)
p.line([(43, 24), (42.6, 28)], SKIN[2])

# eye stalks: slate tubes tipped with crystal beads
p = R.part('antL')
H.stalk(p, P['antL'], (41.6, 5.6), SKIN, w0=3, w1=2.2, knob=2.3, knob_ramp=GEM, mid=(43.6, 12))
p.px(40.6, 4.4, '#ffffff')
p = R.part('antR')
H.stalk(p, P['antR'], (54.4, 5.0), SKIN, w0=3, w1=2.2, knob=2.3, knob_ramp=GEM, mid=(52.6, 11.5))
p.px(53.4, 3.8, '#ffffff')

# eyes: drowsy, half shut
p = R.part('eyes')
H.button_eye(p, P['eyes'][0], P['eyes'][1], 1.7, lid=SKIN[2], lidcut=-.25)

R.save()
