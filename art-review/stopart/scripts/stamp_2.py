#!/usr/bin/env python3
"""stamp-ferry: a little sailboat on blue water, on a water ring."""
from stamp_kit import *  # noqa

b = badge('#2f6a9a')
inner = ell(32, 32, 23.5, 23.5)
w = Group(outline=False)
w.add(mask(lambda x, y: inner(x, y) and y >= 43), ('#3f7fc8', '#2a5a9a', '#7ab0e0'))
for x in range(10, 56, 6):
    w.px(x, 47, '#a9d6ea'); w.px(x + 1, 47, '#a9d6ea')
    w.px(x + 3, 51, '#a9d6ea')
g = Group()
g.add(mask(thick_path([(32, 13), (32, 39)], 2.2)), ('#7a4a1f', '#5a3416', '#9a6232'), flat=True)
g.add(mask(poly([(34, 14), (48, 37), (34, 37)])), ('#f4f0e4', '#c9c5bc', '#ffffff'), stitch='#c9a96e', depth=2)
g.add(mask(poly([(30, 18), (30, 37), (19, 37)])), ('#d6322b', '#a8241f', '#f0705a'))
g.add(mask(poly([(31, 12.5), (37, 14.5), (31, 16.5)])), ('#e8a317', '#b07a10', '#f5cf6a'), flat=True)
g.add(mask(poly([(12, 38), (52, 38), (46, 47), (18, 47)])), ('#b07a3a', '#7a4a1f', '#d9a35a'))
g.line([(17, 41), (47, 41)], '#f2e4c0')
for x in range(17, 48, 2):
    g.over.pop((x, 41), None)
save('ferry', [b, w, g])
