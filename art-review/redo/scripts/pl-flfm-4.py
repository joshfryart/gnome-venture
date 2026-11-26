"""pl-flfm-4 Petal Heap: inner-TTTT peg. A flower-market boat heaped with pale blossoms: wooden hull (lower core) + leafy flower mound
(upper core); N peg = a big white blossom crowning the heap, E/W pegs = pink blooms spilling over the gunwale, S peg = the keel.
Lake turquoise water lapping the hull (cell 10-5), cream/pink/white flowers on leaf green, hull wood from the picture's stalls."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WOODR = K.ramp('#a8683a')
LEAF = K.ramp('#4f9a3c')
PETW = K.ramp('#f4eee0')
PINK = K.ramp('#e87aa0')
CREAMY = K.ramp('#f2d878')
WATER = K.ramp('#3fb0c4')
ROSE = '#c8506e'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 18, 52, 52)
    tabN = K.knob('T', 'peg', 32, 18, 0, -1, r=5.2 * k)
    tabE = K.knob('T', 'peg', 52, 29, 1, 0, r=4.4 * k)
    tabW = K.knob('T', 'peg', 12, 29, -1, 0, r=4.4 * k)
    tabS = K.knob('T', 'peg', 32, 52, 0, 1, r=4.0 * k)
    bow = (lambda x, y: x < 16 and y > 46 and (x - 16) ** 2 + (y - 46) ** 2 > 16,
           lambda x, y: x > 48 and y > 46 and (x - 48) ** 2 + (y - 46) ** 2 > 16)
    body = c.m(core, tabN, tabE, tabW, tabS, minus=bow)
    # leafy heap (upper core)
    c.add(c.m(K.rect(12, 18, 52, 37)), LEAF)
    # hull (lower core) + keel
    hull = c.m(K.rect(12, 36, 52, 52), tabS, minus=bow)
    c.add(hull, WOODR, stitch=None)
    # gunwale rail
    c.add(c.m(K.rect(12, 35, 52, 38.5)), K.ramp('#7a4a24'))
    # plank seam
    y = c.P(0, 44)[1]
    for x in range(c.P(12, 0)[0] + 1, c.P(52, 0)[0] - 1):
        if (x, y) in hull:
            c.px(x, y, WOODR[1])
    # water lapping at the waterline
    c.add(c.m(K.rect(12, 48.5, 52, 52), minus=bow), WATER)
    c.add(c.m(tabS, minus=(core,)), K.ramp('#7a4a24'))
    if not c.small:
        yy = c.P(0, 49.5)[1]
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            if x % 4 in (1, 2):
                c.px(x, yy, WATER[2])
    # tab blooms
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 15, 64, 19))), PETW)
    c.add(c.m(tabE, minus=(core,)), PINK)
    c.add(c.m(tabW, minus=(core,)), PINK)
    # flowers heaped on the leaves, five-petal blossoms packed tight: (x, y, ramp)
    if not c.small:
        fl = [(17, 21.5, PETW), (32, 20.5, CREAMY), (47, 21.5, PETW), (24.5, 24.5, PINK), (39.5, 24.5, PETW),
              (17, 30, CREAMY), (32, 28.5, PETW), (47, 30, PINK), (24.5, 33, PETW), (39.5, 33, CREAMY)]
        pr, po = 2.3, 2.4
    else:
        fl = [(18, 22, PETW), (32, 21, CREAMY), (46, 22, PETW), (25, 29, PINK), (39, 29, PETW)]
        pr, po = 2.9, 3.0
    for (x, y, rp) in fl:
        m = c.m(K.ell(x, y - po, pr, pr), K.ell(x + po, y - 0.6, pr, pr), K.ell(x - po, y - 0.6, pr, pr),
                K.ell(x + po * 0.6, y + po * 0.85, pr, pr), K.ell(x - po * 0.6, y + po * 0.85, pr, pr)) & body
        c.add(m, rp)
        c.edge(m, rp[1])
        cx, cy = c.P(x, y)
        c.px(cx, cy, '#e8a317')
        if not c.small:
            c.px(cx - 1, cy, '#e8a317')
    # big crown blossom centre + side bloom centres
    cx, cy = c.P(32, 13.5 if not c.small else 13)
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)) if not c.small else ((0, 0), (1, 0)):
        c.px(cx + dx - 1, cy + dy, '#e8a317')
    c.px(*c.P(57.5, 29), ROSE)
    c.px(*c.P(6.5, 29), ROSE)
    # face on the hull
    c.eye(25, 42.5, disc=True)
    c.eye(39, 42.5, disc=True)
    c.smile(32, 45.5, K.UMBER)
    c.blush(20, 45.5)
    c.blush(43, 45.5)


K.render_pal(fn, 'pl-flfm-4', 'Petal Heap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flfm-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flfm-4.png')
