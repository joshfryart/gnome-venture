"""Puzzle Pals: SUNKEN GNOME GALLEON (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-sung-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_sung.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: reef-shallows sprites round a tiny wreck, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy, zzz); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell
of game/assets/img/jigsaw/places/wonder-sunken-gnome-galleon.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Sunnyfin Shoal      sunny fish yellow          | forked tail fin off the east tab, two little shoal-mates     | wide bright eyes, open grin
  2 Chestful Snore      chest wood brown           | iron lid band + gold lock plate, rising snore bubbles, zzz   | shut sleepy lids, cat mouth
  3 Bubble Bop          pale shallows aqua         | glassy bubble ring + big white shine, pop-burst lines        | ^ ^ happy eyes, o mouth
  4 Topsail Bandage     sail cream (+ patch orange)| central orange mend with cross-stitches, mast tip on top tab | eyes glancing up, smile
  5 Porthole Peekaboo   hull dark (+ brass)        | big brass porthole ring, one giant eye peeking through glass | single huge eye, small smirk
  6 Hullmate Octopus    coral red octopus          | whimsy octopus, 6 curly arms, one waving, suckers, glow     | startled round eyes, o mouth, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-sunken-gnome-galleon'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-sunken-gnome-galleon-1c85cc')

FISH = ('#e8b83a', '#f6d66a')
CHEST = ('#8a5a30', '#a8743e')
AQUA = ('#8fd8dc', '#c4eef0')
SAIL = ('#e6d2aa', '#f4e6c8')
HULL = ('#5a3a26', '#74503a')
OCTO = ('#c8463e', '#e0645a')
CREAMW = '#fbf0dc'
IRON = '#3c261e'
LOCK = ('#f0c84a', '#fff0a0')
PATCH = ('#e8762a', '#f6a050')
BRASS = ('#c8963a', '#ecc464')
GLASS = '#2a4a6a'
BUBW = '#eefaff'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def shut_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def bub(st, cx, cy, r):
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 1.1)
    st.paint(ring, AQUA[1], solid=True)
    st.dots([(int(cx - r * 0.4), int(cy - r * 0.4))], BUBW)
    st.extra |= disc(cx, cy, r)


def tiny_fish(st, x, y, flip=1):
    m = ellipse(x, y, 3.2, 2.0) | poly([(x - 3 * flip, y), (x - 6 * flip, y - 2.5), (x - 6 * flip, y + 2.5)])
    st.part(m, FISH[0], d=0, contour=True, shade=False)
    st.dots([(int(x + 1.5 * flip), y - 1)], UMBER)


# 1. Sunnyfin Shoal: corner-TT keyhole, common.
def sunnyfin_shoal():
    key = 'pl-sung-1'
    st = Sticker()
    core = (10, 22, 40, 52)
    tail = poly([(41, 37), (52, 29), (49, 37), (52, 45)])
    st.part(tail, FISH[1], d=1, contour=True)
    st.paint(line([(45, 37), (51, 32)]) | line([(45, 37), (51, 42)]), '#c8902a')
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 10, 12, 44, list(FISH)), contour=True)
    st.paint(poly([(22, 22), (28, 15), (32, 22)]) & ~body, '#c8902a', solid=True)   # dorsal fin nub
    for x in (17, 25, 33):
        st.paint(line([(x, 44), (x + 3, 47), (x + 6, 44)]) & body, '#c8902a')        # scales
    st.eye(15, 29)
    st.eye(28, 29)
    st.mouth('grin', 22, 38)
    tiny_fish(st, 15, 13, 1)
    tiny_fish(st, 49, 15, -1)
    return key, st


# 2. Chestful Snore: edge-TBT keyhole, common.
def chestful_snore():
    key = 'pl-sung-2'
    st = Sticker()
    core = (16, 22, 48, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 3, 3.6), e=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 14, 12, 42, list(CHEST)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(16, 33, 48, 34) & body & ~grow(holes, 1), IRON)
    st.paint(rect(20, 22, 21, 52) & body, IRON)
    st.paint(rect(43, 22, 44, 52) & body & ~grow(holes, 1), IRON)
    st.part(rect(29, 32, 34, 38), LOCK[0], d=0, contour=True, shade=False)
    st.paint(rect(31, 35, 32, 36), IRON, solid=True)
    st.dots([(30, 33)], LOCK[1])
    shut_eye(st, 23, 27)
    shut_eye(st, 35, 27)
    st.mouth('cat', 29, 43)
    bub(st, 50, 18, 2.4)
    bub(st, 45, 12, 1.7)
    zzz(st, 50, 6)
    return key, st


# 3. Bubble Bop: inner-TBTB keyhole, common.
def bubble_bop():
    key = 'pl-sung-3'
    st = Sticker()
    core = (14, 14, 48, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 6, 44, list(AQUA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=BUBW, skip=grow(holes, 3))
    st.paint(rect(19, 21, 23, 22) | rect(19, 23, 20, 25), BUBW)        # glassy shine
    for (a, b, c, d) in ((8, 12, 10, 14), (55, 12, 53, 14), (8, 51, 10, 49), (55, 51, 53, 49)):
        st.paint(line([(a, b), (c, d)]), AQUA[1], solid=True)          # pop lines
        st.extra |= line([(a, b), (c, d)])
    happy_eye(st, 22, 27)
    happy_eye(st, 36, 27)
    st.mouth('o', 30, 36)
    return key, st


# 4. Topsail Bandage: inner-TTTT keyhole, uncommon.
def topsail_bandage():
    key = 'pl-sung-4'
    st = Sticker()
    core = (17, 20, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 10, 8, 46, list(SAIL)), contour=True)
    st.stitch(body, col=PATCH[0])
    st.paint(rect(31, 8, 32, 12), '#7a4a2a', solid=True)                # mast tip over the top tab
    st.paint(rect(29, 7, 34, 7), '#7a4a2a', solid=True)
    st.extra |= rect(29, 7, 34, 12)
    patch = rect(27, 37, 36, 43)
    st.part(patch, PATCH[0], d=0, contour=True, shade=False)
    st.paint(rect(28, 38, 35, 38), PATCH[1])
    for x in (26, 37):
        st.paint(line([(x - 1, 39), (x + 1, 41)]) | line([(x + 1, 39), (x - 1, 41)]), UMBER)
    st.eye(23, 26, look=(0, -1))
    st.eye(36, 26, look=(0, -1))
    st.mouth('smile', 29, 32)
    st.paint(rect(20, 31, 22, 31) | rect(41, 31, 43, 31), BLUSH)
    return key, st


# 5. Porthole Peekaboo: inner-BBBB double, uncommon.
def porthole_peekaboo():
    key = 'pl-sung-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(HULL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=BRASS[1], skip=grow(holes, 3))
    for y in (20, 44):
        st.paint(rect(15, y, 48, y) & body & ~grow(holes, 2), '#8a6448')   # plank seams
    ring = disc(31.5, 31.5, 11) & ~disc(31.5, 31.5, 8)
    st.part(ring, BRASS[0], d=0, contour=True, shade=False)
    st.paint(ring & (CX + CY < 60), BRASS[1])
    for dx, dy in ((0, -9.5), (0, 9.5), (-9.5, 0), (9.5, 0)):
        st.dots([(int(31.5 + dx), int(31.5 + dy))], IRON)
    st.paint(disc(31.5, 31.5, 8), GLASS, solid=True)
    st.paint(disc(31.5, 31.5, 5.5), CREAMW, solid=True)                 # the giant peeking eye
    st.paint(disc(32.5, 32.5, 3), UMBER, solid=True)
    st.dots([(31, 30), (35, 34)], '#ffffff')
    st.paint(line([(27, 37), (29, 38), (36, 38)]) & ~disc(31.5, 31.5, 5.5), BRASS[1])
    return key, st


# 6. Hullmate Octopus: whimsy-octopus keyhole, rare.
def hullmate_octopus():
    key = 'pl-sung-6'
    st = Sticker()
    head = ellipse(32, 25, 14, 13)
    tab = knob('n', 'keyhole', 32, 13, r=3.0)
    arms = blank()
    for (x0, x1, x2) in ((22, 17, 13), (27, 25, 21), (37, 39, 43), (42, 47, 51)):
        arms |= line([(x0, 34), (x1, 46), (x2, 50)], w=3)
    arms |= disc(12, 49, 2.2) | disc(52, 49, 2.2)
    wave = line([(45, 28), (50, 22), (51, 16)], w=3) | disc(50, 14, 2.2)   # the waving curly arm
    left = line([(19, 30), (12, 34), (9, 40)], w=3)
    sil = head | tab | arms | wave | left
    st.part(sil, tex=fill(key, sil, 6, 8, 52, list(OCTO)), contour=True)
    for (x, y) in ((16, 47), (23, 46), (40, 46), (47, 47), (49, 21), (11, 37)):
        st.dots([(x, y)], '#f4b0a0')
    st.paint(disc(24, 26, 4.5), CREAMW, solid=True)
    st.paint(disc(40, 26, 4.5), CREAMW, solid=True)
    st.paint(disc(24, 26, 2), UMBER, solid=True)
    st.paint(disc(40, 26, 2), UMBER, solid=True)
    st.dots([(23, 25), (39, 25)], '#ffffff')
    st.paint(line([(20, 19), (26, 18)]) | line([(38, 18), (44, 19)]), UMBER)   # brows shot up
    st.mouth('o', 31, 32)
    st.paint(rect(18, 32, 20, 32) | rect(44, 32, 46, 32), BLUSH)
    st.sparkle(9, 9)
    st.sparkle(54, 40, big=False)
    st.sparkle(12, 22, big=False)
    return key, st


PALS = [sunnyfin_shoal, chestful_snore, bubble_bop, topsail_bandage, porthole_peekaboo, hullmate_octopus]

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
