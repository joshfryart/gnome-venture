"""Puzzle Pals: REEF OF THE BOX JELLY QUEEN (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-bjq-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_bjq.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair + palib parts (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-reef-of-the-box-jelly-queen.png, calmed by brightness onto 2 tones of ONE colour family per pal, so no two
pals share a body tone: 1 tentacle pink, 2 clownfish orange, 3 lagoon aqua, 4 crown gold, 5 deep-sea blue, 6 queen periwinkle.
Each has its own accessory (tentacle curl + music notes, coral sprig + fin tail, a hanging blue bell, a bubble crown, a brass porthole monocle,
a too-small tilted crown), its own face (sleepy, shy, startled, cheeky wink, grumpy, smug-regal) and its own pose (sway, peek-lean, upright...).
Picture dominants: water #6ed0d4 / #4793b1 / #2f7ca2, queen #9ab8f0, crown gold #e8a317, sand #d8c08a, tentacle pink #e8a0d8, clownfish #f08a24.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-reef-of-the-box-jelly-queen'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-reef-of-the-box-jelly-queen-6c4091')

PINK = ('#e08ac8', '#c060a8', '#f4c8e8', '#8a3a7a')
ORANGE = ('#f08a24', '#e0501f', '#f5b840', '#a8352e')
AQUA = ('#6ed0d4', '#4fb4c0', '#a8ecec', '#2f7ca2')
GOLDB = ('#e8a317', '#c98a14', '#f5cf6a', '#8a5a10')
DEEP = ('#3a94b0', '#2f7ca2', '#62b4cc', '#1f5a7a')
PERI = ('#9ab8f0', '#7a9ad8', '#d8e8ff', '#5a6ab8')
LILAC = ('#c0a0ec', '#9a7ad0', '#e4d4fc', '#6a4aa8')
CORAL = ('#c8306e', '#9a2058', '#f06aa0', '#6a1a40')
BRASS = ('#c9a96e', '#9a7a48', '#f1dca8', '#6a4a2a')
GEM = '#d6322b'
GLASS = '#d8f0f4'
BUBBLE = ('#d8f4f4', '#a8e0e8')
CREAMW = '#fff3c8'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0, cuts=None):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones, cuts)


# ---------------------------------------------------------------- my own small parts (not in the kit)
def startled_eye(st, x, y):
    """Wide eye: 5 x 5 cream, a small 2 x 2 pupil in the middle (so it looks surprised), felt socket."""
    st.eye(x, y)
    st.px[y + 1:y + 4, x + 1:x + 4] = hx(CREAM)
    st.px[y + 2:y + 4, x + 2:x + 4] = hx(UMBER)
    st.px[y + 2, x + 2] = hx(CREAMW)


def arc_eye(st, x, y, up=True):
    """Closed eye: a 5 px arc (up = happy ^ wink, else a content - curve)."""
    rows_ = ['.UUU.', 'U...U'] if up else ['U...U', '.UUU.']
    st.sprite(rows_, x, y + 1, {'U': UMBER}, solid=False)


def blush(st, pts, col='#f0889a'):
    for x, y in pts:
        st.px[y, x:x + 2] = hx(col)


def note(st, x, y, col):
    """A floating eighth note (border only, like a sparkle)."""
    for j, row in enumerate(['.ff', '.f.', '.f.', 'ff.', 'ff.']):
        for i, ch in enumerate(row):
            if ch == 'f':
                st.px[y + j, x + i] = hx(col)
                st.extra[y + j, x + i] = True


def bubble(st, cx, cy, r):
    """Hollow bubble: pale ring + glint, floats (border only)."""
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 1.1)
    st.px[ring] = hx(BUBBLE[1])
    st.px[ring & (CX < cx) & (CY < cy)] = hx(BUBBLE[0])
    g = int(cx - r * 0.35), int(cy - r * 0.35)
    st.px[g[1], g[0]] = hx('#ffffff')
    st.extra |= ring
    st.extra[g[1], g[0]] = True


def solid_bubble(st, cx, cy, r):
    m = disc(cx, cy, r)
    st.part(m, AQUA[2], d=1, contour=True)
    st.paint(m & disc(cx - r * 0.4, cy - r * 0.4, r * 0.4), '#ffffff')
    return m


def sway(st, k, cy=None):
    """Lean the whole pal: each row moves sideways by round((cy - y) * k) px (a sway / peek-lean pose, rows stay crisp)."""
    ys = np.nonzero(st.sil)[0]
    cy = cy if cy is not None else ys.max()
    px, sil, ex = st.px.copy(), st.sil.copy(), st.extra.copy()
    st.px[:], st.sil[:], st.extra[:] = 0, False, False
    for y in range(N):
        d = int(round((cy - y) * k))
        st.px[y] = np.roll(px[y], d, axis=0)
        st.sil[y] = np.roll(sil[y], d)
        st.extra[y] = np.roll(ex[y], d)


# ------------------------------------------------------------------ 1. Tentacle Wisp: corner-TB peg, common. Pink tentacle corner, a curl of tentacle on top, swaying to music.
def tentacle_wisp():
    key = 'pl-bjq-1'
    st = Sticker()
    core = (15, 24, 42, 48)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'peg', -4, 3.6), e=('B', 'peg', 2, 3.4))
    # the curl it is named for: a 2 px tentacle rising from the peg, curling over to the right
    curl = line([(25, 15), (24, 11), (26, 7), (30, 6), (33, 8), (33, 11), (30, 12), (29, 10)], w=2)
    st.part(curl, PINK[1], d=1, contour=True)
    st.paint(curl & (XX % 3 == 0) & (YY < 12), PINK[2])          # sucker dots
    st.part(body, tex=fill(key, body, 15, 24, 28, [PINK[1], PINK[0]]))
    st.blank_shade(body, holes)
    st.stitch(body, col=PINK[2], skip=grow(holes, 3))
    # little curly tentacle feet instead of boots
    for fx in (18, 33):
        f = line([(fx, 49), (fx, 52), (fx + 2, 54), (fx + 4, 53)], w=2)
        st.part(f, PINK[1], d=1, contour=True)
    arc_eye(st, 19, 31, up=False)                                   # sleepy, eyes shut, humming
    arc_eye(st, 31, 31, up=False)
    st.paint(rect(19, 30, 23, 30) | rect(31, 30, 35, 30), PINK[3])  # heavy lids
    st.mouth('o', 26, 39)
    blush(st, [(17, 36), (36, 36)])
    sway(st, 0.08)
    note(st, 47, 10, DEEP[0])
    note(st, 53, 18, DEEP[2])
    return key, st


# ------------------------------------------------------------------ 2. Clownfish Peek: edge-TTB tri, common. Orange striped fish-piece peeking from behind a coral sprig, fin tail.
def clownfish_peek():
    key = 'pl-bjq-2'
    st = Sticker()
    core = (14, 22, 42, 47)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 5, 3.8), e=('T', 'tri', -2, 4.2), w=('B', 'tri', 2, 3.4))
    st.part(body, tex=fill(key, body, 14, 22, 29, [ORANGE[1], ORANGE[0]]))
    st.blank_shade(body, holes)
    # clownfish bands: two cream stripes edged in umber (the tail fin = the east tri tab)
    for bx in (17.5, 40.5):
        band = body & (np.abs(CX - bx) < 1.6) & shrink(body, 1) & (CY > 21)
        st.paint(body & dil4(band) & ~band & shrink(body, 1), UMBER2)
        st.paint(band, CREAM)
    tail = body & (CX > 43)
    st.paint(tail, ORANGE[2])
    st.paint(tail & (np.abs(CY - 34 - (CX - 43) * 0) < 0.6), ORANGE[1])
    st.stitch(body & ~tail, col=ORANGE[2], skip=grow(holes, 3) | grow(tail, 1))
    # the coral it hides behind: a magenta sprig in front of its lower left
    stem = line([(17, 54), (18, 47), (15, 42), (13, 39)], w=3) | line([(18, 47), (23, 44), (25, 41)], w=3) | line([(16, 44), (10, 44)], w=2)
    stem |= disc(13, 38.5, 2.2) | disc(25.5, 40.5, 2.2) | disc(9.5, 44, 1.8)
    st.part(stem, CORAL[0], d=1, contour=True)
    st.paint(disc(12.5, 38, 1.0) | disc(25, 40, 1.0) | disc(9, 43.5, 0.8), CORAL[2])
    # shy: both eyes slid to one side, tiny smile, rosy cheeks
    st.eye(23, 28, look=(1, 1))
    st.eye(31, 28, look=(1, 1))
    st.mouth('smile', 27, 37)
    blush(st, [(22, 35), (35, 35)], '#ffc8b0')
    sway(st, -0.07, cy=50)
    return key, st


# ------------------------------------------------------------------ 3. Bell Bead: inner-TBTB hook, common. Aqua bead with a blue bell hanging from its top hook; startled when it rings.
def bell_bead():
    key = 'pl-bjq-3'
    st = Sticker()
    core = (15, 22, 46, 45)
    body, holes = piece_blanks(core, n=('T', 'hook', -3, 3.6), s=('T', 'hook', 4, 3.4, True), e=('B', 'hook', 6, 2.6), w=('B', 'hook', 6, 2.6))
    st.part(body, tex=fill(key, body, 15, 22, 31, [AQUA[1], AQUA[0]]))
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=AQUA[2], skip=grow(holes, 3))
    # a bead string from the hook to a little deep-blue bell with a gold clapper
    st.paint(line([(31, 12), (38, 9), (45, 10)]), GOLD_L, solid=True)
    st.dots([(35, 10), (41, 9)], GOLD)
    bell = poly([(44, 11), (47, 11), (49, 17), (50, 19), (41, 19), (42, 17)]) | disc(45.5, 12.5, 2.2)
    st.part(bell, DEEP[1], d=1, contour=True)
    st.paint(bell & ~shift(bell, 1, 0) & shrink(bell, 1), DEEP[2])
    st.paint(rect(41, 18, 50, 19) & bell, DEEP[3])
    st.paint(rect(45, 20, 46, 21), GOLD, solid=True)
    st.dots([(52, 13), (53, 15), (39, 14)], CREAMW)                     # ding lines
    # startled: wide eyes with pinprick pupils, brows up, little o
    startled_eye(st, 22, 27)
    startled_eye(st, 33, 27)
    st.paint(rect(22, 24, 25, 24) | rect(34, 24, 37, 24), UMBER)
    st.mouth('o', 29, 35)
    # stubby arms flung up beside the face
    for ax, s in ((13, -1), (48, 1)):
        a = line([(ax, 34), (ax + s * 3, 29)], w=3)
        st.part(a, AQUA[1], d=1, contour=True)
    for fx in (19, 37):
        f = rect(fx, 46, fx + 4, 49)
        f[49, fx] = f[49, fx + 4] = False
        st.part(f, DEEP[0], d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 4. Gold Spike Tiara: inner-TTTT double, uncommon. A gold plus that is four crown spikes; its crown is mostly bubbles; cheeky wink.
def gold_spike_tiara():
    key = 'pl-bjq-4'
    st = Sticker()
    core = (20, 24, 43, 46)
    body = piece(core, r=3.6, n=('T', 'double', 0, 3.8), e=('T', 'double', 2), s=('T', 'double', 0), w=('T', 'double', 2))
    # four spikes, one leaning out of each corner of the plus (the spikes it is named for)
    spikes = blank()
    for (x, y, ax, ay) in ((20, 24, -5, -6), (43, 24, 5, -6), (20, 46, -5, 5), (43, 46, 5, 5)):
        spikes |= poly([(x - 2 * (1 if ax < 0 else -1), y), (x + ax, y + ay), (x, y - 2 * (1 if ay < 0 else -1))])
    st.part(spikes, GOLDB[2], d=1, contour=True)
    st.part(body, tex=fill(key, body, 20, 24, 24, [GOLDB[1], GOLDB[0]]))
    st.stitch(body, col=AQUA[0])                                        # uncommon accent: lagoon aqua
    st.paint(rect(28, 23, 35, 23) & body, GOLDB[2])
    gem = disc(31.5, 23.5, 1.6)
    st.paint(gem, GEM)
    st.dots([(31, 22)], '#ff9a8a')
    # the bubbles that make up the rest of its crown
    solid_bubble(st, 23, 12, 2.6)
    solid_bubble(st, 40, 11, 2.2)
    bubble(st, 31, 7, 3.0)
    bubble(st, 50, 16, 2.2)
    bubble(st, 12, 18, 1.8)
    # cheeky: one wink, one open, a toothy grin
    arc_eye(st, 24, 30, up=True)
    st.eye(34, 29, look=(0, 0))
    st.mouth('tooth', 29, 38)
    return key, st


# ------------------------------------------------------------------ 5. Jellybell Porthole: inner-BBBB peg, uncommon. A deep-sea ring with a brass porthole worn as a monocle; grumpy.
def jellybell_porthole():
    key = 'pl-bjq-5'
    st = Sticker()
    core = (12, 19, 50, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 6, 3.2), e=('B', 'peg', 8, 3.2), s=('B', 'peg', 4, 3.2), w=('B', 'peg', 8, 3.2))
    st.part(body, tex=fill(key, body, 12, 19, 39, [DEEP[0], DEEP[2]]))
    st.blank_shade(body, holes)
    st.stitch(body, col=PERI[0], skip=grow(holes, 3))                   # uncommon accent: queen periwinkle
    # brass porthole round the left eye: rim, 4 bolts, pale glass, the eye big behind it
    rim = disc(26.5, 32.5, 6.6) & ~disc(26.5, 32.5, 4.6)
    st.paint(disc(26.5, 32.5, 4.6), GLASS)
    st.eye(24, 30, look=(1, 0), lid=1, socket=None)
    st.part(rim, BRASS[0], d=1, contour=False)
    st.dots([(26, 26), (26, 38), (20, 32), (32, 32)], BRASS[3])
    st.dots([(23, 29), (24, 28)], '#ffffff')
    st.dots([(31, 37), (32, 39), (33, 41)], BRASS[2])
    # the other eye: grumpy, heavy lid and a cross brow
    st.eye(37, 30, look=(-1, 0), lid=2)
    st.paint(line([(36, 27), (42, 29)]), UMBER)
    st.sprite(['.UUU.', 'U...U'], 34, 38, {'U': UMBER}, solid=False)   # frown
    for fx in (16, 39):
        f = ellipse(fx + 3.5, 54, 4.0, 2.2)
        st.part(f, DEEP[1], d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 6. Little Box Queen: whimsy-jelly tri, rare. A cube-bell box jelly, lilac tentacles, a crown too small for her; smug.
def little_box_queen():
    key = 'pl-bjq-6'
    st = Sticker()
    x0, y0, x1, y1 = 14, 16, 45, 39
    bellm = rect(x0, y0, x1, y1)
    for cx, cy in ((x0 + 4.5, y0 + 4.5), (x1 - 3.5, y0 + 4.5), (x0 + 4.5, y1 - 3.5), (x1 - 3.5, y1 - 3.5)):
        q = (np.abs(CX - cx) <= 5) & (np.abs(CY - cy) <= 5) & ((CX - cx) * np.sign(cx - 31) > 0) & ((CY - cy) * np.sign(cy - 28) > 0)
        bellm &= ~(q & ~disc(cx, cy, 4.6))
    tab = knob('e', 'tri', 26, x1 + 1, r=2.8)
    # tentacles: 4 wavy 2 px strands under the bell (silhouette), lilac
    tent = blank()
    for i, tx in enumerate((18, 25, 32, 39)):
        ph = 1 if i % 2 else -1
        L = (53, 50, 53, 51)[i]
        tent |= line([(tx, 39), (tx, 45), (tx + ph, 48), (tx + ph, L)], w=2) | rect(tx + ph * 2, L - 1, tx + ph * 2 + 1, L)
    st.part(tent, LILAC[0], d=1, contour=True)
    st.paint(tent & (YY % 4 == 0), LILAC[2])
    body = bellm | tab
    st.part(body, tex=fill(key, body, x0, y0, 34, [PERI[1], PERI[0]]))
    # see-through bell: vertical ribs, a glass gloss panel upper left, a deep skirt band
    for rx in (24, 32, 40):
        st.paint(bellm & (XX == rx) & (YY > y0 + 2) & (YY < y1 - 3), PERI[1])
    st.paint(rect(17, 20, 19, 29) & bellm, PERI[2])
    st.paint(bellm & (YY >= y1 - 2), PERI[3])
    st.stitch(bellm, col=GOLD, depth=2, skip=~(YY == y1 - 3))
    # her crown: small, gold, three spikes with red gems, slipping to one side
    crown = rect(26, 13, 37, 16)
    for sx in (26, 31, 36):
        crown |= poly([(sx - 0.2, 13), (sx + 1, 8), (sx + 2.2, 13)])
    st.part(crown, GOLDB[0], d=1, contour=True)
    st.paint(crown & (YY == 13), GOLDB[2])
    st.dots([(28, 15), (32, 15), (36, 15)], GEM)
    # smug-regal: half-lidded eyes looking down her nose, lashes, a pleased smirk
    st.eye(20, 25, look=(1, 1), lid=2)
    st.eye(34, 25, look=(1, 1), lid=2)
    st.dots([(19, 24), (39, 24)], UMBER)
    st.mouth('smirk', 28, 33)
    blush(st, [(19, 31), (38, 31)], '#c08ad8')
    st.sparkle(6, 8)
    st.sparkle(53, 7, big=False)
    st.sparkle(54, 46, big=False)
    return key, st


PALS = [tentacle_wisp, clownfish_peek, bell_bead, gold_spike_tiara, jellybell_porthole, little_box_queen]

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
