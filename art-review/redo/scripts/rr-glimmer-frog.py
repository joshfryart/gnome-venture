import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

# whimsy-frog, hook: a squat front-facing frog that IS the piece. Eye domes at the top corners, hook tab E (curled front toe),
# hook blank W bites the flank, hook tab N between the eyes reads as a glowing crest. Foliage greens, window-gold glowing belly, bark ledge.
GREEN = ramp('#3f7a3a')
DGREEN = ramp('#2f6a32')
GLOW = ('#f5cf6a', '#d9a73a', '#fbe9b0')
BARK = ramp('#a99a7b')
ROOT = '/home/user/gnome-venture/'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 20, 50, 54)
    rcore = lambda x, y: core(x, y) and not ((x < 13 or x > 46) and (y > 50) and ((x - (13 if x < 30 else 46)) ** 2 + (y - 50) ** 2 > 16))
    eyeL = ell(17, 19, 8, 7.5)
    eyeR = ell(42, 19, 8, 7.5)
    tabE = knob('T', 'hook', 50, 40, 1, 0, r=5.6 * k, nw=3.2)
    tabN = knob('T', 'hook', 29.5, 20, 0, -1, r=4.8 * k, nw=3.0, flip=True)
    blankW = knob('B', 'hook', 9, 38, -1, 0, r=5.2 * k, nw=3.0)
    body = c.m(rcore, eyeL, eyeR, tabE, tabN, minus=(blankW,))
    c.add(body, GREEN, stitch=None if c.small else GREEN[1])
    # back stripes in the darker leaf green
    c.add(body & c.m(tabN), DGREEN)
    # glowing belly (the lit window)
    belly = c.m(ell(30, 45, 12.5, 8.5)) & body
    c.add(belly, GLOW)
    c.edge(belly, GLOW[1])
    # bark ledge the frog sits on (toes)
    ledge = c.m(rect(7, 54, 52, 60))
    c.add(ledge, BARK)
    for tx in (12, 17, 42, 47):
        c.add(c.m(ell(tx, 55.5, 3.2, 2.4)), DGREEN)
    # wide frog mouth
    y = c.P(0, 34)[1]
    x0, x1 = c.P(18, 0)[0], c.P(41, 0)[0]
    for x in range(x0, x1 + 1):
        dy = 1 if x0 + 2 < x < x1 - 2 else 0
        c.px(x, y + dy, K.UMBER)
    # glimmer spots
    spots = [(12, 28), (47, 28), (14, 44), (29.5, 25)] if not c.small else [(12, 29), (47, 29)]
    for sx, sy in spots:
        px, py = c.P(sx, sy)
        c.px(px, py, GLOW[2])
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(px + d[0], py + d[1], GLOW[0])
    # eyes on the domes
    c.eye(17, 19, disc=True, look=(1, 0))
    c.eye(42, 19, disc=True, look=(-1, 0))
    c.blush(15, 30)
    c.blush(43, 30)


K.render_pal(fn, 'rr-glimmer-frog', 'Glimmer Frog', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=ROOT + 'art-review/redo/_src/rr-glimmer-frog-cell.png',
             oldfile=ROOT + 'game/assets/img/puzzles/pals/rr-glimmer-frog.png')
