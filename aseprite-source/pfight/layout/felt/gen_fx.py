#!/usr/bin/env python3
"""Pop-animation sprite sheets for Puzzle Combat, "Stitched Toy" felt style, HARD PIXELS ONLY.
Run: python3 gen_fx.py [out dir]   (default: game/assets/img/pfight/)
Writes fx-hit.png fx-guard.png fx-heal.png fx-charm.png: each 128x32 RGBA = 4 frames of 32x32 (frame i at x=i*32),
played once at ~10 fps, centred on the frame, transparent background.
Colour-blind cue = SHAPE language, not colour alone:
  hit   = jagged star + slash streaks          (vermilion/cream)
  guard = round ring pulse + leaf shield        (blue/cream)
  heal  = plus signs rising                     (green/cream)
  charm = petals + hearts swirling out          (pink/cream)
Every object is a hard mask -> felt bevel (light top-left, shade bottom-right), optional dashed cream stitch,
then its own 1 px 4-neighbour ink outline, composited front to back (alpha only 0/255)."""
import math
import os
import sys
import numpy as np
from PIL import Image
import base_icons as B

INK, CREAM, GOLD = B.INK, B.CREAM, B.GOLD
hx = B.hx
WHITE = hx('#fff8e6')
CD = B.CREAM_D
S = 32
C = 15.5                                     # frame centre (between pixels 15 and 16)
YY, XX = np.mgrid[0:S, 0:S]
PX, PY = XX + 0.5, YY + 0.5                  # pixel centres


# ---------------------------------------------------------------- core helpers
def nbr(m, dx, dy):
    """m shifted so out[y,x] = m[y+dy, x+dx] (False outside)."""
    p = np.pad(m, 1)
    return p[1 + dy:1 + dy + S, 1 + dx:1 + dx + S]


def erode(m):
    return m & nbr(m, 1, 0) & nbr(m, -1, 0) & nbr(m, 0, 1) & nbr(m, 0, -1)


def felt(m, base, light, shade, stitch=None, outline=True):
    """mask -> RGBA layer with bevel, optional stitch (dashed line 2 px inside the edge), ."""
    a = np.zeros((S, S, 4), np.uint8)
    a[m] = base + (255,)
    sh = m & ~nbr(m, 1, 1)
    li = m & ~nbr(m, -1, -1) & ~sh
    a[sh] = shade + (255,)
    a[li] = light + (255,)
    if stitch is not None:
        inner = erode(erode(m))
        ring = inner & ~erode(inner)
        ys, xs = np.nonzero(m)
        ry, rx = np.nonzero(ring)
        order = np.argsort(np.arctan2(ry - ys.mean(), rx - xs.mean()))
        dash = np.zeros_like(m)
        for k, i in enumerate(order):
            dash[ry[i], rx[i]] = (k % 4) < 2               # 2 on, 2 off along the seam
        a[dash] = stitch + (255,)
    if outline:
        o = (nbr(m, 1, 0) | nbr(m, -1, 0) | nbr(m, 0, 1) | nbr(m, 0, -1)) & ~m
        a[o] = INK + (255,)
    return a


def paint(a, m, col):
    a[m & (a[..., 3] > 0)] = col + (255,)


def over(dst, src):
    s = src[..., 3] > 0
    dst[s] = src[s]
    return dst


def blank():
    return np.zeros((S, S, 4), np.uint8)


def dots(pts, col, outline=True):
    """tiny solid pixels / blocks: list of (x, y) or (x, y, w, h)."""
    m = np.zeros((S, S), bool)
    for p in pts:
        x, y = p[0], p[1]
        w, h = (p[2], p[3]) if len(p) > 2 else (1, 1)
        m[y:y + h, x:x + w] = True
    a = np.zeros((S, S, 4), np.uint8)
    a[m] = col + (255,)
    if outline:
        o = (nbr(m, 1, 0) | nbr(m, -1, 0) | nbr(m, 0, 1) | nbr(m, 0, -1)) & ~m
        a[o] = INK + (255,)
    return a


def poly_mask(pts):
    """even-odd point-in-polygon on pixel centres (hard)."""
    m = np.zeros((S, S), bool)
    n = len(pts)
    for i in range(n):
        x1, y1 = pts[i]
        x2, y2 = pts[(i + 1) % n]
        cond = (y1 > PY) != (y2 > PY)
        with np.errstate(divide='ignore', invalid='ignore'):
            xint = x1 + (PY - y1) * (x2 - x1) / (y2 - y1 + 1e-12)
        m ^= cond & (PX < xint)
    return m


