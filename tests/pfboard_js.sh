#!/bin/bash
# JS legal cells vs the PHP board engine on random boards (needs node).
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp); php "$HERE/pfboard_js.php" >"$T" && node "$HERE/pfboard_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
