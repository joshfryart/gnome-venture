#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for WCA "The Greatcanopy" (band orange, Lv 35-45).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built on the
SA / CB generators: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside
with a dithered orange halo and an orange rim light (west of the Sunsprinkle Seal gate the rim takes
the gold of the Isles' band), biome ground (the red laterite Red Earth Clearing with its fonio plots,
gardenia hedges and the Seed Bed; the dark Bight along the north-west wall with canoe, fishing stakes
and a root islet; the Rootwater Fen with stilt roots and lily pools; the Deep Green rainforest; the
Silk Hollow with web veils and a pair of red eyes; Dunewhisper's sand spill with dunes; the Gold Grass
savanna with baobab, termite spires, acacias, talking drums, oil palms and a mist bank; the Snowcrown
Shelf with its green lower step and frost cap), the Great Taproot bole on the south-west wall with
buttress roots, two taproot pillars, glowing road trunks on the layout polylines (the new west road
as a stone-kerbed causeway through the Sunsprinkle Seal gate) and the three exit tunnel mouths; a
root-mat ceiling and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one or two flat tones, no sprites, no water, no texture); inside water each such disc is a bank.

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_WCA.py [--layout layout-WCA.json] [--plan plan-WCA.json]
                                     [--out game/assets/img/scenes/map2-WCA.png]
                                     [--preview PREVIEW-2x.png]
