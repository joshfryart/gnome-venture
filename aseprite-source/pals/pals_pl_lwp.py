"""Puzzle Pals: THE LONG WALL WALK (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-lwp-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_lwp.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built on palib + kit_lair (PlacePic, rows, cell_fill, calm_tones, tidy) as building blocks only; every accessory here is drawn for this roster.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/delve-the-long-wall-walk.png,
calmed onto 2 tones of a pal-own colour family from the picture so the face reads. Delve mood: cosy-curious, never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Sentry Straw       ridge sage green        | conical straw hat tied with a red cord + knot tails      | grumpy on-duty: low brows, side look, flat mouth
  2 Brick Counter      wall-stone grey         | gold round spectacles, chalk tally marks, a chalk stick | startled (lost count): wide eyes, brows up, gasp O
  3 Autumn Flutter     autumn leaf orange      | leaf veins + curled stem, gale swooshes, drifting flecks | cheeky: wink arc + one eye, open grin
  4 Battlement Whistle walkway sandstone (+red)| four merlons along its head, music notes, wind lines   | sleepy: closed arcs, tiny whistling pucker
  5 Galeswing Lantern  lantern crimson (+gold) | gold lantern caps, ribs, tilted hanger string, swung tassel | smug: half-lidded bead eyes, smirk
  6 Lookout Turret     tower navy roofs, gold storey (rare) | whimsy watchtower: two upturned roofs, finial, red banner, a perched bird | shy: arched window eyes looking down, blush
Ring/Plus/TBTB blanks and tabs are mirror-placed (n, s centred; e, w at the same height). Peg/hook blanks kept small.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import PlacePic, rows, cell_fill, calm_tones, tidy  # noqa: E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-the-long-wall-walk'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-the-long-wall-walk-7eadc6')

SAGE = ('#5e8e80', '#78a898')
STONE = ('#949ca0', '#b0b6b8')
LEAF = ('#d0862a', '#e8a040')
SANDST = ('#c8b088', '#dcc8a0')
CRIMSON = ('#a8242a', '#c83a32')
NAVY = ('#293750', '#3e5a78')
STRAW = ('#e8c26a', '#c99a48', '#f9e0a0')
CORD = '#d6322b'
GOLDF = ('#e8a317', '#b07a10', '#f5cf6a')
CHALK = '#f4f0e0'
BLUSH = '#f0a0a0'
WIND = '#eef6fa'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


def boots(st, xs, y, w=6, h=3, col=SHOE[0]):
    for x in xs:
        sh = rect(x, y, x + w - 1, y + h - 1)
        sh[y, x] = sh[y, x + w - 1] = False
        st.part(sh, col, d=1, contour=True)


def extra_sprite(st, rows_, x, y, col):
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch != '.':
                st.px[y + j, x + i] = hx(col)
                st.extra[y + j, x + i] = True


def swoosh(st, x, y, L):
    """A gale streak: a 1 px cream line with a curled tail (border only, floats beside the pal)."""
    extra_sprite(st, ['.' * 2 + 'W' * (L - 2), 'W' + '.' * (L - 1)], x, y, WIND)


def note(st, x, y):
    extra_sprite(st, ['.NN', '.N.', 'NN.', 'NN.'], x, y, CHALK)


# ------------------------------------------------------------------ 1. Sentry Straw: corner-BB round, common. Ridge sage, a big straw hat tied on with red cord.
def sentry_straw():
    key = 'pl-lwp-1'
    st = Sticker()
    core = (12, 26, 44, 50)
    body, holes = piece_blanks(core, n='F', w='F', e=('B', 'round', 3, 2.8), s=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 26, 33, SAGE), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY > 28), col='#c8e0d0', skip=grow(holes, 3))
    boots(st, [14, 38], 51)
    # red cord from the brim down round the chin to a knot with two tails
    st.paint(line([(14, 27), (17, 44)]) | line([(42, 27), (39, 44)]), CORD)
    # the conical straw hat, a little wider than the piece
    hat = poly([(7, 27), (28, 7), (30, 7), (51, 27)]) | rect(7, 26, 51, 28)
    st.part(hat, STRAW[0], d=1, contour=True)
    st.paint(hat & shrink(hat, 1) & ((XX + YY) % 4 == 0) & (YY < 25), STRAW[1])        # weave
    st.paint(hat & shrink(hat, 1) & ((XX - YY) % 4 == 0) & (YY < 25) & (YY > 12), STRAW[2])
    st.paint(hat & (YY >= 22) & (YY <= 23), CORD)                                         # red band
    st.paint(hat & (YY == 28), STRAW[1])
    st.sprite(['.R.', 'RRR', 'R.R'], 16, 44, {'R': CORD}, solid=False)
    st.eye(18, 31, look=(1, 0), lid=1)
    st.eye(31, 31, look=(1, 0), lid=1)
    st.paint(line([(17, 29), (23, 30)]) | line([(30, 30), (36, 29)]), UMBER)              # stern brows
    st.sprite(['UUUUU'], 24, 39, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 2. Brick Counter: edge-TBB peg, common. Wall-stone grey, spectacles, chalk tallies.
def brick_counter():
    key = 'pl-lwp-2'
    st = Sticker()
    core = (15, 22, 47, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.6), e=('B', 'peg', 2, 3.0), w=('B', 'peg', 2, 3.0))
    st.part(body, tex=fill(key, body, 15, 22, 33, STONE), contour=True)
    st.blank_shade(body, holes, width=1)
    inner = shrink(body, 2)
    # brick courses on the peg and the hem only (the face stays clear)
    mort = inner & (((YY - 1) % 5 == 0) | (((XX + 4 * ((YY - 1) // 5 % 2)) % 8 == 0))) & ((YY < 22) | (YY > 44))
    st.paint(mort, '#7a8286')
    st.stitch(body & (YY < 45) & (YY > 22), col='#dfe4e6', skip=grow(holes, 3))
    boots(st, [17, 39], 51)
    # gold round spectacles
    for cx in (22.5, 37.5):
        ring = disc(cx, 33.5, 5.4) & ~disc(cx, 33.5, 4.2)
        st.paint(ring, GOLDF[0])
        st.paint(ring & (CX + CY > cx + 33.5 + 2), GOLDF[1])
    st.paint(rect(28, 32, 32, 32), GOLDF[0])
    st.eye(20, 31)
    st.eye(35, 31)
    st.paint(line([(18, 25), (21, 24), (24, 25)]) | line([(36, 25), (39, 24), (42, 25)]), UMBER)   # brows shot up
    st.sprite(['.UUU.', 'URRRU', 'URRRU', '.UUU.'], 27, 40, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    # chalk tally on its tummy: four strokes and a slash
    for x in (36, 38, 40, 42):
        st.paint(rect(x, 41, x, 45), CHALK)
    st.paint(line([(35, 45), (43, 41)]), CHALK)
    # a chalk stick held out on the left
    st.part(ellipse(14, 46, 3, 2.2), STONE[0], d=1, contour=True)
    st.part(rect(7, 45, 11, 46), CHALK, d=0, contour=True)
    return key, st


# ------------------------------------------------------------------ 3. Autumn Flutter: inner-TBTB tri, common. A leaf riding the gale: tri tip up, stem down, winking.
def autumn_flutter():
    key = 'pl-lwp-3'
    st = Sticker()
    core = (17, 22, 45, 45)
    body, holes = piece_blanks(core, n=('T', 'tri', 0, 4.2), s=('T', 'tri', 0, 2.6), e=('B', 'tri', 1, 2.6), w=('B', 'tri', 1, 2.6))
    st.part(body, tex=fill(key, body, 17, 22, 29, LEAF), contour=True)
    st.blank_shade(body, holes, width=1)
    vein = '#a8582a'
    st.paint(body & (XX == 31) & ((YY < 27) | (YY > 44)), vein)
    st.paint((line([(31, 20), (26, 17)]) | line([(31, 20), (36, 17)]) | line([(31, 48), (25, 45)]) | line([(31, 48), (37, 45)])) & shrink(body, 1), vein)
    st.stitch(body, col='#fbd890', skip=grow(holes, 3) | (XX == 31))
    # curled stem off the bottom tab
    st.part(line([(31, 52), (32, 54), (35, 54), (36, 52)], 2), '#7a4a1f', d=0, contour=True)
    st.sprite(['.UUU.', 'U...U'], 20, 31, {'U': UMBER}, solid=False)                    # winking eye
    st.eye(33, 29, look=(-1, -1))
    st.sprite(['UUUUUUU', 'URRRRRU', '.UCRRU.', '..UUU..'], 24, 37, {'U': UMBER, 'R': MOUTH_RED, 'C': '#e88a8a'}, solid=False)
    st.paint(rect(18, 36, 20, 36) | rect(40, 36, 42, 36), BLUSH)
    swoosh(st, 4, 14, 9)
    swoosh(st, 6, 40, 7)
    swoosh(st, 50, 50, 8)
    extra_sprite(st, ['.O', 'OO'], 52, 12, '#d6322b')                                     # drifting autumn flecks
    extra_sprite(st, ['OO', 'O.'], 8, 52, '#f08a24')
    return key, st


# ------------------------------------------------------------------ 4. Battlement Whistle: inner-TTTT double, uncommon. Sandstone, 4 merlons on its head, whistling asleep.
def battlement_whistle():
    key = 'pl-lwp-4'
    st = Sticker()
    core = (17, 25, 45, 48)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 25, 29, SANDST), contour=True)
    st.stitch(body & (YY > 28), col=CORD)                                                  # uncommon accent: the wall's red cord
    # four stubby merlons along its head, two either side of the top knob
    mer = blank()
    for x in (17, 22, 36, 41):
        mer |= rect(x, 20, x + 3, 27)
    st.part(mer, '#b8a478', d=1, contour=True)
    st.paint(mer & (YY == 20), '#e8dcb8')
    st.paint(mer & (YY == 24), '#8e7c58')
    st.sprite(['UU...UU', '.UUUUU.'], 20, 33, {'U': UMBER}, solid=False)                 # closed sleepy eyes
    st.sprite(['UU...UU', '.UUUUU.'], 34, 33, {'U': UMBER}, solid=False)
    st.paint(rect(19, 37, 21, 37) | rect(39, 37, 41, 37), BLUSH)
    st.sprite(['.U.', 'URU', '.U.'], 34, 40, {'U': UMBER, 'R': MOUTH_RED}, solid=False)   # tiny pucker, off to one side
    note(st, 52, 10)
    note(st, 56, 21)
    swoosh(st, 5, 17, 7)
    swoosh(st, 5, 46, 6)
    return key, st


# ------------------------------------------------------------------ 5. Galeswing Lantern: inner-BBBB peg, uncommon. Crimson lantern body, gold caps, swung on its string, smug.
def galeswing_lantern():
    key = 'pl-lwp-5'
    st = Sticker()
    core = (14, 19, 47, 49)
    body, holes = piece_blanks(core, n=('B', 'peg', 0, 2.8), e=('B', 'peg', 0, 2.8), s=('B', 'peg', 0, 2.8), w=('B', 'peg', 0, 2.8))
    # hanger string swung sideways by the gale
    hang = line([(38, 5), (31, 12)])
    st.paint(hang, GOLDF[2])
    st.extra |= hang
    st.part(rect(30, 13, 32, 16), GOLDF[0], d=0, contour=True)
    st.part(body, tex=fill(key, body, 14, 19, 34, CRIMSON), contour=True)
    st.blank_shade(body, holes, width=1)
    caps = body & ((YY <= 22) | (YY >= 46))
    st.paint(caps, GOLDF[0])
    st.paint(caps & ((YY == 22) | (YY == 49)), GOLDF[1])
    st.paint(caps & ((YY == 19) | (YY == 46)), GOLDF[2])
    st.paint(body & ((XX == 19) | (XX == 42)) & (YY > 22) & (YY < 46), '#7a1a24')         # lantern ribs
    st.stitch(body & (YY > 23) & (YY < 45), col=GOLDF[2], skip=grow(holes, 3))           # uncommon accent: lantern gold
    # tassel swung the other way
    st.paint(line([(26, 50), (23, 53)]), GOLDF[0], solid=True)
    st.part(poly([(19, 52), (24, 52), (23, 56), (18, 56)]), CORD, d=0, contour=True)
    for x in (22, 35):                                                                     # half-lidded bead eyes
        st.sprite(['.UUU.', 'UUUUU', 'UCUUU', '.UUU.'], x, 30, {'U': UMBER, 'C': CREAM}, solid=False)
        st.paint(rect(x, 29, x + 4, 30), '#7a1a24')
        st.paint(rect(x, 31, x + 4, 31), UMBER2)
    st.sprite(['......U', 'UUUUUU.'], 26, 39, {'U': UMBER}, solid=False)
    st.paint(rect(20, 37, 22, 37) | rect(39, 37, 41, 37), GOLDF[2])                      # warm glow cheeks
    return key, st


# ------------------------------------------------------------------ 6. Lookout Turret: whimsy-watchtower hook, rare. A tiny pagoda watchtower with a banner and a bird friend.
def lookout_turret():
    key = 'pl-lwp-6'
    st = Sticker()
    finial = rect(30, 11, 32, 16) | disc(31.5, 10.5, 2.0)
    roof1 = poly([(16, 23), (21, 19), (25, 17), (38, 17), (42, 19), (47, 23), (43, 22), (20, 22)])
    store = rect(21, 22, 42, 27)
    roof2 = poly([(12, 32), (17, 27), (21, 25), (42, 25), (46, 27), (51, 32), (47, 31), (16, 31)])
    tower = rect(16, 31, 47, 51)
    tower[51, 16] = tower[51, 47] = False
    tab = knob('e', 'hook', 42, 48, r=2.8)
    roofs = roof1 | roof2
    body = finial | roofs | store | tower | tab
    t = cell_fill(pic, ROWS[key]['piece'], body, 12, 9, 42, 3, 3)
    st.part(finial, GOLDF[0], d=1, contour=True)
    st.part(store | tower | tab, tex=calm_tones(t, store | tower | tab, ['#d8a848', '#f0c860']), contour=True)
    st.part(roofs, tex=calm_tones(t, roofs, list(NAVY)), contour=True)
    st.paint(roofs & ((YY == 22) | (YY == 31)) & (XX % 3 != 0), GOLDF[0])               # gold trim dashes on the eaves
    st.paint(roofs & ((YY == 17) | (YY == 25)), '#4e8a9a')
    st.paint(tower & ((XX <= 18) | (XX >= 45)) & (YY > 31), CORD)                          # red pillars
    st.paint(store & ((XX == 25) | (XX == 31) | (XX == 37)), '#b07a10')
    st.stitch(tower & (YY > 32), col='#fff3c8', skip=grow(tab, 2))
    # banner streaming from the finial
    st.paint(line([(33, 12), (36, 11)]), UMBER2, solid=True)
    st.part(poly([(35, 9), (42, 10), (46, 9), (45, 13), (40, 14), (35, 14)]), CORD, d=0, contour=True)
    st.paint(line([(37, 11), (42, 12)]), '#f08a24')
    # a little bird perched on the lower eave
    st.sprite(['..BB..', '.BBBBk', 'BBWBB.', '.BBB..', '..y.y.'], 45, 21, {'B': '#5a6aa0', 'W': CREAM, 'k': GOLDF[0], 'y': GOLDF[1]})
    st.dots([(48, 22)], UMBER)
    # shy arched-window eyes looking down
    for x in (21, 36):
        st.sprite(['.UUU.', 'UCCCU', 'UCCCU', 'UUUUU', 'UUUUU'], x, 36, {'U': UMBER, 'C': CREAM}, solid=False)
        st.dots([(x + 1, 37)], '#ffffff')
        st.paint(rect(x + 1, 39, x + 3, 40), UMBER)
    st.paint(rect(19, 43, 21, 43) | rect(41, 43, 43, 43), BLUSH)
    st.sprite(['U.U', '.U.'], 30, 44, {'U': UMBER}, solid=False)
    st.paint(rect(27, 47, 36, 51) & ~rect(27, 47, 27, 47) & ~rect(36, 47, 36, 47), '#6a3a1a')   # the tower door
    st.paint(rect(28, 48, 35, 48), '#8a5a2a')
    st.sparkle(5, 12)
    st.sparkle(53, 6, big=False)
    st.sparkle(5, 40, big=False)
    return key, st


PALS = [sentry_straw, brick_counter, autumn_flutter, battlement_whistle, galeswing_lantern, lookout_turret]

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
        print('%-10s %-19s %-9s %-18s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