def disc(cx, cy, r):
    return (PX - cx) ** 2 + (PY - cy) ** 2 <= r * r


def sparkle4(cx, cy, r, col=CREAM, ink=True):
    """4-point twinkle: + with arms r, centre pixel at (cx, cy) integer."""
    pts = [(cx, cy)]
    for k in range(1, r + 1):
        pts += [(cx + k, cy), (cx - k, cy), (cx, cy + k), (cx, cy - k)]
    pts = [p for p in pts if 0 <= p[0] < S and 0 <= p[1] < S]
    return dots(pts, col, outline=ink)


# ---------------------------------------------------------------- palettes
HU, GU, HE, CH = B.TYPES['hurt'], B.TYPES['guard'], B.TYPES['heal'], B.TYPES['charm']


# ---------------------------------------------------------------- HIT: jagged starburst + slash streaks
def star(cx, cy, radii, rin, rot=0.0):
    n = len(radii)
    pts = []
    for i in range(n):
        a0 = rot + i * 2 * math.pi / n
        a1 = a0 + math.pi / n
        pts.append((cx + radii[i] * math.cos(a0), cy + radii[i] * math.sin(a0)))
        ri = rin[i] if isinstance(rin, (list, tuple)) else rin
        pts.append((cx + ri * math.cos(a1), cy + ri * math.sin(a1)))
    return poly_mask(pts)


def slash(x0, y0, x1, y1, w):
    """tapered streak: thick at (x0,y0), sharp at (x1,y1)."""
    dx, dy = x1 - x0, y1 - y0
    L = math.hypot(dx, dy)
    nx, ny = -dy / L * w, dx / L * w
    return poly_mask([(x0 + nx, y0 + ny), (x1, y1), (x0 - nx, y0 - ny), (x0 - dx / L * 1.2, y0 - dy / L * 1.2)])


def shard(cx, cy, ang, ln, w):
    """small triangle pointing outward along ang."""
    ca, sa = math.cos(ang), math.sin(ang)
    tip = (cx + ca * ln, cy + sa * ln)
    b1 = (cx - sa * w, cy + ca * w)
    b2 = (cx + sa * w, cy - ca * w)
    return poly_mask([tip, b1, b2])


def fx_hit():
    fr = []
    # f1: small tight 6-point star, cream core, one short streak forming
    a = blank()
    m = star(C, C, [7, 6, 7.5, 5.5, 7, 6.5], 3.0, rot=-0.3)
    l = felt(m, HU['base'], HU['light'], HU['shade'])
    paint(l, disc(C, C, 2.6), CREAM)
    over(a, l)
    over(a, felt(slash(22, 9, 27, 4, 1.2), CREAM, WHITE, CD))
    fr.append(a)
    # f2: big irregular 9-point star, layered cream inner star, two crossing slash streaks
    a = blank()
    m = star(C, C + 0.5, [14, 10, 13.5, 11, 14.5, 9.5, 13, 11.5, 12.5], [5.5, 6, 5, 6.5, 5.5, 6, 5, 6.5, 5.5], rot=-1.4)
    l = felt(m, HU['base'], HU['light'], HU['shade'])
    inner = star(C, C + 0.5, [7, 6, 7.5, 5.5, 7, 6.5, 6, 7.5, 6], 3.2, rot=-1.4 + 0.35)
    paint(l, inner, CREAM)
    paint(l, disc(C - 0.5, C, 1.6), WHITE)
    over(a, l)
    over(a, felt(slash(8, 25, 29, 3, 1.6), WHITE, WHITE, CD))
    over(a, felt(slash(22, 25, 30, 17, 1.0), CREAM, WHITE, CD))
    over(a, felt(slash(3, 13, 1, 2, 1.0), CREAM, WHITE, CD))
    fr.append(a)
    # f3: breaking up - star splits into separate outward shards, hollow centre with a cream ring flash
    a = blank()
    ring = disc(C, C, 6.2) & ~disc(C, C, 4.2)
    over(a, felt(ring, CREAM, WHITE, CD))
    angs = [-1.4 + k * 2 * math.pi / 9 + (0.12 if k % 2 else -0.08) for k in range(9)]
    lens = [7, 5, 6.5, 5, 7, 5.5, 6.5, 4.5, 6]
    for i, (g, ln) in enumerate(zip(angs, lens)):
        r0 = 9.0 + (i % 2) * 1.0
        m = shard(C + r0 * math.cos(g), C + r0 * math.sin(g), g + (0.25 if i % 2 else -0.2), ln, 2.2)
        col = HU['base'] if i % 3 else CREAM
        over(a, felt(m, col, HU['light'] if i % 3 else WHITE, HU['shade'] if i % 3 else CD))
    over(a, felt(slash(26, 3, 29, 1, 1.0) | slash(3, 28, 1, 30, 1.0), CREAM, WHITE, CD))
    fr.append(a)
    # f4: faint fragments at the rim: tiny shards and loose dots, no centre
    a = blank()
    for g, r, ln, col in [(-1.2, 12.5, 3.5, HU['base']), (0.4, 13, 3, CREAM), (1.55, 12, 3.5, HU['shade']),
                          (2.8, 13, 3, HU['base']), (4.0, 12.5, 3, CREAM), (5.1, 13.5, 2.5, HU['shade'])]:
        m = shard(C + r * math.cos(g), C + r * math.sin(g), g + 0.3, ln, 1.4)
        over(a, felt(m, col, col, col))
    over(a, dots([(9, 12), (21, 19), (13, 22), (20, 10)], HU['shade'], outline=False))
    over(a, dots([(16, 15), (10, 18)], CD, outline=False))
    fr.append(a)
    return fr


