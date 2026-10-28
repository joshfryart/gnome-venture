"""Jigsaw picture: BIRCHBRAMBLE STEPPE (draft v0): game/assets/img/jigsaw/birchbramble.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_birchbramble.py [outdir]
Early spring on the steppe edge: a wide pale sky with storks flying home, a low far ridge (the Grey Wolf King's, a wolf on the top), striped black-earth
fields greening in rows, a wooden chapel with blue onion domes and melting snow on the left, a hay rick, a sweep well (long see-saw pole) with a gnome
hauling the bucket, the Painted Egg House in the centre (an egg-shaped folk-art cottage, a stork nest on its chimney) with a porch where a grandmother
gnome pours tea from a steaming samovar, a wattle fence with clay pots on the stakes and last year's sunflower heads, a birch wood on the right with a
sap bucket, catkins and mushrooms, a melt stream, a slushy snowman, a muddy track with sky puddles, geese marching in the front and a gnome child with a
basket of painted eggs.
"""
import sys

from jigsaw_common import *  # noqa: F401,F403

SKY0, SKY1, SKY2 = '#9ccbe6', '#b6dbee', '#cfe8f2'
SNOW = ramp('#f4f8f8', '#c9dbe6', '#ffffff')
GRASS = ramp('#8cc84a', '#5fa83a', '#b8e070')
DGRASS = ramp('#5fa83a', '#3f8a32', '#8cc84a')
EARTH = ramp('#4a3424', '#2e2018', '#6a4a30')
MUD = ramp('#8a6a44', '#6a4e32', '#a8885a')
LOG = ramp('#a06a38', '#74462a', '#c88a4a')
SHINGLE = ramp('#a8977e', '#7a6a58', '#cdbd9e')
BIRCH = ramp('#f1ece0', '#c9c5bc', '#ffffff')
RED = ramp('#d6322b', '#a8241f', '#f0705a')
BLUE = ramp('#2f62b8', '#1f4282', '#6a9ae0')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
PLAST = ramp('#f6efe0', '#d8ccb0', '#ffffff')
STONE = ramp('#b9b2a2', '#8a8474', '#d8d2c2')
WATER = ramp('#5fa6cc', '#3f80aa', '#a9d6ea')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
BOOT = ramp('#5c3420', '#3d2a1c', '#7a4a1f')
GOOSE = ramp('#f4f4ee', '#c9c9c0', '#ffffff')
GREEN_T = ramp('#3f8a32', '#2f5a2a', '#6aa84a')   # tunic green
CLAY = ramp('#c8643a', '#9a4424', '#e8905a')
cv = new_canvas(SKY0)
r = rnd(4411)
r2 = rnd(913)
r3 = rnd(7177)   # pass-1 details (separate so the v0 layout does not shift)
yy_, xx_ = np.mgrid[0:H, 0:W]


def shadow(x0, y0, x1, y1, col='#3f8a32'):
    cv.fill(ell(x0, y0, x1, y1), col)


def gnome(gx, gy, hat=RED, tunic=BLUE, beard=True, arm=1, hat_lean=-1):
    """A gnome standing with feet at (gx, gy), about 40 px tall. arm: +1 reaches right, -1 reaches left."""
    shadow(gx - 9, gy - 1, gx + 10, gy + 2, '#3f8a32' if cv.px[min(H - 1, gy + 1), gx][1] > 120 else '#2e2018')
    o = cv.obj()
    o.part(rect(gx - 7, gy - 3, gx - 2, gy) | rect(gx + 1, gy - 3, gx + 6, gy), BOOT, d=1)
    o.part(rrect(gx - 7, gy - 16, gx + 7, gy - 3, 2), tunic, d=2, contour=True)
    o.part(rect(gx - 7, gy - 7, gx + 7, gy - 6), ramp('#7a4a1f', '#5c3420'), d=0)
    if beard:
        o.part(poly([(gx - 7, gy - 20), (gx + 7, gy - 20), (gx + 1, gy - 6)]), BEARD, d=1, contour=True)
        o.part(rect(gx - 5, gy - 25, gx + 5, gy - 19), SKIN, d=1)
        o.part(poly([(gx - 8, gy - 23), (gx + 8, gy - 23), (gx + 5 * hat_lean, gy - 42)]), hat, d=2, contour=True)
    else:   # granny: a painted kerchief wrapped round the face and knotted under the chin, a white apron
        o.part(poly([(gx - 7, gy - 16), (gx - 8, gy - 25), (gx - 5, gy - 30), (gx + 5, gy - 30), (gx + 8, gy - 25), (gx + 7, gy - 16)]), hat, d=2, contour=True)
        o.part(rrect(gx - 4, gy - 25, gx + 4, gy - 18, 1), SKIN, d=1)
    o.part(rect(gx + (5 if arm > 0 else -9), gy - 15, gx + (9 if arm > 0 else -5), gy - 12), tunic, d=1)
    o.draw()
    if beard:
        cv.fill(rect(gx - 8, gy - 24, gx + 8, gy - 23), hat['s'])
    else:
        cv.dots([(gx - 5, gy - 27), (gx - 1, gy - 28), (gx + 3, gy - 28), (gx + 6, gy - 24), (gx - 6, gy - 21), (gx + 6, gy - 19), (gx - 6, gy - 18)], '#ffffff')   # kerchief dots
        cv.dots([(gx + 1, gy - 28), (gx - 6, gy - 24), (gx + 6, gy - 22)], GOLD['b'])
        cv.fill(rect(gx - 3, gy - 25, gx + 3, gy - 25), '#c9c5bc')   # grey hair under the kerchief edge
        cv.fill(rect(gx - 2, gy - 17, gx + 1, gy - 15), hat['s'])   # knot under the chin
        cv.dots([(gx - 3, gy - 14), (gx + 2, gy - 14), (gx - 3, gy - 13)], hat['b'])
        cv.fill(rect(gx - 4, gy - 13, gx + 4, gy - 4), '#f6efe0')   # apron
        cv.fill(rect(gx - 4, gy - 4, gx + 4, gy - 4) | rect(gx - 4, gy - 13, gx - 4, gy - 4), '#d8ccb0')
        cv.dots([(gx - 2, gy - 6), (gx, gy - 6), (gx + 2, gy - 6)], RED['b'])
    cv.dots([(gx - 2, gy - 22), (gx + 2, gy - 22)], '#2a1a10')
    cv.dots([(gx, gy - 21), (gx + 1, gy - 21), (gx, gy - 20), (gx + 1, gy - 20)], '#e0907a')
    cv.dots([(gx - 4, gy - 20), (gx + 4, gy - 20)], '#f0a0a0')
    hx_ = gx + 8 if arm > 0 else gx - 10
    cv.fill(rect(hx_, gy - 16, hx_ + 2, gy - 13), SKIN['b'])
    cv.fill(rect(gx - 1, gy - 7, gx + 1, gy - 6), GOLD['r'])
    return hx_ + 1, gy - 15


