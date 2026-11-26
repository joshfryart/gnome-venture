# Clap Along (pl-drmc-3): inner-TBTB, round. A clapping gnome that IS a square inner piece.
# N tab = the tip + pompom of the red hat, S tab = a little hand drum held between the boots,
# W/E blanks = cut into the purple tunic at the elbows; the two mitts clap together in front of the beard.
# Colours from cell 4-5: dusk-sky purple tunic, sandy-orange ground for skin/drum, red hat, cream beard.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

SKY = K.ramp('#6a3f8a')
SAND = K.ramp('#c8884e')
SKIN = K.ramp('#e0a46c')
HAT = K.ramp('#c8302a')
BEARD = ('#f0e6d0', '#c4b89c', '#fffaf0')
BOOT = K.ramp('#7a4a2a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(13, 12, 51, 52)
    tabN = knob('T', 'round', 32, 12, 0, -1, r=4.6 * s)
    tabS = knob('T', 'round', 32, 52, 0, 1, r=5.0 * s)
    blW = knob('B', 'round', 13, 41, -1, 0, r=4.2 * s)
    blE = knob('B', 'round', 51, 41, 1, 0, r=4.2 * s)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, SAND, stitch='#e8b47a')
    # dusk sky in the top corners of the piece, stars
    c.add(body & c.m(rect(0, 0, 64, 27)), SKY)
    # red pointed gnome hat rising into the N tab (hat tip + pompom)
    hat = body & c.m(poly([(14, 27), (29.5, 10), (34.5, 10), (50, 27)]), rect(29.5, 4, 34.5, 14))
    c.add(hat, HAT)
    c.add(body & c.m(ell(32, 5.8, 4.4 * s, 4.4 * s)), K.ramp('#f0d090'))   # pompom
    c.add(body & c.m(rect(13, 24.5, 51, 27.5)), K.ramp('#a02420'))                                 # hat brim
    # face + big nose
    face = c.m(ell(32, 30, 11, 5.5), minus=(rect(0, 0, 64, 27.5),))
    c.add(face, SKIN)
    # beard
    beard = c.m(poly([(17, 30), (47, 30), (46, 39), (39, 47), (32, 50), (25, 47), (18, 39)]))
    c.add(beard, BEARD)
    c.add(c.m(ell(32, 32.5, 3.2, 2.8)), K.ramp('#e88a6a'))                                         # nose
    # boots at the bottom corners of the core
    c.add(body & c.m(ell(19.5, 52, 7, 5), ell(44.5, 52, 7, 5)) & c.m(core), BOOT)
    # S tab = hand drum: sand head, red body
    drum = c.m(tabS, minus=(core,))
    c.add(drum, K.ramp('#b8402e'))
    c.add(c.m(ell(32, 54.5, 4.6 * s, 2.0 * s)) & body, K.ramp('#ecc890'))
    # clapping mitts in front of the beard
    # sleeves reaching in from the tunic
    c.add(c.m(thick_path([(17, 36), (25.5, 41)], 4.6), thick_path([(47, 36), (38.5, 41)], 4.6)) & body, K.ramp('#a86a3c'))
    hands = c.m(ell(28.5, 41, 3.6, 4.2), ell(35.5, 41, 3.6, 4.2))
    c.add(hands, K.ramp('#f2b884'))
    c.edge(c.m(ell(28.5, 41, 3.6, 4.2)), K.UMBER2)
    for (sx, sy) in ((17, 21), (46, 18), (21, 15)):
        if c.small and sx == 21:
            continue
        c.px(*c.P(sx, sy), '#f8e8a0')
    c.eye(27.5, 28.5)
    c.eye(36.5, 28.5)
    c.blush(22.5, 31.5)
    c.blush(40.5, 31.5)
    # clap sparks above the hands
    for (a, b) in (((26, 35.5), (24.5, 34)), ((38, 35.5), (39.5, 34)), ((32, 35), (32, 34))):
        if c.small and a[0] == 32:
            continue
        c.line([a, b], '#f8d060')


K.render_pal(fn, 'pl-drmc-3', 'Clap Along', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drmc-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drmc-3.png')
