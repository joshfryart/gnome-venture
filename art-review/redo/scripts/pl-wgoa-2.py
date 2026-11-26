import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

R = '/home/user/gnome-venture/'
CYP = K.ramp('#2c6e4a')        # cypress green from the picture
CYPL = '#4f9a6a'
HILL = K.ramp('#a8b8a0')       # sage hill (cell)
CREAMH = K.ramp('#f6ebc8')     # cream horizon (cell)
SKY = '#e0f0e8'


def fn(c):
    """Edge-TBB keyhole: a pencil cypress. Flat S = sage hill it stands on, keyhole tab N = the tree's tip,
    keyhole blanks W and E (staggered) bite into the foliage like gaps between the flame tufts."""
    s = 1.15 if c.small else 1.0
    arch = poly([(18, 36), (18.5, 25), (22, 17), (27, 11.5), (32, 9.5), (37, 11.5), (42, 17), (45.5, 25), (46, 36)])
    core = lambda x, y: rect(18, 32, 46, 58)(x, y) or arch(x, y)
    tabN = knob('T', 'keyhole', 32, 10.5, 0, -1, r=3.6 * s, nw=2.2)
    blankW = knob('B', 'keyhole', 18, 43, -1, 0, r=3.0 * s, nw=1.9)
    blankE = knob('B', 'keyhole', 46, 35, 1, 0, r=3.0 * s, nw=1.9)
    body = c.m(core, tabN, minus=(blankW, blankE))
    c.add(body, CYP, stitch=None if c.small else CYPL)
    # foliage tufts: soft vertical flame strokes in a lighter green
    if not c.small:
        for pts in ([(27, 15), (24, 22)], [(37, 15), (40, 22)], [(31, 36), (30, 44)], [(40, 43), (41, 48)], [(24, 33), (23, 38)]):
            c.line(pts, CYPL)
    else:
        c.line([(27, 15), (25, 21)], CYPL)
        c.line([(30, 37), (29, 44)], CYPL)
    # hill base: sage band with a cream horizon line, the cell's own strata
    hill = body & c.m(lambda x, y: y >= 51 - 1.5 * ((x - 18) / 28))
    c.add(hill, HILL)
    c.add(body & c.m(lambda x, y: 49 - 1.5 * ((x - 18) / 28) <= y < 51 - 1.5 * ((x - 18) / 28)), CREAMH)
    # tiny trunk peeking where tree meets hill
    c.add(body & c.m(rect(30, 46, 34.5, 50.5)), K.ramp('#7a4a2a'))
    # face high on the calm foliage
    c.eye(28, 26, disc=True)
    c.eye(36.5, 26, disc=True)
    c.smile(32, 31.5, '#f2e4c0')
    c.blush(24.5, 30)
    c.blush(39.5, 30)


K.render_pal(fn, 'pl-wgoa-2', 'Green Pencil Cypress', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-wgoa-2-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-wgoa-2.png')
