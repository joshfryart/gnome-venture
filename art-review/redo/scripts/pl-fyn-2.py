import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

R = '/home/user/gnome-venture/'
GREEN = K.ramp('#4a8a2a')
LEAF = K.ramp('#6aa832')
ASH = K.ramp('#8a8078')
EMBER = K.ramp('#e0481e')
FLAME = K.ramp('#f08a20')
YEL = '#f8d050'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 20, 54, 58)
    top = K.knob('T', 'peg', 32, 20, 0, -1, r=4.5 * k)
    lb = K.knob('B', 'peg', 10, 33, -1, 0, r=3.4 * k)
    rb = K.knob('B', 'peg', 54, 33, 1, 0, r=3.4 * k)
    # two leaves sprouting from the top corners (reach the outline)
    lleaf = K.poly([(30, 22), (20, 11), (5, 10), (4, 17), (12, 23)])
    rleaf = K.poly([(34, 22), (44, 11), (59, 10), (60, 17), (52, 23)])
    body = c.m(core, top, minus=(lb, rb))
    c.add(body, GREEN, stitch=LEAF[2])
    c.add(c.m(K.ell(32, 40, 13, 7)) & body, LEAF)
    c.add(c.m(lleaf, rleaf, minus=(lb, rb)), LEAF)
    c.edge(c.m(lleaf, rleaf), GREEN[1])
    # ash mound at the bottom with embers and little flames
    ash = c.m(K.rect(10, 46, 54, 58), K.ell(32, 46, 24, 5), minus=(lb, rb))
    ash = ash & body
    c.add(ash, ASH)
    c.edge(ash, ASH[1])
    for fx in (17, 32, 47):
        fl = c.m(K.poly([(fx - 5, 58), (fx + 5, 58), (fx + 4, 51), (fx + 1, 54), (fx, 45), (fx - 2, 52), (fx - 4, 49)]))
        c.add(fl & body, EMBER)
        c.add(c.m(K.ell(fx, 55, 2.6, 2.6)) & body, (YEL, FLAME[0], YEL))
    # leaf veins
    if not c.small:
        c.line([(28, 20), (9, 13)], GREEN[1])
        c.line([(36, 20), (55, 13)], GREEN[1])
    # face
    c.eye(25, 32)
    c.eye(39, 32)
    c.smile(32, 38)
    c.blush(20, 37)
    c.blush(43, 37)


K.render_pal(fn, 'pl-fyn-2', 'Ash Sprout', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-fyn-2-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-fyn-2.png')
