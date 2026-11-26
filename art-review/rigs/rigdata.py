"""Read the rig layout straight from game/assets/fightrigs.js (read-only). Same maths as fightengine.js rigFor()."""
import re, json, os
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
JS = os.path.join(ROOT, 'game/assets/fightrigs.js')


def _load():
    src = open(JS).read()
    skel, rigs = {}, {}
    for m in re.finditer(r'^"([\w-]+)":\{(.*)\},?$', src, re.M):
        bones = {}
        for b in re.finditer(r'(\w+):\[(0|"[\w-]+"),(-?[\d.]+),(-?[\d.]+),([01])\]', m.group(2)):
            bones[b.group(1)] = (None if b.group(2) == '0' else b.group(2).strip('"'), float(b.group(3)), float(b.group(4)), int(b.group(5)))
        skel[m.group(1)] = bones
    for m in re.finditer(r'^"([\w-]+)":\["([\w-]+)",(\d+),(\d+),([\d.]+),"([\w,]+)","([\w.]+)"\]', src, re.M):
        rigs[m.group(1)] = dict(skel=m.group(2), fw=int(m.group(3)), fh=int(m.group(4)), u=float(m.group(5)), parts=m.group(6).split(','), arch=m.group(7))
    return skel, rigs


SKEL, RIGS = _load()


def rig(slug):
    """dict: fw, fh, u, parts (sheet column order), arch, cx, by, bones {id: (parent, a, b, under)}, piv {id: (x, y) frame px (float, as the engine's transform-origin)}"""
    r = dict(RIGS[slug]); sk = SKEL[r['skel']]
    r['cx'] = (r['fw'] - 1) / 2; r['by'] = r['fh'] - 5
    r['bones'] = {p: sk[p] for p in r['parts']}
    r['piv'] = {p: (r['cx'] + sk[p][1] * r['u'] + .5, r['by'] - sk[p][2] * r['u'] + .5) for p in r['parts']}
    return r


if __name__ == '__main__':
    import sys
    from PIL import Image
    for slug in sys.argv[1:]:
        r = rig(slug)
        im = Image.open(os.path.join(ROOT, 'game/assets/img/fight/rig-%s.png' % slug)).convert('RGBA')
        print(slug, 'frame', r['fw'], 'x', r['fh'], 'u', r['u'], r['arch'], 'sheet', im.size)
        for i, p in enumerate(r['parts']):
            fr = im.crop((i * r['fw'], 0, (i + 1) * r['fw'], r['fh']))
            print('  %-6s parent=%-5s under=%d pivot=(%.1f,%.1f) bbox=%s' % (p, r['bones'][p][0], r['bones'][p][3], r['piv'][p][0], r['piv'][p][1], fr.getbbox()))
