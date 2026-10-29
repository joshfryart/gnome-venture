#!/usr/bin/env python3
"""catfish_recolor.py: palette-swap the grey Cat Fish templates into the 8 coat colours.

Usage: python3 tools/catfish_recolor.py [--in DIR] [--out DIR] [--glob 'cf-cat-grey-*.png']
           [--coats grey,black,...] [--eye amber|green|blue|hazel] [--check]

Handled by file name (default --glob 'cf-*.png' in --in):
  cf-cat-grey-<f>, cf-pat-<pattern>-grey-<f>  -> '-grey-' becomes '-<coat>-' for all 8 coats
  cf-ears-folded-<f>, cf-tail-bobtail-<f>     -> cf-ears-folded-<coat>-<f> (parts use the grey tones: recoloured like the body)
  cf-bookhead-grey[-*]                        -> cf-bookhead-<coat>[-*] (Cat Book cell head, grey tones + fixed accents)
  cf-eyes-<amber|green|blue|hazel>-<f>        -> copied as is; cf-eyes-ring-<f> -> cf-eyes-ring-<eye>-<f> tinted with --eye
  cf-*-mask-<f>                               -> copied unchanged
Other files (fish, rod, icons) are skipped.
Compositor: --compose --coat X [--pattern P] [--eyes E | L,R] [--ears folded] [--tail bobtail] --frame F --out file.png
builds base coat, clears the mask regions (also from the pattern), adds parts, pattern, eyes, in that order. Default --in aseprite-source/catfish/test,
default --out aseprite-source/catfish/test/recolor/ (never game/assets).

Tones: aseprite-source/catfish/tones.json maps role -> template hex (shade, base, light, gloss).
Optional aseprite-source/catfish/tones_overlays.json adds more roles: role -> hex, or role -> {hex, derive}.
When 'derive' is present it decides the recolour (e.g. patch_white_edge derives coat_deep, so the 1 px rim of a
white/cream patch follows the coat's deep tone); otherwise the role name does. Kinds:
  - plain roles (any name): the hex passes through unchanged (fixed accent);
  - coat roles: mark_dark (coat deep), mark_mid (coat shade), mark_base (coat base),
    mark_light (coat light), mark_pale (coat gloss): hex is recoloured from the coat ramp;
    also 'coat_<shade|base|light|gloss|deep|bounce>' for the same;
  - eye_ring: recoloured with --eye (amber/green/blue/hazel) if given, else unchanged.
Mask files (cf-ears-mask-*, cf-tail-mask-*; white #ffffff, role 'mask') are not art: copied through unchanged
and never checked or recoloured.
Fixed accents of the cat (pink, eye cream, umber, gold thread, #000000 border) always pass through.

Ramp recipe = GV.ramp in aseprite-source/gvlib/gvlib.lua: lights rotate toward yellow-orange (hue 45),
shade/deep toward red-violet (hue 285), bounce is a warmer shade. Lightness is clamped to 0.07..0.94 so
no tone is ever #000000/#ffffff, and a minimum step keeps the 4 tones apart on white and black coats.
Deterministic, alpha untouched (0/255 only). Exit code 1 on --check failure.
"""
import argparse, colorsys, glob, json, os, shutil, sys
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CF = os.path.join(ROOT, 'aseprite-source', 'catfish')

