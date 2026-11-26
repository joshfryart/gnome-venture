"""pl-jrc-6 Boulder Jaguar (whimsy-jaguar, peg): a chibi jaguar sitting face-on on a mossy cave boulder. Its square body is the piece:
round ears break the top corners with an N peg blank between them, the ringed tail sticks out E as the peg tab, a W peg blank bites the
flank, and the purple-grey boulder carries an S peg tab. Orange fur + dark spots on purple cave rock (cell 5-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#f0a03c')
CREAM = K.ramp('#f8e2b4')
ROCK = K.ramp('#7c6a86')
MOSS = K.ramp('#6a9a48')
SPOT = '#3a2418'
PINK = '#e89a8a'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 12, 51, 47)
    earL, earR = K.ell(17, 12, 6, 6), K.ell(47, 12, 6, 6)
    blankN = K.knob('B', 'peg', 32, 12, 0, -1, r=3.0 * s)
    blankW = K.knob('B', 'peg', 13, 36, -1, 0, r=3.6 * s)
    tabE = K.knob('T', 'peg', 51, 34, 1, 0, r=4.0 * s)
    boulder = K.poly([(10, 50), (13, 45), (51, 45), (54, 50), (54, 54), (51, 56), (13, 56), (10, 54)])
    tabS = K.knob('T', 'peg', 32, 56, 0, 1, r=3.6 * s)

    rock = c.add(c.m(boulder, tabS), ROCK, stitch=None if c.small else '#9a8aa6')
    c.add(c.m(K.rect(10, 44, 54, 48.5), minus=(K.rect(0, 0, 64, 45.6),)) & c.m(boulder), MOSS)
    body = c.add(c.m(core, earL, earR, minus=(blankN, blankW)), FUR)
    tail = c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(49, 0, 52, 64))), FUR)
    # inner ears
    c.add(c.m(K.ell(17, 12, 2.8, 2.8)), K.ramp(PINK))
    c.add(c.m(K.ell(47, 12, 2.8, 2.8)), K.ramp(PINK))
    # belly
    c.add(c.m(K.ell(33, 41, 8, 6)) & body, CREAM)
    # muzzle
    c.add(c.m(K.ell(32, 30.5, 6.5, 4.2)), CREAM)
    # front paws on the boulder
    for px_ in (25, 39):
        pw = c.add(c.m(K.ell(px_, 46, 4.2, 2.8)), CREAM)
        if not c.small:
            c.px(*c.P(px_, 46.5), K.UMBER2)
    # ringed tail tip (dark bands + dark tip)
    x0, x1 = c.P(51, 0)[0], c.n
    for (x, y) in tail:
        if x >= c.P(57.5 if not c.small else 57, 0)[0] or (not c.small and x == c.P(54, 0)[0]):
            c.px(x, y, SPOT)
    # rosette spots: broken dark rings (jaguar rosettes), avoiding the face
    if not c.small:
        spots = [(16.5, 19.5), (45.5, 20), (17, 40), (46, 39.5), (45, 29.5), (18.5, 29), (24, 44.5), (41, 45)]
        for (sx, sy) in spots:
            x, y = c.P(sx, sy)
            for dx, dy in ((0, 0), (1, 0), (2, 1), (2, 2), (0, 2), (-1, 1)):
                c.px(x + dx, y + dy, SPOT)
    else:
        spots = [(16, 20), (46, 20), (17, 41), (46.5, 40), (45, 30), (18, 30)]
        for (sx, sy) in spots:
            x, y = c.P(sx, sy)
            c.px(x, y, SPOT)
            c.px(x + 1, y + 1, SPOT)
    # forehead stripes
    for fx in (28, 32, 36):
        x, y = c.P(fx, 18.5)
        c.px(x, y, SPOT)
        c.px(x, y + 1, SPOT)
        if not c.small:
            c.px(x, y + 2, SPOT)
    # face
    c.eye(25, 25)
    c.eye(39, 25)
    nx, ny = c.P(32, 28.5)
    if c.small:
        c.px(nx - 1, ny, K.UMBER2)
        c.px(nx, ny, K.UMBER2)
        c.px(nx - 2, ny + 2, K.UMBER2)
        c.px(nx + 1, ny + 2, K.UMBER2)
    else:
        for dx in (-1, 0, 1):
            c.px(nx + dx, ny, '#8a4a3a')
        c.px(nx, ny + 1, '#8a4a3a')
        c.px(nx, ny + 2, K.UMBER2)
        c.px(nx - 1, ny + 3, K.UMBER2)
        c.px(nx - 2, ny + 3, K.UMBER2)
        c.px(nx + 1, ny + 3, K.UMBER2)
        c.px(nx + 2, ny + 3, K.UMBER2)
    c.blush(20, 30)
    c.blush(43, 30)


print(K.render_pal(fn, 'pl-jrc-6', 'Boulder Jaguar', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-6-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-6.png'))
