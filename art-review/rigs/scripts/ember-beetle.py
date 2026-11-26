#!/usr/bin/env python3
"""ember-beetle "Ember Beetle" (bug.beetle rig, 61 x 45, 8 parts): "Its shell glows like a coal fresh from the fire." (desert, mountain; Ember Shell, Ember Spark)
A round, high-domed felt beetle that is a live coal: charcoal felt wing case (body) quilted with glowing orange crack seams and a hot
gold heart, a little felt flame licking up from the top of the dome (the Ember Spark), a short charcoal shoulder plate; a round
charcoal head with a warm glowing cheek and a tiny pincer (head), one button eye under a cross brow (eyes), short club antennae tipped
with sparks (antL / antR), and three stubby charcoal legs (leg1..leg3). Silhouette: the tallest, roundest dome of the batch, with the flame."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_bug_ember-beetle')

R = Rig('ember-beetle')
CHAR = ('#9a7e68', '#6e5546', '#523e33', '#2a1a10')
HOT = ('#fff3c8', '#f5cf6a', '#f08a4a', '#dd3a2a')
GLOW = EMBER

# legs: stubby, the rear one raked back, the front one forward
H.leg(R, 'leg1', (15.5, 32), (13, 38.5), darker(CHAR), w=(4.2, 3.6, 3))
H.leg(R, 'leg2', (30.5, 32.5), (29, 38.5), darker(CHAR), w=(4.2, 3.6, 3))
H.leg(R, 'leg3', (42.5, 32), (46, 38.5), darker(CHAR), w=(4.2, 3.6, 3))

# body: the coal dome + shoulder plate + flame
p = R.part('body')
dome = minus(ell(24, 21, 17, 13), lambda x, y: y > 30.5)
plate = ell(38.5, 22, 6.5, 7.5)
p.add(p.m(plate), CHAR, local=True)
p.add(p.m(dome), CHAR, stitch=CHAR[3])
WARM = ('#a8665a', '#8a4e40', '#6e3d34', '#4a2c1a')
H.blob(p, p.m(inter(ell(21, 21, 12, 8.5), dome)), WARM)               # the felt warming over the coal
heart = poly([(15, 19), (18, 15.5), (23, 16.5), (27, 15), (28.5, 19.5), (25, 23.5), (19, 24), (16, 22.5)])
H.blob(p, p.m(heart), (HOT[1], GLOW[0], GLOW[1], GLOW[2]))             # a split where the coal shows
p.fill(p.m(ell(22, 19.3, 3.5, 2)), HOT[1])
for pts in ([(16, 21), (12, 21.5), (8.5, 23.5)], [(26.5, 16), (29.5, 12.5), (33, 11.5)], [(19, 15.8), (18, 11.5), (20, 9)],
            [(24, 23.5), (26, 27), (30, 28)], [(17.5, 23.5), (14.5, 27.5)]):
    p.fill(p.m(inter(capsule(pts, 1.8, 1.1), dome)), GLOW[1])                 # glowing cracks running out of the split
    p.pxs(pts[1:2], HOT[1])
p.line([(36, 12), (34, 18), (30, 24), (27, 29)], CHAR[3])                     # the wing-case seam
p.fill(p.m(inter(dome, lambda x, y: y > 28.5)), CHAR[2])      # the rim of the case
flame = poly([(20, 9.5), (19, 5.5), (21.5, 2.5), (22, 5), (24, 1.5), (25.5, 6), (27, 4), (27.5, 9.5)])
p.add(p.m(flame), (HOT[0], HOT[2], GLOW[1], GLOW[2]), local=True, crescent=0)
p.add(p.m(ell(23.5, 8, 1.8, 2)), (HOT[0], HOT[1], HOT[1], HOT[1]), flat=True)
p.add(p.m(ell(38.5, 20, 1.6, 1.3)), (GLOW[0], GLOW[1], GLOW[1], GLOW[1]), flat=True)    # an ember on the plate

# head: round, a warm cheek, a little pincer
p = R.part('head')
hd = union(ell(46.8, 24, 7, 6.6), capsule([R.pv('head'), (45, 24)], 6, 6))
p.add(p.m(hd), CHAR)
p.add(p.m(capsule([(52, 27.5), (55.5, 28.5), (56.5, 26.8)], 2.2, 1.4)), darker(CHAR), local=True, crescent=0)   # pincer
p.add(p.m(ell(49.5, 27, 1.6, 1.1)), (GLOW[0],) * 4, flat=True)                # glowing cheek
p.line([(51, 28.5), (53, 29)], INK)

p = R.part('eyes')
H.button_eye(p, 48.8, 22.4, 2.4, look=1)
p.line([(46, 19), (51, 19.8)], INK)

for pid, pts in (('antL', [(45.9, 19.5), (44.5, 14), (46, 10)]), ('antR', [(50.1, 19.5), (52.5, 15), (55.5, 12.5)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2, 1.6)), CHAR, crescent=0)
    p.add(p.m(ell(pts[-1][0], pts[-1][1], 1.9, 1.9)), (HOT[0], GLOW[0], GLOW[1], GLOW[2]), local=True, crescent=0)

R.save()
