import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Inner-TTTT keyhole: a lavender-grey pond boulder in a blue pool band. N tab = mossy tuft with pink flowers,
# W/E tabs = little pebble islets, S tab = a water splash. Rock and water colours from cell 4-7.
ROCK = ('#9a8eb0', '#6a5f80', '#c8bcd8')
ROCK2 = ('#7e7296', '#5a5070', '#a89cc0')
WATER = ('#3a8ac8', '#2a66a0', '#8ac4e8')
MOSS = K.ramp('#5aa03a')
PINK = '#e8609a'
FOAM = '#e8f4fc'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = (K.rect(12, 18, 52, 52),)
    tabN = K.knob('T', 'keyhole', 32, 18, 0, -1, r=5.0 * k)
    tabW = K.knob('T', 'keyhole', 12, 38, -1, 0, r=4.6 * k)
    tabE = K.knob('T', 'keyhole', 52, 38, 1, 0, r=4.6 * k)
    tabS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=4.6 * k)
    roundcut = (lambda x, y: y < 26 and (x < 20 or x >= 44) and not (K.ell(20, 26, 8, 8)(x, y) or K.ell(44, 26, 8, 8)(x, y)),)
    body = c.m(*core, tabN, tabW, tabE, tabS, minus=roundcut)
    # water fills everything first
    c.add(body, WATER)
    # the boulder: square-ish dome over the top of the core, down to the waterline
    wl = 40
    rock = c.m(K.rect(12, 26, 52, wl), K.rect(20, 18, 44, wl), K.ell(20, 26, 8, 8), K.ell(44, 26, 8, 8))
    c.add(rock, ROCK)
    c.add(rock & c.m(K.ell(27, 24, 11, 4.5)), ('#b4a8c8', '#9a8eb0', '#d4cae0'))
    # darker under-ledge of the rock at the waterline
    c.add(rock & c.m(K.rect(0, wl - 4, 64, wl)), ROCK2)
    # pebble islets in the W/E tabs
    for sx, nx in ((12, -1), (52, 1)):
        peb = c.m(K.ell(sx + nx * 8.5, 37.5, 5.2 * k, 4.0 * k)) & body & c.m(K.rect(0, 0, 64, 38.5))
        c.add(peb, ROCK)
        x0 = c.P(sx + nx * 13, 0)[0]; x1 = c.P(sx + nx * 4, 0)[0]
        c.line([(sx + nx * 13, 39), (sx + nx * 4, 39)], FOAM)
    # moss tuft on top (N tab) with pink flowers
    moss = c.m(tabN, minus=(K.rect(0, 18, 64, 64),)) | (c.m(K.ell(32, 19.5, 7, 2.6)) & rock)
    c.add(moss, MOSS)
    for fx, fy in ((29, 9), (35, 10.5), (32, 6.5)) if not c.small else ((29.5, 9), (35, 10)):
        x, y = c.P(fx, fy)
        c.px(x, y, PINK); c.px(x + 1, y, PINK)
        if not c.small:
            c.px(x, y - 1, '#f8a8c8'); c.px(x + 1, y + 1, '#b83a70')
    # water ripples and splash
    if not c.small:
        c.line([(15, 44.5), (22, 44.5)], WATER[2]); c.line([(42, 44.5), (49, 44.5)], WATER[2])
        c.line([(20, 48.5), (28, 48.5)], WATER[2]); c.line([(36, 48.5), (44, 48.5)], WATER[2])
        c.line([(14, 41), (50, 41)], FOAM)
    else:
        c.line([(16, 45), (24, 45)], WATER[2]); c.line([(40, 45), (48, 45)], WATER[2])
        c.line([(14, 41), (50, 41)], FOAM)
    x, y = c.P(32, 57)
    c.px(x, y, FOAM); c.px(x - 1, y + 1, FOAM); c.px(x + 1, y + 1, FOAM)
    # rock cracks
    if not c.small:
        c.line([(44, 24), (46, 28), (45, 31)], ROCK2[1])
        c.line([(18, 26), (20, 29)], ROCK2[1])
    c.eye(25.5, 29, disc=False)
    c.eye(38.5, 29, disc=False)
    c.smile(32, 33.5)
    c.blush(21, 33); c.blush(42, 33)

K.render_pal(fn, 'pl-sing-4', 'Pondrock Islets', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sing-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sing-4.png')
