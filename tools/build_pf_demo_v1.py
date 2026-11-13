#!/usr/bin/env python3
"""Builds the playable v1 DEMO (one HTML file, art inlined): the shipped puzzle-combat v1 (2.6.78) as a page you can play.
Nothing is re-implemented: the fight rules are tools/pfengine.js (the JS port of game/includes/pfboard.php, checked against it by tests/pfengine_js.sh), the pieces / creature decks / classes are the game's own
data files (dumped by tools/pfdemo_v1/dump_data.php), the stylesheets (style.css, pfight.css, pfv1.css) and the page scripts (pfparts.js, pfv1box.js, pfboardv1.js) are the game's own files.
tools/pfdemo_v1/ holds only the glue that plays the server: pfd.js (the deck model, port of pfdeck.php), views.js (the page markup, port of pfdeck_view.php + pfight_board_html), glue.js (requests, screens).
The game files are read from a git ref (default 51645514b = the 2.6.78 release merge) so the demo shows the shipped game even while the working copy is being changed: PFDEMO_GAME_REF=HEAD to use the latest commit.
Usage: python3 tools/build_pf_demo_v1.py [OUT.html] [DATA_OUT.json]   (run from anywhere; php needed for the data dump)"""
import base64, json, os, re, subprocess, sys, tempfile
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); os.chdir(R)
REF = os.environ.get('PFDEMO_GAME_REF', '51645514b')
TMP = tempfile.mkdtemp(prefix='pfdemo_')
subprocess.check_call('git archive %s game tools/pfengine.js | tar -x -C %s' % (REF, TMP), shell=True)
OUT = sys.argv[1] if len(sys.argv) > 1 else 'claude/mockups/pf-demo-v1.html'
DATA_OUT = sys.argv[2] if len(sys.argv) > 2 else None
G = TMP + '/game/assets/'; IMG = G + 'img/'; P = IMG + 'pfight/'; PT = P + 'parts/'; D = 'tools/pfdemo_v1/'
def uri(path, mime='image/png'): return 'data:%s;base64,%s' % (mime, base64.b64encode(open(path, 'rb').read()).decode())
def js(o): return json.dumps(o, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/').replace('<!--', '<\\!--')
def rd(p): return open(p, encoding='utf-8').read()
esc = lambda t: t.replace('</script', '<\\/script')

data_json = subprocess.check_output(['php', D + 'dump_data.php', TMP]).decode()
if DATA_OUT: open(DATA_OUT, 'w').write(data_json)
data = json.loads(data_json)

# ---- art: the parts kit, the small icons, the creatures' mini pictures, the gnome's head
art = {}
for f in sorted(os.listdir(PT)):
    if f.endswith('.png'): art['parts/' + f] = uri(PT + f)
for f in sorted(os.listdir(PT + 'marks')):
    if f.endswith('.png') and re.match(r'(tag|rarity|mod)-', f): art['parts/marks/' + f] = uri(PT + 'marks/' + f)
for f in sorted(os.listdir(P)):
    if re.match(r'ico-[a-z]+(-s)?\.png$', f) or f in ('chip-gnome.png', 'crown-boss.png'): art[f] = uri(P + f)
for c in data['creatures']: art['mini-%s.png' % c['slug']] = uri(IMG + 'mini/mini-%s.png' % c['slug'])
from PIL import Image
import io
L = [Image.open(IMG + 'gnome/gnome-%s.png' % n).convert('RGBA') for n in ['body', 'face', 'beard', 'hat']]
im = Image.new('RGBA', L[0].size)
for l in L: im = Image.alpha_composite(im, l)
full = im.crop(im.getbbox()); fs = max(full.size); fq = Image.new('RGBA', (fs, fs)); fq.paste(full, ((fs - full.size[0]) // 2, 0))
b = io.BytesIO(); fq.resize((60, 60), Image.LANCZOS).save(b, 'PNG'); art['gnome.png'] = 'data:image/png;base64,' + base64.b64encode(b.getvalue()).decode()
# emoji -> the game's own SVG icons (emoji_icons.php swaps them on every page): only the emoji the demo's own text uses
texts = ''.join(rd(f) for f in [D + 'views.js', D + 'glue.js', D + 'page.html'])
ico = {}
for em, r in data['ico'].items():
    f = G + 'img/ico/%s.svg' % r[0]
    if em in texts and os.path.isfile(f): ico[em] = r; art['ico/%s.svg' % r[0]] = uri(f, 'image/svg+xml')
data['ico'] = ico
atlas = json.load(open(PT + 'atlas.json')); rim = json.load(open(PT + 'rim.json'))

# ---- css: the game's own files; images become data: URIs (the ones the pages use) or nothing
def css_urls(css, base):
    def sub(m):
        u = m.group(1).strip('\'"'); p = os.path.normpath(os.path.join(base, u))
        return 'url(%s)' % uri(p) if os.path.isfile(p) and (p.endswith('felt-umber.png') or p.endswith('button.png') or p.startswith(PT.rstrip('/'))) else 'url(data:,)'
    return re.sub(r'url\(([^)]*)\)', sub, css)
css = '\n'.join(css_urls(rd(G + f), G) for f in ['style.css', 'pfight.css', 'pfv1.css'])

src = {'pfx': rd(G + 'pfx.js'), 'pfparts': rd(G + 'pfparts.js'), 'pfv1box': rd(G + 'pfv1box.js'), 'pfboardv1': rd(G + 'pfboardv1.js')}
page = rd(D + 'page.html')
def put(mark, text):
    global page
    assert page.count(mark) == 1, mark; page = page.replace(mark, lambda m: text) if False else page.replace(mark, text)
put('/*DATA*/{}', js(data)); put('/*ART*/{}', js(art)); put('/*ATLAS*/{}', js(atlas)); put('/*RIM*/{}', js(rim)); put('/*SRC*/{}', js(src))
put('/*ENGINE*/', esc(rd(TMP + '/tools/pfengine.js'))); put('/*PFD*/', esc(rd(D + 'pfd.js'))); put('/*VIEWS*/', esc(rd(D + 'views.js'))); put('/*GLUE*/', esc(rd(D + 'glue.js')))
put('/*CSS*/', css)
open(OUT, 'w', encoding='utf-8').write(page); print(OUT, len(page) // 1024, 'KB')
