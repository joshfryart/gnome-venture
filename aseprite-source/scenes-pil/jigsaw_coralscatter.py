"""Jigsaw picture: THE CORALSCATTER (draft v0): game/assets/img/jigsaw/coralscatter.jpg (+ -thumb). Usage: python3 -B aseprite-source/scenes-pil/jigsaw_coralscatter.py [outdir]
A Pacific lagoon at dusk seen half above, half below the waterline: a navy star sky with the Starpath (a chain of bright stars) and a moon, a smoking
volcano island with lava runs and palms on the left, an outrigger canoe with a crab-claw sail and a gnome navigator pointing up the star path, a
tide-pool village of thatched huts on stilts with a fishing gnome, a beach with a kangaroo and a kiwi, the Stone Head Watchers on a grassy bluff.
Below the line: aqua water with light shafts, the volcano's underwater flank with the glowworm grotto, stilts down to the reef, the Box Jelly Queen,
a snorkelling gnome holding a spiral shell, a sea turtle, fish, and a coral reef floor (branching coral, brain coral, sea fans, anemone and clownfish,
giant clam, starfish, urchins, an octopus).
"""
import math
import sys

from jigsaw_common import *  # noqa: F401,F403

# ---------------------------------------------------------------- palette (coral pink, aqua, lava orange, deep navy)
NAVY0, NAVY1, NAVY2 = '#16203f', '#22305a', '#353f74'
DUSK0, DUSK1, DUSK2 = '#5c4a86', '#a8608e', '#e57f8a'
GLOW = '#f6a77a'
CORAL = ramp('#ef6f78', '#bf4560', '#ffa6a0')
LAVA = ramp('#f27a2a', '#c2481e', '#ffc94a')
AQUA = ramp('#4cc7c4', '#2a9aa8', '#9ee8de')
VOLC = ramp('#5a3a56', '#3a2442', '#7e5674')
UROCK = ramp('#3c4a72', '#28325a', '#566a92')
JUNG = ramp('#2f8a62', '#1d5e4c', '#5cb07a')
PALM = ramp('#3f9a5e', '#1d5e4c', '#7cc77a')
TRUNK = ramp('#9a6a3f', '#6a4428', '#c99a5a')
WOOD = ramp('#a0663a', '#6a4428', '#d29a5a')
THATCH = ramp('#d9a050', '#a8702e', '#f2cc7a')
WEAVE = ramp('#e8c48a', '#b8925a', '#fbe4b0')
SAND = ramp('#f2d29a', '#c9a46a', '#fff0c8')
GRASS = ramp('#6aaa4e', '#3f7a3e', '#9acc6a')
STONE = ramp('#9a96a8', '#6a6680', '#c8c4d2')
ROO = ramp('#c9784a', '#9a5232', '#e8a070')
KIWI = ramp('#8a6440', '#5c4028', '#b08a5a')
SKIN = ramp('#f2c8a0', '#d9a07a', '#fff0d8')
BEARD = ramp('#f1ece0', '#c9c5bc', '#ffffff')
RED = ramp('#d6322b', '#a8241f', '#f08a4a')
TEAL = ramp('#2f8fa8', '#1f6080', '#7ad0e0')
YEL = ramp('#f2c43a', '#c9921a', '#fbe680')
PURP = ramp('#8a5aa8', '#5e3a80', '#b88ad0')
JELLY = ramp('#cfe2f6', '#94b4dc', '#ffffff')
TURT = ramp('#6a9a4a', '#44703a', '#9ac46a')
SHELL = ramp('#9a7040', '#6a4828', '#c99a5a')
W0, W1, W2, W3 = '#5cd0c8', '#3fb4bc', '#2a92a8', '#1f7090'   # underwater depth bands
SHAFT = '#76dcd2'
DARK = '#2a1a10'
WL = 92   # the waterline (camera sits on it)

cv = new_canvas(NAVY0)
r = rnd(1771)
r2 = rnd(53)
yy_, xx_ = np.mgrid[0:H, 0:W]


def below(thr):
    """Mask of pixels at or below a per-column threshold (array of W ints)."""
    return yy_ >= np.asarray(thr)[None, :]


