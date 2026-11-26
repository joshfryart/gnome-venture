# Tiny Door Ajar: an old stump that is an inner-BBBB keyhole piece; tiny glowing door ajar in the bark, grass at the roots.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
BARK = K.ramp('#8a5634')
TOP = K.ramp('#c89a64')
GRASS = K.ramp('#3a8a58')
GLOW = ('#f6d04a', '#e0a020', '#fff0a0')
DOOR = K.ramp('#6a3a20')
PINK = K.ramp('#d8507a')
STEM = K.ramp('#efe2c4')


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 3.2 * s
    core = K.rect(7, 8, 57, 57)
    blanks = [K.knob('B', 'keyhole', 32, 8, 0, -1, r=r),
              K.knob('B', 'keyhole', 32, 57, 0, 1, r=r),
              K.knob('B', 'keyhole', 7, 34, -1, 0, r=r),
              K.knob('B', 'keyhole', 57, 34, 1, 0, r=r)]
    body = c.m(core, minus=blanks)
    c.add(body, BARK, stitch=None)
    # cut top (rings) as an ellipse band
    top = c.m(K.ell(32, 8, 25, 9), minus=blanks)
    c.add(top, TOP)
    c.edge(top, BARK[1])
    # rings
    c.line([(12, 11), (22, 13), (25, 12)], TOP[1])
    c.line([(39, 12), (44, 13), (52, 11)], TOP[1])
    # bark grain
    for gx in (11, 52):
        c.line([(gx, 20), (gx, 26)], BARK[1])
    for gx in (13, 19, 45, 51):
        c.line([(gx, 41), (gx, 47)], BARK[1])
    # grass skirt at the roots
    grass = c.m(K.poly([(7, 57), (7, 49), (10, 51), (13, 46), (16, 50), (19, 47), (23, 51), (25, 57)]),
                K.poly([(39, 57), (41, 51), (45, 47), (48, 50), (51, 46), (54, 51), (57, 49), (57, 57)]), minus=blanks)
    c.add(grass, GRASS)
    # door frame + glowing arch
    frame = c.m(K.rect(24.5, 32, 39.5, 46), K.ell(32, 32, 7.5, 7.5), minus=blanks)
    c.add(frame, DOOR)
    glow = c.m(K.rect(27, 32, 37, 46), K.ell(32, 32, 5, 5.2), minus=blanks)
    c.add(glow, GLOW)
    # door leaf swung open (narrow, on the right)
    leaf = c.m(K.poly([(33.5, 28.5), (38, 30.5), (38, 46), (33.5, 46)]), minus=blanks)
    c.add(leaf, K.ramp('#a8683a'))
    c.edge(leaf, DOOR[1])
    kx, ky = c.P(34.5, 38)
    c.px(kx, ky, GLOW[2])
    # pink mushroom on the stump top (from the picture)
    cap = c.add(c.m(K.ell(46, 8, 6, 4.2), minus=blanks + [K.rect(0, 8, 64, 64)]), PINK)
    c.add(c.m(K.rect(44, 7, 48, 12)), STEM)
    c.add(c.m(K.ell(46, 8, 6, 4.2), minus=[K.rect(0, 8, 64, 64)]), PINK)
    for (dx, dy) in ((44, 6), (48, 6.5)):
        c.px(*c.P(dx, dy), '#f6c8d8')
    # felt face on the bark, above the door
    c.eye(21, 23)
    c.eye(43, 23)
    c.blush(17, 28)
    c.blush(46, 28)
    # doorstep
    c.add(c.m(K.rect(23, 45.5, 41, 48), minus=blanks), STEM)


K.render_pal(fn, 'pl-wfri-5', 'Tiny Door Ajar', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-wfri-5-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-wfri-5.png')
