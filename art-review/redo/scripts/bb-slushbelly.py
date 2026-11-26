# Slushbelly: a snowman that is a corner piece. Flat top = hat crown, flat left side; round blanks on the right (melted belly scoop)
# and bottom (into the slush puddle). Motif from birchbramble cell 8-6: brown hat, white snowman, red scarf, carrot nose, green grass.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SNOW = ('#f2f4f6', '#b4c2d6', '#ffffff')
HAT = K.ramp('#a8522e')
BRIM = K.ramp('#7a3a22')
SCARF = K.ramp('#d8302a')
SLUSH = K.ramp('#8cc0e4')
GRASS = K.ramp('#5aa83a')
CARROT = '#f08a20'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(7, 17, 57, 57)(x, y) or K.rect(14, 6, 50, 17)(x, y)
    bR = K.knob('B', 'round', 57, 40, 1, 0, r=4.5 * s)
    bB = K.knob('B', 'round', 34, 57, 0, 1, r=4.5 * s)
    body = c.m(core, minus=(bR, bB))
    c.add(body, SNOW)
    # slush puddle melting along the base (light blue), with a grass edge at the very bottom
    slush = c.m(K.rect(7, 49, 57, 57), K.ell(14, 49, 6, 3), K.ell(50, 50, 6, 3), minus=(bR, bB)) & body
    c.add(slush, SLUSH)
    grass = c.m(K.rect(7, 54, 57, 57), minus=(bB,)) & body
    c.add(grass, GRASS)
    # hat: crown is the flat top side, brim below
    c.add(c.m(K.rect(14, 6, 50, 17)) & body, HAT)
    c.add(c.m(K.rect(14, 13, 50, 16)) & body, K.ramp('#d8302a'))
    c.add(c.m(K.rect(7, 17, 57, 22)) & body, BRIM)
    # head / belly contour (two snowballs)
    head = c.m(K.ell(32, 29, 16, 10)) & body
    c.edge(head, '#c8d2e0')
    # scarf band with a tail hanging on the flat left side
    sc = c.m(K.rect(7, 35, 52, 40), K.rect(10, 35, 17, 50)) & body
    c.add(sc, SCARF)
    for yy in (41, 44, 47):
        c.line([(10, yy), (15.5, yy)], SCARF[1])
    # face
    c.eye(26, 28)
    c.eye(38, 28)
    nx, ny = c.P(32, 31)
    if c.small:
        for dx in range(0, 4):
            c.px(nx + dx, ny, CARROT)
        c.px(nx, ny + 1, '#c06010')
    else:
        for dx in range(0, 7):
            c.px(nx + dx, ny, CARROT)
            if dx < 4:
                c.px(nx + dx, ny + 1, '#c06010')
    c.smile(32, 33.5)
    # coal buttons on the belly
    for yy in (43,):
        bx, by = c.P(30, yy)
        c.px(bx, by, K.UMBER)
        c.px(bx + 1, by, K.UMBER)
        if not c.small:
            c.px(bx, by + 1, K.UMBER)
            c.px(bx + 1, by + 1, K.UMBER)
    # melt drips running down into the puddle
    for x0 in (22, 44):
        c.line([(x0, 44), (x0, 49)], '#c8d8ea')


K.render_pal(fn, 'bb-slushbelly', 'Slushbelly', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-slushbelly-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-slushbelly.png')