# 8 coats: name -> base hex (the 'base' tone; mid-felt colour). Grey is the template itself.
COATS = {
    'grey':       '#8a859b',
    'black':      '#4a4352',   # charcoal-plum felt, never #000000
    'white':      '#e0d9cf',   # warm oat white
    'orange':     '#e8701a',
    'cream':      '#f0dca0',
    'brown':      '#8a5a3c',
    'silver-blue': '#8aa0b8',
    'lilac':      '#b4a0d6',   # pale violet-grey; its hue-shifted ramp stays apart from grey and silver-blue in all 4 tones
}
# Fixed accents, never recoloured (from the cf_test.lua comment).
FIXED = {'#e8909e', '#c66a80', '#f2e4c0', '#2a1a10', '#4a2c1a', '#74462a', '#f5cf6a', '#e8a317', '#000000'}
# The fish held in cf-cat-grey-catch.png is a fixed accent (orange/gold body, never recoloured). Read from
# that PNG; tones.json / tones_overlays.json belong to the art side, so the list lives here.
FIXED_EXTRA = {'#dc6f2c', '#e38111', '#f2c14e', '#ac3b1d', '#f2a860', '#ffc27a', '#fff1c8'}
FIXED |= FIXED_EXTRA
# iris colours, same as EYES in aseprite-source/catfish/cf_overlays.lua (cf-eyes-<eye>-<frame>.png is final art)
EYES = {'amber': '#e0902a', 'green': '#7cb342', 'blue': '#4f9fe0', 'hazel': '#a89436'}
MAXCOL = 24          # per recoloured file
COMPOSE_MAXCOL = 28  # per composited cat
# Odd-eyed split column per frame: the left eye is x < split, the right eye x >= split. This is the midpoint column between the
# two eye clusters of aseprite-source/catfish/test/cf-eyes-ring-<frame>.png (see eye_split(); tests/catfish.sh recomputes it and
# checks game/assets/catfish.css). Closed-eye frames (catch, nap) have no eye pixels, so they keep the old 25.
# 2.1.05 frames (swatA, swatB, jump, stretch from the ring PNGs; happy, yawn, washA, washB have closed eyes and carry the split named in frames-alias-s3/s4.json; blink is an alias of idleA: 25).
EYE_SPLIT = {'idleA': 25, 'idleB': 26, 'wiggle': 40, 'stalk': 40, 'pounce': 41, 'catch': 25, 'nap': 25, 'bored': 24,
             'swatA': 23, 'swatB': 32, 'jump': 32, 'happy': 25, 'blink': 25, 'yawn': 25, 'stretch': 40, 'washA': 25, 'washB': 27}
PATTERNS = ('tabby', 'tuxedo', 'calico', 'pointed', 'spotted')


