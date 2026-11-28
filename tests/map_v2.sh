#!/usr/bin/env bash
# Map v2 (includes/map_v2.php, setting map_v2_open; claude/proposal-map-v2-code.md section 8): off = every map byte-for-byte as before (golden hashes),
# on = the spread layout, the lit floor region widget, the delve-down world map; the world.php page with the setting on and off; mapv2.js; css_lint.
# Runs on a walk.sh-installed copy (player sprout). Usage: map_v2.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3
HERE=$(cd "$(dirname "$0")" && pwd)
TD=$(mktemp -d); trap 'kill $PID 2>/dev/null; rm -rf "$TD"' EXIT
php -d session.save_path=/tmp "$HERE/map_v2.php" "$GAME" || echo "FAIL map_v2.php exited non-zero"

echo "== 8.4 the page (world.php?tab=map) as player sprout"
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >"$TD/php.log" 2>&1 & PID=$!
for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$PORT/login.php" && break; sleep 0.2; done
C=$TD/ck
curl -s -c $C -b $C "http://127.0.0.1:$PORT/login.php" -o $TD/l.html
T=$(grep -o 'name="csrf" value="[^"]*"' $TD/l.html | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')
curl -s -c $C -b $C -X POST "http://127.0.0.1:$PORT/login.php" --data-urlencode "csrf=$T" -d username=sprout --data-urlencode 'password=TestPass123!' -o /dev/null
NA=$(php -r '$p=new PDO("sqlite:'"$GAME"'/data/game.sqlite"); echo $p->query("SELECT id FROM regions WHERE code = '"'NA'"'")->fetchColumn();')
page() { curl -s -c $C -b $C "http://127.0.0.1:$PORT/world.php?tab=map&r=$NA" -o $TD/p.html -w '%{http_code}'; }
php "$HERE/map_v2.php" "$GAME" --set map_v2_open 1 >/dev/null
CODE=$(page)
if [ "$CODE" = 200 ] && grep -q 'assets/mapv2.js' $TD/p.html && grep -q 'class="mv2"' $TD/p.html && ! grep -qE 'Warning:|Notice:|Fatal error|Deprecated:' $TD/p.html; then echo "ok   setting on: 200, mapv2.js and the widget, no PHP warning"
else echo "FAIL setting on: code $CODE, mapv2.js $(grep -c 'assets/mapv2.js' $TD/p.html), widget $(grep -c 'class="mv2"' $TD/p.html)"; grep -oE '(Warning|Notice|Fatal error|Deprecated):[^<]{0,200}' $TD/p.html | head -3; fi
if grep -q '<script>' $TD/p.html || grep -q 'class="mv2[^"]*" style=' $TD/p.html; then echo "FAIL inline script or style on the page"; else echo "ok   no inline script (CSP)"; fi
php "$HERE/map_v2.php" "$GAME" --set map_v2_open 0 >/dev/null
CODE=$(page)
if [ "$CODE" = 200 ] && ! grep -q 'assets/mapv2.js' $TD/p.html && ! grep -q 'class="mv2"' $TD/p.html; then echo "ok   setting off: neither the script nor the widget"; else echo "FAIL setting off: code $CODE"; fi
if grep -hE 'PHP (Warning|Notice|Fatal|Deprecated)' $TD/php.log | grep -q .; then echo "FAIL PHP warnings in the server log"; grep -hE 'PHP (Warning|Notice|Fatal|Deprecated)' $TD/php.log | head -5; fi

echo "== 8.4 mapv2.js and the CSS"
if command -v node >/dev/null; then node --check "$GAME/assets/mapv2.js" && echo "ok   node --check mapv2.js" || echo "FAIL node --check mapv2.js"; else echo "ok   (node not on the path: mapv2.js syntax not checked)"; fi
if grep -qE 'setTimeout|setInterval' "$GAME/assets/mapv2.js"; then echo "FAIL mapv2.js uses a timer"; else echo "ok   mapv2.js has no timers"; fi
bash "$HERE/css_lint.sh" "$GAME" | sed 's/^/  /'
