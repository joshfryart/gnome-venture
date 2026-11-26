import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Pinfeather Hush: a pale owl feather that is a corner piece. Flat left + bottom sides, peg tabs on top (feather tip) and right.
# Colours from cell 4-4: snow-white bark, lavender bark streaks, periwinkle night; brown quill per the blurb.
VANE = K.ramp('#ece6f2')
BAR = K.ramp('#b6aed6')
NIGHT = K.ramp('#6e6aa8')
QUILL = K.ramp('#8a5a36')

def fn(c):
    s = 1.15 if c.small else 1.0
    # vane: flat left + bottom, the upper-right corner swept into a long curved feather tip
    core = K.poly([(10, 54), (10, 24), (13, 18), (19, 13), (28, 11), (40, 9), (49, 6), (55, 3), (53, 12), (53, 24), (52, 36), (49, 46), (43, 52), (36, 54)])
    t_top = K.knob('T', 'peg', 26, 11.5, -0.2, -0.98, r=4.2 * s)
    t_right = K.knob('T', 'peg', 52.5, 30, 1, 0, r=4.2 * s)
    splits = (K.poly([(10, 21), (19, 23), (14, 15)]),          # barb splits: notches where the vane parts
              K.poly([(47, 50), (40, 45), (50, 43)]))
    body = c.m(core, t_top, t_right, minus=splits)
    c.add(body, VANE)
    bx, by, tx, ty = 11, 53, 51, 11
    L = ((tx - bx) ** 2 + (ty - by) ** 2) ** .5
    dx, dy = (tx - bx) / L, (ty - by) / L
    nx, ny = -dy, dx
    w = 4.4 if c.small else 3.8
    for t in (0.36, 0.56, 0.76):      # owl barring: lavender chevrons swept back toward the quill base
        P = (bx + dx * L * t, by + dy * L * t)
        arm = lambda sg: (P[0] + sg * 30 * nx - 15 * dx, P[1] + sg * 30 * ny - 15 * dy)
        band = c.m(K.thick_path([arm(1), P, arm(-1)], w), minus=(K.ell(40, 36, 10.5, 7.5),)) & body
        c.add(band, BAR)
    down = c.m(K.ell(10, 54, 17, 15)) & body           # night-blue down at the quill base
    c.add(down, NIGHT)
    c.edge(down, NIGHT[1])
    shaft = c.m(K.thick_path([(9, 56), (20, 44), (34, 28), (47, 13), (56, 2)], 3.6 if c.small else 3.0)) & body
    c.add(shaft, QUILL)
    # face on the broad lower-right vane
    c.eye(35.5, 35)
    c.eye(44.5, 35)
    c.smile(40, 39 if not c.small else 38.5)
    c.blush(33, 39)
    c.blush(47, 39)

K.render_pal(fn, 'pl-owl-1', 'Pinfeather Hush', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-1.png')
