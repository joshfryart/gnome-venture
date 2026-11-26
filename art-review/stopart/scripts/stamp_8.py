#!/usr/bin/env python3
"""stamp-orchard: a round apple tree with red apples, on a leaf ring."""
from stamp_kit import *  # noqa

b = badge('#2f6a3a')
g = Group()
g.add(mask(rect(29, 34, 35, 50)), ('#8a5428', '#5a3416', '#a87038'))
g.add(mask(rect(20, 49, 44, 52)), ('#6a9a3a', '#4a7a2a', '#9ac060'))
g.add(mask(thick_path([(32, 40), (38, 34)], 2.4)), ('#8a5428', '#5a3416', '#a87038'), flat=True)
g.add(mask(ell(32, 25, 16, 13.5)), ('#5aa04a', '#2f6a3a', '#9ad07a'), stitch='#3f8a3a', depth=2)
a = Group()
for (x, y) in ((24, 21), (38, 19), (35, 30), (24, 31)):
    a.add(mask(ell(x, y, 3.3, 3.3)), ('#d6322b', '#a8241f', '#f0705a'))
save('orchard', [b, g, a])
