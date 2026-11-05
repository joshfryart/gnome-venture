"""Route 315 (tundra, Den of the Great White Owl) landmarks: gate, lamp lane, pine slope, snow fort, frozen stream, icicle bridge,
giant feather, feather cairns, owl den, doormat. See gen2.LANDMARKS for the format."""
import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
from PIL import ImageDraw

SN, IC, PN, ST, WD, GD, EM, PT, DK, MS = (r5(RAMP[k]) for k in ("snow", "ice", "pine", "stone", "wood", "gold", "ember", "petal", "dusk", "moss"))
FONT = {"O": "111101101101111", "W": "101101101111101", "L": "100100100100111", "Y": "101101010010010", "E": "111100110100111",
        "S": "111100111001111", "?": "111001011000010", ".": "000000000000010", "H": "101101111101101"}

def _text(cv, x, y, s, c, sc=2):
    for i, ch in enumerate(s):
        g = FONT[ch]
        for k, b in enumerate(g):
            if b == "1":
                for dx in range(sc):
                    for dy in range(sc): cv.put(x + i * 4 * sc + (k % 3) * sc + dx, y + (k // 3) * sc + dy, c)

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

# -------------------------------------------------------------------------------------------- section 0
def lm_gate(rnd, cv):   # 220 x 190
    _rect(cv, 76, 82, 144, 88, WD[2])
    for x in range(36, 76): pass
    for x0 in (36, 150):
        _col(cv, x0, x0 + 34, 64, 186, ST, rnd, .1)
        for y in range(70, 186, 14):
            for x in range(x0, x0 + 34): cv.put(x, y, ST[3])
            for x in range(x0 + (9 if (y // 14) % 2 else 20), x0 + 34, 22):
                for yy in range(y, min(186, y + 14)): cv.put(x, yy, ST[3])
        lump(cv, x0 + 17, 62, 24, 14, SN, rnd, .06)   # snow hat
        _rect(cv, x0 + 15, 44, x0 + 19, 52, SN[1])   # tiny snowflake topper
        for dx, dy in ((0, -3), (0, 3), (-3, 0), (3, 0), (0, 0)): cv.put(x0 + 17 + dx, 46 + dy, CREAM)
    for y in range(94, 138):   # sign board, hung on two cords
        for x in range(74, 146):
            t = 0 if y < 97 else 3 if y > 134 else 1 if y < 118 else 2
            if x < 76 or x > 143: t = 3
            cv.put(x, y, WD[t])
    for xx in (84, 136):
        for y in range(88, 94): cv.put(xx, y, ST[3])
    _text(cv, 83, 98, "OWL?", CREAM, 3 if False else 2); _text(cv, 83, 118, "YES.", GD[0], 2)
    for dx, dy in ((0, 0), (1, 0), (0, 1), (-1, 0), (0, -1)): cv.put(133 + dx, 124 + dy, SN[0])
    _drift(cv, 55, 190, 50, 18, rnd); _drift(cv, 167, 190, 50, 18, rnd); _drift(cv, 110, 190, 36, 10, rnd)
    for k in range(5): cv.put(98 + k * 6, 178 + k % 2, IC[2]); cv.put(99 + k * 6, 178 + k % 2, IC[2])

def lm_lamps(rnd, cv):   # 290 x 200
    for i, (cx, top) in enumerate(((46, 58), (112, 44), (178, 52), (244, 40))):
        by = 192 - (i % 2) * 3
        _drift(cv, cx, by + 2, 24, 9, rnd)
        _col(cv, cx - 3, cx + 3, top + 34, by - 4, ST, rnd, 0)
        _col(cv, cx - 7, cx + 7, by - 16, by - 4, ST, rnd, 0)   # base block
        for y in range(top + 10, top + 36):   # lantern, warm bulb
            for x in range(cx - 11, cx + 12):
                edge = x < cx - 8 or x > cx + 8 or y > top + 32
                cv.put(x, y, WD[3] if edge else GD[0] if (x - cx) ** 2 + (y - top - 22) ** 2 < 40 else GD[1] if x < cx + 3 else GD[2])
        for x in range(cx - 1, cx + 2):
            for y in range(top + 10, top + 36): cv.put(x, y, WD[3])
        for y in range(top, top + 12):   # roof hat with snow
            hw = (y - top) * 14 // 12 + 2
            for x in range(cx - hw, cx + hw + 1): cv.put(x, y, SN[0] if x < cx - hw // 3 else SN[1] if x < cx + hw // 2 else SN[2])
        lump(cv, cx, top + 11, 17, 5, SN, rnd, 0)
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(cx + dx - 6, top + 4 + dy, CREAM)   # one snowflake
        cv.put(cx - 6, top + 4, IC[1])
        cv.put(cx + 12, top + 6, GD[0]); cv.put(cx + 13, top + 5, GD[0]); cv.put(cx - 14, top + 24, GD[1])
    _rect(cv, 140, 5, 142, 8, GD[0]) if False else None

# -------------------------------------------------------------------------------------------- section 1
def lm_slope(rnd, cv):   # 290 x 210
    lump(cv, 145, 206, 142, 54, SN, rnd, .08)
    rows = ((98, 96, range(30, 270, 50)), (140, 118, range(56, 250, 56)), (186, 150, range(26, 270, 62)))
    for by, h, xs in rows:
        for i, x in enumerate(xs):
            _pine(cv, x + rnd.randint(-3, 3), by + rnd.randint(-2, 2), h - 12 + rnd.randint(0, 24) if False else h + (i % 3) * 6, rnd)
    for (zx, zy) in ((70, 60), (178, 52), (122, 100)):   # sleepy z's
        _zzz(cv, zx, zy, 2)
    lump(cv, 28, 200, 14, 7, SN, rnd, 0); lump(cv, 258, 201, 16, 7, SN, rnd, 0)   # fwump piles
    for k in range(14): cv.put(10 + k * 19, 205 - k % 3, IC[1])

def lm_fort(rnd, cv):   # 250 x 140
    sw = r5(RAMP["snow"])
    _col(cv, 14, 236, 58, 124, sw, rnd, .03)
    for y in range(58, 124, 16):
        for x in range(14, 236): cv.put(x, y, SN[3])
        for x in range(14 + (11 if (y // 16) % 2 else 0), 236, 22):
            for yy in range(y, min(124, y + 16)): cv.put(x, yy, SN[3])
    for k in range(6):   # crenellations
        x0 = 14 + k * 38
        _col(cv, x0, x0 + 22, 38, 60, sw, rnd, .03)
        for x in range(x0, x0 + 22): cv.put(x, 38, SN[0]); cv.put(x, 39, SN[0])
    _rect(cv, 14, 124, 236, 128, SN[3])
    lump(cv, 124, 40, 14, 10, EM, rnd, 0)   # a woolly hat peeking over, very serious
    lump(cv, 124, 30, 5, 5, SN, rnd, 0)
    _rect(cv, 110, 44, 139, 50, EM[2])
    for ex in (116, 130): _rect(cv, ex, 47, ex + 3, 51, INK)
    for x in range(12, 14): pass
    for y in range(4, 40): cv.put(30, y, WD[1]); cv.put(31, y, WD[2])   # flag
    for y in range(6, 18):
        for x in range(32, 50 - (y - 6) // 3): cv.put(x, y, PT[1] if y < 12 else PT[2])
    lump(cv, 205, 126, 22, 6, SN, rnd, 0)
    for i, (x, y) in enumerate(((196, 114), (214, 114), (205, 102))): lump(cv, x, y, 8, 8, SN, rnd, 0)   # snowball stack
    _drift(cv, 70, 136, 56, 12, rnd); _drift(cv, 160, 138, 40, 9, rnd)
    for k in range(6): cv.put(40 + k * 5, 133 - k % 2, IC[2])

# -------------------------------------------------------------------------------------------- section 2
def lm_stream(rnd, cv):   # 290 x 110
    def cy(x): return 62 + int(7 * math.sin(x / 38))
    for x in range(4, 286):
        c = cy(x); hh = 22 - (max(0, 30 - x, x - 260)) // 2
        for y in range(c - hh, c + hh + 1):
            u = (y - (c - hh)) / (2 * hh + 1)
            t = 0 if u < .22 else 1 if u < .55 else 2 if u < .88 else 3
            if (x * 3 + y * 7) % 23 == 0: t = max(0, t - 1)
            cv.put(x, y, IC[t])
    for x0, y0 in ((50, 56), (130, 70), (206, 52)):   # cracks and glints
        x, y = x0, y0
        for k in range(26):
            cv.put(x, y, IC[3]); x += 1 if k % 3 else 0; y += rnd.choice((-1, 0, 1)) if k % 2 else 0
        for k in range(10): cv.put(x0 + k, y0 - 10, CREAM) if k < 7 else None
    fx, fy = 150, cy(150) - 2   # fish frozen under the glass, mildly alarmed
    lump(cv, fx, fy, 16, 7, EM, rnd, 0);
    for k in range(7): _rect(cv, fx + 15 + k, fy - 3 - k // 2 + (k // 4), fx + 16 + k, fy + 4 + k // 2, EM[2])
    cv.put(fx - 8, fy - 2, CREAM); cv.put(fx - 9, fy - 2, INK); cv.put(fx - 10, fy + 2, INK); cv.put(fx - 11, fy + 2, INK)
    for x in range(6, 284, 5):   # snow banks top and bottom
        c = cy(x)
        lump(cv, x, c - 24, 11, 6 + (x // 5) % 3, SN, rnd, .04)
        lump(cv, x + 2, c + 26, 11, 5 + (x // 5) % 2, SN, rnd, .04)
    for cx, cyy, rx, ry in ((28, 90, 14, 9), (262, 28, 12, 8)):
        lump(cv, cx, cyy, rx, ry, ST, rnd, .1); lump(cv, cx, cyy - ry + 1, rx - 3, 4, SN, rnd, 0)

def lm_bridge(rnd, cv):   # 260 x 180
    gd = r5(RAMP["dusk"])
    for y in range(124, 176):   # the ditch of blue shadow
        for x in range(30, 232):
            u = (y - 124) / 52; t = 2 if u < .2 else 3 if u < .55 else 4
            cv.put(x, y, gd[t] if (x * 5 + y) % 13 else gd[max(2, t - 1)])
    for x in range(4, 36):
        for y in range(120, 176): cv.put(x, y, SN[1 if y < 128 else 2 if y < 150 else 3] if x < 34 - (y - 120) // 3 else (0, 0, 0, 0))
    for x in range(226, 256):
        for y in range(120, 176): cv.put(x, y, SN[1 if y < 128 else 2 if y < 150 else 3] if x > 228 + (y - 120) // 3 else (0, 0, 0, 0))
    lump(cv, 24, 126, 30, 10, SN, rnd, 0); lump(cv, 236, 126, 30, 10, SN, rnd, 0)
    for x in range(20, 241):   # arched deck of packed snow
        tp = 112 - int(46 * math.sin(math.pi * (x - 20) / 220) ** .8)
        for y in range(tp, tp + 28):
            f = (y - tp) / 28; t = 0 if f < .15 else 1 if f < .5 else 2 if f < .8 else 3
            if (x // 14) % 2 and f > .45: t = min(3, t + 1)
            if (x * 7 + y * 3) % 19 == 0: t = max(0, t - 1)
            cv.put(x, y, SN[t])
    for x in range(26, 236, 14):   # block seams
        tp = 112 - int(46 * math.sin(math.pi * (x - 20) / 220) ** .8)
        for y in range(tp + 6, tp + 28): cv.put(x, y, SN[3])
    for x in range(30, 232, 5):   # icicles
        tp = 112 - int(46 * math.sin(math.pi * (x - 20) / 220) ** .8) + 28
        ln = 6 + ((x * 13) % 7) * 3
        for k in range(ln):
            w = 2 if k < ln * .55 else 1
            for o in range(w): cv.put(x + o, tp + k, IC[0] if o == 0 else IC[1] if k < ln - 3 else IC[2])
    for cx in (70, 190):   # snow-lumps on the deck
        tp = 112 - int(46 * math.sin(math.pi * (cx - 20) / 220) ** .8)
        lump(cv, cx, tp - 2, 14, 6, SN, rnd, 0)
    tp = 66
    for y in range(tp - 26, tp): cv.put(130, y, WD[1]); cv.put(131, y, WD[2])   # tiny sign: sturdy
    _rect(cv, 112, tp - 40, 150, tp - 22, WD[1]); _rect(cv, 112, tp - 24, 150, tp - 22, WD[3])
    _rect(cv, 116, tp - 36, 146, tp - 33, CREAM); _rect(cv, 116, tp - 30, 140, tp - 27, CREAM)

# -------------------------------------------------------------------------------------------- section 3
def lm_feather(rnd, cv):   # 150 x 250
    lump(cv, 75, 232, 62, 16, SN, rnd, .06); lump(cv, 40, 236, 24, 9, SN, rnd, 0); lump(cv, 112, 237, 26, 8, SN, rnd, 0)
    _feather(cv, 70, 230, 84, 12, 34, rnd, bend=-12)
    for y in range(205, 226):   # snow collar round the quill
        for x in range(60, 82): cv.put(x, y, WD[3]) if False else None
    lump(cv, 72, 228, 22, 8, SN, rnd, 0)
    for k in range(14): cv.put(20 + k * 8, 244 - k % 3, IC[2])
    for x in range(98, 116): cv.put(x, 140 + (x - 98) // 3, PT[1]) if False else None

def lm_cairns(rnd, cv):   # 250 x 150
    for cx, widths, fh in ((52, (56, 40, 26, 16), 46), (126, (80, 58, 40, 28, 16), 62), (198, (50, 34, 20), 40)):
        _drift(cv, cx, 148, widths[0] // 2 + 12, 9, rnd)
        top = _stonepile(cv, cx, 144, widths, rnd)
        lump(cv, cx, top + 6, widths[-1] // 2 + 2, 4, SN, rnd, 0)
        _feather(cv, cx, top + 6, cx + 6, top - fh, 9 + fh // 12, rnd, bend=5 * (1 if cx != 126 else -1))
    for k in range(5): cv.put(10 + k * 50, 148 - k % 2, IC[2])
    for cx in (92, 162):
        lump(cv, cx, 143, 6, 4, ST, rnd, .1)   # spare stones waiting

# -------------------------------------------------------------------------------------------- section 4
def lm_den(rnd, cv):   # 300 x 190
    for tx in (86, 214):   # ear tufts
        lump(cv, tx, 52, 22, 36, SN, rnd, .06)
    lump(cv, 150, 195, 146, 150, SN, rnd, .06)   # snowy hill
    for tx, s in ((86, -1), (214, 1)):   # dark feather tips on the tufts
        for k in range(16):
            for j in range(3): cv.put(tx + s * (k // 4) - 2 + j, 20 + k, DK[2 + (j > 1)]) if cv.get(tx + s * (k // 4) - 2 + j, 20 + k)[3] and cv.get(tx + s * (k // 4) - 2 + j, 20 + k) != INK else None
    for y in range(66, 100, 11):   # chest chevrons
        for x in range(60, 250, 17):
            if cv.get(x, y)[3] and abs(x - 150) > 70:
                for k in range(5): cv.put(x - k, y + k // 2 + 0, IC[2]); cv.put(x + k, y + k // 2, IC[2])
    for cx in (40, 262):
        _pine(cv, cx, 150 + (8 if cx > 150 else 0), 70, rnd)
    cx0 = 150
    for y in range(104, 190):   # the hollow
        for x in range(cx0 - 70, cx0 + 71):
            nx = (x + .5 - cx0) / 70; ny = (y + .5 - 190) / 86
            if nx * nx + ny * ny <= 1:
                v = (nx * nx + ny * ny)
                cv.put(x, y, DK[3] if v > .55 else INK)
    for a in range(180, 361, 2):   # stone rim and snow lip around the arch
        x = cx0 + math.cos(math.radians(a)) * 76; y = 190 + math.sin(math.radians(a)) * 92
        if a % 6 == 0: lump(cv, int(x), int(y), 9, 8, ST, rnd, .1)
    lump(cv, cx0, 100, 56, 11, SN, rnd, 0)
    for ex in (cx0 - 26, cx0 + 26):   # two big kind glowing eyes
        for y in range(126, 168):
            for x in range(ex - 16, ex + 17):
                d = ((x - ex) / 16) ** 2 + ((y - 147) / 21) ** 2
                if d <= 1: cv.put(x, y, GD[0] if d < .35 else GD[1] if d < .7 else GD[2])
        for y in range(135, 162):
            for x in range(ex - 6, ex + 7):
                if ((x - ex) / 6) ** 2 + ((y - 148) / 13) ** 2 <= 1: cv.put(x, y, INK)
        _rect(cv, ex - 5, 139, ex - 1, 144, CREAM)
    for y in range(125, 140):   # left eye mid-blink: heavy lid
        for x in range(cx0 - 43, cx0 - 8):
            if cv.get(x, y) in (GD[0], GD[1], GD[2], INK) : cv.put(x, y, DK[3] if y < 138 else DK[2]) if (x - (cx0 - 26)) ** 2 / 256 + (y - 147) ** 2 / 441 <= 1 and y < 138 else None
    for x in range(cx0 - 14, cx0 + 14): cv.put(x, 160 + abs(x - cx0) // 5, GD[2]) if False else None
    _rect(cv, cx0 - 4, 156, cx0 + 5, 160, GD[2]); _rect(cv, cx0 - 2, 160, cx0 + 3, 166, GD[3])   # small beak between the eyes
    lump(cv, 38, 184, 26, 10, SN, rnd, 0); lump(cv, 262, 184, 26, 10, SN, rnd, 0)

def lm_doormat(rnd, cv):   # 230 x 100
    _drift(cv, 115, 96, 106, 22, rnd)
    for y in range(36, 88):
        sk = (88 - y) // 6
        for x in range(26 + sk, 204 - sk):
            u = (y - 36) / 52; t = 1 if u < .25 else 2 if u < .6 else 3
            if (x * 3 + y * 5) % 7 == 0: t = max(0, t - 1)
            if (x * 5 + y) % 11 == 0: t = min(4, t + 1)
            cv.put(x, y, MS[t])
    for y in range(36, 88):   # stitched border
        sk = (88 - y) // 6
        for x in (30 + sk, 199 - sk): cv.put(x, y, CREAM) if y % 3 else None
    for x in range(30, 200, 3):
        sk0 = (88 - 40) // 6; sk1 = 0
        cv.put(x + 2, 40, CREAM); cv.put(x + 2, 83, CREAM) if 36 + 0 < x < 196 else None
    for x in range(26, 204, 3):   # moss fringe
        for k in range(3 + (x // 3) % 3): cv.put(x, 88 + k, MS[2 if k < 2 else 3])
    _text(cv, 72, 52, "HOO", GD[0], 5)
    for ex, ey in ((28, 20), (196, 14), (160, 24)):   # soft feathers drifting down
        _feather(cv, ex, ey + 14, ex + 2, ey, 4, rnd, bend=3)
    for k in range(4): lump(cv, 46 + k * 46, 92, 7, 4, ST, rnd, .1) if k % 2 == 0 else None

LM = {"315-gate": (220, 190, lm_gate), "315-lamps": (290, 200, lm_lamps), "315-slope": (290, 210, lm_slope), "315-fort": (250, 140, lm_fort),
      "315-stream": (290, 110, lm_stream), "315-bridge": (260, 180, lm_bridge), "315-feather": (150, 250, lm_feather), "315-cairns": (250, 150, lm_cairns),
      "315-den": (300, 190, lm_den), "315-doormat": (230, 100, lm_doormat)}
