"""pv47.py : compose v47 pieces from the PNG parts (the same stamping the game code would do). Used by check.py and make_sheet.py."""
import os
from PIL import Image
V = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
CFG = {
  'strip': dict(BW=56, BH=47, T=13, lenTB=20, lenLR=21, pitch=(56, 47), badge=11),
  'hand':  dict(BW=96, BH=80, T=22, lenTB=34, lenLR=34, pitch=(96, 80), badge=18),
}
for c in CFG.values(): c['W'] = c['BW'] + 2 * c['T']; c['H'] = c['BH'] + 2 * c['T']
TYPES = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item']
FAMS = ['body', 'mind', 'craft']
SIDES = ['top', 'right', 'bottom', 'left']
ERASE = (255, 0, 255, 255)
def P(size, name): return Image.open(os.path.join(V, size, name + '.png')).convert('RGBA')
def region(size, side):
    """crop rectangle (x0,y0,x1,y1) of one side in piece-image coordinates"""
    c = CFG[size]; T = c['T']; m = 2
    if side in ('top', 'bottom'):
        x0 = T + (c['BW'] - c['lenTB']) // 2 - m; x1 = x0 + c['lenTB'] + 2 * m
        return (x0, 0, x1, 2 * T + m) if side == 'top' else (x0, c['H'] - 2 * T - m, x1, c['H'])
    y0 = T + (c['BH'] - c['lenLR']) // 2 - m; y1 = y0 + c['lenLR'] + 2 * m
    return (0, y0, 2 * T + m, y1) if side == 'left' else (c['W'] - 2 * T - m, y0, c['W'], y1)
def stamp(img, size, side, fam, kind):
    sock = P(size, 'sock-%s-%s-%s' % (size, fam, kind)); x0, y0, x1, y1 = region(size, side)
    # a sock file holds all four sides; the side layers are disjoint, so the region crop selects one
    for y in range(y0, y1):
        for x in range(x0, x1):
            p = sock.getpixel((x, y))
            if p[3] == 0: continue
            img.putpixel((x, y), (0, 0, 0, 0) if p == ERASE else p)
GREY = {(0xd5, 0x5e, 0x00): (0x6f, 0x6a, 0x5c)}
def piece(size, typ, edges=None, owner='me'):
    """edges: dict side -> (kind, fam); returns RGBA image W x H"""
    edges = edges or {}
    img = P(size, 'tile-%s-%s' % (size, typ)).copy()
    if owner == 'env':   # grey felt: every saturated (type colour) pixel becomes a grey of the same relative lightness
        base = {'hurt': (213, 94, 0), 'guard': (0, 99, 158), 'heal': (0, 158, 115), 'charm': (204, 121, 167), 'soothe': (98, 188, 238), 'trick': (240, 228, 66), 'item': (230, 159, 0)}[typ]
        lum = lambda r, g, b: 0.3 * r + 0.59 * g + 0.11 * b
        bl = lum(*base); px = img.load()
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, a = px[x, y]
                if a and max(r, g, b) - min(r, g, b) > 70:
                    k = lum(r, g, b) / bl
                    px[x, y] = (min(255, int(0x6f * k)), min(255, int(0x6a * k)), min(255, int(0x5c * k)), 255)
    if owner in ('foe', 'env'): img.alpha_composite(P(size, 'frame-%s-%s' % (size, owner)))
    for side in SIDES:
        if side in edges and edges[side]: stamp(img, size, side, edges[side][1], edges[side][0])
    return img
def board(size, cells, cols=None, rows=None):
    """cells: list of (col,row, image). pitch = body size; canvas = pitch*cols + 2T"""
    c = CFG[size]; px, py = c['pitch']
    cols = cols or max(x for x, y, i in cells) + 1; rows = rows or max(y for x, y, i in cells) + 1
    out = Image.new('RGBA', (cols * px + 2 * c['T'], rows * py + 2 * c['T']), (0, 0, 0, 0))
    for x, y, im in cells: out.alpha_composite(im, (x * px, y * py))
    return out

def with_state(size, img, state):
    """picked / now: overlay drawn UNDER the piece; faded: veil drawn over it"""
    ov = P(size, 'overlay-%s-%s' % (size, state))
    if state == 'faded':
        out = img.copy(); out.alpha_composite(ov); return out
    out = Image.new('RGBA', img.size, (0, 0, 0, 0)); out.alpha_composite(ov); out.alpha_composite(img); return out
K, H = 'knob', 'hole'
CLUSTER = [
  (0, 0, 'hurt',   'me',  dict(right=(K, 'body'), bottom=(K, 'mind'))),
  (1, 0, 'guard',  'me',  dict(left=(H, 'body'), right=(K, 'craft'), bottom=(H, 'body'))),
  (2, 0, 'heal',   'me',  dict(left=(H, 'craft'), bottom=(K, 'mind'))),
  (0, 1, 'charm',  'foe', dict(top=(H, 'mind'), right=(K, 'craft'))),
  (1, 1, 'soothe', 'me',  dict(top=(K, 'body'), left=(H, 'craft'), right=(K, 'mind'))),
  (2, 1, 'trick',  'me',  dict(top=(H, 'mind'), left=(H, 'mind'), right=(K, 'body'), bottom=(K, 'craft'))),
  (3, 1, 'item',   'env', dict(left=(H, 'body'))),
  (2, 2, 'hurt',   'me',  dict(top=(H, 'craft'))),
]
def cluster(size):
    """the 5 x 3 chain used in the sheet; every knob sits in a hole of the same family"""
    return board(size, [(x, y, piece(size, t, e, o)) for x, y, t, o, e in CLUSTER], 5, 3)
