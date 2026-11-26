#!/usr/bin/env python3
"""stamp-inn: a cosy house with red roof, chimney, door and two lit windows, on a petal ring."""
from stamp_kit import *  # noqa

b = badge('#b0485e')
g = Group()
g.add(mask(rect(38, 14, 43, 24)), ('#8a5a40', '#5a3a28', '#b07a58'))
g.add(mask(rect(14, 29, 50, 49)), ('#f0c89a', '#c9a070', '#fbe4c4'), stitch='#c9853a', depth=2)
g.add(mask(poly([(9, 31), (32, 12), (55, 31), (51, 33), (32, 18), (13, 33)])), ('#c8322a', '#8e1a20', '#e8604a'))
g.add(mask(poly([(16, 31), (32, 18.5), (48, 31)])), ('#c8322a', '#8e1a20', '#e8604a'), flat=True)
g.add(mask(rect(28, 37, 36, 49)), ('#7a4a1f', '#5a3416', '#9a6232'))
g.px(34, 43, '#e8a317')
for x0 in (18, 40):
    g.rectpx(x0, 34, x0 + 6, 40, '#2a1a10')
    g.rectpx(x0 + 1, 35, x0 + 5, 39, '#f5cf6a')
    g.rectpx(x0 + 1, 37, x0 + 5, 38, '#e8a317')
    g.rectpx(x0 + 3, 35, x0 + 4, 39, '#e8a317')
g.add(mask(rect(11, 49, 53, 52)), ('#9a6b3f', '#74462a', '#c9a96e'))
save('inn', [b, g])
