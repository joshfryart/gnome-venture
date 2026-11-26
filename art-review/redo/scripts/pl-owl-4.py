# Owlet Peep: a sleepy lavender owlet that is an inner piece (TTTT, double knobs). Top double tab = the two ear tufts,
# left/right double tabs = folded wing tips, bottom double tab = two tan talons. Motif from den-of-the-great-white-owl
# cell 5-7: lavender snow, tan mushroom caps at the tree foot; owl's grey-violet plumage and amber eyes from the picture.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PLUM = K.ramp('#9288b8')     # owl plumage
WING = K.ramp('#665a92')
BELLY = K.ramp('#d4d0ec')    # snow-lavender belly
SNOW = ('#f4ecf4', '#c8bcd8', '#ffffff')
TAN = K.ramp('#c8b4a0')      # mushroom caps
AMBER, ORANGE = '#f0c030', '#e08a35'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 14, 51, 50)
    rnd = lambda x, y: core(x, y) and not any(((x - cx) ** 2 + (y - cy) ** 2 > 16 and abs(x - cx) < 4 and abs(y - cy) < 4 and (x - cx) * (cx - 32) > 0 and (y - cy) * (cy - 32) > 0) for cx, cy in ((17, 18), (47, 18), (17, 46), (47, 46)))
    tT = K.knob('T', 'double', 32, 14, 0, -1, r=7 * s, nw=3.2)
    tB = K.knob('T', 'double', 32, 50, 0, 1, r=5.5 * s)
    tL = K.knob('T', 'double', 13, 36, -1, 0, r=5.5 * s)
    tR = K.knob('T', 'double', 51, 36, 1, 0, r=5.5 * s)
    body = c.m(rnd, tT, tL, tR)
    c.add(body, PLUM, stitch='#b8aed0')
    # ear tufts darker
    c.add(c.m(tT, minus=(core,)), WING)
    # wings: side panels + side tabs
    wl = c.m(K.ell(14, 36, 6, 13), tL) & body
    wr = c.m(K.ell(50, 36, 6, 13), tR) & body
    c.add(wl, WING)
    c.add(wr, WING)
    c.edge(wl, PLUM[1])
    c.edge(wr, PLUM[1])
    # belly with chevron feather marks
    belly = c.m(K.ell(32, 40, 11, 10)) & body
    c.add(belly, BELLY)
    if not c.small:
        for yy in (36, 41, 46):
            for xx in (26, 32, 38):
                if (xx - 32) ** 2 / 121 + (yy - 40) ** 2 / 90 < 0.8:
                    c.line([(xx - 2, yy), (xx, yy + 1.5), (xx + 2, yy)], PLUM[0])
    else:
        for xx, yy in ((28, 40), (35, 40), (31, 45)):
            c.line([(xx - 1.5, yy), (xx, yy + 1.6), (xx + 1.5, yy)], PLUM[0])
    # snow cap on the head (from the snowy den)
    cap = c.m(K.ell(18, 15, 5, 2.6), K.ell(46, 15, 5, 2.6)) & body
    c.add(cap, SNOW)
    # talons: bottom tab, tan like the mushroom caps
    feet = c.m(tB, minus=(core,))
    c.add(feet, TAN)
    # toe splits on the talons
    for tx in (29.5, 34.5):
        c.line([(tx, 56.5), (tx, 60)], TAN[1])
    # eyes: amber discs with orange ring, sleepy lids
    for ex in (24, 40):
        ring = c.m(K.ell(ex, 26, 6.2, 6.2))
        c.add(ring & body, ('#f4ecf4', '#c8bcd8', '#ffffff'))
        c.add(c.m(K.ell(ex, 26, 4.6, 4.6)), (AMBER, ORANGE, '#f8d860'))
        cx, cy = c.P(ex, 26)
        if c.small:
            for dx in range(-1, 2):
                c.px(cx + dx, cy - 1, PLUM[0])
                c.px(cx + dx, cy, PLUM[0])
            c.px(cx, cy + 1, K.UMBER)
            c.px(cx - 1, cy + 1, K.UMBER)
        else:
            for dx in range(-3, 4):
                for dy in range(-4, 0):
                    if dx * dx + (dy + 0.5) ** 2 < 16:
                        c.px(cx + dx, cy + dy, PLUM[0])
            for dx in range(-3, 4):
                c.px(cx + dx, cy, PLUM[1])
            for dx in range(-1, 2):
                c.px(cx + dx, cy + 1, K.UMBER)
                c.px(cx + dx, cy + 2, K.UMBER)
            c.px(cx - 1, cy + 1, K.CREAM)
    # beak
    bx, by = c.P(32, 30)
    beak = [(0, 0), (-1, 0), (1, 0), (0, 1)] if c.small else [(-1, 0), (0, 0), (1, 0), (-1, 1), (0, 1), (1, 1), (0, 2), (0, 3)]
    for dx, dy in beak:
        c.px(bx + dx, by + dy, ORANGE)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-owl-4', 'Owlet Peep', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-4.png'))
