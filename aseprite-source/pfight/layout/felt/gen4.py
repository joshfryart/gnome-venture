#!/usr/bin/env python3
"""felt/gen4: the r2-m11c quilted-felt jigsaw extended to FOUR-sided pieces for the shared 2D board.

render(type, size, edges, owner) -> RGBA piece image
  size  'strip' (body 56x40, image 74x52) or 'hand' (body 96x68, image 132x92)
  edges {'L': (kind, fam), 'R': .., 'T': .., 'B': ..}, kind flat|knob|hole, fam body|mind|craft (None for flat)
  owner 'me' | 'foe'
Image = body + tab depth on every side: left/right KX (strip 9, hand 18), top/bottom KY (strip 6, hand 12).
The body sits at (KX, KY). Place pieces on a grid at body pitch (56x40 / 96x68): a knob fills the neighbour's
hole exactly (holes are transparent cutouts of the identical shape), so the seam is one shared ink joint.
Mine = cream piping + gold running stitch. Foe = bramble: body inset on all four sides, thorns fill the margin
(tips on the cell edge, so they never cross into a neighbour), corner horns, rust/maroon band; around every
socket the margin is filled solid (a collar) so knobs and holes keep the exact shape and still fit.
Run: python3 gen4.py  -> board-demo.png/.json, tray-demo-0..3.png, inspect-demo.png, sheet.png, sheet-gray.png, sheet-cb.png
Code copied from mockups/r2/r2-m11c/gen.py (sockets, rings, thorns, 20 px icons, sims); base_icons.py is a copy.
"""
import json
import os
import numpy as np
from PIL import Image, ImageDraw
import base_icons as B

HERE = os.path.dirname(os.path.abspath(__file__))
INK, CREAM, GOLD, FELT = B.INK, B.CREAM, B.GOLD, B.FELT
hx = B.hx
WHITE = (0xff, 0xf8, 0xe6)
RUST = hx('#c2502c')     # foe contrast ring
MAROON = hx('#5e1a12')   # foe band
BONE = hx('#f4d6a8')     # thorn tips
TOOTH = hx('#b4441f')    # thorn body
STITCH = hx('#d8764a')   # foe red-brown stitch
TYPES, ORDER = B.TYPES, B.ORDER
FAM3 = ['body', 'mind', 'craft']
SIDES = 'LRTB'

# icon / plate / ribbon are in BODY coordinates. Hand icon moved down 4 px and the ribbon made 9 px tall so the
# shallower top/bottom tabs never cut them; strip plate moved left so it clears the top socket.
GEO = {
    'hand': dict(W=96, H=68, KX=18, KY=12, R=6, icon=32, ix=37, iy=13, tag=(21, 3, 14, 12), name=(24, 46, 58, 9),
                 inset=4, tper=10, span=7),
    'strip': dict(W=56, H=40, KX=9, KY=6, R=4, icon=20, ix=21, iy=13, tag=(5, 2, 12, 10), name=None,
                  inset=3, tper=7, span=5),
}


# ------------------------------------------------------------------ sockets (d = depth from the cell edge)
def knob_hand(fam, d, dy):
    """left/right, depth 18 (as r2-m11c)"""
    a = abs(dy)
    if fam == 'body':       # round tab, short FAT neck, big round head
        return (d <= 3 and a <= 4.5) or (d - 9.6) ** 2 + dy * dy <= 8.3 ** 2
    if fam == 'mind':       # keyhole on its side: wide trapezoid base, narrow neck, round head at the tip
        if d <= 7 and a <= 7.0 - d * 0.7:
            return True
        return (d - 11.6) ** 2 + dy * dy <= 6.2 ** 2
    if fam == 'craft':      # arrow: short neck then a wide triangle, point out
        if d <= 3 and a <= 3.0:
            return True
        return 3 <= d and a <= (17.6 - d) * 0.66
    return False


def knob_hand_v(fam, d, dx):
    """top/bottom, depth 12: the same three silhouettes, squatter"""
    a = abs(dx)
    if fam == 'body':       # fat neck + wide dome
        return (d <= 2 and a <= 4.5) or ((d - 6.2) / 5.6) ** 2 + (a / 7.6) ** 2 <= 1
    if fam == 'mind':       # flared base, pinched neck, round head
        if d <= 4 and a <= 7.0 - d * 1.15:
            return True
        return ((d - 7.9) / 3.9) ** 2 + (a / 4.9) ** 2 <= 1
    if fam == 'craft':      # short neck + wide arrowhead
        if d <= 2 and a <= 3.0:
            return True
        return 2 <= d and a <= (11.7 - d) * 1.05
    return False


