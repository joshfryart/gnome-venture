# Termite Tower: a red termite mound that is an inner piece. Top = round TAB (the mound's spire tip),
# left / right / bottom = round BLANKS. Brick-coursed terracotta mud and a gold/green grass tuft from cell 0-6 of Thornacre.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MUD = K.ramp('#b85029')
MUDDK = K.ramp('#8a3a1f')
GRASS = K.ramp('#5aa83c')
GOLD = K.ramp('#cf8f2d')
STONE = K.ramp('#b9a189')


def fn(c):
    s = 1.15 if c.small else 1.0
    # tapered tower core: wider at the base, straight sides between knobs
    core = K.poly([(21, 15), (43, 15), (56, 59), (8, 59)])
    dome = K.ell(32, 16, 12, 5)
    tab = K.knob('T', 'round', 32, 12, 0, -1, r=4.6 * s, nw=2.8)
    bl = K.knob('B', 'round', 12.2, 46, -0.96, -0.28, r=3.2 * (1.05 if c.small else 1))
    br = K.knob('B', 'round', 51.8, 46, 0.96, -0.28, r=3.2 * (1.05 if c.small else 1))
    bb = K.knob('B', 'round', 32, 59, 0, 1, r=3.4 * s)
    blanks = (bl, br, bb)
    body = c.m(core, dome, tab, minus=blanks)
    c.add(body, MUD)
    tip = c.m(K.ell(32, 3.5 + 0.2, 3.0, 2.4))
    c.add(tip & body, MUDDK)
    # grass tufts at both bottom corners (cell's green blades and gold grass)
    lg = c.m(K.poly([(8, 59), (11, 50), (14, 54), (17, 47), (19, 54), (23, 51), (25, 59)]), minus=blanks)
    rg = c.m(K.poly([(39, 59), (42, 51), (45, 54), (47, 46), (50, 53), (53, 49), (56, 59)]), minus=blanks)
    # brick courses: offset dark dashes like the cell's mud bricks
    rows = range(19, 58, 4) if not c.small else range(20, 58, 5)
    seen = set()
    for i, y in enumerate(rows):
        Y = c.P(0, y)[1]
        if Y in seen:
            continue
        seen.add(Y)
        off = 0 if i % 2 == 0 else 4
        if 24 <= y <= 37 and not c.small or 25 <= y <= 36 and c.small:
            continue
        for x0 in range(6 + off, 60, 8):
            for X in range(int(x0 * c.k), int((x0 + 4.5) * c.k)):
                if (X, Y) in body and (X, Y - 1) in body and (X, Y) not in lg and (X, Y) not in rg:
                    c.px(X, Y, '#8a3a1f')
    c.add(lg, GRASS)
    c.add(rg, GOLD)
    # face on the calm middle
    c.eye(27, 29)
    c.eye(37, 29)
    c.smile(32, 33)
    c.blush(23, 32)
    c.blush(40, 32)


K.render_pal(fn, 'th-termite-tower', 'Termite Tower', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/th-termite-tower-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/th-termite-tower.png')
