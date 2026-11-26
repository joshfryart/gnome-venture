import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, UMBER, UMBER2

# Belfry Ding, corner-TT round: a lemon-grove belfry tower that IS a corner piece. Flat W (wall) and S (stone footing).
# N round tab = terracotta roof finial ball, E round tab = a golden lemon hanging from the eave. The open belfry arch shows
# the pale sky of cell 4-1 with a lemon-shaped bell inside (the mouth). Cream wall, terracotta roof, lemon gold.
WALL = K.ramp('#ecd8ac')
ROOF = K.ramp('#c8603a')
LEMON = K.ramp('#f2c832')
SKY = K.ramp('#a8c8d8')
STONE = K.ramp('#b8b4a4')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 20, 51, 57)
    tabN = knob('T', 'round', 31, 20, 0, -1, r=4.8 * k)
    tabE = knob('T', 'round', 51, 40, 1, 0, r=4.8 * k)
    body = c.m(core, tabN, tabE)
    c.add(c.m(core), WALL, stitch='#d4bc8a')
    # roof: a terracotta cap across the top with the finial (N tab)
    roof = c.m(rect(11, 20, 51, 27))
    c.add(roof, ROOF)
    c.add(c.m(tabN, minus=(core,)), ROOF)
    if not c.small:
        for x in range(c.P(12, 0)[0], c.P(51, 0)[0]):
            if x % 3 == 0:
                for y in range(c.P(0, 21)[1], c.P(0, 26)[1]):
                    c.px(x, y, ROOF[1])
    # eave line under the roof
    c.edge(roof, ROOF[1])
    # E tab: hanging lemon with a little green leaf
    c.add(c.m(tabE, minus=(core,)), LEMON)
    lx, ly = c.P(57.5, 37)
    for dx, dy in ((0, 0), (1, 0), (1, -1), (2, -1)):
        c.px(lx + dx, ly + dy, '#4a8a3a')
    # stone footing (flat S)
    c.add(c.m(rect(11, 53, 51, 57)), STONE)
    # belfry arch: sky blue opening with the lemon bell (the mouth)
    arch = c.m(rect(22, 43, 40, 53), ell(31, 43, 9, 6.5))
    c.add(arch, SKY)
    c.edge(arch, UMBER2)
    c.add(c.m(ell(31, 48, 5.4, 4.6)), LEMON)
    c.add(c.m(rect(30, 38.5, 32.2, 44)), ('#7a4a1f', '#5a3410', '#9a6a3a'))   # bell yoke
    bx, by = c.P(31, 52.2)
    c.px(bx, by, '#b07a10')
    # face on the wall above the arch
    c.eye(21.5, 32.5, disc=True)
    c.eye(40.5, 32.5, disc=True)
    c.blush(17, 37)
    c.blush(44, 37)


K.render_pal(fn, 'pl-lemn-1', 'Belfry Ding', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-1.png')
