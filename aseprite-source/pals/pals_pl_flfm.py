"""Puzzle Pals: FLOATING FLOWER MARKET (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-flfm-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_flfm.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven = cosy hearth folk, round knobs. kit_lair parts are building blocks only; the rest is drawn here.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/haven-floating-flower-market.png,
calmed onto 2 tones of a pal-own colour family from the picture (shikara walnut, lake teal, mountain slate, blossom pink, dome cream, marigold).
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Blooming Barge    shikara walnut      | a crescent shikara hull underneath, a heap of pink + orange blooms on its head | cheeky wink, grin
  2 Bobbing Blooms    lake teal           | marigold heads bobbing in a ripple round it, a half-strung garland thread       | startled wide eyes, o
  3 Sunrise Snowcap   mountain slate      | a snowy peak cap on its head, the rising sun peeping behind                     | sleepy closed arcs, smile
  4 Petal Heap        blossom pink (+wh)  | a mounded heap of pale petals on top, petals drifting off both sides           | shy dot eyes, blush, cat mouth
  5 Temple Arch       dome cream (+gold)  | a dark arched doorway in its belly with gold light spilling out, onion finial  | calm half lids, flat mouth
  6 Garland Florist   marigold (rare)     | whimsy marigold: petal-ring head, pink pointed hat, oar + a garland loop       | big happy eyes, toothy grin
Ring and Plus knobs are centred (n, s at 0; e, w at the same height), no hooks.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-floating-flower-market'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-floating-flower-market-da20bd')

WALNUT = ('#6a3e26', '#8a5634')
TEAL = ('#2f7f92', '#408da1')
SLATE = ('#4a5a8a', '#6474a4')
PINK = ('#d8789a', '#ec98b2')
DOMECR = ('#e2cfa0', '#f2e2b8')
MARI = ('#e88a1e', '#f6a832')
HULL = ('#5a2e1c', '#3a1c12', '#8a5232', '#2a140c')
WATER = ('#408da1', '#2e6a7c', '#85bdd8', '#1e4a5a')
SNOW = ('#eef4fa', '#b8c8de', '#ffffff', '#8a9ab8')
BLOOMP = '#f088b0'
BLOOMO = '#f59a2a'
PETAL = ('#f6e6ec', '#dcbcc8', '#fff8fa')
ORANGE_D = '#c86414'
HATPINK = ('#d8508a', '#a8306a', '#f080b0')
BLUSH = '#f0a0a0'
SUN = '#f5b850'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


def extra_sprite(st, rows_, x, y, cmap):
    st.sprite(rows_, x, y, cmap, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch not in '. ':
                st.extra[y + j, x + i] = True


# ---------------------------------------------------------------- own helpers
def bloom(st, cx, cy, col, r=2.2):
    m = disc(cx, cy, r)
    st.part(m, col, d=1, contour=True)
    st.paint(rect(int(cx), int(cy), int(cx), int(cy)), GOLD)
    return m


def marigold(st, x, y):
    """A 5 x 5 marigold head: frilly orange ring, dark centre."""
    st.sprite(['.OOO.', 'OoOoO', 'OODOO', 'OoOoO', '.OOO.'], x, y, {'O': BLOOMO, 'o': ORANGE_D, 'D': '#7a3a10'}, solid=True)


def ripple(st, cx, cy, rx, ry):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, WATER[0], d=1, contour=True)
    st.paint(m & (YY == cy) & ((XX % 5) < 2), WATER[2])
    return m


def shikara(st, x0, x1, y):
    """A crescent shikara hull: long low boat, both ends curling up to points, a light rail line."""
    m = blank()
    for x in range(x0, x1 + 1):
        t = (x - x0) / (x1 - x0)
        top = y - int(round(5 * (2 * t - 1) ** 6))
        m |= rect(x, top, x, y + 4 - int(round(3 * (2 * t - 1) ** 2)))
    st.part(m, HULL[0], d=1, contour=True)
    st.paint(m & (YY == y + 1) & (XX > x0 + 3) & (XX < x1 - 3), HULL[2])
    return m


def closed_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def snowcap(st, cx, y, w):
    pts = [(cx - w, y + 7), (cx - 3, y + 1), (cx, y - 2), (cx + 3, y + 1), (cx + w, y + 7)]
    m = poly(pts + [(cx + w, y + 9), (cx - w, y + 9)])
    m &= ~((YY >= y + 6) & ((XX % 4) == 1) & (YY > y + 7))
    st.part(m, SNOW[0], d=1, contour=True)
    st.paint(m & (XX > cx + 1) & (YY > y + 1), SNOW[1])
    return m


# ------------------------------------------------------------------ 1. Blooming Barge: corner-TB round, common.
def blooming_barge():
    key = 'pl-flfm-1'
    st = Sticker()
    core = (12, 22, 44, 44)
    body, holes = piece_blanks(core, n=('T', 'round', -6, 3.8), e=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 34, list(WALNUT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 42), col='#d8a868', skip=grow(holes, 3))
    shikara(st, 8, 55, 46)
    for cx, cy, c in ((17, 13, BLOOMP), (22, 10, BLOOMO), (27, 12, BLOOMP), (20, 16, BLOOMO), (26, 17, BLOOMP),
                      (31, 15, BLOOMO), (14, 18, BLOOMP)):
        bloom(st, cx, cy, c)
    st.eye(17, 27, look=(1, 0))
    closed_eye(st, 31, 29)
    st.mouth('grin', 23, 36)
    st.paint(rect(15, 35, 17, 35) | rect(37, 35, 39, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Bobbing Blooms: edge-TTB peg, common.
def bobbing_blooms():
    key = 'pl-flfm-2'
    st = Sticker()
    core = (15, 20, 46, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 3.0), e=('T', 'peg', -3, 3.2), w=('T', 'peg', -3, 3.2))
    st.part(body, tex=fill(key, body, 15, 20, 32, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 42), col=WATER[2], skip=grow(holes, 3))
    ripple(st, 31, 49, 24, 3.6)
    for x, y in ((9, 45), (18, 46), (39, 46), (49, 45)):
        marigold(st, x, y)
    marigold(st, 18, 33)
    st.eye(20, 25, look=(0, -1))
    st.eye(36, 25, look=(0, -1))
    st.paint(rect(20, 22, 24, 22) | rect(36, 22, 40, 22), UMBER)
    st.mouth('o', 29, 33)
    return key, st


# ------------------------------------------------------------------ 3. Sunrise Snowcap: inner-TBTB round, common.
def sunrise_snowcap():
    key = 'pl-flfm-3'
    st = Sticker()
    core = (13, 22, 44, 48)
    sun = disc(45, 15, 5.5)
    st.part(sun, SUN, d=1, contour=True)
    st.paint(sun & (CY < 14), GOLD)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.4), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.4), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 13, 22, 32, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    snowcap(st, 29, 10, 16)
    st.stitch(body & (YY > 30), col=SNOW[1], skip=grow(holes, 3))
    closed_eye(st, 19, 31)
    closed_eye(st, 33, 31)
    st.mouth('smile', 26, 37)
    st.paint(rect(17, 35, 19, 35) | rect(39, 35, 41, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Petal Heap: inner-TTTT peg (Plus), uncommon.
def petal_heap():
    key = 'pl-flfm-4'
    st = Sticker()
    core = (18, 22, 45, 45)
    body = piece(core, n=('T', 'peg', 0, 3.0), e=('T', 'peg', 0, 3.2), s=('T', 'peg', 0, 3.2), w=('T', 'peg', 0, 3.2))
    st.part(body, tex=fill(key, body, 18, 22, 28, list(PINK)), contour=True)
    st.stitch(body, col=PETAL[0])                                         # uncommon accent: the pale petal white
    heap = ellipse(32, 17, 11, 6) & (YY < 21) | rect(22, 17, 41, 21)
    st.part(heap, PETAL[0], d=1, contour=True)
    for x, y in ((25, 14), (30, 12), (35, 14), (28, 17), (38, 17), (24, 18), (33, 18)):
        st.sprite(['.P.', 'PWP', '.P.'], x - 1, y - 1, {'P': PETAL[1], 'W': PETAL[2]}, solid=False)
    for x, y in ((8, 14), (55, 14)):
        extra_sprite(st, ['.P', 'PP'] if x < 32 else ['P.', 'PP'], x, y, {'P': PETAL[0]})
    st.paint(rect(24, 30, 26, 32) | rect(37, 30, 39, 32), UMBER)
    st.dots([(24, 30), (37, 30)], CREAM)
    st.paint(rect(21, 35, 23, 35) | rect(40, 35, 42, 35), '#b84070')
    st.mouth('cat', 29, 36)
    return key, st


# ------------------------------------------------------------------ 5. Temple Arch: inner-BBBB round (Ring), uncommon.
def temple_arch():
    key = 'pl-flfm-5'
    st = Sticker()
    core = (13, 16, 50, 51)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.2), e=('B', 'round', 0, 3.2), s=('B', 'round', 0, 3.2), w=('B', 'round', 0, 3.2))
    st.part(body, tex=fill(key, body, 13, 16, 38, list(DOMECR)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLD_D, skip=grow(holes, 3))                       # uncommon accent: the dome gold
    door = (ellipse(32, 39, 6, 6) | rect(26, 39, 37, 48)) & (YY <= 48)
    st.paint(grow(door, 1), '#3a2a4a', solid=True)
    st.paint(door, '#2a2440', solid=True)
    st.paint(door & (YY >= 44) & ~shrink(door, 1), GOLD)
    st.paint(rect(29, 45, 34, 48) & door, GOLD_L)                          # light spilling out
    st.paint(rect(28, 49, 35, 49), GOLD, solid=True)
    st.paint(disc(32, 14, 1.8) | disc(32, 11.5, 1.0), GOLD, solid=True)     # onion finial in the notch
    st.eye(20, 23, lid=1)
    st.eye(39, 23, lid=1)
    st.mouth('flat', 31, 31)
    return key, st


# ------------------------------------------------------------------ 6. Garland Florist: whimsy-marigold peg, rare.
def garland_florist():
    key = 'pl-flfm-6'
    st = Sticker()
    petals = blank()
    for i in range(12):
        a = i * np.pi / 6
        petals |= disc(32 + 13 * np.cos(a), 34 + 12 * np.sin(a), 4.2)
    head = ellipse(32, 34, 13, 12)
    tab = knob('e', 'peg', 34, 49, r=2.6)
    body = petals | head | tab
    st.part(body, tex=fill(key, body, 12, 15, 42, list(MARI)), contour=True)
    for i in range(12):
        a = (i + 0.5) * np.pi / 6
        st.paint(line([(int(32 + 11 * np.cos(a)), int(34 + 10 * np.sin(a))), (int(32 + 17 * np.cos(a)), int(34 + 16 * np.sin(a)))]) & body & ~head, ORANGE_D)
    st.paint(head & ~shrink(head, 1), ORANGE_D)
    st.stitch(head, col=GOLD_L)
    hat = poly([(22, 22), (42, 22), (33, 9)])
    st.part(hat, HATPINK[0], d=1, contour=True)
    st.paint(rect(21, 21, 43, 23), HATPINK[1], solid=True)
    st.paint(line([(30, 16), (32, 11)]), HATPINK[2])
    oar = line([(11, 53), (19, 41)], w=2)
    st.part(oar, HULL[2], d=0, contour=True)
    st.part(ellipse(11, 52, 2.2, 3.0), HULL[0], d=0, contour=True)
    gar = blank()
    for i in range(9):
        t = i / 8
        gar |= disc(22 + 20 * t, 47 + 5 * np.sin(np.pi * t), 1.6)
    st.part(gar, BLOOMP, d=1, contour=True)
    st.paint(gar & ((XX + YY) % 4 == 0), BLOOMO)
    st.eye(24, 29)
    st.eye(35, 29)
    st.mouth('tooth', 30, 37)
    st.paint(rect(21, 36, 23, 36) | rect(41, 36, 43, 36), BLUSH)
    st.sparkle(6, 12)
    st.sparkle(52, 8, big=False)
    st.sparkle(53, 54, big=False)
    return key, st


PALS = [blooming_barge, bobbing_blooms, sunrise_snowcap, petal_heap, temple_arch, garland_florist]

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
