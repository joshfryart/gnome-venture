import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
from PIL import Image, ImageDraw

SN, IC, ST, WD, GD, EM, PT, PI, SE, MO, DU = (r5(RAMP[k]) for k in ("snow", "ice", "stone", "wood", "gold", "ember", "petal", "pine", "sea", "moss", "dusk"))
COAL = H("#35295f")
CARROT = [mix(RAMP["gold"][1], RAMP["ember"][0], .45), mix(RAMP["gold"][2], RAMP["ember"][0], .3), RAMP["gold"][2]]


def _mask(w, h, pts):
    im = Image.new("L", (w, h), 0); ImageDraw.Draw(im).polygon(pts, fill=255); return im.load()


def slab(cv, pts, R, rnd, sx=.6, sy=.4, speck=.07):
    """Flat-ish polygon shaded top-left light, with lit top edge and dark underside."""
    m = _mask(cv.w, cv.h, pts)
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]; x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    bw, bh = max(1, x1 - x0), max(1, y1 - y0)
    for y in range(max(0, y0), min(cv.h, y1 + 1)):
        for x in range(max(0, x0), min(cv.w, x1 + 1)):
            if not m[x, y]: continue
            u = sx * (x - x0) / bw + sy * (y - y0) / bh
            t = 0 if u < .10 else 1 if u < .32 else 2 if u < .56 else 3 if u < .8 else 4
            if rnd.random() < speck: t = max(0, min(4, t + rnd.choice((-1, 1))))
            if y > 0 and not m[x, y - 1]: t = 0
            elif y + 1 < cv.h and not m[x, y + 1]: t = max(t, 3)
            cv.put(x, y, R[t])


def poly(cv, pts, c):
    ImageDraw.Draw(cv.im).polygon(pts, fill=c)


def line(cv, pts, c, w=1):
    d = ImageDraw.Draw(cv.im)
    d.line(pts, fill=c, width=w)


def icicle(cv, x, y, ln, w, R=None):
    R = R or IC
    for i in range(ln):
        hw = max(0, int(round(w / 2 * (1 - i / ln) ** .8)))
        for k in range(-hw, hw + 1):
            t = 0 if k < -hw * .3 else 1 if k < hw * .4 else 2
            if i > ln - 4: t = 0
            cv.put(x + k, y + i, R[t])
        if hw == 0 and i < ln - 1: cv.put(x, y + i, R[1])
    cv.put(x, y + ln, R[0])


def carrot(cv, x, y, d, ln, w, up=0):
    for i in range(ln):
        hw = max(0, int(round(w * (1 - i / ln))))
        yy = y - int(up * (i / ln) ** 2)
        for k in range(-hw, hw + 1):
            cv.put(x + d * i, yy + k, CARROT[0] if k < 0 else CARROT[1] if k == 0 or hw < 2 else CARROT[2])
    cv.put(x + d * (ln - 1), y - int(up), CARROT[2])


def eye(cv, x, y, s=3):
    for dx in range(s):
        for dy in range(s): cv.put(x + dx, y + dy, COAL)
    cv.put(x, y, CREAM) if s > 2 else None


def ground_snow(cv, cx, cy, rx, ry, rnd, speck=.1):
    lump(cv, cx, cy, rx, ry, SN, rnd, speck)


def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)


def ellfill(cv, cx, cy, rx, ry, fn):
    """Fill an ellipse; fn(x, y, nx, ny) returns a colour (or None to skip)."""
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny <= 1:
                c = fn(x, y, nx, ny)
                if c: cv.put(x, y, c)


def post(cv, x, y0, y1, w, R):
    for xx in range(x, x + w):
        u = (xx - x) / max(1, w - 1); t = 0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3
        for y in range(y0, y1): cv.put(xx, y, R[t])


def star5(cv, cx, cy, r, c):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5; rr = r if i % 2 == 0 else r * .42
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    poly(cv, pts, c)


def curve(cv, pts_fn, n, c, hi=None, every=5):
    for i in range(n):
        x, y = pts_fn(i / (n - 1)); cv.put(int(x), int(y), c)
        if hi and i % every == 0: cv.put(int(x), int(y) - 1, hi)


