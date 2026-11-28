#!/usr/bin/env python3
"""Gnome Venture - World map v2 underlay ("Delve down", lit and layered).

Native 640x360 pixel art, fixed palette (<=48 colours), no anti-aliasing.
Built from the approved mockup delve-3.py with the SAME seeds and positions, but
it paints only the underlay: strata, fog bands, cavern floors in their band
colours (rim light, halo, landmarks), the Mossbottom Market island, roots at the
top and stalagmites at the bottom. No labels, ruler, legend, seals, START tag,
hub-link badges or routes: the game draws those on top, from the layout JSON.

Writes (repo-relative):
  game/assets/img/scenes/map2-world.png         640x360 underlay
  game/includes/data/world_v2_layout.json      cavern ellipses, hub, ruler, route polylines
Optional:  python3 tools/map_v2/world.py --preview OUT.png
  also writes a 1280x720 check image (art + placeholder names + routes).
"""
import json, math, os, random, sys
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
W, H = 640, 360
random.seed(11)
rng = np.random.default_rng(11)


def hx(s):
    return tuple(int(s[i:i + 2], 16) for i in (1, 3, 5))


# ---------------------------------------------------------------- palette
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
assert len(PAL) <= 48
TIER_C = {1: ('T1', 't1'), 2: ('T2', 't2'), 3: ('T3', 't3'), 4: ('T4', 't4'), 5: ('T5', 't5')}

img = np.zeros((H, W, 3), np.uint8)
yy, xx = np.mgrid[0:H, 0:W]
B4 = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]])
BAY = (B4[yy % 4, xx % 4] + 0.5) / 16.0
BAY2 = (B4[(yy + 1) % 4, (xx + 2) % 4] + 0.5) / 16.0


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
    '0': '.###./#...#/#..##/#.#.#/##..#/#...#/.###.', '1': '..#../.##../..#../..#../..#../..#../.###.',
    '2': '.###./#...#/....#/...#./..#../.#.../#####', '3': '####./....#/....#/.###./....#/....#/####.',
    '4': '...#./..##./.#.#./#..#./#####/...#./...#.', '5': '#####/#..../####./....#/....#/#...#/.###.',
    '6': '.###./#..../#..../####./#...#/#...#/.###.', '7': '#####/....#/...#./..#../..#../..#../..#..',
    '8': '.###./#...#/#...#/.###./#...#/#...#/.###.', '9': '.###./#...#/#...#/.####/....#/....#/.###.',
    '-': '...../...../...../.###./...../...../.....', ':': '...../..#../...../...../...../..#../.....',
    ' ': '...../...../...../...../...../...../.....',
}
FONT = {k: v.split('/') for k, v in FONT_SRC.items()}


def text_w(s):
    return len(s) * 6 - 1


def text(x, y, s, c='CR', shadow='K'):
    for pas, (ox, oy, col) in enumerate(((1, 1, shadow), (0, 0, c))):
        if col is None:
            continue
        cx = x
        for ch in s:
            g = FONT[ch]
            for r in range(7):
                for q in range(5):
                    if g[r][q] == '#':
                        put(cx + q + ox, y + r + oy, col)
            cx += 6


