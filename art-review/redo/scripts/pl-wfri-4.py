import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
# Redcap Congregation: four leaning toadstools merged into an inner-TTTT piece (double knobs).
# Caps (red, magenta, orange, pink, cream spots) fill the top half; cream stems and fairy-ring grass fill the bottom.
RED = K.ramp('#d8483a'); MAGc = K.ramp('#b8407e'); ORA = K.ramp('#e0703a'); PINK = K.ramp('#d8609a')
STEM = K.ramp('#ecdcc0'); GRASS = K.ramp('#4aa04a'); NAVY = K.ramp('#24384e')
SPOT = '#f8ecd8'

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.6 * k
    core = K.poly([(16, 13), (48, 13), (51, 16), (51, 49), (48, 51), (16, 51), (13, 48), (13, 16)])
    top = K.knob('T', 'double', 32, 13, 0, -1, r=r)
    lef = K.knob('T', 'double', 13, 26, -1, 0, r=r)
    rig = K.knob('T', 'double', 51, 26, 1, 0, r=r)
    bot = K.knob('T', 'double', 32, 51, 0, 1, r=r)
    body = c.m(core, top, lef, rig, bot)
    # night backdrop (the cell's navy trunks) behind the toadstools
    c.add(body, NAVY)
    c.add(c.m(K.rect(26, 0, 38, 64)) & body, K.ramp('#1c2c40'))
    # stems, leaning inward
    stems = [((18, 44), (21, 30), 7.0), ((27.5, 45), (29, 26), 6.5), ((36.5, 45), (35, 26), 6.5), ((46, 44), (43, 30), 7.0)]
    sm = c.m(*[K.thick_path([a, b], w) for a, b, w in stems]) & body
    c.add(sm, STEM)
    c.add(c.m(K.rect(0, 43, 64, 64), K.ell(32, 44, 22, 3)) & body, GRASS)
    # four caps leaning to the centre: inner pair behind (red, pink), outer pair in front (magenta, orange)
    caps = [
        (K.ell(28, 20, 9.5, 8), 27, RED),
        (K.ell(37, 20, 9.5, 8), 27, PINK),
        (K.ell(19, 27, 9.5, 8.5), 33, MAGc),
        (K.ell(45, 27, 9.5, 8.5), 33, ORA),
    ]
    masks = []
    for pred, cut, rm in caps:
        mk = c.m(pred, minus=(K.rect(0, cut, 64, 64),)) & body
        masks.append((mk, rm))
    for i, (mk, rm) in enumerate(masks):
        vis = set(mk)
        for mk2, _ in masks[i + 1:]:
            vis -= mk2
        c.add(mk, rm)
        c.edge(vis, rm[1])
        # gill rim: bottom row of each cap
        rim = {(x, y) for (x, y) in vis if (x, y + 1) not in mk}
        for q in rim:
            c.px(q[0], q[1], '#c9a888')
    # side tabs: cap brims; top tab: two tiny red caps
    c.add(c.m(lef, minus=(core,)) & body, MAGc)
    c.add(c.m(rig, minus=(core,)) & body, ORA)
    c.add(c.m(top, minus=(core,)) & body, RED)
    c.add(c.m(bot, minus=(core,)) & body, GRASS)
    # spots
    spots = [(26, 15), (31, 18), (39, 15), (13, 26), (24, 22), (40, 22), (50, 26), (36, 21)]
    for sx, sy in spots:
        cx, cy = c.P(sx, sy)
        if c.small:
            c.px(cx, cy, SPOT)
        else:
            for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
                c.px(cx + dx, cy + dy, SPOT)
    for x0 in (30, 34):
        c.px(*c.P(x0, 6), SPOT)
    # glow sparkles (fairy ring)
    for gx, gy in ((16, 47), (48, 47), (24, 41), (40, 41), (17, 16), (47, 15)):
        c.px(*c.P(gx, gy), '#f8e070')
    # faces on the two middle stems (leaning together, sharing a secret)
    c.eye(18, 28, disc=True, look=(1, 0))
    c.eye(46, 28, disc=True, look=(-1, 0))
    c.blush(22, 30.5)
    c.blush(41, 30.5)

K.render_pal(fn, 'pl-wfri-4', 'Redcap Congregation', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfri-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfri-4.png')
