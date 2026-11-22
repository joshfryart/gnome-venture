#!/bin/bash
# 2.7.01 costly cell (learn.md item 1): a lit spot whose chain costs your health has a red edge and names the cause; once placed the line above End turn says it; in a gnome's first fights End turn asks once.
# Also the help sheet rows the learner review found missing (how a fight ends, lit-spot numbers, combos). Install as in pfv1_charm.sh; real browser on the served v1 fight page.
# The lit-spot numbers are real (the page asks the server); the test rewrites one answer so one spot costs 4 health (a costly spot in a seeded fight is luck).
# Usage: tests/pfv1_costly.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
GAME=${1:-}; PORT=${2:-8811}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "${SRC:-$ROOT/game}" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
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
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_intro','0')" >/dev/null   # 2.7.57: the first-time intro card would cover the board
db "UPDATE users SET level=12 WHERE username='sprout'" >/dev/null
echo "== costly cell: red edge, named cause, End turn asks once (browser)"
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfv1_costly.js" "$BASE" "$GAME" "$HERE" 2>&1 | tee $H.out | cut -c1-400
  FAILS=$(grep -c '^FAIL' $H.out); [ "$(grep -c '^costly: done' $H.out)" = 1 ] || FAILS=$((FAILS+1))
else echo "skip (no playwright)"; FAILS=0; fi
[ -n "$FAILS" ] && [ "$FAILS" -eq 0 ] && echo "pfv1_costly ok" || echo "$FAILS FAILED"
[ "${FAILS:-1}" -eq 0 ]
