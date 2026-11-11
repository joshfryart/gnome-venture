#!/usr/bin/env python3
"""Fight-screen layout mockup. RED outline = placeholder art that is not drawn yet. Solid = delivered art.
Everything is laid out in CSS px at 2x native art (phone 412 wide). Run: python3 make_mockup.py > mockup.html"""
A = '../../../game/assets/img/pfight/'   # relative to aseprite-source/pfight/layout/
S = 2


def img(name, x, y, w, h, extra=''):
    return f'<img src="{A}{name}" style="left:{x}px;top:{y}px;width:{w * S}px;height:{h * S}px;{extra}">'


def ph(x, y, w, h, label, n=None, extra=''):
    """red-outlined placeholder, w/h in CSS px"""
    num = f'<b class="n">{n}</b>' if n else ''
    return f'<div class="ph" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;{extra}"><span>{label}</span>{num}</div>'


def call(x, y, n):
    return f'<b class="n" style="left:{x}px;top:{y}px">{n}</b>'


def strip_piece(t, hf, kf, x, y, foe=False):
    st = 'foe' if foe else 'me'
    s = f'<div class="p" style="left:{x}px;top:{y}px;width:{65 * S}px;height:{40 * S}px">'
    s += f'<img src="{A}piece-strip-{t}-{hf}-{kf}.png" style="left:0;top:0;width:{65 * S}px">'
    s += f'<img src="{A}ico-{t}-s.png" style="left:{21 * S}px;top:{14 * S}px;width:{20 * S}px">'
    s += f'<img src="{A}edge-strip-{st}-{hf}-{kf}.png" style="left:0;top:0;width:{65 * S}px">'
    return s + '</div>'


def hand_piece(t, hf, kf, x, y, val, name, picked=False):
    s = f'<div class="p" style="left:{x}px;top:{y}px;width:{114 * S}px;height:{68 * S + 22}px">'
    if picked:
        s += f'<img src="{A}frame-picked-hand.png" style="left:{-2 * S}px;top:{-2 * S - 6}px;width:{100 * S}px">'
    ty = -6 if picked else 0
    s += f'<img src="{A}piece-hand-{t}-{hf}-{kf}.png" style="left:0;top:{ty}px;width:{114 * S}px">'
    s += f'<img src="{A}ico-{t}.png" style="left:{37 * S}px;top:{9 * S + ty}px;width:{32 * S}px">'
    s += f'<img src="{A}edge-hand-me-{hf}-{kf}.png" style="left:0;top:{ty}px;width:{114 * S}px">'
    s += f'<i class="val" style="left:{21 * S}px;top:{3 * S + ty}px;width:{14 * S}px;height:{12 * S}px;line-height:{12 * S}px">{val}</i>'
    s += f'<i class="nm" style="left:{24 * S}px;top:{50 * S + ty}px;width:{56 * S}px">{name}</i>'
    return s + '</div>'


def chip(who, types, res, x):
    """history chip"""
    s = f'<div class="chip {who}" style="left:{x}px">'
    s += '<em>' + ('YOU' if who == 'me' else 'FOE') + '</em>'
    for t in types:
        s += f'<img src="{A}ico-{t}-s.png" style="position:static;width:20px;height:20px">'
    return s + f'<strong>{res}</strong></div>'


def history(w):
    h = f'<div class="hist" style="width:{w}px">'
    h += ph(6, 6, 52, 44, 'PORTRAIT', None, 'position:absolute')  # replaced below
    h = f'<div class="hist" style="width:{w}px"><div class="hl">HISTORY</div><div class="hscroll">'
    xs = 0
    for who, types, res in (('me', ['guard'], '+2 guard'), ('foe', ['hurt'], '-3'), ('me', ['hurt', 'trick'], '-5 combo'),
                            ('foe', ['soothe', 'charm'], 'charm +2'), ('me', ['charm', 'item'], 'charm +4')):
        h += chip(who, types, res, xs)
        xs += 40 + 22 * len(types) + 64
    return h + '</div></div>'


