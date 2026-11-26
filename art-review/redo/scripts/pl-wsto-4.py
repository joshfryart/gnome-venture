# Eyebrow Row: a carved stone watcher-head that IS an inner-TTTT piece (double knobs): ears = E/W tabs, moss tuft = N tab,
# chin = S tab. Lilac-grey stone, tan brow band, slate eye sockets, moss patches (cell 11-5); one stony eyebrow raised.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

STONE = K.ramp('#bcacb4')
BAND = K.ramp('#bea197')
SLATE = K.ramp('#645a82')
MOSS = K.ramp('#5aa050')
MOSSL = '#9ed070'
BROW = '#4a3c50'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 14, 51, 52)
    rnd = K.ell(32, 22, 19, 12)  # dome of the head
    core_shape = lambda x, y: (core(x, y) and (y >= 22 or rnd(x, y)))
    tN = K.knob('T', 'double', 32, 14, 0, -1, r=4.6 * k)
    tE = K.knob('T', 'double', 51, 34, 1, 0, r=4.4 * k)
    tW = K.knob('T', 'double', 13, 34, -1, 0, r=4.4 * k)
    tS = K.knob('T', 'double', 32, 52, 0, 1, r=4.6 * k)
    body = c.m(core_shape, tE, tW, tS)
    c.add(body, STONE, stitch=None)
    # moss tuft on top (N tab) in picture green
    c.add(c.m(tN, minus=(core_shape,)) | (c.m(tN) & c.m(K.rect(0, 12, 64, 16))), MOSS)
    # moss speckle on the tuft and dripping onto the crown
    tuft = c.m(tN, minus=(core_shape,))
    for (x, y) in sorted(tuft):
        if (x * 7 + y * 3 + (x * y) % 5) % 6 == 0:
            c.px(x, y, MOSSL)
    cap = c.m(lambda x, y: 14 <= y < 16.5 + (2 if int(x) % 5 in (1, 2) else 0) and 25 <= x < 39) & body
    c.add(cap, MOSS)
    # tan brow band across the forehead
    band = c.m(K.rect(13, 19, 51, 24.5)) & body
    c.add(band, BAND)
    # slate eye sockets
    sockL = c.m(K.ell(24, 30, 6.5, 3.6))
    sockR = c.m(K.ell(40, 29.5, 6.5, 4.2))
    c.add(sockL, SLATE)
    c.add(sockR, SLATE)
    # long carved nose
    nose = c.m(K.poly([(29.5, 26), (34.5, 26), (37, 42), (27, 42)]))
    c.add(nose, STONE)
    c.edge(nose, STONE[1])
    # flat carved lips
    lips = c.m(K.rect(25, 45.5, 39, 49))
    c.add(lips, K.ramp('#a8909c'))
    c.edge(lips, STONE[1])
    # eyebrows: left flat, right raised high (the joke)
    w = 3.0 if c.small else 2.4
    c.add(c.m(K.thick_path([(18, 26.0), (30, 26.0)], w)), (BROW, BROW, '#6a5a70'))
    c.add(c.m(K.thick_path([(34, 24.5), (38, 21.2), (43, 20.2), (47, 22.5)], w)), (BROW, BROW, '#6a5a70'))
    # moss patches on the stone
    if not c.small:
        for (x, y) in [(17, 40), (18, 41), (17, 41), (19, 42), (45, 44), (46, 44), (46, 45), (44, 17), (45, 17), (20, 18), (21, 18)]:
            c.px(*c.P(x, y), MOSSL)
        for (x, y) in [(16, 42), (18, 42), (45, 46), (47, 45)]:
            c.px(*c.P(x, y), MOSS[0])
    else:
        for (x, y) in [(17, 41), (19, 41), (46, 45)]:
            c.px(*c.P(x, y), MOSSL)
    c.eye(24, 30.5, disc=True)
    c.eye(40, 30, disc=True, look=(0, -1))


K.render_pal(fn, 'pl-wsto-4', 'Eyebrow Row', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsto-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsto-4.png')
