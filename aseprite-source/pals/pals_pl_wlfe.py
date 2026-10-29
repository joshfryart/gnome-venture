"""Puzzle Pals: LANTERN FESTIVAL RIVER (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wlfe-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wlfe.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: river lantern sprites, keyhole knobs, night. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-lantern-festival-river.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Upturned Pagoda Eaves   pagoda brick red            | curly upturned eave roof on its brow + spire finial          | wide bright eyes, open grin
  2 Butter Moonlet          butter moon yellow          | crescent shadow bite + two craters, tiny star                | sleepy half-lids, small smile
  3 Lollipop Tree           bank leaf green             | round lollipop canopy dapple + brown trunk stick below       | ^ ^ happy eyes, o mouth
  4 Beads on the Bridge     bridge stone grey (+ red)   | rail across the brow, four red bead lanterns, one per tab    | eyes glancing up, cat mouth
  5 Roundbelly Lanternling  river night navy (+ amber)  | glowing belly window, top cap + tassel, ripple rings         | dot eyes, toothy grin
  6 Candle Boat Pilot       paper amber lantern         | whimsy floating lantern on a little boat, wish star, glow    | joyful lashes, smile, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-lantern-festival-river'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-lantern-festival-river-05dda1')

BRICK = ('#8a2e2a', '#a8463a')         # pagoda brick red
BUTTER = ('#e8cc6a', '#f6e296')        # butter moon
LEAF = ('#3e7a3a', '#5a9a4a')          # bank leaf green
STONE = ('#7a7c84', '#9a9ca4')         # bridge stone grey
NAVY = ('#283a6a', '#384e84')          # river night navy
AMBER = ('#e88a3a', '#f6aa5a')         # paper lantern amber (rare)
ROOF = ('#3a2a3a', '#5a4050')
LANT = ('#d83a2e', '#ff7a5a')
GLOW = ('#ffd070', '#fff0b0')
TRUNK = '#6a4a2a'
CREAM = '#fbf0dc'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def lash_eye(st, x, y):
    st.sprite(['U.U.U', '.UUU.', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def dot_eye(st, x, y):
    st.sprite(['UU', 'UU'], x, y, {'U': UMBER}, solid=False)


def bead(st, x, y):
    st.part(ellipse(x, y, 2.2, 2.6), LANT[0], d=1, contour=True)
    st.paint(ellipse(x, y, 0.8, 1.0), GLOW[0])


# ------------------------------------------------------------------ 1. Upturned Pagoda Eaves: corner-TB keyhole, common.
def pagoda_eaves():
    key = 'pl-wlfe-1'
    st = Sticker()
    core = (12, 18, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -4, 3.6), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 9, 46, list(BRICK)), contour=True)
    st.blank_shade(body, holes, width=1)
    eave = rect(10, 17, 50, 21) | rect(7, 14, 10, 17) | rect(50, 14, 53, 17)
    st.part(eave, ROOF[0], d=1, contour=True)
    st.paint(rect(11, 18, 49, 18), ROOF[1])
    st.paint(rect(16, 46, 44, 46) & body & ~grow(holes, 1) & ((XX // 4) % 2 == 0), '#c86a4a')
    st.eye(20, 28)
    st.eye(35, 28)
    st.paint(rect(18, 36, 20, 36) | rect(39, 36, 41, 36), BLUSH)
    st.mouth('grin', 26, 37)
    return key, st


# ------------------------------------------------------------------ 2. Butter Moonlet: edge-TTB keyhole, common.
def butter_moonlet():
    key = 'pl-wlfe-2'
    st = Sticker()
    core = (12, 20, 45, 53)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 3, 3.6), w=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 13, 12, 38, list(BUTTER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(disc(14, 48, 9) & body & ~grow(holes, 1), '#c8a84a')
    st.paint(disc(39, 46, 2.2) & body, '#d4b452')
    st.paint(disc(22, 26, 1.6) & body, '#d4b452')
    st.sparkle(50, 8, big=False)
    st.eye(20, 31, lid=2)
    st.eye(34, 31, lid=2)
    st.mouth('smile', 26, 39)
    return key, st


# ------------------------------------------------------------------ 3. Lollipop Tree: inner-TBTB keyhole, common.
def lollipop_tree():
    key = 'pl-wlfe-3'
    st = Sticker()
    core = (14, 16, 49, 43)
    trunk = rect(29, 43, 34, 54)
    st.part(trunk, TRUNK, d=0, contour=True, shade=False)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 36, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x, y in ((19, 20), (42, 21), (24, 39), (44, 38), (36, 18)):
        st.paint(disc(x, y, 1.3) & body, GLOW[0])
    happy_eye(st, 20, 26)
    happy_eye(st, 36, 26)
    st.mouth("o", 30, 33)
    return key, st


# ------------------------------------------------------------------ 4. Beads on the Bridge: inner-TTTT double, uncommon.
def bridge_beads():
    key = 'pl-wlfe-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(STONE)), contour=True)
    st.stitch(body, col=LANT[0])                                    # uncommon accent: lantern red
    st.paint(rect(19, 22, 44, 23) & body, '#4a4a54')
    for x in (23, 40):
        st.paint(rect(x, 23, x, 25), '#4a4a54')
        bead(st, x, 28)
    bead(st, 31.5, 11)
    bead(st, 31.5, 52)
    bead(st, 11, 31.5)
    bead(st, 52, 31.5)
    st.eye(24, 33, look=(0, -1))
    st.eye(36, 33, look=(0, -1))
    st.mouth('cat', 29, 40)
    return key, st


# ------------------------------------------------------------------ 5. Roundbelly Lanternling: inner-BBBB keyhole, uncommon.
def roundbelly_lanternling():
    key = 'pl-wlfe-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(NAVY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=AMBER[0], skip=grow(holes, 3))              # uncommon accent: lantern amber
    win = ellipse(31.5, 34, 11, 10)
    st.part(win, GLOW[0], d=1, contour=True)
    st.paint(ellipse(31.5, 34, 6, 6), GLOW[1])
    for x in (24, 39):
        st.paint(rect(x, 25, x, 43) & win, AMBER[0])
    st.paint(rect(24, 17, 39, 19), ROOF[0])
    for x in (16, 47):
        st.paint(rect(x - 1, 46, x, 46), '#6a8ac0')
    dot_eye(st, 26, 31)
    dot_eye(st, 36, 31)
    st.mouth('tooth', 29, 36)
    return key, st


# ------------------------------------------------------------------ 6. Candle Boat Pilot: whimsy-wishlight keyhole, rare.
def candle_boat_pilot():
    key = 'pl-wlfe-6'
    st = Sticker()
    boat = rect(14, 46, 48, 49) | rect(17, 50, 45, 52) | rect(13, 43, 14, 46) | rect(48, 43, 49, 46)
    st.part(boat, TRUNK, d=0, contour=True, shade=False)
    lan = ellipse(31, 30, 13, 14)
    tab = knob('e', 'keyhole', 41, 30, r=3.0)
    sil = lan | tab
    st.part(sil, tex=fill(key, sil, 12, 10, 44, list(AMBER)), contour=True)
    st.paint(rect(22, 15, 40, 17), ROOF[0])
    st.paint(rect(24, 43, 38, 45), ROOF[0])
    st.paint(ellipse(31, 34, 6, 5) & lan, GLOW[1])
    st.part(disc(31, 9, 2.4), GLOW[0], d=1, contour=True)      # the wish star
    st.paint(rect(31, 12, 31, 14), GLOW[0])
    lash_eye(st, 23, 23)
    lash_eye(st, 34, 23)
    st.paint(rect(21, 29, 23, 29) | rect(39, 29, 41, 29), BLUSH)
    st.mouth('smile', 29, 30)
    st.sparkle(6, 8)
    st.sparkle(47, 7, big=False)
    st.sparkle(48, 54, big=False)
    return key, st


PALS = [pagoda_eaves, butter_moonlet, lollipop_tree, bridge_beads, roundbelly_lanternling, candle_boat_pilot]

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
