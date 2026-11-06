#!/usr/bin/env python3
"""Inline the fight demo (css, js, every image it uses) into ONE html file to share as an artifact / attach.
   python3 tools/fight/build_demo.py out.html"""
import base64, re, sys, pathlib
G = pathlib.Path(__file__).resolve().parents[2] / 'game'
def uri(p): return 'data:image/png;base64,' + base64.b64encode((G / p).read_bytes()).decode()
html = (G / 'fight_demo.html').read_text()
css = (G / 'assets/fightengine.css').read_text()
eng = (G / 'assets/fightengine.js').read_text()
demo = (G / 'assets/fightdemo.js').read_text()
demo = re.sub(r"'(assets/img/fight/[^']+\.png)'", lambda m: "'" + uri(m.group(1)) + "'", demo)   # gnome parts
# creature minis are built by string concat ('assets/img/mini/mini-' + slug + '.png'): swap for a lookup table
slugs = re.findall(r'<option>([^<]+)</option>', html)
table = '{' + ','.join("'%s':'%s'" % (s, uri('assets/img/mini/mini-%s.png' % s)) for s in slugs) + '}'
demo = demo.replace("'assets/img/mini/mini-' + slug + '.png'", 'MINI[slug]').replace('(function () {', 'var MINI = ' + table + ';\n(function () {', 1)
html = html.replace('<link rel="stylesheet" href="assets/fightengine.css">', '<style>' + css + '</style>')
html = html.replace('<script src="assets/fightengine.js"></script><script src="assets/fightdemo.js"></script>', '<script>' + eng + '</script><script>' + demo + '</script>')
pathlib.Path(sys.argv[1]).write_text(html); print(sys.argv[1], len(html) // 1024, 'KB')
