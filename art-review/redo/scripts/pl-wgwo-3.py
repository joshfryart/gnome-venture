"""pl-wgwo-3 Hopscotch Stones. Inner-TBTB keyhole (rotated: tabs N + S, blanks W + E).
A flat lavender stepping stone sitting in the teal glow-pool (cell 8-7): N tab = a small pebble perched on top (the next hop),
S tab = a second stepping stone peeking out of the pool; W + E keyhole blanks bite into the stone slab. Face on the slab top."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#a8a0d0')
UNDER = K.ramp('#5a5290')
WATER = K.ramp('#2aa8b0')
GLOW = '#7fe8e0'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(10, 15, 54, 53)
    # rounded lumpy corners
    corners = (K.rect(10, 15, 14, 19), K.rect(50, 15, 54, 19))
    keep = (K.ell(14, 19, 4, 4), K.ell(50, 19, 4, 4))
    tabN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=6.2 * s, nw=3.6)
    tabS = K.knob('T', 'keyhole', 32, 53, 0, 1, r=5.6 * s, nw=3.4)
    blankW = K.knob('B', 'keyhole', 10, 30, -1, 0, r=6.0 * s, nw=3.6)
    blankE = K.knob('B', 'keyhole', 54, 30, 1, 0, r=6.0 * s, nw=3.6)
    cutc = lambda x, y: any(a(x, y) for a in corners) and not any(k(x, y) for k in keep)
    body = c.m(core, minus=(blankW, blankE, cutc))
    c.add(body, STONE, stitch='#c9c3e6')
    # pebble on top (N tab)
    peb = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 12, 64, 17)))
    c.add(peb, K.ramp('#bcb4e0'))
    c.edge(peb, K.UMBER2)
    # darker underside of the slab, curved
    under = body & c.m(lambda x, y: y >= 38 + 2.5 * ((x - 32) / 22) ** 2)
    c.add(under, UNDER)
    # pool water band at the bottom + the S ripple tab
    water = body & c.m(lambda x, y: y >= 46 - 1.5 * ((x - 32) / 22) ** 2)
    c.add(water, WATER)
    # a second little stepping stone peeking out of the pool (S tab), lavender top over teal
    sst = c.m(tabS, minus=(core,))
    c.add(sst, UNDER)
    c.add(sst & c.m(lambda x, y: y < 60), STONE)
    # mottles on the slab (stone texture from the cell)
    for (a, b, w) in ((15, 25, 3), (44, 20, 4), (20, 35, 2), (47, 35, 3), (29, 21, 2)):
        x, y = c.P(a, b)
        for d in range(w if not c.small else max(1, w - 1)):
            c.px(x + d, y, '#8c84bc')
    c.edge(under, K.UMBER2)
    # ripple highlights on water
    for (a, b) in ((14, 49), (40, 50), (47, 48)):
        x, y = c.P(a, b)
        for d in range(3 if not c.small else 2):
            c.px(x + d, y, GLOW)
    # glow specks on stone and pebble
    for (a, b) in ((17, 22), (46, 24), (31, 7.5)):
        x, y = c.P(a, b)
        c.px(x, y, GLOW)
        if not c.small:
            c.px(x + 1, y, '#ffffff')
    # speckle crack on stone underside
    if not c.small:
        c.line([(18, 41), (22, 42.5), (25, 41.5)], '#433c74')
        c.line([(40, 42), (44, 43)], '#433c74')
    # face on the slab top
    c.eye(26, 27)
    c.eye(38, 27)
    c.smile(32, 32)
    c.blush(23, 31)
    c.blush(40, 31)


K.render_pal(fn, 'pl-wgwo-3', 'Hopscotch Stones', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-3.png')
