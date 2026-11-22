#!/usr/bin/env python3
"""Builds claude/pf-anim/small-creatures.json (+ coverage.txt) and claude/mockups/pf-small-anim.html for every SMALL creature.
Reads the real data through dump_small.php (pfd_foe_row of every small creature: class, ability, lands, art and the layered deck), applies the
mapping rules of TEMPLATE.md (section 3) and then claude/pf-anim/overrides.json.  Run:  python3 claude/pf-anim/build_small_anim.py   (needs php)
Themed pass: claude/pf-anim/themes.json (hand-authored motif catalogue + one theme per creature) adds a `th` block to every entry and a `theme`
block to every creature (TEMPLATE.md section 9); the 16 families stay as the engine fallback (`family`).
Deterministic: no randomness, same input = same output."""
import colorsys, json, os, re, subprocess, sys, collections
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))

# ---- closed list of families: tone = player effect colour, snd = place sound-line style (visual only), own/carrier = effect ids drawn by the page,
#      heavy = what the creature-heavy variant changes (the page implements every id for both variants)
FAMILIES = {
 'slash':  dict(tone='#fff3c8', snd='click', own='streak',      carrier='comet',      heavy='two thick streaks, 12-square comet'),
 'bite':   dict(tone='#f2e4c0', snd='click', own='jaws',        carrier='chomp-trail',heavy='bigger jaws, snap twice, grit flecks'),
 'thrust': dict(tone='#ffffff', snd='tink',  own='lance',       carrier='lance-line', heavy='thicker lance, short recoil dots'),
 'shock':  dict(tone='#ffe27a', snd='zig',   own='zigzag',      carrier='arc-hop',    heavy='4 jagged lines, bigger spark'),
 'buzz':   dict(tone='#9bd05a', snd='zig',   own='orbit-dots',  carrier='scatter',    heavy='10 dots, wider wobble, dark dots'),
 'bash':   dict(tone='#d9a85a', snd='thud',  own='thump-blocks',carrier='block-roll', heavy='big blocks, dust, edge shakes'),
 'shield': dict(tone='#a9d6ea', snd='tink',  own='dash-scroll', carrier='dash-run',   heavy='thick slow dashes, corner plates (hold = same)'),
 'thorn':  dict(tone='#8fb86a', snd='thud',  own='spikes',      carrier='spike-run',  heavy='longer spikes, dark tips'),
 'puff':   dict(tone='#dfe6ee', snd='pop',   own='puff-bloom',  carrier='puff-trail', heavy='bigger, greyer puffs, slower fade'),
 'mend':   dict(tone='#5f9a4a', snd='pop',   own='plus-rise',   carrier='plus-drift', heavy='fewer, larger pluses, slow rise'),
 'drip':   dict(tone='#7fd35a', snd='pop',   own='drops-fall',  carrier='drop-trail', heavy='fat drops, dark pool, long fall'),
 'web':    dict(tone='#e8e4f0', snd='tink',  own='strands',     carrier='strand-run', heavy='thick strands, big dew drops'),
 'ripple': dict(tone='#a8c8e8', snd='pop',   own='edge-ripple', carrier='ripple-run', heavy='wide ripples, murky tone'),
 'sparkle':dict(tone='#f6d878', snd='tink',  own='stars',       carrier='star-trail', heavy='fewer, harder stars, dim glow'),
 'ember':  dict(tone='#ff9a3c', snd='zig',   own='embers-rise', carrier='ember-trail',heavy='dull red embers, smoke dots'),
 'leaf':   dict(tone='#7fb85a', snd='pop',   own='leaf-spin',   carrier='leaf-drift', heavy='darker leaves, slower spin'),
}
KEY = {  # name keyword -> family (keyword hits are matched on whole-word starts, lower-case)
 'bite':   r'\b(bite|nip|pincer|mandible|fang|jaw|clamp|chomp|pinch|snap|gulp|beak|tusk|gnaw|chew|munch|nibble)',
 'ember':  r'\b(ember|fire|flame|burn|burning|scorch|ash|cinder|lava|smoke|boiling|crackle|sparkfall|blaze|heat)',
 'web':    r'\b(web|silk|snare|thread|tangle|net|sticky|stitch|cobweb|noose)',
 'sparkle':r'\b(glow|lamp|shimmer|sheen|glitter|dew|sparkle|wink|glamour|flicker|twinkle|lure)',
 'leaf':   r'\b(leaf|leaves|vine|petal|frond|fern|spore|moss|bloom|bark|sprig|root|bramble)',
 'ripple': r'\b(water|wave|tide|surf|ripple|splash|skim|float|current|pond|pool|brine|bubble|croak|drift|swirl)',
}
HURT_KEYS = ('bite', 'ember', 'web', 'leaf')           # keyword families allowed on a hurt piece with no mechanical tag
SOFT_KEYS = ('ember', 'web', 'sparkle', 'leaf', 'ripple')  # allowed on trick, and on guard evade / plain guard
SWARM_RX = r'\b(swarm|buzz|wing|wings|flutter|whine|hum|fly|flit|mob|gnat|hornet|flicker|swirl|cloud|scatter|burst|mosquito|sting)'
SPIDER = ('orb-spider',)
THEME = {'grassland': '#8fb04a', 'coast': '#5fa3b5', 'wetland': '#4f9a8a', 'forest': '#3f7a45', 'desert': '#c9964a', 'island': '#3fb0a0',
         'mountain': '#7f8c9a', 'rainforest': '#2f9a55', 'tundra': '#a9c8dc', 'any': '#b0a080'}
