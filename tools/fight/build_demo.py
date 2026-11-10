#!/usr/bin/env python3
"""One self-contained HTML file of the fight engine (css, js, every rig sheet inlined), to share or publish as an artifact.
   python3 tools/fight/build_demo.py out.html                      the plain demo (game/fight_demo.html)
   python3 tools/fight/build_demo.py out.html --showcase [dir]     the showcase page (tools/fight/showcase.html: stage, body types, sheet viewer);
                                                                   dir = old mini-<slug>.png files to show before/after beside the current minis"""
import base64, re, sys, pathlib
T = pathlib.Path(__file__).resolve().parent; G = T.parents[1] / 'game'
def uri(p): return 'data:image/png;base64,' + base64.b64encode(pathlib.Path(p).read_bytes()).decode()
show = '--showcase' in sys.argv
imgs = {'assets/img/fight/' + f.name: uri(f) for f in sorted((G / 'assets/img/fight').glob('rig-*.png'))}
js = 'window.FE_IMG={' + ','.join('"%s":"%s"' % kv for kv in imgs.items()) + '};'
if show and len(sys.argv) > 3:
    js += 'window.FE_BEFORE={' + ','.join('"%s":["%s","%s"]' % (f.stem[5:], uri(f), uri(G / 'assets/img/mini' / f.name)) for f in sorted(pathlib.Path(sys.argv[3]).glob('mini-*.png'))) + '};'
css = (G / 'assets/fightengine.css').read_text()
code = ''.join('<script>' + (G / 'assets' / n).read_text() + '</script>' for n in ['fightrigs.js', 'fightarch.js', 'fightengine.js', 'fightdemo.js'])
if show:
    html = (T / 'showcase.html').read_text()
    html = html.replace('<style>', '<style>' + css, 1).replace('</main>\n<script>', '</main>\n<script>' + js + '</script><script>', 1) + code
else:
    html = (G / 'fight_demo.html').read_text()
    html = html.replace('<link rel="stylesheet" href="assets/fightengine.css">', '<style>' + css + '</style>')
    html, n = re.subn(r'(<script src="assets/fight\w+\.js"></script>)+', lambda m: '<script>' + js + '</script>' + code, html)
    assert n == 1
pathlib.Path(sys.argv[1]).write_text(html); print(sys.argv[1], len(html) // 1024, 'KB')
