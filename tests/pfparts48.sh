#!/bin/bash
# The beauty-pass piece kit (assets/img/pfight/parts48/, tools/build_parts48.py, aseprite-source/pfight/v48) and its renderer (assets/pfparts47.js):
# the kit on disk is whole and keeps the v47 edge, the Aseprite sources pass their own check, and in a real browser: the creature's pieces carry a glyph per type
# (owner: "Need symbols on enemy pieces"), the environment's pieces are drawn by the kit (what the board paints over them afterwards is dropped), the number is on every piece,
# and a piece picture is redrawn for the size it is shown at (desktop scales 1.2 / 1.7 are not whole pixels) without changing the layout. The v47 kit still draws as before.
# Usage: tests/pfparts48.sh [PORT]
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd); PORT=${1:-8857}
FAILS=0; ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
ck "node --check assets/pfparts47.js" "$(node --check "$ROOT/game/assets/pfparts47.js" 2>&1 | wc -l | tr -d ' ')" "0"
ck "the parts48 kit is whole: every sheet, right sizes, no semi-transparent pixel, sockets / badges / overlays are v47's" "$(python3 -W ignore "$ROOT/tools/build_parts48.py" --check 2>&1 | wc -l | tr -d ' ')" "0"
ck "the v48 Aseprite sources pass their check (silhouette = v47, glyphs centred and clear of holes, interlock, outline)" "$(python3 -W ignore "$ROOT/aseprite-source/pfight/v48/scripts/check.py" 2>&1 | tail -1)" "RESULT ALL PASS"
ck "the atlas keeps version 47 (the sizes the board code knows) and says art 48" "$(php -r '$a=json_decode(file_get_contents($argv[1]),true); echo $a["version"]," ",$a["art"]," ",implode("x",$a["sizes"]["strip"]["piece"])," ",implode("x",$a["sizes"]["hand"]["piece"]);' "$ROOT/game/assets/img/pfight/parts48/atlas.json")" "47 48 82x73 140x124"
ck "the kit is small (under 60 KB without the shared marks)" "$(php -r '$n=0; foreach (glob($argv[1]."/*.*") as $f) $n+=filesize($f); echo $n < 60000 ? "yes" : $n;' "$ROOT/game/assets/img/pfight/parts48")" "yes"
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  T=$(mktemp -d); ln -s "$ROOT/game/assets" "$T/assets"
  for k in 48 47; do printf '<!doctype html><meta charset="utf-8"><link rel="icon" href="data:,"><body style="margin:0;background:#3a2a22"><i id="pfight"></i><script type="application/json" id="pf-data">{"art":"assets/img/pfight/","parts":"assets/img/pfight/parts%s/","mods":{},"tint":11}</script><div id="stage"></div><script src="assets/pfparts47.js"></script>' $k > "$T/k$k.html"; done
  php -S 127.0.0.1:$PORT -t "$T" >/dev/null 2>&1 & PID=$!; sleep 1; trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfparts48.js" "http://127.0.0.1:$PORT" 2>&1 | tee "$T/out" | cut -c1-400
  FAILS=$((FAILS + $(grep -c '^FAIL' "$T/out"))); [ "$(grep -c '^parts48: done' "$T/out")" = 1 ] || FAILS=$((FAILS+1))
else echo "skip the browser part (no playwright)"; fi
[ "$FAILS" -eq 0 ] && echo "pfparts48 ok" || echo "$FAILS FAILED"
[ "$FAILS" -eq 0 ]
