import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds

def R_(n): return RAMP[n]
def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)
def disc(cv, cx, cy, r, c):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r // 2: cv.put(x, y, c)
def hline(cv, x0, x1, y, c):
    for x in range(x0, x1): cv.put(x, y, c)
def vline(cv, x, y0, y1, c):
    for y in range(y0, y1): cv.put(x, y, c)
def eyes(cv, x, y, gap=8, s=3):
    for ex in (x - gap // 2, x + gap // 2):
        rect(cv, ex - s // 2, y, ex - s // 2 + s, y + s + 1, INK); cv.put(ex - s // 2, y, CREAM)
def smile(cv, x, y, w, c=None):
    c = c or RAMP["ember"][3]
    for k in range(-w, w + 1): cv.put(x + k, y + (k * k) // max(1, w * 2) * -1 + w // 2, c)
def foot_flat(cv, cx, y, rx, c):   # flat-bottomed lump: erase below y
    for yy in range(y + 1, cv.h):
        for x in range(cx - rx - 4, cx + rx + 5): cv.p[x, yy] = (0, 0, 0, 0) if 0 <= x < cv.w else None
def mound(cv, cx, base, rx, ry, R, rnd, speck=.1):
    lump(cv, cx, base, rx, ry, R, rnd, speck)
    for y in range(base + 1, base + ry + 3):
        for x in range(cx - rx - 2, cx + rx + 3):
            if 0 <= x < cv.w and 0 <= y < cv.h: cv.p[x, y] = (0, 0, 0, 0)
def shell(cv, x, y, s, col, rnd):
    P = RAMP[col]
    for dy in range(-s, 1):
        w = int(s * math.sqrt(max(0, 1 - (dy / s) ** 2)) * 1.4) + 1 if False else s + dy + 1
        for dx in range(-w, w + 1):
            cv.put(x + dx, y + dy, P[1] if (dx + dy) % 3 else P[0])
    for k in range(-s + 1, s, 2): cv.put(x + k, y, P[2]); cv.put(x + k // 2, y - s // 2, P[2])
    cv.put(x, y, P[3])
def spiral(cv, x, y, s, col):
    P = RAMP[col]
    disc(cv, x, y, s, P[1]); disc(cv, x - 1, y - 1, s - 1, P[0])
    for a in range(0, 540, 20):
        r = s * (1 - a / 640.0)
        cv.put(x + int(round(math.cos(math.radians(a)) * r)), y + int(round(math.sin(math.radians(a)) * r)), P[3])
def crab(cv, x, y, s, rnd, wave=False):
    E = r5(RAMP["ember"])
    for sx in (-1, 1):   # legs
        for k in range(3):
            for j in range(5 * s): cv.put(x + sx * (7 * s + j), y + 2 * s + k * 2 * s + j // 2, RAMP["ember"][3])
    lump(cv, x, y + 2 * s, 9 * s, 6 * s, E, rnd, .05)
    for sx in (-1, 1):   # claws
        cy = y - 4 * s if (wave and sx > 0) else y
        for k in range(5 * s): cv.put(x + sx * (8 * s + k // 3), y + 2 * s - k // 2 if wave and sx > 0 else y + 2 * s, RAMP["ember"][2])
        lump(cv, x + sx * 12 * s, cy, 4 * s, 3 * s, E, rnd, 0)
        rect(cv, x + sx * 12 * s - 1, cy - 1, x + sx * 12 * s + 1, cy + 1, RAMP["ember"][3])
    for sx in (-1, 1):
        vline(cv, x + sx * 3 * s, y - s, y + s, RAMP["ember"][2])
        disc(cv, x + sx * 3 * s, y - s * 2, s + 1, CREAM); disc(cv, x + sx * 3 * s, y - s * 2, max(1, s - 1) , INK)
def gull(cv, x, y, s=1, flip=False, open_beak=False):
    d = -1 if flip else 1
    rnd = random.Random(x * 31 + y)
    lump(cv, x, y, 8 * s, 5 * s, r5(RAMP["snow"]), rnd, 0)
    for k in range(7 * s):   # grey wing
        for j in range(3 * s): cv.put(x - d * (k + 1) + d * 2 * s, y - s + j, RAMP["stone"][1 if j < 2 * s else 2]) if k > s else None
    lump(cv, x + d * 7 * s, y - 5 * s, 4 * s, 4 * s, r5(RAMP["snow"]), rnd, 0)
    for k in range(4 * s): cv.put(x + d * (10 * s + k), y - 4 * s + k // 3 + (1 if open_beak else 0), RAMP["gold"][1])
    if open_beak:
        for k in range(3 * s): cv.put(x + d * (10 * s + k), y - 5 * s, RAMP["gold"][1])
    cv.put(x + d * 8 * s, y - 6 * s, INK); cv.put(x + d * 8 * s, y - 6 * s + 1, INK)
    for lx in (-2 * s, 2 * s): vline(cv, x + lx, y + 4 * s, y + 7 * s, RAMP["gold"][2])
    for k in range(3 * s): cv.put(x - d * (8 * s + k), y + 1 * s, RAMP["stone"][2])   # tail
def waves(cv, x0, x1, y, rnd, amp=2, c=None):
    for x in range(x0, x1):
        yy = y + int(round(math.sin(x / 7.0) * amp))
        cv.put(x, yy, c or CREAM)
        if x % 3: cv.put(x, yy + 1, RAMP["sea"][0])
def seaband(cv, x0, x1, y0, y1, rnd):
    for y in range(y0, y1):
        t = 0 if y < y0 + (y1 - y0) // 4 else 1 if y < y0 + (y1 - y0) // 2 else 2 if y < y0 + 3 * (y1 - y0) // 4 else 3
        for x in range(x0, x1):
            tt = t
            if (x * 5 + y * 3) % 11 == 0: tt = max(0, tt - 1)
            cv.put(x, y, RAMP["sea"][tt])
def pebble_(cv, x, y, rx, ry, c, rnd):
    R = [mix(c, CREAM, .5), mix(c, CREAM, .22), c, darker_c(c), darker_c(darker_c(c))]
    lump(cv, x, y, rx, ry, R, rnd, 0)
def darker_c(c): return mix(c, H("#2b1c26"), .35)

# ------------------------------------------------------------------ hand-drawn detail helpers (form shading, dither, strokes)
_B4 = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))
_LV = (-0.5, -0.6, 0.62)
def hd_tone(v, x, y):
    """continuous tone 0..4 -> int tone with a 4x4 ordered dither so ramp steps melt into a checker."""
    b = (_B4[y & 3][x & 3] + .5) / 16 - .5
    return max(0, min(4, int(math.floor(v + b + .5))))
def hd_noise(rnd, cell, w=900, h=900):
    gw, gh = w // cell + 3, h // cell + 3; g = [[rnd.random() for _ in range(gw)] for _ in range(gh)]
    def f(x, y):
        fx, fy = x / cell, y / cell; x0, y0 = int(fx), int(fy); tx, ty = fx - x0, fy - y0
        tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
        a, b, c, d = g[y0][x0], g[y0][x0 + 1], g[y0 + 1][x0], g[y0 + 1][x0 + 1]
        return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
    return f
def hd_form(cv, box_, inside, hf, R, rnd, gain=2.8, bias=.95, extra=None):
    """Fill every pixel where inside(x,y) with a ramp tone from a height field hf(x,y) (normal . light, dithered). Returns {(x,y): v}."""
    x0, y0, x1, y1 = box_; out = {}
    for y in range(y0, y1):
        for x in range(x0, x1):
            if not inside(x, y): continue
            gx = (hf(x + 1, y) - hf(x - 1, y)) / 2.0; gy = (hf(x, y + 1) - hf(x, y - 1)) / 2.0
            nn = math.sqrt(gx * gx + gy * gy + 1); d = (-gx * _LV[0] - gy * _LV[1] + _LV[2]) / nn
            v = (bias - d) * gain + (extra(x, y) if extra else 0)
            out[(x, y)] = v; cv.put(x, y, R[hd_tone(v, x, y)])
    return out
def hd_idx(c, R):
    for i, r in enumerate(R):
        if r == c: return i
    return None
def hd_blade(cv, x, y, h, lean, R, wide=False, ib=None):
    """one grass blade growing up from (x, y), coloured from whatever it grows on (dark root, lit tip)."""
    i = hd_idx(cv.get(x, y), R) if ib is None else ib; i = 2 if i is None else i
    for k in range(h):
        xx = x + (k * lean) // 3; t = max(0, i - 2) if k >= h - 1 else max(0, i - 1) if k > h // 2 else min(4, i + 1) if k == 0 else i
        cv.put(xx, y - k, R[t])
        if wide and k < h - 1: cv.put(xx + 1, y - k, R[min(4, i + 1)])
def hd_tuft(cv, x, y, n, hmax, R, rnd, spread=3, lean0=0, ib=None):
    for j in range(n):
        u = (j - (n - 1) / 2.0); hd_blade(cv, x + int(u * spread / max(1, n - 1) * 2), y + rnd.choice((0, 0, 1)), rnd.randint(max(2, hmax - 2), hmax), int(u * 1.2) + lean0, R, False, ib)
def hd_line(cv, x0, y0, x1, y1, c, only=None):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = int(round(x0 + (x1 - x0) * i / n)); y = int(round(y0 + (y1 - y0) * i / n))
        if only is None or only(x, y): cv.put(x, y, c)
def hd_blob(cv, cx, cy, rx, ry, c, rnd, only=None, rough=.18):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            d = ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2
            if d <= 1 - (rough if rnd.random() < .5 else 0) and (only is None or only(x, y)): cv.put(x, y, c)
def hd_bounce(cv, S, R, lr, bounce_i=1, deep_i=4):
    """S = set of filled pixels. On the lower-right edge (lr(x,y) true) the outermost px gets a bounce-light tone and the px just inside get the deepest shade."""
    E = [(x, y) for (x, y) in S if ((x + 1, y) not in S or (x, y + 1) not in S) and lr(x, y)]
    ES = set(E)
    for (x, y) in E:
        for dx, dy in ((-1, 0), (0, -1), (-1, -1)):
            p = (x + dx, y + dy)
            if p in S and p not in ES: cv.put(p[0], p[1], R[deep_i] if (p[0] + p[1]) % 3 else R[max(0, deep_i - 1)])
    for (x, y) in E: cv.put(x, y, R[bounce_i])
def hd_rock(cv, cx, base, rx, ry, rnd, R, p=2.3, H=60, nfacet=0, strata=0, gain=3.0, light_bias=.95, wiggle=.06):
    """Dome of rock: superellipse silhouette with a wobbly edge, form shading from a height field, optional voronoi facets (each with its own tilt, creased) and curved strata.
    Returns {(x, y): tone value}."""
    nz = hd_noise(rnd, 12); nz2 = hd_noise(rnd, 4); nz3 = hd_noise(rnd, 7)
    def rr(x, y): return abs((x + .5 - cx) / float(rx)) ** p + abs((y + .5 - base) / float(ry)) ** p
    def ins(x, y): return y <= base and rr(x, y) <= 1 + (nz3(x, y * .3) - .5) * wiggle * 2 + (nz(x, 3) - .5) * wiggle
    seeds = [(cx + rnd.uniform(-1, 1) * rx * .95, base - rnd.uniform(0, 1) * ry * .95, rnd.uniform(-1.1, 1.1), rnd.uniform(-1.1, 1.1)) for _ in range(nfacet)]
    def cell(x, y):
        best, bi = 1e9, -1
        for i, (sx, sy, a, b) in enumerate(seeds):
            d = (x - sx) ** 2 + ((y - sy) * 1.25) ** 2
            if d < best: best, bi = d, i
        return bi
    cells = {}
    def hf(x, y):
        r = min(1.0, rr(x, y)); return H * math.sqrt(max(0, 1 - r)) + 2.5 * nz(x, y)
    bandf = lambda x, y: (y + .0016 * (x - cx) ** 2 + 5 * (nz(x * .6, 9) - .5) * 2) / 9.5
    S = {}
    for y in range(base - ry - 4, base + 1):
        for x in range(cx - rx - 4, cx + rx + 5):
            if not ins(x, y): continue
            gx = (hf(x + 1, y) - hf(x - 1, y)) / 2.0; gy = (hf(x, y + 1) - hf(x, y - 1)) / 2.0
            if nfacet:
                c = cell(x, y); cells[(x, y)] = c; gx += seeds[c][2]; gy += seeds[c][3]
            nn = math.sqrt(gx * gx + gy * gy + 1); d = (-gx * _LV[0] - gy * _LV[1] + _LV[2]) / nn
            v = (light_bias - d) * gain + (nz2(x + 33, y) - .5) * .9 + ((x * 3 + y * 7) % 13 == 0) * .5
            if strata:
                b = bandf(x, y); k = int(math.floor(b)); fr = b - k
                v += (((k * 37) % 7) / 7.0 - .5) * 1.1
                S[(x, y)] = (v, fr, k)
            else: S[(x, y)] = (v, 0, 0)
    for (x, y), (v, fr, k) in S.items():
        t = hd_tone(v, x, y)
        if strata and nz3(x * 1.3 + k * 9, k * 5) > .35:
            if fr < .13: t = min(4, t + 2)         # dark ledge seam
            elif fr < .26: t = max(0, t - 1)       # lit lip below it
        cv.put(x, y, R[t])
    if nfacet:
        for (x, y), c in cells.items():
            for (dx, dy) in ((-1, 0), (0, -1)):
                o = cells.get((x + dx, y + dy))
                if o is not None and o != c:
                    vo, vc = S[(x + dx, y + dy)][0], S[(x, y)][0]
                    cv.put(x, y, R[max(0, min(4, hd_tone(vc + (-.9 if vc < vo else 1.0), x, y)))])
    return {k: v[0] for k, v in S.items()}
def hd_barn(cv, x, y, R, big=False):
    """one barnacle: a little pale volcano with a dark mouth and a shaded right side."""
    rows = ((-3, -1, 1), (-2, -2, 2), (-1, -3, 3), (0, -3, 3)) if big else ((-2, -1, 0), (-1, -2, 1), (0, -2, 2))
    for dy, a, b in rows:
        for dx in range(a, b + 1): cv.put(x + dx, y + dy, CREAM if dx < b - 1 else RAMP["snow"][1] if dx < b else R[3])
    top = rows[0][0]; cv.put(x - 1 + (1 if big else 0), y + top, R[4]); cv.put(x + (1 if big else 0), y + top, R[3])
    for dx in range(rows[-1][1] + 1, rows[-1][2] + 2): cv.put(x + dx, y + 1, R[4])
def hd_barnacles(cv, pts, R, n, rnd, where, cluster=4):
    for _ in range(n):
        for _t in range(30):
            x, y = rnd.choice(pts)
            if where(x, y): break
        else: continue
        for j in range(rnd.randint(2, cluster)):
            xx, yy = x + rnd.randint(-6, 6), y + rnd.randint(-4, 4)
            if (xx, yy) in cv_set(pts) and (xx + 3, yy) in cv_set(pts): hd_barn(cv, xx, yy, R, rnd.random() < .3)
_PTS = {}
def cv_set(pts):
    k = id(pts)
    if k not in _PTS or _PTS[k][0] is not pts: _PTS[k] = (pts, set(pts))
    return _PTS[k][1]
def hd_weed(cv, x, y, h, rnd, lean=1, R=None):
    """kelp / sea-lettuce strand: a swaying ribbon two px wide with lighter frill edge."""
    R = R or r5(RAMP["pine"]); ph = rnd.random() * 6
    for k in range(h):
        xx = x + int(math.sin(k / 4.5 + ph) * 2) + lean * k // 7
        cv.put(xx, y + k, R[1 if k % 6 else 0]); cv.put(xx + 1, y + k, R[2 if k % 5 else 3])
        if k % 9 == 4: cv.put(xx - 1, y + k, R[0]); cv.put(xx + 2, y + k, R[3])
    cv.put(x + int(math.sin((h - 1) / 4.5 + ph) * 2) + lean * (h - 1) // 7, y + h, R[3])
def hd_crack(cv, x, y, n, rnd, R, d=1, S=None):
    xx = x
    for k in range(n):
        if rnd.random() < .35: xx += d
        if S is None or (xx, y + k) in S:
            cv.put(xx, y + k, R[4]); 
            if k % 2 == 0 and (S is None or (xx + 1, y + k) in S): cv.put(xx + 1, y + k, R[3])
            if (S is None or (xx - 1, y + k) in S) and k % 3 == 0: cv.put(xx - 1, y + k, R[0])   # lit lip
def hd_shell(cv, x, y, s, P, rnd, flip=False):
    """fan shell (scallop) with ridges: s = radius."""
    for dy in range(-s, 1):
        w = int(round(math.sqrt(max(0, s * s - dy * dy)))) + 0
        for dx in range(-w, w + 1):
            ang = math.atan2(-dy, dx) if (dx or dy) else 0
            ridge = int(round(ang * 5)) % 2
            c = P[0] if (dx + dy) < -s * .5 else P[1] if ridge else P[2] if dx > s // 2 else P[1]
            if abs(dx) >= w - 0 and dy > -s: c = P[3]
            cv.put(x + dx, y + dy, c)
    for dx in range(-s // 2, s // 2 + 1): cv.put(x + dx, y + 1, P[3])
    cv.put(x, y, P[3]); cv.put(x - 1, y - 1, P[0]); cv.put(x, y + 2, P[3]) if s > 3 else None
def hd_spiral(cv, x, y, s, P, rnd):
    for yy in range(-s, s + 1):
        for xx in range(-s, s + 1):
            d = math.sqrt(xx * xx + yy * yy)
            if d <= s + .4: cv.put(x + xx, y + yy, P[0] if xx + yy < -s * .5 else P[1] if xx + yy < s * .4 else P[2])
    for a in range(0, 720, 14):
        r = s * (1 - a / 820.0); cv.put(x + int(round(math.cos(math.radians(a)) * r)), y + int(round(math.sin(math.radians(a)) * r)), P[3])
    cv.put(x - 1, y - 1, CREAM)

# ------------------------------------------------------------------ 307
# ---- polish-pass helpers
def logh(cv, x0, x1, y0, h, rnd, R=None):
    """horizontal driftwood log, lit from the top, with a ring end on the left and grain lines"""
    R = R or r5(RAMP["wood"])
    for x in range(x0, x1):
        e = min(x - x0, x1 - 1 - x)
        for r in range(h):
            if e < 3 and (r < 3 - e or r >= h - 3 + e): continue
            u = r / float(h - 1); t = 0 if u < .18 else 1 if u < .45 else 2 if u < .75 else 3
            if (x * 5 + r * 3) % 17 == 0: t = min(4, t + 1)
            if r in (h // 2,) and (x // 6) % 3 == 0: t = min(4, t + 1)
            cv.put(x, y0 + r, R[t])
    for dy in range(h - 2):
        for dx in range(4):
            if (dx - 1.5) ** 2 / 4 + (dy - (h - 2) / 2.0) ** 2 / max(1, ((h - 2) / 2.0) ** 2) <= 1: cv.put(x0 + dx, y0 + 1 + dy, R[0] if dx == 1 or dy % 3 == 1 else R[1])
def stick(cv, x0, y0, x1, y1, w=3, R=None):
    R = R or RAMP["wood"]; n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i // n; y = y0 + (y1 - y0) * i // n
        for k in range(w): cv.put(x + k, y, R[0 if k == 0 else 1 if k < w - 1 else 3])
def weed(cv, x, y, h, rnd, lean=1, R=None):
    R = R or RAMP["pine"]
    for k in range(h):
        xx = x + int(math.sin(k / 5.0 + x) * 2) + lean * k // 6
        cv.put(xx, y - k, R[1 if k % 5 else 0]); cv.put(xx + 1, y - k, R[2])
        if k % 7 == 3: disc(cv, xx - 2, y - k, 2, R[0])
def prints(cv, x, y, c, flip=1):
    for dx, dy in ((0, 0), (-3, -3), (3, -3), (0, -4)):
        pass
    cv.put(x, y, c); cv.put(x, y - 1, c); cv.put(x, y - 2, c); cv.put(x - 2, y - 3, c); cv.put(x + 2, y - 3, c); cv.put(x - 1, y - 2, c); cv.put(x + 1, y - 2, c)
def bottle(cv, x, y, lean=1):
    """green bottle stuck neck-up in the sand; y is where it sits"""
    G = [H("#d4f5d0"), H("#8fd4a0"), H("#4fa07c"), H("#2c6358")]
    for k in range(40):
        bx = x + lean * (40 - k) // 6; w = 8 if k < 26 else 3
        for dx in range(-w, w + 1):
            if k < 26 or abs(dx) <= 3: cv.put(bx + dx, y - k, G[0] if dx < -w + 2 else G[1] if dx < w - 2 else G[2])
    for k in range(26, 38):
        bx = x + lean * (40 - k) // 6
        for dx in range(-2, 3): cv.put(bx + dx, y - k - 1, G[1] if dx < 2 else G[2])
    bx = x + lean * 2 // 6 * 0
    tx = x + lean * (40 - 38) // 6
    for dx in range(-3, 4): cv.put(tx + dx, y - 40, RAMP["wood"][1]); cv.put(tx + dx, y - 41, RAMP["wood"][0]); cv.put(tx + dx, y - 39, RAMP["wood"][2])
    for k in range(14): cv.put(x - 2 + (k % 2), y - 8 - k, CREAM); cv.put(x + (k % 2) + 1, y - 8 - k, RAMP["sand"][1])   # the message inside
def cairn(cv, cx, base, n, rnd, cols, w0=18):
    y = base
    for i in range(n):
        rx = max(5, int(w0 * (1 - i * .15) + rnd.randint(-1, 2))); ry = max(3, int(rx * .55))
        pebble_(cv, cx + rnd.randint(-2, 2), y - ry, rx, ry, cols[(i * 3 + 1) % len(cols)], rnd); y -= int(ry * 1.7)
    return y
def para(cv, pts_fn, x0, x1, y0, y1, colfn):
    for y in range(y0, y1):
        for x in range(x0, x1):
            if pts_fn(x, y): cv.put(x, y, colfn(x, y))
def lm_tideline(rnd, cv):   # 330 x 124
    W = 330; SD = RAMP["sand"]
    top = lambda x: 82 + int(math.sin(x / 40.0) * 6); bot = lambda x: 118 + int(math.sin(x / 40.0 + 1) * 3)
    for y in range(70, 124):   # wide curved wet-sand band
        for x in range(4, W - 4):
            if y < top(x) or y > bot(x): continue
            e = min(x - 4, W - 5 - x)
            if e < 14 and (y - top(x)) * 14 < (14 - e) * (bot(x) - top(x)): continue
            t = 1 if y < top(x) + 5 else 2 if y < bot(x) - 12 else 3
            if (x * 7 + y * 3) % 13 == 0: t = max(0, t - 1)
            cv.put(x, y, SD[t])
    for x in range(6, W - 6):   # foam edge, two rows
        if x % 5 != 0: cv.put(x, top(x), CREAM); cv.put(x, top(x) + 1, RAMP["sea"][0] if x % 2 else CREAM)
        if x % 9 < 4: cv.put(x, top(x) - 2 + (x // 9) % 2, RAMP["sea"][0])
    for x in range(10, W - 10, 5): cv.put(x, bot(x) - 1 + (x % 3), SD[3])
    for x in range(12, W - 10, 11):   # ripples in the wet sand
        hline(cv, x, x + 5, top(x) + 12 + (x // 11) % 3 * 3, SD[1])
    # driftwood log with a branch and draped weed, left
    logh(cv, 22, 122, 94, 14, rnd)
    stick(cv, 58, 96, 38, 30, 5); stick(cv, 44, 66, 70, 36, 4); stick(cv, 47, 78, 22, 44, 4); stick(cv, 40, 40, 30, 10, 3); stick(cv, 38, 40, 52, 16, 3); stick(cv, 68, 38, 80, 24, 3)
    weed(cv, 64, 96, 18, rnd, -1); weed(cv, 100, 96, 14, rnd, 1)
    # crab waving from a tide-line rock
    lump(cv, 188, 100, 24, 16, r5(RAMP["stone"]), rnd, .1)
    crab(cv, 188, 52, 3, rnd, wave=True)
    gull(cv, 112, 76, 2, True)
    # bottle with a message
    bottle(cv, 244, 116, -1)
    # shell piles at both ends
    for cx, base, rx, ry in ((292, 112, 28, 26), (136, 116, 18, 14)):
        mound(cv, cx, base, rx, ry, r5(SD), rnd, .1)
    cols = ["gold", "petal", "sand", "snow", "ember", "dusk"]
    for i in range(34):
        cx, rx, ry, base = (292, 28, 26, 112) if i < 24 else (136, 18, 14, 116)
        a = rnd.random() * 3.14; r = math.sqrt(rnd.random()) * .85
        x = int(cx + math.cos(a) * rx * r * (1 if rnd.random() < .5 else -1)); y = int(base - math.sin(a) * ry * r)
        if i % 4 == 0: spiral(cv, x, y, 4, cols[i % 6])
        else: shell(cv, x, y, 4 + i % 2, cols[i % 6], rnd)
    n = 0
    for x in range(18, 300, 17):   # the long line of shells along the foam
        if 270 < x < 314: continue
        y = top(x) + 18 + rnd.randint(-2, 5) if x < 150 else top(x) + 14 + rnd.randint(-2, 4); n += 1
        if 100 < x < 170 and y > 92: continue
        if n % 3 == 0: spiral(cv, x, y, 4, cols[n % 6])
        else: shell(cv, x, y, 5 if n % 2 else 4, cols[n % 6], rnd)
    for x, y in ((196, 110), (214, 104), (262, 100), (246, 94), (150, 108), (160, 111)):   # bird footprints
        prints(cv, x, y, SD[3])
    # a lonely sock on a stick
    stick(cv, 308, 100, 310, 14, 4); rect(cv, 314, 14, 328, 24, RAMP["ember"][1]); rect(cv, 314, 24, 322, 40, RAMP["ember"][2]); rect(cv, 314, 36, 328, 46, RAMP["ember"][2]); rect(cv, 314, 14, 328, 18, CREAM); rect(cv, 314, 28, 322, 31, CREAM)
    weed(cv, 214, 86, 10, rnd, 1); weed(cv, 20, 90, 12, rnd, 1)
    for _ in range(10):
        x = rnd.randint(14, W - 14); pebble_(cv, x, top(x) + rnd.randint(8, 24), rnd.randint(2, 3), 2, rnd.choice([H("#aab0c0"), H("#8c8ca0"), H("#d8c8b0")]), rnd)

def barnacles(cv, cx, cy, rx, ry, n, rnd):
    for _ in range(n):
        a = rnd.random() * 6.28; r = math.sqrt(rnd.random()) * .8
        x, y = int(cx + math.cos(a) * rx * r), int(cy + math.sin(a) * ry * r)
        for dy in range(-3, 1):
            for dx in range(-3 - dy // 2, 4 + dy // 2): cv.put(x + dx, y + dy, CREAM if dx < 1 else RAMP["snow"][1])
        cv.put(x, y - 3, RAMP["stone"][3]); cv.put(x - 1, y - 2, RAMP["stone"][3]); cv.put(x + 1, y - 2, RAMP["stone"][3])
def face(cv, x, y, s=1):
    for ex in (x - 10 * s, x + 10 * s):
        rect(cv, ex, y, ex + 5 * s, y + 7 * s, CREAM); rect(cv, ex + s, y + 2 * s, ex + 4 * s, y + 7 * s, INK); cv.put(ex + s, y + 2 * s, CREAM)
    for k in range(-12 * s, 13 * s): cv.put(x + 2 + k, y + 14 * s - (k * k) // (24 * s) + 6 * s, RAMP["ember"][2]); cv.put(x + 2 + k, y + 15 * s - (k * k) // (24 * s) + 6 * s, RAMP["ember"][3]) if abs(k) < 11 * s else None
def starfish(cv, x, y, c="ember"):
    P = RAMP[c]
    for a in range(5):
        ang = math.radians(-90 + a * 72)
        for k in range(1, 9): disc(cv, x + int(math.cos(ang) * k), y + int(math.sin(ang) * k), max(1, 3 - k // 3), P[1] if k % 3 else P[0])
    disc(cv, x, y, 3, P[1]); cv.put(x, y, P[3])
def lm_barnacles(rnd, cv):   # 270 x 190
    S = r5(RAMP["stone"])
    lump(cv, 48, 148, 46, 38, S, rnd, .1); lump(cv, 224, 152, 44, 34, S, rnd, .1); lump(cv, 135, 104, 74, 80, S, rnd, .1)
    lump(cv, 94, 160, 28, 22, S, rnd, .1)
    for (cx, cy, rx, ry, n) in ((48, 148, 42, 32, 14), (224, 152, 40, 28, 14), (135, 104, 68, 70, 44), (94, 160, 24, 16, 6)): barnacles(cv, cx, cy, rx, ry, n, rnd)
    face(cv, 133, 76, 1)   # smiling face on the big one
    for (fx, fy) in ((36, 134), (219, 138)):   # the little ones smile too
        for ex in (fx - 6, fx + 8): rect(cv, ex, fy, ex + 4, fy + 5, CREAM); cv.put(ex + 1, fy + 1, INK); cv.put(ex + 1, fy + 2, INK); cv.put(ex + 2, fy + 2, INK)
        for k in range(-7, 8): cv.put(fx + 2 + k, fy + 12 - (k * k) // 14, INK)
    for x in range(70, 200, 6):   # tide mark: a pale line of dried salt
        cv.put(x, 132 + (x // 6) % 2, CREAM)
    for k in range(5):   # weed hanging off the big rock like hair
        x = 96 + k * 20; h = rnd.randint(18, 30)
        for j in range(h): cv.put(x + int(math.sin(j / 4.0 + k) * 2), 34 + j, RAMP["pine"][1 if j % 4 else 0]); cv.put(x + 1 + int(math.sin(j / 4.0 + k) * 2), 34 + j, RAMP["pine"][2])
    starfish(cv, 38, 160, "ember"); starfish(cv, 224, 128, "gold")
    crab(cv, 196, 160, 1, rnd)   # a small crab who agrees
    for x in range(8, 262):   # wet foot with weed and foam
        if x % 4 == 0 and cv.get(x, 184)[3] == 0: cv.put(x, 188, RAMP["moss"][2]); cv.put(x, 187, RAMP["moss"][1])
    for x in range(8, 262, 7): cv.put(x, 189, RAMP["sea"][0]); cv.put(x + 1, 189, CREAM)
def lm_shellhollow(rnd, cv):   # 260 x 160
    S = r5(RAMP["stone"]); A = r5(RAMP["sand"]); M = r5(RAMP["moss"]); PE = r5(RAMP["petal"]); GO = r5(RAMP["gold"]); SN = r5(RAMP["snow"]); SE = r5(RAMP["sea"]); PI = r5(RAMP["pine"])
    cx, base = 130, 154
    nz = hd_noise(rnd, 6); nz2 = hd_noise(rnd, 3); nz3 = hd_noise(rnd, 15)
    rock = hd_rock(cv, cx, base, 122, 108, rnd, S, 2.3, 62, 11, 1, 3.5, 1.25)
    RS = set(rock)
    def dh(x, y): return ((x + .5 - cx) / 82.0) ** 2 + ((y + .5 - base - 6) / 62.0) ** 2
    def inhol(x, y): return (x, y) in RS and dh(x, y) <= 1 + (nz2(x, y) - .5) * .1
    hol = set(p for p in RS if inhol(*p))
    def wall_y(x): return 124 - 9 * (1 - ((x - cx) / 82.0) ** 2) + (nz(x, 7) - .5) * 4
    # ---- the hollow: shaded back wall, sand floor
    for (x, y) in hol:
        d = dh(x, y)
        if y < wall_y(x):   # back wall: deep rock in shadow, strata
            v = 2.7 + d * 1.2 + (nz2(x, y) - .5) * 1.4 + ((y // 7) % 2) * .35
            if (y - 100) % 7 == 0 and nz3(x, y) > .3: v += 1.2
            cv.put(x, y, S[hd_tone(v, x, y)])
        else:
            u = (y - wall_y(x)) / 40.0
            v = 3.1 - u * 2.9 + d * 1.0 + (nz2(x + 9, y) - .5) * 1.1
            cv.put(x, y, A[hd_tone(v, x, y)])
    for (x, y) in hol:   # soft cast shadow of the overhang onto the floor, dithered
        if wall_y(x) <= y < wall_y(x) + 5 and (x + y) % 2 == 0: cv.put(x, y, A[3])
    for k in range(7):   # ripple ridges in the sand, curved, with a lit crest and a dark trough
        yk = 126 + k * 4.6
        for x in range(cx - 80, cx + 81):
            y = int(yk + 2.2 * math.sin(x / 7.5 + k * 1.7) + (x - cx) ** 2 / 4200.0 * (1 + k * .2))
            if (x, y) in hol and (x, y + 1) in hol and y > wall_y(x) + 5 and (x * 5 + k * 3) % 9 < 6: cv.put(x, y, A[0]); cv.put(x, y + 1, A[3] if (x + k) % 2 else A[2])
    for _ in range(90):   # grains: dark and pale single pixels
        x, y = rnd.randint(cx - 80, cx + 80), rnd.randint(100, 152)
        if (x, y) in hol and y > wall_y(x) + 3: cv.put(x, y, A[0] if rnd.random() < .5 else A[3])
    # lip of the hollow: lit rim on the upper left, shadow lip on the right/bottom
    for (x, y) in hol:
        if dh(x, y) > .93 and (x + 1, y + 1) in hol or (dh(x, y) > .93):
            a = math.atan2(y - (base + 6), x - cx)
            if y < base - 2: cv.put(x, y, S[4] if (x + y) % 2 else S[3])
    for (x, y) in list(RS - hol):
        if .98 < dh(x, y) < 1.17 and y < base - 2:
            a = (x - cx) + (y - base) * .8
            cv.put(x, y, S[0] if a < -10 and (x + y) % 3 else S[1] if a < 20 else S[2] if (x + y) % 2 else S[3])
    # ---- shells: ring of embedded ones on the lip, loose ones on the sand
    PALS = [(PE, 'p'), (GO, 'g'), (SN, 's'), (SE, 'e')]
    def put_shell(x, y, s, kind, pal):
        for xx in range(x - s - 1, x + s + 3): cv.put(xx, y + 1, A[4] if y > wall_y(xx) and (xx, y + 1) in hol else cv.get(xx, y + 1)) if (xx + y) % 2 == 0 and cv.get(xx, y + 1) in A else None   # contact shadow
        (hd_spiral(cv, x, y - s, s, pal, rnd) if kind == 0 else hd_shell(cv, x, y, s, pal, rnd))
    for a in range(200, 345, 8):
        x = cx + int(math.cos(math.radians(a)) * 83); y = base + 6 + int(math.sin(math.radians(a)) * 62)
        if (x, y) in RS: 
            pal = PALS[(a // 8) % 4][0]; (hd_spiral(cv, x, y, 3 + (a % 3 == 0), pal, rnd) if (a // 8) % 2 else hd_shell(cv, x, y + 3, 3 + (a % 3 == 0), pal, rnd))
    loose = [(62, 144, 5, 1), (84, 134, 4, 0), (100, 146, 6, 1), (118, 138, 3, 0), (150, 142, 4, 1), (168, 133, 5, 0), (186, 145, 6, 1), (204, 138, 4, 0), (132, 150, 7, 1), (72, 150, 3, 0), (222, 148, 3, 1), (110, 130, 3, 1), (176, 128, 3, 1), (92, 128, 3, 0), (153, 131, 3, 0)]
    for i, (x, y, s, k) in enumerate(loose):
        if (x, y) in hol or (x, y - s) in hol: put_shell(x, y, s, k, PALS[i % 4][0])
    # a small starfish and a cone shell
    for a_ in range(5):
        ang = math.radians(-90 + a_ * 72)
        for k in range(1, 6): cv.put(144 + int(math.cos(ang) * k), 128 + int(math.sin(ang) * k * .8), GO[1 if k % 2 else 0])
    cv.put(144, 128, GO[3]); cv.put(145, 127, CREAM)
    for k in range(7): cv.put(95 + k // 2 - (k > 3) * 0, 118 + k, SN[1] if k % 2 else SN[0]); cv.put(96 + k // 2, 118 + k, SN[2])   # cone shell standing in the sand
    # echo arcs rising from the big shell, drawn as dashes
    for k in range(3):
        for a in range(-60, 61, 6):
            r = 20 + k * 11; x = cx + int(math.cos(math.radians(a - 90)) * r); y = 138 + int(math.sin(math.radians(a - 90)) * r * .7)
            if (x, y) in hol and a % 12 == 0: cv.put(x, y, CREAM if k % 2 == 0 else SE[0]); cv.put(x + 1, y, CREAM if k % 2 == 0 else SE[1])
    # ---- fossil shells, cracks, barnacle crust and weed on the dome
    out = [p for p in RS if p not in hol]; OS = set(out)
    for (fx, fy, fs) in ((50, 112, 7), (206, 88, 8), (96, 70, 6), (158, 62, 5), (230, 124, 5), (30, 138, 4)):
        if (fx, fy) in OS:
            for yy in range(fy - fs - 1, fy + fs + 2):
                for xx in range(fx - fs - 1, fx + fs + 2):
                    if (xx, yy) in OS and (xx - fx) ** 2 + (yy - fy) ** 2 <= (fs + 1) ** 2: cv.put(xx, yy, S[4] if (xx - fx) + (yy - fy) > 0 else S[3])
            hd_spiral(cv, fx - 0, fy - 0, fs - 1, [S[0], mix(CREAM, S[1], .4), S[1], S[3]], rnd)
            for k in range(-fs, fs): cv.put(fx + k, fy + fs + 1, S[0]) if (fx + k, fy + fs + 1) in OS and k % 3 == 0 else None
    for (x, y, n, d) in ((84, 54, 18, 1), (170, 80, 22, -1), (210, 110, 14, -1), (40, 98, 16, 1), (126, 40, 10, 1), (60, 76, 12, -1)):
        hd_crack(cv, x, y, n, rnd, S, d, OS)
    def low(x, y): return y > 98 and (x, y) in OS and (x < cx - 60 or x > cx + 60 or y > 146)
    hd_barnacles(cv, out, S, 26, rnd, low, 5)
    # tide stain: a wavy dark band low on the flanks, wet green near the foot
    for (x, y) in out:
        edge = 120 + 8 * math.sin(x / 9.0) + 6 * (nz(x, 2) - .5) + abs(x - cx) * -.22 + (abs(x - cx) > 90) * 0
        if y > edge + 12:
            if cv.get(x, y) in S and (x + y) % 2 == 0 or y > edge + 22 and cv.get(x, y) in S: cv.put(x, y, M[hd_tone(2.4 + (y - edge) * .05 + (nz2(x, y) - .5) * 2, x, y)] if nz3(x * 2, y) > .5 else S[hd_tone(3.2 + (nz2(x, y) - .5) * 1.5, x, y)])
        elif y > edge and (x + y) % 3 == 0 and cv.get(x, y) in S: cv.put(x, y, S[min(4, hd_idx(cv.get(x, y), S) + 1)])
    for x in range(14, 250, 3):
        y = int(120 + 8 * math.sin(x / 9.0) + 6 * (nz(x, 2) - .5) + abs(x - cx) * -.22) + 12
        if (x, y) in OS and nz3(x * 3, 0) > .4 and cv.get(x, y) not in A: hd_weed(cv, x, y, rnd.randint(6, 16), rnd, rnd.choice((-1, 1)), PI)
    for _ in range(8):   # limpets: pale low cones
        x, y = rnd.randint(14, 246), rnd.randint(118, 150)
        if (x, y) in OS: cv.put(x - 1, y, SN[1]); cv.put(x, y, SN[0]); cv.put(x + 1, y, SN[2]); cv.put(x, y - 1, SN[1]); cv.put(x + 2, y, S[4]); cv.put(x, y + 1, S[4]); cv.put(x - 1, y + 1, S[3])
    # moss cushions and sea-thrift on the top ledges
    for (mx_, my_, w_) in ((120, 54, 18), (160, 50, 12), (84, 66, 10), (176, 74, 8)):
        for yy in range(my_ - 4, my_ + 5):
            for xx in range(mx_ - w_, mx_ + w_ + 1):
                if (xx, yy) in OS and ((xx - mx_) / float(w_)) ** 2 + ((yy - my_) / 4.0) ** 2 + (nz2(xx, yy) - .5) * .6 <= 1: cv.put(xx, yy, M[hd_tone(1.0 + (yy - my_ + 4) * .35 + (nz2(xx + 4, yy) - .5), xx, yy)])
        for k in range(w_ // 2): hd_tuft(cv, mx_ - w_ + 2 + k * 4, my_ + 1, 3, 4, M, rnd, 2, 0, 2) if (mx_ - w_ + 2 + k * 4, my_ + 1) in OS else None
        for k in range(w_ // 4):
            x, y = mx_ - w_ + rnd.randint(0, 2 * w_), my_ + rnd.randint(-2, 1)
            if (x, y) in OS: cv.put(x, y, PE[1]); cv.put(x - 1, y, PE[0]); cv.put(x + 1, y, PE[2]); cv.put(x, y - 1, PE[0]); cv.put(x, y + 1, M[3])
    for _ in range(40):   # lichen
        x, y = rnd.randint(20, 240), rnd.randint(50, 130)
        if (x, y) in OS and cv.get(x, y) in S[:3]: cv.put(x, y, GO[1] if rnd.random() < .6 else GO[0]); cv.put(x + 1, y, GO[2]) if rnd.random() < .4 and (x + 1, y) in OS else None
    # pebbles at the foot and a line of foam
    for x in range(6, 256, 11):
        pe = [mix(S[1], CREAM, .3), S[1], S[2], S[3], S[4]]; lump(cv, x + rnd.randint(-2, 2), base - 1 + rnd.randint(0, 2), rnd.randint(3, 5), rnd.randint(2, 3), pe, rnd, .1)
    for x in range(10, 252, 7): cv.put(x, base + 4, SE[0]); cv.put(x + 1, base + 4, CREAM); cv.put(x + 3, base + 5, SE[1])
    hd_bounce(cv, RS, S, lambda x, y: (x - cx) * .8 + (y - base) > 40 and x > cx + 20, 1, 4)
def lm_sandcastle(rnd, cv):   # 230 x 200
    _pond(cv, 115, 178, 108, 17, rnd)
    Sd = r5(RAMP["sand"])
    mound(cv, 115, 182, 82, 20, Sd, rnd, .12)
    def tower(cx, w, top, base):
        _col(cv, cx - w // 2, cx + w // 2, top, base, Sd, rnd, .1)
        for x in range(cx - w // 2, cx + w // 2 + 1, 4): rect(cv, x, top - 6, x + 3, top, Sd[1 if x < cx else 2])   # crenels
        for y in range(top + 12, base, 14): hline(cv, cx - w // 2, cx + w // 2, y, Sd[3])
        rect(cv, cx - 3, base - 18, cx + 3, base, Sd[4]); disc(cv, cx, base - 18, 3, Sd[4])
    for cx, w, top in ((50, 28, 118), (180, 28, 118), (78, 24, 98), (152, 24, 98), (115, 30, 70)):
        tower(cx, w, top, 176)
    _col(cv, 64, 166, 126, 180, Sd, rnd, .1)   # curtain wall
    for x in range(64, 166, 8): rect(cv, x, 120, x + 4, 126, Sd[1 if x < 115 else 2])
    rect(cv, 105, 150, 125, 180, Sd[4]); disc(cv, 115, 150, 10, Sd[4])
    for x in range(106, 125, 3): vline(cv, x, 150, 180, Sd[3])   # portcullis
    tower(115, 30, 70, 126)
    for ty, tx in ((50, 78), (50, 152)): pass
    for tx in (50, 180, 78, 152): disc(cv, tx, 108 if tx in (78, 152) else 126, 0, Sd[0])
    for tx, ty in ((78, 84), (152, 84), (50, 104), (180, 104)):   # cone roofs
        for k in range(14): hline(cv, tx - 14 + k, tx + 14 - k, ty - k + 14 - 14 + 0, RAMP["petal"][1 if k < 8 else 2]) if False else None
    vline(cv, 152, 40, 92, RAMP["wood"][2]); vline(cv, 153, 40, 92, RAMP["wood"][3])
    for k in range(14):   # the flag
        hline(cv, 154, 180 - k // 2, 42 + k, RAMP["ember"][1 if k < 7 else 2])
    hline(cv, 154, 178, 42, RAMP["ember"][0])
    for sx in (-1, 1):
        for k in range(8): cv.put(115 + sx * 20 + sx * k, 188 + k % 2, RAMP["sea"][0])
    crab(cv, 115, 48, 1, rnd, wave=True)   # crab in charge, on the top
    for k in range(8): cv.put(40 + k * 22, 198, RAMP["sea"][0]); cv.put(41 + k * 22, 198, CREAM)
    shell(cv, 25, 192, 4, "petal", rnd); shell(cv, 204, 192, 4, "gold", rnd)

# ------------------------------------------------------------------ 308
def lm_pebblebar(rnd, cv):   # 300 x 170
    PC = [H(h) for h in ("#e86a5c", "#f2b84b", "#7cc0d8", "#a98fd8", "#8fd18a", "#f08fb0", "#fff0d0", "#6f7aa8", "#e0a070", "#3a4a58")]
    mound(cv, 150, 164, 144, 44, r5(RAMP["sand"]), rnd, .08)
    for _ in range(330):
        x = rnd.randint(14, 286); y = rnd.randint(130, 164)
        e = ((x - 150) / 140.0) ** 2 + ((y - 164) / 40.0) ** 2
        if e > .9: continue
        pebble_(cv, x, y, rnd.randint(3, 6), rnd.randint(2, 4), rnd.choice(PC), rnd)
    # tilted pebble mosaic: a rainbow on a sheared slab
    sh = lambda y: int((y - 130) * .28)
    X0, X1, Y0, Y1 = 98, 206, 52, 134
    def inside(x, y): return X0 + sh(y) <= x < X1 + sh(y) and Y0 <= y < Y1
    def slab(x, y):
        u = (x - X0 - sh(y)) / float(X1 - X0); t = 1 if u < .1 else 2 if u < .8 else 3
        if y < Y0 + 2: t = 0
        if y >= Y1 - 4: t = 4
        if (x * 3 + y * 7) % 19 == 0 and t < 3: t += 1
        return r5(RAMP["stone"])[t]
    para(cv, inside, X0 - 40, X1 + 40, Y0, Y1, slab)
    cx0, cy0 = 152, 124
    for i, rr in enumerate(range(40, 6, -6)):
        c = PC[i % 6]
        for a in range(190, 351, 14 if rr > 20 else 24):
            px = cx0 + int(math.cos(math.radians(a)) * rr * 1.15) + sh(int(cy0 + math.sin(math.radians(a)) * rr)); py = cy0 + int(math.sin(math.radians(a)) * rr)
            if Y0 + 4 < py < Y1 - 3: pebble_(cv, px, py, 4, 3, c, rnd)
    for k in range(6): pebble_(cv, 124 + k * 12 + sh(128), 129, 4, 3, PC[(k + 2) % 10], rnd) if False else None
    # three pebble cairns, topped with a tiny gnome hat
    for cx, base, n, w0 in ((46, 152, 6, 20), (250, 150, 7, 22), (92, 162, 4, 14)):
        ty = cairn(cv, cx, base, n, rnd, PC, w0)
        if cx == 46 or cx == 250:
            for k in range(14): hline(cv, cx - 5 + k // 3, cx + 6 - k // 3, ty - 2 - k, RAMP["ember"][1 if k < 7 else 2])
            hline(cv, cx - 7, cx + 8, ty - 2, CREAM)
    cairn(cv, 206, 158, 3, rnd, PC, 12)
    for x, y in ((20, 150), (276, 160)):   # strand of weed on the bar
        weed(cv, x, y, 12, rnd, 1)
    for _ in range(14):   # the white one with a stripe
        x = rnd.randint(30, 270); y = rnd.randint(144, 162); pebble_(cv, x, y, 6, 4, CREAM, rnd); hline(cv, x - 4, x + 5, y, RAMP["stone"][1])
def ribbon(cv, x, y0, ln, w, rnd, ph=0, R=None):
    R = R or RAMP["pine"]
    for k in range(ln):
        xx = x + int(math.sin(k / 7.0 + ph) * 3); ww = w - (k * 2) // max(1, ln // 2) if k > ln - 8 else w
        for dx in range(max(2, ww)):
            t = 0 if dx == 0 else 1 if dx < ww // 2 else 2 if dx < ww - 1 else 3
            if (k + dx) % 9 == 0: t = max(0, t - 1)
            cv.put(xx + dx, y0 + k, R[t])
def float_(cv, x, y, r, c):
    disc(cv, x, y, r, RAMP[c][1]); disc(cv, x - 1, y - 1, max(1, r - 2), RAMP[c][0]); cv.put(x + r // 2, y + r // 2, RAMP[c][3]); hline(cv, x - r + 1, x + r, y + r - 1, RAMP[c][2])
def rack(cv, x0, x1, base, top, rnd, ph):
    W = RAMP["wood"]
    for px in (x0, x1):
        stick(cv, px, base, px + 3, top, 5); stick(cv, px - 10, base, px, top + 14, 3); stick(cv, px + 14, base, px + 4, top + 14, 3)
    for y in range(top, top + 5): hline(cv, x0 - 4, x1 + 9, y, W[0] if y == top else W[1] if y < top + 3 else W[3])
    n = (x1 - x0) // 13
    for i in range(n):
        x = x0 + 8 + i * 13; ln = rnd.randint(40, 64) if i % 2 == 0 else rnd.randint(28, 44)
        ribbon(cv, x, top + 5, ln, 7, rnd, ph + i)
    for x in (x0 - 2, x1 + 5): float_(cv, x, top - 6, 6, "gold" if x < x0 else "ember")
def lm_kelp(rnd, cv):   # 320 x 124
    G = RAMP["pine"]
    rack(cv, 24, 112, 116, 22, rnd, 0)
    rack(cv, 214, 298, 116, 30, rnd, 2)
    for x in range(6, 314):   # the long line of kelp on the ground
        yy = 108 + int(math.sin(x / 11.0) * 3) + int(math.sin(x / 31.0) * 4)
        for y in range(yy - 3, yy + 3): cv.put(x, y, G[1 if y < yy else 2 if y < yy + 2 else 3])
        if x % 17 == 0: disc(cv, x, yy - 5, 4, G[0]); disc(cv, x + 1, yy - 4, 2, G[1])
    # tall centre pole with streamers and a bobbing float on top
    stick(cv, 160, 118, 162, 4, 5)
    for i, (ln, dx, y0) in enumerate(((60, 5, 16), (80, -9, 24), (50, 5, 52), (70, -9, 60))):
        ribbon(cv, 160 + dx, y0, ln, 8, rnd, i * 2)
    float_(cv, 162, 8, 7, "ember"); float_(cv, 148, 100, 7, "gold"); float_(cv, 182, 102, 6, "ember")
    lump(cv, 135, 102, 20, 12, r5(G), rnd, .12); lump(cv, 190, 104, 16, 9, r5(G), rnd, .12)   # heaps
    for x, y in ((130, 98), (196, 100)): disc(cv, x, y, 3, G[0])
def mask_ell(cv, cx, cy, rx, ry):
    for y in range(cv.h):
        for x in range(cv.w):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1: cv.p[x, y] = (0, 0, 0, 0)
def bollard(cv, x, y, h, rnd):
    S = RAMP["stone"]
    for xx in range(x - 6, x + 7):
        for yy in range(y - h, y):
            u = (xx - x + 6) / 12.0; t = 0 if u < .2 else 1 if u < .45 else 2 if u < .8 else 3
            cv.put(xx, yy, S[t])
    for xx in range(x - 8, x + 9): cv.put(xx, y - h - 1, S[0]); cv.put(xx, y - h, S[1]); cv.put(xx, y - h + 1, S[3])
    hline(cv, x - 6, x + 7, y - h // 2, RAMP["wood"][2]); hline(cv, x - 6, x + 7, y - h // 2 + 1, RAMP["wood"][3]); hline(cv, x - 6, x + 7, y - h // 2 - 1, RAMP["wood"][1])
def lamp(cv, x, y, h, rnd):
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48")]
    for xx in range(x - 2, x + 3):
        for yy in range(y - h, y): cv.put(xx, yy, K[0 if xx == x - 2 else 1 if xx < x + 1 else 3])
    for xx in range(x - 5, x + 6): cv.put(xx, y - 3, K[1]); cv.put(xx, y - 2, K[3])
    stick(cv, x - 1, y - h + 4, x - 12, y - h - 2, 2, K) if False else None
    lx, ly = x, y - h - 12
    rect(cv, lx - 7, ly - 3, lx + 8, ly, K[2]); rect(cv, lx - 6, ly, lx + 7, ly + 14, RAMP["gold"][0]); rect(cv, lx - 4, ly + 2, lx + 5, ly + 12, CREAM)
    for yy in range(ly, ly + 14): cv.put(lx - 6, yy, K[1]); cv.put(lx + 7, yy, K[2]); cv.put(lx, yy, K[1])
    rect(cv, lx - 7, ly + 14, lx + 8, ly + 16, K[2])
    for k in range(5): hline(cv, lx - 5 + k, lx + 7 - k, ly - 4 - k, K[1 if k < 3 else 0])
    disc(cv, lx, ly - 11, 2, RAMP["gold"][1])
def lm_causeway(rnd, cv):   # 330 x 160
    W = 330
    seaband(cv, 4, W - 4, 60, 150, rnd)
    for y in range(60, 150):
        for x in range(4, W - 4):
            e = min(x - 4, W - 5 - x)
            if e < 16 and (y - 60) < (16 - e): cv.p[x, y] = (0, 0, 0, 0)
    for x in range(10, W - 10, 17): waves(cv, x, x + 12, 70 + (x // 17) % 3 * 14, rnd, 1)
    stones = [(28, 104), (68, 100), (108, 106), (148, 100), (188, 106), (228, 100), (268, 104), (306, 100)]
    for i, (x, y) in enumerate(stones):
        lump(cv, x, y, 25, 12, r5(RAMP["stone"]), rnd, .1)
        for k in range(-21, 22, 3): cv.put(x + k, y + 13, CREAM) if (k + i) % 2 else None
        hline(cv, x - 10, x - 3, y - 4, RAMP["stone"][0])
    for x in range(10, W - 10):
        for yy in (66, 138):
            if (x * 3) % 7 < 3: cv.put(x, yy + int(math.sin(x / 8.0) * 2), CREAM)
    mask_ell(cv, 165, 105, 161, 48)
    # rope swagging between bollards
    for bx in (44, 118, 212, 290): bollard(cv, bx, 98, 30, rnd)
    for ax, bx in ((44, 118), (212, 290)):
        for x in range(ax, bx + 1):
            y = 74 + int(math.sin((x - ax) / float(bx - ax) * math.pi) * 14); cv.put(x, y, RAMP["wood"][1]); cv.put(x, y + 1, RAMP["wood"][3])
    for lx in (80, 165, 250): lamp(cv, lx, 96, 62, rnd)
    crab(cv, 148, 86, 1, rnd, wave=True)   # a crab holding the toll
    for x, y in ((10, 100), (320, 104)): weed(cv, x, y, 12, rnd, 1)
def lm_rockpool(rnd, cv):   # 240 x 160
    S = r5(RAMP["stone"]); A = r5(RAMP["sand"]); M = r5(RAMP["moss"]); PE = r5(RAMP["petal"]); GO = r5(RAMP["gold"]); SN = r5(RAMP["snow"]); SE = r5(RAMP["sea"]); PI = r5(RAMP["pine"]); DU = r5(RAMP["dusk"]); EM = r5(RAMP["ember"])
    cx, base = 120, 154; pcx, pcy, prx, pry = 120, 119, 82.0, 26.0
    nz = hd_noise(rnd, 6); nz2 = hd_noise(rnd, 3); nz3 = hd_noise(rnd, 15)
    rock = hd_rock(cv, cx, base, 114, 100, rnd, S, 2.2, 56, 15, 0, 3.3, 1.2)
    RS = set(rock)
    def pd(x, y): return ((x + .5 - pcx) / prx) ** 2 + ((y + .5 - pcy) / pry) ** 2 + (nz2(x, y) - .5) * .12
    pool = set(p for p in RS if pd(*p) <= 1.0)
    # ---- tide-line stain across the dome, with a fringe of barnacles on its upper edge
    def tide(x): return 80 + 7 * math.sin(x / 11.0) + 8 * (nz(x, 3) - .5) + (abs(x - cx) / 114.0) ** 2 * 10
    out = [p for p in RS if p not in pool]; OS = set(out)
    for (x, y) in out:
        e = y - tide(x)
        if e > 0 and (e > 6 or (x + y) % 2 == 0) and cv.get(x, y) in S:
            i = hd_idx(cv.get(x, y), S); v = i + 1.2 + (e / 14.0) * .6 + (nz2(x, y) - .5) * 1.6
            cv.put(x, y, S[hd_tone(v, x, y)] if nz3(x * 2, y * 1.5) < .55 else M[hd_tone(2.5 + (nz2(x + 3, y) - .5) * 2 + e * .02, x, y)])
    fr = [(x, y) for (x, y) in out if -2 < y - tide(x) < 5]
    hd_barnacles(cv, fr, S, 22, rnd, lambda x, y: True, 5)
    for _ in range(9):   # mussels: dark blue ovals with a glint, in a little cluster
        x0, y0 = rnd.randint(20, 220), rnd.randint(int(tide(120)) + 8, 128)
        if (x0, y0) in OS and pd(x0, y0) > 1.5:
            for j in range(rnd.randint(2, 4)):
                x, y = x0 + rnd.randint(-5, 5), y0 + rnd.randint(-3, 3)
                if (x + 3, y + 2) in OS:
                    for dx in range(0, 4): cv.put(x + dx, y + (dx == 0 or dx == 3), DU[3] if dx > 1 else DU[2]); cv.put(x + dx, y + 1 + (dx == 0 or dx == 3), DU[4])
                    cv.put(x + 1, y, DU[0])
    for x in range(14, 230, 4):   # weed hanging off the tide line
        y = int(tide(x)) + 5
        if (x, y) in OS and pd(x, y + 8) > 1.4 and nz3(x * 3, 8) > .35: hd_weed(cv, x, y, rnd.randint(6, 18), rnd, rnd.choice((-1, 1)), PI)
    # ---- the pool: depth-dithered water, shadow under the back rim, sunlit shallows, pebbly bed
    for (x, y) in pool:
        d = pd(x, y); back = y < pcy
        depth = max(0, 1 - d)
        v = .6 + (1 - depth) * -.4 + depth * 2.2 + (nz(x + 5, y * 2) - .5) * 1.0
        if back: v += (1 - (y - (pcy - pry)) / 12.0) * 1.2 * (1 if y < pcy - pry + 12 else 0) if y < pcy - pry + 12 else 0
        v += (x - pcx) / prx * .5
        cv.put(x, y, SE[hd_tone(v, x, y)])
    for (x, y) in pool:   # pebbles on the bed, visible in the shallows
        if pd(x, y) > .55 and nz3(x * 2.1, y * 3.3) > .72 and (x + y) % 2 == 0: cv.put(x, y, A[hd_tone(1.8 + (nz2(x, y) - .5) * 2, x, y)])
    for _ in range(60):   # ripple dashes
        x, y = rnd.randint(pcx - 78, pcx + 78), rnd.randint(pcy - 24, pcy + 24)
        if (x, y) in pool and pd(x, y) < .9:
            for k in range(rnd.randint(3, 8)): cv.put(x + k, y, SE[0]) if (x + k, y) in pool else None; cv.put(x + k + 1, y + 1, SE[3]) if k % 2 == 0 and (x + k + 1, y + 1) in pool else None
    for k in range(6): hd_line(cv, 70 + k * 3, 110 + k, 82 + k * 3, 106 + k, CREAM, lambda a, b: (a, b) in pool) if k % 2 == 0 else None   # sky reflection streaks
    # inner wall of the back rim
    for (x, y) in pool:
        if y < pcy and .8 < pd(x, y) <= 1.0:
            cv.put(x, y, S[hd_tone(2.4 + (pd(x, y) - .8) * 6 + (nz2(x, y) - .5), x, y)] if (x + y) % 3 else SE[3])
    # ---- rim: lit lip in front, shadow face under it, wet dark line along the back
    for (x, y) in out:
        d = pd(x, y)
        if 1.0 < d < 1.07 and y < pcy + 5: cv.put(x, y, S[3] if (x + y) % 2 else S[4])
        elif 1.0 < d < 1.22 and y >= pcy: cv.put(x, y, S[0] if d < 1.12 and (x + y) % 5 else S[1])
        elif 1.22 <= d < 1.34 and y >= pcy: cv.put(x, y, S[3] if (x + y) % 2 else S[4])
        elif 1.0 < d < 1.28 and y < pcy and (x - pcx) < -20: cv.put(x, y, S[1] if (x + y) % 2 else S[0])
    # ---- the island with the crab, and the starfish
    isl = [(x, y) for y in range(pcy - 2, pcy + 8) for x in range(pcx + 6, pcx + 42) if ((x - (pcx + 24)) / 18.0) ** 2 + ((y - (pcy + 5)) / 5.0) ** 2 <= 1]
    lump(cv, pcx + 24, pcy + 3, 18, 7, S, rnd, .1)
    for k in range(12): cv.put(pcx + 8 + k * 3, pcy + 8, SE[0]); cv.put(pcx + 9 + k * 3, pcy + 9, CREAM) if k % 2 else None
    crab(cv, pcx + 24, pcy - 9, 1, rnd, wave=True)
    starfish(cv, pcx - 38, pcy + 6, "ember")
    for k in range(12): cv.put(pcx - 52 + k * 3, pcy + 13, SE[0]); cv.put(pcx - 51 + k * 3, pcy + 14, SE[1]) if k % 2 else None
    # fronds of weed rising from the bed
    for (fx_, fy_, h_) in ((pcx - 58, pcy + 10, 12), (pcx - 12, pcy + 16, 10), (pcx + 62, pcy + 12, 13), (pcx + 4, pcy + 12, 7)):
        ph = rnd.random() * 6
        for k in range(h_):
            x = fx_ + int(math.sin(k / 3.0 + ph) * 1.6); cv.put(x, fy_ - k, PI[1 if k % 4 else 0]); cv.put(x + 1, fy_ - k, PI[2])
            if k % 4 == 2: cv.put(x - 1, fy_ - k, PI[0]); cv.put(x + 2, fy_ - k - 1, PI[0])
    # ---- anemones on the front lip and tucked at the sides
    def anemone(x, y, pal, tip):
        for yy in range(-3, 1):
            for xx in range(-3, 4):
                if abs(xx) <= 3 + yy // 2 + 1 and not (yy == -3 and abs(xx) > 2): cv.put(x + xx, y + yy, pal[0] if xx < -1 else pal[1] if xx < 2 else pal[2])
        for xx in range(-3, 4): cv.put(x + xx, y + 1, pal[3])
        for k in range(-3, 4):   # tentacles waving up from the top
            cv.put(x + k, y - 4 - (abs(k) < 3), pal[1]); cv.put(x + k + (k > 0) - (k < 0), y - 5 - (abs(k) < 3), tip if k % 2 == 0 else pal[0])
        cv.put(x, y - 1, INK)
    anemone(pcx + 58, pcy + 29, PE, CREAM); anemone(pcx - 48, pcy + 30, M, CREAM); anemone(pcx + 30, pcy + 33, PE, SN[0]); anemone(pcx - 80, pcy + 8, M, CREAM); anemone(pcx - 20, pcy + 34, M, CREAM)
    # ---- cracks, lichen, moss on top, a snail shell
    for (x, y, n, d) in ((70, 38, 20, 1), (146, 30, 24, -1), (190, 56, 16, 1), (44, 70, 14, -1), (110, 56, 10, 1)):
        hd_crack(cv, x, y, n, rnd, S, d, OS)
    for _ in range(50):
        x, y = rnd.randint(20, 220), rnd.randint(40, 100)
        if (x, y) in OS and cv.get(x, y) in S[:3]: cv.put(x, y, GO[1] if rnd.random() < .6 else GO[0]); cv.put(x + 1, y, GO[2]) if (x + 1, y) in OS and rnd.random() < .5 else None
    for (mx_, my_, w_) in ((100, 44, 14), (150, 38, 10), (62, 62, 8)):
        for yy in range(my_ - 4, my_ + 5):
            for xx in range(mx_ - w_, mx_ + w_ + 1):
                if (xx, yy) in OS and ((xx - mx_) / float(w_)) ** 2 + ((yy - my_) / 4.0) ** 2 + (nz2(xx, yy) - .5) * .6 <= 1: cv.put(xx, yy, M[hd_tone(1.0 + (yy - my_ + 4) * .35 + (nz2(xx + 4, yy) - .5), xx, yy)])
        for k in range(w_ // 2): hd_tuft(cv, mx_ - w_ + 2 + k * 4, my_ + 1, 3, 4, M, rnd, 2, 0, 2) if (mx_ - w_ + 2 + k * 4, my_ + 1) in OS else None
    for x in range(8, 236, 9):   # pebbles and foam at the foot
        pe = [mix(S[1], CREAM, .3), S[1], S[2], S[3], S[4]]; lump(cv, x + rnd.randint(-2, 2), base + rnd.randint(-1, 1), rnd.randint(3, 5), rnd.randint(2, 3), pe, rnd, .1)
    for x in range(10, 232, 7): cv.put(x, base + 4, SE[0]); cv.put(x + 1, base + 4, CREAM); cv.put(x + 3, base + 5, SE[1])
    hd_bounce(cv, RS, S, lambda x, y: (x - cx) * .8 + (y - base) > 30 and x > cx + 25, 1, 4)
def lm_tidesteps(rnd, cv):   # 280 x 200
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48", "#201f36")]
    steps = [(20, 112, 120), (66, 112, 150), (112, 112, 100)]
    ys = [150, 120, 90, 60]
    for i in range(4):
        x0 = 14 + i * 56; top = ys[i] if i < 4 else 60; x1 = x0 + 74 if i < 3 else 270
        x1 = min(x1, 268)
        for y in range(top, 196):   # block face
            for x in range(x0, x1):
                if y < top + 10: t = 0 if (x - x0) % 29 > 3 else 1   # lit top face
                else: u = (x - x0) / (x1 - x0); t = 1 if u < .2 else 2 if u < .7 else 3
                if rnd.random() < .08: t = min(4, t + 1)
                cv.put(x, y, K[t])
        for y in range(top + 16, 196, 9): hline(cv, x0 + 3, x1 - 3, y, K[4])
        px = (x0 + x1) // 2
        for y in range(top + 1, top + 8):   # teacup pool on the tread
            for x in range(px - 16, px + 17):
                if ((x - px) / 16.0) ** 2 + ((y - top - 4) / 3.5) ** 2 <= 1: cv.put(x, y, RAMP["sea"][1 if y < top + 4 else 2])
        cv.put(px - 7, top + 3, RAMP["sea"][0]); cv.put(px - 6, top + 3, RAMP["sea"][0])
        if i == 1: crab(cv, px, top - 14, 1, rnd) if False else None
    for sx, sy, c in ((84, 118, "snow"), (140, 82, "petal"), (200, 52, "gold")):   # shell on a step
        spiral(cv, sx, sy, 3, c)
    # sea at the foot
    seaband(cv, 8, 272, 192, 199, rnd); waves(cv, 8, 272, 192, rnd, 1)
    for k in range(4): disc(cv, 40 + k * 56, 143 - k * 30 - 2 + 0, 0, CREAM)
    # little seaweed tuft on the top step
    for k in range(6): vline(cv, 240 + k * 3, 48 - k % 3 * 3, 58, RAMP["moss"][1 + k % 2])

# ------------------------------------------------------------------ 314
def lm_driftwood(rnd, cv):   # 300 x 220
    W = r5(RAMP["wood"]); Wd = RAMP["wood"]
    def log(x0, y0, x1, y1, th):   # thick bent log, thickness th
        n = max(abs(x1 - x0), abs(y1 - y0)) * 2
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
            for dy in range(-th // 2, th // 2 + 1):
                for dx in range(-th // 2, th // 2 + 1):
                    if dx * dx + dy * dy <= (th // 2) ** 2 + 2:
                        t = 0 if dx + dy < -th // 3 else 1 if dx + dy < 0 else 2 if dx + dy < th // 3 else 3
                        cv.put(int(x) + dx, int(y) + dy, Wd[t] if (int(x) + dy) % 9 else Wd[min(3, t + 1)])
    # sofa (left): back, seat, arms, tired sag
    sx = 6
    rect(cv, sx + 4, 130, sx + 94, 170, Wd[2]); _col(cv, sx + 4, sx + 94, 130, 170, W, rnd, .1)
    lump(cv, sx + 20, 168, 22, 10, W, rnd); lump(cv, sx + 78, 168, 22, 10, W, rnd)
    log(sx + 8, 148, sx + 8, 190, 14); log(sx + 90, 148, sx + 90, 190, 14)
    for cx in (sx + 28, sx + 60): lump(cv, cx, 165, 18, 9, r5(RAMP["petal"]), rnd, .05)   # saggy cushions
    for k in range(10): cv.put(sx + 32 + k, 150 + abs(k - 5) // 2, Wd[3])
    for lx in (sx + 10, sx + 88): rect(cv, lx, 186, lx + 6, 216, Wd[2]); rect(cv, lx, 186, lx + 2, 216, Wd[1])
    # chair (middle)
    cx0 = 118
    log(cx0, 112, cx0, 215, 8); log(cx0 + 40, 112, cx0 + 40, 215, 8)
    for y in (118, 134, 150): log(cx0, y, cx0 + 40, y - 2, 6) if y < 160 else None
    log(cx0 - 4, 170, cx0 + 44, 170, 12)
    log(cx0 + 2, 172, cx0 + 2, 214, 8) if False else None
    for k in range(5): cv.put(cx0 + 8 + k * 6, 100 + k % 2, Wd[0])
    rect(cv, cx0 - 2, 112, cx0 + 4, 116, Wd[3])
    # the dragon (right)
    dx0 = 195
    log(dx0, 214, dx0 + 20, 170, 20); log(dx0 + 20, 170, dx0 + 14, 120, 18); log(dx0 + 14, 120, dx0 + 30, 78, 16); log(dx0 + 30, 78, dx0 + 54, 62, 14)
    log(dx0 + 54, 62, dx0 + 80, 70, 12)
    log(dx0 + 80, 70, dx0 + 96, 80, 8)
    for k in range(5):   # spines
        for j in range(8 - k): cv.put(dx0 + 22 + k * 3 - j // 3, 112 - k * 18 - j, RAMP["gold"][1 + (j > 4)])
    disc(cv, dx0 + 64, 64, 4, CREAM); disc(cv, dx0 + 65, 64, 2, INK)   # eye
    for k in range(7): cv.put(dx0 + 90 + k, 78 + k // 3, RAMP["ember"][1]); cv.put(dx0 + 94 + k, 72 - k, RAMP["ember"][0] if k % 2 else RAMP["gold"][1])   # puff of smoke / fire
    for k in range(5): cv.put(dx0 + 56 + k * 4, 52 - k, Wd[1]); cv.put(dx0 + 56 + k * 4, 51 - k, Wd[1])   # horn
    log(dx0 - 4, 214, dx0 - 30, 200, 10)   # tail curl
    log(dx0 - 30, 200, dx0 - 40, 184, 7)
    log(dx0 + 10, 130, dx0 - 14, 150, 7)   # a stubby arm
    hline(cv, 8, 292, 217, RAMP["sand"][2]) if False else None
def lm_shellpile(rnd, cv):   # 210 x 170
    mound(cv, 105, 166, 98, 100, r5(RAMP["sand"]), rnd, .06)
    cols = ["snow", "petal", "gold", "sand", "dusk"]
    # sorted in rows by colour (strong feelings), spirals on top
    pts = []
    for row in range(10):
        y = 166 - row * 9
        half = int(math.sqrt(max(0, 1 - ((166 - y) / 96.0) ** 2)) * 90)
        for x in range(105 - half + 8, 105 + half - 6, 14):
            pts.append((x + (7 if row % 2 else 0), y, row))
    for x, y, row in sorted(pts, key=lambda p: p[1]):
        if abs(x - 105) > 92 - 0: continue
        c = cols[(x // 14 + row // 2) % 5]
        if row % 3 == 0 or (x // 14) % 2: spiral(cv, x, y - 2, 5, c)
        else: shell(cv, x, y, 6, c, rnd)
    spiral(cv, 105, 76, 8, "petal")   # the favourite
    # sorting stick sign: arrow pointing to spirals
    vline(cv, 188, 120, 166, RAMP["wood"][2]); vline(cv, 189, 120, 166, RAMP["wood"][3])
    rect(cv, 170, 106, 204, 124, RAMP["wood"][0]); hline(cv, 170, 204, 106, RAMP["wood"][3]); hline(cv, 170, 204, 124, RAMP["wood"][3])
    for k in range(8): cv.put(180 + k, 115 - (k if k < 4 else 7 - k), RAMP["ember"][2]) if False else None
    spiral(cv, 187, 115, 4, "petal")
def lm_stepping(rnd, cv):   # 280 x 130
    seaband(cv, 4, 276, 40, 124, rnd)
    for y in range(40, 124):
        for x in range(4, 276):
            e = min(x - 4, 275 - x)
            if e < 18 and (y - 40) < (18 - e) * 2: cv.p[x, y] = (0, 0, 0, 0)
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48", "#201f36")]
    for i, (x, y, rx, ry) in enumerate(((36, 86, 24, 12), (84, 66, 20, 10), (132, 92, 26, 12), (184, 70, 20, 10), (236, 88, 24, 12))):
        lump(cv, x, y, rx, ry, K, rnd, .1)
        for k in range(-rx + 3, rx - 2, 3): cv.put(x + k, y + ry + 1, CREAM) if (k + i) % 2 else None
        hline(cv, x - 8, x - 2, y - 4, K[0])
    for x in range(8, 272, 14): waves(cv, x, x + 9, 56 + (x // 14) % 4 * 14, rnd, 1)
    gull(cv, 132, 78, 1, flip=False)   # one gull watching
    mask_ell(cv, 140, 82, 137, 44)
def lm_lanternrocks(rnd, cv):   # 300 x 270
    S = r5(RAMP["stone"]); GO = r5(RAMP["gold"]); SE = r5(RAMP["sea"]); PI = r5(RAMP["pine"]); M = r5(RAMP["moss"]); SN = r5(RAMP["snow"]); EM = r5(RAMP["ember"]); A = r5(RAMP["sand"]); WD = r5(RAMP["wood"])
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48")]
    nzA = hd_noise(rnd, 6); nzB = hd_noise(rnd, 3); nzC = hd_noise(rnd, 14)
    lamps = []; allpts = {}
    def spire(cx, base, rx, ht, seed):
        r2 = random.Random(seed); top = base - ht
        bands = []; y = top
        while y < base: h = r2.randint(10, 17); bands.append((y, y + h, r2.randint(-4, 3), r2.randint(-3, 4), [r2.randint(11, 22) for _ in range(8)])); y += h
        pts = {}
        def bandof(y):
            for i, b in enumerate(bands):
                if b[0] <= y < b[1]: return i
            return len(bands) - 1
        for y in range(top - 3, base):
            u = max(0, (y - top)) / float(ht); hw = rx * (.34 + .66 * u ** .72)
            b = bandof(y); b0, b1, oL, oR, jw = bands[b]; fr = (y - b0) / float(b1 - b0)
            ptb = bands[b - 1] if b > 0 else bands[0]
            for x in range(int(cx - hw - 8), int(cx + hw + 9)):
                xl = cx - hw + oL + (nzB(y, 2) - .5) * 4; xr = cx + hw + oR + (nzB(y + 40, 5) - .5) * 4
                if y < top + 4: xl += 5 - (y - top) ; xr -= 5 - (y - top)
                if y < top + int(3 * nzA(x, 1)) or not (xl <= x <= xr): continue
                xm = cx - .16 * hw + 6 * (nzC(y, 9) - .5); w = (xr - xl)
                f = (x - xl) / max(1.0, xm - xl) if x < xm else 0
                vl = .45 + 1.25 * min(1.0, f) + (.5 if x - xl < 2 else 0) * -1
                vr = 2.55 + 1.0 * (x - xm) / max(1.0, xr - xm)
                wgt = max(0.0, min(1.0, (x - xm) / 7.0 + .5)); v = vl * (1 - wgt) + vr * wgt
                v += ((b * 53) % 7 / 7.0 - .5) * 1.0 + (nzB(x, y) - .5) * .9 + (nzC(x + seed, y) - .5) * .8
                if y < top + 7: v = .1 + (nzB(x, y) - .5) * .8 + (x - xl) / w * .8
                broken = nzA(x * .5 + b * 13, b * 7) > .3
                if fr < .12: v += 1.7 if broken else .3         # dark seam under the ledge above
                elif fr < .27 and x < xm + 3: v -= .75           # lit lip of this course
                elif fr > .86: v += .55                           # undercut shade
                if b > 0 and bands[b - 1][2] < oL and fr < .3 and x < xm: v += 1.0   # cast shadow from a ledge sticking out above
                for k in range(8):   # vertical joints between slabs
                    jx = int(xl) + sum(jw[:k + 1])
                    if x == jx and .16 < fr < .9 and (k + b) % 3 != 0: v += .9 if x < xm else .5
                    if x == jx - 1 and .2 < fr < .8 and x < xm and (k + b) % 3 != 0: v -= .4
                if (x * 5 + y * 9 + seed) % 23 == 0: v += rnd.choice((-1.3, 1.3))
                cv.put(x, y, S[hd_tone(v, x, y)]); pts[(x, y)] = v
        # chisel marks: little groups of diagonal strokes
        for _ in range(int(ht / 7)):
            x, y = rnd.randint(cx - int(rx * .7), cx + int(rx * .5)), rnd.randint(top + 12, base - 20)
            for j in range(rnd.randint(3, 5)):
                xx, yy = x + j * 3, y + (j % 2) * 2
                if all(((xx + k, yy - k) in pts) for k in range(3)):
                    i0 = hd_idx(cv.get(xx, yy), S); i0 = 2 if i0 is None else i0
                    for k in range(3): cv.put(xx + k, yy - k, S[max(0, i0 - 1)]); cv.put(xx + k + 1, yy - k + 1, S[min(4, i0 + 1)]) if (xx + k + 1, yy - k + 1) in pts and k == 1 else None
        for _ in range(int(ht / 25) + 1):   # cracks
            x = rnd.randint(cx - int(rx * .6), cx + int(rx * .5)); y = rnd.randint(top + 14, base - 50)
            hd_crack(cv, x, y, rnd.randint(12, 26), rnd, S, rnd.choice((-1, 1)), pts)
        return pts, top
    def rubble(cx, base, rx, ht, seed): return hd_rock(cv, cx, base, rx, ht, random.Random(seed), S, 2.2, ht * .8, 4, 0, 3.3, 1.15)
    def lantern(cx, ly):
        # iron post set into the rock, then a ring and chain
        for yy in range(ly + 22, ly + 34): cv.put(cx - 1, yy, K[1]); cv.put(cx, yy, K[0]); cv.put(cx + 1, yy, K[3])
        for xx in range(cx - 5, cx + 6): cv.put(xx, ly + 23, K[2]); cv.put(xx, ly + 24, K[3]) if xx % 2 else None
        for k in range(4): cv.put(cx + (k % 2) - 1, ly - 19 - k, K[0 if k % 2 else 2]); cv.put(cx + (k % 2), ly - 19 - k, K[1])
        for dx, dy in ((-2, 0), (-1, -1), (0, -1), (1, -1), (2, 0), (2, 1), (-2, 1), (-1, 2), (0, 2), (1, 2)): cv.put(cx + dx, ly - 24 + dy, K[0] if dy < 1 else K[2])
        # roof: stepped pagoda lid
        for k in range(9):
            hw = 11 - k; yy = ly - 5 - k
            for xx in range(cx - hw, cx + hw + 1): cv.put(xx, yy, K[0] if xx < cx - hw + 2 and k < 8 else K[1] if xx < cx + 2 else K[2] if xx < cx + hw - 1 else K[3])
        for xx in range(cx - 12, cx + 13): cv.put(xx, ly - 4, K[3]); cv.put(xx, ly - 5, K[1] if xx < cx else K[2])
        for xx in range(cx - 9, cx + 10): cv.put(xx, ly - 14, K[0] if xx < cx else K[1])
        for k in range(3): cv.put(cx - 1 + k, ly - 15, K[2]); cv.put(cx - 1, ly - 16, K[0])
        disc_ = [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]
        for dx, dy in disc_: cv.put(cx + dx, ly - 18 + dy, K[0] if dx < 1 else K[2])
        # cage: glowing glass with a dithered gradient, a flame core
        for yy in range(ly, ly + 21):
            for xx in range(cx - 8, cx + 9):
                d = math.sqrt(((xx - cx) * 1.15) ** 2 + (yy - ly - 11) ** 2)
                v = d / 3.6 + (nzB(xx, yy) - .5) * .4
                cv.put(xx, yy, [CREAM, GO[0], GO[1], GO[2], EM[2]][hd_tone(v, xx, yy)])
        for yy in range(ly + 6, ly + 14): cv.put(cx, yy, CREAM if yy > ly + 8 else GO[0]); cv.put(cx - 1, yy, GO[0]) if 8 < yy - ly < 13 else None
        cv.put(cx, ly + 5, GO[0]); cv.put(cx, ly + 4, GO[1]); cv.put(cx + 1, ly + 12, GO[1]) 
        for xx in (cx - 8, cx - 4, cx + 4, cx + 8):
            for yy in range(ly, ly + 21): cv.put(xx, yy, K[1] if xx < cx else K[2]); cv.put(xx - 1 if xx < cx else xx + 1, yy, K[0] if xx < cx and yy % 3 else cv.get(xx + 1, yy))
        for xx in range(cx - 8, cx + 9): cv.put(xx, ly, K[2]); cv.put(xx, ly + 1, K[1] if xx < cx else K[3]); cv.put(xx, ly + 19, K[2]); cv.put(xx, ly + 20, K[3])
        for k in range(3): cv.put(cx - 6 + k, ly + 3 + k, CREAM) if k < 2 else None   # glint on the glass
        for k in range(3):   # humming notes
            nx, ny = cx + 18 + k * 8, ly - 6 - k * 9
            for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (1, 1), (0, -1), (-1, 1), (-1, -1)): pass
            for dx in range(-2, 3):
                for dy in range(-1, 2):
                    if dx * dx + dy * dy * 2 <= 4: cv.put(nx + dx, ny + 6 + dy, CREAM if (dx + dy) < 1 else A[1])
            for yy in range(ny - 3, ny + 6): cv.put(nx + 2, yy, CREAM)
            cv.put(nx + 3, ny - 3, CREAM); cv.put(nx + 4, ny - 2, CREAM); cv.put(nx + 3, ny - 2, A[1])
    SP = [(150, 262, 52, 190, 11), (58, 262, 36, 150, 22), (240, 262, 36, 130, 33)]
    spts = []
    for (cx, base, rx, ht, sd) in SP:
        pts, top = spire(cx, base, rx, ht, sd); spts.append((cx, base, rx, ht, pts, top))
        allpts.update(pts)
        rb = rubble(cx - rx // 3, base, rx // 2 + 8, 16, sd + 1); rb2 = rubble(cx + rx // 2 + 3, base - 1, rx // 2 + 4, 14, sd + 2)
        for p in list(rb) + list(rb2): allpts[p] = rb.get(p, 2)
    # lantern glow on the rock, as warm dither
    for (cx, base, rx, ht, pts, top) in spts:
        lx, ly = cx, top - 26
        for (x, y) in pts:
            d = math.hypot((x - lx) * .85, y - (ly + 10))
            if d < 36 and _B4[y & 3][x & 3] / 16.0 < (1 - d / 36.0) * 1.05:
                c = cv.get(x, y); i = hd_idx(c, S)
                if i is not None: cv.put(x, y, mix(c, GO[0], .45 if i < 3 else .28))
    for (cx, base, rx, ht, pts, top) in spts: lantern(cx, top - 26)
    # tide stain, barnacles and weed low on every spire; limpets, mussels, shells in the rubble
    P = list(allpts)
    def tide(x): return 232 + 5 * math.sin(x / 8.0) + 6 * (nzA(x, 4) - .5)
    for (x, y) in P:
        e = y - tide(x)
        if e > 0 and cv.get(x, y) in S and ((x + y) % 2 == 0 or e > 8):
            i = hd_idx(cv.get(x, y), S); cv.put(x, y, S[min(4, i + 1)] if nzC(x * 2, y) < .55 else M[hd_tone(2.6 + (nzB(x, y) - .5) * 2, x, y)])
    fr = [(x, y) for (x, y) in P if -3 < y - tide(x) < 7]
    hd_barnacles(cv, fr, S, 40, rnd, lambda x, y: True, 5)
    hi = [(x, y) for (x, y) in P if 150 < y < 228 and cv.get(x, y) in S[:3]]
    hd_barnacles(cv, hi, S, 12, rnd, lambda x, y: True, 3)
    for x in range(20, 282, 4):
        y = int(tide(x)) + 8
        if (x, y) in allpts and nzC(x * 3, 2) > .4: hd_weed(cv, x, y, rnd.randint(6, 20), rnd, rnd.choice((-1, 1)), PI)
    for _ in range(18):   # limpets
        x, y = rnd.randint(30, 270), rnd.randint(210, 256)
        if (x, y) in allpts: cv.put(x - 1, y, SN[1]); cv.put(x, y, SN[0]); cv.put(x + 1, y, SN[2]); cv.put(x, y - 1, SN[1]); cv.put(x + 2, y, S[4]); cv.put(x, y + 1, S[4])
    for _ in range(14):   # lichen
        x, y = rnd.randint(30, 270), rnd.randint(100, 210)
        if (x, y) in allpts and cv.get(x, y) in S[:3]: cv.put(x, y, GO[1] if rnd.random() < .6 else GO[0]); cv.put(x + 1, y, GO[2]) if (x + 1, y) in allpts and rnd.random() < .5 else None
    for x in range(14, 290, 9):   # pebbles and foam at the foot
        pe = [mix(S[1], CREAM, .3), S[1], S[2], S[3], S[4]]; lump(cv, x + rnd.randint(-2, 2), 263 + rnd.randint(-1, 1), rnd.randint(3, 5), rnd.randint(2, 3), pe, rnd, .1)
    for x in range(8, 292, 6): cv.put(x, 267, SE[0]); cv.put(x + 1, 267, CREAM); cv.put(x + 3, 268, SE[1])
    hd_bounce(cv, set(allpts), S, lambda x, y: (x % 60 > 28) and y > 150 or y > 256, 1, 4)
def lm_gullparliament(rnd, cv):   # 300 x 250
    S = r5(RAMP["stone"])
    # stepped rock like benches/tiers
    tiers = [(150, 248, 140, 40), (150, 208, 112, 40), (150, 168, 86, 40), (150, 128, 58, 36)]
    for (cx, base, rx, ht) in tiers:
        top = base - ht
        for y in range(top, base):
            for x in range(cx - rx, cx + rx + 1):
                f = (x - (cx - rx)) / (2.0 * rx); r = (y - top)
                if y < top + 6: t = 0 if f < .5 else 1
                else: t = 1 if f < .15 else 2 if f < .55 else 3
                if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
                cv.put(x, y, S[t])
        for k in range(rx * 2 // 24 + 1): vline(cv, cx - rx + 10 + k * 24, top + 8, base - 2, S[4])
    # gulls in rows
    rows = [(246, 140, 7), (206, 112, 6), (166, 84, 5)]
    for (ry, rx, n) in rows:
        for i in range(n):
            x = 150 - rx + 18 + i * (2 * rx - 36) // max(1, n - 1)
            gull(cv, x, ry - 40 + 8, 1, flip=(x > 150), open_beak=(i + ry) % 4 == 0)
    # podium and the chairgull on top
    rect(cv, 128, 100, 172, 124, RAMP["wood"][1]); _col(cv, 128, 172, 100, 124, r5(RAMP["wood"]), rnd, .05)
    rect(cv, 128, 98, 172, 101, RAMP["wood"][0]); hline(cv, 128, 172, 124, RAMP["wood"][3])
    gull(cv, 150, 98, 2, flip=False, open_beak=True)
    # tiny wig, gavel
    for x in range(138, 163): cv.put(x, 66 + abs(x - 150) // 3 * 0 + (x % 3 == 0), CREAM) if False else None
    rect(cv, 168, 90, 180, 96, RAMP["wood"][2]); vline(cv, 174, 96, 100, RAMP["wood"][3])
    # banners / flags
    for fx, c in ((34, "ember"), (266, "petal")):
        vline(cv, fx, 128, 210, RAMP["wood"][2]); vline(cv, fx + 1, 128, 210, RAMP["wood"][3])
        for k in range(18): hline(cv, fx + 2, fx + 24 - k // 3, 130 + k, RAMP[c][1 if k < 9 else 2])
    for k in range(6):   # speech squiggles
        x = 120 + k * 12; cv.put(x, 36 - (k % 2) * 4, CREAM); cv.put(x + 1, 36 - (k % 2) * 4, CREAM)
    for x in range(20, 282, 7): cv.put(x, 249, RAMP["sea"][0]); cv.put(x + 1, 249, CREAM)

LM = {
 "307-tideline": (330, 124, lm_tideline),
 "307-barnacles": (270, 190, lm_barnacles),
 "307-shellhollow": (260, 160, lm_shellhollow),
 "307-sandcastle": (230, 200, lm_sandcastle),
 "308-pebblebar": (300, 170, lm_pebblebar),
 "308-kelpline": (320, 124, lm_kelp),
 "308-rockpool": (240, 164, lm_rockpool),
 "308-tidesteps": (280, 200, lm_tidesteps),
 "314-driftwood": (300, 220, lm_driftwood),
 "314-shellpile": (210, 170, lm_shellpile),
 "314-causeway": (330, 160, lm_causeway),
 "314-steppingrocks": (280, 130, lm_stepping),
 "314-lanternrocks": (300, 270, lm_lanternrocks),
 "314-gullparliament": (300, 250, lm_gullparliament),
}
