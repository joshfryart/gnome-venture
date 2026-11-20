#!/usr/bin/env python3
"""Builds the Garden Yard picture assets from the Aseprite output.
Reads aseprite-source/v3/states2/<building>/<building>-{empty,l1,l2,l3,ready-l1,ready-l2,ready-l3}.png (and fence-ready.png)
and aseprite-source/v3/scenes/garden-ground.png, writes game/assets/img/gyard/*.png and game/assets/gyard.css.
Every sprite is placed by percentages of the 480x270 ground picture (the art is drawn on a 240x135 grid at x2). Run from the repo root."""
import os, shutil
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'aseprite-source/v3/states2')
OUT = os.path.join(ROOT, 'game/assets/img/gyard')
KEYS = ['kitchen', 'beehive', 'greenhouse', 'tailor', 'tool_shed', 'compost_bin', 'rain_barrel', 'root_cellar', 'worm_farm', 'ladybird_lodge',
        'snail_jar', 'frog_pond', 'quail_coop', 'silk_shelf', 'tortoise_run', 'butterfly_bush', 'fence']
# feet (ground contact) of every building on the 240x135 grid; the art puts it at (W/2, H-10) of each sprite
POS = {'greenhouse': (20, 62), 'tailor': (58, 62), 'kitchen': (120, 62), 'tool_shed': (183, 62), 'compost_bin': (221, 62), 'beehive': (24, 92),
       'root_cellar': (60, 92), 'worm_farm': (99, 92), 'ladybird_lodge': (141, 92), 'snail_jar': (181, 92), 'rain_barrel': (218, 92), 'fence': (27, 122),
       'quail_coop': (64, 122), 'silk_shelf': (100, 122), 'tortoise_run': (140, 122), 'butterfly_bush': (180, 122), 'frog_pond': (219, 126)}

STATIC = """.gyard .gy-scene{position:relative;width:100%;aspect-ratio:480/270;border:2px solid var(--line);background:#9fc27a;overflow:hidden;margin:0 0 8px}
.gy-ground{position:absolute;left:0;top:0;width:100%;height:100%;image-rendering:pixelated;display:block}
.gy-sp{position:absolute;image-rendering:pixelated;pointer-events:none;display:block}
.gy-a{background-repeat:no-repeat;background-size:400% 100%;animation:gyf4 .8s steps(1,end) infinite}
@keyframes gyf4{0%{background-position:0% 0}25%{background-position:33.3333% 0}50%{background-position:66.6667% 0}75%{background-position:100% 0}}
.gy-locked{opacity:.55}
.gy-hit{position:absolute;display:block;background:transparent;border:0;cursor:pointer;text-decoration:none}
.gy-hit::before{content:"";position:absolute;inset:-10px -4px}
.gy-hit::after{content:"";position:absolute;inset:0;border:2px solid transparent;pointer-events:none}
.gy-hit:hover::after,.gy-hit:focus-visible::after,.gy-hit.on::after{border-color:#ffe9a3;border-style:dashed}
.gy-hit:focus-visible{outline:none}
.gyard .gy-tools{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin:8px 0 0}
.gyard .gy-hint{margin:6px 0 0;font-size:13px}
@media (prefers-reduced-motion:reduce){.gy-a{animation:none}}"""