# ------------------------------------------------------------------ 309
def lm_frozenpond(rnd, cv):   # 330 x 170
    cx, cy, rx, ry = 165, 104, 146, 48
    TH = 11
    # front thickness of the ice shelf, then the packed-snow rim on top of it
    ellfill(cv, cx, cy + TH, rx + 9, ry + 7, lambda x, y, nx, ny: SN[3] if ny + nx * .2 > -.1 else None)
    ellfill(cv, cx, cy + TH - 1, rx + 9, ry + 7, lambda x, y, nx, ny: IC[2] if ny > .55 else None)
    def rim(x, y, nx, ny):
        u = ny * .6 + nx * .4
        return SN[0 if u < -.5 else 1 if u < -.1 else 2]
    ellfill(cv, cx, cy, rx + 9, ry + 7, rim)
    # the polished plate
    def ice(x, y, nx, ny):
        u = ny * .5 + nx * .35; t = 0 if u < -.38 else 1 if u < -.02 else 2 if u < .4 else 3
        if (x + y * 2) % 17 == 0: t = max(0, t - 1)
        band = (x * 3 + y * 5) % 97   # two long polished glare bands
        if band < 7 and abs(nx) < .88: t = 0
        return IC[t]
    ellfill(cv, cx, cy, rx, ry, ice)
    for k in range(9):   # glossy streaks
        x, y = rnd.randint(cx - 110, cx + 70), rnd.randint(cy - 26, cy + 24)
        for j in range(rnd.randint(8, 18)): cv.put(x + j, y - j // 3, CREAM); cv.put(x + j + 1, y - j // 3 + 1, IC[0])
    # cracks that catch the light
    for x0, y0, dx in ((60, 82, 1), (214, 76, 1), (132, 118, 1)):
        x, y = x0, y0
        for k in range(34):
            cv.put(x, y, IC[3]); cv.put(x, y - 1, CREAM) if k % 3 == 0 else cv.put(x + 1, y - 1, IC[0])
            x += 1 if k % 3 else 0; y += rnd.choice((-1, 0, 1)) if k % 2 else 0
            if k in (12, 22):   # a fork
                fx, fy = x, y
                for j in range(9): cv.put(fx + j, fy + j // 2, IC[3]); cv.put(fx + j, fy + j // 2 - 1, IC[0]) if j % 3 == 0 else None
    # the skating gnome's loop: a figure of eight traced in blade scratches
    for off, col in ((0, SN[3] if False else IC[3]), (2, IC[0])):
        curve(cv, lambda t: (cx - 52 + 66 * math.sin(t * 2 * math.pi) * (1 if True else 0) + 0, cy + 4 + off + 15 * math.sin(t * 4 * math.pi + .6)), 420, col)
    for i in range(0, 420, 28):   # footprint-ish tick marks along the loop
        t = i / 419; x = cx - 52 + 66 * math.sin(t * 2 * math.pi); y = cy + 4 + 15 * math.sin(t * 4 * math.pi + .6)
        cv.put(int(x), int(y) + 4, SN[2]); cv.put(int(x) + 1, int(y) + 4, SN[2])
    # the fishing hole with a stool, a rod and a very patient bucket
    hx, hy = cx + 70, cy + 8
    ellfill(cv, hx, hy, 17, 8, lambda x, y, nx, ny: SN[1] if ny < 0 else SN[2])
    ellfill(cv, hx, hy + 1, 12, 5, lambda x, y, nx, ny: SE[2] if ny < -.2 else SE[3])
    for x in range(hx - 9, hx + 9): cv.put(x, hy - 3, SE[1]) if x % 3 == 0 else None
    stx, sty = hx - 38, cy + 6   # stool
    for lx in (-6, 0, 6): rect(cv, stx + lx, sty, stx + lx + 2, sty + 10, WD[3])
    ellfill(cv, stx, sty, 10, 4, lambda x, y, nx, ny: WD[0] if ny < -.2 else WD[1] if nx < .3 else WD[2])
    rect(cv, stx - 9, sty + 1, stx + 10, sty + 3, WD[3])
    line(cv, [(stx + 4, sty - 3), (stx + 26, sty - 36)], WD[2], 2)   # rod
    line(cv, [(stx + 4, sty - 3), (stx + 26, sty - 36)], WD[0], 1)
    line(cv, [(stx + 26, sty - 36), (hx - 1, hy - 2)], ST[1], 1)   # line
    lump(cv, hx - 1, hy - 4, 3, 3, EM, rnd, 0)   # bobber
    bx = stx - 20   # bucket and one fish tail
    rect(cv, bx, sty + 2, bx + 12, sty + 12, ST[1]); rect(cv, bx, sty + 2, bx + 12, sty + 4, ST[0]); rect(cv, bx + 9, sty + 4, bx + 12, sty + 12, ST[3])
    for k in range(5): cv.put(bx + 4 + k // 2, sty - 1 - k, EM[1]); cv.put(bx + 6 + k // 2, sty - 1 - k, EM[2])
    # snow banks on the far side and at the two ends, so the plate looks sunk into the ground
    for a in range(200, 341, 7):
        x = cx + math.cos(math.radians(a)) * (rx + 12); y = cy + math.sin(math.radians(a)) * (ry + 9) + 2
        lump(cv, int(x), int(y), rnd.randint(11, 16), rnd.randint(7, 10), SN, rnd, .05)
    # a gnome hat sitting politely on the bank
    hatx, haty = cx - 96, cy - ry - 4
    poly(cv, [(hatx - 10, haty), (hatx + 10, haty), (hatx + 6, haty - 22), (hatx + 9, haty - 32)], EM[1])
    poly(cv, [(hatx - 10, haty), (hatx - 2, haty), (hatx + 3, haty - 22), (hatx + 9, haty - 32)], EM[0])
    for x in range(hatx - 13, hatx + 14): cv.put(x, haty + 1, SN[0]); cv.put(x, haty + 2, SN[1]); cv.put(x, haty + 3, SN[2])
    for x, y, a, b in ((cx - rx - 10, cy + 6, 22, 14), (cx + rx + 10, cy + 8, 22, 14), (cx - 110, cy + 44, 30, 9), (cx + 100, cy + 46, 34, 9)):
        lump(cv, x, y, a, b, SN, rnd, .05)
    for x, y in ((cx - 60, cy - 10), (cx + 20, cy - 24), (cx + 110, cy - 6)): gen2.sparkle(cv, x, y, False)
    for x in range(16, 316, 4): cv.put(x, 165, SN[3]) if x % 8 == 0 else None


def snowman(cv, cx, base, s, rnd, hat, carrot_kind, scarf=None, mood=0):
    rb, rm, rh = int(15 * s), int(11.5 * s), int(8.5 * s)
    yb = base - rb; ym = yb - rb - rm + 5; yh = ym - rm - rh + 4
    lump(cv, cx, yb, rb, rb, SN, rnd, .05); lump(cv, cx, ym, rm, rm, SN, rnd, .05); lump(cv, cx, yh, rh, rh, SN, rnd, .05)
    for k in range(3): cv.put(cx - 1 + k, ym - 2 + k * 6, COAL); cv.put(cx - 1 + k, ym + 1 + k * 6, COAL) if False else None
    for yy in (ym - 3, ym + 4): cv.put(cx, yy, COAL); cv.put(cx + 1, yy, COAL); cv.put(cx, yy + 1, COAL); cv.put(cx + 1, yy + 1, COAL)
    for d in (-1, 1):   # twig arms
        for i in range(int(18 * s)):
            cv.put(cx + d * (rm - 2 + i), ym - 2 - i // 2 * (1 if mood == 0 else -1 if mood == 2 else 0), WD[2]); cv.put(cx + d * (rm - 2 + i), ym - 1 - i // 2 * (1 if mood == 0 else -1 if mood == 2 else 0), WD[3])
    eye(cv, cx - rh // 2 - 1, yh - 3, 2); eye(cv, cx + rh // 2, yh - 3, 2)
    for i in range(-3, 4): cv.put(cx + i, yh + rh // 2 + (1 if abs(i) > 1 else 0), COAL) if mood != 3 else None
    cx_ = cx + 1
    if carrot_kind == "long": carrot(cv, cx_, yh + 1, 1, int(26 * s), 2)
    elif carrot_kind == "tiny": carrot(cv, cx_, yh + 1, 1, 6, 1)
    elif carrot_kind == "up": carrot(cv, cx_, yh + 2, 1, int(20 * s), 2, up=11)
    elif carrot_kind == "fat": carrot(cv, cx_, yh + 2, 1, int(14 * s), 4)
    elif carrot_kind == "two": carrot(cv, cx_, yh, 1, int(14 * s), 1, up=-4); carrot(cv, cx_, yh + 3, 1, int(14 * s), 1, up=4)
    elif carrot_kind == "side": carrot(cv, cx - 3, yh + 2, -1, int(18 * s), 2, up=-3)
    if scarf:
        for x in range(cx - rh + 1, cx + rh):
            for k in range(3): cv.put(x, yh + rh - 1 + k, scarf[(0 if k == 0 else 1 if k == 1 else 2)])
        for k in range(10): cv.put(cx + rh - 3 + k // 5, yh + rh + 2 + k, scarf[1]); cv.put(cx + rh - 2 + k // 5, yh + rh + 2 + k, scarf[2])
    top = yh - rh
    if hat == "top":
        for x in range(cx - rh - 3, cx + rh + 4): cv.put(x, top + 3, ST[3]); cv.put(x, top + 4, ST[3])
        for y in range(top - 12, top + 3):
            for x in range(cx - rh + 2, cx + rh - 1): cv.put(x, y, ST[2] if x < cx + 2 else ST[3])
        for x in range(cx - rh + 2, cx + rh - 1): cv.put(x, top - 1, PT[1]); cv.put(x, top, PT[2])
    elif hat == "bobble":
        lump(cv, cx, top + 3, rh, 7, PT, rnd, .05); lump(cv, cx, top - 6, 4, 4, SN, rnd, 0)
        for x in range(cx - rh, cx + rh + 1): cv.put(x, top + 8, SN[1])
    elif hat == "pot":
        for y in range(top - 6, top + 4):
            for x in range(cx - rh + 1, cx + rh): cv.put(x, y, ST[1] if x < cx - 2 else ST[2] if x < cx + 3 else ST[3])
        for y in (top - 6, top - 5): cv.put(cx, y, ST[0])
        for k in range(4): cv.put(cx - 2 + k, top - 8, ST[3]); cv.put(cx - 2 + k, top - 7, ST[2])
    elif hat == "bucket":
        for y in range(top - 8, top + 4):
            hw = rh - 1 - (top + 4 - y) // 5 * -1 if False else rh - 2 + (y - top + 8) // 4
            for x in range(cx - hw, cx + hw + 1): cv.put(x, y, WD[1] if x < cx - 2 else WD[2] if x < cx + 3 else WD[3])
        for y in (top - 3, top + 1):
            for x in range(cx - rh, cx + rh + 1): cv.put(x, y, ST[2])
    elif hat == "crown":
        for i in range(5):
            x = cx - 8 + i * 4
            for k in range(7 + (4 if i % 2 == 0 else 0)): cv.put(x, top - k + 2, GD[1]); cv.put(x + 1, top - k + 2, GD[2])
        for x in range(cx - 8, cx + 10): cv.put(x, top + 3, GD[2]); cv.put(x, top + 2, GD[1])
    elif hat == "none":
        for k in range(3): cv.put(cx - 4 + k * 4, top - 1, WD[2]); cv.put(cx - 4 + k * 4, top - 2, WD[2])


def lm_snowmen(rnd, cv):   # 290 x 150
    H_ = 186
    for x in range(8, 282):   # bit of trampled snow floor
        for y in range(H_ - 6, H_ + 1):
            if (x * 7 + y * 3) % 5 and ((x - 145) / 140) ** 2 + ((y - H_ + 2) / 5) ** 2 < 1: cv.put(x, y, SN[1] if y < H_ - 2 else SN[2])
    snowman(cv, 40, H_ - 2, 1.3, rnd, "top", "long", PT[1], 0)
    snowman(cv, 98, H_ - 2, 1.1, rnd, "bobble", "tiny", None, 3)
    snowman(cv, 152, H_ - 2, 1.55, rnd, "none", "up", EM[1], 0)
    snowman(cv, 210, H_ - 2, 1.15, rnd, "bucket", "fat", SE[1], 1)
    snowman(cv, 255, H_ - 2, 1.35, rnd, "pot", "side", None, 2)
    for x in (68, 125, 182, 232):   # tiny rating flags
        for y in range(H_ - 18, H_ - 2): cv.put(x, y, WD[2])
        for dx in range(7):
            for dy in range(4): cv.put(x + 1 + dx, H_ - 18 + dy, GD[1] if dx % 2 else GD[0])


def lm_icecave(rnd, cv):   # 270 x 220
    # snow-capped ice mound, flat base
    for y in range(40, 218):
        t_ = (y - 40) / 178
        hw = 134 * math.sqrt(max(0, 1 - (1 - t_ ** .85) ** 2)) if t_ < 1 else 134
        for x in range(int(135 - hw), int(135 + hw) + 1):
            nx = (x - 135) / 134; ny = (y - 200) / 160
            t = tone5(gen2.shade_pt(nx * .95, ny))
            if rnd.random() < .1: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, IC[min(3, max(0, t - (1 if t > 2 else 0)))] if False else (IC[min(3, t)] if t < 4 else ST[3]))
    for k in range(60):   # chunky facets
        x, y = rnd.randint(20, 250), rnd.randint(70, 215)
        if cv.get(x, y)[3] and cv.get(x, y) != INK:
            for j in range(rnd.randint(5, 12)): cv.put(x + j, y + j // 4, IC[0]); cv.put(x + j, y + j // 4 + 1, IC[3])
    lump(cv, 135, 62, 56, 28, SN, rnd, .06); lump(cv, 88, 76, 30, 20, SN, rnd, .06); lump(cv, 184, 78, 32, 20, SN, rnd, .06)
    # the mouth
    mx0, mx1, mt, mb = 70, 202, 128, 214
    for y in range(mt, mb + 1):
        for x in range(mx0, mx1 + 1):
            nx = (x - 136) / 66; top_ = mt + 26 * (nx * nx)
            if y < top_: continue
            if y > mb - 14 and abs(nx) > .85 + (mb - y) * .01: continue
            d = (y - mt) / (mb - mt)
            cv.put(x, y, DU[3] if d > .15 else H("#241a4a"))
    for y in range(mt + 30, mb):   # inner glow
        for x in range(90, 182):
            if (x + y) % 3 == 0 and abs(x - 136) < 14 + (y - mt - 30) // 3 and y > mb - 40: cv.put(x, y, DU[2])
    # eyes in the dark (it is polite)
    for ex in (112, 150):
        for dx in range(5):
            for dy in range(7): cv.put(ex + dx, 168 + dy, CREAM)
        for dx in range(3):
            for dy in range(4): cv.put(ex + 1 + dx, 171 + dy, COAL)
    # icicle teeth along the lip, stalagmite teeth below
    for i, x in enumerate(range(mx0 + 6, mx1 - 4, 9)):
        nx = (x - 136) / 66; y0 = int(mt + 26 * nx * nx)
        icicle(cv, x, y0 - 2, 22 + int(18 * (1 - abs(nx))) + (i * 7) % 9, 8)
    for i, x in enumerate(range(mx0 + 18, mx1 - 14, 12)):
        h = 8 + (i * 5) % 11
        for k in range(h):
            hw = (h - k) // 3 + 0
            for dx in range(-hw, hw + 1): cv.put(x + dx, mb - 1 - k, IC[0] if dx < 0 else IC[1])
    for x in range(mx0 - 4, mx1 + 5):   # frosty frame rim
        for y in range(mt - 5, mt + 1):
            nx = (x - 136) / 66; top_ = mt + 26 * (nx * nx)
            if abs(y - top_ + 3) < 3 and abs(nx) < 1.03: cv.put(x, y, SN[0])


def lm_auroraledge(rnd, cv):   # 260 x 170
    X0, X1, FT, FB = 22, 238, 56, 140
    # back / top face
    slab(cv, [(X0 + 30, 22), (X1 + 14, 22), (X1, FT), (X0, FT)], IC, rnd, .4, .8)
    # front face, aurora bands showing through
    COLS = [(SE[0], SE[1], SE[2]), (MO[0], MO[1], MO[2]), (PT[0], PT[1], PT[2]), (SE[0], MO[0], SE[2])]
    for y in range(FT, FB):
        for x in range(X0, X1 + 1):
            v = ((x + y * .9) / 44.0)
            band = COLS[int(v) % 4]
            f = (y - FT) / (FB - FT)
            t = 0 if f < .28 else 1 if f < .62 else 2
            if (x + y) % 2 == 0 and abs((f * 3) % 1 - .5) < .0: t = 0
            c = band[t]
            if x == X0 or y == FT: c = IC[0]
            cv.put(x, y, c)
    for k in range(7):   # glints
        x, y = rnd.randint(X0 + 10, X1 - 40), rnd.randint(FT + 8, FB - 30)
        for j in range(rnd.randint(12, 24)): cv.put(x + j, y + j, CREAM); cv.put(x + j + 1, y + j, IC[0])
    for x in range(X0, X1 + 1): cv.put(x, FB - 1, IC[3]); cv.put(x, FB - 2, IC[3]); cv.put(x, FB - 3, IC[2])
    for x in range(X1 - 8, X1 + 1):
        for y in range(FT, FB): cv.put(x, y, darker(cv.get(x, y), 1)) if cv.get(x, y) in SE + MO + PT else None
    # snow cap and drips
    for x in range(X0 + 26, X1 + 14):
        for y in range(16, 24): cv.put(x, y, SN[0] if y < 19 else SN[1]) if (y - 16) < 5 + (x * 7) % 3 else None
    for x in range(X0, X1, 14): icicle(cv, x + 4, FT + 1, 8 + (x * 5) % 14, 6)
    # a pair of snowbanks at the foot, and a star glint
    lump(cv, 40, 150, 30, 14, SN, rnd, .06); lump(cv, 212, 152, 36, 14, SN, rnd, .06); lump(cv, 130, 160, 50, 8, SN, rnd, .06)
    for x, y in ((90, 8), (170, 12), (200, 4)):
        gen2.sparkle(cv, x, y, False)


# ------------------------------------------------------------------ 310
def drift(cv, x0, x1, base, h, u0, rnd):
    for x in range(x0, x1 + 1):
        u = (x - x0) / (x1 - x0)
        f = (u / u0) ** .75 if u < u0 else ((1 - u) / (1 - u0)) ** 1.45
        top = int(base - h * f)
        for y in range(top, base):
            d = (y - top) / max(1, h)
            if u < u0: t = 0 if d < .25 else 1 if d < .6 else 2
            else: t = 2 if d < .2 else 3 if d < .7 else 4
            if rnd.random() < .07: t = max(0, min(4, t + rnd.choice((-1, 1))))
            if y == top: t = 0
            cv.put(x, y, SN[t])
        if x == int(x0 + u0 * (x1 - x0)):
            for y in range(top, base): cv.put(x, y, SN[2])
    for k in range(int((x1 - x0) / 9)):   # wind ripples
        x = rnd.randint(x0 + 6, x1 - 6); y = base - rnd.randint(4, 12)
        if cv.get(x, y)[3]:
            for j in range(rnd.randint(5, 9)): cv.put(x + j, y + j // 5, SN[3])


def lm_driftpass(rnd, cv):   # 340 x 196
    B = 192
    drift(cv, 4, 150, B - 10, 112, .8, rnd)
    drift(cv, 100, 244, B - 6, 150, .3, rnd)
    drift(cv, 210, 336, B, 118, .78, rnd)
    # cornices: the wind has curled each crest over like a wave
    for (x, y, w) in ((118, 76, 34), (136, 44, 34), (306, 80, 34)):
        lump(cv, x, y + 4, w // 2, 9, SN, rnd, .04)
        for k in range(w // 3): cv.put(x - w // 2 + k * 3, y + 14 + (k % 2), SN[3])
        lump(cv, x - 16, y + 12, 9, 6, SN, rnd, .04)
    # scoops carved by the wind, in long lit arcs
    for (x0, y0, ln) in ((30, 140, 40), (96, 120, 36), (150, 150, 46), (214, 126, 34), (262, 150, 44)):
        for j in range(ln):
            y = y0 + int(6 * math.sin(j / ln * math.pi) * -1) + j // 8
            if not cv.get(x0 + j, y + 3)[3]: continue
            cv.put(x0 + j, y, SN[0]); cv.put(x0 + j, y + 1, SN[1]); cv.put(x0 + j, y + 2, SN[3]) if j % 2 == 0 else None
    # zig-zag signpost with a scarf, planted in front of the middle drift
    px = 168
    post(cv, px - 1, 84, B - 2, 5, WD)
    lump(cv, px + 1, B - 2, 18, 6, SN, rnd, .05)
    for (x0, y0, d) in ((px + 4, 92, 1), (px - 2, 110, -1), (px + 4, 128, 1)):
        poly(cv, [(x0, y0), (x0 + d * 36, y0), (x0 + d * 46, y0 + 7), (x0 + d * 36, y0 + 14), (x0, y0 + 14)], WD[0] if d > 0 else WD[1])
        rect(cv, min(x0, x0 + d * 36), y0 + 12, max(x0, x0 + d * 36), y0 + 14, WD[3])
        for k in range(5): cv.put(x0 + d * (7 + k * 6), y0 + 6, WD[3]); cv.put(x0 + d * (8 + k * 6), y0 + 6, WD[3])
    for k in range(18): cv.put(px - 4 - k // 3, 88 + k, PT[1]); cv.put(px - 3 - k // 3, 88 + k, PT[2]); cv.put(px - 5 - k // 3, 88 + k, PT[0]) if k % 3 == 0 else None
    lump(cv, px + 2, 82, 6, 5, SN, rnd, 0)
    # a half-buried boot, sole to the sky, with a trail of footprints that stops right at it
    bx, by = 288, 172
    lump(cv, bx, by + 6, 26, 9, SN, rnd, .05)
    rect(cv, bx - 5, by - 24, bx + 5, by, WD[2]); rect(cv, bx - 5, by - 24, bx - 2, by, WD[1]); rect(cv, bx + 3, by - 24, bx + 5, by, WD[3])
    rect(cv, bx - 6, by - 28, bx + 6, by - 24, PT[1]); rect(cv, bx - 6, by - 28, bx + 6, by - 27, PT[0])   # cuff
    for k in range(3): rect(cv, bx - 6 + k * 4, by - 26, bx - 4 + k * 4, by - 24, PT[2])
    poly(cv, [(bx + 5, by - 4), (bx + 17, by - 8), (bx + 17, by), (bx + 5, by)], WD[2])
    lump(cv, bx + 2, by + 2, 14, 6, SN, rnd, 0)
    for i in range(8):
        x, y = 190 + i * 9, B - 8 - (i % 2) * 3
        if i % 2 == 0: rect(cv, x, y, x + 3, y + 2, SN[3])
    for x, y in ((110, 18), (250, 30)): gen2.sparkle(cv, x, y, False)
    for x in range(10, 330): cv.put(x, B + 1, SN[3]) if (x * 3) % 7 == 0 else None


def lm_sledtrack(rnd, cv):   # 340 x 170
    cx, cy, rx, ry = 170, 118, 160, 40
    # a long mound of packed snow with a thick front lip
    ellfill(cv, cx, cy + 10, rx, ry, lambda x, y, nx, ny: SN[3] if ny > -.1 else None)
    ellfill(cv, cx, cy + 8, rx, ry, lambda x, y, nx, ny: SN[4] if ny > .55 else None)
    for a in range(190, 351, 9):   # a lumpy back bank so the mound stands up
        lump(cv, int(cx + math.cos(math.radians(a)) * (rx - 6)), int(cy + math.sin(math.radians(a)) * (ry - 2)), 15, 10, SN, rnd, .05)
    def top(x, y, nx, ny):
        u = ny * .55 + nx * .35; t = 0 if u < -.42 else 1 if u < -.05 else 2 if u < .5 else 3
        if rnd.random() < .05: t = max(0, min(4, t + rnd.choice((-1, 1))))
        return SN[t]
    ellfill(cv, cx, cy + 3, rx - 10, ry - 8, top)
    # snow ramp, left: a wedge with a sharp lit lip and a shaded face
    slab(cv, [(14, 130), (56, 108), (108, 58), (126, 66), (126, 134), (14, 134)], SN, rnd, sx=.3, sy=.7, speck=.04)
    rect(cv, 108, 62, 127, 134, SN[3]); rect(cv, 120, 66, 127, 134, SN[4])
    for y in range(64, 134, 4): rect(cv, 110, y, 117, y + 1, SN[2])
    for x in range(18, 108, 3): cv.put(x, 129 - (x - 14) * 70 // 94 - 1, CREAM)
    # two deep runners, grooves with a shaded far wall and a lit near lip, wobbling away from the ramp lip towards the sled
    def yc(x): return 104 + (x - 130) * .2 + 7 * math.sin(x / 24.0)
    for off in (-8, 6):
        for x in range(130, 222):
            y = int(round(yc(x) + off))
            for dy, t in ((-3, 2), (-2, 3), (-1, 4), (0, 4), (1, 1), (2, 0)): cv.put(x, y + dy, SN[t])
            if x % 9 == 0: cv.put(x, y + 3, SN[0])
    for x in range(126, 218, 7):   # frozen bounce marks between the runners
        y = int(round(yc(x) - 1)); cv.put(x, y - 2, SN[0]); cv.put(x + 1, y - 2, SN[0]); cv.put(x, y - 3, SN[1])
    # the parked sled, with a flag, a cushion and a trailing rope
    sx, sb = 226, 150
    for x in range(sx - 2, sx + 62):   # runners: two steel bars curling up at the nose
        cv.put(x, sb, ST[2]); cv.put(x, sb - 1, ST[0]); cv.put(x, sb + 1, ST[3])
    for k in range(8): cv.put(sx + 62 + k // 2, sb - 1 - k, ST[1]); cv.put(sx + 62 + k // 2, sb - k, ST[0])
    for x in (sx + 6, sx + 28, sx + 50): rect(cv, x, sb - 9, x + 4, sb, WD[3])
    for y in range(sb - 18, sb - 9):   # plank deck
        for x in range(sx - 2, sx + 64): cv.put(x, y, WD[1 if y < sb - 15 else 2]); cv.put(x, y, WD[0]) if y == sb - 18 else None
    for x in range(sx + 6, sx + 62, 10): rect(cv, x, sb - 18, x + 1, sb - 9, WD[3])
    rect(cv, sx - 2, sb - 10, sx + 64, sb - 9, WD[3])
    rect(cv, sx - 2, sb - 36, sx + 4, sb - 9, WD[2]); rect(cv, sx - 2, sb - 36, sx, sb - 9, WD[1])   # backrest
    rect(cv, sx - 2, sb - 36, sx + 4, sb - 34, WD[0])
    for x in range(sx + 6, sx + 40): rect(cv, x, sb - 24, x + 1, sb - 18, PT[1] if (x // 5) % 2 else PT[0])   # striped cushion
    lump(cv, sx + 22, sb - 24, 17, 4, PT, rnd, 0)
    line(cv, [(sx + 66, sb - 12), (sx + 76, sb - 4), (sx + 88, sb - 2)], EM[2], 1)   # rope
    rect(cv, sx + 86, sb - 4, sx + 90, sb, EM[1])
    # the flag: pole in the bank, triangular pennant
    fx = 306
    post(cv, fx, 56, 142, 3, WD)
    poly(cv, [(fx + 3, 58), (fx + 34, 68), (fx + 3, 80)], EM[1]); poly(cv, [(fx + 3, 58), (fx + 22, 64), (fx + 3, 68)], EM[0])
    cv.put(fx + 1, 54, GD[0]); cv.put(fx + 1, 55, GD[0]); cv.put(fx + 2, 55, GD[0])
    lump(cv, fx + 1, 142, 12, 5, SN, rnd, 0)
    # a lost mitten on a stick (the caption's one lost mitten), left in front of the ramp
    mx = 40
    post(cv, mx, 74, 120, 3, WD)
    lump(cv, mx + 1, 66, 8, 10, EM, rnd, .05); lump(cv, mx - 7, 70, 3, 5, EM, rnd, 0)
    for x in range(mx - 6, mx + 9): cv.put(x, 74, SN[0]); cv.put(x, 75, SN[1])
    lump(cv, mx + 1, 120, 10, 4, SN, rnd, 0)
    # small gnome footprints trudging back up, snowballs, drifts
    for i in range(10):
        x, y = 136 + i * 8, 134 + int(3 * math.sin(i)); cv.put(x, y, SN[3]); cv.put(x + 1, y, SN[3]); cv.put(x, y + 1, SN[3]) if i % 2 == 0 else cv.put(x + 3, y - 1, SN[3])
    for x, y in ((190, 138), (200, 140)): lump(cv, x, y, 4, 4, SN, rnd, 0)
    lump(cv, 24, 144, 20, 8, SN, rnd, .05); lump(cv, 150, 158, 42, 6, SN, rnd, .05)
    for x, y in ((90, 70), (150, 54)): gen2.sparkle(cv, x, y, False)


def lm_comb(rnd, cv):   # 290 x 190
    B = 186
    # two stone legs
    for lx in (46, 244):
        for k, (cy, rx, ry) in enumerate(((B - 18, 26, 18), (B - 46, 24, 18), (B - 74, 22, 16), (B - 100, 24, 18))):
            lump(cv, lx + (k % 2) * 3 - 1, cy, rx, ry, ST, rnd, .1)
    # the ridge: long snow bar
    for x in range(8, 282):
        u = (x - 8) / 273
        top = 24 + int(8 * math.sin(u * 3.14159)) * -1 + 8
        for y in range(18 + int(10 * (1 - math.sin(u * 3.14159))), 62 + int(8 * (1 - math.sin(u * 3.14159)))):
            d = (y - 18) / 44.0
            t = 0 if d < .18 else 1 if d < .45 else 2 if d < .75 else 3
            if rnd.random() < .07: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, SN[t])
    for x in range(8, 282):   # ends rounded
        e = min(x - 8, 281 - x)
        if e < 10:
            for y in range(0, 90):
                if cv.get(x, y)[3] and y < 20 + (10 - e) * 2 + 4 - 4 and e < 6 and y < 44 - e * 3: cv.p[x, y] = (0, 0, 0, 0)
    # teeth pointing politely down
    i = 0
    for x in range(22, 270, 12):
        ln = 62 + (i * 37) % 24 - (10 if i % 5 == 3 else 0)
        if i == 9: ln = 22   # one broken tooth, embarrassed
        yoff = int(10 * (1 - math.sin((x - 8) / 273 * 3.14159)))
        icicle(cv, x, 60 + yoff, ln, 10)
        i += 1
    for x, y in ((30, 14), (140, 10), (230, 14)):
        lump(cv, x, y + 4, 22, 8, SN, rnd, .04)
    for x in range(40, 250): cv.put(x, B + 1, IC[3]) if x % 5 == 0 else None


def lm_icicurtain(rnd, cv):   # 250 x 194
    B = 192
    for px in (22, 224):   # posts
        trunk(cv, px, 20, B, 16, rnd)
        lump(cv, px, 18, 14, 8, SN, rnd, .04)
    for y in range(34, 50):   # crossbar
        for x in range(10, 238): cv.put(x, y, WD[0] if y < 37 else WD[1] if y < 43 else WD[2] if y < 47 else WD[3])
    for x in range(14, 236):
        for y in range(28, 34): cv.put(x, y, SN[0] if y < 31 else SN[1]) if (x * 5 + y) % 9 < 7 else None
    i = 0
    for x in range(34, 218, 8):
        ln = 44 + (i * 53) % 58 + (14 if 8 < i < 14 else 0)
        icicle(cv, x, 50, ln, 7 if i % 3 else 9)
        i += 1
    for x in range(30, 220, 8):   # shorter secondary row, staggered
        if (x // 8) % 2: icicle(cv, x + 4, 50, 30 + (x * 3) % 20, 5, IC)
    for x, ln in ((58, 60), (122, 92), (170, 74), (194, 52)):   # little chime bells
        y = 50 + ln + 4
        for dx in range(7):
            for dy in range(6): cv.put(x - 3 + dx, y + dy, GD[1] if dy < 3 else GD[2]) if (dx - 3) ** 2 + (dy - 5) ** 2 <= 14 else None
        cv.put(x, y + 6, GD[3])
    # do-not-lick sign
    for y in range(120, 150): cv.put(224 - 7, y, WD[3]) if False else None
    poly(cv, [(190, 140), (226, 140), (226, 168), (190, 168)], WD[1])
    for x in range(190, 227): cv.put(x, 140, WD[0]); cv.put(x, 168, WD[3])
    for y in range(140, 169): cv.put(226, y, WD[3])
    poly(cv, [(198, 148), (203, 148), (203, 151), (198, 151)], COAL); poly(cv, [(212, 148), (217, 148), (217, 151), (212, 151)], COAL)
    poly(cv, [(202, 158), (214, 158), (214, 162), (202, 162)], COAL)
    poly(cv, [(206, 162), (211, 162), (211, 166), (206, 166)], PT[1])
    line(cv, [(194, 144), (222, 164)], EM[1], 2)
    for x in range(26, 222): cv.put(x, B + 1, SN[3]) if x % 4 == 0 else None


# ------------------------------------------------------------------ 316
def lm_skyhill(rnd, cv):   # 290 x 190
    B = 186; cx = 145; TOP = 70
    for y in range(TOP, B):
        hw = 46 + 98 * math.sqrt(max(0, 1 - ((B - y) / (B - TOP) - 0) ** 2) if False else 98 * 0)
        hw = 50 + 92 * math.sqrt(max(0, 1 - ((B - y) / (B - TOP + 0.0)) ** 2.4 * 0 - (1 - (y - TOP) / (B - TOP)) ** 2))
        for x in range(int(cx - hw), int(cx + hw) + 1):
            nx = (x - cx) / (hw + 18) * (.9); ny = -(B - y) / (B - TOP) * .6 + .05
            t = tone5(gen2.shade_pt(nx, ny))
            if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, SN[t])
    for y in range(TOP - 9, TOP + 10):   # flat lit top
        for x in range(cx - 52, cx + 53):
            if ((x - cx) / 52) ** 2 + ((y - TOP) / 9) ** 2 <= 1: cv.put(x, y, SN[0] if (x + y) % 11 else CREAM)
    for k in range(5):   # wind combs on the slope
        x, y = rnd.randint(40, 230), rnd.randint(TOP + 30, B - 14)
        if cv.get(x, y)[3] and cv.get(x, y) != INK:
            for j in range(rnd.randint(10, 20)): cv.put(x + j, y + j // 6, SN[0]); cv.put(x + j, y + j // 6 + 1, SN[3])
    # a footpath up the hill
    for i in range(22):
        t = i / 21; x = int(88 + 24 * math.sin(t * 5) * 0 + t * 40 - 20 * (1 - t) * 0); y = int(B - 8 - t * (B - TOP - 20))
        x = int(100 + t * 24 + 6 * math.sin(t * 9));
        if i % 2: cv.put(x, y, SN[3]); cv.put(x + 1, y, SN[3]); cv.put(x, y + 1, SN[3])
    # a gnome lying on a blanket, counting nothing
    bx, by = 140, TOP
    poly(cv, [(bx - 36, by + 1), (bx + 34, by - 2), (bx + 38, by + 5), (bx - 32, by + 8)], PT[1])
    for x in range(bx - 34, bx + 36, 6): line(cv, [(x, by + 1), (x + 2, by + 7)], PT[0])
    lump(cv, bx - 24, by - 2, 7, 5, SN, rnd, 0)   # beard
    lump(cv, bx - 18, by - 4, 11, 6, SE, rnd, .05)   # belly
    for sx in (bx + 2, bx + 12):   # boots in the air
        for y in range(by - 10, by): cv.put(sx, y, SE[2]); cv.put(sx + 1, y, SE[3])
        for dx in range(5):
            for dy in range(4): cv.put(sx - 1 + dx, by - 14 + dy, WD[1] if dy < 2 else WD[3])
    poly(cv, [(bx - 38, by - 4), (bx - 30, by - 4), (bx - 30, by - 20), (bx - 28, by - 30)], EM[1])
    poly(cv, [(bx - 36, by - 4), (bx - 33, by - 4), (bx - 31, by - 20), (bx - 28, by - 30)], EM[0])
    for x in range(bx - 40, bx - 27): cv.put(x, by - 3, SN[1])
    for x, y in ((60, 20), (96, 8), (150, 14), (200, 10), (238, 28), (175, 36), (110, 38)):   # nothing in particular
        gen2.sparkle(cv, x, y, False)


def menhir(cv, cx, base, w, h, R, rnd, lean=0, dots=None):
    """A tall standing stone: tapered slab, snow cap, carved constellation dots (GD) joined by faint lines."""
    top = base - h
    pts = [(cx - w // 2, base), (cx - w // 2 + 3 + lean, top + 12), (cx - w // 2 + 9 + lean, top + 2), (cx + w // 2 - 7 + lean, top), (cx + w // 2 - 1 + lean, top + 14), (cx + w // 2, base)]
    slab(cv, pts, R, rnd, sx=.75, sy=.25, speck=.09)
    for k in range(3):   # strata
        yy = top + 24 + k * (h // 4); line(cv, [(cx - w // 2 + 3, yy), (cx + w // 2 - 3, yy + 2)], R[3])
    if dots:
        ps = [(cx - w // 2 + int(u * w), top + int(v * h)) for u, v in dots]
        for a, b in zip(ps, ps[1:]): line(cv, [a, b], R[4] if R[2] != GD[2] else GD[3])
        for x, y in ps:
            rect(cv, x - 1, y - 1, x + 1, y + 1, CREAM); cv.put(x, y, GD[1])
    lump(cv, cx + lean * .5 - 1, top + 3, w // 2 + 1, 6, SN, rnd, .05)


def lm_starstones(rnd, cv):   # 340 x 200
    cx, cy, rx, ry = 170, 160, 160, 34
    TH = 10
    ellfill(cv, cx, cy + TH, rx, ry, lambda x, y, nx, ny: ST[3] if ny > -.2 else None)
    ellfill(cv, cx, cy + TH - 2, rx, ry, lambda x, y, nx, ny: ST[4] if ny > .5 else None)
    def floor(x, y, nx, ny):
        u = ny * .5 + nx * .4; t = 0 if u < -.4 else 1 if u < -.05 else 2 if u < .45 else 3
        if (x * 3 + y * 5) % 17 == 0: t = max(0, t - 1)
        if abs(x // 24 - (y + (x // 24) % 2 * 6) // 12) % 5 == 0 and (x % 24 == 0 or y % 12 == 0): t = min(4, t + 1)   # flagstone seams
        return ST[1 + (t > 1) + (t > 2)]
    ellfill(cv, cx, cy, rx, ry, floor)
    for x in range(cx - rx + 4, cx + rx - 3):   # frost rim
        y = int(cy - ry * math.sqrt(max(0, 1 - ((x - cx) / rx) ** 2)))
        cv.put(x, y + 1, SN[0]); cv.put(x, y + 2, SN[1]) if x % 3 else None
    # the star chart inlaid in the floor: dots joined by lines
    pts = [(40, 160), (70, 174), (104, 162), (136, 178), (170, 160), (206, 168), (240, 176), (276, 160), (300, 166), (120, 148), (220, 150)]
    for a, b in ((0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (2, 9), (4, 10), (10, 5)):
        line(cv, [pts[a], pts[b]], SN[1], 1)
    for i, (x, y) in enumerate(pts):
        big = i in (3, 6)
        rect(cv, x - 2, y - 1, x + 2, y + 2, GD[1] if big else SN[0]); cv.put(x - 1, y - 1, CREAM)
    # the standing stones in a half-ring at the back, then the glowing gold star stone in the middle
    menhir(cv, 36, 160, 34, 76, ST, rnd, lean=-2, dots=[(.2, .2), (.55, .35), (.4, .62), (.8, .8)])
    menhir(cv, 82, 148, 40, 104, ST, rnd, lean=1, dots=[(.7, .12), (.3, .3), (.55, .5), (.25, .72), (.6, .86)])
    menhir(cv, 258, 148, 40, 98, ST, rnd, lean=-1, dots=[(.25, .15), (.6, .28), (.45, .5), (.78, .62), (.4, .84)])
    menhir(cv, 304, 160, 34, 70, ST, rnd, lean=2, dots=[(.3, .22), (.7, .4), (.45, .7)])
    menhir(cv, 170, 142, 52, 118, GD, rnd, lean=0)
    star5(cv, 170, 62, 15, CREAM); star5(cv, 170, 63, 9, GD[0])   # carved star, lit from within
    for ang in range(0, 360, 45):   # glow rays
        for k in range(5, 11):
            x = 170 + int(math.cos(math.radians(ang)) * (16 + k)); y = 62 + int(math.sin(math.radians(ang)) * (16 + k))
            if cv.get(x, y)[3] and cv.get(x, y) in tuple(GD): cv.put(x, y, GD[0])
    for x, y in ((140, 24), (202, 20), (170, 6), (118, 60), (224, 48)): gen2.sparkle(cv, x, y, False)
    for x, y in ((150, 22), (190, 36)): cv.put(x, y, GD[0]); cv.put(x + 1, y, GD[0])
    # star-chart table, front right: a stone slab with the chart pinned on it
    tx, ty = 262, 186
    for lx in (tx - 26, tx + 22): rect(cv, lx, ty - 18, lx + 5, ty, ST[2]); rect(cv, lx, ty - 18, lx + 2, ty, ST[1]); rect(cv, lx + 3, ty - 18, lx + 5, ty, ST[3])
    slab(cv, [(tx - 36, ty - 26), (tx + 24, ty - 30), (tx + 36, ty - 22), (tx - 28, ty - 18)], ST, rnd, sx=.5, sy=.5, speck=.04)
    rect(cv, tx - 30, ty - 18, tx + 34, ty - 15, ST[3])
    poly(cv, [(tx - 26, ty - 25), (tx + 18, ty - 28), (tx + 26, ty - 22), (tx - 20, ty - 20)], CREAM)
    for i, (x, y) in enumerate(((-16, -24), (-6, -26), (4, -24), (-2, -22), (12, -25), (18, -23))): cv.put(tx + x, ty + y, DU[1]); cv.put(tx + x + 1, ty + y, DU[1])
    line(cv, [(tx - 16, ty - 24), (tx - 6, ty - 26), (tx + 4, ty - 24), (tx + 12, ty - 25)], DU[2], 1)
    cv.put(tx + 26, ty - 26, GD[1]); cv.put(tx + 27, ty - 26, GD[1]); cv.put(tx + 26, ty - 27, GD[0])   # a lost pencil
    line(cv, [(tx + 22, ty - 24), (tx + 33, ty - 25)], GD[2], 2)
    lump(cv, 28, 186, 22, 8, SN, rnd, .05); lump(cv, 156, 192, 40, 7, SN, rnd, .05); lump(cv, 318, 190, 22, 8, SN, rnd, .05)
    for x, y in ((92, 180), (205, 182)): lump(cv, x, y, 6, 3, ST, rnd, .05)


def lm_auroracamp(rnd, cv):   # 300 x 250
    B = 244
    # aurora ribbons overhead
    for x in range(6, 294):
        for band, (cols, off, amp) in enumerate((((SE[1], MO[0], MO[1]), 82, 12), ((PT[1], PT[0], SE[0]), 104, 9))):
            top = int(off + amp * math.sin(x / 26.0 + band * 1.7) + 4 * math.sin(x / 9.0))
            ln = 46 - band * 12 + int(10 * math.sin(x / 13.0 + band))
            for k in range(ln):
                f = k / ln
                c = cols[0] if f < .12 else cols[1] if f < .5 else cols[2]
                if f > .62 and (x + k) % 2: continue
                if f > .85 and (x + k) % 4: continue
                cv.put(x, top + k, c)
    # tents
    def tent(cx, w, h, R, R2):
        for y in range(B - h, B):
            hw = int((y - (B - h)) / h * w / 2) + 1
            for x in range(cx - hw, cx + hw + 1):
                t = 0 if x < cx - hw * .4 else 1 if x < cx else 2 if x < cx + hw * .5 else 3
                st = ((x + (y - B + h) // 2) // 10) % 2
                cv.put(x, y, (R2 if st else R)[t + (1 if t < 3 and False else 0)])
        for y in range(int(B - h * .5), B):
            hw = int(w * .13 * (y - (B - h * .5)) / (h * .5) + 4)
            for x in range(cx - hw, cx + hw + 1): cv.put(x, int(y), DU[3] if abs(x - cx) < hw - 2 else DU[2])
        for k in range(8): cv.put(cx - 4 + k // 2 * 2, B - h - k, WD[2]); cv.put(cx - 3 + k // 2 * 2, B - h - k, WD[3]) if False else None
        for k in range(10): cv.put(cx, B - h - k, WD[2]); cv.put(cx + 1, B - h - k, WD[3])
        for k in range(8): cv.put(cx + 2 + k, B - h - 10 + (k // 2) * 0 + k % 2, PT[1])   # pennant
    tent(60, 108, 104, EM[1:] and [EM[0], EM[0], EM[1], EM[2]], [PT[0], PT[1], PT[1], PT[2]] if False else [SN[0], SN[1], SN[2], SN[3]])
    tent(232, 88, 84, [DU[0], DU[1], DU[2], DU[3]], [SN[0], SN[1], SN[2], SN[3]])
    # logs, stone ring, fire
    fx = 148
    for dx in range(-30, 31):
        for dy in range(-6, 7):
            if dx * dx / 900 + dy * dy / 36 <= 1: cv.put(fx + dx, B - 8 + dy, ST[2 if dy < 0 else 3])
    for k in range(9):
        a = k / 9 * 6.283; lump(cv, fx + int(30 * math.cos(a)), B - 8 + int(7 * math.sin(a)), 7, 5, ST, rnd, .1)
    for x in range(fx - 20, fx + 21):
        for y in range(B - 18, B - 8):
            if (x - fx) ** 2 / 400 + (y - B + 13) ** 2 / 25 <= 1: cv.put(x, y, EM[2] if y > B - 12 else EM[1])
    for (dx, hgt) in ((-10, 24), (0, 36), (10, 28), (-18, 14), (18, 14)):   # flames
        for k in range(hgt):
            hw = max(0, (hgt - k) // 6 + 1 if k < hgt * .6 else (hgt - k) // 6)
            for x in range(fx + dx - hw, fx + dx + hw + 1): cv.put(x, B - 12 - k, EM[0] if k > hgt * .5 else GD[2] if k > hgt * .25 else GD[1] if k > 3 else GD[0])
    for (x0, x1) in ((fx - 22, fx + 18), (fx + 22, fx - 16)):   # crossed logs
        line(cv, [(x0, B - 5), (x1, B - 12)], WD[2], 5); line(cv, [(x0, B - 7), (x1, B - 14)], WD[0], 1)
    # tripod and kettle
    for sx in (-1, 0, 1):
        line(cv, [(fx + sx * 36, B - 8), (fx + sx * 3, B - 82)], WD[2], 3) if sx != 0 else line(cv, [(fx, B - 4), (fx + 2, B - 82)], WD[1], 3)
    ky = B - 62
    for y in range(ky - 2, ky + 24): cv.put(fx - 1, y, ST[3])
    lump(cv, fx, ky + 30, 17, 14, ST, rnd, .05)
    lump(cv, fx, ky + 18, 10, 4, ST, rnd, 0)
    for k in range(10): cv.put(fx + 15 + k, ky + 28 - k, ST[2]); cv.put(fx + 15 + k, ky + 27 - k, ST[1]) if False else None
    for k in range(9): cv.put(fx - 16 - k, ky + 26 - k // 2, ST[2])
    for a in range(180, 360, 10): cv.put(fx + int(round(math.cos(math.radians(a)) * 12)), ky + 17 + int(round(math.sin(math.radians(a)) * 12)), EM[2])
    for k in range(3):   # steam
        for j in range(8): cv.put(fx + 6 + k * 4 + int(2 * math.sin(j)), ky - 4 - j * 3, SN[0]); cv.put(fx + 7 + k * 4 + int(2 * math.sin(j)), ky - 4 - j * 3, SN[1])
    for lx in (96, 202):   # log seats
        lump(cv, lx, B - 6, 14, 6, WD, rnd, .08)
        for k in range(5): cv.put(lx - 6 + k * 3, B - 9, WD[0]); cv.put(lx - 5 + k * 3, B - 9, WD[1])
    for x in range(10, 292): cv.put(x, B + 1, SN[3]) if x % 5 == 0 else None


def lm_kettletree(rnd, cv):   # 240 x 232
    B = 228
    trunk(cv, 120, 150, B, 24, rnd)
    for x in range(88, 152):
        for y in range(150, 190):
            c = cv.get(x, y)
            if c[3] and c in RAMP["wood"]: cv.put(x, y, darker(c, 1))
    tiers = [(120, 6, 112, 52), (120, 52, 156, 92), (120, 100, 200, 134), (120, 150, 236, 176)]   # (cx, apex, base y? , halfwidth)
    tiers = [(120, 6, 64, 40), (120, 38, 108, 62), (120, 80, 152, 82), (120, 122, 196, 96)]
    for cx_, ay, by_, hw in tiers:
        for y in range(ay, by_):
            f = (y - ay) / (by_ - ay)
            w = int(hw * (f ** .9) * (1 if True else 1))
            scal = 3 if ((cx_ + y) // 3) % 2 and y > by_ - 10 else 0
            for x in range(cx_ - w, cx_ + w + 1):
                u = (x - (cx_ - w)) / max(1, 2 * w)
                t = 0 if u < .2 else 1 if u < .45 else 2 if u < .72 else 3
                if rnd.random() < .07: t = max(0, min(4, t + rnd.choice((-1, 1))))
                if y > by_ - 4: t = 3
                cv.put(x, y, PI[t] if t < 4 else PI[3])
        for x in range(cx_ - hw, cx_ + hw + 1):   # ragged skirts
            for k in range(0, 6):
                if abs(x - cx_) <= hw and (x // 4) % 2 == 0: cv.put(x, by_ + k // 2, PI[3] if k > 1 else PI[2]) if abs(x - cx_) < hw - 2 else None
    leaf_texture(cv, PI, rnd, 500)
    for cx_, ay, by_, hw in tiers:   # snow along each tier's upper contour
        for x in range(cx_ - hw, cx_ + hw + 1):
            for y in range(ay, by_):
                if cv.get(x, y)[3] and cv.get(x, y - 1)[3] == 0:
                    for k in range(3 + (x % 3)): cv.put(x, y + k, SN[0] if k < 2 else SN[1])
                    break
    lump(cv, 120, 12, 10, 8, SN, rnd, .04)
    # hung kettles and mugs
    def kettle(x, y, R):
        line(cv, [(x, y - 14), (x, y)], WD[3], 1); line(cv, [(x - 8, y), (x + 8, y)], WD[2], 1)
        lump(cv, x, y + 10, 11, 9, R, rnd, .05); lump(cv, x, y + 2, 7, 3, R, rnd, 0)
        for k in range(7): cv.put(x + 10 + k // 2, y + 12 - k, R[2]); cv.put(x + 10 + k // 2, y + 11 - k, R[1])
        for k in range(8): cv.put(x - 10 - k // 2, y + 8 - k // 2, R[2])
    def mug(x, y, R):
        line(cv, [(x, y - 10), (x, y)], WD[3], 1)
        for dx in range(10):
            for dy in range(11): cv.put(x - 5 + dx, y + dy, R[0] if dx < 2 else R[1] if dx < 6 else R[2])
        for dy in range(2, 9): cv.put(x + 6, y + dy, R[2]); cv.put(x + 7, y + dy, R[2]) if dy in (2, 8) else None
        for dx in range(10): cv.put(x - 5 + dx, y + 1, CREAM)
    kettle(88, 62, ST)
    kettle(52, 104, EM); kettle(190, 108, ST)
    kettle(126, 112, SE); kettle(60, 144, GD); kettle(184, 150, PT)
    for x, y, R in ((112, 54, EM), (146, 80, GD), (96, 88, SE), (74, 86, PT), (156, 134, EM), (110, 140, SE), (30, 142, ST), (140, 168, GD), (210, 142, GD), (92, 176, PT), (24, 160, SE), (212, 170, EM)):
        mug(x, y, R)
    for x in range(30, 214): cv.put(x, B + 1, SN[3]) if x % 5 == 0 else None
    for k in range(3):   # steam from one kettle
        for j in range(7): cv.put(126 - 2 + k * 4 + int(2 * math.sin(j)), 112 - j * 3 - 6, SN[0])


def tone5(d): return gen2.tone5(d)


LM = {
    "309-frozenpond": (330, 170, lm_frozenpond),
    "309-snowmen": (290, 190, lm_snowmen),
    "309-icecave": (270, 220, lm_icecave),
    "309-auroraledge": (260, 170, lm_auroraledge),
    "310-driftpass": (340, 196, lm_driftpass),
    "310-sledtrack": (340, 170, lm_sledtrack),
    "310-combridge": (290, 190, lm_comb),
    "310-icicurtain": (250, 194, lm_icicurtain),
    "316-skyhill": (290, 190, lm_skyhill),
    "316-starstones": (340, 200, lm_starstones),
    "316-auroracamp": (300, 250, lm_auroracamp),
    "316-kettletree": (240, 232, lm_kettletree),
}
