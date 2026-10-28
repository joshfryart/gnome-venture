"""Puzzle Pals: TOMB OF THE SAND SCARAB (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-scr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_scr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair + palib (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-tomb-of-the-sand-scarab.png, calmed onto 2 tones of a body family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual). Each pal has its own body tone, accessory, silhouette detail, face and pose:
  1 Pyramid Speck       pyramid ochre, leans left   | a stepped pyramid hat with a gold capstone, felt boots   | dreamy hopeful: eyes up, tiny o, blush
  2 Scarab Glint        scarab teal + gold lines    | two beetle antennae with gold knobs, a sun glint on its shell | cheeky wink, tongue-out grin
  3 Dune Ticktock       pale dune cream             | a brass hourglass it hugs, tick marks                    | startled: dot eyes, brows up, O
  4 Scarab Leg March    scarab-leg violet (+ gold)  | four skinny jointed legs mid-march, a navy shako + red plume | grumpy: low brows, flat frown
  5 Sundisk Window      sundisk gold (+ wing blue)  | the tomb door's blue wings, a round peek window (one eye in it) | shy peek, blush, wobbly mouth
  6 Sandlit Scarab Charm lapis blue (rare)          | whimsy scarab: head + pronotum + elytra, 6 legs, red jewel, gold trim | dozing: closed arcs, jewel awake
Hook blanks kept small (r 2.6 to 3). No puffs. Browns lifted off mud.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-tomb-of-the-sand-scarab'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-tomb-of-the-sand-scarab-c727bc')

OCHRE = ('#d08a4a', '#e2a464')
TEAL = ('#22716f', '#2a8a8a')
DUNE = ('#f0c890', '#fbe0a8')
VIOLET = ('#783e9f', '#9460bc')
SUNG = ('#e8a317', '#f5b838')
LAPIS = ('#3a56a8', '#5274c4')
STONE = ('#e8c88a', '#c09a5a', '#fbe8b8', '#a87a44')
NAVY = ('#3e2f66', '#291d4a', '#5a4a8a', '#1f0f26')
WINGB = ('#3f8fb0', '#2a6a8a', '#65c8c4', '#1f4a6a')
RED, RED_L = '#d6322b', '#f2795a'
LINE_G = '#f5b838'
BLUSH = '#f0a0a0'
TONGUE = '#e86a6a'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def shear(m, k, cy):
    o = blank()
    for y in range(N):
        o[y] = shift(m, int(round(k * (y - cy))), 0)[y]
    return o


def brows(st, l, r, col=UMBER):
    st.paint(line(l) | line(r), col)


def arc_eye(st, x, y, up=True):
    st.sprite(['.UUU.', 'U...U'] if up else ['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def wide_eye(st, x, y):
    """Startled eye: a 7 x 7 cream disc in an umber ring, a small 2 x 2 pupil dead centre (all white round it)."""
    st.sprite(['.UUUUU.', 'UCCCCCU', 'UCCCCCU', 'UCCPPCU', 'UCCPPCU', 'UCCCCCU', '.UUUUU.'], x - 1, y - 1,
              {'U': UMBER2, 'C': CREAM, 'P': UMBER}, solid=False)


def boots(st, xs, y, w=6):
    for x in xs:
        m = rect(x, y, x + w, y + 3) & ~rect(x, y, x, y) & ~rect(x + w, y, x + w, y)
        st.part(m, SHOE[0], d=1, contour=True)


def pyramid_hat(st, cx, by, w=10, steps=4, sh=3):
    """A stepped pyramid sitting on the head: each step 1 px narrower a side per sh rows, sunlit left face, gold capstone."""
    m = blank()
    for i in range(steps):
        hw = w - i * (w / steps)
        m |= rect(int(cx - hw), by - (i + 1) * sh, int(cx + hw) - 1, by - i * sh - 1)
    st.part(m, STONE[0], d=1, contour=True)
    st.paint(m & (XX >= cx) & shrink(m, 0) & ~shift(m, 0, 1), STONE[1])          # shade right face (top rows stay lit)
    st.paint(m & (XX >= cx) & (XX > cx + 1) & shrink(m, 0), STONE[1])
    for i in range(1, steps):
        st.paint(rect(int(cx - w + i * (w / steps)), by - i * sh, int(cx + w - i * (w / steps)) - 1, by - i * sh) & m, STONE[3])
    top = by - steps * sh
    cap = poly([(cx - 3, top + 0.5), (cx, top - 3.5), (cx + 3, top + 0.5)])
    st.part(cap, GOLDP[0], d=1, contour=True)
    st.paint(cap & (XX < cx - 0.5), GOLDP[2])
    return m | cap


def antenna(st, pts, knob_xy):
    m = line(pts, w=1)
    st.part(grow(m, 0) | shift(m, 1, 0), '#1f4a4a', d=0, contour=True)
    kx, ky = knob_xy
    k = disc(kx + 0.5, ky + 0.5, 2.2)
    st.part(k, GOLDP[0], d=1, contour=True)
    st.dots([(kx - 1, ky - 1)], GOLDP[2])
    return m | k


def glint(st, x, y):
    """A painted sun glint on the shell (not a rarity sparkle): cream cross, gold ends, inside the body."""
    st.sprite(['..g..', '..W..', 'gWWWg', '..W..', '..g..'], x, y, {'g': LINE_G, 'W': '#fff3c8'}, solid=False)


def hourglass(st, x, y):
    """A brass hourglass 9 x 15: gold caps, two glass bulbs (pale blue), sand falling to the bottom bulb, posts."""
    capt, capb = rect(x, y, x + 8, y + 1), rect(x, y + 14, x + 8, y + 15)
    glass = blank()
    for j in range(12):
        t = abs(j - 5.5) / 5.5
        hw = 0.8 + 2.6 * t
        glass |= (YY == y + 2 + j) & (CX > x + 4.5 - hw) & (CX < x + 4.5 + hw)
    st.part(glass, '#cfe8ee', d=0, contour=True)
    st.paint(glass & (YY >= y + 10), '#f5b860')
    st.paint(glass & (YY >= y + 12), '#d9885a')
    st.paint(glass & (YY <= y + 4) & (YY >= y + 4), '#f5b860')
    st.paint(rect(x + 4, y + 6, x + 4, y + 10), '#f5b860')
    st.paint(glass & (XX == x + 2) & (YY < y + 6), '#ffffff')
    posts = rect(x, y + 2, x, y + 13) | rect(x + 8, y + 2, x + 8, y + 13)
    st.part(posts, '#a87030', d=0, contour=True)
    st.part(capt | capb, GOLDP[0], d=1, contour=True)
    st.paint(capt & (YY == y), GOLDP[2])
    return capt | capb | glass | posts


def tick(st, pts):
    st.paint(line(pts), CREAM)
    st.extra |= line(pts)


def march_leg(st, hip, knee, foot, col):
    m = line([hip, knee], w=2) | line([knee, foot], w=2)
    st.part(m, col, d=0, contour=True)
    fx, fy = foot
    f = rect(fx - 1, fy, fx + 2, fy + 1)
    st.part(f, '#1f0f26', d=0, contour=True)
    return m | f


def shako(st, x, y, w=9, h=8):
    """A drummer's shako: navy cylinder slightly wider at top, gold band + brim, red pompom plume."""
    m = blank()
    for j in range(h):
        m |= rect(x - (1 if j < 2 else 0), y + j, x + w + (1 if j < 2 else 0), y + j)
    st.part(m, NAVY[0], d=1, contour=True)
    st.paint(rect(x, y + h - 2, x + w, y + h - 2), GOLDP[0])
    st.paint(rect(x + 3, y + 2, x + 6, y + 4) & m, GOLDP[0])
    st.dots([(x + 4, y + 3)], RED)
    brim = rect(x - 1, y + h, x + w + 2, y + h)
    st.part(brim, '#1f0f26', d=0, contour=True)
    plume = disc(x + w / 2 + 0.5, y - 2.0, 2.6) | rect(int(x + w / 2), y - 1, int(x + w / 2), y)
    st.part(plume, RED, d=1, contour=True)
    st.dots([(int(x + w / 2) - 1, y - 4)], RED_L)
    return m | brim | plume


