#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for OC "The Coralscatter" (band violet, Lv 45-55).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built from the
SE generator: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside with a
dithered violet halo and a violet rim light (tier 5).  A drowned cavern: the Lagoon (glowing shallow
water WA/WL, dithered to t2 at the walls, pale sand islets with a cream lip under every keep), the
Queen's Reef (deep violet water, darkest round the Box Jelly Queen, coral heads and jelly lights),
channels between the Palm Islands, a fern brook; dry biomes from the plan: Palm Islands (bright
green), the Red Heart (red ochre with dot-painting songlines, spinifex, the great red monolith,
termite mounds), Cinder Shore (black sand, ash streaks, ember pixels, the smoking cone and steam
vents), Hatchling Beach (cream sand ripples, turtle tracks), Fern Gully (tree ferns, moss lights,
the Stone Head Watchers).  Props: tiare garden, taro pondfield, coconut palms, outrigger canoe, salt
pans and jetty, the Rock Pools with a driftwood fire, the oldest lamp (unlit), coral-crusted
stalactites with violet tips; glowing road trunks on the layout polylines, the two exit tunnel
mouths (mangrove roots by the Rainroot mouth, vines and a ferry lamp by the Monsoon gate); a root
ceiling (thickest over the Market) and a stalagmite floor frame.

UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout town / stops / exits and inside a
14-unit circle round every spread position of the plan there is a plain floor (one or two flat
tones, no sprites, no water, no texture).  (The layout's keep circles for off-road places sit at
their old trail ends; those places moved to the spread positions, so their circle is the spread one.)

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_OC.py [--layout layout-OC.json] [--plan plan-OC.json]
                                    [--out game/assets/img/scenes/map2-OC.png] [--preview PREVIEW-2x.png]
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
CODE = 'OC'
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

# ---------------------------------------------------------------- shared sprites (from the NWE generator)
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


# ---------------------------------------------------------------- OC sprites (The Coralscatter)
LET.update({'V': 'T5', 'x': 't5', 'O': 'T4', 'Y': 'GD', 'h': 'RH', 'e': 'RE', 'R': 'RK', 'W': 'WH'})
COCO = ['.kkkkk.', 'kGGgggk', 'Gkbybkg', '...b...', '...B...', '..bB...', '..kkk..']
PALMC = {'G': 'T1', 'g': 'GK'}
PALM_L = ['.kkkk...', 'kGGggk..', 'Gk.bkg..', '...b....', '....b...', '....bB..', '....kkk.']
OUTRIGGER = ['kkkkkk......', '.b...b......', '.b...b......', 'kkkkkkkkkkkk', 'kBbBbBbBbBbk', '.kkkkkkkkkk.']


