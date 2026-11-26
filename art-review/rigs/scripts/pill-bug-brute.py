#!/usr/bin/env python3
"""pill-bug-brute "Pill Bug Brute" (bug.beetle rig, 63 x 38, 8 parts): "Rolls into a ball, then rolls into you." (trek, medium, L16; Beetle Shell)
A hefty felt pill bug: a tall round dome of slate-violet armour (body) sewn from seven curved plates, each with a pale rolled rim
on its back edge, so the side reads as stacked bands ready to curl into a ball; the plate ends make a scalloped skirt, and a little
tail fan pokes out at the back. A brute: a mended dent on the shell (a mustard felt patch with cross stitches). Under the skirt,
three pairs of short stout legs (leg1 back, leg2 middle, leg3 front; near leg pale, far leg dark). The head (head) is a small blunt
face tucked under the front plate, with a scowling button eye (eyes) and two elbowed feelers (antL up, antR forward)."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_giant-centipede')

R = Rig('pill-bug-brute')
G = R.ground + .5
SHELL = ('#c4c4dc', '#8e8eb4', '#66668c', '#42425e')
RIMC = ('#e4e4f2', '#c4c4dc', '#a2a2c2', '#66668c')
LEGN = ('#b4b4cc', '#8a8aa8', '#62627e', '#42425e')
LEGF = darker(LEGN)
FACE = ('#8c8cae', '#6c6c90', '#505072', '#34344c')
PATCH = ('#f5cf6a', '#e8a317', '#b87a14', '#7a4a1f')
CX, CY, RX, RY, SKIRT = 27.6, 19.4, 18.4, 17, 24.4

# body: the dome, plates with rolled rims, scalloped skirt, tail fan, the mended patch
p = R.part('body')
cuts = [14.5, 20.5, 26.5, 32.5, 38.5]           # plate boundaries along the skirt (x at the bottom)
def bound(k):
    """the k-th plate edge: an arc from the dome top (all edges lean toward the middle) down to the skirt"""
    xb = cuts[k]
    return lambda x, y: x < xb + (CX - xb) * .28 * (1 - (y - 2.4) / (SKIRT - 2.4)) - 1.6 * math.sin(math.pi * min(1, max(0, (y - 2.4) / (SKIRT - 2.4))))
dome = inter(ell(CX, CY, RX, RY), lambda x, y: y < SKIRT)
lobes = union(*[ell((a + b) / 2, SKIRT + .2, (b - a) / 2 + .1, 2.1) for a, b in zip([9.6] + cuts, cuts + [46.4])])
fan = union(ell(10.2, 22.6, 3, 2.4), ell(8.6, 21, 1.8, 1.6))
p.add(p.m(fan), darker(SHELL), local=True)
shell = union(dome, inter(lobes, ell(CX, CY + 1.5, RX + .2, RY)))
mk = p.add(p.m(shell), SHELL, stitch=None)
for k in range(len(cuts)):                            # a pale rolled rim just behind each plate edge, then the dark seam
    f = bound(k)
    rim = {q for q in mk if f(q[0] + .5, q[1] + .5) and not f(q[0] + 1.5, q[1] + .5)}
    p.fill(rim, RIMC[0] if k % 2 else RIMC[1])
    if k % 2:                                         # every other plate a shade darker, so the bands read at game scale
        nxt = bound(k + 1) if k + 1 < len(cuts) else (lambda x, y: x < 99)
        H.blob(p, {q for q in mk if not f(q[0] + .5, q[1] + .5) and nxt(q[0] - .5, q[1] + .5) and q not in rim and q[1] + .5 < SKIRT - 1.2}, ('#9c9cc0', '#74749c', '#565678', '#42425e'))
    seam = {q for q in mk if not f(q[0] + .5, q[1] + .5) and f(q[0] - .5, q[1] + .5)}
    p.fill(seam, SHELL[3])
p.fill({q for q in mk if q[1] + .5 > SKIRT - 1.2}, SHELL[2])  # the skirt shadow
patch = p.m(rell(31.5, 9.5, 3.6, 2.8, -15)) & mk
H.blob(p, patch, PATCH)
for (x, y) in ((29.5, 8), (31.5, 9.5), (33.5, 11)):
    p.px(x, y, PATCH[3]); p.px(x + 1, y + 1, PATCH[3]); p.px(x + 1, y - 1 + 2 * 0, PATCH[3])
p.pxs([(16, 7), (17, 6), (22, 4)], RIMC[0])         # felt highlights on the dome

# legs: short stout pairs under the skirt (far dark, near pale), little hooked feet
for pid, lean in (('leg1', -1), ('leg2', 0), ('leg3', 1)):
    p = R.part(pid)
    x, y = R.pv(pid)
    H.leg(p, [(x + 2, y - .5), (x + 2.6 + lean * .6, y + 7), (x + 3.4 + lean, G - .6)], [2.6, 2.3, 1.8], LEGF)
    H.leg(p, [(x - .6, y - .5), (x - 1.2 + lean * .6, y + 7.4), (x - 1.4 + lean * 1.4, G - .6)], [3, 2.6, 2], LEGN)
    p.add(p.m(capsule([(x - 1.4 + lean * 1.4, G - .6), (x + .4 + lean * 1.4, G - .4)], 1.8, 1.4)), LEGN, local=True, crescent=1)

# head: a small blunt face tucked under the front plate
p = R.part('head')
hp = R.pv('head')
face = union(ell(48.6, 22.2, 5.6, 4.8), capsule([hp, (46, 22.4)], 5, 6.4))
p.add(p.m(face), FACE)
p.add(p.m(inter(ell(52.6, 24.2, 2.6, 2), ell(48.6, 22.2, 5.6, 4.8))), (FACE[0], FACE[0], FACE[1], FACE[2]), local=True, crescent=0)
p.line([(54, 25.5), (51.5, 26)], FACE[3])           # a grim little mouth
p.pxs([(51, 23), (52, 23)], BLUSH)
p.add(p.m(capsule([(53, 26.5), (54.6, 27.2)], 1.6, 1.2)), LEGF, local=True, crescent=0)   # mouthpart

# eyes: scowling button eye under a slanted brow
p = R.part('eyes')
H.button_eye(p, 49.4, 19.9, r=1.7, look=1)
p.line([(46.5, 17.2), (49, 17.6), (52, 18.4)], INK)

# antennae: elbowed feelers, antL up (far, dark), antR forward (near, pale)
p = R.part('antL')
x, y = R.pv('antL')
H.leg(p, [(x, y), (x - .8, y - 5), (x + .6, y - 9.6)], [1.8, 1.6, 1.3], LEGF)
p = R.part('antR')
x, y = R.pv('antR')
H.leg(p, [(x, y), (x + 3.2, y - 3.4), (x + 7.6, y - 4.4)], [1.9, 1.6, 1.3], LEGN)
p.add(p.m(ell(x + 8, y - 4.4, 1.2, 1.1)), LEGN, local=True, crescent=0)

R.save()
