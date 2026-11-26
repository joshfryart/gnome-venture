#!/usr/bin/env python3
"""stamp-workshop: a big brass cog on a workbench, on a wood ring."""
from stamp_kit import *  # noqa

b = badge('#7a4a1f')
g = Group()
g.add(mask(rect(12, 44, 52, 49)), ('#b07a3a', '#7a4a1f', '#d9a35a'), stitch='#f5cf6a', depth=1)
g.add(mask(rect(15, 49, 19, 53), rect(45, 49, 49, 53)), ('#7a4a1f', '#5a3416', '#9a6232'))


def cog(x, y, cx=32.5, cy=27.5):
    dx, dy = x - cx, y - cy
    r = math.hypot(dx, dy)
    a = math.atan2(dy, dx) + math.pi / 8
    tooth = (a % (math.pi / 4)) < math.pi / 8
    return r < (15 if tooth else 11.5)


c = Group()
c.add(mask(cog, minus=[ell(32.5, 27.5, 4.5, 4.5)]), ('#e0a830', '#a8721a', '#f5d070'), stitch='#7a4a1f', depth=4)
c.add(mask(ell(32.5, 27.5, 4.5, 4.5), minus=[ell(32.5, 27.5, 2, 2)]), ('#7a5a30', '#5a3a18', '#9a7a48'), flat=True)
save('workshop', [b, g, c])
