# pl-kava-6 "Tanoa Buddy": whimsy-tanoa, peg. A chibi carved kava bowl (tanoa) that is a jigsaw piece: peg tabs W and E are the bowl's
# carved lug handles, peg blank S cut up into the belly between the two stubby legs. Wood browns and
# grey-tan kava from cell 5-7 of the Kava Circle picture.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WOOD = K.ramp('#d48344')
WOODD = K.ramp('#a9603d')
LEG = K.ramp('#7a4030')
KAVA = ('#bcac96', '#8f826f', '#d7ccb9')
SHELL = K.ramp('#6a4430')


def fn(c):
    s = 1.15 if c.small else 1.0
    lip = K.ell(32, 25, 26, 7)
    belly = lambda x, y: y >= 25 and ((x - 32) / 24) ** 2 + ((y - 25) / 21) ** 2 < 1
    legs = lambda x, y: 40 <= y < 56 and (13 <= x < 23 or 41 <= x < 51)
    tabW = K.knob('T', 'peg', 7, 27, -1, 0, r=3.8 * s)
    tabE = K.knob('T', 'peg', 57, 27, 1, 0, r=3.8 * s)
    blankS = K.knob('B', 'peg', 32, 50, 0, 1, r=3.6 * s)
    body = c.m(lip, belly, legs, tabW, tabE, minus=(blankS,))
    c.add(c.m(legs, minus=(belly,)) & body, LEG)
    c.add(c.m(belly) & body, WOOD, stitch=None)
    c.add(c.m(tabW, tabE, minus=(lip,)), WOODD)
    c.add(c.m(lip) & body, WOODD)
    c.add(c.m(K.ell(32, 24.3, 22.5, 4.6 if not c.small else 4.4)), KAVA)
    c.edge(c.m(belly) & body, WOODD[1])
    if not c.small:   # ripple highlight on the kava
        for x in range(c.P(20, 0)[0], c.P(30, 0)[0]):
            c.px(x, c.P(0, 23)[1], KAVA[2])
        # carved zigzag band on the belly
        y = c.P(0, 40)[1]
        for x in range(c.P(15, 0)[0], c.P(49, 0)[0]):
            c.px(x, y + (x // 2) % 2, WOODD[1])
    else:
        c.px(*c.P(24, 23), KAVA[2]); c.px(c.P(24, 23)[0] + 1, c.P(24, 23)[1], KAVA[2])
    for ex in (23, 41):
        cx, cy = c.P(ex, 32)
        if c.small:
            c.px(cx - 1, cy, K.UMBER); c.px(cx, cy + 1, K.UMBER); c.px(cx + 1, cy, K.UMBER)
        else:
            c.px(cx - 2, cy, K.UMBER); c.px(cx - 1, cy + 1, K.UMBER); c.px(cx, cy + 1, K.UMBER)
            c.px(cx + 1, cy + 1, K.UMBER); c.px(cx + 2, cy, K.UMBER)
    c.smile(32, 35)
    c.blush(17, 35)
    c.blush(46, 35)


K.render_pal(fn, 'pl-kava-6', 'Tanoa Buddy', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-kava-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-kava-6.png')
