#!/usr/bin/env python3
"""stamp-market: a stall with red and cream striped awning, fruit on the counter, on a gold ring."""
from stamp_kit import *  # noqa

b = badge('#c8901a')
g = Group()
g.add(mask(rect(14, 25, 17, 48), rect(47, 25, 50, 48)), ('#7a4a1f', '#5a3416', '#9a6232'))
g.add(mask(rect(12, 38, 52, 49)), ('#b07a3a', '#7a4a1f', '#d9a35a'), stitch='#f5cf6a', depth=1)
# awning: stripes
for i in range(6):
    x0 = 11 + i * 7
    col = ('#d6322b', '#a8241f', '#f0705a') if i % 2 == 0 else ('#f4f0e4', '#c9c5bc', '#ffffff')
    g.add(mask(lambda x, y, x0=x0: x0 <= x < x0 + 7 and 14 <= y < 24 and (y - 14) * 1.0 >= 0
               and x >= 11 + (24 - y) * 0.25 and x < 53 - (24 - y) * 0.25,
               ell(x0 + 3.5, 24, 3.6, 3.4)), col, flat=False)
# fruit
g.add(mask(ell(22, 35, 3.6, 3.6)), ('#d6322b', '#a8241f', '#f0705a'))
g.add(mask(ell(31, 35, 3.6, 3.6)), ('#f0a020', '#c06a10', '#f8d060'))
g.add(mask(ell(41, 35.5, 4.2, 3.2)), ('#8ab83a', '#5a8a2a', '#b8e070'))
g.px(22, 31, '#2f6a3a'); g.px(31, 31, '#2f6a3a')
save('market', [b, g])
