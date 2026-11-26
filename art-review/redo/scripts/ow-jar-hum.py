"""ow-jar-hum "Jar Hum": an ochre amphora that IS an inner-TBTB peg piece. Peg tab N = the jar's neck and lip, peg tab S = its foot,
peg blanks W and E bite into the belly below the handles. Ochre amphora + terracotta band from cell 8-7 (olive jars in the courtyard)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

OCHRE = K.ramp('#d8a854')
TERRA = K.ramp('#c7643a')
OLIVE = K.ramp('#6f8a3a')
CREAMB = '#f2e4c0'
SHADE = '#b07f3a'


def fn(c):
    k = 1.15 if c.small else 1.0
    # square-ish core with softened corners
    # jar belly: a wide ellipse clipped flat at top and bottom (rounded shoulders, tapering base, still a square-ish piece core)
    belly = K.ell(32, 31, 21.5, 27)
    box = K.rect(11, 17, 53, 55)
    core = lambda x, y: belly(x, y) and box(x, y)
    tabN = K.knob('T', 'peg', 32, 17, 0, -1, r=5.4 * k, nw=3.4)
    tabS = K.knob('T', 'peg', 32, 55, 0, 1, r=5.0 * k, nw=3.0)
    blkW = K.knob('B', 'peg', 11, 34, -1, 0, r=4.2 * k)
    blkE = K.knob('B', 'peg', 53, 34, 1, 0, r=4.2 * k)
    body = c.m(core, tabN, tabS, minus=(blkW, blkE))
    c.add(body, OCHRE, stitch=None if c.small else SHADE)
    # lip (top of the N peg) and foot ring (bottom of the S peg) in terracotta
    c.add(body & c.m(K.rect(0, 0, 64, 9.0 if not c.small else 9.5)), TERRA)
    c.add(body & c.m(K.rect(0, 62.0 if not c.small else 61.5, 64, 64)), TERRA)
    # shoulder band: terracotta with a cream wave
    band = body & c.m(K.rect(0, 22, 64, 27.5))
    c.add(band, TERRA)
    # handles: two ear loops from the neck to the shoulders (inner paint, wide enough for 36 px)
    hw = 2.8 if not c.small else 3.4
    for side in (-1, 1):
        pts = [(32 + side * 5, 12.5), (32 + side * 12, 12.5), (32 + side * 15, 17), (32 + side * 15, 22)]
        h = c.m(K.thick_path(pts, hw))
        c.add(h, TERRA)
    if not c.small:
        y0 = c.P(0, 24.5)[1]
        for x in range(c.P(15, 0)[0], c.P(49, 0)[0]):
            c.px(x, y0 + (1 if (x // 2) % 2 else 0), CREAMB)
    else:
        y0 = c.P(0, 24.5)[1]
        for x in range(c.P(15, 0)[0], c.P(49, 0)[0], 2):
            c.px(x, y0, CREAMB)
    # olive sprig painted on the belly (motif from the olive grove)
    if not c.small:
        c.line([(21, 51), (27, 48), (32, 47.5)], OLIVE[1])
        for (lx, ly) in ((22, 48.5), (25.5, 46), (28, 50), (30.5, 45.5)):
            cx, cy = c.P(lx, ly)
            for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (2, 0)):
                c.px(cx + dx, cy + dy, OLIVE[0])
        cx, cy = c.P(33.5, 47.5)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            c.px(cx + dx, cy + dy, '#4a5a2a')
    else:
        for (lx, ly) in ((22, 49), (26, 47.5), (30, 48.5)):
            cx, cy = c.P(lx, ly)
            c.px(cx, cy, OLIVE[1]); c.px(cx + 1, cy, OLIVE[0])
    # glaze highlight down the left of the belly (roundness)
    c.add(body & c.m(K.thick_path([(18, 30), (17, 38), (19, 46)], 2.2 if not c.small else 2.8)) - band, (OCHRE[2], OCHRE[2], OCHRE[2]))
    # face: humming, eyes closed-ish happy, round "o" mouth
    c.eye(25.5, 36)
    c.eye(38.5, 36)
    c.blush(22, 40.5)
    c.blush(41.5, 40.5)
    mx, my = c.P(32, 41.5)
    if not c.small:
        for dx, dy in ((0, 0), (1, 0), (-1, 1), (2, 1), (-1, 2), (2, 2), (0, 3), (1, 3)):
            c.px(mx + dx, my + dy, K.UMBER)
        c.px(mx, my + 1, '#8a3a20'); c.px(mx + 1, my + 1, '#8a3a20'); c.px(mx, my + 2, '#8a3a20'); c.px(mx + 1, my + 2, '#8a3a20')
    else:
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
            c.px(mx + dx, my + dy, K.UMBER)


if __name__ == '__main__':
    print(K.render_pal(fn, 'ow-jar-hum', 'Jar Hum', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/ow-jar-hum-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ow-jar-hum.png'))
