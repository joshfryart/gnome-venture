"""pl-fyn-1 Firelily Flicker: corner-TB, round. A fire lily as a corner piece: flat W and S (sandy ash soil),
round tab N (the glowing yellow stamen tuft), round blank E cut into the green leaf band. Recurved petal tips curl
out at the top corners. Colours from cell 1-6 (sandy ash browns, olive and teal leaves) and the picture's trail flames."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FLAME = K.ramp('#f48b34')
EMBER = K.ramp('#d8481e')
GLOW = K.ramp('#f8d84a')
LEAF = K.ramp('#7c9a48')
TEALL = K.ramp('#1c6c80')
SAND = K.ramp('#c07f4b')
ASH = K.ramp('#6c3c3c')


def petal(cx, cy, ang, L, W):
    ca, sa = math.cos(ang), math.sin(ang)

    def f(x, y):
        u = (x - cx) * ca + (y - cy) * sa      # along the petal
        v = -(x - cx) * sa + (y - cy) * ca
        if u < 0 or u > L:
            return False
        w = W * math.sin(math.pi * min(1.0, u / L * 0.95 + 0.05)) ** 0.8
        return abs(v) < w
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 15, 51, 57)
    tabN = K.knob('T', 'round', 31, 15, 0, -1, r=5.0 * k)
    blankE = K.knob('B', 'round', 51, 47, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, minus=(blankE,))
    c.add(body, LEAF)
    c.add(body & c.m(K.rect(0, 51, 64, 64)), SAND)
    lv = c.m(K.poly([(12, 51), (14, 36), (20, 51)]), K.poly([(40, 51), (47, 38), (49, 51)]))
    c.add(lv & body, TEALL)
    c.edge(lv & body, TEALL[1])
    c.add(c.m(K.rect(29, 42, 33.5, 51)) & body, LEAF)
    cx, cy = 31, 30
    W = 8.2 if not c.small else 8.6
    # ember shade behind the bloom so the petal gaps read deep
    c.add(c.m(K.ell(cx, cy, 12, 12)) & body, EMBER)
    for i, ang in enumerate([-90, -30, 30, 90, 150, 210]):
        a = math.radians(ang)
        L = 22 if ang == -90 else 20
        m = c.m(petal(cx, cy, a, L, W)) & body
        if ang == -90:
            m |= c.m(tabN) & body
        c.add(m, FLAME)
        c.edge(m, EMBER[1])
        if not c.small:   # yellow flame stripe down each front petal
            c.line([(cx + math.cos(a) * 9, cy + math.sin(a) * 9), (cx + math.cos(a) * (L - 4), cy + math.sin(a) * (L - 4))], GLOW[2])
    c.add(c.m(tabN, minus=(core,)) & body, GLOW)
    # yellow throat = face
    th = c.m(K.ell(cx, cy, 8, 7)) & body
    c.add(th, GLOW)
    for p_ in th:
        c.edges.pop(p_, None)
    c.edge(th, FLAME[1])
    for (x, y) in [(16, 54), (24, 55), (37, 53), (44, 55)]:
        c.px(*c.P(x, y), ASH[0])
    c.eye(27.5, 29.5)
    c.eye(34.5, 29.5)
    c.smile(31, 33)
    if not c.small:
        c.blush(25, 33)
        c.blush(36, 33)


K.render_pal(fn, 'pl-fyn-1', 'Firelily Flicker', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-fyn-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-fyn-1.png')
