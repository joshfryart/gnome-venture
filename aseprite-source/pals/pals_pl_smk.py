"""Puzzle Pals: SMOKECAP CALDERA (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-smk-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_smk.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-smokecap-caldera.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Ashpuff Drifter    dusk periwinkle          | a too-small orange bobble hat, a smoke-wisp tail (no feet)     | cheeky wink, tongue out
  2 Smokecap Button    warm mushroom mauve-grey | a speckled grey mushroom cap, a raindrop on the brim, stems   | shy dot eyes, blush, tiny smile
  3 Ember Speckle      lemon glow yellow        | orange heat rays, a marshmallow on a stick it is toasting      | startled ring eyes, wobbly mouth
  4 Caldera Prongs     lifted crater-rock tan   | 4 prong tips glowing, lava cracks, a summit flag, soot boots   | grumpy unibrow, underbite fangs
  5 Smoke Ringlet      sky rose pink            | a smoke-ring halo, blowing a little ring, floats (no feet)     | smug half lids, side glance, pucker
  6 Sleepy Salamander  wine-berry + yellow spots (rare) | whimsy salamander: side view, curled tail, 4 legs, snore rings | fast asleep arcs, blush
Hook blanks kept small (r 2.6). No ash puffs (smoke shown as hollow rings and a wisp). Browns lifted for dark pages.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-smokecap-caldera'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-smokecap-caldera-32490a')

PERI = ('#7476b4', '#9494c8')          # dusk periwinkle sky
MUSH = ('#8e7c86', '#a8969e')          # warm mushroom mauve-grey
LEMON = ('#eed45a', '#f8e88e')         # glowing lemon spot
ROCK = ('#a46e58', '#bc8a70')          # crater rock, lifted off mud
ROSE = ('#c886ac', '#dca2c2')          # sky rose
WINE = ('#982a46', '#b23e5a')          # salamander berry
SPOT = '#f5cf6a'
RING = '#e8dcd8'
BLUSH = '#f0a0a0'
TONGUE = '#e8707a'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def wink(st, x, y):
    st.sprite(['.....', 'U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def dot_eye(st, x, y):
    st.sprite(['UUU', 'UCU', 'UUU'], x, y, {'U': UMBER, 'C': CREAM}, solid=False)
    st.px[y + 1, x + 1] = hx(UMBER)
    st.px[y, x] = hx(CREAM)


def ring_eye(st, x, y):
    """Startled: a wide cream eye with a tiny pinprick pupil."""
    so = rect(x - 1, y - 1, x + 5, y + 5)
    for cx, cy in ((x - 1, y - 1), (x + 5, y - 1), (x - 1, y + 5), (x + 5, y + 5)):
        so[cy, cx] = False
    st.paint(so, UMBER2)
    e = rect(x, y, x + 4, y + 4)
    for cx, cy in ((x, y), (x + 4, y), (x, y + 4), (x + 4, y + 4)):
        e[cy, cx] = False
    st.paint(e, CREAM)
    st.dots([(x + 2, y + 2)], UMBER)
    st.dots([(x + 2, y + 1)], UMBER)


def sleep_arc(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def bobble_hat(st, cx, y, w=7, tilt=2):
    """A too-small knitted bobble hat, tilted; orange with cream rib band and a cream pompom."""
    dome = poly([(cx - w, y), (cx - w + 1, y - 4), (cx - 2 + tilt, y - 7), (cx + 3 + tilt, y - 7), (cx + w, y - 3), (cx + w, y)])
    band = rect(int(cx - w - 1), int(y), int(cx + w), int(y) + 2)
    m = dome | band
    st.part(m, '#e0703a', d=1, contour=True)
    st.paint(dome & ((XX % 3) == 0) & shrink(dome, 1), '#c4542e')
    st.paint(band, '#f2e4c0')
    st.paint(band & ((XX % 2) == 0), '#d2bf96')
    pom = disc(cx + tilt + 1, y - 9, 2.6)
    st.part(pom, '#f2e4c0', d=1, contour=True)
    return m | pom


def wisp_tail(st, pts, r0, col):
    """A smoke wisp: overlapping discs along a path, tapering, curling at the end."""
    m = blank()
    n = len(pts)
    for i, (x, y) in enumerate(pts):
        m |= disc(x, y, max(1.1, r0 * (1 - i / n)))
    st.part(m, col[1], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1), '#c8c8e4')
    return m


def mush_cap(st, cx, y, w=13):
    cap = ellipse(cx, y, w, 7) & (CY < y + 1.5)
    st.part(cap, '#6e6470', d=2, contour=True)
    st.paint(rect(int(cx - w + 1), int(y) + 1, int(cx + w - 1), int(y) + 1) & cap, '#4e4652')
    for x, yy, r in ((cx - 6, y - 3, 1.6), (cx + 2, y - 5, 1.2), (cx + 7, y - 1, 1.5), (cx - 1, y - 1, 1.0)):
        st.paint(disc(x, yy, r) & shrink(cap, 1), '#d8d0d8')
    return cap


def raindrop(st, x, y):
    st.sprite(['..B..', '.BB..', 'BBLB.', 'BLBB.', '.BB..'], x, y, {'B': '#7ab0dc', 'L': '#e8f4fc'}, solid=True)


def toast_stick(st, x0, y0, x1, y1):
    stick = line([(x0, y0), (x1, y1)], w=1)
    st.part(stick, '#8a5a3a', d=0, contour=True)
    mm = rect(x1 - 2, y1 - 5, x1 + 2, y1)
    mm[y1 - 5, x1 - 2] = mm[y1 - 5, x1 + 2] = mm[y1, x1 - 2] = mm[y1, x1 + 2] = False
    st.part(mm, '#fbf4e4', d=1, contour=True)
    st.paint(mm & (YY >= y1 - 1), '#c88a4a')
    st.paint(mm & (YY == y1 - 2) & ((XX % 2) == 0), '#e0b070')
    return stick | mm


def heat_rays(st, pts):
    for (x0, y0, x1, y1) in pts:
        m = line([(x0, y0), (x1, y1)], w=1)
        m |= shift(m, 1, 0)
        st.part(m, '#f08a24', d=0, contour=False)
        st.paint(m & ~shift(m, 0, 1), '#f5b840')
        st.sil |= m


def flag(st, x, y, h=12):
    pole = rect(x, y - h, x, y)
    st.paint(pole, '#5b4a50', solid=True)
    cloth = poly([(x + 1, y - h), (x + 8, y - h + 2.5), (x + 1, y - h + 5)])
    st.part(cloth, '#e8504a', d=1, contour=True)
    st.paint(cloth & (YY == y - h + 2) & (XX >= x + 2) & (XX <= x + 3), '#f2e4c0')
    st.dots([(x, y - h - 1)], GOLD)
    st.sil[y - h - 1, x] = True


def smoke_ring(st, cx, cy, rx, ry, col=RING):
    o = ellipse(cx, cy, rx, ry)
    i = ellipse(cx, cy, max(0.6, rx - 1.6), max(0.6, ry - 1.4))
    m = o & ~i
    st.paint(m, col)
    st.paint(m & (CY > cy + ry * 0.3) & (CX > cx - rx * 0.2), '#b8a8c4')
    st.extra |= m
    return m


def legs(st, specs, col):
    for x, y, w, h in specs:
        m = ellipse(x, y, w, h)
        st.part(m, col, d=1, contour=True)
        st.paint(rect(int(x - w) + 1, int(y + h) - 1, int(x + w) - 1, int(y + h) - 1) & m & ((XX % 2) == 0), SPOT)


# ------------------------------------------------------------------ 1. Ashpuff Drifter: corner-TT hook, common.
def ashpuff_drifter():
    key = 'pl-smk-1'
    st = Sticker()
    core = (14, 22, 44, 46)
    wisp_tail(st, [(16, 46), (13, 49), (10, 47), (10, 43), (12, 41)], 4.0, PERI)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'hook', 6, 3.0), e=('T', 'hook', 4, 3.0, True))
    st.part(body, tex=fill(key, body, 14, 22, 31, list(PERI)), contour=True)
    st.stitch(body, col='#c8c8e4')
    bobble_hat(st, 22, 22, w=7, tilt=-2)
    st.eye(18, 29, look=(1, -1))
    wink(st, 31, 28)
    st.sprite(['U...U', '.UUU.', '..R..'], 24, 37, {'U': UMBER, 'R': TONGUE}, solid=False)
    st.paint(rect(16, 36, 18, 36) | rect(36, 35, 38, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Smokecap Button: edge-TBT tri, common.
def smokecap_button():
    key = 'pl-smk-2'
    st = Sticker()
    core = (15, 25, 45, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 3.4), e=('B', 'tri', 3, 3.2), w=('T', 'tri', 4, 3.4))
    st.part(body, tex=fill(key, body, 15, 25, 31, list(MUSH)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in (21, 36):
        st.part(rect(x, 49, x + 4, 52) & ~rect(x, 52, x, 52) & ~rect(x + 4, 52, x + 4, 52), '#e8dcc8', d=1, contour=True)
    mush_cap(st, 31, 23, w=15)
    raindrop(st, 15, 24)
    dot_eye(st, 22, 33)
    dot_eye(st, 35, 33)
    st.paint(rect(19, 38, 21, 38) | rect(38, 38, 40, 38), BLUSH)
    st.sprite(['U.U', '.U.'], 29, 39, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Ember Speckle: inner-TBBB peg, common.
def ember_speckle():
    key = 'pl-smk-3'
    st = Sticker()
    core = (12, 21, 42, 48)
    heat_rays(st, [(12, 15, 11, 13), (24, 13, 24, 11), (36, 15, 37, 13)])
    body, holes = piece_blanks(core, n=('T', 'peg', 2, 3.2), e=('B', 'peg', 2, 3.0), s=('B', 'peg', -3, 3.0), w=('B', 'peg', 3, 3.0))
    st.part(body, tex=fill(key, body, 12, 21, 31, list(LEMON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & ~shrink(body, 1) & ~grow(holes, 1) & (CY < 30), '#fff3c8')
    for x, y in ((16, 42), (37, 24), (35, 43)):
        st.paint(disc(x, y, 1.2) & shrink(body, 2), '#f0a030')
    toast_stick(st, 40, 44, 53, 23)
    st.part(rect(15, 49, 20, 52) & ~rect(15, 49, 15, 49) & ~rect(20, 49, 20, 49), SHOE[0], d=1, contour=True)
    st.part(rect(30, 49, 35, 52) & ~rect(30, 49, 30, 49) & ~rect(35, 49, 35, 49), SHOE[0], d=1, contour=True)
    ring_eye(st, 17, 28)
    ring_eye(st, 30, 28)
    st.paint(line([(17, 25), (20, 24)]) | line([(31, 24), (34, 25)]), UMBER)
    st.sprite(['.U.U.', 'U.U.U'], 24, 38, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 4. Caldera Prongs: inner-TTTT double, uncommon.
def caldera_prongs():
    key = 'pl-smk-4'
    st = Sticker()
    core = (17, 25, 44, 48)
    body = piece(core, n=('T', 'double', -3, 3.6), e=('T', 'double', 2, 3.4), s=('T', 'double', -4, 3.2), w=('T', 'double', 3, 3.4))
    flag(st, 26, 19, h=10)
    st.part(body, tex=fill(key, body, 17, 23, 28, list(ROCK)), contour=True)
    tips = body & ~rect(core[0] - 3, core[1] - 3, core[2] + 3, core[3] + 3)
    st.paint(tips & ~shrink(body, 1), '#f08a24')
    st.paint(tips & shrink(body, 1), '#f5b840')
    v = (line([(19, 41), (23, 44), (27, 42)]) | line([(37, 45), (40, 41), (43, 43)]) | line([(40, 25), (42, 29)])) & shrink(body, 2)
    st.paint(v, '#f08a24')
    st.stitch(body & rect(core[0], core[1], core[2], core[3]), col='#f5b840')
    claw_feet(st, [18, 37], 52, w=6, h=3)
    st.eye(21, 31, look=(0, 0), lid=1)
    st.eye(33, 31, look=(0, 0), lid=1)
    st.paint(line([(20, 28), (26, 30), (31, 30), (38, 28)]), UMBER)
    st.paint(line([(20, 29), (26, 31)]) | line([(32, 31), (38, 29)]), UMBER)
    st.paint(rect(25, 41, 32, 41), UMBER)
    st.sprite(['C....C', 'C....C'], 26, 39, {'C': CREAM}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Smoke Ringlet: inner-BBBB hook, uncommon.
def smoke_ringlet():
    key = 'pl-smk-5'
    st = Sticker()
    core = (13, 24, 46, 50)
    # blanks centred on n/s and level on e/w (mirror-symmetric, never offset round the piece: that read as a hooked-cross pinwheel)
    body, holes = piece_blanks(core, n=('B', 'hook', 0, 2.0), e=('B', 'hook', 4, 2.0), s=('B', 'hook', 0, 2.0), w=('B', 'hook', 4, 2.0))
    st.part(body, tex=fill(key, body, 13, 24, 34, list(ROSE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0aa98', skip=grow(holes, 3))
    smoke_ring(st, 25, 15, 8.5, 4.2)
    smoke_ring(st, 54, 31, 3.6, 3.6)
    st.eye(18, 31, look=(1, 0), lid=2)
    st.eye(36, 31, look=(1, 0), lid=2)
    st.paint(line([(35, 28), (38, 27), (41, 28)]), UMBER)
    st.sprite(['.U.', 'URU', '.U.'], 33, 39, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(19, 37, 21, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Sleepy Salamander: whimsy-salamander peg, rare.
def sleepy_salamander():
    key = 'pl-smk-6'
    st = Sticker()
    legs(st, [(23, 45, 2.4, 3.0), (38, 45, 2.4, 3.0)], '#7a1e38')
    torso = ellipse(31, 39, 11.5, 6.2)
    head = ellipse(46.5, 34.5, 7.5, 6.5)
    neck = ellipse(40, 37, 4, 4.5)
    tail = blank()
    tp = [(21, 41), (18, 42.5), (15, 43), (12.5, 42), (11, 39.5), (11.5, 37), (13.5, 35.5)]
    for i, (x, y) in enumerate(tp):
        tail |= disc(x, y, 3.4 - i * 0.3)
    tab = knob('n', 'peg', 30, 33.5, r=3.0)
    body = torso | head | tail | tab | neck
    tex = fill(key, body, 9, 22, 44, list(WINE))
    st.part(tail, tex=tex, contour=True)
    st.part(torso | tab | neck, tex=tex, contour=True)
    st.part(head, tex=tex, contour=True)
    st.paint(body & ~shrink(body, 1) & (CY < 36) & ~shift(body, 1, 1), '#d05a72')
    for x, y, r in ((24, 37, 1.5), (31, 36, 1.7), (37, 39, 1.4), (15, 41, 1.1), (29, 42, 1.1), (47, 30, 1.1)):
        st.paint(disc(x, y, r) & shrink(body, 2), SPOT)
    st.paint(rect(29, 28, 30, 29), SPOT)
    legs(st, [(27, 47, 2.6, 3.0), (43, 46, 2.6, 3.0)], '#a8324e')
    st.stitch(torso | neck, col='#fff3c8', depth=2)
    for x, y, r in ((24, 37, 1.9), (32, 36, 2.0), (37, 40, 1.5), (15, 41, 1.3), (47, 30, 1.2)):
        st.paint(disc(x, y, r) & shrink(body, 1), SPOT)
        st.paint(disc(x - 0.6, y - 0.6, 0.7) & shrink(body, 1), '#fff3c8')
    sleep_arc(st, 43, 33)
    st.dots([(52, 33)], UMBER)
    st.paint(rect(42, 37, 43, 37), BLUSH)
    st.sprite(['U...U', '.UUU.'], 47, 38, {'U': UMBER}, solid=False)
    smoke_ring(st, 51, 21, 2.6, 2.6)
    smoke_ring(st, 55, 12, 3.6, 3.6)
    st.sparkle(8, 14)
    st.sparkle(33, 17, big=False)
    st.sparkle(6, 50, big=False)
    return key, st


PALS = [ashpuff_drifter, smokecap_button, ember_speckle, caldera_prongs, smoke_ringlet, sleepy_salamander]

if __name__ == '__main__':
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-10s %-18s %-9s %-18s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
