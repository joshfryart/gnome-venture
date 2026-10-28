"""Puzzle Pals: ANACONDA HOLLOWS (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-ana-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_ana.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cute cave beasts and the dark's small treasures, cosy-curious, never scary. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy, feather, claw_feet); everything else drawn here. Silhouette = the row's shape + knob,
body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/delve-anaconda-hollows.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Tailtip Tickle    pale chartreuse tail-tip    | a curled tail tip on top + an orange toucan feather it tickles with | cheeky wink, toothy grin
  2 Tongue Taster     belly cream-sand            | a long forked red tongue flicked out right, breeze curls            | startled-curious, brows up, o
  3 Creek Sipper      creek teal                  | a reed straw dipped in a ripple, burp bubbles                       | sleepy heavy lids, pursed sip
  4 Scale Diamonds    deep canopy green (+ teal)  | 4 wet-pebble diamond markings (one per tab), 2 drips                | smug closed ^ ^ eyes, smirk
  5 Coil Nest         twig-nest bank brown (+moss)| woven twig rim, a moss pillow with a tiny red gnome cap napping     | shy, looks down, blush
  6 Big Grin Anaconda jungle green, dark spots    | whimsy coiled anaconda (3 coils + head), cream jaw, glow (rare)     | huge grin, round happy eyes
Ring and Plus are mirror-symmetric (all knobs centred). Browns lifted off mud.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-anaconda-hollows'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-anaconda-hollows-734b93')

LIME = ('#a4bc56', '#c4d478')          # tail-tip chartreuse
BELLY = ('#cdb878', '#e6d49a')         # anaconda belly cream-sand
CREEK = ('#3f8480', '#5ea294')         # creek teal
CANOPY = ('#2c6436', '#3a7a40')        # deep canopy green
NEST = ('#8e6638', '#a8804a')          # bank brown, lifted
JUNGLE = ('#4f8f40', '#5e9e46')        # anaconda green (rare)
TOUCAN = ('#e8841f', '#b85a1a', '#f5b45a', '#7a3414')
TONGUE, TONGUE_D = '#d63a34', '#a8241f'
REED = ('#9a8a3a', '#6a5a28', '#c4b45a', '#4a3a1a')
CATTAIL = ('#7a4a24', '#5a3418', '#9a6a3a', '#3a2214')
BUBBLE = ('#b8e4dc', '#eefaf6')
PEBBLE = ('#2f6a6e', '#4a8a82', '#a8e0d4', '#ffffff')
MOSS = ('#6a9a3a', '#4a7a2a', '#9ac45a', '#2f5a2a')
SPOT = '#24502a'
JAW = ('#e9d9a0', '#c8b070')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


def mark_extra(st, m):
    st.extra |= m


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def taper_path(pts, r0, r1):
    """A tapering tube along a polyline: discs from radius r0 down to r1."""
    m = blank()
    n = len(pts)
    for i, (x, y) in enumerate(pts):
        t = i / max(1, n - 1)
        m |= disc(x, y, r0 + (r1 - r0) * t)
    return m


def tail_curl(st, x, y, col):
    """A tail tip rising from (x, y), curling over to the right into a small spiral; a light dorsal line."""
    pts = []
    for i in range(22):
        t = i / 21
        a = math.pi * (1.0 + 1.5 * t)
        rad = 6.5 * (1 - 0.55 * t)
        pts.append((x + 6 + rad * math.cos(a) * -1 * -1, y - 4 + rad * math.sin(a)))
    pts = [(x, y + 2), (x - 0.3, y - 1)] + pts
    m = taper_path(pts, 2.6, 1.0)
    st.part(m, col[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1) & shrink(m, 0), col[1])
    return m


def forked_tongue(st, x, y, L=12):
    """Long forked tongue from the mouth at (x, y) out to the right, wiggling once, a 2-prong fork at its tip."""
    pts = [(x + i, y + round(1.2 * math.sin(i * 0.5))) for i in range(L)]
    m = blank()
    for (a, b), (c, d) in zip(pts, pts[1:]):
        m |= line([(a, b), (c, d)], w=2)
    ex, ey = pts[-1]
    m |= line([(ex, ey), (ex + 3, ey - 3)]) | line([(ex, ey + 1), (ex + 3, ey + 4)])
    st.paint(m, TONGUE, solid=True)
    st.paint(m & shift(m, 0, -1) & ~shift(m, 0, 1), TONGUE_D)
    return m


def breeze(st, x, y, n=3):
    """Little breeze curls (cream, border only)."""
    rows_ = ['CCC.', '...C', '.CC.']
    for k in range(n):
        st.sprite(rows_, x + 2 * k, y + 5 * k, {'C': CREAM}, solid=False)
        for j, r in enumerate(rows_):
            for i, ch in enumerate(r):
                if ch == 'C':
                    st.extra[y + 5 * k + j, x + 2 * k + i] = True


def reed_straw(st, x0, y0, x1, y1):
    stalk = line([(x0, y0), (x1, y1)], w=2)
    st.part(stalk, REED[0], d=1, contour=True)
    st.paint(stalk & (CX < x0 + (x1 - x0) * (CY - y0) / max(1, (y1 - y0)) + 0.6), REED[2])
    head = ellipse(x1 + 0.5, y1 - 3, 2.2, 4.2)
    st.part(head, CATTAIL[0], d=1, contour=True)
    st.paint(head & (CX < x1), CATTAIL[2])
    st.paint(rect(int(x1), int(y1) - 10, int(x1), int(y1) - 7), REED[2], solid=True)   # the reed's spike
    return stalk | head


def bubble(st, cx, cy, r):
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 1.1)
    st.paint(ring, BUBBLE[0])
    st.paint(disc(cx - r * 0.4, cy - r * 0.4, 0.8 if r > 2 else 0.5) | rect(int(cx - r * 0.45), int(cy - r * 0.45), int(cx - r * 0.45), int(cy - r * 0.45)), BUBBLE[1])
    st.extra |= disc(cx, cy, r)
    return ring


def ripple(st, cx, cy, rx):
    m = ellipse(cx, cy, rx, 2.2) & ~ellipse(cx, cy - 0.6, rx - 2, 1.4)
    st.part(m, CREEK[1], d=0, contour=True, shade=False)
    st.paint(m & (CY < cy), BUBBLE[0])
    return m


def diamond(st, cx, cy, r):
    """A wet creek-pebble diamond marking: dark teal-green rhombus, a teal sheen, a white glint top-left."""
    m = poly([(cx, cy - r), (cx + r * 0.8, cy), (cx, cy + r), (cx - r * 0.8, cy)])
    st.paint(m, PEBBLE[2])
    st.paint(shrink(m, 1), PEBBLE[0])
    st.paint(shrink(m, 1) & (CX + CY < cx + cy - 0.5), PEBBLE[1])
    st.dots([(int(cx - 1), int(cy - r * 0.45))], PEBBLE[3])
    st.dots([(int(cx), int(cy - r * 0.45))], PEBBLE[2])
    return m


def drip(st, cx, cy):
    m = disc(cx, cy, 1.2) | rect(int(cx), int(cy) - 2, int(cx), int(cy) - 1)
    st.paint(m, PEBBLE[2])
    st.dots([(int(cx), int(cy))], PEBBLE[3])
    st.extra |= m


def closed_up(st, x, y):
    """Happy-smug closed eye: an upward arc ^."""
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def twig_rim(st, body):
    """Woven twig rim round the nest: two rows of short diagonal twig strokes just inside the edge."""
    edge = body & ~shrink(body, 3) & shrink(body, 0)
    st.paint(edge & ((XX + YY) % 4 == 0), '#6a4a2a')
    st.paint(edge & ((XX - YY) % 5 == 0), '#c49a5a')


def moss_pillow(st, cx, cy):
    m = ellipse(cx, cy, 6.5, 2.8)
    st.part(m, MOSS[0], d=1, contour=True)
    st.paint(m & ((XX * 3 + YY) % 5 == 0) & shrink(m, 1), MOSS[2])
    return m


def gnome_cap(st, x, y):
    """A tiny red gnome cap left on the moss pillow (the napping gnome's), tip flopped right, white pompom."""
    m = poly([(x, y + 5), (x + 2.5, y), (x + 5, y - 1), (x + 4, y + 1.5), (x + 6.5, y + 5)])
    st.part(m, '#c8402e', d=1, contour=True)
    st.paint(rect(x, y + 4, x + 6, y + 5) & m, '#f2e4c0')
    st.paint(disc(x + 5.6, y - 1, 1.3), '#ffffff', solid=True)
    return m


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Tailtip Tickle: corner-TT peg, common.
def tailtip_tickle():
    key = 'pl-ana-1'
    st = Sticker()
    core = (13, 25, 45, 50)
    tail_curl(st, 17, 26, ('#d6e29a', '#f0f4c8'))
    body = piece(core, n=('T', 'peg', 5, 3.6), e=('T', 'peg', 3, 3.6))
    st.part(body, tex=fill(key, body, 13, 25, 33, list(LIME)), contour=True)
    st.stitch(body, col='#6a8a2a')
    feather(st, 45, 45, L=11, ang=-32, pal=TOUCAN)            # the toucan feather it tickles toes with
    nub_feet(st, [17, 35], 50, '#7a8a3a')
    wink(st, 19, 35)
    st.eye(32, 33, look=(-1, 0))
    st.paint(line([(31, 30), (34, 29), (37, 30)]), UMBER)       # cheeky cocked brow
    st.mouth('tooth', 25, 41)
    st.paint(rect(17, 40, 19, 40) | rect(38, 40, 40, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Tongue Taster: edge-TBT tri, common.
def tongue_taster():
    key = 'pl-ana-2'
    st = Sticker()
    core = (16, 23, 44, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 3.6), w=('T', 'tri', 2, 3.6), e=('B', 'tri', -6, 2.8))
    st.part(body, tex=fill(key, body, 16, 23, 29, list(BELLY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#9a7a3a', skip=grow(holes, 3))
    claw_feet(st, [19, 36], 50, w=6, h=3, pal=('#8a6a3a', '#6a4a2a', '#a88a5a', '#4a2c1a'), tip=BONE)
    st.eye(19, 29, look=(1, -1))
    st.eye(31, 29, look=(1, -1))
    st.paint(line([(19, 25), (21, 24), (23, 25)]) | line([(31, 25), (33, 24), (35, 25)]), UMBER)   # brows up: what's that taste?
    st.sprite(['.UU.', 'URRU', '.UU.'], 26, 39, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    forked_tongue(st, 30, 40, L=19)
    breeze(st, 49, 12, n=3)
    return key, st


# ------------------------------------------------------------------ 3. Creek Sipper: inner-TBTB round, common.
def creek_sipper():
    key = 'pl-ana-3'
    st = Sticker()
    core = (10, 22, 40, 45)
    body, holes = piece_blanks(core, n=('T', 'round', -3, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -4, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 10, 22, 31, list(CREEK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8dcd0', skip=grow(holes, 3))
    ripple(st, 50, 51, 6)
    # the reed straw: from its mouth down-right into the ripple; cattail head stands up above the ripple
    stalk = line([(27, 38), (49, 50)], w=2)
    st.part(stalk, REED[0], d=1, contour=True)
    st.paint(stalk & ~shift(stalk, 0, -1), REED[2])
    stem = rect(51, 28, 52, 50)
    st.part(stem, REED[0], d=1, contour=True)
    head = ellipse(52, 30, 2.4, 5)
    st.part(head, CATTAIL[0], d=1, contour=True)
    st.paint(head & (CX < 51.6), CATTAIL[2])
    st.paint(rect(52, 22, 52, 24), REED[2], solid=True)
    st.eye(14, 28, lid=3)
    st.eye(27, 28, lid=3)
    st.paint(rect(12, 35, 14, 35) | rect(31, 35, 33, 35), BLUSH)
    st.sprite(['.U.', 'U.U', '.U.'], 24, 36, {'U': UMBER}, solid=False)
    bubble(st, 17, 13, 2.6)
    bubble(st, 10, 8, 1.8)
    bubble(st, 24, 7, 1.6)
    return key, st


# ------------------------------------------------------------------ 4. Scale Diamonds: inner-TTTT double, uncommon.
def scale_diamonds():
    key = 'pl-ana-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(CANOPY)), contour=True)
    st.stitch(body, col=PEBBLE[2])                              # uncommon accent: the creek-pebble teal sheen
    for cx, cy in ((32, 12.5), (32, 52.5), (11.5, 32.5), (52.5, 32.5)):
        diamond(st, cx, cy, 4.6)
    drip(st, 21, 52)
    drip(st, 43, 54)
    closed_up(st, 22, 29)
    closed_up(st, 37, 29)
    st.paint(line([(36, 26), (39, 25), (42, 26)]), UMBER)       # one brow raised, very pleased with its shine
    st.mouth('smirk', 30, 37)
    return key, st


# ------------------------------------------------------------------ 5. Coil Nest: inner-BBBB peg, uncommon.
def coil_nest():
    key = 'pl-ana-5'
    st = Sticker()
    core = (11, 15, 52, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 0, 3.0), e=('B', 'peg', 0, 3.0), s=('B', 'peg', 0, 3.0), w=('B', 'peg', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 15, 42, list(NEST)), contour=True)
    twig_rim(st, body)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=MOSS[2], skip=grow(holes, 3))          # uncommon accent: moss green
    moss_pillow(st, 32, 44)
    gnome_cap(st, 34, 37)
    st.eye(20, 25, look=(-1, 1))
    st.eye(36, 25, look=(-1, 1))
    st.paint(rect(18, 32, 20, 32) | rect(41, 32, 43, 32), BLUSH)
    st.sprite(['U.U.U', '.U.U.'], 28, 34, {'U': UMBER}, solid=False)
    zzz(st, 44, 34)
    return key, st


# ------------------------------------------------------------------ 6. Big Grin Anaconda: whimsy-anaconda round, rare.
def big_grin_anaconda():
    key = 'pl-ana-6'
    st = Sticker()
    coil1 = ellipse(31, 50, 21, 5.2)          # bottom coil
    coil2 = ellipse(30, 42, 17, 4.8)          # middle coil
    neck = poly([(19, 41), (18, 29), (31, 29), (33, 41)])
    head = ellipse(25.5, 22, 12, 8.6)
    tailt = taper_path([(49, 52), (51.5, 49), (52, 45), (50, 42.5)], 2.4, 1.1)
    tab = knob('e', 'round', 22, 37.3, r=3.2)
    body = coil1 | coil2 | neck | head | tailt | tab
    st.part(body, tex=fill(key, body, 10, 12, 40, list(JUNGLE)), contour=True)
    seam = '#2a5a2a'
    st.paint(coil1 & ~coil2 & dil4(coil2) & ~neck, seam)
    st.paint(coil2 & ~coil1 & ~neck & dil4(neck) & (CX > 30), seam)
    st.paint(coil2 & ~head & dil4(coil1 & ~coil2) & ~neck, seam)
    for cx, cy in ((15, 50), (24, 52), (38, 52), (46, 49), (17, 43), (40, 42), (34, 16), (24, 33)):
        st.paint(disc(cx, cy, 1.8) & body, SPOT)
        st.dots([(int(cx - 1), int(cy - 1))], '#7db05a')
    st.stitch(coil1 | coil2, col='#b4cc78', skip=grow(neck | tailt, 1))
    # cream jaw with the ear-to-ear grin
    jaw = ellipse(25.5, 27, 9.8, 4.0) & (CY > 24.5)
    st.paint(jaw, JAW[0])
    st.paint(jaw & (CY > 29.2), JAW[1])
    st.paint(rect(16, 24, 35, 24), UMBER)
    st.paint(line([(15, 22), (16, 24)]) | line([(35, 24), (36, 22)]), UMBER)
    st.paint(rect(19, 25, 32, 26) & jaw, UMBER)
    st.paint(rect(20, 26, 31, 26), MOUTH_RED)
    # forked tongue dangling out of the grin
    st.paint(rect(25, 26, 26, 33), TONGUE, solid=True)
    st.paint(rect(24, 34, 24, 35) | rect(27, 34, 27, 35), TONGUE, solid=True)
    st.paint(rect(26, 27, 26, 33), TONGUE_D)
    st.eye(17, 15, look=(1, 0))
    st.eye(29, 15, look=(1, 0))
    st.paint(rect(14, 22, 15, 22) | rect(36, 21, 37, 21), BLUSH)
    st.sparkle(6, 7)
    st.sparkle(46, 8, big=False)
    st.sparkle(54, 24, big=False)
    return key, st


PALS = [tailtip_tickle, tongue_taster, creek_sipper, scale_diamonds, coil_nest, big_grin_anaconda]

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
        print('%-10s %-17s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
