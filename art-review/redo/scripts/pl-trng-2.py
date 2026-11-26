"""pl-trng-2 Leaf Raft: edge-TBB keyhole. A green leaf IS the upper piece body (tip = keyhole tab N, keyhole blanks W and E cut into
the leaf), riding on a stump-bark log raft that makes the flat S side. Bark browns from cell 9-6, ring grain from the stump top."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LEAF = K.ramp('#4f9a3c')
VEIN = '#8cc85a'
BARK = K.ramp('#7a4a2c')
RING = K.ramp('#b9824a')
BARKD = '#3e2418'
BARKL = '#b07a44'


def fn(c):
    k = 1.15 if c.small else 1.0
    # leaf: square-ish core with rounded upper shoulders rising to a point at the top tab
    leafcore = poly([(12, 44), (12, 24), (16, 17), (24, 13), (32, 11), (40, 13), (48, 17), (52, 24), (52, 44)])
    tabN = knob('T', 'keyhole', 32, 12, 0, -1, r=4.6 * k)
    blankW = knob('B', 'keyhole', 12, 30, -1, 0, r=4.0 * k)
    blankE = knob('B', 'keyhole', 52, 30, 1, 0, r=4.0 * k)
    raft = rect(9, 43, 55, 54)
    leaf = c.m(leafcore, tabN, minus=(blankW, blankE))
    c.add(leaf, LEAF, stitch=None)
    # raft: log slab with rounded ends
    rmask = c.m(rect(11, 43, 53, 54), ell(11, 48.5, 3, 5.5), ell(53, 48.5, 3, 5.5))
    c.add(rmask, BARK)
    # log end-grain (stump rings) at the left end
    c.add(c.m(ell(11.5, 48.5, 3.2, 5.0)), RING)
    if not c.small:
        cx, cy = c.P(11.5, 48.5)
        c.px(cx, cy, BARKD)
        for (dx, dy) in ((-1, -2), (0, -2), (1, -2), (-1, 2), (0, 2), (1, 2), (-2, -1), (-2, 0), (-2, 1), (2, -1), (2, 0), (2, 1)):
            c.px(cx + dx, cy + dy, BARK[1])
    else:
        cx, cy = c.P(11.5, 48.5)
        c.px(cx, cy, BARKD)
    # bark stripes (vertical, like the stump side cell)
    xs = (18, 23, 29, 35, 41, 47) if not c.small else (20, 29, 38, 47)
    for i, x in enumerate(xs):
        c.line([(x, 45 + (i % 2)), (x + 1, 52)], BARKD)
        if not c.small:
            c.line([(x + 2, 45), (x + 2, 48 - (i % 2))], BARKL)
    # leaf midrib from tip down to the raft, plus veins
    c.line([(32, 6), (32, 42)], VEIN)
    if not c.small:
        c.line([(32, 9), (33, 9)], VEIN)
        for y in (18, 26, 34):
            c.line([(31, y), (21, y - 5)], VEIN)
            c.line([(33, y), (43, y - 5)], VEIN)
    else:
        for y in (20, 33):
            c.line([(31, y), (22, y - 5)], VEIN)
            c.line([(33, y), (42, y - 5)], VEIN)
    # face on the leaf, either side of the midrib
    c.eye(25, 33)
    c.eye(39, 33)
    c.smile(32, 38 if not c.small else 37)
    c.blush(20, 37)
    c.blush(43, 37)


K.render_pal(fn, 'pl-trng-2', 'Leaf Raft', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-trng-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-trng-2.png')
