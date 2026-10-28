"""Puzzle Pals: LAIR OF THE GREY WOLF KING (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-gwk-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_gwk.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-of-the-grey-wolf-king.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Fang Chip          lifted wolf-chest tan      | the king's red banner on a pole, one upward underbite fang | brave, flat-top eyes, waving
  2 Pawprint Cuff      snow white-blue            | a pressed pawprint + a red knitted cuff band, mitten feet   | sleepy, yawning
  3 Moonpale Mantle    twilight pink              | a little ermine-trimmed night-blue cape, crescent clasp     | shy, eyes down, wobbly mouth
  4 Crown Points       royal blue                 | gilded tri tab tips (the 4 crown points), a red sash + medal | haughty, eyes shut, nose up
  5 Howl Echo          pine teal                  | moon-white echo rings rising from its howl, head tilted     | eyes squeezed shut > <, tall O
  6 Grey Wolf Whistle  wolf grey + cream muzzle   | whimsy wolf-head silhouette, a silver whistle on a cord     | bright, friendly, glow (rare)
Hook blanks kept small (r 3). No puffs. Browns lifted for dark pages.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-of-the-grey-wolf-king'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-of-the-grey-wolf-king-d7db5e')

TAN = ('#b98262', '#d09e7c')
SNOW = ('#c3c8e4', '#e2e5f4')
PINK = ('#c798ab', '#dbb6c2')
ROYAL = ('#4f62a8', '#6478b6')
PINE = ('#3f7f78', '#53968c')
WOLF = ('#77768f', '#8d8ca8')
FLAG = ('#dd3a2a', '#b12d22', '#f2795a', '#79270c')
NIGHT = ('#33427e', '#24305e', '#5468a4', '#1c1a48')
MOONW = '#eef0f8'
BLUSH = '#f0a0a8'
PAD = '#7480b4'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def banner(st, x, ytop, ybot):
    """The king's red banner: a wooden pole with a gold knob, a swallow-tailed red flag rippling right."""
    pole = rect(x, ytop, x + 1, ybot)
    st.part(pole, '#9a6a3a', d=1, contour=True)
    st.part(disc(x + 1, ytop - 1, 2.0), GOLD, d=1, contour=True)
    fl = poly([(x + 2, ytop + 1), (x + 12, ytop + 2), (x + 10, ytop + 5.5), (x + 12, ytop + 9), (x + 2, ytop + 9)])
    st.part(fl, FLAG[0], d=1, contour=True)
    st.paint(fl & (XX == x + 6) & (YY > ytop + 2) & (YY < ytop + 8), FLAG[1])
    st.paint(rect(x + 4, ytop + 4, x + 5, ytop + 5), GOLD)
    return pole | fl


def flat_eye(st, x, y):
    """Brave eye: a locked eye with a flat umber lid line across its top (determined, not cross)."""
    st.eye(x, y, look=(0, 0), lid=2)
    st.paint(rect(x - 1, y - 1, x + 5, y - 1), UMBER)


def pawprint(st, cx, cy, col=PAD):
    st.paint(ellipse(cx, cy + 2, 3.2, 2.6), col)
    for dx, dy in ((-3.5, -2.2), (-1.2, -3.8), (1.2, -3.8), (3.5, -2.2)):
        st.paint(disc(cx + dx, cy + dy, 1.2), col)


def knit_cuff(st, x0, x1, y, h=5):
    m = rect(x0, y, x1, y + h - 1)
    st.part(m, FLAG[0], d=1, contour=True)
    st.paint(m & (XX % 2 == 0) & shrink(m, 0), FLAG[1])
    st.paint(m & (YY == y), FLAG[2])
    return m


def mitten(st, x, y, col='#5468a4'):
    m = ellipse(x + 3, y + 2, 3.5, 2.5) | disc(x + 0.5, y + 0.5, 1.5)
    st.part(m, col, d=1, contour=True)
    st.paint(m & (YY == y + 3), '#eef0f8')
    return m


