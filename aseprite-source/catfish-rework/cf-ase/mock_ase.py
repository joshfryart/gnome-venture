import sys, os, json, shutil, glob, io, contextlib
sys.path.insert(0, '/home/user/gnome-venture/tools')
import catfish_recolor as r
from PIL import Image
B = os.path.dirname(os.path.abspath(__file__)) + '/'
NEW = B + 'out/'
RICH = os.path.dirname(B.rstrip('/')) + '/cf-new/rich/'
O = '/home/user/gnome-venture/game/assets/img/catfish/'
CF = '/home/user/gnome-venture/aseprite-source/catfish/'
_orig = r.ramp
def ramp2(base):   # runtime patch (as cf-new/mock.py): lift + rim roles
    o = _orig(base)
    a, b = r.h2rgb(o['base']), r.h2rgb(o['light'])
    o['lift'] = r.hex_([(x + y) // 2 for x, y in zip(a, b)])
    h, s, l = r.to_hsl(o['shade'])
    o['rim'] = r.from_hsl(r.toward(h, 265, 40), min(1, s * 0.9), min(0.9, l * 1.12))
    return o
r.ramp = ramp2
OVJ = B + 'tones_overlays.ase.json'
d = json.load(open(os.path.dirname(B.rstrip('/')) + '/cf-new/tones_overlays.rich.json'))
d['patch_white_deep'] = {"hex": "#8d829a", "derive": "fixed"}
json.dump(d, open(OVJ, 'w'), indent=1)

def prep(src, ov):
    dd = B + 'cmp/' + os.path.basename(src.rstrip('/')) + '/'
    shutil.rmtree(dd, ignore_errors=True); os.makedirs(dd)
    for f in glob.glob(src + 'cf-cat-grey-*.png') + glob.glob(ov + '*.png'): shutil.copy(f, dd)
    for fr in ('idleA', 'pounce', 'catch', 'nap'):
        for f in glob.glob(O + 'cf-eyes-*-%s.png' % fr): shutil.copy(f, dd)
    return dd

SPECS = [('grey', 'idleA', 'tabby', 'amber', None, None), ('orange', 'idleA', 'tabby', 'amber', 'folded', None),
         ('cream', 'pounce', 'calico', 'blue', None, None), ('black', 'catch', 'tuxedo', 'green', None, 'bobtail'),
         ('brown', 'nap', 'spotted', 'hazel', None, None), ('silver-blue', 'idleA', 'pointed', 'blue', None, None),
         ('lilac', 'pounce', 'tabby', 'green', 'folded', 'bobtail'), ('white', 'catch', 'spotted', 'blue', None, None),
         ('grey', 'nap', 'tuxedo', 'hazel', 'folded', None)]
def comp(dd, specs):
    ims = []
    for coat, fr, pat, eye, ears, tail in specs:
        img = r.compose(coat, fr, dd, pat, eye, ears, tail, CF + 'tones.json', OVJ)
        e = r.check_compose(img)
        if e: print('COMPOSE', coat, fr, pat, e)
        ims.append(Image.fromarray(img, 'RGBA'))
    return ims

def files(src): return [src + 'cf-cat-grey-%s.png' % f for f in ('idleA', 'pounce', 'catch', 'nap')] + [src + 'cf-fish-%d.png' % i for i in range(1, 6)]
def row(fs, bg):
    W = Image.new('RGBA', (2016, 256), bg); x = 0
    for p in fs[:4]: W.alpha_composite(Image.open(p).convert('RGBA').resize((256, 256), 0), (x, 0)); x += 256
    for p in fs[4:]:
        if os.path.exists(p): W.alpha_composite(Image.open(p).convert('RGBA').resize((192, 192), 0), (x, 32))
        x += 196
    return W
def rowims(ims, bg):
    W = Image.new('RGBA', (2016, 256), bg)
    for i, im in enumerate(ims): W.alpha_composite(im.resize((256, 256), 0) if i < 7 else im.resize((256, 256), 0), (i * 224 if len(ims) > 7 else i * 256, 0))
    return W
def strip(fs, bg):
    W = Image.new('RGBA', (2016, 256), bg); x = 8
    for sc in (1, 2):
        for p in fs:
            if not os.path.exists(p): continue
            im = Image.open(p).convert('RGBA'); w = im.size[0] * sc
            W.alpha_composite(im.resize((w, w), 0), (x, 8)); x += w + 6
        x += 24
    return W

if __name__ == '__main__':
    rd = prep(RICH, RICH + 'overlays/'); nd = prep(NEW, NEW + 'overlays/')
    rc = comp(rd, SPECS[:8]); nc = comp(nd, SPECS)
    rows = [lambda bg: row(files(RICH), bg), lambda bg: row(files(NEW), bg),
            lambda bg: rowims(nc[:5], bg), lambda bg: rowims(nc[5:], bg), lambda bg: strip(files(NEW) + [], bg)]
    n = len(rows)
    H = Image.new('RGB', (2016, 256 * n * 2), (0, 0, 0))
    for h, bg in enumerate([(205, 205, 210, 255), (52, 46, 64, 255)]):
        for i, fn in enumerate(rows): H.paste(fn(bg).convert('RGB'), (0, (h * n + i) * 256))
    H.save(B + 'mockup-ase.png')
    # compact strips of composed coats for review
    C = Image.new('RGB', (9 * 200, 200), (205, 205, 210))
    for i, im in enumerate(nc):
        bgim = Image.new('RGBA', (192, 192), (205, 205, 210, 255) if i % 2 == 0 else (52, 46, 64, 255)); bgim.alpha_composite(im.resize((192, 192), 0)); C.paste(bgim.convert('RGB'), (i * 200, 4))
    C.save(B + '_coats.png')