WORD = [(r'\b(red|crimson|scarlet|rust)', '#b8442c'), (r'\b(orange)', '#d9822b'), (r'\b(yellow|golden|gold|amber)', '#d9b02a'),
        (r'\b(green|olive|bottle-green|moss)', '#5f9a4a'), (r'\b(blue|azure|indigo|teal)', '#4f7fa8'), (r'\b(black|dark|sooty|charcoal)', '#55505a'),
        (r'\b(white|pale|grey|gray|silver|chalk)', '#b8bec6'), (r'\b(brown|tan|dusty|sandy|russet)', '#9a6b45'), (r'\b(pink|rose)', '#c46a9b'), (r'\b(purple|violet|mauve)', '#7a5aa8')]

def hx2hls(h): r, g, b = (int(h[i:i+2], 16) / 255 for i in (1, 3, 5)); return colorsys.rgb_to_hls(r, g, b)
def hls2hx(h, l, s): r, g, b = colorsys.hls_to_rgb(h % 1, min(1, max(0, l)), min(1, max(0, s))); return '#%02x%02x%02x' % (round(r * 255), round(g * 255), round(b * 255))
def mix(a, b, t):
    A = [int(a[i:i+2], 16) for i in (1, 3, 5)]; B = [int(b[i:i+2], 16) for i in (1, 3, 5)]
    return '#%02x%02x%02x' % tuple(round(A[i] * (1 - t) + B[i] * t) for i in range(3))

def theme_of(c):
    """Creature base tone: first colour word of its art line / name, else its first landscape."""
    txt = (c['art'] + ' ' + c['name']).lower()
    for rx, hx in WORD:
        if re.search(rx, txt): return hx, 'art-word'
    return THEME.get(c['lands'].split(',')[0].strip(), THEME['any']), 'land:' + c['lands'].split(',')[0].strip()

def palette(c, fam):
    base, why = theme_of(c)
    col = mix(FAMILIES[fam]['tone'], base, .40)                    # creature-heavy: duller and darker than the player tone
    h, l, s = hx2hls(col); col = hls2hx(h, min(.74, max(.50, l * .88)), s * .75)
    bh, bl, bs = hx2hls(base); acc = hls2hx(bh, .17, min(.6, bs * .8 + .1))
    return col, acc, base, why

def kw_hits(name):
    n = name.lower(); return [f for f, rx in KEY.items() if re.search(rx, n)]

