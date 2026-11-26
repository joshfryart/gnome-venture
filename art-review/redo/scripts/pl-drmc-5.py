# pl-drmc-5 "Firelit Circle": a campfire sprite. inner-BBBB, round knobs: the N blank is the split between two flame tongues,
# the S blank is the gap between two crossed logs, W/E blanks bite the flame's flanks. Colours from cell 6-6 (the bonfire):
# deep red #d8383c, orange #ff7a30, gold #ffb83c, pale core #fff0a0, plum #7a2438 embers.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

RED = K.ramp('#d8383c')
ORG = K.ramp('#ff7a30')
GLD = K.ramp('#ffb83c')
PALE = ('#fff0a0', '#f0c860', '#fffad8')
LOG = K.ramp('#8a5230')
EMB = '#7a2438'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 16, 52, 54)
    # a row of wavy flame licks, uneven heights, tips curling: a fire, not two ears
    tongL = K.poly([(12, 22), (12, 14), (13, 9), (11, 4), (16, 7), (18, 11), (20, 7), (23, 2), (24, 8), (26, 13), (27, 17), (12, 17)])
    tongR = K.poly([(52, 22), (52, 15), (53, 10), (51, 6), (48, 9), (46, 4), (44, 0.5), (41, 6), (40, 11), (37, 17), (52, 17)])
    bN = K.knob('B', 'round', 32, 16, 0, -1, r=4.6 * k)
    bS = K.knob('B', 'round', 32, 54, 0, 1, r=4.2 * k)
    bW = K.knob('B', 'round', 12, 30, -1, 0, r=4.2 * k)
    bE = K.knob('B', 'round', 52, 30, 1, 0, r=4.2 * k)
    blanks = (bN, bS, bW, bE)
    body = c.m(core, tongL, tongR, minus=blanks)
    c.add(body, RED)
    # orange layer: flame shape inset, with its own licks
    org = K.poly([(16, 50), (16, 22), (15, 13), (19, 16), (23, 8), (25, 16), (27, 22), (29, 24), (35, 24), (38, 20), (41, 12), (44, 6),
                  (46, 13), (50, 11), (48, 22), (48, 50)])
    c.add(c.m(org, minus=blanks) & body, ORG)
    # gold inner flame
    gld = K.poly([(20, 48), (20, 32), (22, 24), (25, 28), (28, 26), (32, 22), (36, 26), (39, 28), (42, 24), (44, 32), (44, 48)])
    c.add(c.m(gld, minus=blanks) & body, GLD)
    # pale hot heart where the face sits
    c.add(c.m(K.ell(32, 41, 9, 7.5), minus=blanks) & body, PALE)
    # logs: two crossed logs across the base, the S blank between them
    logL = K.thick_path([(11, 54), (29, 45)], 7.6)
    logR = K.thick_path([(53, 54), (35, 45)], 7.6)
    lm = c.m(logL, logR, minus=blanks) & body
    c.add(lm, LOG)
    c.edge(lm, LOG[1])
    # log end rings
    for (x, y) in ((14, 52.5), (50, 52.5)):
        c.px(*c.P(x, y), K.WOOD[2])
    # ember dots
    for (x, y) in ((14, 44), (50, 44)):
        px, py = c.P(x, y)
        c.px(px, py, EMB)
        if not c.small:
            c.px(px + 1, py, EMB)
    # face
    c.eye(27.5, 38)
    c.eye(36.5, 38)
    c.smile(32, 42.5, wide=not c.small)
    c.blush(24.5, 41.5)
    c.blush(39, 41.5)


K.render_pal(fn, 'pl-drmc-5', 'Firelit Circle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drmc-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drmc-5.png')
