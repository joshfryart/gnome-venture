#!/usr/bin/env python3
"""2.7.00 camp spots: one per Trail route (data/trail_camps.json: {route: {sec, x, y}}). The game draws the camp tile itself (no re-bake of ground pictures).
Picks a clearing on the middle stretch: reachable floor, far from the stretch's entry and exit, off finds / fights / gates / water / sprites, with open floor around it.
  python3 tools/gen_trail_camps.py [--check]      (--check compares with the file in the game and exits 1 on a difference)"""
import json, glob, os, sys, collections
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(R, 'game/includes/data/trail_camps.json')
FLOOR = set('.,')
def pick(sec):
    rows = sec['rows']; h = len(rows); w = len(rows[0])
    ent = sec.get('entry'); S = None; N9 = None
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c == 'S': S = (x, y)
            if c == '9': N9 = (x, y)
    if S is None and ent: S = (ent['x'], ent['y'])
    if S is None: return None
    block = set()
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c in 'EF': block.add((x, y))
    for mb in sec.get('extra_minibosses') or []: block.add((mb['x'], mb['y']))
    for g in sec.get('gates') or []:
        for t in g.get('tiles') or []: block.add((t[0], t[1]))
    wet = sec.get('wet') or []
    for y, r in enumerate(wet):
        for x, c in enumerate(r):
            if c == '1': block.add((x, y))
    big = []
    for o in sec.get('objs') or []:
        block.add((o[0], o[1]))
        if str(o[2]).startswith('lm-'): big.append((o[0], o[1]))
    # reachable floor from the entry
    dist = {S: 0}; q = collections.deque([S])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in dist and rows[ny][nx] in FLOOR | set('S9EF'):
                dist[(nx, ny)] = dist[(x, y)] + 1; q.append((nx, ny))
    if N9 is not None and N9 not in dist: return None
    cand = []
    for (x, y), d in dist.items():
        if rows[y][x] not in FLOOR or (x, y) in block: continue
        if abs(x - S[0]) + abs(y - S[1]) < 6: continue
        if N9 is not None and abs(x - N9[0]) + abs(y - N9[1]) < 6: continue
        if any(abs(x - bx) + abs(y - by) < 3 for bx, by in block if (bx, by) != (x, y) and rows[by][bx] in 'EF'): continue
        if any(abs(x - bx) <= 2 and abs(y - by) <= 2 for bx, by in big): continue
        n = sum(1 for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx or dy) and 0 <= x + dx < w and 0 <= y + dy < h and rows[y + dy][x + dx] in FLOOR | set('S9') and (x + dx, y + dy) not in block)
        if n < 6: continue
        cand.append((abs(d - max(dist.values()) / 2), -n, y, x))
    if not cand: return None
    _, _, y, x = min(cand)
    return x, y
def main():
    out = {}; miss = []
    for f in sorted(glob.glob(os.path.join(R, 'game/includes/data/trail_maps/*_30x18.json'))):
        for rid, r in json.load(open(f))['routes'].items():
            secs = r['sections']; n = len(secs)
            order = sorted(range(n), key=lambda i: (abs(i - (n - 1) / 2), i))   # the middle stretch first, then the ones next to it
            for i in order:
                p = pick(secs[i])
                if p: out[rid] = {'sec': i, 'x': p[0], 'y': p[1]}; break
            else: miss.append(rid)
    out = {k: out[k] for k in sorted(out, key=int)}
    txt = json.dumps({'v': 1, 'camps': out}, separators=(',', ':')) + '\n'
    if miss: print('NO CAMP SPOT:', miss, file=sys.stderr)
    if '--check' in sys.argv: sys.exit(0 if (os.path.isfile(OUT) and open(OUT).read() == txt) else 1)
    open(OUT, 'w').write(txt); print(len(out), 'camps,', len(miss), 'routes without')
main()
