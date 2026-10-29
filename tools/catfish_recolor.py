#!/usr/bin/env python3
"""catfish_recolor.py: palette-swap the grey Cat Fish templates into the 8 coat colours.

Usage: python3 tools/catfish_recolor.py [--in DIR] [--out DIR] [--glob 'cf-cat-grey-*.png']
           [--coats grey,black,...] [--eye amber|green|blue|hazel] [--check]

Input files must contain '-grey-' in the name; output replaces it with '-<coat>-'
(cf-cat-grey-idleA.png -> cf-cat-orange-idleA.png). Default --in aseprite-source/catfish/test,
default --out aseprite-source/catfish/test/recolor/ (never game/assets).

Tones: aseprite-source/catfish/tones.json maps role -> template hex (shade, base, light, gloss).
Optional aseprite-source/catfish/tones_overlays.json adds more roles (role -> hex):
  - plain roles (any name): the hex passes through unchanged (fixed accent);
  - coat roles: mark_dark (coat deep), mark_mid (coat shade), mark_base (coat base),
    mark_light (coat light), mark_pale (coat gloss): hex is recoloured from the coat ramp;
    also 'coat_<shade|base|light|gloss|deep|bounce>' for the same;
  - eye_ring: recoloured with --eye (amber/green/blue/hazel) if given, else unchanged.
Fixed accents of the cat (pink, eye cream, umber, gold thread, #000000 border) always pass through.

Ramp recipe = GV.ramp in aseprite-source/gvlib/gvlib.lua: lights rotate toward yellow-orange (hue 45),
shade/deep toward red-violet (hue 285), bounce is a warmer shade. Lightness is clamped to 0.07..0.94 so
no tone is ever #000000/#ffffff, and a minimum step keeps the 4 tones apart on white and black coats.
Deterministic, alpha untouched (0/255 only). Exit code 1 on --check failure.
"""
import argparse, colorsys, glob, json, os, sys
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CF = os.path.join(ROOT, 'aseprite-source', 'catfish')

# 8 coats: name -> base hex (the 'base' tone; mid-felt colour). Grey is the template itself.
COATS = {
    'grey':       '#8a859b',
    'black':      '#4a4352',   # charcoal-plum felt, never #000000
    'white':      '#e0d9cf',   # warm oat white
    'orange':     '#e0832a',
    'cream':      '#e8d2a0',
    'brown':      '#8a5a3c',
    'silver-blue': '#8aa0b8',
    'ginger-red': '#c4482a',
}
# Fixed accents, never recoloured (from the cf_test.lua comment).
FIXED = {'#e8909e', '#c66a80', '#f2e4c0', '#2a1a10', '#4a2c1a', '#74462a', '#f5cf6a', '#e8a317', '#000000'}
EYES = {'amber': '#d9902a', 'green': '#6aa84a', 'blue': '#5a8fd0', 'hazel': '#9a7a3a'}
MAXCOL = 24


def h2rgb(h):
    h = h.lstrip('#'); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))

def hex_(c): return '#%02x%02x%02x' % tuple(c)

def to_hsl(hx):
    r, g, b = (v / 255 for v in h2rgb(hx))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return h * 360, s, l

def from_hsl(h, s, l):
    r, g, b = colorsys.hls_to_rgb((h % 360) / 360, min(max(l, 0), 1), min(max(s, 0), 1))
    return hex_([min(254, max(1, int(v * 255 + 0.5))) for v in (r, g, b)])

def toward(h, t, a):
    d = (t - h + 540) % 360 - 180
    return h + max(-a, min(a, d))

def ramp(base):
    """Hue-shifted 4-tone (+deep, bounce) ramp. Mirrors GV.ramp, with wider steps than gvlib so the
    felt reads at 16 px, and a minimum lightness gap so pale and dark coats keep 4 distinct tones."""
    h, s, l = to_hsl(base)
    lo, hi = 0.07, 0.94
    l = min(max(l, 0.2), 0.88)
    sh_l = l * 0.68
    li_l = l + (1 - l) * 0.32
    gl_l = l + (1 - l) * 0.70
    de_l = l * 0.46
    # keep tones apart (white: lift gap down; black: push up)
    gap = 0.075
    if gl_l > hi: gl_l = hi
    if li_l > gl_l - gap: li_l = gl_l - gap
    if li_l < l + gap: li_l = l + gap; gl_l = max(gl_l, li_l + gap)
    if gl_l > hi: gl_l = hi; li_l = gl_l - gap; l = min(l, li_l - gap)
    if sh_l > l - gap: sh_l = l - gap
    de_l = min(de_l, sh_l - 0.05)
    sh_l, de_l = max(sh_l, lo + 0.04), max(de_l, lo)
    sh = toward(h, 285, 12)
    out = {
        'base': from_hsl(h, s, l),
        'shade': from_hsl(sh, min(1, s * 1.05), sh_l),
        'deep': from_hsl(toward(h, 285, 25), s, de_l),
        'bounce': from_hsl(toward(sh, 30, 12), s, sh_l * 1.08),
        'light': from_hsl(toward(h, 45, 12), min(1, s * 1.05), li_l),
        'gloss': from_hsl(toward(h, 45, 20), min(1, s * 1.1), gl_l),
    }
    # the base keeps the stated hex unless clamped
    if l == to_hsl(base)[2]: out['base'] = base
    return out

