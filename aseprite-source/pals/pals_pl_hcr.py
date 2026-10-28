"""Puzzle Pals: LAIR OF THE HURRICANE CRAB (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-hcr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_hcr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-of-the-hurricane-crab.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Lightning Pinch    lit storm-cloud silver     | a yellow lightning-bolt crest + one snappy red pincer arm  | cheeky wink, tongue out
  2 Shell Splinter     sandy shell tan, orange ribs | a chipped corner, a tiny shell wind chime it holds up      | grumpy brows, frown
  3 Gust Ribbon        island leaf green          | a flag-yellow ribbon looping round it, a two-leaf sprout     | joyful ^ ^ eyes, open grin
  4 Whirl Pincer       crab-wine berry            | notched pincer tips on all 4 tri tabs, a pinwheel on a stick | startled, eyes up, o
  5 Eye of the Storm   deep sea blue + calm swirl | a lilac striped umbrella, yellow rain boots                  | serene, sleepy lids, tiny smile
  6 Gale Islander      crab red (rare)            | whimsy crab: raised claws, legs, an island with 2 palms + flag | shy stalk eyes, blush
Hook blanks kept small (r 2.6 to 3). No puffs. Browns lifted for dark pages.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-of-the-hurricane-crab'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-of-the-hurricane-crab-9f245a')

CLOUD = ('#9ca4b8', '#b8bfce')          # lit storm cloud
SHELLT = ('#c9a46e', '#dcbc88')         # sandy shell tan
LEAF = ('#5e9e48', '#7ab55c')           # island green
WINE = ('#86304e', '#a03e5c')           # crab-wine berry
SEA = ('#3f6488', '#4f7898')            # deep sea blue
CRAB = ('#c0412e', '#d65a3a', '#e8784a', '#8a2a28')
BOLT = ('#f5cf3a', '#e8a317', '#fff3a8', '#b07a10')
RIB = '#e0702e'
PALMG = ('#3f8a3a', '#2f6a2a', '#6ab04a', '#1f4a24')
TRUNK = ('#9a6a3a', '#74462a', '#c08a50', '#4a2c1a')
LILAC = ('#a888c8', '#7e64a4', '#d0b8e4', '#5a4880')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def bolt(st, x, y, s=1.0, pal=BOLT):
    """A chunky zigzag lightning bolt, top at (x, y), ~8 x 13 px at s=1."""
    pts = [(x + 3 * s, y), (x + 8 * s, y), (x + 5 * s, y + 5 * s), (x + 8 * s, y + 5 * s), (x + 1 * s, y + 13 * s),
           (x + 3 * s, y + 7 * s), (x, y + 7 * s)]
    m = poly(pts)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 0), pal[2])
    return m


def pincer(st, cx, cy, r=4.0, ang=-90.0, gape=0.55, pal=CRAB):
    """An open crab claw: a disc with a V bite out of it pointing at ang (degrees), a cream glint."""
    m = disc(cx, cy, r) | ellipse(cx, cy, r * 0.9, r * 1.1)
    a = math.radians(ang)
    dx, dy = math.cos(a), math.sin(a)
    px, py = -dy, dx
    L = r * 1.6
    bite = poly([(cx + dx * r * 0.05, cy + dy * r * 0.05), (cx + dx * L + px * L * gape, cy + dy * L + py * L * gape),
                 (cx + dx * L - px * L * gape, cy + dy * L - py * L * gape)])
    m &= ~bite
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & disc(cx - r * 0.4, cy - r * 0.1, 1.0), '#ffd8b8')
    return m


def wink(st, x, y):
    st.sprite(['.....', 'U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def tongue_grin(st, x, y):
    st.sprite(['U....U', '.UUUU.', '..RR..'], x, y, {'U': UMBER, 'R': '#e8706a'}, solid=False)


def chime(st, x, y):
    """A tiny shell wind chime: a driftwood bar with 3 threads and 3 shell bits of different lengths."""
    bar = rect(x, y, x + 9, y + 1)
    st.part(bar, TRUNK[0], d=1, contour=True)
    st.paint(rect(x, y, x + 9, y), TRUNK[2])
    for i, (dx, L, c) in enumerate(((1, 3, '#f2e4c0'), (4, 5, '#e8946a'), (8, 2, '#a9d6ea'))):
        st.paint(rect(x + dx, y + 2, x + dx, y + 1 + L), '#f2e4c0', solid=True)
        bit = rect(x + dx - 1, y + 2 + L, x + dx + 1, y + 3 + L)
        st.part(bit, c, d=1, contour=False)
    return bar


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'U...U', 'U...U'], x, y, {'U': UMBER}, solid=False)


def ribbon(st, pts, col=BOLT[0]):
    m = line(pts, w=2)
    st.part(m, col, d=1, contour=True)
    st.paint(line(pts, w=1) & m & ~shift(m, 0, -1), BOLT[2])
    return m


def pinwheel(st, cx, cy, r=5, stick_to=None):
    if stick_to:
        s = line([(cx, cy), stick_to], w=2)
        st.part(s, TRUNK[2], d=1, contour=True)
    m = blank()
    cols = ['#f2e4c0', '#4fb0c8', '#f5cf3a', '#e8706a']
    for k in range(4):
        a = math.radians(k * 90)
        b = math.radians(k * 90 + 90)
        tri = poly([(cx, cy), (cx + r * math.cos(a), cy + r * math.sin(a)), (cx + r * 0.7 * math.cos(b - 0.5), cy + r * 0.7 * math.sin(b - 0.5))])
        st.part(tri, cols[k], d=0, contour=True)
        m |= tri
    st.paint(rect(int(cx) - 1, int(cy) - 1, int(cx), int(cy)), UMBER, solid=True)
    return m


def umbrella(st, cx, y, w=10, h=6):
    dome = ellipse(cx, y + h, w, h) & (CY < y + h + 0.5)
    for k in range(3):
        dome &= ~disc(cx - w + w * 2 * (k + 0.5) / 3, y + h + 1.9, w / 3.2)
    st.part(dome, LILAC[0], d=1, contour=True)
    st.paint(dome & (((XX - int(cx) + 40) // 4) % 2 == 0) & shrink(dome, 1), '#f2e4c0')
    st.paint(rect(int(cx) - 1, y - 2, int(cx), y - 1), LILAC[3], solid=True)
    return dome


def boots(st, xs, y, col='#f5c040'):
    for x in xs:
        b = rect(x, y, x + 5, y + 3)
        b[y, x] = b[y, x + 5] = False
        st.part(b, col, d=1, contour=True)
        st.paint(rect(x, y + 3, x + 5, y + 3) & b, '#b07a10')


def swirl(st, cx, cy, mask, col):
    pts = [(cx + (2 + t * 1.4) * math.cos(t * 1.15), cy + (2 + t * 1.4) * math.sin(t * 1.15) * 0.8) for t in np.linspace(0, 9, 40)]
    m = line(pts) & shrink(mask, 2)
    st.paint(m, col)
    return m


def palm(st, x, y, h=11, lean=1.0, flip=False):
    """Palm tree from its foot (x, y): a curved 2 px trunk, 5 drooping 2 px fronds, a coconut."""
    tx = x + lean * 3
    trunk = line([(x, y), (x + lean * 1.2, y - h * 0.5), (tx, y - h)], w=2)
    st.part(trunk, TRUNK[0], d=1, contour=True)
    st.paint(trunk & ((YY % 3) == 0), TRUNK[3])
    fr = blank()
    for dx, dy, ex, ey in ((-6, -1, -7, 3), (-4, -3, -3, -4), (5, -3, 4, -4), (6, -1, 8, 3), (0, -4, 1, -5)):
        fr |= line([(tx, y - h), (tx + dx, y - h + dy), (tx + ex, y - h + ey)], w=2)
    st.part(fr, PALMG[0], d=1, contour=True)
    st.paint(fr & ~shift(fr, 0, -1), PALMG[2])
    st.paint(rect(int(tx), y - h + 1, int(tx) + 1, y - h + 2), '#5a3a1f', solid=True)
    return trunk | fr


def stalk_eye(st, x, y, base_y, look=(0, 0)):
    s = rect(x + 2, y + 4, x + 2, base_y)
    st.part(s, '#8a2a28', d=0, contour=False, shade=False)
    st.sil |= s
    st.eye(x, y, look=look, socket=UMBER2)
    st.sil |= rect(x - 1, y - 1, x + 5, y + 5)


# ------------------------------------------------------------------ 1. Lightning Pinch: corner-BB hook, common. Lit storm cloud, a bolt crest, one snappy red pincer.
def lightning_pinch():
    key = 'pl-hcr-1'
    st = Sticker()
    core = (14, 24, 45, 50)
    bolt(st, 33, 11, s=1.0)
    arm = line([(14, 40), (10, 36), (10, 31)], w=3)
    st.part(arm, CRAB[0], d=1, contour=True)
    pincer(st, 10, 27, r=4.0, ang=-90, gape=0.5)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'hook', -7, 2.8), e=('B', 'hook', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 32, list(CLOUD)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (((YY == 46) & (XX % 6 < 4)) | ((YY == 30) & ((XX + 3) % 7 < 4))) & shrink(body, 2) & ~grow(holes, 2), '#c8cedb')
    nub_feet = [(17, 50), (36, 50)]
    for x, y in nub_feet:
        st.part(ellipse(x + 3, y + 2, 3.2, 2), '#5a6478', d=1, contour=True)
    st.eye(18, 32, look=(1, 0), lid=0)
    wink(st, 31, 32)
    tongue_grin(st, 25, 40)
    st.paint(rect(16, 39, 18, 39) | rect(37, 39, 39, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Shell Splinter: edge-TBB peg, common. Sandy shell with orange ribs, a chipped corner, a little wind chime.
def shell_splinter():
    key = 'pl-hcr-2'
    st = Sticker()
    core = (11, 20, 40, 48)
    body, holes = piece_blanks(core, n='F', s=('T', 'peg', 0, 3.4), e=('B', 'peg', 1, 3.0), w=('B', 'peg', 1, 3.0))
    body &= ~poly([(33, 19), (41, 19), (41, 28), (37, 24), (38, 22)])            # the splinter: a jagged chip off the top-right corner
    st.part(body, tex=fill(key, body, 11, 20, 30, list(SHELLT)), contour=True)
    st.blank_shade(body, holes, width=1)
    rays = blank()
    for k in range(-3, 4):
        a = math.radians(-90 + k * 17)
        rays |= line([(25.5 + 14 * math.cos(a), 46 + 14 * math.sin(a)), (25.5 + 30 * math.cos(a), 46 + 30 * math.sin(a))], w=2)
    st.paint(rays & body & shrink(body, 2) & ~grow(holes, 2), RIB)
    st.paint(body & shrink(body, 1) & (YY == 21) & ~shift(body, -1, 0) | (body & (YY == 20) & (XX < 33)), '#f2dcae')
    chime(st, 44, 12)
    arm = line([(41, 33), (46, 26), (47, 16)], w=2)
    st.part(arm, SHELLT[1], d=1, contour=True)
    claw_feet(st, [14, 31], 49, w=6, h=3, pal=('#8a6a5a', '#5a4a4a', '#a88a7a', '#3a2a2a'))
    st.eye(15, 31, look=(0, 1), lid=1)
    st.eye(28, 31, look=(0, 1), lid=1)
    st.paint(line([(14, 28), (20, 30)]) | line([(28, 30), (34, 28)]), UMBER)
    st.sprite(['.UUUU.', 'U....U'], 21, 40, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Gust Ribbon: inner-TBTB double, common. Island green, a yellow ribbon looping round it, a leaf sprout, joyful.
def gust_ribbon():
    key = 'pl-hcr-3'
    st = Sticker()
    core = (16, 24, 44, 49)
    body, holes = piece_blanks(core, n=('T', 'double', 3, 3.4), s=('T', 'double', -2, 3.4), e=('B', 'double', 0, 3.0), w=('B', 'double', 0, 3.0))
    back = ellipse(30, 25, 17, 4.6) & ~ellipse(30, 24.6, 14.5, 2.6) & (CY <= 25)
    st.part(back, BOLT[1], d=1, contour=True)
    feather(st, 33, 15, L=8, ang=-140, pal=('#3f8a3a', '#2f6a2a', '#6ab04a', '#1f4a24'))
    feather(st, 35, 15, L=8, ang=-40, pal=('#3f8a3a', '#2f6a2a', '#6ab04a', '#1f4a24'))
    st.part(body, tex=fill(key, body, 16, 24, 29, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    loop = ellipse(30, 25, 17, 4.6) & ~ellipse(30, 24.6, 14.5, 2.6)
    st.part(loop & (CY > 25), BOLT[0], d=1, contour=True)
    st.paint(loop & (CY > 25) & (YY == 28), BOLT[1])
    tail = poly([(46, 24), (52, 20), (55, 22), (51, 25), (55, 28), (51, 29), (46, 27)])
    st.part(tail, BOLT[0], d=1, contour=True)
    st.paint(tail & (XX >= 52), BOLT[1])
    happy_eye(st, 20, 31)
    happy_eye(st, 34, 31)
    st.mouth('grin', 26, 38)
    st.paint(rect(18, 37, 20, 37) | rect(36, 37, 38, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Whirl Pincer: inner-TTTT tri, uncommon. Crab-wine berry, notched pincer tips on its tri tabs, a pinwheel, startled.
def whirl_pincer():
    key = 'pl-hcr-4'
    st = Sticker()
    core = (19, 23, 44, 47)
    body = piece(core, n=('T', 'tri', 0, 3.4), e=('T', 'tri', 0, 3.4), s=('T', 'tri', 0, 3.4), w=('T', 'tri', 0, 3.4))
    for tx, ty, ix, iy in ((32, 14.7, 0, 1), (32, 56.3, 0, -1), (10.7, 35.5, 1, 0), (53.3, 35.5, -1, 0)):
        px_, py_ = -iy, ix
        body &= ~poly([(tx - ix + px_ * 3.2, ty - iy + py_ * 3.2), (tx + ix * 4.6, ty + iy * 4.6), (tx - ix - px_ * 3.2, ty - iy - py_ * 3.2)])
    pinwheel(st, 50, 16, r=5, stick_to=(46, 29))
    st.part(body, tex=fill(key, body, 19, 23, 26, list(WINE)), contour=True)
    st.stitch(body & rect(17, 21, 46, 49), col=BOLT[0])
    st.paint(body & ~shrink(body, 2) & ~rect(19, 23, 44, 47) & ~shift(body, 1, 1), '#f2a0a0')
    st.eye(22, 29, look=(0, -1))
    st.eye(35, 29, look=(0, -1))
    st.paint(line([(22, 25), (26, 25)]) | line([(35, 25), (39, 25)]), UMBER)
    st.mouth('o', 30, 39)
    return key, st


# ------------------------------------------------------------------ 5. Eye of the Storm: inner-BBBB hook, uncommon. Deep sea blue with a calm swirl, a lilac umbrella, yellow rain boots, serene.
def eye_of_the_storm():
    key = 'pl-hcr-5'
    st = Sticker()
    core = (13, 22, 46, 49)
    body, holes = piece_blanks(core, n=('B', 'hook', 6, 2.6), e=('B', 'hook', 6, 2.6), s=('B', 'hook', 0, 2.6), w=('B', 'hook', 6, 2.6))
    st.part(body, tex=fill(key, body, 13, 22, 34, list(SEA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a9d6ea', skip=grow(holes, 3))
    sw = blank()
    for a0 in (0.4, 3.5):
        pts = [(29.5 + (7 + t * 4) * math.cos(a0 + t), 38 + (6 + t * 3) * math.sin(a0 + t)) for t in np.linspace(0, 1.4, 12)]
        sw |= line(pts)
    st.paint(grow(sw, 1) & shrink(body, 3) & ~sw, '#5a88aa')
    st.paint(sw & shrink(body, 3), '#9cc4dc')
    umbrella(st, 21, 9, w=10, h=6)
    handle = rect(21, 16, 21, 24)
    st.paint(handle, LILAC[3], solid=True)
    st.paint(rect(16, 24, 17, 26) | rect(18, 26, 20, 26), LILAC[3], solid=True)
    boots(st, [16, 37], 50)
    for x in (20, 34):
        st.sprite(['.....', 'U...U', '.UUU.'], x, 31, {'U': UMBER}, solid=False)
        st.dots([(x - 1, 31), (x + 5, 31)], UMBER)
    st.mouth('smile', 27, 40)
    return key, st


# ------------------------------------------------------------------ 6. Gale Islander: whimsy-crab peg, rare. A crab with raised claws and legs, an island on its back: palms + flag. Shy stalk eyes.
def gale_islander():
    key = 'pl-hcr-6'
    st = Sticker()
    isl = ellipse(32, 34, 11, 6) & (CY < 35)
    st.part(isl, '#7ab55c', d=1, contour=True)
    st.paint(isl & ~shift(isl, 0, -1), '#a8d47a')
    palm(st, 25, 31, h=11, lean=-1.0)
    palm(st, 40, 31, h=9, lean=1.0)
    st.paint(rect(32, 21, 32, 30), '#4a2c1a', solid=True)                      # flag pole
    st.paint(poly([(33, 21), (37, 23), (33, 25)]) | rect(33, 21, 33, 24), BOLT[0], solid=True)
    sand = ellipse(32, 35.5, 14, 3.6) & ~ellipse(32, 34, 11, 3) & (CY < 37)
    st.part(sand, '#dcbc88', d=1, contour=True)
    for s in (-1, 1):
        arm = line([(32 + s * 12, 41), (32 + s * 17, 36), (32 + s * 18, 31)], w=3)
        st.part(arm, CRAB[0], d=1, contour=True)
        pincer(st, 32 + s * 18, 27, r=3.8, ang=-90 + s * 18, gape=0.45)
        for k, (a, b, y0) in enumerate(((12, 17, 42), (11, 15, 45), (8, 11, 47))):
            leg = line([(32 + s * a, y0), (32 + s * b, y0 + 4)], w=2)
            st.part(leg, CRAB[3] if k == 1 else CRAB[0], d=1, contour=True)
    shell = ellipse(32, 41, 14, 7)
    tab = knob('s', 'peg', 32, 47.5, r=2.6)
    body = shell | tab
    src = pic.sample(*ROWS[key]['piece'], 18, 34, 28).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(CRAB[0])
    tex[src > 300] = hx(CRAB[1])
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    st.stitch(shell & (CY > 37), col='#f5cf6a')
    st.dots([(21, 40), (42, 40)], '#f2e4c0')
    stalk_eye(st, 24, 32, 36, look=(1, 1))
    stalk_eye(st, 35, 32, 36, look=(1, 1))
    st.paint(rect(21, 41, 23, 41) | rect(40, 41, 42, 41), BLUSH)
    st.sprite(['U.U.U', '.U.U.'], 30, 43, {'U': UMBER}, solid=False)
    st.sparkle(6, 10)
    st.sparkle(54, 8, big=False)
    st.sparkle(55, 52, big=False)
    return key, st


PALS = [lightning_pinch, shell_splinter, gust_ribbon, whirl_pincer, eye_of_the_storm, gale_islander]

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
