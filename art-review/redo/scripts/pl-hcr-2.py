import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Shell Splinter: an orange crab-shell chip that is an edge piece. Flat bottom, top = peg blank between two eye stalks,
# left = peg blank, right = peg tab painted as a claw stub. Coral shell mottling + a dark crack from the 5-4 cell.
SHELL = K.ramp('#f0805a')
DEEP = K.ramp('#d0503a')
CLAW = K.ramp('#e0603e')
STALK = K.ramp('#e87050')
SEA = K.ramp('#2a8a9a')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(6, 16, 50, 56)(x, y) and not (x > 46 and y > 52 and (x - 46) ** 2 + (y - 52) ** 2 > 16) \
        and not (x < 10 and y > 52 and (x - 10) ** 2 + (y - 52) ** 2 > 16)
    tab_r = K.knob('T', 'peg', 50, 36, 1, 0, r=5.2 * k)
    blank_t = K.knob('B', 'peg', 28, 16, 0, -1, r=4.2 * k)
    blank_l = K.knob('B', 'peg', 6, 38, -1, 0, r=4.2 * k)
    stalkL = K.thick_path([(17, 18), (15, 9)], 3.4 if c.small else 3.0)
    stalkR = K.thick_path([(39, 18), (41, 9)], 3.4 if c.small else 3.0)
    ballL, ballR = K.ell(15, 8, 4.8, 4.8), K.ell(41, 8, 4.8, 4.8)
    body = c.m(core, minus=(blank_t, blank_l))
    c.add(body, SHELL, stitch=None if c.small else '#c84a32')
    c.add(c.m(stalkL, stalkR, minus=(blank_t,)), STALK)
    c.add(c.m(ballL, ballR), K.ramp('#f4f0e4'))
    claw = c.m(tab_r, minus=(core,))
    c.add(claw, CLAW)
    # pincer notch on the claw tip
    c.cut |= c.m(K.poly([(64, 32.5), (56.5, 36), (64, 39.5)]))
    c.edge(c.m(K.rect(50, 30, 54, 42)) & claw, CLAW[1])
    # sea band along the flat bottom (picture's water)
    sea = c.m(K.rect(6, 49, 50, 56), minus=(blank_l,)) & body
    c.add(sea, SEA)
    c.edge(sea, SEA[1])
    for i, x in enumerate(range(8, 50, 6)):
        c.line([(x, 51), (x + 3, 50)], SEA[2])
    # shell mottling
    for (cx, cy, rx, ry) in ((14, 26, 4, 3), (42, 24, 4, 3.5), (40, 43, 5, 3), (13, 44, 3, 2.5)):
        c.add(c.m(K.ell(cx, cy, rx, ry), minus=(blank_l, blank_t)) & body, DEEP)
    # crack (the splinter)
    w = 'line'
    c.line([(46, 18), (42, 22), (45, 26), (41, 30)], '#7a2a1a')
    # face
    c.eye(15, 8.5, look=(1, 0))
    c.eye(41, 8.5, look=(-1, 0))
    c.smile(28, 34, wide=True)
    c.blush(19, 32)
    c.blush(36, 32)

K.render_pal(fn, 'pl-hcr-2', 'Shell Splinter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hcr-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hcr-2.png')
