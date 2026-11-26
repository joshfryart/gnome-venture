import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Concept: Hullmate Octopus - red chibi octopus (galleon's octopus) whose mantle + tentacle skirt is a square piece;
# keyhole tab right, keyhole blanks top and left; hugs a brown hull plank with dark seams (cell 3-5), sandy glint.
RED = K.ramp('#d8404e')
REDL = K.ramp('#e8687a')
PLANK = K.ramp('#a86a3e')
SEAM = '#3a2430'
SAND = '#e8b060'

def fn(c):
    k = 1.15 if c.small else 1.0
    dome = K.ell(32, 24, 19, 15)
    core = K.rect(13, 22, 51, 46)
    tR = K.knob('T', 'keyhole', 51, 31, 1, 0, r=5.0 * k)
    bL = K.knob('B', 'keyhole', 13, 31, -1, 0, r=4.8 * k)
    tT = K.knob('T', 'keyhole', 32, 9, 0, -1, r=3.6 * k)
    # tentacle tips: rounded lobes along the bottom, curling outward at the ends
    lobes = [K.ell(17, 49, 4.4, 5), K.ell(27, 51, 4.4, 5.5), K.ell(37, 51, 4.4, 5.5), K.ell(47, 49, 4.4, 5)]
    curlL = K.thick_path([(15, 50), (11, 54), (12, 57), (15, 57)], 4.4)
    curlR = K.thick_path([(49, 50), (53, 54), (52, 57), (49, 57)], 4.4)
    gaps = [K.ell(22, 55, 1.6, 6), K.ell(32, 57, 1.6, 6), K.ell(42, 55, 1.6, 6)]
    body = c.m(dome, core, tR, tT, *lobes, curlL, curlR, minus=[bL] + gaps)
    c.add(body, RED, stitch=None if c.small else '#f08a96')
    # hull plank hugged across the lower body
    plank = c.m(K.rect(13, 38, 51, 47)) & body
    c.add(plank, PLANK)
    c.edge(plank, SEAM)
    # seams and nail on plank
    c.line([(14, 42), (50, 42)], SEAM)
    for nx in (16, 48):
        x, y = c.P(nx, 39)
        c.px(x, y, SAND)
    # two arms wrapping over the plank
    armA = c.m(K.thick_path([(20, 36), (20, 46)], 5.0))
    armB = c.m(K.thick_path([(44, 36), (44, 46)], 5.0))
    c.add(armA, RED)
    c.add(armB, RED)
    c.edge(armA, '#a02e3c')
    c.edge(armB, '#a02e3c')
    # hat-red knob on top (the galleon octopus wears a red gnome cap)
    hat = c.m(tT, minus=[K.rect(0, 12, 64, 64)])
    c.add(hat, K.ramp('#c82a2a'))
    # suckers
    if not c.small:
        for sx, sy in ((26, 52), (36, 52), (17, 50), (46, 50)):
            x, y = c.P(sx, sy)
            c.px(x, y, '#f6b8c0')
    # mantle spots
    for sx, sy in ((22, 20), (42, 19), (46, 26)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#a8303e')
        if not c.small:
            c.px(x + 1, y, '#a8303e')
    # face
    c.eye(26, 28, disc=True)
    c.eye(38, 28, disc=True)
    c.smile(32, 33)
    c.blush(21, 33)
    c.blush(43, 33)

K.render_pal(fn, 'pl-sung-6', 'Hullmate Octopus', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-6.png')
