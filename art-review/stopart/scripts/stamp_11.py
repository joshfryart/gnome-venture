#!/usr/bin/env python3
"""stamp-tower: a stone watchtower with battlements, arched door and a beacon flame, on a slate ring."""
from stamp_kit import *  # noqa

b = badge('#5a6478')
g = Group()
g.add(mask(poly([(21, 50), (23, 26), (41, 26), (43, 50)])), ('#a0a0a8', '#6a6a72', '#c8c8d0'), stitch='#6a6a72', depth=2)
g.add(mask(rect(19, 20, 45, 27), rect(19, 16, 23, 20), rect(27, 16, 31, 20), rect(33, 16, 37, 20), rect(41, 16, 45, 20)),
      ('#8a8a92', '#5a5a62', '#b8b8c0'))
g.add(mask(rect(29, 39, 35, 50), ell(32, 39, 3, 3)), ('#4a2c1a', '#3a2216', '#5c3a24'), flat=True)
g.add(mask(rect(30, 30, 34, 34)), ('#f5cf6a', '#e8a317', '#f8e090'), flat=True)
g.add(mask(rect(17, 49, 47, 52)), ('#6a6a72', '#4a4a52', '#8a8a92'))
f = Group()
f.add(mask(poly([(28, 17), (30, 11), (32, 13), (33, 7), (36, 13), (36, 17)])), ('#e0482a', '#a8241f', '#f08a4a'))
f.add(mask(poly([(30.5, 17), (32, 13), (33.5, 15), (34, 17)])), ('#f0c030', '#e8a317', '#f8e090'), flat=True)
save('tower', [b, g, f])
