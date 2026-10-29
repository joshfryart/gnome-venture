"""Puzzle Pals: THE SUGAR SHACK (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-sugr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_sugr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a gnome maple sugarhouse on an autumn day. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy, puff); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-the-sugar-shack.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Bucket Plink      tin pail grey         | a bucket bail handle + spout with an amber sap drip  | looks down at the drip, 'o' mouth
  2 Tapper Tip        gnome coat blue       | a red gnome hat + a tiny hand drill                   | happy ^ ^ eyes, big grin
  3 Sweet Steam Wander steam cream white    | rising steam puffs from the top                        | sleepy lids, small smile
  4 Maple Quartet     maple leaf orange     | four small maple leaves, one at each knob tip         | wide eyes glance aside, cat mouth
  5 Syrup Shine       log cabin brown       | a glowing amber window pane on the chest + syrup drop | content closed lids, smile
  6 Maple Mayor       maple crimson         | whimsy maple-leaf body, black top hat + gold sash, glow | eyes up, toothy grin, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-the-sugar-shack'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-the-sugar-shack-364637')

TIN = ('#7e8c98', '#a2b0bc')
COAT = ('#3e5e94', '#5a7cb2')
STEAM = ('#d8dce4', '#f2f4f8')
LEAF = ('#d0661e', '#e88a32')
LOG = ('#834e2f', '#a0663e')
MAPLE = ('#a8282a', '#c8403a')
SAP = ('#e0a030', '#f8d070')
HATR = ('#c8302c', '#e05040')
DRILL = ('#6a6a72', '#3a3a42')
GLOW = ('#f8b040', '#ffe08a', '#5a2e18')
TOPHAT = ('#2a2228', '#4a3e46')
GOLDS = ('#e8c048', '#c89a28')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def drop(st, x, y, col=SAP):
    m = disc(x, y + 1, 1.6) | rect(x, y - 1, x, y)
    st.part(m, col[0], d=1, contour=True)
    st.paint(rect(x - 1, y, x - 1, y), col[1])
    st.extra |= grow(m, 1)


def maple_mask(cx, cy, s):
    p = [(0, -10), (2, -5), (6, -7), (5, -2), (10, -3), (7, 2), (8, 4), (2, 3), (1, 8), (-1, 8), (-2, 3), (-8, 4),
         (-7, 2), (-10, -3), (-5, -2), (-6, -7), (-2, -5)]
    return poly([(cx + x * s, cy + y * s) for x, y in p])


def mini_leaf(st, cx, cy, s=0.4):
    m = maple_mask(cx, cy, s) | disc(cx, cy, 1.2)
    st.part(m, LEAF[1], d=1, contour=True)
    st.paint(rect(int(cx), int(cy), int(cx), int(cy) + 2), '#8a3a14')
    st.extra |= grow(m, 1)


# ------------------------------------------------------------------ 1. Bucket Plink: corner-TT round, common.
def bucket_plink():
    key = 'pl-sugr-1'
    st = Sticker()
    core = (12, 22, 44, 52)
    body = piece(core, s='F', w='F', n=('T', 'round', 2, 3.6), e=('T', 'round', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(TIN)), contour=True)
    for y in (27, 47):                                         # pail hoops
        st.paint(rect(13, y, 43, y) & body, '#5a6670')
    st.stitch(body, col='#c8d2dc')
    bail = disc(28, 22, 13) & ~disc(28, 22, 11.6) & (CY < 20)
    st.paint(bail, UMBER, solid=True)
    st.extra |= bail
    spout = rect(9, 33, 12, 35)
    st.part(spout, DRILL[0], d=1, contour=True)
    drop(st, 10, 39)
    st.eye(20, 33, look=(-1, 1))
    st.eye(32, 33, look=(-1, 1))
    st.mouth('o', 25, 40)
    return key, st


# ------------------------------------------------------------------ 2. Tapper Tip: edge-BTB peg, common.
def tapper_tip():
    key = 'pl-sugr-2'
    st = Sticker()
    core = (14, 26, 46, 52)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 2.8), e=('T', 'peg', 2, 3.4), w=('B', 'peg', 2, 2.8))
    st.part(body, tex=fill(key, body, 14, 26, 33, list(COAT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8c0e0', skip=grow(holes, 3))
    hat = poly([(15, 27), (45, 27), (34, 9), (30, 8)])
    st.part(hat, HATR[0], d=1, contour=True)
    st.paint(hat & (CX < 26), HATR[1])
    st.paint(rect(15, 26, 45, 27) & hat, '#8a1e1e')
    drill = rect(38, 46, 41, 48) | rect(42, 47, 45, 47) | rect(39, 49, 40, 51)
    st.part(drill, DRILL[0], d=1, contour=True)
    closed_up(st, 20, 34)
    closed_up(st, 34, 34)
    st.mouth('grin', 27, 40)
    st.paint(rect(17, 39, 19, 39) | rect(41, 39, 43, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Sweet Steam Wander: inner-TBTB round, common.
def sweet_steam():
    key = 'pl-sugr-3'
    st = Sticker()
    core = (14, 20, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -4, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 20, 33, list(STEAM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8ac0e0', skip=grow(holes, 3))
    for cx, cy, r in ((20, 11, 3.0), (40, 10, 3.2), (47, 8, 2.2)):
        puff(st, cx, cy, r=r, pal=('#f2f4f8', '#d8dce4', '#b8c0cc'), lobes=3)
    st.eye(22, 29, lid=3)
    st.eye(35, 29, lid=3)
    st.mouth('smile', 27, 36)
    st.paint(rect(18, 34, 20, 34) | rect(39, 34, 41, 34), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Maple Quartet: inner-TTTT peg, uncommon.
def maple_quartet():
    key = 'pl-sugr-4'
    st = Sticker()
    core = (18, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 18, 29, list(LEAF)), contour=True)
    st.stitch(body, col=LOG[0])                                 # uncommon accent: cabin log brown
    st.paint(rect(32, 21, 32, 43) & body & (CY % 2 == 0), '#9a4012')
    for lx, ly in ((32, 12), (32, 52), (12, 32), (52, 32)):
        mini_leaf(st, lx, ly)
    st.eye(25, 29, look=(1, 0))
    st.eye(37, 29, look=(1, 0))
    st.mouth('cat', 30, 36)
    return key, st


# ------------------------------------------------------------------ 5. Syrup Shine: inner-BBBB round, uncommon.
def syrup_shine():
    key = 'pl-sugr-5'
    st = Sticker()
    core = (11, 12, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 12, 42, list(LOG)), contour=True)
    for y in (18, 24, 46):                                      # log seams
        st.paint(rect(13, y, 50, y) & body & ~grow(holes, 1), '#5a3220')
    st.blank_shade(body, holes, width=1)
    win = rect(24, 34, 39, 44)
    st.part(win, GLOW[0], d=1, contour=True)
    st.paint(rect(25, 35, 31, 38), GLOW[1])
    st.paint(rect(31, 34, 32, 44) | rect(24, 39, 39, 39), GLOW[2])
    st.stitch(body, col=SAP[1], skip=grow(holes, 3))            # uncommon accent: syrup amber
    closed_down(st, 21, 26)
    closed_down(st, 38, 26)
    st.mouth('smile', 29, 29)
    st.paint(rect(17, 30, 19, 30) | rect(44, 30, 46, 30), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Maple Mayor: whimsy-maple peg, rare.
def maple_mayor():
    key = 'pl-sugr-6'
    st = Sticker()
    leaf = maple_mask(32, 32, 2.0)
    tab = knob('s', 'peg', 32, 47, r=3.2)
    body = leaf | tab
    st.part(body, tex=fill(key, body, 9, 8, 46, list(MAPLE)), contour=True)
    st.paint(rect(32, 22, 32, 46) & body & (CY % 2 == 0), '#781a1e')
    sash = line([(20, 37), (44, 42)], w=2) & leaf
    st.part(sash, GOLDS[0], d=1, contour=True, rim=False)
    hat = rect(26, 8, 38, 13) | rect(23, 13, 41, 15)
    st.part(hat, TOPHAT[0], d=1, contour=True)
    st.paint(rect(25, 11, 39, 11), GOLDS[1])
    st.eye(26, 25, look=(0, -1))
    st.eye(38, 25, look=(0, -1))
    st.mouth('tooth', 30, 32)
    st.paint(rect(21, 30, 23, 30) | rect(41, 30, 43, 30), BLUSH)
    st.sparkle(11, 12)
    st.sparkle(53, 12, big=False)
    st.sparkle(52, 50, big=False)
    return key, st


PALS = [bucket_plink, tapper_tip, sweet_steam, maple_quartet, syrup_shine, maple_mayor]

if __name__ == '__main__':
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-10s %-19s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
