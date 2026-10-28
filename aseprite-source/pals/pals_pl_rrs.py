"""Puzzle Pals: THE RED ROCK SONGLINES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-rrs-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_rrs.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cosy-curious desert critters and the dark's small treasures, never scary. Built on palib + kit_lair (picture, rows, fill,
calm_tones, tidy) as building blocks only; every accessory below is drawn here. Body = the row's own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-the-red-rock-songlines.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Dotted Trail       dawn-sky peach              | a winding songline of painted dots + a twig dot-brush held out | cheeky wink, tongue grin
  2 Galah Chatter      galah pink (+ grey wings)   | pale pink crest, bone beak, grey wing flaps, gossip dots       | chatty: bead eyes with rose rings, open beak
  3 Hummed Note        song-note gold              | a big umber quaver worn on its head, two hum waves             | blissful closed ^ ^ arcs, round o hum
  4 Dotcircle Painting red-rock rust (+ gold)      | concentric dot rings painted on its belly, a dot-tip brush tail| smug half lids, smirk
  5 Monolith Hidey     monolith maroon (+ sun)     | a red rock cap with ribs, a cave hollow, the noon sun peeking  | shy downward glance, blush, wobbly mouth
  6 Songline Kangaroo  kangaroo tan (rare)         | whimsy kangaroo: tall ears, tail, big feet, pointing paw, dilly bag, gold note | big glossy eyes, open smile
Plus (4) is mirror-symmetric (all knobs centred). Blanks kept small and shaded. No browns left muddy (maroon lifted).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-the-red-rock-songlines'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-the-red-rock-songlines-c16ad4')

PEACH = ('#eab47a', '#f8d4a0')
PINK = ('#e2789c', '#f09ab4')
NOTEG = ('#e8a317', '#f5c24a')
RUST = ('#c04e34', '#c65236')
MAROON = ('#7e2a36', '#963a44')
TAN = ('#c88a4a', '#dca466')
REDROCK = ('#c4492f', '#a3402b', '#e0704a', '#6a2420')
GREY = ('#a8a8b4', '#7e8090', '#cfd0da', '#5a5c6a')
CREST = '#fbd0dc'
BEAK = ('#efe2c8', '#c8b490')
SUN = ('#f5cf6a', '#fff1c8')
CAVE = '#3a1218'
BUSH = ('#5f9a3e', '#3e6e2e', '#88c060', '#2a4a22')
BAG = ('#a3402b', '#7a2a22', '#d0603e', '#4a1a1a')
STICK = '#7a4a2a'
BLUSH = '#f0a0a0'
DOTS = ['#a3402b', '#e46a9b', '#d08a10']


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def dot(st, x, y, col, mask=None, solid=False):
    m = rect(x, y, x + 1, y + 1)
    if mask is not None:
        m &= mask
    st.paint(m, col, solid=solid)
    return m


def dot_trail(st, pts, mask, cols=DOTS):
    for i, (x, y) in enumerate(pts):
        dot(st, x, y, cols[i % len(cols)], mask)


def arc_eye(st, x, y, up=True, col=UMBER):
    """A closed 5 px arc eye: up=True is a happy ^ arc (blissful), False a sleepy u."""
    rows_ = ['.UUU.', 'U...U'] if up else ['U...U', '.UUU.']
    st.sprite(rows_, x, y, {'U': col}, solid=False)


def wink(st, x, y):
    st.sprite(['U...', '.UUU', 'U...'], x, y, {'U': UMBER}, solid=False)   # a > wink


def bead_eye(st, x, y):
    """Galah eye: a 3 x 3 umber bead with a cream glint inside a rose-pink eye ring."""
    ring = rect(x - 1, y - 1, x + 3, y + 3)
    for cx, cy in ((x - 1, y - 1), (x + 3, y - 1), (x - 1, y + 3), (x + 3, y + 3)):
        ring[cy, cx] = False
    st.paint(ring, '#f6b8c8')
    st.paint(rect(x, y, x + 2, y + 2), UMBER)
    st.dots([(x, y)], CREAM)


def roo_eye(st, x, y):
    """Kangaroo eye like the picture's: 4 x 5 glossy umber oval, two cream glints, a cream rim under it."""
    e = rect(x, y, x + 3, y + 4)
    e[y, x] = e[y, x + 3] = e[y + 4, x] = e[y + 4, x + 3] = False
    st.paint(grow(e, 1) & ~e, UMBER2)
    st.paint(e, UMBER)
    st.dots([(x + 1, y + 1), (x + 2, y + 3)], CREAM)


