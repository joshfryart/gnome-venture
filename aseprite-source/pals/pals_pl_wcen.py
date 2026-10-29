"""Puzzle Pals: CENOTE OF ECHOES (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wcen-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wcen.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: pool sprites, keyhole knobs, soft and curious. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-cenote-of-echoes.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Mossy Ledge Croaker  moss frog green            | frog eye-bumps on top, puffed throat sac, moss ledge cap, croak arcs | bulgy eyes, o croak
  2 Plinking Pebbles     slate stone grey           | a falling drip above + plink rings, two little pebble buddies        | sleepy lids, smirk
  3 Chestful of Twinkles chest wood brown           | ajar chest lid on its head with gold glints, gold lock plate, coin  | happy ^ ^ eyes, tooth grin
  4 Slanting Sunbeams    pale sun lime (+ teal)     | four slanted light beams on its tabs, dust motes                    | looking up, smile
  5 Ripples Running Late deep pool teal (+ lime)    | concentric ripple rings round it, a late echo arc                   | glance aside, cat mouth
  6 Chestwatch Goldfish  goldfish orange            | whimsy plump goldfish, fanning fin, tiny chest, bubbles, glow (rare)| guard brows, flat mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-cenote-of-echoes'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-cenote-of-echoes-f27683')

MOSS = ('#5c9a3a', '#7cb850')          # frog moss green
SLATE = ('#6a7480', '#8a94a0')         # slate stone grey
WOOD = ('#8a5a32', '#a87446')          # chest wood brown
SUN = ('#c8dc7a', '#e0eca0')           # pale sun lime
POOL = ('#2e7a78', '#4a9a90')          # deep pool teal
FISH = ('#e88a2a', '#f4a84a')          # goldfish orange (rare)
GOLDC = ('#e8c040', '#b88a20', '#fff0a0')
WATER = ('#9ad8d0', '#5ab0a8')
BEAM = ('#eaf4b0', '#c8e080')
LEAFG = ('#3f7a2a', '#8cc85a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def mark(st, pts, col):
    for x, y in pts:
        st.px[y, x] = hx(col)
        st.extra[y, x] = True


def arc_marks(st, cx, cy, r, a0, a1, col):
    pts = set()
    for i in range(24):
        a = np.radians(a0 + (a1 - a0) * i / 23)
        pts.add((int(round(cx + r * np.cos(a))), int(round(cy + r * np.sin(a)))))
    mark(st, pts, col)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def coin(st, cx, cy, r=2.6):
    m = disc(cx, cy, r)
    st.part(m, GOLDC[0], d=1, contour=True)
    st.dots([(int(cx) - 1, int(cy) - 1)], GOLDC[2])


def drip(st, cx, top):
    m = poly([(cx, top), (cx + 2.5, top + 5), (cx - 2.5, top + 5)]) | disc(cx, top + 5, 2.5)
    st.part(m, WATER[0], d=1, contour=True)
    st.dots([(int(cx) - 1, top + 4)], '#ffffff')


# ------------------------------------------------------------------ 1. Mossy Ledge Croaker: corner-TT keyhole, common.
def mossy_ledge_croaker():
    key = 'pl-wcen-1'
    st = Sticker()
    core = (14, 22, 44, 50)
    bumps = disc(20, 22, 5) | disc(36, 22, 5)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 2, 3.6)) | bumps
    st.part(body, tex=fill(key, body, 14, 15, 36, list(MOSS)), contour=True)
    st.stitch(body, col='#c8e48a')
    cap = ellipse(28, 14, 6, 2.2) | ellipse(23, 15, 3, 2)              # moss ledge clump on its knob
    st.part(cap & (CY < 16), LEAFG[0], d=1, contour=True)
    st.paint(cap & (CY < 13), LEAFG[1])
    sac = ellipse(28, 44, 7, 4)                                         # puffed croak sac
    st.part(sac, '#e8e0a0', d=1, contour=True)
    for cx in (20, 36):
        st.paint(disc(cx, 21, 4.2), CREAM)
        st.paint(disc(cx, 22, 2.2), UMBER)
        st.dots([(cx - 1, 20)], '#ffffff')
    st.mouth('o', 26, 34)
    st.paint(rect(16, 31, 18, 31) | rect(38, 31, 40, 31), BLUSH)
    st.part(ellipse(18, 52, 4, 2), MOSS[0], d=1, contour=True)
    st.part(ellipse(36, 52, 4, 2), MOSS[0], d=1, contour=True)
    arc_marks(st, 50, 30, 3, -50, 50, CREAM)                           # croak going out ...
    arc_marks(st, 50, 30, 6, -40, 40, '#a8d8e0')                       # ... and coming back late
    return key, st


# ------------------------------------------------------------------ 2. Plinking Pebbles: edge-BTB keyhole, common.
def plinking_pebbles():
    key = 'pl-wcen-2'
    st = Sticker()
    core = (12, 22, 46, 49)
    body, holes = piece_blanks(core, s='F', n=('B', 'keyhole', 0, 3.0), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 22, 36, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c4ccd6', skip=grow(holes, 3))
    drip(st, 28, 8)
    arc_marks(st, 28.5, 19, 5, 200, 340, WATER[0])
    st.part(ellipse(10, 53, 3.5, 2.2), '#4a525c', d=1, contour=True)       # pebble buddies
    st.part(ellipse(53, 54, 3, 2), '#7a6a5a', d=1, contour=True)
    st.eye(20, 31, lid=2)
    st.eye(34, 31, lid=2)
    st.mouth('smirk', 26, 40)
    st.paint(rect(16, 38, 18, 38) | rect(40, 38, 42, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Chestful of Twinkles: inner-TBTB keyhole, common.
def chestful_of_twinkles():
    key = 'pl-wcen-3'
    st = Sticker()
    core = (15, 19, 48, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 6, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', -6, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 19, 34, list(WOOD)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(16, 36, 47, 37) & body, '#5a3a20')                    # iron band
    st.stitch(body, col=GOLDC[0], skip=grow(holes, 3) | rect(0, 35, 63, 38))
    lid = poly([(12, 16), (36, 9), (40, 12), (16, 20)])                  # ajar lid tipped on its head
    st.part(lid, WOOD[0], d=1, contour=True)
    st.paint(line([(14, 17), (37, 10)]), GOLDC[1])
    st.part(rect(29, 38, 34, 43), GOLDC[0], d=1, contour=True)          # lock plate
    st.dots([(31, 40), (32, 40), (31, 41)], UMBER)
    for x, y in ((24, 21), (44, 16), (10, 26)):
        st.sparkle(x, y, big=False)
    coin(st, 51, 49)
    happy_eye(st, 20, 26)
    happy_eye(st, 37, 26)
    st.mouth('tooth', 28, 31)
    return key, st


# ------------------------------------------------------------------ 4. Slanting Sunbeams: inner-TTTT double, uncommon.
def slanting_sunbeams():
    key = 'pl-wcen-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SUN)), contour=True)
    st.stitch(body, col=POOL[1])                                        # uncommon accent: pool teal
    for x in (22, 29, 35, 41):                                          # beam stripes, symmetric pairs
        st.paint(rect(x, 18, x + 1, 45) & shrink(body, 3) & ~rect(18, 24, 45, 40), BEAM[0])
    for cx, cy in ((32, 9), (32, 55), (9, 32), (55, 32)):
        st.paint(shrink(body, 1) & disc(cx, cy, 3), BEAM[0])
    st.eye(23, 27, look=(0, -1))
    st.eye(36, 27, look=(0, -1))
    st.mouth('smile', 30, 35)
    st.paint(rect(20, 34, 22, 34) | rect(41, 34, 43, 34), BLUSH)
    mark(st, [(5, 5), (58, 5), (5, 58), (58, 58)], BEAM[0])
    return key, st


# ------------------------------------------------------------------ 5. Ripples Running Late: inner-BBBB keyhole, uncommon.
def ripples_running_late():
    key = 'pl-wcen-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(POOL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=SUN[1], skip=grow(holes, 3))                    # uncommon accent: sunbeam lime
    for r in (6.5, 10.5, 14.5):                                         # rings, centred
        ring = ellipse(32, 44, r, r * 0.4) & ~ellipse(32, 44, r - 1, r * 0.4 - 1)
        st.paint(ring & shrink(body, 3), WATER[0])
    st.eye(22, 26, look=(1, 0), lid=1)
    st.eye(37, 26, look=(1, 0), lid=1)
    st.mouth('cat', 30, 33)
    st.paint(rect(17, 32, 19, 32) | rect(44, 32, 46, 32), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Chestwatch Goldfish: whimsy-goldfish keyhole, rare.
def chestwatch_goldfish():
    key = 'pl-wcen-6'
    st = Sticker()
    tail = poly([(15, 30), (8, 21), (10, 31), (8, 41)])
    st.part(tail, FISH[1], d=1, contour=True)
    fin_top = poly([(26, 20), (36, 13), (42, 20)])
    st.part(fin_top, FISH[1], d=1, contour=True)
    tab = knob('s', 'keyhole', 32, 44, r=3.0)
    body = ellipse(32, 31, 19, 13) | tab
    st.part(body, tex=fill(key, body, 13, 18, 38, list(FISH)), contour=True)
    st.stitch(ellipse(32, 31, 19, 13), col='#ffd890')
    fan = poly([(30, 34), (22, 42), (26, 43), (32, 38)])                # fanning side fin
    st.part(fan, FISH[1], d=1, contour=True)
    st.paint(line([(29, 36), (24, 42)]), '#c86a1a')
    ch = rect(36, 47, 48, 54)                                           # its little chest
    st.part(ch, WOOD[0], d=1, contour=True)
    st.paint(rect(36, 49, 48, 49), '#5a3a20')
    st.part(rect(41, 49, 43, 51), GOLDC[0], d=0, contour=True, shade=False)
    st.eye(40, 26, look=(-1, 0), lid=1)
    st.paint(line([(37, 22), (43, 23)]), UMBER)
    st.mouth('flat', 46, 33)
    st.paint(rect(42, 31, 44, 31), BLUSH)
    for cx, cy in ((54, 20), (57, 14)):
        mark(st, [(cx, cy - 1), (cx - 1, cy), (cx + 1, cy), (cx, cy + 1)], WATER[0])
    st.sparkle(5, 5)
    st.sparkle(53, 5, big=False)
    st.sparkle(9, 51, big=False)
    return key, st


PALS = [mossy_ledge_croaker, plinking_pebbles, chestful_of_twinkles, slanting_sunbeams, ripples_running_late, chestwatch_goldfish]

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
