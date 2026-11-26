"""pl-smk-1 Ashpuff Drifter: a puff of caldera smoke that is a corner-TT piece. Flat W and S sides (the puff sits on the crater rim),
hook tabs N and E are curling smoke wisps. Lavender-grey smoke from the picture's plume, ash-purple underside from the dusk sky cell 9-0,
and a little spotted smokecap mushroom hat (the warmer hat it is hunting for)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SMOKE = K.ramp('#b9b2d2')
ASH = K.ramp('#6e4a80')
SKY = K.ramp('#4e3d6e')
CAP = K.ramp('#d8744a')
STEM = K.ramp('#e8e0d0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 20, 49, 56)
    tabN = K.knob('T', 'hook', 27, 20, 0, -1, r=6.4 * k)
    tabE = K.knob('T', 'hook', 49, 38, 1, 0, r=6.4 * k, flip=True)
    # round off the top-left and top-right corners into puffs (the sides stay straight between)
    cut_tl = lambda x, y: x < 14 and y < 25 and (x - 14) ** 2 + (y - 25) ** 2 > 25
    cut_tr = lambda x, y: x > 44 and y < 25 and (x - 44) ** 2 + (y - 25) ** 2 > 25
    # billows bulging out of the N and E sides (keeps the flat W and S sides and the square core)
    bil = (K.ell(15, 22, 6.5, 4.5), K.ell(40, 21, 7, 4.5), K.ell(48, 27, 4, 5.5), K.ell(48.5, 50, 4, 5))
    body = c.m(core, tabN, tabE, *bil, minus=(cut_tl, cut_tr))
    c.add(body, SMOKE)
    # ash-purple underside band (the dusk sky)
    c.add(body & c.m(K.rect(0, 47, 64, 64)), ASH)
    # puff contours: overlapping billows inside the body
    if not c.small:
        for (cx, cy, r) in ((13, 29, 5), (44, 30, 5), (14, 44, 5), (44, 43, 5)):
            m = c.m(K.ell(cx, cy, r, r * 0.85)) & body
            c.edge(m, SMOKE[1] if cy < 40 else '#9184b0')
        for (cx, cy) in ((12, 27), (29, 24), (43, 28)):
            c.add(c.m(K.ell(cx, cy, 2.6, 1.6)) & body, K.ramp('#e6e2f2'))
    else:
        pass
    # wisp tips a little lighter
    c.add(c.m(tabN, minus=(core,)), K.ramp('#cfc9e2'))
    c.add(c.m(tabE, minus=(core,)) & c.m(K.rect(51, 0, 64, 64)), K.ramp('#cfc9e2'))
    # little smokecap hat, tilted on the top-left puff
    hat = c.m(lambda x, y: K.ell(15, 20, 9, 7)(x, y) and y < 20.5)
    c.add(hat, CAP)
    c.add(c.m(K.rect(7, 20, 23, 22.5)), K.ramp('#8e7a70'))
    for (sx, sy) in ((11, 17), (16, 14.5), (20, 17.5)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#f4f0e4')
        if not c.small:
            c.px(x + 1, y, '#f4f0e4')
    # face
    c.eye(22, 36, look=(1, 0))
    c.eye(35, 36, look=(1, 0))
    c.smile(28.5, 41)
    c.blush(17.5, 40)
    c.blush(39, 40)


K.render_pal(fn, 'pl-smk-1', 'Ashpuff Drifter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-1.png')