def twig_brush(st, x0, y0, x1, y1):
    """A thin painting stick held out, its chewed tip loaded with a fat gold dot."""
    st.paint(line([(x0, y0), (x1, y1)], 2), STICK, solid=True)
    st.paint(line([(x0, y0), (x1, y1)]), '#9a6a3a')
    tip = disc(x1 + 0.5, y1 + 0.5, 2.0)
    st.part(tip, SUN[0], d=1, contour=True)
    st.dots([(x1, y1)], SUN[1])


def quaver(st, x, y):
    """A big umber song note worn on the head: note head at (x, y) (5 x 4), stem up 9 px, a curled flag. Glint on the head."""
    head = ellipse(x + 2.5, y + 2, 3.0, 2.2)
    stem = rect(x + 4, y - 9, x + 5, y + 1)
    flag = line([(x + 5, y - 9), (x + 8, y - 7), (x + 9, y - 4), (x + 8, y - 2)], 2)
    m = head | stem | flag
    st.part(m, '#551e21', d=1, contour=True)
    st.dots([(x + 1, y + 1)], '#c0606a')
    return m


def hum_wave(st, x, y, n=5):
    for i in range(n):
        dy = (0, -1, 0, 1)[i % 4]
        st.extra[y + dy, x + i] = True
        st.px[y + dy, x + i] = hx(CREAM)


def dot_rings(st, cx, cy):
    """A rock-art dot circle: centre dot, gold ring of 6, cream ring of 10 (like the boulder in the picture)."""
    st.paint(rect(int(cx) - 1, int(cy) - 1, int(cx), int(cy)), '#f5cf6a')
    for r, n, col in ((3.4, 6, '#fff1c8'), (6.2, 10, '#f5cf6a')):
        for i in range(n):
            a = 2 * np.pi * i / n + 0.3
            x, y = int(round(cx + r * np.cos(a) - 0.5)), int(round(cy + r * np.sin(a) - 0.5))
            st.dots([(x, y)], col)


def crest(st, cx, y):
    """Galah crest: three rounded pale pink feather tufts fanned up from (cx, y)."""
    m = blank()
    for dx, h, lean in ((-3, 6, -2), (0, 8, 0), (3, 6, 2)):
        m |= line([(cx + dx, y), (cx + dx + lean, y - h)], 3) | disc(cx + dx + lean + 0.5, y - h + 0.5, 1.6)
    st.part(m, CREST, d=1, contour=True)
    st.paint(line([(cx, y - 1), (cx, y - 6)]), '#f6b0c4')
    return m


def wing_flap(st, x, y, side, body):
    """A grey galah wing folded on the body side: a rounded fan with two feather slits. side -1 = left wing."""
    m = (ellipse(x, y, 5.5, 6.5) & ((CX - x) * side > -0.5)) & body
    st.paint(m, GREY[0])
    st.paint(m & ~shift(m, side, 1), GREY[1])
    st.paint(m & (((CX - x) * side) < 1.2) & ~shift(m & (((CX - x) * side) < 1.2), 0, -1), GREY[2])
    for k in (2, 4):
        st.paint(line([(x + side * k, y - 1), (x + side * k, y + 5)]) & shrink(m, 1), GREY[3])
    return m


def rock_cap(st, body, y):
    """The monolith's red rock top (as in the picture): body above row y + a wobble goes rock red, a light rim, rib streaks below."""
    wave = y + 0.8 * np.sin(XX * 0.55)
    m = body & (CY < wave)
    st.paint(m, REDROCK[0])
    st.paint(m & ~shift(m, 0, 1) | m & ~shift(m, 0, -1) & (CY > y - 3), REDROCK[2])
    st.paint(m & ~shift(m, 0, -1), REDROCK[1])
    return m


def cave_hollow(st, cx, by, w=5, h=6):
    m = ellipse(cx, by, w, h) & (CY < by)
    st.paint(m, CAVE)
    st.paint(m & ~shift(m, 1, 1) & (CY < by - 1), '#5a1e26')
    st.dots([(int(cx) - 2, int(by) - 3), (int(cx) + 1, int(by) - 3)], '#f5cf6a')     # two tiny shy eyes in the dark
    return m


def dilly_bag(st, x, y):
    """A little woven dilly bag on a strap: a rounded pouch with cream dot weave."""
    m = ellipse(x, y, 3.4, 4.0)
    st.part(m, BAG[0], d=1, contour=True)
    st.paint(m & ((XX + YY) % 3 == 0) & shrink(m, 1), '#f2e4c0')
    return m


