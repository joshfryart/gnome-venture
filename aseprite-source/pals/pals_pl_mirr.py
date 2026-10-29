"""Puzzle Pals: THE MIRROR SALT FLAT (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-mirr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_mirr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: dawn salt-flat sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-the-mirror-salt-flat.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Nugget Nap          nugget amber              | heap of gold nuggets piled on its head, glints                | closed sleeping arcs, flat mouth
  2 Pinklegs Strut      dusk lavender             | two long pink flamingo legs striding out below, knees bent    | eyes glancing sideways, smirk
  3 Saltcrack Smile     salt crust white-grey     | hex salt-crust cracks curling into little smile lines         | ^ ^ happy eyes, wide grin
  4 Fluffy Pinkbelly    flamingo rose (+ cream)   | big scalloped cream fluff tummy, feather tufts on every tab   | big open eyes, cat mouth
  5 Peach Dawn Coin     peach sun (+ mauve)       | round sun coin over twin mountain peaks + their reflection    | calm half-lids, o mouth
  6 Puddle Dancer       hot pink flamingo         | whimsy flamingo twirling on one leg, mirrored reflection, glow| lash eye, beak, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-mirror-salt-flat'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-mirror-salt-flat-712d75')

AMBER = ('#c8902e', '#e4b04a')        # nugget amber
LAV = ('#7a72ac', '#9a92c8')          # dusk lavender
SALT = ('#c8ccd8', '#e8eaf0')         # salt crust
ROSE = ('#d0608e', '#e888ac')         # flamingo rose
PEACH = ('#f0a878', '#f9cc9a')        # peach sun
HOT = ('#e05a96', '#f488b8')          # rare flamingo
MAUVE = ('#6e5a8e', '#8e7aae')
CREAM2 = '#fbf0e4'
NUG = ('#f0c040', '#fff0a0', '#b07818')
LEG = ('#e8789e', '#b8507a')
BEAK = '#2a1a1a'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def sleep_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def lash_eye(st, x, y):
    st.sprite(['U.U.U', '.UUU.', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def nugget(st, x, y, r):
    st.part(disc(x, y, r), NUG[0], d=1, contour=True)
    st.dots([(int(x) - 1, int(y) - 1)], NUG[1])


# ------------------------------------------------------------------ 1. Nugget Nap: corner-TB keyhole, common.
def nugget_nap():
    key = 'pl-mirr-1'
    st = Sticker()
    core = (12, 22, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -6, 3.6), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 12, 42, list(AMBER)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x, y, r in ((36, 20, 3.4), (42, 21, 3.0), (39, 16, 3.0), (31, 21, 2.6), (46, 18, 2.2)):
        nugget(st, x, y, r)
    st.sparkle(44, 9, big=False)
    sleep_eye(st, 18, 34)
    sleep_eye(st, 33, 34)
    st.paint(rect(16, 38, 18, 38) | rect(38, 38, 40, 38), BLUSH)
    st.mouth('flat', 27, 41)
    return key, st


# ------------------------------------------------------------------ 2. Pinklegs Strut: edge-TTB keyhole, common.
def pinklegs_strut():
    key = 'pl-mirr-2'
    st = Sticker()
    core = (13, 13, 47, 40)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    for pts in (((23, 40), (19, 47), (24, 53)), ((37, 40), (41, 47), (44, 53))):
        st.part(line(list(pts), w=2), LEG[0], d=0, contour=True, shade=False)
    st.part(rect(21, 53, 27, 54), LEG[1], d=0, contour=True, shade=False)
    st.part(rect(42, 53, 48, 54), LEG[1], d=0, contour=True, shade=False)
    st.dots([(19, 47), (41, 47)], LEG[1])
    st.part(body, tex=fill(key, body, 13, 5, 44, list(LAV)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.eye(20, 22, look=(1, 0))
    st.eye(34, 22, look=(1, 0))
    st.mouth('smirk', 27, 31)
    return key, st


# ------------------------------------------------------------------ 3. Saltcrack Smile: inner-TBTB keyhole, common.
def saltcrack_smile():
    key = 'pl-mirr-3'
    st = Sticker()
    core = (14, 16, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 36, list(SALT)), contour=True)
    st.blank_shade(body, holes, width=1)
    crack = '#9a9cb4'
    for x0 in (17, 27, 37):   # tiny smile cracks along the bottom
        st.paint(line([(x0, 40), (x0 + 2, 42), (x0 + 5, 42), (x0 + 7, 40)]) & body & ~grow(holes, 1), crack)
    st.paint(line([(16, 20), (21, 22), (24, 19)]) & body, crack)
    st.paint(line([(40, 19), (44, 22), (47, 20)]) & body, crack)
    happy_eye(st, 20, 26)
    happy_eye(st, 37, 26)
    st.mouth('grin', 29, 31)
    return key, st


# ------------------------------------------------------------------ 4. Fluffy Pinkbelly: inner-TTTT keyhole, uncommon.
def fluffy_pinkbelly():
    key = 'pl-mirr-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(ROSE)), contour=True)
    belly = ellipse(31.5, 38, 9, 6)
    for x in (24, 28, 32, 36, 40):
        belly |= disc(x - 0.5 + (0 if x < 32 else 0), 33, 2.2)
    st.part(belly & shrink(body, 1), CREAM2, d=1, contour=True)
    st.stitch(body, col=CREAM2, skip=belly)                       # uncommon accent: cream fluff
    st.eye(23, 23)
    st.eye(36, 23)
    st.mouth('cat', 29, 30)
    return key, st


# ------------------------------------------------------------------ 5. Peach Dawn Coin: inner-BBBB double, uncommon.
def peach_dawn_coin():
    key = 'pl-mirr-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(PEACH)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=MAUVE[0], skip=grow(holes, 3))            # uncommon accent: mountain mauve
    sun = disc(31.5, 35, 5)
    st.part(sun, '#fff0c8', d=1, contour=True)
    mtn = blank()
    for i in range(8):
        mtn |= rect(17 + i, 42 - i, 46 - i, 42 - i) & (rect(17, 0, 30, 63) | rect(33, 0, 46, 63))
    mtn = mtn | mtn[:, ::-1]
    st.part(mtn & ~sun, MAUVE[0], d=0, contour=False, shade=False)
    st.paint(rect(17, 43, 46, 43), '#fff0c8')
    for i in range(0, 6, 2):
        st.paint(rect(20 + i, 45 + i // 2, 43 - i, 45 + i // 2) & ((XX % 2) == 0), MAUVE[1])
    st.eye(21, 18, lid=1)
    st.eye(38, 18, lid=1)
    st.mouth('o', 30, 25)
    return key, st


# ------------------------------------------------------------------ 6. Puddle Dancer: whimsy-saltflamingo keyhole, rare.
def puddle_dancer():
    key = 'pl-mirr-6'
    st = Sticker()
    bodyb = ellipse(34, 27, 12, 7)
    nk = line([(25, 24), (21, 17), (23, 11)], w=4)
    head = disc(25, 10, 5.5)
    tab = knob('e', 'keyhole', 45, 28, r=3.0)
    sil = bodyb | nk | head | tab
    leg = line([(34, 33), (34, 42)], w=1) | line([(35, 36), (40, 32)], w=1)
    st.part(leg, LEG[1], d=0, contour=True, shade=False)
    # puddle + reflection (mirror of body, paler)
    pud = ellipse(33, 46, 20, 3.5)
    st.part(pud, '#b8c8e8', d=0, contour=True, shade=False)
    ref = ellipse(34, 50, 10, 3) & ~pud | (ellipse(34, 48.5, 9, 2) & pud)
    st.paint(ellipse(34, 47.5, 9, 1.5), '#f4b0cc')
    st.part(ellipse(34, 52, 8, 2.2), '#f4b0cc', d=0, contour=True, shade=False)
    st.paint(rect(16, 45, 19, 45) | rect(46, 46, 49, 46), '#e8f0fc')
    st.part(sil, tex=fill(key, sil, 9, 4, 44, list(HOT)), contour=True)
    st.paint(ellipse(38, 25, 6, 3) & bodyb, '#ffc8dc')
    beak = rect(29, 10, 32, 12) | rect(32, 11, 33, 14)
    st.part(beak, BEAK, d=0, contour=False, shade=False)
    st.paint(rect(29, 10, 30, 11), '#f4ece0')
    # twirl swish marks
    st.paint(line([(12, 30), (16, 34)]) | line([(50, 37), (54, 34)]), '#fff0f6')
    lash_eye(st, 22, 7)
    st.paint(rect(20, 13, 22, 13), BLUSH)
    st.sparkle(8, 8)
    st.sparkle(52, 12, big=False)
    st.sparkle(12, 50, big=False)
    return key, st


PALS = [nugget_nap, pinklegs_strut, saltcrack_smile, fluffy_pinkbelly, peach_dawn_coin, puddle_dancer]

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
