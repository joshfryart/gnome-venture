"""Puzzle Pals: TURTLE NESTING BEACH (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-turt-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_turt.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a Caribbean beach at night, hatchlings heading for the moonlit sea; round knobs. kit_lair parts used
only as building blocks (PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob,
body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/haven-turtle-nesting-beach.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Moonlit Beam         full-moon butter yellow   | craters + a fan of moonbeams pouring down                      | sleepy content lids, cat :3
  2 Flipper Dash         hatchling olive-brown     | two flapping flippers, dash speed lines behind                  | determined eyes ahead, puffing o
  3 Wave Ribbon          night-sea blue            | a foam crest curling over its head, spray drops                 | cheeky wink, smirk
  4 Hatchling Line       moon-sand tan (+green)    | four tiny hatchlings on its four tabs, flipper-print trail     | eyes sideways, tooth grin
  5 Mama Shell           mossy shell green (+moss) | hexagon scute pattern, moss tuft on top                         | shy look-down eyes, blush, small smile
  6 Moonshell Hatchling  moon lavender (rare)      | whimsy hatchling: dome shell, head, 4 flippers, crescent moon  | big happy grin, wide eyes
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-turtle-nesting-beach'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-turtle-nesting-beach-ffa682')

MOON = ('#e8c050', '#f8e08a')          # full moon butter yellow
HATCH = ('#5a5a2e', '#7a7a3e')         # hatchling olive-brown
SEA = ('#2a4a8a', '#3e68b0')           # night sea blue
SANDT = ('#b0a090', '#ccbca8')         # moonlit sand tan
SHELL = ('#3e7a34', '#5e9a3e')         # mossy shell green
LAV = ('#8c88af', '#aaa6cc')           # moon lavender (rare, picture dominant)
FOAM = ('#eef4fc', '#a8c0e0')
BEAM = ('#fff3c8', '#f8dc6a')
FLIP = ('#3a3a1e', '#6a6a36')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def mark(st, m, col):
    st.paint(m, col)
    st.extra |= m


def beams(st, cx, cy, n=5):
    m = blank()
    for i in range(n):
        a = math.radians(60 + 60.0 * i / (n - 1))
        m |= line([(cx + 2 * math.cos(a), cy + 2 * math.sin(a)), (cx + 12 * math.cos(a), cy + 12 * math.sin(a))], w=1)
    mark(st, m, BEAM[1])
    return m


def flipper(st, cx, cy, side):
    m = ellipse(cx, cy, 5, 2.4) | ellipse(cx + 3 * side, cy + 2, 2.5, 1.8)
    st.part(m, FLIP[1], d=1, contour=True)
    return m


def speed_lines(st, x, ys):
    m = blank()
    for i, y in enumerate(ys):
        m |= rect(x - 2 * i, y, x + 4 - 2 * i, y)
    mark(st, m, FOAM[1])


def foam_crest(st, cx, cy):
    m = (disc(cx, cy, 6) & ~disc(cx + 2.5, cy + 2.5, 4.2)) | disc(cx - 5, cy + 2, 2)
    st.part(m, FOAM[0], d=1, contour=True)
    return m


def drop(st, x, y):
    mark(st, rect(x, y, x, y + 1) | rect(x - 1, y + 1, x + 1, y + 2), FOAM[0])


def tiny_hatch(st, cx, cy):
    s = ellipse(cx, cy, 3.2, 2.4)
    st.part(s, SHELL[0], d=1, contour=True)
    st.part(disc(cx, cy - 2.6, 1.4), HATCH[1], d=0, contour=True, shade=False)
    st.dots([(int(cx), int(cy - 3))], UMBER)


def print_trail(st, x0, y0, x1, y1, n=4):
    m = blank()
    for i in range(n):
        t = i / (n - 1)
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        m |= rect(int(x) - 2, int(y), int(x) - 1, int(y)) | rect(int(x) + 1, int(y), int(x) + 2, int(y))
    st.paint(m, '#8a7a68')


def scutes(st, body, cx, cy):
    m = blank()
    for dx, dy in ((0, 0), (-8, -5), (8, -5), (-8, 6), (8, 6), (0, -10), (0, 11)):
        h = poly([(cx + dx - 3, cy + dy), (cx + dx - 1.5, cy + dy - 3), (cx + dx + 1.5, cy + dy - 3),
                  (cx + dx + 3, cy + dy), (cx + dx + 1.5, cy + dy + 3), (cx + dx - 1.5, cy + dy + 3)])
        m |= h & ~shrink(h, 1)
    st.paint(m & shrink(body, 2), '#2a5a24')


def moss(st, cx, cy):
    m = disc(cx, cy, 3) | disc(cx - 3, cy + 1, 2.2) | disc(cx + 3, cy + 1, 2.2)
    st.part(m, '#8ab84e', d=1, contour=True)
    return m


def crescent(st, cx, cy, r):
    m = disc(cx, cy, r) & ~disc(cx + r * 0.6, cy - r * 0.3, r * 0.85)
    st.paint(m, BEAM[0], solid=True)


# ------------------------------------------------------------------ 1. Moonlit Beam: corner-TB round, common.
def moonlit_beam():
    key = 'pl-turt-1'
    st = Sticker()
    core = (12, 17, 43, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 3.0))
    body = body & ~(rect(0, 32, 27, 63) & ~disc(27.5, 31.5, 15))      # moon-round lower-left belly
    st.part(body, tex=fill(key, body, 12, 13, 34, list(MOON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c09a3a', skip=grow(holes, 3))
    for cx, cy, r in ((35, 24, 2.2), (19, 41, 1.6), (36, 41, 1.5)):
        st.paint(disc(cx, cy, r), '#d8a840')
    beams(st, 25, 44)
    st.sprite(['UUUUU'], 17, 31, {'U': UMBER}, solid=False)
    st.sprite(['UUUUU'], 30, 31, {'U': UMBER}, solid=False)
    st.paint(rect(15, 35, 17, 35) | rect(37, 35, 39, 35), BLUSH)
    st.mouth('cat', 24, 35)
    return key, st


# ------------------------------------------------------------------ 2. Flipper Dash: edge-TTB peg, common.
def flipper_dash():
    key = 'pl-turt-2'
    st = Sticker()
    core = (18, 18, 45, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 3.0), e=('T', 'peg', -2, 3.2), w=('T', 'peg', -2, 3.2))
    st.part(body, tex=fill(key, body, 18, 18, 28, list(HATCH)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8a868', skip=grow(holes, 3))
    flipper(st, 12, 24, -1)
    flipper(st, 51, 24, 1)
    speed_lines(st, 12, (42, 46, 50))
    st.eye(22, 27, look=(1, 0), lid=1)
    st.eye(34, 27, look=(1, 0), lid=1)
    st.mouth('o', 30, 37)
    return key, st


# ------------------------------------------------------------------ 3. Wave Ribbon: inner-TBTB round, common.
def wave_ribbon():
    key = 'pl-turt-3'
    st = Sticker()
    core = (14, 20, 43, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.4), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.4), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 30, list(SEA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FOAM[1], skip=grow(holes, 3))
    foam_crest(st, 45, 14)
    drop(st, 52, 24)
    drop(st, 8, 14)
    wink(st, 19, 28)
    st.eye(32, 27)
    st.mouth('smirk', 25, 37)
    st.paint(rect(17, 35, 19, 35) | rect(38, 35, 40, 35), '#8aa0d8')
    return key, st


# ------------------------------------------------------------------ 4. Hatchling Line: inner-TTTT peg, uncommon.
def hatchling_line():
    key = 'pl-turt-4'
    st = Sticker()
    core = (20, 20, 43, 43)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 18, 28, list(SANDT)), contour=True)
    st.stitch(body, col=SHELL[1])                                 # uncommon accent: hatchling green
    tiny_hatch(st, 31.5, 14)
    tiny_hatch(st, 31.5, 51)
    tiny_hatch(st, 13, 33)
    tiny_hatch(st, 50, 33)
    print_trail(st, 26, 39, 37, 39)
    st.eye(23, 25, look=(-1, 0))
    st.eye(35, 25, look=(1, 0))
    st.mouth('tooth', 29, 32)
    return key, st


# ------------------------------------------------------------------ 5. Mama Shell: inner-BBBB round, uncommon.
def mama_shell():
    key = 'pl-turt-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.2), e=('B', 'round', 0, 3.2), s=('B', 'round', 0, 3.2), w=('B', 'round', 0, 3.2))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(SHELL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8c070', skip=grow(holes, 3))          # uncommon accent: sand gold
    scutes(st, body, 32, 37)
    moss(st, 32, 9)
    st.eye(21, 19, look=(0, 1))
    st.eye(38, 19, look=(0, 1))
    st.paint(rect(17, 27, 19, 27) | rect(44, 27, 46, 27), BLUSH)
    st.mouth('smile', 30, 26)
    return key, st


# ------------------------------------------------------------------ 6. Moonshell Hatchling: whimsy-hatchling peg, rare.
def moonshell_hatchling():
    key = 'pl-turt-6'
    st = Sticker()
    for cx, cy in ((17, 34), (47, 34)):
        st.part(ellipse(cx, cy, 6, 2.6), FLIP[1], d=1, contour=True)
    for cx, cy in ((21, 49), (43, 49)):
        st.part(ellipse(cx, cy, 4, 2.4), FLIP[1], d=1, contour=True)
    shell = ellipse(32, 38, 16, 12) & (YY < 50)
    tab = knob('s', 'peg', 32, 49, r=2.6)
    body = shell | tab
    st.part(body, tex=fill(key, body, 16, 26, 34, list(LAV)), contour=True)
    st.stitch(shell, col='#e8e4ff')
    crescent(st, 32, 40, 5)
    head = disc(32, 18, 9)
    st.part(head, HATCH[1], d=1, contour=True)
    st.eye(25, 15)
    st.eye(34, 15)
    st.mouth('grin', 30, 21)
    st.paint(rect(24, 21, 26, 21) | rect(38, 21, 40, 21), BLUSH)
    st.sparkle(9, 9)
    st.sparkle(50, 9, big=False)
    st.sparkle(51, 44, big=False)
    return key, st


PALS = [moonlit_beam, flipper_dash, wave_ribbon, hatchling_line, mama_shell, moonshell_hatchling]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-10s %-20s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
