# Archway Ember: a mossy temple-stone lantern block that is an inner piece with four keyhole blanks (top cuts the moss cap,
# left/right cut the stone, bottom cuts under a wrapping root); the glowing arched doorway of the picture holds a little ember with a face.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#b4bc98')
MOSS = K.ramp('#5aa040')
ROOT = K.ramp('#a8744a')
GLOW = K.ramp('#fae5a5')
EMBER = K.ramp('#f0a020')
DOOR = K.ramp('#55383a')


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 3.7 * s
    core = K.poly([(11, 8), (53, 8), (56, 11), (56, 53), (53, 56), (11, 56), (8, 53), (8, 11)])
    blanks = (K.knob('B', 'keyhole', 32, 8, 0, -1, r=r),
              K.knob('B', 'keyhole', 8, 32, -1, 0, r=r),
              K.knob('B', 'keyhole', 56, 32, 1, 0, r=r),
              K.knob('B', 'keyhole', 32, 56, 0, 1, r=r))
    c.add(c.m(core, minus=blanks), STONE, stitch=None)
    # stone courses (block seams)
    seam = STONE[1]
    for y in (19, 45):
        c.line([(9, y), (22, y)], seam)
        c.line([(42, y), (55, y)], seam)
    c.line([(15, 19), (15, 45)], seam) if not c.small else None
    c.line([(49, 19), (49, 45)], seam) if not c.small else None
    # moss cap with drips
    moss = K.poly([(7, 7), (57, 7), (57, 15), (50, 16), (47, 20), (43, 16), (22, 16), (18, 21), (15, 16), (7, 17)])
    c.add(c.m(moss, minus=blanks), MOSS)
    # moss tufts on sides
    c.add(c.m(K.ell(11, 50, 4, 3), K.ell(53, 24, 3, 3), minus=blanks), MOSS)
    # arched doorway: dark frame, glowing interior
    arch_o = lambda x, y: (21 <= x < 43 and 29 <= y < 47) or ((x - 32) ** 2 + (y - 29) ** 2 < 11 ** 2 and y < 29)
    arch_i = lambda x, y: (24 <= x < 40 and 29 <= y < 47) or ((x - 32) ** 2 + (y - 29) ** 2 < 8 ** 2 and y < 29)
    c.add(c.m(arch_o, minus=blanks), DOOR)
    c.add(c.m(arch_i, minus=blanks), GLOW)
    # the ember: teardrop flame
    flame = lambda x, y: ((x - 32) / 6.5) ** 2 + ((y - 37) / 6) ** 2 < 1 or (y < 37 and abs(x - 32) < (y - 25) * 0.55)
    fm = c.m(flame, minus=blanks)
    c.add(fm, EMBER)
    c.add(c.m(K.ell(32, 39, 3, 3) , minus=blanks), K.ramp('#f8d060'))
    # wrapping root across the lower stones
    root = K.thick_path([(9, 50), (18, 47), (30, 49), (44, 46), (55, 43)], 5.5 * s)
    c.add(c.m(lambda x, y: root(x, y) and core(x, y), minus=blanks), ROOT)
    c.eye(29.5, 37, look=(0, 0))
    c.eye(35, 37, look=(0, 0))
    if not c.small:
        c.blush(27, 40)
        c.blush(36, 40)


K.render_pal(fn, 'pl-wroo-5', 'Archway Ember', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-5.png')
