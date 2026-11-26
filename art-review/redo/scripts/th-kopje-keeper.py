"""Kopje Keeper: inner-TTBB, hook. A sage soapstone bird statue on its plinth (cell 1-2, Thornacre).
Tabs: N = the round stone head with a hooked beak, W = a curled tail. Blanks: E (cut into the chest), S (cut into the plinth).
Sage-green stone, greige plinth with a sunrise-orange zigzag carving (the sky behind the statue)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAGE = K.ramp('#9aa684')
SAGED = K.ramp('#7a8567')
PLINTH = K.ramp('#b9a189')
SUN = '#f39a4a'
BEAK = K.ramp('#c8b48a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 22, 50, 57)
    head = K.ell(31, 17, 9, 8.5)
    beak = K.poly([(37, 11.5), (45, 12), (48.5, 15.5), (48, 21.5), (45.5, 18), (38, 19.5)])
    tabW = lambda x, y: K._ks('hook', y - 33, 13 - x, 5.6 * s, 3.0, solid=True)  # solid comma tail, tip curling up
    blankE = K.knob('B', 'hook', 50, 36, 1, 0, r=4.6 * s)
    blankS = K.knob('B', 'hook', 31, 57, 0, 1, r=4.6 * s)
    blanks = (blankE, blankS)
    body = c.m(core, head, tabW, minus=blanks)
    c.add(body, SAGE, stitch=None)
    # head (tab N)
    c.add(c.m(head, minus=(core,)) | (c.m(head) & c.m(K.rect(0, 0, 64, 23))), SAGE)
    c.add(c.m(beak), BEAK)
    # tail curl (tab W) in the darker stone
    tail = c.m(tabW, minus=(core,))
    c.add(tail, SAGED)
    # folded wing: a darker oval with scale chevrons
    wing = c.m(K.ell(27, 36, 10, 8.5), minus=blanks)
    c.add(wing, SAGED)
    c.edge(wing, SAGED[1])
    rows = (31, 35, 39) if not c.small else (32, 38)
    for ry in rows:
        for cx in (22, 28, 33) if not c.small else (23, 31):
            x, y = c.P(cx, ry)
            c.px(x - 1, y, SAGED[2]); c.px(x, y + 1, SAGED[2]); c.px(x + 1, y, SAGED[2])
            if not c.small:
                c.px(x - 2, y - 1, SAGED[2]); c.px(x + 2, y - 1, SAGED[2])
    # plinth
    pl = c.m(K.rect(0, 46, 64, 64), minus=blanks) & body
    c.add(pl, PLINTH)
    y0 = c.P(0, 49.5)[1]
    for x in range(c.P(13, 0)[0], c.P(50, 0)[0]):
        z = (x // (1 if c.small else 2)) % 2
        c.px(x, y0 + z, SUN)
        if not c.small:
            c.px(x, y0 + z + 1, SUN)
    # unblinking felt eye on the head, looking out
    c.eye(32, 16, disc=True, look=(1, 0))
    # brow ridge of stone
    bx, by = c.P(32, 11)
    for dx in range(-2, 3) if not c.small else range(-1, 2):
        c.px(bx + dx, by, SAGE[1])


K.render_pal(fn, 'th-kopje-keeper', 'Kopje Keeper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/th-kopje-keeper-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/th-kopje-keeper.png')
