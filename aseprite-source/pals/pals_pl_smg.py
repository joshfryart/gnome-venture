"""Puzzle Pals: SALT MINE GALLERIES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-smg-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_smg.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve = cosy-curious cave beasts and the dark's small treasures. kit_lair parts are building blocks only; the rest is drawn here.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/delve-salt-mine-galleries.png,
calmed onto 2 tones of a pal-own colour family from the picture (salt-wall lavender, rosy salt, doorway indigo, rail steel, lamp honey,
cart timber).
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Brass Hardhat      salt-wall lavender     | tilted brass lamp helmet with a lit lamp, clink ticks, zzz   | sleepy nodding: closed lash arcs, small o
  2 Salt Lick          rosy salt white        | a pink rock-salt block hugged in stubby arms, tongue on it   | cheeky wink, tongue out
  3 Crystal Pendant    doorway indigo         | gold chain necklace with a hanging salt crystal, tinkle ticks | shy dot eyes looking down, blush, wavy mouth
  4 Railtrack Rattle   rail steel (+ timber)  | timber sleeper sash with bolts, rail-iron tab ends, rattle ticks | startled: big round eyes, brows up, o
  5 Salthall Roundel   lamp honey (+ salt)    | carved rosy-salt arch with a pink keystone, round lit window, warm wisps | smug half lid side-eye, smirk
  6 Saltblock Minecart cart timber (rare)     | whimsy minecart: salt blocks piled high, steel wheels, gold band | singing: happy ^ ^ arcs, open grin, note
Ring and Plus knobs centred (n, s at 0; e, w at the same height, offset 0). No hooks.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-salt-mine-galleries'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-salt-mine-galleries-228a12')

LAVW = ('#8e7c98', '#a898a8')          # salt-wall lavender
ROSY = ('#d6c0bc', '#eadcd4')          # rosy salt white
INDIGO = ('#44395e', '#584c76')        # lit doorway midnight, lifted off black
STEEL = ('#5f6b7c', '#7a8698')         # rail steel
HONEY = ('#e8b24a', '#f5cf6a')         # lamp honey
TIMBER = ('#9a5630', '#b46a3c')        # cart timber, lifted off mud
BRASSP = ('#d8a048', '#a87030', '#f4cc80', '#6a4420')
ROCKSALT = ('#e8a0a8', '#c87482', '#fbd8dc', '#8a4858')
CRYSTAL = ('#e8f0f8', '#b0c4dc', '#ffffff', '#7a8aa8')
SLEEPER = ('#8a4f2a', '#6a3420', '#b07a45', '#481617')
RAIL = ('#c9c5bc', '#9a968e', '#eeeae2', '#5b6470')
ARCH = ('#eadcd4', '#c8b0b0', '#fff6ee', '#9a8090')
WHEEL = ('#5b6470', '#3e4650', '#8a94a0', '#2a3038')
KEY = '#d86a8a'
BLUSH = '#f0a0a0'
TONGUE = '#e87a8a'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


def extra_sprite(st, rows_, x, y, cmap):
    st.sprite(rows_, x, y, cmap, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch not in '. ':
                st.extra[y + j, x + i] = True


def boots(st, xs, y, w=6, h=3, col=SHOE[0]):
    for x in xs:
        sh = rect(x, y, x + w - 1, y + h - 1)
        sh[y, x] = sh[y, x + w - 1] = False
        st.part(sh, col, d=1, contour=True)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def hardhat(st, cx, y, w=15, tilt=-2.5):
    """A tilted brass miner's helmet: dome over a slanted brim, a ridge, and a lit lamp on the front (cream lens, gold rim)."""
    dome = ellipse(cx, y, w - 4, 8) & (CY < y + 0.5 + tilt * (CX - cx) / w)
    brim = poly([(cx - w - 1, y + 1 - tilt), (cx + w + 1, y + 1 + tilt), (cx + w + 1, y + 3.5 + tilt), (cx - w - 1, y + 3.5 - tilt)])
    m = dome | brim
    st.part(m, BRASSP[0], d=1, contour=True)
    st.paint(brim & ~shift(brim, 0, -1), BRASSP[1])
    st.paint(line([(cx - 7, y - 4), (cx - 5, y - 6)]) & dome, BRASSP[2])          # a lit glint on the dome
    lamp = disc(cx, y - 3.5, 3.8)
    st.part(lamp, GOLD_D, d=1, contour=True)
    st.paint(disc(cx, y - 3.5, 2.6), GOLD_L)
    st.dots([(int(cx) - 1, int(y) - 5)], '#ffffff')
    return m | lamp


