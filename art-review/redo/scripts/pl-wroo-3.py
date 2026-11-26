# pl-wroo-3 "Vine Bead Dangle": inner-TBTB keyhole. A round-cornered green bead that IS the piece, threaded on a vine:
# N tab = the vine's knot where it enters the bead (vine runs on up to the canopy with a leaf), S tab = the vine's tail
# tassel, W and E keyhole blanks cut into the bead. Colours: the cell's mossy pole greens (#4a8a58 / #2e6a48) on canopy teal.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BEAD = K.ramp('#4a8a58')
MOSS = K.ramp('#74845f')
VINE = K.ramp('#2e6a48')
LEAF = K.ramp('#5aa04a')
BAND = K.ramp('#1e4a3c')
SHINE = '#c4e6b4'


def rrect(x0, y0, x1, y1, r):
    return lambda x, y: (x0 <= x < x1 and y0 + r <= y < y1 - r) or (x0 + r <= x < x1 - r and y0 <= y < y1) or any(
        (x - cx) ** 2 + (y - cy) ** 2 < r * r for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r), (x0 + r, y1 - r), (x1 - r, y1 - r)))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(9, 16, 55, 54, 12)
    tabN = K.knob('T', 'keyhole', 32, 16, 0, -1, r=4.4 * k)
    tabS = K.knob('T', 'keyhole', 32, 54, 0, 1, r=4.6 * k)
    blW = K.knob('B', 'keyhole', 9, 35, -1, 0, r=3.8 * k)
    blE = K.knob('B', 'keyhole', 55, 35, 1, 0, r=3.8 * k)
    vw = 3.0 if not c.small else 3.6
    # vine strand from the canopy down into the N knot
    c.add(c.m(K.thick_path([(32, 8), (31, 4), (33, 0.5)], vw)), VINE)
    # leaf on the vine
    c.add(c.m(K.poly([(33, 5), (40, 1.5), (45, 3), (41, 7.5), (35, 7.5)])), LEAF)
    # bead body
    body = c.m(core, minus=(blW, blE))
    c.add(body, BEAD, stitch=None if c.small else MOSS[2])
    # knots (tabs) in darker vine green
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 14, 64, 17))), VINE)
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 53, 64, 56))), VINE)
    # vine bands wrapping round the bead top and bottom (the strand passing through)
    bt = c.m(K.ell(32, 17, 9, 3.2)) & body
    bb = c.m(K.ell(32, 53, 9, 3.2)) & body
    c.add(bt, BAND)
    c.add(bb, BAND)
    # moss mottle on the bead (64 only)
    if not c.small:
        for (x, y) in body:
            if 20 <= y < 52 and (x * 7 + y * 3) % 11 == 0 and not (20 <= x <= 44 and 28 <= y <= 42):
                c.px(x, y, MOSS[0])
    # glossy bead shine, upper left
    if not c.small:
        for p in ((15, 24), (16, 23), (17, 22), (18, 22), (15, 25), (15, 26), (19, 22)):
            c.px(*p, SHINE)
    else:
        for p in ((8, 13), (8, 14), (9, 12), (10, 12)):
            c.px(*p, SHINE)
    # face
    c.eye(26, 34)
    c.eye(38, 34)
    c.smile(32, 39.5)
    c.blush(20, 38)
    c.blush(43, 38)


K.render_pal(fn, 'pl-wroo-3', 'Vine Bead Dangle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-3.png')
