#!/bin/sh
# Rebuild the 9 test-run files. usage: ASEPRITE=/path/to/aseprite sh opus-test-run/scripts/build.sh  (from the repo root)
# Each script prints a Part E check line (size, colours/cap, semi, black, badBlack, layerDiff, OK/FAIL).
ROOT="$(cd "$(dirname "$0")/../.." && pwd)/"
ASE="${ASEPRITE:-aseprite}"
for n in stage-grassland stage-forest banner-market home-cottage shop-general mini-aphid-swarm pin landmark-wild npc-unknown; do
  GV_ROOT="$ROOT" "$ASE" -b --script "$ROOT/opus-test-run/scripts/$n.lua"
done
