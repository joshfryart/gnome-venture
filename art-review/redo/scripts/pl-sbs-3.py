# Concept: a buttress-root tree hollow that is an inner piece: tri tabs W/E are the flaring buttress roots, tri blanks N (into the moss cap)
# and S (the hollow's mouth); in the dark purple hollow sits a white silk knot with two glowing spider eyes. Tan bark, moss green, dusk purple, earth brown from cell 2-6.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#a88a7c')
BARKD = K.ramp('#8b706e')
MOSS = K.ramp('#487a50')
HOLLOW = ('#3b3345', '#2e2a3c', '#483c4e')
EARTH = K.ramp('#99614a')
SILK = ('#ece6ea', '#b8b0c4', '#ffffff')
ROOT = K.ramp('#7a4a44')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 11, 51, 55)
    tabW = K.knob('T', 'tri', 13, 38, -1, 0, r=4.6 * k, nw=3.2)
    tabE = K.knob('T', 'tri', 51, 38, 1, 0, r=4.6 * k, nw=3.2)
    blankN = K.knob('B', 'tri', 32, 11, 0, -1, r=4.0 * k)
    blankS = K.knob('B', 'tri', 32, 55, 0, 1, r=3.8 * k)
    body = c.m(core, tabW, tabE, minus=(blankN, blankS))
    c.add(body, BARK)
    # buttress roots: darker flares running into the side tabs
    roots = c.m(K.poly([(13, 30), (20, 44), (20, 55), (5, 55)]), K.poly([(51, 30), (44, 44), (44, 55), (59, 55)])) & body
    c.add(roots | (c.m(tabW, tabE) & body), BARKD)
    # moss cap on top
    moss = c.m(lambda x, y: y < 18 + 2 * ((int(x) // 4) % 2)) & body
    c.add(moss, MOSS)
    # dark hollow arch, open at the bottom
    hol = c.m(K.ell(32, 40, 12, 15), minus=(K.rect(0, 55, 64, 64),)) & body
    c.add(hol, HOLLOW)
    c.edge(hol, UM2)
    # earth at the feet
    c.add(c.m(K.rect(0, 51, 64, 56)) & body - hol, EARTH)
    # web across the hollow: spokes and one ring (silk tangle)
    cx, cy = 32, 39
    import math
    for i in range(8 if not c.small else 0):
        a = math.pi * 2 * i / 8 + 0.2
        c.line([(cx, cy), (cx + 11.5 * math.cos(a), cy + 14.5 * math.sin(a))], '#5e5470')
    if not c.small:
        ring = c.m(K.ell(cx, cy, 9.5, 12)) - c.m(K.ell(cx, cy, 8.5, 11))
        for q in ring & hol:
            c.px(q[0], q[1], '#5e5470')
    # little silk spider: legs then fuzzy body
    lw = 1.5 if not c.small else 2.0
    legs = []
    for sx in (-1, 1):
        legs += [[(cx + sx * 5, cy - 3), (cx + sx * 9, cy - 9), (cx + sx * 11, cy - 6)],
                 [(cx + sx * 5, cy + 3), (cx + sx * 10, cy + 6), (cx + sx * 10, cy + 11)]]
    c.add(c.m(*[K.thick_path(L, lw) for L in legs]) & hol, ('#b8b0c4', '#8a809c', '#d8d0e0'))
    c.add(c.m(K.ell(cx, cy + 0.5, 7.2 if not c.small else 7.6, 6.4 if not c.small else 6.8)), SILK)
    if not c.small:
        c.line([(cx - 5, cy - 3), (cx, cy - 5), (cx + 5, cy - 3)], '#c8c0d4')
    c.eye(cx - 2.2, cy, look=(0, 0))
    c.eye(cx + 2.4, cy, look=(0, 0))
    c.smile(cx, cy + 3.5, UM2)
    # bark grain
    if not c.small:
        for gx in (17, 47):
            x = c.P(gx, 0)[0]
            for y in range(c.P(0, 21)[1], c.P(0, 30)[1]):
                c.px(x + (y // 4) % 2, y, BARK[1])


UM2 = '#2e2a3c'

K.render_pal(fn, 'pl-sbs-3', 'Buttress Tangle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-3.png')