# ------------------------------------------------------------------ 1. Dotted Trail: corner-BB round, common. Dawn peach, a songline of dots, a twig brush, cheeky wink.
def dotted_trail():
    key = 'pl-rrs-1'
    st = Sticker()
    core = (14, 15, 48, 49)
    body, holes = piece_blanks(core, e=('B', 'round', -3, 2.6), s=('B', 'round', -2, 2.6))
    st.part(body, tex=fill(key, body, 14, 15, 35, list(PEACH)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c26a3e', skip=grow(holes, 3))
    trail = [(17, 44), (20, 41), (24, 40), (28, 42), (32, 44), (36, 45), (40, 44), (43, 41), (45, 37), (44, 33), (45, 29)]
    dot_trail(st, trail, shrink(body, 1))
    twig_brush(st, 15, 38, 9, 43)
    st.eye(19, 24, look=(1, 0))
    wink(st, 32, 25)
    st.paint(line([(31, 21), (35, 20)]), UMBER)                               # one brow up
    st.sprite(['U.....U', '.UUUUU.', '..URU..'], 22, 33, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(17, 31, 18, 31) | rect(35, 31, 36, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Galah Chatter: edge-TTB peg, common. Galah pink, grey wings, crest, chattering beak.
def galah_chatter():
    key = 'pl-rrs-2'
    st = Sticker()
    core = (15, 22, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 7, 3.2), e=('T', 'peg', 4, 3.0), w=('B', 'peg', 5, 2.8))
    crest(st, 23, 24)
    st.part(body, tex=fill(key, body, 15, 22, 30, list(PINK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY < 40), col='#fbd0dc', skip=grow(holes, 3))
    wings = body & (CY > 44 + 1.2 * np.abs(np.sin((XX - 15) * 0.42)))                 # grey galah wings folded round its lower half
    st.paint(wings, GREY[0])
    st.paint(wings & ~shift(wings, 0, -1), GREY[2])
    st.paint(wings & ((XX - 15) % 7 == 0) & (YY > 46), GREY[1])
    st.paint(wings & ~shift(wings, -2, -2), GREY[1])
    bead_eye(st, 22, 30)
    bead_eye(st, 35, 30)
    beak = poly([(26, 34), (33, 34), (31, 39), (28, 39)])
    st.part(beak, BEAK[0], d=1, contour=True)
    st.paint(rect(28, 37, 31, 38), MOUTH_RED)                                  # beak open mid-gossip
    st.paint(rect(28, 39, 30, 40), BEAK[1])
    for x, y in ((50, 15), (53, 12), (56, 9)):                                # chatter dots flying off
        st.paint(rect(x, y, x + 1, y + 1), CREAM)
        st.extra[y:y + 2, x:x + 2] = True
    return key, st


# ------------------------------------------------------------------ 3. Hummed Note: inner-TBTB tri, common. Note gold, an umber quaver on its head, blissful humming.
def hummed_note():
    key = 'pl-rrs-3'
    st = Sticker()
    core = (15, 23, 46, 47)
    body, holes = piece_blanks(core, n=('T', 'tri', -6, 3.2), e=('B', 'tri', 4, 2.6), s=('T', 'tri', 0, 3.2), w=('B', 'tri', 4, 2.6))
    st.part(body, tex=fill(key, body, 15, 23, 32, list(NOTEG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fff1c8', skip=grow(holes, 3))
    quaver(st, 31, 20)
    arc_eye(st, 20, 31, up=True)
    arc_eye(st, 33, 31, up=True)
    st.paint(rect(19, 35, 21, 35) | rect(36, 35, 38, 35), BLUSH)
    st.sprite(['.UU.', 'URRU', '.UU.'], 27, 36, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    hum_wave(st, 52, 18)
    hum_wave(st, 55, 24, 4)
    return key, st


# ------------------------------------------------------------------ 4. Dotcircle Painting: inner-TTTT double, uncommon. Red rock rust, dot rings on its belly, smug.
def dotcircle_painting():
    key = 'pl-rrs-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.2), e=('T', 'double', 0, 3.2), s=('T', 'double', 0, 3.2), w=('T', 'double', 0, 3.2))
    flat = np.zeros((N, N, 3), np.uint8)
    flat[:] = hx(RUST[0])                                                     # the cell's cream dots would read as a nose: keep it flat
    st.part(body, tex=flat, contour=True)
    st.stitch(body, col='#f5cf6a')                                             # uncommon accent: the dot-gold
    belly = disc(32, 37, 8.2)
    st.paint(belly, '#e07a52')
    st.paint(belly & ~shift(belly, -1, -1), '#b8452f')
    dot_rings(st, 32, 37)
    st.eye(22, 22, lid=2, socket=None)                                         # no socket: two sockets framed a 'nose' between them
    st.eye(36, 22, lid=2, socket=None)
    st.sprite(['.....U', 'UUUUU.'], 29, 28, {'U': UMBER}, solid=False)
    st.dots([(28, 28)], UMBER)
    return key, st


# ------------------------------------------------------------------ 5. Monolith Hidey: inner-TTBB round, uncommon. Monolith maroon, red rock cap, cave hollow, sun peeking, shy.
def monolith_hidey():
    key = 'pl-rrs-5'
    st = Sticker()
    sun = disc(49, 15, 6.5)
    st.part(sun, SUN[0], d=1, contour=False)
    st.paint(sun & ~shift(sun, 1, 1), SUN[1])
    core = (12, 20, 46, 49)
    body, holes = piece_blanks(core, n=('T', 'round', -6, 3.2), e=('T', 'round', 3, 3.2), s=('B', 'round', -6, 2.8), w=('B', 'round', -2, 2.8))
    st.part(body, tex=fill(key, body, 12, 20, 35, list(MAROON)), contour=True)
    st.blank_shade(body, holes, width=1)
    rock_cap(st, body, 25)
    for x in (16, 43):
        st.paint(rect(x, 29, x, 36) & body, '#5e1e28')                         # rock ribs
    st.stitch(body & (YY > 26), col='#e0a070', skip=grow(holes, 3))
    cave_hollow(st, 38, 49)
    tuft = ellipse(21, 14, 3.4, 2.4) | ellipse(25, 13, 2.6, 2.2)
    st.part(tuft, BUSH[0], d=1, contour=True)                                  # uncommon accent: a desert bush tuft on its tab
    st.paint(tuft & ~shift(tuft, 1, 1), BUSH[2])
    st.eye(20, 30, look=(-1, 1))
    st.eye(32, 30, look=(-1, 1))
    st.paint(rect(17, 37, 19, 37) | rect(37, 37, 39, 37), BLUSH)
    st.sprite(['.U.U', 'U.U.'], 26, 38, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Songline Kangaroo: whimsy-kangaroo tri, rare. A kangaroo-cut piece pointing along the song.
def songline_kangaroo():
    key = 'pl-rrs-6'
    st = Sticker()
    head = ellipse(27, 25, 8.5, 7.0)
    ears = poly([(19.5, 21), (20, 10), (24.5, 18)]) | poly([(30, 18), (34, 9.5), (35.5, 21)]) | disc(20.5, 11, 1.8) | disc(33.8, 11, 1.8)
    torso = ellipse(28, 41, 10, 10)
    feet = ellipse(24, 52, 8, 2.6) | ellipse(34, 52, 6.5, 2.6)
    tail = line([(20, 46), (15, 50), (11, 52)], 5) | disc(11.5, 52, 2.4)
    arm = line([(36, 35), (44, 32), (48, 31)], 4)
    paw = disc(48.5, 31, 2.4)
    tab = knob('w', 'tri', 38, 19.2, r=2.6)
    body = head | ears | torso | feet | tail | arm | paw | tab
    t = cell_fill(pic, ROWS[key]['piece'], body, 9, 8, 44, 3, 3)
    st.part(body, tex=calm_tones(t, body, list(TAN)), contour=True)
    belly = ellipse(28.5, 43.5, 5.6, 6.5)
    st.paint(belly, '#f2e4c0')
    st.paint(belly & ~shift(belly, -1, -1), '#d8c6a0')
    st.paint(ellipse(21.5, 15, 1.2, 3.2) | ellipse(33.5, 14.5, 1.2, 3.2), '#f0b8a8')   # inner ears
    st.paint(line([(24, 52), (30, 52)]) | line([(36, 52), (40, 52)]), '#a8703a')   # toe lines
    st.stitch(torso & ~belly, col='#fbe8b8')
    st.paint(line([(33, 33), (38, 42)]), '#a3402b')                              # dilly-bag strap
    dilly_bag(st, 39, 45)
    muzzle = ellipse(28, 29, 4.0, 2.6)
    st.paint(muzzle, '#ecc890')
    st.paint(rect(27, 27, 29, 28), UMBER)                                        # nose
    roo_eye(st, 21, 21)
    roo_eye(st, 31, 21)
    st.sprite(['U...U', '.URU.'], 26, 30, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(19, 28, 20, 28) | rect(36, 28, 37, 28), BLUSH)
    nm = ellipse(55.5, 24, 2.2, 1.7) | rect(57, 15, 57, 24) | line([(57, 15), (59, 17), (59, 19)])   # the gold song note it points at
    st.paint(nm, '#f5cf6a')
    st.extra |= nm
    st.sparkle(5, 6)
    st.sparkle(47, 6, big=False)
    st.sparkle(52, 46, big=False)
    return key, st


PALS = [dotted_trail, galah_chatter, hummed_note, dotcircle_painting, monolith_hidey, songline_kangaroo]

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
        print('%-10s %-19s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
