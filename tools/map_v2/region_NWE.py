#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for NWE "Mistmoor" (band cyan, Lv 15-25).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built from the
CA / CB generators: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside
with a dithered cyan halo and a cyan rim light (a few px of green at the Maplewold mouth; east of the
line through the two tier gates the rim turns gold, tier 3 lies beyond), biome ground (the mist-green
Hedgerow Downs hub, dark Fernhollow Wood, the pale Ley shelf, the frosted Long Night Fells and the cold
shoulder, warm grey Screefall, the Olivewhistle terraces, Stork Marsh and the birch wood), waters
(Foghorn Mere, the warm Turtle Lagoon with sand islets, the black Fjordfang and its creek to the
Sea-cave, the beck under the Footbridge), landmark props (windmill, barley Seed Bed edged with
heather, hedgerows, Ley stones and the menhir, the fairy ring, the unlit twin beacon, ice
stalagmites, the Rim Pass door, sea stack and longboat, the orange Forge vent, the Sauna's steam
plume under a green aurora, olives, vines, birches, reeds, salt crystals), FOG dither low on the
floor, glowing road trunks on the layout polylines with the two gate posts and the Footbridge, the
three exit tunnel mouths; a root ceiling (thickest over the Market) and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and inside a
14-unit circle round every spread position of the plan there is a plain floor (one or two flat
tones, no sprites, no water, no texture).

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_NWE.py [--layout layout-NWE.json] [--plan plan-NWE.json]
                                     [--out game/assets/img/scenes/map2-NWE.png] [--preview PREVIEW-2x.png]
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
CODE = 'NWE'
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
BRIGHT, DIM = 'T2', 't2'  # band cyan
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

# ---------------------------------------------------------------- shared sprites (from the CA generator)
def make_cone(w=27, h=18):
    """the Smokecap cone: ash flanks lit from the west, a glowing crater, a lava seam"""
    rows = []
    for j in range(h):
        hw = 3.2 + (w / 2.0 - 3.2) * (j / (h - 1.0)) ** 0.9
        row = ''
        for i in range(w):
            dx = i - (w - 1) / 2.0
            if abs(dx) > hw + 0.5:
                row += '.'
            elif abs(dx) > hw - 0.6 or j == h - 1 or j == 0:
                row += 'k'
            elif j == 1:
                row += 'h' if abs(dx) < 1.5 else 'r'
            elif j == 2 and abs(dx) < hw - 1.5:
                row += 'R'
            elif j < 11 and abs(dx - (1 + j * 0.25)) < 0.6:
                row += 'r' if j < 7 else 'R'
            elif dx < -hw * 0.45:
                row += 'A' if (i + j) % 4 else 'a'
            elif dx < hw * 0.15:
                row += 'a' if (i * 3 + j) % 7 else 'A'
            else:
                row += '3' if (i + j) % 5 else '2'
        rows.append(row)
    return rows


CONE = make_cone(31, 21)
CONE_S = make_cone()
BRAZIER = ['kkkkk', 'k222k', '.kak.', '..a..', '..A..', '.kAak', 'kkkkk']
WAYSTONE = ['.kk.', 'kAak', 'kAak', 'kaak', 'kkkk']
GRANARY = ['....kkk....', '..kkSsSkk..', '.kSsSsSsSk.', 'kSsSsSsSsSk', 'kkkkkkkkkkk', '.kBBbBBBbk.',
           '.kBbBBBBbk.', '.kBBBkkBbk.', '.kBBBk1Bbk.', '.kBbBk1Bbk.', '.kkkkkkkkk.']
AMARANTH = ['.r.', 'rRr', '.R.', '.d.']
MAIZE = ['.y.', 'yg.', '.gd', 'dg.', '.g.', '.d.']
MAIZE_S = ['y.', 'gd', 'dg', '.g']
SAGUARO = ['...kk...', '..kGgk..', 'k.kGgk.k', 'GkkGgkkg', 'GgGGgggd', 'kkkGgkkk', '..kGgk..', '..kGgk..', '..kkkk..']
SAGUARO_S = ['..k..', '.kGk.', 'kkGkk', 'GgGgg', 'kkGkk', '.kGk.', '.kkk.']
PALM = ['.kkkkk.', 'kGGgggk', 'Gk.b.kg', '...b...', '...B...', '..bB...', '..kkk..']
TALLGRASS = ['S.s', 'g.S', 'gdg', '.d.']
CEIBA = {'g': 'GM', 'G': 'T1', 'd': 'GK', 'b': 'AL', 'B': 'WH'}
REDROCK = {'A': 'SN', 'a': 'RE', '1': 'RK'}
OBSIDIAN = {'A': 'D4', 'a': 'D2', '1': 'K'}

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

