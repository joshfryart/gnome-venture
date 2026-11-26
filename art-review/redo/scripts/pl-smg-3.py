# Crystal Pendant: a carved salt-crystal chandelier pendant that is an inner piece (inner-TBTB, round knobs).
# Top tab = maroon hanging loop/cap, bottom tab = glowing cream drop tip, left + right blanks cut into the crystal body.
# Colours: cell 6-2 maroon tunnel wall #6a3e48 + glowing lamp cream #e1cca1; picture's pink-white salt crystals #f2dcdf / lavender #ac9ab1.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MAROON = K.ramp('#6a3e48')
SALT = ('#f2dcdf', '#ac9ab1', '#fbf3f6')
SALTL = ('#f8edf8', '#c9b8cc', '#ffffff')
SALTD = ('#ac9ab1', '#86748c', '#c8b8cc')
GLOW = ('#e1cca1', '#ab8c79', '#f4e8c4')
BRASS = K.ramp('#c8964a')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 14, 50, 17, 49
    # hexagonal-prism crystal core: square with small chamfers
    core = K.poly([(x0 + 3, y0), (x1 - 3, y0), (x1, y0 + 3), (x1, y1 - 9), (x1 - 10, y1), (x0 + 10, y1), (x0, y1 - 9), (x0, y0 + 3)])
    top = K.knob('T', 'round', 32, y0, 0, -1, r=4.5 * k)
    bot = K.knob('T', 'round', 32, y1, 0, 1, r=4.5 * k)
    lb = K.knob('B', 'round', x0, 31, -1, 0, r=4.0 * k)
    rb = K.knob('B', 'round', x1, 31, 1, 0, r=4.0 * k)
    body = c.m(core, minus=(lb, rb))
    c.add(body, SALT)
    # facets: left light facet, right shadow facet
    left = c.m(K.poly([(0, 0), (23, 0), (27, 64), (0, 64)]), minus=(lb,)) & body
    right = c.m(K.poly([(41, 0), (64, 0), (64, 64), (37, 64)]), minus=(rb,)) & body
    # warm lamp glow inside the middle facet (cell 6-2 light)
    glow = c.m(K.ell(32, 46, 4.5, 5)) & body
    glow -= left | right
    c.add(glow, ('#f4e8c4', '#e1cca1', '#fbf4e0'))
    c.add(left, SALTL)
    c.add(right, SALTD)
    c.edge(left, '#9a86a0')
    c.edge(right, '#86748c')
    # glow drop tip (bottom tab) from the lamp light
    tip = c.m(bot, minus=(core,))
    c.add(tip, GLOW)
    tr = c.m(K.rect(32, 0, 64, 64)) & tip
    c.add(tr, ('#c3a88b', '#ab8c79', '#e1cca1'))
    # maroon cap band + hanging loop (top tab)
    cap = c.m(K.rect(x0 - 1, y0 - 1, x1 + 1, y0 + 5), minus=(lb, rb)) & body
    loop = c.m(top, minus=(core,))
    c.add(cap | loop, MAROON)
    c.edge(cap, MAROON[1])
    # brass ring-hole in the loop
    hx, hy = c.P(32, y0 - 6.2 * k)
    if not c.small:
        for p in ((hx - 1, hy), (hx, hy), (hx - 1, hy - 1), (hx, hy - 1)):
            c.cut.add(p)
    else:
        c.px(hx, hy, BRASS[0])
    # cap studs
    for sx in (20, 32, 44):
        a = c.P(sx, y0 + 2.5)
        c.px(a[0], a[1], BRASS[2] if not c.small else BRASS[0])
    # little glints on the crystal
    if not c.small:
        g = c.P(18, 26)
        for d in ((0, 0), (0, 1), (0, 2), (-1, 1), (1, 1)):
            c.px(g[0] + d[0], g[1] + d[1], '#ffffff')
    # face on the middle facet
    c.eye(28, 30, look=(0, 0))
    c.eye(36.5, 30, look=(0, 0))
    c.blush(25.5, 34.5)
    c.blush(38.5, 34.5)
    c.smile(32, 35)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-smg-3', 'Crystal Pendant', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-3.png')
    print(rep)
