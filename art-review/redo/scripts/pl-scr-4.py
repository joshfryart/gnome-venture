"""pl-scr-4 Scarab Leg March. Inner-TTTT, tri: a teal sand scarab seen from above, its domed shell IS the square piece.
N tri tab = the slate head (pointed clypeus), E + W tri tabs = two marching legs with pointed feet, S tri tab = a hind leg/tail tip.
Shell teal with the cell's yellow gem dots and centre seam, slate legs, sand-gold rim (cell 3-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

TEAL = K.ramp('#1a6a8c')
TEAL2 = K.ramp('#2ea8b0')
SLATE = ('#3a5a78', '#263c56', '#7a98a8')
SAND = K.ramp('#e8a868')
GEM = '#ffe090'
LEAF = '#6ac078'


def fn(c):
    k = 1.15 if c.small else 1.0
    def rr(x0, y0, x1, y1, r):
        return lambda x, y: (x0 <= x < x1 and y0 + r <= y < y1 - r) or (x0 + r <= x < x1 - r and y0 <= y < y1) or any(
            (x - cx) ** 2 + (y - cy) ** 2 < r * r for cx in (x0 + r, x1 - r) for cy in (y0 + r, y1 - r))
    core = rr(14, 16, 50, 54, 8)
    tabN = K.knob('T', 'tri', 32, 16, 0, -1, r=4.2 * k)
    tabE = K.knob('T', 'tri', 50, 37, 1, 0, r=4.2 * k)
    tabW = K.knob('T', 'tri', 14, 37, -1, 0, r=4.2 * k)
    tabS = K.knob('T', 'tri', 32, 54, 0, 1, r=4.0 * k)
    lw = 3.2 if c.small else 2.8
    # front and hind legs: short bent slate sticks at the corners (with E/W tabs = six legs)
    legs = [K.thick_path([(18, 25), (11, 22), (9, 16)], lw), K.thick_path([(46, 25), (53, 22), (55, 16)], lw),
            K.thick_path([(18, 47), (11, 51), (10, 57)], lw), K.thick_path([(46, 47), (53, 51), (54, 57)], lw)]
    c.add(c.m(*legs, minus=(core,)), SLATE)
    c.add(c.m(tabE, tabW, tabN, tabS, minus=(core,)), SLATE)
    body = c.m(core)
    c.add(body, TEAL)
    # two wing cases (elytra), lighter teal, split by the seam
    elL = body & c.m(K.rect(0, 27, 31.6, 64))
    elR = body & c.m(K.rect(32.6, 27, 64, 64))
    c.add(elL, TEAL2)
    c.add(elR, TEAL2)
    c.edge(elL, TEAL[1])
    c.edge(elR, TEAL[1])
    # head: slate cap across the top of the shell, eyes on it
    head = body & c.m(K.ell(32, 18, 13, 9.5))
    c.add(head, SLATE)
    c.edge(head, SLATE[1])
    # yellow gem dots on each wing case (the cell motif)
    for gx in (24.5, 39.5):
        cx, cy = c.P(gx, 38)
        w = 2 if c.small else 4
        for dx in range(w):
            for dy in range(w - (0 if c.small else 1)):
                c.px(cx - w // 2 + dx, cy - w // 2 + dy, GEM)
    if not c.small:
        for (gx, gy) in ((21, 47), (43, 47), (27, 31), (37, 31)):
            px, py = c.P(gx, gy)
            c.px(px, py, TEAL2[2])
        px, py = c.P(32, 50)
        c.px(px - 1, py, LEAF); c.px(px + 1, py, LEAF)
    c.eye(27, 20, disc=True)
    c.eye(37, 20, disc=True)


K.render_pal(fn, 'pl-scr-4', 'Scarab Leg March', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scr-4.png')
