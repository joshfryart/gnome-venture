# Flamingo Flick: edge-BTB, keyhole. Flat bottom = waterhole (blue water over sand), top keyhole TAB = neck + head with
# hooked beak, left/right keyhole BLANKS cut into the fluffy pink body. Pink, sky-blue and sand from thornacre cell 3-7.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

PINK = K.ramp('#ee8fae')
WING = K.ramp('#d4628a')
WATER = K.ramp('#4f93c4')
SAND = K.ramp('#d9903c')
BEAK = K.ramp('#f4e4cc')
LEG = '#c84a78'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = [K.rect(8, 27, 56, 58), K.rect(15, 20, 49, 27), K.ell(15, 27, 7, 7), K.ell(49, 27, 7, 7)]
    head = K.knob('T', 'keyhole', 29, 20.5, 0, -1, r=7.0 * s)
    beak = K.poly([(33, 6.5), (43, 7), (48, 11.5), (47.5, 18), (44.5, 15.5), (42, 13), (33, 13)])
    bl = K.knob('B', 'keyhole', 8, 31, -1, 0, r=3.9 * s)
    br = K.knob('B', 'keyhole', 56, 31, 1, 0, r=3.9 * s)
    body = c.add(c.m(*core, head, minus=(bl, br, K.rect(0, 45, 64, 64))), PINK, stitch=WING[0])
    c.add(c.m(beak), BEAK)
    tip = c.m(K.poly([(43.5, 7.5), (48, 11.5), (47.5, 18), (44.5, 15.5), (42.5, 13)]))
    for p in tip:
        c.px(p[0], p[1], K.UMBER2)
    wing = c.m(K.ell(37, 35, 14, 7.5), K.poly([(24, 31), (15, 41), (27, 40)]), minus=(br,))
    c.add(wing, WING)
    c.edge(wing, WING[1])
    c.add(c.m(K.rect(8, 45, 56, 52)), WATER)
    c.add(c.m(K.rect(8, 52, 56, 58)), SAND)
    # one standing leg into the water, the other tucked as a bent line on the belly
    c.add(c.m(K.thick_path([(32, 42), (32, 53)], 2.8 if c.small else 2.2)), (LEG, '#9a3058', '#e07a9e'))
    c.line([(24, 43), (20, 41), (24, 39)], LEG)
    # ripples
    c.line([(12, 48), (17, 48)], WATER[2])
    c.line([(40, 49), (48, 49)], WATER[2])
    c.line([(27, 50), (37, 50)], WATER[2])
    c.eye(28, 10)
    c.blush(25, 13.5)


K.render_pal(fn, 'th-flamingo-flick', 'Flamingo Flick', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/th-flamingo-flick-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/th-flamingo-flick.png')
