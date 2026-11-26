#!/usr/bin/env python3
"""cs-snorkel-snip "Snorkel Snip": a pink reef crab that is a corner-BB piece. Flat W and S sides (it sits in the corner of the reef),
round blank N between its two raised claws, round blank E in its side. A teal snorkel mask and a lavender snorkel with pink bands
(the pink and lavender light-bars on teal water of cell 3-5); a lavender scallop shell in each claw."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#ee8fb4')
PINKD = K.ramp('#c45a8a')
LAV = K.ramp('#d5c9ef')
TEAL = K.ramp('#3fb4bd')
DEEP = K.ramp('#2992a8')
GLASS = K.ramp('#9fe0e4')
CREAMW = '#f6e8f0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 22, 56, 58)
    blankN = K.knob('B', 'round', 32, 22, 0, -1, r=4.6 * k)
    blankE = K.knob('B', 'round', 56, 46, 1, 0, r=4.4 * k)
    # arms + big open pincers raised at the top corners
    aw = 5.0 if not c.small else 5.8
    armL = K.thick_path([(15, 26), (13, 20)], aw)
    armR = K.thick_path([(49, 26), (51, 20)], aw)
    clawL = K.ell(12, 12, 8.5, 8.5)
    clawR = K.ell(52, 12, 8.5, 8.5)
    notchL = K.poly([(14, 12), (11, 1), (21, 1), (17, 8)])
    notchR = K.poly([(50, 12), (53, 1), (43, 1), (47, 8)])
    body = c.m(core, minus=(blankN, blankE))
    c.add(body, PINK)
    c.add(c.m(armL, armR), PINK)
    c.add(c.m(clawL, clawR, minus=(notchL, notchR)), PINKD)
    # a scallop shell held in each pincer
    for sx in (15.5, 48.5):
        sh = c.m(K.ell(sx, 9, 3.4, 3.2), minus=(K.rect(0, 0, 64, 6.5),))
        c.add(sh, LAV)
        if not c.small:
            c.line([(sx, 12), (sx, 8)], LAV[1])
    # snorkel: lavender tube with pink bands, rising beside the right claw
    tube = K.thick_path([(40, 34), (40, 4)], 4.2 if not c.small else 5.0)
    c.add(c.m(tube), LAV)
    for by in (9, 17, 25):
        c.add(c.m(tube) & c.m(K.rect(0, by, 64, by + 3)), PINK)
    c.add(c.m(K.thick_path([(38.5, 4), (43, 4)], 3.6)), DEEP)
    # snorkel goggles: teal strap and frame, two glass lenses
    c.add(body & c.m(K.rect(8, 33, 56, 37)), TEAL)
    c.add(c.m(K.rect(11, 30, 39, 44)), TEAL)
    c.add(c.m(K.rect(13.5, 32, 24, 42), K.rect(26, 32, 36.5, 42)), GLASS)
    c.eye(19, 37.5)
    c.eye(31, 37.5)
    # mouth under the mask
    c.smile(25, 48, K.UMBER2)
    # crab legs: three dark-pink strokes on each lower flank, walking in the deep-teal water band
    w = 2.6 if not c.small else 3.0
    for ly in (44, 48.5, 53):
        c.add(c.m(K.thick_path([(8, ly + 1), (13, ly - 2)], w)), PINKD)
        c.add(c.m(K.thick_path([(42, ly - 2), (47, ly + 1)], w)) & body, PINKD)
    c.add(body & c.m(K.rect(0, 55, 64, 58)), DEEP)

if __name__ == '__main__':
    print(K.render_pal(fn, 'cs-snorkel-snip', 'Snorkel Snip', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/cs-snorkel-snip-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/cs-snorkel-snip.png'))
