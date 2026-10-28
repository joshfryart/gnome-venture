"""Puzzle Pals: FIREFLY CAVES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-ffy-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_ffy.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cute cave beasts and the dark's small treasures, cosy-curious, never scary. Built on palib + kit_lair (parts as building
blocks only; every accessory here is drawn in this file). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-firefly-caves.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Glowtail Dot        halo moss green            | its east tab IS a glowing lime tail with blink rays, curly antennae, nub feet | cheeky wink + tongue
  2 Canoe Glimmer       lamp amber                 | glass-lamp frame bars + a wire handle loop, sits in a red outrigger canoe    | adoring: big shiny eyes up, blush, tiny o
  3 Lake Twinkle        deep lake teal             | half under water: wavy waterline, ripples, a drowned glow speck, bubbles    | sleepy: heavy lids, bubble mouth
  4 Spare Wings         glow lime (+ lavender)     | four pale wings in two stacked pairs at its shoulders, flutter marks       | giddy: ^ ^ arcs, open grin
  5 Night Archway       stalactite purple (+ moon) | a moonlit arch window on its belly (peaks, moon), chalk tally, felt boots   | concentrating: squint + look up, tongue poke
  6 Firefly Lamplighter cocoa head + glow belly    | whimsy firefly: wings, antennae, a lamplighter pole with a lit wick, gold star badge | proud: star-glint eyes, wide grin
Ring blanks mirror-symmetric (n, s centred, e and w at the same height). No pinwheels. Browns lifted off mud.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-firefly-caves'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-firefly-caves-dfbe7c')

MOSS = ('#4f8e42', '#64a452')
AMBER = ('#d9a05a', '#f0bc6c')
LAKE = ('#1f6a80', '#2c84a0')
LIME = ('#c2d474', '#d6e494')
ROCK = ('#6e5890', '#84699e')
COCOA = ('#8a5a3a', '#a26c46')
GLOW = ('#c8d77a', '#a4b86a', '#f2f8c0', '#6a9a3a')        # firefly glow (base, shade, light, deep)
WINGP = ('#cfd6e8', '#a8c4e0', '#f4f8ff', '#6a86c0')
CANOE = ('#8a2a2c', '#57181d', '#b0484a', '#311619')
WOOD = ('#8a5a30', '#5e3a20', '#b07a48', '#3a2216')
SKY = ('#a8c4e0', '#cfd6e8', '#6a86c0')
PEAK = '#2f5a6a'
BLUSH = '#f0a0a0'
CHALK = '#e2f0e0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def arc_eye(st, x, y, up=True):
    """Closed eye: a 5 px arc. up=True = happy ^ (giddy, wink); False = sleepy u."""
    st.sprite(['.UUU.', 'U...U'] if up else ['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def antenna(st, x, y, pts, tip=GLOW, col='#6a4430'):
    """A thin curly antenna from (x, y) through pts, with a 2 x 2 glow bead on the end."""
    m = line([(x, y)] + pts, w=1)
    st.part(m, col, d=0, contour=False)
    ex, ey = pts[-1]
    b = disc(ex + 0.5, ey + 0.5, 1.9)
    st.part(b, tip[0], d=0, contour=False)
    st.paint(rect(ex - 1, ey - 1, ex, ey) & b, tip[2])
    return m | b


def glow_rays(st, pts):
    """Short blink rays (border only, like sparkles): each (x, y, dx, dy) = a 2 px dash."""
    for x, y, dx, dy in pts:
        for k in range(2):
            st.px[y + dy * k, x + dx * k] = hx(GLOW[2] if k == 0 else GLOW[0])
            st.extra[y + dy * k, x + dx * k] = True


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def canoe(st, x0, x1, y):
    """An outrigger canoe hull seen side on: a shallow crescent, dark red, cream-gold rim stripe, a tiny outrigger float behind."""
    float_ = ellipse(x1 - 3, y - 2, 4, 1.6)
    st.part(float_, WOOD[0], d=1, contour=True)
    hull = poly([(x0, y - 1), (x1, y - 1), (x1 - 4, y + 6), (x0 + 5, y + 6)]) | ellipse(x0 + 4, y + 2, 4, 3.5) | ellipse(x1 - 4, y + 2, 4, 3.5)
    hull &= (CY > y - 1.5)
    st.part(hull, CANOE[0], d=1, contour=True)
    st.paint(hull & (YY == y), '#d9a660')
    st.paint(hull & (YY == y + 1), CANOE[1])
    st.paint(hull & (YY == y + 3) & (XX % 6 == 0), CANOE[2])
    return hull


def ripples(st, cx, y, ws):
    """Flat ripple dashes on the water (border only)."""
    for i, w in enumerate(ws):
        yy = y + i * 2
        for x in range(int(cx - w), int(cx + w) + 1):
            if (x + i) % 4 != 3:
                st.px[yy, x] = hx('#5ad8c8' if i == 0 else '#30cbb2')
                st.extra[yy, x] = True


def bubble(st, x, y, r=1):
    """A tiny bubble ring (border only): r=1 -> 3 x 3 ring, r=2 -> 4 x 4."""
    rows_ = ['.B.', 'B.B', '.B.'] if r == 1 else ['.BB.', 'BWbB', 'BbbB', '.BB.']
    for j, row in enumerate(rows_):
        for i, ch in enumerate(row):
            if ch != '.':
                st.px[y + j, x + i] = hx({'B': '#cfe8f0', 'W': '#ffffff', 'b': '#2c84a0'}[ch])
                st.extra[y + j, x + i] = True


def wing(st, cx, cy, rx, ry, ang, pal=WINGP):
    """A pale oval firefly wing rotated ang degrees, with one vein."""
    a = np.radians(ang)
    u = (CX - cx) * np.cos(a) + (CY - cy) * np.sin(a)
    v = -(CX - cx) * np.sin(a) + (CY - cy) * np.cos(a)
    m = (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & (np.abs(v) < 0.5) & (np.abs(u) < rx - 1.5), pal[1])
    st.paint(m & ((u / rx) ** 2 + ((v + ry * 0.35) / (ry * 0.5)) ** 2 <= 0.35), pal[2])
    return m


def arch_window(st, x0, x1, y0, y1):
    """The cave's far mouth on its belly: an arch (round top) of moonlit sky, pale core, dark teal peaks at the foot, a moon slit."""
    w = x1 - x0 + 1
    r = w / 2
    m = rect(x0, int(y0 + r), x1, y1) | (disc(x0 + r, y0 + r, r) & (CY < y0 + r + 0.5))
    st.paint(m, SKY[2])
    inner = shrink(m, 2)
    st.paint(inner, SKY[0])
    st.paint(shrink(m, 4) & (CY < y1 - 3), SKY[1])
    peaks = poly([(x0, y1 + 1), (x0 + w * 0.28, y1 - 5), (x0 + w * 0.45, y1 - 2), (x0 + w * 0.68, y1 - 8), (x1 + 1, y1 - 1), (x1 + 1, y1 + 1)]) & m
    st.paint(peaks, PEAK)
    st.paint(peaks & ~shift(peaks, 0, 1) & ~shift(peaks, 1, 0), '#4a8a9a')
    st.paint(rect(int(x0 + w * 0.42), int(y0 + 4), int(x0 + w * 0.42) + 1, int(y0 + 7)), '#fff1c8')
    st.paint(m & ~shift(m, 1, 0) | m & ~shift(m, 0, 1) & (CY < y0 + r), UMBER2)
    return m


