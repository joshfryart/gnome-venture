"""pv48.py : compose v48 pieces from the PNG parts, exactly as the game's renderer (assets/pfparts47.js, build47) does. Used by check.py and make_sheet.py.
The edge (body, sockets, overlays, badges) is v47's and is read from ../../v47 through its pv47.py: v48 only repaints the face."""
import os, sys
from PIL import Image
V = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(V, '..', 'v47', 'scripts'))
import pv47
CFG, TYPES, FAMS, SIDES, ERASE, region = pv47.CFG, pv47.TYPES, pv47.FAMS, pv47.SIDES, pv47.ERASE, pv47.region
KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn']
SLOTS = {   # body coordinates of what the game draws into the empty slots of the art (the same as v47)
    'strip': dict(plate=[3, 3, 16, 12], owner=[42, 3], extra=[42, 33], pips=[4, 40], pip=[5, 3, 1], k=2),
    'hand': dict(plate=[5, 5, 28, 20], owner=[73, 5], extra=[73, 57], pips=[7, 68], pip=[9, 5, 2], k=3),
}
PRE = {'me': 'tile', 'foe': 'foe', 'env': 'env'}
def P(size, name): return Image.open(os.path.join(V, size, name + '.png')).convert('RGBA')
def glyph(size, owner, name): return Image.open(os.path.join(V, 'scripts/layers/glyph-%s-%s-%s.png' % (size, owner, name))).convert('RGBA')
def number(img, size, text):
    c = CFG[size]; sl = SLOTS[size]; T = c['T']; k = sl['k']; px, py, pw, ph = sl['plate']
    img.alpha_composite(P(size, 'plate-' + size), (T + px, T + py))
    d = P(size, 'digits-' + size); gw, gh = 3 * k, 5 * k
    w = len(text) * gw + (len(text) - 1) * k; x0 = T + px + (pw - w) // 2; y0 = T + py + (ph - gh) // 2
    for n, ch in enumerate(text): img.alpha_composite(d.crop((int(ch) * gw, 0, int(ch) * gw + gw, gh)), (x0 + n * (gw + k), y0))
def piece(size, name, edges=None, owner='me', num=None, glyph_on=True):
    """owner me / foe: name = a type; owner env: name = a kind. edges: dict side -> (kind, fam). Returns RGBA image W x H."""
    edges = edges or {}
    img = P(size, '%s-%s-%s' % (PRE[owner], size, name)).copy()
    if not glyph_on:   # the tile without its glyph layer = the tile minus the glyph's pixels is not recoverable from the PNG: used only for outlines
        pass
    for side in SIDES:
        if side in edges and edges[side]: pv47.stamp(img, size, side, edges[side][1], edges[side][0])
    if num is not None and owner != 'env': number(img, size, str(num))
    if owner == 'foe':
        c = CFG[size]; sl = SLOTS[size]
        img.alpha_composite(pv47.P(size, 'badge-%s-eye' % size), (c['T'] + sl['owner'][0], c['T'] + sl['owner'][1]))
    return img
def board(size, cells, cols=None, rows=None):
    c = CFG[size]; px, py = c['pitch']
    cols = cols or max(x for x, y, i in cells) + 1; rows = rows or max(y for x, y, i in cells) + 1
    out = Image.new('RGBA', (cols * px + 2 * c['T'], rows * py + 2 * c['T']), (0, 0, 0, 0))
    for x, y, im in cells: out.alpha_composite(im, (x * px, y * py))
    return out
K, H = 'knob', 'hole'
CLUSTER = [   # col, row, name, owner, edges, number
  (0, 0, 'hurt',   'me',  dict(right=(K, 'body'), bottom=(K, 'mind')), 11),
  (1, 0, 'guard',  'me',  dict(left=(H, 'body'), right=(K, 'craft'), bottom=(H, 'body')), 12),
  (2, 0, 'heal',   'me',  dict(left=(H, 'craft'), bottom=(K, 'mind'), right=(H, 'body')), 8),
  (3, 0, 'hurt',   'foe', dict(left=(K, 'body'), bottom=(H, 'craft'), right=(K, 'mind')), 18),
  (0, 1, 'charm',  'me',  dict(top=(H, 'mind'), right=(K, 'craft'), bottom=(H, 'body')), 6),
  (1, 1, 'soothe', 'me',  dict(top=(K, 'body'), left=(H, 'craft'), right=(K, 'mind')), 7),
  (2, 1, 'trick',  'me',  dict(top=(H, 'mind'), left=(H, 'mind'), right=(K, 'body'), bottom=(K, 'craft')), 3),
  (3, 1, 'guard',  'foe', dict(top=(K, 'craft'), left=(H, 'body'), bottom=(H, 'mind')), 9),
  (4, 1, 'sun',    'env', dict(top=(K, 'mind'), left=(H, 'body')), None),
  (0, 2, 'item',   'me',  dict(top=(K, 'body'), right=(H, 'mind')), 5),
  (1, 2, 'charm',  'foe', dict(left=(K, 'mind'), right=(K, 'body')), 4),
  (2, 2, 'thorn',  'env', dict(top=(H, 'craft'), left=(H, 'body'), right=(K, 'craft')), None),
  (3, 2, 'trick',  'foe', dict(top=(K, 'mind'), left=(H, 'craft'), right=(H, 'body')), 2),
  (4, 2, 'rain',   'env', dict(left=(K, 'body'), top=(H, 'mind')), None),
]
def cluster(size):
    return board(size, [(x, y, piece(size, t, e, o, n)) for x, y, t, o, e, n in CLUSTER], 5, 3)
