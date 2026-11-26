"""pl-eggs-4 Fence Eggs: inner-TTTT, peg. A painted spring egg IS the piece: W and E peg tabs are the white fence rail
running through it, S peg tab is the fence post it sits on, N peg tab is the picket top behind it (cell 9-6: cream fence post, hen-comb red stripes).
Egg stripes red / straw yellow / sky blue from the picture's painted eggs."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

RED = ramp('#d8402e')
YEL = ramp('#f0c040')
BLUE = ramp('#5a9ad8')
PINK = ramp('#e88aa8')
FENCE = ramp('#eee6d6')
GRASS = ramp('#6cb048')
COMB = ramp('#e03a30')


def fn(c):
    k = 1.15 if c.small else 1.0
    # egg core: straight sides, rounded narrower top, rounded bottom corners
    def core(x, y):
        if y < 35:
            rx = 12.5 + 7.5 * min(1.0, max(0.0, (y - 11) / 22.0)) ** 0.6
            return abs(x - 32) < rx * max(0.0, 1 - ((35 - y) / 24.0) ** 2) ** 0.5 * 1.25 and y > 11 and abs(x - 32) < 19
        return abs(x - 32) < 19 and ((x - 32) / 21) ** 2 + ((y - 35) / 18.5) ** 2 < 1
    tN = knob('T', 'peg', 32, 12.5, 0, -1, r=3.6 * k)
    tS = knob('T', 'peg', 32, 53, 0, 1, r=4.0 * k)
    tW = knob('T', 'peg', 13, 38, -1, 0, r=4.2 * k)
    tE = knob('T', 'peg', 51, 38, 1, 0, r=4.2 * k)
    egg = c.m(core)
    c.add(egg, YEL)
    # stripes (horizontal bands like the roof egg)
    c.add(egg & c.m(lambda x, y: y < 20), RED)
    c.add(egg & c.m(rect(0, 22, 64, 26.5)), BLUE)
    c.add(egg & c.m(rect(0, 42, 64, 46.5)), RED)
    c.add(egg & c.m(lambda x, y: y >= 48.5), BLUE)
    # pink dots on the yellow band (64 only)
    if not c.small:
        for (dx, dy) in ((14, 12), (26, 14), (38, 14), (50, 12), (20, 51), (32, 52), (44, 51)):
            if (dx, dy) in egg: c.px(dx, dy, YEL[2])
    # fence rail through the egg (tabs W/E), drawn as rail ends
    rail = c.m(tW, tE, minus=(core,))
    c.add(rail, FENCE)
    post = c.m(tS, minus=(core,))
    c.add(post, FENCE)
    # grass tuft at the post foot
    c.add(post & c.m(rect(0, 61, 64, 64)), GRASS)
    c.add(c.m(tN, minus=(core,)), FENCE)
    # face on the yellow band
    c.eye(25, 33)
    c.eye(39, 33)
    c.smile(32, 37.5)
    c.blush(21, 37)
    c.blush(42, 37)
    # zigzag between yellow and lower red band
    for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
        y = c.P(0, 41)[1] + (x % 2 if not c.small else 0)
        c.px(x, y, RED[0])


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-eggs-4', 'Fence Eggs', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-eggs-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-eggs-4.png'))
