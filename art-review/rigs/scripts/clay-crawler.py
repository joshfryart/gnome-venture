#!/usr/bin/env python3
"""clay-crawler "Clay Crawler" (worm rig, 55 x 26, 6 parts): "A pale little grub in a crust of grey-brown clay. It crawls along the wall
and does not know why it is cross." (small, trek claybound tunnels, level 17; Wet Clay)
A small soft felt grub, pale cream-pink underneath, wearing a cracked crust of grey-brown clay on its back like a badly fitted coat:
s1..s4 are fat stitched grub rings, each with its own crust plate (lumpy clods break the top outline, dark crack lines, a wet sheen),
the pale grub showing at the belly with tiny stubby prolegs; the tail ring (s4) tapers to a pale point. head: a small pale grub head with a
smear of clay on the crown and little dark mandibles. eyes: one round button eye under a heavy cross brow (it does not know why).
Segments are lit against the whole grub (ref=) and sewn together where each ring overlaps the next."""
import importlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_basalt-borer')

R = Rig('clay-crawler')
GRUB = ('#fff6ea', '#f6dccb', '#dcb49c', '#b08670')
CLAY = ('#c9b8a0', '#9c8670', '#76624e', '#4e3f32')
WET = '#ddd0bc'
FLOOR = lambda x, y: y < 21.6

SEG = {'s1': ell(40, 14.6, 5.8, 5.6),
       's2': union(ell(33, 13.6, 6.4, 6.8), ell(27, 12.5, 3.5, 4)),
       's3': union(ell(24.5, 13.6, 6.4, 6.8), ell(17.5, 14.5, 3.5, 3.5)),
       's4': union(ell(16.5, 16, 5.4, 5), capsule([(13, 18), (7.5, 19.4)], 5.4, 3))}
CRUST = {'s1': (lambda x, y: y < 15.5 - (x - 40) * .3, [(38.5, 9.6, 2.8, 1.4)]),
         's2': (lambda x, y: y < 14, [(31, 7.4, 3, 1.4), (35.6, 7.9, 1.8, 1.2)]),
         's3': (lambda x, y: y < 14, [(22.6, 7.4, 2.8, 1.4), (27.2, 7.2, 2, 1.3)]),
         's4': (lambda x, y: y < 16.2 + (16 - x) * .25, [(15.5, 11.4, 2.4, 1.2)])}
UNDER = {'s2': 's1', 's3': 's2', 's4': 's3'}
CRACK = {'s1': [[(39, 10.5), (40, 12), (39, 13.5)]], 's2': [[(33, 8), (32, 10), (33.5, 12)], [(32, 10), (29.5, 11)]],
         's3': [[(24.5, 8), (25.5, 10), (24, 12.5)], [(25.5, 10), (28, 11)]], 's4': [[(17, 12.5), (16, 14.5)]]}

ALL = {}
for pid in SEG:
    cr, clods = CRUST[pid]
    ALL[pid] = union(SEG[pid], *[ell(*c) for c in clods])
REF = R.part('s1').m(*[inter(m, FLOOR) for m in ALL.values()])

for pid in SEG:
    p = R.part(pid)
    cr, clods = CRUST[pid]
    mk = p.add(p.m(inter(ALL[pid], FLOOR)), GRUB, ref=REF)
    PL = {'s1': ell(39.6, 13.6, 4.6, 5.2), 's2': ell(32.6, 12.6, 5.2, 6.4), 's3': ell(24.2, 12.6, 5.2, 6.4), 's4': ell(16.4, 15, 4.4, 4.6)}[pid]
    crust = inter(ALL[pid], FLOOR, union(inter(PL, cr), *[ell(*c) for c in clods]))
    p.add(p.m(crust), CLAY, ref=REF)
    # the crust's ragged lower edge, a dark seam line, and a wet sheen
    cm = p.m(crust)
    for (x, y) in cm:
        if (x, y + 1) not in cm and (x, y + 1) in mk:
            p.px(x, y, CLAY[3])
            if (x * 7) % 5 == 0:
                p.px(x, y + 1, CLAY[2])
    for pts in CRACK[pid]:
        p.line(pts, CLAY[3])
    for (cx, cy, rx, ry) in clods:
        p.px(cx - .5, cy - .5, WET)
    if pid in UNDER:
        H.seam_over(p, mk, R.part('s1').m(ALL[UNDER[pid]]), GRUB[3])
    cx = {'s1': 40, 's2': 33, 's3': 24.5, 's4': 16.5}[pid]
    p.line([(cx + 4.2, 15), (cx + 5, 17.5), (cx + 4.4, 20)], GRUB[3])           # a soft ring crease on the pale belly
    if pid in ('s1', 's2', 's3'):            # tiny stubby prolegs
        bx = {'s1': 40, 's2': 33, 's3': 24.5}[pid]
        for x in (bx - 2, bx + 1.5):
            p.add(p.m(ell(x, 20.4, 1.1, 1.1)), GRUB, local=True, crescent=0)
            p.px(x - .5, 21, GRUB[3])

# head: small pale grub head, clay smear on the crown, dark mandibles
p = R.part('head')
hx, hy = R.pv('head')
hd = union(ell(46.6, 13.4, 4.7, 5), capsule([(hx, hy + .5), (44, 14)], 5, 5))
HEAD = ('#fff0dc', '#f2c9a8', '#d49e7c', '#a8705a')
hm = p.add(p.m(hd), HEAD)
H.seam_over(p, hm, R.part('s1').m(SEG['s1']), HEAD[3])
p.add(p.m(inter(hd, lambda x, y: y < 9.8 and x < 45.5)), CLAY, local=True)
p.add(p.m(ell(49.5, 9.3, 1.4, 1.1)), CLAY, local=True, crescent=0)                      # a clay clod stuck on the head
p.add(p.m(capsule([(50, 16.5), (51.5, 18), (50.3, 19)], 1.6, 1.2)), ('#8f4f24', '#5a2c14', '#3f1c10', '#3f1c10'), flat=True)
p.px(49, 15, BLUSH); p.px(48, 15, BLUSH)
p.line([(43, 17), (46, 17.8)], GRUB[3])

p = R.part('eyes')
ex, ey = R.pv('eyes')
H.button_eye(p, ex + .2, ey + .8, 1.7, brow=[(43.5, 7.6), (48.5, 9.2)])

R.save()
