#!/usr/bin/env python3
"""Fight-screen layout mockup v2: a shared 2D jigsaw board. RED outline = placeholder art not drawn yet.
Shown at 2x native art (phone 412 css px wide). Run: python3 make_board_demo.py && python3 make_mockup.py > mockup.html"""
import json
import os

A = '../../../game/assets/img/pfight/'
S = 2
J = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'board-demo.json')))
PW, PH = J['pitch']
PX, PY = J['pad_x'], J['pad_y']
BW, BH = 3 * PW + 2 * PX, 3 * PH + 2 * PY          # board image size in art px


def ph(x, y, w, h, label, n=None, extra=''):
    num = f'<b class="n">{n}</b>' if n else ''
    return f'<div class="ph" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;{extra}"><span>{label}</span>{num}</div>'


def call(x, y, n):
    return f'<b class="n" style="left:{x}px;top:{y}px;right:auto">{n}</b>'


def local(name, x, y, w, h, extra=''):
    return f'<img src="{name}" style="left:{x}px;top:{y}px;width:{w * S}px;height:{h * S}px;{extra}">'


def chip(who, types, res, x):
    s = f'<div class="chip {who}" style="left:{x}px"><em>{"YOU" if who == "me" else "FOE"}</em>'
    for t in types:
        s += f'<img src="{A}ico-{t}-s.png" style="position:static;width:20px;height:20px">'
    return s + f'<strong>{res}</strong></div>'


def history(w):
    h = f'<div class="hist" style="width:{w}px"><div class="hl">HISTORY</div><div class="hscroll">'
    xs = 0
    for who, types, res in (('me', ['guard'], '+2 guard'), ('foe', ['hurt'], '-3'), ('me', ['hurt', 'trick'], 'chain -5'),
                            ('foe', ['soothe', 'charm'], 'charm +2'), ('me', ['heal', 'trick', 'guard'], 'chain +6')):
        h += chip(who, types, res, xs)
        xs += 40 + 22 * len(types) + 70
    return h + '</div></div>'


def board(x, y, with_marks=True):
    """board image at (x,y) css px; overlays: open-socket markers, just-placed marker, chain popup"""
    o = [local('board-demo.png', x, y, BW, BH)]
    if with_marks:
        for s in J['open_sockets']:
            c, r = s['cell']
            bx, by = c * PW + PX, r * PH + PY
            cx, cy = {'L': (bx - PX / 2, by + PH / 2), 'R': (bx + PW + PX / 2, by + PH / 2),
                      'T': (bx + PW / 2, by - PY / 2), 'B': (bx + PW / 2, by + PH + PY / 2)}[s['side']]
            o.append(f'<div class="os" style="left:{x + cx * S - 11}px;top:{y + cy * S - 11}px"></div>')
        # newest piece = cell (1,2): chain activation
        bx, by = 1 * PW + PX, 2 * PH + PY
        o.append(f'<div class="ph" style="left:{x + bx * S - 6}px;top:{y + by * S - 6}px;width:{PW * S + 12}px;height:{PH * S + 12}px;background:none"><span>chain-fire glow (FX)</span><b class="n">6</b></div>')
    return '\n'.join(o)


