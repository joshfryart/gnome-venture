"""pl-ambr-6 Plumetail Digger (rare, whimsy-redsquirrel, keyhole).
Concept: a chibi red squirrel sitting upright whose body is a square piece: tufted head + ears on N, a great striped plume tail forms the
whole E side (keyhole blank bitten into it), the W keyhole tab is a glowing amber drop hugged in its paws, keyhole blank between the feet on S.
Colours from cell 10-4: amber glow #ffc860, bark browns #a8603a / #7a4034, dark plum trunk shadow #54303a."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#cc5a28')
TAIL = K.ramp('#e07a34')
BARK = K.ramp('#a8603a')
PLUM = '#54303a'
AMBER = ('#ffc860', '#f4a43c', '#fff0b0')
CREAMB = K.ramp('#f6d89a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(10, 22, 42, 57)
    head = K.ell(25, 20, 14, 11)
    earL = K.poly([(13, 16), (12, 4), (14.5, 3), (21, 12)])
    earR = K.poly([(29, 12), (35.5, 3), (38, 4), (37, 16)])
    tail = lambda x, y: (40 <= x < 56 and 18 <= y < 57) or K.ell(47, 14, 13, 11)(x, y) or K.ell(55, 26, 5, 8)(x, y)
    tabW = K.knob('T', 'keyhole', 10, 39, -1, 0, r=5.8 * s)
    blankE = K.knob('B', 'keyhole', 56, 40, 1, 0, r=4.2 * s)
    blankS = K.knob('B', 'keyhole', 26, 57, 0, 1, r=4.2 * s)
    cuts = (blankE, blankS)
    body = c.m(core, head, earL, earR, minus=cuts)
    c.add(body, RED)
    # cream belly and muzzle
    c.add(c.m(K.ell(26, 44, 9, 12), minus=cuts) & body, CREAMB)
    # the plume tail: rises behind, curls over at the top, bark-dark stripes like the amber woods' trunks
    tm = c.m(tail, minus=cuts)
    c.add(tm, TAIL, stitch=None if c.small else '#f6b060')
    c.edge(tm, RED[1])
    if not c.small:
        for (x0, y0, x1, y1) in ((44, 30, 54, 27), (44, 39, 51, 36), (44, 50, 54, 47), (40, 13, 49, 9)):
            c.line([(x0, y0), (x1, y1)], BARK[1])
        c.line([(40, 20), (39, 14), (43, 7), (50, 6), (54, 10), (52, 15), (47, 15)], BARK[1])
    else:
        for (x0, y0, x1, y1) in ((44, 31, 54, 28), (44, 50, 54, 47)):
            c.line([(x0, y0), (x1, y1)], BARK[1])
    # glowing amber-lit plume tip (the woods' light)
    c.add(c.m(K.ell(47, 9, 6, 4.5)) & tm, AMBER)
    # ear tufts (dark plum tips)
    c.add(c.m(K.ell(13.5, 4.5, 2.4, 3), K.ell(36.5, 4.5, 2.4, 3)), (PLUM, '#3a2030', '#7a4034'))
    # feet either side of the S blank
    c.add(c.m(K.ell(16, 55, 6, 3.4), K.ell(36, 55, 6, 3.4), minus=cuts) & body, BARK)
    # the amber drop (W keyhole tab) hugged by the paws
    am = c.m(tabW, minus=(K.rect(10, 0, 64, 64),))
    c.add(am | (c.m(tabW) & c.m(K.rect(9, 0, 11.5, 64))), AMBER)
    c.add(c.m(K.ell(12.5, 33.5, 3.2, 2.4), K.ell(12.5, 44.5, 3.2, 2.4)), BARK)
    ax, ay = c.P(3.6 if not c.small else 3.0, 37)
    c.px(ax, ay, '#ffffff')
    if not c.small:
        c.px(ax + 1, ay, '#fff0b0')
        c.px(ax, ay + 1, '#fff0b0')
    # face
    c.eye(20, 20)
    c.eye(31, 20)
    nx, ny = c.P(25.5, 23.5)
    c.px(nx, ny, PLUM)
    if not c.small:
        c.px(nx + 1, ny, PLUM)
    c.smile(25.5, 25)
    c.blush(16, 24)
    c.blush(34, 24)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-ambr-6', 'Plumetail Digger', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-ambr-6-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-ambr-6.png'))
