#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for EA "Blossomreach" (band violet, Lv 45-55).

Lit floor style (the approved region-1 mockup: same palette, sprites, 5x7 font, glow), built on the
sibling map_v2 generators: dark strata and fog outside, the cavern floor (the plan polygon) lit from
inside with a dithered violet halo and a violet rim light (the Spicepeak mouth, the tier 4 door, takes
the orange of tier 4 for ~20 px), biome ground from the plan (moist green loam as the default floor,
the lighter Market terraces in three low steps, the Ricestep paddies as contour lines with water on
every second step, the pale Gobi gravel tongue, three bamboo groves of the Whisperwood, the Pearlwave
sand and bay, the dark wet Monsoon breath, the pink Blossom Meadow, the Long Wall gravel shelf and the
green-black Jade Falls rock), landmark props (Seed Bed with persimmon and cherry sapling, persimmon
trees, paper lantern poles, water-mill wheel, orchard rows, the shut Clovercove gatehouse in the north
ceiling with its faint unlit trace and the oldest lamp, panda, shrine posts, Caravanserai arch, camel
line, copper gate tower, scree and prayer flags at the west mouth, jetty, ferry raft, sea stacks,
broad leaves and vines, steam vents, spice beds, the Lantern Festival River with floating lanterns and
the moon bridge, the reef lagoon, the Long Wall with two watchtowers, the warm spring, cherry trees and
petal drifts, teahouse ledge steps, red gate rows, the jade waterfall, jade rock, reeds, dragon-fly
glints), glowing road trunks on the layout polylines and the two exit tunnel mouths, a root ceiling
with stalactites and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout town / stops / exits and inside a
14-unit circle round every spread position of the plan there is a plain floor (one or two flat
tones, no sprites, no water, no texture).  The layout's keep circles of the off places are at their
old (pre-spread) positions and are not used: the spread circles replace them.

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_EA.py [--layout layout-EA.json] [--plan plan-EA.json]
                                    [--out game/assets/img/scenes/map2-EA.png] [--preview PREVIEW-2x.png]
