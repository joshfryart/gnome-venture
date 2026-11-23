#!/usr/bin/env python3
"""2.7.55 piece effects: builds the production animation engine and its data.
  python3 tools/build_pfanim.py            writes game/assets/pfanim.js and game/assets/pfanim-data.json
  python3 tools/build_pfanim.py --check    compares only (exit 1 when either file is not what the build gives)
Inputs (all read-only):
  tools/pfanim_part.js                        the engine (overlay canvas, clock, hooks, look-up, multi-loop perimeter)
  claude/pf-anim/small-anim.template.html     the approved draw code (place state, sound lines, 16 families, themed glyphs / motions / extras / carriers, personalities);
                                              bundled from `function hexmix(` up to the gallery, minus its single-loop perimeter (the engine has its own)
  claude/pf-anim/motifs/*.js                  motif modules (PFA.motif / PFA.glyph / PFA.motion), bundled in file-name order
  claude/pf-anim/<size>-creatures.json        small / medium / large / boss as far as they exist (built by claude/pf-anim/build_small_anim.py <size>)
  claude/pf-anim/stat-pieces.json             the 24 stat pieces: motif catalogue + piece -> motif and colour (data key "sp")
  claude/pf-anim/themes.json                  the motif catalogue (motifs used by no size are left out)
  game/includes/data/pf_pieces.txt, wear_items_pieces.txt, pf_region_pieces.txt, pf_class_base.txt: the player's pieces and the creatures' shared pieces get a family
    (the 15-row pilot table of claude/proposal-piece-animations.md for the base pieces, else the TEMPLATE.md section 3 rules).
When medium / large / boss data (or a new motif module) lands: rebuild that size with build_small_anim.py, then run this script again (and tests/pfanim.sh).
Deterministic: same input = same output. The JSON is compact (short keys, one theme per creature, motif refs by index)."""
import glob, hashlib, importlib.util, json, math, os, re, sys
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AN = os.path.join(R, 'claude', 'pf-anim')
OUT_JS, OUT_JSON = os.path.join(R, 'game', 'assets', 'pfanim.js'), os.path.join(R, 'game', 'assets', 'pfanim-data.json')
SIZES = ('small', 'medium', 'large', 'boss')

spec = importlib.util.spec_from_file_location('pfa_build', os.path.join(AN, 'build_small_anim.py')); BS = importlib.util.module_from_spec(spec); spec.loader.exec_module(BS)
FAMILIES = BS.FAMILIES; FNAMES = list(FAMILIES); FIX = {f: i for i, f in enumerate(FNAMES)}

def die(msg): sys.exit('build_pfanim: ' + msg)
def jsround(x): return math.floor(x + .5)
def jsmix(a, b, t):   # the engine's hexmix (Math.round = half up), so a colour the engine derives is checked against the source exactly
    A = [int(a[i:i+2], 16) for i in (1, 3, 5)]; B = [int(b[i:i+2], 16) for i in (1, 3, 5)]
    return '#' + ''.join('%02x' % jsround(A[i] * (1 - t) + B[i] * t) for i in range(3))

# ---- families: [name, player tone, place sound, creature tone (base: any land), creature dark]
def fam_table():
    out = []
    for f in FNAMES:
        col, acc, base, why = BS.palette({'art': '', 'name': '', 'lands': 'any'}, f)
        out.append([f, FAMILIES[f]['tone'], FAMILIES[f]['snd'], col, acc])
    return out

# ---- the player's pieces (and the creatures' shared region / class pieces): name -> [family index, colour or 0, sound or 0]
PILOT = {   # claude/proposal-piece-animations.md, pilot table (the base pieces; veil and calm are not in the closed list of 16: ripple)
 'Swing': ('slash', '#fff3c8', 'click'), 'Dodge': ('shield', '#a9d6ea', 'tink'), 'Rest': ('mend', '#5f9a4a', 'pop'), 'Charm': ('sparkle', '#f6b8cf', 'tink'),
 'Snack': ('sparkle', '#c9a96e', 'pop'), 'Hide': ('ripple', '#c3b2ea', 'thud'), 'Breather': ('mend', '#5f9a4a', 'pop'), 'Jab': ('shock', '#ffe27a', 'click'),
 'Pierce': ('thrust', '#ffffff', 'click'), 'Brace': ('shield', '#4f7fa8', 'thud'), 'Soothe': ('ripple', '#3f8fb0', 'tink'),
 'Swarm': ('buzz', '#9bd05a', 'zig'), 'Honeydew': ('mend', '#e8a317', 'pop'), 'Cloud Up': ('puff', '#dfe6ee', 'pop'), 'Sap Sip': ('drip', '#7fd35a', 'pop')}