# ---------------------------------------------------------------- NWE sprites (Mistmoor)
LET.update({'U': 'WL', 'u': 'WA', 'z': 't2', 'q': 'T2'})
WINDMILL = ['kk.......kk', 'kck.....kck', '.kck...kck.', '..kckAkck..', '...kkAkk...', '..kckBkck..', '.kck.B.kck.',
            'kck.kBk.kck', 'kk.kBbBk.kk', '...kBbBk...', '...kbBbk...', '..kBbbBbk..', '..kbB1Bbk..', '..kBb1bBk..',
            '..kkkkkkk..']
HEDGE = ['.kkkkkkkkkk.', 'kGdGgdGgdGdk', 'kdgddgddgddk', '.kkkkkkkkkk.']
HEDGE_S = ['.kkkkkk.', 'kGdGgdGk', 'kdgddgdk', '.kkkkkk.']
LEYSTONE = ['.kqk.', '.kAk.', 'kAAak', 'kAa1k', 'kkkkk']
MENHIR = ['..k..', '.kqk.', '.kAk.', 'kAAak', 'kAa1k', 'kAa1k', 'kAaak', 'kAa1k', 'kAa1k', 'kkkkk']
BEACON_S = ['kkkkk', 'kmMmk', '.kAk.', '.kak.', 'kAaak', 'kkkkk']
HEATHER = ['p.P.p', 'dpdpd']
HEATHER_S = ['P.p', 'dpd']
ICE = ['..k..', '.kwk.', '.kwUk', 'kwUUk', 'kwUuk', 'kkkkk']
ICE_S = ['.k.', 'kwk', 'kUk', 'kkk']
SEASTACK = ['.kk..', 'kAak.', 'kAa1k', 'kaa1k', 'ka11k', 'kkkkk']
STACKROCK = {'A': 'AL', 'a': 'AS', '1': 'D3'}
LONGBOAT = ['..k......', '..b.....k', 'kkbkkkkbk', 'kBbBbBbBk', '.kkkkkkk.']
VENT = ['.k...k.', 'kok.kok', 'kroRork', 'kkkkkkk']
OLIVE = {'g': 'MD', 'G': 'MY', 'd': 't1'}
VINES = ['g.d.g.d.g', 'bkbkbkbkb']
SALT = ['.w.', 'wUw', 'kwk']
SALT_S = ['w', 'U']
PILLAR = ['.kk.', 'kqzk', 'kkkk', 'kAak', 'kAak', 'kA1k', 'kA1k', 'kkkk']
CRAB_ROCK = {'A': 'AS', 'a': 'D4', '1': 'D2'}
TURTLE = ['.kk.', 'kGgk', 'kgdk', '.kk.']
SHELL = ['.P.', 'PpP']


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
    fjord = np.zeros((H, W), bool)    # Fjordfang: black water
    mere = np.zeros((H, W), bool)     # Foghorn Mere
    lagoon = np.zeros((H, W), bool)   # Turtle Lagoon: warm, the brightest water (islets under its keeps)
    KEY = {'downs': 'downs', 'wood': 'wood', 'ley_shelf': 'ley', 'fells': 'fells', 'cliffs': 'scree',
           'shore': 'olive', 'marsh': 'marsh', 'birchwood': 'birch'}
    frost_x = None
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        t = b['type']
        note = b.get('note', '')
        if b['shape'] == 'polygon':
            s = blur(poly_mask(b['points']).astype(float), 5 if t != 'water' else 1)
            m = s + (0.75 if t != 'water' else 0.25) * (n - 0.5) > 0.5
        else:
            e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
            m = e + 0.35 * (n - 0.5) < 1
        if t == 'water':
            if 'Fjord' in note:
                fjord |= m
            elif 'Turtle' in note:
                lagoon |= m
            else:
                mere |= m
            continue
        k = 'cold' if (t == 'fells' and b['shape'] == 'ellipse') else KEY.get(t)
        if k:
            zmask.setdefault(k, np.zeros((H, W), bool))
            zmask[k] |= m
    for key in ['wood', 'ley', 'fells', 'scree', 'olive', 'marsh', 'birch', 'downs', 'cold']:
        if key in zmask:
            zone[zmask[key] & F] = key
    zone[lagoon & F] = 'isle'
    # the beck: from Fernhollow Wood under the Footbridge to Foghorn Mere; the tidal creek: fjord -> Sea-cave
    fb = [p for p in P['props'] if p['kind'] == 'footbridge']
    fbx, fby = (fb[0]['x'], fb[0]['y']) if fb else (102, 127)
    beck_px = raster([(fbx - 2, fby - 27), (fbx + 1, fby - 13), (fbx, fby), (fbx + 2, fby + 21), (fbx + 2, fby + 43),
                      (fbx - 3, fby + 59), (fbx - 14, fby + 68)])
    beck = pixmask(beck_px, 1)
    creek_px = raster([(201, 217), (190, 214), (180, 213), (172, 212)])
    creek = pixmask(creek_px, 1)

    RAMPS = {
        'base': ['t1', 'GK', 'GK', 'GM'], 'downs': ['GK', 'GK', 'GM', 'GM'], 'wood': ['S2', 't1', 't1', 'GK'],
        'ley': ['GK', 'GM', 'GM', 'MY'], 'fells': ['D3', 'AS', 'AS', 'AL'], 'cold': ['t2', 'AS', 'AL', 'AL'],
        'scree': ['S4', 'S6', 'AS', 'AL'], 'olive': ['S5', 'S6', 'SD', 'SN'], 'marsh': ['t1', 't1', 'GK', 'GM'],
        'birch': ['t1', 'GK', 'GK', 'GM'], 'isle': ['SD', 'SD', 'SN', 'SN'],
    }
    BIAS = {'base': 0.0, 'downs': 0.10, 'wood': -0.10, 'ley': 0.04, 'fells': 0.02, 'cold': 0.04, 'scree': 0.02,
            'olive': 0.06, 'marsh': -0.04, 'birch': -0.04, 'isle': 0.12}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.12 + 0.44 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.26 * np.exp(-(dt / 85.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.20 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    lv = lightv + np.where(keep_m, 0, 0.14 * (tex - 0.5))
    gi = np.floor(lv * 4 - 0.4 + (BAY - 0.5) * 0.9).astype(int).clip(0, 3)
    gi = np.where(keep_m, np.clip(gi, 1, 2), gi)   # plain floor in the keep circles
    for zname, ramp in RAMPS.items():
        zm = F & (zone == zname)
        for i in range(4):
            paint(zm & (gi == i), ramp[i])
    inner = F & ~ero4(F)
    for zname, ramp in RAMPS.items():
        paint(inner & (zone == zname), ramp[0])
    # texture fades out over 7 px round every keep circle (dithered), so the plain discs have soft edges
    kd = np.full((H, W), 99.0)
    for (_, x, y, r) in keeps:
        kd = np.minimum(kd, np.hypot(xx - x, yy - y) - r)
    busyok = F & ~keep_m & (depth > 2) & (kd > BAY2 * 7)
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    # Hedgerow Downs: a patchwork of fields edged by dark hedge lines, a few lime flecks
    dz = busyok & (zone == 'downs')
    fn = vnoise(13, 201)
    fld = (np.abs(np.sin(fn * 9.0)) < 0.09) & ~pixmask(road_px, 3)
    paint(dz & fld, 't1')
    paint(dz & np.roll(fld, -1, axis=0) & ~fld & ((xx + yy) % 2 == 0), 'GM')
    paint(dz & (vnoise(1, 202) > 0.95) & (gi >= 2), 'T1')
    # peat floor: dark moss flecks
    bz = busyok & (zone == 'base')
    paint(bz & (vnoise(1, 203) > 0.90) & ((xx + yy) % 2 == 0), 't1')
    # Fernhollow Wood: dark fronds; ley shelf: pale grass flecks
    wz = busyok & (zone == 'wood')
    paint(wz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 'GK')
    paint(busyok & (zone == 'ley') & (vnoise(1, 204) > 0.88) & ((xx + yy) % 2 == 0), 'MY')
    paint(busyok & (zone == 'ley') & (vnoise(1, 212) > 0.94), 'MD')
    paint(busyok & (zone == 'ley') & (vnoise(1, 205) > 0.95), 'GK')
    # fells + the cold shoulder: stone cracks, rime dither, frost sparkle
    sn = vnoise(5, 61)
    crk = (np.abs(np.sin((xx * 0.55 + yy + 14 * sn) / 3.2)) < 0.16) & (vnoise(3, 62) > 0.45)
    for zname in ('fells', 'cold', 'scree'):
        ramp = RAMPS[zname]
        stz = busyok & (zone == zname)
        paint(stz & crk & (gi >= 1), ramp[0])
        paint(stz & dil4(crk) & ~crk & (yy % 2 == 0) & (gi >= 1) & (vnoise(1, 63) > 0.55), ramp[3])
    for zname in ('fells', 'cold'):
        fz = busyok & (zone == zname)
        rime = vnoise(6, 64) > 0.60
        paint(fz & rime & (BAY > 0.55) & (gi >= 1), 'AL')
        paint(fz & rime & (BAY > 0.85) & (gi >= 2), 'WH')
        paint(fz & ~rime & (vnoise(1, 65) > 0.975), 'WL')
    # heather on the lee (south) slopes of the fells
    lee = busyok & (zone == 'fells') & (vnoise(9, 206) > 0.58) & (yy > 170)
    paint(lee & (vnoise(1, 207) > 0.90) & ((xx + yy) % 2 == 0), 'PK')
    # Screefall: warm grey scree speckle and ledges
    scz = busyok & (zone == 'scree')
    ledge = ((yy + (xx // 19) * 3) % 9 == 0) & (vnoise(5, 136) > 0.35)
    paint(scz & ledge, 'S4')
    paint(scz & np.roll(ledge, 1, axis=0) & ~ledge & ((xx + yy) % 2 == 0), 'AL')
    paint(scz & (vnoise(1, 208) > 0.93), 'SD')
    # Olivewhistle breath: dry terraces (S6 lips), sand grit
    oz = busyok & (zone == 'olive')
    terr = ((yy + xx // 17) % 7 == 0) & (vnoise(6, 133) > 0.38)
    paint(oz & terr, 'S5')
    paint(oz & np.roll(terr, 1, axis=0) & ((xx + yy) % 2 == 0), 'SN')
    paint(oz & (vnoise(1, 209) > 0.95), 'S5')
    # Stork Marsh + birch wood: brackish teal pools
    for zname, sd, th in (('marsh', 137, 0.60), ('birch', 138, 0.78)):
        zz = busyok & (zone == zname)
        pool = zz & (vnoise(4, sd) > th)
        pool = ero4(dil4(pool)) & zz
        paint(pool, 'ND')
        paint(pool & ~dil4(~pool) & (BAY > 0.55), 't2')
        paint(pool & ~dil4(~pool) & (yy % 3 == 0) & ((xx + yy) % 4 == 0), 'NW')
        paint(dil4(pool) & ~pool & zz, 't1')
    paint(busyok & (zone == 'birch') & (vnoise(1, 210) > 0.94), 'AL')
    # mist: FOG dither lying low on the floor (thicker to the south and in the wood)
    fogd = np.clip((yy - 140) / 110.0, 0, 1) * 0.9 + np.where(zone == 'wood', 0.35, 0)
    fogd = fogd * np.clip((vnoise(17, 211) - 0.25) * 2.0, 0, 1)
    fogz = busyok & ((zone == 'base') | (zone == 'wood') | (zone == 'fells') | (zone == 'downs') | (zone == 'marsh'))
    paint(fogz & (fogd > BAY + 0.30) & ((xx + yy) % 2 == 0), 'FOG')
    # rim: K outline, band-colour rim light (cyan), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')
    # past the two tier gates (east of the line through them) the rim and halo turn gold (tier 3 beyond)
    gates = {p['kind']: (p['x'], p['y']) for p in P['props'] if p['kind'].startswith('gate_')}
    g1 = gates.get('gate_fell_pass', (322, 76)); g2 = gates.get('gate_smugglers_tide', (286, 140))
    bx = np.where(yy < g1[1], g1[0], np.where(yy < g2[1], g1[0] + (g2[0] - g1[0]) * (yy - g1[1]) / float(g2[1] - g1[1]),
                                               g2[0] - 0.18 * (yy - g2[1])))
    gold_side = (xx - bx) > (BAY - 0.5) * 16
    for src, dst in ((BRIGHT, 'T3'), (DIM, 't3')):
        hit = ~F & gold_side & (img == np.array(PAL[src], np.uint8)).all(-1)
        paint(hit, dst)
    # the Maplewold mouth: a few px of green rim where the band behind ends
    XBAND = {'NA': ('T1', 't1')}
    for e in L['exits']:
        if e['to'] not in XBAND:
            continue
        b_, d_ = XBAND[e['to']]
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        dd = np.hypot(xx - ex, yy - ey)
        nr = ~F & ((dd < 26) | ((dd < 40) & (BAY > (dd - 26) / 14.0)))
        for src, dst in ((BRIGHT, b_), (DIM, d_)):
            hit = nr & (img == np.array(PAL[src], np.uint8)).all(-1)
            paint(hit, dst)

    # ------------------------------------------------ 4. WATERS: Foghorn Mere, Turtle Lagoon, Fjordfang, beck, creek
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on dry ground (islets in the lagoon)
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 1 + 2.5 * isl
        if sid in slots and slots[sid]['type'] == 'stop':
            keep_wet |= disk(x, y, r + 6)  # the water stops short of the road stops
    band = pixmask(road_px, 4)
    big = (lagoon | mere | fjord) & F & (depth > 2)
    water = big & ~keep_wet & ~band
    water = ero4(dil4(water)) & ~keep_wet & F & ~band
    thin = (beck | creek) & F & ~keep_wet & ~band & (depth > 1)
    occ_water = water | thin
    black = occ_water & (fjord | creek)
    warm = occ_water & lagoon
    # banks: sand round the lagoon, wet peat round the mere and beck, dark rock on the fjord
    sh = dil8(occ_water) & ~occ_water & F & ~keep_m & ~road_m
    paint(sh & dil8(warm), 'SN')
    paint(sh & dil8(water & mere), 't1')
    paint(sh & dil8(thin & beck), 't1')
    paint(sh & dil8(black), 'D3')
    sh2 = dil8(sh) & ~sh & ~occ_water & F & ~keep_m & ~road_m
    paint(sh2 & dil8(dil8(warm)) & (BAY > 0.5), 'SD')
    paint(sh2 & dil8(dil8(black)) & (BAY > 0.5), 'AS')
    paint(occ_water, 'WA')
    paint(warm & (BAY > 0.62), 'WL')
    deep = ero4(ero4(water))
    paint(deep & ~warm & ~black & (BAY > 0.45), 't2')
    paint(ero4(deep) & ~warm & ~black & (BAY > 0.2), 't2')
    paint(ero4(deep) & warm & (BAY > 0.8), 't2')
    paint(black, 'D2')
    paint(black & ~ero4(black) & (BAY > 0.5), 'D3')
    paint(black & ero4(black) & (vnoise(1, 140) > 0.93), 'WL')       # glints on the black water
    paint(black & ero4(black) & ((yy % 5 == 0) & ((xx + yy) % 4 == 0)), 'D4')
    foam = (water & ~black) & dil8(~occ_water) & ~grow(~F, 3)
    paint(foam & ((xx + yy) % 2 == 0), 'WL')
    paint(water & ~black & ~deep & (yy % 4 == 1) & (np.sin(xx / 3.0 + yy) > 0.8), 'WL')
    paint(thin & ~black & ((xx + yy) % 3 == 0), 'WL')

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    protect = keep_pad | near_road | root_corr | dil4(occ_water)
    free = F & ~protect & (depth >= 2)
    free_wet = F & ~(keep_pad | near_road | root_corr) & (depth >= 1)
    wet_free = occ_water & ~(keep_pad | near_road | root_corr) & ~grow(~occ_water, 1)
    occ = np.zeros((H, W), bool)
    placed = []

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
        occ[y0 - 1:y0 + h + 1, x0 - 1:x0 + w + 1] |= smask(rows, 1)
        placed.append((y, x, rows, over))
        return True

    def near(tx, ty, rows, over=None, maxd=12, pad=1, where=None):
        best = None
        for y in range(max(4, ty - maxd), min(H - 2, ty + maxd + 1)):
            for x in range(max(4, tx - maxd), min(W - 4, tx + maxd + 1)):
                d = (x - tx) ** 2 + (y - ty) ** 2
                if d > maxd * maxd or (best and d >= best[0]):
                    continue
                w, h = spr_size(rows)
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
            if try_place(x, y, rows, over, pad):
                got += 1
        return got

    def floor_top(x):
        col = np.nonzero(F[:, x])[0]
        return int(col[0]) if len(col) else None

    def glow(cx_, cy_, rad, col, extra=None, thr=0.12):
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + thr) & ((xx + yy) % 2 == 0), col)

    def patch(x, y, rx, ry, fn_, tries=((0, 0), (2, 1), (-2, 1), (0, 3), (3, -2), (-3, -1), (5, 2), (-5, 2), (0, -4))):
        hard_ = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
        for (dx, dy) in tries:
            gx, gy = x + dx, y + dy
            sl = (slice(gy - ry - 1, gy + ry + 2), slice(gx - rx - 1, gx + rx + 2))
            if hard_[sl].all() and not occ[sl].any():
                gm = (((xx - gx) / (rx + 0.5)) ** 2 + ((yy - gy) / (ry + 0.5)) ** 2) < 1
                fn_(gm, gx, gy)
                occ[sl] = True
                return (gx, gy)
        return None

    log = []
    beacon_at = None
    vent_at = None
    plume_at = None
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
        if k == 'hanging_roots':
            got = 'ceiling'   # drawn with the root ceiling (thickest over the Market)
        elif k == 'windmill':
            got = near(x, y + 7, WINDMILL, None, 12, 0, where=hard)
        elif k == 'seed_bed_barley_heather':
            def bed(gm, gx, gy):
                paint(gm, 'S5')
                paint(gm & ((yy - gy) % 2 == 0), 'GD')                 # barley rows
                paint(gm & ((yy - gy) % 2 == 0) & ((xx + yy) % 3 == 0), 'SN')
                rim_ = gm & ~ero4(gm)
                paint(rim_, 'GK')
                paint(rim_ & ((xx + yy) % 2 == 0), 'PK')               # heather edging
                paint(rim_ & ((xx * 3 + yy) % 5 == 0), 'PL')
            got = patch(x, y, 8, 4, bed)
        elif k == 'hedgerow':
            got = cluster(x, y, [(HEDGE, HAZEL), (HEDGE_S, HAZEL)], n, 14, 0, where=hard)
        elif k == 'footbridge':
            got = 'bridge'   # drawn over the beck after the roads
        elif k == 'maple':
            got = cluster(x, y, [(TREE, MAPLE), (TREE, MAPLE_R), (TREE_S, MAPLE)], n, 8, 0, where=hard)
        elif k == 'ley_stone':
            got = cluster(x, y, [(LEYSTONE, None)], n, 9, 1, where=hard)
        elif k == 'menhir':
            got = near(x, y + 4, MENHIR, None, 10, 1, where=hard)
        elif k == 'fairy_mushrooms':
            def ring(gm, gx, gy):
                rr_ = np.hypot((xx - gx) / 1.0, (yy - gy) * 1.6)
                rg = (np.abs(rr_ - 5.5) < 0.6) & ((xx + yy) % 2 == 0)
                paint(rg, 'WH')
            got = patch(x, y, 7, 4, ring)
            if got:
                for (ox, oy) in ((-6, 0), (5, -2), (1, 3)):
                    spr(got[0] + ox, got[1] + oy, ['.k.', 'kwk', '.c.'])
        elif k == 'hazel_tree':
            got = cluster(x, y, [(TREE, HAZEL), (BIGTREE, HAZEL), (TREE_S, HAZEL)], n, 11, 0, where=hard)
        elif k == 'brine_pool':
            def brine(gm, gx, gy):
                paint(gm, 'WH'); paint(ero4(gm), 'WL'); paint(ero4(ero4(gm)), 'WA')
                paint(ero4(ero4(gm)) & ((xx + yy) % 3 == 0), 'WL')
                paint(gm & ~dil4(~gm) & ~ero4(gm) & ((xx + yy) % 2 == 0), 'AL')
            got = patch(x, y, 5, 3, brine)
        elif k == 'twin_beacon':
            got = beacon_at = near(x, y + 3, BEACON, None, 12, 0, where=hard)
            if got:
                n2_ = near(got[0] + 9, got[1] + 1, BEACON_S, None, 6, 0, where=hard)
        elif k == 'heather':
            got = cluster(x, y, [(HEATHER, None), (HEATHER_S, None)], n * 2, 12, 0, where=hard)
        elif k == 'ice_stalagmite':
            got = cluster(x, y, [(ICE, None), (ICE_S, None)], n, 10, 0, where=hard)
        elif k == 'rim_pass_door':
            got = near(x, y + 4, DOOR, None, 12, 0, where=hard)
        elif k == 'reeds':
            got = cluster(x, y, [(CATTAIL, None), (REED, None), (CATTAIL, None)], n + 2, 10, 0, where=free_wet)
        elif k == 'sea_stack':
            got = near(x, y, SEASTACK, STACKROCK, 10, 0, where=wet_free | (hard & dil8(occ_water)))
        elif k == 'longboat':
            got = near(x, y, LONGBOAT, None, 12, 0, where=wet_free | (hard & dil8(occ_water)))
        elif k == 'lava_vent':
            got = vent_at = near(x, y, VENT, None, 10, 0, where=hard)
        elif k == 'scree_boulders':
            got = cluster(x, y, [(CRAG, WARMSTONE), (STONE, WARMSTONE), (PEBBLE, WARMSTONE)], n, 11, 0, where=hard)
        elif k == 'olive_tree':
            got = cluster(x, y, [(TREE, OLIVE), (TREE_S, OLIVE)], n, 10, 0, where=hard)
        elif k.startswith('gate_'):
            got = 'posts'   # drawn on the road after the trunks
        elif k == 'steam_plume':
            got = plume_at = (x, y)
        elif k == 'vine_terrace':
            got = cluster(x, y, [(VINES, None)], n, 14, 0, where=hard)
        elif k == 'turtle_rock':
            got = cluster(x, y, [(TURTLE, None), (STONE, CRAB_ROCK), (TURTLE, None)], n, 12, 0, where=wet_free | hard)
        elif k == 'birch':
            got = cluster(x, y, [(TREE, BIRCH), (TREE_S, BIRCH)], n, 11, 0, where=hard)
        elif k == 'salt_crystals':
            got = cluster(x, y, [(SALT, None), (SALT_S, None)], n, 9, 0, where=hard)
        else:
            got = 'skip'
        log.append((k, x, y, got))
    # dressing at the three mouths: maples at the Maplewold, olives on the west lip of the south mouth,
    # birches both sides of the Birchbramble mouth
    hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['to'] == 'NA':
            for (tx, ty) in ((ex + 18, ey - 24), (ex + 20, ey + 26), (ex + 30, ey - 30)):
                near(tx, ty, TREE if ty < ey else TREE_S, MAPLE_R if ty > ey else MAPLE, 8, 0, where=hard)
        elif e['to'] == 'SE':
            for (tx, ty) in ((ex - 24, ey - 12), (ex - 32, ey - 18)):
                near(tx, ty, TREE_S, OLIVE, 8, 0, where=hard)
        elif e['to'] == 'EE':
            for (tx, ty) in ((ex - 14, ey - 26), (ex - 16, ey + 28), (ex - 26, ey - 22), (ex - 24, ey + 30)):
                near(tx, ty, TREE if ty < ey else TREE_S, BIRCH, 8, 0, where=hard)

    # biome scatter: nothing tall on the Downs (the three roads must read); the wood is dense and dark
    zf = lambda z: free & (zone == z)
    scatter([(TREE, HAZEL), (BIGTREE, HAZEL), (TREE_S, HAZEL), (FERN, HAZEL), (FERN_S, HAZEL), (BUSH, HAZEL),
             (TREE, JUNGLE), (FERN, None), (STUMP, None)], 230, zf('wood'), pad=0, tries=9000)
    scatter([(HEDGE_S, HAZEL), (BUSH, HAZEL), (FERN_S, HAZEL)], 22, zf('downs'), pad=2)
    scatter([(BUSH, HAZEL), (FERN_S, HAZEL), (STUMP, None), (PEBBLE, None)], 26, zf('base'), pad=1)
    scatter([(PEBBLE, None), (STONE, None)], 8, zf('ley'), pad=2)
    scatter([(STONE, FROSTSTONE), (PEBBLE, FROSTSTONE), (CRAG, FROSTSTONE), (PINE, SNOWPINE), (HEATHER, None),
             (PEBBLE, FROSTSTONE)], 46, zf('fells'), pad=0)
    scatter([(STONE, FROSTSTONE), (PEBBLE, FROSTSTONE)], 6, zf('cold'), pad=1)
    scatter([(CRAG, WARMSTONE), (STONE, WARMSTONE), (PEBBLE, WARMSTONE), (STONE, None)], 34, zf('scree'), pad=0)
    scatter([(TREE_S, OLIVE), (VINES, None), (TREE, OLIVE), (PEBBLE, WARMSTONE)], 30, zf('olive'), pad=0)
    scatter([(CATTAIL, None), (REED, None), (CATTAIL, None), (BUSH, HAZEL)], 40, zf('marsh'), pad=0)
    scatter([(TREE, BIRCH), (TREE_S, BIRCH), (BUSH, HAZEL), (FERN_S, HAZEL), (TREE, BIRCH)], 60, zf('birch'), pad=0)
    shore_ = dil8(dil8(occ_water)) & ~occ_water & free
    scatter([(REED, None), (CATTAIL, None)], 18, shore_ & ((zone == 'base') | (zone == 'wood') | (zone == 'downs')), pad=0)
    scatter([(SHELL, None), (PEBBLE, WARMSTONE)], 8, shore_ & ((zone == 'isle') | (zone == 'olive')), pad=0)
    # flowers: heather pink on the fells, white wood anemones in the wood, flax blue on the downs
    fl = free & ~occ & ~dil4(occ)
    paint(fl & (zone == 'wood') & (vnoise(1, 85) > 0.96) & (vnoise(6, 86) > 0.5), 'WH')
    paint(fl & (zone == 'downs') & (vnoise(1, 87) > 0.975) & (vnoise(8, 88) > 0.5), 'T2')

    # lanterns beside the trunks
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
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'GD')
    # the Forge's lava vent: the only orange on the map; the Sauna: a steam plume under a green-white aurora
    if vent_at:
        glow(vent_at[0], vent_at[1] - 2, 11, 'T4')
        glow(vent_at[0], vent_at[1] - 2, 6, 'RD', thr=0.3)
    if plume_at:
        px_, py_ = plume_at
        glow(px_ - 6, py_ - 8, 16, 'ND', thr=0.05)
        glow(px_ - 6, py_ - 10, 9, 'NW', thr=0.25)
        st = ~keep_pad & ~near_road & ~root_corr & F
        for j in range(16):
            cx_ = px_ + int(round(2 * math.sin(j / 3.0)))
            wdt = 1 + j // 6
            for ox in range(-wdt, wdt + 1):
                X, Y = cx_ + ox, py_ - j
                if 0 <= X < W and 0 <= Y < H and st[Y, X] and (X + Y + j) % 2 == 0:
                    put(X, Y, 'WH' if j < 9 else 'AL')
        spr(px_, py_ + 2, ['.kkk.', 'kAa1k', 'kkkkk'])
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
        ln_, th_ = RS.randint(12, 30), RS.choice([1, 2, 2, 3])
        if frost_x and frost_x[0] - 4 <= x0 <= frost_x[1] + 4:
            continue  # icicles hang over the frost pocket instead
        root(x0, ln_, th_, SEED * 100 + k)
    for k in range(10):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S, CYANCAP if k % 3 == 0 else None)
    for k in range(6):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'PL', 'u': 'T5', 'n': 't5'} if k % 2 else None)

    # the Footbridge: plank rails where the Maplewold road crosses the beck (the road line runs over it)
    cross = road_m & dil4(dil4(beck))
    if cross.any():
        cy_, cx_ = [int(round(v.mean())) for v in np.nonzero(cross)]
        for X in range(cx_ - 5, cx_ + 6):
            for s in (-1, 1):
                Y = cy_ + s * 4
                put(X, Y, 'S6' if X % 2 else 'S5')
                put(X, Y + s, 'K')
                if X in (cx_ - 5, cx_ + 5):
                    put(X, Y - s, 'K'); put(X, Y + 2 * s, 'K')
    # the two tier gates: stone posts either side of the trunk, a cyan seal stone on each
    for gk, (gx, gy) in sorted(gates.items()):
        best = None
        for px in roads:
            for i, (x, y) in enumerate(px):
                d = (x - gx) ** 2 + (y - gy) ** 2
                if best is None or d < best[0]:
                    best = (d, px, i)
        _, px, i = best
        a = px[max(0, i - 4)]; b = px[min(len(px) - 1, i + 4)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / ln, dx / ln
        x, y = px[i]
        for s in (-1, 1):
            X = int(round(x + s * 7 * nx)); Y = int(round(y + s * 7 * ny))
            spr(X, Y + 4, PILLAR)

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
    for sid, nm in ((188, 'FROST TOAD BARROW'), (194, 'CINDER WYRM FORGE'), (185, 'STANDING STONES'), (192, 'LABYRINTH ISLE'), (187, 'SEA-CAVE'), (163, 'LIGHTHOUSE')):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-NWE.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-NWE.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-NWE.png'))
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