def eye_split(path):
    """Midpoint column between the two eye clusters of a ring/eyes PNG (columns with opaque pixels, split at the widest gap), or None if there are no two clusters."""
    a = np.array(Image.open(path).convert('RGBA'))[..., 3] > 0
    cols = np.nonzero(a.any(0))[0]
    if len(cols) < 2: return None
    gaps = np.diff(cols)
    i = int(np.argmax(gaps))
    if gaps[i] < 2: return None
    return int((cols[i] + cols[i + 1]) // 2)


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

UNKNOWN_SEEN = set()
COAT_ROLES = {'mark_dark': 'deep', 'mark_mid': 'shade', 'mark_base': 'base', 'mark_light': 'light', 'mark_pale': 'gloss'}


def load(path, required=False):
    if not os.path.exists(path):
        if required: sys.exit('missing ' + path)
        return {}
    with open(path) as f: raw = json.load(f)
    # values are either a hex string, or {"hex":..., "derive": ...} (tones_overlays.json); normalise to role -> (hex, derive)
    out = {}
    for k, v in raw.items():
        if k.startswith('_'): continue
        out[k] = (v['hex'].lower(), v.get('derive', 'fixed')) if isinstance(v, dict) else (v.lower(), None)
    return out


def build_map(coat, base_tones, overlays, eye):
    """template hex -> output hex for this coat."""
    r = ramp(COATS[coat])
    if coat == 'grey':  # grey is the template, exact
        r.update({k: base_tones[k] for k in ('shade', 'base', 'light', 'gloss')})
        r['deep'] = ramp(COATS['grey'])['deep']
    m = {base_tones[k]: r[k] for k in ('shade', 'base', 'light', 'gloss')}
    for role, (hx, derive) in overlays.items():
        d = derive or role          # explicit 'derive' wins; plain-string files fall back to the role name
        if d == 'mask' or role == 'mask': continue  # masks are not art, handled by file name
        if coat == 'grey' and (d in COAT_ROLES or d.startswith('coat_')): m[hx] = hx  # grey is the template itself
        elif d in COAT_ROLES: m[hx] = r[COAT_ROLES[d]]
        elif d.startswith('coat_') and d[5:] in r: m[hx] = r[d[5:]]
        elif d == 'eye_ring' and eye: m[hx] = EYES[eye]
        elif d in base_tones: m[hx] = r[d]
        else:
            if d not in ('fixed', 'eye_ring') and not d.startswith('eye_') and role not in UNKNOWN_SEEN:
                UNKNOWN_SEEN.add(role); print('WARN overlay role %s: unknown derive %r, left fixed' % (role, d), file=sys.stderr)
            m.setdefault(hx, hx)  # fixed
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


def is_mask(name): return '-mask-' in name

def check(name, src, out, unmapped, base_tones):
    errs, warns = [], []
    al = np.unique(out[..., 3])
    if any(v not in (0, 255) for v in al): errs.append('semi-alpha')
    op = out[out[..., 3] > 0][:, :3]
    cols = {hex_(c) for c in np.unique(op, axis=0)} if len(op) else set()
    if len(cols) > MAXCOL: errs.append('%d colours > %d' % (len(cols), MAXCOL))
    sa = np.array(src.convert('RGBA'))
    sb = int((sa[..., :3] == 0).all(-1)[sa[..., 3] > 0].sum())
    ob = int((op == 0).all(-1).sum())
    if ob != sb: errs.append('#000000 count changed %d -> %d' % (sb, ob))
    if (op == 255).all(-1).any(): errs.append('pure #ffffff present')
    if unmapped: warns.append('unmapped: ' + ', '.join('%s x%d' % kv for kv in sorted(unmapped.items())))
    return errs, warns, len(cols)


def classify(name):
    """-> kind: 'mask', 'eyes', 'ring', 'coat' (has -grey-), 'part' (ears/tail), 'head' (bookhead), or None (skip)."""
    if not name.startswith('cf-') or not name.endswith('.png'): return None
    if is_mask(name): return 'mask'
    if name.startswith('cf-eyes-ring-'): return 'ring'
    if name.startswith('cf-eyes-'): return 'eyes'
    if name.startswith(('cf-cat-', 'cf-pat-')) and '-grey-' in name: return 'coat'
    if name.startswith(('cf-ears-folded-', 'cf-tail-bobtail-')): return 'part'
    if name.startswith('cf-bookhead-grey'): return 'head'
    return None


def part_name(name, coat):
    """cf-ears-folded-idleA.png -> cf-ears-folded-<coat>-idleA.png"""
    stem = name[:-4].split('-')       # cf, ears, folded, idleA
    return '-'.join(stem[:3] + [coat] + stem[3:]) + '.png'


def _layer(path, cmap):
    return recolor(Image.open(path), cmap)[0]


def compose(coat, frame, indir=os.path.join(CF, 'test'), pattern=None, eyes=None, ears=None, tail=None,
            tones=os.path.join(CF, 'tones.json'), overlays=os.path.join(CF, 'tones_overlays.json')):
    """Layered cat as an RGBA array: base, clear masks, parts, pattern, eyes. No new drawing."""
    base_tones = {k: v[0] for k, v in load(tones, True).items()}
    cmap = build_map(coat, base_tones, load(overlays), None)
    def need(n):
        p = os.path.join(indir, n)
        if not os.path.exists(p): sys.exit('missing %s (frame %r not drawn for this layer?)' % (n, frame))
        return p
    img = _layer(need('cf-cat-grey-%s.png' % frame), cmap)
    pat = _layer(need('cf-pat-%s-grey-%s.png' % (pattern, frame)), cmap) if pattern and pattern != 'none' else None
    parts = []
    for kind, val in (('ears', ears), ('tail', tail)):
        if not val or val == 'none': continue
        if val != {'ears': 'folded', 'tail': 'bobtail'}[kind]: sys.exit('unknown %s %r' % (kind, val))
        m = np.array(Image.open(need('cf-%s-mask-%s.png' % (kind, frame))).convert('RGBA'))[..., 3] > 0
        img[m] = 0
        if pat is not None: pat[m] = 0
        parts.append(_layer(need('cf-%s-%s-%s.png' % (kind, val, frame)), cmap))
    def over(dst, src):
        o = src[..., 3] > 0; dst[o] = src[o]
    for pt in parts: over(img, pt)
    if pat is not None: over(img, pat)
    if eyes and eyes != 'none':
        names = eyes.split(',')
        if len(names) == 1: names = names * 2
        if len(names) != 2 or any(n not in EYES for n in names): sys.exit('bad --eyes %r (one of %s, or LEFT,RIGHT)' % (eyes, '/'.join(EYES)))
        xs = np.arange(64)[None, :].repeat(64, 0)
        split = EYE_SPLIT.get(frame, 25)
        for n, sel in ((names[0], xs < split), (names[1], xs >= split)):
            e = np.array(Image.open(need('cf-eyes-%s-%s.png' % (n, frame))).convert('RGBA'))
            e[~sel] = 0
            over(img, e)
    return img


def check_compose(img):
    errs = []
    if any(v not in (0, 255) for v in np.unique(img[..., 3])): errs.append('semi-alpha')
    op = img[img[..., 3] > 0][:, :3]
    n = len(np.unique(op, axis=0))
    if n > COMPOSE_MAXCOL: errs.append('%d colours > %d' % (n, COMPOSE_MAXCOL))
    if (op == 255).all(-1).any(): errs.append('pure #ffffff present')
    if (op == [255, 0, 255]).all(-1).any(): errs.append('placeholder #ff00ff present')
    return errs


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--in', dest='indir', default=os.path.join(CF, 'test'))
    ap.add_argument('--out', default=os.path.join(CF, 'test', 'recolor'))
    ap.add_argument('--glob', default='cf-*.png')
    ap.add_argument('--coats', default=','.join(COATS))
    ap.add_argument('--eye', choices=sorted(EYES))
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--tones', default=os.path.join(CF, 'tones.json'))
    ap.add_argument('--overlays', default=os.path.join(CF, 'tones_overlays.json'))
    ap.add_argument('--compose', action='store_true', help='build one layered cat to --out (a file)')
    ap.add_argument('--coat'); ap.add_argument('--pattern', choices=PATTERNS + ('none',))
    ap.add_argument('--eyes'); ap.add_argument('--ears'); ap.add_argument('--tail'); ap.add_argument('--frame')
    a = ap.parse_args(argv)
    if a.compose:
        if a.coat not in COATS or not a.frame: sys.exit('--compose needs --coat (%s) and --frame' % '/'.join(COATS))
        img = compose(a.coat, a.frame, a.indir, a.pattern, a.eyes, a.ears, a.tail, a.tones, a.overlays)
        errs = check_compose(img)
        out = a.out if a.out.endswith('.png') else os.path.join(a.out, 'cf-compose-%s-%s.png' % (a.coat, a.frame))
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        Image.fromarray(img, 'RGBA').save(out, optimize=False)
        for e in errs: print('FAIL compose: ' + e)
        print('wrote ' + out)
        return 1 if errs else 0
    base_tones = {k: v[0] for k, v in load(a.tones, True).items()}
    overlays = load(a.overlays)
    files = sorted(glob.glob(os.path.join(a.indir, a.glob)))
    if not files: sys.exit('no input files for ' + a.glob)
    os.makedirs(a.out, exist_ok=True)
    bad = n = 0; warned = set()
    coats = a.coats.split(',')
    for c in coats:
        if c not in COATS: sys.exit('unknown coat ' + c)
    for f in files:
        name = os.path.basename(f); kind = classify(name)
        if kind is None: continue
        if kind in ('mask', 'eyes') or (kind == 'ring' and not a.eye):
            shutil.copyfile(f, os.path.join(a.out, name)); n += 1; continue
        src = Image.open(f)
        if kind == 'ring':  # tinted placeholder ring; coat independent
            out, unm = recolor(src, build_map('grey', base_tones, overlays, a.eye))
            Image.fromarray(out, 'RGBA').save(os.path.join(a.out, name.replace('ring-', 'ring-%s-' % a.eye, 1)), optimize=False)
            n += 1; continue
        for coat in coats:
            cmap = build_map(coat, base_tones, overlays, a.eye)
            out, unm = recolor(src, cmap)
            if kind == 'coat': oname = name.replace('-grey-', '-%s-' % coat)
            elif kind == 'head': oname = name.replace('cf-bookhead-grey', 'cf-bookhead-' + coat, 1)
            else: oname = part_name(name, coat)
            Image.fromarray(out, 'RGBA').save(os.path.join(a.out, oname), optimize=False)
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
