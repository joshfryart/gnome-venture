"""Route 315 (tundra, Den of the Great White Owl) landmarks: gate, lamp lane, pine slope, snow fort, frozen stream, icicle bridge,
giant feather, feather cairns, owl den, doormat. See gen2.LANDMARKS for the format."""
import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
from PIL import ImageDraw

SN, IC, PN, ST, WD, GD, EM, PT, DK, MS = (r5(RAMP[k]) for k in ("snow", "ice", "pine", "stone", "wood", "gold", "ember", "petal", "dusk", "moss"))
SE = r5(RAMP["sea"])
COAL = H("#35295f")
FONT = {"O": "111101101101111", "W": "101101101111101", "L": "100100100100111", "Y": "101101010010010", "E": "111100110100111",
        "S": "111100111001111", "?": "111001011000010", ".": "000000000000010", "H": "101101111101101"}

def _text(cv, x, y, s, c, sc=2):
    for i, ch in enumerate(s):
        g = FONT[ch]
        for k, b in enumerate(g):
            if b == "1":
                for dx in range(sc):
                    for dy in range(sc): cv.put(x + i * 4 * sc + (k % 3) * sc + dx, y + (k // 3) * sc + dy, c)

def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)

def poly(cv, pts, c):
    ImageDraw.Draw(cv.im).polygon(pts, fill=c)

def line(cv, pts, c, w=1):
    ImageDraw.Draw(cv.im).line(pts, fill=c, width=w)

def post(cv, x, y0, y1, w, R):
    for xx in range(x, x + w):
        u = (xx - x) / max(1, w - 1); t = 0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3
        for y in range(y0, y1): cv.put(xx, y, R[t])

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

def _rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)

def _drift(cv, cx, by, rx, ry, rnd):
    lump(cv, cx, by - ry * .4, rx, ry, SN, rnd, .06)

def _pine(cv, cx, by, h, rnd, snowy=True):
    tw = max(4, h // 9)
    _col(cv, cx - tw // 2, cx + tw // 2 + 1, by - h // 7, by, WD, rnd, 0)
    n = 3
    for i in range(n):
        yt = int(by - h * .92 + i * h * .25); yb = int(yt + h * .42); hwb = h * (.2 + .085 * i)
        for y in range(yt, yb):
            fr = (y - yt) / max(1, yb - yt); hw = max(1, int(fr * hwb) + 1)
            for x in range(cx - hw, cx + hw + 1):
                u = (x - (cx - hw)) / max(1, 2 * hw); t = 1 if u < .22 else 2 if u < .55 else 3
                if fr > .9 or (u > .8 and fr > .6): t = 4 if fr > .9 else 3
                if (x * 5 + y * 3) % 17 == 0: t = max(1, t - 1)
                if snowy and fr < .3 + .1 * (((x * 7 + i * 3) % 5) / 4) + (.18 if abs(x - cx) > hw * .7 else 0):
                    t = 0; c = SN[0] if u < .4 else SN[1] if u < .75 else SN[2]
                    cv.put(x, y, c)
                else: cv.put(x, y, PN[t])
        if snowy:   # snow lip hanging off the tier's shoulders
            for s in (-1, 1):
                xx = cx + s * int(hwb * .86)
                lump(cv, xx, yb - 2, max(3, int(h * .07)), max(2, int(h * .04)), SN, rnd, 0)

def _zzz(cv, x, y, sc=1):
    for k, (dx, dy) in enumerate(((0, 0), (1, 0), (2, 0), (1, 1), (0, 2), (1, 2), (2, 2))):
        for a in range(sc):
            for b in range(sc): cv.put(x + dx * sc + a, y + dy * sc + b, CREAM)

def _feather(cv, bx, by, tx, ty, wid, rnd, bend=10):
    """Curved feather: quill from (bx,by) to (tx,ty), vane half-width wid; cream with ice shadow side."""
    N = int(math.hypot(tx - bx, ty - by) * 2.2)
    for k in range(N + 1):
        t = k / N
        sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
        if t > .22:
            w = wid * math.sin(math.pi * min(1, (t - .1) / .9) ** .85) * (1 - .12 * t)
            if t > .96: w = 0
            for o in range(-int(w), int(w) + 1):
                u = (o + w) / max(1, 2 * w); c = SN[0] if u < .35 else SN[1] if u < .62 else SN[2] if u < .88 else SN[3]
                if (int(sy) + (o if o > 0 else -o) * 1) % 7 == 0 and abs(o) > 2: c = IC[1] if c == SN[0] else SN[2] if c == SN[1] else SN[3]
                cv.put(int(sx) + o, int(sy), c)
    for k in range(N + 1):   # quill
        t = k / N; sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
        c = ST[1] if t > .22 else WD[0]
        cv.put(int(sx), int(sy), c); cv.put(int(sx) + 1, int(sy), ST[2] if t > .22 else WD[1])
    N2 = int(wid * .5)   # little notch at the vane edge
    t = .6; sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
    for d in range(1, 7):
        for o in range(int(wid * .5) - 2, int(wid) + 2): cv.put(int(sx) + o, int(sy) + d * 2 - 6 + 0, (0, 0, 0, 0)) if False else None

def _stonepile(cv, cx, by, widths, rnd, hts=None):
    y = by
    for i, w in enumerate(widths):
        h = hts[i] if hts else max(8, w // 3)
        lump(cv, cx + rnd.randint(-3, 3), y - h * .5, w / 2, h / 2 + 1, ST, rnd, .12); y -= h - 2
    return y

# -------------------------------------------------------------------------------------------- hand-drawn toolkit
SD = r5(RAMP["sand"])
LDIR = (-.5, -.62, .6)

def _sh(cv, x, y, n):
    """shift the tone of an existing ramp pixel by n steps (n<0 lighter, n>0 darker); leaves ink and empty pixels alone"""
    c = cv.get(x, y)
    if c[3] == 0: return
    tm = gen2._tone_map()
    if c in tm:
        R, i = tm[c]; cv.put(x, y, R[max(0, min(4, i + n))])

def _inside(cv, x, y):
    c = cv.get(x, y); return c[3] > 0 and c != INK

def _pl(x0, y0, x1, y1):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    return [(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)) for i in range(n + 1)]

def _dist(mask):
    INF = 1e9; d = {}
    for (x, y) in mask:
        d[(x, y)] = 1 if any((x + a, y + b) not in mask for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))) else INF
    for (x, y) in sorted(mask, key=lambda p: (p[1], p[0])):
        for a, b, c in ((-1, 0, 1), (0, -1, 1), (-1, -1, 1.4), (1, -1, 1.4)):
            q = (x + a, y + b)
            if q in d and d[q] + c < d[(x, y)]: d[(x, y)] = d[q] + c
    for (x, y) in sorted(mask, key=lambda p: (-p[1], -p[0])):
        for a, b, c in ((1, 0, 1), (0, 1, 1), (1, 1, 1.4), (-1, 1, 1.4)):
            q = (x + a, y + b)
            if q in d and d[q] + c < d[(x, y)]: d[(x, y)] = d[q] + c
    return d

def _form(cv, z, R, lo=-.1, hi=.9, bounce=None):
    """Light a height field from the top left with checker-dithered tone transitions; bounce light (ramp `bounce`) on the lower right."""
    out = {}
    for (x, y), h in z.items():
        gx = (z.get((x + 1, y), h - 2.0) - z.get((x - 1, y), h - 2.0)) / 2; gy = (z.get((x, y + 1), h - 2.0) - z.get((x, y - 1), h - 2.0)) / 2
        nz = 1 / math.sqrt(1 + gx * gx + gy * gy); d = -gx * nz * LDIR[0] - gy * nz * LDIR[1] + nz * LDIR[2]
        v = max(0.0, min(4.0, (hi - d) / (hi - lo) * 4)); i = int(v); f = v - i
        ev = (x & 1) == 0 and (y & 1) == 0
        if i >= 4: t = 4
        elif f < .3: t = i
        elif f < .42: t = i + (1 if ev else 0)
        elif f < .58: t = i + ((x + y) & 1)
        elif f < .7: t = i + (0 if ev else 1)
        else: t = i + 1
        c = R[t]
        if bounce and t >= 3 and gx > .3 and gy > .1 and ((x + 2, y + 2) not in z or (x + 3, y + 3) not in z or (x + 3, y + 2) not in z): c = bounce[2] if (x + y) & 1 or t == 3 else R[3]
        cv.put(x, y, c); out[(x, y)] = t
    return out

