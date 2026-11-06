import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
"""Forest landmarks, routes 304-306 (12 sprites). Hard pixels only; the figure is centred on canvas_w/2, base at the bottom."""

BIRCH = [H(c) for c in ("#fffdf2", "#ece9de", "#c4c0b6", "#8a8586")]
BIRCH5 = r5(BIRCH)

def _ok(cv, x, y):
    c = cv.get(x, y); return c[3] and c != INK

def _bole(cv, cxf, wf, y0, y1, R, rnd, bark=True):
    for y in range(y0, y1):
        c = cxf(y); w = wf(y)
        for x in range(int(c - w), int(c + w) + 1):
            u = (x - (c - w)) / max(1, 2 * w)
            t = 0 if u < .12 else 1 if u < .32 else 2 if u < .6 else 3 if u < .85 else 4
            if bark and (x * 13 + (y // 5) * 7) % 9 == 0: t = min(4, t + 1)
            elif bark and rnd.random() < .04: t = max(0, t - 1)
            cv.put(x, y, R[t])

def _disc(cv, cx, cy, r, col, ry=None):
    ry = ry or r
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - r), int(cx + r) + 1):
            if (x - cx) ** 2 / r ** 2 + (y - cy) ** 2 / ry ** 2 <= 1: cv.put(x, y, col)

def _rect(cv, x0, y0, x1, y1, col):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, col)

def _line(cv, x0, y0, x1, y1, col, w=1):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for a in range(w):
            for b in range(w): cv.put(int(round(x)) + a, int(round(y)) + b, col)

def _acorn(cv, x, y, rnd, s=1):
    L = r5(RAMP["litter"]); W = r5(RAMP["wood"])
    lump(cv, x, y + 2 * s, 3.5 * s, 5 * s, L, rnd, 0)
    lump(cv, x, y - 2 * s, 4.5 * s, 3 * s, [W[1], W[2], W[3], W[4], W[4]], rnd, 0)
    cv.put(x, y - 6 * s, W[3]); cv.put(x, y - 5 * s, W[3])

def _mush(cv, x, y, rnd, s=1):
    E = r5(RAMP["ember"]); S = r5(RAMP["sand"])
    _rect(cv, x - s, y - 4 * s, x + s + 1, y + 1, S[2])
    lump(cv, x, y - 5 * s, 5 * s, 3.5 * s, E, rnd, 0)
    cv.put(x - s, y - 6 * s, CREAM); cv.put(x + 2 * s, y - 5 * s, CREAM)

