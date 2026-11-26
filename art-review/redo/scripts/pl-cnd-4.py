import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Talon Clutch: a condor foot that is an inner-TTTT piece. Top double tab = purple feather tuft of the leg;
# left / right / bottom double tabs = yellow toes, each lobe tipped with a curled ivory talon. Colours from cell 6-4.
PURP = K.ramp('#5c4a8c')
LAVL = K.ramp('#8a78b8')
FOOT = K.ramp('#e8c050')
CLAW = K.ramp('#ece4d0')
NEST = K.ramp('#c8925a')
S = '#3e3068'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 5.0 * k
    x0, y0, x1, y1 = 16, 15, 48, 47
    core = K.rect(x0, y0, x1, y1)
    top = K.knob('T', 'double', 32, y0, 0, -1, r=r)
    lef = K.knob('T', 'double', x0, 38, -1, 0, r=r)
    rig = K.knob('T', 'double', x1, 38, 1, 0, r=r)
    bot = K.knob('T', 'double', 32, y1, 0, 1, r=r)
    body = c.m(core, top, lef, rig, bot)
    # yellow foot = whole body first
    c.add(body, FOOT)
    # purple feathered leg: top of core + top tab, shaggy hem
    hem = K.poly([(15, 0), (49, 0), (49, 33), (45, 30), (41, 35), (36.5, 30), (32, 35), (27.5, 30), (23, 35), (19, 30), (15, 33)])
    leg = c.m(hem, top) & body
    c.add(leg, PURP, stitch=None if c.small else S)
    # lighter feather tips on the tuft
    plume = c.m(K.ell(32, 7, 6, 3.5)) & leg
    c.add(plume, LAVL)
    # curled talons: hooked ivory claws at the end of each toe lobe, curling down / inward
    kk = r * 0.56
    tl = x0 - 2 * r - 1.5
    tr = x1 + 2 * r + 1.5
    tb = y1 + 2 * r + 1.5
    cl = []
    for y in (38 - kk, 38 + kk):
        cl.append(K.thick_path([(tl + 3, y - 0.5), (tl - 0.5, y + 0.5), (tl - 1.5, y + 3.5), (tl + 1, y + 5.5)], 3.2))
        cl.append(K.thick_path([(tr - 3, y - 0.5), (tr + 0.5, y + 0.5), (tr + 1.5, y + 3.5), (tr - 1, y + 5.5)], 3.2))
    for x, sx in ((32 - kk, -1), (32 + kk, 1)):
        cl.append(K.thick_path([(x, tb - 3), (x + sx * 0.5, tb), (x + sx * 3, tb + 1.8), (x + sx * 5.5, tb + 0.5)], 3.2))
    claws = c.m(*cl)
    c.add(claws, CLAW)
    # toe split grooves
    if not c.small:
        c.line([(tl + 1, 38), (x0 - 1, 38)], FOOT[1])
        c.line([(x1 + 1, 38), (tr - 1, 38)], FOOT[1])
        c.line([(32, y1 + 1), (32, tb - 1)], FOOT[1])
    c.edge(leg, S)
    # scales on the foot
    if not c.small:
        for yy in (40, 45):
            c.line([(20, yy), (23, yy + 1), (26, yy)], FOOT[1])
            c.line([(38, yy), (41, yy + 1), (44, yy)], FOOT[1])
        c.line([(30, 43), (32, 44), (34, 43)], FOOT[1])
    # face on the purple leg
    c.eye(26, 24, disc=True)
    c.eye(38, 24, disc=True)
    c.smile(32, 29, col=K.CREAM)
    c.blush(21, 28)
    c.blush(42, 28)


K.render_pal(fn, 'pl-cnd-4', 'Talon Clutch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cnd-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cnd-4.png')
