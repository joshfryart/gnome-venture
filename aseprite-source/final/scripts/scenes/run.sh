#!/bin/sh
# usage: run.sh <script.lua>...   needs Aseprite AppImage extracted at $ASE (default /tmp/claude-0/ase/squashfs-root)
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
ASE="${ASE:-/tmp/claude-0/ase/squashfs-root/AppRun}"
for f in "$@"; do GV_ROOT="$ROOT/" "$ASE" -b --script "$f" 2>&1 | grep -v '^$'; done
