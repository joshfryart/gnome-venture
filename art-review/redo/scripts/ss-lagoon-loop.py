"""ss-lagoon-loop "Lagoon Loop": inner-BBBB keyhole. A cream life ring (rounded square piece) with a keyhole blank cut into each side,
coral bands on the diagonals, and the turquoise lagoon filling the hole: the lagoon is the face and it winks (cell 10-6: lagoon teal, cream sail, coral stripe)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
TEALW = K.ramp('#2bb3bf')
SEAFOAM = '#60d3cc'
SAND = K.ramp('#efe0bf')
CORAL = K.ramp('#f3827a')
GOLDC = K.ramp('#f0b92b')


def rsq(x0, y0, x1, y1, r):
    def f(x, y):
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return x0 <= x < x1 and y0 <= y < y1 and (x - cx) ** 2 + (y - cy) ** 2 < r * r
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rsq(4, 4, 60, 60, 15)
    rr = 3.2 * k
    blanks = (K.knob('B', 'keyhole', 32, 4, 0, -1, r=rr), K.knob('B', 'keyhole', 60, 32, 1, 0, r=rr),
              K.knob('B', 'keyhole', 32, 60, 0, 1, r=rr), K.knob('B', 'keyhole', 4, 32, -1, 0, r=rr))
    lagoon = K.ell(32, 32, 13.5, 13.5)
    body = c.m(core, minus=blanks)
    c.add(body, SAND, stitch='#c9b489')
    band = lambda x, y: abs(abs(x - 32) - abs(y - 32)) < 6.5
    c.add(body & c.m(band, minus=(lagoon,)), CORAL)
    lag = c.m(lagoon)
    c.add(lag, TEALW)
    c.edge(lag, TEALW[1])
    # ripples
    c.line([(23, 39.5), (26, 38.5), (29, 39.5)], SEAFOAM)
    c.line([(35, 40.5), (38, 39.5), (41, 40.5)], SEAFOAM)
    if not c.small:
        c.line([(22, 24), (25, 22)], '#a8e6e0')
    # face: open eye + wink
    c.eye(26.5, 30.5, disc=True)
    wx, wy = c.P(37.5, 30.5)
    if c.small:
        for dx, dy in ((-1, 0), (0, -1), (1, -1), (2, 0)):
            c.px(wx + dx, wy + dy, K.UMBER)
    else:
        for dx, dy in ((-2, 1), (-1, 0), (0, -1), (1, 0), (2, 1)):
            c.px(wx + dx, wy + dy, K.UMBER)
    c.smile(32, 34.5, wide=True)
    c.blush(22.5, 34.5)
    c.blush(41, 34.5)


K.render_pal(fn, 'ss-lagoon-loop', 'Lagoon Loop', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/ss-lagoon-loop-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/ss-lagoon-loop.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
