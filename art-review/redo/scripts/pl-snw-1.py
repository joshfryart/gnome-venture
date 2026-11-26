# Frost Nibble: a twin snow peak that is a corner piece. Flat left and bottom sides; hook blanks on the top (the col between the
# two peaks) and the right (bitten into the rock flank). Motif from snowcrown cell 5-1: cream snowcap with lavender shade,
# mauve-grey rock with deep plum streaks, the purple ridge line; a face in the snow with icicle teeth (it nibbles).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SNOW = ('#fbf7ea', '#c9cbe0', '#ffffff')
SHADE = K.ramp('#a3aacb')
ROCK = K.ramp('#a6979c')
PLUM = K.ramp('#3f3550')
GRASS = K.ramp('#5aa83a')


def fn(c):
    s = 1.15 if c.small else 1.0
    # gabled top: two peaks with the col between them
    core = K.poly([(7, 57), (7, 20), (17, 5), (25, 14), (39, 14), (47, 5), (57, 20), (57, 57)])
    bT = K.knob('B', 'hook', 32, 14, 0, -1, r=4.0 * s)
    bR = K.knob('B', 'hook', 57, 41, 1, 0, r=4.5 * s, flip=True)
    body = c.m(core, minus=(bT, bR))
    c.add(body, ROCK, stitch=None)
    # plum streaks down the rock (the picture's dark gullies)
    streaks = c.m(K.poly([(14, 34), (19, 34), (17, 57), (11, 57)]),
                  K.poly([(41, 36), (46, 36), (49, 57), (43, 57)])) & body
    c.add(streaks, PLUM)
    # snowcap: jagged lower edge with drips
    cap = c.m(K.poly([(7, 20), (17, 5), (25, 14), (39, 14), (47, 5), (57, 20), (57, 33), (52, 37), (47, 33), (40, 41), (33, 36),
                      (26, 42), (20, 36), (14, 40), (7, 34)])) & body
    c.add(cap, SNOW)
    # lavender shade on the right faces of each peak
    sh = c.m(K.poly([(17, 5), (24, 13), (19, 22), (13, 24)]), K.poly([(47, 5), (57, 20), (57, 32), (52, 35), (50, 18)])) & cap
    c.add(sh, SHADE)
    # grass strip along the flat bottom
    c.add(c.m(K.rect(7, 53, 57, 57)) & body, GRASS)
    # face in the snow
    c.eye(24, 26)
    c.eye(40, 26)
    c.blush(19, 31) if not c.small else None
    c.blush(45, 31) if not c.small else None
    # mouth with icicle teeth
    mx, my = c.P(32, 32)
    if not c.small:
        for dx in range(-3, 4):
            c.px(mx + dx, my, K.UMBER)
        for dx in (-2, 1):
            c.px(mx + dx, my + 1, SHADE[1]); c.px(mx + dx + 1, my + 1, SHADE[1]); c.px(mx + dx, my + 2, SHADE[1])
        c.px(mx - 4, my - 1, K.UMBER); c.px(mx + 4, my - 1, K.UMBER)
    else:
        for dx in range(-2, 3):
            c.px(mx + dx, my, K.UMBER)
        c.px(mx - 3, my - 1, K.UMBER); c.px(mx + 3, my - 1, K.UMBER)
        c.px(mx - 1, my + 1, SHADE[1]); c.px(mx + 1, my + 1, SHADE[1])


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-snw-1', 'Frost Nibble', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-1.png'))
