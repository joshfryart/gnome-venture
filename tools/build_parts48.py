#!/usr/bin/env python3
"""Build the runtime kit of the v48 pieces (the beauty pass): game/assets/img/pfight/parts48/ (sprite sheets + atlas.json), from
aseprite-source/pfight/v48/ (the faces, glyphs, plate and digits) and aseprite-source/pfight/v47/ (the edge: sockets, badges, overlays, unchanged).
The game's renderer is assets/pfparts47.js (it uses this kit when atlas.json says art 48; version stays 47, the edge and sizes the board code knows); includes/pfparts_url.php picks the folder.

  python3 tools/build_parts48.py          (needs the Aseprite CLI, only to render the tiles WITHOUT their glyph layer: env ASE=/path/to/ase.sh or aseprite)
  python3 tools/build_parts48.py --check  (no Aseprite needed: the kit on disk has every sheet of its atlas, in the right size, without a semi-transparent pixel)

Sheets per size (strip = the board and the hand, hand = the detail views and any piece shown bigger than 1.4 x), every cell the full piece image (82 x 73 / 140 x 124):
  tiles      7 of mine, by type, without glyph        glyphs      their 7 glyphs (a named piece's tag icon replaces one)
  foetile    the creature's body (one for every type)  foeglyphs   the creature's 7 glyphs, by type
  envtiles   6 of the environment, by kind            envglyphs   their 6 glyphs
  socks      body-knob, body-hole, mind-knob, mind-hole, craft-knob, craft-hole (all four sides in each; crop one side)      [v47]
  badges     lock star flip eye land (11 x 11 / 18 x 18)   overlays  picked | faded | now                                    [v47]
  plate      the number plate (16 x 12 / 28 x 20)     digits      0-9 (6 x 10 / 9 x 15 each)
Holes mark their cut-out with pure magenta (#ff00ff): the renderer clears those pixels. Shared files of the old kit (joints, chain glow, combo stamps, marks/) are copied so one folder is the base path.
"""
import json, os, shutil, subprocess, sys, tempfile
from PIL import Image
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V = os.path.join(R, 'aseprite-source/pfight/v48')
V47 = os.path.join(R, 'aseprite-source/pfight/v47')
OUT = os.path.join(R, 'game/assets/img/pfight/parts48')
OLD = os.path.join(R, 'game/assets/img/pfight/parts')
sys.path.insert(0, os.path.join(V, 'scripts'))
import pv48
pv47 = pv48.pv47
TYPES, FAMS, KINDS = pv48.TYPES, pv48.FAMS, pv48.KINDS
SOCKS = ['%s-%s' % (f, k) for f in FAMS for k in ('knob', 'hole')]
BADGES = ['lock', 'star', 'flip', 'eye', 'land']
OVERLAYS = ['picked', 'faded', 'now']
BASE = {'hurt': [213, 94, 0], 'guard': [0, 99, 158], 'heal': [0, 158, 115], 'charm': [204, 121, 167], 'soothe': [98, 188, 238], 'trick': [240, 228, 66], 'item': [230, 159, 0]}
SHARED = ('joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png')
SHEETS = ('tiles', 'glyphs', 'foetile', 'foeglyphs', 'envtiles', 'envglyphs', 'socks', 'badges', 'overlays', 'plate', 'digits')

def ase():
    for c in (os.environ.get('ASE'), shutil.which('aseprite')):
        if c and os.path.exists(c): return c
    sys.exit('Aseprite CLI not found (set ASE=/path/to/ase.sh; aseprite-source/HANDOFF.md says how to unpack the AppImage)')

def noglyph(size, name, tmp):
    out = os.path.join(tmp, '%s.png' % name)
    subprocess.run([ase(), '-b', '--ignore-layer', 'glyph', os.path.join(V, size, name + '.aseprite'), '--save-as', out], check=True, capture_output=True)
    return Image.open(out).convert('RGBA')

def sheet(imgs):
    w, h = imgs[0].size
    s = Image.new('RGBA', (w * len(imgs), h), (0, 0, 0, 0))
    for i, im in enumerate(imgs): s.paste(im, (i * w, 0))
    return s

