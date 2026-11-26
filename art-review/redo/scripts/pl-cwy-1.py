import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Ember Flake: corner-BB hook. A glowing cinder chunk; flat W + S (it sits on the forge floor), hook blanks N + E,
# a curling flame wisp rising from the NW corner. Forge-mouth ramps from cell 11-7: yellow top, orange middle, lava red base.
YEL = K.ramp('#f8d860')
ORG = K.ramp('#f8a030')
RED = K.ramp('#d84a22')
CRUST = ('#7a2a18', '#561c10', '#a0401e')
FLAME = K.ramp('#fbe48a')
GLOW = '#ffe9a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(9, 21), (13, 17), (52, 17), (54, 21), (54, 57), (9, 57)])
    bN = K.knob('B', 'hook', 40, 17, 0, -1, r=4.6 * k)
    bE = K.knob('B', 'hook', 54, 38, 1, 0, r=4.6 * k, flip=True)
    # three flame tongues licking up from the top-left of the cinder
    flame = K.poly([(9, 22), (8, 12), (11, 6), (13, 12), (16, 2), (20, 10), (23, 5), (26, 12), (29, 8), (31, 19)])
    body = c.m(core, minus=(bN, bE))
    c.add(body, ORG)
    c.add(c.m(flame, minus=(core,)) | (c.m(flame) & c.m(K.rect(0, 0, 64, 19))), FLAME)
    inner = c.m(K.poly([(12, 19), (12, 13), (15, 9), (17, 14), (20, 11), (23, 15), (25, 12), (27, 19)]))
    c.add(inner, ORG)
    c.add(c.m(lambda x, y: y > 36) & body, RED)
    # hot glow under the flames, fading to red
    glow = c.m(lambda x, y: y < 26 + (2 if (x // 5) % 2 else 0) and x < 36) & body
    c.add(glow, YEL)
    # charred crust plates with glowing seams between them
    plates = [K.poly([(9, 40), (20, 37), (25, 44), (21, 57), (9, 57)]),
              K.poly([(24, 47), (34, 45), (40, 50), (38, 57), (25, 57)]),
              K.poly([(42, 46), (54, 43), (54, 57), (42, 57)])]
    for pl in plates:
        m = c.m(pl) & body
        c.add(m, CRUST)
    seam = c.m(K.thick_path([(21, 57), (25, 44), (20, 37)], 1.0), K.thick_path([(38, 57), (40, 50), (42, 46)], 1.0))
    for (x, y) in seam & body:
        c.px(x, y, YEL[0])
    if not c.small:
        for p in ((15, 47), (47, 51), (31, 51)):
            x, y = c.P(*p)
            c.px(x, y, ORG[0]); c.px(x + 1, y, ORG[0])
        for p in ((30, 21), (45, 33)):
            x, y = c.P(*p)
            c.px(x, y, GLOW)
    c.eye(23, 32, disc=True)
    c.eye(35, 32, disc=True)
    c.smile(29, 38, wide=not c.small)


K.render_pal(fn, 'pl-cwy-1', 'Ember Flake', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cwy-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cwy-1.png')