STATIC2 = """.gyt{position:relative;flex:none;width:112px;height:112px;overflow:hidden;background:#c4e3b8;border:2px solid #150d08;box-sizing:content-box}
.gyt>span{position:absolute;image-rendering:pixelated;background-repeat:no-repeat;animation-duration:.8s;animation-timing-function:steps(1,end);animation-iteration-count:infinite}
.gyt-b{position:absolute;right:5px;top:5px;z-index:2;width:22px;height:22px;border-radius:50%;background:#e8a317;border:2px solid #150d08;color:#2a1a10;font:800 14px/18px system-ui;text-align:center;font-style:normal;animation:gyb .8s steps(1,end) infinite}
@keyframes gyb{0%{transform:translateY(0)}25%{transform:translateY(-1px)}50%{transform:translateY(0)}75%{transform:translateY(1px)}}
dialog.gycard .pickbox{width:min(330px,calc(100vw - 28px));padding:0;overflow:hidden;max-height:calc(100vh - 24px);max-height:calc(100dvh - 24px);display:flex;flex-direction:column}
.gycard .gyhd{flex:none}
.gycard .gybd{flex:1 1 auto;min-height:0;overflow-y:auto;-webkit-overflow-scrolling:touch;overscroll-behavior:contain;touch-action:pan-y}
.gycard .gybd.fence{min-height:0;gap:8px}
.gycard .gybd.fence .gynow{min-height:0;-webkit-line-clamp:2;font-size:13px}
.gycard .gybd.fence .help,.gycard .gybd.fence .muted{font-size:12px;margin:0}
@media (max-height:640px){.gycard .gyhd{min-height:0;padding:8px 10px 8px 12px}.gycard .gyt{transform:none}}
.gyhd{display:flex;gap:12px;align-items:center;padding:12px 10px 12px 12px;min-height:140px;background:var(--surface-2,#4a3322);border-bottom:2px dashed var(--thread,#e8a317)}
.gytt{flex:1;min-width:0;display:flex;flex-direction:column;gap:7px}
.gytt b{font-size:19px;line-height:1.1}
.gychips{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.gypill{font:700 11px system-ui,sans-serif;padding:2px 7px;border:1px solid var(--line);background:var(--bg-2,transparent);color:var(--muted)}
.gypill.g{background:var(--thread,#e8a317);color:#2a1a10;border-color:var(--thread,#e8a317)}
.gyx:focus{outline:none}
.gyx:focus-visible{outline:2px dashed #ffe9a3}
.gyx{flex:none;align-self:flex-start;width:36px;height:36px;margin:-6px -4px 0 0;display:flex;align-items:center;justify-content:center;text-decoration:none;font-size:20px}
.gybd{padding:12px;display:flex;flex-direction:column;gap:10px}
.gybd.home{min-height:262px}
.gybd:not(.home){min-height:176px}
.gynow{margin:0;font-size:14px;line-height:1.4;min-height:4.2em;display:-webkit-box;-webkit-box-orient:vertical;-webkit-line-clamp:3;overflow:hidden}
.gyst{display:-webkit-box;-webkit-box-orient:vertical;-webkit-line-clamp:2;overflow:hidden}
.gystrip{margin:0;min-height:50px;display:flex;gap:8px;align-items:center;padding:7px 9px;font-size:13px;line-height:1.35;border:1px solid var(--line);color:var(--muted)}
.gystrip.alert{border-color:var(--thread,#e8a317);color:var(--ink)}
.gystrip i{flex:none;width:18px;height:18px;border-radius:50%;background:var(--thread,#e8a317);color:#2a1a10;font:800 12px/16px system-ui;text-align:center;font-style:normal;border:1px solid #150d08}
.gyacts{display:flex;gap:8px;flex-wrap:wrap;margin-top:auto;min-height:44px}
.gyacts form{flex:1 1 28%;margin:0;min-width:0}
.gyacts .btn,.gyacts .gypill{width:100%;white-space:nowrap}
.gyacts .gymore{flex:0 0 auto;width:auto;padding:0 14px}
.gyacts .gypill{flex:1;text-align:center;padding:12px 6px;font-size:12px}
.gyslots{list-style:none;margin:0;padding:0;display:grid;grid-template-columns:repeat(4,1fr);gap:6px}
.gyslot{border:1px solid var(--line);min-height:64px;padding:5px 2px 4px;text-align:center;font-size:11px;line-height:1.2;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px;min-width:0}
.gyslot .cimg{width:30px;height:30px}
.gyslot b,.gyslot small{max-width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.gyslot.free{border-style:dashed;color:var(--muted)}
.gyslot.free b{font-size:20px;line-height:1}
.gywelcome{display:flex;gap:6px;margin:0}
.gywelcome input{flex:1;min-width:0}
@media (prefers-reduced-motion:reduce){.gyt>span,.gyt-b{animation:none}}"""

def pct(v, t):
    s = ('%.3f' % (v / t * 100)).rstrip('0').rstrip('.')
    return s + '%'

def bbox_union(im, W, H, frames, body=0.7):
    bb = None
    for i in range(frames):
        a = im.crop((i * W, 0, (i + 1) * W, H)).getchannel('A').point(lambda v: 255 if v else 0)
        b = a.getbbox()
        if b:
            top = int(b[1] + (1 - body) * (b[3] - b[1]))   # only the lower part of the drawing takes taps
            b = a.crop((0, top, W, b[3])).getbbox()
            b = (b[0], b[1] + top, b[2], b[3] + top)
            bb = b if bb is None else (min(bb[0], b[0]), min(bb[1], b[1]), max(bb[2], b[2]), max(bb[3], b[3]))
    return bb


TILE = 112   # the art tile in a card is a fixed square; the building is cropped to its drawn pixels and zoomed by a whole number to fill it

