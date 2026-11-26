"""pl-dlz-1 Scalecrust Tot. Concept: a baby dragon-lizard that IS a corner piece: flat W and S sides (it sits on the gold hoard),
a hook tab N that is its curved bone horn, a hook blank E bitten into its back; green scales, amber slit eye, toothy grin,
purple cave-rock crust plates on the back and the gold hoard band at the bottom (cell 4-6: purple rock, green scale corner, gold)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

GREEN = K.ramp('#6ea83e')
BELLY = K.ramp('#b8d27a')
ROCK = K.ramp('#6a4d62')
HORN = K.ramp('#e2c08a')
GOLD = K.ramp('#ecd27a')
AMBER = '#f0a628'
SCALE = '#4f7e2c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 17, 53, 57)
    tabN = knob('T', 'hook', 31, 17, 0, -1, r=5.4 * k)
    blankE = knob('B', 'hook', 53, 38, 1, 0, r=4.6 * k, flip=True)
    body = c.m(core, minus=(blankE,))
    c.add(body, GREEN, stitch=None)
    # horn tab
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 15, 64, 18.5))), HORN)
    # dorsal crest: rounded cream spikes along the top edge (the den dragon's horns)
    for sx in (14, 21, 41, 48):
        sp = c.m(poly([(sx - 3.2, 18), (sx + 0.6, 11.5), (sx + 3.2, 18)]))
        c.add(sp - body | (sp & c.m(rect(0, 16, 64, 18.5))), HORN)
    # purple rock-crust spots on the back
    for (sx, sy, r) in ((13, 22, 2.6), (44, 22, 2.8), (35, 21, 2.0)):
        c.add(c.m(ell(sx, sy, r * 1.3, r)) & body, ROCK)
    # pale belly / jaw
    c.add(c.m(ell(28, 55, 16, 10)) & body, BELLY)
    # gold hoard band at the bottom
    c.add(c.m(rect(9, 52.5, 53, 57)) & body, GOLD)
    if not c.small:
        for gx in range(12, 52, 6):
            c.px(*c.P(gx, 54), '#fff2b0')
    # scales on green
    if not c.small:
        g = c.parts[0][0]
        for (x, y) in g:
            if y > c.P(0, 24)[1] and y < c.P(0, 38)[1] and ((x + (y // 3) * 2) % 6 == 0) and y % 3 == 0:
                c.px(x, y, SCALE)
    # eye: amber with a slit pupil
    ex, ey = (22, 31)
    eye = c.m(ell(ex, ey, 6.0, 5.2))
    for p in eye:
        c.px(p[0], p[1], AMBER)
    c.edge(eye, K.UMBER)
    cx, cy = c.P(ex, ey)
    for dy in range(-2 if not c.small else -1, 3 if not c.small else 2):
        c.px(cx, cy + dy, K.UMBER)
    c.px(cx - 2 if not c.small else cx - 1, cy - 2 if not c.small else cy - 1, '#fff2b0')
    # brow ridge
    c.line([(15, 24.5), (29, 25.5)], GREEN[1])
    # nostril
    c.px(*c.P(41, 31), K.UMBER)
    if not c.small:
        c.px(c.P(41, 31)[0] + 1, c.P(41, 31)[1], K.UMBER)
    # wide open toothy jaw, like the den dragon's
    mouth = c.m(poly([(12, 40), (45, 38.5), (44, 43), (36, 47.5), (18, 47.5), (12, 44)]))
    c.add(mouth & body, K.ramp('#7a2a30'))
    c.add(c.m(ell(28, 47, 8, 2.6)) & mouth, K.ramp('#e07a8a'))
    tw = 3.0 if not c.small else 3.6
    for tx in range(14, 44, 5 if not c.small else 7):
        c.add(c.m(poly([(tx, 39.6), (tx + tw, 39.4), (tx + tw / 2, 43.2)])) & mouth, K.ramp('#f4f0e4'))
    c.blush(36, 33)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-dlz-1', 'Scalecrust Tot', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-1.png')
    print(rep)
