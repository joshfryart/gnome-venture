#!/bin/bash
# v2.0.31 Garden Plot Logic: fresh SQLite install in a temp copy, then tests/plot.php, then page renders (solution must not be in the HTML).
# Usage: tests/plot.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
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
echo "== pages (before the engine test touches the data)"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET coins=1000, level=20, energy=10");'
echo "plot.php -> $(get plot.php)"; grep -q 'Plant today’s bed' $H && echo "  start box shown"
echo "games.php -> $(get games.php)"; grep -q 'plot.php' $H && echo "  hub tile shown"
echo "rules -> $(get 'plot.php?t=rules')"; grep -q 'first solve each day' $H && echo "  rules show Petals row"; [ "$(grep -o '<li><span class="ricon"' $H | wc -l)" -ge 9 ] && echo "  rules rows ok"
get plot.php >/dev/null; post plot.php -d do=start >/dev/null
echo "plot.php (live) -> $(get plot.php)"
grep -q 'class="plotbed"' $H && echo "  bed shown"
[ "$(grep -o 'class="plotcell open"' $H | wc -l)" -ge 14 ] && echo "  open squares are selects"
SOL=$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=json_decode($p->query("SELECT state FROM game_state WHERE game=\"plot\"")->fetchColumn(),true); echo json_encode($s["sol"]);')
if grep -qF "$SOL" $H || grep -q '"sol"' $H; then echo "  FAIL solution leaked into the page"; else echo "  solution is not in the page"; fi
grep -q 'style="' $H && echo "  FAIL inline style found" || echo "  no inline styles"
grep -q 'assets/plot.js' $H && echo "  plot.js loaded"
echo "== engine (tests/plot.php)"
php -d display_errors=1 -d error_reporting=-1 -d memory_limit=512M "$HERE/plot.php" "$GAME" 2>&1; RC=$?
echo "== error log"; cat "$GAME/data/error-log.txt" 2>/dev/null | head -20
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
exit $RC