TAGF = {'heavy': 'bash', 'hum': 'sparkle', 'lull': 'ripple', 'snack': 'sparkle', 'mend': 'mend'}
def player_fam(t, tag, n):
    if tag in TAGF: return TAGF[tag]
    if t == 'charm': return 'sparkle'
    if t == 'soothe': return 'ripple'
    if t == 'item': return 'sparkle'
    tg = tag if tag in ('quick', 'evade', 'hold', 'thorns', 'poison', 'pierce', 'trip', 'bash', 'heal') else ''
    f, ok, why = BS.decide({'ab': [], 'class': 'Player', 'family': ''}, {'t': t, 'tag': tg, 'n': n})
    return f
def rows(path):
    for ln in open(path, encoding='utf-8'):
        ln = ln.rstrip('\n')
        if not ln.strip() or ln.startswith('#') or ln.startswith('='): continue
        yield ln.split('|')
def shared_pieces():
    pp = {}
    def put(n, f, col=0, snd=0):
        if n in pp: return
        if f not in FIX: die('family %s for %s is not one of the 16' % (f, n))
        r = [FIX[f]]
        if col or snd: r += [col or 0]
        if snd and snd != FAMILIES[f]['snd']: r = [FIX[f], col or 0, snd]
        pp[n] = r
    for n, (f, col, snd) in sorted(PILOT.items()): put(n, f, col, snd)
    D = os.path.join(R, 'game', 'includes', 'data')
    for c in rows(os.path.join(D, 'pf_pieces.txt')): put(c[1], player_fam(c[4], c[7] if c[7] != '-' else '', c[1]))
    for c in rows(os.path.join(D, 'wear_items_pieces.txt')): put(c[1], player_fam(c[4], c[7] if c[7] != '-' else '', c[1]))
    for c in rows(os.path.join(D, 'pf_region_pieces.txt')): put(c[2], player_fam(c[3], c[6] if c[6] != '-' else '', c[2]))
    for c in rows(os.path.join(D, 'pf_class_base.txt')):
        if len(c) >= 6: put(c[1], player_fam(c[2], c[5] if c[5] != '-' else '', c[1]))
    return pp

# ---- creatures
def load_sizes():
    got = {}
    for s in SIZES:
        f = os.path.join(AN, ('%s-creatures.json' % s))
        if os.path.exists(f): got[s] = json.load(open(f, encoding='utf-8'))
    if 'small' not in got: die('claude/pf-anim/small-creatures.json is missing')
    return got

