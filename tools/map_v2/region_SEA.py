#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for SEA "The Monsoon Tangle" (band violet, Lv 45-55).

Lit floor style (the approved region-1 mockup: same palette, sprites, 5x7 font, glow), built on the
sibling map_v2 generators: dark strata and fog outside, the cavern floor (the plan polygon) lit from
inside with a dithered violet halo and a violet rim light (the Spicepeak mouth, the tier 4 door, takes
the orange of tier 4 for ~20 px), biome ground from the plan (paddy clay as the default floor, the hub
of stepped mirror-water rice paddies round the Market, dark tea steps toward Spicepeak, the Temple
Tangle with root-wrapped grey temple blocks, the Ember Isle cinder cone, the Lantern Festival River
falling out of the ceiling, bamboo, blossom, the Long Wall and the Dunewick sand spill in the north,
the darkest Old Tangle in the west pocket, the Klong Marsh with straight canals draining into the
monsoon sump, the Monsoon Grove, the Drowned Shore lagoon with a sand islet under every marker and
the black Dragonlizard islet, the pale Coralscatter sand with tide pools, moss stones, stone heads
and the jelly glow), four banyan root pillars (the Tangle), the Seed Bed (rice and sampaguita),
stilt houses, klong and lantern boats, the unlit oldest lamp, the Spicepeak Seal gate on the west
road, glowing road trunks on the layout polylines and the three exit tunnel mouths, a root ceiling
with stalactites and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout town / stops / exits and inside a
14-unit circle round every spread position of the plan there is a plain floor (one or two flat
tones, no sprites, no water, no texture).  The layout's keep circles of the off places are at their
old (pre-spread) positions and are not used: the spread circles replace them.

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_SEA.py [--layout layout-SEA.json] [--plan plan-SEA.json]
                                     [--out game/assets/img/scenes/map2-SEA.png] [--preview PREVIEW-2x.png]
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
CODE = 'SEA'
SEED = 55
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

# ---------------------------------------------------------------- shared sprites (from the EA generator)
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

# ---------------------------------------------------------------- SEA sprites (the Monsoon Tangle)
FIG_C = {'g': 'GK', 'G': 'GM', 'd': 't1'}
BANYAN = ['..kkkkkkk..',
          '.kdgGGggdk.',
          'kdgGGggggdk',
          'kgggggdgddk',
          '.kkdkbkdkk.',
          '..kbkBbkv..',
          '..kbkBbkv..',
          '..kBbkbBkv.',
          '..kBbkbBkv.',
          '..kbBkBbkv.',
          '..kbBkBbkv.',
          '..kBbkbBkv.',
          '.kbBkkBbbkv',
          'kbbk..kkbbk',
          'kk.......kk']
TEMPLE = ['....kk....',
          '...kAak...',
          '...kbak...',
          '..kAAa1k..',
          '..kbAa1k..',
          '.kAAbaa1k.',
          '.kAkkkk1k.',
          'kAAk11kabk',
          'kbAk11kaak',
          'kkkkkkkkkk']
TEMPLE_BLOCK = ['.kkkk.', 'kAAabk', 'kAbaak', 'kkkkkk']
CONE = ['.......khk.......',
        '......kReRk......',
        '.....kRRhRrk.....',
        '....kRRRRRrrk....',
        '....kRRyRRRrk....',
        '...kRRReRRRrrk...',
        '..kRRRRRyRRRrrk..',
        '.kRRRRRRRRRRRrrk.',
        'k2RRRRRRRRRRRRr2k',
        'kkkkkkkkkkkkkkkkk']
CONE_C = {'R': 'RK', 'r': 'S2', 'e': 'RE', 'h': 'RH', 'y': 'GD'}
MANGROVE = ['..kkkkk..',
            '.kGggddk.',
            'kGgggdddk',
            'kgggddddk',
            '.kkbkbkk.',
            '.kb.b.bk.',
            'kb..b..bk',
            'b...b...b']
STILT = ['...kk...',
         '..kSsk..',
         '.kSssSk.',
         'kSsssSSk',
         'kkbBBbkk',
         '.kbkkbk.',
         '.b....b.',
         '.b....b.']