def make_monolith(w=30, h=13):
    """the great red rock: a long dome, lit RH on the west shoulder, RK shadow east and below"""
    rows = []
    for j in range(h):
        t = (j + 1.0) / h
        hw = (w / 2.0) * min(1.0, (t * 2.2) ** 0.45)
        row = ''
        for i in range(w):
            dx = i - (w - 1) / 2.0
            if abs(dx) > hw:
                row += '.'
            elif abs(dx) > hw - 1 or j == 0 or j == h - 1:
                row += 'k'
            elif j <= 2 and dx < hw * 0.2:
                row += 'h'
            elif dx < -hw * 0.55 and j < h - 3:
                row += 'h' if (i + j) % 3 else 'e'
            elif dx > hw * 0.5 or j >= h - 3:
                row += 'R' if (i + j) % 4 else 'e'
            elif (j * 3 + i // 7) % 5 == 0:
                row += 'R'
            else:
                row += 'e'
        rows.append(row)
    return rows


MONOLITH = make_monolith()
TERMITE = ['..k..', '.kek.', '.kek.', 'kSeek', 'kSeRk', 'kkkkk']
TERMITE_S = ['.k.', 'kek', 'kSk', 'kkk']
ASHCONE = {'A': 'AS', 'a': 'S4', '3': 'S3', '2': 'S2'}
STEAM = ['.W.f.', 'f.W..', '.fWf.', '..W..', '.kak.']
STEAM_S = ['.W.', 'f.f', '.W.', 'kak']
TREEFERN = ['g.G...G.g', '.gGg.gGg.', 'gdgGgGgdg', '.d.dbd.d.', '....b....', '....B....', '...kbk...']
BRAIN = ['.kkk.', 'kPpPk', 'kpPpk', 'kkkkk']
VBRAIN = {'P': 'T5', 'p': 't5'}
FAN = ['V.p.V', '.VpV.', 'p.V.p', '.kpk.']
FIRE = ['.O.', 'OrO', 'kbk']
OLDLAMP = ['.kkk.', 'kAmAk', 'kmmmk', '.kkk.', '.kAk.', '.kak.', '.kAk.', '.kak.', '.kAk.', 'kAaak', 'kkkkk']
MOAI = ['.kkk.', 'kAAak', 'kAk1k', 'kAaak', 'kA11k', 'kAaak', 'kkkkk']
MOAI_S = ['.kk.', 'kAak', 'kk1k', 'kAak', 'kkkk']
JELLY = ['.V.', 'VWV', 'x.x']
SPINIFEX = {'g': 'GD', 'd': 'S5', 'S': 'SD', 's': 'SN'}
BASALTROCK = {'A': 'AS', 'a': 'S3', '1': 'S1'}


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
        b, dm = R.choice([('T2', 't2'), ('T5', 't5'), ('NW', 'ND'), ('T4', 't4'), (BRIGHT, DIM)])
        put(x, y, b); put(x, y + 1, dm)
        if R.random() < .3:
            put(x, y - 1, 'WH')

    # ------------------------------------------------ 2. ZONES from the plan biomes (noisy edges)
    zone = np.full((H, W), 'base', dtype=object)
    bmask = {}
    KEY = {'palm_islands': 'palm', 'red_heart_desert': 'red', 'volcanic_black_sand': 'cinder',
           'hatchling_beach': 'beach', 'fern_gully': 'fern', 'coral_reef': 'reef', 'lagoon_shallows': 'lagoon'}
    zm_ = {}
    kz_ = grow(keep_m, 3)
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        t = b['type']
        wet = t in ('lagoon_shallows', 'coral_reef')
        s = blur(poly_mask(b['points']).astype(float), 3 if wet else 7)
        n2_ = vnoise(3, 200 + i)
        m = s + (0.5 if wet else 0.95) * (n - 0.5) + (0 if wet else 0.35 * (n2_ - 0.5) + 0.22 * (BAY - 0.5)) > 0.5
        m = np.where(kz_, s + (0.5 if wet else 0.95) * (n - 0.5) > 0.5, m)   # clean edges in the keeps
        bmask[t] = m
        k = KEY.get(t)
        if k:
            zm_[k] = zm_.get(k, np.zeros((H, W), bool)) | m
    for key in ['beach', 'cinder', 'red', 'fern', 'palm', 'reef', 'lagoon']:
        if key in zm_:
            zone[zm_[key] & F] = key

    RAMPS = {
        'base': ['S5', 'S6', 'SD', 'SD'], 'palm': ['GK', 'GM', 'GM', 'T1'], 'red': ['RK', 'RE', 'RE', 'S6'],
        'cinder': ['S2', 'S3', 'S4', 'S4'], 'beach': ['S6', 'SD', 'SN', 'CR'], 'fern': ['t1', 'GK', 'GK', 'GM'],
        'reef': ['AS', 'SD', 'SN', 'SN'], 'lagoon': ['SD', 'SD', 'SN', 'SN'],
    }
    BIAS = {'base': 0.04, 'palm': 0.08, 'red': 0.04, 'cinder': 0.0, 'beach': 0.10, 'fern': 0.0, 'reef': 0.06,
            'lagoon': 0.12}

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
    kd = np.full((H, W), 99.0)
    for (_, x, y, r) in keeps:
        kd = np.minimum(kd, np.hypot(xx - x, yy - y) - r)
    busyok = F & ~keep_m & (depth > 2) & (kd > BAY2 * 7)
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    near3 = pixmask(road_px, 3)
    # Red Heart: dot-painting rows (the songlines) in SN, RK grit, GD spinifex flecks
    rz = busyok & (zone == 'red') & ~near3
    sv = (xx * 0.18 + yy * 0.55 + 7 * vnoise(14, 121))
    songs = ((sv % 7.0) < 0.9) & ((xx + 2 * yy) % 4 == 0) & (vnoise(6, 122) > 0.45)
    paint(rz & songs & (gi >= 1), 'SN')
    for (cx_, cy_) in ((112, 142), (206, 160), (236, 120)):
        ring_ = np.hypot(xx - cx_, (yy - cy_) * 1.3)
        paint(rz & (ring_ < 11) & ((ring_ % 4.0) < 0.9) & ((xx + yy) % 2 == 0), 'SN')
        paint(rz & (ring_ < 1.6), 'CR')
    paint(rz & (vnoise(1, 123) > 0.95) & ((xx + yy) % 2 == 1), 'RK')
    paint(rz & (vnoise(1, 124) > 0.985) & (gi >= 1), 'GD')
    # Cinder Shore: black sand, ash streaks, ember pixels
    cz = busyok & (zone == 'cinder')
    streak = (np.abs(np.sin((xx * 0.25 + yy + 10 * vnoise(8, 131)) / 2.6)) < 0.12) & (vnoise(4, 132) > 0.5)
    paint(cz & streak & ((xx + yy) % 2 == 0), 'AS')
    paint(cz & (vnoise(1, 133) > 0.96), 'S2')
    paint(cz & (vnoise(1, 134) > 0.985) & (vnoise(9, 135) > 0.5), 'RD')
    # Hatchling Beach: wind ripples, drift flecks
    bz = busyok & (zone == 'beach')
    rip = np.sin((xx * 0.30 + yy * 1.0 + 9 * vnoise(8, 141)) / 1.5) > 0.88
    paint(bz & rip & (BAY > 0.3), 'CR')
    paint(bz & np.roll(rip, -1, axis=0) & ~rip & (BAY > 0.55), 'SD')
    paint(bz & (vnoise(1, 142) > 0.96), 'S6')
    # Palm Islands: bright tufts; Fern Gully: wet dark green with moss lights
    pz = busyok & (zone == 'palm')
    paint(pz & (vnoise(1, 151) > 0.90) & ((xx + yy) % 2 == 0), 'GK')
    paint(pz & (vnoise(1, 152) > 0.94) & (gi >= 1), 'T1')
    fz = busyok & (zone == 'fern')
    paint(fz & (vnoise(1, 153) > 0.90) & ((xx + yy) % 2 == 0), 't1')
    paint(fz & (vnoise(1, 154) > 0.975) & (vnoise(7, 155) > 0.5), 'NW')
    paint(fz & (vnoise(1, 156) > 0.95) & (gi >= 2), 'GM')
    bsz = busyok & (zone == 'base')
    paint(bsz & (vnoise(1, 157) > 0.92), 'S5')

    # rim: K outline, band-colour rim light (violet), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')

    # ------------------------------------------------ 4. WATERS: the drowned floor (lagoon, reef, channels, brook)
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker stands on its own islet
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 2 + 2.5 * isl
        if sid in slots and slots[sid]['type'] in ('stop', 'town'):
            keep_wet |= disk(x, y, r + 5)
    DRY = {'tiare_garden': (13, 9), 'salt_pans': (14, 8), 'rock_pools': (13, 9), 'coconut_palms': (16, 8),
           'oldest_lamp': (6, 8), 'taro_pondfield': (14, 8), 'outrigger_canoe': (4, 4)}
    dry = np.zeros((H, W), bool)
    for p in P['props']:
        if p['kind'] in DRY:
            rx, ry = DRY[p['kind']]
            dry |= np.hypot((xx - p['x']) / rx, (yy - p['y']) / ry) + 0.3 * (isl - 0.5) < 1
    band = pixmask(road_px, 6)
    chan = vnoise(9, 171)
    wetz = (zone == 'lagoon') | (zone == 'reef') | ((zone == 'palm') & (chan < 0.36)) | ((zone == 'base') & (chan < 0.50))
    islets = (vnoise(5, 172) > 0.74) & (zone == 'lagoon')
    water = wetz & F & (depth > 2) & ~keep_wet & ~band & ~dry & ~islets
    water = dil4(ero4(water))
    water = ero4(dil4(water)) & ~keep_wet & F & ~band & ~dry & (depth > 2)
    # the fern brook: from the east wall down to the lagoon
    brook = pixmask(raster([(458, 104), (440, 110), (424, 124), (420, 142), (428, 160), (442, 178), (450, 196)]), 1)
    brook = brook & F & ~keep_wet & ~band & ~dry
    occ_water = water | brook
    reefw = water & (zone == 'reef')
    lagw = occ_water & ~reefw
    # banks: pale sand with a cream lip
    sh = dil8(occ_water) & ~occ_water & F & ~keep_m & ~road_m
    paint(sh & (zone != 'reef'), 'SN')
    paint(sh & (zone != 'reef') & (BAY > 0.5), 'CR')
    paint(sh & (zone == 'reef'), 'AS')
    paint(sh & (zone == 'reef') & (BAY > 0.6), 'AL')
    sh2 = dil8(sh) & ~sh & ~occ_water & F & ~keep_m & ~road_m
    paint(sh2 & (BAY > 0.55) & (zone != 'reef'), 'SD')
    dsh = np.zeros((H, W), float)
    m = occ_water.copy()
    for i in range(7):
        dsh += m
        m = ero4(m)
    # glowing shallows: WA body, t2 dithered in towards the walls and in a few deeper pools, WL sparkle
    paint(lagw, 'WA')
    wall_t = np.clip(1 - (depth - 3) / 9.0, 0, 1)
    paint(lagw & (wall_t > BAY), 't2')
    paint(lagw & (dsh >= 4) & (vnoise(11, 173) > 0.60) & (BAY > 0.55), 't2')
    paint(lagw & (dsh >= 3) & (yy % 4 == 1) & (np.sin(xx / 3.0 + yy) > 0.82), 'WL')
    paint(lagw & (dsh >= 2) & (vnoise(1, 174) > 0.975), 'WL')
    paint(lagw & (dsh == 1) & ((xx + yy) % 2 == 0), 'WL')
    # the Queen's Reef: deep violet water, darkest round the Queen
    jq = None
    for sid, (x, y) in spread.items():
        if slots.get(sid, {}).get('kind') == 'lair' and zone[y, x] == 'reef':
            jq = (x, y)
    paint(reefw, 't5')
    paint(reefw & (dsh <= 2) & ((xx + yy) % 2 == 0), 'WA')
    paint(reefw & (dsh == 1), 'WA')
    paint(reefw & (dsh >= 4) & (BAY > 0.55), 'D2')
    if jq:
        qd = np.clip(1 - np.hypot(xx - jq[0], yy - jq[1]) / 40.0, 0, 1)
        paint(reefw & (dsh >= 3) & (qd > BAY * 0.9), 'D2')
        paint(reefw & (dsh >= 3) & (qd > BAY * 0.9 + 0.35), 'D1')
    paint(reefw & (dsh >= 3) & (yy % 5 == 2) & (np.sin(xx / 4.0 + yy * 0.7) > 0.88), 'T5')
    paint(reefw & (dsh == 1) & ((xx + yy) % 4 == 0), 'WL')

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
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
            if try_place(x, y, rows, over, pad, where):
                got += 1
        return got

    def glow(cx_, cy_, rad, col, extra=None, thr=0.12):
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + thr) & ((xx + yy) % 2 == 0), col)

    def patch(x, y, rx, ry, fn_, tries=((0, 0), (2, 1), (-2, 1), (0, 3), (3, -2), (-3, -1), (5, 2), (-5, 2), (0, -4)),
              where=None):
        hard_ = (F & ~keep_pad & ~near_road & ~root_corr & ~occ_water) if where is None else where
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
    cone_at = None
    fire_at = None
    jellies = []
    hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water
    tall_ok = hard & ~pixmask(road_px, 6)     # nothing tall on the road line
    shore_ok = wet_free | (hard & dil8(occ_water))
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        if k == 'tiare_garden':
            def tiare(gm, gx, gy):
                paint(gm, 'GK')
                paint(gm & ((xx - gx + (yy - gy) % 2 * 2) % 4 == 0) & ((yy - gy) % 2 == 0), 'WH')
                paint(gm & ((xx - gx + (yy - gy) % 2 * 2) % 4 == 1) & ((yy - gy) % 2 == 0) & (BAY > 0.4), 'GD')
                paint(gm & ((yy - gy) % 2 == 1) & (BAY > 0.7), 'GM')
                rim_ = gm & ~ero4(gm)
                paint(rim_, 'AS')
                paint(rim_ & ((xx + yy) % 2 == 0), 'AL')
            got = patch(x, y, 7, 4, tiare, where=hard)
        elif k == 'taro_pondfield':
            got = 0
            for (dx, dy) in ((-8, 0), (2, -1), (11, 1), (-3, 5), (7, 6), (-12, -4)):
                if got >= n:
                    break
                def taro(gm, gx, gy):
                    paint(gm, 'WA')
                    paint(gm & ((xx - gx + yy) % 3 == 0), 'GM')
                    paint(gm & ((xx - gx + yy) % 3 == 0) & ((yy - gy) % 2 == 0), 'T1')
                    paint(gm & ~ero4(gm), 'S5')
                if patch(x + dx, y + dy, 4, 2, taro, tries=((0, 0), (1, 1), (-1, 1)), where=hard):
                    got += 1
        elif k == 'coconut_palms':
            got = cluster(x, y, [(PALM, PALMC), (COCO, PALMC), (PALM_L, PALMC)], n, 14, 0, where=tall_ok)
        elif k == 'outrigger_canoe':
            got = near(x, y + 2, OUTRIGGER, None, 14, 0, where=shore_ok)
        elif k == 'red_monolith':
            got = near(x, y + 6, MONOLITH, None, 20, 0, where=hard)
        elif k == 'termite_mounds':
            got = cluster(x, y, [(TERMITE, None), (TERMITE_S, None)], n, 10, 0, where=hard)
        elif k == 'smoking_cone':
            got = cone_at = near(x, y + 10, CONE_S, ASHCONE, 12, 0, where=hard)
        elif k == 'steam_vents':
            got = cluster(x, y, [(STEAM, None), (STEAM_S, None)], n, 10, 0, where=hard)
        elif k == 'turtle_tracks':
            got = 0
            for (dx, dy) in ((4, -4), (8, 6), (0, 0), (12, 2)):
                if got >= n:
                    break
                tx_, ty_ = x + dx, y + dy
                trk = [(tx_ - t, ty_ - (t // 4) % 2) for t in range(3, 22)]
                if all(hard[py, px_] and not occ[py, px_] for (px_, py) in trk) and try_place(tx_, ty_, TURTLE, None, 0, where=hard):
                    for j, (px_, py) in enumerate(trk):
                        if j % 2 == 0:
                            put(px_, py - 1, 'SD'); put(px_, py + 2, 'SD')
                    got += 1
        elif k == 'tree_ferns':
            got = cluster(x, y, [(TREEFERN, None), (TREEFERN, None), (FERN, JUNGLE)], n, 14, 0, where=tall_ok)
        elif k == 'coral_heads':
            got = cluster(x, y, [(BRAIN, None), (BRAIN, VBRAIN), (FAN, None)], n, 16, 0, where=wet_free | hard)
            for (dx, dy) in ((-14, -10), (6, -16), (16, 4)):
                jellies.append((x + dx, y + dy))
        elif k == 'salt_pans':
            def pans(gm, gx, gy):
                paint(gm, 'AS')
                cell = ((xx - gx) % 5 != 0) & ((yy - gy) % 4 != 0)
                paint(gm & cell, 'WH')
                paint(gm & cell & ((xx + yy) % 3 == 0), 'CR')
            got = patch(x, y, 9, 4, pans, where=hard)
            if got:
                jx, jy = got[0] + 11, got[1] + 1
                for t in range(0, 10):
                    X = jx + t
                    if 0 <= X < W and occ_water[jy, X] and not keep_pad[jy, X]:
                        put(X, jy, 'S6'); put(X, jy + 1, 'K' if t % 3 == 0 else 'S4')
        elif k == 'rock_pools':
            def pools(gm, gx, gy):
                paint(gm, 'D3')
                paint(gm & (BAY > 0.6), 'AS')
                pool = gm & (vnoise(2, 181) > 0.55) & ero4(gm)
                paint(pool, 'WA')
                paint(pool & ~ero4(pool) & ((xx + yy) % 2 == 0), 'WL')
            got = patch(x, y, 9, 5, pools, where=F & ~keep_pad & ~near_road & ~root_corr)
            if got:
                fire_at = (got[0] - 9, got[1] + 1)
                try_place(fire_at[0], fire_at[1], FIRE, None, 0, where=F & ~keep_pad & ~near_road & ~root_corr)
        elif k == 'oldest_lamp':
            got = near(x, y + 5, OLDLAMP, None, 8, 0, where=hard)
        elif k == 'ceiling_coral_stalactites':
            got = 'ceiling'
        else:
            got = 'skip'
        log.append((k, x, y, got))
    # the Stone Head Watchers: two heads on the bare rise, outside the marker's floor
    for sid, (x, y) in spread.items():
        if sid == 239:
            log.append(('stone_heads', x, y, cluster(x + 2, y - 16, [(MOAI, None), (MOAI_S, None)], 2, 6, 0, where=hard)))

    # biome scatter
    zf = lambda z: free & (zone == z)
    far_road = ~pixmask(road_px, 7)
    scatter([(PALM, PALMC), (COCO, PALMC), (PALM_L, PALMC), (BUSH, HAZEL)], 24, zf('palm') & far_road, pad=1)
    scatter([(BUSH, HAZEL), (FERN_S, HAZEL)], 8, zf('palm'), pad=1)
    scatter([(TALLGRASS, SPINIFEX), (TALLGRASS, SPINIFEX), (PEBBLE, REDROCK), (STONE, REDROCK), (TERMITE_S, None)], 34,
            zf('red'), pad=1)
    scatter([(CRAG, BASALTROCK), (STONE, BASALTROCK), (PEBBLE, BASALTROCK), (CRAG, BASALTROCK), (FERN_S, HAZEL)], 26,
            zf('cinder'), pad=1)
    scatter([(SHELL, None), (PEBBLE, WARMSTONE), (PALM_L, None), (SHELL, None)], 18, zf('beach') & far_road, pad=2)
    scatter([(TREEFERN, None), (TREEFERN, None), (FERN, JUNGLE), (FERN_S, JUNGLE), (BUSH, JUNGLE)], 36, zf('fern') & far_road,
            pad=0)
    scatter([(SHROOM_S, None)], 4, zf('fern') & far_road, pad=1)
    scatter([(STONE, CRAB_ROCK), (PEBBLE, CRAB_ROCK)], 10, wet_free & (zone == 'lagoon'), pad=1)
    scatter([(BRAIN, None), (BRAIN, VBRAIN), (FAN, None), (FAN, None)], 22, wet_free & (zone == 'reef'), pad=1)
    shore_ = dil8(dil8(occ_water)) & ~occ_water & free
    scatter([(SHELL, None), (PEBBLE, WARMSTONE)], 14, shore_, pad=0)

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
    # the smoking cone: red crater glow and a smoke curl up to the ceiling band
    if cone_at:
        cx_, cy_ = cone_at[0], cone_at[1] - 20
        glow(cx_, cy_ + 2, 8, 'T4', thr=0.2)
        for j in range(1, cy_ - 2):
            X = cx_ + int(round(2.5 * math.sin(j / 3.5))) + j // 6
            Y = cy_ - j
            if 0 <= Y < H and not keep_pad[Y, X] and not near_road[Y, X]:
                put(X, Y, 'AL' if j < 5 else ('FOG' if j % 3 else 'AS'))
                if j % 2 == 0 and j > 3:
                    put(X + 1, Y, 'FOG')
    if fire_at:
        glow(fire_at[0], fire_at[1] - 2, 9, 'T4', thr=0.15)
    # jelly lights over the reef (violet with a white core)
    for (x, y) in jellies:
        if 0 <= y < H and 0 <= x < W and occ_water[y, x] and not keep_pad[y, x] and not root_corr[y, x]:
            glow(x, y, 7, 'T5', extra=occ_water, thr=0.05)
            try_place(x, y + 1, JELLY, None, 0, where=occ_water & ~keep_pad & ~root_corr)
    # glowworms on the roof of the sea-cave (the south wall by the Grotto)
    for sid, (x, y) in spread.items():
        if sid == 237:
            gw = ~F & (np.abs(xx - x) < 26) & (yy > y + 8) & (yy < H - 4) & (outd > 0)
            paint(gw & (vnoise(1, 191) > 0.90), 'ND')
            paint(gw & (vnoise(1, 192) > 0.94), 'NW')
            paint(gw & (vnoise(1, 193) > 0.985), 'WL')
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

    # ------------------------------------------------ 7. NEAR LAYER: ceiling roots, stalactites, stalagmites
    keep = keep_m | pixmask(road_px, 4)

    def spike(x0, w, h, up, coral=True):
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
                if not up and coral:   # coral-crusted stalactites with violet tips
                    if j >= hh_ - 1 and abs(i - (w - 1) / 2.0) <= 1 and hh_ >= 4:
                        c = 'T5' if j == hh_ else 't5'
                    elif c in ('S1', 'S2') and (i * 3 + j * 2) % 7 == 0:
                        c = 'PK' if (i + j) % 2 else 'S5'
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

    # hanging mycelium roots: thickest over the Market (the plan's hanging_roots prop)
    tx_ = town['x']
    for k, (x0, ln, th) in enumerate([(tx_ - 22, 30, 3), (tx_ - 6, 36, 3), (tx_ + 12, 28, 3), (tx_ + 30, 22, 2)]):
        root(x0, ln, th, SEED * 100 + 50 + k)
    for k in range(16):
        x0 = RS.randrange(8, W - 8)
        ln_, th_ = RS.randint(12, 30), RS.choice([1, 2, 2, 3])
        root(x0, ln_, th_, SEED * 100 + k)
    for k in range(10):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 4:x + 5].any():
            spr(x, H - 3, SHROOM if k % 2 else SHROOM_S, CYANCAP if k % 3 == 0 else None)
    for k in range(6):
        x = RS.randrange(6, W - 6)
        if not keep[H - 8:H, x - 3:x + 4].any():
            spr(x, H - 3, ['..k..', '.kUk.', 'kUuuk', 'kUuuk', 'kUunk', '.kkk.'], {'U': 'PL', 'u': 'T5', 'n': 't5'} if k % 2 else None)

    # exit dressing (outside the keep circles): mangrove roots on the west wall either side of the
    # Rainroot mouth, a canoe post; vines down the ceiling either side of the Monsoon gate, a ferry lamp
    for e in exits.values():
        ex, ey = e['x'], e['y']
        if e['side'] == 'W':
            for (ry0, dirn) in ((ey - 24, -1), (ey + 24, 1)):
                for k in range(3):
                    x0 = 3 + k * 4
                    for t in range(0, 10):
                        X = x0 + t; Y = ry0 + dirn * (k * 3 + int(round(4 * math.sin(t / 3.0))))
                        if 0 <= X < W and 0 <= Y < H and not keep_pad[Y, X] and not road_m[Y, X]:
                            put(X, Y, 'S5' if t % 3 else 'S6')
                            put(X, Y + 1, 'K')
            got = near(ex + 10, ey + 26, ['kyk', 'kbk', 'kbk', 'kbk', 'kkk'], None, 8, 0,
                       where=F & ~keep_pad & ~near_road & ~occ_water)
            if got:
                spr(got[0], got[1], ['kyk', 'kbk', 'kbk', 'kbk', 'kkk'])
        elif e['side'] == 'N':
            for s in (-1, 1):
                for k in range(3):
                    X = ex + s * (21 + k * 5)
                    ln = 10 + (k * 7) % 9
                    for j in range(2, ln):
                        if 0 <= X < W and not keep_pad[j, X] and not road_m[j, X]:
                            put(X + (j // 4) % 2, j, 'GK' if j % 3 else 'GM')
                    if 0 <= X < W and not keep_pad[ln, X]:
                        put(X + (ln // 4) % 2, ln, 'T1')
            lx, ly = ex + 20, ey + 18
            if not keep_pad[ly - 6:ly + 1, lx - 2:lx + 3].any():
                spr(lx, ly, ['.k.', 'kYk', 'kck', '.k.', '.b.', '.b.', 'kbk'])
                gl = disk(lx, ly - 5, 7) & F & ~keep_pad & ~road_m
                lv3 = np.clip(1 - np.hypot(xx - lx, yy - ly + 5) / 7.0, 0, 1)
                paint(gl & (lv3 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0) & ~dil4(pixmask([(lx, ly - 3)], 2)), 'GD')


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
    for sid, nm in ((241, 'BOX JELLY QUEEN'), (235, 'DRAGONLIZARD DEN'), (240, 'RED ROCK SONGLINES'), (237, 'GLOWWORM GROTTO'), (239, 'STONE HEADS'), (180, 'DOLPHIN POOLS')):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-OC.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-OC.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-OC.png'))
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
