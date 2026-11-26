#!/usr/bin/env python3
"""stamp-spring: a stone-rimmed hot spring pool with three steam curls, on a teal ring."""
from stamp_kit import *  # noqa

b = badge('#2a8a8a')
g = Group()
g.add(mask(lambda x, y: ell(32, 38, 21, 13)(x, y) and y >= 36), ('#8a8a90', '#5a5a60', '#b8b8c0'))
g.add(mask(ell(32, 36, 21, 4.5)), ('#8a8a90', '#5a5a60', '#b8b8c0'))
g.add(mask(lambda x, y: ell(32, 36.5, 17.5, 2.8)(x, y)), ('#3f8fd0', '#2a5a9a', '#a9d6ea'), inset=True)
for x in (20, 30, 40):
    g.px(x, 44, '#5a5a60'); g.px(x + 1, 44, '#5a5a60')
    g.px(x + 4, 41, '#b8b8c0')
s = Group()
for x0 in (22, 32, 42):
    pts = [(x0, 32), (x0 - 3, 28), (x0, 24), (x0 + 3, 20), (x0, 15)]
    s.add(mask(thick_path(pts, 2.6)), ('#e8f4f4', '#a9d6ea', '#ffffff'), flat=True)
save('spring', [b, g, s])