CSS = '''
body{margin:0;background:#1d130c;color:#f2e4c0;font:14px system-ui,sans-serif;padding:20px}
h1,h2{margin:.4rem 0}.legend{display:flex;gap:1.5rem;align-items:center;margin:.5rem 0 1rem;flex-wrap:wrap}
.key{display:inline-block;width:38px;height:22px;vertical-align:middle;margin-right:6px}
.frame{position:relative;overflow:hidden;background:#3d2a1c;border:2px solid #000;margin:0 24px 24px 0;display:inline-block;vertical-align:top}
.frame *{box-sizing:border-box}.frame img{position:absolute;image-rendering:pixelated}
.ph{position:absolute;outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12);color:#ff9a9a;font:11px/1.25 system-ui;padding:5px 6px;overflow:hidden}
.ph span{display:block}.n{position:absolute;z-index:9;min-width:22px;height:22px;border-radius:11px;background:#ff2a2a;color:#fff;font:bold 12px/22px system-ui;text-align:center;right:3px;top:3px;padding:0 4px}
.os{position:absolute;width:22px;height:22px;border:3px solid #ff2a2a;border-radius:50%;background:rgba(255,42,42,.25)}
.panel{position:absolute;background:rgba(42,26,16,.9);border:2px solid #f2e4c0;color:#f2e4c0}
.hist{position:absolute;left:0;top:0;height:60px;background:rgba(42,26,16,.92);border-bottom:3px solid #e8a317;overflow:hidden}
.hl{position:absolute;left:6px;top:2px;font:bold 10px system-ui;color:#e8a317}
.hscroll{position:absolute;left:8px;top:18px;height:36px}
.chip{position:absolute;top:0;height:36px;display:flex;align-items:center;gap:3px;padding:0 6px;border:2px solid #f2e4c0;border-radius:6px;background:#3d2a1c;white-space:nowrap}
.chip.foe{border:2px dashed #c96;background:#2a1a10}.chip em{font:bold 10px system-ui;font-style:normal;color:#e8a317}.chip strong{font:bold 11px system-ui;margin-left:3px}
.btn{position:absolute;background:#e8a317;color:#2a1a10;border:3px solid #2a1a10;border-radius:8px;font:bold 15px/1 system-ui;text-align:center;padding:10px 0}
.btn.alt{background:#f2e4c0}
.lbl{position:absolute;color:#f2e4c0;font:bold 12px system-ui;text-shadow:0 1px 0 #000}
.tray{position:absolute;overflow:hidden}.tray .in{position:absolute;white-space:nowrap}
.txt{position:absolute;color:#f2e4c0;font:13px/1.35 system-ui}
.val{position:absolute;color:#f2e4c0;font:bold 18px system-ui;text-align:center;font-style:normal}
.sel{position:absolute;outline:3px solid #e8a317;outline-offset:2px}
'''


def tray_pieces(x0, y0, n=4):
    o = []
    for i in range(n):
        o.append(local(f'tray-demo-{i}.png', x0 + i * 156, y0, 74, 52))
        o.append(f'<i class="val" style="left:{x0 + i * 156 + (PX + 13) * S}px;top:{y0 + (PY + 2) * S}px;width:{12 * S}px;height:{10 * S}px;line-height:{10 * S}px;font-size:15px">{[3, 2, 1, 1][i]}</i>')
    return '\n'.join(o)


def phone():
    W, H = 412, 900
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, 'MAP BACKGROUND: the map screen where the fight began (crop 206x450 art px at 2x). Behind everything.', 1, 'background:rgba(255,42,42,.06);display:flex;align-items:flex-end'))
    o.append(history(W))
    o.append(call(W - 30, 34, 2))
    # player (left) and creature (right), above the board
    o.append(ph(8, 68, 100, 100, 'PLAYER 64x64', 8))
    o.append(f'<div class="panel" style="left:8px;top:170px;width:100px;height:24px;font:bold 12px/20px system-ui;text-align:center">You</div>')
    o.append(ph(304, 68, 100, 100, 'CREATURE 64x64', 3, 'text-align:right'))
    o.append(f'<div class="panel" style="left:304px;top:170px;width:100px;height:24px;font:bold 12px/20px system-ui;text-align:center">Rowdy Boar</div>')
    o.append(ph(116, 72, 180, 22, 'bar-frame 96x12 (hurt / charm fills)', 5))
    o.append(ph(116, 100, 60, 48, 'bubble 28x24', 4))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:132px;top:108px;width:40px;height:40px">')
    o.append(ph(236, 100, 60, 60, 'combo 32x32', 9))
    # board
    o.append('<div class="panel" style="left:8px;top:200px;width:396px;height:288px;background:rgba(42,26,16,.55);border-color:#e8a317"></div>')
    o.append('<div class="lbl" style="left:16px;top:204px">BOARD: shared 2D puzzle. Pieces attach one at a time to an open edge</div>')
    o.append(board(20, 224))
    o.append(call(372, 206, 7))
    o.append('<div class="btn alt" style="left:8px;top:496px;width:120px">Undo</div><div class="btn" style="left:136px;top:496px;width:268px">End turn</div>')
    # hand tray
    o.append('<div class="lbl" style="left:12px;top:552px">YOUR HAND (swipe; tap to inspect)</div>')
    o.append(f'<div class="tray" style="left:0;top:572px;width:{W}px;height:136px"><div class="in" style="left:0;top:0;width:1200px;height:136px">')
    o.append(tray_pieces(10, 10))
    o.append('</div></div>')
    o.append('<div class="sel" style="left:8px;top:578px;width:148px;height:116px"></div>')
    o.append(call(376, 556, 10))
    # inspect card
    o.append('<div class="panel" style="left:8px;top:716px;width:396px;height:176px"></div>')
    o.append(local('inspect-demo.png', 14, 720, 132, 92, 'width:200px;height:140px'))
    o.append('<div class="txt" style="left:226px;top:726px;width:170px"><b>Swing</b><br>Hurt 3. Connects to a <b>Mind</b> hole on the right, <b>Craft</b> knob underneath.<br><span style="color:#e8a317">Chain: +2 if it touches a Guard.</span></div>')
    o.append(call(376, 720, 11))
    o.append('</div>')
    return '\n'.join(o)