def closed_lash(st, x, y):
    """Sleepy closed eye: a down-curved arc (smile-shaped lid line) with two lashes."""
    st.sprite(['U.....U', '.UUUUU.'], x, y, {'U': UMBER}, solid=False)
    st.dots([(x, y + 2), (x + 6, y + 2)], UMBER)


def salt_block(st, x, y, s=9, pal=ROCKSALT):
    """An isometric-ish rock-salt cube: front face, lit top face, shaded side, white glints."""
    front = rect(x, y + 3, x + s - 1, y + s + 2)
    top = poly([(x, y + 3), (x + 3, y), (x + s + 2, y), (x + s - 1, y + 3)])
    side = poly([(x + s, y + 3), (x + s + 2.9, y), (x + s + 2.9, y + s), (x + s, y + s + 2.9)])
    m = front | top | side
    st.part(m, pal[0], d=1, contour=True)
    st.paint(top & shrink(m, 1), pal[2])
    st.paint(side & shrink(m, 1) & ~top, pal[1])
    st.dots([(x + 2, y + 5), (x + 3, y + 6), (x + 6, y + 9)], '#ffffff')
    return m


def wink(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y + 1, {'U': UMBER}, solid=False)


def dot_eye(st, x, y):
    """Shy downcast eye: a 4 x 4 cut-corner cream bead with a 2 x 2 pupil sunk to its lower edge (reads on a dark body)."""
    e = rect(x, y, x + 3, y + 3)
    e[y, x] = e[y, x + 3] = False
    st.paint(e, CREAM)
    st.paint(rect(x + 1, y + 2, x + 2, y + 3), UMBER)
    st.dots([(x + 1, y + 2)], '#ffffff')


def pendant(st, cx, y0, chain_w, drop):
    """A gold chain hung in a V across the chest and a long carved salt crystal (hexagonal prism, pointed tip) dangling from it."""
    ch = line([(cx - chain_w, y0), (cx, y0 + 4)]) | line([(cx, y0 + 4), (cx + chain_w, y0)])
    st.paint(ch & ((XX % 2) == 0), GOLD)
    st.paint(ch & ((XX % 2) == 1), GOLD_D)
    cy = y0 + 5
    gem = poly([(cx, cy), (cx + 2.6, cy + 2), (cx + 2.6, cy + drop - 3), (cx, cy + drop), (cx - 2.6, cy + drop - 3), (cx - 2.6, cy + 2)])
    st.part(gem, CRYSTAL[0], d=1, contour=True)
    st.paint(gem & (CX > cx + 0.6) & shrink(gem, 1), CRYSTAL[1])
    st.paint(line([(cx - 1, cy + 2), (cx - 1, cy + drop - 3)]) & gem, CRYSTAL[2])
    st.dots([(int(cx), cy - 1)], GOLD_D)
    return gem


def round_eye(st, cx, cy, r=4.2, look=(0, -1)):
    """Startled eye: a big round cream eye with a small pupil (not the locked eye)."""
    e = disc(cx, cy, r)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, CREAM)
    px, py = int(cx) - 1 + look[0], int(cy) - 1 + look[1]
    st.paint(rect(px, py, px + 1, py + 1), UMBER)
    st.dots([(int(cx) - 2, int(cy) - 2)], '#ffffff')


