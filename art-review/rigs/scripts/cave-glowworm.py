#!/usr/bin/env python3
"""cave-glowworm "Cave Glowworm" (worm rig, 55 x 25, 6 parts): "Lovely to look at. Sticky to touch." (small, lv 5, mountain and
rainforest caves, out at night; Glow Silk, Glowing Bead)
A felt glowworm larva crawling right: a soft, pale, ringed grub body sewn from three segments with a gentle hump (s1 behind the head,
s2, s3; each a ring seam at its front end where it sits on the one ahead), a string of glowing silk beads draped along its flank like a
necklace (s2, s3), and the famous lamp: the tail end is a big round glowing teal lantern with a bright core and sparkle stitches (s4);
a small dark-brown head capsule with tiny mandibles and a sticky silk drool line ending in a glowing bead (head); two button eyes
(eyes). Silhouette: a short glowing tube with a lit bulb on the end, lower and softer than the rest of the batch."""
import importlib, math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rigkit import *  # noqa
H = importlib.import_module('_crawler_shale-slater')

R = Rig('cave-glowworm')
GRUB = ('#e6ecd6', '#bcc8a6', '#8e9c7a', '#5c6a4e')
GLOW = ('#ffffff', '#a8f5dc', '#3fd0b0', '#1f8a86')
HEAD = ('#a8826a', '#7a5a46', '#5a4032', '#3a2820')
SILK = '#fff8e0'
P = {k: R.pv(k) for k in R.ids}

# three plump felt rings, each a ball sewn on the one ahead of it (its shaded front edge is the seam), with a hump at s2
SEGS = {'s1': (38, 13.5, 6.5, 6), 's2': (30.5, 12, 6.8, 7), 's3': (21.5, 12.6, 7.2, 6.6)}
for pid, (cx, cy, rx, ry) in SEGS.items():
    p = R.part(pid)
    seg = ell(cx, cy, rx, ry)
    p.add(p.m(seg), GRUB, crescent=2)
    p.fill(p.m(inter(seg, lambda x, y, cy=cy, ry=ry: y > cy + ry * .55)), GRUB[2])         # shaded belly
    p.line([(cx - 1, cy - ry + 2), (cx + 1.5, cy - ry + 1.6)], GRUB[0])                     # a soft highlight
    if pid in ('s2', 's3'):   # glowing silk beads draped along the flank
        xs = [cx - rx + 2, cx, cx + rx - 2]
        ys = [cy - .5, cy + 2, cy - .5]
        H.stitch_line(p, list(zip(xs, ys)), SILK, gap=1)
        for x, y in ((cx - 2.6, cy + 1.6), (cx + 2.6, cy + 1.6)):
            p.add(p.m(ell(x, y, 1.8, 1.8)), GLOW, local=True, crescent=0)
            p.px(x - 1, y - 1, '#ffffff')

# s4: the last grub ring and the tail lamp
p = R.part('s4')
lamp = ell(8.5, 13.6, 7, 6)
p.add(p.m(lamp), GLOW, stitch=GLOW[3])
p.add(p.m(ell(7.6, 12.8, 3.4, 2.5)), ('#ffffff', '#ffffff', GLOW[1], GLOW[1]), flat=True)    # the bright core
p.add(p.m(ell(14.5, 14, 4.2, 5.2)), GRUB, crescent=1, local=True)
p.fill(p.m(inter(ell(14.5, 14, 4.2, 5.2), lambda x, y: x < 13.5)), GLOW[1])      # lamp light spilling onto the last ring
p.px(13, 11, GRUB[0])
for x, y in ((4, 10), (11, 17)):
    p.px(x, y, '#ffffff')

# head: dark head capsule, mandibles, a sticky drool line with a glowing bead
p = R.part('head')
hd = union(ell(45.5, 12.6, 6.2, 6.2), capsule([P['head'], (44, 13)], 6, 6))
p.add(p.m(capsule([(50.5, 15.5), (50.8, 19)], 1, 1)), (SILK,) * 4, flat=True)
p.add(p.m(ell(51, 18.4, 1.4, 1.4)), GLOW, local=True, crescent=0)
p.add(p.m(hd), HEAD, stitch=None)
p.add(p.m(capsule([(49.5, 15.5), (51.5, 16), (52, 14.8)], 1.6, 1.2)), darker(HEAD), local=True, crescent=0)   # mandible
p.add(p.m(ell(47.5, 15.4, 1.2, .9)), (BLUSH,) * 4, flat=True)
p.line([(41, 9), (40.5, 13), (41, 17)], HEAD[3])          # the collar seam

p = R.part('eyes')
H.button_eye(p, 43.9, 10.3, 1.6, look=1)
H.button_eye(p, 48.3, 10.6, 1.6, look=1)

R.save()
