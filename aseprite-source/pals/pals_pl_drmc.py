"""Puzzle Pals: DRUM CIRCLE MARKET (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-drmc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_drmc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a West/Central African night market, drum circle round a fire, groundnut stew on the boil.
kit_lair parts used only as building blocks (PlacePic, rows, cell_fill, calm_tones, tidy, flame); everything else drawn here.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/haven-drum-circle-market.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Groundnut Bubble  cast-iron pot charcoal     | pot rim band, stew bubbles popping on top, a groundnut          | sleepy content lids, cat :3
  2 Moon Croon        crescent-moon pale yellow  | a little crescent moon on its head, music notes, a star          | singing: closed ^ eyes, open o song
  3 Clap Along        gnome-hat red              | a tall red gnome hat, two clapping hands + clap marks           | cheeky wink, tooth grin
  4 Acacia Parasol    acacia leaf green (+bark)  | a flat wide acacia crown on top, a trunk stripe, shade dots      | smug closed eyes, smirk
  5 Firelit Circle    night indigo (+fire amber) | a little campfire in its middle ringed by 4 tiny gnome hats     | shy look-down eyes, blush, small smile
  6 Hut Dweller       mud-hut clay brown (rare)  | whimsy round hut: thatched cone roof, glowing doorway             | big welcoming grin, happy round eyes
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-drum-circle-market'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-drum-circle-market-1b1e7c')

IRON = ('#3a3a46', '#5a5a68')          # cast-iron pot charcoal
MOON = ('#e2cc78', '#f6e8a8')          # crescent moon pale yellow
HATR = ('#a8342a', '#c85440')          # gnome-hat red
ACAC = ('#3f6e4a', '#5a8e58')          # acacia leaf green
NIGHT = ('#322b64', '#4a4288')         # night indigo
MUD = ('#845135', '#a8704a')           # mud hut clay brown (rare)
STEW = ('#c87a30', '#e8a050', '#f6cc80')
NUT = ('#c89a5a', '#8a6236', '#e8c488')
THATCH = ('#d8a848', '#a87828', '#f2d27a', '#6a4a1a')
SKIN = ('#e8b088', '#b87a58')
TRUNK = ('#6a4a3a', '#4a3028')
FIRE = ('#e0501f', '#f08a24', '#f5cf6a', '#fff3c8')
LAMP = ('#f5cf6a', '#f08a24', '#fff3c8')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def stew_bubble(st, cx, cy, r):
    m = disc(cx, cy, r)
    st.part(m, STEW[0], d=1, contour=True)
    st.paint(disc(cx - r * 0.35, cy - r * 0.35, max(0.8, r * 0.4)), STEW[2])
    return m


def groundnut(st, cx, cy):
    m = ellipse(cx - 1.5, cy, 2.4, 2.2) | ellipse(cx + 1.8, cy, 2.4, 2.2)
    st.part(m, NUT[0], d=1, contour=True)
    st.paint(rect(int(cx), int(cy) - 1, int(cx), int(cy) + 1) & m, NUT[1])
    st.dots([(int(cx - 2), int(cy - 1)), (int(cx + 2), int(cy - 1))], NUT[2])
    return m


def note(st, x, y, col=CREAM):
    rows_ = ['..CC', '..CC', '..C.', '..C.', 'CCC.', 'CCC.']
    st.sprite(rows_, x, y, {'C': col}, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch == 'C':
                st.extra[y + j, x + i] = True


def crescent(st, cx, cy, r):
    m = disc(cx, cy, r) & ~disc(cx + r * 0.55, cy - r * 0.25, r * 0.85)
    st.part(m, '#f2dc80', d=1, contour=True)
    st.paint(m & (CX < cx - r * 0.4), '#fff3c8')
    return m


def gnome_hat(st, cx, by, w, h, col=HATR):
    m = poly([(cx - w, by), (cx, by - h), (cx + w, by)])
    st.part(m, '#c03a2c', d=1, contour=True)
    st.paint(rect(int(cx - w), int(by) - 1, int(cx + w), int(by)) & grow(m, 1), CREAM, solid=True)
    return m


def hand(st, cx, cy):
    m = ellipse(cx, cy, 2.6, 3.4)
    st.part(m, SKIN[0], d=1, contour=True)
    st.paint(m & (CX > cx + 0.8), SKIN[1])
    return m


def clap_marks(st, x, y):
    for a, b in (((x, y), (x - 2, y - 3)), ((x + 3, y - 1), (x + 3, y - 4)), ((x + 6, y), (x + 8, y - 3))):
        m = line([a, b])
        st.paint(m, CREAM)
        st.extra |= m


def acacia_crown(st, cx, cy, rx, ry):
    m = ellipse(cx, cy, rx, ry) | ellipse(cx - rx * 0.5, cy - 1.5, rx * 0.45, ry) | ellipse(cx + rx * 0.5, cy - 1.5, rx * 0.45, ry)
    st.part(m, '#4a7e3a', d=1, contour=True)
    st.paint(m & (CY < cy - ry * 0.3), '#7aae5a')
    st.paint(m & ((XX * 3 + YY) % 7 == 0) & shrink(m, 1), '#2f5a2e')
    return m


def campfire(st, cx, by):
    logs = line([(cx - 5, by), (cx + 5, by - 2)], w=2) | line([(cx - 5, by - 2), (cx + 5, by)], w=2)
    st.part(logs, TRUNK[0], d=1, contour=True)
    fl = poly([(cx - 3.5, by - 1), (cx - 2, by - 6), (cx - 0.5, by - 4), (cx, by - 9), (cx + 1.5, by - 5), (cx + 2.5, by - 7), (cx + 3.5, by - 1)])
    st.paint(fl, FIRE[0], solid=True)
    st.paint(shrink(fl, 1), FIRE[1])
    st.paint(shrink(fl, 2), FIRE[2])
    st.paint(shrink(fl, 1) & (CY > by - 3) & (np.abs(CX - cx) < 1.2), FIRE[3])


def thatch_roof(st, cx, by, w, h):
    m = poly([(cx - w, by), (cx, by - h), (cx + w, by)]) | ellipse(cx, by, w, 2.2)
    st.part(m, THATCH[0], d=1, contour=True)
    st.paint(m & ((XX - 2 * YY) % 4 == 0) & shrink(m, 1), THATCH[1])
    st.paint(m & (CX < cx - 1) & (CY < by - h * 0.4) & shrink(m, 1), THATCH[2])
    st.paint(rect(int(cx) - 1, int(by - h) - 2, int(cx), int(by - h)), THATCH[3], solid=True)
    return m


# ------------------------------------------------------------------ 1. Groundnut Bubble: corner-TB round, common.
def groundnut_bubble():
    key = 'pl-drmc-1'
    st = Sticker()
    core = (12, 24, 45, 49)
    body, holes = piece_blanks(core, n=('T', 'round', -6, 3.6), e=('B', 'round', 1, 3.0))
    body = body & ~(rect(0, 46, 63, 63) & ~ellipse(28.5, 44, 17.5, 6.5))
    st.part(body, tex=fill(key, body, 12, 24, 34, list(IRON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(12, 29, 45, 30) & body & ~grow(holes, 1), '#22222c')
    st.stitch(body, col='#c8a070', skip=grow(holes, 3))
    stew_bubble(st, 34, 20, 3.2)
    stew_bubble(st, 41, 14, 2.2)
    stew_bubble(st, 46, 9, 1.6)
    groundnut(st, 50, 40)
    st.eye(18, 35, lid=2)
    st.eye(31, 35, lid=2)
    st.paint(rect(15, 42, 17, 42) | rect(37, 42, 39, 42), BLUSH)
    st.mouth('cat', 25, 42)
    return key, st


# ------------------------------------------------------------------ 2. Moon Croon: edge-TTB peg, common.
def moon_croon():
    key = 'pl-drmc-2'
    st = Sticker()
    core = (15, 24, 44, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.2), e=('B', 'peg', -2, 2.8), w=('T', 'peg', -2, 3.2))
    st.part(body, tex=fill(key, body, 15, 24, 30, list(MOON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#b8943a', skip=grow(holes, 3))
    crescent(st, 32, 11, 4.5)
    closed_up(st, 19, 32)
    closed_up(st, 33, 32)
    st.sprite(['.UU.', 'URRU', 'URRU', '.UU.'], 27, 38, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(18, 37, 20, 37) | rect(37, 37, 39, 37), BLUSH)
    note(st, 50, 8)
    note(st, 45, 16)
    st.sparkle(6, 10, big=False)
    return key, st


# ------------------------------------------------------------------ 3. Clap Along: inner-TBTB round, common.
def clap_along():
    key = 'pl-drmc-3'
    st = Sticker()
    core = (16, 24, 44, 47)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.2), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.0), w=('B', 'round', 0, 2.8))
    body = body & (YY < 57)
    st.part(body, tex=fill(key, body, 16, 24, 29, list(HATR)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0c090', skip=grow(holes, 3))
    gnome_hat(st, 30, 22, 10, 16)
    hand(st, 48, 38)
    hand(st, 51, 37)
    clap_marks(st, 47, 30)
    wink(st, 20, 33)
    st.eye(33, 32, look=(1, 0))
    st.mouth('tooth', 26, 41)
    st.paint(rect(19, 40, 21, 40) | rect(38, 40, 40, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Acacia Parasol: inner-TTTT peg, uncommon.
def acacia_parasol():
    key = 'pl-drmc-4'
    st = Sticker()
    core = (20, 22, 43, 45)
    body = piece(core, n=('T', 'peg', 0, 3.2), e=('T', 'peg', 0, 3.2), s=('T', 'peg', 0, 3.2), w=('T', 'peg', 0, 3.2))
    st.part(body, tex=fill(key, body, 18, 20, 28, list(ACAC)), contour=True)
    st.stitch(body, col='#a8744a')                              # uncommon accent: acacia bark
    acacia_crown(st, 31.5, 12, 19, 4.2)
    st.paint(rect(31, 46, 32, 56) & body, TRUNK[0])
    closed_up(st, 23, 30)
    closed_up(st, 36, 30)
    st.mouth('smirk', 29, 37)
    st.paint(rect(22, 35, 24, 35) | rect(39, 35, 41, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Firelit Circle: inner-BBBB round, uncommon.
def firelit_circle():
    key = 'pl-drmc-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.2), e=('B', 'round', 0, 3.2), s=('B', 'round', 0, 3.2), w=('B', 'round', 0, 3.2))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(NIGHT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FIRE[1], skip=grow(holes, 3))          # uncommon accent: fire amber
    st.paint(ellipse(31.5, 44, 13, 5) & ~ellipse(31.5, 44, 10.5, 3.2), '#845135')
    campfire(st, 31.5, 46)
    for hx_, hy, c in ((19, 44, '#c03a2c'), (44, 44, '#d8a848'), (24, 49, '#3f6e4a'), (39, 49, '#e8e0d0')):
        st.sprite(['..C..', '.CCC.', 'CCCCC'], hx_ - 2, hy - 3, {'C': c}, solid=False)
    st.eye(20, 21, look=(0, 1))
    st.eye(38, 21, look=(0, 1))
    st.paint(rect(16, 29, 18, 29) | rect(45, 29, 47, 29), BLUSH)
    st.mouth('smile', 29, 30)
    return key, st


# ------------------------------------------------------------------ 6. Hut Dweller: whimsy-hut peg, rare.
def hut_dweller():
    key = 'pl-drmc-6'
    st = Sticker()
    wall = rect(16, 28, 47, 52) | ellipse(31.5, 52, 16, 3)
    tab = knob('e', 'peg', 41, 48, r=2.6)
    body = (wall | tab) & (YY < 56)
    st.part(body, tex=fill(key, body, 14, 22, 36, list(MUD)), contour=True)
    st.stitch(wall & (YY < 56), col='#e8c088')
    thatch_roof(st, 31.5, 29, 22, 19)
    door = (ellipse(31.5, 47, 4.5, 4.5) | rect(27, 47, 36, 53)) & (YY <= 53)
    st.paint(grow(door, 1), UMBER2, solid=True)
    st.paint(door, LAMP[1], solid=True)
    st.paint(shrink(door, 1), LAMP[0])
    st.paint(rect(30, 46, 31, 50), LAMP[2])
    st.eye(21, 33, look=(0, 0))
    st.eye(37, 33, look=(0, 0))
    st.mouth('grin', 29, 40)
    st.paint(rect(18, 40, 20, 40) | rect(43, 40, 45, 40), BLUSH)
    st.sparkle(5, 34)
    st.sparkle(54, 18, big=False)
    st.sparkle(8, 12, big=False)
    return key, st


PALS = [groundnut_bubble, moon_croon, clap_along, acacia_parasol, firelit_circle, hut_dweller]

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
