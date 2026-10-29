"""Puzzle Pals: COFFEE CEREMONY HUT (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wcof-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wcof.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: night-hut sprites, keyhole knobs, warm and curious. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-coffee-ceremony-hut.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Thatchtop Bauble     thatch straw gold            | a little thatched cone roof hat with the gold ball on top, moon nick | looks up wide-eyed, o mouth
  2 Bowl of Puffs        popcorn cream                | a red-rimmed bowl heaped with white puffs, one puff in hand          | happy ^ ^ eyes, munch mouth, cheeks
  3 Grumbling Coals      clay terracotta              | a round black pot on its head, a bed of glowing coals at its foot, note | sleepy lids, cat-mouth hum, brows down
  4 Cuppa Constellation  night indigo (+ gold stitch) | four tiny white coffee cups, one on each tab, star dots                | wide eyes looking aside, grin
  5 Doorway Aglow        hut-door orange (+ indigo)   | a round arched glowing door with a lamp-lit window on its belly      | cheeky wink, toothy grin
  6 Headband Pourer      coffee-bean brown            | whimsy seated host, striped headband, jebena pouring into 3 cups, glow (rare) | calm half-lids, soft smile
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-coffee-ceremony-hut'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-coffee-ceremony-hut-e84613')

STRAW = ('#c49a52', '#dcb872')        # thatch straw
PUFFC = ('#d8d0bc', '#ece6d4')        # popcorn cream
CLAY = ('#9a4a34', '#b8604a')         # clay terracotta
NIGHT = ('#433a7a', '#5a509a')        # night indigo
DOOR = ('#e0883a', '#f0a65a')         # hut door orange
BEAN = ('#6a3e24', '#86522e')         # coffee bean brown (rare)
THATCH = ('#b08848', '#8a6630', '#d8b468')
POT = ('#3a3236', '#26202a', '#5a5058')
COAL = ('#e0542a', '#a8301a', '#ffb050')
CUP = ('#f4f0e6', '#c8c0b0', '#6a3e24')
RUG = ('#c0302a', '#f0c040')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def cup(st, cx, by):
    """Tiny handle-less coffee cup (sini): white, dark coffee top line."""
    m = rect(cx - 3, by - 4, cx + 2, by) & ~(rect(cx - 3, by, cx - 3, by) | rect(cx + 2, by, cx + 2, by))
    st.part(m, CUP[0], d=1, contour=True)
    st.paint(rect(cx - 2, by - 4, cx + 1, by - 4), CUP[2])
    st.paint(rect(cx - 2, by - 1, cx + 1, by - 1), CUP[1])
    return m


def puff(st, cx, cy, r=2.2):
    m = disc(cx, cy, r)
    st.part(m, '#faf6ec', d=0, contour=True, shade=False)
    st.paint(m & ~shift(m, -1, -1), '#d8d0bc')
    return m


def note(st, x, y, col=CREAM):
    st.sprite(['.CC', '.C.', '.C.', 'CC.', 'CC.'], x, y, {'C': col}, solid=True)


# ------------------------------------------------------------------ 1. Thatchtop Bauble: corner-TB keyhole, common.
def thatchtop_bauble():
    key = 'pl-wcof-1'
    st = Sticker()
    core = (12, 24, 47, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -6, 3.6), e=('B', 'keyhole', 2, 3.0))
    st.part(body, tex=fill(key, body, 12, 24, 36, list(STRAW)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#7a5428', skip=grow(holes, 3))
    roof = poly([(26, 29), (38, 12), (50, 29)])
    st.part(roof, THATCH[0], d=1, contour=True)
    st.paint(roof & ((YY % 3) == 0), THATCH[1])
    st.paint(roof & ((XX + YY) % 5 == 0) & (CX < 38), THATCH[2])
    st.part(disc(38, 10, 3.0), GOLD, d=1, contour=True)
    st.dots([(37, 9)], GOLD_L)
    st.eye(17, 35, look=(1, -1))
    st.eye(30, 35, look=(0, -1))
    st.mouth('o', 25, 43)
    st.paint(rect(15, 42, 17, 42) | rect(35, 42, 37, 42), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Bowl of Puffs: edge-TTB keyhole, common.
def bowl_of_puffs():
    key = 'pl-wcof-2'
    st = Sticker()
    core = (16, 14, 47, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'keyhole', 0, 3.0), e=('T', 'keyhole', -4, 3.4), w=('T', 'keyhole', -4, 3.4))
    st.part(body, tex=fill(key, body, 14, 14, 36, list(PUFFC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a89878', skip=grow(holes, 3))
    for cx, cy in ((22, 40), (27, 37.5), (32, 36.5), (37, 37.5), (42, 40)):
        puff(st, cx, cy, 2.6)
    bw = ellipse(32, 44, 16, 9) & (CY >= 42)
    st.part(bw, '#8a5a34', d=1, contour=True)
    st.paint(bw & (YY == 44), RUG[0])
    st.paint(bw & (YY == 46) & (XX % 2 == 0), RUG[1])
    happy_eye(st, 20, 23)
    happy_eye(st, 38, 23)
    st.paint(disc(18, 30, 2) | disc(46, 30, 2), BLUSH)
    st.sprite(['UUUU', 'URRU', '.UU.'], 30, 28, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Grumbling Coals: inner-TBBB keyhole, common.
def grumbling_coals():
    key = 'pl-wcof-3'
    st = Sticker()
    core = (13, 19, 50, 50)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 2, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 2, 3.0))
    st.part(body, tex=fill(key, body, 13, 19, 38, list(CLAY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0c890', skip=grow(holes, 3))
    pot = ellipse(32, 13, 9, 6)
    st.part(pot, POT[0], d=1, contour=True)
    st.paint(pot & (CY < 9), POT[2])
    st.paint(rect(28, 6, 36, 7), POT[1])
    for cx in (12, 18, 46, 52):
        c = disc(cx, 53.5, 2.4)
        st.part(c, COAL[0], d=0, contour=True, shade=False)
        st.dots([(cx - 1, 52)], COAL[2])
    note(st, 50, 8)
    st.eye(21, 29, lid=2)
    st.eye(37, 29, lid=2)
    st.paint(line([(20, 26), (25, 27)]) | line([(37, 27), (42, 26)]), UMBER)
    st.mouth('cat', 29, 38)
    return key, st


# ------------------------------------------------------------------ 4. Cuppa Constellation: inner-TTTT double, uncommon.
def cuppa_constellation():
    key = 'pl-wcof-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(NIGHT)), contour=True)
    st.stitch(body, col=GOLD)                                  # uncommon accent: the hut's lamp gold
    for cx, by in ((32, 14), (32, 55), (12, 35), (52, 35)):
        cup(st, cx, by)
    st.dots([(21, 21), (42, 21), (21, 42), (42, 42)], GOLD_L)
    st.eye(23, 26, look=(1, 0))
    st.eye(36, 26, look=(1, 0))
    st.mouth('grin', 30, 35)
    return key, st


# ------------------------------------------------------------------ 5. Doorway Aglow: inner-BBBB keyhole, uncommon.
def doorway_aglow():
    key = 'pl-wcof-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(DOOR)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=NIGHT[1], skip=grow(holes, 3))         # uncommon accent: night indigo
    door = (disc(32, 37, 8) | rect(24, 37, 39, 47))
    st.part(door, '#f6c070', d=1, contour=True)
    st.paint(shrink(door, 2), '#ffd890')
    st.paint(rect(30, 35, 33, 39), '#c86a2a')
    st.paint(rect(31, 35, 32, 39), '#ffefb0')
    st.dots([(36, 42)], UMBER)
    wink(st, 21, 20)
    st.eye(37, 19)
    st.mouth('tooth', 29, 27)
    st.paint(rect(17, 27, 19, 27) | rect(44, 27, 46, 27), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Headband Pourer: whimsy-host keyhole, rare.
def headband_pourer():
    key = 'pl-wcof-6'
    st = Sticker()
    dress = ellipse(30, 46, 15, 9)
    head = disc(28, 24, 10)
    tab = knob('w', 'keyhole', 46, 15.5, r=3.0)
    body = head | dress | tab
    st.part(body, tex=fill(key, body, 13, 10, 38, list(BEAN)), contour=True)
    st.paint(dress & ~head & (CY > 40), '#f2ece0')                       # white netela dress
    st.paint(dress & (YY == 50) & (XX % 2 == 0), RUG[0])
    st.paint(dress & (YY == 51) & (XX % 2 == 1), RUG[1])
    hb = head & (YY >= 16) & (YY <= 18)                                  # striped headband
    st.paint(hb, GOLD)
    st.paint(hb & (YY == 17) & (XX % 3 == 0), RUG[0])
    st.paint(hb & (YY == 17) & (XX % 3 == 1), '#2a6a3a')
    # jebena (round clay pot with long neck), pouring
    jb = disc(41, 33, 5) | line([(41, 29), (45, 22)], w=2)
    st.part(jb, POT[0], d=1, contour=True)
    st.paint(disc(40, 32, 2) & jb, POT[2])
    st.part(disc(35, 36, 2.6), BEAN[1], d=1, contour=True)                # the steady hand
    st.paint(line([(46, 21), (48, 24), (48, 45)]), '#2a1408', solid=True)  # the pour
    for cx in (42, 48, 54):
        cup(st, cx, 52 if cx == 48 else 50)
    st.eye(21, 22, lid=2, socket=None)
    st.eye(30, 22, lid=2, socket=None)
    st.mouth('smile', 25, 29)
    st.sparkle(5, 6)
    st.sparkle(52, 8, big=False)
    st.sparkle(6, 30, big=False)
    return key, st


PALS = [thatchtop_bauble, bowl_of_puffs, grumbling_coals, cuppa_constellation, doorway_aglow, headband_pourer]

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
