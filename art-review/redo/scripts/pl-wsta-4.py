"""pl-wsta-4 "Cream Sail Billow": inner-TTTT, double knobs. A billowing cream sail IS the piece: square sail body with red diagonal
hatching and the red cross mark (from the canoe's sail), a wooden mast down the W side, the red yard + pennant as the N double tab,
the orange canoe hull stub as the S double tab, cream billow lobes as the E and W tabs. Dusk purple/pink of cell 6-4 on the hull band."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

SAIL = K.ramp('#f2e2b8')
SAILSH = K.ramp('#dabc91')
RED = K.ramp('#d2665c')
PARROT = K.ramp('#f06562')
WOODR = K.ramp('#e3914f')
MAST = K.ramp('#a86a3a')
DUSK = K.ramp('#8a5aa0')
PINK = K.ramp('#c874a0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(14, 14), (46, 14), (50, 22), (53, 32), (51, 42), (46, 50), (14, 50)])
    tN = knob('T', 'double', 31, 14, 0, -1, r=5.2 * k)
    tS = knob('T', 'double', 31, 50, 0, 1, r=5.2 * k)
    tE = knob('T', 'double', 52.5, 32, 1, 0, r=5.0 * k)
    tW = knob('T', 'double', 14, 32, -1, 0, r=5.0 * k)
    body = c.m(core, tE, tW)
    c.add(body, SAIL, stitch=None if c.small else SAILSH[0])
    # billow shade: a soft belly crescent on the lower right of the sail
    c.add(c.m(ell(46, 36, 9, 12), tE) & body & c.m(lambda x, y: x + 0.6 * y > 64), SAILSH)
    # red diagonal hatching (the sail's rigging lines)
    step = 9 if not c.small else 10
    for (x, y) in c.m(core):
        X, Y = (x + 0.5) / c.k, (y + 0.5) / c.k
        if int(X + Y) % step == 0 and Y > 16:
            c.px(x, y, RED[0] if not c.small else RED[1])
    # the red cross mark
    cx, cy = 38, 25
    c.line([(cx - 4, cy), (cx + 4, cy)], RED[1])
    c.line([(cx, cy - 4), (cx, cy + 4)], RED[1])
    if c.small:
        c.line([(cx - 3, cy + 1.8), (cx + 3, cy + 1.8)], RED[1])
    # mast down the W edge, yard across the top
    c.add(c.m(rect(14, 14, 17.5 if not c.small else 18.5, 50)) | c.m(tW, minus=(rect(14, 0, 64, 64),)), MAST)
    c.add(c.m(rect(15, 10, 17.5 if not c.small else 18.5, 14)), MAST)
    c.add(c.m(rect(12, 12, 50, 15.5 if not c.small else 16.5)), RED)
    # N tab: red pennant knot at the masthead
    c.add(c.m(tN, minus=(rect(0, 12, 64, 64),)), PARROT)
    # S tab: a slice of the orange canoe hull, with a dusk band below the sail
    c.add(c.m(rect(14, 46, 50, 50.5)), DUSK)
    c.add(c.m(tS, minus=(rect(0, 0, 64, 50.5),)), WOODR)
    c.add(c.m(rect(30, 50, 33, 53.5)), MAST)
    if not c.small:
        for x in range(c.P(26, 0)[0], c.P(37, 0)[0]):
            if x % 3 == 0:
                c.px(x, c.P(0, 55)[1], WOODR[1])
    # face on the calm middle of the sail
    c.eye(26, 31)
    c.eye(36, 31)
    c.smile(31, 36)
    c.blush(22.5, 35)
    c.blush(39, 35)
    # two dusk stars stitched on the sail
    c.px(*c.P(44, 19), '#9ec8ff')
    c.px(*c.P(22, 21), '#9ec8ff')


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wsta-4', 'Cream Sail Billow', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsta-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsta-4.png'))
