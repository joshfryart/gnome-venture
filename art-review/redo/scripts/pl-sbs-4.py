# pl-sbs-4 "Eightlegs Clasp": a plum cave spider whose square body is an inner piece with four double-knob tabs
# (top/bottom/left/right); its eight lavender legs fold out of the four corners, two per corner, web-strand lavender
# on the lair's deep plum (cell 4-5: dark violet cave with pale web threads).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BODY = K.ramp('#4c3a6c')
BELLY = K.ramp('#5e4880')
LEG = K.ramp('#b8b6dc')
WEB = '#c8c8e0'
FANG = K.ramp('#e8e4f0')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 15, 15, 49, 49
    core = K.rect(x0, y0, x1, y1)
    tabs = [K.knob('T', 'double', 32, y0, 0, -1, r=4.6 * k),
            K.knob('T', 'double', 32, y1, 0, 1, r=4.6 * k),
            K.knob('T', 'double', x0, 32, -1, 0, r=4.6 * k),
            K.knob('T', 'double', x1, 32, 1, 0, r=4.6 * k)]
    w = 3.6 if c.small else 3.0
    legs = []
    for sx in (1, -1):
        for sy in (1, -1):
            def T(px, py):
                return (32 + sx * (px - 32), 32 + sy * (py - 32))
            # leg out sideways, knee up, foot down
            legs.append(K.thick_path([T(18, 21), T(8, 15), T(4, 22)], w))
            # leg out upward, knee out, foot sideways
            legs.append(K.thick_path([T(21, 18), T(15, 8), T(22, 4)], w))
    c.add(c.m(*legs), LEG)
    body = c.m(core, *tabs)
    c.add(body, BODY, stitch=None)
    # rounded abdomen patch to soften the box into a spider body
    belly = c.m(K.ell(32, 35, 11, 10))
    c.add(belly, BELLY)
    c.edge(belly, BODY[1])
    if not c.small:
        # web strands on the abdomen
        for pts in [[(32, 26), (32, 44)], [(22, 35), (42, 35)], [(25, 28), (39, 42)], [(39, 28), (25, 42)]]:
            c.line(pts, WEB)
    else:
        c.line([(32, 30), (32, 43)], WEB)
        c.line([(24, 36), (40, 36)], WEB)
    # glowing eyes in the top band, like the lair spider's
    c.eye(25, 21, disc=True)
    c.eye(39, 21, disc=True)
    if not c.small:
        for ex in (19, 45):
            px, py = c.P(ex, 19)
            c.px(px, py, WEB)
            c.px(px + 1, py, WEB)
    # fangs on the bottom tab
    fx, fy = c.P(32, 51)
    for dx in ((-2, 1) if not c.small else (-1, 1)):
        c.px(fx + dx, fy, FANG[0])
        c.px(fx + dx, fy + 1, FANG[0])


K.render_pal(fn, 'pl-sbs-4', 'Eightlegs Clasp', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-4.png')
