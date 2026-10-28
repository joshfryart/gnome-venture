"""Puzzle Pals: SNOWCROWN PEAK (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-snw-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_snw.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built on palib + kit_lair (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-snowcrown-peak.png, calmed onto 2 tones so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual). Each pal has its own body tone, accessory, silhouette detail, face and pose:
  1 Frost Nibble      icy pale blue          | pink earmuffs, icicle fringe underneath      | cheeky wink, buck tooth
  2 Acacia Sprig      savanna green          | flat-top acacia tree on its head, pointing arm | smug side-eye toward the peak, smirk
  3 Snowmelt Trickle  aqua meltwater teal    | falling droplets, ripple lines, tilted lean   | giggling closed ^^ eyes, open grin, blush
  4 Snowcrown Peaks   mountain mauve         | drippy snow cap + red summit flag             | grumpy brows, flat mouth
  5 Lion Paw Pair     lion tan               | two big paws (one waving), pink toe beans     | shy, looks down, blush, tiny smile
  6 Snowpeak Cub      russet mane (rare)     | lion head: scalloped mane, round ears, snow tuft | sleepy, muzzle + nose, :3
Hook knobs kept small (r 3) so they read as notches, not dark swirls; no puffs (read as rocks); the rare has no side parts.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-snowcrown-peak'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-snowcrown-peak-52d64c')

ICE = ('#93c6e2', '#b8dcee')
SAVANNA = ('#5f8f34', '#7aa848')
MELT = ('#3e95a6', '#58b4bc')
MAUVE = ('#7c6c84', '#978aa0')
TAN = ('#c39a5e', '#d6b27a')
RUSSET = ('#b0502a', '#c8682e')
SNOW, SNOW_S = '#eef0f8', '#c8d2e6'
LAV = '#6150b3'
PINK, PINK_D = '#e8889a', '#c0607a'
BLUSH = '#f0a0a0'
BARK = '#7a4a2a'
CANOPY = ('#3f6a2a', '#2c4e1e', '#6a9a3a', '#1f3a16')
PAW = ('#b37e46', '#8a5a30', '#d6a868', '#5c3a20')


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def happy_eye(st, x, y):
    """Closed laughing eye: an upside-down arc (^), 5 wide."""
    st.sprite(['.UUU.', 'U...U', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def sleepy_eye(st, x, y):
    st.sprite(['UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)
    st.dots([(x - 1, y - 1)], UMBER)


def icicles(st, specs, y):
    m = blank()
    for x, h in specs:
        m |= rect(x - 1, y, x + 1, y + h - 1) | disc(x + 0.5, y + h - 0.5, 1.6) | rect(x - 2, y, x + 2, y + 1)
    st.part(m, '#cfe8f4', d=1, contour=True)
    st.paint(m & (CX < XX.astype(float) + 0.6) & ~shift(m, 1, 0), '#fbfdff')
    return m


def earmuffs(st, l, r, y, band_top):
    band = line([(l[0], y), (l[0] + 3, band_top + 2), (r[0] - 3, band_top + 2), (r[0], y)], w=2)
    st.part(band, '#8b8f96', d=0, contour=True)
    for cx in (l[0], r[0]):
        mf = disc(cx, y + 1, 4.3)
        st.part(mf, PINK, d=1, contour=True)
        st.paint(mf & disc(cx - 1.2, y - 0.4, 1.4), '#f8c0cc')
    return band


def acacia(st, cx, ty, by):
    trunk = rect(cx, ty, cx + 1, by) | line([(cx + 1, ty + 3), (cx + 5, ty)]) | line([(cx, ty + 2), (cx - 4, ty)])
    st.part(trunk, BARK, d=0, contour=True)
    can = ellipse(cx + 0.5, ty - 2.5, 12.5, 3.2) & (CY < ty + 0.5)
    st.part(can, CANOPY[0], d=1, contour=True)
    st.paint(can & ~shift(can, 0, 1), CANOPY[2])
    st.paint(can & ((XX * 3 + YY) % 7 == 0) & shrink(can, 1), CANOPY[2])
    return can | trunk


def pointer_arm(st, x, y, L, col):
    arm = rect(x, y, x + L, y + 3)
    tip = poly([(x + L, y - 2), (x + L + 5, y + 1.5), (x + L, y + 5)])
    m = arm | tip
    st.part(m, col, d=1, contour=True)
    return m


def droplet(st, cx, cy, r, col='#8fd6e0'):
    m = disc(cx, cy, r) | poly([(cx - r * 0.7, cy - r * 0.5), (cx + 0.5, cy - r * 2.1), (cx + r * 0.7 + 1, cy - r * 0.5)])
    st.part(m, col, d=1, contour=True)
    st.dots([(int(cx - r * 0.4), int(cy - r * 0.3))], '#eef8fc')
    return m


def snowcap(st, body, ybase):
    """Snow over the top of the body: a wavy drip edge, white with a cool shade."""
    edge = ybase + 2.0 * np.sin(XX * 0.9) + 1.2 * (XX % 5 == 0)
    m = body & (CY < edge)
    st.paint(m, SNOW)
    st.paint(m & ~shift(m, 0, -1), SNOW_S)
    return m


def flag(st, x, y, h=11):
    pole = rect(x, y, x, y + h)
    st.part(pole, '#8b8f96', d=0, contour=True)
    fl = poly([(x + 1, y), (x + 8, y + 2.5), (x + 1, y + 5)])
    st.part(fl, '#d6322b', d=1, contour=True)
    st.paint(rect(x, y - 1, x, y - 1), GOLD, solid=True)
    return pole | fl


def paw(st, cx, cy, r, beans=True):
    m = ellipse(cx, cy, r, r * 0.9)
    toes = blank()
    for k in (-1, 0, 1):
        toes |= disc(cx + k * r * 0.62, cy - r * 0.85, r * 0.38)
    m |= toes
    st.part(m, PAW[0], d=1, contour=True)
    st.paint(toes & ~shift(toes, 0, 1), PAW[2])
    if beans:
        st.paint(ellipse(cx, cy + 0.6, r * 0.45, r * 0.32), '#f0a0b0')
        for k in (-1, 0, 1):
            st.paint(disc(cx + k * r * 0.62, cy - r * 0.85, 0.9), '#f0a0b0')
    return m


def wave_lines(st, pts):
    m = blank()
    for p in pts:
        m |= line(p)
    st.paint(m, CREAM, solid=True)


# ------------------------------------------------------------------ 1. Frost Nibble: corner-BB hook, common. Icy blue, pink earmuffs, an icicle fringe, a cheeky wink.
def frost_nibble():
    key = 'pl-snw-1'
    st = Sticker()
    core = (12, 21, 46, 45)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'hook', 6, 3.0), e=('B', 'hook', 5, 3.0))
    st.part(body, tex=fill(key, body, 12, 21, 35, list(ICE)), contour=True)
    st.blank_shade(body, holes, width=1)
    icicles(st, [(19, 4), (31, 6), (39, 3)], 46)
    st.stitch(body, col='#fff3c8', skip=grow(holes, 3))
    earmuffs(st, (12, 0), (46, 0), 27, 15)
    wink(st, 19, 30)
    st.eye(31, 29, look=(-1, -1))
    st.paint(rect(31, 27, 35, 27), UMBER)
    st.paint(rect(18, 36, 20, 36) | rect(37, 36, 39, 36), BLUSH)
    st.mouth('tooth', 25, 37)
    return key, st


# ------------------------------------------------------------------ 2. Acacia Sprig: edge-BTB peg, common. Savanna green, a flat-top acacia on its head, points at the peak.
def acacia_sprig():
    key = 'pl-snw-2'
    st = Sticker()
    core = (13, 27, 42, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -3, 3.6), e=('B', 'peg', 3, 3.2), w=('B', 'peg', 3, 3.2))
    acacia(st, 25, 15, 19)
    st.part(body, tex=fill(key, body, 13, 27, 30, list(SAVANNA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e8d890', skip=grow(holes, 3))
    pointer_arm(st, 40, 30, 7, SAVANNA[0])
    claw_feet(st, [16, 33], 51, w=6, h=3, pal=('#6a4a2a', '#4a2c1a', '#8a6a3a', '#2a1a10'))
    st.eye(17, 33, look=(1, 0), lid=2)
    st.eye(29, 33, look=(1, 0), lid=2)
    st.paint(line([(29, 30), (32, 29), (34, 30)]), UMBER)
    st.mouth('smirk', 23, 42)
    return key, st


# ------------------------------------------------------------------ 3. Snowmelt Trickle: inner-TBTB tri, common. Aqua meltwater, leaning, falling droplets, giggling.
def snowmelt_trickle():
    key = 'pl-snw-3'
    st = Sticker()
    core = (14, 21, 41, 44)
    body, holes = piece_blanks(core, n=('T', 'tri', 3, 3.6), e=('B', 'tri', -2, 3.2), s=('T', 'tri', -3, 3.4), w=('B', 'tri', 2, 3.2))
    st.part(body, tex=fill(key, body, 14, 21, 28, list(MELT)), contour=True)
    st.blank_shade(body, holes, width=1)
    rip = (line([(17, 39), (20, 38), (23, 39), (26, 38)]) | line([(29, 41), (32, 40), (35, 41), (38, 40)])) & shrink(body, 2)
    st.paint(rip, '#a6e0e4')
    st.stitch(body, col='#d8f4f4', skip=grow(holes, 3))
    droplet(st, 47, 50, 2.4)
    droplet(st, 52, 40, 1.8)
    droplet(st, 13, 54, 1.8)
    happy_eye(st, 17, 27)
    happy_eye(st, 30, 27)
    st.paint(rect(16, 32, 18, 32) | rect(35, 32, 37, 32), BLUSH)
    st.mouth('grin', 24, 32)
    return key, st


# ------------------------------------------------------------------ 4. Snowcrown Peaks: inner-TTTT double, uncommon. Mountain mauve under a drippy snow cap, a red summit flag, grumpy.
def snowcrown_peaks():
    key = 'pl-snw-4'
    st = Sticker()
    core = (17, 25, 45, 48)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 2), s=('T', 'double'), w=('T', 'double', 2))
    flag(st, 34, 9, h=10)
    st.part(body, tex=fill(key, body, 17, 25, 29, list(MAUVE)), contour=True)
    snowcap(st, body, 30)
    st.stitch(body & (CY > 30), col=LAV)                          # uncommon accent: the peak's lavender ridge
    st.eye(21, 32, look=(0, 0), lid=1)
    st.eye(34, 32, look=(0, 0), lid=1)
    st.paint(line([(20, 29), (25, 31)]) | line([(34, 31), (39, 29)]), UMBER)
    st.paint(rect(28, 42, 32, 42), UMBER)
    st.paint(rect(28, 43, 32, 43) & (XX % 2 == 0), UMBER2)
    return key, st


# ------------------------------------------------------------------ 5. Lion Paw Pair: inner-TTBB hook, uncommon. Lion tan, two big soft paws (one waving), shy.
def lion_paw_pair():
    key = 'pl-snw-5'
    st = Sticker()
    core = (15, 22, 44, 47)
    body, holes = piece_blanks(core, n=('T', 'hook', 4, 2.8), e=('T', 'hook', 0, 2.8), s=('B', 'hook', 7, 2.5), w=('B', 'hook', 7, 2.5))
    st.part(body, tex=fill(key, body, 15, 22, 30, list(TAN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=PINK_D, skip=grow(holes, 3))              # uncommon accent: toe-bean pink
    paw(st, 14, 20, 4.8)
    wave_lines(st, [[(7, 10), (9, 12)], [(12, 8), (13, 11)], [(7, 16), (8, 17)]])
    paw(st, 47, 49, 5.0)
    st.eye(20, 27, look=(-1, 1))
    st.eye(32, 27, look=(-1, 1))
    st.paint(rect(18, 34, 20, 34) | rect(36, 34, 38, 34), BLUSH)
    st.sprite(['U..U', '.UU.'], 26, 35, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Snowpeak Cub: whimsy-lion peg, rare. A lion cub head: scalloped russet mane, snow tuft, sleepy.
def snowpeak_cub():
    key = 'pl-snw-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    cx, cy = 32, 31
    mane = disc(cx, cy, 14.5)
    for k in range(12):
        a = math.radians(k * 30 + 15)
        mane |= disc(cx + 14 * math.cos(a), cy + 13.5 * math.sin(a), 4.6)
    tab = knob('s', 'peg', cx, cy + 15, r=2.4)
    ears = disc(cx - 11, cy - 15, 4.4) | disc(cx + 11, cy - 15, 4.4)
    body = mane | tab
    st.part(ears, TAN[1], d=1, contour=True)
    st.paint(disc(cx - 11, cy - 15.5, 2.0) | disc(cx + 11, cy - 15.5, 2.0), '#e8a0a0')
    st.part(body, tex=fill(key, body, 12, 13, 40, list(RUSSET)), contour=True)
    locks = blank()
    for k in range(12):
        a = math.radians(k * 30)
        locks |= line([(cx + 11 * math.cos(a), cy + 10.5 * math.sin(a)), (cx + 17 * math.cos(a), cy + 16 * math.sin(a))])
    st.paint(locks & shrink(body, 1), '#8a3a22')
    tuft = disc(cx, cy - 15, 3.4) | disc(cx - 3.5, cy - 14, 2.6) | disc(cx + 3.6, cy - 14, 2.6)
    st.paint(tuft & body, SNOW)
    st.paint(tuft & body & ~shift(tuft, 0, -1), SNOW_S)
    face = ellipse(cx, cy + 1, 11, 10)
    st.part(face, TAN[1], d=2, contour=True)
    st.stitch(body & ~grow(face, 1), col='#fff3c8', depth=2)
    muz = ellipse(cx - 2.5, cy + 6, 3.4, 2.6) | ellipse(cx + 2.5, cy + 6, 3.4, 2.6)
    st.paint(muz, '#f4e2c0')
    st.sprite(['NNN', '.N.'], cx - 1, cy + 3, {'N': '#9a4a50'}, solid=False)
    st.sprite(['U.U.U', '.U.U.'], cx - 2, cy + 6, {'U': UMBER}, solid=False)
    sleepy_eye(st, cx - 8, cy - 1)
    sleepy_eye(st, cx + 4, cy - 1)
    st.paint(rect(cx - 9, cy + 3, cx - 7, cy + 3) | rect(cx + 7, cy + 3, cx + 9, cy + 3), BLUSH)
    st.sparkle(6, 8)
    st.sparkle(54, 10, big=False)
    st.sparkle(53, 52, big=False)
    return key, st


PALS = [frost_nibble, acacia_sprig, snowmelt_trickle, snowcrown_peaks, lion_paw_pair, snowpeak_cub]

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