def _blob(cv, cx, cy, rx, ry, R, rnd, D=None, wob=.03, ymax=None, broad=.35, lo=-.1, hi=.9, bounce=None, nolo=None):
    ph = [rnd.random() * 6.28 for _ in range(4)]; mask = set()
    for y in range(int(cy - ry * 1.12) - 1, int(cy + ry * 1.12) + 2):
        if ymax is not None and y > ymax: break
        for x in range(int(cx - rx * 1.12) - 1, int(cx + rx * 1.12) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry; a = math.atan2(ny, nx)
            lim = 1 + wob * (math.sin(5 * a + ph[0]) * .8 + math.sin(9 * a + ph[1]) * .6 + math.sin(15 * a + ph[2]) * .5)
            if nx * nx + ny * ny <= lim * lim: mask.add((x, y))
    if not mask: return mask
    d = _dist(mask); D = D or min(rx, ry) * .5; z = {}
    for p in mask:
        nx = (p[0] + .5 - cx) / rx; ny = (p[1] + .5 - cy) / ry
        k = min(d[p], D) / D
        z[p] = D * math.sqrt(max(0, 1 - (1 - k) ** 2)) + broad * min(rx, ry) * math.sqrt(max(0, 1 - nx * nx - ny * ny))
    _form(cv, z, R, lo, hi, bounce); return mask

def _crack(cv, x, y, n, rnd, dx=1, dy=1, fork=.12, deep=2):
    """jagged crust crack: dark line with a lit lip on its lower right"""
    for k in range(n):
        if _inside(cv, x, y):
            _sh(cv, x, y, deep)
        if _inside(cv, x + 1, y + 1) and rnd.random() < .6: _sh(cv, x + 1, y + 1, -1)
        r = rnd.random()
        if r < .45: x += dx
        elif r < .8: y += dy
        else: x += dx; y += dy
        if rnd.random() < fork and n - k > 5: _crack(cv, x, y, (n - k) // 2, rnd, rnd.choice((-1, 1)) * dx if rnd.random() < .5 else dx, dy, fork * .3, deep)

def _ridge(cv, pts, depth=1):
    """wind-sculpted ridge: lit crest, shaded lee"""
    for (x, y) in pts:
        _sh(cv, x, y, -1) if _inside(cv, x, y) else None
        if _inside(cv, x, y + 1): _sh(cv, x, y + 1, depth)
        if _inside(cv, x + 1, y + 2) and (x + y) & 1: _sh(cv, x + 1, y + 2, 1)

def _arc(cx, cy, rx, ry, a0, a1, step=1.0):
    pts = []; a = a0
    while a <= a1:
        p = (round(cx + math.cos(math.radians(a)) * rx), round(cy + math.sin(math.radians(a)) * ry))
        if not pts or pts[-1] != p: pts.append(p)
        a += step
    return pts

def _glint(cv, x, y, big=False):
    if not _inside(cv, x, y): return
    cv.put(x, y, CREAM)
    if big:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, SN[0] if cv.get(x + dx, y + dy)[3] else CREAM)

def _tuft(cv, x, y, rnd, n=5, h=8, frost=True):
    """a tuft of frozen grass poking out of the snow"""
    for k in range(n):
        lean = rnd.choice((-2, -1, -1, 0, 1, 1, 2)) * (1 if k < n else 1); hh = h - abs(k - n // 2) * 1 + rnd.randint(-1, 1)
        bx = x + (k - n // 2) * 2
        for j in range(hh):
            xx = bx + int(lean * (j / hh) ** 1.5 * 2); c = (MS[2], SD[3], SD[2], MS[3])[(k + (j > hh * .6)) % 4] if j < hh * .55 else (SD[2], SD[1], MS[2])[k % 3]
            cv.put(xx, y - j, c)
        if frost: cv.put(bx + int(lean * 2), y - hh, SN[0]); cv.put(bx + int(lean * 1.4), y - hh + 1, SN[1])

def _print(cv, x, y, rnd=None, flip=1):
    """a gnome footprint in snow"""
    for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (0, 2), (1, 2)):
        if _inside(cv, x + dx * flip, y + dy): _sh(cv, x + dx * flip, y + dy, 2)
    for dx, dy in ((3, 1), (3, 2), (2, 3), (0, 3), (1, 3)):
        if _inside(cv, x + dx * flip, y + dy): _sh(cv, x + dx * flip, y + dy, -1)

def _leaf(cv, x0, y0, x1, y1, w, R, rnd=None, light=1):
    """a pointed feather/leaf shape from (x0,y0) to (x1,y1), half-width w, lit on the up-left side"""
    N = max(abs(x1 - x0), abs(y1 - y0)) * 2 + 1; L = math.hypot(x1 - x0, y1 - y0) or 1; px, py = -(y1 - y0) / L, (x1 - x0) / L
    for k in range(N + 1):
        t = k / N; ww = w * math.sin(math.pi * min(1, t * 1.05) ** .8)
        bx = x0 + (x1 - x0) * t; by = y0 + (y1 - y0) * t
        for o in range(-int(ww + .5), int(ww + .5) + 1):
            u = (o + ww) / max(1, 2 * ww)
            side = u if (px * LDIR[0] + py * LDIR[1]) < 0 else 1 - u
            cv.put(round(bx + px * o), round(by + py * o), R[0 if side > .75 else 1 if side > .45 else 2 if side > .15 else 3])

def _pine2(cv, cx, by, h, rnd, snowy=True):
    """hand-drawn snowy pine: ragged tiers of needle sprigs lit from the left, snow cushions on the boughs"""
    tw = max(4, h // 13)
    for x in range(cx - tw // 2, cx - tw // 2 + tw):
        u = (x - (cx - tw // 2)) / max(1, tw - 1)
        for y in range(by - h // 6, by): cv.put(x, y, WD[1 if u < .3 else 2 if u < .7 else 3])
        for y in range(by - h // 6 + 2, by, 4): cv.put(x, y, WD[3] if u > .3 else WD[2])
    n = 4 if h >= 100 else 3
    for i in range(n):
        yt = int(by - h * .95 + i * h * (.78 / n)); yb = int(yt + h * (.9 / n) + 5); hwb = h * (.15 + .085 * i * (3 / n) + .02)
        hwb = min(hwb, h * .36)
        for y in range(yt, yb):
            fr = (y - yt) / max(1, yb - yt - 1); hw0 = 1 + fr ** .9 * hwb
            hl = hw0 + (2 if (y * 7 + i * 5) % 5 == 0 else 0) - (1 if (y * 3) % 7 == 0 else 0); hr = hw0 + (2 if (y * 5 + i * 3) % 6 == 0 else 0) - (1 if (y * 11) % 5 == 0 else 0)
            for x in range(int(cx - hl), int(cx + hr) + 1):
                u = (x - (cx - hl)) / max(1, hl + hr)
                t = 1 if u < .16 else 2 if u < .42 else 3 if u < .74 else 4
                if (x + y * 2) % 6 == 0 and u < .62: t -= 1
                elif (x * 2 - y) % 7 == 0 and u > .3: t += 1
                if fr > .88: t += 1
                if fr < .1: t -= 1
                cv.put(x, y, PN[max(0, min(4, t))])
        for k in range(-int(hwb) + 1, int(hwb) + 1, 3):   # sprig clumps drooping off the hem
            xx = cx + k + (i * 2) % 3; ln = 3 + (xx * 5 + i) % 4
            for j in range(ln):
                for o in range(2 if j < ln - 1 else 1):
                    cv.put(xx + o, yb + j - 1, PN[3 if o == 0 and j < 2 else 4 if j > 1 else 2])
        if snowy:   # snow cushions on the bough tops, shaded
            for x in range(int(cx - hwb), int(cx + hwb) + 1):
                dx = abs(x - cx); ye = yt + dx * (yb - yt) / max(hwb, 1) * .96
                depth = 2 + int(((yb - yt) * .2) * (1 - dx / (hwb + 1)) ** .5) + ((x * 3 + i) % 3 == 0)
                for y in range(int(ye) - 1 if dx > 2 else yt, int(ye) + depth):
                    if cv.get(x, y)[3] == 0 or y >= yb: continue
                    u = (x - (cx - hwb)) / max(1, 2 * hwb); lyr = (y - ye) / max(1, depth)
                    t = (0 if u < .35 else 1 if u < .62 else 2 if u < .85 else 3) + (1 if lyr > .65 else 0)
                    if abs(lyr - .65) < .12 and (x + y) & 1: t += 1 if lyr > .65 else 0
                    cv.put(x, y, SN[min(4, t)])
    cv.put(cx, int(by - h * .95), SN[0]); cv.put(cx, int(by - h * .95) + 1, SN[1])

# -------------------------------------------------------------------------------------------- section 0
def _stoneblk(cv, x0, y0, x1, y1, rnd):
    R = ST; b = 1 + rnd.choice((0, 0, 1)); w = x1 - x0
    for y in range(y0, y1):
        for x in range(x0, x1):
            u = (x - x0) / max(1, w - 1); v = (y - y0) / max(1, y1 - y0 - 1)
            t = b + (1 if u + v > 1.2 else 0) + (1 if u + v > 1.7 else 0) - (1 if u + v < .35 else 0)
            if abs(u + v - 1.2) < .1 and (x + y) & 1: t += 1
            if rnd.random() < .08: t += rnd.choice((-1, 1))
            cv.put(x, y, R[max(0, min(4, t))])
    for x in range(x0, x1): cv.put(x, y0, R[0]); cv.put(x, y1 - 1, R[4])
    for y in range(y0, y1): cv.put(x0, y, R[0]); cv.put(x1 - 1, y, R[3])
    for dx, dy in ((0, 0), (1, 0), (0, 1)): cv.put(x1 - 1 - dx, y0 + dy, SN[1] if rnd.random() < .5 else R[4])   # chipped corner
    if rnd.random() < .5: cv.put(x0 + rnd.randint(2, w - 3), y0 + rnd.randint(2, y1 - y0 - 3), MS[1]); cv.put(x0 + rnd.randint(2, w - 3), y1 - 3, MS[2])
    if rnd.random() < .35:
        fx = x0 + rnd.randint(3, w - 4)
        for j in range(y1 - y0 - 4): cv.put(fx + (j // 3), y0 + 2 + j, R[4])

def _pillar(cv, x0, rnd):
    W = 34; y = 66
    while y < 186:
        hh = min(rnd.choice((13, 15, 17, 14)), 186 - y); x = x0
        off = rnd.choice((0, 8, 14)) if (y // 14) % 2 else 0
        if off: _stoneblk(cv, x, y, x + off, y + hh, rnd); x += off
        while x < x0 + W:
            w = rnd.choice((12, 16, 20, 14)); x1 = min(x + w, x0 + W)
            if x0 + W - x1 < 7: x1 = x0 + W
            _stoneblk(cv, x, y, x1, y + hh, rnd); x = x1
        y += hh
    for y in range(66, 186):   # cylinder-ish shading over the whole pillar
        for x in range(x0, x0 + W):
            u = (x - x0) / (W - 1)
            if u < .18 and (x + y) & 1: _sh(cv, x, y, -1)
            elif u > .62 and ((x + y) & 1 or u > .8): _sh(cv, x, y, 1)
            if u > .9: _sh(cv, x, y, 1)
    for x in range(x0 - 2, x0 + W + 2):
        for y in range(184, 187): _sh(cv, x, y, 1)

def lm_gate(rnd, cv):   # 220 x 190
    for x0 in (36, 150): _pillar(cv, x0, rnd)
    # crossbeam, sign cords and the sign: planks with grain and nails
    for y in range(80, 88):
        for x in range(70, 150):
            v = (y - 80) / 7; t = 0 if v < .15 else 1 if v < .5 else 2 if v < .85 else 3
            if (x * 7 + y * 3) % 13 == 0: t = min(3, t + 1)
            cv.put(x, y, WD[t])
    for x in range(70, 150, 18): cv.put(x, 83, WD[3]); cv.put(x + 1, 84, WD[3])
    for xx in (84, 134):
        for y in range(88, 96): cv.put(xx, y, WD[1] if (y & 1) else WD[3]); cv.put(xx + 1, y, WD[2] if (y & 1) else WD[0])
    for y in range(95, 140):
        for x in range(74, 146):
            v = (y - 95) / 44.0; u = (x - 74) / 71.0
            pl = (y - 95) // 15; pv = ((y - 95) % 15) / 14.0
            t = 0 if pv < .12 else 1 if pv < .5 else 2 if pv < .88 else 3
            t = min(3, t + (1 if u > .8 else 0)) if t < 3 else 3
            if pl % 2: t = min(3, t + 1) if t < 3 and (x + y) % 5 == 0 else t
            if x < 76 or x > 143: t = 3 if x > 143 else 1
            if (x * 5 + (y // 2) * 3 + pl * 7) % 19 == 0 and 0 < t < 3: t += 1
            cv.put(x, y, WD[t])
    for (nx, ny) in ((78, 99), (141, 99), (78, 134), (141, 134), (78, 113), (141, 113)): cv.put(nx, ny, ST[1]); cv.put(nx + 1, ny + 1, WD[3])
    _text(cv, 83, 98, "OWL?", CREAM, 2); _text(cv, 83, 118, "YES.", GD[0], 2)
    for x in range(83, 83 + 4 * 8): 
        if cv.get(x, 105) == CREAM: pass
    for (dx, dy) in ((0, 0), (1, 0), (0, 1), (-1, 0), (0, -1)): cv.put(133 + dx, 124 + dy, SN[0])
    _blob(cv, 110, 82, 42, 5, SN, rnd, D=3, wob=.12, broad=.5, bounce=IC)   # snow on the beam
    # snow hats on the posts, overhanging, with drips and a snowflake finial
    for x0 in (36, 150):
        _blob(cv, x0 + 17, 62, 26, 14, SN, rnd, D=9, wob=.06, broad=.8, bounce=IC, ymax=75)
        _blob(cv, x0 + 6, 66, 9, 5, SN, rnd, D=3, wob=.1, broad=.4); _blob(cv, x0 + 30, 67, 8, 5, SN, rnd, D=3, wob=.1, broad=.4, bounce=IC)
        for x in range(x0 - 2, x0 + 38, 7): icicle(cv, x, 71, 3 + (x * 5) % 6, 2, IC) if _inside(cv, x, 71) else None
        for dx, dy in ((0, -3), (0, 3), (-3, 0), (3, 0), (0, 0), (2, 2), (-2, -2), (2, -2), (-2, 2)): cv.put(x0 + 17 + dx, 45 + dy, CREAM if dx * dy == 0 else SN[1])
        cv.put(x0 + 17, 45, IC[1])
    # drifts, tufts, prints
    for (cx, cy, rx, ry) in ((55, 182, 52, 14), (167, 182, 52, 14), (110, 187, 38, 8)):
        _blob(cv, cx, cy, rx, ry, SN, rnd, D=7, wob=.07, broad=.7, bounce=IC, ymax=189)
    for (x, y, n) in ((16, 186, 4), (204, 186, 4), (88, 188, 3), (134, 188, 3)): _tuft(cv, x, y, rnd, n, 7)
    for k in range(6): _print(cv, 96 + k * 6, 183 - (k % 2) * 2, rnd, 1 if k % 2 else -1)
    for (x, y) in ((50, 90), (176, 110), (62, 150), (186, 130)): _glint(cv, x, y)

def lm_lamps(rnd, cv):   # 240 x 200
    for i, (cx, top) in enumerate(((45, 58), (95, 44), (145, 52), (195, 40))):
        by = 192 - (i % 2) * 3
        _blob(cv, cx, by - 2, 26, 10, SN, rnd, D=6, wob=.07, broad=.6, bounce=IC, ymax=by + 6)
        for y in range(top + 34, by - 14):   # iron post, round: highlight, body, shade, with collars
            for x in range(cx - 3, cx + 4):
                u = x - cx + 3; cv.put(x, y, (ST[0], ST[1], ST[2], ST[3], ST[3], ST[4], ST[4])[u])
            if y % 22 == 0 and y > top + 40:
                for x in range(cx - 4, cx + 5): cv.put(x, y, ST[1] if x < cx else ST[3]); cv.put(x, y + 1, ST[3] if x < cx + 2 else ST[4])
        for x in range(cx - 8, cx + 9):   # stone foot: two courses
            for y in range(by - 16, by - 3):
                u = (x - cx + 8) / 16.0; v = (y - (by - 16)) / 12.0
                t = 1 + (1 if u > .55 else 0) + (1 if u > .85 else 0) + (1 if v > .85 else 0) - (1 if u < .15 else 0)
                if v < .1: t = 0
                if y == by - 10 or x == cx + (-1 if i % 2 else 2): t = 4
                cv.put(x, y, ST[max(0, min(4, t))])
        cv.put(cx + 3, by - 15, SN[1]); cv.put(cx + 4, by - 15, SN[1]); cv.put(cx - 6, by - 12, MS[2])
        for y in range(top + 11, top + 37):   # lantern: wood frame, glass with a glowing core
            for x in range(cx - 11, cx + 12):
                edge = x < cx - 8 or x > cx + 8 or y > top + 33 or y < top + 14
                if edge: cv.put(x, y, WD[3] if x > cx - 10 and y != top + 11 else WD[2]); continue
                d = ((x - cx) / 8.5) ** 2 + ((y - top - 24) / 10.5) ** 2
                t = 0 if d < .18 else 1 if d < .5 else 2 if d < .85 else 3
                if abs(d - .5) < .08 and (x + y) & 1: t = 1 if t == 2 else 2
                if x > cx + 3: t = min(3, t + 1) if t < 3 else 3
                cv.put(x, y, GD[t])
        for y in range(top + 14, top + 34): cv.put(cx, y, WD[3]); cv.put(cx - 1, y, WD[2]) if y % 2 else None
        for dy in (0, 1, 2, 3): cv.put(cx - 2 + dy // 2, top + 20 + dy, EM[0 if dy < 2 else 1]); cv.put(cx + 2 - dy // 2, top + 21 + dy, GD[0])
        cv.put(cx - 7, top + 26, CREAM); cv.put(cx - 7, top + 27, GD[0])   # glass shine
        for x in range(cx - 4, cx + 5): cv.put(x, top + 36, WD[3]); cv.put(x, top + 37, WD[3]) if abs(x - cx) < 3 else None   # base cap
        cv.put(cx, top + 38, WD[3])
        for y in range(top, top + 12):   # roof hat with snow
            hw = (y - top) * 14 // 12 + 2
            for x in range(cx - hw, cx + hw + 1):
                u = (x - (cx - hw)) / max(1, 2 * hw); cv.put(x, y, WD[0 if u < .15 else 1 if u < .45 else 2 if u < .8 else 3])
        _blob(cv, cx, top + 4, 15, 5, SN, rnd, D=4, wob=.08, broad=.7, bounce=IC, ymax=top + 8)
        _blob(cv, cx - 11, top + 11, 5, 3, SN, rnd, D=2, wob=.1, broad=.4); _blob(cv, cx + 11, top + 11, 5, 3, SN, rnd, D=2, wob=.1, broad=.4)
        for dx in (-10, -4, 5, 11): icicle(cv, cx + dx, top + 13, 3 + (dx * 3 + i) % 4, 2, IC)
        cv.put(cx, top - 3, GD[0]); cv.put(cx, top - 2, GD[1]); cv.put(cx, top - 1, GD[2]) if True else None   # finial
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(cx + dx - 6, top + 2 + dy, CREAM)   # one snowflake
        cv.put(cx - 6, top + 2, IC[1])
        cv.put(cx + 13, top + 20, GD[0]); cv.put(cx + 14, top + 19, GD[0]); cv.put(cx - 14, top + 24, GD[1])   # light motes
        _tuft(cv, cx + 15, by + 2, rnd, 3, 6); _print(cv, cx - 12, by + 1, rnd, 1)

# -------------------------------------------------------------------------------------------- section 1
def lm_slope(rnd, cv):   # 290 x 210
    _blob(cv, 145, 206, 143, 54, SN, rnd, D=26, wob=.04, broad=.6, bounce=IC, ymax=208)
    for (a0, a1, rx, ry, cy0) in ((200, 250, 120, 40, 206), (290, 335, 126, 44, 206), (215, 300, 70, 26, 204)):   # wind ripples in the crust
        _ridge(cv, _arc(145, cy0, rx, ry, a0, a1, .8))
    rows = ((98, 96, range(30, 270, 50)), (140, 118, range(56, 250, 56)), (186, 150, range(26, 270, 62)))
    for by, h, xs in rows:
        for i, x in enumerate(xs):
            _pine2(cv, x + rnd.randint(-3, 3), by + rnd.randint(-2, 2), h + (i % 3) * 6, rnd)
    for (zx, zy) in ((70, 60), (178, 52), (122, 100)): _zzz(cv, zx, zy, 2)
    for (cx, cy, rx, ry) in ((30, 202, 18, 8), (258, 201, 20, 8), (110, 205, 22, 6), (180, 206, 20, 6)):
        _blob(cv, cx, cy, rx, ry, SN, rnd, D=5, wob=.1, broad=.5, bounce=IC, ymax=209)   # fwump piles
    for (x, y) in ((50, 204), (78, 206), (150, 205), (214, 204), (236, 206)): _crack(cv, x, y, 5, rnd, 1, 0, 0, 2)
    for (x, y, n) in ((16, 206, 3), (272, 206, 3), (130, 207, 3)): _tuft(cv, x, y, rnd, n, 6)
    for k in range(6): _print(cv, 100 + k * 6, 205 - (k % 2) * 2, rnd, 1 if k % 2 else -1)
    for (x, y) in ((40, 90), (120, 70), (200, 100), (250, 160), (60, 170), (160, 130), (230, 60)): _glint(cv, x, y, (x // 7) % 3 == 0)

def _iceblock(cv, x0, y0, x1, y1, rnd, kind=None):
    """one hand-drawn ice block: lit top-left edges, shaded bottom-right, a chipped corner, frost and sometimes a crack"""
    kind = kind if kind is not None else rnd.choice((0, 0, 1, 1, 2))
    R = (SN, IC, SN)[kind]; b = (1, 1, 2)[kind] + rnd.choice((0, 0, 1))
    for y in range(y0, y1):
        for x in range(x0, x1):
            u = (x - x0) / max(1, x1 - x0 - 1); v = (y - y0) / max(1, y1 - y0 - 1)
            t = b + (1 if u + v > 1.25 else 0) + (1 if u + v > 1.7 else 0) - (1 if u + v < .3 else 0)
            if (u + v) > .9 and (u + v) < 1.1 and (x + y) & 1: t += 1
            cv.put(x, y, R[max(0, min(4, t))])
    for x in range(x0, x1): cv.put(x, y0, R[0]); cv.put(x, y1 - 1, R[min(4, b + 3)])   # top highlight, bottom shade
    for y in range(y0, y1): cv.put(x0, y, R[0] if y > y0 else R[0]); cv.put(x1 - 1, y, R[min(4, b + 2)])
    cv.put(x1 - 1, y1 - 1, R[4]); cv.put(x0, y1 - 1, R[min(4, b + 2)])
    c = rnd.choice((0, 1, 2, 3))   # chipped corner
    cw, ch = rnd.choice((2, 3)), rnd.choice((2, 3))
    cx, cy = (x0, y0) if c == 0 else (x1 - cw, y0) if c == 1 else (x0, y1 - ch) if c == 2 else (x1 - cw, y1 - ch)
    if (x1 - x0) > 10:
        for dy in range(ch):
            for dx in range(cw):
                if dx + dy < max(cw, ch) - (1 if c in (0, 3) else 0) + (0 if rnd.random() < .5 else 1): cv.put(cx + (dx if c in (0, 2) else cw - 1 - dx), cy + (dy if c in (0, 1) else ch - 1 - dy), SN[4] if c != 0 else IC[2])
    for _ in range(rnd.randint(1, 3)):   # frost speckle
        fx, fy = rnd.randint(x0 + 2, x1 - 3), rnd.randint(y0 + 2, y1 - 3)
        cv.put(fx, fy, SN[0]); cv.put(fx + 1, fy, SN[0]) if rnd.random() < .5 else None
    if rnd.random() < .18 and (x1 - x0) > 14:   # hairline crack
        fx, fy = rnd.randint(x0 + 4, x1 - 6), y0 + 2
        for j in range(y1 - y0 - 5): cv.put(fx + (j // 3) % 2 + (j // 5), fy + j, R[min(4, b + 3)])
    return

def _hat(cv, cx, cy, rnd):
    """a woolly red hat and a forehead peeking over the wall: knit rows, turned-up brim, bobble, two serious eyes"""
    for y in range(cy + 6, cy + 20):   # forehead
        for x in range(cx - 13, cx + 14):
            if ((x - cx) / 13.5) ** 2 + ((y - cy - 18) / 13) ** 2 <= 1: cv.put(x, y, SD[1 if x < cx + 4 else 2])
    _blob(cv, cx, cy - 4, 15, 12, EM, rnd, D=7, wob=.04, broad=.6, ymax=cy + 8)
    for y in range(cy - 14, cy + 8):   # knit ribs: short zig-zag stitch rows
        for x in range(cx - 14, cx + 15):
            if _inside(cv, x, y) and (x + (y // 2) * 2) % 4 == 0 and (y & 1): _sh(cv, x, y, 1 if x > cx - 6 else -1)
    for y in range(cy + 6, cy + 13):   # turned-up brim
        for x in range(cx - 14, cx + 15):
            u = (x - cx + 14) / 28; cv.put(x, y, EM[0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3] if y < cy + 11 else EM[3] if u > .3 else EM[2])
    for x in range(cx - 14, cx + 15, 3): cv.put(x, cy + 8, EM[3] if (x // 3) & 1 else EM[0])
    _blob(cv, cx - 1, cy - 17, 5, 5, SN, rnd, D=3, wob=.1, broad=.7)   # bobble
    for ex in (cx - 7, cx + 6):
        _rect(cv, ex, cy + 15, ex + 3, cy + 20, INK); cv.put(ex, cy + 15, CREAM) if False else None; cv.put(ex + 1, cy + 16, CREAM)
    for k in range(5): cv.put(cx - 10 + k, cy + 14, SD[3]); cv.put(cx + 5 + k, cy + 14, SD[3])   # worried-serious brows

def lm_fort(rnd, cv):   # 250 x 140
    L, Rr, WT, WB = 14, 236, 60, 124
    def edge(y): return int((y - WT) * .07)   # wall batters out a touch toward the base
    # dark joints/back face first
    for y in range(WT, WB + 3):
        for x in range(L - edge(y) - 1, Rr + edge(y) + 1): cv.put(x, y, SN[4])
    for y in range(WT - 9, WT):   # the far parapet seen through the crenels, in shade
        for x in range(L, Rr):
            u = (y - (WT - 9)) / 9; xo = (x // 11) % 2
            cv.put(x, y, SN[3] if u < .15 else (IC[3] if (x % 11) else SN[4]) if u < .8 else SN[4])
        for x in range(L, Rr, 11): cv.put(x, WT - 9, SN[2]); cv.put(x + 1, WT - 9, SN[2])
    # merlons, each a stack of two or three hand-cut blocks; one is chipped half away
    mer = ((14, 40), (50, 76), (88, 114), (166, 192), (206, 236))
    for mi, (a, b) in enumerate(mer):
        top = 38 if mi != 3 else 46
        yy = WT
        rows = [(top, top + 11), (top + 11, WT)] if mi != 3 else [(top, WT)]
        for (ya, yb) in rows:
            if mi == 1 and ya == top: a2, b2 = a + 5, b - 2
            else: a2, b2 = a, b
            xs = [a2] + ([a2 + (b2 - a2) // 2 + (ya % 3) - 1] if b2 - a2 > 22 else []) + [b2]
            for i in range(len(xs) - 1): _iceblock(cv, xs[i], ya, xs[i + 1], yb, rnd, kind=0 if ya == top else None)
        for x in range(a, b):   # snow cap on top, drooping over the front
            if mi != 3: pass
        _blob(cv, (a + b) // 2 + 1, top, (b - a) // 2 + 1, 4, SN, rnd, D=3, wob=.1, broad=.5, bounce=IC)
    # the wall courses: blocks of varied width and height, brick-offset, each its own colour
    y = WT; ri = 0; heights = (15, 17, 16, 17)
    while y < WB:
        hh = heights[ri % 4]; hh = min(hh, WB - y); x = L - edge(y) + (0 if ri % 2 == 0 else 9)
        if ri % 2: _iceblock(cv, L - edge(y), y, x, y + hh, rnd)
        while x < Rr + edge(y):
            w = rnd.choice((20, 22, 24, 26, 18)); x1 = min(x + w, Rr + edge(y))
            if Rr + edge(y) - x1 < 8: x1 = Rr + edge(y)
            _iceblock(cv, x, y, x1, y + hh, rnd); x = x1
        y += hh; ri += 1
    # ledge shadow cast by the crenel snow, frost speckle and a darker foot
    for x in range(L, Rr):
        if _inside(cv, x, WT + 1): _sh(cv, x, WT + 1, 1) if x % 2 else None
        if _inside(cv, x, WB - 2): _sh(cv, x, WB - 2, 1); _sh(cv, x, WB - 3, 1) if x % 2 else None
    for y in range(WT, WB):   # right end of the wall falls into shade
        for x in range(Rr - 18, Rr + edge(y)):
            if _inside(cv, x, y) and ((x + y) & 1 or x > Rr - 8): _sh(cv, x, y, 1)
    for y in range(WT, WB, 1):   # lit left end
        for x in range(L - edge(y), L + 6):
            if _inside(cv, x, y) and (x + y) & 1: _sh(cv, x, y, -1)
    _hat(cv, 140, 38, rnd)
    # pennant on a pole standing behind the left merlon
    for y in range(4, 42):
        cv.put(30, y, WD[1]); cv.put(31, y, WD[2]); cv.put(32, y, WD[3]) if y > 28 else None
    for k in range(3): cv.put(30, 3 - k + 3, GD[0 + k])
    cv.put(30, 3, GD[0]); cv.put(31, 3, GD[1]); cv.put(30, 2, GD[0])
    for y in range(6, 19):
        ln = 20 - (y - 6) * 3 // 4
        for x in range(32, 32 + ln):
            wave = int(1.4 * math.sin((x - 32) * .5)); yy = y + wave
            t = 0 if (y - 6) < 3 else 1 if (y - 6) < 8 else 2
            if (x - 32) > ln - 4: t = min(3, t + 1)
            cv.put(x, yy, PT[t])
        cv.put(32 + ln - 1, y + int(1.4 * math.sin((ln - 1) * .5)), PT[3])
    for k in range(3): cv.put(36 + k * 4, 11 + int(1.4 * math.sin((4 + k * 4) * .5)), CREAM)   # stitched dots on the flag
    # snow drifted along the foot of the wall, spilling over it in lumps
    for (cx, cy, rx, ry) in ((30, 126, 26, 9), (84, 128, 22, 7), (150, 127, 30, 8), (236, 125, 20, 8), (112, 130, 18, 6)):
        _blob(cv, cx, cy, rx, ry, SN, rnd, D=5, wob=.08, broad=.6, bounce=IC, ymax=137)
    for (x, y) in ((24, 128), (60, 130), (140, 128), (196, 130)): _crack(cv, x, y, 5, rnd, 1, 0, 0, 2)
    # a stack of snowballs, shaded like spheres, one rolled-off ball and a half-built one
    for (x, y, r) in ((176, 133, 5), (200, 125, 10), (222, 125, 10), (211, 106, 9)):
        for dx in range(-r, r + 14):
            for dy in range(-2, 3):
                if (dx / (r + 12)) ** 2 + (dy / 3) ** 2 <= 1 and cv.get(x + dx, y + r - 2 + dy)[3]: _sh(cv, x + dx, y + r - 2 + dy, 2)
        _blob(cv, x, y, r, r, SN, rnd, D=r * .8, wob=.05, broad=.9, bounce=IC, lo=-.2, hi=.85)
        _glint(cv, x - r // 3, y - r // 2) if r > 7 else None
    # little prints trailing to the wall
    for (x, y, f) in ((60, 133, 1), (68, 130, -1), (78, 134, 1), (86, 131, -1), (98, 135, 1), (106, 132, -1)): _print(cv, x, y, rnd, f)
    for (x, y) in ((38, 70), (130, 90), (176, 74), (224, 96)): _glint(cv, x, y)
    for k in range(7): _tuft(cv, 18 + k * 33 + (k * 7) % 9, 133, rnd, 3, 5) if k in (1, 4, 6) else None

# -------------------------------------------------------------------------------------------- section 2
def lm_stream(rnd, cv):   # 330 x 124
    def cy(x): return 78 + int(6 * math.sin(x / 38))
    # packed-snow banks first, then the glassy ribbon between them with a thick front edge
    for x in range(8, 322, 4):
        c = cy(x)
        lump(cv, x, c - 24, 12, 7 + (x // 4) % 3, SN, rnd, .04)
    for x in range(6, 324):
        c = cy(x); hh = 20 - (max(0, 26 - x, x - 298)) // 2
        for y in range(c - hh, c + hh + 1):
            u = (y - (c - hh)) / (2 * hh + 1)
            t = 0 if u < .22 else 1 if u < .55 else 2 if u < .88 else 3
            if (x * 3 + y * 7) % 23 == 0: t = max(0, t - 1)
            if (x * 2 + y * 5) % 61 < 4 and u < .7: t = 0
            cv.put(x, y, IC[t])
        for k in range(1, 6): cv.put(x, c + hh + k, IC[2] if k < 3 else IC[3] if k < 5 else SN[4])   # the ice's thick front edge
    # icicle fringe: hanging from the far bank over the ice, and from the lip at the front
    i = 0
    for x in range(14, 316, 7):
        c = cy(x); hh = 20 - (max(0, 26 - x, x - 298)) // 2
        icicle(cv, x, c - hh - 1, 7 + (i * 5) % 9, 4, IC); i += 1
    for x in range(12, 318, 9):
        c = cy(x); hh = 20 - (max(0, 26 - x, x - 298)) // 2
        icicle(cv, x, c + hh + 6, 6 + (x * 7) % 10, 4, IC)
    # cracks and glints, leaves frozen in the glass
    for x0, y0 in ((40, 62), (118, 72), (250, 58)):
        x, y = x0, y0
        for k in range(26):
            cv.put(x, y, IC[3]); cv.put(x, y - 1, CREAM) if k % 4 == 0 else None; x += 1 if k % 3 else 0; y += rnd.choice((-1, 0, 1)) if k % 2 else 0
    for x, y, col in ((92, 60, GD), (204, 74, EM), (276, 60, GD), (58, 76, MS), (236, 62, EM), (130, 58, GD)):
        for dx in range(-3, 4):
            for dy in range(-2, 3):
                if dx * dx / 10 + dy * dy / 5 <= 1: cv.put(x + dx, y + dy, col[1] if dy < 1 else col[2])
        cv.put(x - 1, y - 1, col[0]); cv.put(x + 4, y + 1, col[3]); cv.put(x + 5, y + 1, col[3])
    fx, fy = 70, 68   # fish frozen under the glass, mildly alarmed
    lump(cv, fx, fy, 14, 6, EM, rnd, 0)
    for k in range(6): rect(cv, fx + 13 + k, fy - 3 - k // 2 + (k // 4), fx + 14 + k, fy + 4 + k // 2, EM[2])
    cv.put(fx - 7, fy - 2, CREAM); cv.put(fx - 8, fy - 2, INK); cv.put(fx - 9, fy + 2, INK); cv.put(fx - 10, fy + 2, INK)
    # the little plank bridge, humped, with rope rails and a snowy hat
    bx0, bx1 = 150, 192
    for x in range(bx0, bx1):
        c = cy(x); u = (x - bx0) / (bx1 - bx0)
        for y in range(c - 30, c + 28):
            hump = int(5 * math.sin(math.pi * (y - (c - 30)) / 58))
            ty = y
            t = 0 if (x - bx0) % 7 == 0 else 1 if (x - bx0) % 7 < 4 else 2
            if y > c + 22: t = 3
            cv.put(x, y - hump, WD[t])
        for dy in (-34, 31): pass
    for x in (bx0 - 1, bx1): rect(cv, x, 14, x + 3, 100, WD[2]) if False else None
    for px, py in ((bx0 - 2, cy(bx0) - 32), (bx0 - 2, cy(bx0) + 22), (bx1 - 1, cy(bx1) - 32), (bx1 - 1, cy(bx1) + 22)):
        post(cv, px, py - 12, py + 8, 4, WD); lump(cv, px + 2, py - 12, 4, 3, SN, rnd, 0)
    for py in (cy(bx0) - 38, cy(bx0) + 18):   # rope rails
        line(cv, [(bx0, py + 1), (bx1 + 1, py + 1)], WD[0], 1); line(cv, [(bx0, py + 2), (bx1 + 1, py + 2)], WD[3], 1)
    lump(cv, 170, cy(170) - 2, 12, 4, SN, rnd, 0)
    # a couple of stones and drifts on the near bank
    for cx, cyy, rx, ry in ((26, 100, 14, 9), (304, 28, 12, 8)):
        lump(cv, cx, cyy, rx, ry, ST, rnd, .1); lump(cv, cx, cyy - ry + 1, rx - 3, 4, SN, rnd, 0)
    for x in range(10, 320, 5):
        c = cy(x); lump(cv, x + 2, c + 32, 11, 4 + (x // 5) % 2, SN, rnd, .04)


def lm_bridge(rnd, cv):   # 260 x 180
    gd = r5(RAMP["dusk"])
    def tp(x): return 112 - int(46 * math.sin(math.pi * (min(240, max(20, x)) - 20) / 220) ** .8)
    # the gully: shaded purple walls, dithered down to a dark floor with an ice skin, glints and rubble
    for y in range(118, 178):
        lo = 28 + (y - 118) // 7 + (3 if (y * 5) % 7 == 0 else 0); hi = 233 - (y - 118) // 7 - (3 if (y * 3) % 7 == 0 else 0)
        for x in range(lo, hi):
            u = (y - 118) / 60.0
            t = 3 if u < .08 else 2 if u < .22 else 3 if u < .55 else 4
            if abs(u - .22) < .05 and (x + y) & 1: t = 3
            if abs(u - .55) < .06 and (x + y) & 1: t = 4 if (x + y) % 4 else 3
            if (x * 7 + y * 3) % 41 == 0 and u > .25: t -= 1
            if x < lo + 5: t = max(2, t - 1) if (x + y) & 1 else t   # lit left wall edge
            cv.put(x, y, gd[max(1, t)])
    for y in range(164, 178):   # floor ice
        for x in range(46, 214):
            u = (y - 164) / 14
            if (x * 3 + y) % 9 < 6: cv.put(x, y, IC[3] if u < .4 else IC[4]) if (x // 3 + y) % 2 else cv.put(x, y, gd[4])
    for x in range(48, 212, 11): cv.put(x, 168 + (x % 3), IC[1]); cv.put(x + 1, 168 + (x % 3), IC[2])
    for (x, y) in ((70, 172), (120, 170), (176, 173)): _blob(cv, x, y, 6, 3, IC, rnd, D=2, wob=.1, broad=.3)
    # banks of snow either side, with the bridge's feet buried in them
    _blob(cv, 26, 152, 34, 36, SN, rnd, D=14, wob=.05, broad=.8, bounce=IC, ymax=176)
    _blob(cv, 236, 152, 34, 36, SN, rnd, D=14, wob=.05, broad=.8, bounce=IC, ymax=176)
    # the arch: wedge-shaped ice blocks (voussoirs), each its own tint, lit upper left, shaded lower right
    nseg = 15; xs = [20 + round(i * 220 / nseg) for i in range(nseg + 1)]
    for si in range(nseg):
        a, b = xs[si], xs[si + 1]; base = 1 + ((si * 5) % 3 == 0) - ((si * 7) % 4 == 0); R = IC if si % 3 else SN
        m = (tp(b) - tp(a)) / (b - a)
        for x in range(a, b):
            t0 = tp(x)
            for y in range(t0, t0 + 28):
                f = (y - t0) / 28; u = (x - a) / max(1, b - a - 1)
                t = base + (0 if f < .3 else 1 if f < .65 else 2) + (1 if u > .8 else 0) - (1 if u < .15 else 0)
                if abs(f - .3) < .08 and (x + y) & 1: t += 1
                if abs(f - .65) < .08 and (x + y) & 1: t += 1
                if f < .1: t = 0
                cv.put(x, y, R[max(0, min(4, t))])
        for y in range(tp(a), tp(a) + 28):   # joint
            jx = a - int(round(m * (y - tp(a)) * .5)); cv.put(jx, y, R[4]); cv.put(jx + 1, y, R[0]) if (y & 1) else None
        for (fx, fy) in ((a + 3, tp(a) + 10), (a + 6, tp(a) + 17)):   # frost glints
            if rnd.random() < .6: cv.put(fx, fy, SN[0]); cv.put(fx + 1, fy + 1, SN[0])
        if si % 4 == 1:   # a chipped corner on the underside
            for dx, dy in ((0, 0), (1, 0), (0, 1)): cv.put(b - 1 - dx, tp(b - 1) + 27 - dy, (0, 0, 0, 0))
    for x in range(20, 241):   # thick underside band: darker ice with a refracted stripe
        t0 = tp(x)
        for y in range(t0 + 22, t0 + 28):
            if _inside(cv, x, y): _sh(cv, x, y, 1 if y < t0 + 25 else 2)
        if (x // 3) % 4 == 0 and _inside(cv, x, t0 + 20): cv.put(x, t0 + 20, IC[0])
    for x in range(20, 241):   # blown-snow crown along the top, lumpy
        t0 = tp(x)
        n = 3 + int(2 * math.sin(x * .37) + 2 * math.sin(x * .11 + 1))
        for k in range(n):
            u = k / n; cv.put(x, t0 - n + k + 1, SN[0] if u < .45 else SN[1] if u < .8 else SN[2])
        cv.put(x, t0, SN[3]) if x % 2 else cv.put(x, t0, SN[2])
    for (cx, w) in ((70, 15), (126, 11), (196, 15)):
        _blob(cv, cx, tp(cx) - 3, w, 5, SN, rnd, D=3, wob=.1, broad=.5, bounce=IC)
    # icicles of every length hanging under the arch, three tones each
    xx = 28; k = 0
    while xx < 234:
        ln = (6, 15, 9, 22, 7, 12, 18, 8)[k % 8] + (xx * 3) % 5; t0 = tp(xx) + 27
        w = 4 if ln > 11 else 3
        icicle(cv, xx, t0 - 1, ln, w, IC)
        if ln > 14: cv.put(xx, t0 + ln + 2, IC[0]); cv.put(xx, t0 + ln + 4, IC[1]) if ln > 18 else None
        xx += 5 + (k * 3) % 5; k += 1
    # the little sign on the crest: wood planks, nails, frost on top
    ty = tp(130) - 1
    for y in range(ty - 26, ty):
        cv.put(130, y, WD[1]); cv.put(131, y, WD[2]); cv.put(132, y, WD[3]) if y % 2 else None
    for y in range(ty - 42, ty - 22):
        for x in range(110, 152):
            v = (y - (ty - 42)) / 19.0; u = (x - 110) / 41.0
            t = 0 if v < .1 else 1 if v < .45 else 2 if v < .85 else 3
            if x < 112 or x > 149: t = 3
            if v > .46 and v < .54: t = 3
            if (x * 3 + y * 5) % 11 == 0 and 0 < t < 3: t += 1 if u > .5 else -1
            cv.put(x, y, WD[t])
    for (nx, ny) in ((113, ty - 38), (147, ty - 38), (113, ty - 26), (147, ty - 26)): cv.put(nx, ny, ST[1]); cv.put(nx + 1, ny + 1, WD[3])
    _rect(cv, 116, ty - 37, 146, ty - 34, CREAM); _rect(cv, 116, ty - 31, 140, ty - 28, CREAM)
    for x in range(116, 146): cv.put(x, ty - 34, SD[1]) if x % 3 == 0 else None
    for x in range(116, 140): cv.put(x, ty - 28, SD[1]) if x % 3 == 0 else None
    _blob(cv, 130, ty - 43, 22, 4, SN, rnd, D=3, wob=.12, broad=.5)
    for x in range(114, 148, 5): icicle(cv, x, ty - 22, 3 + (x * 3) % 4, 2, IC)
    for (x, y) in ((40, 118), (214, 118), (84, 70), (176, 64)): _glint(cv, x, y, True)
    for (x, y, n) in ((14, 175, 3), (248, 175, 3)): _tuft(cv, x, y, rnd, n, 6)
    for k in range(5): _print(cv, 6 + k * 5, 176 - (k % 2) * 3, rnd, 1)

# -------------------------------------------------------------------------------------------- section 3
def lm_feather(rnd, cv):   # 190 x 206
    B = 202
    # a mound of snow, trodden down round the base
    lump(cv, 95, B - 12, 90, 22, SN, rnd, .06)
    lump(cv, 36, B - 8, 28, 10, SN, rnd, .05); lump(cv, 154, B - 8, 30, 10, SN, rnd, .05)
    bx, by, tx, ty, wid, bend = 90, B - 14, 100, 6, 36, -12
    N = 700
    for k in range(N + 1):   # vane tapers smoothly from a downy base to a soft tip
        t = k / N; sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
        w = 0 if t < .26 or t > .99 else wid * math.sin(math.pi * ((t - .26) / .73) ** .75) ** .85
        jl = 3 * ((int(sy) // 3) % 2) if w > 8 else 0; jr = 3 * (((int(sy) + 1) // 3) % 2) if w > 8 else 0   # ragged barbs
        for o in range(-int(w) + jl, int(w) + 1 - jr):
            if .5 < t < .56 and o > w * .4: continue   # a little split in the vane
            u = (o + w) / max(1, 2 * w); c = SN[0] if u < .35 else SN[1] if u < .62 else SN[2] if u < .88 else SN[3]
            cv.put(int(sx) + o, int(sy), c)
        if t > .06: cv.put(int(sx), int(sy), ST[1]); cv.put(int(sx) + 1, int(sy), ST[2])
    for k in range(30):   # downy fluff near the quill base
        t = .24 + k / 30 * .1; sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
        for o in range(-(2 + k // 4), 3 + k // 4): cv.put(int(sx) + o, int(sy), SN[1 if o < 0 else 2])
    # barbs: diagonal combed lines across the vane
    sset = set(SN) | set(IC)
    for y in range(8, B - 20):
        for x in range(0, 190):
            c = cv.get(x, y)
            if c in sset and (y * 2 + x) % 9 == 0 and cv.get(x, y - 1) in sset:
                cv.put(x, y, IC[1] if c in (SN[0], SN[1]) else SN[3])
    # shimmer: pearly pink, mint and gold glints scattered over the vane
    k = 0
    for y in range(12, B - 34):
        for x in range(0, 190):
            c = cv.get(x, y)
            if c in sset and (x * 7 + y * 13) % 71 == 0:
                cv.put(x, y, (PT[0], SE[0], GD[0])[k % 3]); k += 1
    for x, y in ((60, 40), (120, 70), (96, 24), (50, 112), (132, 130), (84, 94)): gen2.sparkle(cv, x, y, y % 20 == 4)
    lump(cv, 90, B - 16, 20, 7, SN, rnd, 0)   # snow collar round the quill
    for a in range(0, 360, 51):   # a ring of little stones, as if marking the spot
        x = 95 + int(math.cos(math.radians(a)) * 66); y = B - 6 + int(math.sin(math.radians(a)) * 9)
        lump(cv, x, y, 5, 3, ST, rnd, .1)
    for i in range(7):   # gnome prints leading round it (it was very impressive)
        x, y = 20 + i * 11, B + 2 - (i % 2) * 3; cv.put(x, y, SN[3]); cv.put(x + 1, y, SN[3]); cv.put(x, y - 1, SN[3])
    for k in range(18): cv.put(12 + k * 9, B + 1 - k % 3, IC[2])


def _barbs(cv, bx, by, tx, ty, wid, bend):
    N = int(math.hypot(tx - bx, ty - by) * 1.6)
    for k in range(N + 1):
        t = k / N
        if t < .3 or t > .94 or k % 3: continue
        sx = bx + (tx - bx) * t + bend * math.sin(t * math.pi); sy = by + (ty - by) * t
        w = wid * math.sin(math.pi * min(1, (t - .1) / .9) ** .85) * (1 - .12 * t)
        for sd in (-1, 1):
            for j in range(2, int(w) - 1):
                px, py = int(sx) + sd * j, int(sy) - j // 2
                if _inside(cv, px, py): _sh(cv, px, py, 1 if sd > 0 else 1)
                if _inside(cv, px, py - 1) and sd < 0 and j % 2: _sh(cv, px, py - 1, -1)

def lm_cairns(rnd, cv):   # 250 x 150
    for cx, widths, fh in ((52, (56, 40, 26, 16), 46), (126, (80, 58, 40, 28, 16), 62), (198, (50, 34, 20), 40)):
        _blob(cv, cx, 143, widths[0] // 2 + 14, 9, SN, rnd, D=5, wob=.08, broad=.6, bounce=IC, ymax=149)
        y = 144; tops = []
        for i, w in enumerate(widths):
            h = max(8, w // 3) + 2; cxx = cx + rnd.randint(-3, 3)
            nst = 1 if w < 30 else 2 if w < 60 else 3   # a course of two or three stones, not one smooth lump
            xs = [cxx - w // 2 + round(j * w / nst) for j in range(nst + 1)]
            for j in range(nst):
                sw = xs[j + 1] - xs[j] + 5
                _blob(cv, (xs[j] + xs[j + 1]) // 2 + rnd.randint(-1, 1), y - h // 2, sw / 2, h / 2 + rnd.randint(0, 1), ST, rnd, D=min(5, h / 2), wob=.12, broad=.5, bounce=None, lo=-.4, hi=.7)
                for _ in range(rnd.randint(1, 2)):   # lichen dot, frost on the lit lip
                    px = (xs[j] + xs[j + 1]) // 2 + rnd.randint(-sw // 3, sw // 3)
                    if rnd.random() < .5: cv.put(px, y - h + 3, SN[0]); cv.put(px + 1, y - h + 3, SN[0])
                    else: cv.put(px, y - h // 2 + 1, GD[2 if rnd.random() < .5 else 1])
                if sw > 18 and rnd.random() < .7: _crack(cv, (xs[j] + xs[j + 1]) // 2 + 2, y - h + 3, 4, rnd, 1, 1, 0, 2)
            tops.append(y - h)
            if i < len(widths) - 1: _blob(cv, cx - 2, y - h + 1, w // 2 - 4, 2, SN, rnd, D=2, wob=.1, broad=.3) if i % 2 == 0 else None   # snow caught between the courses
            y -= h - 2
        top = y
        _blob(cv, cx, top + 6, widths[-1] // 2 + 2, 4, SN, rnd, D=3, wob=.1, broad=.5)
        _feather(cv, cx, top + 6, cx + 6, top - fh, 9 + fh // 12, rnd, bend=5 * (1 if cx != 126 else -1))
        _barbs(cv, cx, top + 6, cx + 6, top - fh, 9 + fh // 12, 5 * (1 if cx != 126 else -1))
        _tuft(cv, cx - widths[0] // 2 - 8, 148, rnd, 3, 6)
    for cx in (92, 162):
        _blob(cv, cx, 143, 7, 4, ST, rnd, D=3, wob=.12, broad=.5)   # spare stones waiting
    for k in range(5): _print(cv, 14 + k * 5, 148 - k % 2, rnd, 1)
    for (x, y) in ((20, 100), (226, 90), (160, 60)): _glint(cv, x, y)

# -------------------------------------------------------------------------------------------- section 4
def lm_den(rnd, cv):   # 300 x 190
    B = 187; X = 150
    for tx in (84, 216):   # ear tufts, tucked behind the dome
        _blob(cv, tx, 52, 21, 36, SN, rnd, D=13, wob=.05, broad=.3, bounce=IC)
    _blob(cv, X, B + 6, 147, 141, SN, rnd, D=60, wob=.03, ymax=B, broad=1.0, bounce=IC, lo=-.25, hi=.82)
    for a in range(196, 345, 9):   # blown-snow lips and bumps on the silhouette
        ex = X + math.cos(math.radians(a)) * 143; ey = B + 6 + math.sin(math.radians(a)) * 137
        _blob(cv, round(ex), round(ey), 9 + (a * 7) % 6, 5 + (a * 3) % 4, SN, rnd, D=4, wob=.1, broad=.6, bounce=IC)
    for tx, s in ((84, -1), (216, 1)):   # dark feather tips
        for k in range(17):
            xx = tx + s * (k // 5) - 1
            for j in range(3 if k < 11 else 2):
                if _inside(cv, xx + j, 20 + k): cv.put(xx + j, 20 + k, DK[1 + j])
        for k in range(10, 17):
            if _inside(cv, tx + s * 3, 20 + k): cv.put(tx + s * 3 + 1, 20 + k, DK[3]) if k % 2 else None
    # --- feathers: overlapping scallops following the curve of the dome, rows spaced down the hill
    for ri, yr in enumerate(range(80, B - 4, 13)):
        off = .06 if ri % 2 else 0
        for j in range(-14, 15):
            ph = j * .125 + off; xs = X + 147 * math.sin(ph); xe = X + 147 * math.sin(ph + .125)
            w = xe - xs
            if w < 3: continue
            for i in range(int(w) + 1):
                u = i / max(1, w); px = int(round(xs + i)); sag = int(round(((px - X) / 147) ** 2 * 16))
                py = yr + sag + int(round(4 * (1 - (2 * u - 1) ** 2)))
                if _inside(cv, px, py) and cv.get(px, py)[3]:
                    _sh(cv, px, py, 2 if u > .35 else 1); _sh(cv, px, py + 1, 2 if u > .5 else 1)
                    if _inside(cv, px, py - 1): _sh(cv, px, py - 1, -2 if u < .5 else -1)
    # --- wind-sculpted ridges and snow crust cracks
    for (a0, a1, rx, ry, cyy) in ((205, 250, 118, 118, B + 6), (292, 335, 126, 124, B + 6), (240, 275, 90, 96, B + 6)):
        _ridge(cv, _arc(X, cyy, rx, ry, a0, a1, .7))
    for (x, y, n, d) in ((60, 112, 14, 1), (236, 120, 12, -1), (108, 82, 10, 1), (196, 92, 10, -1), (36, 150, 11, 1), (262, 152, 9, -1)):
        _crack(cv, x, y, n, rnd, d, 1)
    for (x, y) in ((18, 160), (276, 168)): _crack(cv, x, y, 6, rnd, 1 if x < 150 else -1, -1)
    # --- claw marks: three raking scratches high on each flank
    for (cx0, cy0, sg) in ((92, 96, 1), (206, 108, -1)):
        for k in range(3):
            for j in range(18):
                x = cx0 + k * 6 - sg * int(j * .35) + int(j * .1) * 0; y = cy0 + j + int(k * 1.2)
                if j % 9 != 8: 
                    xx = cx0 + k * 6 + sg * int(j * .4)
                    if _inside(cv, xx, y): _sh(cv, xx, y, 3)
                    if _inside(cv, xx - sg, y): _sh(cv, xx - sg, y, -2)
                    if _inside(cv, xx + sg, y) and j % 2: _sh(cv, xx + sg, y, 1)
    # --- the stone-ringed door
    H0 = (X, B + 3, 64, 82)
    for y in range(B - 95, B + 1):   # dark joints behind the stones
        for x in range(X - 82, X + 83):
            nx = (x + .5 - X) / 80; ny = (y + .5 - H0[1]) / 96
            if nx * nx + ny * ny <= 1: cv.put(x, y, ST[4])
    ns = 15
    for k in range(ns):
        a = 180 + (k + .5) * 180 / ns; ex = X + math.cos(math.radians(a)) * 72; ey = H0[1] + math.sin(math.radians(a)) * 88
        rr = 9 + (k * 5) % 3; key = abs(k - ns // 2) == 0
        _blob(cv, round(ex), round(ey), rr + (2 if key else 0), 8 + (k * 3) % 3 + (2 if key else 0), ST, rnd, D=5, wob=.1, broad=.4, bounce=None)
        if a < 340 and a > 200 and k % 2 == 0:   # snow settled on the stones
            _blob(cv, round(ex - 1), round(ey - 5), rr - 3, 3, SN, rnd, D=2, wob=.1, broad=.3)
    for y in range(B - 85, B + 3):   # hollow with reveal
        for x in range(X - 66, X + 67):
            nx = (x + .5 - X) / 64; ny = (y + .5 - H0[1]) / 82; r = nx * nx + ny * ny
            if r > 1: continue
            if r > .86:
                t = SN[2 if nx > .35 else 3] if r < .93 else SN[3 if nx > .35 else 4]
                if nx < -.2 or ny < -.8: t = DK[2] if r < .93 else DK[3]
            else: t = DK[3] if (r > .8 or ((r > .72) and (x + y) & 1)) else INK
            cv.put(x, y, t)
    for ex in (X - 26, X + 26):   # a warm glow on the dark, dithered round the eyes
        for y in range(108, B):
            for x in range(ex - 30, ex + 31):
                c = cv.get(x, y)
                if c in (INK, DK[3]):
                    d = ((x - ex) / 16) ** 2 + ((y - 147) / 21) ** 2
                    if d < 1.5 and ((d < 1.18 and (x + y) % 2 == 0) or (d < 1.5 and x % 2 == 0 and y % 2 == 0)): cv.put(x, y, GD[3] if d < 1.18 else DK[2])
    for ex in (X - 26, X + 26):   # eyes: ringed, pupil, shine
        for y in range(124, 171):
            for x in range(ex - 17, ex + 18):
                d = ((x - ex) / 16) ** 2 + ((y - 147) / 21) ** 2
                if d > 1: continue
                t = 0 if d < .28 else 1 if d < .5 else 2 if d < .78 else 3
                for bd in (.28, .5, .78):
                    if abs(d - bd) < .06 and (x + y) & 1: t = min(3, t + 1) if d > bd else max(0, t - 1) if False else min(3, t + 0)
                if d > .93: t = 3
                if (x - ex) > 4 and (y - 147) > 6 and d > .62: t = min(3, t + 1)
                cv.put(x, y, GD[t])
        for y in range(135, 163):
            for x in range(ex - 6, ex + 7):
                if ((x - ex) / 6) ** 2 + ((y - 148) / 13) ** 2 <= 1: cv.put(x, y, INK)
        _rect(cv, ex - 5, 139, ex - 2, 143, CREAM); cv.put(ex - 2, 143, SN[1]); cv.put(ex + 3, 155, SN[2]); cv.put(ex + 2, 156, SN[2])
        for k in range(7):   # brow
            by = 122 - int(3 * math.sin(math.pi * k / 6)) + (1 if (ex < X) == (k < 3) else 0)
            cv.put(ex - 14 + k * 4, by, DK[1]); cv.put(ex - 13 + k * 4, by, DK[1]); cv.put(ex - 14 + k * 4, by + 1, DK[2]); cv.put(ex - 13 + k * 4, by + 1, DK[3])
    for y in range(124, 140):   # left eye mid-blink: heavy lid and a lash line
        for x in range(X - 44, X - 7):
            d = ((x - (X - 26)) / 16) ** 2 + ((y - 147) / 21) ** 2
            lid = 139 + int(3 * (1 - ((x - (X - 26)) / 16) ** 2))
            if d <= 1 and y < lid: cv.put(x, y, DK[2] if y < lid - 2 else DK[1] if y < lid else DK[3])
    for x in range(X - 40, X - 11):
        ly = 139 + int(3 * (1 - ((x - (X - 26)) / 16) ** 2))
        if ((x - (X - 26)) / 16) ** 2 <= 1: cv.put(x, ly, INK)
    bk = ((0, 0, 9), (1, 1, 7), (2, 2, 5), (3, 3, 3), (4, 4, 1))
    for (dy, k, w) in ((0, 0, 9), (1, 0, 9), (2, 1, 7), (3, 1, 7), (4, 2, 5), (5, 2, 5), (6, 3, 3), (7, 3, 3), (8, 4, 1)):   # little beak
        for o in range(w):
            xx = X - w // 2 + o; cv.put(xx, 154 + dy, GD[1 if o < w * .45 else 2] if dy < 7 else GD[3])
    cv.put(X - 3, 154, GD[0]); cv.put(X - 2, 154, GD[0]); cv.put(X - 3, 155, GD[0])
    # blown-snow lip draped over the top of the arch
    for k in range(5):
        a = 236 + k * 17; ex = X + math.cos(math.radians(a)) * 86; ey = H0[1] + math.sin(math.radians(a)) * 103
        _blob(cv, round(ex), round(ey), 9 + (k * 5) % 3, 5 + (k * 3) % 2, SN, rnd, D=3, wob=.1, broad=.5, bounce=IC)
    # feathered rim: pale feathers fanning out round the arch over the stones
    for k in range(17):
        a = 190 + k * 10.6 + (k % 2) * 2; dxo = math.cos(math.radians(a)); dyo = math.sin(math.radians(a))
        ex = X + dxo * 76; ey = H0[1] + dyo * 92
        _leaf(cv, round(ex), round(ey), round(ex + dxo * 15), round(ey + dyo * 17), 3 + (k % 2), SN, rnd)
        cv.put(round(ex + dxo * 5), round(ey + dyo * 6), SN[4]) if k % 2 == 0 else None
    # --- foot of the hill: spilled drifts, an apron before the door, pines, tufts, pellets, prints
    for (dx, dy, rx, ry) in ((26, B - 8, 28, 12), (274, B - 8, 28, 12), (82, B - 1, 24, 7), (222, B - 1, 24, 7)):
        _blob(cv, dx, dy, rx, ry, SN, rnd, D=6, wob=.08, broad=.5, bounce=IC, ymax=B + 2)
    _blob(cv, X, B + 3, 72, 8, SN, rnd, D=5, wob=.05, broad=.5, bounce=IC, ymax=B + 3)
    for cx in (36, 264):
        _pine2(cv, cx, 150 + (8 if cx > 150 else 0), 70, rnd)
    for (x, y, n) in ((60, B, 5), (240, B + 1, 4), (108, B + 2, 3), (192, B + 2, 3), (14, B, 3)): _tuft(cv, x, y, rnd, n, 7)
    for (px, py) in ((112, B - 1), (126, B + 1), (176, B), (194, B - 1)):   # owl pellets, with a bone or two
        _blob(cv, px, py - 2, 6, 4, WD, rnd, D=3, wob=.1, broad=.4)
        cv.put(px - 1, py - 3, SD[1]); cv.put(px + 1, py - 2, ST[1])
    for (x, y) in ((100, B - 2), (136, B + 1), (160, B + 2), (206, B - 3)): _print(cv, x, y, rnd, 1 if x < 150 else -1)
    for (x, y) in ((44, 80), (120, 62), (196, 70), (254, 112), (30, 130), (150, 74)): _glint(cv, x, y, (x + y) % 3 == 0)

def _boot(cv, x, base, rnd, flip=1, tip=False):
    for dy in range(26):   # leg
        for dx in range(12):
            if tip: break
            cv.put(x + dx, base - 10 - dy, WD[1 if dx < 4 else 2 if dx < 9 else 3])
    for dy in range(10):   # foot
        for dx in range(26):
            xx = x - (4 if flip < 0 else 0) + dx if flip > 0 else x + 12 - dx
            cv.put(xx, base - dy, WD[0 if dy > 8 else 1 if dx < 8 else 2 if dy < 8 else 3])
    for dx in range(26):
        xx = x + dx if flip > 0 else x + 12 - dx
        cv.put(xx, base - 1, ST[3])   # sole
    rect(cv, x - 1, base - 38, x + 13, base - 33, SN[1]); rect(cv, x - 1, base - 38, x + 13, base - 36, SN[0])   # snowy cuff
    for k in range(3): cv.put(x + 3 + k * 3, base - 22, ST[0]); cv.put(x + 3 + k * 3, base - 16, ST[0])   # laces


def lm_doormat(rnd, cv):   # 300 x 140
    B = 136
    lump(cv, 150, B - 12, 142, 24, SN, rnd, .06)
    t0, t1 = 62, 116   # mat top and bottom edges
    for y in range(t0, t1):
        sk = (t1 - y) // 5
        for x in range(30 + 12 - (y - t0) // 4 + 0, 270 - 12 + (y - t0) // 4 + 0) if False else range(40 - (y - t0) // 4, 260 + (y - t0) // 4):
            u = (y - t0) / (t1 - t0)
            band = (y - t0)
            if band < 7 or band > t1 - t0 - 8: c = (GD[1], DK[2])[(x // 9) % 2] if band < 7 else (GD[2], DK[3])[(x // 9) % 2]   # owl-stripe borders
            else:
                t = 1 if u < .25 else 2 if u < .6 else 3
                if (x * 3 + y * 5) % 7 == 0: t = max(0, t - 1)
                if (x * 5 + y) % 11 == 0: t = min(4, t + 1)
                c = MS[t]
            cv.put(x, y, c)
    for y in range(t1, t1 + 4):   # the mat's thick front edge
        for x in range(40 - (t1 - t0) // 4 - 1, 260 + (t1 - t0) // 4 + 1): cv.put(x, y, MS[3] if y < t1 + 3 else MS[4])
    for x in range(26, 274, 3):   # moss fringe
        for k in range(3 + (x // 3) % 3): cv.put(x, t1 + 4 + k, MS[2 if k < 2 else 3])
    for y in range(t0 + 8, t1 - 8):   # stitched side borders
        for x in (46 - (y - t0) // 4, 254 + (y - t0) // 4): cv.put(x, y, CREAM) if y % 3 else None
    _text(cv, 108, t0 + 13, "HOO", GD[0], 6)
    _text(cv, 109, t0 + 14, "HOO", GD[2], 6) if False else None
    # boots left on the mat: one upright, one tipped over, a bit muddy
    _boot(cv, 56, 112, rnd, 1)
    _boot(cv, 86, 114, rnd, 1)
    cv.put(70, 100, WD[3]); cv.put(71, 101, WD[3])
    # a lantern with a tiny flame, on a hook post
    lx = 224
    post(cv, lx + 8, 22, 112, 4, WD)
    line(cv, [(lx + 10, 24), (lx - 2, 24)], WD[2], 2)
    line(cv, [(lx, 24), (lx, 38)], ST[3], 1)
    rect(cv, lx - 8, 38, lx + 9, 42, WD[3])
    for y in range(42, 66):
        for x in range(lx - 7, lx + 8):
            edge = x in (lx - 7, lx + 7)
            cv.put(x, y, WD[3] if edge else GD[0] if (x - lx) ** 2 + (y - 54) ** 2 < 44 else GD[1] if x < lx + 2 else GD[2])
    rect(cv, lx - 8, 66, lx + 9, 69, WD[3])
    for k in range(6): cv.put(lx - 8 + k * 3, 36 - (k % 2), WD[3])
    poly(cv, [(lx - 10, 38), (lx + 10, 38), (lx, 28)], SN[1]); poly(cv, [(lx - 10, 38), (lx - 2, 38), (lx, 28)], SN[0])
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(lx + 16 + dx, 50 + dy, GD[0]); cv.put(lx - 18 + dx, 58 + dy, GD[1])
    lump(cv, lx + 10, 113, 16, 5, SN, rnd, 0)
    for ex, ey in ((22, 24), (270, 18), (170, 20), (130, 40)):   # soft feathers drifting down
        _feather(cv, ex, ey + 14, ex + 2, ey, 4, rnd, bend=3)
    for x, y in ((40, 128), (110, 130), (190, 128), (262, 126)): lump(cv, x, y, 8, 4, ST, rnd, .1)


LM = {"315-gate": (220, 190, lm_gate), "315-lamps": (240, 200, lm_lamps), "315-slope": (290, 210, lm_slope), "315-fort": (250, 140, lm_fort),
      "315-stream": (330, 124, lm_stream), "315-bridge": (260, 180, lm_bridge), "315-feather": (190, 206, lm_feather), "315-cairns": (250, 150, lm_cairns),
      "315-den": (300, 190, lm_den), "315-doormat": (300, 140, lm_doormat)}
