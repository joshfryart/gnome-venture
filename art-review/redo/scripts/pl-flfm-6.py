import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""pl-flfm-6 Garland Florist, whimsy-marigold, peg.
A marigold flower head IS the piece: square core with a ruffled petal rim. N peg tab = the crown of her pink (roof) hat,
E peg tab = an oar blade, W peg blank cut into the petals, flat S = a little rowing boat on the teal lake (cell 6-6)."""

GOLD = K.ramp('#f8b828')
ORANGE = K.ramp('#ee7a1c')
HEART = K.ramp('#c8561a')
PINK = K.ramp('#d8506a')
WOOD = K.ramp('#b07a3a')
LAKE = K.ramp('#2a9aa8')
LEAF = K.ramp('#3f9a4a')
CREAMY = '#f4f0e4'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 13, 51, 19, 48
    core = K.rect(x0, y0, x1, y1)
    # ruffled petal rim: discs centred on the core border
    petals = []
    for i in range(6):
        t = x0 + 3.5 + i * (x1 - x0 - 7) / 5
        petals.append(K.ell(t, y0, 4.0, 4.4))
    for i in range(5):
        t = y0 + 3 + i * (y1 - y0 - 6) / 4
        petals.append(K.ell(x0, t, 4.4, 3.9))
        petals.append(K.ell(x1, t, 4.4, 3.9))
    tabN = K.knob('T', 'peg', 32, 11, 0, -1, r=4.6 * k)
    tabE = K.knob('T', 'peg', 56, 33, 1, 0, r=4.2 * k)
    blankW = K.knob('B', 'peg', 9, 33, -1, 0, r=4.2 * k)
    hull = K.poly([(6, 47), (58, 47), (52, 57), (12, 57)])
    water = K.rect(4, 56, 60, 61)
    body = c.m(core, *petals, minus=(blankW,))
    c.add(body, GOLD, stitch=None)
    # orange inner petal ring and dark heart
    lobes = [K.ell(32 + 13.5 * K.math.cos(K.math.radians(a)), 32 + 11 * K.math.sin(K.math.radians(a)), 4.6, 4.2) for a in range(0, 360, 30)]
    ring = body & c.m(K.ell(32, 32, 13.5, 11), *lobes)
    c.add(ring, ORANGE)
    heart = c.m(K.ell(32, 33, 11, 9))
    c.add(heart, HEART)
    if not c.small:
        # petal ruffle lines on the gold rim
        for ang in range(15, 360, 30):
            a = K.math.radians(ang)
            c.line([(32 + 15 * K.math.cos(a), 32 + 12.5 * K.math.sin(a)), (32 + 20 * K.math.cos(a), 32 + 17 * K.math.sin(a))], GOLD[1])
        c.edge(ring, ORANGE[1])
    # leaves at the boat rim
    c.add(c.m(K.ell(17, 47, 6, 2.8), K.ell(47, 47, 6, 2.8)), LEAF)
    # oar (E tab): shaft through the rim
    c.add(c.m(tabE, minus=(core, *petals)) | c.m(K.rect(52, 31.2, 58, 34.8)), WOOD)
    # boat and lake
    c.add(c.m(hull), WOOD)
    c.add(c.m(water), LAKE)
    if not c.small:
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            c.px(x, c.P(0, 51)[1], WOOD[1])
        y = c.P(0, 58.5)[1]
        for x in range(c.P(5, 0)[0], c.P(59, 0)[0]):
            if x % 5 in (0, 1):
                c.px(x, y, LAKE[2])
    else:
        for x in range(c.P(14, 0)[0], c.P(50, 0)[0]):
            c.px(x, c.P(0, 51.5)[1], WOOD[1])
    # pink hat: brim + crown (N tab) with a cream band
    brim = c.m(K.ell(32, 16, 13, 3.2))
    crown = c.m(tabN, K.rect(26.5, 10, 37.5, 16))
    c.add(brim | crown, PINK)
    c.add(c.m(K.rect(26.5, 12.4, 37.5, 14.6 if not c.small else 15.2)), (CREAMY, '#c9c5bc', '#ffffff'))
    # face on the heart
    c.eye(28, 32, disc=True)
    c.eye(36, 32, disc=True)
    c.smile(32, 36, '#f4d08a')
    c.blush(23.5, 36)
    c.blush(40, 36)


K.render_pal(fn, 'pl-flfm-6', 'Garland Florist', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flfm-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flfm-6.png')
