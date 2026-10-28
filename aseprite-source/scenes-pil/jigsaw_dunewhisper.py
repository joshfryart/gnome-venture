"""Jigsaw picture: THE DUNEWHISPER (MENA). game/assets/img/jigsaw/dunewhisper.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_dunewhisper.py [outdir]
Dusk over the desert: a violet-to-amber sky with first stars, a crescent moon and rose cloud streaks; the rose-red canyon city carved in the far cliff
(left), whispering dunes with a camel caravan on the crest and a domed library-mosque silhouette; a mud-brick souk with a wind-catcher, a lit gate
and strings of lanterns; a spice stall with cones of spice under a striped awning (gnome merchant), a gnome pouring mint tea from on high; the Oasis
Well under date palms with a gnome hauling the bucket, a camel drinking at the pool, a camel resting in front; melons, a carpet, sweating clay jars,
desert sage and the friendly sand scarab rolling its ball across the rippled sand.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# ---- palette: deep violet, rose, amber sand, lantern yellow (+ dusk palm green and a teal accent)
SKYC = ['#2a1d4a', '#3d2a63', '#563a78', '#7a4580', '#a8527e', '#d06a78', '#e88a62', '#f2ac5a']
LANT = ramp('#ffd85a', '#e8a317', '#fff4c0')
SAND = ramp('#e2a273', '#c47c5e', '#f2c08a')
ADOBE = ramp('#d98f5c', '#a8603f', '#f2b884')
ADOBE2 = ramp('#c9706a', '#9a4a52', '#e8988a')
CANYON = ramp('#b8525a', '#8a3a50', '#d97a6a')
DARK = '#3b2440'
PALM = ramp('#5a8a4a', '#35603f', '#8ab060')
TRUNK = ramp('#8a5a3a', '#5c3a2a', '#b07a4a')
CAMEL = ramp('#c98a5a', '#9a5f3f', '#e8b07a')
TEAL = ramp('#3f8fa0', '#25637d', '#7ac0c8')
ROSE = ramp('#d06a78', '#a8527e', '#e88a8a')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff4d8')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
STONE = ramp('#b9a8a2', '#8a7a80', '#d8ccc2')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
SAFF = ramp('#f0b020', '#c98a14', '#f8dc6a')
HERB = ramp('#6a8a3a', '#4f6a2a', '#8ab060')
CLAY = ramp('#c47048', '#8a4a2a', '#e8986a')
MELON = ramp('#7ab55c', '#4f8a3a', '#a4c86a')
cv = new_canvas(SKYC[0])
r = rnd(1999)
r2 = rnd(313)


def shadow(x0, y0, x1, y1, col=None):
    cv.fill(ell(x0, y0, x1, y1), col or SAND['s'])


def catenary(x0, y0, x1, y1, sag, n=24):
    pts = []
    for i in range(n + 1):
        t = i / n
        pts.append((round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t))))
    return pts


def lantern(x, y, glass=LANT):
    """A little hanging lantern: hook, cap, glowing body, finial; a hard 4-dot glow round it."""
    cv.dots([(x - 3, y + 3), (x + 3, y + 3), (x, y - 2), (x, y + 8)], '#e8a317' if glass is LANT else glass['s'])
    o = cv.obj()
    o.part(rect(x - 1, y + 1, x + 1, y + 5) | rect(x - 2, y + 2, x + 2, y + 4), glass, d=1)
    o.draw()
    cv.fill(rect(x - 1, y, x + 1, y), '#4a2c1a')
    cv.dots([(x, y + 3)], '#fff4c0')
    cv.dots([(x, y + 6)], '#4a2c1a')


def awning(x0, x1, y0, y1, ca, cb, w=4):
    """Striped awning sloping toward the viewer, scalloped hem."""
    m = poly([(x0, y0), (x1, y0), (x1 + 3, y1), (x0 - 3, y1)])
    hem = blank()
    for sx in range(x0 - 3, x1 + 3, w * 2):
        hem |= ell(sx, y1 - 2, sx + w * 2 - 1, y1 + 3)
    m |= hem & rect(x0 - 3, y1, x1 + 3, y1 + 3)
    o = cv.obj()
    o.part(m, ca, d=1)
    o.draw()
    ys = np.arange(H)[:, None]
    xs = np.arange(W)[None, :]
    # stripes fan out a little toward the hem
    t = np.clip((ys - y0) / max(1, y1 - y0), 0, 1)
    u = (xs - (x0 - 3 * t)) / ((x1 - x0) + 6 * t) * ((x1 - x0) / w)
    stripes = m & ((np.floor(u).astype(int) % 2) == 1) & ~(dil4(~m))
    cv.fill(stripes, cb['b'])
    cv.fill(m & ~shift(m, 0, -1) & ~dil4(~shift(m, 0, -2)), ca['s'])
    cv.fill(m & rect(0, y0, W, y0) & ~dil4(~m), ca['r'])


def gnome(gx, gy, hat, tunic, hh=19, beard=BEARD):
    """Gnome standing with feet at (gx, gy): boots, tunic, belt, beard, face, tall hat (tip leaning back)."""
    o = cv.obj()
    o.part(rect(gx - 7, gy - 3, gx - 2, gy) | rect(gx + 1, gy - 3, gx + 6, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - 7, gy - 16, gx + 7, gy - 3, 2), tunic, d=2, contour=True)
    o.part(rect(gx - 7, gy - 7, gx + 7, gy - 6), ramp('#7a4a1f', '#5c3420'), d=0)
    o.part(poly([(gx - 7, gy - 20), (gx + 7, gy - 20), (gx + 1, gy - 6)]), beard, d=1, contour=True)
    o.part(rect(gx - 5, gy - 25, gx + 5, gy - 19), SKIN, d=1)
    o.part(poly([(gx - 8, gy - 23), (gx + 8, gy - 23), (gx - 4, gy - 23 - hh)]), hat, d=2, contour=True)
    o.draw()
    cv.fill(rect(gx - 8, gy - 24, gx + 8, gy - 23), hat['s'])
    cv.dots([(gx - 2, gy - 22), (gx + 2, gy - 22)], '#2a1a10')
    cv.dots([(gx, gy - 21), (gx + 1, gy - 21), (gx, gy - 20), (gx + 1, gy - 20)], '#e0907a')
    cv.dots([(gx - 4, gy - 20), (gx + 4, gy - 20)], '#f0a0a0')
    cv.fill(rect(gx - 1, gy - 7, gx + 1, gy - 6), '#f5cf6a')
    cv.dots([(gx - 6, gy - 14), (gx - 6, gy - 13)], tunic['r'])


def palm(bx, by, cx, cy, fronds, seed):
    """Date palm: ringed trunk along a curve from (bx, by) up to the crown (cx, cy), drooping fronds with leaflets, date clusters."""
    rp = rnd(seed)
    trunk = blank()
    n = max(8, abs(by - cy) // 3)
    pts = []
    for i in range(n + 1):
        t = i / n
        x = bx + (cx - bx) * t + (cx - bx) * 0.35 * 4 * t * (1 - t) * 0  # straight-ish
        x = bx + (cx - bx) * (t ** 1.6)
        y = by + (cy - by) * t
        w = 4 - 2 * t
        pts.append((x, y))
        trunk |= ell(round(x - w), round(y - 2), round(x + w), round(y + 2))
    o = cv.obj()
    o.part(trunk, TRUNK, d=2)
    o.draw()
    for i in range(1, n, 1):   # ring scars
        x, y = pts[i]
        if i % 2:
            cv.fill(line([(round(x - 2), round(y)), (round(x + 2), round(y + 1))]) & trunk, TRUNK['s'])
        else:
            cv.dots([(round(x - 2), round(y))], TRUNK['r'])
    m = blank()
    for ang, ln, droop in fronds:
        import math
        dx, dy = math.cos(math.radians(ang)), math.sin(math.radians(ang))
        p1 = (cx + dx * ln * 0.5, cy + dy * ln * 0.45 - 2)
        p2 = (cx + dx * ln, cy + dy * ln * 0.45 + droop)
        m |= line([(cx, cy), (round(p1[0]), round(p1[1])), (round(p2[0]), round(p2[1]))], 2)
        for k in range(2, 9):   # leaflets hanging off the rib
            t = k / 9
            if t < 0.5:
                px, py = cx + (p1[0] - cx) * t * 2, cy + (p1[1] - cy) * t * 2
            else:
                px, py = p1[0] + (p2[0] - p1[0]) * (t - 0.5) * 2, p1[1] + (p2[1] - p1[1]) * (t - 0.5) * 2
            lx = 3 if dx >= 0 else -3
            m |= line([(round(px), round(py)), (round(px + lx * 0.6), round(py + 4 + t * 3))])
            m |= line([(round(px), round(py)), (round(px - lx * 0.7), round(py + 3 + t * 2))])
    o = cv.obj()
    o.part(m, PALM, d=1)
    o.draw()
    ys, xs = np.nonzero(m & shift(m, 1, 0))
    for _ in range(len(xs) // 14):
        i = rp(0, len(xs) - 1)
        cv.dots([(int(xs[i]), int(ys[i]))], PALM['r'] if rp(0, 2) else PALM['r'])
    for k in range(3):   # date clusters under the crown
        ddx = (-5, 2, 7)[k]
        for j in range(6):
            cv.dots([(cx + ddx + rp(-2, 2), cy + 3 + rp(0, 4))], ('#e8a317', '#c47048', '#a8603f')[j % 3])
    return pts


# ================================================================ SKY: hard bands with wavy edges, stars, moon, cloud streaks, swifts
edges = [0, 20, 34, 46, 56, 64, 71, 78]
for i in range(1, len(SKYC)):
    yb = edges[i]
    pts = [(-1, H)]
    x = -1
    while x < W + 10:
        pts.append((x, yb + r(-2, 2)))
        x += r(10, 22)
    pts.append((W + 10, H))
    cv.fill(poly(pts), SKYC[i])
for _ in range(110):   # stars, thinner toward the glow
    sx, sy = r(0, W - 1), r(0, 54)
    if sy > 38 and r(0, 2):
        continue
    cv.dots([(sx, sy)], ('#fff4d8', '#f5cf6a', '#c3b2ea', '#fff4d8')[r(0, 3)])
for sx, sy in ((92, 8), (150, 20), (204, 6), (128, 34), (60, 30), (236, 32), (178, 42), (18, 44), (110, 14)):   # bright twinkles
    cv.dots([(sx, sy), (sx - 1, sy), (sx + 1, sy), (sx, sy - 1), (sx, sy + 1)], '#fff4c0')
    cv.dots([(sx - 2, sy), (sx + 2, sy), (sx, sy - 2), (sx, sy + 2)], '#c3b2ea')
moon = ell(20, 6, 40, 26) & ~ell(26, 2, 46, 22)   # crescent moon (upper left = the light)
cv.fill(dil4(dil4(moon)) & ~moon, SKYC[1])
cv.fill(moon, '#fff0c0')
cv.fill(moon & ~shift(moon, -1, -1), '#f5cf6a')
cv.dots([(46, 24), (45, 24), (47, 24), (46, 23), (46, 25)], '#fff4c0')   # evening star beside it
for cx, cy, w in ((70, 50, 46), (150, 58, 60), (232, 46, 40), (26, 64, 34), (198, 68, 44), (110, 72, 36), (272, 62, 30), (180, 40, 28)):
    m = rrect(cx - w // 2, cy, cx + w // 2, cy + 3, 1) | rrect(cx - w // 3, cy - 2, cx + w // 6, cy + 1, 1)
    cv.fill(m, '#e88a8a')
    cv.fill(m & ~shift(m, 0, 1), '#f5b06a')   # lit top edge
    cv.fill(m & ~shift(m, 0, -1), '#8a4a7a')  # violet underside
for bx, by in ((120, 44), (126, 41), (132, 45), (214, 26), (220, 29), (58, 70), (260, 50), (266, 47)):   # swifts
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], SKYC[0])

# ================================================================ FAR: rose-red canyon city (left), dunes, library-mosque, caravan
cliff = poly([(0, 52), (14, 50), (22, 56), (40, 54), (52, 62), (60, 76), (66, 104), (0, 104)])
o = cv.obj(outline=False)
o.part(cliff, CANYON, d=3)
o.draw()
for yy in range(58, 104, 6):   # strata
    cv.fill(cliff & line([(0, yy), (70, yy + 3)]), CANYON['s'])
fac = rect(8, 62, 30, 88)   # carved temple front: pediment, columns, dark door
cv.fill(fac, CANYON['r'])
cv.fill(poly([(6, 63), (32, 63), (19, 55)]), CANYON['r'])
cv.fill(poly([(9, 62), (29, 62), (19, 57)]), CANYON['b'])
for cx in (10, 15, 23, 28):
    cv.fill(rect(cx, 66, cx + 1, 86), CANYON['b'])
cv.fill(rect(17, 72, 21, 86), DARK)
cv.fill(rect(18, 74, 20, 80), '#e8a317')
for dx, dy in ((38, 66), (46, 74), (36, 82), (52, 88), (4, 94), (42, 94)):   # cave doorways, some lit
    cv.fill(rect(dx, dy, dx + 3, dy + 5) | rect(dx + 1, dy - 1, dx + 2, dy - 1), DARK)
    if (dx + dy) % 3 == 0:
        cv.fill(rect(dx + 1, dy + 2, dx + 2, dy + 4), '#ffd85a')
dune1 = poly([(40, 96), (90, 80), (140, 88), (200, 76), (250, 86), (300, 78), (300, 112), (40, 112)])
cv.fill(dune1, '#7a4a80')
cv.fill(dune1 & ~shift(dune1, 4, 3), '#a8608a')   # lit crests
for _ in range(36):   # wind ripples
    px, py = r(44, 296), r(80, 108)
    if dune1[py, px]:
        cv.fill(line([(px, py), (px + r(4, 8), py + 1)]) & dune1, '#6a3f76')
# library-mosque silhouette with lit arched windows
mq = rect(140, 82, 192, 104) | ell(148, 66, 172, 92) | rect(158, 60, 160, 66) | rect(184, 48, 190, 104) | rect(182, 60, 192, 62) | ell(183, 43, 191, 51) | rect(174, 74, 182, 84)
cv.fill(mq, '#4a3366')
cv.fill(mq & ~shift(mq, -1, 0) & rect(0, 0, 165, H), '#5e4380')   # left rim catching the glow
cv.dots([(159, 58), (158, 57), (160, 57), (187, 41)], '#f5cf6a')   # finials
for wx in (144, 152, 160, 168, 176):
    cv.fill(rect(wx, 90, wx + 3, 96) | rect(wx + 1, 89, wx + 2, 89), '#ffd85a')
cv.fill(rect(186, 66, 188, 72), '#ffd85a')
cv.fill(rect(186, 54, 188, 56), '#e8a317')
for cx in range(242, 300, 13):   # camel caravan silhouette on the crest
    cy = 84 + (cx % 3)
    cam = ell(cx, cy, cx + 8, cy + 4) | ell(cx + 2, cy - 2, cx + 6, cy + 2) | line([(cx + 8, cy + 1), (cx + 10, cy - 3)], 2)
    for lx in (cx + 1, cx + 3, cx + 6, cx + 7):
        cam |= rect(lx, cy + 4, lx, cy + 8)
    cv.fill(cam, '#3d2a63')
    cv.dots([(cx + 4, cy - 3)], '#d06a78')   # saddle cloth
dune2 = poly([(0, 104), (60, 96), (120, 102), (190, 94), (260, 104), (300, 98), (300, 124), (0, 124)])
cv.fill(dune2, '#b86a70')
cv.fill(dune2 & ~shift(dune2, 3, 2), '#d9867a')
for _ in range(30):
    px, py = r(2, 296), r(98, 120)
    if dune2[py, px]:
        cv.fill(line([(px, py), (px + r(4, 9), py + 1)]) & dune2, '#9a5a64')

# ================================================================ GROUND: amber sand with ripples, the path in
ground = rect(0, 116, W - 1, H - 1)
cv.fill(ground, SAND['b'])
cv.fill(rect(0, 116, W - 1, 130), '#d08a6a')
for y in range(118, H, 3):
    for _ in range(7):
        px = r(0, W - 1)
        ln = r(3, 9)
        cv.fill(rect(px, y, px + ln, y), SAND['s'] if y < 130 or r(0, 1) else '#9a5a64')
        cv.fill(rect(px + 1, y - 1, px + ln - 1, y - 1), SAND['r'])
path = poly([(120, 138), (140, 138), (152, 152), (168, 168), (186, 186), (196, 199), (146, 199), (140, 184), (130, 162), (122, 150)])
cv.fill(path, '#f2c08a')
cv.fill(path & ~shift(path, -2, 0), '#e2a273')
cv.fill(path & ~shift(path, 2, 0), '#f8d8a8')
for k in range(9):   # footprints up the path
    fy = 194 - k * 6
    fx = 166 - k * 3 + (4 if k % 2 else 0)
    cv.dots([(fx, fy), (fx + 1, fy), (fx, fy - 2)], '#d99068')

# ================================================================ THE SOUK: mud-brick houses, wind-catcher, gate, awnings, lanterns
def house(x0, y0, x1, y1, rp, parapet=True):
    o = cv.obj()
    o.part(rect(x0, y0, x1, y1), rp, d=3)
    if parapet:
        for cx in range(x0, x1 - 2, 6):
            o.part(rect(cx, y0 - 3, cx + 3, y0), rp, d=1)
    o.draw()
    for _ in range((x1 - x0) * (y1 - y0) // 70):   # mud-brick texture: little brick dashes, straw flecks
        bx, by = r(x0 + 2, x1 - 4), r(y0 + 2, y1 - 2)
        cv.fill(rect(bx, by, bx + 2, by), rp['s'])
    cv.fill(rect(x0 + 1, y0 + 4, x1 - 1, y0 + 4), rp['s'])
    for bx in range(x0 + 4, x1 - 2, 9):   # roof beam ends poking out
        cv.dots([(bx, y0 + 6), (bx + 1, y0 + 6)], '#5c3a2a')


house(0, 78, 34, 140, ADOBE)
o = cv.obj()   # wind-catcher tower
o.part(rect(8, 52, 22, 80), ADOBE, d=2)
o.part(rect(6, 50, 24, 53), ADOBE2, d=1)
o.draw()
for sx in (11, 15, 19):
    cv.fill(rect(sx, 56, sx + 1, 66), DARK)
cv.dots([(12, 70), (13, 70), (17, 74)], ADOBE['s'])
house(30, 90, 72, 140, ADOBE2)
house(68, 74, 110, 140, ADOBE)
house(106, 94, 152, 142, ADOBE2)
# windows and doors
for wx, wy, lit in ((6, 92, True), (20, 100, False), (40, 98, True), (56, 98, True), (78, 84, True), (94, 84, False), (84, 100, True)):
    o = cv.obj()
    o.part(rect(wx, wy + 2, wx + 6, wy + 9) | rect(wx + 1, wy + 1, wx + 5, wy + 1) | rect(wx + 2, wy, wx + 4, wy), ramp('#ffd85a', '#e8a317', '#fff4c0') if lit else ramp(DARK, '#2a1a10'), d=1)
    o.draw()
    cv.fill(rect(wx + 3, wy + 1, wx + 3, wy + 9), '#4a2c1a' if lit else '#2a1a10')
    cv.fill(rect(wx - 1, wy + 10, wx + 7, wy + 10), '#5c3a2a')
cv.fill(rect(20, 101, 26, 101), TEAL['b'])   # teal shutter edge
for dx, dy in ((92, 92), (50, 86)):   # potted plants on the sills / roof
    cv.fill(rect(dx, dy - 1, dx + 3, dy + 1), CLAY['b'])
    cv.dots([(dx, dy - 2), (dx + 2, dy - 3), (dx + 3, dy - 2), (dx + 1, dy - 3)], PALM['b'])
# souk gate: tall horseshoe arch with a lit lane and lanterns inside
gate = ell(116, 100, 144, 126) | rect(116, 113, 144, 142)
gate_in = ell(119, 103, 141, 123) | rect(119, 113, 141, 142)
o = cv.obj()
o.part(gate & ~gate_in, TEAL, d=1)
o.draw()
cv.fill(gate_in, '#ffb84a')
cv.fill(gate_in & rect(0, 126, W, H), '#e8a317')
cv.fill(gate_in & rect(0, 134, W, H), '#c47048')
for k in range(4):
    cv.fill(gate_in & rect(122 + k * 5, 118 + k, 123 + k * 5, 133 - k), '#a8603f')   # far stalls in the lane
for lx in (124, 136, 130):
    lantern(lx, 106 + (lx % 7))
cv.fill(gate & ~gate_in & ~shift(gate, 0, -1) & ~dil4(~gate) & rect(0, 0, W, 112), TEAL['r'])
for k in range(0, 26, 4):   # tile band round the arch
    cv.dots([(116 + k, 98)], '#f5cf6a')
cv.fill(rect(114, 97, 146, 97), TEAL['s'])
# carpets hanging over the parapets
for cx0, cy0, w, h, base, band in ((36, 87, 10, 16, RED, TEAL), (88, 71, 12, 12, TEAL, ROSE)):
    o = cv.obj()
    o.part(rect(cx0, cy0, cx0 + w, cy0 + h), base, d=1)
    o.draw()
    cv.fill(rect(cx0 + 2, cy0 + 2, cx0 + w - 2, cy0 + h - 2), band['b'])
    cv.fill(rect(cx0 + 4, cy0 + 4, cx0 + w - 4, cy0 + h - 4), '#f5cf6a')
    cv.dots([(cx0 + w // 2, cy0 + h // 2)], base['s'])
    for fx in range(cx0, cx0 + w + 1, 2):
        cv.dots([(fx, cy0 + h + 1)], '#f2e4c0')
# shop-front awnings along the street
awning(2, 30, 116, 124, ROSE, CREAM)
awning(72, 104, 120, 128, TEAL, CREAM)
for ax in (0, 32, 70, 106):
    cv.fill(rect(ax, 128, ax + 1, 140), '#5c3a2a')
# lantern strings across the lanes
for (xa, ya, xb, yb, sag) in ((14, 50, 70, 74, 10), (34, 88, 68, 74, 6), (110, 76, 186, 52, 22), (152, 96, 218, 98, 12)):
    pts = catenary(xa, ya, xb, yb, sag)
    cv.fill(line(pts), '#3d2a1c')
    for k in range(2, len(pts) - 1, 4):
        lantern(pts[k][0], pts[k][1] + 1, (LANT, ROSE, LANT, TEAL)[k // 4 % 4])

# ================================================================ OASIS: palms, well, pool, camels
p2 = palm(214, 134, 224, 68, ((180, 40, 10), (205, 38, 4), (235, 30, -4), (300, 30, -4), (330, 36, 4), (355, 40, 10), (160, 32, 14), (20, 32, 14), (270, 16, -2)), 5)
pool = ell(204, 140, 300, 178) | rect(260, 150, 299, 170)
cv.fill(dil4(dil4(dil4(pool))) & ~pool, PALM['s'])   # grassy bank
cv.fill(dil4(dil4(pool)) & ~pool, PALM['b'])
cv.fill(pool, '#45306a')
for k, (yy, col) in enumerate(((150, '#a8527e'), (156, '#d06a78'), (162, '#e88a62'), (168, '#f2ac5a'), (172, '#d06a78'))):   # sky glow mirrored in bands
    for _ in range(6):
        px = r(206, 292)
        cv.fill(rect(px, yy + r(-1, 1), px + r(4, 12), yy) & pool & ~dil4(~pool), col)
cv.fill(pool & ~shift(pool, 0, 2), '#2a1d4a')   # dark far edge
for _ in range(14):
    px, py = r(210, 296), r(146, 176)
    if pool[py, px]:
        cv.dots([(px, py)], '#fff4d8')
for bx, by in ((206, 146), (212, 140), (290, 144), (270, 140), (300, 154), (236, 178), (296, 172)):   # tufts and reeds round the bank
    cv.dots([(bx, by), (bx - 1, by - 2), (bx + 1, by - 3), (bx + 2, by - 1), (bx, by - 4)], PALM['r'])
for rx, ry in ((280, 144), (284, 146), (288, 143), (210, 150)):
    cv.fill(rect(rx, ry - 10, rx, ry), PALM['s'])
    cv.fill(rect(rx - 1, ry - 13, rx + 1, ry - 9), '#7a4a1f')
# the Oasis Well: stone drum, wooden frame and pulley, bucket on a rope
o = cv.obj()
o.part(rect(232, 112, 234, 132) | rect(252, 112, 254, 132) | rect(230, 110, 256, 112), WOOD, d=1)
o.part(rrect(228, 122, 258, 140, 2), STONE, d=3)
o.part(ell(228, 118, 258, 126), STONE, d=1)
o.draw()
cv.fill(ell(231, 120, 255, 125), DARK)
for yy in (127, 132, 136):
    for xx in range(229 + (yy % 2) * 3, 257, 7):
        cv.fill(rect(xx, yy, xx, yy + 3), STONE['s'])
    cv.fill(rect(229, yy, 257, yy), STONE['s'])
cv.fill(ell(240, 109, 245, 114), '#7a4a1f')
cv.fill(rect(242, 113, 242, 121), '#c9a96e')
o = cv.obj()
o.part(rrect(239, 115, 246, 121, 1), WOOD, d=1)
o.draw()
cv.dots([(240, 116), (245, 116)], '#45306a')
# palm in front of the souk end (small) and the big palm on the right
palm(170, 150, 166, 112, ((190, 24, 8), (215, 22, 2), (250, 12, -2), (300, 22, 0), (330, 24, 6), (350, 26, 10), (160, 20, 12)), 9)
# gnome hauling the well rope
gnome(266, 140, ROSE, TEAL, hh=17)
cv.fill(line([(254, 112), (274, 124)]), '#c9a96e')
cv.fill(rect(273, 122, 276, 125), SKIN['b'])
# camel drinking at the pool (left bank), striped blanket
cx0, cy0 = 182, 140
o = cv.obj()
legs = blank()
for lx, ln in ((cx0 + 4, 0), (cx0 + 9, 1), (cx0 + 24, 0), (cx0 + 29, 1)):
    legs |= rect(lx, cy0 + 12, lx + 2, cy0 + 34 - ln) | rect(lx - 1, cy0 + 33 - ln, lx + 3, cy0 + 35 - ln)
o.part(legs, CAMEL, d=1)
o.part(ell(cx0, cy0, cx0 + 34, cy0 + 18), CAMEL, d=3)
o.part(ell(cx0 + 8, cy0 - 10, cx0 + 24, cy0 + 8), CAMEL, d=2)
o.part(line([(cx0 + 32, cy0 + 6), (cx0 + 38, cy0 + 12), (cx0 + 44, cy0 + 20)], 5), CAMEL, d=1)
o.part(ell(cx0 + 42, cy0 + 17, cx0 + 54, cy0 + 25), CAMEL, d=1)
o.part(ell(cx0 - 3, cy0 + 4, cx0 + 3, cy0 + 12), CAMEL, d=1)
o.draw()
bl = ell(cx0 + 4, cy0 - 4, cx0 + 28, cy0 + 14) & ~rect(0, 0, W, cy0 + 1)
cv.fill(bl, RED['b'])
cv.fill(bl & rect(0, cy0 + 5, W, cy0 + 6), TEAL['b'])
cv.fill(bl & rect(0, cy0 + 9, W, cy0 + 9), '#f5cf6a')
cv.fill(bl & ~shift(bl, 0, -1), RED['s'])
for fx in range(cx0 + 8, cx0 + 26, 3):
    cv.dots([(fx, cy0 + 12)], '#f5cf6a')
cv.dots([(cx0 + 47, cy0 + 19), (cx0 + 53, cy0 + 23)], '#2a1a10')
cv.dots([(cx0 + 44, cy0 + 17)], CAMEL['s'])
cv.fill(rect(cx0 + 40, cy0 + 26, cx0 + 58, cy0 + 26), '#e88a62')
cv.fill(rect(cx0 + 44, cy0 + 28, cx0 + 54, cy0 + 28), '#f2ac5a')   # ripple where it drinks
# the big palm, right edge (drawn over the pool bank)
palm(296, 156, 268, 28, ((150, 52, 18), (180, 50, 10), (205, 44, 2), (240, 30, -6), (290, 30, -8), (320, 40, 2), (345, 48, 12), (10, 40, 22), (165, 42, 26), (270, 20, -4)), 3)
# resting camel at the front right, a gnome-sized saddle pack beside it
rx0, ry0 = 232, 178
o = cv.obj()
o.part(ell(rx0, ry0 + 2, rx0 + 46, ry0 + 22), CAMEL, d=3)
o.part(ell(rx0 + 14, ry0 - 6, rx0 + 32, ry0 + 12), CAMEL, d=2)
o.part(line([(rx0 + 42, ry0 + 10), (rx0 + 48, ry0), (rx0 + 52, ry0 - 8)], 5), CAMEL, d=1)
o.part(ell(rx0 + 50, ry0 - 14, rx0 + 63, ry0 - 6), CAMEL, d=1)
o.part(rect(rx0 + 4, ry0 + 18, rx0 + 16, ry0 + 21) | rect(rx0 + 30, ry0 + 18, rx0 + 42, ry0 + 21), CAMEL, d=1, contour=True)
o.draw()
cv.dots([(rx0 + 57, ry0 - 12), (rx0 + 58, ry0 - 12)], '#2a1a10')
cv.dots([(rx0 + 62, ry0 - 9)], '#2a1a10')
cv.fill(rect(rx0 + 52, ry0 - 16, rx0 + 53, ry0 - 14), CAMEL['s'])   # ear
cv.fill(line([(rx0, ry0 + 10), (rx0 - 4, ry0 + 16)]), CAMEL['s'])   # tail
bl = ell(rx0 + 10, ry0 - 2, rx0 + 36, ry0 + 16) & ~rect(0, 0, W, ry0 + 1)
cv.fill(bl, TEAL['b'])
cv.fill(bl & rect(0, ry0 + 5, W, ry0 + 6), ROSE['b'])
cv.fill(bl & rect(0, ry0 + 10, W, ry0 + 10), '#f5cf6a')
for fx in range(rx0 + 12, rx0 + 36, 3):
    cv.dots([(fx, ry0 + 16)], '#f2e4c0')
cv.dots([(rx0 + 18, ry0 + 3), (rx0 + 28, ry0 + 3)], '#2a1a10')   # pompoms

# ================================================================ THE SPICE STALL (centre-left foreground)
gnome(92, 152, SAFF, ROSE, hh=12)   # merchant behind the counter
cv.fill(rect(100, 138, 103, 141), SKIN['b'])
cv.fill(rect(100, 134, 101, 138), '#c9a96e')   # holding up a scoop
o = cv.obj()
o.part(rect(44, 122, 46, 172) | rect(122, 122, 124, 172), WOOD, d=1)
o.draw()
awning(42, 126, 110, 122, RED, CREAM, w=5)
for k, hx in enumerate(x for x in range(52, 124, 9) if abs(x - 92) > 11):   # strings of dried limes, chillies and garlic under the awning
    for j in range(3):
        cv.dots([(hx, 126 + j * 3), (hx + 1, 126 + j * 3), (hx, 127 + j * 3)], (SAFF['b'], RED['b'], '#f2e4c0', HERB['b'])[(k + j) % 4])
    cv.fill(rect(hx, 124, hx, 125), '#3d2a1c')
o = cv.obj()
o.part(rect(40, 148, 128, 172), WOOD, d=3)
o.part(rect(38, 145, 130, 148), WOOD, d=1)
o.draw()
cv.fill(rect(44, 152, 124, 168), TEAL['b'])
for tx in range(48, 124, 8):   # tiled front panel: little eight-point stars
    for ty in (156, 164):
        cv.dots([(tx, ty), (tx - 1, ty), (tx + 1, ty), (tx, ty - 1), (tx, ty + 1)], '#f5cf6a')
        cv.dots([(tx - 2, ty - 2), (tx + 2, ty - 2), (tx - 2, ty + 2), (tx + 2, ty + 2)], TEAL['r'])
cv.fill(rect(44, 160, 124, 160), TEAL['s'])
for k, (sx, sp) in enumerate(((50, RED), (62, SAFF), (74, HERB), (112, ROSE), (124, CLAY))):   # spice cones in brass bowls
    if sx > 120:
        continue
    o = cv.obj()
    o.part(poly([(sx - 6, 145), (sx + 6, 145), (sx, 134 + (k % 2) * 2)]), sp, d=2)
    o.part(ell(sx - 7, 142, sx + 7, 148) & rect(0, 144, W, H), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=1)
    o.draw()
    cv.dots([(sx - 1, 137 + (k % 2) * 2), (sx - 2, 139 + (k % 2) * 2)], sp['r'])
# open sacks in front of the counter
for sx, sp in ((50, SAFF), (66, RED), (108, HERB), (122, CLAY)):
    o = cv.obj()
    o.part(rrect(sx - 7, 168, sx + 7, 184, 3), CREAM, d=2)
    o.draw()
    cv.fill(ell(sx - 5, 166, sx + 5, 171), sp['b'])
    cv.dots([(sx - 2, 167), (sx + 1, 168)], sp['r'])
    cv.fill(rect(sx - 6, 172, sx + 6, 172), CREAM['s'])
# gnome pouring mint tea from on high, glasses on a brass tray
tgx, tgy = 154, 186
gnome(tgx, tgy, TEAL, RED, hh=18)
o = cv.obj()
o.part(rect(tgx + 7, tgy - 30, tgx + 10, tgy - 14), RED, d=1)   # raised arm
o.part(ell(tgx + 6, tgy - 40, tgx + 16, tgy - 31) | line([(tgx + 15, tgy - 36), (tgx + 20, tgy - 38)], 2) | rect(tgx + 9, tgy - 42, tgx + 12, tgy - 40), ramp('#d9cfb8', '#9a8f7a', '#ffffff'), d=1)   # teapot
o.draw()
cv.fill(rect(tgx + 21, tgy - 37, tgx + 21, tgy - 12), '#e8a317')   # the long golden pour
cv.dots([(tgx + 20, tgy - 30), (tgx + 22, tgy - 20)], '#f5cf6a')
o = cv.obj()
o.part(ell(tgx + 12, tgy - 9, tgx + 32, tgy - 5), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=1)
o.part(rect(tgx + 20, tgy - 5, tgx + 22, tgy), WOOD, d=1)
o.draw()
for gx2 in (tgx + 15, tgx + 20, tgx + 26):
    cv.fill(rect(gx2, tgy - 12, gx2 + 2, tgy - 8), '#c47048')
    cv.dots([(gx2, tgy - 12), (gx2 + 2, tgy - 12)], '#fff4d8')
    cv.dots([(gx2 + 1, tgy - 12)], '#8ab060')   # mint sprig

# ================================================================ FOREGROUND props: melons, carpet, jars, scarab, sage, pebbles
for mx, my, s in ((6, 186, 9), (20, 190, 8), (12, 176, 8), (28, 180, 7), (2, 196, 6), (34, 194, 7)):
    o = cv.obj()
    o.part(ell(mx - s, my - s * 2 // 3, mx + s, my + s * 2 // 3), MELON, d=2)
    o.draw()
    for k in (-s // 2, 0, s // 2):
        cv.fill(line([(mx + k, my - s * 2 // 3 + 1), (mx + k + 1, my + s * 2 // 3 - 1)]) & ell(mx - s + 1, my - s * 2 // 3 + 1, mx + s - 1, my + s * 2 // 3 - 1), '#2f5a2a')
    cv.dots([(mx - s // 2, my - s // 3)], MELON['r'])
o = cv.obj()   # one cut melon showing red
o.part(ell(36, 168, 48, 176) & rect(0, 172, W, H), MELON, d=1)
o.part(ell(37, 168, 47, 175) & rect(0, 168, W, 172), RED, d=1)
o.draw()
cv.dots([(40, 170), (43, 171), (45, 170)], '#2a1a10')
# carpet spread on the sand (front, between the melons and the path)
cp = poly([(60, 188), (122, 186), (128, 199), (54, 199)])
o = cv.obj()
o.part(cp, RED, d=1)
o.draw()
cv.fill(poly([(64, 190), (118, 188), (122, 199), (60, 199)]), TEAL['b'])
cv.fill(poly([(70, 192), (112, 191), (114, 199), (68, 199)]), RED['b'])
for k, fx in enumerate(range(74, 112, 8)):
    cv.dots([(fx, 195), (fx - 1, 196), (fx + 1, 196), (fx, 197), (fx, 194), (fx, 198)], '#f5cf6a' if k % 2 else '#f2e4c0')
for fx in range(60, 124, 2):
    cv.dots([(fx, 187 - (fx - 60) // 32)], '#f2e4c0')
# sweating clay jars by the stall corner
for jx, jy, s in ((136, 170, 6), (128, 178, 5), (142, 182, 4)):
    o = cv.obj()
    o.part(ell(jx - s, jy - s, jx + s, jy + s) | rect(jx - 2, jy - s - 3, jx + 2, jy - s) | rect(jx - 3, jy - s - 4, jx + 3, jy - s - 3), CLAY, d=2)
    o.draw()
    cv.dots([(jx - s // 2, jy - 1), (jx - s // 2 + 1, jy + 2), (jx + 1, jy - 2)], '#a9d6ea')   # sweat beads
    cv.fill(rect(jx - s + 1, jy, jx + s - 1, jy), CLAY['s'])
# the friendly sand scarab rolling its ball (front centre-right)
sbx, sby = 210, 190
shadow(sbx - 12, sby + 3, sbx + 12, sby + 7)
o = cv.obj()
o.part(ell(sbx - 12, sby - 8, sbx - 1, sby + 4), ramp('#c9a96e', '#9a6b3f', SAND['r']), d=2)
o.part(ell(sbx + 1, sby - 4, sbx + 12, sby + 4), ramp('#3f8fa0', '#25637d', '#a9d6ea'), d=2, contour=True)
o.part(ell(sbx - 1, sby - 3, sbx + 4, sby + 2), ramp('#2a4a5a', '#2a1a10', '#3f8fa0'), d=1)
o.draw()
cv.fill(rect(sbx + 6, sby - 4, sbx + 6, sby + 4), '#25637d')
cv.dots([(sbx + 4, sby - 2), (sbx + 9, sby - 2)], '#f5cf6a')
for lx in (sbx + 2, sbx + 6, sbx + 10):
    cv.dots([(lx, sby + 5), (lx + 1, sby + 6)], '#2a1a10')
cv.dots([(sbx - 9, sby - 5), (sbx - 8, sby - 6)], SAND['r'])
for k in range(5):   # its track in the sand
    cv.dots([(sbx + 16 + k * 4, sby + 4 - (k % 2))], SAND['s'])
for sx, sy in ((150, 140), (176, 150), (8, 150), (226, 194), (200, 176), (60, 182)):   # desert sage tufts (silver-green)
    for dx, dy in ((0, 0), (-2, -2), (2, -3), (-1, -4), (1, -5), (3, -1), (-3, -1)):
        cv.dots([(sx + dx, sy + dy)], '#9aaa8a' if (dx + dy) % 2 else '#6a7a6a')
for px, py in ((140, 196), (24, 160), (178, 196), (232, 160), (16, 168), (198, 160), (2, 158)):   # pebbles
    o = cv.obj()
    o.part(ell(px, py, px + 5, py + 3), STONE, d=1)
    o.draw()
# a tall amphora and a basket of oranges by the first house, a brass lamp on the carpet
o = cv.obj()
o.part(ell(4, 128, 14, 142) | rect(7, 124, 11, 128) | rect(6, 123, 12, 124), CLAY, d=2)
o.part(rrect(16, 136, 28, 143, 1), WOOD, d=1)
o.draw()
for ox in (17, 20, 23, 26):
    cv.fill(rect(ox, 133 + ox % 2, ox + 2, 135 + ox % 2), '#f08a24')
for xx in range(17, 28, 2):
    cv.fill(rect(xx, 137, xx, 142), WOOD['s'])
cv.fill(rect(5, 133, 13, 133), TEAL['b'])
o = cv.obj()
o.part(ell(92, 180, 104, 186) | line([(103, 182), (108, 179)], 2) | rect(96, 177, 99, 180), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=1)
o.draw()
cv.dots([(109, 178), (110, 177)], '#fff4c0')
for _ in range(40):   # wind-blown sand specks
    px, py = r(0, W - 2), r(130, H - 2)
    if path[py, px] or tuple(cv.px[py, px]) != P.hx(SAND['b']):
        continue
    cv.dots([(px, py)], SAND['r'] if r(0, 1) else '#9a5a64')

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'dunewhisper', out)
    print('dunewhisper:', n, 'colours')
