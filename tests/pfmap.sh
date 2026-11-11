#!/bin/bash
# Puzzle combat on a random route map with a random creature (board and strip modes), phone + wide, with screenshots (SHOT=dir).
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8793}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; grep -oE "flash err[^<]*<[^<]*" $H; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
db "UPDATE users SET energy=100 WHERE username='sprout'" >/dev/null
FAILS=0
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=$n -d turn=$t "$@"; }
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','1')" >/dev/null
for MODE in board chain; do
  db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','$MODE')" >/dev/null
  for N in 1 2 3; do
    R=$(php -d display_errors=1 "$HERE/pfmap.php" "$GAME" $RANDOM 12 2>&1 | tail -1); echo "== $MODE #$N: $R"
    case "$R" in route*) ;; *) echo "FAIL could not set up a fight: $R"; FAILS=$((FAILS+1)); continue;; esac
    if [ -n "$SHOT" ]; then node "$HERE/pfmap.js" "$BASE" "$SHOT" "$MODE-$N" || { echo "FAIL map check ($MODE #$N)"; FAILS=$((FAILS+1)); }
    else get adventure.php >/dev/null; grep -q 'advgrid[^"]*pfover' $H && echo "ok   fight over map" || { echo "FAIL fight not over the map"; FAILS=$((FAILS+1)); }; fi
  done
done
# a chain on the board: play on (smart bot moves) until the page reports one, then check the glow, the stamp and the expiring cue in the browser
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','board')" >/dev/null
for TRY in $(seq 1 30); do
  php -d display_errors=1 "$HERE/pfmap.php" "$GAME" $((RANDOM)) 6 >/dev/null 2>&1; get adventure.php >/dev/null; FX=0; T=0
  while [ $T -lt 10 ]; do
    MV=$(php "$HERE/pfboard_move.php" "$GAME" 2>&1 | tail -1); [ "$MV" = "NONE" ] && break
    if [ "$MV" = "PASS" ]; then pf pfb_pass >/dev/null; else pf pfb_play -d moves="$MV" >/dev/null; fi
    get adventure.php >/dev/null; if grep -q '"fx":\[{' $H; then FX=1; break; fi; T=$((T+1))
  done
  [ $FX = 1 ] && break
done
if [ $FX = 1 ]; then
  if [ -n "$SHOT" ]; then node "$HERE/pfmap.js" "$BASE" "$SHOT" fx fx || { echo "FAIL chain glow check"; FAILS=$((FAILS+1)); }; else echo "ok   chain reported after $T turns"; fi
else echo "FAIL no chain happened in 30 fights"; FAILS=$((FAILS+1)); fi
grep -qi "warning\|fatal\|notice" $LOG && { echo "FAIL php log"; grep -i "warning\|fatal\|notice" $LOG | head -3; FAILS=$((FAILS+1)); } || echo "ok   no PHP warnings"
[ $FAILS = 0 ] && echo "pfmap ok" || { echo "$FAILS FAILED"; exit 1; }
