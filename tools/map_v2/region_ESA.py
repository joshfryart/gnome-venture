#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for ESA "Thornacre Savanna" (band orange, Lv 35-45).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built on the
SA / CA generators: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside
with a dithered orange halo and an orange rim light (the Rainroot mouth takes the gold of tier 3
behind it), biome ground (the gold-grass Thornacre Plains as the default floor, the Red Clay Heart
with pale teff contour rows, the dark Greatcanopy fringe with lianas, the stepped red Coffeecloud
terraces under the white-capped Snowcrown massif, the pale Rift soda lakes with a pink flamingo rim,
the grey-green fynbos heath with burnt fire trails and protea dots, the red Bonedry Karoo), landmark
props (great baobab with a lantern in its trunk, king protea garden, teff terraces and threshing
floor, Seal waystone, flat thorn acacias with long east shadows, the migration herd and its track,
drum ring, liana bridges, coffee terraces with drying rack and pot, papyrus jetty, lotus channel with
flower boats, thorn bomas, termite spires), glowing road trunks on the layout polylines and the three
exit tunnel mouths; a flat stone ceiling with termite-clay stalactites and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one or two flat tones, no sprites, no water, no texture); water never enters such a disc.

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_ESA.py [--layout layout-ESA.json] [--plan plan-ESA.json]
                                     [--out game/assets/img/scenes/map2-ESA.png] [--preview PREVIEW-2x.png]
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
CODE = 'ESA'
SEED = 11


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


# ---------------------------------------------------------------- ESA sprites (Thornacre Savanna)
LET.update({'U': 'WL', 'u': 'WA', 'z': 't2', 'D': 't1', 'v': 'T5', 'W': 'WH', '5': 'S5', '6': 'S6'})


def pad_rows(rows):
    w = max(len(r) for r in rows)
    return [r + '.' * (w - len(r)) for r in rows]


THORN = ['.kkkkkkkkk.', 'kddgdgdgddk', '.kkkkbkkkk.', '...kb.bk...', '....kbk....', '....kbk....', '....kkk....']
THORN_S = ['.kkkkkk.', 'kdgdgddk', '.kkbkkk.', '...bk...', '..kkk...']
THORN_W = pad_rows(['..kkkkkkkkkkk..', '.kddgdGgdgGgddk.', 'kdgdddkdddgdddk', '.kkkkkbkkbkkkk.', '.....kb.bk.....',
                    '......kbk......', '......kbk......', '......kkk......'])
ACACIA = {'g': 'GM', 'G': 'GD', 'd': 'GK'}          # olive crowns lit gold from the west
BAOBAB = pad_rows([
    '..kkkk....kkkk....kkk..',
    '.kGGggk..kGggdk..kGgdk.',
    'kGGgggdkkGgggddkkGggddk',
    'kGgggddkGggggdddkgggddk',
    '.kkgdkkbkkgddkkbkkddkk.',
    '...kkbBk..kbbk..kbbkk..',
    '.....kBbk.kBbk.kbk.....',
    '......kBbkkBbkkbk......',
    '.......kBbbBbbbbk......',
    '......kBBbbbbbb4k......',
    '.....kBBbbbbbbb44k.....',
    '....kBBbbbbbbbb444k....',
    '....kBBbbbbbbbbb44k....',
    '...kBBbbbkkkkbbb444k...',
    '...kBBbbkyyyykbb444k...',
    '...kBBbbkycyykbb444k...',
    '...kBBbbkyyyykbb444k...',
    '...kBBbbbkkkkbbb444k...',
    '...kBBbbbbbbbbbb444k...',
    '....kBbbbbbbbbbb44k....',
    '...kkBbbbbbbbbbb44kk...',
    '..kBBbkbbbbbbbbk444bk..',
    '.kkkkkkkkkkkkkkkkkkkkk.'])
