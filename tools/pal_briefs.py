#!/usr/bin/env python3
"""Puzzle Pals art helper (build step 1 stub). Usage:
  tools/pal_briefs.py --placeholders [OUTDIR]   write the red-border THIS IS PLACEHOLDER sticker (64 px, tools/gen_placeholder_art.py style) as
        OUTDIR/_placeholder.png (the reference ppal_art_ready() compares against) and one identical copy per authored pal key in puzzle_pals.txt.
        Default OUTDIR = game/assets/img/puzzles/pals. Placeholders are for dev and admin preview only: a picture whose pals are placeholders is NOT art-ready.
  tools/pal_briefs.py --brief <place-slug> | --brief-kind <haven|wonder|delve|lair> [--out DIR]
        write a design brief per Places picture to DIR (default claude/art-briefs/pals)/<slug>.md: title, kind, 3-5 motif words (title, landmarks.txt flavour,
        the scene script's header comment), the 3 dominant colours read from the Place PNG, any authored roster rows, and the rarity/shape recipe (plan-puzzle-pals.md s6).
        <place-slug> is the file name in game/assets/img/jigsaw/places without .png (lair-condors-crag) or without the kind prefix (condors-crag).
  Gallery picture briefs are not generated here."""
import os, re, glob, shutil, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_placeholder_art import make

PLACES = os.path.join(HERE, '..', 'game', 'assets', 'img', 'jigsaw', 'places')
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
KINDS = ('haven', 'wonder', 'delve', 'lair')
STOP = set('the of a an and in on at to for with its it is are as by from into that this one old great big boss lair help find rest buy sell read keeper where who whose their them they has have was were can will not but out up over under all any some hard side path rewards reward finds special puzzle event checks check zone bright day night high whole hovers underwater sleeps rules guards huge giant'.split())
MOOD = {'haven': 'round knobs, hearth folk', 'wonder': 'keyhole knobs, sprites', 'delve': 'cave beasts (peg or tri knobs)', 'lair': 'hooks and horns, the villain\'s leftovers'}

def slugify(t): return re.sub(r'[^a-z0-9]+', '-', t.lower().replace("'", '').replace('\u2019', '')).strip('-')

def landmark_rows():
    out = {}
    for l in open(os.path.join(DATA, 'landmarks.txt'), encoding='utf-8'):
        c = l.rstrip('\n').split('|')
        if l.startswith('#') or len(c) < 4 or c[2] not in KINDS: continue
        out[c[2] + '-' + slugify(c[3])] = (c[3], c[2], c[4] if len(c) > 4 else '')
        out[c[2] + '-' + re.sub('^' + c[2] + '-', '', slugify(c[3]))] = out[c[2] + '-' + slugify(c[3])]   # files drop a repeated kind (lair-of-the-.. for Lair of the ..)
    return out

def script_text(slug):
    """Header comment of the scene script(s) for this place, if any."""
    txt = ''
    for f in glob.glob(os.path.join(HERE, '..', 'aseprite-source', '**', slug + '.lua'), recursive=True):
        for l in open(f, encoding='utf-8', errors='replace'):
            if l.startswith('--'): txt += ' ' + l[2:]
            else: break
    return txt

def motifs(title, flavour, scene, slug):
    out = []
    def add(ws):
        for w in re.findall(r"[a-z]{3,}", ws.lower().replace("'s", '')):
            if w not in STOP and w not in out and not w.startswith(slug.split('-')[0]): out.append(w)
    add(title); add(re.sub(r'\b[A-Z]{2,4}\b', ' ', scene.split(':', 1)[-1] if scene else '')); add(re.sub(r'\b[A-Z]{2,4}\b', ' ', flavour))
    if len(out) < 3: add(slug.replace('-', ' '))
    return out[:5]

def colours(path):
    from PIL import Image
    im = Image.open(path).convert('RGB').resize((120, 80))
    q = im.quantize(colors=10, method=Image.Quantize.MEDIANCUT)
    pal = q.getpalette()
    cnt = sorted(q.getcolors(), reverse=True)
    picked = []
    for n, i in cnt:
        rgb = tuple(pal[i * 3:i * 3 + 3])
        if all(sum((a - b) ** 2 for a, b in zip(rgb, o)) > 45 ** 2 for o in picked): picked.append(rgb)
        if len(picked) == 3: break
    for n, i in cnt:   # fewer than 3 distinct: top up
        rgb = tuple(pal[i * 3:i * 3 + 3])
        if len(picked) >= 3: break
        if rgb not in picked: picked.append(rgb)
    return ['#%02x%02x%02x' % c for c in picked]