def sleeper_sash(st, body, y0, y1):
    """A timber rail sleeper strapped across the belly, two iron bolts each end."""
    m = body & (YY >= y0) & (YY <= y1) & shrink(body, 1)
    st.paint(m, SLEEPER[0])
    st.paint(m & (YY == y0), SLEEPER[2])
    st.paint(m & (YY == y1), SLEEPER[1])
    st.paint(m & ((XX % 6) == 0) & (YY > y0) & (YY < y1), SLEEPER[3])               # wood grain cuts
    return m


def bolt(st, x, y):
    st.sprite(['RR', 'RD'], x, y, {'R': RAIL[2], 'D': RAIL[3]}, solid=False)


def rail_tips(st, body, tabs):
    """Iron rail-ends: the tab heads painted rail silver with a dark web line."""
    t = tabs & body
    st.paint(t, '#9aa2ae')
    st.paint(t & ~shift(t, -1, -1), RAIL[3])
    st.paint(t & ~shift(t, 1, 1), RAIL[2])
    st.paint(t & shrink(t, 1) & ((np.abs(CX - 31.5) < 0.6) | (np.abs(CY - 33.5) < 0.6)), RAIL[3])   # the rail-end groove


def salt_arch(st, cx, y, rx, ry, th=3.2):
    """A carved rosy-salt arch over the top of a body (like the gnome hall doorways) with a pink keystone."""
    m = ellipse(cx, y, rx, ry) & ~ellipse(cx, y, rx - th, ry - th) & (CY < y + 0.5)
    st.part(m, ARCH[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1), ARCH[2])
    k = rect(int(cx) - 2, int(y - ry) - 1, int(cx) + 1, int(y - ry) + 2)
    st.part(k, KEY, d=1, contour=True)
    st.dots([(int(cx) - 1, int(y - ry))], '#fbd8e0')
    return m | k


def salt_ring(st, cx, cy, r):
    """The carved rosy-salt frame round a hall roundel: a thick ring, lit upper left, a pink keystone at the top."""
    m = disc(cx, cy, r)
    st.part(m, ARCH[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1) & ~disc(cx, cy, r - 1.2), ARCH[2])
    st.paint(m & ((np.abs(CX - cx) < 0.6) | (np.abs(CY - cy) < 0.6)) & ~disc(cx, cy, r - 2.8), ARCH[1])  # 4 carved joints n e s w
    k = rect(int(cx) - 2, int(cy - r) - 1, int(cx) + 1, int(cy - r) + 2)
    st.part(k, KEY, d=1, contour=True)
    st.dots([(int(cx) - 1, int(cy - r))], '#fbd8e0')
    return m | k


def lit_window(st, cx, cy, r):
    w = disc(cx, cy, r)
    st.paint(grow(w, 1) & ~w, '#8a5a30')
    st.paint(w, '#f5cf6a')
    st.paint(disc(cx - 1.5, cy - 1.5, r - 2.2), '#fff1c8')
    return w


def happy_arc(st, x, y):
    st.sprite(['..UU..', '.U..U.', 'U....U'], x, y, {'U': UMBER}, solid=False)


def note(st, x, y, col=CREAM):
    extra_sprite(st, ['.NNN', '.N.N', '.N.N', 'NN.N', 'NNNN', '...N'][:5], x, y, {'N': col})


# ------------------------------------------------------------------ 1. Brass Hardhat: corner-BB peg, common. Lavender wall pal nodding off under a tilted lamp helmet.
def brass_hardhat():
    key = 'pl-smg-1'
    st = Sticker()
    core = (12, 25, 48, 52)
    body, holes = piece_blanks(core, n='F', w='F', e=('B', 'peg', 2, 2.8), s=('B', 'peg', 0, 2.8))
    st.part(body, tex=fill(key, body, 12, 25, 37, list(LAVW)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY > 29), col='#e8d8d0', skip=grow(holes, 3))
    hardhat(st, 29, 26, w=17, tilt=-1.5)
    extra_sprite(st, ['C...', '.C..', '..C.'], 21, 9, {'C': GOLD_L})                  # lamp rays
    extra_sprite(st, ['..C', '.C.', 'C..'], 35, 9, {'C': GOLD_L})
    extra_sprite(st, ['C', 'C', 'C'], 29, 7, {'C': GOLD_L})
    closed_lash(st, 16, 36)
    closed_lash(st, 31, 35)
    st.sprite(['.UU.', 'URRU', '.UU.'], 26, 41, {'U': UMBER, 'R': MOUTH_RED}, solid=False)   # a small sleepy yawn
    st.paint(rect(15, 40, 17, 40) | rect(38, 39, 40, 39), BLUSH)
    zzz(st, 51, 14)
    zzz(st, 56, 8)
    return key, st


