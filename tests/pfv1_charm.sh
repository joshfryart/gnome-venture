#!/bin/bash
# 2.6.78: charm pieces and the end of a fight, in a real browser on the served v1 fight page (setting pfight_v1).
# Josh: "Sometimes the page reloads quickly and it's weird. Usually after I play a pink piece" / "the charm bar fills but the fight does not end" / "play the last turn fully, then show the end".
# Plays charm pieces (plain, in a row, a charm that fills the bar, a defeat) and asserts: the page is never reloaded or navigated (the swap is in place), no failed request,
# no console error, the replay of the last turn plays (banners, the bar reaching full) BEFORE the end scene, and a reload after the end still lands on the result.
# Usage: tests/pfv1_charm.sh [PORT]
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
PORT=${1:-8811}; T=$(mktemp -d); cp -r "${SRC:-$ROOT/game}" "$T/game"; GAME=$T/game
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$HERE/router.php" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; rm -rf \"$T\"" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
install() {   # install, register sprout, onboard: on the server at $1 with the game copy $2
  local B=$BASE G=$GAME; BASE=$1; GAME=$2
  get install.php >/dev/null
  post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
  grep -q 'All planted' $H || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
  rm -f $C
  get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
  get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
  get 'welcome.php?step=place' >/dev/null
  local RID=$(db "SELECT id FROM regions WHERE code='NA'")
  local VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
  post welcome.php -d do=place -d village_id=$VID >/dev/null
  get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
  db "UPDATE users SET energy=100, tour_step=99 WHERE username='sprout'" >/dev/null
  db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','1')" >/dev/null; db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','board')" >/dev/null
  BASE=$B; GAME=$G
}
install "$BASE" "$GAME"
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_v1','1')" >/dev/null
db "UPDATE users SET level=12 WHERE username='sprout'" >/dev/null
echo "== charm pieces and the end of the fight (browser)"
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfv1_charm.js" "$BASE" "$GAME" "$HERE" 2>&1 | tee $H.out | cut -c1-400
  FAILS=$(grep -c '^FAIL' $H.out); [ "$(grep -c '^charm: done' $H.out)" = 1 ] || FAILS=$((FAILS+1))
else echo "skip (no playwright)"; FAILS=0; fi
[ -n "$FAILS" ] && [ "$FAILS" -eq 0 ] && echo "pfv1_charm ok" || echo "$FAILS FAILED"
[ "${FAILS:-1}" -eq 0 ]
