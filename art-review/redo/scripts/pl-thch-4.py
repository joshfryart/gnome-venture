# Scone Tower: three golden scones stacked into an inner-TTTT piece; peg tabs = jam dollop (top), scone bulges (sides), plate foot (bottom).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

SCONE = K.ramp('#e0a83a')     # thatch gold
CRUST = K.ramp('#b8742c')     # baked top
CREAM = K.ramp('#f4ead2')
JAM = K.ramp('#c8304a')
PLATE = K.ramp('#b89aae')     # wall mauve from the cell
TIMBER = '#7a4a2a'

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 5.2 * k
    core = K.poly([(16, 14), (48, 14), (50, 16), (50, 48), (48, 50), (16, 50), (14, 48), (14, 16)])
    top = K.knob('T', 'peg', 32, 14, 0, -1, r=r, nw=3.4)
    lft = K.knob('T', 'peg', 14, 33, -1, 0, r=r, nw=3.4)
    rgt = K.knob('T', 'peg', 50, 33, 1, 0, r=r, nw=3.4)
    bot = K.knob('T', 'peg', 32, 50, 0, 1, r=r, nw=3.4)
    notch = (K.ell(14, 25, 2.4, 1.6), K.ell(50, 25, 2.4, 1.6), K.ell(14, 40, 2.4, 1.6), K.ell(50, 40, 2.4, 1.6))
    body = c.m(core, lft, rgt, minus=notch)
    c.add(body, SCONE, stitch=None)
    # crusty tops of each scone
    c.add(c.m(K.rect(14, 14, 51, 19), minus=notch), CRUST)
    c.add(c.m(K.rect(14, 27, 51, 30.5), K.ell(6.5, 30.5, 2.6, 3.4), K.ell(57.5, 30.5, 2.6, 3.4), minus=notch), CRUST)
    c.add(c.m(K.rect(14, 41.5, 51, 43.5), minus=notch), CRUST)
    # cream / jam fillings
    cr1 = c.add(c.m(K.rect(14, 22.5, 51, 26.5), K.ell(22, 26.8, 3.2, 2.2), K.ell(40, 27, 3.8, 2.2), minus=notch), CREAM)
    jm2 = c.add(c.m(K.rect(14, 39 if c.small else 38.5, 51, 41), K.ell(28, 41, 3, 1.8), minus=notch), JAM)
    # plate at the bottom with a peg foot
    pl = c.add(c.m(K.rect(14, 46.5, 51, 50), bot), PLATE)
    c.edge(pl, K.ramp('#b89aae')[1])
    # jam dollop on top with a cream swirl
    c.add(c.m(top, K.ell(32, 14.5, 8, 3.2), K.ell(24, 16, 1.6, 2.6), K.ell(39, 16.5, 1.6, 3)), JAM)
    c.add(c.m(K.ell(30.5, 8.5, 2.2, 1.6)), CREAM) if not c.small else None
    # face on the middle scone
    c.eye(26, 34.5)
    c.eye(38, 34.5)
    c.smile(32, 36.5)
    c.blush(21, 37)
    c.blush(42, 37)
    # raisin flecks (timber brown)
    if not c.small:
        for (x, y) in ((20, 20), (40, 21), (45, 33), (19, 31), (36, 44), (24, 44)):
            c.px(*c.P(x, y), TIMBER)

K.render_pal(fn, 'pl-thch-4', 'Scone Tower', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-thch-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-4.png')
