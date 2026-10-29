"""Puzzle Pals: FAIRY-RING CLEARING (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wfri-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wfri.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: clearing sprites, keyhole knobs, night glow. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-fairy-ring-clearing.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Moon Spotlight       moonlight cream-yellow      | craters on its face + a soft spotlight beam fanning down         | serene closed ^ eyes, small smile
  2 Ribboned Gift        blush pink                  | a ribbon cross over its body and a big bow on the top tab         | bright wide eyes, open grin
  3 Mycelium Twinkles    soil umber                  | golden wavy mycelium threads + twinkle dots, one thread waving    | cheeky wink, smirk
  4 Redcap Congregation  night teal (+ sage stitch)  | four little glowing red caps, one on each tab, leaning in         | eyes glancing sideways, o (shh) mouth
  5 Tiny Door Ajar       stump bark brown (+ gold)   | a round green door with a crack of warm light, tiny knob          | peeking half-lids, cat mouth
  6 Dancing Pinkcap      hot rose cap + cream stem   | whimsy mushroom mid-twirl, white spots, holds a gift, glow (rare) | joyful ^ ^ eyes, grin, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-fairy-ring-clearing'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-fairy-ring-clearing-8e1394')

MOON = ('#e2d68e', '#f4ecb8')          # moonlight cream-yellow
BLUSHP = ('#e0a0b4', '#f0c2d0')        # blush pink gift
SOIL = ('#6e5038', '#8a684a')          # soil umber
TEAL = ('#314a59', '#4a6878')          # night teal
BARK = ('#7a5a3a', '#94744e')          # stump bark
ROSE = ('#c8508a', '#e07aa8')          # hot rose cap (rare)
STEM = ('#efe4cc', '#fbf4e2')
CAP = ('#d23a32', '#8e2420', '#f0786a')
GOLDT = ('#f0c84a', '#fff0a0')
DOOR = ('#5a8a4a', '#3a6030', '#7aaa62')
RIB = ('#7a6ad0', '#5040a0', '#a89af0')
BEAM = '#fff6c8'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def twinkle(st, x, y, col=GOLDT[1]):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        st.px[y + dy, x + dx] = hx(col if (dx, dy) == (0, 0) else GOLDT[0])
        st.extra[y + dy, x + dx] = True


def redcap(st, cx, cy, lean=0):
    capm = ellipse(cx + lean, cy - 1, 4.2, 2.8) & (CY <= cy)
    stem = rect(int(cx) - 1, int(cy), int(cx) + 1, int(cy) + 2)
    st.part(stem, STEM[0], d=1, contour=True)
    st.part(capm, CAP[0], d=1, contour=True)
    st.dots([(int(cx + lean) - 2, int(cy) - 2), (int(cx + lean) + 1, int(cy) - 3)], '#fff4e0')


# ------------------------------------------------------------------ 1. Moon Spotlight: corner-BB keyhole, common.
def moon_spotlight():
    key = 'pl-wfri-1'
    st = Sticker()
    # spotlight beam fanning down behind (drawn first, body covers its top)
    for a, b in (((22, 47), (18, 55)), ((31, 47), (31, 56)), ((40, 47), (44, 55))):
        st.paint(line([a, b], w=2), BEAM, solid=True)
    core = (14, 9, 50, 43)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 6, 3.0), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 14, 9, 37, list(MOON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#b8a860', skip=grow(holes, 3))
    for cx, cy, r in ((17, 17, 2.2), (41, 37, 2.6), (19, 37, 1.6)):
        st.paint(disc(cx, cy, r), '#cbbd74')
        st.paint(disc(cx - 0.6, cy - 0.6, r - 1), '#d8ca80')
    happy_eye(st, 21, 24)
    happy_eye(st, 34, 24)
    st.paint(rect(18, 30, 20, 30) | rect(40, 30, 42, 30), BLUSH)
    st.mouth('smile', 28, 31)
    return key, st


# ------------------------------------------------------------------ 2. Ribboned Gift: edge-TBB keyhole, common.
def ribboned_gift():
    key = 'pl-wfri-2'
    st = Sticker()
    core = (13, 18, 50, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 3, 3.0), w=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 13, 18, 38, list(BLUSHP)), contour=True)
    st.blank_shade(body, holes, width=1)
    rib = (rect(30, 18, 33, 50) | rect(13, 41, 50, 44)) & body
    st.part(rib, RIB[0], d=0, contour=False, shade=False)
    st.paint(rib & (XX == 30), RIB[2])
    st.paint(rib & (YY == 41), RIB[2])
    bow = ellipse(27, 9, 4, 2.6) | ellipse(36, 9, 4, 2.6)
    st.part(bow, RIB[0], d=1, contour=True)
    st.paint(disc(31.5, 9.5, 1.6), RIB[1], solid=True)
    st.paint(bow & ~shift(bow, 0, -1), RIB[2])
    st.eye(19, 25)
    st.eye(37, 25)
    st.paint(rect(17, 33, 19, 33) | rect(44, 33, 46, 33), BLUSH)
    st.mouth('grin', 23, 33)
    return key, st


# ------------------------------------------------------------------ 3. Mycelium Twinkles: inner-TBTB keyhole, common.
def mycelium_twinkles():
    key = 'pl-wfri-3'
    st = Sticker()
    core = (14, 14, 49, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 15, 36, list(SOIL)), contour=True)
    st.blank_shade(body, holes, width=1)
    thr = line([(16, 44), (21, 40), (26, 43), (31, 39), (36, 42), (41, 38), (46, 41)])
    thr |= line([(26, 43), (24, 48)]) | line([(36, 42), (38, 47)])
    st.paint(thr & body, GOLDT[0])
    wave = line([(46, 41), (49, 35), (50, 31)], w=2)                  # one thread waving hello out the side
    st.part(wave, GOLDT[0], d=0, contour=True, shade=False)
    st.paint(disc(50.5, 29.5, 1.7), GOLDT[1], solid=True)
    for x, y in ((20, 46), (33, 45), (44, 46), (9, 12), (55, 54)):
        twinkle(st, x, y)
    wink(st, 21, 26)
    st.eye(35, 25, look=(1, 0))
    st.mouth('smirk', 28, 34)
    return key, st


# ------------------------------------------------------------------ 4. Redcap Congregation: inner-TTTT double, uncommon.
def redcap_congregation():
    key = 'pl-wfri-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(TEAL)), contour=True)
    st.stitch(body, col='#90b090')                                # uncommon accent: clearing sage
    for cx, cy in ((32, 10), (32, 51), (11, 31), (52, 31)):
        st.paint(disc(cx, cy, 5.5) & ~st.sil, '#3a6a5a')
        redcap(st, cx, cy)
    st.eye(22, 27, look=(-1, 0))
    st.eye(37, 27, look=(1, 0))
    st.paint(rect(20, 34, 22, 34) | rect(41, 34, 43, 34), BLUSH)
    st.mouth('o', 30, 37)
    return key, st


# ------------------------------------------------------------------ 5. Tiny Door Ajar: inner-BBBB keyhole, uncommon.
def tiny_door_ajar():
    key = 'pl-wfri-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(BARK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLDT[0], skip=grow(holes, 3))            # uncommon accent: warm light gold
    door = (disc(32, 40, 7) & (YY <= 40)) | rect(25, 40, 39, 47)
    st.part(door, DOOR[0], d=1, contour=True)
    st.paint(door & (XX == 29), DOOR[1])
    st.paint(door & (XX == 35), DOOR[1])
    st.paint(rect(38, 34, 39, 47) & door, GOLDT[1])               # crack of light, ajar
    st.dots([(36, 42)], GOLDT[0])
    st.eye(20, 22, lid=2)
    st.eye(38, 22, lid=2)
    st.mouth('cat', 30, 29)
    return key, st


# ------------------------------------------------------------------ 6. Dancing Pinkcap: whimsy-toadstool keyhole, rare.
def dancing_pinkcap():
    key = 'pl-wfri-6'
    st = Sticker()
    cap = ellipse(31, 22, 19, 11) & (CY <= 26)
    cap |= ellipse(31, 26, 19, 3)
    stem = ellipse(31, 41, 10, 12) & (CY >= 27)
    tab = knob('e', 'keyhole', 31, 40.5, r=3.0)
    st.part(stem | tab, tex=fill(key, stem | tab, 21, 28, 24, list(STEM)), contour=True)
    st.part(cap, tex=fill(key, cap, 12, 11, 38, list(ROSE)), contour=True)
    for cx, cy, r in ((22, 17, 2.2), (31, 14, 2.6), (40, 18, 2.2), (17, 23, 1.4), (45, 23, 1.4)):
        st.paint(disc(cx, cy, r), '#fff4f0')
    # twirl feet + skirt swish marks
    st.part(ellipse(26, 53, 3, 1.8), '#b88a6a', d=1, contour=True)
    st.part(ellipse(37, 52, 3, 1.8), '#b88a6a', d=1, contour=True)
    for x, y in ((14, 46), (12, 42)):
        st.paint(line([(x, y), (x + 4, y + 2)]), BEAM, solid=True)
    # arm out holding a tiny gift
    arm = line([(22, 38), (15, 33)], w=2)
    st.part(arm, STEM[0], d=0, contour=True, shade=False)
    g = rect(9, 27, 15, 33)
    st.part(g, BLUSHP[0], d=1, contour=True)
    st.paint(rect(12, 27, 12, 33) | rect(9, 30, 15, 30), RIB[0])
    st.paint(disc(12, 26, 1.2), RIB[2], solid=True)
    happy_eye(st, 24, 32)
    happy_eye(st, 33, 32)
    st.paint(rect(22, 37, 24, 37) | rect(37, 37, 39, 37), BLUSH)
    st.mouth('grin', 28, 37)
    st.sparkle(5, 8)
    st.sparkle(54, 7, big=False)
    st.sparkle(52, 52, big=False)
    return key, st


PALS = [moon_spotlight, ribboned_gift, mycelium_twinkles, redcap_congregation, tiny_door_ajar, dancing_pinkcap]

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
