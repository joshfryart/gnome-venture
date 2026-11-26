import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

STONE = K.ramp('#d2bf98')
RISER = K.ramp('#a8906c')
MOSS = K.ramp('#5fa84a')
CLOUD = K.ramp('#8a5ea0')
CLOUD2 = K.ramp('#5a4a8e')
STAR = '#fff4d0'

X0, Y0, X1, Y1 = 6, 6, 58, 58
# stepped upper-left corner: 4 steps from (X0, 32) up to (34, Y0)
STEPS = [(X0, 32), (13, 25), (20, 18), (27, 11), (34, Y0)]


def fn(c):
    s = 1.15 if c.small else 1.0
    pts = [(X0, Y1), (X0, 32)]
    for (ax, ay), (bx, by) in zip(STEPS, STEPS[1:]):
        pts += [(bx, ay), (bx, by)]
    pts += [(X1, Y0), (X1, Y1)]
    core = K.poly(pts)
    bl = K.knob('B', 'keyhole', X0, 42, -1, 0, r=5 * s)
    bt = K.knob('B', 'keyhole', 46.5, Y0, 0, -1, r=5 * s)
    body = c.m(core, minus=(bl, bt))
    c.add(body, STONE, stitch=None)
    # risers (vertical faces) darker, treads light, along the stepped edge
    for (ax, ay), (bx, by) in zip(STEPS, STEPS[1:]):
        c.add(c.m(K.rect(bx - 2.2, by, bx + 0.01, ay + 4)) & body, RISER)
        c.add(c.m(K.rect(ax, ay, bx, ay + 2.4)) & body, MOSS)
    c.add(c.m(K.rect(34, Y0, X1, Y0 + 2.4)) & body, MOSS)
    # brick courses
    for y in (24, 38):
        if y < Y1 - 2:
            c.line([(X0 + 1, y), (X1 - 1, y)] if y > 33 else [(20, y), (X1 - 1, y)], RISER[0])
    for (x, y0, y1) in ((30, 24, 38), (48, 24, 38), (22, 38, 46), (40, 38, 46), (40, 12, 24)):
        c.line([(x, y0), (x, y1)], RISER[0])
    # purple cloud from the cell wrapped round the base, stair rises out of it
    cl = c.m(K.ell(12, 53, 8, 6), K.ell(26, 52, 9, 6.5), K.ell(42, 53, 9, 6), K.ell(54, 51, 7, 6), K.rect(X0, 54, X1, Y1)) & c.m(core)
    c.add(cl, CLOUD)
    c.add(c.m(K.ell(34, 58, 14, 3.2), K.ell(54, 57, 5, 3)) & cl, CLOUD2)
    c.edge(cl, CLOUD[1])
    # star twinkling over the top step
    cx, cy = c.P(52, 14)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(cx + dx, cy + dy, STAR)
    # face on the calm stone mass
    c.eye(28, 30)
    c.eye(40, 30)
    c.blush(24, 35)
    c.blush(44, 35)
    c.smile(34, 36)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-skyc-1', 'Cloudstep Climb', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-1.png'))
