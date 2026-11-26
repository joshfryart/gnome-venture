import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Lodge Door: a stick-and-mud beaver lodge that is an inner-BBBB piece (round blanks on all four sides);
# domed top with poking stick ends, woven stick bands (cell browns), dark round door at the blue waterline, beaver peeking out.
MUD = K.ramp('#b47a48')
STICK = K.ramp('#d8a070')
DARKS = K.ramp('#6a3a20')
DOOR = ('#3a2218', '#2e1a12', '#4a2c1a')
WATER = K.ramp('#3a78b0')
FUR = K.ramp('#9a5a2a')

def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.5 * s
    core = K.poly([(6, 58), (6, 22), (10, 13), (18, 7), (32, 5), (46, 7), (54, 13), (58, 22), (58, 58)])
    sticks = [K.thick_path([(6, 14), (12, 11)], 2.8), K.thick_path([(58, 14), (52, 11)], 2.8)]
    blanks = [K.knob('B', 'round', 32, 5, 0, -1, r=r), K.knob('B', 'round', 32, 58, 0, 1, r=r),
              K.knob('B', 'round', 6, 36, -1, 0, r=r), K.knob('B', 'round', 58, 36, 1, 0, r=r)]
    body = c.m(core, *sticks, minus=blanks)
    c.add(body, MUD, stitch=None)
    # woven stick bands
    bands = [K.thick_path([(4, 17), (20, 14), (40, 16), (60, 14)], 2.8),
             K.thick_path([(4, 29), (22, 31), (44, 28), (60, 30)], 2.8)]
    c.add(c.m(*bands) & body, STICK)
    darkb = [K.thick_path([(8, 22), (26, 23), (46, 21), (58, 23)], 2.6),
             K.thick_path([(6, 42), (14, 40), (22, 42)], 2.6), K.thick_path([(42, 42), (50, 40), (60, 42)], 2.6)]
    c.add(c.m(*darkb) & body, DARKS)
    c.add(c.m(*sticks) - c.m(*blanks), STICK)
    # water at the base
    water = c.m(K.rect(0, 48.5, 64, 64)) & body
    c.add(water, WATER)
    # round door, low at the waterline
    door = c.m(K.ell(32, 36, 9.5, 10.5), K.rect(22.5, 36, 41.5, 48.5)) & body
    c.add(door, DOOR)
    c.edge(door, '#5a3424')
    # beaver peeking: head in door
    head = c.m(K.ell(32, 38, 7, 6.5)) & door
    c.add(head, FUR)
    c.eye(28.5, 36, disc=True)
    c.eye(35.5, 36, disc=True)
    # nose + teeth
    nx, ny = c.P(32, 40)
    c.px(nx, ny, '#3a2218'); c.px(nx - 1, ny, '#3a2218')
    for dy in range(1, 3 if c.small else 4):
        c.px(nx - 1, ny + dy, '#f4f0e4'); c.px(nx, ny + dy, '#f4f0e4')
    # ripple lines on water
    if not c.small:
        c.line([(10, 53), (17, 53)], '#9cc4e4'); c.line([(47, 53), (54, 53)], '#9cc4e4')

K.render_pal(fn, 'pl-bvd-5', 'Lodge Door', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-5.png')
