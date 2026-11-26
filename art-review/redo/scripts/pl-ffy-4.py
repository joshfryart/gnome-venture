"""pl-ffy-4 Spare Wings: inner-TTTT, double. A firefly that IS the piece: square body (brown fuzzy thorax up top, glowing
yellow-green abdomen below with navy cave bands), W and E double tabs = two pairs of pale ice-blue wings (four spare wings),
N double tab = the fuzzy head bumps with antennae tipped in spark green, S double tab = the glowing lantern tail.
Colours: cave navy + spark green from cell 2-2, brown / ice-blue / lime of the picture's fireflies."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BROWN = K.ramp('#6e4a34')
FUZZ = K.ramp('#8a6046')
WING = ('#d8e6f6', '#8fa8d0', '#ffffff')
GLOW = K.ramp('#e6e070')
LIME = K.ramp('#8cc63a')
NAVY = '#24305e'
SPARK = '#b6e04a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(15, 19, 49, 51)
    tabN = K.knob('T', 'double', 32, 19, 0, -1, r=5.0 * k)
    tabS = K.knob('T', 'double', 32, 51, 0, 1, r=4.6 * k)
    tabW = K.knob('T', 'double', 15, 30, -1, 0, r=7.0 * k, nw=2.2)
    tabE = K.knob('T', 'double', 49, 30, 1, 0, r=7.0 * k, nw=2.2)
    # antennae with spark-green tips
    aw = 2.2 if not c.small else 2.8
    c.add(c.m(K.thick_path([(21, 20), (18, 12), (13, 8)], aw), K.thick_path([(43, 20), (46, 12), (51, 8)], aw)), BROWN)
    c.add(c.m(K.ell(13, 8, 2.6, 2.6), K.ell(51, 8, 2.6, 2.6)), LIME)
    # fuzzy brown body (head bumps on N)
    c.add(c.m(core, tabN), BROWN)
    # glowing lantern abdomen: lime glow ring, pale yellow lamp inside with dotted rows (as in the picture)
    abd = c.m(K.rect(15, 34, 49, 51), tabS)
    c.add(abd, LIME)
    lamp = c.m(K.ell(32, 44, 13, 8.5) if not c.small else K.ell(32, 44, 13.5, 8.8))
    c.add(lamp, GLOW)
    rows = (40, 44, 48) if not c.small else (41, 46)
    for ry in rows:
        y = c.P(0, ry)[1]
        for x in range(c.P(20, 0)[0], c.P(45, 0)[0]):
            if (x, y) in lamp and (x % 2 == 0 or c.small):
                c.px(x, y, '#b0a838')
    c.edge(abd, BROWN[1])
    # wings: neck brown (shoulder), lobes ice-blue, a vein between the two wings of each pair
    for t, x0, x1, vx0, vx1 in ((tabW, 0, 16, 1, 13), (tabE, 48, 64, 51, 63)):
        w = c.m(t, minus=(core,)) & c.m(K.rect(x0, 0, x1, 64))
        c.add(w, WING)
        c.line([(vx0, 30), (vx1, 30)], NAVY)
    c.add(c.m(K.rect(11, 24, 16, 36), K.rect(48, 24, 53, 36)) & c.m(tabW, tabE, core), BROWN)
    # sparks of the cave
    for sx, sy in ((5, 24), (59, 36)):
        c.px(*c.P(sx, sy), SPARK)
    # face on the fuzzy thorax
    c.eye(26, 25.5, disc=True)
    c.eye(38, 25.5, disc=True)
    c.smile(32, 29.5, K.CREAM)

R = '/home/user/gnome-venture/'
print(K.render_pal(fn, 'pl-ffy-4', 'Spare Wings', R + 'art-review/redo/out',
                   cellfile=R + 'art-review/redo/_src/pl-ffy-4-cell.png',
                   oldfile=R + 'game/assets/img/puzzles/pals/pl-ffy-4.png'))
