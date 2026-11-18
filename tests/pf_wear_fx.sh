#!/bin/bash
# Wear piece effects (2.7.09): every trigger, payoff and Rare through the PHP engine, then PHP / JS parity on fights with wear pieces (tools/pfengine.js; needs node).
HERE=$(cd "$(dirname "$0")" && pwd)
php "$HERE/pf_wear_fx.php" || exit 1
T=$(mktemp); PFE_MODES=v1wear,v1wearc php "$HERE/pfengine_js.php" >"$T" && node "$HERE/pfengine_js.js" "$T"; rc=$?; rm -f "$T"; exit $rc
