"""pl-labi-6 Plinth Riddler (whimsy-stonegnome, keyhole): a chibi grey stone gnome whose squat body + hedge plinth is the square piece core.
The pointy grey hat is the whimsy top, W side = keyhole tab (a stone mitten held out), E side = keyhole blank cut into the stone coat,
S plinth = trimmed maze hedge (cell 5-4 greens) with a sand-path band, keyhole tab S (hedge tuft). Colours: hedge greens + maze sand + stone grey."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#a4a6aa')
HAT = K.ramp('#7d828c')
FACE = K.ramp('#c8c4b8')
BEARD = K.ramp('#e2e0d8')
HEDGE = K.ramp('#3f8a32')
LEAF = '#8ccf3c'
SAND = K.ramp('#e4c88e')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 27, 51, 59)
    hat = K.poly([(11, 30), (53, 30), (43, 21), (38, 13), (36, 8), (38, 5.5), (41, 4.5), (39, 3), (35, 3.5), (31, 7), (26, 16), (21, 23)])
    tabW = K.knob('T', 'keyhole', 13, 40, -1, 0, r=4.6 * k)
    blankE = K.knob('B', 'keyhole', 51, 40, 1, 0, r=4.4 * k)
    tabS = K.knob('T', 'keyhole', 32, 59, 0, 1, r=3.4 * k)
    body = c.m(core, tabW, minus=(blankE,))
    c.add(body, STONE, stitch=None)
    # hedge plinth + sand path band + tuft tab
    plinth = c.m(K.rect(13, 50, 51, 59), tabS, minus=(blankE,))
    c.add(plinth, HEDGE)
    c.add(c.m(K.rect(13, 49, 51, 51.6)), SAND)
    # hat
    c.add(c.m(hat), HAT)
    # face + beard
    c.add(c.m(K.ell(32, 33, 10, 5.5)), FACE)
    beard = c.m(K.poly([(21, 35), (43, 35), (41, 42), (36, 48), (32, 49.5), (28, 48), (23, 42)]))
    c.add(beard, BEARD)
    c.add(c.m(K.ell(32, 36.2, 2.6, 2.2)), K.ramp('#b8a8a0'))   # nose
    # mitten on W tab
    c.add(c.m(tabW, minus=(K.rect(13, 0, 64, 64),)), BEARD)
    # hedge texture: leaf flecks on the plinth
    for (x, y) in plinth:
        Y = (y + 0.5) / c.k
        if 51.6 <= Y < (54 if not c.small else 54.5) and (x, y + 1) in plinth:
            c.px(x, y, LEAF)
        elif Y >= 54.5 and not c.small and ((x // 2) * 7 + (y // 2) * 3) % 5 == 0:
            c.px(x, y, HEDGE[1])
    # stone cracks / riddle-mark on hat
    if not c.small:
        c.line([(31, 19), (33, 16), (34, 19), (32, 22)], HAT[1])
        c.px(*c.P(32, 24), HAT[1])
        c.line([(16, 44), (18, 46)], STONE[1])
        c.line([(46, 47), (48, 45)], STONE[1])
    else:
        c.line([(31, 17), (33, 18), (32, 21)], HAT[1])
    c.eye(27.5, 33)
    c.eye(36.5, 33)
    if not c.small:
        c.blush(24, 36)
        c.blush(39, 36)


K.render_pal(fn, 'pl-labi-6', 'Plinth Riddler', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-6.png')
