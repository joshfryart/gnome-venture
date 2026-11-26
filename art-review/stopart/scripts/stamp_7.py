#!/usr/bin/env python3
"""stamp-mill: a windmill with four felt sails and a door, on a wheat ring."""
from stamp_kit import *  # noqa

b = badge('#9a6b3f')
g = Group()
g.add(mask(poly([(24, 50), (27, 26), (37, 26), (40, 50)])), ('#c9a070', '#9a7048', '#e8c898'), stitch='#7a4a1f', depth=2)
g.add(mask(poly([(25, 27), (32, 20), (39, 27)])), ('#a8301a', '#7a2014', '#d8583a'))
g.add(mask(rect(29, 42, 35, 50)), ('#5a3416', '#3a2210', '#7a4a1f'))
s = Group()
cx, cy = 32, 25
for a in (45, 135, 225, 315):
    r = math.radians(a)
    ux, uy = math.cos(r), math.sin(r)
    vx, vy = -uy, ux
    p = lambda t, w: (cx + ux * t + vx * w, cy + uy * t + vy * w)  # noqa: E731
    s.add(mask(poly([p(4, -1), p(19, -1), p(19, 5.5), p(5, 5.5)])), ('#e8c898', '#b8905a', '#f8e4bc'))
    s.add(mask(thick_path([p(2, 0), p(20, 0)], 1.8)), ('#7a4a1f', '#5a3416', '#9a6232'), flat=True)
s.add(mask(ell(32, 25, 3, 3)), ('#e8a317', '#b07a10', '#f5cf6a'))
save('mill', [b, g, s])
