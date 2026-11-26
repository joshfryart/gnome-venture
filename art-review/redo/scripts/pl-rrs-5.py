import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Monolith Hidey, inner-TTBB round: a red-rock monolith that IS the piece. N tab = the rock's domed crown, E tab = a boulder bulge,
# W + S blanks bite into the rock. A dark cave arch in the face where a grey kangaroo peeks out (ears + felt eyes).
# Cell 5-4 colours: rock coral #dc7061 / maroon strata #c8585a / glow #f08868, sand #fcc880; dot songlines in cream.
ROCK = K.ramp('#dc7061')
STRATA = K.ramp('#c8585a')
GLOW = K.ramp('#f08868')
SAND = K.ramp('#fcc880')
CAVE = ('#5a2220', '#3e1818', '#7a3028')
ROO = K.ramp('#8c8690')
DOT = '#f8e0b0'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(10, 16, 52, 54)(x, y) and not (
        (x < 22 and y < 28 and (x - 22) ** 2 + (y - 28) ** 2 > 144) or
        (x > 40 and y < 28 and (x - 40) ** 2 + (y - 28) ** 2 > 144))
    tabN = K.knob('T', 'round', 31, 16, 0, -1, r=5.6 * k)
    tabE = K.knob('T', 'round', 52, 33, 1, 0, r=5.0 * k)
    blankW = K.knob('B', 'round', 10, 36, -1, 0, r=4.6 * k)
    blankS = K.knob('B', 'round', 33, 54, 0, 1, r=4.6 * k)
    body = c.m(core, tabN, tabE, minus=(blankW, blankS))
    c.add(body, ROCK, stitch=None)
    # maroon strata bands (wavy, like the cell's lower rock)
    st = c.m(lambda x, y: 43 + 1.5 * ((x // 6) % 2) < y < 49) & body
    c.add(st, STRATA)
    # vertical gullies (the monolith's rain streaks)
    w = 2.6 if c.small else 1.6
    for gx, y0 in ((15, 26), (20, 20), (42, 20), (47, 26)):
        c.add(c.m(K.thick_path([(gx, y0), (gx + 0.8, 34), (gx, 44)], w)) & body, STRATA)
    # glow on the crown (sunlit top, cell's light coral)
    c.add(c.m(K.ell(28, 15, 11, 5)) & body, GLOW)
    # sand foot
    c.add(c.m(K.rect(0, 50, 64, 64)) & body, SAND)
    # cave arch with the kangaroo peeking
    cave = c.m(lambda x, y: K.ell(30, 36, 9, 10)(x, y) and y < 42 or K.rect(21, 34, 39, 45)(x, y))
    c.add(cave, CAVE)
    ears = c.m(K.poly([(23, 37), (23.5, 26.5), (27.5, 35)]), K.poly([(32.5, 35), (36.5, 26.5), (37, 37)]))
    c.add(ears & cave, ROO)
    head = c.m(K.ell(30, 40, 6.5, 5)) & cave
    c.add(head, ROO)
    c.add(c.m(K.ell(30, 43, 3.4, 2.2)) & cave, K.ramp('#c8c2c4'))
    c.px(*c.P(30, 42.2), '#3a2a2a')
    c.edge(cave, CAVE[1])
    c.eye(27.5, 39.5, disc=True)
    c.eye(32.5, 39.5, disc=True)
    # dotted songline circles on the rock flanks
    dots = [] if c.small else \
        [(52, 40), (55, 42), (52, 44), (49, 42), (13, 36), (15, 38)]
    for (x, y) in dots:
        c.px(*c.P(x, y), DOT)
    if c.small:
        for (x, y) in []:
            c.px(*c.P(x, y), DOT)

R = '/home/user/gnome-venture/'
print(K.render_pal(fn, 'pl-rrs-5', 'Monolith Hidey', R + 'art-review/redo/out',
                   cellfile=R + 'art-review/redo/_src/pl-rrs-5-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-rrs-5.png'))