COAT_ROLES = {'mark_dark': 'deep', 'mark_mid': 'shade', 'mark_base': 'base', 'mark_light': 'light', 'mark_pale': 'gloss'}


def load(path, required=False):
    if not os.path.exists(path):
        if required: sys.exit('missing ' + path)
        return {}
    with open(path) as f: return {k: v.lower() for k, v in json.load(f).items() if not k.startswith('_')}


def build_map(coat, base_tones, overlays, eye):
    """template hex -> output hex for this coat."""
    r = ramp(COATS[coat])
    if coat == 'grey':  # grey is the template, exact
        r.update({k: base_tones[k] for k in ('shade', 'base', 'light', 'gloss')})
        r['deep'] = ramp(COATS['grey'])['deep']
    m = {base_tones[k]: r[k] for k in ('shade', 'base', 'light', 'gloss')}
    for role, hx in overlays.items():
        if role in COAT_ROLES: m[hx] = r[COAT_ROLES[role]]
        elif role.startswith('coat_') and role[5:] in r: m[hx] = r[role[5:]]
        elif role == 'eye_ring' and eye: m[hx] = EYES[eye]
        elif role in base_tones: m[hx] = r[role]
        else: m.setdefault(hx, hx)
    return m


def recolor(img, cmap):
    a = np.array(img.convert('RGBA'))
    out = a.copy(); unmapped = {}
    op = a[..., 3] > 0
    for y, x in zip(*np.nonzero(op)):
        k = hex_(a[y, x, :3])
        if k in cmap: out[y, x, :3] = h2rgb(cmap[k])
        elif k not in FIXED: unmapped[k] = unmapped.get(k, 0) + 1
    return out, unmapped


def check(name, src, out, unmapped, base_tones):
    errs, warns = [], []
    al = np.unique(out[..., 3])
    if any(v not in (0, 255) for v in al): errs.append('semi-alpha')
    op = out[out[..., 3] > 0][:, :3]
    cols = {hex_(c) for c in np.unique(op, axis=0)}
    if len(cols) > MAXCOL: errs.append('%d colours > %d' % (len(cols), MAXCOL))
    sb = int((np.array(src.convert('RGBA'))[..., :3] == 0).all(-1)[np.array(src.convert('RGBA'))[..., 3] > 0].sum())
    ob = int((op == 0).all(-1).sum())
    if ob != sb: errs.append('#000000 count changed %d -> %d' % (sb, ob))
    if (op == 255).all(-1).any(): errs.append('pure #ffffff present')
    if unmapped: warns.append('unmapped: ' + ', '.join('%s x%d' % kv for kv in sorted(unmapped.items())))
    return errs, warns, len(cols)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--in', dest='indir', default=os.path.join(CF, 'test'))
    ap.add_argument('--out', default=os.path.join(CF, 'test', 'recolor'))
    ap.add_argument('--glob', default='cf-cat-grey-*.png')
    ap.add_argument('--coats', default=','.join(COATS))
    ap.add_argument('--eye', choices=sorted(EYES))
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--tones', default=os.path.join(CF, 'tones.json'))
    ap.add_argument('--overlays', default=os.path.join(CF, 'tones_overlays.json'))
    a = ap.parse_args(argv)
    base_tones = load(a.tones, True)
    overlays = load(a.overlays)
    files = sorted(glob.glob(os.path.join(a.indir, a.glob)))
    if not files: sys.exit('no input files for ' + a.glob)
    os.makedirs(a.out, exist_ok=True)
    bad = n = 0; warned = set()
    for coat in a.coats.split(','):
        if coat not in COATS: sys.exit('unknown coat ' + coat)
        cmap = build_map(coat, base_tones, overlays, a.eye)
        for f in files:
            name = os.path.basename(f)
            if '-grey-' not in name: sys.exit('input needs -grey- in name: ' + name)
            src = Image.open(f)
            out, unm = recolor(src, cmap)
            Image.fromarray(out, 'RGBA').save(os.path.join(a.out, name.replace('-grey-', '-%s-' % coat)), optimize=False)
            n += 1
            if a.check:
                errs, warns, nc = check(name, src, out, unm, base_tones)
                for w in warns:
                    if (name, w) not in warned: warned.add((name, w)); print('WARN %s: %s' % (name, w))
                for e in errs: print('FAIL %s %s: %s' % (coat, name, e)); bad += 1
    print('wrote %d files to %s%s' % (n, a.out, ' (check %s)' % ('FAILED' if bad else 'ok') if a.check else ''))
    return 1 if bad else 0

if __name__ == '__main__':
    sys.exit(main())