Defaults for --layout / --plan: $MAP_V2_LAYOUT / $MAP_V2_PLAN, else the planning scratchpad files.
--preview also writes a 960x540 nearest-neighbour check image (art + placeholder markers at the stops
and spread positions, thick gold roots, dotted for a third of the places, a few names).
"""
import argparse, json, math, os, random
import numpy as np
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
SCRATCH = '/tmp/claude-0/-home-user-gnome-venture/30c9491a-86e7-530f-9f28-96d77dd01450/scratchpad'
W, H = 480, 270
yy, xx = np.mgrid[0:H, 0:W]
CODE = 'EA'
SEED = 45
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
BRIGHT, DIM = 'T5', 't5'  # band violet
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

# ---------------------------------------------------------------- EA sprites (Blossomreach)
LET.update({'U': 'WL', 'u': 'WA', 'z': 't2', 'D': 't1', 'v': 'T5', 'W': 'WH', '5': 'S5', '6': 'S6', 'j': 'NW'})


def pad_rows(rows):
    w = max(len(r) for r in rows)
    return [r + '.' * (w - len(r)) for r in rows]


# bamboo: GK stems with a K shadow side and GM leaf ticks, taller than wide
BAMBOO = pad_rows(['.g...g..',
                   'kdg.kd..',
                   'kd..kdg.',
                   'kdgkkd..',
                   'gd.kd.g.',
                   'kd.kdgd.',
                   'kdgkd.d.',
                   'kd.kd.dg',
                   'kd.kdgd.',
                   'kD.kD.D.',
                   'kk.kk.k.'])
BAMBOO_S = ['.g..g.', 'kdgkd.', 'kd.kdg', 'gdgkd.', 'kd.kd.', 'kD.kD.', 'kk.kk.']
BAMBOO_C = {'d': 'GM', 'g': 'T1', 'D': 'GK'}
PERSIMMON = ['..kkkk..', '.kGgogk.', 'kGogggok', 'kgggoddk', 'kogggdok', '.kgdodk.', '..kbbk..', '..kbBk..', '..kkkk..']
PERSIMMON_S = ['.kkkk.', 'kGogdk', 'kgodok', '.kddk.', '.kbbk.', '.kkkk.']
PERSIM_C = {'g': 'GM', 'G': 'T1', 'd': 'GK', 'o': 'T4'}
CHERRY_C = {'g': 'PK', 'G': 'PL', 'd': 'RH'}
CHERRY_D = {'g': 'PK', 'G': 'PL', 'd': 'RK'}
OLD_C = {'g': 'GK', 'G': 'GM', 'd': 't1'}
LANTERN_POLE = pad_rows(['bbbb.', 'b..k.', 'b.krk', 'b.khk', 'b.kRk', 'b..k.', 'b....', 'b....', 'kb...'])
TORII = ['kkkkkkkk', 'hrrrrrrh', '.rk..rk.', 'krrrrrrk', '.rk..rk.', '.rk..rk.', '.kk..kk.']
TORII_S = ['kkkkk', 'hrrrh', '.r.r.', '.r.r.', '.k.k.']
POSTS = ['hk', 'rk', 'rk', 'rk', 'kk']
WATCHTOWER = ['..k..', '.krk.', 'krrrk', 'kAa1k', 'kAk1k', 'kAa1k', 'kAa1k', 'kkkkk']
COPPER_TOWER = ['..k..', '.kok.', 'kooek', 'kkkkk', 'kSs5k', 'kSk5k', 'kSs5k', 'kSs5k', 'kkkkk']
MILL = ['.kkk.', 'kbBbk', 'kBkBk', 'kbBbk', '.kkk.']
CAMEL = ['..kk...', '.kSSk.k', 'kSSSSkS', 'kSSSSSk', '.k.k.k.']
ARCH = ['.kkkkkkk.', 'ksSSSSSsk', 'kSkkkkkSk', 'kSk...kSk', 'kSk...kSk', 'kkk...kkk']
PANDA = ['k...k', 'kwwwk', 'wkwkw', 'wwwww', 'kk.kk']
SEA_STACK = ['.kkk.', 'kAa1k', 'kAa1k', 'kaa1k', 'kkkkk']
BIGLEAF = ['..kkk..', '.kgGgk.', 'kgggddk', 'kdgdddk', '.kkdkk.', '...d...']
BIGLEAF_C = {'g': 'GK', 'G': 'GM', 'd': 't1'}
JADE = {'A': 'ND', 'a': 'GK', '1': 't1'}
GREY = {'A': 'AL', 'a': 'AS', '1': 'S3'}
GRAVEL = {'A': 'SN', 'a': 'SD', '1': 'S5'}
SANDSTONE = {'A': 'SN', 'a': 'SD', '1': 'S5'}

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
    if 'anchors' in P:
        anchors = {int(k): int(v) for k, v in P['anchors'].items()}
    else:   # SA plan: found_places carry their layout anchor
        anchors = {int(fp['id']): int(fp['anchor']) for fp in P.get('found_places', [])}
    for sid in spread:   # fall back on the layout anchor
        if sid not in anchors and sid in slots and slots[sid].get('anchor'):
            anchors[sid] = int(slots[sid]['anchor'])
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

    # ------------------------------------------------ 1. FAR LAYER: strata + fog + violet halo
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
    # spray mist outside the east horn (the jade falls)
    em = ~F & (outd > 3) & (xx > 456) & (yy > 140) & (yy < 210)
    paint(em & (vnoise(6, 19) > 0.45) & (BAY > 0.55), 'FOG')
    hval = np.clip(1 - (outd - 4) / 11.0, 0, 1)
    paint(~F & (outd > 4) & (hval ** 1.5 > BAY + 0.04), DIM)
    paint(~F & (outd > 4) & (outd < 8) & (hval ** 3 > BAY + 0.35), BRIGHT)
    for _ in range(70):   # far crystals (no jade: NW belongs to the Jade Falls only)
        x = R.randrange(2, W - 3); y = R.randrange(14, H - 14)
        if outd[y, x] < 7 or F[y, x]:
            continue
        b, dm = R.choice([('T2', 't2'), ('T5', 't5'), ('T5', 't5'), ('GD', 't3'), (BRIGHT, DIM)])
        put(x, y, b); put(x, y + 1, dm)
        if R.random() < .3:
            put(x, y - 1, 'WH')

    # ------------------------------------------------ 2. ZONES from the plan biomes (noisy edges)
    zone = np.full((H, W), 'base', dtype=object)   # moist green loam is the default floor
    zmask = {}
    KEY = {'market_terraces': 'hub', 'ricestep_terraces': 'terrace', 'gobi_wastes': 'gobi',
           'bamboo_whisperwood': 'bamboo', 'pearlwave_shore': 'shore', 'bay_water': 'bay',
           'monsoon_breath': 'monsoon', 'blossom_meadow': 'blossom', 'long_wall_shelf': 'shelf',
           'jade_falls': 'jade'}
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        if b['shape'] == 'polygon':
            s = blur(poly_mask(b['points']).astype(float), 3)
            m = s + 0.5 * (n - 0.5) > 0.5
            if b['type'] == 'bay_water':
                m = poly_mask(b['points']) & (vnoise(3, 300) * 0.0 == 0)
        else:
            e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
            m = e + 0.35 * (n - 0.5) < 1
        k = KEY.get(b['type'])
        if k:
            zmask.setdefault(k, np.zeros((H, W), bool))
            zmask[k] |= m
    # the gobi gravel and the monsoon breath fade into the loam by dither, not a hard edge
    for k in ('gobi', 'monsoon', 'shelf', 'hub'):
        if k in zmask:
            cs = blur(zmask[k].astype(float), 4)
            zmask[k] = cs > 0.25 + 0.5 * BAY
    for key in ['shelf', 'gobi', 'shore', 'monsoon', 'terrace', 'hub', 'bamboo', 'blossom', 'jade']:
        if key in zmask:
            zone[zmask[key] & F] = key

    RAMPS = {
        'base': ['S4', 't1', 'GK', 'GM'], 'hub': ['t1', 'GK', 'GM', 'GM'], 'terrace': ['t1', 'GK', 'GM', 'GM'],
        'gobi': ['S4', 'S6', 'SD', 'SN'], 'bamboo': ['S3', 't1', 't1', 'GK'], 'shore': ['S6', 'SD', 'SN', 'SN'],
        'monsoon': ['S3', 't1', 't1', 'GK'], 'blossom': ['t1', 'GK', 'GK', 'GM'], 'shelf': ['S5', 'S6', 'SD', 'SN'],
        'jade': ['S3', 't1', 'GK', 'GK'],
    }
    BIAS = {'base': 0.0, 'hub': 0.04, 'terrace': 0.04, 'gobi': 0.06, 'bamboo': -0.04, 'shore': 0.08,
            'monsoon': -0.04, 'blossom': 0.04, 'shelf': 0.04, 'jade': -0.04}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.14 + 0.46 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.24 * np.exp(-(dt / 80.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.18 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    lv = lightv + np.where(keep_m, 0.0, 0.14 * (tex - 0.5))
    gi = np.floor(lv * 4 - 0.4 + (BAY - 0.5) * 0.9).astype(int).clip(0, 3)
    # plain floor in the keep circles: the mean tone of the ground round each disc, at most two tones
    # dithered (no pale or dark polka dots)
    gv = lv * 4 - 0.4
    for (_, x, y, r) in sorted(keeps, key=lambda t: -t[3]):
        dd_ = np.hypot(xx - x, yy - y)
        ring_ = F & ~keep_m & (dd_ > r) & (dd_ < r + 7)
        mval = float(gv[ring_].mean()) if ring_.any() else float(gv[dd_ <= r].mean())
        mval = min(max(mval, 1.0), 2.6)
        dm_ = dd_ <= r
        gi = np.where(dm_, np.floor(mval + (BAY - 0.5) * 0.6).astype(int).clip(1, 3), gi)
    for zname, ramp in RAMPS.items():
        zm = F & (zone == zname)
        for i in range(4):
            paint(zm & (gi == i), ramp[i])
    inner = F & ~ero4(F)
    for zname, ramp in RAMPS.items():
        paint(inner & (zone == zname), ramp[0])
    kd = np.full((H, W), 99.0)
    for (_, x, y, r) in keeps:
        kd = np.minimum(kd, np.hypot(xx - x, yy - y) - r)
    feather = BAY2 < np.clip(kd / 6.0, 0, 1)     # texture thins out toward each plain disc
    busyok = F & ~keep_m & (depth > 2) & feather
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    near_road = pixmask(road_px, 3)
    # Ricestep terraces: contour risers (S5 under a lit GM lip), water on every second step
    tz = busyok & (zone == 'terrace') & ~near_road
    off = np.round(3.0 * np.sin(xx / 21.0) + 5 * vnoise(16, 201)).astype(int)
    ph = (yy + off) % 10
    paint(tz & ((ph == 0) | (ph == 5)), 'S5')
    paint(tz & ((ph == 9) | (ph == 4)), 'T1')
    wet = tz & ((ph == 1) | (ph == 2) | (ph == 3)) & (vnoise(4, 202) > 0.30)
    paint(wet & ((xx + yy) % 2 == 0), 'WA')
    paint(wet & (ph == 1), 't2')
    paint(wet & (ph == 2) & ((xx * 3 + yy) % 7 == 0), 'WL')
    paint(tz & ((ph == 6) | (ph == 7)) & (vnoise(1, 203) > 0.80), 'T1')     # rice tufts on the dry steps
    # the Market terraces: three low loam steps round the Market (concentric lips)
    hz = busyok & (zone == 'hub') & ~near_road
    de = np.hypot((xx - town['x']) / 1.35, yy - town['y']) + 2.0 * (vnoise(5, 204) - 0.5)
    for r_ in (25, 32, 39):
        paint(hz & (np.abs(de - r_ + 1) < 0.5), 'T1')
        paint(hz & (np.abs(de - r_) < 0.5), 'S5')
        paint(hz & (np.abs(de - r_ - 1) < 0.5) & ((xx + yy) % 2 == 0), 'S4')
    paint(hz & (vnoise(1, 227) > 0.90) & (np.abs(de - 28.5) > 2), 'T1')
    # gobi: SD/SN gravel dithered over the floor, grey stone near the west mouth
    gz = busyok & (zone == 'gobi')
    paint(gz & (vnoise(1, 205) > 0.80), 'S5')
    paint(gz & (vnoise(1, 206) > 0.88), 'CR')
    grey = gz & (BAY < np.clip((60 - xx) / 50.0, 0, 0.8))
    paint(grey & (gi >= 2), 'AL'); paint(grey & (gi < 2), 'AS')
    # bamboo groves: dark floor with leaf litter
    bz = busyok & (zone == 'bamboo')
    paint(bz & (vnoise(1, 207) > 0.85) & ((xx + yy) % 2 == 0), 'GK')
    paint(bz & (vnoise(1, 208) > 0.95), 'GM')
    # shore: wet dark sand ripples
    sz = busyok & (zone == 'shore')
    rip = np.abs(np.sin((yy * 1.2 + 3 * np.sin(xx / 8.0) + 5 * vnoise(8, 209)) / 1.5)) > 0.96
    paint(sz & rip, 'SD')
    paint(sz & (vnoise(1, 210) > 0.95), 'WH')
    # monsoon breath: GM tufts fading by dither, wet glints
    mz = busyok & (zone == 'monsoon')
    paint(mz & (vnoise(1, 211) > 0.72) & ((xx + yy) % 3 == 0), 'GK')
    paint(mz & (vnoise(1, 224) > 0.90) & ((xx + yy) % 2 == 0), 'GM')
    vine = mz & (np.abs(np.sin((xx * 0.8 + yy * 0.5 + 9 * vnoise(6, 225)) / 2.0)) < 0.10) & (vnoise(3, 226) > 0.5)
    paint(vine, 'GK')
    paint(mz & (vnoise(1, 212) > 0.985), 'WL')
    # blossom meadow: pink petals on the dark floor (single pixels)
    pz = busyok & (zone == 'blossom')
    paint(pz & (vnoise(1, 213) > 0.86) & (vnoise(9, 214) > 0.35), 'PL')
    paint(pz & (vnoise(1, 215) > 0.93), 'PK')
    paint(pz & (vnoise(1, 216) > 0.90) & ((xx + yy) % 2 == 0), 'GM')
    # Long Wall shelf: pale gravel at low density
    lz = busyok & (zone == 'shelf')
    paint(lz & (vnoise(1, 217) > 0.82), 'S5')
    paint(lz & (vnoise(1, 228) > 0.88), 'CR')
    paint(lz & (vnoise(1, 218) > 0.90), 'GK')
    # Jade Falls: green-black rock floor with ND strata
    jz = busyok & (zone == 'jade')
    crk = (np.abs(np.sin((xx * 0.55 + yy + 14 * vnoise(5, 219)) / 3.2)) < 0.16) & (vnoise(3, 220) > 0.45)
    paint(jz & crk, 'S2')
    paint(jz & dil4(crk) & ~crk & (yy % 2 == 0) & (vnoise(1, 221) > 0.55), 'ND')
    paint(jz & (vnoise(1, 229) > 0.975), 'NW')
    paint(jz & (vnoise(3, 232) > 0.62) & ((xx + yy) % 2 == 0), 'ND')
    # base loam: a few S4 patches of bare soil
    oz = busyok & (zone == 'base')
    paint(oz & (vnoise(4, 222) > 0.80) & ((xx + yy) % 4 == 0), 'S4')
    paint(oz & (vnoise(1, 223) > 0.95), 'T1')

    # rim: K outline, band-colour rim light (violet T5), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')
    # the tier 4 door: the Spicepeak mouth takes the orange of tier 4 behind it (~20 px)
    XBAND = {'CSA': ('T4', 't4')}
    for e in L['exits']:
        if e['to'] not in XBAND:
            continue
        b_, d_ = XBAND[e['to']]
        ex, ey = e['x'], e['y']
        dd = np.hypot(xx - ex, yy - ey)
        nr = ~F & ((dd < 20) | ((dd < 32) & (BAY > (dd - 20) / 12.0)))
        for src, dst in ((BRIGHT, b_), (DIM, d_)):
            hit = nr & (img == np.array(PAL[src], np.uint8)).all(-1)
            paint(hit, dst)

    # ------------------------------------------------ 4. WATERS: the bay, the Lantern Festival River, the lagoon, the falls
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on dry ground
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2.5 * isl
    band = pixmask(road_px, 5)
    bay = zmask.get('bay', np.zeros((H, W), bool)) & F & ~keep_wet & ~band & (depth > 1)
    bay = ero4(dil4(bay)) & F & ~keep_wet & ~band
    river_pts = [tuple(p) for p in P.get('river', [])]
    river_line = raster(river_pts) if river_pts else []
    river = pixmask(river_line, 1)
    river |= pixmask(river_line[:len(river_line) // 3], 2)     # broader near the falls
    lag = None
    for p in P['props']:
        if p['kind'] == 'reef_lagoon':
            lag = (p['x'], p['y'])
    lagoon = np.zeros((H, W), bool)
    if lag:
        lagoon = np.hypot((xx - lag[0]) / 10.0, (yy - lag[1]) / 5.5) + 0.3 * (vnoise(3, 230) - 0.5) < 1
    plunge = np.hypot((xx - 458) / 6.0, (yy - 173) / 3.5) < 1
    riv = (river | lagoon | plunge) & F & ~keep_wet & ~band
    water = bay | riv
    occ_water = water.copy()
    # bay: D2 edge, WA body, WL glints
    sh = dil8(bay) & ~bay & F & ~keep_m
    paint(sh, 'SD')
    paint(bay, 'WA')
    paint(bay & ~ero4(bay), 'D2')
    paint(bay & ero4(ero4(bay)) & (vnoise(4, 231) > 0.55) & (BAY > 0.45), 't2')
    paint(bay & ero4(bay) & (yy % 3 == 0) & ((xx + yy // 3) % 5 == 0), 'WL')
    # river and lagoon
    shr = dil8(riv) & ~riv & F & ~keep_m & ~bay
    paint(shr, 'S4')
    paint(riv, 'WA')
    paint(riv & ero4(riv) & ((xx + 2 * yy) % 6 == 0), 'WL')
    paint(lagoon & riv & ~ero4(lagoon), 'D2')
    paint(lagoon & riv & ero4(ero4(lagoon)) & ((xx * 5 + yy * 3) % 9 == 0), 'SN')   # reef heads
    paint(lagoon & riv & ero4(ero4(lagoon)) & ((xx * 5 + yy * 3) % 9 == 4), 'ND')
    paint(plunge & riv, 'WL'); paint(plunge & riv & ((xx + yy) % 2 == 0), 'WH')

    # ------------------------------------------------ 5. PROPS + SCATTER
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    place18 = np.zeros((H, W), bool)   # landmark props stay out of an 18 px circle round every spread place
    for sid, (x, y) in spread.items():
        place18 |= disk(x, y, 18)
    protect = keep_pad | near_road | root_corr | dil4(occ_water)
    free = F & ~protect & (depth >= 2)
    occ = np.zeros((H, W), bool)
    placed = []
    log = []

    def smask(rows, pad):
        m = np.array([[ch != '.' for ch in row] for row in rows])
        m = np.pad(m, pad)
        for _ in range(pad):
            m = dil8(m)
        return m

    def fits(x0, y0, rows, pad=1, where=None):
        where = free if where is None else where
        w, h = spr_size(rows)
        if x0 - pad < 0 or y0 - pad < 0 or x0 + w + pad > W or y0 + h + pad > H:
            return False
        m = smask(rows, pad)
        sl = (slice(y0 - pad, y0 + h + pad), slice(x0 - pad, x0 + w + pad))
        return bool(where[sl][m].all() and not occ[sl][m].any())

    def try_place(x, y, rows, over=None, pad=1, where=None):
        w, h = spr_size(rows)
        x0, y0 = x - w // 2, y - h + 1
        if not fits(x0, y0, rows, pad, where):
            return False
        m_ = smask(rows, 1)
        ys0, xs0 = y0 - 1, x0 - 1
        a0, a1 = max(0, ys0), min(H, ys0 + m_.shape[0])
        b0, b1 = max(0, xs0), min(W, xs0 + m_.shape[1])
        occ[a0:a1, b0:b1] |= m_[a0 - ys0:a1 - ys0, b0 - xs0:b1 - xs0]
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
                if fits(x - w // 2, y - h + 1, rows, pad, where):
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
            if try_place(x, y, rows, over, pad, where):
                got += 1
        return got

    def glow(cx_, cy_, rad, col, extra=None):
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ & F & ~occ_water
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + 0.12) & ((xx + yy) % 2 == 0), col)

    def box_ok(m, x0, y0, x1, y1):
        if x0 < 0 or y0 < 0 or x1 >= W or y1 >= H:
            return False
        return bool(m[y0:y1 + 1, x0:x1 + 1].all() and not occ[y0:y1 + 1, x0:x1 + 1].any())

    def find_box(tx, ty, w, h, m, maxd=12):
        best = None
        for dy in range(-maxd, maxd + 1):
            for dx in range(-maxd, maxd + 1):
                d = dx * dx + dy * dy
                if d > maxd * maxd or (best and d >= best[0]):
                    continue
                x0, y0 = tx + dx - w // 2, ty + dy - h // 2
                if box_ok(m, x0, y0, x0 + w - 1, y0 + h - 1):
                    best = (d, tx + dx, ty + dy)
        return best[1:] if best else None

    hard = F & ~keep_pad & ~near_road & ~root_corr & ~dil4(occ_water) & ~place18
    soft = F & ~keep_pad & ~near_road & ~root_corr & ~dil4(occ_water)
    flat = F & ~keep_pad & ~near_road & ~dil4(occ_water)        # ground decals may run under a root
    wall_px = []
    lamp_glows = []
    FIRST = ('warm_spring_pool', 'seed_bed_persimmon_sakura', 'gravel_dune', 'spice_beds', 'steam_vent')
    for p in sorted(P['props'], key=lambda q: q['kind'] not in FIRST):
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        got = None
        if k == 'seed_bed_persimmon_sakura':
            b = find_box(x, y, 13, 9, soft, 14)
            if b:
                bx, by = b
                bm = (np.abs(xx - bx) <= 6) & (np.abs(yy - by) <= 2)
                paint(bm, 'S4'); paint(bm & (yy == by) & (xx % 2 == 0), 'GM'); paint(bm & ~ero4(bm), 'S5')
                spr(bx - 3, by - 2, PERSIMMON_S, PERSIM_C)
                spr(bx + 3, by - 2, TREE_S, CHERRY_C)
                occ[by - 8:by + 3, bx - 7:bx + 7] = True
                lamp_glows.append((bx, by - 4, 9, 'PL'))
                got = (bx, by)
        elif k == 'persimmon_tree':
            got = cluster(x, y, [(PERSIMMON, PERSIM_C), (PERSIMMON_S, PERSIM_C)], n, 9, 1, where=soft & ~pixmask(road_px, 6))
        elif k == 'paper_lantern_pole':
            got = 0
            for i in range(n):
                q = near(x + i * 9, y + (i % 2) * 3, LANTERN_POLE, None, 14, 0, where=soft)
                if q:
                    lamp_glows.append((q[0] + 1, q[1] - 5, 6, 'GD'))
                    got += 1
        elif k == 'terrace_steps':
            got = 0
            for i in range(n):   # stepped risers: lit lip over an S5 face
                ty0 = y - 4 + i * 4
                for X in range(x - 16 + i * 3, x + 16 - i * 3):
                    if flat[ty0 - 1:ty0 + 2, X].all() and not occ[ty0 - 1:ty0 + 2, X].any() and not root_corr[ty0, X]:
                        put(X, ty0 - 1, 'T1'); put(X, ty0, 'S5'); put(X, ty0 + 1, 'S4')
                        got += 1
        elif k == 'water_mill_wheel':
            got = near(x, y, MILL, None, 12, 0, where=soft)
            if got:
                mx, my = got
                for Y in range(my - 6, my + 1):     # the mill race beside the wheel
                    for X in (mx + 3, mx + 4):
                        if soft[Y, X] and not occ[Y, X]:
                            put(X, Y, 'WA' if (X + Y) % 3 else 'WL')
        elif k == 'clovercove_gatehouse':
            got = (x, y)    # drawn on the near layer (north ceiling)
        elif k == 'old_road_trace':
            got = 'trace'   # drawn once below from the plan polyline
        elif k == 'orchard_row':
            got = 0
            for i in range(n):
                for j in range(3):
                    got += try_place(x - 10 + j * 9 + (i % 2) * 4, y - 4 + i * 6, PERSIMMON_S, {'g': 'GM', 'G': 'T1', 'd': 'GK', 'o': 'GD'}, 0, where=soft)
        elif k == 'bamboo_clump':
            got = cluster(x, y, [(BAMBOO, BAMBOO_C), (BAMBOO_S, BAMBOO_C)], n + 1, 10, 0, where=hard & ~pixmask(road_px, 8))
        elif k == 'panda':
            got = near(x, y, PANDA, None, 10, 1, where=soft)
            if got:
                for (dx, dy) in ((-5, 0), (5, -1), (-4, -6), (6, -6)):
                    try_place(got[0] + dx, got[1] + dy, BAMBOO_S, BAMBOO_C, 0, where=soft)
        elif k == 'shrine_gate_posts':
            got = near(x, y, TORII_S, None, 10, 1, where=soft)
        elif k == 'old_tree':
            got = cluster(x, y, [(BIGTREE, OLD_C), (TREE, OLD_C)], n, 10, 0, where=hard)
        elif k == 'gravel_dune':
            b = find_box(x, y, 24, 9, flat & (zone == 'gobi'), 14)
            got = b
            if b:
                cx_, cy_ = b
                rx, ry = 10, 3.5
                e = ((xx - cx_) / rx) ** 2 + ((yy - cy_) / ry) ** 2
                e2 = ((xx - cx_ - rx * 0.25) / (rx * 0.9)) ** 2 + ((yy - cy_ - ry * 0.7) / ry) ** 2
                body = (e <= 1) & (e2 > 1) & flat
                paint(body & (yy < cy_ - ry * 0.1), 'CR')
                paint(body & (yy >= cy_ - ry * 0.1), 'SN')
                paint(body & (yy >= cy_ + ry * 0.2) & ((xx + yy) % 2 == 0), 'SD')
                paint(dil4(body) & ~body & (e2 <= 1.25) & (yy > cy_ - ry) & flat, 'S6')
                occ[cy_ - 5:cy_ + 6, cx_ - 12:cx_ + 13] = True
        elif k == 'camel_line':
            got = 0
            for i in range(3):
                got += bool(near(x - 9 + i * 9, y + (i % 2), CAMEL, None, 6, 0, where=soft))
            if got:    # a footprint line behind them
                for X in range(x - 30, x - 12, 3):
                    Y = y + 1 + (X // 3) % 2
                    if flat[Y, X] and not occ[Y, X]:
                        put(X, Y, 'S6')
        elif k == 'caravanserai_arch':
            got = near(x + 4, y, ARCH, SANDSTONE, 10, 0, where=F & ~keep_pad & ~near_road & ~root_corr)
        elif k == 'gate_tower_copper':
            got = near(x, y, COPPER_TOWER, None, 12, 1, where=soft)
        elif k == 'grey_scree':
            got = cluster(x, y, [(STONE, GREY), (PEBBLE, GREY), (CRAG, GREY)], n + 2, 8, 0, where=soft)
        elif k == 'prayer_flags':
            got = 0
            fl_c = ['RD', 'GD', 'T2', 'WH', 'GM']
            ok_ = flat & ~root_corr
            spot = None
            for dy_ in sorted(range(-14, 15), key=abs):
                for dx_ in sorted(range(-12, 13), key=abs):
                    if box_ok(ok_, x + dx_ - 9, y + dy_ - 9, x + dx_ + 9, y + dy_ + 1):
                        spot = (x + dx_, y + dy_); break
                if spot:
                    break
            if spot:
                x, y = spot
                x0_, x1_ = x - 8, x + 8
                for (X0) in (x0_ - 1, x1_ + 1):
                    for Y in range(y - 8, y + 1):
                        put(X0, Y, 'S5')
                    put(X0, y - 9, 'K')
                for i, X in enumerate(range(x0_, x1_ + 1)):
                    Y = y - 8 + int(round(3 * (1 - ((X - x) / 8.5) ** 2)))
                    if Y < 0:
                        continue
                    if ok_[Y, X]:
                        put(X, Y, 'K')
                        if i % 2 == 0:
                            put(X, Y + 1, fl_c[(i // 2) % 5])
                            got += 1
                occ[y - 9:y + 2, x0_ - 1:x1_ + 2] = True
        elif k == 'jetty':
            got = None
            for dx in sorted(range(-30, 31), key=abs):
                X = x + dx
                col = [Y for Y in range(y - 16, y + 12) if bay[Y, X]]
                if len(col) < 4:
                    continue
                Y0 = col[0]
                if not (F & ~keep_pad & ~near_road)[Y0 - 4:Y0, X - 1:X + 2].all() or occ[Y0 - 4:Y0 + 6, X - 1:X + 2].any():
                    continue
                for Y in range(Y0 - 3, min(Y0 + 6, col[-1])):
                    put(X - 1, Y, 'K'); put(X, Y, 'S6' if Y % 2 else 'S5'); put(X + 1, Y, 'K')
                occ[Y0 - 4:Y0 + 7, X - 2:X + 3] = True
                got = (X, Y0)
                break
        elif k == 'ferry_raft':
            got = None
            for dy in sorted(range(-8, 12), key=abs):
                Y = y + dy
                xs_ = [X for X in range(x - 10, x + 11) if bay[Y, X] and bay[Y + 1, X] and bay[Y - 1, X]]
                if len(xs_) >= 7:
                    cx_ = xs_[len(xs_) // 2]
                    for X in range(cx_ - 3, cx_ + 4):
                        put(X, Y, 'S6' if X % 2 else 'S5'); put(X, Y + 1, 'K')
                    put(cx_, Y - 1, 'S5'); put(cx_, Y - 2, 'K'); put(cx_ + 1, Y - 2, 'CR')
                    got = (cx_, Y)
                    break
        elif k == 'pearl_shells':
            got = 0
            for (dx, dy) in [(0, 0), (6, 3), (-5, 4), (3, -4), (-8, -2), (9, -1)][:n + 2]:
                X, Y = x + dx, y + dy
                if flat[Y - 1:Y + 2, X - 1:X + 2].all() and not occ[Y, X]:
                    put(X, Y, 'WH'); put(X + 1, Y, 'AL'); put(X, Y + 1, 'S5')
                    got += 1
        elif k == 'sea_stack':
            got = 0
            for (dx, dy) in [(0, 0), (12, -3), (-10, 2), (20, -1)]:
                X, Y = x + dx, y + dy
                if got >= n:
                    break
                if bay[Y - 4:Y + 2, X - 3:X + 4].all() and not occ[Y - 4:Y + 2, X - 3:X + 4].any():
                    spr(X, Y, SEA_STACK, GREY)
                    put(X - 3, Y + 1, 'WL'); put(X + 3, Y + 1, 'WL')
                    occ[Y - 5:Y + 2, X - 3:X + 4] = True
                    got += 1
        elif k == 'broad_leaf_fronds':
            got = cluster(x, y, [(BIGLEAF, BIGLEAF_C), (FERN, BIGLEAF_C), (BIGLEAF, None)], n + 1, 10, 0, where=soft)
        elif k == 'hanging_vines':
            got = 'near layer'
        elif k == 'steam_vent':
            got = 0
            for (dx, dy) in [(a_, b_) for b_ in range(-4, 16, 2) for a_ in range(-16, 17, 3)]:
                if got >= n:
                    break
                X, Y = x + dx, y + dy
                if box_ok(soft, X - 3, Y - 9, X + 3, Y + 1):
                    put(X - 1, Y, 'S2'); put(X, Y, 'K'); put(X + 1, Y, 'S2'); put(X, Y - 1, 'T4'); put(X, Y + 1, 'S2')
                    for j, (ox, oy) in enumerate(((0, -3), (1, -5), (0, -7), (-1, -8), (1, -9))):
                        put(X + ox, Y + oy, 'WH' if j < 2 else 'AL')
                    occ[Y - 9:Y + 2, X - 3:X + 4] = True
                    lamp_glows.append((X, Y - 1, 6, 'T4'))
                    got += 1
        elif k == 'spice_beds':
            got = 0
            for i in range(n):
                b = find_box(x - 6 + i * 13, y + (i % 2) * 3, 11, 5, flat & ~root_corr, 10)
                if b:
                    bx, by = b
                    bm = (np.abs(xx - bx) <= 5) & (np.abs(yy - by) <= 2)
                    paint(bm, 'S3'); paint(bm & ~ero4(bm), 'S5')
                    for X in range(bx - 4, bx + 5, 2):
                        put(X, by - 1, ['RD', 'T4', 'GD'][(X // 2 + i) % 3]); put(X, by + 1, ['GD', 'RD', 'T4'][(X // 2 + i) % 3])
                    occ[by - 3:by + 4, bx - 6:bx + 7] = True
                    got += 1
        elif k in ('reef_lagoon', 'river'):
            got = 'water'
        elif k == 'moon_bridge':
            got = None
            # a pale stone arch across the river where the Lair root crosses it
            bx, by = x, y
            for X in range(bx - 5, bx + 6):
                t_ = (X - bx) / 5.5
                Y = by - int(round(2 * (1 - t_ * t_)))
                put(X, Y, 'AL'); put(X, Y + 1, 'AS'); put(X, Y - 1, 'K')
                if abs(X - bx) in (3, 5):
                    put(X, Y - 2, 'WH')
            put(bx - 6, by, 'K'); put(bx + 6, by, 'K')
            got = (bx, by)
        elif k == 'floating_lanterns':
            got = 0
            cand = [(X, Y) for (X, Y) in river_line if abs(X - x) + abs(Y - y) <= 18 and riv[Y, X]]
            for (X, Y) in cand[::max(1, len(cand) // max(1, n))][:n]:
                put(X, Y, 'GD'); put(X, Y + 1, 't3')
                got += 1
        elif k == 'long_wall_segment':
            got = 'wall'
        elif k == 'wall_watchtower':
            got = 'wall'
        elif k == 'warm_spring_pool':
            got = None
            for dy in sorted(range(-10, 16), key=abs):
                for dx in sorted(range(-14, 15), key=abs):
                    cx_, cy_ = x + dx, y + dy
                    if box_ok(soft, cx_ - 7, cy_ - 4, cx_ + 7, cy_ + 3):
                        pm = np.hypot((xx - cx_) / 5.5, (yy - cy_) / 2.4) + 0.2 * (vnoise(2, 240) - 0.5) < 1
                        paint(dil8(pm) & ~pm, 'SD'); paint(pm, 'WA'); paint(pm & (yy < cy_) & ((xx + yy) % 2 == 0), 'WL')
                        for (ox, oy) in ((-2, -4), (1, -5), (3, -4)):
                            put(cx_ + ox, cy_ + oy, 'AL')
                        occ[cy_ - 5:cy_ + 5, cx_ - 9:cx_ + 9] = True
                        occ_water |= pm
                        got = (cx_, cy_)
                        break
                if got:
                    break
        elif k == 'cherry_trees':
            got = cluster(x, y, [(TREE, CHERRY_C), (BIGTREE, CHERRY_C), (TREE_S, CHERRY_D)], n, 12, 0, where=hard)
        elif k == 'teahouse_ledge_steps':
            got = 0
            for i in range(3):
                ty0 = y - 3 + i * 3
                for X in range(x - 8 + i * 2, x + 8 - i * 2):
                    if flat[ty0 - 1:ty0 + 2, X].all() and not occ[ty0 - 1:ty0 + 2, X].any():
                        put(X, ty0, 'AL' if i == 0 else 'AS'); put(X, ty0 + 1, 'S3')
                        got += 1
        elif k == 'red_gate_row':
            got = 0
            for i in range(n):
                got += bool(near(x - (n - 1) * 5 + i * 10, y + (i % 2), TORII if i % 2 == 0 else TORII_S, None, 6, 0, where=soft))
        elif k == 'petal_drift':
            got = 0
            pm = disk(x, y, 9 + n) & flat & ~occ & ((xx * 7 + yy * 5) % 5 == 0) & (vnoise(1, 250 + x) > 0.4)
            paint(pm & ((xx + yy) % 2 == 0), 'PL'); paint(pm & ((xx + yy) % 2 == 1), 'PK')
            got = int(pm.sum())
        elif k == 'jade_waterfall':
            got = 'falls'
        elif k == 'jade_rock':
            got = cluster(x, y, [(CRAG, JADE), (STONE, JADE), (PEBBLE, JADE)], n + 1, 9, 0, where=soft)
        elif k == 'reed_bed':
            got = cluster(x, y, [(REED, None), (CATTAIL, None), (REED, None)], n + 3, 9, 0, where=soft)
        elif k == 'dragonfly_glints':
            got = 0
            for (dx, dy) in [(0, 0), (7, -4), (-6, -3), (4, 5), (-9, 4)][:n + 1]:
                X, Y = x + dx, y + dy
                if flat[Y, X - 1:X + 2].all() and not occ[Y, X - 1:X + 2].any():
                    put(X - 1, Y, 'NW'); put(X + 1, Y, 'NW'); put(X, Y, 'ND')
                    got += 1
        elif k in ('stalactites', 'stalagmites', 'hanging_roots'):
            got = 'near layer'
        elif k == 'oldest_lamp_post':
            # the oldest lamp: an unlit dark post on the old trace
            got = near(x, y, ['.k.', 'k2k', 'k1k', '.k.', '.2.', '.2.', 'k2k'], None, 8, 0, where=soft)
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # the faint unlit old road trace (Clovercove tunnel to the Market): dashed dark loam, no glow
    trace = P.get('old_road_trace', [])
    if trace:
        for i, (X, Y) in enumerate(raster([tuple(p) for p in trace])):
            if i % 4 == 3:
                continue
            if 0 <= X < W and 0 <= Y < H and F[Y, X] and not keep_pad[Y, X] and not root_corr[Y, X] and not occ[Y, X] \
                    and not near_road[Y, X]:
                put(X, Y, 'S4'); put(X, Y + 1, 'S3') if F[min(H - 1, Y + 1), X] and not keep_pad[min(H - 1, Y + 1), X] else None

    # the Long Wall: grey stone with crenels, broken round the keep discs; two watchtowers on it
    lw = P.get('long_wall', [])
    if lw:
        wpx = raster([tuple(p) for p in lw])
        okw = F & ~keep_pad & ~near_road & ~dil4(occ_water)
        for (X, Y) in wpx:
            if not okw[Y - 2:Y + 2, X].all():
                continue
            put(X, Y - 2, 'AL' if X % 3 else 'K')
            put(X, Y - 1, 'AL'); put(X, Y, 'AS'); put(X, Y + 1, 'K')
            put(X, Y + 2, 'S3') if not keep_pad[Y + 2, X] else None
            occ[Y - 3:Y + 3, X] = True
        for p in P['props']:
            if p['kind'] == 'wall_watchtower':
                X = p['x']
                ys_ = [Y for (Xw, Y) in wpx if Xw == X]
                if ys_ and okw[ys_[0] - 8:ys_[0] + 2, X - 3:X + 3].all():
                    spr(X, ys_[0] + 1, WATCHTOWER, {'r': 'S6', 'h': 'AL'})
                    occ[ys_[0] - 8:ys_[0] + 2, X - 3:X + 3] = True

    # biome scatter: low near the roads so the trunks read
    zf = lambda z: free & (zone == z) & ~occ_water
    far_road = ~pixmask(road_px, 9)
    scatter([(BAMBOO, BAMBOO_C), (BAMBOO_S, BAMBOO_C)], 40, zf('bamboo') & far_road, pad=0, tries=6000)
    scatter([(BAMBOO_S, BAMBOO_C), (FERN_S, OLD_C)], 20, zf('bamboo'), pad=0, tries=3000)
    scatter([(TREE, OLD_C), (TREE_S, OLD_C), (BUSH, None), (FERN, OLD_C)], 26, zf('base') & far_road, pad=1, tries=4000)
    scatter([(BUSH, None), (FERN_S, None)], 14, zf('base'), pad=1)
    scatter([(PERSIMMON_S, PERSIM_C), (BUSH, None)], 8, zf('hub') & far_road, pad=1)
    scatter([(REED, None), (FERN_S, None)], 18, zf('terrace'), pad=1)
    scatter([(STONE, GRAVEL), (PEBBLE, GRAVEL), (PEBBLE, GREY), (STONE, GREY)], 22, zf('gobi'), pad=1)
    scatter([(PEBBLE, GREY), (PEBBLE, None)], 10, zf('shore'), pad=1)
    scatter([(BIGLEAF, BIGLEAF_C), (FERN, BIGLEAF_C), (BIGLEAF, None), (FERN_S, BIGLEAF_C)], 70, zf('monsoon'), pad=0, tries=7000)
    scatter([(TREE, CHERRY_C), (TREE_S, CHERRY_C), (BIGTREE, CHERRY_C), (TREE_S, CHERRY_D)], 16, zf('blossom') & far_road, pad=1, tries=4000)
    scatter([(PEBBLE, GRAVEL), (STONE, GREY)], 8, zf('shelf'), pad=1)
    scatter([(CRAG, JADE), (STONE, JADE), (PEBBLE, JADE)], 30, zf('jade'), pad=1)
    scatter([(CRAG, JADE), (STONE, JADE)], 10, free & (xx > 370) & (yy > 212) & ~occ_water, pad=1)
    scatter([(REED, None), (CATTAIL, None)], 16, dil8(dil8(occ_water)) & ~occ_water & free & (zone != 'shore'), pad=0)

    # lanterns beside the trunks (gold glow)
    lamp_cand = pixmask(road_px, 6) & ~pixmask(road_px, 4) & free & ~occ
    ys, xs = np.nonzero(lamp_cand)
    idxs = list(range(len(xs)))
    R.shuffle(idxs)
    lamp_at = []
    for i in idxs:
        x, y = int(xs[i]), int(ys[i])
        if any((x - a) ** 2 + (y - b) ** 2 < 40 ** 2 for a, b in lamp_at):
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lamp_glows.append((x, y - 4, 7, 'GD'))
    for (x, y, r_, c_) in lamp_glows:
        lg = disk(x, y, r_) & F & ~keep_pad & ~road_m & ~occ_water & ~occ
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y) / float(r_), 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), c_)
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
                            put(X, Y, 'S5')
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
                    put(X, Y, 'S6')
    for px in roads:   # cast shadow under the trunk
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
        for s in (-1, 1):
            for j in range(0, 9):
                if e['side'] in ('N', 'S'):
                    X = ex + s * 6; Y = (H - 1 - j) if e['side'] == 'S' else j
                    put(X, Y, 'K'); put(X + s, Y, 'S4' if j % 3 else 'S5'); put(X + 2 * s, Y, 'K')
                else:
                    Y = ey + s * 6; X = (W - 1 - j) if e['side'] == 'E' else j
                    put(X, Y, 'K'); put(X, Y + s, 'S4' if j % 3 else 'S5'); put(X, Y + 2 * s, 'K')

    # ------------------------------------------------ 7. NEAR LAYER: root ceiling, stalactites, stalagmites
    keep = keep_m | pixmask(road_px, 4)
    falls_x, falls_y = 466, 172
    for p in P['props']:
        if p['kind'] == 'jade_waterfall':
            falls_x, falls_y = p['x'], p['y']
    falls_band = (np.abs(xx - (falls_x - 2)) <= 6) & (yy > falls_y - 40) & (yy < falls_y + 6)
    keep = keep | falls_band

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

    def root(x0, y1, thick, seed, col=('S5', 'S6')):
        r = random.Random(seed)
        ph = r.uniform(0, 6)
        pts = []
        for y in range(0, y1 + 1):
            x = x0 + int(round(2.2 * math.sin(y / 5.0 + ph) + 1.0 * math.sin(y / 2.3 + ph)))
            pts.append((x, y))
        for (x, y) in pts:
            if keep_pad[min(y + 3, H - 1), max(0, min(W - 1, x))] or occ_water[min(y + 1, H - 1), max(0, min(W - 1, x))] \
                    or near_road[min(y + 1, H - 1), max(0, min(W - 1, x))] or root_corr[min(y + 2, H - 1), max(0, min(W - 1, x))]:
                return False
        for (x, y) in pts:
            t = thick if y < y1 - 5 else 1
            rect(x - 1, y, x + t, y, 'K')
        for (x, y) in pts:
            t = thick if y < y1 - 5 else 1
            rect(x, y, x + t - 1, y, col[0])
            put(x, y, col[1])
        x, y = pts[-1]
        put(x, y + 1, 'K')
        for k in range(3, len(pts) - 4, 7):
            x, y = pts[k]
            sgn = r.choice([-1, 1])
            for t in range(1, r.randint(3, 6)):
                X, Y = x + sgn * (t + (thick if sgn > 0 else 0)), y + t
                if 0 <= X < W and not keep[Y, X]:
                    put(X, Y, col[0])
        return True

    # hanging roots over the Market, then a root ceiling across the cavern
    for p in P['props']:
        if p['kind'] == 'hanging_roots':
            got_r = 0
            for k in range(30):
                if got_r >= p.get('n', 3):
                    break
                x0 = p['x'] - 22 + RS.randrange(0, 45)
                if root(x0, RS.randint(20, 34), RS.choice([2, 3, 2]), SEED * 100 + 50 + k):
                    got_r += 1
    for k in range(16):
        x0 = RS.randrange(8, W - 8)
        root(x0, RS.randint(10, 26), RS.choice([1, 2, 2, 3]), SEED * 100 + k)
    for k in range(10):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S)
    for k in range(7):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'PL', 'u': 'T5', 'n': 't5'} if k % 2 else None)

    # the shut Clovercove gatehouse in the north ceiling (dressing, not an exit)
    for dm in P.get('dressing_mouths', []):
        gx, gy = dm['x'], dm['y']
        gb = gy + 3
        for j in range(0, gb - 6):   # the dark tunnel shaft behind it
            for X in range(gx - 4, gx + 5):
                put(X, j, 'S0' if abs(X - gx) < 4 else 'K')
        spr(gx, gb, GATEHOUSE, {'b': 'S4', 'B': 'S5', 'A': 'AL', 'a': 'AS'})
        put(gx, gb - 4, 'S6')   # the bar across the shut doors
        for X in range(gx - 3, gx + 4):
            put(X, gb - 3, 'S1')

    # the jade waterfall: a thin fall line on the east wall into the plunge pool
    fx = falls_x - 3
    for Y in range(falls_y - 36, falls_y + 1):
        put(fx - 1, Y, 'K'); put(fx + 3, Y, 'K')
        put(fx, Y, 'WL'); put(fx + 1, Y, 'WH' if (Y // 2) % 3 == 0 else 'WL'); put(fx + 2, Y, 'WA')
    for (ox, oy) in ((-3, -2), (4, -3), (-2, 1), (5, 0), (-4, -5), (6, -6)):
        put(fx + ox, falls_y + oy, 'WH')
    for (ox, oy) in ((-6, 2), (-8, -1), (7, 3)):
        put(fx + ox, falls_y + oy, 'NW')

    # mouths: the Spicepeak stone mouth with grey scree, the Monsoon mouth hung with vines and leaves
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['side'] == 'W':
            for s in (-1, 1):
                for j in range(0, 12):
                    Y = ey + s * (6 + j // 3); X = j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'AL' if j % 3 else 'AS'); put(X, Y + s, 'K')
        elif e['side'] == 'S':
            for s in (-1, 1):
                for j in range(0, 12):
                    X = ex + s * (5 + j // 3)
                    Y = H - 13 + j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'GK' if j % 2 else 'S5')
                    if j % 3 == 0:
                        put(X + s, Y - 1, 'K'); put(X - s, Y - 1, 'GK')
                    if j % 4 == 1:
                        put(X + s, Y, 'GM')
    # hanging vines over the south mouth and along the south wall (they hang up from the floor frame lip)
    for p in P['props']:
        if p['kind'] == 'hanging_vines':
            for k in range(14):
                X = p['x'] - 60 + k * 9 + RS.randint(-2, 2)
                if not (0 < X < W - 1):
                    continue
                top = H - 4
                ln_ = RS.randint(5, 11)
                if keep[top - ln_ - 2:H, X - 1:X + 2].any() or occ_water[top - ln_ - 2:H, X].any():
                    continue
                for j in range(ln_):
                    Y = top - j
                    put(X + (1 if (j // 3) % 2 else 0), Y, 'GK' if j % 2 else 'GM')
                put(X, top - ln_, 'T1')

    cols = np.unique(img.reshape(-1, 3), axis=0)
    allowed = {tuple(c) for c in PAL.values()}
    assert all(tuple(c) in allowed for c in cols), 'off-palette pixel'
    return img.copy(), dict(keeps=keeps, roads=roads, exits=exits, F=F, log=log, zone=zone)

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
    main = set((m['id'] if isinstance(m, dict) else m) for m in P.get('main_line', []))
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
    for sid, nm in ((229, 'JADE DRAGON-FLY LAIR'), (224, 'CHERRY BLOSSOM TEAHOUSE'), (225, 'THOUSAND GATES'), (227, 'PANDA BAMBOO GROVE'), (219, 'CARAVANSERAI')):
        if sid in spread:
            want.append((spread[sid][0], spread[sid][1], (nm or slots[sid]['loc']['name']).upper(), False, 4))
    rootm = np.zeros((H, W), bool)
    for sid in places:
        a = slots.get(anchors.get(sid, 0))
        if a:
            rootm |= pixmask(raster([(a['x'], a['y']), spread[sid]]), 2)
    boxes = []
    pts = [(s['x'], s['y'], 6) for s in slots.values() if s['type'] != 'off'] + [(x, y, 5) for (x, y) in spread.values()]
    for (x, y, name, town, r) in want:
        tw = text_w(name) + 6; th = 11
        cands = [(x - tw // 2, y + r + 2), (x - tw // 2, y - r - 2 - th), (x + r + 3, y - th // 2), (x - r - 3 - tw, y - th // 2),
                 (x + r, y + r), (x - tw - r, y + r), (x + r, y - r - th), (x - tw - r, y - r - th)]
        if name in ('BIRCHFORD', 'LILYBY'):   # their roots leave due east: labels on the west side
            cands = [cands[3]] + cands[:3] + cands[4:]
        best = None
        for ci, (bx, by) in enumerate(cands):
            bx = int(bx); by = int(by)
            if bx < 2 or by < 2 or bx + tw > W - 2 or by + th > H - 2:
                continue
            if any(not (bx + tw + 1 < a or a2 + 1 < bx or by + th + 1 < b or b2 + 1 < by) for (a, b, a2, b2) in boxes):
                continue
            pen = ci * 0.5 + rootm[by:by + th, bx:bx + tw].sum() * 0.2
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-EA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-EA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-EA.png'))
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

