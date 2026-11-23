#!/bin/bash
# Stat pieces plumbing (setting pfight_statpieces): data, ownership by tier, packing, numbers, the shared Luck roll, setting Off = unchanged; then PHP / JS parity on fights with stat pieces (tools/pfengine.js; needs node).
HERE=$(cd "$(dirname "$0")" && pwd)
php "$HERE/pf_stat_pieces.php" || exit 1
php "$HERE/pf_stat_luck.php" || exit 1
php "$HERE/pf_stat_nimble.php" || exit 1
php "$HERE/pf_stat_lore.php" || exit 1
php "$HERE/pf_stat_sense.php" || exit 1
T=$(mktemp); PFE_MODES=v1stat,v1luck,v1nimble,v1lore,v1sense php "$HERE/pfengine_js.php" >"$T" && node "$HERE/pfengine_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
