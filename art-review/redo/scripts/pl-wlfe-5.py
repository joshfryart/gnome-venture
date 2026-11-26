# Concept: a round-bellied paper lantern (orange-red paper, darker ribs, gold caps) that is an inner-BBBB keyhole piece:
# keyhole blanks in the top cap, both flanks and the water line; its lower third bobs in the cell's blue river with a green bank glint.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PAPER = K.ramp('#f2603c')
RIB = '#b74d47'
GLOW = ('#faba90', '#f2603c', '#fff0b0')
CAP = K.ramp('#e8a838')
WATER = K.ramp('#2a5a98')
RIPPLE = '#5a7ab0'
BANK = '#2c6a58'


def rounded(x0, y0, x1, y1, r):
    core = K.rect(x0 + r, y0, x1 - r, y1)
    core2 = K.rect(x0, y0 + r, x1, y1 - r)
    cs = [K.ell(x0 + r, y0 + r, r, r), K.ell(x1 - r, y0 + r, r, r), K.ell(x0 + r, y1 - r, r, r), K.ell(x1 - r, y1 - r, r, r)]
    return lambda x, y: core(x, y) or core2(x, y) or any(f(x, y) for f in cs)


def fn(c):
    k = 1.15 if c.small else 1.0
    belly = rounded(9, 7, 55, 57, 11)
    bulge = K.ell(32, 32, 26, 23)
    bN = K.knob('B', 'keyhole', 32, 7, 0, -1, r=3.3 * k, nw=1.9)
    bS = K.knob('B', 'keyhole', 32, 57, 0, 1, r=3.3 * k, nw=1.9)
    bW = K.knob('B', 'keyhole', 6, 32, -1, 0, r=3.3 * k, nw=1.9)
    bE = K.knob('B', 'keyhole', 58, 32, 1, 0, r=3.3 * k, nw=1.9)
    blanks = (bN, bS, bW, bE)
    body = c.m(belly, bulge, minus=blanks)
    c.add(body, PAPER, stitch=None)
    # glow in the belly
    c.add(body & c.m(K.ell(32, 30, 15, 16)), K.ramp('#f8905c'))
    c.add(body & c.m(K.ell(32, 30, 9.5, 11)), GLOW)
    # ribs
    rw = 1.0 if not c.small else 1.8
    for rx, bend, col in ((14, -3, RIB), (22, -1.5, '#e8704a'), (42, 1.5, '#e8704a'), (50, 3, RIB)):
        pts = [(rx - bend * 0.2, 12), (rx + bend * 0.6, 24), (rx + bend, 32), (rx + bend * 0.6, 40), (rx - bend * 0.2, 52)]
        c.add(body & c.m(K.thick_path(pts, 1.6 if not c.small else 2.2)), (col, col, col))
    # wire handle over the top cap
    c.add(c.m(K.thick_path([(23, 8), (25, 3.5), (32, 2), (39, 3.5), (41, 8)], 2.6 if c.small else 2.0)), K.ramp('#452d2c'))
    # gold top cap
    c.add(body & c.m(K.rect(0, 0, 64, 13.5)), CAP)
    # river: lower part submerged
    wave = lambda x, y: y > 44 + 1.3 * ((int(x) // 6) % 2)
    water = body & c.m(wave)
    c.add(water, WATER)
    # ripple light along the water line and a green bank glint (from the cell)
    y0 = c.P(0, 46.5)[1]
    for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
        if (x // (2 if c.small else 3)) % 3 != 2:
            c.px(x, y0 + ((x // (2 if c.small else 3)) % 2), RIPPLE)
    for (bx, by) in ((15, 51), (45, 51.5)):
        x, y = c.P(bx, by)
        for dx in range(2 if c.small else 3):
            c.px(x + dx, y, BANK)
    # glow reflection in the river
    for (gx, gy, w) in ((17, 50, 4), (43, 50, 4), (20, 53, 3), (41, 53.5, 3)):
        x, y = c.P(gx, gy)
        for dx in range(max(1, int(w * c.k))):
            c.px(x + dx, y, '#fff0b0')
    # gold cap band line
    yb = c.P(0, 13)[1]
    for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
        if (x, yb) in body:
            c.px(x, yb, CAP[1])
    # face on the glow
    c.eye(27, 28)
    c.eye(37, 28)
    c.smile(32, 33)
    c.blush(23, 33)
    c.blush(41, 33)


K.render_pal(fn, 'pl-wlfe-5', 'Roundbelly Lanternling', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlfe-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-5.png')
