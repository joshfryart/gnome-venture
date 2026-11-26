import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Moonlit Keg (whimsy-barrel, hook): a smuggler's keg, bulging oak staves with cave-rock blue-grey iron hoops.
# N hook tab = the stolen moon peeking out of the bung; E hook tab = the wooden spigot; W hook blank bites the bulge; S flat (it sits on the ledge).
# Colours: keg tans from the barrels on the boat, hoops in the cave-rock blue, moon cream + moonglow gold (picture cell 9-5).

OAK = K.ramp('#c08a50')
OAKD = K.ramp('#8a5a36')
HOOP = K.ramp('#4c6886')
MOON = ('#faf4d2', '#d8cc98', '#ffffff')
GLOW = '#f4d171'


def fn(c):
    S = 1.15 if c.small else 1.0
    barrel = lambda x, y: K.ell(32, 37, 20, 29)(x, y) and 17 <= y < 57
    tabN = K.knob('T', 'hook', 32, 17, 0, -1, r=5.2 * S)
    tabE = K.knob('T', 'hook', 51.2, 38, 1, 0, r=4.2 * S)
    blankW = K.knob('B', 'hook', 12.8, 37, -1, 0, r=4.2 * S, flip=True)
    body = c.m(barrel, minus=(blankW,))
    c.add(body, OAK)
    # stave lines (darker oak), curving with the bulge
    for sx in (-0.55, 0.0, 0.55):
        pts = []
        for yy in range(18, 57, 3):
            w = 20 * (1 - ((yy - 37) / 29) ** 2) ** 0.5
            pts.append((32 + sx * w, yy))
        if c.small and sx == 0.0:
            continue
        for (x, y) in c.m(K.thick_path(pts, 1.4 if not c.small else 1.8)) & body:
            c.px(x, y, OAKD[0])
    # iron hoops in cave blue
    for (y0, y1) in ((21, 25.5), (49, 53.5)):
        c.add(body & c.m(K.rect(0, y0, 64, y1)), HOOP)
    # the moon tab out of the bung, the spigot tab on the right
    rN = 5.8 * S
    tabN = K.knob('T', 'hook', 32, 17, 0, -1, r=rN)
    c.add(c.m(tabN, minus=(barrel,)) | (c.m(tabN) & c.m(K.rect(0, 15, 64, 18.5))), MOON)
    cy = 17 - (rN + 1.6)
    c.add(c.m(K.ell(32, cy, rN - 1.6, rN - 1.6)), ('#f4d171', '#d8a840', '#fff0b0'))
    c.add(c.m(tabE, minus=(barrel,)) | (c.m(tabE) & c.m(K.rect(49, 0, 53, 64))), OAKD)
    # moon craters
    mx, my = c.P(30, 8)
    c.px(mx, my, MOON[1])
    if not c.small:
        c.px(mx + 1, my, MOON[1])
        c.px(mx + 4, my + 3, MOON[1])
    # moonglow leaking from the seam under the moon
    gy = c.P(0, 27.5)[1]
    for x in range(c.P(25, 0)[0], c.P(39, 0)[0]):
        if (x, gy) in body:
            c.px(x, gy, GLOW)
    # face in the calm middle band
    c.eye(25.5, 36)
    c.eye(38.5, 36)
    c.smile(32, 41)
    c.blush(20.5, 40)
    c.blush(43, 40)


K.render_pal(fn, 'pl-scg-6', 'Moonlit Keg', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-6.png')