BAOBAB_C = {'g': 'GM', 'G': 'T1', 'd': 'GK', 'B': 'AL', 'b': 'MY', '4': 'MD', 'y': 'GD', 'c': 'CR'}
SPIRE_T = ['..k..', '.kyk.', '.kek.', 'kheRk', 'kheRk', 'keeRk', 'kheRk', 'keRRk', 'kkkkk']
SPIRE_TS = ['.k.', 'kyk', 'keR', 'heR', 'kkk']
QUIVER = ['k.k.k', 'gkgkg', '.kAk.', '.kAk.', '.kak.', '.kkk.']
COFFEE = ['.kk.', 'kdrk', 'kgdk', '.kk.']
PROTEA = ['p.p', 'PcP', '.d.']
HEATH = ['.kk.', 'kgak', 'kkkk']
HEATH_C = {'g': 'GM', 'a': 'AS'}
PAPYRUS = ['G.g', '.g.', '.g.']
TUFT = ['y.s', 'S.y', '5y5']
GRASS_C = {'y': 'GD', 's': 'CR', 'S': 'SN', '5': 'S5'}
BONE = {'A': 'WH', 'a': 'AL'}
RACK = ['kkkkkkk', 'krRrRrk', 'b.....b', 'k.....k']
POT = ['.W.', '...', 'kek', 'eRe', 'kkk']
DRUM = ['kk', 'B6', 'kk']
BOAT = ['.p.', 'kBk']
SEALSTONE = ['..k..', '.kAk.', 'kAyak', 'kayak', 'kAyak', 'kAaak', 'kkkkk']
STACK_S = ['.kkk.', 'kAa1k', 'kssak', 'kaa1k', 'kkkkk']
REDSTACK = {'A': 'RH', 'a': 'RE', '1': 'RK', 's': 'SN'}
GOLDTUFT = ['y.y', 'yky', '.g.']

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
    # the low east wall is misty over the lakes: an extra fog bank outside it
    em = ~F & (outd > 3) & (xx > 440) & (yy > 100) & (yy < 200)
    paint(em & (vnoise(6, 19) > 0.45) & (BAY > 0.55), 'FOG')
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
    zone = np.full((H, W), 'grass', dtype=object)   # the Thornacre Plains grass is the default floor
    zmask = {}
    KEY = {'red_clay_teff': 'clay', 'savanna_grass': 'grass', 'canopy_fringe': 'canopy',
           'coffee_highland': 'coffee', 'rift_lake': 'lake', 'fynbos_heath': 'fynbos', 'red_sand_karoo': 'karoo'}
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
    # the canopy fringe fades into the grass by dither, not a hard edge
    if 'canopy' in zmask:
        cs = blur(zmask['canopy'].astype(float), 4)
        zmask['canopy'] = cs > 0.25 + 0.5 * BAY
    for key in ['grass', 'clay', 'karoo', 'coffee', 'canopy', 'fynbos', 'lake']:
        if key in zmask:
            zone[zmask[key] & F] = key

    RAMPS = {
        'grass': ['S5', 'SD', 'SD', 'SN'], 'clay': ['S4', 'RK', 'RE', 'RE'], 'canopy': ['t1', 't1', 'GK', 'GM'],
        'coffee': ['S4', 'RK', 'RE', 'S6'], 'lake': ['S6', 'SD', 'SN', 'SN'], 'fynbos': ['S4', 'GK', 'GK', 'GM'],
        'karoo': ['S5', 'RE', 'SD', 'SN'],
    }
    BIAS = {'grass': 0.06, 'clay': 0.06, 'canopy': -0.06, 'coffee': 0.0, 'lake': 0.10, 'fynbos': 0.10, 'karoo': 0.04}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.14 + 0.46 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.24 * np.exp(-(dt / 80.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.18 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    # plain discs sit at the mean tone of the textured ground round them (no pale or dark polka dots)
    kbias = np.where(zone == 'grass', 0.14, np.where((zone == 'lake') | (zone == 'karoo'), 0.06, np.where(zone == 'fynbos', 0.16, 0.0)))
    lv = lightv + np.where(keep_m, kbias, 0.14 * (tex - 0.5))
    gi = np.floor(lv * 4 - 0.4 + (BAY - 0.5) * 0.9).astype(int).clip(0, 3)
    gi = np.where(keep_m, np.clip(gi, 1, 3), gi)   # plain floor in the keep circles (two flat tones at most)
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
    # grass: gold 1 px wind streaks, AL glints, dry dark stems
    gz = busyok & (zone == 'grass')
    wind = (vnoise(1, 71) > 0.70) & ((yy % 3) == 0)
    streak = wind | np.roll(wind, 1, axis=1) | np.roll(wind, 2, axis=1) | np.roll(wind, 3, axis=1) | np.roll(wind, 4, axis=1)
    paint(gz & streak & (vnoise(3, 72) > 0.42), 'GD')
    paint(gz & streak & (vnoise(3, 72) <= 0.42) & (vnoise(3, 73) > 0.5), 'AL')
    paint(gz & (vnoise(1, 74) > 0.94) & (gi <= 2), 'S5')
    # red clay heart: pale gold teff in 1 px contour rows
    cz = busyok & (zone == 'clay')
    cont = np.sin((yy + 3.0 * np.sin(xx / 17.0) + 6 * vnoise(14, 90)) / 1.1)
    rows_ = (cont > 0.93)
    paint(cz & rows_ & ((xx // 2) % 4 != 3), 'AL')
    paint(cz & rows_ & ((xx // 2) % 4 != 3) & (vnoise(2, 91) > 0.55), 'CR')
    paint(cz & np.roll(rows_, -1, axis=0) & ~rows_, 'RK')
    # canopy fringe: dark fronds, sparse T1 highlights
    jz = busyok & (zone == 'canopy')
    paint(jz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    paint(jz & (vnoise(1, 66) > 0.975) & (gi >= 2), 'T1')
    # coffee highland: stepped terrace ledges
    oz = busyok & (zone == 'coffee')
    ledge = ((yy + (xx // 23) * 2) % 6 == 0) & (vnoise(5, 83) > 0.25)
    paint(oz & ledge, 'RK')
    paint(oz & np.roll(ledge, 1, axis=0) & ~ledge, 'RH')
    # fynbos: GM dithered with S4, grey AS twigs
    fz = busyok & (zone == 'fynbos')
    paint(fz & ((xx + yy) % 2 == 0) & (vnoise(4, 92) > 0.30), 'AS')
    paint(fz & ((xx + yy) % 2 == 1) & (vnoise(4, 92) > 0.70) & (gi >= 2), 'S6')
    paint(fz & (vnoise(1, 93) > 0.93), 'AL')
    # karoo: red sand ripples, bone pebbles, greening toward the Rainroot mouth
    kz = busyok & (zone == 'karoo')
    rip = np.abs(np.sin((yy * 1.3 + 4 * np.sin(xx / 9.0) + 6 * vnoise(8, 69)) / 1.6)) > 0.95
    paint(kz & rip & (gi >= 2), 'RE')
    paint(kz & (vnoise(1, 79) > 0.97), 'WH')
    greenish = kz & (BAY < np.clip((xx - 360) / 90.0, 0, 0.7)) & (vnoise(1, 94) > 0.6)
    paint(greenish, 'GK')
    paint(greenish & (vnoise(1, 95) > 0.7), 'GM')
    # lake zone dry ground: white soda crust flecks
    lz = busyok & (zone == 'lake')
    paint(lz & (vnoise(1, 96) > 0.90), 'WH')
    paint(lz & (vnoise(1, 97) > 0.93), 'CR')

    # Emberhollow: a scorched ochre patch round the village (the 14 disc stays one flat tone)
    if 116 in spread:
        ex_, ey_ = spread[116]
        de = np.hypot(xx - ex_, yy - ey_) + 4 * (vnoise(3, 98) - 0.5)
        ring = busyok & (de < 26) & (de > 14) & ~road_m
        paint(ring & (BAY < np.clip((26 - de) / 10.0, 0, 1)), 'S6')
        paint(ring & (BAY < np.clip((22 - de) / 10.0, 0, 1)) & ((xx + yy) % 2 == 0), 'S4')
        paint(ring & (vnoise(1, 99) > 0.95), 'T4')

    # rim: K outline, band-colour rim light (orange T4), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')
    # the cross-band mouth: the Rainroot mouth takes the gold of tier 3 behind it
    XBAND = {'SA': ('T3', 't3')}
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

    # ------------------------------------------------ 4. WATERS: the rift soda lakes, the lotus channel, the reed pool
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on dry ground
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2.5 * isl
    band = pixmask(road_px, 5)
    ln = vnoise(4, 151)
    lakes = np.zeros((H, W), bool)
    for (cx_, cy_, rx_, ry_) in ((350, 156, 24, 11), (424, 146, 30, 14), (438, 174, 16, 7), (372, 172, 10, 5)):
        lakes |= np.hypot((xx - cx_) / rx_, (yy - cy_) / ry_) + 0.45 * (ln - 0.5) < 1
    lakes &= zmask.get('lake', np.ones((H, W), bool)) & (depth > 3)
    chan_pts = [(361, 14), (363, 24), (368, 31), (375, 36), (381, 40)]
    chan = pixmask(raster(chan_pts), 1) | pixmask(raster(chan_pts[:3]), 2)
    pool = (np.hypot((xx - 96) / 9.0, (yy - 37) / 4.5) + 0.3 * (ln - 0.5) < 1)
    water = (lakes | pool) & F & ~keep_wet & ~band
    water = ero4(dil4(water)) & F & ~keep_wet & ~band
    water &= ~dil4(ero4(ero4(~water)))   # drop slivers
    chan_w = chan & ~band & ~disk(*spread.get(218, (-99, -99)), 15) & ~disk(328, 16, 19)
    occ_water = water | (chan_w & F)
    lk = water & ~pool
    # soda crust and pink flamingo rim round the lakes
    sh1 = dil8(lk) & ~lk & F & ~keep_m
    sh2 = dil8(dil4(sh1)) & ~sh1 & ~lk & F & ~keep_m
    paint(sh2 & (BAY > 0.35), 'WH')
    paint(sh2 & (BAY <= 0.35), 'CR')
    paint(sh1 & ((xx + yy) % 2 == 0), 'PK')
    paint(sh1 & ((xx + yy) % 2 == 1), 'PL')
    paint(lk, 'WL')
    paint(lk & ero4(lk) & (BAY > 0.5), 'WA')
    deep = ero4(ero4(ero4(lk)))
    paint(deep, 'WA')
    paint(deep & ero4(deep) & (BAY > 0.70), 't2')
    paint(lk & ero4(lk) & (yy % 3 == 0) & ((xx + yy // 3) % 5 == 0), 'WH')
    # reed pool in the canopy fringe
    pw = water & pool
    shp = dil8(pw) & ~pw & F & ~keep_m
    paint(shp, 'S5')
    paint(pw, 'WA')
    paint(pw & ((xx + yy) % 2 == 0), 'GK')
    paint(pw & ero4(pw) & (yy % 2 == 1) & (xx % 4 == 0), 'WL')
    # lotus channel from the north wall
    cw = chan_w & F
    paint(dil8(cw) & ~cw & F & ~keep_m, 'S4')
    paint(cw, 'WA')
    paint(cw & ((xx + 2 * yy) % 5 == 0), 'WL')

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    place18 = np.zeros((H, W), bool)   # landmark props stay out of an 18 px circle round every spread place
    for sid, (x, y) in spread.items():
        place18 |= disk(x, y, 18)
    protect = keep_pad | near_road | root_corr | dil4(occ_water)
    free = F & ~protect & (depth >= 2)
    wet_free = occ_water & ~(keep_pad | near_road | root_corr) & ~grow(~occ_water, 1)
    occ = np.zeros((H, W), bool)
    placed = []
    shadows = []

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
        if rows in (THORN, THORN_W, THORN_S, BAOBAB, QUIVER):
            shadows.append((x, y, w))
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
            if try_place(x, y, rows, over, pad, where):
                got += 1
        return got

    def glow(cx_, cy_, rad, col, extra=None):
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ & F
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + 0.12) & ((xx + yy) % 2 == 0), col)

    def okpx(X, Y, m=None):
        m = hard if m is None else m
        return 0 <= X < W and 0 <= Y < H and m[Y, X] and not occ[Y, X]

    log = []
    baobab_at = None
    massif = None
    hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water & ~place18
    soft = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        if k == 'great_baobab':
            got = baobab_at = (near(x, y + 11, BAOBAB, BAOBAB_C, 10, 0, where=hard)
                               or near(x, y + 11, BAOBAB, BAOBAB_C, 16, 0, where=soft))
        elif k == 'king_protea_garden':
            got = None
            for (dx, dy) in [(0, 0), (2, 1), (-2, 1), (0, 3), (3, -2), (-3, -1), (5, 2), (-5, 2), (0, -3), (-6, 4)]:
                gx, gy = x + dx, y + dy
                sl = (slice(gy - 5, gy + 6), slice(gx - 9, gx + 10))
                if hard[sl].all() and not occ[sl].any():
                    gm = (((xx - gx) / 8.5) ** 2 + ((yy - gy) / 4.5) ** 2 + 0.2 * (vnoise(2, 130) - 0.5)) < 1
                    paint(gm, 'RK')
                    paint(gm & ((xx + yy) % 2 == 0), 'S4')
                    paint(gm & (yy == gy + 2) & (xx % 3 != 0), 'AL')     # one teff row
                    for (hx_, hy_) in ((gx - 5, gy - 1), (gx - 1, gy - 2), (gx + 3, gy - 1), (gx + 6, gy + 0),
                                       (gx - 3, gy + 1), (gx + 1, gy + 1), (gx + 5, gy + 3), (gx - 6, gy + 3)):
                        put(hx_ - 1, hy_, 'PK'); put(hx_ + 1, hy_, 'PK'); put(hx_, hy_ - 1, 'PK'); put(hx_, hy_ + 1, 'GK')
                        put(hx_, hy_, 'CR'); put(hx_ - 1, hy_ - 1, 'PL'); put(hx_ + 1, hy_ - 1, 'PL')
                    for t_ in range(-9, 10):     # thorn fence round the bed
                        a_ = t_ / 9.5
                        for s_ in (-1, 1):
                            yy_ = gy + s_ * int(round(5.2 * math.sqrt(max(0, 1 - a_ * a_))))
                            put(gx + t_, yy_, 'K' if (t_ % 2) else 'S5')
                    occ[sl] = True
                    got = (gx, gy)
                    break
        elif k == 'teff_terraces':
            got = 0
            for i in range(n):   # three low steps, each a lit lip over a pale gold row
                ty0 = y - 4 + i * 4
                for X in range(x - 14 + i * 2, x + 12 - i * 2):
                    if okpx(X, ty0, soft) and okpx(X, ty0 - 1, soft) and okpx(X, ty0 + 1, soft):
                        put(X, ty0 - 1, 'RH'); put(X, ty0, 'CR' if (X + i) % 3 else 'AL'); put(X, ty0 + 1, 'RK')
                        occ[ty0 - 1:ty0 + 2, X] = True
                        got += 1
            # the round threshing floor
            for (dx, dy) in [(-18, 2), (-20, 6), (-16, -4), (-22, 0), (14, 6)]:
                tx_, ty_ = x + dx, y + dy
                if soft[ty_ - 3:ty_ + 4, tx_ - 4:tx_ + 5].all() and not occ[ty_ - 3:ty_ + 4, tx_ - 4:tx_ + 5].any():
                    tm = np.hypot((xx - tx_) / 4.0, (yy - ty_) / 2.6) < 1
                    paint(tm, 'SN'); paint(tm & ~ero4(tm), 'S5'); put(tx_, ty_, 'S6')
                    occ[ty_ - 3:ty_ + 4, tx_ - 4:tx_ + 5] = True
                    got = (got, (tx_, ty_))
                    break
        elif k == 'seal_waystone':
            got = near(x, y, SEALSTONE, None, 10, 0, where=F & ~keep_pad & ~near_road & ~occ_water & ~root_corr)
        elif k == 'thorn_acacia':
            got = cluster(x, y, [(THORN_W, ACACIA), (THORN, ACACIA), (THORN_S, ACACIA)], 3, 12, 1, where=hard & ~pixmask(road_px, 10))
            got += cluster(286, 44, [(THORN_W, ACACIA), (THORN, ACACIA)], 2, 10, 1, where=hard & ~pixmask(road_px, 10))
            got += cluster(130, 100, [(THORN, ACACIA), (THORN_S, ACACIA)], 2, 10, 1, where=hard)
        elif k == 'migration_herd':
            got = 0
            track = [(int(x + 34 - i * 5.5), int(round(y + 2.5 * math.sin(i / 1.7)))) for i in range(n)]
            for (X, Y) in track:
                if okpx(X, Y) and okpx(X + 1, Y) and okpx(X, Y - 1) and okpx(X + 1, Y - 1):
                    put(X, Y - 1, 'S3'); put(X + 1, Y - 1, 'S2'); put(X, Y, 'K'); put(X + 1, Y, 'K'); put(X - 1, Y - 1, 'S4')
                    occ[Y - 1:Y + 1, X - 1:X + 2] = True
                    got += 1
            # the dusty herd track running east-west across the plains
            for X in range(x - 70, x + 90):
                Y = int(round(y + 4 + 3 * math.sin(X / 23.0)))
                if X % 3 and okpx(X, Y, hard | (F & ~keep_pad & ~near_road & ~root_corr & ~occ_water)):
                    put(X, Y, 'S6' if X % 3 == 1 else 'S5')
        elif k == 'drum_ring':
            got = 0
            if hard[y - 7:y + 7, x - 8:x + 8].all():
                for a in range(5):
                    ang = a * 2 * math.pi / 5 + 0.3
                    X = int(round(x + 6 * math.cos(ang))); Y = int(round(y + 4 * math.sin(ang)))
                    spr(X, Y + 1, DRUM)
                    got += 1
                put(x, y, 'T4'); put(x, y - 1, 'GD'); put(x, y + 1, 'RD'); put(x - 1, y + 1, 'S2'); put(x + 1, y + 1, 'S2')
                occ[y - 7:y + 7, x - 8:x + 8] = True
                glow(x, y, 9, 'GD', extra=~occ | True)
        elif k == 'liana_bridges':
            got = 0
            trunks = [x - 16, x - 4, x + 10, x + 22]
            ok_cols = [X for X in trunks if (F & ~keep_pad & ~near_road & ~root_corr & ~occ_water)[y - 22:y + 8, X - 1:X + 2].all()]
            for X in ok_cols:
                for Y in range(y - 22, y + 8):
                    put(X - 1, Y, 'K'); put(X, Y, 'S5' if Y % 4 else 'S4'); put(X + 1, Y, 'K')
                for (dx, dy) in ((-2, -22), (2, -21), (-3, -19), (3, -20), (0, -23)):
                    put(X + dx, y + dy, 'GM'); put(X + dx, y + dy + 1, 'GK')
                put(X, y + 8, 'K'); put(X - 2, y + 8, 'GK'); put(X + 2, y + 8, 'GK')
                occ[y - 24:y + 9, X - 3:X + 4] = True
            for a_, b_ in zip(ok_cols, ok_cols[1:]):
                for X in range(a_ + 2, b_ - 1):
                    t_ = (X - a_) / float(b_ - a_)
                    for (base, sag) in ((y - 14, 4), (y - 4, 3)):
                        Y = int(round(base + sag * math.sin(math.pi * t_)))
                        put(X, Y, 'S6'); put(X, Y + 1, 'K' if X % 2 else 'GK')
                        if X % 4 == 0:
                            put(X, Y + 2, 'GM')
                got += 1
        elif k == 'coffee_terraces':
            got = 0
            for i in range(n):
                ty0 = y - 6 + i * 5
                for X in range(x - 16 + i, x + 14 - i, 4):
                    if fits(X - 2, ty0 - 3, COFFEE, 0, hard) or fits(X - 2, ty0 - 3, COFFEE, 0, soft & ~place18):
                        try_place(X, ty0, COFFEE, None, 0, where=soft)
                        got += 1
            got = (got, near(x - 30, y + 18, RACK, None, 10, 0, where=soft & ~disk(*spread.get(213, (-99, -99)), 16)),
                   near(x - 34, y + 12, POT, None, 12, 0, where=soft & ~disk(*spread.get(213, (-99, -99)), 16)))
        elif k == 'snowcrown_massif':
            px_, base_, pk = x + 4, y + 14, 207
            topn = vnoise(2, 131)
            top = pk + 0.78 * np.abs(xx - px_) + 2.4 * (topn - 0.5) + 2.0 * np.sin(xx / 3.1)
            top = np.where(xx < px_ - 16, np.minimum(top, 222 + 0.85 * np.abs(xx - (px_ - 26)) + 2 * np.sin(xx / 2.3)), top)
            M = (yy >= top) & (yy <= base_) & (np.abs(xx - px_) <= 44) & ~keep_pad & ~near_road & ~root_corr
            M &= F    # it grows out of the south wall: the rim stays in front of its foot
            ridge = px_ + (yy - pk) * 0.18
            lit = xx < ridge
            snow = yy < pk + 12 + 2 * np.sin(xx / 2.0) + 1.5 * np.cos(xx / 3.7) - 0.22 * np.abs(xx - px_)
            snow |= (xx < px_ - 16) & (yy < 229 + 1.5 * np.sin(xx / 1.7) - 0.3 * np.abs(xx - (px_ - 26)))
            paint(M & lit, 'AS'); paint(M & lit & ((xx + yy) % 2 == 0) & (xx > ridge - 8), 'AL')
            paint(M & ~lit, 'S4'); paint(M & ~lit & ((xx + yy) % 2 == 0) & (xx > ridge + 3), 'S3')
            led = M & ((yy + (xx // 7)) % 6 == 0) & (vnoise(3, 132) > 0.35)
            paint(led & lit, 'S4'); paint(led & ~lit, 'S2')
            paint(M & snow & lit, 'WH'); paint(M & snow & ~lit, 'AL')
            paint(M & snow & ~lit & ((xx + yy) % 3 == 0), 'WH')
            edge = M & ~ero4(M) & (yy < base_ - 1)
            paint(edge & ~dil4(~F & (yy > 240)), 'K')
            # one mist line across the mountain foot
            mist = M & (np.abs(yy - (238 + np.sin(xx / 6.0))) < 0.8) & ((xx // 2) % 3 != 0)
            paint(mist, 'AL')
            # the Mountain Lion of the Snowpeak: one red glow pixel pair on the east shoulder
            for (X, Y) in ((px_ + 20, 231), (px_ + 18, 229), (px_ + 22, 234), (px_ + 15, 227)):
                if M[Y, X] and M[Y, X + 2]:
                    put(X, Y, 'RD'); put(X + 2, Y, 'RD'); put(X + 1, Y + 1, 'RK')
                    break
            occ |= M
            massif = M
            got = int(M.sum())
        elif k == 'flamingo_flock':
            got = 0
            rimz = dil8(occ_water & ~(pool & True)) & ~occ_water & F
            rim_in = occ_water & dil8(~occ_water) & lakes
            for (cx_, cy_, nn) in ((x, y, n), (372, 150, max(4, n // 2))):
                cand = [(X, Y) for Y in range(cy_ - 16, cy_ + 17) for X in range(cx_ - 26, cx_ + 27)
                        if 0 <= X < W and 0 <= Y < H - 1 and (rim_in[Y, X] or rimz[Y, X]) and not keep_pad[Y, X]
                        and not near_road[Y, X] and not occ[Y, X]]
                R.shuffle(cand)
                c2 = 0
                for (X, Y) in cand:
                    if c2 >= nn:
                        break
                    if occ[Y - 1:Y + 2, X - 1:X + 2].any():
                        continue
                    put(X, Y - 1, 'PK'); put(X, Y, 'PL' if (X + Y) % 2 else 'PK')
                    occ[Y - 1:Y + 2, X - 1:X + 2] = True
                    c2 += 1
                got += c2
        elif k == 'papyrus_jetty':
            got = None
            okj = F & ~keep_pad & ~near_road & ~root_corr
            for dy in sorted(range(-10, 12), key=abs):
                Y = y + dy
                xs_ = [X for X in range(x - 16, x + 24) if lk[Y, X]]
                if len(xs_) < 8:
                    continue
                x0_ = xs_[0]
                if not okj[Y - 1:Y + 2, x0_ - 4:x0_ + 1].all() or occ[Y - 1:Y + 2, x0_ - 4:x0_ + 8].any():
                    continue
                for X in range(x0_ - 3, x0_ + 7):
                    put(X, Y - 1, 'K'); put(X, Y, 'S6' if X % 2 else 'S5'); put(X, Y + 1, 'K')
                put(x0_ - 3, Y + 2, 'K'); put(x0_ + 6, Y + 2, 'K')
                # a papyrus raft moored at the end
                for X in range(x0_ + 8, x0_ + 13):
                    put(X, Y + 2, 'GD' if X % 2 else 'SD'); put(X, Y + 3, 'K')
                put(x0_ + 10, Y + 1, 'S6'); put(x0_ + 10, Y, 'K')
                for (X, Y2) in ((x0_ - 6, Y), (x0_ - 7, Y + 2), (x0_ - 5, Y - 3)):
                    if okj[Y2, X]:
                        spr(X, Y2, PAPYRUS)
                occ[Y - 3:Y + 5, x0_ - 8:x0_ + 14] = True
                got = (x0_, Y)
                break
        elif k == 'burnt_fire_trails':
            got = 0
            for i in range(n):
                cx_, cy_ = x - 6 + i * 9, y - 18 + i * 14
                Lm = (np.abs((xx - cx_) * 0.55 + (yy - cy_) * 0.84) < 1.6 + 0.8 * vnoise(2, 140 + i)) & \
                     (np.hypot(xx - cx_, yy - cy_) < 15) & hard & ~occ & (zone == 'fynbos')
                paint(Lm, 'S1'); paint(Lm & ((xx + yy) % 2 == 0), 'K')
                paint(Lm & (vnoise(1, 150 + i) > 0.85), 'T4')
                paint(Lm & (vnoise(1, 160 + i) > 0.93), 'RD')
                edge_ = dil8(Lm) & ~Lm & hard & ~occ
                paint(edge_ & (vnoise(1, 170 + i) > 0.70), 'T1')
                paint(edge_ & (vnoise(1, 180 + i) > 0.85), 'PK')
                occ |= dil4(Lm)
                got += int(Lm.sum())
        elif k == 'lotus_channel':
            got = 0
            cw2 = chan_w & F
            ys_, xs_ = np.nonzero(dil8(dil8(cw2)) & ~cw2 & F & ~keep_pad & ~near_road)
            for i in range(0, len(xs_), 3):
                X, Y = int(xs_[i]), int(ys_[i])
                if (X * 7 + Y * 3) % 4 == 0:
                    put(X, Y, 'GM'); put(X + 1, Y, 'PK' if (X + Y) % 2 else 'PL')
                    got += 1
            ys_, xs_ = np.nonzero(ero4(cw2) if ero4(cw2).any() else cw2)
            if len(xs_):
                order = np.argsort(ys_)
                for f in (0.35, 0.75):
                    j = order[int(len(order) * f)]
                    spr(int(xs_[j]), int(ys_[j]) + 1, BOAT)
            occ |= dil4(cw2)
        elif k == 'thorn_boma':
            got = 0
            for (bx, by) in ((x, y), (340, 234))[:n]:
                for dx, dy in sorted(((a, b) for a in range(-8, 9) for b in range(-6, 7)), key=lambda t: abs(t[0]) + abs(t[1])):
                    cx_, cy_ = bx + dx, by + dy
                    if hard[cy_ - 5:cy_ + 6, cx_ - 7:cx_ + 8].all() and not occ[cy_ - 5:cy_ + 6, cx_ - 7:cx_ + 8].any():
                        for a in range(28):
                            ang = a * 2 * math.pi / 28
                            X = int(round(cx_ + 6 * math.cos(ang))); Y = int(round(cy_ + 4 * math.sin(ang)))
                            if a in (6, 7):
                                continue    # the gate
                            put(X, Y, 'GK' if a % 3 else 'S5'); put(X, Y - 1, 'K' if a % 2 else 'GK')
                        put(cx_ - 1, cy_, 'S4'); put(cx_, cy_, 'S6'); put(cx_ + 1, cy_, 'S4'); put(cx_, cy_ - 1, 'K')
                        occ[cy_ - 5:cy_ + 6, cx_ - 7:cx_ + 8] = True
                        got += 1
                        break
        elif k == 'termite_spires':
            got = cluster(x, y, [(SPIRE_T, None), (SPIRE_TS, None)], 2, 10, 1, where=hard)
            got += cluster(180, 76, [(SPIRE_T, None), (SPIRE_TS, None)], 1, 8, 1, where=hard)
            got += cluster(380, 238, [(SPIRE_T, None), (SPIRE_TS, None)], 1, 8, 1, where=hard)
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter: crowns under 8 px within 10 px of the roads so the Y at the Market reads
    zf = lambda z: free & (zone == z) & ~occ_water
    far_road = ~pixmask(road_px, 10)
    tall_j = [(BIGTREE, JUNGLE), (TREE, JUNGLE), (TREE, HAZEL), (BIGTREE, HAZEL)]
    low_j = [(FERN, JUNGLE), (FERN, None), (FERN_S, JUNGLE), (BUSH, None), (TREE_S, JUNGLE), (TREE_S, HAZEL)]
    scatter(tall_j, 40, zf('canopy') & far_road, pad=0, tries=6000)
    scatter(low_j, 50, zf('canopy'), pad=0, tries=5000)
    scatter([(THORN_W, ACACIA), (THORN, ACACIA)], 10, zf('grass') & far_road, pad=3, tries=4000)
    scatter([(THORN_S, ACACIA)], 8, zf('grass'), pad=2, tries=3000)
    scatter([(TUFT, GRASS_C), (TUFT, GRASS_C), (GOLDTUFT, None)], 45, zf('grass'), pad=1)
    scatter([(SPIRE_TS, None)], 4, zf('grass') & far_road, pad=3)
    scatter([(TUFT, GRASS_C)], 10, zf('clay'), pad=2)
    scatter([(COFFEE, None)], 14, zf('coffee'), pad=1)
    scatter([(STACK_S, REDSTACK), (PEBBLE, BONE)], 8, zf('coffee'), pad=1)
    scatter([(HEATH, HEATH_C), (HEATH, HEATH_C), (PROTEA, None), (BUSH, HEATH_C)], 40, zf('fynbos'), pad=0)
    scatter([(QUIVER, None), (THORN_S, ACACIA), (PEBBLE, BONE), (PEBBLE, BONE), (STONE, REDROCK)], 22, zf('karoo'), pad=1)
    scatter([(PAPYRUS, None), (REED, None)], 22, dil8(dil8(occ_water)) & ~occ_water & free, pad=0)
    # protea dots in the heath, pink and gold
    fl = free & ~occ & ~dil4(occ)
    fpix = fl & (zone == 'fynbos') & (vnoise(1, 86) > 0.93) & (vnoise(7, 87) > 0.50)
    sel = (xx * 7 + yy * 13) % 3
    for i, c in enumerate(['PK', 'PL', 'GD']):
        paint(fpix & (sel == i), c)
    paint(fl & (zone == 'canopy') & (vnoise(1, 88) > 0.975), 'PK')

    # lanterns beside the trunks (cream glow on warm ground)
    lamp_cand = pixmask(road_px, 6) & ~pixmask(road_px, 4) & free & ~occ
    ys, xs = np.nonzero(lamp_cand)
    idxs = list(range(len(xs)))
    R.shuffle(idxs)
    lamp_at = []
    for i in idxs:
        x, y = int(xs[i]), int(ys[i])
        if any((x - a) ** 2 + (y - b) ** 2 < 44 ** 2 for a, b in lamp_at):
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'CR')
    if baobab_at:
        glow(baobab_at[0], baobab_at[1] - 8, 13, 'GD')
    # long low shadows to the east (the light comes from the west)
    for (x, y, w) in shadows:
        for dx in range(1, w // 2 + 7):
            for dy in (0, 1) if w > 12 else (0,):
                X, Y = x + dx, y - dy
                if 0 <= X < W and F[Y, X] and not keep_pad[Y, X] and not road_m[Y, X] and not occ_water[Y, X] \
                        and not (massif is not None and massif[Y, X]):
                    if dx > w // 2 + 3 and (X + Y) % 2:
                        continue
                    put(X, Y, 'S5' if zone[Y, X] in ('grass', 'lake', 'karoo') else 'S4')
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

    # ------------------------------------------------ 7. NEAR LAYER: flat stone sky, termite-clay stalactites, stalagmites
    keep = keep_m | pixmask(road_px, 4) | chan
    if massif is not None:
        keep = keep | massif

    def spike(x0, w, h, up, clay=False):
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
                c = 'RK' if clay else 'S1'
                if i <= w * 0.3 and j < hh_:
                    c = ('RE' if clay else ('S4' if up else 'S3'))
                if j >= hh_ or i == 0 or i == w - 1:
                    c = 'K'
                if c in ('S1', 'RK') and (i + j) % 5 == 0:
                    c = 'S2'
                put(x0 + i, y, c)

    RS = random.Random(SEED + 3)
    for up in (False, True):
        x = -3
        while x < W:
            w = RS.randint(5, 13) if not up else RS.randint(6, 16)
            h = RS.randint(4, 10) if not up else RS.randint(4, 13)   # a flat stone sky: short spikes up top
            spike(x, w, h, up, clay=(not up and RS.random() < 0.3))
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
                    or near_road[min(y + 1, H - 1), max(0, min(W - 1, x))]:
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

    # few hanging roots: a cluster over the town and short dry tufts elsewhere
    tx_ = town['x']
    for k, (x0, ln, th) in enumerate([(tx_ - 14, 26, 2), (tx_ + 4, 30, 3), (tx_ + 20, 22, 2)]):
        root(x0, ln, th, SEED * 100 + 50 + k)
    for k in range(10):
        x0 = RS.randrange(150, W - 12)
        root(x0, RS.randint(8, 16), RS.choice([1, 1, 2]), SEED * 100 + k)
    # Greatcanopy lianas droop from the north-west ceiling
    for k in range(14):
        x0 = RS.randrange(12, 146)
        ln_ = RS.randint(14, 40)
        if root(x0, ln_, 1, SEED * 100 + 200 + k, col=('GK', 'GM')):
            for Y in range(4, ln_, 5):
                X = x0 + int(round(2.2 * math.sin(Y / 5.0 + random.Random(SEED * 100 + 200 + k).uniform(0, 6))))
                put(X - 1, Y, 'GM'); put(X + 2, Y + 1, 'T1' if Y % 2 else 'GM')
    for k in range(9):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S)
    for k in range(5):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'RH', 'u': 'T4', 'n': 't4'} if k % 2 else None)

    # mouths: the Greatcanopy root-and-liana arch, the Spicepeak stone stair with prayer flags,
    # the Rainroot thorn arch with wet moss on its lip
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['to'] == 'WCA':
            for s in (-1, 1):
                for j in range(0, 14):
                    X = ex + s * (5 + (j * j) // 40); Y = j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'S5'); put(X + s, Y, 'K')
                    if j % 3 == 0:
                        put(X - s, Y + 1, 'GM'); put(X - s, Y + 2, 'GK')
                    if j % 4 == 2:
                        put(X + 2 * s, Y, 'T1')
            for X in range(ex - 5, ex + 6):   # the green glow of the canopy behind
                if not road_m[2, X] and abs(X - ex) > 1:
                    put(X, 2 + (X % 2), 'T1' if X % 3 else 'GM')
        elif e['to'] == 'CSA':
            for Y in range(2, 14, 3):
                for X in range(ex - 5, ex + 6):
                    if road_m[Y, X] or abs(X - ex) < 2:
                        continue
                    put(X, Y, 'AL'); put(X, Y + 1, 'AS'); put(X, Y + 2, 'K')
            fl_c = ['RD', 'GD', 'T2', 'WH', 'GM']
            for i, X in enumerate(range(ex - 12, ex + 13)):   # a prayer-flag line across the mouth
                Y = 4 + int(round(2.5 * (1 - ((X - ex) / 12.0) ** 2)))
                if road_m[Y, X]:
                    continue
                put(X, Y, 'K')
                if i % 2 == 0 and abs(X - ex) > 1:
                    put(X, Y + 1, fl_c[(i // 2) % 5])
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
                        put(X + s, Y, 'GD')
            for X in range(ex - 9, ex + 10):   # wet moss on the lip
                Y = H - 13 - (1 if abs(X - ex) > 6 else 0)
                if not road_m[Y, X] and not keep_m[Y, X] and abs(X - ex) > 2:
                    put(X, Y, 'GM' if X % 2 else 'T1'); put(X, Y + 1, 'GK')
                    if X % 3 == 0:
                        put(X, Y + 2, 'WL')

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
    for sid, nm in ((217, 'SNOWCROWN PEAK'), (215, 'FLAMINGO SHALLOWS'), (212, 'BAOBAB INN'), (216, 'FYNBOS FIRE TRAILS'), (213, 'COFFEE CEREMONY HUT')):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-ESA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-ESA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-ESA.png'))
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

