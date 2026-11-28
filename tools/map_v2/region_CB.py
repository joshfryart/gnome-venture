#!/usr/bin/env python3
"""Gnome Venture - region map v2 underlay for CB "The Sunsprinkle Isles" (band gold, Lv 25-35).

Lit floor style (the approved region-1 mockup, same palette, sprites, 5x7 font, glow), built from
the CA generator: dark strata and fog outside, the cavern floor (the plan polygon) lit from inside
with a dithered gold halo and a gold rim light (the west mouth takes the cyan of the band behind,
the east mouth the orange of the band ahead), biome ground (the coral sand hub isle, Turtle Sound,
Ferry Cove and the dark Galleon Deep lagoons with tidal shallows between, the Maizehollow shore
terraces, the saffron and red Smokecap shoulder, the Lianawood, two mangroves, the grey Rainroot
foothills, the Greatcanopy fen), landmark props (lighthouse, frangipani garden, steel drum stage,
breadfruit trees, the first lit boat, the galleon wreck, the cascade, crab shells, caldera rim,
Sky City columns, condor spires, turtle tracks, coral heads, chili strings), glowing road trunks
on the layout polylines (plank causeways over water) and the three exit tunnel mouths; a root
ceiling and a stalagmite floor frame.
--gates also writes the root-lattice overlay (RGBA) for the sealed east tide gate.

The isles rule: every stop, the town and every spread place stands on land: inside water each
keep-clear disc is a sand islet.
UNDERLAY ONLY: no markers, no labels, no trails, no thick roots (the game draws those).
Plain-ground rule: inside every keep-clear circle of the layout stops / town / exits and
inside a 14-unit circle round every spread position of the plan there is a plain floor
(one or two flat tones, no sprites, no water, no texture).

Native 480x270, fixed palette, no anti-aliasing.

Usage (re-runnable, deterministic):
  python3 tools/map_v2/region_CB.py [--layout layout-CB.json] [--plan plan-CB.json]
                                    [--out game/assets/img/scenes/map2-CB.png]
                                    [--preview PREVIEW-2x.png] [--gates GATES.png]
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
CODE = 'CB'
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
BRIGHT, DIM = 'T3', 't3'  # band gold
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

# ---------------------------------------------------------------- CB sprites (Sunsprinkle Isles)
LET.update({'U': 'WL', 'u': 'WA', 'z': 't2'})
LIGHTHOUSE = ['..kkk..', '.kyyyk.', 'kkcwckk', '.kAkAk.', '.kkkkk.', '..kAk..', '..krk..', '..kAk..', '..krk..',
              '.kAAak.', '.krrrk.', '.kAAak.', '.krrrk.', 'kAAAaak', 'kkkkkkk']
BREADFRUIT = ['...kkkkkk...', '.kkGGGgggkk.', 'kGGGgyggggdk', 'kGygggggdydk', 'kggggdgdddkk', '.kkddkbkddk.',
              '...kkkbkkk..', '....kbBk....', '....kbBk....', '....kkkk....']
BOAT = ['...k...', '..kyk..', '..kck..', '...b...', 'kkkbkkk', 'kBbBbBk', '.kkkkk.']
WRECK = ['.k.....k..', 'kck...kck.', '.b.....b..', '.bk....bk.', 'kbBk..kbBk', '.b.....b..', 'kkkkkkkkkk',
         'kBbBbBbBbk', '.kkzkkzkk.']
CASCADE = ['kkkkkkkkk', 'kAaUwUaAk', 'kaaUwUa1k', '.k.wUw.k.', '...UwU...', '...wUw...', '..UwUwU..', '.kuuUuuk.',
           'kuuuuuuuk', '.kkkkkkk.']
MANGROVE = ['..kkkkk..', '.kGGgddk.', 'kGgggdddk', '.kkgdkdk.', '..kbkbk..', '.kb.b.bk.', 'kb..b..bk', 'b...b...b']
CRABSHELL = ['.kkkk.', 'krhrrk', 'krrrRk', 'kkkkkk']
CALDERA = ['...kkkkkkk...', '.kkhrrrrrhkk.', 'kAkRRRRRRRkak', 'kAAkkkkkkka3k', 'kAaaaa3aa333k', 'kkkkkkkkkkkkk']
CALROCK = {'A': 'RE', 'a': 'RK', '3': 'S2'}
COLUMN = ['kkkkk', 'kAAak', '.kAk.', '.kAk.', '.kak.', '.kAk.', '.kak.', 'kAAak', 'kkkkk']
COLUMN_S = ['.kk..', '.kAk.', '.kAk.', '.kak.', 'kAAak', 'kkkkk']
TURTLE = ['.kk.', 'kGgk', 'kgdk', '.kk.']
STAGE = ['kkkkkkkkkk', 'kryryryryk', 'kkkkkkkkkk', '.b......b.', '.bkAk.kAkb', '.bkak.kakb', 'kkkkkkkkkk',
         'kBbBbBbBbk', 'kkkkkkkkkk']
CORAL = ['p.h', 'pPp', '.p.']
CHILI = ['k...k', 'bkkkb', 'brRrb', 'b.r.b', 'b...b', 'k...k']
SHELL = ['.P.', 'PpP']
CRAB_ROCK = {'A': 'AS', 'a': 'D4', '1': 'D2'}



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
    lagoon = np.zeros((H, W), bool)   # all lagoon water (the isles rule: keeps become sand islets)
    deepw = np.zeros((H, W), bool)    # Galleon Deep: one step darker
    lightw = np.zeros((H, W), bool)   # Turtle Sound: the lightest cyan
    KEY = {'coral_sand': 'coral', 'prairie': 'shore', 'desert_volcanic': 'volc', 'jungle': 'jungle',
           'mangrove': 'mangrove', 'ridge': 'ridge', 'fen': 'fen'}
    frost_x = None
    for i, b in enumerate(P['biomes']):
        n = vnoise(7, 100 + i)
        t = b['type']
        if b['shape'] == 'polygon':
            s = blur(poly_mask(b['points']).astype(float), 3)
            m = s + 0.5 * (n - 0.5) > 0.5
        else:
            e = np.hypot((xx - b['cx']) / b['rx'], (yy - b['cy']) / b['ry'])
            m = e + 0.35 * (n - 0.5) < 1
        if t == 'water':
            lagoon |= m
            if b['shape'] == 'ellipse':
                deepw |= m
            elif 'Turtle' in b.get('note', ''):
                lightw |= m
            continue
        k = KEY.get(t)
        if k:
            zmask.setdefault(k, np.zeros((H, W), bool))
            zmask[k] |= m
    for key in ['shore', 'coral', 'fen', 'ridge', 'volc', 'jungle', 'mangrove']:
        if key in zmask:
            zone[zmask[key] & F] = key
    cal = [p for p in P['props'] if p['kind'] == 'caldera_rim']
    cal_c = (cal[0]['x'] - 8, cal[0]['y'] + 2) if cal else (96, 38)
    zone[(zone == 'volc') & (np.hypot(xx - cal_c[0], (yy - cal_c[1]) * 1.2) + 6 * vnoise(4, 131) < 26)] = 'caldera'
    # tidal shallows in the open sand between the zones: the floor is a lagoon, broken by sand
    shallow = (zone == 'base') & F & (vnoise(13, 132) > 0.67) & (depth > 4) & ~pixmask(road_px, 9)
    zone[lagoon & F] = 'isle'

    RAMPS = {
        'base': ['S6', 'SD', 'SD', 'SN'], 'coral': ['SD', 'SD', 'SN', 'SN'], 'isle': ['SD', 'SN', 'SN', 'SN'],
        'shore': ['t1', 'GK', 'GM', 'SD'], 'volc': ['S5', 'S6', 'SD', 'SN'], 'caldera': ['RK', 'RK', 'RE', 'S6'],
        'jungle': ['t1', 'GK', 'GK', 'GM'], 'mangrove': ['t1', 'GK', 'GM', 'GM'], 'ridge': ['S3', 'AS', 'AS', 'AL'],
        'fen': ['t1', 't1', 'GK', 'GM'],
    }
    BIAS = {'base': 0.08, 'coral': 0.16, 'isle': 0.14, 'shore': 0.04, 'volc': 0.06, 'caldera': 0.0,
            'jungle': -0.04, 'mangrove': -0.02, 'ridge': -0.02, 'fen': -0.06}

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
    busyok = F & ~keep_m & (depth > 2)
    tuft = busyok & (vnoise(1, SEED + 11) > 0.86)
    for zname, ramp in RAMPS.items():
        zm = tuft & (zone == zname)
        for i in range(3):
            paint(zm & (gi == i), ramp[i + 1])
    # sand: wind/tide ripples + S5 speckle (base, coral hub, saffron)
    sandz = busyok & ((zone == 'base') | (zone == 'coral') | (zone == 'volc'))
    rip = np.abs(np.sin((yy * 1.3 + 4 * np.sin(xx / 9.0) + 6 * vnoise(8, 69)) / 1.6)) > 0.94
    paint(sandz & rip & (gi >= 2), 'SD')
    paint(sandz & (vnoise(1, 70) > 0.95), 'S5')
    paint(busyok & (zone == 'coral') & (vnoise(1, 74) > 0.965), 'PL')        # coral grit
    paint(busyok & (zone == 'volc') & (vnoise(1, 75) > 0.95), 'GD')          # saffron
    paint(busyok & (zone == 'volc') & (vnoise(1, 76) > 0.96), 'RE')
    # Maizehollow shore: warm maize-green terraces (T1 + GD dither, S6 terrace lips)
    shz = busyok & (zone == 'shore')
    terr = ((yy + xx // 17) % 7 == 0) & (vnoise(6, 133) > 0.38)
    paint(shz & terr, 'S6')
    paint(shz & np.roll(terr, 1, axis=0) & ((xx + yy) % 2 == 0), 't1')
    paint(shz & (vnoise(1, 134) > 0.88) & ((xx + yy) % 2 == 0), 'T1')
    paint(shz & (vnoise(1, 135) > 0.95), 'GD')
    # caldera: black cracks on red rock
    sn = vnoise(5, 61)
    crk = (np.abs(np.sin((xx * 0.55 + yy + 14 * sn) / 3.2)) < 0.16) & (vnoise(3, 62) > 0.45)
    cz = busyok & (zone == 'caldera')
    paint(cz & crk, 'K')
    paint(cz & dil4(crk) & ~crk & (yy % 2 == 0) & (vnoise(1, 63) > 0.6), 'RE')
    # ridge: grey stone steps (ledge lines) + cracks + glints
    rz = busyok & (zone == 'ridge')
    ledge = ((yy + (xx // 21) * 2) % 8 == 0) & (vnoise(5, 136) > 0.3)
    paint(rz & ledge, 'S3')
    paint(rz & np.roll(ledge, 1, axis=0) & ~ledge, 'AL')
    paint(rz & crk & (gi >= 1), 'S3')
    # jungle: dark fronds
    jz = busyok & (zone == 'jungle')
    paint(jz & (vnoise(1, 67) > 0.80) & ((xx + yy) % 3 == 0), 't1')
    # mangrove + fen: brackish teal pools
    for zname, sd in (('mangrove', 137), ('fen', 138)):
        zz = busyok & (zone == zname)
        pool = zz & (vnoise(4, sd) > 0.68)
        pool = ero4(dil4(pool)) & zz
        paint(pool, 'ND')
        paint(pool & ~dil4(~pool) & (BAY > 0.55), 't2')
        paint(pool & ~dil4(~pool) & (yy % 3 == 0) & ((xx + yy) % 4 == 0), 'NW')
        paint(dil4(pool) & ~pool & zz, 't1')
    paint(busyok & (zone == 'fen') & (vnoise(1, 139) > 0.975), 'T4')   # a hint of the orange band ahead
    # rim: K outline, band-colour rim light (gold), dim outer
    d1 = dil8(F); d2 = dil4(d1); d3 = dil8(d2); d4 = dil4(d3)
    paint(d4 & ~d3, DIM)
    paint(d3 & ~d1, BRIGHT)
    paint(d3 & ~d2 & (yy > H * 0.55) & ((xx + yy) % 3 == 0), DIM)
    paint(d1 & ~F, 'K')
    # the two cross-band mouths: their rim and halo take the neighbour band colour
    XBAND = {'CA': ('T2', 't2'), 'WCA': ('T4', 't4')}
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

    # ------------------------------------------------ 4. WATERS: the lagoons, the shallows, Galleon Deep
    keep_wet = np.zeros((H, W), bool)
    isl = vnoise(3, 47)
    for (sid, x, y, r) in keeps:  # every marker on its own sand islet
        keep_wet |= np.hypot(xx - x, yy - y) <= r + 1 + 2.5 * isl
    band = pixmask(road_px, 4)
    wet = (lagoon | shallow) & F & (depth > 2)
    water = wet & ~keep_wet & ~band
    water = ero4(dil4(water)) & ~keep_wet & F & ~band
    water &= ~dil4(ero4(ero4(~water)))  # drop slivers
    occ_water = water
    # plank causeways where a road crosses water
    planks = band & wet & ~keep_wet & dil8(dil8(water))
    planks = dil4(planks) & band & ~keep_m
    paint(planks, 'S6')
    paint(planks & ((xx + yy // 3) % 3 == 0), 'S5')
    paint(planks & ~ero4(band), 'K')
    sh = dil8(water) & ~water & F & ~keep_m & ~planks
    paint(sh, 'SN')
    paint(dil8(sh) & ~sh & ~water & F & ~keep_m & ~planks & (lagoon | shallow) & (BAY > 0.5), 'SD')
    paint(water, 'WA')
    lw = water & (lightw | shallow)
    paint(lw & (BAY > 0.55), 'WL')
    deep = ero4(ero4(water))
    paint(deep & ~lw & (BAY > 0.45), 't2')
    paint(ero4(deep) & ~lw & (BAY > 0.2), 't2')
    dw = water & deepw
    paint(ero4(deep) & dw, 't2')
    paint(ero4(ero4(deep)) & dw & (BAY > 0.5), 'D2')
    paint(dw & ero4(deep) & (vnoise(1, 140) > 0.96), 'T2')       # a glint in the deep
    paint(water & grow(~F, 4) & (BAY > 0.3), 'D2')
    foam = water & dil8(~water) & ~grow(~F, 3)
    paint(foam & ((xx + yy) % 2 == 0), 'WL')
    paint(water & ~dil4(~water) & ~lw & (yy % 3 == 0) & ((xx * 3 + yy) % 5 == 0), 'WL')
    paint(water & ~deep & ~lw & (yy % 4 == 1) & (np.sin(xx / 3.0 + yy) > 0.8), 'WL')
    reef = ero4(water) & lightw & (vnoise(1, 141) > 0.95)
    paint(reef, 'PK'); paint(np.roll(reef, 1, axis=1) & ero4(water), 'RH')

    # ------------------------------------------------ 5. PROPS + SCATTER
    near_road = pixmask(road_px, 3)
    keep_pad = np.zeros((H, W), bool)
    for (_, x, y, r) in keeps:
        keep_pad |= disk(x, y, r + 1)
    protect = keep_pad | near_road | root_corr | dil4(occ_water) | planks
    free = F & ~protect & (depth >= 2)
    free_wet = F & ~(keep_pad | near_road | root_corr | planks) & (depth >= 1)
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

    def glow(cx_, cy_, rad, col, extra=None):
        gl = disk(cx_, cy_, rad) & ~keep_pad & ~near_road & ~root_corr & ~occ
        if extra is not None:
            gl &= extra
        lv_ = np.clip(1 - np.hypot(xx - cx_, yy - cy_) / float(rad), 0, 1)
        paint(gl & (lv_ ** 1.2 > BAY + 0.12) & ((xx + yy) % 2 == 0), col)

    log = []
    cone_at = None
    cal_at = None
    boat_at = None
    lh_at = None
    for p in P['props']:
        k, x, y, n = p['kind'], p['x'], p['y'], p.get('n', 1)
        hard = F & ~keep_pad & ~near_road & ~root_corr & ~occ_water & ~planks
        if k == 'frangipani_garden':
            got = None
            for (dx, dy) in [(0, 0), (2, 1), (-2, 1), (0, 3), (3, -2), (-3, -1), (5, 2), (-5, 2), (0, 5), (-6, 4)]:
                gx, gy = x + dx, y + dy
                sl = (slice(gy - 4, gy + 5), slice(gx - 8, gx + 9))
                if hard[sl].all() and not occ[sl].any():
                    gm = (((xx - gx) / 8.5) ** 2 + ((yy - gy) / 4.5) ** 2 + 0.25 * (vnoise(2, 130) - 0.5)) < 1
                    paint(gm, 'GK')
                    paint(gm & ((xx + yy) % 2 == 0), 't1')
                    paint(gm & ((xx * 2 + yy * 3) % 5 == 0), 'WH')
                    paint(gm & ((xx * 2 + yy * 3) % 5 == 2) & ((xx + yy) % 3 == 0), 'GD')
                    paint(gm & ((xx * 2 + yy * 3) % 7 == 3), 'PL')
                    paint(gm & ((xx * 2 + yy * 3) % 11 == 6), 'PK')
                    occ[sl] = True
                    got = (gx, gy)
                    break
        elif k == 'lighthouse':
            got = lh_at = near(x, y, LIGHTHOUSE, None, 12, 0, where=hard)
        elif k == 'breadfruit_tree':
            got = cluster(x, y, [(BREADFRUIT, JUNGLE)], n, 13, 0, where=hard)
        elif k == 'plank_causeway':
            got = int(planks.sum())
        elif k == 'lit_boat':
            got = boat_at = near(x, y, BOAT, None, 14, 0, where=wet_free | (hard & dil8(occ_water)))
        elif k == 'galleon_wreck':
            got = near(x, y, WRECK, None, 14, 0, where=wet_free)
            if not got:
                got = near(x, y, WRECK, None, 16, 0, where=hard | wet_free)
        elif k == 'palm_cluster':
            got = cluster(x, y, [(PALM, None)], n, 11, 0, where=hard)
        elif k == 'waterfall_cascade':
            got = near(x, y, CASCADE, None, 12, 0, where=hard)
            if got:
                glow(got[0], got[1] - 2, 9, 'WL', hard)
        elif k == 'mangrove_arches':
            got = cluster(x, y, [(MANGROVE, None)], n, 12, 0, where=free_wet | wet_free)
        elif k == 'crab_shell_rocks':
            got = cluster(x, y, [(CRABSHELL, None), (CRAG, CRAB_ROCK), (STONE, CRAB_ROCK), (CRABSHELL, None)], n, 10, 0, where=hard)
        elif k == 'caldera_rim':
            got = cal_at = near(x, y + 3, CALDERA, CALROCK, 14, 0, where=hard)
        elif k == 'sky_city_columns':
            got = cluster(x, y, [(COLUMN, None), (COLUMN_S, None), (COLUMN, None)], n, 11, 0, where=hard)
        elif k == 'condor_crag_spire':
            got = cluster(x, y, [(SPIRE, None), (CRAG, None)], n, 10, 0, where=hard)
        elif k == 'turtle_tracks':
            got = None
            for (dx, dy) in [(0, 0), (4, 2), (-4, 2), (0, 4), (6, -2), (-6, 0)]:
                bx_, by_ = x + dx, y + dy
                bar = (((xx - bx_) / 8.0) ** 2 + ((yy - by_) / 3.2) ** 2) < 1
                if (bar & (keep_pad | ~F | near_road | root_corr | occ)).any():
                    continue
                paint(bar, 'SN'); paint(bar & ~ero4(bar), 'SD')
                for t_ in range(-6, 6, 2):
                    put(bx_ + t_, by_ - 1 + (t_ // 2) % 2, 'SD'); put(bx_ + t_, by_ + 1 - (t_ // 2) % 2, 'SD')
                spr(bx_ + 4, by_ + 1, TURTLE)
                occ[by_ - 5:by_ + 4, bx_ - 9:bx_ + 10] = True
                got = (bx_, by_)
                break
        elif k == 'reed_bed':
            got = cluster(x, y, [(CATTAIL, None), (REED, None), (CATTAIL, None)], n, 9, 0, where=free_wet)
        elif k == 'giant_canopy_trunk':
            got = 0
            for rows in (GIANT, BIGTREE, BIGTREE):
                if got >= n:
                    break
                got += bool(near(x + (got * 9 if got else 0), y, rows, JUNGLE, 14, 0, where=hard))
        elif k == 'sealed_tide_gate':
            got = 'mouth'   # drawn with the east mouth (posts) + the --gates overlay (lattice)
        elif k == 'steel_drum_stage':
            got = near(x, y, STAGE, None, 12, 0, where=hard)
        elif k == 'coral_heads':
            got = cluster(x, y, [(CORAL, None)], n, 12, 0, where=wet_free | hard)
        elif k == 'chili_strings':
            got = cluster(x, y, [(CHILI, None)], n, 10, 0, where=hard)
        else:
            got = 'skip'
        log.append((k, x, y, got))

    # biome scatter: palms only on the hub isle (nothing tall at the forks), tall growth in the Lianawood
    zf = lambda z: free & (zone == z)
    scatter([(FERN, JUNGLE), (FERN, None), (FERN_S, JUNGLE), (BIGTREE, JUNGLE), (TREE, JUNGLE), (BUSH, None),
             (PALM, None), (TREE, JUNGLE), (BREADFRUIT, JUNGLE), (TREE_S, JUNGLE)], 240, zf('jungle'), pad=0, tries=8000)
    scatter([(PALM, None), (PALM, None), (SHELL, None)], 16, zf('coral'), pad=2)
    scatter([(PALM, None), (SHELL, None), (PEBBLE, WARMSTONE), (BUSH, None), (SHELL, None)], 46, zf('base'), pad=1)
    scatter([(MAIZE_S, None), (TALLGRASS, None), (MAIZE, None), (AMARANTH, None)], 40, zf('shore'), pad=1)
    scatter([(STONE, REDROCK), (PEBBLE, REDROCK), (TALLGRASS, None)], 10, zf('volc'), pad=1)
    scatter([(CRAG, CALROCK), (STONE, CALROCK), (PEBBLE, CALROCK)], 8, zf('caldera'), pad=0)
    scatter([(MANGROVE, None), (CATTAIL, None), (REED, None), (MANGROVE, None), (BUSH, None)], 50, zf('mangrove'), pad=0)
    scatter([(CRAG, None), (STONE, None), (PEBBLE, None), (PEAK_S, None), (TREE_S, HAZEL)], 40, zf('ridge'), pad=0)
    scatter([(CATTAIL, None), (REED, None), (TREE, HAZEL), (BUSH, None), (TREE_S, JUNGLE)], 34, zf('fen'), pad=0)
    shore_ = dil8(dil8(occ_water)) & ~occ_water & free
    scatter([(REED, None), (SHELL, None), (PALM, None)], 16, shore_, pad=0)
    # flowers: frangipani flecks on the hub, chili red on the shore, orchids in the Lianawood
    fl = free & ~occ & ~dil4(occ)
    paint(fl & (zone == 'coral') & (vnoise(1, 77) > 0.95) & (vnoise(8, 78) > 0.55), 'WH')
    paint(fl & (zone == 'shore') & (vnoise(1, 79) > 0.975) & (vnoise(8, 80) > 0.55), 'RD')
    paint(fl & (zone == 'jungle') & (vnoise(1, 85) > 0.94) & (vnoise(6, 86) > 0.5), 'PK')

    # lanterns beside the trunks
    lamp_cand = pixmask(road_px, 6) & ~pixmask(road_px, 4) & free & ~occ
    ys, xs = np.nonzero(lamp_cand)
    idxs = list(range(len(xs)))
    R.shuffle(idxs)
    lamp_at = []
    for i in idxs:
        x, y = int(xs[i]), int(ys[i])
        if any((x - a) ** 2 + (y - b) ** 2 < 36 ** 2 for a, b in lamp_at):
            continue
        if try_place(x, y, LAMP, None, 0):
            lamp_at.append((x, y))
    for (x, y) in lamp_at:
        lg = disk(x, y - 4, 7) & F & ~keep_pad & ~road_m & ~occ_water
        lv2 = np.clip(1 - np.hypot(xx - x, yy - y + 4) / 7.0, 0, 1)
        paint(lg & (lv2 ** 1.3 > BAY + 0.15) & ((xx + yy) % 2 == 0), 'GD')
    # the first lit boat: lamplight on the water; the relit lighthouse: a warm halo round its lamp
    if boat_at:
        glow(boat_at[0], boat_at[1] - 3, 9, 'GD', occ_water)
    if lh_at:
        glow(lh_at[0], lh_at[1] - 13, 10, 'GD')
    for (y, x, rows, over) in sorted(placed, key=lambda t: t[0]):
        spr(x, y, rows, over)
    # macaws: a red and gold fleck on a few Lianawood canopies
    q = 0
    for (y, x, rows, over) in placed:
        if q >= 3:
            break
        if rows is BIGTREE and over is JUNGLE and zone[y, x] == 'jungle':
            put(x + 2, y - 9, 'RD'); put(x + 3, y - 9, 'GD'); put(x + 3, y - 8, 'T2')
            q += 1
    # the Smokecap Caldera: one ember glow in the crater
    if cal_at:
        cx_, cy_ = cal_at
        top = cy_ - len(CALDERA) + 1
        gl = disk(cx_, top + 1, 7) & ~disk(cx_, top + 1, 3) & ~keep_pad & ~root_corr & ~near_road & ~occ
        paint(gl & (BAY > 0.72), 'RK')
        paint(gl & disk(cx_, top + 1, 5) & (BAY > 0.9), 'T4')

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

    # mouths: lianas over the south (Rainroot) mouth; the east (Greatcanopy) mouth is a tide gate:
    # sea water in the tunnel and two stone posts either side of the trunk (the lattice is --gates)
    for e in exits.values():
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        if e['side'] == 'S':
            for X in range(ex - 12, ex + 13):
                if abs(X - ex) < 5:
                    continue
                ln = 3 + (X * 7) % 5
                top_ = H - 12
                for j in range(ln):
                    Y = top_ + j
                    if not keep_m[Y, X] and not road_m[Y, X] and X % 3 == 0:
                        put(X, Y, 'GM' if j % 2 else 'GK')
        elif e['side'] == 'E':
            for Y in range(ey + 3, ey + 9):
                for X in range(W - 10, W):
                    if not road_m[Y, X] and not F[Y, X] and (X + Y) % 2 == 0:
                        put(X, Y, 'WA' if Y % 3 else 'WL')
            for s in (-1, 1):
                X0 = W - 15
                Y0 = ey + s * 5
                for Y in range(Y0 - 2, Y0 + 3):
                    for X in range(X0, X0 + 4):
                        if road_m[Y, X]:
                            continue
                        edge = X in (X0, X0 + 3) or Y in (Y0 - 2, Y0 + 2)
                        put(X, Y, 'K' if edge else ('AL' if Y == Y0 - 1 else 'AS'))
                put(X0 + 1, Y0 - 3, 'K'); put(X0 + 2, Y0 - 3, 'K'); put(X0 + 1, Y0 - 2, 'GD'); put(X0 + 2, Y0 - 2, 'T4')

    cols = np.unique(img.reshape(-1, 3), axis=0)
    allowed = {tuple(c) for c in PAL.values()}
    assert all(tuple(c) in allowed for c in cols), 'off-palette pixel'
    return img.copy(), dict(keeps=keeps, roads=roads, exits=exits, F=F, log=log)


def gates_overlay(info, sides=('E',)):
    """RGBA 480x270: a lattice across the sealed east tide gate, for the game to drop once the Sunsprinkle Seal is held"""
    ov = np.zeros((H, W, 4), np.uint8)

    def gp(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            ov[y, x, :3] = PAL[c]; ov[y, x, 3] = 255
    for e in info['exits'].values():
        if e['side'] not in sides:
            continue
        ex, ey = edge_pt(e['x'], e['y'], e['side'])
        for a in range(-7, 8):
            for b in range(0, 12):
                u, v = (a, b)
                on = (u + v) % 4 == 0 or (u - v) % 4 == 0
                if not on or abs(u) > 6:
                    continue
                X, Y = (ex + u, H - 1 - v) if e['side'] == 'S' else (W - 1 - v, ey + u)
                gp(X, Y, 'S6' if (u + v) % 8 == 0 else 'S5')
        for a in range(-7, 8):  # dark gaps behind the lattice edge
            for b in (0, 12):
                X, Y = (ex + a, H - 1 - b) if e['side'] == 'S' else (W - 1 - b, ey + a)
                gp(X, Y, 'K')
    return ov


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
    for sid, nm in ((173, 'SUNKEN GALLEON'), (174, 'SINGING WATERFALL'), (176, 'HURRICANE CRAB'), (179, 'SKY CITY RUINS'), (171, 'SMOKECAP CALDERA'), (39, None)):
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
    ap.add_argument('--layout', default=os.environ.get('MAP_V2_LAYOUT', os.path.join(SCRATCH, 'layouts', 'layout-CB.json')))
    ap.add_argument('--plan', default=os.environ.get('MAP_V2_PLAN', os.path.join(SCRATCH, 'plans', 'plan-CB.json')))
    ap.add_argument('--out', default=os.path.join(ROOT, 'game', 'assets', 'img', 'scenes', 'map2-CB.png'))
    ap.add_argument('--preview', default=None)
    ap.add_argument('--gates', default=None)
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
    if a.gates:
        Image.fromarray(gates_overlay(info), 'RGBA').save(a.gates)
        print('wrote', a.gates)
    if a.preview:
        comp = preview(art, info, L, P, slots, spread, anchors)
        Image.fromarray(comp, 'RGB').resize((W * 2, H * 2), Image.NEAREST).save(a.preview)
        print('wrote', a.preview)
