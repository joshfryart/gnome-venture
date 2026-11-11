#!/usr/bin/env python3
"""Copied unchanged from mockups/r2/r2-m11c/base_icons.py for gen4.py (patterns, 32 px icons, font, colours).
Import only: do not run this file here (its __main__ writes the old m11 sheets).

m11-fable mockup: "Quilted felt jigsaw".

Each tile is a die-cut felt jigsaw piece: a locking knob (narrow neck, wide head) sticks OUT of the right,
the exact same shape is cut INTO the left. Mine = cream piping with gold thread; foe = black bramble band
with a saw-cut top/bottom edge. Type = hue + quilt pattern + icon. Family = knob/hole silhouette only.

Canvas of one piece = (W + P) x H. Body is x 0..W-1, knob is x W..W+P-1, hole eats the first P+1 px.
Snap pieces at a pitch of W-1 px (the 1 px ink outlines are shared), earlier piece drawn on top.

Run: python3 gen.py   (writes sheet.png, cream.png, gray-sheet.png, gray-cream.png next to this file)
"""
import math
import os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
INK = (0x2a, 0x1a, 0x10)
CREAM = (0xf2, 0xe4, 0xc0)
GOLD = (0xe8, 0xa3, 0x17)
FELT = (0x3d, 0x2a, 0x1c)
FELT_SH = (0x2b, 0x1c, 0x12)
CREAM_SH = (0xd2, 0xbf, 0x94)
CREAM_D = (0xc9, 0xb4, 0x86)


def hx(s):
    return tuple(int(s[i:i + 2], 16) for i in (1, 3, 5))


# base, pattern mark, bevel light, bevel shade
TYPES = {
    'hurt':   dict(base=hx('#d55e00'), mark=hx('#9c3608'), light=hx('#f08a3c'), shade=hx('#8a2c0a')),
    'guard':  dict(base=hx('#00639e'), mark=hx('#3f9bd0'), light=hx('#3f9bd0'), shade=hx('#0a3d6e')),
    'heal':   dict(base=hx('#009e73'), mark=hx('#7fe0b4'), light=hx('#4cc79a'), shade=hx('#066a55')),
    'charm':  dict(base=hx('#cc79a7'), mark=hx('#9a4a7c'), light=hx('#eaa6c8'), shade=hx('#8a3f70')),
    'soothe': dict(base=hx('#62bcee'), mark=hx('#d8f1fb'), light=hx('#a4dcf8'), shade=hx('#2f84bd')),
    'trick':  dict(base=hx('#f0e442'), mark=hx('#d2bd1e'), light=hx('#fbf5a0'), shade=hx('#a8860e')),
    'item':   dict(base=hx('#e69f00'), mark=hx('#b06a08'), light=hx('#f8c552'), shade=hx('#a05c08')),
}
ORDER = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item']
FAMS = ['body', 'mind', 'craft']

GEO = {
    'hand': dict(W=96, H=68, P=20, R=6, rim=2, icon=32, ix=45, iy=6, tag=(6, 5, 14, 12), name=(24, 47, 64, 14)),
    'strip': dict(W=56, H=40, P=11, R=4, rim=1, icon=20, ix=26, iy=11, tag=(4, 3, 12, 10), name=None),
}


# ---------------------------------------------------------------- socket shapes
def in_knob(fam, size, d, dy):
    """d = px out from the body's last column (pixel centre), dy = offset from the centre line."""
    a = abs(dy)
    if size == 'hand':
        if fam == 'body':      # lollipop: neck + big round head
            return (d < 7 and a <= 4.0) or (d - 11.5) ** 2 + dy * dy <= 8.6 ** 2
        if fam == 'mind':      # keyhole on its side: stem, round eye, then a slot that flares to a flat end
            if (d - 6.5) ** 2 + dy * dy <= 6.7 ** 2:
                return True
            return 12 <= d <= 20 and a <= 3.2 + (d - 12) * 0.66
        if fam == 'craft':     # arrowhead: neck + triangle, point outward
            if d < 5 and a <= 3.5:
                return True
            return 4.5 <= d <= 20 and a <= (20.6 - d) * 0.82
    else:
        if fam == 'body':
            return (d < 4 and a <= 2.0) or (d - 6.5) ** 2 + dy * dy <= 4.7 ** 2
        if fam == 'mind':
            if (d - 4.0) ** 2 + dy * dy <= 4.2 ** 2:
                return True
            return 7 <= d <= 11 and a <= 2.2 + (d - 7) * 1.0
        if fam == 'craft':
            if d < 3 and a <= 2.0:
                return True
            return 2.5 <= d <= 11 and a <= (11.6 - d) * 0.86
    return False


