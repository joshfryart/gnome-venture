"""pl-wpea-6 Whiskerwatch Diver (rare, whimsy-diver, keyhole).
Concept: an old brass-helmet diver whose round helmet dome + square suit is the piece; keyhole tab N = the pearl held up in a gloved fist,
keyhole tab W = the helmet's air valve, keyhole blank E bites the suit, flat S = the raft plank. Turquoise water suit + bubble porthole (cell 5-1),
snorkel orange brass, pearl lavender-white, deep cove blue trims."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

SUIT = ramp('#58d8dc')
TRIM = ramp('#2a9ac9')
BRASS = ramp('#e8902a')
GLASS = ramp('#d8fff8')
PEARL = ('#ece4f4', '#b8a8cc', '#ffffff')
SKIN = ramp('#f0b890')
BEARD = ('#f4f0e4', '#c9c5bc', '#ffffff')
PLANK = ramp('#b07a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 33, 52, 59)
    helm = ell(25, 21, 14.5, 13.5)
    tabN = knob('T', 'keyhole', 45.5, 33, 0, -1, r=6.0 * k, nw=2.0)
    tabW = knob('T', 'keyhole', 9, 46, -1, 0, r=4.4 * k)
    blankE = knob('B', 'keyhole', 52, 45, 1, 0, r=4.6 * k)
    body = c.m(core, helm, tabN, tabW, minus=(blankE,))
    c.add(body, SUIT, stitch=None if c.small else SUIT[2])
    # brass collar band and belt, cove-blue
    c.add(body & c.m(rect(0, 33, 64, 37)), BRASS)
    c.add(body & c.m(rect(0, 48, 64, 51)), TRIM)
    # air valve (W tab) brass
    c.add(c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(rect(7, 0, 10, 64))), BRASS)
    # glove arm + pearl (N tab)
    arm = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 31, 64, 34)))
    c.add(arm, TRIM)
    pr_ = 6.0 * k
    c.add(c.m(ell(45.5, 33 - pr_ - 2.1, pr_ * 0.86, pr_ * 0.86)), PEARL)
    gx, gy = c.P(44, 33 - pr_ - 3.4)
    c.px(gx, gy, '#ffffff')
    # helmet dome in brass
    c.add(c.m(helm, minus=(rect(0, 33, 64, 64),)), BRASS)
    # big round porthole with the bearded face in it
    pr = 9.5 if not c.small else 10
    port = c.m(ell(24, 21, pr, pr - 0.5))
    c.add(port, BRASS)
    c.edge(port, K.UMBER2)
    glass = c.m(ell(24, 21, pr - 1.4, pr - 1.9))
    c.add(glass, GLASS)
    face = c.m(ell(24, 21.5, pr - 2.8, pr - 3.3))
    c.add(face, SKIN)
    beard = c.m(lambda x, y: ell(24, 26, pr - 3, 6)(x, y) and y > 23) & face
    c.add(beard, BEARD)
    # moustache
    c.add(c.m(ell(22, 23.6, 2.8, 1.3), ell(26.4, 23.6, 2.8, 1.3)), BEARD)
    # rivets on the dome
    for (rx, ry) in ((13, 14), (37, 14), (11.5, 24), (38.5, 24), (24.5, 9.2)):
        x, y = c.P(rx, ry)
        c.px(x, y, BRASS[2])
    # bubbles rising from the valve onto the suit (cell motif)
    if not c.small:
        for (bx, by) in ((20, 43), (33, 41)):
            x, y = c.P(bx, by)
            for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
                c.px(x + dx, y + dy, GLASS[0])
            c.px(x, y, '#ffffff')
    else:
        x, y = c.P(22, 42)
        c.px(x, y, GLASS[0]); c.px(x + 1, y, GLASS[0])
    # raft plank (flat S)
    c.add(body & c.m(rect(0, 55, 64, 64)), PLANK)
    for px_ in (22, 36):
        x, _ = c.P(px_, 0)
        for y in range(c.P(0, 55.5)[1], c.n):
            if (x, y) in body:
                c.px(x, y, PLANK[1])
    c.eye(21.2, 19)
    c.eye(27.2, 19)
    if not c.small:
        c.blush(18.5, 22)
        c.blush(29, 22)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wpea-6', 'Whiskerwatch Diver', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-6.png'))
