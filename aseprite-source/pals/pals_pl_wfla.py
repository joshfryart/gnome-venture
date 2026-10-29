"""Puzzle Pals: FLAMINGO SHALLOWS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wfla-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wfla.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: lake sprites, keyhole knobs, bright day. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-flamingo-shallows.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Peppermint Awning     peppermint red              | red/cream awning stripes + scalloped valance along its brow    | wide bright eyes, open grin
  2 Quill Bouquet         twine straw                 | fan of pink feathers sprouting from the top, twine bow         | sleepy half-lids, small smile
  3 Faraway Pink Fuzz     lake sky blue               | far flock as pink fuzz dots + ripple lines across the water    | ^ ^ happy eyes, o mouth
  4 Long-Neck Lineup      shore sand tan (+ rose)     | four pink necks peeking over, one on each tab, beaks out       | eyes glancing up, cat mouth
  5 Question-Mark Neck    deep magenta (+ gold)       | a single neck curled into a ? above, floating ? dot below      | one eye raised (wink), smirk
  6 Stallkeeper Plumeling coral flamingo + cream bib  | whimsy flamingo on one leg, holds a plume, tally beads, glow   | joyful lashes, beak grin, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-flamingo-shallows'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-flamingo-shallows-707c2a')

MINT = ('#c8343c', '#e2565a')          # peppermint red
STRAW = ('#c8a868', '#e0c488')         # twine straw
LAKE = ('#7ab4d4', '#a2d0e8')          # lake sky blue
SAND = ('#a88a5e', '#c4a678')          # shore sand
MAG = ('#9a2e6e', '#ba4a8a')           # deep magenta
CORAL = ('#ee8a8a', '#f8acaa')         # coral flamingo (rare)
CREAM = '#fbf0dc'
FEATH = ('#f07ab0', '#ffb0d0', '#c84a88')
NECK = ('#ec86b2', '#c85a8e')
BEAK = '#2a1a1a'
GOLD = ('#f0c84a', '#fff0a0')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def lash_eye(st, x, y):
    st.sprite(['U.U.U', '.UUU.', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def neck(st, pts, head, beak_dir):
    st.part(line(pts, w=2), NECK[0], d=0, contour=True, shade=False)
    hx_, hy = head
    st.part(disc(hx_, hy, 2.6), NECK[0], d=1, contour=True)
    bx = hx_ + 2 * beak_dir
    st.paint(rect(min(bx, bx + beak_dir), hy, max(bx, bx + beak_dir), hy + 1), BEAK, solid=True)
    st.dots([(hx_, hy - 1)], UMBER)


# ------------------------------------------------------------------ 1. Peppermint Awning: corner-TB keyhole, common.
def peppermint_awning():
    key = 'pl-wfla-1'
    st = Sticker()
    core = (12, 16, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -4, 3.6), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 7, 46, list(MINT)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in range(14, 48, 8):
        st.paint(rect(x, 16, x + 3, 53) & body & ~grow(holes, 1), CREAM)
    val = rect(12, 16, 48, 20)
    for x in range(12, 49, 6):
        val |= disc(x + 3, 21, 2.6)
    st.part(val & ~holes, MINT[0], d=1, contour=True)
    st.paint(rect(12, 16, 48, 16) & body, CREAM)
    st.paint(rect(19, 27, 43, 42), MINT[1])
    st.eye(21, 30)
    st.eye(35, 30)
    st.paint(rect(18, 38, 20, 38) | rect(41, 38, 43, 38), BLUSH)
    st.mouth('grin', 26, 38)
    return key, st


# ------------------------------------------------------------------ 2. Quill Bouquet: edge-TTB keyhole, common.
def quill_bouquet():
    key = 'pl-wfla-2'
    st = Sticker()
    core = (12, 23, 45, 53)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 3, 3.6), w=('B', 'keyhole', 3, 3.0))
    # feather fan behind the top tab
    for ang_pts in (((30, 21), (21, 11)), ((30, 21), (26, 8)), ((30, 21), (34, 8)), ((30, 21), (39, 11))):
        a, b = ang_pts
        f = line([a, b], w=3)
        st.part(f, FEATH[0], d=0, contour=True, shade=False)
        st.paint(line([a, b]) & f, FEATH[2])
        st.paint(disc(b[0], b[1], 1.6), FEATH[1], solid=True)
    st.part(body, tex=fill(key, body, 13, 15, 38, list(STRAW)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#9a7a44', skip=grow(holes, 3))
    bow = ellipse(26, 25, 3.2, 2) | ellipse(34, 25, 3.2, 2)
    st.part(bow, '#8a6a3a', d=1, contour=True)
    st.paint(disc(30, 25.5, 1.3), '#6a4a2a', solid=True)
    st.eye(20, 33, lid=2)
    st.eye(35, 33, lid=2)
    st.mouth('smile', 27, 41)
    return key, st


# ------------------------------------------------------------------ 3. Faraway Pink Fuzz: inner-TBTB keyhole, common.
def faraway_pink_fuzz():
    key = 'pl-wfla-3'
    st = Sticker()
    core = (14, 16, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 36, list(LAKE)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (40, 44):
        st.paint(rect(18, y, 46, y) & body & ~grow(holes, 1) & ((XX // 3) % 2 == 0), '#e8f4fa')
    for x, y in ((18, 19), (23, 17), (27, 20), (36, 18), (41, 20), (45, 17), (32, 16)):
        st.paint(disc(x, y, 1.4), FEATH[1])
        st.dots([(x, y)], FEATH[0])
        st.paint(rect(x, y + 2, x, y + 3), FEATH[2])
    happy_eye(st, 20, 26)
    happy_eye(st, 35, 26)
    st.mouth('o', 30, 33)
    return key, st


# ------------------------------------------------------------------ 4. Long-Neck Lineup: inner-TTTT double, uncommon.
def long_neck_lineup():
    key = 'pl-wfla-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SAND)), contour=True)
    st.stitch(body, col=FEATH[2])                                  # uncommon accent: flamingo rose
    neck(st, [(30, 13), (30, 10)], (31, 9), 1)
    neck(st, [(33, 13), (33, 10)], (32, 9), -1)
    neck(st, [(13, 30), (11, 27)], (11, 25), -1)
    neck(st, [(50, 30), (52, 27)], (52, 25), 1)
    st.eye(23, 26, look=(0, -1))
    st.eye(36, 26, look=(0, -1))
    st.paint(rect(21, 33, 23, 33) | rect(40, 33, 42, 33), BLUSH)
    st.mouth('cat', 30, 35)
    return key, st


# ------------------------------------------------------------------ 5. Question-Mark Neck: inner-BBBB keyhole, uncommon.
def question_mark_neck():
    key = 'pl-wfla-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(MAG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLD[0], skip=grow(holes, 3))              # uncommon accent: sun gold
    q = line([(32, 46), (32, 41), (37, 37), (38, 31), (34, 28), (29, 28), (26, 31), (26, 33)], w=2)
    st.part(q, NECK[0], d=0, contour=True, shade=False)
    st.part(disc(32, 50, 1.8), GOLD[0], d=1, contour=True)
    wink(st, 18, 20)
    st.eye(40, 19, lid=1)
    st.mouth('smirk', 18, 27)
    return key, st


# ------------------------------------------------------------------ 6. Stallkeeper Plumeling: whimsy-stallbird keyhole, rare.
def stallkeeper_plumeling():
    key = 'pl-wfla-6'
    st = Sticker()
    bodyb = ellipse(34, 37, 15, 9)
    nk = line([(24, 32), (20, 24), (22, 16)], w=4)
    head = disc(25, 14, 6.5)
    tab = knob('e', 'keyhole', 48, 38, r=3.0)
    leg = line([(34, 46), (34, 53)], w=1) | line([(34, 52), (39, 49)], w=1)
    st.part(leg, '#c85a6a', d=0, contour=True, shade=False)
    st.part(rect(31, 53, 37, 54), '#c85a6a', d=0, contour=True, shade=False)
    sil = bodyb | nk | head | tab
    st.part(sil, tex=fill(key, sil, 11, 8, 46, list(CORAL)), contour=True)
    st.paint(ellipse(30, 41, 7, 4) & bodyb, CREAM)
    st.paint(ellipse(41, 36, 6, 3.5) & bodyb, FEATH[0])
    beak = rect(31, 14, 34, 16) | rect(34, 15, 35, 18)
    st.part(beak, BEAK, d=0, contour=False, shade=False)
    st.paint(rect(31, 14, 32, 15), '#f4ece0')
    # held plume
    pl = line([(17, 42), (10, 30)], w=2)
    st.part(pl, FEATH[1], d=0, contour=True, shade=False)
    st.paint(disc(10, 29, 2.2), FEATH[0], solid=True)
    st.part(line([(19, 40), (24, 40)], w=2), CORAL[0], d=0, contour=True, shade=False)
    # tally beads on the bib
    for x in (27, 30, 33):
        st.dots([(x, 44)], GOLD[0])
    lash_eye(st, 22, 11)
    st.paint(rect(20, 17, 22, 17), BLUSH)
    st.sparkle(6, 8)
    st.sparkle(52, 10, big=False)
    st.sparkle(54, 54, big=False)
    return key, st


PALS = [peppermint_awning, quill_bouquet, faraway_pink_fuzz, long_neck_lineup, question_mark_neck, stallkeeper_plumeling]

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
