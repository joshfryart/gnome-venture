"""pl-ambr-5 Sprout Nook: inner-BBBB, double. A rounded chunk of the big amber (cell 6-6 honey #facc64, cream glints,
the brown twig crack) cut as a square piece with four double blanks; a dark knot-hole nook in its middle with felt eyes
peering out and a green sprout growing up out of the nook's rim."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

AMBER = K.ramp('#facc64')
AMB_O = K.ramp('#f4a43c')
HOLE = ('#5a3420', '#3e2416', '#7a4a2c')
LEAF = K.ramp('#7ab040')
STEM = K.ramp('#5a8a30')
CRACK = '#7a4a2c'
GLINT = '#fff0a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.2 * k
    x0, y0, x1, y1 = 7, 9, 57, 57
    rc = 6
    core = lambda x, y: (rect(x0 + rc, y0, x1 - rc, y1)(x, y) or rect(x0, y0 + rc, x1, y1 - rc)(x, y)
                         or any(ell(cx, cy, rc, rc)(x, y) for cx in (x0 + rc, x1 - rc) for cy in (y0 + rc, y1 - rc)))
    bN = knob('B', 'double', 32, y0, 0, -1, r=r)
    bS = knob('B', 'double', 32, y1, 0, 1, r=r)
    bW = knob('B', 'double', x0, 34, -1, 0, r=r)
    bE = knob('B', 'double', x1, 34, 1, 0, r=r)
    body = c.m(core, minus=(bN, bS, bW, bE))
    c.add(body, AMBER, stitch='#f0b452')
    # glassy amber glow: lighter honey band toward the upper left
    c.add(body & c.m(poly([(0, 0), (40, 0), (0, 36)])), K.ramp('#fcd87a'))
    # warmer orange lower-right lobe (amber deepens toward the ground)
    c.add(body & c.m(poly([(64, 40), (64, 64), (34, 64)])), AMB_O)
    # the nook: a dark hollow in the middle
    hole = c.m(ell(32, 36, 9.5, 7.5))
    c.add(hole, HOLE)
    c.edge(hole, '#3e2416')
    # sprout growing out of the top rim of the nook
    c.add(c.m(thick_path([(32, 33), (32, 26), (33, 22)], 2.8 if not c.small else 3.0)), STEM)
    lf = c.m(ell(26.5, 21, 5.5, 3.2), ell(38.5, 19.5, 5.5, 3.2))
    c.add(lf, LEAF)
    c.edge(lf, LEAF[1])
    # eyes peering out of the dark nook
    c.eye(28.5, 36.5, disc=True)
    c.eye(35.5, 36.5, disc=True)
    # twig crack + amber glints from the picture
    c.line([(41, 50), (45, 47.5), (49, 44)], CRACK)
    if not c.small:
        c.line([(45, 47.5), (46, 45)], CRACK)
    c.line([(12, 30), (12, 20), (15, 15), (20, 12)], GLINT)
    for bx, by in ((48, 22), (17, 47), (44, 41)):
        x, y = c.P(bx, by)
        for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)) if not c.small else ((0, 0),):
            c.px(x + dx, y + dy, GLINT if c.small else '#f4a43c')
        if not c.small:
            c.px(x - 1, y - 1, GLINT)
    for gx, gy in ():
        x, y = c.P(gx, gy)
        c.px(x, y, GLINT)
    c.blush(21.5, 41)
    c.blush(42, 41)


K.render_pal(fn, 'pl-ambr-5', 'Sprout Nook', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ambr-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ambr-5.png')
print(K.check(K.draw(fn, 64))['colours'])
