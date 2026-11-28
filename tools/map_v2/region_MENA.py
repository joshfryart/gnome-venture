#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for MENA "The Dunewhisper" (band orange, Lv 35-45).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built on the
NA generator: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside with a
dithered orange halo and an orange rim light (gold in the north-west corner before the Olivewhistle
Seal gate), biome ground (the pale swept Market basin with date-palm rows, awnings and the Seed Bed;
the Olivewhistle breath with red stony soil, olives, lemons and a sea-cave pool; the Amber Erg with
crescent dunes, amber rock teeth, wind ripples and the scarab tomb pylons; the dry steppe shelf with
dry grass, thorn, the hanging terraces, broken columns, cedars and spice sacks; the Greatcanopy breath
going from savanna to dark broadleaf and vines, a creek and web strands; the rose-red Canyon with
mesas, carved door fronts and a dry wadi; the Spicepeak breath of grey stone, pines, steps, prayer
flags and frost), the Oasis That Moves (one bright pool north of its marker, two dry prints), glowing
road trunks on the layout polylines and the three exit tunnel mouths; a root ceiling and a
stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one zone, one or two flat tones; texture fades in over 9 px outside, no sprites, no water, no texture).

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_MENA.py [--layout layout-MENA.json] [--plan plan-MENA.json]
                                      [--out game/assets/img/scenes/map2-MENA.png]
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
CODE = 'MENA'
SEED = 21


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
BRIGHT, DIM = 'T4', 't4'  # band orange
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


def bez(p0, c, p1, n=48):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * c[0] + t * t * p1[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * c[1] + t * t * p1[1]) for t in (k / n for k in range(n + 1))]


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



# ---------------------------------------------------------------- Dunewhisper sprites
DATEPALM = ['.kk...kk.', 'kGgk.kgdk', '.kggkggk.', 'kgkeBekgk', 'kk.kbk.kk', '...kBk...', '...kbk...', '...kbk...',
            '...kkk...']
PALM_Y = ['g.g', 'kgk', '.b.']
OLIVE_T = ['.kkkk.', 'kAgAdk', 'kgAgdk', '.kddk.', '..bk..', '.kbbk.']
LEMON_T = ['.kkkk.', 'kgsgdk', 'kGgsdk', '.kddk.', '..bk..', '.kbbk.']
CEDAR_T = ['....kk....', '..kkGgkk..', '.kGgggddk.', '..kkkbkk..', '.kkGggdkk.', 'kGgggggddk', '.kkkbBkkk.',
           '....bB....', '...kkkk...']
CEDAR_S = ['..kk..', '.kGgk.', 'kkkbkk', 'kGggdk', '.kbBk.', '.kkkk.']
AWNING = ['kkkkkkkkk', 'krsrsrsrk', 'kkkkkkkkk', '.b.....b.', '.b.....b.', 'kk.....kk']
AWNING_O = {'r': 'RD', 's': 'SN'}
AWNING_B = {'r': 'T4', 's': 'SN'}
SACKS = ['.k.k.k.', 'krkokyk', 'krkokyk', 'kkkkkkk']
CAMEL = ['.......kk', '..kk..ksk', '.kssk.ks.', 'kssssss..', 'kSSSSSk..', '.kSkSk...', '.k.k.k...']
CAMEL_O = {'s': 'SN', 'S': 'SD'}
OBELISK = ['.k...', 'kAk..', 'kAak.', 'kAak.', 'kAak.', 'ksSss']
PYLON = ['kkkkkk...kkkkkk', 'kSsssk...kssssk', 'kSsssk...kssssk', 'kSsssk.k.kssssk', 'kSssskk1kkssssk',
         'kSsssk1r1kssssk', 'kSsssk1r1kssssk', 'kkkkkkkkkkkkkkk']
PYLON_O = {'s': 'SN', 'S': 'SD'}
MUDTOWER = ['.kkkk.', 'kSssSk', 'kS1sSk', 'bSssSb', 'kSs1Sk', 'bSssSb', 'kSssSk', 'kSs1Sk', 'kkkkkk']
MUDO = {'s': 'SD', 'S': 'S6', '1': 'S3'}
BCOL = ['.kk.', 'kwAk', 'kAak', 'kwAk', 'kAak', 'kkkk']
BCOL_S = ['kkk', 'kAk', 'kak', 'kkk']
SANDSTONE = {'A': 'SN', 'a': 'SD', '1': 'S5', 'w': 'SN'}
AMBER = {'A': 'SN', 'a': 'S6', '1': 'S5'}
REDROCK = {'A': 'RH', 'a': 'RE', '1': 'RK', 'w': 'SN'}
MESA = ['..kkkkkk...', '.khhheeekk.', 'kheeeeeeRk.', 'keeReeeeRRk', 'keRRReRRRRk', 'kkkkkkkkkkk']
MESA_S = ['.kkkk..', 'khheekk', 'keeeRRk', 'kkkkkkk']
FACADE = ['kkkkkkkkkkkkk', 'khhhhhhhhhhek', 'khkkkkkkkkkek', 'khkhk...khkek', 'khkhk.1.khkek', 'khkhk111khkek',
          'kekek111kekRk', 'kkkkkkkkkkkkk']
STEPS = ['kkkkk...', 'kAAak...', 'kkkkkkk.', '.kAAAak.', '.kkkkkkk', '..kAAAak', '..kkkkkk']
BUSH_D = ['.kkk.', 'kMmMk', 'kmMmk', '.kkk.']
THORN_B = ['k.k.k', '.kbk.', 'kbMbk', '.kbk.']
DRYGRASS = ['M.m', 'mMm', '.m.']
TALLGRASS = ['S.s', 'g.S', 'gdg', '.d.']
BONES = ['w.w', '.w.', 'w.w']
SEALGATE = ['kk.kk', 'kAkAk', 'kAyak', 'kAyak', 'kAaak', 'kAaak', 'kkkkk']
LAMP_DARK = ['.k.', 'kak', 'k1k', '.k.', '.b.', '.b.', 'kbk']
JUNGLE = {'g': 'GM', 'G': 'T1', 'd': 'GK'}
JUNGLE_D = {'g': 'GK', 'G': 'GM', 'd': 't1'}
CEDAR = {'g': 'GK', 'G': 'GM', 'd': 't1'}
SNOWPINE = {'G': 'WH', 'g': 'GK', 'd': 't1'}
FROSTSTONE = {'A': 'WH', 'a': 'AL', '1': 'AS'}
CYANCAP = {'r': 'WA', 'w': 'WL'}


