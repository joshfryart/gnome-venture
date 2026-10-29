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
[ "$N" = 1348 ] || { echo "FAIL: expected 1348 files, got $N"; exit 1; }
grep -q 'built 1348 files' "$OUT.log" || { echo "FAIL: build count line"; exit 1; }
[ -f "$OUT/manifest.json" ] || { echo "FAIL: no manifest.json"; exit 1; }
python3 -I - "$OUT" <<'P'
import sys, json, hashlib, os, re
o = sys.argv[1]
m = json.load(open(o + '/manifest.json'))
assert m['count'] == 1348 == len(m['files'])
for r in m['files']:
    b = open(o + '/' + r['file'], 'rb').read()
    assert r['size'] == len(b) and r['sha1'] == hashlib.sha1(b).hexdigest(), r['file']
names = {r['file'] for r in m['files']}
for need in ('cf-cat-lilac-idleA.png', 'cf-bookhead-lilac.png', 'cf-bookhead-unknown.png', 'cf-room-window.png', 'cf-eyes-hazel-bored.png', 'cf-pat-calico-silver-blue-stalk.png',
             'cf-ears-folded-orange-nap.png', 'cf-tail-bobtail-black-catch.png', 'cf-up-catflap.png', 'cf-badge-book_full.png', 'cf-ribbon-part.png', 'cf-banner.png', 'cf-tile.png',
             'cf-cat-lilac-swatA.png', 'cf-pat-calico-orange-happy.png', 'cf-ears-folded-black-washB.png', 'cf-tail-bobtail-white-yawn.png', 'cf-eyes-blue-stretch.png', 'cf-ears-mask-jump.png',
             'cf-cat-grey-blink.png', 'cf-eyes-amber-blink.png', 'cf-pat-tabby-brown-tailflick.png', 'cf-tail-bobtail-cream-tailflick.png', 'cf-tail-mask-tailflick.png',
             'cf-pat-calico-lilac-eartwitch.png', 'cf-ears-folded-orange-eartwitch.png', 'cf-ears-mask-eartwitch.png', 'cf-z.png', 'cf-sparkle-1.png', 'cf-sparkle-3.png',
             'cf-bird-2.png', 'cf-yarn-4.png', 'cf-room-yarnpatch.png', 'cf-room-window-nobird.png',
             'cf-collar-rose-idleA.png', 'cf-collar-red-nap.png', 'cf-collar-violet-catch.png', 'cf-collar-gold-pounce.png', 'cf-season-petal-b.png', 'cf-season-flake-small.png', 'cf-season-firefly-b.png',
             'cf-yarn-1-rose.png', 'cf-yarn-4-gold.png', 'cf-yarn-3-mint.png', 'cf-yarn-2-violet.png', 'cf-yi-hold.png', 'cf-yi-titles.png', 'cf-yi-balls.png'):
    assert need in names, need
# alias frames carry only the layers they own (frames-alias-s2/s3.json): no tuxedo/calico on tailflick, no folded ears on tailflick, no pattern on blink, no ears on blink
for no in ('cf-pat-tuxedo-black-tailflick.png', 'cf-pat-calico-black-tailflick.png', 'cf-ears-folded-black-tailflick.png', 'cf-pat-tabby-black-blink.png', 'cf-tail-bobtail-black-blink.png',
           'cf-pat-spotted-black-eartwitch.png', 'cf-tail-bobtail-black-eartwitch.png', 'cf-eyes-amber-tailflick.png', 'cf-eyes-amber-eartwitch.png'):
    assert no not in names, no
# 2.2.x: 24 collars (4 frames x 6 colours), 8 season bits, 16 coloured yarn frames, 15 Yarn icons; no grey collar (the template is not shipped)
assert sum(n.startswith('cf-collar-') for n in names) == 24 and 'cf-collar-idleA.png' not in names
assert sum(n.startswith('cf-season-') for n in names) == 8 and sum(n.startswith('cf-yi-') for n in names) == 15
assert sum(n.startswith('cf-yarn-') for n in names) == 20
from PIL import Image
for n in range(1, 5):   # the redrawn grey frames are the ones from art22/out, not the old test art
    assert open(o + '/cf-yarn-%d.png' % n, 'rb').read() == open('aseprite-source/catfish/art22/out/cf-yarn-%d.png' % n, 'rb').read(), n
for n in range(1, 4): assert open(o + '/cf-bird-%d.png' % n, 'rb').read() == open('aseprite-source/catfish/art22/out/cf-bird-%d.png' % n, 'rb').read(), n
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
bad "a missing 2.2.x collar" 'rm cf-collar-rose-nap.png' 'missing required file cf-collar-rose-nap.png'
bad "a wrong season size" 'python3 -c "from PIL import Image; Image.new(\"RGBA\",(4,4),(1,2,3,255)).save(\"cf-season-leaf.png\")"' 'cf-season-leaf.png: size 4x4'
bad "a wrong Yarn icon size" 'python3 -c "from PIL import Image; Image.new(\"RGBA\",(16,64),(1,2,3,255)).save(\"cf-yi-hold.png\")"' 'cf-yi-hold.png: size 16x64'
bad "a semi-transparent pixel" 'python3 -c "from PIL import Image; im=Image.open(\"cf-ico-yarn.png\").convert(\"RGBA\"); im.putpixel((16,16),(200,10,10,128)); im.save(\"cf-ico-yarn.png\")"' 'cf-ico-yarn.png: semi-transparent'
# --install is the only way into game/: the default run leaves game/assets/img/catfish alone, and --install DIR writes where it is told
[ "$(ls game/assets/img/catfish 2>/dev/null | wc -l)" = "$G0" ] && [ "$(ls -l game/assets/img/catfish 2>/dev/null | md5sum)" = "$GH0" ] || { echo "FAIL: game/assets/img/catfish changed after a plain build"; exit 1; }
I=$(mktemp -d); python3 tools/catfish_build_art.py --install "$I" | tail -1 | grep -q 'installed 1348 files' || { echo "FAIL: --install DIR"; rm -rf "$I"; exit 1; }
[ "$(ls $I | wc -l)" = 1348 ] || { echo "FAIL: installed file count"; rm -rf "$I"; exit 1; }
rm -rf "$I" tools/__pycache__
echo "catfish_build_art: ok"
