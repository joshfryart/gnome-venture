# Nest Wobble (pl-cnd-5): a twiggy nest bowl riding a puffy peach cloud. inner-TTBB hook: N tab = a curled twig sprig, E tab = a wind-curl
# of cloud, W blank bites the nest wall, S blank bites the cloud. Colours from cell 3-6: dusk peach/pink cloud, sand-gold eggs, nest tan
# (the condor's nest in the picture), purple dusk shadow band.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

NEST = K.ramp('#be8e67')
TWIG = K.ramp('#8a5a3a')
CLOUD = ('#fadabc', '#e8aeaa', '#fff0d0')
PURP = ('#7a5684', '#56426e', '#9a82bc')
EGG = ('#ffd890', '#ecb98a', '#fff0d0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 15, 53, 55)
    tabN = K.knob('T', 'hook', 32, 15, 0, -1, r=5.4 * k)
    tabE = K.knob('T', 'hook', 53, 40, 1, 0, r=5.0 * k, flip=True)
    blankW = K.knob('B', 'hook', 10, 27, -1, 0, r=4.4 * k)
    blankS = K.knob('B', 'hook', 31, 55, 0, 1, r=4.4 * k)
    cuts = (blankW, blankS)
    body = c.m(core, tabN, tabE, minus=cuts)
    # cloud fills the whole piece; puff contours on the lower sides
    c.add(body, CLOUD)
    # soft puff seams in the cloud, curling up beside the bowl
    for pf in (K.ell(12, 40, 5.5, 4.5), K.ell(51, 40, 5.5, 4.5)):
        c.edge(c.m(pf, K.rect(0, 0, 64, 15)) & body, '#e8aeaa')
    # nest bowl sitting in the cloud
    bowl = K.poly([(9, 15), (55, 15), (55, 22), (52, 31), (46, 38), (38, 41.5), (26, 41.5), (17, 38), (11, 31), (9, 22)])
    nest = c.m(bowl, minus=cuts) & body
    c.add(nest, NEST)
    w = 1.6 if not c.small else 2.4
    for i in range(-6, 10):
        x0 = 6 + i * 6
        c.add(c.m(K.thick_path([(x0, 18), (x0 + 14, 42)], w)) & nest, TWIG)
    c.add(c.m(K.thick_path([(14, 36), (7.5, 39.5)], 2.6), K.thick_path([(50, 35), (56.5, 38)], 2.6)), TWIG)
    c.add(c.m(K.rect(9, 15, 55, 20.5), minus=cuts), TWIG)
    c.add(c.m(tabN, minus=(K.rect(0, 15, 64, 64),)) | (c.m(tabN) & c.m(K.rect(0, 13, 64, 16))), TWIG)
    # eggs peeking over the rim
    c.add(c.m(K.ell(43, 14.5, 5.2, 6.4), minus=(K.rect(0, 19.5, 64, 64),)), EGG)
    if not c.small:
        for (ex, ey) in ((41, 11), (45, 13), (42.5, 15.5)):
            c.px(*c.P(ex, ey), '#d89a6a')
    else:
        c.px(*c.P(44, 13), '#d89a6a')
    # stray twigs poking up from the rim
    c.add(c.m(K.thick_path([(14, 17), (11, 11.5)], 2.6), K.thick_path([(21, 17), (24, 12)], 2.6)), TWIG)
    # E wind curl (cloud)
    c.add(c.m(tabE, minus=(K.rect(0, 0, 53, 64),)), CLOUD)
    # purple dusk band at the cloud's base
    band = body & c.m(K.rect(0, 51, 64, 64))
    c.add(band, PURP)
    if not c.small:
        y = c.P(0, 51)[1]
        for x in range(c.n):
            if (x, y) in band and x % 3 == 0:
                c.px(x, y, '#f4c9b9')
    # face on the nest bowl
    c.eye(25, 27.5, disc=True)
    c.eye(38.5, 27.5, disc=True)
    c.smile(31.5, 32.5, K.UMBER)
    c.blush(20, 32)
    c.blush(42.5, 32)


K.render_pal(fn, 'pl-cnd-5', 'Nest Wobble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cnd-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cnd-5.png')
