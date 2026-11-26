import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

PLANK = [K.ramp('#c08850'), K.ramp('#a86e40'), K.ramp('#b87c48')]
GAP = K.ramp('#4a2a28')
POST = K.ramp('#8a5a34')
ROPE = K.ramp('#d8b070')
LEAF = K.ramp('#5aa04a')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 13, 51, 20, 56
    core = K.rect(x0, y0, x1, y1)
    tl = K.knob('T', 'tri', x0, 38, -1, 0, r=4.5 * k)
    tr = K.knob('T', 'tri', x1, 38, 1, 0, r=4.5 * k)
    bt = K.knob('B', 'tri', 32, y0, 0, -1, r=3.6 * k)
    # rope posts at the top corners + handrail rope sagging between
    pl = K.rect(13, 9, 18.5, 22)
    pr = K.rect(45.5, 9, 51, 22)
    body = c.m(core, tl, tr, minus=(bt,))
    c.add(body, GAP)
    # planks: three horizontal boards separated by dark gaps
    bands = [(20, 30.5), (33, 43), (45.5, 56)]
    for i, (a, b) in enumerate(bands):
        m = c.m(K.rect(6, a, 58, b), minus=(bt,)) & body
        c.add(m, PLANK[i], stitch=None)
        # wood grain knots
    # rope lashings binding the planks (vertical side ropes of the bridge)
    for rx in (17.5, 46.5):
        c.add(c.m(K.rect(rx - 1.6, 19, rx + 1.6, 56)), ROPE)
    c.add(c.m(pl), POST)
    c.add(c.m(pr), POST)
    rope = c.m(K.thick_path([(15, 11), (24, 15), (32, 16.5), (40, 15), (49, 11)], 2.8 if not c.small else 3.2))
    c.add(rope, ROPE)
    # leafy tuft on posts (canopy)
    c.add(c.m(K.ell(15.5, 8, 4.5, 3)), LEAF)
    c.add(c.m(K.ell(48.5, 8, 4.5, 3)), LEAF)
    # grain lines
    gr = '#7a4a30'
    if not c.small:
        c.line([(16, 27), (22, 27)], gr)
        c.line([(43, 51), (49, 51)], gr)
        c.line([(16, 50), (20, 50)], gr)
        c.line([(44, 25), (48, 25)], gr)
    # face on middle plank
    c.eye(26, 37)
    c.eye(38, 37)
    c.smile(32, 40)
    c.blush(21.5, 40)
    c.blush(42, 40)


K.render_pal(fn, 'pl-tcb-2', 'Plank Skipper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-2.png')