def text_c(cx, y, s, c='CR', shadow='K'):
    text(cx - text_w(s) // 2, y, s, c, shadow)


# ---------------------------------------------------------------- sprites
LET = {'k': 'K', 'g': 'GM', 'G': 'T1', 'd': 'GK', 'r': 'RD', 'R': 'RK', 'h': 'RH', 'o': 'T4', 'y': 'GD',
       'c': 'CR', 'w': 'WH', 'b': 'S5', 'B': 'S6', 'p': 'PK', 'P': 'PL', 'a': 'AS', 'A': 'AL', 'u': 'WA',
       'U': 'WL', 's': 'SN', 'S': 'SD', 'v': 'T5', 't': 'NW', 'e': 'RE', 'n': 'ND', '1': 'S1', '2': 'S2',
       '3': 'S3', 'D': 't1'}


def spr(x, y, rows, over=None, anchor='bc'):
    """draw sprite; anchor 'bc' = bottom-centre at (x,y), 'tl' = top-left."""
    h = len(rows); w = len(rows[0])
    if anchor == 'bc':
        x0, y0 = x - w // 2, y - h + 1
    else:
        x0, y0 = x, y
    for r, row in enumerate(rows):
        for q, ch in enumerate(row):
            if ch == '.':
                continue
            c = (over or {}).get(ch, LET[ch])
            put(x0 + q, y0 + r, c)


TREE = ['..kkkk..', '.kGGggk.', 'kGGggggk', 'kGggggdk', 'kggggddk', '.kgdddk.', '..kbbk..', '..kbBk..', '..kkkk..']
TREE_S = ['.kkkk.', 'kGGgdk', 'kGggdk', '.kddk.', '.kbbk.', '.kkkk.']
BIGTREE = ['...kkkkkk...', '.kkGGGgggkk.', 'kGGGggggggdk', 'kGGgggggdddk', 'kggggdgdddkk', '.kkddkbkddk.',
           '...kkkbkkk..', '....kbBk....', '....kbBk....', '....kkkk....']
ACACIA = ['..kkkkkkkk..', '.kGGGgggggk.', 'kGggggggdddk', '.kkkkbkkkkk.', '..kbkbk.....', '...kbbk.....',
          '....kbk.....', '....kbk.....', '....kkk.....']
BIRCH = ['.kkkk.', 'kGGgdk', 'kGggdk', 'kggddk', '.kwkk.', '.kwk..', '.kak..', '.kwk..', '.kkk..']
PALM = ['.kk...kk.', 'kGgk.kgdk', '.kggkggk.', 'kgkkbkkgk', 'kk.kbk.kk', '...kBk...', '..kbk....', '..kbk....',
        '..kkk....']
SHROOM = ['..kkkk..', '.krwrrk.', 'krrrrwrk', 'kkkcckkk', '..kcSk..', '..kkkk..']
VOLCANO = ['....hy.y...', '...kyoyk...', '..kaoyoak..', '..kaAoaak..', '.kaAaaoaak.', 'kaAaaaaaaak', 'kkkkkkkkkkk']
VOLC_S = ['...yo...', '..kook..', '.k1aa1k.', 'k1a1111k', 'kkkkkkkk']
PEAK = ['....kk....', '...kwwk...', '..kwwAak..', '..kwAaak..', '.kAAaaaak.', 'kAAaaaaaak', 'kkkkkkkkkk']
PEAK_S = ['...kk...', '..kwAk..', '.kwAaak.', 'kAAaaaak', 'kkkkkkkk']
CRYSTAL = ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.']
STONE = ['.kkkk.', 'kAAaak', 'kAaaak', 'kkkkkk']
MENHIR = ['.kk.', 'kAak', 'kAak', 'kAak', 'kaak', 'kkkk']
COLUMN = ['kkkkk', 'kwwAk', '.kwk.', '.kAk.', '.kwk.', '.kAk.', 'kwwAk', 'kkkkk']
CORAL = ['k.k.k.k', 'pkpkPkp', 'kpkpkpk', '.kpPpk.', '..kpk..', '..kkk..']
MAIZE = ['.ky.', 'kGyk', 'kgGk', 'kygk', 'kgGk', '.kk.']
MOUND = ['..kk..', '.kehk.', '.keek.', 'keeRek', 'kkkkkk']
GNOME = ['....k....', '...krk...', '..krhrk..', '..krrrk..', '.krrrrrk.', '.kkssskk.', '.kwwwwkk.',
         'kuwwwukyk', '.kuuuukck', '.kbkkbkk.', '.kk..kk..']
SEAL = ['..kkkkk..', '.kRrrrRk.', 'kRhhrrrRk', 'krhRRRrrk', 'krrRcRrrk', 'krrRRRrRk', 'kRrrrrRRk', '.kRRRRRk.',
        '..kkkkk..']
BADGE = ['.kkkkk.', 'krrwrrk', 'krwrrrk', 'kkkckkk', '.kcck..', '.kkkk..']

MAPLE = {'g': 'T4', 'G': 'GD', 'd': 'RD'}
MAPLE_R = {'g': 'RD', 'G': 'T4', 'd': 'RK'}
JUNGLE = {'g': 'GK', 'G': 'GM', 'd': 't1'}
OLIVE = {'g': 'GK', 'G': 'AL', 'd': 't1'}
BLOSSOM = {'g': 'PK', 'G': 'PL', 'd': 'RE'}
CYANCAP = {'r': 'WA', 'w': 'WL'}

# ---------------------------------------------------------------- layout
BAND_Y = [18, 82, 146, 210, 274, 338]
BAND_LV = ['1-15', '15-25', '25-35', '35-45', '45-55']
CAV = {  # code: (cx, cy, hw, hh, label lines)
    'NA': (262, 43, 52, 17, ['MAPLEWOLD']),
    'CA': (161, 107, 46, 17, ['MAIZEHOLLOW']),
    'NWE': (397, 107, 46, 17, ['MISTMOOR']),
    'SA': (102, 171, 46, 17, ['RAINROOT', 'REACHES']),
    'CB': (220, 171, 46, 17, ['SUNSPRINKLE', 'ISLES']),
    'SE': (338, 171, 46, 17, ['OLIVEWHISTLE', 'SHORE']),
    'EE': (456, 171, 46, 17, ['BIRCHBRAMBLE', 'STEPPE']),
    'ESA': (102, 235, 46, 17, ['THORNACRE', 'SAVANNA']),
    'WCA': (220, 235, 46, 17, ['GREATCANOPY']),
    'MENA': (338, 235, 46, 17, ['DUNEWHISPER']),
    'CSA': (456, 235, 46, 17, ['SPICEPEAK']),
    'OC': (140, 301, 46, 17, ['CORALSCATTER']),
    'SEA': (290, 301, 46, 17, ['MONSOON TANGLE']),
    'EA': (440, 301, 46, 17, ['BLOSSOMREACH']),
}
# band of each region (1 green 1-15, 2 cyan 15-25, 3 gold 25-35, 4 orange 35-45, 5 violet 45-55)
TIER = {'NA': 1, 'CA': 2, 'NWE': 2, 'CB': 3, 'SA': 3, 'SE': 3, 'EE': 3, 'MENA': 4, 'CSA': 4, 'WCA': 4, 'ESA': 4,
        'EA': 5, 'SEA': 5, 'OC': 5}
BAND_NAME = {1: 'green', 2: 'cyan', 3: 'gold', 4: 'orange', 5: 'violet'}
# ROAD_PAIRS then ROAD_PAIRS_V2, as in game/includes/roads.php
ROADS = [('NA', 'CA'), ('NA', 'NWE'), ('NA', 'EA'), ('CA', 'CB'), ('CA', 'SA'), ('CB', 'SA'), ('SA', 'OC'),
         ('NWE', 'SE'), ('NWE', 'EE'), ('SE', 'MENA'), ('EE', 'CSA'), ('MENA', 'WCA'), ('MENA', 'CSA'),
         ('WCA', 'ESA'), ('ESA', 'CSA'), ('CSA', 'EA'), ('CSA', 'SEA'), ('EA', 'SEA'), ('SEA', 'OC'),
         ('CB', 'WCA'), ('SA', 'ESA')]
NEW = set(ROADS[-2:])
assert set(CAV) == set(TIER)

HUB = (582, 80)
LANTERN = (233, 38)

# route waypoints (through cavern interiors; caverns are painted over them)
WAY = {
    ('NA', 'CA'): [(232, 48), (205, 66), (182, 84), (168, 100)],
    ('NA', 'NWE'): [(296, 48), (330, 64), (368, 82), (390, 100)],
    ('NA', 'EA'): [(300, 40), (360, 34), (440, 38), (498, 56), (514, 100), (515, 200), (513, 270), (504, 293), (476, 302)],
    ('CA', 'CB'): [(172, 112), (190, 136), (206, 150), (216, 164)],
    ('CA', 'SA'): [(150, 112), (132, 136), (116, 150), (106, 164)],
    ('CB', 'SA'): [(220, 172), (161, 175), (102, 172)],
    ('SA', 'OC'): [(66, 171), (51, 181), (47, 230), (48, 278), (66, 297), (100, 302)],
    ('NWE', 'SE'): [(386, 112), (368, 136), (352, 150), (342, 164)],
    ('NWE', 'EE'): [(408, 112), (426, 136), (442, 150), (452, 164)],
    ('SE', 'MENA'): [(368, 176), (383, 190), (384, 210), (372, 228)],
    ('EE', 'CSA'): [(426, 176), (411, 190), (410, 210), (422, 228)],
    ('MENA', 'WCA'): [(338, 236), (279, 233), (220, 236)],
    ('MENA', 'CSA'): [(338, 234), (397, 237), (456, 234)],
    ('WCA', 'ESA'): [(220, 234), (161, 237), (102, 234)],
    ('ESA', 'CSA'): [(128, 242), (146, 262), (200, 269), (330, 268), (384, 266), (399, 252), (414, 238)],
    ('CSA', 'EA'): [(478, 240), (494, 256), (492, 276), (474, 292)],
    ('CSA', 'SEA'): [(430, 244), (420, 264), (392, 279), (340, 291), (316, 298)],
    ('EA', 'SEA'): [(440, 302), (365, 299), (290, 302)],
    ('SEA', 'OC'): [(290, 300), (215, 303), (140, 300)],
    ('CB', 'WCA'): [(250, 176), (265, 190), (266, 210), (254, 228)],
    ('SA', 'ESA'): [(132, 176), (147, 190), (148, 210), (136, 228)],
}
SEAL_AT = {('NA', 'EA'): (514, 146), ('SA', 'OC'): (48, 274)}
OPEN = {('NA', 'CA'), ('NA', 'NWE')}  # routes already unlocked at the start
assert set(WAY) == set(ROADS)

# ---------------------------------------------------------------- cavern geometry
geo = {}
for i, (code, (cx, cy, hw, hh, lab)) in enumerate(CAV.items()):
    r = random.Random(100 + i)
    p = [r.uniform(0, 6.28) for _ in range(3)]
    dx = xx - cx; dy = yy - cy
    th = np.arctan2(dy * hw / hh, dx)
    rm = 1 + 0.055 * np.sin(3 * th + p[0]) + 0.04 * np.sin(5 * th + p[1]) + 0.025 * np.sin(9 * th + p[2])
    ed = np.sqrt((dx / hw) ** 2 + (dy / hh) ** 2) / rm
    d = np.sqrt(dx * dx + dy * dy)
    dist = d * (1 - 1 / np.maximum(ed, 1e-6))
    geo[code] = dict(mask=ed <= 1, dist=dist, ed=ed)


def dil4(m):
    r = m.copy()
    r[1:] |= m[:-1]; r[:-1] |= m[1:]; r[:, 1:] |= m[:, :-1]; r[:, :-1] |= m[:, 1:]
    return r


def dil8(m):
    r = dil4(m)
    r[1:, 1:] |= m[:-1, :-1]; r[1:, :-1] |= m[:-1, 1:]; r[:-1, 1:] |= m[1:, :-1]; r[:-1, :-1] |= m[1:, 1:]
    return r


def plaque_rect(code):
    cx, cy, hw, hh, lab = CAV[code]
    w = max(text_w(s) for s in lab) + 7
    if len(lab) == 1:
        return (cx - w // 2, cy + 13, cx - w // 2 + w - 1, cy + 25)
    return (cx - w // 2, cy + 11, cx - w // 2 + w - 1, cy + 31)


# ================================================================ 1. FAR LAYER: lit strata
n1 = vnoise(24, 1); n2 = vnoise(6, 2); n3 = vnoise(3, 3)
strata = np.sin((yy + 7 * np.sin(xx / 37.0) + 14 * n1) / 5.0)
v = 0.25 + 0.10 * n1 + 0.07 * n2 + 0.045 * strata + 0.04 * n3
v *= 1 - 0.28 * (yy / H)
v -= 0.07 * (np.abs(xx - 320) / 320.0) ** 2
# light sources
dl = np.hypot(xx - LANTERN[0], yy - LANTERN[1])
v += 0.42 * np.exp(-(dl / 26.0) ** 2)
dh = np.hypot(xx - HUB[0], yy - HUB[1])
v += 0.34 * np.exp(-(dh / 30.0) ** 2)
for code, g in geo.items():
    gl = np.clip(1 - g['dist'] / 22.0, 0, 1)
    v += np.where(g['dist'] > 0, 0.16 * gl * gl, 0)
idx = np.floor(v * 7 + BAY).astype(int).clip(0, 5)
cool = np.clip((yy - 150) / 170.0, 0, 1) * 0.92 > BAY2
WARM = ['S0', 'S1', 'S2', 'S3', 'S4', 'S5']
COOL = ['S0', 'D1', 'D2', 'D3', 'D4', 'D4']
for i in range(6):
    paint((idx == i) & ~cool, WARM[i])
    paint((idx == i) & cool, COOL[i])
# strata cracks
crack = (np.abs(strata) < 0.07) & (n2 > 0.56)
paint(crack & ~cool, 'S0'); paint(crack & cool, 'S0')
# pebbles
for _ in range(240):
    x = random.randrange(44, W); y = random.randrange(14, H - 8)
    deep = y > 200 and random.random() < (y - 150) / 200
    put(x, y, 'D4' if deep else 'S5'); put(x + 1, y, 'D3' if deep else 'S4')
    if random.random() < .4:
        put(x, y - 1, 'FOG' if deep else 'S6')
# v2: the old depth-ruler strip (x < 44) is plain ground now; own RNG so the rest stays as delve-3
RL = random.Random(44)
for _ in range(18):
    x = RL.randrange(0, 42); y = RL.randrange(14, H - 8)
    deep = y > 200 and RL.random() < (y - 150) / 200
    put(x, y, 'D4' if deep else 'S5'); put(x + 1, y, 'D3' if deep else 'S4')
    if RL.random() < .4:
        put(x, y - 1, 'FOG' if deep else 'S6')

# fog bands between strata
fogn = vnoise(16, 9)
for bi, y0 in enumerate(BAND_Y[1:5]):
    ph = bi * 1.7
    yc = y0 + 2.5 * np.sin(xx / 29.0 + ph) + 1.5 * np.sin(xx / 11.0 + ph * 2)
    dyf = np.abs(yy - yc)
    dens = np.clip((fogn - 0.30) * 2.2, 0, 1) * np.clip(1 - dyf / 5.0, 0, 1)
    paint((dens > BAY + 0.10) & (dyf > 1.5), 'D4')
    paint((dens > BAY + 0.10) & (dyf <= 1.5), 'FOG')

# coloured halos (dithered) around each cavern in band colour
for code, g in geo.items():
    bright, dim = TIER_C[TIER[code]]
    hval = np.clip(1 - g['dist'] / 13.0, 0, 1)
    paint((g['dist'] > 0) & (hval ** 1.6 > BAY + 0.04), dim)

# tiny far crystals
inany = np.zeros((H, W), bool)
for g in geo.values():
    inany |= g['dist'] < 6
for _ in range(110):
    x = random.randrange(46, W - 3); y = random.randrange(16, H - 16)
    if inany[y, x]:
        continue
    b, dm = random.choice([('T2', 't2'), ('T5', 't5'), ('NW', 'ND'), ('GD', 't3'), ('PK', 't4')])
    if y > 215 and random.random() < .6:
        put(x, y, dm); put(x, y + 1, 'D2')
    else:
        put(x, y, b); put(x, y + 1, dm)
        if random.random() < .35:
            put(x, y - 1, 'WH'); put(x + 1, y + 1, dm)


# ================================================================ 2. ROUTE GEOMETRY (not painted: the game draws routes)
def catmull(pts, n=24):
    P = [pts[0]] + list(pts) + [pts[-1]]
    out = []
    for i in range(1, len(P) - 2):
        p0, p1, p2, p3 = P[i - 1], P[i], P[i + 1], P[i + 2]
        for k in range(n):
            t = k / n
            out.append(tuple(0.5 * ((2 * p1[j]) + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t * t
                                    + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t ** 3) for j in (0, 1)))
    out.append(pts[-1])
    return out


def thread_path(pts, seed):
    """The wobbling thread centre line (float points) exactly as delve-3 drew it."""
    c = catmull(pts)
    ph = seed * 1.3
    px = []
    s = 0.0
    for i, (x, y) in enumerate(c):
        if i:
            s += math.hypot(x - c[i - 1][0], y - c[i - 1][1])
        j = min(i + 1, len(c) - 1); k = max(i - 1, 0)
        tx, ty = c[j][0] - c[k][0], c[j][1] - c[k][1]
        L = math.hypot(tx, ty) or 1
        wob = 1.1 * math.sin(s / 6.5 + ph) + 0.6 * math.sin(s / 2.9 + ph * 2)
        px.append((x - ty / L * wob, y + tx / L * wob))
    return px


def route_pixels(pts, seed):
    px = thread_path(pts, seed)
    out = []
    for i in range(len(px) - 1):
        x0, y0 = px[i]; x1, y1 = px[i + 1]
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for k in range(n + 1):
            p = (int(round(x0 + (x1 - x0) * k / n)), int(round(y0 + (y1 - y0) * k / n)))
            if not out or out[-1] != p:
                out.append(p)
    return out


def kind(r):
    return 'new' if r in NEW else ('open' if r in OPEN else 'locked')


STY = {'open': ('CR', 'GD'), 'locked': ('MY', 'MD'), 'new': ('NW', 'ND')}


def draw_thread(px, k, hyphae=True, seed=0):
    core, flank = STY[k]
    rr = random.Random(seed)
    if k == 'open':  # warm dithered glow
        for (x, y) in px:
            for ox in range(-3, 4):
                for oy in range(-3, 4):
                    if ox * ox + oy * oy <= 9 and (x + ox + y + oy) % 2 == 0:
                        put(x + ox, y + oy, 'S6')
    if hyphae:
        for i in range(6, len(px) - 6, 9):
            if rr.random() < .7:
                x, y = px[i]
                sx, sy = rr.choice([(1, 1), (-1, 1), (1, -1), (-1, -1)])
                for t in range(1, rr.randint(3, 6)):
                    put(x + sx * t, y + sy * ((t + 1) // 2) + (sy if t > 2 else 0), flank if k != 'open' else 'SD')
    for (x, y) in px:
        for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            put(x + ox, y + oy, flank)
    for i, (x, y) in enumerate(px):
        c = core
        if k == 'new' and i % 7 >= 5:
            c = 'ND'
        if k == 'locked' and i % 9 == 4:
            c = 'CR'
        put(x, y, c)
    if k == 'open':  # pulse knots
        for i in range(5, len(px) - 3, 11):
            x, y = px[i]
            for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                put(x + ox, y + oy, 'CR')
            put(x, y, 'WH')



# ================================================================ 3. MID LAYER: caverns
FLOOR = {  # base, texture, edge
    'NA': ('GM', 'T1', 'GK'), 'CA': ('AS', 'AL', 'S3'), 'NWE': ('GK', 't1', 'S2'),
    'SA': ('GK', 'GM', 't1'), 'CB': ('SN', 'CR', 'SD'), 'SE': ('RE', 'RH', 'RK'),
    'EE': ('S2', 'S3', 'S0'), 'ESA': ('SD', 'GD', 'S5'), 'WCA': ('RE', 'T4', 'RK'),
    'MENA': ('SN', 'CR', 'SD'), 'CSA': ('S6', 'SD', 'S4'), 'OC': ('WA', 'WL', 't2'),
    'SEA': ('GM', 'T1', 'GK'), 'EA': ('GM', 'T1', 'GK'),
}
texn = vnoise(2, 21)
for code, g in geo.items():
    cx, cy, hw, hh, lab = CAV[code]
    bright, dim = TIER_C[TIER[code]]
    m = g['mask']
    d1 = dil8(m); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, dim)
    paint(d3 & ~d2, bright)
    paint(d2 & ~d1, bright)
    paint(d1 & ~m, 'K')
    # rim texture: broken light on the lower half
    paint((d3 & ~d2) & (yy > cy + 4) & ((xx + yy) % 3 == 0), dim)
    base, tex, edge = FLOOR[code]
    paint(m, base)
    paint(m & (texn > 0.70), tex)
    paint(m & (texn < 0.22), edge)
    inner = m & ~(~dil4(~m))
    paint(inner, edge)
    up3 = np.zeros_like(m); up3[3:] = m[:-3]
    paint(m & ~up3 & ((xx + yy) % 2 == 0), edge)
    g['rim'] = d4


def clip_ellipse(code, x, y, rx, ry, c, c2=None, outline=None):
    m = geo[code]['mask']
    e = ((xx - x) / rx) ** 2 + ((yy - y) / ry) ** 2
    if outline:
        eo = ((xx - x) / (rx + 1)) ** 2 + ((yy - y) / (ry + 1)) ** 2
        paint(m & (eo <= 1), outline)
    paint(m & (e <= 1), c)
    if c2:
        paint(m & (e <= 1) & (yy < y) & (e > 0.25) & (xx < x + rx * 0.3), c2)


def dots(code, pts, c):
    cx, cy = CAV[code][:2]
    for dx, dy in pts:
        if geo[code]['mask'][cy + dy, cx + dx]:
            put(cx + dx, cy + dy, c)


def place(code, items):
    cx, cy = CAV[code][:2]
    for it in sorted(items, key=lambda t: t[1]):
        dx, dy, rows = it[:3]
        spr(cx + dx, cy + dy, rows, it[3] if len(it) > 3 else None)


R = random.Random(5)


def scatter(code, n, c, ymin=-13, ymax=9):
    cx, cy, hw = CAV[code][:3]
    for _ in range(n):
        dx = R.randint(-hw + 6, hw - 6); dy = R.randint(ymin, ymax)
        if geo[code]['mask'][cy + dy, cx + dx]:
            put(cx + dx, cy + dy, c)


# --- Maplewold: maples + prairie
scatter('NA', 26, 'GD'); scatter('NA', 14, 'GK')
place('NA', [(-12, -2, TREE, MAPLE), (2, 8, TREE, MAPLE_R), (15, -3, TREE, MAPLE), (28, 7, TREE),
             (39, -1, TREE_S), (-22, 9, TREE_S, MAPLE), (-2, -8, TREE_S, MAPLE_R)])
# --- Maizehollow: volcanic ash
cx, cy = CAV['CA'][:2]
clip_ellipse('CA', cx + 18, cy + 2, 17, 8, 'GK'); clip_ellipse('CA', cx + 18, cy + 1, 15, 6, 'GM')
scatter('CA', 14, 'S3')
place('CA', [(-20, 4, VOLCANO, {'a': 'S3', 'A': 'S5'}), (-36, 8, STONE), (4, 1, MAIZE), (11, 7, MAIZE), (18, 0, MAIZE), (25, 6, MAIZE),
             (32, 1, MAIZE), (-3, 9, MAIZE)])
dots('CA', [(-21, -6), (-18, -8), (-17, -5)], 'AL')
# --- Mistmoor: peat, pools, fog
cx, cy = CAV['NWE'][:2]
clip_ellipse('NWE', cx - 20, cy + 3, 10, 4, 'WA', 'WL', 'K'); clip_ellipse('NWE', cx + 24, cy - 5, 8, 3, 'WA', 'WL', 'K')
scatter('NWE', 16, 'GM'); scatter('NWE', 10, 'S4')
place('NWE', [(-2, 2, MENHIR), (5, 6, MENHIR), (12, 1, MENHIR), (30, 8, TREE_S, JUNGLE), (-34, -2, TREE_S, JUNGLE),
              (-8, -6, SHROOM, CYANCAP)])
m = geo['NWE']['mask']
mist = (np.sin(xx / 5.0 + yy * 1.9) > 0.45) & (yy % 4 == 1) & (yy < cy + 11)
paint(m & mist & (xx % 2 == 0), 'AL'); paint(m & mist & (xx % 2 == 1), 'WH')
# --- Rainroot Reaches: jungle + river
cx, cy = CAV['SA'][:2]
m = geo['SA']['mask']
riv = np.abs(yy - (cy + 4 + 4 * np.sin((xx - cx) / 9.0))) < 1.4
paint(m & riv, 'WA'); paint(m & riv & (xx % 5 == 0), 'WL')
place('SA', [(-34, -1, TREE, JUNGLE), (-22, -6, BIGTREE, JUNGLE), (-8, -4, TREE, JUNGLE), (6, -7, BIGTREE, JUNGLE),
             (20, -3, TREE, JUNGLE), (33, -2, TREE, JUNGLE), (-30, 9, TREE_S, JUNGLE), (36, 8, TREE_S, JUNGLE),
             (-14, 9, TREE_S)])
dots('SA', [(-20, -12), (8, -13), (22, -8), (-6, -9)], 'RH')
# --- Sunsprinkle Isles: coral sand pools
cx, cy = CAV['CB'][:2]
clip_ellipse('CB', cx - 22, cy - 2, 11, 5, 'WA', 'WL', 'SD'); clip_ellipse('CB', cx + 6, cy + 5, 9, 4, 'WA', 'WL', 'SD')
clip_ellipse('CB', cx + 26, cy - 5, 8, 4, 'WA', 'WL', 'SD')
place('CB', [(-4, -3, PALM), (36, 8, PALM), (-36, 9, CORAL), (18, -8, CORAL, {'p': 'RH', 'P': 'PL'}), (-14, 9, SHROOM)])
dots('CB', [(-22, -2), (6, 5), (27, -5)], 'WH')
# --- Olivewhistle Shore: red stony, olive trees
scatter('SE', 18, 'AL'); scatter('SE', 12, 'AS')
place('SE', [(-32, 0, TREE, OLIVE), (-18, 8, TREE, OLIVE), (-6, -3, TREE, OLIVE), (22, -2, TREE, OLIVE),
             (34, 7, TREE_S, OLIVE), (8, 7, COLUMN), (-38, 9, STONE)])
# --- Birchbramble Steppe: black earth, birches
cx, cy = CAV['EE'][:2]
m = geo['EE']['mask']
paint(m & (yy % 3 == 0) & (xx > cx - 6) & (yy > cy - 8) & ((xx + yy // 3) % 7 != 0), 'S4')
paint(m & (yy % 3 == 1) & (xx > cx - 6) & (yy > cy - 8) & ((xx * 3 + yy) % 5 == 0), 'GD')
scatter('EE', 14, 'GM')
place('EE', [(-36, 2, BIRCH), (-27, 8, BIRCH), (-18, 0, BIRCH), (-9, 9, BIRCH), (4, -6, BIRCH), (30, -7, BIRCH),
             (18, -8, TREE_S)])
# --- Thornacre Savanna
cx, cy = CAV['ESA'][:2]
clip_ellipse('ESA', cx + 20, cy + 4, 12, 4, 'RE'); scatter('ESA', 26, 'T3'); scatter('ESA', 14, 'GM')
place('ESA', [(-28, 1, ACACIA), (-4, -4, ACACIA), (24, 0, ACACIA), (-14, 9, MOUND), (36, 8, MOUND), (8, 9, TREE_S)])
# --- Greatcanopy
scatter('WCA', 14, 'RK')
place('WCA', [(-32, -1, BIGTREE), (-18, 6, BIGTREE, JUNGLE), (-6, -4, BIGTREE), (8, 5, BIGTREE), (22, -3, BIGTREE, JUNGLE),
              (34, 6, BIGTREE), (-38, 9, TREE_S)])
# --- Dunewhisper
cx, cy = CAV['MENA'][:2]
m = geo['MENA']['mask']
for k in range(5):
    yb = cy - 12 + k * 5
    wave = np.abs(yy - (yb + 2.2 * np.sin((xx + k * 9) / 6.0))) < 0.6
    paint(m & wave, 'SD')
    wave2 = np.abs(yy - 1 - (yb + 2.2 * np.sin((xx + k * 9) / 6.0))) < 0.6
    paint(m & wave2 & (np.cos((xx + k * 9) / 6.0) > 0.2), 'CR')
clip_ellipse('MENA', cx + 22, cy + 3, 8, 3, 'WA', 'WL', 'GK')
place('MENA', [(31, 1, PALM), (12, 6, PALM), (-26, 4, STONE, {'A': 'CR', 'a': 'SD'})])
# --- Spicepeak
cx, cy = CAV['CSA'][:2]
m = geo['CSA']['mask']
riv = np.abs(yy - (cy + 6 + 3 * np.sin((xx - cx) / 8.0))) < 1.4
paint(m & riv, 'WA'); paint(m & riv & (xx % 4 == 0), 'WL')
scatter('CSA', 10, 'RD', 3, 10); scatter('CSA', 10, 'T4', 3, 10); scatter('CSA', 10, 'GD', 3, 10); scatter('CSA', 8, 'GM')
place('CSA', [(-26, 0, PEAK), (-8, -4, PEAK), (10, 1, PEAK), (28, -3, PEAK_S), (-37, 4, PEAK_S), (36, 9, TREE_S)])
# --- Coralscatter
cx, cy = CAV['OC'][:2]
for (dx, dy, rx, ry) in [(-26, 0, 12, 5), (4, -6, 10, 4), (24, 4, 13, 5), (-6, 8, 8, 3)]:
    clip_ellipse('OC', cx + dx, cy + dy, rx, ry, 'SN', None, 'WL')
place('OC', [(-28, 2, VOLC_S), (22, 5, PALM), (4, -5, CORAL), (-8, 10, CORAL, {'p': 'RH'}), (34, 8, CORAL),
             (-38, 6, CORAL, {'p': 'T5', 'P': 'PL'}), (12, 8, TREE_S)])
# --- Monsoon Tangle: paddies
cx, cy = CAV['SEA'][:2]
m = geo['SEA']['mask']
for (dx, dy, w, h) in [(-36, -10, 16, 8), (-18, -12, 18, 9), (2, -11, 16, 8), (-30, 0, 18, 9), (-10, -1, 16, 9), (8, -1, 18, 8)]:
    r = (xx >= cx + dx) & (xx < cx + dx + w) & (yy >= cy + dy) & (yy < cy + dy + h)
    paint(m & r, 'GK')
    ri = (xx > cx + dx) & (xx < cx + dx + w - 1) & (yy > cy + dy) & (yy < cy + dy + h - 1)
    paint(m & ri, 'WA'); paint(m & ri & ((yy - cy - dy) % 2 == 0) & (xx % 3 != 0), 'T1')
    paint(m & ri & ((yy - cy - dy) % 2 == 1) & (xx % 4 == 0), 'WL')
place('SEA', [(33, -2, PALM), (38, 8, PALM), (27, 9, TREE_S, JUNGLE), (-40, 6, TREE_S, JUNGLE)])
# --- Blossomreach: terraces
cx, cy = CAV['EA'][:2]
m = geo['EA']['mask']
rr_ = np.hypot((xx - cx) * 0.55, (yy - cy - 26))
paint(m & (rr_.astype(int) % 6 == 0), 'GK'); paint(m & (rr_.astype(int) % 6 == 1), 'T1')
paint(m & (rr_.astype(int) % 6 == 3) & (xx % 3 == 0), 'PK')
place('EA', [(-32, 1, TREE, BLOSSOM), (-16, -4, TREE, BLOSSOM), (0, 4, TREE, BLOSSOM), (16, -3, TREE, BLOSSOM),
             (31, 3, TREE, BLOSSOM), (-24, 9, TREE_S, BLOSSOM), (38, 9, TREE_S, BLOSSOM)])
dots('EA', [(-8, -10), (8, -11), (24, -9), (-26, -8), (-10, 7), (12, 8)], 'PL')


# ================================================================ 6. HUB island (right column)
hxc, hyc = HUB
for i in range(16):
    a = i * math.pi / 8 + 0.2
    r0, r1 = (25, 33) if i % 2 == 0 else (26, 30)
    for rr2 in range(r0, r1 + 1):
        if i % 2 == 1 and rr2 % 2:
            continue
        put(hxc + math.cos(a) * rr2 * 1.25, hyc + 2 + math.sin(a) * rr2, 'GD' if rr2 < r1 - 1 else 'CR')
glow = np.clip(1 - np.hypot((xx - hxc) / 1.25, yy - hyc - 2) / 24.0, 0, 1)
paint((glow > 0) & (glow ** 1.4 > BAY + 0.10), 't3')
paint((glow ** 2.2 > BAY + 0.25), 'S6')
# floating island
e = ((xx - hxc) / 25.0) ** 2 + ((yy - hyc - 10) / 6.0) ** 2
eo = ((xx - hxc) / 26.0) ** 2 + ((yy - hyc - 10) / 7.0) ** 2
under = (np.abs(xx - hxc) < 22 - (yy - hyc - 10) * 2.2) & (yy >= hyc + 10) & (yy <= hyc + 19)
under_o = (np.abs(xx - hxc) < 23.5 - (yy - hyc - 10) * 2.2) & (yy >= hyc + 10) & (yy <= hyc + 20)
paint(under_o, 'K'); paint(under, 'S4'); paint(under & ((xx + yy) % 3 == 0), 'S3'); paint(under & (xx < hxc - 8) & ((xx + yy) % 2 == 0), 'S5')
paint(eo <= 1, 'K'); paint(e <= 1, 'GM'); paint((e <= 1) & (yy < hyc + 9), 'T1'); paint((e <= 1) & (yy > hyc + 12), 'GK')
paint((e <= 1) & (vnoise(2, 33) > .72), 'GK')
# big mushroom
capc = (hxc, hyc - 2)
ec = ((xx - capc[0]) / 13.0) ** 2 + ((yy - capc[1]) / 10.0) ** 2
eco = ((xx - capc[0]) / 14.0) ** 2 + ((yy - capc[1]) / 11.0) ** 2
rect(hxc - 4, hyc - 2, hxc + 4, hyc + 9, 'K'); rect(hxc - 3, hyc - 1, hxc + 3, hyc + 9, 'CR'); rect(hxc + 1, hyc - 1, hxc + 3, hyc + 9, 'SN')
rect(hxc - 3, hyc - 1, hxc + 3, hyc, 'SD')
cap_o = (eco <= 1) & (yy <= capc[1] + 1); cap = (ec <= 1) & (yy <= capc[1])
paint(cap_o, 'K'); paint(cap, 'RD')
paint(cap & (((xx - capc[0] + 4) / 13.0) ** 2 + ((yy - capc[1] + 3) / 10.0) ** 2 < 0.35), 'RH')
paint(cap & (xx > capc[0] + 6) & (ec > 0.55), 'RK'); paint(cap & (yy == capc[1]), 'RK')
for (dx, dy, rr3) in [(-6, -6, 2), (3, -7, 1.6), (7, -3, 1.5), (-1, -3, 1.3), (-10, -2, 1.2)]:
    paint(cap & (np.hypot(xx - capc[0] - dx, yy - capc[1] - dy) <= rr3), 'WH')
spr(hxc - 17, hyc + 10, SHROOM); spr(hxc + 17, hyc + 11, SHROOM, CYANCAP)
spr(hxc + 9, hyc + 12, CRYSTAL)
for (dx, dy) in [(-22, -14), (20, -18), (-14, -22), (12, -24), (26, -6), (-27, -4)]:
    put(hxc + dx, hyc + dy, 'CR'); put(hxc + dx, hyc + dy + 1, 'GD')

# ================================================================ 9. NEAR LAYER: roots, stalactites, stalagmites
def spike(x0, w, h, up):
    for i in range(w):
        t = 1 - abs((i + 0.5) / w * 2 - 1)
        hh_ = int(round(h * t ** 0.8))
        for j in range(hh_ + 1):
            y = (H - 1 - j) if up else j
            c = 'S1'
            if i <= w * 0.3 and j < hh_:
                c = 'S4'
            if j >= hh_ - 0 or i == 0 or i == w - 1:
                c = 'K'
            if c == 'S1' and (i + j) % 5 == 0:
                c = 'S2'
            put(x0 + i, y, c)


rect(0, 0, W - 1, 2, 'K')
rect(0, H - 3, W - 1, H - 1, 'K')
# v2: fill the old ruler strip (x < 43) first, with its own RNG
RL = random.Random(43)
x = -3
while True:
    w = RL.randint(5, 11)
    if x + w > 44:
        break
    spike(x, w, RL.randint(3, 6) + 2, False)
    x += w - RL.randint(0, 2)
x = -4
while True:
    w = RL.randint(6, 14)
    if x + w > 44:
        break
    spike(x, w, RL.randint(4, 13) + 2, True)
    x += w - RL.randint(0, 3)
x = 43
RS = random.Random(3)
while x < W:
    w = RS.randint(5, 13)
    h = RS.randint(3, 10)
    if 214 < x < 312:
        h = min(h, 5)
    if x < 180:
        h = min(h, 4)
    elif x > 320:
        h += 3
    spike(x, w, h + 2, False)
    x += w - RS.randint(0, 2)
x = 43
while x < W:
    w = RS.randint(6, 16)
    h = RS.randint(4, 15)
    spike(x, w, h + 2, True)
    x += w - RS.randint(0, 3)


def root(x0, y1, thick, seed):
    r = random.Random(seed)
    ph = r.uniform(0, 6)
    pts = []
    for y in range(0, y1 + 1):
        x = x0 + int(round(2.2 * math.sin(y / 5.0 + ph) + 1.0 * math.sin(y / 2.3 + ph)))
        pts.append((x, y))
    for (x, y) in pts:
        t = thick if y < y1 - 5 else 1
        rect(x - 1, y, x + t, y, 'K')
    for (x, y) in pts:
        t = thick if y < y1 - 5 else 1
        rect(x, y, x + t - 1, y, 'S5')
        put(x, y, 'S6')
        if y % 6 == 3 and t > 1:
            put(x + t - 1, y, 'S4')
    x, y = pts[-1]
    put(x, y + 1, 'K')
    for k in range(3, len(pts) - 4, 7):  # rootlets
        x, y = pts[k]
        sgn = r.choice([-1, 1])
        for t in range(1, r.randint(3, 6)):
            put(x + sgn * (t + (thick if sgn > 0 else 0)), y + t, 'S5')


for (x0, y1, th, sd) in [(226, 24, 2, 1), (242, 27, 3, 2), (258, 22, 2, 3), (271, 28, 3, 4), (286, 25, 2, 5), (300, 21, 2, 6),
                         (120, 17, 1, 7), (438, 19, 1, 8), (350, 15, 1, 9), (620, 22, 2, 10), (538, 18, 1, 11)]:
    root(x0, y1, th, sd)
# floor dressing
for (x, c) in [(70, None), (196, CYANCAP), (372, None), (508, CYANCAP), (566, None), (612, CYANCAP)]:
    spr(x, H - 5, SHROOM, c)
for x in (240, 406, 590, 540):
    spr(x, H - 4, CRYSTAL, {'U': 'PL', 'u': 'T5', 'n': 't5'} if x % 4 == 0 else None)
root(24, 19, 2, 12)
spr(16, H - 5, SHROOM, CYANCAP)


# ================================================================ output: underlay PNG
def check_palette():
    cols = np.unique(img.reshape(-1, 3), axis=0)
    allowed = {tuple(c) for c in PAL.values()}
    assert all(tuple(c) in allowed for c in cols), 'off-palette pixel'
    return len(cols)


print('colours used:', check_palette())
png_path = os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-world.png')
Image.fromarray(img, 'RGB').save(png_path, optimize=True)
print('wrote', png_path)

# ================================================================ output: layout JSON
def decimate(px, step=3.0):
    """Keep a point every `step` px of arc length (plus the last one)."""
    out = [px[0]]
    acc = 0.0
    for i in range(1, len(px)):
        acc += math.hypot(px[i][0] - px[i - 1][0], px[i][1] - px[i - 1][1])
        if acc >= step:
            out.append(px[i]); acc = 0.0
    if out[-1] != px[-1]:
        out.append(px[-1])
    return [[round(x, 1), round(y, 1)] for x, y in out]


layout = {
    'w': W, 'h': H,
    'note': 'Native-pixel coordinates on map2-world.png (generated by tools/map_v2/world.py). '
            'regions: cavern floor ellipse centre (x,y) and half-axes (rx,ry); the lit rim adds ~4 px. '
            'label: the box under the cavern where delve-3 put the name plaque. '
            'routes: the glowing thread centre line from rim to rim (the part delve-3 showed), first code to second; '
            'routes_full: the same thread running on to the cavern centres (hidden under the floors in delve-3); '
            'route_waypoints: the generator control points (Catmull-Rom).',
    'regions': {},
    'hub': {'x': HUB[0], 'y': HUB[1], 'rx': 33, 'ry': 26, 'label_y': HUB[1] + 42},
    'start': {'x': LANTERN[0], 'y': LANTERN[1]},
    'ruler': {'x0': 0, 'x1': 42, 'bands': []},
    'routes': {},
    'routes_full': {},
    'route_waypoints': {},
    'route_order': ['%s-%s' % r for r in ROADS],
}
for code, (cx, cy, hw, hh, lab) in CAV.items():
    layout['regions'][code] = {'x': cx, 'y': cy, 'rx': hw, 'ry': hh, 'band': BAND_NAME[TIER[code]],
                               'tier': TIER[code], 'label': list(plaque_rect(code))}
for bi in range(5):
    layout['ruler']['bands'].append({'band': BAND_NAME[bi + 1], 'tier': bi + 1, 'lv': BAND_LV[bi],
                                     'y0': BAND_Y[bi], 'y1': BAND_Y[bi + 1],
                                     'colour': '#%02x%02x%02x' % PAL[TIER_C[bi + 1][0]]})
RIM_ANY = np.zeros((H, W), bool)
for g in geo.values():
    RIM_ANY |= g['rim']


def visible_part(px):
    """The stretch of thread between the two cavern rims (delve-3 painted caverns over the rest)."""
    out = [k for k, (x, y) in enumerate(px) if not RIM_ANY[int(round(y)), int(round(x))]]
    assert out and out[-1] - out[0] + 1 == len(out), 'route crosses a third cavern'
    return px[max(0, out[0] - 1):out[-1] + 2]


for i, r in enumerate(ROADS):
    key = '%s-%s' % r
    full = thread_path(WAY[r], i)
    layout['routes'][key] = decimate(visible_part(full))
    layout['routes_full'][key] = decimate(full)
    layout['route_waypoints'][key] = [list(p) for p in WAY[r]]
json_path = os.path.join(ROOT, 'game', 'includes', 'data', 'world_v2_layout.json')
with open(json_path, 'w') as f:
    f.write('{\n')
    keys = list(layout)
    for ki, k in enumerate(keys):
        v = layout[k]
        if isinstance(v, dict) and k in ('regions', 'routes', 'routes_full', 'route_waypoints'):
            f.write('  %s: {\n' % json.dumps(k))
            sub = list(v)
            for si, sk in enumerate(sub):
                f.write('    %s: %s%s\n' % (json.dumps(sk), json.dumps(v[sk], separators=(',', ':')),
                                            ',' if si < len(sub) - 1 else ''))
            f.write('  }')
        else:
            f.write('  %s: %s' % (json.dumps(k), json.dumps(v)))
        f.write(',\n' if ki < len(keys) - 1 else '\n')
    f.write('}\n')
json.load(open(json_path))
print('wrote', json_path)

# ================================================================ optional preview (art + placeholder names + routes)
if '--preview' in sys.argv:
    prev = sys.argv[sys.argv.index('--preview') + 1]
    lay = json.load(open(json_path))
    for order in ('locked', 'new', 'open'):
        for i, r in enumerate(ROADS):
            if kind(r) != order:
                continue
            fp = [tuple(p) for p in lay['routes']['%s-%s' % r]]
            pix = []
            for (x0, y0), (x1, y1) in zip(fp, fp[1:]):
                n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
                for k in range(n + 1):
                    p = (int(round(x0 + (x1 - x0) * k / n)), int(round(y0 + (y1 - y0) * k / n)))
                    if not pix or pix[-1] != p:
                        pix.append(p)
            draw_thread(pix, order, hyphae=False, seed=i)
    for code, reg in lay['regions'].items():
        x0, y0, x1, y1 = reg['label']
        bright, dim = TIER_C[reg['tier']]
        rect(x0, y0, x1, y1, 'K'); rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, dim); rect(x0 + 2, y0 + 2, x1 - 2, y1 - 2, 'S0')
        lab = CAV[code][4]
        for li, s in enumerate(lab):
            text_c((x0 + x1) // 2 + 1, y0 + 3 + li * 9, s, 'CR')
    text_c(HUB[0], lay['hub']['label_y'], 'MOSSBOTTOM', 'CR')
    text_c(HUB[0], lay['hub']['label_y'] + 9, 'MARKET', 'CR')
    for b in lay['ruler']['bands']:
        bright, dim = TIER_C[b['tier']]
        rect(0, b['y0'] + 1, 3, b['y1'] - 1, bright)
        text(6, (b['y0'] + b['y1']) // 2 - 3, b['lv'], bright)
    Image.fromarray(img, 'RGB').resize((W * 2, H * 2), Image.NEAREST).save(prev)
    print('wrote', prev)
