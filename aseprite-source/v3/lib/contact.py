#!/usr/bin/env python3
"""Contact sheet: python3 contact.py out.html a.png b.png ...   |   contact.py --compare out.html orig.png new.png [orig2 new2 ...]"""
import sys, os, base64, html
from PIL import Image

def b64(p):
    return "data:image/png;base64," + base64.b64encode(open(p, "rb").read()).decode()

def views(p):
    w, h = Image.open(p).size
    big = max(w, h)
    sc = 4 if big <= 80 else 2 if big <= 300 else 1
    v = [("100%", 1)]
    if sc > 1: v.append(("x%d" % sc, sc))
    v.append(("50%", 0.5))
    return w, h, v

def cell(p, bg):
    w, h, v = views(p)
    s = '<div class="row" style="background:%s">' % bg
    for lab, k in v:
        s += '<figure><img src="%s" width="%d" height="%d"><figcaption>%s</figcaption></figure>' % (b64(p), max(1, round(w * k)), max(1, round(h * k)), lab)
    return s + "</div>"

def item(p, extra=""):
    w, h = Image.open(p).size
    return '<section><h3>%s <small>%dx%d</small>%s</h3>%s%s</section>' % (html.escape(os.path.basename(p)), w, h, extra, cell(p, "#808080"), cell(p, "#1c1722"))

CSS = """body{font:13px system-ui,sans-serif;background:#2a2630;color:#eee;margin:16px}
section{display:inline-block;vertical-align:top;margin:0 16px 16px 0;border:1px solid #555;padding:8px;background:#3a3542}
.pair{display:flex;gap:12px}h3{margin:0 0 6px;font-size:13px}small{color:#aaa}
.row{padding:8px;margin-bottom:6px;display:flex;gap:12px;align-items:flex-start}
figure{margin:0}figcaption{font-size:10px;color:#ddd;text-align:center}
img{image-rendering:pixelated;display:block}"""

def main(a):
    cmp_ = False
    if a and a[0] == "--compare": cmp_, a = True, a[1:]
    if len(a) < 2: sys.exit(__doc__)
    out, files = a[0], a[1:]
    body = ""
    if cmp_:
        if len(files) % 2: sys.exit("--compare needs pairs")
        for i in range(0, len(files), 2):
            o, n = files[i], files[i + 1]
            body += '<div class="pair">%s%s</div>' % (item(o, " (orig)"), item(n, " (new)"))
    else:
        body = "".join(item(f) for f in files)
    open(out, "w").write("<!doctype html><meta charset=utf-8><title>contact</title><style>%s</style>%s" % (CSS, body))
    print("wrote", out)

main(sys.argv[1:])
