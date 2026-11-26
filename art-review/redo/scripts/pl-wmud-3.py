"""pl-wmud-3 Candy Minaret. Inner-TBTB keyhole: a banded mud-brick minaret. N tab = the blue tiled spire cap with gold finial,
S tab = the brick plinth, E + W blanks cut into the striped shaft; wooden toron beams poke out of both sides (cell 11-3)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MUD = K.ramp('#c8884e')
BAND = K.ramp('#8e5030')
BEAM = K.ramp('#5a3620')
BLUE = K.ramp('#3f86d0')
GOLD = K.GOLD
BASE = K.ramp('#9a6038')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 14, 50, 16, 52
    core = K.poly([(18, y0), (46, y0), (50, y1), (14, y1)])
    tabN = K.knob('T', 'keyhole', 32, y0, 0, -1, r=5.6 * k)
    tabS = K.knob('T', 'keyhole', 32, y1, 0, 1, r=5.0 * k)
    blkE = K.knob('B', 'keyhole', 48.3, 36, 0.995, -0.1, r=2.7 * k)
    blkW = K.knob('B', 'keyhole', 15.7, 36, -0.995, -0.1, r=2.7 * k)
    bw = 3.2 if c.small else 2.6
    beams = [K.rect(12.5, 27.5, 51.5, 27.5 + bw), K.rect(11.5, 44, 52.5, 44 + bw)]
    body = c.m(core, minus=(blkE, blkW))
    c.add(body, MUD, stitch='#e8b27a')
    # candy bands (horizontal stripes of darker mud)
    bands = c.m(core, minus=(blkE, blkW)) & c.m(K.rect(0, 16, 64, 19), K.rect(0, 33, 64, 35.5), K.rect(0, 39.5, 64, 42))
    c.add(bands, BAND)
    # plinth tab + bottom course
    c.add(c.m(tabS, K.rect(x0, 49, x1, y1)), BASE)
    # blue spire cap (keyhole tab) with gold finial
    c.add(c.m(tabN, minus=(core,)), BLUE)
    c.add(c.m(K.ell(32, 2.6, 1.6, 1.8), K.rect(31.2, 2.5, 32.8, 6)), GOLD)
    # toron beams sticking out of the walls
    for b in beams:
        c.add(c.m(b), BEAM)
    # arched door from the picture (gold frame, blue/green glass)
    c.add(c.m(K.rect(27.5, 44, 36.5, 52), K.ell(32, 44, 4.5, 3.5)), K.ramp('#e8b830'))
    c.add(c.m(K.rect(29.4, 44.5, 34.6, 52), K.ell(32, 44.5, 2.6, 2.2)), K.ramp('#4a90c8'))
    if not c.small:
        c.add(c.m(K.rect(29.4, 47.5, 34.6, 48.7)), K.ramp('#5aa848'))
    # face on the upper shaft
    c.eye(26, 23)
    c.eye(38, 23)
    c.smile(32, 25.5)
    c.blush(22, 26)
    c.blush(42, 26)


K.render_pal(fn, 'pl-wmud-3', 'Candy Minaret', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wmud-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wmud-3.png')
