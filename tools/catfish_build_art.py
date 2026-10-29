#!/usr/bin/env python3
"""catfish_build_art.py: build the whole Cat Fish art set with its final names from the test art.

Usage: python3 tools/catfish_build_art.py [--in DIR] [--out DIR] [--check] [--install [DIR]] [--verify DIR]

  --in DIR       source art (default aseprite-source/catfish/test)
  --out DIR      where the set is built (default: a new temp dir; printed at the end). Nothing in game/ is touched.
  --check        validate every output file (RGBA, alpha 0/255 only, size per kind from claude/catfish-art-brief.md, names against the brief's
                 naming list, every required file present, no stray file); exit 1 on any failure
  --install [D]  after a clean check, copy the set into D (default game/assets/img/catfish). This is the only way the tool writes into game/.
  --verify DIR   no build: run the checks on an existing folder (e.g. the installed one)

What it does: copies the hand-drawn pieces (fish, rod, icons, upgrade icons, badges, ribbons, tile, banner, room and overlays, ear/tail masks,
Cat Book unknown head, eye colour files) and runs tools/catfish_recolor.py for the cat frames (8 coats, grey is the template), patterns,
folded ears, bobtail and the Cat Book heads. The eye-ring template is not shipped. Writes manifest.json (file, size, sha1, width, height) into --out.
"""
import argparse, glob, hashlib, io, json, os, re, shutil, sys, tempfile
sys.dont_write_bytecode = True
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import numpy as np
from PIL import Image
import catfish_recolor as R

SRC = os.path.join(R.CF, 'test')
DEST = os.path.join(ROOT, 'game', 'assets', 'img', 'catfish')
BRIEF = os.path.join(ROOT, 'claude', 'catfish-art-brief.md')
FRAMES = ['idleA', 'idleB', 'wiggle', 'stalk', 'pounce', 'catch', 'nap', 'bored']   # CATFISH_FRAMES in game/includes/catfish.php
KEY_FRAMES = ['idleA', 'pounce', 'catch', 'nap', 'stalk']                           # CATFISH_PATTERN_FRAMES
EYES = sorted(R.EYES)
COATS = list(R.COATS)
HAND = ['cf-fish-[1-5].png', 'cf-rod.png', 'cf-ico-*.png', 'cf-up-*.png', 'cf-badge-*.png', 'cf-ribbon-*.png', 'cf-tile.png', 'cf-banner.png',
        'cf-room.png', 'cf-room-*.png', 'cf-bookhead-unknown.png']
# recolour passes: (glob in --in, what it makes)
RECOLOR = ['cf-cat-grey-*.png', 'cf-pat-*-grey-*.png', 'cf-ears-folded-*.png', 'cf-tail-bobtail-*.png', 'cf-bookhead-grey.png', 'cf-eyes-[!r]*.png', 'cf-*-mask-*.png']


def brief_keys():
    """The key lists of the brief's file-name section: upgrade keys, badge keys, ribbon tiers."""
    t = open(BRIEF, encoding='utf-8').read()
    out = {}
    for name, rx in (('up', r'cf-up-<upgrade key>\.png` \(keys: ([a-z_ ]+)\)'), ('badge', r'cf-badge-<key>\.png` \(keys: ([a-z_0-9 ]+)\)'),
                     ('ribbon', r'cf-ribbon-<tier>\.png` \(([a-z ]+)\)')):
        m = re.search(rx, t)
        if not m: sys.exit('the brief (claude/catfish-art-brief.md) has no naming list for ' + name)
        out[name] = m.group(1).split()
    return out


def expected():
    """file name -> (width, height) for every file the game can ask for."""
    k = brief_keys(); e = {}
    for c in COATS:
        for f in FRAMES: e['cf-cat-%s-%s.png' % (c, f)] = (64, 64)
        for f in KEY_FRAMES:
            for p in R.PATTERNS: e['cf-pat-%s-%s-%s.png' % (p, c, f)] = (64, 64)
            e['cf-ears-folded-%s-%s.png' % (c, f)] = (64, 64)
            e['cf-tail-bobtail-%s-%s.png' % (c, f)] = (64, 64)
        e['cf-bookhead-%s.png' % c] = (32, 32)
    for f in KEY_FRAMES:
        e['cf-ears-mask-%s.png' % f] = (64, 64); e['cf-tail-mask-%s.png' % f] = (64, 64)
    for y in EYES:
        for f in FRAMES: e['cf-eyes-%s-%s.png' % (y, f)] = (64, 64)
    for n in range(1, 6): e['cf-fish-%d.png' % n] = (48, 48)
    e['cf-rod.png'] = (48, 64)
    e['cf-ico-kibble.png'] = e['cf-ico-yarn.png'] = e['cf-bookhead-unknown.png'] = (32, 32)
    for key in k['up']: e['cf-up-%s.png' % key] = (64, 64)
    for key in k['badge']: e['cf-badge-%s.png' % key] = (64, 64)
    for t in k['ribbon']: e['cf-ribbon-%s.png' % t] = (64, 64)
    e['cf-tile.png'] = (64, 64); e['cf-banner.png'] = (480, 120)
    e['cf-room.png'] = (320, 200)
    for o in ('sunbeam', 'rug', 'scratch', 'window'): e['cf-room-%s.png' % o] = (320, 200)
    return e


