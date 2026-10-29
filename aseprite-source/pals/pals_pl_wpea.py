"""Puzzle Pals: PEARL DIVER COVE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wpea-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wpea.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: cove sprites, keyhole knobs, calm blue water. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell
of game/assets/img/jigsaw/places/wonder-pearl-diver-cove.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Bobbing Cherry Buoy   cherry red                  | white buoy band + rope loop up top, ripple line at base        | wide bright eyes, open grin
  2 Marmalade Minnow      marmalade orange            | tail fin out the side, top fin, bubbles                        | big look-ahead eye, o mouth
  3 Coral Fingerlings     coral pink                  | branching coral fingers waving on top, sand tufts              | ^ ^ happy eyes, cat mouth
  4 Oysterbed Choir       oyster slate (+ sand)       | ridged shell lines, three tiny music notes                     | sleepy shut lids, singing o mouth
  5 Pearl Peekaboo        sandy shell tan (+ pearl)   | shell lips opened a crack showing one glowing pearl            | one wink, smirk
  6 Whiskerwatch Diver    sea teal suit + skin        | whimsy diver, white beard, goggles, pearl held up, glow+spark  | goggle eyes, flat mouth, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-pearl-diver-cove'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-pearl-diver-cove-680a36')

CHERRY = ('#b8283a', '#d84656')        # cherry buoy red
MARM = ('#e07a24', '#f49c44')          # marmalade minnow
CORAL = ('#e0707a', '#f498a0')         # coral pink
OYSTER = ('#5e6a78', '#7c8898')        # oyster slate
SAND = ('#c8a878', '#e0c494')          # shell sand
TEAL = ('#2a7a84', '#3e98a0')          # diver suit teal (rare)
SEA = ('#3e8eb0', '#96cee4')
ROPE = '#8a6a3a'
PEARL = ('#eef0f4', '#ffffff', '#c8ccd8')
SKIN = ('#d89a74', '#f0b890')
BEARD = '#f4f0e8'
BLUSH = '#e89a9a'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['.....', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def shut_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def big_eye(st, x, y, look):
    st.sprite(['.UUUU.', 'UWWWWU', 'UWWWWU', 'UWWWWU', '.UUUU.'], x, y, {'U': UMBER, 'W': CREAM}, solid=False)
    px = x + 2 + look
    st.paint(rect(px, y + 1, px + 1, y + 3), UMBER, solid=True)
    st.dots([(px, y + 1)], '#ffffff')


def goggle_eye(st, x, y):
    st.part(disc(x, y, 3.2), '#c89a3a', d=0, contour=True, shade=False)
    st.paint(disc(x, y, 2.0), SEA[1], solid=True)
    st.paint(rect(x - 1, y - 1, x, y), UMBER, solid=True)
    st.dots([(x - 1, y - 1)], '#ffffff')


def pearl(st, x, y, r=2.2):
    st.part(disc(x, y, r), PEARL[0], d=1, contour=True)
    st.dots([(int(x) - 1, int(y) - 1)], PEARL[1])


# ------------------------------------------------------------------ 1. Bobbing Cherry Buoy: corner-TB keyhole, common.
def cherry_buoy():
    key = 'pl-wpea-1'
    st = Sticker()
    core = (12, 20, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 4, 3.0))
    loop = disc(30, 10, 4) & ~disc(30, 10, 2.2)
    st.part(loop, ROPE, d=0, contour=True, shade=False)
    st.part(body, tex=fill(key, body, 12, 11, 42, list(CHERRY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(12, 44, 48, 47) & body & ~grow(holes, 1), CREAM)
    st.paint(rect(12, 51, 48, 51) & body & (XX % 4 < 2), SEA[1])
    st.eye(18, 28)
    st.eye(34, 28)
    st.paint(rect(16, 36, 18, 36) | rect(40, 36, 42, 36), BLUSH)
    st.mouth('grin', 26, 36)
    return key, st


# ------------------------------------------------------------------ 2. Marmalade Minnow: edge-TTB keyhole, common.
def marmalade_minnow():
    key = 'pl-wpea-2'
    st = Sticker()
    core = (18, 22, 46, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    tail = poly([(18, 30), (8, 24), (10, 36), (8, 48), (18, 42)])
    st.part(tail & ~holes, MARM[0], d=1, contour=True)
    fin = poly([(24, 22), (28, 15), (34, 22)])
    st.part(fin, MARM[1], d=0, contour=True, shade=False)
    st.part(body, tex=fill(key, body, 16, 14, 38, list(MARM)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in (26, 30, 34):
        st.paint(line([(x, 40), (x + 2, 43)]) & body, CREAM)
    big_eye(st, 34, 28, 1)
    st.mouth('o', 40, 36)
    for x, y in ((55, 15), (52, 10), (56, 6)):
        st.dots([(x, y)], SEA[1])
    return key, st


# ------------------------------------------------------------------ 3. Coral Fingerlings: inner-TBTB keyhole, common.
def coral_fingerlings():
    key = 'pl-wpea-3'
    st = Sticker()
    core = (14, 22, 49, 50)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    fingers = blank()
    for bx, tx in ((18, 16), (24, 22), (38, 40), (44, 47)):
        fingers |= line([(bx, 23), (tx, 11)], w=3) | disc(tx, 11, 1.8)
    st.part(fingers & ~grow(body, 0), CORAL[1], d=1, contour=True)
    st.part(body, tex=fill(key, body, 14, 14, 38, list(CORAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(18, 45, 45, 47) & body & ~grow(holes, 1), SAND[1])
    happy_eye(st, 20, 29)
    happy_eye(st, 38, 29)
    st.mouth('cat', 30, 35)
    return key, st


# ------------------------------------------------------------------ 4. Oysterbed Choir: inner-TTTT double, uncommon.
def oysterbed_choir():
    key = 'pl-wpea-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(OYSTER)), contour=True)
    for y in (36, 40):
        st.paint(rect(20, y, 43, y) & body & (XX % 3 != 0), OYSTER[1])
    st.paint(rect(19, 32, 44, 32) & body, '#3a4250')
    st.stitch(body, col=SAND[1])                                    # uncommon accent: sand
    shut_eye(st, 22, 24)
    shut_eye(st, 37, 24)
    st.mouth('o', 30, 27)
    for x, y in ((10, 9), (52, 9)):
        st.paint(rect(x + 2, y - 4, x + 2, y), UMBER)
        st.paint(rect(x, y, x + 2, y + 1), UMBER)
    return key, st


# ------------------------------------------------------------------ 5. Pearl Peekaboo: inner-BBBB keyhole, uncommon.
def pearl_peekaboo():
    key = 'pl-wpea-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SAND)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=PEARL[2], skip=grow(holes, 3))               # uncommon accent: pearl
    gap = ellipse(31.5, 38, 12, 4)
    st.part(gap, '#4b312f', d=0, contour=True, shade=False)
    st.paint(rect(19, 34, 44, 34) & grow(gap, 1), SAND[0])
    pearl(st, 31.5, 38, 3.0)
    for x, y in ((31, 31), (25, 38), (38, 38)):
        st.dots([(x, y)], '#fff8d0')
    wink(st, 18, 19)
    st.eye(38, 18)
    st.mouth('smirk', 28, 26)
    return key, st


# ------------------------------------------------------------------ 6. Whiskerwatch Diver: whimsy-diver keyhole, rare.
def whiskerwatch_diver():
    key = 'pl-wpea-6'
    st = Sticker()
    torso = ellipse(30, 42, 14, 10)
    head = disc(30, 23, 9)
    arm = line([(42, 36), (50, 20)], w=4)
    tab = knob('s', 'keyhole', 30, 51, r=3.0)
    sil = torso | head | tab | arm
    st.part(sil, tex=fill(key, sil, 9, 8, 46, list(TEAL)), contour=True)
    st.part(ellipse(30, 25, 7, 6), SKIN[0], d=1, contour=True)
    st.paint(ellipse(30, 31, 7, 4) & ~rect(0, 0, 63, 27), BEARD, solid=True)
    st.paint(rect(22, 21, 38, 21), '#5a3a2a')
    goggle_eye(st, 26, 23)
    goggle_eye(st, 34, 23)
    st.mouth('flat', 29, 29)
    st.paint(rect(22, 27, 23, 27) | rect(37, 27, 38, 27), BLUSH)
    st.part(disc(50, 19, 2.5), SKIN[1], d=0, contour=True, shade=False)
    pearl(st, 50, 14, 3.0)
    st.paint(rect(18, 44, 42, 45) & torso, CREAM)
    st.sparkle(8, 10)
    st.sparkle(56, 6, big=False)
    st.sparkle(9, 52, big=False)
    return key, st


PALS = [cherry_buoy, marmalade_minnow, coral_fingerlings, oysterbed_choir, pearl_peekaboo, whiskerwatch_diver]

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
