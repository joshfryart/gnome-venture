"""Puzzle Pals: THATCHTOP TEAROOM (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-thch-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_thch.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a thatched cottage tearoom, round knobs, soft afternoon. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob,
body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/haven-thatchtop-tearoom.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Chimney Wink      brick red-brown             | a chimney pot on its top with three smoke puffs              | wink + smirk
  2 Sill Sprinkle     rose pink                   | a window box of pink flowers + a tiny blue teapot pouring    | happy closed ^ ^ eyes, cat mouth
  3 Knock Knock       door green                  | round-top door panels, brass knocker, a scone held out        | big open eyes looking up, grin
  4 Scone Tower       scone gold (+ jam red)      | three stacked scones, jam dollop + cream on top               | round eyes, toothy happy grin
  5 Gable Eye         window sky blue (+ straw)   | thatch fringe brow, cross window bars                          | sleepy owl lids, small o
  6 Teatime Hedgehog  hedgehog spine brown        | whimsy hedgehog with spines, cream face, teacup on a saucer (rare) | gentle side-look, smile, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-thatchtop-tearoom'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-thatchtop-tearoom-0ce3c9')

BRICK = ('#a4563a', '#c0704c')
ROSE = ('#d47a96', '#eaa0b6')
DOOR = ('#3f7a4a', '#559456')
SCONE = ('#c88a3e', '#e2aa5a')
SKY = ('#6fa8c8', '#98c8e2')
SPINE = ('#7a4a2c', '#96603a')
JAM = ('#b8283a', '#e04a5a')
CLOT = '#fbf0d0'
STRAW = ('#c8a050', '#8a6a2a', '#e6c47a')
SMOKE = ('#d8d4cc', '#f2f0ea')
TEAPOT = ('#5a8ac0', '#3a6a9a', '#a8c8e8')
BRASS = ('#e8b83a', '#a87a1a')
CUP = ('#f4eee0', '#c8bca0')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def puff(st, cx, cy, r):
    m = disc(cx, cy, r)
    st.paint(m, SMOKE[0], solid=True)
    st.paint(disc(cx - r * 0.35, cy - r * 0.35, r * 0.55), SMOKE[1])
    return m


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def flower(st, x, y):
    st.sprite(['.p.', 'pyp', '.p.'], x, y, {'p': '#f08ab0', 'y': '#f8e070'}, solid=True)


# ------------------------------------------------------------------ 1. Chimney Wink: corner-BB round, common.
def chimney_wink():
    key = 'pl-thch-1'
    st = Sticker()
    stack = rect(18, 17, 25, 28)
    st.part(stack, '#8a4a30', d=1, contour=True)
    st.paint(rect(18, 20, 25, 20) | rect(18, 24, 25, 24) | rect(21, 17, 21, 19) | rect(23, 21, 23, 23), '#6a3420')
    pot = rect(19, 12, 24, 16)
    st.part(pot, '#c8763a', d=1, contour=True)
    st.paint(rect(18, 12, 25, 12), '#e09a5a', solid=True)
    puff(st, 28, 9, 2.4)
    puff(st, 33, 8, 1.8)
    puff(st, 37, 9, 1.4)
    core = (12, 26, 46, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 6, 2.8), e=('B', 'round', 1, 2.8))
    st.part(body, tex=fill(key, body, 12, 26, 35, list(BRICK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e8b08a', skip=grow(holes, 3))
    wink(st, 18, 34)
    st.eye(30, 33, look=(1, 0))
    st.mouth('smirk', 23, 42)
    st.paint(rect(16, 40, 18, 40) | rect(36, 40, 38, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Sill Sprinkle: edge-TTB peg, common.
def sill_sprinkle():
    key = 'pl-thch-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -4, 3.4), w=('T', 'peg', 2, 3.4), e=('B', 'peg', 2, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(ROSE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fbe0ea', skip=grow(holes, 3))
    box = rect(16, 25, 41, 29)
    st.part(box, '#8a5a34', d=1, contour=True)
    st.paint(rect(16, 25, 41, 25), '#b07a4a')
    for x in (17, 22, 27, 33, 38):
        st.part(rect(x + 1, 20, x + 1, 24), '#4a8a3a', d=0, contour=False, shade=False)
        flower(st, x, 18)
    # tiny teapot pouring top-right
    pot = ellipse(50, 13, 4.2, 3.4)
    st.part(pot, TEAPOT[0], d=1, contour=True)
    st.paint(pot & (CX < 49) & (CY < 12), TEAPOT[2])
    spout = line([(46, 13), (43, 11)], w=2)
    st.part(spout, TEAPOT[0], d=1, contour=True)
    st.paint(rect(49, 8, 51, 9), TEAPOT[1], solid=True)
    st.paint(rect(42, 13, 42, 13) | rect(41, 15, 41, 15) | rect(42, 17, 42, 17), '#a8d8f0', solid=True)
    closed_up(st, 20, 35)
    closed_up(st, 32, 35)
    st.mouth('cat', 27, 41)
    st.paint(rect(18, 39, 20, 39) | rect(37, 39, 39, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Knock Knock: inner-TBTB round, common.
def knock_knock():
    key = 'pl-thch-3'
    st = Sticker()
    core = (14, 17, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 16, 33, list(DOOR)), contour=True)
    st.blank_shade(body, holes, width=1)
    dark = '#2a5a34'
    st.paint(rect(30, 18, 30, 46) & shrink(body, 2), dark)                 # door seam
    st.paint((rect(18, 37, 27, 44) & ~rect(19, 38, 26, 43)) | (rect(33, 37, 42, 44) & ~rect(34, 38, 41, 43)), dark)
    st.paint(disc(37, 32, 1.8), BRASS[0], solid=True)                      # brass knocker ring
    st.paint(disc(37, 32, 0.6), BRASS[1])
    st.eye(20, 24, look=(0, -1))
    st.eye(34, 24, look=(0, -1))
    st.mouth('grin', 25, 31)
    sc = ellipse(52, 45, 4.5, 3.4)
    st.part(sc, SCONE[1], d=1, contour=True)
    st.paint(sc & (CY < 44), '#f2c87a')
    st.paint(rect(50, 43, 54, 43), JAM[0])
    return key, st


# ------------------------------------------------------------------ 4. Scone Tower: inner-TTTT peg, uncommon.
def scone_tower():
    key = 'pl-thch-4'
    st = Sticker()
    core = (18, 20, 45, 47)
    body = piece(core, n=('T', 'peg', 0, 3.6), e=('T', 'peg', 0, 3.6), s=('T', 'peg', 0, 3.6), w=('T', 'peg', 0, 3.6))
    st.part(body, tex=fill(key, body, 18, 20, 28, list(SCONE)), contour=True)
    st.stitch(body, col=JAM[1])                                            # uncommon accent: jam red
    for y in (29, 38):                                                      # scone layers
        st.paint(rect(19, y, 44, y) & shrink(body, 1), '#9a6428')
    jam = ellipse(31.5, 10, 3.4, 2.4)
    st.paint(jam, JAM[0], solid=True)
    st.paint(disc(31.5, 7.5, 1.6), CLOT, solid=True)
    st.dots([(30, 9)], JAM[1])
    st.eye(23, 23, look=(0, 0))
    st.eye(36, 23, look=(0, 0))
    st.mouth('tooth', 29, 32)
    st.paint(rect(21, 31, 23, 31) | rect(40, 31, 42, 31), BLUSH)
    for x, y in ((24, 43), (31, 42), (38, 43)):
        st.dots([(x, y)], '#7a4a1a')                                      # currants
    return key, st


# ------------------------------------------------------------------ 5. Gable Eye: inner-BBBB round, uncommon.
def gable_eye():
    key = 'pl-thch-5'
    st = Sticker()
    core = (12, 14, 51, 51)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 14, 40, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=STRAW[2], skip=grow(holes, 3))                    # uncommon accent: thatch straw
    fringe = rect(14, 19, 49, 22) & body
    st.paint(fringe, STRAW[0])
    st.paint(fringe & (XX % 3 == 0), STRAW[1])
    st.paint(rect(14, 19, 49, 19) & body, STRAW[2])
    bars = '#f4eee0'
    st.paint((rect(31, 23, 32, 48) | rect(15, 39, 48, 40)) & shrink(body, 2), bars)
    st.eye(20, 27, lid=2)
    st.eye(39, 27, lid=2)
    st.mouth('o', 30, 34)
    return key, st


# ------------------------------------------------------------------ 6. Teatime Hedgehog: whimsy-hedgehog peg, rare.
def teatime_hedgehog():
    key = 'pl-thch-6'
    st = Sticker()
    back = ellipse(33, 36, 18, 14)
    spikes = blank()
    for i in range(9):
        a = math.pi * (0.95 + 1.1 * i / 8)
        x, y = 33 + 17 * math.cos(a), 36 + 13 * math.sin(a)
        spikes |= poly([(x - 2.5, y), (x + 4 * math.cos(a), y + 4 * math.sin(a)), (x + 2.5, y)])
    tab = knob('e', 'peg', 38, 48.5, r=3.0)
    body = back | spikes | tab
    st.part(body, tex=fill(key, body, 12, 16, 44, list(SPINE)), contour=True)
    st.paint(body & ((XX + 2 * YY) % 6 == 0) & shrink(body, 2), '#4a2a18')
    face = ellipse(21, 40, 9, 8)
    st.part(face, '#f0d8a8', d=1, contour=True)
    st.paint(disc(12, 42, 1.6), UMBER, solid=True)                          # nose
    st.eye(15, 34, look=(-1, 0))
    st.eye(23, 34, look=(-1, 0))
    st.mouth('smile', 15, 42)
    st.paint(rect(12, 39, 13, 39) | rect(26, 40, 28, 40), BLUSH)
    for x in (21, 41):
        st.part(ellipse(x, 51, 3, 2), '#5a3420', d=1, contour=True)
    sau = ellipse(46, 22, 7, 1.6)
    st.part(sau, CUP[1], d=1, contour=True)
    cup = rect(42, 15, 50, 21)
    st.part(cup, CUP[0], d=1, contour=True)
    st.paint(rect(43, 15, 49, 15), '#a8642a')
    st.paint(rect(51, 17, 52, 19) & ~rect(51, 18, 51, 18), CUP[1], solid=True)
    st.paint(rect(43, 18, 49, 18), ROSE[0])
    st.sparkle(6, 6)
    st.sparkle(30, 6, big=False)
    st.sparkle(56, 8, big=False)
    return key, st


import math  # noqa: E402

PALS = [chimney_wink, sill_sprinkle, knock_knock, scone_tower, gable_eye, teatime_hedgehog]

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
        print('%-10s %-17s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
