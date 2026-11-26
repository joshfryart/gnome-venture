#!/usr/bin/env python3
"""stoptiers_kit.py: POLISH helpers for the 96x96 adoption-tier stickers game/assets/img/stoptiers/<type>-<1..4>.png.

Staging only: reads the shipped file, retouches it, writes art-review/stopart/out/stoptiers/<name>.png and a side-by-side
art-review/stopart/out/_cmp/stoptiers-<name>.png (shipped | polished, 4x, on light and dark). Nothing under game/ is written.

House pass applied to every file (finish()):
  * hard 1-bit alpha (0 or 255), transparent pixels zeroed;
  * enclosed transparent holes filled (a sticker is one die-cut piece);
  * ONE outer outline, 2 px wide (= 1 art pixel at the set's 2x grid), pure black (RULINGS 1), grown where a file had 1 px;
  * the sticker's felt band gets the same light everywhere: a light rim where the outline is above / left,
    darker felt where it is below / right.
Per-file retouches go in the <set>_<n>.py scripts through paint() / remap() before finish().
"""
import os

from PIL import Image, ImageDraw

ROOT = '/home/user/gnome-venture'
SRC = os.path.join(ROOT, 'game/assets/img/stoptiers')
OUT = os.path.join(ROOT, 'art-review/stopart/out/stoptiers')
CMP = os.path.join(ROOT, 'art-review/stopart/out/_cmp')

BLACK = (0, 0, 0, 255)
CLEAR = (0, 0, 0, 0)
BAND = {'74462a': 'mid', '4a2c1a': 'deep', '2a1a10': 'dark', '8a5a35': 'mid', '693a28': 'mid'}
BAND_LIGHT = '#9a6b3f'    # line-2: lit felt on the upper-left rim
BAND_MID = '#74462a'
BAND_DARK = '#2a1a10'
N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))


def hexrgba(c):
    c = c.lstrip('#')
    return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def hexof(p):
    return '%02x%02x%02x' % p[:3]


def load(name):
    return Image.open(os.path.join(SRC, name + '.png')).convert('RGBA')


def paint(im, x0, y0, rows, legend, scale=2):
    """Paint a char map at art-pixel (x0, y0); each char is a scale x scale block. ' ' or '.' = keep."""
    for j, row in enumerate(rows):
        for i, ch in enumerate(row):
            if ch in ' .':
                continue
            col = CLEAR if legend[ch] is None else hexrgba(legend[ch])
            for dy in range(scale):
                for dx in range(scale):
                    im.putpixel(((x0 + i) * scale + dx, (y0 + j) * scale + dy), col)


def remap(im, box, table):
    """Recolour pixels inside box (x0, y0, x1, y1, full-res, x1/y1 exclusive) by hex table {'old': '#new'}."""
    x0, y0, x1, y1 = box
    for y in range(y0, y1):
        for x in range(x0, x1):
            p = im.getpixel((x, y))
            if p[3] and hexof(p) in table:
                im.putpixel((x, y), hexrgba(table[hexof(p)]))


def sil(im):
    W, H = im.size
    return {(x, y) for y in range(H) for x in range(W) if im.getpixel((x, y))[3] >= 128}


def fill_holes(im):
    """Transparent pockets not reachable from the canvas border become felt; their black ring becomes umber contour."""
    W, H = im.size
    s = sil(im)
    seen = set()
    stack = [(x, y) for x in range(W) for y in (0, H - 1)] + [(x, y) for y in range(H) for x in (0, W - 1)]
    stack = [p for p in stack if p not in s]
    seen.update(stack)
    while stack:
        x, y = stack.pop()
        for dx, dy in N4:
            q = (x + dx, y + dy)
            if 0 <= q[0] < W and 0 <= q[1] < H and q not in s and q not in seen:
                seen.add(q)
                stack.append(q)
    holes = [(x, y) for y in range(H) for x in range(W) if (x, y) not in s and (x, y) not in seen]
    hs = set(holes)
    for (x, y) in holes:
        im.putpixel((x, y), hexrgba('#4a2c1a'))
    for (x, y) in hs:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                q = (x + dx, y + dy)
                if q not in hs and q in s and im.getpixel(q)[:3] == (0, 0, 0):
                    im.putpixel(q, hexrgba(BAND_DARK))
    return len(holes)


