#!/usr/bin/env python3
"""shops_street_kit.py: shared kit for the 480 x 300 Shop Street scene cards (game/assets/img/scenes/here-shops-street-<code>.png),
Stitched Toy redraw.

STAGING ONLY: writes art-review/stopart/out/scenes/here-shops-street-<code>.png and art-review/stopart/out/_cmp/shops-street-<code>.png.
Never touches game/.

The picture keeps the shipped layout (game/includes/data/here_layouts.json 'shops-street'): four tall leaning local houses on the left
(loc-1..4), the clock tower with its little side shop (loc-more), the two-storey Mossbottom arcade on the right (hub-*), street and
stand points in front, horizon at y 96. The shipped regional pictures come in four colour families (warm, teal, blue, purple); each
family keeps its sky, local-house walls and roof felt.

Finish: every felt piece is a flat fill with a 1 px light rim upper-left, a 2 px dark crescent lower-right, one 1 px umber outline,
optional dashed gold/cream thread stitch 3 px inside. No anti-aliasing; opaque scene card (alpha 255 everywhere). numpy + Pillow.
Deterministic.
"""
import math
import os

import numpy as np
from PIL import Image, ImageDraw

ROOT = '/home/user/gnome-venture'
OUT = os.path.join(ROOT, 'art-review/stopart/out/scenes')
CMP = os.path.join(ROOT, 'art-review/stopart/out/_cmp')
SHIP = os.path.join(ROOT, 'game/assets/img/scenes')
W, H = 480, 300
HORIZON = 96

UMBER = '#2a1a10'
UMBER2 = '#4a2c1a'
THREAD = '#e8a317'
CREAM_T = '#fff3c8'

# ramps: (base, dark, light)
STONE = ('#8e8690', '#66606c', '#b0a8b0')
STONE_D = ('#6e6672', '#4e4856', '#8e8690')
PLASTER = ('#ecdcc4', '#c8b498', '#fbf0dc')
WOOD = ('#a06a3a', '#7a4a26', '#c48a52')
WOOD_D = ('#6a4426', '#4a2c1a', '#86583a')
GLASS = ('#f5cf6a', '#d8a03a', '#fde8a0')
GLASS_D = ('#4a4466', '#33304a', '#6a6488')
CLOCK = ('#f4ead0', '#cfc0a0', '#ffffff')
CLOUD = ('#fff6e4', '#eadcc4', '#ffffff')
COBBLE = ('#bdb0aa', '#8c7e86', '#ded2c2')
CURB = ('#9a8e94', '#6e6470', '#c0b4b4')
IRON = ('#4a3e48', '#2e262e', '#6e626c')
LAMP = ('#f8d870', '#e0a830', '#fff4c0')
GREEN = ('#4f9a4a', '#2f6a3a', '#86c06a')
TEALG = ('#3f8a7a', '#2a6458', '#6ab4a0')
RED = ('#c8402e', '#8e2a1e', '#ec7254')
PINK = ('#e88aac', '#b85a80', '#f6b8cf')
PURPLE = ('#8a5ca8', '#5e3a7e', '#b48ccc')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
BLUE = ('#3f7fc8', '#245a8e', '#7aaee0')
FLAGS = ['#d6322b', '#f0c030', '#3f9a4a', '#3f7fc8', '#e88aac', '#f4f0e4']

