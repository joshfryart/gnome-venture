"""pl-tgm-4 Tiger Wing Quad: inner-TTTT, tri. A tiger moth seen from above, wings spread into a square piece.
Tri tabs: N = furry head (antennae), E/W = forewing tips, S = striped abdomen tip. Forewings cream with brown tiger stripes,
hindwings red with blue eye spots (Temple of the Tiger Moth, cell 2-3: red wing, cream rim, brown)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CREAMW = K.ramp('#f0dcb0')
BROWN = K.ramp('#5a3424')
RED = K.ramp('#c8382a')
ORNG = K.ramp('#e8782a')
FUZZ = K.ramp('#d8a870')
BLUE = K.ramp('#3f8fd0')
SRC = '/home/user/gnome-venture/art-review/redo/_src/pl-tgm-4-cell.png'
OLD = '/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tgm-4.png'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 11, 15, 53, 52
    core = K.rect(x0, y0, x1, y1)
    tN = K.knob('T', 'tri', 32, y0, 0, -1, r=4.6 * k)
    tS = K.knob('T', 'tri', 32, y1, 0, 1, r=4.8 * k)
    tE = K.knob('T', 'tri', x1, 26, 1, 0, r=5.4 * k)
    tW = K.knob('T', 'tri', x0, 26, -1, 0, r=5.4 * k)
    mid = 34
    # forewings: cream with diagonal brown stripes, fanning out from the body
    fore = c.m(K.rect(x0, y0, x1, mid), tE, tW)
    c.add(fore, CREAMW)
    bw = 4.6 if not c.small else 5.2
    stripe = c.m(lambda x, y: y < mid and (((y - mid) + 0.6 * abs(x - 32) + 40) // bw) % 2 == 0)
    c.add(stripe & fore, BROWN)
    c.add(c.m(tE, tW, minus=(core,)), BROWN)
    c.edge(fore, BROWN[1])
    # hindwings: red, orange near the body, blue eye spots
    hind = c.m(K.rect(x0, mid, x1, y1))
    c.add(hind, RED)
    c.add(hind & c.m(K.ell(32, mid, 13, 10)), ORNG)
    c.edge(hind, RED[1])
    for sx in (19, 45):
        c.add(c.m(K.ell(sx, 44, 4.2, 4.2)), CREAMW)
        c.add(c.m(K.ell(sx, 44, 2.8, 2.8)), BLUE)
    if not c.small:
        for sx in (24, 40):
            c.add(c.m(K.ell(sx, 49, 1.9, 1.9)), BLUE)
    # body: fuzzy thorax + head tab, banded abdomen into the S tab
    c.add(c.m(K.ell(32, 25, 6, 8.5), tN, minus=(K.rect(0, 33, 64, 64),)) , FUZZ)
    abd = c.m(K.ell(32, 42, 3.6, 10), tS)
    c.add(abd, FUZZ)
    for by in (38, 43, 48, 54):
        c.add(abd & c.m(K.rect(0, by, 64, by + 2)), BROWN)
    # antennae curling out of the head tab
    w = 2.4 if not c.small else 2.8
    c.add(c.m(K.thick_path([(30, 9), (26, 4), (22, 3.5)], w)), BROWN)
    c.add(c.m(K.thick_path([(34, 9), (38, 4), (42, 3.5)], w)), BROWN)
    c.eye(29.2, 23.5)
    c.eye(35.2, 23.5)
    c.smile(32, 28)
    c.blush(27, 27)
    c.blush(36.5, 27)


print(K.render_pal(fn, 'pl-tgm-4', 'Tiger Wing Quad', '/home/user/gnome-venture/art-review/redo/out', cellfile=SRC, oldfile=OLD))
