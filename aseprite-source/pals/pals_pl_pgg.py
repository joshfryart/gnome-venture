"""Puzzle Pals: PIRATE-GULL GROTTOES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-pgg-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_pgg.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from palib + kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-pirate-gull-grottoes.png, calmed onto 2 tones of a pal-own colour family so the face reads.
Mood: cosy-curious cave beasts of a sunny sea grotto and the gulls' small pinched treasures, never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Hat Brim           grotto sandstone              | tiny brown tricorn tipped askew with a red plume, a wave curl at its foot | cheeky wink, tongue
  2 Squawk Shanty      sea teal                      | a red concertina, a fish jumping up to listen, beamed notes                | squeezed >< eyes, big squawk
  3 Stalactite Tap     sky blue                      | a sandstone stalactite on a ledge, one drumstick tapping it, tap ticks     | blissful closed eyes, small smile
  4 Loot Heap          coin gold (+ chest red)       | a 3-coin stack on its top tab, a white gull feather tucked in              | smug half lids, side glance, smirk
  5 Pinched Pearls     pearl lilac (+ sea mint)      | a pearl necklace looped twice with a dangling loop and gold clasp           | shy bead eyes, blush, tiny mouth
  6 Quartermaster Gull white gull (rare)             | whimsy gull: indigo tricorn with gold trim + coin badge, eyepatch, a fish  | stern one-eyed count, brow, beak
Ring and Plus knobs mirror-symmetric (n, s centred; e, w at the same height). Tri blanks kept small (r 2.8).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-pirate-gull-grottoes'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-pirate-gull-grottoes-0265f9')

SANDST = ('#b8a88a', '#c2b89b')
TEALS = ('#3fb0c8', '#4ec0d0')
SKY = ('#a4d0e8', '#b9dcee')
COIN = ('#e8a317', '#f5cf6a')
LILAC = ('#8a76b0', '#9e8cc4')
GULLW = ('#cfd8e4', '#e6ecf2')
FELT = ('#74462a', '#5e2f1e', '#a8582f', '#3a1e14')
INDIGO = ('#3e2f66', '#291d4a', '#5a4a8a', '#1f0f26')
CHEST = ('#d6322b', '#83301f', '#f2795a', '#57181d')
WOOD = ('#a8582f', '#8a4c27', '#ce8033', '#5e2f1e')
FISH = ('#8fcbd8', '#3f8fb0', '#e2f0e0', '#2a78a4')
SEAW = ('#4ec0d0', '#2c8cb4', '#c8f0e8', '#2a78a4')
STONE = ('#c2b89b', '#9a8a6a', '#e2d4b0', '#6a5a4a')
COINP = ('#f6d678', '#cea550', '#fff1c8', '#c98a14')
PEARL = ('#f4f0e0', '#c8bcd4', '#ffffff')
BEAK = ('#e8a317', '#ce8033', '#f6d678', '#ab3d0b')
WINGG = ('#929ab0', '#6a7088', '#bcc4d4', '#48474f')
MINT = '#8fe8e0'
BLUSH = '#f0a0a0'
TONGUE = '#f07890'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def _rot(pts, cx, cy, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c) for x, y in pts]


def tricorn(st, cx, y, w=8, h=6, tilt=0.0, pal=INDIGO, trim=None, badge=None, plume=None):
    """A pirate tricorn: crown bump + brim with two upturned corners, base centre (cx, y), half width w; tilt in degrees.
    trim = a hex for the brim's lower edge, badge = a hex for a coin badge on the front, plume = a hex for a feather tuft."""
    pts = [(cx - w, y - h * 0.55), (cx - w * 0.55, y + 1), (cx + w * 0.55, y + 1), (cx + w, y - h * 0.55), (cx + w * 0.45, y - h * 0.3),
           (cx + w * 0.3, y - h), (cx - w * 0.3, y - h), (cx - w * 0.45, y - h * 0.3)]
    m = poly(_rot(pts, cx, y, tilt))
    if plume:
        px, py = _rot([(cx + w * 0.35, y - h + 0.5)], cx, y, tilt)[0]
        pl = ellipse(px + 2.5, py - 2, 3.2, 1.8) | disc(px + 1, py - 0.5, 1.6)
        st.part(pl, plume, d=1, contour=True)
        st.paint(pl & (CY < py - 2.2) & (CX < px + 4), '#f2795a')
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1) & shrink(m, 0) & (CY < y - h * 0.4), pal[2])
    if trim:
        brim = m & ~shift(m, 0, -2) & (CY > y - h * 0.6)
        st.paint(brim, trim)
    if badge:
        bx, by = _rot([(cx, y - h * 0.5)], cx, y, tilt)[0]
        b = disc(bx, by, 1.9)
        st.paint(b, badge)
        st.dots([(int(bx) - 1, int(by) - 1)], '#fff1c8')
    return m


