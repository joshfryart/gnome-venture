#!/usr/bin/env python3
"""Build the runtime PARTS kit for the felt four-sided jigsaw pieces and PROVE it equals gen4.render().

Kit (written to <out>):
  parts-<size>-<owner>.png     index sheet: cell 0 = base (all edges flat), then one STAMP per (side, kind, fam)
  patterns-<size>.png          7 cells (ORDER): fill-pattern mask per type
  icons-<size>.png             7 cells (ORDER): the icon per type (hand 32x32, strip 20x20)
  atlas.json, rim.json
  example/                     one worked piece (parts, index, final) + board-demo.png + expected board json
Index images: colour = (role, 0, 0, 255). alpha 0 = transparent (base) / unchanged (stamp). In a stamp R=255 = ERASE.
Compose a piece: start from base, apply the 4 side stamps (any order, they never touch the same pixel), recolour roles.
Run: python3 gen_parts.py <out dir>
"""
import json
import os
import random
import shutil
import sys
import numpy as np
from PIL import Image
import base_icons as B
import gen4 as G

SIDES, ORDER, FAM3 = 'LRTB', B.ORDER, G.FAM3
KINDS = [('knob', f) for f in FAM3] + [('hole', f) for f in FAM3]
ERASE = 255
GOLD_ = B.GOLD

ROLES = {  # name: (id, default rgb)
    'INK': (1, B.INK), 'RIM_ME': (2, B.CREAM), 'STITCH_ME': (3, B.GOLD), 'RIM_FOE': (4, G.RUST),
    'BAND_FOE': (5, G.MAROON), 'STITCH_FOE': (6, G.STITCH), 'THORN_TIP': (7, G.BONE), 'THORN_BODY': (8, G.TOOTH),
    'PLATE': (9, B.CREAM), 'PLATE_SHADE': (10, B.CREAM_D),
    'FILL': (11, None), 'SHADE': (12, None), 'LIGHT': (13, None), 'TYPE_BASE': (14, None)}
RID = {k: v[0] for k, v in ROLES.items()}
# neutral fake type: unique colours so every pixel role is recoverable
NEUT = {'base': (1, 201, 1), 'mark': (1, 204, 1), 'shade': (1, 202, 1), 'light': (1, 203, 1)}
COL2ROLE = {B.INK: 'INK', B.CREAM: 'RIM_ME', B.GOLD: 'STITCH_ME', G.RUST: 'RIM_FOE', G.MAROON: 'BAND_FOE',
            G.STITCH: 'STITCH_FOE', G.BONE: 'THORN_BODY', G.TOOTH: 'THORN_BODY', B.CREAM_D: 'PLATE_SHADE',
            NEUT['base']: 'FILL', NEUT['shade']: 'SHADE', NEUT['light']: 'LIGHT'}
COL2ROLE[G.BONE] = 'THORN_TIP'

REAL_PAT = B.pat
REAL_ICON = G.get_icon


def neutral_index(size, edges, owner):
    """gen4 render with fake type, no pattern, no icon -> HxW uint8 role image (0 = transparent)."""
    B.TYPES['idx'] = NEUT
    B.pat = lambda *a: False
    G.get_icon = lambda t, s: Image.new('RGBA', (1, 1), (0, 0, 0, 0))
    G._cache.clear()
    try:
        im = np.array(G.render('idx', size, edges, owner))
    finally:
        B.pat, G.get_icon = REAL_PAT, REAL_ICON
        G._cache.clear()
        del B.TYPES['idx']
    g = G.GEO[size]
    KX, KY = g['KX'], g['KY']
    out = np.zeros(im.shape[:2], np.uint8)
    tx, ty, tw, th = g['tag']
    plate = (tx + KX - 1, ty + KY - 1, tx + KX + tw, ty + KY + th)      # x0,y0,x1,y1 inclusive
    rib = None
    if g['name']:
        nx, ny, nw, nh = g['name']
        rib = (nx + KX - 1, ny + KY - 1, nx + KX + nw, ny + KY + nh)
    for y in range(im.shape[0]):
        for x in range(im.shape[1]):
            if im[y, x, 3] == 0:
                continue
            c = tuple(int(v) for v in im[y, x, :3])
            role = COL2ROLE[c]
            inp = plate[0] <= x <= plate[2] and plate[1] <= y <= plate[3]
            inr = rib and rib[0] <= x <= rib[2] and rib[1] <= y <= rib[3]
            if (inp or inr) and role == 'RIM_ME':
                role = 'PLATE'
            if inr and role == 'FILL':
                role = 'TYPE_BASE'
            out[y, x] = RID[role]
    return out


