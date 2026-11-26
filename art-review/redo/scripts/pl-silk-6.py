"""pl-silk-6 Purplehat Haggler: whimsy-merchant, keyhole. A travelling merchant gnome IS the piece: purple cone hat (sky purple) is the
whimsy top, the square robe core is caravanserai sandstone brick (cell 8-6), keyhole tab E = teal coin purse (dome teal),
keyhole blank W bites the robe, keyhole blank S splits the robe hem into two boots."""
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

HAT = K.ramp('#7a3a8c')
BRICK = K.ramp('#c8925e')
BRICK2 = K.ramp('#a8744a')
TEAL = K.ramp('#2a8a86')
GOLD = K.ramp('#e8b030')
SKIN = K.ramp('#f0b48c')
BEARD = ('#f4f0e4', '#c9c5bc', '#ffffff')
BOOT = K.ramp('#6e4a36')
MORTAR = '#6e4a36'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 25, 50, 59)
    tabE = K.knob('T', 'keyhole', 50, 42, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'keyhole', 12, 41, -1, 0, r=4.8 * k)
    blankS = K.knob('B', 'keyhole', 31, 59, 0, 1, r=3.6 * k)
    hat = K.poly([(8, 27), (20, 15), (28, 7), (36, 2.5), (40, 4), (37, 8), (35, 15), (44, 21), (55, 27), (50, 29), (14, 29)])
    body = c.m(core, minus=(blankW, blankS))
    c.add(body, BRICK, stitch=None)
    # brick courses on the robe
    robe = c.m(K.rect(12, 33, 50, 59), minus=(blankW, blankS))
    darkb = c.m(lambda x, y: ((int((x + (6 if int((y - 36) // 6) % 2 else 0)) // 12)) % 2 == 1) and y >= 36) & robe
    c.add(darkb, BRICK2)
    beardm = c.m(K.ell(31, 38.5, 9, 7), K.rect(22, 34.5, 40, 38), K.rect(12, 43.5, 50, 47.5))
    if not c.small:
        for (x, y) in robe - beardm:
            X, Y = (x + .5) / c.k, (y + .5) / c.k
            band = int((Y - 36) // 6)
            if abs((Y - 36) % 6) < 1.0 / c.k and Y > 35:
                c.px(x, y, MORTAR)
            if abs(((X + (6 if band % 2 else 0)) % 12)) < 1.0 / c.k:
                c.px(x, y, MORTAR)
    # boots
    c.add(c.m(K.rect(12, 55.5, 50, 59), minus=(blankW, blankS)), BOOT)
    # face + beard
    c.add(c.m(K.rect(16, 27, 46, 35)), SKIN)
    c.add(c.m(K.ell(31, 38.5, 9, 7), K.rect(22, 34.5, 40, 38)), BEARD)
    # teal belt + purse tab
    belt = c.m(K.rect(12, 44, 50, 47.5), minus=(blankW,))
    c.add(belt, TEAL)
    purse = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(48, 0, 51, 64)))
    c.add(purse, TEAL)
    c.edge(purse, TEAL[1])
    # hat on top
    hm = c.m(hat)
    c.add(hm, HAT)
    c.edge(c.m(K.rect(8, 26, 56, 29)) & hm, HAT[1])
    c.add(c.m(K.rect(16, 23.5, 47, 26.5)) & hm, GOLD)       # gold hat band (finial gold)
    # gold coin on the purse
    cx, cy = c.P(57, 43)
    c.px(cx, cy, GOLD[2]); c.px(cx + 1, cy, GOLD[0])
    if not c.small:
        c.px(cx, cy + 1, GOLD[0]); c.px(cx + 1, cy + 1, GOLD[1])
    # face
    c.eye(25, 31.5, disc=False)
    c.eye(37, 31.5, disc=False)
    c.blush(20, 33.5)
    c.blush(41, 33.5)
    nx, ny = c.P(30.5, 33)
    c.px(nx, ny, SKIN[1]); c.px(nx + 1, ny, SKIN[1])


K.render_pal(fn, 'pl-silk-6', 'Purplehat Haggler', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-6.png')
