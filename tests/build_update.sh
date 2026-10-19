#!/bin/bash
# Build the update zips for a release (v0.7.82+). Run from the folder holding game/ and tests/:
#   bash tests/build_update.sh 0.7.83 0.7.81
# 1st arg = this version, 2nd = the version two releases back (the slim zip can go on top of it or anything newer).
# Makes GnomeVenture-<v>-web-update.zip (slim: files changed since the base, plus bootstrap.php and index.php, plus UPDATE-BASE.txt),
# GnomeVenture-<v>-web-update-FULL.zip (everything, for when the live site is further behind) and GnomeVenture-<v>-source.zip,
# and saves tests/manifests/<v>.txt for future releases.
# v1.5.2: refuse to build with leftover merge-conflict markers (one slipped into style.css in 1.4.8)
if grep -rnE "^(<<<<<<<|=======|>>>>>>>)( |$)" game tests --include=*.php --include=*.js --include=*.css --include=*.txt --include=*.sh >/dev/null 2>&1; then echo "Merge conflict markers found:"; grep -rnE "^(<<<<<<<|=======|>>>>>>>)( |$)" game tests --include=*.php --include=*.js --include=*.css --include=*.txt --include=*.sh | head; exit 1; fi
set -e
V=$1; BASE=$2; OUT=${3:-$HOME}
[ -f tests/manifests/$BASE.txt ] || { echo "No manifest for $BASE: make a FULL zip only"; exit 1; }
python3 tests/manifest.py game tests/manifests/$V.txt
T=$(mktemp -d); mkdir -p $T/full $T/slim
cp -r game $T/full/ && rm -rf $T/full/game/data $T/full/game/config.php $T/full/game/install.php
( cd $T/full && rm -f $OUT/GnomeVenture-$V-web-update-FULL.zip && zip -qr $OUT/GnomeVenture-$V-web-update-FULL.zip game )
# files whose hash differs from the base, or that are new
python3 - "$BASE" "$V" > $T/list.txt <<'PY'
import sys
def load(v): return dict((l[42:].strip(), l[:40]) for l in open(f'tests/manifests/{v}.txt') if l.strip())
old, new = load(sys.argv[1]), load(sys.argv[2])
want = {f for f, h in new.items() if old.get(f) != h} | {'includes/bootstrap.php', 'index.php'}
print('\n'.join(sorted(want)))
PY
mkdir -p $T/slim/game
while read f; do mkdir -p "$T/slim/game/$(dirname "$f")"; cp "game/$f" "$T/slim/game/$f"; done < $T/list.txt
echo "$BASE" > $T/slim/game/UPDATE-BASE.txt
( cd $T/slim && rm -f $OUT/GnomeVenture-$V-web-update.zip && zip -qr $OUT/GnomeVenture-$V-web-update.zip game )
rm -f $OUT/GnomeVenture-$V-source.zip && zip -qr $OUT/GnomeVenture-$V-source.zip game tests -x "game/data/*" "game/config.php"
echo "slim: $(wc -l < $T/list.txt) files (needs v$BASE+) · full: $(unzip -l $OUT/GnomeVenture-$V-web-update-FULL.zip | tail -1 | awk '{print $2}') files"
rm -rf $T
