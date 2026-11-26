# Claw Sail: a crab-claw sail boat that IS an inner-TTTT piece (tri knobs). Square core = striped sail
# (pink / orange / tan diagonal stripes from cell 4-2) bounded by two brown spars in a V whose tips are the
# rounded crab-claw horns at the top corners; wooden outrigger hull with a big grin forms the bottom band.
# Tabs: top (pennant, between the claw horns), left and right (sail), bottom (keel under the hull).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#ee6f78')
ORNG = K.ramp('#f37a2b')
TAN = K.ramp('#e8c48a')
WOODR = K.ramp('#a06539')
SPAR = K.ramp('#74472a')
RUST = '#c2491e'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 5.0 * k
    # sail core with a shallow concave top whose corners rise into rounded claw horns
    sail = K.poly([(14, 42), (14, 14), (12, 6), (14, 3), (20, 8), (26, 14), (32, 16), (38, 14), (44, 8), (50, 3), (52, 6), (50, 14), (50, 42)])
    hornL = K.ell(15, 6, 3.0, 3.0)
    hornR = K.ell(49, 6, 3.0, 3.0)
    hull = K.poly([(5, 37), (9, 41), (55, 41), (59, 37), (60, 40), (54, 49), (48, 53), (16, 53), (10, 49), (4, 40)])
    tT = K.knob('T', 'tri', 32, 16, 0, -1, r=r)
    tL = K.knob('T', 'tri', 14, 26, -1, 0, r=r)
    tR = K.knob('T', 'tri', 50, 26, 1, 0, r=r)
    tB = K.knob('T', 'tri', 32, 53, 0, 1, r=r)
    curlL = K.thick_path([(14, 4), (18, 3), (21, 5)], 3.0)
    curlR = K.thick_path([(50, 4), (46, 3), (43, 5)], 3.0)
    sailm = c.m(sail, hornL, hornR, curlL, curlR, tT, tL, tR)
    # diagonal stripes like the cell (bands running down-left)
    W = 7.0
    def band(i):
        return lambda x, y: int(((x - y * 0.55) + 200) // W) % 3 == i
    for i, rp in enumerate((PINK, ORNG, TAN)):
        c.add(sailm & c.m(band(i)), rp)
    hm = c.m(hull, tB)
    c.add(hm, WOODR, stitch='#d19a5a')
    c.edge(hm, SPAR[1])
    # the V of spars: crab-claw sail booms meeting at the hull
    sw = 3.0 if c.small else 2.6
    c.add(c.m(K.thick_path([(31, 42), (15, 5)], sw), K.thick_path([(33, 42), (49, 5)], sw), K.ell(32, 42, 2.4, 2.0)), SPAR)
    # pennant tip on the top tab in rust
    pen = c.m(K.knob('T', 'tri', 32, 16, 0, -1, r=r)) - c.m(K.rect(0, 11, 64, 64))
    c.add(pen, K.ramp(RUST))
    # face on the hull: eyes + very large grin
    c.eye(23, 46.5, disc=True)
    c.eye(41, 46.5, disc=True)
    cx, cy = c.P(32, 48.5)
    if not c.small:
        for dx in range(-6, 7):
            c.px(cx + dx, cy + 1, K.UMBER)
        for dx in range(-5, 6):
            c.px(cx + dx, cy + 2, '#c8202a' if abs(dx) < 4 else K.UMBER)
        for dx in range(-3, 4):
            c.px(cx + dx, cy + 3, K.UMBER)
        c.px(cx - 7, cy, K.UMBER); c.px(cx + 7, cy, K.UMBER)
        c.blush(18, 49); c.blush(45, 49)
    else:
        for dx in range(-3, 4):
            c.px(cx + dx, cy, K.UMBER)
        for dx in range(-2, 3):
            c.px(cx + dx, cy + 1, K.UMBER)
        c.px(cx - 4, cy - 1, K.UMBER); c.px(cx + 4, cy - 1, K.UMBER)


K.render_pal(fn, 'cs-claw-sail', 'Claw Sail', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/cs-claw-sail-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/cs-claw-sail.png')
