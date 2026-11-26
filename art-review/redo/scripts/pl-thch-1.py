"""pl-thch-1 Chimney Wink: corner-BB, round. The brick chimney stack of the Thatchtop tearoom IS the corner piece:
flat W and S sides (S is the golden thatch it pokes out of), a round blank N = the flue mouth in the pot cap, a round blank E bitten
into the bricks. Brick rose #b87968 with a #906c64 cap, thatch gold, a lavender-sky smoke puff curling off the cap; winking face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BRICK = K.ramp('#b87968')
CAP = K.ramp('#906c64')
THATCH = ('#e4b45c', '#b07a30', '#f8d070')
SMOKE = ('#e6daf0', '#b8a6cc', '#ffffff')
MORTAR = '#8e5444'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 12, 54, 58)
    blankN = K.knob('B', 'round', 32, 12, 0, -1, r=5.0 * k)
    blankE = K.knob('B', 'round', 54, 31, 1, 0, r=4.6 * k)
    cut = (blankN, blankE)
    body = c.m(core, minus=cut)
    c.add(body, BRICK)
    slope = lambda x, y: y > 36 + (x - 10) * 0.36 and y < 58 and 10 <= x < 54
    th = c.m(slope)
    # brick courses with staggered joints (fewer, chunkier at 36 px)
    step = 5 if not c.small else 6.5
    yv, row = (23.0 if not c.small else 39.0), 0
    while yv < 52:
        y = c.P(0, yv)[1]
        for x in range(c.n):
            if (x, y) in body and (x, y) not in th:
                c.px(x, y, MORTAR)
        if not c.small:
            off = 0 if row % 2 else 4
            for x in range(c.P(10, 0)[0] + off, c.P(54, 0)[0], 8):
                for yy in range(y + 1, y + 5):
                    if (x, yy) in body and (x, yy) not in th:
                        c.px(x, yy, MORTAR)
        yv += step
        row += 1
    # chimney pot cap (wider rim band at the top)
    cap = c.m(K.rect(10, 12, 54, 19.5), minus=cut)
    c.add(cap, CAP)
    # golden thatch skirt rising to the left (the roof slope the chimney sits in)
    c.add(th, THATCH, stitch=None)
    c.edge(th, '#b07a30')
    if not c.small:
        for (x, y) in th:
            if (x * 3 + y * 5) % 11 == 0:
                c.px(x, y, '#f8d070')
            elif (x * 7 + y) % 13 == 0:
                c.px(x, y, '#c8903a')
    # smoke puff curling out of the flue, tucked on the cap's left shoulder
    puff = c.m(K.ell(17, 9.5, 5.2, 4.0), K.ell(23.5, 7.5, 4.2, 3.4))
    c.add(puff, SMOKE)
    # winking face on the bricks
    c.eye(25, 28)
    lx, ly = c.P(38, 28)
    if not c.small:
        for dx, dy in ((-2, 0), (-1, -1), (0, -1), (1, -1), (2, 0)):
            c.px(lx + dx, ly + dy, K.UMBER)
    else:
        for dx, dy in ((-1, 0), (0, -1), (1, -1), (2, 0)):
            c.px(lx + dx, ly + dy, K.UMBER)
    c.smile(32, 34, wide=True)
    c.blush(21, 32)
    c.blush(42, 32)


rep = K.render_pal(fn, 'pl-thch-1', 'Chimney Wink', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-thch-1-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-1.png')
print(rep)
