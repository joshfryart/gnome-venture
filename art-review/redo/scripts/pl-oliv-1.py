# Pennant Frolic: a coral pennant flag on a wooden pole that is itself a corner piece.
# Flat sides = pole (left) and flag top; round tab on the right (flag tip) and on the slanted bottom hem.
# Motif from cell 3-1 / picture: coral roof-orange flag, lavender sky, rose hill, bunting in shutter green + window gold.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math

FLAG = K.ramp('#f89a60')
POLE = ('#a0623a', '#6e4026', '#d08a52')
FINIAL = K.ramp('#fbd46f')
LAVR = K.ramp('#9a88c0')
ROSE = K.ramp('#d898a8')
GREEN = K.ramp('#408473')
GOLD = K.ramp('#fbd46f')
CORD = '#72404c'


def fn(c):
    k = 1.15 if c.small else 1.0
    flag = K.poly([(13, 12), (50, 12), (50, 38), (13, 54)])
    tab_r = K.knob('T', 'round', 50, 25, 1, 0, r=5.0 * k, nw=3.4)
    # bottom hem: from (13,54) to (50,38)
    dx, dy = 37, -16
    L = math.hypot(dx, dy)
    nx, ny = -dy / L, dx / L  # outward (down-right)
    tab_b = K.knob('T', 'round', 31.5, 46, nx, ny, r=5.0 * k, nw=3.4)
    body = c.m(flag, tab_r, tab_b)
    c.add(body, FLAG, stitch='#fbd46f')
    pole = c.m(K.rect(8, 9, 14, 61))
    c.add(pole, POLE)
    c.add(c.m(K.ell(11, 8, 4, 3.6)), FINIAL)
    # bunting: cord + four little pennants hanging inside the flag
    cord = c.m(K.thick_path([(14, 17), (24, 20), (36, 20), (48, 17)], 1.6 if not c.small else 2.0))
    cols = [GREEN, GOLD, LAVR, ROSE]
    xs = [18, 26.5, 35, 43.5]
    tris = []
    for x, col in zip(xs, cols):
        y0 = 18.6 if x < 22 or x > 40 else 19.6
        t = c.m(K.poly([(x - 4.2, y0), (x + 4.2, y0), (x, y0 + 9.5)]))
        c.add(t, col)
        tris.append(t)
    for (x, y) in cord:
        c.px(x, y, CORD)
    c.eye(25, 33)
    c.eye(37, 32)
    c.smile(31, 38, wide=True)
    c.blush(21, 37)
    c.blush(41, 36)


rep = K.render_pal(fn, 'pl-oliv-1', 'Pennant Frolic', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oliv-1-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oliv-1.png')
print(rep)
