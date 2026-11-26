import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Podtree Wiggle, inner-TBTB keyhole: a bushy spice tree that is an inner piece. Square core = green canopy over a brown
terrace; N tab = a big gold pod on top, S tab = the trunk's root ball (keyhole flare = root flare), W/E blanks cut into
the canopy. Cell 1-6: bush greens, saffron-gold pod row, terrace browns; red dots on the branches."""
from pal_kit import rect, ell, poly, thick_path, knob, ramp

LEAF = ramp('#7db06a'); LEAF_L = ramp('#a8d080'); LEAF_D = '#4f8a50'
GOLDP = ramp('#f0b020')
SOIL = ramp('#8a5c3c'); TRUNK = ramp('#b06c40')
RED = '#d8301e'; POD_D = '#b07a10'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 16, 53, 52)
    tabN = knob('T', 'keyhole', 32, 16, 0, -1, r=5.0 * k, nw=2.4)
    podN = ell(32, 16 - 7.2 * k, 5.6 * k, 4.6 * k)
    tabS = knob('T', 'keyhole', 32, 52, 0, 1, r=4.6 * k, nw=2.4)
    ballS = ell(32, 52 + 6.6 * k, 5.0 * k, 4.2 * k)
    blW = knob('B', 'keyhole', 11, 31, -1, 0, r=3.9 * k, nw=2.2)
    blE = knob('B', 'keyhole', 53, 31, 1, 0, r=3.9 * k, nw=2.2)
    corner = lambda x, y: (x < 15 and y < 20 and (x - 15) ** 2 + (y - 20) ** 2 > 16) or (x > 49 and y < 20 and (x - 49) ** 2 + (y - 20) ** 2 > 16)
    body = c.m(core, tabN, tabS, podN, ballS, minus=(blW, blE, corner))
    # terrace soil (lower band) + root ball tab
    c.add(body, SOIL)
    # trunk rising from the soil
    c.add(c.m(poly([(26, 52), (38, 52), (36, 44), (35, 36), (29, 36), (28, 44)])) & body, TRUNK)
    c.add(c.m(tabS, ballS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 50, 64, 53))), SOIL)
    # canopy: square top with a scalloped lower hem over the soil
    hem = lambda x, y: y < 40 + 2.2 * abs(math.sin((x - 11) * math.pi / 7))
    canopy = c.m(lambda x, y: rect(11, 16, 53, 52)(x, y) and hem(x, y), minus=(blW, blE, corner))
    canopy -= c.m(rect(28.5, 40, 35.5, 60))
    c.add(canopy, LEAF, stitch=None if c.small else LEAF_D)
    # leafy lighter clumps (upper left light)
    for (cx, cy, rx, ry) in ((20, 20, 6, 4.5), (40, 19, 6, 4.5), (27, 31, 5, 3.5), (46, 33, 4, 3)):
        c.add(c.m(ell(cx, cy, rx, ry)) & canopy, LEAF_L)
    # branches with red dots (2.6+ units for 36 px)
    br = thick_path([(32, 40), (32, 34), (21, 30)], 2.8 if not c.small else 3.2)
    br2 = thick_path([(32, 34), (43, 30)], 2.8 if not c.small else 3.2)
    c.add(c.m(br, br2) & canopy, TRUNK)
    # big gold pod on top (N tab) with a stem notch
    c.add(c.m(tabN, podN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 14, 64, 17))), GOLDP)
    c.add(c.m(rect(31, 1.5, 33.5, 4.5)), TRUNK)
    # gold pods hanging in the canopy (the cell's pod row)
    pods = [(16, 27), (48, 23), (20, 37), (44, 37), (40, 34), (17, 20), (47, 18)] if not c.small else \
           [(16, 27), (48, 23), (21, 37), (44, 37), (40, 34)]
    for (x, y) in pods:
        c.add(c.m(ell(x, y, 2.6 * k, 2.0 * k)) & canopy, GOLDP)
    # pod seam on the big top pod
    if not c.small:
        x0 = c.P(32, 0)[0]
        for y in range(c.P(0, 6)[1], c.P(0, 13)[1]):
            c.px(x0 + 1, y, POD_D)
    # red dots on the branches
    for (x, y) in ((23, 30), (28, 32), (40, 31), (32, 37)):
        px, py = c.P(x, y)
        c.px(px, py, RED)
        if not c.small:
            c.px(px + 1, py, RED)
    # gold pod row band on soil (cell motif), small dots
    for x in range(14, 52, 5):
        if 26 < x < 38:
            continue
        px, py = c.P(x, 47)
        c.px(px, py, GOLDP[0])
        if not c.small:
            c.px(px + 1, py, GOLDP[2]); c.px(px, py + 1, GOLDP[1]); c.px(px + 1, py + 1, GOLDP[1])
    # face on the trunk/upper canopy calm area: put on canopy centre-top
    c.eye(26, 24 if not c.small else 23)
    c.eye(38, 24 if not c.small else 23)
    c.smile(32, 27 if not c.small else 26.5)
    c.blush(22, 28)
    c.blush(41, 28)


import math
K.render_pal(fn, 'pl-volc-3', 'Podtree Wiggle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-volc-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-volc-3.png')
