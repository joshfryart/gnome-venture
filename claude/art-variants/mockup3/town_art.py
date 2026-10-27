"""Mockup 3: felt-card art for the main-stop (town) page.
A copy-on-import of mockup2/gather_b.py: it loads that module, registers new vignettes in its TOOLS table and
reuses its card()/vignette()/felt9()/ribbon9()/badge() pipeline, so the new art matches the Gather/Do cards exactly
(same 72x54 framed window, umber 3-tone outline, light upper left, saved 2x).

Vignettes, one per town_spots.kind (includes/town.php ensure_towns) plus the specials the mock shows (towns.txt S lines)
and one per shops.shop_type the Shops tab lists:
  place-green place-teahouse place-board place-library        the four places every town has
  place-grind place-monastery (Spicepeak) place-stones place-pub (Mistmoor)   specials shown in the mock
  place-special                                               fallback for the other specials until each gets its own
  shop-seeds shop-food shop-florist shop-dyes shop-decor
New parts: felt-gold.png (gold-stitched felt for "found only here" places), badge-star.png, badge-repair.png.
Felt idle/sel/off, ribbons and the sel/lock/done badges are mockup2's own files (../mockup2/art), not copied.
Usage: PYTHONHASHSEED=0 python3 claude/art-variants/mockup3/town_art.py   (writes to mockup3/art/)"""
import os, sys, importlib.util
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'art')
os.makedirs(OUT, exist_ok=True)
spec = importlib.util.spec_from_file_location('gather_b', os.path.join(HERE, '..', 'mockup2', 'gather_b.py'))
gb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gb)
from types import SimpleNamespace
rect, ell, poly, line, item, gnome, C, GN = gb.rect, gb.ell, gb.poly, gb.line, gb.item, gb.gnome, gb.C, gb.GN
GY = gb.GY
tool = gb.tool
WOOD, WOODD, WOODR = '#a06a3a', '#74462a', '#c08a52'


def villager(c, x, y, flip=True, **look):
    """A second figure with its own colours (as v_chat in gather_b)."""
    keep = dict(GN)
    GN.update(look)
    gnome(c, x, y, flip=flip)
    GN.clear(); GN.update(keep)


def wall(c, col, shade, floor=('#8a5a30', '#6b4a2e')):
    """Indoor scene: plaster wall over the whole window, a skirting line and plank floor."""
    c.f(rect(14, 14, 81, GY - 1), col)
    for y in range(18, GY - 2, 6):
        c.f(rect(14, y, 81, y), shade)
    c.f(rect(14, GY, 81, 63), floor[0])
    c.f(rect(14, GY, 81, GY), floor[1])
    for x in range(18, 82, 9):
        c.f(rect(x, GY + 1, x, 63), floor[1])


# ------------------------------------------------------------------ the four places every town has
@tool('place-green')
def v_green(c):
    pond = ell(56, GY - 3, 84, GY + 7)
    c.f(pond, '#4a88b0'); c.f(rect(60, GY, 66, GY) | rect(70, GY + 3, 76, GY + 3), '#8cc4dc')
    duck = ell(66, GY - 5, 72, GY - 1) | ell(70, GY - 8, 73, GY - 5)
    item(c, duck, '#f4eee0', '#cfc6b0'); c.f(rect(74, GY - 7, 75, GY - 7), '#e8a317'); c.f(rect(72, GY - 7, 72, GY - 7), '#2a1a10')
    trunk = rect(22, GY - 20, 25, GY)
    crown = ell(12, GY - 38, 36, GY - 16)
    c.outline(trunk | crown)
    c.shaded(trunk, '#8a5a2e', '#5a3a1e'); c.shaded(crown, '#4e8a3c', '#386a2a', '#6aa84a', 2)
    c.f(rect(18, GY - 30, 19, GY - 29) | rect(28, GY - 25, 29, GY - 24), '#c03a4a')   # blossom
    bench = rect(32, GY - 6, 52, GY - 4) | rect(34, GY - 4, 35, GY) | rect(49, GY - 4, 50, GY) | rect(32, GY - 12, 52, GY - 11)
    item(c, bench, WOOD, WOODD)
    gnome(c, 40, GY - 6, pose='sit')


