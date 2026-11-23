#!/bin/bash
# render.sh <script.lua> <name> [x0 y0 x1 y1]
# Runs the Lua script in Aseprite (headless), writes out/<name>_x6.png (6x view), prints a summary
# (+ character map for small canvases or the optional region), and a SCORE vs reference.png if present.
set -e
cd "$(dirname "$0")"
ASE="/c/Program Files/Aseprite/Aseprite.exe"
"$ASE" -b --script "$1" 2>&1 | tail -20
"$ASE" -b "out/$2.png" --scale 6 --save-as "out/$2_x6.png" >/dev/null 2>&1
PARAMS=(--script-param "png=$(pwd -W)/out/$2.png")
if [ -n "$3" ]; then PARAMS+=(--script-param "x0=$3" --script-param "y0=$4" --script-param "x1=$5" --script-param "y1=$6"); fi
"$ASE" -b "${PARAMS[@]}" --script dump.lua 2>&1
if [ -f reference.png ]; then python score.py "out/$2.png" reference.png out/scores.txt "$1" 2>&1 | tail -2; fi
echo "RENDERED: out/$2.png  (6x view: out/$2_x6.png)"
