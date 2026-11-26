import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
R = '/home/user/gnome-venture/'
# Concept: a little volcano cone that IS an inner-BBBB piece (double knobs): the top blank is the glowing crater mouth,
# side blanks cut into the slopes, bottom blank under the base; tan slope + spice terraces + lava from the picture.
ROCK = K.ramp('#b08a68')
TAN = K.ramp('#d6b08c')
LAVA = K.ramp('#f07020')
GLOW = K.ramp('#f8b838')
PURP = K.ramp('#7a4ab0'); YELL = K.ramp('#f0c030'); GRN = K.ramp('#3f9a4a'); RED = K.ramp('#d8402a')

def fn(c):
    s = 1.15 if c.small else 1.0
    TL, TR, BL, BR = (16, 8), (48, 8), (3, 60), (61, 60)
    core = K.poly([TL, TR, BR, BL])
    def side(a, b):
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        return mx, my, dy / L, -dx / L
    lx, ly, lnx, lny = side(BL, TL)
    rx, ry, rnx, rny = side(TR, BR)
    blanks = [K.knob('B', 'double', 32, 8, 0, -1, r=3.5 * s),
              K.knob('B', 'double', lx - 0.6, ly - 2, lnx, lny, r=3.0 * s),
              K.knob('B', 'double', rx + 0.6, ry - 2, rnx, rny, r=3.0 * s),
              K.knob('B', 'double', 32, 60, 0, 1, r=3.2 * s)]
    body = c.m(core, minus=blanks)
    c.add(body, ROCK)
    # upper tan face area
    c.add(c.m(K.rect(0, 0, 64, 36), minus=blanks) & body, TAN, stitch='#b08a68')
    # spice terraces
    for y0, rmp in ((38, PURP), (43, YELL), (48, GRN), (53, RED)):
        band = c.m(K.rect(0, y0, 64, y0 + 3.4), minus=blanks) & body
        c.add(band, rmp)
    # crater glow: lava lips around the crater blank
    rim = c.m(K.knob('B', 'double', 32, 8, 0, -1, r=3.5 * s + 2.4), K.rect(16, 8, 48, 11), minus=blanks) & body
    c.add(rim, GLOW)
    # lava rivers down the slope
    c.add(c.m(K.thick_path([(25, 10), (23, 14), (21, 17)], 3.0 * s), minus=blanks) & body, LAVA)
    c.add(c.m(K.thick_path([(38, 10), (41, 16), (43, 23), (42, 30), (46, 37), (45, 44), (49, 52)], 3.0 * s), minus=blanks) & body, LAVA)
    # face
    c.eye(28, 24); c.eye(36, 24)
    c.blush(26, 28); c.blush(37, 28)
    c.smile(32, 29, wide=True)

K.render_pal(fn, 'pl-volc-5', 'Cratermouth Hearth', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-volc-5-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-volc-5.png')