def wide():
    W, H = 980, 600
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, 'MAP BACKGROUND (same crop, wide). Behind everything.', 1, 'background:rgba(255,42,42,.06);display:flex;align-items:flex-end'))
    o.append(history(W))
    o.append(ph(24, 90, 180, 170, 'PLAYER 64x64', 8))
    o.append(f'<div class="panel" style="left:24px;top:264px;width:180px;height:26px;font:bold 14px/22px system-ui;text-align:center">You</div>')
    o.append(ph(776, 90, 180, 170, 'CREATURE 64x64', 3, 'text-align:right'))
    o.append(f'<div class="panel" style="left:776px;top:264px;width:180px;height:26px;font:bold 14px/22px system-ui;text-align:center">Rowdy Boar</div>')
    o.append(ph(704, 70, 60, 48, 'bubble 28x24', 4))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:720px;top:76px;width:40px;height:40px">')
    o.append(ph(300, 70, 380, 24, 'bar-frame 96x12 (shared resolve bar)', 5))
    o.append(ph(24, 300, 64, 64, 'combo stamp', 9))
    o.append('<div class="panel" style="left:290px;top:104px;width:400px;height:292px;background:rgba(42,26,16,.55);border-color:#e8a317"></div>')
    o.append(board(304, 126))
    o.append(call(660, 108, 7))
    o.append('<div class="btn alt" style="left:24px;top:420px;width:180px">Undo</div><div class="btn" style="left:24px;top:472px;width:180px">End turn</div>')
    o.append('<div class="lbl" style="left:290px;top:412px">YOUR HAND</div>')
    o.append(tray_pieces(290, 436, 3))
    o.append('<div class="sel" style="left:288px;top:442px;width:148px;height:116px"></div>')
    o.append(call(660, 412, 10))
    o.append('<div class="panel" style="left:776px;top:320px;width:180px;height:200px"></div>')
    o.append('<img src="inspect-demo.png" style="left:784px;top:330px;width:172px;height:120px">')
    o.append('<div class="txt" style="left:784px;top:452px;width:166px"><b>Swing</b>, Hurt 3.<br><span style="color:#e8a317">Chain: +2 next to a Guard.</span></div>')
    o.append(call(930, 322, 11))
    o.append('</div>')
    return '\n'.join(o)


print(f'''<!doctype html><meta charset="utf-8"><title>Puzzle Combat layout mockup v2</title><style>{CSS}</style>
<h1>Puzzle Combat: fight screen layout (2D jigsaw board)</h1>
<div class="legend"><span><i class="key" style="outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12)"></i>RED = placeholder, art not drawn yet</span><span><i class="key" style="border:3px solid #ff2a2a;border-radius:50%;width:22px;background:rgba(255,42,42,.25)"></i>RED circle = open socket (attach point) marker</span><span>Solid = real art delivered</span><span>Numbers match SPEC.md</span></div>
<h2>A. Phone portrait 412 wide (art at 2x)</h2>{phone()}
<h2>B. Wide / landscape (art at 2x)</h2>{wide()}''')
