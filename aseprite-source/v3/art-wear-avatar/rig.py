"""Rig I/O for the wear-avatar toolkit: loads the gnome25 layer strips (game/assets/img/gnome25, read-only), recolours them with
GNOME25_DEFAULT (same palette mapping as gnome25.php), composes a view with wear layers inserted per a stack rule."""
import os
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../..'))
G = os.path.join(ROOT, 'game/assets/img/gnome25')
ORDER = [('shadow', None), ('outline', None), ('boots', 'boots'), ('tunic', 'tunic'), ('scarf', 'scarf'), ('skin', 'skin'), ('beard', 'beard'), ('face', None), ('hat', 'hat'), ('trim', 'trim')]
MARK = {(0xf0, 0xf0, 0xf0): 0, (0xb4, 0xb4, 0xb4): 1, (0x78, 0x78, 0x78): 2, (0x3c, 0x3c, 0x3c): 3}
DEFAULT = {'hat': ['#ff8a5c', '#e8493b', '#b52e3f', '#6e2038'], 'tunic': ['#b6f0e0', '#5fc4c8', '#3a86b0', '#2a4a7a'], 'scarf': ['#ffe38a', '#f5b82e', '#d98322', '#51302b'],
           'beard': ['#fff4d6', '#e2e0e6', '#aaa9b8', '#74758c'], 'boots': ['#e8b982', '#b97a4a', '#864c33', '#51302b'], 'skin': ['#ffe0bd', '#f0b98d', '#c98462', '#51302b'],
           'trim': ['#ffe38a', '#f5b82e', '#d98322', '#51302b']}
VIEWS = ('front', 'back', 'side')
# where a wear CATEGORY layer goes (drawn right after this base layer; '' = first). Mirrors the planned game rule.
AFTER = {'front': {'footwear': 'tunic', 'coat': 'tunic', 'backpack': '', 'cloak': ''},
         'back': {'footwear': 'tunic', 'coat': 'tunic', 'backpack': 'tunic', 'cloak': 'tunic'},
         'side': {'footwear': 'tunic', 'coat': 'tunic', 'backpack': 'tunic', 'cloak': 'tunic'}}
_cache = {}

def hx(h):
    h = h.lstrip('#'); return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

def layer(view, name, coloured=True):
    k = (view, name, coloured)
    if k not in _cache:
        im = Image.open(os.path.join(G, f'{view}-{name}.png')).convert('RGBA')
        role = dict(ORDER).get(name)
        if coloured and role:
            ramp = [hx(c) for c in DEFAULT[role]]
            px = im.load()
            for y in range(im.height):
                for x in range(im.width):
                    p = px[x, y]
                    if p[3] and p[:3] in MARK: px[x, y] = (*ramp[MARK[p[:3]]], 255)
        _cache[k] = im
    return _cache[k]

def compose(view, wear=(), skip=()):
    """wear: list of (category, RGBA strip). Returns composed 512x80 strip."""
    out = Image.new('RGBA', (512, 80))
    for cat, im in wear:
        if AFTER[view][cat] == '': out.alpha_composite(im)
    for name, _ in ORDER:
        if name not in skip: out.alpha_composite(layer(view, name))
        for cat, im in wear:
            if AFTER[view][cat] == name: out.alpha_composite(im)
    return out
