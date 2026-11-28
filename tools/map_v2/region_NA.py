#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for NA "The Maplewold" (band green, Lv 1-15).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow):
dark strata and fog outside, the cavern floor (the plan polygon) lit from inside with a
dithered green halo and a rim light, biome ground (prairie, maplewood, hazel, ridge,
frost, fern corner, blossom corner, waters), landmark props, glowing road trunks on the
layout polylines and the two exit tunnel mouths; a root ceiling and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one or two flat tones, no sprites, no water, no texture).

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_NA.py [--layout layout-NA.json] [--plan plan-NA.json]
                                    [--out game/assets/img/scenes/map2-NA.png]
                                    [--preview PREVIEW-2x.png]
Defaults for --layout / --plan: $MAP_V2_LAYOUT / $MAP_V2_PLAN, else the planning scratchpad
files next to this checkout.  --preview also writes a 960x540 nearest-neighbour check image
(art + placeholder markers at the stops and spread positions, thick gold roots, a few names).
"""
import argparse, json, math, os, random
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
SCRATCH = '/tmp/claude-0/-home-user-gnome-venture/30c9491a-86e7-530f-9f28-96d77dd01450/scratchpad'
W, H = 480, 270
yy, xx = np.mgrid[0:H, 0:W]
CODE = 'NA'
SEED = 7


def hx(s):
    return tuple(int(s[i:i + 2], 16) for i in (1, 3, 5))


# ---------------------------------------------------------------- palette (delve-3 / region-1)
PAL = {k: hx(v) for k, v in {
    'K': '#07050a',
    'S0': '#100b0d', 'S1': '#1a1311', 'S2': '#261b14', 'S3': '#33241a',
    'S4': '#44301f', 'S5': '#5a3f26', 'S6': '#7a5632',
    'D1': '#13111c', 'D2': '#1c1927', 'D3': '#272334', 'D4': '#353045',
    'FOG': '#4b4a60',
    'T1': '#8fd14f', 't1': '#34552a', 'T2': '#5ec4e8', 't2': '#214a5e',
    'T3': '#f2c94c', 't3': '#5e4a1c', 'T4': '#f08a3c', 't4': '#633319',
    'T5': '#b58cf0', 't5': '#3f2f63',
    'CR': '#fff3cf', 'GD': '#ffc857',
    'MY': '#b5a57c', 'MD': '#6e6652',
    'NW': '#7df0c0', 'ND': '#2f8f7a',
    'RD': '#d8402f', 'RK': '#8a1f1c', 'RH': '#ff8a6a',
    'GM': '#4f9a3a', 'GK': '#2a5c2e',
    'SN': '#e6cf8a', 'SD': '#c2a05a',
    'RE': '#b5482a',
    'AS': '#6e6a70', 'AL': '#a8a3a8',
    'WA': '#3f9fd0', 'WL': '#9be3f2',
    'PK': '#f29ac0', 'PL': '#ffd3e2',
    'WH': '#f6f6ee',
}.items()}
BRIGHT, DIM = 'T1', 't1'  # band green
B4 = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]])
BAY = (B4[yy % 4, xx % 4] + 0.5) / 16.0
BAY2 = (B4[(yy + 1) % 4, (xx + 2) % 4] + 0.5) / 16.0

img = np.zeros((H, W, 3), np.uint8)


def put(x, y, c):
    x = int(x); y = int(y)
    if 0 <= x < W and 0 <= y < H:
        img[y, x] = PAL[c]


def rect(x0, y0, x1, y1, c):
    img[max(0, y0):min(H, y1 + 1), max(0, x0):min(W, x1 + 1)] = PAL[c]


def paint(mask, c):
    img[mask] = PAL[c]


def vnoise(scale, seed):
    r = np.random.default_rng(seed)
    gh, gw = H // scale + 3, W // scale + 3
    g = r.random((gh, gw))
    fy = yy / scale; fx = xx / scale
    iy = fy.astype(int); ix = fx.astype(int)
    ty = fy - iy; tx = fx - ix
    ty = ty * ty * (3 - 2 * ty); tx = tx * tx * (3 - 2 * tx)
    a = g[iy, ix] * (1 - tx) + g[iy, ix + 1] * tx
    b = g[iy + 1, ix] * (1 - tx) + g[iy + 1, ix + 1] * tx
    return a * (1 - ty) + b * ty


def dil4(m):
    r = m.copy()
    r[1:] |= m[:-1]; r[:-1] |= m[1:]; r[:, 1:] |= m[:, :-1]; r[:, :-1] |= m[:, 1:]
    return r


def dil8(m):
    r = dil4(m)
    r[1:, 1:] |= m[:-1, :-1]; r[1:, :-1] |= m[:-1, 1:]; r[:-1, 1:] |= m[1:, :-1]; r[:-1, :-1] |= m[1:, 1:]
    return r


def ero4(m):
    return ~dil4(~m)


def grow(m, n):
    for i in range(n):
        m = dil8(m) if i % 2 else dil4(m)
    return m


def blur(a, r):
    k = 2 * r + 1
    p = np.pad(a, r, mode='edge').astype(float)
    c = np.cumsum(np.pad(p, ((1, 0), (0, 0))), axis=0)
    p = (c[k:] - c[:-k]) / k
    c = np.cumsum(np.pad(p, ((0, 0), (1, 0))), axis=1)
    return (c[:, k:] - c[:, :-k]) / k


def disk(x, y, r):
    return (xx - x) ** 2 + (yy - y) ** 2 <= r * r


def poly_mask(pts):
    im = Image.new('L', (W, H), 0)
    ImageDraw.Draw(im).polygon([tuple(p) for p in pts], fill=1, outline=1)
    return np.array(im, bool)


# ---------------------------------------------------------------- font 5x7
FONT_SRC = {
    'A': '.###./#...#/#...#/#####/#...#/#...#/#...#', 'B': '####./#...#/#...#/####./#...#/#...#/####.',
    'C': '.###./#...#/#..../#..../#..../#...#/.###.', 'D': '####./#...#/#...#/#...#/#...#/#...#/####.',
    'E': '#####/#..../#..../####./#..../#..../#####', 'F': '#####/#..../#..../####./#..../#..../#....',
    'G': '.###./#...#/#..../#.###/#...#/#...#/.###.', 'H': '#...#/#...#/#...#/#####/#...#/#...#/#...#',
    'I': '.###./..#../..#../..#../..#../..#../.###.', 'J': '..###/...#./...#./...#./...#./#..#./.##..',
    'K': '#...#/#..#./#.#../##.../#.#../#..#./#...#', 'L': '#..../#..../#..../#..../#..../#..../#####',
    'M': '#...#/##.##/#.#.#/#.#.#/#...#/#...#/#...#', 'N': '#...#/##..#/#.#.#/#..##/#...#/#...#/#...#',
    'O': '.###./#...#/#...#/#...#/#...#/#...#/.###.', 'P': '####./#...#/#...#/####./#..../#..../#....',
    'Q': '.###./#...#/#...#/#...#/#.#.#/#..#./.##.#', 'R': '####./#...#/#...#/####./#.#../#..#./#...#',
    'S': '.####/#..../#..../.###./....#/....#/####.', 'T': '#####/..#../..#../..#../..#../..#../..#..',
    'U': '#...#/#...#/#...#/#...#/#...#/#...#/.###.', 'V': '#...#/#...#/#...#/#...#/#...#/.#.#./..#..',
    'W': '#...#/#...#/#...#/#.#.#/#.#.#/##.##/#...#', 'X': '#...#/#...#/.#.#./..#../.#.#./#...#/#...#',
    'Y': '#...#/#...#/.#.#./..#../..#../..#../..#..', 'Z': '#####/....#/...#./..#../.#.../#..../#####',
    '-': '...../...../...../.###./...../...../.....', ' ': '...../...../...../...../...../...../.....',
    "'": '..#../..#../...../...../...../...../.....',
}
FONT = {k: v.split('/') for k, v in FONT_SRC.items()}


def text_w(s):
    return len(s) * 6 - 1


def text(x, y, s, c='CR', shadow='K'):
    for (ox, oy, col) in ((1, 1, shadow), (0, 0, c)):
        cx = x
        for ch in s:
            g = FONT.get(ch, FONT[' '])
            for r in range(7):
                for q in range(5):
                    if g[r][q] == '#':
                        put(cx + q + ox, y + r + oy, col)
            cx += 6


# ---------------------------------------------------------------- sprites
LET = {'k': 'K', 'g': 'GM', 'G': 'T1', 'd': 'GK', 'r': 'RD', 'R': 'RK', 'h': 'RH', 'o': 'T4', 'y': 'GD',
       'c': 'CR', 'w': 'WH', 'b': 'S5', 'B': 'S6', 'p': 'PK', 'P': 'PL', 'a': 'AS', 'A': 'AL', 'u': 'WA',
       'U': 'WL', 's': 'SN', 'S': 'SD', 'v': 'T5', 't': 'NW', 'e': 'RE', 'n': 'ND', '1': 'S1', '2': 'S2',
       '3': 'S3', '4': 'S4', 'D': 't1', 'm': 'MD', 'M': 'MY', 'f': 'FOG'}

TREE = ['..kkkk..', '.kGGggk.', 'kGGggggk', 'kGggggdk', 'kggggddk', '.kgdddk.', '..kbbk..', '..kbBk..', '..kkkk..']
TREE_S = ['.kkkk.', 'kGGgdk', 'kGggdk', '.kddk.', '.kbbk.', '.kkkk.']
BIGTREE = ['...kkkkkk...', '.kkGGGgggkk.', 'kGGGggggggdk', 'kGGgggggdddk', 'kggggdgdddkk', '.kkddkbkddk.',
           '...kkkbkkk..', '....kbBk....', '....kbBk....', '....kkkk....']
GIANT = ['......kkkkk......',
         '....kkGGGggkk....',
         '...kGGGgggggdk...',
         '..kGGgggggggddk..',
         '.kGGggggGGggdddk.',
         '.kGggggGGgggdddk.',
         'kGgggggggggddgddk',
         'kggggdggggdddgddk',
         'kgggggdgggdddddk.',
         '.kgggddgggdddddk.',
         '.kkgdddkdddddkk..',
         '..kkddkbkddkk....',
         '....kkkbBkkk.....',
         '......kbBk.......',
         '......kbBk.......',
         '.....kbbBBk......',
         '....kkkkkkkk.....']
PINE = ['...k...', '..kGk..', '..kgk..', '.kGgdk.', '.kggdk.', 'kGggddk', 'kkkbkkk', '..kbk..', '..kkk..']
SHROOM = ['..kkkk..', '.krwrrk.', 'krrrrwrk', 'kkkcckkk', '..kcSk..', '..kkkk..']
SHROOM_S = ['.kkk.', 'krwrk', 'kkckk', '.kck.', '.kkk.']
PEAK_S = ['...kk...', '..kwAk..', '.kwAaak.', 'kAAaaaak', 'kkkkkkkk']
CRAG = ['..kkk...', '.kAAak..', 'kAAaaakk', 'kAaaa1ak', 'kaaa11ak', 'kkkkkkkk']
STONE = ['.kkkk.', 'kAAaak', 'kAaaak', 'kkkkkk']
PEBBLE = ['.kk.', 'kAak', 'kkkk']
CAIRN = ['..kk..', '.kAak.', '.kkkk.', 'kAAaak', 'kkkkkk', 'kAaaak', 'kkkkkk']
CATTAIL = ['k.k..', 'b.bk.', 'bkbbk', 'gkgbk', 'gggk.', '.gg..']
REED = ['g.g', 'gkg', '.g.']
STUMP = ['.kkkk.', 'kBbbBk', 'kbBBbk', 'kkkkkk']
BUSH = ['.kkk.', 'kGgdk', 'kggdk', '.kkk.']
LAMP = ['.k.', 'kyk', 'kck', '.k.', '.b.', '.b.', 'kbk']
FERN = ['G.k.G', 'gG.Gg', 'dgGgd', '.dgd.', '..d..']
FERN_S = ['g.g', 'dGd', '.d.']
GOLDEN = ['y.y', 'yky', '.g.']
GOLDEN2 = ['.y.', 'yyy', 'kgk', '.g.']
SPIRE = ['...kk...', '..kwAk..', '..kAak..', '..kAak..', '.kwAaak.', '.kAAa1k.', '.kAaa1k.', 'kwAaaa1k',
         'kAAaa11k', 'kAaaa11k', 'kAaa111k', 'kkkkkkkk']
BEACON = ['kkkkkkk', 'kmMMMmk', '.kmmmk.', '..kAk..', '..kak..', '.kAaak.', '.kAaak.', 'kkkkkkk']
DOOR = ['..kkkkk..', '.kAAAAak.', 'kAa111aak', 'kAa1n1aak', 'kAa111aak', 'kAa111aak', 'kAa1n1aak', 'kAa111aak',
        'kkkkkkkkk']
GATEHOUSE = ['kkk.....kkk', 'kAk.....kAk', 'kAkkkkkkkAk', 'kAkbBbBbkak', 'kAkBbkbBkak', 'kakbBkBbkak',
             'kakBbkbBkak', 'kkkkkkkkkkk']
DEADTREE = ['b.kwwk.b', '.bkwck.b', '..bkkbb.', '...bb...', '...bB...', '...bB...', '..kbbk..', '..kkkk..']
LODGE = ['...kkk...', '..kBbBk..', '.kbBbBbk.', 'kBbbBbbBk', 'kbBk1kBbk', 'kkkkkkkkk']
RAFT = ['...k...', '...b...', 'kkkkkkk', 'kBbBbBk', 'kkkkkkk']
TAP_TREE = ['.kkkk.', 'kGGgdk', 'kGggdk', '.kddk.', '.kbbkA', '.kbbka', '.kkkk.']

MAPLE = {'g': 'T4', 'G': 'GD', 'd': 'RD'}
MAPLE_R = {'g': 'RD', 'G': 'T4', 'd': 'RK'}
MAPLE_H = {'g': 'RD', 'G': 'RH', 'd': 'RK'}
JUNGLE = {'g': 'GM', 'G': 'T1', 'd': 'GK'}
HAZEL = {'g': 'GK', 'G': 'GM', 'd': 't1'}
BIRCH = {'g': 'GM', 'G': 'T1', 'd': 'GK', 'b': 'AL', 'B': 'WH'}
CHERRY = {'g': 'PK', 'G': 'PL', 'd': 'RH'}
SNOWPINE = {'G': 'WH', 'g': 'GK', 'd': 't1'}
FROSTSTONE = {'A': 'WH', 'a': 'AL', '1': 'AS'}
WARMSTONE = {'A': 'AL', 'a': 'S6', '1': 'S5'}
CYANCAP = {'r': 'WA', 'w': 'WL'}


def spr_size(rows):
    return len(rows[0]), len(rows)


def spr(x, y, rows, over=None, anchor='bc'):
    h = len(rows); w = len(rows[0])
    x0, y0 = (x - w // 2, y - h + 1) if anchor == 'bc' else (x, y)
    for r, row in enumerate(rows):
        for q, ch in enumerate(row):
            if ch != '.':
                put(x0 + q, y0 + r, (over or {}).get(ch, LET[ch]))


# ---------------------------------------------------------------- geometry
def raster(pts):
    out = []
    for i in range(len(pts) - 1):
        x0, y0 = pts[i]; x1, y1 = pts[i + 1]
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for k in range(n + 1):
            p = (int(round(x0 + (x1 - x0) * k / n)), int(round(y0 + (y1 - y0) * k / n)))
            if not out or out[-1] != p:
                out.append(p)
    clean = []
    for p in out:
        if len(clean) >= 2:
            a = clean[-2]
            if abs(p[0] - a[0]) <= 1 and abs(p[1] - a[1]) <= 1:
                clean[-1] = p
                continue
        clean.append(p)
    return clean


def pixmask(px, r=0):
    m = np.zeros((H, W), bool)
    for x, y in px:
        if 0 <= x < W and 0 <= y < H:
            m[y, x] = True
    return grow(m, r)


def edge_pt(ex, ey, side):
    return {'N': (ex, 0), 'S': (ex, H - 1), 'E': (W - 1, ey), 'W': (0, ey)}[side]


# ================================================================ data
def load(layout_path, plan_path):
    L = json.load(open(layout_path))
    P = json.load(open(plan_path))
    slots = {int(k): v for k, v in L['slots'].items()}
    spread = {int(k): tuple(v) for k, v in P['spread'].items()}
    anchors = {int(k): int(v) for k, v in P['anchors'].items()}
    return L, P, slots, spread, anchors


def keep_circles(L, slots, spread):
    """(id, x, y, r): layout keep-clear circles of the town, stops and exits + r14 round every spread place."""
    out = []
    for c in L['clear']:
        s = slots.get(c['id'])
        if s is not None and s['type'] == 'off':
            continue  # off places moved: their keep circle is the spread one below
        out.append((c['id'], c['x'], c['y'], c['r']))
    for sid, (x, y) in spread.items():
        out.append((sid, x, y, 14))
    return out


# ================================================================ RENDER
def render(L, P, slots, spread, anchors):
    global img
    R = random.Random(SEED)
    img = np.zeros((H, W, 3), np.uint8)
    keeps = keep_circles(L, slots, spread)
    exits = {e['id']: e for e in L['exits']}

    roads = []
    for rd in L['roads']:
        pts = [tuple(p) for p in rd['pts']]
        last = rd['nodes'][-1]
        if last in exits:
            e = exits[last]
            pts = pts + [edge_pt(e['x'], e['y'], e['side'])]
        roads.append(raster(pts))
    road_px = [p for px in roads for p in px]
    road_m = pixmask(road_px)

    keep_m = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_m |= disk(x, y, r)
    keep_core = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_core |= disk(x, y, r - 4)
    # straight stop -> place lines: the game lays its thick roots there, keep them free of tall sprites
    root_px = []
    for sid, (x, y) in spread.items():
        a = slots.get(anchors.get(sid, 0))
        if a:
            root_px += raster([(a['x'], a['y']), (x, y)])
    root_corr = pixmask(root_px, 2)

    # ------------------------------------------------ floor shape: the plan polygon, edge broken by noise
    poly = poly_mask(P['polygon'])
    en = vnoise(5, SEED + 1)
    pd = grow(poly, 2); pe = ~grow(~poly, 2)
    F = np.where(en > 0.64, pd, np.where(en < 0.36, pe, poly))
    margin = (xx >= 4) & (xx < W - 4) & (yy >= 12) & (yy < H - 10)
    F &= margin
    F |= keep_m
    F |= pixmask(road_px, 4)  # roads, and the exit corridors to the frame edge
    F = ero4(dil4(dil4(F)))
    F = dil4(ero4(F)) | keep_m
    out_ = ~F
    reach = out_ & ((xx == 0) | (yy == 0) | (xx == W - 1) | (yy == H - 1))
    while True:
        nr = dil4(reach) & out_
        if (nr == reach).all():
            break
        reach = nr
    F |= out_ & ~reach
    depth = np.zeros((H, W), float)
    m = F.copy()
    for i in range(26):
        depth += m
        m = ero4(m)
    outd = np.zeros((H, W), float)
    m = F.copy()
    for i in range(18):
        m = dil8(m) if i % 2 else dil4(m)
        outd += ~m
    outd = 18 - outd

    # ------------------------------------------------ 1. FAR LAYER: strata + fog + halo
    n1 = vnoise(24, 1 + SEED); n2 = vnoise(6, 2 + SEED); n3 = vnoise(3, 3)
    strata = np.sin((yy + 7 * np.sin(xx / 37.0) + 14 * n1) / 5.0)
    v = 0.24 + 0.10 * n1 + 0.07 * n2 + 0.045 * strata + 0.04 * n3
    v -= 0.10 * (np.abs(xx - W / 2) / (W / 2)) ** 3
    v += 0.20 * np.clip(1 - outd / 12.0, 0, 1) ** 2
    idx = np.floor(v * 7 + BAY).astype(int).clip(0, 5)
    cool = np.clip((yy - 150) / 150.0, 0, 1) * 0.8 > BAY2
    WARM = ['S0', 'S1', 'S2', 'S3', 'S4', 'S5']
    COOL = ['S0', 'D1', 'D2', 'D3', 'D4', 'D4']
    for i in range(6):
        paint((idx == i) & ~cool, WARM[i]); paint((idx == i) & cool, COOL[i])
    paint((np.abs(strata) < 0.07) & (n2 > 0.56), 'S0')
    for _ in range(160):
        x = R.randrange(0, W); y = R.randrange(4, H - 4)
        if F[y, x] or outd[y, x] < 4:
            continue
        deep = y > 170
        put(x, y, 'D4' if deep else 'S5'); put(x + 1, y, 'D3' if deep else 'S4')
        if R.random() < .4:
            put(x, y - 1, 'FOG' if deep else 'S6')
    fogn = vnoise(16, 9)
    for k, y0 in enumerate((70, 150, 222)):
        yc = y0 + 3 * np.sin(xx / 29.0 + k) + 1.5 * np.sin(xx / 11.0 + 2 * k)
        dyf = np.abs(yy - yc)
        dens = np.clip((fogn - 0.30) * 2.2, 0, 1) * np.clip(1 - dyf / 5.0, 0, 1)
        fm = ~F & (outd > 3)
        paint(fm & (dens > BAY + 0.10) & (dyf > 1.5), 'D4')
        paint(fm & (dens > BAY + 0.10) & (dyf <= 1.5), 'FOG')
    hval = np.clip(1 - (outd - 4) / 11.0, 0, 1)
    paint(~F & (outd > 4) & (hval ** 1.5 > BAY + 0.04), DIM)
    paint(~F & (outd > 4) & (outd < 8) & (hval ** 3 > BAY + 0.35), BRIGHT)
    # aurora on the wall over Aurora Camp (cyan-white curtains, behind the rim)
    au = [p for p in P['props'] if p['kind'] == 'aurora_glow']
    for p in au:
        ax, ay = p['x'] - 8, p['y'] - 14
        e = ((xx - ax) / 26.0) ** 2 + ((yy - ay) / 22.0) ** 2
        cur = np.sin(xx / 2.6 + 3 * vnoise(8, 33)) > 0.15
        zone_a = ~F & (e < 1) & (outd > 2)
        lv = np.clip(1 - e, 0, 1)
        paint(zone_a & cur & (lv > BAY * 0.9), 'ND')
        paint(zone_a & cur & (lv > BAY * 0.6 + 0.35) & ((xx + yy) % 2 == 0), 'NW')
    for _ in range(70):
        x = R.randrange(2, W - 3); y = R.randrange(14, H - 14)
        if outd[y, x] < 7 or F[y, x]:
            continue
        b, dm = R.choice([('T2', 't2'), ('T5', 't5'), ('NW', 'ND'), ('GD', 't3'), (BRIGHT, DIM)])
        put(x, y, b); put(x, y + 1, dm)
        if R.random() < .3:
            put(x, y - 1, 'WH')

    # ------------------------------------------------ 2. ZONES from the plan biomes (noisy edges)
    zone = np.full((H, W), 'base', dtype=object)
    zmask = {}
    water = np.zeros((H, W), bool)
    brook_px = []
    order = ['prairie', 'maple', 'hazel', 'jungle', 'blossom', 'smoke', 'ridge', 'frost']
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        t = b['type']
        if t == 'water' and b['shape'] == 'polygon' and len(b['points']) > 10:
            # the Meltwater Brook: the polygon is a thin band; draw its centre line
            pts = b['points']; half = len(pts) // 2
            cl = [((pts[k][0] + pts[-1 - k][0]) / 2.0, (pts[k][1] + pts[-1 - k][1]) / 2.0) for k in range(half)]
            brook_px = raster(cl)
            continue
        if b['shape'] == 'polygon':
            s = blur(poly_mask(b['points']).astype(float), 3)
            m = s + 0.5 * (n - 0.5) > 0.5
        else:
            e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
            m = e + 0.35 * (n - 0.5) < 1
        note = b.get('note', '')
        if t == 'water':
            water |= m
            continue
        key = {'prairie': 'prairie', 'ridge': 'ridge', 'frost': 'frost', 'jungle': 'jungle', 'blossom': 'blossom'}.get(t)
        if t == 'maplewood':
            key = 'hazel' if 'Hazel' in note else 'maple'
        if t == 'ridge' and 'Smokecap' in note:
            key = 'smoke'
        zmask.setdefault(key, np.zeros((H, W), bool))
        zmask[key] |= m
    for key in order:
        if key in zmask:
            zone[zmask[key] & F] = key

    RAMPS = {
        'base': ['t1', 'GK', 'GM', 'T1'], 'prairie': ['t1', 'GK', 'GM', 'T1'], 'maple': ['t1', 'GK', 'GM', 'GM'],
        'hazel': ['t1', 'GK', 'GK', 'GM'], 'jungle': ['t1', 'GK', 'GK', 'GM'], 'blossom': ['t1', 'GK', 'GM', 'T1'],
        'ridge': ['S3', 'S4', 'AS', 'AL'], 'smoke': ['S4', 'S5', 'AS', 'AL'], 'frost': ['t2', 'AS', 'AL', 'WH'],
    }
    BIAS = {'prairie': 0.08, 'maple': -0.04, 'hazel': -0.02, 'jungle': 0.10, 'ridge': 0.02, 'frost': 0.0}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.14 + 0.46 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.24 * np.exp(-(dt / 80.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.22 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    lv = lightv + np.where(keep_m, 0, 0.14 * (tex - 0.5))
    gi = np.floor(lv * 4 - 0.4 + (BAY - 0.5) * 0.9).astype(int).clip(0, 3)
    # plain floor in the keep circles: no texture noise (lv above), stone / frost capped below their glare tone
    rocky = (zone == 'ridge') | (zone == 'smoke') | (zone == 'frost')
    gi = np.where(keep_m & rocky, np.clip(gi, 1, 2), gi)
    for zname, ramp in RAMPS.items():
        zm = F & (zone == zname)
        for i in range(4):
            paint(zm & (gi == i), ramp[i])
    inner = F & ~ero4(F)
    for zname, ramp in RAMPS.items():
        paint(inner & (zone == zname), ramp[0])
    busyok = F & ~keep_m & (depth > 2)
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    # stone: strata cracks + glints;  frost: WL/WH rime dither
    sn = vnoise(5, 61)
    crk = (np.abs(np.sin((xx * 0.55 + yy + 14 * sn) / 3.2)) < 0.16) & (vnoise(3, 62) > 0.45)
    for zname in ('ridge', 'smoke', 'frost'):
        ramp = RAMPS[zname]
        stz = busyok & (zone == zname)
        paint(stz & crk & (gi >= 1), ramp[0] if zname != 'frost' else 'AS')
        paint(stz & dil4(crk) & ~crk & (yy % 2 == 0) & (gi >= 1) & (vnoise(1, 63) > 0.55), ramp[3])
    fz = busyok & (zone == 'frost')
    paint(fz & (vnoise(4, 64) > 0.55) & (BAY > 0.7) & (gi <= 2), 'WL')
    paint(fz & (vnoise(1, 65) > 0.93), 'WH')
    # hazel end: fog dither drifting in from the Mistmoor mouth
    hz = busyok & (zone == 'hazel')
    paint(hz & (vnoise(9, 66) > 0.45) & ((xx + 2 * yy) % 5 == 0), 'FOG')
    # fern corner: dark fronds texture
    jz = busyok & (zone == 'jungle')
    paint(jz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 'GK')
    # rim: K outline, band-colour rim light, dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')

    # ------------------------------------------------ 4. WATERS (never inside a keep circle; dry ground under each)
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # dry islands: a little wobble on the shore line
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 1 + 3 * isl
    wn = vnoise(6, 41)
    water = water & F & (depth > 2) & ~keep_wet & ~pixmask(road_px, 3)
    # the Beaver Pond is broken by green hummocks
    pond_poly = [b for b in P['biomes'] if b['type'] == 'water' and b['shape'] == 'polygon' and len(b['points']) <= 10]
    if pond_poly:  # a few extra hummocks besides the dry islands under the places
        pm = poly_mask(pond_poly[0]['points'])
        water &= ~(pm & (wn < 0.22))
    water = ero4(dil4(water)) & ~keep_wet & F & ~pixmask(road_px, 3)
    water &= ~dil4(ero4(ero4(~water)))  # drop slivers
    # the dam: the pool stays north of the dam line at the Dam Debt
    dam = None
    for p in P['props']:
        pass
    pool_b = [b for b in P['biomes'] if b['type'] == 'water' and b['shape'] == 'ellipse' and 'dam' in b.get('note', '').lower()]
    dam_sid = None
    for sid, (x, y) in spread.items():
        s = slots.get(sid)
        if s and 'Dam' in s['loc']['name']:
            dam_sid = sid
    if pool_b and dam_sid:
        b = pool_b[0]; dx_, dy_ = spread[dam_sid]
        e = ((xx - b['cx']) / (b['rx'] + 1)) ** 2 + ((yy - b['cy'] + 2) / (b['ry'])) ** 2 <= 1
        dam_y = dy_ - 10
        pool_m = e & (yy < dam_y) & F & ~pixmask(road_px, 3)
        water |= pool_m
        dam = (int(b['cx']), dam_y, int(b['rx']))
    # the Meltwater Brook: 3 px; 1 px inside the dam circle
    brook_m = np.zeros((H, W), bool)
    if brook_px:
        thin = pixmask(brook_px)
        wide = pixmask(brook_px, 1)
        inkeep = np.zeros((H, W), bool)
        for (sid, x, y, r) in keeps:
            if sid != dam_sid:
                inkeep |= disk(x, y, r + 1)
        dk = disk(*spread[dam_sid], 15) if dam_sid else np.zeros((H, W), bool)
        brook_m = ((wide & ~dk) | (thin & dk)) & F & ~inkeep
    occ_water = water | brook_m
    sh = dil8(water) & ~water & F & ~keep_m
    paint(sh, 't1')
    paint(dil4(brook_m) & ~brook_m & F & ~keep_m & ~water, 'GK')
    paint(water, 'WA')
    deep = ero4(ero4(water))
    paint(deep & (BAY > 0.45), 't2')
    paint(ero4(deep) & (BAY > 0.2), 't2')
    wall_side = water & (outd < 1) & dil8(dil8(dil8(~F)))
    paint(water & grow(~F, 4) & (BAY > 0.3), 'D2')
    paint(water & ~dil4(~water) & (yy % 3 == 0) & ((xx * 3 + yy) % 5 == 0), 'WL')
    paint(water & ~deep & (yy % 4 == 1) & (np.sin(xx / 3.0 + yy) > 0.8), 'WL')
    paint(brook_m, 'WA')
    paint(brook_m & ((xx + yy) % 4 == 0), 'WL')
    # fog band over the North Mere
    mere = [b for b in P['biomes'] if b['type'] == 'water' and 'Mere' in b.get('note', '')]
    if mere:
        b = mere[0]
        fb = water & (np.abs(yy - (b['cy'] - 6)) < 3) & ((xx + yy) % 3 == 0) & (vnoise(8, 71) > 0.4)
        paint(fb, 'FOG')
    if dam:
        cx, dy_, rx = dam
        for x in range(cx - rx, cx + rx + 1):
            for y in (dy_ - 1, dy_):
                if 0 <= y < H and (occ_water[y - 1, x] or occ_water[y, x] or brook_m[y + 1, x]) and F[y, x]:
                    put(x, y, 'S6' if (x + y) % 3 else 'S5')
            if occ_water[dy_ - 2, x] or brook_m[dy_ + 1, x]:
                put(x, dy_ + 1, 'K')

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    protect = keep_pad | near_road | root_corr | dil4(occ_water)
    free = F & ~protect & (depth >= 2)
    free_wet = F & ~(keep_pad | near_road | root_corr) & (depth >= 1)  # for props that stand in water
    occ = np.zeros((H, W), bool)
    placed = []

    def fits(x0, y0, w, h, pad=1, where=None):
        where = free if where is None else where
        if x0 - pad < 0 or y0 - pad < 0 or x0 + w + pad > W or y0 + h + pad > H:
            return False
        sl = (slice(y0 - pad, y0 + h + pad), slice(x0 - pad, x0 + w + pad))
        return where[sl].all() and not occ[sl].any()

    def try_place(x, y, rows, over=None, pad=1, where=None):
        w, h = spr_size(rows)
        x0, y0 = x - w // 2, y - h + 1
        if not fits(x0, y0, w, h, pad, where):
            return False
        occ[y0:y0 + h, x0:x0 + w] = True
        placed.append((y, x, rows, over))
        return True

    def near(tx, ty, rows, over=None, maxd=12, pad=1, where=None):
        best = None
        w, h = spr_size(rows)
        for y in range(max(4, ty - maxd), min(H - 2, ty + maxd + 1)):
            for x in range(max(4, tx - maxd), min(W - 4, tx + maxd + 1)):
                d = (x - tx) ** 2 + (y - ty) ** 2
                if d > maxd * maxd or (best and d >= best[0]):
                    continue
                if fits(x - w // 2, y - h + 1, w, h, pad, where):
                    best = (d, x, y)
        if best:
            try_place(best[1], best[2], rows, over, pad, where)
            return best[1:]
        return None

    def cluster(tx, ty, choices, n, spread_r=9, pad=0, where=None, tries=300):
        got = 0
        for _ in range(tries):
            if got >= n:
                break
            x = tx + R.randint(-spread_r, spread_r); y = ty + R.randint(-spread_r * 2 // 3, spread_r * 2 // 3)
            rows, over = R.choice(choices)
            if try_place(x, y, rows, over, pad, where):
                got += 1
        return got

    def scatter(choices, n, where, tries=3000, pad=1):
        got = 0
        cy, cx = np.nonzero(where)
        if len(cx) == 0:
            return 0
        for _ in range(tries):
            if got >= n:
                break
            i = R.randrange(len(cx))
            x, y = int(cx[i]), int(cy[i])
            rows, over = R.choice(choices)
            if try_place(x, y, rows, over, pad):
                got += 1
        return got

    log = []
    special = []  # (callable) drawn after the sprites
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        if k == 'giant_maple':
            got = near(x, y + 6, GIANT, MAPLE_R, 14, 1)
        elif k == 'maple_cluster':
            got = cluster(x, y, [(TREE, MAPLE_R), (TREE, MAPLE), (BIGTREE, MAPLE_R), (TREE_S, MAPLE_H), (TREE_S, MAPLE)], n, 12)
        elif k == 'sugar_taps':
            got = cluster(x, y, [(TAP_TREE, MAPLE_R), (TAP_TREE, MAPLE)], n, 9)
        elif k == 'cairn_row':
            got = 0
            for i in range(n):
                got += bool(near(x - (n - 1) * 4 + i * 8, y, CAIRN, None, 5, 0))
        elif k == 'cairnback_beacon':
            got = near(x, y, BEACON, None, 10, 0, where=F & ~keep_pad & ~near_road & ~root_corr)
        elif k == 'hollow_peak_spire':
            got = near(x, y, SPIRE, None, 12, 0, where=F & ~keep_pad & ~near_road & ~root_corr)
        elif k == 'aurora_glow':
            got = 'wall'
            fl = free & disk(x + 8, y + 10, 18) & (depth < 7)
            paint(fl & ((xx + yy) % 3 == 0) & (vnoise(3, 34) > 0.45), 'ND')
        elif k == 'snow_drift':
            got = cluster(x, y, [(PINE, SNOWPINE), (STONE, FROSTSTONE), (PEBBLE, FROSTSTONE)], n, 10)
            sd = free & disk(x, y, 12) & (vnoise(3, 35) > 0.5)
            paint(sd & ~occ, 'WH'); paint(sd & ~occ & (BAY > 0.6), 'WL')
        elif k == 'wild_rice_paddy':
            pw, ph = 16, 8
            x0, y0 = x - pw // 2, y - ph // 2
            sl = (slice(y0 - 1, y0 + ph + 1), slice(x0 - 1, x0 + pw + 1))
            if free_wet[sl].all():
                rect(x0 - 1, y0 - 1, x0 + pw, y0 + ph, 'S5')
                rect(x0, y0, x0 + pw - 1, y0 + ph - 1, 'WA')
                for yy_ in range(y0, y0 + ph):
                    for xx_ in range(x0, x0 + pw):
                        if yy_ % 2 == 0 and xx_ % 2 == (yy_ // 2) % 2:
                            put(xx_, yy_, 'SD')
                        elif yy_ % 2 == 1 and xx_ % 4 == 1:
                            put(xx_, yy_, 'GM')
                rect(x0 + pw // 2, y0, x0 + pw // 2, y0 + ph - 1, 'S5')
                occ[sl] = True
                got = 1
            else:
                got = None
        elif k == 'ferry_raft':
            got = None
            for (dx, dy) in [(0, 0), (3, 1), (-3, 1), (6, 2), (-6, 2), (0, 3), (8, 0), (-8, 0)]:
                xs, ys = x + dx, y + dy
                if water[ys - 1:ys + 1, xs - 4:xs + 4].all() and not keep_pad[ys - 5:ys + 1, xs - 4:xs + 4].any():
                    spr(xs, ys, RAFT); got = (xs, ys); break
        elif k == 'ice_stalactites':
            got = 0
            for i in range(n):
                cx = x - (n - 1) * 3 + i * 6 + R.randint(-1, 1)
                col = np.nonzero(F[:, cx])[0]
                if len(col) == 0:
                    continue
                ty = col[0]
                ln = R.randint(4, 8)
                if keep_pad[ty:ty + ln + 1, cx - 1:cx + 2].any() or occ_water[ty:ty + ln, cx].any():
                    continue
                for j in range(ln):
                    put(cx, ty + j, 'WH' if j < ln // 2 else 'WL')
                    if j < ln - 3:
                        put(cx + 1, ty + j, 'WL')
                        put(cx - 1, ty + j, 'K')
                put(cx, ty + ln, 'K'); put(cx + 1, ty + ln - 2, 'K')
                got += 1
            # the meltwater spring at the brook head
            if brook_px:
                bx, by = brook_px[0]
                pool_s = disk(bx, by + 1, 3) & F & ~keep_pad
                paint(dil8(pool_s) & ~pool_s & F & ~keep_pad, 'WH'); paint(pool_s, 'WA'); put(bx - 1, by, 'WL')
        elif k == 'sealed_door_north_rim':
            # set into the wall: find the floor edge above (x, y)
            col = np.nonzero(F[:, x])[0]
            ty = col[0] if len(col) else y
            spr(x, ty + 3, DOOR)
            got = (x, ty + 3)
        elif k == 'frost_boulders':
            got = cluster(x, y, [(STONE, FROSTSTONE), (CRAG, FROSTSTONE), (PEBBLE, FROSTSTONE), (PEAK_S, None)], n, 9)
        elif k == 'owl_perch':
            got = near(x, y, DEADTREE, None, 10, 0)
        elif k in ('footbridge', 'beaver_dam_causeway'):
            # sits on a road where the brook passes under: planks across the brook, the road goes over them
            bx, by = x, y
            if brook_px:
                bx, by = min(brook_px, key=lambda q: (q[0] - x) ** 2 + (q[1] - y) ** 2)
            if k == 'footbridge':
                rect(bx - 3, by - 2, bx + 3, by + 2, 'K'); rect(bx - 2, by - 2, bx + 2, by + 2, 'S6')
                for j in (-2, 0, 2):
                    rect(bx - 2, by + j, bx + 2, by + j, 'S5')
            else:
                for i in range(-5, 6):
                    put(bx + i, by + (i % 2) - 1, 'S5' if i % 2 else 'S6'); put(bx + i, by + 1, 'K')
            got = (bx, by)
        elif k == 'beaver_lodge':
            got = near(x, y, LODGE, None, 8, 0, where=free_wet)
        elif k == 'reed_bed':
            shore = dil8(dil8(water)) & ~water & free
            got = 0
            for _ in range(400):
                if got >= n * 3:
                    break
                xs = x + R.randint(-24, 24); ys = y + R.randint(-18, 18)
                if 0 <= xs < W and 0 <= ys < H and shore[ys, xs]:
                    got += try_place(xs, ys, R.choice([CATTAIL, REED, REED]), None, 0, where=free | shore)
        elif k == 'goldenrod_drift':
            got = cluster(x, y, [(GOLDEN, None), (GOLDEN2, None), (GOLDEN, None)], n * 2, 12)
            gd = free & ~occ & disk(x, y, 13) & (vnoise(1, 36 + x) > 0.78)
            paint(gd, 'GD')
        elif k == 'red_cap_mushrooms':
            got = cluster(x, y, [(SHROOM, None), (SHROOM_S, None)], n, 8)
        elif k == 'fern_fronds':
            got = cluster(x, y, [(FERN, JUNGLE), (FERN_S, JUNGLE), (FERN, None)], n, 12)
        elif k == 'hanging_vines':
            got = 0
            for i in range(n * 2):
                vx = x - 10 + R.randint(0, 20); vy = y - 10 + R.randint(0, 14)
                # walk to the nearest wall pixel to the west / south
                ln = R.randint(5, 10)
                if keep_pad[vy:vy + ln, vx - 1:vx + 2].any():
                    continue
                for j in range(ln):
                    X = vx + int(round(1.2 * math.sin(j / 2.0 + i)))
                    put(X, vy + j, 'GK' if j % 3 else 'GM')
                    if j % 3 == 1:
                        put(X + 1, vy + j, 'T1')
                got += 1
        elif k == 'smokecap_boulders':
            got = cluster(x, y, [(CRAG, WARMSTONE), (STONE, WARMSTONE), (PEBBLE, WARMSTONE)], n, 9)
        elif k == 'hazel_thicket':
            got = cluster(x, y, [(TREE, HAZEL), (TREE_S, HAZEL), (TREE, BIRCH), (TREE_S, BIRCH)], n, 12)
        elif k == 'cherry_trees':
            got = cluster(x, y, [(TREE, CHERRY), (TREE_S, CHERRY), (BIGTREE, CHERRY)], n, 12)
        elif k == 'clovercove_gatehouse':
            got = near(x, y, GATEHOUSE, None, 8, 0, where=F & ~keep_pad & ~near_road & ~root_corr)
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter (prairie stays open; tall things in the woods)
    zf = lambda z: free & (zone == z)
    if os.environ.get("DEBUG"):
        for z in ("maple", "jungle", "base", "hazel", "blossom", "prairie"):
            print("  free", z, int(zf(z).sum()), int((F & (zone == z)).sum()))
    scatter([(TREE, MAPLE_R), (TREE, MAPLE), (BIGTREE, MAPLE_R), (TREE_S, MAPLE_H), (TREE_S, MAPLE), (TREE, MAPLE_H)], 95, zf('maple'), pad=0)
    scatter([(TREE, HAZEL), (TREE_S, HAZEL), (TREE, BIRCH), (TREE_S, BIRCH), (PINE, HAZEL)], 40, zf('hazel'), pad=0)
    scatter([(FERN, JUNGLE), (FERN, None), (FERN_S, JUNGLE), (BIGTREE, JUNGLE), (TREE, JUNGLE), (BUSH, None), (FERN, JUNGLE)], 110, zf('jungle'), pad=0)
    scatter([(TREE, CHERRY), (TREE_S, CHERRY), (BUSH, None)], 20, zf('blossom'), pad=0)
    scatter([(CRAG, None), (PEAK_S, None), (STONE, None), (PEBBLE, None), (CAIRN, None), (CRAG, None)], 60, zf('ridge'), pad=0)
    scatter([(STONE, WARMSTONE), (PEBBLE, WARMSTONE)], 6, zf('smoke'), pad=0)
    scatter([(STONE, FROSTSTONE), (PEBBLE, FROSTSTONE), (PINE, SNOWPINE), (CRAG, FROSTSTONE)], 34, zf('frost'), pad=0)
    scatter([(TREE_S, MAPLE), (TREE, MAPLE_R), (TREE_S, None), (PINE, None), (BUSH, None), (STUMP, None), (TREE, None)], 80, zf('base'), pad=0)
    scatter([(BUSH, None), (GOLDEN, None), (GOLDEN2, None)], 16, zf('prairie'), pad=1)
    scatter([(SHROOM_S, None), (SHROOM_S, CYANCAP)], 8, free & (zone != 'frost'), pad=0)
    # flowers: blossom petals, goldenrod on the prairie, meadow flowers on the base floor
    fl = free & ~occ & ~dil4(occ)
    paint(fl & (zone == 'blossom') & (vnoise(1, 81) > 0.82), 'PL')
    paint(fl & (zone == 'blossom') & (vnoise(1, 82) > 0.90), 'PK')
    paint(fl & (zone == 'prairie') & (vnoise(1, 83) > 0.90) & (vnoise(8, 84) > 0.55), 'GD')
    fpix = fl & (zone == 'base') & (vnoise(1, 77) > 0.90) & (vnoise(8, 78) > 0.66)
    sel = (xx * 7 + yy * 13) % 4
    for i, c in enumerate(['GD', 'CR', 'RH', 'T4']):
        paint(fpix & (sel == i), c)
    paint(fl & (zone == 'jungle') & (vnoise(1, 85) > 0.93) & (vnoise(6, 86) > 0.5), 'PK')
    leaf = free & ~occ & (zone == 'maple') & (vnoise(1, 91) > 0.90)
    paint(leaf & ((xx + yy) % 2 == 0), 'T4'); paint(leaf & ((xx + yy) % 2 == 1), 'RD')

    # lanterns beside the trunks
    lamp_cand = pixmask(road_px, 6) & ~pixmask(road_px, 4) & free & ~occ
    ys, xs = np.nonzero(lamp_cand)
    idxs = list(range(len(xs)))
    R.shuffle(idxs)
    lamp_at = []
    for i in idxs:
        x, y = int(xs[i]), int(ys[i])
        if any((x - a) ** 2 + (y - b) ** 2 < 34 ** 2 for a, b in lamp_at):
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'GD')
    for (y, x, rows, over) in sorted(placed, key=lambda t: t[0]):
        spr(x, y, rows, over)

    # ------------------------------------------------ 6. ROADS: glowing mycelium trunks (no trails)
    for px in roads:
        for (x, y) in px:
            for ox in range(-3, 4):
                for oy in range(-3, 4):
                    if 4 < ox * ox + oy * oy <= 10 and (x + ox + y + oy) % 2 == 0:
                        X, Y = x + ox, y + oy
                        if 0 <= X < W and 0 <= Y < H and F[Y, X] and not occ_water[Y, X]:
                            put(X, Y, 'S6')
    rr = random.Random(5)
    for px in roads:
        for i in range(6, len(px) - 6, 8):  # hyphae
            x, y = px[i]
            if keep_m[y, x] or rr.random() > .7:
                continue
            sx, sy = rr.choice([(1, 1), (-1, 1), (1, -1), (-1, -1)])
            for t in range(2, rr.randint(4, 7)):
                X, Y = x + sx * t, y + sy * ((t + 1) // 2)
                if 0 <= X < W and 0 <= Y < H and not keep_m[Y, X] and not occ_water[Y, X]:
                    put(X, Y, 'SD')
    for px in roads:
        for (x, y) in px:
            for ox, oy in ((0, 2), (1, 2), (-1, 2), (2, 1), (-2, 1)):
                X, Y = x + ox, y + oy
                if 0 <= X < W and 0 <= Y < H and not road_m[Y, X] and F[Y, X]:
                    put(X, Y, 't1')
    for px in roads:
        for (x, y) in px:
            for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, 1)):
                X, Y = x + ox, y + oy
                if 0 <= X < W and 0 <= Y < H and not road_m[Y, X]:
                    put(X, Y, 'GD' if (ox, oy) in ((1, 0), (-1, 0), (0, -1)) else 'S6')
    for px in roads:
        for (x, y) in px:
            put(x, y, 'CR')
    for px in roads:  # pulse knots between the stops
        for i in range(5, len(px) - 3, 12):
            x, y = px[i]
            if keep_m[y, x]:
                continue
            for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                put(x + ox, y + oy, 'CR')
            put(x, y, 'WH')
    # exit tunnel mouths: a dark arch round the corridor and a warm glow where the trunk leaves the floor
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        for oy in range(-7, 8):
            for ox in range(-7, 8):
                X, Y = ex + ox, ey + oy
                if not (0 <= X < W and 0 <= Y < H) or road_m[Y, X]:
                    continue
                d2 = ox * ox + oy * oy
                if d2 <= 16 and (ox + oy) % 2 == 0 and not F[Y, X]:
                    put(X, Y, 'GD' if d2 <= 6 else 'S6')
        # mouth lips: two rock jambs either side of the corridor
        for s in (-1, 1):
            for j in range(0, 9):
                if e['side'] in ('N', 'S'):
                    X = ex + s * 6; Y = (H - 1 - j) if e['side'] == 'S' else j
                    put(X, Y, 'K'); put(X + s, Y, 'S4' if j % 3 else 'S5'); put(X + 2 * s, Y, 'K')
                else:
                    Y = ey + s * 6; X = (W - 1 - j) if e['side'] == 'E' else j
                    put(X, Y, 'K'); put(X, Y + s, 'S4' if j % 3 else 'S5'); put(X, Y + 2 * s, 'K')

    # ------------------------------------------------ 7. NEAR LAYER: ceiling roots, stalactites, stalagmites
    keep = keep_m | pixmask(road_px, 4)

    def spike(x0, w, h, up):
        while h > 1:
            ok = True
            for i in range(w):
                t = 1 - abs((i + 0.5) / w * 2 - 1)
                hh_ = int(round(h * t ** 0.8))
                for j in range(hh_ + 2):
                    y = (H - 1 - j) if up else j
                    X = x0 + i
                    if 0 <= X < W and keep[y, X]:
                        ok = False; break
                if not ok:
                    break
            if ok:
                break
            h -= 1
        if h <= 1:
            return
        for i in range(w):
            t = 1 - abs((i + 0.5) / w * 2 - 1)
            hh_ = int(round(h * t ** 0.8))
            for j in range(hh_ + 1):
                y = (H - 1 - j) if up else j
                c = 'S1'
                if i <= w * 0.3 and j < hh_:
                    c = 'S4' if up else 'S3'
                if j >= hh_ or i == 0 or i == w - 1:
                    c = 'K'
                if c == 'S1' and (i + j) % 5 == 0:
                    c = 'S2'
                put(x0 + i, y, c)

    RS = random.Random(SEED + 3)
    for up in (False, True):
        x = -3
        while x < W:
            w = RS.randint(5, 13) if not up else RS.randint(6, 16)
            h = RS.randint(5, 14) if not up else RS.randint(4, 13)
            spike(x, w, h, up)
            x += w - RS.randint(0, 2)
    for x in range(W):
        for j in range(0, 3):
            if not keep[j, x]:
                put(x, j, 'K')
            if not keep[H - 1 - j, x]:
                put(x, H - 1 - j, 'K')

    def root(x0, y1, thick, seed):
        r = random.Random(seed)
        ph = r.uniform(0, 6)
        pts = []
        for y in range(0, y1 + 1):
            x = x0 + int(round(2.2 * math.sin(y / 5.0 + ph) + 1.0 * math.sin(y / 2.3 + ph)))
            pts.append((x, y))
        for (x, y) in pts:
            if keep_pad[min(y + 3, H - 1), max(0, min(W - 1, x))] or occ_water[min(y + 1, H - 1), max(0, min(W - 1, x))]:
                return False
        for (x, y) in pts:
            t = thick if y < y1 - 5 else 1
            rect(x - 1, y, x + t, y, 'K')
        for (x, y) in pts:
            t = thick if y < y1 - 5 else 1
            rect(x, y, x + t - 1, y, 'S5')
            put(x, y, 'S6')
        x, y = pts[-1]
        put(x, y + 1, 'K')
        for k in range(3, len(pts) - 4, 7):
            x, y = pts[k]
            sgn = r.choice([-1, 1])
            for t in range(1, r.randint(3, 6)):
                X, Y = x + sgn * (t + (thick if sgn > 0 else 0)), y + t
                if 0 <= X < W and not keep[Y, X]:
                    put(X, Y, 'S5')
        return True

    # hanging mycelium roots: thickest over the town
    tx_ = town['x']
    for k, (x0, ln, th) in enumerate([(tx_ - 22, 30, 3), (tx_ - 6, 36, 3), (tx_ + 12, 28, 3), (tx_ + 30, 22, 2)]):
        root(x0, ln, th, SEED * 100 + 50 + k)
    for k in range(16):
        x0 = RS.randrange(8, W - 8)
        root(x0, RS.randint(12, 30), RS.choice([1, 2, 2, 3]), SEED * 100 + k)
    for k in range(10):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S, CYANCAP if k % 3 == 0 else None)
    for k in range(6):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'PL', 'u': 'T5', 'n': 't5'} if k % 2 else None)

    cols = np.unique(img.reshape(-1, 3), axis=0)
    allowed = {tuple(c) for c in PAL.values()}
    assert all(tuple(c) in allowed for c in cols), 'off-palette pixel'
    return img.copy(), dict(keeps=keeps, roads=roads, exits=exits, F=F, log=log)


# ================================================================ PREVIEW (placeholder markers, thick roots, names)
STAR = ['...k...', '..kyk..', 'kkkykkk', 'kyywyyk', '.kyyyk.', '.kykyk.', '.kk.kk.']


def circle(cx, cy, r, fill, outline='CR', ring='K'):
    for y in range(cy - r - 2, cy + r + 3):
        for x in range(cx - r - 2, cx + r + 3):
            d = (x - cx) ** 2 + (y - cy) ** 2
            if d <= (r + 0.5) ** 2 - (r * 2 if r > 3 else 2):
                put(x, y, fill)
            elif d <= (r + 0.5) ** 2:
                put(x, y, outline)
            elif d <= (r + 1.5) ** 2:
                put(x, y, ring)


def arrow(cx, cy, side):
    rows = ['....k....', '...kwk...', '..kwwwk..', '.kwwwwwk.', 'kwwkwkwwk', 'kkkkwkkkk', '...kwk...', '...kwk...',
            '...kkk...']
    rot = {'N': 0, 'E': 1, 'S': 2, 'W': 3}[side]
    a = np.rot90(np.array([list(r) for r in rows]), -rot)
    h, w = a.shape
    for r in range(h):
        for q in range(w):
            ch = a[r, q]
            if ch != '.':
                put(cx - w // 2 + q, cy - h // 2 + r, 'K' if ch == 'k' else 'GD')


def marker(x, y, kind, lit=True, stop=False):
    if kind == 'town':
        circle(x, y, 6, 'GD', 'CR'); put(x - 2, y - 2, 'WH'); put(x - 1, y - 3, 'CR'); put(x - 3, y - 1, 'CR')
    elif kind == 'village':
        circle(x, y, 4 if stop or lit else 3, 'CR' if lit else 'AL', 'WH' if lit else 'CR')
        put(x - 1, y - 1, 'WH')
    elif kind == 'wonder':
        spr(x, y + 3, STAR)
    elif kind == 'delve':
        circle(x, y, 4, 'S0', 'CR'); circle(x, y, 2, 'K', 'S5', 'S5')
    elif kind == 'lair':
        circle(x, y, 3, 'RD', 'WH'); put(x - 1, y - 1, 'RH')
    elif kind == 'haven':
        circle(x, y, 3, 'T1', 'WH'); put(x - 1, y - 1, 'CR')


def thick_root(x0, y0, x1, y1, dotted, width=4.2):
    L = math.hypot(x1 - x0, y1 - y0)
    if L < 1:
        return
    ux, uy = (x1 - x0) / L, (y1 - y0) / L
    rr = width / 2.0
    xs0, xs1 = int(min(x0, x1) - 4), int(max(x0, x1) + 5)
    ys0, ys1 = int(min(y0, y1) - 4), int(max(y0, y1) + 5)
    for y in range(max(0, ys0), min(H, ys1)):
        for x in range(max(0, xs0), min(W, xs1)):
            t = (x - x0) * ux + (y - y0) * uy
            if t < 0 or t > L:
                continue
            d = abs(-(x - x0) * uy + (y - y0) * ux)
            if dotted and int(t) % 8 >= 5:
                continue
            if d <= rr - 0.6:
                put(x, y, 'CR' if d < 0.6 and not dotted else 'GD')
            elif d <= rr + 0.6:
                put(x, y, 'K' if not dotted else 'S5')


def preview(art, info, L, P, slots, spread, anchors):
    global img
    img = art.copy()
    main = set(P.get('main_line', []))
    side = [sid for sid in sorted(spread) if sid not in main]
    dotted = set(side[::3]) | set(side[1::9])
    places = sorted(spread)
    dotted = set(places[k] for k in range(0, len(places), 3) if places[k] not in main)
    for sid in places:
        a = slots.get(anchors.get(sid, 0))
        if a:
            x, y = spread[sid]
            thick_root(a['x'], a['y'], x, y, sid in dotted)
    for sid in places:
        x, y = spread[sid]
        s = slots[sid]
        marker(x, y, s['kind'], lit=(sid in main or sid not in dotted))
    for s in slots.values():
        if s['type'] in ('stop', 'town'):
            marker(s['x'], s['y'], s['kind'], stop=True)
    for e in info['exits'].values():
        arrow(e['x'], e['y'], e['side'])
    # labels: town, stops, exits + a few places
    want = []
    for s in slots.values():
        if s['type'] in ('stop', 'town'):
            n = s['loc']['name']
            n = n[4:] if n.lower().startswith('the ') else n
            want.append((s['x'], s['y'], n.upper(), s['kind'] == 'town', 6 if s['kind'] == 'town' else 5))
    for e in info['exits'].values():
        want.append((e['x'], e['y'], e['name'].upper(), False, 6))
    for sid, nm in ((245, None), (248, None), (165, 'OWL DEN'), (229, 'JADE DRAGON-FLY'), (163, 'LOST LANTERN'), (166, None), (225, None)):
        if sid in spread:
            want.append((spread[sid][0], spread[sid][1], (nm or slots[sid]['loc']['name']).upper(), False, 4))
    boxes = []
    pts = [(s['x'], s['y'], 6) for s in slots.values() if s['type'] != 'off'] + [(x, y, 5) for (x, y) in spread.values()]
    for (x, y, name, town, r) in want:
        tw = text_w(name) + 6; th = 11
        cands = [(x - tw // 2, y + r + 2), (x - tw // 2, y - r - 2 - th), (x + r + 3, y - th // 2), (x - r - 3 - tw, y - th // 2),
                 (x + r, y + r), (x - tw - r, y + r), (x + r, y - r - th), (x - tw - r, y - r - th)]
        best = None
        for ci, (bx, by) in enumerate(cands):
            bx = int(bx); by = int(by)
            if bx < 2 or by < 2 or bx + tw > W - 2 or by + th > H - 2:
                continue
            if any(not (bx + tw + 1 < a or a2 + 1 < bx or by + th + 1 < b or b2 + 1 < by) for (a, b, a2, b2) in boxes):
                continue
            pen = ci * 0.5
            for (ox, oy, orr) in pts:
                cx = min(max(ox, bx), bx + tw); cy = min(max(oy, by), by + th)
                if (cx - ox) ** 2 + (cy - oy) ** 2 <= orr * orr:
                    pen += 20
            if best is None or pen < best[0]:
                best = (pen, bx, by)
        if best is None:
            continue
        _, bx, by = best
        boxes.append((bx, by, bx + tw, by + th))
        rect(bx, by, bx + tw - 1, by + th - 1, 'K')
        rect(bx + 1, by + 1, bx + tw - 2, by + th - 2, 'S1')
        rect(bx + 1, by + 1, bx + tw - 2, by + 1, 'GD' if town else 'S4')
        text(bx + 3, by + 3, name, 'GD' if town else 'CR', 'K')
    return img.copy()


def keep_report(art, keeps):
    """distinct colours inside each keep circle (r - 3), busiest first"""
    out = []
    for (sid, x, y, r) in keeps:
        m = disk(x, y, max(4, r - 3))
        n = len(np.unique(art[m].reshape(-1, 3), axis=0))
        out.append((n, sid))
    return sorted(out, reverse=True)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-NA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-NA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-NA.png'))
    ap.add_argument('--preview', default=None)
    ap.add_argument('-v', action='store_true')
    a = ap.parse_args()
    L, P, slots, spread, anchors = load(a.layout, a.plan)
    art, info = render(L, P, slots, spread, anchors)
    Image.fromarray(art, 'RGB').save(a.out)
    print('wrote', a.out, art.shape[1], 'x', art.shape[0], 'colours', len(np.unique(art.reshape(-1, 3), axis=0)))
    rep = keep_report(art, info['keeps'])
    print('busiest keep circles (colours, id):', rep[:8])
    if a.v:
        for row in info['log']:
            print('  prop', row)
    if a.preview:
        comp = preview(art, info, L, P, slots, spread, anchors)
        Image.fromarray(comp, 'RGB').resize((W * 2, H * 2), Image.NEAREST).save(a.preview)
        print('wrote', a.preview)