# ------------------------------------------------------------------ 2. Salt Lick: edge-TBB tri, common. Rosy salt pal licking a pink rock-salt block.
def salt_lick():
    key = 'pl-smg-2'
    st = Sticker()
    core = (13, 22, 47, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', -4, 3.6), e=('B', 'tri', 0, 3.0), w=('B', 'tri', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 22, 35, list(ROSY)), contour=True)
    st.blank_shade(body, holes, width=2)
    st.stitch(body, col='#a898a8', skip=grow(holes, 3))
    boots(st, [15, 39], 49, col='#6a5878')
    wink(st, 18, 27)
    st.eye(33, 27, look=(-1, 1))
    st.paint(line([(32, 24), (35, 23), (38, 24)]), UMBER)                              # cocked brow
    st.sprite(['UUUUUU', '.U..U.'], 24, 35, {'U': UMBER}, solid=False)
    salt_block(st, 30, 38, s=10)
    tg = rect(26, 37, 29, 40) | rect(27, 41, 30, 41)
    st.paint(tg, TONGUE)
    st.paint(rect(27, 37, 27, 39), '#f4a8b0')
    st.paint(rect(29, 38, 29, 40), '#c85a6a')
    st.part(ellipse(26, 45, 3.2, 2.4), ROSY[0], d=1, contour=True)                       # a stubby arm hugging the block
    st.part(ellipse(45, 45, 2.6, 2.4), ROSY[0], d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 3. Crystal Pendant: inner-TBTB round, common. Indigo doorway pal wearing a salt crystal, shy.
def crystal_pendant():
    key = 'pl-smg-3'
    st = Sticker()
    core = (16, 19, 46, 45)
    body, holes = piece_blanks(core, n=('T', 'round', 3, 3.4), e=('B', 'round', 0, 3.0), s=('T', 'round', 0, 3.4), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 16, 19, 31, list(INDIGO)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f5b860', skip=grow(holes, 3))
    boots(st, [17, 39], 46, col='#2a1d2e')
    dot_eye(st, 21, 26)
    dot_eye(st, 36, 26)
    st.paint(rect(18, 31, 21, 32) | rect(37, 31, 40, 32), BLUSH)
    st.sprite(['.U.U.U.', 'U.U.U.U'], 27, 31, {'U': CREAM}, solid=False)   # tiny wavy mouth (cream on dark)
    pendant(st, 31, 33, 8, 13)
    extra_sprite(st, ['C...', '..C.', 'C...'], 39, 41, {'C': '#ffffff'})            # tinkle round the crystal
    extra_sprite(st, ['.C', '..', 'C.'], 25, 42, {'C': '#ffffff'})
    return key, st


# ------------------------------------------------------------------ 4. Railtrack Rattle: inner-TTTT double, uncommon. Steel pal, four rail-iron tabs, startled by its own rattle.
def railtrack_rattle():
    key = 'pl-smg-4'
    st = Sticker()
    core = (17, 20, 45, 46)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 20, 29, list(STEEL)), contour=True)
    tabs = body & ~rect(17, 20, 45, 46)
    rail_tips(st, body, tabs & ~grow(rect(17, 20, 45, 46), 2))
    st.stitch(rect(17, 20, 45, 46) & body, col=SLEEPER[2])                              # uncommon accent: timber
    sleeper_sash(st, body, 38, 42)
    for x in (19, 41):
        bolt(st, x, 39)
    round_eye(st, 24, 29)
    round_eye(st, 38, 29)
    st.paint(line([(20, 22), (24, 21), (27, 22)]) | line([(35, 22), (38, 21), (42, 22)]), UMBER)
    st.mouth('o', 30, 34)
    extra_sprite(st, ['C.C', '...', 'C.C'], 9, 9, {'C': CREAM})                       # rattle ticks at the corners
    extra_sprite(st, ['C.C', '...', 'C.C'], 52, 9, {'C': CREAM})
    extra_sprite(st, ['C.C', '...', 'C.C'], 9, 52, {'C': CREAM})
    extra_sprite(st, ['C.C', '...', 'C.C'], 52, 52, {'C': CREAM})
    return key, st


# ------------------------------------------------------------------ 5. Salthall Roundel: inner-BBBB peg, uncommon. Honey hall pal, carved arch, round lit window, smug.
def salthall_roundel():
    key = 'pl-smg-5'
    st = Sticker()
    core = (13, 18, 49, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 0, 3.0), e=('B', 'peg', 0, 3.0), s=('B', 'peg', 0, 3.0), w=('B', 'peg', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 18, 37, list(HONEY)), contour=True)
    st.blank_shade(body, holes, width=2)
    st.stitch(body & (YY > 26), col=KEY, skip=grow(holes, 3))                           # uncommon accent: keystone pink
    salt_ring(st, 31, 32, 12.5)
    lit_window(st, 31, 32, 9.6)
    st.eye(22, 27, look=(1, 0), lid=2)
    st.eye(34, 27, look=(1, 0), lid=2)
    st.paint(line([(34, 23), (37, 22), (39, 23)]), UMBER)
    st.mouth('smirk', 28, 35)
    st.paint(rect(21, 34, 23, 34) | rect(39, 34, 40, 34), BLUSH)
    extra_sprite(st, ['.C', 'C.', '.C'], 7, 26, {'C': '#fff1c8'})                       # warm wisps, like a fresh bun
    extra_sprite(st, ['C.', '.C', 'C.'], 55, 26, {'C': '#fff1c8'})
    return key, st