@tool('place-teahouse', 'dusk')
def v_tea(c):
    wall(c, '#e3c48c', '#d4b07a')
    win = rect(20, 20, 36, 34)
    c.outline(win); c.f(win, '#f4cf98'); c.f(rect(28, 20, 28, 34) | rect(20, 27, 36, 27), WOODD)
    c.f(ell(30, 23, 34, 27), '#f4c84a')
    shelf = rect(44, 24, 76, 25)
    item(c, shelf, WOOD, WOODD)
    for i, col in enumerate(('#c0442e', '#4a6e9a', '#4e8a3c', '#e8a317')):
        cup = rect(46 + i * 8, 20, 49 + i * 8, 23)
        item(c, cup, col, '#2a1a10')
    table = rect(44, GY - 10, 74, GY - 9) | rect(58, GY - 9, 60, GY)
    item(c, table, WOOD, WOODD)
    pot = ell(48, GY - 18, 57, GY - 11) | line([(57, GY - 15), (61, GY - 18)], 1) | rect(51, GY - 20, 54, GY - 19)
    item(c, pot, '#c0442e', '#8e2e1e')
    cup = rect(64, GY - 14, 68, GY - 11)
    item(c, cup, '#f4eee0', '#cfc6b0')
    c.f(rect(65, GY - 18, 65, GY - 17) | rect(67, GY - 21, 67, GY - 20) | rect(52, GY - 25, 52, GY - 24) | rect(54, GY - 28, 54, GY - 27), '#ffffff')
    gnome(c, 36, GY)


@tool('place-board')
def v_board(c):
    posts = rect(44, GY - 28, 46, GY) | rect(74, GY - 28, 76, GY)
    item(c, posts, '#8a5a2e', '#5a3a1e')
    board = rect(40, GY - 30, 80, GY - 10)
    c.outline(board); c.shaded(board, WOOD, WOODD, WOODR, 1)
    roof = poly([(38, GY - 31), (60, GY - 38), (82, GY - 31)])
    item(c, roof, '#8e3c2a', '#6e2c1e')
    notes = [(43, GY - 27, 52, GY - 19, '#f4eee0'), (55, GY - 28, 63, GY - 21, '#f5cf6a'), (66, GY - 27, 77, GY - 20, '#a9d6ea'),
             (46, GY - 17, 56, GY - 12, '#f5cf6a'), (60, GY - 18, 70, GY - 12, '#f4eee0')]
    for x0, y0, x1, y1, col in notes:
        n = rect(x0, y0, x1, y1)
        c.f(n, col); c.f(rect(x0, y1, x1, y1), '#cfc6b0')
        for yy in range(y0 + 2, y1 - 1, 2):
            c.f(rect(x0 + 2, yy, x1 - 2, yy), '#8a8478')
        c.f(rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y0), '#c0442e')
    gnome(c, 30, GY)


@tool('place-library')
def v_library(c):
    wall(c, '#74462a', '#5c3420', ('#4a2c1a', '#2a1a10'))
    case = rect(16, 16, 50, GY)
    c.f(case, '#5c3420')
    rng = np.random.default_rng(7)
    cols = ['#c0442e', '#4a6e9a', '#4e8a3c', '#e8a317', '#7a5cc0', '#f4eee0', '#a8241f', '#25637d']
    for sy in (17, 26, 35, 44):
        x = 18
        while x < 48:
            w = int(rng.integers(2, 4)); h = int(rng.integers(5, 8))
            c.f(rect(x, sy + 8 - h, min(x + w - 1, 48), sy + 7), cols[int(rng.integers(0, len(cols)))])
            x += w + int(rng.random() < .25)
        c.f(rect(16, sy + 8, 50, sy + 8), WOODR)
    c.outline(case)
    stand = poly([(66, GY), (68, GY - 12), (70, GY - 12), (72, GY)])
    item(c, stand, WOOD, WOODD)
    book = rect(60, GY - 17, 78, GY - 13)
    item(c, book, '#f4eee0', '#cfc6b0')
    c.f(rect(69, GY - 17, 69, GY - 13), '#8a8478'); c.f(rect(62, GY - 16, 67, GY - 16) | rect(71, GY - 16, 76, GY - 16) | rect(62, GY - 14, 66, GY - 14) | rect(71, GY - 14, 75, GY - 14), '#8a8478')
    c.f(rect(60, GY - 12, 78, GY - 12), '#8e3c2a')
    lamp = rect(76, 22, 78, 26)
    c.f(lamp, '#f4c84a'); c.f(rect(77, 16, 77, 21), '#2a1a10')
    gnome(c, 56, GY)


