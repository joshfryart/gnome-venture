# pl-fyn-3 "Charcoal Twiglet": inner-TBTB, tri. An upright charred fynbos twig stump like a candle: the N tri tab is the
# glowing ember flame at its tip, the S tri tab is the sharpened twig point, tri blanks bite E and W into the wood.
# Top third charred plum-charcoal with ember cracks, lower part the cell's tan plank wood with plum grain lines; ember yellow from the cell spark.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

WOOD = ('#d89868', '#9c5c48', '#ecc090')
WOOD2 = ('#ba7a58', '#9c5c48', '#d89868')
CHAR = ('#4e3644', '#3a2632', '#6e4a58')
FLAME = ('#f48a34', '#d0581e', '#ffd45a')
EMBER = ('#ffd45a', '#f48a34', '#fff0b0')
PLUM = '#643c48'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(18, 19), (46, 19), (46, 52), (18, 52)])
    tabN = K.knob('T', 'tri', 32, 19, 0, -1, r=5.8 * k, nw=3.0)
    tabS = K.knob('T', 'tri', 32, 52, 0, 1, r=4.4 * k)
    blE = K.knob('B', 'tri', 46, 35, 1, 0, r=2.8 * k)
    blW = K.knob('B', 'tri', 18, 35, -1, 0, r=2.8 * k)
    cut = (blE, blW)
    twig = K.thick_path([(44, 27), (50, 24), (53, 18)], 3.4 if not c.small else 4.0)
    body = c.m(core, minus=cut)
    c.add(body, WOOD)
    c.add(c.m(tabS, minus=(K.rect(0, 0, 64, 52.5),)), WOOD2)
    # little side twig with a fynbos leaf tuft, charred at the end
    c.add(c.m(twig, minus=(core,)), WOOD2)
    c.add(c.m(K.ell(53.5, 16.5, 2.6 * k, 2.6 * k)), CHAR)
    # bark grain: vertical plum lines (cell's dark plank lines turned along the twig)
    for gx, y0, y1 in ((22, 42, 50), (42, 41, 50), (26, 30, 37), (38, 29, 36)):
        c.line([(gx, y0), (gx, y1)], PLUM)
    # charred top
    char = c.m(lambda x, y: 19 <= y < 26 + (2.2 if (x // 5) % 2 else 0) and 18 <= x < 46) & body
    c.add(char, CHAR)
    fl = c.m(tabN, minus=(K.rect(0, 19.5, 64, 64),))
    c.add(fl, FLAME)
    c.add(c.m(K.ell(32, 15.5, 2.4 * k, 3.0 * k)), EMBER)
    for pts in [[(22, 21), (24, 24)], [(40, 21), (42, 24)], [(31, 22), (32, 25)]]:
        c.line(pts, '#f48a34')
    # sleepy closed eyes + smile
    for ex in (26.5, 37.5):
        x, y = c.P(ex, 41)
        if c.small:
            c.px(x - 1, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y, K.UMBER)
        else:
            c.px(x - 2, y, K.UMBER); c.px(x - 1, y + 1, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y + 1, K.UMBER); c.px(x + 2, y, K.UMBER)
    c.blush(24, 44.5)
    c.blush(40, 44.5)
    c.smile(32, 45)


K.render_pal(fn, 'pl-fyn-3', 'Charcoal Twiglet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-fyn-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-fyn-3.png')
