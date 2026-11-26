import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Gable Eye: a thatch owl-house. inner-BBBB, round blanks on all 4 sides; the top blank sits between two thatch
# ear-tufts, the round gable window is one big sleepy eye under a thatch eyelid; straw gold from cell 5-2, cream timbered wall, amber glass.
THATCH = K.ramp('#e0aa4c')
STRAW = K.ramp('#c88a3a')
WALL = K.ramp('#f0e4cc')
TIMBER = K.ramp('#6e4426')
FRAME = K.ramp('#8a5426')
GLASS = K.ramp('#f6c64a')
STRAND = '#a8702e'
ROOT = '/home/user/gnome-venture/art-review/redo/'

def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.2 * s
    core = K.rect(7, 10, 57, 58)
    tuftL = K.poly([(7, 12), (7, 3), (10, 2), (19, 10)])
    tuftR = K.poly([(57, 12), (57, 3), (54, 2), (45, 10)])
    blanks = (K.knob('B', 'round', 32, 10, 0, -1, r), K.knob('B', 'round', 32, 58, 0, 1, r),
              K.knob('B', 'round', 7, 35, -1, 0, r), K.knob('B', 'round', 57, 35, 1, 0, r))
    body = c.m(core, tuftL, tuftR, minus=blanks)
    c.add(body, THATCH, stitch=None if c.small else STRAW[0])
    # thatch courses: darker straw bands (rows of the roof)
    for y in (18, 50):
        band = c.m(*[K.ell(x, y, 2.6, 2.0) for x in range(7, 59, 4)]) & body
        c.add(band, STRAW)
    if not c.small:
        for (x, y) in ((12, 25), (48, 25), (12, 44), (48, 44), (18, 54), (42, 54), (12, 13), (48, 13)):
            c.line([(x, y), (x + 3, y + 2)], STRAND)
    # cream wall disc behind the window (the window sits in the plaster under the thatch)
    cx, cy, R = 32, 35, 9.0
    c.add(c.m(K.ell(cx, cy, R + 1.8, R + 1.8)) & body, WALL)
    c.add(c.m(K.ell(cx, cy, R, R)), FRAME)
    glass = c.m(K.ell(cx, cy, R - 2.0, R - 2.0))
    c.add(glass, GLASS)
    # sleepy thatch eyelid over the top third
    lid = c.m(K.ell(cx, cy, R + 0.4, R + 0.4), minus=(K.rect(0, cy - 3, 64, 64),))
    c.add(lid, THATCH)
    c.edge(lid, STRAW[1])
    # big round pupil (the eye) under the lid
    pc = c.m(K.ell(cx, cy + 1.5, 3.8 * s, 3.8 * s), minus=(K.rect(0, 0, 64, cy - 3),))
    c.add(pc, TIMBER)
    gx, gy = c.P(cx - 1.8 * s, cy - 0.2)
    c.px(gx, gy, K.CREAM); c.px(gx + 1, gy, K.CREAM)
    if not c.small:
        c.px(gx, gy + 1, K.CREAM)
    # two thatch eyebrow tufts either side of the top blank, like the dormer eyebrows in the picture
    for sg in (-1, 1):
        brow = c.m(K.thick_path([(cx + sg * 7, cy - 13), (cx + sg * 12, cy - 12.5), (cx + sg * 15, cy - 8)], 3.6 if c.small else 3.0))
        c.add(brow, STRAW)
    c.blush(16, 44)
    c.blush(47, 44)

K.render_pal(fn, 'pl-thch-5', 'Gable Eye', ROOT + 'out', cellfile=ROOT + '_src/pl-thch-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-5.png')