# ------------------------------------------------------------------ specials in the mock
@tool('place-grind')
def v_grind(c):
    for i in range(0, 68, 8):   # striped awning
        c.f(rect(14 + i, 14, 17 + i, 20), '#c0442e'); c.f(rect(18 + i, 14, 21 + i, 20), '#f4eee0')
    c.f(rect(14, 21, 81, 21), '#8e2e1e')
    for i, (x, heap) in enumerate(((50, '#e8a317'), (66, '#c0442e'))):
        bowl = ell(x, GY - 9, x + 13, GY + 1) & rect(0, GY - 5, 95, GY)
        c.outline(bowl); c.shaded(bowl, '#8a8a92', '#62626c', '#aaaab2', 1)
        h = ell(x + 2, GY - 9, x + 11, GY - 3) & rect(0, 0, 95, GY - 5)
        c.f(h, heap)
    sack = poly([(16, GY), (19, GY - 16), (29, GY - 16), (31, GY)])
    item(c, sack, '#c89050', '#946434')
    c.f(ell(19, GY - 19, 29, GY - 14) & rect(0, 0, 95, GY - 16), '#4e8a3c')
    gnome(c, 41, GY)
    item(c, line([(45, GY - 5), (54, GY - 12)], 1), '#cfc6b0', '#8a8478')
    c.f(rect(56, GY - 14, 56, GY - 14) | rect(58, GY - 17, 58, GY - 17) | rect(70, GY - 22, 70, GY - 22), '#e8a317')


@tool('place-monastery')
def v_monastery(c):
    mtn = poly([(14, GY), (40, 18), (70, GY)])
    c.outline(mtn); c.shaded(mtn, '#8a8a92', '#62626c', '#aaaab2', 2)
    snow = poly([(32, 28), (40, 18), (48, 28), (44, 26), (40, 29), (36, 26)])
    c.f(snow, '#f4eee0')
    hall = rect(54, GY - 14, 74, GY)
    roof = poly([(51, GY - 14), (64, GY - 22), (77, GY - 14)])
    c.outline(hall | roof)
    c.shaded(hall, '#f4eee0', '#cfc6b0'); c.shaded(roof, '#a8241f', '#7a1a16')
    c.f(rect(63, GY - 25, 64, GY - 22), '#e8a317')
    c.f(rect(62, GY - 8, 66, GY), '#74462a'); c.f(rect(57, GY - 11, 59, GY - 9) | rect(69, GY - 11, 71, GY - 9), '#74462a')
    c.f(line([(14, 22), (82, 30)]), '#4a2c1a')
    flags = ['#4a6e9a', '#f4eee0', '#c0442e', '#4e8a3c', '#f4c84a']
    for i, x in enumerate(range(17, 80, 6)):
        y = 22 + (x - 14) * 8 // 68
        c.f(rect(x, y + 1, x + 3, y + 4), flags[i % 5])
    gnome(c, 30, GY, pose='sit')


@tool('place-stones')
def v_stones(c):
    c.f(rect(14, 40, 81, 46), '#dfe9ea')   # mist
    for x, h, w in ((22, 18, 6), (34, 24, 7), (56, 24, 7), (70, 16, 6)):
        s = rect(x, GY - h, x + w, GY)
        c.outline(s); c.shaded(s, '#8a8a92', '#62626c', '#aaaab2', 1)
    lintel = rect(32, GY - 28, 65, GY - 25)
    c.outline(lintel); c.shaded(lintel, '#8a8a92', '#62626c', '#aaaab2', 1)
    c.f(rect(73, GY - 18, 74, GY - 17) | rect(25, GY - 20, 26, GY - 19), '#e8a317')   # coins left for luck
    gnome(c, 48, GY)


@tool('place-pub', 'night')
def v_pub(c):
    wall(c, '#7a4a1f', '#5c3420', ('#4a2c1a', '#2a1a10'))
    hearth = rect(18, GY - 22, 40, GY)
    c.outline(hearth); c.shaded(hearth, '#8a8a92', '#62626c', '#aaaab2', 1)
    c.f(rect(22, GY - 14, 36, GY), '#2a1a10')
    fl = poly([(23, GY), (27, GY - 11), (29, GY - 6), (31, GY - 12), (35, GY)])
    c.f(fl, '#e8602e'); c.f(poly([(26, GY), (29, GY - 7), (32, GY)]), '#f4c84a')
    beam = rect(14, 16, 81, 18)
    item(c, beam, '#5a3a1e', '#2a1a10')
    table = rect(46, GY - 9, 70, GY - 8) | rect(57, GY - 8, 59, GY)
    item(c, table, WOOD, WOODD)
    for x in (50, 62):
        mug = rect(x, GY - 15, x + 4, GY - 10)
        item(c, mug, '#e8a317', '#b07a10'); c.f(rect(x, GY - 16, x + 4, GY - 16), '#f4eee0')
    gnome(c, 44, GY)
    villager(c, 74, GY, hat='#4e8a3c', hatd='#386a2a', coat='#a0603a', coatd='#74462a', beard='#c8a070', beardd='#a07c50')