def _tuft(cv, x, y, rnd, n=4, h=8):
    M = RAMP["moss"]
    for i in range(n):
        xx = x + i * 2 - n; hh = h + rnd.randint(-2, 2); lean = rnd.choice((-1, 1))
        for k in range(hh): cv.put(xx + (lean * k) // 4, y - k, M[0] if k > hh - 3 else M[1 + (i % 2)])

def _hat(cv, x, y, rnd):   # tiny pointed red hat, base centred at x, bottom at y
    E = RAMP["ember"]
    for k in range(20):
        hw = (20 - k) * 8 // 20 + (0 if k < 19 else 0)
        for xx in range(x - hw, x + hw + 1):
            cv.put(xx + (k // 8), y - k, E[0] if xx < x - hw // 2 else E[1] if xx < x + hw // 3 else E[2])
    for xx in range(x - 9, x + 10): cv.put(xx, y, RAMP["sand"][1]); cv.put(xx, y - 1, RAMP["sand"][0])

# ----------------------------------------------------------------------------------- hand-drawn toolkit
BAY = ((.125, .625), (.875, .375))
def dith(s, x, y):   # float tone 0..4 -> int tone, 2x2 ordered dither (checker at half steps)
    s = 0 if s < 0 else 4 if s > 4 else s; t = int(s)
    return 4 if t >= 4 else t + (1 if s - t > BAY[y & 1][x & 1] else 0)

def dome_s(nx, ny):   # float tone for a surface normal (nx, ny); lit top-left
    return (0.95 - gen2.shade_pt(nx, ny)) * 3.3

def _isw(c, W): return c in W

def bark(cv, span, y0, y1, W, rnd, nr=10, wob=.05):
    """Cylinder-shaded bark: ridges bunch towards the edges so they wrap, furrows wander and break, lit lip left of every furrow, scale flecks."""
    rg = []
    for i in range(nr):
        th = -1.38 + 2.76 * (i + rnd.uniform(.15, .85)) / nr
        rg.append((math.sin(th), rnd.uniform(0, 6.3), rnd.uniform(13, 27), rnd.randint(0, 50), rnd.randint(13, 31)))
    for y in range(y0, y1):
        sp = span(y)
        if not sp: continue
        xl, xr = sp; c = (xl + xr + 1) / 2; w = (xr - xl + 1) / 2; fur = {}
        for p, ph, lam, off, seg in rg:
            if ((y + off) // seg) % 4 == 0: continue
            pp = p + wob * math.sin(y / lam + ph) + wob * .6 * math.sin(y / (lam * .43) + ph * 2)
            xx = int(round(c + pp * w)); fur[xx] = 2
            if ((y + off) // 4) % 3 == 0: fur.setdefault(xx + 1, 1)
        for x in range(xl, xr + 1):
            u = (x + .5 - c) / w
            b = .15 + 3.25 * ((u + 1) / 2) ** 1.12
            if u > .8: b -= 1.1 * (u - .8) / .2      # bounce light on the shaded edge
            f = fur.get(x, 0)
            if f == 2: s = b + 2.2
            elif f == 1: s = b + 1.3
            elif x + 1 in fur: s = b - .9
            elif x - 1 in fur: s = b + .7
            else:
                s = b
                if (x * 7 + y * 3) % 19 == 0: s -= .8
                elif (x * 5 + y * 11) % 23 == 0: s += .8
            cv.put(x, y, W[dith(s, x, y)])

def crack(cv, x, y, n, W, rnd, vert=True):
    for k in range(n):
        if not _isw(cv.get(x, y), W) : break
        cv.put(x, y, W[4])
        a, b = (x - 1, y) if vert else (x, y - 1)
        if _isw(cv.get(a, b), W) and cv.get(a, b) != W[4]: cv.put(a, b, W[1])
        if vert: y += 1; x += rnd.choice((-1, 0, 0, 1))
        else: x += 1; y += rnd.choice((-1, 0, 0, 1))

def knot(cv, cx, cy, rx, ry, W, rnd):
    for y in range(int(cy - ry) - 2, int(cy + ry) + 3):
        for x in range(int(cx - rx) - 2, int(cx + rx) + 3):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry; d = math.hypot(nx, ny)
            if d > 1.15 and d < 1.5 and nx + ny > .2: cv.put(x, y, W[4]) if _isw(cv.get(x, y), W) else None    # cast shade
            if d > 1: continue
            if d > .72: s = 1 if nx + ny < -.15 else 3.4 if nx + ny > .4 else 2.2
            elif d > .45: s = 2.6 + (nx + ny) * .6
            else: s = 4
            cv.put(x, y, W[dith(s, x, y)] if d > .45 else INK if d < .3 else W[4])
    cv.put(int(cx - rx * .55), int(cy - ry * .55), W[2]); cv.put(int(cx + rx * .15), int(cy + ry * .2), W[3])

def root(cv, pts, w0, w1, W, rnd):
    N = 70; sm = []
    for i in range(N + 1):
        t = i / N; x = (1 - t) ** 2 * pts[0][0] + 2 * (1 - t) * t * pts[1][0] + t * t * pts[2][0]
        y = (1 - t) ** 2 * pts[0][1] + 2 * (1 - t) * t * pts[1][1] + t * t * pts[2][1]
        sm.append((x, y, (w0 + (w1 - w0) * t ** .6) / 2 * (1 + .1 * math.sin(i * .33 + pts[0][0]) + .06 * math.sin(i * .9))))
    for i, (x, y, r) in enumerate(sm):
        j = min(N, i + 1); k = max(0, i - 1); tx = sm[j][0] - sm[k][0]; ty = sm[j][1] - sm[k][1]
        L = math.hypot(tx, ty) or 1; nx, ny = -ty / L, tx / L
        if ny > 0: nx, ny = -nx, -ny
        v = -r - .5
        while v <= r + .5:
            vn = max(-1, min(1, v / r)); px = int(round(x + nx * v)); py = int(round(y + ny * v))
            s = dome_s(nx * vn, ny * vn)
            if abs(vn - .3) < .13 and (i // 11) % 5 != 4: s += 1.5
            elif abs(vn + .35) < .1 and (i // 9) % 4 != 3: s += 1.2
            cv.put(px, py, W[dith(s, px, py)]); v += .5

def moss(cv, cx, cy, rx, ry, rnd, onto=None, drip=True):
    M = r5(RAMP["moss"]); ph = [rnd.uniform(0, 6.3) for _ in range(3)]; lowest = {}
    for y in range(int(cy - ry * 1.4), int(cy + ry * 1.4) + 1):
        for x in range(int(cx - rx * 1.4), int(cx + rx * 1.4) + 1):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry; a = math.atan2(ny, nx)
            if math.hypot(nx, ny) > 1 + .13 * math.sin(a * 5 + ph[0]) + .08 * math.sin(a * 9 + ph[1]): continue
            c = cv.get(x, y)
            if onto is not None and not onto(c): continue
            s = dome_s(nx * .8, ny * .8) * .8 + .2 + (.7 if (x * 3 + y * 7) % 11 == 0 else 0)
            cv.put(x, y, M[dith(s, x, y)]); lowest[x] = max(lowest.get(x, y), y)
    if drip:
        for x, yy in lowest.items():
            if (x * 7) % 5 == 0:
                for k in range(1, 3 + (x * 3) % 5):
                    if onto is None or onto(cv.get(x, yy + k)): cv.put(x, yy + k, M[2 if k < 3 else 3])
    for k in range(int(rx * ry / 18)):   # bright flecks
        x = int(cx + rnd.uniform(-.8, .8) * rx); y = int(cy + rnd.uniform(-.8, .5) * ry)
        if cv.get(x, y) in M: cv.put(x, y, M[0]); cv.put(x + 1, y, M[1])

def shelf(cv, x, y, rw, rh, rnd):   # bracket fungus: flat underside at y, domed top, concentric growth bands, pale pored lip
    G = RAMP["gold"]; WD = RAMP["wood"]
    for yy in range(y - rh, y + 1):
        for xx in range(x, x + rw + 1):
            nx = (xx - x) / rw; ny = (y - yy) / rh
            if nx * nx + ny * ny > 1: continue
            d = math.hypot(nx, ny); band = int(d * 8)
            s = dome_s(nx * .7 - .15, -ny * .8) * .85 + .2 + (.9 if band % 3 == 2 else 0) + (.7 if d > .88 else 0) - (.5 if band % 3 == 0 and d > .2 else 0)
            c = G[min(3, dith(s, xx, yy))]
            if d > .9: c = WD[1] if ny > .25 else WD[2]
            cv.put(xx, yy, c)
    for xx in range(x, x + rw + 1):
        nx = (xx - x) / rw
        if nx < 1:
            cv.put(xx, y, RAMP["sand"][0] if xx % 2 else CREAM); cv.put(xx, y + 1, RAMP["sand"][2] if xx % 2 else RAMP["sand"][1]); cv.put(xx, y + 2, WD[2] if xx % 3 else WD[3])
            if rw > 16 and xx % 4 == 0: cv.put(xx, y + 3, WD[3])

def lichen(cv, cx, cy, rx, ry, rnd, onto):
    P = RAMP["sea"][0]; Q = RAMP["moss"][0]
    for k in range(int(rx * ry * .6)):
        a = rnd.uniform(0, 6.3); d = rnd.random() ** .6
        x = int(cx + math.cos(a) * rx * d); y = int(cy + math.sin(a) * ry * d)
        if onto(cv.get(x, y)): cv.put(x, y, P if k % 3 else Q); cv.put(x + 1, y, Q) if k % 4 == 0 and onto(cv.get(x + 1, y)) else None

def pebble(cv, x, y, rnd, s=1):
    S = r5(RAMP["stone"]); lump(cv, x, y, 3 * s, 2 * s, S, rnd, 0)

def leaflet(cv, x, y, col):   # a fallen leaf, 3 px
    cv.put(x, y, col[1]); cv.put(x + 1, y, col[1]); cv.put(x + 1, y - 1, col[0]); cv.put(x + 2, y - 1, col[2])

def acorn2(cv, x, y, s=1):   # hand-pixelled acorn: shaded nut, crosshatched cap, stem, 1 px glint
    N = RAMP["litter"]; C = RAMP["wood"]
    for yy in range(int(-2.4 * s), int(6.8 * s) + 1):
        for xx in range(-4 * s, 4 * s + 1):
            nx = xx / (3.9 * s); ny = (yy - 2 * s) / (4.6 * s)
            if nx * nx + ny * ny > 1: continue
            cv.put(x + xx, y + yy, N[min(3, dith(dome_s(nx * .9, ny * .9) * .85 + .1, x + xx, y + yy))])
    for yy in range(int(-5.4 * s), int(1.2 * s) + 1):
        for xx in range(int(-5 * s), int(5 * s) + 1):
            nx = xx / (4.9 * s); ny = (yy + 2 * s) / (3.4 * s)
            if nx * nx + ny * ny > 1: continue
            t = dith(dome_s(nx * .8, ny * .8) * .75 + .7, x + xx, y + yy)
            if (xx + yy) % 3 == 0 and t < 3: t += 1
            cv.put(x + xx, y + yy, C[min(3, t)])
    cv.put(x - s, y + 2 * s, RAMP["sand"][0]); cv.put(x - s, y + 3 * s, RAMP["sand"][1])
    for k in range(2 * s): cv.put(x, int(y - 5.4 * s) - k, C[2] if k % 2 == 0 else C[3])

# ----------------------------------------------------------------------------------- 304
def vine(cv, x, y, ln, rnd):
    M = RAMP["moss"]; Lf = RAMP["leaf"]; ph = rnd.uniform(0, 6)
    for k in range(ln):
        xx = x + int(round(1.6 * math.sin(k / 6 + ph))); cv.put(xx, y + k, M[2] if k % 3 else M[1])
        if k % 5 == 3 and k > 2:
            d = 1 if (k // 5) % 2 else -1
            cv.put(xx + d, y + k, Lf[1]); cv.put(xx + 2 * d, y + k, Lf[1]); cv.put(xx + 2 * d, y + k + 1, Lf[2]); cv.put(xx + d, y + k - 1, Lf[0])

def lm_oakarch(rnd, cv):   # 280 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"]); G = RAMP["gold"]
    cx0, cy0, A, B, ia, ib = 140, 236, 124, 208, 64, 122
    def rad(th, a, b): return 1 / math.sqrt((math.cos(th) / a) ** 2 + (math.sin(th) / b) ** 2)
    nr = 8; rg = [((i + rnd.uniform(.25, .75)) / nr, rnd.uniform(0, 6.3), rnd.randint(0, 60), rnd.randint(14, 34)) for i in range(nr)]
    for y in range(26, 238):
        for x in range(8, 274):
            ox = (x - cx0) / A; oy = (y - cy0) / B; ix = (x - cx0) / ia; iy = (y - cy0) / ib
            rn = math.hypot(ox, oy); ri = math.hypot(ix, iy)
            if rn > 1 or ri < 1: continue
            v = (1 - rn) / ((1 - rn) + (ri - 1) + 1e-9)
            gx, gy = ox / A, oy / B; gl = math.hypot(gx, gy) or 1; gx /= gl; gy /= gl
            e = (1 - 2 * v) * .95; s = dome_s(gx * e, gy * e)
            th = math.atan2(y - cy0, x - cx0); thick = rad(th, A, B) - rad(th, ia, ib)
            arc = th * (rad(th, A, B) + rad(th, ia, ib)) / 2
            fl = 0
            for vi, ph, off, seg in rg:
                vv = vi + .025 * math.sin(arc / 19 + ph) + .015 * math.sin(arc / 7 + ph * 2)
                if int((arc + off) // seg) % 4 == 0: continue
                dpx = (v - vv) * thick
                if abs(dpx) < .75: fl = 2
                elif -1.8 < dpx <= -.75 and not fl: fl = -1
                elif .75 <= dpx < 1.8 and not fl: fl = 1
            if fl == 2: s += 2.2
            elif fl == -1: s -= .8
            elif fl == 1: s += .6
            elif (x * 7 + y * 5) % 19 == 0: s -= .9
            elif (x * 3 + y * 13) % 23 == 0: s += .8
            if v > .93: s += .6
            cv.put(x, y, W[dith(s, x, y)])
    # roots spreading at both feet
    for sx in (1, -1):
        X = (lambda p: (cx0 + sx * (p - cx0))) 
        root(cv, ((X(26), 222), (X(12), 235), (X(1), 241)), 18, 4, W, rnd); root(cv, ((X(76), 222), (X(86), 236), (X(104), 243)), 16, 4, W, rnd)
        root(cv, ((X(44), 232), (X(40), 244), (X(30), 247)), 11, 3, W, rnd)
    isw = lambda c: c in W
    knot(cv, 34, 150, 5, 7, W, rnd); knot(cv, 252, 184, 4, 6, W, rnd); knot(cv, 100, 62, 4, 5, W, rnd); knot(cv, 196, 52, 5, 4, W, rnd)
    for (x, y, n) in ((24, 120, 30), (44, 150, 22), (250, 140, 34), (260, 180, 20), (90, 84, 14), (122, 44, 8), (176, 44, 10), (52, 90, 18)): crack(cv, x, y, n, W, rnd)
    lichen(cv, 24, 100, 9, 14, rnd, isw); lichen(cv, 258, 120, 7, 12, rnd, isw)
    for cx, cy, rx, ry in ((26, 176, 15, 13), (34, 214, 18, 10), (250, 168, 14, 12), (256, 206, 16, 10), (70, 92, 18, 9), (206, 80, 16, 9)): moss(cv, cx, cy, rx, ry, rnd, isw)
    shelf(cv, 6, 134, 14, 7, rnd) if False else None
    for x in (116, 128, 152, 164, 176, 94, 186):   # vines hanging from the lintel
        top_y = 236 - 122 * math.sqrt(max(0, 1 - ((x - 140) / 64) ** 2))
        vine(cv, x, int(top_y) + 1, rnd.randint(8, 22), rnd)
    # acorn lantern on a twisted cord
    for k in range(18): cv.put(140, 114 + k, RAMP["sand"][2] if k % 2 else RAMP["sand"][3]); cv.put(141, 114 + k, RAMP["sand"][1] if k % 2 else RAMP["sand"][2])
    for dx in (-1, 0, 1, 2): cv.put(140 + dx, 113, W[2])
    lx, ly = 140, 150
    for yy in range(ly - 7, ly + 13):   # glass nut, glowing from the middle
        for xx in range(lx - 10, lx + 11):
            nx = (xx - lx) / 9.2; ny = (yy - (ly + 3)) / 10.5
            if nx * nx + ny * ny > 1: continue
            g = math.hypot(nx * .9, ny * .8)
            cv.put(xx, yy, G[min(3, dith(g * 2.6 + (.25 if nx + ny > .3 else 0), xx, yy))])
    for yy in range(ly - 9, ly - 1):   # cap
        for xx in range(lx - 11, lx + 12):
            nx = (xx - lx) / 11; ny = (yy - (ly - 3)) / 7
            if nx * nx + ny * ny > 1: continue
            t = dith(dome_s(nx * .8, ny * .8) * .7 + .8, xx, yy)
            if (xx + yy) % 3 == 0 and t < 3: t += 1
            cv.put(xx, yy, W[min(4, t)])
    for xx in (lx - 6, lx, lx + 6):
        for yy in range(ly - 2, ly + 12):
            if cv.get(xx, yy) in G: cv.put(xx, yy, W[3] if xx != lx - 6 else W[2])
    cv.put(lx - 5, ly + 1, CREAM); cv.put(lx - 5, ly + 2, CREAM); cv.put(lx - 4, ly, G[0]); cv.put(lx, ly + 13, W[3]); cv.put(lx, ly + 14, W[4])
    for (fx, fy) in ((124, 160), (158, 144), (130, 134)): cv.put(fx, fy, G[0]); cv.put(fx + 1, fy, G[1])
    # canopy
    for cx, cy, rx, ry in ((140, 42, 74, 34), (76, 70, 54, 32), (204, 70, 54, 32), (140, 66, 62, 26), (36, 108, 30, 24), (244, 108, 30, 24), (100, 28, 30, 16), (186, 30, 26, 14), (20, 126, 14, 12), (260, 128, 14, 12)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 330)
    # welcome mat: woven, fringed
    S = RAMP["sand"]
    for y in range(243, 250):
        for x in range(108, 173):
            e = (x < 112 or x > 168 or y == 243 or y == 249)
            cv.put(x, y, S[3] if e else RAMP["ember"][2] if 134 < x < 146 and y in (245, 246, 247) else S[1] if (x + y) % 2 else S[2])
    for x in range(106, 175, 3): cv.put(x, 250, S[2]) if x < 109 or x > 171 else None
    for y in (244, 246, 248): cv.put(106, y, S[1]); cv.put(174, y, S[1])
    _mush(cv, 40, 246, rnd); _mush(cv, 50, 248, rnd, 1); _tuft(cv, 236, 246, rnd); _tuft(cv, 84, 247, rnd, 3); _tuft(cv, 196, 248, rnd, 3, 6)
    for x, y in ((60, 249), (224, 249), (100, 250)): leaflet(cv, x, y, RAMP["litter"])
    pebble(cv, 218, 248, rnd); pebble(cv, 72, 249, rnd)

def tone5(nx, ny):
    d = nx * -0.5 + ny * -0.6 + math.sqrt(max(0, 1 - nx * nx - ny * ny)) * .62
    return 0 if d > .7 else 1 if d > .4 else 2 if d > .05 else 3 if d > -.3 else 4

def _arch(cx, hw, spring, top, bottom, n=40):   # points along a doorway arch, left foot -> right foot
    pts = []
    for i in range(n + 1):
        t = i / n
        if t < .3: pts.append((cx - hw, bottom + (spring - bottom) * t / .3))
        elif t < .7:
            a = math.pi * (1 - (t - .3) / .4); pts.append((cx + math.cos(a) * hw, spring - math.sin(a) * (spring - top)))
        else: pts.append((cx + hw, spring + (bottom - spring) * (t - .7) / .3))
    return pts

def _inarch(x, y, cx, hw, spring, top, bottom):
    if y > bottom or y < top: return False
    if y >= spring: return abs(x - cx) <= hw
    return ((x - cx) / hw) ** 2 + ((spring - y) / (spring - top)) ** 2 <= 1

def lm_hollowtrunk(rnd, cv):   # 210 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"]); M = r5(RAMP["moss"])
    cxf = lambda y: 105 + 2 * math.sin(y / 29)
    def hw(y, sd):
        b = 44 + 2.5 * math.sin(y / 13 + 1 + sd) + max(0, y - 198) ** 1.7 / 52 * 1.1
        if sd < 0 and 108 < y < 142: b += 6 * math.sin(math.pi * (y - 108) / 34)    # knob on the left
        if sd > 0 and 168 < y < 196: b += 5 * math.sin(math.pi * (y - 168) / 28)    # swelling on the right
        return b
    span = lambda y: (int(cxf(y) - hw(y, -1)), int(cxf(y) + hw(y, 1)))
    bark(cv, span, 48, 249, W, rnd, nr=11)
    # ---- broken top: cut face ring, dark hollow, splinters
    ecx, ecy, erx, ery = 105, 50, 46, 11
    spk = [(64, 20, 1.1), (78, 9, 1.4), (95, 4, 1.5), (118, 24, 1.0), (131, 12, 1.4), (144, 22, 1.2), (112, 7, 1.4)]
    def spike(x):
        h = max([int(h - abs(x - px) * sl) for px, h, sl in spk] + [0])
        return h + ((x * 13) % 4 - 1 if h > 3 else 0)
    for x in range(ecx - erx, ecx + erx + 1):
        nx = (x - ecx) / erx; yb = ecy - ery * math.sqrt(max(0, 1 - nx * nx)); h = spike(x)
        for k in range(h + 1):
            yy = int(yb) - k; u = (x - (ecx - erx)) / (2 * erx)
            s = .6 + 2.4 * u + (.9 if (x * 5) % 7 == 0 else 0) - (.8 if k == h else 0)
            cv.put(x, yy, W[dith(s, x, yy)])
    for y in range(ecy - ery - 1, ecy + ery + 2):
        for x in range(ecx - erx - 1, ecx + erx + 2):
            nx = (x + .5 - ecx) / erx; ny = (y + .5 - ecy) / ery; d = math.hypot(nx, ny)
            if d > 1: continue
            ix = (x + .5 - ecx) / (erx - 10); iy = (y + .5 - ecy) / (ery - 4); di = math.hypot(ix, iy)
            if di < 1:   # the hollow: back wall above, darkness below
                t = (y - (ecy - ery + 4)) / (2 * (ery - 4)); s = 3.0 + 1.5 * t ** .6 + (.9 if (x * 5) % 7 == 0 else 0)
                cv.put(x, y, INK if t > .62 and (x + y) % 2 == 0 or t > .8 else W[min(4, dith(s, x, y))])
            else:   # cut face: pale wood with a ring, lip of bark
                dd = (d - (1 - 10 / erx) ** 0) if False else d
                if d > .93: s = 2.6 if ny > 0 else 1.9
                elif d > .84: s = 1.3 + (.8 if ny > 0 else 0)
                elif di < 1.12: s = 2.7
                else:
                    s = .1 + (nx + ny) * .35 + (1.5 if int(di * 9) % 4 == 0 else 0) + (.5 if (x + y) % 5 == 0 else 0)
                cv.put(x, y, W[dith(s, x, y)])
    crack(cv, 128, 52, 7, W, rnd); crack(cv, 76, 50, 5, W, rnd)
    # ---- doorway
    dcx, hwd, spr, dtop, dbot = 106, 30, 192, 150, 246
    inside = lambda x, y: _inarch(x, y, dcx, hwd, spr, dtop, dbot)
    outer = lambda x, y: _inarch(x, y, dcx, hwd + 9, spr, dtop - 9, dbot + 2)
    bcx, bhw, bspr, btop, bbot = 108, 17, 196, 176, 230
    back = lambda x, y: _inarch(x, y, bcx, bhw, bspr, btop, bbot)
    for y in range(dtop - 10, dbot + 3):
        for x in range(dcx - hwd - 10, dcx + hwd + 11):
            if inside(x, y):
                if back(x, y):   # far end: dark with a green glimpse
                    gx = (x - bcx) / 12; gy = (y - 206) / 15; g = math.hypot(gx, gy)
                    cv.put(x, y, M[min(4, dith(2.9 + g * 1.5, x, y))] if g < 1 and y > 200 else INK)
                elif y > bbot - 1: # floor in front of the back arch
                    t = (y - bbot) / (dbot - bbot); cv.put(x, y, W[dith(3.2 - 1.6 * (1 - t) + (.6 if (x // 3 + y) % 4 == 0 else 0), x, y)])
                elif x < bcx - bhw and y >= bspr - 4 or (x < bcx - bhw and y < bspr and not back(x, y) and (x - bcx) < -bhw * math.sqrt(max(0, 1 - ((bspr - y) / (bspr - btop)) ** 2))):
                    cv.put(x, y, W[4] if (x + y) % 3 else INK)   # left wall, in shade
                elif x > bcx + bhw or (y < bspr and (x - bcx) > bhw * math.sqrt(max(0, 1 - ((bspr - y) / (bspr - btop)) ** 2))):
                    cv.put(x, y, W[dith(3.1 + (x - bcx - bhw) * -.03 + (.9 if (y // 2 + x) % 4 == 0 else 0), x, y)])   # right wall catches the light
                else: cv.put(x, y, INK if (x + y) % 5 else W[4])   # ceiling
            elif outer(x, y):   # frame: dark lip all round the hole, then a swelling callus ring
                dy = (y - spr) if y < spr else 0; dx = (x - dcx)
                L = math.hypot(dx / hwd, dy / (spr - dtop)) if y < spr else abs(dx) / hwd
                ox = dx / hwd; oy = dy / (spr - dtop)
                n = math.hypot(ox, oy) or 1
                inl = (_inarch(x - 1, y, dcx, hwd, spr, dtop, dbot) + _inarch(x + 1, y, dcx, hwd, spr, dtop, dbot) +
                       _inarch(x, y - 1, dcx, hwd, spr, dtop, dbot) + _inarch(x, y + 1, dcx, hwd, spr, dtop, dbot))
                near = any(inside(x + a, y + b) for a in (-3, -2, -1, 0, 1, 2, 3) for b in (-3, -2, -1, 0, 1, 2, 3) if abs(a) + abs(b) <= 3)
                if near: s = dome_s(-ox / n * .9, -oy / n * .9) + .4   # lip faces the hole
                else: s = dome_s(ox / n * .7, oy / n * .7) * .8 - .2 + (1.2 if (x * 3 + y) % 6 == 0 else 0)
                cv.put(x, y, W[dith(s, x, y)])
    # perspective grain on the walls and ceiling
    P0 = _arch(dcx, hwd, spr, dtop, dbot, 28); P1 = _arch(bcx, bhw, bspr, btop, bbot, 28)
    for i in range(3, 26):
        if i % 2 or i in (13, 14, 15): continue
        (x0, y0), (x1, y1) = P0[i], P1[i]
        n = int(max(abs(x1 - x0), abs(y1 - y0)))
        for k in range(1, n):
            if (k // 3) % 3 == 2: continue
            px = int(x0 + (x1 - x0) * k / n); py = int(y0 + (y1 - y0) * k / n)
            if inside(px, py) and not back(px, py): cv.put(px, py, W[4] if i < 14 else W[2] if k % 2 else W[3])
    for x in range(dcx - hwd + 3, dcx + hwd - 2):   # a threshold step
        for k in range(3): cv.put(x, dbot - 1 + k, W[1 + k] if k < 2 else W[3]) if outer(x, dbot) or True else None
    # moss tufts on the floor, a fallen acorn
    for x in range(dcx - 24, dcx + 24, 2):
        yy = dbot - (2 if (x * 7) % 5 else 4)
        for k in range(3 + (x * 3) % 3): cv.put(x, yy - k, M[2 if k < 2 else 1 if k < 4 else 0])
    acorn2(cv, 96, 242, 1)
    # ---- spider web in the top-left corner, spider on its thread
    ax, ay = 84, 168; web = RAMP["stone"][0]
    def wp(x, y, c=web):
        if inside(x, y) and not back(x, y) or back(x, y) and inside(x, y): cv.put(x, y, c)
    for a in range(0, 90, 15):
        r = 36 + (a % 30)
        _line_clip = []
        n = r
        for k in range(1, n):
            wp(int(ax + math.cos(math.radians(a - 10)) * k), int(ay + math.sin(math.radians(a - 10)) * k + 1))
    for r in (7, 14, 21, 28):
        for a in range(-10, 82, 2):
            sag = math.sin(math.radians((a + 10) * 2)) * 2
            wp(int(ax + math.cos(math.radians(a)) * r), int(ay + math.sin(math.radians(a)) * r + sag + 1), CREAM if (a // 2) % 5 == 0 else web)
    for k in range(40): wp(116, 158 + k, RAMP["stone"][1])
    cx0, cy0 = 116, 202
    for d in (-1, 1):
        for k in range(4):
            _line(cv, cx0 + d * 3, cy0 - 1 + k, cx0 + d * (7 + k), cy0 - 4 + k * 3 + (k // 2), RAMP["dusk"][3])
    lump(cv, cx0, cy0, 4, 4, [CREAM, RAMP["dusk"][0], RAMP["dusk"][1], RAMP["dusk"][2], RAMP["dusk"][3]], rnd, 0)
    cv.put(cx0 - 1, cy0 - 1, CREAM); cv.put(cx0 + 1, cy0 - 1, CREAM); cv.put(cx0, cy0 + 1, RAMP["ember"][1])
    # ---- bark detail: knots, cracks, lichen, moss
    knot(cv, 68, 112, 6, 9, W, rnd); knot(cv, 138, 212, 4, 6, W, rnd); knot(cv, 142, 90, 3, 4, W, rnd)
    crack(cv, 74, 128, 44, W, rnd); crack(cv, 136, 66, 36, W, rnd); crack(cv, 72, 58, 18, W, rnd)
    for yy in (84, 128, 170): crack(cv, 128 + (yy % 7), yy, 6, W, rnd, False)
    isw = lambda c: c in W
    lichen(cv, 82, 90, 9, 12, rnd, isw); lichen(cv, 134, 160, 6, 8, rnd, isw); lichen(cv, 150, 70, 4, 7, rnd, isw)
    moss(cv, 70, 128, 14, 10, rnd, isw); moss(cv, 144, 100, 10, 12, rnd, isw); moss(cv, 60, 222, 18, 12, rnd, isw); moss(cv, 152, 232, 18, 10, rnd, isw)
    # ---- roots
    root(cv, ((58, 214), (44, 236), (14, 243)), 20, 5, W, rnd); root(cv, ((152, 214), (166, 236), (198, 244)), 20, 5, W, rnd)
    root(cv, ((68, 232), (56, 246), (32, 248)), 12, 3, W, rnd); root(cv, ((144, 232), (156, 246), (178, 248)), 12, 3, W, rnd)
    # ---- fungus shelves
    shelf(cv, 147, 142, 22, 12, rnd); shelf(cv, 149, 122, 15, 8, rnd); shelf(cv, 49, 188, 1, 1, rnd) if False else None
    # ---- the little green crown sprouting from the break
    for cx, cy, rx, ry in ((88, 38, 12, 8), (160, 50, 16, 10), (50, 54, 12, 8)): lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 36)
    for x, y in ((180, 244), (24, 247)): _mush(cv, x, y, rnd)
    _tuft(cv, 186, 247, rnd, 4, 9); _tuft(cv, 28, 248, rnd, 3, 7)
    for x, y in ((40, 249), (160, 249), (178, 249)): leaflet(cv, x, y, RAMP["litter"])
    pebble(cv, 176, 247, rnd)

def lm_acorndrop(rnd, cv):   # 210 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"])
    cxf = lambda y: 100 + 3 * math.sin(y / 33)
    def hw(y, sd): return 13 + 1.3 * math.sin(y / 11 + sd) + max(0, y - 214) ** 1.6 / 12
    span = lambda y: (int(cxf(y) - hw(y, 0)), int(cxf(y) + hw(y, 1)))
    root(cv, ((98, 140), (78, 118), (58, 98)), 14, 7, W, rnd); root(cv, ((104, 138), (130, 114), (152, 94)), 14, 7, W, rnd)
    root(cv, ((100, 130), (100, 108), (100, 84)), 14, 8, W, rnd)
    bark(cv, span, 118, 249, W, rnd, nr=5, wob=.07)
    isw = lambda c: c in W
    knot(cv, 94, 170, 4, 6, W, rnd); knot(cv, 108, 206, 3, 4, W, rnd)
    for (x, y, n) in ((95, 128, 30), (108, 150, 26), (92, 198, 22), (106, 174, 12)): crack(cv, x, y, n, W, rnd)
    moss(cv, 92, 180, 9, 14, rnd, isw); moss(cv, 106, 222, 9, 8, rnd, isw); lichen(cv, 106, 150, 4, 8, rnd, isw)
    root(cv, ((92, 232), (70, 246), (46, 248)), 14, 3, W, rnd); root(cv, ((110, 232), (134, 246), (160, 248)), 14, 3, W, rnd)
    root(cv, ((98, 240), (92, 249), (84, 250)), 8, 3, W, rnd)
    for cx, cy, rx, ry in ((100, 62, 70, 40), (46, 88, 40, 28), (156, 88, 40, 28), (100, 98, 58, 26), (70, 40, 34, 22), (136, 44, 34, 22), (28, 100, 18, 12), (176, 102, 18, 12)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 320)
    for x, y in ((50, 100), (80, 112), (120, 108), (150, 98), (100, 84), (66, 70), (134, 68), (24, 108), (176, 110)):   # still hanging, on tiny stems
        for k in range(3): cv.put(x, y - 7 - k, RAMP["leaf"][2])
        acorn2(cv, x, y, 1)
    for x, y in ((62, 136), (96, 160), (126, 144), (82, 190), (134, 186), (112, 214), (150, 160), (40, 176), (170, 200)):   # falling, with speed marks
        acorn2(cv, x, y, 1)
        for k in range(3): cv.put(x - 1, y - 11 - k * 4, RAMP["litter"][0]); cv.put(x, y - 11 - k * 4, RAMP["litter"][1]); cv.put(x, y - 12 - k * 4, RAMP["sand"][0]) if k == 0 else None
    # the heap, back to front
    pile = sorted(((100 + int(rnd.gauss(0, 24)), 0) for _ in range(30)), key=lambda p: -abs(p[0] - 100))
    for x, _ in pile:
        y = 245 - rnd.randint(0, 3) - max(0, 14 - abs(x - 100) // 2) + rnd.randint(-2, 2)
        acorn2(cv, x, y, 1)
    for x in range(40, 170, 4): leaflet(cv, x + rnd.randint(0, 2), 248 + rnd.randint(0, 1), RAMP["litter"])
    _hat(cv, 156, 247, rnd)
    for k in range(5): cv.put(30 + k * 8, 248, RAMP["moss"][1]); cv.put(31 + k * 8, 247, RAMP["moss"][0])
    _tuft(cv, 178, 249, rnd, 3, 7); _mush(cv, 24, 247, rnd)

def lm_owloak(rnd, cv):   # 240 x 290
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"]); M = r5(RAMP["moss"])
    OW = [H(c) for c in ("#ead2a4", "#cfa670", "#a47a4c", "#6e4e36", "#3f2c28")]
    cxf = lambda y: 120 + 6 * math.sin(y / 38)
    def hw(y, sd): return 51 + 4 * math.sin(y / 23 + sd) + max(0, y - 232) ** 1.65 / 20 + (4 if sd > 0 and 190 < y < 214 else 0) * math.sin(math.pi * (y - 190) / 24 if 190 < y < 214 else 0)
    span = lambda y: (int(cxf(y) - hw(y, 0)), int(cxf(y) + hw(y, 1)))
    # side bough stump, behind the trunk edge
    root(cv, ((86, 184), (62, 166), (42, 140)), 26, 16, W, rnd)
    for yy in range(126, 146):
        for xx in range(28, 58):
            nx = (xx - 43) / 15; ny = (yy - 135) / 8
            if nx * nx + ny * ny <= 1:
                d = math.hypot(nx, ny); cv.put(xx, yy, W[dith(.2 + (nx + ny) * .4 + (1.5 if int(d * 5) % 2 == 0 and d > .2 else 0) + (1.4 if d > .88 else 0), xx, yy)])
    bark(cv, span, 80, 289, W, rnd, nr=15, wob=.06)
    # ---- the hole: bark lip, owl inside
    hx, hy, hrx, hry = 122, 148, 29, 33
    def hole_in(x, y): return ((x + .5 - hx) / hrx) ** 2 + ((y + .5 - hy) / hry) ** 2 <= 1
    for y in range(hy - hry - 10, hy + hry + 11):
        for x in range(hx - hrx - 10, hx + hrx + 11):
            nx = (x + .5 - hx) / hrx; ny = (y + .5 - hy) / hry; d = math.hypot(nx, ny)
            ang = math.atan2(ny, nx); d_adj = d * (1 + .035 * math.sin(ang * 6 + 1))
            if d_adj < 1: cv.put(x, y, INK)
            elif d_adj < 1.17: cv.put(x, y, W[dith(dome_s(-nx * .9, -ny * .9) + .5, x, y)])
            elif d_adj < 1.36: cv.put(x, y, W[dith(dome_s(nx * .8, ny * .8) * .75 + (1.2 if (x + 2 * y) % 5 == 0 else 0), x, y)])
    # the owl: round head, feather scallops, tufts, heavy sleepy lids
    def owl_s(x, y, cx, cy, rx, ry):
        nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
        if nx * nx + ny * ny > 1: return None
        s = dome_s(nx * .85, ny * .85) * .9 + .5
        row = y // 3
        if y % 3 == 2 and (x + (row % 2) * 2) % 4 in (0, 1): s += 1.3
        elif y % 3 == 0 and (x + (row % 2) * 2) % 4 == 2: s -= .7
        return s
    for y in range(hy - hry, hy + hry + 1):   # chest and body first
        for x in range(hx - hrx, hx + hrx + 1):
            if not hole_in(x, y): continue
            s = owl_s(x, y, hx, hy + 30, 26, 22)
            if s is not None: cv.put(x, y, OW[min(4, dith(s - .3, x, y))])
    for y in range(hy - hry, hy + hry + 1):
        for x in range(hx - hrx, hx + hrx + 1):
            if not hole_in(x, y): continue
            s = owl_s(x, y, hx, hy + 2, 25, 22)
            if s is None: continue
            for ex in (hx - 12, hx + 12):   # facial discs
                dd = math.hypot((x - ex) / 12.5, (y - (hy + 3)) / 12)
                if dd < 1: s = s - 1.3 if dd < .86 else s + 1.2
            cv.put(x, y, OW[min(4, dith(s, x, y))])
    for sd in (-1, 1):   # ear tufts and brows
        for k in range(12):
            for w in range(max(1, 5 - k // 2)):
                xx = hx + sd * (15 + k // 2 + w - 2) + 0; yy = hy - 22 - k
                if hole_in(xx, yy): cv.put(xx, yy, OW[1 if (w == 0) == (sd < 0) else 3])
        for k in range(14):
            xx = hx + sd * (3 + k); yy = hy - 7 - k // 2
            for t in range(2):
                if hole_in(xx, yy + t): cv.put(xx, yy + t, OW[4] if t else OW[3])
    for sd in (-1, 1):   # sleepy eyes: lid, lash line, slit of iris
        ex, ey = hx + sd * 12, hy + 2
        for y in range(ey - 6, ey + 6):
            for x in range(ex - 8, ex + 9):
                nx = (x - ex) / 8; ny = (y - ey) / 6
                if nx * nx + ny * ny > 1: continue
                if y < ey - 1 + (abs(x - ex) // 4) * (1 if sd else 0): cv.put(x, y, OW[2] if (x + y) % 2 else OW[3])    # heavy lid
                elif y == ey - 1 + (abs(x - ex) // 4): cv.put(x, y, INK)
                else:
                    cv.put(x, y, CREAM if abs(x - ex) > 3 or y > ey + 3 else RAMP["gold"][1] if abs(x - ex) > 1 else INK)
        cv.put(ex - sd * 8, ey + 1, INK); cv.put(ex - sd * 9, ey + 2, INK); cv.put(ex - 1, ey + 1, CREAM if False else cv.get(ex - 1, ey + 1))
    for k, (w, c) in enumerate(((5, RAMP["gold"][0]), (4, RAMP["gold"][1]), (3, RAMP["gold"][1]), (2, RAMP["gold"][2]), (1, RAMP["gold"][3]))):   # beak
        for dx in range(-(w // 2), w // 2 + (w % 2)): cv.put(hx + dx, hy + 6 + k, c if dx > -(w // 2) or w == 1 else RAMP["gold"][0])
    for sx in (hx - 10, hx + 8):   # claws gripping the sill
        for t in range(3):
            for k in range(4): cv.put(sx + t * 3, hy + 30 + k, RAMP["sand"][1 if t != 1 else 0]); cv.put(sx + t * 3, hy + 34, OW[3])
    moss(cv, hx, hy + 34, 20, 4, rnd, lambda c: c in W, drip=False)
    # ---- bark detail: knots, cracks, lichen, moss, fungus
    for (kx, ky, rx, ry) in ((92, 222, 8, 12), (146, 198, 6, 9), (84, 110, 5, 7), (166, 120, 4, 5), (96, 262, 5, 7)): knot(cv, kx, ky, rx, ry, W, rnd)
    for (x, y, n) in ((74, 104, 40), (170, 128, 46), (84, 150, 26), (160, 210, 40), (104, 244, 30), (136, 238, 26), (188, 190, 20), (72, 188, 24)): crack(cv, x, y, n, W, rnd)
    for yy in (180, 212, 236): crack(cv, 150 + (yy % 9), yy, 8, W, rnd, False); crack(cv, 90 + (yy % 7), yy + 9, 6, W, rnd, False)
    isw = lambda c: c in W
    lichen(cv, 84, 170, 10, 16, rnd, isw); lichen(cv, 172, 160, 8, 10, rnd, isw); lichen(cv, 108, 100, 8, 8, rnd, isw)
    for cx, cy, rx, ry in ((72, 238, 16, 16), (172, 246, 14, 12), (80, 124, 12, 9), (156, 98, 10, 8)): moss(cv, cx, cy, rx, ry, rnd, isw)
    # ---- roots
    root(cv, ((74, 238), (40, 262), (4, 284)), 34, 6, W, rnd); root(cv, ((170, 238), (206, 262), (238, 284)), 34, 6, W, rnd)
    root(cv, ((88, 262), (70, 280), (50, 288)), 18, 4, W, rnd); root(cv, ((152, 262), (170, 280), (190, 288)), 18, 4, W, rnd)
    root(cv, ((112, 274), (106, 286), (96, 289)), 10, 3, W, rnd)
    shelf(cv, 172, 224, 24, 11, rnd); shelf(cv, 174, 206, 16, 8, rnd)
    # ---- canopy
    for cx, cy, rx, ry in ((120, 54, 88, 46), (52, 92, 46, 32), (190, 86, 50, 34), (120, 96, 66, 26), (176, 50, 40, 28), (68, 52, 34, 24), (210, 108, 26, 18)): lump(cv, cx, cy, rx, ry, R, rnd)
    lump(cv, 44, 136, 22, 14, R, rnd)
    leaf_texture(cv, R, rnd, 400)
    for zx, zy, zs in ((158, 120, 6), (170, 104, 8), (184, 84, 10)):   # z z z
        for k in range(zs + 1):
            cv.put(zx + k, zy, CREAM); cv.put(zx + zs - k, zy + k, CREAM); cv.put(zx + k, zy + zs, CREAM)
            if k < zs: cv.put(zx + k, zy + 1, RAMP["sand"][1]); cv.put(zx + zs - k, zy + k + 1, RAMP["sand"][1]) if k < zs - 1 else None
    _tuft(cv, 206, 287, rnd, 5, 12); _mush(cv, 30, 287, rnd); _mush(cv, 42, 288, rnd); _tuft(cv, 18, 289, rnd, 3, 6)
    for x, y in ((120, 289), (70, 290), (150, 290)): leaflet(cv, x, y, RAMP["litter"])
    pebble(cv, 222, 289, rnd)

# ----------------------------------------------------------------------------------- 305
def lm_birchtunnel(rnd, cv):   # 290 x 230
    R = r5(RAMP["leaf"]); P = r5(RAMP["pine"])
    for y in range(54, 226):   # the dark way through
        for x in range(76, 216):
            e = abs(x - 146) / 70; t = 4 if e > .55 or y < 100 else 3
            cv.put(x, y, P[t])
    for y in range(110, 226):   # light at the end
        hw = int(26 * math.sqrt(max(0, 1 - ((y - 190) / 80) ** 2)))
        for x in range(146 - hw, 146 + hw + 1): cv.put(x, y, R[0] if abs(x - 146) < hw * .5 else R[1] if y < 200 else R[2])
    def tr(x0, x1, ytop, w, flip):
        cxf = lambda y: x0 + (x1 - x0) * (226 - y) / (226 - ytop)
        _bole(cv, cxf, lambda y: w, ytop, 226, BIRCH5, rnd, bark=False)
        for y in range(ytop + 6, 224, 11):   # black chevron marks
            c = int(cxf(y))
            for x in range(c - w + 2, c + w - 3):
                if rnd.random() < .8: cv.put(x, y, BIRCH[3]); cv.put(x, y + 1, BIRCH[3]) if (x + y) % 3 else None
            for k in range(rnd.randint(3, 5)): cv.put(c - w + rnd.randint(3, 2 * w - 4), y + 3 + rnd.randint(0, 3), BIRCH[3])
    for x0, x1, yt in ((28, 44, 66), (62, 80, 58), (96, 126, 66)): tr(x0, x1, yt, 11, 0)
    for x0, x1, yt in ((262, 246, 66), (228, 210, 58), (194, 166, 66)): tr(x0, x1, yt, 11, 1)
    for cx, cy, rx, ry in ((60, 52, 50, 30), (146, 38, 80, 34), (230, 52, 50, 30), (146, 70, 62, 24), (110, 52, 40, 26), (182, 52, 40, 26), (26, 84, 22, 22), (264, 84, 22, 22)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 280)
    for x in range(126, 168, 7): _tuft(cv, x, 226, rnd, 2, 5)
    _mush(cv, 18, 226, rnd); _tuft(cv, 270, 227, rnd, 3, 8)

def lm_birchcurtain(rnd, cv):   # 280 x 220
    R = r5(RAMP["leaf"]); M = r5(RAMP["moss"])
    xs = [24 + i * 29 for i in range(9)]
    for i, x in enumerate(xs):
        yt = 50 + (i * 17) % 23
        _bole(cv, lambda y, x=x: x + int(2 * math.sin(y / 30 + x)), lambda y: 9, yt, 216, BIRCH5, rnd, bark=False)
        for y in range(yt + 8, 214, 13):
            for xx in range(x - 6, x + 5):
                if rnd.random() < .7: cv.put(xx, y, BIRCH[3])
            cv.put(x + rnd.randint(-5, 3), y + 5, BIRCH[3]); cv.put(x + rnd.randint(-5, 3), y + 6, BIRCH[2])
    for i, x in enumerate(xs):
        yt = 50 + (i * 17) % 23
        lump(cv, x, yt - 6, 26, 18, R, rnd, .1)
    for i, x in enumerate(xs):   # hanging curtain strands
        for k in range(-2, 3):
            xx = x + k * 5 + 1; L = 70 + rnd.randint(0, 50) + (20 if k == 0 else 0)
            for y in range(52, 52 + L):
                cv.put(xx, y, M[1 + (y // 7 + k) % 2] if y < 52 + L - 6 else M[0]); cv.put(xx + 1, y, M[2]) if y % 5 else None
    leaf_texture(cv, R, rnd, 160)
    for i in (2, 6):   # two trunks who have forgotten why they came
        x = xs[i] + 1
        for ex in (x - 5, x + 2):
            _rect(cv, ex, 140, ex + 4, 147, CREAM); _rect(cv, ex + 1, 142, ex + 3, 146, INK)
        _disc(cv, x, 158, 3, INK, 4); _disc(cv, x, 158, 1, RAMP["petal"][1], 2)
    for i in (2, 6, 4):   # boots at the foot, in a crowd
        for d in (-4, 6): _rect(cv, xs[i] + d - 2, 211, xs[i] + d + 4, 216, RAMP["wood"][2]); _rect(cv, xs[i] + d - 2, 215, xs[i] + d + 5, 217, RAMP["wood"][3])
    _hat(cv, xs[5], 62, rnd)
    for x in range(8, 274, 11): _tuft(cv, x, 218, rnd, 2, 5)

def lm_fernhollow(rnd, cv):   # 270 x 130
    M = r5(RAMP["moss"]); L = r5(RAMP["leaf"])
    cx, cy, rx, ry = 135, 92, 128, 34
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            nx = (x - cx) / rx; ny = (y - cy) / ry
            if nx * nx + ny * ny > 1: continue
            d = nx * nx + ny * ny; t = 4 if d > .82 else 3 if d > .55 else 2 if d > .3 else 1
            if ny > .3 and d < .5: t = 0 if ny > .55 else 1   # light cups the lower side
            if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, M[t])
    lump(cv, 150, 92, 52, 18, [M[0], M[0], M[1], M[1], M[2]], rnd, .05)   # the pillow
    def frond(x, y, ang, ln, bend, R):
        pts = []
        for k in range(ln):
            a = ang + bend * k / ln
            x += math.cos(math.radians(a)); y -= math.sin(math.radians(a)); pts.append((x, y, a))
        for k, (px, py, a) in enumerate(pts):
            cv.put(int(px), int(py), R[3]); cv.put(int(px) + 1, int(py), R[2])
            if k % 3 == 0 and k > 3:
                ll = int((ln - k) * .42) + 2
                for s in (-1, 1):
                    for j in range(ll):
                        ax = int(px + s * j * math.cos(math.radians(a - 80 * s + 90 * 0)) * .9 + s * j); ay = int(py - j * .35 - (j * j) * .02)
                        c = R[0] if j < 2 else R[1] if s < 0 else R[2]
                        cv.put(ax, ay, c); cv.put(ax, ay + 1, R[2] if s < 0 else R[3])
    for x, y, a, ln, b in ((28, 100, 120, 56, 50), (42, 106, 100, 70, 40), (236, 104, 60, 60, -50), (250, 98, 75, 54, -40), (70, 112, 110, 48, 40),
                           (206, 114, 70, 50, -40), (112, 76, 95, 44, 55), (190, 74, 85, 48, -55), (148, 70, 90, 40, 0), (16, 94, 130, 46, 60)):
        frond(x, y, a, ln, b, M)
    # snail
    lump(cv, 150, 100, 26, 7, r5(RAMP["sand"]), rnd, 0)
    lump(cv, 132, 92, 8, 9, r5(RAMP["sand"]), rnd, 0)   # head
    lump(cv, 156, 80, 18, 18, r5(RAMP["petal"]), rnd, 0)   # shell
    for a in range(0, 540, 12):
        r = 2 + a / 540 * 13; cv.put(156 + int(r * math.cos(math.radians(a))), 80 + int(r * math.sin(math.radians(a))), RAMP["petal"][3])
    for ex in (128, 134): _line(cv, ex, 86, ex - 2 + (ex - 128) // 2 * 3, 72, RAMP["sand"][2]); _disc(cv, ex - 2 + (ex - 128) // 2 * 3, 71, 2, CREAM); cv.put(ex - 2 + (ex - 128) // 2 * 3, 71, INK)
    for x in range(124, 176): cv.put(x, 108, M[0]) if x % 4 else None
    _tuft(cv, 14, 118, rnd, 3, 6); _tuft(cv, 258, 118, rnd, 3, 6)

def lm_sunclearing(rnd, cv):   # 250 x 170
    M = r5(RAMP["moss"]); S = RAMP["sand"]; G = RAMP["gold"]
    cx, cy, rx, ry = 125, 124, 120, 34
    for y in range(cy - ry, cy + ry + 1):   # grass disc
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 > 1: continue
            t = 2 if y < cy else 3 if y < cy + ry // 2 else 4
            if rnd.random() < .1: t = max(0, t - 1)
            cv.put(x, y, M[t])
    for y in range(104, 142):   # the square of sun, in perspective
        f = (y - 104) / 38; x0 = int(52 - f * 26); x1 = int(186 + f * 26)
        for x in range(x0, x1):
            e = min(x - x0, x1 - x, y - 104, 141 - y)
            t = G[0] if e > 5 else S[0]
            if e > 5 and (x + y) % 11 == 0: t = CREAM
            cv.put(x, y, t)
    for x in range(30, 220, 4): cv.put(x, 126 + (x % 7), S[0]) if cv.get(x, 126 + (x % 7)) == M[2] else None
    # rabbit, in the sun
    L = r5(RAMP["litter"]); W = r5(RAMP["sand"])
    lump(cv, 98, 124, 11, 9, r5([CREAM, CREAM, S[1], S[2], S[3]] and [CREAM, CREAM, H("#f4e6c0"), S[1], S[2]]), rnd, 0)   # tail
    lump(cv, 126, 110, 30, 30, L, rnd, .05)   # body
    lump(cv, 136, 118, 15, 18, [CREAM, CREAM, H("#f4e6c0"), S[1], S[1]], rnd, 0)   # belly
    lump(cv, 112, 134, 18, 8, L, rnd, 0); lump(cv, 150, 134, 14, 7, L, rnd, 0)   # feet
    lump(cv, 144, 68, 22, 20, L, rnd, .05)   # head
    for ex, ey, tilt in ((138, 26, -1), (156, 28, 1)):
        for k in range(-6, 7):
            for y in range(ey - 8, ey + 38):
                w = 7 - abs(y - (ey + 12)) // 5
                if abs(k) <= max(2, w): cv.put(ex + k + (y - ey) // 10 * tilt, y, L[0 if k < -2 else 1 if k < 2 else 2])
        for y in range(ey + 2, ey + 28): cv.put(ex + (y - ey) // 10 * tilt, y, RAMP["petal"][0])
    for ex in (150, 160): _disc(cv, ex, 66, 3, INK); cv.put(ex - 1, 65, CREAM)
    cv.put(166, 74, RAMP["petal"][2]); cv.put(167, 74, RAMP["petal"][2]); cv.put(166, 75, RAMP["petal"][2])
    for k in range(5): cv.put(158 + k, 78 + k // 2, L[0]); cv.put(158 + k, 82 - k // 2, L[0])
    for i in range(7):   # buttercups
        x, y = 14 + i * 36 + rnd.randint(-5, 5), 120 + rnd.randint(-4, 24)
        if 50 < x < 190 and 100 < y < 142: continue
        for dx, dy in ((0, 0), (-2, 0), (2, 0), (0, -2), (0, 2)): cv.put(x + dx, y + dy, CREAM if dx or dy else G[1])
    for x in (12, 40, 210, 236): _tuft(cv, x, 150 + (x % 3), rnd, 3, 7)

# ----------------------------------------------------------------------------------- 306
def _fern(cv, x, y, rnd, s=1.0):
    G = r5(RAMP["pine"])
    for ang in (-62, -38, -14, 12, 38, 64):
        a = math.radians(ang + rnd.randint(-5, 5)); L = int((20 + rnd.randint(0, 8)) * s)
        for k in range(L):
            px = x + math.sin(a) * k; py = y - math.cos(a) * k + k * k * .02 * (1 if abs(ang) > 30 else .5)
            t = 3 if k < L * .3 else 2 if k < L * .62 else 1 if k < L * .9 else 0
            cv.put(int(px), int(py), G[t])
            if k % 3 == 1 and k > 3:
                for sd in (-1, 1): cv.put(int(px) + sd * 2, int(py) + 1, G[min(4, t + 1)]); cv.put(int(px) + sd * 3, int(py) + 2, G[t])

def lm_mosslog(rnd, cv):   # 340 x 150
    W = r5(RAMP["wood"]); M = r5(RAMP["moss"]); S = r5(RAMP["stone"]); SD = r5(RAMP["sand"]); G = r5(RAMP["leaf"])
    cy, hh = 98, 40
    for cx, r in ((20, 16), (322, 14)): lump(cv, cx, 138, r, 10, S, rnd, .1)
    top = lambda x: cy - hh + int(4 * math.sin(x / 37.0)) - (x > 296) * ((x - 296) // 3)
    bot = lambda x: cy + hh - (4 if x > 290 else 0)
    for x in range(44, 314):
        y0 = top(x); y1 = bot(x)
        for y in range(y0, y1):
            u = (y - y0) / (y1 - y0); t = 0 if u < .1 else 1 if u < .28 else 2 if u < .55 else 3 if u < .82 else 4
            if (y * 13 + (x // 6) * 7) % 11 == 0: t = min(4, t + 1)
            elif rnd.random() < .03: t = max(0, t - 1)
            cv.put(x, y, W[t])
    # cut end with rings and a hollow
    for y in range(cy - hh, cy + hh + 1):
        for x in range(22, 70):
            nx = (x - 46) / 23; ny = (y - cy) / hh
            if nx * nx + ny * ny > 1: continue
            r = math.hypot(nx, ny)
            cv.put(x, y, W[3] if r > .93 else SD[1 if int(r * 9) % 2 else 0] if r > .1 else SD[2])
    for y in range(cy - 14, cy + 30):
        for x in range(33, 62):
            nx = (x - 47) / 14; ny = (y - (cy + 8)) / 22
            if nx * nx + ny * ny <= 1: cv.put(x, y, INK if ny < .6 else RAMP["litter"][1])
    for ex in (42, 50): cv.put(ex, cy + 6, CREAM); cv.put(ex, cy + 7, CREAM)   # someone lives here
    _mush(cv, 40, cy + 29, rnd, 1)
    for x in range(260, 314):   # the far end snaps off into splinters
        if (x * 7) % 5 < 2:
            for y in range(top(x) - 5, top(x) + 1): cv.put(x, y, W[1 + (x % 2)])
    for x0 in range(70, 300, 20):   # moss fur on top
        lump(cv, x0 + rnd.randint(-3, 3), top(x0) + 3, 15 + rnd.randint(0, 6), 9 + rnd.randint(0, 5), M, rnd, .12)
    for x in range(72, 304, 3):   # moss drips down the side
        if (x * 7) % 5 < 3:
            for y in range(top(x) + 10, top(x) + 10 + 5 + (x * 3) % 13): cv.put(x, y, M[2 + (y % 2)])
    for cx, cyy, rx, ry in ((130, 122, 22, 10), (230, 126, 26, 9), (78, 130, 14, 7)): lump(cv, cx, cyy, rx, ry, M, rnd, .12)
    for bx, by, bw in ((150, 106, 14), (160, 120, 11), (250, 112, 13)):   # bracket fungi shelves
        lump(cv, bx, by, bw, 4, SD, rnd, 0); lump(cv, bx, by - 2, bw - 2, 3, r5(RAMP["ember"]), rnd, 0)
    for mx, s in ((110, 1), (122, 1), (176, 2), (214, 1), (270, 1)): _mush(cv, mx, top(mx) + 5, rnd, s)
    for k in range(26): cv.put(201, top(201) - k, W[2 + (k % 2)]); cv.put(202, top(201) - k, W[3])   # a sapling
    for lx, ly, rx, ry in ((194, top(201) - 26, 9, 6), (209, top(201) - 22, 8, 5), (201, top(201) - 34, 7, 6)): lump(cv, lx, ly, rx, ry, G, rnd, .1)
    _fern(cv, 98, 144, rnd, .9); _fern(cv, 252, 146, rnd, 1.0); _fern(cv, 300, 144, rnd, .7)
    for x in range(60, 290, 18): cv.put(x, 146, RAMP["sea"][0]); cv.put(x + 1, 147 - 1, CREAM)

def lm_dripgrotto(rnd, cv):   # 250 x 240
    S = r5(RAMP["stone"]); M = r5(RAMP["moss"]); SEA = RAMP["sea"]; WD = RAMP["wood"]
    E = ((125, 170, 118, 66), (44, 184, 48, 48), (206, 184, 48, 48), (125, 110, 74, 58), (80, 142, 52, 42), (172, 142, 52, 42),
         (92, 76, 36, 24), (164, 82, 32, 22), (24, 208, 26, 22), (228, 210, 26, 22), (125, 62, 30, 16))
    ph = [rnd.uniform(0, 6.3) for _ in range(4)]
    def pick(x, y):
        best, bi = -9, None
        for i, (cx, cy, rx, ry) in enumerate(E):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry; r2 = nx * nx + ny * ny
            a = math.atan2(ny, nx); r2 *= (1 + .05 * math.sin(a * 7 + ph[i % 4]) + .03 * math.sin(a * 13 + ph[(i + 1) % 4])) ** 2
            if r2 < 1 and 1 - r2 > best: best, bi = 1 - r2, (nx, ny)
        return bi
    seeds = {}
    for gy in range(-1, 14):
        for gx in range(-1, 14):
            seeds[(gx, gy)] = (gx * 21 + rnd.uniform(2, 19), gy * 21 + rnd.uniform(2, 19), rnd.uniform(-.8, .8), rnd.uniform(-.04, .04), rnd.uniform(-.04, .04), rnd.random())
    for y in range(40, 238):
        for x in range(0, 250):
            n = pick(x, y)
            if n is None: continue
            gx, gy = int(x // 21), int(y // 21); cand = []
            for a in (-1, 0, 1):
                for b in (-1, 0, 1):
                    sd = seeds[(gx + a, gy + b)]; cand.append((math.hypot(x - sd[0], y - sd[1]), sd))
            cand.sort(key=lambda t: t[0]); (d1, s1), (d2, s2) = cand[0], cand[1]
            s = dome_s(n[0] * .85, n[1] * .85) * .8 + .5 + s1[2] + s1[3] * (x - s1[0]) + s1[4] * (y - s1[1])
            yy = y + .13 * x + 3 * math.sin(x / 23)
            band = int(yy) // 11
            if int(yy) % 11 == 0 and (x // 10 + band) % 3: s += 1.4
            elif int(yy) % 11 == 10 and (x // 10 + band) % 3: s -= .7
            if d2 - d1 < 1.3:
                s += -1.0 if (s2[0] - s1[0]) + (s2[1] - s1[1]) > 0 else 1.9
            elif (x * 7 + y * 3) % 17 == 0: s += .8
            elif (x * 5 + y * 13) % 29 == 0: s -= .9
            c = S[dith(s, x, y)]
            if (band % 4 == 1) or s1[5] > .72: c = mix(c, WD[1], .16)
            cv.put(x, y, c)
    # ---- cave mouth with depth
    dcx, hwd, spr, dtop, dbot = 125, 37, 178, 136, 236
    inside = lambda x, y: _inarch(x, y, dcx, hwd, spr, dtop, dbot)
    outer = lambda x, y: _inarch(x, y, dcx, hwd + 8, spr, dtop - 8, dbot + 1)
    bcx, bhw, bspr, btop, bbot = 127, 20, 190, 164, 226
    back = lambda x, y: _inarch(x, y, bcx, bhw, bspr, btop, bbot)
    for y in range(dtop - 9, dbot + 2):
        for x in range(dcx - hwd - 9, dcx + hwd + 10):
            if inside(x, y):
                if back(x, y): cv.put(x, y, INK)
                elif y > bbot: cv.put(x, y, S[4] if (x + y) % 2 else INK)
                elif x < bcx - bhw: cv.put(x, y, S[4] if (x + y) % 2 or (x // 3) % 2 else INK)
                elif x > bcx + bhw: cv.put(x, y, S[dith(3.4 - .03 * (x - bcx - bhw) + (.6 if (x // 2 + y) % 4 == 0 else 0), x, y)])
                else: cv.put(x, y, INK if (x + y) % 2 else S[4])
            elif outer(x, y) and cv.get(x, y)[3]:
                dy = (y - spr) if y < spr else 0; ox = (x - dcx) / hwd; oy = dy / (spr - dtop); n = math.hypot(ox, oy) or 1
                near = any(inside(x + a, y + b) for a in range(-3, 4) for b in range(-3, 4) if abs(a) + abs(b) <= 3)
                s = dome_s(-ox / n * .9, -oy / n * .9) + .5 if near else dome_s(ox / n * .7, oy / n * .7) * .8 + (1.3 if (x * 5 + y * 3) % 7 == 0 else 0)
                cv.put(x, y, S[dith(s, x, y)])
    P0 = _arch(dcx, hwd, spr, dtop, dbot, 28); P1 = _arch(bcx, bhw, bspr, btop, bbot, 28)
    for i in (5, 9, 19, 23):
        (x0, y0), (x1, y1) = P0[i], P1[i]; n = int(max(abs(x1 - x0), abs(y1 - y0)))
        for k in range(1, n):
            if (k // 4) % 3 == 2: continue
            px = int(x0 + (x1 - x0) * k / n); py = int(y0 + (y1 - y0) * k / n)
            if inside(px, py) and not back(px, py): cv.put(px, py, S[4] if i < 14 else S[3])
    # stalactites: shaded cones with a 1 px lit edge and a hanging drop
    for x0, L in ((98, 24), (106, 12), (113, 18), (120, 9), (132, 27), (141, 13), (149, 20), (156, 8)):
        base = 140 + int(max(0, abs(x0 - 125) - 14) * .9)
        for k in range(L):
            hw_ = (L - k) * 3 // (L + 2) + (1 if k < L - 3 else 0)
            for xx in range(x0 - hw_, x0 + hw_ + 1):
                u = (xx - (x0 - hw_)) / max(1, 2 * hw_); s = .3 + 3 * u + (.9 if (k // 3) % 2 and xx > x0 else 0)
                if inside(xx, base + k): cv.put(xx, base + k, S[dith(s, xx, base + k)])
        if inside(x0, base + L + 1): cv.put(x0, base + L, S[1]); cv.put(x0, base + L + 2, SEA[0]); cv.put(x0, base + L + 3, SEA[1]) if (x0 // 3) % 2 else None
    for x0, L in ((90, 14), (156, 20), (112, 9), (140, 12)):   # stalagmites
        for k in range(L):
            hw_ = (L - k) * 3 // (L + 2) + (1 if k < L - 3 else 0)
            for xx in range(x0 - hw_, x0 + hw_ + 1):
                u = (xx - (x0 - hw_)) / max(1, 2 * hw_); s = .5 + 2.8 * u
                if inside(xx, 229 - k): cv.put(xx, 229 - k, S[dith(s, xx, 229 - k)])
    # pool with reflections and ripples
    for y in range(222, 237):
        for x in range(92, 160):
            nx = (x - 126) / 33; ny = (y - 230) / 7
            if nx * nx + ny * ny > 1: continue
            s = 1.6 + ny * .6 + (.9 if (y + x // 6) % 3 == 0 else 0) + nx * .4
            cv.put(x, y, SEA[min(3, dith(s, x, y) // 1 if dith(s, x, y) < 4 else 3)] if dith(s, x, y) < 4 else SEA[3])
    for x in range(100, 152):
        if (x * 7) % 5 < 2: cv.put(x, 230, SEA[0]) 
    for rx_, ry_ in ((6, 1), (11, 2), (17, 3)):
        for a in range(0, 360, 6):
            px = int(133 + math.cos(math.radians(a)) * rx_); py = int(229 + math.sin(math.radians(a)) * ry_)
            if (a // 6) % 4 != 3 and ((133 - px) ** 2 / 400 + (py - 230) ** 2 / 36 < 1): cv.put(px, py, CREAM if rx_ == 6 else SEA[0])
    for x, y in ((136, 172), (112, 196), (141, 204), (118, 160)):   # drops in flight
        for k in range(5): cv.put(x, y - 5 + k, SEA[1 if k > 2 else 0])
        cv.put(x - 1, y, SEA[1]); cv.put(x + 1, y, SEA[2]); cv.put(x, y, SEA[0]); cv.put(x, y + 1, SEA[2])
    # weathering outside: cracks, lichen, moss
    isr = lambda c: c[3] and c != INK and (c in S or True)
    def cracks_rock(x, y, n):
        for k in range(n):
            c = cv.get(x, y)
            if not c[3] or c == INK: break
            cv.put(x, y, S[4]); lit = cv.get(x - 1, y)
            if lit[3] and lit != INK and lit != S[4]: cv.put(x - 1, y, S[0])
            y += 1; x += rnd.choice((-1, 0, 1))
    for (x, y, n) in ((60, 120, 30), (200, 128, 34), (44, 170, 24), (214, 168, 22), (100, 80, 22), (150, 90, 26), (84, 120, 16)): cracks_rock(x, y, n)
    lichen(cv, 40, 140, 12, 14, rnd, isr); lichen(cv, 210, 150, 10, 12, rnd, isr); lichen(cv, 96, 100, 10, 8, rnd, isr)
    for cx, cy, rx, ry in ((125, 66, 50, 16), (74, 94, 32, 13), (176, 98, 32, 13), (44, 146, 22, 12), (208, 150, 22, 12), (28, 196, 16, 10), (224, 198, 14, 10), (100, 58, 20, 7), (152, 62, 20, 8)):
        moss(cv, cx, cy, rx, ry, rnd, lambda c: c[3] and c != INK)
    for x in range(78, 172, 3):   # moss fringe over the mouth
        for y in range(120, 125 + (x * 5) % 9): cv.put(x, y, M[2 + (y % 2)]) if (x // 3) % 3 != 0 and cv.get(x, y)[3] else None
        for k in range(2): cv.put(x, 130 + (x * 3) % 5 + k, M[1 + k]) if cv.get(x, 128)[3] and (x // 3) % 3 == 1 else None
    for x in (20, 232, 60, 200): vine(cv, x, 196 if x in (20, 232) else 120, 12, rnd) if False else None
    for k in range(14):   # ferns clinging to the foot
        x = 12 + (k * 17) % 48 if k < 7 else 190 + (k * 11) % 48; y = 238 - rnd.randint(0, 3)
        for j in range(rnd.randint(5, 10)): cv.put(x + j // 3 * (1 if k % 2 else -1), y - j, M[1 + (j % 2)] if j < 8 else M[0])
    _mush(cv, 40, 236, rnd); _mush(cv, 50, 238, rnd, 1); _tuft(cv, 214, 238, rnd, 3, 8); pebble(cv, 22, 238, rnd); pebble(cv, 238, 238, rnd)

def lm_mossgate(rnd, cv):   # 340 x 210
    S = r5(RAMP["stone"]); M = r5(RAMP["moss"]); G = RAMP["gold"]; W = r5(RAMP["wood"]); GG = G
    base = 206
    posts = ((22, 88), (252, 318))
    for x0, x1 in posts:
        y0 = 30
        _col(cv, x0, x1, y0, base, S, rnd, .12)
        for i, y in enumerate(range(y0 + 22, base - 10, 26)):   # courses of stone with offset joints
            for x in range(x0, x1): cv.put(x, y, S[3])
            for x in range(x0 + 14 + (i % 2) * 18, x1, 36):
                for yy in range(y - 26, y): cv.put(x, yy, S[3])
        for x in range(x0, x1):   # moss poured down the post
            dep = 34 + 12 * ((x * 7) % 5) // 2 - abs(x - (x0 + x1) // 2) // 3
            for y in range(y0 + 4, y0 + dep):
                u = (x - x0) / (x1 - x0); t = 0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3
                if y > y0 + dep - 6: t = min(4, t + 1)
                if rnd.random() < .12: t = max(0, t - 1)
                cv.put(x, y, M[t])
        lump(cv, (x0 + x1) // 2, y0 - 2, (x1 - x0) // 2 + 8, 12, S, rnd, .1)   # capstone
        lump(cv, (x0 + x1) // 2 - 3, y0 - 8, (x1 - x0) // 2 + 2, 10, M, rnd, .12)
        for y in range(base - 26, base):   # mossy foot
            for x in range(x0 - 6, x1 + 6):
                if (x * 5 + y) % 7 < 3: cv.put(x, y, M[2 + (y % 2)])
    for cx, cy in ((48, 16), (288, 20)):   # flowers on the caps
        for dx, dy, c in ((0, 0, G[1]), (-3, 0, CREAM), (3, 0, CREAM), (0, -3, CREAM), (0, 3, CREAM)): cv.put(cx + dx, cy + dy, c)
    # lintel pole with a bell
    for x in range(88, 252):
        sag = int(5 * math.sin((x - 88) / 164 * math.pi))
        for y in range(52 + sag, 62 + sag): cv.put(x, y, W[0 if y < 54 + sag else 1 if y < 57 + sag else 3 if y > 59 + sag else 2])
    for x in range(100, 240, 9): lump(cv, x, 54 + int(5 * math.sin((x - 88) / 164 * math.pi)), 8, 4, M, rnd, .1)
    _line(cv, 178, 64, 178, 92, W[4], 2)
    lump(cv, 178, 104, 12, 14, r5(G), rnd, 0); _rect(cv, 164, 112, 193, 118, G[2]); _disc(cv, 178, 122, 3, G[3])
    cv.put(176, 98, CREAM); cv.put(177, 97, CREAM)
    # the gate leaf, hung from the left post, right half missing on purpose
    for px in range(88, 172, 14):
        for x in range(px, px + 12):
            for y in range(100, 200):
                tt = 0 if x - px < 2 else 1 if x - px < 5 else 2 if x - px < 9 else 3
                if y < 112: tt = max(0, tt - 1) if False else tt
                cv.put(x, y, W[tt + (1 if (x * 3 + y // 7) % 11 == 0 else 0) if tt < 3 else 3])
    for y in range(100, 200): cv.put(171, y, W[4])
    for ry0 in (112, 176):
        _rect(cv, 88, ry0, 172, ry0 + 9, W[2]); _rect(cv, 88, ry0, 172, ry0 + 2, W[0]); _rect(cv, 88, ry0 + 8, 172, ry0 + 9, W[4])
    _line(cv, 92, 186, 166, 122, W[3], 4)
    for ey in (114, 178): _rect(cv, 88, ey, 114, ey + 5, S[4]); _rect(cv, 88, ey, 114, ey + 2, S[2]); _disc(cv, 116, ey + 2, 3, S[4])
    for x0 in range(92, 170, 16): lump(cv, x0, 102, 11, 5, M, rnd, .12)
    _rect(cv, 164, 150, 172, 158, S[4]); _rect(cv, 252, 148, 258, 160, S[4]); _rect(cv, 244, 152, 258, 156, S[4])   # latch and hook
    for x, y in ((100, 200), (140, 202), (200, 202), (232, 200)): _tuft(cv, x, y + 4, rnd, 3, 7)
    _fern(cv, 98, base - 2, rnd, 1.0); _fern(cv, 244, base - 2, rnd, 1.1); _fern(cv, 14, base - 2, rnd, .8); _fern(cv, 326, base - 2, rnd, .8)
    _mush(cv, 200, 204, rnd); _mush(cv, 212, 205, rnd, 1); _mush(cv, 40, base - 1, rnd, 1)
    for x in range(180, 244, 4): cv.put(x, base - 1, RAMP["litter"][1])

def lm_toadsteps(rnd, cv):   # 260 x 240
    M = r5(RAMP["moss"]); E = r5(RAMP["ember"]); S = r5(RAMP["sand"])
    lump(cv, 130, 200, 124, 38, M, rnd, .1); lump(cv, 190, 160, 66, 60, M, rnd, .1)
    steps = ((200, 96), (150, 128), (100, 160), (52, 194))
    for sx, sy in steps:
        for y in range(sy + 4, sy + 34):
            hw = 9 + (y - sy) // 12
            for x in range(sx - hw, sx + hw): 
                u = (x - (sx - hw)) / (2 * hw); cv.put(x, y, S[0 if u < .15 else 1 if u < .4 else 2 if u < .75 else 3])
        lump(cv, sx, sy, 40, 14, E, rnd, 0)   # flat cap
        for y in range(sy + 4, sy + 14):   # gills underneath
            hw = int(40 * math.sqrt(max(0, 1 - ((y - sy - 4) / 14) ** 2))) if False else 0
        for k in range(5):
            ax = sx - 26 + k * 13 + (k % 2) * 3; ay = sy - 5 + (k * 5) % 7
            _disc(cv, ax, ay, 3, CREAM, 2)
        for x in range(sx - 36, sx + 37, 4):   # light rim and gill line on the lower edge
            y = sy + int(11 * math.sqrt(max(0, 1 - ((x - sx) / 40) ** 2)))
            cv.put(x, y + 1, S[2]); cv.put(x + 1, y + 1, S[1])
    for x, y in ((24, 214), (236, 206), (212, 206)): _tuft(cv, x, y + 22, rnd, 3, 8)
    _mush(cv, 232, 226, rnd, 1); _mush(cv, 18, 226, rnd, 1); _mush(cv, 240, 232, rnd, 1)
    for x in range(60, 200, 6): cv.put(x, 232, M[0]); cv.put(x + 1, 233, M[1])

LM = {
 "304-oakarch": (280, 250, lm_oakarch), "304-hollowtrunk": (210, 250, lm_hollowtrunk),
 "304-acorndrop": (210, 250, lm_acorndrop), "304-owloak": (240, 290, lm_owloak),
 "305-birchtunnel": (290, 230, lm_birchtunnel), "305-birchcurtain": (280, 220, lm_birchcurtain),
 "305-fernhollow": (270, 130, lm_fernhollow), "305-sunclearing": (250, 170, lm_sunclearing),
 "306-mosslog": (340, 150, lm_mosslog), "306-dripgrotto": (250, 240, lm_dripgrotto),
 "306-mossgate": (340, 210, lm_mossgate), "306-toadsteps": (260, 240, lm_toadsteps),
}
