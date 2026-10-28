"""Felt-card art for the World > Go route cards: one vignette per place kind (locations.kind via loc_real_kind).
route-market route-village route-haven route-wonder route-delve route-lair route-hub
Same pipeline as town_art.py (loads mockup2/gather_b.py). Usage: PYTHONHASHSEED=0 python3 claude/art-variants/mockup3/route_art.py
Writes mockup3/art/vig-route-*.png and preview-route.png; copy the vig files to game/assets/img/town/route-<kind>.png."""
import os
import importlib.util
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'art')
os.makedirs(OUT, exist_ok=True)
spec = importlib.util.spec_from_file_location('town_art', os.path.join(HERE, 'town_art.py'))
ta = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ta)
gb = ta.gb
rect, ell, poly, line, item, gnome, GY, tool = ta.rect, ta.ell, ta.poly, ta.line, ta.item, ta.gnome, ta.GY, ta.tool
WOOD, WOODD, WOODR = ta.WOOD, ta.WOODD, ta.WOODR


def cottage(c, x, base, w, h, wall, roof, roofd):
    body = rect(x, base - h, x + w, base)
    c.outline(body); c.shaded(body, wall, '#c9a46a')
    r = poly([(x - 3, base - h), (x + w // 2, base - h - 9), (x + w + 3, base - h)])
    item(c, r, roof, roofd)
    door = rect(x + w // 2 - 2, base - 8, x + w // 2 + 1, base)
    c.f(door, WOODD)
    win = rect(x + 2, base - h + 4, x + 5, base - h + 7)
    c.f(win, '#f4cf98')


def tree(c, x, base, s=1):
    trunk = rect(x, base - 8 * s, x + 2, base)
    crown = ell(x - 7 * s, base - 22 * s, x + 9 * s, base - 6 * s)
    c.outline(trunk | crown); c.shaded(trunk, '#8a5a2e', '#5a3a1e'); c.shaded(crown, '#4e8a3c', '#386a2a', '#6aa84a', 2)


@tool('route-market')
def r_market(c):
    ta.awning(c, '#c0442e', '#f4eee0')
    stall = rect(18, GY - 14, 56, GY)
    c.outline(stall); c.shaded(stall, WOOD, WOODD, WOODR, 1)
    c.f(rect(18, GY - 14, 56, GY - 13), '#c9a46a')
    for i, col in enumerate(('#c0442e', '#e8a317', '#4e8a3c', '#c0442e', '#e8a317')):
        c.f(ell(21 + i * 7, GY - 20, 26 + i * 7, GY - 15), col)
    sign = rect(62, GY - 24, 78, GY - 14)
    post = rect(69, GY - 14, 71, GY)
    item(c, post, '#8a5a2e', '#5a3a1e'); item(c, sign, '#f4eee0', '#cfc6b0')
    c.f(ell(66, GY - 22, 74, GY - 16), '#e8a317')
    gnome(c, 62, GY, flip=True)


@tool('route-village')
def r_village(c):
    tree(c, 70, GY, 1)
    cottage(c, 18, GY, 18, 14, '#e3c48c', '#8e3c2a', '#6e2c1e')
    cottage(c, 40, GY, 16, 11, '#f4eee0', '#4a6e9a', '#34507a')
    c.f(rect(24, GY - 22, 25, GY - 22) | rect(25, GY - 25, 26, GY - 24) | rect(26, GY - 29, 27, GY - 28), '#ffffff')
    path = poly([(46, GY + 1), (52, GY + 1), (60, 63), (44, 63)])
    c.f(path, '#c9a46a')
    gnome(c, 58, GY)


@tool('route-haven', 'dusk')
def r_haven(c):
    tent = poly([(18, GY), (34, GY - 22), (50, GY)])
    item(c, tent, '#c0442e', '#8e2e1e')
    c.f(poly([(30, GY), (34, GY - 12), (38, GY)]), '#2a1a10')
    tree(c, 64, GY, 1)
    logs = rect(54, GY - 3, 66, GY - 1) | rect(56, GY - 5, 64, GY - 3)
    item(c, logs, WOOD, WOODD)
    flame = poly([(57, GY - 5), (60, GY - 14), (63, GY - 5)])
    c.outline(flame); c.shaded(flame, '#f4c84a', '#e8731a', '#fff2b0')
    gnome(c, 44, GY, pose='sit')


@tool('route-wonder')
def r_wonder(c):
    for i, (x, h, col, dk) in enumerate(((30, 26, '#a9d6ea', '#6aa8c8'), (42, 36, '#c8b4f0', '#8a6ac4'), (54, 22, '#a9d6ea', '#6aa8c8'))):
        cr = poly([(x - 5, GY), (x - 3, GY - h + 6), (x, GY - h), (x + 3, GY - h + 6), (x + 5, GY)])
        c.outline(cr); c.shaded(cr, col, dk, '#ffffff', 1)
    for x, y in ((22, 22), (66, 26), (74, 40), (20, 40)):
        c.f(rect(x, y, x, y), '#fff2b0'); c.f(rect(x - 1, y, x + 1, y) | rect(x, y - 1, x, y + 1), '#f4c84a')
    gnome(c, 70, GY, flip=True)


@tool('route-delve', 'dusk')
def r_delve(c):
    hill = ell(14, GY - 34, 82, GY + 24)
    c.outline(hill); c.shaded(hill, '#7a8a66', '#566644', '#9aaa86', 2)
    mouth = poly([(30, GY + 1), (32, GY - 14), (40, GY - 20), (50, GY - 14), (52, GY + 1)])
    c.f(mouth, '#1a1210')
    c.f(rect(33, GY - 12, 49, GY - 11), '#2a1a10')
    for x in (28, 54):
        b = rect(x, GY - 16, x + 1, GY + 1)
        item(c, b, WOOD, WOODD)
    c.f(rect(41, GY - 6, 41, GY - 6), '#f4c84a')   # a lantern glint inside
    lamp = rect(60, GY - 9, 63, GY - 6)
    c.f(rect(61, GY - 12, 62, GY - 10), '#2a1a10'); c.f(lamp, '#f4c84a')
    gnome(c, 66, GY, flip=True)


@tool('route-lair', 'dusk')
def r_lair(c):
    rock = poly([(14, GY + 1), (20, GY - 26), (34, GY - 34), (60, GY - 32), (74, GY - 22), (82, GY + 1)])
    c.outline(rock); c.shaded(rock, '#6a5e6a', '#463c48', '#8a7e8a', 2)
    mouth = poly([(30, GY + 1), (32, GY - 14), (42, GY - 22), (54, GY - 14), (56, GY + 1)])
    c.f(mouth, '#120c12')
    for x in (38, 48):
        c.f(rect(x, GY - 10, x + 2, GY - 8), '#e8a317'); c.f(rect(x + 1, GY - 9, x + 1, GY - 9), '#a8241f')
    for x in (31, 36, 44, 51):
        c.f(poly([(x, GY - 14 - (x % 3)), (x + 2, GY - 14 - (x % 3)), (x + 1, GY - 10)]), '#f4eee0')
    bone = rect(62, GY - 3, 70, GY - 2) | rect(61, GY - 4, 62, GY - 1) | rect(70, GY - 4, 71, GY - 1)
    item(c, bone, '#f4eee0', '#cfc6b0')
    gnome(c, 22, GY)


@tool('route-hub')
def r_hub(c):
    stem = rect(38, GY - 22, 48, GY)
    cap = ell(18, GY - 46, 68, GY - 14)
    c.outline(stem | cap); c.shaded(stem, '#f4eee0', '#cfc6b0'); c.shaded(cap, '#c0442e', '#8e2e1e', '#e0644e', 2)
    for x, y in ((28, GY - 34), (42, GY - 40), (54, GY - 33), (36, GY - 24)):
        c.f(ell(x, y, x + 4, y + 3), '#f4eee0')
    c.f(rect(41, GY - 12, 45, GY), '#74462a')
    gnome(c, 62, GY, flip=True)


KINDS = ['market', 'village', 'haven', 'wonder', 'delve', 'lair', 'hub']

if __name__ == '__main__':
    from PIL import Image
    ims = []
    for k in KINDS:
        im = gb.img(gb.vignette('route-' + k))
        im.save(os.path.join(OUT, f'vig-route-{k}.png'), optimize=True)
        ims.append(im)
    sheet = Image.new('RGBA', (4 * 152, 2 * 116), (42, 33, 24, 255))
    for i, im in enumerate(ims):
        sheet.paste(im, ((i % 4) * 152 + 4, (i // 4) * 116 + 4), im)
    sheet.save(os.path.join(OUT, 'preview-route.png'))
    print(len(KINDS), 'route vignettes ->', OUT)
