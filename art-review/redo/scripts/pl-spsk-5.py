# pl-spsk-5 "Brass Glimmer": inner-BBBB, round. A round-bellied brass bowl stuffed with cinnamon sticks IS the piece:
# N blank parts the cinnamon bundle in two, W/E blanks bite the brass belly (handle sockets), S blank is the arch of the foot ring.
# Belly band is the souk floor's red/orange checker (cell 0-7); gold dust glints on the sticks.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BRASS = K.ramp('#d9a033')
RIM = K.ramp('#f0c45a')
CIN = K.ramp('#9a5226')
CINL = K.ramp('#b8693a')
RED = K.ramp('#d05054')
ORG = K.ramp('#e8ac58')
DUST = '#fff0c0'


def fn(c):
    k = 1.15 if c.small else 1.0
    rimR = rect = K.rect
    belly = K.poly([(9, 25), (55, 25), (55, 44), (53.5, 48.5), (49, 52.5), (15, 52.5), (10.5, 48.5), (9, 44)])
    foot = K.rect(14, 51, 50, 57)
    sticks = [K.rect(x0, y0, x0 + 5, 27) for x0, y0 in ((10.5, 11), (16, 10), (21.5, 12), (37.5, 12), (43, 10), (48.5, 11))]
    caps = [K.ell(x0 + 2.5, y0 + 0.5, 2.5, 1.6) for x0, y0 in ((10.5, 11), (16, 10), (21.5, 12), (37.5, 12), (43, 10), (48.5, 11))]
    filler = K.rect(11, 14, 53, 27)
    bN = K.knob('B', 'round', 32, 11, 0, -1, r=4.6 * k)
    bS = K.knob('B', 'round', 32, 57, 0, 1, r=3.4 * k)
    bW = K.knob('B', 'round', 9, 39, -1, 0, r=4.2 * k)
    bE = K.knob('B', 'round', 55, 39, 1, 0, r=4.2 * k)
    cut = (bN, bS, bW, bE)
    # cinnamon bundle
    c.add(c.m(filler, *sticks, *caps, minus=cut), CIN)
    for i, (x0, y0) in enumerate(((10.5, 11), (16, 10), (21.5, 12), (37.5, 12), (43, 10), (48.5, 11))):
        m = c.m(sticks[i], caps[i], minus=cut)
        c.add(m, CINL if i % 2 else CIN)
        c.edge(m, CIN[1])
        # rolled-bark spiral on the cap
        cx, cy = c.P(x0 + 2.5, y0 + 0.5)
        c.px(cx, cy, CIN[1])
        if not c.small:
            c.px(cx + 1, cy, CIN[1])
    # brass belly + rim
    bm = c.m(belly, foot, minus=cut)
    c.add(bm, BRASS)
    c.add(c.m(K.rect(7, 23, 57, 28.5), minus=cut), RIM)
    c.edge(c.m(K.rect(7, 23, 57, 28.5), minus=cut), BRASS[1])
    # checker band from the souk floor
    band = c.m(K.rect(9, 41, 55, 49), minus=cut) & bm
    sq = 4.0 if not c.small else 4.6
    c.add({p for p in band if (int(p[0] / c.k / sq) + int(p[1] / c.k / sq)) % 2 == 0}, RED)
    c.add({p for p in band if (int(p[0] / c.k / sq) + int(p[1] / c.k / sq)) % 2 == 1}, ORG)
    c.edge(band, BRASS[1])
    # brass shine streak (polished metal)
    c.add(c.m(K.thick_path([(14, 31), (14, 35.5)], 2.2 if not c.small else 2.8), minus=cut), ('#fff0c0', '#f5cf6a', '#ffffff'))
    # foot ring
    fm = c.m(foot, minus=cut)
    c.add(fm, K.ramp('#b07a20'))
    # gold dust on the sticks
    for (x, y) in ((14, 18), (27, 16), (39, 20), (48, 16), (20, 22), (44, 23)):
        px, py = c.P(x, y)
        c.px(px, py, DUST)
    # face on the brass belly above the band
    c.eye(24, 33, disc=False)
    c.eye(40, 33, disc=False)
    c.smile(32, 34.5)
    c.blush(19, 35)
    c.blush(44, 35)


K.render_pal(fn, 'pl-spsk-5', 'Brass Glimmer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-spsk-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-spsk-5.png')
