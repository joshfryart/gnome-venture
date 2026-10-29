"""Puzzle Pals: LIGHTHOUSE OF THE LOST LANTERN (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wlig-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wlig.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: dusk coast sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-lighthouse-of-the-lost-lantern.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Brass Bonnet        polished brass              | domed lamp-room cap with finial ball + rivets on its brow       | wide bright eyes, open grin
  2 Tipsy Crescent      night indigo                | pale crescent moon leaning off the top tab, tiny zzz            | sleepy half-lids, small smile
  3 Thimble Sailboat    sea teal                    | wee sailboat with white sail on the water, wave line            | ^ ^ happy eyes, o mouth
  4 Sunset Layer Cake   sunset pink (+ purple)      | purple/pink/gold bands stacked, candle on the top tab           | eyes glancing up, cat mouth
  5 Wide-Eyed Windows   tower cream (+ brick red)   | two big round window eyes with dark panes, brick stripe band    | round window eyes, small o
  6 Candlehead Crab     crimson crab + cream belly  | whimsy crab holding a lit candle in each claw, eye stalks, glow | stalk eyes, wide smile, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-lighthouse-of-the-lost-lantern'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-lighthouse-of-the-lost-lantern-390d6d')

BRASS = ('#b88a2e', '#d8aa48')
NIGHT = ('#323e70', '#50669b')
SEA = ('#2e7a86', '#4a9aa4')
SUNSET = ('#d87a9a', '#eea0b4')
TOWER = ('#d8c4a4', '#ece0c4')
CRAB = ('#b02a3a', '#d04452')
CREAM = '#fbf0dc'
PURP = ('#6a4a9a', '#8a6abc')
GOLD = ('#f0c84a', '#fff0a0')
BRICK = '#8a3a3a'
FLAME = ('#ff9a2a', '#ffe070')
PANE = '#3a2a5a'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def candle(st, x, y):
    st.part(rect(x, y, x + 1, y + 5), CREAM, d=0, contour=True, shade=False)
    st.paint(rect(x, y - 3, x + 1, y - 1), FLAME[0], solid=True)
    st.dots([(x, y - 2)], FLAME[1])


# 1. Brass Bonnet: corner-TT keyhole, common.
def brass_bonnet():
    key = 'pl-wlig-1'
    st = Sticker()
    core = (12, 20, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 10, 46, list(BRASS)), contour=True)
    st.blank_shade(body, holes, width=1)
    dome = ellipse(30, 21, 15, 6) & (YY <= 21)
    st.part(dome, BRASS[1], d=1, contour=True)
    st.part(disc(30, 9, 2.4), GOLD[0], d=1, contour=True)
    st.paint(rect(14, 22, 46, 23), '#8a6420')
    st.dots([(x, 22) for x in range(16, 46, 5)], GOLD[1])
    st.eye(21, 31)
    st.eye(35, 31)
    st.mouth('grin', 26, 40)
    return key, st


# 2. Tipsy Crescent: edge-TBT keyhole, common.
def tipsy_crescent():
    key = 'pl-wlig-2'
    st = Sticker()
    core = (13, 24, 46, 53)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 3, 3.0), w=('T', 'keyhole', 3, 3.6))
    st.part(body, tex=fill(key, body, 13, 14, 40, list(NIGHT)), contour=True)
    st.blank_shade(body, holes, width=1)
    moon = disc(36, 13, 7) & ~disc(39, 10, 6)
    st.part(moon, '#f4e8a8', d=1, contour=True)
    st.dots([(46, 6), (49, 4), (52, 6)], '#f4e8a8')
    st.dots([(18, 28), (40, 46), (24, 49)], '#c8d0f0')
    st.eye(20, 34, lid=2)
    st.eye(34, 34, lid=2)
    st.mouth('smile', 26, 42)
    return key, st


# 3. Thimble Sailboat: inner-TBTB keyhole, common.
def thimble_sailboat():
    key = 'pl-wlig-3'
    st = Sticker()
    core = (14, 16, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 36, list(SEA)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (38, 42):
        st.paint(rect(18, y, 46, y) & body & ~grow(holes, 1) & ((XX // 3) % 2 == 0), '#cfeef0')
    st.part(rect(36, 33, 45, 35), '#7a4a2a', d=0, contour=True, shade=False)
    sail = rect(39, 22, 40, 32) | (rect(41, 23, 45, 32) & ((XX - 41) <= (YY - 23) * 0.6))
    st.part(sail, CREAM, d=0, contour=True, shade=False)
    happy_eye(st, 19, 23)
    happy_eye(st, 29, 23)
    st.mouth('o', 25, 30)
    return key, st


# 4. Sunset Layer Cake: inner-TTTT double, uncommon.
def sunset_layer_cake():
    key = 'pl-wlig-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SUNSET)), contour=True)
    st.paint(body & (YY <= 23), PURP[0])
    st.paint(body & (YY >= 39) & (YY <= 42), GOLD[0])
    st.paint(body & (YY == 24), CREAM)
    st.paint(body & (YY == 38), CREAM)
    st.stitch(body, col=PURP[1])
    candle(st, 31, 7)
    st.eye(24, 28, look=(0, -1))
    st.eye(35, 28, look=(0, -1))
    st.paint(rect(21, 34, 23, 34) | rect(40, 34, 42, 34), BLUSH)
    st.mouth('cat', 30, 35)
    return key, st


# 5. Wide-Eyed Windows: inner-BBBB keyhole, uncommon.
def wide_eyed_windows():
    key = 'pl-wlig-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(TOWER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(11, 38, 52, 42) & body & ~grow(holes, 1), BRICK)
    st.stitch(body, col=BRICK, skip=grow(holes, 3))
    for cx in (22, 41):
        st.part(disc(cx, 25, 6.5), BRICK, d=0, contour=True, shade=False)
        st.paint(disc(cx, 25, 4.5), PANE, solid=True)
        st.paint(rect(cx - 4, 25, cx + 4, 25) | rect(cx, 21, cx, 29), BRICK)
        st.dots([(cx - 2, 23)], '#fff8e0')
    st.mouth('o', 31, 33)
    return key, st


# 6. Candlehead Crab: whimsy-lampcrab keyhole, rare.
def candlehead_crab():
    key = 'pl-wlig-6'
    st = Sticker()
    shell = ellipse(32, 38, 15, 9)
    tab = knob('s', 'keyhole', 32, 46, r=3.0)
    claws = disc(13, 26, 4.5) | disc(51, 26, 4.5)
    arms = line([(20, 36), (14, 29)], w=2) | line([(44, 36), (50, 29)], w=2)
    legs = line([(20, 43), (14, 50)], w=1) | line([(44, 43), (50, 50)], w=1) | line([(24, 45), (20, 52)], w=1) | line([(40, 45), (44, 52)], w=1)
    stalks = line([(27, 30), (26, 24)], w=1) | line([(37, 30), (38, 24)], w=1)
    st.part(legs | stalks, CRAB[0], d=0, contour=True, shade=False)
    sil = shell | tab | claws | arms
    st.part(sil, tex=fill(key, sil, 9, 14, 46, list(CRAB)), contour=True)
    st.paint(ellipse(32, 42, 8, 3.5) & shell, CREAM)
    for cx in (13, 51):
        st.paint(rect(cx - 1, 21, cx + 1, 22), BRICK)
    candle(st, 12, 15)
    candle(st, 51, 15)
    for cx in (26, 38):
        st.part(disc(cx, 22, 2.6), CREAM, d=0, contour=True, shade=False)
        st.dots([(cx, 22)], UMBER)
    st.mouth('grin', 27, 36)
    st.paint(rect(20, 36, 22, 36) | rect(42, 36, 44, 36), BLUSH)
    st.sparkle(6, 6)
    st.sparkle(56, 6, big=False)
    st.sparkle(32, 8, big=False)
    return key, st


PALS = [brass_bonnet, tipsy_crescent, thimble_sailboat, sunset_layer_cake, wide_eyed_windows, candlehead_crab]

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
