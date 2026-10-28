"""Puzzle Pals: ROSE-RED CANYON CITY (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-rrc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_rrc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-rose-red-canyon-city.png, calmed onto 2 tones of a pal-own colour family so the face reads.
Delve mood: cosy-curious canyon beasts and the carved city's small treasures, never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Bunting Flag      saffron gold                 | waves a red pennant on a pole, a sagging mini bunting string | cheeky wink, open grin + tongue
  2 Window Peek       rose-red canyon stone        | its eyes peer out of a carved arched window, lamp + sill      | shy: eyes slide sideways, blush, wobbly mouth
  3 Rosestone Pillar  pale rose-pink               | a carved capital with scroll volutes, fluting, hum notes     | sleepy humming: heavy lids, small round hum
  4 Saddle Stripes    woven indigo (+ sunset tabs) | each tab a different sunset stripe, a woven zigzag band      | startled: big pinpoint eyes, brows up, open D
  5 Lamplit Doorway   dusky canyon plum (+ gold)   | a dark carved doorway on its belly, holds a brass lamp out    | grumpy night porter: low brows, frown
  6 Rose Canyon Camel caramel (rare)               | whimsy resting camel: hump, curved neck, striped blanket      | content closed arcs, lashes, chewing mouth
Plus (4): all four double knobs centred. Ring: none in this roster. Blanks kept modest so they read as notches.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-rose-red-canyon-city'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-rose-red-canyon-city-5571a1')

SAFFRON = ('#e8b048', '#f2c860')
ROSERED = ('#c5685b', '#d27a66')
ROSEPINK = ('#e8a89a', '#f4c2b2')
INDIGO = ('#4c4c8c', '#5e5ea2')
PLUM = ('#8a4a5c', '#9e5c6a')
CARAMEL = ('#c88a52', '#d89e64')
CREAMSTONE = ('#eccc93', '#c8a070', '#fbe6b8', '#8a6a3a')
PENNANT = ('#d6402e', '#a82a22', '#f07a5a', '#6b1b2c')
POLE = ('#8a5a34', '#5c3a22', '#b07a4a', '#3a2216')
BRASS = ('#d8a048', '#a87030', '#f4cc80', '#6a4420')
RECESS = '#4a2836'
GLOW = '#f8d878'
BLUSH = '#f0a0a0'
SUNSET = ('#e0503a', '#f0b040', '#e87aa0', '#f08a3a')     # n e s w tabs of the Plus
FLAGS = ('#d6402e', '#e87aa0', '#5a8ad0', '#f0c040')


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def nub_feet(st, xs, y, col, rx=3.0):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, rx, 2), col, d=1, contour=True)


def mini_bunting(st, pts, clip, cols=FLAGS):
    """A sagging string across the body with tiny triangle flags hanging off it (the gorge bunting)."""
    s = line(pts) & clip
    st.paint(s, '#6a4a2a')
    for i, (x, y) in enumerate(pts[1:-1]):
        tri = poly([(x - 2, y + 1), (x + 2, y + 1), (x, y + 5)]) & clip
        st.paint(tri, cols[i % len(cols)])
        st.paint(tri & (XX == x - 1) & (YY == y + 1), '#fff3c8')


def pennant_pole(st, x, y0, y1):
    pole = rect(x, y0, x + 1, y1)
    st.part(pole, POLE[0], d=0, contour=True)
    st.part(disc(x + 1, y0 - 0.5, 1.6), GOLD, d=0, contour=True)          # gold finial
    flag = poly([(x + 2, y0 + 1), (x + 15, y0 + 3), (x + 13, y0 + 5), (x + 15, y0 + 8), (x + 2, y0 + 10)])  # swallow-tail, snapping right
    st.part(flag, PENNANT[0], d=1, contour=True)
    st.paint(flag & rect(x + 2, y0 + 1, x + 15, y0 + 3) & ~shift(flag, 0, 1), PENNANT[2])
    st.paint(flag & (XX >= x + 4) & (XX <= x + 5) & shrink(flag, 1), GOLD)
    return pole | flag


def arch_window(st, x0, y0, x1, y1, lamp=True):
    """A carved arched window recess (round top) with a cream stone frame and a sill; a tiny lamp glow at the arch top."""
    cx = (x0 + x1 + 1) / 2
    r = (x1 - x0 + 1) / 2
    hole = (rect(x0, int(y0 + r), x1, y1) | (ellipse(cx, y0 + r, r, r) & (CY < y0 + r + 0.5)))
    frame = grow(hole, 1) & ~hole
    st.paint(frame, CREAMSTONE[1])
    st.paint(frame & ~shift(frame, 1, 1), CREAMSTONE[2])
    st.paint(hole, RECESS)
    st.paint(hole & ~shift(hole, -1, -1), '#5e3444')
    sill = rect(x0 - 3, y1 + 1, x1 + 3, y1 + 2)
    st.part(sill, CREAMSTONE[0], d=1, contour=True)
    if lamp:
        st.paint(rect(int(cx) - 1, y0 + 2, int(cx), y0 + 3), GLOW)
        st.dots([(int(cx) - 1, y0 + 1)], BRASS[1])
    return hole


def capital(st, x0, x1, y):
    """Carved column capital: a slab with a curled scroll (volute) at each end, cream stone, a dark groove."""
    slab = rect(x0 + 2, y, x1 - 2, y + 3)
    vol = disc(x0 + 2.5, y + 2.5, 3.0) | disc(x1 - 1.5, y + 2.5, 3.0)
    m = slab | vol
    st.part(m, CREAMSTONE[0], d=1, contour=True)
    st.paint(rect(x0 + 5, y + 3, x1 - 5, y + 3), CREAMSTONE[1])
    for cx in (x0 + 2, x1 - 2):
        st.dots([(cx, y + 2), (cx + 1, y + 2), (cx + 1, y + 3)], CREAMSTONE[3])
    return m


def note(st, x, y, col=CREAM):
    st.sprite(['.CC', '.C.', 'CC.', 'CC.'], x, y, {'C': col}, solid=False)
    st.extra[y:y + 4, x:x + 3] |= np.array([[0, 1, 1], [0, 1, 0], [1, 1, 0], [1, 1, 0]], bool)


def big_eye(st, x, y, look=(0, 0)):
    """Startled eye: 6 x 7 cream oval, tiny 2 x 2 pinpoint pupil."""
    e = ellipse(x + 3, y + 3.5, 3.2, 3.7)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, CREAM)
    px, py = x + 2 + look[0], y + 3 + look[1]
    st.paint(rect(px, py, px + 1, py + 1), UMBER)


def zigzag(st, mask, y, cols=(CREAM, GOLD)):
    z = mask & (np.abs(((XX % 6) - 3)) + y == YY)
    z2 = mask & (np.abs(((XX % 6) - 3)) + y + 1 == YY)
    st.paint(rect(0, y - 1, 63, y + 4) & mask, INDIGO[0])
    st.paint(z, cols[0])
    st.paint(z2, cols[1])


def door(st, x0, y0, x1, y1):
    cx = (x0 + x1 + 1) / 2
    r = (x1 - x0 + 1) / 2
    hole = rect(x0, int(y0 + r), x1, y1) | (ellipse(cx, y0 + r, r, r) & (CY < y0 + r + 0.5))
    st.paint(grow(hole, 1) & ~hole, '#b87080')
    st.paint(hole, RECESS)
    st.paint(hole & (XX == int(cx)) & (YY > y0 + 2), '#5e3444')
    st.dots([(x1 - 1, int(y0 + r) + 3)], GOLD)                             # door knob
    st.paint(rect(x0 + 1, y1 - 1, x1 - 1, y1) & hole, '#f2b860')            # light spilling under it
    return hole


def lantern(st, x, y):
    """Brass hand lamp: ring handle on top, glowing glass, a base cap."""
    st.paint(line([(x + 1, y), (x + 1, y - 2), (x + 4, y - 2), (x + 4, y)]), BRASS[3], solid=True)
    cap = rect(x, y, x + 5, y + 1)
    glass = rect(x, y + 2, x + 5, y + 7)
    base = rect(x - 1, y + 8, x + 6, y + 9)
    st.part(glass, GLOW, d=1, contour=True)
    st.paint(rect(x + 2, y + 3, x + 3, y + 5), '#fff3c8')
    st.part(cap | base, BRASS[0], d=1, contour=True)
    st.paint(rect(x, y + 2, x, y + 7) | rect(x + 5, y + 2, x + 5, y + 7), BRASS[1])
    for gx, gy in ((x - 3, y + 2), (x + 8, y + 1), (x + 9, y + 6)):
        st.dots([(gx, gy)], GOLD_L)
        st.extra[gy, gx] = True


def sleepy_eye(st, x, y):
    """Dozing eye: a heavy lid line drooping over a thin cream sliver, two lashes."""
    st.sprite(['.UUUU.', 'UCCCCU', '.UUUU.'], x, y, {'U': UMBER, 'C': CREAM}, solid=False)
    st.dots([(x, y + 3), (x + 5, y + 3)], UMBER)


def closed_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


# ------------------------------------------------------------------ 1. Bunting Flag: corner-TB round, common. Saffron, waves a pennant, cheeky wink.
def bunting_flag():
    key = 'pl-rrc-1'
    st = Sticker()
    core = (16, 22, 45, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', -5, 3.6), e=('B', 'round', 2, 3.2))
    st.part(body, tex=fill(key, body, 16, 22, 30, SAFFRON), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#b87a20', skip=grow(holes, 3))
    mini_bunting(st, [(16, 39), (22, 42), (29, 44), (36, 43), (42, 40), (46, 38)], body)
    pennant_pole(st, 11, 9, 46)
    st.part(ellipse(14, 37, 2.6, 2.2), SAFFRON[0], d=1, contour=True)       # paw gripping the pole
    nub_feet(st, [19, 36], 50, '#7a4a2a')
    st.eye(20, 27, look=(1, 0))
    st.sprite(['.UUU.', 'U...U'], 33, 29, {'U': UMBER}, solid=False)        # the wink
    st.mouth('grin', 26, 34)
    st.paint(rect(28, 36, 29, 36), '#f08a8a')                               # tongue
    return key, st


# ------------------------------------------------------------------ 2. Window Peek: edge-TTB peg, common. Rose-red stone, eyes peering out of a carved window.
def window_peek():
    key = 'pl-rrc-2'
    st = Sticker()
    core = (15, 22, 46, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 4, 3.6), e=('T', 'peg', 2, 3.4), w=('B', 'peg', 4, 3.2))
    st.part(body, tex=fill(key, body, 15, 22, 32, ROSERED), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (45, 48):                                                       # canyon strata bands
        st.paint(body & shrink(body, 2) & (YY == y) & ((XX + y) % 7 != 0), '#b05a50')
    hole = arch_window(st, 20, 24, 39, 37, lamp=False)
    st.paint(line([(41, 24), (44, 24), (44, 26)]), BRASS[3], solid=True)       # a little lamp on a bracket by the window
    st.part(rect(43, 27, 45, 30), GLOW, d=0, contour=True)
    st.paint(rect(43, 31, 45, 31), BRASS[1])
    st.dots([(44, 28)], '#fff3c8')
    st.eye(24, 30, look=(1, 0), socket=None)
    st.eye(32, 30, look=(1, 0), socket=None)
    st.paint(rect(17, 41, 19, 41) | rect(40, 41, 42, 41), BLUSH)
    st.sprite(['.U.U.', 'U.U.U'], 27, 42, {'U': UMBER}, solid=False)          # wobbly shy mouth
    st.stitch(body & (CY > 40), col='#f2c0a0', skip=grow(holes, 3) | rect(0, 38, 63, 41))
    st.part(rect(18, 51, 23, 53), '#7a3a34', d=1, contour=True)
    st.part(rect(38, 51, 43, 53), '#7a3a34', d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 3. Rosestone Pillar: inner-TBTB tri, common. Pale rose column, carved capital, humming in its sleep.
def rosestone_pillar():
    key = 'pl-rrc-3'
    st = Sticker()
    core = (19, 22, 42, 46)
    body, holes = piece_blanks(core, n=('T', 'tri', 0, 3.4), e=('B', 'tri', 5, 2.4), s=('T', 'tri', 0, 3.2), w=('B', 'tri', 5, 2.4))
    st.part(body, tex=fill(key, body, 19, 22, 24, ROSEPINK), contour=True)
    st.blank_shade(body, holes, width=1)
    flutes = body & shrink(body, 2) & (YY > 38) & ((XX - 19) % 5 == 2) & ~grow(holes, 2)
    st.paint(flutes, '#d08a80')
    capital(st, 15, 46, 21)
    st.part(rect(18, 46, 43, 47), CREAMSTONE[0], d=1, contour=True)        # base moulding
    sleepy_eye(st, 22, 30)
    sleepy_eye(st, 34, 30)
    st.paint(rect(21, 36, 23, 36) | rect(38, 36, 40, 36), BLUSH)
    st.sprite(['.U.', 'U.U', '.U.'], 30, 36, {'U': UMBER}, solid=False)     # a soft round hum
    note(st, 48, 14, CREAM)
    note(st, 53, 22, GOLD_L)
    return key, st


# ------------------------------------------------------------------ 4. Saddle Stripes: inner-TTTT double, uncommon. Woven indigo, a different sunset on each tab, startled.
def saddle_stripes():
    key = 'pl-rrc-4'
    st = Sticker()
    core = (19, 21, 44, 44)
    body = piece(core, r=3.4, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=fill(key, body, 19, 21, 26, INDIGO), contour=True)
    tabs = {'n': body & (YY < 21), 's': body & (YY > 44), 'w': body & (XX < 19), 'e': body & (XX > 44)}
    for (sd, m), c in zip(tabs.items(), (SUNSET[0], SUNSET[2], SUNSET[3], SUNSET[1])):
        st.paint(m, c)
        st.paint(m & ~shift(m, -1, -1), hexs(tone(hx(c), 'shade')))
        st.paint(m & ~shift(m, 1, 1), hexs(tone(hx(c), 'rim')))
    zigzag(st, body & shrink(body, 2) & rect(19, 0, 44, 63), 38)
    st.stitch(rect(*core), col=GOLD, depth=1)
    big_eye(st, 21, 25, look=(0, -1))
    big_eye(st, 35, 25, look=(0, -1))
    st.paint(line([(21, 22), (26, 21)]) | line([(36, 21), (41, 22)]), UMBER)
    st.sprite(['UUUU', 'URRU', '.UU.'], 30, 34, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.dots([(46, 24), (46, 25)], '#bfe4f4')                                # sweat bead
    return key, st


# ------------------------------------------------------------------ 5. Lamplit Doorway: inner-TTBB round, uncommon. Dusky plum, a carved door on its belly, holds the lamp out, grumpy.
def lamplit_doorway():
    key = 'pl-rrc-5'
    st = Sticker()
    core = (15, 22, 43, 49)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('T', 'round', -3, 3.4), s=('B', 'round', 9, 3.0), w=('B', 'round', 6, 3.0))
    st.part(body, tex=fill(key, body, 15, 22, 29, PLUM), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLD, skip=grow(holes, 3) | rect(22, 36, 34, 50))      # uncommon accent: lamp gold
    door(st, 24, 37, 32, 49)
    arm = ellipse(49, 40, 3.2, 2.4)
    st.part(arm, PLUM[0], d=1, contour=True)
    lantern(st, 48, 40)
    st.eye(19, 27, look=(0, 0), lid=1)
    st.eye(31, 27, look=(0, 0), lid=1)
    st.paint(line([(18, 25), (23, 27)]) | line([(31, 27), (36, 25)]), UMBER)
    st.sprite(['.UUU.', 'U...U'], 26, 33, {'U': UMBER}, solid=False)        # frown
    nub_feet(st, [16, 28], 50, '#4a2a34', rx=2.6)
    return key, st


# ------------------------------------------------------------------ 6. Rose Canyon Camel: whimsy-camel round, rare. A resting chibi camel, one hump, striped blanket, chewing contentedly.
def rose_canyon_camel():
    key = 'pl-rrc-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    belly = ellipse(29, 43, 13.5, 8.5)
    hump = ellipse(28, 34, 8.5, 8)
    neck = poly([(34, 42), (40, 27), (46, 27), (44, 44)])
    head = ellipse(46, 24, 6.5, 5) | ellipse(50, 26, 3.8, 3.5)               # head + droopy snout
    ears = disc(42.5, 18.5, 1.6)
    tab = knob('w', 'round', 42, 16.5, r=2.8)                                # the tail end is the jigsaw tab
    body = belly | hump | neck | head | ears | tab
    legs = ellipse(21, 51, 4.5, 2.4) | ellipse(34, 51.5, 4.5, 2.4)          # legs folded under
    st.part(legs, '#a8703e', d=1, contour=True)
    st.part(body, tex=fill(key, body, 11, 16, 40, CARAMEL), contour=True)
    st.paint(ellipse(29, 47, 10, 3) & belly, '#e8b880')                     # pale underbelly
    # striped saddle blanket draped over the hump
    bl = hump & (CY > 29) & (CX > 18) & (CX < 38) | (rect(18, 34, 37, 43) & belly)
    bl &= ~shrink(~(hump | belly), 0)
    bl &= (CY > 31)
    for i, c in enumerate(('#d6402e', '#f0c040', '#4c4c8c', '#e87aa0', '#d6402e', '#f0c040')):
        st.paint(bl & (YY >= 32 + i * 2) & (YY < 34 + i * 2), c)
    st.paint(bl & ~shift(bl, 1, 0), '#a82a22')
    st.paint(bl & (YY == 43), '#fff3c8')
    st.paint(rect(18, 44, 37, 44) & ((XX % 2) == 0), '#f2e4c0', solid=True)  # tassel fringe
    st.stitch(belly & ~bl & (CY > 44), col='#fbe6b8')
    # face: content closed arc, lashes, chewing lips, nostril
    closed_arc(st, 44, 21)
    st.dots([(44, 23), (48, 23)], UMBER)
    st.dots([(53, 25)], UMBER)
    st.sprite(['U.U', '.U.'], 50, 28, {'U': UMBER}, solid=False)
    st.paint(rect(42, 26, 43, 26), BLUSH)
    st.sparkle(5, 6)
    st.sparkle(55, 8, big=False)
    st.sparkle(6, 30, big=False)
    return key, st


PALS = [bunting_flag, window_peek, rosestone_pillar, saddle_stripes, lamplit_doorway, rose_canyon_camel]

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
        print('%-10s %-17s %-9s %-14s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
