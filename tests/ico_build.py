#!/usr/bin/env python3
"""Inline-icon (ico-*) build. usage: PYTHONHASHSEED=1 python3 tests/ico_build.py reuse|restyle|rawrestyle|all
 reuse   : copy existing art (emoji_map.json reuse paths) -> game/assets/img/ico/<slug>.svg, shadow ellipse stripped, ids made unique
 restyle : tests/ico_src/*.svg -> hearth.restyle(src, slug) (ico- mode) -> game/assets/img/ico/<slug>.svg"""
import os, sys, re, json
if os.environ.get('PYTHONHASHSEED') != '1':   # hearth output depends on set order: re-exec deterministic
    os.environ['PYTHONHASHSEED'] = '1'; os.execv(sys.executable, [sys.executable] + sys.argv)
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
IMG = os.path.join(ROOT, 'game/assets/img'); OUT = os.environ.get('ICO_OUT') or os.path.join(IMG, 'ico'); SRC = os.environ.get('ICO_SRC') or os.path.join(HERE, 'ico_src')
_MS = os.path.join(HERE, 'ico_map_source.json')
MAP = os.environ.get('ICO_MAP') or (_MS if os.path.exists(_MS) else '/tmp/claude-0/-home-claude/ea011c08-e1f5-543d-9648-1b4c4ec8648c/scratchpad/emoji/emoji_map.json')
SHADOW = re.compile(r'<ellipse\b(?=[^>]*fill="#6a4528")(?=[^>]*opacity="\.5")[^>]*/>')       # Hearthlight ground shadow (warm umber .5 + cream ring)
SHADOW_RAW = re.compile(r'^(<svg[^>]*>)<ellipse\b(?=[^>]*cy="5[2-9]")(?=[^>]*fill="#(?:000|6b4a2e)")(?=[^>]*opacity="\.[1-3]\d?")[^>]*/>')   # raw animals/ art: black/brown low-opacity ground blob (first child only)

REDRAW = set('ico-ant ico-beetle ico-fly ico-fish ico-knife ico-mushroom ico-peach ico-peanut ico-four-leaf-clover ico-chili ico-cherry ico-sunflower ico-test-tube ico-watermelon ico-shell ico-snake ico-person ico-shop ico-shrine ico-tent ico-tower ico-goat ico-milk ico-caterpillar'.split())   # reuse candidates judged illegible/muddy at 16-24px: drawn fresh via ico_src instead

SHRINK = {'ico-hedgehog': .88, 'ico-snail': .88}   # art touches the 64px frame: scale about the centre
ONLY = set(filter(None, os.environ.get('ICO_ONLY', '').split(',')))   # ICO_ONLY=ico-snail,ico-hedgehog regenerates just these

def shrink(s, slug):
    k = SHRINK.get(slug)
    if not k: return s
    m = re.match(r'(<svg\b[^>]*>)(.*)</svg>\s*$', s, re.S)
    if not m: return s
    return '%s<g transform="translate(32 32) scale(%s) translate(-32 -32)">%s</g></svg>' % (m.group(1), ('%.3f' % k).rstrip('0'), m.group(2))

def uniq_ids(s, slug):
    ids = re.findall(r'\bid="([^"]+)"', s)
    if not ids: return s
    m = {}
    for i in ids:
        m[i] = 'hl-' + slug if i == 'hl-' + i[3:] and i.startswith('hl-') and ('hl-' + slug) not in m.values() else 'hl-%s-%s' % (slug, re.sub(r'^hl-', '', i))
    for old, new in sorted(m.items(), key=lambda kv: -len(kv[0])):
        s = s.replace('id="%s"' % old, 'id="\0%s"' % new).replace('url(#%s)' % old, 'url(#\0%s)' % new).replace('#%s"' % old, '#\0%s"' % new)
    return s.replace('\0', '')

def reuse():
    m = json.load(open(MAP)); os.makedirs(OUT, exist_ok=True); done = {}
    for e in m.values():
        if e.get('reuse'): done[e['slug']] = e['reuse']
    raster = []; n = 0
    for slug, rel in sorted(done.items()):
        if slug in REDRAW or (ONLY and slug not in ONLY): continue
        f = os.path.join(IMG, rel + '.svg')
        if not os.path.exists(f):
            raster.append((slug, rel)); continue
        s = open(f, encoding='utf-8').read()
        s, k1 = SHADOW.subn('', s); s, k2 = SHADOW_RAW.subn(r'\1', s)
        s = shrink(uniq_ids(s, slug), slug)
        open(os.path.join(OUT, slug + '.svg'), 'w', encoding='utf-8').write(s); n += 1
    print('reuse copied %d  non-svg/missing %s' % (n, raster))

RAW_RESTYLE = {'goat': 'animals/goat', 'milk': 'animals/item-goat-milk', 'caterpillar': 'animals/silkworm'}   # raw game art (no outline) -> ico restyle

def rawrestyle():
    import hearth
    os.makedirs(OUT, exist_ok=True)
    for n, rel in RAW_RESTYLE.items():
        slug = 'ico-' + n
        out = hearth.restyle(open(os.path.join(IMG, rel + '.svg'), encoding='utf-8').read(), slug)
        open(os.path.join(OUT, slug + '.svg'), 'w', encoding='utf-8').write(out); print('rawrestyle', slug, len(out))

def restyle():
    import hearth
    os.makedirs(OUT, exist_ok=True); n = 0; bad = []
    for f in sorted(os.listdir(SRC)):
        if not f.endswith('.svg'): continue
        slug = f[:-4]
        if ONLY and slug not in ONLY: continue
        try: out = hearth.restyle(open(os.path.join(SRC, f), encoding='utf-8').read(), slug)
        except Exception as ex: bad.append((slug, repr(ex))); continue
        out = shrink(out, slug)
        open(os.path.join(OUT, slug + '.svg'), 'w', encoding='utf-8').write(out); n += 1
    print('restyled %d  errors %s' % (n, bad))

if __name__ == '__main__':
    st = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if st in ('reuse', 'all'): reuse()
    if st in ('restyle', 'all'): restyle()
    if st in ('rawrestyle', 'all'): rawrestyle()