def build_data(sizes, MOT):
    mot_names = sorted({e['th']['motif'] for J in sizes.values() for e in J['entries'] if 'th' in e} | {c['theme']['motif'] for J in sizes.values() for c in J['creatures'] if 'theme' in c})
    for m in mot_names:
        if m not in MOT: die('motif %s is used but not in any catalogue' % m)
    MI = {m: i for i, m in enumerate(mot_names)}
    PE = {}
    for J in sizes.values():
        for k, v in J['personalities'].items(): PE[k] = [v['rf'], v['ri']]
    cr, clash, checked = {}, [], 0
    for size in SIZES:
        if size not in sizes: continue
        J = sizes[size]; by = {}
        for e in J['entries']: by.setdefault(e['creature'], []).append(e)
        for c in J['creatures']:
            slug = c['slug']
            if slug in cr: die('creature %s is in two sizes' % slug)
            es = by.get(slug, []); T = c.get('theme')
            acc0 = BS.palette(c, 'slash')[1]
            fc = {}
            for e in es:
                fi = FIX[e['family']]
                if str(fi) not in fc:
                    fc[str(fi)] = BS.palette(c, e['family'])[0]
            rec = {'b': acc0, 'fc': fc, 'p': {}}
            if T:
                rec.update({'a': T['palette'], 'z': T['place_personality'], 's': T['snd_set'], 'sp': T['spd'], 'm': MI[T['motif']]})
                if T.get('x') and T['x'] != MOT[T['motif']]['x']: rec['x'] = T['x']
            for e in sorted(es, key=lambda e: (0 if e['layer'] == 'unique' else 1, e['piece_key'])):
                n = e['name']; fi = FIX[e['family']]; o = {}
                if e['col'] != fc[str(fi)]: o['gc'] = e['col']
                if e['accent'] != acc0: o['ga'] = e['accent']
                tag = '' if e['tag'] == '-' else e['tag']
                snd0 = 'thud' if tag == 'hold' and FAMILIES[e['family']]['snd'] == 'tink' else FAMILIES[e['family']]['snd']
                if e['place']['snd'] != snd0: o['gs'] = e['place']['snd']
                r = [fi, e['place']['lift']]
                th = e.get('th')
                if th and T:
                    M = MOT[th['motif']]
                    lay0 = BS.layout_of({'t': e['type'], 'tag': tag})
                    if th['mp']['lay'] != lay0: o['l'] = th['mp']['lay']
                    spd0 = jsround(T['spd'] * (1.3 if tag == 'quick' else .8 if tag == 'hold' else 1) * 100) / 100
                    if abs(th['mp']['spd'] - spd0) > 1e-9: o['s'] = th['mp']['spd']
                    x0 = T['x'] if th['motif'] == T['motif'] and T.get('x') else M['x']
                    if th['mp']['x'] != x0: o['x'] = th['mp']['x']
                    if th['carrier'] != M['car']: o['car'] = th['carrier']
                    if th['col'] != T['palette'][0]: o['c'] = th['col']
                    hi0 = T['palette'][2] if 'c' not in o else jsmix(th['col'], '#ffffff', .55)
                    if th['hi'] != hi0: o['h'] = th['hi']
                    if th['acc'] != T['palette'][1]: die('%s/%s: theme accent differs from the palette' % (slug, n))
                    snd = T['snd_set'][0 if e['type'] in ('hurt', 'trick') else 1]
                    if th['snd'] != snd: die('%s/%s: theme sound differs from the set' % (slug, n))
                    r += [MI[th['motif']], th['mp']['z']]; checked += 1
                elif o: r += [-1, 0]
                if o: r.append(o)
                if n in rec['p']:
                    if rec['p'][n] != r: clash.append('%s/%s' % (slug, n))
                    continue
                rec['p'][n] = r
            cr[slug] = rec
    mot = [[m, MOT[m]['g'], MOT[m]['mo'], MOT[m]['x'], MOT[m]['car'], MOT[m]['gap']] for m in mot_names]
    SPJ = json.load(open(os.path.join(AN, 'stat-pieces.json'), encoding='utf-8'))   # stat pieces (pfight_statpieces): themed look for the gnome's own pieces
    sp = {}
    for m, v in SPJ['motifs'].items():
        if m in MI: die('stat motif %s is also a creature motif' % m)
        MI[m] = len(mot); mot.append([m, v['g'], v['mo'], v['x'], v['car'], v['gap']])
    for n, v in SPJ['pieces'].items():
        if v['motif'] not in MI: die('stat piece %s: unknown motif %s' % (n, v['motif']))
        sp[n] = [MI[v['motif']], v['col']]
    return {'v': 1, 'm': mot, 'sp': dict(sorted(sp.items())), 'pe': dict(sorted(PE.items())), 'cr': dict(sorted(cr.items())), 'pp': dict(sorted(shared_pieces().items()))}, clash, checked

# ---- code
def template_code():
    t = open(os.path.join(AN, 'small-anim.template.html'), encoding='utf-8').read()
    a, b = t.find('function hexmix('), t.find('/* ---------- gallery')
    p0, p1 = t.find('/* ---------- perimeter of the union'), t.find('/* ---------- layer 1: place')
    if min(a, b, p0, p1) < 0 or not (a < p0 < p1 < b): die('small-anim.template.html markers moved (hexmix, perimeter, layer 1, gallery)')
    code = t[a:p0] + t[p1:b]
    for need in ('function placeState(', 'function soundLines(', 'function ownFx(', 'function carrier(', 'function themedOwn(', 'function themedCar(', 'function persFx(', 'function timing('):
        if need not in code: die('template lost ' + need)
    return code

