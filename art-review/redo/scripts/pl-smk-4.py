"""pl-smk-4 Caldera Prongs: inner-TTTT, double.
Concept: a squat caldera volcano that is a puzzle piece. Lilac crater-rock body (the stone/stem of cell 6-4) with slightly sloped
sides, a glowing caldera bowl in its top edge from which the N double tab bubbles up as a two-lobed lava blob (yellow-orange pool
of the cell), double rock-prong tabs E and W on the slopes with magma cracks, and the S double tab as the orange magma rim of the
cell's bottom band."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#958088')
ROCKD = K.ramp('#6e5c64')
LAVA = ('#f0a028', '#d06418', '#fbe07a')
MAGMA = K.ramp('#d8501c')
GLOW = '#fbe07a'
CRACK = '#e8781e'

TL, TR, BL, BR = (17, 17), (47, 17), (9, 54), (55, 54)


def side(a, b, sign):
    mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    dx, dy = b[0] - a[0], b[1] - a[1]
    L = math.hypot(dx, dy)
    return mx, my, sign * dy / L, -sign * dx / L


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([TL, TR, BR, BL])
    mx, my, nx, ny = side(TR, BR, 1)
    tabE = K.knob('T', 'double', mx, my + 2, nx, ny, r=4.8 * k)
    mx, my, nx, ny = side(BL, TL, 1)
    tabW = K.knob('T', 'double', mx, my + 2, nx, ny, r=4.8 * k)
    tabN = K.knob('T', 'double', 32, 17, 0, -1, r=5.4 * k)
    tabS = K.knob('T', 'double', 32, 54, 0, 1, r=4.8 * k)
    bowl = K.ell(32, 17, 11, 4.2)
    body = c.m(core, minus=(bowl,))
    c.add(body, ROCK, stitch=None if c.small else ROCK[1])
    # E/W rock prongs, darker stone
    c.add(c.m(tabE, minus=(core,)), ROCKD)
    c.add(c.m(tabW, minus=(core,)), ROCKD)
    # magma rim band along the foot (wavy top edge) + S tab
    band = c.m(core, minus=(lambda x, y: y < 48.5 + 1.6 * math.sin(x * 0.7),))
    c.add(band | c.m(tabS, minus=(core,)), MAGMA)
    # caldera: glowing crater lip, lava pool, lava blob bubbling up as the N tab
    c.add(c.m(K.ell(32, 18.5, 13, 4.6)) & body, MAGMA)
    c.add(c.m(K.ell(32, 17.5, 11, 4.0), tabN) - c.m(K.rect(0, 20.0, 64, 64)), LAVA)
    # lava flows dribbling down the slopes
    fw = 2.8 if not c.small else 3.4
    c.add(c.m(K.thick_path([(21, 19), (19, 25), (21, 29), (18.5, 35)], fw), K.ell(18.5, 35.5, 1.9, 2.2)) & body, LAVA)
    c.add(c.m(K.thick_path([(43, 19), (45, 24), (43.5, 28)], fw), K.ell(43.5, 28.5, 1.9, 2.2)) & body, LAVA)
    # glow highlights on the lava blob
    for (x, y) in [(28.5, 9.5), (35.5, 9.5)]:
        px, py = c.P(x, y)
        c.px(px, py, GLOW)
        if not c.small:
            c.px(px + 1, py, GLOW)
            c.px(px, py + 1, GLOW)
    # smoke puff drifting off the blob (the picture's smoke)
    c.add(c.m(K.ell(40.5, 5.5, 4.0, 3.0), K.ell(45.5, 4, 3.4, 2.6)), K.ramp('#b8b4d0'))
    # face
    c.eye(27, 36)
    c.eye(37, 36)
    c.smile(32, 41)
    c.blush(23.5, 40.5)
    c.blush(39.5, 40.5)
    # glowing embers on the magma band
    if not c.small:
        for x in (18, 27, 38, 47):
            c.px(*c.P(x, 52), GLOW)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-smk-4', 'Caldera Prongs', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-4.png')
    print(rep)