# strip left/right knobs: 9 columns deep (string column = depth), 12 rows, centred (rows 14..25 of 40)
STRIP_KNOBS = {
    'body': ["....xxx..", "...xxxxx.", "..xxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx",
             "xxxxxxxxx", "xxxxxxxxx", "xxxxxxxxx", "..xxxxxxx", "...xxxxx.", "....xxx.."],
    'mind': ["x........", "xx.......", "xxx..xxx.", "xxx.xxxxx", "xxxxxxxxx", "xxxxxxxxx",
             "xxxxxxxxx", "xxxxxxxxx", "xxx.xxxxx", "xxx..xxx.", "xx.......", "x........"],
    'craft': ["..x......", "..xx.....", "..xxx....", "..xxxx...", "xxxxxxx..", "xxxxxxxxx",
              "xxxxxxxxx", "xxxxxxx..", "..xxxx...", "..xxx....", "..xx.....", "..x......"],
}
# strip top/bottom knobs: 6 rows deep (row = depth, row 0 touches the body), 14 columns, centred (x 21..34)
STRIP_KNOBS_V = {
    'body': ["....xxxxxx....",
             "..xxxxxxxxxx..",
             ".xxxxxxxxxxxx.",
             ".xxxxxxxxxxxx.",
             "..xxxxxxxxxx..",
             "....xxxxxx...."],
    'mind': ["xxxxxxxxxxxxxx",
             "...xxxxxxxx...",
             "......xx......",
             "...xxxxxxxx...",
             "...xxxxxxxx...",
             ".....xxxx....."],
    'craft': [".....xxxx.....",
              "xxxxxxxxxxxxxx",
              ".xxxxxxxxxxxx.",
              "...xxxxxxxx...",
              ".....xxxx.....",
              "......xx......"],
}

_sock = {}


def socket_cells(size, side, fam):
    """set of (d, s): d = depth from the cell edge, s = body coordinate along the edge"""
    key = (size, side in 'LR', fam)
    if key in _sock:
        return _sock[key]
    g = GEO[size]
    W, H = g['W'], g['H']
    out = set()
    if side in 'LR':
        if size == 'hand':
            cy = (H - 1) / 2.0
            for y in range(H):
                for d in range(g['KX']):
                    if knob_hand(fam, d, y - cy):
                        out.add((d, y))
        else:
            rows = STRIP_KNOBS[fam]
            y0 = H // 2 - len(rows) // 2
            for j, r in enumerate(rows):
                for d, ch in enumerate(r):
                    if ch == 'x':
                        out.add((d, y0 + j))
    else:
        if size == 'hand':
            cx = (W - 1) / 2.0
            for x in range(W):
                for d in range(g['KY']):
                    if knob_hand_v(fam, d, x - cx):
                        out.add((d, x))
        else:
            rows = STRIP_KNOBS_V[fam]
            x0 = W // 2 - len(rows[0]) // 2
            for d, r in enumerate(rows):
                for i, ch in enumerate(r):
                    if ch == 'x':
                        out.add((d, x0 + i))
    _sock[key] = out
    return out


def to_xy(size, side, kind, d, s):
    g = GEO[size]
    W, H = g['W'], g['H']
    if side == 'L':
        return (-1 - d, s) if kind == 'knob' else (d, s)
    if side == 'R':
        return (W + d, s) if kind == 'knob' else (W - 1 - d, s)
    if side == 'T':
        return (s, -1 - d) if kind == 'knob' else (s, d)
    return (s, H + d) if kind == 'knob' else (s, H - 1 - d)


def norm(edges):
    out = {}
    for s in SIDES:
        e = edges.get(s, ('flat', None)) if edges else ('flat', None)
        if isinstance(e, str):
            e = tuple(e.split(':')) if ':' in e else (e, None)
        kind, fam = e[0], (e[1] if len(e) > 1 else None)
        if kind == 'flat' or fam in (None, 'flat'):
            kind, fam = 'flat', None
        out[s] = (kind, fam)
    return out


# ------------------------------------------------------------------ masks
def in_rr(x, y, x0, y0, x1, y1, R):
    """rounded rect [x0..x1] x [y0..y1] inclusive"""
    if not (x0 <= x <= x1 and y0 <= y <= y1):
        return False
    cx = x0 + R - .5 if x < x0 + R else (x1 - R + .5 if x > x1 - R else None)
    cy = y0 + R - .5 if y < y0 + R else (y1 - R + .5 if y > y1 - R else None)
    if cx is not None and cy is not None:
        return (x - cx) ** 2 + (y - cy) ** 2 <= (R - .2) ** 2
    return True


def spans(size, edges):
    """along-edge extent (s0, s1) of every socket, widened by 2 (the foe collar)"""
    out = {}
    for s in SIDES:
        kind, fam = edges[s]
        if kind != 'flat':
            ss = [c[1] for c in socket_cells(size, s, fam)]
            out[s] = (min(ss) - 2, max(ss) + 2)
    return out


def build_masks(size, edges, foe):
    g = GEO[size]
    W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
    Wc, Hc = W + 2 * KX, H + 2 * KY
    body = np.zeros((Hc, Wc), bool)
    knob = np.zeros((Hc, Wc), bool)
    sp = spans(size, edges)
    if foe:
        m = g['inset']
        R = 4 if size == 'hand' else 3
        for y in range(H):
            for x in range(W):
                body[y + KY, x + KX] = in_rr(x, y, m, m, W - 1 - m, H - 1 - m, R)
        for s, (a, b) in sp.items():      # collars: fill the thorn margin around each socket
            for t in range(m):
                for v in range(a, b + 1):
                    x, y = {'L': (t, v), 'R': (W - 1 - t, v), 'T': (v, t), 'B': (v, H - 1 - t)}[s]
                    # 1 px chamfer on the outer corners of the collar
                    if t == 0 and v in (a, b):
                        continue
                    body[y + KY, x + KX] = True
    else:
        R = g['R']
        for y in range(H):
            for x in range(W):
                body[y + KY, x + KX] = in_rr(x, y, 0, 0, W - 1, H - 1, R)
    for s in SIDES:
        kind, fam = edges[s]
        if kind == 'flat':
            continue
        for d, v in socket_cells(size, s, fam):
            x, y = to_xy(size, s, kind, d, v)
            if kind == 'knob':
                knob[y + KY, x + KX] = True
            else:
                body[y + KY, x + KX] = False
    return body, knob, sp


