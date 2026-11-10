#!/usr/bin/env python3
"""One self-contained HTML page: the three creature25 examples rigged and animated on the fight engine, against the gnome.
   python3 aseprite-source/v3/creature25/build_demo.py out.html      (run creature25.lua with rig=1 first)"""
import base64, sys, pathlib
D = pathlib.Path(__file__).resolve().parent; G = D.parents[2] / 'game'
def uri(p): return 'data:image/png;base64,' + base64.b64encode(pathlib.Path(p).read_bytes()).decode()
imgs = {'assets/img/fight/rig-gnome.png': uri(G / 'assets/img/fight/rig-gnome.png')}
for n in ['boar', 'hawk', 'frog']: imgs['assets/img/fight/rig-c25-%s.png' % n] = uri(D / ('rig-c25-%s.png' % n))
js = 'window.FE_IMG={' + ','.join('"%s":"%s"' % kv for kv in imgs.items()) + '};'
A = G / 'assets'
code = '<script>' + (A / 'fightrigs.js').read_text() + 'window.FE_RIGS.rigs={};</script>'   # the bones file, with only the three examples in the list
code += ''.join('<script>' + p.read_text() + '</script>' for p in [A / 'fightarch.js', D / 'creature25-rigs.js', D / 'creature25-arch.js', A / 'fightengine.js', A / 'fightdemo.js'])
html = (D / 'demo.html').read_text().replace('<style>', '<style>' + (A / 'fightengine.css').read_text(), 1).replace('<!--JS-->', '<script>' + js + '</script>') + code
pathlib.Path(sys.argv[1]).write_text(html); print(sys.argv[1], len(html) // 1024, 'KB')
