"""pl-wpea-4 Oysterbed Choir: inner-TTTT, double knobs. A shut oyster/scallop shell IS the piece: ribbed pearly upper valve fanning from
the hinge, pink lip seam where it sings, sand-cream lower valve. Top and bottom double tabs are shell lobes; the E/W double tabs are
orange coral fingers from the cell (8-6: orange coral on sand under blue water)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

SHELL = ramp('#ead4d8')
BAND = ramp('#d6a8bc')
LIP = ramp('#f08ca0')
SAND = ramp('#ebceb5')
CORAL = ramp('#ffa05a')
PEARL = '#fcf3f0'


def fn(c):
    k = 1.15 if c.small else 1.0
    import math

    def core(x, y):
        if not (13 <= x < 51 and 12 <= y < 51):
            return False
        # big rounded top corners (fan shoulders), small bottom corners
        for cx, cy, r in ((26, 25, 13), (38, 25, 13), (17, 47, 4), (47, 47, 4)):
            if ((x < cx and cx < 32) or (x > cx and cx > 32)) and ((y < cy and cy < 32) or (y > cy and cy > 32)):
                if (x - cx) ** 2 + (y - cy) ** 2 > r * r:
                    return False
        # scalloped crown: shallow dips between ribs on the top edge
        if (x - 32) ** 2 + (y - 46) ** 2 > 30 ** 2 * 0.9 or y < 22:
            a = math.atan2(x - 32, 46 - y)
            f = (a / (math.pi / 10)) % 1
            rr = 34.5 - 5.0 * ((f - 0.5) * 2) ** 2 if abs(x - 32) > 5 else 40
            if (x - 32) ** 2 + (y - 46) ** 2 > rr * rr:
                return False
        return True
    tN = knob('T', 'double', 32, 13, 0, -1, r=5.0 * k)
    tS = knob('T', 'double', 32, 51, 0, 1, r=5.0 * k)
    tW = knob('T', 'double', 13, 38, -1, 0, r=4.8 * k)
    tE = knob('T', 'double', 51, 38, 1, 0, r=4.8 * k)
    upper_p = lambda x, y: (core(x, y) or tN(x, y)) and y < 39
    upper = c.m(upper_p)
    c.add(upper, SHELL)
    # alternating rib bands fanning from the hinge
    band = c.m(lambda x, y: core(x, y) and y < 39 and int((math.atan2(x - 32, 46 - y) + 1.6) / (math.pi / 10)) % 2 == 0)
    c.add(band, BAND)
    c.edge(upper, SHELL[1])
    # coral fingers on E and W
    c.add(c.m(tW, minus=(core,)), CORAL)
    c.add(c.m(tE, minus=(core,)), CORAL)
    # lower valve (sand cream) with S tab
    lower = c.m(core, tS, minus=(rect(0, 0, 64, 41),))
    c.add(lower, SAND)
    # lip seam: wavy pink band
    lip = c.m(lambda x, y: core(x, y) and 38 <= y < 42 + (0.8 if (x // 3) % 2 else 0))
    c.add(lip, LIP)
    # lower valve ridges (horizontal)
    if not c.small:
        for yy in (45, 48):
            y = c.P(0, yy)[1]
            for x in range(c.P(17, 0)[0], c.P(47, 0)[0]):
                if (x, y) in lower:
                    c.px(x, y, SAND[1])
    # face: closed happy eyes (shut tight) and a singing O mouth in the lip with a pearl glint
    for ex in (24, 40):
        cx, cy = c.P(ex, 29)
        if not c.small:
            for dx, dy in ((-2, 1), (-1, 0), (0, -1), (1, 0), (2, 1)):
                c.px(cx + dx, cy + dy, K.UMBER)
        else:
            for dx, dy in ((-1, 1), (0, 0), (1, 0), (2, 1)):
                c.px(cx + dx, cy + dy, K.UMBER)
    c.blush(20.5, 32)
    c.blush(42, 32)
    mx, my = c.P(32, 40)
    if not c.small:
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                if abs(dx) + abs(dy) <= 3:
                    c.px(mx + dx, my + dy, K.UMBER)
        c.px(mx, my, PEARL); c.px(mx + 1, my, PEARL); c.px(mx, my + 1, PEARL); c.px(mx + 1, my + 1, '#d8c4cc')
    else:
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                c.px(mx + dx, my + dy, K.UMBER)
        c.px(mx, my, PEARL)
    # music note above the N tab? keep it inside: tiny bubble highlights on coral
    if not c.small:
        for (x, y) in ((c.P(6.5, 34)), (c.P(56.5, 34))):
            c.px(x, y, CORAL[2])


K.render_pal(fn, 'pl-wpea-4', 'Oysterbed Choir', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-4.png')