def rings(m, n=10):
    """ring index from the outside (0 = outline). Alternate 4/8 erosion for round bands."""
    d = np.full(m.shape, -1, int)
    cur = m.copy()
    for i in range(n):
        p = np.pad(cur, 1)
        e4 = cur & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]
        if i % 2:
            e4 = e4 & p[:-2, :-2] & p[:-2, 2:] & p[2:, :-2] & p[2:, 2:]
        d[cur & ~e4] = i
        cur = e4
    d[cur] = n
    return d


def walk(pts):
    left = set(pts)
    paths = []
    while left:
        s = min(left, key=lambda p: (p[1], p[0]))
        left.discard(s)
        path, cur = [s], s
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


# ------------------------------------------------------------------ foe thorns (top-side sprite: row 0 = tip on the cell edge)
THORN = {
    'hand': [(3, 0, 'b'),
             (2, 1, 'k'), (3, 1, 'b'), (4, 1, 'k'),
             (1, 2, 'k'), (2, 2, 't'), (3, 2, 'b'), (4, 2, 't'), (5, 2, 'k'),
             (0, 3, 'k'), (1, 3, 't'), (2, 3, 't'), (3, 3, 't'), (4, 3, 't'), (5, 3, 't'), (6, 3, 'k'),
             (0, 4, 't'), (1, 4, 't'), (2, 4, 't'), (3, 4, 't'), (4, 4, 't'), (5, 4, 't'), (6, 4, 't')],
    'strip': [(2, 0, 'b'),
              (1, 1, 'k'), (2, 1, 'b'), (3, 1, 'k'),
              (0, 2, 'k'), (1, 2, 't'), (2, 2, 'b'), (3, 2, 't'), (4, 2, 'k'),
              (0, 3, 't'), (1, 3, 't'), (2, 3, 't'), (3, 3, 't'), (4, 3, 't')],
}
HORN = {
    'hand': [(0, 0, 'b'), (1, 1, 'b'), (2, 1, 'k'), (1, 2, 'k'), (2, 2, 't'), (3, 2, 'k'), (2, 3, 'k'), (3, 3, 't'),
             (4, 3, 'k'), (3, 4, 't'), (4, 4, 't')],
    'strip': [(0, 0, 'b'), (1, 1, 'b'), (2, 1, 'k'), (1, 2, 'k'), (2, 2, 't'), (3, 2, 't'), (2, 3, 't'), (3, 3, 't')],
}


def teeth_pos(size, side, sp):
    g = GEO[size]
    L = g['W'] if side in 'TB' else g['H']
    per, span = g['tper'], g['span']
    blocks = []
    if side in sp:
        blocks.append((sp[side][0] - 1, sp[side][1] + 1))
    if side == 'T':
        tx, ty, tw, th = g['tag']
        blocks.append((tx - 2, tx + tw + 1))
    lo, hi = g['inset'] + 3, L - g['inset'] - 3        # keep clear of the corner horns
    # lay teeth in each free run, centred in the run
    runs, x = [], lo
    for a, b in sorted(blocks) + [(hi, hi)]:
        if a > x:
            runs.append((x, min(a, hi)))
        x = max(x, b + 1)
    out = []
    for a, b in runs:
        n = (b - a - span) // per + 1 if b - a >= span else 0
        if n <= 0:
            continue
        used = (n - 1) * per + span
        x0 = a + (b - a - used) // 2
        out += [x0 + i * per for i in range(n)]
    return out


def thorns(size, sp):
    g = GEO[size]
    W, H = g['W'], g['H']
    out = {}
    for side in SIDES:
        for p in teeth_pos(size, side, sp):
            for dx, j, k in THORN[size]:
                v = p + dx
                xy = {'T': (v, j), 'B': (v, H - 1 - j), 'L': (j, v), 'R': (W - 1 - j, v)}[side]
                out[xy] = k
    for dx, dy, k in HORN[size]:
        for x, y in ((dx, dy), (W - 1 - dx, dy), (dx, H - 1 - dy), (W - 1 - dx, H - 1 - dy)):
            out.setdefault((x, y), k)
    return out


