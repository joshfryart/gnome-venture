# Kapok Nook: a kapok tree-trunk house that is a corner piece. Flat W + S (trunk side and the ground line),
# round tab N = the leafy kapok crown with a white kapok-fluff puff, round blank E bitten into the bark.
# Front: arched wooden door at the foot, round glowing window, red lantern, green vine; buttress roots. Rainroot cell 1-4.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BARK = K.ramp('#a99a7b')
GROOVE = '#7a6a51'
DOOR = K.ramp('#b07a3a')
WIN = K.ramp('#f5cf6a')
LEAF = K.ramp('#3f9a4a')
VINE = K.ramp('#307a45')
LANT = K.ramp('#c0462a')
FLUFF = K.ramp('#f4f0e4')
ROOT = K.ramp('#8a7858')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 19, 53, 58)
    tabN = K.knob('T', 'round', 31, 19, 0, -1, r=6.2 * k, nw=3.6 * k)
    blankE = K.knob('B', 'round', 53, 43, 1, 0, r=4.6 * k)
    body = c.m(core, minus=(blankE,))
    c.add(body, BARK, stitch=None)
    # vertical bark grooves (the kapok's ribbed trunk)
    for gx, y0, y1 in ((13, 27, 55), (19, 27, 40), (42, 28, 37), (48, 27, 36), (40, 50, 57), (23, 50, 57)):
        c.line([(gx, y0), (gx + 0.8, y1)], GROOVE)
    # buttress roots flaring at the foot
    c.add(c.m(K.poly([(9, 44), (21, 58), (9, 58)])) & body, ROOT)
    c.add(c.m(K.poly([(53, 49), (53, 58), (40, 58)])) & body, ROOT)
    c.edge(c.m(K.poly([(9, 44), (21, 58), (9, 58)])) & body, ROOT[1])
    # leafy canopy: the top of the piece plus the round tab, scalloped hem
    hem = [K.ell(x, 25.5, 3.4, 3.2) for x in (11.5, 18, 24.5, 31, 37.5, 44, 50.5)]
    canopy = c.m(tabN, K.rect(0, 0, 64, 25), *hem) & (body | c.m(tabN))
    c.add(canopy, LEAF)
    c.edge(canopy, VINE[1])
    leafdots = ((27, 10), (34, 13), (14, 21), (22, 23), (38, 21), (47, 22), (30, 20)) if not c.small else ((28, 11), (16, 22), (40, 22))
    for p in leafdots:
        x, y = c.P(*p)
        c.px(x, y, LEAF[2]); c.px(x + 1, y, LEAF[2])
    # kapok pod with white fluff peeking from the crown
    c.add(c.m(K.ell(34.5, 9.5, 2.3 * k, 2.0 * k)), FLUFF)
    # vine trailing down the left side
    c.add(c.m(K.thick_path([(14, 27), (11.5, 34), (12, 42)], 2.8 if c.small else 2.2)) & body, VINE)
    # round window, glowing
    win = c.m(K.ell(17.5, 47, 3.9 * k, 3.9 * k))
    c.add(win, WIN)
    cx, cy = c.P(17.5, 47)
    if not c.small:
        for d in range(-2, 3):
            c.px(cx + d, cy, DOOR[1]); c.px(cx, cy + d, DOOR[1])
    c.edge(win, DOOR[1])
    # arched door at the foot
    door = c.m(K.rect(26, 47, 37, 58), K.ell(31.5, 47, 5.5, 5))
    c.add(door, DOOR)
    c.edge(door, DOOR[1])
    if not c.small:
        x = c.P(31.5, 0)[0]
        for y in range(c.P(0, 44)[1], c.P(0, 58)[1]):
            c.px(x, y, DOOR[1])
    c.px(*c.P(34.5, 53), WIN[0])
    # red lantern hanging from the canopy
    c.line([(45.5, 27), (45.5, 29)], K.UMBER2 if not c.small else GROOVE)
    lant = c.m(K.rect(42.5, 29, 49, 36))
    c.add(lant, LANT)
    c.add(c.m(K.rect(42.5, 29, 49, 30.6)), FLUFF)
    if not c.small:
        c.px(*c.P(45.5, 33), WIN[0])
    # face on the trunk
    c.eye(25, 35)
    c.eye(36, 35)
    c.smile(30.5, 39.5)
    c.blush(21, 39)
    c.blush(40, 39)


K.render_pal(fn, 'rr-kapok-nook', 'Kapok Nook', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/rr-kapok-nook-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/rr-kapok-nook.png')
