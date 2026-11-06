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


# ===================================================================== hand-pixel toolkit (heightfield-lit snow and ice)
WARM = H("#fffaea"); WHITE = (255, 255, 255, 255); VIO = mix(SN[4], DU[1], .35)
SNR = list(SN)                                                              # the game 5-step snow ramp (keeps _painterly happy)
ICR = list(IC)
SKIN = r5([H("#ffe0c8"), H("#f4b898"), H("#d98c74"), H("#a35c58")])
FROST = [H("#e6cf94"), H("#c9a56a"), H("#9a7a4e"), H("#6b5238")]            # frozen dead grass
_BAY = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))
_Ln = math.sqrt(.5 * .5 + .6 * .6 + .62 * .62); LX, LY, LZ = -.5 / _Ln, -.6 / _Ln, .62 / _Ln


def vnoise(rnd, cell):
    g = {}
    def val(i, j):
        if (i, j) not in g: g[(i, j)] = rnd.random()
        return g[(i, j)]
    def f(x, y):
        fx, fy = x / cell, y / cell; i, j = math.floor(fx), math.floor(fy); tx, ty = fx - i, fy - j
        tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
        a = val(i, j) + (val(i + 1, j) - val(i, j)) * tx; b = val(i, j + 1) + (val(i + 1, j + 1) - val(i, j + 1)) * tx
        return a + (b - a) * ty
    return f


def quant(R, lvl, x, y, band=.55):
    """Ramp step for a continuous level; the middle `band` of every step is a Bayer checker dither into the next tone."""
    lvl = max(0., min(len(R) - 1.001, lvl)); i = int(lvl); f2 = ((lvl - i) - (1 - band) / 2) / band
    return R[i + 1] if f2 > 0 and f2 > (_BAY[y & 3][x & 3] + .5) / 16 else R[i]


def ell_n(cx, cy, rx, ry, flat=1.0):
    def f(x, y):
        nx = max(-.995, min(.995, (x + .5 - cx) / rx)); ny = max(-.995, min(.995, (y + .5 - cy) / ry)) * flat
        return nx, ny, math.sqrt(max(.01, 1 - nx * nx - ny * ny))
    return f


def shade(cv, box, inside, nrm, R, bump=None, bk=2.5, bias=0., gain=3.7, band=.55, bounce=0., pick=None):
    """Light a region from its surface normal (nrm(x,y) -> unit vector) plus an optional bump heightfield; light top-left, tones dithered at the steps,
    and a bounce-light band 2-4 px inside the lower-right edge."""
    x0, y0, x1, y1 = box
    for y in range(max(0, y0), min(cv.h, y1 + 1)):
        for x in range(max(0, x0), min(cv.w, x1 + 1)):
            if not inside(x, y): continue
            nx, ny, nz = nrm(x, y)
            if bump:
                nx -= (bump(x + 1, y) - bump(x - 1, y)) * bk * .5; ny -= (bump(x, y + 1) - bump(x, y - 1)) * bk * .5
                l = math.sqrt(nx * nx + ny * ny + nz * nz); nx /= l; ny /= l; nz /= l
            lam = nx * LX + ny * LY + nz * LZ; lvl = (.98 - lam) * gain + bias
            if bounce and lvl > 3.2:
                k = 1
                while k < 7 and inside(x + k, y + k): k += 1
                if 2 <= k <= 5: lvl -= bounce * (1 - abs(k - 3.5) / 2.5)
            c = pick(x, y, lvl) if pick else None
            cv.put(x, y, c or quant(R, lvl, x, y, band))


