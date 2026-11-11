#!/usr/bin/env python3
"""Writes <dir>/pfight-contact.html (images referenced; zoom is CSS only, no scaled files)."""
import os
import sys

D = sys.argv[1]
T = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item']
files = sorted(f for f in os.listdir(D) if f.endswith('.png'))
M = {'deut': '.367322 .860646 -.227968 0 0  .280085 .672501 .047413 0 0  -.011820 .042940 .968881 0 0  0 0 0 1 0',
     'prot': '.152286 1.052583 -.204868 0 0  .114503 .786281 .099216 0 0  -.003882 -.048116 1.051998 0 0  0 0 0 1 0',
     'trit': '1.255528 -.076749 -.178779 0 0  -.078411 .930809 .147602 0 0  .004733 .691367 .303900 0 0  0 0 0 1 0',
     'gray': '.2126 .7152 .0722 0 0  .2126 .7152 .0722 0 0  .2126 .7152 .0722 0 0  0 0 0 1 0'}


def tile(k, t, lf, rf, frame='me'):
    h = k == 'hand'
    W, H, sw = (96, 68, 20) if h else (56, 40, 12)
    ix, iy = (37, 9) if h else (21, 14)
    ico = 'ico-%s.png' % t if h else 'ico-%s-s.png' % t
    s = f'<span class="tl" style="width:{W}px;height:{H}px">'
    s += f'<img src="tile-{k}-{t}.png" style="left:0;top:0">'
    s += f'<img src="sock-{k}-{lf}-hole.png" style="left:0;top:0">'
    s += f'<img src="sock-{k}-{rf}-knob.png" style="left:{W - sw}px;top:0">'
    s += f'<img src="{ico}" style="left:{ix}px;top:{iy}px">'
    s += f'<img src="frame-{frame}-{k}.png" style="left:0;top:0"></span>'
    return s


def board():
    o = ''
    for k in ('hand', 'strip'):
        for row, (lf, rf, fr) in enumerate([('body', 'mind', 'me'), ('mind', 'craft', 'me'),
                                            ('craft', 'body', 'foe'), ('flat', 'flat', 'me')]):
            if k == 'strip' and row == 3:
                continue
            o += '<div class="row">' + ''.join(tile(k, t, lf, rf, fr) for t in T) + '</div>'
    o += '<div class="row">' + ''.join(tile('hand', 'hurt', f, g) for f, g in
                                       (('body', 'body'), ('mind', 'mind'), ('craft', 'craft')))
    o += ('<span class="tl" style="width:100px;height:72px"><img src="frame-picked-hand.png" style="left:0;top:0">'
          '<img src="tile-hand-guard.png" style="left:2px;top:2px"></span></div>')
    o += '<div class="row">' + ''.join(tile('strip', 'guard', f, g) for f, g in
                                       (('body', 'body'), ('mind', 'mind'), ('craft', 'craft'))) + '</div>'
    return o


BOARD = board()
views = [('Normal', ''), ('Grayscale', 'gray'), ('Deuteranopia (red-green)', 'deut'),
         ('Protanopia (red-green)', 'prot'), ('Tritanopia (blue-yellow)', 'trit')]
h = ['<!doctype html><meta charset="utf-8"><title>Puzzle Combat art: contact sheet</title><style>',
     'body{margin:0;background:#3d2a1c;color:#f2e4c0;font:14px system-ui,sans-serif;padding:1rem}h1,h2{margin:.6rem 0}',
     'img{image-rendering:pixelated;position:absolute}.tl{position:relative;display:inline-block;margin:6px}',
     '.row{white-space:nowrap}.zoom{zoom:2}.view{margin-bottom:1.2rem}.cream{background:#f2e4c0;color:#2a1a10;padding:.5rem}',
     '.fl{display:inline-block;margin:4px;text-align:center;font-size:11px;vertical-align:top}',
     '.fl img{position:static;display:block;margin:0 auto 2px}.g{display:flex;flex-wrap:wrap}</style>',
     '<svg width="0" height="0" style="position:absolute">']
for k, m in M.items():
    h.append(f'<filter id="{k}"><feColorMatrix type="matrix" values="{m}"/></filter>')
h.append('</svg><h1>Puzzle Combat art: Group 1 (tiles)</h1>'
         '<p>All files at native pixels; zoom is CSS only. Value corner = dark plate, print a cream number.</p>')
h.append('<h2>Test views (felt, 2x CSS)</h2>')
for name, f in views:
    st = f'filter:url(#{f})' if f else ''
    h.append(f'<div class="view"><h3>{name}</h3><div class="zoom" style="{st}">{BOARD}</div></div>')
h.append('<h2>Same board on cream (2x CSS)</h2><div class="cream"><div class="zoom">' + BOARD + '</div></div>')
for title, cls, bg, fg in (('Every file at native size, on felt', '', '#3d2a1c', '#f2e4c0'),
                           ('Every file at native size, on cream', 'cream', '#f2e4c0', '#2a1a10')):
    h.append(f'<h2>{title}</h2><div class="g" style="background:{bg};padding:.5rem">')
    for f in files:
        h.append(f'<span class="fl"><img src="{f}"><span style="color:{fg}">{f[:-4]}</span></span>')
    h.append('</div>')
open(os.path.join(D, 'pfight-contact.html'), 'w').write('\n'.join(h))