FAMILIES = {
    'warm': dict(sky=('#f8e4be', '#f0c890', '#f5d6a6'), far=('#d8a882', '#b88866', '#e8c09a'), far_kind='hills',
                 wall=('#a08a7e', '#7e6a66', '#bea896'), wall_kind='stone', roof=('#a6483a', '#7a2e2a', '#cc6a4e')),
    'teal': dict(sky=('#c8ecec', '#9cdcd8', '#b4e4e2'), far=('#7cbab6', '#5a9a98', '#a2d4d0'), far_kind='sea',
                 wall=('#3f8a84', '#2a6664', '#64aa9a'), wall_kind='boards', roof=('#cc9e40', '#9a7028', '#e8c464')),
    'blue': dict(sky=('#d2e2f2', '#a8c4e4', '#bed4ec'), far=('#86a8d8', '#6688bc', '#aac4e8'), far_kind='sea',
                 wall=('#dcc4a6', '#b49c84', '#f0dcbc'), wall_kind='plaster', roof=('#dc6a2c', '#a8402a', '#f29a48')),
    'purple': dict(sky=('#dcd4ea', '#b4a8d4', '#c8bee0'), far=('#9d8fb4', '#7e7098', '#bcb0d0'), far_kind='hills',
                   wall=('#9a8e90', '#726870', '#b8acac'), wall_kind='stone', roof=('#8e5ca0', '#643c7c', '#b48ac4')),
}
REGION_FAMILY = {'ca': 'warm', 'csa': 'warm', 'esa': 'warm', 'mena': 'warm',
                 'cb': 'teal', 'ea': 'teal', 'oc': 'teal', 'sea': 'teal',
                 'ee': 'blue', 'na': 'blue', 'nwe': 'blue',
                 'sa': 'purple', 'se': 'purple', 'wca': 'purple'}


