# Concept: a cherry-red bobbing buoy that IS a corner piece: flat W and S sides (S = the teal sea it floats in), keyhole TAB on N
# (the buoy's mast with its yellow lamp ball), keyhole BLANK on E (bitten into the red float). White band, teal water with the
# cell's light-ray stripe and the little yellow fish from cell 3-2 of Pearl Diver Cove.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d8303a')
WHITE = K.ramp('#f4f0e4')
SEA = K.ramp('#2fa8c0')
RAY = K.ramp('#6fd0dc')
LAMP = K.ramp('#f8d070')
MAST = K.ramp('#8a96a8')
FISH = K.ramp('#f8c858')


def fn(c):
    k = 1.15 if c.small else 1.0
    R = 15
    core = lambda x, y: 9 <= x < 53 and 17 <= y < 57 and not (
        (x < 9 + R and y < 17 + R and (x - 9 - R) ** 2 + (y - 17 - R) ** 2 > R * R) or
        (x > 53 - R and y < 17 + R and (x - 53 + R) ** 2 + (y - 17 - R) ** 2 > R * R))
    tabN = K.knob('T', 'keyhole', 31, 17, 0, -1, r=5.2 * k)
    blankE = K.knob('B', 'keyhole', 53, 32, 1, 0, r=5.4 * k)
    body = c.m(core, tabN, minus=(blankE,))
    # red float
    c.add(c.m(core, minus=(blankE,)), RED, stitch=None)
    # white band
    band = c.m(K.rect(0, 34, 64, 40), minus=(blankE,)) & body
    c.add(band, WHITE)
    # mast neck (grey) and lamp ball (yellow) from the tab
    tabm = c.m(tabN, minus=(K.rect(0, 17, 64, 64),))
    c.add(tabm & c.m(K.rect(0, 13.5, 64, 18)), MAST)
    c.add(tabm & c.m(K.rect(0, 0, 64, 13.5)), LAMP)
    if not c.small:
        c.px(*c.P(29.5, 7.5), '#ffffff')
    # sea band at the bottom with a wavy crest, plus the light-ray stripe
    sea = c.m(lambda x, y: y >= 47 + 1.6 * __import__('math').sin(x / 3.2)) & body
    c.add(sea, SEA)
    ray = c.m(lambda x, y: 0 <= (x - 0.5 * y) - 4 < 6) & sea
    c.add(ray, RAY)
    crest = {(x, y) for (x, y) in sea if (x, y - 1) not in sea}
    for p in crest:
        c.px(p[0], p[1], RAY[2])
    # little yellow fish in the water (from the cell)
    fx, fy = c.P(43, 52)
    if not c.small:
        for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (1, -1), (-1, 0), (-1, 1), (-2, -1), (-2, 2)):
            c.px(fx + dx, fy + dy, FISH[0])
        c.px(fx + 1, fy, '#2a1a10')
    else:
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (-1, -1), (-1, 2)):
            c.px(fx + dx, fy + dy, FISH[0])
        c.px(fx + 1, fy, '#2a1a10')
    # face on the red upper float
    c.eye(24, 26, disc=False)
    c.eye(37, 26, disc=False)
    c.blush(20, 30)
    c.blush(41, 30)
    c.smile(30.5, 29)
    # cherry-shine highlight on the dome
    if not c.small:
        for q in ((15, 23), (16, 22), (17, 21), (18, 20)):
            c.px(*c.P(*q), RED[2])
    # rope ring at the band seam
    for x in range(c.P(9, 0)[0], c.P(53, 0)[0]):
        if x % (3 if not c.small else 2) == 0 and (x, c.P(0, 41)[1]) in body:
            c.px(x, c.P(0, 41)[1], RED[1])


K.render_pal(fn, 'pl-wpea-1', 'Bobbing Cherry Buoy', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-1.png')
