#!/usr/bin/env python3
"""Render each svg in OUT_DIR at 64px on transparent bg; flag halo touching the 1px frame and blank/tiny icons (<3% opaque).
usage: python3 tests/hearth_edge.py OUT_DIR   (cairosvg -> rsvg-convert -> inkscape -> headless chromium via playwright)"""
import io, os, shutil, subprocess, sys
S = 64; ALPHA = 128   # alpha >= 128/255 counts as opaque (lower values flag 1-2 faint anti-aliased pixels)
import re
EXEMPT = re.compile(r"^(banner|land|guide|tile)-|-(hedge|border)-(straight|corner|tee|cross|end|gate)$|^(picket|wattle)-fence-")   # full-bleed scenes, tiles, seamless fences/hedges touch the frame by design

def stats(alpha):   # alpha: 2D list/array S x S
    import numpy as np
    a = np.asarray(alpha).reshape(S, S) >= ALPHA
    frame = a[0, :].any() or a[-1, :].any() or a[:, 0].any() or a[:, -1].any()
    return bool(frame), float(a.mean())

def render_cli(files):
    import numpy as np
    from PIL import Image
    res = {}
    for f in files:
        if shutil.which('rsvg-convert'): cmd = ['rsvg-convert', '-w', str(S), '-h', str(S), f]
        else: cmd = ['inkscape', '-w', str(S), '-h', str(S), '--export-type=png', '--export-filename=-', f]
        png = subprocess.run(cmd, capture_output=True, check=True).stdout
        res[f] = stats(np.array(Image.open(io.BytesIO(png)).convert('RGBA'))[:, :, 3])
    return res

def render_cairosvg(files):
    import cairosvg, numpy as np
    from PIL import Image
    res = {}
    for f in files:
        png = cairosvg.svg2png(url=f, output_width=S, output_height=S)
        res[f] = stats(np.array(Image.open(io.BytesIO(png)).convert('RGBA'))[:, :, 3])
    return res

JS = """async (items) => {
  const out = [];
  for (const [name, svg] of items) {
    const img = new Image();
    img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
    try { await img.decode(); } catch (e) { out.push([name, null]); continue; }
    const c = document.createElement('canvas'); c.width = c.height = %d;
    const x = c.getContext('2d'); x.clearRect(0, 0, %d, %d); x.drawImage(img, 0, 0, %d, %d);
    const d = x.getImageData(0, 0, %d, %d).data; let op = 0, fr = false;
    for (let i = 0; i < %d; i++) for (let j = 0; j < %d; j++) {
      if (d[(i * %d + j) * 4 + 3] >= %d) { op++; if (i == 0 || j == 0 || i == %d || j == %d) fr = true; }
    }
    out.push([name, [fr, op / %d]]);
  }
  return out;
}""" % (S, S, S, S, S, S, S, S, S, S, ALPHA, S - 1, S - 1, S * S)

def render_chromium(files):
    from playwright.sync_api import sync_playwright
    res = {}
    with sync_playwright() as p:
        b = p.chromium.launch(); pg = b.new_page(); pg.set_content('<html><body></body></html>')
        for i in range(0, len(files), 100):
            items = [[f, open(f, encoding='utf-8').read()] for f in files[i:i + 100]]
            for name, r in pg.evaluate(JS, items): res[name] = tuple(r) if r else None
        b.close()
    return res

def main():
    if len(sys.argv) != 2: sys.exit('usage: hearth_edge.py OUT_DIR')
    d = sys.argv[1]
    files = [os.path.join(d, f) for f in sorted(os.listdir(d)) if f.endswith('.svg')]
    res = None
    for fn, ok in ((render_cairosvg, lambda: __import__('cairosvg')),
                   (render_cli, lambda: shutil.which('rsvg-convert') or shutil.which('inkscape') or (_ for _ in ()).throw(ImportError())),
                   (render_chromium, lambda: __import__('playwright'))):
        try: ok()
        except Exception: continue
        res = fn(files); print('renderer:', fn.__name__); break
    if res is None: sys.exit('no renderer (cairosvg, rsvg-convert, inkscape, playwright)')
    clipped = []; blank = []; fail = []
    for f in files:
        n = os.path.basename(f)[:-4]; r = res.get(f)
        if r is None: fail.append(n); continue
        fr, cov = r
        if fr and not EXEMPT.search(n): clipped.append(n)
        if cov < 0.03: blank.append('%s(%.1f%%)' % (n, cov * 100))
    print('rendered %d  halo touches frame: %d  blank/tiny: %d  render fail: %d' % (len(files), len(clipped), len(blank), len(fail)))
    print('frame-touch:', ' '.join(clipped[:200]))
    print('blank/tiny:', ' '.join(blank))
    print('render-fail:', ' '.join(fail))
    sys.exit(1 if clipped or blank or fail else 0)

if __name__ == '__main__': main()
