import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Bell Bead: an icy box-jelly bell (inner-TBTB, hook knobs). Top tab = gold hanger hook, bottom tab = pink bead clapper,
# left/right = hook blanks. Colours from cell 6-2: pale ice blue jelly cube, umber-dark eye, pink tentacles, gold crown.
ICE = K.ramp('#bfe2f2')
ICE2 = K.ramp('#8cc4e4')
PINK = K.ramp('#e87aac')
GOLD = K.GOLD
CAP = K.ramp('#e4f4fa')


def fn(c):
    s = 1.15 if c.small else 1.0
    # bell: slightly narrower dome, flared lip, straight sides where the blanks sit
    core = K.poly([(14, 17), (50, 17), (51, 41), (55, 45), (55, 51), (9, 51), (9, 45), (13, 41)])
    dome = K.ell(32, 18, 17, 5)
    top = K.knob('T', 'hook', 32, 13, 0, -1, r=4.5 * s)
    bot = K.knob('T', 'round', 32, 51, 0, 1, r=4.3 * s, nw=2.2 * s)
    lb = K.knob('B', 'hook', 13.5, 31, -1, 0, r=3.4)
    rb = K.knob('B', 'hook', 50.5, 31, 1, 0, r=3.4, flip=True)
    body = c.m(core, dome, minus=(lb, rb))
    c.add(c.m(top), GOLD)
    c.add(body, ICE, stitch='#8cc4e4')
    # frosty cap band on the dome
    cap = c.m(K.ell(32, 17, 15, 4))
    c.add(cap, CAP)
    # lip band with pink tentacle fringe
    lip = c.m(K.rect(9, 45, 55, 51))
    c.add(lip, ICE2)
    c.edge(lip, '#6aa0c4')
    for x in (13, 19, 25, 39, 45, 51):
        c.add(c.m(K.thick_path([(x, 46), (x + 1, 48.5), (x, 51)], 2.8)), PINK)
    c.add(c.m(bot), PINK)
    # tiny gold crown points on top of the dome sides
    c.add(c.m(K.poly([(18, 15), (20.5, 10), (23, 15)]), K.poly([(41, 15), (43.5, 10), (46, 15)])), GOLD)
    # face
    ex = 4.5 if c.small else 5.5
    c.eye(32 - ex, 28, disc=True)
    c.eye(32 + ex - (1 if c.small else 0), 28, disc=True)
    c.smile(32, 35)
    c.blush(22, 34)
    c.blush(41, 34)


K.render_pal(fn, 'pl-bjq-3', 'Bell Bead', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bjq-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bjq-3.png')
