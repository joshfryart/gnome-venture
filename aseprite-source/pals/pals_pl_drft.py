"""Puzzle Pals: DRIFTWOOD TAVERN (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-drft-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_drft.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a Caribbean beach bar at sunset. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-driftwood-tavern.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Pan Ting         steel blue-grey        | a steel pan drum on top (dented bowl) + 2 music notes  | wide round eyes, 'o' ting
  2 Frond Nod        palm green             | a palm frond nodding over to the left + beat ticks     | laughing ^ ^ eyes, big grin
  3 Dusk Lap         sea-at-sunset blue     | a curling wave crest on top + half sun dipping behind   | sleepy lids, soft smile
  4 Thatch Ridge     thatch straw gold (+coconut brown) | straw fringe rows, coconut cups on the tabs | side glance, smirk
  5 Pink Porthole    porthole pink (+ sea teal)| a round glass window in its belly, the sea + glint | wink, cat mouth
  6 Pinkhat Drummer  driftwood tan (drum)   | whimsy chibi gnome: magenta pointed hat, beard, bongo, sticks, glow | closed happy eyes, grin
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-driftwood-tavern'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-driftwood-tavern-c9dacd')

STEEL = ('#7a8698', '#9aa6b6')
PALM = ('#3e7a3c', '#58964a')
SEA = ('#3a5a92', '#5a7ab2')
STRAW = ('#a8783a', '#c49452')
PINK = ('#d87aa6', '#eea0c2')
DRIFT = ('#b07a4a', '#c8955e')
CHROME = ('#c8d0dc', '#eef2f8', '#5a6474', '#3a4252')
FROND = ('#2e6a34', '#4e9a44', '#8acc6a', '#1e4a24')
FOAM = ('#e8f0f8', '#ffffff', '#a8c4e0')
SUN = ('#f4a040', '#f8d070')
COCO = ('#6a4426', '#4a2c18', '#8e6038')
GLASS = ('#3a9aa0', '#6ac4c0', '#ffffff')
HAT = ('#a83a7a', '#c8569a', '#7a2458')
BEARD = ('#f2ece0', '#cfc6b4')
SKIN = ('#f0c09a', '#d89a78')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def note(st, x, y, col=CREAM):
    """A tiny eighth note: head + stem + flag."""
    m = rect(x, y + 4, x + 1, y + 5) | rect(x + 1, y, x + 1, y + 4) | rect(x + 2, y, x + 3, y + 1)
    st.paint(m, col, solid=True)
    st.extra |= grow(m, 1)


def steel_pan(st, cx, cy):
    """The steel pan on its stand: shallow chrome bowl seen from the side with dented note dimples, two legs."""
    legs = line([(cx - 5, cy + 2), (cx - 8, cy + 8)]) | line([(cx + 5, cy + 2), (cx + 8, cy + 8)])
    st.paint(legs, CHROME[3], solid=True)
    st.extra |= legs
    bowl = ellipse(cx, cy, 10, 3.2) | (ellipse(cx, cy, 10, 5) & (CY > cy))
    st.part(bowl, CHROME[0], d=1, contour=True)
    top = ellipse(cx, cy - 0.5, 8.5, 2)
    st.paint(top, CHROME[2])
    for dx in (-4, 0, 4):
        st.paint(disc(cx + dx, cy - 0.5, 1.0), CHROME[1])
    st.paint(rect(int(cx - 7), int(cy + 2), int(cx - 5), int(cy + 2)), CHROME[1])
    return bowl


def frond(st, x, y, ang, L, bend=0.05):
    a = math.radians(ang)
    pts = [(x + i * math.cos(a), y + i * math.sin(a) + bend * i * i) for i in range(L)]
    m = blank()
    for i, (px, py) in enumerate(pts):
        m |= disc(px, py, 2.4 * (1 - i / L) + 0.8)
    st.part(m, FROND[1], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1), FROND[2])
    return m


def wave_crest(st, x0, x1, y):
    """A curling sunset wave along the top: blue swell, white foam lip curling right."""
    m = blank()
    for x in range(x0, x1):
        h = 3 + 2.5 * math.sin((x - x0) / (x1 - x0) * math.pi)
        m |= rect(x, int(y - h), x, y)
    curl = disc(x1 - 3, y - 5, 3.2) & ~disc(x1 - 2, y - 4, 1.6)
    m |= curl
    st.part(m, SEA[1], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), FOAM[0])
    st.paint(curl & (CY < y - 5), FOAM[1])
    return m


def half_sun(st, cx, cy, r):
    m = disc(cx, cy, r) & (CY < cy)
    st.part(m, SUN[0], d=1, contour=True)
    st.paint(m & (CY < cy - r * 0.5), SUN[1])
    return m


def coco_cup(st, cx, cy, r):
    m = disc(cx, cy, r) & (CY >= cy)
    st.part(m, COCO[0], d=1, contour=True)
    st.paint(rect(int(cx - r + 1), int(cy), int(cx + r - 1), int(cy)), CREAM)
    st.paint(m & ((XX + YY) % 3 == 0) & (CY > cy + 1), COCO[2])
    st.paint(line([(int(cx + 1), int(cy)), (int(cx + 2), int(cy - 3))]), '#f080a8', solid=True)
    return m


def porthole(st, cx, cy, r):
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 2)
    glass = disc(cx, cy, r - 2)
    st.paint(glass, GLASS[1])
    st.paint(glass & (CY > cy + 1), GLASS[0])
    st.paint(glass & (CY > cy + 1) & (CY < cy + 2) & (XX % 3 == 0), FOAM[1])
    st.paint(ring, '#f8d0e0')
    st.paint(ring & (CY > cy), '#a84a7a')
    st.paint(rect(int(cx - 3), int(cy - 4), int(cx - 2), int(cy - 4)) | rect(int(cx - 4), int(cy - 3), int(cx - 4), int(cy - 2)), GLASS[2])
    for a in range(0, 360, 90):
        st.dots([(int(cx + (r - 1) * math.cos(math.radians(a + 45))), int(cy + (r - 1) * math.sin(math.radians(a + 45))))], GOLD)


# ------------------------------------------------------------------ 1. Pan Ting: corner-TB round, common.
def pan_ting():
    key = 'pl-drft-1'
    st = Sticker()
    core = (12, 24, 44, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(STEEL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d0d8e4', skip=grow(holes, 3))
    steel_pan(st, 30, 11)
    note(st, 47, 6)
    note(st, 8, 9)
    st.eye(18, 32, look=(0, 0))
    st.eye(31, 32, look=(0, 0))
    st.mouth('o', 25, 42)
    st.paint(rect(14, 41, 16, 41) | rect(36, 41, 38, 41), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Frond Nod: edge-TTB peg, common.
def frond_nod():
    key = 'pl-drft-2'
    st = Sticker()
    core = (16, 24, 46, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 4, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 16, 24, 31, list(PALM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FROND[2], skip=grow(holes, 3))
    frond(st, 36, 15, -165, 26, bend=0.035)                    # one long frond nodding over to the left
    st.part(rect(35, 13, 37, 18), COCO[2], d=1, contour=True)
    for i in range(4):                                          # leaflet ticks under the frond
        st.paint(line([(30 - 6 * i, 15 + i // 2), (28 - 6 * i, 19 + i // 2)]), FROND[0], solid=True)
    closed_up(st, 21, 33)
    closed_up(st, 35, 33)
    st.mouth('grin', 28, 40)
    st.paint(rect(19, 37, 21, 37) | rect(39, 37, 41, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Dusk Lap: inner-TBTB round, common.
def dusk_lap():
    key = 'pl-drft-3'
    st = Sticker()
    core = (14, 20, 46, 46)
    half_sun(st, 42, 21, 8)
    body, holes = piece_blanks(core, n=('T', 'round', -4, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 33, list(SEA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FOAM[2], skip=grow(holes, 3))
    wave_crest(st, 14, 34, 18)
    st.eye(22, 30, lid=3)
    st.eye(35, 30, lid=3)
    st.mouth('smile', 28, 38)
    st.paint(rect(18, 36, 20, 36) | rect(40, 36, 42, 36), BLUSH)
    st.paint(rect(16, 42, 44, 42) & body & (XX % 4 < 2), FOAM[0])   # lapping foam line at its toes
    return key, st


# ------------------------------------------------------------------ 4. Thatch Ridge: inner-TTTT peg, uncommon.
def thatch_ridge():
    key = 'pl-drft-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(STRAW)), contour=True)
    for y in (21, 24, 27):                                    # straw ridge rows, mirror-symmetric
        st.paint(rect(19, y, 44, y) & body & ((XX % 3) == 1), '#8e6a2a')
    st.paint(rect(19, 43, 44, 43) & body & ((XX % 2) == 0), '#8e6a2a')
    st.stitch(body, col=COCO[2])                              # uncommon accent: coconut brown
    roof = poly([(14, 19), (49, 19), (31.5, 7)]) & ~rect(0, 20, 63, 63)
    st.part(roof, '#d8b060', d=1, contour=True)
    st.paint(roof & ((XX % 3) == 0) & (CY > 12), '#8e6a2a')
    st.eye(25, 31, look=(1, 0))
    st.eye(36, 31, look=(1, 0))
    st.mouth('smirk', 29, 37)
    coco_cup(st, 11.5, 33, 3)
    coco_cup(st, 52.5, 33, 3)
    return key, st


# ------------------------------------------------------------------ 5. Pink Porthole: inner-BBBB round, uncommon.
def pink_porthole():
    key = 'pl-drft-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(PINK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GLASS[1], skip=grow(holes, 3))        # uncommon accent: sea teal
    wink(st, 22, 21)
    st.eye(37, 20, look=(0, 0))
    st.mouth('cat', 29, 27)
    porthole(st, 31.5, 39, 7.5)
    st.paint(rect(17, 27, 19, 27) | rect(44, 27, 46, 27), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Pinkhat Drummer: whimsy-drum peg, rare.
def pinkhat_drummer():
    key = 'pl-drft-6'
    st = Sticker()
    drum = rect(18, 38, 45, 50) | ellipse(31.5, 38, 14, 4)
    tab = knob('e', 'peg', 44, 45.5, r=3.0)
    st.part(drum | tab, tex=fill(key, drum | tab, 12, 30, 40, list(DRIFT)), contour=True)
    st.paint(rect(18, 44, 45, 44) & drum & (XX % 4 < 2), '#7a4a24')
    skin = ellipse(31.5, 38, 12, 2.4)
    st.paint(skin, CREAM)
    # gnome head + beard behind the drum
    head = ellipse(31.5, 27, 9, 7.5)
    st.part(head & ~drum, SKIN[0], d=1, contour=True)
    beard = (ellipse(31.5, 33, 10, 6) & (CY > 29)) & ~skin & ~drum
    st.part(beard, BEARD[0], d=1, contour=True)
    st.paint(beard & ((XX + YY) % 4 == 0), BEARD[1])
    st.part(ellipse(31.5, 29.5, 2.2, 1.6), '#e89a80', d=1, contour=False)
    hat = poly([(20, 23), (43, 23), (36, 14), (33, 10), (30, 9)])
    st.part(hat, HAT[1], d=1, contour=True)
    st.paint(hat & (CX < 28) & (CY > 12), HAT[0])
    st.paint(rect(20, 21, 43, 23) & hat, HAT[2])
    closed_up(st, 25, 25)
    closed_up(st, 34, 25)
    st.paint(rect(22, 28, 23, 28) | rect(40, 28, 41, 28), BLUSH)
    # drumsticks mid-beat
    for (a, b), (c, d) in (((15, 28), (23, 37)), ((48, 28), (40, 37))):
        s = line([(a, b), (c, d)], w=2)
        st.paint(s, '#e8c890', solid=True)
        st.paint(disc(a, b, 1.6), CREAM, solid=True)
        st.extra |= grow(s, 1)
    st.sparkle(10, 12)
    st.sparkle(52, 12, big=False)
    st.sparkle(11, 46, big=False)
    return key, st


PALS = [pan_ting, frond_nod, dusk_lap, thatch_ridge, pink_porthole, pinkhat_drummer]

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