def body_mask(size, foe):
    g = GEO[size]
    W, H, P, R = g['W'], g['H'], g['P'], g['R']
    m = [[False] * (W + P) for _ in range(H)]
    for y in range(H):
        for x in range(W):
            # rounded corners
            cx = R - .5 if x < R else (W - R - .5 if x >= W - R else None)
            cy = R - .5 if y < R else (H - R - .5 if y >= H - R else None)
            ok = True
            if cx is not None and cy is not None:
                ok = (x - cx) ** 2 + (y - cy) ** 2 <= (R - .2) ** 2
            # a hair off-square: top and bottom edges sag 1 px toward the corners
            sag = 0
            if foe and ok:
                # saw-cut top and bottom edge (thorns)
                per = 8 if size == 'hand' else 6
                dep = [0, 1, 2, 3, 2, 1, 0, 0] if size == 'hand' else [0, 1, 2, 1, 0, 0]
                if R + 1 <= x < W - R - 1:
                    n = dep[(x - R) % per]
                    if y < n + sag or y > H - 1 - n:
                        ok = False
            m[y][x] = ok
    return m


def erode4(m):
    H, W = len(m), len(m[0])
    return [[m[y][x] and 0 < x < W - 1 and 0 < y < H - 1 and m[y][x - 1] and m[y][x + 1] and m[y - 1][x] and m[y + 1][x]
             for x in range(W)] for y in range(H)]


def erode8(m):
    H, W = len(m), len(m[0])
    return [[m[y][x] and 0 < x < W - 1 and 0 < y < H - 1 and all(m[y + j][x + i] for j in (-1, 0, 1) for i in (-1, 0, 1))
             for x in range(W)] for y in range(H)]


_mask_cache = {}


def piece_mask(size, hole, knob, foe):
    key = (size, hole, knob, foe)
    if key in _mask_cache:
        return _mask_cache[key]
    g = GEO[size]
    W, H, P = g['W'], g['H'], g['P']
    cy = (H - 1) / 2.0
    m = body_mask(size, foe)
    if knob != 'flat':
        for y in range(H):
            for d in range(0, P + 1):
                if in_knob(knob, size, d, y - cy):
                    m[y][W - 1 + d] = True
    if hole != 'flat':
        # the hole is the INTERIOR of the matching knob (so the two ink outlines land on the same pixels)
        k = body_mask(size, False)
        for y in range(H):
            for d in range(0, P + 1):
                if in_knob(hole, size, d, y - cy):
                    k[y][W - 1 + d] = True
        ki = erode4(k)
        for y in range(H):
            for d in range(0, P + 1):
                if ki[y][W - 1 + d]:
                    m[y][d] = False
    _mask_cache[key] = m
    return m


def dist_map(m, maxd=8):
    """ring index from the outside: 0 = outline pixel. Alternates 4/8 erosion for roundish bands."""
    H, W = len(m), len(m[0])
    d = [[-1] * W for _ in range(H)]
    cur = m
    for i in range(maxd):
        nxt = erode4(cur) if i % 2 == 0 else erode8(cur)
        for y in range(H):
            for x in range(W):
                if cur[y][x] and not nxt[y][x]:
                    d[y][x] = i
        cur = nxt
    for y in range(H):
        for x in range(W):
            if cur[y][x]:
                d[y][x] = maxd
    return d


def walk_ring(pts):
    """order a 1px-ish ring of pixels into paths so we can dash along it."""
    left = set(pts)
    paths = []
    while left:
        start = min(left, key=lambda p: (p[1], p[0]))
        left.discard(start)
        path = [start]
        cur = start
        while True:
            nx = None
            for dx, dy in ((1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)):
                q = (cur[0] + dx, cur[1] + dy)
                if q in left:
                    nx = q
                    break
            if nx is None:
                break
            left.discard(nx)
            path.append(nx)
            cur = nx
        paths.append(path)
    return paths