def tally(st, x, y, n=5):
    """Chalk tally marks: 4 strokes and a slash (counting fireflies)."""
    for i in range(min(n, 4)):
        st.paint(rect(x + i * 2, y, x + i * 2, y + 4), CHALK)
    if n >= 5:
        st.paint(line([(x - 1, y + 3), (x + 7, y + 1)]), CHALK)


def boots(st, xs, y):
    for x in xs:
        st.part(rect(x, y, x + 6, y + 3) & ~rect(x, y, x, y) & ~rect(x + 6, y, x + 6, y), SHOE[0], d=1, contour=True)


def star_badge(st, x, y):
    st.sprite(['..G..', '.GGG.', 'GGLGG', '.GGG.', '.G.G.'], x, y, {'G': GOLD, 'L': GOLD_L}, solid=False)
    st.dots([(x + 3, y + 3), (x + 1, y + 4)], GOLD_D)


def wick_pole(st, x0, y0, x1, y1):
    """A lamplighter's pole: a long thin wooden stick, brass hook at the top holding a small lit wick flame."""
    stick = line([(x0, y0), (x1, y1)], w=2)
    st.part(stick, WOOD[0], d=1, contour=True)
    hook = line([(x1, y1), (x1 - 2, y1 - 2), (x1 - 4, y1 - 1), (x1 - 4, y1 + 1)], w=1)
    st.part(hook, '#d8a048', d=0, contour=False)
    flame(st, x1 - 4, y1 + 6, w=4, h=6, lean=0.0, pal=('#f5b860', '#d9a660', '#fff1c8', '#8a4c27'), core=GOLDP, licks=0)
    return stick | hook


