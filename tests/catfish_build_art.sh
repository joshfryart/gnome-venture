#!/usr/bin/env bash
# tools/catfish_build_art.py: builds the whole Cat Fish art set with final names into a temp dir, validates it (--check), and the check fails on a
# missing file, a wrong size, a stray name and a semi-transparent pixel. Never installs into game/.
set -e
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")/.."
G0=$(ls game/assets/img/catfish 2>/dev/null | wc -l); GH0=$(ls -l game/assets/img/catfish 2>/dev/null | md5sum)
OUT=$(mktemp -d); trap 'rm -rf "$OUT" "$OUT.log" "$OUT.bad"; rm -rf tools/__pycache__' EXIT
python3 tools/catfish_build_art.py --out "$OUT" --check | tee "$OUT.log"
grep -q 'check: ok' "$OUT.log" || { echo "FAIL: --check did not pass"; exit 1; }
N=$(ls "$OUT"/cf-*.png | wc -l)
[ "$N" = 440 ] || { echo "FAIL: expected 440 files, got $N"; exit 1; }
grep -q 'built 440 files' "$OUT.log" || { echo "FAIL: build count line"; exit 1; }
[ -f "$OUT/manifest.json" ] || { echo "FAIL: no manifest.json"; exit 1; }
python3 -I - "$OUT" <<'P'
import sys, json, hashlib, os, re
o = sys.argv[1]
m = json.load(open(o + '/manifest.json'))
assert m['count'] == 440 == len(m['files'])
for r in m['files']:
    b = open(o + '/' + r['file'], 'rb').read()
    assert r['size'] == len(b) and r['sha1'] == hashlib.sha1(b).hexdigest(), r['file']
names = {r['file'] for r in m['files']}
for need in ('cf-cat-lilac-idleA.png', 'cf-bookhead-lilac.png', 'cf-bookhead-unknown.png', 'cf-room-window.png', 'cf-eyes-hazel-bored.png', 'cf-pat-calico-silver-blue-stalk.png',
             'cf-ears-folded-orange-nap.png', 'cf-tail-bobtail-black-catch.png', 'cf-up-catflap.png', 'cf-badge-book_full.png', 'cf-ribbon-part.png', 'cf-banner.png', 'cf-tile.png'):
    assert need in names, need
assert not any(n.startswith('cf-eyes-ring') or 'ginger-red' in n for n in names), 'template ring or old coat shipped'
# the tool's key lists match the game's upgrade keys
import subprocess
keys = subprocess.run(['php', '-r', 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require "game/includes/catfish.php"; echo implode(" ", array_keys(CATFISH_UPGRADES));'], capture_output=True, text=True).stdout.split()
assert len(keys) == 16 and all('cf-up-%s.png' % k in names for k in keys), keys
print('manifest ok')
P
# --verify on the good folder, then on four broken copies
python3 tools/catfish_build_art.py --verify "$OUT" | tail -1 | grep -q ' ok$' || { echo "FAIL: verify on a good folder"; exit 1; }
bad() {   # $1 = what is wrong ; $2 = shell to break a copy ; $3 = text the check must print
  rm -rf "$OUT.bad"; cp -r "$OUT" "$OUT.bad"
  (cd "$OUT.bad"; eval "$2")
  R=$(python3 tools/catfish_build_art.py --verify "$OUT.bad" || true)
  echo "$R" | grep -q "$3" || { echo "FAIL: check missed: $1"; echo "$R" | head -3; exit 1; }
  python3 tools/catfish_build_art.py --verify "$OUT.bad" >/dev/null && { echo "FAIL: check exit 0 on: $1"; exit 1; }
  echo "ok   check catches: $1"
}
bad "a missing file" 'rm cf-fish-3.png' 'missing required file cf-fish-3.png'
bad "a stray name" 'cp cf-fish-3.png cf-fish-9.png' 'not in the brief naming list: cf-fish-9.png'
bad "a wrong size" 'python3 -c "from PIL import Image; Image.new(\"RGBA\",(40,40),(1,2,3,255)).save(\"cf-rod.png\")"' 'cf-rod.png: size 40x40'
bad "a semi-transparent pixel" 'python3 -c "from PIL import Image; im=Image.open(\"cf-ico-yarn.png\").convert(\"RGBA\"); im.putpixel((16,16),(200,10,10,128)); im.save(\"cf-ico-yarn.png\")"' 'cf-ico-yarn.png: semi-transparent'
# --install is the only way into game/: the default run leaves game/assets/img/catfish alone, and --install DIR writes where it is told
[ "$(ls game/assets/img/catfish 2>/dev/null | wc -l)" = "$G0" ] && [ "$(ls -l game/assets/img/catfish 2>/dev/null | md5sum)" = "$GH0" ] || { echo "FAIL: game/assets/img/catfish changed after a plain build"; exit 1; }
I=$(mktemp -d); python3 tools/catfish_build_art.py --install "$I" | tail -1 | grep -q 'installed 440 files' || { echo "FAIL: --install DIR"; rm -rf "$I"; exit 1; }
[ "$(ls $I | wc -l)" = 440 ] || { echo "FAIL: installed file count"; rm -rf "$I"; exit 1; }
rm -rf "$I" tools/__pycache__
echo "catfish_build_art: ok"
