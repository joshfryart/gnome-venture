# pl-fyn-5 "Sunset Gap": a square puff of purple fynbos smoke (inner piece, round blanks on all four sides) with a
# gap torn in it where a sleepy dusk sun peeks over a dark ridge. Colours: the cell's smoke purples/pinks, the picture's sunset orange.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/art-review/redo/_src/'
SMOKE = K.ramp('#7a4a8c')
PINK = K.ramp('#c0689c')
MAUVE = K.ramp('#9d5994')
RIDGE = K.ramp('#463066')
SUN = ('#f0a050', '#e0704a', '#f8d080')
GLOW = K.ramp('#e8805a')


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.2 * k
    x0, y0, x1, y1 = 9, 10, 55, 55
    # core with puffy smoke corners (rounded, not spiky)
    core = [K.rect(x0 + 4, y0, x1 - 4, y1), K.rect(x0, y0 + 4, x1, y1 - 3)]
    for cx, cy in ((x0 + 4, y0 + 4), (x1 - 4, y0 + 4), (x0 + 4, y1 - 3), (x1 - 4, y1 - 3)):
        core.append(K.ell(cx, cy, 4.5, 4.5))
    # little smoke puffs bulging on the top edge, beside the blank
    core += [K.ell(18, y0 + 1, 5.5, 3.5), K.ell(46, y0 + 1, 5.5, 3.5)]
    blanks = [K.knob('B', 'round', 32, y0 - 1, 0, -1, r=r), K.knob('B', 'round', 32, y1, 0, 1, r=r),
              K.knob('B', 'round', x0, 33, -1, 0, r=r), K.knob('B', 'round', x1, 33, 1, 0, r=r)]
    body = c.m(*core, minus=blanks)
    c.add(body, SMOKE, stitch=None)
    # pink upper smoke with a wavy lower edge
    pink = c.m(K.poly([(0, 0), (64, 0), (64, 22), (56, 25), (50, 21), (44, 26), (38, 22), (26, 22), (20, 27), (14, 23), (6, 26), (0, 23)]))
    c.add(pink & body, PINK)
    # glow halo = the gap in the smoke
    glow = c.m(K.ell(32, 40, 16.5, 14))
    c.add(glow & body, GLOW)
    # sun disc
    sun = c.m(K.ell(32, 41, 12, 12))
    c.add(sun & body, SUN)
    # dark ridge across the bottom (fynbos hill)
    ridge = c.m(K.poly([(0, 64), (0, 44), (8, 42), (16, 45), (22, 43), (28, 46), (36, 45), (44, 43), (50, 45), (58, 42), (64, 44), (64, 64)]))
    c.add(ridge & body, RIDGE)
    c.edge(ridge & body, RIDGE[1])
    # mauve smoke wisps
    c.add(c.m(K.ell(17, 30, 5, 2.6), K.ell(47, 31, 5, 2.6)) & body, MAUVE)
    # face on the sun: sleepy closed eyes
    if c.small:
        for ex in (27, 36):
            px, py = c.P(ex, 37)
            for dx in range(2):
                c.px(px + dx, py, K.UMBER)
        c.smile(31, 40.5)
        c.blush(25, 40)
        c.blush(39, 40)
    else:
        for ex in (27, 37):
            px, py = c.P(ex, 37)
            c.px(px - 1, py - 1, K.UMBER)
            c.px(px, py, K.UMBER)
            c.px(px + 1, py, K.UMBER)
            c.px(px + 2, py - 1, K.UMBER)
        c.smile(32.5, 40.5)
        c.blush(24.5, 40)
        c.blush(39.5, 40)


rep = K.render_pal(fn, 'pl-fyn-5', 'Sunset Gap', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile=R + 'pl-fyn-5-cell.png', oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-fyn-5.png')
print(rep)
