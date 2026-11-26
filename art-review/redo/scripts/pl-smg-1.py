"""pl-smg-1 Brass Hardhat: corner-BB, peg. A brass miner's hardhat that IS a corner piece: flat W side and flat S (the brim),
square peg blanks bite the crown (N) and the back (E). Lamp glows on the front; maroon strap and slate brim with a pale rail stripe
and rust sleeper from cell 5-4 (gallery wall maroon, slate floor, rail, rust tie)."""
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BRASS = K.ramp('#d8a030')
MAROON = K.ramp('#6e3a4c')
SLATE = K.ramp('#4a3e5c')
RUST = K.ramp('#8a4a30')
RAIL = K.ramp('#c8b8c8')
LAMP = ('#f8e070', '#e0a838', '#fff8c0')


def fn(c):
    k = 1.15 if c.small else 1.0
    dome = K.poly([(9, 50), (9, 24), (12, 16), (19, 10.5), (28, 8.5), (36, 8.5), (45, 10.5), (52, 16), (55, 24), (55, 50)])
    brim = K.rect(9, 45, 60, 55)
    bill = K.ell(56, 50, 6, 5)
    blankN = K.knob('B', 'peg', 32, 8.5, 0, -1, r=3.4 * k)
    blankE = K.knob('B', 'peg', 55, 35, 1, 0, r=3.4 * k)
    cut = (blankN, blankE)
    body = c.m(dome, minus=cut)
    c.add(body, BRASS, stitch=None if c.small else '#f5cf6a')
    # crown ridges either side of the notch
    c.add(c.m(K.rect(23, 9, 26, 22), K.rect(38, 9, 41, 29.5), minus=cut) & body, K.ramp('#c08a28'))
    # strap band (gallery maroon)
    c.add(c.m(K.rect(9, 29.5, 55, 34.5), minus=cut), MAROON)
    # brim: slate with rust sleeper stripe
    c.add(c.m(brim, bill, minus=cut), SLATE)
    c.add(c.m(K.rect(9, 50, 62, 52.5), minus=cut) & c.m(brim, bill), RUST)
    # lamp on the strap
    c.add(c.m(K.ell(20, 32, 7.5, 7.5)), BRASS)
    c.add(c.m(K.ell(20, 32, 5, 5)), LAMP)
    c.edge(c.m(K.ell(20, 32, 7.5, 7.5)), '#a06a18')
    lx, ly = c.P(18, 30)
    c.px(lx, ly, '#ffffff'); c.px(lx + 1, ly, '#ffffff'); c.px(lx, ly + 1, '#ffffff')
    # pale rail strand on the brim edge
    if not c.small:
        for x in range(c.P(10, 0)[0], c.P(58, 0)[0]):
            c.px(x, c.P(0, 46.5)[1], RAIL[2] if x % 3 else RAIL[0])
    # face on the brass below the strap? No: face on the right cheek of the dome
    c.eye(30.5, 40.5 if not c.small else 40)
    c.eye(40, 40.5 if not c.small else 40)
    c.blush(26.5, 43 if not c.small else 42.5)
    c.blush(43.5, 43 if not c.small else 42.5)


K.render_pal(fn, 'pl-smg-1', 'Brass Hardhat', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-1.png')
