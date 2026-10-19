#!/usr/bin/env python3
"""v1.6.5: rewrite every @media (prefers-color-scheme: dark) { ... } block in the game CSS into rules scoped to :root[data-theme="dark"],
so the data-theme attribute (not the phone) decides. Re-runnable: a file with no such blocks is left alone.
Usage: python3 tests/theme_css.py [game/assets/style.css ...]   (default: every css in game/assets)"""
import re, sys, glob, os

D = ':root[data-theme="dark"]'
MEDIA = re.compile(r'@media\s*\(\s*prefers-color-scheme\s*:\s*dark\s*\)\s*\{')

def match_brace(s, i):
    """s[i] == '{' -> index of its closing brace (comments skipped)."""
    depth = 0
    while i < len(s):
        c = s[i]
        if s.startswith('/*', i):
            i = s.index('*/', i) + 2
            continue
        if c == '{': depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0: return i
        i += 1
    raise ValueError('unbalanced braces')

def split_sel(sel):
    out, depth, cur = [], 0, ''
    for c in sel:
        if c in '([': depth += 1
        if c in ')]': depth -= 1
        if c == ',' and depth == 0:
            out.append(cur); cur = ''
        else: cur += c
    out.append(cur)
    return [x.strip() for x in out if x.strip()]

def scope(sel):
    sel = sel.strip()
    sel = sel.replace(':root:not([data-theme="light"])', D)
    if sel.startswith(D): return sel
    if sel.startswith(':root'): return D + sel[5:]
    return D + ' ' + sel

def convert(inner):
    """rules inside a dark media block -> list of rule strings."""
    out, i, n = [], 0, len(inner)
    while i < n:
        m = re.compile(r'\s*').match(inner, i); i = m.end()
        if i >= n: break
        if inner.startswith('/*', i):
            j = inner.index('*/', i) + 2
            out.append(inner[i:j]); i = j; continue
        b = inner.index('{', i)
        head = inner[i:b].strip()
        e = match_brace(inner, b)
        body = inner[b + 1:e]
        i = e + 1
        if head.startswith('@media'):
            out.append(head + ' {\n' + '\n'.join('  ' + r for r in convert(body)) + '\n}')
        else:
            if head == '.btn.ghost, .btn.alt, .btn.pickbtn':
                # the old dark rule lost to a later .btn.alt rule (same specificity, later wins); scoped it would win and change the look, so keep the old result
                head = '.btn.ghost, .btn.pickbtn'
            sels = ', '.join(scope(s) for s in split_sel(head))
            body = body.strip() if '\n' not in body.strip() else '\n' + '\n'.join(l[2:] if l.startswith('  ') else l for l in body.strip('\n').split('\n')).rstrip() + '\n'
            out.append(sels + ' {' + (' ' + body + ' ' if '\n' not in body else body) + '}')
    return out

def norm(rule):
    return re.sub(r'\s+', ' ', rule).strip()

def run(path):
    s = open(path, encoding='utf-8').read()
    changed = False
    while True:
        m = MEDIA.search(s)
        if not m: break
        b = m.end() - 1
        e = match_brace(s, b)
        rules = convert(s[b + 1:e])
        s = s[:m.start()] + '\n'.join(rules) + s[e + 1:]
        changed = True
    if changed:
        # drop exact duplicates of dark rules (old hand-written twins), keeping the first
        seen, out = set(), []
        for line_block in re.split(r'(?<=\})\n', s):
            key = norm(line_block)
            if key.startswith(D) and key.endswith('}'):
                if key in seen: continue
                seen.add(key)
            out.append(line_block)
        s = '\n'.join(out)
    # color-scheme follows the attribute (form controls, scrollbars)
    if 'color-scheme' not in s and path.endswith('style.css'):
        s = s.replace(':root {\n  --bg:', ':root {\n  color-scheme: light;\n  --bg:', 1)
        s = s.replace(D + ' {\n  --bg:', D + ' {\n  color-scheme: dark;\n  --bg:', 1)
        changed = True
    if s.count('{') != s.count('}'): raise SystemExit(path + ': braces unbalanced')
    if re.search(r'^(<<<<<<<|=======|>>>>>>>)', s, re.M): raise SystemExit(path + ': merge marker')
    if changed: open(path, 'w', encoding='utf-8').write(s)
    print(path, 'rewritten' if changed else 'unchanged')

if __name__ == '__main__':
    files = sys.argv[1:] or glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', '*.css'))
    for f in files: run(f)
