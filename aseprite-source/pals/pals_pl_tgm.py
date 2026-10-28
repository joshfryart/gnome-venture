"""Puzzle Pals: TEMPLE OF THE TIGER MOTH (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-tgm-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_tgm.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-temple-of-the-tiger-moth.png, calmed onto 2 tones of that pal's own colour family so the face reads.
UNIQUENESS (every pal an individual): own body tone, own accessory, own silhouette detail, own face, own pose.
  1 Tiger Dust        apricot wing powder + dust speckles | a polka-dot hanky poking out its flat side    | mid-sneeze: squeezed > < eyes, o
  2 Prayerflag Slip   prayer-flag teal                    | a string of 5 prayer flags tab to tab, sweat | nervous: wide eyes sideways, wobble
  3 Temple Chip       grey temple stone, mortar course     | gold shikhara finial cap, tally marks        | proud: chin up, lidded, smirk
  4 Tiger Wing Quad   night indigo, 4 orange striped tabs  | aviator goggles on the brow                  | cheeky: wink + tongue grin
  5 Moonhoop          moon lavender with craters           | a tiny cream moth fluttering through a blank | sleepy: heavy lids, small yawn
  6 Tiger Moth Locket red-orange moth (rare, whimsy-moth)  | gold hook loop locket, eyespots, antennae    | shy-happy: ^ ^ arcs, blush, cat
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-temple-of-the-tiger-moth'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-temple-of-the-tiger-moth-b3f761')

APRICOT = ('#e8944a', '#f5b860')
TEAL = ('#2f7896', '#4a9cbc')
STONE = ('#8e8070', '#b4a68e')
INDIGO = ('#4c4698', '#5e58aa')
LAVND = ('#9a8ed4', '#c3b8ec')
MOTHR = ('#c8401c', '#e0501f')
ORANGE, STRIPE = '#eb7c0c', '#3a2216'
FLAGS = ['#d6322b', '#4fae7a', '#f5cf6a', '#f2e4c0', '#3f8fb0']
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def squeeze_eye(st, x, y, right):
    """A sneeze-squeezed eye: a 4 x 5 chevron, > for the left eye, < for the right."""
    rows_ = ['U...', '.UU.', '...U', '.UU.', 'U...'] if not right else ['...U', '.UU.', 'U...', '.UU.', '...U']
    st.sprite(rows_, x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['.....', 'UUUUU', 'U...U'], x, y + 1, {'U': UMBER}, solid=False)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def hanky(st, x, y):
    """A cream handkerchief tucked in the flat west side, a corner flopping out, red polka dots and a hem."""
    m = poly([(x + 6, y), (x - 5, y + 2), (x - 6, y + 8), (x + 1, y + 11), (x + 6, y + 9)])
    st.part(m, '#f2e4c0', d=1, contour=True)
    st.paint(m & (((XX + 2 * YY) % 5) == 0) & ((YY % 2) == 0) & shrink(m, 1), '#d6322b')
    return m


def flag_string(st, pts, n=5):
    """A sagging cord between two points with n little prayer flags (3 x 4, fluttered corner) hanging off it."""
    (x0, y0), (x1, y1) = pts
    cord = blank()
    seg = []
    for i in range(13):
        t = i / 12
        seg.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t + 4.0 * t * (1 - t) * 1.2))
    cord = line(seg)
    st.paint(cord, '#6b4a2a', solid=True)
    for i in range(n):
        t = (i + 0.7) / (n + 0.4)
        fx, fy = int(round(x0 + (x1 - x0) * t)), int(round(y0 + (y1 - y0) * t + 4.8 * t * (1 - t))) + 1
        f = rect(fx - 1, fy, fx + 2, fy + 4)
        f[fy + 4, fx + 2] = False
        st.paint(f, FLAGS[i % len(FLAGS)], solid=True)
        st.paint(f & (XX == fx + 2), hexs(tone(hx(FLAGS[i % len(FLAGS)]), 'shade')), solid=True)
    return cord


def finial(st, x, y):
    """A gold shikhara finial: a stepped dome on a neck, a pointed bead tip, a tiny bell ring."""
    st.sprite(['...G...', '..GLG..', '...D...', '..GGG..', '.GLGGD.', 'GLGGGGD', '.DDDDD.'], x, y,
              {'G': GOLD, 'L': GOLD_L, 'D': GOLD_D}, solid=True)


def goggles(st, x, y):
    """Aviator goggles pushed up on the brow: a brown strap across the body, two round teal lenses in brass rims."""
    st.paint(rect(x - 6, y + 2, x + 28, y + 3), '#7a4a1f')
    st.paint(rect(x - 6, y + 3, x + 28, y + 3), '#5c3420')
    for cx in (x + 4, x + 18):
        st.paint(disc(cx + 0.5, y + 2.5, 4.2), '#c98a14')
        st.paint(disc(cx + 0.5, y + 2.5, 3.0), '#6ac0d8')
        st.paint(disc(cx - 0.5, y + 1.5, 1.0), '#eef8fc')
    st.paint(rect(x + 9, y + 2, x + 13, y + 3), '#c98a14')


def stripes(st, mask, step=4, w=1):
    """Tiger stripes: diagonal bands across a mask (umber), clipped 1 px inside."""
    m = mask & (((XX - YY) % step) < w) & shrink(mask, 1)
    st.paint(m, STRIPE)
    return m


def little_moth(st, x, y):
    """A 9 x 7 cream moth fluttering: two wing pairs, a dark body, gold antenna tips."""
    st.sprite(['.g.......g.', '..u.....u..', 'WWW.u.u.WWW', 'WWWWuuuWWWW', 'WOWWuuuWWOW', '.WWWuuuWWW.', '..WW.u.WW..', '...W...W...'], x, y,
              {'g': GOLD, 'u': UMBER2, 'W': '#fff3c8', 'O': '#f5b860'}, solid=True)


# ------------------------------------------------------------------ 1. Tiger Dust: corner-TB hook, common.
def tiger_dust():
    key = 'pl-tgm-1'
    st = Sticker()
    core = (14, 22, 45, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'hook', -4, 3.2), e=('B', 'hook', 5, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 32, APRICOT), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (((XX * 5 + YY * 3) % 11) == 0) & ((YY % 3) == 0) & shrink(body, 2) & ~rect(17, 28, 40, 44), '#fbe0a8')
    st.stitch(body, col='#b8601c', skip=grow(holes, 3))
    hanky(st, 13, 36)
    nub_feet = [(18, 50), (34, 50)]
    for fx, fy in nub_feet:
        st.part(ellipse(fx + 2.5, fy + 1.5, 3, 2), '#8a4a20', d=1, contour=True)
    squeeze_eye(st, 20, 30, False)
    squeeze_eye(st, 33, 30, True)
    st.paint(rect(19, 37, 21, 37) | rect(35, 37, 37, 37), BLUSH)
    st.mouth('o', 27, 37)
    # the dust it is about to sneeze: orange specks drifting off the upper right (border-only bits)
    for (px, py) in ((49, 15), (52, 19), (47, 11), (54, 13)):
        st.dots([(px, py)], ORANGE)
        st.extra[py, px] = True
    st.dots([(50, 12)], GOLD_L)
    st.extra[12, 50] = True
    return key, st


# ------------------------------------------------------------------ 2. Prayerflag Slip: edge-TTB double, common.
def prayerflag_slip():
    key = 'pl-tgm-2'
    st = Sticker()
    core = (13, 25, 43, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'double', -2, 3.6), e=('T', 'double', -3, 3.6), w=('B', 'double', 2, 3.0))
    st.part(body, tex=fill(key, body, 13, 25, 31, TEAL), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f5cf6a', skip=grow(holes, 3))
    flag_string(st, [(27, 11), (55, 21)], n=5)
    st.part(rect(16, 50, 21, 52), SHOE[0], d=1, contour=True)
    st.part(rect(34, 50, 39, 52), SHOE[0], d=1, contour=True)
    st.eye(17, 31, look=(1, -1))
    st.eye(29, 31, look=(1, -1))
    st.sprite(['.U.U.U', 'U.U.U.'], 23, 41, {'U': UMBER}, solid=False)         # wobbly nervous mouth
    st.sprite(['.S.', 'SSS', 'SWS', '.S.'], 39, 30, {'S': '#a9d6ea', 'W': '#eef8fc'}, solid=False)   # sweat drop
    return key, st


# ------------------------------------------------------------------ 3. Temple Chip: inner-TBBB peg, common.
def temple_chip():
    key = 'pl-tgm-3'
    st = Sticker()
    core = (14, 24, 45, 50)
    body, holes = piece_blanks(core, n=('T', 'peg', -3, 3.6), e=('B', 'peg', 3, 3.0), s=('B', 'peg', 0, 3.0), w=('B', 'peg', 3, 3.0))
    st.part(body, tex=fill(key, body, 14, 24, 32, STONE), contour=True)
    st.blank_shade(body, holes)
    st.paint(body & ((YY == 39)) & shrink(body, 2) & ~grow(holes, 2), '#6e6254')        # a mortar course
    st.paint(body & (YY > 39) & (YY < 47) & (XX == 30) & shrink(body, 2), '#6e6254')
    for i in range(4):                                                                   # tally marks: it loves being counted
        st.paint(rect(20 + i * 2, 42, 20 + i * 2, 46), UMBER2)
    st.paint(line([(18, 46), (27, 42)]), UMBER2)
    finial(st, 23, 9)
    claw_feet(st, [17, 36], 51, w=6, h=3, pal=ramp('#5c4a44'))
    st.eye(18, 29, look=(0, -1), lid=1)
    st.eye(32, 29, look=(0, -1), lid=1)
    st.mouth('smirk', 27, 36)
    return key, st


# ------------------------------------------------------------------ 4. Tiger Wing Quad: inner-TTTT tri, uncommon.
def tiger_wing_quad():
    key = 'pl-tgm-4'
    st = Sticker()
    core = (18, 23, 45, 48)
    body = piece(core, n=('T', 'tri', 0, 3.8), e=('T', 'tri', 0, 3.8), s=('T', 'tri', 0, 3.8), w=('T', 'tri', 0, 3.8))
    st.part(body, tex=fill(key, body, 18, 23, 28, INDIGO), contour=True)
    tabs = body & ~rect(*core)
    st.paint(tabs, ORANGE)
    st.paint(tabs & ~shift(tabs, 1, 1), '#f5b860')
    stripes(st, tabs, step=3)
    st.stitch(rect(*core), col='#eb7c0c')                      # uncommon accent: the wing orange
    goggles(st, 22, 25)
    st.eye(22, 32, look=(0, 0))
    wink(st, 35, 32)
    st.sprite(['UUUUUUU', 'U.....U', '.UURUU.', '...R...'], 27, 39, {'U': UMBER, 'R': '#e86a78'}, solid=False)   # grin, tongue out
    st.paint(rect(28, 40, 32, 40), CREAM)
    return key, st


# ------------------------------------------------------------------ 5. Moonhoop: inner-BBBB double, uncommon.
def moonhoop():
    key = 'pl-tgm-5'
    st = Sticker()
    core = (13, 21, 48, 50)
    body, holes = piece_blanks(core, n=('B', 'double', -7, 2.8), e=('B', 'double', 6, 2.8), s=('B', 'double', 0, 2.8), w=('B', 'double', 6, 2.8))
    st.part(body, tex=fill(key, body, 13, 21, 36, LAVND), contour=True)
    st.blank_shade(body, holes, width=1)
    for cx, cy, r in ((41, 26, 2.4), (18, 44, 2.0), (43, 44, 1.6)):                     # craters
        c = disc(cx, cy, r) & body
        st.paint(c, '#8a7ec4')
        st.paint(c & ~shift(c, -1, -1), '#ddd6f6')
    st.stitch(body, col='#f5cf6a', skip=grow(holes, 3))            # uncommon accent: moonlight gold
    little_moth(st, 38, 9)
    st.eye(19, 30, look=(0, 1), lid=2)
    st.eye(34, 30, look=(0, 1), lid=2)
    st.paint(rect(18, 37, 20, 37) | rect(37, 37, 39, 37), BLUSH)
    st.sprite(['.UU.', 'URRU', '.UU.'], 27, 38, {'U': UMBER, 'R': MOUTH_RED}, solid=False)   # a little yawn
    return key, st


# ------------------------------------------------------------------ 6. Tiger Moth Locket: whimsy-moth hook, rare.
def tiger_moth_locket():
    key = 'pl-tgm-6'
    st = Sticker()
    fw = [(29, 27), (19, 16), (12, 17), (10, 25), (14, 35), (28, 37)]
    hw = [(29, 37), (17, 38), (14, 45), (17, 51), (23, 51), (29, 45)]
    ul, ur = poly(fw), poly([(64 - x, y) for x, y in fw])
    ll, lr = poly(hw), poly([(64 - x, y) for x, y in hw])
    wings = ul | ur | ll | lr
    head = ellipse(32, 31, 9.5, 8.5)
    tail = ellipse(32, 44, 5, 8)
    loop = knob('n', 'hook', 32, 23.5, r=3.0)
    # antennae with gold bulbs
    for sx in (-1, 1):
        a = line([(32 + sx * 4, 24), (32 + sx * 7, 18), (32 + sx * 8, 14)])
        st.paint(a, UMBER2, solid=True)
        b = disc(32 + sx * 8 + 0.5, 12.5, 2.0)
        st.paint(b, GOLD, solid=True)
        st.paint(b & ~shift(b, 1, 1), GOLD_L)
    tex = fill(key, wings, 10, 14, 44, MOTHR)
    st.part(wings, tex=tex, contour=True)
    st.paint(wings & ~shrink(wings, 2) & (CY > 30), '#952a1a')                         # deep red wing hems
    for sx in (-1, 1):                                                                 # tiger stripes on the fore wings
        for t in (0, 1, 2):
            x0 = 32 + sx * (8 + t * 4)
            st.paint(line([(x0, 31), (x0 + sx * 3, 21)]) & shrink(ul | ur, 1), STRIPE)
    for cx in (21.5, 42.5):                                                            # eyespots on the hind wings
        st.paint(disc(cx, 45.5, 3.8), STRIPE)
        st.paint(disc(cx, 45.5, 2.8), ORANGE)
        st.paint(disc(cx, 45.5, 1.6), GOLD)
        st.paint(disc(cx - 0.6, 44.9, 0.6), GOLD_L)
    st.part(tail, '#f2d6a7', d=1, contour=True)
    st.paint(tail & ((YY % 3) == 0) & (YY > 39), '#d98a50')
    st.part(loop, GOLD, d=1, contour=True)
    st.part(head, '#f2d6a7', d=2, contour=True)
    happy_arc(st, 25, 30)
    happy_arc(st, 35, 30)
    st.paint(rect(24, 34, 26, 34) | rect(38, 34, 40, 34), BLUSH)
    st.mouth('cat', 30, 34)
    st.sparkle(50, 6)
    st.sparkle(10, 6, big=False)
    st.sparkle(54, 52, big=False)
    return key, st


PALS = [tiger_dust, prayerflag_slip, temple_chip, tiger_wing_quad, moonhoop, tiger_moth_locket]

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
