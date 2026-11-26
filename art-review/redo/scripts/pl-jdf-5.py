import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Concept: a dragonfly head that is an inner piece. Top half = two big faceted blue compound eyes (cell 5-2) with
# orange lantern pupils; tri blank on top notches between the eyes, tri blank on right, tri tabs on left and bottom (mandible).
EYE = ('#62c0e8', '#3a8cc4', '#b4ecfa')
EYE2 = K.ramp('#2f86c0')
JADE = K.ramp('#3d9a78')
GLOW = '#f0902a'
GLOW2 = '#f8c860'
FACET = '#2a6a9a'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 18, 52, 52)
    eL, eR = K.ell(20.5, 22, 9.8, 11), K.ell(43.5, 22, 9.8, 11)
    tl = K.knob('T', 'tri', 12, 38, -1, 0, r=4.5 * k)
    tb = K.knob('T', 'tri', 32, 52, 0, 1, r=4.5 * k)
    bt = K.knob('B', 'tri', 32, 18, 0, -1, r=3.8 * k)
    br = K.knob('B', 'tri', 52, 40, 1, 0, r=4.5 * k)
    body = c.m(core, eL, eR, tl, tb, minus=(bt, br))
    c.add(body, JADE, stitch=K.ramp('#3d9a78')[2])
    for (cx, ex) in ((20.5, eL), (43.5, eR)):
        em = c.m(ex, minus=(bt,)) & body
        c.add(em, EYE)
        lower = c.m(K.ell(cx + 2, 27, 9, 5)) & em
        c.add(lower, EYE2)
        c.edge(em, K.UMBER2)
        # facets
        if not c.small:
            for fx in range(-7, 8, 4):
                for fy in range(-6, 9, 4):
                    X, Y = cx + fx + (2 if (fy // 4) % 2 else 0), 22 + fy
                    p = c.P(X, Y)
                    if p in em and ((X - cx) ** 2 + (Y - 22) ** 2) > 30:
                        c.px(p[0], p[1], FACET)
        # orange lantern glow ring + felt pupil
        gx, gy = c.P(cx + 1, 21)
        rr = 1 if c.small else 2
        for dx in range(-rr - 1, rr + 2):
            for dy in range(-rr - 1, rr + 2):
                if dx * dx + dy * dy <= (rr + 1) ** 2:
                    c.px(gx + dx, gy + dy, GLOW)
        for dx in range(-rr, rr + 1):
            for dy in range(-rr, rr + 1):
                if dx * dx + dy * dy <= rr * rr and (dx < 0 or dy < 0):
                    c.px(gx + dx, gy + dy, GLOW2)
        c.eye(cx + 1, 21, look=(0, 0))
        hx, hy = c.P(cx - 5, 16)
        c.px(hx, hy, '#ffffff'); c.px(hx + 1, hy, '#ffffff')
        if not c.small:
            c.px(hx, hy + 1, '#ffffff')
    # jade face: segment ridges + smile + blush
    # dragonfly thorax: yellow-green stripes like the picture's body, tiny mandible mouth
    STR = K.ramp('#c8d860')
    for sx in (21, 43):
        c.add(c.m(K.rect(sx - 1.6, 34, sx + 1.6, 50)) & body, STR)
    c.smile(32, 38)
    c.blush(26, 37); c.blush(37, 37)

K.render_pal(fn, 'pl-jdf-5', 'Lantern Eye Pair', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-5.png')
