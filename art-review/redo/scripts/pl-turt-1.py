# Moonlit Beam: a full-moon pal that is a corner piece. Top and left sides are flat (the night-sky corner of the picture,
# indigo with stars); the lower-right of the piece is the round moon itself, with a round tab out the right and a round
# blank bitten into the bottom. Colours: cell indigo #2e2a6e / #1e1c52, picture moon cream #efdcaa with tan craters.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

SKY = K.ramp('#2e2a6e')
MOON = ('#efdcaa', '#c8b07a', '#fff6d8')
CRATER = '#d2bc86'
STAR = '#f6eec8'


def sq(cx, cy, r, p=3.2):
    return lambda x, y: (abs(x - cx) / r) ** p + (abs(y - cy) / r) ** p < 1


def fn(c):
    s = 1.15 if c.small else 1.0
    corner = K.rect(6, 6, 36, 36)
    moon = sq(33, 33, 24, 2.8)
    tab = K.knob('T', 'round', 57, 32, 1, 0, r=4.6 * s)
    blank = K.knob('B', 'round', 31, 57, 0, 1, r=4.6 * s)
    body = c.m(corner, moon, tab, minus=(blank,))
    c.add(body, SKY)
    glow = c.m(sq(33, 33, 27.5, 2.8)) & body
    c.add(glow, K.ramp('#5a56a8'))
    disc = c.m(moon, tab, minus=(blank,))
    c.add(disc & body, MOON)
    c.edge(disc & body, MOON[1])
    # craters
    for (x, y, r) in ((44, 17, 3.0), (47, 46, 2.6), (17, 46, 2.4), (15, 22, 1.6)):
        cr = c.m(K.ell(x, y, r, r)) & disc
        for p in cr:
            c.px(p[0], p[1], CRATER)
    # stars in the sky corner
    for (x, y) in ((10, 10), (19, 8.5), (8.5, 18)):
        X, Y = c.P(x, y)
        c.px(X, Y, STAR)
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(X + d[0], Y + d[1], K.ramp('#f6eec8')[1])
    # face
    c.eye(27, 29)
    c.eye(38, 29)
    c.smile(32.5, 35)
    c.blush(22, 34)
    c.blush(41, 34)


K.render_pal(fn, 'pl-turt-1', 'Moonlit Beam', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-turt-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-turt-1.png')