# ---------------------------------------------------------------- GUARD: leaf-shield + round ring pulse
def shield(cx, top, w, h):
    """flat-ish top with rounded shoulders, tapering to a point (leaf-shield)."""
    t = (PY - top) / h
    hw = np.where(t < 0.45, w * (0.82 + 0.18 * np.sqrt(np.clip(t / 0.45, 0, 1))), w * np.clip(1 - (t - 0.45) / 0.55, 0, 1) ** 0.8)
    m = (t >= 0) & (t <= 1) & (np.abs(PX - cx) <= hw)
    return m


def ring(cx, cy, r, th=1.0):
    d = np.hypot(PX - cx, PY - cy)
    return (d <= r + th / 2) & (d > r - th / 2)


def guard_shield(a, cx, top, w, h, hollow=False):
    m = shield(cx, top, w, h)
    if hollow:
        l = felt(m & ~erode(erode(m)), CREAM, WHITE, CD)
        return over(a, l)
    l = felt(m, GU['base'], GU['light'], GU['shade'], stitch=CREAM if w >= 6 else None)
    # leaf midrib + veins in cream
    rib = (np.abs(PX - cx) < 0.6) & (PY > top + 4) & (PY < top + h - 1.5) & m
    paint(l, rib, CREAM)
    if False:
        for k in range(2):
            vy = top + 4 + k * 4
            v = m & (np.abs((PY - vy) - 0.6 * np.abs(PX - cx)) < 0.5) & (np.abs(PX - cx) < w - 2.5) & (np.abs(PX - cx) > 0.5)
            paint(l, v, GU['mark'])
    # darker right half (felt fold)
    paint(l, m & (PX > cx + 0.6) & erode(m) & ~rib & (l[..., :3] == np.array(GU['base'])).all(-1), GU['shade'])
    return over(a, l)


def fx_guard():
    fr = []
    # f1: small shield pops in, tight cream ring hugging it, 2 sparks
    a = blank()
    rm = ring(C, C, 8.5, 2.0)
    over(a, felt(rm, CREAM, WHITE, CD))
    guard_shield(a, C, 10, 4.5, 12)
    over(a, sparkle4(5, 8, 1))
    over(a, sparkle4(26, 23, 1))
    fr.append(a)
    # f2: full shield, blue ring pulse at mid radius, 4 diagonal sparks
    a = blank()
    rm = ring(C, C, 12.0, 2.0)
    l = felt(rm, GU['light'], GU['light'], GU['base'])
    ang0 = np.arctan2(PY - C, PX - C)
    paint(l, rm & (np.sin(ang0 * 12) > 0.6), CREAM)
    over(a, l)
    guard_shield(a, C, 6, 7.5, 21)
    for p in [(3, 3), (28, 4), (3, 28), (28, 28)]:
        over(a, sparkle4(p[0], p[1], 1, GOLD))
    fr.append(a)
    # f3: shield settles slightly smaller, ring pushed to the rim and broken into arcs, sparks fly as plus-sparks
    a = blank()
    d = np.hypot(PX - C, PY - C)
    ang = np.arctan2(PY - C, PX - C)
    rm = (d <= 14.4) & (d > 13.0) & (np.sin(ang * 6 + 0.4) > -0.35)
    over(a, felt(rm, CREAM, WHITE, CD))
    guard_shield(a, C, 8, 6.5, 17)
    over(a, sparkle4(6, 6, 2, CREAM))
    over(a, sparkle4(25, 26, 2, CREAM))
    over(a, dots([(26, 6), (5, 25)], GOLD))
    fr.append(a)
    # f4: shield fades to a cream outline ghost, ring reduced to 4 short arcs, tiny dots
    a = blank()
    rm = (d <= 15.2) & (d > 14.2) & (np.sin(ang * 4 + 0.8) > 0.55)
    over(a, felt(rm, GU['light'], GU['light'], GU['light'], outline=False))
    guard_shield(a, C, 9, 5.5, 15, hollow=True)
    over(a, dots([(4, 12), (27, 18), (12, 2), (19, 29)], CREAM, outline=False))
    fr.append(a)
    return fr


