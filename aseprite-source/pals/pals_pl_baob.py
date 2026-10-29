"""Puzzle Pals: BAOBAB INN (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-baob-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_baob.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a guesthouse inside a giant baobab at golden hour; round knobs. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy, puff); everything else drawn here. Silhouette = the row's shape + knob,
body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/haven-baobab-inn.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Pot Simmer        clay-pot terracotta      | a lid with a knob on its head, a curl of stew steam, a wooden ladle  | sleepy content lids, cat :3
  2 Branch Bird       blackbird slate          | an orange beak, a baobab twig perch with a leaf, music notes        | singing: closed ^ eyes, open o song
  3 Supper Sun        low-sun peach-gold       | 8 sun rays + a little spoon held up for supper                       | eager round eyes up, tooth grin
  4 Canopy Rustle     baobab leaf green (+bark)| a leaf tuft on each of its 4 tabs, rustle lines                      | cheeky wink, smirk
  5 Trunk Peephole    bark grey-tan (+lamp)    | a round glowing window with cross panes in its middle                | shy look-down eyes, blush, small smile
  6 Baobab Innkeeper  baobab bark brown (rare) | whimsy baobab: bottle trunk, branch crown of leaf clumps, glowing door | big welcoming smile, happy eyes
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-baobab-inn'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-baobab-inn-9e5f82')

CLAY = ('#a8442e', '#c8623a')          # clay pot terracotta
SLATE = ('#2e3440', '#48505e')         # blackbird slate
SUNC = ('#f0b060', '#fbd88a')          # low sun peach-gold
LEAF = ('#3f7a3a', '#5e9a46')          # baobab leaf green
BARKG = ('#9a8a78', '#b8a890')         # pale bark grey-tan
BARK = ('#8a5a3a', '#a8744a')          # baobab bark brown (rare)
BEAK = ('#f0922a', '#c0661a')
WOOD = ('#b07a40', '#7a4e26', '#d8a868', '#4a2c1a')
STEAM = ('#efe6d6', '#c8bcaa', '#ffffff', '#a89a88')
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


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def pot_lid(st, cx, y, w):
    lid = ellipse(cx, y, w, 2.6)
    st.part(lid, CLAY[1], d=1, contour=True)
    st.paint(lid & (CY < y - 0.5) & shrink(lid, 1), '#e08a5a')
    k = disc(cx, y - 3.6, 1.8)
    st.part(k, WOOD[0], d=0, contour=True, shade=False)
    st.dots([(int(cx - 1), int(y - 5))], WOOD[2])
    return lid | k


def steam_curl(st, x, y):
    for k in range(3):
        m = line([(x + 2 * k, y - 4 * k), (x + 2 * k + 1, y - 4 * k - 1)], w=1)
    pts = [(x + 2 * math.sin(i * 0.7), y - i) for i in range(10)]
    m = blank()
    for a, b in zip(pts, pts[1:]):
        m |= line([a, b], w=2)
    st.paint(m, STEAM[0])
    st.paint(m & ~shift(m, 1, 0), STEAM[2])
    st.extra |= m
    return m


def ladle(st, x0, y0, x1, y1):
    h = line([(x0, y0), (x1, y1)], w=2)
    st.part(h, WOOD[0], d=1, contour=True)
    bowl = disc(x1 + 1, y1 + 2, 2.6)
    st.part(bowl, WOOD[1], d=1, contour=True)
    st.paint(bowl & (CY < y1 + 1.5) & shrink(bowl, 1), WOOD[2])
    return h | bowl


def beak(st, x, y):
    st.sprite(['BBBB.', 'BBBBB', 'DDDD.'], x, y, {'B': BEAK[0], 'D': BEAK[1]}, solid=True)


def note(st, x, y):
    st.sprite(['..CC', '..C.', '..C.', 'CCC.', 'CC..'], x, y, {'C': CREAM}, solid=False)
    for j, r in enumerate(['..CC', '..C.', '..C.', 'CCC.', 'CC..']):
        for i, ch in enumerate(r):
            if ch == 'C':
                st.extra[y + j, x + i] = True


def leaf_clump(st, cx, cy, r, pal=LEAF):
    m = disc(cx, cy, r) | disc(cx - r * 0.7, cy + r * 0.35, r * 0.7) | disc(cx + r * 0.7, cy + r * 0.35, r * 0.7)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & disc(cx - r * 0.35, cy - r * 0.35, r * 0.5) & shrink(m, 1), pal[1])
    return m


def leaf_tuft(st, cx, cy, ang):
    """Three small leaves fanning out from (cx, cy) along angle ang (degrees)."""
    m = blank()
    for da in (-35, 0, 35):
        a = math.radians(ang + da)
        ex, ey = cx + 4 * math.cos(a), cy + 4 * math.sin(a)
        m |= ellipse((cx + ex) / 2, (cy + ey) / 2, 2.0, 2.0) | disc(ex, ey, 1.6)
    st.part(m, '#6aa84e', d=1, contour=True)
    st.paint(m & shrink(m, 1) & ((XX + YY) % 3 == 0), '#9ccc6a')
    return m


def sun_rays(st, cx, cy, r0, r1):
    m = blank()
    for i in range(8):
        a = math.pi / 4 * i + math.pi / 8
        m |= line([(cx + r0 * math.cos(a), cy + r0 * math.sin(a)), (cx + r1 * math.cos(a), cy + r1 * math.sin(a))], w=2)
    st.paint(m, '#f8dc6a')
    st.paint(m & ~shift(m, 1, 1), '#fff3c8')
    st.extra |= m
    return m


def spoon(st, x, y):
    h = rect(x, y, x + 1, y + 10)
    st.part(h, '#c8c8c0', d=1, contour=True)
    b = ellipse(x + 1, y - 2, 2.6, 3.4)
    st.part(b, '#d8d8d0', d=1, contour=True)
    st.dots([(x, y - 4)], '#ffffff')
    return h | b


def window(st, cx, cy, r):
    frame = disc(cx, cy, r + 1.5)
    st.part(frame, WOOD[1], d=1, contour=True)
    g = disc(cx, cy, r)
    st.paint(g, LAMP[1], solid=True)
    st.paint(disc(cx, cy - 0.5, r - 1.5), LAMP[0])
    st.paint(disc(cx - 1, cy - 1.5, r * 0.4), LAMP[2])
    st.paint((rect(int(cx), int(cy - r), int(cx), int(cy + r)) | rect(int(cx - r), int(cy), int(cx + r), int(cy))) & g, WOOD[1])
    return frame


# ------------------------------------------------------------------ 1. Pot Simmer: corner-TB round, common.
def pot_simmer():
    key = 'pl-baob-1'
    st = Sticker()
    core = (12, 25, 45, 49)
    body, holes = piece_blanks(core, n=('T', 'round', -6, 3.8), e=('B', 'round', 1, 3.0))
    body = body & ~(rect(0, 46, 63, 63) & ~ellipse(28.5, 44, 17.5, 6.5))       # a rounded pot belly at the bottom
    st.part(body, tex=fill(key, body, 12, 25, 34, list(CLAY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(13, 32, 44, 33) & body & ~grow(holes, 1), '#7a2e20')         # pot rim band
    st.stitch(body, col='#f0c090', skip=grow(holes, 3))
    pot_lid(st, 26, 21, 9)
    steam_curl(st, 38, 18)
    steam_curl(st, 44, 13)
    ladle(st, 47, 20, 52, 50)
    st.eye(18, 36, lid=2)
    st.eye(30, 36, lid=2)
    st.paint(rect(15, 43, 17, 43) | rect(36, 43, 38, 43), BLUSH)
    st.mouth('cat', 24, 43)
    return key, st


# ------------------------------------------------------------------ 2. Branch Bird: edge-TTB peg, common.
def branch_bird():
    key = 'pl-baob-2'
    st = Sticker()
    br = line([(9, 52), (54, 49)], w=3)
    st.part(br, WOOD[1], d=1, contour=True)
    st.paint(br & ~shift(br, 0, 1), WOOD[0])
    leaf_clump(st, 50, 44, 3.2)
    core = (16, 22, 44, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 3.0), e=('T', 'peg', -2, 3.2), w=('T', 'peg', -2, 3.2))
    st.part(body, tex=fill(key, body, 16, 22, 29, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8a96a8', skip=grow(holes, 3))
    st.sprite(['O.O..O.O', 'OOOO.OOOO'], 22, 47, {'O': BEAK[0]}, solid=True)     # toes gripping the branch
    closed_up(st, 20, 30)
    closed_up(st, 34, 30)
    beak(st, 27, 34)
    st.sprite(['.UU.', 'URRU', '.UU.'], 28, 38, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(18, 34, 20, 34) | rect(37, 34, 39, 34), BLUSH)
    note(st, 50, 10)
    note(st, 8, 8)
    return key, st


# ------------------------------------------------------------------ 3. Supper Sun: inner-TBTB round, common.
def supper_sun():
    key = 'pl-baob-3'
    st = Sticker()
    core = (14, 18, 43, 44)
    sun_rays(st, 29, 31, 21, 26)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.4), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.4), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 30, list(SUNC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c8702a', skip=grow(holes, 3))
    st.eye(19, 25, look=(0, -1))
    st.eye(32, 25, look=(0, -1))
    st.mouth('tooth', 26, 34)
    st.paint(rect(17, 33, 19, 33) | rect(37, 33, 39, 33), '#e8805a')
    spoon(st, 46, 46)
    return key, st


# ------------------------------------------------------------------ 4. Canopy Rustle: inner-TTTT peg, uncommon.
def canopy_rustle():
    key = 'pl-baob-4'
    st = Sticker()
    core = (20, 20, 43, 43)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 18, 28, list(LEAF)), contour=True)
    st.stitch(body, col=BARK[1])                                # uncommon accent: baobab bark
    leaf_tuft(st, 32, 13, -90)
    leaf_tuft(st, 32, 51, 90)
    leaf_tuft(st, 13, 32, 180)
    leaf_tuft(st, 51, 32, 0)
    wink(st, 23, 27)
    st.eye(35, 26, look=(-1, 0))
    st.mouth('smirk', 29, 36)
    st.paint(rect(22, 34, 24, 34) | rect(39, 34, 41, 34), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Trunk Peephole: inner-BBBB round, uncommon.
def trunk_peephole():
    key = 'pl-baob-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.2), e=('B', 'round', 0, 3.2), s=('B', 'round', 0, 3.2), w=('B', 'round', 0, 3.2))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(BARKG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LAMP[0], skip=grow(holes, 3))          # uncommon accent: window lamplight
    st.paint(body & shrink(body, 2) & ((XX * 2 + YY) % 9 == 0) & (YY > 40), '#7a6a58')    # bark grain
    window(st, 32, 37, 6.5)
    st.eye(21, 20, look=(0, 1))
    st.eye(38, 20, look=(0, 1))
    st.paint(rect(17, 28, 19, 28) | rect(44, 28, 46, 28), BLUSH)
    st.mouth('smile', 30, 27)
    return key, st


# ------------------------------------------------------------------ 6. Baobab Innkeeper: whimsy-baobab peg, rare.
def baobab_innkeeper():
    key = 'pl-baob-6'
    st = Sticker()
    trunk = ellipse(32, 41, 14, 12.5) | rect(23, 22, 40, 40)
    branches = line([(26, 24), (19, 16)], w=4) | line([(37, 24), (44, 16)], w=4) | line([(32, 22), (32, 14)], w=4)
    tab = knob('e', 'peg', 42, 42.5, r=2.6)
    body = (trunk | branches | tab) & (YY < 54)
    st.part(body, tex=fill(key, body, 14, 8, 44, list(BARK)), contour=True)
    st.stitch(trunk & (YY < 54), col='#d8a868')
    for cx, cy, r in ((19, 16, 4.2), (45, 16, 4.2), (32, 12, 4.0)):
        leaf_clump(st, cx, cy, r)
    door = (ellipse(32, 46, 5, 5) | rect(27, 46, 37, 52)) & (YY <= 52)
    st.paint(grow(door, 1), WOOD[3], solid=True)
    st.paint(door, LAMP[1], solid=True)
    st.paint(shrink(door, 1), LAMP[0])
    st.paint(rect(30, 44, 31, 48), LAMP[2])
    st.eye(24, 29, look=(0, 0))
    st.eye(35, 29, look=(0, 0))
    st.mouth('grin', 30, 36)
    st.paint(rect(21, 36, 23, 36) | rect(40, 36, 42, 36), BLUSH)
    st.sparkle(9, 26)
    st.sparkle(50, 24, big=False)
    st.sparkle(12, 44, big=False)
    return key, st


PALS = [pot_simmer, branch_bird, supper_sun, canopy_rustle, trunk_peephole, baobab_innkeeper]

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