def decide(c, p):
    """-> (family, confident, why). Order: override (applied later) > mechanical tag > keyword (allowed families only) > type default."""
    t, tag, n = p['t'], p['tag'], p['n']; hits = kw_hits(n); swarm = any(a.startswith('swarm') for a in c['ab']) or bool(re.search(SWARM_RX, n.lower()))
    cl = c['class']; why = 'type %s/%s' % (t, tag or '-')
    def kw(allowed):
        h = [x for x in hits if x in allowed]
        return h
    if t == 'heal' or (t == 'trick' and tag == 'heal'): return 'mend', True, why
    if t == 'hurt':
        if tag == 'pierce': return 'thrust', True, why
        if tag == 'poison': return 'drip', True, why
        if tag == 'bash': return 'bash', True, why
        h = kw(HURT_KEYS)
        if len(h) > 1: return h[0], False, 'two keywords %s' % '+'.join(h)
        if h: return h[0], True, 'keyword ' + h[0]
        if tag == 'quick': return ('buzz' if cl == 'Critter' and swarm else 'shock'), True, why + (' on swarm critter' if cl == 'Critter' and swarm else '')
        return 'slash', True, why
    if t == 'guard':
        if tag == 'hold': return 'shield', True, why
        if tag == 'thorns': return 'thorn', True, why
        h = kw(('sparkle', 'leaf', 'ripple', 'web'))
        if len(h) > 1: return h[0], False, 'two keywords %s' % '+'.join(h)
        if h: return h[0], True, 'keyword ' + h[0]
        if tag == 'evade': return ('ripple' if cl == 'Water' else 'puff'), True, why
        return 'shield', True, why
    if t == 'trick':
        if tag == 'poison': return 'drip', True, why
        if tag == 'bash': return 'bash', True, why
        if tag == 'thorns': return 'thorn', True, why
        h = kw(SOFT_KEYS)
        if len(h) > 1: return h[0], False, 'two keywords %s' % '+'.join(h)
        if h: return h[0], True, 'keyword ' + h[0]
        if tag == 'trip': return ('web' if c['family'] in SPIDER else 'web'), True, why
        if tag == 'quick': return 'shock', True, why
        if tag == 'evade': return ('ripple' if cl == 'Water' else 'puff'), True, why
        return 'ripple', False, 'trick with no tag and no keyword'
    return 'slash', False, 'unknown type ' + t

# ---- themed pass (TEMPLATE.md section 9). Every id below must exist as a `case 'id'` in the page template (checked at build time).
PERSONALITIES = {   # place personality: rf = raise time factor, ri = extra rise px; the wiggle itself (x 2.6 px, rot .06) is never changed
 'squelch': dict(rf=1.4, ri=0, desc='slow wet raise, squash on landing that recovers through the wiggle, slime puddle spreads'),
 'hop':     dict(rf=1.0, ri=1, desc='double hop on the way up, a small re-bounce after the click, dust puffs'),
 'thud':    dict(rf=.8,  ri=2, desc='fast heavy raise, squash and a 1 px shake on landing, dust'),
 'flutter': dict(rf=1.5, ri=1, desc='slow floating raise with side sway, soft landing, two powder motes fall'),
 'skitter': dict(rf=.9,  ri=0, desc='quick raise with a tiny side jitter, leg ticks at the sides'),
 'scuttle': dict(rf=1.0, ri=0, desc='slides in sideways like a crab, sand dots behind'),
 'glide':   dict(rf=1.1, ri=-2, desc='low slide in from the left, almost no lift, a streak behind'),
 'plop':    dict(rf=1.0, ri=4, desc='drops from higher, squash, a ring splashes out at the base'),
 'bob':     dict(rf=1.3, ri=0, desc='bobs on the way up as if floating, a ripple ring on landing'),
 'tumble':  dict(rf=1.1, ri=1, desc='rolls in (a rotation unwinds during the raise), dust arc'),
 'march':   dict(rf=1.1, ri=0, desc='steps up in 2 px steps, crumbs at the base'),
 'swarm':   dict(rf=1.3, ri=0, desc='dots converge onto the spot and the piece fades in out of them'),
 'pounce':  dict(rf=.9,  ri=5, desc='crouch, then a high quick leap, speed lines below'),
 'burrow':  dict(rf=1.2, ri=0, desc='rises up out of the ground (comes from below), a dirt mound kicks out'),
 'hover':   dict(rf=1.6, ri=3, desc='hangs above longer with a small bob and a stipple shadow, then drops'),
 'trundle': dict(rf=1.7, ri=0, desc='very slow heavy raise, deep squash, dust'),
}
SND_STYLES = {'click': '4 corner dashes', 'pop': 'arc of 6 lines', 'tink': '3 small crosses', 'zig': 'buzz zigzags', 'thud': '2 low lines + dust',
              'squish': 'wavy blobs at the base', 'whirr': 'pairs of curved wing arcs', 'croak': '3 concentric arcs above', 'crack': 'jagged broken lines',
              'hiss': 'S-shaped hiss lines', 'chirp': 'small v marks rising'}
