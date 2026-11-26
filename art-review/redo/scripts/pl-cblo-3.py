# Fuji Bow: a snowy mountain that is an inner piece. Slanted mountain flanks are the W/E sides (round blanks), the snow summit is the
# N round tab, the pink blossom-haze foot is the S round tab. Lavender-blue slopes, white snow, pink haze from cell 4-2 / the teahouse picture.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

ROCK = ramp('#888fc8')
SLOPE = ramp('#a7b3ec')
SNOW = ('#f4f4fb', '#b7bce3', '#ffffff')
HAZE = ramp('#f4c3d7')
PINK = ramp('#e889b0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(22, 17), (42, 17), (58, 57), (6, 57)])
    nx, ny = 0.928, -0.371
    tabN = knob('T', 'round', 32, 17, 0, -1, r=5.8 * k, nw=3.4)
    tabS = knob('T', 'round', 32, 57, 0, 1, r=4.6 * k)
    blW = knob('B', 'round', 12.3, 41, -nx, ny, r=3.9 * k)
    blE = knob('B', 'round', 51.7, 41, nx, ny, r=3.9 * k)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, ROCK)
    # lighter left slope band (light from upper left)
    c.add(body & c.m(poly([(22, 17), (30, 17), (14, 57), (6, 57)])), SLOPE)
    c.add(body & c.m(poly([(36, 24), (39, 24), (34, 57), (30, 57)])), SLOPE)
    # snow cap with drippy lower edge
    snow = c.m(lambda x, y: y < 25 + (3.5 if (int(x) // 5) % 2 else 0) - abs(x - 32) * 0.08)
    c.add(body & snow, SNOW)
    # pink blossom haze at the foot + the S tab
    haze = c.m(lambda x, y: y > 51 - (1.5 if (int(x) // 6) % 2 else 0))
    c.add(body & haze, HAZE)
    if not c.small:
        for (x, y) in [(14, 54), (22, 53), (40, 54), (48, 53), (31, 60)]:
            c.add(body & c.m(ell(x, y, 2.2, 1.8)), PINK)
    else:
        for (x, y) in [(16, 54), (46, 54), (31, 60)]:
            c.add(body & c.m(ell(x, y, 2.4, 2.0)), PINK)
    # face: bowing, eyes looking down
    c.eye(26, 33, disc=True, look=(0, 1))
    c.eye(38, 33, disc=True, look=(0, 1))
    c.smile(32, 39)
    c.blush(21, 37)
    c.blush(42, 37)


K.render_pal(fn, 'pl-cblo-3', 'Fuji Bow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-3.png')