# ------------------------------------------------------------------ 1. Glowtail Dot: corner-TT round, common. Moss green dot; its east tab is the glowing tail.
def glowtail_dot():
    key = 'pl-ffy-1'
    st = Sticker()
    core = (9, 23, 40, 50)
    body = piece(core, n=('T', 'round', -5, 3.8), e=('T', 'round', 3, 4.2), s='F', w='F')
    antenna(st, 29, 23, [(29, 18), (31, 14), (34, 13)], col='#355e30')
    antenna(st, 35, 23, [(37, 19), (40, 17), (43, 18)], col='#355e30')
    st.part(body, tex=fill(key, body, 9, 23, 28, list(MOSS)), contour=True)
    tail = body & (CX > 40.5)
    st.paint(tail, GLOW[0])
    st.paint(tail & ~shift(tail, -1, -1), GLOW[1])
    st.paint(tail & disc(46.5, 38.5, 2.2), GLOW[2])
    st.stitch(body & (CX < 40), col=GOLD)
    glow_rays(st, [(55, 37, 1, 0), (53, 31, 1, -1), (53, 45, 1, 1)])
    nub_feet(st, [13, 30], 51, '#355e30')
    st.eye(14, 31, look=(1, 0))
    arc_eye(st, 27, 33, up=True)
    st.dots([(26, 31), (32, 31)], UMBER)                     # wink crinkles
    st.sprite(['U...U', '.URU.', '..R..'], 19, 40, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 2. Canoe Glimmer: edge-BTB tri, common. A lamp-amber glass lamp sitting in a red outrigger canoe.
def canoe_glimmer():
    key = 'pl-ffy-2'
    st = Sticker()
    core = (17, 20, 46, 45)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 3.6), e=('B', 'tri', 0, 3.2), w=('B', 'tri', 0, 3.2))
    st.part(body, tex=fill(key, body, 17, 20, 30, list(AMBER)), contour=True)
    st.blank_shade(body, holes, width=1)
    bars = (rect(21, 22, 21, 44) | rect(42, 22, 42, 44)) & body & ~grow(holes, 1)
    st.paint(bars, '#8a4c27')
    st.paint(rect(17, 20, 46, 21) & body, '#8a4c27')
    st.stitch(body & (CX > 22) & (CX < 42), col='#fff1c8')
    canoe(st, 8, 55, 44)
    st.sprite(['.WW..', 'WWWGG', '..GgG', '...G.'], 43, 9, {'W': WINGP[0], 'G': GLOW[0], 'g': GLOW[2]}, solid=False)   # a visiting firefly
    st.extra[9:13, 43:48] |= np.array([[0, 1, 1, 0, 0], [1, 1, 1, 1, 1], [0, 0, 1, 1, 1], [0, 0, 0, 1, 0]], bool)
    glow_rays(st, [(49, 8, 1, -1), (50, 11, 1, 0)])
    st.eye(23, 28, look=(0, -1))
    st.eye(35, 28, look=(0, -1))
    st.dots([(27, 31), (39, 31)], CREAM)                         # second glint: shiny adoring eyes
    st.paint(rect(21, 35, 23, 35) | rect(39, 35, 41, 35), BLUSH)
    st.mouth('o', 30, 36)
    return key, st


# ------------------------------------------------------------------ 3. Lake Twinkle: inner-TBTB peg, common. Deep lake teal, half under the water line, bubbles.
def lake_twinkle():
    key = 'pl-ffy-3'
    st = Sticker()
    core = (14, 19, 47, 45)
    body, holes = piece_blanks(core, n=('T', 'peg', 0, 3.6), s=('T', 'peg', 0, 3.6), e=('B', 'peg', 0, 3.2), w=('B', 'peg', 0, 3.2))
    st.part(body, tex=fill(key, body, 14, 19, 34, list(LAKE)), contour=True)
    st.blank_shade(body, holes, width=1)
    wave = 37 + 1.2 * np.sin(XX * 0.8)
    under = body & (CY > wave)
    st.paint(under, '#16506a')
    st.paint(under & ~shift(under, 0, 1), '#5ad8c8')
    st.paint(under & ((XX + 2 * YY) % 9 == 0) & (CY > wave + 2), '#2c84a0')
    st.paint(disc(37.5, 47.5, 1.6) & body, GLOW[0])           # the reflection's own blink, down below
    st.dots([(37, 47)], GLOW[2])
    st.stitch(body & (CY < wave - 1), col='#a8c4e0', skip=grow(holes, 3))
    ripples(st, 31, 58, [9])
    st.eye(19, 26, look=(0, 1), lid=2)
    st.eye(35, 26, look=(0, 1), lid=2)
    st.sprite(['.U.', 'U.U', '.U.'], 29, 33, {'U': UMBER}, solid=False)
    bubble(st, 49, 14, r=2)
    bubble(st, 54, 9, r=1)
    bubble(st, 44, 10, r=1)
    return key, st


