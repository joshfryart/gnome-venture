#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for CSA "Spicepeak" (band orange, Lv 35-45).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built on the
ESA generator: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside with a
dithered orange halo and an orange rim light (gold of tier 3 in the north-west corner before the
Birchbramble Seal, violet of tier 5 only at the Blossomreach and Monsoon mouths), biome ground (the
gold Silkroad Steppe hub out to the first stop on every road, river silt, the grey slate Roof of the
World with frost on its tops and its south spur, the Lotus Delta with braided spring channels, the
pale Birchbramble breath, the Dunewhisper sand spill, the Thornacre gold grass, the dark Tigerstripe
Jungle with striped fern bands, the green Blossomreach breath with petals), the Spicepeak itself (a
banded red-and-orange stalactite hanging into the north notch), landmark props (seed bed, turmeric
rows, awnings, spice sacks, camel line, windmill, lookout tower, three Seal gates on the roads, birches,
amber, wolf den, ferry and jetty, prayer flags, slate steps, pines, cairn, pass cut, dunes, red outcrop,
thorn trees, baobab, flamingo pan, ember heath, termite spires, tea rows, temple roots, fireflies,
paddies, mill wheel, bamboo, blossom, pearl pool, copper rocks, stone lantern, the one dark lamp post),
glowing road trunks on the layout polylines and the five exit tunnel mouths; a root ceiling and a
stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one or two flat tones, no sprites, no water, no texture); water never enters such a disc.

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_CSA.py [--layout layout-CSA.json] [--plan plan-CSA.json]
                                     [--out game/assets/img/scenes/map2-CSA.png] [--preview PREVIEW-2x.png]
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
CODE = 'CSA'
SEED = 23


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

# ---------------------------------------------------------------- CSA sprites (Spicepeak)
LET.update({'x': 'CR', 'O': 'T4', 'Y': 'GD', 'V': 'T5', 'z': 't5', 'Z': 'D3', 'q': 'T2'})
BIRCHT = ['.kkkk.', 'kGGgdk', 'kGggdk', 'kgGgdk', '.kgdk.', '..wk..', '..kw..', '..wk..', '..wk..', '..kk..']
BIRCHT_S = ['.kkk.', 'kGgdk', '.kgk.', '..w..', '..k..', '..w..']
AUTUMN = {'G': 'GD', 'g': 'MY', 'd': 'MD'}
WINDMILL = pad_rows(['x.....x', '.x...x.', '..kYk..', '..kxk..', '.x.k.x.', 'x.kBk.x', '..kBk..', '.kBbBk.',
                     '.kBbBk.', '.kb1bk.', 'kkkkkkk'])
TOWER = ['...Y...', '..kkk..', '.kBbBk.', 'kkkkkkk', '.kA.ak.', '.k.A.k.', '.kA.ak.', '.k.A.k.', '.kA.ak.',
         'kkAaakk', 'kkkkkkk']