# ---------------------------------------------------------------- fill patterns
HEART5 = [".#.#.", "#####", "#####", ".###.", "..#.."]
HEART3 = ["#.#", "###", ".#."]


def pat(t, size, x, y):
    hand = size == 'hand'
    if t == 'hurt':        # slash stripes, broken so they read as claw rips
        p = 9 if hand else 6
        w = 3 if hand else 2
        s = (x + y) % p
        gap = ((x - y) % (p * 4)) < (3 if hand else 2)
        return s < w and not gap
    if t == 'guard':       # brick wall, light mortar
        bh, bw = (7, 14) if hand else (5, 10)
        row = y // bh
        return y % bh == 0 or (x + (row % 2) * (bw // 2)) % bw == 0
    if t == 'heal':        # polka dots
        p = 8 if hand else 6
        xx = x + ((y // p) % 2) * (p // 2)
        if hand:
            return (xx % p) in (1, 2) and (y % p) in (1, 2)
        return (xx % p) == 1 and (y % p) in (1, 2) or (xx % p) in (0, 2) and False
    if t == 'charm':       # scattered hearts
        bm, pw, ph = (HEART5, 12, 9) if hand else (HEART3, 8, 6)
        xx = x + ((y // ph) % 2) * (pw // 2)
        u, v = xx % pw, y % ph
        return v < len(bm) and u < len(bm[0]) and bm[v][u] == '#'
    if t == 'soothe':      # calm waves
        per, gap, amp = (12, 7, 1.6) if hand else (8, 5, 1.0)
        off = int(round(amp * math.sin(x * 2 * math.pi / per)))
        return (y + off) % gap == 0
    if t == 'trick':       # harlequin diamonds
        q = 8 if hand else 5
        return ((x + y) // q + (x - y) // q) % 2 == 0
    if t == 'item':        # crate planks with nail heads
        pw = 11 if hand else 8
        if x % pw == 0:
            return True
        nail = (x % pw) == pw // 2 and (y % (12 if hand else 9)) == 3
        return nail
    return False


# ---------------------------------------------------------------- icons
def _icon_canvas(s):
    return Image.new('RGBA', (s, s), (0, 0, 0, 0))


def finish_icon(im):
    """add 1px ink outline around the drawn silhouette, then a 1px cream halo."""
    s = im.size[0]
    px = im.load()
    op = [[px[x, y][3] > 0 for x in range(s)] for y in range(s)]

    def grow(mask, col, diag):
        add = []
        for y in range(s):
            for x in range(s):
                if mask[y][x]:
                    continue
                nb = ((1, 0), (-1, 0), (0, 1), (0, -1)) + (((1, 1), (-1, 1), (1, -1), (-1, -1)) if diag else ())
                for dx, dy in nb:
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < s and 0 <= yy < s and mask[yy][xx]:
                        add.append((x, y))
                        break
        for x, y in add:
            px[x, y] = col + (255,)
            mask[y][x] = True
    grow(op, INK, False)
    grow(op, CREAM, True)
    return im


WHITE = (0xff, 0xf8, 0xe6)


def icon(t, s):
    big = s >= 32
    im = _icon_canvas(s)
    d = ImageDraw.Draw(im)
    k = (s - 4) / 28.0   # hand coords are authored on a 28 box, offset 2

    def P(pts):
        return [(2 + x * k, 2 + y * k) for x, y in pts]

    def poly(pts, col):
        d.polygon(P(pts), fill=col + (255,))

    def ell(x0, y0, x1, y1, col):
        d.ellipse([2 + x0 * k, 2 + y0 * k, 2 + x1 * k, 2 + y1 * k], fill=col + (255,))

    def line(pts, col, w=1):
        d.line(P(pts), fill=col + (255,), width=w)

    def dot(x, y, col):
        im.putpixel((int(round(2 + x * k)), int(round(2 + y * k))), col + (255,))

    if t == 'hurt':        # three claw rips, fat at the top, hooked to a point
        bone, tip = WHITE, hx('#ffc24a')
        for i, (ox, oy) in enumerate(((0, 3), (8.5, 0), (17, 3))):
            poly([(ox + 6, oy + 0), (ox + 10, oy + 1), (ox + 9.5, oy + 9), (ox + 6.5, oy + 17), (ox + 1.5, oy + 23.5),
                  (ox + 0.5, oy + 22), (ox + 3.5, oy + 15), (ox + 4.5, oy + 7)], bone)
            poly([(ox + 3.4, oy + 17), (ox + 6.3, oy + 17.5), (ox + 1.5, oy + 23.5), (ox + 0.5, oy + 22)], tip)
    elif t == 'guard':     # leaf-shield: heater shield with a leaf point and veins
        leaf, dk, lt = hx('#8ed04a'), hx('#3f7d1e'), hx('#d6f08a')
        poly([(14, 0), (20, 3), (26, 3.5), (26, 13), (22, 21), (14, 27.5), (6, 21), (2, 13), (2, 3.5), (8, 3)], leaf)
        poly([(14, 0), (20, 3), (26, 3.5), (26, 13), (22, 21), (14, 27.5)], dk)      # shaded right half
        poly([(14, 2.5), (19.5, 5), (23.5, 5.5), (23.5, 12.5), (20, 19.5), (14, 24.5)], hx('#5aa62e'))
        line([(14, 3), (14, 25)], INK)
        if big:
            for yy in (9, 14, 19):
                line([(14, yy), (9, yy - 4)], dk)
                line([(14, yy), (19, yy - 4)], INK)
            line([(4.5, 6), (4.5, 12)], lt)
        else:
            line([(14, 13), (8, 8)], dk)
            line([(14, 13), (20, 8)], INK)
    elif t == 'heal':      # heart with a two-leaf herb sprout
        hrt, lt, lf = hx('#b9f5cf'), WHITE, hx('#d6f08a')
        ell(0, 2, 15, 17, hrt)
        ell(13, 2, 28, 17, hrt)
        poly([(0.8, 12), (27.2, 12), (14, 27.5)], hrt)
        poly([(2.5, 15), (25.5, 15), (14, 27)], hrt)
        poly([(14, 27.5), (27.2, 12), (27, 9), (22, 17), (14, 24)], hx('#6fd3a0'))     # lower-right shade
        gc = hx('#0f7f58')
        if big:
            ell(3.5, 5, 8, 9.5, lt)
            poly([(12, 8), (16, 8), (16, 21), (12, 21)], gc)
            poly([(7.5, 12.5), (20.5, 12.5), (20.5, 16.5), (7.5, 16.5)], gc)
        else:
            poly([(12.4, 8), (15.6, 8), (15.6, 21), (12.4, 21)], gc)
            poly([(8, 12.6), (20.5, 12.6), (20.5, 15.8), (8, 15.8)], gc)
    elif t == 'charm':     # five-petal flower
        pet, pd, ctr = WHITE, hx('#ffb3d2'), GOLD
        cx, cy, r, pr = 14, 14, 8.2, 5.6
        for i in range(5):
            a = -math.pi / 2 + i * 2 * math.pi / 5
            px_, py_ = cx + r * math.cos(a), cy + r * math.sin(a)
            ell(px_ - pr, py_ - pr, px_ + pr, py_ + pr, pet)
        for i in range(5):
            a = -math.pi / 2 + i * 2 * math.pi / 5
            px_, py_ = cx + (r - 2.2) * math.cos(a), cy + (r - 2.2) * math.sin(a)
            q = 2.6 if big else 2.2
            ell(px_ - q, py_ - q, px_ + q, py_ + q, pd)
        ell(cx - 4, cy - 4, cx + 4, cy + 4, INK)
        ell(cx - 3, cy - 3, cx + 3, cy + 3, ctr)
        if big:
            dot(13, 13, WHITE)
    elif t == 'soothe':    # dove gliding left, wing up, olive twig
        w, sh = WHITE, hx('#b8cfe0')
        poly([(3, 12), (7, 9), (12, 10), (20, 14), (27.5, 12), (25, 17.5), (27, 21), (20, 20.5), (13, 23), (7, 20), (4, 15.5)], w)  # body+tail
        ell(1.5, 8.5, 9, 15.5, w)                                                   # head
        poly([(10, 11), (13, 1), (19, 0.5), (23, 3.5), (21, 9), (19, 14)], w)      # raised wing
        poly([(12, 16), (20, 15), (25, 17.5), (27, 21), (20, 20.5), (13, 23)], sh)  # belly shade
        poly([(1.8, 12), (-1.5, 13.3), (2, 14.2)], GOLD)                             # beak
        if big:
            line([(14, 4), (16.5, 9.5)], sh)
            line([(17.5, 3), (19, 9)], sh)
            dot(5, 11.2, INK)
            line([(-1, 15), (-1.5, 19)], hx('#3f7d1e'))
            poly([(-1.5, 17), (-2, 20), (0.5, 21)], hx('#8ed04a'))
        else:
            dot(5.2, 11.5, INK)
            line([(15.5, 4), (17, 10)], sh)
    elif t == 'trick':     # domino mask with a feather
        mk, md, ml, fe, fd = hx('#7a48a8'), hx('#4a2a6c'), hx('#b48ad8'), hx('#e0452c'), hx('#8f1f14')
        # feather first (behind the mask), sweeping up from the right brow
        poly([(19, 12), (17.5, 6), (19.5, 1), (24, -1.5), (27.5, 1), (27, 6), (24, 12)], fe)
        line([(21, 12), (25, 0)], fd)
        # cat-eye domino mask
        poly([(-1, 9), (4, 11.5), (10, 11), (14, 13), (18, 11), (24, 11.5), (29, 9), (28.5, 17), (25, 23), (19, 25),
              (15.5, 21.5), (14, 19), (12.5, 21.5), (9, 25), (3, 23), (-0.5, 17)], mk)
        poly([(-0.5, 17), (3, 21), (9, 23), (12.5, 19.5), (14, 17), (15.5, 19.5), (19, 23), (25, 21), (28.5, 17), (25, 23),
              (19, 25), (15.5, 21.5), (14, 19), (12.5, 21.5), (9, 25), (3, 23)], md)
        # eye holes
        poly([(3.5, 16.5), (7, 14), (11.5, 15.5), (10.5, 18.5), (6.5, 19.5)], INK)
        poly([(16.5, 15.5), (21, 14), (24.5, 16.5), (21.5, 19.5), (17.5, 18.5)], INK)
        if big:
            line([(22.5, 6.5), (26, 5.5)], fd)
            line([(21.5, 9.5), (25, 9)], fd)
            line([(3, 12.5), (9.5, 12.5)], ml)
            line([(18.5, 12.5), (24, 12.8)], ml)
            dot(14, 15.5, GOLD)
    elif t == 'item':      # jam jar with a tied cloth lid
        gl, jam, jd, lid, tie = hx('#dff3f2'), hx('#b3262e'), hx('#7a141f'), WHITE, hx('#2f84bd')
        poly([(5, 9), (23, 9), (25, 12), (25, 25), (23, 27.5), (5, 27.5), (3, 25), (3, 12)], gl)        # glass
        poly([(5, 14), (23, 14), (23, 25), (22, 26), (6, 26), (5, 25)], jam)                            # jam
        poly([(17, 14), (23, 14), (23, 25), (22, 26), (17, 26)], jd)
        poly([(4, 2.5), (8, 0), (20, 0), (24, 2.5), (26, 8), (22.5, 6.5), (19, 9), (14, 7), (9, 9), (5.5, 6.5), (2, 8)], lid)  # cloth
        poly([(5.5, 5.5), (22.5, 5.5), (22.5, 7.2), (5.5, 7.2)], tie)                                   # string
        if big:
            poly([(9, 17), (19, 17), (19, 23), (9, 23)], WHITE)                                         # label
            poly([(12, 19), (16, 19), (16, 21), (12, 21)], jam)
            line([(6, 12), (6, 13)], WHITE)
            dot(11, 2.5, tie)
            dot(17, 2.5, tie)
        else:
            poly([(9, 17.5), (15, 17.5), (15, 22.5), (9, 22.5)], WHITE)
    return finish_icon(im)


# ---------------------------------------------------------------- piece renderer
def render_piece(t, size, hole, knob, foe=False):
    g = GEO[size]
    W, H, P = g['W'], g['H'], g['P']
    c = TYPES[t]
    m = piece_mask(size, hole, knob, foe)
    dm = dist_map(m)
    rim = g['rim']                 # piping thickness (rings 1..rim)
    im = Image.new('RGBA', (W + P, H), (0, 0, 0, 0))
    px = im.load()
    fill0 = rim + 1                # first ring of felt
    F = [[dm[y][x] >= fill0 for x in range(W + P)] for y in range(H)]

    def inF(x, y):
        return 0 <= x < W + P and 0 <= y < H and F[y][x]

    tx, ty, tw, th = g['tag']
    for y in range(H):
        for x in range(W + P):
            r = dm[y][x]
            if r < 0:
                continue
            if r == 0:
                col = INK
            elif r <= rim:
                col = INK if foe else CREAM
            else:
                col = c['mark'] if pat(t, size, x, y) else c['base']
                # bevel: rim light top-left, cel shade lower-right
                sh = (2 if size == 'hand' else 1)
                if not inF(x + 1, y) or not inF(x, y + 1) or (sh == 2 and (not inF(x + 2, y) or not inF(x, y + 2) or not inF(x + 1, y + 1))):
                    col = c['shade']
                elif not inF(x - 1, y) or not inF(x, y - 1):
                    col = c['light']
            px[x, y] = col + (255,)

    # edge treatment
    if not foe:
        # gold thread dashes along the middle of the cream piping
        ring = [(x, y) for y in range(H) for x in range(W + P) if dm[y][x] == rim]
        on, off = (3, 2) if size == 'hand' else (2, 2)
        for path in walk_ring(ring):
            if len(path) < 6:
                continue
            for i, (x, y) in enumerate(path):
                if i % (on + off) < on:
                    px[x, y] = GOLD + (255,)
    else:
        # bramble: inward thorns from the black band, plus a dull bone fleck line so it is not just "thicker"
        ring = [(x, y) for y in range(H) for x in range(W + P) if dm[y][x] == rim + 1]
        ring2 = set((x, y) for y in range(H) for x in range(W + P) if dm[y][x] == rim + 2)
        per = 5 if size == 'hand' else 4
        for path in walk_ring(ring):
            if len(path) < 6:
                continue
            for i, (x, y) in enumerate(path):
                ph = i % per
                if x >= W - 2 or (x <= P + 4 and abs(y - (H - 1) / 2.0) < P * .62):
                    continue        # keep the sockets clean so the family shape stays readable
                if ph in (0, 1, 2) if size == 'hand' else ph in (0, 1):
                    px[x, y] = INK + (255,)
                if ph == 1:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        if (x + dx, y + dy) in ring2:
                            px[x + dx, y + dy] = INK + (255,)
                            break
        # pale thorn glints inside the band
        mid = [(x, y) for y in range(H) for x in range(W + P) if dm[y][x] == 1]
        for path in walk_ring(mid):
            if len(path) < 6:
                continue
            for i, (x, y) in enumerate(path):
                if i % (per * 2) == 1 and size == 'hand':
                    px[x, y] = hx('#8a6a4a') + (255,)

    # number tag: a calm cream label sewn in the top-left corner
    d = ImageDraw.Draw(im)
    d.rectangle([tx - 1, ty - 1, tx + tw, ty + th], fill=INK + (255,))
    d.rectangle([tx, ty, tx + tw - 1, ty + th - 1], fill=CREAM + (255,))
    for cxy in ((tx - 1, ty - 1), (tx + tw, ty - 1), (tx - 1, ty + th), (tx + tw, ty + th)):
        px[cxy] = (c['shade'] if not foe else INK) + (255,)
    if foe:
        d.rectangle([tx, ty, tx + tw - 1, ty + th - 1], fill=CREAM_D + (255,))

    # name ribbon (hand only): cream swallow-tail label, code prints the name on it
    if g['name']:
        nx, ny, nw, nh = g['name']
        d.rectangle([nx - 1, ny - 1, nx + nw, ny + nh], fill=INK + (255,))
        d.rectangle([nx, ny, nx + nw - 1, ny + nh - 1], fill=(CREAM_D if foe else CREAM) + (255,))
        # swallow-tail notches
        for i in range(4):
            for yy in (ny + nh // 2 - 1 - i + 3, ny + nh // 2 + i - 3):
                pass
        mid = ny + nh // 2
        for i in range(4):
            for yy in range(mid - (3 - i), mid + (3 - i) + 1):
                px[nx + i - 1, yy] = INK + (255,) if (yy in (mid - (3 - i), mid + (3 - i)) or i == 3) else c['base'] + (255,)
                px[nx + nw - i, yy] = INK + (255,) if (yy in (mid - (3 - i), mid + (3 - i)) or i == 3) else c['base'] + (255,)
        # stitch ticks at both ends
        for yy in range(ny + 2, ny + nh - 2, 3):
            px[nx + 5, yy] = GOLD + (255,)
            px[nx + nw - 6, yy] = GOLD + (255,)

    ic = icon(t, g['icon'])
    im.alpha_composite(ic, (g['ix'], g['iy']))
    return im


# ---------------------------------------------------------------- sheet helpers
def shadow_of(im, col):
    sh = Image.new('RGBA', im.size, (0, 0, 0, 0))
    a = im.split()[3]
    sh.paste(col + (255,), (0, 0), a)
    return sh


class Board:
    def __init__(self, w, h, bg, sh):
        self.im = Image.new('RGBA', (w, h), bg + (255,))
        self.sh = sh

    def put(self, piece, x, y, off=2):
        self.im.alpha_composite(shadow_of(piece, self.sh), (x + off, y + off))
        self.im.alpha_composite(piece, (x, y))

    def chain(self, pieces, x, y, W):
        # shadows first, then pieces right-to-left so each knob sits on top of the next piece's hole
        for i, p in enumerate(pieces):
            self.im.alpha_composite(shadow_of(p, self.sh), (x + i * (W - 1) + 2, y + 2))
        for i in reversed(range(len(pieces))):
            self.im.alpha_composite(pieces[i], (x + i * (W - 1), y))


FONT = {
    'A': ["010", "101", "111", "101", "101"], 'B': ["110", "101", "110", "101", "110"], 'C': ["011", "100", "100", "100", "011"],
    'D': ["110", "101", "101", "101", "110"], 'E': ["111", "100", "110", "100", "111"], 'F': ["111", "100", "110", "100", "100"],
    'G': ["011", "100", "101", "101", "011"], 'H': ["101", "101", "111", "101", "101"], 'I': ["111", "010", "010", "010", "111"],
    'K': ["101", "101", "110", "101", "101"], 'L': ["100", "100", "100", "100", "111"], 'M': ["101", "111", "111", "101", "101"],
    'N': ["110", "101", "101", "101", "101"], 'O': ["010", "101", "101", "101", "010"], 'P': ["110", "101", "110", "100", "100"],
    'R': ["110", "101", "110", "101", "101"], 'S': ["011", "100", "010", "001", "110"], 'T': ["111", "010", "010", "010", "010"],
    'U': ["101", "101", "101", "101", "111"], 'W': ["101", "101", "111", "111", "101"], 'Y': ["101", "101", "010", "010", "010"],
    'X': ["101", "101", "010", "101", "101"], 'V': ["101", "101", "101", "101", "010"], ' ': ["000"] * 5, '+': ["000", "010", "111", "010", "000"],
    '4': ["101", "101", "111", "001", "001"], '7': ["111", "001", "010", "010", "010"], '3': ["110", "001", "010", "001", "110"],
}


def text(im, x, y, s, col):
    px = im.load()
    for ch in s.upper():
        g = FONT.get(ch, FONT[' '])
        for j, row in enumerate(g):
            for i, b in enumerate(row):
                if b == '1':
                    px[x + i, y + j] = col + (255,)
        x += 4


def combos():
    # hole, knob per type so every family shows up on real pieces
    return {'hurt': ('flat', 'body'), 'guard': ('body', 'craft'), 'heal': ('craft', 'body'), 'charm': ('body', 'mind'),
            'soothe': ('mind', 'mind'), 'trick': ('mind', 'craft'), 'item': ('craft', 'flat')}


def build_sheet():
    hw, hh, hp = 96, 68, 20
    sw, sh_, sp = 56, 40, 11
    cb = combos()
    Wd, Hd = 500, 596
    b = Board(Wd, Hd, FELT, FELT_SH)
    lab = (0xb8, 0x9a, 0x6a)
    y = 6
    text(b.im, 8, y, 'HAND PIECES', lab)
    y += 9
    for i, t in enumerate(ORDER):
        col, row = i % 4, i // 4
        x = 8 + col * (hw + hp + 6)
        yy = y + row * (hh + 12)
        b.put(render_piece(t, 'hand', *cb[t]), x, yy)
        text(b.im, x + 20, yy + hh + 4, t, lab)
    # foe hand in the 8th slot
    x = 8 + 3 * (hw + hp + 6)
    yy = y + (hh + 12)
    b.put(render_piece('hurt', 'hand', 'mind', 'body', foe=True), x, yy)
    text(b.im, x + 20, yy + hh + 4, 'FOE', lab)
    y += 2 * (hh + 12) + 4

    text(b.im, 8, y, 'STRIP PIECES', lab)
    y += 9
    for i, t in enumerate(ORDER):
        x = 8 + i * (sw + sp + 3)
        b.put(render_piece(t, 'strip', *cb[t]), x, y, off=1)
    y += sh_ + 8
    b.put(render_piece('trick', 'strip', 'craft', 'body', foe=True), 8, y, off=1)
    text(b.im, 8 + sw + 14, y + 16, 'FOE', lab)

    # sockets: knob stub + hole stub, both sizes
    sx = 150
    text(b.im, sx, y - 2, 'SOCKETS  KNOB + HOLE', lab)
    for i, fam in enumerate(FAMS):
        px0 = sx + i * 112
        pa = render_piece('item', 'strip', 'flat', fam).crop((sw - 14, 0, sw + sp, sh_))
        pb = render_piece('soothe', 'strip', fam, 'flat').crop((0, 0, 26, sh_))
        b.put(pa, px0, y + 6, off=1)
        b.put(pb, px0 + 14 + sp + 5, y + 6, off=1)
        text(b.im, px0 + 66, y + 22, {'body': 'BODY', 'mind': 'MIND', 'craft': 'CRAFT'}[fam], lab)
    y += sh_ + 14
    for i, fam in enumerate(FAMS):
        px0 = 8 + i * 160
        pa = render_piece('item', 'hand', 'flat', fam).crop((hw - 30, 0, hw + hp, hh))
        pb = render_piece('soothe', 'hand', fam, 'flat').crop((0, 0, 44, hh))
        b.put(pa, px0, y)
        b.put(pb, px0 + 30 + hp + 8, y)
        text(b.im, px0 + 110, y + 30, {'body': 'BODY', 'mind': 'MIND', 'craft': 'CRAFT'}[fam], lab)
        text(b.im, px0 + 110, y + 38, {'body': 'ROUND', 'mind': 'KEYHOLE', 'craft': 'TRIANGLE'}[fam], lab)
    y += hh + 12

    text(b.im, 8, y, 'SNAPPED CHAIN  HAND', lab)
    y += 9
    ch = [('hurt', 'flat', 'body'), ('heal', 'body', 'mind'), ('trick', 'mind', 'craft'), ('guard', 'craft', 'body')]
    b.chain([render_piece(t, 'hand', h, k) for t, h, k in ch], 8, y, hw)
    y += hh + 12
    text(b.im, 8, y, 'SNAPPED CHAIN  STRIP   MINE + FOE', lab)
    y += 9
    ps = [render_piece('charm', 'strip', 'flat', 'mind'), render_piece('soothe', 'strip', 'mind', 'body'),
          render_piece('hurt', 'strip', 'body', 'craft', foe=True), render_piece('item', 'strip', 'craft', 'body', foe=True)]
    b.chain(ps, 8, y, sw)
    y += sh_ + 8
    return b.im.crop((0, 0, Wd, y)).convert('RGB')


def build_cream():
    hw, hh, hp = 96, 68, 20
    cb = combos()
    b = Board(8 + 4 * (hw + hp + 6), 8 + 2 * (hh + 10), CREAM, CREAM_SH)
    for i, t in enumerate(ORDER):
        col, row = i % 4, i // 4
        b.put(render_piece(t, 'hand', *cb[t]), 8 + col * (hw + hp + 6), 8 + row * (hh + 10))
    return b.im.convert('RGB')


def check_hard(im, name):
    cols = im.getcolors(100000)
    print(name, im.size, 'colours:', len(cols))


if __name__ == '__main__':
    s = build_sheet()
    s.save(os.path.join(HERE, 'sheet.png'))
    c = build_cream()
    c.save(os.path.join(HERE, 'cream.png'))
    s.convert('L').save(os.path.join(HERE, 'gray-sheet.png'))
    c.convert('L').save(os.path.join(HERE, 'gray-cream.png'))
    check_hard(s, 'sheet')
    check_hard(c, 'cream')
