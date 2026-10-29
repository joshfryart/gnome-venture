"""Puzzle Pals: THE AMBER WOODS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-ambr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_ambr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: golden-hour Baltic wood sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-the-amber-woods.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Sapdrop Bead        golden sap honey            | glossy sap drop hanging off the top, drip trail + highlight     | wide bright eyes, small smile
  2 Barkband Ladder     birch white (+ black bands) | black bark bands as rungs, tiny beetle climbing                 | sleepy half-lids, flat mouth
  3 Redcap Pips         toadstool crimson           | two white-spotted red toadstool caps on top, whisper "shh" dots | ^ ^ happy eyes, o mouth
  4 Pinetop Procession  pine green (+ low sun gold) | row of dark pine tops along the brow, gold sun disc behind      | eyes glancing up, cat mouth
  5 Sprout Nook         amber brown (+ leaf green)  | dark hollow in the middle with a green sprout, seed flecks      | eyes glancing sideways, grin
  6 Plumetail Digger    russet squirrel + cream     | whimsy squirrel, huge plume tail, tufted ears, wee trowel, glow | big eyes w/ blush, tooth grin
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-amber-woods'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-amber-woods-f02aa5')

SAP = ('#e0a030', '#f6c860')
BIRCH = ('#d8d4c8', '#f2efe6')
TOAD = ('#b8283a', '#d84a50')
PINE = ('#2e5a3a', '#467a4c')
AMBER = ('#9a5a24', '#c07a34')
SQUIR = ('#c4602a', '#e07e3c')
CREAM = '#fbf0dc'
BARK = '#2a2420'
SUN = ('#f0c84a', '#fff0a0')
LEAF = ('#5a9a3a', '#8ac850')
HOLLOW = '#3a2214'
BLUSH = '#f0a0a0'
STEEL = ('#8a96a0', '#c4ccd4')


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


# 1. Sapdrop Bead: corner-BB keyhole, common.
def sapdrop_bead():
    key = 'pl-ambr-1'
    st = Sticker()
    core = (12, 14, 50, 50)
    body, holes = piece_blanks(core, n='F', w='F', e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 14, 38, list(SAP)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(16, 18, 17, 24) | rect(18, 17, 20, 17), '#fff4c8')
    st.part(rect(39, 14, 41, 19) | disc(40, 22, 3.2), '#b86a14', d=0, contour=True, shade=False)
    st.dots([(39, 21)], '#fff4c8')
    st.eye(20, 28)
    st.eye(32, 28)
    st.mouth('smile', 25, 38)
    return key, st


# 2. Barkband Ladder: edge-TBB keyhole, common.
def barkband_ladder():
    key = 'pl-ambr-2'
    st = Sticker()
    core = (14, 18, 47, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 40, list(BIRCH)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (24, 42, 48):
        st.paint(rect(15, y, 46, y + 1) & body & ~grow(holes, 1) & ((XX // 4) % 3 != 2), BARK)
    st.part(ellipse(42, 37, 2.5, 2), '#3a6a5a', d=0, contour=True, shade=False)
    st.dots([(41, 34), (43, 34)], BARK)
    st.eye(21, 29, lid=2)
    st.eye(34, 29, lid=2)
    st.mouth('flat', 29, 37)
    return key, st


# 3. Redcap Pips: inner-TBTB keyhole, common.
def redcap_pips():
    key = 'pl-ambr-3'
    st = Sticker()
    core = (14, 18, 49, 45)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 10, 36, list(TOAD)), contour=True)
    st.blank_shade(body, holes, width=1)
    for cx in (21, 42):
        st.part(rect(cx - 1, 16, cx + 1, 20), CREAM, d=0, contour=True, shade=False)
        cap = ellipse(cx, 15, 5, 3.5) & (YY <= 16)
        st.part(cap, TOAD[1], d=0, contour=True, shade=False)
        st.dots([(cx - 2, 13), (cx + 2, 14)], CREAM)
    st.dots([(27, 41), (31, 42), (35, 41)], CREAM)
    happy_eye(st, 21, 27)
    happy_eye(st, 36, 27)
    st.mouth('o', 30, 35)
    return key, st


# 4. Pinetop Procession: inner-TTTT keyhole, uncommon.
def pinetop_procession():
    key = 'pl-ambr-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(PINE)), contour=True)
    st.paint(disc(31.5, 23, 4) & body, SUN[0])
    st.paint(disc(30.5, 22, 1.5) & body, SUN[1])
    for cx in (21, 26, 31.5, 37, 42):
        tri = (YY >= 19) & (YY <= 29) & (abs(XX - cx) <= (YY - 19) * 0.3)
        st.paint(tri & body, '#1a3a24')
    st.stitch(body, col=SUN[0])
    st.eye(23, 31, look=(0, -1))
    st.eye(36, 31, look=(0, -1))
    st.mouth('cat', 29, 39)
    return key, st


# 5. Sprout Nook: inner-BBBB double, uncommon.
def sprout_nook():
    key = 'pl-ambr-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(AMBER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(ellipse(31.5, 41, 7, 4), HOLLOW, d=0, contour=True, shade=False)
    st.part(line([(31, 40), (31, 34)], w=2), LEAF[0], d=0, contour=False, shade=False)
    st.part(ellipse(28, 33, 3, 1.6) | ellipse(35, 33, 3, 1.6), LEAF[1], d=0, contour=True, shade=False)
    st.dots([(17, 18), (46, 18), (17, 45), (46, 45)], '#f0bb72')
    st.eye(21, 21, look=(1, 0))
    st.eye(37, 21, look=(-1, 0))
    st.mouth('grin', 29, 28)
    return key, st


# 6. Plumetail Digger: whimsy-redsquirrel keyhole, rare.
def plumetail_digger():
    key = 'pl-ambr-6'
    st = Sticker()
    tail = disc(47, 22, 9) | ellipse(44, 36, 7, 9)
    head = disc(26, 26, 10)
    ears = poly([(17, 19), (18, 9), (23, 17)]) | poly([(29, 17), (34, 9), (35, 19)])
    torso = ellipse(28, 40, 9, 8)
    tab = knob('s', 'keyhole', 28, 47, r=3.0)
    st.part(tail, tex=fill(key, tail, 36, 12, 22, list(SQUIR)), contour=True)
    st.paint(ellipse(48, 20, 4, 5) & tail, SQUIR[1])
    sil = head | ears | torso | tab
    st.part(sil, tex=fill(key, sil, 15, 9, 42, list(SQUIR)), contour=True)
    st.paint(ellipse(28, 42, 5, 4) & torso, CREAM)
    st.paint(disc(18, 11, 1.2) | disc(34, 11, 1.2), '#8a3a1a')
    st.part(rect(12, 37, 13, 43), '#7a4a2a', d=0, contour=True, shade=False)
    st.part(poly([(10, 43), (15, 43), (14, 48), (11, 48)]), STEEL[1], d=0, contour=True, shade=False)
    st.eye(19, 23)
    st.eye(29, 23)
    st.paint(rect(16, 30, 18, 30) | rect(34, 30, 36, 30), BLUSH)
    st.mouth('tooth', 24, 30)
    st.sparkle(6, 8)
    st.sparkle(52, 50, big=False)
    st.sparkle(10, 30, big=False)
    return key, st


PALS = [sapdrop_bead, barkband_ladder, redcap_pips, pinetop_procession, sprout_nook, plumetail_digger]

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
