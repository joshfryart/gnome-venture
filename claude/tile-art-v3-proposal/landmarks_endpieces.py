"""END pieces: the set piece that stands at the last section of a route outside the Maplewold, announcing the haven / wonder / delve / lair ahead
(slugs `end-<kind>-<n>-<land>` in claude/trail-landmarks/setpieces.json). Eight drawings x nine land palettes = 44 slugs.
Look: gen2.py (hard pixels, 5-tone ramps, lump shading, auto outline, painterly pass). Canvas 200 x 190, centred, the bottom edge is the feet line.
  haven-1  warm cottage with smoke, lit window and a lantern     haven-2  signpost with a 'Rest' bed sign, a bench and a lantern post
  wonder-1 two gate pillars with an arch and a glowing orb        wonder-2 a hush ring: three standing stones round a floating glow
  delve-1  timbered mine mouth with a cart and pick              delve-2  a lantern line leading to a dark hole
  lair-1   a cave mound with two eyes, big footprints            lair-2   a scuffed nest ring round a dent, with feather and Zzz"""
import json, os, math, random
import gen2
from gen2 import RAMP, INK, CREAM, lump, r5, _col
from PIL import Image, ImageDraw

W_, H_ = 200, 190
FY = H_ - 10   # feet line

# land -> (ground, rock, timber, accent, glow)
PAL = {
    "grassland": ("moss", "stone", "wood", "gold", "gold"),
    "forest": ("leaf", "stone", "wood", "gold", "gold"),
    "coast": ("sand", "stone", "wood", "sea", "gold"),
    "tundra": ("snow", "ice", "wood", "ice", "sea"),
    "desert": ("sand", "litter", "wood", "ember", "gold"),
    "mountain": ("stone", "stone", "wood", "gold", "gold"),
    "wetland": ("pine", "stone", "wood", "moss", "sea"),
    "rainforest": ("pine", "stone", "wood", "petal", "gold"),
    "island": ("sand", "stone", "wood", "petal", "sea"),
}

def fm(cv, drawfn, fn):
    m = Image.new("L", cv.im.size, 0); drawfn(ImageDraw.Draw(m)); bb = m.getbbox()
    if not bb: return
    mp = m.load()
    for y in range(bb[1], bb[3]):
        for x in range(bb[0], bb[2]):
            if mp[x, y]: cv.put(x, y, fn(x, y))
def poly(cv, pts, c): fm(cv, lambda d: d.polygon(pts, fill=255), lambda x, y: c)
def ell(cv, cx, cy, rx, ry, c): fm(cv, lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255), lambda x, y: c)
def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)
def line(cv, x0, y0, x1, y1, c, w=1):
    n = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for dx in range(w):
            for dy in range(w): cv.put(int(round(x)) + dx - w // 2, int(round(y)) + dy - w // 2, c)
def col(cv, x0, x1, y0, y1, R, rnd, speck=.05): _col(cv, x0, x1, y0, y1, R, rnd, speck)
def planks(cv, x0, x1, y0, y1, R, rnd, pw=8):
    for x in range(x0, x1):
        u = (x - x0) / max(1, x1 - x0 - 1); t = 0 if u < .15 else 1 if u < .4 else 2 if u < .72 else 3
        for y in range(y0, y1):
            c = R[3] if (x - x0) % pw == 0 else R[t]
            if (x * 7 + y * 3) % 23 == 0: c = R[min(4, t + 1)]
            cv.put(x, y, c)
def sparkle(cv, x, y, c=CREAM, big=False):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, c)
    if big:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + dx, y + dy, c)
def glow(cv, cx, cy, r, G):
    ell(cv, cx, cy, r, r, G[1]); ell(cv, cx, cy, r - 2, r - 2, G[0]); ell(cv, cx - 1, cy - 1, max(1, r - 5), max(1, r - 5), CREAM)