STILT_C = {'S': 'SD', 's': 'SN'}
BOAT = ['..y..', 'kBbBk', '.kkk.']
BOAT_L = ['...y...', 'kBbbbBk', '.kkkkk.']
STONE_HEAD = ['.kkk.', 'kAAak', 'kkAkk', 'kAaak', '.kAk.', 'kAAak', 'kkkkk']
RIBS = ['.w..w..w.', 'wkw.Akw.A', 'k.k.k.k.k']
NEST = ['.bBbBb.', 'bBkWkBb', '.bbbbb.']
CRYST = ['..k..', '.kWk.', '.kvk.', 'kvvnk', 'kvnnk', 'kkkkk']
CRYST_C = {'v': 'T5', 'n': 't5', 'W': 'WH'}
TEA = ['.kkk.', 'kGgdk', 'kkkkk']
TEA_C = {'g': 'GK', 'G': 'GM', 'd': 't1'}
POST = ['.k.', 'kok', 'kAk', 'kak', 'kAk', 'kak', 'kkk']
CAVE = ['..kkkkk..', '.k23332k.', 'k2311132k', 'k3111113k', 'k3111113k']
CAVE_C = {'1': 'S0', '2': 'S4', '3': 'S2'}

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
    zone = np.full((H, W), 'base', dtype=object)   # paddy clay is the default floor
    zmask = {}
    KEY = {'paddy_terraces': 'hub', 'spicepeak_breath_tea': 'tea', 'temple_tangle': 'temple',
           'ember_isle': 'ember', 'lantern_river': 'riverz', 'blossomreach_breath': 'blossom',
           'old_tangle': 'old', 'klong_marsh': 'marsh', 'monsoon_grove': 'grove',
           'drowned_shore': 'shore', 'coralscatter_breath': 'coral'}
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        if b['shape'] == 'polygon':
            s = blur(poly_mask(b['points']).astype(float), 3)
            m = s + 0.5 * (n - 0.5) > 0.5
        else:
            e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
            m = e + 0.35 * (n - 0.5) < 1
        k = KEY.get(b['type'])
        if k:
            zmask.setdefault(k, np.zeros((H, W), bool))
            zmask[k] |= m
    # the Dunewick sand spill in the north-east corner, round the two dunes
    zmask['sand'] = np.hypot((xx - 400) / 30.0, (yy - 54) / 21.0) + 0.4 * (vnoise(6, 140) - 0.5) < 1
    for k in ('tea', 'old', 'coral', 'hub', 'sand', 'grove', 'blossom'):
        if k in zmask:
            cs = blur(zmask[k].astype(float), 4)
            zmask[k] = cs > 0.25 + 0.5 * BAY
    for key in ['tea', 'old', 'marsh', 'grove', 'coral', 'blossom', 'sand', 'temple', 'hub', 'ember', 'shore']:
        if key in zmask:
            zone[zmask[key] & F] = key
    # one ground per plain disc: the zone at its centre (no zone seam through a marker)
    for (_, x, y, r) in sorted(keeps, key=lambda t: t[3]):
        if 0 <= x < W and 0 <= y < H:
            zone[disk(x, y, r) & F] = zone[min(H - 1, max(0, y)), min(W - 1, max(0, x))]

    RAMPS = {
        'base': ['S3', 't1', 'GK', 'GM'], 'hub': ['t1', 'GK', 'GM', 'GM'], 'tea': ['S3', 't1', 'GK', 'GM'],
        'temple': ['S3', 't1', 't1', 'GK'], 'ember': ['S3', 'S4', 'S5', 'S6'], 'blossom': ['t1', 'GK', 'GK', 'GM'],
        'sand': ['S6', 'SD', 'SN', 'SN'], 'old': ['S1', 'S2', 't1', 'GK'], 'marsh': ['S3', 't1', 'GK', 'GM'],
        'grove': ['S2', 't1', 't1', 'GK'], 'shore': ['S6', 'SD', 'SN', 'SN'], 'coral': ['S6', 'SD', 'SN', 'SN'],
    }
    BIAS = {'base': 0.0, 'hub': 0.10, 'tea': -0.02, 'temple': -0.04, 'ember': 0.0, 'blossom': 0.04,
            'sand': 0.06, 'old': -0.05, 'marsh': 0.0, 'grove': -0.04, 'shore': 0.08, 'coral': 0.06}


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
    # paddy hub: a warped grid of fields; mirror-water cells (WA, WL glints, single GM shoots), green rice
    # cells, and a few dry clay cells; D2 shadow under each dike, lit T1 / S4 dikes
    hz = busyok & (zone == 'hub') & ~near_road
    gx_ = xx + np.round(2.0 * np.sin(yy / 13.0)).astype(int)
    gy_ = yy + np.round(2.0 * np.sin(xx / 17.0) + 3 * vnoise(14, 301)).astype(int)
    CW, CH = 12, 8
    cxm = gx_ % CW; cym = gy_ % CH
    ccx = np.clip((gx_ // CW) * CW + CW // 2, 0, W - 1); ccy = np.clip((gy_ // CH) * CH + CH // 2, 0, H - 1)
    nv = vnoise(9, 302)[ccy, ccx]
    nv2 = vnoise(5, 303)[ccy, ccx]
    paddy = hz & (nv > 0.30)
    mirror = paddy & (nv2 > 0.42)
    green = paddy & ~mirror
    dike = (cxm == 0) | (cym == 0)
    body = ~dike
    paint(paddy & (cym == 0), 'T1'); paint(paddy & (cxm == 0) & (cym != 0), 'S4')
    paint(mirror & body, 'WA')
    paint(mirror & body & (cym == 1), 'D2')
    paint(mirror & body & (cym > 1) & ((xx * 3 + yy * 5) % 11 == 0), 'WL')
    paint(mirror & body & (cym > 1) & (xx % 3 == 1) & (yy % 2 == 0) & ((xx + yy) % 4 != 0), 'GM')
    paint(green & body, 'GM')
    paint(green & body & (cym == 1), 't1')
    paint(green & body & (cym > 1) & (yy % 2 == 0) & ((xx + yy // 2) % 3 == 0), 'T1')
    paint(green & body & (cym > 1) & ((xx * 5 + yy * 3) % 13 == 0), 'WA')
    # tea steps: rows of round bushes with a dark furrow, contours bent by noise
    tz = busyok & (zone == 'tea') & ~near_road & (vnoise(5, 304) > 0.28)
    toff = np.round(2.5 * np.sin(xx / 19.0) + 4 * vnoise(18, 305)).astype(int)
    tp = (yy + toff) % 5
    paint(tz & (tp == 0), 'S2')
    paint(tz & (tp == 1), 'GK'); paint(tz & (tp == 2), 'GK')
    paint(tz & (tp == 1) & ((xx + (yy + toff) // 5 * 2) % 4 < 2), 'GM')
    paint(tz & (tp == 3) & ((xx + (yy + toff) // 5 * 2) % 4 == 0), 't1')
    # temple tangle: rainforest floor, strangler roots in S4 curls
    mz = busyok & (zone == 'temple')
    paint(mz & (vnoise(1, 306) > 0.75) & ((xx + yy) % 2 == 0), 'GK')
    curl = mz & (np.abs(np.sin((xx * 0.7 - yy * 0.6 + 9 * vnoise(5, 307)) / 2.2)) < 0.09) & (vnoise(3, 308) > 0.5)
    paint(curl, 'S4')
    # ember isle: cinder floor with a few red embers (red only here and at the lair)
    ez = busyok & (zone == 'ember')
    paint(ez & (vnoise(1, 309) > 0.80) & ((xx + yy) % 2 == 0), 'S4')
    paint(ez & (vnoise(1, 310) > 0.975), 'RE')
    paint(ez & (vnoise(3, 336) > 0.70) & ((xx + yy) % 3 == 0), 'GK')    # moss creeping back over the ash
    flow = ez & (np.abs(np.sin((xx * 0.4 + yy + 6 * vnoise(6, 337)) / 2.6)) < 0.10)
    paint(flow, 'S1')
    # blossom: pink petals and green tufts
    pz = busyok & (zone == 'blossom')
    paint(pz & (vnoise(1, 311) > 0.88) & (vnoise(9, 312) > 0.40), 'PL')
    paint(pz & (vnoise(1, 313) > 0.94), 'PK')
    paint(pz & (vnoise(1, 314) > 0.88) & ((xx + yy) % 2 == 0), 'GM')
    # sand spill: ripples
    sz_ = busyok & (zone == 'sand')
    rip = np.abs(np.sin((yy * 1.3 + 3 * np.sin(xx / 9.0) + 5 * vnoise(8, 315)) / 1.6)) > 0.96
    paint(sz_ & rip, 'SD'); paint(sz_ & (vnoise(1, 316) > 0.96), 'CR')
    # old tangle: the darkest forest floor, leaf litter and a few firefly sparks
    oz = busyok & (zone == 'old')
    paint(oz & (vnoise(1, 317) > 0.70) & ((xx + yy) % 2 == 0), 'GK')
    paint(oz & (vnoise(2, 318) > 0.80) & ((xx + yy) % 2 == 1), 'S2')
    paint(oz & (vnoise(1, 319) > 0.992), 'NW')
    # klong marsh: reed strokes and wet glints
    kz = busyok & (zone == 'marsh')
    reed = kz & (xx % 3 == 0) & (vnoise(2, 320) > 0.62)
    paint(reed & (yy % 3 != 0), 'GM'); paint(reed & (yy % 3 == 0), 'T1')
    paint(kz & (vnoise(3, 321) > 0.80) & ((xx + yy) % 2 == 0) & ~reed, 't2')
    # monsoon grove: wet green floor with vines and drips
    gz = busyok & (zone == 'grove')
    paint(gz & (vnoise(1, 322) > 0.72) & ((xx + yy) % 3 == 0), 'GK')
    paint(gz & (vnoise(1, 323) > 0.90) & ((xx + yy) % 2 == 0), 'GM')
    vine = gz & (np.abs(np.sin((xx * 0.8 + yy * 0.5 + 9 * vnoise(6, 324)) / 2.0)) < 0.10) & (vnoise(3, 325) > 0.5)
    paint(vine, 'GK'); paint(gz & (vnoise(1, 326) > 0.985), 'WL')
    # coral sand: ripples, coral crumbs, shells
    cz = busyok & (zone == 'coral')
    rip = np.abs(np.sin((yy * 1.1 + 4 * np.sin(xx / 11.0) + 5 * vnoise(8, 327)) / 1.5)) > 0.965
    paint(cz & rip, 'SD')
    paint(cz & (vnoise(1, 328) > 0.965) & (vnoise(7, 329) > 0.45), 'PK')
    paint(cz & (vnoise(1, 330) > 0.975), 'WH')
    paint(cz & (vnoise(4, 331) > 0.78) & ((xx + yy) % 3 == 0), 'GK')   # damp moss
    # shore bank: wet sand ripples
    hz2 = busyok & (zone == 'shore')
    rip = np.abs(np.sin((yy * 1.2 + 3 * np.sin(xx / 8.0) + 5 * vnoise(8, 332)) / 1.5)) > 0.96
    paint(hz2 & rip, 'SD')
    # base paddy clay: bare wet patches and tufts
    bz = busyok & (zone == 'base')
    paint(bz & (vnoise(4, 333) > 0.78) & ((xx + yy) % 4 == 0), 'S4')
    paint(bz & (vnoise(1, 334) > 0.94), 'T1')
    paint(bz & (vnoise(1, 335) > 0.988), 'WL')

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

    # ------------------------------------------------ 4. WATERS: lagoon, Lantern River, klongs, sump, pools
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on dry ground (the lagoon places get a sand islet)
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2.5 * isl
    band = pixmask(road_px, 5)
    props_by = {}
    for p in P['props']:
        props_by.setdefault(p['kind'], []).append(p)
    # the Dragonlizard islet: black volcanic rock round the lair disc (the disc itself stays plain)
    lair_isle = np.zeros((H, W), bool)
    for sid, (x, y) in spread.items():
        if slots.get(sid, {}).get('kind') == 'lair' and zone[y, x] == 'shore':
            dd_ = np.hypot(xx - x, yy - y) + 1.5 * (vnoise(3, 341) - 0.5)
            lair_isle |= (dd_ <= 19) & (dd_ > 14.5) & F
            pd_ = disk(x, y, 14) & F
            paint(pd_, 'D3'); paint(pd_ & (BAY > 0.70), 'D4')
    paint(lair_isle, 'D3')
    paint(lair_isle & (vnoise(1, 342) > 0.6), 'D2')
    crk = lair_isle & (np.abs(np.sin((xx * 0.9 + yy * 0.4 + 6 * vnoise(3, 343)) / 1.7)) < 0.12)
    paint(crk, 'RE')
    # lagoon: the drowned shore less a bank strip along its edge
    sz = zmask.get('shore', np.zeros((H, W), bool)) & F
    lag = sz.copy()
    for _ in range(4):
        lag = ero4(lag)
    lag &= (depth > 3) & ~keep_wet & ~band & ~grow(lair_isle, 1)
    lag = ero4(dil4(lag)) & ~keep_wet & ~band & ~grow(lair_isle, 1) & F
    # the Lantern Festival River: from the ceiling falls to a pool before the north road
    fall = props_by.get('ceiling_waterfall', [{'x': 184, 'y': 30}])[0]
    fx0, fy0 = fall['x'], fall['y']
    river_line = raster([(fx0, fy0), (fx0 + 4, fy0 + 12), (fx0 + 14, fy0 + 22), (fx0 + 24, fy0 + 32),
                         (fx0 + 38, fy0 + 38), (fx0 + 52, fy0 + 37)])
    river = pixmask(river_line, 1) | pixmask(river_line[:len(river_line) // 4], 2)
    ex_, ey_ = river_line[-1]
    river |= np.hypot((xx - ex_ - 2) / 7.0, (yy - ey_) / 4.0) < 1
    river |= np.hypot((xx - fx0) / 5.0, (yy - fy0 - 1) / 3.0) < 1     # plunge pool
    # klongs: straight canals draining west into the monsoon sump
    sump = props_by.get('monsoon_sump', [{'x': 92, 'y': 186}])[0]
    sx, sy = sump['x'], sump['y']
    klong_lines = [raster([(216, 207), (sx + 6, sy + 2)]), raster([(154, 150), (134, 230)]),
                   raster([(205, 238), (150, 222)])]
    klong = grow(pixmask([p for kl in klong_lines for p in kl], 0), 1)
    klong &= zmask.get('marsh', np.ones((H, W), bool)) | (np.hypot(xx - sx, yy - sy) < 16)
    sumpm = np.hypot((xx - sx) / 10.0, (yy - sy) / 6.5) + 0.25 * (vnoise(3, 344) - 0.5) < 1
    # reed pool by the west road
    rp = props_by.get('reed_pool', [])
    reedpool = np.zeros((H, W), bool)
    for p in rp:
        reedpool |= np.hypot((xx - p['x']) / 7.0, (yy - p['y']) / 3.5) + 0.3 * (vnoise(2, 345) - 0.5) < 1
    wet_ok = F & ~keep_wet & ~band
    river &= wet_ok; klong &= wet_ok; sumpm &= wet_ok & (depth > 1); reedpool &= wet_ok
    occ_water = lag | river | klong | sumpm | reedpool
    # lagoon: WL shallows on the bank side, WA body, t2 deep dither, glints, coral heads
    shl = dil8(lag) & ~lag & F & ~keep_m & ~lair_isle
    paint(shl, 'SD')
    paint(lag, 'WA')
    deep = ero4(ero4(ero4(lag)))
    paint(deep & (vnoise(5, 346) > 0.45) & (BAY > 0.40), 't2')
    paint(lag & ~ero4(lag), 'WL')
    paint(lag & ero4(lag) & ~deep & ((xx + yy) % 2 == 0) & (BAY > 0.5), 'WL')
    paint(deep & (yy % 4 == 0) & ((xx + yy // 4) % 7 == 0), 'WL')
    # river, klongs, reed pool: WA with WL glints, an S4 / D2 bank
    small = river | klong | reedpool
    paint(dil8(small) & ~small & F & ~keep_m & ~lag, 'S4')
    paint(small, 'WA')
    paint(small & ero4(small) & ((xx + 2 * yy) % 6 == 0), 'WL')
    paint(klong & ~ero4(klong) & (yy % 2 == 0), 't2')
    paint(river & (np.hypot((xx - fx0) / 5.0, (yy - fy0 - 1) / 3.0) < 1) & ((xx + yy) % 2 == 0), 'WH')
    # the monsoon sump: a dark drain hole at the cut south-west wall
    paint(dil8(sumpm) & ~sumpm & F & ~keep_m, 'S2')
    paint(sumpm, 't2'); paint(sumpm & ero4(sumpm), 'D2'); paint(sumpm & ero4(ero4(sumpm)), 'D1')
    paint(sumpm & ~ero4(sumpm) & (yy < sy) & ((xx + yy) % 2 == 0), 'WA')

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
    pillar_at = []
    FIRST = ('seed_bed_rice_sampaguita', 'sand_dune', 'tide_pool', 'jelly_glow', 'rice_paddy', 'volcano_cone')
    for p in sorted(P['props'], key=lambda q: q['kind'] not in FIRST):
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        got = None
        if k == 'seed_bed_rice_sampaguita':
            b = find_box(x, y, 15, 9, soft, 14)
            if b:
                bx, by = b
                bm = (np.abs(xx - bx) <= 6) & (np.abs(yy - by) <= 3)
                paint(bm, 'S4')
                paint(bm & (yy % 2 == 0), 'GM'); paint(bm & (yy % 2 == 0) & (xx % 2 == 0), 'T1')
                ring = bm & ~ero4(bm)
                paint(ring, 'S5'); paint(ring & ((xx + yy) % 2 == 0), 'WH')   # sampaguita border
                occ[by - 4:by + 5, bx - 7:bx + 8] = True
                lamp_glows.append((bx, by, 9, 'CR'))
                got = (bx, by)
        elif k == 'oldest_lamp':
            # the oldest lamp: an unlit dark post (it lights at the "last lamp" beat, in code)
            got = near(x, y, ['.k.', 'k2k', 'k1k', '.k.', '.2.', '.2.', 'k2k'], None, 8, 0, where=soft)
        elif k == 'banyan_root_pillar':
            got = near(x, y, BANYAN, FIG_C, 12, 0, where=hard)
            if got:
                pillar_at.append(got)
                for (dx, dy) in ((-7, 0), (7, 1), (-9, -2), (9, -3)):   # aerial prop roots round the foot
                    X, Y = got[0] + dx, got[1] + dy
                    if flat[Y - 4:Y + 1, X].all() and not occ[Y - 4:Y + 1, X].any():
                        for j in range(4):
                            put(X, Y - j, 'S5' if j % 2 else 'S4')
                        put(X, Y - 4, 'K')
        elif k == 'volcano_cone':
            got = near(x, y, CONE, CONE_C, 10, 1, where=soft)
            if got:
                lamp_glows.append((got[0], got[1] - 9, 9, 'RE'))
                for (dx, dy) in ((11, 0), (13, -2), (15, 1)):   # spice dots on the east flank
                    X, Y = got[0] + dx, got[1] + dy
                    if soft[Y, X] and not occ[Y, X]:
                        put(X, Y, 'GD'); put(X, Y + 1, 'S2')
        elif k == 'temple_roots':
            got = 0
            q = near(x, y, TEMPLE, GREY, 12, 0, where=hard)
            if q:
                got += 1
                for (dx, dy) in ((-10, 2), (9, 3), (-4, 7), (12, -4))[:n + 1]:
                    got += bool(try_place(q[0] + dx, q[1] + dy, TEMPLE_BLOCK, GREY, 0, where=soft))
        elif k == 'tea_rows':
            got = 0
            for i in range(n * 4):
                got += bool(try_place(x - 12 + (i % 4) * 7 + (i // 4 % 2) * 3, y - 4 + (i // 4) * 5, TEA, TEA_C, 0, where=soft))
        elif k == 'lantern_boats':
            got = 0
            cand = [(X, Y) for (X, Y) in river_line if abs(X - x) + abs(Y - y) <= 16 and river[Y, X]]
            for (X, Y) in cand[::max(1, len(cand) // max(1, n))][:n]:
                put(X, Y, 'GD'); put(X, Y + 1, 't3'); put(X - 1, Y + 1, 'K'); put(X + 1, Y + 1, 'K')
                lamp_glows.append((X, Y, 4, 'GD'))
                got += 1
        elif k == 'long_wall_segment':
            got = 0
            okw = F & ~keep_pad & ~near_road & ~dil4(occ_water)
            for X in range(x - 10, x + 11):
                Y = y + int(round(1.5 * math.sin(X / 7.0)))
                if not okw[Y - 2:Y + 3, X].all() or occ[Y - 2:Y + 3, X].any():
                    continue
                put(X, Y - 2, 'AL' if X % 3 else 'K')
                put(X, Y - 1, 'AL'); put(X, Y, 'AS'); put(X, Y + 1, 'K'); put(X, Y + 2, 'S3')
                occ[Y - 3:Y + 3, X] = True
                got += 1
            if got > 12:
                q = near(x - 6, y + 1, WATCHTOWER, {'r': 'S6', 'h': 'AL'}, 4, 0, where=okw)
        elif k == 'bamboo':
            got = cluster(x, y, [(BAMBOO, BAMBOO_C), (BAMBOO_S, BAMBOO_C)], n + 2, 10, 0, where=hard)
        elif k == 'sand_dune':
            got = 0
            for i in range(n):
                b = find_box(x + i * 14 - 7 * (n - 1), y + (i % 2) * 6, 24, 9, flat & ~root_corr, 14)
                if not b:
                    continue
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
                got += 1
        elif k == 'firefly_dots':
            got = 0
            for (dx, dy) in [(0, 0), (6, -4), (-7, -2), (3, 5), (-4, 6), (9, 3), (-10, 4)][:n + 1]:
                X, Y = x + dx, y + dy
                if flat[Y - 1:Y + 2, X - 1:X + 2].all() and not occ[Y, X]:
                    put(X, Y, 'NW')
                    if (dx + dy) % 2 == 0:
                        put(X + 1, Y, 'ND')
                    got += 1
        elif k == 'delve_cave_mouth':
            got = 'near layer'
        elif k == 'klong_boats':
            got = 0
            cand = [(X, Y) for kl in klong_lines for (X, Y) in kl
                    if abs(X - x) + abs(Y - y) <= 18 and klong[Y, X] and klong[Y, X - 2] and klong[Y, X + 2] and not occ[Y, X]]
            for (X, Y) in cand[::max(1, len(cand) // max(1, n))][:n]:
                spr(X, Y + 1, BOAT)
                occ[Y - 2:Y + 2, X - 3:X + 4] = True
                lamp_glows.append((X, Y - 1, 4, 'GD'))
                got += 1
        elif k in ('reed_pool', 'monsoon_sump'):
            got = 'water'
            if k == 'reed_pool':
                got = cluster(x, y, [(REED, None), (CATTAIL, None)], 5, 10, 0, where=soft & dil8(dil8(reedpool)))
        elif k == 'canopy_tree':
            got = cluster(x, y, [(GIANT, OLD_C), (BIGTREE, OLD_C)], n, 12, 0, where=hard)
        elif k == 'old_man_nest':
            got = near(x, y, BIGTREE, OLD_C, 10, 0, where=hard)
            if got:
                spr(got[0], got[1] - 9, NEST)
        elif k == 'stilt_house':
            got = 0
            for i in range(n):
                got += bool(near(x - 6 + i * 13, y + (i % 2) * 4, STILT, STILT_C, 10, 0, where=soft))
        elif k == 'rice_paddy':
            got = 0
            for i in range(n):
                b = find_box(x - 7 + i * 14, y, 11, 6, flat & ~root_corr & (zone != 'hub'), 10)
                if b:
                    bx, by = b
                    bm = (np.abs(xx - bx) <= 5) & (np.abs(yy - by) <= 2)
                    paint(bm, 'WA'); paint(bm & (yy == by - 2), 'D2')
                    paint(bm & (xx % 3 == 1) & (yy % 2 == 0), 'GM')
                    paint(dil4(bm) & ~bm & flat, 'S4'); paint(dil4(bm) & ~bm & flat & (yy < by), 'T1')
                    occ[by - 3:by + 4, bx - 6:bx + 7] = True
                    got += 1
                else:
                    got = got or 'in paddy hub'
        elif k == 'sandpiper_flock':
            got = 0
            for (dx, dy) in [(0, 0), (4, -2), (-4, 1), (7, 2), (-7, -1)]:
                X, Y = x + dx, y + dy
                if flat[Y - 1:Y + 2, X - 1:X + 2].all() and not occ[Y - 1:Y + 2, X].any():
                    put(X, Y, 'WH'); put(X + 1, Y, 'S6'); put(X, Y + 1, 'K')
                    got += 1
        elif k == 'rope_bridge':
            got = None
            # a plank-and-rope walk over the nearest lagoon inlet; otherwise a short boardwalk on the bank
            for dy in sorted(range(-10, 11), key=abs):
                Y = y + dy
                xs_ = [X for X in range(x - 6, x + 40) if lag[Y, X]]
                if len(xs_) >= 6 and not keep_pad[Y - 2:Y + 2, xs_[0] - 3:xs_[0] + 8].any():
                    X0 = xs_[0] - 3
                    for X in range(X0, X0 + 11):
                        put(X, Y - 1, 'S6' if X % 3 else 'K'); put(X, Y, 'S5' if X % 2 else 'S6'); put(X, Y + 1, 'K')
                    got = (X0, Y)
                    break
            if not got:
                b = find_box(x, y, 11, 3, soft, 10)
                if b:
                    bx, by = b
                    for X in range(bx - 5, bx + 6):
                        put(X, by - 1, 'S6' if X % 3 else 'K'); put(X, by, 'S5' if X % 2 else 'S6'); put(X, by + 1, 'K')
                    occ[by - 2:by + 3, bx - 6:bx + 7] = True
                    got = b
        elif k == 'mangrove':
            got = 0
            for i in range(n):
                q = near(x + (i - 1) * 6, y + (i - 1) * 8, MANGROVE, OLD_C, 12, 0,
                         where=F & ~keep_pad & ~near_road & ~root_corr & ~place18)
                got += bool(q)
        elif k == 'dragon_bones':
            got = None
            for dy in sorted(range(-10, 11), key=abs):
                for dx in sorted(range(-12, 13), key=abs):
                    X, Y = x + dx, y + dy
                    if box_ok(lag | (F & soft), X - 5, Y - 3, X + 5, Y + 1):
                        spr(X, Y, RIBS, {'w': 'WH', 'A': 'AL'})
                        occ[Y - 3:Y + 2, X - 5:X + 6] = True
                        got = (X, Y); break
                if got:
                    break
        elif k == 'coral_head':
            got = 0
            for (dx, dy) in [(0, 0), (6, 3), (-5, 4), (3, -5), (-8, -2), (9, -3)][:n + 3]:
                X, Y = x + dx, y + dy
                if lag[Y - 1:Y + 2, X - 1:X + 2].all():
                    put(X, Y, 'PK'); put(X + 1, Y, 'PL'); put(X, Y + 1, 'S5'); put(X - 1, Y, 'PK' if dx % 2 else 'SN')
                    got += 1
        elif k == 'stone_head':
            got = 0
            for i in range(n):
                got += bool(near(x - 6 + i * 11, y + (i % 2) * 2, STONE_HEAD, GREY, 8, 0, where=soft))
        elif k in ('tide_pool', 'jelly_glow'):
            got = None
            for dy in sorted(range(-8, 12), key=abs):
                for dx in sorted(range(-14, 15), key=abs):
                    cx_, cy_ = x + dx, y + dy
                    if box_ok(soft & ~place18, cx_ - 7, cy_ - 4, cx_ + 7, cy_ + 3):
                        pm = np.hypot((xx - cx_) / 5.5, (yy - cy_) / 2.6) + 0.2 * (vnoise(2, 350 + x) - 0.5) < 1
                        paint(dil8(pm) & ~pm, 'SD' if k == 'tide_pool' else 'S4')
                        paint(pm, 'WA'); paint(pm & ~ero4(pm), 't2' if k == 'jelly_glow' else 'WL')
                        if k == 'tide_pool':
                            put(cx_ - 2, cy_, 'PK'); put(cx_ + 2, cy_ + 1, 'PL'); put(cx_ + 1, cy_ - 1, 'WL')
                        else:
                            for (ox, oy) in ((-2, 0), (2, 1), (0, -1)):
                                put(cx_ + ox, cy_ + oy, 'T5'); put(cx_ + ox, cy_ + oy + 1, 'PL')
                            lamp_glows.append((cx_, cy_, 10, 'T5'))
                        occ[cy_ - 5:cy_ + 5, cx_ - 9:cx_ + 9] = True
                        occ_water |= pm
                        got = (cx_, cy_)
                        break
                if got:
                    break
        elif k == 'toadstool_ring':
            got = 0
            for (dx, dy) in [(0, 0), (-7, 2), (7, 2), (-4, -4), (4, -4)][:n + 1]:
                got += bool(try_place(x + dx, y + dy, SHROOM_S, {'r': 'T5', 'w': 'PL'} if dx % 2 else None, 0, where=soft))
        elif k == 'moss_stones':
            got = cluster(x, y, [(STONE, {'A': 'GM', 'a': 'AS', '1': 'GK'}), (PEBBLE, {'A': 'GM', 'a': 'AS'}),
                                 (CRAG, {'A': 'GM', 'a': 'AS', '1': 'S3'})], n + 1, 9, 0, where=soft)
        elif k in ('hanging_roots', 'ceiling_waterfall', 'violet_crystal', 'gate_spicepeak_seal'):
            got = 'near layer'
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter: low near the roads so the trunks read
    zf = lambda z: free & (zone == z) & ~occ_water
    far_road = ~pixmask(road_px, 9)
    scatter([(TEA, TEA_C), (BUSH, OLD_C)], 26, zf('tea') & far_road, pad=0, tries=4000)
    scatter([(TREE, OLD_C), (BIGLEAF, BIGLEAF_C), (FERN, OLD_C), (TEMPLE_BLOCK, GREY)], 14, zf('temple') & far_road, pad=0, tries=3000)
    scatter([(GIANT, OLD_C), (BIGTREE, OLD_C), (TREE, OLD_C), (FERN, OLD_C)], 18, zf('old') & far_road, pad=0, tries=5000)
    scatter([(FERN_S, OLD_C), (BIGLEAF, BIGLEAF_C)], 10, zf('old'), pad=0)
    scatter([(REED, None), (CATTAIL, None), (REED, None)], 40, zf('marsh'), pad=0, tries=5000)
    scatter([(BIGTREE, FIG_C), (TREE, FIG_C), (BIGLEAF, BIGLEAF_C)], 12, zf('grove') & far_road, pad=0, tries=4000)
    scatter([(TREE_S, FIG_C), (BIGLEAF, BIGLEAF_C), (FERN, BIGLEAF_C), (FERN_S, BIGLEAF_C)], 22, zf('grove'), pad=0, tries=4000)
    scatter([(BAMBOO, BAMBOO_C), (BAMBOO_S, BAMBOO_C), (TREE, CHERRY_C), (TREE_S, CHERRY_C)], 26, zf('blossom') & far_road, pad=0, tries=5000)
    scatter([(PEBBLE, GRAVEL), (STONE, GRAVEL)], 6, zf('sand'), pad=1)
    scatter([(STONE, {'A': 'GM', 'a': 'AS', '1': 'GK'}), (PEBBLE, GREY), (SHROOM_S, None)], 12, zf('coral') & far_road, pad=1)
    scatter([(BUSH, OLD_C), (BIGLEAF, BIGLEAF_C), (TREE_S, OLD_C), (TREE, FIG_C)], 30, zf('base') & far_road, pad=1, tries=5000)
    scatter([(FERN_S, OLD_C), (REED, None)], 16, zf('base'), pad=1)
    scatter([(MANGROVE, OLD_C)], 6, zf('shore') & dil8(dil8(lag)) & far_road, pad=0, tries=3000)
    scatter([(REED, None), (CATTAIL, None)], 18, dil8(dil8(klong | river | reedpool)) & ~occ_water & free, pad=0)
    scatter([(PEBBLE, {'A': 'D4', 'a': 'D3', '1': 'D2'})], 6, zf('ember'), pad=1)

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

    # the Spicepeak Seal: two orange-capped stone posts astride the west road and a lintel over it
    # (the only prop on a road; the way in from tier 4)
    for p in props_by.get('gate_spicepeak_seal', []):
        best = None
        for px in roads:
            for i, (X, Y) in enumerate(px):
                d = (X - p['x']) ** 2 + (Y - p['y']) ** 2
                if best is None or d < best[0]:
                    best = (d, px, i)
        _, px, i = best
        (ax, ay), (bx_, by_) = px[max(0, i - 4)], px[min(len(px) - 1, i + 4)]
        L_ = math.hypot(bx_ - ax, by_ - ay) or 1
        nx, ny = -(by_ - ay) / L_, (bx_ - ax) / L_
        cx_, cy_ = px[i]
        feet = []
        for s in (-1, 1):
            X, Y = int(round(cx_ + s * 6 * nx)), int(round(cy_ + s * 6 * ny))
            feet.append((X, Y))
        for (X, Y) in feet:
            spr(X, Y, POST)
            lamp_glows_g = disk(X, Y - 6, 5) & F & ~road_m & ~keep_m
            paint(lamp_glows_g & (BAY > 0.72) & ((xx + yy) % 2 == 0), 't4')
        (x0_, y0_), (x1_, y1_) = feet
        for (X, Y) in raster([(x0_, y0_ - 6), (x1_, y1_ - 6)]):
            put(X, Y - 1, 'K'); put(X, Y, 'T4'); put(X, Y + 1, 't4')
        mx_, my_ = (x0_ + x1_) // 2, (y0_ + y1_) // 2 - 6
        put(mx_, my_, 'GD'); put(mx_, my_ - 1, 'K')

    # ------------------------------------------------ 7. NEAR LAYER: root ceiling, stalactites, stalagmites
    keep = keep_m | pixmask(road_px, 4)
    falls_band = (np.abs(xx - fx0) <= 6) & (yy < fy0 + 6)
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


    # the Monsoon: a waterfall out of the root ceiling into the head of the Lantern Festival River
    for Y in range(0, fy0 + 1):
        wob = int(round(0.8 * math.sin(Y / 3.0)))
        X = fx0 - 1 + wob
        put(X - 1, Y, 'K'); put(X + 3, Y, 'K')
        put(X, Y, 'WL'); put(X + 1, Y, 'WH' if (Y // 2) % 3 == 0 else 'WL'); put(X + 2, Y, 'WA')
    for (ox, oy) in ((-3, -1), (4, -2), (-4, 2), (5, 1), (-6, -4), (6, -5), (-2, -6), (3, -7)):
        put(fx0 + ox, fy0 + oy, 'WH')
    for (ox, oy) in ((-7, 1), (7, 3)):
        put(fx0 + ox, fy0 + oy, 'AL')

    # violet crystals in the wall (dressing, may sit on the rim)
    for p in props_by.get('violet_crystal', []):
        for i in range(p.get('n', 1)):
            X, Y = p['x'] + (i * 7 - 3), p['y'] + (i % 2) * 5
            if not keep_m[Y - 6:Y + 1, X - 3:X + 3].any() and not road_m[Y - 6:Y + 1, X - 3:X + 3].any():
                spr(X, Y, CRYST, CRYST_C)

    # the Firefly Caves mouth in the south wall (a delve)
    for p in props_by.get('delve_cave_mouth', []):
        X, Y = p['x'], p['y']
        if not keep_m[Y - 5:Y + 1, X - 5:X + 5].any():
            spr(X, Y, CAVE, CAVE_C)
            for (ox, oy) in ((-3, -6), (2, -7), (5, -4)):
                put(X + ox, Y + oy, 'NW')

    # mouths: Spicepeak (stone and tea steps, orange rim), Blossomreach (bamboo and petals on the lip),
    # the Coralscatter (coral sand spills in)
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['side'] == 'W':
            for s in (-1, 1):
                for j in range(0, 12):
                    Y = ey + s * (6 + j // 3); X = j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'AL' if j % 3 else 'AS'); put(X, Y + s, 'K')
        elif e['side'] == 'N':
            for s in (-1, 1):
                for j in range(3):
                    X = ex + s * (21 + j * 6)
                    if not keep_m[0:24, X - 3:X + 4].any() and not road_m[0:24, X - 3:X + 4].any():
                        spr(X, 20 + (j % 2) * 2, BAMBOO_S, BAMBOO_C)
                for j in range(10):
                    X = ex + s * (8 + j * 3); Y = 12 + (j * 7) % 9
                    if not keep_m[Y, X] and not road_m[Y, X]:
                        put(X, Y, 'PL' if j % 2 else 'PK')
        elif e['side'] == 'S':
            for s in (-1, 1):
                for j in range(0, 14):
                    X = ex + s * (5 + j // 2)
                    Y = H - 14 + j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'SN' if j % 2 else 'SD')
                    if j % 3 == 0:
                        put(X + s, Y - 1, 'PK' if j % 2 else 'SN')

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
    for sid, nm in ((235, 'DRAGONLIZARD DEN'), (230, 'FLOATING MARKET'), (233, 'ROOT-WRAPPED TEMPLE'), (239, 'STONE HEAD WATCHERS'), (148, None)):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-SEA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-SEA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-SEA.png'))
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

