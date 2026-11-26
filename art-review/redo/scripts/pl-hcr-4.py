# Whirl Pincer: a hurricane-crab inner piece (all four sides tri tabs = four pincer points), with a pincer claw
# curled clockwise at each corner (pinwheel whirl); crab coral-red from the picture, teal sea band + lilac storm swirl from cell 11-4.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math

CRAB = K.ramp('#e0603a')
CLAW = K.ramp('#c8402a')
SEA = K.ramp('#3a9ab0')
LIL = '#c9c2dc'
TIP = K.ramp('#f2c0a0')

def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 15, 15, 49, 49
    core = K.rect(x0, y0, x1, y1)
    tabs = [K.knob('T', 'tri', 32, y0, 0, -1, r=4.6 * s), K.knob('T', 'tri', x1, 32, 1, 0, r=4.6 * s),
            K.knob('T', 'tri', 32, y1, 0, 1, r=4.6 * s), K.knob('T', 'tri', x0, 32, -1, 0, r=4.6 * s)]
    claws, cuts = [], []
    for (cx, cy) in ((x0, y0), (x1, y0), (x1, y1), (x0, y1)):
        dx, dy = (cx - 32) / 17 / math.sqrt(2), (cy - 32) / 17 / math.sqrt(2)
        tx, ty = -dy, dx          # clockwise tangent
        ox, oy = cx + dx * 1.5, cy + dy * 1.5
        claws.append(K.ell(ox, oy, 8, 8))
        cuts.append(K.poly([(ox + tx * 0.5 - dx * 0.5, oy + ty * 0.5 - dy * 0.5),
                            (ox + tx * 10 + dx * 4.5, oy + ty * 10 + dy * 4.5),
                            (ox + tx * 10 - dx * 1.5, oy + ty * 10 - dy * 1.5)]))
    body = c.m(core, *tabs, minus=cuts)
    c.add(body, CRAB, stitch=CRAB[1])
    cl = c.m(*claws, minus=cuts)
    c.add(cl, CLAW)
    c.edge(cl & c.m(core), CLAW[1])
    # teal sea band across the lower body with a wave crest
    sea = c.m(lambda x, y: y > 40 + 1.6 * math.sin(x / 3.2) and y < y1 + 1) & body
    sea |= c.m(K.knob('T', 'tri', 32, y1, 0, 1, r=4.6 * s)) & body
    sea -= cl
    c.add(sea, SEA)
    # lilac storm swirl on the body (whirl)
    for (ax, ay) in ((24, 19), (34, 18), (42, 21)):
        c.line([(ax, ay), (ax - 1.6, ay + 3.2)], LIL)
    c.edge(sea, SEA[2])
    # eyes on stalks
    c.eye(26, 27, disc=True)
    c.eye(38, 27, disc=True)
    c.smile(32, 35 if not c.small else 34)
    c.blush(22, 33); c.blush(41, 33)

K.render_pal(fn, 'pl-hcr-4', 'Whirl Pincer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hcr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hcr-4.png')
