#!/usr/bin/env python3
"""make_sheet.py : writes board-cluster-strip.png / board-cluster-hand.png (native size), sheet/*.png (composed pieces) and contact-sheet.html"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pv47 import *
SH = os.path.join(V, 'sheet'); os.makedirs(SH, exist_ok=True)
for s in CFG: cluster(s).save(os.path.join(V, 'board-cluster-%s.png' % s))
E4 = {'top': ('hole', 'mind'), 'right': ('knob', 'body'), 'bottom': ('hole', 'craft'), 'left': ('knob', 'craft')}
EDGES = {'hurt': dict(top=('knob', 'craft'), right=('knob', 'body'), bottom=('hole', 'mind'), left=('hole', 'craft')),
         'guard': dict(top=('hole', 'body'), right=('knob', 'mind'), bottom=('knob', 'craft'), left=('hole', 'mind')),
         'heal': dict(top=('hole', 'mind'), right=('knob', 'craft'), bottom=('hole', 'body'), left=('knob', 'body')),
         'charm': dict(top=('knob', 'body'), right=('hole', 'mind'), bottom=('hole', 'craft'), left=('knob', 'mind')),
         'soothe': dict(top=('hole', 'craft'), right=('hole', 'body'), bottom=('knob', 'body'), left=('knob', 'craft')),
         'trick': dict(top=('knob', 'craft'), right=('hole', 'body'), bottom=('knob', 'mind'), left=('hole', 'craft')),
         'item': dict(top=('hole', 'mind'), right=('knob', 'body'), bottom=('hole', 'mind'), left=('knob', 'mind'))}
def save(name, im): im.save(os.path.join(SH, name + '.png')); return 'sheet/' + name + '.png'
Z = {'strip': 4, 'hand': 2}
H = []
def img(path, size, z=None, cls='', extra=''):
    im = Image.open(os.path.join(V, path)); z = z or Z[size]
    return '<img class="px %s" src="%s" style="--w:%d;--h:%d;--z:%d" alt="" %s>' % (cls, path, im.width, im.height, z, extra)
def fig(path, size, cap, z=None, cls=''): return '<figure>%s<figcaption>%s</figcaption></figure>' % (img(path, size, z, cls), cap)
def guides(size):
    c = CFG[size]; T = c['T']; z = Z[size]
    if size == 'strip': boxes = [('number plate 16x12', 3, 3, 16, 12), ('owner / badge 11x11', 42, 3, 11, 11), ('star / flip 11x11', 42, 33, 11, 11), ('life pips 3 x (5x3)', 4, 40, 17, 3)]
    else: boxes = [('plate 28x20', 5, 5, 28, 20), ('owner / badge 18x18', 73, 5, 18, 18), ('star / flip 18x18', 73, 57, 18, 18), ('pips 3 x (9x5)', 7, 68, 31, 5)]
    out = ''
    for n, x, y, w, h in boxes:
        out += '<i class="guide" title="%s" style="left:calc((%d + %d)*var(--z)*1px);top:calc((%d + %d)*var(--z)*1px);width:calc(%d*var(--z)*1px);height:calc(%d*var(--z)*1px)"></i>' % (n, T, x, T, y, w, h)
    return out
for size in ('strip', 'hand'):
    c = CFG[size]
    H.append('<section><h2>%s size: body %dx%d, tabs %d, piece image %dx%d (shown %dx)</h2>' % (size.upper(), c['BW'], c['BH'], c['T'], c['W'], c['H'], Z[size]))
    H.append('<h3>1. Seven types (me): flat colour, 3 tones, felt stitch, centred glyph; each with different edges</h3><div class="row">')
    for t in TYPES: H.append(fig(save('%s-type-%s' % (size, t), piece(size, t, EDGES[t])), size, t.capitalize()))
    H.append('</div><h3>1b. The tile files themselves (no edges) and the reserved slots the game draws into (thin guides exist only on this sheet)</h3><div class="row">')
    H.append(fig('%s/tile-%s-guard.png' % (size, size), size, 'tile-%s-guard.png' % size))
    H.append('<figure><span class="wrap" style="--w:%d;--h:%d;--z:%d">%s%s</span><figcaption>plate top-left, owner badge top-right, star/flip badge bottom-right, life pips bottom-left</figcaption></figure>' % (c['W'], c['H'], Z[size], img(save('%s-guides' % size, piece(size, 'heal', EDGES['heal'])), size), guides(size)))
    H.append('</div><h3>2. Edge families: square-neck round head = Body (red), keyhole = Mind (purple), wedge = Craft (gold). Knob left, hole right of each pair</h3><div class="row">')
    for fam in FAMS:
        k = {s: ('knob', fam) for s in SIDES}; h = {s: ('hole', fam) for s in SIDES}
        H.append(fig(save('%s-fam-%s-knob' % (size, fam), piece(size, 'hurt', k)), size, '%s: 4 knobs' % fam))
        H.append(fig(save('%s-fam-%s-hole' % (size, fam), piece(size, 'guard', h)), size, '%s: 4 holes (true cut-outs)' % fam))
    H.append('</div><h3>3. Owners: me (plain), creature (red rim + bone thorns), environment (grey body, dashed rim)</h3><div class="row">')
    for o, nm in (('me', 'me'), ('foe', 'creature'), ('env', 'environment')):
        H.append(fig(save('%s-owner-%s' % (size, o), piece(size, 'hurt', EDGES['hurt'], o)), size, nm))
    H.append('</div><h3>4. States (overlay files): picked ring, faded veil, scoring-now glow</h3><div class="row">')
    base = piece(size, 'heal', EDGES['heal'])
    H.append(fig(save('%s-state-normal' % size, base), size, 'normal'))
    for st in ('picked', 'faded', 'now'): H.append(fig(save('%s-state-%s' % (size, st), with_state(size, base, st)), size, st))
    H.append('</div><h3>5. Badges (own files): lock, star, flip, eye, land</h3><div class="row">')
    for b in ('lock', 'star', 'flip', 'eye', 'land'): H.append(fig('%s/badge-%s-%s.png' % (size, size, b), size, b, z=Z[size] * (3 if size == 'strip' else 2)))
    H.append('</div><h3>6. Board cluster 5 x 3 at the real pitch %dx%d: knobs sit in matching holes (native file board-cluster-%s.png)</h3>' % (c['pitch'][0], c['pitch'][1], size))
    H.append('<div class="board">%s</div>' % img('board-cluster-%s.png' % size, size))
    H.append('<h3>7a. Hero pieces, one per family: three knobs and a hole of the same shape</h3><div class="row">')
    for fam, ty, hole in (('body', 'hurt', 'left'), ('mind', 'soothe', 'bottom'), ('craft', 'trick', 'top')):
        e = {s: ('knob', fam) for s in SIDES}; e[hole] = ('hole', fam)
        H.append(fig(save('%s-hero-%s' % (size, fam), piece(size, ty, e)), size, '%s hero' % fam))
    H.append('</div>')
    H.append('<h3>7. A loose piece, so the silhouette reads on its own</h3><div class="row">%s</div></section>' % fig(save('%s-loose' % size, piece(size, 'charm', dict(top=('knob', 'body'), right=('knob', 'mind'), bottom=('hole', 'craft'), left=('hole', 'body')))), size, 'jigsaw outline'))
CSS = '''body{margin:0;background:#150d07;color:#f2e4c0;font:14px/1.35 system-ui,sans-serif;padding:16px 24px}
h1{font-size:1.3rem;color:#f6c453}h2{font-size:1.15rem;color:#f6c453;margin:36px 0 4px;border-top:1px solid #4a3322;padding-top:14px}h3{font-size:.95rem;color:#cdb48c;margin:22px 0 8px}
.row{display:flex;flex-wrap:wrap;gap:18px;align-items:flex-end}figure{margin:0;text-align:center}figcaption{color:#cdb48c;font-size:.8rem;max-width:26em}
.px{image-rendering:pixelated;width:calc(var(--w)*var(--z)*1px);height:calc(var(--h)*var(--z)*1px);display:block}
.wrap{position:relative;display:block;width:calc(var(--w)*var(--z)*1px);height:calc(var(--h)*var(--z)*1px)}
.guide{position:absolute;box-sizing:border-box;border:1px solid #ff4fd8;pointer-events:none}
.board{display:inline-block;padding:14px;background:#2f2016;border:2px solid #5b4128}'''
open(os.path.join(V, 'contact-sheet.html'), 'w').write('<!doctype html><html><head><meta charset="utf-8"><title>Puzzle pieces v47</title><style>%s</style></head><body><h1>Puzzle-combat pieces v47 (56 x 47 strip, 96 x 80 hand)</h1>%s</body></html>' % (CSS, ''.join(H)))
print('sheet written')

# ---- compare-today-vs-new.html : today's art (game/assets/img/pfight/parts) beside the new set, same scale
import json
TODAY = '../../../game/assets/img/pfight/parts/'
dj = json.load(open(os.path.join(V, '..', '..', '..', 'game/assets/img/pfight/parts/example/board-demo-pieces.json')))
KM = {'L': 'left', 'R': 'right', 'T': 'top', 'B': 'bottom'}
def newboard(size, key):
    cells = []
    for k, v in dj[key].items():
        x, y = map(int, k.split(',')); e = {KM[s]: (kd, fam) for s, (kd, fam) in v['edges'].items() if kd != 'flat'}
        cells.append((x, y, piece(size, v['type'], e, v['owner'])))
    cols = max(c[0] for c in cells) + 1; rows = max(c[1] for c in cells) + 1
    return board(size, cells, cols, rows)
newboard('strip', 'strip-3x3').save(os.path.join(SH, 'compare-strip-board.png'))
hk = [k for k in dj if k.startswith('hand')]
if hk: newboard('hand', hk[0]).save(os.path.join(SH, 'compare-hand-board.png'))
def im2(path, z, label):
    im = Image.open(os.path.join(V, path)); return '<figure><img class="px" src="%s" style="--w:%d;--h:%d;--z:%d" alt=""><figcaption>%s</figcaption></figure>' % (path, im.width, im.height, z, label)
C = ['<h1>Today (left) vs the new 56 x 47 jigsaw set (right), same pixel scale</h1><p>Same pieces (types, owners, edge families) as the game\'s own board-demo files. Today: body 56x40, bumps 9 / 6 px. New: body 56x47, tabs 13 px.</p>']
C.append('<h2>Strip board, 3 x 3, 3x</h2><div class="row">' + im2('../../../game/assets/img/pfight/parts/example/board-demo.png', 3, 'today') + im2('sheet/compare-strip-board.png', 3, 'new') + '</div>')
if hk:
    C.append('<h2>Hand board, 2 x 2, 2x</h2><div class="row">' + im2('../../../game/assets/img/pfight/parts/example/board-demo-hand.png', 2, 'today') + im2('sheet/compare-hand-board.png', 2, 'new') + '</div>')
C.append('<h2>One piece: creature trick, left hole Mind, right knob Body, top hole Craft, bottom hole Mind, 5x</h2><div class="row">' + im2('../../../game/assets/img/pfight/parts/example/strip-foe-trick-final.png', 5, 'today') +
         im2(save('compare-foe-trick', piece('strip', 'trick', dict(left=('hole', 'mind'), right=('knob', 'body'), top=('hole', 'craft'), bottom=('hole', 'mind')), 'foe')), 'strip', 5, 'new') if False else '</div>')
foe = save('compare-foe-trick', piece('strip', 'trick', dict(left=('hole', 'mind'), right=('knob', 'body'), top=('hole', 'craft'), bottom=('hole', 'mind')), 'foe'))
C[-1] = C[-1][:-6] if C[-1].endswith('</div>') else C[-1]
C.append('<h2>One piece: creature trick, left hole Mind, right knob Body, top hole Craft, bottom hole Mind, 5x</h2><div class="row">' + im2('../../../game/assets/img/pfight/parts/example/strip-foe-trick-final.png', 5, 'today') + im2(foe, 5, 'new') + '</div>')
C.append('<h2>Type icons: today 20x20 (5x) vs new glyph tiles (strip, 4x)</h2><div class="row">' + im2('../../../game/assets/img/pfight/parts/icons-strip.png', 5, 'today: icons-strip.png') + '</div><div class="row">' + ''.join(im2('strip/tile-strip-%s.png' % t, 3, t) for t in TYPES) + '</div>')
open(os.path.join(V, 'compare-today-vs-new.html'), 'w').write('<!doctype html><html><head><meta charset="utf-8"><title>Today vs new</title><style>%s</style></head><body>%s</body></html>' % (CSS, ''.join(C)))
print('compare written')