def wave_curl(st, cx, by, w=9):
    """A little sea wave rolling in: a teal hump curling over to the left, cream foam on the lip, a foam dot."""
    hump = ellipse(cx, by, w, 6.5) & (CY < by + 0.5)
    curl = disc(cx - w * 0.35, by - 5.2, 2.8)
    m = (hump | curl) & ~disc(cx - w * 0.55, by - 2.2, 1.7)
    st.part(m, SEAW[0], d=1, contour=True)
    lip = m & ~shift(m, 0, 1)
    st.paint(lip | (curl & ~shift(curl, 0, 2)), SEAW[2])
    st.paint(m & (YY >= by - 1) & ((XX % 3) == 0), SEAW[1])
    return m


def concertina(st, x0, y0, x1, y1):
    """A squeezebox: two red end boards with gold buttons, cream bellows between with umber pleats in a zigzag."""
    ends = rect(x0, y0, x0 + 3, y1) | rect(x1 - 3, y0, x1, y1)
    bell = rect(x0 + 4, y0 + 1, x1 - 4, y1 - 1)
    st.part(bell, '#f2e4c0', d=1, contour=True)
    st.paint(bell & (((XX - x0) % 3) == 0), '#a8916a')
    st.paint(bell & (YY == y0 + 1), '#fff3c8')
    st.part(ends, CHEST[0], d=1, contour=True)
    st.dots([(x0 + 1, y0 + 2), (x0 + 1, y0 + 5), (x1 - 2, y0 + 2), (x1 - 2, y0 + 5)], GOLD)
    return ends | bell


def fishy(st, x, y, flip=False, up=False, pal=FISH):
    """A small round fish (about 9 x 5): body, forked tail, cream belly, umber dot eye. up = nose to the sky."""
    s = -1 if flip else 1
    if up:
        m = ellipse(x, y, 2.6, 4.2) | poly([(x - 3, y + 7), (x, y + 3), (x + 3, y + 7)])
        eye = (x - 1, int(y - 2))
    else:
        m = ellipse(x, y, 4.2, 2.6) | poly([(x - s * 7, y - 3), (x - s * 3, y), (x - s * 7, y + 3)])
        eye = (int(x + s * 1.5), int(y - 1))
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & (CY > y + 1) & shrink(m, 1), pal[2])
    st.dots([eye], UMBER)
    return m


def beam_note(st, x, y):
    rows = ['.NNNN', '.N..N', '.N..N', 'NN.NN', 'NN.NN']
    st.sprite(rows, x, y, {'N': CREAM}, solid=False)
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch == 'N':
                st.extra[y + j, x + i] = True


def stalactite(st, cx, y0, h=11, w=4.5):
    """A sandstone stalactite hanging from a little rock ledge (so it reads as cave ceiling), a drip at its tip."""
    ledge = rect(int(cx - w - 3), int(y0) - 3, int(cx + w + 5), int(y0)) & ~((XX % 5 == 0) & (YY == int(y0) - 3))
    ledge &= ~rect(int(cx - w - 3), int(y0) - 3, int(cx - w - 3), int(y0) - 3) & ~rect(int(cx + w + 5), int(y0) - 3, int(cx + w + 5), int(y0) - 3)
    ledge |= poly([(cx + w + 1, y0), (cx + w + 4, y0), (cx + w + 2.5, y0 + 4)])
    sp = poly([(cx - w, y0), (cx + w, y0), (cx + 0.8, y0 + h), (cx - 0.8, y0 + h)])
    m = ledge | sp
    st.part(m, STONE[0], d=1, contour=True)
    st.paint(line([(cx - w + 1.5, y0 + 1), (cx - 0.5, y0 + h - 2)]) & shrink(m, 1), STONE[2])
    st.paint(ledge & ~sp, '#7a5444')
    st.paint(ledge & (YY == int(y0) - 2), '#946a56')
    drop = disc(cx + 0.5, y0 + h + 3, 1.3) | rect(int(cx), int(y0 + h + 1), int(cx), int(y0 + h + 1))
    st.paint(drop, SKY[1], solid=True)
    return m