def hx(c):
    c = c.lstrip('#')
    return np.array([int(c[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.uint8)


# ---------------------------------------------------------------- masks
def _blank():
    return Image.new('L', (W, H), 0)


def _np(im):
    return np.array(im) > 0


def m_poly(pts):
    im = _blank()
    ImageDraw.Draw(im).polygon([(round(x), round(y)) for x, y in pts], fill=255)
    return _np(im)


def m_rect(x0, y0, x1, y1):
    """Half-open box [x0, x1) x [y0, y1)."""
    m = np.zeros((H, W), bool)
    m[max(0, y0):max(0, y1), max(0, x0):max(0, x1)] = True
    return m


def m_ell(cx, cy, rx, ry):
    yy, xx = np.mgrid[0:H, 0:W]
    return ((xx + 0.5 - cx) / rx) ** 2 + ((yy + 0.5 - cy) / ry) ** 2 < 1


def m_rrect(x0, y0, x1, y1, r):
    """Rounded top box (only the top corners round): felt arch caps."""
    m = m_rect(x0, y0 + r, x1, y1) | m_rect(x0 + r, y0, x1 - r, y1)
    m |= m_ell(x0 + r, y0 + r, r, r) | m_ell(x1 - r, y0 + r, r, r)
    return m


def m_line(pts, w=1):
    im = _blank()
    d = ImageDraw.Draw(im)
    for a, b in zip(pts, pts[1:]):
        d.line([a, b], fill=255, width=w)
    return _np(im)


def shift(m, dx, dy):
    """Value of m at (x - dx, y - dy); outside is False."""
    out = np.zeros_like(m)
    ys = slice(max(dy, 0), H + min(dy, 0))
    yd = slice(max(-dy, 0), H + min(-dy, 0))
    xs = slice(max(dx, 0), W + min(dx, 0))
    xd = slice(max(-dx, 0), W + min(-dx, 0))
    out[ys, xs] = m[yd, xd]
    return out


def erode(m, n=1):
    for _ in range(n):
        m = m & shift(m, 1, 0) & shift(m, -1, 0) & shift(m, 0, 1) & shift(m, 0, -1)
    return m


def dilate(m, n=1):
    for _ in range(n):
        m = m | shift(m, 1, 0) | shift(m, -1, 0) | shift(m, 0, 1) | shift(m, 0, -1)
    return m


# ---------------------------------------------------------------- canvas
class Card:
    def __init__(self):
        self.a = np.zeros((H, W, 3), np.uint8)

    def fill(self, m, col):
        self.a[m] = hx(col)

    def piece(self, m, ramp, outline=True, stitch=None, rim=1, shade=2, inset=3, clip=None):
        """A felt piece: fill, light rim upper-left, dark crescent lower-right, outline, optional dashed stitch."""
        if clip is not None:
            m = m & clip
        if not m.any():
            return m
        base, dark, light = ramp
        self.fill(m, base)
        if shade:
            sh = np.zeros_like(m)
            for k in range(1, shade + 1):
                sh |= ~shift(m, -k, 0) | ~shift(m, 0, -k)
            self.fill(m & sh, dark)
        if rim:
            rm = np.zeros_like(m)
            for k in range(1, rim + 1):
                rm |= ~shift(m, k, 0) | ~shift(m, 0, k)
            self.fill(m & rm, light)
        if stitch:
            e = erode(m, inset)
            ring = e & ~erode(e, 1)
            yy, xx = np.mgrid[0:H, 0:W]
            dash = ((xx + yy) // 2) % 2 == 0
            self.fill(ring & dash, stitch)
        if outline:
            o = dilate(m, 1) & ~m
            if clip is not None:
                o &= clip
            self.fill(o, UMBER)
        return m

    def seam(self, m, col):
        self.fill(m, col)

    def px(self, x, y, col):
        if 0 <= x < W and 0 <= y < H:
            self.a[y, x] = hx(col)

    def image(self):
        return Image.fromarray(self.a, 'RGB').convert('RGBA')


# ---------------------------------------------------------------- scene pieces
def sky(c, fam):
    top, low, mid = fam['sky']
    c.fill(m_rect(0, 0, W, 40), top)
    c.fill(m_rect(0, 40, W, 66), mid)
    c.fill(m_rect(0, 66, W, HORIZON), low)
    yy, xx = np.mgrid[0:H, 0:W]
    dash = ((xx // 3) % 2 == 0)
    for y in (40, 66):   # stitched seams between the sky felt bands
        c.fill(m_rect(0, y, W, y + 1) & dash, CREAM_T)
    for cx, cy, s in ((50, 14, 1.0), (300, 12, 1.2), (440, 22, 0.9), (150, 34, 0.7), (380, 50, 0.6)):
        cloud(c, cx, cy, s)


def cloud(c, cx, cy, s):
    m = (m_ell(cx, cy + 2 * s, 22 * s, 6 * s) | m_ell(cx - 7 * s, cy - 1 * s, 9 * s, 6 * s)
         | m_ell(cx + 6 * s, cy - 3 * s, 10 * s, 7 * s))
    m &= m_rect(0, 0, W, int(cy + 7 * s))
    c.piece(m, CLOUD, stitch=CLOUD[1] if s >= 0.9 else None)


def far(c, fam):
    base, dark, light = fam['far']
    if fam['far_kind'] == 'sea':
        sea = m_rect(0, 84, W, 130)
        c.fill(sea, base)
        c.fill(m_rect(0, 84, W, 85), light)
        c.fill(m_rect(0, 85, W, 86), UMBER2)
        yy, xx = np.mgrid[0:H, 0:W]
        for y0 in range(90, 130, 6):
            w = ((xx + y0 * 3) % 23 < 5) & (yy == y0)
            c.fill(w, light)
    else:
        pts = [(0, 92)]
        for i, x in enumerate(range(0, W + 40, 40)):
            pts.append((x + 20, 76 + (i * 7) % 12))
            pts.append((x + 40, 90 - (i * 5) % 6))
        pts += [(W, 130), (0, 130)]
        c.piece(m_poly(pts), fam['far'], rim=1, shade=0)
    # far town silhouettes (flat felt, no stitch)
    st = ('#9a8c94', '#80727c', '#b2a6aa') if fam['far_kind'] == 'hills' else ('#a49aa2', '#8a7e88', '#bcb2b6')
    for x0, y0, w in ((60, 98, 16), (112, 92, 12), (180, 100, 18), (262, 88, 14), (276, 100, 20), (150, 104, 14)):
        c.piece(m_rect(x0, y0, x0 + w, 140), st, shade=1)
        c.piece(m_poly([(x0 - 2, y0), (x0 + w // 2, y0 - 7), (x0 + w + 2, y0)]), st, shade=1)


def street(c):
    # pavement in front of the houses
    c.piece(m_rect(0, 244, W, 254), CURB, shade=1)
    # cobbles: rows that grow toward the viewer, brick-bonded, each cobble a tiny felt piece without outline
    y = 254
    row = 0
    ys = []
    while y < H:
        h = 6 + row // 2
        ys.append((y, min(y + h, H)))
        y += h
        row += 1
    c.fill(m_rect(0, 254, W, H), COBBLE[1])
    for r, (y0, y1) in enumerate(ys):
        cw = 14 + r * 4
        off = (cw // 2) * (r % 2)
        for x0 in range(-off, W, cw):
            m = m_rect(x0 + 1, y0 + 1, x0 + cw, y1)
            if not m.any():
                continue
            k = ((x0 + 7 * r) // cw) % 5
            ramp = COBBLE if k else ('#c8bcb4', '#9c8e92', '#e6dccc')
            c.piece(m, ramp, outline=False, shade=1)
    # stone steps up to the Mossbottom arcade (kept out of the stand points and the compass corner)
    for y0, x0 in ((246, 284), (251, 290)):
        c.piece(m_rect(x0, y0, W, y0 + 6), CURB, shade=1)
    yy, xx = np.mgrid[0:H, 0:W]
    c.fill(m_rect(292, 254, W - 2, 255) & ((xx // 2) % 2 == 0), CREAM_T)


def windows(c, x0, x1, top, bottom, lean, rows, lit_seed):
    """Two windows per floor, positions follow the house's lean."""
    n = 0
    for fy in rows:
        f = (bottom - fy) / max(1, bottom - top)
        dx = int(round(lean * f))
        w = (x1 - x0)
        ww = max(8, w // 4)
        for cx in (x0 + w // 4, x1 - w // 4):
            wx = cx - ww // 2 + dx
            lit = ((n * 7 + lit_seed) % 5) != 0
            win(c, wx, fy, ww, 13, lit)
            n += 1


def win(c, x, y, w, h, lit=True):
    c.piece(m_rect(x - 1, y - 1, x + w + 1, y + h + 1), WOOD_D, shade=1)
    g = m_rect(x + 1, y + 1, x + w - 1, y + h - 1)
    c.piece(g, GLASS if lit else GLASS_D, outline=False, shade=1)
    c.fill(m_rect(x + w // 2, y + 1, x + w // 2 + 1, y + h - 1), WOOD_D[0])
    c.fill(m_rect(x + 1, y + h // 2, x + w - 1, y + h // 2 + 1), WOOD_D[0])
    # sill
    c.piece(m_rect(x - 2, y + h + 1, x + w + 2, y + h + 3), WOOD, shade=1)


def awning(c, x0, x1, y, ramp, depth=8):
    m = m_rect(x0, y, x1, y + depth)
    yy, xx = np.mgrid[0:H, 0:W]
    # scalloped hem
    for sx in range(x0, x1, 6):
        m |= m_ell(sx + 3, y + depth, 3, 2.5)
    m &= m_rect(x0, y, x1, y + depth + 3)
    c.piece(m, ramp, shade=1)
    stripes = m & (((xx - x0) // 3) % 2 == 1) & erode(m, 1)
    c.fill(stripes, '#fff3dc')


def shopfront(c, x0, x1, bottom, awn, door_col=WOOD):
    """Ground floor: display window, door, awning above."""
    w = x1 - x0
    dw = max(8, w // 4)
    dx = x1 - dw - 4
    c.piece(m_rect(x0 + 3, bottom - 22, dx - 3, bottom - 6), GLASS, shade=1)
    c.fill(m_rect(x0 + 3, bottom - 14, dx - 3, bottom - 13), WOOD_D[0])
    c.piece(m_rrect(dx, bottom - 24, dx + dw, bottom, dw // 2), door_col, stitch=None)
    c.px(dx + 2, bottom - 11, GOLD[2])
    awning(c, x0 + 1, x1 - 1, bottom - 34, awn)


def house(c, fam, x0, x1, top, bottom, lean, floors, awn, seed):
    """A tall local house (loc-*): leaning wall, roof cap, chimney, windows, shop on the ground floor."""
    wall = m_poly([(x0, bottom), (x0 + lean, top), (x1 + lean, top), (x1, bottom)])
    c.piece(wall, fam['wall'], stitch=None)
    yy, xx = np.mgrid[0:H, 0:W]
    inner = erode(wall, 2)
    dk = fam['wall'][1]
    if fam['wall_kind'] == 'stone':
        rows = ((yy - top) % 10 == 0)
        joints = ((xx + ((yy - top) // 10) * 9) % 18 == 0) & ((yy - top) % 10 != 0)
        c.fill(inner & (rows | joints) & ((xx * 7 + yy * 3) % 11 < 6), dk)
    elif fam['wall_kind'] == 'boards':
        c.fill(inner & ((yy - top) % 5 == 0), dk)
        c.fill(inner & ((yy - top) % 5 == 1) & (xx % 3 == 0), fam['wall'][2])
    else:
        c.fill(inner & ((xx * 13 + yy * 7) % 47 == 0), dk)
        c.fill(inner & ((xx * 5 + yy * 11) % 53 == 0), fam['wall'][2])
    # corner quoins / stitched edge seam
    seam = erode(wall, 3) & ~erode(wall, 4) & (((yy // 2) % 2) == 0) & (yy > top + 12) & (yy < bottom - 40)
    c.fill(seam, CREAM_T)
    # roof cap and chimney
    rx0, rx1 = x0 + lean - 3, x1 + lean + 3
    c.piece(m_rect(x1 + lean - 12, top - 14, x1 + lean - 5, top - 2), fam['roof'])
    c.piece(m_rect(x1 + lean - 14, top - 16, x1 + lean - 3, top - 12), fam['roof'])
    c.piece(m_poly([(rx0, top + 6), (rx0 + 2, top - 6), (rx1 - 2, top - 6), (rx1, top + 6)]), fam['roof'], stitch=THREAD, inset=2)
    # floors of windows
    span = bottom - 44 - (top + 14)
    rows = [top + 14 + int(i * span / max(1, floors - 1)) for i in range(floors)] if floors > 1 else [top + 14]
    windows(c, x0, x1, top, bottom, lean, rows, seed)
    # ground floor shop
    f = 40 / max(1, bottom - top)
    shopfront(c, x0 + int(lean * f * 0), x1, bottom, awn)
    # sign board
    sw = (x1 - x0) // 2
    sx = (x0 + x1) // 2 - sw // 2 + int(lean * 46 / (bottom - top))
    c.piece(m_rect(sx, bottom - 46, sx + sw, bottom - 38), WOOD, shade=1)
    # little balcony bracket on the side
    by = top + (bottom - top) // 3
    c.piece(m_rect(x1 + int(lean * (bottom - by) / (bottom - top)) - 1, by, x1 + int(lean * (bottom - by) / (bottom - top)) + 6, by + 3), WOOD_D, shade=1)


def tower(c, fam):
    # side shop (part of loc-more)
    c.piece(m_rect(254, 196, 282, 246), fam['wall'])
    c.piece(m_poly([(251, 200), (254, 188), (282, 188), (285, 200)]), fam['roof'], stitch=THREAD, inset=2)
    win(c, 260, 206, 14, 12, True)
    awning(c, 255, 281, 222, GREEN, depth=6)
    c.piece(m_rect(262, 232, 274, 246), WOOD)
    # body
    body = m_rect(206, 72, 254, 248)
    c.piece(body, STONE)
    yy, xx = np.mgrid[0:H, 0:W]
    inner = erode(body, 2)
    c.fill(inner & ((yy % 9 == 0) | (((xx + (yy // 9) * 8) % 16 == 0))), STONE[1])
    # stitched corner seams
    c.fill(m_rect(209, 76, 210, 240) & ((yy // 2) % 2 == 0), CREAM_T)
    c.fill(m_rect(250, 76, 251, 240) & ((yy // 2) % 2 == 0), CREAM_T)
    # roof
    c.piece(m_poly([(198, 76), (230, 24), (262, 76)]), fam['roof'], stitch=THREAD, inset=3)
    c.piece(m_rect(229, 14, 232, 26), GOLD, shade=1)
    c.piece(m_rect(227, 12, 234, 16), GOLD, shade=1)
    c.piece(m_rect(200, 74, 260, 80), STONE_D, shade=1)
    # belfry window
    c.piece(m_rrect(222, 84, 238, 104, 8), WOOD_D)
    c.piece(m_rrect(225, 87, 235, 104, 5), GLASS, outline=False, shade=1)
    # clock
    c.piece(m_ell(230, 120, 15, 15), WOOD)
    c.piece(m_ell(230, 120, 11.5, 11.5), CLOCK, stitch=None)
    for a in range(12):
        t = a * math.pi / 6
        c.px(int(230 + 9 * math.cos(t)), int(120 + 9 * math.sin(t)), UMBER2)
    c.fill(m_line([(230, 120), (230, 112)], 1), UMBER)
    c.fill(m_line([(230, 120), (236, 123)], 1), UMBER)
    # slit windows and band
    for y in (148, 172):
        c.piece(m_rrect(225, y, 235, y + 14, 5), WOOD_D)
        c.piece(m_rect(227, y + 4, 233, y + 13), GLASS, outline=False, shade=1)
    c.piece(m_rect(204, 194, 256, 198), STONE_D, shade=1)
    # banner sign
    c.piece(m_rect(212, 202, 248, 212), RED, stitch=None)
    c.fill(m_rect(214, 207, 246, 208) & ((xx // 2) % 2 == 0), CREAM_T)
    # door
    c.piece(m_rrect(220, 218, 240, 248, 10), WOOD_D)
    c.piece(m_rrect(222, 220, 238, 248, 8), WOOD, outline=False)
    c.fill(m_rect(230, 222, 231, 248), WOOD_D[1])
    c.px(234, 236, GOLD[2])


def icon(c, kind, cx, cy):
    """A small sign symbol for each Mossbottom shop (felt appliqué on a cream board)."""
    c.piece(m_rrect(cx - 9, cy - 7, cx + 9, cy + 7, 3), ('#fff3c8', '#e2cf9a', '#ffffff'))
    if kind == 'seeds':
        c.piece(m_rect(cx - 1, cy - 1, cx + 1, cy + 5), GREEN, outline=False, shade=0, rim=0)
        c.piece(m_ell(cx - 3, cy - 2, 3, 2), GREEN, outline=False, shade=0, rim=0)
        c.piece(m_ell(cx + 3, cy - 3, 3, 2), GREEN, outline=False, shade=0, rim=0)
    elif kind == 'food':
        c.piece(m_poly([(cx - 6, cy - 1), (cx + 6, cy - 1), (cx + 3, cy + 4), (cx - 3, cy + 4)]), RED, outline=False, rim=0, shade=1)
        c.fill(m_rect(cx - 2, cy - 5, cx - 1, cy - 2) | m_rect(cx + 1, cy - 6, cx + 2, cy - 2), '#a8a0a0')
    elif kind == 'florist':
        c.fill(m_rect(cx, cy + 1, cx + 1, cy + 6), GREEN[1])
        c.fill(m_rect(cx + 1, cy + 3, cx + 3, cy + 4), GREEN[0])
        for dx, dy in ((-3, -2), (3, -2), (0, -5), (0, 1)):
            c.fill(m_rect(cx + dx - 1, cy + dy - 1, cx + dx + 2, cy + dy + 2), PINK[1])
        c.fill(m_rect(cx - 1, cy - 3, cx + 2, cy), GOLD[0])
    elif kind == 'decor':
        c.piece(m_poly([(cx - 2, cy - 5), (cx + 2, cy - 5), (cx + 1, cy - 3), (cx + 4, cy + 1), (cx + 2, cy + 5), (cx - 2, cy + 5), (cx - 4, cy + 1), (cx - 1, cy - 3)]),
                BLUE, outline=False, rim=0, shade=1)
    elif kind == 'dyes':
        for dx, col in ((-4, RED[0]), (0, GOLD[0]), (4, BLUE[0])):
            c.fill(m_poly([(cx + dx, cy - 4), (cx + dx + 2, cy + 1), (cx + dx + 1, cy + 3), (cx + dx - 1, cy + 3), (cx + dx - 2, cy + 1)]), col)
    elif kind == 'pets':
        c.fill(m_ell(cx, cy + 2, 3.5, 3), WOOD_D[0])
        for dx, dy in ((-4, -2), (-1, -4), (2, -4), (5, -2)):
            c.fill(m_ell(cx + dx - 0.5, cy + dy, 1.6, 1.8), WOOD_D[0])
    else:   # more
        for dx in (-5, 0, 5):
            c.fill(m_rect(cx + dx - 1, cy - 1, cx + dx + 2, cy + 2), PURPLE[0])


def hub_shop(c, x0, x1, top, bottom, accent, kind, upper):
    cap = 6
    wall = m_rect(x0, top + cap, x1, bottom)
    c.piece(wall, PLASTER)
    yy, xx = np.mgrid[0:H, 0:W]
    c.fill(erode(wall, 2) & ((xx * 13 + yy * 7) % 41 == 0), PLASTER[1])
    # arched cap
    c.piece(m_rrect(x0 - 2, top, x1 + 2, top + cap + 3, 5), accent, stitch=None)
    c.fill(m_rect(x0 + 2, top + 4, x1 - 2, top + 5) & ((xx // 2) % 2 == 0), CREAM_T)
    # pilasters
    c.piece(m_rect(x0, top + cap + 3, x0 + 3, bottom), accent, shade=1, outline=False)
    c.piece(m_rect(x1 - 3, top + cap + 3, x1, bottom), accent, shade=1, outline=False)
    w = x1 - x0
    if upper:
        win(c, x0 + 7, top + 16, 10, 14, True)
        win(c, x1 - 17, top + 16, 10, 14, (x0 // 7) % 3 != 0)
        icon(c, kind, (x0 + x1) // 2, top + 48)
        awning(c, x0 + 3, x1 - 3, top + 60, accent, depth=7)
        c.piece(m_rect(x0 + 6, top + 72, x1 - 6, bottom - 4), GLASS, shade=1)
        c.fill(m_rect((x0 + x1) // 2, top + 72, (x0 + x1) // 2 + 1, bottom - 4), WOOD_D[0])
        c.piece(m_rect(x0 + 4, bottom - 4, x1 - 4, bottom), WOOD, shade=1)
    else:
        win(c, x0 + 7, top + 14, 10, 13, True)
        win(c, x1 - 17, top + 14, 10, 13, (x0 // 5) % 3 != 1)
        icon(c, kind, (x0 + x1) // 2, top + 42)
        awning(c, x0 + 3, x1 - 3, top + 52, accent, depth=7)
        dw = 12
        dx = x1 - dw - 6
        c.piece(m_rect(x0 + 6, top + 64, dx - 3, bottom - 8), GLASS, shade=1)
        c.fill(m_rect(x0 + 6, top + 74, dx - 3, top + 75), WOOD_D[0])
        c.piece(m_rrect(dx, top + 63, dx + dw, bottom, 6), WOOD)
        c.px(dx + 2, bottom - 18, GOLD[2])
        c.piece(m_rect(x0 + 5, bottom - 8, dx - 2, bottom - 4), WOOD, shade=1)


def mossbottom(c):
    # back wall of the arcade
    back = m_rect(284, 50, W, 250)
    c.piece(back, ('#b8a490', '#94806e', '#cfbca6'), outline=True)
    yy, xx = np.mgrid[0:H, 0:W]
    c.fill(erode(back, 2) & (yy % 10 == 0) & (xx % 3 != 0), '#a8947e')
    # upper row
    hub_shop(c, 300, 360, 40, 138, PINK, 'dyes', True)
    hub_shop(c, 366, 424, 40, 138, RED, 'pets', True)
    hub_shop(c, 430, 476, 40, 138, GREEN, 'more', True)
    # gallery ledge with railing
    c.piece(m_rect(282, 138, W, 148), STONE, stitch=None)
    c.fill(m_rect(284, 142, W - 2, 143) & ((xx // 2) % 2 == 0), CREAM_T)
    for x in range(290, W, 10):
        c.piece(m_rect(x, 132, x + 2, 138), IRON, shade=0)
    c.piece(m_rect(284, 130, W, 132), IRON, shade=0)
    # lower row
    hub_shop(c, 286, 330, 150, 246, GREEN, 'seeds', False)
    hub_shop(c, 334, 378, 150, 246, RED, 'food', False)
    hub_shop(c, 382, 426, 150, 246, PINK, 'florist', False)
    hub_shop(c, 430, 474, 150, 246, TEALG, 'decor', False)
    # steps down to the street
    for i, (y0, x0) in enumerate(((246, 284), (252, 280), (258, 276))):
        pass


def bunting(c, pts, sag, n, seed=0):
    (x0, y0), (x1, y1) = pts
    line = []
    for i in range(41):
        t = i / 40
        line.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)))
    c.fill(m_line([(round(x), round(y)) for x, y in line], 1), UMBER2)
    for k in range(1, n):
        t = k / n
        x = x0 + (x1 - x0) * t
        y = y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)
        col = FLAGS[(k + seed) % len(FLAGS)]
        m = m_poly([(x - 3, y + 1), (x + 3, y + 1), (x, y + 7)])
        c.fill(m, col)
        c.fill(m & ~shift(m, -1, 0) & ~shift(m, 0, -1) | (m & ~shift(m, 0, -1) & (np.mgrid[0:H, 0:W][0] > y + 4)), UMBER2)


def lamp(c, x, top, bottom=248):
    c.piece(m_rect(x - 1, top + 8, x + 2, bottom), IRON, shade=0)
    c.piece(m_rect(x - 3, bottom - 4, x + 4, bottom), IRON, shade=0)
    c.piece(m_poly([(x - 4, top + 8), (x - 3, top), (x + 4, top), (x + 5, top + 8)]), LAMP, shade=1)
    c.piece(m_rect(x - 5, top - 3, x + 6, top), IRON, shade=0)


def draw_region(code):
    fam = FAMILIES[REGION_FAMILY[code]]
    c = Card()
    sky(c, fam)
    far(c, fam)
    # ground behind the street, under the houses
    c.piece(m_rect(-2, 128, W + 2, 244), ('#8e8088', '#76686e', '#a29498'), outline=False, shade=0)
    yy, xx = np.mgrid[0:H, 0:W]
    c.fill(m_rect(0, 128, W, 244) & ((yy - 128) % 12 == 0) & ((xx // 2) % 2 == 0), '#76686e')
    tower(c, fam)
    houses = [
        (8, 52, 36, 244, -2, 5, RED, 3),
        (64, 108, 66, 244, 2, 4, GOLD, 1),
        (120, 160, 96, 244, -1, 3, GREEN, 4),
        (170, 198, 126, 244, 1, 2, PINK, 2),
    ]
    for x0, x1, top, bottom, lean, floors, awn, seed in houses[::-1]:
        house(c, fam, x0, x1, top, bottom, lean, floors, awn, seed)
    mossbottom(c)
    bunting(c, ((52, 62), (206, 92)), 12, 12, 0)
    bunting(c, ((254, 98), (300, 58)), 8, 5, 3)
    bunting(c, ((10, 180), (206, 200)), 16, 15, 2)
    bunting(c, ((254, 160), (286, 154)), 4, 3, 4)
    street(c)
    lamp(c, 59, 196)
    lamp(c, 165, 206)
    lamp(c, 280, 214)
    return c.image()


def save(code):
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CMP, exist_ok=True)
    name = 'here-shops-street-%s.png' % code
    ship = Image.open(os.path.join(SHIP, name))
    im = draw_region(code)
    assert im.size == ship.size
    im = im.convert(ship.mode)
    im.save(os.path.join(OUT, name))
    cmp = Image.new('RGB', (W * 2 + 8, H), '#2a1a10')
    cmp.paste(ship.convert('RGB'), (0, 0))
    cmp.paste(im.convert('RGB'), (W + 8, 0))
    cmp.save(os.path.join(CMP, 'shops-street-%s.png' % code))
    return os.path.join(OUT, name)
