import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Teapot Tilt: corner-TB round. A blue teapot that is a corner piece: flat S (base) and flat W below the spout, round tab N = lid finial,
round blank E bitten into the side, spout breaking out of the upper W corner. Belly = the cell's glowing amber shoji panel with plum lattice."""
from pal_kit import rect, ell, poly, thick_path, knob

BLUE = K.ramp('#3c58a8')
NAVY = K.ramp('#2c3c7c')
AMBER = K.ramp('#f0a040')
CREAMP = K.ramp('#ffe0b0')
MAUVE = K.ramp('#c08898')
PINK = K.ramp('#f0a8c0')
PLUM = '#7a3848'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: rect(12, 30, 52, 58)(x, y) or ell(32, 31, 20.5, 13)(x, y)
    tabN = knob('T', 'round', 32, 18, 0, -1, r=4.6 * k)
    blankE = knob('B', 'round', 52, 42, 1, 0, r=4.8 * k)
    sw = 7.0 if not c.small else 7.6
    spout = thick_path([(15, 42), (8, 37), (5, 29)], sw)
    mouth = ell(5, 28, 4.2, 2.6)
    body = c.m(core, minus=(blankE,))
    c.add(body, BLUE, stitch=None if c.small else '#7a90d0')
    c.add(c.m(spout, mouth, minus=(core,)), BLUE)
    # lid: navy band across the top with the finial (blossom pink)
    lid = c.m(ell(32, 25, 13, 6.5)) & body
    c.add(lid, K.ramp('#5c7cd0'))
    c.edge(lid, NAVY[0])
    c.add(c.m(tabN, minus=(ell(32, 25, 13, 6.5),)), PINK)
    # belly: glowing shoji panel
    pan = c.m(rect(16, 38, 39, 53))
    c.add(pan, AMBER)
    c.add(c.m(rect(16, 38, 39, 41.5)), CREAMP)
    c.edge(pan, PLUM)
    for gx in (23.5, 31.5):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 38)[1], c.P(0, 53)[1]):
            c.px(x, y, PLUM)
    if not c.small:
        y = c.P(0, 46)[1]
        for x in range(c.P(16, 0)[0], c.P(39, 0)[0]):
            c.px(x, y, PLUM)
    # mauve foot ring (the veranda base)
    c.add(body & c.m(rect(0, 55, 64, 58)), MAUVE)
    # face on the lid band? no: face on the shoji glow, upper part
    c.eye(24, 34, disc=True)
    c.eye(37, 34, disc=True)
    c.blush(19.5, 36)
    c.blush(41.5, 36)


K.render_pal(fn, 'pl-cblo-1', 'Teapot Tilt', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-1.png')
