#!/bin/bash
# The approved Opus art of 2.7.01 (tools/install_art_2701.py): tests/art_2701.php on an installed copy (ci_suites.sh installs it with walk.sh first),
# then derive_icons.py on a copy of ph/: the hand-drawn icons (PROTECTED: all 33 since step 2) are never rewritten and nothing else in ph/ changes.
# Usage: tests/art_2701.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/.." && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/art_2701.php" "$1" "$REPO" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL art_2701 did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL art_2701 printed PHP warnings"; exit 1; }
echo "== derive_icons.py keeps the hand-drawn icons"
if ! python3 -c 'import PIL' 2>/dev/null; then echo "  skip (no Pillow)"; exit $RC; fi
T=$(mktemp -d); cp -r "$REPO/game/assets/img/ph" "$T/ph"
python3 - "$REPO" "$T/ph" <<'PY' || RC=1
import hashlib, importlib.util, os, subprocess, sys
repo, ph = sys.argv[1], sys.argv[2]
spec = importlib.util.spec_from_file_location('d', os.path.join(repo, 'aseprite-source/v3/gnome-wear/derive_icons.py'))
d = importlib.util.module_from_spec(spec); sys.argv = ['x', ph]; spec.loader.exec_module(d)
rows = subprocess.run([sys.executable, os.path.join(repo, 'tools/install_art_2701.py'), '--list'], capture_output=True, text=True).stdout.split()
drawn = {r.split('|')[1][3:-4] for r in rows if r.split('|')[1].startswith('ph/')}
bad = 0
def ok(what, cond, extra=''):
    global bad
    print(('  ok   ' if cond else '  FAIL ') + what + ('' if cond else '  ' + extra)); bad += not cond
ok('every installed wearable icon is in PROTECTED', drawn <= d.PROTECTED, ' '.join(sorted(drawn - d.PROTECTED)))
h = lambda f: hashlib.md5(open(f, 'rb').read()).hexdigest()
ok('step 2: all 33 wearable icons (6 bases and 5 cut b, each plain / Lined / Fine) are hand-drawn and PROTECTED', len(drawn) == 33 and drawn == d.PROTECTED, '%d drawn, %d protected' % (len(drawn), len(d.PROTECTED)))
before = {f: h(os.path.join(ph, f)) for f in os.listdir(ph) if f.endswith('.png')}
d.main()
after = {f: h(os.path.join(ph, f)) for f in os.listdir(ph) if f.endswith('.png')}
ok('re-running derive_icons.py leaves every hand-drawn icon byte for byte', all(before[s + '.png'] == after[s + '.png'] for s in d.PROTECTED), ' '.join(s for s in d.PROTECTED if before[s + '.png'] != after[s + '.png']))
ok('...and writes no other file in ph/', before == after, ' '.join(f for f in before if before[f] != after[f]))
sys.exit(1 if bad else 0)
PY
rm -rf "$T"
exit $RC
