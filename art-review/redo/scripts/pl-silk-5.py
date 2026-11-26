import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Concept: a sandstone courtyard fountain basin as an inner-BBBB piece (double-knob blanks on all four sides);
# teal dome-coloured water fills the top with two splash jets curling up at the top corners, a brick rim lip,
# sand-brick front with a felt face. Colours: sand cell (#e8c08c / #f2d8a8) + caravanserai teal domes + brick walls.
SAND = K.ramp('#e2b77e')
BRICK = K.ramp('#c8925a')
WATER = K.ramp('#2f9a8e')
FOAM = K.ramp('#9fe0d4')
MORTAR = '#a8753f'

def fn(c):
    S = 1.15 if c.small else 1.0
    r = 3.6 * S
    core = K.rect(8, 9, 56, 58)
    lip = K.rect(6, 21, 58, 26)
    blanks = (K.knob('B', 'double', 32, 8, 0, -1, r=r),
              K.knob('B', 'double', 32, 58, 0, 1, r=r),
              K.knob('B', 'double', 8, 31, -1, 0, r=r),
              K.knob('B', 'double', 56, 31, 1, 0, r=r))
    # splash jets at the top corners (rounded drops leaning outward)
    def drop(x, h):
        q = 3.2 if c.small else 2.6
        return lambda X, Y: K.ell(x, 10 - h, q, q)(X, Y) or K.poly([(x - 1.6, 11), (x + 1.6, 11), (x + 1.0, 10 - h), (x - 1.0, 10 - h)])(X, Y)
    jl = lambda x, y: drop(14, 5.5)(x, y) or drop(21.5, 3)(x, y)
    jr = lambda x, y: drop(50, 5.5)(x, y) or drop(42.5, 3)(x, y)
    body = c.m(core, lip, jl, jr, minus=blanks)
    c.add(body, SAND, stitch=None if c.small else '#f4dcb0')
    water = c.m(K.rect(8, 8, 56, 22), jl, jr, minus=blanks)
    c.add(water, WATER)
    foam = c.m(K.ell(14, 4.5, 2.6, 2.6), K.ell(50, 4.5, 2.6, 2.6), K.ell(21.5, 7, 2.6, 2.6), K.ell(42.5, 7, 2.6, 2.6))
    c.add(foam & body, FOAM)
    rim = c.m(lip, minus=blanks)
    c.add(rim, BRICK)
    c.edge(rim, MORTAR)
    # ripples on the water
    c.line([(14, 15), (19, 15)], FOAM[0])
    c.line([(44, 15), (50, 15)], FOAM[0])
    if not c.small:
        c.line([(17, 18), (22, 18)], FOAM[2]); c.line([(41, 18), (46, 18)], FOAM[2])
    # mortar courses on the basin front
    for yy in (35, 46, 53):
        c.line([(9, yy), (55, yy)], MORTAR)
    for xx, y0, y1 in ((14, 35, 46), (50, 35, 46), (20, 46, 53), (44, 46, 53), (14, 53, 58), (50, 53, 58)):
        c.line([(xx, y0), (xx, y1 - 0.5)], MORTAR)
    # face
    c.eye(25, 39)
    c.eye(39, 39)
    c.smile(32, 43 if not c.small else 42.5, wide=True)
    c.blush(19, 43); c.blush(44, 43)

K.render_pal(fn, 'pl-silk-5', 'Basin Splashback', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-5.png')