LAYOUTS = {  # role layout of a piece's own-edge effect (from type/tag) -> verb used in automatic notes
 'strike': 'lunge off the edge', 'lance': 'shoot along the edge in one line', 'slam': 'slam out and drop back', 'fall': 'drop off the edge and fall',
 'hold': 'line up along the edge and hold', 'scatter': 'scatter out and come back', 'bristle': 'bristle out like spikes', 'rise': 'rise up off the edge',
 'feint': 'blink from spot to spot', 'snare': 'hang at spots tied together'}
CARRIERS = ('train', 'comet', 'hop', 'cloud', 'trail', 'rings', 'blink', 'thread', 'roll', 'flutter', 'zig', 'loop', 'tunnel')

def layout_of(p):
    t, tag = p['t'], p['tag']
    if t == 'hurt': return {'pierce': 'lance', 'poison': 'fall', 'bash': 'slam'}.get(tag, 'strike')
    if t == 'guard': return {'evade': 'scatter', 'thorns': 'bristle'}.get(tag, 'hold')
    if t == 'heal': return 'rise'
    return {'poison': 'fall', 'trip': 'snare', 'evade': 'scatter', 'bash': 'slam', 'thorns': 'bristle', 'heal': 'rise'}.get(tag, 'feint')

def theme_piece(c, p, t, MOT):
    """-> the `th` block of one piece (themed motif, params, carrier, sound line, colours, note)."""
    o = t.get('p', {}).get(p['k'][2:], {}); o = {'n': o} if isinstance(o, str) else o
    m = o.get('m') or (t['m2'] if p['t'] in ('guard', 'heal') and t.get('m2') else t['m'])
    if m not in MOT: sys.exit('unknown motif %s in %s' % (m, c['slug']))
    lay = o.get('lay') or layout_of(p)
    spd = round(t.get('spd', 1) * (1.3 if p['tag'] == 'quick' else .8 if p['tag'] == 'hold' else 1), 2)
    z = 1 if p['tag'] in ('bash', 'hold') or p['v'] >= 12 else 0
    x = o.get('x') or (t.get('x') if m == t['m'] and t.get('x') else MOT[m]['x'])
    pal = t['pal']; col = o.get('c', pal[0]); hi = pal[2] if 'c' not in o else mix(col, '#ffffff', .55)
    snd = t['snd'][0] if p['t'] in ('hurt', 'trick') else t['snd'][1]
    note = o.get('n') or '%s: %s %s' % (p['n'], MOT[m]['nm'], LAYOUTS[lay])
    return dict(motif=m, mp=dict(lay=lay, spd=spd, z=z, x=x), carrier=o.get('car', MOT[m]['car']), snd=snd, col=col, acc=pal[1], hi=hi,
                colL=mix(col, '#ffffff', .45), note=note, hand=bool(o.get('n')), fam=MOT[m]['fam'])

def check_impl(tpl, MOT, CT):
    """Every glyph / motion / extra / carrier / personality / sound style used must have a `case 'id'` in the page template."""
    need = set()
    for m in MOT.values(): need |= {m['g'], m['mo'], m['x'], m['car']}
    for t in CT.values():
        need |= {t['pers']} | set(t['snd']) | {t.get('x', '-')}
        for o in t.get('p', {}).values():
            if isinstance(o, dict): need |= {o.get('lay', 'hold'), o.get('x', '-'), o.get('car', 'train')}
    need |= set(LAYOUTS) | set(CARRIERS)
    miss = sorted(i for i in need - {'-', 'none'} if ("case '%s'" % i) not in tpl)
    if miss: sys.exit('themed ids with no page code (add a case to small-anim.template.html): ' + ', '.join(miss))

