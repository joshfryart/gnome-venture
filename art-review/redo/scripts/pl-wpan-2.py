"""pl-wpan-2 Basket Munchkin: edge-TBB, keyhole. A panda cub sitting in a woven bamboo bowl.
Flat S = the bowl's base. Keyhole blank N = the dip between the cub's ears; keyhole blank W cut into the bowl;
keyhole tab E = the tip of the bamboo shoot it is munching (stalk runs from its mouth). Grove greens from cell 1-6."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER, UMBER2

FURW = K.ramp('#f4e8d4')
PATCH = ('#56475b', '#3c3040', '#7a6a7e')
BOWL = K.ramp('#73b951')
RIM = K.ramp('#9cd459')
SHOOT = K.ramp('#5aa04a')
LEAF = K.ramp('#b8e070')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(11, 17), (53, 17), (53, 46), (51, 53), (47, 58), (17, 58), (13, 53), (11, 46)])
    blankN = knob('B', 'keyhole', 32, 17, 0, -1, r=3.2 * k, nw=1.9)
    blankW = knob('B', 'keyhole', 11, 48.5, -1, 0, r=3.1 * k, nw=1.9)
    tabE = knob('T', 'keyhole', 53, 35, 1, 0, r=4.6 * k)
    cut = (blankN, blankW)
    body = c.m(core, minus=cut)
    # head (white fur, top half)
    c.add(body & c.m(rect(0, 0, 64, 40)), FURW)
    # ears: black, rounding the top corners
    c.add(c.m(ell(16.5, 19, 6, 5.5), minus=cut), PATCH)
    c.add(c.m(ell(47.5, 19, 6, 5.5), minus=cut), PATCH)
    # eye patches
    c.add(c.m(ell(23.5, 29.5, 5, 4.2)), PATCH)
    c.add(c.m(ell(40.5, 29.5, 5, 4.2)), PATCH)
    # woven bamboo bowl (lower part)
    bowl = body & c.m(rect(0, 40, 64, 64))
    c.add(bowl, BOWL, stitch=None)
    rim = body & c.m(rect(0, 39, 64, 43.5))
    c.add(rim, RIM)
    # weave: vertical slats and a horizontal band
    for gx in (17, 23, 29, 35, 41, 47):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 43)[1], c.n):
            if (x, y) in bowl and (y // (2 if c.small else 3)) % 2 == (gx // 6) % 2:
                c.px(x, y, BOWL[1])
    yb = c.P(0, 51)[1]
    for x in range(c.n):
        if (x, yb) in bowl:
            c.px(x, yb, BOWL[2])
    # paws on the rim, black
    c.add(c.m(ell(20, 40, 4.0, 2.8)), PATCH)
    # the shoot: from the mouth to the E tab, held by the right paw
    stalk = c.m(thick_path([(32, 36), (54, 35)], 3.6 if not c.small else 4.2), tabE, minus=(rect(0, 0, 30, 64),))
    c.add(stalk, SHOOT)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(51, 0, 54, 64))), LEAF)
    nx, _ = c.P(44, 0)
    for y in range(c.P(0, 33)[1], c.P(0, 38)[1]):
        if (nx, y) in stalk:
            c.px(nx, y, SHOOT[1])
    c.add(c.m(ell(45, 39.5, 3.8, 2.8)), PATCH)
    # face
    c.eye(23.5, 29.5, disc=True)
    c.eye(40.5, 29.5, disc=True)
    x, y = c.P(32, 33)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(x + dx, y, UMBER2)
    if not c.small:
        c.px(x, y + 1, UMBER2)
    c.blush(17.5, 34)


K.render_pal(fn, 'pl-wpan-2', 'Basket Munchkin', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpan-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpan-2.png')
