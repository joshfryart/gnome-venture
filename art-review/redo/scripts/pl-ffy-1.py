"""pl-ffy-1 Glowtail Dot: corner-TT round. A firefly that IS a corner piece: flat W and S sides (it sits in the corner),
round tab N = its fuzzy head-tuft with two antennae, round tab E = a pale blue wing. Upper core = brown fuzzy thorax with the
face, lower core = the glowing lemon lantern tail with the cell's dotted stitch rows, ringed in the cave-glow green."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BROWN = K.ramp('#6e4226')
FUZZ = K.ramp('#8a5634')
GLOW = K.ramp('#eef3a0')
GREEN = K.ramp('#86c23a')
WING = K.ramp('#bccbea')
ANT = K.ramp('#4a2c1a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 18, 48, 58)
    tabN = K.knob('T', 'round', 27, 18, 0, -1, r=7.0 * k, nw=4.2)
    tabE = K.knob('T', 'round', 48, 28, 1, 0, r=6.8 * k, nw=3.6)
    aw = 3.2 if c.small else 3.0
    antL = K.thick_path([(24, 8), (20, 4), (15, 3)], aw)
    antR = K.thick_path([(30, 8), (34, 4), (39, 3)], aw)
    c.add(c.m(antL, antR), BROWN)
    c.add(c.m(K.ell(15, 3, 2.6 * k, 2.6 * k), K.ell(39, 3, 2.6 * k, 2.6 * k)), GLOW)
    rc = 5.0
    corners = (lambda x, y: x < 9 + rc and y < 18 + rc and (x - 9 - rc) ** 2 + (y - 18 - rc) ** 2 > rc * rc,
               lambda x, y: x > 48 - rc and y < 18 + rc and (x - 48 + rc) ** 2 + (y - 18 - rc) ** 2 > rc * rc)
    body = c.m(core, tabN, minus=corners)
    c.add(body, BROWN)
    c.cut |= c.m(*corners, minus=(tabE, tabN, antL, antR))
    # fuzzy lighter tuft on the head-tab and shoulders
    c.add(c.m(tabN, minus=(core,)) | (c.m(K.ell(27, 18, 10, 4)) & body), FUZZ)
    if not c.small:
        for (x, y) in body:
            if y < c.P(0, 34)[1] and (x * 3 + y * 5) % 11 == 0:
                c.px(x, y, FUZZ[2])
    # wing tab
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(46, 0, 49, 64))), WING)
    if not c.small:
        c.line([(52, 25), (59, 28)], WING[2])
        c.line([(52, 31), (58, 31)], WING[1])
    # glowing tail: green halo band then lemon lantern
    tail = c.m(K.rect(9, 36, 48, 58))
    c.add(tail, GREEN)
    c.add(c.m(K.rect(12, 39, 45, 58)), GLOW)
    c.edge(c.m(K.rect(12, 39, 45, 64)), GREEN[2])
    # dotted stitch rows (the cell's motif)
    rows = (45, 52) if not c.small else (46, 53)
    for ry in rows:
        y = c.P(0, ry)[1]
        for x in range(c.P(15, 0)[0], c.P(43, 0)[0]):
            if x % 2 == 0:
                c.px(x, y, GREEN[0])
    # banding between thorax and tail
    y = c.P(0, 36)[1]
    for x in range(c.P(9, 0)[0], c.P(48, 0)[0]):
        c.px(x, y, BROWN[1])
    # face on the thorax
    c.eye(21, 26, disc=True)
    c.eye(34, 26, disc=True)
    c.smile(27.5, 30.5, CREAMISH)
    c.blush(15, 31)
    c.blush(40, 31)


CREAMISH = '#f2e4c0'

K.render_pal(fn, 'pl-ffy-1', 'Glowtail Dot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ffy-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ffy-1.png')