def sun_wing(st, x0, x1, y, side):
    """A winged-sundisk wing: 3 straight feather rows, longest on top, cream/cyan bands, squared tips (not a leaf)."""
    m = blank()
    for j, cut in enumerate((0, 2, 4)):
        if side < 0:
            m |= rect(x0 + cut, y + j * 2, x1, y + j * 2 + 1)
        else:
            m |= rect(x0, y + j * 2, x1 - cut, y + j * 2 + 1)
    st.part(m, WINGB[0], d=0, contour=True)
    st.paint(m & ((YY - y) % 2 == 0), WINGB[2])
    st.paint(m & ((XX % 3) == 0) & ((YY - y) % 2 == 1), WINGB[3])
    return m


def scarab_leg(st, pts, col):
    m = line(pts, w=2)
    st.part(m, col, d=0, contour=True)
    x, y = pts[-1]
    st.dots([(x, y)], GOLDP[0])
    return m


# ------------------------------------------------------------------ 1. Pyramid Speck: corner-BB hook, common. Ochre tomb dust in a stepped pyramid hat; leans left, dreaming.
def pyramid_speck():
    key = 'pl-scr-1'
    st = Sticker()
    core = (13, 25, 45, 50)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'hook', 6, 2.6), e=('B', 'hook', 7, 2.6))
    body, holes = shear(body, -0.12, 50), shear(holes, -0.12, 50)
    st.part(body, tex=fill(key, body, 13, 25, 33, list(OCHRE)), contour=True)
    st.blank_shade(body, holes, width=1)
    pyramid_hat(st, 25, 26, w=10, steps=3, sh=4)
    boots(st, [15, 34], 51)
    st.eye(18, 32, look=(0, -1))
    st.eye(30, 32, look=(1, -1))
    st.paint(rect(16, 39, 18, 39) | rect(34, 39, 36, 39), BLUSH)
    st.mouth('o', 25, 40)
    return key, st


