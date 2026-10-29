"""Puzzle Pals: CEDAR SANCTUARY (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wced-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wced.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: misty cedar sprites, keyhole knobs, quiet and soft. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy, zzz); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-cedar-sanctuary.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Misty Moonpeek       pale moon cream               | a pale crescent moon it hides behind + two mist wisps          | shy side glance, blush, tiny smile
  2 Fireside Flickerling ember orange                  | a flame tuft on its head, holding one cedar needle, ring stones | happy ^ ^ eyes, open grin
  3 Toadstool Tiptoe     toadstool red-rose            | a white-spotted red cap + stalk on top, tiptoe pointed feet     | startled wide eyes, o mouth
  4 Far Snowcaps         mountain lavender (+ snow)    | two snowy peaks on the north tab, one per side, centred         | sleepy heavy lids, soft smile
  5 Mossring Cushion     moss green (+ cushion red)    | the round red cushion with a gold seed-button on its lap        | content closed arcs, cat mouth
  6 Branch Meditator     carved cedar brown            | whimsy wood spirit cross-legged on a cedar branch, hum notes   | serene shut lines, flat hum mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-cedar-sanctuary'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-cedar-sanctuary-ff7cde')

MOONC = ('#d8d2b4', '#ece6cc')         # pale moon cream
EMBERO = ('#d8803a', '#eca25a')        # ember orange
ROSE = ('#c0504a', '#d8706a')          # toadstool red
LAV = ('#8a88b0', '#a8a6c8')           # mountain lavender
MOSS = ('#4f8a4a', '#6aa260')          # moss green
WOOD = ('#8a5a34', '#a8744a')          # carved cedar brown (rare)
MIST = '#e4eef2'
CEDAR = ('#2f6a4a', '#1f4a34', '#55a168')
FLAME = ('#f0a030', '#c05020', '#ffe070')
STONE = ('#8a8c90', '#5a5c60', '#b4b6ba')
CAP = ('#d03a3a', '#902424', '#f06a5a')
SNOWW = ('#f4f6fa', '#c8d4e4')
PEAK = ('#6a6a94', '#4a4a70')
CUSH = ('#c03a3a', '#842222', '#e86060')
GOLDB = ('#f0c040', '#a8781a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def extra(st, x, y, col):
    st.px[y, x] = hx(col)
    st.extra[y, x] = True


def wisp(st, x, y, L=9):
    """A soft horizontal mist curl (border-only)."""
    for i in range(L):
        extra(st, x + i, y + (1 if i in (0, L - 1) else 0), MIST)
    for i in range(2, L - 3):
        extra(st, x + i + 2, y + 2, MIST)


def crescent(st, cx, cy, r):
    m = disc(cx, cy, r) & ~disc(cx + r * 0.55, cy - r * 0.25, r * 0.85)
    st.part(m, '#f4eebc', d=1, contour=True)
    st.paint(m & ~shift(m, 1, 0), '#fffbe0')
    return m


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def calm_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def shut_eye(st, x, y):
    st.paint(rect(x, y, x + 4, y), UMBER, solid=True)


def flame_tuft(st, cx, by):
    m = poly([(cx - 5, by), (cx - 3, by - 6), (cx - 1, by - 4), (cx, by - 10), (cx + 2, by - 4), (cx + 4, by - 7), (cx + 5, by)])
    st.part(m, FLAME[0], d=1, contour=True)
    st.paint(shrink(m, 1) & (CY > by - 5), FLAME[2])
    return m


def needle(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=1)
    st.paint(m, CEDAR[2], solid=True)
    st.dots([(x1, y1)], CEDAR[0])
    st.sil |= m


def ring_stone(st, cx, cy):
    m = ellipse(cx, cy, 3.5, 2.2)
    st.part(m, STONE[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), STONE[2])


def toad_cap(st, cx, by, rx, h):
    stem = rect(cx - 2, by - 3, cx + 1, by + 1)
    st.part(stem, '#efe6d0', d=1, contour=True)
    m = ellipse(cx - 0.5, by - 3, rx, h) & (CY <= by - 3)
    st.part(m, CAP[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), CAP[2])
    for dx, dy in ((-4, -3), (1, -6), (5, -2), (-1, -2)):
        st.paint(disc(cx + dx, by - 3 + dy, 1.0), '#fff8ec', solid=True)


def peaks(st, cx, by):
    for ox in (-6, 6):
        m = poly([(cx + ox - 6, by), (cx + ox, by - 9), (cx + ox + 6, by)])
        st.part(m, PEAK[0], d=1, contour=True)
        st.paint(m & (CY < by - 5), SNOWW[0], solid=False)
        st.paint(m & (CX > cx + ox + 0.5) & (CY >= by - 5), PEAK[1])


def cushion(st, cx, cy):
    m = ellipse(cx, cy, 10, 4.5)
    st.part(m, CUSH[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), CUSH[2])
    st.paint(line([(cx - 9, cy), (cx - 3, cy)]) | line([(cx + 3, cy), (cx + 9, cy)]), CUSH[1])
    st.button(cx - 2, cy - 2, col=GOLDB[0], dark=GOLDB[1])


def note(st, x, y):
    st.sprite(['.CC', '.C.', 'CC.', 'CC.'], x, y, {'C': CREAM}, solid=True)


# ------------------------------------------------------------------ 1. Misty Moonpeek: corner-BB keyhole, common.
def misty_moonpeek():
    key = 'pl-wced-1'
    st = Sticker()
    core = (14, 20, 46, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 2, 3.0), e=('B', 'keyhole', 0, 3.0))
    crescent(st, 49, 14, 7)
    st.part(body, tex=fill(key, body, 14, 20, 33, list(MOONC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8a088', skip=grow(holes, 3))
    st.eye(20, 30, look=(1, 0), lid=1)
    st.eye(33, 30, look=(1, 0), lid=1)
    st.paint(disc(19, 38, 2) | disc(41, 38, 2), BLUSH)
    st.mouth('smile', 27, 39)
    wisp(st, 5, 56, 10)
    wisp(st, 44, 56, 9)
    return key, st


# ------------------------------------------------------------------ 2. Fireside Flickerling: edge-TBB keyhole, common.
def fireside_flickerling():
    key = 'pl-wced-2'
    st = Sticker()
    core = (14, 20, 49, 47)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', -2, 3.0), w=('B', 'keyhole', -2, 3.0))
    st.part(body, tex=fill(key, body, 14, 20, 36, list(EMBERO)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8a4a1a', skip=grow(holes, 3))
    flame_tuft(st, 32, 15)
    st.eye(21, 27, look=(0, -1))
    st.eye(37, 27, look=(0, -1))
    st.mouth('grin', 30, 35)
    st.paint(disc(19, 35, 1.6) | disc(46, 35, 1.6), BLUSH)
    st.part(ellipse(48, 41, 2.6, 2.2), EMBERO[0], d=1, contour=True)   # stubby paw holding the needle
    needle(st, 49, 40, 54, 32)
    for x in (20, 32, 44):
        ring_stone(st, x, 52)
    return key, st


# ------------------------------------------------------------------ 3. Toadstool Tiptoe: inner-TBTB keyhole, common.
def toadstool_tiptoe():
    key = 'pl-wced-3'
    st = Sticker()
    core = (15, 19, 48, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 6, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 19, 34, list(ROSE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0c8b8', skip=grow(holes, 3))
    toad_cap(st, 38, 16, 8, 6)
    # tiptoe pointy feet either side of the south tab
    st.part(poly([(22, 47), (26, 47), (24, 55)]), '#efe6d0', d=1, contour=True)
    st.part(poly([(38, 47), (42, 47), (40, 55)]), '#efe6d0', d=1, contour=True)
    st.eye(20, 27, look=(-1, -1))
    st.eye(36, 27, look=(-1, -1))
    st.paint(line([(20, 23), (24, 22)]) | line([(37, 22), (41, 23)]), UMBER)
    st.mouth('o', 30, 37)
    return key, st


# ------------------------------------------------------------------ 4. Far Snowcaps: inner-TTTT double, uncommon.
def far_snowcaps():
    key = 'pl-wced-4'
    st = Sticker()
    core = (17, 19, 46, 48)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 19, 30, list(LAV)), contour=True)
    st.stitch(body, col=SNOWW[0])                                  # uncommon accent: snow white
    peaks(st, 32, 22)
    st.eye(22, 30, lid=2)
    st.eye(37, 30, lid=2)
    st.paint(rect(20, 37, 22, 37) | rect(41, 37, 43, 37), BLUSH)
    st.mouth('smile', 30, 39)
    return key, st


# ------------------------------------------------------------------ 5. Mossring Cushion: inner-BBBB keyhole, uncommon.
def mossring_cushion():
    key = 'pl-wced-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(MOSS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=CUSH[2], skip=grow(holes, 3))              # uncommon accent: cushion red
    st.eye(21, 23, lid=3)
    st.eye(37, 23, lid=3)
    st.paint(rect(17, 29, 19, 29) | rect(44, 29, 46, 29), BLUSH)
    st.mouth('cat', 30, 30)
    cushion(st, 32, 41)
    return key, st


# ------------------------------------------------------------------ 6. Branch Meditator: whimsy-woodspirit keyhole, rare.
def branch_meditator():
    key = 'pl-wced-6'
    st = Sticker()
    # the cedar branch it sits on
    br = line([(7, 52), (56, 50)], w=3)
    st.part(br, '#5a3a20', d=1, contour=True)
    for x in (11, 51):
        st.part(ellipse(x, 47, 5, 2.5), CEDAR[0], d=1, contour=True)
    head = ellipse(32, 23, 10, 9)
    torso = ellipse(32, 38, 9, 7)
    legs = ellipse(32, 46, 14, 4)
    tab = knob('n', 'keyhole', 32, 14.5, r=3.0)
    body = head | torso | legs | tab
    st.part(body, tex=fill(key, body, 18, 11, 30, list(WOOD)), contour=True)
    st.paint(line([(25, 44), (39, 44)]), '#5a3a20')                 # crossed-leg seam
    st.paint(disc(28, 40, 2) | disc(36, 40, 2), '#6a4428')          # hands together in the lap
    st.paint(ellipse(32, 28, 5, 1) & ~ellipse(32, 27, 4, 1), '#6a4428')  # carved grain ring
    # cedar sprig tuft crown
    st.part(poly([(25, 14), (32, 6), (39, 14)]), CEDAR[0], d=1, contour=True)
    shut_eye(st, 25, 22)
    shut_eye(st, 35, 22)
    st.mouth('flat', 31, 27)
    st.paint(rect(23, 25, 24, 25) | rect(40, 25, 41, 25), BLUSH)
    note(st, 46, 19)
    st.sparkle(10, 10)
    st.sparkle(14, 30, big=False)
    st.sparkle(52, 32, big=False)
    return key, st


PALS = [misty_moonpeek, fireside_flickerling, toadstool_tiptoe, far_snowcaps, mossring_cushion, branch_meditator]

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
        print('%-10s %-21s %-9s %-18s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
