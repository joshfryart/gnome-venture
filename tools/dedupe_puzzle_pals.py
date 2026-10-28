#!/usr/bin/env python3
"""Find repeats among Puzzle Pals: game/includes/data/puzzle_pals.txt plus any draft files.
Usage: tools/dedupe_puzzle_pals.py [DRAFT.txt ...] [--npcs NPC_NAMES.txt] [--epithet-max N] [--overlap 0.5]
  DRAFT.txt      extra files in the 14-column puzzle_pals.txt format (a row whose key is already shipped is the same row, not a repeat)
  --npcs FILE    one NPC name per line (or name|...): a pal may not share a name, or a full first name + epithet, with an NPC
  --epithet-max  most pals that may end in the same last word (default 2)
  --overlap      near-duplicate idea threshold: shared share of blurb+name keywords (default 0.5, at least 3 shared words)
Flags: same name (ignoring case/accents/punctuation) or very similar name; the same first word AND epithet; an epithet (last word of the name) on more than N pals;
near-duplicate ideas (blurbs/names sharing most of their keywords, or the same rare whimsy shape in two pictures); a name equal to an NPC name. Exit 1 if any."""
import os, re, sys, difflib, itertools, unicodedata
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
def opt(n, d=''):
    return sys.argv[sys.argv.index(n) + 1] if n in sys.argv and sys.argv.index(n) + 1 < len(sys.argv) else d
args = [a for i, a in enumerate(sys.argv[1:], 1) if not a.startswith('--') and not sys.argv[i - 1].startswith('--')]
EMAX = int(opt('--epithet-max', '2')); OVER = float(opt('--overlap', '0.5'))
STOP = set('that this with from have into their there they them than then when what which while where over under about after before always never very just more most some only also been being were will would could should does did and the for its it’s its not but all any one two each every again still even like makes make made stays keeps keep gets get goes going been can cant wont'.split())
def load(path, tag):
    out = []
    for n, l in enumerate(open(path, encoding='utf-8'), 1):
        l = l.rstrip('\n')
        c = l.split('|')
        if l.strip() and not l.startswith('#') and len(c) == 14: out.append((tag, c))
    return out
rows = load(os.path.join(DATA, 'puzzle_pals.txt'), 'puzzle_pals.txt')
for d in args: rows += load(d, os.path.basename(d))
seen, uniq = {}, []
for t, c in rows:
    if c[1] in seen: continue
    seen[c[1]] = 1; uniq.append((t, c))
rows = uniq
def norm(s): return re.sub(r'[^a-z ]', '', unicodedata.normalize('NFKD', s.lower().replace('’', '')).encode('ascii', 'ignore').decode()).strip()
def stem(w): return re.sub(r'(ing|ies|es|ed|s|y)$', '', w) if len(w) > 4 else w
def kw(c): return {stem(w) for w in re.findall(r'[a-z]{4,}', norm(c[13]) + ' ' + norm(c[2])) if w not in STOP}
def epithet(c): return (norm(c[2]).split() or [''])[-1]
def first(c): return (norm(c[2]).split() or [''])[0]
npcs = set()
if opt('--npcs'):
    for l in open(opt('--npcs'), encoding='utf-8'):
        if l.strip() and not l.startswith('#'): npcs.add(norm(l.split('|')[0]))
flags = []
def lab(t, c): return '%s (%s) [%s]' % (c[1], t, c[2])
for (ta, a), (tb, b) in itertools.combinations(rows, 2):
    why = []
    na, nb = norm(a[2]), norm(b[2])
    if na == nb: why.append('same name')
    elif difflib.SequenceMatcher(None, na, nb).ratio() >= 0.85: why.append('very similar name')
    elif first(a) == first(b) and epithet(a) == epithet(b): why.append('same first word + epithet')
    ka, kb = kw(a), kw(b)
    sh = ka & kb
    if len(sh) >= 3 and len(sh) / max(1, min(len(ka), len(kb))) >= OVER: why.append('near-duplicate idea (shared: %s)' % ', '.join(sorted(sh)))
    if a[3] == 'rare' and b[3] == 'rare' and a[10] == b[10] and a[0] != b[0]: why.append('same whimsy shape %s' % a[10])
    if why: flags.append('%s ~ %s: %s' % (lab(ta, a), lab(tb, b), '; '.join(why)))
by = {}
for t, c in rows: by.setdefault(epithet(c), []).append(lab(t, c))
for e, ls in sorted(by.items()):
    if e and len(ls) > EMAX: flags.append('epithet %r on %d pals (max %d): %s' % (e, len(ls), EMAX, '; '.join(ls)))
for t, c in rows:
    if norm(c[2]) in npcs: flags.append('%s: name equals an NPC' % lab(t, c))
print('%d pals compared, %d flagged' % (len(rows), len(flags)))
for f in flags: print('  ' + f)
sys.exit(1 if flags else 0)