# ------------------------------------------------------------------ 20 px icons, hand placed (copied from r2-m11c)
IC20 = {
 'hurt': ("""
 .........ww.....
 ....ww...ww...ww
 ....ww...ww...ww
 ...www..www..www
 ...ww...ww...ww.
 ...ww...ww...ww.
 ..www..www..www.
 ..ww...ww...ww..
 ..ww...ww...ww..
 .www..www..www..
 .ww...ww...ww...
 .oo...oo...o....
 .o...oo...oo....
 .o...o.....o....
 .....o..........
 ................""", {'w': WHITE, 'o': hx('#ffc24a')}),
 'guard': ("""
 .......L........
 ......LLD.......
 .LLLLLLLDDDDDDD.
 .LlLLLLLDDDDDDD.
 .LlLLLLkDDDDDDD.
 .LlLLLLLkDDDDkD.
 .LlLkLLLDkDDkDD.
 .LLLLkLLDDkkDDD.
 .LLLLLkLDDDDDDD.
 ..LLLLLLkDDDDD..
 ..LLLLLLDDDDDD..
 ...LLLLLDDDDD...
 ....LLLLDDDD....
 .....LLLDDD.....
 ......LLDD......
 .......LD.......""", {'L': hx('#8ed04a'), 'D': hx('#4f9a26'), 'l': hx('#d6f08a'), 'k': B.INK}),
 'heal': ("""
 ................
 ..mmmm....mmmm..
 .mwwmmm..mmmmmm.
 mmwmmmmmmmmmmmmm
 mmmmmmmGGmmmmmms
 mmmmmmmGGmmmmmms
 mmmmmGGGGGGmmmss
 mmmmmGGGGGGmmmss
 .mmmmmmGGmmmmss.
 .mmmmmmGGmmmmss.
 ..mmmmmmmmmmss..
 ...mmmmmmmmss...
 ....mmmmmmss....
 .....mmmmss.....
 ......mmss......
 .......ms.......""", {'m': hx('#b9f5cf'), 'w': WHITE, 's': hx('#6fd3a0'), 'G': hx('#0f7f58')}),
 'charm': ("""
 ......wwww......
 .....wwwwww.....
 .....wwppww.....
 .ww..wwppww..ww.
 wwww..wwww..wwww
 wwpppw.kk.wpppww
 .wwwpkkggkkpwww.
 ..wwwkgwggkwww..
 ....wkggggkw....
 .....kkggkk.....
 ...www.kk.www...
 ..wwwpw..wpwww..
 .wwppww..wwppww.
 .wwwww....wwwww.
 ..www......www..
 ................""", {'w': WHITE, 'p': hx('#ffb3d2'), 'g': GOLD, 'k': B.INK}),
 'soothe': ("""
 ................
 ..........ww....
 .........wsw....
 ........wssw....
 .......wwssw....
 ..ww..wwwsw.....
 .wwww.wwwsw.....
 gwkwwwwwwww.....
 .wwwwwwwwwwww...
 ..wwwwwwwwwwwwww
 ...wwwwwwwwwwww.
 ....sswwwwwwww..
 .....sssssswwww.
 .......sss....w.
 ................
 ................""", {'w': WHITE, 's': hx('#b8cfe0'), 'g': GOLD, 'k': B.INK}),
 'trick': ("""
 ............ff..
 ...........fFff.
 ...........fFf..
 ..........fFf...
 ..........Ff....
 pp........F...pp
 pplp..pppppp.ppp
 pppppppppppppppp
 ppkkkkppppkkkkpp
 pkkkkkkppkkkkkkp
 ppkkkkppppkkkkpp
 .pppppp..pppppp.
 ..pppp....pppp..
 ...pp......pp...
 ................
 ................""", {'p': hx('#7a48a8'), 'l': hx('#b48ad8'), 'f': hx('#e0452c'), 'F': hx('#8f1f14'), 'k': B.INK}),
 'item': ("""
 ...wwwwwwwwww...
 ..wwwwwwwwwwww..
 .wwbbbbbbbbbbww.
 ..wwwwwwwwwwww..
 ...gggggggggg...
 ..gggggggggggg..
 .gjjjjjjjjjjJJg.
 .gjjjjjjjjjjJJg.
 .gjjwwwwwwjjJJg.
 .gjjwwjjwwjjJJg.
 .gjjwwwwwwjjJJg.
 .gjjjjjjjjjjJJg.
 .gjjjjjjjjjjJJg.
 ..gggggggggggg..
 ................
 ................""", {'w': WHITE, 'b': hx('#2f84bd'), 'g': hx('#dff3f2'), 'j': hx('#b3262e'), 'J': hx('#7a141f')}),
}


def icon20(t):
    art, pal = IC20[t]
    rows = [r.strip() for r in art.strip('\n').split('\n')]
    im = Image.new('RGBA', (20, 20), (0, 0, 0, 0))
    for j, r in enumerate(rows):
        assert len(r) == 16, (t, j, r)
        for i, ch in enumerate(r):
            if ch != '.':
                im.putpixel((2 + i, 2 + j), pal[ch] + (255,))
    im = B.finish_icon(im)
    if t == 'hurt':   # deep red between the rips instead of a halo
        p = im.load()
        for y in range(20):
            for x in range(1, 19):
                if p[x, y][:3] == CREAM and p[x - 1, y][:3] == INK and p[x + 1, y][:3] == INK:
                    p[x, y] = hx('#7a1e08') + (255,)
    return im


_icons = {}


def get_icon(t, size):
    k = (t, size)
    if k not in _icons:
        _icons[k] = B.icon(t, 32) if size == 'hand' else icon20(t)
    return _icons[k]


# ------------------------------------------------------------------ renderer
_cache = {}


