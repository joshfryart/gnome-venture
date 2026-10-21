#!/usr/bin/env python3
"""Restyle every *.svg in SRC_DIR with hearth.restyle -> OUT_DIR and run the style-guide checks.
usage: python3 tests/hearth_all.py SRC_DIR OUT_DIR"""
import os, re, sys, time, traceback
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hearth

FORBID = ['<script', '<style', 'style=', 'filter', 'xlink', 'href', '<image', '<foreignObject', '<use', 'gradient']
ON_RE = re.compile(r'\son[a-z]+\s*=', re.I)

def cap(name):
    if name.startswith(('banner-', 'land-', 'guide-')): return 8192
    return 4096   # creature-/npc- and everything else

def cat(name): return name.split('-')[0]

def vbox(s):
    m = re.search(r'viewBox\s*=\s*"([^"]*)"', s)
    return m.group(1).split() if m else None

def vb_same(a, b):
    if a is None or b is None: return a == b
    try: return [float(x) for x in a] == [float(x) for x in b]
    except Exception: return a == b

def main():
    if len(sys.argv) != 3: sys.exit('usage: hearth_all.py SRC_DIR OUT_DIR')
    src_dir, out_dir = sys.argv[1], sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)
    t0 = time.time()
    errors = []; sizes = {}; orig_total = 0; over = {}; forb = {}; vbchg = []; ids = {}
    files = sorted(f for f in os.listdir(src_dir) if f.endswith('.svg'))
    for f in files:
        name = f[:-4]
        try:
            src = open(os.path.join(src_dir, f), encoding='utf-8').read()
            orig_total += len(src.encode())
            out = hearth.restyle(src, name)
        except Exception as e:
            errors.append((name, '%s: %s' % (type(e).__name__, e))); continue
        with open(os.path.join(out_dir, f), 'w', encoding='utf-8') as fh: fh.write(out)
        n = len(out.encode()); sizes[name] = n
        if n > cap(name): over.setdefault(cat(name), []).append((name, n))
        bad = [s for s in FORBID if s in out]
        if ON_RE.search(out): bad.append('on*=')
        if bad: forb[name] = bad
        if not vb_same(vbox(src), vbox(out)): vbchg.append(name)
        for i in re.findall(r'<clipPath[^>]*\bid="([^"]+)"', out): ids.setdefault(i, []).append(name)
    dup = {i: v for i, v in ids.items() if len(v) > 1}
    print('files %d  ok %d  time %.1fs' % (len(files), len(sizes), time.time() - t0))
    print('errors: %d' % len(errors))
    for n, e in errors[:40]: print('  ', n, e)
    print('over hard cap: %d' % sum(len(v) for v in over.values()))
    for c, v in sorted(over.items()):
        print('  [%s] %d: %s' % (c, len(v), ', '.join('%s(%d)' % x for x in v[:8])))
    print('dup clipPath ids: %d' % len(dup))
    for i, v in list(dup.items())[:20]: print('  ', i, v)
    print('forbidden strings: %d files' % len(forb))
    for n, b in list(forb.items())[:40]: print('  ', n, b)
    print('viewBox changed: %d %s' % (len(vbchg), vbchg[:20]))
    if sizes:
        tot = sum(sizes.values()); mx = max(sizes, key=sizes.get)
        print('avg %.0fB  max %dB (%s)  total %d vs original %d B (%.0f%%)' % (tot / len(sizes), sizes[mx], mx, tot, orig_total, 100.0 * tot / max(orig_total, 1)))
    bad = errors or over or dup or forb or vbchg
    sys.exit(1 if bad else 0)

if __name__ == '__main__': main()
