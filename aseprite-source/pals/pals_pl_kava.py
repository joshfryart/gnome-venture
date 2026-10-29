"""Puzzle Pals: KAVA CIRCLE (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-kava-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_kava.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of an Oceania evening kava circle. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy, feather); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-kava-circle.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Sliver Rise     dusk violet sky        | a cream crescent moon on top + 2 star twinkles     | dreamy, looks up, tiny smile
  2 Palm Eavesdrop  palm green             | a palm crown (fronds) + a falling leaf             | laughing ^ ^ eyes, big grin
  3 Quiet Sipper    gnome-hat red          | a white beard + a tiny coconut cup held up         | sleepy lids, 'o' sip
  4 Dome Shelter    thatch straw gold      | straw fringe rows, a glowing lamp (dark accent)    | content side glance, smile
  5 Shared Cup      kava khaki (bowl seen from above) | a coconut half-shell cup floating, ripples | wide round eyes, cat mouth
  6 Tanoa Buddy     carved teak orange     | whimsy tanoa bowl, four stubby legs, kava top, glow | sleepy closed lids, soft smile, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-kava-circle'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-kava-circle-fb178e')

DUSK = ('#5e5890', '#7a72aa')
PALM = ('#3e7a3c', '#58964a')
HAT = ('#b8382c', '#d4503a')
STRAW = ('#c49a48', '#dcb662')
KAVA = ('#9c8c6a', '#b8a882')
TEAK = ('#b0602a', '#c87a3a')
MOON = ('#f4e6a8', '#fff8d8')
FROND = ('#2e6a34', '#4e9a44', '#8acc6a', '#1e4a24')
TRUNK = ('#8a6038', '#6a4428')
BEARD = ('#f2ece0', '#cfc6b4')
SHELL = ('#6a4426', '#4a2c18', '#8e6038')
LAMP = ('#f8c84a', '#fff0a8', '#3a2a5a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def twinkle(st, x, y):
    m = rect(x, y - 1, x, y + 1) | rect(x - 1, y, x + 1, y)
    st.paint(m, MOON[1], solid=True)
    st.extra |= m


def crescent(st, cx, cy, r):
    m = disc(cx, cy, r) & ~disc(cx + r * 0.55, cy - r * 0.35, r * 0.85)
    st.part(m, MOON[0], d=1, contour=True)
    st.paint(m & (CX < cx - r * 0.4), MOON[1])
    return m


def frond(st, x, y, ang, L):
    a = math.radians(ang)
    pts = [(x + i * math.cos(a), y + i * math.sin(a) + 0.04 * i * i) for i in range(L)]
    m = blank()
    for i, (px, py) in enumerate(pts):
        m |= disc(px, py, 2.2 * (1 - i / L) + 0.8)
    st.part(m, FROND[1], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1), FROND[2])
    return m


def leaf(st, x, y):
    m = ellipse(x, y, 3, 1.5)
    st.part(m, FROND[1], d=1, contour=True)
    st.paint(rect(x - 2, y, x + 2, y), FROND[0])
    st.extra |= grow(m, 1)


def coco_cup(st, cx, cy, r):
    m = disc(cx, cy, r) & (CY >= cy)
    st.part(m, SHELL[0], d=1, contour=True)
    st.paint(rect(int(cx - r + 1), int(cy), int(cx + r - 1), int(cy)), KAVA[1])
    st.paint(m & ((XX + YY) % 3 == 0) & (CY > cy + 1), SHELL[2])
    return m


def ripple(st, cx, cy, rx):
    m = ellipse(cx, cy, rx, 2.0) & ~ellipse(cx, cy - 0.5, rx - 1.5, 1.2)
    st.paint(m, KAVA[1])


# ------------------------------------------------------------------ 1. Sliver Rise: corner-TB round, common.
def sliver_rise():
    key = 'pl-kava-1'
    st = Sticker()
    core = (12, 22, 44, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(DUSK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8a0d4', skip=grow(holes, 3))
    crescent(st, 18, 13, 7)
    twinkle(st, 41, 8)
    twinkle(st, 52, 16)
    st.eye(18, 32, look=(0, -1))
    st.eye(31, 32, look=(0, -1))
    st.mouth('smile', 23, 41)
    st.paint(rect(14, 39, 16, 39) | rect(37, 39, 39, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Palm Eavesdrop: edge-TTB peg, common.
def palm_eavesdrop():
    key = 'pl-kava-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -6, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(PALM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FROND[2], skip=grow(holes, 3))
    for ang, L in ((-170, 14), (-125, 11), (-55, 11), (-10, 15)):
        frond(st, 30, 14, ang, L)
    st.part(disc(30, 15, 2.6), TRUNK[0], d=1, contour=True)
    leaf(st, 54, 54)
    closed_up(st, 19, 32)
    closed_up(st, 33, 32)
    st.mouth('grin', 25, 40)
    st.paint(rect(17, 37, 19, 37) | rect(37, 37, 39, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Quiet Sipper: inner-TBTB round, common.
def quiet_sipper():
    key = 'pl-kava-3'
    st = Sticker()
    core = (14, 18, 46, 44)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 33, list(HAT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f2c0a0', skip=grow(holes, 3))
    beard = ellipse(30, 40, 11, 6) & (CY > 35)
    st.part(beard & body, BEARD[0], d=1, contour=True, rim=False)
    st.paint(beard & body & ((XX + YY) % 4 == 0), BEARD[1])
    st.eye(22, 28, lid=3)
    st.eye(34, 28, lid=3)
    st.mouth('o', 29, 35)
    coco_cup(st, 44, 40, 4)
    st.paint(rect(18, 33, 20, 33) | rect(39, 33, 41, 33), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Dome Shelter: inner-TTTT peg, uncommon.
def dome_shelter():
    key = 'pl-kava-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(STRAW)), contour=True)
    for y in (22, 26, 41):                                   # straw fringe rows
        st.paint(rect(19, y, 44, y) & body & ((XX % 3) == 0), '#8e6a2a')
    st.stitch(body, col=DUSK[1])                                # uncommon accent: evening violet
    st.eye(25, 30, look=(1, 0))
    st.eye(37, 30, look=(1, 0))
    st.mouth('smile', 29, 36)
    for lx in (11, 52):
        st.paint(disc(lx, 32.5, 1.6), LAMP[1], solid=True)
    st.paint(rect(31, 54, 32, 55), LAMP[0], solid=True)
    st.paint(rect(31, 9, 32, 10), LAMP[0], solid=True)
    return key, st


# ------------------------------------------------------------------ 5. Shared Cup: inner-BBBB round, uncommon.
def shared_cup():
    key = 'pl-kava-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(KAVA)), contour=True)
    rim = body & ~shrink(body, 3)
    st.paint(rim, TEAK[0])
    st.paint(rim & (CY < 31), TEAK[1])
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=HAT[1], skip=grow(holes, 3))          # uncommon accent: gnome-hat red
    st.eye(23, 25, look=(0, 0))
    st.eye(37, 25, look=(0, 0))
    st.mouth('cat', 29, 32)
    ripple(st, 32, 43, 9)
    coco_cup(st, 32, 40, 4)
    st.paint(rect(18, 31, 20, 31) | rect(43, 31, 45, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Tanoa Buddy: whimsy-tanoa peg, rare.
def tanoa_buddy():
    key = 'pl-kava-6'
    st = Sticker()
    bowl = ellipse(32, 30, 22, 15) & (CY > 26)
    top = ellipse(32, 26, 22, 6)
    legs = blank()
    for lx in (16, 26, 38, 48):
        legs |= rect(lx - 2, 40, lx + 2, 50)
    tab = knob('s', 'peg', 32, 44, r=3.2)
    body = bowl | top | legs | tab
    st.part(body, tex=fill(key, body, 10, 20, 44, list(TEAK)), contour=True)
    kava = ellipse(32, 26, 19, 4.2)
    st.paint(kava, KAVA[1])
    st.paint(kava & (CY > 26.5), KAVA[0])
    st.paint(rect(14, 37, 50, 37) & bowl & ((XX % 4) < 2), '#7a3e1a')   # carved band
    st.paint(legs & ~bowl & (CX % 5 == 0), '#7a3e1a')
    closed_down(st, 23, 31)
    closed_down(st, 37, 31)
    st.mouth('smile', 30, 34)
    st.paint(rect(18, 34, 20, 34) | rect(45, 34, 47, 34), BLUSH)
    st.sparkle(8, 10)
    st.sparkle(52, 10, big=False)
    st.sparkle(32, 12, big=False)
    return key, st


PALS = [sliver_rise, palm_eavesdrop, quiet_sipper, dome_shelter, shared_cup, tanoa_buddy]

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
