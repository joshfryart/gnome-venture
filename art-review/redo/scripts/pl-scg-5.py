import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Deepcave Glow: a sea-cave ship's lantern that is an inner-BBBB round piece. Blanks: N cut into the slate roof cap,
# S into the base (two little feet), W + E into the cave-blue frame posts. The glass pane is the cell's warm glow
# (gold core, orange + mauve halo) and wears the face; cream star specks from the night sky on the roof.

ROOF = K.ramp('#34486a')
FRAME = K.ramp('#5f7896')
BASE = K.ramp('#2c4462')
HALO = K.ramp('#8a5e58')
ORANGE = K.ramp('#e0903a')
GLOW = ('#f8d468', '#e8b048', '#fff0b0')
STAR = '#f2e4c0'
BRASS = K.ramp('#d8a040')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(9, 18), (13.5, 13), (50.5, 13), (55, 18), (55, 58), (9, 58)])
    bN = K.knob('B', 'round', 32, 13, 0, -1, r=4.0 * k)
    bS = K.knob('B', 'round', 32, 58, 0, 1, r=4.0 * k)
    bW = K.knob('B', 'round', 9, 36, -1, 0, r=3.8 * k)
    bE = K.knob('B', 'round', 55, 36, 1, 0, r=3.8 * k)
    blanks = (bN, bS, bW, bE)
    body = c.m(core, minus=blanks)
    # bail handle: an iron arch over the top blank, its feet on the roof either side
    arc = [(20, 14), (21, 8), (25, 4.2), (32, 3), (39, 4.2), (43, 8), (44, 14)]
    handle = c.m(K.thick_path(arc, 3.4 if c.small else 2.8)) - body
    c.add(handle, ROOF)
    c.add(body, FRAME, stitch=None)
    # roof cap and base band
    c.add(body & c.m(K.rect(0, 0, 64, 22)), ROOF)
    c.add(body & c.m(K.rect(0, 50, 64, 64)), BASE)
    # brass bands under the roof and above the base
    c.add(body & c.m(K.rect(0, 22, 64, 24.5)), BRASS)
    c.add(body & c.m(K.rect(0, 47.5, 64, 50)), BRASS)
    # glass pane between the corner posts: dusky amber lit from within
    pane = body & c.m(K.rect(16.5, 24.5, 47.5, 47.5))
    c.add(pane, K.ramp('#a86a50'))
    c.edge(pane, K.UMBER2)
    # glass: halo -> orange -> gold glow
    halo = c.m(K.ell(32, 36, 12, 11.5))
    c.add(halo, HALO)
    c.add(c.m(K.ell(32, 36, 9.6, 9.2)), ORANGE)
    glow = c.m(K.ell(32, 36, 7.2, 7))
    c.add(glow, GLOW)
    c.edge(halo, K.UMBER2)
    # star specks on the roof (night sky of the cell)
    for sx, sy in ((15, 17), (47, 16.5), (41, 19.5)):
        x, y = c.P(sx, sy)
        c.px(x, y, STAR)
        if not c.small:
            c.px(x + 1, y, STAR)
    # rivets on the frame posts
    for rx, ry in ((12.5, 27), (51.5, 27), (12.5, 45), (51.5, 45)):
        x, y = c.P(rx, ry)
        c.px(x, y, BRASS[2])
    # face on the glow
    c.eye(28.5, 35)
    c.eye(35.5, 35)
    c.smile(32, 39)
    c.blush(25, 39)
    c.blush(38.5, 39)


K.render_pal(fn, 'pl-scg-5', 'Deepcave Glow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-5.png')
