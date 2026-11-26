# Concept: a plump yellow-orange fish that is a corner piece: flat top and flat left sides (snout at the left), keyhole TAB on the right
# is the tail fin, keyhole TAB at the bottom is the belly fin; colours from cell 1-3 (yellow #ffb03a fish, orange #ff8a2a tail, sea-teal bubble).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BODY = K.ramp('#ffb03a')
FIN = K.ramp('#ff8a2a')
BELLY = K.ramp('#ffd089')
SEA = '#2a98b8'
SEAL = '#62b9ca'


def rr(x0, y0, x1, y1, r, rl):
    # left (snout) corners rounder than the right ones
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        for cx, cy, rad in ((x0 + rl, y0 + rl, rl), (x0 + rl, y1 - rl, rl), (x1 - r, y0 + r, r), (x1 - r, y1 - r, r)):
            if (x - cx) * (1 if cx > x0 + 20 else -1) > 0 and (y - cy) * (1 if cy > y0 + 18 else -1) > 0 and (x - cx) ** 2 + (y - cy) ** 2 >= rad * rad:
                return False
        return True
    return f


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rr(5, 11, 45, 47, 4, 11)
    tail = K.knob('T', 'keyhole', 45, 29, 1, 0, r=6.5 * s, nw=3.0)
    fin = K.knob('T', 'keyhole', 31, 47, 0, 1, r=6.0 * s, nw=3.4)
    notch = K.poly([(60, 24), (54.5, 29), (60, 34)])   # forked tail
    body = c.m(core)
    c.add(c.m(tail, minus=(notch,)), FIN)
    c.add(c.m(fin), FIN)
    c.add(body, BODY, stitch=None if c.small else '#e08a20')
    # belly band and dorsal orange stripe
    c.add(c.m(lambda x, y: core(x, y) and y > 38 and x > 9), BELLY)
    dors = c.m(lambda x, y: core(x, y) and y < 16 and 16 < x < 40)
    c.add(dors, FIN)
    # gill arc
    g = [(19, 15), (21.5, 22), (22, 29), (21.5, 36), (19, 43)]
    c.line(g, '#e07a1a')
    if not c.small:
        c.line([(p[0] + 1, p[1]) for p in g], FIN[1])
    # scales: little arcs behind the gill
    sc = [(28, 22), (35, 22), (31.5, 29), (38.5, 29), (28, 36), (35, 36)] if not c.small else [(30, 22), (37, 30), (30, 36)]
    for (x, y) in sc:
        px, py = c.P(x, y)
        c.px(px, py, BODY[1]); c.px(px + 1, py + 1, BODY[1]); c.px(px - 1, py + 1, BODY[1])
        if not c.small:
            c.px(px + 2, py + 2, BODY[1]); c.px(px - 2, py + 2, BODY[1])
    # tail rays
    if not c.small:
        c.line([(48, 29), (53, 27)], FIN[1]); c.line([(48, 31), (53, 33)], FIN[1])
        c.line([(31, 50), (31, 58)], FIN[1]); c.line([(28.5, 51), (27.5, 57)], FIN[1]); c.line([(33.5, 51), (34.5, 57)], FIN[1])
    # sea bubble glints (picture motif) on the body upper right
    bx, by = c.P(39, 18)
    for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)) if not c.small else ((0, 0), (1, 0), (0, 1), (1, 1)):
        c.px(bx + dx, by + dy, SEA)
    if not c.small:
        c.px(bx, by, SEAL); c.px(bx + 1, by, '#f4f0e4'); c.px(bx, by + 1, SEAL); c.px(bx + 1, by + 1, SEAL)
    else:
        c.px(bx, by, SEAL)
    # face: eye and mouth near the snout (left)
    c.eye(13, 23, disc=True, look=(-1, 0))
    mx, my = c.P(7.5, 33)
    c.px(mx, my, K.UMBER); c.px(mx + 1, my, K.UMBER); c.px(mx + 2, my - 1, K.UMBER)
    if not c.small:
        c.px(mx + 3, my - 1, K.UMBER)
    c.blush(13, 32)


print(K.render_pal(fn, 'pl-sung-1', 'Sunnyfin Shoal', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-1-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-1.png'))
