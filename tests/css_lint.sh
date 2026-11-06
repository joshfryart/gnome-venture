#!/bin/bash
# Polish Phase 1 guard: css_lint.sh GAME PORT ROUTER (only GAME is used). Checks game/assets/style.css:
#  - braces balance
#  - no (min-width: N) equal to a (max-width: N): at exactly N px both would apply (use N+1)
#  - the number of distinct width breakpoints does not grow past the ratchet (17 on 2026-11-01; lower it as they are merged)
#  - map links that switch the outline off (.worldmap a.region, .regionmap a, .mycsvg a) keep a :focus-visible ring on their .hit/.mhit
GAME=${1:-$(dirname "$0")/../game}; CSS=$GAME/assets/style.css; RATCHET=17
python3 - "$CSS" "$RATCHET" <<'PY'
import re, sys
css, ratchet = open(sys.argv[1]).read(), int(sys.argv[2]); bad = 0
def chk(ok, msg):
    global bad
    print(('ok   ' if ok else 'FAIL ') + msg); bad += (not ok)
chk(css.count('{') == css.count('}'), 'braces balance (%d open, %d close)' % (css.count('{'), css.count('}')))
mm = set(re.findall(r'@media[^{]*?min-width:\s*(\d+)px', css)); xm = set(re.findall(r'@media[^{]*?max-width:\s*(\d+)px', css))
clash = sorted(mm & xm, key=int)
chk(not clash, 'no @media min-width equal to a max-width (%s)' % (', '.join(clash) or 'none'))
mq = set(re.findall(r'@media[^{]*?(?:min|max)-width:\s*(\d+)px', css))
chk(len(mq) <= ratchet, 'distinct width breakpoints %d (ratchet %d)' % (len(mq), ratchet))
for sel, hit in (('.worldmap a.region', '.hit'), ('.regionmap a', '.hit'), ('.mycsvg a', '.mhit')):
    ok = any(re.search(re.escape(sel + ':focus-visible ' + hit), r.split('{')[0]) and re.search(r'stroke:\s*var\(--focus\)', r.split('{', 1)[1]) for r in css.split('}') if '{' in r)
    chk(ok, '%s has a focus ring on %s' % (sel, hit))
sys.exit(1 if bad else 0)
PY