def theme_cov(creatures, entries, MOT):
    uni = [e for e in entries if e['layer'] == 'unique']
    used = collections.Counter(e['th']['motif'] for e in entries)
    by_c = collections.defaultdict(set)
    for e in entries: by_c[e['th']['motif']].add(e['creature'])
    sig = collections.defaultdict(list)
    for c in creatures: sig[c['theme']['motif']].append(c['slug'])
    weak, dup = [], []
    for c in creatures:
        u = [e for e in uni if e['creature'] == c['slug']]
        if len({e['th']['motif'] for e in u}) == 1 and len({e['th']['mp']['lay'] for e in u}) <= 2: weak.append(c['slug'] + ': 1 motif and <= 2 layouts on its 4 unique pieces')
        lays = collections.Counter((e['th']['motif'], e['th']['mp']['lay'], e['th']['mp']['x']) for e in u)
        for k, v in lays.items():
            if v > 1: weak.append('%s: %d unique pieces share %s/%s/%s (same picture, only the colour/speed differ)' % (c['slug'], v, k[0], k[1], k[2]))
    seen = {}
    for c in creatures:
        k = (c['theme']['motif'], c['theme']['place_personality'], c['theme']['x'])
        if k in seen: dup.append('%s ~ %s (same signature motif %s, personality %s and extra %s; palettes %s vs %s)' % (c['slug'], seen[k][0], k[0], k[1], k[2], c['theme']['palette'][0], seen[k][1]))
        else: seen[k] = (c['slug'], c['theme']['palette'][0])
    return {'distinct_motifs_used': len(used), 'motifs_in_catalogue': len(MOT), 'unused_motifs': sorted(set(MOT) - set(used)),
            'signature_motifs': len(sig), 'shared_signature_motifs': {k: v for k, v in sorted(sig.items()) if len(v) > 1},
            'motif_usage_pieces': dict(sorted(used.items(), key=lambda kv: (-kv[1], kv[0]))),
            'motif_usage_creatures': {k: len(v) for k, v in sorted(by_c.items(), key=lambda kv: (-len(kv[1]), kv[0]))},
            'motifs_per_creature': {c['slug']: sorted({e['th']['motif'] for e in entries if e['creature'] == c['slug']}) for c in creatures},
            'personality_usage': dict(sorted(collections.Counter(c['theme']['place_personality'] for c in creatures).items())),
            'layout_usage': dict(sorted(collections.Counter(e['th']['mp']['lay'] for e in entries).items())),
            'carrier_usage': dict(sorted(collections.Counter(e['th']['carrier'] for e in entries).items())),
            'hand_notes': sum(1 for e in entries if e['th']['hand']), 'auto_notes': sum(1 for e in entries if not e['th']['hand']),
            'weak_spots': weak, 'near_duplicate_themes': dup}

def lift_of(p, fam):
    """1 light, 2 normal, 3 heavy slam (creature-heavy variant scales raise height, slam force and wobble)."""
    k = 2
    if p['tag'] in ('hold', 'bash', 'thorns') or fam in ('bash', 'shield', 'thorn'): k = 3
    if p['tag'] == 'quick' or fam in ('mend', 'puff', 'sparkle', 'ripple', 'leaf'): k = 1 if p['v'] <= 3 else 2
    if p['v'] >= 5: k = min(3, k + 1)
    return k

