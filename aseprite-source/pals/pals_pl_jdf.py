"""Puzzle Pals: LAIR OF THE JADE DRAGON-FLY (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-jdf-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_jdf.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-of-the-jade-dragon-fly.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Wing Jot          pale wing-glass mint + blue veins | a hummed music note drifting off, tri tabs      | cheeky wink, tongue out
  2 Reedleg Cling     reed olive                        | hugs a cattail reed, six tiny legs, sweat drop  | determined, gritted teeth
  3 Jade Shimmer      deep pond jade                    | gold-rim sunglasses, glitter flecks             | smug cool, smirk
  4 Jadewing Quartet  sky blue                          | four glassy wing bits, a red racer headband "1" | eager, eyes up, big grin
  5 Lantern Eye Pair  dusk slate                        | two huge glowing orange compound eyes, tiny horns, gold dangle | shy, looks down, blush
  6 Lotus Perch       lotus pink on a jade pad (rare)   | whimsy lotus silhouette, a mini jade dragon-fly napping on top | blissful ^ ^, glow
Hook blanks kept small (r 3). No puffs. Browns lifted for dark pages.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-of-the-jade-dragon-fly'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-of-the-jade-dragon-fly-88201f')

GLASS = ('#a6dccc', '#d2f0e4')
VEIN = '#4a90b0'
REED = ('#6f8a3a', '#8ea64c')
POND = ('#2a8a84', '#3aa9a5')
SKY = ('#7fb4dc', '#a0cdec')
SLATE = ('#636884', '#7c809c')
PINKS = ('#d87a9c', '#f0a4bc')
EYE_O = ('#e8a317', '#f5cf6a', '#c06a14')
RED = '#c8402e'
BLUSH = '#f0a0a0'
TONGUE = '#e2707a'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def rell(cx, cy, rx, ry, ang):
    a = math.radians(ang)
    u = (CX - cx) * math.cos(a) + (CY - cy) * math.sin(a)
    v = -(CX - cx) * math.sin(a) + (CY - cy) * math.cos(a)
    return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0


def petal(bx, by, L, W, ang):
    """Almond petal from its base (bx, by), length L, half width W, ang degrees from straight up (+ = right)."""
    a = math.radians(ang)
    ux, uy = math.sin(a), -math.cos(a)
    dx, dy = CX - bx, CY - by
    u = dx * ux + dy * uy
    v = -dx * uy + dy * ux
    t = u / L
    return (t > 0) & (t < 1) & (np.abs(v) <= W * np.sin(np.pi * np.clip(t, 0, 1)) ** 0.7 + 0.3)


def veins(st, mask, avoid, col=VEIN):
    v = blank()
    for k in range(-60, 70, 9):
        v |= line([(k, 0), (k + 64, 64)])
    v &= shrink(mask, 2) & ~avoid
    st.paint(v & (((XX // 3) % 3) != 2), col)
    return v


def note(st, x, y, col=UMBER):
    """A small hummed music note (eighth note): solid, gets the outline."""
    st.sprite(['..UUU', '..UUU', '..U.U', '..U..', '..U..', 'UUU..', 'UUU..', '.U...'], x, y, {'U': col})
    st.sprite(['UUU', 'UU.'], x, y + 5, {'U': VEIN}, solid=False)


def cattail(st, x, y0, y1):
    stalk = rect(x, y0 + 6, x + 1, y1)
    st.part(stalk, '#5f8a34', d=0, contour=True)
    st.paint(rect(x, y0 + 6, x, y1), '#8ab64c')
    head = ellipse(x + 1.0, y0 + 4, 2.4, 4.6)
    st.part(head, '#8a5a34', d=1, contour=True)
    st.paint(head & ellipse(x + 0.3, y0 + 2.8, 1.0, 2.0), '#b47e4c')
    tip = rect(x, y0 - 2, x, y0 - 1)
    st.paint(tip, '#5f8a34', solid=True)
    leaf = poly([(x + 1, y1 - 4), (x + 6, y1 - 12), (x + 5, y1 - 12), (x + 1, y1 - 7)])
    st.part(leaf, '#5f8a34', d=0, contour=True)
    return stalk | head


def legs(st, pts, col):
    """Tiny 2 px insect legs: (x, y, dx) with dx the foot direction."""
    for x, y, dx in pts:
        m = rect(x, y, x + 1, y + 2) | rect(x + (dx if dx < 0 else 1), y + 3, x + (dx if dx < 0 else 1) + abs(dx), y + 3)
        st.part(m, col, d=0, contour=True)


def sunglasses(st, x, y):
    lens = blank()
    for lx in (x, x + 10):
        m = rect(lx, y, lx + 7, y + 4)
        m[y + 4, lx] = m[y + 4, lx + 7] = False
        lens |= m
    st.paint(lens | rect(x, y - 1, x + 17, y - 1), GOLD_D)
    st.paint(shrink(lens, 1) | (lens & (YY > y)), '#21253a')
    st.paint(rect(x + 7, y, x + 10, y), GOLD)
    for lx in (x, x + 10):
        st.dots([(lx + 1, y + 1), (lx + 2, y + 1), (lx + 1, y + 2)], '#cfe8f0')


def glitter(st, mask, pts):
    for px_, py_ in pts:
        if mask[py_, px_]:
            st.paint(rect(px_ - 1, py_, px_ + 1, py_) | rect(px_, py_ - 1, px_, py_ + 1), '#9fe0d4')
            st.dots([(px_, py_)], '#fff3c8')


def wing_bit(st, cx, cy, ang, rx=5.5, ry=2.4):
    m = rell(cx, cy, rx, ry, ang)
    st.part(m, '#cdeee4', d=1, contour=True)
    a = math.radians(ang)
    st.paint(line([(cx - rx * 0.7 * math.cos(a), cy - rx * 0.7 * math.sin(a)), (cx + rx * 0.8 * math.cos(a), cy + rx * 0.8 * math.sin(a))]) & m, VEIN)
    return m


def headband(st, x0, x1, y, body):
    band = rect(x0, y, x1, y + 2) & body
    st.paint(band, RED)
    st.paint(band & (YY == y), '#e0604a')
    knot = rect(x1 + 1, y, x1 + 2, y + 1) | rect(x1 + 2, y + 2, x1 + 4, y + 3) | rect(x1 + 3, y - 2, x1 + 5, y - 1)
    st.part(knot, RED, d=0, contour=True)
    # a cream "1" on the band
    st.sprite(['.C', 'CC', '.C'], (x0 + x1) // 2 - 4, y, {'C': '#fff3c8'}, solid=False)


def big_eye(st, x, y, r=5.0, look=(0, 1)):
    """A compound dragon-fly eye: umber socket, orange disc, gold lit cap, umber pupil, cream glint."""
    st.paint(disc(x, y, r + 1), UMBER2)
    e = disc(x, y, r)
    st.paint(e, EYE_O[0])
    st.paint(e & ~shift(e, -1, -1), EYE_O[2])
    st.paint(e & disc(x - 1.2, y - 1.6, r * 0.55), EYE_O[1])
    st.paint(disc(x + look[0], y + look[1], 1.9), UMBER)
    st.dots([(int(x + look[0] - 1), int(y + look[1] - 1))], CREAM)


def glow_rays(st, x, y, r):
    for k in range(8):
        a = math.radians(k * 45 + 22)
        px_, py_ = int(round(x + r * math.cos(a) - 0.5)), int(round(y + r * math.sin(a) - 0.5))
        st.dots([(px_, py_)], GOLD_L)


def happy_closed(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def mini_dragonfly(st, x, y):
    """A tiny jade dragon-fly napping, facing left: head at (x, y), tail to the right, two pairs of glass wings up."""
    for wx, wy, a in ((x + 5, y - 2, -55), (x + 9, y - 2, -35)):
        wing_bit(st, wx, wy, a, rx=3.6, ry=1.6)
    tail = rect(x + 3, y, x + 15, y + 1)
    st.part(tail, '#3fae8a', d=0, contour=True)
    st.paint(tail & ((XX % 3) == 0), '#e8a317')
    head = disc(x + 1.5, y + 1, 2.6)
    st.part(head, '#3fae8a', d=1, contour=True)
    st.dots([(x, y), (x + 1, y)], UMBER)
    return tail | head


# ------------------------------------------------------------------ 1. Wing Jot: corner-TT tri, common. A flake of wing glass, veined, humming a note; cheeky wink.
def wing_jot():
    key = 'pl-jdf-1'
    st = Sticker()
    core = (12, 23, 41, 50)
    body = piece(core, s='F', w='F', n=('T', 'tri', 4, 3.8), e=('T', 'tri', 3, 3.8))
    st.part(body, tex=fill(key, body, 12, 23, 30, list(GLASS)), contour=True)
    face = rect(15, 28, 38, 45)
    veins(st, body, face)
    st.stitch(body, col='#6aaec0')
    note(st, 49, 10, col='#d2f0e4')
    st.dots([(47, 20), (45, 23)], '#fff3c8')
    st.extra[20, 47] = st.extra[23, 45] = True
    st.eye(17, 31, look=(1, 0))
    st.sprite(['U...U', '.UUU.'], 29, 33, {'U': UMBER}, solid=False)      # winking eye
    st.sprite(['UUUUU', '.UTU.', '..T..'], 23, 40, {'U': UMBER, 'T': TONGUE}, solid=False)
    st.paint(rect(15, 38, 16, 38) | rect(36, 38, 37, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Reedleg Cling: edge-TBT hook, common. Reed olive, clinging to a cattail with six tiny legs, gritted teeth.
def reedleg_cling():
    key = 'pl-jdf-2'
    st = Sticker()
    cattail(st, 48, 9, 55)
    core = (15, 24, 43, 46)
    body, holes = piece_blanks(core, s='F', n=('T', 'hook', -3, 3.4), e=('B', 'hook', 2, 2.8), w=('T', 'hook', 3, 3.0, True))
    st.part(body, tex=fill(key, body, 15, 24, 29, list(REED)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c8d880', skip=grow(holes, 3))
    for yy in (29, 39):      # two front legs hugging the reed
        arm = rect(44, yy, 49, yy + 1)
        st.part(arm, '#4f6a2a', d=0, contour=True)
        st.paint(rect(50, yy, 50, yy + 1), '#4f6a2a', solid=True)
    legs(st, [(17, 47, -1), (23, 47, -1), (32, 47, 1), (39, 47, 1)], '#4f6a2a')
    st.eye(19, 30, look=(1, 0), lid=1)
    st.eye(31, 30, look=(1, 0), lid=1)
    st.paint(line([(18, 27), (23, 29)]) | line([(31, 29), (36, 27)]), UMBER)
    st.sprite(['UUUUUUU', 'UCUCUCU', 'UUUUUUU'], 23, 38, {'U': UMBER, 'C': CREAM}, solid=False)
    st.sprite(['.S.', 'SSS', 'SSS', '.S.'], 38, 25, {'S': '#bfe6f4'}, solid=False)   # a sweat drop: it is holding on so hard
    st.dots([(38, 26)], '#ffffff')
    return key, st


# ------------------------------------------------------------------ 3. Jade Shimmer: inner-TBBB peg, common. Deep pond jade, gold sunglasses, glitter everywhere; smug cool.
def jade_shimmer():
    key = 'pl-jdf-3'
    st = Sticker()
    core = (13, 22, 44, 49)
    body, holes = piece_blanks(core, n=('T', 'peg', 5, 3.6), e=('B', 'peg', 3, 3.0), s=('B', 'peg', -3, 3.0), w=('B', 'peg', 3, 3.0))
    st.part(body, tex=fill(key, body, 13, 22, 32, list(POND), dy=0.1), contour=True)
    st.blank_shade(body, holes, width=1)
    glitter(st, body, [(17, 26), (39, 25), (36, 44), (19, 44), (28, 47), (41, 37)])
    sunglasses(st, 19, 30)
    st.mouth('smirk', 29, 39)
    st.paint(line([(19, 27), (23, 26)]), UMBER)                  # one cool raised brow
    sparks(st, [(50, 13)], big=False)
    st.sparkle(6, 16, big=False)
    return key, st


# ------------------------------------------------------------------ 4. Jadewing Quartet: inner-TTTT double, uncommon. Sky blue, four glassy wing bits, a racer headband; eager.
def jadewing_quartet():
    key = 'pl-jdf-4'
    st = Sticker()
    core = (19, 23, 44, 46)
    for cx, cy, a in ((18, 22, 35), (45, 22, -35), (18, 47, -35), (45, 47, 35)):
        wing_bit(st, cx + (-2 if cx < 30 else 2), cy + (-1 if cy < 30 else 1), a)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 19, 23, 26, list(SKY)), contour=True)
    st.stitch(body, col=EYE_O[0])                                  # uncommon accent: the dragon-fly's orange
    headband(st, 19, 44, 25, body)
    st.eye(22, 30, look=(0, -1))
    st.eye(34, 30, look=(0, -1))
    st.mouth('grin', 28, 38)
    return key, st


# ------------------------------------------------------------------ 5. Lantern Eye Pair: inner-TTBB tri, uncommon. Dusk slate, two huge glowing orange eyes, tiny horns; shy.
def lantern_eye_pair():
    key = 'pl-jdf-5'
    st = Sticker()
    core = (14, 25, 43, 50)
    horn(st, 20, 26, h=7, lean=-0.9, w=4, pal=BONE)
    horn(st, 39, 26, h=7, lean=0.9, w=4, pal=BONE)
    body, holes = piece_blanks(core, n=('T', 'tri', 0, 3.4), e=('T', 'tri', 3, 3.8), s=('B', 'tri', 2, 3.0), w=('B', 'tri', 2, 3.0))
    st.part(body, tex=fill(key, body, 14, 25, 30, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#3fae8a', skip=grow(holes, 3))          # uncommon accent: jade
    big_eye(st, 22.5, 34.5, 5.2, look=(-1, 1))
    big_eye(st, 36.5, 34.5, 5.2, look=(-1, 1))
    glow_rays(st, 22.5, 34.5, 8.3)
    glow_rays(st, 36.5, 34.5, 8.3)
    st.sprite(['.U.U.', 'U.U.U'], 27, 44, {'U': UMBER}, solid=False)
    st.paint(rect(16, 42, 17, 42) | rect(41, 42, 42, 42), BLUSH)
    # a gold dangle orb on a thread from the east tab (like the picture's dragon-fly)
    st.paint(line([(52, 42), (52, 47)]), GOLD_D, solid=True)
    orb = disc(52.5, 50, 2.4)
    st.part(orb, GOLDP[0], d=1, contour=True)
    st.dots([(51, 49)], GOLD_L)
    return key, st


# ------------------------------------------------------------------ 6. Lotus Perch: whimsy-lotus hook, rare. A pink lotus on a jade pad, a mini jade dragon-fly napping on its tip; blissful.
def lotus_perch():
    key = 'pl-jdf-6'
    st = Sticker()
    pad = ellipse(32, 42.5, 21, 5.0) & ~poly([(32, 43), (40, 49), (45, 49)])
    hook = knob('s', 'hook', 18, 47, r=2.4)
    st.part(pad | hook, '#4fae7a', d=1, contour=True)
    st.paint(pad & ellipse(30, 41, 16, 2.5) & ~ellipse(32, 43, 14, 2.6), '#8fd6a6')
    outer = petal(32, 41, 20, 6.5, -62) | petal(32, 41, 20, 6.5, 62)
    st.part(outer, PINKS[0], d=1, contour=True)
    mid = petal(32, 42, 25, 7.5, -30) | petal(32, 42, 25, 7.5, 30)
    st.part(mid, PINKS[0], d=1, contour=True)
    centre = petal(32, 44, 30, 11, 0)
    tex = fill(key, centre, 18, 14, 28, list(PINKS))
    st.part(centre, tex=tex, contour=True)
    st.stitch(centre, col='#fff3c8')
    for m in (outer, mid):
        st.paint(m & ~shift(m, 0, 2) & (CY < 40), '#f8c8d6')
    mini_dragonfly(st, 33, 14)
    happy_closed(st, 24, 28)
    happy_closed(st, 35, 28)
    st.paint(rect(23, 32, 24, 32) | rect(39, 32, 40, 32), BLUSH)
    st.mouth('smile', 30, 33)
    st.sparkle(8, 9)
    st.sparkle(53, 26, big=False)
    st.sparkle(9, 33, big=False)
    return key, st


PALS = [wing_jot, reedleg_cling, jade_shimmer, jadewing_quartet, lantern_eye_pair, lotus_perch]

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
        print('%-10s %-17s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
