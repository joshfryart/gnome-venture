# Maple Quartet: a maple leaf that is an inner-TTTT peg piece. Square orange leaf blade; peg tabs N, E, W are the
# leaf's three main lobe tips, the S peg is the stem in the fence-post plum of cell 10-4; snow cap on top (cell's lavender snow).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

LEAF = ramp('#f0962e')
LEAF2 = ramp('#d86a1c')
STEM = ramp('#4a3448')
SNOW = ('#eef0fa', '#c4c8e4', '#ffffff')
VEIN = '#b8521a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 17, 50, 49)
    tN = knob('T', 'peg', 32, 17, 0, -1, r=4.6 * k)
    tE = knob('T', 'peg', 50, 33, 1, 0, r=4.6 * k)
    tW = knob('T', 'peg', 14, 33, -1, 0, r=4.6 * k)
    tS = knob('T', 'peg', 32, 49, 0, 1, r=3.4 * k, nw=2.2)
    # maple shoulders: small pointed lobes at the lower corners and serration points at the upper corners
    lobeL = poly([(14, 40), (7, 53), (24, 49)])
    lobeR = poly([(50, 40), (57, 53), (40, 49)])
    tipL = poly([(14, 24), (8, 13), (22, 17)])
    tipR = poly([(50, 24), (56, 13), (42, 17)])
    body = c.m(core, tN, tE, tW, lobeL, lobeR)
    c.add(body, LEAF, stitch=None)
    # darker autumn blush toward the bottom
    c.add(body & c.m(lambda x, y: y > 43 - (abs(x - 32) * 0.15)), LEAF2)
    # stem peg (fence-post plum)
    c.add(c.m(tS, minus=(core, lobeL, lobeR)) | (c.m(tS) & c.m(rect(0, 47, 64, 50))), STEM)
    # snow cap on the N lobe and top edge
    snow = body & c.m(lambda x, y: (y < 10.5 + (1.2 if (int(x) // 3) % 2 else 0)) or (17 <= y < 19 + (1.3 if (int(x) // 4) % 2 else 0) and 22 < x < 42))
    # palmate veins radiating from the stem to every lobe tip (drawn before the snow so it stays on top)
    vw = 1.7 if not c.small else 2.0
    for v in ((32, 12), (8, 33), (56, 33), (9, 52), (55, 52)):
        c.add(body & c.m(thick_path([(32, 48), v], vw)), ('#c0601a', '#a04c14', '#c0601a'))
    c.add(snow, SNOW)
    # face
    c.eye(24, 29, disc=True)
    c.eye(40, 29, disc=True)
    c.smile(32, 38)
    c.blush(19, 35)
    c.blush(44, 35)


K.render_pal(fn, 'pl-sugr-4', 'Maple Quartet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-4.png')
