"""pl-tgm-2 Prayerflag Slip. Edge-TTB, double: a cream prayer-flag cloth hung on a straight green bamboo pole (the flat W side);
double tab E = the fluttering tail, double tab S = tassels, double blank N. Diagonal tan/umber moth-wing band from cell 7-1, teal hem."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CLOTH = K.ramp('#f6e6b4')
BAMBOO = ('#3a7a58', '#245a48', '#6aa880')
TAN = K.ramp('#c89a78')
WING = ('#4a2c28', '#2e1c1e', '#6a4438')
TEAL = K.ramp('#355257')
GOLD = K.GOLD


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(15, 11, 51, 49)
    tabE = K.knob('T', 'double', 51, 30, 1, 0, r=5.0 * k)
    tabS = K.knob('T', 'double', 33, 49, 0, 1, r=5.0 * k)
    blankN = K.knob('B', 'double', 33, 11, 0, -1, r=4.6 * k)
    cloth = c.m(core, tabE, tabS, minus=(blankN,))
    c.add(cloth, CLOTH, stitch=None)
    # diagonal moth-wing band: tan upper stripe, dark wing lower stripe
    tan = c.m(K.poly([(15, 41), (64, 21), (64, 26), (15, 47)]))
    dark = c.m(K.poly([(15, 47), (64, 26), (64, 31), (15, 53)]))
    c.add(cloth & tan, TAN)
    c.add(cloth & dark, WING)
    # teal hem on tab tips (tail + tassels)
    c.add(cloth & c.m(K.rect(57, 0, 64, 64)), TEAL)
    c.add(cloth & c.m(K.rect(0, 54, 64, 64)), TEAL)
    for gx in (30.5, 35.5):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 55)[1], c.n):
            c.px(x, y, TEAL[1])
    # bamboo pole (flat W side) with gold finial
    pole = c.m(K.rect(8, 6, 15, 62))
    c.add(pole, BAMBOO)
    c.add(c.m(K.ell(11.5, 5.5, 4.2, 3.6)), GOLD)
    for ny in (22, 40):
        y = c.P(0, ny)[1]
        for x in range(c.P(8, 0)[0], c.P(15, 0)[0]):
            c.px(x, y, BAMBOO[1])
    # cord ties
    for ty in (14, 34):
        x0, y0 = c.P(14, ty)
        c.px(x0, y0, K.UMBER2)
        c.px(x0 + 1, y0, K.UMBER2)
    # nervous face on the calm cream area
    c.eye(26, 24, look=(1, 0))
    c.eye(38, 24, look=(1, 0))
    if c.small:
        x, y = c.P(30, 31)
        for dx in range(0, 4):
            c.px(x + dx, y + (dx % 2), K.UMBER)
    else:
        x, y = c.P(28, 31)
        for dx in range(0, 8):
            c.px(x + dx, y + (dx // 2) % 2, K.UMBER)
    c.blush(21, 29)
    c.blush(42, 29)
    # sweat drop (nervous)
    if not c.small:
        x, y = c.P(45, 17)
        for p in ((0, 0), (0, 1), (-1, 1), (1, 1), (0, 2)):
            c.px(x + p[0], y + p[1], '#9ad0e0')


print(K.render_pal(fn, 'pl-tgm-2', 'Prayerflag Slip', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tgm-2-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tgm-2.png'))
