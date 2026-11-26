# Pearl Peekaboo: an oyster that IS an inner piece (4 keyhole blanks). Scalloped fan-ridged upper shell, pink lip crack with the pearl
# peeking out, ribbed lower shell; colours from cell 6-7 (blush-cream shell, mauve ridges, sand) and the picture's pink lip / lilac pearl.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SHELL = K.ramp('#ecd0b7')
SHELL_HI = K.ramp('#f6e0cb')
LOWER = K.ramp('#c4a199')
LIP = K.ramp('#f0a0b8')
PEARL = ('#ece4f0', '#b8a8c8', '#ffffff')
MOUTH = ('#6a4a52', '#4e4043', '#8a6470')
RIDGE = '#ac8d8a'
SAND = '#d7ad7a'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.0 * k
    x0, x1, y0, y1 = 7, 57, 10, 58
    # scalloped crown on the top edge: core + bumps
    core = K.rect(x0, y0 + 6, x1, y1)
    bumps = [K.ell(x, y0 + 5.5, 6.4, 5.5) for x in (13.2, 23.6, 40.4, 50.8)]
    blanks = [K.knob('B', 'keyhole', 32, y0 + 1, 0, -1, r=r, nw=1.8),
              K.knob('B', 'keyhole', 32, y1, 0, 1, r=r, nw=1.8),
              K.knob('B', 'keyhole', x0, 26, -1, 0, r=r, nw=1.8),
              K.knob('B', 'keyhole', x1, 26, 1, 0, r=r, nw=1.8)]
    body = c.m(core, *bumps, minus=blanks)
    # upper shell (everything above the crack), lower shell below
    upper = {p for p in body if (p[1] + 0.5) / c.k < 38}
    lower = body - upper
    c.add(upper, SHELL, stitch=None)
    c.add(lower, LOWER, stitch=None)
    # fan ridges radiating from the hinge
    hx, hy = 32, 44
    for tx in (18.5, 28, 36, 45.5):
        c.line([(hx + (tx - hx) * 0.45, 33), (tx, y0 + 3)], RIDGE)
    # lip: pink band at the crack, dark gap, pearl
    lip = c.m(K.ell(32, 39.5, 22, 5.5), minus=[K.rect(0, 0, 64, 37)])
    lip &= body
    c.add(lip, LIP)
    gap = c.m(K.ell(32, 39, 18, 3.4)) & body
    c.add(gap, MOUTH)
    pearl = c.m(K.ell(32, 38.5, 7.2, 6.6))
    c.add(pearl, PEARL)
    gx, gy = c.P(29.5, 35.5)
    c.px(gx, gy, '#ffffff')
    if not c.small:
        c.px(gx + 1, gy, '#ffffff'); c.px(gx, gy + 1, '#ffffff')
    # lower shell ribs + a sandy rim at the base
    for yy in (48,) if c.small else (47, 52):
        c.line([(x0 + 3, yy), (24, yy + 1.5)], RIDGE)
        c.line([(40, yy + 1.5), (x1 - 3, yy)], RIDGE)
    # eyes peeking over the crack, on the upper shell
    c.eye(21, 29)
    c.eye(43, 29)
    c.blush(16, 33)
    c.blush(46, 33)


K.render_pal(fn, 'pl-wpea-5', 'Pearl Peekaboo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-5.png')
