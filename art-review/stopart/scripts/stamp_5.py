#!/usr/bin/env python3
"""stamp-jetty: a plank jetty on posts over water, with a mooring post and rope, on a teal ring."""
from stamp_kit import *  # noqa

b = badge('#1d7378')
inner = ell(32, 32, 23.5, 23.5)
w = Group(outline=False)
w.add(mask(lambda x, y: inner(x, y) and y >= 38), ('#3f7fc8', '#2a5a9a', '#7ab0e0'))
for x in range(10, 56, 7):
    w.px(x, 44, '#a9d6ea'); w.px(x + 1, 44, '#a9d6ea'); w.px(x + 4, 50, '#a9d6ea')
g = Group()
for px0 in (14, 23, 32):
    g.add(mask(rect(px0, 33, px0 + 3, 49)), ('#7a4a1f', '#5a3416', '#9a6232'))
g.add(mask(rect(9, 29, 42, 35)), ('#c08a48', '#8a5a28', '#e0b070'), stitch='#7a4a1f', depth=1)
for x in (17, 25, 33):
    g.line([(x, 30), (x, 33)], '#8a5a28')
g.add(mask(rect(41, 17, 46, 47)), ('#9a6232', '#6a4020', '#c08a48'))
g.add(mask(rect(40, 15, 47, 18)), ('#7a4a1f', '#5a3416', '#9a6232'))
g.add(mask(thick_path([(44, 22), (49, 26), (51, 33), (49, 38)], 2)), ('#e6d6a0', '#b8a070', '#f4ead0'), flat=True)
g.add(mask(rect(41, 23, 46, 26)), ('#e6d6a0', '#b8a070', '#f4ead0'), flat=True)
save('jetty', [b, w, g])
