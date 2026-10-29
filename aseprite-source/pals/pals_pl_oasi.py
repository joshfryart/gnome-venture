"""Puzzle Pals: THE OASIS THAT MOVES (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-oasi-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_oasi.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: bright-noon sprites, keyhole knobs, curious and sunny. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-the-oasis-that-moves.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Awning Flop          awning orange                | a striped orange awning flopped over its brow, a dark doorway on its belly | sleepy lids, flat mouth, yawn z
  2 Frond Fanfare        palm-frond green             | a fan of green palm fronds sprouting from the top knob                    | happy ^ ^ eyes, grin, cheeks
  3 Plum Window Blink    plum                         | a sandstone wall band with an arched plum window, shutters              | wink, smirk
  4 Goldbead Dates       date gold (+ sky blue stitch)| four bunches of round dates, one bunch on each tab, stalk dots          | wide eyes looking up, o mouth
  5 Rimmed Pool Saucer   pool blue (+ rim green)      | a round blue pool with a green rim on its belly, ripple                 | eyes looking aside, toothy grin
  6 Twinhump Stroller    camel tan                    | whimsy chibi bactrian, two humps, red saddle blanket, tiny palm on back, glow (rare) | calm half-lids, smile
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-oasis-that-moves'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-oasis-that-moves-dd37ca')

AWN = ('#d8742a', '#ee9440')          # awning orange
FROND = ('#3f8a3a', '#5aa84a')        # palm frond green
PLUM = ('#5a2e5a', '#764076')         # plum window
DATEG = ('#d8a42a', '#ecc04a')        # golden dates
POOL = ('#3a86b8', '#5aa6d4')         # pool blue
CAMEL = ('#b88a52', '#d0a46a')        # camel tan (rare)
LEAF = ('#4f9a3e', '#2f6a2a', '#7ac25a')
STONE = ('#e2c48a', '#c4a066', '#f2dcaa')
SKY = '#83c0dc'
RED = ('#c0302a', '#f0c040')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def frond(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=2)
    st.part(m, LEAF[0], d=0, contour=True, shade=False)
    st.paint(line([(x0, y0), (x1, y1)]), LEAF[2])
    return m


def dates(st, cx, cy):
    for dx, dy in ((-2, 0), (2, 0), (0, 2), (0, -2)):
        st.part(disc(cx + dx, cy + dy, 1.8), '#c07a1a', d=0, contour=True, shade=False)
    st.dots([(cx - 2, cy - 1), (cx + 2, cy - 1), (cx, cy - 3)], '#f8d870')
    st.dots([(cx, cy)], '#7a4a1a')


# ------------------------------------------------------------------ 1. Awning Flop: corner-BB keyhole, common.
def awning_flop():
    key = 'pl-oasi-1'
    st = Sticker()
    core = (12, 16, 49, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', -4, 3.0), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 16, 38, list(AWN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8a4418', skip=grow(holes, 3))
    aw = poly([(8, 22), (48, 22), (52, 31), (6, 31)])
    st.part(aw, '#f4ece0', d=1, contour=True)
    st.paint(aw & ((XX // 4) % 2 == 0), '#e05a24')
    st.paint(aw & (YY == 31) & (XX % 4 == 1), UMBER)
    door = disc(30, 42, 5) | rect(25, 42, 35, 49)
    st.part(door & (CY > 37), '#3a2a24', d=0, contour=True, shade=False)
    st.eye(16, 33, lid=2)
    st.eye(38, 33, lid=2)
    st.mouth('flat', 29, 40)
    st.sprite(['ZZZ', '.Z.', 'ZZZ'], 52, 12, {'Z': CREAM}, solid=True)
    return key, st


# ------------------------------------------------------------------ 2. Frond Fanfare: edge-TBB keyhole, common.
def frond_fanfare():
    key = 'pl-oasi-2'
    st = Sticker()
    core = (14, 24, 49, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 22, 36, list(FROND)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#1f4a1a', skip=grow(holes, 3))
    for x1, y1 in ((10, 15), (17, 9), (31.5, 6), (46, 9), (53, 15)):
        frond(st, 31.5, 18, x1, y1)
    happy_eye(st, 20, 32)
    happy_eye(st, 38, 32)
    st.paint(disc(18, 39, 2) | disc(46, 39, 2), BLUSH)
    st.mouth('grin', 29, 40)
    return key, st


# ------------------------------------------------------------------ 3. Plum Window Blink: inner-TBTB keyhole, common.
def plum_window_blink():
    key = 'pl-oasi-3'
    st = Sticker()
    core = (17, 16, 46, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 12, 40, list(PLUM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c890c8', skip=grow(holes, 3))
    band = rect(15, 33, 48, 46) & body
    st.paint(band, STONE[0])
    st.paint(band & ((YY - 33) % 4 == 3), STONE[1])
    win = disc(32, 38, 4) | rect(28, 38, 36, 45)
    st.part(win, '#3a1838', d=0, contour=True, shade=False)
    st.paint(rect(24, 38, 26, 45) | rect(38, 38, 40, 45), '#8a5a2a')
    wink(st, 20, 22)
    st.eye(36, 21, look=(-1, 0))
    st.mouth('smirk', 27, 29)
    return key, st


# ------------------------------------------------------------------ 4. Goldbead Dates: inner-TTTT keyhole, uncommon.
def goldbead_dates():
    key = 'pl-oasi-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 18, 18, 28, list(DATEG)), contour=True)
    st.stitch(body, col=SKY)                                    # uncommon accent: noon sky blue
    for cx, cy in ((31.5, 11), (31.5, 52), (11, 31.5), (52, 31.5)):
        dates(st, int(cx), int(cy))
    st.eye(23, 25, look=(0, -1))
    st.eye(36, 25, look=(0, -1))
    st.mouth('o', 30, 35)
    return key, st


# ------------------------------------------------------------------ 5. Rimmed Pool Saucer: inner-BBBB double, uncommon.
def rimmed_pool_saucer():
    key = 'pl-oasi-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(POOL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LEAF[0], skip=grow(holes, 3))            # uncommon accent: rim green
    rim = ellipse(31.5, 39, 13, 7)
    st.part(rim, LEAF[0], d=1, contour=True)
    st.paint(ellipse(31.5, 39, 10, 4.5), '#2a6aa8')
    st.paint(ellipse(31.5, 39, 10, 4.5) & (YY == 38) & (XX % 3 == 0), '#bfe4f4')
    st.eye(20, 21, look=(1, 0))
    st.eye(39, 21, look=(1, 0))
    st.mouth('tooth', 29, 29)
    return key, st


# ------------------------------------------------------------------ 6. Twinhump Stroller: whimsy-bactrian keyhole, rare.
def twinhump_stroller():
    key = 'pl-oasi-6'
    st = Sticker()
    torso = ellipse(30, 40, 15, 8)
    humps = disc(23, 31, 5.5) | disc(36, 31, 5.5)
    neck = line([(42, 38), (47, 26)], w=4)
    head = ellipse(48, 22, 6, 5)
    legs = rect(18, 46, 21, 54) | rect(25, 46, 28, 54) | rect(33, 46, 36, 54) | rect(40, 46, 43, 54)
    tab = knob('w', 'keyhole', 40, 15.5, r=3.0)
    body = torso | humps | neck | head | legs | tab
    st.part(body, tex=fill(key, body, 10, 12, 44, list(CAMEL)), contour=True)
    bl = ellipse(30, 38, 9, 6) & ~humps & torso
    st.paint(bl, RED[0])
    st.paint(bl & (YY == 41) & (XX % 2 == 0), RED[1])
    st.paint(legs & (YY >= 53), '#6a4a2a')
    for x1, y1 in ((24, 18), (29, 16), (34, 18)):                  # a tiny palm riding the gap between humps
        st.paint(line([(29, 26), (x1, y1)]), LEAF[0])
    st.paint(line([(29, 27), (29, 22)]), '#8a5a2a')
    st.eye(45, 19, lid=1, socket=None)
    st.mouth('smile', 47, 25)
    st.sparkle(4, 6)
    st.sparkle(54, 40, big=False)
    st.sparkle(8, 26, big=False)
    return key, st


PALS = [awning_flop, frond_fanfare, plum_window_blink, goldbead_dates, rimmed_pool_saucer, twinhump_stroller]

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