def modules():
    files = sorted(glob.glob(os.path.join(os.environ.get('PFA_MOTIFS_DIR') or os.path.join(AN, 'motifs'), '*.js')))
    src, names, gl, mo = [], set(), set(), set()
    for f in files:
        s = open(f, encoding='utf-8').read()
        for n in re.findall(r"PFA\.motif\(\s*'([^']+)'", s):
            if n in names: die('motif %s is registered twice (%s)' % (n, os.path.basename(f)))
            names.add(n)
        gl |= set(re.findall(r"PFA\.glyph\(\s*'([^']+)'", s)); mo |= set(re.findall(r"PFA\.motion\(\s*'([^']+)'", s))
        src.append('/* ---- motifs/%s ---- */\n%s\n' % (os.path.basename(f), s))
    return ''.join(src), names, gl, mo

def main():
    sizes = load_sizes()
    MOT = dict(json.load(open(os.path.join(AN, 'themes.json'), encoding='utf-8'))['motifs'])
    for J in sizes.values():
        for k, v in J['motifs'].items():
            if k in MOT and any(MOT[k].get(f) != v.get(f) for f in ('g', 'mo', 'x', 'car', 'gap')): die('motif %s differs between catalogues' % k)
            MOT[k] = v
    data, clash, checked = build_data(sizes, MOT)
    code = template_code(); msrc, mnames, xg, xm = modules()
    need = set()   # every id the data uses must have page code (a case in the template draw code) or a module
    for r in data['m']: need |= {r[1], r[2], r[3], r[4]}
    for c in data['cr'].values():
        if 'z' in c: need |= {c['z']} | set(c['s']) | {c.get('x', '-')}
        for r in c['p'].values():
            if len(r) > 4: need |= {r[4].get('l', 'hold'), r[4].get('x', '-'), r[4].get('car', 'train')}
    need -= {'-', 'none', 'custom'}
    miss = sorted(i for i in need if ("case '%s'" % i) not in code and i not in xg and i not in xm and not (i in mnames))
    dyn = set(re.findall(r"PFA\.(?:glyph|motion|motif)\(\s*'([A-Za-z0-9]+-)' *\+", msrc))   # modules that register ids in a loop ('L08-' + name)
    miss = [i for i in miss if not any(i.startswith(d) for d in dyn)]
    if miss: die('ids with no draw code: ' + ', '.join(miss))
    fams = json.dumps(fam_table(), separators=(',', ':'))
    js = open(os.path.join(R, 'tools', 'pfanim_part.js'), encoding='utf-8').read()
    for k in ('/*__DRAW__*/', '/*__MOTIFS__*/', '/*__FAMS__*/null', '/*__VER__*/'):
        if js.count(k) != 1: die('tools/pfanim_part.js lost the placeholder ' + k)
    js = js.replace('/*__DRAW__*/', code).replace('/*__MOTIFS__*/', msrc).replace('/*__FAMS__*/null', fams)
    jtxt = json.dumps(data, separators=(',', ':'), ensure_ascii=False, sort_keys=False)
    ver = hashlib.sha1((js + jtxt).encode('utf-8')).hexdigest()[:10]
    js = js.replace('/*__VER__*/', ver)
    if '--check' in sys.argv:
        bad = [p for p, s in ((OUT_JS, js), (OUT_JSON, jtxt)) if not os.path.exists(p) or open(p, encoding='utf-8').read() != s]
        if bad: sys.exit('build_pfanim: not what the build gives (run python3 tools/build_pfanim.py): ' + ', '.join(os.path.relpath(p, R) for p in bad))
        print('build_pfanim: up to date'); return
    open(OUT_JS, 'w', encoding='utf-8').write(js); open(OUT_JSON, 'w', encoding='utf-8').write(jtxt)
    nc = len(data['cr']); npc = sum(len(c['p']) for c in data['cr'].values()); nth = sum(1 for c in data['cr'].values() if 'a' in c)
    print('build_pfanim: sizes %s; %d creatures (%d themed), %d creature pieces (%d themed), %d shared/player pieces, %d motifs, %d motif modules; pfanim-data.json %d bytes, pfanim.js %d bytes; ver %s'
          % ('+'.join(s for s in SIZES if s in sizes), nc, nth, npc, checked, len(data['pp']), len(data['m']), len(mnames), len(jtxt.encode('utf-8')), len(js.encode('utf-8')), ver))
    if clash: print('  same piece name, different look (first kept): ' + ', '.join(clash))
if __name__ == '__main__': main()
