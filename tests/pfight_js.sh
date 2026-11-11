#!/bin/bash
# JS preview vs PHP engine: 3000 random situations (needs node).
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp); php "$HERE/pfight_js.php" >"$T" && node "$HERE/pfight_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
