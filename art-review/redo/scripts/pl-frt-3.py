import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Thawdrop Pip: a meltwater drop that is an inner-TBTB piece. Top tri tab = the drop's tip, bottom tri tab = mossy tuft
# from the barrow's green hill, left/right tri blanks. Ice-teal body with a snow cap and the umber ridge line from cell 9-3.
ICE = K.ramp('#8cc8d0')
SNOW = ('#eef6f8', '#b8d0d8', '#ffffff')
MOSS = K.ramp('#7cb85c')
SKY = '#5a8cb0'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(32, 2), (40, 13), (47, 21), (51, 27), (51, 45), (47, 51), (40, 54), (24, 54), (17, 51), (13, 45), (13, 27), (17, 21), (24, 13)])
    tuft = K.knob('T', 'tri', 32, 54, 0, 1, r=4.0 * k)
    bl = K.knob('B', 'tri', 13, 37, -1, 0, r=3.9 * k)
    br = K.knob('B', 'tri', 51, 37, 1, 0, r=3.9 * k)
    body = c.m(core, minus=(bl, br))
    c.add(body, ICE, stitch=None if c.small else '#c4e4ea')
    # frost dusting on the tip (snow from the cell), with the cell's dark ridge line under it
    cap = c.m(K.poly([(32, 2), (39, 12), (35, 14), (32, 11), (28, 14), (25, 12)])) & body
    c.add(cap, SNOW)
    # moss band + tuft (green hill of cell 9-3)
    moss = c.m(tuft) | (body & c.m(K.rect(0, 50, 64, 64)))
    c.add(moss, MOSS)
    c.edge(moss & body, '#4a8a3c')
    # big ice highlight stripe, upper left
    hl = c.m(K.thick_path([(25, 17), (20, 25), (19, 31)], 3.0 if c.small else 2.4)) & body
    c.add(hl, ('#ffffff', '#ffffff', '#ffffff'))
    # face
    c.eye(27, 30)
    c.eye(38, 30)
    c.smile(32.5, 40)
    c.blush(23, 35)
    c.blush(42, 35)

K.render_pal(fn, 'pl-frt-3', 'Thawdrop Pip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-frt-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-frt-3.png')