def yawn(st, x, y):
    st.sprite(['.UUU.', 'URRRU', 'URRRU', '.UUU.'], x, y, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.dots([(x + 2, y + 2)], '#f0889a')


def mantle(st, cx, y, w=17, h=16):
    """A small royal cape over the shoulders: night-blue, flaring at the hem, ermine-trimmed collar, gold crescent clasp."""
    cape = poly([(cx - w * 0.62, y), (cx + w * 0.62, y), (cx + w, y + h), (cx - w, y + h)]) & ~poly([(cx - 6, y + 2), (cx + 6, y + 2), (cx + 5, y + h + 1), (cx - 5, y + h + 1)])
    st.part(cape, NIGHT[0], d=1, contour=True)
    collar = rect(int(cx - w * 0.62) - 1, y - 1, int(cx + w * 0.62) + 1, y + 1)
    st.part(collar, '#f2e4c0', d=0, contour=True)
    st.paint(collar & ((XX * 3 + YY) % 5 == 0), UMBER)
    st.paint(cape & (YY == y + h) & (XX % 3 == 0), '#f2e4c0')
    st.sprite(['.GG', 'G..', 'G..', '.GG'], int(cx) - 1, y - 2, {'G': GOLD}, solid=False)
    return cape | collar


def sash(st, pts):
    m = line(pts, w=4)
    st.part(m, FLAG[0], d=1, contour=True)
    st.paint(line(pts, w=1), FLAG[2])
    return m


def medal(st, x, y):
    st.part(disc(x + 0.5, y + 0.5, 2.6), GOLD, d=1, contour=True)
    st.dots([(x, y)], GOLD_L)
    st.dots([(x + 1, y + 1)], GOLD_D)


def haughty_eye(st, x, y):
    """Closed, chin-up: a cream lid half with a downward umber arc and two lash flicks."""
    st.sprite(['.UUUU.', 'U....U', 'C.UU.C'], x - 1, y, {'U': UMBER, 'C': UMBER2}, solid=False)
    st.dots([(x - 2, y), (x + 5, y)], UMBER)


def squeeze_eye(st, x, y, left=True):
    rows_ = ['U...', '.UU.', '..UU', '.UU.', 'U...'] if left else ['...U', '.UU.', 'UU..', '.UU.', '...U']
    st.sprite(rows_, x, y, {'U': UMBER}, solid=False)


def echo_rings(st, cx, cy):
    """Three moon-white arcs rising up-right from the howl, each a little smaller (the echo coming back)."""
    for r, w in ((9, 1.0), (13, 1.0), (17, 1.0)):
        d = np.hypot(CX - cx, CY - cy)
        ang = np.degrees(np.arctan2(-(CY - cy), CX - cx))
        m = (np.abs(d - r) < 0.75 * w) & (ang > 20) & (ang < 75)
        m &= ~st.sil
        st.paint(m, MOONW)
        st.extra |= m


def whistle(st, x, y):
    cord = line([(x - 14, y - 5), (x - 8, y - 1), (x - 2, y + 1)])
    st.paint(cord & ~st.sil | cord, '#c8402e')
    tube = rect(x, y, x + 6, y + 2)
    st.part(tube | disc(x + 6.5, y + 2.5, 2.2), GOLD, d=1, contour=True)
    st.paint(rect(x + 1, y, x + 5, y), GOLD_L)
    st.dots([(x + 2, y + 1)], UMBER)
    return tube


def note(st, x, y, col=GOLD):
    st.sprite(['.GG', '.G.', '.G.', 'GG.', 'GG.'], x, y, {'G': col}, solid=False)
    for j, r in enumerate(['.GG', '.G.', '.G.', 'GG.', 'GG.']):
        for i, ch in enumerate(r):
            if ch == 'G':
                st.extra[y + j, x + i] = True


# ------------------------------------------------------------------ 1. Fang Chip: corner-TT hook, common. Tan, the king's banner held high, one brave underbite fang.
def fang_chip():
    key = 'pl-gwk-1'
    st = Sticker()
    core = (16, 22, 44, 48)
    banner(st, 10, 9, 44)
    body = piece(core, n='F', w='F', e=('T', 'hook', -2, 3.2), s=('T', 'hook', 3, 3.2))
    st.part(body, tex=fill(key, body, 16, 22, 30, TAN), contour=True)
    st.stitch(body, col='#f2e4c0', skip=grow(body & ~rect(*core), 1))
    # arm grabbing the pole
    st.part(ellipse(14.5, 34, 3, 2.4), TAN[0], d=1, contour=True)
    st.paint(rect(11, 33, 12, 35), '#9a6a3a')
    flat_eye(st, 21, 28)
    flat_eye(st, 33, 28)
    st.sprite(['U.....U', '.UUUUU.'], 24, 37, {'U': UMBER}, solid=False)
    st.sprite(['.UU.', 'UBBU', 'UBDU'], 28, 35, {'U': UMBER, 'B': '#fff3c8', 'D': '#d2bf96'}, solid=False)  # one chipped fang, up over its lip
    st.dots([(29, 36)], '#fff3c8')
    claw_feet(st, [18, 32], 49, w=5, h=3)
    return key, st


# ------------------------------------------------------------------ 2. Pawprint Cuff: edge-TTB double, common. Snow white, a pawprint pressed in, a red knitted cuff, yawning.
def pawprint_cuff():
    key = 'pl-gwk-2'
    st = Sticker()
    core = (14, 20, 46, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'double', 4, 3.4), e=('T', 'double', -2, 3.4), w=('B', 'double', 2, 3.0))
    st.part(body, tex=fill(key, body, 14, 20, 33, SNOW), contour=True)
    st.blank_shade(body, holes, width=1)
    pawprint(st, 37, 30)
    knit_cuff(st, 14, 46, 43, 6)
    mitten(st, 16, 49)
    mitten(st, 37, 49)
    st.eye(17, 28, look=(0, 1), lid=2)
    st.eye(27, 28, look=(0, 1), lid=2)
    yawn(st, 22, 36)
    frost_chip(st, 52, 13, r=2)
    st.extra |= disc(52.5, 13.5, 2.5) & ~st.sil & (st.px.sum(-1) > 0)
    return key, st


