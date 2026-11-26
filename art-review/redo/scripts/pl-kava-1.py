import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""pl-kava-1 Sliver Rise, corner-TB round: a crescent moon rising out of the night sea. Flat S (sea horizon) and W,
round tab N (top of the moon), big round blank E = the crescent's inner bite. Pale gold moon, indigo sea with sparkles,
pink dusk horizon band and the cell's amber glint (haven-kava-circle window)."""
MOON = K.ramp('#f0dc8c')
SEA = K.ramp('#3c3a86')
DUSK = K.ramp('#c87a9c')
AMBER = '#f8d870'

def fn(c):
    S = 1.15 if c.small else 1.0
    # rounded upper corners so the moon's outer curve is the outline; flat W and S below
    R = 15
    core = lambda x, y: 8 <= x < 56 and 12 <= y < 58 and not (y < 12 + R and ((x < 8 + 7 and (x - 15) ** 2 + (y - 19) ** 2 > 49 and y < 19) or (x > 56 - R and (x - 56 + R) ** 2 + (y - 12 - R) ** 2 > R * R)))
    tabN = K.knob('T', 'round', 28, 12, 0, -1, r=5.0 * S)
    blankE = K.knob('B', 'round', 56, 27, 1, 0, r=9.6 * S, nw=4.0)
    body = c.m(core, tabN, minus=(blankE,))
    c.add(body, MOON)
    # crescent shading: a darker band hugging the bite
    shade = body & c.m(K.ell(56 - (9.6 * S + 2.1), 27, 9.6 * S + 4.5, 9.6 * S + 4.5)) & c.m(K.rect(0, 0, 64, 41))
    c.add(shade, ('#d8b860', '#b89040', '#e8cc78'))
    # sea and horizon at the bottom
    sea = body & c.m(K.rect(0, 44, 64, 64))
    c.add(sea, SEA)
    dusk = body & c.m(K.rect(0, 41, 64, 45))
    c.add(dusk, DUSK)
    # reflection glints on the sea
    for (gx, gy) in ((22, 49), (30, 52), (40, 49), (46, 54), (16, 54), (34, 48)):
        x, y = c.P(gx, gy)
        c.px(x, y, '#9a96d0')
        if not c.small:
            c.px(x + 1, y, '#9a96d0')
    # moon reflection column under the moon
    for gy in (47, 50, 53):
        x, y = c.P(22, gy)
        for dx in range(-1 if not c.small else 0, 2):
            c.px(x + dx, y, AMBER)
    # craters
    # sleepy face on the thick moon part
    c.eye(16, 25)
    c.eye(25, 25)
    c.blush(12, 30)
    c.blush(28, 30)
    c.smile(20.5, 31)

K.render_pal(fn, 'pl-kava-1', 'Sliver Rise', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-kava-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-kava-1.png')
