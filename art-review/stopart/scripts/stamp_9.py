#!/usr/bin/env python3
"""stamp-shrine: a red torii gate with a dusk-purple top beam and stone feet, on a dusk ring."""
from stamp_kit import *  # noqa

b = badge('#4e3a8a')
g = Group()
g.add(mask(rect(19, 22, 24, 47), rect(40, 22, 45, 47)), ('#c8322a', '#8e1a20', '#e8604a'))
g.add(mask(rect(15, 27, 49, 31)), ('#c8322a', '#8e1a20', '#e8604a'))
g.add(mask(rect(30, 21, 34, 27)), ('#c8322a', '#8e1a20', '#e8604a'))
g.add(mask(poly([(12, 15), (20, 18), (44, 18), (52, 15), (51, 20), (45, 22), (19, 22), (13, 20)])), ('#5e4aa0', '#3a2a6a', '#8a78c8'), stitch='#e8a317', depth=1)
g.add(mask(rect(17, 46, 26, 51), rect(38, 46, 47, 51)), ('#8a8a90', '#5a5a60', '#b8b8c0'))
save('shrine', [b, g])
