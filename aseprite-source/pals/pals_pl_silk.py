"""Puzzle Pals: THE SILK ROAD CARAVANSERAI (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-silk-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_silk.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: courtyard sprites, keyhole knobs, golden-hour calm. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy, zzz); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-the-silk-road-caravanserai.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Potstack Teeter       terracotta red-brown         | two little pots stacked and tipping on its top knob            | happy ^ ^, open grin
  2 Doorlamp Dozer        lamp gold                    | a hanging lamp hook + flame on top, zzz                        | sleepy lids, small smile
  3 Greenjar Giggle       jar jade green               | a jar lid with a round handle, rattle marks either side        | big round eyes looking up, toothy laugh
  4 Starry Tilework       tile blue (+ star gold)      | gold stars set on a tile grid, mirrored                        | wide sparkly eyes, o mouth
  5 Basin Splashback      fountain stone grey (+ water)| a water band round the brow, mirrored splash drops             | bead dot eyes, cat mouth
  6 Purplehat Haggler     robe rose + purple cone hat  | whimsy gnome merchant, white beard, seed pouch, glow (rare)    | twinkle eye, beard
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-silk-road-caravanserai'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-silk-road-caravanserai-f002ba')

TERRA = ('#a4523a', '#c8724e')         # clay pots
LAMPG = ('#c8962e', '#e8bc4e')         # golden lamp
JADE_ = ('#3e8a5a', '#5eaa74')         # green jar
TILE = ('#2e5e9a', '#4a80ba')          # blue tiles
BASIN = ('#8a8c96', '#aeb0b8')         # fountain stone
ROSE = ('#b45a78', '#d47c96')          # gnome robe (rare)
STAR = ('#f4cc4a', '#fff0a0')
WATER = ('#7cc4ec', '#ffffff')
POT = ('#b86a44', '#7a3e26', '#e0a070')
LID = ('#2e6a44', '#7cc494')
HAT = ('#6a3a9a', '#8c5abc', '#4a2672')
BEARD = ('#f4f0e8', '#d0c8bc')
SKIN = '#f0c09a'
BRASS = ('#8a6a2a', '#b8923e')
FLAME = ('#f08a2a', '#ffd86a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def dot(st, x, y, col):
    st.px[y, x] = hx(col)
    st.extra[y, x] = True


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def star(st, cx, cy):
    st.paint(rect(cx - 1, cy, cx + 1, cy) | rect(cx, cy - 1, cx, cy + 1), STAR[0], solid=True)
    dot(st, cx, cy, STAR[1])


def pot(st, cx, by, w, h, tilt):
    m = poly([(cx - w + tilt, by - h), (cx + w + tilt, by - h), (cx + w + 1, by - 2), (cx + w - 1, by),
              (cx - w + 1, by), (cx - w - 1, by - 2)])
    st.part(m, POT[0], d=1, contour=True)
    st.paint(rect(cx - w + 1 + tilt, by - h - 1, cx + w - 1 + tilt, by - h), POT[1], solid=True)
    st.paint(rect(cx - w + 1, by - h + 2, cx - w + 1, by - 2), POT[2])
    return m


# ------------------------------------------------------------------ 1. Potstack Teeter: corner-TT keyhole, common.
def potstack():
    key = 'pl-silk-1'
    st = Sticker()
    core = (12, 24, 44, 53)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(TERRA)), contour=True)
    st.stitch(body, col='#f0b08a')
    pot(st, 27, 21, 6, 6, 0)
    pot(st, 30, 14, 4, 5, 1)
    for x, y in ((18, 8), (40, 8)):
        dot(st, x, y, POT[2])
        dot(st, x + 1, y - 1, POT[2])
    happy_eye(st, 17, 33)
    happy_eye(st, 31, 33)
    st.mouth('grin', 24, 41)
    st.paint(rect(14, 39, 16, 39) | rect(37, 39, 39, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Doorlamp Dozer: edge-TTB keyhole, common.
def doorlamp():
    key = 'pl-silk-2'
    st = Sticker()
    core = (14, 27, 48, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 27, 35, list(LAMPG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#7a5a1a', skip=grow(holes, 3))
    # brass hook bar, hanging chain and a small flame cap
    st.part(rect(20, 22, 42, 24), BRASS[0], d=1, contour=True)
    st.paint(rect(20, 22, 42, 22), BRASS[1])
    st.paint(rect(31, 9, 31, 13), BRASS[0], solid=True)
    st.paint(poly([(29, 15), (31, 10), (33, 15)]) | disc(31, 15, 1.6), FLAME[0], solid=True)
    dot(st, 31, 14, FLAME[1])
    zzz(st, 47, 12)
    st.eye(21, 36, lid=3)
    st.eye(36, 36, lid=3)
    st.mouth('smile', 29, 44)
    st.paint(rect(17, 42, 19, 42) | rect(44, 42, 46, 42), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Greenjar Giggle: inner-TBTB keyhole, common.
def greenjar():
    key = 'pl-silk-3'
    st = Sticker()
    core = (15, 20, 47, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 20, 33, list(JADE_)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LID[1], skip=grow(holes, 3))
    # lid with a round handle, tilted by the giggle; rattle marks
    st.part(poly([(20, 21), (42, 18), (43, 21), (21, 24)]), LID[0], d=1, contour=True)
    st.part(disc(31, 15, 2.5), LID[1], d=1, contour=True)
    for x, y in ((14, 14), (12, 17), (49, 12), (51, 15)):
        dot(st, x, y, UMBER)
    st.eye(20, 29, look=(0, -1))
    st.eye(36, 29, look=(0, -1))
    st.mouth('tooth', 29, 39)
    st.paint(rect(17, 37, 19, 37) | rect(43, 37, 45, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Starry Tilework: inner-TTTT keyhole, uncommon.
def tilework():
    key = 'pl-silk-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(TILE)), contour=True)
    grid = (rect(24, 18, 24, 45) | rect(39, 18, 39, 45) | rect(18, 24, 45, 24)) & shrink(body, 1)
    st.paint(grid, '#1e4272')
    st.stitch(body, col=STAR[0])                                    # uncommon accent: star gold
    for x, y in ((21, 21), (42, 21), (21, 42), (42, 42), (31, 11), (31, 52), (11, 31), (52, 31)):
        star(st, x, y)
    st.eye(22, 28)
    st.eye(36, 28)
    dot(st, 23, 29, '#ffffff')
    dot(st, 37, 29, '#ffffff')
    st.mouth('o', 30, 38)
    return key, st


# ------------------------------------------------------------------ 5. Basin Splashback: inner-BBBB double, uncommon.
def basin():
    key = 'pl-silk-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(BASIN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=WATER[0], skip=grow(holes, 3))              # uncommon accent: water blue
    # water band across the brow with ripple lights, mirrored splash drops
    st.part(rect(17, 17, 46, 21), '#4a9ad0', d=1, contour=True)
    for x in (20, 26, 37, 43):
        st.paint(rect(x, 18, x + 1, 18), WATER[1])
    for x, y in ((20, 25), (43, 25), (16, 29), (47, 29)):
        st.paint(disc(x, y, 1.2), WATER[0], solid=True)
        dot(st, x, y, WATER[1])
    st.paint(rect(23, 29, 25, 31) | rect(38, 29, 40, 31), UMBER, solid=True)
    st.mouth('cat', 29, 37)
    st.paint(rect(21, 35, 22, 35) | rect(41, 35, 42, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Purplehat Haggler: whimsy-merchant keyhole, rare.
def haggler():
    key = 'pl-silk-6'
    st = Sticker()
    robe = poly([(20, 36), (42, 36), (48, 54), (14, 54)])
    tab_w = knob('w', 'keyhole', 45, 17.5, r=3.0)
    tab_e = knob('e', 'keyhole', 45, 45.5, r=3.0)
    body = robe | tab_w | tab_e
    st.part(body, tex=fill(key, body, 12, 34, 38, list(ROSE)), contour=True)
    st.paint(rect(16, 49, 46, 50) & robe, '#e8bc4e')                 # gold hem
    face = ellipse(31, 30, 8, 6)
    st.part(face, SKIN, d=1, contour=True)
    beard = poly([(23, 31), (39, 31), (36, 42), (31, 45), (26, 42)])
    st.part(beard, BEARD[0], d=1, contour=True)
    st.paint(beard & (CY > 40), BEARD[1])
    hat = poly([(21, 26), (41, 26), (34, 13), (38, 8), (30, 11)])
    st.part(hat, HAT[0], d=1, contour=True)
    st.paint(rect(21, 24, 41, 26) & hat, HAT[2])
    st.paint(poly([(25, 23), (31, 12), (29, 23)]), HAT[1])
    st.part(disc(32, 32, 1.6), '#e08a7a', d=1)                       # nose
    st.paint(rect(26, 28, 28, 28), UMBER, solid=True)
    st.paint(rect(35, 28, 37, 28), UMBER, solid=True)
    st.paint(rect(27, 27, 27, 27) | rect(36, 27, 36, 27), UMBER, solid=True)
    # seed pouch held out on the east
    st.part(disc(52, 45, 3.5), '#a07a4a', d=1, contour=True)
    st.paint(rect(51, 41, 53, 41), '#6a4a22', solid=True)
    st.paint(disc(52, 39, 1.0), STAR[0], solid=True)
    st.sparkle(50, 15)
    st.sparkle(14, 18, big=False)
    st.sparkle(10, 46, big=False)
    return key, st


PALS = [potstack, doorlamp, greenjar, tilework, basin, haggler]

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
        print('%-10s %-19s %-9s %-14s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