def check():
    bad = []
    try: A = json.load(open(os.path.join(OUT, 'atlas.json')))
    except Exception as e: print('FAIL atlas.json:', e); return 1
    if A.get("version") != 47 or A.get("art") != 48: bad.append("atlas version %r art %r, want 47 and 48 (version = the edge and sizes the board code knows, art = the pass)" % (A.get("version"), A.get("art")))
    n = {'tiles': 7, 'glyphs': 7, 'foetile': 1, 'foeglyphs': 7, 'envtiles': 6, 'envglyphs': 6, 'socks': 6, 'overlays': 3}
    for size in ('strip', 'hand'):
        z = A['sizes'][size]; W, H = z['piece']
        if [W, H] != [pv47.CFG[size]['W'], pv47.CFG[size]['H']] or z['socks'] != {s: list(pv47.region(size, s)) for s in pv47.SIDES}: bad.append('%s: the piece size or the socket crops are not v47\'s' % size)
        for k in SHEETS:
            f = os.path.join(OUT, A['sheets'][size].get(k, '?'))
            if not os.path.isfile(f): bad.append('%s: no %s sheet' % (size, k)); continue
            im = Image.open(f).convert('RGBA')
            want = (W * n[k], H) if k in n else (z['badge'][0] * 5, z['badge'][1]) if k == 'badges' else tuple(z['plate']['size']) if k == 'plate' else (z['digit'][0] * 10, z['digit'][1])
            if im.size != want: bad.append('%s %s: %s, want %s' % (size, k, im.size, want))
            if any(0 < a < 255 for a in im.getchannel('A').getdata()): bad.append('%s %s: a semi-transparent pixel' % (size, k))
        for k in ('socks', 'badges', 'overlays'):   # the edge is v47's, byte for byte in pixels
            a = Image.open(os.path.join(OUT, A['sheets'][size][k])).convert('RGBA'); b = Image.open(os.path.join(R, 'game/assets/img/pfight/parts47', '%s-%s.png' % (k, size))).convert('RGBA')
            if a.size != b.size or a.tobytes() != b.tobytes(): bad.append('%s %s differs from the v47 kit (the edge must stay the same)' % (size, k))
    for f in SHARED:
        if not os.path.isfile(os.path.join(OUT, f)): bad.append('missing ' + f)
    for b in bad: print('FAIL', b)
    return 1 if bad else 0

def main():
    os.makedirs(OUT, exist_ok=True)
    tmp = tempfile.mkdtemp()
    atlas = {"version": 47, "art": 48, 'note': 'built by tools/build_parts48.py from aseprite-source/pfight/v48 (faces) and v47 (edges)', 'erase': [255, 0, 255],
             'order': {'types': TYPES, 'kinds': KINDS, 'socks': SOCKS, 'badges': BADGES, 'overlays': OVERLAYS}, 'base': BASE, 'sizes': {}, 'sheets': {}}
    for size in ('strip', 'hand'):
        c = pv47.CFG[size]; T = c['T']; W, H = c['W'], c['H']; sl = pv48.SLOTS[size]; b = c['badge']; k = sl['k']
        sheets = {
            'tiles': sheet([noglyph(size, 'tile-%s-%s' % (size, t), tmp) for t in TYPES]),
            'glyphs': sheet([pv48.glyph(size, 'me', t) for t in TYPES]),
            'foetile': sheet([noglyph(size, 'foe-%s-hurt' % size, tmp)]),
            'foeglyphs': sheet([pv48.glyph(size, 'foe', t) for t in TYPES]),
            'envtiles': sheet([noglyph(size, 'env-%s-%s' % (size, kd), tmp) for kd in KINDS]),
            'envglyphs': sheet([pv48.glyph(size, 'env', kd) for kd in KINDS]),
            'socks': sheet([pv47.P(size, 'sock-%s-%s' % (size, s)) for s in SOCKS]),
            'badges': sheet([pv47.P(size, 'badge-%s-%s' % (size, n)) for n in BADGES]),
            'overlays': sheet([pv47.P(size, 'overlay-%s-%s' % (size, o)) for o in OVERLAYS]),
            'plate': pv48.P(size, 'plate-' + size),
            'digits': pv48.P(size, 'digits-' + size),
        }
        files = {}
        for name, im in sheets.items():
            files[name] = '%s-%s.png' % (name, size); im.save(os.path.join(OUT, files[name]), optimize=True)
        isz = 20 if size == 'strip' else 32
        gc = [(W - 1) / 2.0, (H - 1) / 2.0]   # every glyph is centred on the body
        atlas['sizes'][size] = {
            'piece': [W, H], 'body': [c['BW'], c['BH']], 'body_at': [T, T], 'pitch': list(c['pitch']), 'tab': [T, T],
            'cell': [W, H], 'badge': [b, b],
            'plate': {'at': [T + sl['plate'][0], T + sl['plate'][1]], 'size': [sl['plate'][2], sl['plate'][3]], 'k': k},
            'digit': [3 * k, 5 * k],
            'owner': [T + sl['owner'][0], T + sl['owner'][1]], 'extra': [T + sl['extra'][0], T + sl['extra'][1]],
            'icon': {'at': [int(round(gc[0] + .5 - isz / 2.0)), int(round(gc[1] + .5 - isz / 2.0))], 'size': [isz, isz]},   # where a tag icon goes: centred on the body
            'glyph_centre': gc,
            'socks': {s: list(pv47.region(size, s)) for s in pv47.SIDES},
        }
        atlas['sheets'][size] = files
    json.dump(atlas, open(os.path.join(OUT, 'atlas.json'), 'w'), indent=1)
    for f in SHARED: shutil.copy(os.path.join(OLD, f), os.path.join(OUT, f))
    if os.path.isdir(os.path.join(OLD, 'marks')):
        shutil.rmtree(os.path.join(OUT, 'marks'), ignore_errors=True); shutil.copytree(os.path.join(OLD, 'marks'), os.path.join(OUT, 'marks'), ignore=shutil.ignore_patterns('*preview*'))
    shutil.rmtree(tmp, ignore_errors=True)
    print('parts48:', sorted(os.listdir(OUT)))

sys.exit(check() if '--check' in sys.argv else main())
