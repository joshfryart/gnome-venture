#!/bin/bash
# Redraw every staged rig (one script per slug in scripts/), then the real-engine preview and the swap tests.
#   art-review/rigs/run_all.sh            # draw + checks only (fast)
#   art-review/rigs/run_all.sh --full     # also preview.sh (before_after_pilot.png) and swap_test.sh
set -u
HERE=$(cd "$(dirname "$0")" && pwd); BAD=0
for f in "$HERE"/scripts/*.py; do python3 "$f" | grep -q ' OK$' || { echo "FAIL $(basename $f)"; BAD=1; }; done
echo "drawn: $(ls "$HERE"/out/rig-*.png | wc -l) sheets, problems: $BAD"
if [ "${1:-}" = --full ]; then bash "$HERE/preview.sh" && bash "$HERE/swap_test.sh" || BAD=1; fi
exit $BAD