def drumstick(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=2)
    st.part(m, WOOD[0], d=0, contour=True)
    tip = disc(x1 + 0.5, y1 + 0.5, 1.8)
    st.part(tip, '#f2e4c0', d=1, contour=True)
    return m | tip


def coin_stack(st, cx, by, n=3, w=5.0):
    m = blank()
    for i in range(n):
        y = by - i * 2.2
        c = ellipse(cx + (1.5, -1.5, 1, -0.5)[i % 4], y, w, 1.9)
        st.part(c, COINP[0], d=0, contour=True)
        st.paint(c & (CY > y + 0.3), COINP[1])
        m |= c
    top = ellipse(cx + (1.5, -1.5, 1, -0.5)[(n - 1) % 4], by - (n - 1) * 2.2, w, 1.9)
    st.paint(top & shrink(top, 1), COINP[2])
    return m


def pearls(st, pts):
    """A strand of pearls through pts: a 2 x 2 bead every 3 px along the polyline, glint top left, lilac grey shade."""
    m = blank()
    acc = 0.0
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        L = math.hypot(bx - ax, by - ay)
        t = (3 - acc) % 3
        while t <= L:
            x, y = int(round(ax + (bx - ax) * t / L)), int(round(ay + (by - ay) * t / L))
            b = rect(x, y, x + 1, y + 1)
            st.paint(b, PEARL[0], solid=True)
            st.paint(rect(x + 1, y + 1, x + 1, y + 1), PEARL[1])
            st.paint(rect(x, y, x, y), PEARL[2])
            m |= b
            t += 3
        acc = (acc + L) % 3
    return m


def arc_pts(cx, cy, rx, ry, a0, a1, n=12):
    return [(cx + rx * math.cos(math.radians(a0 + (a1 - a0) * i / n)), cy + ry * math.sin(math.radians(a0 + (a1 - a0) * i / n)))
            for i in range(n + 1)]


def bead_eye(st, x, y):
    st.sprite(['.UU.', 'UCUU', 'UUUU', '.UU.'], x, y, {'U': UMBER, 'C': CREAM}, solid=False)


def gull_eye(st, x, y):
    st.sprite(['.WWW.', 'WUUUW', 'WUCUW', 'WUUUW', '.WWW.'], x, y, {'U': UMBER, 'C': CREAM, 'W': '#ffffff'}, solid=False)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Hat Brim: corner-TB round, common. Grotto sandstone, a tiny tricorn tipped askew.