def fprint(cv, x, y, s=1, d=0):
    """A boot print pressed into snow (shade on its top-left inner wall, lit lip on the bottom-right)."""
    P = {(dx, dy) for dy in range(0, 4 * s) for dx in range(0, 2 * s + 1) if not (s > 1 and dy in (0, 4 * s - 1) and dx in (0, 2 * s))}
    P |= {(dx, dy) for dy in range(5 * s, 7 * s - (1 if s == 1 else 0)) for dx in range(0, 2 * s)}
    if d: P = {(dx + (dy // 3) * d, dy) for dx, dy in P}
    for dx, dy in P:
        if cv.get(x + dx, y + dy)[3]: cv.put(x + dx, y + dy, SN[3] if (dx - 1, dy - 1) in P else SN[4])
    for dx, dy in P:
        if (dx + 1, dy + 1) not in P and cv.get(x + dx + 1, y + dy + 1)[3] and cv.get(x + dx + 1, y + dy + 1) in SN: cv.put(x + dx + 1, y + dy + 1, SN[0])


def tuft(cv, x, y, rnd, n=5, h=7):
    """Tuft of frozen dead grass, frost on every tip, a little blown snow banked at its foot."""
    for k in range(n):
        c = (k - (n - 1) / 2); lean = c * .5 + rnd.uniform(-.25, .25); ln = int(h - abs(c) * 1.2 + rnd.uniform(-1, 1))
        for i in range(max(2, ln)):
            xx = x + int(round(lean * i * .55 + lean * i * i * .04)); cv.put(xx, y - i, FROST[1] if (k + i // 3) % 2 else FROST[0] if i > ln * .45 else FROST[2])
        cv.put(x + int(round(lean * ln * .55 + lean * ln * ln * .04)), y - ln, SN[0])
    for dx in range(-n, n + 1):
        if abs(dx) + rnd.random() * 2 < n: cv.put(x + dx, y, SN[1] if dx < 1 else SN[3]); cv.put(x + dx, y + 1, SN[2] if dx < 1 else SN[4])


def sprig(cv, x, y, rnd, d=1, ln=12):
    """Pine sprig lying on the snow, snow dusting the upper needles."""
    for k in range(ln): cv.put(x + d * k, y - k // 6, WD[3])
    for k in range(2, ln, 2):
        for j in (-1, 1):
            for i in range(1, 4 - (k * 3 // ln)): cv.put(x + d * k + (d if j > 0 and i > 1 else 0), y - k // 6 + j * i, PI[2] if j < 0 else PI[3] if i % 2 else PI[1])
        cv.put(x + d * k, y - k // 6 - 2, SN[0]); cv.put(x + d * k, y - k // 6 - 1, SN[1])


def crack(cv, x, y, n, rnd, dx=1., dy=.35, col=None, lip=True, branch=.12, only=None):
    col = col or SN[4]; fx, fy = x, y
    for i in range(n):
        fx += dx + rnd.uniform(-.5, .5); fy += dy + rnd.uniform(-.6, .6)
        px, py = int(fx), int(fy); c = cv.get(px, py)
        if not c[3] or (only and c not in only): break
        cv.put(px, py, col)
        if lip and cv.get(px, py - 1)[3] and cv.get(px, py - 1) in SNR + ICR: cv.put(px, py - 1, SN[0])
        if rnd.random() < branch and n - i > 4: crack(cv, px, py, (n - i) // 2, rnd, dx * .5, dy + rnd.choice((-.8, .8)), col, lip, 0, only)


def sastr(cv, x, y, ln, rnd, wave=1., drop=.12):
    """Sastrugi: a wind-cut ridge, lit crest above and a cool shadow tucked under it, swelling in the middle and ending in a point."""
    ph = rnd.random() * 6
    for j in range(ln):
        t = j / max(1, ln - 1); sw = math.sin(t * math.pi); yy = y + int(round(math.sin(j * .3 + ph) * wave + j * drop))
        if not cv.get(x + j, yy)[3]: continue
        cv.put(x + j, yy, WARM if sw > .3 else SN[1])
        if sw > .25 and cv.get(x + j, yy + 1)[3]: cv.put(x + j, yy + 1, SN[3] if sw > .6 or j % 2 else SN[2])
        if sw > .8 and cv.get(x + j, yy + 2)[3] and j % 2: cv.put(x + j, yy + 2, SN[4])


def glint(cv, x, y, big=0):
    cv.put(x, y, WHITE)
    if big:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, CREAM)
        if big > 1:
            for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + dx, y + dy, WARM)


def tube(cv, p0, p1, w0, w1, R, rings=(), ring=None):
    """A shaded round tube between two points: lit on the top-left side, rings at fractions of its length."""
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]; L = math.hypot(dx, dy); ux, uy = dx / L, dy / L; px, py = -uy, ux
    if px * LX + py * LY < 0: px, py = -px, -py
    for s in range(int(L * 2) + 1):
        f = s / (L * 2); w = w0 + (w1 - w0) * f; q = f * L
        for o in range(int(-w * 2), int(w * 2) + 1):
            oo = o / 2; u = .5 - oo / w * .5 if w else .5
            t = 0 if u < .16 else 1 if u < .34 else 2 if u < .6 else 3 if u < .86 else 4
            if any(abs(f - r) < .018 for r in rings): t = min(4, t + 2)
            cv.put(int(round(p0[0] + ux * q + px * oo)), int(round(p0[1] + uy * q + py * oo)), (ring or R)[min(len(R) - 1, t)] if any(abs(f - r) < .018 for r in rings) and ring else R[t])


def icicle2(cv, x, y, ln, w, rnd, R=None, lean=0., bead=True, hollow=False):
    """A hand-drawn icicle: bumpy taper, lit left flank, cool right flank, a bright streak, a hanging drop."""
    R = R or ICR; wob = [rnd.choice((0, 0, 0, 1, -1)) for _ in range(ln)]
    for i in range(ln):
        f = i / ln; hw = max(0, int(round(w / 2 * (1 - f) ** .85 + (wob[i] * .5 if 0 < f < .8 else 0)))); cxx = x + int(round(lean * f * f * ln * .3))
        for k in range(-hw, hw + 1):
            u = (k + hw) / max(1, 2 * hw); t = 1 if u < .3 else 2 if u < .55 else 3 if u < .8 else 4
            if hw == 0: t = 2
            if k == -hw and hw > 0 and f < .85: t = 0 if i % 3 else 1
            if hollow and k == 0 and hw > 1 and 2 < i < ln - 4: t = 4
            cv.put(cxx + k, y + i, R[t])
        if hw >= 2 and f < .7 and i % 4 != 3: cv.put(cxx - hw + 1, y + i, R[0])
    ex = x + int(round(lean * ln * .3))
    cv.put(ex, y + ln, R[1])
    if bead and rnd.random() < .6: cv.put(ex, y + ln + 2, R[0]); cv.put(ex, y + ln + 3, R[2])


def frost_fern(cv, x, y, n, rnd, d=1., col=None):
    """A frost fern: a stem with paired, shrinking side shoots."""
    col = col or ICR[0]
    for i in range(n):
        sx, sy = x + int(round(d * i * .6)), y - i
        cv.put(sx, sy, col)
        if i % 2 == 1 and i < n - 1:
            ln = max(1, (n - i) // 2)
            for j in range(1, ln + 1): cv.put(sx - j, sy - j // 2, col); cv.put(sx + j, sy - j // 2, col)


def cloud_lump(cv, cx, cy, rx, ry, rnd, R=None, bumps=3, **kw):
    """A lumpy snow mass: an ellipse plus a few bulging lobes on its rim, shaded as one surface."""
    R = R or SNR; lobes = [(cx, cy, rx, ry)]
    for k in range(bumps):
        a = rnd.uniform(math.pi * 1.05, math.pi * 1.95); r = rnd.uniform(.35, .6)
        lobes.append((cx + math.cos(a) * rx * .8, cy + math.sin(a) * ry * .7, rx * r, ry * r))
    def inside(x, y): return any(((x + .5 - a) / c) ** 2 + ((y + .5 - b) / d) ** 2 <= 1 for a, b, c, d in lobes)
    nz = vnoise(rnd, 7)
    def nrm(x, y):
        a, b, c, d = min(lobes, key=lambda l: ((x - l[0]) / l[2]) ** 2 + ((y - l[1]) / l[3]) ** 2); return ell_n(a, b, c, d)(x, y)
    shade(cv, (int(cx - rx * 1.4), int(cy - ry * 1.6), int(cx + rx * 1.4), int(cy + ry * 1.2)), inside, nrm, R, bump=nz, bk=1.6, bias=kw.get("bias", -.5), bounce=1.1)


def wood(cv, x0, y0, x1, y1, rnd, vert=True, R=None, mask=None, grain=.7):
    """Rounded timber with grain streaks and a knot or two; lit on the top-left, dark on the bottom-right."""
    R = R or WD; n = vnoise(rnd, 6); w, h = x1 - x0, y1 - y0
    for y in range(y0, y1):
        for x in range(x0, x1):
            if mask and not mask(x, y): continue
            a = ((x - x0 + .5) / w) if vert else ((y - y0 + .5) / h)
            t = 0 if a < .12 else 1 if a < .3 else 2 if a < .56 else 3 if a < .84 else 4
            g = n(x * 2.6, y * .15) if vert else n(x * .17, y * 2.6)
            if g > .5 + (1 - grain) * .3 + .2: t = min(4, t + 1)
            elif g < .3 - (1 - grain) * .2: t = max(0, t - 1)
            cv.put(x, y, R[t])
    for _ in range((w * h) // 500 if w > 6 and h > 8 else 0):   # knots
        kx, ky = rnd.randint(x0 + 2, x1 - 3), rnd.randint(y0 + 3, y1 - 4)
        if mask and not mask(kx, ky): continue
        cv.put(kx, ky, R[4]); cv.put(kx + 1, ky, R[3]); cv.put(kx, ky + 1, R[3]); cv.put(kx - 1, ky - 1, R[2]); cv.put(kx + 1, ky + 1, R[0] if False else R[2])


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


def ball(cv, cx, cy, r, rnd, sq=1.0):
    """A hand-patted snowball: wobbly outline, lumpy surface, form shading, bounce light."""
    wob = [rnd.random() * 6.28 for _ in range(2)]; nz = vnoise(rnd, 6)
    def inside(x, y):
        nx = (x + .5 - cx) / r; ny = (y + .5 - cy) / (r * sq); a = math.atan2(ny, nx); lim = 1 + .045 * math.sin(3 * a + wob[0]) + .03 * math.sin(5 * a + wob[1])
        return nx * nx + ny * ny <= lim * lim
    shade(cv, (int(cx - r - 2), int(cy - r - 2), int(cx + r + 2), int(cy + r + 2)), inside, ell_n(cx, cy, r * 1.06, r * 1.06 * sq), SN, bump=lambda x, y: 2.4 * (nz(x, y) - .5),
          bk=1.7, bias=-.15, gain=4.0, bounce=1.3)
    for k in range(int(r / 3)):    # pats: lit lip of a thumb-pressed dent, cold shadow below it
        a = rnd.uniform(math.pi * .95, math.pi * 1.85); px = int(cx + math.cos(a) * r * rnd.uniform(.25, .7)); py = int(cy + math.sin(a) * r * rnd.uniform(.25, .7))
        for j in range(-2, 3): cv.put(px + j, py + abs(j) // 2, SN[0]) if cv.get(px + j, py + abs(j) // 2) in SN else None; cv.put(px + j, py + 1 + abs(j) // 2, SN[3]) if cv.get(px + j, py + 1 + abs(j) // 2) in SN else None


def twig(cv, x0, y0, x1, y1, rnd):
    n = int(max(abs(x1 - x0), abs(y1 - y0)))
    for i in range(n + 1):
        t = i / float(max(1, n)); x = int(round(x0 + (x1 - x0) * t)); y = int(round(y0 + (y1 - y0) * t + math.sin(t * 5) * 1.2))
        cv.put(x, y, WD[1] if i % 5 else WD[0]); cv.put(x, y + 1, WD[3])
        if i % 7 == 3: cv.put(x, y - 1, SN[0])
    d = 1 if x1 > x0 else -1; ex, ey = x1, y1 + int(math.sin(5) * 1.2)
    for s_ in (-1, 1):   # fingers
        for k in range(1, 5): cv.put(ex + d * k, ey + s_ * (k + 1) // 2 * 1 - (1 if y1 < y0 else 0) * 0, WD[2] if s_ < 0 else WD[3])


def snowman(cv, cx, base, s, rnd, hat, carrot_kind, scarf=None, mood=0):
    rb, rm, rh = int(15 * s), int(11.5 * s), int(8.5 * s)
    yb = base - rb; ym = yb - rb - rm + 5; yh = ym - rm - rh + 4
    ball(cv, cx, yb, rb, rnd, .98); ball(cv, cx, ym, rm, rnd); ball(cv, cx, yh, rh, rnd)
    for (ccx, ccy, cr, ang0) in ((cx, ym, rm, 0), (cx, yh, rh, 0)):   # the crease where each ball presses on the one beneath: a rim of cold shadow, dithered
        for i in range(int(cr * 5)):
            a = math.pi * (.08 + .84 * i / (cr * 5)); px = int(ccx + math.cos(a) * (cr + .6)); py = int(ccy + math.sin(a) * (cr + .6))
            if cv.get(px, py) in SN: cv.put(px, py, SN[4] if i % 3 else SN[3]); cv.put(px, py + 1, SN[3] if i % 2 else SN[2]) if cv.get(px, py + 1) in SN else None
    for i in range(3):   # coal buttons: lit chip, glint
        bxx = cx - 1 + (i % 2) * 0; byy = ym - 4 + i * int(rm * .55)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (-1, 0) if i == 1 else (0, 2)): cv.put(bxx + dx, byy + dy, COAL)
        cv.put(bxx, byy, ST[1])
    ad = (-1 if mood == 0 else 1 if mood == 2 else 0)   # twig arms: raised, level or drooping
    for d in (-1, 1):
        x0 = cx + d * (rm - 2); y0 = ym - 2
        twig(cv, x0, y0, x0 + d * int(18 * s), y0 + ad * int(7 * s) - (0 if ad else 1), rnd)
    for dx in (-rh // 2 - 1, rh // 2):    # eyes: coal, with a glint
        for i, j in ((0, 0), (1, 0), (0, 1), (1, 1)): cv.put(cx + dx + i, yh - 3 + j, COAL)
        cv.put(cx + dx, yh - 3, ST[2])
    my = yh + rh // 2 + 1   # mouth of pebbles
    if mood == 3:
        for dx, dy in ((0, 0), (1, 0), (-1, 1), (2, 1), (0, 2), (1, 2)): cv.put(cx + dx, my + dy + 1, COAL)
    else:
        for i in range(-3, 4):
            off = (1 if abs(i) > 1 else 0) * (-1 if mood in (0, 1) else 1) + (1 if mood == 1 and i > 1 else 0)
            cv.put(cx + i, my + off, COAL); cv.put(cx + i, my + off + 1, COAL) if abs(i) < 2 else None
    ks = max(1, int(s * 1.2))
    CAR = [mix(GD[0], EM[0], .5), CARROT[0], CARROT[1], CARROT[2], EM[2]]
    nx_, ny_ = cx + 1, yh + 1
    if carrot_kind == "long": tube(cv, (nx_, ny_), (nx_ + int(26 * s), ny_ + 2), 4, 1, CAR)
    elif carrot_kind == "tiny": tube(cv, (nx_, ny_), (nx_ + 6, ny_ + 1), 3, 1, CAR)
    elif carrot_kind == "up":
        tube(cv, (nx_, ny_ + 1), (nx_ + int(12 * s), ny_ + 1), 4, 3, CAR); tube(cv, (nx_ + int(12 * s), ny_ + 1), (nx_ + int(20 * s), ny_ - 9), 4, 1, CAR)
    elif carrot_kind == "fat": tube(cv, (nx_, ny_ + 1), (nx_ + int(14 * s), ny_ + 3), 7, 1, CAR)
    elif carrot_kind == "two":
        tube(cv, (nx_, ny_), (nx_ + int(14 * s), ny_ - 4), 3, 1, CAR); tube(cv, (nx_, ny_ + 2), (nx_ + int(14 * s), ny_ + 6), 3, 1, CAR)
    elif carrot_kind == "side": tube(cv, (nx_ - 3, ny_ + 1), (nx_ - 3 - int(18 * s), ny_ + 3), 4, 1, CAR)
    for x in range(nx_, nx_ + 4): cv.put(x, ny_ - 1, SN[3]) if carrot_kind != "side" and cv.get(x, ny_ - 1) in SN else None
    if scarf:
        SC = [mix(scarf, CREAM, .45), scarf, darker(scarf, 1), mix(scarf, INK, .35)]
        for x in range(cx - rh + 1, cx + rh):
            dx = (x - cx) / float(rh); y0 = yh + rh - 2 + int(3 * (1 - dx * dx)) - 1
            for k in range(4): cv.put(x, y0 + k, SC[k] if (x // 3) % 2 == 0 else SC[min(3, k + 1)])
        for k in range(14):
            for j in range(4): cv.put(cx + rh - 6 + j + k // 7, yh + rh + 3 + k, SC[j] if (k // 3) % 2 == 0 else SC[min(3, j + 1)])
        for j in range(4): cv.put(cx + rh - 5 + j * 1, yh + rh + 17, SC[1]) if j % 2 == 0 else None
    top = yh - rh
    if hat == "top":
        hw_ = int(rh * .62); tube(cv, (cx, top - 13), (cx, top + 1), 2 * hw_, 2 * hw_, ST)
        for x in range(cx - hw_, cx + hw_): cv.put(x, top - 2, PT[1] if x > cx - hw_ + 1 else PT[0]); cv.put(x, top - 1, PT[2]); cv.put(x, top, PT[3])
        lump(cv, cx, top + 2, rh + 3, 2, ST, rnd, 0)
        for x in range(cx - hw_ + 1, cx - 1): cv.put(x, top - 12, ST[0]) if x % 2 else None
    elif hat == "bobble":
        lump(cv, cx, top + 1, rh + 1, 7, PT, rnd, 0)
        for x in range(cx - rh + 2, cx + rh - 1, 3):
            for y in range(top - 4, top + 5):
                if cv.get(x, y) in PT: cv.put(x, y, PT[min(4, PT.index(cv.get(x, y)) + 1)])
        for x in range(cx - rh - 1, cx + rh + 2):
            for k in range(3): cv.put(x, top + 5 + k, SN[0] if k == 0 else SN[1] if k == 1 else SN[3]) if (x + k) % 4 else None
        ball(cv, cx, top - 6, 4, rnd)
    elif hat == "pot":
        tube(cv, (cx, top - 6), (cx, top + 2), int(rh * 1.3), int(rh * 1.3), ST)
        lump(cv, cx, top - 6, int(rh * .65), 2, ST, rnd, 0)
        for k in range(4): cv.put(cx - 2 + k, top - 9, ST[3]); cv.put(cx - 2 + k, top - 8, ST[2])
        cv.put(cx - 1, top - 9, ST[0]); cv.put(cx - rh - 1, top - 2, ST[4]); cv.put(cx - rh - 2, top - 1, ST[4]); cv.put(cx + rh, top - 2, ST[4]); cv.put(cx + rh + 1, top - 1, ST[4])
        for x in range(cx - int(rh * .6), cx + int(rh * .6), 2): cv.put(x, top + 1, ST[4])
    elif hat == "bucket":
        for y in range(top - 8, top + 5):
            hw = rh - 3 + (y - top + 8) // 3
            for x in range(cx - hw, cx + hw + 1):
                u = (x - (cx - hw)) / float(2 * hw); cv.put(x, y, WD[1] if u < .2 else WD[2] if u < .55 else WD[3] if u < .85 else WD[4])
        for y in (top - 4, top + 1):
            for x in range(cx - rh - 1, cx + rh + 3): cv.put(x, y, ST[2] if x < cx + 2 else ST[3]); cv.put(x, y + 1, ST[1] if x < cx - 4 else ST[3]) if 0 else None
        lump(cv, cx, top - 8, rh - 2, 2, WD, rnd, 0); cv.put(cx - 3, top - 8, SN[0]); cv.put(cx - 2, top - 8, SN[1])
    elif hat == "none":
        for k in range(3):
            px = cx - 4 + k * 4
            for j in range(4): cv.put(px + (k - 1) * (j // 2), top - j + 1, WD[2] if j % 2 else WD[1])
    return (cx, yb, rb)


def lm_snowmen(rnd, cv):   # 290 x 190
    H_ = 184; nB = vnoise(rnd, 7)
    fl = lambda x, y: 6 <= x <= 284 and H_ - 8 + int(2 * math.sin(x * .1) + (nB(x, 1) - .5) * 3) <= y <= H_ + 1 - (1 if (x * 7) % 9 < 2 else 0)
    shade(cv, (4, H_ - 14, 286, H_ + 3), fl, lambda x, y: (.03, -.92, .39), SN, bump=lambda x, y: 2 * (nB(x, y) - .5) + 1.4 * math.sin(x * .3 + y * .8 + 3 * nB(x * .5, y * .5)), bk=1.2, bias=-.1, gain=3.0)
    smen = ((40, 1.3, "top", "long", PT[1], 0), (98, 1.1, "bobble", "tiny", None, 3), (152, 1.55, "none", "up", EM[1], 0), (210, 1.15, "bucket", "fat", SE[1], 1), (255, 1.35, "pot", "side", None, 2))
    for (x, s, *_) in smen:     # long cold shadows thrown to the right across the trodden snow
        for yy in range(H_ - 6, H_ + 1):
            for xx in range(x, x + int(34 * s)):
                if fl(xx, yy) and ((xx - x - 6) / (30. * s)) ** 2 + ((yy - H_ + 2) / 4.) ** 2 <= 1 and (_BAY[yy & 3][xx & 3] + .5) / 16 < .85: cv.put(xx, yy, SN[3] if (xx + yy) % 5 else SN[4])
    for (x, s, hat, ck, sc, mood) in smen: snowman(cv, x, H_ - 2, s, rnd, hat, ck, sc, mood)
    for i, (fx, n) in enumerate(((68, 4), (125, 3), (182, 5), (232, 2))):    # tiny rating flags on sticks, scored in coal dots
        wood(cv, fx, H_ - 20, fx + 2, H_ - 1, rnd, True, WD, grain=.5)
        for dx in range(8):
            for dy in range(6):
                wv = int(math.sin((dx + i) * .8) * 1)
                cv.put(fx + 2 + dx, H_ - 20 + dy + wv, GD[0] if dy < 2 else GD[1] if dy < 4 else GD[2])
        for k in range(n): cv.put(fx + 3 + k, H_ - 18 + (k % 2) + int(math.sin((k + 1 + i) * .8)), COAL)
        cv.put(fx + 1, H_ - 21, WD[0]); cloud_lump(cv, fx + 1, H_ - 1, 5, 2, rnd, bumps=1, bias=-.5)
    for x, y in ((18, H_ - 3), (64, H_ - 2), (124, H_ - 1), (180, H_ - 3), (234, H_ - 2), (276, H_ - 3)): fprint(cv, x, y - 2, 0, 1 if x % 2 else -1)
    for x, y in ((26, 166), (270, 160), (150, 90)): pass
    tuft(cv, 12, H_ - 3, rnd, 4, 6); tuft(cv, 280, H_ - 2, rnd, 3, 5)
    for k in range(8): glint(cv, 20 + k * 34, H_ - 6 + (k * 3) % 5, 0)


def stalag(cv, x, y, h, w, rnd, R=None):
    """Ice stalagmite rising from y (mirror of icicle2: lit left flank, cool right flank, bright tip)."""
    R = R or ICR
    for i in range(h):
        f = i / h; hw = max(0, int(round(w / 2 * (1 - f) ** .8 + (1 if 0 < f < .6 and rnd.random() < .25 else 0))))
        for k in range(-hw, hw + 1):
            u = (k + hw) / max(1, 2 * hw); t = 1 if u < .34 else 2 if u < .62 else 3 if u < .86 else 4
            if hw == 0: t = 1
            if k == -hw and hw > 1: t = 0
            cv.put(x + k, y - i, R[t])
    cv.put(x, y - h, R[0])


def stalag(cv, x, y, h, w, rnd, R=None):
    """Ice stalagmite rising from y (mirror of icicle2: lit left flank, cool right flank, bright tip)."""
    R = R or ICR
    for i in range(h):
        f = i / h; hw = max(0, int(round(w / 2 * (1 - f) ** .8 + (1 if 0 < f < .6 and rnd.random() < .25 else 0))))
        for k in range(-hw, hw + 1):
            u = (k + hw) / max(1, 2 * hw); t = 1 if u < .34 else 2 if u < .62 else 3 if u < .86 else 4
            if hw == 0: t = 1
            if k == -hw and hw > 1: t = 0
            cv.put(x + k, y - i, R[t])
    cv.put(x, y - h, R[0])


def stalag(cv, x, y, h, w, rnd, R=None):
    """Ice stalagmite rising from y (mirror of icicle2: lit left flank, cool right flank, bright tip)."""
    R = R or ICR
    for i in range(h):
        f = i / h; hw = max(0, int(round(w / 2 * (1 - f) ** .8 + (1 if 0 < f < .6 and rnd.random() < .25 else 0))))
        for k in range(-hw, hw + 1):
            u = (k + hw) / max(1, 2 * hw); t = 1 if u < .34 else 2 if u < .62 else 3 if u < .86 else 4
            if hw == 0: t = 1
            if k == -hw and hw > 1: t = 0
            cv.put(x + k, y - i, R[t])
    cv.put(x, y - h, R[0])


def stalag(cv, x, y, h, w, rnd, R=None):
    """Ice stalagmite rising from y (mirror of icicle2: lit left flank, cool right flank, bright tip)."""
    R = R or ICR
    for i in range(h):
        f = i / h; hw = max(0, int(round(w / 2 * (1 - f) ** .8 + (1 if 0 < f < .6 and rnd.random() < .25 else 0))))
        for k in range(-hw, hw + 1):
            u = (k + hw) / max(1, 2 * hw); t = 1 if u < .34 else 2 if u < .62 else 3 if u < .86 else 4
            if hw == 0: t = 1
            if k == -hw and hw > 1: t = 0
            cv.put(x + k, y - i, R[t])
    cv.put(x, y - h, R[0])


def lm_icecave(rnd, cv):   # 270 x 226
    B = 218; cx = 135; RX = 128; RY = 176
    n1, n2 = vnoise(rnd, 20), vnoise(rnd, 7)
    def top(x):
        dx = min(abs(x - cx), RX - .01); return B - RY * math.sqrt(max(0., 1 - (dx / RX) ** 2)) + (n1(x, 7) - .5) * 14 * (1 - (dx / RX) ** 4) + (n2(x, 2) - .5) * 3
    tp = {x: top(x) for x in range(270)}
    def inside(x, y): return abs(x - cx) <= RX and tp[x] <= y <= B + 1
    capn = vnoise(rnd, 16)
    def capy(x): return tp[x] + 68 + 7 * math.sin(x * .12) + (capn(x, 5) - .5) * 22
    mx0, mx1, mt, mb, MC = 74, 198, 126, 212, 136
    def archtop(x): return mt + 26 * ((x - MC) / 62.) ** 2
    # ice facets: a voronoi of tilted planes, some cells holding refracted colour
    seeds = []
    for _ in range(70):
        x, y = rnd.randint(8, 262), rnd.randint(70, 215)
        seeds.append((x, y, rnd.uniform(-.5, .5), rnd.uniform(-.4, .4), rnd.choice((0, 0, 0, 1, 2, 3))))
    cell = {}; edge = {}
    for y in range(60, B + 2):
        for x in range(8, 263):
            if not inside(x, y): continue
            d = sorted(((x - s[0]) ** 2 * .8 + (y - s[1]) ** 2 * 1.3, i) for i, s in enumerate(seeds)) if False else None
            best = (1e9, -1); second = (1e9, -1)
            for i, s in enumerate(seeds):
                dd = math.sqrt((x - s[0]) ** 2 * .85 + (y - s[1]) ** 2 * 1.25)
                if dd < best[0]: second = best; best = (dd, i)
                elif dd < second[0]: second = (dd, i)
            cell[(x, y)] = best[1]
            if second[0] - best[0] < 1.3: edge[(x, y)] = second[1]
    dome = ell_n(cx, B, RX + 4, RY + 4)
    def is_cap(x, y): return y < capy(x)
    def bump(x, y): return 5 * (n1(x, y) - .5) + 1.5 * (n2(x, y) - .5) + (.9 * math.sin(y / 3.4 + x * .035 + 6 * n1(x * .6, y * .6)) if is_cap(x, y) else 0)
    def nrm(x, y):
        nx, ny, nz = dome(x, y)
        if not is_cap(x, y) and (x, y) in cell:
            s = seeds[cell[(x, y)]]; nx += s[2]; ny += s[3]; l = math.sqrt(nx * nx + ny * ny + nz * nz); return nx / l, ny / l, nz / l
        return nx, ny, nz
    tints = [None, SE[1], DU[1], PT[0]]
    def pick(x, y, lvl):
        if is_cap(x, y):
            if capy(x) - y < 3 and (x, y) not in edge: lvl += 1.3 - (capy(x) - y) * .2       # the cap's overhanging lip falls into shadow
            return quant(SN, lvl - .3, x, y)
        c = quant(IC, lvl + 1.5, x, y)
        if (x, y) in edge:
            s = seeds[edge[(x, y)]]; me = seeds[cell[(x, y)]]
            return IC[0] if (s[0] - me[0]) + (s[1] - me[1]) < 0 else IC[4] if lvl > 2.2 else IC[3]
        t = tints[seeds[cell[(x, y)]][4]] if (x, y) in cell else None
        return mix(c, t, .26) if t else c
    shade(cv, (0, 20, 270, B + 2), inside, nrm, IC, bump=bump, bk=2.0, bias=-.25, gain=3.9, bounce=1.0, pick=pick)
    for x in range(8, 263):    # overhanging lip of the snow cap: a lit roll, a cold shadow tucked under it
        if not inside(x, int(capy(x)) + 2): continue
        y = int(capy(x)); cv.put(x, y, SN[0] if x < cx + 30 else SN[1]); cv.put(x, y + 1, IC[3] if (x + y) % 2 else IC[2]); cv.put(x, y + 2, IC[3] if x % 3 else IC[4]) if cv.get(x, y + 2) in IC else None
    # --- the mouth: dark cave, glow welling up from far inside
    GL = [H("#1b1340"), H("#251a4e"), DU[4], DU[3], mix(DU[3], DU[2], .55), DU[2], mix(DU[2], SE[1], .5), SE[1], SE[0], mix(SE[0], CREAM, .5)]
    def mouth(x, y): return mx0 <= x <= mx1 and archtop(x) <= y <= mb - 3 * (1 - abs((x - MC) / 64.) ** 2) + 1
    def mnrm(x, y): return (0, 0, 1)
    for y in range(mt, mb + 2):
        for x in range(mx0, mx1 + 1):
            if not mouth(x, y): continue
            d = math.hypot((x - MC) / 66., (y - 196) / 56.); lvl = 10.5 * max(0., 1 - d) ** 1.1 - (1.0 if y < 160 else 0)
            lvl += (n2(x, y) - .5) * 1.2
            cv.put(x, y, quant(GL, lvl, x, y, .7))
    for k in range(40):    # god-rays of the glow slanting up through the dark
        x = rnd.randint(mx0 + 10, mx1 - 10); y = rnd.randint(150, 200)
        if mouth(x, y) and cv.get(x, y) in GL[:5]: cv.put(x, y, GL[5 if y > 176 else 4])
    # back wall: dark teeth, further in, picked out by the glow
    for i, x in enumerate(range(mx0 + 10, mx1 - 6, 11)):
        y0 = int(archtop(x)) + 4; icicle2(cv, x + (i % 2) * 2, y0, 12 + (i * 5) % 9, 5, rnd, [mix(c, DU[3], .55) for c in IC], bead=False)
    for i, x in enumerate(range(mx0 + 14, mx1 - 10, 13)):
        stalag(cv, x + (i % 3), mb - 8, 7 + (i * 7) % 8, 6, rnd, [mix(c, DU[3], .5) for c in IC])
    for ex in (112, 150):    # it is polite: two round eyes in the dark, a little brow of frost above each
        for dx in range(-3, 4):
            for dy in range(-4, 5):
                if (dx / 3.4) ** 2 + (dy / 4.4) ** 2 <= 1: cv.put(ex + dx, 180 + dy, CREAM if dx < 1 else SN[2])
        for dx in range(-1, 3):
            for dy in range(-1, 4): cv.put(ex + dx, 181 + dy, COAL)
        cv.put(ex - 1, 179, WHITE); cv.put(ex, 174, SN[3]); cv.put(ex + 1, 174, SN[3])
    # floor of snow spilling out of the mouth, with a trail of prints going in
    cloud_lump(cv, MC, mb + 1, 70, 7, rnd, bumps=2, bias=-.4)
    for i in range(6):
        x = MC - 12 + (i % 2) * 9 - i; y = mb + 4 - i * 2
        if y > mb - 8: fprint(cv, x, y - 3, 0 if i > 2 else 1, 1 if i % 2 else -1)
    for i, x in enumerate(range(mx0 + 18, mx1 - 12, 14)):   # stalagmite teeth rising from the floor, lit left
        stalag(cv, x + (i * 3) % 5, mb - 2, 9 + (i * 5) % 13, 8, rnd)
    # thick snow rim rolled over the arch
    for y in range(mt - 12, mb):
        for x in range(mx0 - 9, mx1 + 10):
            nx = (x - MC) / 62.; at = archtop(x)
            ring = (at - 9 < y < at + 1 and abs(nx) < 1.05) 
            if not ring or not inside(x, y): continue
            dd = at - y if abs(nx) < 1.05 else (mx0 - x if x < MC else x - mx1)
            lvl = .6 + nx * 1.7 + (1 - min(9., abs(dd)) / 9.) * 1.5 + (n2(x, y) - .5) * 1.0
            cv.put(x, y, quant(SN, lvl, x, y))
    for x in range(mx0 - 6, mx1 + 7):     # under-lip shade of the rim where it meets the dark
        y = int(archtop(x)) + 1
        if mouth(x, y + 1): cv.put(x, y, IC[3] if x % 2 else SN[3]); cv.put(x, y + 1, IC[4])
    # the big icicle teeth along the lip: tallest at the middle, lean in, lengths all different
    for i, x in enumerate(range(mx0 + 4, mx1 - 2, 8)):
        nx = (x - MC) / 62.; y0 = int(archtop(x)) + 1
        ln = int(14 + 34 * (1 - abs(nx)) ** 1.2 + (i * 11) % 9 - (6 if i % 4 == 2 else 0)); w = 8 if i % 3 else 10
        icicle2(cv, x, y0, ln, w, rnd, lean=-nx * 1.5, hollow=(ln > 34))
    # frost: ferns creeping over the facets, crystal stars, crust cracks and sastrugi on the cap
    for (x, y, n, d) in ((40, 196, 12, .4), (52, 180, 9, -.5), (222, 184, 12, -.4), (212, 168, 8, .5), (30, 150, 8, 0), (236, 150, 9, -.3), (98, 118, 7, 0), (182, 112, 8, 0)):
        frost_fern(cv, x, y, n, rnd, d, ICR[0] if y > 140 else SN[3])
    for (x, y, n) in ((60, 70, 24), (140, 54, 28), (178, 78, 20), (100, 92, 26), (200, 100, 24), (76, 108, 18)): crack(cv, x, y, n, rnd, 1., .25, only=SN)
    for (x, y, ln) in ((84, 54, 22), (150, 44, 24), (196, 62, 20), (58, 88, 22), (130, 78, 26), (176, 92, 20)): sastr(cv, x, y, ln, rnd, .7, .1)
    # drifts spilling round the base, a tuft, a sprig, a buried stone
    for (x, y, rx, ry) in ((22, B - 4, 24, 8), (248, B - 4, 24, 8), (82, B + 1, 22, 5), (192, B + 1, 22, 5)): cloud_lump(cv, x, y, rx, ry, rnd, bumps=2, bias=-.4)
    lump(cv, 34, B - 10, 10, 6, ST, rnd, .12); cloud_lump(cv, 33, B - 15, 8, 3, rnd, bumps=1, bias=-.7)
    tuft(cv, 56, B - 1, rnd, 5, 7); tuft(cv, 225, B - 2, rnd, 4, 6); sprig(cv, 244, B - 8, rnd, -1, 11)
    for x, y in ((64, 140), (100, 190), (170, 100), (210, 140), (124, 64), (160, 150), (80, 172), (240, 190), (230, 118)): glint(cv, x, y, 0)
    for x, y in ((110, 108), (200, 172), (54, 164), (150, 90)): glint(cv, x, y, 1)


def bubble(cv, x, y, r):
    """A trapped air bubble: bright rim on the top-left, cool rim bottom-right, a clear belly with a glint."""
    for dy in range(-r - 1, r + 2):
        for dx in range(-r - 1, r + 2):
            d = math.hypot(dx + .0, dy + .0)
            if d > r + .6: continue
            c = cv.get(x + dx, y + dy)
            if not c[3]: continue
            if d > r - .9: cv.put(x + dx, y + dy, WHITE if dx + dy < -r * .5 else mix(c, IC[0], .55) if dx + dy < r * .6 else mix(c, IC[4], .5))
            else: cv.put(x + dx, y + dy, mix(c, IC[0], .28))
    if r >= 3: cv.put(x - r // 2, y - r // 2, WHITE)


def fracture(cv, x, y, n, rnd, dx=.4, dy=1., br=.14):
    """A crack deep in the ice: bright line, cold shadow pixel beside it, forking."""
    fx, fy = float(x), float(y)
    for i in range(n):
        fx += dx + rnd.uniform(-.8, .8); fy += dy + rnd.uniform(-.4, .5); px, py = int(fx), int(fy)
        if not cv.get(px, py)[3]: break
        cv.put(px, py, IC[0] if i % 5 else WHITE); cv.put(px + 1, py, mix(cv.get(px + 1, py), IC[4], .55)) if cv.get(px + 1, py)[3] else None
        if rnd.random() < br and n - i > 5: fracture(cv, px, py, (n - i) // 2, rnd, dx + rnd.choice((-1.1, 1.1)), dy * .6, 0)


def bubble(cv, x, y, r):
    """A trapped air bubble: bright rim on the top-left, cool rim bottom-right, a clear belly with a glint."""
    for dy in range(-r - 1, r + 2):
        for dx in range(-r - 1, r + 2):
            d = math.hypot(dx + .0, dy + .0)
            if d > r + .6: continue
            c = cv.get(x + dx, y + dy)
            if not c[3]: continue
            if d > r - .9: cv.put(x + dx, y + dy, WHITE if dx + dy < -r * .5 else mix(c, IC[0], .55) if dx + dy < r * .6 else mix(c, IC[4], .5))
            else: cv.put(x + dx, y + dy, mix(c, IC[0], .28))
    if r >= 3: cv.put(x - r // 2, y - r // 2, WHITE)


def fracture(cv, x, y, n, rnd, dx=.4, dy=1., br=.14):
    """A crack deep in the ice: bright line, cold shadow pixel beside it, forking."""
    fx, fy = float(x), float(y)
    for i in range(n):
        fx += dx + rnd.uniform(-.8, .8); fy += dy + rnd.uniform(-.4, .5); px, py = int(fx), int(fy)
        if not cv.get(px, py)[3]: break
        cv.put(px, py, IC[0] if i % 5 else WHITE); cv.put(px + 1, py, mix(cv.get(px + 1, py), IC[4], .55)) if cv.get(px + 1, py)[3] else None
        if rnd.random() < br and n - i > 5: fracture(cv, px, py, (n - i) // 2, rnd, dx + rnd.choice((-1.1, 1.1)), dy * .6, 0)


def bubble(cv, x, y, r):
    """A trapped air bubble: bright rim on the top-left, cool rim bottom-right, a clear belly with a glint."""
    for dy in range(-r - 1, r + 2):
        for dx in range(-r - 1, r + 2):
            d = math.hypot(dx + .0, dy + .0)
            if d > r + .6: continue
            c = cv.get(x + dx, y + dy)
            if not c[3]: continue
            if d > r - .9: cv.put(x + dx, y + dy, WHITE if dx + dy < -r * .5 else mix(c, IC[0], .55) if dx + dy < r * .6 else mix(c, IC[4], .5))
            else: cv.put(x + dx, y + dy, mix(c, IC[0], .28))
    if r >= 3: cv.put(x - r // 2, y - r // 2, WHITE)


def fracture(cv, x, y, n, rnd, dx=.4, dy=1., br=.14):
    """A crack deep in the ice: bright line, cold shadow pixel beside it, forking."""
    fx, fy = float(x), float(y)
    for i in range(n):
        fx += dx + rnd.uniform(-.8, .8); fy += dy + rnd.uniform(-.4, .5); px, py = int(fx), int(fy)
        if not cv.get(px, py)[3]: break
        cv.put(px, py, IC[0] if i % 5 else WHITE); cv.put(px + 1, py, mix(cv.get(px + 1, py), IC[4], .55)) if cv.get(px + 1, py)[3] else None
        if rnd.random() < br and n - i > 5: fracture(cv, px, py, (n - i) // 2, rnd, dx + rnd.choice((-1.1, 1.1)), dy * .6, 0)


def lm_auroraledge(rnd, cv):   # 260 x 176
    X0, X1, FT, FB = 20, 230, 64, 142; DX = 18; TY = 28
    nA, nB = vnoise(rnd, 20), vnoise(rnd, 6)
    AUR = [SE, MO, PT, SE]
    def hue(x, y):
        v = (x + y * .8 + 14 * nA(x, y)) / 38.; i = int(math.floor(v)); f = v - i; th = (_BAY[int(y) & 3][int(x) & 3] + .5) / 16
        if f > .66 and (f - .66) / .34 > th: i += 1
        elif f < .3 and (.3 - f) / .3 > th: i -= 1
        return AUR[i % 4], (v % 1)
    def caustic(x, y): return max(0., math.sin((x * .62 - y * .34) / 8.5 + 3 * nA(x * .5, y * .5))) ** 5
    front = lambda x, y: X0 <= x <= X1 and FT <= y < FB - (1 if x < X0 + 2 or x > X1 - 2 else 0)
    # front face: thick clear ice, the aurora showing through it in soft diagonal bands
    for y in range(FT, FB):
        for x in range(X0, X1 + 1):
            if not front(x, y): continue
            h_, _ = hue(x, y); d = (y - FT) / float(FB - FT)
            lvl = .4 + 2.7 * d - 1.1 * caustic(x, y) + (nB(x, y) - .5) * 1.1
            c = quant(h_, lvl, x, y, .6); ci = quant(IC, lvl + .2, x, y, .6)
            cv.put(x, y, mix(c, ci, .16 + .16 * d))
    for k in range(5):     # strata: faint frozen layers running across the slab, broken into dashes
        base = FT + 14 + k * 14 + rnd.randint(-2, 2)
        for x in range(X0 + 3, X1 - 3):
            y = base + int(2 * math.sin(x * .05 + k) + 2 * (nA(x, k * 9) - .5))
            if (x * 7 + k * 3) % 13 < 8 and front(x, y): cv.put(x, y, mix(cv.get(x, y), IC[0], .3))
    for x in range(X0, X1 + 1):     # chamfers: bright top lip, lit left edge, bounce light above a dark foot
        for y, c, a in ((FT, ICR[0], 1.), (FT + 1, IC[0], .45)): cv.put(x, y, mix(cv.get(x, y), c, a)) if front(x, y) else None
        if x % 2 == 0: cv.put(x, FB - 5, mix(cv.get(x, FB - 5), IC[0], .4))
        cv.put(x, FB - 3, mix(cv.get(x, FB - 3), IC[4], .5)); cv.put(x, FB - 2, IC[4]); cv.put(x, FB - 1, mix(IC[4], DU[3], .5))
    for y in range(FT, FB - 1):
        cv.put(X0, y, IC[0]); cv.put(X0 + 1, y, mix(cv.get(X0 + 1, y), IC[0], .5)); cv.put(X1, y, mix(cv.get(X1, y), IC[4], .5)); cv.put(X1 - 1, y, mix(cv.get(X1 - 1, y), IC[3], .3))
    # right-hand side face (thickness seen at an angle) darker and bluer
    side = [(X1 + 1, FT), (X1 + DX, TY), (X1 + DX, FB - 15), (X1 + 1, FB - 1)]; ms = _mask(cv.w, cv.h, side)
    for y in range(TY, FB):
        for x in range(X1, X1 + DX + 2):
            if not ms[x, y]: continue
            u = (x - X1) / float(DX); h_, _ = hue(x - 90, y + 30); d = (y - TY) / float(FB - TY)
            lvl = 2.1 + 1.4 * u + .9 * d - .8 * caustic(x * 2, y)
            cv.put(x, y, mix(quant(h_, lvl, x, y, .6), quant(IC, lvl + .3, x, y, .6), .55))
    for y in range(TY, FB - 14): cv.put(X1 + DX, y, IC[4])
    # top face: polished ice with sky reflected in it, a snow rim at the back
    top = [(X0 + 30, TY), (X1 + DX, TY), (X1, FT), (X0, FT)]; mt = _mask(cv.w, cv.h, top)
    for y in range(TY, FT + 1):
        for x in range(X0, X1 + DX + 1):
            if not mt[x, y] or front(x, y) and y > FT: continue
            d = (y - TY) / float(FT - TY); h_, _ = hue(x * 1.3, y * 2.2)
            lvl = 1.4 - 1.1 * d + (nB(x, y * 2) - .5) * 1.3 + .5 * caustic(x * 1.2, y * 3)
            cv.put(x, y, mix(quant(IC, lvl, x, y, .6), quant(h_, 1.4 + 1.2 * d, x, y, .6), .3 + .15 * (1 - d)))
    for k in range(7):      # long polished streaks on the top face
        x = rnd.randint(X0 + 20, X1 - 40); y = rnd.randint(TY + 5, FT - 4)
        for j in range(rnd.randint(14, 30)):
            if mt[min(cv.w - 1, x + j), y]: cv.put(x + j, y, WHITE if j % 4 else IC[0])
    for x in range(X0 + 30, X1 + DX): cv.put(x, TY, IC[0]) if mt[x, TY] else None
    for y in range(TY, FT): cv.put(X0 + 30 - int((y - TY) * 30 / (FT - TY)), y, IC[0])
    # bubbles, a rising string of them, cracks and glints inside the ice
    for (x, y, r) in ((50, 96, 4), (92, 116, 3), (140, 88, 5), (176, 122, 3), (206, 100, 4), (74, 128, 2), (118, 124, 2), (162, 76, 2), (36, 114, 3), (190, 80, 2)): bubble(cv, x, y, r)
    for k in range(6): bubble(cv, 112 + (k % 2), 134 - k * 6, 1 if k % 3 else 2)
    for (x, y, n, d) in ((70, FT + 1, 30, .5), (180, FT + 2, 26, -.4), (130, FB - 3, 22, -.3)): fracture(cv, x, y, n, rnd, d, 1. if y < FT + 5 else -1.)
    for (x, y) in ((44, 80), (150, 104), (214, 114), (96, 84), (60, 130), (188, 74), (230, 90), (126, 70)): glint(cv, x, y, 1 if x % 2 else 0)
    # blown snow on the back rim, and a frost fringe of icicles hanging from the front lip
    cloud_lump(cv, 128, TY - 1, 62, 5, rnd, bumps=3, bias=-.5); cloud_lump(cv, 60, TY + 1, 24, 4, rnd, bumps=1, bias=-.4); cloud_lump(cv, 214, TY + 2, 18, 4, rnd, bumps=1, bias=-.4)
    for i, x in enumerate(range(X0 + 6, X1 - 4, 11)): icicle2(cv, x + (i * 3) % 4, FT + 2, 7 + (i * 7) % 12, 5, rnd, bead=(i % 3 == 0))
    # snowbanks at the foot, tinted pink and green by the light coming through the slab
    for (x, y, rx, ry) in ((38, 152, 32, 12), (214, 154, 34, 12), (128, 164, 56, 8), (82, 160, 20, 6), (176, 163, 22, 6)): cloud_lump(cv, x, y, rx, ry, rnd, bumps=2, bias=-.3)
    for y in range(FB, 176):
        for x in range(4, 256):
            c = cv.get(x, y)
            if c in SN and X0 - 14 < x < X1 + DX + 8:
                h_, _ = hue(x - 10, y * 1.5); f = 1 - (y - FB) / 28.
                if f > 0 and (_BAY[y & 3][x & 3] + .5) / 16 < f * .9: cv.put(x, y, mix(c, h_[1 if c in SN[:2] else 2], .38))
    tuft(cv, 14, 164, rnd, 4, 6); sprig(cv, 236, 166, rnd, -1, 10); lump(cv, 246, 160, 8, 5, ST, rnd, .12); cloud_lump(cv, 246, 157, 7, 2, rnd, bumps=1, bias=-.7)
    for (x, y) in ((90, 12), (170, 16), (200, 6), (30, 20), (240, 20)): glint(cv, x, y, 2) if x % 20 == 0 else gen2.sparkle(cv, x, y, False)


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
    nA, nB = vnoise(rnd, 13), vnoise(rnd, 6)
    D = [dict(x0=0, xp=121, x1=156, yp=70, yb=B - 10, bias=.35), dict(x0=204, xp=300, x1=338, yp=84, yb=B - 3, bias=.35), dict(x0=96, xp=146, x1=248, yp=36, yb=B - 6, bias=-.05)]
    def mk(d):
        x0, xp, x1, yp, yb = d["x0"], d["xp"], d["x1"], d["yp"], d["yb"]
        def pr(x):
            if x <= xp: u = (xp - x) / float(xp - x0); y = yp + (yb - yp) * u ** 1.25
            else: v = (x - xp) / float(x1 - xp); y = yp + (yb - yp) * v ** .85
            m = min(1., abs(x - xp) / 18.); return y + (nA(x, d["yp"]) - .5) * 9 * m + (nB(x, 3) - .5) * 2.5 * m - (3 * (1 - m) ** 2)
        d["top"] = {x: pr(x) for x in range(max(0, x0), min(340, x1 + 1))}
    for d in D: mk(d)
    for d in D:
        top, xp, yp, yb = d["top"], d["xp"], d["yp"], d["yb"]
        def inside(x, y, top=top, yb=yb): return x in top and top[x] <= y <= yb
        def nrm(x, y, top=top, xp=xp, yp=yp, yb=yb):
            s = (top.get(x + 2, top[x]) - top.get(x - 2, top[x])) / 4.; dep = min(1., (y - top[x]) / max(1., yb - yp))
            nx = max(-.92, min(.92, s * .72)) * (1 - .55 * dep); ny = -.3 - .55 * dep - abs(nx) * .15
            return nx, ny, math.sqrt(max(.02, 1 - nx * nx - ny * ny))
        def bump(x, y, top=top):
            tx = top.get(x, top[min(top, key=lambda q: abs(q - x))]); return 1.5 * math.sin((y - tx) / 5.2 + 4 * nA(x * .7, y * .7)) * min(1., (y - tx) / 12.) + 3 * (nA(x, y) - .5)
        shade(cv, (d["x0"], yp - 6, d["x1"], yb), inside, nrm, SNR, bump=bump, bk=1.4, bias=d["bias"] - .1, gain=4.0, bounce=1.0)
        for x in range(d["x0"], d["x1"] + 1):     # lit crest line, one pixel of wind-polished edge
            if x in top and abs(x - xp) > 2: cv.put(x, int(top[x]), SN[0]); cv.put(x, int(top[x]) + 1, SN[1]) if x < xp else None
    # cornices: the wind has curled each crest over to leeward, with a hollow of blue shade undercut beneath
    for (x, y, w) in ((150, 38, 9), (302, 85, 8), (123, 71, 7)):
        cloud_lump(cv, x, y + 2, w, 5, rnd, bumps=2, bias=-.5)
        for k in range(-w + 2, w - 3):
            yy = y + 7 - int((k / float(w)) ** 2 * 3); cv.put(x + k, yy, SN[3] if k % 2 else SN[4]); cv.put(x + k, yy + 1, SN[2]) if k % 3 else None
    # scoops carved by the wind in long lit arcs, sastrugi, crust cracks
    for (x0, y0, ln) in ((24, 136, 40), (92, 122, 34), (160, 118, 44), (222, 124, 34), (262, 154, 46), (60, 108, 22)):
        for j in range(ln):
            y = y0 - int(7 * math.sin(j / ln * math.pi)) + j // 7
            if not cv.get(x0 + j, y + 3)[3]: continue
            cv.put(x0 + j, y, WARM if j % 3 else SN[0]); cv.put(x0 + j, y + 1, SN[1])
            cv.put(x0 + j, y + 2, SN[3]); cv.put(x0 + j, y + 3, SN[4] if j % 2 else SN[3]); cv.put(x0 + j, y + 4, SN[2]) if j % 2 == 0 and 3 < j < ln - 3 else None
    for (x, y, ln) in ((30, 100, 18), (40, 158, 24), (120, 100, 20), (112, 152, 22), (206, 100, 18), (240, 140, 18), (286, 104, 16), (300, 132, 20), (190, 80, 16), (170, 64, 14)): sastr(cv, x, y, ln, rnd, .7)
    for (x, y, n) in ((60, 120, 16), (130, 134, 14), (258, 106, 14), (222, 150, 14), (180, 92, 14)): crack(cv, x, y, n, rnd, 1., .3, only=SNR)
    # flat trodden foreground, so the three drifts sit on one floor
    fl = lambda x, y: 6 <= x <= 334 and B - 13 + int(2 * math.sin(x * .09) + (nB(x, 9) - .5) * 5) <= y <= B + 1 - (1 if x % 5 == 0 else 0)
    shade(cv, (4, B - 20, 336, B + 2), fl, lambda x, y: (.04, -.92, .39), SNR, bump=lambda x, y: 2 * (nB(x, y) - .5) + 1.3 * math.sin(x * .28 + y * .9 + 4 * nA(x, y)), bk=1.3, bias=-.1, gain=3.0)
    for x in range(6, 335):
        if fl(x, B - 13 + int(2 * math.sin(x * .09) + (nB(x, 9) - .5) * 5) - 3) is False: pass
    for x0 in (14, 60, 214, 262): sastr(cv, x0, B - 6, 26, rnd, .5, .02)
    # zig-zag signpost with a scarf, planted in front of the middle drift
    px = 168
    wood(cv, px - 2, 84, px + 4, B - 2, rnd, True, WD, grain=.9)
    for y in range(84, 94): cv.put(px - 2, y, WD[0]); cv.put(px - 1, y, WD[1]) if y > 86 else None
    cloud_lump(cv, px + 1, 82, 6, 3, rnd, bumps=1, bias=-.6)
    cloud_lump(cv, px + 2, B - 2, 17, 6, rnd, bumps=2, bias=-.4)
    for (x0, y0, d) in ((px + 4, 93, 1), (px - 3, 111, -1), (px + 4, 129, 1)):
        L = 36; pts = [(x0, y0), (x0 + d * L, y0), (x0 + d * (L + 10), y0 + 7), (x0 + d * L, y0 + 14), (x0, y0 + 14)]
        mm = _mask(cv.w, cv.h, pts)
        wood(cv, min(x0, x0 + d * (L + 10)), y0, max(x0, x0 + d * (L + 10)) + 1, y0 + 15, rnd, False, WD, mask=lambda x, y, mm=mm: mm[x, y] if 0 <= x < cv.w and 0 <= y < cv.h else 0)
        for k in range(1, L + 6, 3):  # worn painted zig-zag glyph
            cv.put(x0 + d * (4 + k), y0 + 6 + (k // 3 % 2) * 2 - 1, EM[1]); cv.put(x0 + d * (5 + k), y0 + 5 + (k // 3 % 2) * 2, EM[2]) if (k * 7) % 5 else None
        cv.put(x0 + d * 3, y0 + 3, WD[4]); cv.put(x0 + d * 3, y0 + 11, WD[4]); cv.put(x0 + d * (L - 3), y0 + 7, WD[4])    # nails
        for k in range(L - 2):   # snow rides the top edge, frost the underside
            if (k * 5 + d) % 7 < 5: cv.put(x0 + d * k, y0 - 1, SN[0] if k % 2 else SN[1]); cv.put(x0 + d * k, y0 - 2, SN[1]) if (k * 3) % 8 < 2 else None
            if (k * 3) % 5 == 0: cv.put(x0 + d * k, y0 + 15, SN[3])
        crack(cv, x0 + d * 10, y0 + 5, 9, rnd, d * 1., .2, col=WD[4], lip=False, branch=0, only=WD)
        icicle2(cv, x0 + d * (L + 2), y0 + 12, 7, 3, rnd, bead=False)
    py_ = None
    for k in range(34):    # a scarf knotted at the top, streaming off to the left in the wind
        x = px - 3 - int(k * 1.0); y = 88 + int(k * .3 + 3.5 * math.sin(k * .42)); wdt = 6 - k // 10
        lo, hi = (y, y + wdt) if py_ is None else (min(y, py_[0]), max(y + wdt, py_[1]))
        for j in range(lo, hi):
            u = (j - y) / float(max(1, wdt)); band = (k // 4) % 2
            cv.put(x, j, (PT[0] if u < .25 else PT[1] if u < .7 else PT[2]) if band else (CREAM if u < .3 else SN[2] if u < .7 else SN[3]))
        py_ = (y, y + wdt)
    for j in range(5): cv.put(px - 37 - j % 2, 98 + j, PT[1] if j % 2 else CREAM); cv.put(px - 36 - j % 2, 98 + j, PT[2])
    # a half-buried boot, sole to the sky, and a trail of footprints that stops right at it
    bx, by = 290, 172
    lump(cv, bx + 2, by + 8, 28, 9, SN, rnd, 0)
    for y in range(by - 22, by + 6):   # the leg, going down into the drift: stitched leather, lit left
        for x in range(bx - 9, bx + 3): cv.put(x, y, WD[1] if x < bx - 6 else WD[2] if x < bx - 1 else WD[3])
        cv.put(bx - 9 + (y % 3 == 0), y, WD[0]) if y % 4 else None
    foot = [(bx - 9, by - 32), (bx + 12, by - 31), (bx + 28, by - 25), (bx + 30, by - 19), (bx + 24, by - 14), (bx - 9, by - 14)]
    mm = _mask(cv.w, cv.h, foot)
    for y in range(by - 34, by - 12):
        for x in range(bx - 10, bx + 32):
            if not mm[x, y]: continue
            tp_ = by - 32 + max(0, (x - bx + 9)) * 7 // 38
            if y < tp_ + 4: c = WD[4] if y > tp_ else WD[3]                       # sole: dark rubber ...
            elif y == tp_ + 4: c = WD[0]                                          # ... stitched welt
            else: c = WD[1] if x < bx - 3 else WD[2] if x < bx + 14 else WD[3]    # upper leather
            if y >= tp_ + 5 and y > by - 18: c = WD[3] if x < bx + 14 else WD[4]
            cv.put(x, y, c)
    for x in range(bx - 8, bx + 28, 3):   # tread bars cut into the sole
        tp_ = by - 32 + max(0, (x - bx + 9)) * 7 // 38; cv.put(x, tp_ + 1, WD[2]); cv.put(x, tp_ + 2, WD[2])
    rect(cv, bx - 9, by - 36, bx, by - 31, WD[4]); rect(cv, bx - 9, by - 36, bx, by - 35, WD[3])   # heel block
    for x in range(bx - 9, bx + 27): cv.put(x, by - 33 + max(0, (x - bx + 9)) * 7 // 38 - (1 if x > bx else 3 * (x < bx)), SN[0] if (x * 5) % 9 < 5 else SN[1]) if x > bx else None
    cloud_lump(cv, bx + 12, by - 34, 9, 2, rnd, bumps=1, bias=-.7)
    for q in range(4): cv.put(bx - 4 + q * 3, by - 11, WD[4]); cv.put(bx - 3 + q * 3, by - 10, WD[4])
    cloud_lump(cv, bx + 4, by + 5, 24, 6, rnd, bumps=2, bias=-.4)
    for i in range(9):
        x, y = 188 + i * 10 + (i % 2) * 2, B - 10 - (i % 2) * 5 + (i // 4)
        fprint(cv, x, y, 1, 1 if i % 2 else -1)
    tuft(cv, 22, B - 5, rnd, 5, 8); tuft(cv, 128, B - 6, rnd, 4, 6); tuft(cv, 330, B - 4, rnd, 4, 7); sprig(cv, 212, B - 4, rnd, 1, 12); sprig(cv, 70, B - 8, rnd, -1, 10)
    lump(cv, 90, B - 7, 9, 5, ST, rnd, .12); cloud_lump(cv, 89, B - 11, 8, 3, rnd, bumps=1, bias=-.7)
    for x, y in ((110, 18), (250, 30), (60, 40), (200, 14), (296, 48), (20, 20)): gen2.sparkle(cv, x, y, False) if (x + y) % 3 == 0 else (glint(cv, x, y, 2))
    for x, y in ((40, 110), (100, 96), (136, 66), (160, 90), (300, 120), (260, 130), (80, 130), (180, 140)): glint(cv, x, y, 0)
    for x, y in ((130, 92), (240, 150), (70, 150)): glint(cv, x, y, 1)


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
    slab(cv, [(14, 130), (56, 100), (108, 30), (126, 40), (126, 134), (14, 134)], SN, rnd, sx=.3, sy=.7, speck=.04)
    rect(cv, 108, 34, 127, 134, SN[3]); rect(cv, 120, 40, 127, 134, SN[4])
    for y in range(36, 134, 4): rect(cv, 110, y, 117, y + 1, SN[2])
    for x in range(18, 108, 3): cv.put(x, 129 - (x - 14) * 99 // 94 - 1, CREAM)
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
    rect(cv, sx - 2, sb - 46, sx + 4, sb - 9, WD[2]); rect(cv, sx - 2, sb - 46, sx, sb - 9, WD[1])   # backrest
    rect(cv, sx - 2, sb - 46, sx + 4, sb - 44, WD[0])
    for x in range(sx + 6, sx + 40): rect(cv, x, sb - 24, x + 1, sb - 18, PT[1] if (x // 5) % 2 else PT[0])   # striped cushion
    lump(cv, sx + 22, sb - 24, 17, 4, PT, rnd, 0)
    line(cv, [(sx + 66, sb - 12), (sx + 76, sb - 4), (sx + 88, sb - 2)], EM[2], 1)   # rope
    rect(cv, sx + 86, sb - 4, sx + 90, sb, EM[1])
    # the flag: pole in the bank, triangular pennant
    fx = 306
    post(cv, fx, 16, 142, 3, WD)
    poly(cv, [(fx + 3, 18), (fx + 36, 30), (fx + 3, 44)], EM[1]); poly(cv, [(fx + 3, 18), (fx + 24, 25), (fx + 3, 31)], EM[0])
    rect(cv, fx, 12, fx + 3, 16, GD[0])
    lump(cv, fx + 1, 142, 12, 5, SN, rnd, 0)
    # a lost mitten on a stick (the caption's one lost mitten), left in front of the ramp
    mx = 90
    post(cv, mx, 22, 47, 3, WD)
    lump(cv, mx + 1, 12, 10, 12, EM, rnd, .05); lump(cv, mx - 9, 18, 4, 6, EM, rnd, 0)
    for x in range(mx - 8, mx + 11): cv.put(x, 24, SN[0]); cv.put(x, 25, SN[1])
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


def lm_icicurtain(rnd, cv):   # 290 x 186
    B = 184; nB = vnoise(rnd, 7); nA = vnoise(rnd, 16)
    fl = lambda x, y: 6 <= x <= 284 and B - 9 + int(2 * math.sin(x * .1) + (nB(x, 1) - .5) * 3) <= y <= B + 1 - (1 if (x * 7) % 9 < 2 else 0)
    shade(cv, (4, B - 14, 286, B + 3), fl, lambda x, y: (.03, -.92, .39), SN, bump=lambda x, y: 2 * (nB(x, y) - .5) + 1.4 * math.sin(x * .3 + y * .8 + 3 * nA(x * .5, y)), bk=1.2, bias=-.1, gain=3.0)
    ROPE = [CREAM, FROST[0], FROST[1], FROST[2]]
    for px in (30, 260):     # fat timber posts, rope lashings, a cap of snow, drifts banked round the feet
        wood(cv, px - 11, 22, px + 11, B - 6, rnd, True, WD, grain=.95)
        for k in range(5): crack(cv, px - 8 + k * 4, 40 + (k * 37) % 70, 12 + k * 3, rnd, .05, 1., col=WD[4], lip=False, branch=0, only=WD)
        for y in (46, 78, 110, 142):
            for yy in range(y, y + 4):
                for x in range(px - 12, px + 12):
                    u = (x - (px - 12)) / 24.; ci = 0 if u < .25 else 1 if u < .5 else 2 if u < .8 else 3
                    cv.put(x, yy, ROPE[ci] if (x + yy) % 3 else ROPE[min(3, ci + 1)])
            for x in range(px - 12, px + 12): cv.put(x, y + 4, WD[4]) if x % 2 else None
        cloud_lump(cv, px, 20, 17, 7, rnd, bumps=3, bias=-.4)
        cloud_lump(cv, px + 2, B - 6, 33, 10, rnd, bumps=3, bias=-.3)
        for k in range(3): sastr(cv, px - 26 + k * 8, B - 8 + k, 14, rnd, .5, .02)
    # heavy cross beam, snow along its top and clinging over the lip
    bm = lambda x, y: 8 <= x <= 282 and 34 <= y < 55 and not (x < 11 and (y < 36 or y > 52)) and not (x > 279 and (y < 36 or y > 52))
    wood(cv, 8, 34, 282, 55, rnd, False, WD, mask=bm, grain=.95)
    for x in range(8, 282, 17): rect(cv, x, 38, x + 1, 52, WD[4]); cv.put(x + 2, 40, WD[3]); cv.put(x + 2, 49, WD[3])
    for x in range(8, 282, 54): rect(cv, x, 35, x + 4, 40, WD[4]); cv.put(x + 1, 36, WD[1])   # iron cleats
    cloud_lump(cv, 146, 31, 112, 4, rnd, bumps=3, bias=-.4)
    for x in range(14, 276):
        if (x * 5) % 13 < 4: cv.put(x, 35, SN[0]); cv.put(x, 36, SN[1]) if (x * 3) % 4 < 2 else None; cv.put(x, 37, SN[3]) if (x * 7) % 9 < 3 else None
    # the frozen sheet under the beam, fluted, so the curtain reads as one piece of ice
    sheet = lambda x, y: 20 <= x <= 270 and 55 <= y < 55 + 22 + (x * 7) % 9 + int(5 * nA(x, 3))
    shade(cv, (20, 55, 270, 100), sheet, lambda x, y: (.08, -.25, .96), IC, bump=lambda x, y: 1.6 * math.sin(x * 1.05 + 4 * nA(x, y * .4)) + (nB(x, y) - .5) * 2, bk=1.0, bias=.2, gain=3.0)
    i = 0
    for x in range(41, 250, 7):    # the main curtain: ragged lengths, a few hollow tubes and a few lopsided ones
        ln = 36 + (i * 53) % 58 + (16 if 8 < i < 17 else 0) - (22 if i % 6 == 4 else 0)
        icicle2(cv, x, 54, ln, 8 if i % 3 else 10, rnd, lean=((i * 7) % 5 - 2) * .5, hollow=(ln > 70 and i % 2 == 0)); i += 1
    for x in range(36, 252, 8):    # shorter staggered row in front, brighter (nearer the light)
        if (x // 8) % 2: icicle2(cv, x + 4, 54, 22 + (x * 3) % 24, 6, rnd, bead=(x % 3 == 0))
    for x in range(40, 252, 6): cv.put(x, 54, ICR[0]); cv.put(x, 55, ICR[1]) if (x // 6) % 2 else None
    for (x, y) in ((74, 104), (140, 128), (189, 96), (222, 82), (112, 90), (166, 118)):    # sparkles caught in the ice, one tinted pink, one green
        glint(cv, x, y, 1 if x % 2 else 0)
    for (x, y, c) in ((130, 70, PT[0]), (200, 66, SE[0]), (80, 82, MO[0])): cv.put(x, y, c); cv.put(x, y + 1, mix(c, IC[0], .5))
    for x, ln in ((70, 62), (130, 98), (186, 76), (222, 54)):   # little chime bells, each on its own string down through the icicles
        y = 56 + ln
        for k in range(ln): cv.put(x, 56 + k, FROST[2] if k % 2 else FROST[1])
        lump(cv, x, y + 4, 5, 5, GD, rnd, 0); rect(cv, x - 5, y + 7, x + 6, y + 9, GD[2]); rect(cv, x - 5, y + 9, x + 6, y + 10, GD[3]); cv.put(x, y + 11, GD[3]); cv.put(x, y + 12, GD[1]); cv.put(x - 3, y + 2, GD[0]); cv.put(x - 2, y + 1, WHITE)
        cv.put(x - 1, y - 2, GD[2]); cv.put(x, y - 2, GD[3]); cv.put(x + 1, y - 2, GD[2])
    # do-not-lick sign on its own stake
    sx = 206; sh = lambda x, y: sx <= x <= sx + 34 and 112 <= y <= 142 and not (x in (sx, sx + 34) and y in (112, 142))
    wood(cv, sx + 14, 138, sx + 20, B - 6, rnd, True, WD, grain=.8)
    wood(cv, sx, 112, sx + 35, 143, rnd, False, WD, mask=sh, grain=.9)
    for x in range(sx, sx + 35): cv.put(x, 112, WD[0]); cv.put(x, 142, WD[4]) if sh(x, 142) else None
    for y in range(112, 143): cv.put(sx + 34, y, WD[4]) if sh(sx + 34, y) else None; cv.put(sx, y, WD[0]) if sh(sx, y) else None
    for (nx_, ny_) in ((sx + 3, 115), (sx + 31, 115), (sx + 3, 139), (sx + 31, 139)): cv.put(nx_, ny_, WD[4]); cv.put(nx_ - 1, ny_ - 1, WD[0])
    for dx in (8, 23): rect(cv, sx + dx, 120, sx + dx + 5, 125, COAL); cv.put(sx + dx + 1, 121, CREAM); cv.put(sx + dx + 1, 120, CREAM)
    rect(cv, sx + 11, 129, sx + 24, 133, COAL); rect(cv, sx + 14, 133, sx + 20, 139, PT[1]); rect(cv, sx + 14, 133, sx + 15, 139, PT[0]); rect(cv, sx + 19, 134, sx + 20, 139, PT[2]); cv.put(sx + 16, 139, PT[3]); cv.put(sx + 17, 139, PT[3])
    for k in range(34): cv.put(sx + 2 + k, 116 + int(k * .72), EM[1] if k % 3 else EM[2]); cv.put(sx + 3 + k, 116 + int(k * .72), EM[0] if k % 3 == 0 else EM[1])   # the slash
    for k in range(4): cv.put(sx + 8 + k * 7, 143 + (k % 2), WD[4])
    crack(cv, sx + 4, 128, 10, rnd, 1., .5, col=WD[4], lip=False, branch=0, only=WD)
    cloud_lump(cv, sx + 17, 111, 17, 3, rnd, bumps=2, bias=-.6)
    icicle2(cv, sx + 29, 143, 7, 3, rnd, bead=False)
    cloud_lump(cv, sx + 17, B - 5, 14, 5, rnd, bumps=2, bias=-.4)
    tuft(cv, 100, B - 3, rnd, 5, 7); tuft(cv, 180, B - 2, rnd, 4, 6); sprig(cv, 140, B - 3, rnd, 1, 12)
    lump(cv, 86, B - 4, 8, 5, ST, rnd, .12); cloud_lump(cv, 85, B - 8, 7, 2, rnd, bumps=1, bias=-.7)
    for x, y in ((72, B - 4), (110, B - 6), (156, B - 3), (190, B - 5)): fprint(cv, x, y, 1 if x % 2 else 0, 1 if x % 2 else -1)
    for k in range(10): glint(cv, 16 + k * 28, B - 7 + (k * 5) % 6, 0)


# ------------------------------------------------------------------ 316
def lm_skyhill(rnd, cv):   # 340 x 196
    B = 190; cx = 170; TOP = 106; TR = 96
    n1, n2, n3 = vnoise(rnd, 24), vnoise(rnd, 8), vnoise(rnd, 14)
    def ytop(x):
        dx = abs(x - cx)
        if dx <= TR: return TOP - 12 * math.sqrt(max(0, 1 - (dx / TR) ** 2)) + (n2(x, 3) - .5) * 2
        t = min(1., (dx - TR) / 72.); return TOP + (B - TOP - 4) * (1 - math.sqrt(max(0., 1 - t * t))) + (n1(x * .8, 9) - .5) * 9 * t + (n2(x, 1) - .5) * 3
    top = {x: ytop(x) for x in range(0, 340)}
    def inside(x, y): return 0 <= x < 340 and abs(x - cx) <= 168 and top[x] <= y <= B + 1 - (2 if (x * 7) % 11 < 3 else 0)
    def face(x, y): return ((x + .5 - cx) / TR) ** 2 + ((y + .5 - TOP) / 12.) ** 2 <= 1
    ridge_n = vnoise(rnd, 17)
    def bump(x, y):
        fade = min(1., max(0., (y - TOP - 6) / 24.))
        return 3.6 * (n1(x, y) - .5) + 1.4 * (n2(x, y) - .5) + fade * 1.1 * math.sin(y / 3.6 + 8 * ridge_n(x, y) + x * .02)
    slope_n = ell_n(cx, B + 10, 172, B + 10 - TOP + 6)
    shade(cv, (0, TOP - 14, 340, B + 2), lambda x, y: inside(x, y) and not face(x, y), slope_n, SNR, bump=bump, bk=2.1, bias=-.3, gain=4.3, bounce=1.2)
    def tnrm(x, y): return (-.08, -.93, .36)
    tb = lambda x, y: 1.2 * (n2(x, y) - .5) + .7 * math.sin((x * .13 + y * .5) + 3 * n3(x, y))
    shade(cv, (cx - TR, TOP - 13, cx + TR, TOP + 13), lambda x, y: inside(x, y) and face(x, y), tnrm, SNR, bump=tb, bk=1.2, bias=-.35, gain=2.6)
    for x in range(cx - TR, cx + TR + 1):    # blown-snow lip on the front rim of the flat top, with its own shadow cast down the slope
        dx = (x - cx) / TR
        if abs(dx) >= 1: continue
        yf = int(TOP + 12 * math.sqrt(1 - dx * dx)) + (1 if n2(x, 5) > .6 else 0)
        cv.put(x, yf, WARM if x < cx + 30 else SN[1]); cv.put(x, yf + 1, SN[3] if (x + yf) % 3 else SN[4]); cv.put(x, yf + 2, SN[3] if (x * 3 + 1) % 4 < 2 else SN[2])
    # crust cracks and wind-cut sastrugi on the shoulders
    for (x, y, n, d) in ((60, 150, 22, 1.), (118, 150, 14, 1.), (240, 144, 18, 1.), (268, 164, 16, -.4), (86, 172, 12, 1.2), (214, 168, 12, 1.)):
        crack(cv, x, y, n, rnd, d, .3, only=SNR)
    for (x, y, ln) in ((34, 140, 26), (66, 132, 20), (22, 168, 24), (250, 132, 22), (286, 146, 20), (300, 170, 16), (150, 176, 22), (200, 154, 26), (104, 164, 18), (240, 178, 22)):
        sastr(cv, x, y, ln, rnd, wave=.8)
    for x, y in ((98, 120), (214, 122), (138, 126), (255, 112), (80, 118)): sastr(cv, x, y, 14, rnd, .5, .05)
    # footprints trodden up from the foot, climbing round to the top
    for i in range(15):
        t = i / 14.; x = int(106 + 28 * t + 9 * math.sin(t * 6.3)) + (3 if i % 2 else -3); y = int(B - 12 - t * (B - TOP - 30))
        fprint(cv, x, y, 2 if t < .5 else 1, 1 if i % 2 else -1)
    # --- the blanket and the gnome lying on his back, counting
    P = [(102, TOP - 4), (212, TOP - 9), (224, TOP + 3), (112, TOP + 10)]
    m = _mask(cv.w, cv.h, P)
    for y in range(TOP - 12, TOP + 13):
        for x in range(96, 232):
            if not m[x, y]: continue
            u, v = x - 102, y
            c = 1
            if u % 18 < 4: c = 2 if u % 18 < 2 else 3
            elif u % 18 in (9, 10): c = 0
            if (y + (x - 102) // 12) % 9 < 2: c = c + 1 if c < 3 else 3
            if (x * 5 + y * 3) % 7 == 0: c = max(0, c - 1)
            cv.put(x, y, PT[c])
    for (x, y, n, d) in ((130, TOP + 6, 18, 1), (176, TOP + 1, 14, 1), (196, TOP - 3, 10, 1)):   # wrinkles: a dark fold with a lit lip
        crack(cv, x, y, n, rnd, d, -.12, col=PT[3], lip=False, branch=0)
        for k in range(n): cv.put(x + k, y - 1 - int(k * .1), PT[0]) if cv.get(x + k, y - 1)[3] and cv.get(x + k, y - 1) in PT else None
    for k in range(P[3][0], P[2][0]):   # front edge: hem, then a fringe of tassels
        yy = int(P[3][1] + (k - P[3][0]) * (P[2][1] - P[3][1]) / (P[2][0] - P[3][0]))
        cv.put(k, yy, PT[3]); cv.put(k, yy + 1, PT[3]) if k % 2 == 0 else None
        if k % 3 == 0: cv.put(k, yy + 2, PT[2]); cv.put(k, yy + 3, PT[1]) if k % 6 == 0 else None
        cv.put(k, yy + 4 + (k % 2), SN[3]) if k % 2 == 0 else None
    for y in range(TOP - 9, TOP + 10):   # blanket stands a little off the snow: a lit lip of snow on its left edge, shade on the right
        for x in (96, 97):
            if not cv.get(x, y)[3]: pass
    # snow pillow, head, beard
    lump(cv, 116, TOP - 2, 12, 5, SN, rnd, 0)
    lump(cv, 118, TOP - 8, 8, 7, SKIN, rnd, 0)
    for dx in (-3, 2): cv.put(118 + dx, TOP - 8, COAL); cv.put(119 + dx, TOP - 8, COAL)   # closed eyes
    lump(cv, 121, TOP - 5, 2, 2, SKIN, rnd, 0); cv.put(115, TOP - 5, PT[1]); cv.put(116, TOP - 5, PT[0]); cv.put(123, TOP - 4, PT[1])
    lump(cv, 133, TOP - 3, 15, 7, SN, rnd, .0)
    for k in range(5): cv.put(123 + k * 4, TOP + 2 - (k % 2), SN[3]); cv.put(124 + k * 4, TOP + 3, SN[3]) if k % 2 else None
    for hx in range(110, 127): cv.put(hx, TOP - 13 + (hx % 3 == 0), SN[0 if hx < 118 else 2]); cv.put(hx, TOP - 12, SN[1 if hx < 120 else 3])
    for k in range(22):   # woolly red hat: a cone that flops over to the left
        y = TOP - 14 - k; half = max(0, int(7 * (1 - k / 22.) ** .9)); cxh = 118 - int(k * k * .045)
        for x in range(cxh - half, cxh + half + 1):
            u = (x - (cxh - half)) / max(1., 2 * half); cv.put(x, y, EM[0] if u < .22 else EM[1] if u < .5 else EM[2] if u < .8 else EM[3])
    lump(cv, 118 - int(21 * 21 * .045), TOP - 37, 3, 3, SN, rnd, 0)
    # coat and belly
    lump(cv, 156, TOP - 8, 27, 12, SE, rnd, .03)
    for y in range(TOP - 14, TOP + 3): cv.put(158, y, WD[3]) if 0 else None
    rect(cv, 148, TOP - 14, 156, TOP - 5, WD[3]); rect(cv, 150, TOP - 12, 154, TOP - 7, GD[1]); rect(cv, 151, TOP - 11, 153, TOP - 8, GD[3]); cv.put(150, TOP - 12, GD[0])
    for k in range(3): cv.put(138 + k * 3, TOP - 17 + k, SE[0]); cv.put(139 + k * 3, TOP - 17 + k, SE[1])
    tube(cv, (140, TOP - 8), (146, TOP - 28), 6, 5, SE)       # one arm up, pointing at the sky
    lump(cv, 147, TOP - 30, 3, 3, SKIN, rnd, 0)
    for lx, tilt in ((182, 3), (194, 5)):     # trousers, up in the air, with striped socks and boots with treaded soles
        tube(cv, (lx, TOP - 9), (lx + tilt, TOP - 27), 7, 6, DU)
        tube(cv, (lx + tilt, TOP - 27), (lx + tilt + 1, TOP - 32), 6, 6, DU, rings=(.3, .7), ring=[CREAM, CREAM, CREAM, SN[3], SN[3]])
        tube(cv, (lx + tilt + 1, TOP - 32), (lx + tilt + 2, TOP - 40), 9, 10, WD)
        for k in range(-4, 6): cv.put(lx + tilt + 2 + k, TOP - 41, WD[4]); cv.put(lx + tilt + 2 + k, TOP - 42, WD[3] if k % 2 else WD[2])
        cv.put(lx + tilt - 1, TOP - 38, WD[0]); cv.put(lx + tilt - 1, TOP - 37, WD[0])
        for k in range(-3, 4): cv.put(lx + tilt + 2 + k, TOP - 43, SN[0]) if k % 2 == 0 else None   # snow clinging to the soles
    for i in range(3):   # thought puffs rising, the last one holding a count of stars
        cloud_lump(cv, 106 - i * 7, TOP - 46 - i * 14, 4 + i * 2, 3 + i, rnd, bumps=2)
    cloud_lump(cv, 82, TOP - 90, 17, 10, rnd, bumps=4)
    for (x, y) in ((74, TOP - 93), (80, TOP - 86), (86, TOP - 95), (91, TOP - 88), (84, TOP - 80), (76, TOP - 83)): cv.put(x, y, GD[1]); cv.put(x + 1, y, GD[0]) if x % 2 else cv.put(x, y - 1, GD[0])
    # steaming flask and cup
    fx = 208
    tube(cv, (fx + 6, TOP + 4), (fx + 6, TOP - 15), 13, 13, SE)
    rect(cv, fx, TOP - 8, fx + 13, TOP - 5, WD[2]); rect(cv, fx, TOP - 8, fx + 13, TOP - 7, WD[1])
    rect(cv, fx + 1, TOP - 22, fx + 12, TOP - 15, WD[1]); rect(cv, fx + 1, TOP - 22, fx + 3, TOP - 15, WD[0]); rect(cv, fx + 10, TOP - 22, fx + 12, TOP - 15, WD[3])
    for k in range(9): cv.put(fx + 5 + int(2 * math.sin(k * .9)), TOP - 25 - k * 2, CREAM if k % 2 else SN[1]); cv.put(fx + 6 + int(2 * math.sin(k * .9)), TOP - 26 - k * 2, SN[2]) if k % 3 == 0 else None
    lump(cv, fx + 22, TOP + 1, 5, 4, ST, rnd, 0); rect(cv, fx + 19, TOP - 3, fx + 24, TOP - 1, WD[3]); cv.put(fx + 20, TOP - 3, SN[0])
    # telescope on a tripod, aimed at nothing in particular
    tx, ty = 252, TOP + 4
    for ex, sx in ((-13, -3), (0, 0), (13, 3)):
        line(cv, [(tx + sx, ty - 24), (tx + ex, ty + 2)], WD[3], 2); line(cv, [(tx + sx - 1, ty - 24), (tx + ex - 1, ty + 2)], WD[1], 1)
    tube(cv, (tx - 14, ty - 21), (tx + 40, ty - 61), 8, 6, GD, rings=(.08, .5, .93), ring=GD)
    tube(cv, (tx + 40, ty - 61), (tx + 50, ty - 68), 10, 9, GD, rings=(.2, .85), ring=ST)
    lump(cv, tx + 51, ty - 69, 4, 4, SE, rnd, 0); glint(cv, tx + 50, ty - 71, 0)
    tube(cv, (tx - 14, ty - 21), (tx - 19, ty - 17), 4, 3, ST)
    lump(cv, tx - 1, ty - 22, 4, 4, GD, rnd, 0)
    for k in range(3): cv.put(tx - 6 + k * 14, ty - 28 + k * -9, GD[0])
    for dx in (-14, 0, 14): cv.put(tx + dx, ty + 3, SN[3]); cv.put(tx + dx + 1, ty + 3, SN[3])
    # stars (four-point glints and dots), and a shooting star with a fading tail
    for (x, y, b) in ((58, 30, 1), (104, 12, 0), (168, 20, 1), (262, 8, 0), (312, 40, 1), (196, 36, 0), (30, 60, 0), (126, 56, 1), (232, 24, 0), (286, 22, 0)):
        if b: glint(cv, x, y, 2)
        else: cv.put(x, y, CREAM); cv.put(x + 1, y, SN[1]) if x % 2 else None
    for k in range(16):
        x, y = 304 - k * 2, 14 + k; cols = [WHITE, CREAM, SN[0], SN[1], SN[2], SN[2], SN[3]]
        cv.put(x, y, cols[min(6, k // 2)]); cv.put(x + 1, y, cols[min(6, k // 2 + 1)]) if k < 12 else None
        if k < 8: cv.put(x, y + 1, cols[min(6, k // 2 + 1)])
    # drifts spilling round the foot, buried stones, frozen tufts and a pine sprig
    for (x, y, rx, ry) in ((30, B - 6, 26, 9), (312, B - 5, 26, 9), (168, B + 1, 52, 5), (92, B - 1, 26, 5), (250, B - 1, 26, 6)): cloud_lump(cv, x, y, rx, ry, rnd, bumps=2, bias=-.4)
    for x, y, w in ((50, B - 14, 13), (292, B - 10, 12), (206, B - 4, 8)):
        lump(cv, x, y, w, int(w * .62), ST, rnd, .12)
        for k in range(3): crack(cv, x - w // 2 + k * 5, y - 2, 4, rnd, .3, 1., col=ST[4], lip=False, branch=0, only=ST)
        cloud_lump(cv, x - 1, y - int(w * .55), int(w * .8), 3, rnd, bumps=1, bias=-.7)
    tuft(cv, 74, B - 4, rnd, 6, 8); tuft(cv, 120, B - 1, rnd, 4, 6); tuft(cv, 276, B - 3, rnd, 5, 7); tuft(cv, 322, B - 8, rnd, 4, 6)
    sprig(cv, 236, B - 1, rnd, 1, 13); sprig(cv, 14, B - 10, rnd, -1, 10)
    for x, y in ((40, 128), (110, 134), (226, 140), (300, 150), (150, 140), (70, 160), (270, 176), (130, 168)): glint(cv, x, y, 0)
    for x, y in ((180, 150), (92, 146), (244, 158)): glint(cv, x, y, 1)


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
    "309-icecave": (270, 226, lm_icecave),
    "309-auroraledge": (260, 176, lm_auroraledge),
    "310-driftpass": (340, 196, lm_driftpass),
    "310-sledtrack": (340, 170, lm_sledtrack),
    "310-combridge": (290, 190, lm_comb),
    "310-icicurtain": (290, 186, lm_icicurtain),
    "316-skyhill": (340, 190, lm_skyhill),
    "316-starstones": (340, 200, lm_starstones),
    "316-auroracamp": (300, 250, lm_auroracamp),
    "316-kettletree": (240, 232, lm_kettletree),
}
