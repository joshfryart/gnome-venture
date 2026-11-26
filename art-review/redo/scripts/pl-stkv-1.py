# pl-stkv-1 "Pink Dusk Lullaby": a sleepy pink dusk cloud that is a corner-TB piece.
# Flat left + bottom sides; top: scalloped cloud puffs with a keyhole TAB that is the setting orange sun peeking up;
# right: keyhole BLANK. Purple upper-sky band on top puffs, pink body, orange sun-glow in the lower right (cell 9-2).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#f07c94')
PURP = K.ramp('#c068a8')
ORNG = K.ramp('#ff9c80')
SUN = K.ramp('#ffc048')


def fn(c):
    k = 1.15 if c.small else 1.0
    L, R, T, B = 8, 53, 28, 57
    core = K.rect(L, T, R - 3, B)
    pa, pb, pc = K.ell(18.5, T, 10.5, 10), K.ell(44, T + 1, 10, 9.5), K.ell(31, T - 5, 9.5, 10)
    pr = K.ell(R - 6, B - 6, 6.5, 6)      # rounded lower-right puff
    puffs = [pa, pb, pc, pr, K.rect(L, T, R, B - 6), K.rect(L, T, R - 6, B)]
    tab = K.knob('T', 'keyhole', 31, T - 13.5, 0, -1, r=6.0 * k, nw=2.2)
    blank = K.knob('B', 'keyhole', R, 40, 1, 0, r=4.4 * k)
    cutcorner = K.ell(R, B, 2.2, 2.2)
    body = c.m(core, *puffs, minus=(blank, K.rect(0, 0, L, 64)))
    c.add(body, PINK, stitch='#f7b0bf')
    # purple upper-sky puffs
    top = body & c.m(K.rect(0, 0, 64, T - 5))
    c.add(top, PURP)
    c.edge(top, PURP[1])
    # puff seams so the top reads as cloud lumps
    c.edge(body & c.m(pc, minus=(K.rect(0, T + 3, 64, 64),)), PINK[1])
    # the setting sun is the tab
    sun = c.m(tab, minus=(*puffs,))
    c.add(sun, SUN)
    # orange glow lower right
    glow = body & c.m(K.poly([(30, B + 1), (R + 1, B + 1), (R + 1, 44), (46, 46)]))
    c.add(glow, ORNG)
    # sleepy closed eyes (lullaby)
    for ex in (24, 40):
        cx, cy = c.P(ex, 36)
        if c.small:
            for dx, dy in ((-1, 0), (0, 1), (1, 1), (2, 0)):
                c.px(cx + dx, cy + dy, K.UMBER)
        else:
            for dx, dy in ((-3, -1), (-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0), (3, -1)):
                c.px(cx + dx, cy + dy, K.UMBER)
            c.px(cx - 3, cy + 1, K.UMBER2)
            c.px(cx + 3, cy + 1, K.UMBER2)
    c.blush(20, 41)
    c.blush(43, 41)
    # small o mouth: soft snore
    mx, my = c.P(32, 44)
    if c.small:
        c.px(mx, my, K.UMBER2)
    else:
        for dx, dy in ((0, 0), (1, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            c.px(mx + dx, my + dy, K.UMBER2)
    # Z floating on the body, purple
    zx, zy = c.P(14, 47)
    if not c.small:
        for p in [(0, 0), (1, 0), (2, 0), (3, 0), (2, 1), (1, 2), (0, 3), (1, 3), (2, 3), (3, 3)]:
            c.px(zx + p[0], zy + p[1], PURP[1])


K.render_pal(fn, 'pl-stkv-1', 'Pink Dusk Lullaby', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stkv-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stkv-1.png')
