"""Puzzle Pals: FYNBOS FIRE TRAILS (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-fyn-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_fyn.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-fynbos-fire-trails.png, calmed onto 2 or 3 tones of a pal-own colour family so the face reads.
Delve mood: cosy-curious cave beasts and the dark's small treasures (here: what the fire left behind), never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Firelily Flicker  ember coral                  | an orange fire lily trumpet on a green stem, nub feet     | cheeky wink, open grin
  2 Ash Sprout        pale warm ash                | a two-leaf green sprout on its peg, root-toe feet, ash dots | shy: looks down, blush, tiny mouth
  3 Charcoal Twiglet  charcoal slate               | holds a charred twig like a candle, ember + tiny flame tip | sleepy heavy lids, flat mouth, felt boots
  4 Protea Petals     protea pink (+ bract cream)  | a mirrored crown of pointed protea petals, cream tuft band  | startled: wide eyes up, brows up, o mouth, paws up
  5 Sunset Gap        sunset gold (+ dusk purple)  | a dusk-purple nightcap with a star bobble, smoke blanket  | content: closed happy arcs, wide smile
  6 Trail Dassie      dassie tan (rare)            | whimsy rock hyrax, sitting, sniffing a little protea      | blissful beady eyes, w mouth, sniff marks
Plus (4) and Ring (5): all four knobs centred (n, s on the centre line, e and w at the same height): no rotating offsets.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-fynbos-fire-trails'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-fynbos-fire-trails-06ba6d')

CORAL = ('#b0544a', '#c46c5a')
ASHP = ('#b0a496', '#c4baac')
CHAR = ('#4e4660', '#625a78')
PINK = ('#b04a78', '#c65e8c')
SUNSET = ('#f0903a', '#f8b860', '#fbd890')
DASSIE = ('#9a7656', '#b08e6a')
LILY = ('#f08a24', '#e0501f', '#f3ca4f', '#fff1c8')       # body, deep, gold, cream
LEAF = ('#4a8a3e', '#356a2e', '#7cb860')
TWIG = ('#3a2a30', '#2a1a1e', '#5a4448')
PETAL = ('#f08ab4', '#c85a8a', '#fbd0e0')
BRACT = '#d8c8a0'
DUSK = ('#6a4a6a', '#4e3450', '#8a6a8c')
SMOKE = ('#b8a8c4', '#9a88a8', '#d8cce0')
CREAMY = '#ecdcb4'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def stem(st, pts, w=2):
    m = line(pts, w=w)
    st.part(m, LEAF[0], d=1, contour=True)
    return m


def leaf(st, cx, cy, rx, ry, tilt):
    """A small oval leaf, tilt > 0 leans its tip right: drawn as a slanted ellipse with a light midrib."""
    m = ((CX - cx - (CY - cy) * -tilt) / rx) ** 2 + ((CY - cy) / ry) ** 2 <= 1.0
    st.part(m, LEAF[0], d=1, contour=True)
    st.paint(m & shrink(m, 1) & (np.abs((CX - cx) + (CY - cy) * tilt * 1.0) < 0.6), LEAF[2])
    return m


def fire_lily(st, cx, by, h=9):
    """A fire lily trumpet: flared bell of 3 rounded-point petals opening upward from (cx, by), gold throat, deep lower edge."""
    bell = poly([(cx - 2, by), (cx - 5.5, by - h + 2), (cx - 4, by - h), (cx - 1.5, by - h + 3), (cx, by - h - 1), (cx + 1.5, by - h + 3),
                 (cx + 4, by - h), (cx + 5.5, by - h + 2), (cx + 2, by)])
    st.part(bell, LILY[0], d=1, contour=True)
    throat = poly([(cx - 1.2, by - 1), (cx - 2.5, by - h + 3), (cx + 2.5, by - h + 3), (cx + 1.2, by - 1)]) & shrink(bell, 1)
    st.paint(throat, LILY[2])
    st.paint(bell & (YY >= by - 1), LILY[1])
    st.dots([(int(cx) - 4, int(by - h) + 1), (int(cx) + 3, int(by - h) + 1)], LILY[3])
    return bell


def ash_dots(st, mask, col):
    m = mask & (((XX * 5 + YY * 3) % 11) == 0) & ((YY % 3) == 1) & shrink(mask, 3)
    st.paint(m, col)
    return m


def root_toes(st, xs, y, col):
    for x in xs:
        st.paint(rect(x, y, x, y + 2) | rect(x - 1, y + 3, x - 1, y + 3) | rect(x + 1, y + 2, x + 1, y + 2), col, solid=True)


def twig_candle(st, x, y0, y1):
    """A charred fynbos twig held upright: 2 px stick with a side fork and knots, its tip a glowing ember with a tiny sleepy flame."""
    m = line([(x, y1), (x, y0)], w=2) | line([(x + 1, y0 + 9), (x + 4, y0 + 5)], w=1)
    st.part(m, TWIG[0], d=0, contour=True)
    st.paint(m & (XX == x) & ((YY % 4) == 1), TWIG[2])
    flame(st, x + 0.5, y0 - 1, w=4, h=6, lean=0.4, pal=LAVA, licks=0)
    st.paint(rect(x - 1, y0 - 1, x + 1, y0), '#f08a24', solid=True)
    st.dots([(x, y0)], GOLD)
    return m


def petal(cx, cy, ang, L, w):
    a = math.radians(ang)
    ux, uy, px, py = math.cos(a), math.sin(a), -math.sin(a), math.cos(a)
    return poly([(cx + px * w, cy + py * w), (cx + ux * L * 0.55 + px * w * 1.1, cy + uy * L * 0.55 + py * w * 1.1), (cx + ux * L, cy + uy * L),
                 (cx + ux * L * 0.55 - px * w * 1.1, cy + uy * L * 0.55 - py * w * 1.1), (cx - px * w, cy - py * w)])


def protea_crown(st, cx, cy, angs, L=12, w=2.4):
    m = blank()
    for a in angs:
        m |= petal(cx, cy, a, L, w)
    st.part(m, PETAL[0], d=1, contour=True)
    for a in angs:
        rad = math.radians(a)
        tip = petal(cx + math.cos(rad) * L * 0.55, cy + math.sin(rad) * L * 0.55, a, L * 0.45, w * 0.7) & m
        st.paint(tip, PETAL[2])
    return m


def nightcap(st):
    """A floppy dusk-purple nightcap on the top-left corner, its tip flopping down-left to a cream star bobble."""
    cap = poly([(12, 26), (27, 22), (24, 14), (18, 11), (12, 13), (9, 19), (10, 22), (13, 18), (16, 17)])
    st.part(cap, DUSK[0], d=1, contour=True)
    st.paint(cap & ((XX - YY) % 4 == 0) & shrink(cap, 1), DUSK[2])
    cuff = line([(11, 25), (27, 21)], w=3)
    st.part(cuff, SMOKE[2], d=1, contour=True)
    st.sprite(['..s..', '.sSs.', 'sSWSs', '.sSs.', '.s.s.'], 7, 21, {'s': GOLD_D, 'S': GOLD, 'W': GOLD_L})
    return cap | cuff


def smoke_blanket(st, x0, x1, y, clip):
    """A soft smoke blanket tucked over the bottom: a scalloped lavender band, 4 scallops on its top edge."""
    m = rect(x0, y, x1, y + 6)
    n = 4
    span = (x1 - x0 + 1) / n
    for i in range(n):
        m |= disc(x0 + span * (i + 0.5), y + 0.5, span / 2)
    m &= clip
    st.part(m, SMOKE[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1) & shrink(m, 0), SMOKE[2])
    st.paint(m & (YY == y + 4) & ((XX % 6) < 3), SMOKE[1])
    return m


def stars(st, pts):
    for x, y in pts:
        st.dots([(x, y)], GOLD_L)
        st.extra[y, x] = True


def bead_eye(st, x, y):
    """Dassie eye: a 4 x 5 glossy dark bead in a cream ring, two glints (it has spotted cake)."""
    ring = ellipse(x + 2, y + 2.5, 3.0, 3.4)
    st.paint(grow(ring, 1), UMBER2)
    st.paint(ring, CREAM)
    b = ellipse(x + 2, y + 2.7, 2.1, 2.6)
    st.paint(b, UMBER)
    st.dots([(x + 1, y + 1), (x + 3, y + 4)], CREAM)


def little_protea(st, cx, cy, r=5.0):
    stalk = line([(cx - 1, cy + r), (cx - 3, cy + r + 7)], w=2)
    st.part(stalk, LEAF[0], d=1, contour=True)
    m = blank()
    for a in range(-170, 10, 30):
        m |= petal(cx, cy + 1, a, r + 2.5, 1.5)
    m |= disc(cx, cy + 1, r - 1)
    st.part(m, PETAL[0], d=1, contour=True)
    st.paint(disc(cx, cy + 1.2, r - 2.2), BRACT)
    st.paint(disc(cx + 0.6, cy + 1.8, r - 3.4), '#c9b8a0')
    return m | stalk


# ------------------------------------------------------------------ 1. Firelily Flicker: corner-TB round, common. Ember coral, a fire lily sprouting on its head, winking.
def firelily_flicker():
    key = 'pl-fyn-1'
    st = Sticker()
    core = (12, 24, 44, 49)
    body, holes = piece_blanks(core, n=('T', 'round', -7, 3.6), e=('B', 'round', 2, 3.2))
    stem(st, [(37, 25), (38, 21), (39, 17)])
    leaf(st, 43, 22, 1.6, 3.4, 0.6)
    st.part(body, tex=fill(key, body, 12, 24, 33, CORAL), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f3ca4f', skip=grow(holes, 3))
    fire_lily(st, 39.5, 17, h=8)
    nub_feet(st, [16, 33], 49, '#7a3a40')
    st.eye(17, 30, look=(1, 0))
    st.sprite(['.UUU.', 'U...U'], 30, 32, {'U': UMBER}, solid=False)        # the wink
    st.paint(line([(30, 29), (34, 28)]), UMBER)
    st.paint(rect(15, 38, 17, 38) | rect(36, 38, 38, 38), BLUSH)
    st.mouth('grin', 23, 38)
    return key, st


# ------------------------------------------------------------------ 2. Ash Sprout: edge-TBB peg, common. Pale ash, a green sprout pushing up through its peg, shy.
def ash_sprout():
    key = 'pl-fyn-2'
    st = Sticker()
    core = (14, 26, 46, 49)
    stem(st, [(30, 18), (30, 9)])
    leaf(st, 26, 9, 3.6, 1.8, -0.3)
    leaf(st, 34.5, 11, 3.2, 1.7, 0.3)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.6), e=('B', 'peg', 2, 3.2), w=('B', 'peg', 2, 3.2))
    st.part(body, tex=fill(key, body, 14, 26, 32, ASHP), contour=True)
    st.blank_shade(body, holes, width=1)
    ash_dots(st, body & ~rect(16, 28, 44, 44), '#8a7e74')
    st.stitch(body, col='#7cb860', skip=grow(holes, 3))
    root_toes(st, [19, 23, 37, 41], 50, '#6a4a3a')
    st.eye(19, 32, look=(-1, 1))
    st.eye(32, 32, look=(-1, 1))
    st.paint(line([(19, 29), (23, 30)]) | line([(32, 30), (36, 29)]), UMBER)  # worried little brows
    st.paint(rect(17, 39, 19, 39) | rect(36, 39, 38, 39), BLUSH)
    st.sprite(['U.U', '.U.'], 26, 40, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Charcoal Twiglet: inner-TBTB tri, common. Charcoal slate, holding a charred twig candle, drowsy.
def charcoal_twiglet():
    key = 'pl-fyn-3'
    st = Sticker()
    core = (13, 24, 43, 47)
    body, holes = piece_blanks(core, n=('T', 'tri', -5, 3.4), e=('B', 'tri', 1, 2.8), s=('T', 'tri', 4, 3.4), w=('B', 'tri', 1, 2.8))
    st.part(body, tex=fill(key, body, 13, 24, 31, CHAR), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e0501f', skip=grow(holes, 3))
    for x in (14, 36):
        sh = rect(x, 48, x + 6, 50)
        sh[48, x] = sh[48, x + 6] = False
        st.part(sh & ~body, SHOE[0], d=1, contour=True)
    twig_candle(st, 49, 22, 47)
    st.part(ellipse(47.5, 40, 3, 2.4), CHAR[1], d=1, contour=True)          # its paw round the twig
    st.eye(17, 31, lid=3)
    st.eye(29, 31, lid=3)
    st.paint(rect(16, 38, 18, 38) | rect(33, 38, 35, 38), '#9a6a8a')
    st.mouth('flat', 24, 39)
    st.dots([(27, 40)], CREAM)                                               # a tiny drool bead, it is nodding off
    return key, st


# ------------------------------------------------------------------ 4. Protea Petals: inner-TTTT double, uncommon. Protea pink with a mirrored petal crown, startled.
def protea_petals():
    key = 'pl-fyn-4'
    st = Sticker()
    core = (18, 26, 45, 47)
    cx = (core[0] + core[2] + 1) / 2
    protea_crown(st, cx, 31, [-162, -138, -114, -66, -42, -18], L=17, w=2.4)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 26, 28, PINK), contour=True)
    st.paint(body & (YY >= 26) & (YY <= 27) & (((XX + YY) % 2) == 0), BRACT)  # silvery bract tuft band
    st.stitch(body & (YY > 27), col=BRACT)                                    # uncommon accent: the bract cream
    for x in (8, 54):                                                         # paws flung up on the side tabs
        st.part(disc(x + 0.5, 34.5, 2.0), CREAMY, d=1, contour=True)
    st.eye(20, 31, look=(0, -1))
    st.eye(33, 31, look=(0, -1))
    st.paint(line([(20, 28), (24, 27)]) | line([(33, 27), (37, 28)]), UMBER)
    st.mouth('o', 30, 39)
    return key, st


# ------------------------------------------------------------------ 5. Sunset Gap: inner-BBBB round, uncommon. Sunset gold in a dusk nightcap, tucked under a smoke blanket, content.
def sunset_gap():
    key = 'pl-fyn-5'
    st = Sticker()
    core = (12, 22, 51, 51)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 40, SUNSET))
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 44), col=DUSK[0], skip=grow(holes, 3))             # uncommon accent: the dusk purple
    smoke_blanket(st, 12, 51, 44, body)
    st.blank_shade(body, holes, width=1)
    nightcap(st)
    st.sprite(['U...U', '.UUU.'], 19, 32, {'U': UMBER}, solid=False)
    st.sprite(['U...U', '.UUU.'], 38, 32, {'U': UMBER}, solid=False)
    st.paint(rect(17, 36, 19, 36) | rect(42, 36, 44, 36), BLUSH)
    st.sprite(['U.....U', '.UUUUU.'], 28, 37, {'U': UMBER}, solid=False)
    stars(st, [(52, 13), (57, 18), (46, 9)])
    return key, st


# ------------------------------------------------------------------ 6. Trail Dassie: whimsy-dassie double, rare. A chibi rock hyrax sitting on the trail, sniffing a protea like cake.
def trail_dassie():
    key = 'pl-fyn-6'
    st = Sticker()
    blob = ellipse(31, 37, 17, 15) & (CY > 20) | ellipse(31, 31, 14, 11.5)   # one squat potato: no neck, no waist (a hyrax, not a bear)
    ears = disc(20.5, 21.5, 2.8) | disc(41.5, 21.5, 2.8)                        # tiny round ears low on the sides
    tab = knob('w', 'double', 41, 15.5, r=3.0)
    body = blob | ears | tab
    st.part(body, tex=fill(key, body, 13, 19, 34, DASSIE), contour=True)
    st.paint(ears & shrink(ears, 1) & ~shrink(blob, 0), '#d8a888')
    st.paint(body & shrink(body, 2) & ((XX * 3 + YY * 5) % 7 == 0) & (YY % 2 == 0), '#c8a478')   # grizzled coat
    st.paint(ellipse(30, 45, 7, 5.5) & blob, '#d8c098')                        # pale chest
    st.stitch(blob & (YY > 44), col=BRACT)
    st.part(ellipse(23, 52, 4.5, 2.2) | ellipse(37, 52, 4.5, 2.2), '#6a4a30', d=1, contour=True)
    for x in (19, 35):                                                         # the pale brow spot over each eye
        st.paint(ellipse(x + 2.5, 24.5, 2.6, 1.2), CREAMY)
    bead_eye(st, 20, 27)
    bead_eye(st, 36, 27)
    muzzle = ellipse(31, 37, 5.5, 3.6)
    st.part(muzzle, '#e0c8a0', d=1, contour=True)
    st.sprite(['UUU', '.U.'], 30, 35, {'U': UMBER}, solid=False)              # blunt nose, twitching
    st.sprite(['U.U.U', '.U.U.'], 29, 38, {'U': UMBER}, solid=False)
    st.paint(rect(17, 35, 19, 35) | rect(43, 35, 45, 35), BLUSH)
    little_protea(st, 44, 40, r=5)
    st.part(ellipse(40, 46, 3, 2.4) | ellipse(46, 48, 2.6, 2.2), DASSIE[1], d=1, contour=True)   # paws hugging the stalk
    st.sprite(['C.', '.C', 'C.'], 38, 33, {'C': CREAM}, solid=False)            # sniff sniff
    st.sparkle(6, 6)
    st.sparkle(52, 8, big=False)
    st.sparkle(55, 20, big=False)
    return key, st


PALS = [firelily_flicker, ash_sprout, charcoal_twiglet, protea_petals, sunset_gap, trail_dassie]

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
