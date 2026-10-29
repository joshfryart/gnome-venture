"""Puzzle Pals: VOLCANO SPICE GARDENS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-volc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_volc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: dawn spice-island sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-volcano-spice-gardens.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Cinnamon Puff Bounce  smoke grey (+ cinnamon)   | puff cloud bumps on top, cinnamon swirl, bounce lines  | wide bright eyes, small smile
  2 Spiced Bun Snooze     bun golden brown          | glazed swirl bun top, clove dots, zzz                   | closed sleepy lines, flat mouth
  3 Podtree Wiggle        leaf green (+ red pods)   | round tree crown on top with red pod dots, wiggle marks | ^ ^ happy eyes, o mouth
  4 Pinkpetal Rows        petal pink (+ terrace grn)| stripes of pink flowers across the body                 | eyes glancing up, cat mouth
  5 Cratermouth Hearth    volcano mauve (+ lava)    | glowing orange crater in the middle, smoke wisp         | eyes glancing sideways, grin
  6 Sunhat Spicer         straw + beard brown       | whimsy gnome, cone straw hat, beard, spice sack, glow   | big eyes w/ blush, tooth grin
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-volcano-spice-gardens'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-volcano-spice-gardens-174315')

SMOKE = ('#9a94a4', '#c8c2cc')
CINN = '#9a4e22'
BUN = ('#b8763a', '#d8a060')
GLAZE = '#f8e8c8'
CLOVE = '#4a2a18'
TREE = ('#3e7a3a', '#62a050')
POD = '#d83a3a'
PETAL = ('#c47aa8', '#e4a8cc')
TERR = '#5a8a3a'
MAUVE = ('#6a5a80', '#8a7aa0')
LAVA = ('#f07a20', '#ffc84a')
STRAW = ('#d8b060', '#f0d488')
BEARD = ('#7a4a26', '#9a6438')
SKIN = '#f0c09a'
UMBERD = '#3a2214'
BLUSH = '#f0a0a0'
CREAM = '#fbf0dc'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def sleep_eye(st, x, y):
    st.paint(rect(x, y, x + 4, y) | rect(x + 1, y + 1, x + 3, y + 1), UMBER)


# 1. Cinnamon Puff Bounce: corner-BB keyhole, common.
def cinnamon_puff():
    key = 'pl-volc-1'
    st = Sticker()
    core = (12, 18, 50, 50)
    body, holes = piece_blanks(core, n='F', w='F', e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0))
    puff = disc(18, 18, 5) | disc(27, 15, 6) | disc(37, 17, 5)
    body = body | (puff & (YY >= 9))
    st.part(body, tex=fill(key, body, 12, 9, 42, list(SMOKE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(line([(38, 40), (41, 38), (43, 40), (41, 43), (37, 42)], w=1), CINN)
    st.dots([(6, 30), (6, 33), (7, 36)], SMOKE[1])
    st.eye(20, 27)
    st.eye(32, 27)
    st.mouth('smile', 25, 37)
    return key, st


# 2. Spiced Bun Snooze: edge-TTB keyhole, common.
def spiced_bun():
    key = 'pl-volc-2'
    st = Sticker()
    core = (15, 20, 46, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 10, 10, 46, list(BUN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(line([(20, 24), (30, 22), (39, 24)], w=1) & body, GLAZE)
    st.paint(line([(23, 44), (31, 46), (39, 44)], w=1) & body, GLAZE)
    st.dots([(18, 41), (41, 40), (36, 27)], CLOVE)
    st.dots([(50, 22), (52, 20), (54, 22), (52, 24)], '#ffffff')
    sleep_eye(st, 21, 31)
    sleep_eye(st, 34, 31)
    st.mouth('flat', 29, 38)
    return key, st


# 3. Podtree Wiggle: inner-TBTB keyhole, common.
def podtree_wiggle():
    key = 'pl-volc-3'
    st = Sticker()
    core = (14, 22, 49, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    crown = ellipse(31.5, 15, 13, 7)
    st.part(body | crown, tex=fill(key, body | crown, 14, 7, 44, list(TREE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.dots([(22, 13), (27, 10), (34, 11), (40, 14), (25, 17), (37, 18), (31, 15)], POD)
    st.paint(line([(9, 18), (11, 16)], w=1) | line([(54, 16), (56, 18)], w=1), TREE[1])
    happy_eye(st, 21, 28)
    happy_eye(st, 36, 28)
    st.mouth('o', 30, 37)
    return key, st


# 4. Pinkpetal Rows: inner-TTTT keyhole, uncommon.
def pinkpetal_rows():
    key = 'pl-volc-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(PETAL)), contour=True)
    for y in (21, 41):
        st.paint(rect(18, y, 45, y + 1) & body, TERR)
        for x in range(20, 45, 4):
            st.paint(rect(x, y - 1, x + 1, y - 1) & body, PETAL[1])
    st.stitch(body, col=TERR)
    st.eye(23, 28, look=(0, -1))
    st.eye(36, 28, look=(0, -1))
    st.mouth('cat', 29, 36)
    return key, st


# 5. Cratermouth Hearth: inner-BBBB double, uncommon.
def cratermouth():
    key = 'pl-volc-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(MAUVE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(ellipse(31.5, 40, 8, 3.5), LAVA[0], d=0, contour=True, shade=False)
    st.paint(ellipse(31.5, 40, 5, 1.5), LAVA[1])
    st.dots([(30, 34), (33, 32), (31, 30)], SMOKE[1])
    st.eye(21, 21, look=(1, 0))
    st.eye(37, 21, look=(-1, 0))
    st.mouth('grin', 29, 28)
    return key, st


# 6. Sunhat Spicer: whimsy-spicegnome keyhole, rare.
def sunhat_spicer():
    key = 'pl-volc-6'
    st = Sticker()
    hat = poly([(14, 24), (31.5, 10), (49, 24)])
    face = ellipse(31.5, 28, 10, 5)
    beard = poly([(21, 28), (42, 28), (36, 42), (27, 42)])
    torso = ellipse(31.5, 42, 10, 5)
    tab = knob('s', 'keyhole', 31.5, 46, r=3.0)
    sil = torso | tab
    st.part(sil, tex=fill(key, sil, 20, 36, 24, list(TREE)), contour=True)
    st.part(face, SKIN, d=0, contour=True, shade=False)
    st.part(beard, tex=fill(key, beard, 20, 26, 22, list(BEARD)), contour=True)
    st.part(hat, tex=fill(key, hat, 12, 8, 40, list(STRAW)), contour=True)
    st.paint(line([(19, 21), (44, 21)], w=1) & hat, BEARD[0])
    st.part(ellipse(47, 42, 5, 5), '#a06838', d=0, contour=True, shade=False)
    st.dots([(46, 38), (48, 39), (47, 37)], POD)
    st.eye(26, 24)
    st.eye(35, 24)
    st.paint(rect(22, 27, 23, 27) | rect(40, 27, 41, 27), BLUSH)
    st.mouth('tooth', 29, 31)
    st.sparkle(9, 12)
    st.sparkle(54, 30, big=False)
    st.sparkle(10, 44, big=False)
    return key, st


PALS = [cinnamon_puff, spiced_bun, podtree_wiggle, pinkpetal_rows, cratermouth, sunhat_spicer]

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
