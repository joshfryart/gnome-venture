#!/usr/bin/env python3
"""Builds the playable Puzzle Combat demo (one HTML file, art inlined) from the game's own scripts, CSS and art plus tools/pfengine.js.
Usage: python3 tools/build_pf_artifact.py OUT.html   (run from the repo root; needs php and Pillow)"""
import base64, io, json, os, re, subprocess, sys
from PIL import Image
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); os.chdir(R)
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/pf-demo.html'
G = 'game/assets/'; IMG = G + 'img/'; P = IMG + 'pfight/'; PT = P + 'parts/'
def uri(path, mime='image/png'): return 'data:%s;base64,%s' % (mime, base64.b64encode(open(path, 'rb').read()).decode())
consts = json.loads(subprocess.check_output(['php', 'tools/pfartifact/dump_consts.php']))
art = {}
atlas = json.load(open(PT + 'atlas.json')); rim = json.load(open(PT + 'rim.json'))
for f in ['parts-strip-me.png', 'parts-strip-foe.png', 'parts-hand-me.png', 'parts-hand-foe.png', 'patterns-strip.png', 'patterns-hand.png', 'icons-strip.png', 'icons-hand.png',
          'joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png', 'resolve-frame.png', 'resolve-fill-hurt.png', 'resolve-fill-charm.png', 'chip-me.png', 'chip-foe.png', 'intent-bubble.png']:
    art[f] = uri(PT + f)
art['deck-book.png'] = uri(PT + 'deck-book.png'); art['discard-bin.png'] = uri(PT + 'discard-bin.png')
for f in sorted(os.listdir(PT + 'marks')):
    if f.endswith('.png') and (f.startswith('tag-') or f.startswith('mod-') or f.startswith('rarity-')): art['marks/' + f] = uri(PT + 'marks/' + f)
for t in ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item']: art['ico-%s-s.png' % t] = uri(P + 'ico-%s-s.png' % t)
for name in set(consts['tagIcon'].values()):
    for suf in ['-s.png', '.png']:
        if os.path.exists(P + 'ico-' + name + suf): art['ico-' + name + suf] = uri(P + 'ico-' + name + suf)
# the gnome's head for the chips, and a bigger head-and-shoulders for the status bar
L = [Image.open(IMG + 'gnome/gnome-%s.png' % n).convert('RGBA') for n in ['body', 'face', 'beard', 'hat']]
im = Image.new('RGBA', L[0].size)
for l in L: im = Image.alpha_composite(im, l)
x0, y0, x1, y1 = im.getbbox(); h = im.crop((x0, y0, x1, y0 + int((y1 - y0) * 0.78))); h = h.crop(h.getbbox()); side = max(h.size)
sq = Image.new('RGBA', (side, side)); sq.paste(h, ((side - h.size[0]) // 2, 0))
def png(i):
    b = io.BytesIO(); i.save(b, 'PNG'); return 'data:image/png;base64,' + base64.b64encode(b.getvalue()).decode()
art['chip-gnome.png'] = png(sq.resize((20, 20), Image.LANCZOS))
full = im.crop(im.getbbox()); fs = max(full.size); fq = Image.new('RGBA', (fs, fs)); fq.paste(full, ((fs - full.size[0]) // 2, 0)); art['chip-gnome-big.png'] = png(fq.resize((60, 60), Image.LANCZOS))
for slug in ['leopard-slug', 'thistle-beast', 'grass-snake', 'black-bear']:
    art['mini-%s.png' % slug] = uri(IMG + 'mini/mini-%s.png' % slug); art['chip-cr-%s.png' % slug] = art['mini-%s.png' % slug]
css = open(G + 'pfight.css').read()
css = re.sub(r'url\(img/pfight/parts/([^)]+)\)', lambda m: 'url(%s)' % art[m.group(1)], css)
page = open('tools/pfartifact/page.html').read()
def js(o): return json.dumps(o, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/').replace('<!--', '<\\!--')
src = {k: open(G + k + '.js').read() for k in ['pfx', 'pfparts', 'pfboard']}
# the scripts take their art from the inlined map instead of the network
src['pfparts'] = src['pfparts'].replace("i.src = base + file;", "i.src = window.__ART[file];").replace("i.src = data.art + 'ico-' + TAGICON[tag] + z[1] + '.png';", "i.src = window.__ART['ico-' + TAGICON[tag] + z[1] + '.png'];").replace("i.src = base + 'marks/' + n + '.png';", "i.src = window.__ART['marks/' + n + '.png'];")
for needle in ["window.__ART[file]", "window.__ART['ico-'", "window.__ART['marks/'"]: assert needle in src['pfparts'], needle
# the chip pictures of the creature come from the inlined creature sprites
page = page.replace('/*PFCSS*/', css)
page = page.replace('/*ART*/{}', js(art)).replace('/*CONSTS*/{}', js(consts)).replace('/*ATLAS*/{}', js(atlas)).replace('/*RIM*/{}', js(rim)).replace('/*SRC*/{}', js(src))
page = page.replace('/*ENGINE*/', open('tools/pfengine.js').read().replace('</script', '<\\/script')).replace('/*GLUE*/', open('tools/pfartifact/glue.js').read().replace('</script', '<\\/script'))
open(OUT, 'w').write(page); print(OUT, len(page) // 1024, 'KB')
