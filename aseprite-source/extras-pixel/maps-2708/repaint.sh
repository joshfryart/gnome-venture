#!/bin/bash
# Repaint region maps from tools/map_layout.lua with the chain that made the live art (2.7.08; it rebuilds the 2.7.07 live maps bit for bit from the old layout):
#   1. opus-test-run/scripts/upgrade/map-<R>-fit.lua   (reads tools/map_layout.lua: roads, trails, stops, clear rings)  -> opus-test-run/game/assets/img/scenes/map-<R>-fit.png
#   2. aseprite-source/v3/finish3/maps/batch.lua        (restyle; reads game/assets/img/scenes/map-<R>.png)            -> finish3/maps/out/map-<R>.png
#   3. aseprite-source/v3/finish5/maps-a/maps.lua (NA CA CB SA NWE SE EE) or maps-b/maps-b.lua (MENA WCA ESA CSA EA SEA OC; also reads map_layout.lua) on base/map-<R>.png
#   4. install: game/assets/img/scenes/map-<R>.png; the old live picture is kept in aseprite-source/extras-pixel/maps-2708/before/
# Usage: bash aseprite-source/extras-pixel/maps-2708/repaint.sh [ASEPRITE] R [R ...]
#   ASEPRITE defaults to $ASEPRITE or `aseprite`; the AppImage runs without FUSE once extracted: Aseprite_1.3.18.6-x64.AppImage --appimage-extract -> squashfs-root/AppRun
set -e
ROOT=$(cd "$(dirname "$0")/../../.." && pwd); HERE="$ROOT/aseprite-source/extras-pixel/maps-2708"
A=${ASEPRITE:-aseprite}; if [ -x "${1:-}" ]; then A=$1; shift; fi
mkdir -p "$HERE/before" "$HERE/log"
for R in "$@"; do
  LIVE="$ROOT/game/assets/img/scenes/map-$R.png"
  [ -f "$HERE/before/map-$R.png" ] || cp "$LIVE" "$HERE/before/map-$R.png"
  GV_ROOT="$ROOT/" "$A" -b --script "$ROOT/opus-test-run/scripts/upgrade/map-$R-fit.lua" > "$HERE/log/$R.log" 2>&1
  cp "$ROOT/opus-test-run/game/assets/img/scenes/map-$R-fit.png" "$LIVE"
  "$A" -b --script-param name=$R --script "$ROOT/aseprite-source/v3/finish3/maps/batch.lua" >> "$HERE/log/$R.log" 2>&1
  case $R in NA|CA|CB|SA|NWE|SE|EE) P=maps-a; S=maps.lua;; *) P=maps-b; S=maps-b.lua;; esac
  cp "$ROOT/aseprite-source/v3/finish3/maps/out/map-$R.png" "$ROOT/aseprite-source/v3/finish5/$P/base/map-$R.png"
  "$A" -b --script-param name=$R --script-param out="$ROOT/aseprite-source/v3/finish5/$P/out/" --script "$ROOT/aseprite-source/v3/finish5/$P/$S" >> "$HERE/log/$R.log" 2>&1
  cp "$ROOT/aseprite-source/v3/finish5/$P/out/map-$R.png" "$LIVE"
  echo "map-$R repainted"
done
