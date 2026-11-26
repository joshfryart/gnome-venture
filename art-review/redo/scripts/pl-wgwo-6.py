# pl-wgwo-6 "Swinging Glowtail": a plump hanging glowworm that is the whole piece. Keyhole tab N = silk knot (thread rises to the top),
# keyhole tab S = the glowing teal tail tip, keyhole blanks W and E cut into the plump middle segment. Cave lavender body bands,
# grotto-teal glow on the tail and thread, navy night of cell 6-3 with its white sparkle on the belly.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

ROCK = K.ramp('#8c82c4')     # cave lavender
ROCK2 = K.ramp('#6a5fa8')    # deeper violet segment
HEAD = K.ramp('#b4aae0')
GLOW = K.ramp('#4fe0c8')     # grotto teal glow
NAVY = K.ramp('#2a2452')     # cell night
SILK = ('#c8f4ec', '#7fd0c8', '#ffffff')


def fn(c):
    S = 1.15 if c.small else 1.0
    def rr(x0, y0, x1, y1, r):
        return lambda x, y: x0 <= x < x1 and y0 <= y < y1 and not (
            (x < x0 + r and y < y0 + r and (x - x0 - r) ** 2 + (y - y0 - r) ** 2 > r * r) or
            (x > x1 - r and y < y0 + r and (x - x1 + r) ** 2 + (y - y0 - r) ** 2 > r * r) or
            (x < x0 + r and y > y1 - r and (x - x0 - r) ** 2 + (y - y1 + r) ** 2 > r * r) or
            (x > x1 - r and y > y1 - r and (x - x1 + r) ** 2 + (y - y1 + r) ** 2 > r * r))
    core = rr(11, 12, 53, 52, 8)
    tabN = K.knob('T', 'keyhole', 32, 12, 0, -1, r=3.4 * S, nw=2.0)
    tabS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=5.6 * S)
    bW = K.knob('B', 'keyhole', 11, 34, -1, 0, r=3.4 * S, nw=2.0)
    bE = K.knob('B', 'keyhole', 53, 34, 1, 0, r=3.4 * S, nw=2.0)
    # small segment pinches in the outline (a grub's rings)
    pinch = []
    for yy in (25, 43):
        pinch += [K.ell(10, yy, 2.2, 1.6), K.ell(54, yy, 2.2, 1.6)]
    thread = K.thick_path([(32, 0), (32, 8)], 2.8 if not c.small else 3.2)
    body = c.m(core, minus=[bW, bE] + pinch)
    c.add(c.m(thread), SILK)
    c.add(c.m(tabN, minus=(core,)), SILK)
    c.add(body & c.m(K.rect(0, 0, 64, 25)), HEAD, stitch=None)
    c.add(body & c.m(K.rect(0, 25, 64, 34)), ROCK)
    c.add(body & c.m(K.rect(0, 34, 64, 43)), ROCK2)
    tail = (body & c.m(K.rect(0, 43, 64, 64))) | c.m(tabS, minus=(core,))
    c.add(tail, GLOW)
    for yy in (25, 34, 43):
        c.edge(body & c.m(K.rect(0, 0, 64, yy)), K.UMBER2 if yy != 43 else '#2f8a80')
    # navy night spot with the cell's white sparkle
    c.add(c.m(K.ell(32, 38.5, 6.5, 3.0 if not c.small else 3.4)) & body, NAVY)
    c.px(*c.P(32, 38.5), '#ffffff')
    if not c.small:
        for (x, y) in ((24, 48), (40, 47), (32, 58), (17, 29), (47, 30)):
            c.px(*c.P(x, y), '#ffffff' if y > 43 else '#c9d2e4')
    else:
        c.px(*c.P(32, 58), '#ffffff')
    # face on head
    c.eye(25, 18.5, disc=True)
    c.eye(39, 18.5, disc=True)
    c.smile(32, 21.5)
    c.blush(20, 22)
    c.blush(43, 22)


K.render_pal(fn, 'pl-wgwo-6', 'Swinging Glowtail', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-6.png')
