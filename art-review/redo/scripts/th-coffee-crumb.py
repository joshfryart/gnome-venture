"""th-coffee-crumb "Coffee Crumb": a roasted coffee bean that is a corner piece (corner-TT, round knobs).
Flat W and S sides; tab N = the crown of its very large woven straw hat; tab E = a single roasted bean it holds out.
Colours from cell 7-7 of Thornacre: woven basket tan #d9a359 (hat weave), grass green #6b9a3a (hat band),
dark roast wood #794a1e (bean body), cream #f0ece0 (grains / glint), earth orange #cf8f2d (cheeks of the roast)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BEAN = K.ramp('#794a1e')
STRAW = K.ramp('#d9a359')
BAND = K.ramp('#6b9a3a')
EARTH = K.ramp('#cf8f2d')
WEAVE = '#b07a10'
CREASE = '#3e2410'
CREAM = '#f0ece0'


def fn(c):
    S = 1.15 if c.small else 1.0
    # core with a rounded lower-right corner (bean belly); W and S sides stay flat and straight
    corner = lambda x, y: x > 45 and y > 51 and (x - 45) ** 2 + (y - 51) ** 2 > 49
    core = lambda x, y: K.rect(8, 22, 52, 58)(x, y) and not corner(x, y)
    tabN = K.knob('T', 'round', 29, 20, 0, -1, r=8.0 * S, nw=6.5)
    tabE = K.knob('T', 'round', 52, 41, 1, 0, r=5.6 * S, nw=3.0)
    c.add(c.m(core), BEAN)
    held = c.m(tabE, minus=(K.rect(0, 0, 52.5, 64),))
    c.add(held, K.ramp('#8a5626'))
    # brim shadow across the top of the face
    c.add(c.m(K.rect(8, 27, 52, 29.5)), (BEAN[1], BEAN[1], BEAN[1]))
    # very large woven straw hat: the brim overhangs the head to the right and droops, the crown is the N tab
    brim = c.m(K.poly([(8, 20), (52, 19.5), (60, 23), (62, 28), (57, 27.5), (52, 26.5), (8, 27)]))
    crown = c.m(tabN, minus=(K.rect(0, 20, 64, 64),))
    c.add(brim | crown, STRAW)
    band = c.m(K.rect(0, 14.5, 64, 19.5)) & crown
    c.add(band, BAND)
    c.edge(brim, STRAW[1])
    hat = (brim | crown) - band
    for (x, y) in hat:
        if (x + y) % (4 if not c.small else 3) == 0 or (not c.small and (x - y) % 4 == 0):
            c.px(x, y, WEAVE)
    # glossy roast highlight along the upper-left of the bean, and the S crease
    hw = 1.6 if not c.small else 2.2
    for (x, y) in c.m(K.thick_path([(11, 52), (11, 36), (14, 31)], hw)):
        c.px(x, y, BEAN[2])
    w = 2.2 if not c.small else 2.8
    for (x, y) in c.m(K.thick_path([(41, 29), (44, 36), (40, 44), (43, 51), (40, 57.5)], w)):
        c.px(x, y, CREASE)
    for (x, y) in c.m(K.thick_path([(58.5, 35.5), (57, 40), (58.5, 44.5)], w)):
        c.px(x, y, CREASE)
    # face on the calm left half, under the brim
    c.eye(19, 37, disc=True)
    c.eye(31, 37, disc=True)
    c.smile(25, 44, CREAM)
    c.blush(14, 42)
    c.blush(35, 42)
    # roast steam/crumbs in earth orange at the feet (64 only)
    if not c.small:
        for (x, y) in ((15, 52), (22, 54), (31, 52), (35, 55)):
            c.px(*c.P(x, y), EARTH[0])


if __name__ == '__main__':
    print(K.render_pal(fn, 'th-coffee-crumb', 'Coffee Crumb', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/th-coffee-crumb-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/th-coffee-crumb.png'))
