"""Variation B: felt-sign action cards for the Gather UI.
Card = stitched felt panel (96x112 grid, saved 2x) with a framed vignette (gnome + tool in landscape)
and a blank hanging ribbon sign for the HTML label. Each card also has a pressed/selected variant.
Style follows aseprite-source/scenes-pil/pixlib.py: hard pixels, umber 3-tone outline, light upper left."""
import os
import numpy as np
from PIL import Image, ImageDraw

W, H = 96, 112
OUT = os.path.dirname(os.path.abspath(__file__))
OL = ('#74462a', '#4a2c1a', '#2a1a10')
FELT = {'idle': ('#c9a46a', '#a98450', '#e3c48c', '#8a6a3e'),     # base, shade, rim, stitch
        'sel':  ('#8fae5c', '#6e8e44', '#b2cc7c', '#f2e6c4')}
RIB = ('#b8573e', '#8e3c2a', '#d47a5a')
SKY = {'day': ('#a8d4e0', '#cfe8e6'), 'dusk': ('#e8a87a', '#f4cf98'), 'night': ('#3a4a6e', '#56668a')}
HILL = ('#7ea85a', '#5e8a44', '#9cc070')
GN = {'hat': '#c0442e', 'hatd': '#8e2e1e', 'skin': '#f0c8a0', 'beard': '#f4eee0', 'beardd': '#cfc6b0',
      'coat': '#4a6e9a', 'coatd': '#34507a', 'boot': '#5a3a22'}