def render(t, size, edges, owner='me'):
    edges = norm(edges)
    key = (t, size, tuple(edges[s] for s in SIDES), owner)
    if key in _cache:
        return _cache[key].copy()
    g = GEO[size]
    W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
    Wc, Hc = W + 2 * KX, H + 2 * KY
    foe = owner == 'foe'
    hand = size == 'hand'
    c = TYPES[t]
    body, knob, sp = build_masks(size, edges, foe)
    full = body | knob
    # body bands follow the body (+holes) only, so the piping runs straight past each knob root and the whole knob
    # silhouette stays outside the body; the knob gets its own ink + thin rim
    dm = rings(full)
    dmb = rings(body)
    dm[body] = dmb[body]
    p = np.pad(knob, 1)
    nb_knob = p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    dm[body & (dm == 0) & nb_knob] = 1
    rim = (2 if hand else 1) if not foe else (3 if hand else 2)
    kr = 2 if hand else 1
    F = np.where(knob, dm >= kr, dm > rim) & full

    def inF(x, y):
        return 0 <= x < Wc and 0 <= y < Hc and F[y, x]

    im = Image.new('RGBA', (Wc, Hc), (0, 0, 0, 0))
    px = im.load()
    for y in range(Hc):
        for x in range(Wc):
            r = dm[y, x]
            if r < 0:
                continue
            if r == 0:
                col = INK
            elif not F[y, x]:
                col = CREAM if not foe else (RUST if r == 1 else MAROON)
            else:
                col = c['mark'] if B.pat(t, size, x - KX, y - KY) else c['base']
                s2 = hand and body[y, x]
                if not inF(x + 1, y) or not inF(x, y + 1) or (s2 and (not inF(x + 2, y) or not inF(x, y + 2) or not inF(x + 1, y + 1))):
                    col = c['shade']
                elif not inF(x - 1, y) or not inF(x, y - 1):
                    col = c['light']
            px[x, y] = col + (255,)

    edge_px = np.zeros_like(body)            # outermost row/col of the cell
    edge_px[KY, KX:KX + W] = edge_px[KY + H - 1, KX:KX + W] = True
    edge_px[KY:KY + H, KX] = edge_px[KY:KY + H, KX + W - 1] = True
    if foe:
        if hand:
            ring = list(zip(*np.nonzero((dm == 2) & body)[::-1]))
            for path in walk(ring):
                if len(path) < 6:
                    continue
                for i, (x, y) in enumerate(path):
                    if i % 4 < 2:
                        px[x, y] = STITCH + (255,)
        for (x, y), k in thorns(size, sp).items():
            X, Y = x + KX, y + KY
            if not full[Y, X] or (dm[Y, X] == 0 and body[Y, X]):
                px[X, Y] = {'b': BONE, 't': TOOTH, 'k': INK}[k] + (255,)
    else:
        ring = list(zip(*np.nonzero((dm == rim) & ~F & body & ~edge_px)[::-1]))
        on, off = (3, 2) if hand else (2, 2)
        for path in walk(ring):
            if len(path) < 6:
                continue
            for i, (x, y) in enumerate(path):
                if i % (on + off) < on:
                    px[x, y] = GOLD + (255,)

    # number plate: cream plate, ink border; the game prints the number in INK
    d = ImageDraw.Draw(im)
    tx, ty, tw, th = g['tag']
    tx, ty = tx + KX, ty + KY
    d.rectangle([tx - 1, ty - 1, tx + tw, ty + th], fill=INK + (255,))
    d.rectangle([tx, ty, tx + tw - 1, ty + th - 1], fill=CREAM + (255,))
    d.line([tx, ty + th - 1, tx + tw - 1, ty + th - 1], fill=B.CREAM_D + (255,))
    if foe:
        for q in ((tx, ty), (tx + tw - 1, ty), (tx, ty + th - 2), (tx + tw - 1, ty + th - 2)):
            px[q] = RUST + (255,)

    if g['name']:
        nx, ny, nw, nh = g['name']
        nx, ny = nx + KX, ny + KY
        d.rectangle([nx - 1, ny - 1, nx + nw, ny + nh], fill=INK + (255,))
        d.rectangle([nx, ny, nx + nw - 1, ny + nh - 1], fill=CREAM + (255,))
        mid = ny + nh // 2
        for i in range(3):
            for yy in range(mid - (2 - i), mid + (2 - i) + 1):
                edgep = yy in (mid - (2 - i), mid + (2 - i)) or i == 2
                px[nx + i - 1, yy] = (INK if edgep else c['base']) + (255,)
                px[nx + nw - i, yy] = (INK if edgep else c['base']) + (255,)
        st = RUST if foe else GOLD
        for yy in range(ny + 2, ny + nh - 2, 3):
            px[nx + 4, yy] = st + (255,)
            px[nx + nw - 5, yy] = st + (255,)

    ic = get_icon(t, size)
    ip = ic.load()
    ix, iy = g['ix'] + KX, g['iy'] + KY
    for yy in range(ic.height):
        for xx in range(ic.width):
            if ip[xx, yy][3] and full[iy + yy, ix + xx]:
                px[ix + xx, iy + yy] = ip[xx, yy]
    _cache[key] = im
    return im.copy()


# ------------------------------------------------------------------ boards
OPP = {'L': 'R', 'R': 'L', 'T': 'B', 'B': 'T'}
DIR = {'L': (-1, 0), 'R': (1, 0), 'T': (0, -1), 'B': (0, 1)}


def check_fit(edges):
    for (c, r), e in edges.items():
        for s in SIDES:
            n = (c + DIR[s][0], r + DIR[s][1])
            if n in edges:
                a, b = e[s], edges[n][OPP[s]]
                ok = (a[0] == 'flat' and b[0] == 'flat') or ({a[0], b[0]} == {'knob', 'hole'} and a[1] == b[1])
                assert ok, ((c, r), s, a, b)


