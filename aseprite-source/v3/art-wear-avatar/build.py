#!/usr/bin/env python3
"""Build wear-avatar strips for a region and its contact sheets.

  python3 build.py NA                 # all items of NA/items.py
  python3 build.py NA na-portage-sack # one item

Writes wear/<slug>/<front|back|side>.png (same tree as game/assets/img/gnome25/wear/, nothing is copied into game/),
<REGION>/sheets/<slug>.png (icon + the item composed on the default gnome: 3 views x 8 frames at 1x and 4x) and
<REGION>/overview.png (all items, frames 1/4/7 per view at 2x). Prints problems (semi-alpha, #000/#fff, head-zone changes).
"""
import importlib, json, os, sys, time
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import av, rig, cats

BG = (138, 134, 144, 255)
BG2 = (52, 46, 60, 255)


def icon_path(region, slug, pieces):
    p = next(x for x in pieces if x['slug'] == slug)
    name = slug.split('-', 1)[1]
    return os.path.join(rig.ROOT, 'aseprite-source/v3/art-wear-concepts', region, f"{p['cat']}-{p['n']}-{name}.png")


def sheet(region, slug, cat, strips, icon):
    s = 4
    rows = []
    for v in av.VIEWS:
        st = rig.compose(v, [(cat, strips[v])])
        rows.append((v, st))
    Wd = 512 * s + 140
    Hh = sum(80 + 6 + 80 * s + 14 for _ in rows) + 20
    out = Image.new('RGBA', (Wd, Hh), BG)
    d = ImageDraw.Draw(out)
    ic = Image.open(icon).convert('RGBA').resize((128, 128), Image.NEAREST)
    out.alpha_composite(ic, (6, 10))
    d.text((6, 142), slug, fill=(30, 20, 30, 255))
    y = 10
    for v, st in rows:
        d.text((6, y + 170 if v == 'front' else y + 4), v, fill=(30, 20, 30, 255))
        out.alpha_composite(st, (140, y))
        dk = Image.new('RGBA', (512, 80), BG2); dk.alpha_composite(st)
        out.alpha_composite(dk, (140 + 520, y))
        out.alpha_composite(st.resize((512 * s, 80 * s), Image.NEAREST), (140, y + 86))
        y += 80 + 6 + 80 * s + 14
    return out


def overview(region, items, results):
    s = 2; fr = (1, 4, 7)
    cw = 64 * s
    Wd = 80 + cw * len(fr) * 3 + 20
    Hh = 80 * s * len(items) + 10
    out = Image.new('RGBA', (Wd, Hh), BG)
    d = ImageDraw.Draw(out)
    for i, it in enumerate(items):
        y = i * 80 * s + 5
        ic = Image.open(results[it['slug']]['icon']).convert('RGBA').resize((64, 64), Image.NEAREST)
        out.alpha_composite(ic, (8, y + 40))
        d.text((4, y + 4), it['slug'][3:22], fill=(30, 20, 30, 255))
        for j, v in enumerate(av.VIEWS):
            st = rig.compose(v, [(it['cat'], results[it['slug']]['strips'][v])])
            for k, f in enumerate(fr):
                c = st.crop(((f - 1) * 64, 0, f * 64, 80)).resize((cw, 80 * s), Image.NEAREST)
                out.alpha_composite(c, (80 + (j * len(fr) + k) * cw + j * 6, y))
    return out


def main():
    region = sys.argv[1]
    only = sys.argv[2:]
    mod = importlib.import_module(f'{region}.items')
    pieces = json.load(open(os.path.join(rig.ROOT, 'claude/wear-pieces/pieces.json')))
    items = [it for it in mod.ITEMS if not only or it['slug'] in only]
    os.makedirs(os.path.join(HERE, region, 'sheets'), exist_ok=True)
    results = {}
    for it in items:
        t = time.time()
        strips = getattr(cats, it['cat'])(it)
        od = os.path.join(HERE, 'wear', it['slug'])
        os.makedirs(od, exist_ok=True)
        probs = []
        for v, im in strips.items():
            im.save(os.path.join(od, f'{v}.png'))
            probs += [f'{v}: {p}' for p in av.check(im, v, it['cat'])]
        icon = icon_path(region, it['slug'], pieces)
        sheet(region, it['slug'], it['cat'], strips, icon).save(os.path.join(HERE, region, 'sheets', it['slug'] + '.png'))
        results[it['slug']] = dict(strips=strips, icon=icon)
        print(f"{it['slug']:32} {time.time() - t:4.1f}s {'OK' if not probs else '; '.join(probs)}")
    if not only:
        overview(region, items, results).save(os.path.join(HERE, region, 'overview.png'))


if __name__ == '__main__':
    main()