# ------------------------------------------------------------------ 4. Spare Wings: inner-TTTT double, uncommon. Glow lime, four pale wings in two stacked pairs, giddy.
def spare_wings():
    key = 'pl-ffy-4'
    st = Sticker()
    core = (19, 24, 44, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    for s_ in (-1, 1):                                       # mirrored: big back wing, small front wing per shoulder
        wing(st, 31.5 + s_ * 15, 14, 7, 3.4, -s_ * 32)
        wing(st, 31.5 + s_ * 18.5, 21, 5, 2.6, -s_ * 8)
    st.part(body, tex=fill(key, body, 19, 24, 26, list(LIME)), contour=True)
    st.stitch(body, col='#86649e')                           # uncommon accent: the stalactite lavender
    for x, y in ((8, 9), (9, 11), (54, 9), (53, 11)):        # flutter marks
        st.px[y, x] = hx(WINGP[2])
        st.extra[y, x] = True
    arc_eye(st, 23, 31, up=True)
    arc_eye(st, 35, 31, up=True)
    st.paint(rect(22, 34, 24, 34) | rect(38, 34, 40, 34), BLUSH)
    st.mouth('grin', 29, 36)
    return key, st


# ------------------------------------------------------------------ 5. Night Archway: inner-BBBB tri, uncommon. Stalactite purple rock with a moonlit arch window on its belly.
def night_archway():
    key = 'pl-ffy-5'
    st = Sticker()
    core = (11, 17, 52, 51)
    body, holes = piece_blanks(core, n=('B', 'tri', 0, 3.0), e=('B', 'tri', 0, 3.0), s=('B', 'tri', 0, 3.0), w=('B', 'tri', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 17, 42, list(ROCK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GLOW[0], skip=grow(holes, 3))        # uncommon accent: firefly glow
    arch_window(st, 22, 41, 20, 43)
    tally(st, 15, 27)
    for x, y in ((46, 24), (47, 40), (16, 42)):
        st.paint(rect(x, y, x + 1, y + 1), GLOW[0])
        st.dots([(x, y)], GLOW[2])
    boots(st, [15, 42], 52)
    st.eye(25, 27, look=(1, -1), lid=2)
    st.eye(33, 27, look=(1, -1))
    st.paint(line([(24, 25), (28, 24)]) | line([(33, 23), (37, 24)]), UMBER)
    st.sprite(['UUUU.', '...RU', '...R.'], 28, 34, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Firefly Lamplighter: whimsy-firefly round, rare. A big chibi firefly with a lit lamplighter pole.
def firefly_lamplighter():
    key = 'pl-ffy-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    wing(st, 14, 17, 7, 3.6, 30)
    wing(st, 49, 17, 7, 3.6, -30)
    antenna(st, 27, 15, [(26, 12), (23, 10), (20, 10)])
    antenna(st, 36, 15, [(37, 12), (40, 10), (43, 10)])
    head = disc(31.5, 25.5, 11.5)
    belly = ellipse(31.5, 44.5, 11, 9.5)
    tab = knob('e', 'round', 45, 41.5, r=3.0)
    body = head | belly | tab
    wick_pole(st, 50, 53, 51, 26)
    st.part(body & ~head, GLOW[0], contour=True)
    gl = belly & ~head
    st.paint(gl & disc(29, 47, 5), GLOW[2])
    st.paint(gl & ~shift(gl, -2, -2), GLOW[3])
    for yy in (39, 43):                                      # belly segment bands
        st.paint(gl & (YY == yy) & ~disc(29, 47, 5), GLOW[1])
    tex = fill(key, head, 20, 14, 23, list(COCOA))
    st.part(head, tex=tex, contour=True)
    st.stitch(head, col='#f5b860')
    st.paint(tab, COCOA[0])
    st.paint(tab & ~shift(tab, -1, -1), '#6a4430')
    st.eye(23, 22, look=(0, 0))
    st.eye(35, 22, look=(0, 0))
    for x in (24, 36):                                       # star glints in the pupils
        st.dots([(x + 1, 23), (x, 24), (x + 2, 24), (x + 1, 25)], GOLD)
        st.dots([(x + 1, 24)], GOLD_L)
    st.mouth('grin', 29, 30)
    star_badge(st, 36, 41)
    st.sparkle(54, 6)
    st.sparkle(5, 40, big=False)
    st.sparkle(7, 6, big=False)
    return key, st


PALS = [glowtail_dot, canoe_glimmer, lake_twinkle, spare_wings, night_archway, firefly_lamplighter]

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
        print('%-10s %-20s %-9s %-15s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
