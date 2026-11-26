#!/usr/bin/env python3
"""stag-beetle-patrol "Stag Beetle Patrol" (bug.beetle rig, 109 x 50, 8 parts): "Captain Bracken's old watch, sick with blight and
still walking its beat." (trek boss pool, level 18; Beetle Shell, Antler Shard)
A big chestnut felt stag beetle on patrol, gone sick: the wing case (body) is a high chestnut oval with a sewn centre seam, crept over
by grey-sage blight mould (dull felt patches with pale spore dots) and one mended patch cross-stitched on; the shoulder shield still
wears the watch's tarnished brass star. A square head (head) carrying the huge antler mandibles, the near one bright, the far one
darker, each with an inner tine; a tired button eye under a heavy lid (eyes); short elbowed antennae (antL / antR); and three long
striding legs (leg1..leg3). Silhouette: the long forward antlers, much bigger and flatter-backed than the other beetles."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_bug_ember-beetle')

R = Rig('stag-beetle-patrol')
CHEST = ('#b8744a', '#8a4a2a', '#663620', '#3f2014')
HORN = ('#e0a070', '#b8643a', '#8a4428', '#4a2414')
BLIGHT = ('#d4d2bc', '#a3a48c', '#7c8070', '#545a50')
BRASS = ('#f5cf6a', '#c9a046', '#9a7430', '#6b4a1f')

for pid, knee, foot in (('leg1', (34, 35), (29.5, 43.5)), ('leg2', (54, 36), (52.5, 43.5)), ('leg3', (72, 35), (78, 43.5))):
    H.leg(R, pid, knee, foot, darker(CHEST), w=(5.4, 4.4, 3.4))

# body: shoulder shield + long high wing case with blight
p = R.part('body')
shield = ell(65, 22.5, 8.5, 9.5)
p.add(p.m(shield), CHEST, local=True)
case = minus(rell(45, 20, 21.5, 14.5, -4), lambda x, y: y > 33.5)
p.add(p.m(case), CHEST, stitch=CHEST[3])
p.fill(p.m(inter(case, lambda x, y: y > 31.5)), CHEST[2])
p.line([(63, 8), (55, 15), (42, 24), (30, 31)], CHEST[3])                        # the wing-case seam
p.fill(p.m(inter(rell(43, 10.5, 12, 2, -12), case)), CHEST[0])                    # felt sheen along the top
mould = union(rell(30, 14.5, 6, 3.5, -30), ell(35.5, 11, 3, 2.2), ell(27, 21.5, 2.6, 2), rell(52, 28, 5, 2.4, 10), ell(57, 9.5, 2.6, 1.8), ell(24.5, 27.5, 2.2, 1.8), ell(59, 25, 2, 1.6))
H.blob(p, p.m(inter(mould, case)), BLIGHT)
for q in ((29, 14), (31, 16), (35, 11), (51, 28), (54, 27), (38, 15), (21, 18), (59, 25), (47, 30)):
    p.px(q[0], q[1], BLIGHT[0])
patch = rect(41, 15, 48, 21)                                                     # a mended felt patch, cross-stitched on
p.fill(p.m(patch), '#b0804e')
for x in (41, 47):
    for y in range(15, 21, 2):
        p.px(x, y, CHEST[3])
for y in (15, 20):
    for x in range(42, 47, 2):
        p.px(x, y, CHEST[3])
p.fill(p.m(ell(60.5, 15, 2.5, 1.2)), CHEST[0])
star = poly([(59.5, 13.5), (60.8, 16.7), (64.3, 17.0), (61.6, 19.2), (62.4, 22.5), (59.5, 20.7), (56.6, 22.5), (57.4, 19.2), (54.7, 17.0), (58.2, 16.7)])
p.add(p.m(star), BRASS, local=True, crescent=0)                                  # the watch's tarnished brass star
p.px(61, 20, BLIGHT[2])

# head: square head + the antlers
p = R.part('head')
hd = union(rell(73.5, 23, 8.5, 7.8, 0), capsule([R.pv('head'), (70, 24)], 9, 9))
far = union(capsule([(78, 27.5), (88, 30), (97, 29.5), (103, 25.5)], 4.6, 2.2), capsule([(91, 29.5), (92, 25.5)], 2.6, 1.6))
p.add(p.m(far), darker(HORN), local=True, crescent=0)                           # the far antler: low, hooking up
p.add(p.m(hd), CHEST)
near = union(capsule([(78, 20), (87, 14), (96, 11.5), (102.5, 13), (104.5, 17)], 5.4, 2.2), capsule([(93, 12.5), (94, 17)], 2.6, 1.6))
p.add(p.m(near), HORN, local=True)                                               # the near antler: high, hooking down
p.line([(81, 18), (87, 14.5), (96, 12)], HORN[0])
p.line([(84, 29), (94, 30)], HORN[3])
p.add(p.m(inter(rell(71, 27, 4, 2, 0), hd)), BLIGHT, local=True, crescent=0)      # blight creeping onto the cheek
p.line([(79, 27.5), (82, 28)], INK)

p = R.part('eyes')
H.button_eye(p, 76, 22, 2.4, lid=CHEST[2])
p.line([(72.5, 19.5), (79.5, 20.2)], INK)

for pid, pts in (('antL', [(73.25, 17.5), (72, 12), (75, 7)]), ('antR', [(77.75, 17.5), (80.5, 13), (85, 11)])):
    p = R.part(pid)
    p.add(p.m(capsule(pts, 2.2, 1.6)), darker(CHEST), crescent=0)
    tx, ty = pts[-1]
    p.add(p.m(ell(tx, ty, 2, 1.6)), darker(CHEST), local=True, crescent=0)

R.save()
