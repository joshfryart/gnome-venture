"""Puzzle Pals: HOLLOW OF THE SILVERBACK SPIDER (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-sbs-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_sbs.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-hollow-of-the-silverback-spider.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Silkthread Tuft    silk ivory                 | a curly silk topknot + a sticky strand with a dew drop     | worried brows, eyes down, wobble mouth, blush
  2 Web Snag           canopy green               | a snagged red gnome hat dangling on a thread               | cheeky wink, tongue-out grin
  3 Buttress Tangle    lifted trunk brown         | an orange forest mushroom cap, splayed root feet           | grumpy heavy lids, squiggle grumble
  4 Eightlegs Clasp    red forest earth           | eight jointed stubby legs wiggling, 2 tiny extra eyes      | startled pinprick eyes, big O
  5 Dewweb Eye         dew blue                   | a ring of silk + dew beads worn as a monocle, a silk sash  | smug side-glance, lopsided smirk
  6 Silverback Spool   charcoal-plum + silver back (rare) | whimsy spider: 8 legs, silver abdomen, a wooden spool of silk, notes | asleep humming
Hook blanks kept small (r 2.6). No puffs. Browns lifted for dark pages.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-hollow-of-the-silverback-spider'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-hollow-of-the-silverback-spider-65e1ea')

IVORY = ('#e2dcc4', '#f0ead6')          # spun silk
CANOPY = ('#3f8a54', '#56a064')         # the canopy greens
TRUNK = ('#8a6646', '#a07a54')          # buttress trunk, lifted
EARTH = ('#a8442c', '#bf5a3a')          # red forest floor
DEW = ('#5f94b4', '#74a8c4')            # morning dew blue
PLUM = ('#6a5462', '#7e6676', '#9a8494', '#4a3a46')   # the spider, lifted off the dark page
SILV = ('#b8beb8', '#d8ddd6')
SILK = '#f4f6f0'
HATR = ('#c8402e', '#9a2a22', '#e8684a', '#6b1b2c')
SHROOM = ('#e0702e', '#b04a22', '#f29a54', '#7a2e18')
WOOD = ('#c08a50', '#8a5a34', '#e0b07a', '#5c3420')
BLUSH = '#f0a0a0'
TONGUE = '#f08a9a'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def mouth_px(st, rows_, x, y):
    st.sprite(rows_, x, y, {'U': UMBER, 'R': MOUTH_RED, 'P': TONGUE, 'C': CREAM}, solid=False)


def arc_eye(st, x, y, up=True):
    """Closed eye: a 5 px arc. up = happy ^ (wink), else a sleeping u."""
    st.sprite(['..U..', '.U.U.', 'U...U'] if up else ['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def wide_eye(st, x, y):
    """Startled eye: 6 x 6 cream disc in a socket, a 2 px pupil, glint."""
    so = rect(x - 1, y - 1, x + 6, y + 6)
    for cx, cy in ((x - 1, y - 1), (x + 6, y - 1), (x - 1, y + 6), (x + 6, y + 6)):
        so[cy, cx] = False
    st.paint(so, UMBER2)
    e = rect(x, y, x + 5, y + 5)
    for cx, cy in ((x, y), (x + 5, y), (x, y + 5), (x + 5, y + 5)):
        e[cy, cx] = False
    st.paint(e, CREAM)
    st.paint(rect(x + 2, y + 2, x + 3, y + 3), UMBER)
    st.dots([(x + 1, y + 1)], '#ffffff')


def silk_curl(st, cx, by):
    """A silk topknot: three curly wisps of thread fanning up from (cx, by), each tip rolled into a small curl."""
    m = blank()
    for dx, h, s in ((-4, 6, -1), (0, 9, 1), (4, 6, 1)):
        tipx, tipy = cx + dx + s * 1.5, by - h
        m |= line([(cx + dx * 0.4, by + 1), (cx + dx * 0.8, by - h * 0.5), (tipx, tipy)], w=2)
        m |= line([(tipx, tipy), (tipx + s * 2, tipy - 1), (tipx + s * 3, tipy + 1), (tipx + s * 2, tipy + 2)])
    st.part(m, IVORY[1], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1), SILK)
    return m


def sticky_strand(st, x0, y0, x1, y1):
    m = line([(x0, y0), ((x0 + x1) / 2 + 1, (y0 + y1) / 2 + 2), (x1, y1)])
    st.paint(m, SILK, solid=True)
    drop = disc(x1 + 0.5, y1 + 2.5, 1.9)
    st.part(drop, '#a9d6ea', d=1, contour=True)
    st.dots([(x1, y1 + 2)], '#ffffff')
    return m | drop


def dangling_hat(st, ax, ay, hx_, hy):
    """A little red gnome hat hung by its tip on a web thread from (ax, ay); hat tip at (hx_, hy), hanging upside down."""
    st.paint(line([(ax, ay), (hx_, hy)]), SILK, solid=True)
    st.part(disc(hx_ + 0.5, hy - 0.5, 1.8), CREAM, d=0, contour=True)
    cone = poly([(hx_ - 0.5, hy), (hx_ + 1.5, hy), (hx_ + 5, hy + 9), (hx_ - 4, hy + 9)])
    st.part(cone, HATR[0], d=1, contour=True)
    st.paint(cone & (CX < hx_ - 0.5) & (CY > hy + 3), HATR[2])
    brim = rect(int(hx_) - 5, hy + 9, int(hx_) + 5, hy + 11)
    st.part(brim, CREAM, d=0, contour=True)
    st.paint(brim & (YY == hy + 11), '#d2bf96')
    return cone | brim


def mushroom(st, cx, by, w=9, lean=0):
    stem = rect(cx - 1, by - 3, cx + 1, by)
    st.part(stem, CREAM, d=1, contour=True)
    cap = ellipse(cx + 0.5 + lean, by - 3, w / 2, 4.2) & (CY < by - 2)
    st.part(cap, SHROOM[0], d=1, contour=True)
    st.paint(cap & ~shift(cap, 1, 1) & (CY < by - 4), SHROOM[2])
    st.dots([(cx - 2 + lean, by - 5), (cx + 2 + lean, by - 4), (cx + lean, by - 6)], CREAM)
    return cap | stem


def root_feet(st, pts, col=TRUNK):
    m = blank()
    for p in pts:
        m |= line(p, w=2)
    st.part(m, '#6e4c32', d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1), col[1])
    return m


def stub_leg(st, root, knee, tip, col):
    """A jointed spider leg, 2 px thick, a cream sock tip."""
    m = line([root, knee, tip], w=2)
    st.part(m, col, d=1, contour=True)
    st.paint(m & disc(knee[0] + 0.5, knee[1] + 0.5, 1.1), tone(hx(col), 'rim'))
    st.paint(m & disc(tip[0] + 0.5, tip[1] + 0.5, 1.2), CREAM)
    return m


def dew_monocle(st, cx, cy, r=5.2):
    ring = (np.hypot(CX - cx, CY - cy) <= r) & (np.hypot(CX - cx, CY - cy) > r - 1.2)
    st.paint(ring, SILK, solid=True)
    for k in range(6):
        a = math.radians(k * 60 + 20)
        x, y = int(round(cx - 0.5 + r * math.cos(a))), int(round(cy - 0.5 + r * math.sin(a)))
        st.paint(rect(x, y, x + 1, y + 1), '#a9d6ea', solid=True)
        st.dots([(x, y)], '#ffffff')
    st.paint(line([(cx + r * 0.7, cy + r * 0.7), (cx + r + 3, cy + r + 6)]), SILK, solid=True)   # its chain: one silk thread
    return ring


def spool(st, x, y):
    """A wooden cotton spool standing at (x, y) top-left: 7 wide, 8 tall, silver silk wound round the middle."""
    top = rect(x, y, x + 6, y + 1)
    bot = rect(x, y + 7, x + 6, y + 8)
    mid = rect(x + 1, y + 2, x + 5, y + 6)
    st.part(mid, SILV[1], d=1, contour=True)
    st.paint(mid & ((YY % 2) == 0), '#9ea6a0')
    st.part(top | bot, WOOD[0], d=1, contour=True)
    st.paint((top | bot) & (XX == x + 1), WOOD[2])
    return top | bot | mid


def note(st, x, y, col=CREAM):
    st.sprite(['.NN', '.N.', '.N.', 'NN.', 'NN.'], x, y, {'N': col}, solid=False)
    st.extra[y:y + 5, x:x + 3] |= np.array([[0, 1, 1], [0, 1, 0], [0, 1, 0], [1, 1, 0], [1, 1, 0]], bool)


# ------------------------------------------------------------------ 1. Silkthread Tuft: corner-TT peg, common. Silk ivory, a curly topknot, a sticky strand, worried.
def silkthread_tuft():
    key = 'pl-sbs-1'
    st = Sticker()
    core = (12, 24, 42, 50)
    silk_curl(st, 19, 23)
    body = piece(core, n=('T', 'peg', 5, 3.4), e=('T', 'peg', 3, 3.4), s='F', w='F')
    st.part(body, tex=fill(key, body, 12, 24, 31, list(IVORY)), contour=True)
    st.stitch(body, col='#c8b48a')
    sticky_strand(st, 13, 44, 8, 50)
    st.eye(17, 32, look=(0, 1))
    st.eye(30, 32, look=(0, 1))
    st.paint(line([(16, 30), (20, 28)]) | line([(31, 28), (35, 30)]), UMBER)     # worried: inner ends up
    st.paint(rect(15, 39, 17, 39) | rect(34, 39, 36, 39), BLUSH)
    mouth_px(st, ['.U.U.', 'U.U.U'], 24, 41)
    return key, st


# ------------------------------------------------------------------ 2. Web Snag: edge-BTB hook, common. Canopy green, a snagged red gnome hat hanging on its thread, cheeky.
def web_snag():
    key = 'pl-sbs-2'
    st = Sticker()
    core = (15, 22, 45, 49)
    body, holes = piece_blanks(core, s='F', w=('B', 'hook', 2, 2.6), n=('T', 'hook', -3, 3.0), e=('B', 'hook', -2, 2.6))
    st.part(body, tex=fill(key, body, 15, 22, 31, list(CANOPY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8cc878', skip=grow(holes, 3))
    dangling_hat(st, 44, 30, 51, 38)
    for x in (19, 36):
        st.part(ellipse(x + 2.5, 51, 3.2, 2), '#2a5a3a', d=1, contour=True)
    arc_eye(st, 20, 31, up=True)
    st.eye(32, 30, look=(-1, 0))
    mouth_px(st, ['UUUUUU', '.URRPU', '..UPPU', '...UU.'], 24, 39)
    return key, st


# ------------------------------------------------------------------ 3. Buttress Tangle: inner-TBTB tri, common. Lifted trunk brown, a mushroom cap, root feet, grumpy.
def buttress_tangle():
    key = 'pl-sbs-3'
    st = Sticker()
    core = (15, 21, 44, 46)
    root_feet(st, [[(19, 47), (15, 52), (11, 53)], [(26, 47), (25, 53)], [(37, 47), (40, 52), (45, 54)]])
    body, holes = piece_blanks(core, n=('T', 'tri', 6, 3.4), e=('B', 'tri', 1, 3.0), s=('T', 'tri', -2, 3.0), w=('B', 'tri', 2, 3.0))
    st.part(body, tex=fill(key, body, 15, 21, 30, list(TRUNK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8b880', skip=grow(holes, 3))
    st.paint(line([(18, 40), (21, 43), (26, 42)]) & shrink(body, 2), SILK)     # a knot of silk caught on it
    mushroom(st, 23, 21, w=11, lean=-1)
    st.eye(19, 30, look=(0, 0), lid=2)
    st.eye(32, 30, look=(0, 0), lid=2)
    st.paint(line([(18, 28), (23, 30)]) | line([(32, 30), (37, 28)]), UMBER)
    mouth_px(st, ['.U.U.U.', 'U.U.U.U'], 25, 38)
    return key, st


# ------------------------------------------------------------------ 4. Eightlegs Clasp: inner-TTTT double, uncommon. Red earth, eight jointed legs, startled.
def eightlegs_clasp():
    key = 'pl-sbs-4'
    st = Sticker()
    core = (19, 23, 44, 46)
    for s in (-1, 1):
        cxs = 31.5 + s * 11
        for k, (dy, kx, ky, tx, ty) in enumerate(((-7, 7, -6, 9, 0), (-2, 9, -3, 12, 2), (3, 9, 0, 11, 6), (8, 6, 4, 8, 9))):
            if (s, k) in ((-1, 1), (1, 2)):
                continue                                     # the side tabs sit there
            root = (cxs, 34 + dy)
            knee = (cxs + s * kx, 34 + dy + ky)
            tip = (cxs + s * tx, 34 + dy + ty)
            stub_leg(st, root, knee, tip, PLUM[1] if k % 2 else PLUM[2])
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', -3, 3.0), s=('T', 'double', 2, 3.0), w=('T', 'double', 3, 3.0))
    st.part(body, tex=fill(key, body, 19, 23, 26, list(EARTH)), contour=True)
    st.stitch(body, col='#f5cf6a')                           # uncommon accent: the trunk's gold seam
    wide_eye(st, 21, 29)
    wide_eye(st, 33, 29)
    st.paint(rect(28, 26, 29, 27), UMBER)                    # two tiny extra spider eyes
    st.paint(rect(31, 26, 32, 27), UMBER)
    st.dots([(28, 26), (31, 26)], CREAM)
    mouth_px(st, ['.UU.', 'URRU', 'URRU', '.UU.'], 29, 38)
    return key, st


# ------------------------------------------------------------------ 5. Dewweb Eye: inner-BBBB hook, uncommon. Dew blue, a silk-and-dew monocle, a sash, smug.
def dewweb_eye():
    key = 'pl-sbs-5'
    st = Sticker()
    core = (12, 20, 46, 50)
    body, holes = piece_blanks(core, n=('B', 'hook', 5, 2.6), e=('B', 'hook', 7, 2.6), s=('B', 'hook', -5, 2.6), w=('B', 'hook', 6, 2.6))
    st.part(body, tex=fill(key, body, 12, 20, 35, list(DEW)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e8a317', skip=grow(holes, 3))      # uncommon accent: gold
    st.eye(18, 32, look=(1, 0), lid=1)
    st.eye(33, 30, look=(1, 0), lid=1)
    dew_monocle(st, 35.5, 32.5, 5.6)
    st.paint(line([(17, 30), (22, 31)]), UMBER)
    mouth_px(st, ['......U', 'U....U.', '.UUUU..'], 23, 42)
    return key, st


# ------------------------------------------------------------------ 6. Silverback Spool: whimsy-spider peg, rare. A round spider: silver back, eight legs, holding a spool, asleep humming.
def silverback_spool():
    key = 'pl-sbs-6'
    st = Sticker()
    legc = '#a890a0'
    for s in (-1, 1):
        for k, (ry, kx, ky, tx, ty) in enumerate(((30, 10, -8, 15, -2), (34, 12, -5, 17, 3), (38, 12, -1, 16, 8), (42, 9, 2, 12, 11))):
            root = (32 + s * 7, ry)
            stub_leg(st, root, (32 + s * kx, ry + ky), (32 + s * tx, ry + ty), legc if k % 2 == 0 else PLUM[2])
    back = ellipse(32, 25, 10.5, 8.5)
    tab = knob('n', 'peg', 32, 17.3, r=2.8)
    abdomen = back | tab
    src = pic.sample(*ROWS[key]['piece'], 21, 16, 22).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(SILV[0])
    tex[src > 450] = hx(SILV[1])
    tex = majority(tex, abdomen, 3)
    st.part(abdomen, tex=tex, contour=True)
    st.paint((line([(25, 22), (32, 26), (39, 22)], w=2) | line([(27, 28), (32, 30), (37, 28)])) & shrink(abdomen, 1), '#727563')   # silverback chevrons
    st.paint(abdomen & disc(27, 20.5, 1.6), '#ffffff')
    head = ellipse(32, 39, 11, 8.5)
    st.part(head, PLUM[0], contour=True)
    st.paint(head & ~shift(head, 0, -1) & (CY > 41), PLUM[3])
    st.sprite(['C...C', '.CCC.'], 25, 37, {'C': CREAM}, solid=False)
    st.sprite(['C...C', '.CCC.'], 34, 37, {'C': CREAM}, solid=False)
    st.stitch(head, col='#c0a8b8')
    st.paint(rect(23, 40, 24, 40) | rect(39, 40, 40, 40), BLUSH)
    st.paint(rect(31, 42, 32, 43), UMBER)
    st.paint(rect(31, 43, 32, 43), MOUTH_RED)
    fang(st, 27, 45, h=3)
    fang(st, 35, 45, h=3)
    st.paint(line([(47, 45), (41, 42)]), SILK, solid=True)
    spool(st, 44, 45)
    note(st, 10, 16)
    note(st, 48, 10, GOLD_L)
    st.sparkle(51, 22, big=False)
    st.sparkle(8, 40, big=False)
    return key, st


PALS = [silkthread_tuft, web_snag, buttress_tangle, eightlegs_clasp, dewweb_eye, silverback_spool]

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
