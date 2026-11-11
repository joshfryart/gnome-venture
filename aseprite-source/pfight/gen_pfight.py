#!/usr/bin/env python3
"""Puzzle Combat art, Group 1 (tiles). Hard pixels only, no anti-aliasing.

Run:  python3 gen_pfight.py <png_out_dir>
Draws every Group 1 PNG. aseprite-source/pfight/*.aseprite are made from these
PNGs with:  aseprite -b in.png --save-as out.aseprite  (see make_ase.sh).
"""
import math
import os
import sys
from PIL import Image, ImageDraw

INK = (42, 26, 16)
CREAM = (242, 228, 192)
GOLD = (232, 163, 23)
WHITE = (255, 248, 224)
FELT = (61, 42, 28)

TYPES = {  # base colour (Okabe-Ito, nudged a little)
    'hurt':   (213, 94, 0),
    'guard':  (0, 114, 178),
    'heal':   (0, 158, 115),
    'charm':  (204, 121, 167),
    'soothe': (86, 180, 233),
    'trick':  (240, 228, 66),
    'item':   (230, 159, 0),
}
FAMS = ['body', 'mind', 'craft']


def clamp(v):
    return max(0, min(255, int(round(v))))


def dark_of(c):  # hue-shifted shade: toward cool umber
    return (clamp(c[0] * .58 + 6), clamp(c[1] * .55 + 4), clamp(c[2] * .62 + 14))


def light_of(c):  # warm light
    return (clamp(c[0] + (255 - c[0]) * .38), clamp(c[1] + (255 - c[1]) * .34), clamp(c[2] + (255 - c[2]) * .22))


