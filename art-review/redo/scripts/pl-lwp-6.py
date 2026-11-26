"""pl-lwp-6 Lookout Turret: whimsy-watchtower, hook knobs. The pagoda watchtower from The Long Wall Walk: a squat pink-stone tower
body (the piece core) under flared teal pagoda roofs with a gold pennant hook tab on top (N), a red lookout-balcony hook tab on E,
a hook blank cut into W and the gold gate as the S blank. Colours sampled from the picture (teal roofs, red storeys, gold windows,
pink-brick wall, sky-blue band from cell 11-2)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2

ROOF = ramp('#3c9b95')
ROOFD = ('#1f6b83', '#154c6c', '#3c9b95')
RED = ramp('#d04c50')
STONE = ramp('#d69a93')
BRICK = ramp('#a36068')
GOLDP = ramp('#f4c860')
SKY = '#a8d0e0'


def fn(c):
    k = 1.15 if c.small else 1.0
    body = rect(13, 27, 51, 57)
    roof1 = poly([(4, 30), (9, 25.5), (17, 23), (47, 23), (55, 25.5), (60, 30), (52, 29), (12, 29)])
    cap = rect(19, 14, 45, 24)
    roof2 = poly([(11, 17), (15, 13), (22, 10.5), (42, 10.5), (49, 13), (53, 17), (46, 16), (18, 16)])
    tabN = knob('T', 'hook', 32, 10.8, 0, -1, r=4.6 * k)
    tabE = knob('T', 'hook', 51, 41, 1, 0, r=5.0 * k)
    blkW = knob('B', 'hook', 13, 41, -1, 0, r=5.0 * k, flip=True)
    blkS = knob('B', 'round', 32, 57, 0, 1, r=4.4 * k)
    blanks = (blkW, blkS)
    allm = c.m(body, roof1, cap, roof2, tabN, tabE, minus=blanks)
    # stone body (lower storey) and red upper storey
    c.add(allm & c.m(body), STONE, stitch=None)
    c.add(allm & c.m(rect(13, 27, 51, 36)), RED)
    c.add(allm & c.m(tabE, minus=(body,)), RED)
    c.add(allm & c.m(cap), RED)
    c.add(allm & c.m(roof1), ROOF)
    c.add(allm & c.m(roof2), ROOF)
    c.add(allm & c.m(tabN, minus=(roof2,)), GOLDP)
    # brick courses on lower storey
    if not c.small:
        for yy in (45, 50):
            y = c.P(0, yy)[1]
            for x in range(c.P(14, 0)[0], c.P(50, 0)[0]):
                if (x, y) in allm:
                    c.px(x, y, STONE[1])
    # roof eave dark line
    for yy, x0, x1 in ((28.6, 10, 54), (15.6, 17, 47)):
        y = c.P(0, yy)[1]
        for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
            c.px(x, y, ROOFD[0])
    # gold windows on cap
    for wx in (23, 30, 37) if not c.small else (24, 32):
        x, y = c.P(wx, 18)
        w = 3 if not c.small else 2
        for dx in range(w):
            for dy in range(3 if not c.small else 2):
                c.px(x + dx, y + dy, GOLDP[0])
    # gold gate glow around S blank
    g = c.m(knob('B', 'round', 32, 57, 0, 1, r=4.4 * k + 1.4), rect(25, 49, 39, 57), minus=(blkS,)) & allm
    c.edge(c.m(rect(0, 0, 64, 64)) & g, GOLDP[0])
    for p in g:
        c.over[p] = GOLDP[1] if p not in c.edges else GOLDP[0]
    # face on the red storey
    c.eye(25, 31.5, disc=False)
    c.eye(39, 31.5, disc=False)
    c.smile(32, 38.5)
    c.blush(20, 38)
    c.blush(43, 38)


K.render_pal(fn, 'pl-lwp-6', 'Lookout Turret', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lwp-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-6.png')