# ------------------------------------------------------------------ 3. Moonpale Mantle: inner-TBTB peg, common. Twilight pink, a tiny ermine cape, shy.
def moonpale_mantle():
    key = 'pl-gwk-3'
    st = Sticker()
    core = (16, 18, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'peg', 0, 3.4), e=('B', 'peg', 1, 2.8), s=('T', 'peg', 0, 3.4), w=('B', 'peg', 1, 2.8))
    st.part(body, tex=fill(key, body, 16, 18, 31, PINK), contour=True)
    st.blank_shade(body, holes, width=1)
    mantle(st, 31, 37, w=16, h=12)
    st.eye(21, 25, look=(0, 1))
    st.eye(34, 25, look=(0, 1))
    st.paint(rect(19, 32, 21, 32) | rect(38, 32, 40, 32), BLUSH)
    st.sprite(['.U.U', 'U.U.'], 28, 33, {'U': UMBER}, solid=False)
    # two little hands clutching the cape edges
    st.part(disc(25.5, 42.5, 1.8), PINK[1], d=1, contour=True)
    st.part(disc(36.5, 42.5, 1.8), PINK[1], d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 4. Crown Points: inner-TTTT tri, uncommon. Royal blue, its four tri tabs gilded (the crown's points), red sash, haughty.
def crown_points():
    key = 'pl-gwk-4'
    st = Sticker()
    core = (18, 20, 44, 46)
    body = piece(core, n=('T', 'tri', 0, 3.6), e=('T', 'tri', 0, 3.4), s=('T', 'tri', 0, 3.4), w=('T', 'tri', 0, 3.4))
    tex = fill(key, body, 18, 20, 27, ROYAL)
    tips = body & ~grow(rect(*core), 2)
    tex[tips] = hx('#e8a317')
    tex[tips & ~grow(rect(*core), 5)] = hx(GOLD)
    st.part(body, tex=tex, contour=True)
    st.paint(tips & ~shift(tips, 1, 1) & ~grow(rect(*core), 4), GOLD_L)
    st.paint(disc(31.5, 12.5, 1.0), '#dd3a2a')                       # a ruby in the top point
    st.stitch(body & grow(rect(*core), 1), col=GOLD)                 # uncommon accent: crown gold
    sash(st, [(18, 37), (33, 47)])
    medal(st, 26, 42)
    haughty_eye(st, 21, 28)
    haughty_eye(st, 35, 28)
    st.paint(rect(20, 31, 22, 31) | rect(39, 31, 41, 31), '#8a9ad0')
    st.sprite(['U....U', '.UUUU.'], 28, 34, {'U': UMBER}, solid=False)
    st.dots([(34, 33)], UMBER)
    return key, st


# ------------------------------------------------------------------ 5. Howl Echo: inner-TTBB hook, uncommon. Pine teal, head tilted back mid-howl, echo rings rising.
def howl_echo():
    key = 'pl-gwk-5'
    st = Sticker()
    core = (12, 24, 40, 50)
    body, holes = piece_blanks(core, n=('T', 'hook', -4, 3.0), e=('T', 'hook', 2, 3.0), s=('B', 'hook', 3, 2.6), w=('B', 'hook', 2, 2.6))
    st.part(body, tex=fill(key, body, 12, 24, 29, PINE), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=MOONW, skip=grow(holes, 3))                  # uncommon accent: moon white
    # tilted-back face: features climb to the upper right
    squeeze_eye(st, 19, 31, left=True)
    squeeze_eye(st, 30, 28, left=False)
    st.sprite(['.UUUU.', 'URRRRU', 'URRRRU', 'URRRRU', 'URPPRU', '.UUUU.'], 26, 36, {'U': UMBER, 'R': MOUTH_RED, 'P': '#f0889a'}, solid=False)
    st.paint(rect(15, 38, 17, 38) | rect(36, 34, 38, 34), BLUSH)
    echo_rings(st, 36, 26)
    return key, st


# ------------------------------------------------------------------ 6. Grey Wolf Whistle: whimsy-wolf double, rare. A wolf-head piece, pointed ears, cream muzzle, silver whistle on a cord.
def grey_wolf_whistle():
    key = 'pl-gwk-6'
    st = Sticker()
    head = ellipse(32, 33, 15, 12.5)
    ears = poly([(18, 29), (19.5, 9), (30, 22)]) | poly([(46, 29), (44.5, 9), (34, 22)])
    ruff = poly([(18, 34), (11, 44), (21, 43)]) | poly([(46, 34), (53, 44), (43, 43)]) | poly([(22, 42), (32, 49), (42, 42)])
    tab = knob('s', 'double', 32, 48, r=3.0)
    body = head | ears | ruff | tab
    st.part(body, tex=fill(key, body, 14, 10, 38, WOLF), contour=True)
    inner = (poly([(21, 25), (21.5, 14), (27, 22)]) | poly([(43, 25), (42.5, 14), (37, 22)]))
    st.paint(inner, '#d4b4bc')
    st.paint(poly([(30, 20), (34, 20), (32, 27)]), '#a4a4c4')        # forehead blaze
    muz = ellipse(32, 39.5, 7.5, 5.2)
    st.part(muz, '#e8e0d0', d=1)
    st.sprite(['.UUU.', 'UUUUU', '.UUU.'], 30, 35, {'U': UMBER}, solid=False)
    st.dots([(31, 35)], '#74462a')
    st.sprite(['..U..', 'UU.UU'], 30, 39, {'U': UMBER}, solid=False)
    st.paint(rect(31, 41, 33, 42), '#f0889a')                         # a tongue tip, happy pant
    st.eye(21, 27, look=(1, 0))
    st.eye(38, 27, look=(-1, 0))
    st.stitch(head | ears, col='#fff3c8', skip=muz | grow(inner, 1))
    whistle(st, 42, 45)
    note(st, 52, 30)
    st.sparkle(8, 10)
    st.sparkle(54, 5, big=False)
    st.sparkle(7, 49, big=False)
    return key, st


PALS = [fang_chip, pawprint_cuff, moonpale_mantle, crown_points, howl_echo, grey_wolf_whistle]

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
