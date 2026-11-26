"""pl-cwy-3 Scorch Sliver. Inner-TBBB, peg: a smouldering cinder shard of the forge's cave rock. Chamfered mauve-brown rock body with the
cell's rosy rock blobs and glowing lava cracks; N peg tab is the red-hot ember tip with a flame tongue; peg blanks W, E, S (cell 9-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#7a4650')
ROCKD = K.ramp('#5a3448')
BLOB = K.ramp('#b06458')
EMBER = K.ramp('#d8481e')
FLAME = K.ramp('#f0a020')
LAVA = '#f8c040'
HOT = '#e86a1e'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(11, 21), (18, 14), (46, 14), (53, 21), (53, 54), (47, 60), (17, 60), (11, 54)])
    tabN = K.knob('T', 'peg', 32, 14, 0, -1, r=5.0 * k)
    bW = K.knob('B', 'peg', 11, 44, -1, 0, r=3.0 * k)
    bE = K.knob('B', 'peg', 53, 44, 1, 0, r=3.0 * k)
    bS = K.knob('B', 'peg', 32, 60, 0, 1, r=2.7 * k)
    body = c.m(core, minus=(bW, bE, bS))
    c.add(body, ROCK)
    c.add(c.m(K.ell(32, 64, 30, 9)) & body, ROCKD)
    # cell motif: rosy rock blobs on the mauve rock
    blobs = c.m(K.ell(20, 24, 5, 4), K.ell(45, 44, 4, 3.2), K.ell(18, 44, 3, 2.4)) & body
    c.add(blobs, BLOB)
    c.add(c.m(K.ell(44, 25, 4, 3)) & body, ROCKD)
    # ember tip (the peg tab) + flame tongue
    tip = c.m(tabN, minus=(core,))
    c.add(tip, EMBER)
    fl = c.m(K.poly([(28, 6), (31, 0.5), (33, 4), (36, 1.5), (36.5, 6)]) if not c.small else K.poly([(27.5, 6), (31, 0.2), (33, 3.5), (36.5, 0.8), (36.5, 6)]))
    c.add(fl - c.m(core), FLAME)
    # glowing lava cracks running down from the ember tip
    w = 1.6 if not c.small else 2.8
    cracks = c.m(K.thick_path([(32, 14), (30, 20), (33, 25)], w),
                 K.thick_path([(19, 58), (21, 53), (25, 50), (23, 45)], w),
                 K.thick_path([(45, 58), (43, 53), (47, 49), (51, 48)], w),
                 K.thick_path([(14, 30), (18, 33)], w)) & body
    for p in cracks:
        c.px(p[0], p[1], HOT)
    if not c.small:
        for p in c.m(K.thick_path([(31, 18), (31.5, 21)], 0.9)) & body:
            c.px(p[0], p[1], LAVA)
    # face: glowing-ember eyes are felt eyes on a cream disc, cheeks warm
    c.eye(24.5, 34, disc=True)
    c.eye(39.5, 34, disc=True)
    c.smile(32, 40, K.UMBER)
    c.blush(19.5, 39)
    c.blush(43.5, 39)


K.render_pal(fn, 'pl-cwy-3', 'Scorch Sliver', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cwy-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cwy-3.png')
