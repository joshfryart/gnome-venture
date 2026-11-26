#!/usr/bin/env python3
"""stamp-herb: a herb sprig with three leaves and a bud, on a moss ring."""
from stamp_kit import *  # noqa

b = badge('#3f7a32')
g = Group()
g.add(mask(poly([(20, 52), (44, 52), (40, 45), (24, 45)])), ('#7a4a1f', '#5a3416', '#9a6232'))
g.add(mask(thick_path([(32, 46), (32, 30), (34, 18)], 2.4)), ('#4a8a3a', '#2f5a2a', '#7ab55c'), flat=True)
g.add(mask(poly([(31, 40), (24, 39), (16, 33), (13, 26), (20, 27), (27, 31)])), ('#5aa04a', '#2f6a3a', '#9ad07a'))
g.add(mask(poly([(33, 34), (40, 34), (48, 28), (51, 20), (43, 21), (37, 26)])), ('#5aa04a', '#2f6a3a', '#9ad07a'))
g.add(mask(ell(34, 15, 4.5, 5.5)), ('#8a7ab0', '#5e4e8a', '#b8acd8'))
g.line([(29, 37), (19, 30)], '#2f6a3a')
g.line([(36, 31), (46, 24)], '#2f6a3a')
save('herb', [b, g])
