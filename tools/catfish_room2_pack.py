#!/usr/bin/env python3
"""catfish_room2_pack.py: pack the Cat Fish room2 art (aseprite-source/catfish/room2/out*) into game/assets/img/catfish/room2/.
Cat frames become one horizontal strip per layer (frame i at x = i * w): cat/<set>/<layer>.png, set = run | zoom | toward | away.
Plates, furniture and props are copied as they are; manifest.json lists everything catfish_room.js needs.
Run: python3 -I tools/catfish_room2_pack.py"""
import os, re, json, shutil, sys, collections
sys.dont_write_bytecode = True
from PIL import Image
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SRC = os.path.join(ROOT, 'aseprite-source', 'catfish', 'room2')
DST = os.path.join(ROOT, 'game', 'assets', 'img', 'catfish', 'room2')
SETS = {'run': 'out80/coats', 'zoom': 'out_zoom/coats', 'toward': 'out_fb/coats', 'away': 'out_fb/coats'}
RX = re.compile(r'^cf-(.+?)-?(runtoward|runaway|run|zoom)(\d+)(-fold)?\.png$')
SETNAME = {'run': 'run', 'zoom': 'zoom', 'runtoward': 'toward', 'runaway': 'away'}
shutil.rmtree(DST, ignore_errors=True)
man = {'cat': {}, 'plates': [], 'furn': {}, 'props': {}}
groups = collections.defaultdict(dict)   # (set, layer) -> {idx: path}
for key, rel in SETS.items():
    d = os.path.join(SRC, rel)
    for f in sorted(os.listdir(d)):
        m = RX.match(f)
        if not m: continue
        name, st, idx, fold = m.groups()
        if SETNAME[st] != key: continue
        layer = name + ('-fold' if fold else '')
        groups[(key, layer)][int(idx)] = os.path.join(d, f)
sizes = {}
for (key, layer), fr in sorted(groups.items()):
    n = max(fr); ims = [Image.open(fr[i]).convert('RGBA') for i in sorted(fr)]
    w, h = ims[0].size
    strip = Image.new('RGBA', (w * len(ims), h), (0, 0, 0, 0))
    for i, im in enumerate(ims): strip.paste(im, (i * w, 0))
    out = os.path.join(DST, 'cat', key); os.makedirs(out, exist_ok=True)
    strip.save(os.path.join(out, layer + '.png'), optimize=True)
    sizes[key] = {'w': w, 'h': h, 'n': len(ims)}
    man['cat'].setdefault(key, []).append(layer)
# idle set: the old 64x64 stacked art (sitting, stalk, pounce, nap...), one strip per layer, frames in IDLE order
OLD = os.path.join(ROOT, 'game', 'assets', 'img', 'catfish')
IDLE = ['idleA', 'idleB', 'stalk', 'pounce', 'nap', 'wiggle', 'catch', 'blink', 'tailflick', 'eartwitch', 'yawn', 'stretch', 'washA', 'washB', 'swatA', 'swatB', 'jump', 'happy']
ALIAS = ('blink', 'tailflick', 'eartwitch')   # these old frames own only some layers; the others are idleA's file (game/includes/catfish.php catfish_role_frame)
COATS = ['black', 'brown', 'cream', 'grey', 'lilac', 'orange', 'silver-blue', 'white']
PATS = ['tabby', 'tuxedo', 'calico', 'pointed', 'spotted']
def idle_layer(layer, tmpl):
    ims = []
    for fr in IDLE:
        f = os.path.join(OLD, tmpl.format(f=fr))
        if not os.path.isfile(f) and fr in ALIAS: f = os.path.join(OLD, tmpl.format(f='idleA'))
        ims.append(Image.open(f).convert('RGBA') if os.path.isfile(f) else Image.new('RGBA', (64, 64), (0, 0, 0, 0)))
    if not any(im.getbbox() for im in ims): return
    strip = Image.new('RGBA', (64 * len(ims), 64), (0, 0, 0, 0))
    for i, im in enumerate(ims): strip.paste(im, (i * 64, 0))
    out = os.path.join(DST, 'cat', 'idle'); os.makedirs(out, exist_ok=True)
    strip.save(os.path.join(out, layer + '.png'), optimize=True)
    man['cat'].setdefault('idle', []).append(layer)
for c in COATS:
    idle_layer('cat-' + c, 'cf-cat-' + c + '-{f}.png'); idle_layer('ears-folded-' + c, 'cf-ears-folded-' + c + '-{f}.png'); idle_layer('tail-bobtail-' + c, 'cf-tail-bobtail-' + c + '-{f}.png')
    for p_ in PATS: idle_layer('pat-' + p_ + '-' + c, 'cf-pat-' + p_ + '-' + c + '-{f}.png')
for e_ in ['amber', 'green', 'blue', 'hazel']: idle_layer('eyes-' + e_, 'cf-eyes-' + e_ + '-{f}.png')
idle_layer('ears-clear', 'cf-ears-mask-{f}.png'); idle_layer('tail-clear', 'cf-tail-mask-{f}.png')
sizes['idle'] = {'w': 64, 'h': 64, 'n': len(IDLE), 'frames': IDLE}
man['cat_size'] = sizes
def cp(src, sub):
    os.makedirs(os.path.join(DST, sub), exist_ok=True)
    shutil.copy(src, os.path.join(DST, sub, os.path.basename(src)))
lay = json.load(open(os.path.join(SRC, 'out_room', 'room-layout-a.json')))
for f in sorted(os.listdir(os.path.join(SRC, 'out_room'))):
    if f.endswith('.png') and 'preview' not in f: cp(os.path.join(SRC, 'out_room', f), 'room')
furn = json.load(open(os.path.join(SRC, 'out_furn', 'furniture.json')))
for k, v in furn['sprites'].items(): cp(os.path.join(SRC, 'out_furn', v['file']), 'furn')
for f in sorted(os.listdir(os.path.join(SRC, 'out_props'))):
    if f.endswith('.png'): cp(os.path.join(SRC, 'out_props', f), 'props')
wand = json.load(open(os.path.join(SRC, 'out_props', 'cf-wand-cast.json')))
man['layout'] = {k: lay[k] for k in ('anchors', 'back_wall', 'calm_zone', 'depth_model', 'export', 'night', 'plates', 'seams', 'slots', 'stack_bottom_to_top', 'sunbeam', 'vanishing_point', 'wand_hook') if k in lay}
man['furn'] = furn['sprites']; man['wand'] = wand
json.dump(man, open(os.path.join(DST, 'manifest.json'), 'w'), separators=(',', ':'))
tot = sum(os.path.getsize(os.path.join(r, f)) for r, _, fs in os.walk(DST) for f in fs)
print('packed', sum(len(v) for v in man['cat'].values()), 'strips,', round(tot / 1e6, 2), 'MB')
