"""bb-chimney-nest "Chimney Nest": inner-BBBB keyhole. A white chimney stack whose top is a big brown twig nest; the stork who never
moves out sits in it (white body, slate wing tips, red beak and legs, cell 7-1). Keyhole blanks: N = the nest's cup (the stork looks
into it), W + E bite into the chimney sides, S = the chimney's fire-hole arch. Colours from cell 7-1: twig brown, chimney cream, stork slate."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

NEST = K.ramp('#9f6a38')
TWIG = K.ramp('#74472a')
CHIM = ('#f6efdf', '#d7ccb0', '#ffffff')
STORK = ('#f3f4ee', '#cfd2d6', '#ffffff')
SLATE = ('#3e3a44', '#2b2a30', '#5e5a66')
RED = K.ramp('#d8402a')
BRICK = '#c4b494'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 17, 55, 60)
    bN = K.knob('B', 'keyhole', 25, 17, 0, -1, r=4.2 * k)
    bW = K.knob('B', 'keyhole', 9, 31, -1, 0, r=4.0 * k)
    bE = K.knob('B', 'keyhole', 55, 31, 1, 0, r=4.0 * k)
    bS = K.knob('B', 'keyhole', 32, 60, 0, 1, r=3.6 * k)
    blanks = (bN, bW, bE, bS)
    nest_p = K.rect(9, 17, 55, 42)
    # chimney: the lower part, a white stack with a soot cap line
    chim = c.m(core, minus=blanks + (nest_p,))
    c.add(chim, CHIM)
    # stork sitting on the nest's right half: white body, slate wing feathers, long neck, head looking left, red beak
    body = K.ell(42, 18, 11, 7)
    wing = K.poly([(41, 14), (52, 12), (61, 19), (58, 23), (46, 22)])
    neck = K.thick_path([(37, 17), (36, 11), (35.5, 7)], 5.6 if c.small else 5.0)
    head = K.ell(35.5, 6.5, 5.0 * k, 4.4 * k)
    c.add(c.m(body, neck, head), STORK)
    c.add(c.m(wing), SLATE)
    beak = K.poly([(32, 4.5), (32, 9.5), (18, 9.5)])
    c.add(c.m(beak), RED)
    nest = c.m(nest_p, minus=blanks)
    c.add(nest, NEST)
    # twig ends poking out past the nest sides (above and below the side blanks)
    c.add(c.m(K.thick_path([(52, 40), (57, 39)], 2.8)), TWIG)
    if not c.small:
        for (a, b) in [((13, 24), (19, 23)), ((30, 25), (40, 24)), ((44, 25), (52, 23)), ((15, 33), (26, 35)),
                       ((34, 31), (46, 33)), ((22, 28), (30, 29)), ((40, 28), (49, 30)), ((12, 37), (20, 36))]:
            c.line([a, b], TWIG[0])
    else:
        for (a, b) in [((14, 25), (20, 24)), ((30, 31), (46, 33)), ((15, 35), (24, 36))]:
            c.line([a, b], TWIG[0])
    y = c.P(0, 42)[1]
    for x in range(c.n):
        if (x, y) in chim:
            c.px(x, y, CHIM[1])
    if not c.small:
        for yy in (48, 54):
            py = c.P(0, yy)[1]
            for x in range(c.n):
                if (x, py) in chim:
                    c.px(x, py, BRICK)
        for xx, y0, y1 in ((20, 48, 54), (44, 48, 54), (14, 43, 48), (50, 43, 48), (32, 43, 48)):
            px_ = c.P(xx, 0)[0]
            for yy in range(c.P(0, y0)[1], c.P(0, y1)[1]):
                if (px_, yy) in chim:
                    c.px(px_, yy, BRICK)
    c.eye(36.5, 6.0)
    if not c.small:
        c.blush(38.5, 9)


if __name__ == '__main__':
    print(K.render_pal(fn, 'bb-chimney-nest', 'Chimney Nest', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-chimney-nest-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-chimney-nest.png'))
