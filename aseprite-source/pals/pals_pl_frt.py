"""Puzzle Pals: BARROW OF THE FROST TOAD (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-frt-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_frt.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-barrow-of-the-frost-toad.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Rime Crumb       barrow-grass green          | white rime crust + 3 icicles, a pale croak sac under the chin | cheeky side-glance, ^ smile
  2 Puddle Croak     frost-toad teal             | lily pad hat, sits in a rippled puddle, music notes            | sleepy humming, heavy lids, oval hum
  3 Thawdrop Pip     dawn apricot                | a big meltwater drop balanced on its head, felt boots          | startled: raised arcs, sweat bead, wobble
  4 Frostwart Bumps  night navy (+ toad gold)    | gold bobble beanie, 4 frosty warts on its tabs, claw feet      | grumpy brows, wide frown
  5 Barrow Peephole  barrow stone (+ door mint)  | a stone lintel slab with frost, brass peephole ring on one eye | shy peek, blush, tiny smile
  6 Barrow Icecrown  royal ice blue (rare)       | whimsy crown of ice: 5 icicle spikes, gold gems, hook tab      | smug toad eyes (gold, slit pupils), wide toad grin
Hook blanks kept small (r 2.6). No puffs. Stone lifted off mud.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-barrow-of-the-frost-toad'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-barrow-of-the-frost-toad-c2f07b')

GRASS = ('#5e9470', '#74aa82')
TEAL = ('#4a8c9c', '#5aa2b0')
APRICOT = ('#e89a6a', '#f4b486')
NAVY = ('#3e5478', '#50689a')
STONEG = ('#7a828c', '#949ca6')
ICEB = ('#3a68c8', '#5a8ae0')
RIME = ('#eef8fc', '#cfe0e8')
TOADGOLD = ('#f0c040', '#c98a14', '#fbe08a', '#8a5a10')
BRASS = ('#d8a048', '#a87030', '#f4cc80', '#6a4420')
LILY = ('#4f8a3e', '#356a2e', '#7cb860', '#24402c')
PUDDLE = ('#8cc4e4', '#5a94c0', '#d8f0fa', '#3a6a98')
DROP = ('#9cd8f0', '#5aa8d0', '#eefaff', '#3a7aa8')
LINTEL = ('#5a626c', '#40464e', '#7c848e', '#2e3238')
MINT = '#c8ecdc'
BLUSH = '#f0a0a0'
SAC = '#e6eedc'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def rime_crust(st, body, y, icicles):
    """Frost rime caked on the top of a body: a scalloped white band (the body above a wavy line), shade underside, icicles hanging off it."""
    wave = y + 1.4 * np.sin(XX * 0.9)
    m = body & (CY < wave)
    st.paint(m, RIME[0])
    st.paint(m & ~shift(m, 0, -1), RIME[1])
    for x, h in icicles:
        ic = rect(x, int(y) + 1, x + 1, int(y) + h - 1) | rect(x, int(y) + h, x, int(y) + h)
        st.paint(ic & body, RIME[1])
        st.paint(ic & body & (XX == x), RIME[0])
    return m


def croak_sac(st, cx, cy):
    m = ellipse(cx, cy, 4.2, 2.6)
    st.part(m, SAC, d=1, contour=True)
    st.paint(rect(int(cx) - 2, int(cy) - 2, int(cx) - 1, int(cy) - 2) & m, '#ffffff')
    return m


def lily_pad(st, cx, cy, rx=8, ry=3.2):
    m = ellipse(cx, cy, rx, ry) & ~poly([(cx, cy), (cx + rx + 1, cy - 2.5), (cx + rx + 1, cy + 0.5)])
    st.part(m, LILY[0], d=1, contour=True)
    st.paint(line([(cx - rx + 2, cy), (cx, cy)]) & shrink(m, 1), LILY[2])
    st.paint(disc(cx + 3, cy - 3.5, 1.6), '#f0a0c0', solid=True)       # a tiny pink bud on the pad
    return m


def puddle(st, cx, cy, rx, ry):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, PUDDLE[0], d=1, contour=True)
    st.paint((line([(cx - rx + 3, cy), (cx - rx + 7, cy)]) | line([(cx + rx - 8, cy + 1), (cx + rx - 4, cy + 1)])) & m, PUDDLE[2])
    return m


def note(st, x, y):
    st.sprite(['.NN', '.N.', '.N.', 'NN.', 'NN.'], x, y, {'N': CREAM}, solid=False)
    for j, r in enumerate(['.NN', '.N.', '.N.', 'NN.', 'NN.']):
        for i, ch in enumerate(r):
            if ch == 'N':
                st.extra[y + j, x + i] = True


def drop_mask(cx, cy, r, h):
    return disc(cx, cy, r) | poly([(cx - r * 0.9, cy - r * 0.35), (cx, cy - h), (cx + r * 0.9, cy - r * 0.35)])


def melt_drop(st, cx, cy, r=4.2, h=10):
    m = drop_mask(cx, cy, r, h)
    st.part(m, DROP[0], d=1, contour=True)
    st.paint(rect(int(cx - r) + 2, int(cy) - 2, int(cx - r) + 2, int(cy)) | rect(int(cx) - 1, int(cy - h) + 4, int(cx) - 1, int(cy - h) + 5), DROP[2])
    return m


def beanie(st, cx, y, w=10):
    """A knitted bobble beanie: a dome w px each side sitting on row y, a cream rib band, a bobble on top."""
    dome = ellipse(cx, y, w, 7) & (CY < y + 0.5)
    band = rect(int(cx - w), int(y) - 1, int(cx + w) - 1, int(y) + 1)
    bob = disc(cx, y - 7.5, 2.8)
    st.part(bob, CREAM, d=1, contour=True)
    m = dome | band
    st.part(m, TOADGOLD[0], d=1, contour=True)
    st.paint(dome & ~band & ((XX % 3) == 0) & shrink(dome, 1), TOADGOLD[1])
    st.paint(band, CREAM)
    st.paint(band & ((XX % 2) == 0), '#d2bf96')
    return m | bob


def wart(st, cx, cy):
    m = disc(cx, cy, 2.0)
    st.part(m, '#b8dcec', d=1, contour=False)
    st.paint(rect(int(cx) - 1, int(cy) - 1, int(cx) - 1, int(cy) - 1), '#ffffff')
    return m


def lintel(st, x0, x1, y0, y1):
    m = rect(x0, y0, x1, y1)
    for x, y in ((x0, y0), (x1, y0), (x0, y1), (x1, y1)):
        m[y, x] = False
    st.part(m, LINTEL[0], d=1, contour=True)
    st.paint(m & (YY == y0) | m & (YY == y0 + 1) & ((XX % 4) != 1), RIME[0])      # frost on its top
    st.paint(m & (XX == x0 + 9) & (YY > y0 + 1) | m & (XX == x1 - 7) & (YY > y0 + 2), LINTEL[1])   # stone cracks
    return m


def peephole(st, cx, cy, r=5.0):
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 1.6)
    st.paint(ring, BRASS[0])
    st.paint(ring & (CX + CY > cx + cy + 1.5), BRASS[1])
    st.paint(ring & (CX + CY < cx + cy - 4.5), BRASS[2])
    return ring


def toad_eye(st, x, y, lid=0, lidcol=None):
    """Frost-toad eye: a 7 x 6 round gold iris on an umber socket, a horizontal slit pupil, cream glint; lid = rows of body-tone lid
    (a smug half lid rests on the top)."""
    e = ellipse(x + 3.5, y + 3, 3.6, 3.1)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, TOADGOLD[0])
    st.paint(e & ~shift(e, -1, -1), TOADGOLD[1])
    st.paint(rect(x + 1, y + 3, x + 5, y + 3) | rect(x + 2, y + 2, x + 4, y + 4) & (YY != y + 2) | rect(x + 2, y + 3, x + 4, y + 3), UMBER)
    st.dots([(x + 2, y + 1)], CREAM)
    if lid:
        st.paint(e & (YY < y + lid), lidcol)
        st.paint(grow(e, 1) & (YY == y + lid - 1) | e & (YY == y + lid), UMBER)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Rime Crumb: corner-TT peg, common. Grass green crumb with a rime crust, croaking softly.
def rime_crumb():
    key = 'pl-frt-1'
    st = Sticker()
    core = (12, 22, 44, 49)
    body = piece(core, n=('T', 'peg', -5, 3.6), e=('T', 'peg', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(GRASS)), contour=True)
    rime_crust(st, body, 26, [(16, 4), (36, 3), (42, 5)])
    st.stitch(body & (YY > 27), col='#d6ecec')
    nub_feet(st, [16, 35], 49, '#3e6a50')
    st.eye(18, 31, look=(1, -1))
    st.eye(30, 31, look=(1, -1))
    st.paint(line([(30, 28), (33, 27), (35, 28)]), UMBER)                 # cheeky: one brow cocked
    st.sprite(['U....U', '.UUUU.'], 22, 39, {'U': UMBER}, solid=False)
    croak_sac(st, 25, 44)
    return key, st


# ------------------------------------------------------------------ 2. Puddle Croak: edge-TTB hook, common. Toad teal, lily pad hat, humming in its puddle.
def puddle_croak():
    key = 'pl-frt-2'
    st = Sticker()
    core = (14, 24, 46, 46)
    puddle(st, 30, 49, 22, 4.5)
    body, holes = piece_blanks(core, s='F', n=('T', 'hook', 6, 3.0), e=('T', 'hook', 2, 3.0), w=('B', 'hook', 3, 2.6))
    st.part(body, tex=fill(key, body, 14, 24, 33, list(TEAL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 45), col='#a8d8e0', skip=grow(holes, 3))
    st.paint(body & (YY >= 45) & (YY <= 46), PUDDLE[1])                  # its bottom sits in the water
    lily_pad(st, 22, 22)
    st.eye(20, 31, lid=3)
    st.eye(33, 31, lid=3)
    st.paint(rect(18, 37, 20, 37) | rect(37, 37, 39, 37), BLUSH)
    st.sprite(['.UU.', 'U..U', '.UU.'], 27, 39, {'U': UMBER}, solid=False)
    note(st, 52, 12)
    note(st, 56, 22)
    return key, st


# ------------------------------------------------------------------ 3. Thawdrop Pip: inner-TBTB tri, common. Dawn apricot, a meltwater drop balanced on its head, startled.
def thawdrop_pip():
    key = 'pl-frt-3'
    st = Sticker()
    core = (15, 23, 46, 47)
    body, holes = piece_blanks(core, n=('T', 'tri', 6, 3.4), e=('B', 'tri', 7, 2.8), s=('T', 'tri', -2, 3.4), w=('B', 'tri', 7, 2.8))
    st.part(body, tex=fill(key, body, 15, 23, 32, list(APRICOT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fbe8b8', skip=grow(holes, 3))
    melt_drop(st, 22, 19, r=4.2, h=11)
    for x in (16, 37):
        sh = rect(x, 49, x + 6, 52)
        sh[49, x] = sh[49, x + 6] = False
        st.part(sh, SHOE[0], d=1, contour=True)
    st.eye(20, 29, look=(0, -1))
    st.eye(33, 29, look=(0, -1))
    st.paint(line([(20, 25), (22, 24), (24, 25)]) | line([(33, 25), (35, 24), (37, 25)]), UMBER)   # brows shot up
    st.sprite(['.U.U.U.', 'U.U.U.U'], 25, 38, {'U': UMBER}, solid=False)
    st.paint(drop_mask(41.5, 27, 1.3, 3), DROP[0])                       # a sweat bead
    st.dots([(41, 27)], DROP[2])
    return key, st


# ------------------------------------------------------------------ 4. Frostwart Bumps: inner-TTTT double, uncommon. Night navy, gold bobble beanie, frosty warts, grumpy.
def frostwart_bumps():
    key = 'pl-frt-4'
    st = Sticker()
    core = (17, 24, 45, 47)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 3, 3.4), s=('T', 'double', -3, 3.4), w=('T', 'double', -2, 3.4))
    st.part(body, tex=fill(key, body, 17, 24, 29, list(NAVY)), contour=True)
    st.stitch(body, col=TOADGOLD[0])                                     # uncommon accent: the toad's eye gold
    claw_feet(st, [14, 42], 48, w=6, h=3, pal=('#2e3f58', '#1e2a40', '#4a5a78', '#141c2c'))
    beanie(st, 31, 23, w=11)
    for cx, cy in ((53, 37), (10, 33), (25, 53), (41, 43)):
        wart(st, cx, cy)
    st.eye(20, 31, lid=1)
    st.eye(33, 31, lid=1)
    st.paint(line([(19, 27), (24, 29)]) | line([(33, 29), (38, 27)]) | line([(19, 28), (24, 30)]) | line([(33, 30), (38, 28)]), UMBER)
    st.sprite(['.UUUU.', 'U....U'], 26, 39, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Barrow Peephole: inner-BBBB hook, uncommon. Barrow stone under a frosty lintel, brass peephole round one eye, shy.
def barrow_peephole():
    key = 'pl-frt-5'
    st = Sticker()
    core = (14, 23, 48, 52)
    body, holes = piece_blanks(core, n=('B', 'hook', -1, 2.6), e=('B', 'hook', 9, 2.6), s=('B', 'hook', 1, 2.6), w=('B', 'hook', 8, 2.6))
    st.part(body, tex=fill(key, body, 14, 23, 35, list(STONEG)))
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY > 24), col=MINT, skip=grow(holes, 3))            # uncommon accent: the barrow door's mint glow
    lintel(st, 10, 52, 17, 22)
    peephole(st, 39.5, 35.5, 5.4)
    st.eye(18, 33, look=(-1, 1))
    st.eye(37, 33, look=(-1, 1))
    st.paint(rect(16, 40, 18, 40) | rect(45, 40, 46, 40), BLUSH)
    st.sprite(['U.U', '.U.'], 28, 40, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Barrow Icecrown: whimsy-icecrown hook, rare. A crown of ice cut as a piece, gold gems, smug toad eyes.
def barrow_icecrown():
    key = 'pl-frt-6'
    st = Sticker()
    band = rect(10, 33, 45, 50)
    band[50, 10] = band[50, 45] = False
    spikes = blank()
    for cx, top, w in ((13, 22, 3.4), (20.5, 15, 3.8), (28, 9, 4.4), (35.5, 15, 3.8), (43, 22, 3.4)):
        spikes |= poly([(cx - w, 34), (cx - 0.7, top + 1), (cx + 0.7, top + 1), (cx + w, 34)]) | disc(cx, top + 1.5, 1.0)
    tab = knob('e', 'hook', 41, 46, r=3.0)
    body = band | spikes | tab
    t = cell_fill(pic, ROWS[key]['piece'], body, 10, 9, 36, 3, 3)
    st.part(body, tex=calm_tones(t, body, list(ICEB)), contour=True)
    for cx, top, w in ((13, 22, 3.4), (20.5, 15, 3.8), (28, 9, 4.4), (35.5, 15, 3.8), (43, 22, 3.4)):   # lit facet on each spike's left
        st.paint(line([(cx - 1, top + 3), (cx - w * 0.55, 32)]) & spikes & ~band, '#cde0fa')
    st.paint(band & (YY <= 35), '#cdd8ea')                               # frosted rim of the band
    st.paint(band & (YY == 36), '#9ab0d8')
    for gx in (13, 28, 43):
        st.sprite(['.G.', 'GLG', '.G.'], gx - 1, 33, {'G': TOADGOLD[0], 'L': TOADGOLD[2]}, solid=False)
    st.stitch(band & (YY > 36), col='#e8f2ff')
    toad_eye(st, 14, 38, lid=2, lidcol=ICEB[1])
    toad_eye(st, 33, 38, lid=2, lidcol=ICEB[1])
    st.sprite(['U...........U', '.UUUUUUUUUUU.'], 21, 46, {'U': UMBER}, solid=False)   # the wide toad grin
    st.paint(rect(11, 46, 13, 46) | rect(40, 46, 42, 46), BLUSH)
    st.sparkle(5, 8)
    st.sparkle(53, 7, big=False)
    st.sparkle(56, 20, big=False)
    return key, st


PALS = [rime_crumb, puddle_croak, thawdrop_pip, frostwart_bumps, barrow_peephole, barrow_icecrown]

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
