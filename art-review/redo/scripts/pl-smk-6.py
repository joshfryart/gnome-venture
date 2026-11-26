#!/usr/bin/env python3
"""pl-smk-6 Sleepy Salamander (whimsy-salamander, peg).
A sleeping salamander lying side-on IS the piece: its torso is the square core, the head bulges out the W side, a peg tab on the
back is its ember crest (N), a peg blank cuts in under the belly between the legs (S) and another peg blank bites the haunch (E);
the tail curls out of the lower-right corner. Dusk purple body with ember-orange fire-salamander spots, pink belly from the
cell's pink band, a lavender smoke puff snored from the nose (Smokecap caldera, cell 8-3)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PURP = K.ramp('#9a5a8c')
PINK = K.ramp('#c8708a')
EMBER = K.ramp('#ff8a3c')
SMOKE = K.ramp('#cbbfd6')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(16, 24, 52, 50)
    head = K.ell(14, 38, 12, 7.5)
    feet = K.ell(19, 50.5, 6.5, 2.6), K.ell(49, 50.5, 6.5, 2.6)
    tabN = K.knob('T', 'peg', 36, 24, 0, -1, r=4.6 * k)
    blankS = K.knob('B', 'peg', 34, 50, 0, 1, r=4.4 * k)
    blankE = K.knob('B', 'peg', 52, 35, 1, 0, r=4.0 * k)
    tail = K.thick_path([(48, 44), (55, 46), (60, 43), (61, 37), (58, 33)], 6.5 if not c.small else 7.2)
    body = c.m(core, head, tail, *feet, minus=(blankS, blankE))
    c.add(body, PURP)
    # pink belly band and pink jaw
    belly = c.m(K.rect(16, 44, 52, 54), K.ell(12, 42, 10, 3.5), *feet, minus=(blankS, blankE)) & body
    c.add(belly, PINK)
    # ember crest (the N peg tab)
    crest = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 22, 64, 25.5)))
    c.add(crest, EMBER)
    # ember spots on the back and tail
    spots = [(24, 30, 3.2, 2.6), (34, 33, 3.0, 2.4), (45, 29, 3.0, 2.5), (43, 40, 2.6, 2.2), (28, 39, 2.4, 2.0), (60.5, 40, 2.0, 2.0)]
    if c.small:
        spots = [(24, 30, 3.6, 3.0), (35, 34, 3.4, 2.8), (45, 29, 3.2, 2.8), (60.5, 40, 2.4, 2.4)]
    c.add(c.m(*[K.ell(*s) for s in spots]) & body, EMBER)
    # smoke puff snored from the nose, touching the snout (part of the silhouette)
    puff = c.m(K.ell(6, 29.5, 3.2, 3.6), K.ell(5.5, 21, 4.8, 4.2), K.ell(11, 19.5, 4.2, 3.8), K.ell(8, 15, 4.4, 3.6), minus=(head,))
    c.add(puff, SMOKE)
    # sleepy closed eye: a curved umber lash line
    if not c.small:
        ex, ey = c.P(15, 35)
        for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0)):
            c.px(ex + dx, ey + dy, K.UMBER)
        c.px(*c.P(4, 37), K.UMBER2)       # nostril
        c.smile(10, 40, K.UMBER2)
    else:
        ex, ey = c.P(15, 35)
        for dx, dy in ((-1, 0), (0, 1), (1, 1), (2, 0)):
            c.px(ex + dx, ey + dy, K.UMBER)
    c.blush(19, 39)
    # leg seams (front and hind) on the belly
    for lx in (25, 43):
        x, _ = c.P(lx, 0)
        for y in range(c.P(0, 46)[1], c.P(0, 53)[1]):
            if (x, y) in body:
                c.px(x, y, PINK[1])


K.render_pal(fn, 'pl-smk-6', 'Sleepy Salamander', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-6.png')