def main():
    out = subprocess.run(['php', os.path.join(HERE, 'dump_small.php'), ROOT], check=True, capture_output=True, text=True).stdout
    data = json.loads(out)
    ov = json.load(open(os.path.join(HERE, 'overrides.json'))) if os.path.exists(os.path.join(HERE, 'overrides.json')) else {}
    ovr = {k: v for k, v in ov.items() if not k.startswith('_')}
    TH = json.load(open(os.path.join(HERE, 'themes.json'))); MOT, CT = TH['motifs'], TH['creatures']
    tpl = open(os.path.join(HERE, 'small-anim.template.html')).read(); check_impl(tpl, MOT, CT)
    missing = [c['slug'] for c in data if c['slug'] not in CT]
    if missing: sys.exit('no theme in themes.json for: ' + ', '.join(missing))
    creatures, entries, used = [], [], set()
    for c in data:
        fams = []
        for p in c['pieces']:
            fam, ok, why = decide(c, p); key = c['slug'] + '/' + p['k']; o = ovr.get(key, {})
            if 'family' in o: fam, ok, why = o['family'], not o.get('review', False), 'override: ' + o.get('note', '')
            if o: used.add(key)
            col, acc, base, bwhy = palette(c, fam)
            col = o.get('col', col); acc = o.get('accent', acc)
            f = FAMILIES[fam]; snd = o.get('snd', 'thud' if p['tag'] == 'hold' and f['snd'] == 'tink' else f['snd'])
            e = dict(creature=c['slug'], piece_key=p['k'], name=p['n'], type=p['t'], tag=p['tag'] or '-', layer='unique' if p['layer'] == 'uni' else 'class', v=p['v'], knob=p['r'],
                     family=fam, variant='creature-heavy', place=dict(lift=o.get('lift', lift_of(p, fam)), snd=snd), play=dict(own=f['own'], carrier=f['carrier']), col=col, accent=acc,
                     note=why + ('; palette ' + bwhy))
            if not ok: e['review'] = 'needs-art-review'
            t = CT[c['slug']]; e['colL'] = mix(col, '#ffffff', .45); e['th'] = theme_piece(c, p, t, MOT)
            e['th']['place'] = dict(pers=t['pers'], lift=e['place']['lift'], snd=e['th']['snd'])
            entries.append(e); fams.append(fam)
        col0, acc0, base, bwhy = palette(c, 'slash')
        t = CT[c['slug']]; unk = [k for k in t.get('p', {}) if not any(p['k'] == 'f:' + k for p in c['pieces'])]
        if unk: sys.exit('theme piece key(s) %s match no piece of %s' % (unk, c['slug']))
        creatures.append(dict(slug=c['slug'], name=c['name'], level=c['level'], cls=c['class'], ab=c['ab'], lands=c['lands'], art=c['art'], base=base, theme_src=bwhy, families=sorted(set(fams)),
                              theme=dict(palette=t['pal'], motif=t['m'], motif2=t.get('m2'), place_personality=t['pers'], snd_set=t['snd'], spd=t.get('spd', 1), x=t.get('x', MOT[t['m']]['x']), notes=t['notes'])))
    for k in ovr:
        if k not in used: sys.exit('override key matches no piece: ' + k)
    # ---- coverage
    uni = [e for e in entries if e['layer'] == 'unique']
    cov = {'creatures': len(creatures), 'pieces_total': len(entries), 'pieces_unique_layer': len(uni), 'pieces_class_layer': len(entries) - len(uni),
           'per_family_all': dict(sorted(collections.Counter(e['family'] for e in entries).items())), 'per_family_unique': dict(sorted(collections.Counter(e['family'] for e in uni).items())),
           'creatures_per_family': {f: sum(1 for c in creatures if f in c['families']) for f in FAMILIES}, 'needs_art_review': [e['creature'] + '/' + e['piece_key'] + ' ' + e['name'] + ' (' + e['note'].split(';')[0] + ')' for e in entries if e.get('review')],
           'unused_families': [f for f in FAMILIES if not any(e['family'] == f for e in entries)]}
    mixes = collections.Counter(tuple(c['families']) for c in creatures); cov['top_family_mixes'] = ['+'.join(k) + ' x' + str(v) for k, v in mixes.most_common(8)]
    tcov = theme_cov(creatures, entries, MOT)
    J = dict(meta=dict(note='Generated by claude/pf-anim/build_small_anim.py from the real piece data; do not edit by hand, use overrides.json.', variant='creature-heavy', layers='unique = the creature\'s own 4 (pf_creature_pieces / pf_creatures deck); class = its 4 class pieces (shared effect rules, own names)'),
             families=FAMILIES, motifs=MOT, personalities=PERSONALITIES, snd_styles=SND_STYLES, layouts=LAYOUTS, creatures=creatures, entries=entries, coverage=cov, theme_coverage=tcov)
    json.dump(J, open(os.path.join(HERE, 'small-creatures.json'), 'w'), indent=1, ensure_ascii=False)
    with open(os.path.join(HERE, 'coverage.txt'), 'w') as f:
        f.write('Coverage (small creatures)\n' + json.dumps(cov, indent=1, ensure_ascii=False) + '\n')
        f.write('\nThemed pass coverage (themes.json)\n' + json.dumps(tcov, indent=1, ensure_ascii=False) + '\n')
    mini = dict(families=FAMILIES, motifs=MOT, pers=PERSONALITIES, snds=SND_STYLES, creatures=creatures, entries=entries)
    html = tpl.replace('/*__DATA__*/null', json.dumps(mini, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/'))
    open(os.path.join(ROOT, 'claude', 'mockups', 'pf-small-anim.html'), 'w').write(html)
    print(json.dumps({k: cov[k] for k in ('creatures', 'pieces_total', 'pieces_unique_layer', 'per_family_unique', 'per_family_all', 'unused_families')}))
    print('themed: %d distinct motifs used (%d in catalogue), %d signature motifs, %d hand notes, %d weak spots, %d near-duplicate themes' % (
        tcov['distinct_motifs_used'], tcov['motifs_in_catalogue'], tcov['signature_motifs'], tcov['hand_notes'], len(tcov['weak_spots']), len(tcov['near_duplicate_themes'])))
    for w in tcov['weak_spots'] + tcov['near_duplicate_themes']: print('   theme:', w)
    print('needs-art-review:', len(cov['needs_art_review']))
    for r in cov['needs_art_review']: print('  ', r)
if __name__ == '__main__': main()