def tile_css(k, st, im, W, H, frames, still_for_box, fname):
    """One tile class: the sprite (or strip) cropped to the building and centred in the square. Ready tiles are cropped to the still of the same level, so the badge is drawn by CSS."""
    bb = bbox_union(still_for_box, W, H, 1, body=1.0)
    x0, y0, x1, y1 = max(0, bb[0] - 1), max(0, bb[1] - 1), min(W, bb[2] + 1), min(H, bb[3] + 1)
    bw, bh = x1 - x0, y1 - y0
    z = max(1, int(min((TILE - 8) / bw, (TILE - 8) / bh)))
    ox, oy = (TILE - bw * z) // 2, (TILE - bh * z) // 2
    name = 'gyt-%s-%s' % (k, st)
    rule = '.%s{left:%dpx;top:%dpx;width:%dpx;height:%dpx;background-image:url(img/gyard/%s);background-size:%dpx %dpx;background-position:%dpx %dpx' % (
        name, ox, oy, bw * z, bh * z, fname, frames * W * z, H * z, -x0 * z, -y0 * z)
    out = []
    if frames > 1:
        rule += ';animation-name:%s' % name
        kf = ''.join('%d%%{background-position:%dpx %dpx}' % (i * 25, -(x0 + i * W) * z, -y0 * z) for i in range(4))
        out.append('@keyframes %s{%s}' % (name, kf))
    out.insert(0, rule + '}')
    return out

def save(im, name):
    im.save(os.path.join(OUT, name), 'PNG', optimize=True)

def main():
    os.makedirs(OUT, exist_ok=True)
    css = ['/* GENERATED by tools/build_gyard_assets.py (do not edit). The Garden Yard picture: sprites are placed in percentages of the 480x270 ground picture. */', STATIC, STATIC2]
    shutil.copyfile(os.path.join(ROOT, 'aseprite-source/v3/scenes/garden-ground.png'), os.path.join(OUT, 'ground.png'))
    for k in KEYS:
        d = os.path.join(SRC, k, k)
        if k == 'fence':
            r = Image.open(d + '-ready.png').convert('RGBA'); W = r.width // 4; H = r.height
            idle = r.crop((0, 0, W, H)); idle.paste((0, 0, 0, 0), (W - 14, 0, W, 13))   # the idle fence has no badge
            save(idle, 'fence-i.png'); save(r, 'fence-r1.png')
            states = {'i': (idle, 1)}
            tiles = tile_css('fence', 'i', idle, W, H, 1, idle, 'fence-i.png') + tile_css('fence', 'r1', r, W, H, 4, idle, 'fence-r1.png')
        else:
            l1 = Image.open(d + '-l1.png').convert('RGBA'); W, H = l1.size
            states = {}
            for lv in (1, 2, 3):
                im = Image.open(d + '-l%d.png' % lv).convert('RGBA'); save(im, '%s-l%d.png' % (k, lv)); states['l%d' % lv] = (im, 1)
                rr = Image.open(d + '-ready-l%d.png' % lv).convert('RGBA'); save(rr, '%s-r%d.png' % (k, lv))
            e = Image.open(d + '-empty.png').convert('RGBA'); save(e, '%s-e.png' % k); states['e'] = (e, 4)
            tiles = []
            tiles += tile_css(k, 'e', e, W, H, 4, e.crop((0, 0, W, H)), '%s-e.png' % k)
            for lv in (1, 2, 3):
                tiles += tile_css(k, 'l%d' % lv, states['l%d' % lv][0], W, H, 1, states['l%d' % lv][0], '%s-l%d.png' % (k, lv))
                rr = Image.open(d + '-ready-l%d.png' % lv).convert('RGBA')
                tiles += tile_css(k, 'r%d' % lv, rr, W, H, 4, states['l%d' % lv][0], '%s-r%d.png' % (k, lv))
        css += tiles
        x, y = POS[k]
        left, top = (x - W / 2) * 2, (y - (H - 10)) * 2
        css.append('.gy-%s{left:%s;top:%s;width:%s;height:%s}' % (k, pct(left, 480), pct(top, 270), pct(W * 2, 480), pct(H * 2, 270)))
        for st, (im, n) in states.items():
            bb = bbox_union(im, W, H, n)
            hl, ht, hw, hh = left + bb[0] * 2, top + bb[1] * 2, (bb[2] - bb[0]) * 2, (bb[3] - bb[1]) * 2
            css.append('.gy-h-%s-%s{left:%s;top:%s;width:%s;height:%s}' % (k, st, pct(hl, 480), pct(ht, 270), pct(hw, 480), pct(hh, 270)))
        # animated strips: empty (e) and ready (r1..r3, fence r1)
        for st in (['e', 'r1', 'r2', 'r3'] if k != 'fence' else ['r1']):
            css.append('.gy-bg-%s-%s{background-image:url(img/gyard/%s-%s.png)}' % (k, st, k, st))
    print('\n'.join(css))

if __name__ == '__main__':
    import io, contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        main()
    open(os.path.join(ROOT, 'game/assets/gyard.css'), 'w').write(buf.getvalue())
