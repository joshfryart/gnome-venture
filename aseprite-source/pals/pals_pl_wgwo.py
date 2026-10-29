"""Puzzle Pals: GLOWWORM GROTTO (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wgwo-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wgwo.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: little cave sprites made of the grotto's own lights and stones, keyhole knobs, hushed and twinkly, never scary. kit_lair parts
used only as building blocks (PlacePic, rows, cell_fill, calm_tones, tidy, sparks); everything else drawn here. Silhouette = the row's shape +
knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/wonder-glowworm-grotto.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Dangling Dripstone     stalactite violet          | a purple stalactite hanging off its chin, cyan sparkle drop at the tip | holding-still: wide eyes, puffed cheeks, flat mouth
  2 Wanderlight Wisps      glow cyan                  | a wandering trail of loose glow dots looping off to the upper right       | dreamy, looks up-right, little o
  3 Hopscotch Stones       slate stone grey           | two flat dark pool stones underfoot + a splash ripple, mid-hop             | cheeky wink, tooth grin
  4 Ceiling Constellation  cave-roof indigo (+ cyan)  | a 4-dot star map joined by gold threads across its brow, one per tab     | content closed ^ ^ eyes, smile
  5 Pool of Quiet          still-pool teal (+ pale)   | concentric hush ripples on its belly, a reflected glow dot               | sleepy heavy lids, tiny shh mouth
  6 Swinging Glowtail      glowworm lime-green        | whimsy plump glowworm on a silk thread, glowing tail bulb, music notes (rare) | round happy eyes, singing open mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-glowworm-grotto'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-glowworm-grotto-c58e7b')

VIOLET = ('#6a4f8e', '#8a6ab0')        # stalactite violet
CYANB = ('#3aa4b4', '#6ad0d4')         # glow cyan
SLATE = ('#8a8e9a', '#aaaeb8')         # pool-stone slate
INDIGO = ('#33336a', '#45458a')        # cave-roof indigo
POOL = ('#2f6a80', '#3f849a')          # still-pool teal
LIMEW = ('#8ab84a', '#a8d060')         # glowworm lime (rare)
GLOW = ('#9af0f0', '#e8ffff', '#4ac8d4')
STONE = ('#3e4150', '#2a2c38', '#5e6274', '#1e2028')
DRIP = ('#5a3f7a', '#3e2a5a', '#9a7ac4', '#2a1a40')
BLUSH = '#f0a0b8'
SILK = '#e8f4f4'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def glow_dot(st, cx, cy, big=False):
    """A loose glow dot: pale cyan core, white heart, cyan halo (border only)."""
    if big:
        st.sprite(['.c.', 'cWc', '.c.'], cx - 1, cy - 1, {'c': GLOW[0], 'W': GLOW[1]}, solid=False)
        st.extra |= rect(cx - 1, cy - 1, cx + 1, cy + 1) & ~(rect(cx - 1, cy - 1, cx - 1, cy - 1) | rect(cx + 1, cy - 1, cx + 1, cy - 1)
                                                           | rect(cx - 1, cy + 1, cx - 1, cy + 1) | rect(cx + 1, cy + 1, cx + 1, cy + 1))
    else:
        st.dots([(cx, cy)], GLOW[1])
        st.extra[cy, cx] = True


def stalactite(st, cx, y, w=7, h=13):
    m = poly([(cx - w, y), (cx + w, y), (cx + 1, y + h), (cx - 1, y + h)])
    st.part(m, DRIP[0], d=1, contour=True)
    st.paint(m & (CX < cx - 1) & shrink(m, 1), DRIP[2])
    st.paint(m & (CY > y + 3) & ((CY.astype(int) - y) % 4 == 0) & shrink(m, 1), DRIP[1])   # drip rings
    return m


def ripple_ring(st, cx, cy, rx, ry, col):
    m = ellipse(cx, cy, rx, ry) & ~ellipse(cx, cy, rx - 1.1, ry - 1.1)
    st.paint(m, col)
    return m


def pool_stone(st, cx, cy, rx, ry):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, STONE[0], d=1, contour=True)
    st.paint(m & (CY < cy - ry * 0.3) & shrink(m, 1), STONE[2])
    return m


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def note(st, x, y, col=GOLD):
    st.sprite(['.GG', '.G.', '.G.', 'GG.', 'GG.'], x, y, {'G': col}, solid=False)
    for j, r in enumerate(['.GG', '.G.', '.G.', 'GG.', 'GG.']):
        for i, ch in enumerate(r):
            if ch == 'G':
                st.extra[y + j, x + i] = True


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Dangling Dripstone: corner-TT keyhole, common.
def dangling_dripstone():
    key = 'pl-wgwo-1'
    st = Sticker()
    core = (12, 15, 42, 40)
    body = piece(core, n=('T', 'keyhole', 4, 3.6), e=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 12, 15, 31, list(VIOLET)), contour=True)
    st.stitch(body, col='#c4a8e8')
    stalactite(st, 27, 41, w=7, h=11)                       # the stalactite it is, hanging from its chin
    glow_dot(st, 27, 54, big=True)                          # the sparkle at its tip, about to drop
    st.eye(17, 23)
    st.eye(30, 23)
    st.paint(rect(14, 31, 17, 32) | rect(35, 31, 38, 32), BLUSH)   # puffed cheeks: holding its breath, keeping still
    st.mouth('flat', 26, 34)
    return key, st


# ------------------------------------------------------------------ 2. Wanderlight Wisps: edge-TTB keyhole, common.
def wanderlight_wisps():
    key = 'pl-wgwo-2'
    st = Sticker()
    core = (14, 24, 42, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -3, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 24, 29, list(CYANB)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GLOW[1], skip=grow(holes, 3))
    for (x, y, b) in ((44, 15, True), (48, 11, False), (52, 9, True), (56, 12, False), (55, 17, True), (51, 19, False), (8, 18, False), (11, 13, True)):
        glow_dot(st, x, y, b)                               # the loose dots wandering off and back
    nub_feet(st, [17, 35], 49, '#2a7a8a')
    st.eye(22, 32, look=(1, -1))
    st.eye(33, 32, look=(1, -1))
    st.mouth('o', 28, 41)
    return key, st


# ------------------------------------------------------------------ 3. Hopscotch Stones: inner-TBTB keyhole, common.
def hopscotch_stones():
    key = 'pl-wgwo-3'
    st = Sticker()
    core = (16, 15, 45, 39)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 16, 15, 30, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c8ccd6', skip=grow(holes, 3))
    ripple_ring(st, 14, 55, 7, 2.4, GLOW[2])
    pool_stone(st, 14, 54, 5, 2.2)                          # the stone it just left
    pool_stone(st, 47, 55, 6, 2.4)                          # the stone it is hopping to
    st.extra |= ellipse(14, 55, 7, 2.4)
    st.eye(21, 22, lid=4)                                   # a cheeky wink
    st.eye(35, 22, look=(1, 0))
    st.mouth('tooth', 28, 31)
    st.paint(rect(19, 30, 21, 30) | rect(40, 30, 42, 30), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Ceiling Constellation: inner-TTTT double, uncommon.
def ceiling_constellation():
    key = 'pl-wgwo-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(INDIGO)), contour=True)
    st.stitch(body, col=GLOW[2])                            # uncommon accent: glow cyan
    pts = [(32, 21), (40, 26), (32, 31), (24, 26)]          # the star map, symmetric diamond
    for a, b in zip(pts, pts[1:] + pts[:1]):
        st.paint(line([a, b]), GOLD_D)
    for x, y in pts:
        st.sprite(['.c.', 'cWc', '.c.'], x - 1, y - 1, {'c': GLOW[0], 'W': GLOW[1]}, solid=False)
    for x, y in ((32, 9), (32, 55), (9, 32), (55, 32)):     # one glow dot on each tab
        st.sprite(['.c.', 'cWc', '.c.'], x - 1, y - 1, {'c': GLOW[0], 'W': GLOW[1]}, solid=False)
    closed_up(st, 22, 35)
    closed_up(st, 37, 35)
    st.mouth('smile', 30, 40)
    st.paint(rect(20, 39, 22, 39) | rect(41, 39, 43, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Pool of Quiet: inner-BBBB keyhole, uncommon.
def pool_of_quiet():
    key = 'pl-wgwo-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(POOL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#bfe8f0', skip=grow(holes, 3))     # uncommon accent: pale pool shimmer
    ripple_ring(st, 32, 41, 12, 4.5, '#5aa4b8')
    ripple_ring(st, 32, 41, 7, 2.6, '#8ad0dc')
    st.sprite(['.c.', 'cWc', '.c.'], 31, 40, {'c': GLOW[0], 'W': GLOW[1]}, solid=False)   # a reflected glow dot
    st.eye(21, 23, lid=3)
    st.eye(38, 23, lid=3)
    st.sprite(['.U.', 'U.U', '.U.'], 31, 31, {'U': UMBER}, solid=False)    # a tiny shh
    st.paint(rect(18, 31, 20, 31) | rect(43, 31, 45, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Swinging Glowtail: whimsy-glowworm keyhole, rare.
def swinging_glowtail():
    key = 'pl-wgwo-6'
    st = Sticker()
    head = ellipse(26, 21, 10, 8.5)
    segs = ellipse(30, 31, 9.5, 6) | ellipse(35, 38, 8.5, 5.5) | ellipse(39, 44, 7, 4.5)
    tab = knob('w', 'keyhole', 23, 16.5, r=3.0)
    body = head | segs | tab
    st.part(body, tex=fill(key, body, 10, 12, 40, list(LIMEW)), contour=True)
    seam = '#5a8a2a'
    st.paint(segs & dil4(head) & ~head, seam)
    st.paint(ellipse(35, 38, 8.5, 5.5) & dil4(ellipse(30, 31, 9.5, 6)) & ~ellipse(30, 31, 9.5, 6), seam)
    st.paint(ellipse(39, 44, 7, 4.5) & dil4(ellipse(35, 38, 8.5, 5.5)) & ~ellipse(35, 38, 8.5, 5.5), seam)
    bulb = disc(45, 49, 4.0)                                # the glowing tail light
    st.part(bulb, GLOW[0], d=1, contour=True)
    st.paint(disc(44, 48, 1.9), GLOW[1])
    st.stitch(segs, col='#d4ec90', skip=grow(head | bulb, 1))
    silk = line([(26, 5), (26, 12)])                        # its silk thread to the ceiling
    st.paint(silk, SILK)
    st.extra |= silk
    st.eye(19, 16, look=(0, 0))
    st.eye(28, 16, look=(0, 0))
    st.sprite(['UUUU', 'URRU', '.UU.'], 23, 24, {'U': UMBER, 'R': MOUTH_RED}, solid=False)   # humming wide
    st.paint(rect(16, 24, 17, 24) | rect(33, 24, 34, 24), BLUSH)
    note(st, 44, 20)
    note(st, 51, 27)
    st.sparkle(7, 7)
    st.sparkle(52, 8, big=False)
    st.sparkle(10, 42, big=False)
    return key, st


PALS = [dangling_dripstone, wanderlight_wisps, hopscotch_stones, ceiling_constellation, pool_of_quiet, swinging_glowtail]

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