# ---------------------------------------------------------------- HEAL: plus signs rising + hearts + sparkles
def plus(cx, cy, arm, th):
    """cx,cy pixel centre; arm = half length; th = half thickness."""
    return ((np.abs(PX - cx) <= arm) & (np.abs(PY - cy) <= th)) | ((np.abs(PX - cx) <= th) & (np.abs(PY - cy) <= arm))


def heal_plus(a, cx, cy, arm, th, big=False):
    m = plus(cx, cy, arm, th)
    l = felt(m, HE['base'], HE['light'], HE['shade'])
    if big:
        c = plus(cx, cy, arm - 2, max(th - 2, 0.5))
        paint(l, c, CREAM)
        paint(l, c & ~nbr(c, 1, 1), HE['mark'])
    return over(a, l)


def heart(cx, cy, s):
    x = (PX - cx) / s
    y = -(PY - cy) / s
    return (x * x + y * y - 1) ** 3 - x * x * y ** 3 <= 0


def fx_heal():
    fr = []
    # f1: one small plus low in the frame, sparkle dots starting
    a = blank()
    heal_plus(a, 16, 21, 4.5, 1.5)
    over(a, dots([(9, 25), (23, 26)], CREAM))
    over(a, dots([(22, 17)], HE['mark'], outline=False))
    fr.append(a)
    # f2: big plus in the centre with cream core, two small pluses flanking low, sparkles
    a = blank()
    heal_plus(a, 7, 23, 3.5, 1.0)
    heal_plus(a, 25, 21, 3.5, 1.0)
    heal_plus(a, 16, 15, 9.5, 3.5, big=True)
    over(a, sparkle4(26, 7, 2))
    over(a, sparkle4(5, 10, 1))
    over(a, dots([(14, 28), (20, 29)], HE['mark']))
    fr.append(a)
    # f3: big plus risen and smaller, flankers rising past it, a green heart lifts from below
    a = blank()
    heal_plus(a, 16, 10, 6.5, 2.5, big=True)
    heal_plus(a, 6, 15, 3.5, 1.0)
    heal_plus(a, 26, 13, 2.5, 1.0)
    hm = heart(16.5, 23.5, 4.2)
    l = felt(hm, HE['base'], HE['light'], HE['shade'])
    paint(l, plus(16, 23, 1.5, 0.5), CREAM)
    over(a, l)
    over(a, sparkle4(25, 25, 2))
    over(a, sparkle4(7, 4, 1))
    fr.append(a)
    # f4: everything near the top and tiny, sparkles winking out
    a = blank()
    heal_plus(a, 16, 4, 2.5, 0.5)
    heal_plus(a, 7, 9, 2.5, 0.5)
    hm = heart(23.5, 10.5, 2.3)
    over(a, felt(hm, HE['base'], HE['light'], HE['shade']))
    over(a, sparkle4(11, 15, 1, CREAM, ink=False))
    over(a, dots([(20, 18), (26, 4), (5, 14)], CREAM, outline=False))
    over(a, dots([(14, 20)], HE['mark'], outline=False))
    fr.append(a)
    return fr


