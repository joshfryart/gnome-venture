import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2, CREAM

# Clifftop Lamp: corner-BB (round). Flat W + S = cliff face and ground. Blanks: N cut into the slate roof, E cut into the cliff rock.
# A little stone lamp-hut on a slate sea-stack rock (cell 11-0 blue-grey), its big window glowing lantern-gold as the face.
ROCK = ramp('#496683')
ROCK2 = ramp('#617f9e')
WALL = ramp('#7a9ab8')
ROOF = ramp('#38526e')
GLOW = ('#f5c542', '#d8902a', '#fff0a0')
FRAME = ramp('#6a4428')

def fn(c):
    k = 1.15 if c.small else 1.0
    import math
    # gable roof: left slope from (9,19) to ridge (30,6), right slope to (55,19)
    core = poly([(9, 57), (9, 19), (30, 6), (55, 19), (55, 57)])
    ln = math.hypot(25, 13)
    nx, ny = 13 / ln, -25 / ln
    bN = knob('B', 'round', 44, 13.3, nx, ny, r=4.2 * k)
    bE = knob('B', 'round', 55, 46, 1, 0, r=4.6 * k)
    body = c.m(core, minus=(bN, bE))
    c.add(body, ROCK)
    c.add(body & c.m(poly([(9, 46), (22, 42), (30, 57), (9, 57)])), ROCK2)
    c.add(body & c.m(poly([(40, 41), (55, 37), (55, 57), (44, 57)])), ramp('#2f4a6a'))
    walls = body & c.m(rect(9, 21, 55, 41))
    c.add(walls, WALL, stitch='#9db8d2')
    c.edge(walls, ROCK[1])
    roofm = body & c.m(poly([(9, 22), (9, 19), (30, 6), (55, 19), (55, 22)]))
    c.add(roofm, ROOF)
    c.edge(roofm, ROOF[1])
    # attic lamp: round glowing light under the ridge
    c.add(body & c.m(ell(30, 14.5, 5.2, 4.8)), FRAME)
    c.add(body & c.m(ell(30, 14.5, 3.6, 3.3)), ('#fff0a0', '#f5c542', '#ffffff'))
    # big lit window = face
    c.add(body & c.m(rect(13, 25, 39, 39)), FRAME)
    c.add(body & c.m(rect(15.5, 27.5, 36.5, 36.5)), GLOW)
    # door
    c.add(body & c.m(rect(43, 28, 51, 41)), FRAME)
    dx, dy = c.P(49, 35)
    c.px(dx, dy, GLOW[0])
    c.eye(21, 31.5, disc=c.small)
    c.eye(31, 31.5, disc=c.small)
    c.smile(26, 33.5)
    c.blush(18, 35)
    c.blush(34, 35)
    # glints of lamplight on the rock
    if not c.small:
        for (x, y) in ((16, 49), (19, 51), (26, 47)):
            X, Y = c.P(x, y)
            c.px(X, Y, ROCK2[2])

K.render_pal(fn, 'pl-scg-1', 'Clifftop Lamp', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-1.png')
