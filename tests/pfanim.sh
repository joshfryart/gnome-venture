#!/bin/bash
# 2.7.55 piece effects (assets/pfanim.js): the data builds and matches its sources, the engine loads on a real v1 fight page (3x3, 4x4, 5x5 and a boss AOE at 390 px),
# the place / play / chain overlay appears in a replay, the replay's steps come at the same times with the effects on and off, Off and reduced motion draw nothing,
# Light only lands the pieces, a skip drops everything, no console error, the layout does not move. Screenshots in SHOTS (default: a temp dir, printed).
# Usage: tests/pfanim.sh [GAME_COPY_DIR] [PORT]   (default: copies game/ to a temp dir, port 8893)
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
F0=0
python3 "$ROOT/tools/build_pfanim.py" --check || F0=$((F0+1))
node "$HERE/pfanim_unit.js" "$ROOT" | tail -3; [ ${PIPESTATUS[0]} -eq 0 ] || F0=$((F0+1))
node --check "$ROOT/game/assets/pfanim.js" && node --check "$ROOT/game/assets/pfboardv1.js" || F0=$((F0+1))
GAME=${1:-}; PORT=${2:-8893}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "${SRC:-$ROOT/game}" "$T/game"; GAME=$T/game; fi
if [ -e "$GAME/config.php" ] || [ -e "$GAME/data/game.sqlite" ]; then echo "pfanim.sh: $GAME must be a fresh game copy (no config.php, no data/game.sqlite)"; exit 1; fi; mkdir -p "$GAME/data"   # nothing is deleted: the temp copy stays (printed)
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null" EXIT; echo "game copy: $GAME"
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
  : > $C   # a new session (the cookie jar emptied, not deleted)
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
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_v1','1')" >/dev/null; db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_intro','0')" >/dev/null   # 2.7.57: the first-time intro card would cover the board
db "UPDATE users SET level=12 WHERE username='sprout'" >/dev/null
SHOTS=${SHOTS:-$(mktemp -d)}; echo "screenshots: $SHOTS"
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfanim.js" "$BASE" "$GAME" "$HERE" "$SHOTS" 2>&1 | tee $H.out | cut -c1-400
  FAILS=$(grep -c '^FAIL' $H.out); [ "$(grep -c '^pfanim: done' $H.out)" = 1 ] || FAILS=$((FAILS+1))
else echo "skip (no playwright)"; FAILS=0; fi
FAILS=$((FAILS+F0))
[ "$FAILS" -eq 0 ] && echo "pfanim ok" || echo "$FAILS FAILED"
[ "$FAILS" -eq 0 ]