CSS = '''
body{margin:0;background:#1d130c;color:#f2e4c0;font:14px system-ui,sans-serif;padding:20px}
h1,h2{margin:.4rem 0}.legend{display:flex;gap:1.5rem;align-items:center;margin:.5rem 0 1rem}
.key{display:inline-block;width:38px;height:22px;vertical-align:middle;margin-right:6px}
.frame{position:relative;overflow:hidden;background:#3d2a1c;border:2px solid #000;margin:0 24px 24px 0;display:inline-block;vertical-align:top}
.frame *{box-sizing:border-box}.frame img{position:absolute;image-rendering:pixelated}
.ph{position:absolute;outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12);color:#ff9a9a;font:11px/1.25 system-ui;padding:5px 6px;overflow:hidden}
.ph span{display:block}.n{position:absolute;z-index:9;min-width:22px;height:22px;border-radius:11px;background:#ff2a2a;color:#fff;font:bold 12px/22px system-ui;text-align:center;right:3px;top:3px;padding:0 4px}
.p{position:absolute}.p img{position:absolute}
.panel{position:absolute;background:rgba(42,26,16,.9);border:2px solid #f2e4c0;color:#f2e4c0}
.hist{position:absolute;left:0;top:0;height:60px;background:rgba(42,26,16,.92);border-bottom:3px solid #e8a317;overflow:hidden}
.hl{position:absolute;left:6px;top:2px;font:bold 10px system-ui;color:#e8a317}
.hscroll{position:absolute;left:8px;top:18px;height:36px}
.chip{position:absolute;top:0;height:36px;display:flex;align-items:center;gap:3px;padding:0 6px;border:2px solid #f2e4c0;border-radius:6px;background:#3d2a1c;white-space:nowrap}
.chip.foe{border:2px dashed #c96;background:#2a1a10}.chip em{font:bold 10px system-ui;font-style:normal;color:#e8a317}.chip strong{font:bold 11px system-ui;margin-left:3px}
.val{position:absolute;color:#f2e4c0;font:bold 20px system-ui;text-align:center;font-style:normal}
.nm{position:absolute;color:#2a1a10;background:#f2e4c0;border-radius:4px;text-align:center;font:bold 13px/18px system-ui;font-style:normal;height:18px}
.btn{position:absolute;background:#e8a317;color:#2a1a10;border:3px solid #2a1a10;border-radius:8px;font:bold 15px/1 system-ui;text-align:center;padding:10px 0}
.btn.alt{background:#f2e4c0}
.lbl{position:absolute;color:#f2e4c0;font:bold 12px system-ui;text-shadow:0 1px 0 #000}
.tray{position:absolute;overflow:hidden}
.tray .in{position:absolute;white-space:nowrap}
.cap{max-width:420px;color:#d9c9a0;font-size:12px}
'''


def rail(x, y, w):
    return ph(x, y, w, 48, 'strip-rail.png (24px high, tiles horizontally)', None)


def phone():
    W, H = 412, 900
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, 'MAP BACKGROUND: the map screen where the fight began (crop, 206x450 art px at 2x). Full screen behind everything.', 1, 'background:rgba(255,42,42,.06);padding-top:70px'))
    o.append(history(W))
    o.append(call(W - 30, 34, 2))
    # creature side (upper right)
    o.append(ph(238, 82, 160, 160, 'CREATURE SPRITE 64x64 (shown 2x +). Faces left.', 3, 'text-align:right'))
    o.append(f'<div class="panel" style="left:238px;top:246px;width:160px;height:30px;font:bold 14px/26px system-ui;text-align:center">Rowdy Boar</div>')
    o.append(ph(160, 98, 60, 52, 'bubble 28x24', 4))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:176px;top:108px;width:40px;height:40px">')
    # shared resolve bar
    o.append(ph(110, 284, 192, 24, 'bar-frame 96x12 (+ bar-fill-hurt / bar-fill-charm 92x8 fills from both sides)', 5))
    o.append(f'<div class="lbl" style="left:112px;top:310px">HURT &larr;</div><div class="lbl" style="left:250px;top:310px">&rarr; CHARM</div>')
    # board
    o.append(f'<div class="panel" style="left:8px;top:340px;width:396px;height:150px;background:rgba(61,42,28,.88);border-color:#e8a317"></div>')
    o.append(f'<div class="lbl" style="left:16px;top:344px">BOARD: one shared strip, scrolls to the open end</div>')
    o.append(rail(12, 420, 388))
    xs = 18
    pieces = [('hurt', 'flat', 'body', False), ('guard', 'body', 'mind', False), ('trick', 'mind', 'craft', True), ('hurt', 'craft', 'body', True)]
    for i, (t, h, k, foe) in enumerate(pieces):
        o.append(strip_piece(t, h, k, 14 + i * 112, 368, foe))
    o.append(ph(14 + 4 * 112 + 4, 380, 48, 48, 'open-end 24x24', 6))
    o.append(call(380, 352, 7))
    # player (lower left)
    o.append(ph(10, 506, 128, 128, 'PLAYER AVATAR (gnome_avatar), 64x64 at 2x. Faces right.', 8))
    o.append(f'<div class="panel" style="left:10px;top:638px;width:128px;height:28px;font:bold 14px/24px system-ui;text-align:center">You</div>')
    o.append(ph(150, 520, 64, 64, 'combo stamp 32x32 (pops when a combo fires)', 9))
    o.append(f'<div class="btn" style="left:226px;top:508px;width:170px">Play chain</div>')
    o.append(f'<div class="btn alt" style="left:226px;top:560px;width:170px">Undo last tile</div>')
    o.append(f'<div class="btn alt" style="left:226px;top:612px;width:170px">Pass</div>')
    # hand tray
    o.append(f'<div class="lbl" style="left:12px;top:676px">YOUR HAND (swipe)</div>')
    o.append(f'<div class="tray" style="left:0;top:696px;width:{W}px;height:190px"><div class="in" style="left:10px;top:12px;width:1400px;height:170px">')
    hp = [('hurt', 'body', 'mind', 3, 'Swing', True), ('guard', 'mind', 'craft', 2, 'Leaf Shield', False), ('heal', 'craft', 'body', 2, 'Herb Tea', False),
          ('charm', 'body', 'body', 1, 'Posy', False), ('item', 'flat', 'craft', 1, 'Honey Jar', False)]
    for i, (t, h, k, v, nm, pk) in enumerate(hp):
        o.append(hand_piece(t, h, k, i * 214, 6, v, nm, pk))
    o.append('</div></div>')
    o.append(call(380, 678, 10))
    o.append('</div>')
    return '\n'.join(o)


