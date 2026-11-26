#!/usr/bin/env python3
"""mw-bark-badger "Bark Badger": inner-TTBB, peg knobs.
Concept: a face-on badger whose square head-and-body IS the piece; it wears a cloak of oak bark (the Maplewold oak's brown) over its
shoulders. Tabs: N (a peg-shaped tuft of grass on its crown, cell 6-6 green) and E (a bark sleeve / paw held out to share the coat).
Blanks: W and S cut into the bark coat. Grey stone fur and sandy path stripe from the cell (grass, path, gravel)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#8a8474')      # gravel stone in the cell
SAND = K.ramp('#d9bf86')     # the path
DARK = ('#3e3228', '#2f251c', '#5a4a3a')
BARK = K.ramp('#7a4a1e')     # the oak trunk
GRASS = K.ramp('#4f9a45')    # the cell's grass
LEAF = K.ramp('#f0b92b')     # maple gold
RED = '#d6312b'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 13, 53, 55)
    tabN = K.knob('T', 'peg', 31.5, 13, 0, -1, r=4.6 * k)
    tabE = K.knob('T', 'peg', 53, 42, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'peg', 10, 42, -1, 0, r=4.4 * k)
    blankS = K.knob('B', 'peg', 31.5, 55, 0, 1, r=4.4 * k)
    earL = K.ell(14, 13.5, 4.6, 4.2)
    earR = K.ell(49, 13.5, 4.6, 4.2)
    body = c.m(core, tabN, tabE, earL, earR, minus=(blankW, blankS))
    c.add(body, FUR)
    # ears: dark with a sand rim
    c.add(c.m(K.ell(14, 14, 2.6, 2.4)) & body, DARK)
    c.add(c.m(K.ell(49, 14, 2.6, 2.4)) & body, DARK)
    # grass tuft tab on the crown
    tuft = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 12, 64, 15)))
    c.add(tuft, GRASS)
    if not c.small:
        for gx, tx in ((28.5, 27.5), (31.5, 31.5), (34.5, 35.5)):
            c.line([(gx, 10), (tx, 5.5)], GRASS[2])
    # badger face: dark eye masks on either side of the sandy blaze
    maskL = K.poly([(16, 15), (26, 15), (28, 31), (23, 34), (17, 30)])
    maskR = K.poly([(37, 15), (47, 15), (46, 30), (40, 34), (35, 31)])
    c.add(c.m(maskL, maskR) & body, DARK)
    blaze = K.poly([(26, 15), (37, 15), (35.5, 28), (34, 34), (29, 34), (27.5, 28)])
    c.add(c.m(blaze) & body, SAND)
    # cheeks sand
    c.add(c.m(K.ell(14, 31, 4, 4), K.ell(49, 31, 4, 4)) & body, SAND)
    # nose
    c.add(c.m(K.ell(31.5, 33.5, 3.2, 2.2)), DARK)
    # bark coat over shoulders: covers the lower part, with a V collar
    coat = c.m(lambda x, y: y > 37 + max(0, 6 - abs(x - 31.5)) * 0.9, tabE) & body
    c.add(coat, BARK, stitch=None)
    # bark furrows (vertical) + collar edge
    if not c.small:
        for fx in (16, 22, 43, 49, 58):
            c.line([(fx, 40), (fx + 1, 44), (fx, 48), (fx + 1, 52)], BARK[1])
        for fx in (19, 46):
            c.line([(fx, 42), (fx, 46)], BARK[2])
        c.add(c.m(K.ell(25, 48, 1.8, 1.4)), BARK[::-1][1:] + (BARK[0],))
        c.line([(26, 39.5), (31.5, 43.4)], BARK[2])
        c.line([(31.5, 43.4), (37, 39.5)], BARK[2])
    else:
        for fx in (16, 46):
            c.line([(fx, 42), (fx, 52)], BARK[1])
    # front paws peeking under the coat, either side of the S blank
    c.add(c.m(K.ell(22, 54, 4.2, 2.6), K.ell(41, 54, 4.2, 2.6)) & body, DARK)
    # maple leaf brooch on the coat
    lx, ly = 40, 47
    leaf = K.poly([(lx, ly - 3.5), (lx + 1.5, ly - 1), (lx + 3.5, ly - 1.8), (lx + 2.5, ly + 1), (lx, ly + 2.8),
                   (lx - 2.5, ly + 1), (lx - 3.5, ly - 1.8), (lx - 1.5, ly - 1)])
    c.add(c.m(leaf), LEAF)
    c.px(*c.P(lx, ly), RED)
    c.eye(22, 24, disc=True)
    c.eye(41, 24, disc=True)
    c.smile(31.5, 36.5, K.UMBER2)


if __name__ == '__main__':
    print(K.render_pal(fn, 'mw-bark-badger', 'Bark Badger', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/mw-bark-badger-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-bark-badger.png'))
