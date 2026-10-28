"""Puzzle Pals: FORGE OF THE CINDER WYRM (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-cwy-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_cwy.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
First lair place, built from kit_lair (the shared lair parts). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-forge-of-the-cinder-wyrm.png, calmed onto 2 tones so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual). Each pal has its own body tone family, its own accessory, silhouette detail and face:
  1 Ember Flake      charcoal cinder + glowing crack veins | striped red/cream scarf, flame lick crest | sleepy, content :3, nub feet
  2 Slag Drip        molten gold                           | iron ladle worn as a hat, 3 slow drips     | smug side-eye, smirk
  3 Scorch Sliver    crimson wyrm red                      | one curled horn, a thin smoke strand       | grumpy brows, pout + fang
  4 Spine Spark      forge-sky violet                      | orange spine crown, a lit sparkler          | startled, wide eyes up, o
  5 Ash Wreath       pale cool ash                         | an unlit matchstick on its head, boots      | shy, blush, looks away
  6 Last Forge Flame orange flame, gold heart (rare)       | tiny violet wyrm wings, curled tip, zzz    | fast asleep, closed arcs
Hook blanks are kept small (r 3) so they read as notches, not dark swirls; no ash puffs (they read as rocks); the rare has no side licks.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-forge-of-the-cinder-wyrm'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-forge-of-the-cinder-wyrm-db3da4')

RED, RED_D = '#d6322b', '#b12d22'
LAVA_O, LAVA_R, LAVA_L = '#f08a24', '#e0501f', '#f5b840'
CINDER = ('#5e4c58', '#72606a')                       # charcoal cinder, lifted so it is not mud on a dark page
SLAG = ('#e8a317', '#f5b840')
VIOLET = ('#7e4470', '#9a5a8a')                       # the picture's purple forge sky
ASHC = ('#a2a4b8', '#bec0d0')                         # cool pale ash
IRON = ('#8b8f96', '#5b6470', '#c3c8cc', '#3c4250')
WING = ('#8c4a78', '#5e2c56', '#b07aa4', '#3a1e2a')
SMOKE = '#c8bcd4'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def brows(st, l, r, col=UMBER):
    st.paint(line(l) | line(r), col)
    st.paint(line(l) | line(r), col)


def scarf(st, x0, x1, y, tail_x):
    """A knitted scarf band (3 rows) across the body with a fringed tail hanging on the left: red with cream stripes."""
    band = rect(x0, y, x1, y + 3)
    tail = rect(tail_x, y + 3, tail_x + 3, y + 10)
    m = band | tail
    st.part(m, '#c8402e', d=1, contour=True)
    st.paint(m & ((XX + YY) % 4 == 0) & shrink(m, 0), '#f2e4c0')
    st.paint(rect(tail_x, y + 11, tail_x + 3, y + 11) & (XX % 2 == 0), '#f2e4c0', solid=True)
    return m


def crack_veins(st, mask, paths, avoid):
    v = blank()
    for p in paths:
        v |= line(p)
    v &= shrink(mask, 2) & ~avoid
    st.paint(dil4(v) & shrink(mask, 1) & ~avoid & ~v, LAVA_R)
    st.paint(v, LAVA_O)
    st.paint(v & (((XX + YY) % 3) == 0), LAVA_L)
    return v


def ladle_hat(st, cx, y, w=6, hx_=13, hy=-7):
    dome = ellipse(cx, y, w, 4.2) & (CY < y + 0.5)
    rim = rect(int(cx - w - 1), int(y), int(cx + w), int(y) + 1)
    handle = line([(cx + 2, y - 2), (cx + hx_, y + hy)], w=2)
    st.part(handle, IRON[0], d=1, contour=True)
    st.paint(rect(int(cx + hx_) - 1, int(y + hy) - 1, int(cx + hx_), int(y + hy)), IRON[1], solid=True)
    m = dome | rim
    st.part(m, IRON[0], d=1, contour=True)
    st.paint(rim, IRON[1])
    st.paint(dome & ~shift(dome, 1, 1) & shrink(dome, 0) & (CY < y - 1), IRON[2])
    st.paint(rect(int(cx - w), int(y) + 1, int(cx - w) + 1, int(y) + 2), SLAG[1], solid=True)   # a gold drip off its brim
    return m | handle


def plaster(st, x, y):
    """A sticking plaster stuck on at an angle: cream strip, a darker pad, two dot holes."""
    st.sprite(['...UU.', '..UPPU', '.UPDDU', 'UPDDPU', 'UPPU..', '.UU...'], x, y, {'P': '#fff3c8', 'D': '#e0c080', 'U': UMBER}, solid=False)


def sparkler(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=1) | line([(x0 + 1, y0), (x1 + 1, y1)], w=1)
    st.part(m, IRON[0], d=0, contour=True)
    st.paint(rect(x1, y1, x1 + 1, y1 + 3) & m, '#6b3e26')
    st.sparkle(x1 - 2, y1 - 6, big=True)
    st.dots([(x1 - 4, y1 - 2), (x1 + 4, y1 - 4)], GOLD)
    st.extra[y1 - 2, x1 - 4] = st.extra[y1 - 4, x1 + 4] = True
    return m


def matchstick(st, x0, y0, x1, y1):
    stick = line([(x0, y0), (x1, y1)], w=2)
    st.part(stick, '#e0c080', d=1, contour=True)
    head = ellipse(x1 + 0.5, y1 - 0.5, 2.3, 2.6)
    st.part(head, '#c8402e', d=1, contour=True)
    st.paint(head & disc(x1 - 0.3, y1 - 1.4, 1.0), '#f2795a')
    return stick | head


def closed_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)
    st.dots([(x, y - 1)], UMBER)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Ember Flake: corner-BB hook, common. Charcoal cinder with glowing cracks, a striped scarf (it stayed warm).
def ember_flake():
    key = 'pl-cwy-1'
    st = Sticker()
    core = (11, 21, 44, 48)
    flame(st, 16, 23, w=7, h=10, lean=-0.6, pal=LAVA, licks=0)       # the flame lick it still carries, as a crest
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'hook', 7, 3.0), e=('B', 'hook', 6, 3.0))
    st.part(body, tex=fill(key, body, 11, 21, 34, list(CINDER)), contour=True)
    st.blank_shade(body, holes, width=1)
    face = rect(14, 24, 38, 38)
    crack_veins(st, body, [[(40, 23), (37, 29), (42, 33)], [(13, 41), (18, 44), (22, 42), (27, 46)], [(33, 45), (38, 41), (43, 45)],
                           [(22, 22), (26, 25), (31, 23)]], face | grow(holes, 2))
    scarf(st, 11, 44, 37, 13)
    nub_feet(st, [17, 34], 49, '#3e2c38')
    st.eye(17, 27, look=(0, 1), lid=2)
    st.eye(29, 27, look=(0, 1), lid=2)
    st.mouth('cat', 23, 34)
    return key, st


# ------------------------------------------------------------------ 2. Slag Drip: edge-TBB tri, common. Molten gold, an iron ladle worn as a hat, three slow drips for feet.
def slag_drip():
    key = 'pl-cwy-2'
    st = Sticker()
    core = (13, 24, 44, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 4.0), e=('B', 'tri', 3, 3.4), w=('B', 'tri', 3, 3.4))
    drips = blank()
    for x, h, r in ((18, 2, 2.2), (28, 4, 2.6), (39, 1, 2.0)):
        drips |= rect(int(x - r + 1), 49, int(x + r - 1), 49 + h) | disc(x + 0.5, 49 + h + 0.5, r)
    body |= drips
    st.part(body, tex=fill(key, body, 13, 24, 32, list(SLAG), dy=0.1))
    st.blank_shade(body, holes, width=1)
    st.paint(drips & ~shift(drips, 1, 0) & (YY > 50), '#fbe0a8')
    st.stitch(body & (CY < 49.5), col='#b07a10', skip=grow(holes, 3))
    ladle_hat(st, 29, 18, w=6)
    # smug: lazy lids, eyes sliding to the side, one brow up
    st.eye(18, 31, look=(1, 0), lid=2)
    st.eye(31, 31, look=(1, 0), lid=2)
    st.paint(line([(31, 27), (34, 26), (36, 27)]), UMBER)
    st.mouth('smirk', 25, 40)
    return key, st


# ------------------------------------------------------------------ 3. Scorch Sliver: inner-TBBB peg, common. Crimson, one curled horn, a thin strand of smoke, grumpy.
def scorch_sliver():
    key = 'pl-cwy-3'
    st = Sticker()
    core = (13, 23, 44, 50)
    body, holes = piece_blanks(core, n=('T', 'peg', -4), e=('B', 'peg', 2, 3.4), s=('B', 'peg', 0, 3.2), w=('B', 'peg', 2, 3.4))
    horn(st, 39, 24, h=9, lean=1.2, w=6, pal=BONE)
    st.part(body, tex=fill(key, body, 13, 23, 32, [RED_D, RED]), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, col=LAVA_O, skip=grow(holes, 3))
    st.paint(ellipse(19, 26, 3, 1.5) & body, '#8a2a28')                  # a scorch mark
    plaster(st, 37, 36)                                                  # it got scorched; it is not happy about it
    claw_feet(st, [16, 35], 51, w=6, h=3)
    st.eye(18, 31, look=(0, 0), lid=1)
    st.eye(31, 31, look=(0, 0), lid=1)
    brows(st, [(17, 27), (22, 29)], [(31, 29), (36, 27)])
    st.paint(line([(17, 28), (22, 30)]) | line([(31, 30), (36, 28)]), UMBER)
    st.sprite(['.UUU.', 'U...U'], 24, 40, {'U': UMBER}, solid=False)
    st.sprite(['C', 'C'], 26, 41, {'C': CREAM}, solid=False)
    return key, st


# ------------------------------------------------------------------ 4. Spine Spark: inner-TTTT double, uncommon. Forge-sky violet, orange spine crown, a lit sparkler, startled.
def spine_spark():
    key = 'pl-cwy-4'
    st = Sticker()
    core = (17, 24, 45, 48)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    spike_crown(st, 19, 43, 23, n=4, h=6, pal=('#f08a24', '#e0501f', '#f5cf6a', '#b12d22'), tip='#fff3c8')
    st.part(body, tex=fill(key, body, 17, 24, 29, list(VIOLET)), contour=True)
    st.stitch(body, col=LAVA_L)                                      # uncommon accent: the spines' gold
    sparkler(st, 51, 40, 55, 21)
    st.eye(21, 30, look=(0, -1))
    st.eye(34, 30, look=(0, -1))
    st.paint(line([(21, 27), (25, 27)]) | line([(34, 27), (38, 27)]), UMBER)
    st.mouth('o', 29, 39)
    sparks(st, [(9, 14)], big=False)
    st.dots([(14, 19)], GOLD_L)
    st.extra[19, 14] = True
    return key, st


# ------------------------------------------------------------------ 5. Ash Wreath: inner-BBBB hook, uncommon. Pale cool ash, an unlit matchstick it hopes someone lights, shy.
def ash_wreath():
    key = 'pl-cwy-5'
    st = Sticker()
    core = (12, 21, 49, 50)
    body, holes = piece_blanks(core, n=('B', 'hook', -7, 2.6), e=('B', 'hook', 7, 2.6), s=('B', 'hook', 0, 2.6), w=('B', 'hook', 7, 2.6))
    st.part(body, tex=fill(key, body, 12, 21, 38, list(ASHC)))
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LAVA_O, skip=grow(holes, 3))                 # uncommon accent: the ember orange it misses
    matchstick(st, 38, 22, 42, 9)
    st.part(rect(15, 51, 21, 54) & ~rect(15, 51, 15, 51) & ~rect(21, 51, 21, 51), SHOE[0], d=1, contour=True)
    st.part(rect(39, 51, 45, 54) & ~rect(39, 51, 39, 51) & ~rect(45, 51, 45, 51), SHOE[0], d=1, contour=True)
    st.eye(20, 30, look=(-1, 1))
    st.eye(34, 30, look=(-1, 1))
    st.paint(rect(18, 37, 20, 37) | rect(37, 37, 39, 37), BLUSH)
    st.sprite(['U..U', '.UU.'], 27, 38, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Last Forge Flame: whimsy-flame tri, rare. An orange flame curled asleep, tiny violet wyrm wings, zzz.
def last_forge_flame():
    key = 'pl-cwy-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    fl = flame_mask(31, 52, 27, 40, lean=0.75, licks=1)
    tab = knob('w', 'tri', 42, 18.6, r=3.2)
    body = fl | tab
    bat_wing(st, 42, 44, L=7, side=1, pal=WING)
    bat_wing(st, 20, 40, L=7, side=-1, pal=WING)
    src = pic.sample(col, row, 17, 12, 30).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(LAVA_O)
    tex[src > 330] = hx('#f29a34')
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    st.paint(body & ~shrink(body, 2) & (CY > 24) & ~shift(body, 2, 2), LAVA_R)
    heart = flame_mask(31, 51, 16, 15, lean=0.3, licks=0) & shrink(body, 3)
    st.paint(heart, LAVA_L)
    st.paint(heart & ~shift(heart, 0, 2), '#fbe0a8')
    st.stitch(fl, col='#fff3c8')
    closed_eye(st, 23, 36)
    closed_eye(st, 34, 36)
    st.paint(rect(22, 39, 23, 39) | rect(39, 39, 40, 39), BLUSH)
    st.sprite(['U.U', '.U.'], 30, 41, {'U': UMBER}, solid=False)
    zzz(st, 50, 21)
    st.sparkle(9, 9)
    st.sparkle(53, 6, big=False)
    st.sparkle(8, 47, big=False)
    return key, st


PALS = [ember_flake, slag_drip, scorch_sliver, spine_spark, ash_wreath, last_forge_flame]

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
