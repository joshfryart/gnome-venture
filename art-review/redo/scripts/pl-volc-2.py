# Spiced Bun Snooze: a sleepy iced spice bun that is an edge piece. Flat bottom = the bun's base resting on the green market
# ground (cell 1-7: leafy greens with dark cracks and red spice berries); keyhole tabs top (a dough knot) and left (a bulge of
# dough); keyhole blank on the right (a bite taken out). Bun browns from the volcano's spice terraces, red berries from the cell.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BUN = K.ramp('#c87a32')
CRUST = K.ramp('#a85a24')
ICING = ('#f6ead0', '#d8c4a0', '#ffffff')
LEAF = K.ramp('#8cc45a')
LEAFDK = '#3f7a34'
CRACK = '#2a3a1a'
BERRY = '#d8382a'
SPICE = '#e0702a'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = lambda x, y: (K.rect(13, 30, 59, 56)(x, y) or K.rect(25, 15, 47, 30)(x, y)
                         or K.ell(25.5, 30, 12.5, 15)(x, y) or K.ell(46.5, 30, 12.5, 15)(x, y))
    tN = K.knob('T', 'keyhole', 36, 15, 0, -1, r=6.2 * s, nw=3.2)
    tW = K.knob('T', 'keyhole', 13, 39, -1, 0, r=5.4 * s, nw=3.4)
    bE = K.knob('B', 'keyhole', 59, 39, 1, 0, r=5.6 * s, nw=3.0)
    body = c.m(core, tN, tW, minus=(bE,))
    c.add(body, BUN)
    # darker baked crust along the lower part
    c.add(c.m(K.rect(0, 45, 64, 51)) & body, CRUST)
    # leafy market ground: the flat bottom side
    ground = c.m(K.rect(0, 50, 64, 57)) & body
    c.add(ground, LEAF)
    if not c.small:
        for (x0, x1) in ((15, 19), (26, 31), (40, 44), (51, 56)):
            c.line([(x0, 53), (x1, 53)], LEAFDK)
        c.line([(22, 51), (23, 55)], CRACK)
        c.line([(47, 51), (46, 55)], CRACK)
    else:
        for x0 in (16, 34, 50):
            c.line([(x0, 53.5), (x0 + 4, 53.5)], LEAFDK)
    # hot-cross icing on the dome: a bar across and a bar up onto the dough-knot tab
    w = 4.2 if c.small else 3.6
    ice = c.m(K.rect(15, 22, 57, 22 + w), K.rect(36 - w / 2, 15.5, 36 + w / 2, 29.5)) & body
    c.add(ice, ICING)
    # spice berries (red, from the cell) in the four cross quadrants and spice flecks on the crust
    for (bx, by) in ((28, 19), (43, 19), (26, 29), (45, 29), (36, 9)):
        x, y = c.P(bx, by)
        for dx, dy in (((0, 0), (1, 0), (0, 1), (1, 1)) if not c.small else ((0, 0),)):
            c.px(x + dx, y + dy, BERRY)
    if not c.small:
        for (fx, fy) in ((16, 33), (55, 32), (20, 47), (50, 47), (32, 48), (42, 46), (6, 38)):
            c.px(*c.P(fx, fy), SPICE)
    # sleeping face: closed arc eyes, small o-mouth, blush
    for ex in (29, 43):
        x, y = c.P(ex, 35)
        if c.small:
            for dx, dy in ((-1, 0), (0, 1), (1, 1), (2, 0)):
                c.px(x + dx, y + dy, K.UMBER)
        else:
            for dx, dy in ((-3, -1), (-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0), (3, -1)):
                c.px(x + dx, y + dy, K.UMBER)
    mx, my = c.P(36, 41)
    if c.small:
        c.px(mx, my, K.UMBER2)
    else:
        for dx, dy in ((0, 0), (1, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            c.px(mx + dx, my + dy, K.UMBER2)
    c.blush(23, 39)
    c.blush(48, 39)

if __name__ == '__main__':
    K.render_pal(fn, 'pl-volc-2', 'Spiced Bun Snooze', '/home/user/gnome-venture/art-review/redo/out',
                 cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-volc-2-cell.png',
                 oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-volc-2.png')
