# Bridge Knots (pl-tcb-4): inner-TTTT double. A fat rope knot lashed round a bridge post: the square body is three tan rope coils wrapped
# across the brown post (post shows between the coils and pokes out top and bottom as stubs between the double-loop tabs); each double tab
# is a pair of rope bights (loops) sticking out of the knot. Cell 2-5: brown post #6e3e38, tan rope rail #e8c890, ochre #c4894e, canopy greens.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROPE = K.ramp('#e8c890')
OCHRE = K.ramp('#c4894e')
POST = K.ramp('#6e3e38')
LEAF = K.ramp('#57a168')
LEAF2 = K.ramp('#3e8a60')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 14, 51, 50)
    tabs = [K.knob('T', 'double', 32, 14, 0, -1, r=5.4 * s), K.knob('T', 'double', 32, 50, 0, 1, r=5.4 * s),
            K.knob('T', 'double', 13, 32, -1, 0, r=5.4 * s), K.knob('T', 'double', 51, 32, 1, 0, r=5.4 * s)]
    body = c.m(core, *tabs)
    # post behind, the whole body base
    c.add(body, POST)
    # rope loops (tabs) in tan, with an ochre hole in each lobe so they read as bights
    loops = c.m(*tabs, minus=(core,))
    c.add(loops, ROPE)
    # rope lashing: top and bottom wraps, an X of rope across the post, a fat knot in the middle
    ropes = []
    for pts in (((13, 17.5), (51, 17.5)), ((13, 46.5), (51, 46.5)), ((16, 18), (48, 46)), ((48, 18), (16, 46))):
        m = c.m(K.thick_path(list(pts), 7.0 * (1.1 if c.small else 1.0))) & body
        ropes.append(m)
        c.add(m, ROPE)
        c.edge(m, OCHRE[1])
    knot = c.m(K.ell(32, 32, 11.5, 8.5))
    c.add(knot, ROPE)
    c.edge(knot, OCHRE[1])
    lay = 4
    for m in ropes:
        for (x, y) in m:
            if (x + y) % lay == 0 and (x, y) not in knot:
                c.px(x, y, OCHRE[0])
    lashed = knot.union(*ropes)
    if not c.small:   # post grain only where the wood shows
        for (x, y) in c.m(core):
            if x % 5 == 2 and (y // 3) % 4 != 0 and (x, y) not in lashed:
                c.px(x, y, POST[1])
    if not c.small:   # twist creases at the knot's sides
        for (x, y) in knot:
            X = x / c.k
            if (X < 23 or X > 41) and (x + y) % 3 == 0:
                c.px(x, y, OCHRE[0])
    # rope loops: an ochre eye in each lobe so the double tabs read as bights of rope
    for (mx, my, nx, ny) in ((32, 14, 0, -1), (32, 50, 0, 1), (13, 32, -1, 0), (51, 32, 1, 0)):
        r = 5.4 * s
        k = r * 0.56
        cc = r + 1.6
        ax, ay = -ny, nx
        for sgn in (-1, 1):
            hx = mx + nx * (cc - 0.3) + ax * sgn * k
            hy = my + ny * (cc - 0.3) + ay * sgn * k
            hole = c.m(K.ell(hx, hy, 2.0 * s, 2.0 * s))
            for q in hole:
                c.px(q[0], q[1], OCHRE[1])
    # leaf sprig tucked into the top-right corner (canopy green)
    leaf = c.m(K.ell(47.5, 15.5, 5.2, 3.0), K.ell(51.5, 20, 3.0, 4.6))
    c.add(leaf & c.m(K.rect(40, 9, 58, 27)), LEAF)
    c.add(c.m(K.ell(51.5, 20, 3.0, 4.6)), LEAF2)
    # face on the middle coil
    c.eye(27, 30.5)
    c.eye(37.5, 30.5)
    c.smile(32, 34, K.UMBER2)
    c.blush(24, 34)
    c.blush(39.5, 34)


K.render_pal(fn, 'pl-tcb-4', 'Bridge Knots', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-4.png')
