import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Smoke Ringlet: a lavender smoke puff that is an inner piece with four hook blanks (BBBB); its hole is the smoke ring
# and its O-mouth. Puffy corner lumps; rust/ember rim from the mushroom cap and caldera glow; purple sky in the shade.
SMOKE = ('#b4aed0', '#7a6a9c', '#e8e4f4')
PUFF = K.ramp('#ece8f4')
RUST = K.ramp('#b0503a')
EMBER = '#f0a020'

def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(9, 10, 55, 56)
    lumps = [K.ell(12, 13, 6, 6), K.ell(52, 13, 6, 6), K.ell(12, 53, 6, 6), K.ell(52, 53, 6, 6)]
    blanks = [K.knob('B', 'hook', 32, 10, 0, -1, r=4.0 * s),
              K.knob('B', 'hook', 32, 56, 0, 1, r=4.0 * s),
              K.knob('B', 'hook', 9, 33, -1, 0, r=4.0 * s),
              K.knob('B', 'hook', 55, 33, 1, 0, r=4.0 * s)]
    hole_r = 5.5 if not c.small else 6.0
    hole = K.ell(32, 39, hole_r, hole_r * 0.9)
    # cloud scallops along each side, between corner lump and blank
    bumps = []
    for t in (20, 44):
        bumps += [K.ell(t, 10.5, 3.6, 3.0), K.ell(t, 55.5, 3.6, 3.0), K.ell(9.5, t, 3.0, 3.6), K.ell(54.5, t, 3.0, 3.6)]
    # a smoke wisp curling up off the top-right lump
    wisp = lambda x, y: K.ell(57.5, 7.5, 3.6, 3.2)(x, y) or K.ell(60.5, 3.2, 2.4, 2.2)(x, y)
    body = c.m(core, *lumps, *bumps, wisp, minus=blanks)
    c.add(body, SMOKE, stitch=None if c.small else '#9a90bc')
    # lower half lit warm from the caldera below (picture's mauve-rust)
    import math
    warm = c.m(lambda x, y: y > 48 + 1.6 * math.sin(x * 0.55), minus=blanks) & body
    c.add(warm, ('#c49aac', '#8a5a78', '#e0c4cc'))
    # white puff highlights on the upper-left lumps
    p1 = c.m(K.ell(15, 16, 5, 4), minus=blanks)
    c.add(p1, PUFF)
    p2 = c.m(K.ell(48, 15, 4, 3.2), minus=blanks)
    c.add(p2, PUFF)
    # rust/ember rim around the ring's hole
    rim = c.m(K.ell(32, 39, hole_r + 3.2, hole_r * 0.9 + 3.0), minus=(hole,))
    c.add(rim, PUFF)
    c.edge(rim, '#8e80b0')
    hp = c.m(hole)
    c.cut |= hp
    # ember glint on the rim's lower edge
    for (x, y) in rim:
        X, Y = (x + .5) / c.k, (y + .5) / c.k
        if Y > 39 + hole_r * 0.55 and abs(X - 32) < hole_r:
            c.px(x, y, '#e08a5a')
    # face above the O
    c.eye(24, 26, look=(0, 0))
    c.eye(40, 26, look=(0, 0))
    c.blush(19, 31)
    c.blush(44, 31)
    # a wisp curling off the top-right corner lump (inner swirl line)
    if not c.small:
        c.line([(46, 47), (49, 49), (52, 48)], '#8e80b0')
        c.line([(14, 46), (17, 48)], '#8e80b0')

K.render_pal(fn, 'pl-smk-5', 'Smoke Ringlet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-5.png')
