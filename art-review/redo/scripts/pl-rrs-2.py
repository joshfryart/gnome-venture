"""pl-rrs-2 Galah Chatter: edge-TTB, peg. A galah IS the piece: flat S = the red-rock ledge it perches on (cell ochre + plum),
N peg tab = its pale pink crest, W peg tab = its horn beak, E peg blank bites into the grey wing. Rose-pink face and breast
(the picture's salmon sky pink), grey back and wing, ochre/plum ledge from cell 2-1."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, thick_path

PINK = ramp('#e2607c')
CREST = ramp('#f6c4cc')
GREY = ramp('#a09eae')
HORNB = ramp('#e8dcc8')
ROCK = ramp('#cc5e45')
PLUM = '#7a2c44'
OCHRE_L = '#e8784a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (rect(12, 26, 52, 58)(x, y) or ell(28, 27, 16.5, 11)(x, y) or rect(22, 17, 46, 30)(x, y)
                         or ell(40, 28, 12, 10)(x, y)) and 12 <= x < 52
    tabN = knob('T', 'peg', 27, 17, 0, -1, r=5.0 * k)
    tabW = knob('T', 'peg', 12, 31, -1, 0, r=4.2 * k)
    blankE = knob('B', 'peg', 52, 37, 1, 0, r=4.4 * k)
    hook = poly([(3.5, 29), (8, 28.5), (10, 34), (7.5, 39), (5.5, 34.5)])
    tuft = ell(24.5, 7.5, 5.5, 3.0)
    body = c.m(core, tabN, tabW, hook, tuft, minus=(blankE,))
    # pink bird first (whole body), then grey wing, crest, beak, ledge
    c.add(body, PINK, stitch=PINK[2])
    wing = c.m(ell(41, 36, 12.5, 15), poly([(36, 46), (52, 40), (54, 54), (40, 54)])) & body
    c.add(wing, GREY, stitch=GREY[2] if False else None)
    c.edge(wing, GREY[1])
    # feather scallops on the wing
    if not c.small:
        for (gx, gy) in ((38, 30), (44, 28), (40, 38), (46, 44), (38, 46)):
            x, y = c.P(gx, gy)
            for dx in range(-2, 3):
                c.px(x + dx, y + (1 if abs(dx) == 2 else 0), GREY[1])
    else:
        for (gx, gy) in ((40, 32), (42, 43)):
            x, y = c.P(gx, gy)
            for dx in range(-1, 2):
                c.px(x + dx, y, GREY[1])
    crest = c.m(tabN, tuft, minus=(core,)) | (body & c.m(ell(27, 19, 14, 5.5)))
    c.add(crest - wing, CREST)
    # crest feather lines
    for fx in ((25, 29) if not c.small else (27,)):
        c.line([(fx - 1.5, 7), (fx, 15)], CREST[1])
    beak = (c.m(tabW, hook, minus=(core,)) | (c.m(tabW) & c.m(rect(10, 0, 13.5, 64)))) & body
    c.add(beak, HORNB)
    c.edge(beak, HORNB[1])
    for (x, y) in c.m(hook, minus=(core,)):
        if y >= c.P(0, 34)[1]:
            c.px(x, y, HORNB[1])
    # beak split
    if not c.small:
        c.line([(4, 31), (13, 31)], HORNB[1])
    # ledge (flat side)
    ledge = body & c.m(rect(0, 51, 64, 64))
    c.add(ledge, ROCK)
    if not c.small:
        for (gx, gy, w) in ((16, 55, 5), (30, 56, 6), (43, 54, 4)):
            x, y = c.P(gx, gy)
            for dx in range(w):
                c.px(x + dx, y, PLUM)
        for (gx, gy) in ((22, 53), (38, 53)):
            x, y = c.P(gx, gy)
            c.px(x, y, OCHRE_L)
            c.px(x + 1, y, OCHRE_L)
    else:
        x, y = c.P(28, 55.5)
        for dx in range(4):
            c.px(x + dx, y, PLUM)
    # feet gripping the ledge
    for fx in (24, 34):
        x, y = c.P(fx, 51)
        for dx in range(-1, 2) if not c.small else range(0, 2):
            c.px(x + dx, y, GREY[1])
            c.px(x + dx, y - 1, GREY[0])
    # face: pale eye ring, eye, blush
    ex, ey = 20, 27
    rx, ry = c.P(ex, ey)
    ring = c.m(ell(ex, ey - 0.5, 4.2 if not c.small else 4.6, 4.2 if not c.small else 4.6))
    c.add(ring & body - beak, CREST)
    c.eye(ex, ey)
    c.blush(22, 34)



K.render_pal(fn, 'pl-rrs-2', 'Galah Chatter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrs-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrs-2.png')