def stamp_of(flat, ed):
    ch = flat != ed
    st = np.zeros(flat.shape + (4,), np.uint8)
    st[ch & (ed > 0), 0] = ed[ch & (ed > 0)]
    st[ch & (ed == 0), 0] = ERASE
    st[ch, 3] = 255
    return st, ch


def apply_stamp(idx, st):
    m = st[..., 3] > 0
    r = st[..., 0]
    idx = idx.copy()
    idx[m & (r == ERASE)] = 0
    idx[m & (r != ERASE)] = r[m & (r != ERASE)]
    return idx


def build_kit(size, owner):
    flat = neutral_index(size, {}, owner)
    stamps, changed = {}, {}
    for s in SIDES:
        for kind, fam in KINDS:
            ed = neutral_index(size, {s: (kind, fam)}, owner)
            stamps[(s, kind, fam)], changed[(s, kind, fam)] = stamp_of(flat, ed)
    return flat, stamps, changed


def compose_index(flat, stamps, edges):
    idx = flat.copy()
    for s in SIDES:
        kind, fam = edges[s]
        if kind != 'flat':
            idx = apply_stamp(idx, stamps[(s, kind, fam)])
    return idx


# ------------------------------------------------------------------ recolour (the reference the JS must match)
def type_pal(t):
    return B.TYPES[t]


def pattern_mask(size, t):
    g = G.GEO[size]
    W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
    m = np.zeros((H + 2 * KY, W + 2 * KX), bool)
    for y in range(m.shape[0]):
        for x in range(m.shape[1]):
            m[y, x] = bool(B.pat(t, size, x - KX, y - KY))
    return m


def recolour(idx, t, size, pat, icon, owner_pal=None):
    pal = {r: v[1] for r, v in ROLES.items()}
    if owner_pal:
        pal.update(owner_pal)
    tp = type_pal(t)
    out = np.zeros(idx.shape + (4,), np.uint8)
    rid2name = {v[0]: k for k, v in ROLES.items()}
    for y in range(idx.shape[0]):
        for x in range(idx.shape[1]):
            r = idx[y, x]
            if r == 0:
                continue
            n = rid2name[r]
            if n == 'FILL':
                c = tp['mark'] if pat[y, x] else tp['base']
            elif n == 'SHADE':
                c = tp['shade']
            elif n == 'LIGHT':
                c = tp['light']
            elif n == 'TYPE_BASE':
                c = tp['base']
            else:
                c = pal[n]
            out[y, x] = c + (255,)
    g = G.GEO[size]
    ix, iy = g['ix'] + g['KX'], g['iy'] + g['KY']
    ic = np.array(icon)
    for yy in range(ic.shape[0]):
        for xx in range(ic.shape[1]):
            if ic[yy, xx, 3] and idx[iy + yy, ix + xx]:
                out[iy + yy, ix + xx] = ic[yy, xx]
    return out


def rand_edges(rnd):
    e = {}
    for s in SIDES:
        k = rnd.choice(['flat'] + [x for x in KINDS])
        e[s] = ('flat', None) if k == 'flat' else k
    return e