def biome_soft(b, r=4, noise=None, amp=0.45):
    """0..1 soft weight of a plan biome (polygon or ellipse) with noisy edges."""
    if b['shape'] == 'polygon':
        s = blur(poly_mask(b['points']).astype(float), r)
    else:
        e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
        s = np.clip(1.5 - e, 0, 1)
    if noise is not None:
        s = s + amp * (noise - 0.5)
    return s


# ================================================================ RENDER
def render(L, P, slots, spread, anchors):
    global img
    R = random.Random(SEED)
    img = np.zeros((H, W, 3), np.uint8)
    keeps = keep_circles(L, slots, spread)
    exits = {e['id']: e for e in L['exits']}
    BIO = {b['type']: b for b in P['biomes']}

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
    F |= pixmask(road_px, 4)
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

    # rim / halo colour: orange (tier 4), gold in the north-west corner before the Seal gate
    gw = blur(poly_mask(BIO['olivewhistle_breath']['points']).astype(float), 10)
    gold = (gw + 0.25 * (vnoise(6, 140) - 0.5)) > 0.30
    rimB = np.where(gold, 'T3', BRIGHT)
    rimD = np.where(gold, 't3', DIM)

    def paint_by(mask, cols):
        for c in np.unique(cols[mask]) if mask.any() else []:
            paint(mask & (cols == c), c)

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
    # the slanting south-east wall is solid rock: red sandstone strata seen through the dark
    slant = ~F & (xx > 300) & (yy > 120) & (outd > 3)
    paint(slant & (np.abs(strata) < 0.22) & (n2 > 0.48) & (BAY > 0.55), 'RK')
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
    paint_by(~F & (outd > 4) & (hval ** 1.5 > BAY + 0.04), rimD)
    paint_by(~F & (outd > 4) & (outd < 8) & (hval ** 3 > BAY + 0.35), rimB)
    for _ in range(70):
        x = R.randrange(2, W - 3); y = R.randrange(14, H - 14)
        if outd[y, x] < 7 or F[y, x]:
            continue
        b, dm = R.choice([('T2', 't2'), ('T5', 't5'), ('NW', 'ND'), ('GD', 't3'), (BRIGHT, DIM), (BRIGHT, DIM)])
        put(x, y, b); put(x, y + 1, dm)
        if R.random() < .3:
            put(x, y - 1, 'WH')

    # ------------------------------------------------ 2. ZONES from the plan biomes (noisy edges)
    zone = np.full((H, W), 'base', dtype=object)
    dth = (BAY - 0.5) * 0.30  # dithered zone edges
    w_ol = biome_soft(BIO['olivewhistle_breath'], 6, vnoise(7, 101), 0.35)
    w_erg = biome_soft(BIO['amber_erg'], 3, vnoise(7, 102), 0.45)
    w_st = biome_soft(BIO['dry_steppe_shelf'], 3, vnoise(7, 103), 0.45)
    w_gc = biome_soft(BIO['greatcanopy_breath'], 8, vnoise(7, 104), 0.30)
    w_gc = w_gc * np.clip(1.45 - np.hypot(xx - 40, yy - 245) / 150.0, 0, 1)  # greener toward the SW mouth
    w_cy = biome_soft(BIO['rose_red_canyon'], 4, vnoise(6, 105), 0.40)
    w_sp = biome_soft(BIO['spicepeak_breath'], 8, vnoise(7, 106), 0.30) * np.clip((xx - 318) / 55.0, 0, 1)
    w_mk = biome_soft(BIO['market_basin'], 0, vnoise(7, 107), 0.30)
    zone[(w_erg > 0.5 + dth)] = 'erg'
    zone[(w_st > 0.5 + dth)] = 'steppe'
    zone[(w_ol > 0.45 + dth)] = 'olive'
    zone[(w_gc > 0.30 + dth)] = 'savanna'
    zone[(w_gc > 0.62 + dth)] = 'jungle'
    zone[(w_sp > 0.28 + dth)] = 'stonesand'
    zone[(w_sp > 0.58 + dth)] = 'stone'
    zone[(w_mk > 0.5 + dth * 1.3)] = 'market'
    zone[(w_cy > 0.20 + dth * 1.5) & (zone != 'stone') & (zone != 'stonesand')] = 'canyonedge'
    zone[(w_cy > 0.55 + dth)] = 'canyon'
    # plain ground: one zone per keep circle (the zone most of the ring round it belongs to)
    z0 = zone.copy()
    for (_, x, y, r) in keeps:
        ring = disk(x, y, r + 6) & ~disk(x, y, r + 1) & F
        vals, cnt = np.unique(z0[ring if ring.any() else disk(x, y, r)], return_counts=True)
        zc = z0[int(np.clip(y, 0, H - 1)), int(np.clip(x, 0, W - 1))]
        share = dict(zip(vals, cnt / max(1, cnt.sum())))
        # the zone under the centre, unless it is only a speck of the surroundings
        zone[disk(x, y, r + 1)] = zc if share.get(zc, 0) >= 0.30 else vals[int(np.argmax(cnt))]
    zone[~F] = 'base'

    RAMPS = {
        'base': ['S4', 'S5', 'SD', 'SN'], 'erg': ['S5', 'S6', 'SD', 'SN'], 'steppe': ['S4', 'S5', 'SD', 'SN'],
        'market': ['S5', 'SD', 'SN', 'SN'], 'olive': ['S4', 'S5', 'SD', 'SN'],
        'savanna': ['S4', 'S5', 'SD', 'SN'], 'jungle': ['t1', 'GK', 'GK', 'GM'],
        'canyonedge': ['S4', 'S5', 'SD', 'SN'], 'canyon': ['S4', 'RK', 'RE', 'RE'],
        'stonesand': ['S4', 'S5', 'AS', 'SD'], 'stone': ['S3', 'S4', 'AS', 'AL'],
    }
    BIAS = {'market': 0.10, 'erg': 0.04, 'jungle': 0.06, 'stone': 0.04, 'canyon': 0.06}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.19 + 0.46 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.22 * np.exp(-(dt / 80.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.20 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    # distance outside the nearest keep circle: texture and detail fade in over 9 px so the plain discs blend
    kd = np.full((H, W), 99.0)
    for (_, x, y, r) in keeps:
        kd = np.minimum(kd, np.hypot(xx - x, yy - y) - r)
    soft_keep = np.clip(kd / 9.0, 0, 1)
    lv = lightv + 0.14 * (tex - 0.5) * soft_keep
    gi = np.floor(lv * 4 - 0.4 + (BAY - 0.5) * 0.55).astype(int).clip(0, 3)
    gi = np.where(keep_m, np.clip(gi, 1, 3), gi)
    for zname, ramp in RAMPS.items():
        zm = F & (zone == zname)
        for i in range(4):
            paint(zm & (gi == i), ramp[i])
    inner = F & ~ero4(F)
    for zname, ramp in RAMPS.items():
        paint(inner & (zone == zname), ramp[0])
    busyok = F & ~keep_m & (depth > 2) & (BAY2 < soft_keep * 1.15)
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86) & (zone != 'stone')
    for zname, ramp in RAMPS.items():
        if zname in ('market',):
            continue
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    # Olivewhistle breath: red stony soil (terra rossa) dithered into the sand, grey scree at the wall
    oz = busyok & (zone == 'olive')
    tr = np.clip(w_ol - 0.35, 0, 1) * 1.6
    trp = vnoise(6, 121) + 0.25 * tr
    paint(oz & (trp > 0.62) & (BAY < 0.55), 'RE')
    paint(oz & (trp > 0.50) & (trp <= 0.62) & (BAY < 0.20), 'RE')
    paint(oz & (trp > 0.78) & (BAY > 0.85), 'RK')
    paint(oz & (depth < 6) & (vnoise(1, 123) > 0.82), 'AS')
    # savanna: green grass dither into the sand, denser toward the jungle
    sz = busyok & (zone == 'savanna')
    gden = np.clip((w_gc - 0.30) / 0.32, 0, 1)
    paint(sz & (vnoise(1, 124) > 0.86 - 0.32 * gden) & (gi >= 1), 'GM')
    paint(sz & (vnoise(1, 125) > 0.90 - 0.30 * gden) & (gi <= 2), 'GK')
    jz = busyok & (zone == 'jungle')
    paint(jz & (vnoise(1, 126) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    paint(jz & (vnoise(1, 127) > 0.88) & (gi >= 2), 'GM')
    # canyon: red sandstone strata cracks + RH highlights;  edge: red grit in the sand
    sn = vnoise(5, 61)
    crk = (np.abs(np.sin((xx * 0.55 + yy + 14 * sn) / 3.2)) < 0.16) & (vnoise(3, 62) > 0.45)
    cz = busyok & (zone == 'canyon')
    band = np.sin((yy + 3.0 * np.sin(xx / 9.0) + 8.0 * vnoise(9, 141)) / 1.9)
    stripe = (band > 0.72) & (vnoise(4, 142) > 0.30)
    paint(cz & stripe, 'RK')
    paint(cz & dil4(stripe) & ~stripe & (yy % 2 == 0) & (gi >= 2) & (vnoise(1, 63) > 0.70), 'RH')
    paint(cz & crk & ~stripe & (vnoise(3, 143) > 0.55), 'S4')
    paint(cz & (vnoise(1, 128) > 0.95) & (gi >= 2), 'RD')
    ce = busyok & (zone == 'canyonedge')
    cedge = np.clip((w_cy - 0.20) / 0.35, 0, 1)
    paint(ce & (BAY < 0.15 + 0.55 * cedge), 'RE')
    paint(ce & (BAY < 0.08 + 0.25 * cedge) & (gi <= 1), 'RK')
    # Spicepeak: grey stone under thin sand
    for zname in ('stone', 'stonesand'):
        stz = busyok & (zone == zname)
        paint(stz & crk & (gi >= 1), 'S4' if zname == 'stonesand' else 'S3')
        paint(stz & dil4(crk) & ~crk & (yy % 2 == 0) & (gi >= 2) & (vnoise(1, 64) > 0.75), 'AL')
    paint(busyok & (zone == 'stone') & (BAY > 0.80) & (vnoise(6, 131) > 0.62), 'SD')
    paint(busyok & (zone == 'stonesand') & (BAY > 0.50) & (gi >= 1), 'SD')
    # dry steppe: dry grass speckle
    stp = busyok & (zone == 'steppe')
    paint(stp & (vnoise(1, 132) > 0.88) & (vnoise(7, 133) > 0.45), 'MY')
    paint(stp & (vnoise(1, 134) > 0.93), 'MD')
    # wind ripples on the open sand (erg, base, steppe edge) - never in the keep circles
    sandz = busyok & ((zone == 'erg') | (zone == 'base') | (zone == 'canyonedge'))
    rn = vnoise(12, 50)
    for k in range(0, H, 6):
        ph = k * 0.7
        yc = k + 2.0 * np.sin((xx + ph * 9) / 7.0) + 0.18 * (xx - 240) * 0.1
        wave = np.abs(yy - yc) < 0.55
        paint(sandz & wave & (rn > 0.55) & (gi >= 1) & ((xx + k) % 9 != 0), 'S6')
        wave2 = np.abs(yy - 1 - yc) < 0.55
        paint(sandz & wave2 & (np.cos((xx + ph * 9) / 7.0) > 0.1) & (rn > 0.55) & (gi >= 2), 'SN')
    # rim: K outline, band-colour rim light (gold in the NW), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint_by(d4 & ~d3, rimD)
    paint_by(d3 & ~d1, rimB)
    paint_by(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), rimD)
    paint(d1 & ~F, 'K')

    # ------------------------------------------------ 4. WATERS (never inside a keep circle; dry ground under each)
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2 * isl
    near_road3 = pixmask(road_px, 4)
    water = np.zeros((H, W), bool)
    shore_c = {}
    prints = []
    pools = []
    oas = BIO.get('moving_oasis')
    if oas:
        # one bright pool just north of the Oasis marker: slide it north until it clears the keep circles
        cx, cy, rx, ry = oas['cx'], oas['cy'], 11, 4
        for dy in range(0, 30):
            e = ((xx - cx) / rx) ** 2 + ((yy - (cy - dy)) / ry) ** 2 <= 1
            if not (e & (keep_wet | near_road3)).any():
                pools.append((cx, cy - dy, rx, ry, 'GK'))
                break
    for p in P['props']:
        if p['kind'] == 'sea_cave_pool':
            pools.append((p['x'] + 4, p['y'], 5, 3, 'AS'))
        elif p['kind'] == 'reed_pool':
            pools.append((p['x'], p['y'], 7, 3, 'GK'))
    for (cx, cy, rx, ry, sc) in pools:
        wob = 0.22 * (vnoise(4, cx * 7 + cy) - 0.5)
        e = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 + wob <= 1
        e &= F & ~keep_wet & ~near_road3 & (depth >= 2)
        water |= e
        shore_c[(cx, cy)] = (e, sc)
    # the creek: a shallow meander past Pebblenook toward the south wall
    creek_px = []
    for p in P['props']:
        if p['kind'] == 'creek':
            pts = [(p['x'] + 16 - t, p['y'] - 6 + t * 0.55 + 2.5 * math.sin(t / 4.0)) for t in range(0, 40)]
            creek_px = raster(pts)
    creek_m = pixmask(creek_px, 1) & F & ~keep_wet & ~near_road3
    for (cx, cy), (e, sc) in shore_c.items():
        sh = dil8(e) & ~e & F & ~keep_m
        paint(sh, sc)
    paint(dil4(creek_m) & ~creek_m & F & ~keep_m, 'S5')
    paint(water | creek_m, 'WA')
    paint(water & ~dil4(~water) & (yy % 3 == 0) & ((xx * 3 + yy) % 5 == 0), 'WL')
    for (cx, cy, rx, ry, sc) in pools:
        e = shore_c[(cx, cy)][0]
        if (cx, cy) == (pools[0][0], pools[0][1]) and oas:
            paint(e & (yy < cy) & (xx < cx + 2) & ~dil4(~e), 'WL')  # the bright one
            paint(e & (yy >= cy + 1) & ((xx + yy) % 2 == 0), 't2')
        else:
            paint(e & (yy >= cy) & ((xx + yy) % 2 == 0), 'D2')  # creek / reed pool / cave pool one step darker
    paint(creek_m & ((xx + yy) % 4 == 0), 'WL')
    paint(creek_m & (yy % 2 == 0) & ((xx + yy) % 3 == 0), 't2')
    occ_water = water | creek_m

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    protect = keep_pad | near_road | root_corr | dil4(occ_water)
    free = F & ~protect & (depth >= 2)
    flat_ok = F & ~keep_pad & ~near_road & ~dil4(occ_water) & (depth >= 1)  # ground patches may lie under roots
    occ = np.zeros((H, W), bool)
    placed = []
    after = []  # drawn after the roads (the Seal gate stands on its road)

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

    def dune(x, y, rx, ry, where=None):
        """crescent dune: lit windward face (SN), slip-face hollow in shadow (S5/S6), dark lip"""
        where = free if where is None else where
        sl = (slice(max(0, y - ry - 2), y + ry + 3), slice(max(0, x - rx - 2), x + rx + 3))
        if where[sl].mean() < 0.97 or occ[sl].any():
            return False
        # barchan seen from above: a lit crescent (wind from the north-west), horns pointing south-east,
        # a narrow slip face in shadow on the inside of the crescent
        e = ((xx - x) / rx) ** 2 + ((yy - y) / ry) ** 2
        e2 = ((xx - x - rx * 0.30) / (rx * 0.80)) ** 2 + ((yy - y - ry * 0.80) / (ry * 0.95)) ** 2
        body = (e <= 1) & (e2 > 1) & where
        slip = (e2 <= 1) & (e2 > 0.45) & (e <= 1.0) & where & (yy < y + ry * 0.9)
        paint(body, 'SD')
        paint(body & (yy < y - ry * 0.05) & (xx < x + rx * 0.6), 'SN')
        paint(body & (yy >= y) & ((xx + yy) % 2 == 0), 'SN')
        paint(slip, 'S6')
        paint(slip & (e2 > 0.72), 'S5')
        paint(slip & (e2 <= 0.60) & ((xx + yy) % 2 == 0), 'SD')
        crest = body & dil4(slip)
        paint(crest, 'SN')
        paint(dil4(body) & ~body & ~slip & (yy > y) & where & ((xx + yy) % 2 == 0), 'S6')
        occ[sl] = True
        return True

    def patch(x, y, rx, ry, fn, seed, where=None):
        where = flat_ok if where is None else where
        e = ((xx - x) / rx) ** 2 + ((yy - y) / ry) ** 2 + 0.5 * (vnoise(3, seed) - 0.5) <= 1
        e &= where & ~occ
        fn(e)
        return int(e.sum())

    log = []
    FIRST = ['hanging_terrace', 'scarab_tomb_pylons', 'mud_ladder_tower', 'carved_door_fronts', 'half_buried_obelisk',
             'seed_bed_date_damask_rose', 'caravan_camel_line', 'market_awnings', 'date_palm_row']
    props = sorted(P['props'], key=lambda p: FIRST.index(p['kind']) if p['kind'] in FIRST else len(FIRST))
    for p in props:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        got = None
        if k == 'seed_bed_date_damask_rose':
            bw, bh = 12, 5
            x0, y0 = x - bw // 2, y - bh // 2
            for (dx, dy) in [(0, 0), (2, 1), (-2, 1), (0, 2), (3, -1), (-3, -1), (4, 2), (-4, 2), (0, -2)]:
                sl = (slice(y0 + dy - 2, y0 + dy + bh + 1), slice(x0 + dx - 1, x0 + dx + bw + 1))
                if flat_ok[sl].all() and not occ[sl].any():
                    X0, Y0 = x0 + dx, y0 + dy
                    rect(X0 - 1, Y0 - 1, X0 + bw, Y0 + bh, 'S4')
                    rect(X0, Y0, X0 + bw - 1, Y0 + bh - 1, 'S5')
                    for i in range(bw):
                        for j in range(bh):
                            if j % 2 == 0:
                                put(X0 + i, Y0 + j, 'S6' if i % 2 else 'S5')
                    for i in range(0, bw, 2):  # damask-rose edge (the only pink on the map)
                        put(X0 + i, Y0 - 1, 'PK'); put(X0 + i + 1, Y0 + bh, 'PK')
                    put(X0 - 1, Y0 + 1, 'PL'); put(X0 + bw, Y0 + 2, 'PL')
                    occ[sl] = True
                    for i in (2, 6, 10):
                        spr(X0 + i, Y0 + 3, PALM_Y)
                    got = (X0, Y0)
                    break
        elif k in ('date_palm_row', 'date_palm', 'oasis_palm'):
            got = 0
            for i in range(n):
                got += bool(near(x - (n - 1) * 5 + i * 10, y + 3, DATEPALM if k != 'date_palm' or i == 0 else PALM_Y, None, 6, 0))
        elif k == 'market_awnings':
            got = 0
            for i in range(n):
                got += bool(near(x - 6 + i * 12, y + (i % 2) * 3, AWNING, AWNING_O if i % 2 == 0 else AWNING_B, 7, 0))
        elif k == 'hanging_roots':
            got = 'ceiling'
        elif k == 'lamp_post_dark':
            got = near(x, y, LAMP_DARK, None, 6, 0, where=flat_ok & ~root_corr)
        elif k == 'gate_olivewhistle_seal':
            after.append(('gate', x, y))
            got = 'after-roads'
        elif k == 'olive_tree':
            got = cluster(x, y, [(OLIVE_T, None), (OLIVE_T, None)], n, 9)
        elif k == 'lemon_tree':
            got = cluster(x, y, [(LEMON_T, None)], n, 9)
        elif k == 'terra_rossa_patch':
            def tr_(e):
                paint(e & (BAY > 0.25), 'RE'); paint(e & (BAY > 0.80), 'RK'); paint(e & (BAY < 0.12), 'SD')
            got = patch(x, y, 9, 5, tr_, 150) + patch(x + 14, y + 6, 6, 3, tr_, 151)
            got += cluster(x, y, [(PEBBLE, REDROCK), (STONE, REDROCK)], 2, 10)
        elif k == 'sea_cave_pool':
            got = 'water'
            # a cave lip of grey rock round the pool
            cluster(x + 2, y - 4, [(PEBBLE, None), (STONE, None)], 2, 6)
        elif k == 'scree_boulders':
            got = cluster(x, y, [(STONE, None), (PEBBLE, None), (CRAG, None), (PEBBLE, None)], n + 3, 11)
        elif k == 'crescent_dune':
            got = None
            for (dx, dy) in [(0, 0), (3, 2), (-3, -2), (5, -3), (-5, 3), (0, 5), (0, -5), (8, 0), (-8, 0)]:
                if dune(x + dx, y + dy, 11, 4):
                    got = (x + dx, y + dy); break
        elif k == 'amber_rock':
            got = cluster(x, y, [(CRAG, AMBER), (STONE, AMBER), (PEBBLE, AMBER)], n, 9)
        elif k == 'scarab_tomb_pylons':
            # set into the west wall: walk east from the rock edge on row y
            row = np.nonzero(F[y, :60])[0]
            tx = int(row[0]) + 6 if len(row) else x
            got = near(tx, y + 2, PYLON, PYLON_O, 6, 0, where=F & ~keep_pad & ~root_corr | (~F & (xx < tx)))
        elif k == 'scarab_track':
            got = 0
            for i in range(9):
                X = x - 16 + i * 4; Y = y + int(round(2 * math.sin(i / 1.6)))
                for (ox, oy) in ((0, 0), (1, 2)):
                    if flat_ok[Y + oy, X + ox] and not occ[Y + oy, X + ox]:
                        put(X + ox, Y + oy, 'S4'); got += 1
        elif k == 'half_buried_obelisk':
            got = near(x, y, OBELISK, SANDSTONE, 8, 0)
        elif k == 'dry_grass':
            got = cluster(x, y, [(DRYGRASS, None), (DRYGRASS, None), (BUSH_D, None)], n + 2, 12)
        elif k == 'thorn_bush':
            got = cluster(x, y, [(THORN_B, None), (BUSH_D, None)], n, 9)
        elif k == 'broken_column':
            got = cluster(x, y, [(BCOL, SANDSTONE), (BCOL_S, SANDSTONE), (BCOL_S, SANDSTONE)], n, 8)
        elif k == 'hanging_terrace':
            # three stepped sandstone terraces with green hanging off each lip
            got = None
            for (dx, dy) in sorted([(a, b) for a in range(-16, 17, 2) for b in range(-8, 9, 2)], key=lambda q: q[0] ** 2 + q[1] ** 2):
                X, Y = x + dx, y + dy
                sl = (slice(Y - 9, Y + 4), slice(X - 11, X + 12))
                if free[sl].all() and not occ[sl].any():
                    for t, (w2, yo) in enumerate([(10, -8), (8, -4), (6, 0)]):
                        rect(X - w2 - 1, Y + yo - 1, X + w2 + 1, Y + yo + 2, 'K')
                        rect(X - w2, Y + yo, X + w2, Y + yo + 1, 'SN')
                        rect(X - w2, Y + yo + 1, X + w2, Y + yo + 1, 'SD')
                        for i in range(-w2, w2 + 1, 2):
                            put(X + i, Y + yo + 2, 'GM' if (i + t) % 4 else 'GK')
                            if (i + t) % 3 == 0:
                                put(X + i, Y + yo + 3, 'GK')
                            if i % 4 == 0:
                                put(X + i, Y + yo, 'GM')
                    occ[sl] = True
                    got = (X, Y); break
        elif k == 'cedar':
            got = cluster(x, y, [(CEDAR_T, CEDAR), (CEDAR_S, CEDAR)], n, 9)
        elif k == 'spice_sacks':
            got = cluster(x, y, [(SACKS, None)], n, 7)
        elif k == 'dry_oasis_print':
            prints.append((x, y))
            got = 'ring'
        elif k == 'caravan_camel_line':
            got = 0
            for i in range(3):
                got += bool(near(x - 12 + i * 11, y + (i % 2), CAMEL, CAMEL_O, 9, 0))
        elif k == 'mud_flat':
            def mud_(e):
                paint(e, 'S5'); paint(e & (BAY > 0.6), 'S6')
                cr = e & ((np.abs(np.sin(xx * 0.9 + 2 * np.sin(yy * 0.7))) < 0.12) | (np.abs(np.sin(yy * 1.1 + xx * 0.3)) < 0.10))
                paint(cr, 'S3')
            got = patch(x, y, 12, 5, mud_, 152)
        elif k == 'mud_ladder_tower':
            got = near(x, y + 4, MUDTOWER, MUDO, 9, 0)
        elif k == 'broadleaf_tree':
            got = cluster(x, y, [(BIGTREE, JUNGLE_D), (TREE, JUNGLE), (TREE, JUNGLE_D), (BIGTREE, JUNGLE)], n, 10)
        elif k == 'vine_curtain':
            got = 0
            for i in range(n * 4):
                vx = x - 8 + i * 3 + R.randint(-1, 1)
                col = np.nonzero(F[:, max(0, vx)] & (yy[:, 0] > y - 30) & (yy[:, 0] < y + 20))[0]
                if len(col) == 0:
                    continue
                vy = y - 10 + R.randint(-3, 3)
                ln = R.randint(5, 11)
                if keep_pad[vy:vy + ln + 1, vx - 1:vx + 2].any() or root_corr[vy:vy + ln, vx].any():
                    continue
                for j in range(ln):
                    X = vx + int(round(1.0 * math.sin(j / 2.0 + i)))
                    put(X, vy + j, 'GK' if j % 3 else 'GM')
                    if j % 3 == 1:
                        put(X + 1, vy + j, 'GM')
                got += 1
        elif k == 'savanna_grass':
            got = cluster(x, y, [(TALLGRASS, None), (TALLGRASS, None), (DRYGRASS, None)], n + 3, 12)
        elif k == 'creek':
            got = len(creek_px)
        elif k == 'web_strands':
            got = 0
            for i in range(n):
                cx_, cy_ = None, None
                for (dx, dy) in sorted([(a, b) for a in range(-14, 15) for b in range(-10, 4)], key=lambda q: q[0] ** 2 + q[1] ** 2):
                    X0, Y0 = x - 6 + i * 12 + dx, y - 3 + dy
                    if F[Y0, X0] and not (keep_pad | occ | root_corr | near_road)[Y0 - 5:Y0 + 6, X0 - 6:X0 + 7].any():
                        cx_, cy_ = X0, Y0
                        break
                if cx_ is None:
                    continue
                occ[cy_ - 5:cy_ + 6, cx_ - 6:cx_ + 7] = True
                for a in range(6):
                    ang = a * math.pi / 3 + 0.3
                    for t in range(1, 6):
                        X = cx_ + int(round(math.cos(ang) * t)); Y = cy_ + int(round(math.sin(ang) * t * 0.7))
                        if F[Y, X]:
                            put(X, Y, 'AL' if t % 2 else 'WH')
                for t in range(-3, 4):
                    put(cx_ + t, cy_ + (2 if abs(t) < 3 else 1), 'AL')
                got += 1
        elif k == 'pebble_bar':
            got = cluster(x, y, [(PEBBLE, None), (PEBBLE, SANDSTONE), (STONE, None)], 4, 9)
        elif k == 'mesa_block':
            got = 0
            for i in range(n):
                got += bool(near(x + i * 14 - (n - 1) * 7, y, MESA if i == 0 else MESA_S, None, 12, 0))
        elif k == 'carved_door_fronts':
            # in the canyon wall: walk down from (x, y) to the floor edge
            col = np.nonzero(F[:, x])[0]
            by_ = int(col[-1]) - 1 if len(col) else y
            got = near(x, min(y, by_), FACADE, None, 10, 0, where=F & ~keep_pad & ~near_road & ~root_corr | ~F)
        elif k == 'dry_wadi':
            pts = [(x + 18 - t, y + 9 - t * 0.55 + 2.0 * math.sin(t / 5.0)) for t in range(0, 40)]
            wm = pixmask(raster(pts), 1) & flat_ok & ~occ
            paint(wm, 'S5'); paint(wm & ((xx + yy) % 2 == 0), 'S4')
            paint(dil4(wm) & ~wm & flat_ok & ~occ & (BAY > 0.5), 'RE')
            got = int(wm.sum())
        elif k == 'red_boulders':
            got = cluster(x, y, [(CRAG, REDROCK), (STONE, REDROCK), (PEBBLE, REDROCK)], n, 10)
        elif k == 'canyon_ledge':
            lm = (np.abs(yy - (y - 4 + 0.15 * (xx - x))) < 1) & (np.abs(xx - x) < 14) & flat_ok & ~occ
            paint(lm, 'RK'); paint(lm & ((xx + yy) % 3 == 0), 'RH')
            got = int(lm.sum())
        elif k == 'stone_steps':
            got = 0
            for i in range(n):
                got += bool(near(x + i * 10, y + i * 3, STEPS, None, 8, 0))
        elif k == 'grey_boulders':
            got = cluster(x, y, [(STONE, None), (CRAG, None), (PEBBLE, None), (PEAK_S, None)], n + 2, 11)
        elif k == 'frost_patch':
            def fr_(e):
                paint(e & (BAY > 0.45), 'WL'); paint(e & (BAY > 0.80), 'WH')
            got = patch(x, y + 6, 10, 5, fr_, 153 + x)
            got += cluster(x, y + 6, [(STONE, FROSTSTONE), (PEBBLE, FROSTSTONE), (PINE, SNOWPINE)], n + 1, 10)
        elif k == 'pine':
            got = cluster(x, y, [(PINE, None), (PINE, SNOWPINE), (PINE, None)], n + 1, 10)
        elif k == 'reed_pool':
            shore = dil8(dil8(water)) & ~water & free & disk(x, y, 16)
            got = 0
            for _ in range(300):
                if got >= 5:
                    break
                xs = x + R.randint(-12, 12); ys = y + R.randint(-6, 6)
                if 0 <= xs < W and 0 <= ys < H and shore[ys, xs]:
                    got += try_place(xs, ys, R.choice([CATTAIL, REED, REED]), None, 0, where=free | shore)
        elif k == 'prayer_flags':
            after.append(('flags', x, y))
            got = 'after-roads'
        elif k == 'stone_cairn':
            got = near(x, y, CAIRN, None, 8, 0)
        elif k == 'wind_ripples':
            def rp_(e):
                ph = (xx * 0.5 + 2.2 * np.sin(yy / 3.0)) % 4
                paint(e & (np.abs(((yy + 0.4 * xx) % 4) - 1) < 0.5), 'S6')
                paint(e & (np.abs(((yy + 0.4 * xx) % 4) - 2) < 0.5) & (BAY > 0.3), 'SN')
            got = patch(x, y, 14, 7, rp_, 154 + x)
        elif k == 'stalactites':
            got = 0
            for i in range(n):
                cx_ = x - (n - 1) * 4 + i * 8 + R.randint(-1, 1)
                col = np.nonzero(F[:, cx_])[0]
                if len(col) == 0:
                    continue
                ty = col[0]
                ln = R.randint(4, 8)
                if keep_pad[ty:ty + ln + 1, cx_ - 1:cx_ + 2].any() or root_corr[ty:ty + ln + 1, cx_].any():
                    continue
                for j in range(ln):
                    put(cx_, ty + j, 'S6' if j < ln // 2 else 'S5')
                    if j < ln - 3:
                        put(cx_ + 1, ty + j, 'S5'); put(cx_ - 1, ty + j, 'K')
                put(cx_, ty + ln, 'K'); put(cx_ + 1, ty + ln - 2, 'K')
                got += 1
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # the two dry prints of the moving oasis: dead reed ring round darker damp sand
    for (x, y) in prints:
        e = ((xx - x) / 8.0) ** 2 + ((yy - y) / 3.5) ** 2
        ring = (e > 0.70) & (e <= 1.15) & flat_ok & ~occ
        damp = (e <= 0.70) & flat_ok & ~occ
        paint(damp & (BAY > 0.35), 'S6'); paint(damp & (BAY > 0.85), 'S5')
        paint(ring & ((xx * 3 + yy) % 4 == 0), 'MD'); paint(ring & ((xx * 3 + yy) % 4 == 2), 'MY')
        occ[damp | ring] = True

    # biome scatter
    zf = lambda z: free & (zone == z)
    nd = 0
    for _ in range(1600):  # crescent dunes on the erg and open sand
        if nd >= 18:
            break
        x = R.randrange(20, W - 20); y = R.randrange(24, H - 20)
        if zone[y, x] not in ('erg', 'base') or (zone[y, x] == 'base' and R.random() < 0.5):
            continue
        if dune(x, y, R.randint(7, 11), R.randint(3, 4)):
            nd += 1
    scatter([(CRAG, AMBER), (STONE, AMBER), (PEBBLE, AMBER), (BONES, None)], 14, zf('erg'), pad=1)
    scatter([(OLIVE_T, None), (LEMON_T, None), (STONE, None), (PEBBLE, REDROCK), (PEBBLE, None)], 14, zf('olive'), pad=1)
    scatter([(DRYGRASS, None), (THORN_B, None), (BUSH_D, None), (DRYGRASS, None), (STONE, SANDSTONE)], 26, zf('steppe'), pad=1)
    scatter([(TALLGRASS, None), (DRYGRASS, None), (BUSH, None), (TREE_S, JUNGLE_D)], 20, zf('savanna'), pad=0)
    scatter([(BIGTREE, JUNGLE_D), (TREE, JUNGLE), (TREE, JUNGLE_D), (TREE_S, JUNGLE_D), (BUSH, None), (BIGTREE, JUNGLE)], 40, zf('jungle'), pad=0)
    scatter([(MESA_S, None), (CRAG, REDROCK), (STONE, REDROCK), (PEBBLE, REDROCK)], 16, zf('canyon'), pad=1)
    scatter([(PEBBLE, REDROCK), (STONE, REDROCK)], 6, zf('canyonedge'), pad=1)
    scatter([(CRAG, None), (PEAK_S, None), (STONE, None), (PEBBLE, None), (PINE, None)], 30, zf('stone'), pad=0)
    scatter([(STONE, None), (PEBBLE, None), (PEBBLE, SANDSTONE)], 10, zf('stonesand'), pad=1)
    scatter([(PEBBLE, SANDSTONE), (STONE, SANDSTONE), (BONES, None), (DRYGRASS, None)], 14, zf('base'), pad=2)
    scatter([(PALM_Y, None), (DATEPALM, None)], 4, zf('market'), pad=2)
    # frost pixels on the north ledges of the Spicepeak horn
    fz = free & ~occ & (zone == 'stone') & (depth < 7) & (yy < 70)
    paint(fz & (vnoise(1, 160) > 0.80), 'WL'); paint(fz & (vnoise(1, 161) > 0.92), 'WH')
    # lemon flowers / green specks: every green thing a small event
    fl = free & ~occ & ~dil4(occ)
    paint(fl & (zone == 'jungle') & (vnoise(1, 85) > 0.94) & (vnoise(6, 86) > 0.5), 'PK')
    paint(fl & (zone == 'savanna') & (vnoise(1, 87) > 0.95), 'GD')

    # lanterns beside the trunks (a soft sand glow)
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
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water & ~occ
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'SN')
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
                    put(X, Y, 'S6')
    for px in roads:
        for (x, y) in px:
            for ox, oy in ((0, 2), (1, 2), (-1, 2), (2, 1), (-2, 1)):
                X, Y = x + ox, y + oy
                if 0 <= X < W and 0 <= Y < H and not road_m[Y, X] and F[Y, X]:
                    put(X, Y, 'S4')
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
    # exit tunnel mouths: a warm glow where the trunk leaves the floor, rock jambs, and each neighbour's weather
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
        if e['to'] == 'SE':  # Olivewhistle: red soil spilling in through the ceiling notch
            for j in range(12, 30):
                for ox in (-5, -4, 4, 5, 6):
                    X = ex + ox + (j % 2)
                    if F[j, X] and not keep_pad[j, X] and not road_m[j, X] and (X * 3 + j) % 3 != 0 and j < 12 + (8 - abs(ox)) * 2:
                        put(X, j, 'RE' if (X + j) % 2 else 'RK')
        elif e['to'] == 'WCA':  # Greatcanopy: leaves and a root hanging over the mouth
            for j in range(0, 9):
                for ox in range(-10, 11):
                    X, Y = ex + ox, H - 13 - j
                    if abs(ox) > 7 and F[Y, X] and not keep_pad[Y, X] and (X + Y) % 2 == 0 and j < 9 - abs(ox) // 3:
                        put(X, Y, 'GK' if (X + 2 * Y) % 3 else 'GM')
        elif e['to'] == 'CSA':  # Spicepeak: grey stone threshold
            for j in range(1, 12):
                for s in (-1, 1):
                    X, Y = W - 1 - j, ey + s * (5 + (j % 3 == 0))
                    if F[Y, X] and not keep_pad[Y, X] and not road_m[Y, X]:
                        put(X, Y, 'AL' if j % 2 else 'AS')

    # dressing that stands on (or by) a road: the Olivewhistle Seal gate, the prayer flags
    for (what, x, y) in after:
        if what == 'gate':
            # perpendicular to the road through (x, y): two seal pillars and a lintel across the trunk
            rd = min(roads, key=lambda px: min((a - x) ** 2 + (b - y) ** 2 for a, b in px))
            i = min(range(len(rd)), key=lambda q: (rd[q][0] - x) ** 2 + (rd[q][1] - y) ** 2)
            ax, ay = rd[max(0, i - 4)]; bx, by = rd[min(len(rd) - 1, i + 4)]
            L_ = math.hypot(bx - ax, by - ay) or 1
            px_, py_ = -(by - ay) / L_, (bx - ax) / L_
            cx_, cy_ = rd[i]
            tops = []
            for s in (-1, 1):
                X = int(round(cx_ + s * 6 * px_)); Y = int(round(cy_ + s * 6 * py_)) + 3
                spr(X, Y, SEALGATE)
                tops.append((X, Y - 6))
            (x0, y0), (x1, y1) = tops
            lin = raster([(x0, y0), (x1, y1)])
            for q in lin:
                put(q[0], q[1] - 1, 'K'); put(q[0], q[1] + 2, 'K')
            for q in lin:
                put(q[0], q[1], 'AL'); put(q[0], q[1] + 1, 'AS')
            mx, my = (x0 + x1) // 2, (y0 + y1) // 2
            put(mx, my, 'GD'); put(mx, my - 1, 'CR'); put(mx - 1, my, 'K'); put(mx + 1, my, 'K')
            log.append(('gate_drawn', cx_, cy_, tops))
        elif what == 'flags':
            p0 = (x - 9, y); p1 = (x + 9, y - 3)
            for (X, Y) in (p0, p1):
                for j in range(0, 8):
                    put(X, Y - j, 'S5' if j else 'K')
                put(X, Y - 8, 'K')
            fc = ['RD', 'GD', 'WA', 'WH', 'GM']
            for k2, q in enumerate(raster(bez((p0[0], p0[1] - 7), ((p0[0] + p1[0]) / 2, p0[1] - 2), (p1[0], p1[1] - 7)))):
                put(q[0], q[1], 'S6')
                if k2 % 2 == 1:
                    put(q[0], q[1] + 1, fc[(k2 // 2) % 5]); put(q[0], q[1] + 2, fc[(k2 // 2) % 5])

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
            X = max(0, min(W - 1, x))
            if keep_pad[min(y + 3, H - 1), X] or occ_water[min(y + 1, H - 1), X] or root_corr[min(y + 1, H - 1), X]:
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

    # hanging mycelium roots over the Market (plan prop hanging_roots)
    hr = [p for p in P['props'] if p['kind'] == 'hanging_roots']
    hx_ = hr[0]['x'] if hr else town['x']
    hn = 0
    for k, (dx, ln, th) in enumerate([(-24, 34, 3), (-8, 40, 3), (8, 36, 3), (24, 30, 2), (-38, 26, 2), (38, 24, 2),
                                      (-16, 30, 2), (16, 28, 2)]):
        for jig in (0, 2, -2, 4, -4):
            if root(hx_ + dx + jig, ln, th, SEED * 100 + 50 + k):
                hn += 1
                break
    log.append(('hanging_roots_drawn', hx_, 0, hn))
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
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'RH', 'u': 'T4', 'n': 't4'} if k % 2 else None)

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
    for sid, nm in ((206, 'SCARAB TOMB'), (204, 'OASIS THAT MOVES'), (205, 'ROSE-RED CANYON'), (202, 'HANGING GARDEN'), (208, None)):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-MENA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-MENA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-MENA.png'))
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
