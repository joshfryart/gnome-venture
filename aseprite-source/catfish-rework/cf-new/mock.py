import sys, os, json, shutil, glob, numpy as np
sys.path.insert(0, '/home/user/gnome-venture/tools')
import catfish_recolor as r
from PIL import Image
B = os.path.dirname(os.path.abspath(__file__)) + '/'
O = '/home/user/gnome-venture/game/assets/img/catfish/'
CF = '/home/user/gnome-venture/aseprite-source/catfish/'

# patched ramp: adds lift + rim (needed for the rich pass)
_orig = r.ramp
def ramp2(base):
    o = _orig(base)
    a, b = r.h2rgb(o['base']), r.h2rgb(o['light'])
    o['lift'] = r.hex_([(x + y) // 2 for x, y in zip(a, b)])
    h, s, l = r.to_hsl(o['shade'])
    o['rim'] = r.from_hsl(r.toward(h, 265, 40), min(1, s * 0.9), min(0.9, l * 1.12))
    return o
r.ramp = ramp2

def overlays_json(path):
    d = json.load(open(B + 'tones_overlays.new.json'))
    d['coat_lift'] = {"hex": "#aca7b9", "derive": "coat_lift"}
    d['coat_rim'] = {"hex": "#646691", "derive": "coat_rim"}
    json.dump(d, open(path, 'w'))
overlays_json(B + 'tones_overlays.rich.json')

def prep(variant):
    d = B + variant + '/cmp/'
    shutil.rmtree(d, ignore_errors=True); os.makedirs(d)
    for f in glob.glob(B + variant + '/cf-cat-grey-*.png') + glob.glob(B + variant + '/overlays/*.png'): shutil.copy(f, d)
    for f in glob.glob(O + 'cf-eyes-*-idleA.png') + glob.glob(O + 'cf-eyes-*-pounce.png') + glob.glob(O + 'cf-eyes-*-catch.png') + glob.glob(O + 'cf-eyes-*-nap.png'): shutil.copy(f, d)
    return d

SPECS = [('orange', 'idleA', 'tabby', 'amber', 'folded', None), ('cream', 'pounce', 'calico', 'blue', None, None),
         ('black', 'catch', 'tuxedo', 'green', None, 'bobtail'), ('brown', 'nap', 'spotted', 'hazel', None, None)]
SPECS2 = [('silver-blue', 'idleA', 'pointed', 'amber', None, None), ('lilac', 'pounce', 'tabby', 'green', 'folded', 'bobtail'),
          ('white', 'catch', 'spotted', 'blue', None, None), ('grey', 'nap', 'tuxedo', 'hazel', 'folded', None)]

def comp(variant, specs, overlays):
    d = prep(variant)
    ims = []
    for coat, fr, pat, eye, ears, tail in specs:
        img = r.compose(coat, fr, d, pat, eye, ears, tail, CF + 'tones.json', overlays)
        errs = r.check_compose(img)
        if errs: print('COMPOSE', variant, coat, errs)
        ims.append(Image.fromarray(img, 'RGBA'))
    return ims

def row(files, bg, scale=4, fscale=3):
    W = Image.new('RGBA', (1984, 256), bg); x = 0
    for p in files[:4]: W.alpha_composite(Image.open(p).convert('RGBA').resize((64 * scale,) * 2, 0), (x, 0)); x += 256
    for p in files[4:]: W.alpha_composite(Image.open(p).convert('RGBA').resize((48 * fscale * 4 // 3,) * 2, 0), (x, 32)); x += 192
    return W
def rowims(ims, bg):
    W = Image.new('RGBA', (1984, 256), bg); x = 0
    for im in ims: W.alpha_composite(im.resize((256, 256), 0), (x, 0)); x += 256
    return W
def files(src):
    return [src + 'cf-cat-grey-%s.png' % f for f in ('idleA', 'pounce', 'catch', 'nap')] + [src + 'cf-fish-%d.png' % i for i in range(1, 6)]

def sheet(rowsA, rowsB, labels, out):
    n = len(rowsA)
    H = Image.new('RGB', (1984, 256 * n * 2), (0, 0, 0))
    for h, bg in enumerate([(205, 205, 210, 255), (52, 46, 64, 255)]):
        for i, fn in enumerate(rowsA): H.paste(fn(bg).convert('RGB'), (0, (h * n + i) * 256))
    H.save(out)

def v1files(): return files(B)
def v1row(bg): return row(files(B), bg)
def polrow(bg): return row(files(B + 'polish/'), bg)
def richrow(bg): return row(files(B + 'rich/'), bg)

if __name__ == '__main__':
    ovp = B + 'tones_overlays.new.json'
    pc = comp('polish', SPECS, ovp) ; pc2 = comp('polish', SPECS2, ovp)
    rc = comp('rich', SPECS, B + 'tones_overlays.rich.json'); rc2 = comp('rich', SPECS2, B + 'tones_overlays.rich.json')
    # v1 coats with OLD overlays (shows the misalignment fixed)
    sheet([v1row, polrow, lambda bg: rowims(pc, bg), lambda bg: rowims(pc2, bg)], None, None, B + 'mockup-polish.png')
    sheet([polrow, richrow, lambda bg: rowims(rc, bg), lambda bg: rowims(rc2, bg)], None, None, B + 'mockup-rich.png')
    # alignment proof: v1 body + OLD overlays vs polish body + NEW overlays (orange tabby, idleA/pounce/nap)
    import tempfile
    t = tempfile.mkdtemp(prefix='cfv1_', dir=B + 'polish')
    for f in glob.glob(O + 'cf-pat-*-grey-*.png') + glob.glob(O + 'cf-ears-mask-*.png') + glob.glob(O + 'cf-tail-mask-*.png') + glob.glob(O + 'cf-eyes-*-*.png'): shutil.copy(f, t)
    for f in glob.glob(B + 'cf-cat-grey-*.png'): shutil.copy(f, t)
    for f in glob.glob(O + 'cf-ears-folded-grey-*.png'):
        shutil.copy(f, t + '/' + os.path.basename(f).replace('-grey-', '-'))
    for f in glob.glob(O + 'cf-tail-bobtail-grey-*.png'): shutil.copy(f, t + '/' + os.path.basename(f).replace('-grey-', '-'))
    sp = [('orange', 'idleA', 'tabby', 'amber', None, None), ('orange', 'pounce', 'tabby', 'amber', None, None), ('orange', 'nap', 'tabby', 'amber', None, None), ('orange', 'catch', 'tabby', 'amber', None, None)]
    old_ims = []
    for coat, fr, pat, eye, ears, tail in sp:
        old_ims.append(Image.fromarray(r.compose(coat, fr, t, pat, eye, ears, tail, CF + 'tones.json', ovp), 'RGBA'))
    shutil.rmtree(t)
    new_ims = [pc[0], None, None, None]
    d = prep('polish')
    new_ims = [Image.fromarray(r.compose(c, f, d, p, e, a, tl, CF + 'tones.json', ovp), 'RGBA') for c, f, p, e, a, tl in sp]
    A = Image.new('RGB', (1024, 512), (205, 205, 210))
    for i, (a, b) in enumerate(zip(old_ims, new_ims)):
        for j, im in enumerate((a, b)):
            bgim = Image.new('RGBA', (256, 256), (205, 205, 210, 255)); bgim.alpha_composite(im.resize((256, 256), 0)); A.paste(bgim.convert('RGB'), (i * 256, j * 256))
    A.save(B + 'alignment-check.png')
    # readability strip 1x / 2x / 4x (rich)
    S = Image.new('RGB', (1500, 330), (205, 205, 210)); x = 8
    for sc in (1, 2, 4):
        for p in files(B + 'rich/'):
            im = Image.open(p).convert('RGBA'); w = im.size[0] * sc
            if sc == 4 and im.size[0] == 48: continue
            if x + w > 1500: continue
            bgim = Image.new('RGBA', (w, w), (205, 205, 210, 255)); bgim.alpha_composite(im.resize((w, w), 0)); S.paste(bgim.convert('RGB'), (x, 8 if sc < 4 else 8)); x += w + 6
        x += 20
    S.save(B + 'strip-tmp.png')
