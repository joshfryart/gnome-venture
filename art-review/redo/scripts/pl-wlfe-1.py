"""pl-wlfe-1 Upturned Pagoda Eaves: corner-TB, keyhole.
A one-tier pagoda: plum roof with upturned eave tips on top, coral lantern-lit wall with the face, indigo night plinth.
Flat W and S. N tab = keyhole finial whose round head is the cream moon (cell 1-1). E blank = keyhole cut into the wall."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOF = K.ramp('#7a3a5a')
ROOFL = ('#a36a7b', '#7a3a5a', '#c08a98')
WALL = K.ramp('#c8584a')
GLOW = K.ramp('#ffd070')
NIGHT = K.ramp('#3a2a72')
MOON = ('#fff0c0', '#d0c090', '#fffbe8')
SRC = '/home/user/gnome-venture/art-review/redo/_src/'


def fn(c):
    k = 1.15 if c.small else 1.0
    roof = K.poly([(7.5, 14.5), (10, 18), (21, 12.5), (39, 12.5), (50, 18), (52.5, 14.5),
                   (53, 19.5), (50, 24.5), (40, 26.5), (20, 26.5), (10, 24.5), (7, 19.5)])
    wall = K.rect(10, 23, 50, 55)
    tabN = K.knob('T', 'keyhole', 30, 12.6, 0, -1, r=5.0 * k)
    blankE = K.knob('B', 'keyhole', 50, 38, 1, 0, r=4.2 * k)
    body = c.m(roof, wall, minus=(blankE,))
    c.add(body, WALL, stitch=None if c.small else '#e88a70')
    # night plinth
    c.add(body & c.m(K.rect(0, 50, 64, 64)), NIGHT)
    # roof
    rm = c.m(roof)
    c.add(rm, ROOF)
    c.add(rm & c.m(lambda x, y: y > 26.5 - 2.2 - 2.2 * ((x - 30) / 22) ** 2 - (0.6 if c.small else 0)), ROOFL)
    # tile lines
    if not c.small:
        for tx in range(18, 44, 4):
            c.line([(tx, 15.5), (tx + (tx - 30) * 0.15, 21.5)], ROOF[1])
    c.edge(rm, ROOF[1])
    # finial: gold stem + cream moon head
    tm = c.m(tabN, minus=(roof,))
    c.add(tm, GLOW)
    head = c.m(K.ell(30, 12.6 - (5.0 * k + 1.6 + 0.5), 4.0 * k + 0.1, 4.0 * k + 0.1))
    c.add(head & tm, MOON)
    # glowing windows on the wall
    win1 = c.m(K.rect(14, 41, 20, 49))
    win2 = c.m(K.rect(28, 41, 34, 49))
    for w in (win1, win2):
        c.add(w, GLOW)
        c.edge(w, WALL[1])
    if not c.small:
        c.line([(17, 41), (17, 48.5)], '#c8902a')
        c.line([(31, 41), (31, 48.5)], '#c8902a')
    # stars on the plinth
    for sx in (14, 24, 36, 45):
        x, y = c.P(sx, 52.5)
        c.px(x, y, MOON[0])
    # face
    c.eye(19.5, 33)
    c.eye(30.5, 33)
    c.smile(25, 36.5, wide=not c.small)
    c.blush(15, 36)
    c.blush(34, 36)


K.render_pal(fn, 'pl-wlfe-1', 'Upturned Pagoda Eaves', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=SRC + 'pl-wlfe-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-1.png')