def category(name):
    for p, c in (('cf-cat-', 'cat bodies'), ('cf-pat-', 'patterns'), ('cf-ears-mask', 'masks'), ('cf-tail-mask', 'masks'), ('cf-ears-folded', 'folded ears'),
                 ('cf-tail-bobtail', 'bobtails'), ('cf-eyes-', 'eyes'), ('cf-fish-', 'fish'), ('cf-rod', 'rod'), ('cf-ico-', 'icons'), ('cf-up-', 'upgrade icons'),
                 ('cf-badge-', 'badges'), ('cf-ribbon-', 'ribbons'), ('cf-tile', 'tile'), ('cf-banner', 'banner'), ('cf-room', 'room'), ('cf-bookhead-', 'book heads')):
        if name.startswith(p): return c
    return 'other'


def check_dir(d):
    """List of problems in the folder d (empty = good)."""
    bad = []; exp = expected()
    have = sorted(f for f in os.listdir(d) if f.endswith('.png'))
    for f in sorted(set(exp) - set(have)): bad.append('missing required file ' + f)
    for f in sorted(set(have) - set(exp)): bad.append('name not in the brief naming list: ' + f)
    for f in have:
        if f not in exp: continue
        try: im = Image.open(os.path.join(d, f)); im.load()
        except Exception as ex: bad.append('%s: unreadable (%s)' % (f, ex)); continue
        if im.size != exp[f]: bad.append('%s: size %dx%d, want %dx%d' % (f, im.width, im.height, *exp[f]))
        a = np.array(im.convert('RGBA'))
        if any(v not in (0, 255) for v in np.unique(a[..., 3])): bad.append(f + ': semi-transparent pixels')
        if not (a[..., 3] > 0).any() and not f.startswith('cf-eyes-'): bad.append(f + ': fully transparent')
        if (a[(a[..., 3] > 0)][:, :3] == [255, 0, 255]).all(-1).any(): bad.append(f + ': placeholder #ff00ff present')
    return bad


def build(src, out):
    os.makedirs(out, exist_ok=True)
    for pat in HAND:
        for f in sorted(glob.glob(os.path.join(src, pat))): shutil.copyfile(f, os.path.join(out, os.path.basename(f)))
    for g in RECOLOR:
        if not glob.glob(os.path.join(src, g)): sys.exit('no source art for ' + g)
        buf = io.StringIO(); old = sys.stdout; sys.stdout = buf
        try: rc = R.main(['--in', src, '--out', out, '--glob', g, '--check'])
        finally: sys.stdout = old
        if rc: sys.exit('recolour failed for %s:\n%s' % (g, buf.getvalue()))


def manifest(out):
    rows = []
    for f in sorted(os.listdir(out)):
        if not f.endswith('.png'): continue
        b = open(os.path.join(out, f), 'rb').read(); im = Image.open(os.path.join(out, f))
        rows.append({'file': f, 'size': len(b), 'sha1': hashlib.sha1(b).hexdigest(), 'width': im.width, 'height': im.height})
    with open(os.path.join(out, 'manifest.json'), 'w') as fh: json.dump({'count': len(rows), 'files': rows}, fh, indent=1)
    return rows


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--in', dest='src', default=SRC)
    ap.add_argument('--out')
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--install', nargs='?', const=DEST, metavar='DIR')
    ap.add_argument('--verify', metavar='DIR')
    a = ap.parse_args(argv)
    if a.verify:
        bad = check_dir(a.verify)
        for b in bad: print('FAIL ' + b)
        print('verify %s: %s' % (a.verify, 'FAILED (%d problems)' % len(bad) if bad else 'ok'))
        return 1 if bad else 0
    out = a.out or tempfile.mkdtemp(prefix='catfish-art-')
    build(a.src, out)
    rows = manifest(out)
    counts = {}
    for r in rows: counts[category(r['file'])] = counts.get(category(r['file']), 0) + 1
    print('built %d files in %s' % (len(rows), out))
    print('  ' + ', '.join('%s %d' % kv for kv in sorted(counts.items())))
    rc = 0
    if a.check or a.install:
        bad = check_dir(out)
        for b in bad: print('FAIL ' + b)
        print('check: ' + ('FAILED (%d problems)' % len(bad) if bad else 'ok'))
        rc = 1 if bad else 0
    if a.install and not rc:
        os.makedirs(a.install, exist_ok=True)
        for r in rows: shutil.copyfile(os.path.join(out, r['file']), os.path.join(a.install, r['file']))
        print('installed %d files into %s' % (len(rows), a.install))
    return rc


if __name__ == '__main__':
    sys.exit(main())
