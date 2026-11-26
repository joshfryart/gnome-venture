#!/usr/bin/env python3
"""pl-wsta-5 Crescent Hull Smile. Inner-TTBB keyhole: a voyaging-canoe hull bent into a crescent. N keyhole blank = the open hollow of the
hull, bow + stern tips curl up at the top corners, W keyhole blank, S keyhole tab = the keel, E keyhole tab = the glowing stern lantern.
Tan woven hull with dark ribs, navy water band, lantern gold (cell 3-7 + picture)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

HULL = K.ramp('#d49a5a')
HULLD = K.ramp('#a86a34')
NAVY = K.ramp('#3a3a8a')
LAMP = K.ramp('#f0c040')
RIB = '#7a4a24'
SRC = '/home/user/gnome-venture/art-review/redo/_src/'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(7, 22), (57, 22), (57, 34), (54, 41), (46, 46), (32, 47.5), (18, 46), (10, 41), (7, 34)])
    scoop = K.ell(32, 0, 24, 22.6)                      # shallow concave top edge: the crescent hollow of the hull
    bow = K.poly([(7, 28), (13, 23), (8, 18), (4.5, 13), (2.5, 13.5), (3.5, 19), (5, 25)])
    stern = K.poly([(57, 28), (51, 23), (56, 18), (59.5, 13), (61.5, 13.5), (60.5, 19), (59, 25)])
    tabS = K.knob('T', 'keyhole', 32, 47, 0, 1, r=4.6 * k)
    tabE = K.knob('T', 'keyhole', 57, 32, 1, 0, r=4.2 * k)
    blankN = K.knob('B', 'keyhole', 32, 23, 0, -1, r=5.0 * k)
    blankW = K.knob('B', 'keyhole', 7, 33, -1, 0, r=3.8 * k)
    cut = (blankN, blankW, scoop)
    body = c.m(core, bow, stern, tabS, minus=cut)
    c.add(body, HULL, stitch=None if c.small else HULLD[0])
    # inner hollow rim: darker shading along the gunwale + inside the N blank
    c.add(c.m(K.ell(32, 2, 30, 24.5), K.rect(0, 0, 64, 23.5), minus=cut) & body, HULLD)
    # keel tab: darker wood
    c.add(c.m(tabS, minus=(core,)), HULLD)
    # lantern tab: glowing gold with a dark post
    lamp = c.m(tabE, minus=(core,))
    c.add(lamp, LAMP)
    # waterline band (navy water lapping the hull)
    wl = c.m(lambda x, y: 39 + (1.2 if (x // 4) % 2 else 0) < y < 43.5, minus=cut) & body
    c.add(wl, NAVY)
    # ribs of the woven hull
    if not c.small:
        for gx in (14, 20, 44, 50):
            x = c.P(gx, 0)[0]
            for y in range(c.P(0, 25)[1], c.P(0, 39)[1]):
                if (x, y) in body:
                    c.px(x, y, RIB)
        x = c.P(62.5, 0)[0]
        for y in range(c.P(0, 31)[1], c.P(0, 35)[1]):
            c.px(x, y, '#fff2b0')
    else:
        for gx in (14, 50):
            x = c.P(gx, 0)[0]
            for y in range(c.P(0, 26)[1], c.P(0, 38)[1]):
                if (x, y) in body:
                    c.px(x, y, RIB)
    # face: the crescent smile across the hull
    c.eye(24.5, 30)
    c.eye(39.5, 30)
    if c.small:
        c.line([(25, 34), (28, 36), (36, 36), (39, 34)], K.UMBER)
    else:
        c.line([(24, 33.5), (27, 36), (37, 36), (40, 33.5)], K.UMBER)
    c.blush(19.5, 33)
    c.blush(43.5, 33)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wsta-5', 'Crescent Hull Smile', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile=SRC + 'pl-wsta-5-cell.png', oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsta-5.png'))