def brief(slug, outdir):
    png = os.path.join(PLACES, slug + '.png')
    if not os.path.exists(png): print('no such place picture: ' + png); return False
    kind = slug.split('-')[0]
    title, _, flavour = landmark_rows().get(slug, (slug.split('-', 1)[1].replace('-', ' ').title(), kind, ''))
    scene = script_text(slug)
    mw = motifs(title, flavour, scene, slug)
    cols = colours(png)
    rows = []
    for l in open(os.path.join(DATA, 'puzzle_pals.txt'), encoding='utf-8'):
        c = l.rstrip('\n').split('|')
        if not l.startswith('#') and len(c) == 14 and c[0] in (slug, 'pl-' + slug, 'pl-' + slug.split('-', 1)[1]): rows.append(c)
    md = ['# Pal brief: %s' % title, '', '- Picture: `%s` (Places, 360x240 file px; Advanced cell 30x30 file px, 15x15 art px)' % slug,
          '- Kind: **%s** (%s)' % (kind, MOOD[kind]),
          '- Flavour: %s' % (flavour or '(none in landmarks.txt)'),
          '- Scene script note: %s' % (scene.strip() or '(no scene script found)'),
          '- Motif words: %s' % ', '.join(mw),
          '- Dominant colours: %s' % ', '.join(cols), '']
    md += ['## Roster', '']
    if rows:
        md += ['| key | name | rarity | calling | shape | knob | piece | blurb |', '|---|---|---|---|---|---|---|---|']
        md += ['| %s | %s | %s | %s | %s | %s | %s | %s |' % (c[1], c[2], c[3], c[4], c[10], c[11], c[9], c[13]) for c in rows]
    else:
        md += ['Not authored yet (see claude/plan-places-pals.md s1). Draft 6 rows: 3 common, 2 uncommon, 1 rare.']
    md += ['', '## Rules (claude/plan-puzzle-pals.md s6)', '',
           '- Every pal is a living jigsaw piece; its shape is its type. Roster of 6 = 3 common (corner + edge + plain inner), 2 uncommon (two of Plus inner-TTTT, Ring inner-BBBB, TTBB inner-TTBB, different knobs), 1 rare (a whimsy-* novelty piece cut to the place\'s subject).',
           '- No two pals in a roster share shape+knob. Knob from the kind mood: %s.' % MOOD[kind],
           '- Fill = one Advanced cell of this picture (the `piece` column, col-row on 12x8); at 15x15 art px it is nearly flat, so upscale it and use the 3 dominant colours above, calm tones. The place shows in palette + accessory.',
           '- Face: eyes (3 styles), a mouth, stubby limbs on tabs, and one accessory per pal taken from the motif words.',
           '- Rarity look: common = flat outline; uncommon = a second accent colour from the picture; rare = glow + sparkle mark and a signature accessory. The rarity frame stays CSS.',
           '- Names are unique across all pictures (tools/dedupe_puzzle_pals.py); no NPC names; curly apostrophes only.', '']
    os.makedirs(outdir, exist_ok=True)
    open(os.path.join(outdir, slug + '.md'), 'w', encoding='utf-8').write('\n'.join(md))
    print('%s: %s | %s | %s' % (slug, title, ', '.join(mw), ' '.join(cols)))
    return True

def main():
    def opt(n): return sys.argv[sys.argv.index(n) + 1] if n in sys.argv and sys.argv.index(n) + 1 < len(sys.argv) else ''
    if '--brief' in sys.argv or '--brief-kind' in sys.argv:
        out = opt('--out') or os.path.join(HERE, '..', 'claude', 'art-briefs', 'pals')
        if '--brief-kind' in sys.argv:
            k = opt('--brief-kind')
            if k not in KINDS: print('kind must be one of ' + '/'.join(KINDS)); sys.exit(2)
            slugs = sorted(os.path.basename(f)[:-4] for f in glob.glob(os.path.join(PLACES, k + '-*.png')))
        else:
            s = opt('--brief')
            slugs = [s if s.split('-')[0] in KINDS else (glob.glob(os.path.join(PLACES, '*-' + s + '.png')) or [None])[0]]
            slugs = [os.path.basename(x)[:-4] if x and x.endswith('.png') else x for x in slugs]
        ok = all([brief(x, out) if x else print('no such place') for x in slugs])
        sys.exit(0 if ok else 1)
    if '--placeholders' not in sys.argv:
        print(__doc__); sys.exit(2)
    rest = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = rest[0] if rest else os.path.join(HERE, '..', 'game', 'assets', 'img', 'puzzles', 'pals')
    os.makedirs(out, exist_ok=True)
    ref = os.path.join(out, '_placeholder.png')
    make(ref, 64)
    n = 0
    for l in open(os.path.join(HERE, '..', 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
        c = l.rstrip('\n').split('|')
        if l.startswith('#') or len(c) != 14: continue
        dst = os.path.join(out, c[1] + '.png')
        if not os.path.exists(dst):   # never overwrite real art
            shutil.copyfile(ref, dst); n += 1
    print('placeholders: %d new, reference %s' % (n, ref))

main()