def wavy(y0, amp, per, ph=0.0, step=3):
    xs = (np.arange(W) // step) * step
    return np.round(y0 + amp * np.sin(xs / per + ph)).astype(int)


def gnome(gx, gy, tunic, hat, arm=None, flip=False):
    """A standing gnome, feet at (gx, gy). arm: None, 'up' (pointing up-right), 'paddle'."""
    o = cv.obj()
    o.part(rect(gx - 5, gy - 2, gx - 1, gy) | rect(gx + 1, gy - 2, gx + 5, gy), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=1)
    o.part(rrect(gx - 5, gy - 12, gx + 5, gy - 2, 2), tunic, d=2, contour=True)
    o.part(poly([(gx - 5, gy - 15), (gx + 5, gy - 15), (gx, gy - 5)]), BEARD, d=1, contour=True)
    o.part(rect(gx - 4, gy - 19, gx + 4, gy - 14), SKIN, d=1)
    tip = (gx - 4, gy - 32) if not flip else (gx + 4, gy - 32)
    o.part(poly([(gx - 6, gy - 17), (gx + 6, gy - 17), tip]), hat, d=2, contour=True)
    if arm == 'up':
        o.part(line([(gx + 4, gy - 10), (gx + 9, gy - 16), (gx + 12, gy - 22)], 2), tunic, d=0)
    o.draw()
    cv.fill(rect(gx - 6, gy - 18, gx + 6, gy - 17), hat['s'])
    cv.dots([(gx - 2, gy - 16), (gx + 2, gy - 16)], DARK)
    cv.dots([(gx, gy - 15), (gx + 1, gy - 15)], '#e0907a')
    cv.dots([(gx - 3, gy - 14), (gx + 3, gy - 14)], '#f0a0a0')
    if arm == 'up':
        cv.fill(rect(gx + 12, gy - 24, gx + 13, gy - 22), SKIN['b'])


def fish(x, y, rp, s=4, face=1, outline=True, stripe=None):
    """A fish centred at (x, y), facing right (face=1) or left (-1)."""
    body = ell(x - s, y - s // 2 - 1, x + s, y + s // 2 + 1)
    tx = x - face * s
    tail = poly([(tx, y), (tx - face * (s // 2 + 2), y - s // 2 - 1), (tx - face * (s // 2 + 2), y + s // 2 + 1)])
    o = cv.obj(outline=outline)
    o.part(body | tail, rp, d=1)
    o.draw()
    if stripe:
        cv.fill(body & rect(x - 1, 0, x, H), stripe)
    cv.dots([(x + face * (s - 2), y - 1)], DARK)


def bubbles(x, y, n, rr):
    for k in range(n):
        bx, by = x + rr(-2, 2), y - k * rr(4, 7)
        if by < WL + 3:
            break
        s = rr(0, 1)
        if s:
            cv.dots([(bx, by - 1), (bx - 1, by), (bx + 1, by), (bx, by + 1)], '#c8f4ee')
            cv.dots([(bx - 1, by - 1)], '#ffffff')
        else:
            cv.dots([(bx, by)], '#c8f4ee')


def palm(x, y, h, lean, fronds=7):
    """Curved trunk from (x, y) up h px leaning by `lean`, then a crown of drooping fronds."""
    pts = []
    for k in range(0, h + 1, 3):
        t = k / h
        pts.append((x + int(lean * t * t), y - k))
    o = cv.obj()
    o.part(line(pts, 3), TRUNK, d=1)
    o.draw()
    for i, (px, py) in enumerate(pts[1:-1]):
        if i % 2 == 0:
            cv.dots([(px - 1, py), (px, py), (px + 1, py)], TRUNK['s'])
    cx, cy = pts[-1]
    m = blank()
    for k in range(fronds):
        a = math.pi * (0.9 + 1.2 * k / (fronds - 1))
        ex, ey = cx + int(15 * math.cos(a)), cy + int(8 * math.sin(a)) + 7
        mx, my = cx + int(9 * math.cos(a)), cy + int(8 * math.sin(a)) - 2
        m |= line([(cx, cy), (mx, my), (ex, ey)], 3)
    o = cv.obj()
    o.part(m, PALM, d=1)
    o.draw()
    cv.fill(ell(cx - 3, cy, cx + 1, cy + 4), '#6a4428')   # coconuts
    cv.dots([(cx - 2, cy + 1)], '#9a6a3f')


# ================================================================ SKY (dusk: deep navy to coral at the horizon)
for y0, amp, col in ((18, 2, NAVY1), (34, 2, NAVY2), (48, 2, DUSK0), (58, 2, DUSK1), (66, 1, DUSK2), (72, 1, GLOW)):
    cv.fill(below(wavy(y0, amp, 9 + y0 % 5, y0 * 0.3, 4)), col)
# streak clouds lit pink from below (thin hard bars, varied lengths so sky cells differ)
for cx, cy, w in ((22, 40, 30), (150, 30, 38), (236, 44, 34), (100, 54, 26), (200, 58, 40), (286, 60, 22), (60, 14, 24), (176, 12, 18)):
    m = rrect(cx - w // 2, cy, cx + w // 2, cy + 2, 1) | rrect(cx - w // 4, cy - 2, cx + w // 5, cy, 1)
    cv.fill(m, '#7a5a92' if cy < 30 else '#c87a9a')
    cv.fill(m & rect(0, cy + 2, W, cy + 2), DUSK2 if cy < 50 else GLOW)
# stars: scattered dim dots, a few crosses
for _ in range(120):
    sx, sy = r(0, W - 1), r(0, 50)
    cv.dots([(sx, sy)], ('#8a9ad0', '#c8d4f2', '#f2e8c8')[r(0, 2)])
for sx, sy in ((14, 8), (92, 6), (40, 30), (276, 34), (210, 10), (124, 38), (296, 6), (240, 26)):
    cv.dots([(sx, sy), (sx - 1, sy), (sx + 1, sy), (sx, sy - 1), (sx, sy + 1)], '#c8d4f2')
    cv.dots([(sx, sy)], '#ffffff')
# the Starpath: a chain of bright stars rising from the canoe's bow to the upper right, joined by a dotted thread
SP = [(150, 44), (164, 34), (180, 27), (198, 22), (218, 18), (238, 16)]
for (ax, ay), (bx, by) in zip(SP, SP[1:]):
    n = max(abs(bx - ax), abs(by - ay))
    for k in range(3, n - 2, 3):
        cv.dots([(ax + (bx - ax) * k // n, ay + (by - ay) * k // n)], '#f6c49a')
for i, (sx, sy) in enumerate(SP):
    s = 2 if i % 2 == 0 else 1
    cv.fill(rect(sx - s - 1, sy, sx + s + 1, sy) | rect(sx, sy - s - 1, sx, sy + s + 1), '#fff2b0')
    cv.fill(rect(sx - 1, sy - 1, sx + 1, sy + 1), '#ffffff')
# crescent moon (upper right)
mm = ell(258, 4, 274, 20) & ~ell(263, 2, 279, 18)
cv.fill(mm, '#fff2c8')
cv.fill(mm & ~shift(mm, -1, -1), '#e8d49a')
# frigatebirds (long crooked wings)
for bx, by in ((112, 20), (124, 26), (284, 44)):
    cv.dots([(bx - 4, by - 1), (bx - 3, by), (bx - 2, by), (bx - 1, by + 1), (bx, by), (bx + 1, by + 1), (bx + 2, by), (bx + 3, by), (bx + 4, by - 1)], DARK)
    cv.dots([(bx, by + 1)], '#d6322b')
# a breadfruit-leaf kite over the village, tail streaming
kx, ky = 196, 38
o = cv.obj()
o.part(poly([(kx, ky - 7), (kx + 5, ky), (kx, ky + 8), (kx - 5, ky)]), JUNG, d=1)
o.draw()
cv.fill(line([(kx, ky - 6), (kx, ky + 7)]), JUNG['s'])
cv.fill(line([(kx - 4, ky), (kx + 4, ky)]), JUNG['s'])
for k in range(6):
    tx, ty = kx - 2 - k * 3, ky + 9 + (k % 2) * 2
    cv.dots([(tx, ty), (tx - 1, ty)], (CORAL['b'], LAVA['r'])[k % 2])
cv.fill(line([(kx + 1, ky + 8), (kx + 2, ky + 20), (kx - 2, ky + 30)]), '#f2e4c0')   # string down to the hut roof

# ================================================================ far ocean and distant islets
cv.fill(rect(0, 76, W - 1, WL - 1), '#3a4c84')
for y in range(77, WL, 2):   # sunset glints on the far water
    for _ in range(9):
        gx = r(0, W - 8)
        cv.fill(rect(gx, y, gx + r(2, 6), y), ('#e57f8a', '#f6a77a', '#5a6aa4', '#2a3a6a')[r(0, 3)])
for ix, iw, ih in ((124, 22, 6), (150, 12, 4), (276, 16, 5)):
    m = ell(ix, 76 - ih, ix + iw, 76 + ih) & ~rect(0, 77, W, H)
    cv.fill(m, '#2c2a5a')
    cv.fill(m & ~shift(m, 1, 1), '#4a3a72')
palm_small = [(132, 70), (137, 71)]
for px, py in palm_small:
    cv.fill(rect(px, py - 5, px, py), '#2c2a5a')
    cv.dots([(px - 2, py - 6), (px - 1, py - 6), (px + 1, py - 6), (px + 2, py - 6), (px, py - 7), (px - 3, py - 5), (px + 3, py - 5)], '#2c2a5a')

# ================================================================ UNDERWATER base (bands and light shafts)
uw = rect(0, WL, W - 1, H - 1)
cv.fill(uw, W0)
cv.fill(below(wavy(118, 2, 11, 1.0, 4)) & uw, W1)
cv.fill(below(wavy(146, 2, 13, 2.0, 4)) & uw, W2)
cv.fill(below(wavy(172, 2, 10, 0.5, 4)) & uw, W3)
for sx, w in ((96, 10), (128, 6), (214, 12), (252, 7), (176, 5)):   # slanted light shafts (hard parallelograms, from the upper left)
    m = poly([(sx, WL), (sx + w, WL), (sx + w + 40, 170), (sx + 40, 170)]) & uw
    cv.fill(m & (np.all(cv.px == np.array([0x5c, 0xd0, 0xc8]), axis=2)), SHAFT)
    cv.fill(m & (np.all(cv.px == np.array([0x3f, 0xb4, 0xbc]), axis=2)), W0)
    cv.fill(m & (np.all(cv.px == np.array([0x2a, 0x92, 0xa8]), axis=2)), W1)
# underside of the surface: a bright wavy line just below the waterline
surf = below(wavy(WL, 1, 5, 0.0, 2)) & ~below(wavy(WL + 2, 1, 5, 0.0, 2))
cv.fill(surf, '#bff0ea')
cv.fill(rect(0, WL - 1, W - 1, WL - 1), '#ffffff')
for x in range(0, W, 7):   # little wavelets on the line
    cv.dots([(x, WL - 2), (x + 1, WL - 2), (x + 2, WL - 3)], '#d8f6f2')

# ================================================================ VOLCANO ISLAND (left)
vol = poly([(0, 58), (16, 46), (34, 28), (42, 22), (58, 22), (66, 28), (86, 50), (104, 72), (118, WL), (0, WL)])
o = cv.obj()
o.part(vol, VOLC, d=3)
o.draw()
for k in range(26):   # rock strata ledges
    x0, y0 = r(4, 96), r(28, 70)
    if vol[y0, x0] and vol[y0, min(W - 1, x0 + 6)]:
        cv.fill(line([(x0, y0), (x0 + r(3, 7), y0 + 1)]), VOLC['s'] if k % 3 else VOLC['r'])
crater = ell(42, 18, 58, 26) & ~rect(0, 23, W, H)
cv.fill(ell(43, 19, 57, 25), LAVA['b'])
cv.fill(ell(46, 20, 54, 24), LAVA['r'])
lava = blank()
for pts in (((50, 23), (46, 32), (48, 40), (40, 52), (36, 62)), ((54, 23), (60, 34), (66, 42), (70, 56), (78, 66)), ((48, 23), (40, 30), (30, 40))):
    lava |= line(list(pts), 2)
cv.fill(lava & vol, LAVA['b'])
cv.fill(lava & vol & ~shift(lava, 1, 0), LAVA['r'])
cv.fill(dil4(lava) & vol & ~lava, LAVA['s'])
# smoke: hard puffs rising and drifting right, lava-lit undersides
for k in range(9):
    sx, sy = 50 + k * 5 + (k * k) // 3, 14 - k * 4
    s = 3 + k // 2
    pm = ell(sx - s, sy - s + 1, sx + s, sy + s - 1)
    cv.fill(pm, '#6e5a80' if k < 6 else '#7e6a92')
    cv.fill(pm & ~shift(pm, 1, 1), '#9a88aa')
    cv.fill(pm & ~shift(pm, 0, -2), '#4a3a60' if k > 2 else LAVA['s'])
for ex, ey in ((46, 12), (56, 8), (40, 16), (60, 14), (52, 4), (36, 10)):   # embers
    cv.dots([(ex, ey)], LAVA['r'] if ex % 2 else LAVA['b'])
# jungle skirt round the volcano's foot
jm = blank()
for _ in range(26):
    cx, cy = r(-4, 112), r(66, 86)
    s = r(5, 9)
    jm |= ell(cx - s, cy - s * 3 // 4, cx + s, cy + s * 3 // 4)
jm &= poly([(0, 62), (40, 66), (80, 64), (110, 74), (124, WL), (0, WL)]) & ~rect(0, WL, W, H)
o = cv.obj()
o.part(jm, JUNG, d=2)
o.draw()
ys, xs = np.nonzero(jm)
for k in range(60):
    i = r(0, len(xs) - 1)
    x, y = int(xs[i]), int(ys[i])
    cv.dots([(x, y), (x + 1, y)], (JUNG['r'], '#f08ac0', JUNG['s'], YEL['b'])[k % 4] if k % 7 else LAVA['r'])
for px, py, h, lean in ((12, 82, 26, 8), (30, 86, 32, -6), (78, 84, 24, 10), (96, 88, 20, -4)):
    palm(px, py, h, lean)
# little beach and an earth-oven fire at the shore
cv.fill(poly([(60, WL), (68, 86), (96, 84), (112, 88), (118, WL)]), SAND['b'])
cv.fill(poly([(60, WL), (68, 86), (96, 84), (112, 88), (118, WL)]) & ~shift(poly([(60, WL), (68, 86), (96, 84), (112, 88), (118, WL)]), 0, 1), SAND['r'])
o = cv.obj()
o.part(ell(64, 86, 74, 91), STONE, d=1)
o.draw()
cv.dots([(68, 85), (69, 84), (70, 85), (69, 83)], LAVA['b'])
cv.dots([(69, 85)], LAVA['r'])
cv.dots([(70, 80), (71, 77), (70, 74)], '#9a88aa')

# ================================================================ STONE HEAD WATCHERS on the bluff (right)
bluff = poly([(240, WL), (244, 78), (252, 66), (262, 60), (300, 58), (300, WL)])
o = cv.obj()
o.part(bluff, VOLC, d=3)
o.draw()
top = bluff & ~shift(bluff, 0, 6)
cv.fill(top, GRASS['b'])
cv.fill(top & ~shift(top, 0, -2), GRASS['s'])
cv.fill(top & ~shift(top, 0, 1), GRASS['r'])
for k in range(14):
    x0, y0 = r(246, 298), r(70, 90)
    if bluff[y0, x0]:
        cv.fill(line([(x0, y0), (x0 + r(2, 5), y0)]), VOLC['s'])
for hx, hb, hh, topknot in ((256, 70, 22, False), (272, 66, 28, True), (290, 64, 24, False)):
    w = hh * 2 // 5
    head = poly([(hx - w // 2, hb), (hx - w // 2 - 1, hb - hh + 6), (hx - w // 2 + 1, hb - hh), (hx + w // 2, hb - hh), (hx + w // 2 + 1, hb - hh + 6), (hx + w // 2, hb)])
    o = cv.obj()
    o.part(head, STONE, d=2)
    if topknot:
        o.part(rrect(hx - w // 2 + 1, hb - hh - 5, hx + w // 2, hb - hh, 1), CORAL if False else LAVA, d=1, contour=True)
    o.draw()
    by = hb - hh + 7
    cv.fill(rect(hx - w // 2, by, hx + w // 2, by + 1), STONE['s'])   # heavy brow
    cv.dots([(hx - 2, by + 2), (hx + 2, by + 2)], '#3a3650')        # deep-set eyes
    cv.fill(rect(hx, by + 2, hx + 1, by + 9), STONE['s'])            # long nose
    cv.dots([(hx - 1, by + 9), (hx + 2, by + 9)], '#4a4660')
    cv.fill(rect(hx - 2, by + 12, hx + 3, by + 12), '#4a4660')       # pressed lips
    cv.fill(rect(hx - w // 2, by + 3, hx - w // 2, by + 9), STONE['r'])   # ear
    cv.fill(rect(hx - 1, hb - 3, hx + 1, hb - 1), STONE['s'])        # hands carved on the belly
    for k in range(3):
        cv.dots([(hx - w // 2 + r(1, w - 2), hb - r(2, hh - 4))], '#7aa06a')   # lichen
# palm leaning over the bluff edge
palm(296, 62, 34, -14, 8)

# ================================================================ BEACH between village and bluff: kangaroo and kiwi
beach = poly([(196, WL), (206, 86), (226, 82), (244, 80), (246, WL)])
cv.fill(beach, SAND['b'])
cv.fill(beach & ~shift(beach, 0, 1), SAND['r'])
for _ in range(14):
    bx, by = r(204, 240), r(84, 90)
    if beach[by, bx]:
        cv.dots([(bx, by)], SAND['s'])
# kangaroo (standing on its tail, facing left)
kx, ky = 228, 88
o = cv.obj()
o.part(line([(kx + 4, ky - 2), (kx + 10, ky), (kx + 14, ky)], 3), ROO, d=1)       # tail
o.part(ell(kx - 3, ky - 14, kx + 6, ky - 1), ROO, d=2)                              # body
o.part(rect(kx - 4, ky - 2, kx + 3, ky), ROO, d=1)                                 # big feet
o.part(ell(kx - 5, ky - 22, kx + 2, ky - 14), ROO, d=1)                             # head
o.part(poly([(kx - 8, ky - 18), (kx - 4, ky - 20), (kx - 4, ky - 16)]), ROO, d=1)   # snout
o.part(rect(kx - 2, ky - 26, kx - 1, ky - 21) | rect(kx + 1, ky - 26, kx + 2, ky - 21), ROO, d=0)   # ears
o.draw()
cv.fill(ell(kx - 1, ky - 11, kx + 4, ky - 3), '#f2c8a0')    # pale belly
cv.dots([(kx - 3, ky - 19)], DARK)
cv.dots([(kx - 8, ky - 18)], DARK)
cv.dots([(kx - 3, ky - 11), (kx - 4, ky - 10)], ROO['s'])  # little forepaws
# kiwi (round, long beak probing the sand)
wx, wy = 212, 89
o = cv.obj()
o.part(ell(wx - 5, wy - 8, wx + 5, wy - 1), KIWI, d=2)
o.part(rect(wx - 2, wy - 1, wx - 2, wy) | rect(wx + 2, wy - 1, wx + 2, wy), ramp('#d9a35a', '#a8702e'), d=0)
o.draw()
cv.fill(line([(wx - 5, wy - 5), (wx - 11, wy - 1)]), '#e8c48a')
cv.dots([(wx - 3, wy - 6)], DARK)
for k in range(4):
    cv.dots([(wx - 2 + k * 2, wy - 4 + (k % 2))], KIWI['s'])
# hermit crab in a spiral shell
cv.fill(ell(238, 85, 243, 89), CORAL['r'])
cv.dots([(240, 87), (241, 86)], CORAL['s'])
cv.dots([(237, 89), (236, 88)], LAVA['s'])

# ================================================================ TIDE-POOL VILLAGE ON STILTS (centre right)
STILTS = (152, 164, 176, 188, 200)
for sx in STILTS:   # stilts: above water, then down through the lagoon to the reef
    o = cv.obj()
    o.part(rect(sx, 74, sx + 2, WL - 1), WOOD, d=1)
    o.draw()
    cv.fill(rect(sx, WL + 2, sx + 2, 186), '#4a6a72')
    cv.fill(rect(sx + 2, WL + 2, sx + 2, 186), '#2f4a58')
    for by in range(WL + 8, 184, 9):   # barnacles and weed on the posts
        cv.dots([(sx + (by // 9) % 3, by)], '#e8e0c8')
    cv.fill(line([(sx + 1, 186), (sx - 2, 176), (sx + 1, 168), (sx - 1, 160)]), '#3f9a5e')
cv.fill(line([(152, 80), (164, 90)]) | line([(176, 80), (188, 90)]) | line([(188, 80), (200, 90)]), WOOD['s'])   # cross braces
o = cv.obj()
o.part(rect(146, 72, 210, 75), WOOD, d=1)
o.draw()
for x in range(148, 210, 4):
    cv.dots([(x, 73)], WOOD['s'])
for hx0, hx1, wy0, rtop in ((150, 174, 58, 42), (182, 206, 60, 46)):
    o = cv.obj()
    o.part(rect(hx0 + 2, wy0, hx1 - 2, 71), WEAVE, d=2)
    o.draw()
    for yy in range(wy0 + 2, 71, 3):   # woven pandanus wall
        for xx in range(hx0 + 3 + (yy % 2) * 2, hx1 - 2, 4):
            cv.dots([(xx, yy), (xx + 1, yy)], WEAVE['s'])
    dx = (hx0 + hx1) // 2
    o = cv.obj()
    o.part(poly([(hx0 - 4, wy0 + 2), (dx, rtop), (hx1 + 4, wy0 + 2), (hx1 + 2, wy0 + 4), (hx0 - 2, wy0 + 4)]), THATCH, d=2)
    o.draw()
    for k in range(4):   # thatch rows
        y = rtop + 5 + k * 4
        hw = (y - rtop) * (hx1 - hx0 + 8) // 2 // (wy0 + 2 - rtop)
        for xx in range(dx - hw + 2, dx + hw - 1, 3):
            cv.dots([(xx, y), (xx + 1, y + 1)], THATCH['s'])
    cv.fill(rect(dx - 1, rtop - 3, dx + 1, rtop), THATCH['s'])   # ridge knot
    o = cv.obj()
    o.part(rect(dx - 3, wy0 + 5, dx + 3, 71), ramp('#4a2c1a', '#2a1a10', '#6a4428'), d=0)   # doorway
    o.draw()
    cv.fill(rect(dx - 2, wy0 + 6, dx + 2, wy0 + 9), '#f5cf6a')   # lamplight inside
for k in range(9):   # string of coloured lanterns between the huts
    lx = 172 + k * 2
    ly = 52 + int(4 * math.sin(k / 8 * math.pi))
    cv.dots([(lx, ly)], '#2a1a10')
    if k % 2 == 0:
        cv.fill(rect(lx, ly + 1, lx + 1, ly + 2), (CORAL['b'], YEL['b'], AQUA['b'], LAVA['b'], CORAL['r'])[k // 2])
# laundry rail with a fishing net hanging off the platform's left end
cv.fill(rect(146, 76, 148, 86), '#c9a46a')
for yy in range(77, 86, 2):
    cv.dots([(146, yy), (148, yy + 1)], '#8a6440')
# gnome sitting on the platform edge, fishing; line runs down into the lagoon
fgx, fgy = 206, 72
o = cv.obj()
o.part(rrect(fgx - 4, fgy - 9, fgx + 4, fgy, 2), TEAL, d=2, contour=True)
o.part(poly([(fgx - 4, fgy - 12), (fgx + 4, fgy - 12), (fgx, fgy - 3)]), BEARD, d=1, contour=True)
o.part(rect(fgx - 3, fgy - 16, fgx + 3, fgy - 11), SKIN, d=1)
o.part(poly([(fgx - 5, fgy - 14), (fgx + 5, fgy - 14), (fgx + 6, fgy - 26)]), CORAL, d=2, contour=True)
o.part(rect(fgx + 1, fgy + 1, fgx + 3, fgy + 7), TEAL, d=1)   # dangling legs
o.draw()
cv.fill(rect(fgx - 5, fgy - 15, fgx + 5, fgy - 14), CORAL['s'])
cv.dots([(fgx - 1, fgy - 13), (fgx + 2, fgy - 13)], DARK)
cv.dots([(fgx + 1, fgy - 12)], '#e0907a')
cv.fill(rect(fgx + 1, fgy + 8, fgx + 4, fgy + 9), '#5c3420')
cv.fill(line([(fgx + 3, fgy - 6), (fgx + 16, fgy - 18)], 1), '#6a4428')   # rod
cv.fill(line([(fgx + 16, fgy - 18), (fgx + 18, WL - 1)]) & ~below(np.full(W, WL)), '#e8e4d8')
cv.fill(rect(fgx + 18, WL + 2, fgx + 18, 132), '#d8f0ea')
cv.fill(rect(fgx + 17, WL - 1, fgx + 19, WL), CORAL['b'])   # float
cv.dots([(fgx + 17, 132), (fgx + 17, 133), (fgx + 18, 134)], '#c8c4d2')   # hook
# a gnome in the hut doorway with a lantern
gnome(162, 71, PURP, CORAL)
cv.fill(rect(169, 58, 171, 61), '#f5cf6a')
cv.dots([(170, 57)], DARK)

# ================================================================ OUTRIGGER CANOE with the navigator (centre left)
cx0, cx1, cy = 98, 150, 90
o = cv.obj()   # mast and crab-claw sail first (behind the hull)
o.part(rect(122, 46, 123, 88), WOOD, d=0)
o.draw()
sail = poly([(123, 86), (104, 48), (110, 46), (124, 70), (142, 50), (146, 54)])
o = cv.obj()
o.part(sail, CORAL, d=2)
o.draw()
for k in range(1, 4):   # sail seams and woven panels
    cv.fill(line([(123, 86), (106 + k * 9, 48 + k)]) & sail, CORAL['s'])
cv.fill(line([(110, 64), (116, 62)]) & sail, '#f2e4c0')
cv.fill(line([(132, 66), (138, 60)]) & sail, '#f2e4c0')
hull = poly([(cx0, cy - 6), (cx0 + 6, cy - 1), (cx1 - 6, cy - 1), (cx1, cy - 6), (cx1 - 2, cy + 2), (cx0 + 2, cy + 2)])
o = cv.obj()
o.part(hull, WOOD, d=2)
o.part(poly([(cx0 - 2, cy - 10), (cx0 + 2, cy - 9), (cx0 + 4, cy - 2), (cx0, cy - 4)]), WOOD, d=1)   # carved prow curls
o.part(poly([(cx1 + 2, cy - 10), (cx1 - 2, cy - 9), (cx1 - 4, cy - 2), (cx1, cy - 4)]), WOOD, d=1)
o.draw()
cv.fill(hull & rect(0, cy - 1, W, cy), LAVA['b'])   # painted band
for x in range(cx0 + 8, cx1 - 6, 6):
    cv.dots([(x, cy - 1), (x + 1, cy)], '#f2e4c0')
gnome(130, cy - 2, AQUA, LAVA, arm='up')        # the navigator points up the star path
gnome(108, cy - 2, YEL, PURP, flip=True)        # paddler at the stern
o = cv.obj()
o.part(line([(102, cy - 12), (96, WL + 2)], 2), WOOD, d=0)
o.part(ell(93, WL, 99, WL + 5), WOOD, d=1)
o.draw()
# outrigger booms and the float riding just in front, half under the line
for bx in (112, 136):
    cv.fill(line([(bx, cy - 2), (bx - 3, WL + 1)], 2), WOOD['s'])
o = cv.obj()
o.part(rrect(100, WL - 1, 146, WL + 3, 2), TRUNK, d=1)
o.draw()
# the hull's belly seen from below the line
cv.fill(ell(cx0 + 4, WL + 1, cx1 - 4, WL + 6) & ~rect(0, 0, W, WL + 1), '#2f6878')
cv.fill(rect(cx0 + 10, WL + 6, cx1 - 10, WL + 6), '#5cb0b8')

# ================================================================ UNDERWATER: volcano flank and the glowworm grotto (left)
flank = poly([(0, WL + 1), (118, WL + 1), (108, 106), (92, 124), (80, 142), (66, 158), (58, 178), (54, 199), (0, 199)])
o = cv.obj()
o.part(flank, UROCK, d=3)
o.draw()
for k in range(30):
    x0, y0 = r(2, 100), r(WL + 4, 196)
    if flank[y0, x0] and flank[y0, min(W - 1, x0 + 6)]:
        cv.fill(line([(x0, y0), (x0 + r(3, 6), y0 + r(-1, 1))]), UROCK['s'] if k % 3 else UROCK['r'])
cave = ell(10, 126, 50, 166) & ~rect(0, 160, W, H) | rect(14, 156, 46, 162)
cv.fill(dil4(cave) & ~cave, '#1a1a3a')
cv.fill(cave, '#121834')
for k in range(46):   # glowworm ceiling: blue-green dots, a few with dangling threads
    gx, gy = r(14, 46), r(128, 158)
    if cave[gy, gx]:
        cv.dots([(gx, gy)], ('#7af0c8', '#bfffe0', '#4ac0c8')[k % 3])
        if k % 5 == 0:
            cv.fill(rect(gx, gy + 1, gx, gy + 3), '#2a5a6a')
cv.fill(ell(22, 150, 38, 160) & cave, '#1c2a48')   # glowing pool on the cave floor
cv.dots([(26, 154), (31, 156), (34, 153)], '#7af0c8')
for _ in range(10):   # coral tufts on the rock
    x0, y0 = r(60, 110), r(100, 150)
    if flank[y0, x0] and not flank[y0, min(W - 1, x0 + 4)]:
        cv.fill(ell(x0 - 3, y0 - 3, x0 + 2, y0 + 2), (CORAL['b'], PURP['b'], LAVA['b'])[x0 % 3])
        cv.dots([(x0 - 2, y0 - 2)], '#ffffff')
for sx, sy in ((6, 106), (40, 110), (70, 104), (8, 184), (34, 176), (50, 190), (90, 112)):   # sea stars and anemones on the flank
    if flank[sy, sx]:
        cv.dots([(sx, sy), (sx - 1, sy), (sx + 1, sy), (sx, sy - 1), (sx, sy + 1), (sx - 2, sy + 1), (sx + 2, sy + 1)], CORAL['b'] if sx % 2 else LAVA['b'])
        cv.dots([(sx, sy)], LAVA['r'])
# crab on the rock
cbx, cby = 20, 190
o = cv.obj()
o.part(ell(cbx - 5, cby - 3, cbx + 5, cby + 2), RED, d=1)
o.part(ell(cbx - 9, cby - 6, cbx - 5, cby - 2) | ell(cbx + 5, cby - 6, cbx + 9, cby - 2), RED, d=1)
o.draw()
cv.dots([(cbx - 2, cby - 4), (cbx + 2, cby - 4)], DARK)
for dx in (-4, -2, 2, 4):
    cv.dots([(cbx + dx, cby + 3)], RED['s'])

# ================================================================ sand slope under the beach and bluff (right)
slope = poly([(196, WL + 1), (300, WL + 1), (300, 199), (230, 199), (244, 170), (260, 140), (250, 120), (222, 100)])
o = cv.obj()
o.part(slope, ramp('#c9b07a', '#9a8458', '#e8d4a0'), d=2)
o.draw()
cv.fill(slope & poly([(260, WL), (300, WL), (300, 150), (276, 140), (262, 116)]), UROCK['b'])   # the bluff's rock foot
cv.fill(slope & poly([(260, WL), (300, WL), (300, 150), (276, 140), (262, 116)]) & ~shift(slope & poly([(260, WL), (300, WL), (300, 150), (276, 140), (262, 116)]), -2, -2), UROCK['s'])
for k in range(30):
    x0, y0 = r(226, 298), r(100, 196)
    if slope[y0, x0]:
        cv.dots([(x0, y0), (x0 + 1, y0)], ('#9a8458', '#e8d4a0', '#fbe4b0')[k % 3])
# octopus peeking from the rock foot
ox, oy = 280, 150
o = cv.obj()
o.part(ell(ox - 7, oy - 12, ox + 7, oy + 2), CORAL, d=2)
for k in range(5):
    a = 0.3 + k * 0.6
    o.part(line([(ox - 4 + k * 2, oy), (ox - 8 + k * 4, oy + 6), (ox - 10 + k * 5, oy + 10 + (k % 2) * 2)], 2), CORAL, d=0)
o.draw()
cv.fill(rect(ox - 4, oy - 6, ox - 2, oy - 4), '#ffffff')
cv.fill(rect(ox + 2, oy - 6, ox + 4, oy - 4), '#ffffff')
cv.dots([(ox - 3, oy - 5), (ox + 3, oy - 5)], DARK)
for sx, sy in ((ox - 4, oy - 9), (ox + 3, oy - 10), (ox, oy - 3)):
    cv.dots([(sx, sy)], CORAL['r'])

# ================================================================ REEF FLOOR (bottom band across)
floor = below(wavy(182, 3, 8, 0.7, 3)) & rect(52, 0, W - 1, H - 1) & ~flank
cv.fill(floor, SAND['b'])
cv.fill(floor & ~shift(floor, 0, 1), SAND['r'])
for _ in range(60):
    x0, y0 = r(56, 298), r(182, 199)
    if floor[y0, x0]:
        cv.fill(line([(x0, y0), (x0 + r(2, 4), y0)]), SAND['s'])


def branch_coral(x, y, rp, h=16, spread=8):
    m = blank()
    for k in range(-2, 3):
        tx = x + k * spread // 2
        mx = x + k * spread // 4
        m |= line([(x, y), (mx, y - h // 2), (tx, y - h + abs(k) * 2)], 2)
        m |= line([(mx, y - h // 2), (mx + (1 if k >= 0 else -1) * 3, y - h // 2 - 4)], 2)
    o = cv.obj()
    o.part(m, rp, d=1)
    o.draw()
    ys, xs = np.nonzero(m)
    for i in range(0, len(xs), 7):
        cv.dots([(int(xs[i]), int(ys[i]))], rp['r'])


def brain_coral(x, y, s, rp):
    m = ell(x - s, y - s * 3 // 4, x + s, y + 2)
    o = cv.obj()
    o.part(m, rp, d=2)
    o.draw()
    for k in range(-s + 3, s - 2, 3):
        cv.fill(line([(x + k, y - s // 2 + 1), (x + k + 1, y - 1), (x + k - 1, y + 1)]) & m, rp['s'])


def sea_fan(x, y, rp, h=20):
    m = ell(x - h // 2, y - h, x + h // 2, y) & ~rect(0, y - 3, W, H) | rect(x - 1, y - 4, x, y)
    o = cv.obj()
    o.part(m, rp, d=1)
    o.draw()
    for k in range(-3, 4):
        cv.fill(line([(x, y - 3), (x + k * h // 8, y - h + 2 + abs(k))]) & m, rp['s'])
    for k in range(4):
        cv.fill(rect(x - h // 2, y - h + 4 + k * 4, x + h // 2, y - h + 4 + k * 4) & m & ~shift(m, 0, 2), rp['r'])


def seagrass(x, y, n, rr):
    for k in range(n):
        h = rr(8, 18)
        bx = x + k * 2
        cv.fill(line([(bx, y), (bx + rr(-2, 2), y - h // 2), (bx + rr(-3, 3), y - h)], 1), ('#3f9a5e', '#5cb07a', '#2f7a5a')[k % 3])


seagrass(58, 196, 4, r)
seagrass(206, 190, 5, r)
seagrass(292, 194, 3, r)
seagrass(124, 194, 3, r)
branch_coral(72, 188, CORAL, 20, 12)
brain_coral(96, 192, 10, LAVA)
sea_fan(118, 186, PURP, 22)
branch_coral(146, 194, LAVA, 16, 10)
brain_coral(212, 196, 8, CORAL)
sea_fan(232, 190, CORAL, 18)
branch_coral(262, 196, PURP, 18, 12)
branch_coral(184, 192, CORAL, 14, 8)
# anemone with clownfish
anx, any_ = 168, 192
m = blank()
for k in range(9):
    tx = anx - 8 + k * 2
    m |= line([(anx + (k - 4), any_), (tx + (k % 2) * 2 - 1, any_ - 9 - (k % 3) * 2)], 1)
cv.fill(m, '#f0b0c8')
cv.fill(m & ~shift(m, 1, 0), '#ffd8e4')
cv.fill(ell(anx - 4, any_ - 2, anx + 4, any_ + 3), PURP['b'])
fish(158, 178, LAVA, 4, 1, True, '#ffffff')
fish(176, 182, LAVA, 3, -1, True, '#ffffff')
# giant clam with a pearl
clx, cly = 286, 192
o = cv.obj()
o.part(ell(clx - 10, cly - 6, clx + 10, cly + 4), ramp('#c8c4d2', '#8a86a0', '#ece8f2'), d=2)
o.draw()
cv.fill(rect(clx - 9, cly - 1, clx + 9, cly), '#5e3a80')
cv.fill(rect(clx - 7, cly - 1, clx + 7, cly - 1), '#2fb0c8')   # blue mantle lips
cv.fill(rect(clx - 1, cly - 2, clx + 1, cly), '#ffffff')
for k in range(-8, 9, 4):
    cv.fill(line([(clx + k, cly - 5), (clx + k, cly - 2)]), '#8a86a0')
# starfish and urchins on the sand
for sx, sy, col in ((132, 196, CORAL['b']), (250, 186, LAVA['b']), (198, 197, YEL['b'])):
    for dx, dy in ((0, -3), (-3, -1), (3, -1), (-2, 2), (2, 2)):
        cv.fill(line([(sx, sy), (sx + dx, sy + dy)]), col)
    cv.dots([(sx, sy)], '#ffffff')
for ux, uy in ((84, 196), (224, 197), (276, 197)):
    cv.fill(ell(ux - 2, uy - 2, ux + 2, uy + 1), '#2a2440')
    for dx, dy in ((-4, -2), (-3, -4), (0, -5), (3, -4), (4, -2)):
        cv.dots([(ux + dx, uy + dy)], '#2a2440')

# ================================================================ swimmers: the Box Jelly Queen, the snorkeller, a turtle, fish
jx, jy = 84, 112
bell = rrect(jx - 7, jy - 6, jx + 7, jy + 6, 3)
for k, tx in enumerate((jx - 6, jx - 2, jx + 2, jx + 6)):   # long trailing tentacles
    pts = [(tx, jy + 6)] + [(tx + int(2 * math.sin(i * 0.8 + k)), jy + 6 + i * 5) for i in range(1, 9)]
    cv.fill(line(pts), '#f0b0c8' if k % 2 else '#d8c8f0')
o = cv.obj()
o.part(bell, JELLY, d=2)
o.draw()
cv.fill(rect(jx - 4, jy - 2, jx + 4, jy + 3) & bell, '#e8f2fc')
cv.fill(rect(jx - 5, jy + 4, jx + 5, jy + 5), '#b8a8e0')
cv.dots([(jx - 3, jy), (jx + 3, jy)], DARK)
cv.dots([(jx - 1, jy + 2), (jx, jy + 3), (jx + 1, jy + 2)], DARK)   # small smile
crown = poly([(jx - 4, jy - 7), (jx - 4, jy - 11), (jx - 2, jy - 9), (jx, jy - 12), (jx + 2, jy - 9), (jx + 4, jy - 11), (jx + 4, jy - 7)])
o = cv.obj()
o.part(crown, YEL, d=1)
o.draw()
cv.dots([(jx, jy - 9)], CORAL['b'])
# snorkelling gnome, swimming right, holding a spiral shell up
sgx, sgy = 128, 132
o = cv.obj()
o.part(line([(sgx - 18, sgy + 2), (sgx - 12, sgy)], 3), ramp('#5c3420', '#3d2a1c', '#7a4a1f'), d=0)   # kicking feet
o.part(rrect(sgx - 13, sgy - 4, sgx + 1, sgy + 4, 2), AQUA if False else YEL, d=2, contour=True)   # tunic (body horizontal)
o.part(poly([(sgx + 1, sgy - 3), (sgx + 7, sgy - 3), (sgx + 3, sgy + 6)]), BEARD, d=1, contour=True)
o.part(rect(sgx, sgy - 8, sgx + 7, sgy - 2), SKIN, d=1)
o.part(poly([(sgx - 1, sgy - 6), (sgx + 3, sgy - 10), (sgx - 14, sgy - 14)]), RED, d=2, contour=True)   # hat streaming back
o.part(line([(sgx + 4, sgy - 1), (sgx + 10, sgy - 6)], 2), YEL, d=0)   # reaching arm
o.draw()
cv.fill(rect(sgx + 2, sgy - 6, sgx + 7, sgy - 5), '#2a6a8a')   # goggles
cv.dots([(sgx + 3, sgy - 6), (sgx + 6, sgy - 6)], '#bff0ea')
cv.fill(rect(sgx + 1, sgy - 12, sgx + 1, sgy - 6), '#2a6a8a')   # snorkel tube
sh = ell(sgx + 9, sgy - 12, sgx + 15, sgy - 6)
o = cv.obj()
o.part(sh, SHELL, d=1)
o.draw()
cv.dots([(sgx + 12, sgy - 9), (sgx + 13, sgy - 10), (sgx + 11, sgy - 10), (sgx + 11, sgy - 8)], SHELL['s'])
bubbles(sgx + 1, sgy - 15, 6, r2)
bubbles(84, 96 + 30, 3, r2)
bubbles(34, 124, 5, r2)
bubbles(280, 136, 5, r2)
bubbles(196, 170, 6, r2)
# sea turtle gliding left
tx, ty = 236, 118
o = cv.obj()
o.part(poly([(tx - 4, ty + 2), (tx - 14, ty + 8), (tx - 6, ty + 6)]) | poly([(tx + 6, ty + 3), (tx + 12, ty + 9), (tx + 9, ty + 3)]), TURT, d=1)   # flippers
o.part(ell(tx - 18, ty - 3, tx - 10, ty + 3), TURT, d=1)   # head
o.part(ell(tx - 10, ty - 7, tx + 10, ty + 5), SHELL, d=2)  # shell
o.draw()
for k in (-6, 0, 6):
    cv.fill(rect(tx + k - 2, ty - 4, tx + k + 2, ty), SHELL['s'])
    cv.dots([(tx + k - 1, ty - 4)], SHELL['r'])
cv.dots([(tx - 15, ty - 1)], DARK)
# fish: a school of small yellow fish (no outline), and a few bigger ones
for k in range(11):
    fx, fy = 150 + (k % 4) * 9 + (k // 4) * 4, 104 + (k // 4) * 6 + (k % 2) * 2
    fish(fx, fy, YEL, 2, 1, False)
for fx, fy, rp, s, face, st in ((60, 166, TEAL, 5, 1, '#ffffff'), (232, 150, PURP, 5, -1, YEL['b']), (104, 152, CORAL, 4, -1, None), (256, 104, AQUA, 4, -1, '#1f6080'), (180, 146, YEL, 4, 1, '#2a2440'), (214, 132, LAVA, 3, -1, None), (40, 98 + 72, CORAL, 3, 1, None), (150, 120, TEAL, 3, -1, None)):
    fish(fx, fy, rp, s, face, True, st)
fish(fgx + 22, 132, ramp('#c8c4d2', '#8a86a0', '#ece8f2'), 3, -1, True)   # a fish eyeing the hook
# a moorish idol with its long streamer
mix, miy = 108, 112
o = cv.obj()
o.part(poly([(mix - 5, miy), (mix, miy - 6), (mix + 5, miy), (mix, miy + 5)]), YEL, d=1)
o.draw()
cv.fill(rect(mix - 1, miy - 5, mix, miy + 4), DARK)
cv.fill(line([(mix, miy - 6), (mix - 4, miy - 10), (mix - 9, miy - 11)]), '#f2e4c0')
cv.dots([(mix + 3, miy - 1)], DARK)

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else None
    n = save_pic(cv, 'coralscatter', out)
    print('coralscatter:', n, 'colours')
