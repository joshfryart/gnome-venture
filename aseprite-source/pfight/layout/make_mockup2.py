#!/usr/bin/env python3
"""Fight screen layout v3, from Josh's sketch. Uses felt/ art if present, else the base art.
RED = placeholder not drawn yet. Run: python3 make_mockup2.py > mockup2.html"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ART = 'felt/' if os.path.exists(os.path.join(HERE, 'felt', 'board-demo.json')) else ''
J = json.load(open(os.path.join(HERE, ART, 'board-demo.json')))
PW, PH = J['pitch']
PX, PY = J['pad_x'], J['pad_y']
BW, BH = 3 * PW + 2 * PX, 3 * PH + 2 * PY
A = '../../../game/assets/img/pfight/'
S = 2


def ph(x, y, w, h, label, n=None, extra=''):
    num = f'<b class="n">{n}</b>' if n else ''
    return f'<div class="ph" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;{extra}"><span>{label}</span>{num}</div>'


def img(name, x, y, w, h, extra=''):
    return f'<img src="{name}" style="left:{x}px;top:{y}px;width:{w * S}px;height:{h * S}px;{extra}">'


def panel(x, y, w, h, txt='', extra=''):
    return f'<div class="panel" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;{extra}">{txt}</div>'


def btn(x, y, w, t, alt=False):
    return f'<div class="btn{" alt" if alt else ""}" style="left:{x}px;top:{y}px;width:{w}px">{t}</div>'


def chip(who, types, res, x):
    s = f'<div class="chip {who}" style="left:{x}px"><em>{"YOU" if who == "me" else "FOE"}</em>'
    for t in types:
        s += f'<img src="{A}ico-{t}-s.png" style="position:static;width:20px;height:20px">'
    return s + f'<strong>{res}</strong></div>'


def history(w):
    h = f'<div class="hist" style="width:{w}px"><div class="hl">HISTORY BAR</div><div class="hscroll">'
    xs = 0
    for who, types, res in (('me', ['guard'], '+2 guard'), ('foe', ['hurt'], '-3'), ('me', ['hurt', 'trick'], 'chain -5'),
                            ('foe', ['soothe', 'charm'], 'charm +2'), ('me', ['heal', 'trick', 'guard'], 'chain +6')):
        h += chip(who, types, res, xs)
        xs += 40 + 22 * len(types) + 70
    return h + '</div></div>'


def board(x, y):
    o = [img(ART + 'board-demo.png', x, y, BW, BH)]
    for s in J['open_sockets']:
        c, r = s['cell']
        bx, by = c * PW + PX, r * PH + PY
        cx, cy = {'L': (bx - PX / 2, by + PH / 2), 'R': (bx + PW + PX / 2, by + PH / 2),
                  'T': (bx + PW / 2, by - PY / 2), 'B': (bx + PW / 2, by + PH + PY / 2)}[s['side']]
        o.append(f'<div class="os" style="left:{x + cx * S - 11}px;top:{y + cy * S - 11}px"></div>')
    bx, by = 1 * PW + PX, 2 * PH + PY
    o.append(f'<div class="ph glow" style="left:{x + bx * S - 6}px;top:{y + by * S - 6}px;width:{PW * S + 12}px;height:{PH * S + 12}px"><span>chain-fire glow FX</span></div>')
    return '\n'.join(o)


def tray(x, y, n=3, gap=156):
    o = []
    for i in range(n):
        o.append(img(f'{ART}tray-demo-{i}.png', x + i * gap, y, 74, 52))
        o.append(f'<i class="val" style="left:{x + i * gap + (PX + 13) * S}px;top:{y + (PY + 2) * S}px;width:{12 * S}px;height:{10 * S}px;line-height:{10 * S}px">{[3, 2, 1, 1][i]}</i>')
    return '\n'.join(o)


CSS = '''
body{margin:0;background:#1d130c;color:#f2e4c0;font:14px system-ui,sans-serif;padding:20px}
h1,h2{margin:.4rem 0}.legend{display:flex;gap:1.5rem;align-items:center;margin:.5rem 0 1rem;flex-wrap:wrap}
.key{display:inline-block;width:38px;height:22px;vertical-align:middle;margin-right:6px}
.frame{position:relative;overflow:hidden;background:#3d2a1c;border:2px solid #000;margin:0 24px 24px 0;display:inline-block;vertical-align:top}
.frame *{box-sizing:border-box}.frame img{position:absolute;image-rendering:pixelated}
.ph{position:absolute;outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12);color:#ff9a9a;font:11px/1.25 system-ui;padding:5px 6px;overflow:hidden}
.ph.glow{background:none}.ph span{display:block}
.n{position:absolute;z-index:9;width:24px;height:24px;border-radius:12px;background:#ff2a2a;color:#fff;font:bold 13px/24px system-ui;text-align:center}
.os{position:absolute;width:22px;height:22px;border:3px solid #ff2a2a;border-radius:50%;background:rgba(255,42,42,.25)}
.panel{position:absolute;background:rgba(42,26,16,.9);border:2px solid #f2e4c0;color:#f2e4c0;font:bold 13px/1.2 system-ui;text-align:center;padding:4px}
.hist{position:absolute;left:0;top:0;height:60px;background:rgba(42,26,16,.92);border-bottom:3px solid #e8a317;overflow:hidden}
.hl{position:absolute;left:6px;top:2px;font:bold 10px system-ui;color:#e8a317}
.hscroll{position:absolute;left:8px;top:18px;height:36px}
.chip{position:absolute;top:0;height:36px;display:flex;align-items:center;gap:3px;padding:0 6px;border:2px solid #f2e4c0;border-radius:6px;background:#3d2a1c;white-space:nowrap}
.chip.foe{border:2px dashed #c96;background:#2a1a10}.chip em{font:bold 10px system-ui;font-style:normal;color:#e8a317}.chip strong{font:bold 11px system-ui;margin-left:3px}
.btn{position:absolute;background:#e8a317;color:#2a1a10;border:3px solid #2a1a10;border-radius:8px;font:bold 14px/1 system-ui;text-align:center;padding:9px 0}.btn.alt{background:#f2e4c0}
.lbl{position:absolute;color:#f2e4c0;font:bold 12px system-ui;text-shadow:0 1px 0 #000}
.val{position:absolute;color:#2a1a10;font:bold 15px system-ui;text-align:center;font-style:normal}
.sel{position:absolute;outline:3px solid #e8a317;outline-offset:2px}
'''


def num(x, y, n):
    return f'<b class="n" style="left:{x}px;top:{y}px">{n}</b>'


def wide():
    W, H = 960, 620
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, '1 ROUTE MAP: the map where the fight began, behind everything', None, 'background:rgba(255,42,42,.06);display:flex;align-items:flex-end'))
    o.append(num(8, 596, 1))
    o.append(history(W)); o.append(num(W - 34, 8, 5))
    o.append(ph(24, 100, 200, 250, 'PLAYER 2.5D sprite (64x64+, faces right)', None))
    o.append(num(28, 104, 2))
    o.append(panel(24, 356, 200, 28, 'You'))
    o.append(ph(736, 130, 200, 220, 'ENEMY SPRITE (faces left)', None, 'text-align:right'))
    o.append(num(740, 134, 3))
    o.append(panel(736, 356, 200, 28, 'Rowdy Boar'))
    o.append(ph(868, 72, 60, 52, 'bubble 28x24', None))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:884px;top:80px;width:40px;height:40px">')
    o.append(ph(290, 70, 380, 22, 'resolve bar 96x12 (added; not in sketch)', None))
    o.append(panel(250, 96, 460, 308, '', 'background:rgba(42,26,16,.55);border-color:#4a6cd0'))
    o.append(board(294, 118)); o.append(num(254, 100, 4))
    o.append(btn(24, 396, 90, 'Undo', True)); o.append(btn(124, 396, 100, 'End turn'))
    o.append(ph(24, 450, 150, 150, 'PUZZLE BOOK (deck) icon + count', None)); o.append(num(28, 454, 8))
    o.append(ph(786, 450, 150, 150, 'DISCARD pile icon + count', None)); o.append(num(790, 454, 7))
    o.append('<div class="lbl" style="left:290px;top:420px">HAND (swipe)</div>')
    o.append(tray(262, 442)); o.append(num(256, 420, 6))
    o.append('<div class="sel" style="left:260px;top:448px;width:148px;height:116px"></div>')
    o.append('</div>')
    return '\n'.join(o)


def phone():
    W, H = 412, 900
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, '1 ROUTE MAP behind everything', None, 'background:rgba(255,42,42,.06);display:flex;align-items:flex-end'))
    o.append(history(W)); o.append(num(W - 34, 8, 5))
    o.append(ph(8, 68, 100, 130, 'PLAYER 2.5D', None)); o.append(num(10, 70, 2))
    o.append(panel(8, 200, 100, 24, 'You'))
    o.append(ph(304, 68, 100, 130, 'ENEMY', None, 'text-align:right')); o.append(num(378, 70, 3))
    o.append(panel(304, 200, 100, 24, 'Rowdy Boar'))
    o.append(ph(116, 72, 180, 22, 'resolve bar (added)', None))
    o.append(ph(116, 104, 60, 48, 'bubble', None))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:132px;top:112px;width:40px;height:40px">')
    o.append(panel(8, 232, 396, 296, '', 'background:rgba(42,26,16,.55);border-color:#4a6cd0'))
    o.append(board(20, 252)); o.append(num(10, 234, 4))
    o.append(btn(8, 536, 120, 'Undo', True)); o.append(btn(136, 536, 268, 'End turn'))
    o.append(ph(8, 596, 70, 116, 'BOOK (deck)', None)); o.append(num(10, 598, 8))
    o.append(ph(334, 596, 70, 116, 'DISCARD', None)); o.append(num(336, 598, 7))
    o.append(f'<div style="position:absolute;left:84px;top:596px;width:244px;height:130px;overflow:hidden"><div style="position:absolute;left:0;top:0;width:700px;height:130px">{tray(0, 4)}</div></div>')
    o.append('<div class="sel" style="left:84px;top:598px;width:148px;height:116px"></div>'); o.append(num(86, 580, 6))
    o.append('</div>')
    return '\n'.join(o)


print(f'''<!doctype html><meta charset="utf-8"><title>Puzzle Combat layout v3</title><style>{CSS}</style>
<h1>Puzzle Combat: fight screen (Josh's sketch)</h1>
<div class="legend"><span><i class="key" style="outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12)"></i>RED = placeholder, art not drawn</span><span>RED circle = open socket</span><span>Numbers = your sketch: 1 map, 2 player, 3 enemy, 4 board, 5 history, 6 hand, 7 discard, 8 puzzle book (deck)</span><span>Art folder: {ART or "base"}</span></div>
<h2>A. Landscape (tablet / desktop), as sketched</h2>{wide()}
<h2>B. Phone portrait adaptation</h2>{phone()}''')
