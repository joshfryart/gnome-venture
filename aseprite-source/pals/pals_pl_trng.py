"""Puzzle Pals: THOUSAND RINGS STUMP (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-trng-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_trng.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: forest-stump sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-thousand-rings-stump.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Redcap Speck          scarlet red                 | white-spotted mushroom cap worn on top, stalk legs          | wide eyes, o mouth
  2 Leaf Raft             leaf green                  | leaf vein + stem prow, ripple lines beneath like a pond      | sleepy half lids, smile
  3 Cellar Apple Gleam    cellar teal-dusk            | glowing red apple held in an arched little doorway           | eyes looking down, cat mouth
  4 Looking Glass Sparkle ring-wood cream (+ gold)    | gold magnifying glass lens over one eye, tree-ring arcs      | one magnified eye, tooth grin
  5 Velvet Hollow         velvet plum dusk (+ glints) | dark oval hollow in the belly with tiny gold glints         | happy closed arcs, smirk
  6 Tuftear Chipmunk      chestnut, purple socks      | whimsy chipmunk, tufted ears, back stripes, white orb, glow  | big eyes up-right, grin, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-thousand-rings-stump'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-thousand-rings-stump-668470')

SCAR = ('#c03a34', '#e0584a')
LEAF = ('#4f8a3e', '#74ac56')
TEAL = ('#3a6670', '#558690')
CREAMW = ('#d1ac6d', '#e8cc94')
PLUM = ('#5a3a5e', '#7a5680')
CHEST = ('#a0603a', '#c07e50')
WHITE = '#f8f4ea'
STALK = ('#e0d4b8', '#f4ecd8')
APPLE = ('#c8282c', '#f05048', '#ffd8a0')
DOOR = ('#2a1e1a', '#6a4a30')
GLASS = ('#c89a28', '#f0cc50', '#cfe8f0')
RING = '#a8844c'
HOLLOW = ('#1e141e', '#3a2838')
SOCK = ('#7a4aa8', '#9a6ac8')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


# 1. Redcap Speck: corner-TT keyhole, common.
def redcap_speck():
    key = 'pl-trng-1'
    st = Sticker()
    core = (12, 24, 42, 50)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 12, 16, 40, list(SCAR)), contour=True)
    for (x, y) in ((16, 28), (34, 27), (25, 46), (37, 44)):      # white spots
        st.paint(disc(x, y, 1.6) & body, WHITE)
    for x in (18, 32):                                            # stalk legs
        leg = rect(x, 51, x + 3, 55)
        st.part(leg, STALK[0], d=0, contour=True, shade=False)
        st.paint(rect(x, 51, x, 55), STALK[1])
    st.eye(17, 33)
    st.eye(30, 33)
    st.mouth('o', 25, 41)
    return key, st


# 2. Leaf Raft: edge-TBB keyhole, common.
def leaf_raft():
    key = 'pl-trng-2'
    st = Sticker()
    core = (15, 18, 47, 44)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 10, 36, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(31, 36, 31, 43) & body, '#2f5a26')               # midrib
    st.paint(line([(31, 40), (24, 37)]) | line([(31, 40), (38, 37)]), '#2f5a26')
    stem = line([(47, 44), (52, 47)], w=2)
    st.part(stem, '#6a4a2a', d=0, contour=True, shade=False)
    for y, x0 in ((48, 14), (51, 22), (48, 38)):                  # pond ripples
        st.paint(rect(x0, y, x0 + 6, y), CREAMW[0])
        st.extra |= rect(x0, y, x0 + 6, y)
    st.eye(22, 25, lid=2)
    st.eye(35, 25, lid=2)
    st.mouth('smile', 28, 32)
    return key, st


# 3. Cellar Apple Gleam: inner-TBTB keyhole, common.
def cellar_apple():
    key = 'pl-trng-3'
    st = Sticker()
    core = (14, 17, 49, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 10, 36, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    door = (rect(24, 34, 39, 46) | disc(31.5, 34, 7.5)) & (YY <= 46) & body
    st.paint(door, DOOR[0], solid=True)
    st.paint(door & ~shrink(door, 1), DOOR[1], solid=True)
    ap = disc(31.5, 40, 4.2)
    st.paint(grow(ap, 1) & door, '#5a3a20', solid=True)
    st.paint(ap, APPLE[0], solid=True)
    st.paint(disc(30, 39, 2.2), APPLE[1], solid=True)
    st.paint(rect(29, 38, 29, 38), APPLE[2], solid=True)
    st.paint(rect(31, 34, 32, 35), '#6a4a2a', solid=True)
    st.paint(rect(33, 34, 35, 34), '#74ac56', solid=True)
    st.eye(20, 22, look=(0, 1))
    st.eye(39, 22, look=(0, 1))
    st.mouth('cat', 29, 28)
    return key, st


# 4. Looking Glass Sparkle: inner-TTTT keyhole, uncommon (Plus, symmetric).
def looking_glass():
    key = 'pl-trng-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 16, 16, 32, list(CREAMW)), contour=True)
    for r in (6, 10, 14):                                          # tree-ring arcs on the belly
        st.paint(body & ~disc(31.5, 50, r) & disc(31.5, 50, r + 1) & (YY > 36), RING)
    lens = disc(37, 26, 6)
    st.paint(grow(lens, 1), GLASS[0], solid=True)
    st.paint(disc(37, 26, 5), GLASS[1], solid=True)
    st.paint(disc(37, 26, 4), GLASS[2], solid=True)
    st.paint(line([(41, 31), (45, 36)], w=2), '#6a4a2a', solid=True)
    st.eye(20, 23)
    st.eye(35, 24)
    st.mouth('tooth', 26, 32)
    return key, st


# 5. Velvet Hollow: inner-BBBB double, uncommon (Ring, symmetric).
def velvet_hollow():
    key = 'pl-trng-5'
    st = Sticker()
    core = (12, 12, 51, 51)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 12, 40, list(PLUM)), contour=True)
    st.blank_shade(body, holes, width=1)
    hol = ellipse(31.5, 38, 11, 6)
    st.paint(grow(hol, 1), CREAMW[0], solid=True)
    st.paint(hol, HOLLOW[0], solid=True)
    st.paint(hol & (YY >= 40), HOLLOW[1], solid=True)
    for (x, y) in ((25, 37), (31, 39), (37, 36), (34, 41), (28, 41)):
        st.paint(rect(x, y, x, y), GOLD_L, solid=True)
    happy_arc(st, 21, 22)
    happy_arc(st, 38, 22)
    st.mouth('smirk', 29, 27)
    return key, st


# 6. Tuftear Chipmunk: whimsy-chipmunk keyhole, rare.
def tuftear_chipmunk():
    key = 'pl-trng-6'
    st = Sticker()
    head = disc(30, 26, 12)
    ears = disc(20, 15, 3.6) | disc(40, 15, 3.6)
    tufts = poly([(18, 13), (19, 6), (23, 12)]) | poly([(37, 12), (41, 6), (42, 13)])
    belly = ellipse(30, 41, 11, 8)
    tab = knob('s', 'keyhole', 30, 48, r=2.6)
    body = head | ears | tufts | belly | tab
    st.part(body, tex=fill(key, body, 14, 6, 40, list(CHEST)), contour=True)
    st.paint(disc(20, 15, 1.8) | disc(40, 15, 1.8), '#e0a888')
    st.paint(rect(29, 15, 31, 19) & head, '#5a321e')                 # head stripe
    st.paint(ellipse(30, 42, 6, 5), '#f0d8b0')
    for x in (21, 36):                                             # purple socks
        s = rect(x, 47, x + 4, 50)
        st.part(s, SOCK[0], d=0, contour=True, shade=False)
        st.paint(rect(x, 47, x + 4, 47), SOCK[1])
    orb = disc(30, 37, 3.4)
    st.paint(grow(orb, 1), UMBER, solid=True)
    st.paint(orb, WHITE, solid=True)
    st.paint(rect(29, 35, 29, 35), '#cfe8f0', solid=True)
    st.eye(23, 21, look=(1, -1))
    st.eye(33, 21, look=(1, -1))
    st.mouth('grin', 28, 29)
    st.paint(rect(19, 28, 21, 28) | rect(39, 28, 41, 28), BLUSH)
    st.sparkle(48, 8)
    st.sparkle(9, 30, big=False)
    st.sparkle(50, 42, big=False)
    return key, st


PALS = [redcap_speck, leaf_raft, cellar_apple, looking_glass, velvet_hollow, tuftear_chipmunk]

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
        print('%-10s %-22s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
