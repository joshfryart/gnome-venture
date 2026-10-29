"""Puzzle Pals: AURORA CAMP (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-aurc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_aurc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a snowy northern-lights camp. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-aurora-camp.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Tent Flap     tent orange            | a red pennant flag on a pole + door-flap triangle | looks up, smile
  2 Spark Hop     ember yellow           | a flame tuft on top + 2 rising embers             | laughing ^ ^ eyes, big grin
  3 Pine Watch    pine green             | snow-laden tiers + a snow cap                     | wide alert eyes, flat mouth
  4 Aurora Band   aurora mint            | wavy violet ribbon bands, star dots on the tabs   | straight gaze, cat mouth
  5 Peak Peep     slate mountain blue    | a snowy peak cap + snowflake                      | sleepy lids, 'o' mouth
  6 Nightcap Fox  fox rust               | whimsy curled fox, blue nightcap + pompom, glow   | closed lids, soft smile, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-aurora-camp'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-aurora-camp-fdffc1')

TENT = ('#d4702a', '#e8903a')
EMBER = ('#e8b030', '#f6d05a')
PINE = ('#2e5a3e', '#40744c')
AURORA = ('#4ec48a', '#78e0a8')
SLATE = ('#4a618a', '#62789e')
FOX = ('#a24a26', '#be6232')
FLAG = ('#c82a2a', '#e04a3a')
POLE = '#5a3a22'
SNOW = ('#eef4fa', '#c4d2e4')
VIOLET = ('#7a5cc0', '#9a7ad8')
CAP = ('#3a4e9a', '#5a6eba')
FLAME = ('#f06a2a', '#ffe08a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def ember(st, x, y):
    m = rect(x, y, x + 1, y + 1)
    st.paint(m, FLAME[0], solid=True)
    st.paint(rect(x, y, x, y), FLAME[1], solid=True)
    st.extra |= m


def flake(st, x, y):
    m = rect(x, y - 2, x, y + 2) | rect(x - 2, y, x + 2, y)
    st.paint(m, SNOW[0], solid=True)
    st.extra |= m


# ------------------------------------------------------------------ 1. Tent Flap: corner-TB round, common.
def tent_flap():
    key = 'pl-aurc-1'
    st = Sticker()
    core = (12, 22, 44, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(TENT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f6c070', skip=grow(holes, 3))
    door = poly([(28, 38), (21, 51), (35, 51)]) & body
    st.paint(door, '#7a3418')
    st.paint(poly([(28, 41), (25, 51), (31, 51)]) & body, '#f6d05a')
    pole = rect(15, 6, 16, 18)
    st.part(pole, POLE, d=1, contour=True)
    fl = poly([(17, 6), (28, 9), (17, 12)])
    st.part(fl, FLAG[0], d=1, contour=True)
    st.paint(fl & (CY < 9), FLAG[1])
    st.eye(17, 27, look=(0, -1))
    st.eye(31, 27, look=(0, -1))
    st.mouth('smile', 24, 34)
    st.paint(rect(14, 34, 16, 34) | rect(37, 34, 39, 34), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Spark Hop: edge-TTB peg, common.
def spark_hop():
    key = 'pl-aurc-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -6, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(EMBER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FLAME[0], skip=grow(holes, 3))
    fl = disc(32, 19, 5) | poly([(27, 18), (32, 6), (37, 18)]) | poly([(35, 17), (40, 10), (38, 19)])
    st.part(fl, FLAME[0], d=1, contour=True)
    st.paint(disc(32, 19, 2.5) | poly([(31, 18), (32, 12), (33, 18)]), FLAME[1])
    ember(st, 48, 12)
    ember(st, 53, 18)
    closed_up(st, 19, 32)
    closed_up(st, 33, 32)
    st.mouth('grin', 25, 39)
    st.paint(rect(17, 37, 19, 37) | rect(37, 37, 39, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Pine Watch: inner-TBTB round, common.
def pine_watch():
    key = 'pl-aurc-3'
    st = Sticker()
    core = (14, 18, 46, 44)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 33, list(PINE)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (24, 33, 41):                                   # pine tiers with snow edges
        tier = poly([(30, y - 7), (17, y), (43, y)]) & body
        st.paint(tier & ~shift(tier, 0, 1), '#1e4028')
        st.paint(rect(17, y, 43, y) & body & ((XX % 4) != 0), SNOW[0])
    st.part(disc(30, 12, 3.4) & body, SNOW[0], d=1, contour=True, rim=False)
    st.eye(21, 26)
    st.eye(34, 26)
    st.mouth('flat', 29, 35)
    return key, st


# ------------------------------------------------------------------ 4. Aurora Band: inner-TTTT peg, uncommon.
def aurora_band():
    key = 'pl-aurc-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(AURORA)), contour=True)
    import numpy as np
    for base in (22, 40):                                    # wavy violet ribbons, mirror-symmetric
        wave = np.abs(YY - (base + 2 * np.cos((XX - 31.5) / 3.0))) < 1.2
        st.paint(wave & body, VIOLET[0])
    st.stitch(body, col=VIOLET[1])                           # uncommon accent: aurora violet
    st.eye(24, 28)
    st.eye(35, 28)
    st.mouth('cat', 29, 35)
    for sx in (11, 52):
        st.paint(rect(sx, 32, sx, 32), SNOW[0])
    st.paint(rect(31, 9, 32, 10) | rect(31, 54, 32, 55), SNOW[0])
    return key, st


# ------------------------------------------------------------------ 5. Peak Peep: inner-BBBB round, uncommon.
def peak_peep():
    key = 'pl-aurc-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(SLATE)), contour=True)
    peak = poly([(31.5, 17), (20, 30), (24, 28), (28, 31), (31.5, 28), (35, 31), (39, 28), (43, 30)]) & body & ~grow(holes, 1)
    st.paint(peak, SNOW[0])
    st.paint(peak & (CX > 32), SNOW[1])
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=AURORA[1], skip=grow(holes, 3))      # uncommon accent: aurora green
    st.eye(23, 33, lid=2)
    st.eye(36, 33, lid=2)
    st.mouth('o', 30, 41)
    st.paint(rect(18, 40, 20, 40) | rect(43, 40, 45, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Nightcap Fox: whimsy-fox peg, rare.
def nightcap_fox():
    key = 'pl-aurc-6'
    st = Sticker()
    curl = ellipse(32, 39, 19, 10)
    head = disc(26, 32, 10)
    ears = poly([(17, 28), (18, 18), (24, 24)]) | poly([(35, 28), (34, 18), (28, 24)])
    tab = knob('s', 'peg', 32, 48, r=3.0)
    body = curl | head | ears | tab
    st.part(body, tex=fill(key, body, 10, 18, 44, list(FOX)), contour=True)
    tail = ellipse(41, 43, 9, 4.5) & curl
    st.paint(tail, FOX[1])
    st.paint(ellipse(48, 43, 3, 3.5) & curl, SNOW[0])          # tail tip
    st.paint(ellipse(26, 37, 6, 4) & head, SNOW[0])            # muzzle
    st.paint(rect(25, 35, 26, 35), UMBER)                      # nose
    cap = poly([(16, 22), (36, 22), (42, 12)]) & ~(ellipse(26, 32, 10, 9) & (CY > 23))
    st.part(cap, CAP[0], d=1, contour=True)
    st.paint(rect(16, 21, 36, 22), SNOW[0])
    st.part(disc(43, 12, 2.5), SNOW[0], d=1, contour=True)
    closed_down(st, 19, 28)
    closed_down(st, 29, 28)
    st.mouth('smile', 24, 39)
    st.paint(rect(17, 33, 19, 33) | rect(33, 33, 35, 33), BLUSH)
    st.sparkle(7, 9)
    st.sparkle(51, 24, big=False)
    st.sparkle(8, 46, big=False)
    return key, st


PALS = [tent_flap, spark_hop, pine_watch, aurora_band, peak_peep, nightcap_fox]

if __name__ == '__main__':
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
