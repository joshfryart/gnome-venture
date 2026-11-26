"""pl-mgr-1 Tidewater Toes: corner-TB, round. A mangrove stump standing on two stilt-root toes.
Flat W and N (leaf cap), round blank S = the arch between the stilt roots, round tab E = a knobby root arm.
Bark in the cell's rust / maroon, toes dipped in the cell's teal tidewater, cap in mangrove green."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#aa6b4c')
BARKD = K.ramp('#8c4c3c')
MAROON = K.ramp('#5c2c3c')
WATER = K.ramp('#3a9494')
LEAF = K.ramp('#3f8a3a')
TAN = '#c88a5c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 9, 53, 57)
    tabE = K.knob('T', 'round', 53, 30, 1, 0, r=5.0 * k)
    blankS = K.knob('B', 'round', 31, 57, 0, 1, r=6.0 * k, nw=3.4)
    body = c.m(core, tabE, K.ell(9.5, 55, 3, 2.5), K.ell(52.5, 55, 3, 2.5), minus=(blankS,))
    c.add(body, BARK, stitch=MAROON[0])
    # root arm tab, a bit darker with a knuckle line
    arm = c.m(tabE, minus=(K.rect(0, 0, 53, 64),))
    c.add(arm, BARKD)
    # maroon bark grooves (vertical, like the cell's root)
    w = 3.0 if c.small else 2.4
    grooves = c.m(K.thick_path([(24, 40), (19, 42), (15, 46), (13, 52), (12, 57)], w),
                  K.thick_path([(38, 40), (43, 42), (47, 46), (49, 52), (50, 57)], w),
                  K.thick_path([(28, 41), (25, 46), (23, 52), (23, 57)], w),
                  K.thick_path([(34, 41), (37, 46), (39, 52), (39, 57)], w)) & body
    c.add(grooves, MAROON)
    # stilt-root toes: the two legs either side of the blank, darker, dipped in teal water
    legs = body & c.m(K.rect(0, 44, 64, 64))
    c.edge(legs, MAROON[0])
    water = body & c.m(K.rect(0, 51, 64, 64))
    c.add(water, WATER)
    if not c.small:
        y = c.P(0, 51)[1]
        for x in range(c.P(9, 0)[0], c.P(53, 0)[0]):
            if x % 3 != 1:
                c.px(x, y, WATER[2])
    else:
        y = c.P(0, 51)[1]
        for x in range(c.P(9, 0)[0], c.P(53, 0)[0]):
            c.px(x, y, WATER[2])
    # mangrove leaf canopy on the flat top: rounded leaf clumps hanging over the trunk
    cap = c.m(K.rect(9, 9, 53, 15), K.ell(14, 15, 6, 5), K.ell(25, 16, 6.5, 5.5), K.ell(37, 16, 6.5, 5.5), K.ell(48, 15, 6, 5))
    c.add(cap & body, LEAF)
    c.edge(cap & body, LEAF[1])
    if not c.small:
        for (lx, ly) in ((12, 12), (23, 13), (35, 13), (46, 12), (18, 17), (41, 17)):
            c.line([(lx, ly), (lx + 3, ly - 1)], LEAF[2])
    # face on the trunk
    c.eye(24, 29, disc=True)
    c.eye(38, 29, disc=True)
    c.smile(31, 35, K.UMBER)
    c.blush(19, 33)
    c.blush(42, 33)
    # little toes: pale nubs just above the waterline
    for tx in (13, 18, 43, 48):
        px, py = c.P(tx, 49.5)
        c.px(px, py, TAN)
        if not c.small:
            c.px(px + 1, py, TAN)


K.render_pal(fn, 'pl-mgr-1', 'Tidewater Toes', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-1.png')
