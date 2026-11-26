#!/usr/bin/env python3
"""old-gneiss "Old Gneiss" (golem rig, front view, boss, 87 x 109, 7 parts): Chapter III-a mini-boss of the Echo Hollow.
"A rockshell beetle with a back like a boulder. He knocked on the stone for so long that he forgot why." Grey veins run through
his shell; when the fight goes badly his shell cracks. Cured: a large, sleepy gentleman who likes warm walls.
A felt beetle standing upright like an old gentleman: a huge boulder shell of banded pink-and-grey gneiss rising round behind his
shoulders, split down the middle by the elytra seam, with grey blight veins creeping through it, and a pale segmented belly of
five sewn plates in front (body); a domed rock pronotum helmet with a blunt worn knocking horn on top, long elbowed antennae with
club tips sweeping out to both sides, a dark face plate with two curved mandibles and a little gold monocle (head); sleepy
half-lidded button eyes (eyes); dark chitin forelegs, three segments with a spine and two hooked toes (armL / armR); short thick
chitin legs with a knee ring and hooked feet (legL / legR).
Silhouette: tall, horn plus antennae on top, a round boulder back (Holler is low and wide, the Moss Golem round and mossy)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from rigkit import *  # noqa

R = Rig('old-gneiss')
GN = ('#ebe6e0', '#b4adab', '#86807f', '#5a5459')         # grey gneiss
BAND = ('#e6c4b8', '#c99a8e', '#a07670', '#6e4e50')       # its pink feldspar bands
VEIN = '#4f5866'                                           # dark grey blight veins
FACE = ('#9c8ca0', '#6e5e76', '#54465c', '#3a2c40')
BELLY = ('#efe6d6', '#cdbfa9', '#a8987f', '#76664f')
CHIT = ('#7a6a80', '#4f4058', '#3a2c40', '#2a1a10')       # dark plum chitin
G = R.ground                                               # 104
cx = 43.5

for pid in ('legL', 'legR'):
    p = R.part(pid)
    x, y = R.pv(pid); s = -1 if pid == 'legL' else 1
    p.add(p.m(capsule([(x, y - 2), (x + s * 2, G - 6)], 14, 11), ell(x + s * 2, G - 3, 9, 3.6)), CHIT)
    p.line([(x - 6 + s * 1, y + 7), (x + 6 + s * 1, y + 7.5)], CHIT[0])   # knee ring
    for dx in (-5, 5):                                                     # two hooked toes
        p.add(p.m(capsule([(x + s * 2 + dx, G - 3), (x + s * 2 + dx * 1.45, G - .5)], 3.2, 2)), CHIT, local=True, crescent=0)

p = R.part('body')
shell = union(ell(cx, 70, 34, 21), ell(13, 58, 7.5, 7), ell(74, 58, 7.5, 7), ell(22, 50, 11, 10), ell(65, 50, 11, 10), ell(30, 46, 8, 7), ell(57, 46, 8, 7))
p.add(p.m(shell), GN, stitch=GN[3])
for k, yy in enumerate((47, 56, 65, 74, 83)):                                  # wavy gneiss bands across the boulder
    band = lambda x, y, yy=yy, k=k: abs(y - yy - 2.2 * __import__('math').sin(x / 5.0 + k)) < 1.3
    p.add(p.m(inter(shell, band)), BAND, flat=True)
p.line([(cx, 50), (cx, 55)], GN[3])                                       # the elytra seam above the belly
belly = inter(ell(cx, 76, 12.5, 15), lambda x, y: y > 61)
p.add(p.m(belly), BELLY, local=True)
for yy in (67, 72, 77, 82):                                                # sewn belly plates
    w = 11.5 - abs(yy - 76) * .35
    p.line([(cx - w, yy), (cx - 4, yy + 1.2), (cx + 4, yy + 1.2), (cx + w, yy)], BELLY[3])
for pts in (((14, 66), (19, 70), (17, 75), (22, 79)), ((19, 70), (24, 68)), ((70, 63), (66, 68), (69, 72)), ((66, 68), (62, 67)), ((60, 52), (64, 55), (62, 59))):
    p.line(list(pts), VEIN)                                                # grey blight veins

for pid, s in (('armL', -1), ('armR', 1)):
    p = R.part(pid)
    x, y = R.pv(pid)
    knee, wrist = (x + s * 3.5, y + 13), (x + s * 1, y + 25)
    p.add(p.m(ell(x, y + 1, 6, 6), capsule([(x, y), knee], 9, 7.5)), CHIT, crescent=1)
    p.add(p.m(capsule([knee, wrist], 7, 5.5)), CHIT, local=True, crescent=1)
    p.add(p.m(capsule([(knee[0] + s * 2.5, knee[1] + 4), (knee[0] + s * 6, knee[1] + 3)], 2.2, 1.2)), CHIT, local=True, crescent=0)   # spine
    for dx in (-3, 3):
        p.add(p.m(capsule([wrist, (wrist[0] + dx, wrist[1] + 3.5), (wrist[0] + dx * .5, wrist[1] + 6)], 3, 1.6)), CHIT, local=True, crescent=0)
    p.line([(knee[0] - 3, knee[1]), (knee[0] + 3, knee[1])], CHIT[0])

p = R.part('head')
for s in (-1, 1):                                                          # elbowed antennae with club tips
    p.add(p.m(capsule([(cx + s * 10, 26), (cx + s * 22, 20), (cx + s * 31, 9)], 2.6, 2)), CHIT, local=True, crescent=0)
    p.add(p.m(rell(cx + s * 32, 7.5, 3.4, 4.6, s * 30)), CHIT, local=True, crescent=1)
horn = union(capsule([(cx, 30), (cx + 1, 10)], 15, 6.5), ell(cx + 1, 9.5, 4, 3))
p.add(p.m(horn), GN, local=True)                                         # the knocking horn
for yy in (16, 21):
    p.line([(cx - 4 + (yy - 16) * -.3, yy), (cx + 5 + (yy - 16) * .3, yy)], GN[2])
p.add(p.m(ell(cx + 1, 8, 3, 1.4)), BAND, flat=True)                       # its worn flat tip
dome = union(ell(cx, 37, 22, 13), ell(cx, 46, 16, 9))
dm = p.add(p.m(dome), GN, stitch=GN[3])
p.fill({(x, y) for (x, y) in dm if y > 36 and any(n not in dm for n in ((x + 1, y), (x - 1, y), (x, y + 1)))}, GN[3])                               # the helmet's rim, sewn over the shell
p.add(p.m(inter(dome, lambda x, y: abs(y - 27 - 1.6 * __import__('math').sin(x / 4.0)) < 1.1)), BAND, flat=True)
face = inter(ell(cx, 43, 16, 11), lambda x, y: y > 33)
p.add(p.m(face), FACE, local=True)
for s in (-1, 1):                                                          # curved mandibles
    p.add(p.m(capsule([(cx + s * 9, 48), (cx + s * 7, 53.5), (cx + s * 2.5, 55)], 4, 1.8)), CHIT, local=True, crescent=0)
p.line([(cx + 2, 10), (cx + 3, 14), (cx + 1, 18)], VEIN)                  # a vein up the horn
p.line([(28, 31), (31, 34)], VEIN)
mono = minus(ell(52.5, 39, 6, 5.6), ell(52.5, 39, 4.6, 4.2))
p.add(p.m(mono), GOLD, flat=True)
p.line([(57, 43), (58, 47), (59, 51)], GOLD[2])                            # the monocle's chain
p.add(p.m(ell(29, 45, 2.4, 1.2)), (BLUSH,) * 4, flat=True)

p = R.part('eyes')
for ex in (36.5, 52.5):
    p.add(p.m(ell(ex, 39, 4.3, 3.9)), (INK,) * 4, flat=True)
    p.add(p.m(ell(ex, 39, 3.3, 2.9)), (CREAM,) * 4, flat=True)
    p.add(p.m(rect(ex - .5, 38, ex + 1.5, 42)), (INK,) * 4, flat=True)
    p.px(ex - 1, 40, CREAM)
    p.add(p.m(inter(ell(ex, 39, 4.3, 3.9), lambda x, y: y < 38.4)), (GN[2],) * 4, flat=True)   # sleepy lid
    p.line([(ex - 4.5, 38), (ex + 4, 38)], INK)

R.save()