Defaults for --layout / --plan: $MAP_V2_LAYOUT / $MAP_V2_PLAN, else the planning scratchpad
files.  --preview also writes a 960x540 nearest-neighbour check image (art + placeholder markers
at the stops and spread positions, thick gold roots, a few names).
"""
import argparse, json, math, os, random
import numpy as np
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
SCRATCH = '/tmp/claude-0/-home-user-gnome-venture/30c9491a-86e7-530f-9f28-96d77dd01450/scratchpad'
W, H = 480, 270
yy, xx = np.mgrid[0:H, 0:W]
CODE = 'WCA'
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

# ---------------------------------------------------------------- shared sprites (from the SA generator)
LET.update({'U': 'WL', 'u': 'WA', 'z': 't2', 'D': 't1', 'v': 'T5', 'W': 'WH'})
MANGROVE = ['..kkkkk..', '.kGGgddk.', 'kGgggdddk', '.kkgdkdk.', '..kbkbk..', '.kb.b.bk.', 'kb..b..bk', 'b...b...b']
MANGROVE_S = ['.kkkk.', 'kGgddk', '.kbkbk', 'kb..bk', 'b....b']
CORAL = ['p.h', 'pPp', '.p.']
CORAL_G = {'p': 'GD', 'P': 'CR', 'h': 'T4'}
SHELL = ['.P.', 'PpP']
THORN = ['.kkkkkkkkk.', 'kddgdgdgddk', '.kkkkbkkkk.', '...kb.bk...', '....kbk....', '....kbk....', '....kkk....']
THORN_S = ['.kkkkkk.', 'kdgdgddk', '.kkbkkk.', '...bk...', '..kkk...']
YERBA = ['.kkkk.', 'kgddgk', 'kdDddk', 'kddDgk', '.kkkk.', '..kb..', '..kk..']
LOFT = ['.kkkkkk.', 'kSsSsSsk', 'kkkkkkkk', '.bkggkb.', '.b.gg.b.', '.b....b.', 'kk....kk']
CANOE = ['kkkkkkkk', 'kBbbbbBk', '.kkkkkk.']
STACK = ['.kkkk.', 'kAAa1k', 'kaaa1k', 'kssssk', 'kAaa1k', 'kaa11k', 'kssssk', 'kAaa1k', 'kaa11k', 'kkkkkk']
STACK_S = ['.kkk.', 'kAa1k', 'kssak', 'kaa1k', 'kkkkk']
REDSTACK = {'A': 'RH', 'a': 'RE', '1': 'RK', 's': 'SN'}
SEALSTONE = ['..k..', '.kAk.', 'kAyak', 'kayak', 'kAyak', 'kAaak', 'kkkkk']
CONDOR = {'A': 'D4', 'a': 'D3', '1': 'D2', 'w': 'AL'}
CORDSTONE = {'A': 'AL', 'a': 'AS', '1': 'S3'}
SNOWCRAG = {'A': 'WH', 'a': 'AL', '1': 'AS'}
LILY = ['.G.', 'gGg']
GOURDS = ['k...k', 'bkkkb', 'boyob', 'b.o.b', 'k...k']


def make_kapok(w=23, h=27):
    """the giant kapok: an emergent crown over a pale trunk with buttress roots"""
    g = [['.'] * w for _ in range(h)]
    ch = int(round(h * 0.56))
    cx, cy, rx, ry = (w - 1) / 2.0, (ch - 1) / 2.0, w / 2.0, ch / 2.0
    for y in range(ch):
        for x in range(w):
            e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if e <= 1.0:
                c = 'g'
                if (x - cx) + (y - cy) * 1.4 < -w * 0.22:
                    c = 'G'
                elif (x - cx) + (y - cy) * 1.2 > w * 0.18:
                    c = 'd'
                if e > 0.78:
                    c = 'k'
                g[y][x] = c
    R_ = random.Random(w * 31 + h)
    for _ in range(w // 3):   # glow dots in the crown
        x, y = R_.randrange(2, w - 2), R_.randrange(2, ch - 2)
        if g[y][x] in 'gGd':
            g[y][x] = 'y'
    tx = w // 2
    for y in range(ch - 1, h):
        for x in range(tx - 2, tx + 3):
            g[y][x] = 'k' if x in (tx - 2, tx + 2) else ('A' if x == tx - 1 else ('a' if x == tx else '1'))
    fl = min((w - 5) // 3, h - ch - 3)
    for j, y in enumerate(range(h - fl - 1, h)):   # buttress flares
        s_ = j + 1
        for x in range(tx - 2 - s_, tx - 2):
            if x >= 0:
                g[y][x] = 'k' if x == tx - 2 - s_ else ('A' if (x + y) % 3 else 'a')
        for x in range(tx + 3, tx + 3 + s_):
            if x < w:
                g[y][x] = 'k' if x == tx + 2 + s_ else ('a' if (x + y) % 3 else '1')
    for x in range(w):
        if g[h - 1][x] != '.':
            g[h - 1][x] = 'k'
    return [''.join(r) for r in g]


KAPOKS = [make_kapok(23, 27), make_kapok(21, 25), make_kapok(19, 23), make_kapok(17, 22), make_kapok(15, 22), make_kapok(13, 20)]
KAPOK = KAPOKS[0]
KAPOK_C = {'g': 'GM', 'G': 'T1', 'd': 'GK', 'A': 'AL', 'a': 'MY', '1': 'MD', 'y': 'GD'}

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



# ---------------------------------------------------------------- WCA sprites (The Greatcanopy)
GARDENIA = ['.kkk.', 'kwgWk', 'kgdwk', '.kkk.']
GARDENIA_C = {'w': 'WH', 'W': 'WH', 'g': 'GM', 'd': 'GK'}
TERMITE = ['..kk..', '.khek.', '.keek.', '.keRk.', 'kheeRk', 'keeeRk', 'keeRRk', 'kkkkkk']
TERMITE_S = ['.kk.', 'khek', 'keRk', 'keRk', 'kkkk']
BAOBAB = ['.k.kkk.k.kk..', 'kgkgGgkgkdgk.', '.kdkgkdkkgk..', '...kbkkbk....', '...kBbbbk....', '..kBBbbb4k...',
          '..kBbbbb4k...', '..kBbbbb4k...', '..kBBbbb4k...', '.kkBbbbb44k..', '.kkkkkkkkkk..']
ACACIA = ['.kkkkkkkkk.', 'kGgggggddgk', '.kkkkbkkkk.', '....kb.....', '...kb.bk...', '....kbk....', '....kbk....', '....kkk....']
DRUM = ['.kkk.', 'kBcBk', 'kbebk', 'kbRbk', '.kkk.']
OILPALM = ['k.kkk.k', 'Gkgggkg', '.kGgdk.', 'g.kbk.d', '...b...', '...B...', '..kbk..', '..kkk..']
DUGOUT = ['kkkkkkkkkk', 'kBbbbbbbBk', '.kkkkkkkk.']
COFFEE = ['.kkk.', 'kgrdk', 'kdgrk', '.kbk.']
STILT = ['..kkkkk..', '.kGgddgk.', 'kgggdddk.', '.kkbkbkk.', '.kb.b.bk.', 'kb..b..bk', 'b...b...b']
STILT_S = ['.kkkk.', 'kGgddk', '.kbkbk', 'kb..bk', 'b....b']
LSTEP = ['..kkkkkkk', '..khhhhhk', 'kkkeeeeek', 'khhRRRRRk', 'keeeeeeek', 'kRRRRRRRk', 'kkkkkkkkk']
SEALPOST = ['.kkk.', 'kAAak', 'kAyak', 'kAcak', 'kAyak', 'kAaak', 'kAaak', 'kAaa1', 'kkkkk']
GLOWSHROOM = ['.kk.', 'ktnk', '.kk.', '.b..']
FONIO_ROWS = ('SN', 'SD')


def make_column(w, h, lichen_seed=1):
    """a taproot coming down out of the root ceiling: bark grooves, lichen glow, a flared foot, top lost in the dark"""
    g = [['.'] * (w + 6) for _ in range(h)]
    R_ = random.Random(lichen_seed)
    for y in range(h):
        fl = 3 if y >= h - 2 else (2 if y >= h - 4 else (1 if y >= h - 7 else 0))
        x0, x1 = 3 - fl, 3 + w - 1 + fl
        for x in range(x0, x1 + 1):
            if x in (x0, x1) or y == h - 1:
                c = 'k'
            else:
                f = (x - x0) / max(1.0, (x1 - x0))
                c = 'B' if f < 0.3 else ('b' if f < 0.7 else '4')
                if (x * 3 + y // 2) % 5 == 0 and 0.2 < f < 0.9:
                    c = '3'
            if y < 5 and c != 'k' and (x + y) % (y + 2) != 0:   # fades into the root mat above
                c = 'k' if (x + y) % 2 == 0 or y < 2 else c
            g[y][x] = c
    for _ in range(max(3, h // 5)):
        x = R_.randrange(4, 3 + w - 1); y = R_.randrange(6, h - 2)
        if g[y][x] not in '.k':
            g[y][x] = 't' if R_.random() < .5 else 'n'
    return [''.join(r) for r in g]


def make_bole(w=26, h=70, seed=3):
    """the Great Taproot: the bole of the world-tree coming down out of the dark to the floor, grooved bark,
    glow lichen, a dark hollow, flared buttresses at the foot; its upper part is lost in shadow"""
    tw = w + 22
    g = [['.'] * tw for _ in range(h)]
    R_ = random.Random(seed)
    cx = tw // 2
    B4_ = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    TOP = 18   # the upper end splits into three tapering roots that climb back into the dark
    for y in range(h):
        t = y / (h - 1.0)
        hw = w / 2.0 - 3 + 3.0 * t + (max(0, t - 0.80) / 0.20) ** 2 * 10 + 0.8 * math.sin(y / 7.0)
        shade = max(0.0, 1 - t / 0.36) * 0.85     # darker toward the top
        spans = []
        if y < TOP:
            u = (TOP - y) / float(TOP)             # 1 at the top row, 0 where the trunk is whole
            for d in (-1, 0, 1):
                pc = cx + d * (hw - 2) * (0.55 + 0.9 * u) * (1 if d else 0) + (1.5 * u if d == 0 else 0)
                pw = (hw / 2.6) * (1 - 0.75 * u) + 0.6
                if d == 0 and u > 0.75:
                    continue
                spans.append((int(round(pc - pw)), int(round(pc + pw))))
        else:
            spans = [(int(round(cx - hw)), int(round(cx + hw)))]
        for (x0, x1) in spans:
            for x in range(max(0, x0), min(tw, x1 + 1)):
                if x in (x0, x1) or y == h - 1:
                    c = 'k'
                else:
                    f = (x - x0) / max(1.0, (x1 - x0))
                    c = 'B' if f < 0.22 else ('b' if f < 0.62 else ('4' if f < 0.86 else '3'))
                    gx = (x + int(2 * math.sin(y / 6.0 + x * 0.3)))
                    if gx % 5 == 0 and 0.1 < f < 0.95:
                        c = '3' if f > 0.5 else '4'
                    th = (B4_[y % 4][x % 4] + 0.5) / 16.0
                    if shade > th:
                        c = '1' if shade > th + 0.35 else ('2' if c in 'B3' or shade > th + 0.15 else '3')
                g[y][x] = c
    for y in range(h):       # close the tops of the climbing roots
        for x in range(tw):
            if g[y][x] != '.' and (y == 0 or g[y - 1][x] == '.'):
                g[y][x] = 'k'
    hy, hx_ = int(h * 0.72), cx + 2
    for y in range(hy - 5, hy + 4):
        for x in range(hx_ - 3, hx_ + 4):
            if ((x - hx_) / 3.3) ** 2 + ((y - hy) / 4.6) ** 2 < 1:
                g[y][x] = 'k'
    g[hy + 2][hx_ - 1] = 'n'; g[hy + 2][hx_ + 1] = 'n'; g[hy + 1][hx_] = 't'
    n_ = 0
    while n_ < 16:
        x = R_.randrange(3, tw - 3); y = R_.randrange(int(h * 0.3), h - 3)
        if g[y][x] in 'bB43' and g[y][x + 1] in 'bB43':
            g[y][x] = 't'; g[y][x + 1] = 'n'
        n_ += 1
    return [''.join(r) for r in g]


BOLE = make_bole()
COLUMN = make_column(6, 26, 11)
COLUMN_S = make_column(5, 18, 12)


# ================================================================ RENDER
def render(L, P, slots, spread, anchors):
    global img
    R = random.Random(SEED)
    img = np.zeros((H, W, 3), np.uint8)
    keeps = keep_circles(L, slots, spread)
    exits = {e['id']: e for e in L['exits']}

    roads, west_road = [], None
    for rd in L['roads']:
        pts = [tuple(p) for p in rd['pts']]
        last = rd['nodes'][-1]
        if last in exits:
            e = exits[last]
            pts = pts + [edge_pt(e['x'], e['y'], e['side'])]
            if e['to'] == 'CB':
                west_road = len(roads)
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
    root_dry = pixmask(root_px, 3)   # the roots run on dry ground (a raised root causeway through the fen)

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

    # west of the Seal gate the cavern belongs to the Isles' band (gold); dithered seam
    gate_x = 98
    for p in P['props']:
        if p['kind'].startswith('gate_'):
            gate_x = p['x']
    westb = (xx + 10 * (BAY - 0.5) * 2) < gate_x - 4

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
    halo_d = ~F & (outd > 4) & (hval ** 1.5 > BAY + 0.04)
    halo_b = ~F & (outd > 4) & (outd < 8) & (hval ** 3 > BAY + 0.35)
    paint(halo_d & ~westb, DIM); paint(halo_d & westb, 't3')
    paint(halo_b & ~westb, BRIGHT); paint(halo_b & westb, 'T3')
    for _ in range(70):
        x = R.randrange(2, W - 3); y = R.randrange(14, H - 14)
        if outd[y, x] < 7 or F[y, x]:
            continue
        b, dm = R.choice([('T2', 't2'), ('T5', 't5'), ('NW', 'ND'), ('GD', 't3'), (BRIGHT, DIM), (BRIGHT, DIM)])
        put(x, y, b); put(x, y + 1, dm)
        if R.random() < .3:
            put(x, y - 1, 'WH')

    # ------------------------------------------------ 2. ZONES from the plan biomes (noisy edges)
    zone = np.full((H, W), 'base', dtype=object)   # base = the forest edge between the named zones
    zmask = {}
    KEY = {'laterite_clearing': 'clear', 'bight_water': 'bight', 'mangrove_fen': 'fen', 'canopy_rainforest': 'canopy',
           'spider_silk_grove': 'silk', 'sahel_sand': 'sand', 'thorn_savanna': 'grass', 'snow_highland': 'shelf'}
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
    for key in ['grass', 'sand', 'canopy', 'shelf', 'fen', 'clear', 'silk', 'bight']:
        if key in zmask:
            zone[zmask[key] & F] = key
    # the Snowcrown Shelf: a green lower step on its west side, bare stone and frost on the east
    if 'shelf' in zmask:
        stepm = (zone == 'shelf') & (xx + 8 * (vnoise(4, 160) - 0.5) < 438)
        zone[stepm] = 'step'
    # the waters
    bightw = np.zeros((H, W), bool)
    fenw = np.zeros((H, W), bool)
    if 'bight' in zmask:
        bz = zmask['bight'] & F
        bd = blur(bz.astype(float), 3)
        bightw = bz & (bd + 0.30 * (vnoise(6, 150) - 0.5) > 0.62) & (vnoise(5, 156) < 0.90)
    if 'fen' in zmask:
        fenw = zmask['fen'] & (vnoise(6, 152) + 0.12 * (vnoise(2, 153) - 0.5) > 0.655) & (depth > 2)
    bole_dry = np.zeros((H, W), bool)
    for p in P['props']:   # dry ground round the foot of the Great Taproot
        if p['kind'] == 'great_taproot_bole':
            bole_dry = (((xx - p['x']) / 34.0) ** 2 + ((yy - p['y'] - 20) / 22.0) ** 2) < 1
    fenw &= ~bole_dry
    for p in P['props']:   # the lily pools are always there
        if p['kind'] == 'lily_pool':
            fenw |= (((xx - p['x']) / 11.0) ** 2 + ((yy - p['y']) / 6.0) ** 2 + 0.5 * (vnoise(2, 154) - 0.5)) < 1
    fenw &= F

    RAMPS = {
        'base': ['t1', 'GK', 'GK', 'GM'], 'canopy': ['t1', 't1', 'GK', 'GM'], 'clear': ['RK', 'RK', 'RE', 'RE'],
        'bight': ['t1', 'GK', 'GK', 'GM'], 'fen': ['t1', 'GK', 'GK', 'GM'], 'silk': ['D2', 'D3', 'D3', 'D4'],
        'sand': ['S6', 'SD', 'SD', 'SN'], 'grass': ['t3', 'S6', 'SD', 'SD'], 'shelf': ['S4', 'AS', 'AS', 'AL'],
        'step': ['t1', 'GK', 'GM', 'GM'],
    }
    BIAS = {'base': 0.0, 'canopy': -0.06, 'clear': 0.06, 'bight': -0.04, 'fen': -0.04, 'silk': -0.08,
            'sand': 0.10, 'grass': 0.08, 'shelf': 0.06, 'step': 0.02}

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
    gi = np.where(keep_m, np.clip(gi, 1, 2), gi)   # plain floor in the keep circles
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
    busyok = F & ~keep_m & (depth > 2) & ((kd > 5) | (BAY < kd / 5.0))
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname) & (zone != 'silk')
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    # forest: dark fronds, sparse T1 highlights
    jz = busyok & ((zone == 'canopy') | (zone == 'base') | (zone == 'step'))
    paint(jz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    paint(jz & (vnoise(1, 66) > 0.975) & (gi >= 2), 'T1')
    # red laterite: RK dither patches, S6 foot-worn paths, fonio specks
    cz = busyok & (zone == 'clear')
    paint(cz & (vnoise(4, 90) > 0.58) & ((xx + yy) % 2 == 0), 'RK')
    pth = (np.abs(np.sin((xx * 0.4 + yy * 0.9 + 10 * vnoise(10, 91)) / 2.6)) < 0.10) & (vnoise(6, 92) > 0.55)
    paint(cz & pth, 'S6')
    paint(cz & (vnoise(1, 93) > 0.965), 'SN')
    # fen: ND / GK dither, reeds flecks
    fz = busyok & (zone == 'fen')
    paint(fz & ((xx + yy) % 2 == 0) & (vnoise(5, 94) > 0.62), 'ND')
    paint(fz & (vnoise(1, 89) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    paint(fz & (vnoise(1, 95) > 0.93), 'GM')
    # Bight shore: wet dark sand with grit
    bz_ = busyok & (zone == 'bight')
    paint(bz_ & (vnoise(1, 96) > 0.90), 't1')
    # Silk Hollow: faint web threads over a dark floor
    sz = busyok & (zone == 'silk')
    thr = ((np.abs(((xx + 2 * yy) % 13) - 0) < 1) | (np.abs(((xx - 2 * yy) % 17) - 0) < 1)) & (vnoise(3, 97) > 0.52)
    paint(sz & thr, 'D4')
    paint(sz & thr & (vnoise(1, 98) > 0.80), 'AL')
    # sand spill: dune ripples, grit
    dz = busyok & (zone == 'sand')
    rip = np.abs(np.sin((yy * 1.2 + 5 * np.sin(xx / 10.0) + 7 * vnoise(8, 99)) / 1.7)) > 0.93
    paint(dz & rip & (gi >= 2), 'SN')
    paint(dz & np.roll(rip, -1, axis=0) & ~rip & (gi >= 1), 'S6')
    paint(dz & (vnoise(1, 100) > 0.96), 'S5')
    # gold grass: T3 dither flecks, t3 shadows, vertical stalk ticks
    gz = busyok & (zone == 'grass')
    gold = vnoise(5, 107)
    paint(gz & (gold > 0.42) & ((xx + yy) % 2 == 0) & (gi >= 1), 'T3')
    paint(gz & (gold > 0.62) & (gi >= 2), 'T3')
    paint(gz & (vnoise(1, 101) > 0.86) & ((xx + yy) % 2 == 0), 'T3')
    blade = ((xx * 5 + (yy // 2) * 3) % 7 == 0) & (yy % 2 == 0) & (vnoise(3, 108) > 0.35)
    paint(gz & blade, 'S6')
    paint(gz & np.roll(blade, -1, axis=0) & ~blade, 'SN')
    paint(gz & (vnoise(1, 102) > 0.92), 't3')
    stalk = (vnoise(1, 103) > 0.88)
    paint(gz & stalk, 'SN')
    paint(gz & np.roll(stalk, 1, axis=0) & ~stalk, 't3')
    # Shelf: stone ledges and cracks; frost on the upper stone; green step with coffee-red flecks
    oz = busyok & (zone == 'shelf')
    ledge = ((yy + (xx // 13) * 2) % 6 == 0) & (vnoise(4, 104) > 0.3)
    paint(oz & ledge, 'S4')
    paint(oz & np.roll(ledge, 1, axis=0) & ~ledge, 'AL')
    frost = vnoise(6, 105)
    paint(oz & (frost > 0.45) & ((xx + yy) % 2 == 0), 'WL')
    paint(oz & (frost > 0.58), 'WH')
    paint(oz & (frost > 0.58) & ledge, 'AL')
    stz = busyok & (zone == 'step')
    paint(stz & (vnoise(1, 106) > 0.95), 'RD')
    # rim: K outline, band-colour rim light (orange; gold west of the Seal gate), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3 & ~westb, DIM); paint(d4 & ~d3 & westb, 't3')
    paint(d3 & ~d1 & ~westb, BRIGHT); paint(d3 & ~d1 & westb, 'T3')
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0) & ~westb, DIM)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0) & westb, 't3')
    paint(d1 & ~F, 'K')

    # ------------------------------------------------ 4. WATERS: the Bight, the fen pools
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on its own bank / islet
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 1 + 2.5 * isl
    band = pixmask(road_px, 4)
    pools = (bightw | fenw) & F & ~keep_wet & ~band & ~root_dry
    pools = ero4(dil4(pools)) & ~keep_wet & F & ~band & ~root_dry
    pools &= ~dil4(ero4(ero4(~pools)))  # drop slivers
    water = pools
    occ_water = water
    bw = water & bightw
    fw = water & fenw & ~bightw
    sh = dil8(water) & ~water & F & ~keep_m
    paint(sh & dil8(bw), 'SD')
    paint(sh & dil8(fw) & ~dil8(bw), 'S5')
    paint(dil8(sh) & ~sh & ~water & F & ~keep_m & dil8(dil8(dil8(bw))) & (BAY > 0.5), 'S5')
    # the Bight: dark gulf, WA shallows at the shore, WL glints
    bdist = np.zeros((H, W), float)
    m = bw.copy()
    for i in range(8):
        bdist += m
        m = ero4(m)
    paint(bw, 'D2')
    paint(bw & (bdist >= 4) & ((xx + yy) % 2 == 0), 'D1')
    paint(bw & (bdist >= 3) & (bdist < 5) & (BAY > 0.55), 'D3')
    paint(bw & (bdist < 3), 'WA')
    paint(bw & (bdist == 2) & ((xx + yy) % 2 == 0), 'D3')
    glint = (vnoise(1, 157) > 0.80) & (yy % 5 == 2)
    glint = glint | np.roll(glint, 1, axis=1)
    paint(bw & (bdist >= 3) & glint & (vnoise(7, 158) > 0.55), 'WA')
    paint(bw & (bdist >= 3) & glint & (vnoise(7, 158) > 0.55) & (vnoise(1, 159) > 0.75), 'WL')
    # the fen pools: WA dithered with GK, lily pads
    paint(fw, 'WA')
    paint(fw & ((xx + yy) % 2 == 0), 'GK')
    paint(fw & ero4(fw) & (yy % 3 == 1) & ((xx * 3 + yy) % 7 == 0), 'WL')
    paint(water & grow(~F, 4) & (BAY > 0.3), 'D2')

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
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + 0.12) & ((xx + yy) % 2 == 0), col)

    def okpix(x, y, where):
        return 0 <= x < W and 0 <= y < H and where[y, x] and not occ[y, x]

    log = []
    late = []          # things painted after the sprites (webs, stakes, the gate)
    hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water & ~place18
    soft = F & ~keep_pad & ~near_road & ~occ_water     # tall landmarks may stand under a root line
    bole_at = None
    columns = []
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        if k == 'great_taproot_bole':
            # the bole stands on the south-west wall: its foot may go over the rim, never into a keep circle
            okb = ~keep_pad & ~near_road & ~root_corr
            got = None
            for dy in range(24, 40):
                y0 = y + dy - len(BOLE) + 1
                x0 = x - len(BOLE[0]) // 2
                if fits(x0, y0, BOLE, 1, okb | ~F):
                    try_place(x, y + dy, BOLE, None, 1, okb | ~F)
                    got = bole_at = (x, y + dy)
                    break
            if bole_at:
                # buttress roots fanning out north-east over the fen floor
                bx, by = bole_at
                rr_ = random.Random(77)
                fans = [(-60, 28), (-38, 34), (-15, 30), (8, 22), (-82, 20)]
                for ang, ln in fans:
                    a = math.radians(ang)
                    sx, sy = bx + 10 * math.cos(a), by - 4 + 6 * math.sin(a)
                    px_ = []
                    for t in range(ln):
                        X = int(round(sx + t * math.cos(a) + 1.5 * math.sin(t / 4.0 + ang)))
                        Y = int(round(sy + t * math.sin(a) * 0.55))
                        if not (0 <= X < W and 0 <= Y < H) or keep_pad[Y, X] or near_road[Y, X] or root_corr[Y, X]:
                            break
                        px_.append((X, Y))
                    th = 3
                    for i_, (X, Y) in enumerate(px_):
                        tt = th if i_ < len(px_) * 0.5 else (2 if i_ < len(px_) * 0.8 else 1)
                        for o in range(-1, tt + 1):
                            put(X, Y + o, 'K')
                        for o in range(0, tt):
                            put(X, Y + o, 'S6' if o == 0 else ('S5' if o == 1 else 'S4'))
                        occ[max(0, Y - 2):Y + tt + 2, max(0, X - 1):X + 2] = True
                    if px_ and rr_.random() < 0.7:
                        X, Y = px_[len(px_) // 2]
                        put(X, Y, 'NW')
                glow(bx + 4, by - 22, 22, 'ND', extra=F & ~occ_water & ~occ)
        elif k == 'taproot_pillar':
            got = None
            for col in (COLUMN, COLUMN_S):
                got = near(x, y, col, None, 12, 0, where=soft)
                if got:
                    columns.append((got, col))
                    break
        elif k == 'seed_bed_fonio_gardenia':
            got = None
            for (dx, dy) in [(0, 0), (2, 1), (-2, 1), (0, 3), (3, -2), (-3, -1), (-5, 2), (0, -4), (-6, -3)]:
                gx, gy = x + dx, y + dy
                sl = (slice(gy - 4, gy + 5), slice(gx - 8, gx + 9))
                okm = F & ~keep_pad & ~near_road & ~occ_water & ~root_corr
                if okm[sl].all() and not occ[sl].any():
                    rect(gx - 8, gy - 4, gx + 8, gy + 4, 'K')
                    rect(gx - 7, gy - 3, gx + 7, gy + 3, 'S4')
                    for Y in range(gy - 2, gy + 3):
                        for X in range(gx - 6, gx + 7):
                            if Y % 2 == 0:
                                put(X, Y, 'SN' if (X + Y // 2) % 3 else 'SD')
                            else:
                                put(X, Y, 'S5')
                    for X in range(gx - 7, gx + 8):     # gardenia edging
                        for Y in (gy - 3, gy + 3):
                            put(X, Y, 'WH' if X % 3 == 0 else 'GK')
                    for Y in range(gy - 3, gy + 4):
                        for X in (gx - 7, gx + 7):
                            put(X, Y, 'WH' if Y % 3 == 0 else 'GK')
                    occ[sl] = True
                    got = (gx, gy)
                    break
        elif k == 'fonio_plot':
            got = 0
            for i in range(n * 30):
                if got >= n:
                    break
                gx = x + R.randint(-8, 8); gy = y + R.randint(-5, 5)
                sl = (slice(gy - 3, gy + 4), slice(gx - 6, gx + 7))
                okm = F & ~keep_pad & ~near_road & ~occ_water & ~root_corr
                if okm[sl].all() and not occ[sl].any():
                    rect(gx - 5, gy - 2, gx + 5, gy + 2, 'S4')
                    for X in range(gx - 5, gx + 6):
                        put(X, gy - 2, 'K'); put(X, gy + 2, 'K')
                        put(X, gy - 1, 'SN' if X % 2 else 'SD'); put(X, gy + 1, 'SD' if X % 2 else 'SN')
                    put(gx - 6, gy, 'K'); put(gx + 6, gy, 'K')
                    occ[sl] = True
                    got += 1
        elif k == 'gardenia_bush':
            got = cluster(x, y, [(GARDENIA, GARDENIA_C)], n, 7, 0, where=F & ~keep_pad & ~near_road & ~occ_water & ~root_corr)
        elif k.startswith('gate_'):
            late.append(('gate', x, y))
            got = 'late'
        elif k == 'web_veil':
            late.append(('web', x, y, n))
            got = 'late'
        elif k == 'stilt_roots':
            got = cluster(x, y, [(STILT, None), (STILT_S, None)], n, 10, 0, where=soft & ~root_corr | (wet_free & ~place18))
        elif k == 'lily_pool':
            got = cluster(x, y, [(LILY, None)], n * 3, 9, 0, where=wet_free)
        elif k == 'dugout_canoe':
            got = near(x, y, DUGOUT, None, 14, 1, where=wet_free & bightw)
        elif k == 'fishing_stakes':
            late.append(('stakes', x, y, n))
            got = 'late'
        elif k == 'root_islet':
            got = None
            okm = bightw & occ_water & ~keep_pad & ~root_corr
            for (dx, dy) in sorted([(a, b) for a in range(-10, 11, 2) for b in range(-8, 9, 2)], key=lambda t: t[0] ** 2 + t[1] ** 2):
                gx, gy = x + dx, y + dy
                isl_m = (((xx - gx) / 7.5) ** 2 + ((yy - gy) / 3.6) ** 2) < 1
                if (okm | ~isl_m)[gy - 12:gy + 6, gx - 10:gx + 11].all() and okm[isl_m].all():
                    paint(dil8(isl_m), 'K')
                    paint(isl_m, 'S5')
                    paint(isl_m & ((xx + yy) % 3 == 0), 'S6')
                    paint(isl_m & (yy < gy - 1), 'GK')
                    for (rx_, ry_) in ((gx - 6, gy + 2), (gx + 5, gy + 2), (gx - 2, gy + 3), (gx + 2, gy + 3)):
                        put(rx_, ry_, 'S6'); put(rx_, ry_ + 1, 'K')
                    spr(gx, gy, TREE, JUNGLE)
                    occ[gy - 12:gy + 6, gx - 10:gx + 11] = True
                    got = (gx, gy)
                    break
        elif k == 'laterite_step':
            got = cluster(x, y, [(LSTEP, None)], n, 10, 0, where=hard)
        elif k == 'termite_spire':
            got = cluster(x, y, [(TERMITE, None), (TERMITE_S, None), (TERMITE, None)], n, 12, 0, where=hard)
        elif k == 'baobab':
            got = near(x, y, BAOBAB, None, 14, 0, where=hard)
            if got:
                glow(got[0], got[1] - 5, 12, 't4', extra=F & (zone == 'grass'))
        elif k == 'flat_top_acacia':
            got = cluster(x, y, [(ACACIA, None)], n, 12, 0, where=hard)
        elif k == 'talking_drums':
            got = cluster(x, y, [(DRUM, None)], n, 6, 0, where=hard)
        elif k == 'oil_palm':
            got = cluster(x, y, [(OILPALM, None), (PALM, None)], n, 12, 0, where=hard)
        elif k == 'mist_bank':
            got = 0
            for i in range(n):
                mx, my = x - 10 + 20 * i, y - 2 + 4 * i
                mm = (((xx - mx) / 22.0) ** 2 + ((yy - my) / 4.5) ** 2) < 1
                mm &= F & ~keep_pad & ~near_road & ~root_corr & ~occ
                paint(mm & ((xx + yy) % 2 == 0) & (BAY > 0.25), 'AL')
                paint(mm & ((xx + 3 * yy) % 4 == 0) & (np.abs(yy - my) < 2), 'WH')
                got += int(mm.sum())
        elif k == 'sand_dune':
            got = 0
            for i in range(n):
                dx_, dy_ = x - 16 + 16 * i + R.randint(-3, 3), y - 4 + 8 * (i % 2) + R.randint(-2, 2)
                for t in range(-9, 10):
                    X = dx_ + t
                    Y = dy_ + int(round(0.06 * t * t))
                    if okpix(X, Y, hard) and okpix(X, Y + 1, hard):
                        put(X, Y, 'SN'); put(X, Y + 1, 'S6')
                        if t % 3 == 0:
                            put(X, Y + 2, 'S5')
                        got += 1
        elif k == 'snow_crag':
            got = cluster(x, y, [(CRAG, SNOWCRAG), (PEAK_S, None), (CRAG, FROSTSTONE)], n, 8, 0, where=hard | (F & (zone == 'shelf') & ~keep_pad & ~root_corr))
        elif k == 'hanging_roots':
            late.append(('hroots', x, y, n))
            got = 'late'
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter: crowns under 8 px within 10 px of the roads so the cross at the Market reads
    zf = lambda z: free & (zone == z)
    far_road = ~pixmask(road_px, 10)
    tall_j = [(BIGTREE, JUNGLE), (TREE, JUNGLE), (TREE, HAZEL), (BIGTREE, HAZEL), (OILPALM, None)]
    low_j = [(FERN, JUNGLE), (FERN, None), (FERN_S, JUNGLE), (BUSH, None), (TREE_S, JUNGLE), (TREE_S, HAZEL)]
    scatter([(KAPOKS[4], KAPOK_C), (KAPOKS[5], KAPOK_C)], 4, zf('canopy') & far_road & ~place18, pad=1, tries=3000)
    scatter(tall_j + [(BIGTREE, JUNGLE)], 150, zf('canopy') & far_road, pad=0, tries=9000)
    scatter(low_j, 140, zf('canopy'), pad=0, tries=8000)
    low_ok = F & ~keep_pad & ~near_road & ~dil4(occ_water) & (depth >= 2)   # low plants may sit under a root line
    scatter(low_j + [(TREE_S, JUNGLE)], 90, low_ok & ((zone == 'canopy') | (zone == 'base')), pad=0, tries=8000)
    scatter([(TREE, JUNGLE), (BIGTREE, JUNGLE), (TREE, HAZEL)], 60, free & ((zone == 'canopy') | (zone == 'base')), pad=0, tries=6000)
    scatter(tall_j, 60, zf('base') & far_road, pad=0, tries=5000)
    scatter(low_j, 70, zf('base'), pad=0, tries=5000)
    scatter([(GARDENIA, GARDENIA_C), (BUSH, None), (FERN_S, JUNGLE)], 10, zf('clear') & far_road, pad=1)
    scatter([(STILT, None), (STILT_S, None), (CATTAIL, None), (REED, None), (TREE_S, HAZEL), (BUSH, None)], 46, zf('fen'), pad=0)
    scatter([(REED, None), (CATTAIL, None), (PEBBLE, WARMSTONE)], 14, zf('bight'), pad=0)
    scatter([(PALM, None), (PEBBLE, WARMSTONE), (STONE, WARMSTONE), (SAGUARO_S, None)], 16, zf('sand') & far_road, pad=1)
    scatter([(PEBBLE, WARMSTONE)], 8, zf('sand'), pad=1)
    scatter([(TALLGRASS, None), (TALLGRASS, None), (ACACIA, None), (TERMITE_S, None), (THORN_S, None)], 40, zf('grass') & far_road, pad=0)
    scatter([(TALLGRASS, None)], 24, zf('grass'), pad=0)
    scatter([(COFFEE, None), (BUSH, None), (TREE_S, JUNGLE)], 14, zf('step'), pad=0)
    scatter([(CRAG, SNOWCRAG), (PEAK_S, None), (STONE, FROSTSTONE), (PEBBLE, FROSTSTONE), (PINE, SNOWPINE)], 16, zf('shelf'), pad=0)
    scatter([(DEADTREE, None), (PEBBLE, OBSIDIAN)], 5, zf('silk') & far_road, pad=1)
    shore_ = dil8(dil8(occ_water)) & ~occ_water & free
    scatter([(REED, None), (CATTAIL, None)], 18, shore_ & (zone == 'fen'), pad=0)
    scatter([(LILY, None)], 16, wet_free & fenw, pad=0)
    # blossom dots: PK, PL, T4, GD in the forest; gardenia white only round the clearing
    fl = free & ~occ & ~dil4(occ)
    fpix = fl & ((zone == 'canopy') | (zone == 'base')) & (vnoise(1, 86) > 0.90) & (vnoise(7, 87) > 0.45)
    sel = (xx * 7 + yy * 13) % 4
    for i, c in enumerate(['PK', 'PL', 'T4', 'RD']):
        paint(fpix & (sel == i), c)
    paint(fl & (zone == 'fen') & (vnoise(1, 88) > 0.985), 'PK')   # fen orchids

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
        if x < gate_x:   # west of the Seal gate the road is newly opened: no lamps yet
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'GD')
    for (got, col) in columns:   # lichen glow at the foot of the taproot pillars
        glow(got[0], got[1] - 3, 9, 'ND', extra=F & ~occ_water)
    for (y, x, rows, over) in sorted(placed, key=lambda t: t[0]):
        spr(x, y, rows, over)
    # sunbirds / parrots: a red and gold fleck on a few canopy crowns
    q = 0
    for (y, x, rows, over) in placed:
        if q >= 5:
            break
        if rows is BIGTREE and zone[y, x] in ('canopy', 'base'):
            put(x + 2, y - 9, 'RD'); put(x + 3, y - 9, 'GD'); put(x + 3, y - 8, 'T2')
            q += 1

    # late props: web veils, fishing stakes, hanging roots
    for item in late:
        if item[0] == 'web':
            _, x, y, n = item
            for i in range(n):
                cx_, cy_ = x + (i * 9 - 4), y - 6 + 5 * i
                for ang in range(0, 360, 45):
                    a = math.radians(ang + 10 * i)
                    for t in range(1, 8):
                        X, Y = int(round(cx_ + t * math.cos(a))), int(round(cy_ + t * math.sin(a) * 0.8))
                        if 0 <= X < W and 0 <= Y < H and not keep_pad[Y, X] and not root_corr[Y, X]:
                            put(X, Y, 'AL' if t % 3 else 'WH')
                for rad in (3, 5, 7):
                    for ang in range(0, 360, 12):
                        a = math.radians(ang)
                        X, Y = int(round(cx_ + rad * math.cos(a))), int(round(cy_ + rad * math.sin(a) * 0.8))
                        if 0 <= X < W and 0 <= Y < H and not keep_pad[Y, X] and not root_corr[Y, X] and (ang // 12) % 2 == 0:
                            put(X, Y, 'AL')
                for Y in range(0, cy_ - 6):   # the anchor thread up to the ceiling
                    if not keep_pad[Y, cx_] and not root_corr[Y, cx_]:
                        put(cx_, Y, 'AL' if Y % 2 else 'D4')
            log.append(('web_veil_drawn', x, y))
        elif item[0] == 'stakes':
            _, x, y, n = item
            got = 0
            for i in range(n * 4):
                if got >= n:
                    break
                X, Y = x - 10 + 7 * i + R.randint(-1, 1), y + R.randint(-3, 3)
                if all(okpix(X, Y - j, wet_free) for j in range(0, 5)):
                    put(X, Y - 4, 'K'); put(X, Y - 3, 'S6'); put(X, Y - 2, 'S5'); put(X, Y - 1, 'S5'); put(X, Y, 'K')
                    put(X - 1, Y + 1, 'WL'); put(X + 1, Y + 1, 'WL')
                    if got:
                        for t in range(1, 7):   # a net line between stakes
                            if okpix(X - t, Y - 3 + (t % 2), wet_free):
                                put(X - t, Y - 3 + (t % 2), 'AL')
                    got += 1
            log.append(('stakes_drawn', x, y, got))
        elif item[0] == 'hroots':
            _, x, y, n = item
            got = 0
            for i in range(n * 3):
                if got >= n:
                    break
                X = x - 8 + 5 * got + R.randint(-1, 1)
                ln = R.randint(10, 16)
                Y0 = y - ln
                if not all(okpix(X, Y, F & ~keep_pad & ~near_road & ~root_corr) for Y in range(Y0, y + 1)):
                    continue
                for Y in range(Y0, y + 1):
                    sw = int(round(math.sin(Y / 3.0 + X) * 0.6))
                    put(X + sw - 1, Y, 'K'); put(X + sw, Y, 'S5' if Y % 4 else 'S6'); put(X + sw + 1, Y, 'K')
                put(X, y + 1, 'NW'); put(X, y + 2, 'ND')
                got += 1
            log.append(('hroots_drawn', x, y, got))

    # ------------------------------------------------ 6. ROADS: glowing mycelium trunks (no trails)
    for px in roads:
        for (x, y) in px:
            for ox in range(-3, 4):
                for oy in range(-3, 4):
                    if 4 < ox * ox + oy * oy <= 10 and (x + ox + y + oy) % 2 == 0:
                        X, Y = x + ox, y + oy
                        if 0 <= X < W and 0 <= Y < H and F[Y, X] and not occ_water[Y, X]:
                            put(X, Y, 'S6')
    # the new west road: a stone-kerbed causeway through the fen (freshly opened)
    if west_road is not None:
        px = roads[west_road]
        for i in range(1, len(px) - 1):
            x, y = px[i]
            dx_, dy_ = px[i + 1][0] - px[i - 1][0], px[i + 1][1] - px[i - 1][1]
            ln = math.hypot(dx_, dy_) or 1
            nx_, ny_ = -dy_ / ln, dx_ / ln
            for s in (-1, 1):
                X, Y = int(round(x + s * 4 * nx_)), int(round(y + s * 4 * ny_))
                if 0 <= X < W and 0 <= Y < H and F[Y, X] and not keep_m[Y, X] and not road_m[Y, X]:
                    put(X, Y, 'AL' if i % 3 == 0 else 'AS')
                    if not road_m[min(H - 1, Y + 1), X]:
                        put(X, Y + 1, 'K' if i % 3 == 0 else 'S4')
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
    # the Sunsprinkle Seal gate ON the west road: two root-bound stone posts and a lamp
    for item in late:
        if item[0] != 'gate' or west_road is None:
            continue
        _, gx, gy = item
        px = roads[west_road]
        i = min(range(len(px)), key=lambda j: (px[j][0] - gx) ** 2 + (px[j][1] - gy) ** 2)
        x, y = px[i]
        dx_, dy_ = px[min(i + 2, len(px) - 1)][0] - px[max(i - 2, 0)][0], px[min(i + 2, len(px) - 1)][1] - px[max(i - 2, 0)][1]
        ln = math.hypot(dx_, dy_) or 1
        nx_, ny_ = -dy_ / ln, dx_ / ln
        posts = []
        for s in (-1, 1):
            X, Y = int(round(x + s * 6 * nx_)), int(round(y + s * 6 * ny_)) + 3
            spr(X, Y, SEALPOST)
            posts.append((X, Y - 6))
        (ax, ay), (bx_, by_) = posts
        for t in range(0, 11):   # a living root lintel between the post tops
            X = int(round(ax + (bx_ - ax) * t / 10.0)); Y = int(round(ay + (by_ - ay) * t / 10.0)) - int(round(2 * math.sin(math.pi * t / 10.0)))
            put(X, Y - 1, 'K'); put(X, Y, 'S6' if t % 2 else 'S5'); put(X, Y + 1, 'K')
        mx, my = (ax + bx_) // 2, min(ay, by_) - 3
        put(mx, my, 'K'); put(mx, my + 1, 'GD'); put(mx, my + 2, 'CR'); put(mx - 1, my + 1, 'K'); put(mx + 1, my + 1, 'K')
        log.append(('seal_gate', x, y))
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

    # ------------------------------------------------ 7. NEAR LAYER: the root-mat ceiling, stalagmites
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
            h = RS.randint(4, 10) if not up else RS.randint(4, 13)
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
            if road_m[min(y + 1, H - 1), max(0, min(W - 1, x))]:
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
        if r.random() < 0.35:
            put(x, y + 2, 'NW')
        for k in range(3, len(pts) - 4, 7):
            x, y = pts[k]
            sgn = r.choice([-1, 1])
            for t in range(1, r.randint(3, 6)):
                X, Y = x + sgn * (t + (thick if sgn > 0 else 0)), y + t
                if 0 <= X < W and not keep[Y, X]:
                    put(X, Y, 'S5')
        return True

    # the root mat: a band of tangled roots along the ceiling, thick drops over the town and the bole
    for x in range(W):
        for j in range(3, 7):
            if keep[j, x] or F[j, x]:
                continue
            if (x * 7 + j * 3) % 5 < 2:
                put(x, j, 'S4' if (x + j) % 3 else 'S5')
    tx_ = town['x']
    for k, (x0, ln, th) in enumerate([(tx_ - 22, 30, 3), (tx_ - 6, 36, 3), (tx_ + 12, 28, 3), (tx_ + 30, 22, 2)]):
        root(x0, ln, th, SEED * 100 + 50 + k)
    for k in range(30):
        x0 = RS.randrange(8, W - 8)
        ln_, th_ = RS.randint(12, 34), RS.choice([1, 2, 2, 3, 3])
        root(x0, ln_, th_, SEED * 100 + k)
    for k in range(10):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S, CYANCAP if k % 3 == 0 else None)
    for k in range(6):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'T4', 'u': 'RD', 'n': 'RK'} if k % 2 else None)
    # the taproot pillars over everything: they come down out of the root mat
    for (got, col) in columns:
        cx_, cy_ = got
        top = cy_ - len(col) + 1
        for Y in range(0, top + 4):
            hw = 2 + (1 if Y < 6 else 0)
            for X in range(cx_ - hw, cx_ + hw + 1):
                if 0 <= X < W and not keep_pad[Y, X] and not road_m[Y, X]:
                    if X in (cx_ - hw, cx_ + hw):
                        put(X, Y, 'K')
                    elif Y < top:
                        put(X, Y, 'S2' if (X + Y) % 2 else ('S3' if Y > top - 20 else 'K'))
        spr(cx_, cy_, col)
    # the spider's eyes in the dark above its hollow
    for sid, (x, y) in spread.items():
        s = slots.get(sid)
        if s and s.get('kind') == 'lair' and 'Spider' in s['loc']['name']:
            for Y in range(y - 22, y - 13):
                if 0 <= Y < H and not keep_pad[Y, x - 2:x + 3].any() and not road_m[Y, x - 2:x + 3].any():
                    put(x - 2, Y, 'K'); put(x - 1, Y, 'RD'); put(x, Y, 'K'); put(x + 1, Y, 'RD'); put(x + 2, Y, 'K')
                    log.append(('spider_eyes', x, Y))
                    break

    # mouths: sand spilling in at the Dunewhisper mouth; dry grass tufts at the Thornacre mouth; a sea-cave
    # arch with surf at the Sunsprinkle mouth
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['to'] == 'MENA':
            for Y in range(1, 22):
                for X in range(ex - 9, ex + 10):
                    if not (0 <= X < W) or road_m[Y, X] or (keep_m[Y, X] and F[Y, X]):
                        continue
                    d = abs(X - ex)
                    if d < 3:
                        continue
                    if Y > 2 + d * 1.6 or ((X * 3 + Y) % 4 != 0 and Y > d):
                        continue
                    put(X, Y, 'SN' if (X + Y) % 3 else 'SD')
        elif e['to'] == 'CB':
            for Y in range(ey - 12, ey + 13):
                for X in range(0, 13):
                    if not (0 <= Y < H) or road_m[Y, X] or F[Y, X]:
                        continue
                    if abs(Y - ey) <= 2:
                        continue
                    if (X + Y) % 2 == 0:
                        put(X, Y, 'WA' if (abs(Y - ey) + X) % 3 else 'WL')
            for X in range(0, 14):      # the sea-cave arch over the mouth
                Y = ey - 10 + int(round(0.04 * (X - 4) ** 2))
                put(X, Y, 'K'); put(X, Y + 1, 'AS' if X % 3 else 'AL'); put(X, Y + 2, 'K')
        elif e['side'] == 'S':
            for s in (-1, 1):
                for j in range(0, 10):
                    X = ex + s * (5 + j // 2)
                    Y = H - 12 + j
                    if road_m[Y, X] or (keep_m[Y, X] and F[Y, X]):
                        continue
                    put(X, Y, 'SD' if j % 2 else 'T3')
                    put(X, Y - 1, 'K' if j % 3 == 0 else 't3')

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
    for sid, nm in ((211, "SPIDER'S HOLLOW"), (217, 'SNOWCROWN PEAK'), (210, 'CANOPY BRIDGES'), (208, 'MUD MOSQUE LIBRARY'), (102, 'HERONWICK'), (204, 'OASIS THAT MOVES')):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-WCA.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-WCA.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-WCA.png'))
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
