import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Hat Brim: corner-TB round. A pirate gull bobbing in the sea. Flat W + S (sitting in the wave), N round tab = the dome of its
# navy tricorn hat, E round blank bites into the white gull body. Sea teal + island green from cell 4-4, gull white/grey and navy hat from the picture.
SEA = K.ramp('#4cbccc')
DEEP = K.ramp('#2a8ea8')
GULL = ('#eef0f0', '#b8c0c8', '#ffffff')
WING = K.ramp('#9aa4b4')
HAT = K.ramp('#34405a')
LEAF = K.ramp('#4a9a50')
BEAK = K.ramp('#f0a030')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 24, 53, 58)
    tabN = K.knob('T', 'round', 31, 24, 0, -1, r=6.2 * k, nw=3.6)
    blankE = K.knob('B', 'round', 53, 41, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, K.thick_path([(11.5, 20.5), (15, 26.5)], 5.4), K.thick_path([(50.5, 20.5), (47, 26.5)], 5.4), minus=(blankE,))
    c.add(body, GULL)
    # grey wings folded on the sides
    c.add(body & c.m(K.ell(12, 46, 6, 9), K.ell(50, 52, 6, 6)), WING)
    # tricorn hat: dome (the N tab) + a brim curving up into two rounded points at the top corners
    bw = 5.4 if not c.small else 6.0
    brim = c.m(K.thick_path([(11.5, 20.5), (15, 26.5), (23, 29), (31, 29.5), (39, 29), (47, 26.5), (50.5, 20.5)], bw))
    dome = c.m(tabN) & c.m(K.rect(0, 0, 64, 27))
    above = body & c.m(K.poly([(0, 0), (64, 0), (64, 19), (50.5, 20.5), (47, 26.5), (39, 29), (31, 29.5), (23, 29), (15, 26.5), (11.5, 20.5), (0, 19)]))
    c.add(brim | dome | above, HAT)
    c.add(c.m(tabN) & c.m(K.rect(0, 21.5, 64, 24.5)), LEAF)
    # skull badge on the dome
    sx, sy = c.P(31, 17)
    if not c.small:
        for dx in range(-2, 3):
            for dy in range(-2, 1):
                if abs(dx) == 2 and dy == -2:
                    continue
                c.px(sx + dx, sy + dy, K.CREAM)
        c.px(sx - 1, sy - 1, K.UMBER); c.px(sx + 1, sy - 1, K.UMBER)
        c.px(sx - 1, sy + 1, K.CREAM); c.px(sx + 1, sy + 1, K.CREAM)
    else:
        for dx in range(-1, 2):
            c.px(sx + dx, sy, K.CREAM)
        c.px(sx, sy - 1, K.CREAM); c.px(sx, sy + 1, K.CREAM)
    # the sea wave at the bottom (flat S side), with a white crest
    wave = c.m(lambda x, y: y > 50 + 1.6 * __import__('math').sin(x / 3.2))
    c.add(body & wave, SEA)
    c.add(body & c.m(K.rect(0, 55.5, 64, 64)), DEEP)
    crest = c.m(lambda x, y: 50 + 1.6 * __import__('math').sin(x / 3.2) < y < 51.6 + 1.6 * __import__('math').sin(x / 3.2))
    for p in crest & body:
        c.px(*p, '#ffffff')
    # beak (orange, pointing right toward the blank) + face
    c.add(body & c.m(K.poly([(27, 38), (39, 40.5), (27, 44)])), BEAK)
    rx, ry = c.P(29, 41.5)
    c.px(rx, ry, '#d84030')
    c.eye(22, 36)
    c.eye(33, 35.5)
    if not c.small:
        c.line([(27, 41), (36, 41)], BEAK[1])
    c.blush(19, 41)


K.render_pal(fn, 'pl-pgg-1', 'Hat Brim', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-pgg-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-pgg-1.png')
