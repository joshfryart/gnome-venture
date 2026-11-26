"""pl-wcof-6 Headband Pourer (whimsy-host, keyhole). A coffee-ceremony host who IS the piece: square robe body (hut-wall brown with the
cell's tan dashes), N keyhole tab = the host's head in a striped rug-colour headband, E keyhole tab = the clay jebena held out, pouring
into a cup; keyhole blanks W and S bite the robe. Colours: cell 7-5 brown/tan/dusk purple, rug stripes red/yellow/teal."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROBE = K.ramp('#6e4238')
TAN = '#c08a58'
SASH = K.ramp('#4a3468')
SKIN = K.ramp('#9a6038')
HAIR = K.ramp('#3a2418')
POT = K.ramp('#5a3448')
CUP = K.ramp('#f0e8d8')
RED, YEL, TEAL = '#d0402a', '#f0c030', '#3a9aa0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(12, 25, 50, 60)(x, y) and not (y < 29 and ((x - 16) ** 2 + (y - 29) ** 2 > 16 and x < 16 or (x - 46) ** 2 + (y - 29) ** 2 > 16 and x > 46))
    neck = K.knob('T', 'keyhole', 31, 25, 0, -1, r=6.5)
    head = K.ell(31, 15, 10, 9.5)
    pot = K.knob('T', 'keyhole', 50, 40, 1, 0, r=7.4 * k)
    bW = K.knob('B', 'keyhole', 12, 40, -1, 0, r=4.8 * k)
    body = c.m(core, minus=(bW,))
    c.add(body, ROBE, stitch=None)
    # tan dashes of the hut wall (cell motif)
    for yy in (31, 47):
        y = c.P(0, yy)[1]
        for (x, yb) in list(body):
            if yb == y and (x // (2 if c.small else 3)) % 3 != 2:
                c.px(x, y, TAN)
    # purple sash at the waist
    c.add(body & c.m(K.rect(0, 37, 64, 41)), SASH)
    # head on the keyhole flare (the N tab), hair cap, thin striped headband
    hm = c.m(head, neck, minus=(core,))
    c.add(hm, SKIN)
    c.add(hm & c.m(K.rect(0, 0, 64, 9)), HAIR)
    band = hm & c.m(K.rect(0, 8.5, 64, 11.5 if not c.small else 12.5))
    c.add(band, K.ramp(RED))
    cols = (RED, YEL, TEAL, YEL)
    w = 1 if c.small else 2
    for (x, y) in band:
        c.px(x, y, cols[(x // w) % 4])
    # jebena: round clay belly (E keyhole tab), tilted neck, spout pouring
    pm = c.m(pot, minus=(core,))
    c.add(pm, POT)
    c.add(c.m(K.thick_path([(59.5, 36), (60.5, 28)], 2.8 if not c.small else 3.6)), POT)
    c.add(c.m(K.ell(60.5, 27.5, 2.6, 1.6)), POT)
    if not c.small:
        c.px(*c.P(56, 41), POT[2]); c.px(*c.P(57, 41), POT[2]); c.px(*c.P(56, 42), POT[2])
    c.add(c.m(K.thick_path([(54, 44), (50.5, 47.5)], 2.6 if not c.small else 3.4)), POT)
    # arm from shoulder to the pot
    c.add(c.m(K.thick_path([(44, 28), (49, 34), (51, 38)], 5 if not c.small else 5.5)), ROBE)
    c.add(c.m(K.ell(52, 38.5, 2.6, 2.6)), SKIN)
    # three cups on the hem + the coffee stream
    for cx in ((17, 26, 35) if not c.small else (16, 26, 36)):
        cm = c.m(K.rect(cx, 50, cx + 6, 54), K.ell(cx + 3, 54, 3, 2.2))
        c.add(cm, CUP)
        c.edge(cm, CUP[1])
        c.add(c.m(K.rect(cx + 0.5, 50, cx + 5.5, 51.6)), K.ramp('#4a2c1a'))
    c.add(body & c.m(K.rect(13, 56.5, 44, 58.5)), K.ramp('#d8a040'))
    c.line([(49.5, 48), (43, 50.5)], '#4a2c1a')
    # face
    c.eye(26.5, 16.5)
    c.eye(35, 16.5)
    c.smile(30.5, 20.5)
    c.blush(23, 20)
    c.blush(38, 20)


K.render_pal(fn, 'pl-wcof-6', 'Headband Pourer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcof-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-6.png')
