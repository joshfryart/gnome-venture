"""Jigsaw picture: MISTMOOR (v2.0.87): game/assets/img/jigsaw/mistmoor.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_mistmoor.py [outdir]
Soft grey drizzle over the moor: layered slate clouds, a glimpse of the fjord with a lighthouse and seals on the skerry, far fells with mist lying in
the folds, the Standing Stones on a knoll with a gnome flying a kite, a brown burn winding down under a humped stone bridge (a gnome with an umbrella
crossing it), a low turf-roofed stone cottage (the Crooked Kettle) with peat smoke and one amber lantern, drystone walls with an owl on the gatepost,
sheep, a peat bank with a gnome cutting turves and leaning stacks, a fairy ring of toadstools, heather, bracken, cottongrass and puddles everywhere,
a gnome child puddle-jumping on the muddy track.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

# ---- palette: slate sky, heather purple, moss olive, peat/rust brown; one warm lantern amber
SKY = ('#6c7888', '#7b8797', '#8b96a4', '#9ca6b2')
CLOUD = ramp('#b3bbc5', '#98a2ae', '#c8ced5')
DCLOUD = ramp('#66717f', '#566170', '#7b8695')
MIST = ('#c3c9d0', '#b0b8c1')
RAIN = '#c3c9d0'
HEATH = ramp('#8a5a8e', '#64406c', '#b07fb2')
HEATHF = ramp('#7a6286', '#665674', '#8e7898')   # far heather (cooler, flatter)
MOSS = ramp('#6f7f4a', '#55633a', '#8a9a5a')
MOSSF = ramp('#67715a', '#5a6450', '#7a846a')    # far moor
RUST = ramp('#a85a2c', '#7c3e22', '#c97a3e')
PEAT = ramp('#5a3e2c', '#3d2a1e', '#7a5a40')
MUD = ramp('#7a5e44', '#5e4632', '#94765a')
STONE = ramp('#9c9d97', '#74766f', '#bfc0b8')
STONED = '#5c5e58'
WATER = ramp('#6a5444', '#4e3a2e', '#a3acb7')     # peaty burn
PUD = ramp('#8994a2', '#6c7888', '#bfc7ce')
TURF = ramp('#6f8040', '#56632f', '#8fa058')
WOOD = ramp('#8a6040', '#5e4030', '#a87a50')
DOOR = ramp('#4a6a6a', '#344c4c', '#6a8a88')
WARM = ramp('#f2b84a', '#d98a2a', '#ffe08a')
WOOL = ramp('#e6e2d6', '#bdb8ac', '#f6f4ee')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#f6f4ee')
WINE = ramp('#9a3a3a', '#742a2c', '#c05a50')
SLATEC = ramp('#4f6a86', '#3a5068', '#7a94ac')   # oilskin coat
MUST = ramp('#c9a23a', '#9a7a24', '#e8c862')     # child's mac and wellies
BOOT = ramp('#4a3a30', '#2a1a10', '#6a5848')
BELT = ramp('#5e4030', '#3d2a1e')
UMB = ramp('#64406c', '#4a2c52', '#8a5a8e')
UMBER = '#2a1a10'

cv = new_canvas(SKY[0])
r = rnd(1717)
r2 = rnd(53)   # second stream for later details, so the layout drawn with r stays put


def shadow(x0, y0, x1, y1, col=None):
    cv.fill(ell(x0, y0, x1, y1), col or MOSS['s'])


def blobs(cx, cy, rx, ry, n, s0, s1, rr=None):
    rr = rr or r
    m = blank()
    for _ in range(n):
        ex, ey, s = cx + rr(-rx, rx), cy + rr(-ry, ry), rr(s0, s1)
        m |= ell(ex - s, ey - s * 2 // 3, ex + s, ey + s * 2 // 3)
    return m


def heather(cx, cy, rx, ry, n=6, s0=3, s1=6, outline=True, rp=HEATH, flowers=8):
    m = blobs(cx, cy, rx, ry, n, s0, s1)
    o = cv.obj(outline=outline)
    o.part(m, rp, d=2)
    o.draw()
    ys, xs = np.nonzero(m)
    for _ in range(flowers):   # flower spikes: light dots, plus a few stem flecks
        i = r(0, len(xs) - 1)
        x, y = int(xs[i]), int(ys[i])
        cv.dots([(x, y), (x, y - 1)], rp['r'])
    for _ in range(flowers // 3):
        i = r(0, len(xs) - 1)
        cv.dots([(int(xs[i]), int(ys[i]))], MOSS['s'])
    return m


def bracken(x, y, s=1.0, col=RUST):
    h = int(7 * s)
    cv.fill(line([(x, y), (x + 1, y - h)]), col['s'])
    for k in range(1, h, 2):
        cv.dots([(x - 1 - k // 3, y - k + 1), (x - 2 - k // 3, y - k + 2), (x + 2 + k // 3, y - k + 1), (x + 3 + k // 3, y - k + 2)], col['b'] if k % 4 else col['r'])


def cottongrass(x, y, h=6):
    cv.fill(rect(x, y - h, x, y), MOSS['s'])
    cv.dots([(x - 1, y - h - 1), (x, y - h - 1), (x, y - h - 2), (x + 1, y - h - 1), (x, y - h)], '#f6f4ee')
    cv.dots([(x + 1, y - h)], '#bdb8ac')


def puddle(x0, y0, x1, y1, rings=1, rr=None):
    rr = rr or r
    m = ell(x0, y0, x1, y1)
    cv.fill(dil4(m) & ~m, PEAT['s'])
    cv.fill(m, PUD['b'])
    cv.fill(m & ~shift(m, 0, 2), PUD['s'])
    cy = (y0 + y1) // 2
    cv.fill(m & rect(x0 + 3, cy, x0 + (x1 - x0) * 2 // 3, cy), PUD['r'])
    for _ in range(rings):   # raindrop rings
        px, py = rr(x0 + 3, x1 - 4), rr(y0 + 1, y1 - 1)
        ring = ell(px - 3, py - 1, px + 3, py + 1)
        cv.fill(ring & ~shift(ring, 1, 0) & m | ring & ~shift(ring, -1, 0) & m, PUD['r'])
    return m


def gnome(gx, gy, hat, coat, f=1.0, tip=-5, boots=BOOT):
    def X(v):
        return gx + int(round(v * f))

    def Y(v):
        return gy + int(round(v * f))
    o = cv.obj()
    o.part(rect(X(-7), Y(-3), X(-2), gy) | rect(X(1), Y(-3), X(6), gy), boots, d=1)
    o.part(rrect(X(-7), Y(-16), X(7), Y(-3), 2), coat, d=2, contour=True)
    o.part(rect(X(-7), Y(-7), X(7), Y(-6)), BELT, d=0)
    o.part(poly([(X(-7), Y(-20)), (X(7), Y(-20)), (X(1), Y(-6))]), BEARD, d=1, contour=True)
    o.part(rect(X(-5), Y(-25), X(5), Y(-19)), SKIN, d=1)
    o.part(poly([(X(-8), Y(-23)), (X(8), Y(-23)), (X(tip), Y(-42))]), hat, d=2, contour=True)
    o.draw()
    cv.fill(rect(X(-8), Y(-24), X(8), Y(-23)), hat['s'])
    cv.dots([(X(-2), Y(-22)), (X(2), Y(-22))], UMBER)
    cv.dots([(X(0), Y(-21)), (X(1), Y(-21))], '#e0907a')
    if f >= 0.8:
        cv.dots([(X(-4), Y(-20)), (X(4), Y(-20))], '#f0a0a0')
    return X, Y


# ---------------------------------------------------------------- sky: slate bands, layered clouds, a rain curtain, geese, gulls
cv.fill(rect(0, 12, W - 1, H - 1), SKY[1])
cv.fill(rect(0, 28, W - 1, H - 1), SKY[2])
cv.fill(rect(0, 44, W - 1, H - 1), SKY[3])
r3 = rnd(4242)   # third stream (pass 1 additions)
# a break in the cloud over the sea (cell 2,0): pale sky, a watery sun, hard light shafts slanting down to the water
gap = ell(44, -6, 84, 24)
cv.fill(gap, '#b3bbc5')
cv.fill(ell(50, -2, 78, 19), '#c8ced5')
cv.fill(ell(56, 1, 72, 15), '#dcd8bc')
cv.fill(ell(59, 3, 69, 13), '#f2e6b4')
cv.fill(ell(61, 4, 66, 9), '#fff4cc')
for k, (xa, xb) in enumerate(((56, 30), (61, 46), (66, 62), (71, 80), (75, 96))):   # sun shafts, each a slim wedge
    cv.fill(poly([(xa, 14), (xa + 2, 14), (xb + 3 + k, 62), (xb, 62)]) & ~gap, '#a3adb9' if k % 2 else '#b0b8c2')
# a rainbow stub coming down out of the storm cloud onto the far fells (cells 7-8, row 1)
rb_c = (240, 78)
for k, col in enumerate(('#b0505a', '#d99a4a', '#c9c06a', '#7f9a6a', '#6a7aa8', '#7e6496')):
    ro, ri = 54 - k * 2, 52 - k * 2
    band = ell(rb_c[0] - ro, rb_c[1] - ro, rb_c[0] + ro, rb_c[1] + ro) & ~ell(rb_c[0] - ri, rb_c[1] - ri, rb_c[0] + ri, rb_c[1] + ri)
    cv.fill(band & rect(150, 18, 240, 70), col)


def cloud(m, rp, base):
    """A cloud mask lit from the upper left, flat shaded underside at `base`."""
    m = m & ~rect(0, base + 1, W, H)
    cv.fill(m, rp['b'])
    cv.fill(m & ~shift(m, -2, -2) & rect(0, base - 4, W, base), rp['s'])
    cv.fill(m & ~shift(m, 1, 1), rp['r'])
    cv.fill(m & rect(0, base, W, base), rp['s'])
    return m


def cum(cx, cy, w):
    return ell(cx - w // 2, cy - 5, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 10, cx + w // 6, cy + 3) | ell(cx, cy - 8, cx + w // 2 - 6, cy + 4)


# storm cloud over the headland (cells 1-2,0) with a ragged rain curtain hanging to the sea
cloud(ell(14, -8, 50, 12) | ell(30, -4, 58, 14) | ell(20, 2, 40, 16) | ell(-6, -10, 22, 6), DCLOUD, 15)
for k in range(13):
    x0 = 20 + k * 3 + (k % 4)
    cv.fill(line([(x0, 16), (x0 - 6 - k % 3, 30 + (k * 7) % 13)]), DCLOUD['r'] if k % 3 else DCLOUD['s'])
# tall billowing tower (cell 3,0) over a flat dark streak (cell 3,1)
cloud(ell(76, 12, 108, 24) | ell(80, 2, 100, 18) | ell(86, -6, 104, 10) | ell(94, 6, 112, 22), CLOUD, 23)
cloud(ell(70, 34, 116, 39) | ell(82, 31, 104, 38), DCLOUD, 38)
# a high thin streak (cell 4,0) and a puff below the geese (cell 4,1)
cloud(ell(98, 3, 136, 7) | ell(108, 1, 126, 6), CLOUD, 6)
cloud(cum(114, 44, 24), CLOUD, 47)
cloud(cum(160, 44, 26) | ell(148, 40, 166, 47), DCLOUD, 47)   # low dark scud (cell 6,1)
# dark lumpy cloud (cell 6,0) and a lit cumulus with a hole of sky (cell 7,0)
cloud(cum(164, 12, 40) | ell(150, 8, 166, 18), DCLOUD, 17)
cm = cloud(cum(190, 10, 38) | ell(176, 10, 206, 18), CLOUD, 17)
cv.fill(ell(188, 7, 194, 10), SKY[1])
cv.fill(ell(188, 7, 194, 10) & ~shift(ell(188, 7, 194, 10), 0, 1), CLOUD['s'])
# the big rain cloud (cell 9,0) with a curtain of rain of uneven lengths (cell 9,1)
cloud(ell(220, -6, 262, 20) | ell(228, 8, 256, 26) | ell(214, 4, 236, 22) | ell(248, 0, 270, 16), DCLOUD, 25)
for k in range(11):
    x0 = 222 + k * 3 + (k * 5) % 3
    cv.fill(line([(x0, 26), (x0 - 5, 34 + (k * 11) % 17)]), DCLOUD['r'] if k % 2 else '#8b96a4')
# pale high cloud (cell 10,0) and a small light cumulus (cell 11,0)
cloud(ell(254, 2, 290, 8) | ell(262, -2, 282, 6), CLOUD, 8)
cloud(cum(288, 16, 28), CLOUD, 19)
# skein of geese heading home (cell 4,0-1), bigger, in a proper V
for k, (bx, by) in enumerate(((114, 12), (109, 15), (104, 18), (100, 21), (119, 15), (123, 18), (110, 26), (116, 29))):
    cv.dots([(bx - 2, by), (bx - 1, by - 1), (bx, by), (bx + 1, by - 1), (bx + 2, by), (bx, by + 1)], '#3e4654')
# gulls over the sea (cell 1,1) and over the fells (cell 10,0)
for bx, by in ((30, 38), (40, 42), (258, 14), (268, 18)):
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#e6e2d6')
    cv.dots([(bx + 2, by + 1)], '#566170')
# a murmuration of starlings wheeling over the fells (cell 10,1)
mm_ = ell(250, 28, 274, 46) | ell(260, 24, 282, 36) | ell(244, 38, 258, 46)
for _ in range(120):
    sx, sy = r3(244, 282), r3(24, 46)
    if mm_[sy, sx]:
        cv.dots([(sx, sy), (sx + 1, sy)] if r3(0, 2) else [(sx, sy)], '#3e4654')
# a grey heron flapping slowly home (cell 7,1)
hxh, hyh = 186, 36
cv.fill(poly([(hxh - 9, hyh - 6), (hxh, hyh), (hxh + 9, hyh - 7), (hxh + 6, hyh - 2), (hxh, hyh + 2), (hxh - 6, hyh - 1)]), '#566170')
cv.fill(line([(hxh - 8, hyh - 4), (hxh - 3, hyh - 1)]) | line([(hxh + 8, hyh - 5), (hxh + 4, hyh - 1)]), '#4f5560')
cv.fill(rect(hxh - 3, hyh, hxh + 4, hyh + 2), '#a3acb7')
cv.dots([(hxh - 4, hyh + 1), (hxh - 5, hyh + 1), (hxh - 6, hyh + 2), (hxh - 7, hyh + 2)], '#c9a23a')   # bill, neck tucked
cv.fill(rect(hxh + 5, hyh + 1, hxh + 9, hyh + 1), '#4f5560')   # trailing legs
# a curlew over the far moor (cell 11,0)
cv.dots([(276, 4), (277, 3), (278, 4), (279, 4), (280, 3), (281, 4), (279, 5), (282, 5), (283, 6)], '#3e4654')

# ---------------------------------------------------------------- fjord glimpse (left): headland, lighthouse, skerry with seals
sea = rect(0, 50, 110, 74)
cv.fill(sea, '#5f6e7e')
cv.fill(rect(0, 50, 110, 52), '#6c7b8a')   # paler far water under the sun shafts
cv.fill(poly([(34, 52), (70, 52), (90, 70), (50, 70)]), '#6f7e8d')   # sunlit path on the sea
for k in range(26):
    sx, sy = r(2, 104), r(56, 68)
    cv.fill(rect(sx, sy, sx + r(2, 6), sy), '#8796a4' if k % 3 else '#4f5d6c')
for k in range(14):   # whitecaps
    sx, sy = r3(30, 104), r3(53, 70)
    cv.dots([(sx, sy), (sx + 1, sy), (sx + 1, sy - 1)], '#c8ced5')
# the headland: a bold green-topped cliff, the lighthouse planted on it with the keeper's cottage
head = poly([(0, 38), (6, 36), (14, 37), (22, 40), (28, 46), (32, 54), (36, 62), (30, 66), (0, 68)])
cliff = poly([(22, 42), (28, 46), (32, 54), (36, 62), (30, 66), (18, 67), (22, 58), (20, 50)])
o = cv.obj()
o.part(head, MOSSF, d=2)
o.part(cliff, ramp('#6c7284', '#4f5560', '#8c95a6'), d=2)
o.draw()
for yy in range(50, 67, 4):   # rock strata in the cliff
    cv.fill(cliff & line([(18, yy + 1), (36, yy - 1)]), '#4f5560')
for _ in range(30):   # sheep-bitten turf on the headland slope
    x, y = r3(1, 26), r3(42, 66)
    if head[y, x] and not cliff[y, x]:
        cv.dots([(x, y), (x + 1, y)], MOSSF['s'] if r3(0, 2) else HEATHF['b'])
cv.fill(head & ~cliff & ~shift(head & ~cliff, 0, 2), MOSSF['r'])
for x in range(2, 24, 3):   # thrift tufts on the clifftop
    cv.dots([(x, 40 + (x * 7) % 4)], '#b07fb2' if x % 2 else '#e6e2d6')
o = cv.obj()
o.part(poly([(8, 40), (17, 40), (16, 22), (9, 22)]), ramp('#e6e2d6', '#bdb8ac', '#f6f4ee'), d=1)
o.part(rect(7, 20, 18, 21), ramp('#5e4030', '#3d2a1e'), d=0)
o.part(rect(9, 14, 16, 19), ramp('#f5dc8a', '#d9b85a'), d=0)
o.part(poly([(8, 14), (17, 14), (12, 9)]), ramp('#9a3a3a', '#742a2c', '#c05a50'), d=0)
o.part(rect(19, 34, 27, 40), ramp('#e6e2d6', '#bdb8ac', '#f6f4ee'), d=1)   # keeper's cottage
o.part(poly([(18, 34), (28, 34), (25, 30), (21, 30)]), ramp('#5e4030', '#3d2a1e'), d=0)
o.draw()
cv.fill(rect(8, 25, 16, 27) | rect(9, 32, 16, 34), WINE['b'])
cv.dots([(10, 23), (10, 24), (10, 28), (10, 29)], '#bdb8ac')
cv.fill(rect(10, 15, 15, 18), '#ffe08a')
cv.fill(rect(12, 15, 12, 18), '#3d2a1e')
cv.fill(rect(12, 37, 13, 40), '#3d2a1e')   # lighthouse door
cv.dots([(21, 36), (25, 36)], '#d98a2a')
cv.fill(poly([(17, 15), (44, 8), (44, 12), (17, 17)]), '#c8ced5')   # the lamp's beam, a hard pale wedge out to sea
cv.fill(poly([(17, 15), (44, 8), (44, 9)]), '#e6e2d6')
for sx, sy, w in ((34, 64, 16), (50, 66, 10)):   # skerry rocks
    m = ell(sx, sy - 4, sx + w, sy + 3) & ~rect(0, sy + 2, W, H)
    cv.fill(m, '#4f5560')
    cv.fill(m & ~shift(m, 1, 1), '#6c7284')
    cv.fill(rect(sx - 1, sy + 1, sx + w + 1, sy + 1), '#c8ced5')   # surf line
for sx, sy, fc in ((35, 58, 1), (43, 59, -1), (51, 61, 1)):   # seals hauled out, heads up, pale bellies
    cv.fill(ell(sx, sy, sx + 8, sy + 3), '#8b96a4')
    cv.fill(rect(sx + 1, sy + 3, sx + 7, sy + 3), '#c8ced5')
    hx0 = sx + 8 if fc > 0 else sx - 2
    cv.fill(rect(hx0, sy - 2, hx0 + 2, sy + 1), '#8b96a4')
    cv.dots([(hx0 + (2 if fc > 0 else 0), sy - 1)], UMBER)
    cv.dots([(sx + 1, sy)], '#a3acb7')
# a little fishing boat out on the fjord
o = cv.obj()
o.part(poly([(60, 54), (74, 54), (72, 57), (62, 57)]), WINE, d=1)
o.part(poly([(67, 53), (67, 43), (73, 52)]), ramp('#e6e2d6', '#bdb8ac', '#f6f4ee'), d=1)
o.draw()
cv.fill(rect(66, 42, 66, 54), '#3d2a1e')

# ---------------------------------------------------------------- far fells with mist in the folds
m = poly([(60, 64), (96, 50), (130, 58), (168, 44), (214, 56), (250, 46), (300, 58), (300, 80), (60, 80)])
cv.fill(m, '#7a8396')
cv.fill(m & ~shift(m, 2, 2), '#8c95a6')
for _ in range(60):   # far boulders and heather freckles
    x, y = r(64, 298), r(50, 78)
    if m[y, x] and m[max(0, y - 3), x]:
        cv.dots([(x, y), (x + 1, y)], '#6c7488' if r(0, 1) else '#7d7690')
m2 = poly([(84, 76), (120, 62), (160, 70), (200, 60), (244, 70), (276, 62), (300, 68), (300, 90), (84, 90)])
cv.fill(m2, '#6e7186')
cv.fill(m2 & ~shift(m2, 2, 2), '#7f8296')
for _ in range(70):
    x, y = r(86, 298), r(62, 88)
    if m2[y, x] and m2[max(0, y - 2), x]:
        cv.dots([(x, y), (x + 1, y), (x, y + 1)], HEATHF['b'] if r(0, 2) else '#5f6278')


def mist(y0, y1, n, xs=(-20, W + 20), rr=None):
    rr = rr or r
    mm = blank()
    for _ in range(n):
        x = rr(*xs)
        mm |= ell(x - rr(14, 34), y0 + rr(-2, 2), x + rr(14, 34), y1 + rr(-1, 2))
    cv.fill(mm, MIST[0])
    cv.fill(mm & ~shift(mm, 0, -2), MIST[1])   # cooler underside
    return mm


# a little kirk on the far fell (cell 11,1): nave, tower and a sharp spire
o = cv.obj()
o.part(rect(276, 48, 290, 56), ramp('#8c95a6', '#6c7488', '#a3acb7'), d=1)
o.part(poly([(275, 48), (291, 48), (288, 44), (278, 44)]), ramp('#5f6e7e', '#4f5560'), d=0)
o.part(rect(285, 36, 291, 50), ramp('#8c95a6', '#6c7488', '#a3acb7'), d=1)
o.part(poly([(284, 36), (292, 36), (288, 22)]), ramp('#5f6e7e', '#4f5560', '#7b8695'), d=1)
o.draw()
cv.dots([(288, 40), (288, 41), (279, 51), (282, 51)], '#f2b84a')
cv.fill(rect(288, 19, 288, 22) | rect(287, 20, 289, 20), '#4f5560')


def mist2(y0, y1, n, xs, rr):
    """Thick lying mist: long ragged lenses with a pale crown, a cool underside and torn wisps trailing off."""
    mm = blank()
    for _ in range(n):
        x, hw = rr(*xs), rr(18, 46)
        yy = rr(y0, y1)
        mm |= ell(x - hw, yy - rr(2, 4), x + hw, yy + rr(2, 4))
    for _ in range(n):   # wisps
        x, yy = rr(*xs), rr(y0 - 2, y1 + 2)
        mm |= rect(x, yy, x + rr(8, 22), yy)
    cv.fill(mm, MIST[0])
    cv.fill(mm & ~shift(mm, 0, 2), '#d3d8dd')
    cv.fill(mm & ~shift(mm, 0, -2), MIST[1])
    return mm


mist(64, 70, 9, (60, 300))
mist2(58, 66, 7, (100, 300), r3)
# nearer fell behind the cottage, with field walls drawn as lines
m3 = poly([(110, 92), (150, 80), (196, 76), (236, 82), (272, 74), (300, 78), (300, 100), (110, 100)])
cv.fill(m3, MOSSF['b'])
cv.fill(m3 & ~shift(m3, 2, 2), MOSSF['r'])
for pts in (((160, 84), (196, 90), (230, 86)), ((236, 82), (250, 92), (290, 88)), ((200, 79), (214, 92))):
    cv.fill(line(list(pts)) & m3, MOSSF['s'])
for _ in range(50):
    x, y = r(112, 298), r(76, 98)
    if m3[y, x] and m3[max(0, y - 2), x]:
        cv.dots([(x, y), (x + 1, y)], HEATHF['b'] if r(0, 1) else RUST['s'])
mist(78, 84, 8, (100, 300))
mist2(84, 92, 6, (130, 300), r3)

# ---------------------------------------------------------------- knoll with the Standing Stones (left)
knoll = poly([(0, 88), (20, 80), (48, 68), (76, 66), (100, 72), (116, 82), (124, 100), (0, 104)])
cv.fill(knoll, MOSSF['b'])
cv.fill(knoll & ~shift(knoll, 2, 2), MOSSF['r'])
for _ in range(14):
    hx_, hy_ = r(4, 116), r(70, 100)
    if knoll[hy_, hx_]:
        heather(hx_, hy_, 6, 2, n=3, s0=2, s1=4, outline=False, rp=HEATHF, flowers=4)
for _ in range(40):
    x, y = r(2, 120), r(64, 102)
    if knoll[y, x]:
        cv.dots([(x, y), (x, y - 1)], MOSS['b'] if r(0, 1) else RUST['s'])
STONES = ((32, 80, 5, 10), (50, 73, 6, 12), (70, 71, 6, 12), (90, 76, 5, 10), (18, 93, 8, 14), (38, 94, 9, 19), (62, 92, 8, 17), (84, 90, 8, 14))
for sx, sb, w, h in STONES:
    shadow(sx - 2, sb - 1, sx + w + 4, sb + 2, MOSSF['s'])
    o = cv.obj()
    o.part(poly([(sx, sb), (sx + w, sb), (sx + w - 1, sb - h + 2), (sx + w - 3, sb - h), (sx + 1, sb - h + 1)]), STONE, d=2)
    o.draw()
    cv.dots([(sx + 2, sb - h + 2), (sx + 3, sb - h + 2), (sx + 2, sb - h + 3)], MOSS['b'])   # moss cap
    cv.dots([(sx + 1 + r(0, w - 3), sb - r(3, h - 4)) for _ in range(2)], '#c8c27a')       # map lichen
    cv.fill(line([(sx + w // 2, sb - h + 4), (sx + w // 2 + 1, sb - h // 2)]), STONED)     # crack
cv.dots([(41, 75), (42, 75)], '#d9b85a')   # a lucky coin on the tallest stone
cv.dots([(65, 75)], '#d9b85a')

# ---------------------------------------------------------------- the moor (mid and fore ground)
moor = poly([(0, 102), (60, 100), (124, 98), (160, 94), (220, 96), (300, 94), (300, 199), (0, 199)])
cv.fill(moor, MOSS['b'])
cv.fill(moor & rect(0, 150, W, H), '#64733f')
for y in range(100, H, 2):   # grass flecks, denser lower down
    for _ in range(3 if y < 140 else 5):
        gx = r(0, W - 1)
        if moor[y, gx]:
            cv.dots([(gx, y), (gx, y - 1)], MOSS['r'] if r(0, 2) else MOSS['s'])

# ---------------------------------------------------------------- the burn: from the fell down under the bridge to the front edge
burn_pts = [(178, 95), (166, 99), (156, 104), (150, 112), (138, 120), (130, 132), (124, 144), (112, 158), (102, 172), (96, 186), (100, 199)]
burn = blank()
for i in range(len(burn_pts) - 1):
    w = 3 + i * 2 if i < 4 else 3 + i * 3
    burn |= line([burn_pts[i], burn_pts[i + 1]], w)
    burn |= ell(burn_pts[i + 1][0] - w // 2, burn_pts[i + 1][1] - w // 2, burn_pts[i + 1][0] + w // 2, burn_pts[i + 1][1] + w // 2)
cv.fill(dil4(dil4(burn)) & ~burn, PEAT['b'])      # dark peaty banks
cv.fill(dil4(burn) & ~burn, PEAT['s'])
cv.fill(burn, WATER['b'])
cv.fill(burn & ~shift(burn, 0, 3), WATER['s'])
for _ in range(160):   # ripples and sky glints
    x, y = r(90, 170), r(96, 199)
    if burn[y, x] and burn[y, min(W - 1, x + 4)]:
        cv.fill(rect(x, y, x + r(2, 5), y), WATER['r'] if r(0, 2) else PUD['b'])
for sx, sy in ((104, 178), (118, 156), (92, 192), (140, 118)):   # stones in the burn, with foam
    o = cv.obj()
    o.part(ell(sx, sy, sx + 6, sy + 4), STONE, d=1)
    o.draw()
    cv.dots([(sx - 1, sy + 4), (sx + 7, sy + 3), (sx + 8, sy + 4)], '#e6e2d6')

# ---------------------------------------------------------------- the humped stone bridge
bx0, bx1, btop = 104, 160, 120
deck = poly([(bx0, 136), (bx0 + 8, 128), (bx0 + 20, btop + 2), (bx0 + 36, btop + 2), (bx1 - 8, 128), (bx1, 136), (bx1, 140), (bx0, 140)])
arch = ell(118, 128, 146, 152) & ~rect(0, 141, W, H)
shadow(bx0 - 4, 138, bx1 + 4, 144, PEAT['s'])
o = cv.obj()
o.part(deck & ~arch, STONE, d=2)
o.draw()
cv.fill(arch & rect(0, 0, W, 140), '#2e2620')   # dark under the arch
cv.fill(arch & rect(0, 137, W, 140), WATER['s'])
cv.fill(rect(122, 139, 142, 139) & arch, WATER['r'])
# stone courses and voussoirs
for k in range(14):
    a = k / 13.0
    x = 118 + int(a * 28)
    yy = int(140 - 12 * (1 - (2 * a - 1) ** 2))
    cv.dots([(x, yy - 1), (x, yy - 2)], STONED)
for yy in range(126, 139, 4):
    for xx in range(bx0 + 2 + (yy % 8), bx1 - 2, 7):
        if deck[yy, xx] and not arch[yy, xx] and not arch[yy + 1, xx]:
            cv.dots([(xx, yy), (xx + 1, yy), (xx + 2, yy)], STONED)
            cv.dots([(xx + 3, yy - 1)], STONE['r'])
par = poly([(bx0 + 1, 133), (bx0 + 9, 125), (bx0 + 20, btop - 1), (bx0 + 36, btop - 1), (bx1 - 9, 125), (bx1 - 1, 133), (bx1 - 1, 135), (bx0 + 1, 135)]) & ~deck
cv.fill(par, STONE['r'])   # lit coping stones along the top
for xx in range(bx0 + 4, bx1 - 3, 5):
    cv.fill(rect(xx, 0, xx, H) & par, STONE['s'])
cv.dots([(x, 120 + r(0, 1)) for x in range(126, 138, 4)], MOSS['b'])   # moss on the coping

# ---------------------------------------------------------------- the cottage: low rubble walls, thick turf roof, peat smoke, one lantern
cx0, cx1 = 196, 280
shadow(cx0 - 6, 138, cx1 + 10, 145)
o = cv.obj()
o.part(rect(cx0, 110, cx1, 140), STONE, d=3)
o.part(rect(cx0 + 6, 78, cx0 + 15, 104), STONE, d=2)   # chimney at the gable end
o.draw()
for yy in range(113, 140, 4):   # rubble courses
    off = (yy // 4) % 2 * 4
    cv.fill(rect(cx0 + 1, yy, cx1 - 1, yy), STONE['s'])
    for xx in range(cx0 + 2 + off, cx1 - 1, 8 + (yy % 3)):
        cv.fill(rect(xx, yy - 3, xx, yy), STONE['s'])
        cv.dots([(xx + 1, yy - 3), (xx + 2, yy - 3)], STONE['r'])
for xx in range(cx0 + 7, cx0 + 15, 4):
    cv.fill(rect(xx, 84, xx + 2, 84), STONE['s'])
    cv.fill(rect(xx - 1, 92, xx + 1, 92), STONE['s'])
cv.fill(rect(cx0 + 5, 76, cx0 + 16, 78), STONED)   # chimney cap
cv.fill(rect(cx0 + 8, 74, cx0 + 10, 76) | rect(cx0 + 12, 75, cx0 + 13, 76), '#a85a2c')   # two clay pots
for _ in range(16):   # (keeps the r2 stream where the old bead-string smoke left it)
    r2(0, 1)
# peat smoke: a thin column that rises, gets caught by the wind and streams off flat to the left, fraying into torn wisps
pm = blank()
for i in range(0, 41):
    t = i / 40.0
    sx = cx0 + 10 - int(40 * t ** 1.2)
    sy = 74 - int(28 * t ** 0.5) + int(1.5 * np.sin(t * 9))
    hw, hh = 1 + int(6 * t) + r3(0, 2), 1 + int(3 * t) + r3(0, 1)
    if t > 0.6 and (i // 3) % 3 == 2:   # breaking up into puffs
        continue
    pm |= ell(sx - hw, sy - hh, sx + hw, sy + hh)
for k in range(3):   # torn wisps blown ahead of the plume
    wx, wy = 160 - k * 6 + r3(-2, 2), 42 - k * 3 + r3(-1, 1)
    pm |= ell(wx - 5 - k, wy - 1 - (k % 2), wx + 5, wy + 1)
pm &= ~rect(cx0 + 4, 75, cx0 + 18, H)
cv.fill(pm, '#9a9ca4')
cv.fill(pm & rect(0, 0, 172, H), '#a7a9b0')
cv.fill(pm & ~shift(pm, 1, 1), '#b3bbc5')
cv.fill(pm & ~shift(pm, -1, -2), '#8a8c94')
roof = poly([(cx0 - 6, 114), (cx0 + 4, 98), (cx1 - 4, 96), (cx1 + 8, 114)]) | blobs((cx0 + cx1) // 2, 98, 38, 2, 14, 4, 7)
roof &= ~rect(0, 116, W, H)
o = cv.obj()
o.part(roof, TURF, d=3)
o.draw()
cv.fill(rect(cx0 - 5, 114, cx1 + 7, 115), PEAT['b'])   # birch-bark layer under the turf
cv.fill(rect(cx0 - 5, 115, cx1 + 7, 115), PEAT['s'])
ys, xs = np.nonzero(roof)
for k in range(60):   # grass, heather and cottongrass growing on the roof
    i = r(0, len(xs) - 1)
    x, y = int(xs[i]), int(ys[i])
    if y > 112:
        continue
    c = (TURF['r'], TURF['s'], HEATH['b'], HEATH['r'], MOSS['r'])[k % 5]
    cv.dots([(x, y), (x, y - 1)], c)
for x in range(cx0 - 4, cx1 + 7, 5):   # drips off the eaves
    cv.dots([(x, 117 + (x % 3)), (x, 118 + (x % 3))], RAIN)
# door with a lit lantern beside it
o = cv.obj()
o.part(rrect(232, 118, 245, 140, 3), DOOR, d=2)
o.draw()
cv.fill(rect(238, 120, 239, 139), DOOR['s'])
cv.dots([(243, 130)], '#d9b85a')
cv.fill(rect(231, 140, 246, 141), STONE['r'])   # doorstep
glow = ell(244, 112, 258, 128) & ~rrect(232, 118, 245, 140, 3)
cv.fill(glow & rect(cx0, 110, cx1, 140), '#b4a88c')   # warm wash on the wall (hard pixel halo)
cv.fill(rect(250, 112, 252, 114), UMBER)   # bracket
o = cv.obj()
o.part(rect(248, 115, 254, 123), WARM, d=1)
o.draw()
cv.fill(rect(248, 115, 254, 115) | rect(248, 123, 254, 123) | rect(251, 115, 251, 123), '#3d2a1e')
cv.dots([(249, 117), (249, 118)], WARM['r'])
for wx0, wx1 in ((206, 220), (258, 272)):   # deep-set windows, amber light inside
    o = cv.obj()
    o.part(rect(wx0, 119, wx1, 130), WARM, d=2)
    o.draw()
    cv.fill(rect((wx0 + wx1) // 2, 119, (wx0 + wx1) // 2, 130) | rect(wx0, 124, wx1, 124), '#3d2a1e')
    cv.fill(rect(wx0 - 1, 131, wx1 + 1, 132), STONE['r'])
    cv.dots([(wx0 + 2, 121), (wx0 + 2, 122)], WARM['r'])
cv.fill(rect(260, 126, 262, 129) | rect(261, 125, 261, 125), UMBER)   # the house cat in the window
cv.dots([(260, 125), (262, 125)], UMBER)
cv.fill(rect(208, 127, 211, 129), MOSS['s'])   # a pot of something green
cv.dots([(209, 126), (210, 125)], MOSS['r'])
# water butt and peat stack against the gable
o = cv.obj()
o.part(rrect(282, 124, 292, 140, 2), WOOD, d=2)
o.draw()
cv.fill(rect(282, 128, 292, 128) | rect(282, 136, 292, 136), '#3d2a1e')
cv.fill(rect(283, 124, 291, 124), PUD['b'])
for k in range(5):
    cv.fill(rect(294, 110 + k * 6, 299, 112 + k * 6), PEAT['b'])
    cv.fill(rect(294, 113 + k * 6, 299, 113 + k * 6), PEAT['s'])
    cv.dots([(295 + k % 3, 111 + k * 6)], PEAT['r'])
cv.fill(rect(293, 108, 299, 109), TURF['s'])
# pub sign of the Crooked Kettle: post, arm, a board with a kettle on it (no words)
o = cv.obj()
o.part(rect(186, 104, 188, 142), WOOD, d=1)
o.part(rect(174, 104, 188, 105), WOOD, d=0)
o.part(rect(174, 108, 186, 120), PEAT, d=1)
o.draw()
cv.dots([(176, 106), (176, 107), (184, 106), (184, 107)], UMBER)
cv.fill(ell(177, 113, 183, 118), '#e6e2d6')
cv.fill(line([(183, 115), (185, 112)]), '#e6e2d6')
cv.fill(ell(178, 110, 182, 114) & ~ell(179, 111, 181, 113) & rect(0, 0, W, 112), '#e6e2d6')
cv.dots([(186 - 1, 111), (184, 110)], '#bdb8ac')
cv.dots([(178, 115)], '#f6f4ee')

# ---------------------------------------------------------------- the muddy track from the door to the front edge, with puddles
track = poly([(230, 142), (248, 142), (256, 156), (266, 170), (282, 186), (292, 199), (216, 199), (222, 182), (228, 166), (230, 154)])
cv.fill(track, MUD['b'])
cv.fill(track & ~shift(track, 2, 0), MUD['r'])
cv.fill(track & ~shift(track, -2, 0), MUD['s'])
for pts in (((236, 146), (236, 166), (232, 186), (230, 199)), ((244, 146), (252, 166), (264, 186), (272, 199))):   # cart ruts
    cv.fill(line(list(pts)) & track, MUD['s'])
for _ in range(40):
    px, py = r(218, 290), r(144, 199)
    if track[py, px]:
        cv.dots([(px, py)], MUD['r'] if r(0, 1) else STONE['b'])
TRACK_PUDDLES = ((234, 152, 248, 156), (244, 166, 262, 171), (226, 184, 252, 192))
for p in TRACK_PUDDLES:
    puddle(*p, rings=2)

# ---------------------------------------------------------------- drystone walls (bridge to cottage, and along the front of the garden)


def drystone(pts, th=7):
    band = blank()
    for i in range(len(pts) - 1):
        (xa, ya), (xb, yb) = pts[i], pts[i + 1]
        band |= poly([(xa, ya - th), (xb, yb - th), (xb, yb), (xa, ya)])
    o = cv.obj()
    o.part(band, STONE, d=1)
    o.draw()
    ys_, xs_ = np.nonzero(band)
    for k in range(len(xs_) // 14):
        i = r2(0, len(xs_) - 1)
        x, y = int(xs_[i]), int(ys_[i])
        st = ell(x - 2, y - 1, x + 2, y + 1) & band
        cv.fill(st, (STONE['b'], STONE['r'], '#8a8c86')[k % 3])
        cv.fill(st & ~shift(st, -1, -1), STONED)
    tops = band & ~shift(band, 0, 1)
    ty, tx = np.nonzero(tops)
    for i in range(0, len(tx), 3):   # upright coping stones
        cv.dots([(int(tx[i]), int(ty[i]) - 1)], STONE['s'] if i % 2 else STONE['b'])
    return band


wall1 = drystone([(160, 136), (176, 137), (192, 140)], 6)
wall2 = drystone([(150, 158), (190, 152), (226, 150)], 7)
wall3 = drystone([(254, 150), (276, 151), (300, 149)], 7)
for gpx in (226, 252):   # gateposts
    o = cv.obj()
    o.part(rect(gpx, 136, gpx + 4, 152), STONE, d=2)
    o.draw()
    cv.dots([(gpx + 1, 138), (gpx + 2, 144)], '#c8c27a')
# Professor Hoot on the right gatepost
ox, oy = 254, 135
o = cv.obj()
o.part(ell(ox - 5, oy - 9, ox + 5, oy + 1), ramp('#8a6a4a', '#6a4c34', '#a88a6a'), d=2)
o.part(rect(ox - 4, oy - 11, ox - 3, oy - 9) | rect(ox + 3, oy - 11, ox + 4, oy - 9), ramp('#6a4c34', '#4e3626'), d=0)
o.draw()
cv.fill(ell(ox - 4, oy - 8, ox - 1, oy - 5) | ell(ox + 1, oy - 8, ox + 4, oy - 5), '#e6e2d6')
cv.dots([(ox - 2, oy - 6), (ox + 2, oy - 6)], UMBER)
cv.dots([(ox, oy - 5), (ox, oy - 4)], '#d9a35a')
cv.dots([(ox - 2, oy - 2), (ox, oy - 1), (ox + 2, oy - 2)], '#e6e2d6')

# ---------------------------------------------------------------- the peat bank (front left): cut face, wet floor, leaning stacks
bank_top = poly([(0, 136), (40, 138), (84, 144), (88, 150), (0, 146)])
face = poly([(0, 146), (88, 150), (90, 164), (0, 160)])
floor = poly([(0, 160), (90, 164), (94, 174), (80, 199), (0, 199)])
cv.fill(floor & ~burn & ~dil4(dil4(burn)), PEAT['r'])
cv.fill(face, PEAT['b'])
cv.fill(face & rect(0, 0, W, 151), '#7a5a40')   # fibrous light top layer under the turf
for k, yy in enumerate((152, 156, 159)):   # wavy layers in the cut face
    pts = [(x, yy + int(1.4 * np.sin(x / (5.0 + k) + k * 2))) for x in range(0, 92, 3)]
    cv.fill(face & line(pts), PEAT['s'] if k != 1 else '#4a3424')
for sx, sy, w in ((8, 154, 7), (30, 155, 9), (51, 157, 6), (70, 156, 8)):   # stepped cuts where turves came out
    st = rect(sx, sy, sx + w, sy + 4) & face
    cv.fill(st, '#33231a')
    cv.fill(st & ~shift(st, 0, 1), '#4a3424')
    cv.fill(rect(sx, sy + 5, sx + w, sy + 5) & face, PEAT['r'])
for x0, y0, x1, y1 in ((18, 158, 26, 157), (44, 152, 49, 154), (60, 160, 66, 159), (82, 153, 86, 156)):   # bog-oak roots in the peat
    cv.fill(line([(x0, y0), (x1, y1)]) & face, '#94765a')
cv.fill(face & ~shift(face, 0, 1), '#33231a')
cv.fill(bank_top, MOSS['b'])
for k, hx_ in enumerate((5, 14, 27, 38, 46, 59, 70, 81)):   # heather overhanging the cut edge
    heather(hx_, 144 + k // 2 + (k % 3) - 1, 4 + k % 3, 1, n=3, s0=2 + k % 2, s1=4 + k % 2, flowers=5)
ys, xs = np.nonzero(floor & ~dil4(dil4(burn)))
for _ in range(80):
    i = r(0, len(xs) - 1)
    cv.dots([(int(xs[i]), int(ys[i]))], PEAT['b'] if r(0, 1) else MUD['s'])
TURVE = ramp('#7a5a40', '#5a3e2c', '#94765a')
for si, (sx, sy) in enumerate(((10, 178), (26, 182), (44, 178), (14, 196))):   # drying stacks: brick-like turves piled in a little pyramid
    o = cv.obj()
    rows = ((-8, 4), (-6, 3), (-4, 2)) if si != 1 else ((-8, 4), (-6, 3))
    bricks = []
    for ri, (x0, n) in enumerate(rows):
        for b in range(n):
            bx_, by_ = sx + x0 + b * 4 + (si % 2), sy - ri * 4
            bricks.append((bx_, by_))
            o.part(rect(bx_, by_ - 3, bx_ + 3, by_), TURVE, d=1)
    o.draw()
    for k, (bx_, by_) in enumerate(bricks):
        cv.fill(rect(bx_, by_ - 3, bx_ + 3, by_ - 3), TURVE['r'] if k % 3 else '#a87a50')   # lit top of each turve
        cv.fill(rect(bx_ + 3, by_ - 2, bx_ + 3, by_), PEAT['s'])                          # shaded end
        cv.dots([(bx_ + 1 + k % 2, by_ - 1)], PEAT['b'])                                   # fibrous fleck
    cv.dots([(sx - 9, sy + 1), (sx + 9, sy + 1)], '#3d2a1e')
puddle(56, 186, 76, 191, rings=1)
# the peat cutter, with a long flat spade cutting into the face
X, Y = gnome(66, 176, RUST, MOSS, f=0.9, tip=-8)
o = cv.obj()
o.part(line([(X(8), Y(-15)), (82, 156)], 2), WOOD, d=1)
o.part(poly([(80, 154), (86, 158), (84, 163), (78, 159)]), STONE, d=1)
o.draw()
cv.fill(rect(X(6), Y(-15), X(9), Y(-12)), SKIN['b'])
cv.fill(rect(X(-10), Y(-4), X(-8), Y(0)), WOOD['s'])   # a wheelbarrow handle peeking
# a barrow of cut turves
o = cv.obj()
o.part(poly([(34, 164), (54, 164), (51, 171), (37, 171)]), WOOD, d=2)
o.part(ell(38, 169, 44, 175), BOOT, d=1, contour=True)
o.draw()
for k in range(4):
    cv.fill(rect(36 + k * 4, 160, 39 + k * 4, 163), PEAT['b'])
    cv.dots([(36 + k * 4, 160)], PEAT['r'])

# ---------------------------------------------------------------- a bent hawthorn on the knoll's foot (wind-shaped, leaning away from the sea)
for _ in range(114):   # (keeps the r stream where the old pom-pom crown left it)
    r(0, 1)
# trunk: low, thick and twisted, bowed hard over to leeward; a few bare snags on the windward side
o = cv.obj()
o.part(poly([(10, 140), (20, 140), (21, 132), (26, 122), (36, 114), (50, 108), (60, 106), (58, 103), (44, 104), (30, 110), (18, 120), (13, 130)]), WOOD, d=2)
o.part(line([(24, 124), (34, 120), (44, 118)], 2) | line([(38, 110), (52, 112)], 1), WOOD, d=1)
o.draw()
cv.fill(line([(14, 134), (19, 128), (24, 122)]), WOOD['s'])   # bark twist
cv.fill(line([(15, 126), (9, 118), (6, 116)]) | line([(9, 118), (8, 112)]) | line([(22, 118), (18, 110), (14, 108)]), '#5e4030')
# crown: one low wind-combed mass, thin and clipped on the sea side, streaming out long to the right
crown = poly([(16, 108), (22, 102), (32, 98), (46, 96), (58, 96), (68, 99), (74, 103), (64, 106), (54, 108), (44, 110), (30, 112), (20, 112)])
for k in range(7):
    cx_ = 24 + k * 6 + r3(-2, 2)
    crown |= ell(cx_ - 5, 94 + (k % 3) - k // 3, cx_ + 6, 102 + (k % 2))   # lumpy top
for k in range(4):   # ragged underside
    crown &= ~ell(28 + k * 11, 109 + k % 2, 34 + k * 11, 114)
crown &= ~rect(0, 0, 18, 102)
o = cv.obj()
o.part(crown, TURF, d=2)
o.draw()
for k in range(5):   # combed streaks inside the crown
    yy = 100 + k * 2
    cv.fill(line([(28 + k * 5, yy), (46 + k * 5, yy - 1)]) & crown & ~shift(crown, 0, 2), TURF['s'])
ys, xs = np.nonzero(crown)
for k in range(26):
    i = r3(0, len(xs) - 1)
    x, y = int(xs[i]), int(ys[i])
    cv.dots([(x, y)] + ([(x + 1, y)] if k % 3 == 0 else []), WINE['b'] if k % 2 else ('#c05a50' if k % 3 else TURF['r']))   # haws

# ---------------------------------------------------------------- sheep on the moor
SHEEP = ((88, 108, 1), (60, 118, 1), (184, 162, -1), (276, 158, -1))
for shx, shy, fc in SHEEP:
    shadow(shx - 2, shy + 9, shx + 15, shy + 12)
    o = cv.obj()
    o.part(rect(shx + 2, shy + 6, shx + 3, shy + 10) | rect(shx + 10, shy + 6, shx + 11, shy + 10), BOOT, d=0)
    o.part(blobs(shx + 7, shy + 3, 3, 1, 6, 3, 4, r2) | ell(shx + 1, shy, shx + 14, shy + 8), WOOL, d=2)
    hx0 = shx - 5 if fc > 0 else shx + 13
    o.part(ell(hx0, shy + 2, hx0 + 6, shy + 8), BOOT, d=1)
    o.draw()
    cv.dots([(hx0 + (1 if fc > 0 else 4), shy + 4)], '#e6e2d6')
    for k in range(4):
        cv.dots([(shx + 4 + r2(0, 8), shy + 1 + r2(0, 4))], WOOL['s'])

# ---------------------------------------------------------------- moor plants: heather drifts, bracken, cottongrass, sphagnum
for hx_, hy_, rx, ry, n in ((196, 146, 10, 2, 5), (78, 116, 8, 2, 4), (40, 124, 10, 3, 5), (62, 134, 9, 2, 4),
                            (178, 128, 6, 2, 3), (140, 150, 8, 2, 4), (206, 168, 10, 3, 5), (160, 176, 10, 3, 5),
                            (296, 178, 6, 3, 4), (186, 190, 10, 3, 6), (136, 194, 12, 3, 6), (210, 196, 8, 2, 4), (118, 106, 6, 2, 3)):
    heather(hx_, hy_, rx, ry, n=n, s0=3, s1=6, flowers=10)
for bx, by, s in ((90, 112, 0.8), (96, 110, 0.7), (190, 132, 0.8), (124, 166, 1.0), (150, 186, 1.1), (276, 192, 1.1), (212, 158, 1.0),
                  (284, 170, 1.0), (54, 128, 0.8), (32, 132, 0.9), (166, 140, 0.9), (174, 196, 1.2), (122, 186, 1.1), (6, 128, 0.8)):
    bracken(bx, by, s)
for cx, cy in ((84, 128), (92, 132), (146, 136), (152, 132), (198, 160), (204, 186), (170, 162), (178, 168), (140, 170),
               (268, 158), (276, 184), (296, 192), (118, 196), (130, 178), (24, 132), (156, 196), (190, 172)):
    cottongrass(cx, cy, r(4, 7))
for sx, sy in ((150, 166), (190, 180), (272, 196)):   # sphagnum cushions, green and red
    m = blobs(sx, sy, 5, 1, 4, 2, 3)
    cv.fill(m, '#8fa058')
    ys, xs = np.nonzero(m)
    for _ in range(8):
        i = r(0, len(xs) - 1)
        cv.dots([(int(xs[i]), int(ys[i]))], '#a85a4a' if r(0, 1) else '#b8c070')
puddle(160, 142, 176, 146, rings=1)
puddle(176, 154, 192, 158, rings=1)
puddle(260, 176, 270, 179, rings=1)

# ---------------------------------------------------------------- fairy ring of toadstools (front centre-right of the burn)
TOADS = ((132, 172, 'fly'), (142, 168, 'par'), (154, 170, 'ink'), (162, 176, 'fly'), (164, 186, 'puff'), (156, 192, 'cha'), (142, 194, 'fly'), (132, 186, 'par'))
for tx, ty, kind in TOADS:
    if kind == 'fly':
        cap, stem = ramp('#b8483a', '#8a2c2a', '#d06a50'), WOOL
    elif kind == 'par':
        cap, stem = ramp('#c9b08a', '#9a8060', '#e6d2aa'), WOOL
    elif kind == 'ink':
        cap, stem = ramp('#7b8695', '#566170', '#a3acb7'), WOOL
    elif kind == 'cha':
        cap, stem = ramp('#d9a23a', '#a87a24', '#f0c862'), ramp('#d9a23a', '#a87a24')
    else:
        cap, stem = WOOL, WOOL
    o = cv.obj()
    if kind == 'puff':
        o.part(ell(tx - 3, ty - 5, tx + 3, ty), cap, d=2)
    else:
        o.part(ell(tx - 4, ty - 7, tx + 4, ty - 2) & ~rect(0, ty - 3, W, H), cap, d=2)
        o.part(rect(tx - 1, ty - 3, tx + 1, ty), stem, d=1)
    o.draw()
    if kind == 'fly':
        cv.dots([(tx - 2, ty - 5), (tx + 1, ty - 6), (tx + 2, ty - 4)], '#f6f4ee')
# a frog on a stone by the burn
fx, fy = 112, 190
o = cv.obj()
o.part(ell(fx - 6, fy, fx + 6, fy + 5), STONE, d=1)
o.part(ell(fx - 4, fy - 4, fx + 3, fy + 1), MOSS, d=1)
o.draw()
cv.dots([(fx - 3, fy - 4), (fx + 1, fy - 4)], '#f6f4ee')
cv.dots([(fx - 3, fy - 3), (fx + 1, fy - 3)], UMBER)
cv.fill(rect(fx - 2, fy - 1, fx + 1, fy - 1), MOSS['s'])

# ---------------------------------------------------------------- gnomes: kite flyer at the stones, umbrella on the bridge, puddle-jumper on the track
kx, ky = 112, 100
X, Y = gnome(kx, ky, WINE, HEATH, f=0.6, tip=-3)
kite = poly([(137, 12), (145, 21), (137, 32), (129, 21)])
o = cv.obj()
o.part(kite, HEATH, d=1)
o.draw()
cv.fill(kite & rect(137, 0, W, 21), MUST['b'])
cv.fill(kite & rect(0, 21, 137, H), MUST['b'])
cv.fill(line([(137, 12), (137, 32)]) | line([(129, 21), (145, 21)]), '#3d2a1e')
cv.fill(line([(X(6), Y(-12)), (126, 66), (137, 32)]), '#3d2a1e')   # a sagging string
cv.fill(line([(137, 32), (134, 36), (138, 41), (135, 46), (139, 50)]), '#3d2a1e')
for k, (tx, ty) in enumerate(((135, 35), (137, 39), (136, 44), (138, 48))):   # tail bows
    cv.dots([(tx - 1, ty - 1), (tx + 1, ty - 1), (tx, ty), (tx - 1, ty + 1), (tx + 1, ty + 1)], MUST['b'] if k % 2 else WINE['r'])
# umbrella gnome crossing the bridge
ux, uy = 132, 125   # walking along the deck behind the parapet (boots hidden by the coping)
X, Y = gnome(ux, uy, WINE, SLATEC, f=0.75, tip=-2)
hide = (deck | par) & rect(ux - 8, uy - 4, ux + 8, uy + 1)
cv.fill(hide, STONE['b'])
cv.fill(par & hide, STONE['r'])
for xx in range(bx0 + 4, bx1 - 3, 5):
    cv.fill(rect(xx, 0, xx, H) & par & hide, STONE['s'])
cv.fill(rect(ux - 8, uy - 4, ux + 8, uy + 1) & dil4(par) & ~par & ~deck, UMBER)
canopy = ell(X(-17), Y(-52), X(17), Y(-30)) & ~rect(0, Y(-40) + 1, W, H)
for k in range(5):
    bx = X(-17) + k * int(34 * 0.75) // 4
    canopy &= ~ell(bx - 3, Y(-40) - 1, bx + 3, Y(-40) + 3)
o = cv.obj()
o.part(canopy, UMB, d=2)
o.draw()
for k in (-1, 1):
    cv.fill(line([(X(0), Y(-52)), (X(9 * k), Y(-41))]) & canopy, UMB['r'])
cv.fill(rect(X(0), Y(-55), X(0), Y(-52)), UMBER)
cv.fill(line([(X(0), Y(-40)), (X(0), Y(-14))]), '#3d2a1e')
cv.fill(rect(X(-1), Y(-15), X(2), Y(-12)), SKIN['b'])
for dx in (-12, -4, 4, 12):   # drips off the umbrella ribs
    cv.dots([(X(dx), Y(-37)), (X(dx), Y(-35))], RAIN)
# child puddle-jumping, mid-air above the big puddle, with a splash
jx, jy = 240, 168
cv.fill(ell(jx - 8, 186, jx + 8, 189), PUD['s'])   # the child's shadow on the water, well below the boots
for k, dx in enumerate((-13, -10, -7, 7, 10, 13)):   # splash crown: short droplet arcs flung outward off the rim
    sgn = -1 if dx < 0 else 1
    h = 4 + (k % 3)
    cv.fill(line([(jx + dx, 186), (jx + dx + sgn * 2, 186 - h), (jx + dx + sgn * 4, 186 - h + 1)]), '#e6e2d6' if k % 2 else PUD['r'])
    cv.dots([(jx + dx + sgn * 5, 186 - h + 3)], '#e6e2d6')
for dx, dy in ((-16, 177), (17, 176), (-18, 182), (19, 181), (-14, 172), (15, 171)):   # flung droplets
    cv.dots([(jx + dx, dy), (jx + dx, dy + 1)], '#e6e2d6')
X, Y = gnome(jx, jy, WINE, MUST, f=0.8, tip=-10, boots=MUST)
for dx in (-4, 0, 3):   # speed lines under the boots: he is in the air
    cv.fill(rect(jx + dx, jy + 3, jx + dx, jy + 6 + (dx % 2)), '#bfc7ce')
cv.fill(rect(X(-11), Y(-15), X(-8), Y(-12)) | rect(X(8), Y(-15), X(11), Y(-12)), MUST['b'])   # arms flung up
cv.dots([(X(-11), Y(-17)), (X(-10), Y(-17)), (X(10), Y(-17)), (X(11), Y(-17))], SKIN['b'])
KEEP = rect(jx - 20, jy - 36, jx + 20, jy + 22) | rect(ux - 16, uy - 46, ux + 16, uy + 2) | rect(kx - 8, ky - 28, kx + 8, ky + 2) | rect(0, 6, 46, 68) | \
    rect(48, 140, 92, 178) | rect(ox - 7, oy - 12, ox + 7, oy + 2) | rect(174, 104, 188, 120) | rect(204, 116, 274, 134)

# ---------------------------------------------------------------- drizzle over everything (short slanting streaks)
for k in range(520):
    x, y = r2(2, W - 1), r2(0, H - 3)
    if KEEP[y, x] or (y > 100 and k % 2):
        continue
    cv.dots([(x, y), (x - 1, y + 1)] + ([(x - 2, y + 2)] if y < 100 else []), RAIN)

# fold rare one-off tones into their neighbours to stay under ~100 colours
cv.remap({'#d9a35a': '#d9b85a', '#f0c862': '#e8c862', '#d9a23a': '#c9a23a', '#a87a24': '#9a7a24', '#6c7284': '#6c7488', '#7d7690': '#7a6286',
          '#e6d2aa': '#e6e2d6', '#9a8060': '#94765a', '#c9b08a': '#b4a88c', '#a88a6a': '#a87a50', '#8a6a4a': '#8a6040', '#6a4c34': '#6a5444',
          '#b8c070': '#c8c27a', '#a85a4a': '#a85a2c', '#d06a50': '#c05a50', '#8a2c2a': '#742a2c', '#f5dc8a': '#ffe08a', '#4f5d6c': '#4f5560',
          '#5f6278': '#6e7186', '#3e4654': '#4f5560', '#c9c5bc': '#bdb8ac', '#fff0d8': '#f6f4ee',
          '#fff4cc': '#f6f4ee', '#dcd8bc': '#e6e2d6', '#8796a4': '#8b96a4', '#c97a3e': '#d98a2a', '#8a8c86': '#8a8c94', '#4a3424': '#3d2a1e',
          '#6a5848': '#6a5444', '#b4a88c': '#bfc0b8', '#7e6496': '#8e7898', '#6a7aa8': '#7a94ac', '#7f9a6a': '#8a9a5a', '#c8c27a': '#c9c06a'})

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'mistmoor', out)
    print('mistmoor:', n, 'colours')