# ------------------------------------------------------------------ 2. Scarab Glint: edge-TBB peg, common. Teal shell chip with gold lines, antennae, a sun glint; cheeky wink.
def scarab_glint():
    key = 'pl-scr-2'
    st = Sticker()
    core = (13, 23, 45, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.6), e=('B', 'peg', 3, 3.2), w=('B', 'peg', 3, 3.2))
    antenna(st, [(26, 16), (22, 11), (18, 9)], (16, 8))
    antenna(st, [(33, 16), (38, 11), (42, 9)], (43, 8))
    st.part(body, tex=fill(key, body, 13, 23, 32, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    seam = rect(29, 18, 29, 49) & (YY % 3 != 0)
    lines = line([(15, 45), (21, 42)]) | line([(37, 42), (43, 45)]) | line([(16, 27), (21, 25)]) | line([(38, 25), (43, 27)])
    st.paint((seam | lines) & shrink(body, 1), LINE_G)
    glint(st, 37, 18)
    st.part(ellipse(19.5, 51, 3.2, 2), '#1f4a4a', d=1, contour=True)
    st.part(ellipse(39.5, 51, 3.2, 2), '#1f4a4a', d=1, contour=True)
    st.eye(18, 30, look=(1, 0))
    st.sprite(['UU...', '..UUU', 'UU...'], 34, 31, {'U': UMBER}, solid=False)        # wink, the right eye
    st.sprite(['UUUUU', '.URRU', '..TT.'], 26, 38, {'U': UMBER, 'R': MOUTH_RED, 'T': TONGUE}, solid=False)
    st.dots([(28, 40), (29, 40)], TONGUE)
    return key, st


# ------------------------------------------------------------------ 3. Dune Ticktock: inner-TBTB double, common. Pale dune grain hugging a brass hourglass, startled by its own tick.
def dune_ticktock():
    key = 'pl-scr-3'
    st = Sticker()
    core = (10, 22, 38, 47)
    body, holes = piece_blanks(core, n=('T', 'double', -3, 3.4), e=('B', 'double', -4, 3.0), s=('T', 'double', 0, 3.4),
                               w=('B', 'double', 4, 3.0))
    st.part(body, tex=fill(key, body, 10, 22, 29, list(DUNE)), contour=True)
    st.blank_shade(body, holes, width=1)
    sand_grains(st, body & ~rect(13, 26, 33, 44), '#d9a660', every=5)
    hourglass(st, 41, 33)
    st.part(ellipse(40, 42, 3, 2.2), DUNE[0], d=1, contour=True)                   # the hugging paw
    wide_eye(st, 14, 29)
    wide_eye(st, 27, 29)
    brows(st, [(13, 25), (15, 24), (18, 24)], [(27, 24), (30, 24), (32, 25)])
    st.sprite(['.UU.', 'URRU', 'URRU', '.UU.'], 21, 38, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    tick(st, [(48, 25), (51, 22)])
    tick(st, [(52, 28), (55, 27)])
    return key, st


# ------------------------------------------------------------------ 4. Scarab Leg March: inner-TTTT tri, uncommon. Scarab-leg violet on four skinny marching legs, a shako; grumpy.
def scarab_leg_march():
    key = 'pl-scr-4'
    st = Sticker()
    core = (16, 22, 44, 42)
    body = piece(core, n=('T', 'tri', 6, 3.2), e=('T', 'tri', -2, 3.2), s=('T', 'tri', 0, 3.0), w=('T', 'tri', -2, 3.2))
    legcol = '#4a2a66'
    march_leg(st, (20, 42), (17, 47), (19, 52), legcol)
    march_leg(st, (25, 42), (25, 46), (27, 49), legcol)          # lifted mid-step
    march_leg(st, (36, 42), (36, 47), (34, 52), legcol)
    march_leg(st, (40, 42), (44, 46), (43, 50), legcol)          # lifted
    st.part(body, tex=fill(key, body, 16, 22, 29, list(VIOLET)), contour=True)
    st.stitch(body, col=LINE_G)                                     # uncommon accent: the tomb gold
    shako(st, 18, 11, w=8, h=8)
    st.eye(21, 29, look=(0, 1), lid=2)
    st.eye(33, 29, look=(0, 1), lid=2)
    brows(st, [(20, 26), (25, 28)], [(33, 28), (38, 26)])
    st.sprite(['UUUUU', 'U...U'], 27, 37, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Sundisk Window: inner-BBBB hook, uncommon. Sundisk gold with the door's blue wings and a peek window; shy.
def sundisk_window():
    key = 'pl-scr-5'
    st = Sticker()
    core = (17, 20, 46, 50)
    body, holes = piece_blanks(core, n=('B', 'hook', -6, 2.6), e=('B', 'hook', 9, 2.6), s=('B', 'hook', 4, 2.6), w=('B', 'hook', 9, 2.6))
    sun_wing(st, 8, 17, 23, -1)
    sun_wing(st, 47, 55, 23, 1)
    st.part(body, tex=fill(key, body, 17, 20, 30, list(SUNG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=WINGB[0], skip=grow(holes, 3))              # uncommon accent: wing blue
    win = disc(36.5, 31.5, 5.2)
    st.paint(win, UMBER2)
    st.paint(disc(36.5, 31.5, 4.2), NAVY[0])
    st.paint(disc(36.5, 31.5, 4.2) & (CY > 33.5), NAVY[1])
    st.eye(34, 30, look=(-1, 1), socket=None)                     # peeking through the window
    st.eye(21, 31, look=(1, 1))
    st.paint(rect(20, 38, 22, 38) | rect(40, 39, 42, 39), BLUSH)
    st.sprite(['.U.U', 'U.U.'], 28, 41, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Sandlit Scarab Charm: whimsy-scarab double, rare. A lapis scarab charm, 6 legs, red jewel still blinking; dozing.
def sandlit_scarab_charm():
    key = 'pl-scr-6'
    st = Sticker()
    head = ellipse(32, 18.5, 5.5, 3.8)
    jaws = knob('n', 'double', 32, 16, r=2.6)
    pron = ellipse(32, 27, 12, 6.5)
    ely = ellipse(32, 41, 14, 12) & (CY > 29)
    legcol = '#2a2a6a'
    for side in (-1, 1):
        scarab_leg(st, [(32 + side * 10, 25), (32 + side * 16, 21), (32 + side * 18, 15)], legcol)
        scarab_leg(st, [(32 + side * 12, 36), (32 + side * 18, 36), (32 + side * 20, 40)], legcol)
        scarab_leg(st, [(32 + side * 11, 47), (32 + side * 15, 50), (32 + side * 16, 53)], legcol)
    body = head | jaws | pron | ely
    tex = fill(key, body, 17, 14, 30, list(LAPIS))
    st.part(head | jaws, tex=tex, contour=True)
    st.part(ely, tex=tex, contour=True)
    st.part(pron, tex=tex, contour=True)
    st.paint(shrink(pron, 2) & (CY < 30) & ~shift(shrink(pron, 2), -1, -1), '#6a8ad8')   # a lifted face plate so the face reads
    gold = (ely & ~shrink(ely, 1)) | (ely & (XX == 32))
    st.paint(gold & shrink(ely | pron, 0), GOLDP[1])
    st.paint(line([(21, 41), (26, 38)]) | line([(38, 38), (43, 41)]) | line([(22, 47), (27, 45)]) | line([(37, 45), (42, 47)]), LINE_G)
    st.paint(pron & ~shrink(pron, 1) & (CY > 29), GOLDP[1])
    jewel = disc(32.5, 18.5, 2.4)
    st.paint(grow(jewel, 1) & ~jewel, UMBER2)
    st.paint(jewel, RED)
    st.dots([(31, 17)], '#fff3c8')
    st.eye(23, 24, look=(0, 1), lid=2)
    st.eye(36, 24, look=(0, 1), lid=2)
    st.paint(rect(21, 30, 22, 30) | rect(41, 30, 42, 30), BLUSH)
    st.sprite(['U...U', '.UUU.'], 30, 30, {'U': UMBER}, solid=False)
    st.sparkle(6, 27)
    st.sparkle(52, 7, big=False)
    st.sparkle(53, 45, big=False)
    return key, st


PALS = [pyramid_speck, scarab_glint, dune_ticktock, scarab_leg_march, sundisk_window, sandlit_scarab_charm]

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
        print('%-10s %-21s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
