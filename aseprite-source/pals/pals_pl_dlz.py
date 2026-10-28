"""Puzzle Pals: DRAGONLIZARD DEN (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-dlz-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_dlz.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-dragonlizard-den.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Scalecrust Tot    lifted palm-bark rust      | scale-chip pattern, 3 scales flaking off mid-laugh | laughing ^ ^ eyes, open grin, blush
  2 Tongue Flicker    leaf green                 | chameleon eye domes, forked red tongue, a missed fly | cheeky wink, tongue out
  3 Tail Tick         karst stone grey + moss    | a striped curled tail tapping a pebble, tik marks  | listening, head tilt, eyes right
  4 Diamond Spur      lizard-belly sand          | four brown diamond spurs standing on its brow      | smug lids, raised brow, smirk
  5 Karst Yawn        den-mouth violet           | hanging jungle vines, a huge yawn, a yawn tear     | sleepy, stretching peg arm
  6 Mossback Monitor  monitor olive, moss back   | whimsy lizard silhouette, moss blanket + sprout    | bright profile eye, happy, glow (rare)
Hook blanks kept small (r 3). No puffs. Browns lifted for dark pages.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-dragonlizard-den'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-dragonlizard-den-418047')

RUST = ('#9a5e36', '#b87a48')
LEAF = ('#4a8a3e', '#62a64e')
STONE = ('#949f8c', '#b2bcaa')
SANDB = ('#c8b47a', '#ddcc94')
DEN = ('#54447e', '#685a98')
OLIVE = ('#8a8a4a', '#a4a45a')
MOSS = ('#4a8a3e', '#31593c', '#7cc060', '#24402c')
DIAM = ('#6a5430', '#4a3a22', '#9a7a48', '#2a1a10')
TONGUE = '#d6322b'
BLUSH = '#f0a0a0'
TEAR = '#a4d0e8'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def happy_eye(st, x, y):
    """Laughing eye: a 6 px umber arch (^) with a cream glint under it."""
    st.sprite(['..UU..', '.U..U.', 'U....U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UUUUU', '.UUU.'], x, y + 2, {'U': UMBER}, solid=False)
    st.dots([(x - 1, y + 1)], UMBER)


def sleepy_eye(st, x, y):
    """Closed, drooping: a down arc with two lashes."""
    st.sprite(['UUUUU', '.U.U.'], x, y, {'U': UMBER}, solid=False)


def flake(st, x, y, col, w=4, tilt=1):
    """A thin scale flake drifting off: a flat tilted lens chip, light top edge, a crack line."""
    m = poly([(x, y + tilt * 1.5), (x + w * 0.5, y - 1), (x + w, y + 1 - tilt * 1.5), (x + w * 0.5, y + 2)])
    st.part(m, col, d=0, contour=True)
    st.paint(m & ~shift(m, 0, 1), '#fff3c8')
    return m


def fly(st, x, y):
    st.sprite(['CC.CC', 'CUUUC', '.UUU.', '..U..'], x, y, {'C': '#e8f4f8', 'U': '#3a4a2a'})
    st.dots([(x + 2, y + 1)], '#a8241f')


def tongue(st, pts, fork):
    m = line(pts, w=2)
    tx, ty = pts[-1]
    m |= line([(tx, ty), (tx - fork, ty + 3)], w=1) | line([(tx, ty), (tx + fork, ty + 3)], w=1)
    st.part(m, TONGUE, d=0, contour=False)
    st.paint(line(pts[:2], w=1), '#f07a6a')
    st.sil |= m
    return m


def curl_tail(st, pts, w0, w1, pal, stripes=True):
    """Tapering tail along a polyline: discs whose radius shrinks from w0 to w1; darker bands every few steps."""
    import numpy as _np
    m = blank()
    band = blank()
    seg = []
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        for t in _np.linspace(0, 1, 8, endpoint=False):
            seg.append((ax + (bx - ax) * t, ay + (by - ay) * t))
    seg.append(pts[-1])
    for i, (x, y) in enumerate(seg):
        r = w0 + (w1 - w0) * i / max(1, len(seg) - 1)
        d = disc(x, y, r)
        m |= d
        if stripes and i % 6 == 3:
            band |= disc(x, y, r + 0.3)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(band & m & shrink(m, 1), pal[1])
    return m


def pebble(st, cx, cy):
    m = ellipse(cx, cy, 3.2, 2.3)
    st.part(m, '#8a8f84', d=1, contour=True)
    st.paint(rect(int(cx) - 1, int(cy) - 1, int(cx), int(cy) - 1), '#c4ccbc')
    return m


def ticks(st, pts, col=CREAM):
    for (x0, y0, x1, y1) in pts:
        m = line([(x0, y0), (x1, y1)])
        st.paint(m, col)
        st.extra |= m


def diamond(st, cx, cy, r, pal):
    m = poly([(cx, cy - r - 1), (cx + r, cy), (cx, cy + r + 1), (cx - r, cy)])
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & (CX < cx) & (CY < cy) & shrink(m, 1), pal[2])
    return m


def vine(st, x, y0, y1, sway=1):
    m = line([(x, y0), (x + sway, (y0 + y1) / 2), (x, y1)], w=1)
    st.paint(m, '#5aa04a', solid=True)
    for k, yy in enumerate(range(y0 + 3, y1, 4)):
        lx = x + (1 if k % 2 else -1) + (sway if yy > (y0 + y1) / 2 else 0) * 0
        st.paint(rect(lx, yy, lx, yy) | rect(lx + (1 if k % 2 else -1), yy, lx + (1 if k % 2 else -1), yy), '#7cc060', solid=True)
    st.paint(rect(x, y1, x, y1 + 1), '#a4d0e8', solid=True)     # a karst drip on the end
    return m


def yawn(st, x, y):
    st.sprite(['..UUUUU..', '.UCRRRCU.', 'UURRRRRUU', 'URRRRRRRU', 'URRRPPRRU', 'UURPPPPUU', '.UUUUUUU.'], x, y,
              {'U': UMBER, 'R': MOUTH_RED, 'P': '#f0a0a0', 'C': CREAM}, solid=False)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Scalecrust Tot: corner-TB hook, common.
def scalecrust_tot():
    key = 'pl-dlz-1'
    st = Sticker()
    core = (12, 22, 43, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'hook', -6, 3.4), e=('B', 'hook', 3, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 32, list(RUST)), contour=True)
    st.blank_shade(body, holes, width=1)
    face = rect(15, 27, 38, 42)
    scales(st, body & shrink(body, 2) & ~face & ~grow(holes, 2), ramp('#c8925a'), step=5)
    flake(st, 45, 14, '#d89a5e', 7, 1)
    flake(st, 48, 22, '#d89a5e', 6, -1)
    ticks(st, [(44, 10, 45, 11), (55, 17, 56, 18), (50, 28, 51, 29)])
    nub_feet(st, [15, 33], 49, '#6a3e22')
    happy_eye(st, 17, 31)
    happy_eye(st, 30, 31)
    st.paint(rect(16, 35, 18, 36) | rect(33, 35, 35, 36), BLUSH)
    st.mouth('grin', 23, 36)
    return key, st


# ------------------------------------------------------------------ 2. Tongue Flicker: edge-TBT tri, common.
def tongue_flicker():
    key = 'pl-dlz-2'
    st = Sticker()
    core = (15, 25, 45, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 3.4), e=('B', 'tri', 3, 3.2), w=('T', 'tri', 3, 3.0))
    domes = ellipse(20, 26, 5.5, 5) | ellipse(40, 26, 5.5, 5)
    body |= domes
    st.part(body, tex=fill(key, body, 13, 25, 33, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(domes & ~shift(domes, 0, 1) & ~ellipse(20, 27, 4, 4) & ~ellipse(40, 27, 4, 4), '#9cd07c')
    st.stitch(body & (CY > 31), col='#b0b060', skip=grow(holes, 3) | grow(domes, 1))
    st.paint(ellipse(20.5, 26.5, 3.6, 3.2), UMBER2)
    st.paint(ellipse(20.5, 26.5, 2.6, 2.2), CREAM)
    wink(st, 18, 23)
    st.eye(38, 23, look=(1, 1))
    st.sprite(['U.....U', '.UUUUU.'], 26, 37, {'U': UMBER}, solid=False)
    tongue(st, [(30, 39), (32, 46), (35, 53)], 2)
    fly(st, 46, 51)
    claw_tips(st, 17, 49, n=3)
    claw_tips(st, 40, 49, n=3)
    return key, st


# ------------------------------------------------------------------ 3. Tail Tick: inner-TBTB double, common.
def tail_tick():
    key = 'pl-dlz-3'
    st = Sticker()
    core = (11, 21, 40, 46)
    body, holes = piece_blanks(core, n=('T', 'double', -2, 3.4), e=('B', 'double', -6, 3.0), s=('T', 'double', -6, 3.4),
                               w=('B', 'double', 3, 3.0))
    tail = curl_tail(st, [(37, 43), (45, 44), (51, 38), (52, 31), (48, 28)], 3.6, 1.4, ('#a8b2a0', '#4a8a3e'), stripes=False)
    st.dots([(44, 43), (50, 39), (51, 33)], '#5aa04a')
    st.part(body, tex=fill(key, body, 11, 21, 30, list(STONE)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x, y0, y1 in ((15, 24, 28), (36, 33, 38)):     # moss streaks like the karst drips
        st.paint(rect(x, y0, x, y1) & body, '#5aa04a')
    pebble(st, 53, 47)
    ticks(st, [(50, 50, 49, 52), (56, 51, 57, 53), (57, 43, 58, 42)])
    # head tilt: right eye lower, pupils right
    st.eye(15, 27, look=(1, 0), lid=1)
    st.eye(27, 29, look=(1, 0), lid=1)
    st.sprite(['U....', '.UUU.', '....U'], 19, 37, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 4. Diamond Spur: inner-TTTT hook, uncommon.
def diamond_spur():
    key = 'pl-dlz-4'
    st = Sticker()
    core = (17, 25, 44, 47)
    for cx in (27, 32, 37, 42):
        diamond(st, cx, 23, 2.6, DIAM)
    body = piece(core, r=3.2, n=('T', 'hook', -9, 3.0), e=('T', 'hook', 2, 3.2), s=('T', 'hook', 0, 3.2), w=('T', 'hook', 2, 3.2, True))
    st.part(body, tex=fill(key, body, 17, 25, 28, list(SANDB)), contour=True)
    st.stitch(body, col='#8a8a4a')                                   # uncommon accent: the monitor's olive
    for cx in (27, 32, 37, 42):
        st.dots([(cx, 23)], '#d8c060')
    # smug: lazy lids, pupils sliding left, one brow cocked, smirk
    st.eye(21, 31, look=(-1, 0), lid=2)
    st.eye(33, 31, look=(-1, 0), lid=2)
    st.paint(line([(33, 28), (36, 27), (38, 28)]), UMBER)
    st.mouth('smirk', 28, 40)
    st.paint(rect(19, 38, 21, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Karst Yawn: inner-TTBB peg, uncommon.
def karst_yawn():
    key = 'pl-dlz-5'
    st = Sticker()
    core = (12, 22, 44, 48)
    body, holes = piece_blanks(core, n=('T', 'peg', -6), e=('T', 'peg', -4), s=('B', 'peg', 4, 3.0), w=('B', 'peg', 1, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(DEN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#5aa04a', skip=grow(holes, 3))              # uncommon accent: jungle green
    vine(st, 31, 22, 30, 1)
    vine(st, 41, 22, 33, -1)
    vine(st, 15, 22, 27, 1)
    st.eye(16, 30, look=(0, 1), lid=3)
    st.eye(31, 30, look=(0, 1), lid=3)
    st.dots([(37, 35), (37, 36)], TEAR)
    st.dots([(38, 37)], '#eef8fc')
    yawn(st, 22, 37)
    nub_feet(st, [14, 37], 48, '#3a2e5a')
    return key, st


# ------------------------------------------------------------------ 6. Mossback Monitor: whimsy-lizard double, rare.
def mossback_monitor():
    key = 'pl-dlz-6'
    st = Sticker()
    torso = ellipse(32, 39, 12.5, 6.5)
    head = ellipse(18, 35, 7, 5.5) | ellipse(13, 37, 3.6, 3.2)
    neck = poly([(19, 31), (25, 34), (25, 44), (17, 40)])
    legs = blank()
    feet = ((21, -1), (40, 1))
    for x, s_ in feet:
        legs |= rect(x, 43, x + 4, 47) | ellipse(x + 2.5 + s_ * 1.5, 48.5, 3.6, 2)
    tab = knob('n', 'double', 33, 33.5, r=3.0)
    body = torso | head | neck | tab | legs
    curl_tail(st, [(42, 41), (48, 39), (52, 33), (51, 27), (47, 25)], 3.6, 1.3, ('#8a8a4a', '#6a6a36'), stripes=False)
    st.part(body, tex=fill(key, body, 12, 28, 44, list(OLIVE)), contour=True)
    st.paint(torso & (CY > 42) & ~legs, '#ddcc94')                       # pale belly
    for x, s_ in feet:
        st.paint(rect(x - 1 + s_ * 2, 50, x + 6 + s_ * 2, 50) & (XX % 2 == 1) & shift(legs, 0, 1), CREAM, solid=True)
    # a moss runner along its spine (not a shell): lumpy strip with tufts and one sprout
    moss = (ellipse(32, 34.5, 9, 2) | disc(26, 34.5, 1.6) | disc(38, 34.5, 1.6)) & torso
    st.paint(moss, MOSS[0])
    st.paint(moss & ~shift(moss, 0, 1), MOSS[2])
    st.sprite(['G.G', '.G.'], 38, 31, {'G': '#7cc060'})
    st.stitch(torso & (CY > 37), col='#fff3c8', skip=grow(legs, 1) | grow(head, 1))
    st.paint(rect(15, 31, 17, 31) | rect(14, 32, 14, 32) | rect(30, 37, 32, 37), '#fff3c8')    # polished gloss
    st.eye(17, 32, look=(-1, -1))
    st.sprite(['U....U', '.UUUU.'], 10, 38, {'U': UMBER}, solid=False)
    st.paint(rect(21, 39, 22, 39), BLUSH)
    st.dots([(11, 35)], UMBER)
    st.sparkle(9, 20)
    st.sparkle(54, 12, big=False)
    st.sparkle(27, 21, big=False)
    return key, st


PALS = [scalecrust_tot, tongue_flicker, tail_tick, diamond_spur, karst_yawn, mossback_monitor]

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