def verify(size, owner, flat, stamps, n, rnd, pats, icons):
    """compose-from-parts == gen4.render for n random edge sets x random types; also checks stamps never overlap"""
    bad = 0
    for i in range(n):
        e = rand_edges(rnd)
        t = rnd.choice(ORDER)
        idx = compose_index(flat, stamps, e)
        got = recolour(idx, t, size, pats[t], icons[t])
        want = np.array(G.render(t, size, e, owner))
        if not np.array_equal(got, want):
            bad += 1
            if bad <= 3:
                d = np.argwhere(np.any(got != want, -1))
                print('MISMATCH', size, owner, t, e, 'px', len(d), d[:5].tolist())
        ov = np.zeros(flat.shape, int)
        for s in SIDES:
            if e[s][0] != 'flat':
                ov += stamps[(s,) + e[s]][..., 3] > 0
        if (ov > 1).any():
            bad += 1
            print('OVERLAP', size, owner, e)
    return bad


def sheet(cells, cw, ch, cols):
    rows = (len(cells) + cols - 1) // cols
    im = Image.new('RGBA', (cols * cw, rows * ch), (0, 0, 0, 0))
    for i, c in enumerate(cells):
        im.alpha_composite(Image.fromarray(c) if isinstance(c, np.ndarray) else c, ((i % cols) * cw, (i // cols) * ch))
    return im


def old_pal(p):
    mix = lambda c, k=.55, to=(0x6a, 0x5c, 0x4c): tuple(int(round(a + (b - a) * k)) for a, b in zip(c, to))
    return {n: list(mix(tuple(v))) for n, v in p.items()}


def main(out, n_verify):
    os.makedirs(out, exist_ok=True)
    ex = os.path.join(out, 'example')
    os.makedirs(ex, exist_ok=True)
    rnd = random.Random(7)
    atlas = {'version': 1, 'note': 'index in the R channel (G=B=0), alpha 255 = pixel, alpha 0 = transparent (base) / unchanged (stamp); '
             'stamp R=255 = ERASE (set transparent)', 'erase': ERASE, 'order': ['base', 'L', 'R', 'T', 'B'],
             'sizes': {}, 'sheets': {}, 'types': {}, 'patterns': {}, 'icons': {}}
    for t in ORDER:
        atlas['types'][t] = {k: list(v) for k, v in B.TYPES[t].items()}
    total_bad = 0
    pats_all, icons_all = {}, {}
    for size in ('strip', 'hand'):
        g = G.GEO[size]
        W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
        cw, ch = W + 2 * KX, H + 2 * KY
        atlas['sizes'][size] = {
            'piece': [cw, ch], 'body': [W, H], 'tab': [KX, KY], 'body_at': [KX, KY], 'pitch': [W, H],
            'plate': {'at': [g['tag'][0] + KX, g['tag'][1] + KY], 'size': [g['tag'][2], g['tag'][3]]},
            'icon': {'at': [g['ix'] + KX, g['iy'] + KY], 'size': [g['icon'], g['icon']]},
            'name_ribbon': ({'at': [g['name'][0] + KX, g['name'][1] + KY], 'size': [g['name'][2], g['name'][3]]} if g['name'] else None)}
        pats = {t: pattern_mask(size, t) for t in ORDER}
        icons = {t: G.get_icon(t, size) for t in ORDER}
        pats_all[size], icons_all[size] = pats, icons
        sheet([np.dstack([m * 255, np.zeros_like(m, np.uint8), np.zeros_like(m, np.uint8), m * 255]).astype(np.uint8) for m in pats.values()],
              cw, ch, 7).save(os.path.join(out, f'patterns-{size}.png'))
        sheet(list(icons.values()), g['icon'], g['icon'], 7).save(os.path.join(out, f'icons-{size}.png'))
        atlas['patterns'][size] = {'file': f'patterns-{size}.png', 'cell': [cw, ch], 'cols': 7, 'order': ORDER,
                                   'note': 'R=255 alpha=255 where the fill uses the type MARK colour, else BASE'}
        atlas['icons'][size] = {'file': f'icons-{size}.png', 'cell': [g['icon']] * 2, 'cols': 7, 'order': ORDER}
        for owner in ('me', 'foe'):
            flat, stamps, changed = build_kit(size, owner)
            names = ['base']
            cells = [np.dstack([flat, np.zeros_like(flat), np.zeros_like(flat), (flat > 0) * 255]).astype(np.uint8)]
            for s in SIDES:
                for kind, fam in KINDS:
                    names.append(f'{s}:{kind}:{fam}')
                    cells.append(stamps[(s, kind, fam)])
            cols = 5
            sheet(cells, cw, ch, cols).save(os.path.join(out, f'parts-{size}-{owner}.png'))
            parts = {}
            for i, nm in enumerate(names):
                c = cells[i]
                ys, xs = np.nonzero(c[..., 3])
                parts[nm] = {'col': i % cols, 'row': i // cols, 'x': (i % cols) * cw, 'y': (i // cols) * ch,
                             'bbox': [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1] if len(xs) else None}
            atlas['sheets'][f'{size}-{owner}'] = {'file': f'parts-{size}-{owner}.png', 'cell': [cw, ch], 'cols': cols,
                                                  'base': parts['base'], 'stamps': {k: v for k, v in parts.items() if k != 'base'}}
            bad = verify(size, owner, flat, stamps, n_verify, rnd, pats, icons)
            print(size, owner, 'verified', n_verify, 'bad', bad)
            total_bad += bad
            if size == 'strip' and owner == 'foe':          # worked example: foe trick, all four sides non-flat
                e = G.norm(G.DEMO_EDGES[(1, 1)])
                t = 'trick'
                for nm, arr in (('base', cells[0]), *[(f'{s}-{e[s][0]}-{e[s][1]}', stamps[(s,) + e[s]]) for s in SIDES]):
                    Image.fromarray(arr).resize((cw * 4, ch * 4), Image.NEAREST).save(os.path.join(ex, f'strip-foe-trick-part-{nm}.png'))
                idx = compose_index(flat, stamps, e)
                Image.fromarray(np.dstack([idx, np.zeros_like(idx), np.zeros_like(idx), (idx > 0) * 255]).astype(np.uint8)).save(os.path.join(ex, 'strip-foe-trick-index.png'))
                fin = recolour(idx, t, size, pats[t], icons[t])
                Image.fromarray(fin).save(os.path.join(ex, 'strip-foe-trick-final.png'))
                want = np.array(G.render(t, size, e, 'foe'))
                assert np.array_equal(fin, want)
    rim = {'note': 'role id = R value of the parts index image. Colours are the exact RGB of the felt renderer. Ring order from the '
                   'outside: 1 ink, 2 piping/band, 3 stitch pattern; the stitch/checker phase is BAKED into the stamps, no phase maths needed. '
                   'Recolour per creature by changing RIM_FOE / BAND_FOE / STITCH_FOE / THORN_*; "old" = same shape, rim colours dimmed. '
                   'Old must not be a colour-only cue: add a second cue (counter badge or dashed ghost) in code.',
           'roles': {k: {'id': v[0], 'rgb': list(v[1]) if v[1] else None, 'used_by': ''} for k, v in ROLES.items()}}
    for k, u in {'INK': 'outline ring 1, plate border (both owners)', 'RIM_ME': 'mine: cream piping (ring 2)', 'STITCH_ME': 'mine: gold running stitch, ribbon stitch',
                 'RIM_FOE': 'foe: rust ring 2 + plate corners + ribbon stitch', 'BAND_FOE': 'foe: maroon band ring 3', 'STITCH_FOE': 'foe: hand-size red-brown stitch',
                 'THORN_TIP': 'foe: bone thorn tips', 'THORN_BODY': 'foe: thorn body', 'PLATE': 'number plate + ribbon fill (leave empty)',
                 'PLATE_SHADE': 'plate lower edge line', 'FILL': 'type fill: MARK where patterns-<size> mask is 1, else BASE',
                 'SHADE': 'type shade colour', 'LIGHT': 'type light colour', 'TYPE_BASE': 'name ribbon end caps: type BASE (no pattern)'}.items():
        rim['roles'][k]['used_by'] = u
    base_rim = {k: list(v[1]) for k, v in ROLES.items() if v[1]}
    rim['palettes'] = {'default': base_rim, 'old': old_pal(base_rim)}
    rim['palettes']['old'] = {k: v for k, v in rim['palettes']['old'].items() if k not in ('INK',)}
    rim['palettes']['boss'] = {'RIM_FOE': list(GOLD_), 'BAND_FOE': [0x3a, 0x1a, 0x4a], 'STITCH_FOE': list(B.CREAM),
                               'THORN_TIP': [0xff, 0xf8, 0xe6], 'THORN_BODY': [0x7a, 0x48, 0xa8], 'PLATE': list(B.CREAM),
                               'note': 'foe boss: gold ring, violet band/thorns. Second cue = crown-boss.png at the piece top-left corner, never colour only.'}
    json.dump(rim, open(os.path.join(out, 'rim.json'), 'w'), indent=1)
    json.dump(atlas, open(os.path.join(out, 'atlas.json'), 'w'), indent=1)

    # board demos built purely from parts, must equal gen4 compose
    for size, cells_, edges_, cols, rows, name in (('strip', G.DEMO_CELLS, G.DEMO_EDGES, 3, 3, 'board-demo.png'),
                                                   ('hand', G.H2_CELLS, G.H2_EDGES, 2, 2, 'board-demo-hand.png')):
        g = G.GEO[size]
        W, H, KX, KY = g['W'], g['H'], g['KX'], g['KY']
        cv = np.zeros((rows * H + 2 * KY, cols * W + 2 * KX, 4), np.uint8)
        occ = np.zeros(cv.shape[:2], int)
        kits = {o: build_kit(size, o) for o in ('me', 'foe')}
        for (c, r), (t, o) in sorted(cells_.items(), key=lambda kv: (kv[0][1], kv[0][0])):
            e = G.norm(edges_[(c, r)])
            fl, st, _ = kits[o]
            fin = recolour(compose_index(fl, st, e), t, size, pats_all[size][t], icons_all[size][t])
            m = fin[..., 3] > 0
            x0, y0 = c * W, r * H
            occ[y0:y0 + fin.shape[0], x0:x0 + fin.shape[1]] += m
            sub = cv[y0:y0 + fin.shape[0], x0:x0 + fin.shape[1]]
            sub[m] = fin[m]
        assert occ.max() <= 1, 'opaque pixels of two pieces overlap'
        Image.fromarray(cv).save(os.path.join(ex, name))
        ref = np.array(G.compose(cells_, edges_, size, cols, rows))
        assert np.array_equal(cv, ref), name
        print(name, 'equals gen4.compose; no opaque overlap')
        if size == 'strip':
            shutil.copy(os.path.join(HERE_, 'board-demo.json'), os.path.join(ex, 'board-demo.json'))
    json.dump({'strip-3x3': {f'{c[0]},{c[1]}': {'type': t, 'owner': o, 'edges': {s: list(v) for s, v in G.norm(G.DEMO_EDGES[c]).items()}}
                             for c, (t, o) in G.DEMO_CELLS.items()},
               'hand-2x2': {f'{c[0]},{c[1]}': {'type': t, 'owner': o, 'edges': {s: list(v) for s, v in G.norm(G.H2_EDGES[c]).items()}}
                            for c, (t, o) in G.H2_CELLS.items()}}, open(os.path.join(ex, 'board-demo-pieces.json'), 'w'), indent=1)
    print('TOTAL BAD', total_bad)
    return total_bad


HERE_ = os.path.dirname(os.path.abspath(__file__))
if __name__ == '__main__':
    sys.exit(1 if main(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 40) else 0)
