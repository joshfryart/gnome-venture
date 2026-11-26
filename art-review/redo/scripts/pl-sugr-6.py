"""pl-sugr-6 Maple Mayor: whimsy-maple, peg. A maple leaf that is a puzzle piece: the top and upper corners are the leaf's
points, the south peg tab is the stem, a peg tab on the east side and a peg blank on the west. Autumn maple orange from the
picture's trees, a peach-cream mayor's sash (the cell's dawn sky) and snow on the top point."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ORANGE = K.ramp('#e2862a')
VEIN = '#a85a18'
SASH = K.ramp('#fde0b8')
SNOW = K.ramp('#e8eef8')
STEM = K.ramp('#8a5a2e')
GOLD = '#f0c030'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 20, 51, 47)
    top = K.poly([(21, 21), (24, 11), (28, 14), (32, 2), (36, 14), (40, 11), (43, 21)])
    lobeL = K.poly([(13, 32), (4, 20), (10, 19.5), (8, 11), (17, 15), (23, 21), (13, 21)])
    lobeR = K.poly([(51, 32), (60, 20), (54, 19.5), (56, 11), (47, 15), (41, 21), (51, 21)])
    bot = K.poly([(13, 46), (8, 52), (18, 51), (24, 54), (40, 54), (46, 51), (56, 52), (51, 46)])
    tabE = K.knob('T', 'peg', 51, 35, 1, 0, r=4.2 * k)
    blankW = K.knob('B', 'peg', 13, 35, -1, 0, r=4.2 * k)
    stem = K.knob('T', 'peg', 32, 53.5, 0, 1, r=3.0 * k, nw=2.2)
    leaf = c.m(core, top, lobeL, lobeR, bot, tabE, minus=(blankW,))
    c.add(leaf, ORANGE, stitch=None)
    c.add(c.m(stem, minus=(core, bot)), STEM)
    # snow on the top point
    c.add(leaf & c.m(K.ell(32, 6, 6, 5.5)), SNOW)
    # veins: centre and two side veins (thick enough to survive 36 px)
    vw = 1.6 if not c.small else 2.0
    vein = c.m(K.thick_path([(32, 12), (32, 21)], vw), K.thick_path([(20, 20), (12, 15)], vw),
               K.thick_path([(44, 20), (52, 15)], vw))
    for p in vein & leaf:
        c.px(p[0], p[1], VEIN)
    # mayor's sash, peach-cream, from the left shoulder down to the right hip, with a gold medal
    sash = c.m(K.thick_path([(19, 36), (46, 48)], 5.5 if not c.small else 6.0)) & leaf
    c.add(sash, SASH)
    c.edge(sash, '#d8a878')
    mx, my = c.P(40, 45.5)
    for dx in range(-1, 2) if not c.small else range(0, 2):
        for dy in range(-1, 2) if not c.small else range(0, 2):
            c.px(mx + dx, my + dy, GOLD)
    # face
    c.eye(27, 29)
    c.eye(37, 29)
    c.blush(23.5, 33)
    c.blush(40, 33)
    c.smile(32, 33, wide=True)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-sugr-6', 'Maple Mayor', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-6.png')
    print(rep)
