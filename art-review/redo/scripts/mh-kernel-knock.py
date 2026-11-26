# Kernel Knock (mh-kernel-knock), inner-TBBB, round knobs.
# Concept: a golden maize kernel that is an inner piece: round TAB on top is the kernel popping into a cream popcorn puff,
# round BLANKS west, east and south bite into the kernel body; chamfered lower corners give the kernel's tapered base.
# Motif and colours from Maizehollow cell 9-5 (the gnome in the corn rows): maize gold body, teal husk leaf (the gnome's hat),
# red pedicel base band (the gnome's coat).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MAIZE = K.ramp('#f0b828')
CROWN = K.ramp('#f8dc78')
POP = ('#f6ecd0', '#d8c49a', '#ffffff')
TEALH = K.ramp('#2f9a8e')
RED = K.ramp('#c83a2a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(10, 21), (54, 21), (54, 38), (47, 58), (17, 58), (10, 38)])
    tabN = K.knob('T', 'round', 32, 22, 0, -1, r=6.2 * k, nw=3.4)
    blW = K.knob('B', 'round', 10, 33, -1, 0, r=3.7 * k)
    blE = K.knob('B', 'round', 54, 33, 1, 0, r=3.7 * k)
    blS = K.knob('B', 'round', 32, 58, 0, 1, r=3.4 * k)
    blanks = (blW, blE, blS)
    body = c.m(core, minus=blanks)
    c.add(body, MAIZE)
    # pale crown at the top of the kernel (where it splits open)
    c.add(body & c.m(K.rect(0, 22, 64, 27)), CROWN)
    # popcorn puff tab: the round knob plus two small side lobes
    puff = c.m(tabN, K.ell(25, 14, 4.8, 4.2), K.ell(39, 14, 4.8, 4.2), K.ell(32, 7.5, 4.6, 3.6), minus=(core,))
    c.add(puff | (c.m(tabN) & c.m(K.rect(0, 20, 64, 23))), POP)
    if not c.small:
        c.line([(29, 9), (31, 11), (33, 10)], POP[1])
        c.line([(24, 14), (26, 15)], POP[1])
        c.line([(38, 15), (40, 14)], POP[1])
    # crack zigzag between puff and kernel
    zz = [(22, 24), (25, 22.5), (28, 24.5), (31, 22.5), (34, 24.5), (37, 22.5), (40, 24.5), (43, 22.5)]
    c.line(zz, MAIZE[1])
    # red-orange blush of the kernel toward its tip (the gnome's coat red, faded into the gold)
    c.add(body & c.m(K.poly([(10, 46), (54, 46), (54, 64), (10, 64)])), K.ramp('#e07a24'))
    # tip cap (pedicel) either side of the south blank
    c.add(body & c.m(K.rect(0, 54.5, 64, 64)), RED)
    # long vertical shine on the kernel's upper-left (glossy pericarp)
    c.add(body & c.m(K.thick_path([(15.5, 30), (15.5, 41)], 2.6 if not c.small else 3.0)), CROWN)
    # teal husk leaf curling up the lower-left side
    leaf = c.m(K.poly([(44, 59), (50, 52), (55, 44), (60, 37), (59.5, 45), (56, 53), (50, 59)]), minus=blanks + (core,))
    c.add(leaf, TEALH)
    c.line([(51, 56), (55, 49), (58.5, 41)], TEALH[2] if not c.small else TEALH[1])
    # face
    c.eye(26, 36)
    c.eye(38, 36)
    c.smile(32, 42, wide=True)
    c.blush(21.5, 40)
    c.blush(41.5, 40)


K.render_pal(fn, 'mh-kernel-knock', 'Kernel Knock', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mh-kernel-knock-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mh-kernel-knock.png')
