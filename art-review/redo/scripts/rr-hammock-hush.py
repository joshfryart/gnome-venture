# Concept: a sloth hanging from the rope-bridge plank (Rainroot cell 6-3). Edge-BTB: flat top = the wooden plank it clings to,
# keyhole blanks cut into left and right flanks (between arms and belly), keyhole tab at the bottom = its dangling furry rump.
# Colours from the cell: sloth fur #9a8a69 / #6f604b, cream face #c2b28e, dark eye stripes #492c1c, bridge wood, leaf green #5f9a7a.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

FUR = K.ramp('#9a8a69')
FURD = K.ramp('#7a6a50')
FACE = K.ramp('#e2d6b0')
WOOD = K.ramp('#a8743c')
ROPE = K.ramp('#d8b878')
LEAF = K.ramp('#5f9a7a')
STRIPE = '#492c1c'


def fn(c):
    s = 1.15 if c.small else 1.0
    plank = K.rect(6, 7, 58, 15)
    core = K.poly([(11, 14), (53, 14), (53, 44), (50, 48), (14, 48), (11, 44)])
    tab = K.knob('T', 'keyhole', 32, 48, 0, 1, r=5.0 * s)
    bl = K.knob('B', 'keyhole', 11, 33, -1, 0, r=5.2 * s)
    br = K.knob('B', 'keyhole', 53, 33, 1, 0, r=5.2 * s)
    body = c.m(core, tab, minus=(bl, br))
    c.add(body, FUR, stitch=None if c.small else '#c2b28e')
    # arms reaching up to the plank
    arms = c.m(K.thick_path([(20, 22), (16, 13)], 6.5), K.thick_path([(44, 22), (48, 13)], 6.5), minus=(bl, br))
    c.add(arms, FURD)
    c.edge(arms, '#6f604b')
    # plank with rope wraps
    c.add(c.m(plank), WOOD)
    rope = c.m(K.rect(24, 6, 27, 16), K.rect(37, 6, 40, 16))
    c.add(rope, ROPE)
    # leaf hanging off the plank (vine from the picture)
    leaf = c.m(K.ell(57, 13, 3.2, 4.5))
    c.add(leaf, LEAF)
    # claws hooking over the plank
    for cx in (13, 16, 19, 45, 48, 51):
        x, y = c.P(cx, 9)
        c.px(x, y, '#f2e4c0')
        c.px(x, y + 1, '#f2e4c0')
        if not c.small:
            c.px(x, y + 2, '#c2b28e')
    # face mask
    face = c.m(K.ell(32, 31, 11.5, 10))
    c.add(face, FACE)
    c.edge(face, '#a89a74')
    # dark sloth eye stripes sloping down-outward
    # dark sloth eye patches: teardrops running from the eye down and outward
    patch = c.m(K.thick_path([(26.5, 28.5), (23, 33)], 5.2 if c.small else 4.6), K.thick_path([(37.5, 28.5), (41, 33)], 5.2 if c.small else 4.6))
    for p in patch:
        if p in face:
            c.px(p[0], p[1], STRIPE)
    # sleepy closed eyes (cream arcs on the patches)
    for ex in (25.5, 38.5):
        x, y = c.P(ex, 29.5)
        if c.small:
            c.px(x, y, '#f2e4c0'); c.px(x + 1, y, '#f2e4c0')
        else:
            c.px(x - 1, y, '#f2e4c0'); c.px(x, y + 1, '#f2e4c0'); c.px(x + 1, y + 1, '#f2e4c0'); c.px(x + 2, y, '#f2e4c0')
    # nose and smile
    nx, ny = c.P(32, 33)
    c.px(nx - 1, ny, STRIPE); c.px(nx, ny, STRIPE)
    if not c.small:
        c.px(nx - 1, ny + 1, STRIPE); c.px(nx, ny + 1, STRIPE)
    c.smile(31.5, 36)
    c.blush(24, 37)
    c.blush(39, 37)


K.render_pal(fn, 'rr-hammock-hush', 'Hammock Hush', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/rr-hammock-hush-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/rr-hammock-hush.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
