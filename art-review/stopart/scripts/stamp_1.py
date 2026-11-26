#!/usr/bin/env python3
"""stamp-camp: a felt tent with a small campfire, on an ember ring."""
from stamp_kit import *  # noqa

b = badge('#b8481e')
inner = ell(32, 32, 23.5, 23.5)
g = Group()
# ground strip
g.add(mask(lambda x, y: inner(x, y) and y >= 44), '#7a9a3a')
# tent
g.add(mask(poly([(10, 46), (24, 16), (38, 46)])), '#c9853a', stitch='#f2e4c0', depth=2)
g.add(mask(poly([(19, 46), (24, 33), (29, 46)])), ('#4a2c1a', '#3a2216', '#5c3a24'), flat=True)
g.line([(24, 14), (24, 18)], '#7a4a1f')
f = Group()
# logs
f.add(mask(thick_path([(38, 47), (52, 43)], 3)), ('#7a4a1f', '#5a3416', '#9a6232'))
f.add(mask(thick_path([(38, 43), (52, 47)], 3)), ('#8a5428', '#5a3416', '#a87038'))
# flame
f.add(mask(poly([(39, 43), (40, 36), (43, 38), (45, 28), (48, 35), (50, 33), (51, 43)])), ('#e0482a', '#a8241f', '#f08a4a'))
f.add(mask(poly([(42, 43), (43, 38), (45, 40), (46, 35), (48, 43)])), ('#f0c030', '#e8a317', '#f8e090'), flat=True)
save('camp', [b, g, f])
