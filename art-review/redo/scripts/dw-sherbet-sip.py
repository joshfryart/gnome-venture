# Sherbet Sip: a sunset-glazed mint-tea pot that is a corner piece. Flat left + flat bottom (foot), round tab on top = lid finial,
# round tab on right = handle; brass spout up-left. Body = the cell's sunset (orange -> coral) with a purple dune and an indigo camel.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

ORANGE = K.ramp('#f3ac5a')
CORAL = K.ramp('#e88b62')
MAUVE = K.ramp('#a85f8a')
PURPLE = K.ramp('#7b4a81')
INDIGO = ('#3d2a62', '#2e2050', '#5a4482')
BRASS = K.GOLD
MINT = K.ramp('#3f9a4a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(10, 21), (15, 16), (45, 16), (50, 21), (50, 50), (47, 53), (13, 53), (10, 50)])
    foot = K.rect(14, 52, 46, 58)
    top = K.knob('T', 'round', 30, 16.5, 0, -1, r=4.6 * k)
    right = K.knob('T', 'round', 49.5, 34, 1, 0, r=4.8 * k)
    spout = lambda x, y: K.thick_path([(12, 46), (7, 42)], 7.0)(x, y) or K.thick_path([(7, 42), (4, 35), (3, 28)], 4.6 if c.small else 4.0)(x, y)
    spout_tip = K.ell(3, 27, 2.8, 2.0)
    body = c.m(core, foot, top, right, spout, spout_tip)
    # spout + handle (behind body)
    c.add(c.m(spout, spout_tip), BRASS)
    c.add(c.m(right, minus=(core,)), BRASS)
    # body: sunset orange, coral lower half
    c.add(c.m(core), ORANGE, stitch=None)
    lower = K.rect(10, 36, 51, 54)
    c.add(c.m(core, minus=()) & c.m(lower), CORAL)
    # purple dune with camel
    dune = K.poly([(10, 44), (20, 41), (30, 44), (40, 42), (50, 45), (50, 50), (47, 53), (13, 53), (10, 50)])
    c.add(c.m(dune), PURPLE)
    # lid: mauve dome band + brass rim
    lid = K.rect(10, 15, 51, 22)
    c.add(c.m(core) & c.m(lid), MAUVE)
    rim = K.rect(10, 22, 51, 24.5)
    c.add(c.m(core) & c.m(rim), BRASS)
    c.add(c.m(top, minus=(core,)) | (c.m(K.ell(30, 16, 4, 2)) & body), BRASS)
    c.add(c.m(foot, minus=(core,)) | c.m(K.rect(14, 53, 46, 58)), BRASS)
    # camel silhouette (indigo) walking on the dune, lower right
    camel = [K.ell(25, 45.5, 5.2, 3.0), K.ell(26, 42.8, 2.8, 2.2),
             K.thick_path([(21, 45), (18, 40), (16.5, 38.5)], 2.6), K.ell(16.4, 38.6, 1.9, 1.3),
             K.thick_path([(21.5, 47), (21.8, 52)], 2.0), K.thick_path([(28.5, 47), (28.8, 52)], 2.0)]
    if c.small:
        camel = [K.ell(25, 45.5, 5.4, 3.2), K.ell(26, 42.5, 3.0, 2.5),
                 K.thick_path([(21, 45), (17.5, 39.5)], 3.4), K.ell(16.5, 39, 2.4, 1.8),
                 K.thick_path([(21.5, 47), (21.5, 52)], 3.2), K.thick_path([(28.5, 47), (28.5, 52)], 3.2)]
    cm = c.m(*camel) & c.m(core)
    for p in cm:
        c.px(p[0], p[1], INDIGO[0])
    # mint sprig poking from the lid (a tea pot of mint tea)
    # face on the calm orange shoulder
    c.eye(22, 30)
    c.eye(32, 30)
    c.smile(27, 34)
    c.blush(18.5, 34)
    c.blush(35.5, 34)
    # brass band highlight dots on lid
    if not c.small:
        for x in (15, 21, 39, 45):
            c.px(*c.P(x, 18.5), BRASS[2])


K.render_pal(fn, 'dw-sherbet-sip', 'Sherbet Sip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/dw-sherbet-sip-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/dw-sherbet-sip.png')
