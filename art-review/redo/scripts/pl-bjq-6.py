# pl-bjq-6 "Little Box Queen": whimsy-jelly, tri knobs. A box jelly whose cube bell IS the piece core:
# tri tab N (her gold crown spike), tri tab E, tri blank W; pink tentacles hang from the flat south side.
# Colours from cell 7-3 / picture: ice-blue cube with deeper blue side face, gold crown, pink tentacles.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ICE = K.ramp('#c4e6f4')
SIDE = K.ramp('#78acd8')
TOPF = K.ramp('#e2f4fb')
GOLD = ('#f0c040', '#c08a18', '#f8e08a')
PINK = K.ramp('#f494c4')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(9, 13, 53, 42)
    tabN = K.knob('T', 'tri', 31, 13, 0, -1, r=4.8 * s)
    tabE = K.knob('T', 'tri', 53, 27, 1, 0, r=4.4 * s)
    blankW = K.knob('B', 'tri', 9, 27, -1, 0, r=4.4 * s)
    body = c.m(core, tabE, minus=(blankW,))
    c.add(body, ICE, stitch=None if c.small else '#f4fbff')
    # cube faces: lighter top strip, deeper right side face
    c.add(body & c.m(K.poly([(9, 13), (53, 13), (49, 17), (9, 17)])), TOPF)
    side = body & c.m(K.poly([(46, 17), (53, 13), (53, 42), (46, 42)]), tabE)
    c.add(side, SIDE)
    c.edge(side, SIDE[1])
    # crown = the north tri tab, gold, with a band
    crown = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 12, 64, 14)))
    band = c.m(K.rect(21, 11, 42, 14), K.poly([(21, 12), (22.5, 7.5), (25, 12)]), K.poly([(38, 12), (40.5, 7.5), (42, 12)]))
    c.add(crown | band, GOLD)
    jx, jy = c.P(31, 12.5)
    c.px(jx, jy, '#d8402a')
    # tentacles: wavy pink ribbons from the flat bottom
    w = 3.8 if c.small else 3.2
    for i, x0 in enumerate((14, 21, 28, 35, 42, 49)):
        d = 1.4
        pts = [(x0, 41), (x0 + d, 47), (x0 - d, 53), (x0 + d * 0.5, 60 - (i % 2) * 2.5)]
        c.add(c.m(K.thick_path(pts, w)), PINK)
    # bell rim (frilly) where tentacles meet cube
    c.add(body & c.m(K.rect(0, 39, 46, 42)), K.ramp('#9cc8e8'))
    # face on the calm front face
    c.eye(24, 26, disc=False)
    c.eye(37, 26, disc=False)
    c.blush(20, 31)
    c.blush(39, 31)
    cx, cy = c.P(30.5, 33)
    if not c.small:
        for dx in range(-1, 2):
            c.px(cx + dx, cy, K.UMBER)
        c.px(cx - 2, cy + 1, K.UMBER)
        c.px(cx + 2, cy + 1, K.UMBER)
    else:
        c.px(cx, cy, K.UMBER); c.px(cx + 1, cy, K.UMBER)
        c.px(cx - 1, cy + 1, K.UMBER); c.px(cx + 2, cy + 1, K.UMBER)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-bjq-6', 'Little Box Queen', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-bjq-6-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-bjq-6.png'))