@tool('place-special')
def v_special(c):
    """Fallback for specials without their own art yet: a signpost with a gold star, a little flag and a path."""
    path = poly([(40, 63), (48, GY), (58, GY), (70, 63)])
    c.f(path, '#c9a46a')
    post = rect(50, GY - 26, 52, GY)
    item(c, post, '#8a5a2e', '#5a3a1e')
    arm = poly([(38, GY - 22), (62, GY - 22), (66, GY - 19), (62, GY - 16), (38, GY - 16)])
    item(c, arm, WOOD, WOODD)
    star = poly([(51, GY - 38), (53, GY - 33), (58, GY - 33), (54, GY - 30), (56, GY - 25), (51, GY - 28), (46, GY - 25), (48, GY - 30), (44, GY - 33), (49, GY - 33)])
    c.outline(star); c.shaded(star, '#f4c84a', '#c89a2a', '#fff2b0')
    gnome(c, 30, GY)


# ------------------------------------------------------------------ shops (shops.shop_type)
def awning(c, a, b):
    for i in range(0, 68, 8):
        c.f(rect(14 + i, 14, 17 + i, 21), a); c.f(rect(18 + i, 14, 21 + i, 21), b)
    for i in range(0, 68, 4):
        c.f(rect(15 + i, 22, 16 + i, 22), a if (i // 4) % 2 == 0 else b)


@tool('shop-seeds')
def v_seeds(c):
    awning(c, '#4e8a3c', '#f4eee0')
    villager(c, 70, GY - 7, hat='#4e8a3c', hatd='#386a2a')
    counter = rect(16, GY - 10, 80, GY)
    c.outline(counter); c.shaded(counter, WOOD, WOODD, WOODR, 1)
    for i, col in enumerate(('#c0442e', '#e8a317', '#4a6e9a', '#7a5cc0')):
        p = rect(20 + i * 10, GY - 18, 26 + i * 10, GY - 11)
        item(c, p, col, '#2a1a10'); c.f(rect(22 + i * 10, GY - 16, 24 + i * 10, GY - 14), '#f4eee0')
    for x in (24, 46, 68):
        c.f(rect(x, GY - 6, x + 6, GY - 3), '#c89050')


@tool('shop-food', 'dusk')
def v_food(c):
    wall(c, '#e3c48c', '#d4b07a')
    stove = rect(18, GY - 16, 40, GY)
    c.outline(stove); c.shaded(stove, '#62626c', '#3e3e46', '#8a8a92', 1)
    c.f(rect(22, GY - 8, 36, GY - 3), '#e8602e'); c.f(rect(25, GY - 6, 33, GY - 4), '#f4c84a')
    pot = rect(21, GY - 24, 37, GY - 17)
    item(c, pot, '#4a6e9a', '#34507a'); c.f(rect(19, GY - 24, 39, GY - 24), '#34507a')
    for x, y in ((25, GY - 28), (30, GY - 31), (34, GY - 28), (28, GY - 35)):
        c.f(rect(x, y, x + 1, y), '#ffffff')
    table = rect(52, GY - 9, 80, GY - 8) | rect(65, GY - 8, 67, GY)
    item(c, table, WOOD, WOODD)
    loaf = ell(54, GY - 14, 63, GY - 9)
    item(c, loaf, '#c89050', '#946434')
    bowl = ell(68, GY - 14, 78, GY - 8) & rect(0, GY - 12, 95, GY - 8)
    item(c, bowl, '#f4eee0', '#cfc6b0'); c.f(rect(70, GY - 12, 76, GY - 12), '#e8602e')
    gnome(c, 46, GY)


@tool('shop-florist')
def v_florist(c):
    blooms = ('#c03a4a', '#f4c84a', '#7a5cc0', '#f4eee0', '#e8602e')
    for i, x in enumerate((46, 58, 70)):
        b = poly([(x, GY - 9), (x + 9, GY - 9), (x + 8, GY), (x + 1, GY)])
        for k in range(3):
            sx = x + 2 + k * 3
            c.f(line([(sx, GY - 9), (sx + k - 1, GY - 17 - (k + i) % 3)]), '#4e8a3c')
            fx, fy = sx + k - 1, GY - 18 - (k + i) % 3
            c.f(rect(fx - 1, fy - 1, fx + 1, fy + 1), blooms[(i * 2 + k) % 5])
            c.f(rect(fx, fy, fx, fy), '#f4c84a' if blooms[(i * 2 + k) % 5] != '#f4c84a' else '#e8602e')
        item(c, b, '#9aa2ac', '#6e7680')
    gnome(c, 34, GY)
    bq = ell(38, GY - 12, 44, GY - 6)
    c.f(bq, '#c03a4a'); c.f(rect(40, GY - 10, 41, GY - 9), '#f4c84a')


@tool('shop-dyes', 'dusk')
def v_dyes(c):
    for x, dye in ((18, '#e8a317'), (34, '#4a6e9a'), (50, '#c03a4a')):
        tub = rect(x, GY - 10, x + 13, GY)
        c.outline(tub); c.shaded(tub, '#8a5a2e', '#5a3a1e')
        c.f(rect(x, GY - 7, x + 13, GY - 7) | rect(x, GY - 3, x + 13, GY - 3), '#4a2c1a')
        c.f(rect(x + 1, GY - 10, x + 12, GY - 9), dye)
        for k, (sx, sy) in enumerate(((x + 4, GY - 14), (x + 8, GY - 17), (x + 5, GY - 20))):
            c.f(rect(sx, sy, sx + 1, sy), '#f4eee0')
    paddle = line([(66, GY - 22), (58, GY - 9)], 1)
    item(c, paddle, '#c08a52', '#74462a')
    gnome(c, 72, GY, flip=True)


@tool('shop-decor')
def v_decor(c):
    for x in range(16, 44, 6):   # picket fence
        p = poly([(x, GY), (x, GY - 12), (x + 2, GY - 14), (x + 4, GY - 12), (x + 4, GY)])
        item(c, p, '#f4eee0', '#cfc6b0')
    rail = rect(16, GY - 9, 44, GY - 8)
    c.f(rail, '#cfc6b0')
    topi = ell(54, GY - 22, 68, GY - 8) | rect(60, GY - 8, 62, GY - 4)
    pot = rect(56, GY - 4, 66, GY)
    c.outline(topi | pot); c.shaded(topi, '#4e8a3c', '#386a2a', '#6aa84a', 1); c.shaded(pot, '#c0603a', '#8e3c2a')
    lpost = rect(74, GY - 24, 75, GY)
    item(c, lpost, '#4a2c1a', '#2a1a10')
    lamp = rect(72, GY - 30, 77, GY - 25)
    item(c, lamp, '#f4c84a', '#c89a2a')
    gnome(c, 48, GY)


VIGS = ['place-green', 'place-teahouse', 'place-board', 'place-library', 'place-grind', 'place-monastery', 'place-stones', 'place-pub',
        'place-special', 'shop-seeds', 'shop-food', 'shop-florist', 'shop-dyes', 'shop-decor']


def badge2(kind):
    c = C()
    if kind == 'star':     # "found only here"
        s = poly([(7, 1), (9, 5), (13, 5), (10, 8), (11, 13), (7, 10), (3, 13), (4, 8), (1, 5), (5, 5)])
        c.outline(s); c.shaded(s, '#f4c84a', '#c89a2a', '#fff2b0')
        return c.px[0:15, 0:15]
    # repair: a little striped barrier on two legs
    bar = rect(1, 3, 13, 7)
    legs = rect(2, 8, 3, 13) | rect(11, 8, 12, 13)
    c.outline(bar | legs); c.f(legs, '#74462a'); c.f(bar, '#f4eee0')
    for x in range(1, 14, 4):
        c.f(poly([(x, 7), (x + 2, 3), (x + 3, 3), (x + 1, 7)]), '#e8a317')
    return c.px[0:15, 0:15]


if __name__ == '__main__':
    for n in VIGS:
        gb.img(gb.vignette(n)).save(os.path.join(OUT, f'vig-{n}.png'), optimize=True)
    gb.FELT['gold'] = ('#c9a46a', '#a98450', '#f5cf6a', '#b07a10')   # same base as idle (text contrast unchanged), gold rim and stitch
    gb.img(gb.felt9('gold')).save(os.path.join(OUT, 'felt-gold.png'), optimize=True)
    for k in ('star', 'repair'):
        gb.img(badge2(k)).save(os.path.join(OUT, f'badge-{k}.png'), optimize=True)
    # contact sheet for review
    from PIL import Image
    ims = [Image.open(os.path.join(OUT, f'vig-{n}.png')) for n in VIGS]
    sheet = Image.new('RGBA', (5 * 152, 3 * 116), (42, 33, 24, 255))
    for i, im in enumerate(ims):
        sheet.paste(im, ((i % 5) * 152 + 4, (i // 5) * 116 + 4), im)
    sheet.save(os.path.join(OUT, 'preview.png'))
    print(len(VIGS), 'vignettes, felt-gold, 2 badges ->', OUT)
