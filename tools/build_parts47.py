#!/usr/bin/env python3
"""Build the runtime kit for the v47 jigsaw pieces: game/assets/img/pfight/parts47/ (sprite sheets + atlas.json), from
aseprite-source/pfight/v47/ (the Aseprite art). The game's renderer is assets/pfparts.js (it uses this kit when atlas.json says version 47).

  python3 tools/build_parts47.py          (needs the Aseprite CLI once, only to render the tiles WITHOUT their glyph: env ASE=/path/to/ase.sh or aseprite)

Sheets per size (strip = the board, hand = the hand and detail views), every cell the full piece image (82 x 73 / 140 x 124) except badges:
  tiles-<size>.png    7 tiles without glyph      glyphs-<size>.png  the 7 glyphs alone (drawn unless a tag icon replaces them)
  frames-<size>.png   me | foe | env             socks-<size>.png   body-knob, body-hole, mind-knob, mind-hole, craft-knob, craft-hole (all four sides in each; crop one side)
  badges-<size>.png   lock star flip eye land    overlays-<size>.png picked | faded | now
Holes mark their cut-out with pure magenta (#ff00ff): the renderer clears those pixels. Shared files of the old kit (joints, chain glow, combo stamps, marks/) are copied so one folder is the base path.
"""
import json, os, shutil, subprocess, sys, tempfile
from PIL import Image
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V = os.path.join(R, 'aseprite-source/pfight/v47')
OUT = os.path.join(R, 'game/assets/img/pfight/parts47')
OLD = os.path.join(R, 'game/assets/img/pfight/parts')
sys.path.insert(0, os.path.join(V, 'scripts'))
import pv47
TYPES, FAMS = pv47.TYPES, pv47.FAMS
SOCKS = ['%s-%s' % (f, k) for f in FAMS for k in ('knob', 'hole')]
BADGES = ['lock', 'star', 'flip', 'eye', 'land']
FRAMES = ['me', 'foe', 'env']
OVERLAYS = ['picked', 'faded', 'now']
BASE = {'hurt': [213, 94, 0], 'guard': [0, 99, 158], 'heal': [0, 158, 115], 'charm': [204, 121, 167], 'soothe': [98, 188, 238], 'trick': [240, 228, 66], 'item': [230, 159, 0]}
SLOTS = {   # body coordinates of what the game draws into the empty slots of the art
    'strip': dict(plate=[3, 3, 16, 12], owner=[42, 3], extra=[42, 33], pips=[4, 40], pip=[5, 3, 1], k=2),
    'hand': dict(plate=[5, 5, 28, 20], owner=[73, 5], extra=[73, 57], pips=[7, 68], pip=[9, 5, 2], k=3),
}

def ase():
    for c in (os.environ.get('ASE'), shutil.which('aseprite'), '/tmp/claude-0/-home-user-gnome-venture/3833d88e-330b-5605-b374-a585ed53a4ce/scratchpad/ase.sh'):
        if c and os.path.exists(c): return c
    sys.exit('Aseprite CLI not found (set ASE=...)')

def noglyph(size, typ, tmp):
    out = os.path.join(tmp, '%s-%s.png' % (size, typ))
    subprocess.run([ase(), '-b', '--ignore-layer', 'glyph', os.path.join(V, size, 'tile-%s-%s.aseprite' % (size, typ)), '--save-as', out], check=True, capture_output=True)
    return Image.open(out).convert('RGBA')

def sheet(imgs, cell=None):
    w = cell[0] if cell else imgs[0].width; h = cell[1] if cell else imgs[0].height
    s = Image.new('RGBA', (w * len(imgs), h), (0, 0, 0, 0))
    for i, im in enumerate(imgs): s.paste(im, (i * w, 0))
    return s

def main():
    os.makedirs(OUT, exist_ok=True)
    tmp = tempfile.mkdtemp(); atlas = {'version': 47, 'note': 'built by tools/build_parts47.py from aseprite-source/pfight/v47', 'erase': [255, 0, 255], 'order': {'types': TYPES, 'frames': FRAMES, 'socks': SOCKS, 'badges': BADGES, 'overlays': OVERLAYS}, 'base': BASE, 'sizes': {}, 'sheets': {}}
    for size in ('strip', 'hand'):
        c = pv47.CFG[size]; T = c['T']; W, H = c['W'], c['H']; sl = SLOTS[size]; b = c['badge']
        sheets = {
            'tiles': sheet([noglyph(size, t, tmp) for t in TYPES]),
            'glyphs': sheet([Image.open(os.path.join(V, 'scripts/layers/glyph-%s-%s.png' % (size, t))).convert('RGBA') for t in TYPES]),
            'frames': sheet([pv47.P(size, 'frame-%s-%s' % (size, f)) for f in FRAMES]),
            'socks': sheet([pv47.P(size, 'sock-%s-%s' % (size, s)) for s in SOCKS]),
            'badges': sheet([pv47.P(size, 'badge-%s-%s' % (size, n)) for n in BADGES]),
            'overlays': sheet([pv47.P(size, 'overlay-%s-%s' % (size, o)) for o in OVERLAYS]),
        }
        files = {}
        for k, im in sheets.items():
            files[k] = '%s-%s.png' % (k, size); im.save(os.path.join(OUT, files[k]), optimize=True)
        g = pv47.P(size, 'glyph-%s-hurt' % size) if False else Image.open(os.path.join(V, 'scripts/layers/glyph-%s-hurt.png' % size)).convert('RGBA'); gb = g.getbbox()
        gc = [(gb[0] + gb[2]) / 2.0, (gb[1] + gb[3]) / 2.0]
        k = sl['k']
        atlas['sizes'][size] = {
            'piece': [W, H], 'body': [c['BW'], c['BH']], 'body_at': [T, T], 'pitch': list(c['pitch']), 'tab': [T, T],
            'cell': [W, H], 'badge': [b, b],
            'plate': {'at': [T + sl['plate'][0], T + sl['plate'][1]], 'size': [sl['plate'][2], sl['plate'][3]], 'k': k},
            'owner': [T + sl['owner'][0], T + sl['owner'][1]], 'extra': [T + sl['extra'][0], T + sl['extra'][1]],
            'icon': {'at': [int(round(gc[0] - (20 if size == 'strip' else 32) / 2.0)), int(round(gc[1] - (20 if size == 'strip' else 32) / 2.0))], 'size': [20, 20] if size == 'strip' else [32, 32]},   # where a tag icon goes: centred on the glyph
            'glyph_centre': gc,
            'socks': {s: list(pv47.region(size, s)) for s in pv47.SIDES},
        }
        atlas['sheets'][size] = files
    json.dump(atlas, open(os.path.join(OUT, 'atlas.json'), 'w'), indent=1)
    for f in ('joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png'):
        shutil.copy(os.path.join(OLD, f), os.path.join(OUT, f))
    if os.path.isdir(os.path.join(OLD, 'marks')):
        shutil.rmtree(os.path.join(OUT, 'marks'), ignore_errors=True); shutil.copytree(os.path.join(OLD, 'marks'), os.path.join(OUT, 'marks'), ignore=shutil.ignore_patterns('*preview*'))
    shutil.rmtree(tmp, ignore_errors=True)
    print('parts47:', sorted(os.listdir(OUT)))

main()
