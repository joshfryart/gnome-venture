import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Ziggurat Zigzag: inner-TTTT keyhole. A stepped seed-temple (3 terraces) whose body is the piece.
# N tab = golden seed crystal on the summit, E/W tabs = jutting stone blocks of the base terrace, S tab = mossy mound at the stair foot.
# Tan brick, umber mortar, moss-green ledge trims (cell 4-4), central lighter staircase, glowing door.
ROOT = '/home/user/gnome-venture/art-review/redo/'
STONE = K.ramp('#c8a07a')
STONEL = K.ramp('#ddb88c')
STAIR = K.ramp('#e6c69c')
MOSS = K.ramp('#3c9a6c')
GOLD = K.ramp('#e8b020')
MORTAR = '#5e4840'


def fn(c):
    k = 1.15 if c.small else 1.0
    t1 = K.rect(21, 13, 43, 22)
    t2 = K.rect(17, 21, 47, 31)
    t3 = K.rect(13, 30, 51, 51)
    tabN = K.knob('T', 'keyhole', 32, 13, 0, -1, r=5.4 * k, nw=2.0)
    tabW = K.knob('T', 'keyhole', 13, 41, -1, 0, r=5.6 * k, nw=2.0)
    tabE = K.knob('T', 'keyhole', 51, 41, 1, 0, r=5.6 * k, nw=2.0)
    tabS = K.knob('T', 'keyhole', 32, 51, 0, 1, r=5.4 * k, nw=2.0)
    body = c.m(t1, t2, t3)
    c.add(body, STONE, stitch=None)
    c.add(c.m(tabW, tabE, minus=(t3,)), STONE)
    c.add(c.m(tabN, minus=(t1,)), GOLD)
    c.add(c.m(tabS, minus=(t3,)), STAIR)
    c.add(c.m(tabS, minus=(t3,)) & c.m(K.rect(0, 58, 64, 64)), MOSS)
    # brick courses (mortar lines) on 64 px
    if not c.small:
        for (x, y) in body:
            X, Y = x / c.k, y / c.k
            row = int((Y - 13) // 4.5)
            if (Y - 13) % 4.5 < 1 / c.k:
                c.px(x, y, MORTAR)
            elif (int(X) + row * 4) % 9 == 0:
                c.px(x, y, MORTAR)
    # moss ledges on each terrace top
    for (x0, x1, y) in ((21, 43, 13), (17, 47, 21), (13, 51, 30)):
        c.add(c.m(K.rect(x0, y, x1, y + (3.0 if c.small else 2.6))), MOSS)
    # staircase down the middle
    st = c.m(K.rect(29, 21, 35, 51))
    c.add(st, STAIR)
    for yy in range(21, 51, 3 if not c.small else 4):
        c.line([(29, yy), (34.5, yy)], STAIR[1])
    # temple door on the top terrace
    c.add(c.m(K.rect(29, 17, 35, 22), K.ell(32, 17, 3, 2.2)), ('#3a2418', '#2a1a10', '#e08a30'))
    # face on the base terrace either side of the stair
    c.eye(21.5, 38.5, disc=True)
    c.eye(42.5, 38.5, disc=True)
    c.blush(18, 44)
    c.blush(45, 44)
    c.smile(32, 45, '#7a5236', wide=True)


K.render_pal(fn, 'pl-step-4', 'Ziggurat Zigzag', ROOT + 'out', cellfile=ROOT + '_src/pl-step-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-4.png')
