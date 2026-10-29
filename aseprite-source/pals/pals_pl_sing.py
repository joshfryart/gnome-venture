"""Puzzle Pals: THE SINGING WATERFALL (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-sing-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_sing.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: waterfall sprites, keyhole knobs, cool spray calm. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-the-singing-waterfall.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Hummed Quaver         note cream                   | a black eighth-note quaver floating off its top knob          | humming closed eyes, o mouth
  2 Prism Streamer        lilac violet                 | a rainbow ribbon arc streaming over its top                    | one-eye wink, side smile
  3 Misty Foamcap         foam white-aqua              | a puffy foam cap of bubbles on its head                       | sleepy lids, cat mouth
  4 Pondrock Islets       pond-rock grey (+ pool blue) | a ripple ring at its feet, tiny pink flowers on its knobs     | happy ^ ^, open laugh
  5 Tuckaway Ledge        cliff dark green (+ blossom) | two mirrored water-curtain strands, a row of hidden blooms     | wide sparkly eyes, flat mouth
  6 Hollowhome Bluebird   bluebird blue + peach belly  | whimsy bluebird in a round green cliff hollow, singing (rare)  | bright bead eye, open beak
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-singing-waterfall'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-singing-waterfall-c23710')

NOTEC = ('#e8dcb4', '#f8f0d0')         # note cream
LILAC = ('#8a6ab4', '#ac8ed4')         # prism lilac
FOAM = ('#c8e4ec', '#eef8fa')          # foam
ROCK = ('#6a7078', '#8e959c')          # pond rock
CLIFF = ('#23402d', '#3a6a3e')         # dark ledge
BLUE = ('#3a6ac4', '#5a8ee0')          # bluebird (rare)
PEACH = ('#f0b890', '#d8986a')
GRASS = ('#4a8a3e', '#6aaa52', '#2e5a2a')
WATER = ('#94cdda', '#ffffff', '#5aa0c4')
RAINBOW = ('#e04a4a', '#f09a3a', '#f0d84a', '#5ab84a', '#4a8ae0', '#8a5ac4')
FLOWER = ('#f08ab4', '#f8d84a', '#ffffff')
INK = '#2a2430'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def dot(st, x, y, col):
    st.px[y, x] = hx(col)
    st.extra[y, x] = True


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def hum_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def bloom(st, x, y, col):
    for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
        dot(st, x + dx, y + dy, col)
    dot(st, x, y, FLOWER[1])


# ------------------------------------------------------------------ 1. Hummed Quaver: corner-TB keyhole, common.
def quaver():
    key = 'pl-sing-1'
    st = Sticker()
    core = (12, 24, 44, 52)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(NOTEC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#b8a878', skip=grow(holes, 3))
    # eighth-note quaver drifting up-right off the top knob
    st.part(ellipse(42, 18, 3.4, 2.4), INK, d=1, contour=True)
    st.paint(rect(45, 8, 45, 17), INK, solid=True)
    st.paint(line([(45, 8), (48, 10), (50, 12), (49, 15)]), INK, solid=True)
    st.paint(rect(41, 17, 41, 17), '#6a6478')
    for x, y in ((12, 12), (16, 10), (52, 22)):
        dot(st, x, y, WATER[0])
    hum_eye(st, 18, 34)
    hum_eye(st, 32, 34)
    st.mouth('o', 26, 42)
    st.paint(rect(15, 39, 17, 39) | rect(37, 39, 39, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Prism Streamer: edge-TBT keyhole, common.
def prism():
    key = 'pl-sing-2'
    st = Sticker()
    core = (16, 27, 48, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 16, 27, 33, list(LILAC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8c4ec', skip=grow(holes, 3))
    # rainbow ribbon arc streaming over the top
    for i, c in enumerate(RAINBOW):
        r = 20 - i
        arc = ellipse(34, 26, r, r * 0.75) & ~ellipse(34, 26, r - 1, r * 0.75 - 1) & (CY < 24)
        st.paint(arc, c, solid=True)
    st.paint(rect(20, 39, 24, 39) | rect(20, 38, 20, 38) | rect(24, 38, 24, 38), UMBER)    # wink
    st.eye(37, 36)
    st.sprite(['U...', '.UUU'], 29, 46, {'U': UMBER}, solid=False)
    st.paint(rect(17, 43, 19, 43) | rect(44, 43, 46, 43), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Misty Foamcap: inner-TBTB keyhole, common.
def foamcap():
    key = 'pl-sing-3'
    st = Sticker()
    core = (15, 20, 47, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 20, 33, list(FOAM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=WATER[2], skip=grow(holes, 3))
    # foam cap: a cluster of bubbles on the head
    for x, y, r in ((22, 20, 4), (31, 15, 5), (40, 20, 4), (27, 21, 3.5), (36, 21, 3.5)):
        st.part(disc(x, y, r), '#ffffff', d=1, contour=True)
    for x, y in ((29, 12), (20, 18), (39, 18)):
        dot(st, x, y, WATER[0])
    for x, y in ((9, 12), (54, 12), (52, 8)):
        st.paint(disc(x, y, 1.2), WATER[0], solid=True)
    st.eye(21, 30, lid=2)
    st.eye(36, 30, lid=2)
    st.mouth('cat', 29, 39)
    st.paint(rect(18, 37, 20, 37) | rect(41, 37, 43, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Pondrock Islets: inner-TTTT keyhole, uncommon.
def pondrock():
    key = 'pl-sing-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(ROCK)), contour=True)
    st.stitch(body, col=WATER[0])                                   # uncommon accent: pool blue
    # ripple ring across the lower body, flowers on each knob-island
    st.paint((ellipse(31.5, 44, 12, 2) & ~ellipse(31.5, 44, 10, 1)) & body, WATER[0], solid=True)
    for x, y in ((31, 10), (31, 53), (10, 31), (53, 31)):
        bloom(st, x, y, FLOWER[0])
    happy_eye(st, 22, 27)
    happy_eye(st, 37, 27)
    st.sprite(['.UUUU.', 'URRRRU', '.URRU.'], 29, 34, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Tuckaway Ledge: inner-BBBB double, uncommon.
def ledge():
    key = 'pl-sing-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(CLIFF)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FLOWER[0], skip=grow(holes, 3))             # uncommon accent: blossom pink
    # two mirrored water-curtain strands framing the face
    for x in (16, 18, 45, 47):
        st.paint(rect(x, 17, x, 44), WATER[0], solid=True)
        st.paint(rect(x, 17, x, 19), WATER[1], solid=True)
    # the ledge shelf with hidden blooms
    st.part(rect(21, 40, 42, 43), '#5a5048', d=1, contour=True)
    for x, c in ((24, FLOWER[0]), (31, FLOWER[2]), (38, FLOWER[0])):
        bloom(st, x, 38, c)
    st.eye(24, 25)
    st.eye(34, 25)
    dot(st, 25, 26, WATER[1])
    dot(st, 35, 26, WATER[1])
    st.mouth('flat', 30, 33)
    st.paint(rect(22, 31, 23, 31) | rect(40, 31, 41, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Hollowhome Bluebird: whimsy-bluebird keyhole, rare.
def bluebird():
    key = 'pl-sing-6'
    st = Sticker()
    hollow = disc(31, 35, 18)
    tab = knob('n', 'keyhole', 31, 17.5, r=3.0)
    st.part(hollow | tab, tex=fill(key, hollow | tab, 11, 10, 42, list(GRASS[:2])), contour=True)
    st.paint(disc(31, 35, 14), '#1a2a1e', solid=True)              # round dark hollow
    birdb = ellipse(31, 40, 10, 8) | disc(31, 30, 7.5)
    st.part(birdb, tex=fill(key, birdb, 20, 22, 22, list(BLUE)), contour=True)
    st.paint(ellipse(31, 42, 6, 5) & birdb, PEACH[0], solid=True)
    st.paint(ellipse(31, 45, 5, 2) & birdb, PEACH[1])
    st.paint(rect(16, 49, 46, 52) & hollow, '#6a5038', solid=True)  # hollow lip
    st.paint(poly([(29, 32), (34, 32), (31, 37)]), '#e0b83a', solid=True)   # open singing beak
    st.paint(rect(30, 34, 32, 34), '#c4503a', solid=True)
    st.eye(26, 27, socket=None)
    st.eye(34, 27, socket=None)
    st.paint(rect(22, 33, 24, 33) | rect(38, 33, 40, 33), BLUSH)
    # quaver song floating up
    st.paint(rect(48, 8, 48, 14) | disc(46.5, 14.5, 1.6), INK, solid=True)
    st.sparkle(10, 11)
    st.sparkle(53, 50, big=False)
    st.sparkle(10, 50, big=False)
    return key, st


PALS = [quaver, prism, foamcap, pondrock, ledge, bluebird]

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
