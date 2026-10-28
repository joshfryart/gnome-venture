"""Puzzle Pals: MANGROVE ROOT MAZE (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-mgr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_mgr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve = cosy-curious cave beasts and the dark's small treasures. kit_lair parts are building blocks only; the rest is drawn here.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/delve-mangrove-root-maze.png,
calmed onto 2 tones of a pal-own colour family from the picture (tidal teal, frog lime, lantern blue, root rust, warm sky, leaf green).
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Tidewater Toes    tidal teal         | striped bath towel on its head, webbed toes dipping in a ripple, bubbles | sleepy: closed arcs, :3
  2 Frog Peeper       frog lime          | a mossy log it peeks over, frog fingers, a gnat to blink at             | startled bulge eyes up, o
  3 Jarlight Twig     lantern blue       | a firefly jar hung on a twig held high, glow dots                       | smug half lids, smirk
  4 Stiltroot Prance  root rust (+ moss) | four knobbly stilt-root legs mid-dance, one kicked up, splash dots       | cheeky wink, tongue grin
  5 Tangle Gap        warm sky (+ root)  | a wreath of tangled roots round a clear gap, the low sun in it           | shy dot eyes, blush
  6 Mazeroot Mangrove leaf green (rare)  | whimsy mangrove: canopy, aerial roots, stilt-root maze over dark water   | puzzled oval eyes, wavy mouth, ?
Ring and Plus knobs are centred (n, s at 0; e, w at the same height), no hooks.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-mangrove-root-maze'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-mangrove-root-maze-195d16')

TEAL = ('#3a8a88', '#4fa49c')
LIME = ('#78b45a', '#94c86e')
LBLUE = ('#3c5ca0', '#5074b8')
RUST = ('#a45a36', '#bc7248')
SKY = ('#eccb8e', '#f6e0ac')
LEAF = ('#3e7a4c', '#55955c')
WATER = ('#285e60', '#1c464c', '#4a8a88', '#163638')
ROOT = ('#7a3a26', '#57181d', '#a8603a', '#3a1418')
MOSS = ('#7ab55c', '#4a8a5a', '#acc47d', '#2f5a3a')
LOG = ('#8a4c27', '#6a3420', '#b06a3a', '#481617')
GLASS = ('#bfe0e8', '#8abccc', '#eefaff', '#5a8a9a')
CORK = ('#c9a46a', '#9a7448', '#f2d6a7', '#6a4a2a')
TOWEL = ('#f2e4c0', '#d2bf96', '#fff3c8', '#a8916a')
CORAL = '#e07a5a'
BLUSH = '#f0a0a0'
FIRE = '#f5e070'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


def extra_sprite(st, rows_, x, y, cmap):
    st.sprite(rows_, x, y, cmap, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch not in '. ':
                st.extra[y + j, x + i] = True


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def ripple(st, cx, cy, rx, ry):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, WATER[2], d=1, contour=True)
    st.paint((line([(cx - rx + 3, cy + 1), (cx - rx + 7, cy + 1)]) | line([(cx + rx - 8, cy), (cx + rx - 4, cy)])) & m, '#9bc8c2')
    return m


def webbed_toes(st, x, y, col):
    """A dangling webbed foot: a short leg and 3 splayed toe tips, half sunk in the water."""
    st.sprite(['.LL.', '.LL.', 'LLLL', 'L.LL', 'L..L'], x, y, {'L': col}, solid=True)


def towel(st, x0, x1, y):
    """A folded bath towel on the head: a cream slab with two coral stripes, one end flopping down the side."""
    slab = rect(x0, y, x1, y + 4)
    slab[y, x0] = slab[y, x1] = False
    flop = rect(x1 - 3, y + 4, x1, y + 9) & ~rect(x1, y + 9, x1, y + 9)
    m = slab | flop
    st.part(m, TOWEL[0], d=1, contour=True)
    st.paint(m & ((XX == x0 + 3) | (XX == x0 + 6)) & (YY <= y + 4), CORAL)
    st.paint(rect(x1 - 3, y + 9, x1 - 1, y + 9) & (XX % 2 == 0), TOWEL[1], solid=True)   # fringe
    return m


def bubble(st, x, y, big=True):
    rows_ = ['.CC.', 'C..C', 'C..C', '.CC.'] if big else ['.C.', 'C.C', '.C.']
    extra_sprite(st, rows_, x, y, {'C': '#d8f0f0'})


def closed_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def mossy_log(st, x0, x1, y0, y1):
    """A fallen log across the front: bark with grain lines, a cut end with rings on the right, moss tufts along its top."""
    body = rect(x0, y0, x1 - 3, y1)
    body[y0, x0] = body[y1, x0] = False
    end = ellipse(x1 - 3, (y0 + y1 + 1) / 2, 3.6, (y1 - y0 + 1) / 2)
    st.part(body, LOG[0], d=2, contour=True)
    st.paint(body & ((YY == y0 + 3) | (YY == y0 + 7)) & ((XX + YY) % 7 > 1), LOG[1])
    st.part(end, '#d2a470', d=1, contour=True)
    st.paint(end & ~shrink(end, 1), LOG[1])
    st.paint(ellipse(x1 - 3, (y0 + y1 + 1) / 2, 1.6, 2.6) & ~ellipse(x1 - 3, (y0 + y1 + 1) / 2, 0.8, 1.4), '#a8784a')
    moss = blank()
    for cx in range(x0 + 2, x1 - 6, 5):
        moss |= ellipse(cx + 1.5, y0 + 0.5, 2.6, 1.8)
    st.part(moss, MOSS[0], d=1, contour=False)
    st.paint(moss & (YY < y0), MOSS[2])
    return body | end | moss


def frog_eye(st, cx, cy, col, look=(0, -1)):
    """Bulging frog eye on a body-tone dome: big cream ball, 2 x 3 pupil, glint."""
    st.part(disc(cx, cy, 5.2), col, d=1, contour=False)
    st.paint(grow(disc(cx, cy, 3.4), 1), UMBER2)
    st.paint(disc(cx, cy, 3.4), CREAM)
    px, py = int(cx - 1 + look[0]), int(cy - 1 + look[1])
    st.paint(rect(px, py, px + 1, py + 2), UMBER)
    st.dots([(px, py)], CREAM)


def gnat(st, x, y):
    extra_sprite(st, ['W.W', '.U.', '.U.'], x, y, {'W': '#eef8fc', 'U': UMBER})


def jar_twig(st, x0, y0, x1, y1):
    """A twig held up from the hand (x0, y0) to (x1, y1), a firefly jar dangling off its tip on a thread."""
    tw = line([(x0, y0), (x1, y1)], w=2)
    st.part(tw, LOG[0], d=0, contour=True)
    st.paint(line([(x1 - 3, y1 + 4), (x1 - 6, y1 + 2)]) , LOG[0], solid=True)        # a side sprig
    st.paint(disc(x1 - 6.5, y1 + 1.5, 1.4), MOSS[0], solid=True)
    jx, jy = x1 + 1, y1 + 4
    st.paint(rect(jx, y1 + 1, jx, jy - 1), CREAM, solid=True)                         # thread
    jar = rect(jx - 3, jy + 2, jx + 3, jy + 9)
    jar[jy + 9, jx - 3] = jar[jy + 9, jx + 3] = False
    lid = rect(jx - 2, jy, jx + 2, jy + 1)
    st.part(jar, GLASS[0], d=1, contour=True)
    st.part(lid, CORK[0], d=1, contour=True)
    st.paint(disc(jx + 0.5, jy + 6, 2.2) & jar, FIRE)
    st.paint(rect(jx, jy + 5, jx, jy + 6), '#fffbe0')
    st.paint(rect(jx - 2, jy + 3, jx - 2, jy + 5), GLASS[2])
    for x, y in ((jx - 6, jy + 4), (jx + 6, jy + 2), (jx + 5, jy + 11)):
        st.dots([(x, y)], FIRE)
        st.extra[y, x] = True
    return tw | jar | lid


def stilt_leg(st, pts, foot):
    m = line(pts, w=3)
    for x, y in pts[1:-1]:
        m |= disc(x + 0.5, y + 0.5, 2.0)                                              # knobbly joints
    st.part(m, ROOT[0], d=1, contour=True)
    st.paint(line(pts[:2], w=1) & shrink(m, 1), ROOT[2])
    if foot:
        fx, fy = pts[-1]
        st.paint(rect(fx - 2, fy + 1, fx + 2, fy + 1) & (XX % 2 == fx % 2), ROOT[1], solid=True)   # root-tip toes
    return m


def tangle(st, body, gap, paths):
    v = blank()
    for p in paths:
        v |= line(p, w=2)
    v &= body & ~gap
    st.paint(v, ROOT[0])
    st.paint(v & ~shift(v, 1, 1), ROOT[2])
    st.paint(v & ~shift(v, -1, -1), ROOT[1])
    return v


def low_sun(st, cx, cy, r=3.2):
    m = disc(cx, cy, r)
    st.paint(m, '#f5b850')
    st.paint(m & (CY < cy - 0.5), GOLD)
    st.paint(rect(int(cx - r - 2), int(cy) + 2, int(cx + r) + 1, int(cy) + 2) & ((XX % 3) != 0), '#e8a060')   # a haze line
    return m


def oval_eye(st, x, y, look=(0, 0)):
    """Tall oval eye 4 x 6 with an umber socket and a 2 x 2 pupil."""
    e = ellipse(x + 2, y + 3, 2.1, 3.2)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, CREAM)
    px, py = x + 1 + look[0], y + 2 + look[1]
    st.paint(rect(px, py, px + 1, py + 1), UMBER)


# ------------------------------------------------------------------ 1. Tidewater Toes: corner-TB round, common. Tidal teal, toes in the tide, a bath towel on its head.
def tidewater_toes():
    key = 'pl-mgr-1'
    st = Sticker()
    core = (13, 23, 44, 46)
    ripple(st, 29, 52, 21, 4.2)
    body, holes = piece_blanks(core, n=('T', 'round', -7, 3.8), e=('B', 'round', 1, 3.2))
    st.part(body, tex=fill(key, body, 13, 23, 32, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 45), col='#b8e0d8', skip=grow(holes, 3))
    for x in (18, 34):
        webbed_toes(st, x, 47, '#2f7a78')
    st.paint(rect(16, 51, 42, 51) & ((XX % 4) == 0), '#9bc8c2', solid=True)      # the waterline over its toes
    towel(st, 27, 41, 18)
    closed_eye(st, 18, 32)
    closed_eye(st, 30, 32)
    st.paint(rect(17, 35, 19, 35) | rect(34, 35, 36, 35), BLUSH)
    st.mouth('cat', 24, 37)
    bubble(st, 50, 12)
    bubble(st, 55, 20, big=False)
    bubble(st, 8, 14, big=False)
    return key, st


# ------------------------------------------------------------------ 2. Frog Peeper: edge-TTB peg, common. Frog lime, bulging eyes over a mossy log, blinking at a gnat.
def frog_peeper():
    key = 'pl-mgr-2'
    st = Sticker()
    core = (14, 24, 45, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 3.0), e=('T', 'peg', -3, 3.2), w=('T', 'peg', -3, 3.2))
    st.part(body, tex=fill(key, body, 14, 24, 32, list(LIME)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 40), col='#d8ecb0', skip=grow(holes, 3))
    frog_eye(st, 20, 25, LIME[1], look=(-1, -1))
    frog_eye(st, 39, 25, LIME[1], look=(-1, -1))
    st.sprite(['.UU.', 'URRU', '.UU.'], 28, 34, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(16, 34, 18, 34) | rect(41, 34, 43, 34), BLUSH)
    mossy_log(st, 9, 55, 40, 51)
    st.sprite(['F.F.F', 'FFFFF'], 18, 38, {'F': LIME[0]}, solid=True)          # frog fingers on the log
    st.sprite(['F.F.F', 'FFFFF'], 36, 38, {'F': LIME[0]}, solid=True)
    gnat(st, 8, 11)
    return key, st


# ------------------------------------------------------------------ 3. Jarlight Twig: inner-TBTB tri, common. Lantern blue, holds a firefly jar high on a twig, smug.
def jarlight_twig():
    key = 'pl-mgr-3'
    st = Sticker()
    core = (12, 25, 41, 49)
    body, holes = piece_blanks(core, n=('T', 'tri', -4, 3.4), e=('B', 'tri', 0, 2.8), s=('T', 'tri', 0, 3.2), w=('B', 'tri', 0, 2.8))
    st.part(body, tex=fill(key, body, 12, 25, 30, list(LBLUE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=FIRE, skip=grow(holes, 3))
    jar_twig(st, 40, 31, 49, 8)
    st.sprite(['.HH', 'HHH', 'HH.'], 39, 30, {'H': LBLUE[1]}, solid=True)         # the hand on the twig
    st.eye(16, 31, look=(1, -1), lid=2)
    st.eye(28, 31, look=(1, -1), lid=2)
    st.paint(line([(28, 28), (31, 27), (33, 28)]), UMBER)
    st.mouth('smirk', 22, 40)
    return key, st


# ------------------------------------------------------------------ 4. Stiltroot Prance: inner-TTTT double, uncommon. Root rust, four knobbly stilt-root legs mid-dance, cheeky wink.
def stiltroot_prance():
    key = 'pl-mgr-4'
    st = Sticker()
    core = (19, 17, 44, 40)
    legs = [([(21, 39), (15, 46), (12, 53)], True), ([(27, 40), (24, 47), (25, 54)], True),
            ([(37, 40), (41, 46), (40, 54)], True), ([(43, 38), (49, 43), (55, 44)], False)]   # the last one kicked out
    for pts, foot in legs:
        stilt_leg(st, pts, foot)
    body = piece(core, n=('T', 'double', 0, 3.2), e=('T', 'double', 0, 3.2), s=('T', 'double', 0, 3.0), w=('T', 'double', 0, 3.2))
    st.part(body, tex=fill(key, body, 19, 17, 26, list(RUST)), contour=True)
    st.stitch(body, col=MOSS[0])                                                    # uncommon accent: the moss green
    st.eye(22, 24, look=(1, 0))
    closed_eye(st, 34, 26)
    st.paint(line([(34, 23), (38, 22)]), UMBER)
    st.sprite(['UUUUUUU', 'U.RRR.U', '.UURUU.'], 25, 33, {'U': UMBER, 'R': '#e06070'}, solid=False)
    for x, y in ((10, 56), (14, 56), (27, 57), (42, 57)):
        if y <= 57:
            st.dots([(x, y)], '#9bc8c2')
            st.extra[y, x] = True
    return key, st


# ------------------------------------------------------------------ 5. Tangle Gap: inner-BBBB round, uncommon. Warm sky through a wreath of tangled roots, the low sun in it, shy.
def tangle_gap():
    key = 'pl-mgr-5'
    st = Sticker()
    core = (13, 15, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.2), e=('B', 'round', 0, 3.2), s=('B', 'round', 0, 3.2), w=('B', 'round', 0, 3.2))
    gap = disc(32, 33, 12.5)
    st.part(body, tex=fill(key, body, 13, 15, 38, list(SKY)))
    st.paint(body & ~gap & shrink(body, 2), '#dca870')                          # the shaded tangle round the bright gap
    st.paint(gap & shrink(gap, 2), '#fbecc0')
    tangle(st, body, gap, [[(13, 20), (24, 17), (34, 22), (44, 16), (51, 21)],
                           [(13, 44), (21, 49), (30, 45), (40, 50), (51, 45)],
                           [(16, 15), (19, 27), (15, 36), (19, 50)],
                           [(47, 15), (45, 26), (49, 37), (45, 50)],
                           [(13, 30), (22, 22)], [(42, 22), (51, 30)], [(13, 38), (21, 45)], [(43, 45), (51, 38)]])
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=ROOT[1], skip=grow(holes, 3) | gap)                         # uncommon accent: the dark root red
    st.paint(gap & ~shrink(gap, 1) & body, ROOT[3])                                 # the gap's rim
    low_sun(st, 27, 25, r=2.6)
    st.paint(rect(24, 31, 26, 33) | rect(36, 31, 38, 33), UMBER)                    # shy dot eyes, looking down
    st.dots([(24, 31), (36, 31)], CREAM)
    st.paint(rect(22, 36, 24, 36) | rect(38, 36, 40, 36), BLUSH)
    st.sprite(['U.U', '.U.'], 30, 37, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Mazeroot Mangrove: whimsy-mangrove tri, rare. A little mangrove, roots tangled into a maze over dark water, puzzled.
def mazeroot_mangrove():
    key = 'pl-mgr-6'
    st = Sticker()
    water = ellipse(32, 51, 22, 2.5)
    st.part(water, WATER[0], d=1, contour=True)
    st.paint(water & (YY == 51) & ((XX % 5) < 2), WATER[2])
    trunk = rect(28, 33, 35, 43)
    roots = blank()
    for pts in ([(29, 39), (22, 40), (17, 44), (15, 50)], [(30, 41), (26, 45), (24, 50)], [(34, 41), (38, 45), (40, 50)],
                [(35, 39), (42, 40), (47, 44), (49, 50)], [(22, 40), (27, 45), (33, 45), (38, 45)], [(17, 44), (24, 47)], [(47, 44), (40, 47)]):
        roots |= line(pts, w=2)
    st.part(trunk | roots, ROOT[0], d=1, contour=True)
    st.paint(trunk & (XX == 29), ROOT[2])
    st.paint(roots & ~shift(roots, 1, 1), ROOT[2])
    canopy = ellipse(32, 25, 21, 10) | ellipse(18, 29, 9, 6) | ellipse(46, 29, 9, 6)
    tab = knob('n', 'tri', 32, 15, r=2.6)
    body = canopy | tab
    st.part(body, tex=fill(key, body, 11, 9, 42, list(LEAF), dy=0.1), contour=True)
    st.stitch(canopy, col=MOSS[2])
    for x, h in ((14, 8), (50, 7)):                                                 # aerial roots dangling from the canopy
        st.paint(rect(x, 33, x, 33 + h - 2), ROOT[2], solid=True)
    oval_eye(st, 22, 21, look=(-1, -1))
    oval_eye(st, 37, 21, look=(1, 1))
    st.paint(line([(36, 18), (39, 17), (42, 18)]), UMBER)
    st.sprite(['.U...U.', 'U.U.U.U'], 29, 30, {'U': UMBER}, solid=False)
    st.paint(rect(18, 29, 20, 29) | rect(43, 29, 45, 29), BLUSH)
    extra_sprite(st, ['.CCC.', 'C...C', '...C.', '..C..', '.....', '..C..'], 52, 6, {'C': CREAM})
    st.sparkle(5, 8)
    st.sparkle(56, 40, big=False)
    st.sparkle(6, 42, big=False)
    return key, st


PALS = [tidewater_toes, frog_peeper, jarlight_twig, stiltroot_prance, tangle_gap, mazeroot_mangrove]

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
        print('%-10s %-18s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