def hx(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


def mask(fn):
    im = Image.new('1', (W, H), 0)
    fn(ImageDraw.Draw(im))
    return np.array(im, bool)


def rect(a, b, c, d): return mask(lambda g: g.rectangle([a, b, c, d], fill=1))
def ell(a, b, c, d): return mask(lambda g: g.ellipse([a, b, c, d], fill=1))
def poly(p): return mask(lambda g: g.polygon(p, fill=1))
def line(p, w=1): return mask(lambda g: g.line(p, fill=1, width=w))


def sh(m, dx, dy):
    return np.roll(np.roll(m, dy, 0), dx, 1)


def dil(m): return m | sh(m, 1, 0) | sh(m, -1, 0) | sh(m, 0, 1) | sh(m, 0, -1)


class C:
    def __init__(s):
        s.px = np.zeros((H, W, 4), np.uint8)

    def f(s, m, col):
        s.px[m] = hx(col) + (255,)

    def outline(s, u):
        ring = dil(u) & ~u
        ys, xs = np.nonzero(u)
        yy, xx = np.mgrid[0:H, 0:W]
        t = (xx - xs.mean()) / max(4, np.ptp(xs) / 2) + (yy - ys.mean()) / max(4, np.ptp(ys) / 2)
        s.f(ring & (t < -0.7), OL[0]); s.f(ring & (t >= -0.7) & (t < 0.1), OL[1]); s.f(ring & (t >= 0.1), OL[2])

    def shaded(s, m, b, sd, r=None, d=1):
        s.f(m, b)
        s.f(m & ~sh(m, -d, -d), sd)
        if r: s.f(m & ~sh(m, 1, 1) & sh(m, -d, -d), r)


def gnome(c, x, y, flip=False, pose='stand'):
    """Gnome about 14 tall; feet at (x, y)."""
    k = -1 if flip else 1
    P = lambda pts: poly([(x + k * a, y + b) for a, b in pts])
    hat = P([(-4, -9), (4, -9), (1 * 1, -16), (-1, -15)])
    face = P([(-3, -9), (3, -9), (3, -6), (-3, -6)])
    beard = P([(-3, -7), (3, -7), (2, -3), (0, -2), (-2, -3)])
    body = P([(-4, -6), (4, -6), (4, -1), (-4, -1)]) if pose != 'sit' else P([(-4, -5), (5, -5), (5, -1), (-4, -1)])
    boots = P([(-4, -1), (-1, -1), (-1, 0), (-4, 0)]) | P([(1, -1), (4, -1), (4, 0), (1, 0)])
    if pose == 'sit': boots = P([(4, -2), (8, -2), (8, 0), (4, 0)])
    c.outline(hat | face | beard | body | boots)
    c.shaded(body, GN['coat'], GN['coatd'])
    c.f(boots, GN['boot'])
    c.f(face, GN['skin'])
    c.shaded(beard, GN['beard'], GN['beardd'])
    c.shaded(hat, GN['hat'], GN['hatd'])
    c.f(rect(x + k * 1, y - 8, x + k * 1, y - 8), '#2a1a10')
    c.f(rect(x + k * 2, y - 7, x + k * 2, y - 7), '#e08a7a')


def item(c, m, b, sd):
    c.outline(m); c.shaded(m, b, sd)


TOOLS = {}


def tool(name, sky='day'):
    def deco(fn):
        TOOLS[name] = (fn, sky); return fn
    return deco


# vignette frame interior: x 14..81, y 12..61 ; ground line ~ y 52
GY = 53


@tool('hand')
def v_hand(c):
    for bx in (56, 64):
        item(c, ell(bx, GY - 9, bx + 7, GY - 1), '#4e8a3c', '#386a2a')
    c.f(rect(58, GY - 7, 59, GY - 6) | rect(66, GY - 5, 67, GY - 4) | rect(61, GY - 4, 62, GY - 3), '#c03a4a')
    gnome(c, 46, GY)
    item(c, ell(50, GY - 7, 53, GY - 4), GN['skin'], '#d4a27a')


@tool('forage')
def v_forage(c):
    item(c, rect(60, GY - 7, 61, GY - 1) | ell(56, GY - 11, 65, GY - 6), '#c84a3a', '#98302a')
    c.f(rect(58, GY - 10, 58, GY - 10) | rect(62, GY - 9, 62, GY - 9), '#f4eee0')
    gnome(c, 44, GY)
    item(c, line([(49, GY - 4), (54, GY - 7)], 1), '#cfd4dc', '#8a909a')
    c.f(rect(48, GY - 4, 49, GY - 3), '#7a4a2a')


@tool('basket')
def v_basket(c):
    gnome(c, 40, GY)
    b = rect(46, GY - 6, 55, GY - 1)
    handle = line([(47, GY - 6), (50, GY - 11), (54, GY - 6)])
    item(c, b | handle, '#c89050', '#946434')
    c.f(rect(47, GY - 4, 54, GY - 4), '#946434')
    c.f(rect(48, GY - 7, 49, GY - 7) | rect(52, GY - 7, 53, GY - 7), '#c03a4a')
    c.f(rect(50, GY - 7, 51, GY - 7), '#6a4aa0')


@tool('rod', 'dusk')
def v_rod(c):
    water = rect(52, GY - 2, 81, 61)
    c.f(water, '#4a88b0'); c.f(rect(56, GY, 62, GY) | rect(68, GY + 3, 76, GY + 3), '#8cc4dc')
    gnome(c, 38, GY - 1)
    item(c, line([(42, GY - 6), (62, GY - 22)], 1), '#8a5a2e', '#5a3a1e')
    c.f(line([(62, GY - 22), (68, GY - 2)]), '#e8e0d0')
    c.f(rect(67, GY - 2, 69, GY - 2), '#e04a3a')


@tool('net')
def v_net(c):
    gnome(c, 38, GY)
    item(c, line([(42, GY - 6), (54, GY - 18)], 1), '#8a5a2e', '#5a3a1e')
    hoop = ell(52, GY - 26, 62, GY - 16)
    c.outline(hoop & ~ell(54, GY - 24, 60, GY - 18))
    c.f(hoop, '#e8e0d0')
    for i in range(53, 62, 2): c.f(rect(i, GY - 25, i, GY - 17), '#b8b0a0')
    for x0, y0, col in ((66, GY - 28, '#f4c84a'), (70, GY - 20, '#a8d4f0')):
        c.f(rect(x0, y0, x0 + 1, y0) | rect(x0 + 3, y0, x0 + 4, y0), col)
        c.f(rect(x0 + 2, y0, x0 + 2, y0 + 1), '#2a1a10')


@tool('pick')
def v_pick(c):
    rock = poly([(54, GY), (60, GY - 14), (72, GY - 16), (80, GY - 6), (80, GY)])
    c.outline(rock); c.shaded(rock, '#8a8a92', '#62626c', '#aaaab2', 2)
    c.f(rect(64, GY - 9, 65, GY - 8) | rect(71, GY - 5, 72, GY - 4), '#6ad0d8')
    gnome(c, 44, GY)
    item(c, line([(48, GY - 4), (54, GY - 14)], 1), '#8a5a2e', '#5a3a1e')
    item(c, line([(50, GY - 16), (55, GY - 14), (58, GY - 10)], 1), '#b8bcc4', '#7a7e88')


@tool('axe')
def v_axe(c):
    trunk = rect(60, GY - 22, 66, GY)
    crown = ell(52, GY - 40, 76, GY - 18)
    c.outline(trunk | crown)
    c.shaded(trunk, '#8a5a2e', '#5a3a1e'); c.shaded(crown, '#4e8a3c', '#386a2a', '#6aa84a', 2)
    gnome(c, 48, GY)
    item(c, line([(52, GY - 4), (57, GY - 12)], 1), '#8a5a2e', '#5a3a1e')
    item(c, rect(56, GY - 14, 59, GY - 11), '#b8bcc4', '#7a7e88')


@tool('bucket')
def v_bucket(c):
    pond = ell(54, GY - 3, 82, GY + 6)
    c.f(pond, '#4a88b0'); c.f(rect(60, GY, 66, GY), '#8cc4dc')
    gnome(c, 42, GY)
    b = poly([(47, GY - 7), (55, GY - 7), (54, GY - 1), (48, GY - 1)])
    item(c, b | line([(47, GY - 7), (51, GY - 11), (55, GY - 7)]), '#9aa2ac', '#6e7680')
    c.f(rect(48, GY - 7, 54, GY - 7), '#8cc4dc')


@tool('rest', 'dusk')
def v_rest(c):
    bench = rect(36, GY - 6, 60, GY - 4) | rect(38, GY - 4, 39, GY) | rect(57, GY - 4, 58, GY)
    item(c, bench, '#a06a3a', '#74462a')
    gnome(c, 44, GY - 6, pose='sit')
    for i, (zx, zy) in enumerate(((52, GY - 26), (56, GY - 31), (61, GY - 35))):
        c.f(rect(zx, zy, zx + 2 + i, zy) | rect(zx, zy + 2 + i, zx + 2 + i, zy + 2 + i) | line([(zx + 2 + i, zy), (zx, zy + 2 + i)]), '#f4eee0')


@tool('chat')
def v_chat(c):
    gnome(c, 36, GY)
    # villager: green hat, brown coat, facing left
    GN2 = dict(GN); GN.update(hat='#4e8a3c', hatd='#386a2a', coat='#a0603a', coatd='#74462a', beard='#c8a070', beardd='#a07c50')
    gnome(c, 60, GY, flip=True)
    GN.clear(); GN.update(GN2)
    bub = ell(40, GY - 34, 58, GY - 22) | poly([(46, GY - 24), (44, GY - 18), (50, GY - 23)])
    c.outline(bub); c.f(bub, '#f4eee0')
    c.f(rect(44, GY - 28, 45, GY - 27) | rect(48, GY - 28, 49, GY - 27) | rect(52, GY - 28, 53, GY - 27), '#74462a')


@tool('fire', 'night')
def v_fire(c):
    logs = line([(42, GY), (58, GY - 4)], 3) | line([(42, GY - 4), (58, GY)], 3)
    item(c, logs, '#8a5a2e', '#5a3a1e')
    fl = poly([(44, GY - 3), (50, GY - 18), (52, GY - 10), (55, GY - 15), (57, GY - 3)])
    c.f(fl, '#e8602e'); c.f(poly([(47, GY - 3), (51, GY - 12), (54, GY - 3)]), '#f4c84a')
    c.f(rect(50, GY - 5, 51, GY - 3), '#fff2b0')
    c.f(rect(53, GY - 24, 53, GY - 24) | rect(48, GY - 28, 48, GY - 28) | rect(56, GY - 31, 56, GY - 31), '#f4c84a')
    gnome(c, 68, GY, flip=True)
    item(c, line([(63, GY - 5), (56, GY - 2)], 1), '#8a5a2e', '#5a3a1e')


def card(name, state):
    fn, skyk = TOOLS[name]
    c = C()
    base, shade, rim, stitch = FELT[state]
    dy = 2 if state == 'sel' else 0          # pressed card sits 2 px lower, shorter drop shadow
    # drop shadow
    shadow = sh(rect(4, 6, 91, 107), 0, 3 - dy) & ~rect(4, 6 + dy, 91, 107 + dy)
    c.f(shadow & ~rect(0, 0, 0, 0), '#2a1a10')
    felt = rect(4, 6 + dy, 91, 104 + dy)
    for (a, b) in ((4, 6), (91, 6), (4, 104), (91, 104)):
        felt &= ~rect(a, b + dy, a, b + dy)
    c.outline(felt)
    c.shaded(felt, base, shade, rim, 2)
    # felt fuzz specks
    rng = np.random.default_rng(hash(name) & 0xffff)
    for _ in range(70):
        x, y = rng.integers(8, 88), rng.integers(10 + dy, 100 + dy)
        c.f(rect(x, y, x, y), shade if rng.random() < .6 else rim)
    # running stitch border
    st = np.zeros((H, W), bool)
    for x in range(9, 87, 3): st[9 + dy, x] = st[99 + dy, x] = True; st[9 + dy, x + 1] = st[99 + dy, x + 1] = True
    for y in range(12 + dy, 98 + dy, 3): st[y, 8] = st[y, 87] = True; st[y + 1, 8] = st[y + 1, 87] = True
    c.f(st, stitch)
    # framed vignette (drawn on its own layer, then clipped into the frame window)
    v = C()
    top, low = SKY[skyk]
    v.f(rect(0, 0, W - 1, H - 1), top)
    v.f(rect(0, 30, W - 1, 44), low)
    if skyk == 'night':
        for sx, sy in ((20, 16), (34, 22), (70, 14), (60, 26), (76, 30)): v.f(rect(sx, sy, sx, sy), '#f4eee0')
    elif skyk == 'dusk':
        sun = ell(66, 20, 76, 30); v.f(sun, '#f4c84a')
    else:
        v.f(ell(20, 16, 34, 22) | ell(26, 13, 38, 21), '#f4eee0')
    hill = ell(-10, 38, 50, 70) | ell(36, 42, 110, 76)
    v.f(hill, HILL[1] if skyk != 'night' else '#3e5a40')
    v.f(rect(0, GY, W - 1, H - 1), HILL[0] if skyk != 'night' else '#4a6a44')
    v.f(rect(0, GY, W - 1, GY), HILL[2] if skyk != 'night' else '#5e7e52')
    for gx in (18, 27, 75, 31, 79): v.f(rect(gx, GY + 3, gx, GY + 4) | rect(gx + 1, GY + 2, gx + 1, GY + 3), HILL[1])
    fn(v)
    win = rect(16, 16, 79, 61)
    vv = np.roll(v.px, dy, 0)
    c.px[sh(win, 0, dy)] = vv[sh(win, 0, dy)]
    frame = sh(rect(13, 13, 82, 64) & ~win, 0, dy)
    c.outline(rect(13, 13 + dy, 82, 64 + dy))
    c.px[sh(win, 0, dy)] = vv[sh(win, 0, dy)]
    c.shaded(frame, '#a06a3a', '#74462a', '#c08a52', 1)
    c.f(sh(rect(16, 16, 79, 16) | rect(16, 16, 16, 61), 0, dy), '#4a2c1a')   # inner shadow upper left
    for nx, ny in ((14, 14), (81, 14), (14, 63), (81, 63)): c.f(rect(nx, ny + dy, nx, ny + dy), '#e3c48c')
    # hanging ribbon sign (label blank)
    cords = line([(26, 64 + dy), (22, 73 + dy)]) | line([(69, 64 + dy), (73, 73 + dy)])
    c.f(cords, '#4a2c1a')
    r0 = RIB if state == 'idle' else ('#d8a040', '#a87428', '#f0c868')
    sign = poly([(12, 73 + dy), (83, 73 + dy), (79, 81 + dy), (83, 90 + dy), (12, 90 + dy), (16, 81 + dy)])
    c.outline(sign); c.shaded(sign, r0[0], r0[1], r0[2], 2)
    ss = np.zeros((H, W), bool)
    for x in range(20, 76, 3): ss[75 + dy, x] = ss[87 + dy, x] = True
    c.f(ss, r0[2])
    c.f(rect(22, 73 + dy, 23, 74 + dy) | rect(72, 73 + dy, 73, 74 + dy), '#e3c48c')   # pins
    if state == 'sel':   # selected: little gold leaf badge on the top right corner
        leaf = poly([(80, 4 + dy), (88, 4 + dy), (88, 12 + dy)])
        c.outline(leaf); c.shaded(leaf, '#f4c84a', '#c89a2a', '#fff2b0')
    return c


def save(c, path):
    Image.fromarray(c.px, 'RGBA').resize((W * 2, H * 2), Image.NEAREST).save(path, optimize=True)


if __name__ == '__main__':
    names = list(TOOLS)
    tiles = []
    for n in names:
        for st in ('idle', 'sel'):
            c = card(n, st)
            p = os.path.join(OUT, f'card_{n}_{st}.png')
            save(c, p); tiles.append(p)
    cols = 6
    rows = (len(tiles) + cols - 1) // cols
    sheet = Image.new('RGBA', (cols * (W * 2 + 8) + 8, rows * (H * 2 + 8) + 8), hx('#3a2a1e') + (255,))
    for i, p in enumerate(tiles):
        im = Image.open(p)
        sheet.alpha_composite(im, (8 + (i % cols) * (W * 2 + 8), 8 + (i // cols) * (H * 2 + 8)))
    sheet.save(os.path.join(OUT, 'preview.png'))
    print(len(tiles), 'cards')