# ------------------------------------------------------------------ 6. Saltblock Minecart: whimsy-minecart tri, rare. A singing mine cart piled with salt blocks.
def saltblock_minecart():
    key = 'pl-smg-6'
    st = Sticker()
    cart = poly([(9, 30), (47, 30), (44, 48), (12, 48)])
    tab = knob('e', 'tri', 39, 46, r=3.2)
    wheels = disc(18, 50, 4.2) | disc(38, 50, 4.2)
    blocks = []
    for x, y, s in ((11, 21, 9), (24, 18, 10), (34, 22, 8)):
        blocks.append((x, y, s))
    for x, y, s in blocks:
        salt_block(st, x, y, s=s, pal=ARCH)
    salt_block(st, 19, 13, s=7, pal=ROCKSALT)
    body = cart | tab
    st.part(body, tex=fill(key, body, 9, 25, 38, list(TIMBER)), contour=True)
    st.paint(cart & (YY >= 30) & (YY <= 32), GOLD)                                      # gold rim band
    st.paint(cart & (YY == 32), GOLD_D)
    st.paint(cart & ((XX == 13) | (XX == 43)) & (YY > 32) & shrink(cart, 1), '#6a3420')  # corner straps
    st.stitch(cart & (YY > 33), col='#f4cc80')
    for cx in (18, 38):
        st.part(disc(cx, 50, 4.2), WHEEL[0], d=1, contour=True)
        st.paint(disc(cx, 50, 1.5), WHEEL[2])
    happy_arc(st, 17, 36)
    happy_arc(st, 32, 36)
    st.paint(rect(15, 41, 17, 41) | rect(38, 41, 40, 41), BLUSH)
    st.sprite(['UUUUUU', 'URRRRU', '.URRU.', '..UU.'], 24, 40, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    note(st, 52, 13)
    st.sparkle(6, 6)
    st.sparkle(46, 8, big=False)
    st.sparkle(53, 24, big=False)
    return key, st


PALS = [brass_hardhat, salt_lick, crystal_pendant, railtrack_rattle, salthall_roundel, saltblock_minecart]

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
