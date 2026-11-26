# pl-skyc-6 "Trailpack Cubbie": a brown bear cub whose square body is the piece. Round ears on top,
# red trail pack = right keyhole tab, keyhole blank cut into the left flank, floating sky-island rock ledge
# (mauve, green vines) as the bottom with its point as the lower keyhole tab. Pink sky from cell 0-4 for ears/blush.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#8a5a36')
MUZ = K.ramp('#d8b48a')
PACK = K.ramp('#c8402a')
ROCK = K.ramp('#6a4c60')
ROCKT = K.ramp('#a89078')
VINE = K.ramp('#3f8a4a')
PINK = '#f0a8a8'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(12, 14, 49, 50)
    ears = (K.ell(17, 14, 7, 7), K.ell(43, 14, 7, 7))
    pack_tab = K.knob('T', 'keyhole', 51, 33, 1, 0, r=5.2 * s, nw=3.2 * s)
    blank = K.knob('B', 'keyhole', 12, 39, -1, 0, r=4.2 * s, nw=2.4 * s)
    rock = K.poly([(9, 48), (51, 48), (49, 54), (40, 57), (20, 57), (11, 54)])
    rock_tab = K.knob('T', 'keyhole', 30, 57, 0, 1, r=3.8 * s, nw=2.4 * s)
    body = c.m(core, *ears, minus=(blank,))
    c.add(body, FUR, stitch=FUR[1])
    inner = c.m(K.ell(17, 14, 3.4, 3.4), K.ell(43, 14, 3.4, 3.4))
    c.add(inner, (PINK, '#c88080', '#f8d0d0'))
    # belly/arms: a darker paw line
    pk = c.m(pack_tab, K.rect(45, 22, 52, 44))
    c.add(pk, PACK)
    c.edge(pk, PACK[1])
    flap = c.m(K.rect(45, 22, 52, 27))
    c.add(flap, K.ramp('#e0b040'))
    # rock ledge + top grass
    rk = c.m(rock, rock_tab, minus=(blank,))
    c.add(rk, ROCK)
    grass = c.m(K.rect(9, 48, 51, 50.5))
    c.add(grass, VINE)
    vines = c.m(K.thick_path([(16, 50), (16, 58)], 2.8), K.thick_path([(44, 50), (44, 58)], 2.8))
    c.add(vines, VINE)
    tan = c.m(K.poly([(22, 52), (30, 51), (27, 55), (21, 55)]))
    c.add(tan, ROCKT)
    # face
    muz = c.m(K.ell(31, 37, 7.5, 5.5))
    c.add(muz, MUZ)
    c.eye(25, 29)
    c.eye(37, 29)
    nx, ny = c.P(31, 34.5)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx, ny, K.UMBER)
    c.px(nx + (0 if not c.small else 0), ny + 1, K.UMBER)
    c.smile(31, 38)
    c.blush(21, 34)
    c.blush(40, 34)


K.render_pal(fn, 'pl-skyc-6', 'Trailpack Cubbie', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-6.png')
