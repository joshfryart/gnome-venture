#!/bin/bash
# tools/pfengine.js (the JS port of the board engine) vs the PHP engine: whole fights replayed action by action (needs node).
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp); php "$HERE/pfengine_js.php" >"$T" && node "$HERE/pfengine_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