def hat_brim():
    key = 'pl-pgg-1'
    st = Sticker()
    core = (12, 25, 44, 50)
    body, holes = piece_blanks(core, n=('T', 'round', -4, 3.8), e=('B', 'round', 3, 3.2))
    st.part(body, tex=fill(key, body, 12, 25, 33, list(SANDST)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e2d4b0', skip=grow(holes, 3))
    st.sprite(['.U.....UUU.....U.',
               'ULU...ULLHU...ULU',
               'UHHU.ULHHHHU.UHHU',
               'UHHHUHHHHHHDUHHDU',
               '.UHHHHHHGHHHHHDU.',
               '..URRRRRRRRRRRU..',
               '...UUUUUUUUUUU...'], 16, 12, {'U': UMBER, 'H': FELT[0], 'L': FELT[2], 'D': FELT[1], 'G': GOLD, 'R': CHEST[0]})
    st.sprite(['..PP', '.PPU', 'PPU.', 'U...'], 30, 8, {'P': '#f2795a', 'U': UMBER})          # a jaunty red plume
    wave_curl(st, 48, 55, w=8)
    nub_feet(st, [15, 28], 50, '#8a7a5a')
    st.sprite(['.....', 'UUUUU', '.U.U.'], 17, 33, {'U': UMBER}, solid=False)     # the wink
    st.eye(30, 31)
    st.paint(line([(30, 28), (32, 27), (34, 28)]), UMBER)                         # cheeky cocked brow
    st.sprite(['U.....U', '.UUUUU.', '..RRR..', '...R...'], 21, 40, {'U': UMBER, 'R': TONGUE}, solid=False)
    return key, st


# ------------------------------------------------------------------ 2. Squawk Shanty: edge-TTB tri, common. Sea teal, a squeezebox, a fish jumps up to listen.
def squawk_shanty():
    key = 'pl-pgg-2'
    st = Sticker()
    core = (14, 22, 45, 47)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 3, 3.6), e=('T', 'tri', -2, 3.4), w=('B', 'tri', -3, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 32, list(TEALS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 40), col='#c8f0e8', skip=grow(holes, 3))
    concertina(st, 9, 40, 37, 48)
    fishy(st, 48, 51, flip=True)
    st.sprite(['U...U', '.U.U.', '..U..'], 18, 27, {'U': UMBER}, solid=False)      # > shut tight
    st.sprite(['..U..', '.U.U.', 'U...U'], 32, 27, {'U': UMBER}, solid=False)      # < shut tight
    st.sprite(['.UUUU.', 'URRRRU', 'URRRRU', '.UUUU.'], 25, 32, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(16, 33, 18, 33) | rect(38, 33, 40, 33), BLUSH)
    beam_note(st, 6, 12)
    beam_note(st, 12, 4)
    return key, st


# ------------------------------------------------------------------ 3. Stalactite Tap: inner-TBTB peg, common. Sky blue, taps a stalactite with a drumstick, eyes shut in the groove.
def stalactite_tap():
    key = 'pl-pgg-3'
    st = Sticker()
    core = (20, 24, 50, 46)
    body, holes = piece_blanks(core, n=('T', 'peg', 2, 3.4), e=('B', 'peg', 1, 2.8), s=('T', 'peg', -2, 3.4), w=('B', 'peg', 1, 2.8))
    stalactite(st, 13, 10, h=11, w=4)
    st.part(body, tex=fill(key, body, 20, 24, 31, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e6ecf2', skip=grow(holes, 3))
    drumstick(st, 22, 30, 17, 17)
    st.part(ellipse(21.5, 29.5, 2.6, 2.2), SKY[0], d=1, contour=True)              # the stubby paw holding it
    st.sprite(['T..', '.T.'], 6, 15, {'T': CREAM}, solid=False)                    # tap ticks
    st.sprite(['T..', '.T.'], 6, 20, {'T': CREAM}, solid=False)
    st.extra[15, 6] = st.extra[16, 7] = st.extra[20, 6] = st.extra[21, 7] = True
    st.sprite(['U...U', '.UUU.'], 27, 31, {'U': UMBER}, solid=False)               # blissful closed eyes
    st.sprite(['U...U', '.UUU.'], 39, 31, {'U': UMBER}, solid=False)
    st.dots([(26, 30), (44, 30)], UMBER)
    st.paint(rect(26, 35, 28, 35) | rect(42, 35, 44, 35), BLUSH)
    st.mouth('smile', 33, 36)
    return key, st


# ------------------------------------------------------------------ 4. Loot Heap: inner-TTTT double, uncommon. Coin gold, a coin stack on top, a gull feather tucked in, smug.
def loot_heap():
    key = 'pl-pgg-4'
    st = Sticker()
    core = (17, 25, 45, 46)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 2, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 2, 3.4))
    feather(st, 41, 24, L=11, ang=-62, pal=('#e6ecf2', '#929ab0', '#ffffff', '#6a7088'))
    st.part(body, tex=fill(key, body, 17, 25, 29, list(COIN)), contour=True)
    for cx, cy in ((22, 41), (38, 40), (30, 44)):                               # coins pressed into the heap
        c = disc(cx, cy, 2.6) & shrink(body, 2)
        st.paint(c, COINP[0])
        st.paint(c & ~disc(cx - 0.5, cy - 0.5, 1.9), COINP[3])
        st.dots([(cx - 1, cy - 1)], COINP[2])
    st.stitch(body, col=CHEST[0])                                              # uncommon accent: the chest red
    coin_stack(st, 31, 18, n=4, w=6.0)
    st.eye(20, 30, look=(1, 0), lid=2)
    st.eye(33, 30, look=(1, 0), lid=2)
    st.paint(line([(33, 27), (35, 26), (37, 27)]), UMBER)
    st.mouth('smirk', 27, 38)
    return key, st


# ------------------------------------------------------------------ 5. Pinched Pearls: inner-BBBB tri, uncommon. Pearl lilac, a stolen necklace looped twice, shy.
def pinched_pearls():
    key = 'pl-pgg-5'
    st = Sticker()
    core = (13, 21, 48, 50)
    body, holes = piece_blanks(core, n=('B', 'tri', 0, 2.8), e=('B', 'tri', 1, 2.8), s=('B', 'tri', 0, 2.8), w=('B', 'tri', 1, 2.8))
    st.part(body, tex=fill(key, body, 13, 21, 36, list(LILAC)))
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=MINT, skip=grow(holes, 3))                             # uncommon accent: the grotto sea mint
    pearls(st, arc_pts(31, 33, 15, 7, 10, 170))                                # loop 1 across the chest
    pearls(st, arc_pts(30, 37, 13, 7, 15, 165))                                # loop 2, lower
    pearls(st, [(15, 39), (13, 44), (11, 49), (12, 53), (16, 54), (19, 51)])   # a loop slipped off, dangling
    st.sprite(['.G.', 'GLG', '.G.'], 29, 43, {'G': GOLD_D, 'L': GOLD}, solid=False)   # the clasp
    bead_eye(st, 21, 27)
    bead_eye(st, 37, 27)
    st.paint(rect(18, 31, 20, 31) | rect(42, 31, 44, 31), BLUSH)
    st.sprite(['.UU.', 'U..U'], 29, 33, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Quartermaster Gull: whimsy-gull peg, rare. A sitting pirate gull, indigo tricorn, eyepatch, counts a fish.
def quartermaster_gull():
    key = 'pl-pgg-6'
    st = Sticker()
    head = disc(30, 26, 10.5)
    bod = ellipse(30, 41, 14, 10.5)
    tail = poly([(18, 38), (8, 47), (12, 49), (21, 47)])
    tab = knob('e', 'peg', 42, 43.5, r=3.0)
    body = head | bod | tail | tab
    t = cell_fill(pic, ROWS[key]['piece'], body, 14, 14, 34, 3, 3)
    st.part(body, tex=calm_tones(t, body, list(GULLW)), contour=True)
    wing = ellipse(24, 41, 9, 6.5) & ~ellipse(24, 34, 9, 3) & body
    st.part(wing, WINGG[0], d=1, contour=True)
    st.paint(wing & (YY >= 45) & ((XX % 3) == 0), WINGG[3])
    st.paint(tail & ~bod & (CX < 13), WINGG[3])
    st.stitch(bod & ~wing & (CX > 30), col='#bcc4d4')
    for x in (25, 34):                                                         # orange felt feet
        st.part(rect(x, 51, x + 4, 53) & ~rect(x, 53, x, 53) & ~rect(x + 4, 53, x + 4, 53), BEAK[0], d=1, contour=True)
    beak = poly([(37, 26), (50, 29), (37, 33)]) | ellipse(39, 29.5, 3, 3)
    st.part(beak, BEAK[0], d=1, contour=True)
    st.paint(rect(45, 29, 46, 30) & beak, BEAK[3])
    st.paint(line([(40, 30), (48, 30)]) & beak, BEAK[1])
    tricorn(st, 30, 17, w=12, h=7, tilt=-4, pal=INDIGO, trim=GOLD, badge=GOLD)
    st.paint(line([(20, 19), (38, 30)]), UMBER)                                # eyepatch strap
    st.part(ellipse(25, 24, 3.2, 2.8), UMBER2, d=0)
    gull_eye(st, 32, 22)
    st.paint(line([(31, 20), (36, 21)]), UMBER)                                # stern counting brow
    fishy(st, 41, 50, pal=FISH)
    st.sparkle(6, 10)
    st.sparkle(53, 8, big=False)
    st.sparkle(51, 21, big=False)
    return key, st


PALS = [hat_brim, squawk_shanty, stalactite_tap, loot_heap, pinched_pearls, quartermaster_gull]

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
        print('%-10s %-19s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