# ---------------------------------------------------------------- CHARM: petals + hearts swirling out
def petal(cx, cy, ang, ln, w):
    """teardrop: round end near (cx,cy), point at ln along ang."""
    ca, sa = math.cos(ang), math.sin(ang)
    u = (PX - cx) * ca + (PY - cy) * sa          # along
    v = -(PX - cx) * sa + (PY - cy) * ca         # across
    t = u / ln
    half = w * np.sqrt(np.clip(t, 0, 1)) * np.clip((1 - t) * 1.6, 0, 1)
    half = np.where(t < 0.35, w * np.sqrt(np.clip(t / 0.35, 0, 1)) * 0.95 + 0.0, half)
    return (t >= 0) & (t <= 1) & (np.abs(v) <= half)


def charm_petal(a, r, ang, ln, w, cream=False):
    cx, cy = C + r * math.cos(ang), C + r * math.sin(ang)
    m = petal(cx, cy, ang + 1.0, ln, w)          # tilted = swirl
    if cream:
        l = felt(m, CREAM, WHITE, CD)
    else:
        l = felt(m, CH['base'], CH['light'], CH['shade'])
        # midline vein
        ca, sa = math.cos(ang + 1.0), math.sin(ang + 1.0)
        v = -(PX - cx) * sa + (PY - cy) * ca
        u = (PX - cx) * ca + (PY - cy) * sa
        paint(l, m & (np.abs(v) < 0.5) & (u > 1.5) & (u < ln - 1.5), CH['mark'])
    return over(a, l)


def charm_heart(a, cx, cy, s, stitch=False):
    m = heart(cx, cy, s)
    l = felt(m, CH['base'], CH['light'], CH['shade'], stitch=CREAM if stitch else None)
    paint(l, disc(cx - s * 0.45, cy - s * 0.35, max(0.7, s * 0.22)), WHITE)
    return over(a, l)


def flower(a, cx, cy):
    """5-dot cream flower with gold centre (pixel art)."""
    over(a, dots([(cx, cy - 2, 2, 1), (cx - 2, cy, 1, 2), (cx + 2, cy, 1, 2), (cx - 1, cy + 2), (cx + 1, cy + 2),
                  (cx - 1, cy - 1, 3, 3)], CREAM))
    over(a, dots([(cx, cy, 1, 1)], GOLD, outline=False))
    return a


def fx_charm():
    fr = []
    # f1: small heart pops, two petals peeking out
    a = blank()
    charm_petal(a, 8.5, -0.6, 5, 1.8)
    charm_petal(a, 8.5, 2.5, 5, 1.8, cream=True)
    charm_heart(a, C, C + 1, 5.0)
    fr.append(a)
    # f2: big stitched heart, 5 petals swirling round it
    a = blank()
    for i in range(5):
        g = -0.3 + i * 2 * math.pi / 5
        charm_petal(a, 10.5, g, 6.5, 2.6, cream=(i % 2 == 1))
    charm_heart(a, C, C + 1, 7.5, stitch=True)
    fr.append(a)
    # f3: heart has popped into two small hearts drifting apart, petals further out and rotated, a flower
    a = blank()
    for i in range(5):
        g = -1.2 + 0.7 + i * 2 * math.pi / 5
        charm_petal(a, 11.0, g, 5, 1.8, cream=(i % 2 == 0))
    charm_heart(a, 11.5, 13.5, 3.6)
    charm_heart(a, 20.5, 19.5, 3.2)
    flower(a, 22, 9)
    flower(a, 8, 22)
    fr.append(a)
    # f4: tiny petals at the rim, one small heart floating up, sparkle dots
    a = blank()
    for i in range(4):
        g = -1.2 + 1.5 + i * 2 * math.pi / 4
        charm_petal(a, 12.5, g, 3.5, 1.2, cream=(i % 2 == 1))
    charm_heart(a, 16.5, 9.5, 2.4)
    over(a, dots([(10, 19), (22, 21), (16, 26)], CH['light'], outline=False))
    over(a, dots([(19, 14)], CREAM, outline=False))
    fr.append(a)
    return fr


# ---------------------------------------------------------------- output
def sheet(frames):
    out = Image.new('RGBA', (S * len(frames), S), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        out.paste(Image.fromarray(f), (i * S, 0))
    return out


FX = {'hit': fx_hit, 'guard': fx_guard, 'heal': fx_heal, 'charm': fx_charm}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(B.HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')
    out = os.path.normpath(out)
    os.makedirs(out, exist_ok=True)
    for k, fn in FX.items():
        im = sheet(fn())
        a = np.array(im)
        assert set(np.unique(a[..., 3])) <= {0, 255}, k
        im.save(os.path.join(out, 'fx-%s.png' % k))
        print('wrote', os.path.join(out, 'fx-%s.png' % k), im.size)
