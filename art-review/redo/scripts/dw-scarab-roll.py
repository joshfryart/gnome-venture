"""dw-scarab-roll: top-down scarab = edge-BTB keyhole piece. Keyhole tab N = head on its neck, keyhole blanks W/E bite the
teal wing cases, flat S = rear where it rolls a sand ball. Colours from cell 3-7: turquoise stripe, lamp gold, rug red + gold diamonds, sand."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

TEALR = K.ramp('#408fa0')
GOLDR = K.ramp('#e8a317')
REDR = K.ramp('#d6312b')
SAND = K.ramp('#e2a274')
LEG = K.ramp('#6a3a22')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(14, 21), (50, 21), (54, 25), (54, 60), (10, 60), (10, 25)])
    tabN = knob('T', 'keyhole', 32, 21, 0, -1, r=5.0, nw=4.4)
    headE = ell(32, 13, 10, 7.2)
    bW = knob('B', 'keyhole', 10, 41, -1, 0, r=4.6 * k)
    bE = knob('B', 'keyhole', 54, 41, 1, 0, r=4.6 * k)
    lw = 4.2 if not c.small else 4.6
    legs = [thick_path([(12, 25), (6, 23), (4, 17)], lw), thick_path([(52, 25), (58, 23), (60, 17)], lw),
            thick_path([(11, 54), (5, 57), (3, 62)], lw), thick_path([(53, 54), (59, 57), (61, 62)], lw),
            thick_path([(24, 9), (21, 5)], 2.8 if not c.small else 3.4), thick_path([(40, 9), (43, 5)], 2.8 if not c.small else 3.4),
            ell(20, 4.5, 2.6, 2.2), ell(44, 4.5, 2.6, 2.2)]
    c.add(c.m(*legs), LEG)
    body = c.m(core, minus=(bW, bE))
    # wing cases (teal) with a red rug rim
    c.add(body, REDR)
    inner = c.m(rect(12, 30, 52, 58), minus=(knob('B', 'keyhole', 10, 41, -1, 0, r=4.6 * k + 1.6),
                                              knob('B', 'keyhole', 54, 41, 1, 0, r=4.6 * k + 1.6)))
    el = c.add(inner & body, TEALR)
    # pronotum (gold) across the top of the core
    pro = c.add(c.m(ell(32, 22, 22, 9)) & c.m(core), K.ramp('#ed8a22'))
    c.edge(pro, '#a8601a')
    # head on the keyhole neck
    HEADR = K.ramp('#c88a1a')
    head = c.add(c.m(tabN, headE, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 19, 64, 22))), HEADR)
    c.edge(head, HEADR[1])
    # clypeus rake teeth at the front of the head
    for tx in (26, 30, 34, 38):
        c.px(*c.P(tx, 6.6), HEADR[1])
    # sand ball at the rear, clipped by the flat side
    ball = c.add(c.m(ell(32, 51.5, 7.5, 7.5)) & c.m(core), SAND)
    c.edge(ball, SAND[1])
    # seam down the wing cases
    c.line([(32, 31), (32, 44)], '#2a5a66')
    # shine on the wing cases
    c.line([(15.5, 33), (15.5, 35)] if not c.small else [(15.5, 33), (15.5, 34)], '#a6d4dc')
    c.line([(36, 33), (36, 35)] if not c.small else [(36, 33), (36, 34)], '#a6d4dc')
    # gold diamonds on the wing cases (rug motif)
    for dx, dy in ((17, 52), (47, 52), (25, 35), (39, 35)):
        cx, cy = c.P(dx, dy)
        s = 2 if not c.small else 1
        for yy in range(-s, s + 1):
            w = s - abs(yy)
            for xx in range(-w, w + 1):
                c.px(cx + xx, cy + yy, '#f5cf6a')
    # ball texture
    if not c.small:
        for (x, y) in [(29, 49), (34, 52), (30, 54), (35, 48)]:
            c.px(*c.P(x, y), SAND[1])
    # face on the head
    c.eye(27.5, 12)
    c.eye(36.5, 12)
    if not c.small:
        c.blush(24, 15)
        c.blush(39, 15)
    c.smile(32, 15)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'dw-scarab-roll', 'Scarab Roll', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/dw-scarab-roll-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/dw-scarab-roll.png')
    print(rep)