def wide():
    W, H = 960, 560
    o = [f'<div class="frame" style="width:{W}px;height:{H}px">']
    o.append(ph(0, 0, W, H, 'MAP BACKGROUND (same crop, wide). Full screen behind everything.', 1, 'background:rgba(255,42,42,.06);padding-top:70px'))
    o.append(history(W))
    # left player
    o.append(ph(24, 122, 180, 160, 'PLAYER AVATAR 64x64', 8))
    o.append(f'<div class="panel" style="left:24px;top:288px;width:180px;height:28px;font:bold 14px/24px system-ui;text-align:center">You</div>')
    o.append(ph(24, 316, 64, 64, 'combo stamp 32x32', 9))
    o.append(f'<div class="btn" style="left:24px;top:400px;width:180px">Play chain</div><div class="btn alt" style="left:24px;top:452px;width:180px">Undo</div>')
    # right creature
    o.append(ph(756, 122, 180, 160, 'CREATURE SPRITE 64x64', 3, 'text-align:right'))
    o.append(f'<div class="panel" style="left:756px;top:288px;width:180px;height:28px;font:bold 14px/24px system-ui;text-align:center">Rowdy Boar</div>')
    o.append(ph(752, 66, 60, 52, 'bubble 28x24', 4))
    o.append(f'<img src="{A}ico-hurt-s.png" style="left:768px;top:76px;width:40px;height:40px">')
    # middle board
    o.append(ph(300, 76, 360, 24, 'bar-frame 96x12 (shared resolve bar)', 5))
    o.append(f'<div class="panel" style="left:224px;top:130px;width:512px;height:200px;background:rgba(61,42,28,.88);border-color:#e8a317"></div>')
    o.append(f'<div class="lbl" style="left:232px;top:134px">BOARD</div>')
    o.append(rail(232, 232, 496))
    for i, (t, h, k, foe) in enumerate([('hurt', 'flat', 'body', False), ('guard', 'body', 'mind', False), ('trick', 'mind', 'craft', True), ('hurt', 'craft', 'body', True)]):
        o.append(strip_piece(t, h, k, 236 + i * 112, 180, foe))
    o.append(ph(236 + 4 * 112 + 4, 192, 48, 48, 'open-end 24x24', 6))
    # hand under board
    o.append(f'<div class="lbl" style="left:232px;top:344px">YOUR HAND</div>')
    for i, (t, h, k, v, nm, pk) in enumerate([('hurt', 'body', 'mind', 3, 'Swing', True), ('guard', 'mind', 'craft', 2, 'Leaf Shield', False), ('heal', 'craft', 'body', 2, 'Herb Tea', False)]):
        o.append(hand_piece(t, h, k, 232 + i * 240, 372, v, nm, pk))
    o.append('</div>')
    return '\n'.join(o)


print(f'''<!doctype html><meta charset="utf-8"><title>Puzzle Combat layout mockup</title><style>{CSS}</style>
<h1>Puzzle Combat: fight screen layout</h1>
<div class="legend"><span><i class="key" style="outline:3px solid #ff2a2a;outline-offset:-3px;background:rgba(255,42,42,.12)"></i>RED outline = placeholder, art not drawn yet (size given)</span><span>Solid = real art already delivered (pieces, icons, edges)</span><span>Numbers match SPEC.md</span></div>
<h2>A. Phone portrait 412 wide (art at 2x)</h2>{phone()}
<h2>B. Wide / landscape (art at 2x)</h2>{wide()}''')
