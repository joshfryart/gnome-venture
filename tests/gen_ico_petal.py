#!/usr/bin/env python3
"""v2.4.91 Petals currency icon (replaces ico-coin for 🪙) -> tests/ico_src/ico-petal.svg. Build: python3 tests/gen_ico_petal.py build
The pixel PNG is drawn by aseprite-source/final/scripts/ico/ico-petal.lua (gvlib, icon mode); this is the SVG fallback."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); OUT = os.path.join(HERE, 'ico_src')
PK = '#e46a9b'; PL = '#f6b8cf'; PD = '#c44a7e'
I = {'petal': ('Petals',
    '<path fill="%s" d="M12 56C15 40 19 24 31 14C37 9 43 9 46 13L45 21L52 17C57 26 55 38 46 45C36 52 24 54 12 56Z"/>' % PK
    + '<path d="M18 49Q28 36 39 25" fill="none" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % PD
    + '<ellipse cx="28" cy="22" rx="3" ry="6" fill="%s" transform="rotate(35 28 22)"/>' % PL)}
if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for n, (label, body) in I.items():
        open(os.path.join(OUT, 'ico-%s.svg' % n), 'w', encoding='utf-8').write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (label, body))
    print('wrote', len(I))
    if len(sys.argv) > 1 and sys.argv[1] == 'build':
        os.environ['PYTHONHASHSEED'] = '1'
        sys.path.insert(0, HERE); import hearth
        D = os.path.join(os.path.dirname(HERE), 'game/assets/img/ico')
        for n in I:
            s = 'ico-' + n
            o = hearth.restyle(open(os.path.join(OUT, s + '.svg'), encoding='utf-8').read(), s)
            open(os.path.join(D, s + '.svg'), 'w', encoding='utf-8').write(o)
        print('built', len(I))
