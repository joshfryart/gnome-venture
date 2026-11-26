#!/usr/bin/env python3
"""root-weevil "Root Weevil" (bug.beetle rig, 79 x 35, 8 parts): "A long-snouted gnawer of anything that used to grow." (trek fields and
hollows, level 17; Beetle Shell, Wing Dust)
A small, humpbacked felt weevil in soil colours: an egg-shaped ochre wing case (body) that rises to a hump at the back, sewn with
rows of cream scale-dots and a dark centre seam, on a short round shoulder; a little round head (head) that runs out into a very long,
down-curving snout with a pale root end gripped in its tip; a beady button eye (eyes); elbowed antennae with club tips, set halfway
down the snout as on a real weevil (antL / antR); three short russet legs (leg1..leg3).
Silhouette: a hump and a long drooping snout, low and small next to the other beetles."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_bug_ember-beetle')

R = Rig('root-weevil')
SOIL = ('#e0bc84', '#b0844e', '#82593a', '#4a2c1a')
RUSS = ('#b8744a', '#8a4a2a', '#663620', '#3f2014')
ROOT = ('#fff3c8', '#f2e4c0', '#c9a96e', '#9a6b3f')

for pid, knee, foot in (('leg1', (26.5, 23.5), (24.5, 28.5)), ('leg2', (39.5, 24), (38.5, 28.5)), ('leg3', (50, 23.5), (53, 28.5))):
    H.leg(R, pid, knee, foot, RUSS, w=(3.4, 2.8, 2.2), spur=False)

# body: shoulder + humped egg of a wing case with rows of scale dots
p = R.part('body')
p.add(p.m(ell(45, 15.5, 5.5, 5.5)), SOIL, local=True)
case = minus(union(ell(29, 12.5, 11.5, 9.5), ell(38.5, 15, 8, 6.5)), lambda x, y: y > 21.5)
p.add(p.m(case), SOIL, stitch=SOIL[3])
cm = p.m(case)
H.blob(p, p.m(inter(union(rell(25, 10, 3.5, 2, -40), rell(33, 17, 3.5, 1.6, -30), rell(36, 10.5, 2.2, 1.4, -40)), case)), (SOIL[1], '#9a7044', SOIL[2], SOIL[3]))   # mottling
for off in (-5, -2.2, 3, 6):                                                    # the rows of punched scales (striae), parallel to the seam
    H.stitch_line(p, [(42 + off, 7.5 + off * .3), (36 + off, 12 + off * .3), (28 + off, 18 + off * .3), (25 + off, 20.5)], SOIL[2], gap=1)
for q in ((25, 13), (31, 8), (34, 15), (21, 16), (38, 11), (29, 17)):
    p.px(q[0], q[1], ROOT[1])
p.line([(42, 7.5), (36, 12), (28, 18), (24, 21)], SOIL[3])                     # the centre seam of the wing cases
p.fill(p.m(inter(case, lambda x, y: y > 19.8)), SOIL[2])

# head: a round little head and the long drooping snout with a root end
p = R.part('head')
snout = capsule([(51, 14.5), (58, 15.4), (64, 17), (69.5, 19.8), (72.5, 23.5)], 4.4, 2.4)
hd = union(ell(50.5, 14.5, 4.8, 4.6), capsule([R.pv('head'), (50, 15)], 5, 5))
p.add(p.m(capsule([(68.5, 26), (72, 25), (77, 25.5)], 2.6, 1.8), capsule([(70, 26), (68.5, 28.5)], 1.4, 1.1), capsule([(75, 25.5), (76.5, 28)], 1.4, 1.1)), ROOT, local=True, crescent=0)
p.add(p.m(hd, snout), SOIL)
p.line([(55, 13), (63, 14.8), (69, 17.8)], SOIL[0])                           # light along the top of the snout
p.line([(56, 16.5), (63, 18.3), (68, 21)], SOIL[2])
p.add(p.m(ell(72.6, 24, 1.6, 1.5)), RUSS, local=True, crescent=0)               # the jaws at the tip

p = R.part('eyes')
H.button_eye(p, 52.8, 13.6, 1.9)

for pid, pts in (('antL', [(63, 16), (61.5, 11), (64.5, 8)]), ('antR', [(64, 16.5), (66.5, 13), (70, 12)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 1.6, 1.3)), RUSS, crescent=0)
    tx, ty = pts[-1]
    p.add(p.m(rell(tx + .5, ty - .3, 2.1, 1.5, -30)), RUSS, local=True, crescent=0)

R.save()