def cloud(cx, cy, w):
    m = ell(cx - w // 2, cy - 6, cx + w // 2, cy + 5) | ell(cx - w // 4, cy - 11, cx + w // 6, cy + 3) | ell(cx + 2, cy - 8, cx + w // 2 - 4, cy + 4)
    m &= ~rect(0, cy + 3, W, H)
    cv.fill(m, '#ffffff')
    cv.fill(m & ~shift(m, -2, -2) & rect(0, cy - 1, W, cy + 3), '#dde9f0')
    cv.fill(m & rect(0, cy + 3, W, cy + 3), '#b9cfe0')


def stork_fly(sx, sy, k=1):
    """A flying stork, wings spread, heading left (k=1) or right (k=-1)."""
    far = poly([(sx - 2 * k, sy), (sx + 3 * k, sy), (sx + 6 * k, sy + 4), (sx + 2 * k, sy + 3)])   # lower wing (behind)
    cv.fill(far, '#c9dbe6')
    cv.fill(far & rect(min(sx + 4 * k, sx + 6 * k), 0, max(sx + 4 * k, sx + 6 * k), H), '#2a2a30')
    cv.fill(rect(min(sx - 4 * k, sx + 4 * k), sy, max(sx - 4 * k, sx + 4 * k), sy + 1), '#ffffff')   # body
    cv.fill(line([(sx - 4 * k, sy), (sx - 8 * k, sy - 1)]), '#ffffff')   # neck stretched forward
    cv.dots([(sx - 9 * k, sy - 1), (sx - 10 * k, sy - 1), (sx - 11 * k, sy)], '#d6322b')   # beak
    cv.fill(line([(sx + 4 * k, sy + 1), (sx + 9 * k, sy + 2)]), '#d6322b')   # legs trailing
    near = poly([(sx - 2 * k, sy), (sx + 3 * k, sy), (sx + 5 * k, sy - 5), (sx + 1 * k, sy - 8), (sx - 1 * k, sy - 5)])   # raised near wing
    cv.fill(near, '#ffffff')
    cv.fill(near & rect(0, 0, W, sy - 5), '#2a2a30')   # black flight feathers at the tip
    cv.fill(near & ~shift(near, -k, -1) & rect(0, sy - 4, W, sy), '#c9dbe6')


# ---------------------------------------------------------------- sky, clouds, storks
cv.fill(rect(0, 22, W - 1, 80), SKY1)
cv.fill(rect(0, 46, W - 1, 80), SKY2)
for cx, cy, w in ((26, 12, 40), (98, 20, 50), (176, 8, 38), (250, 18, 34), (140, 40, 30), (60, 44, 26), (214, 42, 34), (288, 40, 22), (10, 38, 24), (90, 42, 28), (164, 32, 24), (244, 40, 26)):
    cloud(cx, cy, w)
for sx, sy, k in ((128, 14, 1), (142, 24, 1), (66, 28, 1), (226, 30, -1), (112, 38, 1)):
    stork_fly(sx, sy, k)
for bx, by in ((40, 30), (46, 33), (200, 6), (206, 9), (270, 6)):   # small far birds (larks)
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#3a4a5a')

# ---------------------------------------------------------------- far ridge (Grey Wolf King) with snow caps, a wolf on top
m = poly([(0, 74), (20, 66), (44, 70), (78, 58), (104, 64), (126, 50), (150, 60), (176, 56), (210, 66), (250, 60), (300, 68), (300, 80), (0, 80)])
cv.fill(m, '#9ab8c8')
cv.fill(m & ~shift(m, 3, 3), '#b8d0dc')
for px, py, w in ((78, 58, 10), (126, 50, 14), (176, 56, 10), (250, 60, 8)):   # snow caps
    cap = m & poly([(px - w, py + w * 2 // 3), (px, py - 1), (px + w, py + w * 2 // 3)]) & ~poly([(px - w, py + w * 2 // 3), (px - w // 2, py + 3), (px, py + w // 2), (px + w // 2, py + 2), (px + w, py + w * 2 // 3)])
    cv.fill(cap, '#eef4f6')
cv.fill(m & ~shift(m, 0, 1), '#7e9eb2')   # crest line so the pale snow caps read against the pale sky
WOLF = ramp('#6e7682', '#4a525c', '#a4acb6')
bx, by = 126, 55   # pass 2: the Grey Wolf King is far away, so small (about 11 px), a silhouette sitting on the peak, muzzle up, howling
wolf = (ell(bx, by - 5, bx + 5, by) | poly([(bx - 3, by), (bx - 2, by - 6), (bx + 1, by - 8), (bx + 3, by - 5), (bx + 2, by)])
        | ell(bx - 4, by - 11, bx, by - 7) | line([(bx - 3, by - 10), (bx - 6, by - 13)], 2) | rect(bx - 1, by - 13, bx - 1, by - 11)
        | line([(bx + 5, by), (bx + 9, by - 1)], 2))
cv.fill(dil4(wolf) & ~wolf, '#4a525c')   # thin dark edge (far: no umber outline)
cv.fill(wolf, WOLF['b'])
cv.fill(wolf & ~shift(wolf, -1, -1), WOLF['s'])
cv.fill(wolf & ~shift(wolf, 1, 1), '#a8acb0')
cv.fill(rect(bx - 2, by - 6, bx - 1, by - 3), '#d8d2c2')   # pale ruff
cv.dots([(bx - 2, by - 10)], '#2a1a10')
drift = ell(bx - 8, by - 1, bx + 13, by + 3) & m   # snow drift round its feet
cv.fill(drift & ~rect(0, 0, W, by), '#eef4f6')
cv.fill(drift & ~rect(0, 0, W, by) & ~shift(drift, 0, -1), '#c9dbe6')
x = 2
while x < W - 2:
    x += r2(3, 8)
    col = m[:, min(W - 1, x)]
    if col.any() and r2(0, 3):
        ty = int(np.argmax(col)) + r2(4, 10)
        cv.dots([(x, ty), (x + 1, ty), (x, ty - 1)], '#7e9eb2')

# ---------------------------------------------------------------- far field strips (flat steppe), a far hamlet
bands = (('#7aa84a', 76), ('#4a3424', 78), ('#a4c870', 80), ('#6a4a30', 83), ('#8cc84a', 85))
for col, y in bands:
    cv.fill(rect(0, y, W - 1, 88), col)
for _ in range(26):   # broken patches so the strips are a patchwork, not stripes
    x0, y0 = r(0, W - 20), r(76, 87)
    cv.fill(rect(x0, y0, x0 + r(8, 30), y0 + r(0, 1)), ('#4a3424', '#a4c870', '#eef4f6', '#7aa84a', '#6a4a30')[r(0, 4)])
for hx0 in (96, 104, 112, 208, 216):   # far hamlet: tiny white houses with red roofs
    cv.fill(rect(hx0, 73, hx0 + 4, 76), '#f6efe0')
    cv.fill(poly([(hx0 - 1, 73), (hx0 + 2, 70), (hx0 + 5, 73)]), '#a8241f')

# ---------------------------------------------------------------- mid fields: left green wheat, centre black earth with green rows
cv.fill(rect(0, 88, W - 1, 124), GRASS['b'])
earth = poly([(92, 88), (236, 88), (250, 124), (78, 124)]) | poly([(0, 88), (W - 1, 88), (W - 1, 97), (0, 99)])   # pass 2: the black earth runs right across the steppe behind the yard
cv.fill(earth, EARTH['b'])
for i in range(-22, 23):   # sprout rows converging to the horizon
    xa, xb = 164 + i * 8, 164 + i * 19
    cv.fill(line([(xa, 89), (xb, 124)]) & earth, '#7aa84a')
    cv.fill(line([(xa + 1, 89), (xb + 2, 124)]) & earth & rect(0, 104, W, 124), '#4f8a3a')
wheat = rect(0, 88, W - 1, 124) & ~earth
for y in range(89, 125, 3):   # wheat drills on the left/right fields
    cv.fill(wheat & rect(0, y, W, y), GRASS['s'])
for _ in range(16):   # snow left in the furrows and on the fields
    sx, sy = r(0, W - 30), r(90, 120)
    s = r(6, 16)
    pm = (ell(sx, sy, sx + s, sy + 3) | ell(sx + s // 3, sy - 1, sx + s + 6, sy + 2)) & rect(0, 89, W, 124)
    cv.fill(pm, SNOW['b'])
    cv.fill(pm & ~shift(pm, 0, -1), SNOW['s'])

# ---------------------------------------------------------------- foreground yard (grass), muddy track, puddles
cv.fill(rect(0, 124, W - 1, H - 1), GRASS['b'])
cv.fill(rect(0, 160, W - 1, H - 1), DGRASS['b'])
for y in range(124, H):
    for _ in range(5):
        gx = r(0, W - 1)
        if y < 160:
            cv.dots([(gx, y), (gx, y - 1)], GRASS['r'] if r(0, 2) else GRASS['s'])
        else:
            cv.dots([(gx, y), (gx, y - 1), (gx + 1, y)], GRASS['b'] if r(0, 2) else DGRASS['s'])
track = poly([(172, 124), (188, 124), (186, 140), (178, 156), (170, 172), (168, 186), (172, 199), (128, 199), (136, 182), (150, 164), (164, 146), (170, 134)])
cv.fill(track, MUD['b'])
cv.fill(track & ~shift(track, 2, 0), MUD['r'])
cv.fill(track & ~shift(track, -2, 0), MUD['s'])
for k in range(10):   # wheel ruts
    y = 128 + k * 7
    cv.fill(track & rect(0, y, W, y) & ~rect(0, y, 140 + k * 0, y) & rect(150 - k * 2, y, 168 - k * 2, y), MUD['s'])
for px, py, w in ((160, 168, 16), (146, 186, 20), (176, 140, 9)):
    pm = ell(px, py, px + w, py + 4) & track
    cv.fill(pm, WATER['r'])
    cv.fill(pm & ~shift(pm, 0, 1), MUD['s'])
    cv.dots([(px + 3, py + 2), (px + 4, py + 2), (px + w - 4, py + 1)], '#ffffff')
puddle = ell(70, 178, 120, 194)   # the goose puddle
cv.fill(puddle, WATER['b'])
cv.fill(puddle & ~shift(puddle, 0, 2), WATER['s'])
cv.fill(dil4(puddle) & ~puddle, MUD['b'])
cv.fill(rect(80, 184, 92, 184) & puddle, WATER['r'])
cv.fill(rect(98, 188, 108, 188) & puddle, WATER['r'])
for k in range(5):   # cloud reflection blobs
    cv.dots([(86 + k, 182), (100 + k, 186)], '#ffffff')

# ---------------------------------------------------------------- melt stream (right foreground) with snow banks
cl = [(300, 128), (282, 138), (264, 150), (252, 164), (244, 180), (238, 199)]
stream = line(cl, 11) | line([(300, 132), (276, 146)], 9)
bank = dil4(dil4(dil4(stream))) & ~stream
cv.fill(bank & rect(0, 126, W, H), SNOW['b'])
cv.fill(bank & ~shift(bank, -1, -1) & rect(0, 126, W, H), SNOW['s'])
cv.fill(stream, WATER['b'])
cv.fill(stream & ~shift(stream, -2, 0), WATER['s'])
for _ in range(40):
    sx, sy = r(236, 299), r(130, 198)
    if stream[sy, sx] and stream[sy, max(0, sx - 4)]:
        cv.fill(line([(sx, sy), (sx - 3, sy + 2)]), WATER['r'] if r(0, 2) else '#ffffff')
for sx, sy in ((258, 168), (247, 186), (286, 140)):   # stepping stones in the stream
    o = cv.obj()
    o.part(ell(sx, sy, sx + 8, sy + 5), STONE, d=2)
    o.draw()
    cv.dots([(sx + 2, sy + 1), (sx + 3, sy + 1)], SNOW['b'])

# ---------------------------------------------------------------- the wooden chapel (left): log hall, shingled roof, blue onion domes
def onion(cx, by, w, h):
    """Onion dome sitting on y=by, w half-width, h height (bulb + pointed tip)."""
    bulb = ell(cx - w, by - h * 2 // 3, cx + w, by + 2) & rect(0, 0, W, by)
    tip = poly([(cx - w + 2, by - h // 2), (cx + w - 2, by - h // 2), (cx, by - h)])
    return bulb | tip


ch0, ch1 = 8, 64
shadow(ch0 - 4, 118, ch1 + 8, 124, '#5fa83a')
o = cv.obj()
o.part(rect(ch0, 86, ch1, 120), LOG, d=3)   # log hall
o.part(rect(29, 52, 45, 76), LOG, d=2)   # drum under the big dome
o.part(rect(4, 76, 16, 120), LOG, d=2)   # porch tower
o.draw()
for y in range(88, 120, 4):   # log courses with notched ends
    cv.fill(rect(ch0 + 1, y, ch1 - 1, y), LOG['s'])
    cv.dots([(ch0, y - 1), (ch1, y - 1), (ch0 - 1, y - 1), (ch1 + 1, y - 1)], LOG['r'])
for y in range(55, 76, 4):
    cv.fill(rect(30, y, 44, y), LOG['s'])
for y in range(79, 120, 4):
    cv.fill(rect(5, y, 15, y), LOG['s'])
o = cv.obj()
o.part(poly([(ch0 - 6, 88), (36, 70), (ch1 + 6, 88)]), SHINGLE, d=3)   # hall roof
o.part(poly([(1, 78), (10, 68), (19, 78)]), SHINGLE, d=2)
o.draw()
roofm = poly([(ch0 - 6, 88), (36, 70), (ch1 + 6, 88)]) | poly([(1, 78), (10, 68), (19, 78)])
roofin = roofm & shift(roofm, 1, 1) & shift(roofm, -1, -1)
for k, y in enumerate(range(72, 88, 3)):   # aspen shingle courses: a dark seam, a lit lip, staggered joints with pointed tips
    cv.fill(roofin & rect(0, y, W, y), '#6a5a48')
    cv.fill(roofin & rect(0, y + 1, W, y + 1), '#d8caae')
    for tx in range(2 + (k % 2) * 2, 72, 4):
        cv.fill(roofin & rect(tx, y - 2, tx, y - 1), '#8a7a66')
        cv.fill(roofin & rect(tx + 1, y, tx + 2, y), '#8a7a66')
roofsnow = poly([(ch0 - 4, 87), (14, 82), (20, 84), (26, 80), (30, 83), (22, 87)]) | poly([(48, 79), (56, 83), (ch1 + 4, 87), (52, 87), (46, 84)])
cv.fill(roofsnow, SNOW['b'])
cv.fill(roofsnow & ~shift(roofsnow, 0, -1), SNOW['s'])
for cx, by, w, h in ((37, 52, 12, 30), (10, 68, 6, 16)):
    o = cv.obj()
    o.part(onion(cx, by, w, h), BLUE, d=3)
    o.draw()
    dm = onion(cx, by, w, h)
    for k in range(-w + 3, w - 1, 4):   # shingle scales on the dome (gold dots)
        cv.fill(line([(cx + k // 2, by - h + 6), (cx + k, by - 2)]) & dm & ~shift(dm, -1, 0) & ~shift(dm, 1, 0) | (line([(cx + k // 2, by - h + 6), (cx + k, by - 2)]) & dm & rect(0, by - h * 2 // 3, W, by - 2)), BLUE['s'])
    cv.dots([(cx - w // 2, by - h // 2), (cx - w // 2 + 1, by - h // 2 - 1)], '#ffffff')   # glint
    cv.fill(rect(cx - 1, by - h - 5, cx + 1, by - h - 3), GOLD['b'])   # gold finial ball
    cv.fill(rect(cx, by - h - 8, cx, by - h - 3), GOLD['s'])
    cv.dots([(cx - 1, by - h - 5)], GOLD['r'])
cv.fill(rect(28, 50, 46, 52), GOLD['s'])   # gilded collar under the dome
o = cv.obj()   # arched door and windows
o.part(rrect(30, 100, 42, 120, 3), BLUE, d=2)
o.draw()
cv.fill(rect(36, 100, 36, 120), BLUE['s'])
for wx in (14, 52):
    cv.fill(rrect(wx, 94, wx + 5, 104, 1), '#2a1a10')
    cv.fill(rect(wx + 1, 96, wx + 4, 103), '#f5cf6a')
cv.fill(rect(34, 60, 39, 70), '#2a1a10')
cv.fill(rect(35, 62, 38, 69), '#f5cf6a')
for x in range(ch0, ch1 + 1, 4):   # painted red trim board under the eaves
    cv.dots([(x, 89), (x + 1, 90)], RED['b'])
cv.fill(rect(7, 86, 65, 86), RED['s'])

# ---------------------------------------------------------------- hay rick with a pole and a snow cap
hx, hy = 82, 122
shadow(hx - 16, hy - 2, hx + 18, hy + 3, '#5fa83a')
o = cv.obj()
o.part(poly([(hx - 14, hy), (hx + 14, hy), (hx + 9, hy - 18), (hx, hy - 30), (hx - 9, hy - 18)]), ramp('#d8b860', '#a8883a', '#f2d88a'), d=3)
o.part(rect(hx - 1, hy - 38, hx + 1, hy - 29), LOG, d=1)
o.draw()
for k in range(14):
    sx, sy = hx + r(-10, 10), hy - r(2, 20)
    cv.fill(line([(sx, sy), (sx + r(-2, 2), sy + 3)]), '#a8883a')
cap = poly([(hx - 9, hy - 18), (hx, hy - 30), (hx + 9, hy - 18), (hx + 4, hy - 20), (hx, hy - 17), (hx - 5, hy - 20)])
cv.fill(cap, SNOW['b'])
cv.fill(cap & ~shift(cap, -1, -1), SNOW['s'])
cv.fill(line([(hx - 12, hy - 4), (hx + 4, hy - 26)]), '#9a6b3f')   # binding rope

# ---------------------------------------------------------------- the Painted Egg House (centre)
ecx, etop, ebot = 178, 50, 126
ecy, eb, ea = 92, 42, 33
v = (yy_ - ecy) / eb
half = ea * np.sqrt(np.clip(1 - v * v, 0, 1)) * (1 + 0.16 * v)
egg = (np.abs(xx_ - ecx) <= half) & (yy_ <= ebot) & (yy_ >= etop)
shadow(ecx - 40, ebot - 2, ecx + 44, ebot + 6, '#5fa83a')
o = cv.obj()
o.part(rect(186, 36, 194, 58), PLAST, d=2)   # chimney
o.part(egg, PLAST, d=3)
o.part(rect(ecx - 34, ebot - 3, ecx + 34, ebot + 2) & dil4(dil4(egg)), STONE, d=1)   # stone plinth
o.draw()
cv.fill(rect(186, 36, 194, 39), RED['b'])   # chimney band
cv.fill(egg & (yy_ <= 66), RED['b'])   # red crown cap
cv.fill(egg & (yy_ == 66), RED['s'])
for k in range(-26, 27, 6):   # white dots on the cap
    y = 60 + (k // 6) % 2 * 3
    if egg[y, ecx + k]:
        cv.dots([(ecx + k, y), (ecx + k + 1, y)], '#ffffff')
cv.fill(egg & (yy_ >= 86) & (yy_ <= 91), RED['b'])   # red band with blue diamonds
cv.fill(egg & (yy_ == 91), RED['s'])
for k in range(-30, 31, 8):
    dm = poly([(ecx + k - 3, 88), (ecx + k, 86), (ecx + k + 3, 88), (ecx + k, 90)]) & egg
    cv.fill(dm, BLUE['b'])
    cv.dots([(ecx + k, 88)], '#ffffff')
zig = blank()
for k in range(-36, 36, 6):   # blue zigzag band
    zig |= line([(ecx + k, 100), (ecx + k + 3, 95), (ecx + k + 6, 100)], 2)
cv.fill(zig & egg, BLUE['b'])
cv.fill(egg & (yy_ == 102), BLUE['s'])
cv.fill(egg & (yy_ >= 120) & (yy_ <= 123), BLUE['b'])   # blue skirting
for k in range(-30, 31, 6):
    cv.dots([(ecx + k, 121)], '#ffffff')
for rx, ry, c in ((158, 110, RED), (199, 110, RED), (170, 74, BLUE), (188, 74, BLUE)):   # painted rosettes (sun flowers)
    if c is RED:
        pts = [(rx, ry - 3), (rx, ry + 3), (rx - 3, ry), (rx + 3, ry), (rx - 2, ry - 2), (rx + 2, ry + 2), (rx - 2, ry + 2), (rx + 2, ry - 2)]
        cv.dots(pts, RED['b'])
        cv.dots([(rx, ry)], GOLD['b'])
        cv.fill(line([(rx, ry + 4), (rx, ry + 8)]), '#3f8a32')
        cv.dots([(rx - 2, ry + 6), (rx + 2, ry + 6)], '#5fa83a')
for wx, wy in ((158, 72), (198, 72)):   # round windows with blue shutters
    o = cv.obj()
    o.part(ell(wx - 6, wy - 1, wx - 3, wy + 9) | ell(wx + 3, wy - 1, wx + 6, wy + 9), BLUE, d=1)
    o.part(ell(wx - 4, wy, wx + 4, wy + 8), ramp('#f5cf6a', '#e8a317', '#fff4c0'), d=2)
    o.draw()
    cv.fill(rect(wx, wy, wx, wy + 8) | rect(wx - 4, wy + 4, wx + 4, wy + 4), '#4a2c1a')
o = cv.obj()   # round-topped door with a red frame
o.part(rrect(ecx - 9, 104, ecx + 9, 126, 4), RED, d=2)
o.part(rrect(ecx - 6, 107, ecx + 6, 126, 3), BLUE, d=2, contour=True)
o.draw()
for x in (ecx - 3, ecx, ecx + 3):
    cv.fill(rect(x, 109, x, 125), BLUE['s'])
cv.dots([(ecx + 4, 117)], GOLD['r'])
cv.fill(rect(ecx - 7, 102, ecx + 7, 102), GOLD['b'])
# stork nest on the chimney, a stork standing in it
nest = ell(180, 30, 200, 39)
o = cv.obj()
o.part(nest, LOG, d=2)
o.draw()
for k in range(14):
    sx = r(181, 198)
    cv.fill(line([(sx, r(31, 37)), (sx + r(-5, 5), r(31, 38))]) & dil4(nest), ('#74462a', '#c88a4a', '#5c3420')[k % 3])
for sx, sy, dx in ((180, 34, -4), (199, 33, 4), (184, 38, -3)):
    cv.fill(line([(sx, sy), (sx + dx, sy - 1)]), '#5c3420')
o = cv.obj()
o.part(ell(186, 18, 196, 29), GOOSE, d=2)   # body
o.part(rect(186, 10, 188, 20), GOOSE, d=1)   # neck
o.part(ell(185, 7, 189, 11), GOOSE, d=1)   # head
o.draw()
cv.fill(ell(190, 19, 197, 28) & ~ell(186, 16, 194, 26), '#2a2a30')   # black flight feathers
cv.fill(rect(196, 24, 198, 27), '#2a2a30')
cv.fill(line([(184, 9), (178, 12)], 2), RED['b'])   # long red beak (clattering)
cv.dots([(186, 8)], '#2a1a10')
cv.fill(rect(190, 29, 190, 31) | rect(193, 29, 193, 31), RED['b'])
# chimney smoke curling up past the stork (thin, drifting right)
for k in range(4):
    sx, sy = 200 + k * 5, 26 - k * 5
    pm = ell(sx - 2 - k // 2, sy - 2, sx + 2 + k // 2, sy + 2)
    cv.fill(pm, '#eef2f2')
    cv.fill(pm & ~shift(pm, -1, -1), '#c3d2dc')

# ---------------------------------------------------------------- porch with a samovar and the grandmother gnome
pk0, pk1 = 208, 236
o = cv.obj()
o.part(rect(pk0, 120, pk1, 126), LOG, d=2)   # deck
o.part(rect(pk1 - 2, 96, pk1, 120), LOG, d=1)   # post
o.draw()
for x in range(pk0 + 3, pk1, 5):
    cv.fill(rect(x, 121, x, 126), LOG['s'])
o = cv.obj()   # little red-and-blue awning
o.part(poly([(203, 92), (pk1 + 4, 92), (pk1 + 6, 98), (205, 98)]), RED, d=2)
o.draw()
for x in range(206, pk1 + 5, 6):
    cv.fill(rect(x, 93, x + 2, 97), '#ffffff')
for x in range(206, pk1 + 5, 4):
    cv.dots([(x, 99), (x + 1, 99), (x, 100)], BLUE['b'])
o = cv.obj()   # table
o.part(rect(214, 110, 232, 112), LOG, d=1)
o.part(rect(216, 112, 217, 120) | rect(229, 112, 230, 120), LOG, d=0)
o.draw()
cv.fill(rect(214, 109, 232, 109), RED['b'])   # tablecloth edge
smx = 224   # the samovar: brass urn with a tap, a teapot on top
o = cv.obj()
o.part(rect(smx - 3, 106, smx + 3, 109), GOLD, d=1)   # foot
o.part(ell(smx - 6, 92, smx + 6, 107), GOLD, d=3)   # urn
o.part(rect(smx - 3, 87, smx + 3, 92), GOLD, d=1)   # neck
o.part(ell(smx - 4, 81, smx + 4, 88), BLUE, d=2)   # painted teapot on top
o.part(rect(smx - 9, 95, smx - 7, 99) | rect(smx + 7, 95, smx + 9, 99), GOLD, d=0)   # handles
o.draw()
cv.fill(rect(smx - 2, 101, smx + 1, 102), '#5c3420')   # tap
cv.dots([(smx - 3, 103)], '#5c3420')
cv.dots([(smx - 3, 95), (smx - 3, 96), (smx - 2, 94)], '#fff4c0')
cv.dots([(smx - 1, 84), (smx + 1, 84)], '#ffffff')
cv.fill(rect(smx - 1, 79, smx + 1, 80), BLUE['s'])
for k in range(6):   # steam puffs rising and leaning left
    sx, sy = smx - 1 - k * 2, 75 - k * 7
    pm = ell(sx - 2 - k // 2, sy - 2, sx + 2 + k // 2, sy + 2)
    cv.fill(pm, '#ffffff' if k < 4 else '#eef2f2')
    cv.fill(pm & ~shift(pm, -1, -1), '#c9dbe6')
for cx_ in (215, 219):   # tea glasses in holders
    cv.fill(rect(cx_, 105, cx_ + 2, 108), '#c8643a')
    cv.dots([(cx_, 104), (cx_ + 2, 104)], GOLD['r'])
hand = gnome(244, 127, hat=ramp('#d6322b', '#a8241f', '#f0705a'), tunic=GREEN_T, beard=False, arm=-1)
cv.fill(rect(hand[0] - 3, hand[1] - 2, hand[0], hand[1] + 1), '#c8643a')   # cup held out
cv.dots([(hand[0] - 2, hand[1] - 3)], GOLD['r'])

# ---------------------------------------------------------------- wattle fence with clay pots on the stakes, old sunflower heads
fence = blank()
stakes = list(range(122, 160, 7))
for fx in stakes:
    fence |= rect(fx, 112, fx + 1, 136)
fence |= rect(120, 118, 160, 133)
o = cv.obj()
o.part(fence, ramp('#9a7a52', '#6a4e32', '#c4a070'), d=1)
o.draw()
for y in range(119, 133, 2):   # woven withies
    for fx in stakes:
        off = 0 if (y // 2 + fx // 7) % 2 else 3
        cv.fill(rect(fx + 2 + off, y, fx + 5 + off, y) & rect(120, 0, 160, H), '#6a4e32')
for k, fx in enumerate(stakes[::2]):   # pots upside down on the stakes
    o = cv.obj()
    o.part(poly([(fx - 4, 113), (fx + 5, 113), (fx + 3, 106), (fx - 2, 106)]), [CLAY, BLUE, CLAY, RED][k % 4], d=1)
    o.draw()
    cv.fill(rect(fx - 4, 112, fx + 5, 112), '#9a4424')
    cv.dots([(fx - 1, 108), (fx + 2, 109)], '#ffffff')
for sx, top, lean in ((126, 96, -3), (138, 92, 2), (150, 98, -2)):   # sunflowers by the fence: a golden ragged petal ring round a seed disc
    cv.fill(line([(sx, 118), (sx + lean, top + 4)], 2), '#6a8a3a')
    cx, cy = sx + lean, top
    o = cv.obj()
    o.part(poly([(sx, top + 13), (sx - 7, top + 9), (sx - 4, top + 15)]) | poly([(sx + 1, top + 17), (sx + 7, top + 13), (sx + 5, top + 19)]), GREEN_T, d=1)   # leaves
    o.draw()
    petals = blank()
    for a in range(0, 360, 30):
        if r3(0, 5) == 0:
            continue   # a gap where a petal fell
        t = np.radians(a + r3(-6, 6))
        rr = 8 if np.sin(t) > 0.3 else 7
        petals |= line([(cx + round(3 * np.cos(t)), cy + round(3 * np.sin(t))), (cx + round(rr * np.cos(t)), cy + round(rr * np.sin(t)) + (1 if np.sin(t) > 0.3 else 0))], 2)
    disc = ell(cx - 4, cy - 4, cx + 4, cy + 4)
    o = cv.obj()
    o.part(petals, ramp('#f0b42a', '#c98a14', '#f8dc70'), d=1)
    o.part(disc, ramp('#7a5030', '#4a3424', '#a87a48'), d=2)
    o.draw()
    seeds = disc & ((xx_ + yy_) % 2 == 0) & ~shift(disc, -1, -1)
    cv.fill(seeds & ell(cx - 3, cy - 3, cx + 3, cy + 3), '#4a3424')
    cv.fill(rect(cx - 1, cy - 1, cx, cy), '#a87a48')

# ---------------------------------------------------------------- birch wood (right), early spring: bare white trunks, a mist of catkins
rb = rnd(5521)   # the birch wood's own generator
LEAF = ramp('#a8d860', '#7ab848', '#d4f090')


def birch(m, bot):
    """A birch trunk from a mask: white bark, ragged black lenticels at uneven spacing, knot 'eyes', a dark ragged foot."""
    o = cv.obj()
    o.part(m, BIRCH, d=2)
    o.draw()
    ys = np.nonzero(m.any(axis=1))[0]
    y = int(ys.min()) + rb(1, 4)
    while y < bot - 8:
        xs = np.nonzero(m[y])[0]
        x0, x1 = int(xs.min()), int(xs.max())
        wd = x1 - x0 + 1
        ln = rb(1, max(1, wd - 1))
        st = x0 if rb(0, 2) else x1 - ln + 1   # most marks touch one edge
        cv.fill(rect(st, y, st + ln - 1, y) & m, '#2a2a30')
        if rb(0, 3) == 0 and wd > 3:   # a knot eye: dark wedge with a pale centre
            kx = x0 + wd // 2
            cv.fill(rect(kx - 1, y + 2, kx + 1, y + 3) & m, '#2a2a30')
            cv.dots([(kx, y + 2)], '#8a8474')
            cv.fill(line([(kx - 2, y + 4), (kx - 1, y + 3)]) & m, '#5b5450')
        elif rb(0, 2) == 0:
            cv.fill(rect(st, y + 1, st + max(0, ln - 2), y + 1) & m, '#5b5450')
        y += rb(3, 8)
    xs = np.nonzero(m[min(H - 1, bot)] | m[bot - 1])[0]
    for x in range(int(xs.min()), int(xs.max()) + 1):   # ragged dark bark at the foot
        cv.fill(rect(x, bot - rb(3, 9), x, bot) & m, '#5b5450')
        if rb(0, 2) == 0:
            cv.fill(rect(x, bot - rb(10, 13), x, bot - 10) & m, '#2a2a30')


def trunk(x0, bot, w, x1, top):
    """Trunk mask leaning from (x0, bot) to (x1, top), w wide, slightly tapering."""
    return poly([(x0, bot), (x0 + w, bot), (x1 + max(1, w - 2), top), (x1, top)])


for bx, top, bot, w, tx in ((259, 30, 116, 2, 257), (266, 16, 120, 3, 268), (284, 8, 122, 4, 281)):   # back row, uneven spacing, gentle leans
    birch(trunk(bx, bot, w, tx, top), bot)
birch(trunk(276, 118, 3, 296, 0), 118)   # a young birch leaning out over the stream
bram = blank()   # bramble thicket at the wood's edge
for cx_, cy_, w_ in ((250, 120, 12), (262, 117, 14), (276, 119, 12), (290, 116, 12), (299, 120, 8)):
    bram |= ell(cx_ - w_, cy_ - 7, cx_ + w_, cy_ + 6)
bram &= rect(0, 0, W, 125)
o = cv.obj()
o.part(bram, ramp('#4f8a3a', '#2f5a2a', '#7ab848'), d=2)
o.draw()
for k in range(9):   # arching red canes with thorns and fresh leaves
    x0 = rb(244, 296)
    xm, ym = x0 + rb(-8, 8), rb(104, 110)
    x1 = xm + (xm - x0)
    cane = line([(x0, 124), (x0 + (xm - x0) // 2, ym + 3), (xm, ym), (x1 - (x1 - xm) // 2, ym + 3), (x1, 122)])
    cv.fill(cane, '#8a2e3e')
    ys_, xs_ = np.nonzero(cane)
    for i in range(0, len(xs_), 3):
        if rb(0, 2) == 0:
            cv.dots([(int(xs_[i]), int(ys_[i]) - 1)], '#c06070')
        elif rb(0, 1):
            lx, ly = int(xs_[i]), int(ys_[i])
            cv.dots([(lx, ly - 1), (lx + 1, ly - 1), (lx + 1, ly - 2)], ('#8cc84a', '#b8e070')[rb(0, 1)])
for _ in range(14):   # dark gaps and leaf flecks inside the thicket
    lx, ly = rb(242, 298), rb(112, 123)
    if bram[ly, lx]:
        cv.dots([(lx, ly), (lx + 1, ly)], '#2f5a2a' if rb(0, 1) else '#a8d860')
for bx, top, bot, w, tx in ((254, 6, 134, 5, 252), (271, 0, 142, 7, 273), (292, 0, 150, 6, 291)):   # front row
    shadow(bx - 6, bot - 2, bx + w + 10, bot + 3, '#5fa83a')
    birch(trunk(bx, bot, w, tx, top), bot)
# the early-spring crown: a haze of young leaves in clumps with sky holes, drooping catkin strands, twigs showing through
crown = blank()
for cx_, cy_, rw, rh in ((262, 4, 16, 10), (284, 2, 18, 12), (300, 14, 10, 12), (250, 16, 10, 7), (270, 20, 12, 8), (290, 28, 12, 8), (258, 30, 7, 5), (244, 6, 8, 6)):
    crown |= ell(cx_ - rw, cy_ - rh, cx_ + rw, cy_ + rh)
for _ in range(8):   # bites out of the lower edge so it is not a smooth blob
    hx0 = rb(240, 299)
    col = crown[:, hx0]
    if col.any():
        hy0 = int(np.nonzero(col)[0].max())
        crown &= ~ell(hx0 - 3, hy0 - 3, hx0 + 3, hy0 + 2)
holes = blank()
for _ in range(12):
    hx0, hy0 = rb(244, 298), rb(0, 30)
    holes |= ell(hx0, hy0, hx0 + rb(2, 4), hy0 + rb(1, 3))
holes &= shift(crown, 2, 2) & shift(crown, -2, -2)
o = cv.obj()
o.part(crown, LEAF, d=2)
o.draw()
cv.fill(holes, SKY1)
cv.fill(holes & ~shift(holes, 0, 1), '#7ab848')
for bx, y0, y1, tx in ((256, 34, 8, 246), (274, 30, 4, 262), (274, 26, 10, 290), (294, 36, 12, 300), (266, 22, 6, 278)):   # twigs through the crown
    cv.fill(line([(bx, y0), ((bx + tx) // 2, (y0 + y1) // 2 + 2), (tx, y1)]), '#7a5a4a')
for _ in range(90):   # leaf texture and catkins
    lx, ly = rb(238, 299), rb(0, 44)
    if not crown[ly, lx]:
        continue
    k = rb(0, 4)
    if k < 2:
        cv.dots([(lx, ly), (lx + 1, ly), (lx, ly + 1)], ('#d4f090', '#7ab848')[k])
    else:
        cv.dots([(lx, ly), (lx, ly + 1), (lx, ly + 2)], ('#c9a94a', '#a8883a', '#8a6a2a')[k - 2])
for _ in range(16):   # weeping strands hanging below the crown edge
    lx = rb(240, 299)
    col = crown[:, lx]
    if not col.any():
        continue
    ly = int(np.nonzero(col)[0].max())
    ln = rb(4, 12)
    cv.fill(line([(lx, ly), (lx + rb(-1, 1), ly + ln)]), '#7a5a4a')
    for j in range(2, ln, 3):
        cv.dots([(lx + (j % 2), ly + j)], '#a8d860' if rb(0, 2) else '#c9a94a')
sbx = 272   # birch-sap bucket hung on a spout
cv.fill(rect(sbx - 4, 112, sbx, 112), '#8b8f96')
cv.dots([(sbx - 5, 113)], WATER['r'])
o = cv.obj()
o.part(rrect(sbx - 9, 114, sbx - 2, 122, 1), LOG, d=1)
o.draw()
cv.fill(rect(sbx - 9, 116, sbx - 2, 116) | rect(sbx - 9, 120, sbx - 2, 120), '#5b6470')
cv.dots([(sbx - 6, 114), (sbx - 5, 114)], WATER['r'])
for sx, sy in ((242, 140), (262, 132), (288, 156), (300 - 12, 128)):   # snow under the trees
    pm = ell(sx - 10, sy - 2, sx + 10, sy + 4)
    cv.fill(pm & ~stream, SNOW['b'])
    cv.fill(pm & ~stream & ~shift(pm, 0, -1), SNOW['s'])
for mx, my in ((252, 128), (258, 132), (282, 128), (296, 162), (228, 140)):   # brown-cap mushrooms
    o = cv.obj()
    o.part(ell(mx - 4, my - 5, mx + 4, my), ramp('#8a5a2a', '#5c3420', '#b07a3a'), d=2)
    o.part(rect(mx - 1, my - 1, mx + 2, my + 4), PLAST, d=1)
    o.draw()
    cv.dots([(mx - 2, my - 4)], '#c88a4a')

# ---------------------------------------------------------------- the sweep well: log well box, forked post, long see-saw pole, gnome hauling
wbx0, wby0 = 96, 146
shadow(wbx0 - 4, wby0 + 12, wbx0 + 24, wby0 + 18)
o = cv.obj()
o.part(rect(64, 67, 67, 160), LOG, d=1)   # the tall post
o.draw()
cv.fill(line([(63, 66), (61, 60)]) | line([(68, 66), (70, 60)]), LOG['s'])   # fork
pole = line([(50, 56), (112, 98)], 2)   # sweep pole: weighted end up in the air, tip dipped over the well
o = cv.obj()
o.part(pole, LOG, d=1)
o.part(rrect(44, 50, 55, 60, 2), STONE, d=2)   # counterweight stone lashed on
o.draw()
cv.fill(line([(45, 53), (54, 57)]), '#5c3420')
cv.fill(rect(65, 65, 66, 67), '#2a1a10')   # pivot pin
o = cv.obj()
o.part(rect(110, 99, 111, 130), ramp('#9a7a52', '#6a4e32'), d=0)   # hanging pole down to the bucket
o.part(rrect(105, 130, 116, 139, 1), LOG, d=2)   # bucket coming up over the rim
o.draw()
cv.fill(rect(105, 132, 116, 132) | rect(105, 137, 116, 137), '#5b6470')
cv.dots([(107, 140), (113, 141), (110, 142)], WATER['r'])   # drips
o = cv.obj()
o.part(rect(wbx0, wby0, wbx0 + 20, wby0 + 14), LOG, d=2)   # well box
o.part(rect(wbx0 - 2, wby0 - 3, wbx0 + 22, wby0), LOG, d=1)   # rim log
o.draw()
for y in range(wby0 + 4, wby0 + 14, 4):
    cv.fill(rect(wbx0 + 1, y, wbx0 + 19, y), LOG['s'])
cv.fill(rect(wbx0 + 2, wby0 - 2, wbx0 + 18, wby0 - 2), '#2a1a10')
for x in range(wbx0, wbx0 + 21, 5):
    cv.dots([(x, wby0 + 1), (x + 1, wby0 + 1)], RED['b'])   # painted rim
hand = gnome(126, 160, hat=BLUE, tunic=RED, arm=-1, hat_lean=1)
cv.fill(line([(hand[0], hand[1]), (110, 118)]), '#9a7a52')   # hauling on the pole
# ---------------------------------------------------------------- gnome child carrying a basket of painted eggs up the track
hand = gnome(160, 194, hat=RED, tunic=BLUE, arm=1, hat_lean=-1)
o = cv.obj()
o.part(rrect(hand[0] + 1, hand[1], hand[0] + 13, hand[1] + 7, 2), ramp('#c4a070', '#9a7a52', '#e0c090'), d=2)
o.part(line([(hand[0] + 2, hand[1]), (hand[0] + 7, hand[1] - 6), (hand[0] + 12, hand[1])]), ramp('#9a7a52', '#6a4e32'), d=0)
o.draw()
for k, (ex, c) in enumerate(((2, RED), (5, BLUE), (8, GOLD), (11, RED))):
    cv.fill(ell(hand[0] + ex, hand[1] - 3, hand[0] + ex + 3, hand[1] + 2), c['b'])
    cv.dots([(hand[0] + ex + 1, hand[1] - 1)], '#ffffff')
cv.fill(rect(hand[0] + 2, hand[1] + 3, hand[0] + 12, hand[1] + 3), '#9a7a52')

# ---------------------------------------------------------------- slushy snowman leaning by the stream
smx0, smy0 = 214, 176
shadow(smx0 - 12, smy0 + 10, smx0 + 14, smy0 + 15, '#3f8a32')
o = cv.obj()
o.part(ell(smx0 - 10, smy0 - 2, smx0 + 10, smy0 + 13), SNOW, d=3)
o.part(ell(smx0 - 6, smy0 - 14, smx0 + 7, smy0 - 1), SNOW, d=2)
o.part(rect(smx0 - 5, smy0 - 20, smx0 + 5, smy0 - 15), ramp('#c8643a', '#9a4424', '#e8905a'), d=2)   # clay-pot hat
o.draw()
cv.fill(rect(smx0 - 7, smy0 - 15, smx0 + 7, smy0 - 15), '#9a4424')
cv.dots([(smx0 - 2, smy0 - 9), (smx0 + 3, smy0 - 9)], '#2a1a10')
cv.fill(line([(smx0 + 1, smy0 - 7), (smx0 + 6, smy0 - 6)]), '#e8841f')   # carrot nose
cv.dots([(smx0, smy0 + 2), (smx0, smy0 + 6)], '#2a1a10')
cv.fill(line([(smx0 + 9, smy0), (smx0 + 17, smy0 - 7)]), '#74462a')   # twig arm
cv.fill(line([(smx0 - 9, smy0 + 1), (smx0 - 16, smy0 - 3)]), '#74462a')
cv.fill(rect(smx0 - 7, smy0 - 3, smx0 + 7, smy0 - 2), RED['b'])   # red scarf
cv.fill(rect(smx0 + 4, smy0 - 2, smx0 + 6, smy0 + 5), RED['s'])
melt = ell(smx0 - 16, smy0 + 10, smx0 + 16, smy0 + 16) & ~ell(smx0 - 12, smy0 + 9, smx0 + 14, smy0 + 14)
cv.fill(melt, WATER['r'])

# ---------------------------------------------------------------- geese marching across the front (to the puddle)
GREYGOOSE = ramp('#a8acb0', '#7a8088', '#d4d6d8')
GOSL = ramp('#f5d64a', '#d8a830', '#fff0a0')


def goose(gx, gy, k=1, head_down=False, col=GOOSE, flap=False, bow=None):
    shadow(gx - 6, gy + 5, gx + 8, gy + 8, '#3f8a32')
    o = cv.obj()
    if flap:   # one wing raised and spread, flapping
        o.part(poly([(gx - 4 * k, gy - 1), (gx + 2 * k, gy - 2), (gx - 3 * k, gy - 13), (gx - 7 * k, gy - 11), (gx - 9 * k, gy - 7)]), col, d=1)
    o.part(ell(gx - 6, gy - 4, gx + 7, gy + 5), col, d=2)
    if head_down:
        o.part(line([(gx + 5 * k, gy - 1), (gx + 9 * k, gy + 3)], 2), col, d=0)
        o.part(rect(min(gx + 8 * k, gx + 10 * k), gy + 2, max(gx + 8 * k, gx + 10 * k), gy + 4), col, d=0)
    else:
        o.part(rect(min(gx + 4 * k, gx + 5 * k), gy - 11, max(gx + 4 * k, gx + 5 * k), gy - 2), col, d=1)
        o.part(ell(gx + 3 * k - 2, gy - 14, gx + 3 * k + 3, gy - 10), col, d=1)
    o.draw()
    if flap:
        for j in range(3):   # flight-feather notches
            cv.dots([(gx - (4 + 2 * j) * k, gy - 10 + j * 2)], col['s'])
    if head_down:
        cv.dots([(gx + 11 * k, gy + 3), (gx + 11 * k, gy + 4)], '#e8841f')
    else:
        cv.dots([(gx + 6 * k, gy - 12), (gx + 7 * k, gy - 12), (gx + 6 * k, gy - 11)], '#e8841f')
        cv.dots([(gx + 4 * k, gy - 13)], '#2a1a10')
    cv.fill(line([(gx - 4 * k, gy - 1), (gx + 2 * k, gy + 1)]), col['s'])   # wing line
    if col is GREYGOOSE:   # barred grey back
        cv.fill(line([(gx - 3 * k, gy - 3), (gx + 3 * k, gy - 2)]) | line([(gx - 5 * k, gy + 1), (gx - 1 * k, gy + 2)]), '#6a7078')
    cv.dots([(gx - 7 * k, gy - 2), (gx - 8 * k, gy - 3)], col['b'])   # tail tip
    cv.dots([(gx - 1, gy + 6), (gx - 1, gy + 7), (gx + 2, gy + 6), (gx + 2, gy + 7)], '#e8841f')
    if bow and not head_down:   # a ribbon bow on the neck
        bx_ = min(gx + 4 * k, gx + 5 * k)
        cv.fill(rect(bx_ - 2, gy - 7, bx_ + 3, gy - 6), bow['b'])
        cv.dots([(bx_ - 2, gy - 5), (bx_ + 3, gy - 5), (bx_ - 3, gy - 8), (bx_ + 4, gy - 8)], bow['s'])


def gosling(gx, gy, k=1):
    o = cv.obj()
    o.part(ell(gx - 3, gy - 2, gx + 3, gy + 2), GOSL, d=1)
    o.part(ell(gx + 2 * k - 2, gy - 5, gx + 2 * k + 1, gy - 2), GOSL, d=0)
    o.draw()
    cv.dots([(gx + 2 * k + (2 if k > 0 else -3), gy - 4)], '#e8841f')
    cv.dots([(gx + 2 * k, gy - 4)], '#2a1a10')
    cv.dots([(gx - 1, gy + 3), (gx + 1, gy + 3)], '#e8841f')


for gx, gy, hd, col, fl, bw in ((10, 178, False, GOOSE, False, RED), (30, 186, False, GREYGOOSE, False, None), (48, 176, True, GOOSE, False, None),
                                (60, 190, False, GOOSE, True, BLUE), (126, 186, True, GREYGOOSE, False, None)):
    goose(gx, gy, 1, hd, col, fl, bw)
goose(286, 192, -1, bow=BLUE)
for gx, gy in ((20, 162), (27, 165), (34, 161), (70, 174), (284, 178), (274, 182)):   # goslings trotting after
    gosling(gx, gy, -1 if gx > 200 else 1)
cv.dots([(20, 196), (22, 196), (40, 194)], '#f4f4ee')   # a few feathers

# ---------------------------------------------------------------- gorodki: the skittle town in a chalk square, a throwing bat in the grass
sq = rect(8, 138, 40, 154) & ~rect(10, 140, 38, 152)
cv.fill(sq, '#f1ece0')
for k, (px, py) in enumerate(((16, 146), (22, 145), (28, 146), (22, 150), (34, 147))):
    o = cv.obj()
    o.part(rect(px, py - 7, px + 2, py), ramp('#e0c090', '#a8885a', '#f6e4b8'), d=1)
    o.draw()
    cv.dots([(px + 1, py - 6)], RED['b'] if k % 2 else BLUE['b'])
o = cv.obj()
o.part(line([(42, 156), (56, 146)], 3), LOG, d=1)
o.draw()
cv.fill(rect(30, 154, 33, 156), '#e0c090')   # a knocked-over pin

# ---------------------------------------------------------------- spring litter: snow patches, snowdrops, crocuses, stones, tufts
keep = rect(0, 160, 72, 199) | rect(4, 132, 56, 158) | rect(112, 112, 140, 162) | rect(148, 150, 176, 199) | rect(198, 150, 232, 194) | rect(200, 90, 256, 128) | puddle | track | stream
for _ in range(10):
    sx, sy = r(0, W - 20), r(130, 196)
    pm = ell(sx, sy, sx + r(8, 18), sy + r(3, 5))
    if (pm & keep).any():
        continue
    cv.fill(pm, SNOW['b'])
    cv.fill(pm & ~shift(pm, 0, -1), SNOW['s'])
for _ in range(70):
    fx, fy = r(0, W - 3), r(126, H - 3)
    if keep[fy, fx] or keep[fy + 2, fx]:
        continue
    k = r(0, 3)
    if k == 0:   # snowdrop: a nodding white bell
        cv.fill(rect(fx, fy, fx, fy + 3), '#3f8a32')
        cv.dots([(fx + 1, fy), (fx + 1, fy + 1), (fx + 2, fy + 1)], '#ffffff')
    elif k == 1:   # crocus
        cv.fill(rect(fx, fy + 2, fx, fy + 3), '#3f8a32')
        cv.dots([(fx, fy), (fx - 1, fy + 1), (fx, fy + 1), (fx + 1, fy + 1)], ('#9a6ac8', '#f5cf6a', '#ffffff')[r2(0, 2)])
    else:   # dandelion-green tuft
        cv.dots([(fx, fy), (fx - 1, fy + 1), (fx + 1, fy + 1), (fx, fy + 1)], GRASS['r'])
for sx, sy in ((6, 140), (190, 140), (74, 140), (232, 196), (142, 146)):
    o = cv.obj()
    o.part(ell(sx, sy, sx + 7, sy + 4), STONE, d=2)
    o.draw()

# ---------------------------------------------------------------- pass 1 additions (own generator r3): far copse, crane V, far windmill, rooks on the black earth,
# a woodpile with a cat and straw bee skeps under the chapel, a sledge with a bucket of pussy willow
for cx_, cy_ in ((86, 60), (91, 59), (96, 61)):   # far copse on the ridge
    cv.fill(ell(cx_ - 3, cy_ - 4, cx_ + 3, cy_ + 2), '#6f8f8a')
    cv.dots([(cx_ - 1, cy_ - 3), (cx_ - 2, cy_ - 2)], '#8fb0a8')
cv.fill(rect(85, 62, 98, 63) & m, '#6f8f8a')
for k, (bx, by) in enumerate(((84, 50), (88, 52), (92, 54), (80, 52), (76, 54))):   # cranes in a V
    cv.dots([(bx, by), (bx + 1, by - 1), (bx + 2, by), (bx + 3, by - 1), (bx + 4, by)], '#3a4a5a')
wmx, wmy = 236, 62   # far post windmill on the ridge
cv.fill(rect(wmx - 1, wmy - 5, wmx + 1, wmy), '#6a5a48')
cv.fill(rect(wmx - 3, wmy - 12, wmx + 3, wmy - 5), '#8a7060')
cv.fill(rect(wmx - 3, wmy - 12, wmx - 3, wmy - 5), '#a88a70')
cv.fill(poly([(wmx - 4, wmy - 12), (wmx, wmy - 16), (wmx + 4, wmy - 12)]), '#6a5a48')
for dx, dy in ((1, 1), (-1, 1)):
    cv.fill(line([(wmx - 7 * dx, wmy - 17 - 7 * dy + 7), (wmx + 7 * dx, wmy - 3 + 7 * dy - 7)]), '#e8e2d2')
cv.dots([(wmx, wmy - 10)], '#3a3a40')


def rook(x, y, fly=False):
    if fly:
        cv.fill(poly([(x - 5, y - 2), (x, y), (x + 5, y - 2), (x + 2, y + 1), (x - 2, y + 1)]), '#2a2a30')
        cv.dots([(x - 1, y), (x - 2, y)], '#c9c5bc')
        return
    cv.fill(ell(x - 3, y - 2, x + 3, y + 2), '#2a2a30')
    cv.fill(rect(x + 2, y - 4, x + 4, y - 2), '#2a2a30')
    cv.dots([(x + 5, y - 3), (x + 6, y - 3)], '#c9c5bc')
    cv.dots([(x - 1, y - 1), (x, y - 2)], '#4a5a6a')
    cv.dots([(x - 4, y), (x - 5, y + 1)], '#2a2a30')
    cv.dots([(x, y + 3), (x + 2, y + 3)], '#5b5450')


for rx_, ry_ in ((100, 100), (115, 108), (106, 92)):   # rooks back on the ploughland: first sign of spring
    rook(rx_, ry_)
rook(118, 84, fly=True)
for rx_ in range(96, 120, 2):   # fresh dark furrow turned by the rooks' feet
    if r3(0, 2) == 0:
        cv.dots([(rx_, r3(95, 112))], '#2e2018')

# woodpile under the chapel: log ends in rows, a board roof with snow, a ginger cat dozing on it
o = cv.obj()
o.part(rect(10, 125, 46, 135), LOG, d=2)
o.part(rect(8, 122, 48, 124), ramp('#8a7a66', '#6a5a48', '#b0a290'), d=1)
o.draw()
for k, yy in enumerate((126, 131)):
    for xx in range(11 + (k % 2) * 2, 43, 5):
        lg = ell(xx, yy, xx + 4, yy + 4)
        cv.fill(lg, '#e0c090')
        cv.fill(lg & ~shift(lg, -1, -1), '#a8885a')
        cv.dots([(xx + 2, yy + 2)], '#c4a070' if r3(0, 1) else '#8a6a44')
ps = poly([(28, 122), (38, 120), (47, 122)])
cv.fill(ps, SNOW['b'])
CAT = ramp('#e8841f', '#b0601a', '#f5b060')
o = cv.obj()
o.part(ell(12, 116, 22, 122), CAT, d=1)
o.part(ell(19, 113, 25, 119), CAT, d=1)
o.part(poly([(20, 114), (20, 111), (22, 113)]) | poly([(23, 113), (25, 111), (25, 114)]), CAT, d=0)
o.part(line([(12, 121), (8, 121), (7, 119)], 2), CAT, d=0)
o.draw()
cv.dots([(14, 118), (16, 119), (18, 118)], '#b0601a')   # stripes
cv.fill(rect(21, 116, 22, 116) | rect(24, 116, 24, 116), '#2a1a10')   # sleepy eyes
cv.dots([(23, 117)], '#f0a0a0')
for k, (sx0, sy0) in enumerate(((51, 135), (59, 135))):   # straw bee skeps on a plank
    o = cv.obj()
    o.part(ell(sx0 - 5, sy0 - 13, sx0 + 4, sy0 + 3) & rect(0, 0, W, sy0 - 1), ramp('#d8b860', '#a8883a', '#f2d88a'), d=2)
    o.draw()
    for yy in range(sy0 - 11, sy0, 2):
        cv.fill(ell(sx0 - 5, sy0 - 13, sx0 + 4, sy0 + 3) & rect(0, yy, W, yy) & shift(ell(sx0 - 5, sy0 - 13, sx0 + 4, sy0 + 3), 1, 0) & shift(ell(sx0 - 5, sy0 - 13, sx0 + 4, sy0 + 3), -1, 0), '#a8883a')
    cv.fill(rect(sx0 - 1, sy0 - 3, sx0, sy0 - 1), '#2a1a10')
o = cv.obj()
o.part(rect(45, 135, 63, 136), LOG, d=0)
o.draw()
for bx_, by_ in ((47, 122), (55, 120), (61, 125), (52, 127)):   # first bees
    cv.dots([(bx_, by_), (bx_ + 1, by_)], '#2a1a10')
    cv.dots([(bx_, by_ - 1)], '#f5cf6a')

# sledge left out in the thaw, a painted bucket of pussy willow on it
o = cv.obj()
o.part(rect(200, 143, 221, 145), LOG, d=1)
o.part(rect(202, 146, 203, 148) | rect(218, 146, 219, 148), LOG, d=0)
o.draw()
cv.fill(line([(198, 149), (222, 149), (225, 147), (225, 145)]), '#4a2c1a')
for x in range(203, 220, 4):
    cv.fill(rect(x, 143, x, 145), LOG['s'])
for tx, ty in ((204, 116), (209, 112), (214, 114), (219, 120), (200, 122)):
    cv.fill(line([(210, 136), (tx, ty)]), '#6a3a2a')
    for j in (5, 9, 13, 16):
        px_ = 210 + (tx - 210) * j // 18
        py_ = 136 + (ty - 136) * j // 18
        cv.fill(rect(px_ + 1, py_ - 1, px_ + 2, py_), '#f4f0e8')
        cv.dots([(px_ + 2, py_)], '#b9b2a2')
o = cv.obj()
o.part(poly([(204, 132), (216, 132), (214, 142), (206, 142)]), BLUE, d=2)
o.draw()
cv.fill(line([(204, 131), (210, 127), (216, 131)]) & ~rect(206, 128, 214, 132), '#5b6470')
cv.fill(rect(206, 136, 214, 136), '#ffffff')
cv.dots([(208, 139), (212, 139)], RED['b'])
cv.dots([(210, 139)], GOLD['b'])

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'birchbramble', out)
    print('birchbramble:', n, 'colours')