def lantern(cv, x, y, T, G):
    rect(cv, x - 1, y - 4, x + 2, y - 3, T[3]); rect(cv, x - 3, y - 2, x + 4, y + 7, T[3])
    rect(cv, x - 2, y - 1, x + 3, y + 6, G[1]); rect(cv, x - 1, y, x + 2, y + 4, G[0]); cv.put(x, y + 1, CREAM)
    rect(cv, x - 3, y + 7, x + 4, y + 8, T[3])
def post(cv, x, y0, y1, w, T, rnd):
    col(cv, x - w // 2, x + w // 2 + 1, y0, y1, T, rnd, .04)
def ground_patch(cv, cx, cy, rx, ry, g, rnd):
    lump(cv, cx, cy, rx, ry, g, rnd, .10)
def grass_tufts(cv, rnd, g, n, x0=10, x1=190):
    for _ in range(n):
        x = rnd.randint(x0, x1); y = FY - rnd.randint(0, 6)
        for k in range(rnd.randint(3, 6)): cv.put(x + k // 3, y - k, g[1 + (k % 2)])
        for k in range(rnd.randint(2, 4)): cv.put(x - 2 - k // 3, y - k, g[2])
def smoke(cv, x, y, n, S):
    for k in range(n):
        ell(cv, x + int(5 * math.sin(k * 1.3)) + k, y - k * 9, 5 + k, 4 + k // 2, S[0 if k % 2 else 1])

# ---------------------------------------------------------------- the eight drawings
def d_haven1(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 90, 14, g, rnd)
    # cottage
    col(cv, 52, 148, 92, FY - 4, r5(RAMP["sand"]) if P[0] not in ("sand",) else r5(RAMP["snow"]), rnd, .06)
    rect(cv, 52, FY - 12, 148, FY - 4, r[2])   # stone footing
    for x in range(54, 148, 12): cv.put(x, FY - 8, r[3]); cv.put(x + 6, FY - 11, r[3])
    poly(cv, [(40, 94), (100, 38), (160, 94)], t[2]); poly(cv, [(46, 92), (100, 44), (154, 92)], t[1])
    for i in range(7):   # tile rows
        y = 54 + i * 7; line(cv, 100 - (y - 44) * 0 - int((y - 44) * 1.08), y, 100 + int((y - 44) * 1.08), y, t[3])
    line(cv, 100, 44, 154, 92, t[0], 2)
    col(cv, 124, 136, 44, 68, r, rnd, .04); rect(cv, 122, 42, 138, 46, r[1])           # chimney
    smoke(cv, 130, 38, 5, r5(RAMP["snow"]))
    col(cv, 88, 112, 116, FY - 4, t, rnd, .04); rect(cv, 88, 116, 112, 118, t[0]); cv.put(107, 130, gl[1]); cv.put(107, 131, gl[0])   # door
    ell(cv, 100, 116, 12, 4, t[1]); rect(cv, 88, 116, 112, 122, t[1]); col(cv, 90, 110, 118, FY - 4, t, rnd, .04)
    rect(cv, 64, 108, 82, 124, t[3]); rect(cv, 66, 110, 80, 122, gl[1]); rect(cv, 67, 111, 79, 121, gl[0]); line(cv, 73, 110, 73, 122, t[3]); line(cv, 66, 116, 80, 116, t[3])  # lit window
    rect(cv, 62, 124, 84, 127, t[2])
    for x in (66, 72, 78): cv.put(x, 121, P and RAMP["petal"][1]); cv.put(x, 122, RAMP["moss"][1])
    post(cv, 170, FY - 60, FY - 4, 4, t, rnd); lantern(cv, 170, FY - 66, t, gl)   # lantern post
    for x in range(10, 40, 7): rect(cv, x, FY - 24, x + 3, FY - 4, t[1 + (x // 7) % 2])   # a few fence pickets
    rect(cv, 8, FY - 20, 42, FY - 17, t[0])
    grass_tufts(cv, rnd, g, 14)
def d_haven2(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 90, 14, g, rnd)
    post(cv, 96, 50, FY - 4, 8, t, rnd)                                              # sign post
    poly(cv, [(46, 56), (146, 56), (160, 74), (146, 92), (46, 92)], t[2]); poly(cv, [(48, 58), (144, 58), (156, 74), (144, 90), (48, 90)], t[1])
    planks(cv, 50, 144, 60, 88, t, rnd, 12)
    # bed icon painted on the board: pillow, blanket, legs
    rect(cv, 62, 68, 76, 80, CREAM); rect(cv, 62, 68, 76, 70, r[0])
    rect(cv, 76, 70, 126, 80, RAMP["petal"][1] if P[3] != "petal" else RAMP["sea"][1]); rect(cv, 76, 70, 126, 72, RAMP["petal"][0] if P[3] != "petal" else RAMP["sea"][0])
    rect(cv, 60, 80, 64, 86, t[3]); rect(cv, 124, 80, 128, 86, t[3]); rect(cv, 60, 78, 128, 80, t[3])
    for k, (zx, zy) in enumerate(((132, 66), (138, 58), (146, 52))):    # little z's
        s = 3 + k; line(cv, zx, zy, zx + s, zy, INK); line(cv, zx + s, zy, zx, zy + s, INK); line(cv, zx, zy + s, zx + s, zy + s, INK)
    lump(cv, 96, 50, 7, 5, t, rnd, 0)
    # bench
    planks(cv, 130, 190, FY - 34, FY - 26, t, rnd, 10); rect(cv, 132, FY - 26, 136, FY - 4, t[2]); rect(cv, 184, FY - 26, 188, FY - 4, t[3])
    rect(cv, 130, FY - 44, 190, FY - 40, t[1]); rect(cv, 130, FY - 44, 190, FY - 43, t[0])
    # lantern on a short post, left
    post(cv, 24, FY - 50, FY - 4, 4, t, rnd); lantern(cv, 24, FY - 56, t, gl)
    grass_tufts(cv, rnd, g, 14)
def d_wonder1(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 92, 14, g, rnd)
    for sx in (-1, 1):   # pillars
        px = 100 + sx * 54
        col(cv, px - 14, px + 14, 52, FY - 8, r, rnd, .08)
        for y in range(60, FY - 12, 14): line(cv, px - 14, y, px + 14, y, r[3] if sx > 0 else r[2])
        rect(cv, px - 18, 44, px + 18, 54, r[1]); rect(cv, px - 18, 44, px + 18, 46, r[0]); rect(cv, px - 18, 52, px + 18, 54, r[3])
        rect(cv, px - 18, FY - 12, px + 18, FY - 6, r[2]); rect(cv, px - 18, FY - 6, px + 18, FY - 4, r[4])
        glow(cv, px, 36, 6, gl)
        for k in range(3): cv.put(px - 4 + k * 4, 80 + k * 14, a[1]); cv.put(px - 4 + k * 4, 81 + k * 14, a[0])   # glyphs
    # arch between
    for x in range(48, 153):
        u = (x - 100) / 52.0; yy = 48 - int(18 * math.sqrt(max(0, 1 - u * u)))
        for y in range(yy, yy + 9): cv.put(x, y, r[0 if y == yy else 1 if y < yy + 5 else 2 if x > 100 else 3 if y > yy + 6 else 2])
    glow(cv, 100, 24, 9, gl); sparkle(cv, 100, 24, CREAM, True)
    ell(cv, 100, FY - 10, 34, 7, gl[1]); ell(cv, 100, FY - 10, 24, 5, gl[0]); ell(cv, 100, FY - 11, 12, 3, CREAM)   # pool of light under the arch
    for (sx, sy) in ((78, 66), (126, 74), (88, 100), (116, 96), (100, 52)): sparkle(cv, sx, sy, CREAM)
    grass_tufts(cv, rnd, g, 12)
def d_wonder2(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 10, 92, 18, g, rnd)
    lump(cv, 100, FY - 10, 66, 11, r5(RAMP["litter"]) if P[0] != "snow" else r5(RAMP["ice"]), rnd, .08)
    for (cx, wd, hh, sh) in ((44, 15, 78, -2), (156, 15, 70, 2), (100, 17, 86, 0)):
        top = FY - 14 - hh
        pts = [(cx - wd, FY - 10), (cx - wd + 3 + sh, top + 12), (cx + sh, top), (cx + wd - 3 + sh, top + 10), (cx + wd, FY - 10)]
        fm(cv, lambda d, pts=pts: d.polygon(pts, fill=255), lambda x, y, cx=cx, wd=wd: r[0 if x < cx - wd * .5 else 1 if x < cx else 2 if x < cx + wd * .5 else 3] if (x * 3 + y) % 11 else r[4])
        line(cv, cx - 1, top + 18, cx + 3, top + 30, r[4]); line(cv, cx + 3, top + 30, cx - 2, top + 44, r[4])
        for k in range(3): cv.put(cx - 5 + k * 4, top + 10 + k * 2, a[1])
        ell(cv, cx, FY - 10, wd + 2, 3, g[2])
    glow(cv, 100, 62, 14, gl)    # the hush: a floating orb over the circle
    for k in range(10):
        ang = k * 0.65; sparkle(cv, 100 + int(34 * math.cos(ang)), 62 + int(20 * math.sin(ang)) - k * 2, CREAM if k % 2 else gl[0])
    for k in range(3): line(cv, 92 + k * 8, 78, 92 + k * 8 + (k - 1) * 3, 98 + k * 3, gl[1])
    grass_tufts(cv, rnd, g, 10)
def d_delve1(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 92, 14, g, rnd)
    lump(cv, 100, 96, 80, 64, r, rnd, .10)                                       # rock face
    rect(cv, 12, FY - 22, 188, FY - 4, g[2]); lump(cv, 100, FY - 8, 92, 12, g, rnd, .1)
    ell(cv, 100, 112, 34, 40, INK); rect(cv, 66, 112, 134, FY - 8, INK)          # the dark mouth
    for y in range(72, FY - 8): cv.put(66, y, r[4]) if y > 112 else None
    ell(cv, 100, 112, 28, 34, (28, 18, 36, 255)); rect(cv, 72, 112, 128, FY - 8, (28, 18, 36, 255))
    for k in range(6): cv.put(86 + k * 5, FY - 10 - k % 2, gl[1]) if k in (1, 4) else None
    post(cv, 64, 74, FY - 6, 8, t, rnd); post(cv, 136, 74, FY - 6, 8, t, rnd)    # timber frame
    rect(cv, 56, 66, 144, 76, t[1]); rect(cv, 56, 66, 144, 68, t[0]); rect(cv, 56, 74, 144, 76, t[3])
    line(cv, 68, 76, 84, 66, t[2], 3); line(cv, 132, 76, 116, 66, t[2], 3)
    lantern(cv, 100, 76, t, gl)
    # cart on a short rail + pick
    rect(cv, 148, FY - 8, 196, FY - 6, r[3]); rect(cv, 150, FY - 4, 196, FY - 3, r[3])
    col(cv, 152, 186, FY - 34, FY - 12, t, rnd, .04); rect(cv, 150, FY - 36, 188, FY - 32, t[1]); rect(cv, 150, FY - 36, 188, FY - 35, t[0])
    for cx in (160, 178): ell(cv, cx, FY - 8, 5, 5, r[3]); ell(cv, cx, FY - 8, 2, 2, r[1])
    for k in range(4): lump(cv, 160 + k * 6, FY - 40 - (k % 2) * 3, 5, 4, a, rnd, 0)   # ore heap
    line(cv, 26, FY - 4, 40, FY - 36, t[1], 3); line(cv, 32, FY - 40, 54, FY - 34, r[1], 3); line(cv, 54, FY - 34, 56, FY - 30, r[1], 2)   # pick
    grass_tufts(cv, rnd, g, 8)
def d_delve2(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 92, 14, g, rnd)
    # a track that narrows away, lanterns on posts getting smaller, ending at a dark hole in a hump
    lump(cv, 100, 74, 40, 34, r, rnd, .10); ell(cv, 100, 84, 22, 24, INK); ell(cv, 100, 86, 17, 19, (28, 18, 36, 255)); rect(cv, 83, 86, 117, 100, (28, 18, 36, 255))
    poly(cv, [(84, 100), (116, 100), (150, FY - 6), (50, FY - 6)], r5(RAMP["litter"])[2])
    for y in range(100, FY - 6):
        u = (y - 100) / float(FY - 106); xl = int(84 - 34 * u); xr = int(116 + 34 * u)
        cv.put(xl, y, r5(RAMP["litter"])[1]); cv.put(xr, y, r5(RAMP["litter"])[3])
    rungs = [(62, FY - 14, 5), (136, FY - 34, 4), (68, FY - 58, 3), (130, FY - 76, 3)]
    for i, (x, y, w) in enumerate(((46, FY - 10, 5), (154, FY - 10, 5), (68, FY - 46, 4), (132, FY - 46, 4), (80, FY - 74, 3), (120, FY - 74, 3))):
        ph = 52 - i * 7 if i < 2 else 34 if i < 4 else 24
        post(cv, x, y - ph, y, w, t, rnd); lantern(cv, x, y - ph - 6, t, gl)
        for k in range(1, 4): cv.put(x - 1 + k % 2, y - ph - 6 + k, gl[1 + k % 2]) if False else None
    for x, y in ((28, FY - 20), (172, FY - 16)): lump(cv, x, y, 9, 6, r, rnd, .1)
    for k in range(5): sparkle(cv, 70 + k * 16, 70 + (k % 2) * 6, gl[0])
    grass_tufts(cv, rnd, g, 8)
def d_lair1(cv, rnd, P):
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    ground_patch(cv, 100, FY - 6, 92, 14, g, rnd)
    lump(cv, 100, 88, 78, 62, r, rnd, .10)
    ell(cv, 100, 118, 36, 40, INK); rect(cv, 64, 118, 136, FY - 8, INK)
    ell(cv, 100, 118, 30, 34, (24, 14, 30, 255)); rect(cv, 70, 118, 130, FY - 8, (24, 14, 30, 255))
    for ex in (88, 114):   # two eyes in the dark, a bit sleepy
        rect(cv, ex - 5, 112, ex + 5, 120, gl[1]); rect(cv, ex - 3, 113, ex + 3, 119, gl[0]); rect(cv, ex - 1, 113, ex + 1, 119, INK); rect(cv, ex - 5, 112, ex + 5, 114, (24, 14, 30, 255))
    for k in range(3): lump(cv, 52 + k * 5, 120 - k * 14, 6, 5, r, rnd, 0)       # big claw scratches on the rock
    for i in range(3): line(cv, 140 + i * 6, 62, 146 + i * 6, 96, r[4], 2); line(cv, 140 + i * 6, 62, 141 + i * 6, 62, r[0])
    for (fx, fy, s) in ((34, FY - 16, 1), (148, FY - 12, 1), (84, FY - 6, 1)):    # huge footprints on the way in
        ell(cv, fx, fy, 14, 6, g[3]); ell(cv, fx, fy - 1, 12, 4, g[4])
        for k in range(4): ell(cv, fx - 12 + k * 8, fy - 9, 3, 3, g[3]); ell(cv, fx - 12 + k * 8, fy - 9, 2, 2, g[4])
    for (bx, by) in ((20, FY - 6), (176, FY - 8)): lump(cv, bx, by, 10, 7, r, rnd, .1)
    grass_tufts(cv, rnd, g, 6, 10, 60)
def d_lair2(cv, rnd, P):
    """2.7 fix (was a flat ring): a raised nest bank with a real bowl in it (lit far wall, shaded near wall, deep middle), a woven twig rim,
    boulders sorted back to front and getting smaller toward the viewer, a cast shadow, feathers on the rim and the Zzz from the sleeper."""
    g, r, t, a, gl = [r5(RAMP[n]) for n in P]
    if P[1] == "litter": r = r5(RAMP["stone"])                                  # desert: grey stones on the litter bank
    L = r5(RAMP["litter"]); S = r5(RAMP["sand"]); Wd = r5(RAMP["wood"])
    CX, CY = 100, FY - 22                                                        # centre of the nest bowl
    ground_patch(cv, 100, FY - 8, 94, 16, g, rnd)
    for y in range(FY - 14, FY + 1):                                             # soft cast shadow to the lower right
        for x in range(30, 196):
            if ((x - 112) / 84.0) ** 2 + ((y - (FY - 6)) / 9.0) ** 2 <= 1 and (x + y) % 2 == 0 and cv.get(x, y)[3]: cv.put(x, y, g[4])
    # the bank: a low earth mound, lit up-left
    for y in range(CY - 30, FY):
        for x in range(CX - 92, CX + 93):
            nx = (x + .5 - CX) / 90.0; ny = (y + .5 - (CY + 2)) / 30.0
            if nx * nx + ny * ny > 1: continue
            cv.put(x, y, L[gen2.tone5(gen2.shade_pt(nx * .85, ny * .85))])
    # the bowl: concave, so the light falls on the far (lower-right) inner wall and the near-left wall is in shade
    for y in range(CY - 20, CY + 21):
        for x in range(CX - 66, CX + 67):
            nx = (x + .5 - CX) / 64.0; ny = (y + .5 - CY) / 18.0; d = nx * nx + ny * ny
            if d > 1: continue
            v = gen2.shade_pt(-nx * .9, -ny * .9) - (1 - d) * .55                 # inverted normal + deeper in the middle
            ti = gen2.tone5(v)
            if d < .36: ti = 4 if d < .2 else max(3, ti)
            if ny < -.55 and d > .7: ti = 4                                     # the far lip throws a dark band inside
            c = L[ti]
            if .7 < d and ti <= 2 and (x * 3 + y) % 5 == 0: c = S[2]            # a few lit straw ends on the sunny wall
            cv.put(x, y, c)
    for k in range(34):   # straw and down scuffed into the bowl
        ang = rnd.random() * 6.283; rr = .35 + rnd.random() * .5
        x = CX + int(60 * rr * math.cos(ang)); y = CY + int(16 * rr * math.sin(ang))
        line(cv, x, y, x + rnd.randint(-6, 6), y + rnd.randint(-1, 1), S[1 + k % 3] if k % 4 else CREAM)
    # woven rim: short twigs laid along the lip, alternating light and dark so it reads as weaving
    for k in range(96):
        ang = k * 6.283 / 96; rx_, ry_ = 65 + (k % 3), 18 + (k % 2)
        x = CX + rx_ * math.cos(ang); y = CY + ry_ * math.sin(ang); dx, dy = -math.sin(ang) * 6, math.cos(ang) * 2
        lit = math.sin(ang) > -.2                                               # the near lip faces the light, the far lip is in shade
        line(cv, int(x - dx), int(y - dy), int(x + dx), int(y + dy), Wd[3 if not lit else 1] if k % 2 else Wd[4 if not lit else 2], 2)
        if k % 2 == 0 and lit: cv.put(int(x - dx), int(y - dy) - 1, Wd[0])
    # stones round the bank, painted back to front; the back ones are bigger and stacked like a headboard
    st = []
    for k in range(16):
        ang = (k + .5) * (2 * math.pi / 16); x = CX + int(84 * math.cos(ang)); y = CY + int(26 * math.sin(ang))
        depth = (math.sin(ang) + 1) / 2                                          # 0 back .. 1 front
        sz = 1.25 - .35 * depth
        st.append((y, x, int((9 + (k % 3) * 2) * sz), int((7 + (k % 2) * 2) * sz), math.sin(ang) < -.35))
    for (y, x, rx, ry, back) in sorted(st):
        if back: lump(cv, x, y - ry - 2, rx + 2, int(ry * 1.7), r, rnd, .08)       # the back row: tall boulders, like a headboard
        else: lump(cv, x, y - ry // 2, rx, ry, r, rnd, .08)
        for k in range(rx):   # contact shadow where the stone sits on the bank
            if cv.get(x - rx // 2 + k, y + ry // 2 + 1)[3]: cv.put(x - rx // 2 + k, y + ry // 2 + 1, L[4])
    # feathers lying on the rim: shaft and vanes, in the accent / glow colour
    for (fx, fy, s, dirn) in ((50, CY + 16, 20, 1), (134, CY + 14, 16, -1)):
        for k in range(s):
            x = fx + k; y = fy - int(k * .45 * dirn)
            for w in range(1, 4 - k // 6 if k < s - 2 else 2): cv.put(x, y - w, gl[0] if w == 1 else gl[1]); cv.put(x, y + w, gl[2] if w == 1 else gl[3])
            cv.put(x, y, CREAM)
    # the sleeper: a dark furry curl deep in the bowl (body, head tucked in on the left with two ears, tail wrapped round the front, one closed eye)
    D = r5(RAMP["dusk"])
    def furlump(cx, cy, rx, ry):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
                if nx * nx + ny * ny > 1: continue
                ti = min(4, gen2.tone5(gen2.shade_pt(nx, ny)) + 2) if gen2.shade_pt(nx, ny) < .5 else 1   # mostly in shadow down in the bowl
                if (x * 5 + y * 3) % 7 == 0 and ti > 1: ti -= 1                 # fur ticks
                if nx * nx + ny * ny > .8 and nx + ny > .2: ti = 4                # dark under-rim so the parts separate
                cv.put(x, y, D[min(4, ti)])
    furlump(CX + 6, CY - 2, 25, 10)                                              # body
    for (ex, sgn) in ((CX - 24, 1), (CX - 14, 1)):
        for k in range(5):
            for w in range(5 - k): cv.put(ex - (5 - k) // 2 + w, CY - 10 - k, D[1] if w == 0 else D[2] if w < 3 else D[3])
    furlump(CX - 19, CY - 3, 10, 8)                                              # head, tucked in
    for k in range(90):   # tail curling round the front of the body, lit on top
        ang = math.pi * (.08 + k / 90.0 * .9); x = CX + 6 + int(round(27 * math.cos(ang))); y = CY + 1 + int(round(9 * math.sin(ang)))
        tw = 3 if k < 70 else 2
        for w in range(tw): cv.put(x, y + w - 1, D[1] if w == 0 else D[2] if w < tw - 1 else D[4])
    for (x, y) in ((CX - 25, CY - 3), (CX - 24, CY - 2), (CX - 23, CY - 2), (CX - 22, CY - 2), (CX - 21, CY - 3)): cv.put(x, y, INK)   # closed eye
    cv.put(CX - 28, CY - 1, D[4]); cv.put(CX - 29, CY - 1, INK)                  # nose tip
    # claw scrapes in the earth out front
    for i in range(3): line(cv, 22 + i * 6, FY - 14, 30 + i * 6, FY - 4, g[4], 2); line(cv, 21 + i * 6, FY - 14, 28 + i * 6, FY - 5, g[0])
    for k, (zx, zy) in enumerate(((106, 91), (118, 79), (132, 65))):               # big Zzz rising from the sleeper in the bowl
        s_ = 5 + k * 3
        for (dx, c) in ((1, INK), (0, CREAM)):
            line(cv, zx + dx, zy + dx, zx + s_ + dx, zy + dx, c, 2); line(cv, zx + s_ + dx, zy + dx, zx + dx, zy + s_ + dx, c, 2); line(cv, zx + dx, zy + s_ + dx, zx + s_ + dx, zy + s_ + dx, c, 2)
    grass_tufts(cv, rnd, g, 8)

DRAW = {"haven-1": d_haven1, "haven-2": d_haven2, "wonder-1": d_wonder1, "wonder-2": d_wonder2, "delve-1": d_delve1, "delve-2": d_delve2, "lair-1": d_lair1, "lair-2": d_lair2}

def _mk(kind, land):
    P = PAL[land]
    def fn(rnd, cv): DRAW[kind](cv, rnd, P)
    return (W_, H_, fn)

_CAT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "trail-landmarks", "setpieces.json")
LM = {}
try:
    for slug in json.load(open(_CAT, encoding="utf-8")):
        if not slug.startswith("end-"): continue
        _, kind, n, land = slug.split("-", 3)
        LM[slug] = _mk(kind + "-" + n, land)
except OSError:
    pass
