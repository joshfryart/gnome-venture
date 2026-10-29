"""Puzzle Pals: ROOT-WRAPPED TEMPLE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wroo-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wroo.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: jungle-temple sprites, keyhole knobs, soft and curious. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-root-wrapped-temple.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Mossy Topslab       moss green                  | a grey stone capstone hat, moss dripping off its brim            | sleepy heavy lids, soft smile
  2 Elbow Root Hug      root red-brown              | a thick curling root arm hugging round its middle                | happy ^ ^ eyes, blush, open grin
  3 Vine Bead Dangle    canopy teal                 | a vine hanging from its top tab with a swinging green bead       | eyes look up at the bead, o mouth
  4 Dotted Script Panel temple slate (+ gold stitch)| a carved panel on its belly, rows of dotted script               | round reading glasses, flat mouth
  5 Archway Ember       warm sandstone (+ moss)     | an arched doorway on its belly with a little ember burning       | calm half lids, cat mouth
  6 Grinning Stone Face mossy stone + root arms     | whimsy temple head, square stone face held by two roots, glow   | big carved grin, square eyes
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-root-wrapped-temple'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-root-wrapped-temple-83a03a')

MOSS = ('#5a8a3e', '#78a852')          # moss green
ROOTC = ('#7a3a2a', '#9a5236')         # root red-brown
TEAL = ('#2f5a4e', '#43766a')          # canopy teal
SLATE = ('#6e747a', '#8a9096')         # temple slate
SANDS = ('#b89a6a', '#d0b482')         # warm sandstone
STONE = ('#8a8e88', '#a6aaa2')         # mossy stone (rare)
SLAB = ('#7c8288', '#5a6066', '#a2a8ac')
MOSSP = ('#5e9a3a', '#3e6e2a', '#8cc85a')
ROOTP = ('#6a2e22', '#4a1e18', '#9a5236')
VINE = ('#3f7a2a', '#2a5a1e', '#7ab84a')
EMB = ('#f5cf6a', '#f08a24', '#fff3c8')
DARK = '#2a1a14'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def moss_drips(st, x0, x1, y):
    m = rect(x0, y, x1, y + 1)
    for x in range(x0 + 1, x1, 4):
        m |= rect(x, y + 2, x, y + 3 + (x % 3 == 0))
    st.paint(m, MOSSP[0], solid=True)
    st.paint(rect(x0, y, x1, y) , MOSSP[2])
    return m


def root_band(st, pts, w=4):
    m = line(pts, w=w)
    st.part(m, ROOTP[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), ROOTP[2])
    return m


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def glasses(st, x, y, gap=13):
    for gx in (x, x + gap):
        ring = rect(gx - 2, y - 2, gx + 6, y + 6) & ~rect(gx - 1, y - 1, gx + 5, y + 5)
        st.paint(ring, GOLD_D)
    st.paint(rect(x + 7, y + 1, x + gap - 3, y + 1), GOLD_D)


# ------------------------------------------------------------------ 1. Mossy Topslab: corner-BB keyhole, common.
def mossy_topslab():
    key = 'pl-wroo-1'
    st = Sticker()
    core = (12, 22, 48, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 9, 3.0), e=('B', 'keyhole', 5, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 37, list(MOSS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#b8dc8a', skip=grow(holes, 3))
    cap = rect(8, 17, 33, 21) | rect(12, 11, 29, 16)                     # the stone capstone hat
    st.part(cap, SLAB[0], d=1, contour=True)
    st.paint(rect(12, 11, 29, 11) | rect(8, 17, 33, 17), SLAB[2])
    st.paint(rect(13, 16, 28, 16), SLAB[1])
    moss_drips(st, 9, 32, 20)
    st.paint(disc(16, 12, 1.5) | disc(25, 12, 1.2), MOSSP[0])
    st.eye(20, 31, lid=2)
    st.eye(34, 31, lid=2)
    st.paint(rect(17, 38, 19, 38) | rect(41, 38, 43, 38), BLUSH)
    st.mouth('smile', 28, 41)
    return key, st


# ------------------------------------------------------------------ 2. Elbow Root Hug: edge-TTB keyhole, common.
def elbow_root_hug():
    key = 'pl-wroo-2'
    st = Sticker()
    core = (14, 20, 46, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -3, 3.6), e=('T', 'keyhole', 3, 3.6), w=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 14, 14, 39, list(ROOTC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d89a7a', skip=grow(holes, 3))
    root_band(st, [(9, 50), (14, 44), (22, 42), (34, 43), (44, 41), (50, 36), (50, 30)], w=4)   # the hugging elbow root
    st.part(disc(49.5, 28, 3), ROOTP[2], d=1, contour=True)               # the root's knuckle end
    st.paint(rect(24, 41, 25, 44) | rect(38, 41, 39, 44), ROOTP[1])
    happy_eye(st, 20, 29)
    happy_eye(st, 34, 29)
    st.paint(disc(19, 35, 1.6) | disc(41, 35, 1.6), BLUSH)
    st.mouth('grin', 27, 34)
    return key, st


# ------------------------------------------------------------------ 3. Vine Bead Dangle: inner-TBTB keyhole, common.
def vine_bead_dangle():
    key = 'pl-wroo-3'
    st = Sticker()
    core = (14, 15, 49, 44)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 40, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8ac8b0', skip=grow(holes, 3))
    v = line([(36, 7), (41, 12), (44, 17), (44, 23)], w=1)              # the vine from the top tab
    st.paint(v, VINE[0], solid=True)
    st.paint(disc(40, 10, 1.2) | disc(45, 15, 1.2), VINE[2], solid=True)
    st.part(disc(44, 26, 3.2), VINE[2], d=1, contour=True)              # the green bead
    st.dots([(43, 25)], '#d8f0b0')
    st.eye(20, 24, look=(1, -1))
    st.eye(31, 24, look=(1, -1))
    st.mouth('o', 25, 33)
    st.paint(rect(17, 31, 19, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Dotted Script Panel: inner-TTTT double, uncommon.
def dotted_script_panel():
    key = 'pl-wroo-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SLATE)), contour=True)
    st.stitch(body, col=GOLD)                                           # uncommon accent: the lantern gold
    panel = rect(23, 33, 40, 43)
    st.part(panel, SLAB[1], d=0, contour=True, shade=False)
    for y in (35, 38, 41):
        for x in range(25, 39, 2):
            if (x * 7 + y) % 5 != 0:
                st.dots([(x, y)], CREAM)
    glasses(st, 22, 23, gap=15)
    st.eye(22, 23)
    st.eye(37, 23)
    st.mouth('flat', 31, 30)
    return key, st


# ------------------------------------------------------------------ 5. Archway Ember: inner-BBBB keyhole, uncommon.
def archway_ember():
    key = 'pl-wroo-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SANDS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=MOSSP[0], skip=grow(holes, 3))                  # uncommon accent: moss green
    arch = (ellipse(32, 38, 7, 7) & (CY <= 38)) | rect(25, 38, 38, 47)
    st.paint(grow(arch, 1) & ~arch, '#7a6040')
    st.paint(arch, DARK)
    fl = (ellipse(31.5, 43, 2.5, 3.2)) | rect(31, 38, 32, 40)
    st.paint(fl, EMB[1])
    st.paint(ellipse(31.5, 43.5, 1.2, 1.8), EMB[0])
    st.dots([(31, 44), (32, 44)], EMB[2])
    st.eye(21, 21, lid=1)
    st.eye(38, 21, lid=1)
    st.mouth('cat', 30, 29)
    st.paint(rect(17, 28, 19, 28) | rect(44, 28, 46, 28), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Grinning Stone Face: whimsy-temple keyhole, rare.
def grinning_stone_face():
    key = 'pl-wroo-6'
    st = Sticker()
    head = rect(19, 16, 44, 46) | rect(22, 10, 41, 16) | rect(26, 8, 37, 10)
    tab = knob('s', 'keyhole', 32, 47, r=3.4)
    body = head | tab
    st.part(body, tex=fill(key, body, 17, 8, 30, list(STONE)), contour=True)
    st.paint(rect(22, 10, 41, 10) | rect(19, 16, 44, 16), '#c2c6be')
    moss_drips(st, 23, 40, 11)
    # roots holding it from both sides like arms
    root_band(st, [(11, 53), (12, 40), (14, 30), (21, 24)], w=4)
    root_band(st, [(52, 53), (51, 40), (49, 30), (42, 24)], w=4)
    root_band(st, [(12, 40), (20, 44)], w=3)
    root_band(st, [(51, 40), (43, 44)], w=3)
    # carved face
    st.paint(rect(24, 24, 29, 28) | rect(34, 24, 39, 28), UMBER)
    st.paint(rect(25, 25, 26, 26) | rect(35, 25, 36, 26), CREAM)
    st.paint(rect(23, 21, 29, 21) | rect(34, 21, 40, 21), '#5a5e58')
    st.paint(rect(31, 27, 32, 33), '#6a6e68')
    st.sprite(['U........U', 'UCCCCCCCCU', '.URRRRRRU.', '..UUUUUU..'], 27, 35, {'U': UMBER, 'C': CREAM, 'R': MOUTH_RED},
              solid=False)
    st.paint(rect(21, 33, 23, 33) | rect(40, 33, 42, 33), BLUSH)
    st.sparkle(9, 9)
    st.sparkle(48, 9, big=False)
    st.sparkle(50, 18, big=False)
    return key, st


PALS = [mossy_topslab, elbow_root_hug, vine_bead_dangle, dotted_script_panel, archway_ember, grinning_stone_face]

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