CAMEL = pad_rows(['....kk', '.k..kB', 'kBkkBk', 'kBBBk.', '.kBBk.', '.k.k..'])
AWNING = ['kkkkkkk', 'rxrxrxr', 'k.....k', 'k.Oy..k']
SACKS = ['.k.k.k.', 'kOkykrk', 'kOkykrk', 'kkkkkkk']
GATEPOST = ['kkk', 'kYk', 'kAk', 'kak', 'kAk', 'kak', 'kAk', 'kkk']
STONELANT = ['.k.', 'kAk', 'kyk', 'kak', '.a.', 'kAk', 'kkk']
LANTERN_H = ['k', 'y', 'O']
BRAMBLE = ['.kkk.', 'kdrdk', 'kgdrk', '.kkk.']
BRAMBLE_C = {'g': 'GK', 'd': 't1', 'r': 'RD'}
AMBER = ['.k.', 'kyk', 'kOk', '.k.']
BAMBOO = ['G.g.G', 'gkG.g', 'G.gkG', 'g.G.g', 'Gkg.G', 'g.Gkg', 'G.g.G', 'd.d.d']
BAMBOO_S = ['G.g', 'g.G', 'Gkg', 'g.G', 'd.d']
MANGO = {'g': 'GM', 'G': 'T1', 'd': 'GK'}
LAMP_DARK = ['.k.', 'k1k', 'kak', '.k.', '.b.', '.b.', 'kbk']
MILLWHEEL = ['.kkk.', 'kbkbk', 'kkBkk', 'kbkbk', '.kkk.']
PERCH = ['r.q.', 'kkkk', '.b..', '.b..', 'kbk.']
COPPER = {'A': 'T4', 'a': 'RE', '1': 'RK'}
SLATE = {'A': 'AL', 'a': 'AS', '1': 'D3'}
FERRY = ['....k...', '....b...', 'kkkkkkkk', 'kBbBbBbk', '.kkkkkk.']
TEAROW = ['.kk.', 'kGgk']
TEA_C = {'G': 'GM', 'g': 'GK'}

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
    zone = np.full((H, W), 'silt', dtype=object)    # river silt is the default floor
    zmask = {}
    KEY = {'silkroad_steppe': 'hub', 'roof_of_the_world': 'roof', 'roof_south_spur': 'roof',
           'lotus_delta': 'delta', 'birchbramble_breath': 'birch', 'dunewhisper_spill': 'dune',
           'thornacre_breath': 'thorn', 'tigerstripe_jungle': 'jungle', 'blossomreach_breath': 'blossom'}
    tank_def = None
    for i, b in enumerate(P['biomes']):
        if b['type'] == 'flower_tank':
            tank_def = b
            continue
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
    # the hub stays gold out to the first stop on all five roads
    hubn = vnoise(5, 120)
    for rd in L['roads']:
        s1 = slots[rd['nodes'][1]]
        zmask['hub'] |= np.hypot(xx - s1['x'], yy - s1['y']) + 6 * (hubn - 0.5) < 24
    # breaths fade into the silt by dither
    for k in ('jungle', 'blossom', 'birch', 'thorn'):
        if k in zmask:
            cs = blur(zmask[k].astype(float), 4)
            zmask[k] = cs > 0.25 + 0.5 * BAY
    for key in ['dune', 'birch', 'thorn', 'jungle', 'blossom', 'delta', 'roof', 'hub']:
        if key in zmask:
            zone[zmask[key] & F] = key
    # Snowleopard Ledges and Fynbos Fire Trails get their own small patches (grey ledge, ember heath)
    if 222 in spread:
        lx, ly = spread[222]
        zone[F & (np.hypot((xx - lx) / 22.0, (yy - ly) / 15.0) + 0.4 * (vnoise(4, 121) - 0.5) < 1)] = 'roof'
    if 216 in spread:
        hx_, hy_ = spread[216]
        zone[F & (np.hypot((xx - hx_) / 26.0, (yy - hy_) / 18.0) + 0.4 * (vnoise(4, 122) - 0.5) < 1) & ~disk(hx_, hy_, 15)] = 'ember'

    RAMPS = {
        'silt': ['S5', 'SD', 'SD', 'SN'], 'hub': ['SD', 'SD', 'SN', 'SN'], 'thorn': ['S5', 'SD', 'SD', 'SN'],
        'birch': ['S5', 'MD', 'MY', 'MY'], 'dune': ['S6', 'SD', 'SN', 'SN'], 'roof': ['S4', 'AS', 'AS', 'AL'],
        'delta': ['S5', 'SD', 'SD', 'SN'], 'jungle': ['t1', 't1', 'GK', 'GM'], 'blossom': ['t1', 'GK', 'GM', 'GM'],
        'ember': ['S4', 'S5', 'S6', 'RE'],
    }
    BIAS = {'silt': 0.04, 'hub': 0.14, 'thorn': 0.06, 'birch': 0.10, 'dune': 0.10, 'roof': 0.06, 'delta': 0.04,
            'jungle': -0.04, 'blossom': 0.02, 'ember': 0.04}

    # ------------------------------------------------ 3. FLOOR: lit ground
    town = slots[L['town']]
    dt = np.hypot(xx - town['x'], yy - town['y'])
    tex = vnoise(2, SEED + 9)
    lightv = 0.14 + 0.46 * np.clip(depth / 14.0, 0, 1) ** 0.8 + 0.20 * np.exp(-(dt / 80.0) ** 2)
    roadglow = blur(road_m.astype(float), 5)
    lightv += 0.16 * np.clip(roadglow * 3, 0, 1)
    for k, bv in BIAS.items():
        lightv = lightv + np.where(zone == k, bv, 0)
    kb = {'silt': 0.03, 'thorn': 0.04, 'hub': 0.0, 'birch': 0.02, 'dune': 0.0, 'roof': 0.03, 'delta': 0.03,
          'jungle': 0.04, 'blossom': 0.02, 'ember': 0.02}
    kbias = np.zeros((H, W))
    for k, v in kb.items():
        kbias = np.where(zone == k, v, kbias)
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
    # silt and hub: sparse short grass, single turmeric pixels
    sz = busyok & ((zone == 'silt') | (zone == 'hub'))
    paint(sz & (vnoise(1, 61) > 0.955) & (gi <= 2), 'S5')
    paint(sz & (vnoise(1, 62) > 0.975), 'GD')
    paint(busyok & (zone == 'silt') & (vnoise(1, 63) > 0.97) & (vnoise(9, 64) > 0.5), 'GM')
    # thornacre: gold 1 px wind streaks, AL glints
    gz = busyok & (zone == 'thorn')
    wind = (vnoise(1, 71) > 0.70) & ((yy % 3) == 0)
    streak = wind | np.roll(wind, 1, axis=1) | np.roll(wind, 2, axis=1) | np.roll(wind, 3, axis=1) | np.roll(wind, 4, axis=1)
    paint(gz & streak & (vnoise(3, 72) > 0.42), 'GD')
    paint(gz & streak & (vnoise(3, 72) <= 0.42) & (vnoise(3, 73) > 0.5), 'AL')
    paint(gz & (vnoise(1, 74) > 0.94) & (gi <= 2), 'S5')
    # birchbramble: cold pale grass streaks, white flecks, amber dots
    bz = busyok & (zone == 'birch')
    paint(bz & streak & (vnoise(3, 75) > 0.5), 'AL')
    paint(bz & (vnoise(1, 76) > 0.965), 'WH')
    paint(bz & (vnoise(1, 77) > 0.975), 'GD')
    # dune spill: long ripples
    dz = busyok & (zone == 'dune')
    rip = np.abs(np.sin((yy * 1.2 + 5 * np.sin(xx / 11.0) + 7 * vnoise(9, 78)) / 1.7)) > 0.96
    paint(dz & rip & (gi >= 1), 'S6')
    paint(dz & np.roll(rip, 1, axis=0) & ~rip & (gi >= 2), 'CR')
    # roof of the world: slate steps, frost on the tops, shadow on the north face
    rz = busyok & (zone == 'roof')
    ledge = ((yy + (xx // 9) * 2) % 4 == 0) & (vnoise(4, 80) > 0.20)
    paint(rz & ledge, 'S4')
    paint(rz & np.roll(ledge, 1, axis=0) & ~ledge, 'AL')
    roofm = F & (zone == 'roof')
    north = roofm & ~np.roll(roofm, 7, axis=0)
    paint(north & busyok & (BAY > 0.45), 'D3')
    tops = (vnoise(6, 81) > 0.66) & ~north
    paint(rz & tops & (vnoise(1, 82) > 0.6), 'WH')
    redge = roofm & ~ero4(roofm) & ~keep_m & (depth > 2)
    foot = redge & ~np.roll(roofm, -2, axis=0)          # south-facing foot of the massif
    paint(redge & ~foot & ((xx + yy) % 2 == 0), 'S4')
    paint(foot, 'S3')
    below = np.roll(foot, 1, axis=0) & ~roofm & F & ~keep_m
    paint(below & ((xx + yy) % 2 == 0), 'S4')
    # delta: green silt bars
    ez = busyok & (zone == 'delta')
    paint(ez & (vnoise(1, 84) > 0.88) & ((xx + yy) % 2 == 0), 'GK')
    paint(ez & (vnoise(1, 85) > 0.96), 'GM')
    # jungle: dark fronds, tiger-stripe fern bands
    jz = busyok & (zone == 'jungle')
    paint(jz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    paint(jz & (vnoise(1, 66) > 0.975) & (gi >= 2), 'T1')
    tig = jz & (vnoise(9, 68) > 0.60) & (xx < 420)
    st_ = ((xx - yy * 0.6 + 400) // 2).astype(int) % 4
    paint(tig & (st_ == 0) & (BAY > 0.25), 'T4')
    paint(tig & (st_ == 1) & (BAY > 0.25), 'S2')
    # blossom: green with pink petals
    oz = busyok & (zone == 'blossom')
    paint(oz & (vnoise(1, 86) > 0.95), 'PK')
    paint(oz & (vnoise(1, 87) > 0.975), 'PL')
    paint(oz & (vnoise(1, 88) > 0.85) & ((xx + yy) % 3 == 0), 't1')
    # ember heath
    hz = busyok & (zone == 'ember')
    paint(hz & ((xx + yy) % 2 == 0) & (vnoise(3, 89) > 0.55), 'S3')
    paint(hz & (vnoise(1, 90) > 0.88), 'RD')
    paint(hz & (vnoise(1, 91) > 0.94), 'T4')
    burnt = hz & (np.abs(np.sin((xx * 0.55 + yy * 0.84) / 2.2 + 3 * vnoise(5, 92))) < 0.18)
    paint(burnt, 'S1'); paint(burnt & (vnoise(1, 93) > 0.8), 'RD')
    paint(hz & (vnoise(1, 94) > 0.95), 'GM')

    # rim: K outline, band-colour rim light (orange T4), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')
    # cross-band mouths: gold of tier 3 in the north-west corner, violet of tier 5 at the east and south-east
    XBAND = {'EE': ('T3', 't3', 46, 70), 'EA': ('T5', 't5', 28, 44), 'SEA': ('T5', 't5', 28, 44)}
    for e in L['exits']:
        if e['to'] not in XBAND:
            continue
        b_, d_, r0, r1 = XBAND[e['to']]
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['to'] == 'EE':
            ex, ey = 70, 40     # the whole north-west corner before the gate
        dd = np.hypot(xx - ex, yy - ey)
        nr = ~F & ((dd < r0) | ((dd < r1) & (BAY > (dd - r0) / float(r1 - r0))))
        for src, dst in ((BRIGHT, b_), (DIM, d_)):
            hit = nr & (img == np.array(PAL[src], np.uint8)).all(-1)
            paint(hit, dst)

    # ------------------------------------------------ 3b. THE HANGING PEAK: banded red rock in the north notch
    tipx, tipy = 279, 58
    for p in P['props']:
        if p['kind'] == 'hanging_peak_tip':
            tipx, tipy = p['x'], p['y']
    hw = 2.5 + (tipy - yy) * 0.95 + 1.2 * np.sin(yy / 3.0)
    peak = (yy <= tipy) & (np.abs(xx - tipx - 0.08 * (tipy - yy)) <= np.minimum(hw, 27)) & ~d3
    sx_ = xx - tipx - 0.08 * (tipy - yy)
    band_ = ((yy + 2.0 * np.sin(xx / 6.0) + 0.25 * sx_) // 3).astype(int) % 4
    paint(peak & (band_ == 0), 'RE'); paint(peak & (band_ == 1), 'RK'); paint(peak & (band_ == 2), 'RE')
    paint(peak & (band_ == 3), 'T4')
    paint(peak & (band_ == 3) & (sx_ > 4), 'RE')
    paint(peak & (sx_ > 6) & ((xx + yy) % 2 == 0), 'S2')
    paint(peak & (sx_ > 6) & (band_ == 1), 'S1')
    lit_edge = peak & ~np.roll(peak, 1, axis=1) & (sx_ < 0)
    paint(lit_edge, 'RH'); paint(np.roll(lit_edge, 1, axis=1) & peak, 'T4')
    paint(peak & ~ero4(peak) & ~lit_edge & (sx_ > 0), 'K')
    paint(peak & (vnoise(1, 140) > 0.96) & (sx_ < 2), 'GD')

    # ------------------------------------------------ 4. WATERS: delta channels, the flower tank, small pools
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on dry ground
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2.5 * isl
    band = pixmask(road_px, 5)
    ln = vnoise(4, 151)
    # delta: braided shallow channels running from the peak spring to the south-west
    dzm = F & (zone == 'delta') & (depth > 3)
    cf = (xx * 0.62 + yy) + 9 * vnoise(10, 152) + 4 * vnoise(4, 153)
    chan = dzm & (np.abs(((cf / 15.0) % 1.0) - 0.5) < 0.075) & (vnoise(6, 154) > 0.30)
    chan = dil4(chan) & dzm
    pools = np.zeros((H, W), bool)

    def ell(cx_, cy_, rx_, ry_, nz=0.3):
        return np.hypot((xx - cx_) / rx_, (yy - cy_) / ry_) + nz * (ln - 0.5) < 1

    tank = np.zeros((H, W), bool)
    if tank_def:
        tank = ell(tank_def['cx'], tank_def['cy'], tank_def['rx'], tank_def['ry'], 0.2)
    spots = {}
    for p in P['props']:
        k, x, y = p['kind'], p['x'], p['y']
        if k == 'slate_pool':
            spots[k] = ell(x, y, 7, 3.5)
        elif k == 'reed_pool':
            spots[k] = ell(x, y, 9, 4.5)
        elif k == 'flamingo_pan':
            spots[k] = ell(x, y, 13, 5.5)
        elif k == 'pearl_pool':
            spots[k] = ell(x, y + 2, 13, 6)
        elif k == 'creek':
            cpx = raster([(461, 150), (456, 170), (452, 196), (449, 214), (446, 232)])
            spots[k] = pixmask(cpx, 1)
    for m in spots.values():
        pools |= m
    water = (pools | tank) & F & ~keep_wet & ~band & (depth > 2)
    water = ero4(dil4(water)) & F & ~keep_wet & ~band
    if 'creek' in spots:
        water |= spots['creek'] & F & ~keep_wet & ~band & (depth > 2)
    chan_w = chan & ~keep_wet & ~band
    occ_water = water | chan_w
    # channel banks one step darker, water with glints
    paint(dil8(chan_w) & ~chan_w & F & ~keep_m & ~band, 'S5')
    paint(chan_w, 'WA')
    paint(chan_w & ((xx + 2 * yy) % 6 == 0), 'WL')
    # pools: a D2 bank, WA water, WL glints; the pan gets a pink rim, the tank lotus pads
    for name in ('slate_pool', 'reed_pool', 'flamingo_pan', 'pearl_pool', 'creek'):
        if name not in spots:
            continue
        pw = water & spots[name]
        sh = dil8(pw) & ~pw & F & ~keep_m
        if name == 'flamingo_pan':
            paint(sh & ((xx + yy) % 2 == 0), 'PK'); paint(sh & ((xx + yy) % 2 == 1), 'PL')
            paint(pw, 'WL'); paint(pw & ero4(pw) & (BAY > 0.45), 'WA')
            continue
        paint(sh, 'D2' if name in ('slate_pool', 'pearl_pool') else 'S5')
        paint(pw, 'WA')
        paint(pw & ero4(pw) & (yy % 2 == 1) & (xx % 4 == 0), 'WL')
        if name == 'pearl_pool':
            dp = ero4(ero4(pw))
            paint(dp & (BAY > 0.5), 't2')
            for (X, Y) in ((412, 31), (406, 33), (418, 33)):
                if pw[Y, X]:
                    put(X, Y, 'WH')
        if name == 'reed_pool':
            paint(pw & ((xx + yy) % 5 == 0), 'GK')
    tw = water & tank
    tank_at = None
    if tw.any():
        paint(dil8(tw) & ~tw & F & ~keep_m, 'S5')
        paint(dil8(dil8(tw)) & ~dil8(tw) & F & ~keep_m & (BAY > 0.5), 'S6')
        paint(tw, 'WA')
        paint(tw & ero4(tw) & (yy % 2 == 0) & ((xx + yy // 2) % 5 == 0), 'WL')
        ys_, xs_ = np.nonzero(ero4(tw))
        for i in range(0, len(xs_), 11):
            X, Y = int(xs_[i]), int(ys_[i])
            put(X, Y, 'GM'); put(X + 1, Y, 'PK' if i % 2 else 'PL')
        tank_at = (int(xs_.mean()), int(ys_.mean())) if len(xs_) else None
        if tank_at:
            for dx_ in (-7, 5):
                X, Y = tank_at[0] + dx_, tank_at[1]
                if tw[Y, X - 1:X + 2].all():
                    put(X, Y - 1, 'PK'); put(X - 1, Y, 'K'); put(X, Y, 'S6'); put(X + 1, Y, 'K')

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
        if rows in (THORN, THORN_W, THORN_S, BAOBAB, BIGTREE, WINDMILL, TOWER):
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

    def decal(mask, fn):
        """flat ground decal: paints only where allowed, marks occ"""
        m = mask & soft & ~occ
        fn(m)
        occ[m] = True
        return int(m.sum())

    def road_pt(x, y):
        best = None
        for px in roads:
            for i, (X, Y) in enumerate(px):
                d = (X - x) ** 2 + (Y - y) ** 2
                if best is None or d < best[0]:
                    best = (d, X, Y, px, i)
        _, X, Y, px, i = best
        a = px[max(0, i - 3)]; b = px[min(len(px) - 1, i + 3)]
        L_ = math.hypot(b[0] - a[0], b[1] - a[1]) or 1
        return X, Y, (b[0] - a[0]) / L_, (b[1] - a[1]) / L_

    log = []
    lanterns = []
    hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water & ~place18
    soft = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
    tall_ok = hard & ~pixmask(road_px, 6)
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        got = None
        if k in ('hanging_peak_tip', 'hanging_roots', 'stalactites', 'creek', 'slate_pool', 'reed_pool',
                 'flamingo_pan', 'pearl_pool', 'delta_channel'):
            got = 'elsewhere'
        elif k == 'peak_spring_drip':
            got = 0
            for Y in range(y, y + 22):
                X = x - (Y - y) // 4
                if 0 <= Y < H and not keep_pad[Y, X] and not near_road[Y, X]:
                    put(X, Y, 'WL' if Y % 3 else 'WH'); occ[Y, X] = True
                    got += 1
        elif k in ('turmeric_rows', 'tea_rows', 'rice_terrace_steps'):
            got = 0
            col = {'turmeric_rows': ('GD', 'T4', 'S5'), 'tea_rows': ('GM', 'T1', 't1'),
                   'rice_terrace_steps': ('GM', 'WL', 'S5')}[k]
            for i in range(n + 1):
                ty0 = y - 5 + i * 3
                for X in range(x - 11 + (i % 2), x + 11, 1):
                    if okpx(X, ty0, soft) and okpx(X, ty0 + 1, soft):
                        if k == 'rice_terrace_steps':
                            put(X, ty0, 'WL' if (X + i) % 4 == 0 else 'GM'); put(X, ty0 + 1, 'S5')
                        else:
                            if X % 2 == 0:
                                put(X, ty0, col[0] if X % 4 else col[1])
                            put(X, ty0 + 1, col[2])
                        occ[ty0:ty0 + 2, X] = True
                        got += 1
        elif k == 'seed_bed_turmeric_sacred_lotus':
            got = None
            for (dx, dy) in sorted(((a, b) for a in range(-14, 15) for b in range(-10, 11)), key=lambda t: abs(t[0]) + abs(t[1])):
                gx, gy = x + dx, y + dy
                sl = (slice(gy - 4, gy + 5), slice(gx - 9, gx + 10))
                if soft[sl].all() and not occ[sl].any():
                    rect(gx - 9, gy - 4, gx + 9, gy + 4, 'S5')
                    rect(gx - 8, gy - 3, gx + 8, gy + 3, 'S4')
                    for Y in range(gy - 2, gy + 3, 2):
                        for X in range(gx - 7, gx + 2):
                            put(X, Y, 'GD' if X % 2 else 'T4')
                    for X, Y in ((gx + 5, gy - 1), (gx + 4, gy), (gx + 5, gy), (gx + 6, gy), (gx + 5, gy + 1)):
                        put(X, Y, 'WA')
                    put(gx + 5, gy, 'PK'); put(gx + 4, gy - 1, 'GM'); put(gx + 6, gy + 1, 'PL')
                    occ[sl] = True
                    got = (gx, gy)
                    break
        elif k == 'market_awnings':
            got = cluster(x, y, [(AWNING, None)], n, 8, 0, where=soft)
        elif k == 'spice_sacks':
            got = near(x, y, SACKS, None, 14, 0, where=soft)
        elif k == 'caravan_camel_line':
            got = 0
            for i in range(4):
                if try_place(x - 10 + i * 7, y + (i % 2), CAMEL, None, 0, where=soft):
                    got += 1
        elif k == 'windmill':
            got = near(x, y, WINDMILL, None, 12, 1, where=tall_ok) or near(x, y, WINDMILL, None, 14, 0, where=soft & ~pixmask(road_px, 5))
        elif k == 'lookout_tower':
            got = near(x, y, TOWER, None, 12, 1, where=tall_ok) or near(x, y, TOWER, None, 16, 0, where=soft & ~pixmask(road_px, 5))
        elif k in ('gate_birchbramble_seal', 'gate_spicepeak_seal'):
            X, Y, ux, uy = road_pt(x, y)
            nx_, ny_ = -uy, ux
            got = []
            for s in (-1, 1):
                gx, gy = int(round(X + s * 6 * nx_)), int(round(Y + s * 6 * ny_))
                spr(gx, gy + 3, GATEPOST, SLATE if k == 'gate_birchbramble_seal' else COPPER)
                occ[gy - 6:gy + 4, gx - 2:gx + 3] = True
                got.append((gx, gy))
            (ax, ay), (bx, by) = got
            for t in range(0, 13):   # the lintel, high above the road
                X2 = int(round(ax + (bx - ax) * t / 12.0)); Y2 = int(round(ay + (by - ay) * t / 12.0)) - 5
                put(X2, Y2, 'K'); put(X2, Y2 + 1, 'GD' if k == 'gate_birchbramble_seal' else 'T4')
            put((ax + bx) // 2, (ay + by) // 2 - 5, 'CR')
        elif k == 'birch':
            got = cluster(x, y, [(BIRCHT, AUTUMN), (BIRCHT_S, AUTUMN), (BIRCHT, AUTUMN)], n, 12, 0, where=hard)
        elif k == 'amber_lump':
            got = cluster(x, y, [(AMBER, None)], n, 10, 1, where=soft)
            for (X, Y) in [(xx_, yy_) for (yy_, xx_, r_, o_) in placed[-got:]] if got else []:
                glow(X, Y - 2, 6, 'GD')
        elif k == 'bramble':
            got = cluster(x, y, [(BRAMBLE, BRAMBLE_C)], n, 10, 0, where=soft)
        elif k == 'wolf_den_mouth':
            got = 0
            for dy in range(-6, 7):   # a dark arch in the west wall, two red eyes
                for dx in range(-5, 6):
                    if (dx / 5.5) ** 2 + (dy / 6.5) ** 2 < 1 and not keep_m[y + dy, x + dx] and x + dx >= 4:
                        put(x + dx, y + dy, 'S0' if (dx / 4.0) ** 2 + (dy / 5.0) ** 2 < 1 else 'K')
                        got += 1
            put(x - 1, y - 1, 'RD'); put(x + 2, y - 1, 'RD')
        elif k == 'lotus_pads':
            got = 0
            ys_, xs_ = np.nonzero(dil8(dil8(chan_w)) & ~chan_w & soft & ~occ & (np.hypot(xx - x, yy - y) < 40))
            for i in range(0, len(xs_), 5):
                X, Y = int(xs_[i]), int(ys_[i])
                if (X * 7 + Y * 3) % 3 == 0:
                    put(X, Y, 'GM'); put(X + 1, Y, 'PK' if (X + Y) % 2 else 'PL')
                    got += 1
        elif k == 'reeds':
            wz = dil8(dil8(occ_water)) & ~occ_water & soft
            got = cluster(x, y, [(REED, None), (CATTAIL, None)], n * 2, 18, 0, where=wz) + \
                cluster(x, y, [(REED, None)], n, 10, 0, where=soft)
        elif k == 'ferry_boat':
            got = None
            ys_, xs_ = np.nonzero(ero4(chan_w) & (np.hypot(xx - x, yy - y) < 30))
            if len(xs_):
                j = int(np.argmin(np.hypot(xs_ - x, ys_ - y)))
                spr(int(xs_[j]), int(ys_[j]) + 1, ['.p.', 'kBk'])
                got = (int(xs_[j]), int(ys_[j]))
            got = (got, near(x, y, FERRY, None, 16, 0, where=soft))
        elif k == 'reed_jetty':
            got = None
            for (dx, dy) in sorted(((a, b) for a in range(-16, 17) for b in range(-10, 11)), key=lambda t: abs(t[0]) + abs(t[1])):
                X, Y = x + dx, y + dy
                if soft[Y - 1:Y + 2, X - 5:X + 6].all() and not occ[Y - 1:Y + 2, X - 5:X + 6].any() and \
                        chan_w[Y - 3:Y + 4, X - 9:X + 10].any():
                    for X2 in range(X - 5, X + 6):
                        put(X2, Y - 1, 'K'); put(X2, Y, 'S6' if X2 % 2 else 'S5'); put(X2, Y + 1, 'K')
                    put(X - 5, Y + 2, 'K'); put(X + 5, Y + 2, 'K')
                    occ[Y - 1:Y + 3, X - 5:X + 6] = True
                    got = (X, Y)
                    break
        elif k == 'mango_tree':
            got = cluster(x, y, [(BIGTREE, MANGO), (TREE, MANGO)], n, 10, 0, where=tall_ok)
            for (yy_, xx_, rows_, o_) in placed[-got:] if got else []:
                put(xx_ - 2, yy_ - 6, 'GD'); put(xx_ + 2, yy_ - 7, 'T4')
        elif k == 'prayer_flags':
            got = 0
            fl_c = ['RD', 'GD', 'T2', 'WH', 'GM']
            ok = soft & ~occ
            for (ox_, oy_) in sorted(((a, b) for a in range(-20, 21, 2) for b in range(-14, 15, 2)), key=lambda t: abs(t[0]) + abs(t[1])):
                x2, y2 = x + ox_, y + oy_
                pts_ = [(X, int(round(y2 - 3 + 2.5 * ((X - x2) / 12.0) ** 2))) for X in range(x2 - 12, x2 + 13)]
                if all(ok[Y, X] for (X, Y) in pts_) and ok[y2 - 6:y2 + 2, x2 - 13].all() and ok[y2 - 6:y2 + 2, x2 + 13].all():
                    x, y = x2, y2
                    break
            else:
                pts_ = None
            if pts_:
                for (X, Y) in ((x - 13, y), (x + 13, y)):
                    for j in range(6):
                        put(X, Y - j, 'S6' if j % 2 else 'K')
                for i, (X, Y) in enumerate(pts_):
                    put(X, Y, 'K')
                    if i % 2 == 0:
                        put(X, Y + 1, fl_c[(i // 2) % 5])
                    got += 1
                occ[y - 7:y + 3, x - 14:x + 15] = True
        elif k == 'slate_steps':
            got = 0
            for i in range(n * 2):
                ty0 = y - 6 + i * 3
                for X in range(x - 10 + i, x + 10 - i):
                    if okpx(X, ty0, soft) and okpx(X, ty0 + 1, soft):
                        put(X, ty0, 'AL'); put(X, ty0 + 1, 'D3')
                        occ[ty0:ty0 + 2, X] = True
                        got += 1
        elif k == 'grey_boulders':
            got = cluster(x, y, [(CRAG, None), (STONE, None), (PEBBLE, None), (PEAK_S, None)], n + 1, 12, 0, where=hard)
        elif k == 'frost_patch':
            got = decal(np.hypot((xx - x) / 9.0, (yy - y) / 4.0) + 0.5 * (vnoise(2, 160) - 0.5) < 1,
                        lambda m: (paint(m & ((xx + yy) % 2 == 0), 'WH'), paint(m & ((xx + yy) % 2 == 1), 'AL')))
        elif k == 'moth_temple_lanterns':
            got = cluster(x, y, [(STONELANT, None)], 2, 12, 0, where=soft)
            for (yy_, xx_, rows_, o_) in placed[-got:] if got else []:
                lanterns.append((xx_, yy_ - 4))
        elif k == 'pine':
            got = cluster(x, y, [(PINE, None), (PINE, SNOWPINE)], n, 12, 0, where=hard)
        elif k == 'stone_cairn':
            got = near(x, y, CAIRN, None, 12, 0, where=hard)
        elif k == 'pass_cut':
            got = 0   # the west road cuts through the spur: dark cut walls either side of the trunk
            X, Y, ux, uy = road_pt(x, y)
            for t in range(-9, 10):
                for s in (-1, 1):
                    X2 = int(round(X + ux * t + s * 5 * (-uy))); Y2 = int(round(Y + uy * t + s * 5 * ux))
                    if F[Y2, X2] and not keep_m[Y2, X2]:
                        put(X2, Y2, 'K'); put(X2 + s * 0, Y2 + s, 'AS' if s < 0 else 'S4')
                        got += 1
        elif k == 'ledge_steps':
            got = 0
            for i in range(n * 2):
                ty0 = y - 6 + i * 3
                for X in range(x - 9 + i, x + 9 - i):
                    if okpx(X, ty0, soft) and okpx(X, ty0 + 1, soft):
                        put(X, ty0, 'AL' if X % 5 else 'WH'); put(X, ty0 + 1, 'S4')
                        occ[ty0:ty0 + 2, X] = True
                        got += 1
        elif k == 'crescent_dune':
            got = decal((np.hypot((xx - x) / 12.0, (yy - y) / 5.0) < 1) & (np.hypot((xx - x - 3) / 10.0, (yy - y - 2) / 4.0) >= 1),
                        lambda m: (paint(m, 'SN'), paint(m & ~np.roll(m, 1, axis=0), 'CR'), paint(m & ~np.roll(m, -1, axis=0), 'S6')))
        elif k == 'wind_ripples':
            got = decal((np.hypot((xx - x) / 16.0, (yy - y) / 7.0) < 1) & ((yy + (xx // 5)) % 3 == 0) & (BAY > 0.25),
                        lambda m: paint(m, 'S6'))
        elif k == 'red_outcrop':
            got = cluster(x, y, [(STACK_S, REDSTACK), (STONE, REDROCK), (CRAG, REDROCK)], 2, 10, 0, where=hard)
        elif k == 'souk_awnings':
            got = cluster(x, y, [(AWNING, None), (SACKS, None)], 2, 10, 0, where=soft)
        elif k == 'savanna_grass':
            got = cluster(x, y, [(TUFT, GRASS_C), (GOLDTUFT, None), (TALLGRASS, None)], n * 2, 14, 0, where=soft)
        elif k == 'thorn_tree':
            got = cluster(x, y, [(THORN_W, ACACIA), (THORN, ACACIA), (THORN_S, ACACIA)], n, 12, 1, where=tall_ok)
            if got < n:
                got += cluster(x, y, [(THORN, ACACIA), (THORN_S, ACACIA)], n - got, 24, 0, where=soft & ~pixmask(road_px, 6), tries=800)
        elif k == 'baobab':
            got = near(x, y + 11, BAOBAB, BAOBAB_C, 10, 0, where=tall_ok) or near(x, y + 11, BAOBAB, BAOBAB_C, 30, 0, where=soft & ~pixmask(road_px, 5)) or near(120, 216, BAOBAB, BAOBAB_C, 20, 0, where=soft & ~pixmask(road_px, 5)) or near(268, 246, BAOBAB, BAOBAB_C, 20, 0, where=soft & ~pixmask(road_px, 5))
            if got:
                lanterns.append((got[0], got[1] - 8))
        elif k == 'ember_heath':
            got = cluster(x, y, [(HEATH, HEATH_C), (PROTEA, None), (HEATH, {'g': 'RD', 'a': 'S5'})], n * 3, 14, 0, where=soft)
        elif k == 'hoof_tracks':
            got = 0
            for X in range(x - 30, x + 30):
                Y = int(round(y + 3 * math.sin(X / 13.0)))
                if X % 3 and okpx(X, Y, soft):
                    put(X, Y, 'S5' if X % 3 == 1 else 'S6')
                    got += 1
        elif k == 'termite_mound':
            got = cluster(x, y, [(SPIRE_T, None), (SPIRE_TS, None)], 2, 16, 0, where=soft & ~pixmask(road_px, 5), tries=800)
        elif k == 'tiger_fern_band':
            got = 0
            for i in range(n):
                cx_, cy_ = x - 10 + i * 10, y - 4 + 4 * (i % 2)
                m = (np.hypot((xx - cx_) / 9.0, (yy - cy_) / 4.0) < 1) & (zone == 'jungle')
                st = ((xx - yy * 0.6 + 40) // 2).astype(int) % 3
                got += decal(m, lambda mm: (paint(mm & (st == 0), 'T4'), paint(mm & (st == 1), 'S2'), paint(mm & (st == 2), 'GK')))
        elif k == 'broadleaf_tree':
            got = cluster(x, y, [(BIGTREE, JUNGLE), (TREE, JUNGLE), (BIGTREE, HAZEL)], n, 14, 0, where=tall_ok)
        elif k == 'temple_roots':
            got = None
            for (dx, dy) in sorted(((a, b) for a in range(-14, 15) for b in range(-10, 11)), key=lambda t: abs(t[0]) + abs(t[1])):
                X, Y = x + dx, y + dy
                sl = (slice(Y - 8, Y + 2), slice(X - 7, X + 8))
                if hard[sl].all() and not occ[sl].any():
                    spr(X, Y + 1, ['..kkkkk..', '.kAaAaak.', 'kAa1a1aak', 'kaa111aak', 'kAa1a1aak', 'kkkkkkkkk'])
                    for (rx0, ry0, ln_) in ((X - 4, Y - 6, 6), (X + 2, Y - 7, 7), (X - 1, Y - 5, 5)):
                        for j in range(ln_):
                            put(rx0 + (j % 2), ry0 + j, 'S6')
                    put(X - 6, Y, 'GM'); put(X + 6, Y - 1, 'GM'); put(X + 5, Y, 'GK')
                    occ[sl] = True
                    got = (X, Y)
                    break
        elif k == 'firefly_dots':
            got = 0
            for i in range(n * 3):
                X = x + R.randint(-22, 22); Y = y + R.randint(-10, 10)
                if okpx(X, Y, soft):
                    put(X, Y, 'NW'); occ[Y, X] = True
                    got += 1
        elif k == 'paddy_squares':
            got = 0
            bw, bh = 12 * n + 1, 8
            cand_ = sorted(((a_, b_) for a_ in range(-40, 41, 2) for b_ in range(-30, 31, 2)), key=lambda t: abs(t[0]) + abs(t[1]))
            for (ox_, oy_) in cand_:
                px0, py0 = x - bw // 2 + ox_, y - bh // 2 + oy_
                sl = (slice(py0 - 1, py0 + bh + 1), slice(px0 - 1, px0 + bw + 1))
                if soft[sl].all() and not occ[sl].any():
                    for i in range(n):
                        for j in range(1):
                            qx, qy = px0 + i * 12, py0
                            rect(qx, qy, qx + 11, qy + 6, 'GM')
                            rect(qx + 1, qy + 1, qx + 10, qy + 5, 'WA')
                            for X in range(qx + 2, qx + 10, 2):
                                put(X, qy + 2, 'T1'); put(X + 1, qy + 4, 'WL' if X % 4 == 0 else 'GM')
                            got += 1
                    occ[sl] = True
                    break
        elif k == 'rice_mill_wheel':
            got = near(x, y, MILLWHEEL, None, 12, 0, where=soft)
        elif k == 'parrot_perch':
            got = near(x, y, PERCH, None, 12, 0, where=soft)
        elif k == 'vine_curtain':
            got = 0
            for i in range(n * 3):
                X = x - 6 + i * 3
                for Y in range(y - 12, y + 4):
                    if okpx(X, Y, soft | (~F & (outd < 4))):
                        put(X, Y, 'GK' if Y % 3 else 'GM')
                        got += 1
        elif k == 'bamboo':
            got = cluster(x, y, [(BAMBOO, None), (BAMBOO_S, None)], n, 12, 0, where=hard)
        elif k == 'blossom_tree':
            got = cluster(x, y, [(TREE, CHERRY), (BIGTREE, CHERRY)], n, 12, 0, where=tall_ok)
        elif k == 'copper_rock':
            got = cluster(x, y, [(STONE, COPPER), (CRAG, COPPER)], n, 10, 0, where=hard)
        elif k == 'stone_lantern':
            got = near(x, y, STONELANT, None, 12, 0, where=soft)
            if got:
                lanterns.append((got[0], got[1] - 4))
        elif k == 'lamp_post_dark':
            got = near(x, y, LAMP_DARK, None, 8, 0, where=F & ~keep_pad & ~road_m & ~occ_water)
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter
    zf = lambda z: free & (zone == z) & ~occ_water
    far_road = ~pixmask(road_px, 10)
    scatter([(BIGTREE, JUNGLE), (TREE, JUNGLE), (TREE, HAZEL)], 16, zf('jungle') & far_road & ~place18, pad=0, tries=5000)
    scatter([(FERN, JUNGLE), (FERN, None), (FERN_S, JUNGLE), (BUSH, None)], 30, zf('jungle'), pad=0, tries=4000)
    scatter([(TREE, CHERRY), (BAMBOO_S, None)], 6, zf('blossom') & far_road & ~place18, pad=1)
    scatter([(BUSH, CHERRY), (FERN_S, JUNGLE)], 16, zf('blossom'), pad=1)
    scatter([(BIRCHT, AUTUMN), (BIRCHT_S, AUTUMN)], 8, zf('birch') & far_road & ~place18, pad=1)
    scatter([(BRAMBLE, BRAMBLE_C), (TUFT, {'y': 'MY', 's': 'WH', 'S': 'AL', '5': 'MD'})], 16, zf('birch'), pad=1)
    scatter([(THORN_W, ACACIA), (THORN, ACACIA)], 5, zf('thorn') & far_road & ~place18, pad=3, tries=4000)
    scatter([(TUFT, GRASS_C), (TUFT, GRASS_C), (GOLDTUFT, None)], 30, zf('thorn'), pad=1)
    scatter([(PEBBLE, None), (STONE, None), (PEBBLE, SLATE)], 14, zf('roof'), pad=1)
    scatter([(PEAK_S, None), (CRAG, None)], 4, zf('roof') & ~place18, pad=1)
    scatter([(PEBBLE, REDROCK), (TUFT, {'y': 'SD', 's': 'CR', 'S': 'SN', '5': 'S6'})], 10, zf('dune'), pad=1)
    scatter([(GOLDTUFT, None), (TUFT, GRASS_C)], 14, zf('silt'), pad=2)
    scatter([(GOLDTUFT, None)], 8, zf('hub'), pad=2)
    scatter([(REED, None), (CATTAIL, None)], 18, dil8(dil8(occ_water)) & ~occ_water & free, pad=0)

    # lanterns beside the trunks (cream glow on warm ground)
    lamp_cand = pixmask(road_px, 6) & ~pixmask(road_px, 4) & free & ~occ
    ys, xs = np.nonzero(lamp_cand)
    idxs = list(range(len(xs)))
    R.shuffle(idxs)
    lamp_at = []
    for i in idxs:
        x, y = int(xs[i]), int(ys[i])
        if any((x - a) ** 2 + (y - b) ** 2 < 48 ** 2 for a, b in lamp_at + [(332, 144)]):
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'CR')
    for (x, y) in lanterns:
        glow(x, y, 9, 'GD')
    # long low shadows to the east (the light comes from the west)
    for (x, y, w) in shadows:
        for dx in range(1, w // 2 + 6):
            X, Y = x + dx, y
            if 0 <= X < W and F[Y, X] and not keep_pad[Y, X] and not road_m[Y, X] and not occ_water[Y, X]:
                if dx > w // 2 + 2 and (X + Y) % 2:
                    continue
                put(X, Y, 'S4' if zone[Y, X] in ('jungle', 'blossom', 'roof') else 'S5')
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
    keep = keep_m | pixmask(road_px, 4) | chan | dil8(peak)

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


    # few hanging roots: the plan's cluster west of the peak and short dry tufts elsewhere (never on the peak)
    for p in P['props']:
        if p['kind'] == 'hanging_roots':
            for k in range(p.get('n', 3)):
                root(p['x'] - 12 + k * 11, 18 + 7 * (k % 2), 2 if k != 1 else 3, SEED * 100 + 50 + k)
    for k in range(12):
        x0 = RS.randrange(160, W - 12)
        if abs(x0 - tipx) < 40:
            continue
        root(x0, RS.randint(8, 16), RS.choice([1, 1, 2]), SEED * 100 + k)
    # pale birch roots over the north-west, monsoon vines over the south-east
    for k in range(6):
        x0 = RS.randrange(30, 150)
        root(x0, RS.randint(8, 15), 1, SEED * 100 + 200 + k, col=('S6', 'AL'))
    for k in range(9):
        x0 = RS.randrange(10, W - 10)
        if not keep[H - 8:H, x0 - 4:x0 + 5].any():
            spr(x0, H - 3, SHROOM if k % 2 else SHROOM_S)
    for k in range(5):
        x0 = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x0 - 3:x0 + 4].any():
            spr(x0, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'RH', 'u': 'T4', 'n': 't4'} if k % 2 else None)

    # mouths: birch roots over the north mouth, a sand spill in the west, grass on the south lip,
    # petals and a violet rim in the east, vines and violet in the south-east corner
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        to = e['to']
        if to == 'EE':
            for s in (-1, 1):
                for j in range(0, 16):
                    X = ex + s * (5 + (j * j) // 40); Y = j
                    if road_m[Y, X] or keep_m[Y, X]:
                        continue
                    put(X, Y, 'AL'); put(X + s, Y, 'K')
                    if j % 3 == 0:
                        put(X - s, Y + 1, 'WH')
                    if j % 4 == 2:
                        put(X + 2 * s, Y, 'GD')
        elif to == 'MENA':
            for Y in range(ey - 9, ey + 10):
                for X in range(0, 14):
                    if road_m[Y, X] or keep_m[Y, X] or abs(Y - ey) < 2:
                        continue
                    if (X + Y) % 2 == 0 and BAY[Y, X] < 0.55 - X / 30.0:
                        put(X, Y, 'SN' if (X + Y) % 4 else 'CR')
        elif to in ('ESA', 'SEA'):
            for s in (-1, 1):
                for j in range(0, 12):
                    X = ex + s * (5 + j // 3)
                    Y = H - 13 + j
                    if not (0 <= X < W) or road_m[Y, X] or keep_m[Y, X]:
                        continue
                    if to == 'ESA':
                        put(X, Y, 'SD' if j % 2 else 'S5')
                        if j % 4 == 1:
                            put(X + s, Y, 'GD')
                    else:
                        put(X, Y, 'GK' if j % 2 else 'GM')
                        if j % 3 == 0:
                            put(X + s, Y - 1, 'T5')
            for X in range(ex - 10, ex + 11):   # the lip
                Y = H - 13 - (1 if abs(X - ex) > 6 else 0)
                if 0 <= X < W and not road_m[Y, X] and not keep_m[Y, X] and abs(X - ex) > 2:
                    if to == 'ESA':
                        put(X, Y, 'GD' if X % 2 else 'SD'); put(X, Y - 1, 'S5' if X % 3 else 'GD')
                    else:
                        put(X, Y, 'GM' if X % 2 else 'T1'); put(X, Y + 1, 'GK')
                        if X % 3 == 0:
                            for j in range(2, 6):
                                put(X, Y + j, 'GK' if j % 2 else 'GM')
        elif to == 'EA':
            for X in range(W - 14, W):
                for Y in range(ey - 10, ey + 11):
                    if road_m[Y, X] or keep_m[Y, X] or abs(Y - ey) < 2:
                        continue
                    if (X * 3 + Y * 5) % 11 == 0:
                        put(X, Y, 'PK' if (X + Y) % 2 else 'PL')
                    elif (X * 5 + Y) % 17 == 0:
                        put(X, Y, 'T5')

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
    for sid, nm in ((223, 'TIGER MOTH TEMPLE'), (219, 'CARAVANSERAI'), (218, 'FLOWER MARKET'), (226, 'PEARL DIVER COVE'), (214, 'GREAT MIGRATION'), (200, 'GREY WOLF KING')):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-CSA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-CSA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-CSA.png'))
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