class Cv:
    def __init__(s, w, h):
        s.w, s.h = w, h
        s.p = [[None] * w for _ in range(h)]

    def set(s, x, y, c):
        if 0 <= x < s.w and 0 <= y < s.h:
            s.p[y][x] = c

    def get(s, x, y):
        if 0 <= x < s.w and 0 <= y < s.h:
            return s.p[y][x]
        return None

    def rect(s, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                s.set(x, y, c)

    def disc(s, cx, cy, r, c):
        for y in range(s.h):
            for x in range(s.w):
                if (x + .5 - cx) ** 2 + (y + .5 - cy) ** 2 <= r * r:
                    s.set(x, y, c)

    def image(s):
        im = Image.new('RGBA', (s.w, s.h), (0, 0, 0, 0))
        px = im.load()
        for y in range(s.h):
            for x in range(s.w):
                c = s.p[y][x]
                if c is not None:
                    px[x, y] = (c[0], c[1], c[2], 255)
        return im


def in_rr(x, y, w, h, r):
    """pixel inside rounded rect of w x h, corner radius r"""
    if r <= 0:
        return 0 <= x < w and 0 <= y < h
    cx = r - .5 if x < r else (w - r + .5 if x > w - 1 - r else None)
    cy = r - .5 if y < r else (h - r + .5 if y > h - 1 - r else None)
    if not (0 <= x < w and 0 <= y < h):
        return False
    if cx is None or cy is None:
        return True
    return (x + .5 - cx - .5) ** 2 + (y + .5 - cy - .5) ** 2 <= (r - .2) ** 2 + 0.01


# ---------------------------------------------------------------- patterns
def pat(t, x, y, k):
    """return 'd' (dark), 'l' (light), 'g' (cream), 'y' (gold) or None; k = 'hand'/'strip'"""
    H = k == 'hand'
    if t == 'hurt':  # diagonal slash stripes
        P, T = (8, 3) if H else (6, 2)
        return 'd' if (x + y) % P < T else None
    if t == 'guard':  # brick wall
        B = 6 if H else 5
        J = 9 if H else 7
        r = y // B
        if y % B == 0:
            return 'l'
        if (x + (r % 2) * (J // 2 + 1)) % J == 0:
            return 'l'
        return None
    if t == 'heal':  # dots
        S = 7 if H else 5
        r = y // S
        xx = x + (S // 2 + 1 if r % 2 else 0)
        if xx % S in ((0, 1) if H else (0,)) and y % S in ((0, 1) if H else (0,)):
            return 'l'
        return None
    if t == 'charm':  # small flowers
        S = 12 if H else 8
        r = y // S
        xx = x + (S // 2 if r % 2 else 0)
        cx = xx % S - S // 2
        cy = y % S - S // 2
        rad = 2 if H else 1
        if cx == 0 and cy == 0:
            return 'y'
        if abs(cx) + abs(cy) <= rad:
            return 'g'
        return None
    if t == 'soothe':  # wavy lines
        S = 6 if H else 5
        per = 10 if H else 8
        amp = 1.6 if H else 1.0
        for k2 in range(-1, 14):
            yy = k2 * S + 2 + round(amp * math.sin((x / per) * 2 * math.pi))
            if y == yy or (H and y == yy + 1):
                return 'd'
        return None
    if t == 'trick':  # checker
        S = 6 if H else 4
        return 'd' if ((x // S) + (y // S)) % 2 == 0 else None
    return None  # item: plain (stitched border added separately)


# ---------------------------------------------------------------- tile body
def body(t, k):
    W, H = (96, 68) if k == 'hand' else (56, 40)
    R = 4 if k == 'hand' else 3
    base = TYPES[t]
    dk, lt = dark_of(base), light_of(base)
    cv = Cv(W, H)
    inside = [[in_rr(x, y, W, H, R) for x in range(W)] for y in range(H)]

    def ins(x, y):
        return 0 <= x < W and 0 <= y < H and inside[y][x]

    for y in range(H):
        for x in range(W):
            if not inside[y][x]:
                continue
            edge = not (ins(x - 1, y) and ins(x + 1, y) and ins(x, y - 1) and ins(x, y + 1))
            if edge:
                cv.set(x, y, INK)
                continue
            c = base
            # 1px rim light top/left, shade bottom/right
            if (not ins(x - 2, y) and ins(x - 1, y)) or (not ins(x, y - 2) and ins(x, y - 1)):
                c = lt
            elif (not ins(x + 2, y) and ins(x + 1, y)) or (not ins(x, y + 2) and ins(x, y + 1)):
                c = dk
            else:
                pm = {'d': dk, 'l': lt, 'g': CREAM, 'y': GOLD}
                code = pat(t, x, y, k) if (2 <= x <= W - 3 and 2 <= y <= H - 3) else None
                if code:
                    c = pm[code]
            cv.set(x, y, c)
    # item: stitched gold border (plain body otherwise)
    if t == 'item':
        ins_ = 3 if k == 'hand' else 3
        for x in range(ins_ + 2, W - ins_ - 2):
            if x % 3 < 2:
                cv.set(x, ins_, CREAM)
                cv.set(x, H - 1 - ins_, CREAM)
        for y in range(ins_ + 2, H - ins_ - 2):
            if y % 3 < 2:
                cv.set(ins_, y, CREAM)
                cv.set(W - 1 - ins_, y, CREAM)
    # medallion (calm cream disc behind the icon)
    if k == 'hand':
        mx, my, mr = 53, 25, 19.5
    else:
        mx, my, mr = 31, 24, 11.5
    for y in range(H):
        for x in range(W):
            d2 = (x + .5 - mx) ** 2 + (y + .5 - my) ** 2
            if d2 <= mr * mr:
                edge = d2 > (mr - 1.15) ** 2
                cv.set(x, y, INK if edge else CREAM)
    if k == 'hand':  # stitched gold ring inside the disc, hard pixels
        n = 0
        for a in range(0, 360, 6):
            n += 1
            if n % 3 == 0:
                continue
            px = int(mx + (mr - 2.6) * math.cos(math.radians(a)))
            py = int(my + (mr - 2.6) * math.sin(math.radians(a)))
            cv.set(px, py, GOLD)
    # value plate (calm corner): dark umber with cream rim
    if k == 'hand':
        vx, vy, vw, vh = 21, 3, 14, 12
    else:
        vx, vy, vw, vh = 13, 2, 12, 10
    for y in range(vh):
        for x in range(vw):
            if not in_rr(x, y, vw, vh, 2):
                continue
            edge = not all(in_rr(x + dx, y + dy, vw, vh, 2) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            cv.set(vx + x, vy + y, CREAM if edge else INK)
    return cv.image()


# ---------------------------------------------------------------- sockets
KEY = {(13, 14): [14, 11, 8.5, 6, 4, 2.8, 2.8, 4.5, 5.7, 6, 6, 5.5, 4],
       (7, 9): [9, 6, 3, 3, 5, 5.5, 4]}


def profile(fam, P, A):
    """half-height for columns t=0..P-1 (t=0 is the base, wide side)"""
    out = []
    for t in range(P):
        u = (t + .5) / P
        if fam == 'body':      # dome
            hh = A * math.sqrt(max(0, 1 - u * u))
            hh = max(hh, 0)
        elif fam == 'craft':   # triangle
            hh = A * (1 - u) + .4
        else:                  # keyhole: flared skirt, narrow neck, round bulb (hand-tuned tables)
            tab = KEY.get((P, A))
            hh = tab[t]
        out.append(hh)
    return out


def shape_mask(fam, P, A, H, x0):
    hh = profile(fam, P, A)
    m = set()
    cy = H / 2.0
    for t in range(P):
        for y in range(H):
            if abs(y + .5 - cy) <= hh[t]:
                m.add((x0 + t, y))
    return m


def panel(W, H, outer_right):
    """opaque wood end panel. outer_right True: outer edge on the right."""
    R = 4 if H == 68 else 3
    wood, wl, wd = (138, 102, 68), (170, 134, 94), (92, 62, 40)
    cv = Cv(W, H)
    # use a body-sized rounded rect so the outer corners match the tile
    bw = W + 40
    for y in range(H):
        for x in range(W):
            xx = x if outer_right is False else x + 40 - 0
            if outer_right:
                gx = x  # panel at right: shape x from (bw-W)
                gx = x + (bw - W)
            else:
                gx = x
            if not in_rr(gx, y, bw, H, R):
                continue
            ex = (gx == 0 or gx == bw - 1)
            ey = (y == 0 or y == H - 1)
            edge = not all(in_rr(gx + dx, y + dy, bw, H, R) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if edge:
                cv.set(x, y, INK)
            elif y == 1 or (not in_rr(gx - 1, y - 1, bw, H, R) and True and y < H // 2):
                cv.set(x, y, wl)
            elif y == H - 2:
                cv.set(x, y, wd)
            else:
                cv.set(x, y, wood)
    # inner seam: ink line + gold stitches on the side facing the tile body
    sx = 0 if outer_right else W - 1
    for y in range(H):
        if cv.get(sx, y) is not None:
            cv.set(sx, y, INK)
    gx = 1 if outer_right else W - 2
    for y in range(3, H - 3):
        if y % 3 < 2:
            cv.set(gx, y, GOLD)
    return cv


def knob_peg(cv, fam, P, A, x0):
    H = cv.h
    m = shape_mask(fam, P, A, H, x0)
    dk, hi = (58, 38, 26), (110, 76, 52)
    for (x, y) in m:
        edge = not all(((x + dx, y + dy) in m) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        if edge:
            cv.set(x, y, CREAM)
        else:
            c = INK
            if (x - 1, y) not in m or (x, y - 1) not in m or ((x - 1, y) in m and ((x - 1, y)) and False):
                c = INK
            cv.set(x, y, c)
    # soft highlight inside, upper-left, 1px
    for (x, y) in m:
        if cv.get(x, y) == INK and ((x - 1, y) not in m or (x, y - 1) not in m):
            pass
    for (x, y) in sorted(m):
        if cv.get(x, y) == INK:
            up = cv.get(x, y - 1) == CREAM
            lf = cv.get(x - 1, y) == CREAM
            if (up or lf) and cv.get(x + 1, y + 1) == INK:
                cv.set(x, y, hi)
    return m


def hole_cavity(cv, fam, P, A, x0):
    H = cv.h
    m = shape_mask(fam, P, A, H, x0)
    shade, hl = (206, 184, 138), (255, 246, 222)
    for (x, y) in m:
        edge = not all(((x + dx, y + dy) in m) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        if edge:
            cv.set(x, y, INK)
        else:
            cv.set(x, y, CREAM)
    for (x, y) in m:
        if cv.get(x, y) == CREAM:
            if cv.get(x, y - 1) == INK or cv.get(x - 1, y) == INK:
                cv.set(x, y, shade)
            elif cv.get(x, y + 1) == INK and cv.get(x - 1, y + 1) is not None:
                cv.set(x, y, hl)
    return m


SOCK = {'hand': dict(W=20, H=68, P=13, A=14, x0=3), 'strip': dict(W=12, H=40, P=7, A=9, x0=2)}


def sock(k, fam, kind):
    d = SOCK[k]
    W, H, P, A, x0 = d['W'], d['H'], d['P'], d['A'], d['x0']
    outer_right = (kind == 'knob')
    cv = panel(W, H, outer_right)
    if fam == 'flat':
        # wild edge: plain panel with a gold button (4x4 hand, 3x3 strip)
        b = 4 if k == 'hand' else 3
        bx = (W - b) // 2 + (1 if outer_right else -1) * 0
        by = H // 2 - b // 2
        cv.rect(bx, by, bx + b - 1, by + b - 1, INK)
        cv.rect(bx + 1, by + 1, bx + b - 2, by + b - 2, GOLD)
        if b == 4:
            cv.set(bx + 1, by + 1, WHITE)
        return cv.image()
    if kind == 'knob':
        knob_peg(cv, fam, P, A, x0)
    else:
        hole_cavity(cv, fam, P, A, x0 + (1 if k == 'hand' else 1))
    return cv.image()


# ---------------------------------------------------------------- frame overlays
def frame_me(k):
    W, H = (96, 68) if k == 'hand' else (56, 40)
    cv = Cv(W, H)
    c0 = 4 if k == 'hand' else 3
    for x in range(c0, W - c0):
        for top in (True, False):
            def yy(d):
                return d if top else H - 1 - d
            cv.set(x, yy(0), CREAM)
            cv.set(x, yy(1), INK)
            if (x % 3) < 2:
                cv.set(x, yy(2), CREAM)
    # corner arcs
    for d in range(1, c0):
        for top in (True, False):
            y = d - 1 if top else H - d
            cv.set(c0 - d, y, CREAM) if False else None
    return cv.image()


def frame_foe(k):
    W, H = (96, 68) if k == 'hand' else (56, 40)
    cv = Cv(W, H)
    per = 8 if k == 'hand' else 6
    hts = [1, 2, 3, 4, 4, 3, 2, 1] if k == 'hand' else [1, 2, 3, 3, 2, 1]
    c0 = 4 if k == 'hand' else 3
    thorn, tip = INK, (150, 52, 28)
    for x in range(c0, W - c0):
        h = hts[(x - c0) % per]
        for top in (True, False):
            for d in range(0, h + 1):
                y = d if top else H - 1 - d
                cv.set(x, y, tip if (d == h and h >= 2) else thorn)
            # second ink row to make the whole edge dark
            cv.set(x, 1 if top else H - 2, thorn)
    return cv.image()


def frame_picked():
    W, H = 100, 72
    cv = Cv(W, H)
    # gold glow ring (2px) around a 96x68 tile placed at (2,2); bottom = drop shadow
    for y in range(H):
        for x in range(W):
            inner = in_rr(x - 2, y - 2, 96, 68, 4)
            outer = in_rr(x, y, 100, 72, 6)
            if outer and not inner:
                if y >= 70 or (y >= 66 and x > 4 and x < 95 and False):
                    cv.set(x, y, INK)
                else:
                    ring2 = not in_rr(x - 1, y - 1, 98, 70, 5)
                    cv.set(x, y, (255, 224, 138) if ring2 else GOLD)
    return cv.image()


# ---------------------------------------------------------------- icons
def mk_icon_canvas(S):
    return Image.new('RGBA', (S, S), (0, 0, 0, 0))


def finish_icon(im, halo=True, gloss=None):
    S = im.size[0]
    px = im.load()
    solid = [[px[x, y][3] > 0 for x in range(S)] for y in range(S)]

    def sd(x, y):
        return 0 <= x < S and 0 <= y < S and solid[y][x]
    out = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    po = out.load()
    for y in range(S):
        for x in range(S):
            if not solid[y][x]:
                continue
            c = px[x, y][:3]
            l_out = not sd(x - 1, y) or not sd(x, y - 1)
            r_out = not sd(x + 1, y) or not sd(x, y + 1)
            thick_l = sd(x + 1, y) and sd(x, y + 1)
            thick_r = sd(x - 1, y) and sd(x, y - 1)
            if r_out and thick_r:
                c = dark_of(c)
            elif l_out and thick_l:
                c = light_of(c)
            po[x, y] = (c[0], c[1], c[2], 255)
    if gloss:
        for (gx, gy) in gloss:
            if sd(gx, gy):
                po[gx, gy] = WHITE + (255,)
    # outline
    ol = [[False] * S for _ in range(S)]
    for y in range(S):
        for x in range(S):
            if not solid[y][x] and any(sd(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                ol[y][x] = True
                po[x, y] = INK + (255,)
    if halo:
        snap = [[po[x, y][3] > 0 for x in range(S)] for y in range(S)]
        for y in range(S):
            for x in range(S):
                if not snap[y][x] and any(snap[y + dy][x + dx] if (0 <= x + dx < S and 0 <= y + dy < S) else False for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1))):
                    po[x, y] = CREAM + (255,)
        return out
    if False:
        for y in range(S):
            for x in range(S):
                if po[x, y][3] == 0 and any(0 <= x + dx < S and 0 <= y + dy < S and po[x + dx, y + dy][3] > 0
                                            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1))):
                    po[x, y] = CREAM + (255,)
    return out


def D(im):
    return ImageDraw.Draw(im)


def ico_hurt(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['hurt']
    if S == 32:
        for a in (2, 9, 16):
            d.polygon([(a, 2), (a + 6, 2), (a + 9, 12), (a + 12, 28), (a + 7, 16), (a + 3, 8)], fill=b)
            d.line([(a + 1, 3), (a + 7, 17)], fill=(255, 190, 120))
        g = [(3, 3), (4, 3)]
    else:
        for a in (1, 6, 11):
            d.polygon([(a, 1), (a + 4, 1), (a + 6, 8), (a + 7, 17), (a + 4, 10), (a + 1, 5)], fill=b)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_guard(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['guard']
    leaf = (120, 200, 90)
    if S == 32:
        d.polygon([(4, 4), (16, 2), (28, 4), (28, 16), (22, 24), (16, 29), (10, 24), (4, 16)], fill=b)
        d.polygon([(16, 8), (22, 15), (16, 25), (10, 15)], fill=CREAM)
        d.line([(16, 10), (16, 24)], fill=dark_of(b), width=1)
        d.line([(16, 15), (19, 13)], fill=dark_of(b))
        d.line([(16, 18), (13, 16)], fill=dark_of(b))
        d.line([(16, 20), (19, 18)], fill=dark_of(b))
        g = [(7, 6), (7, 7), (8, 6)]
    else:
        d.polygon([(2, 2), (10, 1), (18, 2), (18, 10), (14, 15), (10, 18), (6, 15), (2, 10)], fill=b)
        d.polygon([(10, 5), (13, 9), (10, 15), (7, 9)], fill=CREAM)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_heal(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['heal']
    if S == 32:
        d.ellipse([3, 4, 16, 17], fill=b)
        d.ellipse([15, 4, 28, 17], fill=b)
        d.polygon([(4, 13), (27, 13), (15.5, 28)], fill=b)
        d.rectangle([14, 9, 17, 20], fill=CREAM)
        d.rectangle([10, 13, 21, 16], fill=CREAM)
        g = [(7, 7), (7, 8), (8, 7)]
    else:
        d.ellipse([1, 2, 10, 11], fill=b)
        d.ellipse([9, 2, 18, 11], fill=b)
        d.polygon([(2, 8), (17, 8), (9.5, 18)], fill=b)
        d.rectangle([9, 5, 10, 12], fill=CREAM)
        d.rectangle([6, 7, 13, 8], fill=CREAM)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_charm(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['charm']
    leafc = (40, 150, 80)
    if S == 32:
        cx, cy = 16, 13
        d.rectangle([15, 22, 16, 29], fill=leafc)
        d.polygon([(16, 27), (22, 23), (22, 28)], fill=leafc)
        for a in range(5):
            an = math.radians(-90 + 72 * a)
            d.ellipse([cx + 7.5 * math.cos(an) - 5.2, cy + 7.5 * math.sin(an) - 5.2,
                       cx + 7.5 * math.cos(an) + 5.2, cy + 7.5 * math.sin(an) + 5.2], fill=b)
        d.ellipse([cx - 4.5, cy - 4.5, cx + 4.5, cy + 4.5], fill=GOLD)
        g = [(12, 5), (12, 6), (13, 5)]
    else:
        cx, cy = 10, 8
        d.rectangle([9, 14, 10, 18], fill=leafc)
        for a in range(5):
            an = math.radians(-90 + 72 * a)
            d.ellipse([cx + 4.6 * math.cos(an) - 3.1, cy + 4.6 * math.sin(an) - 3.1,
                       cx + 4.6 * math.cos(an) + 3.1, cy + 4.6 * math.sin(an) + 3.1], fill=b)
        d.ellipse([cx - 2.6, cy - 2.6, cx + 2.6, cy + 2.6], fill=GOLD)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_soothe(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['soothe']
    body_c = (244, 240, 226)
    beak = (230, 140, 30)
    if S == 32:
        d.polygon([(10, 16), (3, 21), (3, 24), (11, 21)], fill=body_c)         # tail
        d.ellipse([8, 12, 25, 24], fill=body_c)                                  # body
        d.ellipse([20, 7, 28, 15], fill=body_c)                                  # head
        d.polygon([(27, 10), (30, 12), (27, 13)], fill=beak)                     # beak
        d.polygon([(10, 15), (7, 5), (13, 3), (20, 9), (22, 17)], fill=b)        # wing
        d.polygon([(11, 14), (9, 7), (12, 6), (16, 11)], fill=light_of(b))
        d.rectangle([24, 10, 24, 10], fill=INK)                                  # eye
        g = [(13, 18), (14, 18)]
    else:
        d.polygon([(5, 10), (1, 13), (1, 15), (6, 13)], fill=body_c)
        d.ellipse([4, 8, 15, 15], fill=body_c)
        d.ellipse([12, 4, 18, 10], fill=body_c)
        d.polygon([(17, 6), (19, 7), (17, 8)], fill=beak)
        d.polygon([(6, 10), (4, 3), (8, 2), (13, 6), (13, 11)], fill=b)
        d.point((15, 6), fill=INK)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_trick(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['trick']
    fe = (30, 150, 130)
    if S == 32:
        d.polygon([(21, 9), (28, 1), (30, 3), (26, 12), (23, 12)], fill=fe)       # feather
        d.polygon([(2, 12), (8, 9), (16, 11), (24, 9), (29, 12), (28, 20), (21, 25), (16, 22), (11, 25), (4, 20)], fill=b)
        for (x0, x1) in ((6, 13), (18, 25)):                                       # eye holes (transparent)
            for y in range(13, 19):
                for x in range(x0, x1 + 1):
                    cx = (x0 + x1) / 2
                    if abs(x - cx) / ((x1 - x0) / 2 + .5) + abs(y - 15.5) / 3.2 <= 1.25:
                        im.putpixel((x, y), (0, 0, 0, 0))
        g = [(6, 11), (7, 11)]
    else:
        d.polygon([(13, 5), (18, 1), (19, 2), (16, 7)], fill=fe)
        d.polygon([(1, 7), (5, 6), (10, 7), (14, 6), (18, 8), (17, 13), (12, 15), (10, 13), (7, 15), (2, 13)], fill=b)
        for (x0, x1) in ((3, 6), (12, 15)):
            for y in (9, 10):
                for x in range(x0, x1 + 1):
                    im.putpixel((x, y), (0, 0, 0, 0))
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


def ico_item(S):
    im = mk_icon_canvas(S)
    d = D(im)
    b = TYPES['item']
    cork = (150, 100, 60)
    if S == 32:
        d.rectangle([9, 3, 22, 8], fill=cork)                                      # lid
        d.rectangle([10, 8, 21, 11], fill=b)                                       # neck
        d.rounded_rectangle([5, 11, 26, 29], radius=4, fill=b)                     # jar
        d.rectangle([9, 17, 22, 25], fill=CREAM)                                   # label
        d.polygon([(15.5, 18), (17, 21), (20, 21), (17.5, 23), (18.5, 25), (15.5, 23.5), (12.5, 25), (13.5, 23), (11, 21), (14, 21)], fill=GOLD)
        g = [(7, 14), (7, 15), (7, 16)]
    else:
        d.rectangle([6, 1, 13, 4], fill=cork)
        d.rectangle([7, 4, 12, 6], fill=b)
        d.rounded_rectangle([3, 6, 16, 18], radius=3, fill=b)
        d.rectangle([6, 10, 13, 15], fill=CREAM)
        d.point((9, 12), fill=GOLD)
        d.point((10, 12), fill=GOLD)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


ICONS = {'hurt': ico_hurt, 'guard': ico_guard, 'heal': ico_heal, 'charm': ico_charm,
         'soothe': ico_soothe, 'trick': ico_trick, 'item': ico_item}


# ---------------------------------------------------------------- main
def build(out):
    os.makedirs(out, exist_ok=True)
    made = {}

    def save(name, im, exp):
        assert im.size == exp, (name, im.size, exp)
        im.save(os.path.join(out, name))
        made[name] = im.size
    for t in TYPES:
        save('tile-hand-%s.png' % t, body(t, 'hand'), (96, 68))
        save('tile-strip-%s.png' % t, body(t, 'strip'), (56, 40))
        save('ico-%s.png' % t, ICONS[t](32), (32, 32))
        save('ico-%s-s.png' % t, ICONS[t](20), (20, 20))
    for k, sz in (('hand', (20, 68)), ('strip', (12, 40))):
        for fam in FAMS + ['flat']:
            for kind in ('knob', 'hole'):
                save('sock-%s-%s-%s.png' % (k, fam, kind), sock(k, fam, kind), sz)
    save('frame-me-hand.png', frame_me('hand'), (96, 68))
    save('frame-me-strip.png', frame_me('strip'), (56, 40))
    save('frame-foe-hand.png', frame_foe('hand'), (96, 68))
    save('frame-foe-strip.png', frame_foe('strip'), (56, 40))
    save('frame-picked-hand.png', frame_picked(), (100, 72))
    return made


if __name__ == '__main__':
    m = build(sys.argv[1])
    print(len(m), 'files')
