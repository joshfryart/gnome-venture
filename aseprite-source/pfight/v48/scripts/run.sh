#!/bin/bash
# usage: SC=<scratch dir with ase.sh> scripts/run.sh   (draw every v48 file with Aseprite, make the sheets, check). Then: ASE=$SC/ase.sh python3 tools/build_parts48.py
D="$(cd "$(dirname "$0")" && pwd)"
"${SC:?set SC to the scratch dir that holds ase.sh}/ase.sh" --batch --script "$D/build_all.lua" | grep -v -E '^glyph' && python3 -W ignore "$D/make_sheet.py" && python3 -W ignore "$D/check.py" | tee "$D/check-output.txt" | grep -v '^PASS'