def compose(cells, edges, size, cols, rows):
    g = GEO[size]
    W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
    check_fit(edges)
    cv = Image.new('RGBA', (cols * W + 2 * KX, rows * H + 2 * KY), (0, 0, 0, 0))
    for (c, r), (t, o) in sorted(cells.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        cv.alpha_composite(render(t, size, edges[(c, r)], o), (c * W, r * H))
    return cv


F_ = ('flat', None)
DEMO_CELLS = {(1, 0): ('guard', 'me'), (0, 1): ('hurt', 'me'), (1, 1): ('trick', 'foe'), (2, 1): ('hurt', 'foe'),
              (1, 2): ('heal', 'me')}
DEMO_EDGES = {
    (1, 0): {'L': ('hole', 'body'), 'R': ('knob', 'mind'), 'T': F_, 'B': ('knob', 'craft')},
    (0, 1): {'L': F_, 'R': ('knob', 'mind'), 'T': ('hole', 'mind'), 'B': ('knob', 'body')},
    (1, 1): {'L': ('hole', 'mind'), 'R': ('knob', 'body'), 'T': ('hole', 'craft'), 'B': ('hole', 'mind')},
    (2, 1): {'L': ('hole', 'body'), 'R': F_, 'T': ('knob', 'craft'), 'B': ('hole', 'body')},
    (1, 2): {'L': ('knob', 'craft'), 'R': ('hole', 'mind'), 'T': ('knob', 'mind'), 'B': F_},
}


def open_sockets(cells, edges, cols, rows):
    out = []
    for c in sorted(cells):
        for s in SIDES:
            n = (c[0] + DIR[s][0], c[1] + DIR[s][1])
            if n not in cells and 0 <= n[0] < cols and 0 <= n[1] < rows:
                k, f = edges[c][s]
                assert k != 'flat', (c, s)
                out.append({'cell': list(c), 'side': s, 'kind': k, 'fam': f})
    return out


TRAY = [('hurt', {'L': ('hole', 'body'), 'R': ('knob', 'mind'), 'T': F_, 'B': ('knob', 'craft')}),
        ('guard', {'L': ('knob', 'craft'), 'R': ('hole', 'body'), 'T': ('hole', 'mind'), 'B': F_}),
        ('charm', {'L': F_, 'R': ('knob', 'body'), 'T': ('knob', 'mind'), 'B': ('hole', 'craft')}),
        ('item', {'L': ('hole', 'craft'), 'R': F_, 'T': F_, 'B': ('knob', 'body')})]

# varied 4-sided edges per type for the sheet
VAR = {
    'hurt': {'L': ('hole', 'body'), 'R': ('knob', 'mind'), 'T': F_, 'B': ('knob', 'craft')},
    'guard': {'L': ('knob', 'craft'), 'R': ('hole', 'body'), 'T': ('hole', 'mind'), 'B': F_},
    'heal': {'L': F_, 'R': ('knob', 'craft'), 'T': ('knob', 'body'), 'B': ('hole', 'mind')},
    'charm': {'L': ('hole', 'mind'), 'R': ('knob', 'body'), 'T': ('knob', 'mind'), 'B': ('hole', 'craft')},
    'soothe': {'L': ('knob', 'body'), 'R': F_, 'T': ('hole', 'craft'), 'B': ('knob', 'mind')},
    'trick': {'L': ('hole', 'craft'), 'R': ('hole', 'mind'), 'T': ('hole', 'body'), 'B': ('knob', 'body')},
    'item': {'L': ('knob', 'mind'), 'R': ('knob', 'craft'), 'T': F_, 'B': ('hole', 'body')},
}
VAR_FOE = {
    'hurt': {'L': ('knob', 'craft'), 'R': ('hole', 'body'), 'T': ('hole', 'mind'), 'B': ('knob', 'body')},
    'guard': {'L': ('hole', 'mind'), 'R': ('knob', 'craft'), 'T': F_, 'B': ('hole', 'body')},
    'heal': {'L': ('knob', 'body'), 'R': ('hole', 'craft'), 'T': ('hole', 'body'), 'B': F_},
    'charm': {'L': F_, 'R': ('knob', 'mind'), 'T': ('knob', 'craft'), 'B': ('hole', 'mind')},
    'soothe': {'L': ('hole', 'body'), 'R': ('knob', 'body'), 'T': ('knob', 'mind'), 'B': ('hole', 'craft')},
    'trick': {'L': ('knob', 'mind'), 'R': F_, 'T': ('hole', 'craft'), 'B': ('knob', 'craft')},
    'item': {'L': ('hole', 'craft'), 'R': ('hole', 'mind'), 'T': ('knob', 'body'), 'B': ('knob', 'mind')},
}

# a 2x2 hand board for the sheet: mine and foe interlocking on all inner sides
H2_CELLS = {(0, 0): ('heal', 'me'), (1, 0): ('guard', 'foe'), (0, 1): ('trick', 'foe'), (1, 1): ('soothe', 'me')}
H2_EDGES = {
    (0, 0): {'L': F_, 'T': F_, 'R': ('knob', 'mind'), 'B': ('hole', 'craft')},
    (1, 0): {'L': ('hole', 'mind'), 'T': F_, 'R': F_, 'B': ('knob', 'body')},
    (0, 1): {'L': F_, 'T': ('knob', 'craft'), 'R': ('hole', 'body'), 'B': F_},
    (1, 1): {'L': ('knob', 'body'), 'T': ('hole', 'body'), 'R': F_, 'B': F_},
}


# ------------------------------------------------------------------ sheet
LAB = (0xb8, 0x9a, 0x6a)


def text(im, x, y, s, col=LAB):
    B.text(im, x, y, s, col)


def pair(size, fam, vertical, gap, ta, oa, tb, ob, half, across=None):
    """knob piece A (R or B knob) next to hole piece B (L or T hole), `gap` px apart, cropped around the seam"""
    g = GEO[size]
    W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
    if not vertical:
        A = render(ta, size, {'R': ('knob', fam)}, oa)
        Bp = render(tb, size, {'L': ('hole', fam)}, ob)
        cv = Image.new('RGBA', (2 * W + 2 * KX + gap, H + 2 * KY), (0, 0, 0, 0))
        cv.alpha_composite(Bp, (W + gap, 0))
        cv.alpha_composite(A, (0, 0))
        sx = KX + W
        return cv.crop((sx - half, KY, sx + gap + half, KY + H))
    A = render(ta, size, {'B': ('knob', fam)}, oa)
    Bp = render(tb, size, {'T': ('hole', fam)}, ob)
    cv = Image.new('RGBA', (W + 2 * KX, 2 * H + 2 * KY + gap), (0, 0, 0, 0))
    cv.alpha_composite(Bp, (0, H + gap))
    cv.alpha_composite(A, (0, 0))
    sy, cx = KY + H, KX + W // 2
    return cv.crop((cx - across, sy - half, cx + across, sy + gap + half))


# extra digits for the sheet labels (3x5, same style as base_icons.FONT)
B.FONT.update({'0': ["111", "101", "101", "101", "111"], '1': ["010", "110", "010", "010", "111"],
               '2': ["110", "001", "010", "100", "111"], '5': ["111", "100", "110", "001", "110"],
               '6': ["011", "100", "110", "101", "010"], '8': ["010", "101", "010", "101", "010"],
               '9': ["010", "101", "011", "001", "110"]})


def build_sheet():
    hg, sg = GEO['hand'], GEO['strip']
    hW, hH = hg['W'] + 2 * hg['KX'], hg['H'] + 2 * hg['KY']      # 132 x 92
    sW, sH = sg['W'] + 2 * sg['KX'], sg['H'] + 2 * sg['KY']      # 74 x 52
    gap = 6
    Wd = 8 + 4 * (hW + gap)
    im = Image.new('RGBA', (Wd, 2000), FELT + (255,))
    y = 5
    for title, own, var in (('MINE  HAND', 'me', VAR), ('FOE  HAND', 'foe', VAR_FOE)):
        text(im, 8, y, title)
        y += 7
        for i, t in enumerate(ORDER):
            x = 8 + (i % 4) * (hW + gap)
            yy = y + (i // 4) * (hH + 2)
            im.alpha_composite(render(t, 'hand', var[t], own), (x, yy))
        if own == 'me':
            text(im, 8 + 3 * (hW + gap) + 10, y + hH + 30, 'L R TABS 18', LAB)
            text(im, 8 + 3 * (hW + gap) + 10, y + hH + 38, 'T B TABS 12', LAB)
            text(im, 8 + 3 * (hW + gap) + 10, y + hH + 46, 'PIECE 132X92', LAB)
        else:
            text(im, 8 + 3 * (hW + gap) + 10, y + hH + 30, 'STRIP PIECE', LAB)
            text(im, 8 + 3 * (hW + gap) + 10, y + hH + 38, '74X52  TABS 9 6', LAB)
        y += 2 * (hH + 2) + 2
    for title, own, var in (('MINE  STRIP', 'me', VAR), ('FOE  STRIP', 'foe', VAR_FOE)):
        text(im, 8, y, title)
        y += 7
        for i, t in enumerate(ORDER):
            im.alpha_composite(render(t, 'strip', var[t], own), (8 + i * (sW + 4), y))
        y += sH + 2
    y += 2
    # boards: 3x3 strip demo + 2x2 hand
    text(im, 8, y, 'BOARD  STRIP 3X3  PITCH 56X40')
    text(im, 8 + 186 + 16, y, 'BOARD  HAND 2X2  PITCH 96X68')
    y += 8
    bd = compose(DEMO_CELLS, DEMO_EDGES, 'strip', 3, 3)
    im.alpha_composite(bd, (8, y))
    h2 = compose(H2_CELLS, H2_EDGES, 'hand', 2, 2)
    im.alpha_composite(h2, (8 + 186 + 16, y))
    text(im, 8 + 186 + 16 + h2.width + 8, y + 20, 'MINE AND FOE', LAB)
    text(im, 8 + 186 + 16 + h2.width + 8, y + 28, 'INTERLOCK ON', LAB)
    text(im, 8 + 186 + 16 + h2.width + 8, y + 36, 'ALL 4 SIDES', LAB)
    y += max(bd.height, h2.height) + 4
    # sockets: per family, knob and hole apart, then snapped (mine knob into a foe hole); side and top/bottom tabs
    text(im, 8, y, 'SOCKETS   APART  THEN  MINE KNOB SNAPPED INTO FOE HOLE   SIDE AND TOP TABS   HAND THEN STRIP')
    y += 8
    names = {'body': 'BODY  ROUND TAB', 'mind': 'MIND  KEYHOLE', 'craft': 'CRAFT  TRIANGLE'}
    colw = (Wd - 8) // 3
    for i, fam in enumerate(FAM3):
        x0 = 8 + i * colw
        x = x0
        a = pair('hand', fam, False, 6, 'item', 'me', 'soothe', 'me', 28)
        im.alpha_composite(a, (x, y)); x += a.width + 4
        a = pair('hand', fam, False, 0, 'item', 'me', 'hurt', 'foe', 28)
        im.alpha_composite(a, (x, y)); x += a.width + 4
        a = pair('hand', fam, True, 6, 'charm', 'me', 'heal', 'me', 22, 16)
        im.alpha_composite(a, (x, y + 9))
        x = x0
        yy = y + 72
        a = pair('hand', fam, True, 0, 'charm', 'me', 'trick', 'foe', 20, 16)
        im.alpha_composite(a, (x, yy)); x += a.width + 6
        a = pair('strip', fam, False, 4, 'item', 'me', 'soothe', 'me', 16)
        im.alpha_composite(a, (x, yy)); x += a.width + 4
        a = pair('strip', fam, False, 0, 'item', 'me', 'hurt', 'foe', 16)
        im.alpha_composite(a, (x, yy)); x += a.width + 4
        a = pair('strip', fam, True, 4, 'charm', 'me', 'heal', 'me', 11, 14)
        im.alpha_composite(a, (x, yy)); x += a.width + 4
        a = pair('strip', fam, True, 0, 'charm', 'me', 'trick', 'foe', 11, 14)
        im.alpha_composite(a, (x, yy + 4))
        text(im, x0, yy + 46, names[fam])
    y += 72 + 54
    return im.crop((0, 0, Wd, y)).convert('RGB')


# ------------------------------------------------------------------ simulations (Machado 2009, severity 1)
M = {'deuteranopia': [[.367322, .860646, -.227968], [.280085, .672501, .047413], [-.011820, .042940, .968881]],
     'protanopia': [[.152286, 1.052583, -.204868], [.114503, .786281, .099216], [-.003882, -.048116, 1.051998]],
     'tritanopia': [[1.255528, -.076749, -.178779], [-.078411, .930809, .147602], [.004733, .691367, .303900]]}


def lin(a):
    a = a / 255.
    return np.where(a <= .04045, a / 12.92, ((a + .055) / 1.055) ** 2.4)


def srgb(a):
    a = np.clip(a, 0, 1)
    return np.where(a <= .0031308, a * 12.92, 1.055 * a ** (1 / 2.4) - .055) * 255


def sim(img, v):
    a = np.asarray(img.convert('RGB'), float)
    if v == 'gray':
        y = (lin(a) @ np.array([.2126, .7152, .0722]))[..., None]
        out = srgb(np.repeat(y, 3, -1))
    else:
        out = srgb(lin(a) @ np.array(M[v]).T)
    return Image.fromarray(np.round(out).astype(np.uint8))


def labelled(img, s):
    out = Image.new('RGBA', (img.width, img.height + 9), FELT + (255,))
    out.paste(img, (0, 9))
    B.text(out, 4, 2, s, (0xf2, 0xe4, 0xc0))
    return out.convert('RGB')


def main():
    # board demo (strip, 3x3) + json in the layout/board-demo.json schema
    g = GEO['strip']
    bd = compose(DEMO_CELLS, DEMO_EDGES, 'strip', 3, 3)
    bd.save(os.path.join(HERE, 'board-demo.png'))
    socks = open_sockets(DEMO_CELLS, DEMO_EDGES, 3, 3)
    fams = {e[1] for c in DEMO_EDGES.values() for e in c.values() if e[0] != 'flat'}
    assert fams == set(FAM3), fams
    with open(os.path.join(HERE, 'board-demo.json'), 'w') as f:
        json.dump({'pitch': [g['W'], g['H']], 'pad_x': g['KX'], 'pad_y': g['KY'],
                   'cells': {f'{c[0]},{c[1]}': list(v) for c, v in DEMO_CELLS.items()}, 'open_sockets': socks}, f, indent=1)
    for i, (t, e) in enumerate(TRAY):
        render(t, 'strip', e, 'me').save(os.path.join(HERE, f'tray-demo-{i}.png'))
    render('hurt', 'hand', TRAY[0][1], 'me').save(os.path.join(HERE, 'inspect-demo.png'))
    s = build_sheet()
    s.save(os.path.join(HERE, 'sheet.png'))
    sim(s, 'gray').save(os.path.join(HERE, 'sheet-gray.png'))
    parts = [labelled(sim(s, v), v) for v in ('deuteranopia', 'protanopia', 'tritanopia')]
    cb = Image.new('RGB', (sum(p.width for p in parts) + 8, max(p.height for p in parts)), FELT)
    x = 0
    for p in parts:
        cb.paste(p, (x, 0))
        x += p.width + 4
    cb.save(os.path.join(HERE, 'sheet-cb.png'))
    print('board', bd.size, 'sockets', len(socks), 'sheet', s.size,
          'strip', render('hurt', 'strip', {}).size, 'hand', render('hurt', 'hand', {}).size)


if __name__ == '__main__':
    main()
