"""pl-aurc-5 "Peak Peep": inner-BBBB, round. A snowy mountain whose body is the piece: the top side rises into a peak (snowcap),
round blanks cut into the W, E and S sides and into the right slope. Night-slope blue #40548c and sky navy from cell 11-3,
aurora green/violet ribbon draped over the summit (from the picture's sky), snowfield white at the foot."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

SLOPE = K.ramp('#40548c')
NAVY = K.ramp('#2e3870')
SNOW = ('#e4ecfa', '#b4c0e0', '#ffffff')
GREEN = K.ramp('#3fbf8f')
VIOLET = K.ramp('#b76fcf')
PINE = K.ramp('#1f6a55')


def fn(c):
    k = 1.15 if c.small else 1.0
    peak = (30, 5)
    core = K.poly([(7, 58), (7, 29), (27, 6.5), (30, 4.5), (33, 6.5), (57, 29), (57, 58)])
    # right slope normal (outward)
    dx, dy = 57 - 33, 29 - 6.5
    L = math.hypot(dx, dy)
    nx, ny = dy / L, -dx / L
    bW = K.knob('B', 'round', 7, 44, -1, 0, r=3.6 * k)
    bE = K.knob('B', 'round', 57, 44, 1, 0, r=3.6 * k)
    bS = K.knob('B', 'round', 32, 58, 0, 1, r=3.8 * k)
    bN = K.knob('B', 'round', 46, 19, nx, ny, r=3.2 * k)
    blanks = (bW, bE, bS, bN)
    body = c.m(core, minus=blanks)
    c.add(body, SLOPE)
    # darker navy shoulder on the right (shadow side of the mountain)
    shade = c.m(K.poly([(30, 4.5), (57, 29), (57, 58), (46, 58), (39, 30)]), minus=blanks)
    c.add(shade & body, NAVY)
    pass
    # snowcap with drippy lower edge
    cap = K.poly([(30, 2), (43, 17), (41, 19), (37, 17), (33, 21), (29, 17), (25, 20), (21, 16.5), (17, 18)])
    c.add(c.m(cap) & body, SNOW)
    # snowfield foot
    foot = lambda x, y: y > 53 + 1.4 * math.sin(x / 3.2)
    c.add(c.m(foot) & body, SNOW)
    # aurora ribbon draped across, just under the snowcap: green over violet
    w = 2.6 if c.small else 2.2
    gpts = [(7, 29), (14, 26), (22, 27.5), (30, 25), (38, 27), (46, 24.5), (57, 27.5)]
    vpts = [(x, y + w) for x, y in gpts]
    c.add(c.m(K.thick_path(vpts, w + 0.4)) & body, VIOLET)
    c.add(c.m(K.thick_path(gpts, w + 0.4)) & body, GREEN)
    # tiny pine at the left foot (the cell's green tip)
    c.add(c.m(K.poly([(14, 46), (18.5, 55), (9.5, 55)])) & body, PINE)
    # stars of the sky on the navy side (64 px only)
    if not c.small:
        for sx, sy in ((49, 34), (52, 52)):
            c.px(*c.P(sx, sy), '#e4ecfa')
    # face, on the calm blue middle
    c.eye(25.5, 38, disc=True)
    c.eye(38.5, 38, disc=True)
    c.smile(32, 43.5, K.UMBER)
    c.blush(20.5, 42.5)
    c.blush(42.5, 42.5)


K.render_pal(fn, 'pl-aurc-5', 'Peak Peep', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurc-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurc-5.png')
