# pl-jrc-4 "Softpad Prints": a jaguar paw print pressed into the sandy root path that IS an inner-TTTT piece.
# Double tabs N, W, E, S are sand clods; four mauve toe beans arc over a trilobed heel pad that carries the face.
# Core = the sand path (#8c6a52 from cell 3-7), pads = the mauve cave rock (#5c4850), pebble specks in slate.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#8c6a52')
SANDL = K.ramp('#aa8765')
PAD = K.ramp('#6a5260')
SLATE = '#54506c'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 17, 51, 51)
    tN = K.knob('T', 'double', 32, 17, 0, -1, r=6.0 * s)
    tW = K.knob('T', 'double', 13, 27, -1, 0, r=5.0 * s)
    tE = K.knob('T', 'double', 51, 27, 1, 0, r=5.0 * s)
    tS = K.knob('T', 'double', 32, 51, 0, 1, r=5.6 * s)
    body = c.m(core, tN, tW, tE, tS)
    c.add(c.m(core), SAND, stitch=None if c.small else SANDL[0])
    # all four double tabs are sand clods of the path
    for t, cut in ((tW, K.rect(0, 0, 13.5, 64)), (tE, K.rect(50.5, 0, 64, 64)), (tS, K.rect(0, 50.5, 64, 64)), (tN, K.rect(0, 0, 64, 17.5))):
        c.add(c.m(t) & c.m(cut), SAND)
    # four toe beans in an arc across the upper core
    beans = [(19.5, 28, 4.0, 5.0), (27.5, 23, 4.0, 5.0), (36.5, 23, 4.0, 5.0), (44.5, 28, 4.0, 5.0)]
    for (bx, by, rx, ry) in beans:
        c.add(c.m(K.ell(bx, by, rx, ry)) & body, PAD)
        hx, hy = c.P(bx - rx * 0.4, by - ry * 0.45)
        c.px(hx, hy, PAD[2])
    # heel pad: wide trilobed mass in the lower core
    heel = c.m(K.ell(32, 39, 11, 7.5), K.ell(23.5, 44, 5.5, 5), K.ell(40.5, 44, 5.5, 5), K.ell(32, 45.5, 6, 4.5))
    c.add(heel & body, PAD)
    # pebble specks on the sand
    for (x, y) in [(16, 36), (48, 37), (17, 48), (47, 48), (32, 30), (20, 20), (44, 20)]:
        X, Y = c.P(x, y)
        c.px(X, Y, SLATE)
        if not c.small:
            c.px(X + 1, Y, SLATE)
    # face on the heel pad
    c.eye(27.5, 39, disc=True)
    c.eye(36.5, 39, disc=True)
    c.smile(32, 44, K.CREAM)
    c.blush(22, 42)
    c.blush(41, 42)


K.render_pal(fn, 'pl-jrc-4', 'Softpad Prints', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-4.png')
