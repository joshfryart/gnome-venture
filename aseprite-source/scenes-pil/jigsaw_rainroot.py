"""Jigsaw picture: THE RAINROOT REACHES (draft v0): game/assets/img/jigsaw/rainroot.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_rainroot.py [outdir]
Two worlds in one frame: steamy rainforest below, Andean highland above. A giant kapok on the left with a gnome door in its buttress roots, rubber-tree
cups, orchids and a bromeliad frog; the Canopy Bridge sags across to a second tree, a gnome walking over it and a sloth hanging beneath; behind, snowy
peaks, the Sky City ruins on a ridge and potato terraces with llamas; condors circle, macaws fly and perch. Below, a winding river with a gnome poling a
dugout canoe, a pink dolphin, giant water-lily pads; the River Landing bank of red clay with a beached canoe, clay pots and a gnome with a mate gourd;
heliconias and an armadillo on the right bank. Shafts of hard light fall through the steam from the upper left.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# palette: deep jungle green, macaw blue, heliconia orange, red-clay earth (+ pale steam sky)
SKY0, SKY1, SKY2 = '#bfe0d6', '#d3eadb', '#e6f1d8'
MIST = '#eef4e0'
MTN = ramp('#8d9fbc', '#6c80a2', '#b4c2d8')
MTN2 = '#7f98a6'
SNOW = '#f4f6ee'
G_DEEP = ramp('#1f5a3a', '#143f2a', '#3f8a4a')
G_MID = ramp('#2f7a45', '#1f5a3a', '#5fa850')
G_LIT = ramp('#5fa850', '#2f7a45', '#a4c860')
FAR = ('#5f9a7a', '#4f8a6a', '#7aae8a')
TERR = ('#8ab868', '#a4c070', '#7aa858')
STONE = ramp('#c9bb98', '#9a8a6a', '#e6dcbc')
KAPOK = ramp('#a89a7a', '#7a6a52', '#cfc2a0')
BARK = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
WOOD = ramp('#b07a3a', '#7a4a1f', '#d9a35a')
CLAY = ramp('#b8502a', '#8a3a20', '#d9764a')
MUD = ramp('#9a5a34', '#6e3a20', '#c27a4a')
WATER = ramp('#3f8fa0', '#2a6a80', '#8cc4c8')
BLUE = ramp('#2a6fc0', '#1a4a8a', '#6aaae0')
RED = ramp('#d6322b', '#a8241f', '#f08a24')
ORG = ramp('#f08a24', '#b85a14', '#f5b04a')
YEL = ramp('#f0b92b', '#c98a14', '#f8dc6a')
PINK = ramp('#e46a9b', '#b84a7a', '#f6b8cf')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
SLOTH = ramp('#9a8a6a', '#6e604a', '#c2b28e')
WOOL = ramp('#f1ece0', '#c9c5bc', '#ffffff')
LLAMA_B = ramp('#a8743a', '#7a4a1f', '#d9a35a')
UMB = '#2a1a10'

cv = new_canvas(SKY0)
r = rnd(1717)
r2 = rnd(303)


def clump(cx, cy, rx, ry, n, s0=5, s1=9, rr=r):
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + rr(-rx, rx), cy + rr(-ry, ry), rr(s0, s1)
        m |= ell(ex - s, ey - s * 3 // 4, ex + s, ey + s * 3 // 4)
    return m


def leafmass(m, rp, d=3, specks=12, outline=True):
    o = cv.obj(outline=outline)
    o.part(m, rp, d=d)
    o.draw()
    ys, xs = np.nonzero(m)
    inner = m & shift(m, 2, 0) & shift(m, -2, 0) & shift(m, 0, 2) & shift(m, 0, -2)
    for k in range(specks):   # leaf veins / flecks: little lit chevrons
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        if inner[y, x]:
            cv.dots([(x, y), (x + 1, y - 1), (x - 1, y - 1)] if k % 2 else [(x, y), (x + 1, y)], rp['r'])


def gnome(gx, gy, hat, tunic, tip=-3, arm=None):
    """Gnome about 31 px tall, feet at (gx, gy). arm = (dx, dy) of the raised hand, or None."""
    o = cv.obj()
    o.part(rect(gx - 5, gy - 2, gx - 1, gy) | rect(gx + 1, gy - 2, gx + 5, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - 5, gy - 12, gx + 5, gy - 2, 2), tunic, d=2, contour=True)
    o.part(rect(gx - 5, gy - 6, gx + 5, gy - 5), ramp('#7a4a1f', '#5c3420'), d=0)
    o.part(poly([(gx - 5, gy - 15), (gx + 5, gy - 15), (gx, gy - 5)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 4, gy - 19, gx + 4, gy - 14), SKIN, d=1)
    o.part(poly([(gx - 6, gy - 17), (gx + 6, gy - 17), (gx + tip, gy - 31)]), hat, d=2, contour=True)
    if arm:
        o.part(line([(gx + 4, gy - 10), (gx + arm[0], gy + arm[1])], 3), tunic, d=1)
    o.draw()
    cv.fill(rect(gx - 6, gy - 18, gx + 6, gy - 17), hat['s'])
    cv.dots([(gx - 2, gy - 16), (gx + 2, gy - 16)], UMB)
    cv.dots([(gx, gy - 15), (gx + 1, gy - 15)], '#e0907a')
    cv.dots([(gx - 3, gy - 14), (gx + 3, gy - 14)], '#f0a0a0')
    cv.dots([(gx - 1, gy - 6), (gx, gy - 6)], '#f5cf6a')
    if arm:
        cv.fill(rect(gx + arm[0] - 1, gy + arm[1] - 1, gx + arm[0] + 1, gy + arm[1] + 1), SKIN['b'])


def macaw(x, y, body, wing, flip=False):
    """Perched macaw, head at (x, y), long tail hanging down."""
    s = -1 if flip else 1
    o = cv.obj()
    o.part(poly([(x - s, y + 9), (x + s * 2, y + 9), (x + s * 3, y + 22), (x + s * 1, y + 22)]), body, d=1)   # tail
    o.part(ell(x - 3, y + 2, x + 4, y + 11), body, d=2)
    o.part(ell(x - 3, y - 2, x + 3, y + 4), body, d=1)
    o.part(poly([(x - s * 1, y + 4), (x + s * 4, y + 4), (x + s * 3, y + 13)]), wing, d=1)
    o.draw()
    cv.fill(rect(x - s * 3 - (1 if s < 0 else 0), y, x - s * 2 + (0 if s < 0 else 0), y + 2), '#f1ece0')   # bare face patch
    cv.dots([(x - s * 2, y + 1)], UMB)
    cv.dots([(x - s * 4, y + 1), (x - s * 4, y + 2), (x - s * 3, y + 3)], '#3a3a3a')   # hooked beak
    cv.dots([(x + s * 2, y + 21), (x + s * 2, y + 20)], BLUE['b'] if body is RED else YEL['s'])


def flying_macaw(x, y, body, wing):
    """Macaw in flight heading left: round body, long pointed tail trailing right, both wings raised."""
    o = cv.obj()
    o.part(poly([(x + 6, y + 1), (x + 20, y + 5), (x + 19, y + 7), (x + 6, y + 4)]), body, d=1)   # long tail
    o.part(poly([(x + 3, y), (x + 9, y), (x + 12, y - 9), (x + 8, y - 8)]), wing, d=1)   # far wing
    o.part(poly([(x + 3, y + 2), (x + 9, y + 2), (x + 4, y - 7), (x + 1, y - 6)]), wing, d=1)   # near wing
    o.part(ell(x - 1, y - 1, x + 9, y + 4), body, d=1)
    o.part(ell(x - 4, y - 2, x + 1, y + 2), body, d=0)
    o.draw()
    cv.dots([(x - 2, y - 1)], '#f1ece0')
    cv.dots([(x - 3, y - 1)], UMB)
    cv.dots([(x - 5, y), (x - 5, y + 1)], '#3a3a3a')


def fern(x, y, h, lean, col, col2):
    """Fern frond from (x, y) up h px, bending by lean; leaflets alternate both sides."""
    for k in range(h):
        fx = x + lean * k * k // (h * h)
        fy = y - k
        cv.dots([(fx, fy)], col2)
        if k > 1 and k % 2 == 0:
            ln = max(1, (h - k) // 3 + 1)
            cv.fill(line([(fx, fy), (fx - ln, fy - 1)]), col)
            cv.fill(line([(fx, fy), (fx + ln, fy - 1)]), col)


def llama(x, y, rp, face_right=True):
    """Small llama standing at (x, y) = left hoof."""
    s = 1 if face_right else -1
    hx0 = x + (9 if face_right else -1)
    o = cv.obj()
    o.part(rect(x, y - 4, x, y) | rect(x + 2, y - 4, x + 2, y) | rect(x + 6, y - 4, x + 6, y) | rect(x + 8, y - 4, x + 8, y), rp, d=0)
    o.part(ell(x - 1, y - 8, x + 9, y - 3), rp, d=1)
    o.part(rect(hx0 - 1, y - 14, hx0, y - 6), rp, d=0)
    o.part(rect(hx0 - 1, y - 15, hx0 + s * 2, y - 13) if face_right else rect(hx0 - 3, y - 15, hx0, y - 13), rp, d=0)
    o.draw()
    cv.dots([(hx0 - 1, y - 17), (hx0 - 1, y - 16), (hx0, y - 16)], rp['s'])
    cv.dots([(hx0 + s, y - 14)], UMB)


# ---------------------------------------------------------------- steamy sky, mist bands
cv.fill(rect(0, 22, W - 1, 90), SKY1)
cv.fill(rect(0, 48, W - 1, 90), SKY2)
for cx, cy, w in ((140, 10, 34), (282, 8, 30), (120, 38, 26), (186, 30, 36), (262, 34, 22), (154, 56, 40), (96, 60, 28), (232, 18, 24)):
    m = ell(cx - w // 2, cy - 5, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 9, cx + w // 5, cy + 3)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#c9dcd6')

# ---------------------------------------------------------------- far Andes: snowy peaks
peaks = poly([(70, 84), (104, 44), (120, 56), (150, 22), (172, 44), (196, 30), (222, 52), (252, 14), (280, 36), (300, 30), (300, 92), (70, 92)])
cv.fill(peaks, MTN['b'])
cv.fill(peaks & ~shift(peaks, -4, 0) & ~shift(peaks, -3, 2), MTN['s'])   # shadow side of each ridge
for (px, py) in ((150, 22), (252, 14), (196, 30), (104, 44), (300, 30)):
    cap = peaks & poly([(px - 14, py + 14), (px, py - 1), (px + 14, py + 14), (px + 6, py + 10), (px + 1, py + 15), (px - 5, py + 10)])
    cv.fill(cap, SNOW)
    cv.fill(cap & ~shift(cap, -2, 0) & ~shift(cap, -1, 1), '#c9d4e0')
for k in range(26):   # rock streaks on the faces
    sx, sy = r(80, 298), r(30, 80)
    if peaks[sy, sx]:
        cv.fill(line([(sx, sy), (sx + r(-3, 3), sy + r(3, 6))]) & peaks, MTN['s'] if k % 3 else MTN['r'])
ridge = poly([(60, 96), (110, 70), (150, 80), (190, 64), (230, 76), (300, 56), (300, 110), (60, 110)])
cv.fill(ridge, MTN2)
cv.fill(ridge & ~shift(ridge, 0, 2), '#94acb4')
# condors circling over the peaks (wide flat wings with fingered tips)
for cx, cy, sp in ((214, 12, 9), (232, 24, 7), (176, 16, 6), (262, 46, 5)):
    cv.fill(line([(cx - sp, cy + 1), (cx - 2, cy - 1), (cx, cy), (cx + 2, cy - 1), (cx + sp, cy + 1)], 1), '#2f2a2a')
    cv.dots([(cx - sp - 1, cy + 2), (cx + sp + 1, cy + 2), (cx, cy - 1)], '#2f2a2a')
    cv.dots([(cx - 3, cy), (cx + 3, cy)], '#f1ece0')   # white wing patches
    cv.dots([(cx, cy + 1)], '#e46a9b' if sp > 7 else '#2f2a2a')

# ---------------------------------------------------------------- the Sky City ruins on the ridge and the potato terraces with llamas
terr = poly([(200, 70), (240, 54), (300, 44), (300, 126), (186, 126)])
bands = []
for k, y0 in enumerate(range(52, 126, 8)):
    band = terr & rect(0, y0, W, y0 + 7)
    cv.fill(band, TERR[k % 3])
    cv.fill(terr & rect(0, y0 + 6, W, y0 + 7), STONE['b'])   # dry-stone wall face
    cv.fill(terr & rect(0, y0 + 7, W, y0 + 7), STONE['s'])
    for xx in range(186 + (k % 2) * 3, 300, 5):
        cv.dots([(xx, y0 + 6)], STONE['s'])
    bands.append(y0)
cv.fill(terr & ~shift(terr, 2, 0) & ~shift(terr, 0, 2), '#6a9a58')
for k in range(60):   # potato rows: little dark mounds with a green leaf on top
    px, py = r(204, 298), r(56, 122)
    if terr[py, px] and terr[py, min(W - 1, px + 3)] and (py - 52) % 8 in (2, 3, 4):
        cv.dots([(px, py), (px + 1, py)], '#5c7a3a')
        cv.dots([(px, py - 1)], ('#4f9a45', '#e46a9b', '#f5cf6a')[k % 3])   # potato flowers in three colours
# ruins: stone walls and trapezoid doors
for x0, y0, w, h in ((246, 40, 18, 12), (266, 34, 16, 18), (284, 38, 15, 14), (232, 46, 12, 8)):
    o = cv.obj()
    o.part(rect(x0, y0, x0 + w, y0 + h), STONE, d=2)
    o.draw()
    for yy in range(y0 + 3, y0 + h, 3):
        for xx in range(x0 + 1 + (yy % 2) * 2, x0 + w, 4):
            cv.dots([(xx, yy)], STONE['s'])
    dx = x0 + w // 2
    cv.fill(poly([(dx - 2, y0 + h), (dx + 2, y0 + h), (dx + 1, y0 + h - 6), (dx - 1, y0 + h - 6)]), '#4a3a2a')
cv.fill(poly([(270, 34), (278, 34), (274, 28)]), '#b8502a')   # thatched hut roof on the highest ruin
cv.fill(rect(273, 26, 274, 28), '#7a4a1f')
for lx, ly, rp, fr in ((230, 82, WOOL, True), (240, 98, LLAMA_B, False), (262, 74, WOOL, False), (226, 110, WOOL, True), (282, 106, LLAMA_B, True)):
    llama(lx, ly, rp, fr)
cv.fill(rect(244, 90, 247, 91), '#d6322b')   # a woven saddle blanket
cv.dots([(245, 90), (247, 91)], '#f0b92b')
# a tiny terrace gnome with a sack of potatoes
tgx, tgy = 268, 117
o = cv.obj()
o.part(rrect(tgx - 3, tgy - 7, tgx + 3, tgy, 1), BLUE, d=1)
o.part(rect(tgx - 2, tgy - 10, tgx + 2, tgy - 7), SKIN, d=0)
o.part(poly([(tgx - 4, tgy - 9), (tgx + 4, tgy - 9), (tgx - 1, tgy - 17)]), ORG, d=1)
o.part(ell(tgx + 3, tgy - 6, tgx + 9, tgy), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1)
o.draw()
cv.fill(poly([(tgx - 3, tgy - 7), (tgx + 3, tgy - 7), (tgx, tgy - 3)]), '#f1ece0')

# ---------------------------------------------------------------- far forest canopy with steam
x = -8
while x < 210:
    w = r(14, 26)
    top = 84 + r(0, 12)
    col = FAR[r(0, 2)]
    m = ell(x, top, x + w, top + w * 3 // 4 + 8)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, -2, -2), '#3f7a5a')
    cv.fill(m & ~shift(m, 1, 1) & shift(m, -2, -2), '#8ebe98')
    if r(0, 2) == 0:   # an emergent palm on the skyline
        px = x + w // 2
        cv.fill(rect(px, top - 14, px, top), '#4f7a5a')
        for dx, dy in ((-6, 3), (6, 3), (-4, -2), (5, -2), (0, -4)):
            cv.fill(line([(px, top - 14), (px + dx, top - 14 + dy)]), '#3f7a5a')
    x += w - r(3, 6)
cv.fill(rect(0, 104, 210, 108), MIST)   # steam band hanging over the forest
for k in range(18):
    mx = r(0, 205)
    cv.fill(ell(mx, 100 + r(0, 3), mx + r(10, 22), 106 + r(0, 3)), MIST)
cv.fill(rect(0, 108, 230, 126), FAR[1])
for k in range(90):
    fx, fy = r(0, 228), r(108, 125)
    cv.dots([(fx, fy), (fx + 1, fy)], FAR[k % 3] if k % 4 else '#3f7a5a')

# ---------------------------------------------------------------- river (winding in from the back) and the forest floor
river = poly([(128, 112), (146, 112), (160, 124), (184, 138), (210, 152), (240, 168), (268, 184), (300, 192), (300, 199), (64, 199), (74, 184), (92, 166), (108, 148), (116, 132), (122, 120)])
floor = rect(0, 120, W - 1, H - 1) & ~river
cv.fill(floor & rect(0, 120, W, 140), '#3f7a3a')
cv.fill(floor & rect(0, 140, W, H), '#2f6a32')
for k in range(260):   # ferns and undergrowth tufts on the floor
    fx, fy = r(0, W - 3), r(122, H - 2)
    if floor[fy, fx]:
        cv.dots([(fx, fy), (fx - 1, fy - 1), (fx + 1, fy - 1), (fx, fy - 2)], ('#5fa850', '#1f5a3a', '#7aae5a')[k % 3])
cv.fill(river, WATER['b'])
cv.fill(river & rect(0, 112, W, 128), '#6aa8b0')
cv.fill(dil4(dil4(river)) & ~river & floor, MUD['b'])   # muddy banks
cv.fill(dil4(river) & ~river, MUD['s'])
for k in range(110):   # ripples: sky reflections and dark current lines
    rx, ry = r(70, 298), r(116, 198)
    if river[ry, rx] and river[ry, min(W - 1, rx + 6)]:
        ln = 2 + (ry - 110) // 18
        cv.fill(line([(rx, ry), (rx + ln, ry)]), (WATER['r'], WATER['s'], '#d3eadb')[k % 3])

# understorey: shrubs, palms and ferns on the forest floor (keeps the mid band busy)
for ux, uy, w, rp in ((64, 120, 12, G_MID), (86, 126, 10, G_DEEP), (104, 116, 8, G_LIT), (160, 118, 9, G_MID), (176, 126, 10, G_DEEP), (196, 112, 8, G_LIT),
                      (228, 130, 10, G_MID), (252, 132, 12, G_DEEP), (276, 136, 10, G_LIT), (296, 132, 8, G_MID), (240, 146, 8, G_LIT)):
    leafmass(clump(ux, uy, w, 3, 5, 3, 6, rr=r2), rp, d=2, specks=8)
for k in range(46):
    fx, fy = r2(0, W - 1), r2(124, 198)
    if floor[fy, fx] and not river[min(H - 1, fy + 2), fx] and not dil4(dil4(river))[fy, fx]:
        fern(fx, fy, r2(6, 11), r2(-4, 4), ('#5fa850', '#7aae5a', '#3f8a4a')[k % 3], '#2f6a32')
for k in range(40):   # reeds and arrowhead leaves along both river banks
    ry_ = r2(116, 196)
    edge = np.nonzero(river[ry_])[0]
    if len(edge) == 0:
        continue
    rx_ = int(edge[0]) - r2(1, 4) if k % 2 else int(edge[-1]) + r2(1, 4)
    if 0 < rx_ < W - 2:
        h = r2(5, 9)
        cv.fill(line([(rx_, ry_), (rx_ + r2(-2, 2), ry_ - h)]), '#4f7a2a')
        cv.dots([(rx_ + 1, ry_ - 2), (rx_ - 1, ry_ - 3)], '#7aae5a')

# ---------------------------------------------------------------- shafts of light through the steam (hard-edged, lighten only the far layers)
LIGHT = {SKY0: '#e6f1d8', SKY1: '#eef4e0', SKY2: '#f6f6dc', MTN['b']: MTN['r'], MTN2: '#a4b8c0', FAR[0]: '#8ebe98', FAR[1]: FAR[0], FAR[2]: '#a4c8a0',
         '#3f7a5a': FAR[1], TERR[0]: TERR[1], TERR[2]: TERR[0], '#3f7a3a': '#5f9a4a', '#2f6a32': '#3f7a3a', WATER['b']: '#6aa8b0', '#6aa8b0': WATER['r']}
shafts = poly([(84, 0), (100, 0), (214, 199), (190, 199)]) | poly([(118, 0), (126, 0), (236, 180), (224, 186)]) | poly([(46, 30), (60, 30), (150, 199), (132, 199)])
for a, b in LIGHT.items():
    m = shafts & np.all(cv.px == np.array([int(a[i:i + 2], 16) for i in (1, 3, 5)], np.uint8), axis=2)
    cv.fill(m, b)

# ---------------------------------------------------------------- the second tree (bridge end, right of centre)
o = cv.obj()
o.part(poly([(200, 150), (206, 138), (208, 40), (220, 40), (222, 138), (232, 150), (224, 148), (214, 142), (206, 148)]), BARK, d=3)
o.part(poly([(188, 152), (204, 128), (208, 132), (198, 152)]) | poly([(240, 152), (220, 126), (218, 134), (232, 152)]), BARK, d=2)   # buttress fins
o.part(line([(212, 60), (180, 44)], 3) | line([(218, 52), (242, 34)], 3), BARK, d=1)
o.draw()
for yy in range(46, 136, 7):
    cv.fill(line([(211, yy), (213, yy + 4)]), BARK['s'])
    cv.fill(line([(217, yy + 3), (218, yy + 6)]), BARK['r'])
cv.fill(rect(198, 70, 228, 73), WOOD['s'])   # platform where the bridge lands
cv.fill(rect(198, 70, 228, 70), WOOD['r'])
for xx in range(198, 229, 4):
    cv.dots([(xx, 72)], UMB)
for cx, cy, rx, ry, rp in ((210, 18, 22, 10, G_MID), (182, 30, 14, 8, G_DEEP), (240, 22, 14, 10, G_DEEP), (198, 6, 14, 6, G_LIT), (226, 4, 12, 5, G_MID)):
    leafmass(clump(cx, cy, rx, ry, 8, 6, 10), rp, specks=22)
# a vine and a hanging bromeliad
cv.fill(line([(186, 38), (184, 60), (188, 76), (186, 96)]), '#4f7a2a')
for vy in range(44, 96, 6):
    cv.dots([(185 + (vy % 4) // 2, vy), (187, vy + 1)], '#5fa850')

# ---------------------------------------------------------------- the giant kapok (left): buttress roots, gnome door, rubber cups, orchids
trunk = poly([(10, 150), (16, 120), (18, 0), (52, 0), (52, 118), (60, 150)])
roots = (poly([(-6, 178), (10, 118), (22, 140), (14, 180)]) | poly([(30, 182), (30, 130), (46, 120), (60, 150), (84, 172), (62, 180)])
         | poly([(52, 112), (68, 148), (98, 166), (76, 168), (56, 150)]))
o = cv.obj()
o.part(trunk | roots, KAPOK, d=3)
o.part(line([(50, 58), (100, 44)], 5) | line([(48, 30), (84, 16)], 4), KAPOK, d=2)   # limbs: the bridge one and an upper one
o.draw()
for (a0, a1) in (((22, 140), (14, 178)), ((46, 122), (56, 176)), ((60, 136), (84, 170))):   # fin ridges
    cv.fill(line([a0, a1]), KAPOK['s'])
for yy in range(4, 116, 6):   # bark: grey-green lichen streaks and dark furrows
    cv.fill(line([(24 + (yy * 7) % 20, yy), (25 + (yy * 7) % 20, yy + 4)]), KAPOK['s'])
    cv.dots([(20 + (yy * 13) % 28, yy + 2), (21 + (yy * 13) % 28, yy + 2)], '#8aa078')
for k in range(30):   # lichen patches and moss on the kapok
    lx_, ly_ = r2(18, 50), r2(4, 140)
    if trunk[ly_, lx_] and trunk[ly_, lx_ + 3]:
        cv.fill(rect(lx_, ly_, lx_ + r2(1, 3), ly_), ('#8aa078', KAPOK['r'], '#6f8a5a')[k % 3])
        cv.dots([(lx_ + 1, ly_ + 1)], KAPOK['s'])
# gnome door between the fins
o = cv.obj()
o.part(ell(26, 142, 46, 172) & ~rect(0, 168, W, H) | rect(26, 157, 46, 168), WOOD, d=3, contour=True)
o.draw()
for xx in (30, 34, 38, 42):
    cv.fill(rect(xx, 146, xx, 167), WOOD['s'])
cv.dots([(42, 158), (42, 159)], '#f5cf6a')
cv.fill(ell(31, 146, 41, 152), '#f5cf6a')   # fan window, lit
cv.fill(rect(36, 146, 36, 152), '#4a2c1a')
cv.fill(rect(24, 168, 48, 170), STONE['b'])   # doorstep
cv.fill(rect(24, 170, 48, 170), STONE['s'])
# lantern on a hook
cv.fill(rect(52, 132, 58, 132), '#4a2c1a')
o = cv.obj()
o.part(rect(55, 134, 59, 140), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=1)
o.draw()
cv.fill(rect(55, 133, 59, 133), '#4a2c1a')
# a little upper window in the trunk
o = cv.obj()
o.part(ell(26, 92, 36, 104), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=1)
o.draw()
cv.fill(rect(31, 92, 31, 104) | rect(26, 98, 36, 98), '#4a2c1a')
cv.fill(rect(24, 105, 38, 106), WOOD['b'])
# rubber-tree cups tapped into the trunk
for cx, cy in ((44, 110), (20, 74), (46, 82)):
    cv.fill(line([(cx - 4, cy - 6), (cx, cy - 2), (cx + 4, cy - 6)]), '#5c4a3a')
    o = cv.obj()
    o.part(rect(cx - 2, cy, cx + 2, cy + 4), CLAY, d=1)
    o.draw()
    cv.fill(rect(cx - 1, cy, cx + 1, cy), '#f1ece0')
# orchids and a bromeliad with a frog on the trunk
for ox, oy, rp in ((14, 60, PINK), (48, 96, PINK), (20, 126, PINK), (54, 40, PINK), (12, 98, YEL)):
    cv.fill(line([(ox, oy), (ox + 5, oy + 3)]), '#4f7a2a')
    for k, (dx, dy) in enumerate(((0, 0), (4, 1), (7, 4))):
        cv.fill(rect(ox + dx - 1, oy + dy - 1, ox + dx + 1, oy + dy + 1), rp['b'])
        cv.dots([(ox + dx, oy + dy)], rp['r'] if k != 1 else '#ffffff')
        cv.dots([(ox + dx + 1, oy + dy + 1)], rp['s'])
brx, bry = 18, 40
o = cv.obj()
o.part(poly([(brx - 8, bry - 6), (brx - 2, bry + 4), (brx + 2, bry + 4), (brx + 8, bry - 7), (brx + 2, bry), (brx, bry - 9), (brx - 2, bry)]), ramp('#d6322b', '#a8241f', '#f08a24'), d=1)
o.draw()
cv.fill(rect(brx - 2, bry - 1, brx + 2, bry), WATER['b'])
cv.dots([(brx - 1, bry - 2), (brx, bry - 2), (brx + 1, bry - 2), (brx - 1, bry - 3), (brx + 1, bry - 3)], '#5fd06a')   # glossy frog
cv.dots([(brx - 1, bry - 3), (brx + 1, bry - 3)], UMB)
# the kapok crown
for cx, cy, rx, ry, rp in ((30, 8, 26, 8, G_MID), (78, 12, 20, 8, G_DEEP), (110, 4, 12, 5, G_MID), (8, 26, 10, 8, G_DEEP), (58, 30, 12, 6, G_LIT), (96, 30, 10, 5, G_MID)):
    leafmass(clump(cx, cy, rx, ry, 10, 6, 11), rp, specks=26)

# ---------------------------------------------------------------- the Canopy Bridge (left limb to the second tree), gnome crossing, sloth under it
xa, ya, xb, yb, sag = 96, 50, 200, 70, 16


def deck_y(x):
    t = (x - xa) / (xb - xa)
    return int(round(ya + (yb - ya) * t + sag * 4 * t * (1 - t)))


rail = []
deck = []
for xx in range(xa, xb + 1):
    deck.append((xx, deck_y(xx)))
    t = (xx - xa) / (xb - xa)
    rail.append((xx, int(round(ya - 11 + (yb - ya) * t + (sag - 4) * 4 * t * (1 - t)))))
cv.fill(line(deck, 1), '#3d2a1c')
for i in range(0, len(deck) - 1, 3):   # planks: lit top, dark lip, a gap between each
    px, py = deck[i]
    cv.fill(rect(px, py - 2, px + 1, py - 1), WOOD['b'])
    cv.dots([(px, py - 2)], WOOD['r'])
    cv.dots([(px + 1, py)], WOOD['s'])
cv.fill(line(rail, 1), '#7a5a3a')
for i in range(0, len(rail), 7):   # vertical hanger ropes and net diamonds
    cv.fill(line([rail[i], (deck[i][0], deck[i][1] - 2)]), '#9a7a52')
    if i + 4 < len(rail):
        cv.fill(line([(rail[i][0], rail[i][1] + 2), (deck[i + 3][0], deck[i + 3][1] - 3)]), '#9a7a52')
for i in range(0, len(deck), 12):   # palm-leaf pennants tied to the rail
    px, py = rail[i]
    cv.fill(poly([(px, py), (px + 3, py + 1), (px, py + 4)]), (ORG['b'], BLUE['b'], YEL['b'])[(i // 12) % 3])
bgx = 134
gnome(bgx, deck_y(bgx) - 2, RED, ramp('#2f7a45', '#1f5a3a', '#5fa850'), tip=-6, arm=(9, -16))
cv.fill(line([(bgx + 9, deck_y(bgx) - 18), (bgx + 9, deck_y(bgx) - 26)]), '#4a2c1a')   # walking stick raised in a wave? no: a little pennant pole
cv.fill(poly([(bgx + 10, deck_y(bgx) - 26), (bgx + 15, deck_y(bgx) - 24), (bgx + 10, deck_y(bgx) - 22)]), ORG['b'])
# the sloth, hanging upside down from the bridge
slx = 166
sly = deck_y(slx)
o = cv.obj()
o.part(line([(slx - 3, sly), (slx - 2, sly + 6)], 2) | line([(slx + 5, sly), (slx + 4, sly + 6)], 2), SLOTH, d=0)
o.part(ell(slx - 5, sly + 4, slx + 8, sly + 16), SLOTH, d=2)
o.part(ell(slx - 3, sly + 13, slx + 5, sly + 20), ramp('#e6dcbc', '#c2b28e', '#fff4d8'), d=1)
o.draw()
cv.dots([(slx - 1, sly + 16), (slx, sly + 16), (slx + 2, sly + 16), (slx + 3, sly + 16)], '#5c4a3a')   # eye stripes
cv.dots([(slx, sly + 16), (slx + 2, sly + 16)], UMB)
cv.dots([(slx + 1, sly + 18)], UMB)
cv.dots([(slx - 3, sly), (slx - 2, sly), (slx + 4, sly), (slx + 5, sly)], '#3d2a1c')   # claws
for k in range(4):
    cv.dots([(slx - 3 + k * 3, sly + 7 + k % 2)], '#7f9a6a')   # a bit of green algae in the fur

# ---------------------------------------------------------------- macaws: a pair perched on the kapok limb, two flying over the peaks
macaw(70, 40, RED, BLUE)
macaw(82, 38, BLUE, YEL, flip=True)
cv.fill(rect(82, 39, 84, 41), YEL['b'])   # gold chest on the blue-and-gold
flying_macaw(136, 22, RED, BLUE)
flying_macaw(152, 34, BLUE, YEL)

# ---------------------------------------------------------------- the river: canoe with a poling gnome, pink dolphin, giant lily pads
for lx, ly, w in ((222, 176, 22), (250, 190, 24), (196, 192, 16), (272, 182, 14)):   # giant Victoria lily pads with turned-up rims
    pad = ell(lx, ly, lx + w, ly + w // 3)
    o = cv.obj(outline=False)
    o.part(pad, G_LIT, d=1)
    o.draw()
    cv.fill(pad & ~shift(pad, 0, 1), '#b84a7a')
    cv.fill(pad & ~shift(pad, 0, -1), '#d9764a')
    cv.fill(line([(lx + 2, ly + w // 6), (lx + w - 2, ly + w // 6)]) & pad, G_MID['b'])
cv.dots([(244, 175), (245, 174), (246, 175), (245, 176)], '#f6f0f0')   # a lily flower
cv.dots([(245, 175)], '#f6b8cf')
cvx, cvy = 112, 176
canoe = poly([(cvx, cvy - 2), (cvx + 50, cvy - 4), (cvx + 46, cvy + 4), (cvx + 6, cvy + 5)])
o = cv.obj()
o.part(canoe, BARK, d=2)
o.draw()
cv.fill(line([(cvx + 2, cvy - 1), (cvx + 48, cvy - 3)]), WOOD['r'])
cv.fill(rect(cvx + 30, cvy - 9, cvx + 38, cvy - 3), ramp('#c9a96e', '#9a6b3f')['b'])   # bundle of cargo: a sack and bananas
cv.fill(rect(cvx + 30, cvy - 9, cvx + 38, cvy - 9), '#9a6b3f')
cv.fill(line([(cvx + 40, cvy - 6), (cvx + 45, cvy - 9)], 2), YEL['b'])
gnome(cvx + 18, cvy - 2, BLUE, ORG, tip=-5)
cv.fill(line([(cvx + 22, cvy - 26), (cvx + 8, cvy + 14)], 2), WOOD['s'])   # the pole
cv.fill(rect(cvx + 21, cvy - 14, cvx + 23, cvy - 12), SKIN['b'])
for k in range(1, 4):   # wake
    cv.fill(line([(cvx - k * 5, cvy + 1 - k), (cvx - k * 5 + 3, cvy + 2)]), WATER['r'])
    cv.fill(line([(cvx - k * 5, cvy + 5 + k), (cvx - k * 5 + 3, cvy + 4)]), WATER['r'])
cv.fill(rect(cvx + 2, cvy + 6, cvx + 48, cvy + 6), WATER['s'])
dfx, dfy = 176, 184   # pink river dolphin arching out of the water
o = cv.obj()
o.part(poly([(dfx, dfy + 4), (dfx + 4, dfy - 3), (dfx + 12, dfy - 5), (dfx + 18, dfy - 1), (dfx + 20, dfy + 4), (dfx + 14, dfy + 1), (dfx + 6, dfy + 1)]), PINK, d=2)
o.part(line([(dfx + 18, dfy - 1), (dfx + 25, dfy + 1)], 2), PINK, d=0)   # long beak
o.draw()
cv.dots([(dfx + 15, dfy - 2)], UMB)
cv.fill(rect(dfx - 2, dfy + 4, dfx + 22, dfy + 4), WATER['r'])
cv.dots([(dfx + 9, dfy - 9), (dfx + 11, dfy - 11), (dfx + 13, dfy - 8)], '#d3eadb')   # spout droplets
cv.fill(ell(dfx + 22, dfy - 8, dfx + 25, dfy - 5), '#d3eadb')   # a bubble
cv.dots([(dfx + 23, dfy - 7)], '#ffffff')

# ---------------------------------------------------------------- River Landing bank (front left): red clay, beached canoe, pots, a gnome with the mate gourd
bank = poly([(0, 172), (30, 176), (60, 178), (74, 184), (64, 199), (0, 199)])
cv.fill(bank, CLAY['b'])
cv.fill(bank & ~shift(bank, 0, 2), CLAY['r'])
for k in range(40):
    bx, by = r(0, 70), r(178, 198)
    if bank[by, bx]:
        cv.dots([(bx, by), (bx + 1, by)], CLAY['s'] if k % 2 else MUD['r'])
o = cv.obj()   # beached dugout
o.part(poly([(4, 186), (46, 184), (42, 192), (8, 193)]), BARK, d=2)
o.draw()
cv.fill(line([(6, 187), (44, 185)]), WOOD['r'])
cv.fill(line([(8, 189), (40, 187)]), '#3d2a1c')
cv.fill(line([(26, 182), (40, 196)], 2), WOOD['b'])   # paddle across it
cv.fill(ell(38, 192, 44, 198), WOOD['b'])
for px, py, s in ((60, 176, 5), (68, 180, 4)):   # red clay pots
    o = cv.obj()
    o.part(ell(px - s, py - s, px + s, py + s) | rect(px - s // 2, py - s - 2, px + s // 2, py - s), CLAY, d=2)
    o.draw()
    cv.fill(rect(px - s + 1, py - 1, px + s - 1, py - 1), '#f1ece0')
gnome(84, 170, ORG, BLUE, tip=4)   # on the roots by the door, sipping mate
o = cv.obj()
o.part(ell(88, 156, 94, 162), ramp('#b8a06a', '#8a7a4a', '#e6dcbc'), d=1)
o.draw()
cv.fill(line([(92, 157), (94, 152)]), '#c9c5bc')   # silver bombilla straw
cv.fill(rect(86, 158, 88, 160), SKIN['b'])

# ---------------------------------------------------------------- right bank: heliconias, big leaves, an armadillo
rbank = poly([(256, 150), (300, 150), (300, 188), (284, 184), (262, 176), (240, 164)])
cv.fill(rbank & ~river, '#2f6a32')
arx, ary = 262, 160
o = cv.obj()
o.part(ell(arx, ary - 7, arx + 16, ary + 2), ramp('#a89070', '#7a6a52', '#cfc2a0'), d=2)
o.part(poly([(arx + 15, ary - 3), (arx + 22, ary - 1), (arx + 16, ary + 1)]), ramp('#a89070', '#7a6a52'), d=0)
o.part(line([(arx, ary - 1), (arx - 6, ary + 1)], 2), ramp('#a89070', '#7a6a52'), d=0)
o.draw()
for xx in range(arx + 3, arx + 15, 3):
    cv.fill(rect(xx, ary - 6, xx, ary + 1) & ell(arx, ary - 7, arx + 16, ary + 2), '#7a6a52')
cv.dots([(arx + 18, ary - 2)], UMB)
cv.dots([(arx + 17, ary - 4), (arx + 17, ary - 5)], '#a89070')
for hx_, hy_ in ((288, 128), (296, 146), (246, 140)):   # heliconia: zigzag orange-red bracts on a stalk
    cv.fill(rect(hx_, hy_, hx_ + 1, hy_ + 30), '#2f7a45')
    for k in range(5):
        s = 1 if k % 2 else -1
        by = hy_ + 2 + k * 5
        o = cv.obj()
        o.part(poly([(hx_, by), (hx_ + s * 7, by - 2), (hx_ + s * 1, by + 4)]), ORG if k % 2 else RED, d=1)
        o.draw()
        cv.dots([(hx_ + s * 6, by - 2)], YEL['b'])
for lx, ly, s, flip in ((280, 168, 14, False), (0, 140, 12, True), (296, 188, 12, False), (228, 132, 8, False)):   # big monstera-style leaves
    m = ell(lx - s, ly - s // 2, lx + s, ly + s // 2)
    m &= ~(line([(lx - s // 2, ly - s), (lx - s // 3, ly)], 2) | line([(lx + s // 3, ly - s), (lx + s // 4, ly)], 2))
    o = cv.obj()
    o.part(m, G_MID, d=2)
    o.draw()
    cv.fill(line([(lx - s + 2, ly), (lx + s - 2, ly - 1)]) & m, G_LIT['r'])

# ---------------------------------------------------------------- floor litter: toadstools, leafcutter ants, butterflies, ferns along the front
for sx, sy in ((104, 150), (232, 150), (96, 196), (8, 160), (180, 140)):
    o = cv.obj()
    o.part(ell(sx - 3, sy - 4, sx + 3, sy), ORG, d=1)
    o.part(rect(sx - 1, sy, sx, sy + 3), ramp('#f2e4c0', '#c9a96e'), d=0)
    o.draw()
    cv.dots([(sx - 1, sy - 3)], '#fff4c0')
ax = 100
while ax < 120:   # leafcutter ant line carrying green leaf bits along the bank
    ay = 158 + (ax - 100) // 3
    cv.dots([(ax, ay), (ax + 1, ay)], '#5c2a1a')
    cv.dots([(ax, ay - 1), (ax + 1, ay - 2)], '#7ab55c')
    ax += 4
for bx, by, col in ((120, 96, BLUE['b']), (64, 120, BLUE['b']), (250, 128, ORG['b']), (176, 120, YEL['b'])):   # morpho butterflies
    cv.dots([(bx, by), (bx + 1, by - 1), (bx - 1, by - 1), (bx + 2, by - 2), (bx - 2, by - 2), (bx + 1, by + 1), (bx - 1, by + 1)], col)
    cv.dots([(bx, by - 1)], UMB)
for fx in range(70, 300, 9):   # foreground fern fronds along the bottom edge of the floor
    fy = 199
    if river[fy - 3, min(W - 1, fx)]:
        continue
    for k in range(5):
        cv.dots([(fx - k, fy - k * 2), (fx + k, fy - k * 2)], ('#5fa850', '#2f7a45')[k % 2])
    cv.fill(rect(fx, fy - 10, fx, fy), '#2f7a45')

cv.remap({'#a4b8c0': '#94acb4', '#6f8a5a': '#8aa078', '#7f9a6a': '#8aa078', '#a89070': KAPOK['b'], MUD['r']: CLAY['r'], '#6a9a58': TERR[2],
          '#4f7a5a': '#3f7a5a', '#5c7a3a': '#4f7a2a', '#9a7a52': '#9a8a6a'})   # fold near-duplicates to stay under ~100 colours

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'rainroot', out)
    print('rainroot:', n, 'colours')
