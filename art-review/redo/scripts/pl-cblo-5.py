# Roof Medallion: inner-BBBB, round. A little teahouse-roof crest: an indigo tiled roof cap (swept eave tips at the top corners) holding
# a big round gold medallion (the face), gold plaque band at the foot. Round blanks on all four sides. Colours from cell 9-2 (indigo roof, gold plaque).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOF = K.ramp('#3e4a8a')
ROOFD = ('#2a3068', '#21264f', '#54619f')
RIDGE = K.ramp('#6a78b8')
GOLD = ('#f0a040', '#b8742c', '#ffe090')
PLAQ = ('#ffe090', '#f0a040', '#fff4c0')
CREAM = '#fff4c0'


def fn(c):
    k = 1.15 if c.small else 1.0
    roof = K.poly([(19, 9), (45, 9), (54, 22), (54, 40), (61, 37), (60.5, 41), (57, 45.5), (7, 45.5), (3.5, 41), (3, 37), (10, 40), (10, 22)])
    wall = K.rect(12, 45, 52, 60)
    bN = K.knob('B', 'round', 32, 9, 0, -1, r=3.4 * k)
    bS = K.knob('B', 'round', 32, 60, 0, 1, r=3.4 * k)
    bW = K.knob('B', 'round', 10, 31, -1, 0, r=3.4 * k)
    bE = K.knob('B', 'round', 54, 31, 1, 0, r=3.4 * k)
    cut = (bN, bS, bW, bE)
    body = c.m(roof, wall, minus=cut)
    # lit shoji wall under the eaves (gold windows, umber mullions)
    sh = body & c.m(wall, minus=(roof,))
    c.add(sh, PLAQ)
    for mx in (20, 44):
        x = c.P(mx, 0)[0]
        for (xx, y) in sh:
            if xx == x:
                c.px(x, y, '#b86e44')
    y = c.P(0, 53)[1]
    for (x, yy) in sh:
        if yy == y and not c.small:
            c.px(x, y, GOLD[0])
    # tiled roof
    rf = body & c.m(roof)
    c.add(rf, ROOF)
    c.add(rf & c.m(K.rect(0, 0, 64, 13)), RIDGE)
    eave = rf & c.m(K.rect(0, 40.5, 64, 46))
    c.add(eave, RIDGE)
    c.edge(eave, ROOFD[1])
    # tile courses (vertical tile lines, the roof's own texture)
    step = 4 if not c.small else 5
    medz = c.m(K.ell(32, 28, 11.5, 11.5))
    for (x, y) in rf - medz:
        X = x / c.k
        Y = y / c.k
        if 14 <= Y < 40 and int(X) % step == 0 and (x, y) not in eave:
            c.px(x, y, ROOF[1])
    # the medallion: big gold disc with a darker rim, on the roof face
    med = c.m(K.ell(32, 28, 10.5, 10.5))
    c.add(med, GOLD)
    c.edge(med, GOLD[1])
    if not c.small:
        c.edge(c.m(K.ell(32, 28, 8.2, 8.2)), '#f8c868')
    c.eye(28, 27)
    c.eye(36.5, 27)
    c.smile(32.2, 32)
    c.blush(24.5, 31)
    c.blush(39.5, 31)
    gx, gy = c.P(25.5, 21.5)
    c.px(gx, gy, CREAM)
    if not c.small:
        c.px(gx + 1, gy - 1, CREAM)
        c.px(gx, gy + 1, CREAM)


K.render_pal(fn, 'pl-cblo-5', 'Roof Medallion', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-5.png')
