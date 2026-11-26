import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Tide Notches: a wooden tide pole standing in the sea-cave water, merged into an inner piece with four double-knob tabs.
# Top tab = the pole's cap, bottom tab = the pole's foot under water, side tabs = cave-rock stones it is wedged between.
# Body: weathered boat-wood post with 4 cream notch marks; lower third is navy night sea with a moonlit crest. Colours from cell 4-5.

WOOD = K.ramp('#b8814a')
ROCK = K.ramp('#5a7594')
SEA = K.ramp('#1f4468')
CREST = '#8fb0d0'
NOTCH = '#f2e4c0'
MAROON = '#5a2a2a'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.5 * k
    x0, y0, x1, y1 = 14, 14, 50, 50
    core = K.rect(x0, y0, x1, y1)
    top = K.knob('T', 'double', 32, y0, 0, -1, r=r)
    bot = K.knob('T', 'double', 32, y1, 0, 1, r=r)
    lft = K.knob('T', 'double', x0, 32, -1, 0, r=r)
    rgt = K.knob('T', 'double', x1, 32, 1, 0, r=r)
    notches = [K.poly([(x - 0.5, y - 2.8), (x + 4.4, y), (x - 0.5, y + 2.8)]) for x, y in ((x0, 18.5), (x0, 25.5))] + \
              [K.poly([(x + 0.5, y - 2.8), (x - 4.4, y), (x + 0.5, y + 2.8)]) for x, y in ((x1, 18.5), (x1, 25.5))]
    wood = c.m(core, top, minus=notches)
    c.add(wood, WOOD, stitch=None)
    # side stones (cave rock)
    c.add(c.m(lft, K.rect(x0, 26, x0 + 3, 38)), ROCK)
    c.add(c.m(rgt, K.rect(x1 - 3, 26, x1, 38)), ROCK)
    # sea: wavy top
    import math
    wl = 40

    def sea(x, y):
        return y > wl + 1.6 * math.sin((x - 14) / 3.2)
    seam = c.m(lambda x, y: (core(x, y) or bot(x, y)) and sea(x, y))
    c.add(seam, SEA)
    # crest: line along wave top
    for xi in range(c.n):
        X = (xi + 0.5) / c.k
        if x0 <= X < x1:
            yy = wl + 1.6 * math.sin((X - 14) / 3.2)
            py = int(math.ceil(yy * c.k - 0.5))
            c.px(xi, py, CREST)
    # moon glint ripples on water
    if not c.small:
        c.line([(20, 46), (24, 46)], CREST)
        c.line([(36, 47), (42, 47)], CREST)
    else:
        c.line([(36, 47), (42, 47)], CREST)
    # plank grain
    if not c.small:
        c.line([(24.5, 15), (24.5, 22)], WOOD[1])
        c.line([(39.5, 31), (39.5, 38)], WOOD[1])
    # tide gauge: red / cream bands down the pole, from the cap to under the water line
    gx0, gx1 = 28.5, 35.5
    red = c.m(lambda x, y: gx0 <= x < gx1 and 4 <= y < wl + 1.6 * math.sin((x - 14) / 3.2) and int((y - 4) // 4.2) % 2 == 0)
    cream = c.m(lambda x, y: gx0 <= x < gx1 and 4 <= y < wl + 1.6 * math.sin((x - 14) / 3.2) and int((y - 4) // 4.2) % 2 == 1)
    for p in red:
        c.over[p] = '#b83a2e'
    for p in cream:
        c.over[p] = NOTCH
    # face: eyes either side of the gauge
    c.eye(22, 27)
    c.eye(42.5, 27)
    c.smile(32.5, 31, wide=True)
    c.blush(21, 32)
    c.blush(43, 32)


K.render_pal(fn, 'pl-scg-4', 'Tide Notches', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-4.png')