def outline(im, width=2):
    """Outermost `width` px of the silhouette pure black; grow the silhouette where the black ring is thinner."""
    W, H = im.size
    s, depth = depths(im)
    blackw = 0
    while blackw < width:
        ring = [p for p, dd in depth.items() if dd == blackw]
        if sum(im.getpixel(p)[:3] == (0, 0, 0) for p in ring) < 0.5 * len(ring):
            break
        blackw += 1
    for _ in range(width - blackw):
        s = sil(im)
        add = {(x + dx, y + dy) for (x, y) in s for dx, dy in N4}
        for (x, y) in add - s:
            if 0 <= x < W and 0 <= y < H:
                im.putpixel((x, y), BLACK)
    s, depth = depths(im)
    for p, dd in depth.items():     # any non-black pixel left on the outer ring(s) becomes black
        if dd < width:
            im.putpixel(p, BLACK)
    return width - blackw


def depths(im, maxd=8):
    s = sil(im)
    depth = {}
    rest = set(s)
    d = 0
    while rest and d < maxd:
        ring = {p for p in rest if any((p[0] + dx, p[1] + dy) not in rest for dx, dy in N4)}
        for p in ring:
            depth[p] = d
        rest -= ring
        d += 1
    return s, depth


def band_light(im, ow=2, reach=2):
    """First `reach` felt-band px inside the black outline: lit where the outline is above/left, deeper where below/right."""
    s, depth = depths(im)
    edge = {p for p, d in depth.items() if d < ow}
    lit = shade = 0
    for (x, y), d in depth.items():
        if not ow <= d < ow + reach:
            continue
        h = hexof(im.getpixel((x, y)))
        if h not in BAND:
            continue
        ul = any((x, y - k) in edge or (x, y - k) not in s for k in range(1, reach + 1)) or \
            any((x - k, y) in edge or (x - k, y) not in s for k in range(1, reach + 1))
        dr = any((x, y + k) in edge or (x, y + k) not in s for k in range(1, reach + 1)) or \
            any((x + k, y) in edge or (x + k, y) not in s for k in range(1, reach + 1))
        if ul and not dr:
            im.putpixel((x, y), hexrgba(BAND_LIGHT if h != '2a1a10' else BAND_MID))
            lit += 1
        elif dr and not ul and h in ('74462a', '8a5a35', '693a28'):
            im.putpixel((x, y), hexrgba('#4a2c1a'))
            shade += 1
    return lit, shade


def binarise(im):
    W, H = im.size
    for y in range(H):
        for x in range(W):
            p = im.getpixel((x, y))
            if p[3] < 128:
                im.putpixel((x, y), CLEAR)
            elif p[3] != 255:
                im.putpixel((x, y), p[:3] + (255,))


def finish(name, im, grow_outline=True, light=True):
    binarise(im)
    rep = {'holes': fill_holes(im)}
    if grow_outline:
        rep['grown'] = outline(im)
    if light:
        rep['lit'], rep['shade'] = band_light(im)
    binarise(im)
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CMP, exist_ok=True)
    out = os.path.join(OUT, name + '.png')
    im.save(out)
    old = load(name)
    assert im.size == old.size and im.mode == old.mode == 'RGBA'
    alphas = {p[3] for p in im.getdata()}
    assert alphas <= {0, 255}, alphas
    rep['colours'] = len({p for p in im.getdata() if p[3]})
    compare(name, old, im)
    print(name, rep)
    return rep


def compare(name, old, new, S=4):
    W = old.width * S
    sheet = Image.new('RGB', (4 * W + 5 * 12, W + 34), '#d8d0bc')
    d = ImageDraw.Draw(sheet)
    for bi, bg in enumerate(('#f1ece0', '#2a1a10')):
        for k, im in enumerate((old, new)):
            x = 12 + (bi * 2 + k) * (W + 12)
            d.rectangle((x, 22, x + W - 1, 22 + W - 1), fill=bg)
            big = im.resize((W, W), Image.NEAREST)
            sheet.paste(big, (x, 22), big)
            d.text((x + 4, 6), ('shipped ' if k == 0 else 'polished ') + name, fill='#2a1a10')
    sheet.save(os.path.join(CMP, 'stoptiers-%s.png' % name))
